module extend

import ruby
import os

// Translated from Homebrew/brew `extend/kernel.rb`.
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

pub type KernelAction = fn () !ruby.Value

pub type KernelCommandDelegate = fn (KernelCommandPlan) !bool

pub type ExecutableInstaller = fn (ExecutableInstallRequest) !string

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
					unset_environment_setting()
				} else {
					environment_setting(dbus_address)
				}
			}
		}
		display: if display == '' {
			unset_environment_setting()
		} else {
			environment_setting(display)
		}
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
