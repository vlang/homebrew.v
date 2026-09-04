module bundle

import ruby
import homebrew.bundle as brew_bundle

// Translated from Homebrew/brew `test/bundle/brew_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn brew_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn brew_spec_foo() brew_bundle.BundleBrewFormula {
	return brew_bundle.BundleBrewFormula{
		name: 'foo'
		desc: 'foobar'
		oldnames: ['oldfoo']
		full_name: 'qux/quuz/foo'
		any_version_installed: true
		aliases: ['foobar']
		installed_on_request: true
		linked: false
		keg_only: true
	}
}

fn brew_spec_bar() brew_bundle.BundleBrewFormula {
	bottle := ruby.map_value({
		'cellar': ruby.string_value(':any')
		'files':  ruby.map_value({
			'big_sur': ruby.map_value({
				'sha256': ruby.string_value('abcdef')
				'url':    ruby.string_value('https://brew.sh//foo-1.0.big_sur.bottle.tar.gz')
			})
		})
	})
	return brew_bundle.BundleBrewFormula{
		name: 'bar'
		desc: 'barfoo'
		full_name: 'bar'
		any_version_installed: true
		version: '1.0'
		installed_on_request: false
		pinned: true
		outdated: true
		poured_from_bottle: true
		bottle: bottle
		bottled: true
		official_tap: true
		linked: true
	}
}

fn brew_spec_baz() brew_bundle.BundleBrewFormula {
	return brew_bundle.BundleBrewFormula{
		name: 'baz'
		full_name: 'bazzles/bizzles/baz'
		any_version_installed: true
		installed_on_request: true
		dependencies: ['bar']
		build_dependencies: ['bar']
		link_set: true
		link: false
	}
}

fn brew_spec_state() brew_bundle.BundleBrewState {
	return brew_bundle.BundleBrewState{
		formulae: [brew_spec_foo(), brew_spec_bar(), brew_spec_baz()]
		installed_formulae: ['foo', 'bar', 'baz']
		trusted_formulae: ['bazzles/bizzles/baz']
	}
}

fn brew_spec_installer(options brew_bundle.BundleBrewOptions) brew_bundle.BundleBrewInstaller {
	mut installer := brew_bundle.bundle_brew_installer('mysql', options)
	installer.installed = true
	installer.linked = true
	installer.formula_version = '1.0'
	return installer
}

fn brew_spec_effects(command string, result bool) brew_bundle.BundleBrewEffects {
	return brew_bundle.BundleBrewEffects{
		command_results: {
			command: result
		}
	}
}

fn brew_spec_string_map_equals(value ruby.Value, expected map[string]string) bool {
	if value.type_name != 'Hash' || value.map_data.len != expected.len {
		return false
	}
	for key, item in expected {
		if key !in value.map_data || value.map_data[key].as_string() != item {
			return false
		}
	}
	return true
}

// Ruby subject `subject(:dumper) { described_class }` at line 15.
pub fn ruby_brew_spec_l15_d1_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::Brew', 'Homebrew::Bundle::Brew')
}

// Ruby let `let(:foo) do` at line 17.
pub fn ruby_brew_spec_l17_d2_foo(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_foo())
}

// Ruby let `let(:foo_hash) do` at line 36.
pub fn ruby_brew_spec_l36_d3_foo_hash(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_foo())
}

// Ruby let `let(:bar) do` at line 59.
pub fn ruby_brew_spec_l59_d4_bar(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_bar())
}

// Ruby let `let(:bar_hash) do` at line 89.
pub fn ruby_brew_spec_l89_d5_bar_hash(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_bar())
}

// Ruby let `let(:baz) do` at line 120.
pub fn ruby_brew_spec_l120_d6_baz(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_baz())
}

// Ruby let `let(:baz_hash) do` at line 139.
pub fn ruby_brew_spec_l139_d7_baz_hash(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_formula_value(brew_spec_baz())
}

// Ruby method `formula_double_depending_on(name, dependency)` at line 163.
pub fn ruby_brew_spec_l163_d8_formula_double_depending_on(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	dependency := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_bundle.bundle_brew_formula_value(brew_bundle.BundleBrewFormula{
		name: name
		desc: name
		full_name: name
		any_version_installed: true
		dependencies: [
			dependency,
		]
		installed_on_request: true
		keg_only: true
	})
}

// Ruby it `it "returns an empty array when no formulae are installed" do` at line 188.
pub fn ruby_brew_spec_l188_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	formulae, _ := brew_bundle.bundle_brew_sorted_formulae(brew_bundle.BundleBrewState{})
	return brew_spec_bool(formulae.len == 0)
}

// Ruby it `it "returns an empty hash when no formulae are installed" do` at line 194.
pub fn ruby_brew_spec_l194_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_state_value(brew_bundle.BundleBrewState{}).array_data.len == 0)
}

// Ruby it `it "returns an empty hash for an unavailable formula" do` at line 198.
pub fn ruby_brew_spec_l198_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{ unavailable: ['bar'] }
	return brew_spec_bool(brew_bundle.bundle_brew_find_formula(state, 'bar') == none)
}

// Ruby it `it "warns and continues on cyclic dependencies instead of exiting" do` at line 203.
pub fn ruby_brew_spec_l203_d12_warns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{
		formulae: [
			brew_bundle.BundleBrewFormula{
				name: 'foo'
				desc: 'foo'
				full_name: 'foo'
				any_version_installed: true
				dependencies: [
					'bar',
				]
			},
			brew_bundle.BundleBrewFormula{
				name: 'bar'
				desc: 'bar'
				full_name: 'bar'
				any_version_installed: true
				dependencies: [
					'foo',
				]
			},
		]
	}
	formulae, cycles := brew_bundle.bundle_brew_sorted_formulae(state)
	return brew_spec_bool(formulae.len == 2 && cycles.len == 1 && cycles[0] == ['bar', 'foo'])
}

// Ruby it `it "returns a hash for a formula" do` at line 212.
pub fn ruby_brew_spec_l212_d13_returns(args ...ruby.Value) ruby.Value {
	_ = args
	formula := brew_bundle.bundle_brew_find_formula(brew_bundle.BundleBrewState{
		formulae: [
			brew_spec_foo(),
		]
	}, 'qux/quuz/foo') or { return brew_spec_bool(false) }
	return brew_spec_bool(formula == brew_spec_foo())
}

// Ruby it `it "returns an array for all formulae" do` at line 217.
pub fn ruby_brew_spec_l217_d14_returns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_spec_state()
	return brew_spec_bool(state.formulae.len == 3 && brew_bundle.bundle_brew_find_formula(state, 'bar') or { return brew_spec_bool(false) } == brew_spec_bar())
}

// Ruby it `it "returns a hash for a formula" do` at line 236.
pub fn ruby_brew_spec_l236_d15_returns(args ...ruby.Value) ruby.Value {
	_ = args
	formula := brew_bundle.bundle_brew_find_formula(brew_bundle.BundleBrewState{
		formulae: [
			brew_spec_foo(),
		]
	}, 'foo') or { return brew_spec_bool(false) }
	return brew_spec_bool(formula == brew_spec_foo())
}

// Ruby it `it "returns a dump string with installed formulae" do` at line 243.
pub fn ruby_brew_spec_l243_d16_returns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{
		formulae: [brew_spec_foo(),
			brew_bundle.BundleBrewFormula{ ...brew_spec_bar(), installed_on_request: true },
			brew_spec_baz()]
		trusted_formulae: [
			'bazzles/bizzles/baz',
		]
	}
	expected := '# barfoo\nbrew "bar"\nbrew "bazzles/bizzles/baz", link: false, trusted: true\n# foobar\nbrew "qux/quuz/foo"'
	return brew_spec_bool(brew_bundle.bundle_brew_dump(state, true, false) == expected)
}

// Ruby it `it "returns an empty string when no formulae are installed" do` at line 268.
pub fn ruby_brew_spec_l268_d17_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_formula_aliases(brew_bundle.BundleBrewState{}).len == 0)
}

// Ruby it `it "returns a hash with installed formulae aliases" do` at line 272.
pub fn ruby_brew_spec_l272_d18_returns(args ...ruby.Value) ruby.Value {
	_ = args
	aliases := brew_bundle.bundle_brew_formula_aliases(brew_spec_state())
	return brew_spec_bool(aliases == {
		'qux/quuz/foobar': 'qux/quuz/foo'
		'foobar':          'qux/quuz/foo'
	})
}

