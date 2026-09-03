module cli

import homebrew.api
import homebrew.cli as brew_cli
import os

// Translated from Homebrew/brew `test/cli/named_args_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:foo) do` at line 7.
pub fn ruby_named_args_spec_l7_d1_foo() api.PackageReference {
	return named_args_spec_formula('foo', 'homebrew/core', '/path/to/foo.rb')
}

// Ruby let `let(:bar) do` at line 14.
pub fn ruby_named_args_spec_l14_d2_bar() api.PackageReference {
	return named_args_spec_formula('bar', 'homebrew/core', '/path/to/bar.rb')
}

// Ruby let `let(:baz) do` at line 21.
pub fn ruby_named_args_spec_l21_d3_baz() api.PackageReference {
	return named_args_spec_cask('baz', '/path/to/baz.rb')
}

// Ruby let `let(:foo_cask) do` at line 28.
pub fn ruby_named_args_spec_l28_d4_foo_cask() api.PackageReference {
	return named_args_spec_cask('foo', '/path/to/foo-cask.rb')
}

// Ruby method `setup_unredable_formula(name)` at line 36.
pub fn ruby_named_args_spec_l36_d5_setup_unredable_formula(name string) brew_cli.NamedArgsConfig {
	return brew_cli.NamedArgsConfig{
		without_api: true
		formula_errors: {
			name: 'FormulaUnreadableError: ${name}: testing'
		}
	}
}

// Ruby method `setup_unredable_cask(name)` at line 41.
pub fn ruby_named_args_spec_l41_d6_setup_unredable_cask(name string) brew_cli.NamedArgsConfig {
	return brew_cli.NamedArgsConfig{
		without_api: true
		cask_errors: {
			name: 'CaskUnreadableError: ${name}: testing'
		}
	}
}

// Ruby it `it "returns formulae" do` at line 50.
pub fn ruby_named_args_spec_l50_d7_returns() bool {
	args := named_args_spec_args(['foo', 'bar'], [ruby_named_args_spec_l7_d1_foo(),
		ruby_named_args_spec_l14_d2_bar()], []api.PackageReference{}, brew_cli.NamedArgsConfig{})
	return (args.to_formulae() or { return false }).map(it.name) == ['foo', 'bar']
}

// Ruby it `it "raises an error when a Formula is unavailable" do` at line 57.
pub fn ruby_named_args_spec_l57_d8_raises() bool {
	args := named_args_spec_args(['mxcl'], []api.PackageReference{}, []api.PackageReference{}, brew_cli.NamedArgsConfig{})
	args.to_formulae() or { return err.msg().contains('FormulaUnavailable') || err.msg().contains('formula unavailable') }
	return false
}

// Ruby it `it "returns an empty array when there are no Formulae" do` at line 61.
pub fn ruby_named_args_spec_l61_d9_returns() bool {
	return (named_args_spec_args([]string{}, []api.PackageReference{}, []api.PackageReference{}, brew_cli.NamedArgsConfig{}).to_formulae() or { return false }).len == 0
}

// Ruby it `it "returns formulae and casks", :needs_macos do` at line 67.
pub fn ruby_named_args_spec_l67_d10_returns() bool {
	args := named_args_spec_args(['foo', 'baz'], [ruby_named_args_spec_l7_d1_foo()], [
		ruby_named_args_spec_l21_d3_baz(),
	], brew_cli.NamedArgsConfig{})
	return (args.to_formulae_and_casks() or { return false }).map(it.name) == ['foo', 'baz']
}

// Ruby it `it "returns formula by default" do` at line 80.
pub fn ruby_named_args_spec_l80_d11_returns() bool {
	args := named_args_spec_both_foo(false)
	packages := args.to_formulae_and_casks() or { return false }
	return packages.len == 1 && packages[0].kind == .formula
}

// Ruby it `it "returns formula if loading formula only" do` at line 84.
pub fn ruby_named_args_spec_l84_d12_returns() bool {
	packages := named_args_spec_both_foo(false).resolve_formulae_and_casks(brew_cli.PackageConversionOptions{
		only: 'formula'
		unique: true
	}) or { return false }
	return packages.len == 1 && packages[0].kind == .formula
}

// Ruby it `it "returns cask if loading cask only" do` at line 88.
pub fn ruby_named_args_spec_l88_d13_returns() bool {
	packages := named_args_spec_both_foo(false).resolve_formulae_and_casks(brew_cli.PackageConversionOptions{
		only: 'cask'
		unique: true
	}) or { return false }
	return packages.len == 1 && packages[0].kind == .cask
}

// Ruby let `let(:non_core_formula) do` at line 94.
pub fn ruby_named_args_spec_l94_d14_non_core_formula() api.PackageReference {
	return named_args_spec_formula('foo', 'some/tap', '/path/to/some-tap/foo.rb')
}

// Ruby it `it "returns the cask by default" do` at line 107.
pub fn ruby_named_args_spec_l107_d15_returns() bool {
	packages := named_args_spec_both_foo(true).to_formulae_and_casks() or { return false }
	return packages.len == 1 && packages[0].kind == .cask
}

// Ruby it `it "returns formula if loading formula only" do` at line 111.
pub fn ruby_named_args_spec_l111_d16_returns() bool {
	packages := named_args_spec_both_foo(true).resolve_formulae_and_casks(brew_cli.PackageConversionOptions{
		only: 'formula'
		unique: true
	}) or { return false }
	return packages.len == 1 && packages[0].tap == 'some/tap'
}

