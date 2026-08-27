module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/test_bot.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `runner_os_title` at line 13.
pub fn ruby_test_bot_l13_d1_runner_os_title(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runner_os_title', ...args)
}

// Ruby method `previous_run_artifact_specifier` at line 27.
pub fn ruby_test_bot_l27_d2_previous_run_artifact_specifier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('previous_run_artifact_specifier', ...args)
}

// Ruby method `setup_bottle_sudo_purge!(args:)` at line 38.
pub fn ruby_test_bot_l38_d3_setup_bottle_sudo_purge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_bottle_sudo_purge!', ...args)
}

// Ruby method `integration_test_portable_ruby?` at line 45.
pub fn ruby_test_bot_l45_d4_integration_test_portable_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('integration_test_portable_ruby?', ...args)
}

// Ruby method `skip_recursive_dependents?(_formula, args:)` at line 58.
pub fn ruby_test_bot_l58_d5_skip_recursive_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_recursive_dependents?', ...args)
}

// Ruby method `cleanup_github_actions_hosted_runner` at line 69.
pub fn ruby_test_bot_l69_d6_cleanup_github_actions_hosted_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_github_actions_hosted_runner', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module TestBot
// 7:       module ClassMethods
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { T.class_of(::Homebrew::TestBot) }
// 11:
// 12:         sig { returns(String) }
// 13:         def runner_os_title
// 14:           title = "macOS #{MacOS.version.pretty_name} (#{MacOS.version})"
// 15:           title << " on Apple Silicon" if ::Hardware::CPU.arm?
// 16:
// 17:           title
// 18:         end
// 19:       end
// 20:
// 21:       module TestFormulae
// 22:         extend T::Helpers
// 23:
// 24:         requires_ancestor { ::Homebrew::TestBot::TestFormulae }
// 25:
// 26:         sig { returns(String) }
// 27:         def previous_run_artifact_specifier
// 28:           "{macos-#{MacOS.version},#{MacOS.version}-#{::Hardware::CPU.arch}}"
// 29:         end
// 30:       end
// 31:
// 32:       module Formulae
// 33:         extend T::Helpers
// 34:
// 35:         requires_ancestor { ::Homebrew::TestBot::Formulae }
// 36:
// 37:         sig { params(args: ::Homebrew::Cmd::TestBotCmd::Args).void }
// 38:         def setup_bottle_sudo_purge!(args:)
// 39:           # This is needed where sparse files may be handled (bsdtar >=3.0).
// 40:           # We use gnu-tar with sparse files disabled when --only-json-tab is passed.
// 41:           ENV["HOMEBREW_BOTTLE_SUDO_PURGE"] = "1" if MacOS.version >= :catalina && !args.only_json_tab?
// 42:         end
// 43:
// 44:         sig { returns(T::Boolean) }
// 45:         def integration_test_portable_ruby?
// 46:           # tests fail on macOS when currently running portable Ruby is replaced using same path
// 47:           portable_ruby_version = (HOMEBREW_LIBRARY_PATH/"vendor/portable-ruby-version").read.chomp
// 48:           portable_ruby_version != ::Formula["portable-ruby"].pkg_version.to_s
// 49:         end
// 50:       end
// 51:
// 52:       module FormulaeDependents
// 53:         extend T::Helpers
// 54:
// 55:         requires_ancestor { ::Homebrew::TestBot::FormulaeDependents }
// 56:
// 57:         sig { params(_formula: Formula, args: ::Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 58:         def skip_recursive_dependents?(_formula, args:)
// 59:           super || ::Hardware::CPU.intel?
// 60:         end
// 61:       end
// 62:
// 63:       module CleanupBefore
// 64:         extend T::Helpers
// 65:
// 66:         requires_ancestor { ::Homebrew::TestBot::CleanupBefore }
// 67:
// 68:         sig { void }
// 69:         def cleanup_github_actions_hosted_runner
// 70:           delete_or_move HOMEBREW_CELLAR.glob("*")
// 71:           delete_or_move HOMEBREW_CASKROOM.glob("session-manager-plugin")
// 72:
// 73:           delete_or_move %w[
// 74:             Mono.framework
// 75:             PluginManager.framework
// 76:             Python.framework
// 77:             R.framework
// 78:             Xamarin.Android.framework
// 79:             Xamarin.Mac.framework
// 80:             Xamarin.iOS.framework
// 81:           ].map { |framework| ::Pathname.new("/Library/Frameworks")/framework }, sudo: true
// 82:         end
// 83:       end
// 84:     end
// 85:   end
// 86: end
// 87:
// 88: Homebrew::TestBot.singleton_class.prepend(OS::Mac::TestBot::ClassMethods)
// 89: Homebrew::TestBot::TestFormulae.prepend(OS::Mac::TestBot::TestFormulae)
// 90: Homebrew::TestBot::Formulae.prepend(OS::Mac::TestBot::Formulae)
// 91: Homebrew::TestBot::FormulaeDependents.prepend(OS::Mac::TestBot::FormulaeDependents)
// 92: Homebrew::TestBot::CleanupBefore.prepend(OS::Mac::TestBot::CleanupBefore)
