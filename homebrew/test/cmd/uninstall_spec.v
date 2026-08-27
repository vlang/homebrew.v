module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/uninstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uninstalls a given Formula and Cask path", :cask, :integration_test do` at line 10.
pub fn ruby_uninstall_spec_l10_d1_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstalls', ...args)
}

// Ruby it `it "catches cask uninstall errors and sets Homebrew.failed" do` at line 50.
pub fn ruby_uninstall_spec_l50_d2_catches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('catches', ...args)
}

// Ruby it `it "untrusts uninstalled casks" do` at line 68.
pub fn ruby_uninstall_spec_l68_d3_untrusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('untrusts', ...args)
}

// Ruby it `it "does not read an untrusted installed cask when uninstalling", :cask, :trust_store do` at line 84.
pub fn ruby_uninstall_spec_l84_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reads installed JSON cask metadata when uninstalling from an untrusted tap", :cask, :trust_store do` at line 123.
pub fn ruby_uninstall_spec_l123_d5_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/uninstall"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::UninstallCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "uninstalls a given Formula and Cask path", :cask, :integration_test do
// 11:     tap = CoreCaskTap.instance
// 12:     cask_file = tap.cask_dir/"l/local-caffeine.rb"
// 13:     cask_file.dirname.mkpath
// 14:     FileUtils.cp cask_path("local-caffeine"), cask_file
// 15:     tap.clear_cache
// 16:     appdir = mktmpdir
// 17:
// 18:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 19:
// 20:     expect(HOMEBREW_CELLAR/"testball").to exist
// 21:     expect { brew "uninstall", "--force", "testball" }
// 22:       .to output(/Uninstalling testball/).to_stdout
// 23:       .and not_to_output.to_stderr
// 24:       .and be_a_success
// 25:     expect(HOMEBREW_CELLAR/"testball").not_to exist
// 26:
// 27:     Dir.chdir(tap.path) do
// 28:       ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 29:       ENV["HOMEBREW_REQUIRE_TAP_TRUST"] = "1"
// 30:       ENV["HOMEBREW_NO_INSTALL_FROM_API"] = nil
// 31:       brew_env = { "HOMEBREW_SORBET_RUNTIME" => nil, "HOMEBREW_SORBET_RECURSIVE" => nil }
// 32:       expect do
// 33:         brew "install", "--cask", "--no-ask", "--appdir=#{appdir}", "./Casks/l/local-caffeine.rb", brew_env
// 34:       end
// 35:         .to output(/local-caffeine was successfully installed/).to_stdout
// 36:         .and be_a_success
// 37:
// 38:       expect { brew "uninstall", "--cask", "./Casks/l/local-caffeine.rb", brew_env }
// 39:         .to output(/Uninstalling Cask local-caffeine/).to_stdout
// 40:         .and not_to_output.to_stderr
// 41:         .and be_a_success
// 42:     end
// 43:
// 44:     expect(appdir/"Caffeine.app").not_to exist
// 45:     expect(Cask::Caskroom.cask_installed?("local-caffeine")).to be(false)
// 46:   ensure
// 47:     FileUtils.rm_rf tap.path if tap
// 48:   end
// 49:
// 50:   it "catches cask uninstall errors and sets Homebrew.failed" do
// 51:     allow(Cask::Uninstall).to receive(:uninstall_casks).and_raise(Cask::CaskError.new("test cask error"))
// 52:     allow(Cask::Uninstall).to receive(:check_dependent_casks)
// 53:     allow(Homebrew::Uninstall).to receive(:uninstall_kegs)
// 54:     allow(Homebrew::Cleanup).to receive(:autoremove)
// 55:
// 56:     cask = Cask::Cask.new("test-cask")
// 57:     cmd = described_class.new(["test-cask"])
// 58:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable).and_return([cask])
// 59:
// 60:     expect { cmd.run }
// 61:       .to output(/test cask error/).to_stderr
// 62:
// 63:     expect(Homebrew).to have_failed
// 64:   ensure
// 65:     Homebrew.failed = false
// 66:   end
// 67:
// 68:   it "untrusts uninstalled casks" do
// 69:     cask = Cask::Cask.new("test-cask")
// 70:     allow(cask).to receive(:full_name).and_return("thirdparty/foo/test-cask")
// 71:     cmd = described_class.new(["thirdparty/foo/test-cask"])
// 72:     allow(cmd.args.named).to receive(:to_formulae_and_casks_and_unavailable).and_return([cask])
// 73:     allow(Cask::Uninstall).to receive(:check_dependent_casks)
// 74:     allow(Cask::Uninstall).to receive(:uninstall_casks)
// 75:     allow(Homebrew::Uninstall).to receive(:uninstall_kegs)
// 76:     allow(Homebrew::Cleanup).to receive(:autoremove)
// 77:
// 78:     expect(Homebrew::Trust).to receive(:untrust!)
// 79:       .with(:cask, "thirdparty/foo/test-cask")
// 80:
// 81:     cmd.run
// 82:   end
// 83:
// 84:   it "does not read an untrusted installed cask when uninstalling", :cask, :trust_store do
// 85:     tap = Tap.fetch("untrusted", "tap")
// 86:     full_name = "untrusted/tap/local-caffeine"
// 87:     cask_file = tap.cask_dir/"local-caffeine.rb"
// 88:     cask_file.dirname.mkpath
// 89:     FileUtils.cp cask_path("local-caffeine"), cask_file
// 90:     tap.clear_cache
// 91:
// 92:     cask = with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 93:       Cask::CaskLoader.load(full_name).tap { |cask| Cask::Installer.new(cask).install }
// 94:     end
// 95:     cask_file.write <<~RUBY
// 96:       raise "untrusted tap cask evaluated"
// 97:     RUBY
// 98:     installed_caskfile = cask.installed_caskfile
// 99:     (installed_caskfile.dirname/"local-caffeine.rb").write <<~RUBY
// 100:       raise "untrusted installed cask evaluated"
// 101:     RUBY
// 102:     installed_caskfile.unlink
// 103:     allow(Homebrew::Cleanup).to receive(:autoremove)
// 104:
// 105:     original_argv = ARGV.dup
// 106:     begin
// 107:       ARGV.replace(["--cask", "--force", full_name])
// 108:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_NO_REQUIRE_TAP_TRUST: nil) do
// 109:         expect { described_class.new(["--cask", "--force", full_name]).run }
// 110:           .to output(/Uninstalling Cask local-caffeine/).to_stdout
// 111:           .and output(/Skipping loading untrusted Cask #{full_name}; uninstalling recorded artifacts only/).to_stderr
// 112:           .and not_to_output(/untrusted .* cask evaluated/).to_stderr
// 113:       end
// 114:     ensure
// 115:       ARGV.replace(original_argv)
// 116:       FileUtils.rm_rf tap.path.parent
// 117:     end
// 118:
// 119:     expect(Pathname(cask.config.appdir).join("Caffeine.app")).not_to exist
// 120:     expect(cask).not_to be_installed
// 121:   end
// 122:
// 123:   it "reads installed JSON cask metadata when uninstalling from an untrusted tap", :cask, :trust_store do
// 124:     tap = Tap.fetch("untrusted", "json")
// 125:     full_name = "untrusted/json/local-caffeine"
// 126:     cask_file = tap.cask_dir/"local-caffeine.rb"
// 127:     cask_file.dirname.mkpath
// 128:     FileUtils.cp cask_path("local-caffeine"), cask_file
// 129:     tap.clear_cache
// 130:
// 131:     cask = with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 132:       Cask::CaskLoader.load(full_name).tap { |cask| Cask::Installer.new(cask).install }
// 133:     end
// 134:     cask_file.write <<~RUBY
// 135:       raise "untrusted tap cask evaluated"
// 136:     RUBY
// 137:     (cask.installed_caskfile.dirname/"local-caffeine.rb").write <<~RUBY
// 138:       raise "untrusted installed cask evaluated"
// 139:     RUBY
// 140:     allow(Homebrew::Cleanup).to receive(:autoremove)
// 141:
// 142:     original_argv = ARGV.dup
// 143:     begin
// 144:       ARGV.replace(["--cask", "--force", full_name])
// 145:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_NO_REQUIRE_TAP_TRUST: nil) do
// 146:         expect { described_class.new(["--cask", "--force", full_name]).run }
// 147:           .to output(/Uninstalling Cask local-caffeine/).to_stdout
// 148:           .and not_to_output(/Skipping loading untrusted Cask/).to_stderr
// 149:           .and not_to_output(/untrusted .* cask evaluated/).to_stderr
// 150:       end
// 151:     ensure
// 152:       ARGV.replace(original_argv)
// 153:       FileUtils.rm_rf tap.path.parent
// 154:     end
// 155:
// 156:     expect(Pathname(cask.config.appdir).join("Caffeine.app")).not_to exist
// 157:     expect(cask).not_to be_installed
// 158:   end
// 159: end
