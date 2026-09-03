module homebrew

import brew_runtime
import os

pub struct BrewException {
pub:
	kind string
pub mut:
	message string
	fields  map[string]brew_runtime.Value
	lists   map[string][]brew_runtime.Value
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
	fields map[string]brew_runtime.Value) BrewException {
	return BrewException{
		kind: kind
		message: message
		fields: fields.clone()
		lists: map[string][]brew_runtime.Value{}
	}
}

fn exception_with_lists(kind string, message string, fields map[string]brew_runtime.Value,
	lists map[string][]brew_runtime.Value) BrewException {
	return BrewException{
		kind: kind
		message: message
		fields: fields.clone()
		lists: lists.clone()
	}
}

pub fn brew_exception_value(exception BrewException) brew_runtime.Value {
	mut data := exception.fields.clone()
	for key, values in exception.lists {
		data[key] = brew_runtime.array_value(values)
	}
	return brew_runtime.Value{
		type_name: exception.kind
		repr: exception.message
		map_data: data
		attributes: {
			'kind':    exception.kind
			'message': exception.message
		}
	}
}

pub fn brew_exception_from_value(value brew_runtime.Value) BrewException {
	mut fields := value.map_data.clone()
	mut lists := map[string][]brew_runtime.Value{}
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

fn exception_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn exception_field(value brew_runtime.Value, name string) brew_runtime.Value {
	return value.map_data[name] or { exception_nil_value() }
}

fn exception_set_field(value brew_runtime.Value, name string,
	new_value brew_runtime.Value) brew_runtime.Value {
	mut exception := brew_exception_from_value(value)
	exception.fields[name] = new_value
	return brew_exception_value(exception)
}

fn exception_string(value brew_runtime.Value) string {
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn exception_inspect(value brew_runtime.Value) string {
	return match value.type_name {
		'String' { '"${value.as_string()}"' }
		'Symbol' { value.as_string() }
		'NilClass' { 'nil' }
		else { value.as_string() }
	}
}

fn exception_bool_attribute(value brew_runtime.Value, name string) bool {
	return value.attribute(name) or { 'false' } == 'true'
}

fn exception_class_entries(values []brew_runtime.Value) []FormulaClassEntry {
	return values.map(FormulaClassEntry{
		name: it.attribute('name') or { it.as_string().split('::').last() }
		derived_formula: exception_bool_attribute(it, 'derived_formula')
	})
}

pub fn usage_exception(reason string) BrewException {
	message := if reason.len > 0 { 'Invalid usage: ${reason}' } else { 'Invalid usage' }
	return new_brew_exception('UsageError', message, {
		'reason': if reason.len > 0 {
			brew_runtime.string_value(reason)
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
		'name': brew_runtime.string_value(name)
		'tap':  if tap.len > 0 {
			brew_runtime.object_value('Tap', tap)
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
		'name':             brew_runtime.string_value(name)
		'similar':          brew_runtime.string_array_value(similar)
		'auto_without_api': brew_runtime.bool_value(auto_without_api)
		'core_installed':   brew_runtime.bool_value(core_installed)
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
	fields['path'] = brew_runtime.string_value(path)
	fields['class_name'] = brew_runtime.string_value(class_name)
	list := entries.map(brew_runtime.structured_value('Class', it.name, {
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
		'name': brew_runtime.string_value(name)
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
		'name':            brew_runtime.string_value(name)
		'expected_remote': if expected.len > 0 {
			brew_runtime.string_value(expected)
		} else {
			exception_nil_value()
		}
		'actual_remote':   brew_runtime.string_value(actual)
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
		'locked_path': brew_runtime.string_value(path)
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
	values := conflicts.map(brew_runtime.structured_value('Formula::FormulaConflict', it.name, {
		'name':   it.name
		'reason': it.reason
	}))
	return exception_with_lists('FormulaConflictError', messages.join('\n'), {
		'formula': brew_runtime.object_value('Formula', formula)
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

pub fn build_exception(formula brew_runtime.Value, command brew_runtime.Value,
	arguments []brew_runtime.Value, environment map[string]brew_runtime.Value) BrewException {
	pretty := arguments.map(escape_build_argument(it.as_string())).join(' ')
	message := 'Failed executing: ${command.as_string()} ${pretty}'.trim_space()
	return exception_with_lists('BuildError', message, {
		'formula': formula
		'cmd':     command
		'env':     brew_runtime.map_value(environment)
		'options': exception_nil_value()
	}, {
		'args': arguments
	})
}

pub fn execution_exception(command []string, status ExecutionStatus,
	output []ExecutionOutputLine, secrets []string) !BrewException {
	return execution_exception_with_terminal(command, status, output, secrets, brew_runtime.stdout_is_terminal(), os.getenv('HOMEBREW_NO_COLOR') != '', os.getenv('HOMEBREW_COLOR') != '')
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
	lines := output.map(brew_runtime.structured_value('OutputLine', it.line, {
		'type': it.kind
	}))
	return exception_with_lists('ErrorDuringExecution', message, {
		'cmd':        brew_runtime.string_array_value(command)
		'status':     execution_status_value(status)
		'exitstatus': if status.has_exitstatus {
			brew_runtime.int_value(status.exitstatus)
		} else {
			exception_nil_value()
		}
		'termsig':    if status.has_termsig {
			brew_runtime.int_value(status.termsig)
		} else {
			exception_nil_value()
		}
	}, {
		'output': lines
	})
}

fn execution_status_value(status ExecutionStatus) brew_runtime.Value {
	return brew_runtime.structured_value('Process::Status', if status.has_exitstatus {
		status.exitstatus.str()
	} else {
		'signal ${status.termsig}'
	}, {
		'exitstatus': if status.has_exitstatus { status.exitstatus.str() } else { '' }
		'termsig':    if status.has_termsig { status.termsig.str() } else { '' }
	})
}

fn execution_status_from_value(value brew_runtime.Value) ExecutionStatus {
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

fn exception_output_lines(value brew_runtime.Value) []ExecutionOutputLine {
	return value.array_data.map(ExecutionOutputLine{
		kind: it.attribute('type') or { '' }
		line: it.as_string()
	})
}

// Translated from Homebrew/brew `exceptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :reason` at line 14.
pub fn ruby_exceptions_l14_d1_reason(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('reason requires exception') }
	return exception_field(args[0], 'reason')
}

// Ruby method `initialize(reason = nil)` at line 17.
pub fn ruby_exceptions_l17_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	reason := if args.len > 0 { exception_string(args[0]) } else { '' }
	return brew_exception_value(usage_exception(reason))
}

// Ruby method `to_s` at line 24.
pub fn ruby_exceptions_l24_d3_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby method `initialize` at line 34.
pub fn ruby_exceptions_l34_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_exception_value(usage_exception('this command requires a formula argument'))
}

// Ruby method `initialize` at line 42.
pub fn ruby_exceptions_l42_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_exception_value(usage_exception('this command requires a formula or cask argument'))
}

// Ruby method `initialize` at line 50.
pub fn ruby_exceptions_l50_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_exception_value(usage_exception('this command requires a keg argument'))
}

// Ruby attr_reader `attr_reader :name` at line 67.
pub fn ruby_exceptions_l67_d7_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby attr_reader `attr_reader :tap` at line 70.
pub fn ruby_exceptions_l70_d8_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('tap requires exception') }
	return exception_field(args[0], 'tap')
}

// Ruby method `initialize(name, tap: nil)` at line 73.
pub fn ruby_exceptions_l73_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('NoSuchKegError requires name') }
	tap := if args.len > 1 { exception_string(args[1]) } else { '' }
	mut cellar := brew_runtime.environment_value('HOMEBREW_CELLAR')
	if cellar.len == 0 {
		cellar = '/opt/homebrew/Cellar'
	}
	return brew_exception_value(no_such_keg_exception(args[0].as_string(), tap, cellar))
}

// Ruby attr_reader `attr_reader :attr` at line 85.
pub fn ruby_exceptions_l85_d10_attr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('attr requires exception') }
	return exception_field(args[0], 'attr')
}

// Ruby attr_reader `attr_reader :formula` at line 88.
pub fn ruby_exceptions_l88_d11_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula requires exception') }
	return exception_field(args[0], 'formula')
}

// Ruby method `initialize(formula, attr, value)` at line 91.
pub fn ruby_exceptions_l91_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('FormulaValidationError requires formula, attr, and value') }
	return brew_exception_value(new_brew_exception('FormulaValidationError', "invalid attribute for formula '${args[0].as_string()}': ${args[1].as_string()} (${exception_inspect(args[2])})", {
		'formula': args[0]
		'attr':    args[1]
	}))
}

// Ruby attr_reader `attr_reader :attr` at line 100.
pub fn ruby_exceptions_l100_d13_attr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('attr requires exception') }
	return exception_field(args[0], 'attr')
}

// Ruby method `initialize(attr, value)` at line 103.
pub fn ruby_exceptions_l103_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('LegacyDSLError requires attr and value') }
	return brew_exception_value(new_brew_exception('LegacyDSLError', 'A legacy DSL was used: ${args[0].as_string()} (${exception_inspect(args[1])})', {
		'attr': args[0]
	}))
}

// Ruby attr_accessor `attr_accessor :issues_url` at line 114.
pub fn ruby_exceptions_l114_d15_issues_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('issues_url requires exception') }
	return exception_field(args[0], 'issues_url')
}

// Ruby attr_accessor `attr_accessor :issues_url` at line 114.
pub fn ruby_exceptions_l114_d16_issues_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('issues_url= requires exception and value') }
	return exception_set_field(args[0], 'issues_url', args[1])
}

// Ruby attr_reader `attr_reader :name` at line 120.
pub fn ruby_exceptions_l120_d17_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby method `initialize(name)` at line 123.
pub fn ruby_exceptions_l123_d18_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('FormulaOrCaskUnavailableError requires name') }
	similar := if args.len > 1 { args[1].string_array_data } else { []string{} }
	auto := if args.len > 2 { args[2].bool_data } else { false }
	core := if args.len > 3 { args[3].bool_data } else { true }
	return brew_exception_value(formula_unavailable_exception(args[0].as_string(), similar, auto, core))
}

// Ruby method `did_you_mean` at line 136.
pub fn ruby_exceptions_l136_d19_did_you_mean(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('did_you_mean requires exception') }
	similar := exception_field(args[0], 'similar').string_array_data
	return brew_runtime.string_value(if similar.len == 0 {
		''
	} else {
		'Did you mean ${sentence_or(similar)}?'
	})
}