// Ruby it `it "returns an empty string when no formulae are installed" do` at line 282.
pub fn ruby_brew_spec_l282_d19_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_formula_oldnames(brew_bundle.BundleBrewState{}).len == 0)
}

// Ruby it `it "returns a hash with installed formulae old names" do` at line 286.
pub fn ruby_brew_spec_l286_d20_returns(args ...ruby.Value) ruby.Value {
	_ = args
	oldnames := brew_bundle.bundle_brew_formula_oldnames(brew_spec_state())
	return brew_spec_bool(oldnames == {
		'qux/quuz/oldfoo': 'qux/quuz/foo'
		'oldfoo':          'qux/quuz/foo'
	})
}

// Ruby let `let(:formula_name) { "mysql" }` at line 297.
pub fn ruby_brew_spec_l297_d21_formula_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('mysql')
}

// Ruby let `let(:options) { { args: ["with-option"] } }` at line 298.
pub fn ruby_brew_spec_l298_d22_options(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_options_value(brew_bundle.BundleBrewOptions{
		args: [
			'with-option',
		]
	})
}

// Ruby let `let(:installer) { described_class.new(formula_name, options) }` at line 299.
pub fn ruby_brew_spec_l299_d23_installer(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_bundle.bundle_brew_installer_value(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{
		args: [
			'with-option',
		]
	}))
}

// Ruby it `it "start service" do` at line 333.
pub fn ruby_brew_spec_l333_d24_start(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ start_service: 'true' })
	installer.service_started = true
	return brew_spec_bool(brew_bundle.bundle_brew_service_change(installer, brew_bundle.BundleBrewEffects{}, false).events.len == 0)
}

// Ruby it `it "start service" do` at line 341.
pub fn ruby_brew_spec_l341_d25_start(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ start_service: 'true' })
	installer.service_started = true
	return brew_spec_bool(brew_bundle.bundle_brew_install_instance(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false, false, false).events.len == 0)
}

// Ruby it `it "start service" do` at line 354.
pub fn ruby_brew_spec_l354_d26_start(args ...ruby.Value) ruby.Value {
	_ = args
	installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ start_service: 'true' })
	result := brew_bundle.bundle_brew_service_change(installer, brew_bundle.BundleBrewEffects{}, false)
	return brew_spec_bool(result.success && result.events == ['service:start:mysql:'])
}

// Ruby it `it "start service" do` at line 363.
pub fn ruby_brew_spec_l363_d27_start(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ start_service: 'true' })
	result := brew_bundle.bundle_brew_install_instance(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false, false, false)
	return brew_spec_bool(result.success && 'service:start:mysql:' in result.events)
}

// Ruby it `it "restart service" do` at line 380.
pub fn ruby_brew_spec_l380_d28_restart(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ restart_service: 'always' })
	installer.changed = true
	return brew_spec_bool(brew_bundle.bundle_brew_service_change(installer, brew_bundle.BundleBrewEffects{}, false).events == [
		'service:restart:mysql:',
	])
}

// Ruby it `it "restart service" do` at line 389.
pub fn ruby_brew_spec_l389_d29_restart(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ restart_service: 'always' })
	result := brew_bundle.bundle_brew_install_instance(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false, false, false)
	return brew_spec_bool('service:restart:mysql:' in result.events)
}

// Ruby it `it "links formula" do` at line 402.
pub fn ruby_brew_spec_l402_d30_links(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ link_mode: 'true' })
	installer.linked = false
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['link', 'mysql'],
	])
}

// Ruby it `it "force-links keg-only formula" do` at line 410.
pub fn ruby_brew_spec_l410_d31_force_links(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ link_mode: 'true' })
	installer.linked = false
	installer.keg_only = true
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['link', '--force', 'mysql'],
	])
}

// Ruby it `it "overwrite links formula" do` at line 425.
pub fn ruby_brew_spec_l425_d32_overwrite(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ link_mode: 'overwrite' })
	installer.linked = false
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['link', '--overwrite', 'mysql'],
	])
}

// Ruby it `it "unlinks formula" do` at line 439.
pub fn ruby_brew_spec_l439_d33_unlinks(args ...ruby.Value) ruby.Value {
	_ = args
	installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ link_mode: 'false' })
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['unlink', 'mysql'],
	])
}

// Ruby it `it "links formula" do` at line 455.
pub fn ruby_brew_spec_l455_d34_links(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	installer.linked = false
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['link', 'mysql'],
	])
}

// Ruby it `it "unlinks formula" do` at line 470.
pub fn ruby_brew_spec_l470_d35_unlinks(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	installer.keg_only = true
	return brew_spec_bool(brew_bundle.bundle_brew_link_change(installer, brew_bundle.BundleBrewEffects{}, false).commands == [
		['unlink', 'mysql'],
	])
}

// Ruby it `it "unlinks conflicts and stops their services" do` at line 491.
pub fn ruby_brew_spec_l491_d36_unlinks(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{
		restart_service: 'always'
		conflicts_with: [
			'mysql56',
		]
	})
	installer.formula_conflicts = ['mysql55']
	state := brew_bundle.BundleBrewState{ installed_formulae: ['mysql55', 'mysql56'] }
	result := brew_bundle.bundle_brew_resolve_conflicts(installer, state, brew_bundle.BundleBrewEffects{}, false)
	return brew_spec_bool(result.success && result.commands == [['unlink', 'mysql56'],
		['unlink', 'mysql55']] && result.events.len == 2)
}

// Ruby it `it "prints a message" do` at line 506.
pub fn ruby_brew_spec_l506_d37_prints(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{
		restart_service: 'always'
		conflicts_with: [
			'mysql56',
		]
	})
	installer.formula_conflicts = ['mysql55']
	result := brew_bundle.bundle_brew_resolve_conflicts(installer, brew_bundle.BundleBrewState{
		installed_formulae: [
			'mysql55',
			'mysql56',
		]
	}, brew_bundle.BundleBrewEffects{}, true)
	return brew_spec_bool(result.output.len == 4 && result.output[0].contains('conflicts with mysql'))
}

// Ruby it `it "runs the postinstall command" do` at line 537.
pub fn ruby_brew_spec_l537_d38_runs(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ postinstall: 'custom command' })
	installer.changed = true
	result := brew_bundle.bundle_brew_postinstall_change(installer, brew_bundle.BundleBrewEffects{}, false)
	return brew_spec_bool(result.success && result.events == [
		'postinstall:custom command',
	])
}

// Ruby it `it "reports a failure" do` at line 543.
pub fn ruby_brew_spec_l543_d39_reports(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ postinstall: 'custom command' })
	installer.changed = true
	return brew_spec_bool(!brew_bundle.bundle_brew_postinstall_change(installer, brew_bundle.BundleBrewEffects{ postinstall_ok: false }, false).success)
}

// Ruby it `it "does not run the postinstall command" do` at line 555.
pub fn ruby_brew_spec_l555_d40_does(args ...ruby.Value) ruby.Value {
	_ = args
	installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ postinstall: 'custom command' })
	return brew_spec_bool(brew_bundle.bundle_brew_postinstall_change(installer, brew_bundle.BundleBrewEffects{}, false).events.len == 0)
}

// Ruby let `let(:version_file) { "version.txt" }` at line 572.
pub fn ruby_brew_spec_l572_d41_version_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('version.txt')
}

// Ruby let `let(:version) { "1.0" }` at line 573.
pub fn ruby_brew_spec_l573_d42_version(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('1.0')
}

// Ruby it `it "writes the version to the file" do` at line 581.
pub fn ruby_brew_spec_l581_d43_writes(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ version_file: 'version.txt' })
	installer.env_version = '1.0'
	result := brew_bundle.bundle_brew_install_instance(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false, false, false)
	return brew_spec_bool(result.writes['version.txt'] or { '' } == '1.0\n')
}

// Ruby it `it "writes the version to the file" do` at line 589.
pub fn ruby_brew_spec_l589_d44_writes(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{ version_file: 'version.txt' })
	installer.changed = true
	result := brew_bundle.bundle_brew_install_instance(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false, false, false)
	return brew_spec_bool(result.writes['version.txt'] or { '' } == '1.0\n')
}

// Ruby it `it "did not call restart service" do` at line 604.
pub fn ruby_brew_spec_l604_d45_did(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: 'true' })
	preinstall := brew_bundle.bundle_brew_preinstall_instance(mut installer, brew_bundle.BundleBrewState{}, false)
	return brew_spec_bool(preinstall && !installer.installed && !installer.changed)
}

