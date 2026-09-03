module synchronization

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/abstract_lockable_object.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `synchronize` at line 18.
pub fn ruby_abstract_lockable_object_l18_d1_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('NotImplementedError', 'synchronize', {
		'method': 'synchronize'
	})
}

// Ruby method `ns_wait_until(timeout = nil, &condition)` at line 37.
pub fn ruby_abstract_lockable_object_l37_d2_ns_wait_until(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 && args[args.len - 1].type_name == 'Bool' {
		return args[args.len - 1]
	}
	return brew_runtime.bool_value(false)
}

// Ruby method `ns_wait(timeout = nil)` at line 66.
pub fn ruby_abstract_lockable_object_l66_d3_ns_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('NotImplementedError', 'ns_wait', {
		'method': 'ns_wait'
	})
}

// Ruby method `ns_signal` at line 81.
pub fn ruby_abstract_lockable_object_l81_d4_ns_signal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('NotImplementedError', 'ns_signal', {
		'method': 'ns_signal'
	})
}

// Ruby method `ns_broadcast` at line 96.
pub fn ruby_abstract_lockable_object_l96_d5_ns_broadcast(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('NotImplementedError', 'ns_broadcast', {
		'method': 'ns_broadcast'
	})
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2: require 'concurrent/utility/monotonic_time'
// 3: require 'concurrent/synchronization/object'
// 4:
// 5: module Concurrent
// 6:   module Synchronization
// 7:
// 8:     # @!visibility private
// 9:     class AbstractLockableObject < Synchronization::Object
// 10:
// 11:       protected
// 12:
// 13:       # @!macro synchronization_object_method_synchronize
// 14:       #
// 15:       #   @yield runs the block synchronized against this object,
// 16:       #     equivalent of java's `synchronize(this) {}`
// 17:       #   @note can by made public in descendants if required by `public :synchronize`
// 18:       def synchronize
// 19:         raise NotImplementedError
// 20:       end
// 21:
// 22:       # @!macro synchronization_object_method_ns_wait_until
// 23:       #
// 24:       #   Wait until condition is met or timeout passes,
// 25:       #   protects against spurious wake-ups.
// 26:       #   @param [Numeric, nil] timeout in seconds, `nil` means no timeout
// 27:       #   @yield condition to be met
// 28:       #   @yieldreturn [true, false]
// 29:       #   @return [true, false] if condition met
// 30:       #   @note only to be used inside synchronized block
// 31:       #   @note to provide direct access to this method in a descendant add method
// 32:       #     ```
// 33:       #     def wait_until(timeout = nil, &condition)
// 34:       #       synchronize { ns_wait_until(timeout, &condition) }
// 35:       #     end
// 36:       #     ```
// 37:       def ns_wait_until(timeout = nil, &condition)
// 38:         if timeout
// 39:           wait_until = Concurrent.monotonic_time + timeout
// 40:           loop do
// 41:             now = Concurrent.monotonic_time
// 42:             condition_result = condition.call
// 43:             return condition_result if now >= wait_until || condition_result
// 44:             ns_wait wait_until - now
// 45:           end
// 46:         else
// 47:           ns_wait timeout until condition.call
// 48:           true
// 49:         end
// 50:       end
// 51:
// 52:       # @!macro synchronization_object_method_ns_wait
// 53:       #
// 54:       #   Wait until another thread calls #signal or #broadcast,
// 55:       #   spurious wake-ups can happen.
// 56:       #
// 57:       #   @param [Numeric, nil] timeout in seconds, `nil` means no timeout
// 58:       #   @return [self]
// 59:       #   @note only to be used inside synchronized block
// 60:       #   @note to provide direct access to this method in a descendant add method
// 61:       #     ```
// 62:       #     def wait(timeout = nil)
// 63:       #       synchronize { ns_wait(timeout) }
// 64:       #     end
// 65:       #     ```
// 66:       def ns_wait(timeout = nil)
// 67:         raise NotImplementedError
// 68:       end
// 69:
// 70:       # @!macro synchronization_object_method_ns_signal
// 71:       #
// 72:       #   Signal one waiting thread.
// 73:       #   @return [self]
// 74:       #   @note only to be used inside synchronized block
// 75:       #   @note to provide direct access to this method in a descendant add method
// 76:       #     ```
// 77:       #     def signal
// 78:       #       synchronize { ns_signal }
// 79:       #     end
// 80:       #     ```
// 81:       def ns_signal
// 82:         raise NotImplementedError
// 83:       end
// 84:
// 85:       # @!macro synchronization_object_method_ns_broadcast
// 86:       #
// 87:       #   Broadcast to all waiting threads.
// 88:       #   @return [self]
// 89:       #   @note only to be used inside synchronized block
// 90:       #   @note to provide direct access to this method in a descendant add method
// 91:       #     ```
// 92:       #     def broadcast
// 93:       #       synchronize { ns_broadcast }
// 94:       #     end
// 95:       #     ```
// 96:       def ns_broadcast
// 97:         raise NotImplementedError
// 98:       end
// 99:
// 100:     end
// 101:   end
// 102: end