// Ruby method `to_s` at line 146.
pub fn ruby_exceptions_l146_d20_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby attr_reader `attr_reader :tap` at line 158.
pub fn ruby_exceptions_l158_d21_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('tap requires exception') }
	return exception_field(args[0], 'tap')
}

// Ruby method `initialize(tap, name)` at line 161.
pub fn ruby_exceptions_l161_d22_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('TapFormulaOrCaskUnavailableError requires tap and name') }
	tap := args[0].as_string()
	base := formula_unavailable_exception('${tap}/${args[1].as_string()}', []string{}, false, true)
	installed := exception_bool_attribute(args[0], 'installed')
	mut fields := base.fields.clone()
	fields['tap'] = args[0]
	return brew_exception_value(new_brew_exception('TapFormulaOrCaskUnavailableError', tap_required_message(base.message, tap, installed), fields))
}

// Ruby method `to_s` at line 167.
pub fn ruby_exceptions_l167_d23_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby attr_accessor `attr_accessor :dependent` at line 182.
pub fn ruby_exceptions_l182_d24_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('dependent requires exception') }
	return exception_field(args[0], 'dependent')
}

// Ruby attr_accessor `attr_accessor :dependent` at line 182.
pub fn ruby_exceptions_l182_d25_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('dependent= requires exception and value') }
	mut exception := brew_exception_from_value(exception_set_field(args[0], 'dependent', args[1]))
	name := exception_string(exception.fields['name'] or { exception_nil_value() })
	dependent := exception_string(args[1])
	suggestion := exception_string(exception.fields['did_you_mean'] or { exception_nil_value() })
	exception.message = 'No available formula with the name "${name}"${formula_dependent_suffix(name, dependent)}. ${suggestion}'.trim_space()
	return brew_exception_value(exception)
}

// Ruby method `dependent_s` at line 185.
pub fn ruby_exceptions_l185_d26_dependent_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('dependent_s requires exception') }
	name := exception_string(exception_field(args[0], 'name'))
	dependent := exception_string(exception_field(args[0], 'dependent'))
	suffix := formula_dependent_suffix(name, dependent)
	return if suffix.len > 0 { brew_runtime.string_value(suffix) } else { exception_nil_value() }
}

// Ruby method `to_s` at line 190.
pub fn ruby_exceptions_l190_d27_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	exception := brew_exception_from_value(args[0])
	name := exception_string(exception.fields['name'] or { exception_nil_value() })
	dependent := exception_string(exception.fields['dependent'] or { exception_nil_value() })
	similar := exception.fields['similar'] or { brew_runtime.string_array_value([]string{}) }
	suggestion := if similar.string_array_data.len > 0 {
		'Did you mean ${sentence_or(similar.string_array_data)}?'
	} else {
		''
	}
	return brew_runtime.string_value('No available formula with the name "${name}"${formula_dependent_suffix(name, dependent)}. ${suggestion}'.trim_space())
}

// Ruby method `path; end` at line 202.
pub fn ruby_exceptions_l202_d28_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('path requires exception') }
	return exception_field(args[0], 'path')
}

// Ruby method `class_name; end` at line 205.
pub fn ruby_exceptions_l205_d29_class_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_name requires exception') }
	return exception_field(args[0], 'class_name')
}

// Ruby method `class_list; end` at line 208.
pub fn ruby_exceptions_l208_d30_class_list(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_list requires exception') }
	return args[0].map_data['class_list'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `to_s` at line 211.
pub fn ruby_exceptions_l211_d31_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby method `class_list_s` at line 221.
pub fn ruby_exceptions_l221_d32_class_list_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_list_s requires exception') }
	return brew_runtime.string_value(formula_class_list_message(exception_class_entries((args[0].map_data['class_list'] or { brew_runtime.array_value([]brew_runtime.Value{}) }).array_data)))
}

// Ruby method `format_list(class_list)` at line 233.
pub fn ruby_exceptions_l233_d33_format_list(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('format_list requires class list') }
	return brew_runtime.string_value(exception_class_entries(args[args.len - 1].array_data).map(it.name).join(', '))
}

// Ruby attr_reader `attr_reader :path` at line 243.
pub fn ruby_exceptions_l243_d34_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('path requires exception') }
	return exception_field(args[0], 'path')
}

// Ruby attr_reader `attr_reader :class_name` at line 246.
pub fn ruby_exceptions_l246_d35_class_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_name requires exception') }
	return exception_field(args[0], 'class_name')
}

// Ruby attr_reader `attr_reader :class_list` at line 249.
pub fn ruby_exceptions_l249_d36_class_list(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_list requires exception') }
	return args[0].map_data['class_list'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `initialize(name, path, class_name, class_list)` at line 255.
pub fn ruby_exceptions_l255_d37_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('FormulaClassUnavailableError requires name, path, class name, and class list')
	}
	base := new_brew_exception('FormulaUnavailableError', 'No available formula with the name "${args[0].as_string()}".', {
		'name': args[0]
	})
	return brew_exception_value(formula_class_exception(base, args[1].as_string(), args[2].as_string(), exception_class_entries(args[3].array_data), 'FormulaClassUnavailableError'))
}

// Ruby method `formula_error; end` at line 271.
pub fn ruby_exceptions_l271_d38_formula_error(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula_error requires exception') }
	return exception_field(args[0], 'formula_error')
}

// Ruby method `to_s` at line 274.
pub fn ruby_exceptions_l274_d39_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	exception := brew_exception_from_value(args[0])
	return brew_runtime.string_value('${exception_string(exception.fields['name'] or { exception_nil_value() })}: ${exception_string(exception.fields['formula_error'] or { exception_nil_value() })}')
}

// Ruby attr_reader `attr_reader :formula_error` at line 284.
pub fn ruby_exceptions_l284_d40_formula_error(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula_error requires exception') }
	return exception_field(args[0], 'formula_error')
}

// Ruby method `initialize(name, error)` at line 287.
pub fn ruby_exceptions_l287_d41_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('FormulaUnreadableError requires name and error') }
	return brew_exception_value(new_brew_exception('FormulaUnreadableError', '${args[0].as_string()}: ${args[1].as_string()}', {
		'name':          args[0]
		'formula_error': args[1]
	}))
}

// Ruby attr_reader `attr_reader :tap` at line 297.
pub fn ruby_exceptions_l297_d42_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('tap requires exception') }
	return exception_field(args[0], 'tap')
}

// Ruby attr_reader `attr_reader :user` at line 300.
pub fn ruby_exceptions_l300_d43_user(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('user requires exception') }
	return exception_field(args[0], 'user')
}

// Ruby attr_reader `attr_reader :repository` at line 303.
pub fn ruby_exceptions_l303_d44_repository(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('repository requires exception') }
	return exception_field(args[0], 'repository')
}

// Ruby method `initialize(tap, name)` at line 306.
pub fn ruby_exceptions_l306_d45_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('TapFormulaUnavailableError requires tap and name') }
	tap := args[0].as_string()
	base := formula_unavailable_exception('${tap}/${args[1].as_string()}', []string{}, false, true)
	installed := exception_bool_attribute(args[0], 'installed')
	mut fields := base.fields.clone()
	fields['tap'] = args[0]
	fields['user'] = brew_runtime.string_value(args[0].attribute('user') or { tap.all_before('/') })
	fields['repository'] = brew_runtime.string_value(args[0].attribute('repository') or { tap.all_after('/') })
	return brew_exception_value(new_brew_exception('TapFormulaUnavailableError', tap_required_message('No available formula with the name "${tap}/${args[1].as_string()}".', tap, installed), fields))
}

// Ruby method `to_s` at line 314.
pub fn ruby_exceptions_l314_d46_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('to_s requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby attr_reader `attr_reader :path` at line 329.
pub fn ruby_exceptions_l329_d47_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('path requires exception') }
	return exception_field(args[0], 'path')
}

// Ruby attr_reader `attr_reader :class_name` at line 332.
pub fn ruby_exceptions_l332_d48_class_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_name requires exception') }
	return exception_field(args[0], 'class_name')
}

// Ruby attr_reader `attr_reader :class_list` at line 335.
pub fn ruby_exceptions_l335_d49_class_list(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('class_list requires exception') }
	return args[0].map_data['class_list'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `initialize(tap, name, path, class_name, class_list)` at line 341.
pub fn ruby_exceptions_l341_d50_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('TapFormulaClassUnavailableError requires tap, name, path, class name, and class list')
	}
	tap_error := brew_exception_from_value(ruby_exceptions_l306_d45_initialize(args[0], args[1]))
	return brew_exception_value(formula_class_exception(tap_error, args[2].as_string(), args[3].as_string(), exception_class_entries(args[4].array_data), 'TapFormulaClassUnavailableError'))
}

// Ruby attr_reader `attr_reader :formula_error` at line 354.
pub fn ruby_exceptions_l354_d51_formula_error(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula_error requires exception') }
	return exception_field(args[0], 'formula_error')
}

// Ruby method `initialize(tap, name, error)` at line 357.
pub fn ruby_exceptions_l357_d52_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('TapFormulaUnreadableError requires tap, name, and error') }
	tap_error := brew_exception_from_value(ruby_exceptions_l306_d45_initialize(args[0], args[1]))
	mut fields := tap_error.fields.clone()
	fields['formula_error'] = args[2]
	return brew_exception_value(new_brew_exception('TapFormulaUnreadableError', '${exception_string(fields['name'] or { exception_nil_value() })}: ${args[2].as_string()}', fields))
}

// Ruby attr_reader `attr_reader :name` at line 367.
pub fn ruby_exceptions_l367_d53_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby attr_reader `attr_reader :taps` at line 370.
pub fn ruby_exceptions_l370_d54_taps(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('taps requires exception') }
	return args[0].map_data['taps'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby attr_reader `attr_reader :loaders` at line 373.
pub fn ruby_exceptions_l373_d55_loaders(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('loaders requires exception') }
	return args[0].map_data['loaders'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `initialize(name, loaders)` at line 376.
pub fn ruby_exceptions_l376_d56_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('TapFormulaAmbiguityError requires name and loaders') }
	loaders := args[1].array_data
	mut taps := []brew_runtime.Value{}
	for loader in loaders {
		if tap := loader.map_data['tap'] {
			if tap.type_name != 'NilClass' { taps << tap }
		}
	}
	formulae := taps.map('${it.as_string()}/${args[0].as_string()}')
	list := formulae.map('\n       * ${it}').join('')
	message := 'Formulae found in multiple taps:${list}\n\nPlease use the fully-qualified name (e.g. ${if formulae.len > 0 {
		formulae[0]
	} else {
		args[0].as_string()
	}}) to refer to a specific formula.\n'
	return brew_exception_value(exception_with_lists('TapFormulaAmbiguityError', message, {
		'name': args[0]
	}, {
		'taps':    taps
		'loaders': loaders
	}))
}

