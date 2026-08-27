module synchronization

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/lockable_object.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/synchronization/abstract_lockable_object'
// 3: require 'concurrent/synchronization/mutex_lockable_object'
// 4: require 'concurrent/synchronization/jruby_lockable_object'
// 5:
// 6: module Concurrent
// 7:   module Synchronization
// 8:
// 9:     # @!visibility private
// 10:     # @!macro internal_implementation_note
// 11:     LockableObjectImplementation = case
// 12:                                    when Concurrent.on_cruby?
// 13:                                      MutexLockableObject
// 14:                                    when Concurrent.on_jruby?
// 15:                                      JRubyLockableObject
// 16:                                    when Concurrent.on_truffleruby?
// 17:                                      MutexLockableObject
// 18:                                    else
// 19:                                      warn 'Possibly unsupported Ruby implementation'
// 20:                                      MonitorLockableObject
// 21:                                    end
// 22:     private_constant :LockableObjectImplementation
// 23:
// 24:     #   Safe synchronization under any Ruby implementation.
// 25:     #   It provides methods like {#synchronize}, {#wait}, {#signal} and {#broadcast}.
// 26:     #   Provides a single layer which can improve its implementation over time without changes needed to
// 27:     #   the classes using it. Use {Synchronization::Object} not this abstract class.
// 28:     #
// 29:     #   @note this object does not support usage together with
// 30:     #     [`Thread#wakeup`](http://ruby-doc.org/core/Thread.html#method-i-wakeup)
// 31:     #     and [`Thread#raise`](http://ruby-doc.org/core/Thread.html#method-i-raise).
// 32:     #     `Thread#sleep` and `Thread#wakeup` will work as expected but mixing `Synchronization::Object#wait` and
// 33:     #     `Thread#wakeup` will not work on all platforms.
// 34:     #
// 35:     #   @see Event implementation as an example of this class use
// 36:     #
// 37:     #   @example simple
// 38:     #     class AnClass < Synchronization::Object
// 39:     #       def initialize
// 40:     #         super
// 41:     #         synchronize { @value = 'asd' }
// 42:     #       end
// 43:     #
// 44:     #       def value
// 45:     #         synchronize { @value }
// 46:     #       end
// 47:     #     end
// 48:     #
// 49:     # @!visibility private
// 50:     class LockableObject < LockableObjectImplementation
// 51:
// 52:       # TODO (pitr 12-Sep-2015): make private for c-r, prohibit subclassing
// 53:       # TODO (pitr 12-Sep-2015): we inherit too much ourselves :/
// 54:
// 55:       # @!method initialize(*args, &block)
// 56:       #   @!macro synchronization_object_method_initialize
// 57:
// 58:       # @!method synchronize
// 59:       #   @!macro synchronization_object_method_synchronize
// 60:
// 61:       # @!method wait_until(timeout = nil, &condition)
// 62:       #   @!macro synchronization_object_method_ns_wait_until
// 63:
// 64:       # @!method wait(timeout = nil)
// 65:       #   @!macro synchronization_object_method_ns_wait
// 66:
// 67:       # @!method signal
// 68:       #   @!macro synchronization_object_method_ns_signal
// 69:
// 70:       # @!method broadcast
// 71:       #   @!macro synchronization_object_method_ns_broadcast
// 72:
// 73:     end
// 74:   end
// 75: end
