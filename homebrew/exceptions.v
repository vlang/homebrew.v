module homebrew

import ruby
import os

pub struct BrewException {
pub:
	kind string
pub mut:
	message string
	fields  map[string]ruby.Value
	lists   map[string][]ruby.Value
}

pub fn (exception BrewException) msg() string {
	return exception.message
}

pub fn (exception BrewException) code() int {
	if status := exception.fields['exitstatus'] {
		if status.type_name != 'NilClass' {
			return int(status.int_data)
		}
	}
	return 1
}

pub struct ExecutionStatus {
pub:
	has_exitstatus bool
	exitstatus     int
	has_termsig    bool
	termsig        int
}

pub struct ExecutionOutputLine {
pub:
	kind string
	line string
}

// Models Ruby's required positional command and required keyword status before
// delegating to the concrete ErrorDuringExecution initializer.
pub fn execution_exception_from_optional(command ?[]string, status ?ExecutionStatus,
	output []ExecutionOutputLine, secrets []string) !BrewException {
	command_value := command or { return error('ErrorDuringExecution requires command') }
	status_value := status or { return error('ErrorDuringExecution requires status') }
	return execution_exception(command_value, status_value, output, secrets)
}

pub struct ExceptionFormulaConflict {
pub:
	name   string
	reason string
}

pub struct FormulaClassEntry {
pub:
	name            string
	derived_formula bool
}

pub fn new_brew_exception(kind string, message string,
	fields map[string]ruby.Value) BrewException {
	return BrewException{
		kind: kind
		message: message
		fields: fields.clone()
		lists: map[string][]ruby.Value{}
	}
}

fn exception_with_lists(kind string, message string, fields map[string]ruby.Value,
	lists map[string][]ruby.Value) BrewException {
	return BrewException{
		kind: kind
		message: message
		fields: fields.clone()
		lists: lists.clone()
	}
}

pub fn brew_exception_value(exception BrewException) ruby.Value {
	mut data := exception.fields.clone()
	for key, values in exception.lists {
		data[key] = ruby.array_value(values)
	}
	return ruby.Value{
		type_name: exception.kind
		repr: exception.message
		map_data: data
		attributes: {
			'kind':    exception.kind
			'message': exception.message
		}
	}
}

pub fn brew_exception_from_value(value ruby.Value) BrewException {
	mut fields := value.map_data.clone()
	mut lists := map[string][]ruby.Value{}
	for key, child in value.map_data {
		if child.type_name == 'Array' {
			lists[key] = child.array_data.clone()
			fields.delete(key)
		}
	}
	return BrewException{
		kind: value.attribute('kind') or { value.type_name }
		message: value.attribute('message') or { value.repr }
		fields: fields
		lists: lists
	}
}

fn exception_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn exception_field(value ruby.Value, name string) ruby.Value {
	return value.map_data[name] or { exception_nil_value() }
}

fn exception_set_field(value ruby.Value, name string,
	new_value ruby.Value) ruby.Value {
	mut exception := brew_exception_from_value(value)
	exception.fields[name] = new_value
	return brew_exception_value(exception)
}