// Ruby attr_reader `attr_reader :name` at line 395.
pub fn ruby_exceptions_l395_d57_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby method `initialize(name)` at line 398.
pub fn ruby_exceptions_l398_d58_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('TapUnavailableError requires name') }
	core := if args.len > 1 {
		args[1].string_array_data
	} else {
		['homebrew/core', 'homebrew/cask']
	}
	return brew_exception_value(tap_unavailable_exception(args[0].as_string(), core))
}

// Ruby attr_reader `attr_reader :name` at line 420.
pub fn ruby_exceptions_l420_d59_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby attr_reader `attr_reader :expected_remote` at line 423.
pub fn ruby_exceptions_l423_d60_expected_remote(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('expected_remote requires exception') }
	return exception_field(args[0], 'expected_remote')
}

// Ruby attr_reader `attr_reader :actual_remote` at line 426.
pub fn ruby_exceptions_l426_d61_actual_remote(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('actual_remote requires exception') }
	return exception_field(args[0], 'actual_remote')
}

// Ruby method `initialize(name, expected_remote, actual_remote)` at line 429.
pub fn ruby_exceptions_l429_d62_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('TapRemoteMismatchError requires name, expected, and actual') }
	return brew_exception_value(remote_mismatch_exception(args[0].as_string(), exception_string(args[1]), args[2].as_string(), false))
}

// Ruby method `message` at line 438.
pub fn ruby_exceptions_l438_d63_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('message requires exception') }
	exception := brew_exception_from_value(args[0])
	return brew_runtime.string_value(remote_mismatch_exception(exception_string(exception.fields['name'] or { exception_nil_value() }), exception_string(exception.fields['expected_remote'] or { exception_nil_value() }), exception_string(exception.fields['actual_remote'] or { exception_nil_value() }), false).message)
}

// Ruby method `message` at line 449.
pub fn ruby_exceptions_l449_d64_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('message requires exception') }
	exception := brew_exception_from_value(args[0])
	return brew_runtime.string_value(remote_mismatch_exception(exception_string(exception.fields['name'] or { exception_nil_value() }), exception_string(exception.fields['expected_remote'] or { exception_nil_value() }), exception_string(exception.fields['actual_remote'] or { exception_nil_value() }), true).message)
}

// Ruby attr_reader `attr_reader :name` at line 461.
pub fn ruby_exceptions_l461_d65_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby method `initialize(name)` at line 464.
pub fn ruby_exceptions_l464_d66_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('TapAlreadyTappedError requires name') }
	return brew_exception_value(new_brew_exception('TapAlreadyTappedError', 'Tap ${args[0].as_string()} already tapped.\n', {
		'name': args[0]
	}))
}

// Ruby attr_reader `attr_reader :name` at line 476.
pub fn ruby_exceptions_l476_d67_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('name requires exception') }
	return exception_field(args[0], 'name')
}

// Ruby method `initialize(name)` at line 479.
pub fn ruby_exceptions_l479_d68_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('TapNoCustomRemoteError requires name') }
	return brew_exception_value(new_brew_exception('TapNoCustomRemoteError', 'Tap ${args[0].as_string()} with option `--custom-remote` but without a remote URL.\n', {
		'name': args[0]
	}))
}

// Ruby method `initialize(locked_path, waited: nil)` at line 494.
pub fn ruby_exceptions_l494_d69_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('OperationInProgressError requires locked path') }
	waited := if args.len > 1 && args[1].type_name != 'NilClass' {
		?int(int(args[1].int_data))
	} else {
		none
	}
	command := if args.len > 2 { args[2].as_string() } else { 'brew' }
	context := if args.len > 3 { args[3].as_string() } else { '' }
	return brew_exception_value(operation_in_progress_exception(args[0].as_string(), waited, command, context))
}

// Ruby method `initialize(formula)` at line 518.
pub fn ruby_exceptions_l518_d70_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('FormulaInstallationAlreadyAttemptedError requires formula') }
	full_name := args[0].attribute('full_name') or { args[0].as_string() }
	return brew_exception_value(new_brew_exception('FormulaInstallationAlreadyAttemptedError', 'Formula installation already attempted: ${full_name}', {
		'formula': args[0]
	}))
}

// Ruby method `initialize(reqs)` at line 526.
pub fn ruby_exceptions_l526_d71_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('UnsatisfiedRequirements requires requirements') }
	count := args[0].array_data.len
	message := if count == 1 {
		'An unsatisfied requirement failed this build.'
	} else {
		'Unsatisfied requirements failed this build.'
	}
	return brew_exception_value(new_brew_exception('UnsatisfiedRequirements', message, map[string]brew_runtime.Value{}))
}

// Ruby attr_reader `attr_reader :formula` at line 538.
pub fn ruby_exceptions_l538_d72_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula requires exception') }
	return exception_field(args[0], 'formula')
}

// Ruby attr_reader `attr_reader :conflicts` at line 541.
pub fn ruby_exceptions_l541_d73_conflicts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('conflicts requires exception') }
	return args[0].map_data['conflicts'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `initialize(formula, conflicts)` at line 544.
pub fn ruby_exceptions_l544_d74_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('FormulaConflictError requires formula and conflicts') }
	formula := args[0].attribute('full_name') or { args[0].as_string() }
	conflicts := args[1].array_data.map(ExceptionFormulaConflict{ name: it.attribute('name') or { it.as_string() }, reason: it.attribute('reason') or { '' } })
	mut prefix := brew_runtime.environment_value('HOMEBREW_PREFIX')
	if prefix.len == 0 {
		prefix = '/opt/homebrew'
	}
	return brew_exception_value(formula_conflict_exception(formula, conflicts, prefix))
}

// Ruby method `conflict_message(conflict)` at line 551.
pub fn ruby_exceptions_l551_d75_conflict_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('conflict_message requires conflict') }
	conflict := args[args.len - 1]
	name := conflict.attribute('name') or { conflict.as_string() }
	reason := conflict.attribute('reason') or { '' }
	mut message := '  ${name}'
	if reason.len > 0 {
		message += ': because ${reason}'
	}
	return brew_runtime.string_value(message)
}

// Ruby method `message` at line 559.
pub fn ruby_exceptions_l559_d76_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('message requires exception') }
	return brew_runtime.string_value(brew_exception_from_value(args[0]).message)
}

// Ruby method `initialize(formula)` at line 578.
pub fn ruby_exceptions_l578_d77_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('FormulaUnknownPythonError requires formula') }
	name := args[0].attribute('full_name') or { args[0].as_string() }
	message := 'The version of Python to use with the virtualenv in the `${name}` formula\ncannot be guessed automatically because a recognised Python dependency could not be found.\n\nIf you are using a non-standard Python dependency, please add `:using => "python@x.y"`\nto \'virtualenv_install_with_resources\' to resolve the issue manually.\n'
	return brew_exception_value(new_brew_exception('FormulaUnknownPythonError', message, {
		'formula': args[0]
	}))
}

// Ruby method `initialize(formula)` at line 592.
pub fn ruby_exceptions_l592_d78_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('FormulaAmbiguousPythonError requires formula') }
	name := args[0].attribute('full_name') or { args[0].as_string() }
	message := 'The version of Python to use with the virtualenv in the `${name}` formula\ncannot be guessed automatically.\n\nIf the simultaneous use of multiple Pythons is intentional, please add `:using => "python@x.y"`\nto \'virtualenv_install_with_resources\' to resolve the ambiguity manually.\n'
	return brew_exception_value(new_brew_exception('FormulaAmbiguousPythonError', message, {
		'formula': args[0]
	}))
}

// Ruby attr_reader `attr_reader :cmd` at line 608.
pub fn ruby_exceptions_l608_d79_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('cmd requires exception') }
	return exception_field(args[0], 'cmd')
}

// Ruby attr_reader `attr_reader :args` at line 611.
pub fn ruby_exceptions_l611_d80_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('args requires exception') }
	return args[0].map_data['args'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby attr_reader `attr_reader :env` at line 614.
pub fn ruby_exceptions_l614_d81_env(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('env requires exception') }
	return exception_field(args[0], 'env')
}

// Ruby attr_accessor `attr_accessor :formula` at line 617.
pub fn ruby_exceptions_l617_d82_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('formula requires exception') }
	return exception_field(args[0], 'formula')
}

// Ruby attr_accessor `attr_accessor :formula` at line 617.
pub fn ruby_exceptions_l617_d83_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('formula= requires exception and value') }
	return exception_set_field(args[0], 'formula', args[1])
}

// Ruby attr_accessor `attr_accessor :options` at line 620.
pub fn ruby_exceptions_l620_d84_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('options requires exception') }
	return exception_field(args[0], 'options')
}

// Ruby attr_accessor `attr_accessor :options` at line 620.
pub fn ruby_exceptions_l620_d85_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('options= requires exception and value') }
	return exception_set_field(args[0], 'options', args[1])
}

// Ruby method `initialize(formula, cmd, args, env)` at line 631.
pub fn ruby_exceptions_l631_d86_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 { panic('BuildError requires formula, command, arguments, and env') }
	return brew_exception_value(build_exception(args[0], args[1], args[2].array_data, args[3].map_data))
}

