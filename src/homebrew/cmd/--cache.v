module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--cache.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.command_name = "--cache"` at line 14.
pub fn ruby_cache_l14_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_name', ...args)
}

// Ruby method `run` at line 50.
pub fn ruby_cache_l50_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `print_formula_cache(formula, os:, arch:)` at line 87.
pub fn ruby_cache_l87_d3_print_formula_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_formula_cache', ...args)
}

// Ruby method `print_cask_cache(cask)` at line 118.
pub fn ruby_cache_l118_d4_print_cask_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_cask_cache', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fetch"
// 6: require "cask/download"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Cache < AbstractCommand
// 11:       include Fetch
// 12:
// 13:       sig { override.returns(String) }
// 14:       def self.command_name = "--cache"
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Display Homebrew's download cache. See also `$HOMEBREW_CACHE`.
// 19:
// 20:           If a <formula> or <cask> is provided, display the file or directory used to cache it.
// 21:         EOS
// 22:         flag   "--os=",
// 23:                description: "Show cache file for the given operating system. " \
// 24:                             "(Pass `all` to show cache files for all operating systems.)"
// 25:         flag   "--arch=",
// 26:                description: "Show cache file for the given CPU architecture. " \
// 27:                             "(Pass `all` to show cache files for all architectures.)"
// 28:         switch "-s", "--build-from-source",
// 29:                description: "Show the cache file used when building from source."
// 30:         switch "--force-bottle",
// 31:                description: "Show the cache file used when pouring a bottle."
// 32:         flag   "--bottle-tag=",
// 33:                description: "Show the cache file used when pouring a bottle for the given tag."
// 34:         switch "--HEAD",
// 35:                description: "Show the cache file used when building from HEAD."
// 36:         switch "--formula", "--formulae",
// 37:                description: "Only show cache files for formulae."
// 38:         switch "--cask", "--casks",
// 39:                description: "Only show cache files for casks."
// 40:
// 41:         conflicts "--build-from-source", "--force-bottle", "--bottle-tag", "--HEAD", "--cask"
// 42:         conflicts "--formula", "--cask"
// 43:         conflicts "--os", "--bottle-tag"
// 44:         conflicts "--arch", "--bottle-tag"
// 45:
// 46:         named_args [:formula, :cask]
// 47:       end
// 48:
// 49:       sig { override.void }
// 50:       def run
// 51:         if args.no_named?
// 52:           puts HOMEBREW_CACHE
// 53:           return
// 54:         end
// 55:
// 56:         formulae_or_casks = T.cast(
// 57:           args.named.to_formulae_and_casks,
// 58:           T::Array[T.any(Formula, Cask::Cask)],
// 59:         )
// 60:         os_arch_combinations = args.os_arch_combinations
// 61:
// 62:         formulae_or_casks.each do |formula_or_cask|
// 63:           ref = formula_or_cask.reloadable_ref
// 64:
// 65:           case formula_or_cask
// 66:           when Formula
// 67:             os_arch_combinations.each do |os, arch|
// 68:               SimulateSystem.with(os:, arch:) do
// 69:                 print_formula_cache(Formulary.factory(ref), os:, arch:)
// 70:               end
// 71:             end
// 72:           when Cask::Cask
// 73:             os_arch_combinations.each do |os, arch|
// 74:               next if os == :linux
// 75:
// 76:               SimulateSystem.with(os:, arch:) do
// 77:                 print_cask_cache(Cask::CaskLoader.load(ref))
// 78:               end
// 79:             end
// 80:           end
// 81:         end
// 82:       end
// 83:
// 84:       private
// 85:
// 86:       sig { params(formula: Formula, os: Symbol, arch: Symbol).void }
// 87:       def print_formula_cache(formula, os:, arch:)
// 88:         if fetch_bottle?(
// 89:           formula,
// 90:           force_bottle:               args.force_bottle?,
// 91:           bottle_tag:                 args.bottle_tag&.to_sym,
// 92:           build_from_source_formulae: args.build_from_source_formulae,
// 93:           os:                         args.os&.to_sym,
// 94:           arch:                       args.arch&.to_sym,
// 95:         )
// 96:           bottle_tag = Utils::Bottles::Tag.from_arg(args.bottle_tag&.to_sym, os:, arch:)
// 97:
// 98:           bottle = formula.bottle_for_tag(bottle_tag)
// 99:
// 100:           if bottle.nil?
// 101:             opoo "Bottle for tag #{bottle_tag.to_sym.inspect} is unavailable."
// 102:             return
// 103:           end
// 104:
// 105:           puts bottle.cached_download
// 106:         elsif args.HEAD?
// 107:           if (head = formula.head)
// 108:             puts head.cached_download
// 109:           else
// 110:             opoo "No head is defined for #{formula.full_name}."
// 111:           end
// 112:         else
// 113:           puts formula.cached_download
// 114:         end
// 115:       end
// 116:
// 117:       sig { params(cask: Cask::Cask).void }
// 118:       def print_cask_cache(cask)
// 119:         puts Cask::Download.new(cask).downloader.cached_location
// 120:       end
// 121:     end
// 122:   end
// 123: end
