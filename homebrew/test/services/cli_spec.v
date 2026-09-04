module services

import homebrew.services as services_cli
import os

// Translated from Homebrew/brew `test/services/cli_spec.rb`.
// The retained Ruby source follows these concrete source-derived examples.
struct CliSpecResolver {
	values map[string]services_cli.CliResolvedService
}

fn (resolver CliSpecResolver) resolve(label string) services_cli.CliResolvedService {
	return resolver.values[label] or { services_cli.CliResolvedService{} }
}

fn cli_spec_temp_dir(label string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-cli-${os.getpid()}-${label}')
	if os.exists(path) {
		os.rmdir_all(path)!
	}
	os.mkdir_all(path)!
	return path
}

fn cli_spec_system(manager services_cli.FormulaWrapperDaemonManager,
	root bool) services_cli.CliSystem {
	return services_cli.CliSystem{
		manager: manager
		root: root
		domain_target: 'gui/501'
		candidate_domain_targets: ['gui/501']
		systemctl_scope: if root { '' } else { '--user' }
		user_exists: {
			'_serviced': true
		}
	}
}

fn cli_spec_service(directory string) !services_cli.CliService {
	os.mkdir_all(directory)!
	service_file := os.join_path(directory, 'source', 'homebrew.name.service')
	os.mkdir_all(os.dir(service_file))!
	os.write_file(service_file, 'service')!
	return services_cli.CliService{
		name: 'name'
		service_name: 'homebrew.name'
		formula_name: 'name'
		installed: true
		service_file: service_file
		dest: os.join_path(directory, 'dest', 'homebrew.name.service')
		dest_dir: os.join_path(directory, 'dest')
		timer_file: os.join_path(directory, 'source', 'homebrew.name.timer')
		timer_dest: os.join_path(directory, 'dest', 'homebrew.name.timer')
		service_contents: 'service'
	}
}

fn cli_spec_command_args(result services_cli.CliActionResult) []string {
	return result.commands.map(it.args.join(' '))
}

// Ruby subject `subject(:services_cli) { described_class }` at line 12.
pub fn ruby_cli_spec_l12_d1_services_cli() string {
	return 'Homebrew::Services::Cli'
}

// Ruby let `let(:service_string) { "service" }` at line 14.
pub fn ruby_cli_spec_l14_d2_service_string() string {
	return 'service'
}

// Ruby it `it "outputs command name" do` at line 17.
pub fn ruby_cli_spec_l17_d3_outputs() bool {
	return services_cli.cli_bin() == 'brew services'
}

// Ruby it `it "macOS - returns the currently running services" do` at line 23.
pub fn ruby_cli_spec_l23_d4_macos() bool {
	system := services_cli.CliSystem{
		manager: .launchctl
		running_output: '77513   50  homebrew.mxcl.php\n495     0   homebrew.mxcl.node_exporter\n1234    34  homebrew.mxcl.postgresql@14\n'
	}
	return services_cli.cli_running(system) == ['homebrew.mxcl.php', 'homebrew.mxcl.node_exporter',
		'homebrew.mxcl.postgresql@14']
}

// Ruby it `it "systemD - returns the currently running services" do` at line 37.
pub fn ruby_cli_spec_l37_d5_systemd() bool {
	system := services_cli.CliSystem{
		manager: .systemctl
		running_output: 'homebrew.php.service     loaded active running Homebrew PHP service\nsystemd-udevd.service    loaded active running Rule-based Manager for Device Events and Files\nudisks2.service          loaded active running Disk Manager\nuser@1000.service        loaded active running User Manager for UID 1000\n'
	}
	return services_cli.cli_running(system) == ['homebrew.php']
}

// Ruby it `it "checks the input does not exist" do` at line 50.
pub fn ruby_cli_spec_l50_d6_checks() bool {
	services_cli.cli_check([]services_cli.CliService{}) or {
		return err.msg() == 'Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.'
	}
	return false
}

// Ruby it `it "checks the input exists" do` at line 57.
pub fn ruby_cli_spec_l57_d7_checks() bool {
	return services_cli.cli_check([
		services_cli.CliService{ name: 'name' },
	]) or {
		false
	}
}

// Ruby it `it "skips unmanaged services" do` at line 66.
pub fn ruby_cli_spec_l66_d8_skips() bool {
	mut state := services_cli.CliState{}
	system := services_cli.CliSystem{ running_labels: ['example_service'] }
	result := services_cli.ruby_cli_l56_d6_self_kill_orphaned_services(mut state, system, CliSpecResolver{ values: map[string]services_cli.CliResolvedService{} })
	return result.warnings == [
		'Warning: Service example_service not managed by `brew services` => skipping',
	]
}

// Ruby it `it "tries but is unable to kill a non existing service" do` at line 73.
pub fn ruby_cli_spec_l73_d9_tries() bool {
	mut state := services_cli.CliState{}
	service := services_cli.CliService{
		name: 'example_service'
		service_name: 'homebrew.example_service'
		dest: 'this_path_does_not_exist'
		pid_values: [true, true]
	}
	system := services_cli.CliSystem{ running_labels: ['example_service'] }
	result := services_cli.ruby_cli_l56_d6_self_kill_orphaned_services(mut state, system, CliSpecResolver{
		values: {
			'example_service': services_cli.CliResolvedService{ found: true, service: service }
		}
	})
	return result.stdout.contains('Killing `example_service`... (might take a while)')
}

// Ruby it `it "removes unused timer files" do` at line 92.
pub fn ruby_cli_spec_l92_d10_removes() !bool {
	directory := cli_spec_temp_dir('remove-unused')!
	defer { os.rmdir_all(directory) or {} }
	active := os.join_path(directory, 'homebrew.name.timer')
	stale := os.join_path(directory, 'homebrew.stale.timer')
	os.write_file(active, 'timer')!
	os.write_file(stale, 'timer')!
	result := services_cli.ruby_cli_l74_d7_self_remove_unused_service_files(services_cli.CliSystem{
		path: directory
		running_output: 'homebrew.name'
	})!
	return result.cleaned == [stale] && os.exists(active) && !os.exists(stale)
}

// Ruby it `it "checks missing file causes error" do` at line 110.
pub fn ruby_cli_spec_l110_d11_checks() bool {
	mut state := services_cli.CliState{}
	mut targets := [services_cli.CliService{ name: 'service_name' }]
	services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{ present: true, path: '/non/existent/path' }, false) or { return err.msg() == 'Invalid usage: Provided service file does not exist.' }
	return false
}

