module options

// Translated from Homebrew/brew `options/deprecated_option.rb`.

// DeprecatedOption records a formula option rename.
pub struct DeprecatedOption {
pub:
	old     string
	current string
}

// new_deprecated_option translates DeprecatedOption.new(old, current).
pub fn new_deprecated_option(old string, current string) DeprecatedOption {
	return DeprecatedOption{
		old: old
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
