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

// Ruby method `previous_run_artifact_specifier` at line 27.
pub fn ruby_test_bot_l27_d2_previous_run_artifact_specifier(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('previous_run_artifact_specifier requires system context')
	}
	return ruby.string_value(mac_test_bot_previous_run_artifact_specifier(mac_test_bot_system_from_value(args[0])))
}

// Ruby method `setup_bottle_sudo_purge!(args:)` at line 38.
pub fn ruby_test_bot_l38_d3_setup_bottle_sudo_purge(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('setup_bottle_sudo_purge! requires arguments')
	}
	version := args[0].attributes['version'] or { args[0].repr }
	only_json_tab := (args[0].attributes['only_json_tab'] or { 'false' }) == 'true'
	set := mac_test_bot_should_setup_bottle_sudo_purge(version, only_json_tab)
	if set {
		os.setenv('HOMEBREW_BOTTLE_SUDO_PURGE', '1', true)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `integration_test_portable_ruby?` at line 45.
pub fn ruby_test_bot_l45_d4_integration_test_portable_ruby(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('integration_test_portable_ruby? requires installed and formula versions')
	}
	return ruby.bool_value(mac_test_bot_integration_test_portable_ruby(args[0].repr, args[1].repr))
}

// Ruby method `skip_recursive_dependents?(_formula, args:)` at line 58.
pub fn ruby_test_bot_l58_d5_skip_recursive_dependents(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('skip_recursive_dependents? requires super result and architecture')
	}
	return ruby.bool_value(mac_test_bot_skip_recursive_dependents(args[0].bool_data, args[1].repr))
}

// Ruby method `cleanup_github_actions_hosted_runner` at line 69.
pub fn ruby_test_bot_l69_d6_cleanup_github_actions_hosted_runner(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('cleanup_github_actions_hosted_runner requires cellar and caskroom')
	}
	return mac_test_bot_cleanup_value(mac_test_bot_cleanup_targets(args[0].repr, args[1].repr))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module TestBot
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { T.class_of(::Homebrew::TestBot) }
// 11:
// 12:         sig { returns(String) }
// 13:         def runner_os_title
// 14:           title = "macOS #{MacOS.version.pretty_name} (#{MacOS.version})"
// 15:           title << " on Apple Silicon" if ::Hardware::CPU.arm?
// 16:
// 17:           title
// 18:         end
// 19:       end
// 20:
// 21:       module TestFormulae
// 22:         extend T::Helpers
// 23:
// 24:         requires_ancestor { ::Homebrew::TestBot::TestFormulae }
// 25:
// 26:         sig { returns(String) }
// 27:         def previous_run_artifact_specifier
// 28:           "{macos-#{MacOS.version},#{MacOS.version}-#{::Hardware::CPU.arch}}"
// 29:         end
// 30:       end
// 31:
// 32:       module Formulae
// 33:         extend T::Helpers
// 34:
// 35:         requires_ancestor { ::Homebrew::TestBot::Formulae }
// 36:
// 37:         sig { params(args: ::Homebrew::Cmd::TestBotCmd::Args).void }
// 38:         def setup_bottle_sudo_purge!(args:)
// 39:           # This is needed where sparse files may be handled (bsdtar >=3.0).
// 40:           # We use gnu-tar with sparse files disabled when --only-json-tab is passed.
// 41:           ENV["HOMEBREW_BOTTLE_SUDO_PURGE"] = "1" if MacOS.version >= :catalina && !args.only_json_tab?
// 42:         end
// 43:
// 44:         sig { returns(T::Boolean) }
// 45:         def integration_test_portable_ruby?
// 46:           # tests fail on macOS when currently running portable Ruby is replaced using same path
// 47:           portable_ruby_version = (HOMEBREW_LIBRARY_PATH/"vendor/portable-ruby-version").read.chomp
// 48:           portable_ruby_version != ::Formula["portable-ruby"].pkg_version.to_s
// 49:         end
// 50:       end
// 51:
// 52:       module FormulaeDependents
// 53:         extend T::Helpers
// 54:
// 55:         requires_ancestor { ::Homebrew::TestBot::FormulaeDependents }
// 56:
// 57:         sig { params(_formula: Formula, args: ::Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 58:         def skip_recursive_dependents?(_formula, args:)
// 59:           super || ::Hardware::CPU.intel?
// 60:         end
// 61:       end
// 62:
// 63:       module CleanupBefore
// 64:         extend T::Helpers
// 65:
// 66:         requires_ancestor { ::Homebrew::TestBot::CleanupBefore }
// 67:
// 68:         sig { void }
// 69:         def cleanup_github_actions_hosted_runner
// 70:           delete_or_move HOMEBREW_CELLAR.glob("*")
// 71:           delete_or_move HOMEBREW_CASKROOM.glob("session-manager-plugin")
// 72:
// 73:           delete_or_move %w[
// 74:             Mono.framework
// 75:             PluginManager.framework
// 76:             Python.framework
// 77:             R.framework
// 78:             Xamarin.Android.framework
// 79:             Xamarin.Mac.framework
// 80:             Xamarin.iOS.framework
// 81:           ].map { |framework| ::Pathname.new("/Library/Frameworks")/framework }, sudo: true
// 82:         end
// 83:       end
// 84:     end
// 85:   end
// 86: end
// 87:
// 88: Homebrew::TestBot.singleton_class.prepend(OS::Mac::TestBot::ClassMethods)
// 89: Homebrew::TestBot::TestFormulae.prepend(OS::Mac::TestBot::TestFormulae)
// 90: Homebrew::TestBot::Formulae.prepend(OS::Mac::TestBot::Formulae)
// 91: Homebrew::TestBot::FormulaeDependents.prepend(OS::Mac::TestBot::FormulaeDependents)
// 92: Homebrew::TestBot::CleanupBefore.prepend(OS::Mac::TestBot::CleanupBefore)
