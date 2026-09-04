module cmd

import ruby

// Translated from Homebrew/brew `cmd/unpin.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn unpin_packages(mut packages []PinPackageState) PinCommandResult {
	mut warnings := []string{}
	mut failures := []string{}
	for package_kind in [PinPackageKind.formula, .cask] {
		for mut package in packages {
			if package.kind != package_kind {
				continue
			}
			if package.pinned || (package.kind == .cask && package.pin_symlink) {
				package.unpin()
			} else if !package.installed || !package.pinnable {
				failures << '${package.full_name} not installed'
			} else {
				warnings << '${package.full_name} not pinned'
			}
		}
	}
	return PinCommandResult{
		warnings: warnings
		failures: failures
	}
}

// Ruby method `run` at line 28.
pub fn ruby_unpin_l28_d1_run(args ...ruby.Value) ruby.Value {
	mut packages := pin_boundary_packages(args)
	result := unpin_packages(mut packages)
	return unpin_command_result_value(result, packages)
}

fn unpin_command_result_value(result PinCommandResult, packages []PinPackageState) ruby.Value {
	mut messages := result.warnings.clone()
	messages << result.failures
	return ruby.Value{
		type_name: 'UnpinCommandResult'
		repr: messages.join('\n')
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
			'failures': ruby.string_array_value(result.failures)
			'packages': ruby.array_value(packages.map(pin_package_value(it)))
		}
		attributes: {
			'failed': result.failed().str()
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/cask"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Unpin < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Unpin the specified package, allowing it to be upgraded by `brew upgrade` <formula> or <cask>.
// 14:           See also `pin`.
// 15:         EOS
// 16:
// 17:         switch "--formula", "--formulae",
// 18:                description: "Treat all named arguments as formulae."
// 19:         switch "--cask", "--casks",
// 20:                description: "Treat all named arguments as casks."
// 21:
// 22:         conflicts "--formula", "--cask"
// 23:
// 24:         named_args [:installed_formula, :installed_cask], min: 1
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         formulae, casks = args.named.to_resolved_formulae_to_casks
// 30:
// 31:         formulae.each do |formula|
// 32:           if formula.pinned?
// 33:             formula.unpin
// 34:           elsif !formula.pinnable?
// 35:             onoe "#{formula.full_name} not installed"
// 36:           else
// 37:             opoo "#{formula.full_name} not pinned"
// 38:           end
// 39:         end
// 40:
// 41:         casks.each do |cask|
// 42:           if cask.pinned? || cask.pin_path.symlink?
// 43:             cask.unpin
// 44:           elsif !cask.pinnable?
// 45:             onoe "#{cask.full_name} not installed"
// 46:           else
// 47:             opoo "#{cask.full_name} not pinned"
// 48:           end
// 49:         end
// 50:       end
// 51:     end
// 52:   end
// 53: end
