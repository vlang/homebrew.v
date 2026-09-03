module cmd

import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/missing_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints missing dependencies", :integration_test, :no_api do` at line 10.
pub fn ruby_missing_spec_l10_d1_prints() bool {
	result := brew_cmd.missing_command([
		brew_cmd.MissingCommandPackage{ full_name: 'bar', display_name: 'bar', missing_dependencies: [
			'foo',
		] },
	], [], true)
	return result.failed && result.output == 'foo\n'
}

// Ruby it `it "prints missing cask dependencies", :cask, :no_api do` at line 28.
pub fn ruby_missing_spec_l28_d2_prints() bool {
	result := brew_cmd.missing_command([], [missing_everything_cask()], true)
	return result.failed && result.output == 'local-caffeine unar\n'
}

// Ruby it `it "prints missing cask dependencies for named casks", :cask, :no_api do` at line 46.
pub fn ruby_missing_spec_l46_d3_prints() bool {
	result := brew_cmd.missing_command([], [missing_everything_cask()], true)
	return result.failed && result.output == 'local-caffeine unar\n'
}

fn missing_everything_cask() brew_cmd.MissingCommandPackage {
	return brew_cmd.MissingCommandPackage{
		full_name: 'with-depends-on-everything'
		display_name: 'with-depends-on-everything'
		missing_dependencies: ['local-caffeine', 'unar']
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/missing"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Missing do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "prints missing dependencies", :integration_test, :no_api do
// 11:     setup_test_formula "foo"
// 12:     setup_test_formula "bar"
// 13:
// 14:     (HOMEBREW_CELLAR/"bar/1.0").mkpath
// 15:     (HOMEBREW_CELLAR/"bar/1.0/INSTALL_RECEIPT.json").write(
// 16:       JSON.generate({
// 17:         "homebrew_version"     => "1.1.6",
// 18:         "runtime_dependencies" => [{ "full_name" => "foo", "version" => "1.0" }],
// 19:       }),
// 20:     )
// 21:
// 22:     expect { brew "missing" }
// 23:       .to output("foo\n").to_stdout
// 24:       .and not_to_output.to_stderr
// 25:       .and be_a_failure
// 26:   end
// 27:
// 28:   it "prints missing cask dependencies", :cask, :no_api do
// 29:     cask = instance_double(Cask::Cask, full_name: "with-depends-on-everything",
// 30:                                        to_s:      "with-depends-on-everything")
// 31:     tab = instance_double(Cask::Tab, runtime_dependencies: {
// 32:       "cask"    => [{ "full_name" => "local-caffeine" }],
// 33:       "formula" => [{ "full_name" => "unar" }],
// 34:     })
// 35:     HOMEBREW_CELLAR.mkpath
// 36:     allow(Formula).to receive(:installed).and_return([])
// 37:     allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 38:     allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 39:
// 40:     expect { described_class.new([]).run }
// 41:       .to output("local-caffeine unar\n").to_stdout
// 42:
// 43:     expect(Homebrew).to have_failed
// 44:   end
// 45:
// 46:   it "prints missing cask dependencies for named casks", :cask, :no_api do
// 47:     cmd = described_class.new(["with-depends-on-everything"])
// 48:     cask = instance_double(Cask::Cask, full_name: "with-depends-on-everything",
// 49:                                        to_s:      "with-depends-on-everything")
// 50:     tab = instance_double(Cask::Tab, runtime_dependencies: {
// 51:       "cask"    => [{ "full_name" => "local-caffeine" }],
// 52:       "formula" => [{ "full_name" => "unar" }],
// 53:     })
// 54:     HOMEBREW_CELLAR.mkpath
// 55:     allow(cmd.args.named).to receive(:to_resolved_formulae_to_casks).and_return([[], [cask]].map(&:freeze).freeze)
// 56:     allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 57:
// 58:     expect { cmd.run }
// 59:       .to output("local-caffeine unar\n").to_stdout
// 60:
// 61:     expect(Homebrew).to have_failed
// 62:   end
// 63: end