// Ruby method `issues` at line 642.
pub fn ruby_exceptions_l642_d87_issues(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('issues requires exception') }
	return args[0].map_data['issues'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `fetch_issues` at line 647.
pub fn ruby_exceptions_l647_d88_fetch_issues(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('fetch_issues requires exception') }
	if brew_runtime.environment_value('HOMEBREW_NO_BUILD_ERROR_ISSUES').len > 0 {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	return args[0].map_data['fetched_issues'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
}

// Ruby method `dump(verbose: false)` at line 660.
pub fn ruby_exceptions_l660_d89_dump(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('dump requires exception') }
	exception := brew_exception_from_value(args[0])
	formula := exception.fields['formula'] or { return brew_runtime.string_value('') }
	if formula.type_name == 'NilClass' {
		return brew_runtime.string_value('')
	}
	verbose := if args.len > 1 { args[1].bool_data } else { false }
	mut lines := []string{}
	if verbose {
		lines << 'Formula'
		if tap := formula.attribute('tap') { lines << 'Tap: ${tap}' }
		if path := formula.attribute('path') { lines << 'Path: ${path}' }
		lines << 'Configuration'
		lines << 'ENV'
		name := formula.attribute('full_name') or { formula.as_string() }
		version := formula.attribute('version') or { '' }
		lines << '${name} ${version} did not build'.trim_space()
	}
	tap := formula.attribute('tap') or { '' }
	if tap.len == 0 {
		lines << 'We cannot detect the correct tap to report this issue to.\nDo not report this issue to Homebrew/* repositories!'
	} else if url := formula.attribute('issues_url') {
		lines << 'If reporting this issue please do so at:\n  ${url}'
	} else {
		lines << 'If reporting this issue please do so to (not Homebrew/* repositories):\n  ${tap}'
	}
	issues := args[0].map_data['issues'] or { brew_runtime.array_value([]brew_runtime.Value{}) }
	if issues.array_data.len > 0 {
		lines << 'These open issues may also help:'
		lines << issues.array_data.map('${it.attribute('title') or { '' }} ${it.attribute('html_url') or { '' }}').join('\n')
	}
	return brew_runtime.string_value(lines.join('\n'))
}

// Ruby method `initialize(formulae)` at line 737.
pub fn ruby_exceptions_l737_d90_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('UnbottledError requires formulae') }
	names := args[0].array_data.map(it.attribute('full_name') or { it.as_string() })
	plural := if names.len == 1 { 'formula' } else { 'formulae' }
	bottles := if names.len == 1 { 'bottle' } else { 'bottles' }
	mut message := 'The following ${plural} cannot be installed from ${bottles} and must be\nbuilt from source.\n  ${sentence_and(names)}\n'
	if args.len > 1 && args[1].as_string().len > 0 {
		message += '${args[1].as_string()}\n'
	}
	return brew_exception_value(new_brew_exception('UnbottledError', message, map[string]brew_runtime.Value{}))
}

// Ruby method `initialize(flags, bottled: true)` at line 756.
pub fn ruby_exceptions_l756_d91_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('BuildFlagsError requires flags') }
	flags := args[0].string_array_data
	bottled := if args.len > 1 { args[1].bool_data } else { true }
	flag_text := if flags.len > 1 { 'flags' } else { 'flag' }
	require_text := if flags.len > 1 { 'require' } else { 'requires' }
	instructions := if args.len > 2 {
		args[2].as_string()
	} else {
		'Install the Command Line Tools for Xcode.'
	}
	bottle_text := if bottled {
		'Alternatively, remove the ${flag_text} to attempt bottle installation.\n'
	} else {
		''
	}
	message := 'The following ${flag_text}:\n  ${flags.join(', ')}\n${require_text} building tools, but none are installed.\n${instructions} ${bottle_text}\n'
	return brew_exception_value(new_brew_exception('BuildFlagsError', message, {
		'flags': args[0]
	}))
}

// Ruby method `initialize(formula)` at line 786.
pub fn ruby_exceptions_l786_d92_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('CompilerSelectionError requires formula') }
	name := args[0].attribute('full_name') or { args[0].as_string() }
	instructions := if args.len > 1 { args[1].as_string() } else { 'Install a supported compiler.' }
	return brew_exception_value(new_brew_exception('CompilerSelectionError', '${name} cannot be built with any available compilers.\n${instructions}\n', {
		'formula': args[0]
	}))
}

// Ruby attr_reader `attr_reader :cause` at line 797.
pub fn ruby_exceptions_l797_d93_cause(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('cause requires exception') }
	return exception_field(args[0], 'cause')
}

// Ruby method `initialize(downloadable, cause)` at line 800.
pub fn ruby_exceptions_l800_d94_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('DownloadError requires downloadable and cause') }
	name := args[0].attribute('download_queue_name') or { exception_inspect(args[0]) }
	return brew_exception_value(new_brew_exception('DownloadError', 'Failed to download resource ${exception_inspect(brew_runtime.string_value(name))}\n${args[1].as_string()}\n', {
		'downloadable': args[0]
		'cause':        args[1]
	}))
}

// Ruby method `initialize(url, details = nil)` at line 813.
pub fn ruby_exceptions_l813_d95_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('CurlDownloadStrategyError requires URL') }
	url := args[0].as_string()
	details := if args.len > 1 { exception_string(args[1]) } else { '' }
	suffix := if details.len > 0 { '\n${details}' } else { '' }
	message := if url.starts_with('file://') {
		'File cannot be read: ${url[7..]}${suffix}'
	} else {
		'Download failed: ${url}${suffix}'
	}
	return brew_exception_value(new_brew_exception('CurlDownloadStrategyError', message, {
		'url': args[0]
	}))
}

// Ruby method `initialize(url)` at line 827.
pub fn ruby_exceptions_l827_d96_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('HomebrewCurlDownloadStrategyError requires URL') }
	url := 'Homebrew-installed `curl` is not installed for: ${args[0].as_string()}'
	return ruby_exceptions_l813_d95_initialize(brew_runtime.string_value(url))
}

// Ruby attr_reader `attr_reader :cmd` at line 835.
pub fn ruby_exceptions_l835_d97_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('cmd requires exception') }
	return exception_field(args[0], 'cmd')
}

// Ruby attr_reader `attr_reader :exitstatus` at line 838.
pub fn ruby_exceptions_l838_d98_exitstatus(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('exitstatus requires exception') }
	return exception_field(args[0], 'exitstatus')
}

// Ruby attr_reader `attr_reader :status` at line 841.
pub fn ruby_exceptions_l841_d99_status(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('status requires exception') }
	return exception_field(args[0], 'status')
}

// Ruby attr_reader `attr_reader :termsig` at line 844.
pub fn ruby_exceptions_l844_d100_termsig(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('termsig requires exception') }
	return exception_field(args[0], 'termsig')
}

// Ruby attr_reader `attr_reader :output` at line 847.
pub fn ruby_exceptions_l847_d101_output(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('output requires exception') }
	if nil_flag := args[0].map_data['output_nil'] {
		if nil_flag.bool_data {
			return exception_nil_value()
		}
	}
	return args[0].map_data['output'] or { exception_nil_value() }
}

// Ruby method `initialize(cmd, status:, output: nil, secrets: [])` at line 857.
pub fn ruby_exceptions_l857_d102_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ErrorDuringExecution requires command and status') }
	command := if args[0].string_array_data.len > 0 {
		args[0].string_array_data
	} else {
		args[0].array_data.map(it.as_string())
	}
	output := if args.len > 2 && args[2].type_name != 'NilClass' {
		exception_output_lines(args[2])
	} else {
		[]ExecutionOutputLine{}
	}
	secrets := if args.len > 3 { args[3].string_array_data } else { []string{} }
	mut exception := execution_exception(command, execution_status_from_value(args[1]), output, secrets) or { panic(err) }
	exception.fields['output_nil'] = brew_runtime.bool_value(args.len <= 2 || args[2].type_name == 'NilClass')
	return brew_exception_value(exception)
}

// Ruby method `stderr` at line 917.
pub fn ruby_exceptions_l917_d103_stderr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('stderr requires exception') }
	output := args[0].map_data['output'] or { return brew_runtime.string_value('') }
	return brew_runtime.string_value(exception_output_lines(output).filter(it.kind.trim_left(':') == 'stderr').map(it.line).join(''))
}

// Ruby attr_reader `attr_reader :expected` at line 928.
pub fn ruby_exceptions_l928_d104_expected(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('expected requires exception') }
	return exception_field(args[0], 'expected')
}

// Ruby method `initialize(path, expected, actual)` at line 931.
pub fn ruby_exceptions_l931_d105_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('ChecksumMismatchError requires path, expected, and actual') }
	path := args[0].as_string()
	is_path := args[0].type_name == 'Pathname'
	cache := if args.len > 3 {
		args[3].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_CACHE')
	}
	hint := checksum_html_hint(path, is_path, cache)
	message := 'SHA-256 mismatch\nExpected: ${args[1].as_string()}\n  Actual: ${args[2].as_string()}\n    File: ${path}\nTo retry an incomplete download, remove the file above.${hint}\n'
	return brew_exception_value(new_brew_exception('ChecksumMismatchError', message, {
		'expected': args[1]
		'path':     args[0]
		'actual':   args[2]
	}))
}

// Ruby method `self.html_hint(path)` at line 947.
pub fn ruby_exceptions_l947_d106_self_html_hint(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('html_hint requires path') }
	cache := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_CACHE')
	}
	return brew_runtime.string_value(checksum_html_hint(args[0].as_string(), args[0].type_name == 'Pathname', cache))
}

// Ruby method `initialize(formula, resource)` at line 976.
pub fn ruby_exceptions_l976_d107_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ResourceMissingError requires formula and resource') }
	formula := if args[0].type_name == 'NilClass' {
		''
	} else {
		args[0].attribute('full_name') or { args[0].as_string() }
	}
	return brew_exception_value(new_brew_exception('ResourceMissingError', '${formula} does not define resource ${exception_inspect(args[1])}', {
		'formula':  args[0]
		'resource': args[1]
	}))
}

// Ruby method `initialize(resource)` at line 984.
pub fn ruby_exceptions_l984_d108_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('DuplicateResourceError requires resource') }
	return brew_exception_value(new_brew_exception('DuplicateResourceError', 'Resource ${exception_inspect(args[0])} is defined more than once', {
		'resource': args[0]
	}))
}

// Ruby method `initialize(bottle_path, formula_path)` at line 995.
pub fn ruby_exceptions_l995_d109_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('BottleFormulaUnavailableError requires bottle and formula paths') }
	return brew_exception_value(new_brew_exception('BottleFormulaUnavailableError', 'This bottle does not contain the formula file:\n  ${args[0].as_string()}\n  ${args[1].as_string()}\n', {
		'bottle_path':  args[0]
		'formula_path': args[1]
	}))
}

// Ruby attr_reader `attr_reader :status` at line 1007.
pub fn ruby_exceptions_l1007_d110_status(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('status requires exception') }
	return exception_field(args[0], 'status')
}

// Ruby method `initialize(status)` at line 1010.
pub fn ruby_exceptions_l1010_d111_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('ChildProcessError requires status') }
	return brew_exception_value(new_brew_exception('ChildProcessError', 'Forked child process failed: ${args[0].as_string()}', {
		'status': args[0]
	}))
}

