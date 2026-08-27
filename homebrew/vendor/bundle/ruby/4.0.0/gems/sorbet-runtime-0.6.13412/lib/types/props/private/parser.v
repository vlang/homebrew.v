module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `parse(source)` at line 7.
pub fn ruby_parser_l7_d1_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse', ...args)
}

// Ruby method `s(type, *children)` at line 12.
pub fn ruby_parser_l12_d2_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('s', ...args)
}

// Ruby method `require_parser(*constants)` at line 17.
pub fn ruby_parser_l17_d3_require_parser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('require_parser', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props
// 5:   module Private
// 6:     module Parse
// 7:       def parse(source)
// 8:         @current_ruby ||= require_parser(:CurrentRuby)
// 9:         @current_ruby.parse(source)
// 10:       end
// 11:
// 12:       def s(type, *children)
// 13:         @node ||= require_parser(:AST, :Node)
// 14:         @node.new(type, children)
// 15:       end
// 16:
// 17:       private def require_parser(*constants)
// 18:         # This is an optional dependency for sorbet-runtime in general,
// 19:         # but is required here
// 20:         require 'parser/current'
// 21:
// 22:         # Hack to work around the static checker thinking the constant is
// 23:         # undefined
// 24:         cls = Kernel.const_get(:Parser, true)
// 25:         while (const = constants.shift)
// 26:           cls = cls.const_get(const, false)
// 27:         end
// 28:         cls
// 29:       end
// 30:     end
// 31:   end
// 32: end
