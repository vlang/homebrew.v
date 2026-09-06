module cask

import homebrew
import os

// Translated from Homebrew/brew `cask/uninstall.rb`.
pub struct CaskUninstallFailure {
pub:
	type_name string
	message   string
}

pub struct CaskUninstallCask {
pub mut:
	core                     CaskCore
	installed                bool
	pinned                   bool
	installed_versions       []string
	artifact_paths           []string
	uninstall_script         string
	uninstall_script_missing bool
	incomplete_metadata      bool
	upgrade                  bool
	installer_messages       []string
	installer_failure        ?CaskUninstallFailure
}

pub struct CaskUninstallOptions {
pub:
	binaries bool
	force    bool
	verbose  bool
}

pub struct CaskUninstallInstallerRequest {
pub:
	binaries bool
	force    bool
	verbose  bool
}

pub struct CaskUninstallInstallerResult {
pub:
	cask          CaskUninstallCask
	stdout        []string
	stderr        []string
	removed_paths []string
	failure       ?CaskUninstallFailure
}

pub struct CaskUnpinResult {
pub:
	cask    CaskUninstallCask
	allowed bool
	stderr  string
}

pub struct CaskUninstallResult {
pub:
	casks         []CaskUninstallCask
	stdout        string
	stderr        string
	uninstalled   []string
	removed_paths []string
	errors        []CaskUninstallFailure
	final_failure ?CaskUninstallFailure
}

pub struct CaskDependentCheckResult {
pub:
	requireds  []string
	dependents []string
	stderr     string
}

fn cask_uninstall_name(cask CaskUninstallCask) string {
	name := cask.core.full_token()
	return if name != '' { name } else { cask.core.token }
}

fn cask_uninstall_remove(path string) bool {
	if path == '' || (!os.exists(path) && !os.is_link(path)) {
		return false
	}
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path) or { return false }
	} else {
		os.rm(path) or { return false }
	}
	return true
}

pub fn cask_uninstall_installer(cask CaskUninstallCask,
	request CaskUninstallInstallerRequest) CaskUninstallInstallerResult {
	if failure := cask.installer_failure {
		return CaskUninstallInstallerResult{
			cask: cask
			failure: failure
		}
	}
	if cask.uninstall_script_missing && !request.force {
		path := if cask.uninstall_script != '' { cask.uninstall_script } else { 'uninstall script' }
		return CaskUninstallInstallerResult{
			cask: cask
			failure: CaskUninstallFailure{
				type_name: 'Cask::CaskError'
				message: 'uninstall script ${path} does not exist'
			}
		}
	}
	mut updated := cask
	mut removed_paths := []string{}
	for path in cask.artifact_paths {
		if cask_uninstall_remove(path) {
			removed_paths << path
		}
	}
	mut versions := cask.installed_versions.clone()
	if versions.len > 0 {
		version := versions.pop()
		version_path := os.join_path(cask.core.caskroom_path(), version)
		if cask_uninstall_remove(version_path) {
			removed_paths << version_path
		}
		metadata_path := os.join_path(cask.core.metadata_main_container_path(), version)
		if cask_uninstall_remove(metadata_path) {
			removed_paths << metadata_path
		}
	}
	updated.installed_versions = versions
	updated.installed = versions.len > 0
	if versions.len == 0 {
		path := cask.core.caskroom_path()
		if cask_uninstall_remove(path) {
			removed_paths << path
		}
	}
	mut stderr := []string{}
	if cask.incomplete_metadata && !cask.upgrade {
		stderr << "No uninstall artifact metadata is available for Cask '${cask.core.token}'.\nHomebrew will remove its records, but files installed by the Cask may remain."
	}
	return CaskUninstallInstallerResult{
		cask: updated
		stdout: cask.installer_messages.clone()
		stderr: stderr
		removed_paths: removed_paths
	}
}

pub fn cask_unpin_for_removal(cask CaskUninstallCask, force bool) CaskUnpinResult {
	if !cask.pinned {
		return CaskUnpinResult{
			cask: cask
			allowed: true
		}
	}
	if !force {
		return CaskUnpinResult{
			cask: cask
			stderr: '${cask_uninstall_name(cask)} is pinned. You must unpin it to uninstall.'
		}
	}
	mut updated := cask
	mut core := cask.core
	core.unpin() or {}
	updated.core = core
	updated.pinned = false
	return CaskUnpinResult{
		cask: updated
		allowed: true
	}
}

pub fn uninstall_casks(casks []CaskUninstallCask,
	options CaskUninstallOptions) CaskUninstallResult {
	mut states := casks.clone()
	mut stdout := []string{}
	mut stderr := []string{}
	mut uninstalled := []string{}
	mut removed_paths := []string{}
	mut failures := []CaskUninstallFailure{}
	for index, original in states {
		name := cask_uninstall_name(original)
		if !original.installed && !options.force {
			failures << CaskUninstallFailure{
				type_name: 'Cask::CaskNotInstalledError'
				message: 'Cask ${name} is not installed.'
			}
			continue
		}
		unpin := cask_unpin_for_removal(original, options.force)
		states[index] = unpin.cask
		if unpin.stderr != '' {
			stderr << unpin.stderr
		}
		if !unpin.allowed {
			continue
		}
		stdout << '==> Uninstalling Cask ${name}'
		installer := cask_uninstall_installer(unpin.cask, CaskUninstallInstallerRequest{
			binaries: options.binaries
			force: options.force
			verbose: options.verbose
		})
		states[index] = installer.cask
		stdout << installer.stdout
		stderr << installer.stderr
		removed_paths << installer.removed_paths
		if failure := installer.failure {
			failures << failure
			continue
		}
		if original.installed && !installer.cask.installed {
			uninstalled << name
		}
	}
	mut final_failure := ?CaskUninstallFailure(none)
	if failures.len == 1 {
		final_failure = failures[0]
	} else if failures.len > 1 {
		final_failure = CaskUninstallFailure{
			type_name: 'Cask::MultipleCaskErrors'
			message: failures.map(it.message).join('\n')
		}
	}
	return CaskUninstallResult{
		casks: states
		stdout: if stdout.len > 0 { '${stdout.join('\n')}\n' } else { '' }
		stderr: if stderr.len > 0 { '${stderr.join('\n')}\n' } else { '' }
		uninstalled: uninstalled
		removed_paths: removed_paths
		errors: failures
		final_failure: final_failure
	}
}

pub fn check_dependent_casks(casks []CaskUninstallCask, caskroom []homebrew.CaskDependent,
	named_args []string) CaskDependentCheckResult {
	all_requireds := casks.map(it.core.token)
	mut requireds := []string{}
	mut dependents := []string{}
	for dependent in caskroom {
		if dependent.cask.token in all_requireds {
			continue
		}
		mut found := []string{}
		for requirement in dependent.recursive_requirements() {
			if requirement.kind == 'cask' && requirement.cask in all_requireds && requirement.cask !in found {
				found << requirement.cask
			}
		}
		if found.len == 0 {
			continue
		}
		for required in found {
			if required !in requireds {
				requireds << required
			}
		}
		dependents << dependent.cask.token
	}
	if dependents.len == 0 {
		return CaskDependentCheckResult{}
	}
	message := homebrew.new_dependents_message(requireds, dependents, named_args)
	return CaskDependentCheckResult{
		requireds: requireds
		dependents: dependents
		stderr: message.output()
	}
}