fn exception_string(value ruby.Value) string {
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn exception_inspect(value ruby.Value) string {
	return match value.type_name {
		'String' { '"${value.as_string()}"' }
		'Symbol' { value.as_string() }
		'NilClass' { 'nil' }
		else { value.as_string() }
	}
}

fn exception_bool_attribute(value ruby.Value, name string) bool {
	return value.attribute(name) or { 'false' } == 'true'
}

fn exception_class_entries(values []ruby.Value) []FormulaClassEntry {
	return values.map(FormulaClassEntry{
		name: it.attribute('name') or { it.as_string().split('::').last() }
		derived_formula: exception_bool_attribute(it, 'derived_formula')
	})
}

pub fn usage_exception(reason string) BrewException {
	message := if reason.len > 0 { 'Invalid usage: ${reason}' } else { 'Invalid usage' }
	return new_brew_exception('UsageError', message, {
		'reason': if reason.len > 0 {
			ruby.string_value(reason)
		} else {
			exception_nil_value()
		}
	})
}

pub fn no_such_keg_exception(name string, tap string, cellar string) BrewException {
	mut message := 'No such keg: ${cellar.trim_right('/')}/${name}'
	if tap.len > 0 {
		message += ' from tap ${tap}'
	}
	return new_brew_exception('NoSuchKegError', message, {
		'name': ruby.string_value(name)
		'tap':  if tap.len > 0 {
			ruby.object_value('Tap', tap)
		} else {
			exception_nil_value()
		}
	})
}

pub fn formula_unavailable_exception(name string, similar []string, auto_without_api bool,
	core_installed bool) BrewException {
	did_you_mean := if similar.len == 0 { '' } else { 'Did you mean ${sentence_or(similar)}?' }
	mut message := 'No available formula or cask with the name "${name}". ${did_you_mean}'.trim_space()
	if auto_without_api && !core_installed {
		message += '\nA full git tap clone is required to use this command on core packages.'
	}
	return new_brew_exception('FormulaOrCaskUnavailableError', message, {
		'name':             ruby.string_value(name)
		'similar':          ruby.string_array_value(similar)
		'auto_without_api': ruby.bool_value(auto_without_api)
		'core_installed':   ruby.bool_value(core_installed)
	})
}

fn sentence_or(values []string) string {
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} or ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')} or ${values.last()}'
}

fn sentence_and(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} and ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')}, and ${values.last()}'
}

pub fn tap_required_message(base string, tap string, installed bool) string {
	if installed {
		return base
	}
	return '${base}\nThis command requires the tap ${tap}.\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap ${tap}'
}

pub fn formula_dependent_suffix(name string, dependent string) string {
	if dependent.len == 0 || dependent == name {
		return ''
	}
	return ' (dependency of ${dependent})'
}

pub fn formula_class_list_message(entries []FormulaClassEntry) string {
	if entries.len == 0 {
		return 'found no classes'
	}
	derived := entries.filter(it.derived_formula)
	if derived.len == 0 {
		return 'only found: ${entries.map(it.name).join(', ')} (not derived from Formula!)'
	}
	return 'only found: ${derived.map(it.name).join(', ')}'
}

pub fn formula_class_exception(base BrewException, path string, class_name string,
	entries []FormulaClassEntry, kind string) BrewException {
	message := '${base.message}\nIn formula file: ${path}\nExpected to find class ${class_name}, but ${formula_class_list_message(entries)}.'
	mut fields := base.fields.clone()
	fields['path'] = ruby.string_value(path)
	fields['class_name'] = ruby.string_value(class_name)
	list := entries.map(ruby.structured_value('Class', it.name, {
		'name':            it.name
		'derived_formula': it.derived_formula.str()
	}))
	return exception_with_lists(kind, message, fields, {
		'class_list': list
	})
}

pub fn tap_unavailable_exception(name string, core_taps []string) BrewException {
	command := if name in core_taps { 'brew tap --force ${name}' } else { 'brew tap-new ${name}' }
	action := if name in core_taps { 'tap ${name}' } else { 'create a new ${name} tap' }
	return new_brew_exception('TapUnavailableError', 'No available tap ${name}.\nRun ${command} to ${action}!\n', {
		'name': ruby.string_value(name)
	})
}

pub fn remote_mismatch_exception(name string, expected string, actual string,
	core bool) BrewException {
	message := if core {
		'Tap ${name} remote does not match `\$HOMEBREW_CORE_GIT_REMOTE`.\n${expected} != ${actual}\nPlease set `HOMEBREW_CORE_GIT_REMOTE="${actual}"` and run `brew update` instead.\n'
	} else {
		'Tap ${name} remote mismatch.\n${expected} != ${actual}\n'
	}
	return new_brew_exception(if core {
		'TapCoreRemoteMismatchError'
	} else {
		'TapRemoteMismatchError'
	}, message, {
		'name':            ruby.string_value(name)
		'expected_remote': if expected.len > 0 {
			ruby.string_value(expected)
		} else {
			exception_nil_value()
		}
		'actual_remote':   ruby.string_value(actual)
	})
}

