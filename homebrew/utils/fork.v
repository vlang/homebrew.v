module utils

import ruby

// Translated from Homebrew/brew `utils/fork.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn fork_child_error_boundary(child_error &ForkChildError) ruby.Value {
	return ruby.structured_value('Utils::ForkChildError', child_error.message, {
		'fork_child_error_address': u64(voidptr(child_error)).str()
	})
}

fn fork_child_error_from_boundary(value ruby.Value) &ForkChildError {
	address := value.attributes['fork_child_error_address'] or {
		panic('invalid fork child error boundary')
	}
	return unsafe { &ForkChildError(voidptr(address.u64())) }
}

pub fn fork_safe_request_boundary(request &ForkSafeRequest) ruby.Value {
	return ruby.structured_value('Utils::ForkSafeRequest', request.directory, {
		'fork_safe_request_address': u64(voidptr(request)).str()
	})
}

fn fork_safe_request_from_boundary(value ruby.Value) &ForkSafeRequest {
	address := value.attributes['fork_safe_request_address'] or {
		panic('invalid safe fork request boundary')
	}
	return unsafe { &ForkSafeRequest(voidptr(address.u64())) }
}

fn fork_error_pipe_value(pipe ForkErrorPipe) ruby.Value {
	return ruby.map_value({
		'socket_path':         ruby.string_value(pipe.socket_path)
		'descriptor_received': ruby.bool_value(pipe.descriptor_received)
		'close_on_exec':       ruby.bool_value(pipe.close_on_exec)
		'open':                ruby.bool_value(pipe.open)
	})
}

fn fork_error_report_value(report ForkErrorReport) ruby.Value {
	return ruby.map_value({
		'written': ruby.bool_value(report.written)
		'closed':  ruby.bool_value(report.closed)
		'payload': ruby.string_value(report.payload)
	})
}

fn fork_rewritten_error_value(rewritten ForkRewrittenError) ruby.Value {
	mut fields := {
		'json_class': ruby.string_value(rewritten.class_name)
		'backtrace':  ruby.string_array_value(rewritten.backtrace)
	}
	if rewritten.kind == .build_error {
		fields['cmd'] = ruby.string_value(rewritten.command)
		fields['args'] = ruby.string_array_value(rewritten.arguments)
		fields['env'] = fork_string_map_value(rewritten.environment)
	} else if rewritten.kind == .error_during_execution {
		fields['cmd'] = ruby.string_array_value(rewritten.command_arguments)
		fields['status'] = if rewritten.status_is_process {
			fork_status_value(rewritten.status)
		} else {
			ruby.int_value(rewritten.raw_status)
		}
		fields['output'] = fork_output_value(rewritten.output)
	} else if rewritten.kind == .child_process_error {
		fields['status'] = fork_status_value(rewritten.status)
	}
	return ruby.Value{
		type_name: rewritten.class_name
		repr: rewritten.message
		map_data: fields
		attributes: {
			'kind': rewritten.kind.str()
		}
	}
}

fn fork_safe_result_value(result ForkSafeResult) ruby.Value {
	return ruby.map_value({
		'directory':                   ruby.string_value(result.directory)
		'created_temporary_directory': ruby.bool_value(result.created_temporary_directory)
		'socket_path':                 ruby.string_value(result.socket_path)
		'child_error_pipe':            ruby.string_value(result.child_error_pipe)
		'child_environment':           fork_string_map_value(result.child_environment)
		'child_yielded':               ruby.bool_value(result.child_yielded)
		'parent_yielded':              ruby.bool_value(result.parent_yielded)
		'privilege_changed':           ruby.bool_value(result.privilege_changed)
		'write_close_on_exec':         ruby.bool_value(result.write_close_on_exec)
		'descriptor_sent':             ruby.bool_value(result.descriptor_sent)
		'write_closed':                ruby.bool_value(result.write_closed)
		'read_closed':                 ruby.bool_value(result.read_closed)
		'child_reaped':                ruby.bool_value(result.child_reaped)
		'parent_interrupt_caught':     ruby.bool_value(result.parent_interrupt_caught)
		'error_payload':               ruby.string_value(result.error_payload)
	})
}

