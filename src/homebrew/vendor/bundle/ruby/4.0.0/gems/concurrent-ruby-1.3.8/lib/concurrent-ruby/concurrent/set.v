module concurrent

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/set.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/thread_safe/util'
// 3: require 'set'
// 4:
// 5: module Concurrent
// 6:
// 7:   # @!macro concurrent_set
// 8:   #
// 9:   #   A thread-safe subclass of Set. This version locks against the object
// 10:   #   itself for every method call, ensuring only one thread can be reading
// 11:   #   or writing at a time. This includes iteration methods like `#each`.
// 12:   #
// 13:   #   @note `a += b` is **not** a **thread-safe** operation on
// 14:   #     `Concurrent::Set`. It reads Set `a`, then it creates new `Concurrent::Set`
// 15:   #     which is union of `a` and `b`, then it writes the union to `a`.
// 16:   #     The read and write are independent operations they do not form a single atomic
// 17:   #     operation therefore when two `+=` operations are executed concurrently updates
// 18:   #     may be lost. Use `#merge` instead.
// 19:   #
// 20:   #   @see http://ruby-doc.org/stdlib-2.4.0/libdoc/set/rdoc/Set.html Ruby standard library `Set`
// 21:
// 22:   # @!macro internal_implementation_note
// 23:   SetImplementation = case
// 24:                       when Concurrent.on_cruby?
// 25:                         # The CRuby implementation of Set is written in Ruby itself and is
// 26:                         # not thread safe for certain methods.
// 27:                         require 'monitor'
// 28:                         require 'concurrent/thread_safe/util/data_structures'
// 29:
// 30:                         class CRubySet < ::Set
// 31:                         end
// 32:
// 33:                         ThreadSafe::Util.make_synchronized_on_cruby CRubySet
// 34:                         CRubySet
// 35:
// 36:                       when Concurrent.on_jruby?
// 37:                         require 'jruby/synchronized'
// 38:
// 39:                         class JRubySet < ::Set
// 40:                           include JRuby::Synchronized
// 41:                         end
// 42:
// 43:                         JRubySet
// 44:
// 45:                       when Concurrent.on_truffleruby?
// 46:                         require 'concurrent/thread_safe/util/data_structures'
// 47:
// 48:                         class TruffleRubySet < ::Set
// 49:                         end
// 50:
// 51:                         ThreadSafe::Util.make_synchronized_on_truffleruby TruffleRubySet
// 52:                         TruffleRubySet
// 53:
// 54:                       else
// 55:                         warn 'Possibly unsupported Ruby implementation'
// 56:                         ::Set
// 57:                       end
// 58:   private_constant :SetImplementation
// 59:
// 60:   # @!macro concurrent_set
// 61:   class Set < SetImplementation
// 62:   end
// 63: end
// 64:
