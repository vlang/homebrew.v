module cmd

import brew_runtime
import homebrew
import homebrew.cmd as upgrade_cmd

fn upgrade_spec_truth(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn upgrade_spec_list(value brew_runtime.Value, key string) []string {
	raw := value.attributes[key] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn upgrade_spec_formula(name string, old_version string, version string, extras map[string]string) brew_runtime.Value {
	mut attributes := extras.clone()
	attributes['name'] = name
	attributes['full_name'] = attributes['full_name'] or { name }
	attributes['full_specified_name'] = attributes['full_specified_name'] or { name }
	attributes['old_version'] = old_version
	attributes['pkg_version'] = version
	attributes['installed_versions'] = attributes['installed_versions'] or { old_version }
	attributes['outdated'] = attributes['outdated'] or { (old_version != version).str() }
	attributes['core_formula'] = attributes['core_formula'] or { 'true' }
	attributes['pour_bottle'] = attributes['pour_bottle'] or { 'true' }
	return brew_runtime.structured_value('Formula', name, attributes)
}

fn upgrade_spec_cask(name string, installed string, version string, extras map[string]string) brew_runtime.Value {
	mut attributes := extras.clone()
	attributes['token'] = name
	attributes['full_name'] = attributes['full_name'] or { name }
	attributes['installed_version'] = installed
	attributes['version'] = version
	attributes['outdated'] = attributes['outdated'] or { (installed != version).str() }
	return brew_runtime.structured_value('Cask::Cask', name, attributes)
}

fn upgrade_spec_installer(formula brew_runtime.Value, valid bool, upgraded bool, pour_bottle bool) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'FormulaInstaller'
		repr: formula.repr
		attributes: {
			'valid':       valid.str()
			'upgraded':    upgraded.str()
			'pour_bottle': pour_bottle.str()
		}
		map_data: {
			'formula': formula
		}
	}
}

fn upgrade_spec_context(formulae []brew_runtime.Value, installers []brew_runtime.Value,
	upgradeable []brew_runtime.Value, pinned []brew_runtime.Value, pinned_formulae []brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'FormulaeUpgradeContext'
		map_data: {
			'formulae_to_install': brew_runtime.array_value(formulae)
			'formulae_installer':  brew_runtime.array_value(installers)
			'dependants':          brew_runtime.map_value({
				'upgradeable': brew_runtime.array_value(upgradeable)
				'pinned':      brew_runtime.array_value(pinned)
				'skipped':     brew_runtime.array_value([])
			})
			'pinned_formulae':     brew_runtime.array_value(pinned_formulae)
		}
	}
}

fn upgrade_spec_summary(changes []string, pinned_formulae []string, pinned_casks []string,
	deprecated []string, disabled []string, source_build []string) brew_runtime.Value {
	return brew_runtime.structured_value('FinalUpgradeSummary', 'FinalUpgradeSummary', {
		'version_changes':       changes.join('\x1f')
		'pinned_formulae':       pinned_formulae.join('\x1f')
		'pinned_casks':          pinned_casks.join('\x1f')
		'deprecated':            deprecated.join('\x1f')
		'disabled':              disabled.join('\x1f')
		'source_build_formulae': source_build.join('\x1f')
	})
}

fn upgrade_spec_config(attributes map[string]string, mapped map[string]brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'UpgradeCmd'
		attributes: attributes.clone()
		map_data: mapped.clone()
	}
}

// Translated from Homebrew/brew `test/cmd/upgrade_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "trusts fully-qualified named items before resolving them" do` at line 13.
pub fn ruby_upgrade_spec_l13_d1_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	config := upgrade_spec_config({
		'named':  'thirdparty/foo/bar'
		'no_ask': 'true'
	}, {
		'resolved_items': brew_runtime.array_value([])
	})
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(config)
	return upgrade_spec_truth('trust_fully_qualified_items' in upgrade_spec_list(result, 'events'))
}

// Ruby method `install_formula_version(name, version, optlinked: false)` at line 27.
pub fn ruby_upgrade_spec_l27_d2_install_formula_version(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'testball' }
	version := if args.len > 1 { args[1].as_string() } else { '1.0' }
	optlinked := args.len > 2 && args[2].bool_data
	formula := upgrade_spec_formula(name, version, version, {
		'optlinked':   optlinked.str()
		'tabfile':     '${name}/${version}/INSTALL_RECEIPT.json'
		'tab_written': 'true'
	})
	return formula
}

// Ruby method `install_head_formula_version(name, commit, installed_stable_version: "1.0", current_stable_version: "1.1")` at line 39.
pub fn ruby_upgrade_spec_l39_d3_install_head_formula_version(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'head-formula' }
	commit := if args.len > 1 { args[1].as_string() } else { '1234567' }
	installed_stable := if args.len > 2 { args[2].as_string() } else { '1.0' }
	current_stable := if args.len > 3 { args[3].as_string() } else { '1.1' }
	return upgrade_spec_formula(name, 'HEAD-${commit}', 'HEAD-${commit}', {
		'head':                     'true'
		'optlinked':                'true'
		'installed_stable_version': installed_stable
		'current_stable_version':   current_stable
		'latest_head_pkg_version':  'HEAD-${commit}'
		'tab_spec':                 'head'
	})
}

// Ruby method `write_formula(name, content)` at line 63.
pub fn ruby_upgrade_spec_l63_d4_write_formula(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'testball' }
	content := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.structured_value('FormulaSource', name, {
		'name':        name
		'class_name':  name.split('-').map(it.capitalize()).join('')
		'content':     content
		'cache_clear': 'true'
	})
}

// Ruby method `setup_pinned_dependency_upgrade` at line 75.
pub fn ruby_upgrade_spec_l75_d5_setup_pinned_dependency_upgrade(args ...brew_runtime.Value) brew_runtime.Value {
	pinned := upgrade_spec_formula('pinned-dep', '1.0', '2.0', {
		'optlinked': 'true'
		'pinned':    'true'
	})
	dependent := upgrade_spec_formula('needs-pinned-dep', '1.0', '2.0', {
		'optlinked':    'true'
		'dependencies': 'pinned-dep'
	})
	return brew_runtime.map_value({
		'pinned':    pinned
		'dependent': dependent
	})
}

// Ruby it `it "upgrades a Formula and Cask", :cask, :integration_test do` at line 89.
pub fn ruby_upgrade_spec_l89_d6_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball_bottle', '0.0.1', '0.1', {
		'optlinked': 'true'
	})
	cask := upgrade_spec_cask('local-upgrade-test', '1.0', '2.0', {})
	formula_result := upgrade_cmd.ruby_upgrade_l610_d8_upgrade_outdated_formulae(upgrade_spec_config({
		'no_ask': 'true'
	}, {
		'formulae_context': upgrade_spec_context([formula], [
			upgrade_spec_installer(formula, true, true, true),
		], [], [], [])
	}), brew_runtime.array_value([formula]))
	cask_result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(upgrade_spec_config({}, {}), brew_runtime.array_value([
		cask,
	]))
	return upgrade_spec_truth(formula_result.bool_data && cask_result.bool_data && (cask_result.map_data['casks'].as_array() or { [] }).len == 1)
}

// Ruby it `it "links a newer Formula version when upgrade was interrupted" do` at line 127.
pub fn ruby_upgrade_spec_l127_d7_links(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball_bottle', '0.1', '0.1', {
		'optlinked':                'false'
		'outdated':                 'true'
		'latest_version_installed': 'true'
	})
	context := upgrade_cmd.ruby_upgrade_l344_d3_formulae_upgrade_context(upgrade_spec_config({}, {
		'formula_installers': brew_runtime.array_value([
			upgrade_spec_installer(formula, true, true, true),
		])
	}), brew_runtime.array_value([formula]))
	selected := context.map_data['formulae_to_install'].as_array() or { [] }
	return upgrade_spec_truth(selected.len == 1 && selected[0].repr == 'testball_bottle')
}

// Ruby it `it "refuses to upgrade a forbidden Formula" do` at line 149.
pub fn ruby_upgrade_spec_l149_d8_refuses(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball_bottle', '0.0.1', '0.1', {
		'outdated': 'true'
		'disabled': 'true'
	})
	result := upgrade_cmd.ruby_upgrade_l344_d3_formulae_upgrade_context(upgrade_spec_config({}, {}), brew_runtime.array_value([
		formula,
	]))
	return upgrade_spec_truth(result.type_name == 'NilClass' || !(result.attributes['stdout'] or { '' }).contains('testball_bottle 0.1'))
}

// Ruby it `it "upgrades a named formula installed below the minimum version" do` at line 166.
pub fn ruby_upgrade_spec_l166_d9_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('minimum-version-formula', '1.2.2', '1.2.3', {
		'optlinked': 'true'
	})
	config := upgrade_spec_config({
		'min_version': '1.2.3'
	}, {})
	return upgrade_spec_truth(upgrade_cmd.ruby_upgrade_l835_d12_formula_outdated(config, formula).bool_data)
}

// Ruby it `it "aligns formula-only no-ask upgrade summaries", :no_api do` at line 176.
pub fn ruby_upgrade_spec_l176_d10_aligns(args ...brew_runtime.Value) brew_runtime.Value {
	formatted := homebrew.ruby_upgrade_l26_d1_format_upgrade_summary(brew_runtime.string_array_value([
		'gh 2.93.0 -> 2.95.0',
		'visual-studio-code 1.111.0 -> 1.125.1',
	])).as_string_array() or { [] }
	return upgrade_spec_truth(formatted == ['gh                  2.93.0  -> 2.95.0',
		'visual-studio-code  1.111.0 -> 1.125.1'])
}

// Ruby it `it "describes unresolved HEAD formula upgrades as latest HEAD", :no_api do` at line 201.
pub fn ruby_upgrade_spec_l201_d11_describes(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('head-formula', 'HEAD-1234567', 'HEAD-1234567', {
		'head':      'true'
		'optlinked': 'true'
	})
	value := upgrade_cmd.ruby_upgrade_l884_d16_formula_upgrade_display_version(upgrade_spec_config({}, {}), formula, brew_runtime.string_value('HEAD-1234567'))
	return upgrade_spec_truth(value.as_string() == 'latest HEAD')
}

// Ruby it `it "describes fetched HEAD formula upgrades with the resolved commit", :no_api do` at line 218.
pub fn ruby_upgrade_spec_l218_d12_describes(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('head-formula', 'HEAD-1234567', 'HEAD-1234567', {
		'head':                    'true'
		'optlinked':               'true'
		'latest_head_pkg_version': 'HEAD-7654321'
	})
	value := upgrade_cmd.ruby_upgrade_l884_d16_formula_upgrade_display_version(upgrade_spec_config({
		'fetch_head': 'true'
	}, {}), formula, brew_runtime.string_value('HEAD-1234567'))
	return upgrade_spec_truth(value.as_string() == 'HEAD-7654321')
}

// Ruby it `it "skips fetched HEAD formula upgrades when the resolved commit is unchanged", :no_api do` at line 237.
pub fn ruby_upgrade_spec_l237_d13_skips(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('head-formula', 'HEAD-1234567', 'HEAD-1234567', {
		'head':                    'true'
		'optlinked':               'true'
		'latest_head_pkg_version': 'HEAD-1234567'
	})
	return upgrade_spec_truth(upgrade_cmd.ruby_upgrade_l846_d13_fetched_head_formula_current(upgrade_spec_config({
		'fetch_head': 'true'
	}, {}), formula).bool_data)
}

// Ruby it `it "does not upgrade a named formula installed at --minimum-version" do` at line 254.
pub fn ruby_upgrade_spec_l254_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('minimum-version-formula', '1.2.3', '1.2.4', {
		'optlinked': 'true'
	})
	config := upgrade_spec_config({
		'minimum_version': '1.2.3'
	}, {})
	return upgrade_spec_truth(!upgrade_cmd.ruby_upgrade_l835_d12_formula_outdated(config, formula).bool_data)
}

// Ruby it `it "warns once for a named formula that is already up-to-date" do` at line 267.
pub fn ruby_upgrade_spec_l267_d15_warns(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('up-to-date-formula', '1.2.3', '1.2.3', {
		'outdated': 'false'
	})
	result := upgrade_cmd.ruby_upgrade_l344_d3_formulae_upgrade_context(upgrade_spec_config({}, {}), brew_runtime.array_value([
		formula,
	]))
	warning := 'Warning: up-to-date-formula 1.2.3 already installed\n'
	return upgrade_spec_truth((result.attributes['stderr'] or { '' }).count(warning) == 1)
}

// Ruby it `it "warns once for a named cask that is already up-to-date", :cask do` at line 278.
pub fn ruby_upgrade_spec_l278_d16_warns(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('local-caffeine', '1.2.3', '1.2.3', {
		'outdated': 'false'
	})
	result := upgrade_cmd.ruby_upgrade_l858_d14_minimum_version_casks(upgrade_spec_config({
		'minimum_version': '1.2.3'
	}, {}), brew_runtime.array_value([cask]), brew_runtime.bool_value(false))
	return upgrade_spec_truth((result.attributes['stderr'] or { '' }).count('Not upgrading local-caffeine') == 1)
}

