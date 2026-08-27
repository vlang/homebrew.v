module concern

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/deprecation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `deprecated(message, strip = 2)` at line 12.
pub fn ruby_deprecation_l12_d1_deprecated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deprecated', ...args)
}

// Ruby method `deprecated_method(old_name, new_name)` at line 27.
pub fn ruby_deprecation_l27_d2_deprecated_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deprecated_method', ...args)
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
