module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/verify.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 40.
pub fn ruby_verify_l40_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "attestation"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Verify < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Verify the build provenance of bottles using GitHub's attestation tools.
// 13:           This is done by first fetching the given bottles and then verifying
// 14:           their provenance.
// 15:
// 16:           Note that this command depends on the GitHub CLI. Run `brew install gh`.
// 17:         EOS
// 18:         flag   "--os=",
// 19:                description: "Download for the given operating system. " \
// 20:                             "(Pass `all` to download for all operating systems.)"
// 21:         flag   "--arch=",
// 22:                description: "Download for the given CPU architecture. " \
// 23:                             "(Pass `all` to download for all architectures.)"
// 24:         flag   "--bottle-tag=",
// 25:                description: "Download a bottle for given tag."
// 26:         switch "--deps",
// 27:                description: "Also download dependencies for any listed <formula>."
// 28:         switch "-f", "--force",
// 29:                description: "Remove a previously cached version and re-fetch."
// 30:         switch "-j", "--json",
// 31:                description: "Return JSON for the attestation data for each bottle."
// 32:
// 33:         conflicts "--os", "--bottle-tag"
// 34:         conflicts "--arch", "--bottle-tag"
// 35:
// 36:         named_args [:formula], min: 1
// 37:       end
// 38:
// 39:       sig { override.void }
// 40:       def run
// 41:         bucket = if args.deps?
// 42:           args.named.to_formulae.flat_map do |formula|
// 43:             [formula, *formula.recursive_dependencies.map(&:to_formula)]
// 44:           end
// 45:         else
// 46:           args.named.to_formulae
// 47:         end.uniq
// 48:
// 49:         os_arch_combinations = args.os_arch_combinations
// 50:         json_results = []
// 51:         bucket.each do |formula|
// 52:           os_arch_combinations.each do |os, arch|
// 53:             SimulateSystem.with(os:, arch:) do
// 54:               bottle_tag = Utils::Bottles::Tag.from_arg(args.bottle_tag&.to_sym, os:, arch:)
// 55:
// 56:               bottle = formula.bottle_for_tag(bottle_tag)
// 57:
// 58:               if bottle
// 59:                 bottle.clear_cache if args.force?
// 60:                 bottle.fetch
// 61:                 begin
// 62:                   attestation = Homebrew::Attestation.check_core_attestation bottle
// 63:                   oh1 "#{bottle.filename} has a valid attestation"
// 64:                   json_results.push(attestation)
// 65:                 rescue Homebrew::Attestation::InvalidAttestationError => e
// 66:                   ofail <<~ERR
// 67:                     Failed to verify #{bottle.filename} with tag #{bottle_tag} due to error:
// 68:
// 69:                     #{e}
// 70:                   ERR
// 71:                 end
// 72:               else
// 73:                 opoo "Bottle for tag #{bottle_tag.to_sym.inspect} is unavailable."
// 74:               end
// 75:             end
// 76:           end
// 77:         end
// 78:
// 79:         puts json_results.to_json if args.json?
// 80:       end
// 81:     end
// 82:   end
// 83: end
