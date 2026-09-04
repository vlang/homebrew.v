module services

import os

// Translated from Homebrew/brew `services/cli.rb`.
// The retained Ruby source follows these source-shaped typed boundaries.
pub struct CliState {
pub mut:
	sudo_service_user ?string
}

pub struct CliSystem {
pub:
	manager                   FormulaWrapperDaemonManager
	root                      bool
	path                      string
	running_output            string
	running_labels            []string
	domain_target             string
	candidate_domain_targets  []string
	systemctl_scope           string
	user_exists               map[string]bool
	quiet_command_success     bool
	quiet_exit_statuses       []int
	esrch_status              int
	einprogress_status        int
	domain_unsupported_status int
}

pub struct CliFileArgument {
pub:
	present bool
	path    string
}

pub struct CliCommand {
pub:
	program string
	args    []string
	quiet   bool
	safe    bool
}

pub struct CliActionResult {
pub mut:
	stdout          []string
	warnings        []string
	commands        []CliCommand
	cleaned         []string
	root_paths      []string
	wait_seconds    []f64
	ownership_taken bool
	loaded          bool
}

pub struct CliService {
pub mut:
	name                            string
	service_name                    string
	formula_name                    string
	installed                       bool
	service_file                    string
	dest                            string
	dest_dir                        string
	timer_file                      string
	timer_dest                      string
	service_contents                string
	timed                           bool
	keep_alive                      bool
	service_startup                 bool
	service_file_present            bool
	owner                           string
	path_dirs                       []string
	formula_opt_prefix              string
	formula_linked_keg              string
	formula_bin                     string
	formula_sbin                    string
	legacy_service_file             string
	install_handled_by_collaborator bool
	pid_values                      []bool
	loaded_values                   []bool
	pid_default                     bool
	loaded_default                  bool
	pid_reads                       int
	loaded_reads                    int
	cache_resets                    int
}

pub struct CliResolvedService {
pub:
	found   bool
	service CliService
}

pub interface CliFormulaResolver {
	resolve(label string) CliResolvedService
}

fn cli_pid(mut service CliService) bool {
	index := service.pid_reads
	service.pid_reads++
	return if index < service.pid_values.len {
		service.pid_values[index]
	} else {
		service.pid_default
	}
}

fn cli_loaded(mut service CliService) bool {
	index := service.loaded_reads
	service.loaded_reads++
	return if index < service.loaded_values.len {
		service.loaded_values[index]
	} else {
		service.loaded_default
	}
}

fn cli_reset_cache(mut service CliService) {
	service.cache_resets++
}

fn (service CliService) timer_name() string {
	return os.base(service.timer_file)
}

fn cli_systemctl_command(system CliSystem, args []string, quiet bool) CliCommand {
	mut effective := []string{}
	if system.systemctl_scope != '' {
		effective << system.systemctl_scope
	}
	effective << args
	return CliCommand{ program: 'systemctl', args: effective, quiet: quiet }
}

fn cli_launchctl_command(args []string, quiet bool, safe bool) CliCommand {
	return CliCommand{ program: 'launchctl', args: args, quiet: quiet, safe: safe }
}

fn cli_args(base []string, tail []string) []string {
	mut result := base.clone()
	result << tail
	return result
}

fn cli_merge(mut destination CliActionResult, source CliActionResult) {
	destination.stdout << source.stdout
	destination.warnings << source.warnings
	destination.commands << source.commands
	destination.cleaned << source.cleaned
	destination.root_paths << source.root_paths
	destination.wait_seconds << source.wait_seconds
	destination.ownership_taken = destination.ownership_taken || source.ownership_taken
	destination.loaded = destination.loaded || source.loaded
}

fn cli_running_label(line string) ?string {
	mut offset := 0
	for offset < line.len {
		relative := line[offset..].index('homebrew') or { return none }
		start := offset + relative
		mut end := start + 'homebrew'.len
		if line[end..].starts_with('.mxcl.') {
			end += '.mxcl.'.len
		} else if line[end..].starts_with('.') {
			end++
		} else {
			offset = start + 1
			continue
		}
		name_start := end
		for end < line.len {
			byte := line[end]
			if !((byte >= `a` && byte <= `z`) || (byte >= `A` && byte <= `Z`) || (byte >= `0` && byte <= `9`) || byte in [
				`_`,
				`+`,
				`,`,
				`-`,
				`.`,
				`@`,
			]) {
				break
			}
			end++
		}
		if end == name_start {
			offset = start + 1
			continue
		}
		mut label := line[start..end]
		if label.ends_with('.service') {
			label = label[..label.len - '.service'.len]
		}
		return label
	}
	return none
}

fn cli_plist_string(contents string, key string) ?string {
	key_index := contents.index('<key>${key}</key>') or { return none }
	open := contents.index_after('<string>', key_index) or { return none }
	close := contents.index_after('</string>', open + '<string>'.len) or { return none }
	return contents[open + '<string>'.len..close]
}

