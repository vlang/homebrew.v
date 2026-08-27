module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/doctor_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "check_integration_test", :integration_test do` at line 10.
pub fn ruby_doctor_spec_l10_d1_check_integration_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_integration_test', ...args)
}

// Ruby specify `specify "prints json when requested" do` at line 15.
pub fn ruby_doctor_spec_l15_d2_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby specify `specify "check_missing_deps reports formula and cask dependencies", :cask do` at line 22.
pub fn ruby_doctor_spec_l22_d3_check_missing_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_missing_deps', ...args)
}

// Ruby specify `specify "check_for_unreadable_installed_formula skips untrusted installed formulae" do` at line 43.
pub fn ruby_doctor_spec_l43_d4_check_for_unreadable_installed_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_for_unreadable_installed_formula', ...args)
}

// Ruby specify `specify "does not print removed caveats method errors for installed casks", :cask do` at line 57.
pub fn ruby_doctor_spec_l57_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/doctor"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Doctor do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   specify "check_integration_test", :integration_test do
// 11:     expect { brew "doctor", "check_integration_test" }
// 12:       .to output(/This is an integration test/).to_stderr
// 13:   end
// 14:
// 15:   specify "prints json when requested" do
// 16:     cmd = described_class.new(["--json"])
// 17:
// 18:     expect { cmd.run }
// 19:       .to output(/"tier": 1/).to_stdout
// 20:   end
// 21:
// 22:   specify "check_missing_deps reports formula and cask dependencies", :cask do
// 23:     formula = instance_double(Formula, full_name:            "needs-foo",
// 24:                                        missing_dependencies: [instance_double(Dependency, to_s: "foo")])
// 25:     cask = instance_double(Cask::Cask, full_name: "with-depends-on-everything")
// 26:     tab = instance_double(Cask::Tab, runtime_dependencies: {
// 27:       "cask"    => [{ "full_name" => "local-caffeine" }],
// 28:       "formula" => [{ "full_name" => "unar" }],
// 29:     })
// 30:     HOMEBREW_CELLAR.mkpath
// 31:     allow(Formula).to receive(:installed).and_return([formula])
// 32:     allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 33:     allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 34:
// 35:     expect(Homebrew::Diagnostic::Checks.new.check_missing_deps&.to_s)
// 36:       .to include(
// 37:         "Some installed formulae or casks are missing dependencies.",
// 38:         "brew install foo local-caffeine unar",
// 39:         "Run `brew missing` for more details.",
// 40:       )
// 41:   end
// 42:
// 43:   specify "check_for_unreadable_installed_formula skips untrusted installed formulae" do
// 44:     rack = HOMEBREW_CELLAR/"php@7.2"
// 45:     rack.mkpath
// 46:     (rack/"1.0").mkpath
// 47:     allow(Formulary).to receive(:from_rack)
// 48:       .with(rack)
// 49:       .and_raise(
// 50:         Homebrew::UntrustedTapError,
// 51:         "Refusing to load formula shivammathur/php/php@7.2.",
// 52:       )
// 53:
// 54:     expect(Homebrew::Diagnostic::Checks.new.check_for_unreadable_installed_formula).to be_nil
// 55:   end
// 56:
// 57:   specify "does not print removed caveats method errors for installed casks", :cask do
// 58:     cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 59:     installer = InstallHelper.install_with_caskfile(cask)
// 60:     installed_caskfile = installer.metadata_subdir/"#{cask.token}.json"
// 61:     expect(installed_caskfile).to exist
// 62:
// 63:     (installer.metadata_subdir/"#{cask.token}.rb").write(
// 64:       cask_path("local-caffeine").read.sub(
// 65:         /\nend\n\z/,
// 66:         <<~RUBY,
// 67:             caveats do
// 68:               discontinued
// 69:             end
// 70:           end
// 71:         RUBY
// 72:       ),
// 73:     )
// 74:     installed_caskfile.unlink
// 75:
// 76:     (CoreCaskTap.instance.cask_dir/"local-caffeine.rb").unlink
// 77:     CoreCaskTap.instance.clear_cache
// 78:
// 79:     cmd = described_class.new(["check_cask_deprecated_disabled"])
// 80:
// 81:     expect { cmd.run }
// 82:       .to not_to_output(/Unexpected method 'discontinued' called during caveats on Cask local-caffeine\./).to_stderr
// 83:   end
// 84: end
