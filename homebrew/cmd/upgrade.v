module cmd

import ruby
import homebrew.upgrade_helpers

pub struct UpgradeCmdFormula {
pub:
	name                     string
	full_name                string
	full_specified_name      string
	pkg_version              string
	old_version              string
	installed_versions       []string
	latest_head_pkg_version  string
	outdated                 bool
	pinned                   bool
	deprecated               bool
	disabled                 bool
	core_formula             bool
	pour_bottle              bool
	optlinked                bool
	head                     bool
	latest_version_installed bool
	build_from_source        bool
	has_bottle               bool
	bottle_size              i64
}

pub struct UpgradeCmdCask {
pub:
	token                     string
	full_name                 string
	installed_version         string
	version                   string
	outdated                  bool
	pinned                    bool
	deprecated                bool
	disabled                  bool
	manual_installer          bool
	requirements_error        string
	source_download_prefetch  bool
	source_download_available bool
}

pub struct UpgradeCmdInstaller {
pub:
	formula     UpgradeCmdFormula
	valid       bool = true
	upgraded    bool = true
	pour_bottle bool = true
}

pub struct UpgradeCmdDependents {
pub:
	upgradeable []UpgradeCmdFormula
	pinned      []UpgradeCmdFormula
	skipped     []UpgradeCmdFormula
}

pub struct UpgradeCmdFormulaeContext {
pub:
	formulae_to_install []UpgradeCmdFormula
	formulae_installer  []UpgradeCmdInstaller
	dependants          UpgradeCmdDependents
	pinned_formulae     []UpgradeCmdFormula
}

pub struct UpgradeCmdFinalSummary {
pub:
	version_changes       []string
	pinned_formulae       []string
	pinned_casks          []string
	deprecated            []string
	disabled              []string
	source_build_formulae []string
}

fn upgrade_cmd_bool(value ruby.Value, key string, fallback bool) bool {
	raw := value.attributes[key] or { return fallback }
	return raw == 'true' || raw == '1'
}

fn upgrade_cmd_string_list(value ruby.Value, key string) []string {
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn upgrade_cmd_values(value ruby.Value, key string) []ruby.Value {
	item := value.map_data[key] or { return [] }
	return item.as_array() or { [] }
}

fn upgrade_cmd_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn upgrade_cmd_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if seen[value] or { false } {
			continue
		}
		seen[value] = true
		result << value
	}
	return result
}

fn upgrade_cmd_formula(value ruby.Value) UpgradeCmdFormula {
	name := value.attributes['name'] or { value.repr }
	full_name := value.attributes['full_name'] or { name }
	return UpgradeCmdFormula{
		name: name
		full_name: full_name
		full_specified_name: value.attributes['full_specified_name'] or { full_name }
		pkg_version: value.attributes['pkg_version'] or { value.attributes['version'] or { '' } }
		old_version: value.attributes['old_version'] or { '' }
		installed_versions: upgrade_cmd_string_list(value, 'installed_versions')
		latest_head_pkg_version: value.attributes['latest_head_pkg_version'] or { '' }
		outdated: upgrade_cmd_bool(value, 'outdated', false)
		pinned: upgrade_cmd_bool(value, 'pinned', false)
		deprecated: upgrade_cmd_bool(value, 'deprecated', false)
		disabled: upgrade_cmd_bool(value, 'disabled', false)
		core_formula: upgrade_cmd_bool(value, 'core_formula', true)
		pour_bottle: upgrade_cmd_bool(value, 'pour_bottle', true)
		optlinked: upgrade_cmd_bool(value, 'optlinked', false)
		head: upgrade_cmd_bool(value, 'head', false)
		latest_version_installed: upgrade_cmd_bool(value, 'latest_version_installed', false)
		build_from_source: upgrade_cmd_bool(value, 'build_from_source', false)
		has_bottle: upgrade_cmd_bool(value, 'has_bottle', false)
		bottle_size: (value.attributes['bottle_size'] or { '0' }).i64()
	}
}

fn upgrade_cmd_cask(value ruby.Value) UpgradeCmdCask {
	token := value.attributes['token'] or { value.repr }
	return UpgradeCmdCask{
		token: token
		full_name: value.attributes['full_name'] or { token }
		installed_version: value.attributes['installed_version'] or { '' }
		version: value.attributes['version'] or { '' }
		outdated: upgrade_cmd_bool(value, 'outdated', false)
		pinned: upgrade_cmd_bool(value, 'pinned', false)
		deprecated: upgrade_cmd_bool(value, 'deprecated', false)
		disabled: upgrade_cmd_bool(value, 'disabled', false)
		manual_installer: upgrade_cmd_bool(value, 'manual_installer', false)
		requirements_error: value.attributes['requirements_error'] or { '' }
		source_download_prefetch: upgrade_cmd_bool(value, 'source_download_prefetch', false)
		source_download_available: upgrade_cmd_bool(value, 'source_download_available', false)
	}
}

fn upgrade_cmd_formula_value(formula UpgradeCmdFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.full_specified_name, {
		'name':                     formula.name
		'full_name':                formula.full_name
		'full_specified_name':      formula.full_specified_name
		'pkg_version':              formula.pkg_version
		'old_version':              formula.old_version
		'installed_versions':       formula.installed_versions.join('\x1f')
		'latest_head_pkg_version':  formula.latest_head_pkg_version
		'outdated':                 formula.outdated.str()
		'pinned':                   formula.pinned.str()
		'deprecated':               formula.deprecated.str()
		'disabled':                 formula.disabled.str()
		'core_formula':             formula.core_formula.str()
		'pour_bottle':              formula.pour_bottle.str()
		'optlinked':                formula.optlinked.str()
		'head':                     formula.head.str()
		'latest_version_installed': formula.latest_version_installed.str()
		'build_from_source':        formula.build_from_source.str()
		'has_bottle':               formula.has_bottle.str()
		'bottle_size':              formula.bottle_size.str()
	})
}

fn upgrade_cmd_cask_value(cask UpgradeCmdCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.full_name, {
		'token':                     cask.token
		'full_name':                 cask.full_name
		'installed_version':         cask.installed_version
		'version':                   cask.version
		'outdated':                  cask.outdated.str()
		'pinned':                    cask.pinned.str()
		'deprecated':                cask.deprecated.str()
		'disabled':                  cask.disabled.str()
		'manual_installer':          cask.manual_installer.str()
		'requirements_error':        cask.requirements_error
		'source_download_prefetch':  cask.source_download_prefetch.str()
		'source_download_available': cask.source_download_available.str()
	})
}

fn upgrade_cmd_installer(value ruby.Value) UpgradeCmdInstaller {
	formula_value := value.map_data['formula'] or { value }
	return UpgradeCmdInstaller{
		formula: upgrade_cmd_formula(formula_value)
		valid: upgrade_cmd_bool(value, 'valid', true)
		upgraded: upgrade_cmd_bool(value, 'upgraded', true)
		pour_bottle: upgrade_cmd_bool(value, 'pour_bottle', true)
	}
}

fn upgrade_cmd_installer_value(installer UpgradeCmdInstaller) ruby.Value {
	return ruby.Value{
		type_name: 'FormulaInstaller'
		repr: installer.formula.full_specified_name
		attributes: {
			'valid':       installer.valid.str()
			'upgraded':    installer.upgraded.str()
			'pour_bottle': installer.pour_bottle.str()
		}
		map_data: {
			'formula': upgrade_cmd_formula_value(installer.formula)
		}
	}
}

fn upgrade_cmd_dependents(value ruby.Value) UpgradeCmdDependents {
	return UpgradeCmdDependents{
		upgradeable: upgrade_cmd_values(value, 'upgradeable').map(upgrade_cmd_formula(it))
		pinned: upgrade_cmd_values(value, 'pinned').map(upgrade_cmd_formula(it))
		skipped: upgrade_cmd_values(value, 'skipped').map(upgrade_cmd_formula(it))
	}
}

fn upgrade_cmd_dependents_value(dependants UpgradeCmdDependents) ruby.Value {
	return ruby.map_value({
		'upgradeable': ruby.array_value(dependants.upgradeable.map(upgrade_cmd_formula_value(it)))
		'pinned':      ruby.array_value(dependants.pinned.map(upgrade_cmd_formula_value(it)))
		'skipped':     ruby.array_value(dependants.skipped.map(upgrade_cmd_formula_value(it)))
	})
}

fn upgrade_cmd_context(value ruby.Value) UpgradeCmdFormulaeContext {
	dependants_value := value.map_data['dependants'] or { ruby.map_value({}) }
	return UpgradeCmdFormulaeContext{
		formulae_to_install: upgrade_cmd_values(value, 'formulae_to_install').map(upgrade_cmd_formula(it))
		formulae_installer: upgrade_cmd_values(value, 'formulae_installer').map(upgrade_cmd_installer(it))
		dependants: upgrade_cmd_dependents(dependants_value)
		pinned_formulae: upgrade_cmd_values(value, 'pinned_formulae').map(upgrade_cmd_formula(it))
	}
}

fn upgrade_cmd_context_value(context UpgradeCmdFormulaeContext) ruby.Value {
	return ruby.Value{
		type_name: 'FormulaeUpgradeContext'
		map_data: {
			'formulae_to_install': ruby.array_value(context.formulae_to_install.map(upgrade_cmd_formula_value(it)))
			'formulae_installer':  ruby.array_value(context.formulae_installer.map(upgrade_cmd_installer_value(it)))
			'dependants':          upgrade_cmd_dependents_value(context.dependants)
			'pinned_formulae':     ruby.array_value(context.pinned_formulae.map(upgrade_cmd_formula_value(it)))
		}
	}
}

fn upgrade_cmd_summary(value ruby.Value) UpgradeCmdFinalSummary {
	return UpgradeCmdFinalSummary{
		version_changes: upgrade_cmd_string_list(value, 'version_changes')
		pinned_formulae: upgrade_cmd_string_list(value, 'pinned_formulae')
		pinned_casks: upgrade_cmd_string_list(value, 'pinned_casks')
		deprecated: upgrade_cmd_string_list(value, 'deprecated')
		disabled: upgrade_cmd_string_list(value, 'disabled')
		source_build_formulae: upgrade_cmd_string_list(value, 'source_build_formulae')
	}
}

fn upgrade_cmd_summary_value(summary UpgradeCmdFinalSummary) ruby.Value {
	return ruby.structured_value('FinalUpgradeSummary', 'FinalUpgradeSummary', {
		'version_changes':       summary.version_changes.join('\x1f')
		'pinned_formulae':       summary.pinned_formulae.join('\x1f')
		'pinned_casks':          summary.pinned_casks.join('\x1f')
		'deprecated':            summary.deprecated.join('\x1f')
		'disabled':              summary.disabled.join('\x1f')
		'source_build_formulae': summary.source_build_formulae.join('\x1f')
	})
}

fn upgrade_cmd_compare_version(left string, right string) int {
	left_parts := left.trim_left('v').split_any('.-_')
	right_parts := right.trim_left('v').split_any('.-_')
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { '0' }
		right_part := if index < right_parts.len { right_parts[index] } else { '0' }
		if left_part.int() != right_part.int() {
			return if left_part.int() < right_part.int() { -1 } else { 1 }
		}
		if left_part != right_part && (left_part.int() == 0 || right_part.int() == 0) {
			return if left_part < right_part { -1 } else { 1 }
		}
	}
	return 0
}

fn upgrade_cmd_disk_size(size i64) string {
	if size < 1000 {
		return '${size}B'
	}
	if size < 1_000_000 {
		return '${size / 1000}KB'
	}
	if size < 1_000_000_000 {
		return '${size / 1_000_000}MB'
	}
	return '${size / 1_000_000_000}GB'
}