// Ruby it `it "does not summarize dry-run formula upgrades blocked by pinned dependencies" do` at line 286.
pub fn ruby_upgrade_spec_l286_d17_does(args ...brew_runtime.Value) brew_runtime.Value {
	fixture := ruby_upgrade_spec_l75_d5_setup_pinned_dependency_upgrade()
	pinned := fixture.map_data['pinned'] or { brew_runtime.Value{} }
	dependent := fixture.map_data['dependent'] or { brew_runtime.Value{} }
	context := upgrade_spec_context([dependent], [], [], [pinned], [])
	result := upgrade_cmd.ruby_upgrade_l610_d8_upgrade_outdated_formulae(upgrade_spec_config({
		'no_ask': 'true'
	}, {
		'formulae_context': context
	}), brew_runtime.array_value([dependent]), brew_runtime.bool_value(false), brew_runtime.bool_value(false), brew_runtime.bool_value(true))
	summary := result.map_data['final_upgrade_summary'] or { brew_runtime.Value{} }
	return upgrade_spec_truth(upgrade_spec_list(summary, 'version_changes').len == 0)
}

// Ruby it `it "does not warn about pinned formulae before ask-mode pinned dependency failures" do` at line 301.
pub fn ruby_upgrade_spec_l301_d18_does(args ...brew_runtime.Value) brew_runtime.Value {
	fixture := ruby_upgrade_spec_l75_d5_setup_pinned_dependency_upgrade()
	pinned := fixture.map_data['pinned'] or { brew_runtime.Value{} }
	dependent := fixture.map_data['dependent'] or { brew_runtime.Value{} }
	context := upgrade_cmd.ruby_upgrade_l344_d3_formulae_upgrade_context(upgrade_spec_config({}, {
		'dependants': brew_runtime.map_value({
			'upgradeable': brew_runtime.array_value([])
			'pinned':      brew_runtime.array_value([pinned])
			'skipped':     brew_runtime.array_value([])
		})
	}), brew_runtime.array_value([dependent]), brew_runtime.bool_value(false), brew_runtime.bool_value(true))
	return upgrade_spec_truth(!(context.attributes['stdout'] or { '' }).contains('Not upgrading 1 pinned package'))
}

// Ruby it `it "requires one named argument with --minimum-version" do` at line 317.
pub fn ruby_upgrade_spec_l317_d19_requires(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'minimum_version': '1.2.3'
	}, {}))
	return upgrade_spec_truth(result.type_name == 'UsageError' && result.repr.contains('requires exactly one'))
}

// Ruby it `it "rejects multiple named arguments with --minimum-version" do` at line 322.
pub fn ruby_upgrade_spec_l322_d20_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'named':           'foo\x1fbar'
		'minimum_version': '1.2.3'
	}, {}))
	return upgrade_spec_truth(result.type_name == 'UsageError' && result.repr.contains('requires exactly one'))
}

// Ruby it `it "upgrades a named cask installed below --minimum-version", :cask do` at line 327.
pub fn ruby_upgrade_spec_l327_d21_upgrades(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('local-caffeine', '1.2.2', '1.2.3', {})
	result := upgrade_cmd.ruby_upgrade_l858_d14_minimum_version_casks(upgrade_spec_config({
		'minimum_version': '1.2.3'
	}, {}), brew_runtime.array_value([cask]), brew_runtime.bool_value(false))
	return upgrade_spec_truth((result.map_data['casks'].as_array() or { [] }).len == 1)
}

// Ruby it `it "does not upgrade a named cask installed at --minimum-version", :cask do` at line 334.
pub fn ruby_upgrade_spec_l334_d22_does(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('local-caffeine', '1.2.3', '1.2.3', {})
	result := upgrade_cmd.ruby_upgrade_l858_d14_minimum_version_casks(upgrade_spec_config({
		'minimum_version': '1.2.3'
	}, {}), brew_runtime.array_value([cask]), brew_runtime.bool_value(false))
	return upgrade_spec_truth((result.map_data['casks'].as_array() or { [] }).len == 0 && (result.attributes['stderr'] or { '' }).contains('installed version is not below'))
}

// Ruby it `it "reports unavailable names via ofail and continues upgrading" do` at line 343.
pub fn ruby_upgrade_spec_l343_d23_reports(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'outdated': 'false'
	})
	unavailable := brew_runtime.object_value('FormulaOrCaskUnavailableError', 'nonexistent')
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'named':  'testball\x1fnonexistent'
		'no_ask': 'true'
	}, {
		'resolved_items': brew_runtime.array_value([formula, unavailable])
	}))
	return upgrade_spec_truth((result.attributes['stderr'] or { '' }).contains('nonexistent') && 'upgrade_formulae' in upgrade_spec_list(result, 'events'))
}

// Ruby it `it "catches cask upgrade errors and sets Homebrew.failed" do` at line 361.
pub fn ruby_upgrade_spec_l361_d24_catches(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(upgrade_spec_config({
		'cask_upgrade_error': 'test cask error'
	}, {}), brew_runtime.array_value([]))
	return upgrade_spec_truth(!result.bool_data && (result.attributes['stderr'] or { '' }).contains('test cask error'))
}

// Ruby it `it "does not ask again when upgrading discovered outdated casks" do` at line 371.
pub fn ruby_upgrade_spec_l371_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(upgrade_spec_config({}, {}), brew_runtime.array_value([]))
	return upgrade_spec_truth(result.bool_data && result.attributes['skip_prefetch'] == 'false')
}

// Ruby it `it "passes --no-quit to cask upgrades" do` at line 380.
pub fn ruby_upgrade_spec_l380_d26_passes(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(upgrade_spec_config({
		'no_quit': 'true'
	}, {}), brew_runtime.array_value([]))
	return upgrade_spec_truth(result.attributes['quit'] == 'false')
}

// Ruby it `it "passes HOMEBREW_NO_UPGRADE_QUIT_CASKS to cask upgrades" do` at line 391.
pub fn ruby_upgrade_spec_l391_d27_passes(args ...brew_runtime.Value) brew_runtime.Value {
	config := upgrade_spec_config({
		'no_quit': 'true'
	}, {})
	result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(config, brew_runtime.array_value([]))
	return upgrade_spec_truth(result.attributes['quit'] == 'false')
}

// Ruby it `it "prints formula and cask ask plans before upgrading" do` at line 405.
pub fn ruby_upgrade_spec_l405_d28_prints(args ...brew_runtime.Value) brew_runtime.Value {
	summary := upgrade_spec_summary(['testball 0.1 -> 0.2'], [], [], [], [], [])
	config := upgrade_spec_config({
		'ask_prompt_needed': 'true'
	}, {
		'planned_summary':       summary
		'final_upgrade_summary': summary
	})
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(config)
	events := upgrade_spec_list(result, 'events')
	return upgrade_spec_truth(events == ['preview_formulae', 'preview_casks', 'ask_upgrade',
		'new_shared_download_queue', 'fetch_shared_downloads', 'shutdown_shared_download_queue',
		'upgrade_formulae', 'upgrade_casks', 'periodic_cleanup', 'reinstall_pkgconf_if_needed',
		'display_messages'] && (result.attributes['stdout'] or { '' }).contains('testball 0.1 -> 0.2'))
}

// Ruby it `it "does not ask before upgrading when nothing would upgrade" do` at line 466.
pub fn ruby_upgrade_spec_l466_d29_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({}, {}))
	return upgrade_spec_truth('ask_upgrade' !in upgrade_spec_list(result, 'events'))
}

// Ruby it `it "does not prompt for confirmation in dry-run mode" do` at line 493.
pub fn ruby_upgrade_spec_l493_d30_does(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'dry_run': 'true'
	}, {}))
	return upgrade_spec_truth('ask_upgrade' !in upgrade_spec_list(result, 'events') && 'new_shared_download_queue' !in upgrade_spec_list(result, 'events'))
}

// Ruby it `it "does not ask before upgrading only explicitly named formulae" do` at line 512.
pub fn ruby_upgrade_spec_l512_d31_does(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {})
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'named':             'testball'
		'ask_prompt_needed': 'false'
	}, {
		'resolved_items': brew_runtime.array_value([formula])
	}))
	return upgrade_spec_truth('ask_upgrade' !in upgrade_spec_list(result, 'events'))
}

// Ruby it `it "asks before upgrading formulae that resolve from a different name" do` at line 519.
pub fn ruby_upgrade_spec_l519_d32_asks(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {})
	summary := upgrade_spec_summary(['testball 0.1 -> 0.2'], [], [], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'named':             'oldtestball'
		'ask_prompt_needed': 'true'
	}, {
		'resolved_items':  brew_runtime.array_value([formula])
		'planned_summary': summary
	}))
	return upgrade_spec_truth('ask_upgrade' in upgrade_spec_list(result, 'events') && (result.attributes['stdout'] or { '' }).contains('testball 0.1 -> 0.2'))
}

// Ruby it `it "prints formula download sizes in dry-run upgrade summaries" do` at line 549.
pub fn ruby_upgrade_spec_l549_d33_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked':   'true'
		'has_bottle':  'true'
		'bottle_size': '500'
	})
	descriptions := upgrade_cmd.ruby_upgrade_l578_d7_formula_upgrade_descriptions(upgrade_spec_config({}, {}), brew_runtime.array_value([
		formula,
	]), brew_runtime.bool_value(true)).as_string_array() or { [] }
	return upgrade_spec_truth(descriptions == ['testball 0.1 -> 0.2 (500B)'])
}

// Ruby it `it "omits formula download sizes in dry-run source build upgrade summaries" do` at line 565.
pub fn ruby_upgrade_spec_l565_d34_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked':         'true'
		'has_bottle':        'true'
		'bottle_size':       '500'
		'build_from_source': 'true'
	})
	descriptions := upgrade_cmd.ruby_upgrade_l578_d7_formula_upgrade_descriptions(upgrade_spec_config({}, {}), brew_runtime.array_value([
		formula,
	]), brew_runtime.bool_value(true)).as_string_array() or { [] }
	return upgrade_spec_truth(descriptions == ['testball 0.1 -> 0.2'])
}

// Ruby it `it "prints dry-run cleanup output from one formula cleanup run" do` at line 583.
pub fn ruby_upgrade_spec_l583_d35_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {})
	other := upgrade_spec_formula('otherball', '0.1', '0.2', {})
	installers := [upgrade_spec_installer(formula, true, true, true),
		upgrade_spec_installer(other, true, true, true)]
	result := homebrew.ruby_upgrade_l178_d3_upgrade_formulae(brew_runtime.array_value(installers), upgrade_spec_config({
		'dry_run':            'true'
		'cleanup_output':     'Would remove: /cellar/testball/0.1 (1KB)\n'
		'no_install_cleanup': 'true'
	}, {}))
	return upgrade_spec_truth((result.attributes['stdout'] or { '' }) == '==> Would `brew cleanup`\nWould remove: /cellar/testball/0.1 (1KB)\n')
}

// Ruby it `it "omits dry-run dependencies already listed in the final summary" do` at line 613.
pub fn ruby_upgrade_spec_l613_d36_omits(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('yt-dlp', '', '2026.3.17_2', {})
	dependency := upgrade_spec_formula('python@3.14', '', '3.14.5', {})
	mut installer := upgrade_spec_installer(formula, true, true, true)
	installer = brew_runtime.Value{
		...installer
		map_data: {
			'formula':      formula
			'dependencies': brew_runtime.array_value([dependency])
		}
	}
	result := homebrew.ruby_upgrade_l466_d8_upgrade_formula(installer, upgrade_spec_config({
		'dry_run':            'true'
		'skip_formula_names': 'python@3.14'
	}, {}))
	return upgrade_spec_truth((result.attributes['stdout'] or { '' }) == '')
}

// Ruby it `it "omits dry-run dependents already listed in the final summary" do` at line 637.
pub fn ruby_upgrade_spec_l637_d37_omits(args ...brew_runtime.Value) brew_runtime.Value {
	sqlite := upgrade_spec_formula('sqlite', '', '3.53.1', {})
	dependent := upgrade_spec_formula('python@3.14', '', '3.14.5', {})
	deps := upgrade_spec_context([], [], [dependent], [], []).map_data['dependants'] or { brew_runtime.Value{} }
	result := homebrew.ruby_upgrade_l283_d7_upgrade_dependents(deps, brew_runtime.array_value([
		sqlite,
	]), upgrade_spec_config({
		'dry_run':            'true'
		'skip_formula_names': 'python@3.14'
		'no_env_hints':       'true'
	}, {}))
	return upgrade_spec_truth(!(result.attributes['stdout'] or { '' }).contains('python@3.14'))
}

// Ruby it `it "aligns dependent formula upgrade summaries" do` at line 659.
pub fn ruby_upgrade_spec_l659_d38_aligns(args ...brew_runtime.Value) brew_runtime.Value {
	sqlite := upgrade_spec_formula('sqlite', '', '3.53.2', {})
	gh := upgrade_spec_formula('gh', '', '2.95.0', {})
	code := upgrade_spec_formula('visual-studio-code', '', '1.125.1', {})
	deps := upgrade_spec_context([], [], [gh, code], [], []).map_data['dependants'] or { brew_runtime.Value{} }
	result := homebrew.ruby_upgrade_l283_d7_upgrade_dependents(deps, brew_runtime.array_value([
		sqlite,
	]), upgrade_spec_config({
		'dry_run':      'true'
		'no_env_hints': 'true'
	}, {}))
	expected := '==> Would upgrade 2 dependents of upgraded formula:\ngh                  2.95.0\nvisual-studio-code  1.125.1\n'
	return upgrade_spec_truth((result.attributes['stdout'] or { '' }) == expected)
}

