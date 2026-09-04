module standalone

import ruby

// Translated from Homebrew/brew `standalone/sorbet.rb`.
pub type RecursiveValidator = fn (ruby.Value) bool

fn recursively_valid(value ruby.Value, validator RecursiveValidator) bool {
	return validator(value)
}

fn no_checks_value(value ruby.Value, _type ruby.Value, _checked bool) ruby.Value {
	return value
}
