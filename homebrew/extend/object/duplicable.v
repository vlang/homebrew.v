module object

import ruby

// Translated from Homebrew/brew `extend/object/duplicable.rb`.

// is_duplicable reports the default Object#duplicable? result. Callers carrying
// reflection objects use one of the non-duplicable type names below.
pub fn is_duplicable(value ruby.Value) bool {
	return value.type_name !in ['Method', 'UnboundMethod', 'Singleton']
}
