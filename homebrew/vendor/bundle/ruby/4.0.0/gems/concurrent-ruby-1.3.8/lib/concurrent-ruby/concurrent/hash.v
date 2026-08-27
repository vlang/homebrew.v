module concurrent

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/thread_safe/util'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro concurrent_hash
// 7:   #
// 8:   #   A thread-safe subclass of Hash. This version locks against the object
// 9:   #   itself for every method call, ensuring only one thread can be reading
// 10:   #   or writing at a time. This includes iteration methods like `#each`,
// 11:   #   which takes the lock repeatedly when reading an item.
// 12:   #
// 13:   #   @see http://ruby-doc.org/core/Hash.html Ruby standard library `Hash`
// 14:
// 15:   # @!macro internal_implementation_note
// 16:   HashImplementation = case
// 17:                        when Concurrent.on_cruby?
// 18:                          # Hash is not fully thread-safe on CRuby, see
// 19:                          # https://bugs.ruby-lang.org/issues/19237
// 20:                          # https://github.com/ruby/ruby/commit/ffd52412ab
// 21:                          # https://github.com/ruby-concurrency/concurrent-ruby/issues/929
// 22:                          # So we will need to add synchronization here (similar to Concurrent::Map).
// 23:                          ::Hash
// 24:
// 25:                        when Concurrent.on_jruby?
// 26:                          require 'jruby/synchronized'
// 27:
// 28:                          class JRubyHash < ::Hash
// 29:                            include JRuby::Synchronized
// 30:                          end
// 31:                          JRubyHash
// 32:
// 33:                        when Concurrent.on_truffleruby?
// 34:                          require 'concurrent/thread_safe/util/data_structures'
// 35:
// 36:                          class TruffleRubyHash < ::Hash
// 37:                          end
// 38:
// 39:                          ThreadSafe::Util.make_synchronized_on_truffleruby TruffleRubyHash
// 40:                          TruffleRubyHash
// 41:
// 42:                        else
// 43:                          warn 'Possibly unsupported Ruby implementation'
// 44:                          ::Hash
// 45:                        end
// 46:   private_constant :HashImplementation
// 47:
// 48:   # @!macro concurrent_hash
// 49:   class Hash < HashImplementation
// 50:   end
// 51:
// 52: end
