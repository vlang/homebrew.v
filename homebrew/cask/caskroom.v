module cask

import brew_runtime

// Translated from Homebrew/brew `cask/caskroom.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.path` at line 17.
pub fn ruby_caskroom_l17_d1_self_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path', ...args)
}

// Ruby method `self.paths` at line 23.
pub fn ruby_caskroom_l23_d2_self_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.paths', ...args)
}

// Ruby method `self.tokens` at line 32.
pub fn ruby_caskroom_l32_d3_self_tokens(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tokens', ...args)
}

// Ruby method `self.any_casks_installed?` at line 37.
pub fn ruby_caskroom_l37_d4_self_any_casks_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.any_casks_installed?', ...args)
}

// Ruby method `self.cask_installed?(token)` at line 42.
pub fn ruby_caskroom_l42_d5_self_cask_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_installed?', ...args)
}

// Ruby method `self.cask_installed_caskfile(token, old_tokens: [])` at line 47.
pub fn ruby_caskroom_l47_d6_self_cask_installed_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_installed_caskfile', ...args)
}

// Ruby method `self.cask_installed_version(token, old_tokens: [])` at line 65.
pub fn ruby_caskroom_l65_d7_self_cask_installed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_installed_version', ...args)
}

// Ruby method `self.migrate_caskfile_to_json(caskfile)` at line 72.
pub fn ruby_caskroom_l72_d8_self_migrate_caskfile_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.migrate_caskfile_to_json', ...args)
}

// Ruby method `self.artifacts_equivalent?(first, second)` at line 154.
pub fn ruby_caskroom_l154_d9_self_artifacts_equivalent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.artifacts_equivalent?', ...args)
}

// Ruby method `self.corrupt_cask_dirs` at line 161.
pub fn ruby_caskroom_l161_d10_self_corrupt_cask_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.corrupt_cask_dirs', ...args)
}

// Ruby method `self.cask_with_metadata?(cask_path)` at line 166.
pub fn ruby_caskroom_l166_d11_self_cask_with_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_with_metadata?', ...args)
}

// Ruby method `self.token_from_full_token(token)` at line 172.
pub fn ruby_caskroom_l172_d12_self_token_from_full_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.token_from_full_token', ...args)
}

// Ruby method `self.ensure_caskroom_exists` at line 178.
pub fn ruby_caskroom_l178_d13_self_ensure_caskroom_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ensure_caskroom_exists', ...args)
}

// Ruby method `self.chgrp_path(path, sudo)` at line 196.
pub fn ruby_caskroom_l196_d14_self_chgrp_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.chgrp_path', ...args)
}

// Ruby method `self.caskroom_group_correct?(path)` at line 201.
pub fn ruby_caskroom_l201_d15_self_caskroom_group_correct(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.caskroom_group_correct?', ...args)
}

// Ruby attr_writer `attr_writer :expected_caskroom_group` at line 212.
pub fn ruby_caskroom_l212_d16_expected_caskroom_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_caskroom_group=', ...args)
}

// Ruby method `self.expected_caskroom_group` at line 216.
pub fn ruby_caskroom_l216_d17_self_expected_caskroom_group(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.expected_caskroom_group', ...args)
}

