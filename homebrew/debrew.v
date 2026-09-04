module homebrew

import ruby

// Translated from Homebrew/brew `debrew.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn (mut state DebrewState) run(action fn(mut DebrewState) !ruby.Value) !ruby.Value {
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

// Ruby method `install` at line 11.
pub fn ruby_debrew_l11_d1_install(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Debrew state is required')
	}
	mut state := debrew_state_from_value(args[0])
	result := if args.len > 1 { args[1] } else { ruby.object_value('NilClass', 'nil') }
	return state.formula_action('install', result)
}

// Ruby method `patch` at line 16.
pub fn ruby_debrew_l16_d2_patch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Debrew state is required')
	}
	mut state := debrew_state_from_value(args[0])
	result := if args.len > 1 { args[1] } else { ruby.object_value('NilClass', 'nil') }
	return state.formula_action('patch', result)
}

// Ruby method `test` at line 24.
pub fn ruby_debrew_l24_d3_test(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Debrew state is required')
	}
	mut state := debrew_state_from_value(args[0])
	result := if args.len > 1 { args[1] } else { ruby.object_value('NilClass', 'nil') }
	return state.formula_action('test', result)
}

// Ruby attr_accessor `attr_accessor :prompt` at line 37.
pub fn ruby_debrew_l37_d4_prompt(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	menu := debrew_menu_from_value(args[0])
	return if prompt := menu.prompt {
		ruby.string_value(prompt)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :prompt` at line 37.
pub fn ruby_debrew_l37_d5_prompt(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'prompt is required')
	}
	mut menu := debrew_menu_from_value(args[0])
	menu.prompt = if args[1].type_name == 'NilClass' { none } else { args[1].as_string() }
	return args[1]
}

// Ruby attr_accessor `attr_accessor :entries` at line 40.
pub fn ruby_debrew_l40_d6_entries(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	menu := debrew_menu_from_value(args[0])
	return ruby.array_value(menu.entries.map(ruby.structured_value('Debrew::Menu::Entry', it.name, {
		'name':   it.name
		'action': it.action.str()
	})))
}

// Ruby attr_accessor `attr_accessor :entries` at line 40.
pub fn ruby_debrew_l40_d7_entries(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'entries are required')
	}
	mut menu := debrew_menu_from_value(args[0])
	menu.entries = (args[1].as_array() or { [] }).map(DebrewMenuEntry{
		name: it.attributes['name'] or { it.as_string() }
		action: debrew_action_from_string(it.attributes['action'] or { it.as_string() })
	})
	return args[1]
}

// Ruby method `initialize` at line 43.
pub fn ruby_debrew_l43_d8_initialize(args ...ruby.Value) ruby.Value {
	_ = args
	return debrew_menu_value(new_debrew_menu())
}

// Ruby method `choice(name, &action)` at line 48.
pub fn ruby_debrew_l48_d9_choice(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'menu and name are required')
	}
	mut menu := debrew_menu_from_value(args[0])
	action := if args.len > 2 {
		debrew_action_from_string(args[2].as_string())
	} else {
		.raise_exception
	}
	menu.choice(args[1].as_string().trim_string_left(':'), action)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.choose(&_block)` at line 53.
pub fn ruby_debrew_l53_d10_self_choose(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'menu is required')
	}
	mut menu := debrew_menu_from_value(args[0])
	inputs := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	entry := menu.choose(inputs) or { return ruby.object_value('EOFError', err.msg()) }
	return ruby.object_value('Symbol', entry.action.str())
}

// Ruby attr_reader `attr_reader :debugged_exceptions` at line 88.
pub fn ruby_debrew_l88_d11_debugged_exceptions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	state := debrew_state_from_value(args[0])
	return ruby.string_array_value(state.debugged_exceptions.keys())
}

// Ruby method `active? = !@mutex.nil?` at line 91.
pub fn ruby_debrew_l91_d12_active(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && debrew_state_from_value(args[0]).active)
}

// Ruby method `self.debrew(&block)` at line 99.
pub fn ruby_debrew_l99_d13_self_debrew(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Debrew state is required')
	}
	mut state := debrew_state_from_value(args[0])
	state.boundary_result = if args.len > 1 {
		args[1]
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return state.run(debrew_boundary_action) or { ruby.object_value('RuntimeError', err.msg()) }
}

// Ruby method `self.debug(exception)` at line 107.
pub fn ruby_debrew_l107_d14_self_debug(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'state and exception are required')
	}
	mut state := debrew_state_from_value(args[0])
	inputs := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	action := state.debug(debrew_exception_from_value(args[1]), inputs) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.object_value('Symbol', action)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ignorable"
