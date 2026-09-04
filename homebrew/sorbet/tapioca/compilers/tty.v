module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/tty.rb`.
// The original source is retained below until every stub has a typed V body.
pub const tty_compiler_dynamic_methods = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan',
	'default', 'reset', 'bold', 'italic', 'underline', 'strikethrough', 'no_underline', 'up', 'down',
	'right', 'left', 'erase_line', 'erase_char']

pub fn tty_compiler_decoration(constant_name string) TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'module'
		methods: tty_compiler_dynamic_methods.map(TapiocaGeneratedMethod{
			name: it
			return_type: 'String'
			class_method: true
		})
	}
}

// Ruby method `self.gather_constants = [::Tty]` at line 13.
pub fn ruby_tty_l13_d1_self_gather_constants(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([ruby.object_value('Module', 'Tty')])
}

// Ruby method `decorate` at line 16.
pub fn ruby_tty_l16_d2_decorate(args ...ruby.Value) ruby.Value {
	constant_name := if args.len > 0 { args[0].as_string() } else { 'Tty' }
	return tapioca_decoration_value(tty_compiler_decoration(constant_name))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "utils/tty"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class Tty < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [::Tty]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_module(T.must(constant.name)) do |mod|
// 18:           dynamic_methods = ::Tty::COLOR_CODES.keys + ::Tty::STYLE_CODES.keys + ::Tty::SPECIAL_CODES.keys
// 19:
// 20:           dynamic_methods.each do |method|
// 21:             mod.create_method(method.to_s, return_type: "String", class_method: true)
// 22:           end
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
