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

// Ruby method `self.sudo_service_user` at line 15.
pub fn ruby_cli_l15_d1_self_sudo_service_user(state &CliState) ?string {
	return state.sudo_service_user
}

// Ruby method `self.sudo_service_user=(sudo_service_user)` at line 20.
pub fn ruby_cli_l20_d2_self_sudo_service_user(mut state CliState, sudo_service_user string) {
	state.sudo_service_user = sudo_service_user
}

// Ruby method `self.bin` at line 26.
pub fn ruby_cli_l26_d3_self_bin() string {
	return 'brew services'
}

// Ruby method `self.running` at line 32.
pub fn ruby_cli_l32_d4_self_running(system CliSystem) []string {
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
pub fn ruby_cli_l48_d5_self_check(targets []CliService) !bool {
	if targets.len == 0 {
		return error('Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.')
	}
	return true
}

// Ruby method `self.kill_orphaned_services` at line 56.
pub fn ruby_cli_l56_d6_self_kill_orphaned_services(mut state CliState, system CliSystem,
	resolver CliFormulaResolver) CliActionResult {
	mut result := CliActionResult{}
	mut services := []CliService{}
	for label in ruby_cli_l32_d4_self_running(system) {
		resolved := resolver.resolve(label)
		if resolved.found {
			if !os.is_file(resolved.service.dest) {
				result.cleaned << label
				services << resolved.service
			}
		} else {
			result.warnings << 'Warning: Service ${label} not managed by `${ruby_cli_l26_d3_self_bin()}` => skipping'
		}
	}
	killed := ruby_cli_l258_d11_self_kill(mut state, system, mut services, false)
	cli_merge(mut result, killed)
	return result
}

// Ruby method `self.remove_unused_service_files` at line 74.
pub fn ruby_cli_l74_d7_self_remove_unused_service_files(system CliSystem) !CliActionResult {
	mut result := CliActionResult{}
	running := ruby_cli_l32_d4_self_running(system)
	mut files := os.ls(system.path)!
	files.sort()
	for name in files {
		lower := name.to_lower()
		if !name.starts_with('homebrew.') || !(lower.ends_with('.plist') || lower.ends_with('.service') || lower.ends_with('.timer')) {
			continue
		}
		mut label := name
		for suffix in ['.plist', '.service', '.timer'] {
			if label.to_lower().ends_with(suffix) {
				label = label[..label.len - suffix.len]
				break
			}
		}
		if label in running {
			continue
		}
		path := os.join_path(system.path, name)
		result.stdout << 'Removing unused service file: ${path}'
		os.rm(path)!
		result.cleaned << path
	}
	return result
}

// Ruby method `self.run(targets, service_file = nil, verbose: false)` at line 95.
pub fn ruby_cli_l95_d8_self_run(mut state CliState, system CliSystem, mut targets []CliService,
	service_file CliFileArgument, verbose bool) !CliActionResult {
	if service_file.present && !os.exists(service_file.path) {
		return error('Invalid usage: Provided service file does not exist.')
	}
	mut result := CliActionResult{}
	for index in 0 .. targets.len {
		if cli_pid(mut targets[index]) {
			result.stdout << 'Service `${targets[index].name}` already running, use `${ruby_cli_l26_d3_self_bin()} restart ${targets[index].name}` to restart.'
			continue
		}
		if system.root {
			result.stdout << 'Service `${targets[index].name}` cannot be run (but can be started) as root.'
			continue
		}
		loaded := ruby_cli_l378_d15_self_service_load(mut state, system, mut targets[index], service_file, false)!
		cli_merge(mut result, loaded)
	}
	_ = verbose
	return result
}

// Ruby method `self.start(targets, service_file = nil, verbose: false)` at line 122.
pub fn ruby_cli_l122_d9_self_start(mut state CliState, system CliSystem,
	mut targets []CliService, service_file CliFileArgument, verbose bool) !CliActionResult {
	if service_file.present && !os.exists(service_file.path) {
		return error('Invalid usage: Provided service file does not exist.')
	}
	mut result := CliActionResult{}
	mut file := service_file
	for index in 0 .. targets.len {
		if cli_pid(mut targets[index]) {
			result.stdout << 'Service `${targets[index].name}` already started, use `${ruby_cli_l26_d3_self_bin()} restart ${targets[index].name}` to restart.'
			continue
		}
		if !targets[index].installed {
			return error('Invalid usage: Formula `${targets[index].name}` is not installed.')
		}
		if !file.present && !os.exists(targets[index].service_file) && system.manager != .systemctl && targets[index].legacy_service_file != '' {
			file = CliFileArgument{ present: true, path: targets[index].legacy_service_file }
		}
		if !targets[index].install_handled_by_collaborator {
			installed := ruby_cli_l407_d16_self_install_service_file(state, system, targets[index], file)!
			cli_merge(mut result, installed)
		}
		if !file.present && verbose {
			result.stdout << '==> Generated service file for ${targets[index].formula_name}:'
			contents := os.read_file(targets[index].dest)!
			result.stdout << '   ${contents.replace('\n', '\n   ')}'
			result.stdout << ''
		}
		ownership := ruby_cli_l288_d12_self_take_root_ownership(state, system, targets[index])
		cli_merge(mut result, ownership)
		if !ownership.ownership_taken && state.sudo_service_user != none && !system.root {
			continue
		}
		loaded := ruby_cli_l378_d15_self_service_load(mut state, system, mut targets[index], CliFileArgument{}, true)!
		cli_merge(mut result, loaded)
	}
	return result
}

// Ruby method `self.stop(targets, verbose: false, no_wait: false, max_wait: 0, keep: false)` at line 174.
pub fn ruby_cli_l174_d10_self_stop(system CliSystem, mut targets []CliService,
	verbose bool, no_wait bool, max_wait f64, keep bool) !CliActionResult {
	mut result := CliActionResult{}
	for index in 0 .. targets.len {
		if !cli_loaded(mut targets[index]) {
			if !keep {
				if os.exists(targets[index].dest) {
					os.rm(targets[index].dest)!
				}
				if system.manager == .systemctl && targets[index].timed && os.exists(targets[index].timer_dest) {
					os.rm(targets[index].timer_dest)!
				}
			}
			if targets[index].service_file_present {
				prefix := if system.root { '' } else { 'sudo ' }
				return error('Error: Service `${targets[index].name}` is started as `${targets[index].owner}`. Try:\n  ${prefix}${ruby_cli_l26_d3_self_bin()} stop ${targets[index].name}')
			}
			if system.manager == .launchctl && system.quiet_command_success {
				result.commands << cli_launchctl_command(['bootout',
					'${system.domain_target}/${targets[index].service_name}'], true, false)
				result.stdout << '==> Successfully stopped `${targets[index].name}` (label: ${targets[index].service_name})'
			} else {
				result.warnings << 'Warning: Service `${targets[index].name}` is not started.'
			}
			continue
		}
		mut systemctl_args := []string{}
		if no_wait {
			systemctl_args << '--no-block'
			result.stdout << 'Stopping `${targets[index].name}`...'
		} else {
			result.stdout << 'Stopping `${targets[index].name}`... (might take a while)'
		}
		if system.manager == .systemctl {
			if keep {
				if targets[index].timed {
					result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
						'stop',
						targets[index].timer_name(),
					]), true)
				}
				result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
					'stop',
					targets[index].service_name,
				]), true)
			} else if targets[index].timed {
				result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
					'disable',
					'--now',
					targets[index].timer_name(),
				]), true)
				result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
					'disable',
					'--now',
					targets[index].service_name,
				]), true)
			} else {
				result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
					'disable',
					'--now',
					targets[index].service_name,
				]), true)
			}
		} else if system.manager == .launchctl {
			esrch := if system.esrch_status == 0 { 3 } else { system.esrch_status }
			einprogress := if system.einprogress_status == 0 {
				115
			} else {
				system.einprogress_status
			}
			domain_unsupported := if system.domain_unsupported_status == 0 {
				125
			} else {
				system.domain_unsupported_status
			}
			for domain in system.candidate_domain_targets {
				if !cli_loaded(mut targets[index]) {
					break
				}
				result.commands << cli_launchctl_command(['bootout',
					'${domain}/${targets[index].service_name}'], true, false)
				if !no_wait {
					mut time_slept := f64(0)
					mut exit_index := 0
					mut exit_status := if system.quiet_exit_statuses.len > 0 {
						system.quiet_exit_statuses[0]
					} else {
						esrch
					}
					for exit_status !in [esrch, domain_unsupported] && (exit_status == einprogress || cli_loaded(mut targets[index])) && (max_wait == 0 || time_slept < max_wait) {
						result.wait_seconds << 1.0
						time_slept++
						result.commands << cli_launchctl_command(['bootout',
							'${domain}/${targets[index].service_name}'], true, false)
						exit_index++
						exit_status = if exit_index < system.quiet_exit_statuses.len {
							system.quiet_exit_statuses[exit_index]
						} else {
							esrch
						}
					}
				}
				cli_reset_cache(mut targets[index])
				if cli_pid(mut targets[index]) {
					result.commands << cli_launchctl_command(['stop',
						'${domain}/${targets[index].service_name}'], true, false)
				}
			}
		}
		if !keep {
			if os.exists(targets[index].dest) {
				os.rm(targets[index].dest)!
			}
			if system.manager == .systemctl && targets[index].timed && os.exists(targets[index].timer_dest) {
				os.rm(targets[index].timer_dest)!
			}
			if system.manager == .systemctl {
				result.commands << cli_systemctl_command(system, cli_args(systemctl_args, [
					'daemon-reload',
				]), false)
			}
		}
		if cli_loaded(mut targets[index]) || cli_pid(mut targets[index]) {
			result.warnings << 'Warning: Unable to stop `${targets[index].name}` (label: ${targets[index].service_name})'
		} else {
			result.stdout << '==> Successfully stopped `${targets[index].name}` (label: ${targets[index].service_name})'
		}
	}
	_ = verbose
	return result
}

