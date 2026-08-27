module tap

import brew_runtime

// Translated from Homebrew/brew `tap/core_cask_tap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 12.
pub fn ruby_core_cask_tap_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `core_cask_tap?` at line 17.
pub fn ruby_core_cask_tap_l17_d2_core_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_cask_tap?', ...args)
}

// Ruby method `new_cask_subdirectory(token)` at line 22.
pub fn ruby_core_cask_tap_l22_d3_new_cask_subdirectory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask_subdirectory', ...args)
}

// Ruby method `new_cask_path(token)` at line 31.
pub fn ruby_core_cask_tap_l31_d4_new_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask_path', ...args)
}

// Ruby method `cask_files` at line 36.
pub fn ruby_core_cask_tap_l36_d5_cask_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_files', ...args)
}

// Ruby method `cask_tokens` at line 43.
pub fn ruby_core_cask_tap_l43_d6_cask_tokens(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_tokens', ...args)
}

// Ruby method `cask_files_by_name` at line 50.
pub fn ruby_core_cask_tap_l50_d7_cask_files_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_files_by_name', ...args)
}

// Ruby method `cask_renames` at line 69.
pub fn ruby_core_cask_tap_l69_d8_cask_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_renames', ...args)
}

// Ruby method `tap_migrations` at line 81.
pub fn ruby_core_cask_tap_l81_d9_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_migrations', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A specialized {Tap} class for homebrew-cask.
// 5: class CoreCaskTap < AbstractCoreTap
// 6:   class << self
// 7:     Cache = type_member { { fixed: T::Hash[T.any(String, Symbol), T.untyped] } }
// 8:     Elem = type_member(:out) { { fixed: Tap } }
// 9:   end
// 10:
// 11:   sig { void }
// 12:   def initialize
// 13:     super "Homebrew", "cask"
// 14:   end
// 15:
// 16:   sig { override.returns(T::Boolean) }
// 17:   def core_cask_tap?
// 18:     true
// 19:   end
// 20:
// 21:   sig { params(token: String).returns(String) }
// 22:   def new_cask_subdirectory(token)
// 23:     if token.start_with?("font-")
// 24:       "font/font-#{token.delete_prefix("font-")[0]}"
// 25:     else
// 26:       token[0].to_s
// 27:     end
// 28:   end
// 29:
// 30:   sig { override.params(token: String).returns(Pathname) }
// 31:   def new_cask_path(token)
// 32:     cask_dir/new_cask_subdirectory(token)/"#{token.downcase}.rb"
// 33:   end
// 34:
// 35:   sig { override.returns(T::Array[Pathname]) }
// 36:   def cask_files
// 37:     return super if Homebrew::EnvConfig.no_install_from_api?
// 38:
// 39:     cask_files_by_name.values
// 40:   end
// 41:
// 42:   sig { override.returns(T::Array[String]) }
// 43:   def cask_tokens
// 44:     return super if Homebrew::EnvConfig.no_install_from_api?
// 45:
// 46:     Homebrew::API.cask_tokens
// 47:   end
// 48:
// 49:   sig { override.returns(T::Hash[String, Pathname]) }
// 50:   def cask_files_by_name
// 51:     return super if Homebrew::EnvConfig.no_install_from_api?
// 52:
// 53:     @cask_files_by_name ||= T.let(
// 54:       begin
// 55:         cask_directory_path = cask_dir.to_s
// 56:         Homebrew::API.cask_tokens.each_with_object({}) do |name, hash|
// 57:           # If there's more than one item with the same path: use the longer one to prioritise more specific results.
// 58:           existing_path = hash[name]
// 59:           # Pathname equivalent is slow in a tight loop
// 60:           new_path = File.join(cask_directory_path, new_cask_subdirectory(name), "#{name.downcase}.rb")
// 61:           hash[name] = Pathname(new_path) if existing_path.nil? || existing_path.to_s.length < new_path.length
// 62:         end
// 63:       end,
// 64:       T.nilable(T::Hash[String, Pathname]),
// 65:     )
// 66:   end
// 67:
// 68:   sig { override.returns(T::Hash[String, String]) }
// 69:   def cask_renames
// 70:     @cask_renames ||= T.let(
// 71:       if Homebrew::EnvConfig.no_install_from_api?
// 72:         super
// 73:       else
// 74:         Homebrew::API.cask_renames
// 75:       end,
// 76:       T.nilable(T::Hash[String, String]),
// 77:     )
// 78:   end
// 79:
// 80:   sig { override.returns(T::Hash[String, T.untyped]) }
// 81:   def tap_migrations
// 82:     @tap_migrations ||= T.let(
// 83:       if Homebrew::EnvConfig.no_install_from_api?
// 84:         super
// 85:       else
// 86:         Homebrew::API.cask_tap_migrations
// 87:       end,
// 88:       T.nilable(T::Hash[String, T.untyped]),
// 89:     )
// 90:   end
// 91: end
