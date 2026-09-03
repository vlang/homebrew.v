module homebrew

import brew_runtime
import homebrew.upgrade_helpers

pub struct UpgradeExecutionResult {
pub:
	success bool
	values  []brew_runtime.Value
	stdout  string
	stderr  string
}

fn upgrade_bool(value brew_runtime.Value, key string, fallback bool) bool {
	raw := value.attributes[key] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn upgrade_strings(value brew_runtime.Value, key string) []string {
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn upgrade_values(value brew_runtime.Value, key string) []brew_runtime.Value {
	item := value.map_data[key] or { return [] }
	return item.as_array() or { [] }
}

fn upgrade_name(value brew_runtime.Value) string {
	return value.attributes['full_specified_name'] or {
		value.attributes['full_name'] or { value.attributes['name'] or { value.repr } }
	}
}

fn upgrade_version(value brew_runtime.Value) string {
	return value.attributes['pkg_version'] or { value.attributes['version'] or { '' } }
}

fn upgrade_unique_values(values []brew_runtime.Value) []brew_runtime.Value {
	mut seen := map[string]bool{}
	mut result := []brew_runtime.Value{}
	for value in values {
		key := upgrade_name(value)
		if seen[key] or { false } {
			continue
		}
		seen[key] = true
		result << value
	}
	return result
}

fn upgrade_result_value(result UpgradeExecutionResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'UpgradeExecutionResult'
		bool_data: result.success
		attributes: {
			'success': result.success.str()
			'stdout':  result.stdout
			'stderr':  result.stderr
		}
		map_data: {
			'values': brew_runtime.array_value(result.values)
		}
	}
}

fn upgrade_result(value brew_runtime.Value) UpgradeExecutionResult {
	return UpgradeExecutionResult{
		success: upgrade_bool(value, 'success', value.bool_data)
		values: upgrade_values(value, 'values')
		stdout: value.attributes['stdout'] or { '' }
		stderr: value.attributes['stderr'] or { '' }
	}
}

pub fn upgrade_format_summary(upgrades []string) []string {
	return upgrade_helpers.format_summary(upgrades)
}

fn upgrade_installer_formula(value brew_runtime.Value) brew_runtime.Value {
	return value.map_data['formula'] or { value }
}

fn upgrade_installer_value(formula brew_runtime.Value, source brew_runtime.Value) brew_runtime.Value {
	mut attributes := source.attributes.clone()
	attributes['valid'] = (source.attributes['valid'] or { 'true' })
	attributes['upgraded'] = (source.attributes['upgraded'] or { 'true' })
	return brew_runtime.Value{
		type_name: 'FormulaInstaller'
		repr: upgrade_name(formula)
		attributes: attributes
		map_data: {
			'formula':      formula
			'dependencies': source.map_data['dependencies'] or { brew_runtime.array_value([]) }
		}
	}
}

fn upgrade_compare_formula(one brew_runtime.Value, two brew_runtime.Value) int {
	if upgrade_strings(one, 'runtime_dependencies').any(it == (two.attributes['full_name'] or {
		upgrade_name(two)})) {
		return 1
	}
	one_name := upgrade_name(one)
	two_name := upgrade_name(two)
	return if one_name < two_name {
		-1
	} else if one_name > two_name { 1 } else { 0 }
}

// Translated from Homebrew/brew `upgrade.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `format_upgrade_summary(upgrades)` at line 26.
pub fn ruby_upgrade_l26_d1_format_upgrade_summary(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	upgrades := args[0].as_string_array() or {
		(args[0].as_array() or { [] }).map(it.as_string())
	}
	return brew_runtime.string_array_value(upgrade_format_summary(upgrades))
}

// Ruby method `formula_installers(` at line 65.
pub fn ruby_upgrade_l65_d2_formula_installers(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return upgrade_result_value(UpgradeExecutionResult{ success: true })
	}
	config := if args.len > 1 { args[1] } else { brew_runtime.Value{} }
	mut formulae := args[0].as_array() or { [] }
	formulae.sort_with_compare(fn (left &brew_runtime.Value, right &brew_runtime.Value) int {
		left_keg_only := upgrade_bool(*left, 'keg_only', false)
		right_keg_only := upgrade_bool(*right, 'keg_only', false)
		return if left_keg_only == right_keg_only {
			0
		} else if left_keg_only { -1 } else { 1 }
	})
	mut pending := formulae.clone()
	mut sorted := []brew_runtime.Value{}
	for pending.len > 0 {
		pending_names := pending.map(upgrade_name(it))
		mut found := -1
		for index, formula in pending {
			dependencies := upgrade_strings(formula, 'dependencies')
			if dependencies.all(it !in pending_names) {
				found = index
				break
			}
		}
		if found < 0 {
			if upgrade_bool(config, 'developer', false) {
				return upgrade_result_value(UpgradeExecutionResult{
					success: false
					stderr: 'Cyclic dependency: ${pending.map(upgrade_name(it)).join(', ')}\n'
				})
			}
			sorted << pending
			break
		}
		sorted << pending[found]
		pending.delete(found)
	}
	mut installers := []brew_runtime.Value{}
	mut stdout := ''
	mut stderr := ''
	for formula in sorted {
		if error_message := formula.attributes['installer_error'] {
			stderr += 'Error: ${upgrade_name(formula)}: ${error_message}\n'
			continue
		}
		installer_source := formula.map_data['installer'] or { brew_runtime.Value{} }
		mut installer := ruby_upgrade_l539_d11_create_formula_installer(formula, config)
		if installer_source.type_name != '' {
			installer = upgrade_installer_value(formula, installer_source)
		}
		if !upgrade_bool(config, 'dry_run', false) && upgrade_bool(config, 'dependents', false) && upgrade_bool(installer, 'all_runtime_dependencies_installed', false) {
			stdout += '==> Not upgrading ${upgrade_name(formula)}: installed runtime dependencies satisfy bottle metadata\n'
			continue
		}
		if upgrade_bool(config, 'dry_run', false) {
			if sanity_error := installer.attributes['sanity_error'] {
				stderr += 'Error: ${sanity_error}\n'
				continue
			}
		}
		installers << installer
	}
	base := upgrade_result_value(UpgradeExecutionResult{
		success: stderr == ''
		values: installers
		stdout: stdout
		stderr: stderr
	})
	mut attributes := base.attributes.clone()
	attributes['bottle_manifest_heading'] = 'Downloading bottle manifests'
	attributes['bottle_manifest_allow_failures'] = 'true'
	attributes['download_queue_shutdown'] = 'true'
	return brew_runtime.Value{
		...base
		attributes: attributes
	}
}

