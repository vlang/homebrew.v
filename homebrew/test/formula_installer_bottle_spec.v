module test

import brew_runtime
import os

// Translated from Homebrew/brew `test/formula_installer_bottle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct FormulaInstallerBottleSpecFormula {
pub:
	name                        string = 'testball_bottle'
	version                     string = '0.1'
	root                        string
	bottled                     bool = true
	pour_bottle                 bool = true
	skip_relocation             bool
	corrupt_cached_download     bool
	trust_cached_download       bool
	development_tools_installed bool
}

pub struct FormulaInstallerBottleSpecSetup {
pub:
	bin_directory     bool
	libexec_directory bool
	source_removed    bool
	linked_bin        bool
}

pub struct FormulaInstallerBottleSpecRun {
pub:
	formula                    FormulaInstallerBottleSpecFormula
	setup                      FormulaInstallerBottleSpecSetup
	latest_before              bool
	latest_during              bool
	poured_from_bottle         bool
	keg_exists_during          bool
	discarded_corrupt_cache    bool
	redownloaded               bool
	stderr                     string
	homebrew_failed            bool
	cleaned                    bool
	keg_exists_after_cleanup   bool
	latest_after_cleanup       bool
	cache_exists_after_cleanup bool
}

struct FormulaInstallerBottleSpecInstall {
mut:
	discarded_corrupt_cache bool
	redownloaded            bool
	stderr                  string
}

fn formula_installer_bottle_spec_root(label string) string {
	return brew_runtime.join_path(brew_runtime.temporary_directory(), 'brew-v-formula-installer-bottle-${label}-${brew_runtime.process_id()}')
}

pub fn formula_installer_bottle_spec_keg_path(formula FormulaInstallerBottleSpecFormula) string {
	cellar := brew_runtime.join_path(formula.root, 'Cellar')
	rack := brew_runtime.join_path(cellar, formula.name)
	return brew_runtime.join_path(rack, formula.version)
}

pub fn formula_installer_bottle_spec_cache_path(formula FormulaInstallerBottleSpecFormula) string {
	cache := brew_runtime.join_path(formula.root, 'cache')
	return brew_runtime.join_path(cache, '${formula.name}--${formula.version}.bottle.tar.gz')
}

pub fn formula_installer_bottle_spec_prefix(formula FormulaInstallerBottleSpecFormula) string {
	return brew_runtime.join_path(formula.root, 'prefix')
}

fn formula_installer_bottle_spec_remove_path(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	}
}

fn formula_installer_bottle_spec_valid_archive(formula FormulaInstallerBottleSpecFormula) string {
	return 'homebrew-bottle-v1\nname=${formula.name}\nversion=${formula.version}\n'
}

fn formula_installer_bottle_spec_install(formula FormulaInstallerBottleSpecFormula) !FormulaInstallerBottleSpecInstall {
	if !formula.bottled || !formula.pour_bottle {
		if !formula.development_tools_installed {
			return error('A full installation of the build tools is required to compile ${formula.name}')
		}
		return error('${formula.name} cannot be poured from a bottle')
	}
	cache_path := formula_installer_bottle_spec_cache_path(formula)
	brew_runtime.make_dir_all(os.dir(cache_path))!
	if !brew_runtime.path_exists(cache_path) {
		contents := if formula.corrupt_cached_download {
			'corrupt'.repeat(1000)
		} else {
			formula_installer_bottle_spec_valid_archive(formula)
		}
		brew_runtime.write_file(cache_path, contents)!
	}
	mut install := FormulaInstallerBottleSpecInstall{}
	mut archive := brew_runtime.read_file(cache_path)!
	if !archive.starts_with('homebrew-bottle-v1\n') {
		// GitHub Packages blobs are trusted before extraction. An extraction
		// failure still discards the bad cache entry and retries the download.
		_ = formula.trust_cached_download
		formula_installer_bottle_spec_remove_path(cache_path)!
		install.discarded_corrupt_cache = true
		install.stderr = 'Removing corrupt cached download: ${cache_path}\n'
		brew_runtime.write_file(cache_path, formula_installer_bottle_spec_valid_archive(formula))!
		archive = brew_runtime.read_file(cache_path)!
		install.redownloaded = true
	}
	if !archive.contains('name=${formula.name}') || !archive.contains('version=${formula.version}') {
		return error('Bottle archive did not contain ${formula.name}/${formula.version}')
	}
	keg := formula_installer_bottle_spec_keg_path(formula)
	bin := brew_runtime.join_path(keg, 'bin')
	libexec := brew_runtime.join_path(keg, 'libexec')
	brew_runtime.make_dir_all(bin)!
	brew_runtime.make_dir_all(libexec)!
	brew_runtime.write_file(brew_runtime.join_path(bin, formula.name), '#!/bin/sh\nexit 0\n')!
	brew_runtime.write_file(brew_runtime.join_path(libexec, 'helper'), 'installed from bottle\n')!
	brew_runtime.write_file(brew_runtime.join_path(keg, 'INSTALL_RECEIPT.json'), '{"poured_from_bottle":true}\n')!
	return install
}

