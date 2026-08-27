module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/sandbox.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `allow_write_temp_and_cache` at line 47.
pub fn ruby_sandbox_l47_d1_allow_write_temp_and_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_write_temp_and_cache', ...args)
}

// Ruby method `allow_write_xcode` at line 56.
pub fn ruby_sandbox_l56_d2_allow_write_xcode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_write_xcode', ...args)
}

// Ruby method `available?` at line 66.
pub fn ruby_sandbox_l66_d3_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available?', ...args)
}

// Ruby method `nested_sandbox?` at line 75.
pub fn ruby_sandbox_l75_d4_nested_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nested_sandbox?', ...args)
}

// Ruby method `terminal_ioctl_request` at line 87.
pub fn ruby_sandbox_l87_d5_terminal_ioctl_request(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('terminal_ioctl_request', ...args)
}

// Ruby method `home_write_paths` at line 95.
pub fn ruby_sandbox_l95_d6_home_write_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('home_write_paths', ...args)
}

// Ruby method `sandbox_command(args, tmpdir)` at line 101.
pub fn ruby_sandbox_l101_d7_sandbox_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandbox_command', ...args)
}

// Ruby method `allow_network_for_error_pipe?` at line 110.
pub fn ruby_sandbox_l110_d8_allow_network_for_error_pipe(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_network_for_error_pipe?', ...args)
}

// Ruby method `ensure_child_tty_available` at line 115.
pub fn ruby_sandbox_l115_d9_ensure_child_tty_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_child_tty_available', ...args)
}

// Ruby method `record_sandbox_log` at line 123.
pub fn ruby_sandbox_l123_d10_record_sandbox_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('record_sandbox_log', ...args)
}

// Ruby method `seatbelt_profile` at line 156.
pub fn ruby_sandbox_l156_d11_seatbelt_profile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('seatbelt_profile', ...args)
}

// Ruby method `seatbelt_rule(rule)` at line 161.
pub fn ruby_sandbox_l161_d12_seatbelt_rule(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('seatbelt_rule', ...args)
}

// Ruby method `seatbelt_path_filter(filter)` at line 172.
pub fn ruby_sandbox_l172_d13_seatbelt_path_filter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('seatbelt_path_filter', ...args)
}