// Ruby method `self.forked_child_error_pipe` at line 9.
pub fn ruby_fork_l9_d1_self_forked_child_error_pipe(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby.environment_value('HOMEBREW_ERROR_PIPE')
	}
	descriptor_received := args.len < 2 || (args[1].as_bool() or { false })
	return fork_error_pipe_value(forked_child_error_pipe(path, descriptor_received) or {
		return ruby.object_value(if path == '' { 'KeyError' } else { 'IOError' }, err.msg())
	})
}

// Ruby method `self.child_error_hash(error)` at line 16.
pub fn ruby_fork_l16_d2_self_child_error_hash(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'error is required')
	}
	return ruby.map_value(child_error_hash(fork_child_error_from_boundary(args[0])))
}

// Ruby method `self.report_forked_child_error(error_pipe, error)` at line 41.
pub fn ruby_fork_l41_d3_self_report_forked_child_error(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'error pipe and error are required')
	}
	has_error_pipe := args[0].type_name !in ['Nil', 'NilClass']
	return fork_error_report_value(report_forked_child_error(has_error_pipe, fork_child_error_from_boundary(args[1])))
}

// Ruby method `self.rewrite_child_error(child_error)` at line 47.
pub fn ruby_fork_l47_d4_self_rewrite_child_error(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return ruby.object_value('ArgumentError', 'child error hash is required')
	}
	return fork_rewritten_error_value(rewrite_child_error(args[0].map_data))
}

