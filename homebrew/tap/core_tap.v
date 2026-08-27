module tap

import brew_runtime

// Translated from Homebrew/brew `tap/core_tap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 12.
pub fn ruby_core_tap_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `ensure_installed!` at line 17.
pub fn ruby_core_tap_l17_d2_ensure_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_installed!', ...args)
}

// Ruby method `remote` at line 24.
pub fn ruby_core_tap_l24_d3_remote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remote', ...args)
}

// Ruby method `canonical_remote?(remote = self.remote)` at line 32.
pub fn ruby_core_tap_l32_d4_canonical_remote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('canonical_remote?', ...args)
}

// Ruby method `install(quiet: false, clone_target: nil,` at line 41.
pub fn ruby_core_tap_l41_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `uninstall(manual: false)` at line 57.
pub fn ruby_core_tap_l57_d6_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall', ...args)
}

// Ruby method `core_tap?` at line 64.
pub fn ruby_core_tap_l64_d7_core_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_tap?', ...args)
}

// Ruby method `linuxbrew_core?` at line 69.
pub fn ruby_core_tap_l69_d8_linuxbrew_core(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linuxbrew_core?', ...args)
}

// Ruby method `formula_dir` at line 74.
pub fn ruby_core_tap_l74_d9_formula_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_dir', ...args)
}

// Ruby method `new_formula_subdirectory(name)` at line 82.
pub fn ruby_core_tap_l82_d10_new_formula_subdirectory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_formula_subdirectory', ...args)
}

// Ruby method `new_formula_path(name)` at line 91.
pub fn ruby_core_tap_l91_d11_new_formula_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_formula_path', ...args)
}

// Ruby method `alias_dir` at line 100.
pub fn ruby_core_tap_l100_d12_alias_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alias_dir', ...args)
}

// Ruby method `formula_renames` at line 108.
pub fn ruby_core_tap_l108_d13_formula_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_renames', ...args)
}

// Ruby method `tap_migrations` at line 121.
pub fn ruby_core_tap_l121_d14_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_migrations', ...args)
}

// Ruby method `autobump` at line 134.
pub fn ruby_core_tap_l134_d15_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autobump', ...args)
}

// Ruby method `audit_exceptions` at line 142.
pub fn ruby_core_tap_l142_d16_audit_exceptions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_exceptions', ...args)
}

// Ruby method `style_exceptions` at line 150.
pub fn ruby_core_tap_l150_d17_style_exceptions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('style_exceptions', ...args)
}

// Ruby method `synced_versions_formulae` at line 158.
pub fn ruby_core_tap_l158_d18_synced_versions_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synced_versions_formulae', ...args)
}

// Ruby method `alias_file_to_name(file)` at line 166.
pub fn ruby_core_tap_l166_d19_alias_file_to_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alias_file_to_name', ...args)
}

// Ruby method `alias_table` at line 171.
pub fn ruby_core_tap_l171_d20_alias_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('alias_table', ...args)
}

// Ruby method `formula_files` at line 183.
pub fn ruby_core_tap_l183_d21_formula_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_files', ...args)
}

// Ruby method `formula_names` at line 190.
pub fn ruby_core_tap_l190_d22_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_names', ...args)
}

