module services

import ruby
import os

#include <pwd.h>

struct C.passwd {}

fn C.getpwnam(name &char) &C.passwd

// Translated from Homebrew/brew `services/system.rb`.
pub const launchctl_domain_action_not_supported = 125

pub struct ServiceSystemConfig {
pub:
	path_environment     string
	home                 string
	user                 string
	launchctl_path       string
	launchctl_overridden bool
	systemctl_path       string
	systemctl_overridden bool
	root                 bool
	root_overridden      bool
	uid                  int = -1
	euid                 int = -1
	ssh_tty              string
	sudo_user            string
	no_domain_warning    bool
	no_env_hints         bool
	console_uid          int = -1
}

@[heap]
pub struct ServiceSystem {
pub:
	path_environment  string
	home              string
	configured_user   string
	root_overridden   bool
	configured_root   bool
	uid               int
	euid              int
	ssh_tty           string
	sudo_user         string
	no_domain_warning bool
	no_env_hints      bool
	console_uid       int
pub mut:
	launchctl_path     string
	launchctl_resolved bool
	systemctl_path     string
	systemctl_resolved bool
	user_name          string
	user_resolved      bool
	output_warning     bool
	warnings           []string
}

pub enum LaunchctlCommandType {
	launchctl_print
	launchctl_list
}

pub struct LaunchctlRunResult {
pub:
	output  string
	success bool
}

pub struct LaunchctlFindResult {
pub:
	output       string
	success      bool
	command_type LaunchctlCommandType
}

pub type LaunchctlRunner = fn ([]string, bool) LaunchctlRunResult

pub fn new_service_system(config ServiceSystemConfig) &ServiceSystem {
	path_environment := if config.path_environment != '' {
		config.path_environment
	} else {
		os.getenv('PATH')
	}
	home := if config.home != '' {
		config.home
	} else if os.getenv('HOME') != '' {
		os.getenv('HOME')
	} else {
		os.home_dir()
	}
	uid := if config.uid >= 0 { config.uid } else { os.getuid() }
	euid := if config.euid >= 0 { config.euid } else { os.geteuid() }
	mut console_uid := config.console_uid
	if console_uid < 0 && os.exists('/dev/console') {
		if stat := os.stat('/dev/console') {
			console_uid = int(stat.uid)
		}
	}
	return &ServiceSystem{
		path_environment: path_environment
		home: home
		configured_user: config.user
		root_overridden: config.root_overridden
		configured_root: config.root
		uid: uid
		euid: euid
		ssh_tty: config.ssh_tty
		sudo_user: config.sudo_user
		no_domain_warning: config.no_domain_warning
		no_env_hints: config.no_env_hints
		console_uid: console_uid
		launchctl_path: config.launchctl_path
		launchctl_resolved: config.launchctl_overridden
		systemctl_path: config.systemctl_path
		systemctl_resolved: config.systemctl_overridden
	}
}

fn executable_in_path(name string, path_environment string) ?string {
	for directory in path_environment.split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		candidate := os.join_path(directory, name)
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
	}
	return none
}

pub fn (mut system ServiceSystem) launchctl() ?string {
	if !system.launchctl_resolved {
		system.launchctl_path = executable_in_path('launchctl', system.path_environment) or { '' }
		system.launchctl_resolved = true
	}
	return if system.launchctl_path == '' { none } else { system.launchctl_path }
}

pub fn (mut system ServiceSystem) set_launchctl(path ?string) ?string {
	system.launchctl_path = path or { '' }
	system.launchctl_resolved = true
	return path
}

pub fn (mut system ServiceSystem) launchctl_available() bool {
	return system.launchctl() != none
}

pub fn (mut system ServiceSystem) systemctl_available() bool {
	if !system.systemctl_resolved {
		system.systemctl_path = executable_in_path('systemctl', system.path_environment) or { '' }
		system.systemctl_resolved = true
	}
	return system.systemctl_path != ''
}

pub fn (system ServiceSystem) root() bool {
	return if system.root_overridden { system.configured_root } else { system.euid == 0 }
}

pub fn (mut system ServiceSystem) user() string {
	if !system.user_resolved {
		system.user_name = system.configured_user
		if system.user_name == '' {
			system.user_name = os.getenv('USER')
		}
		if system.user_name == '' {
			result := ruby.run_captured_command(['/usr/bin/whoami'], ruby.CapturedCommandOptions{}) or {
				ruby.CapturedCommandResult{}
			}
			system.user_name = chomp_command_output(result.stdout)
		}
		system.user_resolved = true
	}
	return system.user_name
}

pub fn (mut system ServiceSystem) user_exists(username string) bool {
	if username == system.user() {
		return true
	}
	$if windows {
		return false
	} $else {
		return !isnil(C.getpwnam(username.str))
	}
}

pub fn (mut system ServiceSystem) boot_path() !string {
	if system.launchctl_available() {
		return '/Library/LaunchDaemons'
	}
	if system.systemctl_available() {
		return '/usr/lib/systemd/system'
	}
	return error(missing_daemon_manager_exception_message)
}

