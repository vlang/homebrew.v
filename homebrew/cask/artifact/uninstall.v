module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/uninstall.rb`.
pub struct UninstallPhaseOptions {
pub:
	upgrade   bool
	reinstall bool
	quit      bool = true
	operation AbstractUninstallOptions
}

fn uninstall_on_upgrade_directives(artifact AbstractUninstallArtifact) []string {
	raw := artifact.directives['on_upgrade'] or { return [] }
	return value_strings(raw)
}

fn uninstall_operation_options(options UninstallPhaseOptions,
	signal_on_upgrade bool) AbstractUninstallOptions {
	return AbstractUninstallOptions{
		...options.operation
		upgrade: options.upgrade
		reinstall: options.reinstall
		signal_on_upgrade: signal_on_upgrade
	}
}

pub fn uninstall_phase_with_command(mut artifact AbstractUninstallArtifact,
	options UninstallPhaseOptions, runner UninstallCommandRunner) AbstractUninstallResult {
	on_upgrade := uninstall_on_upgrade_directives(artifact)
	allow_signal := 'signal' in on_upgrade
	operation := uninstall_operation_options(options, allow_signal)
	mut result := AbstractUninstallResult{}
	for directive in abstract_uninstall_ordered_directives {
		if directive == 'rmdir' {
			continue
		}
		if directive == 'quit' && !options.quit {
			continue
		}
		if directive == 'signal' && (options.upgrade || options.reinstall) && !allow_signal {
			continue
		}
		dispatch_abstract_uninstall_directive(artifact, directive, operation, runner, mut result)
		if !result.success {
			break
		}
	}
	artifact.bundle_ids_to_reopen << result.bundle_ids_to_reopen
	return result
}

pub fn uninstall_phase(mut artifact AbstractUninstallArtifact,
	options UninstallPhaseOptions) AbstractUninstallResult {
	return uninstall_phase_with_command(mut artifact, options, default_uninstall_runner)
}

pub fn post_uninstall_phase_with_command(artifact AbstractUninstallArtifact,
	options AbstractUninstallOptions, runner UninstallCommandRunner) AbstractUninstallResult {
	mut result := AbstractUninstallResult{}
	dispatch_abstract_uninstall_directive(artifact, 'rmdir', options, runner, mut result)
	return result
}

pub fn post_uninstall_phase(artifact AbstractUninstallArtifact,
	options AbstractUninstallOptions) AbstractUninstallResult {
	return post_uninstall_phase_with_command(artifact, options, default_uninstall_runner)
}

fn uninstall_phase_options_from_value(value ruby.Value) UninstallPhaseOptions {
	values := value.as_map() or { return UninstallPhaseOptions{} }
	return UninstallPhaseOptions{
		upgrade: value_bool(values, 'upgrade', false)
		reinstall: value_bool(values, 'reinstall', false)
		quit: value_bool(values, 'quit', true)
		operation: AbstractUninstallOptions{
			home: (values['home'] or { ruby.string_value('') }).as_string()
			gui: value_bool(values, 'gui', true)
			force: value_bool(values, 'force', false)
			trash_directory: (values['trash_directory'] or { ruby.string_value('') }).as_string()
			undeletable: value_strings(values['undeletable'] or {
				ruby.string_array_value([])
			})
		}
	}
}
