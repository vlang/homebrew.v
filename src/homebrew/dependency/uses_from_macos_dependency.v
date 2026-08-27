module dependency

import brew_runtime

// Translated from Homebrew/brew `dependency/uses_from_macos_dependency.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :bounds` at line 7.
pub fn ruby_uses_from_macos_dependency_l7_d1_bounds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bounds', ...args)
}

// Ruby method `initialize(name, tags = [], bounds:)` at line 10.
pub fn ruby_uses_from_macos_dependency_l10_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `==(other)` at line 17.
pub fn ruby_uses_from_macos_dependency_l17_d3_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 24.
pub fn ruby_uses_from_macos_dependency_l24_d4_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `hash` at line 27.
pub fn ruby_uses_from_macos_dependency_l27_d5_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash', ...args)
}

// Ruby method `installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,` at line 39.
pub fn ruby_uses_from_macos_dependency_l39_d6_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed?', ...args)
}

// Ruby method `use_macos_install?(bottle_os_version: nil)` at line 45.
pub fn ruby_uses_from_macos_dependency_l45_d7_use_macos_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_macos_install?', ...args)
}

// Ruby method `uses_from_macos?` at line 81.
pub fn ruby_uses_from_macos_dependency_l81_d8_uses_from_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses_from_macos?', ...args)
}

// Ruby method `dup_with_formula_name(formula)` at line 86.
pub fn ruby_uses_from_macos_dependency_l86_d9_dup_with_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dup_with_formula_name', ...args)
}

// Ruby method `inspect` at line 91.
pub fn ruby_uses_from_macos_dependency_l91_d10_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A dependency that's marked as "installed" on macOS
// 5: class UsesFromMacOSDependency < Dependency
// 6:   sig { returns(T::Hash[Symbol, Symbol]) }
// 7:   attr_reader :bounds
// 8:
// 9:   sig { params(name: String, tags: T::Array[T.any(String, Symbol, T::Array[T.untyped])], bounds: T::Hash[Symbol, Symbol]).void }
// 10:   def initialize(name, tags = [], bounds:)
// 11:     super(name, tags)
// 12:
// 13:     @bounds = bounds
// 14:   end
// 15:
// 16:   sig { override.params(other: BasicObject).returns(T::Boolean) }
// 17:   def ==(other)
// 18:     case other
// 19:     when UsesFromMacOSDependency
// 20:       name == other.name && tags == other.tags && bounds == other.bounds
// 21:     else false
// 22:     end
// 23:   end
// 24:   alias eql? ==
// 25:
// 26:   sig { override.returns(Integer) }
// 27:   def hash
// 28:     [name, tags, bounds].hash
// 29:   end
// 30:
// 31:   sig {
// 32:     params(
// 33:       minimum_version:               T.nilable(Version),
// 34:       minimum_revision:              T.nilable(Integer),
// 35:       minimum_compatibility_version: T.nilable(Integer),
// 36:       bottle_os_version:             T.nilable(String),
// 37:     ).returns(T::Boolean)
// 38:   }
// 39:   def installed?(minimum_version: nil, minimum_revision: nil, minimum_compatibility_version: nil,
// 40:                  bottle_os_version: nil)
// 41:     use_macos_install?(bottle_os_version:) || super
// 42:   end
// 43:
// 44:   sig { params(bottle_os_version: T.nilable(String)).returns(T::Boolean) }
// 45:   def use_macos_install?(bottle_os_version: nil)
// 46:     # Check whether macOS is new enough for dependency to not be required.
// 47:     if Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 48:       # If there's no since bound, the dependency is always available from macOS
// 49:       since_os_bounds = bounds[:since]
// 50:       return true if since_os_bounds.blank?
// 51:
// 52:       # When installing a bottle built on an older macOS version, use that version
// 53:       # to determine if the dependency should come from macOS or Homebrew
// 54:       effective_os = if bottle_os_version.present? &&
// 55:                         bottle_os_version.start_with?("macOS ")
// 56:         # bottle_os_version is a string like "14" for Sonoma, "15" for Sequoia
// 57:         # Convert it to a MacOS version symbol for comparison
// 58:         MacOSVersion.new(bottle_os_version.delete_prefix("macOS "))
// 59:       elsif Homebrew::SimulateSystem.current_os == :macos
// 60:         # Assume the oldest macOS version when simulating a generic macOS version
// 61:         # Version::NULL is always treated as less than any other version.
// 62:         Version::NULL
// 63:       else
// 64:         MacOSVersion.from_symbol(Homebrew::SimulateSystem.current_os)
// 65:       end
// 66:
// 67:       since_os = begin
// 68:         MacOSVersion.from_symbol(since_os_bounds)
// 69:       rescue MacOSVersion::Error
// 70:         # If we can't parse the bound, it means it's an unsupported macOS version
// 71:         # so let's default to the oldest possible macOS version
// 72:         Version::NULL
// 73:       end
// 74:       return true if effective_os >= since_os
// 75:     end
// 76:
// 77:     false
// 78:   end
// 79:
// 80:   sig { override.returns(T::Boolean) }
// 81:   def uses_from_macos?
// 82:     true
// 83:   end
// 84:
// 85:   sig { override.params(formula: Formula).returns(T.self_type) }
// 86:   def dup_with_formula_name(formula)
// 87:     self.class.new(formula.full_name.to_s, tags, bounds:)
// 88:   end
// 89:
// 90:   sig { returns(String) }
// 91:   def inspect
// 92:     "#<#{self.class.name}: #{name.inspect} #{tags.inspect} #{bounds.inspect}>"
// 93:   end
// 94: end
