module homebrew

import brew_runtime

// Translated from Homebrew/brew `search.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.query_regexp(query)` at line 39.
pub fn ruby_search_l39_d1_self_query_regexp(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.query_regexp', ...args)
}

// Ruby method `self.ignore_cask?(_cask) = false` at line 50.
pub fn ruby_search_l50_d2_self_ignore_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ignore_cask?', ...args)
}

// Ruby method `self.search_descriptions(string_or_regex, args, search_type: nil, show_missing: false)` at line 62.
pub fn ruby_search_l62_d3_self_search_descriptions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_descriptions', ...args)
}

// Ruby method `self.search_formulae(string_or_regex)` at line 118.
pub fn ruby_search_l118_d4_self_search_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_formulae', ...args)
}

// Ruby method `self.search_casks(string_or_regex)` at line 160.
pub fn ruby_search_l160_d5_self_search_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_casks', ...args)
}

// Ruby method `self.search_names(string_or_regex, args)` at line 207.
pub fn ruby_search_l207_d6_self_search_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_names', ...args)
}

// Ruby method `self.search(selectable, string_or_regex, &block)` at line 223.
pub fn ruby_search_l223_d7_self_search(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search', ...args)
}

// Ruby method `self.simplify_string(string)` at line 233.
pub fn ruby_search_l233_d8_self_simplify_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.simplify_string', ...args)
}

// Ruby method `self.search_regex(selectable, regex, &_block)` at line 238.
pub fn ruby_search_l238_d9_self_search_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_regex', ...args)
}