// Ruby it `it "returns cask if loading cask only" do` at line 115.
pub fn ruby_named_args_spec_l115_d17_returns() bool {
	packages := named_args_spec_both_foo(true).to_casks() or { return false }
	return packages.len == 1 && packages[0].kind == .cask
}

// Ruby it `it "raises an error" do` at line 126.
pub fn ruby_named_args_spec_l126_d18_raises() bool {
	args := named_args_spec_unreadable(true, true, []api.PackageReference{})
	args.to_formulae_and_casks() or { return err.msg().contains('FormulaUnreadableError') }
	return false
}

// Ruby it `it "raises an error if loading formula only" do` at line 130.
pub fn ruby_named_args_spec_l130_d19_raises() bool {
	args := named_args_spec_unreadable(true, true, []api.PackageReference{})
	args.to_formulae() or { return err.msg().contains('FormulaUnreadableError') }
	return false
}

// Ruby it `it "raises an error if loading cask only" do` at line 135.
pub fn ruby_named_args_spec_l135_d20_raises() bool {
	args := named_args_spec_unreadable(true, true, []api.PackageReference{})
	args.to_casks() or { return err.msg().contains('CaskUnreadableError') }
	return false
}

// Ruby it `it "raises an error when neither formula nor cask is present" do` at line 141.
pub fn ruby_named_args_spec_l141_d21_raises() bool {
	args := named_args_spec_args(['foo'], []api.PackageReference{}, []api.PackageReference{}, brew_cli.NamedArgsConfig{})
	args.to_formulae_and_casks() or { return err.msg().contains('FormulaOrCaskUnavailableError') }
	return false
}

// Ruby it `it "returns formula when formula is present and cask is unreadable", :needs_macos do` at line 147.
pub fn ruby_named_args_spec_l147_d22_returns() bool {
	args := named_args_spec_unreadable(false, true, [ruby_named_args_spec_l7_d1_foo()])
	resolved := args.resolve_formula_or_cask('foo', '', '', true) or { return false }
	return resolved.package.kind == .formula && resolved.warnings.len == 1
}

// Ruby it `it "returns cask when formula is unreadable and cask is present", :needs_macos do` at line 157.
pub fn ruby_named_args_spec_l157_d23_returns() bool {
	args := named_args_spec_unreadable(true, false, [
		ruby_named_args_spec_l28_d4_foo_cask(),
	])
	resolved := args.resolve_formula_or_cask('foo', '', '', true) or { return false }
	return resolved.package.kind == .cask && resolved.warnings.len == 1
}

// Ruby it `it "raises an error when formula is absent and cask is unreadable", :needs_macos do` at line 167.
pub fn ruby_named_args_spec_l167_d24_raises() bool {
	args := named_args_spec_unreadable(false, true, []api.PackageReference{})
	args.to_formulae_and_casks() or { return err.msg().contains('CaskUnreadableError') }
	return false
}

// Ruby it `it "raises an error when formula is unreadable and cask is absent" do` at line 173.
pub fn ruby_named_args_spec_l173_d25_raises() bool {
	args := named_args_spec_unreadable(true, false, []api.PackageReference{})
	args.to_formulae_and_casks() or { return err.msg().contains('FormulaUnreadableError') }
	return false
}

// Ruby it `it "returns resolved formulae" do` at line 181.
pub fn ruby_named_args_spec_l181_d26_returns() bool {
	args := named_args_spec_args(['foo', 'bar'], [ruby_named_args_spec_l7_d1_foo(),
		ruby_named_args_spec_l14_d2_bar()], []api.PackageReference{}, brew_cli.NamedArgsConfig{})
	return (args.to_resolved_formulae(true) or { return false }).map(it.name) == ['foo', 'bar']
}

// Ruby it `it "returns resolved formulae, as well as casks", :needs_macos do` at line 189.
pub fn ruby_named_args_spec_l189_d27_returns() bool {
	args := named_args_spec_args(['foo', 'baz'], [ruby_named_args_spec_l7_d1_foo()], [
		ruby_named_args_spec_l21_d3_baz(),
	], brew_cli.NamedArgsConfig{})
	partition := args.to_resolved_formulae_to_casks('') or { return false }
	return partition.formulae.map(it.name) == ['foo'] && partition.casks.map(it.name) == [
		'baz',
	]
}

// Ruby it `it "returns casks" do` at line 202.
pub fn ruby_named_args_spec_l202_d28_returns() bool {
	args := named_args_spec_args(['baz'], []api.PackageReference{}, [
		ruby_named_args_spec_l21_d3_baz(),
	], brew_cli.NamedArgsConfig{})
	return (args.to_casks() or { return false }).map(it.name) == ['baz']
}

// Ruby it `it "resolves kegs with` at line 216.
pub fn ruby_named_args_spec_l216_d29_resolves() bool {
	return (named_args_spec_keg_args(['foo', 'bar']).to_keg_references('kegs') or {
		return false
	}).map(it.name) == ['foo', 'foo', 'bar']
}

// Ruby specify `specify do` at line 220.
pub fn ruby_named_args_spec_l220_d30_do() bool {
	versions := (named_args_spec_keg_args(['foo']).to_keg_references('kegs') or {
		return false
	}).map(it.stable_version).sorted()
	empty := named_args_spec_keg_args([]string{}).to_keg_references('kegs') or { return false }
	return versions == ['1.0', '2.0'] && empty.len == 0
}