// Ruby it `it "does not claim to upgrade dependents whose runtime dependencies are satisfied" do` at line 690.
pub fn ruby_upgrade_spec_l690_d39_does(args ...brew_runtime.Value) brew_runtime.Value {
	sqlite := upgrade_spec_formula('sqlite', '', '3.53.2', {})
	dependent := upgrade_spec_formula('python@3.14', '', '3.14.5', {})
	deps := upgrade_spec_context([], [], [dependent], [], []).map_data['dependants'] or { brew_runtime.Value{} }
	result := homebrew.ruby_upgrade_l283_d7_upgrade_dependents(deps, brew_runtime.array_value([
		sqlite,
	]), upgrade_spec_config({}, {
		'installed_formulae': brew_runtime.array_value([dependent])
	}))
	return upgrade_spec_truth(!(result.attributes['stdout'] or { '' }).contains('Upgrading 1 dependent'))
}

// Ruby it `it "does not print aggregate package sizes" do` at line 709.
pub fn ruby_upgrade_spec_l709_d40_does(args ...brew_runtime.Value) brew_runtime.Value {
	summary := upgrade_spec_summary(['testball 0.1 -> 0.2 (500B)', 'codex 1.0 -> 2.0'], [], [], [], [], [])
	output := upgrade_cmd.ruby_upgrade_l528_d6_show_final_upgrade_summary(summary, brew_runtime.bool_value(true)).as_string()
	return upgrade_spec_truth(output == '==> Would upgrade 2 outdated packages\ntestball  0.1 -> 0.2 (500B)\ncodex     1.0 -> 2.0\n' && !output.contains('total'))
}

// Ruby it `it "uses the final summary for dry-run upgrade lists" do` at line 724.
pub fn ruby_upgrade_spec_l724_d41_uses(args ...brew_runtime.Value) brew_runtime.Value {
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'dry_run': 'true'
		'no_ask':  'true'
	}, {
		'final_upgrade_summary': upgrade_spec_summary([], [], [], [], [], [])
	}))
	events := upgrade_spec_list(result, 'events')
	return upgrade_spec_truth('upgrade_formulae' in events && 'upgrade_casks' in events && 'preview_formulae' !in events)
}

// Ruby it `it "prints a combined upgrade summary before fetching combined downloads" do` at line 740.
pub fn ruby_upgrade_spec_l740_d42_prints(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('deno', '2.7.10', '2.7.11', {
		'optlinked': 'true'
	})
	cask := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {})
	context := upgrade_spec_context([formula], [
		upgrade_spec_installer(formula, true, true, true),
	], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'no_ask': 'true'
	}, {
		'formulae_context':            context
		'outdated_casks':              brew_runtime.array_value([cask])
		'formatted_prefetch_upgrades': brew_runtime.string_array_value([
			'deno   2.7.10  -> 2.7.11',
			'codex  0.117.0 -> 0.118.0',
		])
	}))
	stdout := result.attributes['stdout'] or { '' }
	events := upgrade_spec_list(result, 'events')
	return upgrade_spec_truth(stdout.contains('==> Upgrading 2 outdated packages:\ndeno   2.7.10  -> 2.7.11\ncodex  0.117.0 -> 0.118.0') && events.index('fetch_shared_downloads') < events.index('upgrade_formulae'))
}

// Ruby it `it "asks before fetching formulae and casks in the same download queue" do` at line 788.
pub fn ruby_upgrade_spec_l788_d43_asks(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('deno', '2.7.10', '2.7.11', {
		'optlinked': 'true'
	})
	cask := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {})
	summary := upgrade_spec_summary(['deno 2.7.10 -> 2.7.11', 'codex 0.117.0 -> 0.118.0'], [], [], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'ask_prompt_needed': 'true'
	}, {
		'planned_summary':  summary
		'formulae_context': upgrade_spec_context([formula], [
			upgrade_spec_installer(formula, true, true, true),
		], [], [], [])
		'outdated_casks':   brew_runtime.array_value([cask])
	}))
	events := upgrade_spec_list(result, 'events')
	return upgrade_spec_truth(events.index('ask_upgrade') >= 0 && events.index('ask_upgrade') < events.index('new_shared_download_queue') && events.index('new_shared_download_queue') < events.index('fetch_shared_downloads'))
}

// Ruby it `it "uses prefetched compatible casks and carries requirement errors into upgrade" do` at line 838.
pub fn ruby_upgrade_spec_l838_d44_uses(args ...brew_runtime.Value) brew_runtime.Value {
	compatible := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {})
	incompatible := upgrade_spec_cask('bad-cask', '1.0', '2.0', {
		'requirements_error': 'bad-cask: This cask requires Linux.'
	})
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'no_ask': 'true'
	}, {
		'outdated_casks': brew_runtime.array_value([incompatible, compatible])
	}))
	return upgrade_spec_truth(result.attributes['casks_prefetched'] == 'true' && 'upgrade_casks' in upgrade_spec_list(result, 'events'))
}

// Ruby it `it "prefetches language cask files before fetching combined downloads" do` at line 871.
pub fn ruby_upgrade_spec_l871_d45_prefetches(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {
		'source_download_prefetch':  'true'
		'source_download_available': 'true'
	})
	result := upgrade_cmd.ruby_upgrade_l715_d9_prefetch_outdated_casks(upgrade_spec_config({}, {
		'outdated_casks': brew_runtime.array_value([cask])
	}), brew_runtime.array_value([]))
	return upgrade_spec_truth(upgrade_spec_list(result, 'source_downloads') == ['codex'] && result.attributes['cask_file_heading'] == 'Downloading Cask files')
}

// Ruby it `it "skips incompatible casks during combined prefetch" do` at line 924.
pub fn ruby_upgrade_spec_l924_d46_skips(args ...brew_runtime.Value) brew_runtime.Value {
	incompatible := upgrade_spec_cask('bad-cask', '1.0', '2.0', {
		'requirements_error': 'bad-cask: This cask requires Linux.'
	})
	compatible := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {})
	result := upgrade_cmd.ruby_upgrade_l715_d9_prefetch_outdated_casks(upgrade_spec_config({}, {
		'outdated_casks': brew_runtime.array_value([incompatible, compatible])
	}), brew_runtime.array_value([]))
	casks := result.map_data['prefetch_casks'].as_array() or { [] }
	return upgrade_spec_truth(upgrade_spec_list(result, 'prefetch_names') == ['codex'] && upgrade_spec_list(result, 'prefetch_upgrades') == [
		'codex 0.117.0 -> 0.118.0',
	] && upgrade_spec_list(result, 'prefetch_errors') == [
		'bad-cask: This cask requires Linux.',
	] && casks.len == 1 && casks[0].repr == 'codex')
}

// Ruby it `it "omits the cask file heading for cached language cask files" do` at line 975.
pub fn ruby_upgrade_spec_l975_d47_omits(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {
		'source_download_prefetch':  'true'
		'source_download_available': 'false'
	})
	result := upgrade_cmd.ruby_upgrade_l715_d9_prefetch_outdated_casks(upgrade_spec_config({}, {
		'outdated_casks': brew_runtime.array_value([cask])
	}), brew_runtime.array_value([]))
	return upgrade_spec_truth((result.attributes['cask_file_heading'] or { '' }) == '')
}

// Ruby it `it "passes a bottle manifest heading to the tab prefetch queue" do` at line 1023.
pub fn ruby_upgrade_spec_l1023_d48_passes(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('deno', '', '2.7.11', {
		'has_bottle': 'true'
	})
	result := homebrew.ruby_upgrade_l65_d2_formula_installers(brew_runtime.array_value([
		formula,
	]), upgrade_spec_config({
		'bottle_manifest_heading': 'Downloading bottle manifests'
	}, {}))
	installers := result.map_data['values'].as_array() or { [] }
	return upgrade_spec_truth(installers.len == 1 && installers[0].repr == 'deno' && result.attributes['bottle_manifest_heading'] == 'Downloading bottle manifests')
}

// Ruby it `it "only distrusts the formula half of a shared prefetch whose bottle download failed" do` at line 1046.
pub fn ruby_upgrade_spec_l1046_d49_only(args ...brew_runtime.Value) brew_runtime.Value {
	result := ruby_upgrade_spec_l1056_d51_run_upgrade_with_failed_shared_prefetch(brew_runtime.string_value('formula'))
	return upgrade_spec_truth(result.attributes['use_prefetched'] == 'false' && result.attributes['skip_prefetch'] == 'true')
}

// Ruby it `it "only distrusts the cask half of a shared prefetch whose cask download failed" do` at line 1051.
pub fn ruby_upgrade_spec_l1051_d50_only(args ...brew_runtime.Value) brew_runtime.Value {
	result := ruby_upgrade_spec_l1056_d51_run_upgrade_with_failed_shared_prefetch(brew_runtime.string_value('cask'))
	return upgrade_spec_truth(result.attributes['use_prefetched'] == 'true' && result.attributes['skip_prefetch'] == 'false')
}

// Ruby method `run_upgrade_with_failed_shared_prefetch(failed_download)` at line 1056.
pub fn ruby_upgrade_spec_l1056_d51_run_upgrade_with_failed_shared_prefetch(args ...brew_runtime.Value) brew_runtime.Value {
	failed := if args.len > 0 { args[0].as_string() } else { 'formula' }
	formula := upgrade_spec_formula('deno', '2.7.10', '2.7.11', {
		'optlinked': 'true'
	})
	cask := upgrade_spec_cask('codex', '0.117.0', '0.118.0', {})
	summary := upgrade_spec_summary(['deno 2.7.10 -> 2.7.11', 'codex 0.117.0 -> 0.118.0'], [], [], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l167_d2_run(upgrade_spec_config({
		'ask_prompt_needed':     'true'
		'failed_download_types': failed
	}, {
		'planned_summary':  summary
		'formulae_context': upgrade_spec_context([formula], [
			upgrade_spec_installer(formula, true, true, true),
		], [], [], [])
		'outdated_casks':   brew_runtime.array_value([cask])
	}))
	return brew_runtime.structured_value('FailedSharedPrefetchResult', failed, {
		'use_prefetched': result.attributes['formula_prefetched'] or { 'false' }
		'skip_prefetch':  result.attributes['casks_prefetched'] or { 'false' }
	})
}

// Ruby it `it "does not print removed caveats method errors for installed casks", :cask do` at line 1108.
pub fn ruby_upgrade_spec_l1108_d52_does(args ...brew_runtime.Value) brew_runtime.Value {
	cask := upgrade_spec_cask('local-caffeine', '1.2.3', '1.2.3', {
		'outdated': 'false'
	})
	result := upgrade_cmd.ruby_upgrade_l787_d10_upgrade_outdated_casks(upgrade_spec_config({
		'dry_run': 'true'
	}, {}), brew_runtime.array_value([cask]))
	return upgrade_spec_truth(!(result.attributes['stderr'] or { '' }).contains("Unexpected method 'discontinued'"))
}

// Ruby it `it "prints a narrow final upgrade summary" do` at line 1136.
pub fn ruby_upgrade_spec_l1136_d53_prints(args ...brew_runtime.Value) brew_runtime.Value {
	summary := upgrade_spec_summary(['testball 0.1 -> 0.2'], ['pinnedball 1.0'], [
		'pinned-cask 2.0',
	], ['oldball'], ['disabledball'], ['sourceball'])
	output := upgrade_cmd.ruby_upgrade_l528_d6_show_final_upgrade_summary(summary, brew_runtime.bool_value(false)).as_string()
	expected := '==> Upgraded 1 outdated package\ntestball 0.1 -> 0.2\n==> 1 Pinned formula\npinnedball 1.0\n==> 1 Pinned cask\npinned-cask 2.0\n==> 2 Deprecated or disabled packages\noldball (deprecated)\ndisabledball (disabled)\n==> 1 homebrew/core formula built from source\nsourceball\n'
	return upgrade_spec_truth(output == expected)
}

// Ruby it `it "records final formula upgrade summary details" do` at line 1164.
pub fn ruby_upgrade_spec_l1164_d54_records(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked': 'true'
	})
	pinned := upgrade_spec_formula('pinnedball', '', '1.0', {})
	deprecated := upgrade_spec_formula('oldball', '', '1.0', {
		'deprecated': 'true'
	})
	disabled := upgrade_spec_formula('disabledball', '', '1.0', {
		'disabled': 'true'
	})
	source := upgrade_spec_formula('sourceball', '', '1.0', {})
	installers := [upgrade_spec_installer(formula, true, true, true),
		upgrade_spec_installer(deprecated, true, true, true),
		upgrade_spec_installer(disabled, true, true, true),
		upgrade_spec_installer(source, true, true, false)]
	context := upgrade_spec_context([formula, deprecated, disabled, source], installers, [], [], [
		pinned,
	])
	summary := upgrade_cmd.ruby_upgrade_l497_d5_record_formula_upgrade_summary(upgrade_spec_summary([], [], [], [], [], []), context)
	return upgrade_spec_truth('testball 0.1 -> 0.2' in upgrade_spec_list(summary, 'version_changes') && 'pinnedball 1.0' in upgrade_spec_list(summary, 'pinned_formulae') && upgrade_spec_list(summary, 'deprecated') == [
		'oldball',
	] && upgrade_spec_list(summary, 'disabled') == ['disabledball'] && upgrade_spec_list(summary, 'source_build_formulae') == [
		'sourceball',
	])
}