// Translated from Homebrew/brew `cmd/upgrade.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(argv = ARGV.freeze)` at line 161.
pub fn ruby_upgrade_l161_d1_initialize(args ...ruby.Value) ruby.Value {
	argv := if args.len > 0 {
		args[0].as_string_array() or { [] }
	} else {
		[]string{}
	}
	return ruby.Value{
		type_name: 'UpgradeCmd'
		attributes: {
			'argv':                argv.join('\x1f')
			'ask_prompt_required': 'false'
		}
		map_data: {
			'final_upgrade_summary': upgrade_cmd_summary_value(UpgradeCmdFinalSummary{})
		}
	}
}

// Ruby method `run` at line 167.
pub fn ruby_upgrade_l167_d2_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'upgrade command state is required')
	}
	config := args[0]
	named := upgrade_cmd_string_list(config, 'named')
	if upgrade_cmd_bool(config, 'build_from_source', false) && named.len == 0 {
		return ruby.object_value('ArgumentError', '`--build-from-source` requires at least one formula')
	}
	minimum := ruby_upgrade_l832_d11_minimum_version(config)
	if minimum.type_name != 'NilClass' && named.len != 1 {
		return ruby.object_value('UsageError', '`--minimum-version` requires exactly one formula or cask argument.')
	}
	mut events := []string{}
	mut formulae := []ruby.Value{}
	mut casks := []ruby.Value{}
	mut unavailable := []ruby.Value{}
	if named.len > 0 {
		events << 'trust_fully_qualified_items'
		for item in upgrade_cmd_values(config, 'resolved_items') {
			if item.type_name in ['FormulaOrCaskUnavailableError', 'NoSuchKegError'] {
				unavailable << item
			} else if item.type_name == 'Formula' {
				formulae << item
			} else if item.type_name.contains('Cask') {
				casks << item
			}
		}
	}
	named_given := named.len > 0
	only_formulae := (named_given && casks.len == 0) || (formulae.len > 0 && casks.len == 0)
	only_casks := (named_given && formulae.len == 0) || (casks.len > 0 && formulae.len == 0)
	dry_run := upgrade_cmd_bool(config, 'dry_run', false)
	ask := !upgrade_cmd_bool(config, 'no_ask', false) && !dry_run
	mut stdout := ''
	mut stderr := ''
	mut summary_value := config.map_data['final_upgrade_summary'] or {
		upgrade_cmd_summary_value(UpgradeCmdFinalSummary{})
	}
	mut ask_planned := false
	mut skip_after_preview := false
	if ask {
		if !only_casks {
			events << 'preview_formulae'
			preview := ruby_upgrade_l610_d8_upgrade_outdated_formulae(config, ruby.array_value(formulae), ruby.bool_value(false), ruby.bool_value(false), ruby.bool_value(true), ruby.bool_value(false))
			stdout += preview.attributes['stdout'] or { '' }
			stderr += preview.attributes['stderr'] or { '' }
			if preview_summary := preview.map_data['final_upgrade_summary'] {
				summary_value = preview_summary
			}
		}
		if planned := config.map_data['planned_summary'] {
			summary_value = planned
		}
		if !only_formulae {
			events << 'preview_casks'
			preview := ruby_upgrade_l787_d10_upgrade_outdated_casks(config, ruby.array_value(casks), ruby.bool_value(false), ruby.bool_value(false), ruby.bool_value(true))
			stderr += preview.attributes['stderr'] or { '' }
		}
		mut display_summary := summary_value
		if formatted := config.map_data['formatted_version_changes'] {
			mut display_map := summary_value.map_data.clone()
			display_map['formatted_version_changes'] = formatted
			display_summary = ruby.Value{
				...summary_value
				map_data: display_map
			}
		}
		stdout += ruby_upgrade_l528_d6_show_final_upgrade_summary(display_summary, ruby.bool_value(true)).as_string()
		ask_planned = upgrade_cmd_summary(summary_value).version_changes.len > 0
		if upgrade_cmd_bool(config, 'ask_prompt_needed', ask_planned) {
			events << 'ask_upgrade'
		}
		skip_after_preview = upgrade_cmd_bool(config, 'failed_after_preview', false) && !ask_planned
	}
	mut formula_prefetched := false
	mut casks_prefetched := false
	mut prefetched_casks := []ruby.Value{}
	mut prefetched_errors := []string{}
	if !dry_run && (!ask || ask_planned) && !only_formulae && !only_casks {
		events << 'new_shared_download_queue'
		formula_prefetch := ruby_upgrade_l610_d8_upgrade_outdated_formulae(config, ruby.array_value(formulae), ruby.bool_value(true), ruby.bool_value(false), ruby.bool_value(false), ruby.bool_value(false))
		formula_prefetched = formula_prefetch.bool_data
		cask_prefetch := ruby_upgrade_l715_d9_prefetch_outdated_casks(config, ruby.array_value(casks))
		casks_prefetched = cask_prefetch.bool_data
		prefetched_casks = upgrade_cmd_values(cask_prefetch, 'prefetch_casks')
		prefetched_errors = upgrade_cmd_string_list(cask_prefetch, 'prefetch_errors')
		if !ask {
			mut changes := upgrade_cmd_string_list(formula_prefetch, 'prefetch_upgrades')
			changes << upgrade_cmd_string_list(cask_prefetch, 'prefetch_upgrades')
			if changes.len > 0 {
				formatted := if injected := config.map_data['formatted_prefetch_upgrades'] {
					injected.as_string_array() or { changes }
				} else {
					changes
				}
				plural := if changes.len == 1 { 'package' } else { 'packages' }
				stdout += '==> Upgrading ${changes.len} outdated ${plural}:\n${formatted.join('\n')}\n'
			}
		}
		events << 'fetch_shared_downloads'
		failed := upgrade_cmd_string_list(config, 'failed_download_types')
		if 'formula' in failed {
			formula_prefetched = false
		}
		if 'cask' in failed {
			casks_prefetched = false
		}
		events << 'shutdown_shared_download_queue'
	}
	if !only_casks && !skip_after_preview {
		events << 'upgrade_formulae'
		actual := ruby_upgrade_l610_d8_upgrade_outdated_formulae(config, ruby.array_value(formulae), ruby.bool_value(false), ruby.bool_value(formula_prefetched), ruby.bool_value(dry_run), ruby.bool_value(false))
		stdout += actual.attributes['stdout'] or { '' }
		stderr += actual.attributes['stderr'] or { '' }
		if actual_summary := actual.map_data['final_upgrade_summary'] {
			summary_value = actual_summary
		}
	}
	if !only_formulae && !skip_after_preview {
		events << 'upgrade_casks'
		mut cask_config := config
		if prefetched_errors.len > 0 {
			mut attributes := config.attributes.clone()
			attributes['prefetched_cask_errors'] = prefetched_errors.join('\x1f')
			cask_config = ruby.Value{ ...config, attributes: attributes }
		}
		actual_casks := if casks_prefetched { prefetched_casks } else { casks }
		actual := ruby_upgrade_l787_d10_upgrade_outdated_casks(cask_config, ruby.array_value(actual_casks), ruby.bool_value(casks_prefetched), ruby.bool_value(false), ruby.bool_value(dry_run))
		stderr += actual.attributes['stderr'] or { '' }
	}
	for error_value in unavailable {
		stderr += 'Error: ${error_value.repr}\n'
	}
	events << ['periodic_cleanup', 'reinstall_pkgconf_if_needed', 'display_messages']
	mut display_summary := summary_value
	if formatted := config.map_data['formatted_version_changes'] {
		mut display_map := summary_value.map_data.clone()
		display_map['formatted_version_changes'] = formatted
		display_summary = ruby.Value{
			...summary_value
			map_data: display_map
		}
	}
	stdout += ruby_upgrade_l528_d6_show_final_upgrade_summary(display_summary, ruby.bool_value(dry_run)).as_string()
	return ruby.Value{
		type_name: 'UpgradeRunResult'
		bool_data: stderr == ''
		attributes: {
			'stdout':             stdout
			'stderr':             stderr
			'events':             events.join('\x1f')
			'formula_prefetched': formula_prefetched.str()
			'casks_prefetched':   casks_prefetched.str()
		}
		map_data: {
			'final_upgrade_summary': summary_value
		}
	}
}

// Ruby method `formulae_upgrade_context(formulae, show_upgrade_summary: true, dry_run: args.dry_run?)` at line 344.
pub fn ruby_upgrade_l344_d3_formulae_upgrade_context(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return upgrade_cmd_nil()
	}
	config := args[0]
	requested := args[1].as_array() or { [] }
	show_summary := args.len < 3 || args[2].bool_data
	dry_run := if args.len > 3 {
		args[3].bool_data
	} else {
		upgrade_cmd_bool(config, 'dry_run', false)
	}
	mut stdout := ''
	mut stderr := ''
	if upgrade_cmd_bool(config, 'build_from_source', false) {
		if !upgrade_cmd_bool(config, 'development_tools_installed', true) {
			return ruby.object_value('BuildFlagsError', '--build-from-source')
		}
		if !upgrade_cmd_bool(config, 'developer', false) {
			stderr += 'Warning: building from source is not supported!\n'
			stdout += "You're on your own. Failures are expected so don't create any issues, please!\n"
		}
	}
	quiet := upgrade_cmd_bool(config, 'quiet', false) || (dry_run && !upgrade_cmd_bool(config, 'dry_run', false))
	formula_values := if requested.len == 0 {
		upgrade_cmd_values(config, 'installed_formulae')
	} else {
		requested
	}
	mut outdated_values := []ruby.Value{}
	mut not_outdated := []ruby.Value{}
	for formula in formula_values {
		if ruby_upgrade_l835_d12_formula_outdated(config, formula).bool_data {
			outdated_values << formula
		} else {
			not_outdated << formula
		}
	}
	if requested.len > 0 {
		for formula in not_outdated {
			model := upgrade_cmd_formula(formula)
			if model.installed_versions.len == 0 {
				stderr += 'Error: ${model.full_specified_name} not installed\n'
			} else if !quiet {
				mut latest := model.installed_versions[0]
				for version in model.installed_versions {
					if upgrade_cmd_compare_version(version, latest) > 0 {
						latest = version
					}
				}
				stderr += 'Warning: ${model.full_specified_name} ${latest} already installed\n'
			}
		}
	}
	if outdated_values.len == 0 {
		return ruby.Value{
			type_name: 'NilClass'
			repr: 'nil'
			attributes: {
				'stdout': stdout
				'stderr': stderr
			}
		}
	}
	mut pinned_values := []ruby.Value{}
	mut install_values := []ruby.Value{}
	for value in outdated_values {
		if upgrade_cmd_bool(value, 'pinned', false) {
			pinned_values << value
			continue
		}
		latest := value.map_data['latest_formula'] or { value }
		if upgrade_cmd_bool(latest, 'latest_version_installed', false) {
			install_values << value
		} else {
			install_values << latest
		}
	}
	if install_values.len == 0 {
		if show_summary {
			stdout += '==> No packages to upgrade\n'
		}
	} else if show_summary {
		verb := if dry_run { 'Would upgrade' } else { 'Upgrading' }
		plural := if install_values.len == 1 { 'package' } else { 'packages' }
		stdout += '==> ${verb} ${install_values.len} outdated ${plural}:\n'
		if upgrade_cmd_bool(config, 'no_ask', false) {
			descriptions := ruby_upgrade_l578_d7_formula_upgrade_descriptions(config, ruby.array_value(install_values), ruby.bool_value(false)).as_string_array() or { [] }
			formatted := if injected := config.map_data['formatted_descriptions'] {
				injected.as_string_array() or { descriptions }
			} else {
				upgrade_helpers.format_summary(descriptions)
			}
			stdout += formatted.join('\n') + '\n'
		}
	}
	mut installers := []UpgradeCmdInstaller{}
	injected_installers := upgrade_cmd_values(config, 'formula_installers')
	if injected_installers.len > 0 {
		installers = injected_installers.map(upgrade_cmd_installer(it))
	} else {
		for formula in install_values {
			if installer := formula.map_data['installer'] {
				installers << upgrade_cmd_installer(installer)
			}
		}
	}
	if installers.len == 0 && install_values.len > 0 {
		return ruby.Value{
			type_name: 'NilClass'
			repr: 'nil'
			attributes: {
				'stdout': stdout
				'stderr': stderr
			}
		}
	}
	if pinned_values.len > 0 {
		plural := if pinned_values.len == 1 { 'package' } else { 'packages' }
		message := 'Not upgrading ${pinned_values.len} pinned ${plural}:'
		if requested.len > 0 {
			stderr += 'Error: ${message}\n'
		} else {
			stderr += 'Warning: ${message}\n'
		}
		stdout += pinned_values.map('${upgrade_cmd_formula(it).full_specified_name} ${upgrade_cmd_formula(it).pkg_version}').join(', ') + '\n'
	}
	dependants_value := config.map_data['dependants'] or { ruby.map_value({}) }
	context := UpgradeCmdFormulaeContext{
		formulae_to_install: install_values.map(upgrade_cmd_formula(it))
		formulae_installer: installers
		dependants: upgrade_cmd_dependents(dependants_value)
		pinned_formulae: pinned_values.map(upgrade_cmd_formula(it))
	}
	base := upgrade_cmd_context_value(context)
	return ruby.Value{
		...base
		attributes: {
			'stdout': stdout
			'stderr': stderr
		}
	}
}