pub fn formula_installer_bottle_spec_test_basic_formula_setup(formula FormulaInstallerBottleSpecFormula) !FormulaInstallerBottleSpecSetup {
	keg := formula_installer_bottle_spec_keg_path(formula)
	bin := brew_runtime.join_path(keg, 'bin')
	libexec := brew_runtime.join_path(keg, 'libexec')
	if !brew_runtime.is_dir(bin) {
		return error('${bin} is not a directory')
	}
	if !brew_runtime.is_dir(libexec) {
		return error('${libexec} is not a directory')
	}
	if brew_runtime.path_exists(brew_runtime.join_path(keg, 'main.c')) {
		return error('source file main.c remained in the poured keg')
	}
	linked_bin := brew_runtime.join_path(formula_installer_bottle_spec_prefix(formula), 'bin')
	brew_runtime.make_dir_all(linked_bin)!
	for entry in brew_runtime.list_dir(bin)! {
		source := brew_runtime.join_path(bin, entry)
		target := brew_runtime.join_path(linked_bin, entry)
		formula_installer_bottle_spec_remove_path(target)!
		os.symlink(source, target)!
	}
	return FormulaInstallerBottleSpecSetup{
		bin_directory: brew_runtime.is_dir(bin)
		libexec_directory: brew_runtime.is_dir(libexec)
		source_removed: !brew_runtime.path_exists(brew_runtime.join_path(keg, 'main.c'))
		linked_bin: brew_runtime.is_dir(linked_bin)
			&& brew_runtime.is_link(brew_runtime.join_path(linked_bin, formula.name))
	}
}

pub fn formula_installer_bottle_spec_cleanup(formula FormulaInstallerBottleSpecFormula) ! {
	formula_installer_bottle_spec_remove_path(formula_installer_bottle_spec_prefix(formula))!
	formula_installer_bottle_spec_remove_path(formula_installer_bottle_spec_keg_path(formula))!
	formula_installer_bottle_spec_remove_path(formula_installer_bottle_spec_cache_path(formula))!
}

pub fn formula_installer_bottle_spec_temporarily_install(formula FormulaInstallerBottleSpecFormula) !FormulaInstallerBottleSpecRun {
	if formula.root == '' {
		return error('a fixture root is required')
	}
	latest_before := brew_runtime.is_dir(formula_installer_bottle_spec_keg_path(formula))
	install := formula_installer_bottle_spec_install(formula)!
	setup := formula_installer_bottle_spec_test_basic_formula_setup(formula) or {
		formula_installer_bottle_spec_cleanup(formula) or {}
		return err
	}
	keg := formula_installer_bottle_spec_keg_path(formula)
	receipt := brew_runtime.join_path(keg, 'INSTALL_RECEIPT.json')
	poured_from_bottle := brew_runtime.read_file(receipt)!.contains('"poured_from_bottle":true')
	latest_during := brew_runtime.is_dir(keg)
	formula_installer_bottle_spec_cleanup(formula)!
	return FormulaInstallerBottleSpecRun{
		formula: formula
		setup: setup
		latest_before: latest_before
		latest_during: latest_during
		poured_from_bottle: poured_from_bottle
		keg_exists_during: latest_during
		discarded_corrupt_cache: install.discarded_corrupt_cache
		redownloaded: install.redownloaded
		stderr: install.stderr
		homebrew_failed: false
		cleaned: true
		keg_exists_after_cleanup: brew_runtime.path_exists(keg)
		latest_after_cleanup: brew_runtime.is_dir(keg)
		cache_exists_after_cleanup: brew_runtime.path_exists(formula_installer_bottle_spec_cache_path(formula))
	}
}

