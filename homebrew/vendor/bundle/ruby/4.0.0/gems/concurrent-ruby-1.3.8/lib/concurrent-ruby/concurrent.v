module concurrent_ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/version'
// 2: require 'concurrent/constants'
// 3: require 'concurrent/errors'
// 4: require 'concurrent/configuration'
// 5:
// 6: require 'concurrent/atomics'
// 7: require 'concurrent/executors'
// 8: require 'concurrent/synchronization'
// 9:
// 10: require 'concurrent/atomic/atomic_markable_reference'
// 11: require 'concurrent/atomic/atomic_reference'
// 12: require 'concurrent/agent'
// 13: require 'concurrent/atom'
// 14: require 'concurrent/array'
// 15: require 'concurrent/hash'
// 16: require 'concurrent/set'
// 17: require 'concurrent/map'
// 18: require 'concurrent/tuple'
// 19: require 'concurrent/async'
// 20: require 'concurrent/dataflow'
// 21: require 'concurrent/delay'
// 22: require 'concurrent/exchanger'
// 23: require 'concurrent/future'
// 24: require 'concurrent/immutable_struct'
// 25: require 'concurrent/ivar'
// 26: require 'concurrent/maybe'
// 27: require 'concurrent/mutable_struct'
// 28: require 'concurrent/mvar'
// 29: require 'concurrent/promise'
// 30: require 'concurrent/scheduled_task'
// 31: require 'concurrent/settable_struct'
// 32: require 'concurrent/timer_task'
// 33: require 'concurrent/tvar'
// 34: require 'concurrent/promises'
// 35:
// 36: require 'concurrent/thread_safe/synchronized_delegator'
// 37: require 'concurrent/thread_safe/util'
// 38:
// 39: require 'concurrent/options'
// 40:
// 41: # @!macro internal_implementation_note
// 42: #
// 43: #   @note **Private Implementation:** This abstraction is a private, internal
// 44: #     implementation detail. It should never be used directly.
// 45:
// 46: # @!macro monotonic_clock_warning
// 47: #
// 48: #   @note Time calculations on all platforms and languages are sensitive to
// 49: #     changes to the system clock. To alleviate the potential problems
// 50: #     associated with changing the system clock while an application is running,
// 51: #     most modern operating systems provide a monotonic clock that operates
// 52: #     independently of the system clock. A monotonic clock cannot be used to
// 53: #     determine human-friendly clock times. A monotonic clock is used exclusively
// 54: #     for calculating time intervals. Not all Ruby platforms provide access to an
// 55: #     operating system monotonic clock. On these platforms a pure-Ruby monotonic
// 56: #     clock will be used as a fallback. An operating system monotonic clock is both
// 57: #     faster and more reliable than the pure-Ruby implementation. The pure-Ruby
// 58: #     implementation should be fast and reliable enough for most non-realtime
// 59: #     operations. At this time the common Ruby platforms that provide access to an
// 60: #     operating system monotonic clock are MRI 2.1 and above and JRuby (all versions).
// 61: #
// 62: #   @see http://linux.die.net/man/3/clock_gettime Linux clock_gettime(3)
// 63:
// 64: # @!macro copy_options
// 65: #
// 66: #   ## Copy Options
// 67: #
// 68: #   Object references in Ruby are mutable. This can lead to serious
// 69: #   problems when the {#value} of an object is a mutable reference. Which
// 70: #   is always the case unless the value is a `Fixnum`, `Symbol`, or similar
// 71: #   "primitive" data type. Each instance can be configured with a few
// 72: #   options that can help protect the program from potentially dangerous
// 73: #   operations. Each of these options can be optionally set when the object
// 74: #   instance is created:
// 75: #
// 76: #   * `:dup_on_deref` When true the object will call the `#dup` method on
// 77: #     the `value` object every time the `#value` method is called
// 78: #     (default: false)
// 79: #   * `:freeze_on_deref` When true the object will call the `#freeze`
// 80: #     method on the `value` object every time the `#value` method is called
// 81: #     (default: false)
// 82: #   * `:copy_on_deref` When given a `Proc` object the `Proc` will be run
// 83: #     every time   the `#value` method is called. The `Proc` will be given
// 84: #     the current `value` as its only argument and the result returned by
// 85: #     the block will be the return   value of the `#value` call. When `nil`
// 86: #     this option will be ignored (default: nil)
// 87: #
// 88: #   When multiple deref options are set the order of operations is strictly defined.
// 89: #   The order of deref operations is:
// 90: #   * `:copy_on_deref`
// 91: #   * `:dup_on_deref`
// 92: #   * `:freeze_on_deref`
// 93: #
// 94: #   Because of this ordering there is no need to `#freeze` an object created by a
// 95: #   provided `:copy_on_deref` block. Simply set `:freeze_on_deref` to `true`.
// 96: #   Setting both `:dup_on_deref` to `true` and `:freeze_on_deref` to `true` is
// 97: #   as close to the behavior of a "pure" functional language (like Erlang, Clojure,
// 98: #   or Haskell) as we are likely to get in Ruby.
// 99:
// 100: # @!macro deref_options
// 101: #
// 102: #   @option opts [Boolean] :dup_on_deref (false) Call `#dup` before
// 103: #     returning the data from {#value}
// 104: #   @option opts [Boolean] :freeze_on_deref (false) Call `#freeze` before
// 105: #     returning the data from {#value}
// 106: #   @option opts [Proc] :copy_on_deref (nil) When calling the {#value}
// 107: #     method, call the given proc passing the internal value as the sole
// 108: #     argument then return the new value returned from the proc.
// 109:
// 110: # @!macro executor_and_deref_options
// 111: #
// 112: #   @param [Hash] opts the options used to define the behavior at update and deref
// 113: #     and to specify the executor on which to perform actions
// 114: #   @option opts [Executor] :executor when set use the given `Executor` instance.
// 115: #     Three special values are also supported: `:io` returns the global pool for
// 116: #     long, blocking (IO) tasks, `:fast` returns the global pool for short, fast
// 117: #     operations, and `:immediate` returns the global `ImmediateExecutor` object.
// 118: #   @!macro deref_options
// 119:
// 120: # @!macro warn.edge
// 121: #   @api Edge
// 122: #   @note **Edge Features** are under active development and may change frequently.
// 123: #
// 124: #     -   Deprecations are not added before incompatible changes.
// 125: #     -   Edge version: _major_ is always 0, _minor_ bump means incompatible change,
// 126: #         _patch_ bump means compatible change.
// 127: #     -   Edge features may also lack tests and documentation.
// 128: #     -   Features developed in `concurrent-ruby-edge` are expected to move
// 129: #         to `concurrent-ruby` when finalised.
// 130:
// 131:
// 132: # {include:file:README.md}
// 133: module Concurrent
// 134: end
