module cmd

import brew_runtime
import homebrew.cmd as info_cmd
import os
import x.json2

fn info_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn info_spec_tap(name string) brew_runtime.Value {
	path := os.join_path(os.temp_dir(), name.replace('/', '-'))
	repository := if name == 'homebrew/core' {
		'Homebrew/homebrew-core'
	} else if name == 'homebrew/cask' {
		'Homebrew/homebrew-cask'
	} else {
		name
	}
	return brew_runtime.structured_value('Tap', name, {
		'name':           name
		'path':           path
		'remote':         'https://github.com/${repository}'
		'default_remote': 'https://github.com/${repository}'
		'official':       name.starts_with('homebrew/').str()
	})
}

fn info_spec_tab(installed_on_request ?bool, source_tap string, runtime []string,
	poured bool) brew_runtime.Value {
	present := installed_on_request != none
	return brew_runtime.structured_value('Tab', 'Tab', {
		'installed_on_request_present': present.str()
		'installed_on_request':         (installed_on_request or { false }).str()
		'source_tap':                   source_tap
		'runtime_dependencies':         runtime.join('\x1f')
		'poured_from_bottle':           poured.str()
	})
}

fn info_spec_keg(name string, version string, size i64, linked bool, binaries []string,
	tab brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Keg'
		repr: version
		map_data: {
			'tab': tab
		}
		attributes: {
			'name':     name
			'version':  version
			'size':     size.str()
			'linked':   linked.str()
			'binaries': binaries.join('\x1f')
		}
	}
}

fn info_spec_formula(name string, attributes map[string]string,
	fields map[string]brew_runtime.Value) brew_runtime.Value {
	mut values := attributes.clone()
	tap_name := values['tap'] or { 'homebrew/core' }
	tap := info_spec_tap(tap_name)
	tap_path := tap.attributes['path'] or { '' }
	values['kind'] = 'formula'
	values['name'] = name
	values['full_name'] = values['full_name'] or {
		if tap_name == 'homebrew/core' {
			name
		} else {
			'${tap_name}/${name}'
		}
	}
	values['version'] = values['version'] or { '0.1' }
	values['stable_version'] = values['stable_version'] or { values['version'] }
	values['has_stable'] = values['has_stable'] or { 'true' }
	values['pour_bottle'] = values['pour_bottle'] or { 'true' }
	values['path'] = values['path'] or { os.join_path(tap_path, 'Formula', '${name}.rb') }
	mut mapped := fields.clone()
	mapped['tap'] = tap
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: name
		map_data: mapped
		attributes: values
	}
}

fn info_spec_cask(name string, attributes map[string]string,
	fields map[string]brew_runtime.Value) brew_runtime.Value {
	mut values := attributes.clone()
	tap_name := values['tap'] or { 'homebrew/cask' }
	tap := info_spec_tap(tap_name)
	tap_path := tap.attributes['path'] or { '' }
	values['kind'] = 'cask'
	values['name'] = name
	values['full_name'] = values['full_name'] or { name }
	values['version'] = values['version'] or { '1.0' }
	values['sourcefile_path'] = values['sourcefile_path'] or {
		os.join_path(tap_path, 'Casks', '${name}.rb')
	}
	mut mapped := fields.clone()
	mapped['tap'] = tap
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: name
		map_data: mapped
		attributes: values
	}
}

fn info_spec_dependency(name string, kind string, installed bool, outdated bool,
	any_installed bool) brew_runtime.Value {
	return brew_runtime.structured_value('Dependency', name, {
		'name':                  name
		'kind':                  kind
		'installed':             installed.str()
		'outdated':              outdated.str()
		'any_version_installed': any_installed.str()
	})
}

fn info_spec_requirement(display string, kind string, satisfied bool,
	other_os bool) brew_runtime.Value {
	return brew_runtime.structured_value(if other_os { 'LinuxRequirement' } else { 'Requirement' }, display, {
		'display':   display
		'kind':      kind
		'satisfied': satisfied.str()
		'other_os':  other_os.str()
	})
}

fn info_spec_conflict(name string, resolved string) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaConflict', name, {
		'name':               name
		'resolved_full_name': resolved
	})
}

fn info_spec_installed_formula() brew_runtime.Value {
	tab := info_spec_tab(true, 'homebrew/core', [], false)
	keg := info_spec_keg('testball', '0.1', 12, false, [], tab)
	return info_spec_formula('testball', {
		'description':           'Some test'
		'version':               '0.1'
		'any_version_installed': 'true'
	}, {
		'installed_kegs': brew_runtime.array_value([keg])
		'tab':            tab
	})
}

fn info_spec_installed_cask() brew_runtime.Value {
	tab := info_spec_tab(false, 'homebrew/cask', [], false)
	return info_spec_cask('local-transmission', {
		'version':           '2.61'
		'installed_version': '2.61'
		'display_names':     'Transmission'
		'description':       'BitTorrent client'
	}, {
		'tab': tab
	})
}

fn info_spec_formula_with_resolution(qualified bool) brew_runtime.Value {
	base := info_spec_installed_formula()
	installed := info_spec_formula('testball', {
		'tap':                   'ataraxy-labs/tap'
		'full_name':             'ataraxy-labs/tap/testball'
		'any_version_installed': 'true'
	}, {
		'installed_kegs': base.map_data['installed_kegs'] or { brew_runtime.array_value([]) }
	})
	mut attributes := base.attributes.clone()
	attributes['tap'] = 'homebrew/core'
	attributes['full_name'] = 'homebrew/core/testball'
	attributes['installed_tap'] = if qualified { 'homebrew/core' } else { 'ataraxy-labs/tap' }
	mut fields := base.map_data.clone()
	fields['tap'] = info_spec_tap('homebrew/core')
	fields['resolution_formula'] = installed
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: 'testball'
		attributes: attributes
		map_data: fields
	}
}

fn info_spec_json_valid(value brew_runtime.Value) bool {
	json2.decode[json2.Any](value.as_string()) or { return false }
	return true
}

fn info_spec_json_array_length(value brew_runtime.Value, key string) ?int {
	decoded := json2.decode[json2.Any](value.as_string()) or { return none }
	root := decoded.as_map()
	item := root[key] or { return none }
	if item !is []json2.Any {
		return none
	}
	return item.as_array().len
}

fn info_spec_dependency_output(formula_installed bool, dependency brew_runtime.Value,
	runtime []string, installed_runtime []string) string {
	mut fields := {
		'dependencies': brew_runtime.array_value([dependency])
	}
	if formula_installed {
		tab := info_spec_tab(false, 'homebrew/core', runtime, false)
		fields['installed_kegs'] = brew_runtime.array_value([
			info_spec_keg('testball', '0.1', 1, false, [], tab),
		])
	}
	formula := info_spec_formula('testball', {
		'tty':                          'true'
		'runtime_dependency_installed': installed_runtime.join('\x1f')
		'any_version_installed':        formula_installed.str()
	}, fields)
	return info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
}

fn info_spec_with_related(base brew_runtime.Value, related []brew_runtime.Value) brew_runtime.Value {
	mut fields := base.map_data.clone()
	fields['related'] = brew_runtime.array_value(related)
	return brew_runtime.Value{
		type_name: base.type_name
		repr: base.repr
		attributes: base.attributes.clone()
		map_data: fields
	}
}

// Translated from Homebrew/brew `test/cmd/info_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `installed_info_formula` at line 21.
pub fn ruby_info_spec_l21_d1_installed_info_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return info_spec_installed_formula()
}

// Ruby method `installed_info_cask` at line 31.
pub fn ruby_info_spec_l31_d2_installed_info_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return info_spec_installed_cask()
}

// Ruby it `it "prints as json with the --json=v1 flag" do` at line 44.
pub fn ruby_info_spec_l44_d3_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'description': 'Some test'
	}, {})
	result := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.map_value({
		'named_formulae': brew_runtime.array_value([formula])
	}), brew_runtime.string_value('v1'), brew_runtime.bool_value(false))
	return info_spec_bool(info_spec_json_valid(result) && result.as_string().contains('testball'))
}

// Ruby it `it "prints as json with the --json=v2 flag", :integration_test do` at line 58.
pub fn ruby_info_spec_l58_d4_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {})
	result := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.map_value({
		'named_formulae': brew_runtime.array_value([formula])
	}), brew_runtime.string_value('v2'), brew_runtime.bool_value(false))
	return info_spec_bool(info_spec_json_valid(result) && result.as_string().contains('"formulae"'))
}

// Ruby it `it "does not include installed casks in formula JSON" do` at line 67.
pub fn ruby_info_spec_l67_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_installed_formula()
	result_with_data := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'installed':    'true'
			'formula_only': 'true'
		}
		map_data: {
			'installed_formulae': brew_runtime.array_value([formula])
			'installed_casks':    brew_runtime.array_value([
				info_spec_installed_cask(),
			])
		}
	}, brew_runtime.string_value('v2'), brew_runtime.bool_value(false))
	formulae_length := info_spec_json_array_length(result_with_data, 'formulae') or { -1 }
	casks_length := info_spec_json_array_length(result_with_data, 'casks') or { -1 }
	return info_spec_bool(formulae_length == 1 && casks_length == 0)
}

// Ruby it `it "does not include eval-all casks in formula JSON" do` at line 86.
pub fn ruby_info_spec_l86_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'formula_only': 'true'
		}
		map_data: {
			'all_formulae': brew_runtime.array_value([info_spec_installed_formula()])
			'all_casks':    brew_runtime.array_value([info_spec_installed_cask()])
		}
	}, brew_runtime.string_value('v2'), brew_runtime.bool_value(true))
	formulae_length := info_spec_json_array_length(result, 'formulae') or { -1 }
	casks_length := info_spec_json_array_length(result, 'casks') or { -1 }
	return info_spec_bool(result.as_string().contains('"testball"') && formulae_length == 1 && casks_length == 0)
}

// Ruby it `it "prints installed formulae in a human-readable inventory" do` at line 106.
pub fn ruby_info_spec_l106_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_cmd.ruby_info_l404_d19_info_formula_summary(info_spec_installed_formula()).as_string()
	return info_spec_bool(output == '==> testball: Some test\nFormula from homebrew/core\nInstalled: 0.1 (on request)\n')
}

// Ruby it `it "prints installed casks in a human-readable inventory" do` at line 129.
pub fn ruby_info_spec_l129_d8_prints(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_cmd.ruby_info_l900_d36_info_cask_summary(info_spec_installed_cask()).as_string()
	return info_spec_bool(output == '==> local-transmission: (Transmission) BitTorrent client\nCask from homebrew/cask\nInstalled: 2.61 (dependency)\n')
}

// Ruby it `it "omits missing cask descriptions from the installed inventory" do` at line 152.
pub fn ruby_info_spec_l152_d9_omits(args ...brew_runtime.Value) brew_runtime.Value {
	cask := info_spec_cask('no-description', {
		'installed_version': '1.0'
		'display_names':     'No Description'
	}, {
		'tab': info_spec_tab(none, 'homebrew/cask', [], false)
	})
	output := info_cmd.ruby_info_l900_d36_info_cask_summary(cask).as_string()
	return info_spec_bool(output.starts_with('==> no-description\n') && !output.contains('No Description'))
}

// Ruby it `it "omits install reason when receipt intent is unavailable" do` at line 180.
pub fn ruby_info_spec_l180_d10_omits(args ...brew_runtime.Value) brew_runtime.Value {
	tab := info_spec_tab(none, 'homebrew/core', [], false)
	return info_spec_bool(info_cmd.ruby_info_l192_d6_self_installation_summary(brew_runtime.string_value('0.1'), tab).as_string() == 'Installed: 0.1')
}

// Ruby it `it "marks installed formulae in interactive inventory output" do` at line 211.
pub fn ruby_info_spec_l211_d11_marks(args ...brew_runtime.Value) brew_runtime.Value {
	installed := info_spec_installed_formula()
	mut attributes := installed.attributes.clone()
	attributes['tty'] = 'true'
	output := info_cmd.ruby_info_l404_d19_info_formula_summary(brew_runtime.Value{
		...installed
		attributes: attributes
	}).as_string()
	return info_spec_bool(output.contains('testball ✔: Some test'))
}

// Ruby it `it "prints verbose installed inventory as full info" do` at line 230.
pub fn ruby_info_spec_l230_d12_prints(args ...brew_runtime.Value) brew_runtime.Value {
	mut formula_attrs := info_spec_installed_formula().attributes.clone()
	formula_attrs['verbose'] = 'true'
	formula := info_spec_formula('testball', formula_attrs, info_spec_installed_formula().map_data)
	cask := info_spec_cask('local-transmission', {
		'installed_version': '2.61'
		'info':              'full cask info'
	}, {})
	result := info_cmd.ruby_info_l93_d1_run(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'installed': 'true'
			'verbose':   'true'
		}
		map_data: {
			'installed_packages': brew_runtime.array_value([formula, cask])
		}
	})
	return info_spec_bool(result.as_string().contains('==> testball') && result.as_string().contains('full cask info'))
}

// Ruby it `it "prints quiet formula information in the slim inventory format" do` at line 245.
pub fn ruby_info_spec_l245_d13_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'description': 'Some test'
	}, {})
	output := info_cmd.ruby_info_l404_d19_info_formula_summary(formula).as_string()
	return info_spec_bool(output.contains('==> testball: Some test') && output.contains('Formula from https://github.com/') && output.contains('Not installed'))
}

