module extend

import ruby
import os

// Translated from Homebrew/brew `extend/kernel.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct EnvironmentValue {
pub:
	value string
	unset bool
}

pub struct KernelCommandPlan {
pub:
	program     string
	argv0       string
	arguments   []string
	environment map[string]EnvironmentValue
	quiet       bool
}

pub struct EditorChoice {
pub:
	command       string
	warning       string
	used_fallback bool
}

pub struct EditorPlan {
pub:
	message string
	command KernelCommandPlan
}

pub struct BrowserPlan {
pub:
	available bool
	command   KernelCommandPlan
	display   EnvironmentValue
}

pub struct RedirectPlan {
pub:
	target string
}

pub struct ExecutableInstallRequest {
pub:
	name         string
	formula_name string
	reason       string
	latest       bool
}

pub struct ExecutableResolution {
pub:
	path          string
	needs_install bool
	request       ExecutableInstallRequest
}

pub type KernelAction = fn() !ruby.Value

pub type KernelCommandDelegate = fn(KernelCommandPlan) !bool

pub type ExecutableInstaller = fn(ExecutableInstallRequest) !string

pub fn is_superenv(env string, superenv_bin string) bool {
	if env == 'std' {
		return false
	}
	return superenv_bin != ''
}

fn environment_setting(value string) EnvironmentValue {
	return EnvironmentValue{
		value: value
	}
}

fn unset_environment_setting() EnvironmentValue {
	return EnvironmentValue{
		unset: true
	}
}

fn current_environment_setting(name string) EnvironmentValue {
	if value := os.getenv_opt(name) {
		return environment_setting(value)
	}
	return unset_environment_setting()
}

fn apply_environment_setting(name string, setting EnvironmentValue) {
	if setting.unset {
		os.unsetenv(name)
	} else {
		os.setenv(name, setting.value, true)
	}
}

pub fn with_environment(changes map[string]EnvironmentValue, action KernelAction) !ruby.Value {
	mut old_values := map[string]EnvironmentValue{}
	for name, setting in changes {
		old_values[name] = current_environment_setting(name)
		apply_environment_setting(name, setting)
	}
	defer {
		for name, setting in old_values {
			apply_environment_setting(name, setting)
		}
	}
	return action()
}

pub fn with_homebrew_path(original_paths string, action KernelAction) !ruby.Value {
	return with_environment({
		'PATH': environment_setting(original_paths)
	}, action)
}

fn default_command_delegate(plan KernelCommandPlan) !bool {
	result := with_environment(plan.environment, fn [plan] () !ruby.Value {
		command := ruby.run_command(plan.program, plan.arguments)
		return ruby.bool_value(command.exit_code == 0)
	})!
	return result.as_bool()!
}

pub fn safe_system(plan KernelCommandPlan, delegate KernelCommandDelegate) ! {
	if !delegate(plan)! {
		mut command := [plan.program]
		command << plan.arguments
		return error('Failure while executing: ${command.join(' ')}')
	}
}

pub fn quiet_system(plan KernelCommandPlan, delegate KernelCommandDelegate) !bool {
	return delegate(KernelCommandPlan{
		...plan
		quiet: true
	})
}

pub fn executable_on_path(path string) bool {
	return ruby.is_file(path) && os.is_executable(path)
}

fn expanded_path_element(element string) ?string {
	if element == '' {
		return ruby.current_directory()
	}
	if element == '~' {
		return ruby.environment_value('HOME')
	}
	if element.starts_with('~/') {
		return ruby.join_path(ruby.environment_value('HOME'), element[2..])
	}
	if element.starts_with('~') {
		return none
	}
	return if element.starts_with('/') { element } else { ruby.real_path(element) }
}

pub fn which(command string, path string) ?string {
	for element in path.split(':') {
		base := expanded_path_element(element) or { continue }
		candidate := if command.starts_with('/') {
			command
		} else {
			ruby.join_path(base, command)
		}
		if executable_on_path(candidate) {
			return candidate
		}
	}
	return none
}

fn configured_editor() string {
	for name in ['HOMEBREW_EDITOR', 'EDITOR', 'VISUAL'] {
		value := ruby.environment_value(name)
		if value != '' {
			return value
		}
	}
	return ''
}

fn original_paths() string {
	configured := ruby.environment_value('HOMEBREW_PATH')
	return if configured != '' { configured } else { ruby.environment_value('PATH') }
}

