module tap

import os

pub fn core_tap_uninstall(no_install_from_api bool) ! {
	if no_install_from_api {
		return error('Tap#uninstall is not available for CoreTap')
	}
}

pub fn core_tap_formula_names(files []string) []string {
	return files.map(os.base(it).trim_string_right('.rb'))
}

pub fn core_tap_alias_table(files []string) map[string]string {
	mut table := map[string]string{}
	for file in files {
		table[os.base(file)] = os.base(os.real_path(file)).trim_string_right('.rb')
	}
	return table
}

pub struct CoreTapState {
pub:
	user       string
	repository string
	name       string
}

pub struct CoreTapInstallPlan {
pub:
	remote             string
	clone_target       string
	custom_remote      bool
	quiet              bool
	force              bool
	configured_message string
}

pub struct CoreTapPathPlan {
pub:
	path           string
	ensure_install bool
}

pub struct CoreTapStringListPlan {
pub:
	ensure_install bool
	values         []string
}

pub struct CoreTapStringMapPlan {
pub:
	ensure_install bool
	values         map[string]string
}

pub struct CoreTapStringMatrixPlan {
pub:
	ensure_install bool
	values         [][]string
}

pub fn new_core_tap_state() CoreTapState {
	return CoreTapState{ user: 'Homebrew', repository: 'core', name: 'homebrew/core' }
}

pub fn core_tap_should_install(homebrew_tests bool, no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return !homebrew_tests && abstract_core_tap_should_install(no_install_from_api, automatically_set_no_install_from_api, installed)
}

pub fn core_tap_remote(no_install_from_api bool, inherited_remote ?string,
	core_git_remote string) ?string {
	return if no_install_from_api { inherited_remote } else { core_git_remote }
}

pub fn core_tap_canonical_remote(remote ?string, core_git_remote string,
	same_remote bool) bool {
	return remote == none || same_remote
}

pub fn core_tap_install_plan(core_git_remote string, clone_target ?string,
	default_remote string, quiet bool, custom_remote bool, force bool) !CoreTapInstallPlan {
	requested := clone_target or { core_git_remote }
	if requested != core_git_remote {
		return error('TapCoreRemoteMismatchError: homebrew/core: ${core_git_remote} != ${requested}')
	}
	return CoreTapInstallPlan{
		remote: core_git_remote
		clone_target: core_git_remote
		custom_remote: custom_remote
		quiet: quiet
		force: force
		configured_message: if core_git_remote != default_remote {
			'HOMEBREW_CORE_GIT_REMOTE set: using ${core_git_remote} as the Homebrew/homebrew-core Git remote.'} else {
			''}
	}
}

pub fn core_tap_linuxbrew_core(remote_repository ?string) bool {
	remote := remote_repository or { return false }
	return remote.ends_with('/linuxbrew-core') || remote == 'Linuxbrew/homebrew-core'
}

pub fn core_tap_formula_dir(path string, should_install bool) CoreTapPathPlan {
	return CoreTapPathPlan{ path: os.join_path(path, 'Formula'), ensure_install: should_install }
}

pub fn core_tap_new_formula_subdirectory(name string) string {
	if name.starts_with('lib') {
		return 'lib'
	}
	return if name == '' { '' } else { name[..1] }
}

pub fn core_tap_new_formula_path(formula_dir string, name string) string {
	subdirectory := core_tap_new_formula_subdirectory(name)
	if os.is_dir(os.join_path(formula_dir, subdirectory)) {
		return os.join_path(formula_dir, subdirectory, '${name.to_lower()}.rb')
	}
	return os.join_path(formula_dir, '${name.to_lower()}.rb')
}

pub fn core_tap_select_map(no_install_from_api bool, local map[string]string,
	api map[string]string) map[string]string {
	return if no_install_from_api { local } else { api }
}

pub fn core_tap_alias_file_to_name(file string) string {
	return os.base(file)
}

pub fn core_tap_formula_files_by_name(formula_dir string, formula_names []string) map[string]string {
	mut files := map[string]string{}
	for name in formula_names {
		new_path := os.join_path(formula_dir, core_tap_new_formula_subdirectory(name), '${name.to_lower()}.rb')
		existing := files[name] or { '' }
		if existing == '' || existing.len < new_path.len {
			files[name] = new_path
		}
	}
	return files
}

pub fn core_tap_formula_files(no_install_from_api bool, local_files []string,
	formula_dir string, api_names []string) []string {
	if no_install_from_api {
		return local_files
	}
	by_name := core_tap_formula_files_by_name(formula_dir, api_names)
	return api_names.map(by_name[it])
}

// Translated from Homebrew/brew `tap/core_tap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 12.
pub fn ruby_core_tap_l12_d1_initialize() CoreTapState {
	return new_core_tap_state()
}

// Ruby method `ensure_installed!` at line 17.
pub fn ruby_core_tap_l17_d2_ensure_installed(homebrew_tests bool, no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return core_tap_should_install(homebrew_tests, no_install_from_api, automatically_set_no_install_from_api, installed)
}

// Ruby method `remote` at line 24.
pub fn ruby_core_tap_l24_d3_remote(no_install_from_api bool, inherited_remote ?string,
	core_git_remote string) ?string {
	return core_tap_remote(no_install_from_api, inherited_remote, core_git_remote)
}

