module cask

import ruby
import homebrew
import os

// Translated from Homebrew/brew `cask/uninstall.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn cask_uninstall_cask_value(cask CaskUninstallCask) ruby.Value {
	mut values := {
		'core':                     cask_core_value(cask.core)
		'installed':                ruby.bool_value(cask.installed)
		'pinned':                   ruby.bool_value(cask.pinned)
		'installed_versions':       ruby.string_array_value(cask.installed_versions)
		'artifact_paths':           ruby.string_array_value(cask.artifact_paths)
		'uninstall_script':         ruby.string_value(cask.uninstall_script)
		'uninstall_script_missing': ruby.bool_value(cask.uninstall_script_missing)
		'incomplete_metadata':      ruby.bool_value(cask.incomplete_metadata)
		'upgrade':                  ruby.bool_value(cask.upgrade)
		'installer_messages':       ruby.string_array_value(cask.installer_messages)
	}
	if failure := cask.installer_failure {
		values['installer_failure'] = ruby.structured_value(failure.type_name, failure.message, {
			'message': failure.message
		})
	}
	return ruby.Value{
		type_name: 'Cask::Uninstall::CaskState'
		repr: cask_uninstall_name(cask)
		map_data: values
	}
}

fn cask_uninstall_cask_from_value(value ruby.Value) !CaskUninstallCask {
	if value.type_name != 'Cask::Uninstall::CaskState' && value.type_name != 'Hash' {
		return error('expected Cask::Uninstall::CaskState, got ${value.type_name}')
	}
	failure := if raw := value.map_data['installer_failure'] {
		?CaskUninstallFailure(CaskUninstallFailure{
			type_name: raw.type_name
			message: (raw.map_data['message'] or { ruby.string_value(raw.as_string()) }).as_string()
		})
	} else {
		none
	}
	return CaskUninstallCask{
		core: cask_core_from_value(value.map_data['core'] or { return error('core is required') })!
		installed: (value.map_data['installed'] or { ruby.bool_value(false) }).as_bool()!
		pinned: (value.map_data['pinned'] or { ruby.bool_value(false) }).as_bool()!
		installed_versions: (value.map_data['installed_versions'] or { ruby.string_array_value([]) }).as_string_array()!
		artifact_paths: (value.map_data['artifact_paths'] or { ruby.string_array_value([]) }).as_string_array()!
		uninstall_script: (value.map_data['uninstall_script'] or { ruby.string_value('') }).as_string()
		uninstall_script_missing: (value.map_data['uninstall_script_missing'] or { ruby.bool_value(false) }).as_bool()!
		incomplete_metadata: (value.map_data['incomplete_metadata'] or { ruby.bool_value(false) }).as_bool()!
		upgrade: (value.map_data['upgrade'] or { ruby.bool_value(false) }).as_bool()!
		installer_messages: (value.map_data['installer_messages'] or { ruby.string_array_value([]) }).as_string_array()!
		installer_failure: failure
	}
}

fn cask_uninstall_result_value(result CaskUninstallResult) ruby.Value {
	mut values := {
		'casks':         ruby.array_value(result.casks.map(cask_uninstall_cask_value(it)))
		'stdout':        ruby.string_value(result.stdout)
		'stderr':        ruby.string_value(result.stderr)
		'uninstalled':   ruby.string_array_value(result.uninstalled)
		'removed_paths': ruby.string_array_value(result.removed_paths)
		'errors':        ruby.array_value(result.errors.map(ruby.structured_value(it.type_name, it.message, {
			'message': it.message
		})))
	}
	if failure := result.final_failure {
		values['final_failure'] = ruby.structured_value(failure.type_name, failure.message, {
			'message': failure.message
		})
	}
	return ruby.map_value(values)
}

// Ruby method `self.uninstall_casks(*casks, binaries: false, force: false, verbose: false)` at line 13.
pub fn ruby_uninstall_l13_d1_self_uninstall_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cask_uninstall_result_value(uninstall_casks([], CaskUninstallOptions{}))
	}
	values := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	cask_values := (values['casks'] or { ruby.array_value([]) }).as_array() or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	mut casks := []CaskUninstallCask{}
	for value in cask_values {
		casks << (cask_uninstall_cask_from_value(value) or {
			return ruby.object_value('ArgumentError', err.msg())
		})
	}
	return cask_uninstall_result_value(uninstall_casks(casks, CaskUninstallOptions{
		binaries: (values['binaries'] or { ruby.bool_value(false) }).as_bool() or { false }
		force: (values['force'] or { ruby.bool_value(false) }).as_bool() or { false }
		verbose: (values['verbose'] or { ruby.bool_value(false) }).as_bool() or { false }
	}))
}

