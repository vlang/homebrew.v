module atomic

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/count_down_latch.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/atomic/mutex_count_down_latch'
// 3: require 'concurrent/atomic/java_count_down_latch'
// 4:
// 5: module Concurrent
// 6:
// 7:   ###################################################################
// 8:
// 9:   # @!macro count_down_latch_method_initialize
// 10:   #
// 11:   #   Create a new `CountDownLatch` with the initial `count`.
// 12:   #
// 13:   #   @param [new] count the initial count
// 14:   #
// 15:   #   @raise [ArgumentError] if `count` is not an integer or is less than zero
// 16:
// 17:   # @!macro count_down_latch_method_wait
// 18:   #
// 19:   #   Block on the latch until the counter reaches zero or until `timeout` is reached.
// 20:   #
// 21:   #   @param [Fixnum] timeout the number of seconds to wait for the counter or `nil`
// 22:   #     to block indefinitely
// 23:   #   @return [Boolean] `true` if the `count` reaches zero else false on `timeout`
// 24:
// 25:   # @!macro count_down_latch_method_count_down
// 26:   #
// 27:   #   Signal the latch to decrement the counter. Will signal all blocked threads when
// 28:   #   the `count` reaches zero.
// 29:
// 30:   # @!macro count_down_latch_method_count
// 31:   #
// 32:   #   The current value of the counter.
// 33:   #
// 34:   #   @return [Fixnum] the current value of the counter
// 35:
// 36:   ###################################################################
// 37:
// 38:   # @!macro count_down_latch_public_api
// 39:   #
// 40:   #   @!method initialize(count = 1)
// 41:   #     @!macro count_down_latch_method_initialize
// 42:   #
// 43:   #   @!method wait(timeout = nil)
// 44:   #     @!macro count_down_latch_method_wait
// 45:   #
// 46:   #   @!method count_down
// 47:   #     @!macro count_down_latch_method_count_down
// 48:   #
// 49:   #   @!method count
// 50:   #     @!macro count_down_latch_method_count
// 51:
// 52:   ###################################################################
// 53:
// 54:   # @!visibility private
// 55:   # @!macro internal_implementation_note
// 56:   CountDownLatchImplementation = case
// 57:                                  when Concurrent.on_jruby?
// 58:                                    JavaCountDownLatch
// 59:                                  else
// 60:                                    MutexCountDownLatch
// 61:                                  end
// 62:   private_constant :CountDownLatchImplementation
// 63:
// 64:   # @!macro count_down_latch
// 65:   #
// 66:   #   A synchronization object that allows one thread to wait on multiple other threads.
// 67:   #   The thread that will wait creates a `CountDownLatch` and sets the initial value
// 68:   #   (normally equal to the number of other threads). The initiating thread passes the
// 69:   #   latch to the other threads then waits for the other threads by calling the `#wait`
// 70:   #   method. Each of the other threads calls `#count_down` when done with its work.
// 71:   #   When the latch counter reaches zero the waiting thread is unblocked and continues
// 72:   #   with its work. A `CountDownLatch` can be used only once. Its value cannot be reset.
// 73:   #
// 74:   # @!macro count_down_latch_public_api
// 75:   # @example Waiter and Decrementer
// 76:   #   latch = Concurrent::CountDownLatch.new(3)
// 77:   #
// 78:   #   waiter = Thread.new do
// 79:   #     latch.wait()
// 80:   #     puts ("Waiter released")
// 81:   #   end
// 82:   #
// 83:   #   decrementer = Thread.new do
// 84:   #     sleep(1)
// 85:   #     latch.count_down
// 86:   #     puts latch.count
// 87:   #
// 88:   #     sleep(1)
// 89:   #     latch.count_down
// 90:   #     puts latch.count
// 91:   #
// 92:   #     sleep(1)
// 93:   #     latch.count_down
// 94:   #     puts latch.count
// 95:   #   end
// 96:   #
// 97:   #   [waiter, decrementer].each(&:join)
// 98:   class CountDownLatch < CountDownLatchImplementation
// 99:   end
// 100: end
