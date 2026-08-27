module elftools

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/elftools-1.3.1/lib/elftools/exceptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module ELFTools
// 4:   # Being raised when parsing error.
// 5:   class ELFError < StandardError; end
// 6:
// 7:   # Raised on invalid ELF magic.
// 8:   class ELFMagicError < ELFError; end
// 9:
// 10:   # Raised on invalid ELF class (EI_CLASS).
// 11:   class ELFClassError < ELFError; end
// 12:
// 13:   # Raised on invalid ELF data encoding (EI_DATA).
// 14:   class ELFDataError < ELFError; end
// 15: end
