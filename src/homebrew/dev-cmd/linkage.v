module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/linkage.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 33.
pub fn ruby_linkage_l33_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cache_store"
// 6: require "linkage_checker"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class Linkage < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Check the library links from the given <formula> kegs. If no <formula> are
// 14:           provided, check all kegs. Raises an error if run on uninstalled formulae.
// 15:         EOS
// 16:         switch "--test",
// 17:                description: "Show only missing libraries and exit with a non-zero status if any missing " \
// 18:                             "libraries are found."
// 19:         switch "--strict",
// 20:                depends_on:  "--test",
// 21:                description: "Exit with a non-zero status if any undeclared dependencies with linkage are found."
// 22:         switch "--reverse",
// 23:                description: "For every library that a keg references, print its dylib path followed by the " \
// 24:                             "binaries that link to it."
// 25:         switch "--cached",
// 26:                description: "Print the cached linkage values stored in `$HOMEBREW_CACHE`, set by a previous " \
// 27:                             "`brew linkage` run."
// 28:
// 29:         named_args :installed_formula
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         CacheStoreDatabase.use(:linkage) do |db|
// 35:           kegs = if args.named.to_default_kegs.empty?
// 36:             Formula.installed.filter_map(&:any_installed_keg)
// 37:           else
// 38:             args.named.to_default_kegs
// 39:           end
// 40:           kegs.each do |keg|
// 41:             ohai "Checking #{keg.name} linkage" if kegs.size > 1
// 42:
// 43:             result = LinkageChecker.new(keg,
// 44:                                         cache_db: T.cast(db,
// 45:                                                          CacheStoreDatabase[String,
// 46:                                                                             T::Hash[T.any(String, Symbol),
// 47:                                                                                     T.anything]]))
// 48:
// 49:             if args.test?
// 50:               result.display_test_output(strict: args.strict?)
// 51:               Homebrew.failed = true if result.broken_library_linkage?(test: true, strict: args.strict?)
// 52:             elsif args.reverse?
// 53:               result.display_reverse_output
// 54:             else
// 55:               result.display_normal_output
// 56:             end
// 57:           end
// 58:         end
// 59:       end
// 60:     end
// 61:   end
// 62: end