// Ruby it `it "raises an error when a Keg is unavailable" do` at line 225.
pub fn ruby_named_args_spec_l225_d31_raises() bool {
	named_args_spec_keg_args(['missing']).to_keg_references('kegs') or {
		return err.msg().contains('NoSuchKegError')
	}
	return false
}

// Ruby let `let(:tab) { instance_double(Tab, tap: Tap.fetch("user", "repo")) }` at line 230.
pub fn ruby_named_args_spec_l230_d32_tab() brew_cli.NamedKeg {
	return brew_cli.NamedKeg{
		name: 'bar'
		path: '/cellar/bar/1.0'
		version: '1.0'
		tap: 'user/repo'
	}
}

// Ruby it `it "returns kegs if no tap is specified" do` at line 236.
pub fn ruby_named_args_spec_l236_d33_returns() bool {
	args := named_args_spec_tapped_keg_args('bar')
	return (args.to_keg_references('kegs') or { return false }).map(it.name) == ['bar']
}

// Ruby it `it "returns kegs if the tap is specified" do` at line 242.
pub fn ruby_named_args_spec_l242_d34_returns() bool {
	args := named_args_spec_tapped_keg_args('user/repo/bar')
	return (args.to_keg_references('kegs') or { return false }).map(it.name) == ['bar']
}

// Ruby it `it "raises an error if there is no tap match" do` at line 248.
pub fn ruby_named_args_spec_l248_d35_raises() bool {
	args := named_args_spec_tapped_keg_args('other/tap/bar')
	args.to_keg_references('kegs') or {
		return err.msg().contains('other/tap')
	}
	return false
}

// Ruby it `it "resolves kegs with` at line 267.
pub fn ruby_named_args_spec_l267_d36_resolves() bool {
	return (named_args_spec_keg_args(['foo', 'bar']).to_keg_references('default_kegs') or {
		return false
	}).map(it.name) == ['foo', 'bar']
}

// Ruby it `it "resolves the default keg" do` at line 271.
pub fn ruby_named_args_spec_l271_d37_resolves() bool {
	return (named_args_spec_keg_args(['foo']).to_keg_references('default_kegs') or {
		return false
	}).map(it.stable_version) == ['2.0']
}

// Ruby it `it "when there are no matching kegs returns an empty array" do` at line 275.
pub fn ruby_named_args_spec_l275_d38_when() bool {
	return (named_args_spec_keg_args([]string{}).to_keg_references('default_kegs') or {
		return false
	}).len == 0
}

// Ruby it `it "resolves the latest kegs with` at line 291.
pub fn ruby_named_args_spec_l291_d39_resolves() bool {
	latest := named_args_spec_keg_args(['foo', 'bar', 'baz']).to_keg_references('latest_kegs') or {
		return false
	}
	return latest.map(it.name) == ['foo', 'bar', 'baz'] && latest.map(it.stable_version) == [
		'2.0',
		'1.0',
		'HEAD-2',
	]
}

// Ruby it `it "when there are no matching kegs returns an empty array" do` at line 297.
pub fn ruby_named_args_spec_l297_d40_when() bool {
	return (named_args_spec_keg_args([]string{}).to_keg_references('latest_kegs') or {
		return false
	}).len == 0
}

// Ruby it `it "returns kegs, as well as casks", :needs_macos do` at line 307.
pub fn ruby_named_args_spec_l307_d41_returns() bool {
	config := named_args_spec_keg_config()
	args := named_args_spec_args(['foo', 'baz'], []api.PackageReference{}, [
		ruby_named_args_spec_l21_d3_baz(),
	], config)
	partition := args.to_kegs_to_casks('', false, false) or { return false }
	return partition.formulae.map(it.name) == ['foo'] && partition.casks.map(it.name) == [
		'baz',
	]
}

// Ruby specify `specify do` at line 318.
pub fn ruby_named_args_spec_l318_d42_do() bool {
	with_cask := brew_cli.new_named_args(['foo', 'homebrew/cask/local-caffeine'])
	without := brew_cli.new_named_args(['foo'])
	return with_cask.homebrew_tap_cask_names() == ['homebrew/cask/local-caffeine'] && without.homebrew_tap_cask_names().len == 0
}

// Ruby let `let(:existing_path) { mktmpdir }` at line 326.
pub fn ruby_named_args_spec_l326_d43_existing_path() string {
	return os.temp_dir()
}

// Ruby let `let(:formula_path) { Pathname("/path/to/foo.rb") }` at line 327.
pub fn ruby_named_args_spec_l327_d44_formula_path() string {
	return '/path/to/foo.rb'
}

// Ruby let `let(:cask_path) { Pathname("/path/to/baz.rb") }` at line 328.
pub fn ruby_named_args_spec_l328_d45_cask_path() string {
	return '/path/to/baz.rb'
}

// Ruby it `it "returns taps, cask formula and existing paths", :needs_macos do` at line 338.
pub fn ruby_named_args_spec_l338_d46_returns() bool {
	existing := ruby_named_args_spec_l326_d43_existing_path()
	args := named_args_spec_path_args(['homebrew/core', 'foo', 'baz', existing])
	return (args.to_paths('', false) or { return false }) == ['/taps/homebrew/core',
		ruby_named_args_spec_l327_d44_formula_path(), ruby_named_args_spec_l328_d45_cask_path(),
		os.abs_path(existing)]
}

