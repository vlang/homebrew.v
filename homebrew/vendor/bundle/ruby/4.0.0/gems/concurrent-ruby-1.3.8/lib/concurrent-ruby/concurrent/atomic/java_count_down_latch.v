module atomic

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/java_count_down_latch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(count = 1)` at line 12.
pub fn ruby_java_count_down_latch_l12_d1_initialize(args ...ruby.Value) ruby.Value {
	return latch_boundary_new(latch_boundary_count(args, 0, 1), 'Concurrent::JavaCountDownLatch')
}

// Ruby method `wait(timeout = nil)` at line 19.
pub fn ruby_java_count_down_latch_l19_d2_wait(args ...ruby.Value) ruby.Value {
	mut latch := latch_boundary_receiver(args)
	return ruby.bool_value(latch.wait(latch_boundary_timeout(args, 1)))
}

// Ruby method `count_down` at line 33.
pub fn ruby_java_count_down_latch_l33_d3_count_down(args ...ruby.Value) ruby.Value {
	mut latch := latch_boundary_receiver(args)
	latch.count_down()
	return args[0]
}

// Ruby method `count` at line 38.
pub fn ruby_java_count_down_latch_l38_d4_count(args ...ruby.Value) ruby.Value {
	mut latch := latch_boundary_receiver(args)
	return ruby.int_value(latch.count())
}

// Original Ruby source (line-for-line):
// 1: if Concurrent.on_jruby?
// 2:   require 'concurrent/utility/native_extension_loader'
// 3:
// 4:   module Concurrent
// 5:
// 6:     # @!macro count_down_latch
// 7:     # @!visibility private
// 8:     # @!macro internal_implementation_note
// 9:     class JavaCountDownLatch
// 10:
// 11:       # @!macro count_down_latch_method_initialize
// 12:       def initialize(count = 1)
// 13:         Utility::NativeInteger.ensure_integer_and_bounds(count)
// 14:         Utility::NativeInteger.ensure_positive(count)
// 15:         @latch = java.util.concurrent.CountDownLatch.new(count)
// 16:       end
// 17:
// 18:       # @!macro count_down_latch_method_wait
// 19:       def wait(timeout = nil)
// 20:         result = nil
// 21:         if timeout.nil?
// 22:           Synchronization::JRuby.sleep_interruptibly { @latch.await }
// 23:           result = true
// 24:         else
// 25:           Synchronization::JRuby.sleep_interruptibly do
// 26:             result = @latch.await(1000 * timeout, java.util.concurrent.TimeUnit::MILLISECONDS)
// 27:           end
// 28:         end
// 29:         result
// 30:       end
// 31:
// 32:       # @!macro count_down_latch_method_count_down
// 33:       def count_down
// 34:         @latch.countDown
// 35:       end
// 36:
// 37:       # @!macro count_down_latch_method_count
// 38:       def count
// 39:         @latch.getCount
// 40:       end
// 41:     end
// 42:   end
// 43: end
