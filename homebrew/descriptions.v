module homebrew

import brew_runtime

// Translated from Homebrew/brew `descriptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.search(string_or_regex, field, cache_store, status_data: {}, eval_all: Homebrew::EnvConfig.tap_trust_configured?)` at line 33.
pub fn ruby_descriptions_l33_d1_self_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search', ...args)
}

// Ruby method `initialize(descriptions, status_data: {})` at line 59.
pub fn ruby_descriptions_l59_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `print(show_missing: false)` at line 67.
pub fn ruby_descriptions_l67_d3_print(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print', ...args)
}

// Ruby method `decorate_name(full_name, printed_name, description)` at line 101.
pub fn ruby_descriptions_l101_d4_decorate_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate_name', ...args)
}

// Ruby method `installed_formulae` at line 141.
pub fn ruby_descriptions_l141_d5_installed_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formulae', ...args)
}

// Ruby method `installed_casks` at line 149.
pub fn ruby_descriptions_l149_d6_installed_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_casks', ...args)
}

// Ruby method `short_names` at line 157.
pub fn ruby_descriptions_l157_d7_short_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('short_names', ...args)
}

// Ruby method `short_name_counts` at line 165.
pub fn ruby_descriptions_l165_d8_short_name_counts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('short_name_counts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "search"
// 6: require "cask/cask_loader"
// 7:
// 8: # Helper class for printing and searching descriptions.
// 9: class Descriptions
// 10:   # Enum for specifying which fields to search.
// 11:   class SearchField < T::Enum
// 12:     enums do
// 13:       # enum values are not mutable, and calling .freeze on them breaks Sorbet
// 14:       # rubocop:disable Style/MutableConstant
// 15:       Name = new
// 16:       Description = new
// 17:       Either = new
// 18:       # rubocop:enable Style/MutableConstant
// 19:     end
// 20:   end
// 21:
// 22:   # Given a regex, find all formulae whose specified fields contain a match.
// 23:   sig {
// 24:     params(
// 25:       string_or_regex: T.any(Regexp, String),
// 26:       field:           SearchField,
// 27:       cache_store:     T.any(DescriptionCacheStore, T::Hash[String, T.nilable(String)],
// 28:                              T::Hash[String, T::Array[T.nilable(String)]]),
// 29:       status_data:     T::Hash[String, T::Hash[Symbol, T::Boolean]],
// 30:       eval_all:        T::Boolean,
// 31:     ).returns(T.attached_class)
// 32:   }
// 33:   def self.search(string_or_regex, field, cache_store, status_data: {}, eval_all: Homebrew::EnvConfig.tap_trust_configured?)
// 34:     cache_store.populate_if_empty!(eval_all:) if cache_store.is_a?(DescriptionCacheStore)
// 35:
// 36:     results = case field
// 37:     when SearchField::Name
// 38:       Homebrew::Search.search(cache_store, string_or_regex) { |name, _| name }
// 39:     when SearchField::Description
// 40:       Homebrew::Search.search(cache_store, string_or_regex) { |_, desc| desc }
// 41:     when SearchField::Either
// 42:       Homebrew::Search.search(cache_store, string_or_regex)
// 43:     else
// 44:       T.absurd(field)
// 45:     end
// 46:
// 47:     results = T.cast(results, T.any(T::Hash[String, T.nilable(String)], T::Hash[String, T::Array[T.nilable(String)]]))
// 48:
// 49:     new(results, status_data: status_data.slice(*results.keys))
// 50:   end
// 51:
// 52:   # Create an actual instance.
// 53:   sig {
// 54:     params(
// 55:       descriptions: T.any(T::Hash[String, T.nilable(String)], T::Hash[String, T::Array[T.nilable(String)]]),
// 56:       status_data:  T::Hash[String, T::Hash[Symbol, T::Boolean]],
// 57:     ).void
// 58:   }
// 59:   def initialize(descriptions, status_data: {})
// 60:     @descriptions = descriptions
// 61:     @status_data = status_data
// 62:   end
// 63:
// 64:   # Take search results -- a hash mapping formula names to descriptions -- and
// 65:   # print them.
// 66:   sig { params(show_missing: T::Boolean).void }
// 67:   def print(show_missing: false)
// 68:     @descriptions.keys.sort.each do |full_name|
// 69:       description = @descriptions[full_name]
// 70:       next if description.nil?
// 71:
// 72:       short_name = short_names[full_name]
// 73:       display_name = if short_name && short_name_counts[short_name] == 1
// 74:         short_name
// 75:       else
// 76:         full_name
// 77:       end
// 78:       display_name = decorate_name(full_name, display_name, description)
// 79:       if description.is_a?(Array)
// 80:         names = description[0]
// 81:         description = description.fetch(1, nil)
// 82:         next if description.nil? && !show_missing
// 83:
// 84:         description ||= Formatter.warning("[no description]")
// 85:         puts names.present? ? "#{display_name}: (#{names}) #{description}" : "#{display_name}: #{description}"
// 86:       else
// 87:         puts "#{display_name}: #{description}"
// 88:       end
// 89:     end
// 90:   end
// 91:
// 92:   private
// 93:
// 94:   sig {
// 95:     params(
// 96:       full_name:    String,
// 97:       printed_name: String,
// 98:       description:  T.nilable(T.any(String, T::Array[T.nilable(String)])),
// 99:     ).returns(String)
// 100:   }
// 101:   def decorate_name(full_name, printed_name, description)
// 102:     return printed_name unless $stdout.tty?
// 103:
// 104:     installed = if description.is_a?(Array)
// 105:       installed_casks.include?(full_name)
// 106:     else
// 107:       installed_formulae.include?(full_name)
// 108:     end
// 109:     printed_name = if installed
// 110:       Homebrew::Search.pretty_installed(printed_name)
// 111:     else
// 112:       "#{Tty.bold}#{printed_name}#{Tty.reset}"
// 113:     end
// 114:
// 115:     status_data = @status_data[full_name]
// 116:     if status_data&.[](:deprecated)
// 117:       Homebrew::Search.pretty_deprecated(printed_name)
// 118:     elsif status_data&.[](:disabled)
// 119:       Homebrew::Search.pretty_disabled(printed_name)
// 120:     else
// 121:       formula_or_cask = begin
// 122:         Formulary.factory(full_name)
// 123:       rescue FormulaUnavailableError
// 124:         Cask::CaskLoader.load(full_name)
// 125:       rescue Cask::CaskUnavailableError
// 126:         nil
// 127:       end
// 128:       return printed_name if formula_or_cask.nil?
// 129:
// 130:       if formula_or_cask.deprecated?
// 131:         Homebrew::Search.pretty_deprecated(printed_name)
// 132:       elsif formula_or_cask.disabled?
// 133:         Homebrew::Search.pretty_disabled(printed_name)
// 134:       else
// 135:         printed_name
// 136:       end
// 137:     end
// 138:   end
// 139:
// 140:   sig { returns(T::Set[String]) }
// 141:   def installed_formulae
// 142:     @installed_formulae ||= T.let(
// 143:       Formula.installed.flat_map { |formula| [formula.name, formula.full_name] }.to_set,
// 144:       T.nilable(T::Set[String]),
// 145:     )
// 146:   end
// 147:
// 148:   sig { returns(T::Set[String]) }
// 149:   def installed_casks
// 150:     @installed_casks ||= T.let(
// 151:       Cask::Caskroom.casks.flat_map { |cask| [cask.token, cask.full_name] }.to_set,
// 152:       T.nilable(T::Set[String]),
// 153:     )
// 154:   end
// 155:
// 156:   sig { returns(T::Hash[String, String]) }
// 157:   def short_names
// 158:     @short_names ||= T.let(
// 159:       @descriptions.keys.to_h { |k| [k, Utils.name_from_full_name(k)] },
// 160:       T.nilable(T::Hash[String, String]),
// 161:     )
// 162:   end
// 163:
// 164:   sig { returns(T::Hash[String, Integer]) }
// 165:   def short_name_counts
// 166:     @short_name_counts ||= T.let(
// 167:       short_names.values
// 168:                  .tally,
// 169:       T.nilable(T::Hash[String, Integer]),
// 170:     )
// 171:   end
// 172: end
