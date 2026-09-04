module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/test_bot.rb`.

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