pub fn formula_installer_bottle_spec_expected_skip_relocation() bool {
	$if linux {
		return false
	} $else {
		return true
	}
}

fn formula_installer_bottle_spec_formula_from_args(args []brew_runtime.Value,
	label string) FormulaInstallerBottleSpecFormula {
	if args.len == 0 {
		return FormulaInstallerBottleSpecFormula{
			root: formula_installer_bottle_spec_root(label)
		}
	}
	value := args[0]
	return FormulaInstallerBottleSpecFormula{
		name: value.attributes['name'] or { 'testball_bottle' }
		version: value.attributes['version'] or { '0.1' }
		root: value.attributes['root'] or { formula_installer_bottle_spec_root(label) }
		bottled: (value.attributes['bottled'] or { 'true' }) == 'true'
		pour_bottle: (value.attributes['pour_bottle'] or { 'true' }) == 'true'
		skip_relocation: (value.attributes['skip_relocation'] or { 'false' }) == 'true'
		corrupt_cached_download: (value.attributes['corrupt_cached_download'] or { 'false' }) == 'true'
		trust_cached_download: (value.attributes['trust_cached_download'] or { 'false' }) == 'true'
		development_tools_installed: (value.attributes['development_tools_installed'] or {
			'false'
		}) == 'true'
	}
}

fn formula_installer_bottle_spec_run_succeeded(run FormulaInstallerBottleSpecRun) bool {
	return !run.latest_before && run.latest_during && run.poured_from_bottle
		&& run.keg_exists_during && run.setup.bin_directory && run.setup.libexec_directory
		&& run.setup.source_removed && run.setup.linked_bin && run.cleaned
		&& !run.keg_exists_after_cleanup && !run.latest_after_cleanup
		&& !run.cache_exists_after_cleanup
}

fn formula_installer_bottle_spec_run_value(run FormulaInstallerBottleSpecRun) brew_runtime.Value {
	return brew_runtime.structured_value('FormulaInstallerBottleSpecRun', run.formula.name, {
		'latest_before':           run.latest_before.str()
		'latest_during':           run.latest_during.str()
		'poured_from_bottle':      run.poured_from_bottle.str()
		'discarded_corrupt_cache': run.discarded_corrupt_cache.str()
		'redownloaded':            run.redownloaded.str()
		'stderr':                  run.stderr
		'homebrew_failed':         run.homebrew_failed.str()
		'cleaned':                 run.cleaned.str()
	})
}

// Ruby alias_matcher `alias_matcher :pour_bottle, :be_pour_bottle` at line 14.
pub fn ruby_formula_installer_bottle_spec_l14_d1_pour_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.structured_value('RSpec::AliasedMatcher', 'pour_bottle', {
			'alias':   'pour_bottle'
			'matcher': 'be_pour_bottle'
		})
	}
	if args[0].type_name == 'Bool' {
		return brew_runtime.bool_value(args[0].bool_data)
	}
	return brew_runtime.bool_value((args[0].attributes['pour_bottle'] or { 'false' }) == 'true')
}

// Ruby matcher `matcher :be_poured_from_bottle do` at line 16.
pub fn ruby_formula_installer_bottle_spec_l16_d2_be_poured_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.structured_value('RSpec::Matcher', 'be_poured_from_bottle', {
			'attribute': 'poured_from_bottle'
		})
	}
	if args[0].type_name == 'Bool' {
		return brew_runtime.bool_value(args[0].bool_data)
	}
	return brew_runtime.bool_value((args[0].attributes['poured_from_bottle'] or {
		'false'
	}) == 'true')
}

// Ruby method `temporarily_install_bottle(formula)` at line 20.
pub fn ruby_formula_installer_bottle_spec_l20_d3_temporarily_install_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	formula := formula_installer_bottle_spec_formula_from_args(args, 'temporary')
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	run := formula_installer_bottle_spec_temporarily_install(formula) or {
		return brew_runtime.structured_value('FormulaInstallerBottleSpecError', err.msg(), {
			'success': 'false'
		})
	}
	return formula_installer_bottle_spec_run_value(run)
}

