module cask

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/cask/sha256_arch_order_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts keys in the canonical order" do` at line 7.
pub fn ruby_sha256_arch_order_spec_l7_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a single checksum" do` at line 18.
pub fn ruby_sha256_arch_order_spec_l18_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "registers an offense and corrects Linux keys in the wrong order" do` at line 26.
pub fn ruby_sha256_arch_order_spec_l26_d3_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers an offense and corrects macOS keys listed after Linux keys" do` at line 43.
pub fn ruby_sha256_arch_order_spec_l43_d4_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers offenses and corrects within `on_macos` and `on_linux` blocks" do` at line 60.
pub fn ruby_sha256_arch_order_spec_l60_d5_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::Sha256ArchOrder, :config do
// 7:   it "accepts keys in the canonical order" do
// 8:     expect_no_offenses(<<~CASK)
// 9:       cask "foo" do
// 10:         sha256 arm:          "arm",
// 11:                intel:        "intel",
// 12:                arm64_linux:  "arm64_linux",
// 13:                x86_64_linux: "x86_64_linux"
// 14:       end
// 15:     CASK
// 16:   end
// 17:
// 18:   it "accepts a single checksum" do
// 19:     expect_no_offenses(<<~CASK)
// 20:       cask "foo" do
// 21:         sha256 "abc"
// 22:       end
// 23:     CASK
// 24:   end
// 25:
// 26:   it "registers an offense and corrects Linux keys in the wrong order" do
// 27:     expect_offense(<<~CASK)
// 28:       cask "foo" do
// 29:         sha256 x86_64_linux: "x86_64_linux",
// 30:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux
// 31:                arm64_linux:  "arm64_linux"
// 32:       end
// 33:     CASK
// 34:
// 35:     expect_correction(<<~CASK)
// 36:       cask "foo" do
// 37:         sha256 arm64_linux:  "arm64_linux",
// 38:                x86_64_linux: "x86_64_linux"
// 39:       end
// 40:     CASK
// 41:   end
// 42:
// 43:   it "registers an offense and corrects macOS keys listed after Linux keys" do
// 44:     expect_offense(<<~CASK)
// 45:       cask "foo" do
// 46:         sha256 x86_64_linux: "x86_64_linux",
// 47:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux
// 48:                arm:          "arm"
// 49:       end
// 50:     CASK
// 51:
// 52:     expect_correction(<<~CASK)
// 53:       cask "foo" do
// 54:         sha256 arm:          "arm",
// 55:                x86_64_linux: "x86_64_linux"
// 56:       end
// 57:     CASK
// 58:   end
// 59:
// 60:   it "registers offenses and corrects within `on_macos` and `on_linux` blocks" do
// 61:     expect_offense(<<~CASK)
// 62:       cask "foo" do
// 63:         on_macos do
// 64:           sha256 intel: "intel",
// 65:           ^^^^^^^^^^^^^^^^^^^^^^ `sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux
// 66:                  arm:   "arm"
// 67:         end
// 68:
// 69:         on_linux do
// 70:           sha256 x86_64_linux: "x86_64_linux",
// 71:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `sha256` architecture keys should be ordered: arm, intel (or x86_64), arm64_linux, x86_64_linux
// 72:                  arm64_linux:  "arm64_linux"
// 73:         end
// 74:       end
// 75:     CASK
// 76:
// 77:     expect_correction(<<~CASK)
// 78:       cask "foo" do
// 79:         on_macos do
// 80:           sha256 arm:   "arm",
// 81:                  intel: "intel"
// 82:         end
// 83:
// 84:         on_linux do
// 85:           sha256 arm64_linux:  "arm64_linux",
// 86:                  x86_64_linux: "x86_64_linux"
// 87:         end
// 88:       end
// 89:     CASK
// 90:   end
// 91: end
