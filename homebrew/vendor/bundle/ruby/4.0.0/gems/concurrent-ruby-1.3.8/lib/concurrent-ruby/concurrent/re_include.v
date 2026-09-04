module concurrent

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/re_include.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ReIncludeMethod {
	include_module
	extend_module
}

pub struct ReIncludeTarget {
pub:
	method ReIncludeMethod
	base   string
}

pub struct ReIncludeOperation {
pub:
	method ReIncludeMethod
	base   string
	module string
}

pub struct ReInclude {
mut:
	targets []ReIncludeTarget
}

pub fn (mut re_include ReInclude) included(base string) string {
	re_include.targets << ReIncludeTarget{
		method: .include_module
		base: base
	}
	return base
}

pub fn (mut re_include ReInclude) extended(base string) string {
	re_include.targets << ReIncludeTarget{
		method: .extend_module
		base: base
	}
	return base
}

pub fn (re_include ReInclude) include_modules(modules []string) []ReIncludeOperation {
	mut operations := []ReIncludeOperation{cap: modules.len * re_include.targets.len}
	for module_name in modules.reverse() {
		for target in re_include.targets {
			operations << ReIncludeOperation{
				method: target.method
				base: target.base
				module: module_name
			}
		}
	}
	return operations
}

// Ruby method `included(base)` at line 38.
pub fn ruby_re_include_l38_d1_included(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.object_value('NilClass', 'nil') }
}

// Ruby method `extended(base)` at line 44.
pub fn ruby_re_include_l44_d2_extended(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.object_value('NilClass', 'nil') }
}

// Ruby method `include(*modules)` at line 50.
pub fn ruby_re_include_l50_d3_include(args ...ruby.Value) ruby.Value {
	return ruby.array_value(args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   # Methods form module A included to a module B, which is already included into class C,
// 4:   # will not be visible in the C class. If this module is extended to B then A's methods
// 5:   # are correctly made visible to C.
// 6:   #
// 7:   # @example
// 8:   #   module A
// 9:   #     def a
// 10:   #       :a
// 11:   #     end
// 12:   #   end
// 13:   #
// 14:   #   module B1
// 15:   #   end
// 16:   #
// 17:   #   class C1
// 18:   #     include B1
// 19:   #   end
// 20:   #
// 21:   #   module B2
// 22:   #     extend Concurrent::ReInclude
// 23:   #   end
// 24:   #
// 25:   #   class C2
// 26:   #     include B2
// 27:   #   end
// 28:   #
// 29:   #   B1.send :include, A
// 30:   #   B2.send :include, A
// 31:   #
// 32:   #   C1.new.respond_to? :a # => false
// 33:   #   C2.new.respond_to? :a # => true
// 34:   #
// 35:   # @!visibility private
// 36:   module ReInclude
// 37:     # @!visibility private
// 38:     def included(base)
// 39:       (@re_include_to_bases ||= []) << [:include, base]
// 40:       super(base)
// 41:     end
// 42:
// 43:     # @!visibility private
// 44:     def extended(base)
// 45:       (@re_include_to_bases ||= []) << [:extend, base]
// 46:       super(base)
// 47:     end
// 48:
// 49:     # @!visibility private
// 50:     def include(*modules)
// 51:       result = super(*modules)
// 52:       modules.reverse.each do |module_being_included|
// 53:         (@re_include_to_bases ||= []).each do |method, mod|
// 54:           mod.send method, module_being_included
// 55:         end
// 56:       end
// 57:       result
// 58:     end
// 59:   end
// 60: end