// Ruby method `self.safe_fork(directory: nil, yield_parent: false, &_blk)` at line 82.
pub fn ruby_fork_l82_d5_self_safe_fork(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'safe fork request is required')
	}
	outcome := safe_fork_outcome(fork_safe_request_from_boundary(args[0]))
	if outcome.has_error {
		return fork_rewritten_error_value(outcome.raised)
	}
	return fork_safe_result_value(outcome.result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fcntl"
// 5: require "utils/socket"
// 6:
// 7: module Utils
// 8:   sig { returns(IO) }
// 9:   def self.forked_child_error_pipe
// 10:     UNIXSocketExt.open(ENV.fetch("HOMEBREW_ERROR_PIPE"), &:recv_io).tap do |error_pipe|
// 11:       error_pipe.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
// 12:     end
// 13:   end
// 14:
// 15:   sig { params(error: Exception).returns(T::Hash[String, T.untyped]) }
// 16:   def self.child_error_hash(error)
// 17:     require "json/add/exception"
// 18:
// 19:     error_hash = T.cast(JSON.parse(error.to_json), T::Hash[String, T.untyped])
// 20:     case error
// 21:     when BuildError
// 22:       error_hash["cmd"] = error.cmd
// 23:       error_hash["args"] = error.args
// 24:       error_hash["env"] = error.env
// 25:     when ErrorDuringExecution
// 26:       error_hash["cmd"] = error.cmd
// 27:       error_hash["status"] = if error.status.is_a?(Process::Status)
// 28:         {
// 29:           exitstatus: error.exitstatus,
// 30:           termsig:    error.termsig,
// 31:         }
// 32:       else
// 33:         error.status
// 34:       end
// 35:       error_hash["output"] = error.output
// 36:     end
// 37:     error_hash
// 38:   end
// 39:
// 40:   sig { params(error_pipe: T.nilable(IO), error: Exception).void }
// 41:   def self.report_forked_child_error(error_pipe, error)
// 42:     error_pipe&.puts child_error_hash(error).to_json
// 43:     error_pipe&.close
// 44:   end
// 45:
// 46:   sig { params(child_error: T::Hash[String, T.untyped]).returns(Exception) }
// 47:   def self.rewrite_child_error(child_error)
// 48:     # The error class name comes from the forked child's serialised JSON.
// 49:     # rubocop:disable Sorbet/ConstantsFromStrings
// 50:     inner_class = Object.const_get(child_error["json_class"])
// 51:     # rubocop:enable Sorbet/ConstantsFromStrings
// 52:     error = if child_error["cmd"] && inner_class == ErrorDuringExecution
// 53:       ErrorDuringExecution.new(child_error["cmd"],
// 54:                                status: child_error["status"],
// 55:                                output: child_error["output"])
// 56:     elsif child_error["cmd"] && inner_class == BuildError
// 57:       # We fill `BuildError#formula` and `BuildError#options` in later,
// 58:       # when we rescue this in `FormulaInstaller#build`.
// 59:       BuildError.new(nil, child_error["cmd"], child_error["args"], child_error["env"])
// 60:     elsif inner_class == Interrupt
// 61:       Interrupt.new
// 62:     else
// 63:       # Everything other error in the child just becomes a RuntimeError.
// 64:       RuntimeError.new <<~EOS
// 65:         An exception occurred within a child process:
// 66:           #{inner_class}: #{child_error["m"]}
// 67:       EOS
// 68:     end
// 69:
// 70:     error.set_backtrace child_error["b"]
// 71:
// 72:     error
// 73:   end
// 74:
// 75:   # When using this function, remember to call `exec` as soon as reasonably possible.
// 76:   # This function does not protect against the pitfalls of what you can do pre-exec in a fork.
// 77:   # See `man fork` for more information.
// 78:   sig {
// 79:     params(directory: T.nilable(String), yield_parent: T::Boolean,
// 80:            _blk: T.proc.params(arg0: T.nilable(String)).void).void
// 81:   }
// 82:   def self.safe_fork(directory: nil, yield_parent: false, &_blk)
// 83:     block = proc do |tmpdir|
// 84:       UNIXServerExt.open("#{tmpdir}/socket") do |server|
// 85:         read, write = IO.pipe
// 86:
// 87:         pid = fork do
// 88:           # bootsnap doesn't like these forked processes
// 89:           ENV["HOMEBREW_NO_BOOTSNAP"] = "1"
// 90:           error_pipe = server.path
// 91:           ENV["HOMEBREW_ERROR_PIPE"] = error_pipe
// 92:           server.close
// 93:           read.close
// 94:           write.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
// 95:
// 96:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 97:
// 98:           yield(error_pipe)
// 99:         # This could be any type of exception, so rescue them all.
// 100:         rescue Exception => e # rubocop:disable Lint/RescueException
// 101:           report_forked_child_error(write, e)
// 102:
// 103:           exit!
// 104:         else
// 105:           exit!(true)
// 106:         end
// 107:
// 108:         begin
// 109:           yield(nil) if yield_parent
// 110:
// 111:           begin
// 112:             socket = server.accept_nonblock
// 113:           rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
// 114:             retry unless Process.waitpid(pid, Process::WNOHANG)
// 115:           else
// 116:             socket.send_io(write)
// 117:             socket.close
// 118:           end
// 119:           write.close
// 120:           data = read.read
// 121:           read.close
// 122:           Process.waitpid(pid) unless socket.nil?
// 123:         rescue Interrupt
// 124:           Process.waitpid(pid)
// 125:         end
// 126:
// 127:         # 130 is the exit status for a process interrupted via Ctrl-C.
// 128:         raise Interrupt if $CHILD_STATUS.exitstatus == 130
// 129:         raise Interrupt if $CHILD_STATUS.termsig == Signal.list["INT"]
// 130:
// 131:         if data.present?
// 132:           error_hash = JSON.parse(data.lines.fetch(0))
// 133:           raise rewrite_child_error(error_hash)
// 134:         end
// 135:
// 136:         raise ChildProcessError, $CHILD_STATUS unless $CHILD_STATUS.success?
// 137:       end
// 138:     end
// 139:
// 140:     if directory
// 141:       block.call(directory)
// 142:     else
// 143:       Dir.mktmpdir("homebrew-fork", HOMEBREW_TEMP, &block)
// 144:     end
// 145:   end
// 146: end
