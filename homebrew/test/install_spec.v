module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/install_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "::perform_preinstall_checks runs non-fatal preinstall diagnostics" do` at line 10.
pub fn ruby_install_spec_l10_d1_perform_preinstall_checks(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.perform_preinstall_checks(homebrew.InstallPreinstallContext{}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.diagnostics == [
		homebrew.InstallDiagnosticCall{
			kind: .supported_configuration_checks
		},
		homebrew.InstallDiagnosticCall{
			kind: .preinstall_checks
		},
		homebrew.InstallDiagnosticCall{
			kind: .fatal_preinstall_checks
			fatal: true
		},
	])
}

// Ruby it `it "skips formulae whose fetch steps raise and continues with the rest" do` at line 29.
pub fn ruby_install_spec_l29_d2_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.fetch_formulae([
		homebrew.FormulaInstallCandidate{
			name: 'good-bottle'
			full_name: 'good-bottle'
		},
		homebrew.FormulaInstallCandidate{
			name: 'bad-bottle'
			full_name: 'bad-bottle'
			enqueue_fetch_error: 'unexpected failure'
		},
	], homebrew.InstallFormulaFetchOptions{})
	return ruby.bool_value(result.candidates.map(it.name) == ['good-bottle'] && result.errors == [
		'bad-bottle: unexpected failure',
	] && result.shutdown)
}

// Ruby it `it "skips the formula whose download failed and keeps the rest" do` at line 52.
pub fn ruby_install_spec_l52_d3_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.reject_failed_downloads([
		homebrew.FormulaInstallCandidate{
			name: 'bad-bottle'
		},
		homebrew.FormulaInstallCandidate{
			name: 'good-bottle'
		},
	], ['bad-bottle'])
	return ruby.bool_value(result.map(it.name) == ['good-bottle'])
}

// Ruby it `it "skips a formula whose install raises and continues with the rest" do` at line 72.
pub fn ruby_install_spec_l72_d4_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.install_formulae([
		homebrew.FormulaInstallCandidate{
			name: 'bad-bottle'
			full_name: 'bad-bottle'
			install_error: 'gzip decompression failed'
		},
		homebrew.FormulaInstallCandidate{
			name: 'good-bottle'
			full_name: 'good-bottle'
		},
	], homebrew.InstallFormulaBatchOptions{})
	return ruby.bool_value(result.installed == ['good-bottle'] && result.cleaned == [
		'good-bottle',
	] && result.errors == ['bad-bottle: gzip decompression failed'])
}

// Ruby it `it "skips casks whose enqueue raises and continues with the rest" do` at line 92.
pub fn ruby_install_spec_l92_d5_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.enqueue_cask_installers([
		homebrew.CaskInstallCandidate{
			full_name: 'bad-cask'
			enqueue_error: 'bad URI (is not URI?): "https://example.com/bad -cask.dmg"'
		},
		homebrew.CaskInstallCandidate{
			full_name: 'good-cask'
		},
	])
	return ruby.bool_value(result.enqueued == ['good-cask'] && result.errors.len == 1 && result.errors[0].starts_with('bad-cask: bad URI'))
}

// Ruby it `it "splits fresh installs and upgrades under separate headers" do` at line 112.
pub fn ruby_install_spec_l112_d6_splits(args ...ruby.Value) ruby.Value {
	_ = args
	output := homebrew.dry_run_dependencies_plan('testball', [
		homebrew.InstallDependencyPlan{
			name: 'fresh-dep'
		},
		homebrew.InstallDependencyPlan{
			name: 'installed-dep'
			installed: true
		},
	], [])
	return ruby.bool_value(output == '==> Would install 1 dependency for testball:\nfresh-dep\n==> Would upgrade 1 dependency for testball:\ninstalled-dep\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/installer"
// 5: require "install"
// 6: require "dependency"
// 7: require "test/support/fixtures/testball"
// 8:
// 9: RSpec.describe Homebrew::Install do
// 10:   specify "::perform_preinstall_checks runs non-fatal preinstall diagnostics" do
// 11:     allow(described_class).to receive(:check_prefix)
// 12:     allow(described_class).to receive(:check_cpu)
// 13:     allow(described_class).to receive(:attempt_directory_creation)
// 14:
// 15:     expect(Homebrew::Diagnostic).to receive(:checks)
// 16:       .with(:supported_configuration_checks, fatal: false)
// 17:       .ordered
// 18:     expect(Homebrew::Diagnostic).to receive(:checks)
// 19:       .with(:preinstall_checks, fatal: false)
// 20:       .ordered
// 21:     expect(Homebrew::Diagnostic).to receive(:checks)
// 22:       .with(:fatal_preinstall_checks)
// 23:       .ordered
// 24:
// 25:     described_class.perform_preinstall_checks
// 26:   end
// 27:
// 28:   describe "::fetch_formulae" do
// 29:     it "skips formulae whose fetch steps raise and continues with the rest" do
// 30:       good_fi = FormulaInstaller.new(formula("good-bottle") do
// 31:         T.bind(self, T.class_of(Formula))
// 32:         url "foo-1.0"
// 33:       end)
// 34:       bad_fi = FormulaInstaller.new(formula("bad-bottle") do
// 35:         T.bind(self, T.class_of(Formula))
// 36:         url "foo-1.0"
// 37:       end)
// 38:       [good_fi, bad_fi].each do |fi|
// 39:         allow(fi).to receive(:prelude_fetch)
// 40:         allow(fi).to receive(:prelude)
// 41:       end
// 42:       allow(good_fi).to receive(:enqueue_fetch)
// 43:       allow(bad_fi).to receive(:enqueue_fetch).and_raise("unexpected failure")
// 44:
// 45:       expect do
// 46:         expect(described_class.fetch_formulae([good_fi, bad_fi])).to eq([good_fi])
// 47:       end.to output(/Error: bad-bottle: unexpected failure/).to_stderr
// 48:     end
// 49:   end
// 50:
// 51:   describe "::reject_failed_downloads" do
// 52:     it "skips the formula whose download failed and keeps the rest" do
// 53:       bottle_spec = BottleSpecification.new
// 54:       bottle_spec.sha256(arm64_big_sur: "deadbeef" * 8)
// 55:       failed_bottle = Bottle.new(nil, bottle_spec, Utils::Bottles::Tag.from_symbol(:arm64_big_sur),
// 56:                                  name: "bad-bottle", pkg_version: PkgVersion.new(Version.new("1.0"), 0))
// 57:       bad_fi = instance_double(FormulaInstaller, formula: formula("bad-bottle") do
// 58:         T.bind(self, T.class_of(Formula))
// 59:         url "foo-1.0"
// 60:       end)
// 61:       good_fi = instance_double(FormulaInstaller, formula: formula("good-bottle") do
// 62:         T.bind(self, T.class_of(Formula))
// 63:         url "foo-1.0"
// 64:       end)
// 65:       download_queue = instance_double(Homebrew::DownloadQueue, failed_downloads: [failed_bottle])
// 66:
// 67:       expect(described_class.reject_failed_downloads([bad_fi, good_fi], download_queue:)).to eq([good_fi])
// 68:     end
// 69:   end
// 70:
// 71:   describe "::install_formulae" do
// 72:     it "skips a formula whose install raises and continues with the rest" do
// 73:       bad_fi = instance_double(FormulaInstaller, formula: formula("bad-bottle") do
// 74:         T.bind(self, T.class_of(Formula))
// 75:         url "foo-1.0"
// 76:       end)
// 77:       good_fi = instance_double(FormulaInstaller, formula: formula("good-bottle") do
// 78:         T.bind(self, T.class_of(Formula))
// 79:         url "foo-1.0"
// 80:       end)
// 81:       allow(Homebrew::Cleanup).to receive(:install_formula_clean!)
// 82:       allow(described_class).to receive(:install_formula).with(bad_fi, upgrade: false)
// 83:                                                          .and_raise("gzip decompression failed")
// 84:       expect(described_class).to receive(:install_formula).with(good_fi, upgrade: false)
// 85:
// 86:       expect { described_class.install_formulae([bad_fi, good_fi]) }
// 87:         .to output(/Error: bad-bottle: gzip decompression failed/).to_stderr
// 88:     end
// 89:   end
// 90:
// 91:   describe "::enqueue_cask_installers" do
// 92:     it "skips casks whose enqueue raises and continues with the rest" do
// 93:       bad_cask = instance_double(Cask::Cask, to_s: "bad-cask")
// 94:       bad_installer = instance_double(Cask::Installer, cask:                                bad_cask,
// 95:                                                        source_download_requires_pre_fetch?: false)
// 96:       allow(bad_installer).to receive(:enqueue_downloads)
// 97:         .and_raise(URI::InvalidURIError, 'bad URI (is not URI?): "https://example.com/bad -cask.dmg"')
// 98:       good_installer = instance_double(Cask::Installer, source_download_requires_pre_fetch?: false)
// 99:       expect(good_installer).to receive(:enqueue_downloads)
// 100:
// 101:       download_queue = Homebrew::DownloadQueue.new(pour: true)
// 102:       begin
// 103:         expect { described_class.enqueue_cask_installers([bad_installer, good_installer], download_queue:) }
// 104:           .to output(/Error: bad-cask: bad URI/).to_stderr
// 105:       ensure
// 106:         download_queue.shutdown
// 107:       end
// 108:     end
// 109:   end
// 110:
// 111:   describe "::print_dry_run_dependencies" do
// 112:     it "splits fresh installs and upgrades under separate headers" do
// 113:       fresh = formula("fresh-dep") do
// 114:         T.bind(self, T.class_of(Formula))
// 115:         url "foo-1.0"
// 116:       end
// 117:       installed = formula("installed-dep") do
// 118:         T.bind(self, T.class_of(Formula))
// 119:         url "foo-1.0"
// 120:       end
// 121:       allow(fresh).to receive(:any_version_installed?).and_return(false)
// 122:       allow(installed).to receive(:any_version_installed?).and_return(true)
// 123:       deps = [
// 124:         instance_double(Dependency, to_formula: fresh),
// 125:         instance_double(Dependency, to_formula: installed),
// 126:       ]
// 127:
// 128:       expect { described_class.print_dry_run_dependencies(Testball.new, deps, &:name) }
// 129:         .to output(/Would install 1 dependency.*fresh-dep.*Would upgrade 1 dependency.*installed-dep/m).to_stdout
// 130:     end
// 131:   end
// 132: end