// Ruby it `it "checks empty targets cause no error" do` at line 118.
pub fn ruby_cli_spec_l118_d12_checks() !bool {
	mut state := services_cli.CliState{}
	mut targets := []services_cli.CliService{}
	result := services_cli.ruby_cli_l95_d8_self_run(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return result.stdout.len == 0 && result.commands.len == 0
}

// Ruby it `it "checks if target service is already running and suggests restart instead" do` at line 123.
pub fn ruby_cli_spec_l123_d13_checks() !bool {
	mut state := services_cli.CliState{}
	mut targets := [
		services_cli.CliService{ name: 'example_service', pid_values: [true] },
	]
	result := services_cli.ruby_cli_l95_d8_self_run(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return result.stdout == [
		'Service `example_service` already running, use `brew services restart example_service` to restart.',
	]
}

// Ruby it `it "checks missing file causes error" do` at line 134.
pub fn ruby_cli_spec_l134_d14_checks() bool {
	mut state := services_cli.CliState{}
	mut targets := [services_cli.CliService{ name: 'service_name' }]
	services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{
		present: true
		path: '/hfdkjshksdjhfkjsdhf/fdsjghsdkjhb'
	}, false) or { return err.msg() == 'Invalid usage: Provided service file does not exist.' }
	return false
}

// Ruby it `it "checks empty targets cause no error" do` at line 142.
pub fn ruby_cli_spec_l142_d15_checks() !bool {
	mut state := services_cli.CliState{}
	mut targets := []services_cli.CliService{}
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return result.commands.len == 0
}

// Ruby it `it "checks if target service has already been started and suggests restart instead" do` at line 147.
pub fn ruby_cli_spec_l147_d16_checks() !bool {
	mut state := services_cli.CliState{}
	mut targets := [
		services_cli.CliService{ name: 'example_service', pid_values: [true] },
	]
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return result.stdout == [
		'Service `example_service` already started, use `brew services restart example_service` to restart.',
	]
}

// Ruby let `let(:service) do` at line 157.
pub fn ruby_cli_spec_l157_d17_service() !services_cli.CliService {
	return cli_spec_service(cli_spec_temp_dir('start-service')!)
}

// Ruby it `it "loads service for root" do` at line 171.
pub fn ruby_cli_spec_l171_d18_loads() !bool {
	directory := cli_spec_temp_dir('start-root')!
	defer { os.rmdir_all(directory) or {} }
	mut state := services_cli.CliState{}
	mut service := cli_spec_service(directory)!
	service.install_handled_by_collaborator = true
	mut targets := [service]
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.systemctl, true), mut targets, services_cli.CliFileArgument{}, false)!
	return result.loaded && cli_spec_command_args(result).contains('start homebrew.name')
}

// Ruby it `it "loads service for non-root user" do` at line 178.
pub fn ruby_cli_spec_l178_d19_loads() !bool {
	directory := cli_spec_temp_dir('start-user')!
	defer { os.rmdir_all(directory) or {} }
	mut state := services_cli.CliState{}
	mut service := cli_spec_service(directory)!
	service.install_handled_by_collaborator = true
	mut targets := [service]
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return result.loaded && result.commands.any(it.args.len > 0 && it.args[0] == 'bootstrap')
}

// Ruby it `it "loads service for root when given `--sudo-service-user`" do` at line 185.
pub fn ruby_cli_spec_l185_d20_loads() !bool {
	directory := cli_spec_temp_dir('start-root-sudo-user')!
	defer { os.rmdir_all(directory) or {} }
	mut state := services_cli.CliState{ sudo_service_user: '_serviced' }
	mut service := cli_spec_service(directory)!
	service.install_handled_by_collaborator = true
	mut targets := [service]
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.systemctl, true), mut targets, services_cli.CliFileArgument{}, false)!
	return result.loaded
}

// Ruby it `it "does not load service for non-root user when given `--sudo-service-user`" do` at line 192.
pub fn ruby_cli_spec_l192_d21_does() !bool {
	directory := cli_spec_temp_dir('start-user-sudo-user')!
	defer { os.rmdir_all(directory) or {} }
	mut state := services_cli.CliState{ sudo_service_user: '_serviced' }
	mut service := cli_spec_service(directory)!
	service.install_handled_by_collaborator = true
	mut targets := [service]
	result := services_cli.ruby_cli_l122_d9_self_start(mut state, cli_spec_system(.launchctl, false), mut targets, services_cli.CliFileArgument{}, false)!
	return !result.loaded && !result.commands.any(it.args.len > 0 && it.args[0] == 'bootstrap')
}

// Ruby it `it "checks empty targets cause no error" do` at line 202.
pub fn ruby_cli_spec_l202_d22_checks() !bool {
	mut targets := []services_cli.CliService{}
	result := services_cli.ruby_cli_l174_d10_self_stop(cli_spec_system(.systemctl, false), mut targets, false, false, 0, false)!
	return result.commands.len == 0
}

// Ruby it `it "stops timed systemd timers before services when kept" do` at line 207.
pub fn ruby_cli_spec_l207_d23_stops() !bool {
	mut targets := [services_cli.CliService{
		name: 'name'
		service_name: 'homebrew.name'
		timed: true
		timer_file: '/tmp/homebrew.name.timer'
		loaded_values: [true, false]
	}]
	result := services_cli.ruby_cli_l174_d10_self_stop(cli_spec_system(.systemctl, false), mut targets, false, false, 0, true)!
	return cli_spec_command_args(result) == ['--user stop homebrew.name.timer',
		'--user stop homebrew.name'] && result.stdout.last().contains('Successfully stopped `name`')
}

// Ruby it `it "stops and removes timed systemd timer files" do` at line 232.
pub fn ruby_cli_spec_l232_d24_stops() !bool {
	directory := cli_spec_temp_dir('stop-timed')!
	defer { os.rmdir_all(directory) or {} }
	service_dest := os.join_path(directory, 'homebrew.name.service')
	timer_dest := os.join_path(directory, 'homebrew.name.timer')
	os.write_file(service_dest, 'service')!
	os.write_file(timer_dest, 'timer')!
	mut targets := [services_cli.CliService{
		name: 'name'
		service_name: 'homebrew.name'
		dest: service_dest
		timed: true
		timer_file: timer_dest
		timer_dest: timer_dest
		loaded_values: [true, false]
	}]
	result := services_cli.ruby_cli_l174_d10_self_stop(cli_spec_system(.systemctl, false), mut targets, false, false, 0, false)!
	return cli_spec_command_args(result)[..2] == [
		'--user disable --now homebrew.name.timer',
		'--user disable --now homebrew.name',
	] && !os.exists(timer_dest)
}

// Ruby it `it "checks empty targets cause no error" do` at line 267.
pub fn ruby_cli_spec_l267_d25_checks() bool {
	mut state := services_cli.CliState{}
	mut targets := []services_cli.CliService{}
	return services_cli.cli_kill(mut state, cli_spec_system(.systemctl, false), mut targets, false).commands.len == 0
}

// Ruby it `it "prints a message if service is not running" do` at line 272.
pub fn ruby_cli_spec_l272_d26_prints() bool {
	mut state := services_cli.CliState{}
	mut targets := [services_cli.CliService{ name: 'example_service' }]
	result := services_cli.cli_kill(mut state, cli_spec_system(.systemctl, false), mut targets, false)
	return result.stdout == ['Service `example_service` is not started.']
}