// Ruby it `it "uses slim formula information when quiet is passed" do` at line 264.
pub fn ruby_info_spec_l264_d14_uses(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'description': 'Some test'
	}, {})
	result := info_cmd.ruby_info_l318_d15_print_info(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'quiet': 'true'
		}
		map_data: {
			'objects': brew_runtime.array_value([formula])
		}
	}, brew_runtime.bool_value(true))
	return info_spec_bool(result.as_string().contains('Formula from') && !result.as_string().contains('From:'))
}

// Ruby it `it "prints inline summary information for formulae" do` at line 278.
pub fn ruby_info_spec_l278_d15_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'description':    'Some test'
		'homepage':       'https://brew.sh/testball'
		'tty':            'true'
		'stable_bottled': 'false'
		'options':        'with-foo'
	}, {})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('Installs from source: yes') && !output.contains('Metadata') && !output.contains('supports macOS and Linux'))
}

// Ruby it `it "shows a conflict by its resolved full name" do` at line 300.
pub fn ruby_info_spec_l300_d16_shows(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {
		'conflicts': brew_runtime.array_value([
			info_spec_conflict('other', 'someuser/tap/other'),
		])
	})
	return info_spec_bool(info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().contains('Conflicts with:\n  someuser/tap/other'))
}

// Ruby it `it "omits a stale conflict that resolves to the formula itself" do` at line 316.
pub fn ruby_info_spec_l316_d17_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {
		'conflicts': brew_runtime.array_value([
			info_spec_conflict('testball', 'testball'),
		])
	})
	return info_spec_bool(!info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().contains('Conflicts with:'))
}

// Ruby it `it "marks a deprecated formula with `(deprecated)` in the title" do` at line 330.
pub fn ruby_info_spec_l330_d18_marks(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'deprecated': 'true'
		'tty':        'true'
	}, {})
	return info_spec_bool(info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().starts_with('==> testball (deprecated):'))
}

// Ruby it `it "marks a disabled formula with `(disabled)` in the title" do` at line 348.
pub fn ruby_info_spec_l348_d19_marks(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'disabled': 'true'
		'tty':      'true'
	}, {})
	return info_spec_bool(info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().starts_with('==> testball (disabled):'))
}

// Ruby it `it "shows separate blocks for an unqualified and a qualified input that resolve to the same shadowed formula" do` at line 366.
pub fn ruby_info_spec_l366_d20_shows(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(false)
	result := info_cmd.ruby_info_l318_d15_print_info(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'input_names': 'testball\x1fhomebrew/core/testball'
		}
		map_data: {
			'objects': brew_runtime.array_value([formula, formula])
		}
	})
	return info_spec_bool(result.as_string().contains('ataraxy-labs/tap/testball') && result.as_string().contains('homebrew/core/testball'))
}

// Ruby it `it "reports an unavailable name without raising" do` at line 388.
pub fn ruby_info_spec_l388_d21_reports(args ...brew_runtime.Value) brew_runtime.Value {
	error_value := brew_runtime.object_value('FormulaOrCaskUnavailableError', 'No available formula or cask with the name "nonexistent-formula"')
	result := info_cmd.ruby_info_l318_d15_print_info(brew_runtime.map_value({
		'objects': brew_runtime.array_value([error_value])
	}))
	stderr := result.map_data['stderr'] or { brew_runtime.string_value('') }
	return info_spec_bool(stderr.as_string().contains('No available formula or cask'))
}

// Ruby it `it "qualifies the name, reports not installed and shows the shadowing keg when the keg belongs to another tap" do` at line 400.
pub fn ruby_info_spec_l400_d22_qualifies(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(false)
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('homebrew/core/testball') && info_cmd.ruby_info_l703_d26_shadowing_installed_formula(formula).type_name == 'Formula')
}

// Ruby it `it "reloads the formula from the install receipt's tap and reports the shadowing tap" do` at line 418.
pub fn ruby_info_spec_l418_d23_reloads(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(false)
	resolution := info_cmd.ruby_info_l358_d17_installed_resolution(formula).as_array() or { [] }
	return info_spec_bool(resolution.len == 2 && resolution[0].attributes['full_name'] == 'ataraxy-labs/tap/testball' && resolution[1].repr == 'homebrew/core')
}

// Ruby it `it "resolves the keg's own name when it differs from the formula (installed via alias)" do` at line 439.
pub fn ruby_info_spec_l439_d24_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	installed := info_spec_formula('stripe', {
		'tap':       'stripe/stripe-cli'
		'full_name': 'stripe/stripe-cli/stripe'
	}, {})
	formula := info_spec_formula('testball', {
		'installed_tap':      'stripe/stripe-cli'
		'installed_keg_name': 'stripe'
	}, {
		'installed_kegs':     brew_runtime.array_value([
			info_spec_keg('stripe', '1.0', 1, false, [], info_spec_tab(false, 'stripe/stripe-cli', [], false)),
		])
		'resolution_formula': installed
	})
	resolution := info_cmd.ruby_info_l358_d17_installed_resolution(formula).as_array() or { [] }
	return info_spec_bool(resolution.len == 2 && resolution[0].repr == 'stripe')
}

// Ruby it `it "returns the original formula and no shadowing tap when the install receipt has no tap" do` at line 451.
pub fn ruby_info_spec_l451_d25_returns(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_installed_formula()
	resolution := info_cmd.ruby_info_l358_d17_installed_resolution(formula).as_array() or { [] }
	return info_spec_bool(resolution.len == 2 && resolution[0].repr == formula.repr && resolution[1].type_name == 'NilClass')
}

// Ruby it `it "returns the original formula and no shadowing tap when the install receipt's tap matches" do` at line 463.
pub fn ruby_info_spec_l463_d26_returns(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(true)
	resolution := info_cmd.ruby_info_l358_d17_installed_resolution(formula).as_array() or { [] }
	return info_spec_bool(resolution.len == 2 && resolution[0].repr == formula.repr && resolution[1].type_name == 'NilClass')
}

// Ruby it `it "warns about a shadowing tap when info_formula is given one" do` at line 477.
pub fn ruby_info_spec_l477_d27_warns(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula, info_spec_tap('homebrew/core')).as_string()
	return info_spec_bool(output.contains('Warning: `testball` shadows `homebrew/core/testball`.'))
}

// Ruby it `it "treats a `tap/name` input as user-qualified" do` at line 491.
pub fn ruby_info_spec_l491_d28_treats(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {})
	return info_cmd.ruby_info_l347_d16_formula_qualified_by_user(formula, brew_runtime.string_array_value([
		'homebrew/core/testball',
	]))
}

// Ruby it `it "treats a bare unqualified input as not user-qualified" do` at line 503.
pub fn ruby_info_spec_l503_d29_treats(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {})
	return info_spec_bool(!info_cmd.ruby_info_l347_d16_formula_qualified_by_user(formula, brew_runtime.string_array_value([])).bool_data)
}

// Ruby it `it "--json swaps an unqualified-input formula to its installed tap" do` at line 513.
pub fn ruby_info_spec_l513_d30_json(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(false)
	output := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.Value{
		type_name: 'InfoContext'
		map_data: {
			'named_formulae': brew_runtime.array_value([formula])
		}
	}, brew_runtime.bool_value(true), brew_runtime.bool_value(false)).as_string()
	return info_spec_bool(output.contains('ataraxy-labs/tap'))
}

// Ruby it `it "--json honours a tap-qualified input without swapping" do` at line 540.
pub fn ruby_info_spec_l540_d31_json(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula_with_resolution(false)
	output := info_cmd.ruby_info_l729_d29_print_json(brew_runtime.Value{
		type_name: 'InfoContext'
		attributes: {
			'qualified_inputs': 'homebrew/core/testball'
		}
		map_data: {
			'named_formulae': brew_runtime.array_value([formula])
		}
	}, brew_runtime.bool_value(true), brew_runtime.bool_value(false)).as_string()
	return info_spec_bool(output.contains('homebrew/core'))
}

// Ruby it `it "prints required, recursive runtime, and dependent counts in the dependencies section" do` at line 561.
pub fn ruby_info_spec_l561_d32_prints(args ...brew_runtime.Value) brew_runtime.Value {
	dep := info_spec_dependency('bar', 'required', true, false, false)
	tab := info_spec_tab(false, 'homebrew/core', ['installed-dep', 'missing-dep'], false)
	formula := info_spec_formula('testball', {
		'tty':                          'true'
		'any_version_installed':        'true'
		'runtime_dependency_installed': 'installed-dep'
		'dependent_names':              'some-dependent'
	}, {
		'dependencies':   brew_runtime.array_value([dep])
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '0.1', 1, false, [], tab),
		])
	})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('==> Dependencies\nRequired (1): bar ✔') && output.contains('Recursive Runtime (2): 1 installed ✔, 1 missing ✘') && output.contains('Dependents: 1') && !output.contains('Dependencies: '))
}

// Ruby it `it "lists installed dependents inline under Dependencies with --verbose" do` at line 617.
pub fn ruby_info_spec_l617_d33_lists(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'dependent_names':       'some-dependent\x1fanother-dependent'
		'any_version_installed': 'true'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '0.1', 1, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula, brew_runtime.object_value('NilClass', 'nil'), brew_runtime.bool_value(true)).as_string()
	return info_spec_bool(output.contains('Dependents (2): another-dependent, some-dependent') && !output.contains('Dependents: 2'))
}

// Ruby it `it "summarises recursive runtime dependencies as all installed when none are missing" do` at line 654.
pub fn ruby_info_spec_l654_d34_summarises(args ...brew_runtime.Value) brew_runtime.Value {
	dep := info_spec_dependency('bar', 'required', true, false, false)
	output := info_spec_dependency_output(true, dep, ['installed-dep'], [
		'installed-dep',
	])
	return info_spec_bool(output.contains('Recursive Runtime (1): all installed ✔'))
}

// Ruby it `it "marks a tab-listed dep with no installed rack as unsatisfied" do` at line 691.
pub fn ruby_info_spec_l691_d35_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(true, info_spec_dependency('bar', 'required', false, false, false), [
		'bar',
	], [])
	return info_spec_bool(output.contains('Required (1): bar ✘'))
}

// Ruby it `it "marks a tab-listed dep with an installed rack as satisfied when the dep formula is not outdated" do` at line 718.
pub fn ruby_info_spec_l718_d36_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(true, info_spec_dependency('bar', 'required', true, false, false), [
		'bar',
	], ['bar'])
	return info_spec_bool(output.contains('Required (1): bar ✔'))
}

// Ruby it `it "marks a tab-listed dep with an installed rack as outdated when the dep formula is outdated" do` at line 755.
pub fn ruby_info_spec_l755_d37_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(true, info_spec_dependency('bar', 'required', true, true, false), [
		'bar',
	], ['bar'])
	return info_spec_bool(output.contains('Required (1): bar ↑'))
}

// Ruby it `it "marks an installed dep on an uninstalled formula as satisfied" do` at line 792.
pub fn ruby_info_spec_l792_d38_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(false, info_spec_dependency('bar', 'required', true, false, false), [], [])
	return info_spec_bool(output.contains('Required (1): bar ✔'))
}

// Ruby it `it "marks an outdated installed dep on an uninstalled formula as upgradable" do` at line 822.
pub fn ruby_info_spec_l822_d39_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(false, info_spec_dependency('bar', 'required', true, true, false), [], [])
	return info_spec_bool(output.contains('Required (1): bar ↑'))
}

// Ruby it `it "marks an aliased dep as installed when the underlying rack exists under a different name" do` at line 852.
pub fn ruby_info_spec_l852_d40_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(false, info_spec_dependency('pkg-config', 'required', false, false, true), [], [])
	return info_spec_bool(output.contains('Required (1): pkg-config ✔'))
}

// Ruby it `it "does not mark a missing dep on an uninstalled formula" do` at line 882.
pub fn ruby_info_spec_l882_d41_does(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(false, info_spec_dependency('bar', 'required', false, false, false), [], [])
	return info_spec_bool(output.contains('Required (1): bar\n') && !output.contains('bar ✘'))
}

// Ruby it `it "marks a dep absent from the installed keg's tab as unsatisfied when its rack is also missing" do` at line 902.
pub fn ruby_info_spec_l902_d42_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(true, info_spec_dependency('bar', 'required', false, false, false), [], [])
	return info_spec_bool(output.contains('Required (1): bar ✘'))
}

// Ruby it `it "marks a dep absent from the installed keg's tab as installed when its rack exists" do` at line 929.
pub fn ruby_info_spec_l929_d43_marks(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_spec_dependency_output(true, info_spec_dependency('bar', 'required', true, true, false), [], [])
	return info_spec_bool(output.contains('Required (1): bar ↑'))
}

// Ruby it `it "omits build dependencies when a formula would pour from a bottle" do` at line 962.
pub fn ruby_info_spec_l962_d44_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'stable_bottled': 'true'
		'pour_bottle':    'true'
	}, {
		'dependencies': brew_runtime.array_value([
			info_spec_dependency('bar', 'build', false, false, false),
		])
	})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(!output.contains('Build (1):') && !output.contains('==> Dependencies'))
}

// Ruby it `it "shows the installed and stable versions in the headline when outdated" do` at line 992.
pub fn ruby_info_spec_l992_d45_shows(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'outdated':       'true'
		'version':        '0.1'
		'stable_version': '0.1'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '0.0.1', 1, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	return info_spec_bool(info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().starts_with('==> testball: 0.0.1 → stable 0.1\n'))
}