// Ruby method `self.search_string(selectable, string, &_block)` at line 247.
pub fn ruby_search_l247_d10_self_search_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.search_string', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "description_cache_store"
// 5: require "utils/output"
// 6:
// 7: module Homebrew
// 8:   # Helper module for searching formulae or casks.
// 9:   module Search
// 10:     extend Utils::Output::Mixin
// 11:
// 12:     QUERY_REGEX = %r{^/(.*)/$}
// 13:
// 14:     SearchBlockType = T.type_alias do
// 15:       T.nilable(
// 16:         T.proc
// 17:          .params(arg0: T.any(T::Array[String], T::Array[T::Array[String]]))
// 18:          .returns(T.nilable(T.any(String, T::Array[String]))),
// 19:       )
// 20:     end
// 21:
// 22:     SearchResultType = T.type_alias do
// 23:       T.any(
// 24:         T::Array[String],
// 25:         T::Array[T::Array[String]],
// 26:         T::Hash[String, T.nilable(String)],
// 27:         T::Hash[String, T::Array[T.nilable(String)]],
// 28:       )
// 29:     end
// 30:
// 31:     SelectableType = T.type_alias do
// 32:       # These must define a `select` method that takes a block and returns an array or hash.
// 33:       # Since sorbet has minimal support for overloading sig, the return type must be casted to the actual type.
// 34:       # DescriptionCacheStore and Hash instances will return a Hash, other types will return an Array.
// 35:       T.any(DescriptionCacheStore, SearchResultType)
// 36:     end
// 37:
// 38:     sig { params(query: String).returns(T.any(Regexp, String)) }
// 39:     def self.query_regexp(query)
// 40:       if (m = query.match(QUERY_REGEX))
// 41:         Regexp.new(T.must(m[1]))
// 42:       else
// 43:         query
// 44:       end
// 45:     rescue RegexpError
// 46:       raise "#{query} is not a valid regex."
// 47:     end
// 48:
// 49:     sig { params(_cask: Cask::Cask).returns(T::Boolean) }
// 50:     def self.ignore_cask?(_cask) = false
// 51:
// 52:     T::Sig::WithoutRuntime.sig {
// 53:       params(
// 54:         string_or_regex: T.any(Regexp, String),
// 55:         # These must define `cask?`, `eval_all?`, and `formula?` methods.
// 56:         # Since only one command is typically loaded at a time, this alias is not expected to be available at runtime.
// 57:         args:            T.any(Homebrew::Cmd::Desc::Args, Homebrew::Cmd::SearchCmd::Args),
// 58:         search_type:     T.nilable(Descriptions::SearchField),
// 59:         show_missing:    T::Boolean,
// 60:       ).void
// 61:     }
// 62:     def self.search_descriptions(string_or_regex, args, search_type: nil, show_missing: false)
// 63:       require "descriptions"
// 64:
// 65:       search_type ||= Descriptions::SearchField::Description
// 66:       both = !args.formula? && !args.cask?
// 67:       eval_all = args.eval_all? || Homebrew::EnvConfig.tap_trust_configured?
// 68:
// 69:       if args.formula? || both
// 70:         ohai "Formulae"
// 71:         if eval_all
// 72:           CacheStoreDatabase.use(:descriptions) do |db|
// 73:             cache_store = DescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 74:             Descriptions.search(string_or_regex, search_type, cache_store, eval_all:).print
// 75:           end
// 76:         else
// 77:           unofficial = Tap.all.sum { |tap| tap.official? ? 0 : tap.formula_files.size }
// 78:           if unofficial.positive?
// 79:             opoo "Set `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` to search " \
// 80:                  "#{unofficial} additional " \
// 81:                  "#{Utils.pluralize("formula", unofficial)} in third party taps."
// 82:           end
// 83:           formulae = Homebrew::API::Internal.formula_hashes
// 84:           descriptions = formulae.transform_values { |data| data["desc"] }
// 85:           status_data = formulae.transform_values do |data|
// 86:             { deprecated: data["deprecate_present"].present?, disabled: data["disable_present"].present? }
// 87:           end
// 88:           Descriptions.search(string_or_regex, search_type, descriptions, status_data:, eval_all:).print
// 89:         end
// 90:       end
// 91:       return if !args.cask? && !both
// 92:
// 93:       puts if both
// 94:
// 95:       ohai "Casks"
// 96:       if eval_all
// 97:         CacheStoreDatabase.use(:cask_descriptions) do |db|
// 98:           cache_store = CaskDescriptionCacheStore.new(T.cast(db, CacheStoreDatabase[String, T.anything]))
// 99:           Descriptions.search(string_or_regex, search_type, cache_store, eval_all:).print(show_missing:)
// 100:         end
// 101:       else
// 102:         unofficial = Tap.all.sum { |tap| tap.official? ? 0 : tap.cask_files.size }
// 103:         if unofficial.positive?
// 104:           opoo "Set `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` to search " \
// 105:                "#{unofficial} additional " \
// 106:                "#{Utils.pluralize("cask", unofficial)} in third party taps."
// 107:         end
// 108:         casks = Homebrew::API::Internal.cask_hashes
// 109:         descriptions = casks.transform_values { |cask| [cask["names"].join(", "), cask["desc"]] }
// 110:         status_data = casks.transform_values do |cask|
// 111:           { deprecated: cask["deprecate_present"].present?, disabled: cask["disable_present"].present? }
// 112:         end
// 113:         Descriptions.search(string_or_regex, search_type, descriptions, status_data:, eval_all:).print(show_missing:)
// 114:       end
// 115:     end
// 116:
// 117:     sig { params(string_or_regex: T.any(Regexp, String)).returns(T::Array[String]) }
// 118:     def self.search_formulae(string_or_regex)
// 119:       if string_or_regex.is_a?(String) && string_or_regex.match?(HOMEBREW_TAP_FORMULA_REGEX)
// 120:         return begin
// 121:           [Formulary.factory(string_or_regex).name]
// 122:         rescue FormulaUnavailableError
// 123:           []
// 124:         end
// 125:       end
// 126:
// 127:       aliases = Formula.alias_full_names
// 128:       results = T.cast(search(Formula.full_names + aliases, string_or_regex), T::Array[String]).sort
// 129:       if string_or_regex.is_a?(String)
// 130:         results |= Formula.fuzzy_search(string_or_regex).map do |n|
// 131:           Formulary.factory(n).full_name
// 132:         end
// 133:       end
// 134:
// 135:       results.filter_map do |name|
// 136:         formula, canonical_full_name = begin
// 137:           f = Formulary.factory(name)
// 138:           [f, f.full_name]
// 139:         rescue
// 140:           [nil, name]
// 141:         end
// 142:
// 143:         # Ignore aliases from results when the full name was also found
// 144:         next if aliases.include?(name) && results.include?(canonical_full_name)
// 145:
// 146:         installed = formula&.any_version_installed? == true
// 147:         next if formula && !formula.valid_platform? && !installed
// 148:
// 149:         pretty_install_status(
// 150:           name,
// 151:           installed:,
// 152:           deprecated:       formula&.deprecated? == true,
// 153:           disabled:         formula&.disabled? == true,
// 154:           mark_uninstalled: false,
// 155:         )
// 156:       end
// 157:     end
// 158:
// 159:     sig { params(string_or_regex: T.any(Regexp, String)).returns(T::Array[String]) }
// 160:     def self.search_casks(string_or_regex)
// 161:       if string_or_regex.is_a?(String) && string_or_regex.match?(HOMEBREW_TAP_CASK_REGEX)
// 162:         return begin
// 163:           matched_cask = Cask::CaskLoader.load(string_or_regex)
// 164:           ignore_cask?(matched_cask) ? [] : [matched_cask.token]
// 165:         rescue Cask::CaskUnavailableError
// 166:           []
// 167:         end
// 168:       end
// 169:
// 170:       cask_tokens = Tap.each_with_object([]) do |tap, array|
// 171:         # We can exclude the core cask tap because `CoreCaskTap#cask_tokens` returns short names by default.
// 172:         if tap.official? && !tap.core_cask_tap?
// 173:           tap.cask_tokens.each { |token| array << token.sub(%r{^homebrew/cask.*/}, "") }
// 174:         else
// 175:           tap.cask_tokens.each { |token| array << token }
// 176:         end
// 177:       end.uniq
// 178:
// 179:       results = T.cast(search(cask_tokens, string_or_regex), T::Array[String])
// 180:       if string_or_regex.is_a?(String)
// 181:         results += DidYouMean::SpellChecker.new(dictionary: cask_tokens)
// 182:                                            .correct(string_or_regex)
// 183:       end
// 184:
// 185:       results.sort.filter_map do |name|
// 186:         cask = Cask::CaskLoader.load(name.to_s)
// 187:         next if ignore_cask?(cask)
// 188:
// 189:         pretty_install_status(
// 190:           cask.full_name,
// 191:           installed:        cask.installed?,
// 192:           deprecated:       cask.deprecated?,
// 193:           disabled:         cask.disabled?,
// 194:           mark_uninstalled: false,
// 195:         )
// 196:       end.uniq
// 197:     end
// 198:
// 199:     T::Sig::WithoutRuntime.sig {
// 200:       params(
// 201:         string_or_regex: T.any(Regexp, String),
// 202:         # These must define `cask?`, and `formula?` methods.
// 203:         # Since only one command is typically loaded at a time, this alias is not expected to be available at runtime.
// 204:         args:            T.any(Homebrew::Cmd::Desc::Args, Homebrew::Cmd::InstallCmd::Args, Homebrew::Cmd::SearchCmd::Args),
// 205:       ).returns([T::Array[String], T::Array[String]])
// 206:     }
// 207:     def self.search_names(string_or_regex, args)
// 208:       if !args.formula? && !args.cask? # both
// 209:         [search_formulae(string_or_regex), search_casks(string_or_regex)]
// 210:       elsif args.formula?
// 211:         [search_formulae(string_or_regex), []]
// 212:       elsif args.cask?
// 213:         [[], search_casks(string_or_regex)]
// 214:       else
// 215:         [[], []]
// 216:       end
// 217:     end
// 218:
// 219:     sig {
// 220:       params(selectable: SelectableType, string_or_regex: T.any(Regexp, String), block: SearchBlockType)
// 221:         .returns(SearchResultType)
// 222:     }
// 223:     def self.search(selectable, string_or_regex, &block)
// 224:       case string_or_regex
// 225:       when Regexp
// 226:         search_regex(selectable, string_or_regex, &block)
// 227:       else
// 228:         search_string(selectable, string_or_regex.to_str, &block)
// 229:       end
// 230:     end
// 231:
// 232:     sig { params(string: String).returns(String) }
// 233:     def self.simplify_string(string)
// 234:       string.downcase.gsub(/[^a-z\d@+]/i, "")
// 235:     end
// 236:
// 237:     sig { params(selectable: SelectableType, regex: Regexp, _block: SearchBlockType).returns(SearchResultType) }
// 238:     def self.search_regex(selectable, regex, &_block)
// 239:       selectable.select do |*args|
// 240:         args = yield(*args) if block_given?
// 241:         args = Array(args).flatten.compact
// 242:         args.any? { |arg| arg.match?(regex) }
// 243:       end
// 244:     end
// 245:
// 246:     sig { params(selectable: SelectableType, string: String, _block: SearchBlockType).returns(SearchResultType) }
// 247:     def self.search_string(selectable, string, &_block)
// 248:       simplified_string = simplify_string(string)
// 249:       selectable.select do |*args|
// 250:         args = yield(*args) if block_given?
// 251:         args = Array(args).flatten.compact
// 252:         args.any? { |arg| simplify_string(arg).include?(simplified_string) }
// 253:       end
// 254:     end
// 255:   end
// 256: end
// 257:
// 258: require "extend/os/search"
