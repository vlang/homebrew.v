module helper

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/test_each.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `test_each(iter, &block)` at line 19.
pub fn ruby_test_each_l19_d1_test_each(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	return brew_runtime.array_value(test_each_values(args[0].as_array() or { [] }))
}

// Ruby method `test_each_hash(hash, &block)` at line 29.
pub fn ruby_test_each_l29_d2_test_each_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	pairs := test_each_hash_values(args[0].as_map() or { map[string]brew_runtime.Value{} })
	return brew_runtime.array_value(pairs.map(brew_runtime.array_value([
		brew_runtime.string_value(it.key),
		it.value,
	])))
}

pub struct TestEachPair {
pub:
	key   string
	value brew_runtime.Value
}

pub fn test_each_values(iter []brew_runtime.Value) []brew_runtime.Value {
	return iter.clone()
}

pub fn test_each_hash_values(hash map[string]brew_runtime.Value) []TestEachPair {
	mut pairs := []TestEachPair{cap: hash.len}
	for key, value in hash {
		pairs << TestEachPair{
			key: key
			value: value
		}
	}
	return pairs
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Test
// 5:   module Helper
// 6:     # Lets Sorbet see example groups generated from a table, which it cannot do
// 7:     # through a plain `each`.
// 8:     #
// 9:     # @see https://sorbet.org/docs/minitest#table-driven-tests-tests-defined-with-each
// 10:     module TestEach
// 11:       # `checked(:never)` because `HOMEBREW_SORBET_RECURSIVE` rejects a `Hash` here: it wants a tuple
// 12:       # element type, which plain array rows are not. A union instead leaves `U` unbound.
// 13:       sig {
// 14:         type_parameters(:U).params(
// 15:           iter:  T::Enumerable[T.type_parameter(:U)],
// 16:           block: T.proc.params(row: T.type_parameter(:U)).void,
// 17:         ).void.checked(:never)
// 18:       }
// 19:       def test_each(iter, &block)
// 20:         iter.each(&block)
// 21:       end
// 22:
// 23:       sig {
// 24:         type_parameters(:K, :V).params(
// 25:           hash:  T::Hash[T.type_parameter(:K), T.type_parameter(:V)],
// 26:           block: T.proc.params(pair: [T.type_parameter(:K), T.type_parameter(:V)]).void,
// 27:         ).void.checked(:never)
// 28:       }
// 29:       def test_each_hash(hash, &block)
// 30:         hash.each(&block)
// 31:       end
// 32:     end
// 33:   end
// 34: end