// Ruby method `final_upgrade_summary` at line 484.
pub fn ruby_upgrade_l484_d4_final_upgrade_summary(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		if summary := args[0].map_data['final_upgrade_summary'] {
			if summary.type_name == 'FinalUpgradeSummary' {
				return summary
			}
		}
		if args[0].type_name == 'FinalUpgradeSummary' {
			return args[0]
		}
	}
	return upgrade_cmd_summary_value(UpgradeCmdFinalSummary{})
}

// Ruby method `record_formula_upgrade_summary(context, include_sizes: false, formulae_installer: nil, version_changes: nil)` at line 497.
pub fn ruby_upgrade_l497_d5_record_formula_upgrade_summary(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return upgrade_cmd_summary_value(UpgradeCmdFinalSummary{})
	}
	mut summary := upgrade_cmd_summary(args[0])
	context := upgrade_cmd_context(args[1])
	include_sizes := args.len > 2 && args[2].bool_data
	installers := if args.len > 3 && args[3].type_name != 'NilClass' {
		(args[3].as_array() or { [] }).map(upgrade_cmd_installer(it))
	} else {
		context.formulae_installer.clone()
	}
	provided_changes := if args.len > 4 && args[4].type_name != 'NilClass' {
		args[4].as_string_array() or { [] }
	} else {
		[]string{}
	}
	mut changes := provided_changes.clone()
	if args.len <= 4 || args[4].type_name == 'NilClass' {
		formula_values := installers.map(upgrade_cmd_formula_value(it.formula))
		dependent_values := context.dependants.upgradeable.map(upgrade_cmd_formula_value(it))
		changes = ruby_upgrade_l578_d7_formula_upgrade_descriptions(ruby.Value{}, ruby.array_value(formula_values), ruby.bool_value(include_sizes)).as_string_array() or { [] }
		changes << ruby_upgrade_l578_d7_formula_upgrade_descriptions(ruby.Value{}, ruby.array_value(dependent_values), ruby.bool_value(include_sizes)).as_string_array() or { [] }
	}
	mut pinned := context.pinned_formulae.clone()
	pinned << context.dependants.pinned
	mut pinned_descriptions := summary.pinned_formulae.clone()
	for formula in pinned {
		pinned_descriptions << '${formula.full_specified_name} ${formula.pkg_version}'
	}
	mut all_formulae := context.formulae_to_install.clone()
	all_formulae << context.pinned_formulae
	all_formulae << context.dependants.upgradeable
	all_formulae << context.dependants.pinned
	mut deprecated := summary.deprecated.clone()
	mut disabled := summary.disabled.clone()
	for formula in all_formulae {
		if formula.deprecated { deprecated << formula.full_specified_name }
		if formula.disabled { disabled << formula.full_specified_name }
	}
	mut source_build := summary.source_build_formulae.clone()
	for installer in installers {
		if installer.formula.core_formula && !installer.pour_bottle {
			source_build << installer.formula.full_specified_name
		}
	}
	mut version_changes := summary.version_changes.clone()
	version_changes << changes
	return upgrade_cmd_summary_value(UpgradeCmdFinalSummary{
		version_changes: version_changes
		pinned_formulae: pinned_descriptions
		pinned_casks: summary.pinned_casks
		deprecated: deprecated
		disabled: disabled
		source_build_formulae: source_build
	})
}

// Ruby method `show_final_upgrade_summary(dry_run: args.dry_run?)` at line 528.
pub fn ruby_upgrade_l528_d6_show_final_upgrade_summary(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	summary := upgrade_cmd_summary(args[0])
	dry_run := args.len > 1 && args[1].bool_data
	mut output := ''
	version_changes := upgrade_cmd_unique(summary.version_changes)
	if version_changes.len > 0 {
		plural := if version_changes.len == 1 { 'package' } else { 'packages' }
		formatted_changes := if injected := args[0].map_data['formatted_version_changes'] {
			injected.as_string_array() or { version_changes.clone() }
		} else {
			upgrade_helpers.format_summary(version_changes)
		}
		output += ruby_upgrade_l875_d15_show_final_upgrade_summary_section(ruby.string_value('${if dry_run {
			'Would upgrade'
		} else {
			'Upgraded'
		}} ${version_changes.len} outdated ${plural}'), ruby.string_array_value(formatted_changes)).as_string()
	}
	pinned_formulae := upgrade_cmd_unique(summary.pinned_formulae)
	if pinned_formulae.len > 0 {
		plural := if pinned_formulae.len == 1 { 'formula' } else { 'formulae' }
		output += ruby_upgrade_l875_d15_show_final_upgrade_summary_section(ruby.string_value('${pinned_formulae.len} Pinned ${plural}'), ruby.string_array_value(pinned_formulae)).as_string()
	}
	pinned_casks := upgrade_cmd_unique(summary.pinned_casks)
	if pinned_casks.len > 0 {
		plural := if pinned_casks.len == 1 { 'cask' } else { 'casks' }
		output += ruby_upgrade_l875_d15_show_final_upgrade_summary_section(ruby.string_value('${pinned_casks.len} Pinned ${plural}'), ruby.string_array_value(pinned_casks)).as_string()
	}
	mut deprecate_disable := summary.deprecated.map('${it} (deprecated)')
	deprecate_disable << summary.disabled.map('${it} (disabled)')
	deprecate_disable = upgrade_cmd_unique(deprecate_disable)
	if deprecate_disable.len > 0 {
		plural := if deprecate_disable.len == 1 { 'package' } else { 'packages' }
		output += ruby_upgrade_l875_d15_show_final_upgrade_summary_section(ruby.string_value('${deprecate_disable.len} Deprecated or disabled ${plural}'), ruby.string_array_value(deprecate_disable)).as_string()
	}
	source_build := upgrade_cmd_unique(summary.source_build_formulae)
	if source_build.len > 0 {
		plural := if source_build.len == 1 { 'formula' } else { 'formulae' }
		title := if dry_run {
			'${source_build.len} homebrew/core ${plural} that would build from source'
		} else {
			'${source_build.len} homebrew/core ${plural} built from source'
		}
		output += ruby_upgrade_l875_d15_show_final_upgrade_summary_section(ruby.string_value(title), ruby.string_array_value(source_build)).as_string()
	}
	return ruby.string_value(output)
}

// Ruby method `formula_upgrade_descriptions(formulae, include_sizes: false)` at line 578.
pub fn ruby_upgrade_l578_d7_formula_upgrade_descriptions(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_array_value([])
	}
	config := args[0]
	formulae := args[1].as_array() or { [] }
	include_sizes := args.len > 2 && args[2].bool_data
	mut descriptions := []string{}
	for value in formulae {
		formula := upgrade_cmd_formula(value)
		if formula.optlinked {
			new_version := ruby_upgrade_l884_d16_formula_upgrade_display_version(config, value, ruby.string_value(formula.old_version)).as_string()
			size := if include_sizes {
				ruby_upgrade_l896_d17_formula_upgrade_size(config, value).as_string()
			} else {
				''
			}
			descriptions << '${formula.full_specified_name} ${formula.old_version} -> ${new_version}${size}'
		} else if include_sizes {
			descriptions << '${formula.full_specified_name} ${formula.pkg_version}${ruby_upgrade_l896_d17_formula_upgrade_size(config, value).as_string()}'
		} else {
			descriptions << '${formula.full_specified_name} ${formula.pkg_version}'
		}
	}
	return ruby.string_array_value(descriptions)
}

