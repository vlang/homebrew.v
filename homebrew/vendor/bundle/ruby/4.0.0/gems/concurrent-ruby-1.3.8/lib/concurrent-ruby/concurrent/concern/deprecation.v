module concern

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/deprecation.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn deprecation_message(message string, caller_line string, strip int) string {
	if strip > 0 {
		return '[DEPRECATED] ${message}\ncalled on: ${caller_line}'
	}
	return '[DEPRECATED] ${message}'
}

pub fn deprecated_method_message(old_name string, new_name string) string {
	return "`${old_name}` is deprecated and it'll removed in next release, use `${new_name}` instead"
}

// Ruby method `deprecated(message, strip = 2)` at line 12.
pub fn ruby_deprecation_l12_d1_deprecated(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('deprecated requires a message')
	}
	strip := if args.len > 1 { int(args[1].as_int() or { 2 }) } else { 2 }
	caller_line := if args.len > 2 { args[2].as_string() } else { '' }
	return ruby.string_value(deprecation_message(args[0].as_string(), caller_line, strip))
}

// Ruby method `deprecated_method(old_name, new_name)` at line 27.
pub fn ruby_deprecation_l27_d2_deprecated_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('deprecated_method requires old and new names')
	}
	return ruby.string_value(deprecated_method_message(args[0].as_string(), args[1].as_string()))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/concern/logging'
// 2:
// 3: module Concurrent
// 4:   module Concern
// 5:
// 6:     # @!visibility private
// 7:     # @!macro internal_implementation_note
// 8:     module Deprecation
// 9:       # TODO require additional parameter: a version. Display when it'll be removed based on that. Error if not removed.
// 10:       include Concern::Logging
// 11:
// 12:       def deprecated(message, strip = 2)
// 13:         caller_line = caller(strip).first if strip > 0
// 14:         klass       = if Module === self
// 15:                         self
// 16:                       else
// 17:                         self.class
// 18:                       end
// 19:         message     = if strip > 0
// 20:                         format("[DEPRECATED] %s\ncalled on: %s", message, caller_line)
// 21:                       else
// 22:                         format('[DEPRECATED] %s', message)
// 23:                       end
// 24:         log WARN, klass.to_s, message
// 25:       end
// 26:
// 27:       def deprecated_method(old_name, new_name)
// 28:         deprecated "`#{old_name}` is deprecated and it'll removed in next release, use `#{new_name}` instead", 3
// 29:       end
// 30:
// 31:       extend self
// 32:     end
// 33:   end
// 34: end
