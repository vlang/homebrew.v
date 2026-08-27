module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/ruby_check_version_script_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject do` at line 6.
pub fn ruby_ruby_check_version_script_spec_l6_d1_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby let `let(:required_ruby_version) { "1.2.3" }` at line 17.
pub fn ruby_ruby_check_version_script_spec_l17_d2_required_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_ruby_version', ...args)
}

// Ruby let `let(:required_ruby_version) { RUBY_VERSION }` at line 25.
pub fn ruby_ruby_check_version_script_spec_l25_d3_required_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_ruby_version', ...args)
}

// Ruby it `it { is_expected.to be true }` at line 27.
pub fn ruby_ruby_check_version_script_spec_l27_d4_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:required_ruby_version) { "2.0.0" }` at line 31.
pub fn ruby_ruby_check_version_script_spec_l31_d5_required_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_ruby_version', ...args)
}

// Ruby it `it { is_expected.to be true }` at line 38.
pub fn ruby_ruby_check_version_script_spec_l38_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:required_ruby_version) { "1.2.3" }` at line 42.
pub fn ruby_ruby_check_version_script_spec_l42_d7_required_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_ruby_version', ...args)
}

// Ruby it `it { is_expected.to be false }` at line 44.
pub fn ruby_ruby_check_version_script_spec_l44_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:required_ruby_version) { "fish" }` at line 48.
pub fn ruby_ruby_check_version_script_spec_l48_d9_required_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_ruby_version', ...args)
}

// Ruby it `it { is_expected.to be false }` at line 50.
pub fn ruby_ruby_check_version_script_spec_l50_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Utils do
// 5:   describe "ruby_check_version_script" do
// 6:     subject do
// 7:       homebrew_env = ENV.select { |key, _| key.start_with?("HOMEBREW_") }
// 8:       Bundler.with_unbundled_env do
// 9:         ENV.delete_if { |key,| key.start_with?("HOMEBREW_") }
// 10:         ENV.update(homebrew_env)
// 11:         # We intentionally don't use the shebang in this script as portable Ruby
// 12:         # is usually not in PATH. This aligns with how we run the script in brew.
// 13:         quiet_system RUBY_PATH, "#{HOMEBREW_LIBRARY_PATH}/utils/ruby_check_version_script.rb", required_ruby_version
// 14:       end
// 15:     end
// 16:
// 17:     let(:required_ruby_version) { "1.2.3" }
// 18:
// 19:     before do
// 20:       ENV.delete("HOMEBREW_DEVELOPER")
// 21:       ENV.delete("HOMEBREW_USE_RUBY_FROM_PATH")
// 22:     end
// 23:
// 24:     describe "succeeds on the running Ruby version" do
// 25:       let(:required_ruby_version) { RUBY_VERSION }
// 26:
// 27:       it { is_expected.to be true }
// 28:     end
// 29:
// 30:     describe "succeeds on newer mismatched major/minor required Ruby version and configured environment" do
// 31:       let(:required_ruby_version) { "2.0.0" }
// 32:
// 33:       before do
// 34:         ENV["HOMEBREW_DEVELOPER"] = "1"
// 35:         ENV["HOMEBREW_USE_RUBY_FROM_PATH"] = "1"
// 36:       end
// 37:
// 38:       it { is_expected.to be true }
// 39:     end
// 40:
// 41:     describe "fails on on mismatched major/minor required Ruby version" do
// 42:       let(:required_ruby_version) { "1.2.3" }
// 43:
// 44:       it { is_expected.to be false }
// 45:     end
// 46:
// 47:     describe "fails on invalid required Ruby version" do
// 48:       let(:required_ruby_version) { "fish" }
// 49:
// 50:       it { is_expected.to be false }
// 51:     end
// 52:   end
// 53: end