// Ruby method `self.kill(targets, verbose: false)` at line 258.
pub fn ruby_cli_l258_d11_self_kill(mut state CliState, system CliSystem,
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
pub fn ruby_cli_l288_d12_self_take_root_ownership(state CliState, system CliSystem,
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
pub fn ruby_cli_l361_d13_self_launchctl_load(system CliSystem, service CliService,
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
pub fn ruby_cli_l367_d14_self_systemd_load(system CliSystem, service CliService,
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
pub fn ruby_cli_l378_d15_self_service_load(mut state CliState, system CliSystem,
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
		cli_merge(mut result, ruby_cli_l361_d13_self_launchctl_load(system, service, selected, enable))
	} else if system.manager == .systemctl {
		if !os.exists(service.dest) && !service.install_handled_by_collaborator {
			installed := ruby_cli_l407_d16_self_install_service_file(state, system, service, file)!
			cli_merge(mut result, installed)
		}
		for path in service.path_dirs {
			os.mkdir_all(path)!
		}
		cli_merge(mut result, ruby_cli_l367_d14_self_systemd_load(system, service, enable))
	}
	function := if enable { 'started' } else { 'ran' }
	result.stdout << '==> Successfully ${function} `${service.name}` (label: ${service.service_name})'
	result.loaded = true
	return result
}

// Ruby method `self.install_service_file(service, file)` at line 407.
pub fn ruby_cli_l407_d16_self_install_service_file(state CliState, system CliSystem,
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/formula_wrapper"
// 5: require "fileutils"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   module Services
// 10:     module Cli
// 11:       extend FileUtils
// 12:       extend Utils::Output::Mixin
// 13:
// 14:       sig { returns(T.nilable(String)) }
// 15:       def self.sudo_service_user
// 16:         @sudo_service_user
// 17:       end
// 18:
// 19:       sig { params(sudo_service_user: String).void }
// 20:       def self.sudo_service_user=(sudo_service_user)
// 21:         @sudo_service_user = T.let(sudo_service_user, T.nilable(String))
// 22:       end
// 23:
// 24:       # Binary name.
// 25:       sig { returns(String) }
// 26:       def self.bin
// 27:         "brew services"
// 28:       end
// 29:
// 30:       # Find all currently running services via launchctl list or systemctl list-units.
// 31:       sig { returns(T::Array[String]) }
// 32:       def self.running
// 33:         if System.launchctl?
// 34:           Utils.popen_read(System.launchctl, "list")
// 35:         else
// 36:           System::Systemctl.popen_read("list-units",
// 37:                                        "--type=service",
// 38:                                        "--state=running",
// 39:                                        "--no-pager",
// 40:                                        "--no-legend")
// 41:         end.chomp.split("\n").filter_map do |svc|
// 42:           svc[/homebrew(?>\.mxcl)?\.([\w+-.@]+)/]&.delete_suffix(".service")
// 43:         end
// 44:       end
// 45:
// 46:       # Check if formula has been found.
// 47:       sig { params(targets: T::Array[Services::FormulaWrapper]).returns(T::Boolean) }
// 48:       def self.check!(targets)
// 49:         raise UsageError, "Formula(e) missing, please provide a formula name or use `--all`." if targets.empty?
// 50:
// 51:         true
// 52:       end
// 53:
// 54:       # Kill services that don't have a service file
// 55:       sig { returns(T::Array[String]) }
// 56:       def self.kill_orphaned_services
// 57:         cleaned_labels = []
// 58:         cleaned_services = []
// 59:         running.each do |label|
// 60:           if (service = FormulaWrapper.from(label))
// 61:             unless service.dest.file?
// 62:               cleaned_labels << label
// 63:               cleaned_services << service
// 64:             end
// 65:           else
// 66:             opoo "Service #{label} not managed by `#{bin}` => skipping"
// 67:           end
// 68:         end
// 69:         kill(cleaned_services)
// 70:         cleaned_labels
// 71:       end
// 72:
// 73:       sig { returns(T::Array[String]) }
// 74:       def self.remove_unused_service_files
// 75:         cleaned = []
// 76:         System.path.glob("homebrew.*.{plist,service,timer}").each do |file|
// 77:           next if running.include?(File.basename(file).sub(/\.(plist|service|timer)$/i, ""))
// 78:
// 79:           puts "Removing unused service file: #{file}"
// 80:           rm file
// 81:           cleaned << file.to_s
// 82:         end
// 83:
// 84:         cleaned
// 85:       end
// 86:
// 87:       # Run a service as defined in the formula. This does not clean the service file like `start` does.
// 88:       sig {
// 89:         params(
// 90:           targets:      T::Array[Services::FormulaWrapper],
// 91:           service_file: T.nilable(String),
// 92:           verbose:      T::Boolean,
// 93:         ).void
// 94:       }
// 95:       def self.run(targets, service_file = nil, verbose: false)
// 96:         if service_file.present?
// 97:           file = Pathname.new service_file
// 98:           raise UsageError, "Provided service file does not exist." unless file.exist?
// 99:         end
// 100:
// 101:         targets.each do |service|
// 102:           if service.pid?
// 103:             puts "Service `#{service.name}` already running, use `#{bin} restart #{service.name}` to restart."
// 104:             next
// 105:           elsif System.root?
// 106:             puts "Service `#{service.name}` cannot be run (but can be started) as root."
// 107:             next
// 108:           end
// 109:
// 110:           service_load(service, file, enable: false)
// 111:         end
// 112:       end
// 113:
// 114:       # Start a service.
// 115:       sig {
// 116:         params(
// 117:           targets:      T::Array[Services::FormulaWrapper],
// 118:           service_file: T.nilable(String),
// 119:           verbose:      T::Boolean,
// 120:         ).void
// 121:       }
// 122:       def self.start(targets, service_file = nil, verbose: false)
// 123:         file = T.let(nil, T.nilable(Pathname))
// 124:
// 125:         if service_file.present?
// 126:           file = Pathname.new service_file
// 127:           raise UsageError, "Provided service file does not exist." unless file.exist?
// 128:         end
// 129:
// 130:         targets.each do |service|
// 131:           if service.pid?
// 132:             puts "Service `#{service.name}` already started, use `#{bin} restart #{service.name}` to restart."
// 133:             next
// 134:           end
// 135:
// 136:           odie "Formula `#{service.name}` is not installed." unless service.installed?
// 137:
// 138:           file ||= if service.service_file.exist? || System.systemctl?
// 139:             nil
// 140:           elsif service.formula.opt_prefix.exist? &&
// 141:                 (keg = Keg.for service.formula.opt_prefix) &&
// 142:                 keg.plist_installed?
// 143:             service_file = Dir["#{keg}/*#{service.service_file.extname}"].first
// 144:             Pathname.new service_file if service_file.present?
// 145:           end
// 146:
// 147:           install_service_file(service, file)
// 148:
// 149:           if !file && verbose
// 150:             ohai "Generated service file for #{service.formula.name}:"
// 151:             puts "   #{service.dest.read.gsub("\n", "\n   ")}"
// 152:             puts
// 153:           end
// 154:
// 155:           # Never skip loading when ownership was taken, otherwise
// 156:           # only skip a `--sudo-service-user` service when not root.
// 157:           root_ownership_taken = take_root_ownership?(service)
// 158:           next if !root_ownership_taken && sudo_service_user && !System.root?
// 159:
// 160:           service_load(service, nil, enable: true)
// 161:         end
// 162:       end
// 163:
// 164:       # Stop a service and unload it.
// 165:       sig {
// 166:         params(
// 167:           targets:  T::Array[Services::FormulaWrapper],
// 168:           verbose:  T::Boolean,
// 169:           no_wait:  T::Boolean,
// 170:           max_wait: T.nilable(T.any(Integer, Float)),
// 171:           keep:     T::Boolean,
// 172:         ).void
// 173:       }
// 174:       def self.stop(targets, verbose: false, no_wait: false, max_wait: 0, keep: false)
// 175:         targets.each do |service|
// 176:           unless service.loaded?
// 177:             unless keep
// 178:               rm service.dest if service.dest.exist? # get rid of installed service file anyway, dude
// 179:               rm service.timer_dest if System.systemctl? && service.timed? && service.timer_dest.exist?
// 180:             end
// 181:             if service.service_file_present?
// 182:               odie <<~EOS
// 183:                 Service `#{service.name}` is started as `#{service.owner}`. Try:
// 184:                   #{"sudo " unless System.root?}#{bin} stop #{service.name}
// 185:               EOS
// 186:             elsif System.launchctl? &&
// 187:                   quiet_system(System.launchctl, "bootout", "#{System.domain_target}/#{service.service_name}")
// 188:               ohai "Successfully stopped `#{service.name}` (label: #{service.service_name})"
// 189:             else
// 190:               opoo "Service `#{service.name}` is not started."
// 191:             end
// 192:             next
// 193:           end
// 194:
// 195:           systemctl_args = []
// 196:           if no_wait
// 197:             systemctl_args << "--no-block"
// 198:             puts "Stopping `#{service.name}`..."
// 199:           else
// 200:             puts "Stopping `#{service.name}`... (might take a while)"
// 201:           end
// 202:
// 203:           if System.systemctl?
// 204:             if keep
// 205:               System::Systemctl.quiet_run(*systemctl_args, "stop", service.timer_name) if service.timed?
// 206:               System::Systemctl.quiet_run(*systemctl_args, "stop", service.service_name)
// 207:             elsif service.timed?
// 208:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.timer_name)
// 209:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.service_name)
// 210:             else
// 211:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.service_name)
// 212:             end
// 213:           elsif System.launchctl?
// 214:             dont_wait_statuses = [
// 215:               Errno::ESRCH::Errno,
// 216:               System::LAUNCHCTL_DOMAIN_ACTION_NOT_SUPPORTED,
// 217:             ]
// 218:             System.candidate_domain_targets.each do |domain_target|
// 219:               break unless service.loaded?
// 220:
// 221:               quiet_system System.launchctl, "bootout", "#{domain_target}/#{service.service_name}"
// 222:               unless no_wait
// 223:                 time_slept = 0
// 224:                 sleep_time = 1
// 225:                 max_wait = T.must(max_wait)
// 226:                 exit_status = $CHILD_STATUS.exitstatus
// 227:                 while dont_wait_statuses.exclude?(exit_status) &&
// 228:                       (exit_status == Errno::EINPROGRESS::Errno || service.loaded?) &&
// 229:                       (max_wait.zero? || time_slept < max_wait)
// 230:                   sleep(sleep_time)
// 231:                   time_slept += sleep_time
// 232:                   quiet_system System.launchctl, "bootout", "#{domain_target}/#{service.service_name}"
// 233:                   exit_status = $CHILD_STATUS.exitstatus
// 234:                 end
// 235:               end
// 236:               service.reset_cache!
// 237:               quiet_system System.launchctl, "stop", "#{domain_target}/#{service.service_name}" if service.pid?
// 238:             end
// 239:           end
// 240:
// 241:           unless keep
// 242:             rm service.dest if service.dest.exist?
// 243:             rm service.timer_dest if System.systemctl? && service.timed? && service.timer_dest.exist?
// 244:             # Run daemon-reload on systemctl to finish unloading stopped and deleted service.
// 245:             System::Systemctl.run(*systemctl_args, "daemon-reload") if System.systemctl?
// 246:           end
// 247:
// 248:           if service.loaded? || service.pid?
// 249:             opoo "Unable to stop `#{service.name}` (label: #{service.service_name})"
// 250:           else
// 251:             ohai "Successfully stopped `#{service.name}` (label: #{service.service_name})"
// 252:           end
// 253:         end
// 254:       end
// 255:
// 256:       # Stop a service but keep it registered.
// 257:       sig { params(targets: T::Array[Services::FormulaWrapper], verbose: T::Boolean).void }
// 258:       def self.kill(targets, verbose: false)
// 259:         targets.each do |service|
// 260:           if !service.pid?
// 261:             puts "Service `#{service.name}` is not started."
// 262:           elsif service.keep_alive?
// 263:             puts "Service `#{service.name}` is set to automatically restart and can't be killed."
// 264:           else
// 265:             puts "Killing `#{service.name}`... (might take a while)"
// 266:             if System.systemctl?
// 267:               System::Systemctl.quiet_run("stop", service.service_name)
// 268:             elsif System.launchctl?
// 269:               System.candidate_domain_targets.each do |domain_target|
// 270:                 break unless service.pid?
// 271:
// 272:                 quiet_system System.launchctl, "stop", "#{domain_target}/#{service.service_name}"
// 273:                 service.reset_cache!
// 274:               end
// 275:             end
// 276:
// 277:             if service.pid?
// 278:               opoo "Unable to kill `#{service.name}` (label: #{service.service_name})"
// 279:             else
// 280:               ohai "Successfully killed `#{service.name}` (label: #{service.service_name})"
// 281:             end
// 282:           end
// 283:         end
// 284:       end
// 285:
// 286:       # protections to avoid users editing root services
// 287:       sig { params(service: Services::FormulaWrapper).returns(T::Boolean) }
// 288:       def self.take_root_ownership?(service)
// 289:         return false unless System.root?
// 290:         return false if sudo_service_user
// 291:
// 292:         root_paths = T.let([], T::Array[Pathname])
// 293:
// 294:         if System.systemctl?
// 295:           group = "root"
// 296:         elsif System.launchctl?
// 297:           group = "admin"
// 298:           chown "root", group, service.dest
// 299:           require "plist"
// 300:           plist_data = service.dest.read
// 301:           plist = begin
// 302:             Plist.parse_xml(plist_data, marshal: false)
// 303:           rescue
// 304:             nil
// 305:           end
// 306:           return false unless plist
// 307:
// 308:           program_location = plist["ProgramArguments"]&.first
// 309:           key = "first ProgramArguments value"
// 310:           if program_location.blank?
// 311:             program_location = plist["Program"]
// 312:             key = "Program"
// 313:           end
// 314:
// 315:           if program_location.present?
// 316:             Dir.chdir("/") do
// 317:               if File.exist?(program_location)
// 318:                 program_location_path = Pathname(program_location).realpath
// 319:                 root_paths += [
// 320:                   program_location_path,
// 321:                   program_location_path.parent.realpath,
// 322:                 ]
// 323:               else
// 324:                 opoo <<~EOS
// 325:                   #{service.name}: the #{key} does not exist:
// 326:                     #{program_location}
// 327:                 EOS
// 328:               end
// 329:             end
// 330:           end
// 331:         end
// 332:
// 333:         if (formula = service.formula)
// 334:           root_paths += [
// 335:             formula.opt_prefix,
// 336:             formula.linked_keg,
// 337:             formula.bin,
// 338:             formula.sbin,
// 339:           ]
// 340:         end
// 341:         root_paths = root_paths.sort.uniq.select(&:exist?)
// 342:
// 343:         opoo <<~EOS
// 344:           Taking root:#{group} ownership of some #{service.formula} paths:
// 345:             #{root_paths.join("\n  ")}
// 346:           This will require manual removal of these paths using `sudo rm` on
// 347:           brew upgrade/reinstall/uninstall.
// 348:         EOS
// 349:         chown "root", group, root_paths
// 350:         chmod "+t", root_paths
// 351:         true
// 352:       end
// 353:
// 354:       sig {
// 355:         params(
// 356:           service: Services::FormulaWrapper,
// 357:           file:    T.nilable(T.any(String, Pathname)),
// 358:           enable:  T::Boolean,
// 359:         ).void
// 360:       }
// 361:       def self.launchctl_load(service, file:, enable:)
// 362:         safe_system System.launchctl, "enable", "#{System.domain_target}/#{service.service_name}" if enable
// 363:         safe_system System.launchctl, "bootstrap", System.domain_target, file
// 364:       end
// 365:
// 366:       sig { params(service: Services::FormulaWrapper, enable: T::Boolean).void }
// 367:       def self.systemd_load(service, enable:)
// 368:         System::Systemctl.run("start", service.service_name)
// 369:         if service.timed?
// 370:           System::Systemctl.run("start", service.timer_name)
// 371:           System::Systemctl.run("enable", service.timer_name) if enable
// 372:         elsif enable
// 373:           System::Systemctl.run("enable", service.service_name)
// 374:         end
// 375:       end
// 376:
// 377:       sig { params(service: Services::FormulaWrapper, file: T.nilable(Pathname), enable: T::Boolean).void }
// 378:       def self.service_load(service, file, enable:)
// 379:         if System.root? && !service.service_startup? && !sudo_service_user
// 380:           opoo "`#{service.name}` must be run as non-root to start at user login!"
// 381:         elsif !System.root? && service.service_startup?
// 382:           opoo "`#{service.name}` must be run as root to start at system startup!"
// 383:         end
// 384:
// 385:         if (service_user = sudo_service_user) && !System.user_exists?(service_user)
// 386:           function = enable ? "start" : "run"
// 387:           odie "Cannot #{function} `#{service.name}` as `#{service_user}` is not a user!"
// 388:         end
// 389:
// 390:         if System.launchctl?
// 391:           file ||= enable ? service.dest : service.service_file
// 392:           service.path_dirs.each(&:mkpath)
// 393:           launchctl_load(service, file:, enable:)
// 394:         elsif System.systemctl?
// 395:           # Systemctl loads based upon location so only install service
// 396:           # file when it is not installed. Used with the `run` command.
// 397:           install_service_file(service, file) unless service.dest.exist?
// 398:           service.path_dirs.each(&:mkpath)
// 399:           systemd_load(service, enable:)
// 400:         end
// 401:
// 402:         function = enable ? "started" : "ran"
// 403:         ohai("Successfully #{function} `#{service.name}` (label: #{service.service_name})")
// 404:       end
// 405:
// 406:       sig { params(service: Services::FormulaWrapper, file: T.nilable(Pathname)).void }
// 407:       def self.install_service_file(service, file)
// 408:         raise UsageError, "Formula `#{service.name}` is not installed." unless service.installed?
// 409:
// 410:         unless service.service_file.exist?
// 411:           raise UsageError,
// 412:                 "Formula `#{service.name}` has not implemented #plist, #service or provided a locatable service file."
// 413:         end
// 414:
// 415:         temp = Tempfile.new(service.service_name)
// 416:         temp << if file.nil?
// 417:           contents = service.service_contents
// 418:
// 419:           if sudo_service_user && System.launchctl?
// 420:             # set the username in the new plist file
// 421:             ohai "Setting username in #{service.service_name} to: #{sudo_service_user}"
// 422:             require "plist"
// 423:             plist_data = Plist.parse_xml(contents, marshal: false)
// 424:             plist_data["UserName"] = sudo_service_user
// 425:             plist_data.to_plist
// 426:           else
// 427:             contents
// 428:           end
// 429:         else
// 430:           file.read
// 431:         end
// 432:         temp.flush
// 433:
// 434:         rm service.dest if service.dest.exist?
// 435:         service.dest_dir.mkpath unless service.dest_dir.directory?
// 436:         cp T.must(temp.path), service.dest
// 437:
// 438:         # Clear tempfile.
// 439:         temp.close
// 440:
// 441:         chmod 0644, service.dest
// 442:         if System.systemctl? && service.timed?
// 443:           rm service.timer_dest if service.timer_dest.exist?
// 444:           cp service.timer_file, service.timer_dest
// 445:           chmod 0644, service.timer_dest
// 446:         end
// 447:
// 448:         System::Systemctl.run("daemon-reload") if System.systemctl?
// 449:       end
// 450:     end
// 451:   end
// 452: end