fn cli_plist_program(contents string) (string, string) {
	arguments := contents.index('<key>ProgramArguments</key>') or { -1 }
	if arguments >= 0 {
		array_open := contents.index_after('<array>', arguments) or { -1 }
		if array_open >= 0 {
			string_open := contents.index_after('<string>', array_open) or { -1 }
			array_close := contents.index_after('</array>', array_open) or { -1 }
			if string_open >= 0 && array_close >= 0 && string_open < array_close {
				string_close := contents.index_after('</string>', string_open) or { -1 }
				if string_close >= 0 {
					return contents[string_open + '<string>'.len..string_close], 'first ProgramArguments value'
				}
			}
		}
	}
	return cli_plist_string(contents, 'Program') or { '' }, 'Program'
}

fn cli_plist_set_username(contents string, username string) !string {
	key := '<key>UserName</key>'
	if index := contents.index(key) {
		open := contents.index_after('<string>', index + key.len) or {
			return error('invalid plist UserName value')
		}
		close := contents.index_after('</string>', open + '<string>'.len) or {
			return error('invalid plist UserName value')
		}
		return contents[..open + '<string>'.len] + username + contents[close..]
	}
	close := contents.index('</dict>') or { return error('invalid plist') }
	entry := '\t<key>UserName</key>\n\t<string>${username}</string>\n'
	return contents[..close] + entry + contents[close..]
}

// Ruby method `self.bin` at line 26.
pub fn cli_bin() string {
	return 'brew services'
}

// Ruby method `self.running` at line 32.
pub fn cli_running(system CliSystem) []string {
	if system.running_labels.len > 0 {
		return system.running_labels.clone()
	}
	mut labels := []string{}
	for line in system.running_output.trim_right('\n').split('\n') {
		if label := cli_running_label(line) {
			labels << label
		}
	}
	return labels
}

// Ruby method `self.check!(targets)` at line 48.
pub fn cli_check(targets []CliService) !bool {
	if targets.len == 0 {
		return error('Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.')
	}
	return true
}

// Ruby method `self.kill(targets, verbose: false)` at line 258.
pub fn cli_kill(mut state CliState, system CliSystem,
	mut targets []CliService, verbose bool) CliActionResult {
	mut result := CliActionResult{}
	for index in 0 .. targets.len {
		if !cli_pid(mut targets[index]) {
			result.stdout << 'Service `${targets[index].name}` is not started.'
		} else if targets[index].keep_alive {
			result.stdout << "Service `${targets[index].name}` is set to automatically restart and can't be killed."
		} else {
			result.stdout << 'Killing `${targets[index].name}`... (might take a while)'
			if system.manager == .systemctl {
				result.commands << cli_systemctl_command(system, ['stop',
					targets[index].service_name], true)
			} else if system.manager == .launchctl {
				for domain in system.candidate_domain_targets {
					if !cli_pid(mut targets[index]) {
						break
					}
					result.commands << cli_launchctl_command(['stop',
						'${domain}/${targets[index].service_name}'], true, false)
					cli_reset_cache(mut targets[index])
				}
			}
			if cli_pid(mut targets[index]) {
				result.warnings << 'Warning: Unable to kill `${targets[index].name}` (label: ${targets[index].service_name})'
			} else {
				result.stdout << '==> Successfully killed `${targets[index].name}` (label: ${targets[index].service_name})'
			}
		}
	}
	_ = state
	_ = verbose
	return result
}

// Ruby method `self.take_root_ownership?(service)` at line 288.
pub fn cli_take_root_ownership(state CliState, system CliSystem,
	service CliService) CliActionResult {
	mut result := CliActionResult{}
	if !system.root || state.sudo_service_user != none {
		return result
	}
	group := if system.manager == .systemctl { 'root' } else { 'admin' }
	if system.manager == .launchctl {
		result.commands << CliCommand{ program: 'chown', args: ['root', group, service.dest] }
		contents := os.read_file(service.dest) or { return result }
		if !contents.contains('<plist') || !contents.contains('</plist>') {
			return result
		}
		program, key := cli_plist_program(contents)
		if program != '' {
			if os.exists(program) {
				real := os.real_path(program)
				result.root_paths << [real, os.real_path(os.dir(real))]
			} else {
				result.warnings << 'Warning: ${service.name}: the ${key} does not exist:\n  ${program}'
			}
		}
	}
	result.root_paths << [service.formula_opt_prefix, service.formula_linked_keg,
		service.formula_bin, service.formula_sbin]
	result.root_paths = result.root_paths.filter(it != '' && os.exists(it))
	result.root_paths.sort()
	mut unique_paths := []string{}
	for path in result.root_paths {
		if path !in unique_paths {
			unique_paths << path
		}
	}
	result.root_paths = unique_paths
	result.warnings << 'Warning: Taking root:${group} ownership of some ${service.formula_name} paths:\n  ${result.root_paths.join('\n  ')}\nThis will require manual removal of these paths using `sudo rm` on\nbrew upgrade/reinstall/uninstall.'
	result.commands << CliCommand{ program: 'chown', args: cli_args(['root', group], result.root_paths) }
	result.commands << CliCommand{ program: 'chmod', args: cli_args(['+t'], result.root_paths) }
	result.ownership_taken = true
	return result
}

