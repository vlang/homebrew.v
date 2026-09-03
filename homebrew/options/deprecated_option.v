module options

// Translated from Homebrew/brew `options/deprecated_option.rb`.
// The original source is retained below.

// DeprecatedOption records a formula option rename.
pub struct DeprecatedOption {
pub:
	old     string
	current string
}

// new_deprecated_option translates DeprecatedOption.new(old, current).
pub fn new_deprecated_option(old string, current string) DeprecatedOption {
	return DeprecatedOption{
		old:     old
		current: current
	}
}

// old_flag translates DeprecatedOption#old_flag.
pub fn (option DeprecatedOption) old_flag() string {
	return '--${option.old}'
}

// current_flag translates DeprecatedOption#current_flag.
pub fn (option DeprecatedOption) current_flag() string {
	return '--${option.current}'
}

// equal translates DeprecatedOption#== and DeprecatedOption#eql?.
pub fn (option DeprecatedOption) equal(other DeprecatedOption) bool {
	return option.old == other.old && option.current == other.current
}

// Ruby attr_reader `attr_reader :old, :current` at line 7.
pub fn ruby_deprecated_option_l7_d1_old(option DeprecatedOption) string {
	return option.old
}

// Ruby attr_reader `attr_reader :old, :current` at line 7.
pub fn ruby_deprecated_option_l7_d2_current(option DeprecatedOption) string {
	return option.current
}

// Ruby method `initialize(old, current)` at line 10.
pub fn ruby_deprecated_option_l10_d3_initialize(old string, current string) DeprecatedOption {
	return new_deprecated_option(old, current)
}

// Ruby method `old_flag` at line 16.
pub fn ruby_deprecated_option_l16_d4_old_flag(option DeprecatedOption) string {
	return option.old_flag()
}

// Ruby method `current_flag` at line 21.
pub fn ruby_deprecated_option_l21_d5_current_flag(option DeprecatedOption) string {
	return option.current_flag()
}

// Ruby method `==(other)` at line 26.
pub fn ruby_deprecated_option_l26_d6_anonymous(option DeprecatedOption, other DeprecatedOption) bool {
	return option.equal(other)
}

// Ruby alias `alias eql? ==` at line 34.
pub fn ruby_deprecated_option_l34_d7_eql(option DeprecatedOption, other DeprecatedOption) bool {
	return option.equal(other)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A deprecated formula option.
// 5: class DeprecatedOption
// 6:   sig { returns(String) }
// 7:   attr_reader :old, :current
// 8:
// 9:   sig { params(old: String, current: String).void }
// 10:   def initialize(old, current)
// 11:     @old = old
// 12:     @current = current
// 13:   end
// 14:
// 15:   sig { returns(String) }
// 16:   def old_flag
// 17:     "--#{old}"
// 18:   end
// 19:
// 20:   sig { returns(String) }
// 21:   def current_flag
// 22:     "--#{current}"
// 23:   end
// 24:
// 25:   sig { params(other: T.anything).returns(T::Boolean) }
// 26:   def ==(other)
// 27:     case other
// 28:     when DeprecatedOption
// 29:       instance_of?(other.class) && old == other.old && current == other.current
// 30:     else
// 31:       false
// 32:     end
// 33:   end
// 34:   alias eql? ==
// 35: end