// Ruby let `let(:tapped_name) { "foo/bar/baz" }` at line 611.
pub fn ruby_brew_spec_l611_d46_tapped_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('foo/bar/baz')
}

// Ruby it `it "trusts the formula before installing the tap that loads it" do` at line 618.
pub fn ruby_brew_spec_l618_d47_trusts(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_bundle.bundle_brew_installer('foo/bar/baz', brew_bundle.BundleBrewOptions{ trusted: true })
	result := brew_bundle.bundle_brew_install_change(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false)
	return brew_spec_bool(result.events.len >= 2 && result.events[0] == 'trust:foo/bar/baz' && result.events[1] == 'tap:ensure:foo/bar')
}

// Ruby it `it "does not trust an unqualified formula name" do` at line 628.
pub fn ruby_brew_spec_l628_d48_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_bundle.bundle_brew_installer('baz', brew_bundle.BundleBrewOptions{ trusted: true })
	result := brew_bundle.bundle_brew_install_change(mut installer, brew_bundle.BundleBrewState{}, brew_bundle.BundleBrewEffects{}, false, false)
	return brew_spec_bool(!result.events.any(it.starts_with('trust:')))
}

// Ruby it `it "calls Homebrew" do` at line 636.
pub fn ruby_brew_spec_l636_d49_calls(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{
		formulae: [brew_bundle.BundleBrewFormula{ name: 'a', outdated: true },
			brew_bundle.BundleBrewFormula{ name: 'b', outdated: true },
			brew_bundle.BundleBrewFormula{ name: 'c' }]
	}
	return brew_spec_bool(brew_bundle.bundle_brew_outdated_formulae(state) == ['a', 'b'])
}

// Ruby it `it "calls Homebrew" do` at line 650.
pub fn ruby_brew_spec_l650_d50_calls(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{
		formulae: [brew_bundle.BundleBrewFormula{ name: 'a', pinned: true },
			brew_bundle.BundleBrewFormula{ name: 'b', pinned: true },
			brew_bundle.BundleBrewFormula{ name: 'c' }]
	}
	return brew_spec_bool(brew_bundle.bundle_brew_pinned_formulae(state) == ['a', 'b'])
}

// Ruby it `it "returns result" do` at line 698.
pub fn ruby_brew_spec_l698_d51_returns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{
		formulae: [
			brew_bundle.BundleBrewFormula{
				name: 'foo'
				full_name: 'homebrew/tap/foo'
				aliases: [
					'foobar',
				]
			},
			brew_bundle.BundleBrewFormula{ name: 'bar', full_name: 'bar', outdated: true },
		]
		installed_formulae: ['foo', 'bar']
	}
	return brew_spec_bool(brew_bundle.bundle_brew_installed_and_up_to_date(state, 'foo', false) && brew_bundle.bundle_brew_installed_and_up_to_date(state, 'foobar', false) && !brew_bundle.bundle_brew_installed_and_up_to_date(state, 'bar', false) && !brew_bundle.bundle_brew_installed_and_up_to_date(state, 'baz', false))
}

// Ruby it `it "warns and marks the formula actionable without loading it" do` at line 714.
pub fn ruby_brew_spec_l714_d52_warns(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{ installed_formulae: ['php@7.2'], require_tap_trust: true }
	check := brew_bundle.bundle_brew_formula_upgradable_check(state, 'shivammathur/php/php@7.2')
	return brew_spec_bool(check.upgradable && !check.loaded && check.warning.contains('not trusted') && !brew_bundle.bundle_brew_installed_and_up_to_date(state, 'shivammathur/php/php@7.2', false))
}

// Ruby it `it "does not warn when upgrades are disabled" do` at line 721.
pub fn ruby_brew_spec_l721_d53_does(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{ installed_formulae: ['php@7.2'], require_tap_trust: true }
	return brew_spec_bool(brew_bundle.bundle_brew_installed_and_up_to_date(state, 'shivammathur/php/php@7.2', true))
}

// Ruby it `it "detects missing formulae without loading the formula" do` at line 731.
pub fn ruby_brew_spec_l731_d54_detects(args ...ruby.Value) ruby.Value {
	_ = args
	state := brew_bundle.BundleBrewState{ require_tap_trust: true }
	check := brew_bundle.bundle_brew_formula_upgradable_check(state, 'shivammathur/php/php@7.2')
	return brew_spec_bool(!check.upgradable && check.warning == '' && !check.loaded)
}

// Ruby it `it "install formula" do` at line 749.
pub fn ruby_brew_spec_l749_d55_install(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{
		args: [
			'with-option',
		]
	})
	result := brew_bundle.bundle_brew_install_formula(mut installer, brew_spec_effects('install --formula mysql --with-option', true), false, false)
	return brew_spec_bool(result.success && result.commands == [
		['install', '--formula', 'mysql', '--with-option'],
	])
}

// Ruby it `it "reports a failure" do` at line 757.
pub fn ruby_brew_spec_l757_d56_reports(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{
		args: [
			'with-option',
		]
	})
	return brew_spec_bool(!brew_bundle.bundle_brew_install_formula(mut installer, brew_spec_effects('install --formula mysql --with-option', false), false, false).success)
}

// Ruby it `it "upgrade formula" do` at line 779.
pub fn ruby_brew_spec_l779_d57_upgrade(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	return brew_spec_bool(brew_bundle.bundle_brew_upgrade_formula(mut installer, brew_spec_effects('upgrade --formula mysql', true), false, false).success)
}

// Ruby it `it "reports a failure" do` at line 787.
pub fn ruby_brew_spec_l787_d58_reports(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	return brew_spec_bool(!brew_bundle.bundle_brew_upgrade_formula(mut installer, brew_spec_effects('upgrade --formula mysql', false), false, false).success)
}

// Ruby it `it "does not upgrade formula" do` at line 800.
pub fn ruby_brew_spec_l800_d59_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	state := brew_bundle.BundleBrewState{
		formulae: [
			brew_bundle.BundleBrewFormula{ name: 'mysql', full_name: 'mysql', outdated: true, pinned: true },
		]
		installed_formulae: ['mysql']
	}
	return brew_spec_bool(!brew_bundle.bundle_brew_preinstall_instance(mut installer, state, false))
}

// Ruby it `it "does not upgrade formula" do` at line 812.
pub fn ruby_brew_spec_l812_d60_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut installer := brew_spec_installer(brew_bundle.BundleBrewOptions{})
	state := brew_bundle.BundleBrewState{
		formulae: [
			brew_bundle.BundleBrewFormula{ name: 'mysql', full_name: 'mysql' },
		]
		installed_formulae: ['mysql']
	}
	return brew_spec_bool(!brew_bundle.bundle_brew_preinstall_instance(mut installer, state, false))
}

// Ruby it `it "is false by default" do` at line 822.
pub fn ruby_brew_spec_l822_d61_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(!brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{}).changed)
}

// Ruby it `it "is false by default" do` at line 828.
pub fn ruby_brew_spec_l828_d62_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(!brew_bundle.bundle_brew_start_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{})))
}

// Ruby it `it "is true" do` at line 833.
pub fn ruby_brew_spec_l833_d63_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_start_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ start_service: 'true' })))
}

// Ruby specify `specify do` at line 845.
pub fn ruby_brew_spec_l845_d64_do(args ...ruby.Value) ruby.Value {
	_ = args
	mut values := []bool{}
	for options in [brew_bundle.BundleBrewOptions{},
		brew_bundle.BundleBrewOptions{ start_service: 'true' },
		brew_bundle.BundleBrewOptions{ restart_service: 'true' },
		brew_bundle.BundleBrewOptions{ restart_service: 'changed' },
		brew_bundle.BundleBrewOptions{ restart_service: 'always' }] {
		mut installer := brew_bundle.bundle_brew_installer('mysql', options)
		installer.service_started = true
		values << brew_bundle.bundle_brew_start_service_needed(installer)
	}
	return brew_spec_bool(values == [false, false, false, false, false])
}

// Ruby specify `specify do` at line 861.
pub fn ruby_brew_spec_l861_d65_do(args ...ruby.Value) ruby.Value {
	_ = args
	mut values := []bool{}
	for options in [brew_bundle.BundleBrewOptions{},
		brew_bundle.BundleBrewOptions{ start_service: 'true' },
		brew_bundle.BundleBrewOptions{ restart_service: 'true' },
		brew_bundle.BundleBrewOptions{ restart_service: 'changed' },
		brew_bundle.BundleBrewOptions{ restart_service: 'always' }] {
		values << brew_bundle.bundle_brew_start_service_needed(brew_bundle.bundle_brew_installer('mysql', options))
	}
	return brew_spec_bool(values == [false, true, true, true, true])
}

