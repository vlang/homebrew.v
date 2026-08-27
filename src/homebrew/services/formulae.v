module services

import brew_runtime

// Translated from Homebrew/brew `services/formulae.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.available_services(loaded: nil, skip_root: false)` at line 12.
pub fn ruby_formulae_l12_d1_self_available_services(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.available_services', ...args)
}

// Ruby method `self.services_list` at line 28.
pub fn ruby_formulae_l28_d2_self_services_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.services_list', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/formula_wrapper"
// 5:
// 6: module Homebrew
// 7:   module Services
// 8:     module Formulae
// 9:       # All available services, with optional filters applied
// 10:       # @private
// 11:       sig { params(loaded: T.nilable(T::Boolean), skip_root: T::Boolean).returns(T::Array[Services::FormulaWrapper]) }
// 12:       def self.available_services(loaded: nil, skip_root: false)
// 13:         require "formula"
// 14:
// 15:         formulae = Formula.installed
// 16:                           .map { |formula| FormulaWrapper.new(formula) }
// 17:                           .select(&:service?)
// 18:                           .sort_by(&:name)
// 19:
// 20:         formulae = formulae.select { |formula| formula.loaded? == loaded } unless loaded.nil?
// 21:         formulae = formulae.reject { |formula| formula.owner == "root" } if skip_root
// 22:
// 23:         formulae
// 24:       end
// 25:
// 26:       # List all available services with status, user, and path to the file.
// 27:       sig { returns(T::Array[T::Hash[Symbol, T.anything]]) }
// 28:       def self.services_list
// 29:         available_services.map(&:to_hash)
// 30:       end
// 31:     end
// 32:   end
// 33: end