// 5:
// 6: # Helper module for debugging formulae.
// 7: module Debrew
// 8:   # Module for allowing to debug formulae.
// 9:   module Formula
// 10:     sig { void }
// 11:     def install
// 12:       Debrew.debrew { super }
// 13:     end
// 14:
// 15:     sig { void }
// 16:     def patch
// 17:       Debrew.debrew { super }
// 18:     end
// 19:
// 20:     sig {
// 21:       # TODO: replace `returns(BasicObject)` with `void` after dropping `return false` handling in test
// 22:       returns(BasicObject)
// 23:     }
// 24:     def test
// 25:       Debrew.debrew { super }
// 26:     end
// 27:   end
// 28:
// 29:   # Module for displaying a debugging menu.
// 30:   class Menu
// 31:     class Entry < T::Struct
// 32:       const :name, String
// 33:       const :action, T.proc.void
// 34:     end
// 35:
// 36:     sig { returns(T.nilable(String)) }
// 37:     attr_accessor :prompt
// 38:
// 39:     sig { returns(T::Array[Entry]) }
// 40:     attr_accessor :entries
// 41:
// 42:     sig { void }
// 43:     def initialize
// 44:       @entries = T.let([], T::Array[Entry])
// 45:     end
// 46:
// 47:     sig { params(name: Symbol, action: T.proc.void).void }
// 48:     def choice(name, &action)
// 49:       entries << Entry.new(name: name.to_s, action:)
// 50:     end
// 51:
// 52:     sig { params(_block: T.proc.params(menu: Menu).void).void }
// 53:     def self.choose(&_block)
// 54:       menu = new
// 55:       yield menu
// 56:
// 57:       choice = T.let(nil, T.nilable(Entry))
// 58:       while choice.nil?
// 59:         menu.entries.each_with_index { |e, i| puts "#{i + 1}. #{e.name}" }
// 60:         print menu.prompt unless menu.prompt.nil?
// 61:
// 62:         input = $stdin.gets || exit
// 63:         input.chomp!
// 64:
// 65:         i = input.to_i
// 66:         if i.positive?
// 67:           choice = menu.entries[i - 1]
// 68:         else
// 69:           possible = menu.entries.select { |e| e.name.start_with?(input) }
// 70:
// 71:           case possible.size
// 72:           when 0 then puts "No such option"
// 73:           when 1 then choice = possible.first
// 74:           else puts "Multiple options match: #{possible.map(&:name).join(" ")}"
// 75:           end
// 76:         end
// 77:       end
// 78:
// 79:       choice.action.call
// 80:     end
// 81:   end
// 82:
// 83:   @mutex = T.let(nil, T.nilable(Mutex))
// 84:   @debugged_exceptions = T.let(Set.new, T::Set[Exception])
// 85:
// 86:   class << self
// 87:     sig { returns(T::Set[Exception]) }
// 88:     attr_reader :debugged_exceptions
// 89:
// 90:     sig { returns(T::Boolean) }
// 91:     def active? = !@mutex.nil?
// 92:   end
// 93:
// 94:   sig {
// 95:     type_parameters(:U)
// 96:       .params(block: T.proc.returns(T.type_parameter(:U)))
// 97:       .returns(T.type_parameter(:U))
// 98:   }
// 99:   def self.debrew(&block)
// 100:     @mutex = Mutex.new
// 101:     Ignorable.hook_raise(on_ignorable: ->(e) { e.is_a?(SystemExit) ? :raise : debug(e) }, &block)
// 102:   ensure
// 103:     @mutex = nil
// 104:   end
// 105:
// 106:   sig { params(exception: Exception).returns(Symbol) }
// 107:   def self.debug(exception)
// 108:     raise(exception) if !active? || !debugged_exceptions.add?(exception) || !@mutex&.try_lock
// 109:
// 110:     begin
// 111:       puts exception.backtrace&.first
// 112:       puts Formatter.error(exception, label: exception.class.name)
// 113:
// 114:       loop do
// 115:         Menu.choose do |menu|
// 116:           menu.prompt = "Choose an action: "
// 117:
// 118:           menu.choice(:raise) { raise(exception) }
// 119:           menu.choice(:ignore) { return :ignore } if exception.is_a?(Ignorable::ExceptionMixin)
// 120:           menu.choice(:backtrace) { puts exception.backtrace }
// 121:
// 122:           if exception.is_a?(Ignorable::ExceptionMixin)
// 123:             menu.choice(:irb) do
// 124:               puts "When you exit this IRB session, execution will continue."
// 125:               set_trace_func proc { |event, _, _, id, binding, klass|
// 126:                 if klass == Object && id == :raise && event == "return"
// 127:                   set_trace_func(nil)
// 128:                   @mutex.synchronize do
// 129:                     require "debrew/irb"
// 130:                     IRB.start_within(binding)
// 131:                   end
// 132:                 end
// 133:               }
// 134:
// 135:               return :ignore
// 136:             end
// 137:           end
// 138:
// 139:           menu.choice(:shell) do
// 140:             puts "When you exit this shell, you will return to the menu."
// 141:             interactive_shell
// 142:           end
// 143:         end
// 144:       end
// 145:     ensure
// 146:       @mutex.unlock
// 147:     end
// 148:   end
// 149: end