// Ruby it `it "returns both cask and formula paths if they exist", :needs_macos do` at line 346.
pub fn ruby_named_args_spec_l346_d47_returns() bool {
	args := named_args_spec_path_args(['foo', 'baz'])
	return (args.to_paths('', false) or { return false }) == [
		ruby_named_args_spec_l327_d44_formula_path(),
		ruby_named_args_spec_l328_d45_cask_path(),
	]
}

// Ruby it `it "returns only formulae when `only: :formula` is specified" do` at line 353.
pub fn ruby_named_args_spec_l353_d48_returns() bool {
	args := named_args_spec_path_args(['foo', 'baz'])
	return (args.to_paths('formula', false) or { return false }) == [
		ruby_named_args_spec_l327_d44_formula_path(),
		'/formula/b/baz.rb',
	]
}

// Ruby it `it "returns only casks when `only: :cask` is specified" do` at line 360.
pub fn ruby_named_args_spec_l360_d49_returns() bool {
	args := named_args_spec_path_args(['foo', 'baz'])
	return (args.to_paths('cask', false) or { return false }) == [os.abs_path('foo'),
		ruby_named_args_spec_l328_d45_cask_path()]
}

// Ruby it `it "returns a bare path for an API-known formula when the tap is not installed" do` at line 367.
pub fn ruby_named_args_spec_l367_d50_returns() bool {
	args := named_args_spec_args(['foo'], []api.PackageReference{}, []api.PackageReference{}, brew_cli.NamedArgsConfig{
		without_api: true
	})
	paths := args.to_paths('', false) or { return false }
	return paths.len == 1 && !paths[0].contains('homebrew-core/Formula')
}

// Ruby it `it "returns taps" do` at line 387.
pub fn ruby_named_args_spec_l387_d51_returns() bool {
	return (brew_cli.new_named_args(['homebrew/foo', 'bar/baz']).to_taps() or {
		return false
	}) == ['homebrew/foo', 'bar/baz']
}

// Ruby it `it "raises an error for invalid tap" do` at line 392.
pub fn ruby_named_args_spec_l392_d52_raises() bool {
	brew_cli.new_named_args(['homebrew/foo', 'barbaz']).to_taps() or {
		return err.msg().contains('Invalid tap name')
	}
	return false
}

// Ruby it `it "returns installed taps" do` at line 403.
pub fn ruby_named_args_spec_l403_d53_returns() bool {
	args := brew_cli.new_named_args_with_config(['homebrew/foo'], brew_cli.NamedArgsConfig{
		installed_taps: ['homebrew/foo']
	})
	return (args.to_installed_taps() or { return false }) == ['homebrew/foo']
}

// Ruby it `it "raises an error for uninstalled tap" do` at line 408.
pub fn ruby_named_args_spec_l408_d54_raises() bool {
	args := brew_cli.new_named_args_with_config(['homebrew/foo', 'bar/baz'], brew_cli.NamedArgsConfig{
		installed_taps: ['homebrew/foo']
	})
	args.to_installed_taps() or { return err.msg().contains('TapUnavailableError') }
	return false
}

// Ruby it `it "raises an error for invalid tap" do` at line 413.
pub fn ruby_named_args_spec_l413_d55_raises() bool {
	args := brew_cli.new_named_args_with_config(['homebrew/foo', 'barbaz'], brew_cli.NamedArgsConfig{
		installed_taps: ['homebrew/foo']
	})
	args.to_installed_taps() or { return err.msg().contains('Invalid tap name') }
	return false
}

fn named_args_spec_formula(name string, tap string, local_path string) api.PackageReference {
	return api.PackageReference{
		kind: .formula
		name: name
		full_name: name
		tap: tap
		stable_version: '1.0'
		local_path: local_path
		core_tap: tap == 'homebrew/core'
		tap_installed: true
	}
}

fn named_args_spec_cask(name string, local_path string) api.PackageReference {
	return api.PackageReference{
		kind: .cask
		name: name
		full_name: name
		tap: 'homebrew/cask'
		stable_version: '1.0'
		local_path: local_path
		core_cask_tap: true
		tap_installed: true
	}
}

fn named_args_spec_args(values []string, formulae []api.PackageReference,
	casks []api.PackageReference, extra brew_cli.NamedArgsConfig) brew_cli.NamedArgs {
	mut formula_map := map[string]api.PackageReference{}
	for formula in formulae {
		formula_map[formula.name] = formula
	}
	mut cask_map := map[string]api.PackageReference{}
	for cask in casks {
		cask_map[cask.name] = cask
	}
	return brew_cli.new_named_args_with_config(values, brew_cli.NamedArgsConfig{
		...extra
		without_api: true
		formulae: formula_map
		casks: cask_map
	})
}

fn named_args_spec_both_foo(non_core bool) brew_cli.NamedArgs {
	formula := if non_core {
		ruby_named_args_spec_l94_d14_non_core_formula()
	} else {
		ruby_named_args_spec_l7_d1_foo()
	}
	return named_args_spec_args(['foo'], [formula], [
		ruby_named_args_spec_l28_d4_foo_cask(),
	], brew_cli.NamedArgsConfig{})
}

