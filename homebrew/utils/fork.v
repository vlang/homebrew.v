module utils

import brew_runtime

// Translated from Homebrew/brew `utils/fork.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.forked_child_error_pipe` at line 9.
pub fn ruby_fork_l9_d1_self_forked_child_error_pipe(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.forked_child_error_pipe', ...args)
}

// Ruby method `self.child_error_hash(error)` at line 16.
pub fn ruby_fork_l16_d2_self_child_error_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.child_error_hash', ...args)
}

// Ruby method `self.report_forked_child_error(error_pipe, error)` at line 41.
pub fn ruby_fork_l41_d3_self_report_forked_child_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.report_forked_child_error', ...args)
}

// Ruby method `self.rewrite_child_error(child_error)` at line 47.
pub fn ruby_fork_l47_d4_self_rewrite_child_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.rewrite_child_error', ...args)
}

// Ruby method `self.safe_fork(directory: nil, yield_parent: false, &_blk)` at line 82.
pub fn ruby_fork_l82_d5_self_safe_fork(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.safe_fork', ...args)
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