// Ruby method `upgrade_formulae(formula_installers, dry_run: false, verbose: false, fetch: true, skip_formula_names: [])` at line 178.
pub fn ruby_upgrade_l178_d3_upgrade_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return upgrade_result_value(UpgradeExecutionResult{ success: true })
	}
	config := if args.len > 1 { args[1] } else { brew_runtime.Value{} }
	dry_run := upgrade_bool(config, 'dry_run', false)
	fetch := upgrade_bool(config, 'fetch', true)
	mut installers := args[0].as_array() or { [] }
	if !dry_run && fetch {
		installers = installers.filter(upgrade_bool(it, 'fetch_valid', true))
	}
	mut upgraded := []brew_runtime.Value{}
	mut stdout := ''
	mut stderr := ''
	for installer in installers {
		result := upgrade_result(ruby_upgrade_l466_d8_upgrade_formula(installer, config))
		stdout += result.stdout
		stderr += result.stderr
		if result.success {
			upgraded << installer
			if !dry_run && upgrade_bool(config, 'cleanup', true) {
				stdout += installer.attributes['cleanup_output'] or { '' }
			}
		}
	}
	if dry_run {
		cleanup_output := config.attributes['cleanup_output'] or { '' }
		if cleanup_output != '' {
			stdout += '==> Would `brew cleanup`\n${cleanup_output}'
			if !upgrade_bool(config, 'no_install_cleanup', false) {
				stdout += 'Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.\n'
			}
		}
	}
	return upgrade_result_value(UpgradeExecutionResult{
		success: stderr == ''
		values: upgraded
		stdout: stdout
		stderr: stderr
	})
}

// Ruby method `outdated_kegs(formula)` at line 201.
pub fn ruby_upgrade_l201_d4_outdated_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	mut kegs := upgrade_values(args[0], 'linked_kegs')
	kegs << upgrade_values(args[0], 'old_installed_linked_kegs')
	return brew_runtime.array_value(kegs.filter(upgrade_bool(it, 'directory', false)))
}

// Ruby method `print_upgrade_message(formula, fi_options)` at line 208.
pub fn ruby_upgrade_l208_d5_print_upgrade_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	formula := args[0]
	options := if args.len > 1 {
		args[1].as_string_array() or { upgrade_strings(args[1], 'options') }
	} else {
		[]string{}
	}
	version_upgrade := if upgrade_bool(formula, 'optlinked', false) {
		'${formula.attributes['old_version'] or { '' }} -> ${upgrade_version(formula)}'
	} else {
		'-> ${upgrade_version(formula)}'
	}
	return brew_runtime.string_value('==> Upgrading ${upgrade_name(formula)}\n  ${version_upgrade} ${options.join(' ')}\n')
}

// Ruby method `dependants(` at line 227.
pub fn ruby_upgrade_l227_d6_dependants(args ...brew_runtime.Value) brew_runtime.Value {
	formulae := if args.len > 0 { args[0].as_array() or { [] } } else { []brew_runtime.Value{} }
	config := if args.len > 1 { args[1] } else { brew_runtime.Value{} }
	mut stdout := ''
	if upgrade_bool(config, 'no_installed_dependents_check', false) {
		if !upgrade_bool(config, 'no_env_hints', false) {
			stdout = 'Warning: `\$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set: not checking for outdated\ndependents or dependents with broken linkage!\n'
		}
		return brew_runtime.Value{
			type_name: 'UpgradeDependents'
			attributes: {
				'stdout': stdout
			}
			map_data: {
				'upgradeable': brew_runtime.array_value([])
				'pinned':      brew_runtime.array_value([])
				'skipped':     brew_runtime.array_value([])
			}
		}
	}
	formulae_to_install := formulae.filter(!(upgrade_bool(it, 'core_formula', false) && upgrade_bool(it, 'versioned_formula', false)))
	mut outdated := []brew_runtime.Value{}
	for formula in formulae_to_install {
		outdated << upgrade_values(formula, 'runtime_dependents').filter(upgrade_bool(it, 'outdated', false))
	}
	outdated = upgrade_unique_values(outdated)
	mut skipped := []brew_runtime.Value{}
	mut bottled := []brew_runtime.Value{}
	for dependent in outdated {
		if upgrade_bool(dependent, 'bottled', false) && upgrade_bool(dependent, 'dependencies_bottled', true) {
			bottled << dependent
		} else {
			skipped << dependent
		}
	}
	if upgrade_bool(config, 'dry_run', false) {
		primary_names := formulae_to_install.map(upgrade_name(it))
		bottled = bottled.filter(upgrade_name(it) !in primary_names)
	}
	mut upgradeable := bottled.filter(!upgrade_bool(it, 'pinned', false))
	mut pinned := bottled.filter(upgrade_bool(it, 'pinned', false))
	upgradeable.sort_with_compare(fn (left &brew_runtime.Value, right &brew_runtime.Value) int {
		return upgrade_compare_formula(*left, *right)
	})
	pinned.sort_with_compare(fn (left &brew_runtime.Value, right &brew_runtime.Value) int {
		return upgrade_compare_formula(*left, *right)
	})
	return brew_runtime.Value{
		type_name: 'UpgradeDependents'
		attributes: {
			'stdout': stdout
		}
		map_data: {
			'upgradeable': brew_runtime.array_value(upgradeable)
			'pinned':      brew_runtime.array_value(pinned)
			'skipped':     brew_runtime.array_value(skipped)
		}
	}
}

