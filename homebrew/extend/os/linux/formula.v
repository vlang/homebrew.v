module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `shared_library(name, version = nil)` at line 12.
pub fn ruby_formula_l12_d1_shared_library(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shared_library', ...args)
}

// Ruby method `loader_path` at line 22.
pub fn ruby_formula_l22_d2_loader_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loader_path', ...args)
}

// Ruby method `deuniversalize_machos(*targets); end` at line 27.
pub fn ruby_formula_l27_d3_deuniversalize_machos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deuniversalize_machos', ...args)
}

// Ruby method `add_global_deps_to_spec(spec)` at line 30.
pub fn ruby_formula_l30_d4_add_global_deps_to_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_global_deps_to_spec', ...args)
}

// Ruby method `valid_platform?` at line 48.
pub fn ruby_formula_l48_d5_valid_platform(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_platform?', ...args)
}

// Ruby method `std_cabal_v2_args(installdir: bin)` at line 53.
pub fn ruby_formula_l53_d6_std_cabal_v2_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std_cabal_v2_args', ...args)
}

// Ruby method `std_swift_args` at line 60.
pub fn ruby_formula_l60_d7_std_swift_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('std_swift_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Formula
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::Formula }
// 10:
// 11:       sig { params(name: String, version: T.nilable(T.any(String, Integer))).returns(String) }
// 12:       def shared_library(name, version = nil)
// 13:         suffix = if version == "*" || (name == "*" && version.blank?)
// 14:           "{,.*}"
// 15:         elsif version.present?
// 16:           ".#{version}"
// 17:         end
// 18:         "#{name}.so#{suffix}"
// 19:       end
// 20:
// 21:       sig { returns(String) }
// 22:       def loader_path
// 23:         "$ORIGIN"
// 24:       end
// 25:
// 26:       sig { params(targets: T.nilable(T.any(::Pathname, String))).void }
// 27:       def deuniversalize_machos(*targets); end
// 28:
// 29:       sig { params(spec: SoftwareSpec).void }
// 30:       def add_global_deps_to_spec(spec)
// 31:         @global_deps ||= T.let(nil, T.nilable(T::Array[Dependency]))
// 32:         @global_deps ||= begin
// 33:           dependency_collector = spec.dependency_collector
// 34:           related_formula_names = Set[name]
// 35:           if ::DevelopmentTools.needs_build_formulae? || ::DevelopmentTools.needs_libc_formula?
// 36:             related_formula_names.merge(aliases)
// 37:             related_formula_names.merge(versioned_formulae_names)
// 38:           end
// 39:           [
// 40:             dependency_collector.gcc_dep_if_needed(related_formula_names),
// 41:             dependency_collector.glibc_dep_if_needed(related_formula_names),
// 42:           ].compact.freeze
// 43:         end
// 44:         @global_deps.each { |dep| spec.dependency_collector.add(dep) }
// 45:       end
// 46:
// 47:       sig { returns(T::Boolean) }
// 48:       def valid_platform?
// 49:         supports_linux?
// 50:       end
// 51:
// 52:       sig { params(installdir: T.any(String, ::Pathname, FalseClass)).returns(T::Array[String]) }
// 53:       def std_cabal_v2_args(installdir: bin)
// 54:         args = super
// 55:         args << "--ghc-option=-pie" if ::Hardware::CPU.arm?
// 56:         args
// 57:       end
// 58:
// 59:       sig { returns(T::Array[String]) }
// 60:       def std_swift_args
// 61:         # Use ld shim to help find Homebrew-installed libraries
// 62:         ["--static-swift-stdlib", "-Xswiftc", "-use-ld=ld"].concat(super)
// 63:       end
// 64:     end
// 65:   end
// 66: end
// 67:
// 68: Formula.prepend(OS::Linux::Formula)
