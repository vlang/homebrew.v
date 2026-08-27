module cmd

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/cmd/brew-verify-undefined.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run; end` at line 80.
pub fn ruby_brew_verify_undefined_l80_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/parser"
// 5: require "utils/output"
// 6:
// 7: UNDEFINED_CONSTANTS = %w[
// 8:   AbstractDownloadStrategy
// 9:   Addressable
// 10:   Base64
// 11:   CacheStore
// 12:   Cask::Cask
// 13:   Cask::CaskLoader
// 14:   Completions
// 15:   Concurrent
// 16:   CSV
// 17:   Formula
// 18:   Formulary
// 19:   GitRepository
// 20:   Homebrew::API
// 21:   Homebrew::Manpages
// 22:   Homebrew::Settings
// 23:   JSONSchemer
// 24:   Kramdown
// 25:   MachO
// 26:   Metafiles
// 27:   MethodSource
// 28:   Minitest
// 29:   Nokogiri
// 30:   OS::Mac::Version
// 31:   PatchELF
// 32:   Plist
// 33:   Pry
// 34:   ProgressBar
// 35:   PyCall
// 36:   REXML
// 37:   Red
// 38:   Redcarpet
// 39:   RSpec
// 40:   RuboCop
// 41:   RubyProf
// 42:   StackProf
// 43:   Spoom
// 44:   Tap
// 45:   Tapioca
// 46:   UnpackStrategy
// 47:   Utils::Analytics
// 48:   Utils::Backtrace
// 49:   Utils::Bottles
// 50:   Utils::Curl
// 51:   Utils::Fork
// 52:   Utils::Git
// 53:   Utils::GitHub
// 54:   Utils::Link
// 55:   Utils::Svn
// 56:   Uri
// 57:   Vernier
// 58:   Warnings
// 59:   YARD
// 60: ].freeze
// 61:
// 62: UNDEFINED_CONSTANTS_AFTER_REQUIRE = T.let({
// 63:   "api"                           => %w[Base64 Concurrent Homebrew::DownloadQueue Plist],
// 64:   "cask/artifact/pkg"             => %w[Plist],
// 65:   "dev-cmd/formula-analytics"     => %w[InfluxDBClient3 PyCall],
// 66:   "downloadable"                  => %w[Concurrent],
// 67:   "extend/os/mac/extend/pathname" => %w[MachO],
// 68:   "formula_cellar_checks"         => %w[Plist],
// 69:   "keg"                           => %w[MachO],
// 70:   "livecheck/livecheck"           => %w[Addressable],
// 71:   "os/mac/xcode"                  => %w[Plist],
// 72:   "service"                       => %w[Plist],
// 73:   "services/cli"                  => %w[Plist],
// 74: }.freeze, T::Hash[String, T::Array[String]])
// 75:
// 76: module Homebrew
// 77:   module Cmd
// 78:     class VerifyUndefined < AbstractCommand
// 79:       sig { override.void }
// 80:       def run; end
// 81:     end
// 82:   end
// 83: end
// 84:
// 85: parser = Homebrew::CLI::Parser.new(Homebrew::Cmd::VerifyUndefined) do
// 86:   usage_banner <<~EOS
// 87:     `verify-undefined`
// 88:
// 89:     Verifies that the following constants have not been defined
// 90:     at startup to make sure that startup times stay consistent.
// 91:
// 92:     Constants:
// 93:     #{UNDEFINED_CONSTANTS.join("\n")}
// 94:   EOS
// 95: end
// 96:
// 97: parser.parse
// 98:
// 99: UNDEFINED_CONSTANTS.each do |constant_name|
// 100:   # The constant name is iterated from the list above.
// 101:   # rubocop:disable Sorbet/ConstantsFromStrings
// 102:   Object.const_get(constant_name)
// 103:   # rubocop:enable Sorbet/ConstantsFromStrings
// 104:   Utils::Output.ofail "#{constant_name} should not be defined at startup"
// 105: rescue NameError
// 106:   # We expect this to error as it should not be defined.
// 107: end
// 108:
// 109: UNDEFINED_CONSTANTS_AFTER_REQUIRE.each do |require_path, constant_names|
// 110:   require require_path
// 111:
// 112:   constant_names.each do |constant_name|
// 113:     # The constant name is iterated from the list above.
// 114:     # rubocop:disable Sorbet/ConstantsFromStrings
// 115:     Object.const_get(constant_name)
// 116:     # rubocop:enable Sorbet/ConstantsFromStrings
// 117:     Utils::Output.ofail "#{constant_name} should not be defined after requiring #{require_path}"
// 118:   rescue NameError
// 119:     # We expect this to error as it should not be defined.
// 120:   end
// 121: end
