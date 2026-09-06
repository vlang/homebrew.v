module utils

import ruby

// Translated from Homebrew/brew `utils/fork.rb`.

pub enum ForkChildErrorKind {
	build_error
	error_during_execution
	interrupt
	runtime_error
}

pub struct ForkProcessStatus {
pub:
	has_exitstatus bool
	exitstatus     int
	has_termsig    bool
	termsig        int
}

pub struct ForkOutputLine {
pub:
	stream string
	text   string
}

@[heap]
pub struct ForkChildError {
pub:
	kind              ForkChildErrorKind
	class_name        string
	message           string
	backtrace         []string
	command           string
	command_arguments []string
	arguments         []string
	environment       map[string]string
	status            ForkProcessStatus
	status_is_process bool
	raw_status        int
	output            []ForkOutputLine
}

pub enum ForkRewrittenErrorKind {
	build_error
	error_during_execution
	interrupt
	runtime_error
	child_process_error
}

pub struct ForkRewrittenError {
pub:
	kind              ForkRewrittenErrorKind
	class_name        string
	message           string
	backtrace         []string
	command           string
	command_arguments []string
	arguments         []string
	environment       map[string]string
	status            ForkProcessStatus
	status_is_process bool
	raw_status        int
	output            []ForkOutputLine
}

pub struct ForkErrorPipe {
pub:
	socket_path         string
	descriptor_received bool
	close_on_exec       bool
	open                bool
}

pub struct ForkErrorReport {
pub:
	written bool
	closed  bool
	payload string
}

@[heap]
pub struct ForkSafeRequest {
pub:
	directory                 string
	temporary_directory       string
	yield_parent              bool
	child_requests_error_pipe bool
	has_child_error           bool
	child_error               ForkChildError
	has_exitstatus            bool
	exitstatus                int
	has_termsig               bool
	termsig                   int
	uid                       int
	effective_uid             int
	parent_interrupted        bool
}

pub struct ForkSafeResult {
pub:
	directory                   string
	created_temporary_directory bool
	socket_path                 string
	child_error_pipe            string
	child_environment           map[string]string
	child_yielded               bool
	parent_yielded              bool
	privilege_changed           bool
	write_close_on_exec         bool
	descriptor_sent             bool
	write_closed                bool
	read_closed                 bool
	child_reaped                bool
	parent_interrupt_caught     bool
	error_payload               string
}

pub struct ForkSafeOutcome {
pub:
	result    ForkSafeResult
	has_error bool
	raised    ForkRewrittenError
}

pub struct ForkRaisedError {
pub:
	rewritten ForkRewrittenError
}

pub fn (raised ForkRaisedError) msg() string {
	return raised.rewritten.message
}

pub fn (raised ForkRaisedError) code() int {
	return match raised.rewritten.kind {
		.interrupt { 130 }
		.child_process_error { 71 }
		else { 1 }
	}
}

fn fork_child_error_class(child_error &ForkChildError) string {
	if child_error.class_name != '' {
		return child_error.class_name
	}
	return match child_error.kind {
		.build_error { 'BuildError' }
		.error_during_execution { 'ErrorDuringExecution' }
		.interrupt { 'Interrupt' }
		.runtime_error { 'RuntimeError' }
	}
}

fn fork_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn fork_string_map_value(values map[string]string) ruby.Value {
	mut converted := map[string]ruby.Value{}
	for key, value in values {
		converted[key] = ruby.string_value(value)
	}
	return ruby.map_value(converted)
}

fn fork_string_map_from_value(value ruby.Value) map[string]string {
	mut converted := map[string]string{}
	for key, entry in value.map_data {
		converted[key] = entry.as_string()
	}
	return converted
}

fn fork_string_array_from_value(value ruby.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return (value.as_array() or { []ruby.Value{} }).map(it.as_string())
}

fn fork_status_value(status ForkProcessStatus) ruby.Value {
	return ruby.map_value({
		'exitstatus': if status.has_exitstatus {
			ruby.int_value(status.exitstatus)
		} else {
			fork_nil_value()
		}
		'termsig':    if status.has_termsig {
			ruby.int_value(status.termsig)
		} else {
			fork_nil_value()
		}
	})
}