// Ruby it `it "prints a message if service is set to keep alive" do` at line 280.
pub fn ruby_cli_spec_l280_d27_prints() bool {
	mut state := services_cli.CliState{}
	mut targets := [services_cli.CliService{
		name: 'example_service'
		pid_values: [true]
		keep_alive: true
	}]
	result := services_cli.cli_kill(mut state, cli_spec_system(.systemctl, false), mut targets, false)
	return result.stdout == [
		"Service `example_service` is set to automatically restart and can't be killed.",
	]
}

// Ruby it `it "returns false when given non-root user" do` at line 290.
pub fn ruby_cli_spec_l290_d28_returns() bool {
	return !services_cli.cli_take_root_ownership(services_cli.CliState{}, cli_spec_system(.launchctl, false), services_cli.CliService{}).ownership_taken
}

// Ruby it `it "returns false when given `--sudo-service-user`" do` at line 296.
pub fn ruby_cli_spec_l296_d29_returns() bool {
	return !services_cli.cli_take_root_ownership(services_cli.CliState{
		sudo_service_user: '_serviced'
	}, cli_spec_system(.launchctl, true), services_cli.CliService{}).ownership_taken
}

// Ruby it `it "checks service is installed" do` at line 305.
pub fn ruby_cli_spec_l305_d30_checks() bool {
	services_cli.cli_install_service_file(services_cli.CliState{}, cli_spec_system(.launchctl, false), services_cli.CliService{ name: 'name' }, services_cli.CliFileArgument{}) or {
		return err.msg() == 'Invalid usage: Formula `name` is not installed.'
	}
	return false
}

// Ruby it `it "checks service file exists" do` at line 312.
pub fn ruby_cli_spec_l312_d31_checks() bool {
	services_cli.cli_install_service_file(services_cli.CliState{}, cli_spec_system(.launchctl, false), services_cli.CliService{
		name: 'name'
		installed: true
		service_file: '/does/not/exist'
	}, services_cli.CliFileArgument{}) or {
		return err.msg() == 'Invalid usage: Formula `name` has not implemented #plist, #service or provided a locatable service file.'
	}
	return false
}

// Ruby it `it "installs timed systemd timer files" do` at line 327.
pub fn ruby_cli_spec_l327_d32_installs() !bool {
	directory := cli_spec_temp_dir('install-timer')!
	defer { os.rmdir_all(directory) or {} }
	mut service := cli_spec_service(directory)!
	service.timed = true
	os.write_file(service.timer_file, 'timer')!
	result := services_cli.cli_install_service_file(services_cli.CliState{}, cli_spec_system(.systemctl, false), service, services_cli.CliFileArgument{})!
	return os.read_file(service.timer_dest)! == 'timer' && cli_spec_command_args(result).contains('--user daemon-reload')
}

// Ruby let `let(:dest_dir) { mktmpdir }` at line 357.
pub fn ruby_cli_spec_l357_d33_dest_dir() !string {
	return cli_spec_temp_dir('plist-dest')
}

// Ruby let `let(:plist_xml) do` at line 358.
pub fn ruby_cli_spec_l358_d34_plist_xml() string {
	return '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n  <key>Label</key>\n  <string>homebrew.test</string>\n  <key>ProgramArguments</key>\n  <array>\n    <string>/opt/homebrew/opt/test/bin/test</string>\n  </array>\n</dict>\n</plist>\n'
}

// Ruby let `let(:service) do` at line 374.
pub fn ruby_cli_spec_l374_d35_service() !services_cli.CliService {
	directory := cli_spec_temp_dir('plist-service')!
	source := os.join_path(directory, 'source', 'homebrew.test.plist')
	os.mkdir_all(os.dir(source))!
	contents := ruby_cli_spec_l358_d34_plist_xml()
	os.write_file(source, contents)!
	return services_cli.CliService{
		name: 'name'
		service_name: 'homebrew.test'
		formula_name: 'name'
		installed: true
		service_file: source
		service_contents: contents
		dest_dir: os.join_path(directory, 'dest')
		dest: os.join_path(directory, 'dest', 'homebrew.test.plist')
	}
}

// Ruby it `it "prints the given username" do` at line 395.
pub fn ruby_cli_spec_l395_d36_prints() !bool {
	service := ruby_cli_spec_l374_d35_service()!
	defer { os.rmdir_all(os.dir(os.dir(service.service_file))) or {} }
	result := services_cli.cli_install_service_file(services_cli.CliState{
		sudo_service_user: '_serviced'
	}, cli_spec_system(.launchctl, false), service, services_cli.CliFileArgument{})!
	return result.stdout == ['==> Setting username in homebrew.test to: _serviced']
}

// Ruby it `it "sets username in the generated plist" do` at line 401.
pub fn ruby_cli_spec_l401_d37_sets() !bool {
	service := ruby_cli_spec_l374_d35_service()!
	defer { os.rmdir_all(os.dir(os.dir(service.service_file))) or {} }
	services_cli.cli_install_service_file(services_cli.CliState{
		sudo_service_user: '_serviced'
	}, cli_spec_system(.launchctl, false), service, services_cli.CliFileArgument{})!
	contents := os.read_file(service.dest)!
	return contents.contains('<key>UserName</key>') && contents.contains('<string>_serviced</string>')
}

// Ruby let `let(:bindir) { mktmpdir }` at line 409.
pub fn ruby_cli_spec_l409_d38_bindir() !string {
	return cli_spec_temp_dir('systemctl-bin')
}

// Ruby let `let(:log) { bindir/"systemctl.log" }` at line 410.
pub fn ruby_cli_spec_l410_d39_log() !string {
	return os.join_path(ruby_cli_spec_l409_d38_bindir()!, 'systemctl.log')
}

// Ruby it `it "checks non-enabling run" do` at line 421.
pub fn ruby_cli_spec_l421_d40_checks() bool {
	result := services_cli.cli_systemd_load(cli_spec_system(.systemctl, false), services_cli.CliService{ service_name: 'name' }, false)
	return cli_spec_command_args(result) == ['--user start name']
}

// Ruby it `it "checks enabling run" do` at line 432.
pub fn ruby_cli_spec_l432_d41_checks() bool {
	result := services_cli.cli_systemd_load(cli_spec_system(.systemctl, false), services_cli.CliService{ service_name: 'name' }, true)
	return cli_spec_command_args(result) == ['--user start name', '--user enable name']
}

// Ruby it `it "checks enabling timed run" do` at line 446.
pub fn ruby_cli_spec_l446_d42_checks() bool {
	result := services_cli.cli_systemd_load(cli_spec_system(.systemctl, false), services_cli.CliService{
		service_name: 'name'
		timed: true
		timer_file: 'name.timer'
	}, true)
	return cli_spec_command_args(result) == ['--user start name', '--user start name.timer',
		'--user enable name.timer']
}

// Ruby let `let(:bindir) { mktmpdir }` at line 468.
pub fn ruby_cli_spec_l468_d43_bindir() !string {
	return cli_spec_temp_dir('launchctl-bin')
}

// Ruby let `let(:log) { bindir/"launchctl.log" }` at line 469.
pub fn ruby_cli_spec_l469_d44_log() !string {
	return os.join_path(ruby_cli_spec_l468_d43_bindir()!, 'launchctl.log')
}