// Ruby method `self.casks(config: nil)` at line 227.
pub fn ruby_caskroom_l227_d18_self_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.casks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   # Helper functions for interacting with the `Caskroom` directory.
// 9:   #
// 10:   # @api internal
// 11:   module Caskroom
// 12:     extend ::Utils::Output::Mixin
// 13:
// 14:     CASKFILE_EXTENSIONS = %w[json internal.json rb].freeze
// 15:
// 16:     sig { returns(Pathname) }
// 17:     def self.path
// 18:       @path ||= T.let(HOMEBREW_PREFIX/"Caskroom", T.nilable(Pathname))
// 19:     end
// 20:
// 21:     # Return all paths for installed casks.
// 22:     sig { returns(T::Array[Pathname]) }
// 23:     def self.paths
// 24:       return [] unless path.exist?
// 25:
// 26:       path.children.select { |p| p.directory? && !p.symlink? }
// 27:     end
// 28:     private_class_method :paths
// 29:
// 30:     # Return all tokens for installed casks.
// 31:     sig { returns(T::Array[String]) }
// 32:     def self.tokens
// 33:       paths.map { |path| path.basename.to_s }
// 34:     end
// 35:
// 36:     sig { returns(T::Boolean) }
// 37:     def self.any_casks_installed?
// 38:       paths.any?
// 39:     end
// 40:
// 41:     sig { params(token: String).returns(T::Boolean) }
// 42:     def self.cask_installed?(token)
// 43:       !cask_installed_version(token).nil?
// 44:     end
// 45:
// 46:     sig { params(token: String, old_tokens: T::Array[String]).returns(T.nilable(Pathname)) }
// 47:     def self.cask_installed_caskfile(token, old_tokens: [])
// 48:       # Check if the cask is installed with an old name.
// 49:       [token, *old_tokens].map { |cask_token| token_from_full_token(cask_token) }.uniq.each do |cask_token|
// 50:         caskroom_path = path/cask_token
// 51:         next if !caskroom_path.directory? || caskroom_path.symlink?
// 52:
// 53:         timestamped_path = Pathname.glob((caskroom_path/".metadata/*/*").to_s).max_by { |p| p.basename.to_s }
// 54:         next unless timestamped_path
// 55:
// 56:         caskfile = CASKFILE_EXTENSIONS.map { |ext| timestamped_path/"Casks/#{cask_token}.#{ext}" }
// 57:                                       .find(&:exist?)
// 58:         return caskfile if caskfile
// 59:       end
// 60:
// 61:       nil
// 62:     end
// 63:
// 64:     sig { params(token: String, old_tokens: T::Array[String]).returns(T.nilable(String)) }
// 65:     def self.cask_installed_version(token, old_tokens: [])
// 66:       return unless (caskfile = cask_installed_caskfile(token, old_tokens:))
// 67:
// 68:       caskfile.dirname.dirname.dirname.basename.to_s
// 69:     end
// 70:
// 71:     sig { params(caskfile: Pathname).void }
// 72:     def self.migrate_caskfile_to_json(caskfile)
// 73:       # Parse regular installed JSON so current files can be skipped and useful URL data can survive repairs.
// 74:       token = CaskLoader.token_from_path(caskfile)
// 75:       installed_json_caskfile = CaskLoader.installed_json_caskfile?(caskfile)
// 76:       source_json = CaskLoader.load_installed_json(caskfile)
// 77:
// 78:       source_artifacts = nil
// 79:       source_url_specs = nil
// 80:       current_json = false
// 81:       if source_json
// 82:         raw_source_artifacts = source_json["artifacts"]
// 83:         raw_source_version = source_json["version"]
// 84:         raw_source_url_specs = source_json["url_specs"]
// 85:         source_artifacts = raw_source_artifacts if raw_source_artifacts.is_a?(Array)
// 86:         source_url_specs = raw_source_url_specs if raw_source_url_specs.is_a?(Hash)
// 87:
// 88:         # Installed JSON only supplements metadata available from the path or receipt: artifacts and version preserve
// 89:         # otherwise-lost installed values, while url_specs preserves an artifact's staged source path.
// 90:         current_json = (source_json.keys - %w[artifacts url_specs version]).empty? &&
// 91:                        (raw_source_artifacts.nil? || !source_artifacts.nil?) &&
// 92:                        (raw_source_version.nil? || raw_source_version.is_a?(String)) &&
// 93:                        (raw_source_url_specs.nil? || !source_url_specs.nil?)
// 94:       end
// 95:
// 96:       # Recover missing receipt and legacy caskfile data before deciding what must be stored in the JSON.
// 97:       tab = CaskLoader.load_installed_tab(token)
// 98:
// 99:       cask = begin
// 100:         if installed_json_caskfile
// 101:           CaskLoader.load_from_installed_caskfile(caskfile)
// 102:         else
// 103:           CaskLoader.load(caskfile, warn: false)
// 104:         end
// 105:       rescue CaskInvalidError, CaskUnavailableError, MethodDeprecatedError, JSON::ParserError, NoMethodError,
// 106:              TypeError
// 107:         nil
// 108:       end
// 109:       return if current_json && cask && (!source_artifacts.nil? || tab.uninstall_artifacts.present?)
// 110:       return if cask&.uninstall_flight_blocks? || tab.uninstall_flight_blocks
// 111:
// 112:       cask ||= CaskLoader.recover_from_installed_caskfile(caskfile, tab:)
// 113:       return unless cask
// 114:
// 115:       # Preserve the original version and artifacts whenever the receipt cannot reproduce them.
// 116:       version = cask.version.to_s
// 117:       json_uninstall_artifacts = JSON.parse(JSON.generate(cask.artifacts_list(uninstall_only: true)))
// 118:       # Keep missing artifacts distinguishable from an intentional empty artifact list.
// 119:       return if source_artifacts.nil? && tab.uninstall_artifacts.blank? && json_uninstall_artifacts.empty?
// 120:
// 121:       installed_json = cask.to_installed_json_hash
// 122:       installed_json["url_specs"] ||= source_url_specs if source_url_specs
// 123:       receipt_artifacts = tab.uninstall_artifacts.presence
// 124:       if receipt_artifacts.nil? || !artifacts_equivalent?(receipt_artifacts, json_uninstall_artifacts)
// 125:         installed_json["artifacts"] = json_uninstall_artifacts
// 126:       end
// 127:       installed_json["version"] = version if caskfile.dirname.dirname.dirname.basename.to_s != version
// 128:
// 129:       # Replace the old metadata only after the new JSON reloads with the selected version and artifacts.
// 130:       json_caskfile = caskfile.dirname/"#{token}.json"
// 131:       original_contents = caskfile.read if caskfile == json_caskfile
// 132:       json_caskfile.atomic_write(JSON.pretty_generate(installed_json))
// 133:       begin
// 134:         # Only durable on-disk data may satisfy this check: the API fallback would mask a
// 135:         # migrated caskfile that lost its artifacts for as long as the API definition matches.
// 136:         migrated_cask = CaskLoader.load_from_installed_caskfile(json_caskfile, api_fallback: false)
// 137:         migrated_artifacts = JSON.parse(JSON.generate(migrated_cask.artifacts_list(uninstall_only: true)))
// 138:         if migrated_cask.version.to_s != version ||
// 139:            !artifacts_equivalent?(migrated_artifacts, json_uninstall_artifacts)
// 140:           raise "migrated Cask metadata differs from the original after preserving version and artifacts"
// 141:         end
// 142:       rescue
// 143:         if original_contents
// 144:           json_caskfile.atomic_write(original_contents)
// 145:         elsif json_caskfile.exist?
// 146:           json_caskfile.unlink
// 147:         end
// 148:         raise
// 149:       end
// 150:       caskfile.unlink if caskfile != json_caskfile
// 151:     end
// 152:
// 153:     sig { params(first: T::Array[T.anything], second: T::Array[T.anything]).returns(T::Boolean) }
// 154:     def self.artifacts_equivalent?(first, second)
// 155:       first.tally == second.tally
// 156:     end
// 157:     private_class_method :artifacts_equivalent?
// 158:
// 159:     # Return tokens for Caskroom directories missing expected installed metadata.
// 160:     sig { returns(T::Array[String]) }
// 161:     def self.corrupt_cask_dirs
// 162:       paths.filter_map { |p| p.basename.to_s unless cask_with_metadata?(p) }
// 163:     end
// 164:
// 165:     sig { params(cask_path: Pathname).returns(T::Boolean) }
// 166:     def self.cask_with_metadata?(cask_path)
// 167:       cask_path.glob(".metadata/*/*/Casks/*.{rb,json}").any?
// 168:     end
// 169:     private_class_method :cask_with_metadata?
// 170:
// 171:     sig { params(token: String).returns(String) }
// 172:     def self.token_from_full_token(token)
// 173:       _, _, cask_token = token.split("/", 3)
// 174:       cask_token || token
// 175:     end
// 176:
// 177:     sig { void }
// 178:     def self.ensure_caskroom_exists
// 179:       return if path.exist?
// 180:
// 181:       sudo = !path.parent.writable?
// 182:
// 183:       if sudo && !ENV.key?("SUDO_ASKPASS") && $stdout.tty?
// 184:         ohai "Creating Caskroom directory: #{path}",
// 185:              "We'll set permissions properly so we won't need sudo in the future."
// 186:       end
// 187:
// 188:       SystemCommand.run("mkdir", args: ["-p", path], sudo:)
// 189:       SystemCommand.run("chmod", args: ["g+rwx", path], sudo:)
// 190:       SystemCommand.run("chown", args: [User.current.to_s, path], sudo:)
// 191:
// 192:       chgrp_path(path, sudo) unless caskroom_group_correct?(path)
// 193:     end
// 194:
// 195:     sig { params(path: Pathname, sudo: T::Boolean).void }
// 196:     def self.chgrp_path(path, sudo)
// 197:       SystemCommand.run("chgrp", args: [expected_caskroom_group, path], sudo:)
// 198:     end
// 199:
// 200:     sig { params(path: Pathname).returns(T::Boolean) }
// 201:     def self.caskroom_group_correct?(path)
// 202:       group = Etc.getgrnam(expected_caskroom_group)
// 203:       return false if group.nil?
// 204:
// 205:       path.stat.gid == group.gid
// 206:     end
// 207:
// 208:     @expected_caskroom_group = T.let(nil, T.nilable(String))
// 209:
// 210:     class << self
// 211:       sig { params(expected_caskroom_group: T.nilable(String)).void }
// 212:       attr_writer :expected_caskroom_group
// 213:     end
// 214:
// 215:     sig { returns(String) }
// 216:     def self.expected_caskroom_group
// 217:       "admin"
// 218:     end
// 219:
// 220:     # Get all installed casks.
// 221:     #
// 222:     # A Caskroom directory for a cask that has been renamed but not yet migrated loads
// 223:     # as the cask it was renamed to, so deduplicate to avoid listing it twice.
// 224:     #
// 225:     # @api internal
// 226:     sig { params(config: T.nilable(Config)).returns(T::Array[Cask]) }
// 227:     def self.casks(config: nil)
// 228:       tokens.sort.filter_map do |token|
// 229:         # This is nested so that the rescue can catch errors from both branches
// 230:         begin
// 231:           CaskLoader.load_prefer_installed(token, config:, warn: false)
// 232:         rescue TapCaskAmbiguityError => e
// 233:           e.loaders.fetch(0).load(config:)
// 234:         end
// 235:       rescue Homebrew::UntrustedTapError
// 236:         # If the tap is untrusted the only place we can load the cask from is the installed cask file, if it exists.
// 237:         begin
// 238:           CaskLoader::FromInstalledPathLoader.try_new(token, warn: false)&.load(config:)
// 239:         rescue
// 240:           nil
// 241:         end
// 242:       rescue
// 243:         # Don't blow up because of a single unavailable cask.
// 244:         nil
// 245:       end.select(&:installed?).uniq(&:full_name)
// 246:     end
// 247:   end
// 248: end
// 249:
// 250: require "extend/os/cask/caskroom"
