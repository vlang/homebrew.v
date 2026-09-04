module homebrew

import ruby

// Translated from Homebrew/brew `debrew.rb`.
pub enum DebrewMenuAction {
	raise_exception
	ignore
	backtrace
	irb
	shell
}

pub struct DebrewMenuEntry {
pub:
	name   string
	action DebrewMenuAction
}

@[heap]
pub struct DebrewMenu {
pub mut:
	prompt  ?string
	entries []DebrewMenuEntry
	output  []string
}

pub fn new_debrew_menu() &DebrewMenu {
	return &DebrewMenu{}
}

pub fn (mut menu DebrewMenu) choice(name string, action DebrewMenuAction) {
	menu.entries << DebrewMenuEntry{
		name: name
		action: action
	}
}

pub fn (mut menu DebrewMenu) choose(inputs []string) !DebrewMenuEntry {
	for raw_input in inputs {
		for index, entry in menu.entries {
			menu.output << '${index + 1}. ${entry.name}'
		}
		if prompt := menu.prompt {
			menu.output << prompt
		}
		input := raw_input.trim_right('\r\n')
		index := input.int()
		if index > 0 {
			if index <= menu.entries.len {
				return menu.entries[index - 1]
			}
			continue
		}
		possible := menu.entries.filter(it.name.starts_with(input))
		if possible.len == 0 {
			menu.output << 'No such option'
		} else if possible.len == 1 {
			return possible[0]
		} else {
			menu.output << 'Multiple options match: ${possible.map(it.name).join(' ')}'
		}
	}
	return error('input ended before a menu choice was selected')
}

pub struct DebrewException {
pub:
	id         string
	class_name string
	message    string
	backtrace  []string
	ignorable  bool
}

@[heap]
pub struct DebrewState {
pub mut:
	active              bool
	locked              bool
	debugged_exceptions map[string]bool
	output              []string
	formula_invocations []string
	boundary_result     ruby.Value
}

pub fn new_debrew_state() &DebrewState {
	return &DebrewState{
		debugged_exceptions: map[string]bool{}
	}
}

fn debrew_exception_key(exception DebrewException) string {
	return if exception.id != '' {
		exception.id
	} else {
		'${exception.class_name}:${exception.message}'
	}
}

pub fn (mut state DebrewState) run(action fn (mut DebrewState) !ruby.Value) !ruby.Value {
	state.active = true
	defer {
		state.active = false
		state.locked = false
	}
	return action(mut state)
}

pub fn (mut state DebrewState) debug(exception DebrewException, inputs []string) !string {
	key := debrew_exception_key(exception)
	if !state.active {
		return error(exception.message)
	}
	if key in state.debugged_exceptions {
		return error(exception.message)
	}
	state.debugged_exceptions[key] = true
	if state.locked {
		return error(exception.message)
	}
	state.locked = true
	defer {
		state.locked = false
	}
	if exception.backtrace.len > 0 {
		state.output << exception.backtrace[0]
	}
	state.output << '${exception.class_name}: ${exception.message}'
	mut input_offset := 0
	for input_offset < inputs.len {
		mut menu := new_debrew_menu()
		menu.prompt = 'Choose an action: '
		menu.choice('raise', .raise_exception)
		if exception.ignorable {
			menu.choice('ignore', .ignore)
		}
		menu.choice('backtrace', .backtrace)
		if exception.ignorable {
			menu.choice('irb', .irb)
		}
		menu.choice('shell', .shell)
		entry := menu.choose(inputs[input_offset..])!
		state.output << menu.output
		mut consumed := 1
		for index, item in menu.output {
			if item == 'No such option' || item.starts_with('Multiple options match:') {
				consumed++
			}
			_ = index
		}
		input_offset += consumed
		match entry.action {
			.raise_exception {
				return error(exception.message)
			}
			.ignore {
				return 'ignore'
			}
			.backtrace {
				state.output << exception.backtrace
			}
			.irb {
				state.output << 'When you exit this IRB session, execution will continue.'
				return 'ignore'
			}
			.shell {
				state.output << 'When you exit this shell, you will return to the menu.'
			}
		}
	}
	return error('input ended before a debugger action completed')
}

fn debrew_boundary_action(mut state DebrewState) !ruby.Value {
	return state.boundary_result
}

pub fn (mut state DebrewState) formula_action(name string, result ruby.Value) ruby.Value {
	state.formula_invocations << name
	state.boundary_result = result
	return state.run(debrew_boundary_action) or {
		ruby.object_value('RuntimeError', err.msg())
	}
}

fn debrew_state_value(state &DebrewState) ruby.Value {
	return ruby.structured_value('Debrew::State', '', {
		'debrew_state_address': u64(voidptr(state)).str()
	})
}

fn debrew_state_from_value(value ruby.Value) &DebrewState {
	address := value.attributes['debrew_state_address'] or { panic('invalid Debrew state') }
	return unsafe { &DebrewState(voidptr(address.u64())) }
}

pub fn debrew_state_boundary(state &DebrewState) ruby.Value {
	return debrew_state_value(state)
}

fn debrew_menu_value(menu &DebrewMenu) ruby.Value {
	return ruby.structured_value('Debrew::Menu', '', {
		'debrew_menu_address': u64(voidptr(menu)).str()
	})
}

fn debrew_menu_from_value(value ruby.Value) &DebrewMenu {
	address := value.attributes['debrew_menu_address'] or { panic('invalid Debrew menu') }
	return unsafe { &DebrewMenu(voidptr(address.u64())) }
}

pub fn debrew_menu_boundary(menu &DebrewMenu) ruby.Value {
	return debrew_menu_value(menu)
}

fn debrew_action_from_string(value string) DebrewMenuAction {
	return match value.trim_string_left(':') {
		'ignore' { .ignore }
		'backtrace' { .backtrace }
		'irb' { .irb }
		'shell' { .shell }
		else { .raise_exception }
	}
}

fn debrew_exception_from_value(value ruby.Value) DebrewException {
	return DebrewException{
		id: value.attributes['id'] or { value.repr }
		class_name: value.attributes['class_name'] or { value.type_name }
		message: value.attributes['message'] or { value.repr }
		backtrace: (value.attributes['backtrace'] or { '' }).split_into_lines()
		ignorable: value.attributes['ignorable'] == 'true'
	}
}