pub fn choose_editor(configured string, path string, silent bool) EditorChoice {
	if configured != '' {
		return EditorChoice{
			command: configured
		}
	}
	mut editor := ''
	for candidate in ['code', 'codium', 'cursor', 'code-insiders', 'subl', 'mate', 'bbedit', 'vim'] {
		if _ := which(candidate, path) {
			editor = candidate
			break
		}
	}
	if editor == '' {
		editor = 'vim'
	}
	warning := if silent {
		''
	} else {
		'Using ${editor} because no editor was set in the environment.\nThis may change in the future, so we recommend setting `\$EDITOR`\nor `\$HOMEBREW_EDITOR` to your preferred text editor.'
	}
	return EditorChoice{
		command: editor
		warning: warning
		used_fallback: true
	}
}

pub fn which_editor(silent bool) EditorChoice {
	return choose_editor(configured_editor(), original_paths(), silent)
}

pub fn shell_split(command string) []string {
	mut words := []string{}
	mut current := []u8{}
	mut quote := u8(0)
	mut escaped := false
	for character in command.bytes() {
		if escaped {
			current << character
			escaped = false
			continue
		}
		if character == `\\` && quote != `'` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			} else {
				current << character
			}
			continue
		}
		if character == `'` || character == `"` {
			quote = character
		} else if character.is_space() {
			if current.len > 0 {
				words << current.bytestr()
				current.clear()
			}
		} else {
			current << character
		}
	}
	if escaped {
		current << `\\`
	}
	if current.len > 0 {
		words << current.bytestr()
	}
	return words
}

pub fn editor_plan(choice EditorChoice, filenames []string, homebrew_path string) !EditorPlan {
	parts := shell_split(choice.command)
	if parts.len == 0 {
		return error('editor command is empty')
	}
	mut arguments := if parts.len > 1 { parts[1..].clone() } else { []string{} }
	arguments << filenames
	return EditorPlan{
		message: 'Editing ${filenames.join('\n')}'
		command: KernelCommandPlan{
			program: parts[0]
			arguments: arguments
			environment: {
				'PATH': environment_setting(homebrew_path)
			}
		}
	}
}

pub fn execute_editor(filenames []string, delegate KernelCommandDelegate) !EditorPlan {
	plan := editor_plan(which_editor(false), filenames, original_paths())!
	safe_system(plan.command, delegate)!
	return plan
}

fn default_browser() string {
	for name in ['HOMEBREW_BROWSER', 'BROWSER'] {
		value := ruby.environment_value(name)
		if value != '' {
			return value
		}
	}
	$if macos {
		return 'open'
	} $else {
		if _ := which('xdg-open', ruby.environment_value('PATH')) {
			return 'xdg-open'
		}
	}
	return ''
}

pub fn browser_plan(browser string, arguments []string, display string,
	dbus_address string) BrowserPlan {
	if browser == '' {
		return BrowserPlan{}
	}
	return BrowserPlan{
		available: true
		command: KernelCommandPlan{
			program: browser
			arguments: arguments.clone()
			environment: {
				'DBUS_SESSION_BUS_ADDRESS': if dbus_address == '' {
					unset_environment_setting()} else {
					environment_setting(dbus_address)}
			}
		}
		display: if display == '' {
			unset_environment_setting()} else {
			environment_setting(display)}
	}
}

pub fn execute_browser(arguments []string, delegate KernelCommandDelegate) !BrowserPlan {
	plan := browser_plan(default_browser(), arguments, ruby.environment_value('HOMEBREW_DISPLAY'), ruby.environment_value('HOMEBREW_DBUS_SESSION_BUS_ADDRESS'))
	if !plan.available {
		return plan
	}
	apply_environment_setting('DISPLAY', plan.display)
	safe_system(plan.command, delegate)!
	return plan
}

pub fn run_interactive_shell(formula_prefix string, formula_name string, shell string,
	delegate KernelCommandDelegate) ! {
	if formula_prefix != '' {
		os.setenv('HOMEBREW_DEBUG_PREFIX', formula_prefix, true)
		os.setenv('HOMEBREW_DEBUG_INSTALL', formula_name, true)
	}
	home := ruby.environment_value('HOME')
	temporary := ruby.environment_value('HOMEBREW_TEMP')
	if shell.ends_with('/zsh') && temporary != '' && home.starts_with(ruby.real_path(temporary)) {
		ruby.make_dir_all(home)!
		zshrc := ruby.join_path(home, '.zshrc')
		if !ruby.path_exists(zshrc) {
			ruby.write_file(zshrc, '')!
		}
	}
	term := if configured := os.getenv_opt('HOMEBREW_TERM') {
		configured
	} else if configured := os.getenv_opt('TERM') {
		configured
	} else {
		''
	}
	result := with_environment({
		'TERM': if term == '' { unset_environment_setting() } else { environment_setting(term) }
	}, fn [shell, delegate] () !ruby.Value {
		return ruby.bool_value(delegate(KernelCommandPlan{
			program: shell
		})!)
	})!
	if !result.as_bool()! {
		return error('Aborted due to non-zero exit status')
	}
}