fn fork_status_from_value(value ruby.Value) (ForkProcessStatus, bool, int) {
	if value.type_name != 'Hash' {
		return ForkProcessStatus{}, false, int(value.int_data)
	}
	exitstatus := value.map_data['exitstatus'] or { fork_nil_value() }
	termsig := value.map_data['termsig'] or { fork_nil_value() }
	return ForkProcessStatus{
		has_exitstatus: exitstatus.type_name != 'NilClass'
		exitstatus: int(exitstatus.int_data)
		has_termsig: termsig.type_name != 'NilClass'
		termsig: int(termsig.int_data)
	}, true, 0
}

fn fork_output_value(output []ForkOutputLine) ruby.Value {
	return ruby.array_value(output.map(ruby.array_value([
		ruby.string_value(it.stream),
		ruby.string_value(it.text),
	])))
}

fn fork_output_from_value(value ruby.Value) []ForkOutputLine {
	mut output := []ForkOutputLine{}
	for entry in value.as_array() or { []ruby.Value{} } {
		parts := entry.as_array() or { continue }
		if parts.len >= 2 {
			output << ForkOutputLine{
				stream: parts[0].as_string()
				text: parts[1].as_string()
			}
		}
	}
	return output
}

pub fn forked_child_error_pipe(error_pipe_path string, descriptor_received bool) !ForkErrorPipe {
	if error_pipe_path == '' {
		return error('key not found: HOMEBREW_ERROR_PIPE')
	}
	if !descriptor_received {
		return error('no file descriptor received from ${error_pipe_path}')
	}
	return ForkErrorPipe{
		socket_path: error_pipe_path
		descriptor_received: true
		close_on_exec: true
		open: true
	}
}

pub fn child_error_hash(child_error &ForkChildError) map[string]ruby.Value {
	mut error_hash := {
		'json_class': ruby.string_value(fork_child_error_class(child_error))
		'm':          ruby.string_value(child_error.message)
		'b':          ruby.string_array_value(child_error.backtrace)
	}
	match child_error.kind {
		.build_error {
			error_hash['cmd'] = ruby.string_value(child_error.command)
			error_hash['args'] = ruby.string_array_value(child_error.arguments)
			error_hash['env'] = fork_string_map_value(child_error.environment)
		}
		.error_during_execution {
			error_hash['cmd'] = ruby.string_array_value(child_error.command_arguments)
			error_hash['status'] = if child_error.status_is_process {
				fork_status_value(child_error.status)
			} else {
				ruby.int_value(child_error.raw_status)
			}
			error_hash['output'] = fork_output_value(child_error.output)
		}
		else {}
	}
	return error_hash
}

pub fn report_forked_child_error(has_error_pipe bool, child_error &ForkChildError) ForkErrorReport {
	if !has_error_pipe {
		return ForkErrorReport{}
	}
	payload := ruby.json_value_to_string(ruby.map_value(child_error_hash(child_error))) + '\n'
	return ForkErrorReport{
		written: true
		closed: true
		payload: payload
	}
}

pub fn rewrite_child_error(child_error map[string]ruby.Value) ForkRewrittenError {
	class_name := (child_error['json_class'] or { ruby.string_value('NameError') }).as_string()
	message := (child_error['m'] or { ruby.string_value('') }).as_string()
	backtrace := fork_string_array_from_value(child_error['b'] or {
		ruby.string_array_value([]string{})
	})
	if cmd := child_error['cmd'] {
		if class_name == 'ErrorDuringExecution' {
			status, status_is_process, raw_status := fork_status_from_value(child_error['status'] or {
				ruby.int_value(0)
			})
			return ForkRewrittenError{
				kind: .error_during_execution
				class_name: class_name
				message: message
				backtrace: backtrace
				command_arguments: fork_string_array_from_value(cmd)
				status: status
				status_is_process: status_is_process
				raw_status: raw_status
				output: fork_output_from_value(child_error['output'] or {
					ruby.array_value([]ruby.Value{})
				})
			}
		}
		if class_name == 'BuildError' {
			return ForkRewrittenError{
				kind: .build_error
				class_name: class_name
				message: message
				backtrace: backtrace
				command: cmd.as_string()
				arguments: fork_string_array_from_value(child_error['args'] or {
					ruby.string_array_value([]string{})
				})
				environment: fork_string_map_from_value(child_error['env'] or {
					ruby.map_value(map[string]ruby.Value{})
				})
			}
		}
	}
	if class_name == 'Interrupt' {
		return ForkRewrittenError{
			kind: .interrupt
			class_name: class_name
			message: 'Interrupt'
			backtrace: backtrace
		}
	}
	return ForkRewrittenError{
		kind: .runtime_error
		class_name: 'RuntimeError'
		message: 'An exception occurred within a child process:\n  ${class_name}: ${message}\n'
		backtrace: backtrace
	}
}