// Ruby method `initialize(type, reason)` at line 1020.
pub fn ruby_exceptions_l1020_d112_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('ShebangDetectionError requires type and reason') }
	return brew_exception_value(new_brew_exception('ShebangDetectionError', 'Cannot detect ${args[0].as_string()} shebang: ${args[1].as_string()}.', {
		'type':   args[0]
		'reason': args[1]
	}))
}

// Ruby method `initialize(strongly_connected_components)` at line 1028.
pub fn ruby_exceptions_l1028_d113_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('CyclicDependencyError requires components') }
	mut cycles := []string{}
	for component in args[0].array_data {
		names := if component.string_array_data.len > 0 {
			component.string_array_data
		} else {
			component.array_data.map(it.as_string())
		}
		if names.len > 1 { cycles << sentence_and(names) }
	}
	return brew_exception_value(new_brew_exception('CyclicDependencyError', 'The following packages contain cyclic dependencies:\n  ${cycles.join('\n  ')}\n', {
		'components': args[0]
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # We intentionally want to have many exceptions in this file.
// 5: # rubocop:disable Style/OneClassPerFile
// 6:
// 7: require "utils/output"
// 8:
// 9: # Raised when a command is used wrong.
// 10: #
// 11: # @api internal
// 12: class UsageError < RuntimeError
// 13:   sig { returns(T.nilable(String)) }
// 14:   attr_reader :reason
// 15:
// 16:   sig { params(reason: T.nilable(String)).void }
// 17:   def initialize(reason = nil)
// 18:     super
// 19:
// 20:     @reason = reason
// 21:   end
// 22:
// 23:   sig { returns(String) }
// 24:   def to_s
// 25:     s = "Invalid usage"
// 26:     s += ": #{reason}" if reason
// 27:     s
// 28:   end
// 29: end
// 30:
// 31: # Raised when a command expects a formula and none was specified.
// 32: class FormulaUnspecifiedError < UsageError
// 33:   sig { void }
// 34:   def initialize
// 35:     super "this command requires a formula argument"
// 36:   end
// 37: end
// 38:
// 39: # Raised when a command expects a formula or cask and none was specified.
// 40: class FormulaOrCaskUnspecifiedError < UsageError
// 41:   sig { void }
// 42:   def initialize
// 43:     super "this command requires a formula or cask argument"
// 44:   end
// 45: end
// 46:
// 47: # Raised when a command expects a keg and none was specified.
// 48: class KegUnspecifiedError < UsageError
// 49:   sig { void }
// 50:   def initialize
// 51:     super "this command requires a keg argument"
// 52:   end
// 53: end
// 54:
// 55: class UnsupportedInstallationMethod < RuntimeError; end
// 56:
// 57: class MultipleVersionsInstalledError < RuntimeError; end
// 58:
// 59: # Raised when a path is not a keg.
// 60: #
// 61: # @api internal
// 62: class NotAKegError < RuntimeError; end
// 63:
// 64: # Raised when a keg doesn't exist.
// 65: class NoSuchKegError < RuntimeError
// 66:   sig { returns(String) }
// 67:   attr_reader :name
// 68:
// 69:   sig { returns(T.nilable(Tap)) }
// 70:   attr_reader :tap
// 71:
// 72:   sig { params(name: String, tap: T.nilable(Tap)).void }
// 73:   def initialize(name, tap: nil)
// 74:     @name = name
// 75:     @tap = tap
// 76:     message = "No such keg: #{HOMEBREW_CELLAR}/#{name}"
// 77:     message += " from tap #{tap}" if tap
// 78:     super message
// 79:   end
// 80: end
// 81:
// 82: # Raised when an invalid attribute is used in a formula.
// 83: class FormulaValidationError < StandardError
// 84:   sig { returns(T.any(Symbol, String)) }
// 85:   attr_reader :attr
// 86:
// 87:   sig { returns(String) }
// 88:   attr_reader :formula
// 89:
// 90:   sig { params(formula: String, attr: T.any(Symbol, String), value: T.untyped).void }
// 91:   def initialize(formula, attr, value)
// 92:     @attr = attr
// 93:     @formula = formula
// 94:     super "invalid attribute for formula '#{formula}': #{attr} (#{value.inspect})"
// 95:   end
// 96: end
// 97:
// 98: class LegacyDSLError < StandardError
// 99:   sig { returns(Symbol) }
// 100:   attr_reader :attr
// 101:
// 102:   sig { params(attr: Symbol, value: T.untyped).void }
// 103:   def initialize(attr, value)
// 104:     @attr = attr
// 105:     super "A legacy DSL was used: #{attr} (#{value.inspect})"
// 106:   end
// 107: end
// 108:
// 109: class FormulaSpecificationError < StandardError; end
// 110:
// 111: # Raised when a deprecated method is used.
// 112: class MethodDeprecatedError < StandardError
// 113:   sig { returns(T.nilable(String)) }
// 114:   attr_accessor :issues_url
// 115: end
// 116:
// 117: # Raised when neither a formula nor a cask with the given name is available.
// 118: class FormulaOrCaskUnavailableError < RuntimeError
// 119:   sig { returns(String) }
// 120:   attr_reader :name
// 121:
// 122:   sig { params(name: String).void }
// 123:   def initialize(name)
// 124:     super()
// 125:
// 126:     @name = name
// 127:
// 128:     # Store the state of these envs at the time the exception is thrown.
// 129:     # This is so we do the fuzzy search for "did you mean" etc under that same mode,
// 130:     # in case the list of formulae are different.
// 131:     @without_api = T.let(Homebrew::EnvConfig.no_install_from_api?, T::Boolean)
// 132:     @auto_without_api = T.let(Homebrew::EnvConfig.automatically_set_no_install_from_api?, T::Boolean)
// 133:   end
// 134:
// 135:   sig { returns(String) }
// 136:   def did_you_mean
// 137:     require "formula"
// 138:
// 139:     similar_formula_names = Homebrew.with_no_api_env_if_needed(@without_api) { Formula.fuzzy_search(name) }
// 140:     return "" if similar_formula_names.blank?
// 141:
// 142:     "Did you mean #{similar_formula_names.to_sentence two_words_connector: " or ", last_word_connector: " or "}?"
// 143:   end
// 144:
// 145:   sig { returns(String) }
// 146:   def to_s
// 147:     s = "No available formula or cask with the name \"#{name}\". #{did_you_mean}".strip
// 148:     if @auto_without_api && !CoreTap.instance.installed?
// 149:       s += "\nA full git tap clone is required to use this command on core packages."
// 150:     end
// 151:     s
// 152:   end
// 153: end
// 154:
// 155: # Raised when a formula or cask in a specific tap is not available.
// 156: class TapFormulaOrCaskUnavailableError < FormulaOrCaskUnavailableError
// 157:   sig { returns(Tap) }
// 158:   attr_reader :tap
// 159:
// 160:   sig { params(tap: Tap, name: String).void }
// 161:   def initialize(tap, name)
// 162:     super "#{tap}/#{name}"
// 163:     @tap = tap
// 164:   end
// 165:
// 166:   sig { returns(String) }
// 167:   def to_s
// 168:     s = super
// 169:     unless tap.installed?
// 170:       s += "\nThis command requires the tap #{tap}."
// 171:       s += "\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap #{tap}"
// 172:     end
// 173:     s
// 174:   end
// 175: end
// 176:
// 177: # Raised when a formula is not available.
// 178: #
// 179: # @api internal
// 180: class FormulaUnavailableError < FormulaOrCaskUnavailableError
// 181:   sig { returns(T.nilable(String)) }
// 182:   attr_accessor :dependent
// 183:
// 184:   sig { returns(T.nilable(String)) }
// 185:   def dependent_s
// 186:     " (dependency of #{dependent})" if dependent && dependent != name
// 187:   end
// 188:
// 189:   sig { returns(String) }
// 190:   def to_s
// 191:     "No available formula with the name \"#{name}\"#{dependent_s}. #{did_you_mean}".strip
// 192:   end
// 193: end
// 194:
// 195: # Shared methods for formula class errors.
// 196: module FormulaClassUnavailableErrorModule
// 197:   extend T::Helpers
// 198:
// 199:   abstract!
// 200:
// 201:   sig { abstract.returns(T.any(Pathname, String)) }
// 202:   def path; end
// 203:
// 204:   sig { abstract.returns(String) }
// 205:   def class_name; end
// 206:
// 207:   sig { abstract.returns(T::Array[T::Class[T.anything]]) }
// 208:   def class_list; end
// 209:
// 210:   sig { returns(String) }
// 211:   def to_s
// 212:     s = super
// 213:     s += "\nIn formula file: #{path}"
// 214:     s += "\nExpected to find class #{class_name}, but #{class_list_s}."
// 215:     s
// 216:   end
// 217:
// 218:   private
// 219:
// 220:   sig { returns(String) }
// 221:   def class_list_s
// 222:     formula_class_list = class_list.select { |klass| klass < Formula }
// 223:     if class_list.empty?
// 224:       "found no classes"
// 225:     elsif formula_class_list.empty?
// 226:       "only found: #{format_list(class_list)} (not derived from Formula!)"
// 227:     else
// 228:       "only found: #{format_list(formula_class_list)}"
// 229:     end
// 230:   end
// 231:
// 232:   sig { params(class_list: T::Array[T::Class[T.anything]]).returns(String) }
// 233:   def format_list(class_list)
// 234:     class_list.map { |klass| klass.name&.split("::")&.last }.join(", ")
// 235:   end
// 236: end
// 237:
// 238: # Raised when a formula does not contain a formula class.
// 239: class FormulaClassUnavailableError < FormulaUnavailableError
// 240:   include FormulaClassUnavailableErrorModule
// 241:
// 242:   sig { override.returns(T.any(Pathname, String)) }
// 243:   attr_reader :path
// 244:
// 245:   sig { override.returns(String) }
// 246:   attr_reader :class_name
// 247:
// 248:   sig { override.returns(T::Array[T::Class[T.anything]]) }
// 249:   attr_reader :class_list
// 250:
// 251:   sig {
// 252:     params(name: String, path: T.any(Pathname, String), class_name: String, class_list: T::Array[T::Class[T.anything]])
// 253:       .void
// 254:   }
// 255:   def initialize(name, path, class_name, class_list)
// 256:     @path = path
// 257:     @class_name = class_name
// 258:     @class_list = class_list
// 259:     super name
// 260:   end
// 261: end
// 262:
// 263: # Shared methods for formula unreadable errors.
// 264: module FormulaUnreadableErrorModule
// 265:   extend T::Helpers
// 266:
// 267:   abstract!
// 268:   requires_ancestor { FormulaOrCaskUnavailableError }
// 269:
// 270:   sig { abstract.returns(Exception) }
// 271:   def formula_error; end
// 272:
// 273:   sig { returns(String) }
// 274:   def to_s
// 275:     "#{name}: " + formula_error.to_s
// 276:   end
// 277: end
// 278:
// 279: # Raised when a formula is unreadable.
// 280: class FormulaUnreadableError < FormulaUnavailableError
// 281:   include FormulaUnreadableErrorModule
// 282:
// 283:   sig { override.returns(Exception) }
// 284:   attr_reader :formula_error
// 285:
// 286:   sig { params(name: String, error: Exception).void }
// 287:   def initialize(name, error)
// 288:     super(name)
// 289:     @formula_error = error
// 290:     set_backtrace(error.backtrace)
// 291:   end
// 292: end
// 293:
// 294: # Raised when a formula in a specific tap is unavailable.
// 295: class TapFormulaUnavailableError < FormulaUnavailableError
// 296:   sig { returns(Tap) }
// 297:   attr_reader :tap
// 298:
// 299:   sig { returns(String) }
// 300:   attr_reader :user
// 301:
// 302:   sig { returns(String) }
// 303:   attr_reader :repository
// 304:
// 305:   sig { params(tap: Tap, name: String).void }
// 306:   def initialize(tap, name)
// 307:     @tap = tap
// 308:     @user = T.let(tap.user, String)
// 309:     @repository = T.let(tap.repository, String)
// 310:     super "#{tap}/#{name}"
// 311:   end
// 312:
// 313:   sig { override.returns(String) }
// 314:   def to_s
// 315:     s = super
// 316:     unless tap.installed?
// 317:       s += "\nThis command requires the tap #{tap}."
// 318:       s += "\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap #{tap}"
// 319:     end
// 320:     s
// 321:   end
// 322: end
// 323:
// 324: # Raised when a formula in a specific tap does not contain a formula class.
// 325: class TapFormulaClassUnavailableError < TapFormulaUnavailableError
// 326:   include FormulaClassUnavailableErrorModule
// 327:
// 328:   sig { override.returns(T.any(Pathname, String)) }
// 329:   attr_reader :path
// 330:
// 331:   sig { override.returns(String) }
// 332:   attr_reader :class_name
// 333:
// 334:   sig { override.returns(T::Array[T::Class[T.anything]]) }
// 335:   attr_reader :class_list
// 336:
// 337:   sig {
// 338:     params(tap: Tap, name: String, path: T.any(Pathname, String),
// 339:            class_name: String, class_list: T::Array[T::Class[T.anything]]).void
// 340:   }
// 341:   def initialize(tap, name, path, class_name, class_list)
// 342:     @path = path
// 343:     @class_name = class_name
// 344:     @class_list = class_list
// 345:     super tap, name
// 346:   end
// 347: end
// 348:
// 349: # Raised when a formula in a specific tap is unreadable.
// 350: class TapFormulaUnreadableError < TapFormulaUnavailableError
// 351:   include FormulaUnreadableErrorModule
// 352:
// 353:   sig { override.returns(Exception) }
// 354:   attr_reader :formula_error
// 355:
// 356:   sig { params(tap: Tap, name: String, error: Exception).void }
// 357:   def initialize(tap, name, error)
// 358:     super(tap, name)
// 359:     @formula_error = error
// 360:     set_backtrace(error.backtrace)
// 361:   end
// 362: end
// 363:
// 364: # Raised when a formula with the same name is found in multiple taps.
// 365: class TapFormulaAmbiguityError < RuntimeError
// 366:   sig { returns(String) }
// 367:   attr_reader :name
// 368:
// 369:   sig { returns(T::Array[Tap]) }
// 370:   attr_reader :taps
// 371:
// 372:   sig { returns(T::Array[Formulary::FormulaLoader]) }
// 373:   attr_reader :loaders
// 374:
// 375:   sig { params(name: String, loaders: T::Array[Formulary::FormulaLoader]).void }
// 376:   def initialize(name, loaders)
// 377:     @name = name
// 378:     @loaders = loaders
// 379:     @taps = T.let(loaders.filter_map(&:tap), T::Array[Tap])
// 380:
// 381:     formulae = taps.map { |tap| "#{tap}/#{name}" }
// 382:     formula_list = formulae.map { |f| "\n       * #{f}" }.join
// 383:
// 384:     super <<~EOS
// 385:       Formulae found in multiple taps:#{formula_list}
// 386:
// 387:       Please use the fully-qualified name (e.g. #{formulae.first}) to refer to a specific formula.
// 388:     EOS
// 389:   end
// 390: end
// 391:
// 392: # Raised when a tap is unavailable.
// 393: class TapUnavailableError < RuntimeError
// 394:   sig { returns(String) }
// 395:   attr_reader :name
// 396:
// 397:   sig { params(name: String).void }
// 398:   def initialize(name)
// 399:     @name = name
// 400:
// 401:     message = "No available tap #{name}.\n"
// 402:     if [CoreTap.instance.name, CoreCaskTap.instance.name].include?(name)
// 403:       command = "brew tap --force #{name}"
// 404:       message += <<~EOS
// 405:         Run #{Formatter.identifier(command)} to tap #{name}!
// 406:       EOS
// 407:     else
// 408:       command = "brew tap-new #{name}"
// 409:       message += <<~EOS
// 410:         Run #{Formatter.identifier(command)} to create a new #{name} tap!
// 411:       EOS
// 412:     end
// 413:     super message.freeze
// 414:   end
// 415: end
// 416:
// 417: # Raised when a tap's remote does not match the actual remote.
// 418: class TapRemoteMismatchError < RuntimeError
// 419:   sig { returns(String) }
// 420:   attr_reader :name
// 421:
// 422:   sig { returns(T.nilable(String)) }
// 423:   attr_reader :expected_remote
// 424:
// 425:   sig { returns(T.any(Pathname, String)) }
// 426:   attr_reader :actual_remote
// 427:
// 428:   sig { params(name: String, expected_remote: T.nilable(String), actual_remote: T.any(Pathname, String)).void }
// 429:   def initialize(name, expected_remote, actual_remote)
// 430:     @name = name
// 431:     @expected_remote = expected_remote
// 432:     @actual_remote = actual_remote
// 433:
// 434:     super message
// 435:   end
// 436:
// 437:   sig { returns(String) }
// 438:   def message
// 439:     <<~EOS
// 440:       Tap #{name} remote mismatch.
// 441:       #{expected_remote} != #{actual_remote}
// 442:     EOS
// 443:   end
// 444: end
// 445:
// 446: # Raised when the remote of homebrew/core does not match HOMEBREW_CORE_GIT_REMOTE.
// 447: class TapCoreRemoteMismatchError < TapRemoteMismatchError
// 448:   sig { override.returns(String) }
// 449:   def message
// 450:     <<~EOS
// 451:       Tap #{name} remote does not match `$HOMEBREW_CORE_GIT_REMOTE`.
// 452:       #{expected_remote} != #{actual_remote}
// 453:       Please set `HOMEBREW_CORE_GIT_REMOTE="#{actual_remote}"` and run `brew update` instead.
// 454:     EOS
// 455:   end
// 456: end
// 457:
// 458: # Raised when a tap is already installed.
// 459: class TapAlreadyTappedError < RuntimeError
// 460:   sig { returns(String) }
// 461:   attr_reader :name
// 462:
// 463:   sig { params(name: String).void }
// 464:   def initialize(name)
// 465:     @name = name
// 466:
// 467:     super <<~EOS
// 468:       Tap #{name} already tapped.
// 469:     EOS
// 470:   end
// 471: end
// 472:
// 473: # Raised when run `brew tap --custom-remote` without a remote URL.
// 474: class TapNoCustomRemoteError < RuntimeError
// 475:   sig { returns(String) }
// 476:   attr_reader :name
// 477:
// 478:   sig { params(name: String).void }
// 479:   def initialize(name)
// 480:     @name = name
// 481:
// 482:     super <<~EOS
// 483:       Tap #{name} with option `--custom-remote` but without a remote URL.
// 484:     EOS
// 485:   end
// 486: end
// 487:
// 488: # Raised when a Git redirect targets a disallowed or forbidden tap remote.
// 489: class TapRedirectNotAllowedError < RuntimeError; end
// 490:
// 491: # Raised when another Homebrew operation is already in progress.
// 492: class OperationInProgressError < RuntimeError
// 493:   sig { params(locked_path: Pathname, waited: T.nilable(Integer)).void }
// 494:   def initialize(locked_path, waited: nil)
// 495:     full_command = Homebrew.running_command_with_args.presence || "brew"
// 496:     lock_context = if (env_lock_context = Homebrew::EnvConfig.lock_context.presence)
// 497:       "\n#{env_lock_context}"
// 498:     end
// 499:     advice = if waited
// 500:       "Gave up after waiting #{waited} seconds. Terminate it to continue."
// 501:     else
// 502:       "Please wait for it to finish or terminate it to continue."
// 503:     end
// 504:     message = <<~EOS
// 505:       A `#{full_command}` process has already locked #{locked_path}.#{lock_context}
// 506:       #{advice}
// 507:     EOS
// 508:
// 509:     super message
// 510:   end
// 511: end
// 512:
// 513: class CannotInstallFormulaError < RuntimeError; end
// 514:
// 515: # Raised when a formula installation was already attempted.
// 516: class FormulaInstallationAlreadyAttemptedError < RuntimeError
// 517:   sig { params(formula: Formula).void }
// 518:   def initialize(formula)
// 519:     super "Formula installation already attempted: #{formula.full_name}"
// 520:   end
// 521: end
// 522:
// 523: # Raised when there are unsatisfied requirements.
// 524: class UnsatisfiedRequirements < RuntimeError
// 525:   sig { params(reqs: T::Array[Requirement]).void }
// 526:   def initialize(reqs)
// 527:     if reqs.length == 1
// 528:       super "An unsatisfied requirement failed this build."
// 529:     else
// 530:       super "Unsatisfied requirements failed this build."
// 531:     end
// 532:   end
// 533: end
// 534:
// 535: # Raised when a formula conflicts with another one.
// 536: class FormulaConflictError < RuntimeError
// 537:   sig { returns(Formula) }
// 538:   attr_reader :formula
// 539:
// 540:   sig { returns(T::Array[Formula::FormulaConflict]) }
// 541:   attr_reader :conflicts
// 542:
// 543:   sig { params(formula: Formula, conflicts: T::Array[Formula::FormulaConflict]).void }
// 544:   def initialize(formula, conflicts)
// 545:     @formula = formula
// 546:     @conflicts = conflicts
// 547:     super message
// 548:   end
// 549:
// 550:   sig { params(conflict: Formula::FormulaConflict).returns(String) }
// 551:   def conflict_message(conflict)
// 552:     message = []
// 553:     message << "  #{conflict.name}"
// 554:     message << ": because #{conflict.reason}" if conflict.reason
// 555:     message.join
// 556:   end
// 557:
// 558:   sig { returns(String) }
// 559:   def message
// 560:     message = []
// 561:     message << "Cannot install #{formula.full_name} because conflicting formulae are installed."
// 562:     message.concat conflicts.map { |c| conflict_message(c) } << ""
// 563:     message << <<~EOS
// 564:       Please `brew unlink #{conflicts.map(&:name) * " "}` before continuing.
// 565:
// 566:       Unlinking removes a formula's symlinks from #{HOMEBREW_PREFIX}. You can
// 567:       link the formula again after the install finishes. You can `--force` this
// 568:       install, but the build may fail or cause obscure side effects in the
// 569:       resulting software.
// 570:     EOS
// 571:     message.join("\n")
// 572:   end
// 573: end
// 574:
// 575: # Raise when the Python version cannot be detected automatically.
// 576: class FormulaUnknownPythonError < RuntimeError
// 577:   sig { params(formula: T.any(Formula, Language::Python::Virtualenv)).void }
// 578:   def initialize(formula)
// 579:     super <<~EOS
// 580:       The version of Python to use with the virtualenv in the `#{formula.full_name}` formula
// 581:       cannot be guessed automatically because a recognised Python dependency could not be found.
// 582:
// 583:       If you are using a non-standard Python dependency, please add `:using => "python@x.y"`
// 584:       to 'virtualenv_install_with_resources' to resolve the issue manually.
// 585:     EOS
// 586:   end
// 587: end
// 588:
// 589: # Raise when two Python versions are detected simultaneously.
// 590: class FormulaAmbiguousPythonError < RuntimeError
// 591:   sig { params(formula: T.any(Formula, Language::Python::Virtualenv)).void }
// 592:   def initialize(formula)
// 593:     super <<~EOS
// 594:       The version of Python to use with the virtualenv in the `#{formula.full_name}` formula
// 595:       cannot be guessed automatically.
// 596:
// 597:       If the simultaneous use of multiple Pythons is intentional, please add `:using => "python@x.y"`
// 598:       to 'virtualenv_install_with_resources' to resolve the ambiguity manually.
// 599:     EOS
// 600:   end
// 601: end
// 602:
// 603: # Raised when an error occurs during a formula build.
// 604: class BuildError < RuntimeError
// 605:   include Utils::Output::Mixin
// 606:
// 607:   sig { returns(T.nilable(T.any(String, Pathname, T::Array[String], T::Hash[String, T.nilable(String)]))) }
// 608:   attr_reader :cmd
// 609:
// 610:   sig { returns(T::Array[T.nilable(T.any(String, Integer, Pathname, Symbol, T::Array[String], T::Hash[String, T.nilable(String)]))]) }
// 611:   attr_reader :args
// 612:
// 613:   sig { returns(T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))]) }
// 614:   attr_reader :env
// 615:
// 616:   sig { returns(T.nilable(Formula)) }
// 617:   attr_accessor :formula
// 618:
// 619:   sig { returns(T.nilable(T::Array[String])) }
// 620:   attr_accessor :options
// 621:
// 622:   sig {
// 623:     params(
// 624:       formula: T.nilable(Formula),
// 625:       cmd:     T.nilable(T.any(String, Pathname, T::Array[String], T::Hash[String, T.nilable(String)])),
// 626:       args:    T::Array[T.nilable(T.any(String, Integer, Pathname, Symbol, T::Array[String],
// 627:                                         T::Hash[String, T.nilable(String)]))],
// 628:       env:     T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 629:     ).void
// 630:   }
// 631:   def initialize(formula, cmd, args, env)
// 632:     @formula = formula
// 633:     @cmd = cmd
// 634:     @args = args
// 635:     @env = env
// 636:     @options = T.let(nil, T.nilable(T::Array[String]))
// 637:     pretty_args = Array(args).map { |arg| arg.to_s.gsub(/[\\ ]/, "\\\\\\0") }.join(" ")
// 638:     super "Failed executing: #{cmd} #{pretty_args}".strip
// 639:   end
// 640:
// 641:   sig { returns(T::Array[T::Hash[String, T.untyped]]) }
// 642:   def issues
// 643:     @issues ||= T.let(fetch_issues, T.nilable(T::Array[T::Hash[String, T.untyped]]))
// 644:   end
// 645:
// 646:   sig { returns(T::Array[T::Hash[String, T.untyped]]) }
// 647:   def fetch_issues
// 648:     return [] if ENV["HOMEBREW_NO_BUILD_ERROR_ISSUES"].present?
// 649:
// 650:     formula = self.formula
// 651:     return [] unless formula
// 652:
// 653:     GitHub.issues_for_formula(formula.name, tap: formula.tap, state: "open", type: "issue")
// 654:   rescue GitHub::API::Error => e
// 655:     opoo "Unable to query GitHub for recent issues on the tap\n#{e.message}"
// 656:     []
// 657:   end
// 658:
// 659:   sig { params(verbose: T::Boolean).void }
// 660:   def dump(verbose: false)
// 661:     puts
// 662:     formula = self.formula
// 663:     return unless formula
// 664:
// 665:     if verbose
// 666:       require "system_config"
// 667:       require "build_environment"
// 668:
// 669:       ohai "Formula"
// 670:       puts "Tap: #{formula.tap}" if formula.tap?
// 671:       puts "Path: #{formula.path}"
// 672:       ohai "Configuration"
// 673:       SystemConfig.dump_verbose_config
// 674:       ohai "ENV"
// 675:       BuildEnvironment.dump env
// 676:       puts
// 677:       onoe "#{formula.full_name} #{formula.version} did not build"
// 678:       unless (logs = Dir["#{formula.logs}/*"]).empty?
// 679:         puts "Logs:"
// 680:         puts logs.map { |fn| "     #{fn}" }.join("\n")
// 681:       end
// 682:     end
// 683:
// 684:     formula_tap = formula.tap
// 685:     if formula_tap
// 686:       if OS.not_tier_one_configuration?
// 687:         <<~EOS
// 688:           This is not a Tier 1 configuration:
// 689:             #{Formatter.url("https://docs.brew.sh/Support-Tiers")}
// 690:           #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 691:           Read the above document instead before opening any issues or PRs.
// 692:         EOS
// 693:       elsif formula_tap.official?
// 694:         if OS.nix_managed_homebrew?
// 695:           puts issue_reporting_message(OS::ISSUES_URL)
// 696:         else
// 697:           puts issue_reporting_message(OS::ISSUES_URL, read_this: true)
// 698:         end
// 699:       elsif (issues_url = formula_tap.issues_url)
// 700:         puts issue_reporting_message(issues_url)
// 701:       else
// 702:         puts <<~EOS
// 703:           If reporting this issue please do so to (not Homebrew/* repositories):
// 704:             #{formula_tap}
// 705:         EOS
// 706:       end
// 707:     else
// 708:       <<~EOS
// 709:         We cannot detect the correct tap to report this issue to.
// 710:         Do not report this issue to Homebrew/* repositories!
// 711:       EOS
// 712:     end
// 713:
// 714:     puts
// 715:
// 716:     if issues.present?
// 717:       puts "These open issues may also help:"
// 718:       puts issues.map { |i| "#{i["title"]} #{i["html_url"]}" }.join("\n")
// 719:     end
// 720:
// 721:     require "diagnostic"
// 722:     checks = Homebrew::Diagnostic::Checks.new
// 723:     checks.build_error_checks.each do |check|
// 724:       out = checks.public_send(check)
// 725:       next if out.nil?
// 726:
// 727:       puts
// 728:       ofail out
// 729:     end
// 730:   end
// 731: end
// 732:
// 733: # Raised if the formula or its dependencies are not bottled and are being
// 734: # installed in a situation where a bottle is required.
// 735: class UnbottledError < RuntimeError
// 736:   sig { params(formulae: T::Array[Formula]).void }
// 737:   def initialize(formulae)
// 738:     require "utils"
// 739:
// 740:     msg = <<~EOS
// 741:       The following #{Utils.pluralize("formula", formulae.count)} cannot be installed from #{Utils.pluralize("bottle", formulae.count)} and must be
// 742:       built from source.
// 743:         #{formulae.to_sentence}
// 744:     EOS
// 745:     msg += "#{DevelopmentTools.installation_instructions}\n" unless DevelopmentTools.installed?
// 746:     msg.freeze
// 747:     super(msg)
// 748:   end
// 749: end
// 750:
// 751: # Raised by `Homebrew.install`, `Homebrew.reinstall` and `Homebrew.upgrade`
// 752: # if the user passes any flags/environment that would case a bottle-only
// 753: # installation on a system without build tools to fail.
// 754: class BuildFlagsError < RuntimeError
// 755:   sig { params(flags: T::Array[String], bottled: T::Boolean).void }
// 756:   def initialize(flags, bottled: true)
// 757:     if flags.length > 1
// 758:       flag_text = "flags"
// 759:       require_text = "require"
// 760:     else
// 761:       flag_text = "flag"
// 762:       require_text = "requires"
// 763:     end
// 764:
// 765:     bottle_text = if bottled
// 766:       <<~EOS
// 767:         Alternatively, remove the #{flag_text} to attempt bottle installation.
// 768:       EOS
// 769:     end
// 770:
// 771:     message = <<~EOS
// 772:       The following #{flag_text}:
// 773:         #{flags.join(", ")}
// 774:       #{require_text} building tools, but none are installed.
// 775:       #{DevelopmentTools.installation_instructions} #{bottle_text}
// 776:     EOS
// 777:
// 778:     super message
// 779:   end
// 780: end
// 781:
// 782: # Raised by {CompilerSelector} if the formula fails with all of
// 783: # the compilers available on the user's system.
// 784: class CompilerSelectionError < RuntimeError
// 785:   sig { params(formula: T.any(Formula, SoftwareSpec)).void }
// 786:   def initialize(formula)
// 787:     super <<~EOS
// 788:       #{formula.full_name} cannot be built with any available compilers.
// 789:       #{DevelopmentTools.custom_installation_instructions}
// 790:     EOS
// 791:   end
// 792: end
// 793:
// 794: # Raised in {Downloadable#fetch}.
// 795: class DownloadError < RuntimeError
// 796:   sig { returns(Exception) }
// 797:   attr_reader :cause
// 798:
// 799:   sig { params(downloadable: Downloadable, cause: Exception).void }
// 800:   def initialize(downloadable, cause)
// 801:     super <<~EOS
// 802:       Failed to download resource #{downloadable.download_queue_name.inspect}
// 803:       #{cause.message}
// 804:     EOS
// 805:     @cause = cause
// 806:     set_backtrace(cause.backtrace)
// 807:   end
// 808: end
// 809:
// 810: # Raised in {CurlDownloadStrategy#fetch}.
// 811: class CurlDownloadStrategyError < RuntimeError
// 812:   sig { params(url: String, details: T.nilable(String)).void }
// 813:   def initialize(url, details = nil)
// 814:     suffix = "\n#{details}" if details.present?
// 815:     case url
// 816:     when %r{^file://(.+)}
// 817:       super "File cannot be read: #{Regexp.last_match(1)}#{suffix}"
// 818:     else
// 819:       super "Download failed: #{url}#{suffix}"
// 820:     end
// 821:   end
// 822: end
// 823:
// 824: # Raised in {HomebrewCurlDownloadStrategy#fetch}.
// 825: class HomebrewCurlDownloadStrategyError < CurlDownloadStrategyError
// 826:   sig { params(url: String).void }
// 827:   def initialize(url)
// 828:     super "Homebrew-installed `curl` is not installed for: #{url}"
// 829:   end
// 830: end
// 831:
// 832: # Raised by {Kernel#safe_system} in `utils.rb`.
// 833: class ErrorDuringExecution < RuntimeError
// 834:   sig { returns(T::Array[T.nilable(T.any(Pathname, String, T::Array[String], T::Hash[String, T.nilable(String)]))]) }
// 835:   attr_reader :cmd
// 836:
// 837:   sig { returns(T.nilable(Integer)) }
// 838:   attr_reader :exitstatus
// 839:
// 840:   sig { returns(T.any(Integer, T::Hash[String, T.untyped], Process::Status)) }
// 841:   attr_reader :status
// 842:
// 843:   sig { returns(T.nilable(Integer)) }
// 844:   attr_reader :termsig
// 845:
// 846:   sig { returns(T.nilable(T::Array[[T.any(String, Symbol), String]])) }
// 847:   attr_reader :output
// 848:
// 849:   sig {
// 850:     params(
// 851:       cmd:     T::Array[T.nilable(T.any(Pathname, String, T::Array[String], T::Hash[String, T.nilable(String)]))],
// 852:       status:  T.any(Integer, T::Hash[String, T.untyped], Process::Status),
// 853:       output:  T.nilable(T::Array[[T.any(String, Symbol), String]]),
// 854:       secrets: T::Array[String],
// 855:     ).void
// 856:   }
// 857:   def initialize(cmd, status:, output: nil, secrets: [])
// 858:     @cmd = cmd
// 859:     @status = status
// 860:     @output = output
// 861:
// 862:     @exitstatus = T.let(
// 863:       case status
// 864:       when Integer
// 865:         status
// 866:       when Hash
// 867:         status["exitstatus"]
// 868:       else
// 869:         status.exitstatus
// 870:       end,
// 871:       T.nilable(Integer),
// 872:     )
// 873:
// 874:     @termsig = T.let(
// 875:       case status
// 876:       when Integer
// 877:         nil
// 878:       when Hash
// 879:         status["termsig"]
// 880:       else
// 881:         status.termsig
// 882:       end,
// 883:       T.nilable(Integer),
// 884:     )
// 885:
// 886:     redacted_cmd = Formatter.redact_secrets(cmd.shelljoin.gsub('\=', "="), secrets)
// 887:
// 888:     reason = if exitstatus
// 889:       "exited with #{exitstatus}"
// 890:     elsif (t = termsig)
// 891:       "was terminated by uncaught signal #{Signal.signame(t)}"
// 892:     else
// 893:       raise ArgumentError, "Status neither has `exitstatus` nor `termsig`."
// 894:     end
// 895:
// 896:     s = "Failure while executing; `#{redacted_cmd}` #{reason}."
// 897:
// 898:     if Array(output).present?
// 899:       format_output_line = lambda do |type_line|
// 900:         type, line = *type_line
// 901:         if type == :stderr
// 902:           Formatter.error(line)
// 903:         else
// 904:           line
// 905:         end
// 906:       end
// 907:
// 908:       s << " Here's the output:\n"
// 909:       s << Array(output).map(&format_output_line).join
// 910:       s << "\n" unless s.end_with?("\n")
// 911:     end
// 912:
// 913:     super s.freeze
// 914:   end
// 915:
// 916:   sig { returns(String) }
// 917:   def stderr
// 918:     Array(output).select { |type,| type == :stderr }.map(&:last).join
// 919:   end
// 920: end
// 921:
// 922: # Raised by {Pathname#verify_checksum} when "expected" is nil or empty.
// 923: class ChecksumMissingError < ArgumentError; end
// 924:
// 925: # Raised by {Pathname#verify_checksum} when verification fails.
// 926: class ChecksumMismatchError < RuntimeError
// 927:   sig { returns(Checksum) }
// 928:   attr_reader :expected
// 929:
// 930:   sig { params(path: T.any(Pathname, String), expected: Checksum, actual: Checksum).void }
// 931:   def initialize(path, expected, actual)
// 932:     @expected = expected
// 933:
// 934:     super <<~EOS
// 935:       SHA-256 mismatch
// 936:       Expected: #{Formatter.success(expected.to_s)}
// 937:         Actual: #{Formatter.error(actual.to_s)}
// 938:           File: #{path}
// 939:       To retry an incomplete download, remove the file above.#{ChecksumMismatchError.html_hint(path)}
// 940:     EOS
// 941:   end
// 942:
// 943:   # Detect downloads that are HTML pages (bot-protection challenges, rate-limit
// 944:   # or error pages served as `text/html`) rather than the expected binary
// 945:   # artifact. Returns an extra hint for the error message, or an empty string.
// 946:   sig { params(path: T.any(Pathname, String)).returns(String) }
// 947:   def self.html_hint(path)
// 948:     return "" unless path.is_a?(Pathname)
// 949:     return "" unless path.file?
// 950:
// 951:     head = path.binread(512).to_s
// 952:     return "" unless head.match?(/\A\s*(?:<!doctype\s+html|<html|<\?xml[^>]*\?>\s*<html)/i)
// 953:
// 954:     rm_command = if path.to_s.start_with?("#{HOMEBREW_CACHE}/")
// 955:       relative = path.relative_path_from(HOMEBREW_CACHE)
// 956:       %Q(rm "$(brew --cache)/#{relative}")
// 957:     else
// 958:       %Q(rm "#{path}")
// 959:     end
// 960:
// 961:     <<~EOS
// 962:
// 963:       The start of the downloaded file is HTML/XML, not a binary.
// 964:       The server may have returned a bot-protection, rate-limit or
// 965:       error page instead. Delete the file and retry:
// 966:         #{rm_command}
// 967:     EOS
// 968:   rescue SystemCallError
// 969:     ""
// 970:   end
// 971: end
// 972:
// 973: # Raised when a resource is missing.
// 974: class ResourceMissingError < ArgumentError
// 975:   sig { params(formula: T.nilable(T.any(Formula, Cask::Cask)), resource: T.any(Resource, String)).void }
// 976:   def initialize(formula, resource)
// 977:     super "#{formula&.full_name} does not define resource #{resource.inspect}"
// 978:   end
// 979: end
// 980:
// 981: # Raised when a resource is specified multiple times.
// 982: class DuplicateResourceError < ArgumentError
// 983:   sig { params(resource: T.any(Resource, String)).void }
// 984:   def initialize(resource)
// 985:     super "Resource #{resource.inspect} is defined more than once"
// 986:   end
// 987: end
// 988:
// 989: # Raised when a single patch file is not found and apply hasn't been specified.
// 990: class MissingApplyError < RuntimeError; end
// 991:
// 992: # Raised when a bottle does not contain a formula file.
// 993: class BottleFormulaUnavailableError < RuntimeError
// 994:   sig { params(bottle_path: T.any(Pathname, String), formula_path: T.any(Pathname, String)).void }
// 995:   def initialize(bottle_path, formula_path)
// 996:     super <<~EOS
// 997:       This bottle does not contain the formula file:
// 998:         #{bottle_path}
// 999:         #{formula_path}
// 1000:     EOS
// 1001:   end
// 1002: end
// 1003:
// 1004: # Raised when a `Utils.safe_fork` exits with a non-zero code.
// 1005: class ChildProcessError < RuntimeError
// 1006:   sig { returns(Process::Status) }
// 1007:   attr_reader :status
// 1008:
// 1009:   sig { params(status: Process::Status).void }
// 1010:   def initialize(status)
// 1011:     @status = status
// 1012:
// 1013:     super "Forked child process failed: #{status}"
// 1014:   end
// 1015: end
// 1016:
// 1017: # Raised when `detected_perl_shebang` etc cannot detect the shebang.
// 1018: class ShebangDetectionError < RuntimeError
// 1019:   sig { params(type: String, reason: String).void }
// 1020:   def initialize(type, reason)
// 1021:     super "Cannot detect #{type} shebang: #{reason}."
// 1022:   end
// 1023: end
// 1024:
// 1025: # Raised when one or more formulae have cyclic dependencies.
// 1026: class CyclicDependencyError < RuntimeError
// 1027:   sig { params(strongly_connected_components: T::Array[T.untyped]).void }
// 1028:   def initialize(strongly_connected_components)
// 1029:     super <<~EOS
// 1030:       The following packages contain cyclic dependencies:
// 1031:         #{strongly_connected_components.select { |packages| packages.count > 1 }.map(&:to_sentence).join("\n  ")}
// 1032:     EOS
// 1033:   end
// 1034: end
// 1035:
// 1036: # rubocop:enable Style/OneClassPerFile