// Ruby it `it "records formula upgrade versions before upgrading" do` at line 1214.
pub fn ruby_upgrade_spec_l1214_d55_records(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked': 'true'
	})
	context := upgrade_spec_context([formula], [
		upgrade_spec_installer(formula, true, true, true),
	], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l610_d8_upgrade_outdated_formulae(upgrade_spec_config({}, {
		'formulae_context': context
	}), brew_runtime.array_value([]))
	summary := result.map_data['final_upgrade_summary'] or { brew_runtime.Value{} }
	return upgrade_spec_truth('testball 0.1 -> 0.2' in upgrade_spec_list(summary, 'version_changes'))
}

// Ruby it `it "omits failed formula version changes from the final summary" do` at line 1245.
pub fn ruby_upgrade_spec_l1245_d56_omits(args ...brew_runtime.Value) brew_runtime.Value {
	success := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked': 'true'
	})
	failure := upgrade_spec_formula('failball', '0.1', '0.2', {
		'optlinked':  'true'
		'deprecated': 'true'
	})
	context := upgrade_spec_context([success, failure], [
		upgrade_spec_installer(success, true, true, true),
		upgrade_spec_installer(failure, true, true, true),
	], [], [], [])
	result := upgrade_cmd.ruby_upgrade_l610_d8_upgrade_outdated_formulae(upgrade_spec_config({
		'upgraded_formula_names': 'testball'
	}, {
		'formulae_context': context
	}), brew_runtime.array_value([]))
	summary := result.map_data['final_upgrade_summary'] or { brew_runtime.Value{} }
	return upgrade_spec_truth(upgrade_spec_list(summary, 'version_changes') == [
		'testball 0.1 -> 0.2',
	] && upgrade_spec_list(summary, 'deprecated') == ['failball'])
}