fn named_args_spec_unreadable(formula_unreadable bool, cask_unreadable bool,
	packages []api.PackageReference) brew_cli.NamedArgs {
	mut formulae := []api.PackageReference{}
	mut casks := []api.PackageReference{}
	for package in packages {
		if package.kind == .formula {
			formulae << package
		} else if package.kind == .cask {
			casks << package
		}
	}
	return named_args_spec_args(['foo'], formulae, casks, brew_cli.NamedArgsConfig{
		formula_errors: if formula_unreadable {
			{
				'foo': 'FormulaUnreadableError: foo: testing'
			}} else {
			map[string]string{}}
		cask_errors: if cask_unreadable {
			{
				'foo': 'CaskUnreadableError: foo: testing'
			}} else {
			map[string]string{}}
	})
}

fn named_args_spec_keg_config() brew_cli.NamedArgsConfig {
	return brew_cli.NamedArgsConfig{
		without_api: true
		kegs: {
			'foo': [
				brew_cli.NamedKeg{ name: 'foo', path: '/cellar/foo/1.0', version: '1.0' },
				brew_cli.NamedKeg{ name: 'foo', path: '/cellar/foo/2.0', version: '2.0' },
			]
			'bar': [
				brew_cli.NamedKeg{ name: 'bar', path: '/cellar/bar/1.0', version: '1.0' },
			]
			'baz': [
				brew_cli.NamedKeg{ name: 'baz', path: '/cellar/baz/HEAD-1', version: 'HEAD-1', head: true, source_modified_time: 1 },
				brew_cli.NamedKeg{ name: 'baz', path: '/cellar/baz/HEAD-2', version: 'HEAD-2', head: true, source_modified_time: 2 },
			]
		}
		linked_prefixes: {
			'foo': '/cellar/foo/2.0'
		}
	}
}

fn named_args_spec_keg_args(values []string) brew_cli.NamedArgs {
	return named_args_spec_args(values, []api.PackageReference{}, []api.PackageReference{}, named_args_spec_keg_config())
}

fn named_args_spec_tapped_keg_args(name string) brew_cli.NamedArgs {
	return named_args_spec_args([name], []api.PackageReference{}, []api.PackageReference{}, brew_cli.NamedArgsConfig{
		without_api: true
		kegs: {
			'bar': [ruby_named_args_spec_l230_d32_tab()]
		}
	})
}

