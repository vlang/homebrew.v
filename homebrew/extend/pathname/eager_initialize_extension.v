module pathname

import brew_runtime

// Translated from Homebrew/brew `extend/pathname/eager_initialize_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args)` at line 23.
pub fn ruby_eager_initialize_extension_l23_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Eagerly initialises {Pathname}'s lazy memoised ivars so every instance
// 5: # shares one object shape, avoiding Ruby's shape-variation warning.
// 6: #
// 7: # Any new `@x ||= ...` ivar added to {Pathname} or its mixed-in extensions
// 8: # must also be added to `#initialize` below to keep the shape stable.
// 9: module EagerInitializeExtension
// 10:   extend T::Helpers
// 11:
// 12:   requires_ancestor { Pathname }
// 13:
// 14:   # These aliases hoist the `T.nilable(...)` type objects out of the hot path.
// 15:   # `#initialize` runs on every {Pathname} allocation, and with runtime
// 16:   # checks disabled `T.let` discards its type argument, so evaluating
// 17:   # `T.nilable(...)` inline would rebuild the same type objects each time.
// 18:   NilableString = T.type_alias { T.nilable(String) }
// 19:   NilableInteger = T.type_alias { T.nilable(Integer) }
// 20:   NilableStringArray = T.type_alias { T.nilable(T::Array[String]) }
// 21:
// 22:   sig { params(args: T.untyped).void }
// 23:   def initialize(*args)
// 24:     @magic_number = T.let(nil, NilableString)
// 25:     @file_type = T.let(nil, NilableString)
// 26:     @zipinfo = T.let(nil, NilableStringArray)
// 27:     @which_install_info = T.let(nil, NilableString)
// 28:     @disk_usage = T.let(nil, NilableInteger)
// 29:     @file_count = T.let(nil, NilableInteger)
// 30:     super
// 31:   end
// 32: end