// Ruby method `canonical_remote?(remote = self.remote)` at line 32.
pub fn ruby_core_tap_l32_d4_canonical_remote(remote ?string, core_git_remote string,
	same_remote bool) bool {
	return core_tap_canonical_remote(remote, core_git_remote, same_remote)
}

// Ruby method `install(quiet: false, clone_target: nil,` at line 41.
pub fn ruby_core_tap_l41_d5_install(core_git_remote string, clone_target ?string,
	default_remote string, quiet bool, custom_remote bool, force bool) !CoreTapInstallPlan {
	return core_tap_install_plan(core_git_remote, clone_target, default_remote, quiet, custom_remote, force)
}

// Ruby method `uninstall(manual: false)` at line 57.
pub fn ruby_core_tap_l57_d6_uninstall(no_install_from_api bool) ! {
	return core_tap_uninstall(no_install_from_api)
}

// Ruby method `core_tap?` at line 64.
pub fn ruby_core_tap_l64_d7_core_tap() bool {
	return true
}

// Ruby method `linuxbrew_core?` at line 69.
pub fn ruby_core_tap_l69_d8_linuxbrew_core(remote_repository ?string) bool {
	return core_tap_linuxbrew_core(remote_repository)
}

// Ruby method `formula_dir` at line 74.
pub fn ruby_core_tap_l74_d9_formula_dir(path string, should_install bool) CoreTapPathPlan {
	return core_tap_formula_dir(path, should_install)
}

// Ruby method `new_formula_subdirectory(name)` at line 82.
pub fn ruby_core_tap_l82_d10_new_formula_subdirectory(name string) string {
	return core_tap_new_formula_subdirectory(name)
}

// Ruby method `new_formula_path(name)` at line 91.
pub fn ruby_core_tap_l91_d11_new_formula_path(formula_dir string, name string) string {
	return core_tap_new_formula_path(formula_dir, name)
}

// Ruby method `alias_dir` at line 100.
pub fn ruby_core_tap_l100_d12_alias_dir(path string, should_install bool) CoreTapPathPlan {
	return CoreTapPathPlan{ path: os.join_path(path, 'Aliases'), ensure_install: should_install }
}

// Ruby method `formula_renames` at line 108.
pub fn ruby_core_tap_l108_d13_formula_renames(no_install_from_api bool,
	local map[string]string, api map[string]string) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{
		ensure_install: no_install_from_api
		values: core_tap_select_map(no_install_from_api, local, api)
	}
}

// Ruby method `tap_migrations` at line 121.
pub fn ruby_core_tap_l121_d14_tap_migrations(no_install_from_api bool,
	local map[string]string, api map[string]string) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{
		ensure_install: no_install_from_api
		values: core_tap_select_map(no_install_from_api, local, api)
	}
}

// Ruby method `autobump` at line 134.
pub fn ruby_core_tap_l134_d15_autobump(values []string,
	should_install bool) CoreTapStringListPlan {
	return CoreTapStringListPlan{ values: values, ensure_install: should_install }
}

// Ruby method `audit_exceptions` at line 142.
pub fn ruby_core_tap_l142_d16_audit_exceptions(values map[string]string,
	should_install bool) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{ values: values, ensure_install: should_install }
}

// Ruby method `style_exceptions` at line 150.
pub fn ruby_core_tap_l150_d17_style_exceptions(values map[string]string,
	should_install bool) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{ values: values, ensure_install: should_install }
}

// Ruby method `synced_versions_formulae` at line 158.
pub fn ruby_core_tap_l158_d18_synced_versions_formulae(values [][]string,
	should_install bool) CoreTapStringMatrixPlan {
	return CoreTapStringMatrixPlan{ values: values, ensure_install: should_install }
}

// Ruby method `alias_file_to_name(file)` at line 166.
pub fn ruby_core_tap_l166_d19_alias_file_to_name(file string) string {
	return core_tap_alias_file_to_name(file)
}

// Ruby method `alias_table` at line 171.
pub fn ruby_core_tap_l171_d20_alias_table(no_install_from_api bool,
	local map[string]string, api map[string]string) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{
		ensure_install: no_install_from_api
		values: core_tap_select_map(no_install_from_api, local, api)
	}
}

// Ruby method `formula_files` at line 183.
pub fn ruby_core_tap_l183_d21_formula_files(no_install_from_api bool, local_files []string,
	formula_dir string, api_names []string) CoreTapStringListPlan {
	return CoreTapStringListPlan{
		ensure_install: no_install_from_api
		values: core_tap_formula_files(no_install_from_api, local_files, formula_dir, api_names)
	}
}

// Ruby method `formula_names` at line 190.
pub fn ruby_core_tap_l190_d22_formula_names(no_install_from_api bool, local_files []string,
	api_names []string) CoreTapStringListPlan {
	return CoreTapStringListPlan{
		ensure_install: no_install_from_api
		values: if no_install_from_api { core_tap_formula_names(local_files) } else { api_names }
	}
}

// Ruby method `formula_files_by_name` at line 197.
pub fn ruby_core_tap_l197_d23_formula_files_by_name(no_install_from_api bool,
	local map[string]string, formula_dir string, api_names []string) CoreTapStringMapPlan {
	return CoreTapStringMapPlan{
		ensure_install: no_install_from_api
		values: if no_install_from_api {
			local} else {
			core_tap_formula_files_by_name(formula_dir, api_names)}
	}
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
