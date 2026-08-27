module cask

import brew_runtime

// Translated from Homebrew/brew `cask/migrator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :old_cask, :new_cask` at line 13.
pub fn ruby_migrator_l13_d1_old_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_cask', ...args)
}

// Ruby attr_reader `attr_reader :old_cask, :new_cask` at line 13.
pub fn ruby_migrator_l13_d2_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask', ...args)
}

// Ruby method `initialize(old_cask, new_cask)` at line 16.
pub fn ruby_migrator_l16_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.old_tokens_needing_migration(new_cask, dry_run: false)` at line 26.
pub fn ruby_migrator_l26_d4_self_old_tokens_needing_migration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.old_tokens_needing_migration', ...args)
}

// Ruby method `self.migrate_if_needed(new_cask, dry_run: false)` at line 46.
pub fn ruby_migrator_l46_d5_self_migrate_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.migrate_if_needed', ...args)
}

// Ruby method `migrate(dry_run: false)` at line 55.
pub fn ruby_migrator_l55_d6_migrate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrate', ...args)
}

// Ruby method `self.replace_caskfile_token(path, old_token, new_token)` at line 68.
pub fn ruby_migrator_l68_d7_self_replace_caskfile_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.replace_caskfile_token', ...args)
}

// Ruby method `uninstall_old_cask(old_caskfile, dry_run:)` at line 84.
pub fn ruby_migrator_l84_d8_uninstall_old_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_old_cask', ...args)
}

// Ruby method `shared_with_new_cask?(artifact)` at line 124.
pub fn ruby_migrator_l124_d9_shared_with_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shared_with_new_cask?', ...args)
}

// Ruby method `move_old_cask(old_caskfile, dry_run:)` at line 136.
pub fn ruby_migrator_l136_d10_move_old_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_old_cask', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/inreplace"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   class Migrator
// 9:     extend ::Utils::Output::Mixin
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     sig { returns(Cask) }
// 13:     attr_reader :old_cask, :new_cask
// 14:
// 15:     sig { params(old_cask: Cask, new_cask: Cask).void }
// 16:     def initialize(old_cask, new_cask)
// 17:       raise CaskNotInstalledError, new_cask unless new_cask.installed?
// 18:
// 19:       @old_cask = old_cask
// 20:       @new_cask = new_cask
// 21:     end
// 22:
// 23:     # The old tokens of `new_cask` that are still installed in their own Caskroom directory.
// 24:     # A symlinked directory means the cask has already been migrated.
// 25:     sig { params(new_cask: Cask, dry_run: T::Boolean).returns(T::Array[String]) }
// 26:     def self.old_tokens_needing_migration(new_cask, dry_run: false)
// 27:       new_cask.old_tokens
// 28:               .map { |old_token| Caskroom.token_from_full_token(old_token) }
// 29:               .uniq
// 30:               .select do |old_token|
// 31:         next false if old_token == new_cask.token
// 32:
// 33:         old_caskroom_path = Caskroom.path/old_token
// 34:         next false if old_caskroom_path.symlink? || !old_caskroom_path.directory?
// 35:
// 36:         if Caskroom.cask_installed_caskfile(old_token).nil?
// 37:           old_caskroom_path.rmdir_if_possible unless dry_run
// 38:           next false
// 39:         end
// 40:
// 41:         true
// 42:       end
// 43:     end
// 44:
// 45:     sig { params(new_cask: Cask, dry_run: T::Boolean).void }
// 46:     def self.migrate_if_needed(new_cask, dry_run: false)
// 47:       old_tokens_needing_migration(new_cask).each do |old_token|
// 48:         new(Cask.new(old_token), new_cask).migrate(dry_run:)
// 49:       rescue => e
// 50:         onoe e
// 51:       end
// 52:     end
// 53:
// 54:     sig { params(dry_run: T::Boolean).void }
// 55:     def migrate(dry_run: false)
// 56:       old_caskfile = old_cask.installed_caskfile
// 57:       return if old_caskfile.nil?
// 58:
// 59:       new_caskroom_path = new_cask.caskroom_path
// 60:       if new_caskroom_path.directory? && !new_caskroom_path.symlink?
// 61:         uninstall_old_cask(old_caskfile, dry_run:)
// 62:       else
// 63:         move_old_cask(old_caskfile, dry_run:)
// 64:       end
// 65:     end
// 66:
// 67:     sig { params(path: Pathname, old_token: String, new_token: String).void }
// 68:     def self.replace_caskfile_token(path, old_token, new_token)
// 69:       case path.extname
// 70:       when ".rb"
// 71:         ::Utils::Inreplace.inreplace path, /\A\s*cask\s+"#{Regexp.escape(old_token)}"/, "cask #{new_token.inspect}"
// 72:       when ".json"
// 73:         json = JSON.parse(path.read)
// 74:         json["token"] = new_token
// 75:         path.atomic_write json.to_json
// 76:       end
// 77:     end
// 78:
// 79:     private
// 80:
// 81:     # The new cask is already installed under its own token, so the old cask is a
// 82:     # separate installation that needs to be uninstalled rather than moved.
// 83:     sig { params(old_caskfile: Pathname, dry_run: T::Boolean).void }
// 84:     def uninstall_old_cask(old_caskfile, dry_run:)
// 85:       old_token = old_cask.token
// 86:       new_token = new_cask.token
// 87:
// 88:       old_caskroom_path = old_cask.caskroom_path
// 89:       new_caskroom_path = new_cask.caskroom_path
// 90:
// 91:       # Load the old cask from its own installed caskfile so that its artifacts (rather
// 92:       # than the artifacts of the cask it was renamed to) are the ones uninstalled.
// 93:       installed_old_cask = CaskLoader.load_from_installed_caskfile(old_caskfile)
// 94:       uninstallable, shared = installed_old_cask.artifacts.partition do |artifact|
// 95:         !shared_with_new_cask?(artifact)
// 96:       end
// 97:
// 98:       if dry_run
// 99:         oh1 "Would migrate cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 100:
// 101:         puts "#{new_token} is already installed, so #{old_token} would be uninstalled."
// 102:         shared.each { |artifact| puts "#{artifact} would be kept as #{new_token} installs it too." }
// 103:         puts "ln -s #{new_caskroom_path.basename} #{old_caskroom_path}"
// 104:         return
// 105:       end
// 106:
// 107:       oh1 "Migrating cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 108:       puts "#{new_token} is already installed, so #{old_token} will be uninstalled."
// 109:       shared.each { |artifact| puts "Keeping #{artifact} as #{new_token} installs it too." }
// 110:
// 111:       require "cask/installer"
// 112:
// 113:       installed_old_cask.unpin if installed_old_cask.pinned?
// 114:       Installer.new(installed_old_cask, force: true, verbose: Context.current.verbose?,
// 115:                     default_uninstall_artifacts: ArtifactSet.new(uninstallable)).uninstall
// 116:
// 117:       FileUtils.rm_rf old_caskroom_path
// 118:       FileUtils.ln_s new_caskroom_path.basename, old_caskroom_path
// 119:     end
// 120:
// 121:     # Artifacts the new cask installs too must be left alone: uninstalling them would
// 122:     # remove them from the new cask, which stays installed.
// 123:     sig { params(artifact: Artifact::AbstractArtifact).returns(T::Boolean) }
// 124:     def shared_with_new_cask?(artifact)
// 125:       new_cask.artifacts.any? do |new_artifact|
// 126:         if artifact.is_a?(Artifact::Relocated)
// 127:           # Compare the paths these end up at, which is all that matters on disk.
// 128:           new_artifact.is_a?(Artifact::Relocated) && new_artifact.target == artifact.target
// 129:         else
// 130:           new_artifact.instance_of?(artifact.class) && new_artifact.to_args == artifact.to_args
// 131:         end
// 132:       end
// 133:     end
// 134:
// 135:     sig { params(old_caskfile: Pathname, dry_run: T::Boolean).void }
// 136:     def move_old_cask(old_caskfile, dry_run:)
// 137:       old_token = old_cask.token
// 138:       new_token = new_cask.token
// 139:
// 140:       old_caskroom_path = old_cask.caskroom_path
// 141:       new_caskroom_path = new_cask.caskroom_path
// 142:
// 143:       old_installed_caskfile = old_caskfile.relative_path_from(old_caskroom_path)
// 144:       new_installed_caskfile = old_installed_caskfile.dirname/old_installed_caskfile.basename.sub(
// 145:         old_token,
// 146:         new_token,
// 147:       )
// 148:
// 149:       if dry_run
// 150:         oh1 "Would migrate cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 151:
// 152:         puts "rm #{new_caskroom_path}" if new_caskroom_path.symlink?
// 153:         puts "cp -r #{old_caskroom_path} #{new_caskroom_path}"
// 154:         puts "mv #{new_caskroom_path}/#{old_installed_caskfile} #{new_caskroom_path}/#{new_installed_caskfile}"
// 155:         puts "rm -r #{old_caskroom_path}"
// 156:         puts "ln -s #{new_caskroom_path.basename} #{old_caskroom_path}"
// 157:         if (old_pin_path = old_cask.pin_path).symlink? && (pinned_version = old_cask.pinned_version)
// 158:           new_pin_path = new_cask.pin_path
// 159:           puts "rm #{old_pin_path}"
// 160:           puts "ln -s #{(new_caskroom_path/pinned_version).relative_path_from(new_pin_path.dirname)} #{new_pin_path}"
// 161:         end
// 162:       else
// 163:         oh1 "Migrating cask #{Formatter.identifier(old_token)} to #{Formatter.identifier(new_token)}"
// 164:
// 165:         # An earlier rename migration era could leave the new token as an alias symlink
// 166:         # pointing at the old directory; remove it so the copy below cannot recurse
// 167:         # into its own source.
// 168:         FileUtils.rm new_caskroom_path if new_caskroom_path.symlink?
// 169:
// 170:         begin
// 171:           FileUtils.cp_r old_caskroom_path, new_caskroom_path
// 172:           FileUtils.mv new_caskroom_path/old_installed_caskfile, new_caskroom_path/new_installed_caskfile
// 173:           self.class.replace_caskfile_token(new_caskroom_path/new_installed_caskfile, old_token, new_token)
// 174:         rescue => e
// 175:           FileUtils.rm_rf new_caskroom_path
// 176:           raise e
// 177:         end
// 178:
// 179:         FileUtils.rm_r old_caskroom_path
// 180:         FileUtils.ln_s new_caskroom_path.basename, old_caskroom_path
// 181:         if old_cask.pin_path.symlink? && (pinned_version = old_cask.pinned_version)
// 182:           begin
// 183:             new_cask.pin_path.make_relative_symlink(new_caskroom_path/pinned_version)
// 184:             old_cask.unpin
// 185:           rescue => e
// 186:             opoo "Failed to migrate cask pin from #{old_token} to #{new_token}: #{e}"
// 187:           end
// 188:         end
// 189:       end
// 190:     end
// 191:   end
// 192: end
