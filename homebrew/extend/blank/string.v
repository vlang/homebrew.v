module blank

import ruby

// Translated from Homebrew/brew `extend/blank/string.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `blank?` at line 28.
pub fn ruby_string_l28_d1_blank(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('String#blank? requires a receiver') }
	return ruby.bool_value(value_is_blank(args[0]))
}

// Ruby method `present? = !blank? # :nodoc:` at line 41.
pub fn ruby_string_l41_d2_present(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('String#present? requires a receiver') }
	return ruby.bool_value(value_is_present(args[0]))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class String
// 5:   BLANK_RE = /\A[[:space:]]*\z/
// 6:   # This is a cache that is intentionally mutable
// 7:   # rubocop:disable Style/MutableConstant
// 8:   ENCODED_BLANKS_ = T.let(Hash.new do |h, enc|
// 9:     h[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
// 10:   end, T::Hash[Encoding, Regexp])
// 11:   # rubocop:enable Style/MutableConstant
// 12:
// 13:   # A string is blank if it's empty or contains whitespaces only:
// 14:   #
// 15:   # ```ruby
// 16:   # ''.blank?       # => true
// 17:   # '   '.blank?    # => true
// 18:   # "\t\n\r".blank? # => true
// 19:   # ' blah '.blank? # => false
// 20:   # ```
// 21:   #
// 22:   # Unicode whitespace is supported:
// 23:   #
// 24:   # ```ruby
// 25:   # "\u00a0".blank? # => true
// 26:   # ```
// 27:   sig { returns(T::Boolean) }
// 28:   def blank?
// 29:     # The regexp that matches blank strings is expensive. For the case of empty
// 30:     # strings we can speed up this method (~3.5x) with an empty? call. The
// 31:     # penalty for the rest of strings is marginal.
// 32:     empty? ||
// 33:       begin
// 34:         BLANK_RE.match?(self)
// 35:       rescue Encoding::CompatibilityError
// 36:         T.must(ENCODED_BLANKS_[encoding]).match?(self)
// 37:       end
// 38:   end
// 39:
// 40:   sig { returns(T::Boolean) }
// 41:   def present? = !blank? # :nodoc:
// 42: end