// Ruby method `self.unpin_for_removal?(cask, force:)` at line 39.
pub fn ruby_uninstall_l39_d2_self_unpin_for_removal(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	cask := cask_uninstall_cask_from_value(args[0]) or { return ruby.bool_value(false) }
	force := args.len > 1 && (args[1].as_bool() or { false })
	return ruby.bool_value(cask_unpin_for_removal(cask, force).allowed)
}

// Ruby method `self.check_dependent_casks(*casks, named_args: [])` at line 52.
pub fn ruby_uninstall_l52_d3_self_check_dependent_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	values := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	mut casks := []CaskUninstallCask{}
	for raw in (values['casks'] or { ruby.array_value([]) }).as_array() or {
		return ruby.object_value('ArgumentError', err.msg())
	} {
		casks << (cask_uninstall_cask_from_value(raw) or {
			return ruby.object_value('ArgumentError', err.msg())
		})
	}
	mut caskroom := []homebrew.CaskDependent{}
	for raw in (values['caskroom'] or { ruby.array_value([]) }).as_array() or {
		return ruby.object_value('ArgumentError', err.msg())
	} {
		caskroom << (homebrew.cask_dependent_from_value(raw) or {
			return ruby.object_value('ArgumentError', err.msg())
		})
	}
	named_args := (values['named_args'] or { ruby.string_array_value([]) }).as_string_array() or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.string_value(check_dependent_casks(casks, caskroom, named_args).stderr)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask_dependent"
// 5: require "dependents_message"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class Uninstall
// 10:     extend ::Utils::Output::Mixin
// 11:
// 12:     sig { params(casks: ::Cask::Cask, binaries: T::Boolean, force: T::Boolean, verbose: T::Boolean).void }
// 13:     def self.uninstall_casks(*casks, binaries: false, force: false, verbose: false)
// 14:       require "cask/installer"
// 15:
// 16:       caught_exceptions = []
// 17:
// 18:       casks.each do |cask|
// 19:         odebug "Uninstalling Cask #{cask}"
// 20:
// 21:         raise CaskNotInstalledError, cask if !cask.installed? && !force
// 22:
// 23:         next unless unpin_for_removal?(cask, force:)
// 24:
// 25:         Installer.new(cask, binaries:, force:, verbose:).uninstall
// 26:       rescue => e
// 27:         caught_exceptions << e
// 28:         next
// 29:       end
// 30:
// 31:       return if caught_exceptions.empty?
// 32:
// 33:       raise MultipleCaskErrors, caught_exceptions if caught_exceptions.count > 1
// 34:
// 35:       raise caught_exceptions.fetch(0)
// 36:     end
// 37:
// 38:     sig { params(cask: ::Cask::Cask, force: T::Boolean).returns(T::Boolean) }
// 39:     def self.unpin_for_removal?(cask, force:)
// 40:       return true unless cask.pinned?
// 41:
// 42:       unless force
// 43:         onoe "#{cask.full_name} is pinned. You must unpin it to uninstall."
// 44:         return false
// 45:       end
// 46:
// 47:       cask.unpin
// 48:       true
// 49:     end
// 50:
// 51:     sig { params(casks: ::Cask::Cask, named_args: T::Array[String]).void }
// 52:     def self.check_dependent_casks(*casks, named_args: [])
// 53:       dependents = []
// 54:       all_requireds = casks.map(&:token)
// 55:       requireds = Set.new
// 56:       caskroom = ::Cask::Caskroom.casks
// 57:
// 58:       caskroom.each do |dependent|
// 59:         next if all_requireds.include?(dependent.token)
// 60:
// 61:         d = CaskDependent.new(dependent)
// 62:         dependencies = d.recursive_requirements.filter_map { |r| r.cask if r.is_a?(CaskDependent::Requirement) }
// 63:         found_dependents = dependencies.intersection(all_requireds)
// 64:         next if found_dependents.empty?
// 65:
// 66:         requireds += found_dependents
// 67:         dependents << dependent.token
// 68:       end
// 69:
// 70:       return if dependents.empty?
// 71:
// 72:       DependentsMessage.new(requireds.to_a, dependents, named_args:).output
// 73:     end
// 74:   end
// 75: end
