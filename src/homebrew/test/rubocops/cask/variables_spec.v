module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/variables_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts when there are no variables" do` at line 7.
pub fn ruby_variables_spec_l7_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts when there is an `arch` stanza" do` at line 15.
pub fn ruby_variables_spec_l15_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts an `on_arch_conditional` variable" do` at line 23.
pub fn ruby_variables_spec_l23_d3_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "reports an offense for an `arch` variable using strings" do` at line 31.
pub fn ruby_variables_spec_l31_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for an `arch` variable using symbols" do` at line 46.
pub fn ruby_variables_spec_l46_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for an `arch` variable with an empty string" do` at line 61.
pub fn ruby_variables_spec_l61_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for a non-`arch` variable using strings" do` at line 76.
pub fn ruby_variables_spec_l76_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for a non-`arch` variable with an empty string" do` at line 91.
pub fn ruby_variables_spec_l91_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for consecutive `arch` and non-`arch` variables" do` at line 106.
pub fn ruby_variables_spec_l106_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense for two consecutive non-`arch` variables" do` at line 124.
pub fn ruby_variables_spec_l124_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::Variables, :config do
// 7:   it "accepts when there are no variables" do
// 8:     expect_no_offenses <<~CASK
// 9:       cask "foo" do
// 10:         version :latest
// 11:       end
// 12:     CASK
// 13:   end
// 14:
// 15:   it "accepts when there is an `arch` stanza" do
// 16:     expect_no_offenses <<~CASK
// 17:       cask "foo" do
// 18:         arch arm: "darwin-arm64", intel: "darwin"
// 19:       end
// 20:     CASK
// 21:   end
// 22:
// 23:   it "accepts an `on_arch_conditional` variable" do
// 24:     expect_no_offenses <<~CASK
// 25:       cask "foo" do
// 26:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 27:       end
// 28:     CASK
// 29:   end
// 30:
// 31:   it "reports an offense for an `arch` variable using strings" do
// 32:     expect_offense <<~CASK
// 33:       cask 'foo' do
// 34:         arch = Hardware::CPU.intel? ? "darwin" : "darwin-arm64"
// 35:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arch arm: "darwin-arm64", intel: "darwin"` instead of `arch = Hardware::CPU.intel? ? "darwin" : "darwin-arm64"`.
// 36:       end
// 37:     CASK
// 38:
// 39:     expect_correction <<~CASK
// 40:       cask 'foo' do
// 41:         arch arm: "darwin-arm64", intel: "darwin"
// 42:       end
// 43:     CASK
// 44:   end
// 45:
// 46:   it "reports an offense for an `arch` variable using symbols" do
// 47:     expect_offense <<~CASK
// 48:       cask 'foo' do
// 49:         arch = Hardware::CPU.intel? ? :darwin : :darwin_arm64
// 50:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arch arm: :darwin_arm64, intel: :darwin` instead of `arch = Hardware::CPU.intel? ? :darwin : :darwin_arm64`.
// 51:       end
// 52:     CASK
// 53:
// 54:     expect_correction <<~CASK
// 55:       cask 'foo' do
// 56:         arch arm: :darwin_arm64, intel: :darwin
// 57:       end
// 58:     CASK
// 59:   end
// 60:
// 61:   it "reports an offense for an `arch` variable with an empty string" do
// 62:     expect_offense <<~CASK
// 63:       cask 'foo' do
// 64:         arch = Hardware::CPU.intel? ? "" : "arm64"
// 65:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arch arm: "arm64"` instead of `arch = Hardware::CPU.intel? ? "" : "arm64"`.
// 66:       end
// 67:     CASK
// 68:
// 69:     expect_correction <<~CASK
// 70:       cask 'foo' do
// 71:         arch arm: "arm64"
// 72:       end
// 73:     CASK
// 74:   end
// 75:
// 76:   it "reports an offense for a non-`arch` variable using strings" do
// 77:     expect_offense <<~CASK
// 78:       cask 'foo' do
// 79:         folder = Hardware::CPU.intel? ? "darwin" : "darwin-arm64"
// 80:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"` instead of `folder = Hardware::CPU.intel? ? "darwin" : "darwin-arm64"`.
// 81:       end
// 82:     CASK
// 83:
// 84:     expect_correction <<~CASK
// 85:       cask 'foo' do
// 86:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 87:       end
// 88:     CASK
// 89:   end
// 90:
// 91:   it "reports an offense for a non-`arch` variable with an empty string" do
// 92:     expect_offense <<~CASK
// 93:       cask 'foo' do
// 94:         folder = Hardware::CPU.intel? ? "amd64" : ""
// 95:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `folder = on_arch_conditional intel: "amd64"` instead of `folder = Hardware::CPU.intel? ? "amd64" : ""`.
// 96:       end
// 97:     CASK
// 98:
// 99:     expect_correction <<~CASK
// 100:       cask 'foo' do
// 101:         folder = on_arch_conditional intel: "amd64"
// 102:       end
// 103:     CASK
// 104:   end
// 105:
// 106:   it "reports an offense for consecutive `arch` and non-`arch` variables" do
// 107:     expect_offense <<~CASK
// 108:       cask 'foo' do
// 109:         arch = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"
// 110:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `arch arm: "darwin-arm64", intel: "darwin"` instead of `arch = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"`.
// 111:         folder = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"
// 112:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"` instead of `folder = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"`.
// 113:       end
// 114:     CASK
// 115:
// 116:     expect_correction <<~CASK
// 117:       cask 'foo' do
// 118:         arch arm: "darwin-arm64", intel: "darwin"
// 119:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 120:       end
// 121:     CASK
// 122:   end
// 123:
// 124:   it "reports an offense for two consecutive non-`arch` variables" do
// 125:     expect_offense <<~CASK
// 126:       cask 'foo' do
// 127:         folder = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"
// 128:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"` instead of `folder = Hardware::CPU.arm? ? "darwin-arm64" : "darwin"`.
// 129:         platform = Hardware::CPU.intel? ? "darwin": "darwin-arm64"
// 130:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"` instead of `platform = Hardware::CPU.intel? ? "darwin": "darwin-arm64"`.
// 131:       end
// 132:     CASK
// 133:
// 134:     expect_correction <<~CASK
// 135:       cask 'foo' do
// 136:         folder = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 137:         platform = on_arch_conditional arm: "darwin-arm64", intel: "darwin"
// 138:       end
// 139:     CASK
// 140:   end
// 141: end
