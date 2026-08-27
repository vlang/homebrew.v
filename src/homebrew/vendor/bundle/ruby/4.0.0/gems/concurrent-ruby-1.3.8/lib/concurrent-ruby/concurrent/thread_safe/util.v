module thread_safe

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   # @!visibility private
// 4:   module ThreadSafe
// 5:
// 6:     # @!visibility private
// 7:     module Util
// 8:
// 9:       # TODO (pitr-ch 15-Oct-2016): migrate to Utility::NativeInteger
// 10:       FIXNUM_BIT_SIZE = (0.size * 8) - 2
// 11:       MAX_INT         = (2 ** FIXNUM_BIT_SIZE) - 1
// 12:       # TODO (pitr-ch 15-Oct-2016): migrate to Utility::ProcessorCounter
// 13:       CPU_COUNT       = 16 # is there a way to determine this?
// 14:     end
// 15:   end
// 16: end