// Ruby method `seatbelt_quote(path)` at line 185.
pub fn ruby_sandbox_l185_d14_seatbelt_quote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('seatbelt_quote', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "erb"
// 5: require "fcntl"
// 6: require "fiddle"
// 7:
// 8: module OS
// 9:   module Mac
// 10:     module Sandbox
// 11:       extend T::Helpers
// 12:
// 13:       requires_ancestor { ::Sandbox }
// 14:
// 15:       SANDBOX_EXEC = "/usr/bin/sandbox-exec"
// 16:
// 17:       # This is defined in the macOS SDK but Ruby unfortunately does not expose it.
// 18:       # This value can be found by compiling a C program that prints TIOCSCTTY.
// 19:       TIOCSCTTY = 0x20007461
// 20:
// 21:       SEATBELT_ERB = <<~ERB
// 22:         (version 1)
// 23:         (debug deny) ; log all denied operations to /var/log/system.log
// 24:         <%= rules.join("\n") %>
// 25:         (allow file-write*
// 26:             (literal "/dev/ptmx")
// 27:             (literal "/dev/dtracehelper")
// 28:             (literal "/dev/null")
// 29:             (literal "/dev/random")
// 30:             (literal "/dev/zero")
// 31:             (regex #"^/dev/fd/[0-9]+$")
// 32:             (regex #"^/dev/tty[a-z0-9]*$")
// 33:             )
// 34:         (deny file-write*) ; deny non-allowlist file write operations
// 35:         (deny file-write-setugid) ; deny non-allowlist file write SUID/SGID operations
// 36:         (deny file-write-mode) ; deny non-allowlist file write mode operations
// 37:         (allow process-exec
// 38:             (literal "/bin/ps")
// 39:             (with no-sandbox)
// 40:             ) ; allow certain processes running without sandbox
// 41:         (allow default) ; allow everything else
// 42:       ERB
// 43:
// 44:       private_constant :SANDBOX_EXEC, :TIOCSCTTY, :SEATBELT_ERB
// 45:
// 46:       sig { void }
// 47:       def allow_write_temp_and_cache
// 48:         allow_write_path "/private/tmp"
// 49:         allow_write_path "/private/var/tmp"
// 50:         allow_write path: "^/private/var/folders/[^/]+/[^/]+/[C,T]/", type: :regex
// 51:         super
// 52:       end
// 53:
// 54:       # Xcode projects expect access to certain cache/archive dirs.
// 55:       sig { void }
// 56:       def allow_write_xcode
// 57:         home_write_paths.each { |path| allow_write_path path }
// 58:       end
// 59:
// 60:       module ClassMethods
// 61:         extend T::Helpers
// 62:
// 63:         requires_ancestor { T.class_of(::Sandbox) }
// 64:
// 65:         sig { returns(T::Boolean) }
// 66:         def available?
// 67:           File.executable?(SANDBOX_EXEC)
// 68:         end
// 69:
// 70:         # Nested `sandbox-exec` invocations hang inside an existing macOS sandbox
// 71:         # (e.g. an agent's), so detect that via the libSystem `sandbox_check`
// 72:         # syscall. The shared `avoid_nested_sandboxing?` only calls this once the
// 73:         # `$HOMEBREW_AVOID_NESTED_SANDBOXING` opt-in is set.
// 74:         sig { returns(T::Boolean) }
// 75:         def nested_sandbox?
// 76:           sandbox_check = Fiddle::Function.new(
// 77:             Fiddle.dlopen(nil)["sandbox_check"],
// 78:             [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT],
// 79:             Fiddle::TYPE_INT,
// 80:           )
// 81:           sandbox_check.call(Process.pid, nil, 0) == 1
// 82:         rescue Fiddle::DLError
// 83:           false
// 84:         end
// 85:
// 86:         sig { returns(Integer) }
// 87:         def terminal_ioctl_request
// 88:           TIOCSCTTY
// 89:         end
// 90:       end
// 91:
// 92:       private
// 93:
// 94:       sig { returns(T::Array[String]) }
// 95:       def home_write_paths
// 96:         home = Dir.home(ENV.fetch("USER"))
// 97:         ["#{home}/Library/Developer", "#{home}/Library/Caches/org.swift.swiftpm"]
// 98:       end
// 99:
// 100:       sig { params(args: T::Array[T.any(String, ::Pathname)], tmpdir: String).returns(T::Array[T.any(String, ::Pathname)]) }
// 101:       def sandbox_command(args, tmpdir)
// 102:         seatbelt = File.new(File.join(tmpdir, "homebrew.sb"), "wx")
// 103:         seatbelt.write(seatbelt_profile)
// 104:         seatbelt.close
// 105:
// 106:         [SANDBOX_EXEC, "-f", seatbelt.path, *args]
// 107:       end
// 108:
// 109:       sig { returns(T::Boolean) }
// 110:       def allow_network_for_error_pipe?
// 111:         true
// 112:       end
// 113:
// 114:       sig { void }
// 115:       def ensure_child_tty_available
// 116:         # We're opening and immediately closing so this is safe.
// 117:         # rubocop:disable Style/FileOpen
// 118:         File.open("/dev/tty", Fcntl::O_WRONLY).close # Workaround for https://developer.apple.com/forums/thread/663632
// 119:         # rubocop:enable Style/FileOpen
// 120:       end
// 121:
// 122:       sig { void }
// 123:       def record_sandbox_log
// 124:         sleep 0.1 # wait for a bit to let syslog catch up the latest events.
// 125:         syslog_args = [
// 126:           "-F", "$((Time)(local)) $(Sender)[$(PID)]: $(Message)",
// 127:           "-k", "Time", "ge", T.must(start).to_i.to_s,
// 128:           "-k", "Message", "S", "deny",
// 129:           "-k", "Sender", "kernel",
// 130:           "-o",
// 131:           "-k", "Time", "ge", T.must(start).to_i.to_s,
// 132:           "-k", "Message", "S", "deny",
// 133:           "-k", "Sender", "sandboxd"
// 134:         ]
// 135:         logs = Utils.popen_read("syslog", *syslog_args)
// 136:
// 137:         # These messages are confusing and non-fatal, so don't report them.
// 138:         logs = logs.lines.grep_v(/^.*Python\(\d+\) deny file-write.*pyc$/).join
// 139:
// 140:         return if logs.empty?
// 141:
// 142:         if (logfile_path = logfile)
// 143:           File.open(logfile_path, "w") do |log|
// 144:             log.write logs
// 145:             log.write "\nWe use time to filter sandbox log. Therefore, unrelated logs may be recorded.\n"
// 146:           end
// 147:         end
// 148:
// 149:         return if !failed || !Homebrew::EnvConfig.verbose?
// 150:
// 151:         ohai "Sandbox Log", logs
// 152:         $stdout.flush # without it, brew test-bot would fail to catch the log
// 153:       end
// 154:
// 155:       sig { returns(String) }
// 156:       def seatbelt_profile
// 157:         ERB.new(SEATBELT_ERB).result_with_hash(rules: profile.rules.map { |rule| seatbelt_rule(rule) })
// 158:       end
// 159:
// 160:       sig { params(rule: T.untyped).returns(String) }
// 161:       def seatbelt_rule(rule)
// 162:         s = +"("
// 163:         s << (rule.allow ? "allow" : "deny")
// 164:         s << " #{rule.operation}"
// 165:         s << " (#{seatbelt_path_filter(rule.filter)})" if rule.filter
// 166:         s << " (with #{rule.modifier})" if rule.modifier
// 167:         s << ")"
// 168:         s.freeze
// 169:       end
// 170:
// 171:       sig { params(filter: T.untyped).returns(String) }
// 172:       def seatbelt_path_filter(filter)
// 173:         case filter.type
// 174:         when :regex   then "regex #\"#{filter.path}\""
// 175:         when :subpath then "subpath \"#{seatbelt_quote(filter.path)}\""
// 176:         when :literal then "literal \"#{seatbelt_quote(filter.path)}\""
// 177:         else raise ArgumentError, "Invalid path filter type: #{filter.type}"
// 178:         end
// 179:       end
// 180:
// 181:       # `"` and `\` are the only characters special inside a double-quoted
// 182:       # seatbelt string, so escaping just those two lets any path (spaces,
// 183:       # parentheses, quotes, backslashes, even newlines) be expressed safely.
// 184:       sig { params(path: String).returns(String) }
// 185:       def seatbelt_quote(path)
// 186:         path.gsub(/["\\]/) { |char| "\\#{char}" }
// 187:       end
// 188:     end
// 189:   end
// 190: end
// 191:
// 192: Sandbox.prepend(OS::Mac::Sandbox)
// 193: Sandbox.singleton_class.prepend(OS::Mac::Sandbox::ClassMethods)