// Ruby method `self.launchctl_load(service, file:, enable:)` at line 361.
pub fn cli_launchctl_load(system CliSystem, service CliService,
	file string, enable bool) CliActionResult {
	mut result := CliActionResult{}
	if enable {
		result.commands << cli_launchctl_command(['enable',
			'${system.domain_target}/${service.service_name}'], false, true)
	}
	result.commands << cli_launchctl_command(['bootstrap', system.domain_target, file], false, true)
	return result
}

// Ruby method `self.systemd_load(service, enable:)` at line 367.
pub fn cli_systemd_load(system CliSystem, service CliService,
	enable bool) CliActionResult {
	mut result := CliActionResult{}
	result.commands << cli_systemctl_command(system, ['start', service.service_name], false)
	if service.timed {
		result.commands << cli_systemctl_command(system, ['start', service.timer_name()], false)
		if enable {
			result.commands << cli_systemctl_command(system, ['enable', service.timer_name()], false)
		}
	} else if enable {
		result.commands << cli_systemctl_command(system, ['enable', service.service_name], false)
	}
	return result
}

// Ruby method `self.service_load(service, file, enable:)` at line 378.
pub fn cli_service_load(mut state CliState, system CliSystem,
	mut service CliService, file CliFileArgument, enable bool) !CliActionResult {
	mut result := CliActionResult{}
	if system.root && !service.service_startup && state.sudo_service_user == none {
		result.warnings << 'Warning: `${service.name}` must be run as non-root to start at user login!'
	} else if !system.root && service.service_startup {
		result.warnings << 'Warning: `${service.name}` must be run as root to start at system startup!'
	}
	if service_user := state.sudo_service_user {
		if !(system.user_exists[service_user] or { false }) {
			function := if enable { 'start' } else { 'run' }
			return error('Error: Cannot ${function} `${service.name}` as `${service_user}` is not a user!')
		}
	}
	if system.manager == .launchctl {
		selected := if file.present {
			file.path
		} else if enable {
			service.dest
		} else {
			service.service_file
		}
		for path in service.path_dirs {
			os.mkdir_all(path)!
		}
		cli_merge(mut result, cli_launchctl_load(system, service, selected, enable))
	} else if system.manager == .systemctl {
		if !os.exists(service.dest) && !service.install_handled_by_collaborator {
			installed := cli_install_service_file(state, system, service, file)!
			cli_merge(mut result, installed)
		}
		for path in service.path_dirs {
			os.mkdir_all(path)!
		}
		cli_merge(mut result, cli_systemd_load(system, service, enable))
	}
	function := if enable { 'started' } else { 'ran' }
	result.stdout << '==> Successfully ${function} `${service.name}` (label: ${service.service_name})'
	result.loaded = true
	return result
}

// Ruby method `self.install_service_file(service, file)` at line 407.
pub fn cli_install_service_file(state CliState, system CliSystem,
	service CliService, file CliFileArgument) !CliActionResult {
	if !service.installed {
		return error('Invalid usage: Formula `${service.name}` is not installed.')
	}
	if !os.exists(service.service_file) {
		return error('Invalid usage: Formula `${service.name}` has not implemented #plist, #service or provided a locatable service file.')
	}
	mut result := CliActionResult{}
	mut contents := if file.present { os.read_file(file.path)! } else { service.service_contents }
	if user := state.sudo_service_user {
		if system.manager == .launchctl {
			result.stdout << '==> Setting username in ${service.service_name} to: ${user}'
			contents = cli_plist_set_username(contents, user)!
		}
	}
	if os.exists(service.dest) {
		os.rm(service.dest)!
	}
	if !os.is_dir(service.dest_dir) {
		os.mkdir_all(service.dest_dir)!
	}
	os.write_file(service.dest, contents)!
	os.chmod(service.dest, 0o644)!
	if system.manager == .systemctl && service.timed {
		if os.exists(service.timer_dest) {
			os.rm(service.timer_dest)!
		}
		os.cp(service.timer_file, service.timer_dest)!
		os.chmod(service.timer_dest, 0o644)!
	}
	if system.manager == .systemctl {
		result.commands << cli_systemctl_command(system, ['daemon-reload'], false)
	}
	return result
}