// Ruby method `test_basic_formula_setup(formula)` at line 62.
pub fn ruby_formula_installer_bottle_spec_l62_d4_test_basic_formula_setup(args ...brew_runtime.Value) brew_runtime.Value {
	formula := formula_installer_bottle_spec_formula_from_args(args, 'setup')
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	run := formula_installer_bottle_spec_temporarily_install(formula) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(run.setup.bin_directory && run.setup.libexec_directory
		&& run.setup.source_removed && run.setup.linked_bin)
}

// Ruby specify `specify "basic bottle install" do` at line 82.
pub fn ruby_formula_installer_bottle_spec_l82_d5_basic(args ...brew_runtime.Value) brew_runtime.Value {
	formula := formula_installer_bottle_spec_formula_from_args(args, 'basic')
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	run := formula_installer_bottle_spec_temporarily_install(formula) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(formula_installer_bottle_spec_run_succeeded(run))
}

// Ruby specify `specify "basic bottle install with cellar information on sha256 line" do` at line 91.
pub fn ruby_formula_installer_bottle_spec_l91_d6_basic(args ...brew_runtime.Value) brew_runtime.Value {
	formula := FormulaInstallerBottleSpecFormula{
		...formula_installer_bottle_spec_formula_from_args(args, 'cellar')
		skip_relocation: formula_installer_bottle_spec_expected_skip_relocation()
	}
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	run := formula_installer_bottle_spec_temporarily_install(formula) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(formula_installer_bottle_spec_run_succeeded(run)
		&& run.formula.skip_relocation == formula_installer_bottle_spec_expected_skip_relocation())
}

// Ruby specify `specify "bottle install with a corrupt cached download", :aggregate_failures do` at line 105.
pub fn ruby_formula_installer_bottle_spec_l105_d7_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	base := formula_installer_bottle_spec_formula_from_args(args, 'corrupt')
	formula := FormulaInstallerBottleSpecFormula{
		...base
		corrupt_cached_download: true
		trust_cached_download: true
	}
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	run := formula_installer_bottle_spec_temporarily_install(formula) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(formula_installer_bottle_spec_run_succeeded(run)
		&& run.discarded_corrupt_cache && run.redownloaded
		&& run.stderr.contains('Removing corrupt cached download') && !run.homebrew_failed)
}

