module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/pin.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 32.
pub fn ruby_pin_l32_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
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
// 10:     class Pin < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Pin the specified package, preventing it from being upgraded when
// 14:           issuing the `brew upgrade` <formula> or <cask> command. See also `unpin`.
// 15:
// 16:           *Note:* Other packages which depend on newer versions of a pinned formula
// 17:           might not install or run correctly.
// 18:           Pinned casks with `auto_updates true` may update themselves outside Homebrew.
// 19:         EOS
// 20:
// 21:         switch "--formula", "--formulae",
// 22:                description: "Treat all named arguments as formulae."
// 23:         switch "--cask", "--casks",
// 24:                description: "Treat all named arguments as casks."
// 25:
// 26:         conflicts "--formula", "--cask"
// 27:
// 28:         named_args [:installed_formula, :installed_cask], min: 1
// 29:       end
// 30:
// 31:       sig { override.void }
// 32:       def run
// 33:         formulae, casks = args.named.to_resolved_formulae_to_casks
// 34:
// 35:         (formulae + casks).each do |package|
// 36:           if package.pinned?
// 37:             opoo "#{package.full_name} already pinned"
// 38:           elsif !package.pinnable?
// 39:             ofail "#{package.full_name} not installed"
// 40:           else
// 41:             package.pin
// 42:             if package.is_a?(Cask::Cask) && package.auto_updates
// 43:               opoo "#{package.full_name} has `auto_updates true` and may update itself outside Homebrew despite " \
// 44:                    "being pinned."
// 45:             end
// 46:           end
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