// Ruby method `upgrade_outdated_formulae!(formulae, prefetch_only: false, use_prefetched: false,` at line 610.
pub fn ruby_upgrade_l610_d8_upgrade_outdated_formulae(args ...ruby.Value) ruby.Value {
	if args.len < 2 || upgrade_cmd_bool(args[0], 'cask_only', false) {
		return ruby.Value{ type_name: 'FormulaUpgradeResult', bool_data: false }
	}
	config := args[0]
	formulae := args[1]
	prefetch_only := args.len > 2 && args[2].bool_data
	use_prefetched := args.len > 3 && args[3].bool_data
	dry_run := if args.len > 4 {
		args[4].bool_data
	} else {
		upgrade_cmd_bool(config, 'dry_run', false)
	}
	show_summary := args.len < 6 || args[5].bool_data
	mut context_value := ruby.Value{}
	mut used_prefetched := false
	if use_prefetched {
		if prefetched := config.map_data['prefetched_formulae_context'] {
			if prefetched.type_name == 'FormulaeUpgradeContext' {
				context_value = prefetched
				used_prefetched = true
			}
		}
	}
	if context_value.type_name == '' {
		if injected := config.map_data['formulae_context'] {
			context_value = injected
		} else {
			context_value = ruby_upgrade_l344_d3_formulae_upgrade_context(config, formulae, ruby.bool_value(show_summary), ruby.bool_value(dry_run))
		}
	}
	if context_value.type_name != 'FormulaeUpgradeContext' {
		return ruby.Value{
			type_name: 'FormulaUpgradeResult'
			bool_data: false
			attributes: {
				'stdout': context_value.attributes['stdout'] or { '' }
				'stderr': context_value.attributes['stderr'] or { '' }
			}
		}
	}
	context := upgrade_cmd_context(context_value)
	mut stdout := context_value.attributes['stdout'] or { '' }
	mut stderr := context_value.attributes['stderr'] or { '' }
	if prefetch_only {
		valid := context.formulae_installer.filter(it.valid)
		prefetch_upgrades := ruby_upgrade_l578_d7_formula_upgrade_descriptions(config, ruby.array_value(valid.map(upgrade_cmd_formula_value(it.formula))), ruby.bool_value(false)).as_string_array() or { [] }
		prefetched := UpgradeCmdFormulaeContext{
			formulae_to_install: context.formulae_to_install
			formulae_installer: valid
			dependants: context.dependants
			pinned_formulae: context.pinned_formulae
		}
		return ruby.Value{
			type_name: 'FormulaUpgradeResult'
			bool_data: valid.len > 0
			attributes: {
				'stdout':            stdout
				'stderr':            stderr
				'prefetch_names':    valid.map(it.formula.name).join('\x1f')
				'prefetch_upgrades': prefetch_upgrades.join('\x1f')
			}
			map_data: {
				'prefetched_formulae_context': upgrade_cmd_context_value(prefetched)
			}
		}
	}
	formula_values := context.formulae_installer.map(upgrade_cmd_formula_value(it.formula))
	dependent_values := context.dependants.upgradeable.map(upgrade_cmd_formula_value(it))
	formula_changes := ruby_upgrade_l578_d7_formula_upgrade_descriptions(config, ruby.array_value(formula_values), ruby.bool_value(dry_run)).as_string_array() or { [] }
	dependent_changes := ruby_upgrade_l578_d7_formula_upgrade_descriptions(config, ruby.array_value(dependent_values), ruby.bool_value(dry_run)).as_string_array() or { [] }
	mut summary := upgrade_cmd_summary(config.map_data['final_upgrade_summary'] or {
		upgrade_cmd_summary_value(UpgradeCmdFinalSummary{})
	})
	if dry_run {
		mut planned_changes := formula_changes.clone()
		planned_changes << dependent_changes
		summary = upgrade_cmd_summary(ruby_upgrade_l497_d5_record_formula_upgrade_summary(upgrade_cmd_summary_value(summary), context_value, ruby.bool_value(false), upgrade_cmd_nil(), ruby.string_array_value(planned_changes)))
	}
	ask_required := !upgrade_cmd_bool(config, 'no_ask', false) && dry_run && upgrade_cmd_bool(config, 'named_present', false) && upgrade_cmd_bool(config, 'formulae_ask_prompt_needed', false)
	mut upgraded_installers := context.formulae_installer.filter(it.upgraded)
	mut upgraded_dependents := context.dependants.upgradeable.clone()
	if successful := config.attributes['upgraded_formula_names'] {
		names := if successful == '' { []string{} } else { successful.split('\x1f') }
		upgraded_installers = upgraded_installers.filter(it.formula.full_name in names || it.formula.full_specified_name in names)
	}
	if successful := config.attributes['upgraded_dependent_names'] {
		names := if successful == '' { []string{} } else { successful.split('\x1f') }
		upgraded_dependents = upgraded_dependents.filter(it.full_name in names || it.full_specified_name in names)
	}
	if !dry_run {
		mut successful_changes := []string{}
		mut planned_names := context.formulae_installer.map(it.formula.full_specified_name)
		planned_names << context.dependants.upgradeable.map(it.full_specified_name)
		mut successful_names := upgraded_installers.map(it.formula.full_specified_name)
		successful_names << upgraded_dependents.map(it.full_specified_name)
		mut all_changes := formula_changes.clone()
		all_changes << dependent_changes
		for index, name in planned_names {
			if name in successful_names && index < all_changes.len { successful_changes << all_changes[index] }
		}
		summary = upgrade_cmd_summary(ruby_upgrade_l497_d5_record_formula_upgrade_summary(upgrade_cmd_summary_value(summary), context_value, ruby.bool_value(false), ruby.array_value(upgraded_installers.map(upgrade_cmd_installer_value(it))), ruby.string_array_value(successful_changes)))
	}
	if used_prefetched {
		stdout += config.attributes['prefetched_formula_output'] or { '' }
	}
	return ruby.Value{
		type_name: 'FormulaUpgradeResult'
		bool_data: true
		attributes: {
			'stdout':              stdout
			'stderr':              stderr
			'ask_prompt_required': ask_required.str()
			'used_prefetched':     used_prefetched.str()
		}
		map_data: {
			'final_upgrade_summary': upgrade_cmd_summary_value(summary)
			'upgraded_installers':   ruby.array_value(upgraded_installers.map(upgrade_cmd_installer_value(it)))
			'upgraded_dependents':   ruby.array_value(upgraded_dependents.map(upgrade_cmd_formula_value(it)))
		}
	}
}

// Ruby method `prefetch_outdated_casks!(casks, download_queue:, prefetch_names: nil,` at line 715.
pub fn ruby_upgrade_l715_d9_prefetch_outdated_casks(args ...ruby.Value) ruby.Value {
	if args.len < 2 || upgrade_cmd_bool(args[0], 'formula_only', false) {
		return ruby.Value{ type_name: 'CaskPrefetchResult', bool_data: false }
	}
	config := args[0]
	minimum_result := ruby_upgrade_l858_d14_minimum_version_casks(config, args[1], ruby.bool_value(true))
	casks := upgrade_cmd_values(minimum_result, 'casks')
	minimum := ruby_upgrade_l832_d11_minimum_version(config)
	if minimum.type_name != 'NilClass' && casks.len == 0 {
		return ruby.Value{ type_name: 'CaskPrefetchResult', bool_data: false }
	}
	mut outdated := if injected := config.map_data['outdated_casks'] {
		injected.as_array() or { [] }
	} else {
		casks.filter(upgrade_cmd_bool(it, 'outdated', false))
	}
	if outdated.len == 0 {
		return ruby.Value{ type_name: 'CaskPrefetchResult', bool_data: false }
	}
	outdated = outdated.filter(!upgrade_cmd_bool(it, 'manual_installer', false))
	if outdated.len == 0 {
		return ruby.Value{ type_name: 'CaskPrefetchResult', bool_data: false }
	}
	mut compatible := []ruby.Value{}
	mut errors := []string{}
	mut installers := []ruby.Value{}
	mut source_downloads := []string{}
	for value in outdated {
		cask := upgrade_cmd_cask(value)
		if cask.requirements_error != '' {
			errors << cask.requirements_error
			continue
		}
		compatible << value
		installers << ruby.Value{
			type_name: 'Cask::Installer'
			repr: cask.full_name
			attributes: {
				'binaries':       upgrade_cmd_bool(config, 'binaries', true).str()
				'verbose':        upgrade_cmd_bool(config, 'verbose', false).str()
				'force':          upgrade_cmd_bool(config, 'force', false).str()
				'skip_cask_deps': upgrade_cmd_bool(config, 'skip_cask_deps', false).str()
				'require_sha':    upgrade_cmd_bool(config, 'require_sha', false).str()
				'upgrade':        'true'
				'defer_fetch':    'true'
			}
		}
		if cask.source_download_prefetch && cask.source_download_available {
			source_downloads << cask.full_name
		}
	}
	mut names := []string{}
	mut upgrades := []string{}
	for value in compatible {
		cask := upgrade_cmd_cask(value)
		names << cask.full_name
		upgrades << '${cask.full_name} ${cask.installed_version} -> ${cask.version}'
	}
	return ruby.Value{
		type_name: 'CaskPrefetchResult'
		bool_data: compatible.len > 0 || errors.len > 0
		attributes: {
			'prefetch_names':    names.join('\x1f')
			'prefetch_upgrades': upgrades.join('\x1f')
			'prefetch_errors':   errors.join('\x1f')
			'source_downloads':  source_downloads.join('\x1f')
			'cask_file_heading': if source_downloads.len > 0 {
				'Downloading Cask files'} else {
				''}
		}
		map_data: {
			'prefetch_casks': ruby.array_value(compatible)
			'installers':     ruby.array_value(installers)
		}
	}
}

// Ruby method `upgrade_outdated_casks!(casks, skip_prefetch: false, show_upgrade_summary: true,` at line 787.
pub fn ruby_upgrade_l787_d10_upgrade_outdated_casks(args ...ruby.Value) ruby.Value {
	if args.len < 2 || upgrade_cmd_bool(args[0], 'formula_only', false) {
		return ruby.Value{ type_name: 'CaskUpgradeResult', bool_data: false }
	}
	config := args[0]
	skip_prefetch := args.len > 2 && args[2].bool_data
	show_summary := args.len < 4 || args[3].bool_data
	dry_run := if args.len > 4 {
		args[4].bool_data
	} else {
		upgrade_cmd_bool(config, 'dry_run', false)
	}
	quiet := upgrade_cmd_bool(config, 'quiet', false) || (dry_run && !upgrade_cmd_bool(config, 'dry_run', false))
	minimum_result := ruby_upgrade_l858_d14_minimum_version_casks(config, args[1], ruby.bool_value(quiet))
	casks := upgrade_cmd_values(minimum_result, 'casks')
	mut stderr := minimum_result.attributes['stderr'] or { '' }
	minimum := ruby_upgrade_l832_d11_minimum_version(config)
	if minimum.type_name != 'NilClass' && casks.len == 0 {
		return ruby.Value{
			type_name: 'CaskUpgradeResult'
			bool_data: false
			attributes: {
				'stderr': stderr
			}
		}
	}
	prefetched_errors := upgrade_cmd_string_list(config, 'prefetched_cask_errors')
	if skip_prefetch && casks.len == 0 && prefetched_errors.len > 0 {
		stderr += prefetched_errors.map('Error: ${it}').join('\n') + '\n'
		return ruby.Value{
			type_name: 'CaskUpgradeResult'
			bool_data: false
			attributes: {
				'stderr': stderr
			}
		}
	}
	if error_message := config.attributes['cask_upgrade_error'] {
		stderr += 'Error: ${error_message}\n'
		return ruby.Value{
			type_name: 'CaskUpgradeResult'
			bool_data: false
			attributes: {
				'stderr': stderr
			}
		}
	}
	return ruby.Value{
		type_name: 'CaskUpgradeResult'
		bool_data: true
		attributes: {
			'stderr':               stderr
			'force':                upgrade_cmd_bool(config, 'force', false).str()
			'greedy':               upgrade_cmd_bool(config, 'greedy', false).str()
			'greedy_latest':        upgrade_cmd_bool(config, 'greedy_latest', false).str()
			'greedy_auto_updates':  upgrade_cmd_bool(config, 'greedy_auto_updates', false).str()
			'dry_run':              dry_run.str()
			'binaries':             upgrade_cmd_bool(config, 'binaries', true).str()
			'require_sha':          upgrade_cmd_bool(config, 'require_sha', false).str()
			'skip_cask_deps':       upgrade_cmd_bool(config, 'skip_cask_deps', false).str()
			'quit':                 (!upgrade_cmd_bool(config, 'no_quit', false)).str()
			'verbose':              upgrade_cmd_bool(config, 'verbose', false).str()
			'quiet':                quiet.str()
			'skip_prefetch':        skip_prefetch.str()
			'show_upgrade_summary': show_summary.str()
		}
		map_data: {
			'casks': ruby.array_value(casks)
		}
	}
}

// Ruby method `minimum_version = args.minimum_version || args.min_version` at line 832.
pub fn ruby_upgrade_l832_d11_minimum_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return upgrade_cmd_nil()
	}
	version := args[0].attributes['minimum_version'] or {
		args[0].attributes['min_version'] or { '' }
	}
	return if version == '' { upgrade_cmd_nil() } else { ruby.string_value(version) }
}

// Ruby method `formula_outdated?(formula)` at line 835.
pub fn ruby_upgrade_l835_d12_formula_outdated(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	config := args[0]
	formula := upgrade_cmd_formula(args[1])
	if !formula.outdated {
		return ruby.bool_value(false)
	}
	if ruby_upgrade_l846_d13_fetched_head_formula_current(config, args[1]).bool_data {
		return ruby.bool_value(false)
	}
	minimum := ruby_upgrade_l832_d11_minimum_version(config)
	if minimum.type_name == 'NilClass' {
		return ruby.bool_value(true)
	}
	return ruby.bool_value(formula.installed_versions.any(upgrade_cmd_compare_version(it, minimum.as_string()) < 0))
}

