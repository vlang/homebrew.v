module concurrent

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/array.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/thread_safe/util'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro concurrent_array
// 7:   #
// 8:   #   A thread-safe subclass of Array. This version locks against the object
// 9:   #   itself for every method call, ensuring only one thread can be reading
// 10:   #   or writing at a time. This includes iteration methods like `#each`.
// 11:   #
// 12:   #   @note `a += b` is **not** a **thread-safe** operation on
// 13:   #     `Concurrent::Array`. It reads array `a`, then it creates new `Concurrent::Array`
// 14:   #     which is concatenation of `a` and `b`, then it writes the concatenation to `a`.
// 15:   #     The read and write are independent operations they do not form a single atomic
// 16:   #     operation therefore when two `+=` operations are executed concurrently updates
// 17:   #     may be lost. Use `#concat` instead.
// 18:   #
// 19:   #   @see http://ruby-doc.org/core/Array.html Ruby standard library `Array`
// 20:
// 21:   # @!macro internal_implementation_note
// 22:   ArrayImplementation = case
// 23:                         when Concurrent.on_cruby?
// 24:                           # Array is not fully thread-safe on CRuby, see
// 25:                           # https://github.com/ruby-concurrency/concurrent-ruby/issues/929
// 26:                           # So we will need to add synchronization here
// 27:                           ::Array
// 28:
// 29:                         when Concurrent.on_jruby?
// 30:                           require 'jruby/synchronized'
// 31:
// 32:                           class JRubyArray < ::Array
// 33:                             include JRuby::Synchronized
// 34:                           end
// 35:                           JRubyArray
// 36:
// 37:                         when Concurrent.on_truffleruby?
// 38:                           require 'concurrent/thread_safe/util/data_structures'
// 39:
// 40:                           class TruffleRubyArray < ::Array
// 41:                           end
// 42:
// 43:                           ThreadSafe::Util.make_synchronized_on_truffleruby TruffleRubyArray
// 44:                           TruffleRubyArray
// 45:
// 46:                         else
// 47:                           warn 'Possibly unsupported Ruby implementation'
// 48:                           ::Array
// 49:                         end
// 50:   private_constant :ArrayImplementation
// 51:
// 52:   # @!macro concurrent_array
// 53:   class Array < ArrayImplementation
// 54:   end
// 55:
// 56: end