fn fork_interrupt_error() ForkRewrittenError {
	return ForkRewrittenError{
		kind: .interrupt
		class_name: 'Interrupt'
		message: 'Interrupt'
	}
}

fn fork_child_process_error(request &ForkSafeRequest) ForkRewrittenError {
	status := if request.has_exitstatus {
		'exit ${request.exitstatus}'
	} else if request.has_termsig {
		'signal ${request.termsig}'
	} else {
		'unknown status'
	}
	return ForkRewrittenError{
		kind: .child_process_error
		class_name: 'ChildProcessError'
		message: 'Forked child process failed: ${status}'
		status: ForkProcessStatus{
			has_exitstatus: request.has_exitstatus
			exitstatus: request.exitstatus
			has_termsig: request.has_termsig
			termsig: request.termsig
		}
		status_is_process: true
	}
}

pub fn safe_fork_outcome(request &ForkSafeRequest) ForkSafeOutcome {
	directory := if request.directory != '' {
		request.directory
	} else if request.temporary_directory != '' {
		request.temporary_directory
	} else {
		'/tmp/homebrew-fork'
	}
	socket_path := '${directory}/socket'
	mut payload := ''
	if request.has_child_error {
		payload = report_forked_child_error(true, &request.child_error).payload
	}
	result := ForkSafeResult{
		directory: directory
		created_temporary_directory: request.directory == ''
		socket_path: socket_path
		child_error_pipe: socket_path
		child_environment: {
			'HOMEBREW_NO_BOOTSNAP': '1'
			'HOMEBREW_ERROR_PIPE':  socket_path
		}
		child_yielded: true
		parent_yielded: request.yield_parent
		privilege_changed: request.effective_uid != request.uid
		write_close_on_exec: true
		descriptor_sent: request.child_requests_error_pipe
		write_closed: true
		read_closed: true
		child_reaped: true
		parent_interrupt_caught: request.parent_interrupted
		error_payload: payload
	}
	if (request.has_exitstatus && request.exitstatus == 130)
		|| (request.has_termsig && request.termsig == 2) {
		return ForkSafeOutcome{
			result: result
			has_error: true
			raised: fork_interrupt_error()
		}
	}
	if payload != '' {
		first_line := payload.split_into_lines()[0]
		parsed := ruby.parse_json_value(first_line) or {
			return ForkSafeOutcome{
				result: result
				has_error: true
				raised: ForkRewrittenError{
					kind: .runtime_error
					class_name: 'RuntimeError'
					message: err.msg()
				}
			}
		}
		return ForkSafeOutcome{
			result: result
			has_error: true
			raised: rewrite_child_error(parsed.as_map() or { map[string]ruby.Value{} })
		}
	}
	success := (!request.has_exitstatus && !request.has_termsig)
		|| (request.has_exitstatus && request.exitstatus == 0 && !request.has_termsig)
	if !success {
		return ForkSafeOutcome{
			result: result
			has_error: true
			raised: fork_child_process_error(request)
		}
	}
	return ForkSafeOutcome{
		result: result
	}
}

pub fn safe_fork(request &ForkSafeRequest) !ForkSafeResult {
	outcome := safe_fork_outcome(request)
	if outcome.has_error {
		return ForkRaisedError{
			rewritten: outcome.raised
		}
	}
	return outcome.result
}
