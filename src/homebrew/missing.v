module homebrew

import brew_runtime

// Translated from Homebrew/brew `missing.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.deps(formulae, casks = [], hide = [], &_block)` at line 16.
pub fn ruby_missing_l16_d1_self_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deps', ...args)
}

// Ruby method `self.cask_deps(cask, hide)` at line 37.
pub fn ruby_missing_l37_d2_self_cask_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_deps', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "utils"
// 6: require "cask/caskroom"
// 7: require "cask/tab"
// 8:
// 9: module Homebrew
// 10:   module Missing
// 11:     sig {
// 12:       params(formulae: T::Array[Formula], casks: T::Array[Cask::Cask], hide: T::Array[String], _block: T.nilable(
// 13:         T.proc.params(package_name: String, missing_dependencies: T::Array[String]).void,
// 14:       )).returns(T::Hash[String, T::Array[String]])
// 15:     }
// 16:     def self.deps(formulae, casks = [], hide = [], &_block)
// 17:       missing = {}
// 18:       formulae.each do |formula|
// 19:         missing_dependencies = formula.missing_dependencies(hide: hide).map(&:to_s)
// 20:         next if missing_dependencies.empty?
// 21:
// 22:         yield formula.full_name, missing_dependencies if block_given?
// 23:         missing[formula.full_name] = missing_dependencies
// 24:       end
// 25:
// 26:       casks.each do |cask|
// 27:         missing_dependencies = cask_deps(cask, hide)
// 28:         next if missing_dependencies.empty?
// 29:
// 30:         yield cask.full_name, missing_dependencies if block_given?
// 31:         missing[cask.full_name] = missing_dependencies
// 32:       end
// 33:       missing
// 34:     end
// 35:
// 36:     sig { params(cask: Cask::Cask, hide: T::Array[String]).returns(T::Array[String]) }
// 37:     def self.cask_deps(cask, hide)
// 38:       tab_deps = T.let(Cask::Tab.for_cask(cask).runtime_dependencies, T.untyped)
// 39:       return [] unless tab_deps.is_a?(Hash)
// 40:
// 41:       tab_deps.keys.flat_map do |type|
// 42:         deps = tab_deps[type]
// 43:         next [] unless deps.is_a?(Array)
// 44:
// 45:         deps.filter_map do |dep|
// 46:           next unless dep.is_a?(Hash)
// 47:
// 48:           full_name = T.cast(dep["full_name"], T.nilable(String))
// 49:           next if full_name.blank?
// 50:
// 51:           name = Utils.name_from_full_name(full_name)
// 52:           installed = case type.to_s
// 53:           when "cask"
// 54:             (Cask::Caskroom.path/name).directory?
// 55:           when "formula"
// 56:             (HOMEBREW_CELLAR/name).directory?
// 57:           else
// 58:             true
// 59:           end
// 60:           next if hide.exclude?(name) && installed
// 61:
// 62:           full_name
// 63:         end
// 64:       end.sort
// 65:     end
// 66:     private_class_method :cask_deps
// 67:   end
// 68: end
