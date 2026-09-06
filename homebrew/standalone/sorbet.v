module standalone

import ruby

// Translated from Homebrew/brew `standalone/sorbet.rb`.
pub type RecursiveValidator = fn (ruby.Value) bool