// Ruby method `upgrade_dependents(deps, formulae,` at line 283.
pub fn ruby_upgrade_l283_d7_upgrade_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return upgrade_result_value(UpgradeExecutionResult{ success: true })
	}
	deps := args[0]
	formulae := if args.len > 1 { args[1].as_array() or { [] } } else { []brew_runtime.Value{} }
	config := if args.len > 2 { args[2] } else { brew_runtime.Value{} }
	dry_run := upgrade_bool(config, 'dry_run', false)
	mut upgradeable := upgrade_values(deps, 'upgradeable')
	pinned := upgrade_values(deps, 'pinned')
	skipped := upgrade_values(deps, 'skipped')
	mut stdout := ''
	mut stderr := ''
	if pinned.len > 0 {
		plural := if pinned.len == 1 { 'dependent' } else { 'dependents' }
		mut pinned_descriptions := []string{}
		for formula in pinned {
			pinned_descriptions << '${upgrade_name(formula)} ${upgrade_version(formula)}'
		}
		stdout += 'Warning: Not upgrading ${pinned.len} pinned ${plural}:\n${pinned_descriptions.join(', ')}\n'
	}
	if skipped.len > 0 {
		stdout += 'Warning: The following dependents of upgraded formulae are outdated but will not\nbe upgraded because they are not bottled:\n  ${skipped.map(upgrade_name(it)).join('\n  ')}\n'
	}
	installed := upgrade_values(config, 'installed_formulae')
	installed_names := installed.map(upgrade_name(it))
	primary_names := formulae.map(it.attributes['full_name'] or { upgrade_name(it) })
	mut upgraded := []brew_runtime.Value{}
	if !dry_run {
		upgraded << upgradeable.filter(upgrade_name(it) in installed_names && (it.attributes['full_name'] or { upgrade_name(it) }) !in primary_names)
	}
	skip_names := upgrade_strings(config, 'skip_formula_names')
	upgradeable = upgradeable.filter(upgrade_name(it) !in installed_names && !(dry_run && upgrade_name(it) in skip_names))
	if upgradeable.len > 0 {
		formula_count := if dry_run { formulae.len } else { installed.len }
		formula_plural := if formula_count == 1 { 'formula' } else { 'formulae' }
		verb := if dry_run { 'Would upgrade' } else { 'Upgrading' }
		dependent_plural := if upgradeable.len == 1 { 'dependent' } else { 'dependents' }
		stdout += '==> ${verb} ${upgradeable.len} ${dependent_plural} of upgraded ${formula_plural}:\n'
		stdout += ruby_upgrade_l522_d10_puts_no_installed_dependents_check_disable_message_if_not_already(config).as_string()
		mut descriptions := []string{}
		for formula in upgradeable {
			descriptions << if upgrade_bool(formula, 'optlinked', false) {
				'${upgrade_name(formula)} ${formula.attributes['old_version'] or { '' }} -> ${upgrade_version(formula)}'
			} else {
				'${upgrade_name(formula)} ${upgrade_version(formula)}'
			}
		}
		stdout += upgrade_format_summary(descriptions).join('\n') + '\n'
		if !dry_run {
			installer_result := upgrade_result(ruby_upgrade_l65_d2_formula_installers(brew_runtime.array_value(upgradeable), config))
			formula_result := upgrade_result(ruby_upgrade_l178_d3_upgrade_formulae(brew_runtime.array_value(installer_result.values), config))
			stdout += installer_result.stdout + formula_result.stdout
			stderr += installer_result.stderr + formula_result.stderr
			upgraded << formula_result.values.map(upgrade_installer_formula(it))
		}
	}
	non_core := installed.filter(!upgrade_bool(it, 'core_formula', false))
	if non_core.len > 0 {
		if !dry_run {
			stdout += '==> Checking for dependents of upgraded formulae...\n'
			stdout += ruby_upgrade_l522_d10_puts_no_installed_dependents_check_disable_message_if_not_already(config).as_string()
		}
		broken := ruby_upgrade_l504_d9_check_broken_dependents(brew_runtime.array_value(non_core)).as_array() or { [] }
		if broken.len == 0 {
			stdout += if dry_run {
				'==> No currently broken dependents found!\nWarning: If they are broken by the upgrade they will also be upgraded or reinstalled.\n'
			} else {
				'==> No broken dependents found!\n'
			}
		} else {
			reinstallable := broken.filter(!upgrade_bool(it, 'outdated', false) && !upgrade_bool(it, 'pinned', false))
			pinned_broken := broken.filter(upgrade_bool(it, 'outdated', false) && upgrade_bool(it, 'pinned', false))
			if pinned_broken.len > 0 {
				plural := if pinned_broken.len == 1 { 'dependent' } else { 'dependents' }
				mut pinned_descriptions := []string{}
				for formula in pinned_broken {
					pinned_descriptions << '${upgrade_name(formula)} ${upgrade_version(formula)}'
				}
				stderr += 'Error: Not reinstalling ${pinned_broken.len} broken and outdated, but pinned ${plural}:\n${pinned_descriptions.join(', ')}\n'
			}
			if reinstallable.len == 0 {
				stdout += '==> No broken dependents to reinstall!\n'
			} else {
				plural := if reinstallable.len == 1 { 'dependent' } else { 'dependents' }
				stdout += '==> Reinstalling ${reinstallable.len} ${plural} with broken linkage from source:\n${reinstallable.map(upgrade_name(it)).join(', ')}\n'
			}
		}
	}
	return upgrade_result_value(UpgradeExecutionResult{
		success: stderr == ''
		values: upgraded
		stdout: stdout
		stderr: stderr
	})
}

