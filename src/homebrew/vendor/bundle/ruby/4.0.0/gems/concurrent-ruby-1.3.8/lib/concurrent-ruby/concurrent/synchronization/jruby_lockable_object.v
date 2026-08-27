module synchronization

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/synchronization/jruby_lockable_object.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: module Concurrent
// 4:   module Synchronization
// 5:
// 6:     if Concurrent.on_jruby?
// 7:
// 8:       # @!visibility private
// 9:       # @!macro internal_implementation_note
// 10:       class JRubyLockableObject < AbstractLockableObject
// 11:
// 12:       end
// 13:     end
// 14:   end
// 15: end
