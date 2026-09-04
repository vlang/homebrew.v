module mac

import ruby
import os

// Translated from Homebrew/brew `extend/os/mac/test_bot.rb`.
pub struct MacTestBotSystem {
pub:
	version        string
	pretty_version string
	arch           string = 'x86_64'
}

pub struct MacTestBotCleanupTarget {
pub:
	paths []string
	sudo  bool
}

pub fn mac_test_bot_runner_os_title(system MacTestBotSystem) string {
	mut title := 'macOS ${system.pretty_version} (${system.version})'
	if system.arch in ['arm64', 'arm', 'aarch64'] {
		title += ' on Apple Silicon'
	}
	return title
}

pub fn mac_test_bot_previous_run_artifact_specifier(system MacTestBotSystem) string {
	return '{macos-${system.version},${system.version}-${system.arch}}'
}

fn mac_test_bot_version_at_least_catalina(version string) bool {
	parts := version.split('.').map(it.int())
	if parts.len == 0 {
		return false
	}
	return parts[0] > 10 || (parts[0] == 10 && parts.len > 1 && parts[1] >= 15)
}

pub fn mac_test_bot_should_setup_bottle_sudo_purge(version string,
	only_json_tab bool) bool {
	return mac_test_bot_version_at_least_catalina(version) && !only_json_tab
}

pub fn mac_test_bot_integration_test_portable_ruby(portable_ruby_version string,
	formula_package_version string) bool {
	return portable_ruby_version.trim_space() != formula_package_version
}

pub fn mac_test_bot_skip_recursive_dependents(super_skips bool, arch string) bool {
	return super_skips || arch in ['x86_64', 'intel']
}

pub fn mac_test_bot_cleanup_targets(cellar string, caskroom string) []MacTestBotCleanupTarget {
	return [
		MacTestBotCleanupTarget{
			paths: [ruby.join_path(cellar, '*')]
		},
		MacTestBotCleanupTarget{
			paths: [ruby.join_path(caskroom, 'session-manager-plugin')]
		},
		MacTestBotCleanupTarget{
			paths: ['Mono.framework', 'PluginManager.framework', 'Python.framework', 'R.framework',
				'Xamarin.Android.framework', 'Xamarin.Mac.framework', 'Xamarin.iOS.framework'].map(ruby.join_path('/Library/Frameworks', it))
			sudo: true
		},
	]
}

fn mac_test_bot_system_from_value(value ruby.Value) MacTestBotSystem {
	return MacTestBotSystem{
		version: value.attributes['version'] or { value.repr }
		pretty_version: value.attributes['pretty_version'] or { value.repr }
		arch: value.attributes['arch'] or { 'x86_64' }
	}
}

fn mac_test_bot_cleanup_value(targets []MacTestBotCleanupTarget) ruby.Value {
	return ruby.array_value(targets.map(ruby.structured_value('DeleteOrMove', it.paths.str(), {
		'paths': it.paths.join('\n')
		'sudo':  it.sudo.str()
	})))
}

// Ruby method `runner_os_title` at line 13.
pub fn ruby_test_bot_l13_d1_runner_os_title(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('runner_os_title requires system context')
	}
	return ruby.string_value(mac_test_bot_runner_os_title(mac_test_bot_system_from_value(args[0])))
}