// Ruby it `it "is false by default" do` at line 873.
pub fn ruby_brew_spec_l873_d66_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(!brew_bundle.bundle_brew_restart_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{})))
}

// Ruby it `it "is true" do` at line 878.
pub fn ruby_brew_spec_l878_d67_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_restart_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: 'true' })))
}

// Ruby it `it "is true" do` at line 884.
pub fn ruby_brew_spec_l884_d68_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_restart_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: 'always' })))
}

// Ruby it `it "is true" do` at line 890.
pub fn ruby_brew_spec_l890_d69_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(brew_bundle.bundle_brew_restart_service(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: 'changed' })))
}

// Ruby it `it "is false by default" do` at line 897.
pub fn ruby_brew_spec_l897_d70_is(args ...ruby.Value) ruby.Value {
	_ = args
	return brew_spec_bool(!brew_bundle.bundle_brew_restart_service_needed(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{})))
}

// Ruby specify `specify do` at line 906.
pub fn ruby_brew_spec_l906_d71_do(args ...ruby.Value) ruby.Value {
	_ = args
	mut values := []bool{}
	for mode in ['true', 'always', 'changed'] {
		values << brew_bundle.bundle_brew_restart_service_needed(brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: mode }))
	}
	return brew_spec_bool(values == [false, true, false])
}

// Ruby specify `specify do` at line 920.
pub fn ruby_brew_spec_l920_d72_do(args ...ruby.Value) ruby.Value {
	_ = args
	mut values := []bool{}
	for mode in ['true', 'always', 'changed'] {
		mut installer := brew_bundle.bundle_brew_installer('mysql', brew_bundle.BundleBrewOptions{ restart_service: mode })
		installer.changed = true
		values << brew_bundle.bundle_brew_restart_service_needed(installer)
	}
	return brew_spec_bool(values == [true, true, true])
}

// Ruby it `it "treats an edge to a missing node as a leaf" do` at line 932.
pub fn ruby_brew_spec_l932_d73_treats(args ...ruby.Value) ruby.Value {
	_ = args
	topo := brew_bundle.bundle_brew_toposort({
		'a': ['b']
		'b': ['libice']
	})
	return brew_spec_bool(topo.ordered == ['libice', 'b', 'a'])
}