// Ruby it `it "prints Linux requirements through the requirements section" do` at line 1014.
pub fn ruby_info_spec_l1014_d46_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'tty': 'true'
	}, {
		'requirements': brew_runtime.array_value([
			info_spec_requirement('Linux', 'required', false, true),
		])
	})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('==> Requirements\nRequired: Linux') && !output.contains('supports Linux'))
}

// Ruby it `it "hides source install metadata for formulae that only run on another OS" do` at line 1036.
pub fn ruby_info_spec_l1036_d47_hides(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'tty': 'true'
	}, {
		'requirements': brew_runtime.array_value([
			info_spec_requirement('Linux', 'required', false, true),
		])
	})
	return info_spec_bool(!info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().contains('Installs from source: yes'))
}

// Ruby it `it "prints a Binaries section listing executables in bin and sbin with --verbose" do` at line 1058.
pub fn ruby_info_spec_l1058_d48_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {
		'installed_kegs': brew_runtime.array_value([info_spec_keg('testball', '0.1', 1, false, [
			'testball',
			'another',
			'daemon',
		], info_spec_tab(false, 'homebrew/core', [], false))])
	})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula, brew_runtime.object_value('NilClass', 'nil'), brew_runtime.bool_value(true)).as_string()
	return info_spec_bool(output.contains('==> Binaries\nanother\ndaemon\ntestball\n'))
}

// Ruby it `it "prints a Binaries section from the bottle manifest when the formula is not installed with --verbose" do` at line 1087.
pub fn ruby_info_spec_l1087_d49_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'bottle_binaries': 'bin/testball\x1fbin/another\x1fsbin/daemon'
	}, {})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula, brew_runtime.object_value('NilClass', 'nil'), brew_runtime.bool_value(true)).as_string()
	return info_spec_bool(output.contains('==> Binaries\nanother\ndaemon\ntestball\n'))
}

// Ruby it `it "omits the Binaries section without --verbose" do` at line 1111.
pub fn ruby_info_spec_l1111_d50_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {
		'installed_kegs': brew_runtime.array_value([info_spec_keg('testball', '0.1', 1, false, [
			'testball',
		], info_spec_tab(false, 'homebrew/core', [], false))])
	})
	return info_spec_bool(!info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().contains('==> Binaries'))
}

// Ruby it `it "omits the Binaries section when no executables are installed" do` at line 1137.
pub fn ruby_info_spec_l1137_d51_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '0.1', 1, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	return info_spec_bool(!info_cmd.ruby_info_l426_d20_info_formula(formula, brew_runtime.object_value('NilClass', 'nil'), brew_runtime.bool_value(true)).as_string().contains('==> Binaries'))
}

// Ruby it `it "prints on-request installs explicitly" do` at line 1161.
pub fn ruby_info_spec_l1161_d52_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return info_spec_bool(info_cmd.ruby_info_l178_d4_self_installation_status(info_spec_tab(true, '', [], false)).as_string() == 'Installed (on request)')
}

// Ruby it `it "treats non-requested installs as dependency installs" do` at line 1166.
pub fn ruby_info_spec_l1166_d53_treats(args ...brew_runtime.Value) brew_runtime.Value {
	return info_spec_bool(info_cmd.ruby_info_l178_d4_self_installation_status(info_spec_tab(false, '', [], false)).as_string() == 'Installed (as dependency)')
}

// Ruby it `it "returns summary lines for pinned formulae" do` at line 1175.
pub fn ruby_info_spec_l1175_d54_returns(args ...brew_runtime.Value) brew_runtime.Value {
	stamp := i64(1_720_189_900)
	formula := info_spec_formula('testball', {
		'pinned':                'true'
		'pinned_version':        '1.0'
		'pin_mtime':             stamp.str()
		'any_version_installed': 'true'
	}, {})
	lines := info_cmd.ruby_info_l156_d3_self_metadata_lines(formula, brew_runtime.bool_value(true)).as_string_array() or { [] }
	expected_time := info_cmd.ruby_info_l257_d11_self_formatted_time(brew_runtime.int_value(stamp)).as_string()
	return info_spec_bool(lines == ['Pinned: 1.0 on ${expected_time}'])
}

// Ruby it `it "returns summary lines for pinned casks" do` at line 1195.
pub fn ruby_info_spec_l1195_d55_returns(args ...brew_runtime.Value) brew_runtime.Value {
	stamp := i64(1_720_189_900)
	cask := info_spec_cask('test-cask', {
		'pinned':         'true'
		'pinned_version': '1.0'
		'pin_mtime':      stamp.str()
	}, {})
	lines := info_cmd.ruby_info_l156_d3_self_metadata_lines(cask, brew_runtime.bool_value(true)).as_string_array() or { [] }
	expected_time := info_cmd.ruby_info_l257_d11_self_formatted_time(brew_runtime.int_value(stamp)).as_string()
	return info_spec_bool(lines == ['Pinned: 1.0 on ${expected_time}'])
}

// Ruby let `let(:remote) { "https://github.com/Homebrew/homebrew-core" }` at line 1217.
pub fn ruby_info_spec_l1217_d56_remote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('https://github.com/Homebrew/homebrew-core')
}

// Ruby specify `specify "returns correct URLs" do` at line 1219.
pub fn ruby_info_spec_l1219_d57_returns(args ...brew_runtime.Value) brew_runtime.Value {
	remote := ruby_info_spec_l1217_d56_remote()
	path := brew_runtime.string_value('Formula/git.rb')
	return info_spec_bool(info_cmd.ruby_info_l147_d2_github_remote_path(remote, path).as_string() == 'https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git.rb' && info_cmd.ruby_info_l147_d2_github_remote_path(brew_runtime.string_value('${remote.repr}.git'), path).as_string() == 'https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git.rb' && info_cmd.ruby_info_l147_d2_github_remote_path(brew_runtime.string_value('git@github.com:user/repo'), brew_runtime.string_value('foo.rb')).as_string() == 'https://github.com/user/repo/blob/HEAD/foo.rb' && info_cmd.ruby_info_l147_d2_github_remote_path(brew_runtime.string_value('https://mywebsite.com'), brew_runtime.string_value('foo/bar.rb')).as_string() == 'https://mywebsite.com/foo/bar.rb')
}

// Ruby it `it "lists aliases on their own row when the formula has any" do` at line 1235.
pub fn ruby_info_spec_l1235_d58_lists(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'aliases': 'testball@1.0\x1ftball\x1fgoogleball'
	}, {})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('Aliases: testball@1.0, tball, googleball') && !output.contains('Old Names:'))
}

// Ruby it `it "renders aliases and old names on separate rows when both exist" do` at line 1250.
pub fn ruby_info_spec_l1250_d59_renders(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'aliases':   'testball@1.0\x1ftball'
		'old_names': 'foo\x1fbar'
	}, {})
	return info_spec_bool(info_cmd.ruby_info_l426_d20_info_formula(formula).as_string().contains('Aliases: testball@1.0, tball\nOld Names: foo, bar'))
}

// Ruby it `it "renders only an Old Names row when there are no aliases" do` at line 1264.
pub fn ruby_info_spec_l1264_d60_renders(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'old_names': 'foo'
	}, {})
	output := info_cmd.ruby_info_l426_d20_info_formula(formula).as_string()
	return info_spec_bool(output.contains('Old Names: foo') && !output.contains('Aliases:'))
}

// Ruby it `it "omits both rows when there are none" do` at line 1279.
pub fn ruby_info_spec_l1279_d61_omits(args ...brew_runtime.Value) brew_runtime.Value {
	output := info_cmd.ruby_info_l426_d20_info_formula(info_spec_formula('testball', {}, {})).as_string()
	return info_spec_bool(!output.contains('Aliases:') && !output.contains('Old Names:'))
}

// Ruby it `it "lists this formula alongside installed sibling versioned formulae" do` at line 1296.
pub fn ruby_info_spec_l1296_d62_lists(args ...brew_runtime.Value) brew_runtime.Value {
	main := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	versioned := info_spec_formula('testball@0.9', {
		'version':  '0.9'
		'keg_only': 'true'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball@0.9', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(info_spec_with_related(main, [
		versioned,
	])).as_string_array() or { [] }
	return info_spec_bool(lines.any(it.contains('testball 1.0')) && lines.any(it.contains('testball@0.9 0.9')))
}

// Ruby it `it "shows installed → latest only on the newest installed keg of an outdated formula" do` at line 1332.
pub fn ruby_info_spec_l1332_d63_shows(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'version':  '2.0'
		'outdated': 'true'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
			info_spec_keg('testball', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(formula).as_string_array() or { [] }
	return info_spec_bool(lines.any(it.contains('1.0 → 2.0')) && lines.all(!it.contains('0.9 →')))
}

// Ruby it `it "hides older non-linked kegs by default" do` at line 1357.
pub fn ruby_info_spec_l1357_d64_hides(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
			info_spec_keg('testball', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(formula).as_string_array() or { [] }
	return info_spec_bool(lines.len == 1 && lines[0].contains('1.0'))
}

// Ruby it `it "marks the currently linked version with `*`" do` at line 1381.
pub fn ruby_info_spec_l1381_d65_marks(args ...brew_runtime.Value) brew_runtime.Value {
	main := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, true, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	versioned := info_spec_formula('testball@0.9', {
		'version': '0.9'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball@0.9', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(info_spec_with_related(main, [
		versioned,
	])).as_string_array() or { [] }
	return info_spec_bool(lines.any(it.contains('testball 1.0') && it.contains('[Linked]')))
}

// Ruby it `it "includes the unversioned parent when run on a versioned formula" do` at line 1416.
pub fn ruby_info_spec_l1416_d66_includes(args ...brew_runtime.Value) brew_runtime.Value {
	versioned := info_spec_formula('testball@0.9', {
		'version': '0.9'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball@0.9', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	parent := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(info_spec_with_related(versioned, [
		parent,
	])).as_string_array() or { [] }
	return info_spec_bool(lines.any(it.contains('testball 1.0')) && lines.any(it.contains('testball@0.9 0.9')))
}

// Ruby it `it "renders the section even when only the current formula is installed" do` at line 1453.
pub fn ruby_info_spec_l1453_d67_renders(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	return info_spec_bool(info_cmd.ruby_info_l799_d31_installed_section_lines(formula).as_string_array() or {
		[]
	}.len > 0)
}

// Ruby it `it "renders the section when the queried formula is uninstalled but a sibling is installed" do` at line 1474.
pub fn ruby_info_spec_l1474_d68_renders(args ...brew_runtime.Value) brew_runtime.Value {
	versioned := info_spec_formula('testball@0.9', {
		'version': '0.9'
	}, {})
	parent := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(info_spec_with_related(versioned, [
		parent,
	])).as_string_array() or { [] }
	return info_spec_bool(lines.any(it.contains('testball 1.0')) && lines.all(!it.contains('testball@0.9')))
}

// Ruby it `it "lists every installed keg of a formula, newest first, with --verbose" do` at line 1502.
pub fn ruby_info_spec_l1502_d69_lists(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'version': '1.0'
	}, {
		'installed_kegs': brew_runtime.array_value([
			info_spec_keg('testball', '0.9', 9, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
			info_spec_keg('testball', '1.0', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
			info_spec_keg('testball', '0.10', 10, false, [], info_spec_tab(false, 'homebrew/core', [], false)),
		])
	})
	lines := info_cmd.ruby_info_l799_d31_installed_section_lines(formula, brew_runtime.bool_value(true)).as_string_array() or { [] }
	return info_spec_bool(lines.len == 3 && lines[0].contains('1.0') && lines[1].contains('0.10') && lines[2].contains('0.9'))
}

// Ruby it `it "omits the section when nothing in the family is installed" do` at line 1532.
pub fn ruby_info_spec_l1532_d70_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := info_spec_formula('testball', {
		'version': '1.0'
	}, {})
	return info_spec_bool((info_cmd.ruby_info_l799_d31_installed_section_lines(formula).as_string_array() or {
		[]
	}).len == 0)
}

// Ruby let `let(:tap) { CoreTap.instance }` at line 1548.
pub fn ruby_info_spec_l1548_d71_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return info_spec_tap('homebrew/core')
}

// Ruby it `it "returns the local path for a formula whose file lives outside its tap" do` at line 1550.
pub fn ruby_info_spec_l1550_d72_returns(args ...brew_runtime.Value) brew_runtime.Value {
	tap := ruby_info_spec_l1548_d71_tap()
	path := os.join_path(os.temp_dir(), 'Cellar', 'testball', '0.1', '.brew', 'testball.rb')
	formula := info_spec_formula('testball', {
		'path': path
	}, {
		'tap': tap
	})
	return info_spec_bool(info_cmd.ruby_info_l371_d18_github_info(formula).as_string() == path)
}