// Ruby method `upgrade_formula(formula_installer, dry_run: false, verbose: false, skip_formula_names: [])` at line 466.
pub fn ruby_upgrade_l466_d8_upgrade_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return upgrade_result_value(UpgradeExecutionResult{ success: false })
	}
	installer := args[0]
	config := if args.len > 1 { args[1] } else { brew_runtime.Value{} }
	formula := upgrade_installer_formula(installer)
	if upgrade_bool(config, 'dry_run', false) {
		skip_names := upgrade_strings(config, 'skip_formula_names')
		mut descriptions := []string{}
		for dependency in upgrade_values(installer, 'dependencies') {
			name := upgrade_name(dependency)
			if name in skip_names {
				continue
			}
			installed := upgrade_strings(dependency, 'installed_versions')
			mut current := dependency.attributes['old_version'] or { '' }
			for version in installed {
				if current == '' || version > current {
					current = version
				}
			}
			description := if current != '' && current != upgrade_version(dependency) {
				'${name} ${current} -> ${upgrade_version(dependency)}'
			} else {
				'${name} ${upgrade_version(dependency)}'
			}
			descriptions << description
		}
		return upgrade_result_value(UpgradeExecutionResult{
			success: true
			values: [installer]
			stdout: if descriptions.len > 0 {
				'==> Would upgrade dependencies\n${upgrade_format_summary(descriptions).join('\n')}\n'} else {
				''}
		})
	}
	error_message := installer.attributes['install_error'] or { '' }
	if error_message != '' {
		name := upgrade_name(formula)
		return upgrade_result_value(UpgradeExecutionResult{
			success: false
			stderr: 'Error: ${name}: ${error_message}\n'
		})
	}
	return upgrade_result_value(UpgradeExecutionResult{
		success: true
		values: [installer]
	})
}

// Ruby method `check_broken_dependents(installed_formulae)` at line 504.
pub fn ruby_upgrade_l504_d9_check_broken_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	formulae := args[0].as_array() or { [] }
	mut dependents := []brew_runtime.Value{}
	for formula in formulae {
		dependents << upgrade_values(formula, 'runtime_dependents')
	}
	dependents = upgrade_unique_values(dependents)
	return brew_runtime.array_value(dependents.filter(upgrade_bool(it, 'any_installed_keg', false) && upgrade_bool(it, 'keg_directory', false) && upgrade_bool(it, 'broken_linkage', false)))
}

// Ruby method `puts_no_installed_dependents_check_disable_message_if_not_already!` at line 522.
pub fn ruby_upgrade_l522_d10_puts_no_installed_dependents_check_disable_message_if_not_already(args ...brew_runtime.Value) brew_runtime.Value {
	config := if args.len > 0 { args[0] } else { brew_runtime.Value{} }
	if upgrade_bool(config, 'no_env_hints', false) || upgrade_bool(config, 'no_installed_dependents_check', false) || upgrade_bool(config, 'hint_printed', false) {
		return brew_runtime.string_value('')
	}
	return brew_runtime.string_value('Disable this behaviour by setting `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1`.\nHide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\n')
}

// Ruby method `create_formula_installer(` at line 539.
pub fn ruby_upgrade_l539_d11_create_formula_installer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula is required')
	}
	formula := args[0]
	config := if args.len > 1 { args[1] } else { brew_runtime.Value{} }
	kegs := upgrade_values(formula, 'installed_kegs')
	mut keg := brew_runtime.Value{}
	if upgrade_bool(formula, 'optlinked', false) {
		keg = formula.map_data['opt_keg'] or { brew_runtime.Value{} }
	} else {
		for candidate in kegs {
			if upgrade_bool(candidate, 'optlinked', false) {
				keg = candidate
				break
			}
		}
	}
	mut requested_options := upgrade_strings(config, 'flags')
	requested_options << upgrade_strings(formula, 'used_options')
	allowed := upgrade_strings(formula, 'options')
	mut options := []string{}
	for option in requested_options {
		if option in allowed && option !in options {
			options << option
		}
	}
	return brew_runtime.Value{
		type_name: 'FormulaInstaller'
		repr: upgrade_name(formula)
		attributes: {
			'link_keg':             if keg.type_name != '' {
				upgrade_bool(keg, 'linked', false).str()} else {
				''}
			'installed_on_request': if keg.type_name != '' {
				upgrade_bool(keg, 'installed_on_request', false).str()} else {
				'true'}
			'build_bottle':         if keg.type_name != '' {
				upgrade_bool(keg, 'built_bottle', false).str()} else {
				'false'}
			'options':              options.join('\x1f')
			'force_bottle':         upgrade_bool(config, 'force_bottle', false).str()
			'interactive':          upgrade_bool(config, 'interactive', false).str()
			'keep_tmp':             upgrade_bool(config, 'keep_tmp', false).str()
			'debug_symbols':        upgrade_bool(config, 'debug_symbols', false).str()
			'force':                upgrade_bool(config, 'force', false).str()
			'overwrite':            upgrade_bool(config, 'overwrite', false).str()
			'debug':                upgrade_bool(config, 'debug', false).str()
			'quiet':                upgrade_bool(config, 'quiet', false).str()
			'verbose':              upgrade_bool(config, 'verbose', false).str()
		}
		map_data: {
			'formula': formula
		}
	}
}

// Ruby method `depends_on(one, two)` at line 599.
pub fn ruby_upgrade_l599_d12_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.int_value(0)
	}
	return brew_runtime.int_value(upgrade_compare_formula(args[0], args[1]))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "reinstall"