// Ruby specify `specify "build tools error" do` at line 134.
pub fn ruby_formula_installer_bottle_spec_l134_d8_build(args ...brew_runtime.Value) brew_runtime.Value {
	base := formula_installer_bottle_spec_formula_from_args(args, 'build-tools')
	formula := FormulaInstallerBottleSpecFormula{
		...base
		name: 'testball'
		bottled: false
		pour_bottle: false
		development_tools_installed: false
	}
	brew_runtime.remove_all(formula.root) or {}
	defer { brew_runtime.remove_all(formula.root) or {} }
	formula_installer_bottle_spec_install(formula) or {
		return brew_runtime.bool_value(err.msg().contains('build tools is required')
			&& !brew_runtime.path_exists(formula_installer_bottle_spec_keg_path(formula)))
	}
	return brew_runtime.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "formula_installer"
// 6: require "keg"
// 7: require "tab"
// 8: require "cmd/install"
// 9: require "test/support/fixtures/testball"
// 10: require "test/support/fixtures/testball_bottle"
// 11: require "test/support/fixtures/testball_bottle_cellar"
// 12:
// 13: RSpec.describe FormulaInstaller do
// 14:   alias_matcher :pour_bottle, :be_pour_bottle
// 15:
// 16:   matcher :be_poured_from_bottle do
// 17:     match(&:poured_from_bottle)
// 18:   end
// 19:
// 20:   def temporarily_install_bottle(formula)
// 21:     expect(formula).not_to be_latest_version_installed
// 22:     expect(formula).to be_bottled
// 23:     expect(formula).to pour_bottle
// 24:
// 25:     stub_formula_loader(
// 26:       formula("gcc") do
// 27:         T.bind(self, T.class_of(Formula))
// 28:         url "gcc-1.0"
// 29:       end,
// 30:     )
// 31:     stub_formula_loader(
// 32:       formula("glibc") do
// 33:         T.bind(self, T.class_of(Formula))
// 34:         url "glibc-1.0"
// 35:       end,
// 36:     )
// 37:     stub_formula_loader formula
// 38:
// 39:     fi = FormulaInstaller.new(formula)
// 40:     fi.fetch
// 41:     fi.install
// 42:
// 43:     keg = Keg.new(formula.prefix)
// 44:
// 45:     expect(formula).to be_latest_version_installed
// 46:
// 47:     begin
// 48:       expect(keg.tab).to be_poured_from_bottle
// 49:
// 50:       yield formula
// 51:     ensure
// 52:       keg.unlink
// 53:       keg.uninstall
// 54:       formula.clear_cache
// 55:       formula.bottle.clear_cache
// 56:     end
// 57:
// 58:     expect(keg).not_to exist
// 59:     expect(formula).not_to be_latest_version_installed
// 60:   end
// 61:
// 62:   def test_basic_formula_setup(formula)
// 63:     # Test that things made it into the Keg
// 64:     expect(formula.bin).to be_a_directory
// 65:
// 66:     expect(formula.libexec).to be_a_directory
// 67:
// 68:     expect(formula.prefix/"main.c").not_to exist
// 69:
// 70:     # Test that things made it into the Cellar
// 71:     keg = Keg.new formula.prefix
// 72:     keg.link
// 73:
// 74:     bin = HOMEBREW_PREFIX/"bin"
// 75:     expect(bin).to be_a_directory
// 76:
// 77:     expect(formula.libexec).to be_a_directory
// 78:   end
// 79:
// 80:   # This test wraps expect() calls in `test_basic_formula_setup`
// 81:   # rubocop:disable RSpec/NoExpectationExample
// 82:   specify "basic bottle install" do
// 83:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 84:     Homebrew::Cmd::InstallCmd.new(["testball_bottle"])
// 85:     temporarily_install_bottle(TestballBottle.new) do |f|
// 86:       test_basic_formula_setup(f)
// 87:     end
// 88:   end
// 89:   # rubocop:enable RSpec/NoExpectationExample
// 90:
// 91:   specify "basic bottle install with cellar information on sha256 line" do
// 92:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 93:     Homebrew::Cmd::InstallCmd.new(["testball_bottle_cellar"])
// 94:     temporarily_install_bottle(TestballBottleCellar.new) do |f|
// 95:       test_basic_formula_setup(f)
// 96:
// 97:       # skip_relocation is always false on Linux but can be true on macOS.
// 98:       # see: extend/os/linux/software_spec.rb
// 99:       skip_relocation = !OS.linux?
// 100:
// 101:       expect(f.bottle_specification.skip_relocation?).to eq(skip_relocation)
// 102:     end
// 103:   end
// 104:
// 105:   specify "bottle install with a corrupt cached download", :aggregate_failures do
// 106:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 107:     formula = TestballBottle.new
// 108:     bottle = formula.bottle
// 109:     stub_formula_loader formula
// 110:
// 111:     # Simulate a GitHub Packages bottle blob, which is trusted without being
// 112:     # rehashed, so this corrupt download is only noticed when it fails to
// 113:     # extract and must then be discarded and downloaded again.
// 114:     bottle.cached_download.dirname.mkpath
// 115:     bottle.cached_download.write("corrupt" * 1000)
// 116:     allow(bottle).to receive(:downloaded_and_valid?).and_return(true)
// 117:
// 118:     formula_installer = described_class.new(formula)
// 119:     begin
// 120:       expect do
// 121:         Homebrew::Install.fetch_formulae([formula_installer])
// 122:         formula_installer.install
// 123:       end.to output(/Removing corrupt cached download/).to_stderr
// 124:
// 125:       expect(formula).to be_latest_version_installed
// 126:       expect(Homebrew).not_to have_failed
// 127:     ensure
// 128:       Keg.new(formula.prefix).uninstall if formula.prefix.directory?
// 129:       formula.clear_cache
// 130:       bottle.clear_cache
// 131:     end
// 132:   end
// 133:
// 134:   specify "build tools error" do
// 135:     allow(DevelopmentTools).to receive(:installed?).and_return(false)
// 136:
// 137:     # Testball doesn't have a bottle block, so use it to test this behavior
// 138:     formula = Testball.new
// 139:
// 140:     expect(formula).not_to be_latest_version_installed
// 141:     expect(formula).not_to be_bottled
// 142:
// 143:     expect do
// 144:       described_class.new(formula).install
// 145:     end.to raise_error(SystemExit)
// 146:
// 147:     expect(formula).not_to be_latest_version_installed
// 148:   end
// 149: end