// Ruby it `it "returns a GitHub URL for a formula whose file lives inside its tap" do` at line 1563.
pub fn ruby_info_spec_l1563_d73_returns(args ...brew_runtime.Value) brew_runtime.Value {
	tap := ruby_info_spec_l1548_d71_tap()
	path := os.join_path(tap.attributes['path'], 'Formula', 'testball.rb')
	formula := info_spec_formula('testball', {
		'path': path
	}, {
		'tap': tap
	})
	return info_spec_bool(info_cmd.ruby_info_l371_d18_github_info(formula).as_string() == 'https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/testball.rb')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/info"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Info do
// 8:   before do
// 9:     allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 10:   end
// 11:
// 12:   RSpec::Matchers.define :a_json_string do
// 13:     match do |actual|
// 14:       JSON.parse(actual)
// 15:       true
// 16:     rescue JSON::ParserError
// 17:       false
// 18:     end
// 19:   end
// 20:
// 21:   def installed_info_formula
// 22:     test_formula = formula("testball") do
// 23:       T.bind(self, T.class_of(Formula))
// 24:       url "https://brew.sh/testball-0.1.tar.gz"
// 25:       desc "Some test"
// 26:     end
// 27:     (HOMEBREW_CELLAR/"testball/0.1").mkpath
// 28:     test_formula
// 29:   end
// 30:
// 31:   def installed_info_cask
// 32:     cask = Cask::Cask.new("local-transmission") do
// 33:       version "2.61"
// 34:       name "Transmission"
// 35:       desc "BitTorrent client"
// 36:       url "https://example.com/local-transmission.zip"
// 37:     end
// 38:     allow(cask).to receive(:installed_version).and_return("2.61")
// 39:     cask
// 40:   end
// 41:
// 42:   it_behaves_like "parseable arguments"
// 43:
// 44:   it "prints as json with the --json=v1 flag" do
// 45:     test_formula = formula("testball") do
// 46:       T.bind(self, T.class_of(Formula))
// 47:       url "https://brew.sh/testball-0.1.tar.gz"
// 48:       desc "Some test"
// 49:     end
// 50:     info = described_class.new(["--json=v1", "testball"])
// 51:     allow(info.args.named).to receive(:to_formulae).and_return([test_formula])
// 52:
// 53:     expect { info.run }
// 54:       .to output(a_json_string).to_stdout
// 55:       .and not_to_output.to_stderr
// 56:   end
// 57:
// 58:   it "prints as json with the --json=v2 flag", :integration_test do
// 59:     setup_test_formula "testball"
// 60:
// 61:     expect { brew "info", "testball", "--json=v2" }
// 62:       .to output(a_json_string).to_stdout
// 63:       .and not_to_output.to_stderr
// 64:       .and be_a_success
// 65:   end
// 66:
// 67:   it "does not include installed casks in formula JSON" do
// 68:     formula = installed_info_formula
// 69:
// 70:     allow(Formula).to receive(:installed).and_return([formula])
// 71:     expect(Cask::Caskroom).not_to receive(:casks)
// 72:
// 73:     output = +""
// 74:     expect { described_class.new(["--json=v2", "--installed", "--formula"]).run }
// 75:       .to output(satisfy { |s|
// 76:         output << s
// 77:         true
// 78:       }).to_stdout
// 79:         .and not_to_output.to_stderr
// 80:
// 81:     json = JSON.parse(output)
// 82:     expect(json["formulae"].length).to eq(1)
// 83:     expect(json["casks"]).to be_empty
// 84:   end
// 85:
// 86:   it "does not include eval-all casks in formula JSON" do
// 87:     formula = installed_info_formula
// 88:
// 89:     allow(Formula).to receive(:all).and_return([formula])
// 90:     allow(Homebrew::EnvConfig).to receive(:tap_trust_configured?).and_return(true)
// 91:     expect(Cask::Cask).not_to receive(:all)
// 92:
// 93:     output = +""
// 94:     expect { described_class.new(["--json=v2", "--formula"]).run }
// 95:       .to output(satisfy { |s|
// 96:         output << s
// 97:         true
// 98:       }).to_stdout
// 99:         .and not_to_output.to_stderr
// 100:
// 101:     json = JSON.parse(output)
// 102:     expect(json["formulae"].length).to eq(1)
// 103:     expect(json["casks"]).to be_empty
// 104:   end
// 105:
// 106:   it "prints installed formulae in a human-readable inventory" do
// 107:     mktmpdir do |dir|
// 108:       tabfile = dir/AbstractTab::FILENAME
// 109:       tabfile.write("{}")
// 110:       formula = installed_info_formula
// 111:
// 112:       allow(Formula).to receive(:installed).and_return([formula])
// 113:       allow(Tab).to receive(:for_formula).with(formula).and_return(
// 114:         Tab.new(installed_on_request: true, source: { "tap" => "homebrew/core" }, tabfile:),
// 115:       )
// 116:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 117:
// 118:       expected_output = <<~EOS
// 119:         ==> testball: Some test
// 120:         Formula from homebrew/core
// 121:         Installed: 0.1 (on request)
// 122:       EOS
// 123:       expect { described_class.new(["--installed"]).run }
// 124:         .to output(expected_output).to_stdout
// 125:         .and not_to_output.to_stderr
// 126:     end
// 127:   end
// 128:
// 129:   it "prints installed casks in a human-readable inventory" do
// 130:     mktmpdir do |dir|
// 131:       tabfile = dir/AbstractTab::FILENAME
// 132:       tabfile.write("{}")
// 133:       cask = installed_info_cask
// 134:
// 135:       allow(Formula).to receive(:installed).and_return([])
// 136:       allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 137:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(
// 138:         Cask::Tab.new(installed_on_request: false, source: { "tap" => "homebrew/cask" }, tabfile:),
// 139:       )
// 140:
// 141:       expected_output = <<~EOS
// 142:         ==> local-transmission: (Transmission) BitTorrent client
// 143:         Cask from homebrew/cask
// 144:         Installed: 2.61 (dependency)
// 145:       EOS
// 146:       expect { described_class.new(["--installed"]).run }
// 147:         .to output(expected_output).to_stdout
// 148:         .and not_to_output.to_stderr
// 149:     end
// 150:   end
// 151:
// 152:   it "omits missing cask descriptions from the installed inventory" do
// 153:     mktmpdir do |dir|
// 154:       tabfile = dir/AbstractTab::FILENAME
// 155:       tabfile.write("{}")
// 156:       cask = Cask::Cask.new("no-description") do
// 157:         version "1.0"
// 158:         name "No Description"
// 159:         url "https://example.com/no-description.zip"
// 160:       end
// 161:       allow(cask).to receive(:installed_version).and_return("1.0")
// 162:
// 163:       allow(Formula).to receive(:installed).and_return([])
// 164:       allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 165:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(
// 166:         Cask::Tab.new(source: { "tap" => "homebrew/cask" }, tabfile:),
// 167:       )
// 168:
// 169:       expected_output = <<~EOS
// 170:         ==> no-description
// 171:         Cask from homebrew/cask
// 172:         Installed: 1.0
// 173:       EOS
// 174:       expect { described_class.new(["--installed"]).run }
// 175:         .to output(expected_output).to_stdout
// 176:         .and not_to_output.to_stderr
// 177:     end
// 178:   end
// 179:
// 180:   it "omits install reason when receipt intent is unavailable" do
// 181:     mktmpdir do |dir|
// 182:       tabfile = dir/AbstractTab::FILENAME
// 183:       tabfile.write("{}")
// 184:       formula = installed_info_formula
// 185:       cask = installed_info_cask
// 186:
// 187:       allow(Formula).to receive(:installed).and_return([formula])
// 188:       allow(Tab).to receive(:for_formula).with(formula).and_return(
// 189:         Tab.new(source: { "tap" => "homebrew/core" }, tabfile:),
// 190:       )
// 191:       allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 192:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(
// 193:         Cask::Tab.new(source: { "tap" => "homebrew/cask" }, tabfile:),
// 194:       )
// 195:
// 196:       expected_output = <<~EOS
// 197:         ==> testball: Some test
// 198:         Formula from homebrew/core
// 199:         Installed: 0.1
// 200:
// 201:         ==> local-transmission: (Transmission) BitTorrent client
// 202:         Cask from homebrew/cask
// 203:         Installed: 2.61
// 204:       EOS
// 205:       expect { described_class.new(["--installed"]).run }
// 206:         .to output(expected_output).to_stdout
// 207:         .and not_to_output.to_stderr
// 208:     end
// 209:   end
// 210:
// 211:   it "marks installed formulae in interactive inventory output" do
// 212:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 213:     mktmpdir do |dir|
// 214:       tabfile = dir/AbstractTab::FILENAME
// 215:       tabfile.write("{}")
// 216:       formula = installed_info_formula
// 217:
// 218:       allow(Formula).to receive(:installed).and_return([formula])
// 219:       allow(Tab).to receive(:for_formula).with(formula).and_return(
// 220:         Tab.new(installed_on_request: true, source: { "tap" => "homebrew/core" }, tabfile:),
// 221:       )
// 222:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 223:
// 224:       expect { described_class.new(["--installed"]).run }
// 225:         .to output(/testball .*✔.*: Some test/).to_stdout
// 226:         .and not_to_output.to_stderr
// 227:     end
// 228:   end
// 229:
// 230:   it "prints verbose installed inventory as full info" do
// 231:     info = described_class.new(["--verbose", "--installed"])
// 232:     formula = installed_info_formula
// 233:     cask = installed_info_cask
// 234:
// 235:     allow(Formula).to receive(:installed).and_return([formula])
// 236:     allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 237:     expect(info).to receive(:info_formula).with(formula, shadowed_by: nil)
// 238:     expect(info).to receive(:info_cask).with(cask)
// 239:
// 240:     expect { info.run }
// 241:       .to output("\n").to_stdout
// 242:       .and not_to_output.to_stderr
// 243:   end
// 244:
// 245:   it "prints quiet formula information in the slim inventory format" do
// 246:     info = described_class.new([])
// 247:     formula = formula("testball") do
// 248:       T.bind(self, T.class_of(Formula))
// 249:       url "https://brew.sh/testball-0.1.tar.gz"
// 250:       desc "Some test"
// 251:     end
// 252:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 253:
// 254:     expected_output = <<~EOS
// 255:       ==> testball: Some test
// 256:       Formula from https://example.com/testball.rb
// 257:       Not installed
// 258:     EOS
// 259:     expect { info.info_formula_summary(formula) }
// 260:       .to output(expected_output).to_stdout
// 261:       .and not_to_output.to_stderr
// 262:   end
// 263:
// 264:   it "uses slim formula information when quiet is passed" do
// 265:     test_formula = formula("testball") do
// 266:       T.bind(self, T.class_of(Formula))
// 267:       url "https://brew.sh/testball-0.1.tar.gz"
// 268:       desc "Some test"
// 269:     end
// 270:     info = described_class.new(["--quiet", "testball"])
// 271:     allow(info.args.named).to receive(:to_formulae_and_casks_and_unavailable).and_return([test_formula])
// 272:
// 273:     expect(info).to receive(:info_formula_summary).with(test_formula)
// 274:     expect { info.run }
// 275:       .to not_to_output.to_stderr
// 276:   end
// 277:
// 278:   it "prints inline summary information for formulae" do
// 279:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 280:
// 281:     info = described_class.new([])
// 282:     formula = formula("testball") do
// 283:       T.bind(self, T.class_of(Formula))
// 284:       url "https://brew.sh/testball-0.1.tar.gz"
// 285:       homepage "https://brew.sh/testball"
// 286:       desc "Some test"
// 287:
// 288:       option "with-foo", "Build with foo"
// 289:     end
// 290:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 291:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 292:
// 293:     expect { info.info_formula(formula) }
// 294:       .to output(/Installs from source: yes/).to_stdout
// 295:       .and not_to_output(/Metadata/).to_stdout
// 296:       .and not_to_output(/supports macOS and Linux/).to_stdout
// 297:       .and not_to_output.to_stderr
// 298:   end
// 299:
// 300:   it "shows a conflict by its resolved full name" do
// 301:     info = described_class.new([])
// 302:     formula = formula("testball") do
// 303:       T.bind(self, T.class_of(Formula))
// 304:       url "https://brew.sh/testball-0.1.tar.gz"
// 305:       conflicts_with "other"
// 306:     end
// 307:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 308:     other = formula("other") { url "https://brew.sh/other-0.1.tar.gz" }
// 309:     allow(other).to receive(:full_name).and_return("someuser/tap/other")
// 310:     allow(Formulary).to receive(:factory).with("other").and_return(other)
// 311:
// 312:     expect { info.info_formula(formula) }
// 313:       .to output(%r{Conflicts with:\n  someuser/tap/other}).to_stdout
// 314:   end
// 315:
// 316:   it "omits a stale conflict that resolves to the formula itself" do
// 317:     info = described_class.new([])
// 318:     formula = formula("testball") do
// 319:       T.bind(self, T.class_of(Formula))
// 320:       url "https://brew.sh/testball-0.1.tar.gz"
// 321:       conflicts_with "testball"
// 322:     end
// 323:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 324:     allow(Formulary).to receive(:factory).with("testball").and_return(formula)
// 325:
// 326:     expect { info.info_formula(formula) }
// 327:       .not_to output(/Conflicts with:/).to_stdout
// 328:   end
// 329:
// 330:   it "marks a deprecated formula with `(deprecated)` in the title" do
// 331:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 332:
// 333:     info = described_class.new([])
// 334:     formula = formula("testball") do
// 335:       T.bind(self, T.class_of(Formula))
// 336:       url "https://brew.sh/testball-0.1.tar.gz"
// 337:       desc "Some test"
// 338:       deprecate! date: "2024-01-01", because: :versioned_formula
// 339:     end
// 340:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 341:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 342:
// 343:     expect { info.info_formula(formula) }
// 344:       .to output(/==> .*testball.*\(deprecated\):/).to_stdout
// 345:       .and not_to_output.to_stderr
// 346:   end
// 347:
// 348:   it "marks a disabled formula with `(disabled)` in the title" do
// 349:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 350:
// 351:     info = described_class.new([])
// 352:     formula = formula("testball") do
// 353:       T.bind(self, T.class_of(Formula))
// 354:       url "https://brew.sh/testball-0.1.tar.gz"
// 355:       desc "Some test"
// 356:       disable! date: "2024-01-01", because: :unmaintained
// 357:     end
// 358:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 359:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 360:
// 361:     expect { info.info_formula(formula) }
// 362:       .to output(/==> .*testball.*\(disabled\):/).to_stdout
// 363:       .and not_to_output.to_stderr
// 364:   end
// 365:
// 366:   it "shows separate blocks for an unqualified and a qualified input that resolve to the same shadowed formula" do
// 367:     info = described_class.new([])
// 368:     core = installed_info_formula
// 369:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 370:     tab = Tab.empty
// 371:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 372:     tab.source["tap"] = "ataraxy-labs/tap"
// 373:     tab.write
// 374:     allow(core).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 375:     installed = formula("testball") { url "https://brew.sh/testball-0.1.tar.gz" }
// 376:     allow(installed).to receive_messages(tap: Tap.fetch("ataraxy-labs/tap"), full_name: "ataraxy-labs/tap/testball")
// 377:     allow(Formulary).to receive(:factory).with("ataraxy-labs/tap/testball").and_return(installed)
// 378:     allow(info).to receive(:github_info).and_return("https://example.com/testball.rb")
// 379:     allow(info.args.named).to receive_messages(
// 380:       downcased_unique_named:                ["testball", "homebrew/core/testball"],
// 381:       to_formulae_and_casks_and_unavailable: [core, core],
// 382:     )
// 383:
// 384:     expect { info.print_info }
// 385:       .to output(%r{ataraxy-labs/tap/testball.*homebrew/core/testball.*Not installed}m).to_stdout
// 386:   end
// 387:
// 388:   it "reports an unavailable name without raising" do
// 389:     info = described_class.new([])
// 390:     error = FormulaOrCaskUnavailableError.new("nonexistent-formula")
// 391:     allow(info.args.named).to receive_messages(
// 392:       downcased_unique_named:                ["nonexistent-formula"],
// 393:       to_formulae_and_casks_and_unavailable: [error],
// 394:     )
// 395:
// 396:     expect { info.print_info }
// 397:       .to output(/No available formula or cask with the name "nonexistent-formula"/).to_stderr
// 398:   end
// 399:
// 400:   it "qualifies the name, reports not installed and shows the shadowing keg when the keg belongs to another tap" do
// 401:     info = described_class.new([])
// 402:     formula = installed_info_formula
// 403:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 404:     tab = Tab.empty
// 405:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 406:     tab.source["tap"] = "ataraxy-labs/tap"
// 407:     tab.write
// 408:     allow(formula).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 409:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 410:     shadowing = formula("testball") { url "https://brew.sh/testball-0.1.tar.gz" }
// 411:     allow(shadowing).to receive_messages(tap: Tap.fetch("ataraxy-labs/tap"), full_name: "ataraxy-labs/tap/testball")
// 412:     allow(Formulary).to receive(:factory).with("ataraxy-labs/tap/testball").and_return(shadowing)
// 413:
// 414:     expect { info.info_formula(formula) }
// 415:       .to output(%r{homebrew/core/testball.*Not installed.*ataraxy-labs/tap/testball}m).to_stdout
// 416:   end
// 417:
// 418:   it "reloads the formula from the install receipt's tap and reports the shadowing tap" do
// 419:     info = described_class.new([])
// 420:     formula = installed_info_formula
// 421:
// 422:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 423:     tab = Tab.empty
// 424:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 425:     tab.source["tap"] = "ataraxy-labs/tap"
// 426:     tab.write
// 427:
// 428:     shadowing_tap = Tap.fetch("homebrew/core")
// 429:     allow(formula).to receive(:tap).and_return(shadowing_tap)
// 430:     keg_formula = formula("testball") do
// 431:       T.bind(self, T.class_of(Formula))
// 432:       url "https://brew.sh/testball-0.1.tar.gz"
// 433:     end
// 434:     allow(Formulary).to receive(:factory).with("ataraxy-labs/tap/testball").and_return(keg_formula)
// 435:
// 436:     expect(info.installed_resolution(formula)).to eq([keg_formula, shadowing_tap])
// 437:   end
// 438:
// 439:   it "resolves the keg's own name when it differs from the formula (installed via alias)" do
// 440:     info = described_class.new([])
// 441:     formula = installed_info_formula
// 442:     tab = instance_double(Tab, tap: Tap.fetch("stripe/stripe-cli"))
// 443:     keg = instance_double(Keg, name: "stripe", tab:)
// 444:     allow(formula).to receive_messages(tap: Tap.fetch("homebrew/core"), installed_kegs: [keg])
// 445:     keg_formula = formula("stripe") { url "https://brew.sh/stripe-1.0.tar.gz" }
// 446:     allow(Formulary).to receive(:factory).with("stripe/stripe-cli/stripe").and_return(keg_formula)
// 447:
// 448:     expect(info.installed_resolution(formula)).to eq([keg_formula, Tap.fetch("homebrew/core")])
// 449:   end
// 450:
// 451:   it "returns the original formula and no shadowing tap when the install receipt has no tap" do
// 452:     info = described_class.new([])
// 453:     formula = installed_info_formula
// 454:
// 455:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 456:     tab = Tab.empty
// 457:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 458:     tab.write
// 459:
// 460:     expect(info.installed_resolution(formula)).to eq([formula, nil])
// 461:   end
// 462:
// 463:   it "returns the original formula and no shadowing tap when the install receipt's tap matches" do
// 464:     info = described_class.new([])
// 465:     formula = installed_info_formula
// 466:
// 467:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 468:     tab = Tab.empty
// 469:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 470:     tab.source["tap"] = "homebrew/core"
// 471:     tab.write
// 472:
// 473:     allow(formula).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 474:     expect(info.installed_resolution(formula)).to eq([formula, nil])
// 475:   end
// 476:
// 477:   it "warns about a shadowing tap when info_formula is given one" do
// 478:     info = described_class.new([])
// 479:     formula = formula("testball") do
// 480:       T.bind(self, T.class_of(Formula))
// 481:       url "https://brew.sh/testball-0.1.tar.gz"
// 482:     end
// 483:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 484:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 485:
// 486:     expect { info.info_formula(formula, shadowed_by: Tap.fetch("homebrew/core")) }
// 487:       .to output(%r{Warning: `testball` shadows `homebrew/core/testball`}).to_stdout
// 488:       .and not_to_output.to_stderr
// 489:   end
// 490:
// 491:   it "treats a `tap/name` input as user-qualified" do
// 492:     info = described_class.new([])
// 493:     formula = formula("testball") do
// 494:       T.bind(self, T.class_of(Formula))
// 495:       url "https://brew.sh/testball-0.1.tar.gz"
// 496:     end
// 497:     allow(formula).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 498:
// 499:     qualified = Set["homebrew/core/testball"]
// 500:     expect(info.formula_qualified_by_user?(formula, qualified)).to be(true)
// 501:   end
// 502:
// 503:   it "treats a bare unqualified input as not user-qualified" do
// 504:     info = described_class.new([])
// 505:     formula = formula("testball") do
// 506:       T.bind(self, T.class_of(Formula))
// 507:       url "https://brew.sh/testball-0.1.tar.gz"
// 508:     end
// 509:
// 510:     expect(info.formula_qualified_by_user?(formula, Set.new)).to be(false)
// 511:   end
// 512:
// 513:   it "--json swaps an unqualified-input formula to its installed tap" do
// 514:     info = described_class.new(["--json", "testball"])
// 515:     shadowed_formula = installed_info_formula
// 516:
// 517:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 518:     tab = Tab.empty
// 519:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 520:     tab.source["tap"] = "ataraxy-labs/tap"
// 521:     tab.write
// 522:
// 523:     allow(shadowed_formula).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 524:     installed_formula = formula("testball") do
// 525:       T.bind(self, T.class_of(Formula))
// 526:       url "https://brew.sh/testball-0.1.tar.gz"
// 527:     end
// 528:     allow(installed_formula).to receive(:tap).and_return(Tap.fetch("ataraxy-labs/tap"))
// 529:     allow(info.args.named).to receive(:to_formulae).and_return([shadowed_formula])
// 530:     allow(Formulary).to receive(:factory).with("ataraxy-labs/tap/testball").and_return(installed_formula)
// 531:
// 532:     output = +""
// 533:     expect { info.run }.to output(satisfy { |s|
// 534:       output << s
// 535:       true
// 536:     }).to_stdout
// 537:     expect(JSON.parse(output).first["tap"]).to eq("ataraxy-labs/tap")
// 538:   end
// 539:
// 540:   it "--json honours a tap-qualified input without swapping" do
// 541:     info = described_class.new(["--json", "homebrew/core/testball"])
// 542:     formula = installed_info_formula
// 543:
// 544:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 545:     tab = Tab.empty
// 546:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 547:     tab.source["tap"] = "ataraxy-labs/tap"
// 548:     tab.write
// 549:
// 550:     allow(formula).to receive(:tap).and_return(Tap.fetch("homebrew/core"))
// 551:     allow(info.args.named).to receive(:to_formulae).and_return([formula])
// 552:
// 553:     output = +""
// 554:     expect { info.run }.to output(satisfy { |s|
// 555:       output << s
// 556:       true
// 557:     }).to_stdout
// 558:     expect(JSON.parse(output).first["tap"]).to eq("homebrew/core")
// 559:   end
// 560:
// 561:   it "prints required, recursive runtime, and dependent counts in the dependencies section" do
// 562:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 563:
// 564:     info = described_class.new([])
// 565:     formula = formula("testball") do
// 566:       T.bind(self, T.class_of(Formula))
// 567:       url "https://brew.sh/testball-0.1.tar.gz"
// 568:       homepage "https://brew.sh/testball"
// 569:       desc "Some test"
// 570:
// 571:       depends_on "bar"
// 572:     end
// 573:     direct_dependency = formula.deps.required.first
// 574:
// 575:     # Simulate an installed keg with tab runtime dependencies
// 576:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 577:     keg_path.mkpath
// 578:     tab = Tab.empty
// 579:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 580:     tab.runtime_dependencies = [
// 581:       { "full_name" => "installed-dep", "version" => "1.0" },
// 582:       { "full_name" => "missing-dep", "version" => "2.0" },
// 583:     ]
// 584:     tab.write
// 585:
// 586:     # Create a rack for the installed dependency
// 587:     installed_dep_path = HOMEBREW_CELLAR/"installed-dep/1.0"
// 588:     installed_dep_path.mkpath
// 589:     installed_dep_tab = Tab.empty
// 590:     installed_dep_tab.tabfile = installed_dep_path/AbstractTab::FILENAME
// 591:     installed_dep_tab.write
// 592:
// 593:     # Create a dependent keg whose tab references testball
// 594:     dependent_keg_path = HOMEBREW_CELLAR/"some-dependent/1.0"
// 595:     dependent_keg_path.mkpath
// 596:     dependent_tab = Tab.empty
// 597:     dependent_tab.tabfile = dependent_keg_path/AbstractTab::FILENAME
// 598:     dependent_tab.runtime_dependencies = [
// 599:       { "full_name" => "testball", "version" => "0.1" },
// 600:     ]
// 601:     dependent_tab.write
// 602:
// 603:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 604:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 605:     allow(direct_dependency).to receive(:satisfied?).and_return(true)
// 606:
// 607:     expected_output = Regexp.new(
// 608:       "==> Dependencies\nRequired \\(1\\): .*bar.*\n" \
// 609:       "Recursive Runtime \\(2\\): 1 installed .*✔, 1 missing .*✘\nDependents: 1",
// 610:     )
// 611:     expect { info.info_formula(formula) }
// 612:       .to output(expected_output).to_stdout
// 613:       .and not_to_output(/^Dependencies: /).to_stdout
// 614:       .and not_to_output.to_stderr
// 615:   end
// 616:
// 617:   it "lists installed dependents inline under Dependencies with --verbose" do
// 618:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 619:
// 620:     info = described_class.new(["--verbose"])
// 621:     formula = formula("testball") do
// 622:       T.bind(self, T.class_of(Formula))
// 623:       url "https://brew.sh/testball-0.1.tar.gz"
// 624:       homepage "https://brew.sh/testball"
// 625:       desc "Some test"
// 626:     end
// 627:
// 628:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 629:     keg_path.mkpath
// 630:     tab = Tab.empty
// 631:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 632:     tab.write
// 633:
// 634:     %w[some-dependent another-dependent].each do |dependent_name|
// 635:       dependent_keg_path = HOMEBREW_CELLAR/"#{dependent_name}/1.0"
// 636:       dependent_keg_path.mkpath
// 637:       dependent_tab = Tab.empty
// 638:       dependent_tab.tabfile = dependent_keg_path/AbstractTab::FILENAME
// 639:       dependent_tab.runtime_dependencies = [
// 640:         { "full_name" => "testball", "version" => "0.1" },
// 641:       ]
// 642:       dependent_tab.write
// 643:     end
// 644:
// 645:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 646:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 647:
// 648:     expect { info.info_formula(formula) }
// 649:       .to output(/^Dependents \(2\): another-dependent, some-dependent$/).to_stdout
// 650:       .and not_to_output(/^Dependents: /).to_stdout
// 651:       .and not_to_output.to_stderr
// 652:   end
// 653:
// 654:   it "summarises recursive runtime dependencies as all installed when none are missing" do
// 655:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 656:
// 657:     info = described_class.new([])
// 658:     formula = formula("testball") do
// 659:       T.bind(self, T.class_of(Formula))
// 660:       url "https://brew.sh/testball-0.1.tar.gz"
// 661:       homepage "https://brew.sh/testball"
// 662:       desc "Some test"
// 663:
// 664:       depends_on "bar"
// 665:     end
// 666:     direct_dependency = formula.deps.required.first
// 667:
// 668:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 669:     keg_path.mkpath
// 670:     tab = Tab.empty
// 671:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 672:     tab.runtime_dependencies = [{ "full_name" => "installed-dep", "version" => "1.0" }]
// 673:     tab.write
// 674:
// 675:     installed_dep_path = HOMEBREW_CELLAR/"installed-dep/1.0"
// 676:     installed_dep_path.mkpath
// 677:     installed_dep_tab = Tab.empty
// 678:     installed_dep_tab.tabfile = installed_dep_path/AbstractTab::FILENAME
// 679:     installed_dep_tab.write
// 680:
// 681:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 682:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 683:     allow(direct_dependency).to receive(:satisfied?).and_return(true)
// 684:
// 685:     expect { info.info_formula(formula) }
// 686:       .to output(/Recursive Runtime \(1\): all installed .*✔/).to_stdout
// 687:       .and not_to_output(/missing/).to_stdout
// 688:       .and not_to_output.to_stderr
// 689:   end
// 690:
// 691:   it "marks a tab-listed dep with no installed rack as unsatisfied" do
// 692:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 693:
// 694:     info = described_class.new([])
// 695:     formula = formula("testball") do
// 696:       T.bind(self, T.class_of(Formula))
// 697:       url "https://brew.sh/testball-0.1.tar.gz"
// 698:       desc "Some test"
// 699:
// 700:       depends_on "bar"
// 701:     end
// 702:
// 703:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 704:     keg_path.mkpath
// 705:     tab = Tab.empty
// 706:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 707:     tab.runtime_dependencies = [{ "full_name" => "bar", "version" => "1.0", "pkg_version" => "1.0" }]
// 708:     tab.write
// 709:
// 710:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 711:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 712:
// 713:     expect { info.info_formula(formula) }
// 714:       .to output(/Required \(1\): .*bar.*✘/).to_stdout
// 715:       .and not_to_output.to_stderr
// 716:   end
// 717:
// 718:   it "marks a tab-listed dep with an installed rack as satisfied when the dep formula is not outdated" do
// 719:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 720:
// 721:     info = described_class.new([])
// 722:     formula = formula("testball") do
// 723:       T.bind(self, T.class_of(Formula))
// 724:       url "https://brew.sh/testball-0.1.tar.gz"
// 725:       desc "Some test"
// 726:
// 727:       depends_on "bar"
// 728:     end
// 729:     direct_dependency = formula.deps.required.first
// 730:
// 731:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 732:     keg_path.mkpath
// 733:     tab = Tab.empty
// 734:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 735:     tab.runtime_dependencies = [{ "full_name" => "bar", "version" => "1.0", "pkg_version" => "1.0" }]
// 736:     tab.write
// 737:
// 738:     bar_keg_path = HOMEBREW_CELLAR/"bar/1.0"
// 739:     bar_keg_path.mkpath
// 740:     bar_tab = Tab.empty
// 741:     bar_tab.tabfile = bar_keg_path/AbstractTab::FILENAME
// 742:     bar_tab.write
// 743:
// 744:     bar_formula = instance_double(Formula, outdated?: false)
// 745:     allow(direct_dependency).to receive(:to_formula).and_return(bar_formula)
// 746:
// 747:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 748:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 749:
// 750:     expect { info.info_formula(formula) }
// 751:       .to output(/Required \(1\): .*bar.*✔/).to_stdout
// 752:       .and not_to_output.to_stderr
// 753:   end
// 754:
// 755:   it "marks a tab-listed dep with an installed rack as outdated when the dep formula is outdated" do
// 756:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 757:
// 758:     info = described_class.new([])
// 759:     formula = formula("testball") do
// 760:       T.bind(self, T.class_of(Formula))
// 761:       url "https://brew.sh/testball-0.1.tar.gz"
// 762:       desc "Some test"
// 763:
// 764:       depends_on "bar"
// 765:     end
// 766:     direct_dependency = formula.deps.required.first
// 767:
// 768:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 769:     keg_path.mkpath
// 770:     tab = Tab.empty
// 771:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 772:     tab.runtime_dependencies = [{ "full_name" => "bar", "version" => "1.0", "pkg_version" => "1.0" }]
// 773:     tab.write
// 774:
// 775:     bar_keg_path = HOMEBREW_CELLAR/"bar/1.0"
// 776:     bar_keg_path.mkpath
// 777:     bar_tab = Tab.empty
// 778:     bar_tab.tabfile = bar_keg_path/AbstractTab::FILENAME
// 779:     bar_tab.write
// 780:
// 781:     bar_formula = instance_double(Formula, outdated?: true)
// 782:     allow(direct_dependency).to receive(:to_formula).and_return(bar_formula)
// 783:
// 784:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 785:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 786:
// 787:     expect { info.info_formula(formula) }
// 788:       .to output(/Required \(1\): .*bar.*↑/).to_stdout
// 789:       .and not_to_output.to_stderr
// 790:   end
// 791:
// 792:   it "marks an installed dep on an uninstalled formula as satisfied" do
// 793:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 794:
// 795:     info = described_class.new([])
// 796:     formula = formula("testball") do
// 797:       T.bind(self, T.class_of(Formula))
// 798:       url "https://brew.sh/testball-0.1.tar.gz"
// 799:       desc "Some test"
// 800:
// 801:       depends_on "bar"
// 802:     end
// 803:     direct_dependency = formula.deps.required.first
// 804:
// 805:     bar_keg_path = HOMEBREW_CELLAR/"bar/1.0"
// 806:     bar_keg_path.mkpath
// 807:     bar_tab = Tab.empty
// 808:     bar_tab.tabfile = bar_keg_path/AbstractTab::FILENAME
// 809:     bar_tab.write
// 810:
// 811:     bar_formula = instance_double(Formula, outdated?: false)
// 812:     allow(direct_dependency).to receive(:to_formula).and_return(bar_formula)
// 813:
// 814:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 815:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 816:
// 817:     expect { info.info_formula(formula) }
// 818:       .to output(/Required \(1\): .*bar.*✔/).to_stdout
// 819:       .and not_to_output.to_stderr
// 820:   end
// 821:
// 822:   it "marks an outdated installed dep on an uninstalled formula as upgradable" do
// 823:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 824:
// 825:     info = described_class.new([])
// 826:     formula = formula("testball") do
// 827:       T.bind(self, T.class_of(Formula))
// 828:       url "https://brew.sh/testball-0.1.tar.gz"
// 829:       desc "Some test"
// 830:
// 831:       depends_on "bar"
// 832:     end
// 833:     direct_dependency = formula.deps.required.first
// 834:
// 835:     bar_keg_path = HOMEBREW_CELLAR/"bar/1.0"
// 836:     bar_keg_path.mkpath
// 837:     bar_tab = Tab.empty
// 838:     bar_tab.tabfile = bar_keg_path/AbstractTab::FILENAME
// 839:     bar_tab.write
// 840:
// 841:     bar_formula = instance_double(Formula, outdated?: true)
// 842:     allow(direct_dependency).to receive(:to_formula).and_return(bar_formula)
// 843:
// 844:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 845:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 846:
// 847:     expect { info.info_formula(formula) }
// 848:       .to output(/Required \(1\): .*bar.*↑/).to_stdout
// 849:       .and not_to_output.to_stderr
// 850:   end
// 851:
// 852:   it "marks an aliased dep as installed when the underlying rack exists under a different name" do
// 853:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 854:
// 855:     info = described_class.new([])
// 856:     formula = formula("testball") do
// 857:       T.bind(self, T.class_of(Formula))
// 858:       url "https://brew.sh/testball-0.1.tar.gz"
// 859:       desc "Some test"
// 860:
// 861:       depends_on "pkg-config"
// 862:     end
// 863:     direct_dependency = formula.deps.required.first
// 864:
// 865:     pkgconf_keg_path = HOMEBREW_CELLAR/"pkgconf/2.5.1"
// 866:     pkgconf_keg_path.mkpath
// 867:     pkgconf_tab = Tab.empty
// 868:     pkgconf_tab.tabfile = pkgconf_keg_path/AbstractTab::FILENAME
// 869:     pkgconf_tab.write
// 870:
// 871:     pkgconf_formula = instance_double(Formula, any_version_installed?: true, outdated?: false)
// 872:     allow(direct_dependency).to receive(:to_formula).and_return(pkgconf_formula)
// 873:
// 874:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 875:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 876:
// 877:     expect { info.info_formula(formula) }
// 878:       .to output(/Required \(1\): .*pkg-config.*✔/).to_stdout
// 879:       .and not_to_output.to_stderr
// 880:   end
// 881:
// 882:   it "does not mark a missing dep on an uninstalled formula" do
// 883:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 884:
// 885:     info = described_class.new([])
// 886:     formula = formula("testball") do
// 887:       T.bind(self, T.class_of(Formula))
// 888:       url "https://brew.sh/testball-0.1.tar.gz"
// 889:       desc "Some test"
// 890:
// 891:       depends_on "bar"
// 892:     end
// 893:
// 894:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 895:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 896:
// 897:     expect { info.info_formula(formula) }
// 898:       .to output(/Required \(1\): bar\n/).to_stdout
// 899:       .and not_to_output.to_stderr
// 900:   end
// 901:
// 902:   it "marks a dep absent from the installed keg's tab as unsatisfied when its rack is also missing" do
// 903:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 904:
// 905:     info = described_class.new([])
// 906:     formula = formula("testball") do
// 907:       T.bind(self, T.class_of(Formula))
// 908:       url "https://brew.sh/testball-0.1.tar.gz"
// 909:       desc "Some test"
// 910:
// 911:       depends_on "bar"
// 912:     end
// 913:
// 914:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 915:     keg_path.mkpath
// 916:     tab = Tab.empty
// 917:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 918:     tab.runtime_dependencies = []
// 919:     tab.write
// 920:
// 921:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 922:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 923:
// 924:     expect { info.info_formula(formula) }
// 925:       .to output(/Required \(1\): .*bar.*✘/).to_stdout
// 926:       .and not_to_output.to_stderr
// 927:   end
// 928:
// 929:   it "marks a dep absent from the installed keg's tab as installed when its rack exists" do
// 930:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 931:
// 932:     info = described_class.new([])
// 933:     formula = formula("testball") do
// 934:       T.bind(self, T.class_of(Formula))
// 935:       url "https://brew.sh/testball-0.1.tar.gz"
// 936:       desc "Some test"
// 937:
// 938:       depends_on "bar"
// 939:     end
// 940:
// 941:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 942:     keg_path.mkpath
// 943:     tab = Tab.empty
// 944:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 945:     tab.runtime_dependencies = []
// 946:     tab.write
// 947:
// 948:     bar_keg_path = HOMEBREW_CELLAR/"bar/1.0"
// 949:     bar_keg_path.mkpath
// 950:     bar_tab = Tab.empty
// 951:     bar_tab.tabfile = bar_keg_path/AbstractTab::FILENAME
// 952:     bar_tab.write
// 953:
// 954:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 955:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 956:
// 957:     expect { info.info_formula(formula) }
// 958:       .to output(/Required \(1\): .*bar.*↑/).to_stdout
// 959:       .and not_to_output.to_stderr
// 960:   end
// 961:
// 962:   it "omits build dependencies when a formula would pour from a bottle" do
// 963:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 964:
// 965:     info = described_class.new([])
// 966:     formula = formula("testball") do
// 967:       T.bind(self, T.class_of(Formula))
// 968:       url "https://brew.sh/testball-0.1.tar.gz"
// 969:       homepage "https://brew.sh/testball"
// 970:       desc "Some test"
// 971:
// 972:       depends_on "bar" => :build
// 973:     end
// 974:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 975:     allow(formula).to receive_messages(
// 976:       core_formula?:          false,
// 977:       recursive_dependencies: [],
// 978:       stable:                 instance_double(
// 979:         SoftwareSpec,
// 980:         version:  Version.new("0.1"),
// 981:         bottled?: true,
// 982:       ),
// 983:       pour_bottle?:           true,
// 984:     )
// 985:
// 986:     expect { info.info_formula(formula) }
// 987:       .to not_to_output(/Build \(1\): .*bar.*/).to_stdout
// 988:       .and not_to_output(/==> Dependencies/).to_stdout
// 989:       .and not_to_output.to_stderr
// 990:   end
// 991:
// 992:   it "shows the installed and stable versions in the headline when outdated" do
// 993:     info = described_class.new([])
// 994:     formula = formula("testball") do
// 995:       T.bind(self, T.class_of(Formula))
// 996:       url "https://brew.sh/testball-0.1.tar.gz"
// 997:       homepage "https://brew.sh/testball"
// 998:       desc "Some test"
// 999:     end
// 1000:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1001:     allow(formula).to receive_messages(core_formula?: false, outdated?: true)
// 1002:
// 1003:     keg_path = HOMEBREW_CELLAR/"testball/0.0.1"
// 1004:     keg_path.mkpath
// 1005:     tab = Tab.empty
// 1006:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 1007:     tab.write
// 1008:
// 1009:     expect { info.info_formula(formula) }
// 1010:       .to output(/\A==> testball: 0\.0\.1 → stable 0\.1\n/).to_stdout
// 1011:       .and not_to_output.to_stderr
// 1012:   end
// 1013:
// 1014:   it "prints Linux requirements through the requirements section" do
// 1015:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 1016:
// 1017:     info = described_class.new([])
// 1018:     formula = formula("testball") do
// 1019:       T.bind(self, T.class_of(Formula))
// 1020:       url "https://brew.sh/testball-0.1.tar.gz"
// 1021:       homepage "https://brew.sh/testball"
// 1022:       desc "Some test"
// 1023:     end
// 1024:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1025:     allow(formula).to receive_messages(
// 1026:       core_formula?: false,
// 1027:       requirements:  Requirements.new(LinuxRequirement.new),
// 1028:     )
// 1029:
// 1030:     expect { info.info_formula(formula) }
// 1031:       .to output(/Requirements\nRequired: .*Linux/).to_stdout
// 1032:       .and not_to_output(/supports Linux/).to_stdout
// 1033:       .and not_to_output.to_stderr
// 1034:   end
// 1035:
// 1036:   it "hides source install metadata for formulae that only run on another OS" do
// 1037:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 1038:
// 1039:     info = described_class.new([])
// 1040:     formula = formula("testball") do
// 1041:       T.bind(self, T.class_of(Formula))
// 1042:       url "https://brew.sh/testball-0.1.tar.gz"
// 1043:       homepage "https://brew.sh/testball"
// 1044:       desc "Some test"
// 1045:     end
// 1046:     os_requirement = OS.mac? ? LinuxRequirement.new : MacOSRequirement.new([:sonoma])
// 1047:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1048:     allow(formula).to receive_messages(
// 1049:       core_formula?: false,
// 1050:       requirements:  Requirements.new(os_requirement),
// 1051:     )
// 1052:
// 1053:     expect { info.info_formula(formula) }
// 1054:       .to not_to_output(/Installs from source: yes/).to_stdout
// 1055:       .and not_to_output.to_stderr
// 1056:   end
// 1057:
// 1058:   it "prints a Binaries section listing executables in bin and sbin with --verbose" do
// 1059:     info = described_class.new(["--verbose"])
// 1060:     formula = formula("testball") do
// 1061:       T.bind(self, T.class_of(Formula))
// 1062:       url "https://brew.sh/testball-0.1.tar.gz"
// 1063:       homepage "https://brew.sh/testball"
// 1064:       desc "Some test"
// 1065:     end
// 1066:
// 1067:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 1068:     (keg_path/"bin").mkpath
// 1069:     (keg_path/"sbin").mkpath
// 1070:     ["bin/testball", "bin/another", "sbin/daemon"].each do |rel|
// 1071:       file = keg_path/rel
// 1072:       file.write("#!/bin/sh\n")
// 1073:       file.chmod(0755)
// 1074:     end
// 1075:     tab = Tab.empty
// 1076:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 1077:     tab.write
// 1078:
// 1079:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1080:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 1081:
// 1082:     expect { info.info_formula(formula) }
// 1083:       .to output(a_string_including("==> Binaries\nanother\ndaemon\ntestball\n")).to_stdout
// 1084:       .and not_to_output.to_stderr
// 1085:   end
// 1086:
// 1087:   it "prints a Binaries section from the bottle manifest when the formula is not installed with --verbose" do
// 1088:     info = described_class.new(["--verbose"])
// 1089:     formula = formula("testball") do
// 1090:       T.bind(self, T.class_of(Formula))
// 1091:       url "https://brew.sh/testball-0.1.tar.gz"
// 1092:       homepage "https://brew.sh/testball"
// 1093:       desc "Some test"
// 1094:     end
// 1095:
// 1096:     bottle = instance_double(
// 1097:       Bottle,
// 1098:       path_exec_files: ["bin/testball", "bin/another", "sbin/daemon"],
// 1099:       bottle_size:     nil,
// 1100:       installed_size:  nil,
// 1101:     )
// 1102:     allow(bottle).to receive(:fetch_tab)
// 1103:     allow(formula).to receive_messages(bottle:, core_formula?: false)
// 1104:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1105:
// 1106:     expect { info.info_formula(formula) }
// 1107:       .to output(a_string_including("==> Binaries\nanother\ndaemon\ntestball\n")).to_stdout
// 1108:       .and not_to_output.to_stderr
// 1109:   end
// 1110:
// 1111:   it "omits the Binaries section without --verbose" do
// 1112:     info = described_class.new([])
// 1113:     formula = formula("testball") do
// 1114:       T.bind(self, T.class_of(Formula))
// 1115:       url "https://brew.sh/testball-0.1.tar.gz"
// 1116:       homepage "https://brew.sh/testball"
// 1117:       desc "Some test"
// 1118:     end
// 1119:
// 1120:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 1121:     (keg_path/"bin").mkpath
// 1122:     binary = keg_path/"bin/testball"
// 1123:     binary.write("#!/bin/sh\n")
// 1124:     binary.chmod(0755)
// 1125:     tab = Tab.empty
// 1126:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 1127:     tab.write
// 1128:
// 1129:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1130:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 1131:
// 1132:     expect { info.info_formula(formula) }
// 1133:       .to not_to_output(/==> Binaries/).to_stdout
// 1134:       .and not_to_output.to_stderr
// 1135:   end
// 1136:
// 1137:   it "omits the Binaries section when no executables are installed" do
// 1138:     info = described_class.new(["--verbose"])
// 1139:     formula = formula("testball") do
// 1140:       T.bind(self, T.class_of(Formula))
// 1141:       url "https://brew.sh/testball-0.1.tar.gz"
// 1142:       homepage "https://brew.sh/testball"
// 1143:       desc "Some test"
// 1144:     end
// 1145:
// 1146:     keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 1147:     (keg_path/"lib").mkpath
// 1148:     tab = Tab.empty
// 1149:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 1150:     tab.write
// 1151:
// 1152:     allow(info).to receive(:github_info).with(formula).and_return("https://example.com/testball.rb")
// 1153:     allow(formula).to receive_messages(core_formula?: false, missing_library_linkage: [[], Set.new])
// 1154:
// 1155:     expect { info.info_formula(formula) }
// 1156:       .to not_to_output(/==> Binaries/).to_stdout
// 1157:       .and not_to_output.to_stderr
// 1158:   end
// 1159:
// 1160:   describe "::installation_status" do
// 1161:     it "prints on-request installs explicitly" do
// 1162:       expect(described_class.installation_status(instance_double(Tab, installed_on_request: true)))
// 1163:         .to eq("Installed (on request)")
// 1164:     end
// 1165:
// 1166:     it "treats non-requested installs as dependency installs" do
// 1167:       expect(described_class.installation_status(instance_double(Tab, installed_on_request: false)))
// 1168:         .to eq("Installed (as dependency)")
// 1169:     end
// 1170:   end
// 1171:
// 1172:   describe "::metadata_lines" do
// 1173:     before { allow($stdout).to receive(:tty?).and_return(true) }
// 1174:
// 1175:     it "returns summary lines for pinned formulae" do
// 1176:       test_formula = formula("testball") do
// 1177:         T.bind(self, T.class_of(Formula))
// 1178:         url "https://brew.sh/testball-1.0"
// 1179:       end
// 1180:       allow(test_formula).to receive_messages(any_version_installed?: true, pinned?: true, pinned_version: "1.0")
// 1181:
// 1182:       mktmpdir do |dir|
// 1183:         pin_path = Pathname(dir/"testball")
// 1184:         pin_path.write("pin")
// 1185:         pin_time = Time.at(1_720_189_900)
// 1186:         File.utime(pin_time, pin_time, pin_path)
// 1187:         allow(FormulaPin).to receive(:new).with(test_formula).and_return(instance_double(FormulaPin, path: pin_path))
// 1188:
// 1189:         expect(described_class.metadata_lines(test_formula)).to eq([
// 1190:           "Pinned: 1.0 on #{pin_time.strftime("%Y-%m-%d at %H:%M:%S")}",
// 1191:         ])
// 1192:       end
// 1193:     end
// 1194:
// 1195:     it "returns summary lines for pinned casks" do
// 1196:       cask = Cask::Cask.new("test-cask") do
// 1197:         version "1.0"
// 1198:         url "https://brew.sh/test-cask.zip"
// 1199:       end
// 1200:       allow(cask).to receive_messages(pinned?: true, pinned_version: "1.0")
// 1201:
// 1202:       mktmpdir do |dir|
// 1203:         pin_path = Pathname(dir/"test-cask")
// 1204:         pin_path.write("pin")
// 1205:         pin_time = Time.at(1_720_189_900)
// 1206:         File.utime(pin_time, pin_time, pin_path)
// 1207:         allow(cask).to receive(:pin_path).and_return(pin_path)
// 1208:
// 1209:         expect(described_class.metadata_lines(cask)).to eq([
// 1210:           "Pinned: 1.0 on #{pin_time.strftime("%Y-%m-%d at %H:%M:%S")}",
// 1211:         ])
// 1212:       end
// 1213:     end
// 1214:   end
// 1215:
// 1216:   describe "::github_remote_path" do
// 1217:     let(:remote) { "https://github.com/Homebrew/homebrew-core" }
// 1218:
// 1219:     specify "returns correct URLs" do
// 1220:       expect(described_class.new([]).github_remote_path(remote, "Formula/git.rb"))
// 1221:         .to eq("https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git.rb")
// 1222:
// 1223:       expect(described_class.new([]).github_remote_path("#{remote}.git", "Formula/git.rb"))
// 1224:         .to eq("https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git.rb")
// 1225:
// 1226:       expect(described_class.new([]).github_remote_path("git@github.com:user/repo", "foo.rb"))
// 1227:         .to eq("https://github.com/user/repo/blob/HEAD/foo.rb")
// 1228:
// 1229:       expect(described_class.new([]).github_remote_path("https://mywebsite.com", "foo/bar.rb"))
// 1230:         .to eq("https://mywebsite.com/foo/bar.rb")
// 1231:     end
// 1232:   end
// 1233:
// 1234:   describe "Aliases and Old Names rows" do
// 1235:     it "lists aliases on their own row when the formula has any" do
// 1236:       info = described_class.new([])
// 1237:       main_formula = formula("testball") do
// 1238:         T.bind(self, T.class_of(Formula))
// 1239:         url "https://brew.sh/testball-1.0.tar.gz"
// 1240:       end
// 1241:       allow(main_formula).to receive_messages(aliases: ["testball@1.0", "tball", "googleball"], oldnames: [])
// 1242:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1243:
// 1244:       expect { info.info_formula(main_formula) }
// 1245:         .to output(/^Aliases: testball@1\.0, tball, googleball$/).to_stdout
// 1246:         .and not_to_output(/^Old Names:/).to_stdout
// 1247:         .and not_to_output.to_stderr
// 1248:     end
// 1249:
// 1250:     it "renders aliases and old names on separate rows when both exist" do
// 1251:       info = described_class.new([])
// 1252:       main_formula = formula("testball") do
// 1253:         T.bind(self, T.class_of(Formula))
// 1254:         url "https://brew.sh/testball-1.0.tar.gz"
// 1255:       end
// 1256:       allow(main_formula).to receive_messages(aliases: ["testball@1.0", "tball"], oldnames: ["foo", "bar"])
// 1257:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1258:
// 1259:       expect { info.info_formula(main_formula) }
// 1260:         .to output(/^Aliases: testball@1\.0, tball\nOld Names: foo, bar$/).to_stdout
// 1261:         .and not_to_output.to_stderr
// 1262:     end
// 1263:
// 1264:     it "renders only an Old Names row when there are no aliases" do
// 1265:       info = described_class.new([])
// 1266:       main_formula = formula("testball") do
// 1267:         T.bind(self, T.class_of(Formula))
// 1268:         url "https://brew.sh/testball-1.0.tar.gz"
// 1269:       end
// 1270:       allow(main_formula).to receive_messages(aliases: [], oldnames: ["foo"])
// 1271:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1272:
// 1273:       expect { info.info_formula(main_formula) }
// 1274:         .to output(/^Old Names: foo$/).to_stdout
// 1275:         .and not_to_output(/^Aliases:/).to_stdout
// 1276:         .and not_to_output.to_stderr
// 1277:     end
// 1278:
// 1279:     it "omits both rows when there are none" do
// 1280:       info = described_class.new([])
// 1281:       main_formula = formula("testball") do
// 1282:         T.bind(self, T.class_of(Formula))
// 1283:         url "https://brew.sh/testball-1.0.tar.gz"
// 1284:       end
// 1285:       allow(main_formula).to receive_messages(aliases: [], oldnames: [])
// 1286:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1287:
// 1288:       expect { info.info_formula(main_formula) }
// 1289:         .to not_to_output(/^Aliases:/).to_stdout
// 1290:         .and not_to_output(/^Old Names:/).to_stdout
// 1291:         .and not_to_output.to_stderr
// 1292:     end
// 1293:   end
// 1294:
// 1295:   describe "Installed section" do
// 1296:     it "lists this formula alongside installed sibling versioned formulae" do
// 1297:       info = described_class.new([])
// 1298:       main_formula = formula("testball") do
// 1299:         T.bind(self, T.class_of(Formula))
// 1300:         url "https://brew.sh/testball-1.0.tar.gz"
// 1301:       end
// 1302:       versioned = formula("testball@0.9") do
// 1303:         T.bind(self, T.class_of(Formula))
// 1304:         url "https://brew.sh/testball-0.9.tar.gz"
// 1305:         keg_only :versioned_formula
// 1306:       end
// 1307:
// 1308:       main_keg = HOMEBREW_CELLAR/"testball/1.0"
// 1309:       main_keg.mkpath
// 1310:       main_tab = Tab.empty
// 1311:       main_tab.tabfile = main_keg/AbstractTab::FILENAME
// 1312:       main_tab.write
// 1313:
// 1314:       sibling_keg = HOMEBREW_CELLAR/"testball@0.9/0.9"
// 1315:       sibling_keg.mkpath
// 1316:       sibling_tab = Tab.empty
// 1317:       sibling_tab.tabfile = sibling_keg/AbstractTab::FILENAME
// 1318:       sibling_tab.write
// 1319:
// 1320:       allow(main_formula).to receive(:versioned_formulae).and_return([versioned])
// 1321:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1322:
// 1323:       expect { info.info_formula(main_formula) }
// 1324:         .to output(Regexp.new(
// 1325:                      "==> Installed Versions\n" \
// 1326:                      ".*testball\\b.*\\s+1\\.0\\s+\\(.*\\)\n" \
// 1327:                      ".*testball@0\\.9\\b.*\\s+0\\.9\\s+\\(",
// 1328:                    )).to_stdout
// 1329:         .and not_to_output.to_stderr
// 1330:     end
// 1331:
// 1332:     it "shows installed → latest only on the newest installed keg of an outdated formula" do
// 1333:       info = described_class.new([])
// 1334:       main_formula = formula("testball") do
// 1335:         T.bind(self, T.class_of(Formula))
// 1336:         url "https://brew.sh/testball-2.0.tar.gz"
// 1337:         version "2.0"
// 1338:       end
// 1339:
// 1340:       ["1.0", "0.9"].each do |version|
// 1341:         keg_path = HOMEBREW_CELLAR/"testball/#{version}"
// 1342:         keg_path.mkpath
// 1343:         tab = Tab.empty
// 1344:         tab.tabfile = keg_path/AbstractTab::FILENAME
// 1345:         tab.write
// 1346:       end
// 1347:
// 1348:       allow(main_formula).to receive_messages(versioned_formulae: [], outdated?: true)
// 1349:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1350:
// 1351:       expect { info.info_formula(main_formula) }
// 1352:         .to output(/==> Installed Versions\n.*testball\b.*\s+1\.0 → 2\.0\s+\(/).to_stdout
// 1353:         .and not_to_output(/0\.9 →/).to_stdout
// 1354:         .and not_to_output.to_stderr
// 1355:     end
// 1356:
// 1357:     it "hides older non-linked kegs by default" do
// 1358:       info = described_class.new([])
// 1359:       main_formula = formula("testball") do
// 1360:         T.bind(self, T.class_of(Formula))
// 1361:         url "https://brew.sh/testball-1.0.tar.gz"
// 1362:       end
// 1363:
// 1364:       ["1.0", "0.9"].each do |version|
// 1365:         keg_path = HOMEBREW_CELLAR/"testball/#{version}"
// 1366:         keg_path.mkpath
// 1367:         tab = Tab.empty
// 1368:         tab.tabfile = keg_path/AbstractTab::FILENAME
// 1369:         tab.write
// 1370:       end
// 1371:
// 1372:       allow(main_formula).to receive(:versioned_formulae).and_return([])
// 1373:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1374:
// 1375:       expect { info.info_formula(main_formula) }
// 1376:         .to output(/==> Installed Versions\n.*testball\b.*\s+1\.0\s+\(/).to_stdout
// 1377:         .and not_to_output(/\s+0\.9\s+\(/).to_stdout
// 1378:         .and not_to_output.to_stderr
// 1379:     end
// 1380:
// 1381:     it "marks the currently linked version with `*`" do
// 1382:       info = described_class.new([])
// 1383:       main_formula = formula("testball") do
// 1384:         T.bind(self, T.class_of(Formula))
// 1385:         url "https://brew.sh/testball-1.0.tar.gz"
// 1386:       end
// 1387:       versioned = formula("testball@0.9") do
// 1388:         T.bind(self, T.class_of(Formula))
// 1389:         url "https://brew.sh/testball-0.9.tar.gz"
// 1390:         keg_only :versioned_formula
// 1391:       end
// 1392:
// 1393:       main_keg = HOMEBREW_CELLAR/"testball/1.0"
// 1394:       main_keg.mkpath
// 1395:       main_tab = Tab.empty
// 1396:       main_tab.tabfile = main_keg/AbstractTab::FILENAME
// 1397:       main_tab.write
// 1398:       (HOMEBREW_LINKED_KEGS/"testball").parent.mkpath
// 1399:       FileUtils.ln_s(main_keg, HOMEBREW_LINKED_KEGS/"testball")
// 1400:
// 1401:       sibling_keg = HOMEBREW_CELLAR/"testball@0.9/0.9"
// 1402:       sibling_keg.mkpath
// 1403:       sibling_tab = Tab.empty
// 1404:       sibling_tab.tabfile = sibling_keg/AbstractTab::FILENAME
// 1405:       sibling_tab.write
// 1406:
// 1407:       allow(main_formula).to receive_messages(versioned_formulae: [versioned], linked?: true,
// 1408:                                               linked_version: PkgVersion.parse("1.0"))
// 1409:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1410:
// 1411:       expect { info.info_formula(main_formula) }
// 1412:         .to output(/.*testball\b.*\s+1\.0\s+\(.*\)\s+\[Linked\]/).to_stdout
// 1413:         .and not_to_output.to_stderr
// 1414:     end
// 1415:
// 1416:     it "includes the unversioned parent when run on a versioned formula" do
// 1417:       info = described_class.new([])
// 1418:       versioned = formula("testball@0.9") do
// 1419:         T.bind(self, T.class_of(Formula))
// 1420:         url "https://brew.sh/testball-0.9.tar.gz"
// 1421:         keg_only :versioned_formula
// 1422:       end
// 1423:       parent = formula("testball") do
// 1424:         T.bind(self, T.class_of(Formula))
// 1425:         url "https://brew.sh/testball-1.0.tar.gz"
// 1426:       end
// 1427:
// 1428:       versioned_keg = HOMEBREW_CELLAR/"testball@0.9/0.9"
// 1429:       versioned_keg.mkpath
// 1430:       versioned_tab = Tab.empty
// 1431:       versioned_tab.tabfile = versioned_keg/AbstractTab::FILENAME
// 1432:       versioned_tab.write
// 1433:
// 1434:       parent_keg = HOMEBREW_CELLAR/"testball/1.0"
// 1435:       (parent_keg/"bin").mkpath
// 1436:       parent_tab = Tab.empty
// 1437:       parent_tab.tabfile = parent_keg/AbstractTab::FILENAME
// 1438:       parent_tab.write
// 1439:
// 1440:       allow(versioned).to receive(:versioned_formulae).and_return([])
// 1441:       allow(Formulary).to receive(:factory).with("testball").and_return(parent)
// 1442:       allow(info).to receive(:github_info).with(versioned).and_return("https://example.com/testball.rb")
// 1443:
// 1444:       expect { info.info_formula(versioned) }
// 1445:         .to output(Regexp.new(
// 1446:                      "==> Installed Versions\n" \
// 1447:                      ".*testball\\b.*\\s+1\\.0\\s+\\(.*\\)\n" \
// 1448:                      ".*testball@0\\.9\\b.*\\s+0\\.9\\s+\\(",
// 1449:                    )).to_stdout
// 1450:         .and not_to_output.to_stderr
// 1451:     end
// 1452:
// 1453:     it "renders the section even when only the current formula is installed" do
// 1454:       info = described_class.new([])
// 1455:       main_formula = formula("testball") do
// 1456:         T.bind(self, T.class_of(Formula))
// 1457:         url "https://brew.sh/testball-1.0.tar.gz"
// 1458:       end
// 1459:
// 1460:       keg_path = HOMEBREW_CELLAR/"testball/1.0"
// 1461:       keg_path.mkpath
// 1462:       tab = Tab.empty
// 1463:       tab.tabfile = keg_path/AbstractTab::FILENAME
// 1464:       tab.write
// 1465:
// 1466:       allow(main_formula).to receive(:versioned_formulae).and_return([])
// 1467:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1468:
// 1469:       expect { info.info_formula(main_formula) }
// 1470:         .to output(/==> Installed Versions\n.*testball\b.*\s+1\.0\s+\(/).to_stdout
// 1471:         .and not_to_output.to_stderr
// 1472:     end
// 1473:
// 1474:     it "renders the section when the queried formula is uninstalled but a sibling is installed" do
// 1475:       info = described_class.new([])
// 1476:       versioned = formula("testball@0.9") do
// 1477:         T.bind(self, T.class_of(Formula))
// 1478:         url "https://brew.sh/testball-0.9.tar.gz"
// 1479:         keg_only :versioned_formula
// 1480:       end
// 1481:       parent = formula("testball") do
// 1482:         T.bind(self, T.class_of(Formula))
// 1483:         url "https://brew.sh/testball-1.0.tar.gz"
// 1484:       end
// 1485:
// 1486:       parent_keg = HOMEBREW_CELLAR/"testball/1.0"
// 1487:       parent_keg.mkpath
// 1488:       parent_tab = Tab.empty
// 1489:       parent_tab.tabfile = parent_keg/AbstractTab::FILENAME
// 1490:       parent_tab.write
// 1491:
// 1492:       allow(versioned).to receive(:versioned_formulae).and_return([])
// 1493:       allow(Formulary).to receive(:factory).with("testball").and_return(parent)
// 1494:       allow(info).to receive(:github_info).with(versioned).and_return("https://example.com/testball.rb")
// 1495:
// 1496:       expect { info.info_formula(versioned) }
// 1497:         .to output(/==> Installed Versions\n.*testball\b.*\s+1\.0\s+\(/).to_stdout
// 1498:         .and not_to_output(/testball@0\.9 \(0\.9\)/).to_stdout
// 1499:         .and not_to_output.to_stderr
// 1500:     end
// 1501:
// 1502:     it "lists every installed keg of a formula, newest first, with --verbose" do
// 1503:       info = described_class.new(["--verbose"])
// 1504:       main_formula = formula("testball") do
// 1505:         T.bind(self, T.class_of(Formula))
// 1506:         url "https://brew.sh/testball-1.0.tar.gz"
// 1507:       end
// 1508:
// 1509:       ["0.9", "1.0", "0.10"].each do |version|
// 1510:         keg_path = HOMEBREW_CELLAR/"testball/#{version}"
// 1511:         keg_path.mkpath
// 1512:         tab = Tab.empty
// 1513:         tab.tabfile = keg_path/AbstractTab::FILENAME
// 1514:         tab.write
// 1515:       end
// 1516:
// 1517:       allow(main_formula).to receive(:versioned_formulae).and_return([])
// 1518:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1519:
// 1520:       expect { info.info_formula(main_formula) }
// 1521:         .to output(Regexp.new(
// 1522:                      "==> Installed Kegs and Versions\n" \
// 1523:                      ".*testball\\b.*\\s+1\\.0\\b.*\\(.*\\)\n" \
// 1524:                      "(?: .*\n)*" \
// 1525:                      ".*testball\\b.*\\s+0\\.10\\s+\\(.*\\)\n" \
// 1526:                      "(?: .*\n)*" \
// 1527:                      ".*testball\\b.*\\s+0\\.9\\s+\\(",
// 1528:                    )).to_stdout
// 1529:         .and not_to_output.to_stderr
// 1530:     end
// 1531:
// 1532:     it "omits the section when nothing in the family is installed" do
// 1533:       info = described_class.new([])
// 1534:       main_formula = formula("testball") do
// 1535:         T.bind(self, T.class_of(Formula))
// 1536:         url "https://brew.sh/testball-1.0.tar.gz"
// 1537:       end
// 1538:       allow(main_formula).to receive(:versioned_formulae).and_return([])
// 1539:       allow(info).to receive(:github_info).with(main_formula).and_return("https://example.com/testball.rb")
// 1540:
// 1541:       expect { info.info_formula(main_formula) }
// 1542:         .to not_to_output(/==> Installed Versions\b/).to_stdout
// 1543:         .and not_to_output.to_stderr
// 1544:     end
// 1545:   end
// 1546:
// 1547:   describe "#github_info" do
// 1548:     let(:tap) { CoreTap.instance }
// 1549:
// 1550:     it "returns the local path for a formula whose file lives outside its tap" do
// 1551:       # Simulates a formula that was removed from its tap but is still installed,
// 1552:       # so it gets loaded from the keg's `.brew/` directory by `FromKegLoader`.
// 1553:       keg_formula_path = HOMEBREW_CELLAR/"testball/0.1/.brew/testball.rb"
// 1554:       formula_instance = formula("testball", path: keg_formula_path, tap:) do
// 1555:         T.bind(self, T.class_of(Formula))
// 1556:         url "https://brew.sh/testball-0.1.tar.gz"
// 1557:       end
// 1558:
// 1559:       expect(described_class.new([]).github_info(formula_instance))
// 1560:         .to eq(keg_formula_path.to_s)
// 1561:     end
// 1562:
// 1563:     it "returns a GitHub URL for a formula whose file lives inside its tap" do
// 1564:       formula_path = tap.new_formula_path("testball")
// 1565:       formula_instance = formula("testball", path: formula_path, tap:) do
// 1566:         T.bind(self, T.class_of(Formula))
// 1567:         url "https://brew.sh/testball-0.1.tar.gz"
// 1568:       end
// 1569:
// 1570:       expect(described_class.new([]).github_info(formula_instance))
// 1571:         .to eq("https://github.com/Homebrew/homebrew-core/blob/HEAD/" \
// 1572:                "#{formula_path.relative_path_from(tap.path)}")
// 1573:     end
// 1574:   end
// 1575: end