fn named_args_spec_path_args(values []string) brew_cli.NamedArgs {
	return named_args_spec_args(values, [ruby_named_args_spec_l7_d1_foo()], [
		ruby_named_args_spec_l21_d3_baz(),
	], brew_cli.NamedArgsConfig{
		formula_directory: '/formula'
		tap_paths: {
			'homebrew/core': '/taps/homebrew/core'
		}
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/named_args"
// 5:
// 6: RSpec.describe Homebrew::CLI::NamedArgs do
// 7:   let(:foo) do
// 8:     formula "foo" do
// 9:       T.bind(self, T.class_of(Formula))
// 10:       url "https://brew.sh"
// 11:       version "1.0"
// 12:     end
// 13:   end
// 14:   let(:bar) do
// 15:     formula "bar" do
// 16:       T.bind(self, T.class_of(Formula))
// 17:       url "https://brew.sh"
// 18:       version "1.0"
// 19:     end
// 20:   end
// 21:   let(:baz) do
// 22:     Cask::CaskLoader::FromContentLoader.new(+<<~RUBY, tap: CoreCaskTap.instance).load(config: nil)
// 23:       cask "baz" do
// 24:         version "1.0"
// 25:       end
// 26:     RUBY
// 27:   end
// 28:   let(:foo_cask) do
// 29:     Cask::CaskLoader::FromContentLoader.new(+<<~RUBY, tap: CoreCaskTap.instance).load(config: nil)
// 30:       cask "foo" do
// 31:         version "1.0"
// 32:       end
// 33:     RUBY
// 34:   end
// 35:
// 36:   def setup_unredable_formula(name)
// 37:     error = FormulaUnreadableError.new(name, RuntimeError.new("testing"))
// 38:     allow(Formulary).to receive(:factory).with(name, any_args).and_raise(error)
// 39:   end
// 40:
// 41:   def setup_unredable_cask(name)
// 42:     error = Cask::CaskUnreadableError.new(name, "testing")
// 43:     allow(Cask::CaskLoader).to receive(:load).with(name, any_args).and_raise(error)
// 44:
// 45:     config = instance_double(Cask::Config)
// 46:     allow(Cask::Config).to receive(:from_args).and_return(config)
// 47:   end
// 48:
// 49:   describe "#to_formulae" do
// 50:     it "returns formulae" do
// 51:       stub_formula_loader foo, call_original: true
// 52:       stub_formula_loader bar
// 53:
// 54:       expect(described_class.new("foo", "bar").to_formulae).to eq [foo, bar]
// 55:     end
// 56:
// 57:     it "raises an error when a Formula is unavailable" do
// 58:       expect { described_class.new("mxcl").to_formulae }.to raise_error FormulaUnavailableError
// 59:     end
// 60:
// 61:     it "returns an empty array when there are no Formulae" do
// 62:       expect(described_class.new.to_formulae).to be_empty
// 63:     end
// 64:   end
// 65:
// 66:   describe "#to_formulae_and_casks" do
// 67:     it "returns formulae and casks", :needs_macos do
// 68:       stub_formula_loader foo, call_original: true
// 69:       stub_cask_loader baz, call_original: true
// 70:
// 71:       expect(described_class.new("foo", "baz").to_formulae_and_casks).to eq [foo, baz]
// 72:     end
// 73:
// 74:     context "when both formula and cask are present" do
// 75:       before do
// 76:         stub_formula_loader foo
// 77:         stub_cask_loader foo_cask
// 78:       end
// 79:
// 80:       it "returns formula by default" do
// 81:         expect(described_class.new("foo").to_formulae_and_casks).to eq [foo]
// 82:       end
// 83:
// 84:       it "returns formula if loading formula only" do
// 85:         expect(described_class.new("foo").to_formulae_and_casks(only: :formula)).to eq [foo]
// 86:       end
// 87:
// 88:       it "returns cask if loading cask only" do
// 89:         expect(described_class.new("foo").to_formulae_and_casks(only: :cask)).to eq [foo_cask]
// 90:       end
// 91:     end
// 92:
// 93:     context "when a non-core formula and a core cask are present" do
// 94:       let(:non_core_formula) do
// 95:         formula "foo", tap: Tap.fetch("some/tap") do
// 96:           T.bind(self, T.class_of(Formula))
// 97:           url "https://brew.sh"
// 98:           version "1.0"
// 99:         end
// 100:       end
// 101:
// 102:       before do
// 103:         stub_formula_loader non_core_formula, "foo"
// 104:         stub_cask_loader foo_cask
// 105:       end
// 106:
// 107:       it "returns the cask by default" do
// 108:         expect(described_class.new("foo").to_formulae_and_casks).to eq [foo_cask]
// 109:       end
// 110:
// 111:       it "returns formula if loading formula only" do
// 112:         expect(described_class.new("foo").to_formulae_and_casks(only: :formula)).to eq [non_core_formula]
// 113:       end
// 114:
// 115:       it "returns cask if loading cask only" do
// 116:         expect(described_class.new("foo").to_formulae_and_casks(only: :cask)).to eq [foo_cask]
// 117:       end
// 118:     end
// 119:
// 120:     context "when both formula and cask are unreadable" do
// 121:       before do
// 122:         setup_unredable_formula "foo"
// 123:         setup_unredable_cask "foo"
// 124:       end
// 125:
// 126:       it "raises an error" do
// 127:         expect { described_class.new("foo").to_formulae_and_casks }.to raise_error(FormulaUnreadableError)
// 128:       end
// 129:
// 130:       it "raises an error if loading formula only" do
// 131:         expect { described_class.new("foo").to_formulae_and_casks(only: :formula) }
// 132:           .to raise_error(FormulaUnreadableError)
// 133:       end
// 134:
// 135:       it "raises an error if loading cask only" do
// 136:         expect { described_class.new("foo").to_formulae_and_casks(only: :cask) }
// 137:           .to raise_error(Cask::CaskUnreadableError)
// 138:       end
// 139:     end
// 140:
// 141:     it "raises an error when neither formula nor cask is present" do
// 142:       expect do
// 143:         described_class.new("foo").to_formulae_and_casks
// 144:       end.to raise_error(FormulaOrCaskUnavailableError)
// 145:     end
// 146:
// 147:     it "returns formula when formula is present and cask is unreadable", :needs_macos do
// 148:       stub_formula_loader foo
// 149:       setup_unredable_cask "foo"
// 150:
// 151:       expect(described_class.new("foo").to_formulae_and_casks).to eq [foo]
// 152:       expect do
// 153:         described_class.new("foo").to_formulae_and_casks
// 154:       end.to output(/Failed to load cask: foo/).to_stderr
// 155:     end
// 156:
// 157:     it "returns cask when formula is unreadable and cask is present", :needs_macos do
// 158:       setup_unredable_formula "foo"
// 159:       stub_cask_loader foo_cask
// 160:
// 161:       expect(described_class.new("foo").to_formulae_and_casks).to eq [foo_cask]
// 162:       expect do
// 163:         described_class.new("foo").to_formulae_and_casks
// 164:       end.to output(/Failed to load formula: foo/).to_stderr
// 165:     end
// 166:
// 167:     it "raises an error when formula is absent and cask is unreadable", :needs_macos do
// 168:       setup_unredable_cask "foo"
// 169:
// 170:       expect { described_class.new("foo").to_formulae_and_casks }.to raise_error(Cask::CaskUnreadableError)
// 171:     end
// 172:
// 173:     it "raises an error when formula is unreadable and cask is absent" do
// 174:       setup_unredable_formula "foo"
// 175:
// 176:       expect { described_class.new("foo").to_formulae_and_casks }.to raise_error(FormulaUnreadableError)
// 177:     end
// 178:   end
// 179:
// 180:   describe "#to_resolved_formulae" do
// 181:     it "returns resolved formulae" do
// 182:       allow(Formulary).to receive(:resolve).and_return(foo, bar)
// 183:
// 184:       expect(described_class.new("foo", "bar").to_resolved_formulae).to eq [foo, bar]
// 185:     end
// 186:   end
// 187:
// 188:   describe "#to_resolved_formulae_to_casks" do
// 189:     it "returns resolved formulae, as well as casks", :needs_macos do
// 190:       allow(Formulary).to receive(:resolve).and_call_original
// 191:       allow(Formulary).to receive(:resolve).with("foo", any_args).and_return foo
// 192:       stub_cask_loader baz, call_original: true
// 193:
// 194:       resolved_formulae, casks = described_class.new("foo", "baz").to_resolved_formulae_to_casks
// 195:
// 196:       expect(resolved_formulae).to eq [foo]
// 197:       expect(casks).to eq [baz]
// 198:     end
// 199:   end
// 200:
// 201:   describe "#to_casks" do
// 202:     it "returns casks" do
// 203:       stub_cask_loader baz
// 204:
// 205:       expect(described_class.new("baz").to_casks).to eq [baz]
// 206:     end
// 207:   end
// 208:
// 209:   describe "#to_kegs" do
// 210:     before do
// 211:       (HOMEBREW_CELLAR/"foo/1.0").mkpath
// 212:       (HOMEBREW_CELLAR/"foo/2.0").mkpath
// 213:       (HOMEBREW_CELLAR/"bar/1.0").mkpath
// 214:     end
// 215:
// 216:     it "resolves kegs with #resolve_kegs" do
// 217:       expect(described_class.new("foo", "bar").to_kegs.map(&:name)).to eq ["foo", "foo", "bar"]
// 218:     end
// 219:
// 220:     specify do
// 221:       expect(described_class.new("foo").to_kegs.map { |k| k.version.version.to_s }.sort).to eq ["1.0", "2.0"]
// 222:       expect(described_class.new.to_kegs).to be_empty
// 223:     end
// 224:
// 225:     it "raises an error when a Keg is unavailable" do
// 226:       expect { described_class.new("baz").to_kegs }.to raise_error NoSuchKegError
// 227:     end
// 228:
// 229:     context "when a keg specifies a tap" do
// 230:       let(:tab) { instance_double(Tab, tap: Tap.fetch("user", "repo")) }
// 231:
// 232:       before do
// 233:         allow_any_instance_of(Keg).to receive(:tab).and_return(tab)
// 234:       end
// 235:
// 236:       it "returns kegs if no tap is specified" do
// 237:         stub_formula_loader bar, "user/repo/bar"
// 238:
// 239:         expect(described_class.new("bar").to_kegs.map(&:name)).to eq ["bar"]
// 240:       end
// 241:
// 242:       it "returns kegs if the tap is specified" do
// 243:         stub_formula_loader bar, "user/repo/bar"
// 244:
// 245:         expect(described_class.new("user/repo/bar").to_kegs.map(&:name)).to eq ["bar"]
// 246:       end
// 247:
// 248:       it "raises an error if there is no tap match" do
// 249:         stub_formula_loader bar, "other/tap/bar"
// 250:
// 251:         expect do
// 252:           described_class.new("other/tap/bar").to_kegs
// 253:         end.to raise_error(NoSuchKegError, %r{from tap other/tap})
// 254:       end
// 255:     end
// 256:   end
// 257:
// 258:   describe "#to_default_kegs" do
// 259:     before do
// 260:       (HOMEBREW_CELLAR/"foo/1.0").mkpath
// 261:       (HOMEBREW_CELLAR/"bar/1.0").mkpath
// 262:       linked_path = (HOMEBREW_CELLAR/"foo/2.0")
// 263:       linked_path.mkpath
// 264:       Keg.new(linked_path).link
// 265:     end
// 266:
// 267:     it "resolves kegs with #resolve_default_keg" do
// 268:       expect(described_class.new("foo", "bar").to_default_kegs.map(&:name)).to eq ["foo", "bar"]
// 269:     end
// 270:
// 271:     it "resolves the default keg" do
// 272:       expect(described_class.new("foo").to_default_kegs.map { |k| k.version.version.to_s }).to eq ["2.0"]
// 273:     end
// 274:
// 275:     it "when there are no matching kegs returns an empty array" do
// 276:       expect(described_class.new.to_default_kegs).to be_empty
// 277:     end
// 278:   end
// 279:
// 280:   describe "#to_latest_kegs" do
// 281:     before do
// 282:       (HOMEBREW_CELLAR/"foo/1.0").mkpath
// 283:       (HOMEBREW_CELLAR/"foo/2.0").mkpath
// 284:       (HOMEBREW_CELLAR/"bar/1.0").mkpath
// 285:       (HOMEBREW_CELLAR/"baz/HEAD-1").mkpath
// 286:       head2 = HOMEBREW_CELLAR/"baz/HEAD-2"
// 287:       head2.mkpath
// 288:       (head2/"INSTALL_RECEIPT.json").write (TEST_FIXTURE_DIR/"receipt.json").read
// 289:     end
// 290:
// 291:     it "resolves the latest kegs with #resolve_latest_keg" do
// 292:       latest_kegs = described_class.new("foo", "bar", "baz").to_latest_kegs
// 293:       expect(latest_kegs.map(&:name)).to eq ["foo", "bar", "baz"]
// 294:       expect(latest_kegs.map { |k| k.version.version.to_s }).to eq ["2.0", "1.0", "HEAD-2"]
// 295:     end
// 296:
// 297:     it "when there are no matching kegs returns an empty array" do
// 298:       expect(described_class.new.to_latest_kegs).to be_empty
// 299:     end
// 300:   end
// 301:
// 302:   describe "#to_kegs_to_casks" do
// 303:     before do
// 304:       (HOMEBREW_CELLAR/"foo/1.0").mkpath
// 305:     end
// 306:
// 307:     it "returns kegs, as well as casks", :needs_macos do
// 308:       stub_cask_loader baz, call_original: true
// 309:
// 310:       kegs, casks = described_class.new("foo", "baz").to_kegs_to_casks
// 311:
// 312:       expect(kegs.map(&:name)).to eq ["foo"]
// 313:       expect(casks).to eq [baz]
// 314:     end
// 315:   end
// 316:
// 317:   describe "#homebrew_tap_cask_names" do
// 318:     specify do
// 319:       expect(described_class.new("foo", "homebrew/cask/local-caffeine").homebrew_tap_cask_names)
// 320:         .to eq ["homebrew/cask/local-caffeine"]
// 321:       expect(described_class.new("foo").homebrew_tap_cask_names).to be_empty
// 322:     end
// 323:   end
// 324:
// 325:   describe "#to_paths" do
// 326:     let(:existing_path) { mktmpdir }
// 327:     let(:formula_path) { Pathname("/path/to/foo.rb") }
// 328:     let(:cask_path) { Pathname("/path/to/baz.rb") }
// 329:
// 330:     before do
// 331:       allow(formula_path).to receive(:exist?).and_return(true)
// 332:       allow(cask_path).to receive(:exist?).and_return(true)
// 333:
// 334:       allow(Formulary).to receive(:path).and_call_original
// 335:       allow(Cask::CaskLoader).to receive(:path).and_call_original
// 336:     end
// 337:
// 338:     it "returns taps, cask formula and existing paths", :needs_macos do
// 339:       expect(Formulary).to receive(:path).with("foo").and_return(formula_path)
// 340:       expect(Cask::CaskLoader).to receive(:path).with("baz").and_return(cask_path)
// 341:
// 342:       expect(described_class.new("homebrew/core", "foo", "baz", existing_path.to_s).to_paths)
// 343:         .to eq [Tap.fetch("homebrew/core").path, formula_path, cask_path, existing_path]
// 344:     end
// 345:
// 346:     it "returns both cask and formula paths if they exist", :needs_macos do
// 347:       expect(Formulary).to receive(:path).with("foo").and_return(formula_path)
// 348:       expect(Cask::CaskLoader).to receive(:path).with("baz").and_return(cask_path)
// 349:
// 350:       expect(described_class.new("foo", "baz").to_paths).to eq [formula_path, cask_path]
// 351:     end
// 352:
// 353:     it "returns only formulae when `only: :formula` is specified" do
// 354:       expect(Formulary).to receive(:path).with("foo").and_return(formula_path)
// 355:
// 356:       expect(described_class.new("foo",
// 357:                                  "baz").to_paths(only: :formula)).to eq [formula_path, Formulary.path("baz")]
// 358:     end
// 359:
// 360:     it "returns only casks when `only: :cask` is specified" do
// 361:       expect(Cask::CaskLoader).to receive(:path).with("foo").and_return(cask_path)
// 362:
// 363:       expect(described_class.new("foo", "baz").to_paths(only: :cask)).to eq [cask_path, Cask::CaskLoader.path("baz")]
// 364:     end
// 365:
// 366:     context "when without_api: true" do
// 367:       it "returns a bare path for an API-known formula when the tap is not installed" do
// 368:         allow(CoreTap.instance).to receive(:installed?).and_return(false)
// 369:
// 370:         require "api"
// 371:         allow(Homebrew::API).to receive(:formula_names).and_return(["foo"])
// 372:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return("foo" => {})
// 373:
// 374:         named_args = described_class.new("foo", without_api: true)
// 375:         paths = named_args.to_paths
// 376:
// 377:         # to_paths returns a bare expanded path (not the core formula path) because
// 378:         # without_api: true sets HOMEBREW_NO_INSTALL_FROM_API=1 which defeats the
// 379:         # API name fallback check. The brew edit command works around this by
// 380:         # auto-tapping before calling to_paths.
// 381:         expect(paths.first.to_s).not_to include("homebrew-core/Formula")
// 382:       end
// 383:     end
// 384:   end
// 385:
// 386:   describe "#to_taps" do
// 387:     it "returns taps" do
// 388:       taps = described_class.new("homebrew/foo", "bar/baz")
// 389:       expect(taps.to_taps.map(&:name)).to eq %w[homebrew/foo bar/baz]
// 390:     end
// 391:
// 392:     it "raises an error for invalid tap" do
// 393:       taps = described_class.new("homebrew/foo", "barbaz")
// 394:       expect { taps.to_taps }.to raise_error(Tap::InvalidNameError, /Invalid tap name/)
// 395:     end
// 396:   end
// 397:
// 398:   describe "#to_installed_taps" do
// 399:     before do
// 400:       (HOMEBREW_REPOSITORY/"Library/Taps/homebrew/homebrew-foo").mkpath
// 401:     end
// 402:
// 403:     it "returns installed taps" do
// 404:       taps = described_class.new("homebrew/foo")
// 405:       expect(taps.to_installed_taps.map(&:name)).to eq %w[homebrew/foo]
// 406:     end
// 407:
// 408:     it "raises an error for uninstalled tap" do
// 409:       taps = described_class.new("homebrew/foo", "bar/baz")
// 410:       expect { taps.to_installed_taps }.to raise_error(TapUnavailableError)
// 411:     end
// 412:
// 413:     it "raises an error for invalid tap" do
// 414:       taps = described_class.new("homebrew/foo", "barbaz")
// 415:       expect { taps.to_installed_taps }.to raise_error(Tap::InvalidNameError, /Invalid tap name/)
// 416:     end
// 417:   end
// 418: end