// Ruby it `it "flattens a cyclic graph via strongly connected components without raising" do` at line 940.
pub fn ruby_brew_spec_l940_d74_flattens(args ...ruby.Value) ruby.Value {
	_ = args
	topo := brew_bundle.bundle_brew_toposort({
		'a': ['b']
		'b': ['a']
	})
	mut ordered := topo.ordered.clone()
	ordered.sort()
	return brew_spec_bool(ordered == ['a', 'b'] && topo.cycles == [['a', 'b']])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/brew"
// 6: require "bundle/brew_services"
// 7: require "tsort"
// 8: require "formula"
// 9: require "tab"
// 10: require "trust"
// 11: require "utils/bottles"
// 12:
// 13: RSpec.describe Homebrew::Bundle::Brew do
// 14:   describe "dumping" do
// 15:     subject(:dumper) { described_class }
// 16:
// 17:     let(:foo) do
// 18:       instance_double(Formula,
// 19:                       name:                   "foo",
// 20:                       desc:                   "foobar",
// 21:                       oldnames:               ["oldfoo"],
// 22:                       full_name:              "qux/quuz/foo",
// 23:                       any_version_installed?: true,
// 24:                       aliases:                ["foobar"],
// 25:                       runtime_dependencies:   [],
// 26:                       deps:                   [],
// 27:                       conflicts:              [],
// 28:                       any_installed_prefix:   nil,
// 29:                       linked?:                false,
// 30:                       keg_only?:              true,
// 31:                       pinned?:                false,
// 32:                       outdated?:              false,
// 33:                       stable:                 instance_double(SoftwareSpec, bottle_defined?: false, bottled?: false),
// 34:                       tap:                    instance_double(Tap, official?: false))
// 35:     end
// 36:     let(:foo_hash) do
// 37:       {
// 38:         aliases:                ["foobar"],
// 39:         any_version_installed?: true,
// 40:         args:                   [],
// 41:         bottle:                 false,
// 42:         bottled:                false,
// 43:         build_dependencies:     [],
// 44:         conflicts_with:         [],
// 45:         dependencies:           [],
// 46:         desc:                   "foobar",
// 47:         full_name:              "qux/quuz/foo",
// 48:         installed_on_request?:  true,
// 49:         link?:                  nil,
// 50:         name:                   "foo",
// 51:         oldnames:               ["oldfoo"],
// 52:         outdated?:              false,
// 53:         pinned?:                false,
// 54:         poured_from_bottle?:    false,
// 55:         version:                nil,
// 56:         official_tap:           false,
// 57:       }
// 58:     end
// 59:     let(:bar) do
// 60:       linked_keg = Pathname("/usr/local").join("var").join("homebrew").join("linked").join("bar")
// 61:       instance_double(Formula,
// 62:                       name:                   "bar",
// 63:                       desc:                   "barfoo",
// 64:                       oldnames:               [],
// 65:                       full_name:              "bar",
// 66:                       any_version_installed?: true,
// 67:                       aliases:                [],
// 68:                       runtime_dependencies:   [],
// 69:                       deps:                   [],
// 70:                       conflicts:              [],
// 71:                       any_installed_prefix:   nil,
// 72:                       linked?:                true,
// 73:                       keg_only?:              false,
// 74:                       pinned?:                true,
// 75:                       outdated?:              true,
// 76:                       linked_keg:,
// 77:                       stable:                 instance_double(SoftwareSpec, bottle_defined?: true, bottled?: true),
// 78:                       tap:                    instance_double(Tap, official?: true),
// 79:                       bottle_hash:            {
// 80:                         cellar: ":any",
// 81:                         files:  {
// 82:                           big_sur: {
// 83:                             sha256: "abcdef",
// 84:                             url:    "https://brew.sh//foo-1.0.big_sur.bottle.tar.gz",
// 85:                           },
// 86:                         },
// 87:                       })
// 88:     end
// 89:     let(:bar_hash) do
// 90:       {
// 91:         aliases:                [],
// 92:         any_version_installed?: true,
// 93:         args:                   [],
// 94:         bottle:                 {
// 95:           cellar: ":any",
// 96:           files:  {
// 97:             big_sur: {
// 98:               sha256: "abcdef",
// 99:               url:    "https://brew.sh//foo-1.0.big_sur.bottle.tar.gz",
// 100:             },
// 101:           },
// 102:         },
// 103:         bottled:                true,
// 104:         build_dependencies:     [],
// 105:         conflicts_with:         [],
// 106:         dependencies:           [],
// 107:         desc:                   "barfoo",
// 108:         full_name:              "bar",
// 109:         installed_on_request?:  false,
// 110:         link?:                  nil,
// 111:         name:                   "bar",
// 112:         oldnames:               [],
// 113:         outdated?:              true,
// 114:         pinned?:                true,
// 115:         poured_from_bottle?:    true,
// 116:         version:                "1.0",
// 117:         official_tap:           true,
// 118:       }
// 119:     end
// 120:     let(:baz) do
// 121:       instance_double(Formula,
// 122:                       name:                   "baz",
// 123:                       desc:                   "",
// 124:                       oldnames:               [],
// 125:                       full_name:              "bazzles/bizzles/baz",
// 126:                       any_version_installed?: true,
// 127:                       aliases:                [],
// 128:                       runtime_dependencies:   [instance_double(Dependency, name: "bar")],
// 129:                       deps:                   [instance_double(Dependency, name: "bar", build?: true)],
// 130:                       conflicts:              [],
// 131:                       any_installed_prefix:   nil,
// 132:                       linked?:                false,
// 133:                       keg_only?:              false,
// 134:                       pinned?:                false,
// 135:                       outdated?:              false,
// 136:                       stable:                 instance_double(SoftwareSpec, bottle_defined?: false, bottled?: false),
// 137:                       tap:                    instance_double(Tap, official?: false))
// 138:     end
// 139:     let(:baz_hash) do
// 140:       {
// 141:         aliases:                [],
// 142:         any_version_installed?: true,
// 143:         args:                   [],
// 144:         bottle:                 false,
// 145:         bottled:                false,
// 146:         build_dependencies:     ["bar"],
// 147:         conflicts_with:         [],
// 148:         dependencies:           ["bar"],
// 149:         desc:                   "",
// 150:         full_name:              "bazzles/bizzles/baz",
// 151:         installed_on_request?:  true,
// 152:         link?:                  false,
// 153:         name:                   "baz",
// 154:         oldnames:               [],
// 155:         outdated?:              false,
// 156:         pinned?:                false,
// 157:         poured_from_bottle?:    false,
// 158:         version:                nil,
// 159:         official_tap:           false,
// 160:       }
// 161:     end
// 162:
// 163:     def formula_double_depending_on(name, dependency)
// 164:       instance_double(Formula,
// 165:                       name:,
// 166:                       desc:                   name,
// 167:                       oldnames:               [],
// 168:                       full_name:              name,
// 169:                       any_version_installed?: true,
// 170:                       aliases:                [],
// 171:                       runtime_dependencies:   [instance_double(Dependency, name: dependency)],
// 172:                       deps:                   [],
// 173:                       conflicts:              [],
// 174:                       any_installed_prefix:   nil,
// 175:                       linked?:                false,
// 176:                       keg_only?:              true,
// 177:                       pinned?:                false,
// 178:                       outdated?:              false,
// 179:                       stable:                 instance_double(SoftwareSpec, bottle_defined?: false, bottled?: false),
// 180:                       tap:                    instance_double(Tap, official?: false))
// 181:     end
// 182:
// 183:     before do
// 184:       described_class.reset!
// 185:     end
// 186:
// 187:     describe "#formulae" do
// 188:       it "returns an empty array when no formulae are installed" do
// 189:         expect(dumper.formulae).to be_empty
// 190:       end
// 191:     end
// 192:
// 193:     describe "#formulae_by_full_name" do
// 194:       it "returns an empty hash when no formulae are installed" do
// 195:         expect(dumper.formulae_by_full_name).to eql({})
// 196:       end
// 197:
// 198:       it "returns an empty hash for an unavailable formula" do
// 199:         expect(Formula).to receive(:[]).with("bar").and_raise(FormulaUnavailableError.new("bar"))
// 200:         expect(dumper.formulae_by_full_name("bar")).to eql({})
// 201:       end
// 202:
// 203:       it "warns and continues on cyclic dependencies instead of exiting" do
// 204:         cyclic_foo = formula_double_depending_on("foo", "bar")
// 205:         cyclic_bar = formula_double_depending_on("bar", "foo")
// 206:         expect(Formula).to receive(:installed).and_return([cyclic_foo, cyclic_bar])
// 207:
// 208:         expect { dumper.formulae_by_full_name }.to output(/found a circular dependency/).to_stderr
// 209:         expect(dumper.formulae.map { |f| f[:full_name] }).to contain_exactly("foo", "bar")
// 210:       end
// 211:
// 212:       it "returns a hash for a formula" do
// 213:         expect(Formula).to receive(:[]).with("qux/quuz/foo").and_return(foo)
// 214:         expect(dumper.formulae_by_full_name("qux/quuz/foo")).to eql(foo_hash)
// 215:       end
// 216:
// 217:       it "returns an array for all formulae" do
// 218:         expect(Formula).to receive(:installed).and_return([foo, bar, baz])
// 219:         expect(bar.linked_keg).to receive(:realpath).and_return(instance_double(Pathname, basename: "1.0"))
// 220:         expect(Tab).to receive(:for_keg).with(bar.linked_keg).and_return(
// 221:           instance_double(Tab,
// 222:                           installed_on_request: false,
// 223:                           poured_from_bottle:   true,
// 224:                           runtime_dependencies: [],
// 225:                           used_options:         []),
// 226:         )
// 227:         expect(dumper.formulae_by_full_name).to eql({
// 228:           "bar"                 => bar_hash,
// 229:           "qux/quuz/foo"        => foo_hash,
// 230:           "bazzles/bizzles/baz" => baz_hash,
// 231:         })
// 232:       end
// 233:     end
// 234:
// 235:     describe "#formulae_by_name" do
// 236:       it "returns a hash for a formula" do
// 237:         expect(Formula).to receive(:[]).with("foo").and_return(foo)
// 238:         expect(dumper.formulae_by_name("foo")).to eql(foo_hash)
// 239:       end
// 240:     end
// 241:
// 242:     describe "#dump" do
// 243:       it "returns a dump string with installed formulae" do
// 244:         allow(Homebrew::Bundle::Brew::Services).to receive(:started_services).and_return([])
// 245:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula).and_return(["bazzles/bizzles/baz"])
// 246:
// 247:         expect(Formula).to receive(:installed).and_return([foo, bar, baz])
// 248:         expect(bar.linked_keg).to receive(:realpath).and_return(instance_double(Pathname, basename: "1.0"))
// 249:         expect(Tab).to receive(:for_keg).with(bar.linked_keg).and_return(
// 250:           instance_double(Tab,
// 251:                           installed_on_request: true,
// 252:                           poured_from_bottle:   true,
// 253:                           runtime_dependencies: [],
// 254:                           used_options:         []),
// 255:         )
// 256:         expected = <<~RUBY
// 257:           # barfoo
// 258:           brew "bar"
// 259:           brew "bazzles/bizzles/baz", link: false, trusted: true
// 260:           # foobar
// 261:           brew "qux/quuz/foo"
// 262:         RUBY
// 263:         expect(dumper.dump(describe: true)).to eql(expected.chomp)
// 264:       end
// 265:     end
// 266:
// 267:     describe "#formula_aliases" do
// 268:       it "returns an empty string when no formulae are installed" do
// 269:         expect(dumper.formula_aliases).to eql({})
// 270:       end
// 271:
// 272:       it "returns a hash with installed formulae aliases" do
// 273:         expect(Formula).to receive(:installed).and_return([foo, bar, baz])
// 274:         expect(dumper.formula_aliases).to eql({
// 275:           "qux/quuz/foobar" => "qux/quuz/foo",
// 276:           "foobar"          => "qux/quuz/foo",
// 277:         })
// 278:       end
// 279:     end
// 280:
// 281:     describe "#formula_oldnames" do
// 282:       it "returns an empty string when no formulae are installed" do
// 283:         expect(dumper.formula_oldnames).to eql({})
// 284:       end
// 285:
// 286:       it "returns a hash with installed formulae old names" do
// 287:         expect(Formula).to receive(:installed).and_return([foo, bar, baz])
// 288:         expect(dumper.formula_oldnames).to eql({
// 289:           "qux/quuz/oldfoo" => "qux/quuz/foo",
// 290:           "oldfoo"          => "qux/quuz/foo",
// 291:         })
// 292:       end
// 293:     end
// 294:   end
// 295:
// 296:   describe "installing" do
// 297:     let(:formula_name) { "mysql" }
// 298:     let(:options) { { args: ["with-option"] } }
// 299:     let(:installer) { described_class.new(formula_name, options) }
// 300:
// 301:     before do
// 302:       # Clear the class-level formula cache so a hash memoised by an earlier
// 303:       # example (e.g. without conflicts) doesn't leak into this one.
// 304:       described_class.reset!
// 305:
// 306:       # don't try to load gcc/glibc
// 307:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 308:
// 309:       stub_formula_loader formula(formula_name) {
// 310:         T.bind(self, T.class_of(Formula))
// 311:         url "mysql-1.0"
// 312:       }
// 313:     end
// 314:
// 315:     context "when the formula is installed" do
// 316:       before do
// 317:         allow_any_instance_of(described_class).to receive(:installed?).and_return(true)
// 318:       end
// 319:
// 320:       context "with a true start_service option" do
// 321:         before do
// 322:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 323:           allow_any_instance_of(described_class).to receive(:installed?).and_return(true)
// 324:           allow(Homebrew::Bundle).to receive(:brew).with("link", formula_name, verbose: false).and_return(true)
// 325:         end
// 326:
// 327:         context "when service is already running" do
// 328:           before do
// 329:             allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with(formula_name).and_return(true)
// 330:           end
// 331:
// 332:           context "with a successful installation" do
// 333:             it "start service" do
// 334:               expect(Homebrew::Bundle::Brew::Services).not_to receive(:start)
// 335:               described_class.preinstall!(formula_name, start_service: true)
// 336:               described_class.install!(formula_name, start_service: true)
// 337:             end
// 338:           end
// 339:
// 340:           context "with a skipped installation" do
// 341:             it "start service" do
// 342:               expect(Homebrew::Bundle::Brew::Services).not_to receive(:start)
// 343:               described_class.install!(formula_name, preinstall: false, start_service: true)
// 344:             end
// 345:           end
// 346:         end
// 347:
// 348:         context "when service is not running" do
// 349:           before do
// 350:             allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with(formula_name).and_return(false)
// 351:           end
// 352:
// 353:           context "with a successful installation" do
// 354:             it "start service" do
// 355:               expect(Homebrew::Bundle::Brew::Services).to \
// 356:                 receive(:start).with(formula_name, file: nil, verbose: false).and_return(true)
// 357:               described_class.preinstall!(formula_name, start_service: true)
// 358:               described_class.install!(formula_name, start_service: true)
// 359:             end
// 360:           end
// 361:
// 362:           context "with a skipped installation" do
// 363:             it "start service" do
// 364:               expect(Homebrew::Bundle::Brew::Services).to \
// 365:                 receive(:start).with(formula_name, file: nil, verbose: false).and_return(true)
// 366:               described_class.install!(formula_name, preinstall: false, start_service: true)
// 367:             end
// 368:           end
// 369:         end
// 370:       end
// 371:
// 372:       context "with an always restart_service option" do
// 373:         before do
// 374:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 375:           allow_any_instance_of(described_class).to receive(:installed?).and_return(true)
// 376:           allow(Homebrew::Bundle).to receive(:brew).with("link", formula_name, verbose: false).and_return(true)
// 377:         end
// 378:
// 379:         context "with a successful installation" do
// 380:           it "restart service" do
// 381:             expect(Homebrew::Bundle::Brew::Services).to \
// 382:               receive(:restart).with(formula_name, file: nil, verbose: false).and_return(true)
// 383:             described_class.preinstall!(formula_name, restart_service: :always)
// 384:             described_class.install!(formula_name, restart_service: :always)
// 385:           end
// 386:         end
// 387:
// 388:         context "with a skipped installation" do
// 389:           it "restart service" do
// 390:             expect(Homebrew::Bundle::Brew::Services).to \
// 391:               receive(:restart).with(formula_name, file: nil, verbose: false).and_return(true)
// 392:             described_class.install!(formula_name, preinstall: false, restart_service: :always)
// 393:           end
// 394:         end
// 395:       end
// 396:
// 397:       context "when the link option is true" do
// 398:         before do
// 399:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 400:         end
// 401:
// 402:         it "links formula" do
// 403:           allow_any_instance_of(described_class).to receive(:linked?).and_return(false)
// 404:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "link", "mysql",
// 405:                                                             verbose: false).and_return(true)
// 406:           described_class.preinstall!(formula_name, link: true)
// 407:           described_class.install!(formula_name, link: true)
// 408:         end
// 409:
// 410:         it "force-links keg-only formula" do
// 411:           allow_any_instance_of(described_class).to receive(:linked?).and_return(false)
// 412:           allow_any_instance_of(described_class).to receive(:keg_only?).and_return(true)
// 413:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "link", "--force", "mysql",
// 414:                                                             verbose: false).and_return(true)
// 415:           described_class.preinstall!(formula_name, link: true)
// 416:           described_class.install!(formula_name, link: true)
// 417:         end
// 418:       end
// 419:
// 420:       context "when the link option is :overwrite" do
// 421:         before do
// 422:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 423:         end
// 424:
// 425:         it "overwrite links formula" do
// 426:           allow_any_instance_of(described_class).to receive(:linked?).and_return(false)
// 427:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "link", "--overwrite", "mysql",
// 428:                                                             verbose: false).and_return(true)
// 429:           described_class.preinstall!(formula_name, link: :overwrite)
// 430:           described_class.install!(formula_name, link: :overwrite)
// 431:         end
// 432:       end
// 433:
// 434:       context "when the link option is false" do
// 435:         before do
// 436:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 437:         end
// 438:
// 439:         it "unlinks formula" do
// 440:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 441:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql",
// 442:                                                             verbose: false).and_return(true)
// 443:           described_class.preinstall!(formula_name, link: false)
// 444:           described_class.install!(formula_name, link: false)
// 445:         end
// 446:       end
// 447:
// 448:       context "when the link option is nil and formula is unlinked and not keg-only" do
// 449:         before do
// 450:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 451:           allow_any_instance_of(described_class).to receive(:linked?).and_return(false)
// 452:           allow_any_instance_of(described_class).to receive(:keg_only?).and_return(false)
// 453:         end
// 454:
// 455:         it "links formula" do
// 456:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "link", "mysql",
// 457:                                                             verbose: false).and_return(true)
// 458:           described_class.preinstall!(formula_name, link: nil)
// 459:           described_class.install!(formula_name, link: nil)
// 460:         end
// 461:       end
// 462:
// 463:       context "when the link option is nil and formula is linked and keg-only" do
// 464:         before do
// 465:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 466:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 467:           allow_any_instance_of(described_class).to receive(:keg_only?).and_return(true)
// 468:         end
// 469:
// 470:         it "unlinks formula" do
// 471:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql",
// 472:                                                             verbose: false).and_return(true)
// 473:           described_class.preinstall!(formula_name, link: nil)
// 474:
// 475:           described_class.install!(formula_name, link: nil)
// 476:         end
// 477:       end
// 478:
// 479:       context "when the conflicts_with option is provided" do
// 480:         before do
// 481:           stub_formula_loader formula(formula_name) {
// 482:             T.bind(self, T.class_of(Formula))
// 483:             url "mysql-1.0"
// 484:             conflicts_with "mysql55"
// 485:           }
// 486:           allow(described_class).to receive(:formula_installed?).and_return(true)
// 487:           allow_any_instance_of(described_class).to receive(:install_formula!).and_return(true)
// 488:           allow_any_instance_of(described_class).to receive(:upgrade_formula!).and_return(true)
// 489:         end
// 490:
// 491:         it "unlinks conflicts and stops their services" do
// 492:           verbose = false
// 493:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 494:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql55",
// 495:                                                             verbose:).and_return(true)
// 496:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql56",
// 497:                                                             verbose:).and_return(true)
// 498:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop).with("mysql55", verbose:).and_return(true)
// 499:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop).with("mysql56", verbose:).and_return(true)
// 500:           expect(Homebrew::Bundle::Brew::Services).to receive(:restart).with(formula_name, file:    nil,
// 501:                                                                                            verbose:).and_return(true)
// 502:           described_class.preinstall!(formula_name, restart_service: :always, conflicts_with: ["mysql56"])
// 503:           described_class.install!(formula_name, restart_service: :always, conflicts_with: ["mysql56"])
// 504:         end
// 505:
// 506:         it "prints a message" do
// 507:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 508:           allow_any_instance_of(described_class).to receive(:puts)
// 509:           verbose = true
// 510:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql55",
// 511:                                                             verbose:).and_return(true)
// 512:           expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "unlink", "mysql56",
// 513:                                                             verbose:).and_return(true)
// 514:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop).with("mysql55", verbose:).and_return(true)
// 515:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop).with("mysql56", verbose:).and_return(true)
// 516:           expect(Homebrew::Bundle::Brew::Services).to receive(:restart).with(formula_name, file:    nil,
// 517:                                                                                            verbose:).and_return(true)
// 518:           described_class.preinstall!(formula_name, restart_service: :always, conflicts_with: ["mysql56"],
// 519:           verbose: true)
// 520:           described_class.install!(formula_name, restart_service: :always, conflicts_with: ["mysql56"],
// 521:           verbose: true)
// 522:         end
// 523:       end
// 524:
// 525:       context "when the postinstall option is provided" do
// 526:         before do
// 527:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 528:           allow_any_instance_of(described_class).to receive(:installed?).and_return(true)
// 529:           allow(Homebrew::Bundle).to receive(:brew).with("link", formula_name, verbose: false).and_return(true)
// 530:         end
// 531:
// 532:         context "when formula has changed" do
// 533:           before do
// 534:             allow_any_instance_of(described_class).to receive(:changed?).and_return(true)
// 535:           end
// 536:
// 537:           it "runs the postinstall command" do
// 538:             expect(Kernel).to receive(:system).with("custom command").and_return(true)
// 539:             described_class.preinstall!(formula_name, postinstall: "custom command")
// 540:             described_class.install!(formula_name, postinstall: "custom command")
// 541:           end
// 542:
// 543:           it "reports a failure" do
// 544:             expect(Kernel).to receive(:system).with("custom command").and_return(false)
// 545:             described_class.preinstall!(formula_name, postinstall: "custom command")
// 546:             expect(described_class.install!(formula_name, postinstall: "custom command")).to be(false)
// 547:           end
// 548:         end
// 549:
// 550:         context "when formula has not changed" do
// 551:           before do
// 552:             allow_any_instance_of(described_class).to receive(:changed?).and_return(false)
// 553:           end
// 554:
// 555:           it "does not run the postinstall command" do
// 556:             expect(Kernel).not_to receive(:system)
// 557:             described_class.preinstall!(formula_name, postinstall: "custom command")
// 558:             described_class.install!(formula_name, postinstall: "custom command")
// 559:           end
// 560:         end
// 561:       end
// 562:
// 563:       context "when the version_file option is provided" do
// 564:         before do
// 565:           Homebrew::Bundle.reset!
// 566:
// 567:           allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(true)
// 568:           allow_any_instance_of(described_class).to receive(:installed?).and_return(true)
// 569:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 570:         end
// 571:
// 572:         let(:version_file) { "version.txt" }
// 573:         let(:version) { "1.0" }
// 574:
// 575:         context "when formula versions are changed and specified by the environment" do
// 576:           before do
// 577:             allow_any_instance_of(described_class).to receive(:changed?).and_return(false)
// 578:             ENV["HOMEBREW_BUNDLE_EXEC_FORMULA_VERSION_#{formula_name.upcase}"] = version
// 579:           end
// 580:
// 581:           it "writes the version to the file" do
// 582:             expect(File).to receive(:write).with(version_file, "#{version}\n")
// 583:             described_class.preinstall!(formula_name, version_file:)
// 584:             described_class.install!(formula_name, version_file:)
// 585:           end
// 586:         end
// 587:
// 588:         context "when using the latest formula" do
// 589:           it "writes the version to the file" do
// 590:             expect(File).to receive(:write).with(version_file, "#{version}\n")
// 591:             described_class.preinstall!(formula_name, version_file:)
// 592:             described_class.install!(formula_name, version_file:)
// 593:           end
// 594:         end
// 595:       end
// 596:     end
// 597:
// 598:     context "when a formula isn't installed" do
// 599:       before do
// 600:         allow_any_instance_of(described_class).to receive(:installed?).and_return(false)
// 601:         allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(false)
// 602:       end
// 603:
// 604:       it "did not call restart service" do
// 605:         expect(Homebrew::Bundle::Brew::Services).not_to receive(:restart)
// 606:         described_class.preinstall!(formula_name, restart_service: true)
// 607:       end
// 608:     end
// 609:
// 610:     context "when the trusted option is true" do
// 611:       let(:tapped_name) { "foo/bar/baz" }
// 612:
// 613:       before do
// 614:         allow_any_instance_of(described_class).to receive_messages(installed?: false, resolve_conflicts!: true,
// 615:                                                                    install_formula!: true)
// 616:       end
// 617:
// 618:       it "trusts the formula before installing the tap that loads it" do
// 619:         order = []
// 620:         tap = instance_double(Tap, ensure_installed!: nil)
// 621:         allow(Tap).to receive(:with_formula_name).with(tapped_name).and_return([tap, "baz"])
// 622:         allow(tap).to receive(:ensure_installed!) { order << :tap }
// 623:         allow(Homebrew::Trust).to receive(:trust!).with(:formula, tapped_name) { order << :trust }
// 624:         described_class.install!(tapped_name, trusted: true)
// 625:         expect(order).to eq([:trust, :tap])
// 626:       end
// 627:
// 628:       it "does not trust an unqualified formula name" do
// 629:         allow(Tap).to receive(:with_formula_name).and_return(nil)
// 630:         expect(Homebrew::Trust).not_to receive(:trust!)
// 631:         described_class.install!("baz", trusted: true)
// 632:       end
// 633:     end
// 634:
// 635:     describe ".outdated_formulae" do
// 636:       it "calls Homebrew" do
// 637:         described_class.reset!
// 638:         expect(described_class).to receive(:formulae).and_return(
// 639:           [
// 640:             { name: "a", outdated?: true },
// 641:             { name: "b", outdated?: true },
// 642:             { name: "c", outdated?: false },
// 643:           ],
// 644:         )
// 645:         expect(described_class.outdated_formulae).to eql(%w[a b])
// 646:       end
// 647:     end
// 648:
// 649:     describe ".pinned_formulae" do
// 650:       it "calls Homebrew" do
// 651:         described_class.reset!
// 652:         expect(described_class).to receive(:formulae).and_return(
// 653:           [
// 654:             { name: "a", pinned?: true },
// 655:             { name: "b", pinned?: true },
// 656:             { name: "c", pinned?: false },
// 657:           ],
// 658:         )
// 659:         expect(described_class.pinned_formulae).to eql(%w[a b])
// 660:       end
// 661:     end
// 662:
// 663:     describe ".formula_installed_and_up_to_date?" do
// 664:       before do
// 665:         described_class.reset!
// 666:         allow_any_instance_of(Formula).to receive(:outdated?).and_return(true)
// 667:         allow(Formula).to receive(:installed_formula_names).and_return(%w[foo bar])
// 668:         allow(described_class).to receive_messages(outdated_formulae: %w[bar], formulae: [
// 669:           {
// 670:             name:         "foo",
// 671:             full_name:    "homebrew/tap/foo",
// 672:             aliases:      ["foobar"],
// 673:             args:         [],
// 674:             version:      "1.0",
// 675:             dependencies: [],
// 676:             requirements: [],
// 677:           },
// 678:           {
// 679:             name:         "bar",
// 680:             full_name:    "bar",
// 681:             aliases:      [],
// 682:             args:         [],
// 683:             version:      "1.0",
// 684:             dependencies: [],
// 685:             requirements: [],
// 686:           },
// 687:         ])
// 688:         stub_formula_loader formula("foo") {
// 689:           T.bind(self, T.class_of(Formula))
// 690:           url "foo-1.0"
// 691:         }
// 692:         stub_formula_loader formula("bar") {
// 693:           T.bind(self, T.class_of(Formula))
// 694:           url "bar-1.0"
// 695:         }
// 696:       end
// 697:
// 698:       it "returns result" do
// 699:         expect(described_class.formula_installed_and_up_to_date?("foo")).to be(true)
// 700:         expect(described_class.formula_installed_and_up_to_date?("foobar")).to be(true)
// 701:         expect(described_class.formula_installed_and_up_to_date?("bar")).to be(false)
// 702:         expect(described_class.formula_installed_and_up_to_date?("baz")).to be(false)
// 703:       end
// 704:     end
// 705:
// 706:     describe ".formula_installed_and_up_to_date? with an untrusted tap formula" do
// 707:       before do
// 708:         described_class.reset!
// 709:         allow(Homebrew::EnvConfig).to receive(:require_tap_trust?).and_return(true)
// 710:         allow(Formula).to receive(:installed_formula_names).and_return(["php@7.2"])
// 711:         allow(Homebrew::Trust).to receive(:trusted?).with(:formula, "shivammathur/php/php@7.2").and_return(false)
// 712:       end
// 713:
// 714:       it "warns and marks the formula actionable without loading it" do
// 715:         expect(Formula).not_to receive(:installed)
// 716:         expect(Formula).not_to receive(:[])
// 717:         expect { expect(described_class.formula_installed_and_up_to_date?("shivammathur/php/php@7.2")).to be(false) }
// 718:           .to output(/Cannot check whether.*not trusted/).to_stderr
// 719:       end
// 720:
// 721:       it "does not warn when upgrades are disabled" do
// 722:         expect(Formula).not_to receive(:installed)
// 723:         expect(Formula).not_to receive(:[])
// 724:         expect do
// 725:           expect(described_class.formula_installed_and_up_to_date?("shivammathur/php/php@7.2",
// 726:                                                                    no_upgrade: true)).to be(true)
// 727:         end
// 728:           .not_to output.to_stderr
// 729:       end
// 730:
// 731:       it "detects missing formulae without loading the formula" do
// 732:         allow(Formula).to receive(:installed_formula_names).and_return([])
// 733:
// 734:         expect(Formula).not_to receive(:installed)
// 735:         expect(Formula).not_to receive(:[])
// 736:         expect { expect(described_class.formula_installed_and_up_to_date?("shivammathur/php/php@7.2")).to be(false) }
// 737:           .not_to output.to_stderr
// 738:       end
// 739:     end
// 740:
// 741:     context "when brew is installed" do
// 742:       context "when no formula is installed" do
// 743:         before do
// 744:           allow(described_class).to receive(:installed_formulae).and_return([])
// 745:           allow_any_instance_of(described_class).to receive(:conflicts_with).and_return([])
// 746:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 747:         end
// 748:
// 749:         it "install formula" do
// 750:           expect(Homebrew::Bundle).to receive(:system)
// 751:             .with(HOMEBREW_BREW_FILE, "install", "--formula", formula_name, "--with-option", verbose: false)
// 752:             .and_return(true)
// 753:           expect(installer.preinstall!).to be(true)
// 754:           expect(installer.install!).to be(true)
// 755:         end
// 756:
// 757:         it "reports a failure" do
// 758:           expect(Homebrew::Bundle).to receive(:system)
// 759:             .with(HOMEBREW_BREW_FILE, "install", "--formula", formula_name, "--with-option", verbose: false)
// 760:             .and_return(false)
// 761:           expect(installer.preinstall!).to be(true)
// 762:           expect(installer.install!).to be(false)
// 763:         end
// 764:       end
// 765:
// 766:       context "when formula is installed" do
// 767:         before do
// 768:           allow(described_class).to receive(:installed_formulae).and_return([formula_name])
// 769:           allow_any_instance_of(described_class).to receive(:conflicts_with).and_return([])
// 770:           allow_any_instance_of(described_class).to receive(:linked?).and_return(true)
// 771:           allow_any_instance_of(Formula).to receive(:outdated?).and_return(true)
// 772:         end
// 773:
// 774:         context "when formula upgradable" do
// 775:           before do
// 776:             allow(described_class).to receive(:outdated_formulae).and_return([formula_name])
// 777:           end
// 778:
// 779:           it "upgrade formula" do
// 780:             expect(Homebrew::Bundle).to \
// 781:               receive(:system).with(HOMEBREW_BREW_FILE, "upgrade", "--formula", formula_name, verbose: false)
// 782:                               .and_return(true)
// 783:             expect(installer.preinstall!).to be(true)
// 784:             expect(installer.install!).to be(true)
// 785:           end
// 786:
// 787:           it "reports a failure" do
// 788:             expect(Homebrew::Bundle).to \
// 789:               receive(:system).with(HOMEBREW_BREW_FILE, "upgrade", "--formula", formula_name, verbose: false)
// 790:                               .and_return(false)
// 791:             expect(installer.preinstall!).to be(true)
// 792:             expect(installer.install!).to be(false)
// 793:           end
// 794:
// 795:           context "when formula pinned" do
// 796:             before do
// 797:               allow(described_class).to receive(:pinned_formulae).and_return([formula_name])
// 798:             end
// 799:
// 800:             it "does not upgrade formula" do
// 801:               expect(Homebrew::Bundle).not_to \
// 802:                 receive(:system).with(HOMEBREW_BREW_FILE, "upgrade", "--formula", formula_name, verbose: false)
// 803:               expect(installer.preinstall!).to be(false)
// 804:             end
// 805:           end
// 806:
// 807:           context "when formula not upgraded" do
// 808:             before do
// 809:               allow(described_class).to receive(:outdated_formulae).and_return([])
// 810:             end
// 811:
// 812:             it "does not upgrade formula" do
// 813:               expect(Homebrew::Bundle).not_to receive(:system)
// 814:               expect(installer.preinstall!).to be(false)
// 815:             end
// 816:           end
// 817:         end
// 818:       end
// 819:     end
// 820:
// 821:     describe "#changed?" do
// 822:       it "is false by default" do
// 823:         expect(described_class.new(formula_name).changed?).to be(false)
// 824:       end
// 825:     end
// 826:
// 827:     describe "#start_service?" do
// 828:       it "is false by default" do
// 829:         expect(described_class.new(formula_name).start_service?).to be(false)
// 830:       end
// 831:
// 832:       context "when the start_service option is true" do
// 833:         it "is true" do
// 834:           expect(described_class.new(formula_name, start_service: true).start_service?).to be(true)
// 835:         end
// 836:       end
// 837:     end
// 838:
// 839:     describe "#start_service_needed?" do
// 840:       context "when a service is already started" do
// 841:         before do
// 842:           allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with(formula_name).and_return(true)
// 843:         end
// 844:
// 845:         specify do
// 846:           expect(described_class.new(formula_name).start_service_needed?).to be(false)
// 847:           expect(described_class.new(formula_name, start_service: true).start_service_needed?).to be(false)
// 848:           expect(described_class.new(formula_name, restart_service: true).start_service_needed?).to be(false)
// 849:           expect(described_class.new(formula_name,
// 850:                                      restart_service: :changed).start_service_needed?).to be(false)
// 851:           expect(described_class.new(formula_name,
// 852:                                      restart_service: :always).start_service_needed?).to be(false)
// 853:         end
// 854:       end
// 855:
// 856:       context "when a service is not started" do
// 857:         before do
// 858:           allow(Homebrew::Bundle::Brew::Services).to receive(:started?).with(formula_name).and_return(false)
// 859:         end
// 860:
// 861:         specify do
// 862:           expect(described_class.new(formula_name).start_service_needed?).to be(false)
// 863:           expect(described_class.new(formula_name, start_service: true).start_service_needed?).to be(true)
// 864:           expect(described_class.new(formula_name, restart_service: true).start_service_needed?).to be(true)
// 865:           expect(described_class.new(formula_name,
// 866:                                      restart_service: :changed).start_service_needed?).to be(true)
// 867:           expect(described_class.new(formula_name, restart_service: :always).start_service_needed?).to be(true)
// 868:         end
// 869:       end
// 870:     end
// 871:
// 872:     describe "#restart_service?" do
// 873:       it "is false by default" do
// 874:         expect(described_class.new(formula_name).restart_service?).to be(false)
// 875:       end
// 876:
// 877:       context "when the restart_service option is true" do
// 878:         it "is true" do
// 879:           expect(described_class.new(formula_name, restart_service: true).restart_service?).to be(true)
// 880:         end
// 881:       end
// 882:
// 883:       context "when the restart_service option is always" do
// 884:         it "is true" do
// 885:           expect(described_class.new(formula_name, restart_service: :always).restart_service?).to be(true)
// 886:         end
// 887:       end
// 888:
// 889:       context "when the restart_service option is changed" do
// 890:         it "is true" do
// 891:           expect(described_class.new(formula_name, restart_service: :changed).restart_service?).to be(true)
// 892:         end
// 893:       end
// 894:     end
// 895:
// 896:     describe "#restart_service_needed?" do
// 897:       it "is false by default" do
// 898:         expect(described_class.new(formula_name).restart_service_needed?).to be(false)
// 899:       end
// 900:
// 901:       context "when a service is unchanged" do
// 902:         before do
// 903:           allow_any_instance_of(described_class).to receive(:changed?).and_return(false)
// 904:         end
// 905:
// 906:         specify do
// 907:           expect(described_class.new(formula_name, restart_service: true).restart_service_needed?).to be(false)
// 908:           expect(described_class.new(formula_name,
// 909:                                      restart_service: :always).restart_service_needed?).to be(true)
// 910:           expect(described_class.new(formula_name,
// 911:                                      restart_service: :changed).restart_service_needed?).to be(false)
// 912:         end
// 913:       end
// 914:
// 915:       context "when a service is changed" do
// 916:         before do
// 917:           allow_any_instance_of(described_class).to receive(:changed?).and_return(true)
// 918:         end
// 919:
// 920:         specify do
// 921:           expect(described_class.new(formula_name, restart_service: true).restart_service_needed?).to be(true)
// 922:           expect(described_class.new(formula_name,
// 923:                                      restart_service: :always).restart_service_needed?).to be(true)
// 924:           expect(described_class.new(formula_name,
// 925:                                      restart_service: :changed).restart_service_needed?).to be(true)
// 926:         end
// 927:       end
// 928:     end
// 929:   end
// 930:
// 931:   describe Homebrew::Bundle::Brew::Topo do
// 932:     it "treats an edge to a missing node as a leaf" do
// 933:       topo = described_class.new
// 934:       topo["a"] = ["b"]
// 935:       topo["b"] = ["libice"]
// 936:
// 937:       expect(topo.tsort).to eq(["libice", "b", "a"])
// 938:     end
// 939:
// 940:     it "flattens a cyclic graph via strongly connected components without raising" do
// 941:       topo = described_class.new
// 942:       topo["a"] = ["b"]
// 943:       topo["b"] = ["a"]
// 944:
// 945:       cycles = []
// 946:       expect(topo.tsort_with_cycles { |c| cycles.concat(c) }).to contain_exactly("a", "b")
// 947:       expect(cycles).to eq([["a", "b"]])
// 948:     end
// 949:   end
// 950: end
