module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/caller_utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.find_caller` at line 6.
pub fn ruby_caller_utils_l6_d1_self_find_caller(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_caller', ...args)
}

// Ruby method `self.find_caller` at line 21.
pub fn ruby_caller_utils_l21_d2_self_find_caller(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_caller', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Private::CallerUtils
// 5:   if Thread.respond_to?(:each_caller_location) # RUBY_VERSION >= "3.2"
// 6:     def self.find_caller
// 7:       skipped_first = false
// 8:       Thread.each_caller_location do |loc|
// 9:         unless skipped_first
// 10:           skipped_first = true
// 11:           next
// 12:         end
// 13:
// 14:         next if loc.path&.start_with?("<internal:")
// 15:
// 16:         return loc if yield(loc)
// 17:       end
// 18:       nil
// 19:     end
// 20:   else
// 21:     def self.find_caller
// 22:       caller_locations(2).find do |loc|
// 23:         !loc.path&.start_with?("<internal:") && yield(loc)
// 24:       end
// 25:     end
// 26:   end
// 27: end
