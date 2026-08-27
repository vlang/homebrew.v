module extend

import brew_runtime

// Translated from Homebrew/brew `extend/kernel.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `superenv?(env)` at line 11.
pub fn ruby_kernel_l11_d1_superenv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('superenv?', ...args)
}

// Ruby method `interactive_shell(formula = nil)` at line 19.
pub fn ruby_kernel_l19_d2_interactive_shell(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interactive_shell', ...args)
}

// Ruby method `with_homebrew_path(&block)` at line 42.
pub fn ruby_kernel_l42_d3_with_homebrew_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_homebrew_path', ...args)
}

// Ruby method `safe_system(cmd, argv0 = nil, *args, **options)` at line 55.
pub fn ruby_kernel_l55_d4_safe_system(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('safe_system', ...args)
}

// Ruby method `quiet_system(cmd, argv0 = nil, *args)` at line 72.
pub fn ruby_kernel_l72_d5_quiet_system(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('quiet_system', ...args)
}

// Ruby method `which(cmd, path = ENV.fetch("PATH"))` at line 84.
pub fn ruby_kernel_l84_d6_which(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('which', ...args)
}

// Ruby method `which_editor(silent: false)` at line 99.
pub fn ruby_kernel_l99_d7_which_editor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('which_editor', ...args)
}

// Ruby method `exec_editor(*filenames)` at line 121.
pub fn ruby_kernel_l121_d8_exec_editor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exec_editor', ...args)
}

// Ruby method `exec_browser(*args)` at line 127.
pub fn ruby_kernel_l127_d9_exec_browser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exec_browser', ...args)
}

// Ruby method `ignore_interrupts(&_block)` at line 142.
pub fn ruby_kernel_l142_d10_ignore_interrupts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignore_interrupts', ...args)
}

// Ruby method `redirect_stdout(file, &_block)` at line 167.
pub fn ruby_kernel_l167_d11_redirect_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('redirect_stdout', ...args)
}

// Ruby method `ensure_executable!(name, formula_name = nil, reason: "", latest: false)` at line 178.
pub fn ruby_kernel_l178_d12_ensure_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_executable!', ...args)
}