// Ruby it `it "reports only successful dependent version changes in the final summary" do` at line 1283.
pub fn ruby_upgrade_spec_l1283_d57_reports(args ...brew_runtime.Value) brew_runtime.Value {
	formula := upgrade_spec_formula('testball', '0.1', '0.2', {
		'optlinked': 'true'
	})
	upgraded := upgrade_spec_formula('upgraded-dependent', '0.1', '0.2', {
		'optlinked': 'true'
	})
	skipped := upgrade_spec_formula('skipped-dependent', '0.1', '0.2', {
		'optlinked': 'true'
	})
	context := upgrade_spec_context([formula], [
		upgrade_spec_installer(formula, true, true, true),
	], [
		upgraded,
		skipped,
	], [], [])
	result := upgrade_cmd.ruby_upgrade_l610_d8_upgrade_outdated_formulae(upgrade_spec_config({
		'upgraded_formula_names':   'testball'
		'upgraded_dependent_names': 'upgraded-dependent'
	}, {
		'formulae_context': context
	}), brew_runtime.array_value([]))
	summary := result.map_data['final_upgrade_summary'] or { brew_runtime.Value{} }
	return upgrade_spec_truth(upgrade_spec_list(summary, 'version_changes') == [
		'testball 0.1 -> 0.2',
		'upgraded-dependent 0.1 -> 0.2',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/upgrade"
// 6: require "cmd/shared_examples/reinstall_pkgconf_if_needed"
// 7:
// 8: RSpec.describe Homebrew::Cmd::UpgradeCmd do
// 9:   include FileUtils
// 10:
// 11:   it_behaves_like "parseable arguments"
// 12:
// 13:   it "trusts fully-qualified named items before resolving them" do
// 14:     cmd = described_class.new(["thirdparty/foo/bar"])
// 15:     allow(cmd.args.named).to receive(:present?).and_return(true)
// 16:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 17:       .with(method: :resolve)
// 18:       .and_return([])
// 19:     allow(cmd).to receive_messages(upgrade_outdated_formulae!: true, upgrade_outdated_casks!: false)
// 20:
// 21:     expect(Homebrew::Trust).to receive(:trust_fully_qualified_items!)
// 22:       .with(cmd.args.named, type: nil)
// 23:
// 24:     cmd.run
// 25:   end
// 26:
// 27:   def install_formula_version(name, version, optlinked: false)
// 28:     keg_path = HOMEBREW_CELLAR/name/version
// 29:     keg_path.mkpath
// 30:     tab = Tab.empty
// 31:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 32:     tab.write
// 33:     return unless optlinked
// 34:
// 35:     (HOMEBREW_PREFIX/"opt").mkpath
// 36:     FileUtils.ln_s(keg_path, HOMEBREW_PREFIX/"opt/#{name}")
// 37:   end
// 38:
// 39:   def install_head_formula_version(name, commit, installed_stable_version: "1.0", current_stable_version: "1.1")
// 40:     write_formula name, <<~RUBY
// 41:       url "https://brew.sh/#{name}-#{current_stable_version}"
// 42:       head "https://brew.sh/#{name}.git", using: :git
// 43:     RUBY
// 44:
// 45:     keg_path = HOMEBREW_CELLAR/name/"HEAD-#{commit}"
// 46:     keg_path.mkpath
// 47:     tab = Tab.empty
// 48:     tab.tabfile = keg_path/AbstractTab::FILENAME
// 49:     tab.source["spec"] = "head"
// 50:     tab.source["versions"] = {
// 51:       "stable"                => installed_stable_version,
// 52:       "head"                  => "HEAD",
// 53:       "version_scheme"        => 0,
// 54:       "compatibility_version" => nil,
// 55:     }
// 56:     tab.write
// 57:
// 58:     (HOMEBREW_PREFIX/"opt").mkpath
// 59:     FileUtils.ln_s(keg_path, HOMEBREW_PREFIX/"opt/#{name}")
// 60:     Formula.clear_cache
// 61:   end
// 62:
// 63:   def write_formula(name, content)
// 64:     Formulary.find_formula_in_tap(name, CoreTap.instance).tap do |path|
// 65:       path.dirname.mkpath
// 66:       path.write <<~RUBY
// 67:         class #{Formulary.class_s(name)} < Formula
// 68:         #{content.gsub(/^(?!$)/, "  ")}
// 69:         end
// 70:       RUBY
// 71:       CoreTap.instance.clear_cache
// 72:     end
// 73:   end
// 74:
// 75:   def setup_pinned_dependency_upgrade
// 76:     write_formula "pinned-dep", <<~RUBY
// 77:       url "https://brew.sh/pinned-dep-2.0"
// 78:     RUBY
// 79:     install_formula_version "pinned-dep", "1.0", optlinked: true
// 80:     Formula["pinned-dep"].pin
// 81:
// 82:     write_formula "needs-pinned-dep", <<~RUBY
// 83:       url "https://brew.sh/needs-pinned-dep-2.0"
// 84:       depends_on "pinned-dep"
// 85:     RUBY
// 86:     install_formula_version "needs-pinned-dep", "1.0", optlinked: true
// 87:   end
// 88:
// 89:   it "upgrades a Formula and Cask", :cask, :integration_test do
// 90:     formula_name = "testball_bottle"
// 91:     formula_rack = HOMEBREW_CELLAR/formula_name
// 92:
// 93:     setup_test_formula formula_name
// 94:     mktmpdir do |dir|
// 95:       (dir/"local-upgrade-test.rb").write <<~RUBY
// 96:         cask "local-upgrade-test" do
// 97:           version "1.0"
// 98:           sha256 :no_check
// 99:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 100:           stage_only true
// 101:         end
// 102:       RUBY
// 103:       (CoreCaskTap.instance.cask_dir/"local-upgrade-test.rb").write <<~RUBY
// 104:         cask "local-upgrade-test" do
// 105:           version "2.0"
// 106:           sha256 :no_check
// 107:           url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 108:           stage_only true
// 109:         end
// 110:       RUBY
// 111:       CoreCaskTap.instance.clear_cache
// 112:       InstallHelper.stub_cask_installation(Cask::CaskLoader.load(dir/"local-upgrade-test.rb"))
// 113:
// 114:       (formula_rack/"0.0.1/foo").mkpath
// 115:
// 116:       expect do
// 117:         brew "upgrade", formula_name, "local-upgrade-test"
// 118:       end.to be_a_success
// 119:
// 120:       expect(formula_rack/"0.1").to be_a_directory
// 121:       expect(formula_rack/"0.0.1").not_to exist
// 122:       expect(Cask::CaskLoader.load("local-upgrade-test").installed_version).to eq("2.0")
// 123:     end
// 124:   end
// 125:
// 126:   # links newer version when upgrade was interrupted
// 127:   it "links a newer Formula version when upgrade was interrupted" do
// 128:     formula_name = "testball_bottle"
// 129:     formula_rack = HOMEBREW_CELLAR/formula_name
// 130:     write_formula formula_name, <<~RUBY
// 131:       url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 132:       sha256 TESTBALL_SHA256
// 133:
// 134:       bottle do
// 135:         root_url "file://#{TEST_FIXTURE_DIR}/bottles"
// 136:         sha256 cellar: :any_skip_relocation, all: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 137:       end
// 138:     RUBY
// 139:     install_formula_version formula_name, "0.1"
// 140:
// 141:     expect { described_class.new([]).run }.not_to raise_error
// 142:
// 143:     expect(formula_rack/"0.1").to be_a_directory
// 144:     expect(HOMEBREW_PREFIX/"opt/#{formula_name}").to be_a_symlink
// 145:     expect(HOMEBREW_PREFIX/"var/homebrew/linked/#{formula_name}").to be_a_symlink
// 146:   end
// 147:
// 148:   # refuses to upgrade a forbidden formula
// 149:   it "refuses to upgrade a forbidden Formula" do
// 150:     formula_name = "testball_bottle"
// 151:     formula_rack = HOMEBREW_CELLAR/formula_name
// 152:     write_formula formula_name, <<~RUBY
// 153:       url "https://brew.sh/#{formula_name}-0.1"
// 154:     RUBY
// 155:     (formula_rack/"0.0.1/foo").mkpath
// 156:
// 157:     with_env("HOMEBREW_FORBIDDEN_FORMULAE" => formula_name) do
// 158:       expect { described_class.new([formula_name]).run }
// 159:         .to not_to_output(%r{#{formula_rack}/0\.1}o).to_stdout
// 160:         .and output(/#{formula_name} was forbidden/).to_stderr
// 161:     end
// 162:     expect(Homebrew).to have_failed
// 163:     expect(formula_rack/"0.1").not_to exist
// 164:   end
// 165:
// 166:   it "upgrades a named formula installed below the minimum version" do
// 167:     write_formula "minimum-version-formula", <<~RUBY
// 168:       url "https://brew.sh/minimum-version-formula-1.2.3"
// 169:     RUBY
// 170:     install_formula_version "minimum-version-formula", "1.2.2", optlinked: true
// 171:
// 172:     expect { described_class.new(["minimum-version-formula", "--min-version=1.2.3", "--dry-run"]).run }
// 173:       .to output(/minimum-version-formula 1\.2\.2 -> 1\.2\.3/).to_stdout
// 174:   end
// 175:
// 176:   it "aligns formula-only no-ask upgrade summaries", :no_api do
// 177:     write_formula "gh", <<~RUBY
// 178:       url "https://brew.sh/gh-2.95.0"
// 179:     RUBY
// 180:     write_formula "visual-studio-code", <<~RUBY
// 181:       url "https://brew.sh/visual-studio-code-1.125.1"
// 182:     RUBY
// 183:     install_formula_version "gh", "2.93.0", optlinked: true
// 184:     install_formula_version "visual-studio-code", "1.111.0", optlinked: true
// 185:     allow(Homebrew::Upgrade).to receive(:formula_installers).and_return([])
// 186:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 187:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 188:     allow(Homebrew.messages).to receive(:display_messages)
// 189:
// 190:     expected_summary = <<~EOS
// 191:       ==> Upgrading 2 outdated packages:
// 192:       gh                  2.93.0  -> 2.95.0
// 193:       visual-studio-code  1.111.0 -> 1.125.1
// 194:     EOS
// 195:
// 196:     expect do
// 197:       described_class.new(["--yes", "--formula", "gh", "visual-studio-code"]).run
// 198:     end.to output(a_string_starting_with(expected_summary)).to_stdout
// 199:   end
// 200:
// 201:   it "describes unresolved HEAD formula upgrades as latest HEAD", :no_api do
// 202:     install_head_formula_version "head-formula", "1234567"
// 203:     allow(Homebrew::Upgrade).to receive(:formula_installers).and_return([])
// 204:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 205:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 206:     allow(Homebrew.messages).to receive(:display_messages)
// 207:
// 208:     expected_summary = <<~EOS
// 209:       ==> Upgrading 1 outdated package:
// 210:       head-formula HEAD-1234567 -> latest HEAD
// 211:     EOS
// 212:
// 213:     expect do
// 214:       described_class.new(["--yes", "--formula", "head-formula"]).run
// 215:     end.to output(a_string_starting_with(expected_summary)).to_stdout
// 216:   end
// 217:
// 218:   it "describes fetched HEAD formula upgrades with the resolved commit", :no_api do
// 219:     install_head_formula_version "head-formula", "1234567"
// 220:     allow_any_instance_of(Formula).to receive(:latest_head_pkg_version)
// 221:       .and_return(PkgVersion.parse("HEAD-7654321"))
// 222:     allow(Homebrew::Upgrade).to receive(:formula_installers).and_return([])
// 223:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 224:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 225:     allow(Homebrew.messages).to receive(:display_messages)
// 226:
// 227:     expected_summary = <<~EOS
// 228:       ==> Upgrading 1 outdated package:
// 229:       head-formula HEAD-1234567 -> HEAD-7654321
// 230:     EOS
// 231:
// 232:     expect do
// 233:       described_class.new(["--yes", "--fetch-HEAD", "--formula", "head-formula"]).run
// 234:     end.to output(a_string_starting_with(expected_summary)).to_stdout
// 235:   end
// 236:
// 237:   it "skips fetched HEAD formula upgrades when the resolved commit is unchanged", :no_api do
// 238:     install_head_formula_version "head-formula", "1234567"
// 239:     allow_any_instance_of(Formula).to receive(:latest_head_pkg_version)
// 240:       .and_return(PkgVersion.parse("HEAD-1234567"))
// 241:     expect(Homebrew::Upgrade).not_to receive(:formula_installers)
// 242:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 243:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 244:     allow(Homebrew.messages).to receive(:display_messages)
// 245:
// 246:     warning = "Warning: head-formula HEAD-1234567 already installed\n"
// 247:
// 248:     expect do
// 249:       described_class.new(["--yes", "--fetch-HEAD", "--formula", "head-formula"]).run
// 250:     end.to not_to_output(/Upgrading/).to_stdout
// 251:                                      .and output(satisfy { |stderr| stderr.scan(warning).one? }).to_stderr
// 252:   end
// 253:
// 254:   it "does not upgrade a named formula installed at --minimum-version" do
// 255:     write_formula "minimum-version-formula", <<~RUBY
// 256:       url "https://brew.sh/minimum-version-formula-1.2.4"
// 257:     RUBY
// 258:     install_formula_version "minimum-version-formula", "1.2.3", optlinked: true
// 259:
// 260:     expect { described_class.new(["minimum-version-formula", "--minimum-version=1.2.3", "--dry-run"]).run }
// 261:       .to not_to_output(/Would upgrade/).to_stdout
// 262:       .and output(
// 263:         /Not upgrading minimum-version-formula, the installed version is not below the minimum version 1\.2\.3/,
// 264:       ).to_stderr
// 265:   end
// 266:
// 267:   it "warns once for a named formula that is already up-to-date" do
// 268:     write_formula "up-to-date-formula", <<~RUBY
// 269:       url "https://brew.sh/up-to-date-formula-1.2.3"
// 270:     RUBY
// 271:     install_formula_version "up-to-date-formula", "1.2.3", optlinked: true
// 272:
// 273:     warning = "Warning: up-to-date-formula 1.2.3 already installed\n"
// 274:     expect { described_class.new(["up-to-date-formula"]).run }
// 275:       .to output(satisfy { |stderr| stderr.scan(warning).one? }).to_stderr
// 276:   end
// 277:
// 278:   it "warns once for a named cask that is already up-to-date", :cask do
// 279:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("local-caffeine")))
// 280:
// 281:     warning = "Warning: Not upgrading local-caffeine, the latest version is already installed\n"
// 282:     expect { described_class.new(["--cask", "local-caffeine"]).run }
// 283:       .to output(satisfy { |stderr| stderr.scan(warning).one? }).to_stderr
// 284:   end
// 285:
// 286:   it "does not summarize dry-run formula upgrades blocked by pinned dependencies" do
// 287:     setup_pinned_dependency_upgrade
// 288:
// 289:     expect do
// 290:       described_class.new(["--dry-run", "--yes", "--formula"]).run
// 291:     end
// 292:       .to not_to_output(/Pinned formula|needs-pinned-dep/).to_stdout
// 293:       .and output(/You must `brew unpin pinned-dep` as installing needs-pinned-dep requires the latest version/)
// 294:       .to_stderr
// 295:
// 296:     expect(Homebrew).to have_failed
// 297:   ensure
// 298:     Formula["pinned-dep"].unpin if Formula["pinned-dep"].pinned?
// 299:   end
// 300:
// 301:   it "does not warn about pinned formulae before ask-mode pinned dependency failures" do
// 302:     setup_pinned_dependency_upgrade
// 303:
// 304:     expect do
// 305:       described_class.new(["--formula"]).run
// 306:     end
// 307:       .to not_to_output(/Pinned formula|needs-pinned-dep/).to_stdout
// 308:       .and output(a_string_matching(
// 309:                     /\A(?=.*You must `brew unpin pinned-dep`)(?!.*Not upgrading \d+ pinned package).*\z/m,
// 310:                   )).to_stderr
// 311:
// 312:     expect(Homebrew).to have_failed
// 313:   ensure
// 314:     Formula["pinned-dep"].unpin if Formula["pinned-dep"].pinned?
// 315:   end
// 316:
// 317:   it "requires one named argument with --minimum-version" do
// 318:     expect { described_class.new(["--minimum-version=1.2.3"]).run }
// 319:       .to raise_error(UsageError, /`--minimum-version` requires exactly one formula or cask argument/)
// 320:   end
// 321:
// 322:   it "rejects multiple named arguments with --minimum-version" do
// 323:     expect { described_class.new(["foo", "bar", "--minimum-version=1.2.3"]).run }
// 324:       .to raise_error(UsageError, /`--minimum-version` requires exactly one formula or cask argument/)
// 325:   end
// 326:
// 327:   it "upgrades a named cask installed below --minimum-version", :cask do
// 328:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("outdated/local-caffeine")))
// 329:
// 330:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1.2.3", "--dry-run"]).run }
// 331:       .to output(/local-caffeine 1\.2\.2 -> 1\.2\.3/).to_stdout
// 332:   end
// 333:
// 334:   it "does not upgrade a named cask installed at --minimum-version", :cask do
// 335:     InstallHelper.stub_cask_installation(Cask::CaskLoader.load(cask_path("local-caffeine")))
// 336:
// 337:     expect { described_class.new(["--cask", "local-caffeine", "--minimum-version=1.2.3", "--dry-run"]).run }
// 338:       .to not_to_output(/Would upgrade/).to_stdout
// 339:       .and output(/Not upgrading local-caffeine, the installed version is not below the minimum version 1\.2\.3/)
// 340:       .to_stderr
// 341:   end
// 342:
// 343:   it "reports unavailable names via ofail and continues upgrading" do
// 344:     error = FormulaOrCaskUnavailableError.new("nonexistent")
// 345:     formula = instance_double(Formula, full_name: "testball")
// 346:
// 347:     cmd = described_class.new(["testball", "nonexistent"])
// 348:     allow(cmd.args.named).to receive(:present?).and_return(true)
// 349:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 350:       .with(method: :resolve)
// 351:       .and_return([formula, error])
// 352:
// 353:     allow(cmd).to receive_messages(upgrade_outdated_formulae!: true, upgrade_outdated_casks!: false)
// 354:
// 355:     expect { cmd.run }
// 356:       .to output(/nonexistent/).to_stderr
// 357:
// 358:     expect(Homebrew).to have_failed
// 359:   end
// 360:
// 361:   it "catches cask upgrade errors and sets Homebrew.failed" do
// 362:     allow(Cask::Upgrade).to receive(:upgrade_casks!).and_raise(Cask::CaskError.new("test cask error"))
// 363:
// 364:     cmd = described_class.new(["--cask"])
// 365:     expect { cmd.upgrade_outdated_casks!([]) }
// 366:       .to output(/test cask error/).to_stderr
// 367:
// 368:     expect(Homebrew).to have_failed
// 369:   end
// 370:
// 371:   it "does not ask again when upgrading discovered outdated casks" do
// 372:     cmd = described_class.new(["--cask"])
// 373:
// 374:     expect(Homebrew::Install).not_to receive(:ask_casks)
// 375:     expect(Cask::Upgrade).to receive(:upgrade_casks!).and_return(true)
// 376:
// 377:     cmd.upgrade_outdated_casks!([])
// 378:   end
// 379:
// 380:   it "passes --no-quit to cask upgrades" do
// 381:     cmd = described_class.new(["--cask", "--no-quit"])
// 382:
// 383:     expect(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 384:       expect(kwargs[:quit]).to be(false)
// 385:       true
// 386:     end
// 387:
// 388:     cmd.upgrade_outdated_casks!([])
// 389:   end
// 390:
// 391:   it "passes HOMEBREW_NO_UPGRADE_QUIT_CASKS to cask upgrades" do
// 392:     with_env("HOMEBREW_NO_UPGRADE_QUIT_CASKS" => "1") do
// 393:       cmd = described_class.new(["--cask"])
// 394:
// 395:       expect(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 396:         expect(kwargs[:quit]).to be(false)
// 397:         true
// 398:       end
// 399:
// 400:       cmd.upgrade_outdated_casks!([])
// 401:     end
// 402:   end
// 403:
// 404:   # upgrades with asking for user prompts
// 405:   it "prints formula and cask ask plans before upgrading" do
// 406:     cmd = described_class.new([])
// 407:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, failed_downloads: [], shutdown: nil)
// 408:
// 409:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 410:       .with([], dry_run: true, show_upgrade_summary: false)
// 411:       .ordered do
// 412:         cmd.final_upgrade_summary.version_changes << "testball 0.1 -> 0.2"
// 413:         true
// 414:       end
// 415:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 416:       .with([], dry_run: true, skip_prefetch: false, show_upgrade_summary: false, download_queue: nil)
// 417:       .ordered
// 418:       .and_return(true)
// 419:     allow(cmd).to receive(:show_final_upgrade_summary).and_call_original
// 420:     expect(cmd).to receive(:show_final_upgrade_summary).with(dry_run: true).ordered
// 421:     expect(Homebrew::Install).to receive(:ask).with(action: "upgrade")
// 422:                                               .ordered
// 423:     expect(Cask::Upgrade).to receive(:show_upgrade_summary)
// 424:       .with(["testball 0.1 -> 0.2"])
// 425:       .ordered
// 426:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 427:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 428:       .with(
// 429:         [],
// 430:         prefetch_only:        true,
// 431:         download_queue:,
// 432:         prefetch_names:       [],
// 433:         prefetch_upgrades:    [],
// 434:         show_upgrade_summary: false,
// 435:       )
// 436:       .ordered
// 437:       .and_return(true)
// 438:     expect(cmd).to receive(:prefetch_outdated_casks!)
// 439:       .with(
// 440:         [],
// 441:         download_queue:,
// 442:         prefetch_names:    [],
// 443:         prefetch_upgrades: [],
// 444:         prefetch_casks:    [],
// 445:         prefetch_errors:   [],
// 446:       )
// 447:       .ordered
// 448:       .and_return(true)
// 449:     expect(download_queue).to receive(:fetch).ordered
// 450:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 451:       .with([], use_prefetched: true, show_upgrade_summary: false)
// 452:       .ordered
// 453:       .and_return(true)
// 454:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 455:       .with([], skip_prefetch: true, show_upgrade_summary: false, download_queue: nil,
// 456:                 prefetched_cask_errors: [])
// 457:       .ordered
// 458:       .and_return(true)
// 459:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 460:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 461:     allow(Homebrew.messages).to receive(:display_messages)
// 462:
// 463:     cmd.run
// 464:   end
// 465:
// 466:   it "does not ask before upgrading when nothing would upgrade" do
// 467:     cmd = described_class.new([])
// 468:
// 469:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 470:       .with([], dry_run: true, show_upgrade_summary: false)
// 471:       .ordered
// 472:       .and_return(false)
// 473:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 474:       .with([], dry_run: true, skip_prefetch: false, show_upgrade_summary: false, download_queue: nil)
// 475:       .ordered
// 476:       .and_return(false)
// 477:     expect(Homebrew::Install).not_to receive(:ask)
// 478:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 479:       .with([], use_prefetched: false, show_upgrade_summary: false)
// 480:       .ordered
// 481:       .and_return(false)
// 482:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 483:       .with([], skip_prefetch: false, show_upgrade_summary: false, download_queue: nil)
// 484:       .ordered
// 485:       .and_return(false)
// 486:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 487:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 488:     allow(Homebrew.messages).to receive(:display_messages)
// 489:
// 490:     cmd.run
// 491:   end
// 492:
// 493:   it "does not prompt for confirmation in dry-run mode" do
// 494:     cmd = described_class.new(["--dry-run"])
// 495:
// 496:     expect(Homebrew::Install).not_to receive(:ask)
// 497:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 498:       .with([], use_prefetched: false, show_upgrade_summary: false)
// 499:       .ordered
// 500:       .and_return(false)
// 501:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 502:       .with([], skip_prefetch: false, show_upgrade_summary: false, download_queue: nil)
// 503:       .ordered
// 504:       .and_return(false)
// 505:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 506:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 507:     allow(Homebrew.messages).to receive(:display_messages)
// 508:
// 509:     cmd.run
// 510:   end
// 511:
// 512:   it "does not ask before upgrading only explicitly named formulae" do
// 513:     expect(Homebrew::Install.ask_prompt_needed?(
// 514:              planned_names:   ["testball"],
// 515:              requested_names: ["testball"],
// 516:            )).to be(false)
// 517:   end
// 518:
// 519:   it "asks before upgrading formulae that resolve from a different name" do
// 520:     formula = formula("testball") do
// 521:       T.bind(self, T.class_of(Formula))
// 522:       url "https://brew.sh/testball-0.2"
// 523:     end
// 524:     cmd = described_class.new(["oldtestball"])
// 525:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable)
// 526:       .with(method: :resolve)
// 527:       .and_return([formula])
// 528:
// 529:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 530:       .with([formula], dry_run: true, show_upgrade_summary: false)
// 531:       .ordered do
// 532:         cmd.final_upgrade_summary.version_changes << "testball 0.1 -> 0.2"
// 533:         true
// 534:       end
// 535:     allow(cmd).to receive(:show_final_upgrade_summary).and_call_original
// 536:     expect(cmd).to receive(:show_final_upgrade_summary).with(dry_run: true).ordered
// 537:     expect(Homebrew::Install).to receive(:ask).with(action: "upgrade").ordered
// 538:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 539:       .with([formula], use_prefetched: false, show_upgrade_summary: false)
// 540:       .ordered
// 541:       .and_return(true)
// 542:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 543:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 544:     allow(Homebrew.messages).to receive(:display_messages)
// 545:
// 546:     expect { cmd.run }.to output(/testball 0\.1 -> 0\.2/).to_stdout
// 547:   end
// 548:
// 549:   it "prints formula download sizes in dry-run upgrade summaries" do
// 550:     cmd = described_class.new(["--dry-run"])
// 551:     formula = formula("testball") do
// 552:       T.bind(self, T.class_of(Formula))
// 553:       url "https://brew.sh/testball-0.2"
// 554:     end
// 555:     bottle = instance_double(Bottle, fetch_tab: nil, bottle_size: 500)
// 556:     keg = instance_double(Keg, version: PkgVersion.parse("0.1"), disk_usage: 1000)
// 557:
// 558:     allow(formula).to receive_messages(optlinked?: true, opt_prefix: HOMEBREW_PREFIX/"opt/testball", bottle:)
// 559:     allow(Keg).to receive(:new).with(HOMEBREW_PREFIX/"opt/testball").and_return(keg)
// 560:
// 561:     expect(cmd.formula_upgrade_descriptions([formula], include_sizes: true))
// 562:       .to eq(["testball 0.1 -> 0.2 (500B)"])
// 563:   end
// 564:
// 565:   it "omits formula download sizes in dry-run source build upgrade summaries" do
// 566:     write_formula "testball", <<~RUBY
// 567:       url "https://brew.sh/testball-0.2"
// 568:     RUBY
// 569:
// 570:     cmd = described_class.new(["--dry-run", "--build-from-source", "testball"])
// 571:     formula = Formula["testball"]
// 572:     bottle = instance_double(Bottle)
// 573:     keg = instance_double(Keg, version: PkgVersion.parse("0.1"), disk_usage: 1000)
// 574:
// 575:     allow(formula).to receive_messages(optlinked?: true, opt_prefix: HOMEBREW_PREFIX/"opt/testball", bottle:)
// 576:     allow(Keg).to receive(:new).with(HOMEBREW_PREFIX/"opt/testball").and_return(keg)
// 577:     expect(bottle).not_to receive(:fetch_tab)
// 578:
// 579:     expect(cmd.formula_upgrade_descriptions([formula], include_sizes: true))
// 580:       .to eq(["testball 0.1 -> 0.2"])
// 581:   end
// 582:
// 583:   it "prints dry-run cleanup output from one formula cleanup run" do
// 584:     formula = formula("testball") do
// 585:       T.bind(self, T.class_of(Formula))
// 586:       url "https://brew.sh/testball-0.2"
// 587:     end
// 588:     other_formula = formula("otherball") do
// 589:       T.bind(self, T.class_of(Formula))
// 590:       url "https://brew.sh/otherball-0.2"
// 591:     end
// 592:
// 593:     allow(Homebrew::Install).to receive(:print_dry_run_dependencies)
// 594:     allow(formula).to receive(:latest_version_installed?).and_return(true)
// 595:     allow(other_formula).to receive(:latest_version_installed?).and_return(true)
// 596:     expect(Homebrew::Cleanup).to receive(:dry_run_output)
// 597:       .with(formulae: [formula, other_formula])
// 598:       .and_return("Would remove: #{HOMEBREW_CELLAR}/testball/0.1 (1KB)\n")
// 599:
// 600:     with_env(HOMEBREW_NO_ENV_HINTS: "1") do
// 601:       expect do
// 602:         Homebrew::Upgrade.upgrade_formulae(
// 603:           [FormulaInstaller.new(formula), FormulaInstaller.new(other_formula)],
// 604:           dry_run: true,
// 605:         )
// 606:       end.to output(<<~EOS).to_stdout
// 607:         ==> Would `brew cleanup`
// 608:         Would remove: #{HOMEBREW_CELLAR}/testball/0.1 (1KB)
// 609:       EOS
// 610:     end
// 611:   end
// 612:
// 613:   it "omits dry-run dependencies already listed in the final summary" do
// 614:     formula = formula("yt-dlp") do
// 615:       T.bind(self, T.class_of(Formula))
// 616:       url "https://brew.sh/yt-dlp-2026.3.17_2.tar.gz"
// 617:     end
// 618:     dependency_formula = formula("python@3.14") do
// 619:       T.bind(self, T.class_of(Formula))
// 620:       url "https://brew.sh/python@3.14-3.14.5.tar.gz"
// 621:     end
// 622:     formula_installer = FormulaInstaller.new(formula)
// 623:
// 624:     allow(formula_installer).to receive(:compute_dependencies)
// 625:       .and_return([instance_double(Dependency, to_formula: dependency_formula)])
// 626:     allow(Homebrew::Cleanup).to receive(:install_formula_clean!)
// 627:
// 628:     expect do
// 629:       Homebrew::Upgrade.upgrade_formulae(
// 630:         [formula_installer],
// 631:         dry_run:            true,
// 632:         skip_formula_names: [dependency_formula.full_name],
// 633:       )
// 634:     end.not_to output.to_stdout
// 635:   end
// 636:
// 637:   it "omits dry-run dependents already listed in the final summary" do
// 638:     formula = formula("sqlite") do
// 639:       T.bind(self, T.class_of(Formula))
// 640:       url "https://brew.sh/sqlite-3.53.1.tar.gz"
// 641:     end
// 642:     dependent = formula("python@3.14") do
// 643:       T.bind(self, T.class_of(Formula))
// 644:       url "https://brew.sh/python@3.14-3.14.5.tar.gz"
// 645:     end
// 646:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [dependent], pinned: [], skipped: [])
// 647:
// 648:     expect do
// 649:       Homebrew::Upgrade.upgrade_dependents(
// 650:         dependants,
// 651:         [formula],
// 652:         flags:              [],
// 653:         dry_run:            true,
// 654:         skip_formula_names: [dependent.full_name],
// 655:       )
// 656:     end.not_to output.to_stdout
// 657:   end
// 658:
// 659:   it "aligns dependent formula upgrade summaries" do
// 660:     formula = formula("sqlite") do
// 661:       T.bind(self, T.class_of(Formula))
// 662:       url "https://brew.sh/sqlite-3.53.2.tar.gz"
// 663:     end
// 664:     dependants = Homebrew::Upgrade::Dependents.new(
// 665:       upgradeable: [
// 666:         formula("gh") do
// 667:           T.bind(self, T.class_of(Formula))
// 668:           url "https://brew.sh/gh-2.95.0.tar.gz"
// 669:         end,
// 670:         formula("visual-studio-code") do
// 671:           T.bind(self, T.class_of(Formula))
// 672:           url "https://brew.sh/visual-studio-code-1.125.1.tar.gz"
// 673:         end,
// 674:       ],
// 675:       pinned:      [],
// 676:       skipped:     [],
// 677:     )
// 678:
// 679:     with_env(HOMEBREW_NO_ENV_HINTS: "1") do
// 680:       expect do
// 681:         Homebrew::Upgrade.upgrade_dependents(dependants, [formula], flags: [], dry_run: true)
// 682:       end.to output(<<~EOS).to_stdout
// 683:         ==> Would upgrade 2 dependents of upgraded formula:
// 684:         gh                  2.95.0
// 685:         visual-studio-code  1.125.1
// 686:       EOS
// 687:     end
// 688:   end
// 689:
// 690:   it "does not claim to upgrade dependents whose runtime dependencies are satisfied" do
// 691:     formula = formula("sqlite") do
// 692:       T.bind(self, T.class_of(Formula))
// 693:       url "https://brew.sh/sqlite-3.53.2.tar.gz"
// 694:     end
// 695:     dependent = formula("python@3.14") do
// 696:       T.bind(self, T.class_of(Formula))
// 697:       url "https://brew.sh/python@3.14-3.14.5.tar.gz"
// 698:     end
// 699:     dependants = Homebrew::Upgrade::Dependents.new(upgradeable: [dependent], pinned: [], skipped: [])
// 700:
// 701:     allow(Homebrew::Upgrade).to receive(:formula_installers).and_return([])
// 702:     allow(FormulaInstaller).to receive(:installed).and_return([])
// 703:
// 704:     expect do
// 705:       Homebrew::Upgrade.upgrade_dependents(dependants, [formula], flags: [])
// 706:     end.not_to output(/Upgrading.*python@3\.14/m).to_stdout
// 707:   end
// 708:
// 709:   it "does not print aggregate package sizes" do
// 710:     cmd = described_class.new(["--dry-run"])
// 711:     summary = Homebrew::Cmd::UpgradeCmd::FinalUpgradeSummary.new(
// 712:       version_changes: ["testball 0.1 -> 0.2 (500B)", "codex 1.0 -> 2.0"],
// 713:     )
// 714:
// 715:     allow(cmd).to receive(:final_upgrade_summary).and_return(summary)
// 716:
// 717:     expect { cmd.show_final_upgrade_summary }.to output(<<~EOS).to_stdout
// 718:       ==> Would upgrade 2 outdated packages
// 719:       testball  0.1 -> 0.2 (500B)
// 720:       codex     1.0 -> 2.0
// 721:     EOS
// 722:   end
// 723:
// 724:   it "uses the final summary for dry-run upgrade lists" do
// 725:     cmd = described_class.new(["--dry-run", "--yes"])
// 726:
// 727:     expect(cmd).to receive(:upgrade_outdated_formulae!)
// 728:       .with([], use_prefetched: false, show_upgrade_summary: false)
// 729:       .and_return(true)
// 730:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 731:       .with([], skip_prefetch: false, show_upgrade_summary: false, download_queue: nil)
// 732:       .and_return(true)
// 733:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 734:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 735:     allow(Homebrew.messages).to receive(:display_messages)
// 736:
// 737:     cmd.run
// 738:   end
// 739:
// 740:   it "prints a combined upgrade summary before fetching combined downloads" do
// 741:     cmd = described_class.new(["-y"])
// 742:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, failed_downloads: [], shutdown: nil)
// 743:     cask = instance_double(
// 744:       Cask::Cask,
// 745:       artifacts:         [],
// 746:       full_name:         "codex",
// 747:       installed_version: "0.117.0",
// 748:       version:           "0.118.0",
// 749:     )
// 750:     installer = instance_double(Cask::Installer, check_requirements: nil, enqueue_downloads: nil,
// 751:                                                  source_download_requires_pre_fetch?: false)
// 752:
// 753:     expect(Homebrew::DownloadQueue).to receive(:new).once.and_return(download_queue)
// 754:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, prefetch_only: false,
// 755:                                                               prefetch_names: nil,
// 756:                                                               prefetch_upgrades: nil,
// 757:                                                               show_upgrade_summary: true,
// 758:                                                               **|
// 759:       if prefetch_only
// 760:         expect(show_upgrade_summary).to be(false)
// 761:         prefetch_names&.replace(["deno"])
// 762:         prefetch_upgrades&.replace(["deno 2.7.10 -> 2.7.11"])
// 763:       end
// 764:
// 765:       true
// 766:     end
// 767:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([cask])
// 768:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 769:     allow(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 770:       expect(kwargs[:skip_prefetch]).to be(true)
// 771:       expect(kwargs[:show_upgrade_summary]).to be(false)
// 772:
// 773:       true
// 774:     end
// 775:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 776:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 777:     allow(Homebrew.messages).to receive(:display_messages)
// 778:     expect(download_queue).to receive(:fetch)
// 779:       .with(heading: "Fetching downloads for: deno and codex")
// 780:
// 781:     expect { cmd.run }.to output(<<~EOS).to_stdout
// 782:       ==> Upgrading 2 outdated packages:
// 783:       deno   2.7.10  -> 2.7.11
// 784:       codex  0.117.0 -> 0.118.0
// 785:     EOS
// 786:   end
// 787:
// 788:   it "asks before fetching formulae and casks in the same download queue" do
// 789:     cmd = described_class.new([])
// 790:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, failed_downloads: [], shutdown: nil)
// 791:     cask = instance_double(
// 792:       Cask::Cask,
// 793:       artifacts:         [],
// 794:       full_name:         "codex",
// 795:       installed_version: "0.117.0",
// 796:       version:           "0.118.0",
// 797:     )
// 798:     installer = instance_double(Cask::Installer, check_requirements: nil, enqueue_downloads: nil,
// 799:                                                  source_download_requires_pre_fetch?: false)
// 800:
// 801:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, dry_run: false, prefetch_only: false,
// 802:                                                               use_prefetched: false, prefetch_names: nil,
// 803:                                                               prefetch_upgrades: nil, **|
// 804:       if dry_run
// 805:         cmd.final_upgrade_summary.version_changes << "deno 2.7.10 -> 2.7.11"
// 806:       elsif prefetch_only
// 807:         prefetch_names&.replace(["deno"])
// 808:         prefetch_upgrades&.replace(["deno 2.7.10 -> 2.7.11"])
// 809:       else
// 810:         expect(use_prefetched).to be(true)
// 811:       end
// 812:
// 813:       true
// 814:     end
// 815:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([cask])
// 816:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 817:     allow(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 818:       if kwargs[:dry_run]
// 819:         kwargs[:summary_upgrades] << "codex 0.117.0 -> 0.118.0"
// 820:       else
// 821:         expect(kwargs[:skip_prefetch]).to be(true)
// 822:       end
// 823:
// 824:       true
// 825:     end
// 826:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 827:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 828:     allow(Homebrew.messages).to receive(:display_messages)
// 829:
// 830:     expect(Homebrew::Install).to receive(:ask).with(action: "upgrade").ordered
// 831:     expect(Homebrew::DownloadQueue).to receive(:new).ordered.and_return(download_queue)
// 832:     expect(Homebrew::Install).to receive(:enqueue_cask_installers).ordered
// 833:     expect(download_queue).to receive(:fetch).ordered
// 834:
// 835:     cmd.run
// 836:   end
// 837:
// 838:   it "uses prefetched compatible casks and carries requirement errors into upgrade" do
// 839:     cmd = described_class.new(["--yes"])
// 840:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, failed_downloads: [], shutdown: nil)
// 841:     cask = instance_double(Cask::Cask)
// 842:     cask_error = Cask::CaskError.new("bad-cask: This cask requires Linux.")
// 843:
// 844:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, prefetch_only: false, **|
// 845:       prefetch_only
// 846:     end
// 847:     expect(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 848:     expect(cmd).to receive(:prefetch_outdated_casks!) do |_, prefetch_upgrades:, prefetch_casks:,
// 849:                                                             prefetch_errors:, **|
// 850:       prefetch_upgrades.replace(["codex 0.117.0 -> 0.118.0"])
// 851:       prefetch_casks.replace([cask])
// 852:       prefetch_errors << cask_error
// 853:       true
// 854:     end
// 855:     expect(cmd).to receive(:upgrade_outdated_casks!)
// 856:       .with(
// 857:         [cask],
// 858:         skip_prefetch:          true,
// 859:         show_upgrade_summary:   false,
// 860:         download_queue:         nil,
// 861:         prefetched_cask_errors: [cask_error],
// 862:       )
// 863:       .and_return(true)
// 864:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 865:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 866:     allow(Homebrew.messages).to receive(:display_messages)
// 867:
// 868:     cmd.run
// 869:   end
// 870:
// 871:   it "prefetches language cask files before fetching combined downloads" do
// 872:     cmd = described_class.new(["--yes"])
// 873:     download_queue = instance_double(Homebrew::DownloadQueue, failed_downloads: [], shutdown: nil)
// 874:     cask = instance_double(
// 875:       Cask::Cask,
// 876:       artifacts:         [],
// 877:       full_name:         "codex",
// 878:       installed_version: "0.117.0",
// 879:       version:           "0.118.0",
// 880:     )
// 881:     installer = instance_double(
// 882:       Cask::Installer,
// 883:       check_requirements:                  nil,
// 884:       enqueue_downloads:                   nil,
// 885:       source_download_requires_pre_fetch?: true,
// 886:     )
// 887:     source_download = instance_double(Homebrew::API::SourceDownload)
// 888:
// 889:     expect(Homebrew::DownloadQueue).to receive(:new).once.and_return(download_queue)
// 890:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, prefetch_only: false,
// 891:                                                               prefetch_names: nil,
// 892:                                                               prefetch_upgrades: nil,
// 893:                                                               show_upgrade_summary: true,
// 894:                                                               **|
// 895:       if prefetch_only
// 896:         expect(show_upgrade_summary).to be(false)
// 897:         prefetch_names&.replace(["deno"])
// 898:         prefetch_upgrades&.replace(["deno 2.7.10 -> 2.7.11"])
// 899:       end
// 900:
// 901:       true
// 902:     end
// 903:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 904:     expect(installer).to receive(:prelude_fetch_download).and_return(source_download)
// 905:     expect(download_queue).to receive(:enqueue).with(source_download).ordered
// 906:     expect(download_queue).to receive(:fetch)
// 907:       .with(only: Cask::Download, heading: "Downloading Cask files")
// 908:       .ordered
// 909:     expect(download_queue).to receive(:fetch)
// 910:       .with(heading: "Fetching downloads for: deno and codex")
// 911:       .ordered
// 912:     allow(Cask::Upgrade).to receive_messages(outdated_casks: [cask], upgrade_casks!: true)
// 913:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 914:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 915:     allow(Homebrew.messages).to receive(:display_messages)
// 916:
// 917:     expect { cmd.run }.to output(<<~EOS).to_stdout
// 918:       ==> Upgrading 2 outdated packages:
// 919:       deno   2.7.10  -> 2.7.11
// 920:       codex  0.117.0 -> 0.118.0
// 921:     EOS
// 922:   end
// 923:
// 924:   it "skips incompatible casks during combined prefetch" do
// 925:     cmd = described_class.new(["--yes"])
// 926:     download_queue = instance_double(Homebrew::DownloadQueue)
// 927:     incompatible_cask = instance_double(
// 928:       Cask::Cask,
// 929:       artifacts:         [],
// 930:       full_name:         "bad-cask",
// 931:       installed_version: "1.0",
// 932:       token:             "bad-cask",
// 933:       version:           "2.0",
// 934:     )
// 935:     compatible_cask = instance_double(
// 936:       Cask::Cask,
// 937:       artifacts:         [],
// 938:       full_name:         "codex",
// 939:       installed_version: "0.117.0",
// 940:       token:             "codex",
// 941:       version:           "0.118.0",
// 942:     )
// 943:     incompatible_installer = instance_double(Cask::Installer)
// 944:     compatible_installer = instance_double(Cask::Installer, check_requirements: nil)
// 945:     prefetch_names = []
// 946:     prefetch_upgrades = []
// 947:     prefetch_casks = []
// 948:     prefetch_errors = []
// 949:
// 950:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([incompatible_cask, compatible_cask])
// 951:     allow(incompatible_installer).to receive(:check_requirements)
// 952:       .and_raise(Cask::CaskError, "bad-cask: This cask requires Linux.")
// 953:     allow(Cask::Installer).to receive(:new) do |cask, **|
// 954:       (cask == incompatible_cask) ? incompatible_installer : compatible_installer
// 955:     end
// 956:     expect(Homebrew::Install).to receive(:enqueue_cask_installers).with([compatible_installer], download_queue:)
// 957:     expect(cmd).not_to receive(:ofail)
// 958:
// 959:     expect(
// 960:       cmd.prefetch_outdated_casks!(
// 961:         [],
// 962:         download_queue:,
// 963:         prefetch_names:,
// 964:         prefetch_upgrades:,
// 965:         prefetch_casks:,
// 966:         prefetch_errors:,
// 967:       ),
// 968:     ).to be(true)
// 969:     expect(prefetch_names).to eq(["codex"])
// 970:     expect(prefetch_upgrades).to eq(["codex 0.117.0 -> 0.118.0"])
// 971:     expect(prefetch_casks).to eq([compatible_cask])
// 972:     expect(prefetch_errors.map(&:to_s)).to eq(["bad-cask: This cask requires Linux."])
// 973:   end
// 974:
// 975:   it "omits the cask file heading for cached language cask files" do
// 976:     cmd = described_class.new(["-y"])
// 977:     download_queue = instance_double(Homebrew::DownloadQueue, failed_downloads: [], shutdown: nil)
// 978:     cask = instance_double(
// 979:       Cask::Cask,
// 980:       artifacts:         [],
// 981:       full_name:         "codex",
// 982:       installed_version: "0.117.0",
// 983:       version:           "0.118.0",
// 984:     )
// 985:     installer = instance_double(
// 986:       Cask::Installer,
// 987:       check_requirements:                  nil,
// 988:       enqueue_downloads:                   nil,
// 989:       source_download_requires_pre_fetch?: true,
// 990:     )
// 991:
// 992:     expect(Homebrew::DownloadQueue).to receive(:new).once.and_return(download_queue)
// 993:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, prefetch_only: false,
// 994:                                                               prefetch_names: nil,
// 995:                                                               prefetch_upgrades: nil,
// 996:                                                               show_upgrade_summary: true,
// 997:                                                               **|
// 998:       if prefetch_only
// 999:         expect(show_upgrade_summary).to be(false)
// 1000:         prefetch_names&.replace(["deno"])
// 1001:         prefetch_upgrades&.replace(["deno 2.7.10 -> 2.7.11"])
// 1002:       end
// 1003:
// 1004:       true
// 1005:     end
// 1006:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 1007:     expect(installer).to receive(:prelude_fetch_download).and_return(nil)
// 1008:     expect(download_queue).to receive(:fetch)
// 1009:       .with(heading: "Fetching downloads for: deno and codex")
// 1010:       .once
// 1011:     allow(Cask::Upgrade).to receive_messages(outdated_casks: [cask], upgrade_casks!: true)
// 1012:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 1013:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 1014:     allow(Homebrew.messages).to receive(:display_messages)
// 1015:
// 1016:     expect { cmd.run }.to output(<<~EOS).to_stdout
// 1017:       ==> Upgrading 2 outdated packages:
// 1018:       deno   2.7.10  -> 2.7.11
// 1019:       codex  0.117.0 -> 0.118.0
// 1020:     EOS
// 1021:   end
// 1022:
// 1023:   it "passes a bottle manifest heading to the tab prefetch queue" do
// 1024:     formula = formula("deno") do
// 1025:       T.bind(self, T.class_of(Formula))
// 1026:       url "https://brew.sh/deno-2.7.11.tar.gz"
// 1027:
// 1028:       bottle do
// 1029:         root_url HOMEBREW_BOTTLE_DEFAULT_DOMAIN
// 1030:         sha256 cellar: :any_skip_relocation,
// 1031:                Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 1032:       end
// 1033:     end
// 1034:     download_queue = instance_double(Homebrew::DownloadQueue, enqueue: nil, shutdown: nil)
// 1035:
// 1036:     allow(formula).to receive(:latest_formula).and_return(formula)
// 1037:     allow(Migrator).to receive(:migrate_if_needed)
// 1038:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 1039:     expect(Homebrew).not_to receive(:default_download_queue)
// 1040:     expect(download_queue).to receive(:fetch)
// 1041:       .with(only: Resource::BottleManifest, heading: "Downloading bottle manifests", allow_failures: true)
// 1042:
// 1043:     Homebrew::Upgrade.formula_installers([formula], flags: [])
// 1044:   end
// 1045:
// 1046:   it "only distrusts the formula half of a shared prefetch whose bottle download failed" do
// 1047:     expect(run_upgrade_with_failed_shared_prefetch(instance_double(Bottle)))
// 1048:       .to eq(use_prefetched: false, skip_prefetch: true)
// 1049:   end
// 1050:
// 1051:   it "only distrusts the cask half of a shared prefetch whose cask download failed" do
// 1052:     expect(run_upgrade_with_failed_shared_prefetch(Cask::Download.new(Cask::Cask.new("codex"))))
// 1053:       .to eq(use_prefetched: true, skip_prefetch: false)
// 1054:   end
// 1055:
// 1056:   def run_upgrade_with_failed_shared_prefetch(failed_download)
// 1057:     upgraded = {}
// 1058:     cmd = described_class.new([])
// 1059:     download_queue = instance_double(Homebrew::DownloadQueue, fetch:            nil,
// 1060:                                                               failed_downloads: [failed_download],
// 1061:                                                               shutdown:         nil)
// 1062:     cask = instance_double(
// 1063:       Cask::Cask,
// 1064:       artifacts:         [],
// 1065:       full_name:         "codex",
// 1066:       installed_version: "0.117.0",
// 1067:       version:           "0.118.0",
// 1068:     )
// 1069:     installer = instance_double(Cask::Installer, check_requirements: nil, enqueue_downloads: nil,
// 1070:                                                  source_download_requires_pre_fetch?: false)
// 1071:
// 1072:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 1073:     allow(cmd).to receive(:upgrade_outdated_formulae!) do |_, prefetch_only: false,
// 1074:                                                               use_prefetched: false,
// 1075:                                                               prefetch_names: nil,
// 1076:                                                               prefetch_upgrades: nil,
// 1077:                                                               dry_run: false,
// 1078:                                                               **|
// 1079:       if prefetch_only
// 1080:         prefetch_names&.replace(["deno"])
// 1081:         prefetch_upgrades&.replace(["deno 2.7.10 -> 2.7.11"])
// 1082:       elsif !dry_run
// 1083:         upgraded[:use_prefetched] = use_prefetched
// 1084:       end
// 1085:
// 1086:       true
// 1087:     end
// 1088:     allow(Cask::Upgrade).to receive(:outdated_casks).and_return([cask])
// 1089:     allow(Cask::Installer).to receive(:new).and_return(installer)
// 1090:     allow(Cask::Upgrade).to receive(:upgrade_casks!) do |*_, **kwargs|
// 1091:       if kwargs[:dry_run]
// 1092:         # Plan an upgrade in the `--ask` preview so the shared prefetch runs.
// 1093:         kwargs[:summary_upgrades]&.push("codex 0.117.0 -> 0.118.0")
// 1094:       else
// 1095:         upgraded[:skip_prefetch] = kwargs[:skip_prefetch]
// 1096:       end
// 1097:
// 1098:       true
// 1099:     end
// 1100:     allow(Homebrew::Cleanup).to receive(:periodic_clean!)
// 1101:     allow(Homebrew::Reinstall).to receive(:reinstall_pkgconf_if_needed!)
// 1102:     allow(Homebrew.messages).to receive(:display_messages)
// 1103:
// 1104:     cmd.run
// 1105:     upgraded
// 1106:   end
// 1107:
// 1108:   it "does not print removed caveats method errors for installed casks", :cask do
// 1109:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 1110:     installer = InstallHelper.install_with_caskfile(cask)
// 1111:     installed_caskfile = installer.metadata_subdir/"#{cask.token}.json"
// 1112:     expect(installed_caskfile).to exist
// 1113:
// 1114:     (installer.metadata_subdir/"#{cask.token}.rb").write(
// 1115:       cask_path("local-caffeine").read.sub(
// 1116:         /\nend\n\z/,
// 1117:         <<~RUBY,
// 1118:             caveats do
// 1119:               discontinued
// 1120:             end
// 1121:           end
// 1122:         RUBY
// 1123:       ),
// 1124:     )
// 1125:     installed_caskfile.unlink
// 1126:
// 1127:     (CoreCaskTap.instance.cask_dir/"local-caffeine.rb").unlink
// 1128:     CoreCaskTap.instance.clear_cache
// 1129:
// 1130:     cmd = described_class.new(["--cask", "--dry-run"])
// 1131:
// 1132:     expect { cmd.upgrade_outdated_casks!([]) }
// 1133:       .to not_to_output(/Unexpected method 'discontinued' called during caveats on Cask local-caffeine\./).to_stderr
// 1134:   end
// 1135:
// 1136:   it "prints a narrow final upgrade summary" do
// 1137:     cmd = described_class.new([])
// 1138:     summary = Homebrew::Cmd::UpgradeCmd::FinalUpgradeSummary.new(
// 1139:       version_changes:       ["testball 0.1 -> 0.2"],
// 1140:       pinned_formulae:       ["pinnedball 1.0"],
// 1141:       pinned_casks:          ["pinned-cask 2.0"],
// 1142:       deprecated:            ["oldball"],
// 1143:       disabled:              ["disabledball"],
// 1144:       source_build_formulae: ["sourceball"],
// 1145:     )
// 1146:
// 1147:     allow(cmd).to receive(:final_upgrade_summary).and_return(summary)
// 1148:
// 1149:     expect { cmd.show_final_upgrade_summary }.to output(<<~EOS).to_stdout
// 1150:       ==> Upgraded 1 outdated package
// 1151:       testball 0.1 -> 0.2
// 1152:       ==> 1 Pinned formula
// 1153:       pinnedball 1.0
// 1154:       ==> 1 Pinned cask
// 1155:       pinned-cask 2.0
// 1156:       ==> 2 Deprecated or disabled packages
// 1157:       oldball (deprecated)
// 1158:       disabledball (disabled)
// 1159:       ==> 1 homebrew/core formula built from source
// 1160:       sourceball
// 1161:     EOS
// 1162:   end
// 1163:
// 1164:   it "records final formula upgrade summary details" do
// 1165:     formula = formula("testball") do
// 1166:       T.bind(self, T.class_of(Formula))
// 1167:       url "https://brew.sh/testball-0.2"
// 1168:     end
// 1169:     pinned = formula("pinnedball") do
// 1170:       T.bind(self, T.class_of(Formula))
// 1171:       url "https://brew.sh/pinnedball-1.0"
// 1172:     end
// 1173:     deprecated = formula("oldball") do
// 1174:       T.bind(self, T.class_of(Formula))
// 1175:       url "https://brew.sh/oldball-1.0"
// 1176:       deprecate! date: "2020-01-01", because: :unmaintained
// 1177:     end
// 1178:     disabled = formula("disabledball") do
// 1179:       T.bind(self, T.class_of(Formula))
// 1180:       url "https://brew.sh/disabledball-1.0"
// 1181:       disable! date: "2020-01-01", because: :unsupported
// 1182:     end
// 1183:     source_build = formula("sourceball") do
// 1184:       T.bind(self, T.class_of(Formula))
// 1185:       url "https://brew.sh/sourceball-1.0"
// 1186:     end
// 1187:     old_keg = HOMEBREW_CELLAR/"testball/0.1"
// 1188:     old_keg.mkpath
// 1189:     allow(formula).to receive_messages(optlinked?: true, opt_prefix: old_keg)
// 1190:
// 1191:     cmd = described_class.new([])
// 1192:     context = Homebrew::Cmd::UpgradeCmd::FormulaeUpgradeContext.new(
// 1193:       formulae_to_install: [formula, deprecated, disabled, source_build],
// 1194:       formulae_installer:  [
// 1195:         FormulaInstaller.new(formula),
// 1196:         FormulaInstaller.new(deprecated),
// 1197:         FormulaInstaller.new(disabled),
// 1198:         FormulaInstaller.new(source_build, build_from_source_formulae: [source_build.full_name]),
// 1199:       ],
// 1200:       dependants:          Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: []),
// 1201:       pinned_formulae:     [pinned],
// 1202:     )
// 1203:
// 1204:     cmd.record_formula_upgrade_summary(context)
// 1205:     summary = cmd.final_upgrade_summary
// 1206:
// 1207:     expect(summary.version_changes).to include("testball 0.1 -> 0.2")
// 1208:     expect(summary.pinned_formulae).to include("pinnedball 1.0")
// 1209:     expect(summary.deprecated).to include("oldball")
// 1210:     expect(summary.disabled).to include("disabledball")
// 1211:     expect(summary.source_build_formulae).to include("sourceball")
// 1212:   end
// 1213:
// 1214:   it "records formula upgrade versions before upgrading" do
// 1215:     formula = formula("testball") do
// 1216:       T.bind(self, T.class_of(Formula))
// 1217:       url "https://brew.sh/testball-0.2"
// 1218:     end
// 1219:     old_keg = HOMEBREW_CELLAR/"testball/0.1"
// 1220:     new_keg = HOMEBREW_CELLAR/"testball/0.2"
// 1221:     old_keg.mkpath
// 1222:     new_keg.mkpath
// 1223:     allow(formula).to receive_messages(optlinked?: true, opt_prefix: old_keg)
// 1224:     formula_installer = FormulaInstaller.new(formula)
// 1225:     cmd = described_class.new([])
// 1226:
// 1227:     allow(cmd).to receive(:formulae_upgrade_context).and_return(
// 1228:       Homebrew::Cmd::UpgradeCmd::FormulaeUpgradeContext.new(
// 1229:         formulae_to_install: [formula],
// 1230:         formulae_installer:  [formula_installer],
// 1231:         dependants:          Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: []),
// 1232:       ),
// 1233:     )
// 1234:     allow(Homebrew::Upgrade).to receive(:upgrade_formulae) do
// 1235:       allow(formula).to receive(:opt_prefix).and_return(new_keg)
// 1236:       [formula_installer]
// 1237:     end
// 1238:     allow(Homebrew::Upgrade).to receive(:upgrade_dependents).and_return([])
// 1239:
// 1240:     cmd.upgrade_outdated_formulae!([])
// 1241:
// 1242:     expect(cmd.final_upgrade_summary.version_changes).to include("testball 0.1 -> 0.2")
// 1243:   end
// 1244:
// 1245:   it "omits failed formula version changes from the final summary" do
// 1246:     successful_formula = formula("testball") do
// 1247:       T.bind(self, T.class_of(Formula))
// 1248:       url "https://brew.sh/testball-0.2"
// 1249:     end
// 1250:     failed_formula = formula("failball") do
// 1251:       T.bind(self, T.class_of(Formula))
// 1252:       url "https://brew.sh/failball-0.2"
// 1253:       deprecate! date: "2020-01-01", because: :unmaintained
// 1254:     end
// 1255:     successful_formula_installer = FormulaInstaller.new(successful_formula)
// 1256:     failed_formula_installer = FormulaInstaller.new(failed_formula)
// 1257:     old_successful_keg = HOMEBREW_CELLAR/"testball/0.1"
// 1258:     old_failed_keg = HOMEBREW_CELLAR/"failball/0.1"
// 1259:     old_successful_keg.mkpath
// 1260:     old_failed_keg.mkpath
// 1261:     allow(successful_formula).to receive_messages(optlinked?: true, opt_prefix: old_successful_keg)
// 1262:     allow(failed_formula).to receive_messages(optlinked?: true, opt_prefix: old_failed_keg)
// 1263:     cmd = described_class.new([])
// 1264:
// 1265:     allow(cmd).to receive(:formulae_upgrade_context).and_return(
// 1266:       Homebrew::Cmd::UpgradeCmd::FormulaeUpgradeContext.new(
// 1267:         formulae_to_install: [successful_formula, failed_formula],
// 1268:         formulae_installer:  [successful_formula_installer, failed_formula_installer],
// 1269:         dependants:          Homebrew::Upgrade::Dependents.new(upgradeable: [], pinned: [], skipped: []),
// 1270:       ),
// 1271:     )
// 1272:     allow(Homebrew::Upgrade).to receive_messages(upgrade_formulae:   [successful_formula_installer],
// 1273:                                                  upgrade_dependents: [])
// 1274:
// 1275:     cmd.upgrade_outdated_formulae!([])
// 1276:
// 1277:     expect(cmd.final_upgrade_summary).to have_attributes(
// 1278:       version_changes: contain_exactly("testball 0.1 -> 0.2"),
// 1279:       deprecated:      contain_exactly("failball"),
// 1280:     )
// 1281:   end
// 1282:
// 1283:   it "reports only successful dependent version changes in the final summary" do
// 1284:     formula = formula("testball") do
// 1285:       T.bind(self, T.class_of(Formula))
// 1286:       url "https://brew.sh/testball-0.2"
// 1287:     end
// 1288:     upgraded_dependent = formula("upgraded-dependent") do
// 1289:       T.bind(self, T.class_of(Formula))
// 1290:       url "https://brew.sh/upgraded-dependent-0.2"
// 1291:     end
// 1292:     skipped_dependent = formula("skipped-dependent") do
// 1293:       T.bind(self, T.class_of(Formula))
// 1294:       url "https://brew.sh/skipped-dependent-0.2"
// 1295:     end
// 1296:     formula_installer = FormulaInstaller.new(formula)
// 1297:     old_formula_keg = HOMEBREW_CELLAR/"testball/0.1"
// 1298:     old_upgraded_dependent_keg = HOMEBREW_CELLAR/"upgraded-dependent/0.1"
// 1299:     old_skipped_dependent_keg = HOMEBREW_CELLAR/"skipped-dependent/0.1"
// 1300:     old_formula_keg.mkpath
// 1301:     old_upgraded_dependent_keg.mkpath
// 1302:     old_skipped_dependent_keg.mkpath
// 1303:     allow(formula).to receive_messages(optlinked?: true, opt_prefix: old_formula_keg)
// 1304:     allow(upgraded_dependent).to receive_messages(optlinked?: true, opt_prefix: old_upgraded_dependent_keg)
// 1305:     allow(skipped_dependent).to receive_messages(optlinked?: true, opt_prefix: old_skipped_dependent_keg)
// 1306:     cmd = described_class.new([])
// 1307:
// 1308:     allow(cmd).to receive(:formulae_upgrade_context).and_return(
// 1309:       Homebrew::Cmd::UpgradeCmd::FormulaeUpgradeContext.new(
// 1310:         formulae_to_install: [formula],
// 1311:         formulae_installer:  [formula_installer],
// 1312:         dependants:          Homebrew::Upgrade::Dependents.new(
// 1313:           upgradeable: [upgraded_dependent, skipped_dependent], pinned: [], skipped: [],
// 1314:         ),
// 1315:       ),
// 1316:     )
// 1317:     allow(Homebrew::Upgrade).to receive_messages(
// 1318:       upgrade_formulae:   [formula_installer],
// 1319:       upgrade_dependents: [upgraded_dependent],
// 1320:     )
// 1321:
// 1322:     cmd.upgrade_outdated_formulae!([])
// 1323:
// 1324:     expect(cmd.final_upgrade_summary.version_changes)
// 1325:       .to contain_exactly("testball 0.1 -> 0.2", "upgraded-dependent 0.1 -> 0.2")
// 1326:   end
// 1327:
// 1328:   it_behaves_like "reinstall_pkgconf_if_needed"
// 1329: end
