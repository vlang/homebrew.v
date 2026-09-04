module cmd

import ruby

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
