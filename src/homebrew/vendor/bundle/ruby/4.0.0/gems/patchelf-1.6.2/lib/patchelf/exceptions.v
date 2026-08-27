module patchelf

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/exceptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # encoding: ascii-8bit
// 2: # frozen_string_literal: true
// 3:
// 4: require 'elftools/exceptions'
// 5:
// 6: module PatchELF
// 7:   # Raised on an error during ELF modification.
// 8:   class PatchError < ELFTools::ELFError; end
// 9:
// 10:   # Raised when Dynamic Tag is missing
// 11:   class MissingTagError < PatchError; end
// 12:
// 13:   # Raised on missing Program Header(segment)
// 14:   class MissingSegmentError < PatchError; end
// 15: end