// Ruby it `it "checks non-enabling run" do` at line 480.
pub fn ruby_cli_spec_l480_d45_checks() bool {
	result := services_cli.cli_launchctl_load(cli_spec_system(.launchctl, false), services_cli.CliService{}, 'a', false)
	return cli_spec_command_args(result) == ['bootstrap gui/501 a']
}

// Ruby it `it "checks enabling run" do` at line 488.
pub fn ruby_cli_spec_l488_d46_checks() bool {
	result := services_cli.cli_launchctl_load(cli_spec_system(.launchctl, false), services_cli.CliService{ service_name: 'name' }, 'a', true)
	return cli_spec_command_args(result) == ['enable gui/501/name', 'bootstrap gui/501 a']
}

// Ruby it `it "checks non-root for login" do` at line 503.
pub fn ruby_cli_spec_l503_d47_checks() !bool {
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{ name: 'name', service_name: 'service.name' }
	result := services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, true), mut service, services_cli.CliFileArgument{}, false)!
	return result.stdout == ['==> Successfully ran `name` (label: service.name)']
}

// Ruby it `it "checks root for startup" do` at line 522.
pub fn ruby_cli_spec_l522_d48_checks() !bool {
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{
		name: 'name'
		service_name: 'service.name'
		service_startup: true
	}
	result := services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, false), mut service, services_cli.CliFileArgument{}, false)!
	return result.stdout == ['==> Successfully ran `name` (label: service.name)']
}

// Ruby it `it "warns root for login without `--sudo-service-user`" do` at line 540.
pub fn ruby_cli_spec_l540_d49_warns() !bool {
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{ name: 'name', service_name: 'service.name' }
	result := services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, true), mut service, services_cli.CliFileArgument{}, true)!
	return result.warnings.contains('Warning: `name` must be run as non-root to start at user login!')
}

// Ruby it `it "does not warn root for login when given `--sudo-service-user`" do` at line 558.
pub fn ruby_cli_spec_l558_d50_does() !bool {
	mut state := services_cli.CliState{ sudo_service_user: '_serviced' }
	mut service := services_cli.CliService{ name: 'name', service_name: 'service.name' }
	result := services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, true), mut service, services_cli.CliFileArgument{}, true)!
	return !result.warnings.any(it.contains('must be run as non-root'))
}

// Ruby it `it "errors then exits when given a `--sudo-service-user` which does not exist" do` at line 578.
pub fn ruby_cli_spec_l578_d51_errors() bool {
	mut state := services_cli.CliState{ sudo_service_user: 'not_a_real_user' }
	mut service := services_cli.CliService{ name: 'name', service_name: 'service.name' }
	services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, true), mut service, services_cli.CliFileArgument{}, true) or {
		return err.msg() == 'Error: Cannot start `name` as `not_a_real_user` is not a user!'
	}
	return false
}

// Ruby it `it "continues loading when given a `--sudo-service-user` which exists" do` at line 596.
pub fn ruby_cli_spec_l596_d52_continues() !bool {
	mut state := services_cli.CliState{ sudo_service_user: '_serviced' }
	mut service := services_cli.CliService{ name: 'name', service_name: 'service.name' }
	result := services_cli.cli_service_load(mut state, cli_spec_system(.unavailable, true), mut service, services_cli.CliFileArgument{}, true)!
	return result.stdout == ['==> Successfully started `name` (label: service.name)']
}

// Ruby it `it "triggers launchctl" do` at line 618.
pub fn ruby_cli_spec_l618_d53_triggers() !bool {
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{
		name: 'name'
		service_name: 'service.name'
		service_file: 'service-file'
	}
	result := services_cli.cli_service_load(mut state, cli_spec_system(.launchctl, false), mut service, services_cli.CliFileArgument{}, false)!
	return result.commands.len == 1 && result.commands[0].args == ['bootstrap', 'gui/501',
		'service-file']
}

// Ruby it `it "creates service path directories before loading" do` at line 639.
pub fn ruby_cli_spec_l639_d54_creates() !bool {
	directory := cli_spec_temp_dir('path-dirs')!
	defer { os.rmdir_all(directory) or {} }
	paths := [os.join_path(directory, 'var', 'run'), os.join_path(directory, 'var', 'log')]
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{
		name: 'name'
		service_name: 'service.name'
		service_file: 'service-file'
		path_dirs: paths
	}
	services_cli.cli_service_load(mut state, cli_spec_system(.launchctl, false), mut service, services_cli.CliFileArgument{}, false)!
	return paths.all(os.is_dir(it))
}

// Ruby it `it "triggers systemctl" do` at line 668.
pub fn ruby_cli_spec_l668_d55_triggers() !bool {
	directory := cli_spec_temp_dir('systemctl-trigger')!
	defer { os.rmdir_all(directory) or {} }
	dest := os.join_path(directory, 'homebrew.name.service')
	os.write_file(dest, 'service')!
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{
		name: 'name'
		service_name: 'service.name'
		dest: dest
	}
	result := services_cli.cli_service_load(mut state, cli_spec_system(.systemctl, false), mut service, services_cli.CliFileArgument{}, false)!
	return cli_spec_command_args(result) == ['--user start service.name']
}