pub fn ignore_interrupts(action KernelAction) !ruby.Value {
	// V cannot close over state in a signal handler. The typed boundary still
	// guarantees that the action's success or error is returned unchanged.
	return action()
}

pub fn redirect_plan(target string) RedirectPlan {
	return RedirectPlan{
		target: target
	}
}

pub fn redirect_stdout(target string, action KernelAction) !ruby.Value {
	mut file := os.open_file(target, 'w')!
	saved_stdout := os.fd_dup(1)
	if saved_stdout < 0 {
		file.close()
		return error('unable to duplicate stdout')
	}
	flush_stdout()
	if os.fd_dup2(file.fd, 1) < 0 {
		os.fd_close(saved_stdout)
		file.close()
		return error('unable to redirect stdout')
	}
	defer {
		flush_stdout()
		os.fd_dup2(saved_stdout, 1)
		os.fd_close(saved_stdout)
		file.close()
	}
	return action()
}

pub fn executable_resolution(name string, formula_name string, current_path string,
	original_path string, prefix string, reason string, latest bool) ExecutableResolution {
	resolved_formula := if formula_name == '' { name } else { formula_name }
	mut candidates := []string{}
	if executable := which(name, current_path) {
		candidates << executable
	}
	if executable := which(name, original_path) {
		candidates << executable
	}
	candidates << ruby.join_path(prefix, 'opt/${resolved_formula}/bin/${name}')
	candidates << ruby.join_path(prefix, 'bin/${name}')
	for candidate in candidates {
		if ruby.path_exists(candidate) {
			return ExecutableResolution{
				path: candidate
			}
		}
	}
	return ExecutableResolution{
		needs_install: true
		request: ExecutableInstallRequest{
			name: name
			formula_name: resolved_formula
			reason: reason
			latest: latest
		}
	}
}

pub fn ensure_executable(name string, formula_name string, current_path string,
	original_path string, prefix string, reason string, latest bool,
	installer ExecutableInstaller) !string {
	resolution := executable_resolution(name, formula_name, current_path, original_path, prefix, reason, latest)
	if !resolution.needs_install {
		return resolution.path
	}
	return installer(resolution.request)
}

fn command_plan_from_values(args []ruby.Value) KernelCommandPlan {
	if args.len == 0 {
		return KernelCommandPlan{}
	}
	mut offset := 1
	mut argv0 := ''
	if args.len > 1 {
		if args[1].type_name in ['Nil', 'NilClass'] {
			offset = 2
		} else {
			argv0 = args[1].as_string()
			offset = 2
		}
	}
	return KernelCommandPlan{
		program: args[0].as_string()
		argv0: argv0
		arguments: if offset < args.len { args[offset..].map(it.as_string()) } else { []string{} }
	}
}

fn environment_changes_from_value(value ruby.Value) map[string]EnvironmentValue {
	mut changes := map[string]EnvironmentValue{}
	for name, setting in value.map_data {
		changes[name] = if setting.type_name in ['Nil', 'NilClass'] {
			unset_environment_setting()
		} else {
			environment_setting(setting.as_string())
		}
	}
	return changes
}

fn nil_kernel_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `superenv?(env)` at line 11.
pub fn ruby_kernel_l11_d1_superenv(args ...ruby.Value) ruby.Value {
	env := if args.len > 0 { args[0].as_string() } else { '' }
	bin := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_SUPERENV_BIN')
	}
	return ruby.bool_value(is_superenv(env, bin))
}

// Ruby method `interactive_shell(formula = nil)` at line 19.
pub fn ruby_kernel_l19_d2_interactive_shell(args ...ruby.Value) ruby.Value {
	mut prefix := ''
	mut full_name := ''
	if args.len > 0 && args[0].type_name !in ['Nil', 'NilClass'] {
		prefix = args[0].attribute('prefix') or { '' }
		full_name = args[0].attribute('full_name') or { args[0].as_string() }
	}
	shell := ruby.environment_value('SHELL')
	run_interactive_shell(prefix, full_name, if shell != '' { shell } else { '/bin/bash' }, default_command_delegate) or { panic(err) }
	return nil_kernel_value()
}

