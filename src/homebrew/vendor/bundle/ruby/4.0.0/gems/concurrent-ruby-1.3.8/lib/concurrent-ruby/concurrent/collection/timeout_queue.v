module collection

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/timeout_queue.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Collection
// 3:     # @!visibility private
// 4:     # @!macro internal_implementation_note
// 5:     TimeoutQueueImplementation = if RUBY_VERSION >= '3.2'
// 6:                                    ::Queue
// 7:                                  else
// 8:                                    require 'concurrent/collection/ruby_timeout_queue'
// 9:                                    RubyTimeoutQueue
// 10:                                  end
// 11:     private_constant :TimeoutQueueImplementation
// 12:
// 13:     # @!visibility private
// 14:     # @!macro timeout_queue
// 15:     class TimeoutQueue < TimeoutQueueImplementation
// 16:     end
// 17:   end
// 18: end