// Ruby it `it "represents correct action" do` at line 690.
pub fn ruby_cli_spec_l690_d56_represents() !bool {
	directory := cli_spec_temp_dir('systemctl-action')!
	defer { os.rmdir_all(directory) or {} }
	dest := os.join_path(directory, 'homebrew.name.service')
	os.write_file(dest, 'service')!
	mut state := services_cli.CliState{}
	mut service := services_cli.CliService{
		name: 'name'
		service_name: 'service.name'
		dest: dest
	}
	result := services_cli.cli_service_load(mut state, cli_spec_system(.systemctl, false), mut service, services_cli.CliFileArgument{}, true)!
	return cli_spec_command_args(result) == ['--user start service.name', '--user enable service.name'] && result.stdout == [
		'==> Successfully started `name` (label: service.name)',
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/cli"
// 5: require "services/system"
// 6: require "services/formula_wrapper"
// 7: require "test/support/helper/services"
// 8:
// 9: RSpec.describe Homebrew::Services::Cli do
// 10:   include Test::Helper::Services
// 11:
// 12:   subject(:services_cli) { described_class }
// 13:
// 14:   let(:service_string) { "service" }
// 15:
// 16:   describe "#bin" do
// 17:     it "outputs command name" do
// 18:       expect(services_cli.bin).to eq("brew services")
// 19:     end
// 20:   end
// 21:
// 22:   describe "#running" do
// 23:     it "macOS - returns the currently running services" do
// 24:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 25:       allow(Utils).to receive(:popen_read).and_return <<~EOS
// 26:         77513   50  homebrew.mxcl.php
// 27:         495     0   homebrew.mxcl.node_exporter
// 28:         1234    34  homebrew.mxcl.postgresql@14
// 29:       EOS
// 30:       expect(services_cli.running).to eq([
// 31:         "homebrew.mxcl.php",
// 32:         "homebrew.mxcl.node_exporter",
// 33:         "homebrew.mxcl.postgresql@14",
// 34:       ])
// 35:     end
// 36:
// 37:     it "systemD - returns the currently running services" do
// 38:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(false)
// 39:       allow(Homebrew::Services::System::Systemctl).to receive(:popen_read).and_return <<~EOS
// 40:         homebrew.php.service     loaded active running Homebrew PHP service
// 41:         systemd-udevd.service    loaded active running Rule-based Manager for Device Events and Files
// 42:         udisks2.service          loaded active running Disk Manager
// 43:         user@1000.service        loaded active running User Manager for UID 1000
// 44:       EOS
// 45:       expect(services_cli.running).to eq(["homebrew.php"])
// 46:     end
// 47:   end
// 48:
// 49:   describe "#check!" do
// 50:     it "checks the input does not exist" do
// 51:       expect do
// 52:         services_cli.check!([])
// 53:       end.to raise_error(UsageError,
// 54:                          "Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.")
// 55:     end
// 56:
// 57:     it "checks the input exists" do
// 58:       service = instance_double(Homebrew::Services::FormulaWrapper, name: "name", installed?: false)
// 59:       expect do
// 60:         services_cli.check!([service])
// 61:       end.not_to raise_error
// 62:     end
// 63:   end
// 64:
// 65:   describe "#kill_orphaned_services" do
// 66:     it "skips unmanaged services" do
// 67:       allow(services_cli).to receive(:running).and_return(["example_service"])
// 68:       expect do
// 69:         services_cli.kill_orphaned_services
// 70:       end.to output("Warning: Service example_service not managed by `brew services` => skipping\n").to_stderr
// 71:     end
// 72:
// 73:     it "tries but is unable to kill a non existing service" do
// 74:       service = instance_double(
// 75:         service_string,
// 76:         name:         "example_service",
// 77:         service_name: "homebrew.example_service",
// 78:         pid?:         true,
// 79:         dest:         Pathname("this_path_does_not_exist"),
// 80:         keep_alive?:  false,
// 81:       )
// 82:       allow(service).to receive(:reset_cache!)
// 83:       allow(Homebrew::Services::FormulaWrapper).to receive(:from).and_return(service)
// 84:       allow(services_cli).to receive(:running).and_return(["example_service"])
// 85:       expect do
// 86:         services_cli.kill_orphaned_services
// 87:       end.to output("Killing `example_service`... (might take a while)\n").to_stdout
// 88:     end
// 89:   end
// 90:
// 91:   describe "#remove_unused_service_files" do
// 92:     it "removes unused timer files" do
// 93:       path = mktmpdir
// 94:       active_timer = path/"homebrew.name.timer"
// 95:       stale_timer = path/"homebrew.stale.timer"
// 96:       active_timer.write("timer")
// 97:       stale_timer.write("timer")
// 98:       allow(Homebrew::Services::System).to receive(:path).and_return(path)
// 99:       allow(services_cli).to receive(:running).and_return(["homebrew.name"])
// 100:
// 101:       expect do
// 102:         expect(services_cli.remove_unused_service_files).to eq([stale_timer.to_s])
// 103:       end.to output("Removing unused service file: #{stale_timer}\n").to_stdout
// 104:       expect(active_timer).to exist
// 105:       expect(stale_timer).not_to exist
// 106:     end
// 107:   end
// 108:
// 109:   describe "#run" do
// 110:     it "checks missing file causes error" do
// 111:       expect(Homebrew::Services::System).not_to receive(:root?)
// 112:       service = instance_double(Homebrew::Services::FormulaWrapper, name: "service_name")
// 113:       expect do
// 114:         services_cli.start([service], "/non/existent/path")
// 115:       end.to raise_error(UsageError, "Invalid usage: Provided service file does not exist.")
// 116:     end
// 117:
// 118:     it "checks empty targets cause no error" do
// 119:       expect(Homebrew::Services::System).not_to receive(:root?)
// 120:       services_cli.run([])
// 121:     end
// 122:
// 123:     it "checks if target service is already running and suggests restart instead" do
// 124:       expected_output = "Service `example_service` already running, " \
// 125:                         "use `brew services restart example_service` to restart.\n"
// 126:       service = instance_double(service_string, name: "example_service", pid?: true)
// 127:       expect do
// 128:         services_cli.run([service])
// 129:       end.to output(expected_output).to_stdout
// 130:     end
// 131:   end
// 132:
// 133:   describe "#start" do
// 134:     it "checks missing file causes error" do
// 135:       expect(Homebrew::Services::System).not_to receive(:root?)
// 136:       service = instance_double(Homebrew::Services::FormulaWrapper, name: "service_name")
// 137:       expect do
// 138:         services_cli.start([service], "/hfdkjshksdjhfkjsdhf/fdsjghsdkjhb")
// 139:       end.to raise_error(UsageError, "Invalid usage: Provided service file does not exist.")
// 140:     end
// 141:
// 142:     it "checks empty targets cause no error" do
// 143:       expect(Homebrew::Services::System).not_to receive(:root?)
// 144:       services_cli.start([])
// 145:     end
// 146:
// 147:     it "checks if target service has already been started and suggests restart instead" do
// 148:       expected_output = "Service `example_service` already started, " \
// 149:                         "use `brew services restart example_service` to restart.\n"
// 150:       service = instance_double(service_string, name: "example_service", pid?: true)
// 151:       expect do
// 152:         services_cli.start([service])
// 153:       end.to output(expected_output).to_stdout
// 154:     end
// 155:
// 156:     context "when deciding whether to load target service" do
// 157:       let(:service) do
// 158:         instance_double(
// 159:           Homebrew::Services::FormulaWrapper,
// 160:           name:         "name",
// 161:           pid?:         false,
// 162:           installed?:   true,
// 163:           service_file: instance_double(Pathname, exist?: true),
// 164:         )
// 165:       end
// 166:
// 167:       before do
// 168:         allow(services_cli).to receive(:install_service_file)
// 169:       end
// 170:
// 171:       it "loads service for root" do
// 172:         allow(Homebrew::Services::System).to receive(:root?).and_return(true)
// 173:         allow(services_cli).to receive(:take_root_ownership?).and_return(true)
// 174:         expect(services_cli).to receive(:service_load).with(service, nil, enable: true)
// 175:         services_cli.start([service])
// 176:       end
// 177:
// 178:       it "loads service for non-root user" do
// 179:         allow(Homebrew::Services::System).to receive(:root?).and_return(false)
// 180:         allow(services_cli).to receive(:take_root_ownership?).and_return(false)
// 181:         expect(services_cli).to receive(:service_load).with(service, nil, enable: true)
// 182:         services_cli.start([service])
// 183:       end
// 184:
// 185:       it "loads service for root when given `--sudo-service-user`" do
// 186:         allow(Homebrew::Services::System).to receive(:root?).and_return(true)
// 187:         allow(services_cli).to receive_messages(sudo_service_user: "_serviced", take_root_ownership?: false)
// 188:         expect(services_cli).to receive(:service_load).with(service, nil, enable: true)
// 189:         services_cli.start([service])
// 190:       end
// 191:
// 192:       it "does not load service for non-root user when given `--sudo-service-user`" do
// 193:         allow(Homebrew::Services::System).to receive(:root?).and_return(false)
// 194:         allow(services_cli).to receive_messages(sudo_service_user: "_serviced", take_root_ownership?: false)
// 195:         expect(services_cli).not_to receive(:service_load)
// 196:         services_cli.start([service])
// 197:       end
// 198:     end
// 199:   end
// 200:
// 201:   describe "#stop" do
// 202:     it "checks empty targets cause no error" do
// 203:       expect(Homebrew::Services::System).not_to receive(:root?)
// 204:       services_cli.stop([])
// 205:     end
// 206:
// 207:     it "stops timed systemd timers before services when kept" do
// 208:       allow(Homebrew::Services::System).to receive(:systemctl?).and_return(true)
// 209:       expect(Homebrew::Services::System::Systemctl).to receive(:quiet_run)
// 210:         .with("stop", "homebrew.name.timer")
// 211:         .ordered
// 212:         .and_return(true)
// 213:       expect(Homebrew::Services::System::Systemctl).to receive(:quiet_run)
// 214:         .with("stop", "homebrew.name")
// 215:         .ordered
// 216:         .and_return(true)
// 217:       service = instance_double(
// 218:         Homebrew::Services::FormulaWrapper,
// 219:         name:         "name",
// 220:         service_name: "homebrew.name",
// 221:         timed?:       true,
// 222:         timer_name:   "homebrew.name.timer",
// 223:         pid?:         false,
// 224:       )
// 225:       allow(service).to receive(:loaded?).and_return(true, false)
// 226:
// 227:       expect do
// 228:         services_cli.stop([service], keep: true)
// 229:       end.to output(/Successfully stopped `name`/).to_stdout
// 230:     end
// 231:
// 232:     it "stops and removes timed systemd timer files" do
// 233:       allow(Homebrew::Services::System).to receive(:systemctl?).and_return(true)
// 234:       expect(Homebrew::Services::System::Systemctl).to receive(:quiet_run)
// 235:         .with("disable", "--now", "homebrew.name.timer")
// 236:         .and_return(true)
// 237:       expect(Homebrew::Services::System::Systemctl).to receive(:quiet_run)
// 238:         .with("disable", "--now", "homebrew.name")
// 239:         .and_return(true)
// 240:       expect(Homebrew::Services::System::Systemctl).to receive(:run).with("daemon-reload")
// 241:
// 242:       dest_dir = mktmpdir
// 243:       service_dest = dest_dir/"homebrew.name.service"
// 244:       timer_dest = dest_dir/"homebrew.name.timer"
// 245:       service_dest.write("service")
// 246:       timer_dest.write("timer")
// 247:       service = instance_double(
// 248:         Homebrew::Services::FormulaWrapper,
// 249:         name:         "name",
// 250:         service_name: "homebrew.name",
// 251:         dest:         service_dest,
// 252:         timed?:       true,
// 253:         timer_name:   "homebrew.name.timer",
// 254:         timer_dest:,
// 255:         pid?:         false,
// 256:       )
// 257:       allow(service).to receive(:loaded?).and_return(true, false)
// 258:
// 259:       expect do
// 260:         services_cli.stop([service])
// 261:       end.to output(/Successfully stopped `name`/).to_stdout
// 262:       expect(timer_dest).not_to exist
// 263:     end
// 264:   end
// 265:
// 266:   describe "#kill" do
// 267:     it "checks empty targets cause no error" do
// 268:       expect(Homebrew::Services::System).not_to receive(:root?)
// 269:       services_cli.kill([])
// 270:     end
// 271:
// 272:     it "prints a message if service is not running" do
// 273:       expected_output = "Service `example_service` is not started.\n"
// 274:       service = instance_double(service_string, name: "example_service", pid?: false)
// 275:       expect do
// 276:         services_cli.kill([service])
// 277:       end.to output(expected_output).to_stdout
// 278:     end
// 279:
// 280:     it "prints a message if service is set to keep alive" do
// 281:       expected_output = "Service `example_service` is set to automatically restart and can't be killed.\n"
// 282:       service = instance_double(service_string, name: "example_service", pid?: true, keep_alive?: true)
// 283:       expect do
// 284:         services_cli.kill([service])
// 285:       end.to output(expected_output).to_stdout
// 286:     end
// 287:   end
// 288:
// 289:   describe "#take_root_ownership?" do
// 290:     it "returns false when given non-root user" do
// 291:       allow(Homebrew::Services::System).to receive(:root?).and_return(false)
// 292:       service = instance_double(Homebrew::Services::FormulaWrapper)
// 293:       expect(services_cli.take_root_ownership?(service)).to be(false)
// 294:     end
// 295:
// 296:     it "returns false when given `--sudo-service-user`" do
// 297:       allow(Homebrew::Services::System).to receive(:root?).and_return(true)
// 298:       allow(services_cli).to receive(:sudo_service_user).and_return("_serviced")
// 299:       service = instance_double(Homebrew::Services::FormulaWrapper)
// 300:       expect(services_cli.take_root_ownership?(service)).to be(false)
// 301:     end
// 302:   end
// 303:
// 304:   describe "#install_service_file" do
// 305:     it "checks service is installed" do
// 306:       service = instance_double(Homebrew::Services::FormulaWrapper, name: "name", installed?: false)
// 307:       expect do
// 308:         services_cli.install_service_file(service, nil)
// 309:       end.to raise_error(UsageError, "Invalid usage: Formula `name` is not installed.")
// 310:     end
// 311:
// 312:     it "checks service file exists" do
// 313:       service = instance_double(
// 314:         Homebrew::Services::FormulaWrapper,
// 315:         name:         "name",
// 316:         installed?:   true,
// 317:         service_file: instance_double(Pathname, exist?: false),
// 318:       )
// 319:       expect do
// 320:         services_cli.install_service_file(service, nil)
// 321:       end.to raise_error(
// 322:         UsageError,
// 323:         "Invalid usage: Formula `name` has not implemented #plist, #service or provided a locatable service file.",
// 324:       )
// 325:     end
// 326:
// 327:     it "installs timed systemd timer files" do
// 328:       allow(Homebrew::Services::System).to receive(:systemctl?).and_return(true)
// 329:       allow(Homebrew::Services::System::Systemctl).to receive(:run).with("daemon-reload")
// 330:
// 331:       source_dir = mktmpdir
// 332:       dest_dir = mktmpdir
// 333:       service_file = source_dir/"homebrew.name.service"
// 334:       timer_file = source_dir/"homebrew.name.timer"
// 335:       service_file.write("service")
// 336:       timer_file.write("timer")
// 337:       service = instance_double(
// 338:         Homebrew::Services::FormulaWrapper,
// 339:         name:             "name",
// 340:         service_name:     "homebrew.name",
// 341:         installed?:       true,
// 342:         service_file:,
// 343:         service_contents: "service",
// 344:         dest:             dest_dir/service_file.basename,
// 345:         dest_dir:,
// 346:         timed?:           true,
// 347:         timer_file:,
// 348:         timer_dest:       dest_dir/timer_file.basename,
// 349:       )
// 350:
// 351:       services_cli.install_service_file(service, nil)
// 352:
// 353:       expect(service.timer_dest.read).to eq("timer")
// 354:     end
// 355:
// 356:     context "when given `--sudo-service-user`" do
// 357:       let(:dest_dir) { mktmpdir }
// 358:       let(:plist_xml) do
// 359:         <<~XML
// 360:           <?xml version="1.0" encoding="UTF-8"?>
// 361:           <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 362:           <plist version="1.0">
// 363:           <dict>
// 364:             <key>Label</key>
// 365:             <string>homebrew.test</string>
// 366:             <key>ProgramArguments</key>
// 367:             <array>
// 368:               <string>/opt/homebrew/opt/test/bin/test</string>
// 369:             </array>
// 370:           </dict>
// 371:           </plist>
// 372:         XML
// 373:       end
// 374:       let(:service) do
// 375:         source_dir = mktmpdir
// 376:         service_file = source_dir/"homebrew.test.plist"
// 377:         service_file.write(plist_xml)
// 378:         instance_double(
// 379:           Homebrew::Services::FormulaWrapper,
// 380:           name:             "name",
// 381:           service_name:     "homebrew.test",
// 382:           installed?:       true,
// 383:           service_file:,
// 384:           service_contents: plist_xml,
// 385:           dest:             dest_dir/"homebrew.test.plist",
// 386:           dest_dir:,
// 387:         )
// 388:       end
// 389:
// 390:       before do
// 391:         allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 392:         allow(services_cli).to receive(:sudo_service_user).and_return("_serviced")
// 393:       end
// 394:
// 395:       it "prints the given username" do
// 396:         expect do
// 397:           services_cli.install_service_file(service, nil)
// 398:         end.to output(/Setting username in homebrew\.test to: _serviced/).to_stdout
// 399:       end
// 400:
// 401:       it "sets username in the generated plist" do
// 402:         services_cli.install_service_file(service, nil)
// 403:         expect(service.dest.read).to include("<key>UserName</key>", "<string>_serviced</string>")
// 404:       end
// 405:     end
// 406:   end
// 407:
// 408:   describe "#systemd_load" do
// 409:     let(:bindir) { mktmpdir }
// 410:     let(:log) { bindir/"systemctl.log" }
// 411:
// 412:     before do
// 413:       (bindir/"systemctl").write <<~SH
// 414:         #!/bin/sh
// 415:         printf '%s\\n' "$*" >> "#{log}"
// 416:       SH
// 417:       (bindir/"systemctl").chmod 0755
// 418:       reset_services_memoization!
// 419:     end
// 420:
// 421:     it "checks non-enabling run" do
// 422:       with_env(PATH: bindir.to_s) do
// 423:         services_cli.systemd_load(
// 424:           instance_double(Homebrew::Services::FormulaWrapper, service_name: "name", timed?: false),
// 425:           enable: false,
// 426:         )
// 427:       end
// 428:
// 429:       expect(log.read).to eq("--user start name\n")
// 430:     end
// 431:
// 432:     it "checks enabling run" do
// 433:       with_env(PATH: bindir.to_s) do
// 434:         services_cli.systemd_load(
// 435:           instance_double(Homebrew::Services::FormulaWrapper, service_name: "name", timed?: false),
// 436:           enable: true,
// 437:         )
// 438:       end
// 439:
// 440:       expect(log.read).to eq <<~EOS
// 441:         --user start name
// 442:         --user enable name
// 443:       EOS
// 444:     end
// 445:
// 446:     it "checks enabling timed run" do
// 447:       with_env(PATH: bindir.to_s) do
// 448:         services_cli.systemd_load(
// 449:           instance_double(
// 450:             Homebrew::Services::FormulaWrapper,
// 451:             service_name: "name",
// 452:             timed?:       true,
// 453:             timer_name:   "name.timer",
// 454:           ),
// 455:           enable: true,
// 456:         )
// 457:       end
// 458:
// 459:       expect(log.read).to eq <<~EOS
// 460:         --user start name
// 461:         --user start name.timer
// 462:         --user enable name.timer
// 463:       EOS
// 464:     end
// 465:   end
// 466:
// 467:   describe "#launchctl_load" do
// 468:     let(:bindir) { mktmpdir }
// 469:     let(:log) { bindir/"launchctl.log" }
// 470:
// 471:     before do
// 472:       (bindir/"launchctl").write <<~SH
// 473:         #!/bin/sh
// 474:         printf '%s\\n' "$*" >> "#{log}"
// 475:       SH
// 476:       (bindir/"launchctl").chmod 0755
// 477:       reset_services_memoization!
// 478:     end
// 479:
// 480:     it "checks non-enabling run" do
// 481:       with_env(PATH: bindir.to_s) do
// 482:         services_cli.launchctl_load(instance_double(Homebrew::Services::FormulaWrapper), file: "a", enable: false)
// 483:       end
// 484:
// 485:       expect(log.read).to eq("bootstrap #{Homebrew::Services::System.domain_target} a\n")
// 486:     end
// 487:
// 488:     it "checks enabling run" do
// 489:       with_env(PATH: bindir.to_s) do
// 490:         services_cli.launchctl_load(instance_double(Homebrew::Services::FormulaWrapper, service_name: "name"),
// 491:                                     file:   "a",
// 492:                                     enable: true)
// 493:       end
// 494:
// 495:       expect(log.read).to eq <<~EOS
// 496:         enable #{Homebrew::Services::System.domain_target}/name
// 497:         bootstrap #{Homebrew::Services::System.domain_target} a
// 498:       EOS
// 499:     end
// 500:   end
// 501:
// 502:   describe "#service_load" do
// 503:     it "checks non-root for login" do
// 504:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 505:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(false)
// 506:       expect(Homebrew::Services::System).to receive(:root?).once.and_return(true)
// 507:
// 508:       expect do
// 509:         services_cli.service_load(
// 510:           instance_double(
// 511:             Homebrew::Services::FormulaWrapper,
// 512:             name:             "name",
// 513:             service_name:     "service.name",
// 514:             service_startup?: false,
// 515:           ),
// 516:           nil,
// 517:           enable: false,
// 518:         )
// 519:       end.to output("==> Successfully ran `name` (label: service.name)\n").to_stdout
// 520:     end
// 521:
// 522:     it "checks root for startup" do
// 523:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 524:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(false)
// 525:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(false)
// 526:       expect do
// 527:         services_cli.service_load(
// 528:           instance_double(
// 529:             Homebrew::Services::FormulaWrapper,
// 530:             name:             "name",
// 531:             service_name:     "service.name",
// 532:             service_startup?: true,
// 533:           ),
// 534:           nil,
// 535:           enable: false,
// 536:         )
// 537:       end.to output("==> Successfully ran `name` (label: service.name)\n").to_stdout
// 538:     end
// 539:
// 540:     it "warns root for login without `--sudo-service-user`" do
// 541:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 542:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(false)
// 543:       expect(Homebrew::Services::System).to receive(:root?).once.and_return(true)
// 544:       expect do
// 545:         services_cli.service_load(
// 546:           instance_double(
// 547:             Homebrew::Services::FormulaWrapper,
// 548:             name:             "name",
// 549:             service_name:     "service.name",
// 550:             service_startup?: false,
// 551:           ),
// 552:           nil,
// 553:           enable: true,
// 554:         )
// 555:       end.to output(/`name` must be run as non-root to start at user login!/).to_stderr
// 556:     end
// 557:
// 558:     it "does not warn root for login when given `--sudo-service-user`" do
// 559:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 560:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(false)
// 561:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(true)
// 562:       allow(services_cli).to receive(:sudo_service_user).and_return("_serviced")
// 563:       allow(Homebrew::Services::System).to receive(:user_exists?).with("_serviced").and_return(true)
// 564:       expect do
// 565:         services_cli.service_load(
// 566:           instance_double(
// 567:             Homebrew::Services::FormulaWrapper,
// 568:             name:             "name",
// 569:             service_name:     "service.name",
// 570:             service_startup?: false,
// 571:           ),
// 572:           nil,
// 573:           enable: true,
// 574:         )
// 575:       end.not_to output(/must be run as non-root to start at user login!/).to_stderr
// 576:     end
// 577:
// 578:     it "errors then exits when given a `--sudo-service-user` which does not exist" do
// 579:       allow(services_cli).to receive(:sudo_service_user).and_return("not_a_real_user")
// 580:       expect(Homebrew::Services::System).to receive(:user_exists?).with("not_a_real_user").and_return(false)
// 581:       expect do
// 582:         services_cli.service_load(
// 583:           instance_double(
// 584:             Homebrew::Services::FormulaWrapper,
// 585:             name:             "name",
// 586:             service_name:     "service.name",
// 587:             service_startup?: false,
// 588:           ),
// 589:           nil,
// 590:           enable: true,
// 591:         )
// 592:       end.to output(/Error: Cannot start `name` as `not_a_real_user` is not a user!/).to_stderr
// 593:                                                                                      .and raise_error(SystemExit)
// 594:     end
// 595:
// 596:     it "continues loading when given a `--sudo-service-user` which exists" do
// 597:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 598:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(false)
// 599:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(true)
// 600:       allow(services_cli).to receive(:sudo_service_user).and_return("_serviced")
// 601:       expect(Homebrew::Services::System).to receive(:user_exists?).with("_serviced").and_return(true)
// 602:       expect do
// 603:         services_cli.service_load(
// 604:           instance_double(
// 605:             Homebrew::Services::FormulaWrapper,
// 606:             name:             "name",
// 607:             service_name:     "service.name",
// 608:             service_startup?: false,
// 609:             service_file:     instance_double(Pathname, exist?: false),
// 610:             path_dirs:        [],
// 611:           ),
// 612:           nil,
// 613:           enable: true,
// 614:         )
// 615:       end.to output("==> Successfully started `name` (label: service.name)\n").to_stdout
// 616:     end
// 617:
// 618:     it "triggers launchctl" do
// 619:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(true)
// 620:       expect(Homebrew::Services::System).not_to receive(:systemctl?)
// 621:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(false)
// 622:       expect(described_class).to receive(:launchctl_load).once.and_return(true)
// 623:       expect do
// 624:         services_cli.service_load(
// 625:           instance_double(
// 626:             Homebrew::Services::FormulaWrapper,
// 627:             name:             "name",
// 628:             service_name:     "service.name",
// 629:             service_startup?: false,
// 630:             service_file:     instance_double(Pathname, exist?: false),
// 631:             path_dirs:        [],
// 632:           ),
// 633:           nil,
// 634:           enable: false,
// 635:         )
// 636:       end.to output("==> Successfully ran `name` (label: service.name)\n").to_stdout
// 637:     end
// 638:
// 639:     it "creates service path directories before loading" do
// 640:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(true)
// 641:       expect(Homebrew::Services::System).not_to receive(:systemctl?)
// 642:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(false)
// 643:
// 644:       path_dirs = [
// 645:         mktmpdir/"var/run",
// 646:         mktmpdir/"var/log",
// 647:       ]
// 648:       expect(described_class).to receive(:launchctl_load).once do
// 649:         expect(path_dirs).to all(be_a_directory)
// 650:       end
// 651:
// 652:       expect do
// 653:         services_cli.service_load(
// 654:           instance_double(
// 655:             Homebrew::Services::FormulaWrapper,
// 656:             name:             "name",
// 657:             service_name:     "service.name",
// 658:             service_startup?: false,
// 659:             service_file:     instance_double(Pathname, exist?: false),
// 660:             path_dirs:,
// 661:           ),
// 662:           nil,
// 663:           enable: false,
// 664:         )
// 665:       end.to output("==> Successfully ran `name` (label: service.name)\n").to_stdout
// 666:     end
// 667:
// 668:     it "triggers systemctl" do
// 669:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 670:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(true)
// 671:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(false)
// 672:       expect(Homebrew::Services::System::Systemctl).to receive(:run).once.and_return(true)
// 673:       expect do
// 674:         services_cli.service_load(
// 675:           instance_double(
// 676:             Homebrew::Services::FormulaWrapper,
// 677:             name:             "name",
// 678:             service_name:     "service.name",
// 679:             service_startup?: false,
// 680:             dest:             instance_double(Pathname, exist?: true),
// 681:             timed?:           false,
// 682:             path_dirs:        [],
// 683:           ),
// 684:           nil,
// 685:           enable: false,
// 686:         )
// 687:       end.to output("==> Successfully ran `name` (label: service.name)\n").to_stdout
// 688:     end
// 689:
// 690:     it "represents correct action" do
// 691:       expect(Homebrew::Services::System).to receive(:launchctl?).once.and_return(false)
// 692:       expect(Homebrew::Services::System).to receive(:systemctl?).once.and_return(true)
// 693:       expect(Homebrew::Services::System).to receive(:root?).twice.and_return(false)
// 694:       expect(Homebrew::Services::System::Systemctl).to receive(:run).twice.and_return(true)
// 695:       expect do
// 696:         services_cli.service_load(
// 697:           instance_double(
// 698:             Homebrew::Services::FormulaWrapper,
// 699:             name:             "name",
// 700:             service_name:     "service.name",
// 701:             service_startup?: false,
// 702:             dest:             instance_double(Pathname, exist?: true),
// 703:             timed?:           false,
// 704:             path_dirs:        [],
// 705:           ),
// 706:           nil,
// 707:           enable: true,
// 708:         )
// 709:       end.to output("==> Successfully started `name` (label: service.name)\n").to_stdout
// 710:     end
// 711:   end
// 712: end
