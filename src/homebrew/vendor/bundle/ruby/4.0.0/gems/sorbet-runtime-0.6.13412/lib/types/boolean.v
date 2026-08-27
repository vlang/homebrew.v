module types

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/boolean.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module T
// 5:   # T::Boolean is a type alias helper for the common `T.any(TrueClass, FalseClass)`.
// 6:   # Defined separately from _types.rb because it has a dependency on T::Types::Union.
// 7:   Boolean = T.type_alias { T.any(TrueClass, FalseClass) }
// 8: end