// 5: require "formula_installer"
// 6: require "download_queue"
// 7: require "development_tools"
// 8: require "messages"
// 9: require "cleanup"
// 10: require "utils/topological_hash"
// 11: require "utils/output"
// 12:
// 13: module Homebrew
// 14:   # Helper functions for upgrading formulae.
// 15:   module Upgrade
// 16:     extend Utils::Output::Mixin
// 17:
// 18:     class Dependents < T::Struct
// 19:       const :upgradeable, T::Array[Formula]
// 20:       const :pinned, T::Array[Formula]
// 21:       const :skipped, T::Array[Formula]
// 22:     end
// 23:
// 24:     class << self
// 25:       sig { params(upgrades: T::Array[String]).returns(T::Array[String]) }
// 26:       def format_upgrade_summary(upgrades)
// 27:         return upgrades if upgrades.size < 2
// 28:
// 29:         name_width = upgrades.map { |upgrade| upgrade.split(" ", 2).fetch(0).length }.max
// 30:         name_width ||= 0
// 31:         old_version_width = upgrades.filter_map do |upgrade|
// 32:           versions = upgrade.split(" ", 2).fetch(1, "")
// 33:           next unless versions.include?(" -> ")
// 34:
// 35:           versions.split(" -> ", 2).fetch(0).length
// 36:         end.max
// 37:         old_version_width ||= 0
// 38:
// 39:         upgrades.map do |upgrade|
// 40:           parts = upgrade.split(" ", 2)
// 41:           name = parts.fetch(0)
// 42:           versions = parts.fetch(1, "")
// 43:           next name if versions.blank?
// 44:
// 45:           if versions.include?(" -> ")
// 46:             version_parts = versions.split(" -> ", 2)
// 47:             old_version = version_parts.fetch(0)
// 48:             new_version = version_parts.fetch(1)
// 49:             "#{name.ljust(name_width)}  #{old_version.ljust(old_version_width)} -> #{new_version}"
// 50:           else
// 51:             "#{name.ljust(name_width)}  #{versions}"
// 52:           end
// 53:         end
// 54:       end
// 55:
// 56:       sig {
// 57:         params(
// 58:           formulae_to_install: T::Array[Formula], flags: T::Array[String], dry_run: T::Boolean,
// 59:           force_bottle: T::Boolean, build_from_source_formulae: T::Array[String],
// 60:           dependents: T::Boolean, interactive: T::Boolean, keep_tmp: T::Boolean,
// 61:           debug_symbols: T::Boolean, force: T::Boolean, overwrite: T::Boolean,
// 62:           debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean
// 63:         ).returns(T::Array[FormulaInstaller])
// 64:       }
// 65:       def formula_installers(
// 66:         formulae_to_install,
// 67:         flags:,
// 68:         dry_run: false,
// 69:         force_bottle: false,
// 70:         build_from_source_formulae: [],
// 71:         dependents: false,
// 72:         interactive: false,
// 73:         keep_tmp: false,
// 74:         debug_symbols: false,
// 75:         force: false,
// 76:         overwrite: false,
// 77:         debug: false,
// 78:         quiet: false,
// 79:         verbose: false
// 80:       )
// 81:         return [] if formulae_to_install.empty?
// 82:
// 83:         # Sort keg-only before non-keg-only formulae to avoid any needless conflicts
// 84:         # with outdated, non-keg-only versions of formulae being upgraded.
// 85:         formulae_to_install.sort! do |a, b|
// 86:           if !a.keg_only? && b.keg_only?
// 87:             1
// 88:           elsif a.keg_only? && !b.keg_only?
// 89:             -1
// 90:           else
// 91:             0
// 92:           end
// 93:         end
// 94:
// 95:         dependency_graph = Utils::TopologicalHash.graph_package_dependencies(formulae_to_install)
// 96:         sorted = dependency_graph.tsort_with_cycles do |cycles|
// 97:           raise CyclicDependencyError, cycles if Homebrew::EnvConfig.developer?
// 98:
// 99:           odebug "Ignoring cyclic dependencies: #{cycles.map(&:to_sentence).join(", ")}"
// 100:         end
// 101:         formulae_to_install = sorted & formulae_to_install
// 102:
// 103:         # We need to fetch the bottle tabs ahead of the `Install.fetch_formulae`
// 104:         # pipeline because we need to first filter out those formulae with all
// 105:         # runtime dependencies already satisfied (see below).
// 106:         download_queue = Homebrew::DownloadQueue.new
// 107:         begin
// 108:           installers = formulae_to_install.filter_map do |formula|
// 109:             Migrator.migrate_if_needed(formula, force:, dry_run:)
// 110:             begin
// 111:               fi = create_formula_installer(
// 112:                 formula,
// 113:                 flags:,
// 114:                 download_queue:,
// 115:                 force_bottle:,
// 116:                 build_from_source_formulae:,
// 117:                 interactive:,
// 118:                 keep_tmp:,
// 119:                 debug_symbols:,
// 120:                 force:,
// 121:                 overwrite:,
// 122:                 debug:,
// 123:                 quiet:,
// 124:                 verbose:,
// 125:               )
// 126:               fi.fetch_bottle_tab(quiet: !debug, enqueue: true)
// 127:               fi
// 128:             rescue CannotInstallFormulaError => e
// 129:               ofail e
// 130:               nil
// 131:             rescue UnsatisfiedRequirements, DownloadError => e
// 132:               ofail "#{formula}: #{e}"
// 133:               nil
// 134:             end
// 135:           end
// 136:
// 137:           download_queue.fetch(only: Resource::BottleManifest, heading: "Downloading bottle manifests",
// 138:                                allow_failures: true)
// 139:         ensure
// 140:           download_queue.shutdown
// 141:         end
// 142:
// 143:         installers.filter_map do |fi|
// 144:           fi.determine_bottle_tab_attributes
// 145:
// 146:           if !dry_run && dependents
// 147:             all_runtime_deps_installed = fi.bottle_tab_runtime_dependencies.presence&.all? do |dependency, hash|
// 148:               minimum_version = if (version = hash["version"])
// 149:                 Version.new(version)
// 150:               end
// 151:               Dependency.new(dependency).installed?(minimum_version:, minimum_revision: hash["revision"].to_i)
// 152:             end
// 153:
// 154:             if all_runtime_deps_installed
// 155:               ohai "Not upgrading #{fi.formula.full_specified_name}: " \
// 156:                    "installed runtime dependencies satisfy bottle metadata"
// 157:               next
// 158:             end
// 159:           end
// 160:
// 161:           if dry_run
// 162:             begin
// 163:               fi.check_install_sanity
// 164:             rescue CannotInstallFormulaError => e
// 165:               ofail e.message
// 166:               next
// 167:             end
// 168:           end
// 169:
// 170:           fi
// 171:         end
// 172:       end
// 173:
// 174:       sig {
// 175:         params(formula_installers: T::Array[FormulaInstaller], dry_run: T::Boolean, verbose: T::Boolean,
// 176:                fetch: T::Boolean, skip_formula_names: T::Array[String]).returns(T::Array[FormulaInstaller])
// 177:       }
// 178:       def upgrade_formulae(formula_installers, dry_run: false, verbose: false, fetch: true, skip_formula_names: [])
// 179:         valid_formula_installers = if dry_run || !fetch
// 180:           formula_installers
// 181:         else
// 182:           Install.fetch_formulae(formula_installers)
// 183:         end
// 184:
// 185:         upgraded_formula_installers = valid_formula_installers.select do |fi|
// 186:           upgraded = upgrade_formula(fi, dry_run:, verbose:, skip_formula_names:)
// 187:           Cleanup.install_formula_clean!(fi.formula) if upgraded && !dry_run
// 188:           upgraded
// 189:         end
// 190:         return upgraded_formula_installers unless dry_run
// 191:
// 192:         formulae_to_clean = Cleanup.install_cleanup_formulae(upgraded_formula_installers.map(&:formula))
// 193:         if formulae_to_clean.present? &&
// 194:            Cleanup.printed_dry_run_output?(Cleanup.dry_run_output(formulae: formulae_to_clean), ohai: true)
// 195:           Cleanup.puts_no_install_cleanup_disable_message_if_not_already!
// 196:         end
// 197:         upgraded_formula_installers
// 198:       end
// 199:
// 200:       sig { params(formula: Formula).returns(T::Array[Keg]) }
// 201:       def outdated_kegs(formula)
// 202:         [formula, *formula.old_installed_formulae].map(&:linked_keg)
// 203:                                                   .select(&:directory?)
// 204:                                                   .map { |k| Keg.new(k.resolved_path) }
// 205:       end
// 206:
// 207:       sig { params(formula: Formula, fi_options: Options).void }
// 208:       def print_upgrade_message(formula, fi_options)
// 209:         version_upgrade = if formula.optlinked?
// 210:           "#{Keg.new(formula.opt_prefix).version} -> #{formula.pkg_version}"
// 211:         else
// 212:           "-> #{formula.pkg_version}"
// 213:         end
// 214:         oh1 "Upgrading #{Formatter.identifier(formula.full_specified_name)}"
// 215:         puts "  #{version_upgrade} #{fi_options.to_a.join(" ")}"
// 216:       end
// 217:
// 218:       sig {
// 219:         params(
// 220:           formulae: T::Array[Formula], flags: T::Array[String], dry_run: T::Boolean,
// 221:           ask: T::Boolean, installed_on_request: T::Boolean, force_bottle: T::Boolean,
// 222:           build_from_source_formulae: T::Array[String], interactive: T::Boolean,
// 223:           keep_tmp: T::Boolean, debug_symbols: T::Boolean, force: T::Boolean,
// 224:           debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean
// 225:         ).returns(Dependents)
// 226:       }
// 227:       def dependants(
// 228:         formulae,
// 229:         flags:,
// 230:         dry_run: false,
// 231:         ask: false,
// 232:         installed_on_request: false,
// 233:         force_bottle: false,
// 234:         build_from_source_formulae: [],
// 235:         interactive: false,
// 236:         keep_tmp: false,
// 237:         debug_symbols: false,
// 238:         force: false,
// 239:         debug: false,
// 240:         quiet: false,
// 241:         verbose: false
// 242:       )
// 243:         no_dependents = Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 244:         if Homebrew::EnvConfig.no_installed_dependents_check?
// 245:           unless Homebrew::EnvConfig.no_env_hints?
// 246:             opoo <<~EOS
// 247:               `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set: not checking for outdated
// 248:               dependents or dependents with broken linkage!
// 249:             EOS
// 250:           end
// 251:           return no_dependents
// 252:         end
// 253:         formulae_to_install = formulae.reject { |f| f.core_formula? && f.versioned_formula? }
// 254:         return no_dependents if formulae_to_install.empty?
// 255:
// 256:         # TODO: this should be refactored to use FormulaInstaller new logic
// 257:         outdated = formulae_to_install.flat_map(&:runtime_installed_formula_dependents)
// 258:                                       .uniq
// 259:                                       .select(&:outdated?)
// 260:
// 261:         # Ensure we never attempt a source build for outdated dependents of upgraded formulae.
// 262:         outdated, skipped = outdated.partition do |dependent|
// 263:           dependent.bottled? && dependent.deps.map(&:to_formula).all?(&:bottled?)
// 264:         end
// 265:         return no_dependents if outdated.blank?
// 266:
// 267:         outdated -= formulae_to_install if dry_run
// 268:         upgradeable = outdated.reject(&:pinned?)
// 269:                               .sort { |a, b| depends_on(a, b) }
// 270:         pinned = outdated.select(&:pinned?)
// 271:                          .sort { |a, b| depends_on(a, b) }
// 272:
// 273:         Dependents.new(upgradeable:, pinned:, skipped:)
// 274:       end
// 275:
// 276:       sig {
// 277:         params(deps: Dependents, formulae: T::Array[Formula], flags: T::Array[String],
// 278:                dry_run: T::Boolean, installed_on_request: T::Boolean, force_bottle: T::Boolean,
// 279:                build_from_source_formulae: T::Array[String], interactive: T::Boolean, keep_tmp: T::Boolean,
// 280:                debug_symbols: T::Boolean, force: T::Boolean, debug: T::Boolean, quiet: T::Boolean,
// 281:                verbose: T::Boolean, skip_formula_names: T::Array[String]).returns(T::Array[Formula])
// 282:       }
// 283:       def upgrade_dependents(deps, formulae,
// 284:                              flags:,
// 285:                              dry_run: false,
// 286:                              installed_on_request: false,
// 287:                              force_bottle: false,
// 288:                              build_from_source_formulae: [],
// 289:                              interactive: false,
// 290:                              keep_tmp: false,
// 291:                              debug_symbols: false,
// 292:                              force: false,
// 293:                              debug: false,
// 294:                              quiet: false,
// 295:                              verbose: false,
// 296:                              skip_formula_names: [])
// 297:         return [] if deps.blank?
// 298:
// 299:         upgradeable = deps.upgradeable
// 300:         pinned      = deps.pinned
// 301:         skipped     = deps.skipped
// 302:         if pinned.present?
// 303:           plural = Utils.pluralize("dependent", pinned.count)
// 304:           opoo "Not upgrading #{pinned.count} pinned #{plural}:"
// 305:           puts(pinned.map do |f|
// 306:             "#{f.full_specified_name} #{f.pkg_version}"
// 307:           end.join(", "))
// 308:         end
// 309:         if skipped.present?
// 310:           opoo <<~EOS
// 311:             The following dependents of upgraded formulae are outdated but will not
// 312:             be upgraded because they are not bottled:
// 313:               #{skipped * "\n  "}
// 314:           EOS
// 315:         end
// 316:
// 317:         installed_formulae = FormulaInstaller.installed
// 318:         upgraded_formulae = T.let([], T::Array[Formula])
// 319:         unless dry_run
// 320:           primary_formula_names = formulae.map(&:full_name)
// 321:           upgraded_formulae.concat(upgradeable.select do |f|
// 322:             installed_formulae.include?(f) && primary_formula_names.exclude?(f.full_name)
// 323:           end)
// 324:         end
// 325:
// 326:         upgradeable.reject! do |f|
// 327:           installed_formulae.include?(f) || (dry_run && skip_formula_names.include?(f.full_name))
// 328:         end
// 329:
// 330:         return upgraded_formulae if upgradeable.blank?
// 331:
// 332:         dependent_installers = T.let([], T::Array[FormulaInstaller])
// 333:         unless dry_run
// 334:           dependent_installers = formula_installers(
// 335:             upgradeable.dup,
// 336:             flags:,
// 337:             force_bottle:,
// 338:             build_from_source_formulae:,
// 339:             dependents:                 true,
// 340:             interactive:,
// 341:             keep_tmp:,
// 342:             debug_symbols:,
// 343:             force:,
// 344:             debug:,
// 345:             quiet:,
// 346:             verbose:,
// 347:           )
// 348:           upgradeable = dependent_installers.map(&:formula)
// 349:         end
// 350:
// 351:         # Print the upgradable dependents.
// 352:         if upgradeable.present?
// 353:           installed_formulae = (dry_run ? formulae : FormulaInstaller.installed.to_a).dup
// 354:           formula_plural = Utils.pluralize("formula", installed_formulae.count)
// 355:           upgrade_verb = dry_run ? "Would upgrade" : "Upgrading"
// 356:           ohai "#{upgrade_verb} #{Utils.pluralize("dependent", upgradeable.count,
// 357:                                                   include_count: true)} of upgraded #{formula_plural}:"
// 358:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 359:           formulae_upgrades = upgradeable.map do |f|
// 360:             name = f.full_specified_name
// 361:             if f.optlinked?
// 362:               "#{name} #{Keg.new(f.opt_prefix).version} -> #{f.pkg_version}"
// 363:             else
// 364:               "#{name} #{f.pkg_version}"
// 365:             end
// 366:           end
// 367:           puts format_upgrade_summary(formulae_upgrades).join("\n")
// 368:         end
// 369:
// 370:         upgraded_formulae.concat(upgrade_formulae(dependent_installers, verbose:).map(&:formula)) unless dry_run
// 371:
// 372:         # Update non-core installed formulae for linkage checks after upgrading
// 373:         # Don't need to check core formulae because we do so at CI time.
// 374:         installed_non_core_formulae = FormulaInstaller.installed.to_a.reject(&:core_formula?)
// 375:         return upgraded_formulae if installed_non_core_formulae.blank?
// 376:
// 377:         # Assess the dependents tree again now we've upgraded.
// 378:         unless dry_run
// 379:           oh1 "Checking for dependents of upgraded formulae..."
// 380:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 381:         end
// 382:
// 383:         broken_dependents = check_broken_dependents(installed_non_core_formulae)
// 384:         if broken_dependents.blank?
// 385:           if dry_run
// 386:             ohai "No currently broken dependents found!"
// 387:             opoo "If they are broken by the upgrade they will also be upgraded or reinstalled."
// 388:           else
// 389:             ohai "No broken dependents found!"
// 390:           end
// 391:           return upgraded_formulae
// 392:         end
// 393:
// 394:         reinstallable_broken_dependents =
// 395:           broken_dependents.reject(&:outdated?)
// 396:                            .reject(&:pinned?)
// 397:                            .sort { |a, b| depends_on(a, b) }
// 398:         outdated_pinned_broken_dependents =
// 399:           broken_dependents.select(&:outdated?)
// 400:                            .select(&:pinned?)
// 401:                            .sort { |a, b| depends_on(a, b) }
// 402:
// 403:         # Print the pinned dependents.
// 404:         if outdated_pinned_broken_dependents.present?
// 405:           count = outdated_pinned_broken_dependents.count
// 406:           plural = Utils.pluralize("dependent", outdated_pinned_broken_dependents.count)
// 407:           onoe "Not reinstalling #{count} broken and outdated, but pinned #{plural}:"
// 408:           $stderr.puts(outdated_pinned_broken_dependents.map do |f|
// 409:             "#{f.full_specified_name} #{f.pkg_version}"
// 410:           end.join(", "))
// 411:         end
// 412:
// 413:         # Print the broken dependents.
// 414:         if reinstallable_broken_dependents.blank?
// 415:           ohai "No broken dependents to reinstall!"
// 416:         else
// 417:           ohai "Reinstalling #{Utils.pluralize("dependent", reinstallable_broken_dependents.count,
// 418:                                                include_count: true)} with broken linkage from source:"
// 419:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 420:           puts reinstallable_broken_dependents.map(&:full_specified_name)
// 421:                                               .join(", ")
// 422:         end
// 423:
// 424:         return upgraded_formulae if dry_run
// 425:
// 426:         reinstall_contexts = reinstallable_broken_dependents.map do |formula|
// 427:           Reinstall.build_install_context(
// 428:             formula,
// 429:             flags:,
// 430:             force_bottle:,
// 431:             build_from_source_formulae: build_from_source_formulae + [formula.full_name],
// 432:             interactive:,
// 433:             keep_tmp:,
// 434:             debug_symbols:,
// 435:             force:,
// 436:             debug:,
// 437:             quiet:,
// 438:             verbose:,
// 439:           )
// 440:         end
// 441:
// 442:         valid_formula_installers = Install.fetch_formulae(reinstall_contexts.map(&:formula_installer))
// 443:
// 444:         reinstall_contexts.each do |reinstall_context|
// 445:           next unless valid_formula_installers.include?(reinstall_context.formula_installer)
// 446:
// 447:           Reinstall.reinstall_formula(reinstall_context)
// 448:         rescue FormulaInstallationAlreadyAttemptedError
// 449:           # We already attempted to reinstall f as part of the dependency tree of
// 450:           # another formula. In that case, don't generate an error, just move on.
// 451:           nil
// 452:         rescue BuildError => e
// 453:           e.dump(verbose:)
// 454:           puts
// 455:           Homebrew.failed = true
// 456:         rescue => e
// 457:           ofail e
// 458:         end
// 459:         upgraded_formulae
// 460:       end
// 461:
// 462:       sig {
// 463:         params(formula_installer: FormulaInstaller, dry_run: T::Boolean, verbose: T::Boolean,
// 464:                skip_formula_names: T::Array[String]).returns(T::Boolean)
// 465:       }
// 466:       def upgrade_formula(formula_installer, dry_run: false, verbose: false, skip_formula_names: [])
// 467:         formula = formula_installer.formula
// 468:
// 469:         if dry_run
// 470:           Install.print_dry_run_dependencies(formula, formula_installer.compute_dependencies,
// 471:                                              skip_formula_names:) do |f|
// 472:             name = f.full_specified_name
// 473:             current_version = if f.optlinked?
// 474:               Keg.new(f.opt_prefix).version
// 475:             else
// 476:               f.installed_kegs.map(&:version).max
// 477:             end
// 478:             if current_version && current_version != f.pkg_version
// 479:               "#{name} #{current_version} -> #{f.pkg_version}"
// 480:             else
// 481:               "#{name} #{f.pkg_version}"
// 482:             end
// 483:           end
// 484:           return true
// 485:         end
// 486:
// 487:         Install.install_formula(formula_installer, upgrade: true)
// 488:         true
// 489:       rescue BuildError => e
// 490:         e.dump(verbose:)
// 491:         puts
// 492:         Homebrew.failed = true
// 493:         false
// 494:       rescue => e
// 495:         # Keep a single failed upgrade (e.g. a bottle that fails to extract)
// 496:         # from aborting the rest of the batch while still failing the run.
// 497:         ofail "#{formula_installer.formula.full_specified_name}: #{e}"
// 498:         false
// 499:       end
// 500:
// 501:       private
// 502:
// 503:       sig { params(installed_formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 504:       def check_broken_dependents(installed_formulae)
// 505:         CacheStoreDatabase.use(:linkage) do |db|
// 506:           installed_formulae.flat_map(&:runtime_installed_formula_dependents)
// 507:                             .uniq
// 508:                             .select do |f|
// 509:             keg = f.any_installed_keg
// 510:             next unless keg
// 511:             next unless keg.directory?
// 512:
// 513:             LinkageChecker.new(
// 514:               keg,
// 515:               cache_db: T.cast(db, CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]]),
// 516:             ).broken_library_linkage?
// 517:           end.compact
// 518:         end
// 519:       end
// 520:
// 521:       sig { void }
// 522:       def puts_no_installed_dependents_check_disable_message_if_not_already!
// 523:         return if Homebrew::EnvConfig.no_env_hints?
// 524:         return if Homebrew::EnvConfig.no_installed_dependents_check?
// 525:         return if @puts_no_installed_dependents_check_disable_message_if_not_already
// 526:
// 527:         puts "Disable this behaviour by setting `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1`."
// 528:         puts "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`)."
// 529:         @puts_no_installed_dependents_check_disable_message_if_not_already = T.let(true, T.nilable(T::Boolean))
// 530:       end
// 531:
// 532:       sig {
// 533:         params(formula: Formula, flags: T::Array[String], download_queue: Homebrew::DownloadQueue,
// 534:                force_bottle: T::Boolean,
// 535:                build_from_source_formulae: T::Array[String], interactive: T::Boolean,
// 536:                keep_tmp: T::Boolean, debug_symbols: T::Boolean, force: T::Boolean,
// 537:                overwrite: T::Boolean, debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean).returns(FormulaInstaller)
// 538:       }
// 539:       def create_formula_installer(
// 540:         formula,
// 541:         flags:,
// 542:         download_queue:,
// 543:         force_bottle: false,
// 544:         build_from_source_formulae: [],
// 545:         interactive: false,
// 546:         keep_tmp: false,
// 547:         debug_symbols: false,
// 548:         force: false,
// 549:         overwrite: false,
// 550:         debug: false,
// 551:         quiet: false,
// 552:         verbose: false
// 553:       )
// 554:         keg = if formula.optlinked?
// 555:           Keg.new(formula.opt_prefix.resolved_path)
// 556:         else
// 557:           formula.installed_kegs.find(&:optlinked?)
// 558:         end
// 559:
// 560:         if keg
// 561:           tab = keg.tab
// 562:           link_keg = keg.linked?
// 563:           installed_on_request = tab.installed_on_request == true
// 564:           build_bottle = tab.built_bottle?
// 565:         else
// 566:           link_keg = nil
// 567:           installed_on_request = true
// 568:           build_bottle = false
// 569:         end
// 570:
// 571:         build_options = BuildOptions.new(Options.create(flags), formula.options)
// 572:         options = build_options.used_options
// 573:         options |= formula.build.used_options
// 574:         options &= formula.options
// 575:
// 576:         FormulaInstaller.new(
// 577:           formula,
// 578:           **{
// 579:             download_queue:,
// 580:             options:,
// 581:             link_keg:,
// 582:             installed_on_request:,
// 583:             build_bottle:,
// 584:             force_bottle:,
// 585:             build_from_source_formulae:,
// 586:             interactive:,
// 587:             keep_tmp:,
// 588:             debug_symbols:,
// 589:             force:,
// 590:             overwrite:,
// 591:             debug:,
// 592:             quiet:,
// 593:             verbose:,
// 594:           }.compact,
// 595:         )
// 596:       end
// 597:
// 598:       sig { params(one: Formula, two: Formula).returns(Integer) }
// 599:       def depends_on(one, two)
// 600:         if one.any_installed_keg
// 601:               &.runtime_dependencies
// 602:               &.any? { |dependency| dependency["full_name"] == two.full_name }
// 603:           1
// 604:         else
// 605:           T.must(one <=> two)
// 606:         end
// 607:       end
// 608:     end
// 609:   end
// 610: end