// Ruby method `with_env(hash, &_block)` at line 218.
pub fn ruby_kernel_l218_d13_with_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_env', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Homebrew extends Ruby's `Kernel` to make our code more readable.
// 7: # Extending Kernel makes these methods available globally.
// 8: # TODO: move all of these to other modules e.g. Utils.
// 9: module Kernel
// 10:   sig { params(env: T.nilable(String)).returns(T::Boolean) }
// 11:   def superenv?(env)
// 12:     return false if env == "std"
// 13:
// 14:     !Superenv.bin.nil?
// 15:   end
// 16:   private :superenv?
// 17:
// 18:   sig { params(formula: T.nilable(Formula)).void }
// 19:   def interactive_shell(formula = nil)
// 20:     unless formula.nil?
// 21:       ENV["HOMEBREW_DEBUG_PREFIX"] = formula.prefix.to_s
// 22:       ENV["HOMEBREW_DEBUG_INSTALL"] = formula.full_name
// 23:     end
// 24:
// 25:     if Utils::Shell.preferred == :zsh && (home = Dir.home).start_with?(HOMEBREW_TEMP.resolved_path.to_s)
// 26:       FileUtils.mkdir_p home
// 27:       FileUtils.touch "#{home}/.zshrc"
// 28:     end
// 29:
// 30:     term = ENV.fetch("HOMEBREW_TERM", ENV.fetch("TERM", nil))
// 31:     with_env(TERM: term) do
// 32:       Process.wait fork { exec Utils::Shell.preferred_path(default: "/bin/bash") }
// 33:     end
// 34:
// 35:     return if $CHILD_STATUS.success?
// 36:     raise "Aborted due to non-zero exit status (#{$CHILD_STATUS.exitstatus})" if $CHILD_STATUS.exited?
// 37:
// 38:     raise $CHILD_STATUS.inspect
// 39:   end
// 40:
// 41:   sig { type_parameters(:U).params(block: T.proc.returns(T.type_parameter(:U))).returns(T.type_parameter(:U)) }
// 42:   def with_homebrew_path(&block)
// 43:     with_env(PATH: PATH.new(ORIGINAL_PATHS).to_s, &block)
// 44:   end
// 45:
// 46:   # Kernel.system but with exceptions.
// 47:   sig {
// 48:     params(
// 49:       cmd:     T.nilable(T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)])),
// 50:       argv0:   T.nilable(T.any(Pathname, String, [String, String])),
// 51:       args:    T.nilable(T.any(Pathname, String)),
// 52:       options: T.untyped,
// 53:     ).void
// 54:   }
// 55:   def safe_system(cmd, argv0 = nil, *args, **options)
// 56:     # odeprecated: remove this method in a later release, use `Homebrew.safe_system` directly instead
// 57:     require "homebrew"
// 58:
// 59:     Homebrew.safe_system(cmd, argv0, *args, **options)
// 60:   end
// 61:
// 62:   # Run a system command without any output.
// 63:   #
// 64:   # @api internal
// 65:   sig {
// 66:     params(
// 67:       cmd:   T.nilable(T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)])),
// 68:       argv0: T.nilable(T.any(String, [String, String])),
// 69:       args:  T.any(Pathname, String),
// 70:     ).returns(T::Boolean)
// 71:   }
// 72:   def quiet_system(cmd, argv0 = nil, *args)
// 73:     # odeprecated: remove this method in a later release, use `Homebrew.quiet_system` directly instead
// 74:     require "homebrew"
// 75:
// 76:     Homebrew.quiet_system(cmd, argv0, *args)
// 77:   end
// 78:
// 79:   # Find a command.
// 80:   #
// 81:   # @api public
// 82:   # Keep in sync with `which` in Library/Homebrew/utils.sh.
// 83:   sig { params(cmd: String, path: PATH::Elements).returns(T.nilable(Pathname)) }
// 84:   def which(cmd, path = ENV.fetch("PATH"))
// 85:     PATH.new(path).each do |p|
// 86:       begin
// 87:         pcmd = File.expand_path(cmd, p)
// 88:       rescue ArgumentError
// 89:         # File.expand_path will raise an ArgumentError if the path is malformed.
// 90:         # See https://github.com/Homebrew/legacy-homebrew/issues/32789
// 91:         next
// 92:       end
// 93:       return Pathname.new(pcmd) if File.file?(pcmd) && File.executable?(pcmd)
// 94:     end
// 95:     nil
// 96:   end
// 97:
// 98:   sig { params(silent: T::Boolean).returns(String) }
// 99:   def which_editor(silent: false)
// 100:     editor = Homebrew::EnvConfig.editor
// 101:     return editor if editor
// 102:
// 103:     # Find VS Code variants, Sublime Text, Textmate, BBEdit, or vim
// 104:     editor = %w[code codium cursor code-insiders subl mate bbedit vim].find do |candidate|
// 105:       candidate if which(candidate, ORIGINAL_PATHS)
// 106:     end
// 107:     editor ||= "vim"
// 108:
// 109:     unless silent
// 110:       Utils::Output.opoo <<~EOS
// 111:         Using #{editor} because no editor was set in the environment.
// 112:         This may change in the future, so we recommend setting `$EDITOR`
// 113:         or `$HOMEBREW_EDITOR` to your preferred text editor.
// 114:       EOS
// 115:     end
// 116:
// 117:     editor
// 118:   end
// 119:
// 120:   sig { params(filenames: T.any(String, Pathname)).void }
// 121:   def exec_editor(*filenames)
// 122:     puts "Editing #{filenames.join "\n"}"
// 123:     with_homebrew_path { safe_system(*which_editor.shellsplit, *filenames) }
// 124:   end
// 125:
// 126:   sig { params(args: T.any(String, Pathname)).void }
// 127:   def exec_browser(*args)
// 128:     browser = Homebrew::EnvConfig.browser
// 129:     browser ||= OS::PATH_OPEN if defined?(OS::PATH_OPEN)
// 130:     return unless browser
// 131:
// 132:     ENV["DISPLAY"] = Homebrew::EnvConfig.display
// 133:
// 134:     with_env(DBUS_SESSION_BUS_ADDRESS: ENV.fetch("HOMEBREW_DBUS_SESSION_BUS_ADDRESS", nil)) do
// 135:       safe_system(browser, *args)
// 136:     end
// 137:   end
// 138:
// 139:   IGNORE_INTERRUPTS_MUTEX = Thread::Mutex.new.freeze
// 140:
// 141:   sig { type_parameters(:U).params(_block: T.proc.returns(T.type_parameter(:U))).returns(T.type_parameter(:U)) }
// 142:   def ignore_interrupts(&_block)
// 143:     IGNORE_INTERRUPTS_MUTEX.synchronize do
// 144:       interrupted = T.let(false, T::Boolean)
// 145:       old_sigint_handler = trap(:INT) do
// 146:         interrupted = true
// 147:
// 148:         $stderr.print "\n"
// 149:         $stderr.puts "One sec, cleaning up..."
// 150:       end
// 151:
// 152:       begin
// 153:         yield
// 154:       ensure
// 155:         trap(:INT, old_sigint_handler)
// 156:
// 157:         raise Interrupt if interrupted
// 158:       end
// 159:     end
// 160:   end
// 161:
// 162:   sig {
// 163:     type_parameters(:U)
// 164:       .params(file: T.any(IO, Pathname, String), _block: T.proc.returns(T.type_parameter(:U)))
// 165:       .returns(T.type_parameter(:U))
// 166:   }
// 167:   def redirect_stdout(file, &_block)
// 168:     out = $stdout.dup
// 169:     $stdout.reopen(file)
// 170:     yield
// 171:   ensure
// 172:     $stdout.reopen(out)
// 173:     out.close
// 174:   end
// 175:
// 176:   # Ensure the given executable exists otherwise install the brewed version
// 177:   sig { params(name: String, formula_name: T.nilable(String), reason: String, latest: T::Boolean).returns(Pathname) }
// 178:   def ensure_executable!(name, formula_name = nil, reason: "", latest: false)
// 179:     formula_name ||= name
// 180:
// 181:     executable = [
// 182:       which(name),
// 183:       which(name, ORIGINAL_PATHS),
// 184:       # We prefer the opt_bin path to a formula's executable over the prefix
// 185:       # path where available, since the former is stable during upgrades.
// 186:       HOMEBREW_PREFIX/"opt/#{formula_name}/bin/#{name}",
// 187:       HOMEBREW_PREFIX/"bin/#{name}",
// 188:     ].compact.find(&:exist?)
// 189:     return executable if executable
// 190:
// 191:     require "formula"
// 192:     T.cast(Formula[formula_name].ensure_installed!(reason:, latest:, executable: name), Pathname)
// 193:   end
// 194:
// 195:   # Calls the given block with the passed environment variables
// 196:   # added to `ENV`, then restores `ENV` afterwards.
// 197:   #
// 198:   # NOTE: This method is **not** thread-safe – other threads
// 199:   #       which happen to be scheduled during the block will also
// 200:   #       see these environment variables.
// 201:   #
// 202:   # ### Example
// 203:   #
// 204:   # ```ruby
// 205:   # with_env(PATH: "/bin") do
// 206:   #   system "echo $PATH"
// 207:   # end
// 208:   # ```
// 209:   #
// 210:   # @api public
// 211:   sig {
// 212:     type_parameters(:U)
// 213:       .params(
// 214:         hash:   T::Hash[Object, T.nilable(T.any(PATH, Pathname, String))],
// 215:         _block: T.proc.returns(T.type_parameter(:U)),
// 216:       ).returns(T.type_parameter(:U))
// 217:   }
// 218:   def with_env(hash, &_block)
// 219:     old_values = {}
// 220:     begin
// 221:       hash.each do |key, value|
// 222:         key = key.to_s
// 223:         old_values[key] = ENV.delete(key)
// 224:         ENV[key] = value&.to_s
// 225:       end
// 226:
// 227:       yield
// 228:     ensure
// 229:       ENV.update(old_values)
// 230:     end
// 231:   end
// 232: end