// Ruby method `fetched_head_formula_current?(formula)` at line 846.
pub fn ruby_upgrade_l846_d13_fetched_head_formula_current(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	formula := upgrade_cmd_formula(args[1])
	return ruby.bool_value(upgrade_cmd_bool(args[0], 'fetch_head', false) && formula.head && formula.optlinked && formula.old_version.starts_with('HEAD-') && formula.latest_head_pkg_version == formula.old_version)
}

// Ruby method `minimum_version_casks(casks, quiet: args.quiet?)` at line 858.
pub fn ruby_upgrade_l858_d14_minimum_version_casks(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.map_value({
			'casks': ruby.array_value([])
		})
	}
	config := args[0]
	casks := args[1].as_array() or { [] }
	quiet := args.len > 2 && args[2].bool_data
	minimum := ruby_upgrade_l832_d11_minimum_version(config)
	if minimum.type_name == 'NilClass' {
		return ruby.Value{
			type_name: 'MinimumVersionCasksResult'
			map_data: {
				'casks': ruby.array_value(casks)
			}
		}
	}
	mut selected := []ruby.Value{}
	mut warnings := []string{}
	for value in casks {
		cask := upgrade_cmd_cask(value)
		if cask.installed_version != '' && upgrade_cmd_compare_version(cask.installed_version, minimum.as_string()) < 0 {
			selected << value
		} else if !quiet {
			warnings << 'Warning: Not upgrading ${cask.token}, the installed version is not below the minimum version ${minimum.as_string()}'
		}
	}
	return ruby.Value{
		type_name: 'MinimumVersionCasksResult'
		attributes: {
			'stderr': if warnings.len > 0 { warnings.join('\n') + '\n' } else { '' }
		}
		map_data: {
			'casks': ruby.array_value(selected)
		}
	}
}

// Ruby method `show_final_upgrade_summary_section(title, items)` at line 875.
pub fn ruby_upgrade_l875_d15_show_final_upgrade_summary_section(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	items := upgrade_cmd_unique(args[1].as_string_array() or { [] })
	if items.len == 0 {
		return ruby.string_value('')
	}
	return ruby.string_value('==> ${args[0].as_string()}\n${items.join('\n')}\n')
}

// Ruby method `formula_upgrade_display_version(formula, old_version)` at line 884.
pub fn ruby_upgrade_l884_d16_formula_upgrade_display_version(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.string_value('')
	}
	config := args[0]
	formula := upgrade_cmd_formula(args[1])
	old_version := args[2].as_string()
	if !old_version.starts_with('HEAD-') || !formula.head || formula.pkg_version != old_version {
		return ruby.string_value(formula.pkg_version)
	}
	if !upgrade_cmd_bool(config, 'fetch_head', false) {
		return ruby.string_value('latest HEAD')
	}
	if formula.latest_head_pkg_version == old_version {
		return ruby.string_value('latest HEAD')
	}
	return ruby.string_value(formula.latest_head_pkg_version)
}

