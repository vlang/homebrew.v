module homebrew

import ruby

// Translated from Homebrew/brew `fetch.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FetchBottleFormula {
pub:
	full_name            string
	bottle_present       bool
	pour_bottle          bool
	compatible_locations bool
	bottled_tags         []string
}

pub struct FetchBottleOptions {
pub:
	force_bottle               bool
	bottle_tag                 string
	build_from_source_formulae []string
	os                         string
	arch                       string
	test_generic_os            bool
}

pub fn fetch_bottle(formula FetchBottleFormula, options FetchBottleOptions) bool {
	if options.force_bottle && formula.bottle_present {
		return true
	}
	if options.os != '' {
		return true
	}
	if options.test_generic_os {
		return false
	}
	if options.arch != '' {
		return true
	}
	if options.bottle_tag != '' && options.bottle_tag in formula.bottled_tags {
		return true
	}
	return formula.bottle_present && formula.pour_bottle && formula.full_name !in options.build_from_source_formulae && formula.compatible_locations
}

// Ruby method `fetch_bottle?(formula, force_bottle:, bottle_tag:, build_from_source_formulae:, os:, arch:)` at line 16.
pub fn ruby_fetch_l16_d1_fetch_bottle(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	formula_value := args[0]
	formula := FetchBottleFormula{
		full_name: formula_value.attributes['full_name'] or { formula_value.as_string() }
		bottle_present: (formula_value.attributes['bottle_present'] or { 'false' }).bool()
		pour_bottle: (formula_value.attributes['pour_bottle'] or { 'false' }).bool()
		compatible_locations: (formula_value.attributes['compatible_locations'] or { 'false' }).bool()
		bottled_tags: (formula_value.attributes['bottled_tags'] or { '' }).split(',').filter(it != '')
	}
	options := FetchBottleOptions{
		force_bottle: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		bottle_tag: if args.len > 2 { args[2].as_string() } else { '' }
		build_from_source_formulae: if args.len > 3 {
			args[3].as_string_array() or { []string{} }} else {
			[]string{}}
		os: if args.len > 4 { args[4].as_string() } else { '' }
		arch: if args.len > 5 { args[5].as_string() } else { '' }
		test_generic_os: if args.len > 6 { args[6].as_bool() or { false } } else { false }
	}
	return ruby.bool_value(fetch_bottle(formula, options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Fetch
// 6:     sig {
// 7:       params(
// 8:         formula:                    Formula,
// 9:         force_bottle:               T::Boolean,
// 10:         bottle_tag:                 T.nilable(Symbol),
// 11:         build_from_source_formulae: T::Array[String],
// 12:         os:                         T.nilable(Symbol),
// 13:         arch:                       T.nilable(Symbol),
// 14:       ).returns(T::Boolean)
// 15:     }
// 16:     def fetch_bottle?(formula, force_bottle:, bottle_tag:, build_from_source_formulae:, os:, arch:)
// 17:       bottle = formula.bottle
// 18:
// 19:       return true if force_bottle && bottle.present?
// 20:       if os.present?
// 21:         return true
// 22:       elsif ENV["HOMEBREW_TEST_GENERIC_OS"].present?
// 23:         # `:generic` bottles don't exist and `--os` flag is not specified.
// 24:         return false
// 25:       end
// 26:       return true if arch.present?
// 27:       return true if bottle_tag.present? && formula.bottled?(bottle_tag)
// 28:
// 29:       bottle.present? &&
// 30:         formula.pour_bottle? &&
// 31:         build_from_source_formulae.exclude?(formula.full_name) &&
// 32:         bottle.compatible_locations?
// 33:     end
// 34:   end
// 35: end