pub fn (mut system ServiceSystem) user_path() !string {
	if system.launchctl_available() {
		return os.join_path(system.home, 'Library', 'LaunchAgents')
	}
	if system.systemctl_available() {
		return os.join_path(system.home, '.config', 'systemd', 'user')
	}
	return error(missing_daemon_manager_exception_message)
}

pub fn (mut system ServiceSystem) path() !string {
	return if system.root() { system.boot_path()! } else { system.user_path()! }
}

pub fn (mut system ServiceSystem) domain_target() string {
	if system.root() {
		return 'system'
	}
	ssh_tty := system.ssh_tty != '' && system.console_uid != system.uid
	sudo_user := system.sudo_user != ''
	if ssh_tty || sudo_user || system.uid != system.euid {
		if !system.output_warning && !system.no_domain_warning {
			warning := if ssh_tty {
				'running over SSH without /dev/console ownership, using user/* instead of gui/* domain!'
			} else if sudo_user {
				'running through sudo, using user/* instead of gui/* domain!'
			} else {
				'uid and euid do not match, using user/* instead of gui/* domain!'
			}
			system.warnings << warning
			if !system.no_env_hints {
				system.warnings << 'Hide this warning by setting `HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1`.'
				system.warnings << 'Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).'
			}
			system.output_warning = true
		}
		return 'user/${system.euid}'
	}
	return 'gui/${system.uid}'
}

pub fn (mut system ServiceSystem) candidate_domain_targets() []string {
	mut candidates := [system.domain_target()]
	if !system.root() {
		for candidate in ['user/${system.euid}', 'gui/${system.uid}'] {
			if candidate !in candidates {
				candidates << candidate
			}
		}
	}
	return candidates
}

pub fn (mut system ServiceSystem) launchctl_find_service(label string, sudo bool,
	runner LaunchctlRunner) LaunchctlFindResult {
	launchctl_path := system.launchctl() or {
		return LaunchctlFindResult{
			command_type: .launchctl_list
		}
	}
	for domain in system.candidate_domain_targets() {
		result := runner([launchctl_path, 'print', '${domain}/${label}'], sudo)
		if result.success && result.output != '' {
			return LaunchctlFindResult{
				output: result.output
				success: true
				command_type: .launchctl_print
			}
		}
	}
	result := runner([launchctl_path, 'list', label], sudo)
	return LaunchctlFindResult{
		output: result.output
		success: result.success && result.output != ''
		command_type: .launchctl_list
	}
}

pub fn (mut system ServiceSystem) launchctl_service_running(label string, sudo bool,
	runner LaunchctlRunner) bool {
	return system.launchctl_find_service(label, sudo, runner).success
}

fn chomp_command_output(output string) string {
	if output.ends_with('\r\n') {
		return output[..output.len - 2]
	}
	if output.ends_with('\n') || output.ends_with('\r') {
		return output[..output.len - 1]
	}
	return output
}

pub fn launchctl_run(command []string, sudo bool) LaunchctlRunResult {
	if command.len == 0 {
		return LaunchctlRunResult{}
	}
	mut argv := command.clone()
	if sudo {
		sudo_path := if os.is_executable('/usr/bin/sudo') { '/usr/bin/sudo' } else { 'sudo' }
		argv = [sudo_path, '--']
		argv << command
	}
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{}) or {
		return LaunchctlRunResult{}
	}
	return LaunchctlRunResult{
		output: chomp_command_output(result.stdout)
		success: result.exit_code == 0
	}
}

pub fn launchctl_find_service_native(mut system ServiceSystem, label string,
	sudo bool) LaunchctlFindResult {
	return system.launchctl_find_service(label, sudo, launchctl_run)
}

fn service_system_value(system &ServiceSystem) ruby.Value {
	return ruby.structured_value('Homebrew::Services::System', 'System', {
		'system_address': u64(voidptr(system)).str()
	})
}

pub fn service_system_boundary(system &ServiceSystem) ruby.Value {
	return service_system_value(system)
}

fn service_system_from_args(args []ruby.Value) (&ServiceSystem, int) {
	if args.len > 0 && args[0].type_name == 'Homebrew::Services::System' {
		address := args[0].attributes['system_address'] or { panic('translated System state is missing') }
		return unsafe { &ServiceSystem(voidptr(address.u64())) }, 1
	}
	return new_service_system(ServiceSystemConfig{}), 0
}

fn launchctl_find_result_value(result LaunchctlFindResult) ruby.Value {
	type_name := if result.command_type == .launchctl_print {
		'launchctl_print'
	} else {
		'launchctl_list'
	}
	return ruby.array_value([
		ruby.string_value(result.output),
		ruby.bool_value(result.success),
		ruby.object_value('Symbol', type_name),
	])
}

fn launchctl_run_result_value(result LaunchctlRunResult) ruby.Value {
	return ruby.array_value([
		ruby.string_value(result.output),
		ruby.bool_value(result.success),
	])
}