// Ruby method `formula_upgrade_size(formula)` at line 896.
pub fn ruby_upgrade_l896_d17_formula_upgrade_size(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	config := args[0]
	formula := upgrade_cmd_formula(args[1])
	if formula.name in upgrade_cmd_string_list(config, 'build_from_source_formulae') || formula.build_from_source || !formula.has_bottle || formula.bottle_size <= 0 {
		return ruby.string_value('')
	}
	return ruby.string_value(' (${upgrade_cmd_disk_size(formula.bottle_size)})')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula_installer"
// 6: require "install"
// 7: require "upgrade"
// 8: require "cask/download"
// 9: require "cask/utils"
// 10: require "cask/upgrade"
// 11: require "api"
// 12: require "reinstall"
// 13: require "minimum_version"
// 14: require "trust"
// 15:
// 16: module Homebrew
// 17:   module Cmd
// 18:     class UpgradeCmd < AbstractCommand
// 19:       class FormulaeUpgradeContext < T::Struct
// 20:         const :formulae_to_install, T::Array[Formula]
// 21:         const :formulae_installer, T::Array[FormulaInstaller]
// 22:         const :dependants, Homebrew::Upgrade::Dependents
// 23:         const :pinned_formulae, T::Array[Formula], default: []
// 24:       end
// 25:
// 26:       class FinalUpgradeSummary < T::Struct
// 27:         prop :version_changes, T::Array[String], default: []
// 28:         prop :pinned_formulae, T::Array[String], default: []
// 29:         prop :pinned_casks, T::Array[String], default: []
// 30:         prop :deprecated, T::Array[String], default: []
// 31:         prop :disabled, T::Array[String], default: []
// 32:         prop :source_build_formulae, T::Array[String], default: []
// 33:       end
// 34:
// 35:       cmd_args do
// 36:         description <<~EOS
// 37:           Upgrade outdated, unpinned packages using the same options they were originally installed with,
// 38:           plus any appended brew formula options. If <cask> or <formula> are specified, upgrade only the given
// 39:           <cask> or <formula> (unless they are pinned; see `pin`, `unpin`).
// 40:
// 41:           Unless `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set, `brew upgrade` or `brew reinstall` will be run for
// 42:           outdated dependents and dependents with broken linkage, respectively.
// 43:
// 44:           Unless `$HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for the
// 45:           upgraded formulae or, every 30 days, for all formulae.
// 46:         EOS
// 47:         switch "-d", "--debug",
// 48:                description: "If brewing fails, open an interactive debugging session with access to IRB " \
// 49:                             "or a shell inside the temporary build directory."
// 50:         switch "--display-times",
// 51:                description: "Print install times for each package at the end of the run.",
// 52:                env:         :display_install_times
// 53:         switch "-f", "--force",
// 54:                description: "Install formulae without checking for previously installed keg-only or " \
// 55:                             "non-migrated versions. When installing casks, overwrite existing files " \
// 56:                             "(binaries and symlinks are excluded, unless originally from the same cask)."
// 57:         switch "-v", "--verbose",
// 58:                description: "Print the verification and post-install steps."
// 59:         switch "-n", "--dry-run",
// 60:                description: "Show what would be upgraded, but do not actually upgrade anything."
// 61:         flag   "--minimum-version=", "--min-version=",
// 62:                description: "Only upgrade a named formula or cask with an installed version below the given " \
// 63:                             "minimum version."
// 64:         switch "--no-ask", "--yes", "-y",
// 65:                description: "Do not ask for confirmation before downloading and upgrading. Ask mode is the default.",
// 66:                env:         :no_ask
// 67:         switch "--ask",
// 68:                description: "Ask for confirmation before downloading and upgrading. " \
// 69:                             "Print the same plan as `--dry-run`, including available download sizes. " \
// 70:                             "When named arguments are provided, only prompts if the plan includes packages " \
// 71:                             "other than those arguments; if the requested formulae or casks are the only " \
// 72:                             "things to upgrade, it only prints the plan. With no named arguments, prompts if " \
// 73:                             "anything would be upgraded. The confirmation prompt is skipped without a TTY. " \
// 74:                             "This is the default unless `$HOMEBREW_NO_ASK` is set.",
// 75:                env:         :ask,
// 76:                replacement: "the default behaviour",
// 77:                odeprecated: true
// 78:         [
// 79:           [:switch, "--formula", "--formulae", {
// 80:             description: "Treat all named arguments as formulae. If no named arguments " \
// 81:                          "are specified, upgrade only outdated formulae.",
// 82:           }],
// 83:           [:switch, "-s", "--build-from-source", {
// 84:             description: "Compile <formula> from source even if a bottle is available.",
// 85:           }],
// 86:           [:switch, "-i", "--interactive", {
// 87:             description: "Download and patch <formula>, then open a shell. This allows the user to " \
// 88:                          "run `./configure --help` and otherwise determine how to turn the software " \
// 89:                          "package into a Homebrew package.",
// 90:           }],
// 91:           [:switch, "--force-bottle", {
// 92:             description: "Install from a bottle if it exists for the current or newest version of " \
// 93:                          "macOS, even if it would not normally be used for installation.",
// 94:           }],
// 95:           [:switch, "--fetch-HEAD", {
// 96:             description: "Fetch the upstream repository to detect if the HEAD installation of the " \
// 97:                          "formula is outdated. Otherwise, the repository's HEAD will only be checked for " \
// 98:                          "updates when a new stable or development version has been released.",
// 99:           }],
// 100:           [:switch, "--keep-tmp", {
// 101:             description: "Retain the temporary files created during installation.",
// 102:           }],
// 103:           [:switch, "--debug-symbols", {
// 104:             depends_on:  "--build-from-source",
// 105:             description: "Generate debug symbols on build. Source will be retained in a cache directory.",
// 106:           }],
// 107:           [:switch, "--overwrite", {
// 108:             description: "Delete files that already exist in the prefix while linking.",
// 109:           }],
// 110:         ].each do |args|
// 111:           options = args.pop
// 112:           send(*args, **options)
// 113:           conflicts "--cask", args.last
// 114:         end
// 115:         formula_options
// 116:         [
// 117:           [:switch, "--cask", "--casks", {
// 118:             description: "Treat all named arguments as casks. If no named arguments " \
// 119:                          "are specified, upgrade only outdated casks.",
// 120:           }],
// 121:           [:switch, "--skip-cask-deps", {
// 122:             description: "Skip installing cask dependencies.",
// 123:           }],
// 124:           [:switch, "--no-quit", {
// 125:             description: "Prevent running cask applications from being quit during upgrade.",
// 126:             env:         :no_upgrade_quit_casks,
// 127:           }],
// 128:           [:switch, "-g", "--greedy", {
// 129:             description: "Also include casks with `version :latest` and `auto_updates true` casks " \
// 130:                          "that would otherwise be skipped.",
// 131:             env:         :upgrade_greedy,
// 132:           }],
// 133:           [:switch, "--greedy-latest", {
// 134:             description: "Also include casks with `version :latest`.",
// 135:           }],
// 136:           [:switch, "--greedy-auto-updates", {
// 137:             description: "Also include `auto_updates true` casks that would otherwise be skipped.",
// 138:           }],
// 139:           [:switch, "--[no-]binaries", {
// 140:             description: "Disable/enable linking of helper executables (default: enabled).",
// 141:             env:         :cask_opts_binaries,
// 142:           }],
// 143:           [:switch, "--require-sha", {
// 144:             description: "Require all casks to have a checksum.",
// 145:             env:         :cask_opts_require_sha,
// 146:           }],
// 147:         ].each do |args|
// 148:           options = args.pop
// 149:           send(*args, **options)
// 150:           conflicts "--formula", args.last
// 151:         end
// 152:         cask_options
// 153:
// 154:         conflicts "--build-from-source", "--force-bottle"
// 155:         conflicts "--ask", "--no-ask"
// 156:
// 157:         named_args [:installed_formula, :installed_cask]
// 158:       end
// 159:
// 160:       sig { override.params(argv: T::Array[String]).void }
// 161:       def initialize(argv = ARGV.freeze)
// 162:         super
// 163:         @ask_prompt_required = T.let(false, T::Boolean)
// 164:       end
// 165:
// 166:       sig { override.void }
// 167:       def run
// 168:         if args.build_from_source? && args.named.empty?
// 169:           raise ArgumentError, "`--build-from-source` requires at least one formula"
// 170:         end
// 171:         raise UsageError, "`--minimum-version` requires exactly one formula or cask argument." if
// 172:           minimum_version.present? && args.named.length != 1
// 173:
// 174:         formulae = T.let([], T::Array[Formula])
// 175:         casks = T.let([], T::Array[Cask::Cask])
// 176:         unavailable_errors = T.let(
// 177:           [],
// 178:           T::Array[T.any(FormulaOrCaskUnavailableError, NoSuchKegError)],
// 179:         )
// 180:         @prefetched_formulae_upgrade_context = T.let(nil, T.nilable(FormulaeUpgradeContext))
// 181:         prefetched_formulae_names = T.let([], T::Array[String])
// 182:         prefetched_formulae_upgrades = T.let([], T::Array[String])
// 183:         prefetched_cask_names = T.let([], T::Array[String])
// 184:         prefetched_cask_upgrades = T.let([], T::Array[String])
// 185:         prefetched_cask_upgrade_casks = T.let([], T::Array[Cask::Cask])
// 186:         prefetched_cask_errors = T.let([], T::Array[StandardError])
// 187:         @final_upgrade_summary = T.let(FinalUpgradeSummary.new, T.nilable(FinalUpgradeSummary))
// 188:         @ask_prompt_required = false
// 189:         ask = !args.no_ask? && !args.dry_run?
// 190:         skip_upgrades_after_failed_ask_preview = T.let(false, T::Boolean)
// 191:
// 192:         if args.named.present?
// 193:           Homebrew::Trust.trust_fully_qualified_items!(args.named, type: args.only_formula_or_cask)
// 194:
// 195:           args.named.to_formulae_and_casks_and_unavailable(method: :resolve).each do |item|
// 196:             case item
// 197:             when FormulaOrCaskUnavailableError, NoSuchKegError
// 198:               unavailable_errors << item
// 199:             when Formula
// 200:               formulae << item
// 201:             when Cask::Cask
// 202:               casks << item
// 203:             end
// 204:           end
// 205:         end
// 206:
// 207:         # If one or more formulae are specified, but no casks were
// 208:         # specified, we want to make note of that so we don't
// 209:         # try to upgrade all outdated casks.
// 210:         #
// 211:         # When names were given, we must also prevent empty resolved lists
// 212:         # from triggering the "upgrade all" path (which happens when all
// 213:         # names failed resolution).
// 214:         named_given = args.named.present?
// 215:         only_upgrade_formulae = (named_given && casks.blank?) || (formulae.present? && casks.blank?)
// 216:         only_upgrade_casks = (named_given && formulae.blank?) || (casks.present? && formulae.blank?)
// 217:
// 218:         if Homebrew::EnvConfig.verify_attestations?
// 219:           formulae = Homebrew::Attestation.sort_formulae_for_install(formulae)
// 220:         end
// 221:
// 222:         formulae_prefetched = T.let(false, T::Boolean)
// 223:         prefetched_casks = T.let(false, T::Boolean)
// 224:         ask_upgrade_planned = T.let(false, T::Boolean)
// 225:         shared_download_queue = T.let(nil, T.nilable(Homebrew::DownloadQueue))
// 226:         if ask
// 227:           unless only_upgrade_casks
// 228:             upgrade_outdated_formulae!(
// 229:               formulae,
// 230:               dry_run:              true,
// 231:               show_upgrade_summary: false,
// 232:             )
// 233:           end
// 234:           unless only_upgrade_formulae
// 235:             upgrade_outdated_casks!(
// 236:               casks,
// 237:               dry_run:              true,
// 238:               skip_prefetch:        false,
// 239:               show_upgrade_summary: false,
// 240:               download_queue:       nil,
// 241:             )
// 242:           end
// 243:
// 244:           show_final_upgrade_summary(dry_run: true)
// 245:           if Install.ask_prompt_needed?(
// 246:             planned_names:   final_upgrade_summary.version_changes.map do |version_change|
// 247:               planned_name = version_change.split.fetch(0)
// 248:               formulae.find { |formula| formula.full_specified_name == planned_name }&.full_name || planned_name
// 249:             end,
// 250:             requested_names: args.named,
// 251:             force:           @ask_prompt_required,
// 252:             named:           args.named.present?,
// 253:           )
// 254:             Install.ask(action: "upgrade")
// 255:             Cask::Upgrade.show_upgrade_summary(final_upgrade_summary.version_changes)
// 256:           end
// 257:           ask_upgrade_planned = final_upgrade_summary.version_changes.present?
// 258:           skip_upgrades_after_failed_ask_preview = Homebrew.failed? && !ask_upgrade_planned
// 259:           @final_upgrade_summary = FinalUpgradeSummary.new
// 260:         end
// 261:
// 262:         if !args.dry_run? && (!ask || ask_upgrade_planned) && !only_upgrade_formulae && !only_upgrade_casks
// 263:           shared_download_queue = Homebrew::DownloadQueue.new(pour: true)
// 264:           begin
// 265:             formulae_prefetched = upgrade_outdated_formulae!(
// 266:               formulae,
// 267:               prefetch_only:        true,
// 268:               download_queue:       shared_download_queue,
// 269:               prefetch_names:       prefetched_formulae_names,
// 270:               prefetch_upgrades:    prefetched_formulae_upgrades,
// 271:               show_upgrade_summary: false,
// 272:             )
// 273:             prefetched_casks = prefetch_outdated_casks!(
// 274:               casks,
// 275:               download_queue:    shared_download_queue,
// 276:               prefetch_names:    prefetched_cask_names,
// 277:               prefetch_upgrades: prefetched_cask_upgrades,
// 278:               prefetch_casks:    prefetched_cask_upgrade_casks,
// 279:               prefetch_errors:   prefetched_cask_errors,
// 280:             )
// 281:             unless ask
// 282:               Cask::Upgrade.show_upgrade_summary(
// 283:                 prefetched_formulae_upgrades + prefetched_cask_upgrades,
// 284:                 dry_run: args.dry_run?,
// 285:               )
// 286:             end
// 287:             shared_download_queue.fetch(heading: Install.combined_fetch_downloads_heading(
// 288:               formula_names: prefetched_formulae_names,
// 289:               cask_names:    prefetched_cask_names,
// 290:             ))
// 291:             # Only redo the slower unprefetched fetch for the kind of package
// 292:             # that actually failed, so e.g. one bad bottle does not also
// 293:             # re-verify every already downloaded cask.
// 294:             failed_cask_downloads, failed_formula_downloads =
// 295:               shared_download_queue.failed_downloads.partition { |download| download.is_a?(Cask::Download) }
// 296:             formulae_prefetched = false if failed_formula_downloads.any?
// 297:             prefetched_casks = false if failed_cask_downloads.any?
// 298:           ensure
// 299:             shared_download_queue.shutdown
// 300:           end
// 301:         end
// 302:
// 303:         if !only_upgrade_casks && !skip_upgrades_after_failed_ask_preview
// 304:           upgrade_outdated_formulae!(
// 305:             formulae,
// 306:             use_prefetched:       formulae_prefetched,
// 307:             show_upgrade_summary: prefetched_formulae_upgrades.blank? && !args.dry_run? && !ask,
// 308:           )
// 309:         end
// 310:         if !only_upgrade_formulae && !skip_upgrades_after_failed_ask_preview
// 311:           if prefetched_casks
// 312:             upgrade_outdated_casks!(
// 313:               prefetched_cask_upgrade_casks,
// 314:               skip_prefetch:          true,
// 315:               show_upgrade_summary:   prefetched_cask_upgrades.blank? && !args.dry_run? && !ask,
// 316:               download_queue:         nil,
// 317:               prefetched_cask_errors: prefetched_cask_errors,
// 318:             )
// 319:           else
// 320:             upgrade_outdated_casks!(
// 321:               casks,
// 322:               skip_prefetch:        false,
// 323:               show_upgrade_summary: prefetched_cask_upgrades.blank? && !args.dry_run? && !ask,
// 324:               download_queue:       nil,
// 325:             )
// 326:           end
// 327:         end
// 328:
// 329:         unavailable_errors.each { |e| ofail e }
// 330:
// 331:         Cleanup.periodic_clean!(dry_run: args.dry_run?)
// 332:
// 333:         Homebrew::Reinstall.reinstall_pkgconf_if_needed!(dry_run: args.dry_run?)
// 334:
// 335:         Homebrew.messages.display_messages(display_times: args.display_times?)
// 336:
// 337:         show_final_upgrade_summary
// 338:       end
// 339:
// 340:       sig {
// 341:         params(formulae: T::Array[Formula], show_upgrade_summary: T::Boolean,
// 342:                dry_run: T::Boolean).returns(T.nilable(FormulaeUpgradeContext))
// 343:       }
// 344:       def formulae_upgrade_context(formulae, show_upgrade_summary: true, dry_run: args.dry_run?)
// 345:         if args.build_from_source?
// 346:           unless DevelopmentTools.installed?
// 347:             raise BuildFlagsError.new(["--build-from-source"], bottled: formulae.all?(&:bottled?))
// 348:           end
// 349:
// 350:           unless Homebrew::EnvConfig.developer?
// 351:             opoo "building from source is not supported!"
// 352:             puts "You're on your own. Failures are expected so don't create any issues, please!"
// 353:           end
// 354:         end
// 355:
// 356:         quiet = args.quiet? || (dry_run && !args.dry_run?)
// 357:         not_outdated = T.let([], T::Array[Formula])
// 358:         if formulae.blank?
// 359:           outdated = Formula.installed.select do |f|
// 360:             formula_outdated?(f)
// 361:           end
// 362:         elsif minimum_version.present?
// 363:           outdated, not_outdated = formulae.partition do |f|
// 364:             f.outdated?(fetch_head: args.fetch_HEAD?)
// 365:           end
// 366:           outdated, minimum_version_skipped = outdated.partition do |f|
// 367:             MinimumVersion.formula_outdated_kegs(f, minimum_version, fetch_head: args.fetch_HEAD?).present?
// 368:           end
// 369:
// 370:           minimum_version_skipped.each do |f|
// 371:             next if quiet
// 372:
// 373:             opoo "Not upgrading #{f.full_specified_name}, the installed version is not below " \
// 374:                  "the minimum version #{minimum_version}"
// 375:           end
// 376:         else
// 377:           outdated, not_outdated = formulae.partition do |f|
// 378:             formula_outdated?(f)
// 379:           end
// 380:         end
// 381:
// 382:         if formulae.present?
// 383:           not_outdated.each do |f|
// 384:             latest_keg = f.installed_kegs.max_by(&:scheme_and_version)
// 385:             if latest_keg.nil?
// 386:               ofail "#{f.full_specified_name} not installed"
// 387:             else
// 388:               opoo "#{f.full_specified_name} #{latest_keg.version} already installed" unless quiet
// 389:             end
// 390:           end
// 391:         end
// 392:
// 393:         return if outdated.blank?
// 394:
// 395:         pinned = outdated.select(&:pinned?)
// 396:         outdated -= pinned
// 397:         formulae_to_install = outdated.map do |f|
// 398:           f_latest = f.latest_formula
// 399:           if f_latest.latest_version_installed?
// 400:             f
// 401:           else
// 402:             f_latest
// 403:           end
// 404:         end
// 405:
// 406:         if formulae_to_install.empty?
// 407:           oh1 "No packages to upgrade" if show_upgrade_summary
// 408:         elsif show_upgrade_summary
// 409:           verb = dry_run ? "Would upgrade" : "Upgrading"
// 410:           oh1 "#{verb} #{formulae_to_install.count} outdated #{Utils.pluralize("package",
// 411:                                                                                formulae_to_install.count)}:"
// 412:           puts Upgrade.format_upgrade_summary(formula_upgrade_descriptions(formulae_to_install)).join("\n") if
// 413:             args.no_ask?
// 414:         end
// 415:
// 416:         Install.perform_preinstall_checks_once
// 417:
// 418:         formulae_installer = Upgrade.formula_installers(
// 419:           formulae_to_install,
// 420:           flags:                      args.flags_only,
// 421:           dry_run:,
// 422:           force_bottle:               args.force_bottle?,
// 423:           build_from_source_formulae: args.build_from_source_formulae,
// 424:           interactive:                args.interactive?,
// 425:           keep_tmp:                   args.keep_tmp?,
// 426:           debug_symbols:              args.debug_symbols?,
// 427:           force:                      args.force?,
// 428:           overwrite:                  args.overwrite?,
// 429:           debug:                      args.debug?,
// 430:           quiet:                      args.quiet?,
// 431:           verbose:                    args.verbose?,
// 432:         )
// 433:
// 434:         if formulae_installer.blank?
// 435:           return if formulae_to_install.present?
// 436:           return if pinned.blank?
// 437:         end
// 438:
// 439:         if pinned.any?
// 440:           message = "Not upgrading #{pinned.count} pinned #{Utils.pluralize("package", pinned.count)}:"
// 441:           # only fail when pinned formulae are named explicitly
// 442:           if formulae.any?
// 443:             ofail message
// 444:           else
// 445:             opoo message
// 446:           end
// 447:           puts pinned.map { |f| "#{f.full_specified_name} #{f.pkg_version}" } * ", "
// 448:         end
// 449:
// 450:         if formulae_installer.blank?
// 451:           return FormulaeUpgradeContext.new(
// 452:             formulae_to_install:,
// 453:             formulae_installer:  formulae_installer,
// 454:             dependants:          Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: []),
// 455:             pinned_formulae:     pinned,
// 456:           )
// 457:         end
// 458:
// 459:         dependants = Upgrade.dependants(
// 460:           formulae_to_install,
// 461:           flags:                      args.flags_only,
// 462:           dry_run:,
// 463:           ask:                        !args.no_ask?,
// 464:           force_bottle:               args.force_bottle?,
// 465:           build_from_source_formulae: args.build_from_source_formulae,
// 466:           interactive:                args.interactive?,
// 467:           keep_tmp:                   args.keep_tmp?,
// 468:           debug_symbols:              args.debug_symbols?,
// 469:           force:                      args.force?,
// 470:           debug:                      args.debug?,
// 471:           quiet:                      args.quiet?,
// 472:           verbose:                    args.verbose?,
// 473:         )
// 474:
// 475:         FormulaeUpgradeContext.new(
// 476:           formulae_to_install:,
// 477:           formulae_installer:  formulae_installer,
// 478:           dependants:,
// 479:           pinned_formulae:     pinned,
// 480:         )
// 481:       end
// 482:
// 483:       sig { returns(FinalUpgradeSummary) }
// 484:       def final_upgrade_summary
// 485:         @final_upgrade_summary ||= T.let(FinalUpgradeSummary.new, T.nilable(FinalUpgradeSummary))
// 486:         @final_upgrade_summary
// 487:       end
// 488:
// 489:       sig {
// 490:         params(
// 491:           context:            FormulaeUpgradeContext,
// 492:           include_sizes:      T::Boolean,
// 493:           formulae_installer: T.nilable(T::Array[FormulaInstaller]),
// 494:           version_changes:    T.nilable(T::Array[String]),
// 495:         ).void
// 496:       }
// 497:       def record_formula_upgrade_summary(context, include_sizes: false, formulae_installer: nil, version_changes: nil)
// 498:         summary = final_upgrade_summary
// 499:         formulae_installer ||= context.formulae_installer
// 500:         upgrade_formulae = formulae_installer.map(&:formula)
// 501:         dependent_formulae = context.dependants.upgradeable
// 502:         summary.version_changes.concat(
// 503:           version_changes || (formula_upgrade_descriptions(upgrade_formulae, include_sizes:) +
// 504:             formula_upgrade_descriptions(dependent_formulae, include_sizes:)),
// 505:         )
// 506:         summary.pinned_formulae.concat((context.pinned_formulae + context.dependants.pinned).map do |formula|
// 507:           "#{formula.full_specified_name} #{formula.pkg_version}"
// 508:         end)
// 509:
// 510:         formulae = context.formulae_to_install + context.pinned_formulae +
// 511:                    context.dependants.upgradeable + context.dependants.pinned
// 512:         summary.deprecated.concat(formulae.filter_map do |formula|
// 513:           formula.full_specified_name if formula.deprecated?
// 514:         end)
// 515:         summary.disabled.concat(formulae.filter_map do |formula|
// 516:           formula.full_specified_name if formula.disabled?
// 517:         end)
// 518:         summary.source_build_formulae.concat(formulae_installer.filter_map do |formula_installer|
// 519:           formula = formula_installer.formula
// 520:           next unless formula.core_formula?
// 521:           next if formula_installer.pour_bottle?
// 522:
// 523:           formula.full_specified_name
// 524:         end)
// 525:       end
// 526:
// 527:       sig { params(dry_run: T::Boolean).void }
// 528:       def show_final_upgrade_summary(dry_run: args.dry_run?)
// 529:         summary = final_upgrade_summary
// 530:         return if summary.version_changes.empty? && summary.pinned_formulae.empty? && summary.pinned_casks.empty? &&
// 531:                   summary.deprecated.empty? && summary.disabled.empty? && summary.source_build_formulae.empty?
// 532:
// 533:         if summary.version_changes.present?
// 534:           version_change_count = summary.version_changes.uniq.count
// 535:           show_final_upgrade_summary_section(
// 536:             "#{dry_run ? "Would upgrade" : "Upgraded"} #{version_change_count} outdated " \
// 537:             "#{Utils.pluralize("package", version_change_count)}",
// 538:             Upgrade.format_upgrade_summary(summary.version_changes),
// 539:           )
// 540:         end
// 541:         if summary.pinned_formulae.present?
// 542:           pinned_count = summary.pinned_formulae.uniq.count
// 543:           show_final_upgrade_summary_section(
// 544:             "#{pinned_count} Pinned #{Utils.pluralize("formula", pinned_count)}",
// 545:             summary.pinned_formulae,
// 546:           )
// 547:         end
// 548:         if summary.pinned_casks.present?
// 549:           pinned_count = summary.pinned_casks.uniq.count
// 550:           show_final_upgrade_summary_section(
// 551:             "#{pinned_count} Pinned #{Utils.pluralize("cask", pinned_count)}",
// 552:             summary.pinned_casks,
// 553:           )
// 554:         end
// 555:         deprecate_disable_summary = summary.deprecated.map { |item| "#{item} (deprecated)" } +
// 556:                                     summary.disabled.map { |item| "#{item} (disabled)" }
// 557:         deprecate_disable_count = deprecate_disable_summary.uniq.count
// 558:         show_final_upgrade_summary_section(
// 559:           "#{deprecate_disable_count} Deprecated or disabled #{Utils.pluralize("package", deprecate_disable_count)}",
// 560:           deprecate_disable_summary,
// 561:         )
// 562:         source_build_count = summary.source_build_formulae.uniq.count
// 563:         if dry_run
// 564:           show_final_upgrade_summary_section(
// 565:             "#{source_build_count} homebrew/core " \
// 566:             "#{Utils.pluralize("formula", source_build_count)} that would build from source",
// 567:             summary.source_build_formulae,
// 568:           )
// 569:         else
// 570:           show_final_upgrade_summary_section(
// 571:             "#{source_build_count} homebrew/core #{Utils.pluralize("formula", source_build_count)} built from source",
// 572:             summary.source_build_formulae,
// 573:           )
// 574:         end
// 575:       end
// 576:
// 577:       sig { params(formulae: T::Array[Formula], include_sizes: T::Boolean).returns(T::Array[String]) }
// 578:       def formula_upgrade_descriptions(formulae, include_sizes: false)
// 579:         formulae.map do |formula|
// 580:           if formula.optlinked?
// 581:             old_keg = Keg.new(formula.opt_prefix)
// 582:             old_version = old_keg.version
// 583:             new_version = formula_upgrade_display_version(formula, old_version)
// 584:             if include_sizes
// 585:               "#{formula.full_specified_name} #{old_version} -> " \
// 586:                 "#{new_version}#{formula_upgrade_size(formula)}"
// 587:             else
// 588:               "#{formula.full_specified_name} #{old_version} -> #{new_version}"
// 589:             end
// 590:           elsif include_sizes
// 591:             "#{formula.full_specified_name} #{formula.pkg_version}#{formula_upgrade_size(formula)}"
// 592:           else
// 593:             "#{formula.full_specified_name} #{formula.pkg_version}"
// 594:           end
// 595:         end
// 596:       end
// 597:
// 598:       sig {
// 599:         params(
// 600:           formulae:             T::Array[Formula],
// 601:           prefetch_only:        T::Boolean,
// 602:           use_prefetched:       T::Boolean,
// 603:           dry_run:              T::Boolean,
// 604:           download_queue:       T.nilable(Homebrew::DownloadQueue),
// 605:           prefetch_names:       T.nilable(T::Array[String]),
// 606:           prefetch_upgrades:    T.nilable(T::Array[String]),
// 607:           show_upgrade_summary: T::Boolean,
// 608:         ).returns(T::Boolean)
// 609:       }
// 610:       def upgrade_outdated_formulae!(formulae, prefetch_only: false, use_prefetched: false,
// 611:                                      dry_run: args.dry_run?,
// 612:                                      download_queue: nil,
// 613:                                      prefetch_names: nil,
// 614:                                      prefetch_upgrades: nil,
// 615:                                      show_upgrade_summary: true)
// 616:         return false if args.cask?
// 617:
// 618:         use_prefetched_context = use_prefetched && @prefetched_formulae_upgrade_context
// 619:         context = if use_prefetched_context
// 620:           @prefetched_formulae_upgrade_context
// 621:         else
// 622:           formulae_upgrade_context(formulae, show_upgrade_summary:, dry_run:)
// 623:         end
// 624:         return false if context.blank?
// 625:
// 626:         if prefetch_only
// 627:           prefetch_download_queue = download_queue || Homebrew.default_download_queue
// 628:           valid_formula_installers = Install.enqueue_formulae(context.formulae_installer,
// 629:                                                               download_queue: prefetch_download_queue)
// 630:           prefetch_names&.replace(valid_formula_installers.map { |fi| fi.formula.name })
// 631:           prefetch_upgrades&.replace(formula_upgrade_descriptions(valid_formula_installers.map(&:formula)))
// 632:           @prefetched_formulae_upgrade_context = FormulaeUpgradeContext.new(
// 633:             formulae_to_install: context.formulae_to_install,
// 634:             formulae_installer:  valid_formula_installers,
// 635:             dependants:          context.dependants,
// 636:             pinned_formulae:     context.pinned_formulae,
// 637:           )
// 638:           return valid_formula_installers.present?
// 639:         end
// 640:
// 641:         formula_version_changes = formula_upgrade_descriptions(context.formulae_installer.map(&:formula),
// 642:                                                                include_sizes: dry_run)
// 643:         dependent_formulae = context.dependants.upgradeable.dup
// 644:         dependent_version_changes = formula_upgrade_descriptions(dependent_formulae,
// 645:                                                                  include_sizes: dry_run)
// 646:         if dry_run
// 647:           record_formula_upgrade_summary(context,
// 648:                                          version_changes: formula_version_changes + dependent_version_changes)
// 649:         end
// 650:         if !args.no_ask? && dry_run && args.named.present? &&
// 651:            Install.formulae_ask_prompt_needed?(context.formulae_installer, context.dependants)
// 652:           @ask_prompt_required = true
// 653:         end
// 654:
// 655:         skip_formula_names = if dry_run
// 656:           (context.formulae_installer.map(&:formula) + context.dependants.upgradeable)
// 657:             .uniq(&:full_name)
// 658:             .map(&:full_name)
// 659:         else
// 660:           []
// 661:         end
// 662:
// 663:         upgraded_formula_installers = Upgrade.upgrade_formulae(
// 664:           context.formulae_installer,
// 665:           dry_run:,
// 666:           verbose:            args.verbose?,
// 667:           fetch:              !use_prefetched_context,
// 668:           skip_formula_names:,
// 669:         )
// 670:
// 671:         upgraded_dependent_formulae = Upgrade.upgrade_dependents(
// 672:           context.dependants, context.formulae_to_install,
// 673:           flags:                      args.flags_only,
// 674:           dry_run:,
// 675:           force_bottle:               args.force_bottle?,
// 676:           build_from_source_formulae: args.build_from_source_formulae,
// 677:           interactive:                args.interactive?,
// 678:           keep_tmp:                   args.keep_tmp?,
// 679:           debug_symbols:              args.debug_symbols?,
// 680:           force:                      args.force?,
// 681:           debug:                      args.debug?,
// 682:           quiet:                      args.quiet?,
// 683:           verbose:                    args.verbose?,
// 684:           skip_formula_names:
// 685:         )
// 686:
// 687:         unless dry_run
// 688:           upgraded_formulae_by_identity = T.let({}.compare_by_identity, T::Hash[Formula, T::Boolean])
// 689:           (upgraded_formula_installers.map(&:formula) + upgraded_dependent_formulae).each do |formula|
// 690:             upgraded_formulae_by_identity[formula] = true
// 691:           end
// 692:           planned_formulae = context.formulae_installer.map(&:formula) + dependent_formulae
// 693:           version_changes = formula_version_changes + dependent_version_changes
// 694:           record_formula_upgrade_summary(
// 695:             context,
// 696:             formulae_installer: upgraded_formula_installers,
// 697:             version_changes:    planned_formulae.each_with_index.filter_map do |formula, index|
// 698:               version_changes.fetch(index) if upgraded_formulae_by_identity.key?(formula)
// 699:             end,
// 700:           )
// 701:         end
// 702:
// 703:         @prefetched_formulae_upgrade_context = nil if use_prefetched_context
// 704:         true
// 705:       end
// 706:
// 707:       sig {
// 708:         params(casks: T::Array[Cask::Cask], download_queue: Homebrew::DownloadQueue,
// 709:                prefetch_names: T.nilable(T::Array[String]),
// 710:                prefetch_upgrades: T.nilable(T::Array[String]),
// 711:                prefetch_casks: T.nilable(T::Array[Cask::Cask]),
// 712:                prefetch_errors: T.nilable(T::Array[StandardError]))
// 713:           .returns(T::Boolean)
// 714:       }
// 715:       def prefetch_outdated_casks!(casks, download_queue:, prefetch_names: nil,
// 716:                                    prefetch_upgrades: nil, prefetch_casks: nil, prefetch_errors: nil)
// 717:         return false if args.formula?
// 718:
// 719:         casks = minimum_version_casks(casks, quiet: true)
// 720:         return false if minimum_version.present? && casks.empty?
// 721:
// 722:         outdated_casks = Cask::Upgrade.outdated_casks(
// 723:           casks,
// 724:           args:,
// 725:           force:               args.force?,
// 726:           quiet:               true,
// 727:           greedy:              args.greedy?,
// 728:           greedy_latest:       args.greedy_latest?,
// 729:           greedy_auto_updates: args.greedy_auto_updates?,
// 730:         )
// 731:         return false if outdated_casks.empty?
// 732:
// 733:         manual_installer_casks = outdated_casks.select do |cask|
// 734:           cask.artifacts.any? do |artifact|
// 735:             artifact.is_a?(Cask::Artifact::Installer) && artifact.manual_install
// 736:           end
// 737:         end
// 738:         outdated_casks -= manual_installer_casks
// 739:         return false if outdated_casks.empty?
// 740:
// 741:         require "cask/installer"
// 742:         fetchable_cask_installers = []
// 743:         outdated_casks.select! do |cask|
// 744:           installer = Cask::Installer.new(
// 745:             cask,
// 746:             binaries:       args.binaries?,
// 747:             verbose:        args.verbose?,
// 748:             force:          args.force?,
// 749:             skip_cask_deps: args.skip_cask_deps?,
// 750:             require_sha:    args.require_sha?,
// 751:             upgrade:        true,
// 752:             download_queue:,
// 753:             defer_fetch:    true,
// 754:           )
// 755:           begin
// 756:             installer.check_requirements
// 757:           rescue Cask::CaskError => e
// 758:             prefetch_errors&.push(e)
// 759:             next false
// 760:           end
// 761:
// 762:           fetchable_cask_installers << installer
// 763:           true
// 764:         end
// 765:         prefetch_casks&.replace(outdated_casks)
// 766:         return prefetch_errors.present? if outdated_casks.empty?
// 767:
// 768:         cask_names = outdated_casks.map(&:full_name)
// 769:         Install.enqueue_cask_installers(fetchable_cask_installers, download_queue:)
// 770:         prefetch_names&.replace(cask_names)
// 771:         prefetch_upgrades&.replace(
// 772:           outdated_casks.map { |cask| "#{cask.full_name} #{cask.installed_version} -> #{cask.version}" },
// 773:         )
// 774:         true
// 775:       rescue => e
// 776:         ofail e
// 777:         false
// 778:       end
// 779:
// 780:       sig {
// 781:         params(casks: T::Array[Cask::Cask], skip_prefetch: T::Boolean, show_upgrade_summary: T::Boolean,
// 782:                dry_run: T::Boolean,
// 783:                download_queue: T.nilable(Homebrew::DownloadQueue),
// 784:                prefetched_cask_errors: T.nilable(T::Array[StandardError]))
// 785:           .returns(T::Boolean)
// 786:       }
// 787:       def upgrade_outdated_casks!(casks, skip_prefetch: false, show_upgrade_summary: true,
// 788:                                   dry_run: args.dry_run?,
// 789:                                   download_queue: nil, prefetched_cask_errors: nil)
// 790:         return false if args.formula?
// 791:
// 792:         quiet = args.quiet? || (dry_run && !args.dry_run?)
// 793:         casks = minimum_version_casks(casks, quiet:)
// 794:         return false if minimum_version.present? && casks.empty?
// 795:
// 796:         if skip_prefetch && casks.empty? && prefetched_cask_errors.present?
// 797:           prefetched_cask_errors.each { |error| ofail error }
// 798:           return false
// 799:         end
// 800:
// 801:         Cask::Upgrade.upgrade_casks!(
// 802:           *casks,
// 803:           force:                args.force?,
// 804:           greedy:               args.greedy?,
// 805:           greedy_latest:        args.greedy_latest?,
// 806:           greedy_auto_updates:  args.greedy_auto_updates?,
// 807:           dry_run:,
// 808:           binaries:             args.binaries?,
// 809:           require_sha:          args.require_sha?,
// 810:           skip_cask_deps:       args.skip_cask_deps?,
// 811:           quit:                 !args.no_quit?,
// 812:           verbose:              args.verbose?,
// 813:           quiet:,
// 814:           skip_prefetch:,
// 815:           show_upgrade_summary:,
// 816:           download_queue:,
// 817:           summary_upgrades:     final_upgrade_summary.version_changes,
// 818:           summary_pinned:       final_upgrade_summary.pinned_casks,
// 819:           summary_deprecated:   final_upgrade_summary.deprecated,
// 820:           summary_disabled:     final_upgrade_summary.disabled,
// 821:           prefetched_errors:    prefetched_cask_errors,
// 822:           args:,
// 823:         )
// 824:       rescue => e
// 825:         ofail e
// 826:         false
// 827:       end
// 828:
// 829:       private
// 830:
// 831:       sig { returns(T.nilable(String)) }
// 832:       def minimum_version = args.minimum_version || args.min_version
// 833:
// 834:       sig { params(formula: Formula).returns(T::Boolean) }
// 835:       def formula_outdated?(formula)
// 836:         outdated = formula.outdated?(fetch_head: args.fetch_HEAD?)
// 837:         return false if outdated && fetched_head_formula_current?(formula)
// 838:
// 839:         version = minimum_version
// 840:         return outdated if version.blank?
// 841:
// 842:         outdated && MinimumVersion.formula_outdated_kegs(formula, version, fetch_head: args.fetch_HEAD?).present?
// 843:       end
// 844:
// 845:       sig { params(formula: Formula).returns(T::Boolean) }
// 846:       def fetched_head_formula_current?(formula)
// 847:         return false unless args.fetch_HEAD?
// 848:         return false unless formula.head?
// 849:         return false unless formula.optlinked?
// 850:
// 851:         old_version = Keg.new(formula.opt_prefix).version
// 852:         return false unless old_version.head?
// 853:
// 854:         formula.latest_head_pkg_version(fetch_head: true).to_s == old_version.to_s
// 855:       end
// 856:
// 857:       sig { params(casks: T::Array[Cask::Cask], quiet: T::Boolean).returns(T::Array[Cask::Cask]) }
// 858:       def minimum_version_casks(casks, quiet: args.quiet?)
// 859:         version = minimum_version
// 860:         return casks if version.blank?
// 861:
// 862:         casks.select do |cask|
// 863:           if MinimumVersion.cask_installed_below?(cask, version)
// 864:             true
// 865:           else
// 866:             unless quiet
// 867:               opoo "Not upgrading #{cask.token}, the installed version is not below the minimum version #{version}"
// 868:             end
// 869:             false
// 870:           end
// 871:         end
// 872:       end
// 873:
// 874:       sig { params(title: String, items: T::Array[String]).void }
// 875:       def show_final_upgrade_summary_section(title, items)
// 876:         items = items.uniq
// 877:         return if items.empty?
// 878:
// 879:         oh1 title
// 880:         puts items.join("\n")
// 881:       end
// 882:
// 883:       sig { params(formula: Formula, old_version: PkgVersion).returns(String) }
// 884:       def formula_upgrade_display_version(formula, old_version)
// 885:         return formula.pkg_version.to_s if !old_version.head? || !formula.head?
// 886:         return formula.pkg_version.to_s if formula.pkg_version.to_s != old_version.to_s
// 887:         return "latest HEAD" unless args.fetch_HEAD?
// 888:
// 889:         latest_head_version = formula.latest_head_pkg_version(fetch_head: true)
// 890:         return "latest HEAD" if latest_head_version.to_s == old_version.to_s
// 891:
// 892:         latest_head_version.to_s
// 893:       end
// 894:
// 895:       sig { params(formula: Formula).returns(String) }
// 896:       def formula_upgrade_size(formula)
// 897:         return "" if args.build_from_source_formulae.include?(formula.name)
// 898:
// 899:         bottle = formula.bottle
// 900:         return "" unless bottle
// 901:
// 902:         bottle.fetch_tab(quiet: !args.debug?)
// 903:         return "" unless (download_size = bottle.bottle_size)
// 904:
// 905:         " (#{Formatter.disk_usage_readable(download_size.to_i)})"
// 906:       end
// 907:     end
// 908:   end
// 909: end