// Ruby method `formula_files_by_name` at line 197.
pub fn ruby_core_tap_l197_d23_formula_files_by_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_files_by_name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # A specialized {Tap} class for the core formulae.
// 5: class CoreTap < AbstractCoreTap
// 6:   class << self
// 7:     Cache = type_member { { fixed: T::Hash[T.any(String, Symbol), T.untyped] } }
// 8:     Elem = type_member(:out) { { fixed: Tap } }
// 9:   end
// 10:
// 11:   sig { void }
// 12:   def initialize
// 13:     super "Homebrew", "core"
// 14:   end
// 15:
// 16:   sig { override.void }
// 17:   def ensure_installed!
// 18:     return if ENV["HOMEBREW_TESTS"]
// 19:
// 20:     super
// 21:   end
// 22:
// 23:   sig { override.returns(T.nilable(String)) }
// 24:   def remote
// 25:     return super if Homebrew::EnvConfig.no_install_from_api?
// 26:
// 27:     Homebrew::EnvConfig.core_git_remote
// 28:   end
// 29:
// 30:   # The configured `HOMEBREW_CORE_GIT_REMOTE` is the official remote for this tap.
// 31:   sig { override.params(remote: T.nilable(String)).returns(T::Boolean) }
// 32:   def canonical_remote?(remote = self.remote)
// 33:     remote.blank? || self.class.same_remote?(remote, Homebrew::EnvConfig.core_git_remote)
// 34:   end
// 35:
// 36:   # CoreTap never allows shallow clones (on request from GitHub).
// 37:   sig {
// 38:     override.params(quiet: T::Boolean, clone_target: T.nilable(T.any(Pathname, String)),
// 39:                     custom_remote: T::Boolean, verify: T::Boolean, force: T::Boolean).void
// 40:   }
// 41:   def install(quiet: false, clone_target: nil,
// 42:               custom_remote: false, verify: false, force: false)
// 43:     remote = Homebrew::EnvConfig.core_git_remote # set by HOMEBREW_CORE_GIT_REMOTE
// 44:     requested_remote = clone_target || remote
// 45:
// 46:     # The remote will changed again on `brew update` since remotes for homebrew/core are mismatched
// 47:     raise TapCoreRemoteMismatchError.new(name, remote, requested_remote) if requested_remote != remote
// 48:
// 49:     if remote != default_remote
// 50:       $stderr.puts "HOMEBREW_CORE_GIT_REMOTE set: using #{remote} as the Homebrew/homebrew-core Git remote."
// 51:     end
// 52:
// 53:     super(quiet:, clone_target: remote, custom_remote:, force:)
// 54:   end
// 55:
// 56:   sig { override.params(manual: T::Boolean).void }
// 57:   def uninstall(manual: false)
// 58:     raise "Tap#uninstall is not available for CoreTap" if Homebrew::EnvConfig.no_install_from_api?
// 59:
// 60:     super
// 61:   end
// 62:
// 63:   sig { override.returns(T::Boolean) }
// 64:   def core_tap?
// 65:     true
// 66:   end
// 67:
// 68:   sig { returns(T::Boolean) }
// 69:   def linuxbrew_core?
// 70:     remote_repository.to_s.end_with?("/linuxbrew-core") || remote_repository == "Linuxbrew/homebrew-core"
// 71:   end
// 72:
// 73:   sig { override.returns(Pathname) }
// 74:   def formula_dir
// 75:     @formula_dir ||= T.let(begin
// 76:       ensure_installed!
// 77:       super
// 78:     end, T.nilable(Pathname))
// 79:   end
// 80:
// 81:   sig { params(name: String).returns(String) }
// 82:   def new_formula_subdirectory(name)
// 83:     if name.start_with?("lib")
// 84:       "lib"
// 85:     else
// 86:       name[0].to_s
// 87:     end
// 88:   end
// 89:
// 90:   sig { override.params(name: String).returns(Pathname) }
// 91:   def new_formula_path(name)
// 92:     formula_subdir = new_formula_subdirectory(name)
// 93:
// 94:     return super unless (formula_dir/formula_subdir).directory?
// 95:
// 96:     formula_dir/formula_subdir/"#{name.downcase}.rb"
// 97:   end
// 98:
// 99:   sig { override.returns(Pathname) }
// 100:   def alias_dir
// 101:     @alias_dir ||= T.let(begin
// 102:       ensure_installed!
// 103:       super
// 104:     end, T.nilable(Pathname))
// 105:   end
// 106:
// 107:   sig { override.returns(T::Hash[String, String]) }
// 108:   def formula_renames
// 109:     @formula_renames ||= T.let(
// 110:       if Homebrew::EnvConfig.no_install_from_api?
// 111:         ensure_installed!
// 112:         super
// 113:       else
// 114:         Homebrew::API.formula_renames
// 115:       end,
// 116:       T.nilable(T::Hash[String, String]),
// 117:     )
// 118:   end
// 119:
// 120:   sig { override.returns(T::Hash[String, T.untyped]) }
// 121:   def tap_migrations
// 122:     @tap_migrations ||= T.let(
// 123:       if Homebrew::EnvConfig.no_install_from_api?
// 124:         ensure_installed!
// 125:         super
// 126:       else
// 127:         Homebrew::API.formula_tap_migrations
// 128:       end,
// 129:       T.nilable(T::Hash[String, T.untyped]),
// 130:     )
// 131:   end
// 132:
// 133:   sig { override.returns(T::Array[String]) }
// 134:   def autobump
// 135:     @autobump ||= T.let(begin
// 136:       ensure_installed!
// 137:       super
// 138:     end, T.nilable(T::Array[String]))
// 139:   end
// 140:
// 141:   sig { override.returns(T::Hash[Symbol, T.untyped]) }
// 142:   def audit_exceptions
// 143:     @audit_exceptions ||= T.let(begin
// 144:       ensure_installed!
// 145:       super
// 146:     end, T.nilable(T::Hash[Symbol, T.untyped]))
// 147:   end
// 148:
// 149:   sig { override.returns(T::Hash[Symbol, T.untyped]) }
// 150:   def style_exceptions
// 151:     @style_exceptions ||= T.let(begin
// 152:       ensure_installed!
// 153:       super
// 154:     end, T.nilable(T::Hash[Symbol, T.untyped]))
// 155:   end
// 156:
// 157:   sig { override.returns(T::Array[T::Array[String]]) }
// 158:   def synced_versions_formulae
// 159:     @synced_versions_formulae ||= T.let(begin
// 160:       ensure_installed!
// 161:       super
// 162:     end, T.nilable(T::Array[T::Array[String]]))
// 163:   end
// 164:
// 165:   sig { override.params(file: Pathname).returns(String) }
// 166:   def alias_file_to_name(file)
// 167:     file.basename.to_s
// 168:   end
// 169:
// 170:   sig { override.returns(T::Hash[String, String]) }
// 171:   def alias_table
// 172:     @alias_table ||= T.let(
// 173:       if Homebrew::EnvConfig.no_install_from_api?
// 174:         super
// 175:       else
// 176:         Homebrew::API.formula_aliases
// 177:       end,
// 178:       T.nilable(T::Hash[String, String]),
// 179:     )
// 180:   end
// 181:
// 182:   sig { override.returns(T::Array[Pathname]) }
// 183:   def formula_files
// 184:     return super if Homebrew::EnvConfig.no_install_from_api?
// 185:
// 186:     formula_files_by_name.values
// 187:   end
// 188:
// 189:   sig { override.returns(T::Array[String]) }
// 190:   def formula_names
// 191:     return super if Homebrew::EnvConfig.no_install_from_api?
// 192:
// 193:     Homebrew::API.formula_names
// 194:   end
// 195:
// 196:   sig { override.returns(T::Hash[String, Pathname]) }
// 197:   def formula_files_by_name
// 198:     return super if Homebrew::EnvConfig.no_install_from_api?
// 199:
// 200:     @formula_files_by_name ||= T.let(
// 201:       begin
// 202:         formula_directory_path = formula_dir.to_s
// 203:         Homebrew::API.formula_names.each_with_object({}) do |name, hash|
// 204:           # If there's more than one item with the same path: use the longer one to prioritise more specific results.
// 205:           existing_path = hash[name]
// 206:           # Pathname equivalent is slow in a tight loop
// 207:           new_path = File.join(formula_directory_path, new_formula_subdirectory(name), "#{name.downcase}.rb")
// 208:           hash[name] = Pathname(new_path) if existing_path.nil? || existing_path.to_s.length < new_path.length
// 209:         end
// 210:       end,
// 211:       T.nilable(T::Hash[String, Pathname]),
// 212:     )
// 213:   end
// 214: end