pub fn operation_in_progress_exception(path string, waited ?int, command string,
	lock_context string) BrewException {
	advice := if seconds := waited {
		'Gave up after waiting ${seconds} seconds. Terminate it to continue.'
	} else {
		'Please wait for it to finish or terminate it to continue.'
	}
	context := if lock_context.len > 0 { '\n${lock_context}' } else { '' }
	return new_brew_exception('OperationInProgressError', 'A `${if command.len > 0 {
		command
	} else {
		'brew'
	}}` process has already locked ${path}.${context}\n${advice}\n', {
		'locked_path': ruby.string_value(path)
	})
}

pub fn formula_conflict_exception(formula string, conflicts []ExceptionFormulaConflict,
	prefix string) BrewException {
	mut messages := [
		'Cannot install ${formula} because conflicting formulae are installed.',
	]
	for conflict in conflicts {
		mut line := '  ${conflict.name}'
		if conflict.reason.len > 0 {
			line += ': because ${conflict.reason}'
		}
		messages << line
	}
	messages << ''
	messages << "Please `brew unlink ${conflicts.map(it.name).join(' ')}` before continuing.\n\nUnlinking removes a formula's symlinks from ${prefix}. You can\nlink the formula again after the install finishes. You can `--force` this\ninstall, but the build may fail or cause obscure side effects in the\nresulting software.\n"
	values := conflicts.map(ruby.structured_value('Formula::FormulaConflict', it.name, {
		'name':   it.name
		'reason': it.reason
	}))
	return exception_with_lists('FormulaConflictError', messages.join('\n'), {
		'formula': ruby.object_value('Formula', formula)
	}, {
		'conflicts': values
	})
}

fn escape_build_argument(value string) string {
	return value.replace('\\', '\\\\').replace(' ', '\\ ')
}

fn shell_escape(value string) string {
	if value.len == 0 {
		return "''"
	}
	mut escaped := ''
	for character in value {
		if !character.is_alnum() && character !in [`_`, `-`, `.`, `/`, `:`, `+`, `,`, `@`, `%`] {
			escaped += '\\'
		}
		escaped += character.ascii_str()
	}
	return escaped
}

fn signal_name(signal int) string {
	return match signal {
		1 { 'HUP' }
		2 { 'INT' }
		3 { 'QUIT' }
		4 { 'ILL' }
		5 { 'TRAP' }
		6 { 'ABRT' }
		7 { 'BUS' }
		8 { 'FPE' }
		9 { 'KILL' }
		10 { 'USR1' }
		11 { 'SEGV' }
		12 { 'USR2' }
		13 { 'PIPE' }
		14 { 'ALRM' }
		15 { 'TERM' }
		17 { 'CHLD' }
		18 { 'CONT' }
		19 { 'STOP' }
		20 { 'TSTP' }
		21 { 'TTIN' }
		22 { 'TTOU' }
		else { signal.str() }
	}
}

pub fn build_exception(formula ruby.Value, command ruby.Value,
	arguments []ruby.Value, environment map[string]ruby.Value) BrewException {
	pretty := arguments.map(escape_build_argument(it.as_string())).join(' ')
	message := 'Failed executing: ${command.as_string()} ${pretty}'.trim_space()
	return exception_with_lists('BuildError', message, {
		'formula': formula
		'cmd':     command
		'env':     ruby.map_value(environment)
		'options': exception_nil_value()
	}, {
		'args': arguments
	})
}

pub fn execution_exception(command []string, status ExecutionStatus,
	output []ExecutionOutputLine, secrets []string) !BrewException {
	return execution_exception_with_terminal(command, status, output, secrets, ruby.stdout_is_terminal(), os.getenv('HOMEBREW_NO_COLOR') != '', os.getenv('HOMEBREW_COLOR') != '')
}

// Supplies the terminal facts used by Formatter.error while keeping the
// ErrorDuringExecution rendering deterministic for callers and tests.
pub fn execution_exception_with_terminal(command []string, status ExecutionStatus,
	output []ExecutionOutputLine, secrets []string, stdout_is_terminal bool, no_color bool,
	force_color bool) !BrewException {
	mut rendered := command.map(shell_escape(it)).join(' ').replace('\\=', '=')
	for secret in secrets {
		rendered = rendered.replace(secret, '******')
	}
	reason := if status.has_exitstatus {
		'exited with ${status.exitstatus}'
	} else if status.has_termsig {
		'was terminated by uncaught signal ${signal_name(status.termsig)}'
	} else {
		return error('Status neither has `exitstatus` nor `termsig`.')
	}
	mut message := 'Failure while executing; `${rendered}` ${reason}.'
	if output.len > 0 {
		message += " Here's the output:\n"
		use_color := (stdout_is_terminal || force_color) && !no_color
		message += output.map(if it.kind.trim_left(':') == 'stderr' && use_color {
			'\x1b[31m${it.line}\x1b[0m'
		} else {
			it.line
		}).join('')
		if !message.ends_with('\n') {
			message += '\n'
		}
	}
	lines := output.map(ruby.structured_value('OutputLine', it.line, {
		'type': it.kind
	}))
	return exception_with_lists('ErrorDuringExecution', message, {
		'cmd':        ruby.string_array_value(command)
		'status':     execution_status_value(status)
		'exitstatus': if status.has_exitstatus {
			ruby.int_value(status.exitstatus)
		} else {
			exception_nil_value()
		}
		'termsig':    if status.has_termsig {
			ruby.int_value(status.termsig)
		} else {
			exception_nil_value()
		}
	}, {
		'output': lines
	})
}

fn execution_status_value(status ExecutionStatus) ruby.Value {
	return ruby.structured_value('Process::Status', if status.has_exitstatus {
		status.exitstatus.str()
	} else {
		'signal ${status.termsig}'
	}, {
		'exitstatus': if status.has_exitstatus { status.exitstatus.str() } else { '' }
		'termsig':    if status.has_termsig { status.termsig.str() } else { '' }
	})
}

fn execution_status_from_value(value ruby.Value) ExecutionStatus {
	if value.type_name == 'Integer' {
		return ExecutionStatus{ has_exitstatus: true, exitstatus: int(value.int_data) }
	}
	if value.type_name == 'Hash' {
		exit := value.map_data['exitstatus'] or { exception_nil_value() }
		signal := value.map_data['termsig'] or { exception_nil_value() }
		return ExecutionStatus{
			has_exitstatus: exit.type_name != 'NilClass'
			exitstatus: int(exit.int_data)
			has_termsig: signal.type_name != 'NilClass'
			termsig: int(signal.int_data)
		}
	}
	exit := value.attribute('exitstatus') or { '' }
	signal := value.attribute('termsig') or { '' }
	return ExecutionStatus{
		has_exitstatus: exit.len > 0
		exitstatus: exit.int()
		has_termsig: signal.len > 0
		termsig: signal.int()
	}
}

pub fn checksum_html_hint(path string, is_path bool, cache string) string {
	if !is_path || !os.is_file(path) {
		return ''
	}
	data := os.read_bytes(path) or { return '' }
	head_size := if data.len < 512 { data.len } else { 512 }
	head := data[..head_size].bytestr().trim_space().to_lower()
	if !head.starts_with('<!doctype html') && !head.starts_with('<html') && !(head.starts_with('<?xml') && head.contains('<html')) {
		return ''
	}
	cache_prefix := '${cache.trim_right('/')}/'
	command := if cache.len > 0 && path.starts_with(cache_prefix) {
		'rm "\$(brew --cache)/${path.all_after(cache_prefix)}"'
	} else {
		'rm "${path}"'
	}
	return '\nThe start of the downloaded file is HTML/XML, not a binary.\nThe server may have returned a bot-protection, rate-limit or\nerror page instead. Delete the file and retry:\n  ${command}\n'
}

fn exception_output_lines(value ruby.Value) []ExecutionOutputLine {
	return value.array_data.map(ExecutionOutputLine{
		kind: it.attribute('type') or { '' }
		line: it.as_string()
	})
}

// Translated from Homebrew/brew `exceptions.rb`.

// Ruby method `to_s` at line 167.
pub fn ruby_exceptions_l167_d23_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return ruby.string_value(brew_exception_from_value(args[0]).message)
}
