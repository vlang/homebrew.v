module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/test_bot.rb`.
// The original source is retained below until every stub has a typed V body.

pub const linux_previous_run_artifact_specifier = '{linux,ubuntu}'
pub const linux_hosted_runner_cleanup_paths = [
	'/usr/local/include/node/',
	'/opt/pipx_bin/ansible-config',
]

pub struct LinuxTestBotFormula {
pub:
	name           string
	requires_linux bool
}

pub struct LinuxTestBotCleanupPlan {
pub:
	paths []string
	sudo  bool
}

pub fn linux_runner_os_title(kernel_name string) string {
	return kernel_name
}

pub fn linux_runner_os_title_with_arch(kernel_name string, arch string) string {
	return '${linux_runner_os_title(kernel_name)} ${arch}'
}

pub fn linux_configure_sandbox(available bool) bool {
	return available
}

pub fn linux_skip_recursive_dependents(super_skips bool,
	formula LinuxTestBotFormula) bool {
	return super_skips || !formula.requires_linux
}

pub fn linux_build_dependent_from_source(dependent LinuxTestBotFormula) bool {
	return dependent.requires_linux
}

pub fn linux_hosted_runner_cleanup_plan() LinuxTestBotCleanupPlan {
	return LinuxTestBotCleanupPlan{
		paths: linux_hosted_runner_cleanup_paths.clone()
		sudo: true
	}
}

fn linux_test_bot_formula_from_value(value ruby.Value) LinuxTestBotFormula {
	return LinuxTestBotFormula{
		name: if value.attributes['name'] != '' {
			value.attributes['name']
		} else {
			value.as_string()
		}
		requires_linux: value.attributes['requires_linux'] == 'true'
	}
}

// Ruby method `runner_os_title` at line 13.
pub fn ruby_test_bot_l13_d1_runner_os_title(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { ruby.kernel_info().name }
	return ruby.string_value(linux_runner_os_title(name))
}

// Ruby method `runner_os_title_with_arch` at line 18.
pub fn ruby_test_bot_l18_d2_runner_os_title_with_arch(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { ruby.kernel_info().name }
	arch := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_value(linux_runner_os_title_with_arch(name, arch))
}

// Ruby method `configure_sandbox!` at line 23.
pub fn ruby_test_bot_l23_d3_configure_sandbox(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux_configure_sandbox(args.len > 0
		&& (args[0].as_bool() or { false })))
}

// Ruby method `previous_run_artifact_specifier` at line 35.
pub fn ruby_test_bot_l35_d4_previous_run_artifact_specifier(args ...ruby.Value) ruby.Value {
	return ruby.string_value(linux_previous_run_artifact_specifier)
}

// Ruby method `skip_recursive_dependents?(formula, args:)` at line 46.
pub fn ruby_test_bot_l46_d5_skip_recursive_dependents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(true)
	}
	return ruby.bool_value(linux_skip_recursive_dependents(args.len > 1
		&& (args[1].as_bool() or { false }), linux_test_bot_formula_from_value(args[0])))
}

// Ruby method `build_dependent_from_source?(dependent)` at line 51.
pub fn ruby_test_bot_l51_d6_build_dependent_from_source(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(linux_build_dependent_from_source(linux_test_bot_formula_from_value(args[0])))
}

// Ruby method `cleanup_github_actions_hosted_runner` at line 62.
pub fn ruby_test_bot_l62_d7_cleanup_github_actions_hosted_runner(args ...ruby.Value) ruby.Value {
	plan := linux_hosted_runner_cleanup_plan()
	return ruby.map_value({
		'paths': ruby.string_array_value(plan.paths)
		'sudo':  ruby.bool_value(plan.sudo)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module TestBot
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { T.class_of(::Homebrew::TestBot) }
// 11:
// 12:         sig { returns(String) }
// 13:         def runner_os_title
// 14:           OS.kernel_name
// 15:         end
// 16:
// 17:         sig { returns(String) }
// 18:         def runner_os_title_with_arch
// 19:           "#{runner_os_title} #{::Hardware::CPU.arch}"
// 20:         end
// 21:
// 22:         sig { returns(T::Boolean) }
// 23:         def configure_sandbox!
// 24:           require "sandbox"
// 25:           ::Sandbox.available?
// 26:         end
// 27:       end
// 28:
// 29:       module TestFormulae
// 30:         extend T::Helpers
// 31:
// 32:         requires_ancestor { ::Homebrew::TestBot::TestFormulae }
// 33:
// 34:         sig { returns(String) }
// 35:         def previous_run_artifact_specifier
// 36:           "{linux,ubuntu}"
// 37:         end
// 38:       end
// 39:
// 40:       module FormulaeDependents
// 41:         extend T::Helpers
// 42:
// 43:         requires_ancestor { ::Homebrew::TestBot::FormulaeDependents }
// 44:
// 45:         sig { params(formula: Formula, args: ::Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 46:         def skip_recursive_dependents?(formula, args:)
// 47:           super || formula.requirements.exclude?(LinuxRequirement.new)
// 48:         end
// 49:
// 50:         sig { params(dependent: Formula).returns(T::Boolean) }
// 51:         def build_dependent_from_source?(dependent)
// 52:           dependent.requirements.include?(LinuxRequirement.new)
// 53:         end
// 54:       end
// 55:
// 56:       module CleanupBefore
// 57:         extend T::Helpers
// 58:
// 59:         requires_ancestor { ::Homebrew::TestBot::CleanupBefore }
// 60:
// 61:         sig { void }
// 62:         def cleanup_github_actions_hosted_runner
// 63:           # brew doctor complains
// 64:           delete_or_move %w[
// 65:             /usr/local/include/node/
// 66:             /opt/pipx_bin/ansible-config
// 67:           ].map { |path| ::Pathname.new(path) }, sudo: true
// 68:         end
// 69:       end
// 70:     end
// 71:   end
// 72: end
// 73:
// 74: Homebrew::TestBot.singleton_class.prepend(OS::Linux::TestBot::ClassMethods)
// 75: Homebrew::TestBot::TestFormulae.prepend(OS::Linux::TestBot::TestFormulae)
// 76: Homebrew::TestBot::FormulaeDependents.prepend(OS::Linux::TestBot::FormulaeDependents)
// 77: Homebrew::TestBot::CleanupBefore.prepend(OS::Linux::TestBot::CleanupBefore)