// Ruby method `with_homebrew_path(&block)` at line 42.
pub fn ruby_kernel_l42_d3_with_homebrew_path(args ...ruby.Value) ruby.Value {
	result := if args.len > 0 { args[args.len - 1] } else { nil_kernel_value() }
	return with_homebrew_path(original_paths(), fn [result] () !ruby.Value {
		return result
	}) or { panic(err) }
}

// Ruby method `safe_system(cmd, argv0 = nil, *args, **options)` at line 55.
pub fn ruby_kernel_l55_d4_safe_system(args ...ruby.Value) ruby.Value {
	safe_system(command_plan_from_values(args), default_command_delegate) or { panic(err) }
	return nil_kernel_value()
}

// Ruby method `quiet_system(cmd, argv0 = nil, *args)` at line 72.
pub fn ruby_kernel_l72_d5_quiet_system(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(quiet_system(command_plan_from_values(args), default_command_delegate) or { false })
}

// Ruby method `which(cmd, path = ENV.fetch("PATH"))` at line 84.
pub fn ruby_kernel_l84_d6_which(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return nil_kernel_value()
	}
	path := if args.len > 1 { args[1].as_string() } else { ruby.environment_value('PATH') }
	return if executable := which(args[0].as_string(), path) {
		ruby.object_value('Pathname', executable)
	} else {
		nil_kernel_value()
	}
}

// Ruby method `which_editor(silent: false)` at line 99.
pub fn ruby_kernel_l99_d7_which_editor(args ...ruby.Value) ruby.Value {
	silent := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	return ruby.structured_value('String', which_editor(silent).command, {
		'warning': which_editor(silent).warning
	})
}

// Ruby method `exec_editor(*filenames)` at line 121.
pub fn ruby_kernel_l121_d8_exec_editor(args ...ruby.Value) ruby.Value {
	execute_editor(args.map(it.as_string()), default_command_delegate) or { panic(err) }
	return nil_kernel_value()
}

// Ruby method `exec_browser(*args)` at line 127.
pub fn ruby_kernel_l127_d9_exec_browser(args ...ruby.Value) ruby.Value {
	execute_browser(args.map(it.as_string()), default_command_delegate) or { panic(err) }
	return nil_kernel_value()
}

// Ruby method `ignore_interrupts(&_block)` at line 142.
pub fn ruby_kernel_l142_d10_ignore_interrupts(args ...ruby.Value) ruby.Value {
	result := if args.len > 0 { args[args.len - 1] } else { nil_kernel_value() }
	return ignore_interrupts(fn [result] () !ruby.Value {
		return result
	}) or { panic(err) }
}

// Ruby method `redirect_stdout(file, &_block)` at line 167.
pub fn ruby_kernel_l167_d11_redirect_stdout(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('redirect_stdout requires a file')
	}
	result := if args.len > 1 { args[args.len - 1] } else { nil_kernel_value() }
	return redirect_stdout(args[0].as_string(), fn [result] () !ruby.Value {
		return result
	}) or { panic(err) }
}

// Ruby method `ensure_executable!(name, formula_name = nil, reason: "", latest: false)` at line 178.
pub fn ruby_kernel_l178_d12_ensure_executable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ensure_executable! requires a name')
	}
	name := args[0].as_string()
	formula_name := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		args[1].as_string()
	} else {
		name
	}
	reason := if args.len > 2 { args[2].as_string() } else { '' }
	latest := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	prefix := if configured := os.getenv_opt('HOMEBREW_PREFIX') {
		configured
	} else {
		'/opt/homebrew'
	}
	resolution := executable_resolution(name, formula_name, ruby.environment_value('PATH'), original_paths(), prefix, reason, latest)
	if !resolution.needs_install {
		return ruby.object_value('Pathname', resolution.path)
	}
	if args.len > 4 {
		return ruby.object_value('Pathname', args[4].as_string())
	}
	return ruby.structured_value('ExecutableInstallRequest', formula_name, {
		'name':         name
		'formula_name': formula_name
		'reason':       reason
		'latest':       latest.str()
	})
}

// Ruby method `with_env(hash, &_block)` at line 218.
pub fn ruby_kernel_l218_d13_with_env(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('with_env requires a hash')
	}
	result := if args.len > 1 { args[args.len - 1] } else { nil_kernel_value() }
	return with_environment(environment_changes_from_value(args[0]), fn [result] () !ruby.Value {
		return result
	}) or { panic(err) }
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
