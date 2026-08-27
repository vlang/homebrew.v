module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/moved.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_description` at line 12.
pub fn ruby_moved_l12_d1_self_english_description(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_description', ...args)
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 28.
pub fn ruby_moved_l28_d2_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,` at line 45.
pub fn ruby_moved_l45_d3_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `summarize_installed` at line 51.
pub fn ruby_moved_l51_d4_summarize_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize_installed', ...args)
}

// Ruby method `backup_copy_args(target, source)` at line 60.
pub fn ruby_moved_l60_d5_backup_copy_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backup_copy_args', ...args)
}

// Ruby method `move(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil, successor: nil,` at line 78.
pub fn ruby_moved_l78_d6_move(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move', ...args)
}

// Ruby method `post_move(command)` at line 176.
pub fn ruby_moved_l176_d7_post_move(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('post_move', ...args)
}

// Ruby method `matching_artifact?(cask)` at line 183.
pub fn ruby_moved_l183_d8_matching_artifact(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matching_artifact?', ...args)
}

// Ruby method `move_back(skip: false, force: false, adopt: false, command: SystemCommand, successor: nil)` at line 200.
pub fn ruby_moved_l200_d9_move_back(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('move_back', ...args)
}

// Ruby method `delete(target, force: false, successor: nil, command: SystemCommand)` at line 244.
pub fn ruby_moved_l244_d10_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete', ...args)
}

// Ruby method `undeletable?(target)` at line 264.
pub fn ruby_moved_l264_d11_undeletable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('undeletable?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5: require "cask/quarantine"
// 6:
// 7: module Cask
// 8:   module Artifact
// 9:     # Superclass for all artifacts that are installed by moving them to the target location.
// 10:     class Moved < Relocated
// 11:       sig { returns(String) }
// 12:       def self.english_description
// 13:         "#{english_name}s"
// 14:       end
// 15:
// 16:       sig {
// 17:         overridable.params(
// 18:           adopt:        T::Boolean,
// 19:           auto_updates: T.nilable(T::Boolean),
// 20:           force:        T::Boolean,
// 21:           verbose:      T::Boolean,
// 22:           predecessor:  T.nilable(Cask),
// 23:           successor:    T.nilable(Cask),
// 24:           reinstall:    T::Boolean,
// 25:           command:      T.class_of(SystemCommand),
// 26:         ).void
// 27:       }
// 28:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 29:                         successor: nil, reinstall: false, command: SystemCommand)
// 30:         move(adopt:, auto_updates:, force:, verbose:, predecessor:, successor:, reinstall:, command:)
// 31:       end
// 32:
// 33:       sig {
// 34:         overridable.params(
// 35:           skip:      T::Boolean,
// 36:           force:     T::Boolean,
// 37:           adopt:     T::Boolean,
// 38:           verbose:   T::Boolean,
// 39:           successor: T.nilable(Cask),
// 40:           upgrade:   T::Boolean,
// 41:           reinstall: T::Boolean,
// 42:           command:   T.class_of(SystemCommand),
// 43:         ).void
// 44:       }
// 45:       def uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,
// 46:                           reinstall: false, command: SystemCommand)
// 47:         move_back(skip:, force:, adopt:, successor:, command:)
// 48:       end
// 49:
// 50:       sig { returns(String) }
// 51:       def summarize_installed
// 52:         if target.exist?
// 53:           "#{printable_target} (#{target.abv})"
// 54:         else
// 55:           Formatter.error(printable_target, label: "Missing #{self.class.english_name}")
// 56:         end
// 57:       end
// 58:
// 59:       sig { overridable.params(target: Pathname, source: Pathname).returns(T::Array[T.any(String, Pathname)]) }
// 60:       def backup_copy_args(target, source)
// 61:         ["-pR", target, source]
// 62:       end
// 63:
// 64:       private
// 65:
// 66:       sig {
// 67:         params(
// 68:           adopt:        T::Boolean,
// 69:           auto_updates: T.nilable(T::Boolean),
// 70:           force:        T::Boolean,
// 71:           verbose:      T::Boolean,
// 72:           predecessor:  T.nilable(Cask),
// 73:           successor:    T.nilable(Cask),
// 74:           reinstall:    T::Boolean,
// 75:           command:      T.class_of(SystemCommand),
// 76:         ).returns(T.nilable(SystemCommand::Result))
// 77:       }
// 78:       def move(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil, successor: nil,
// 79:                reinstall: false, command: SystemCommand)
// 80:         unless source.exist?
// 81:           raise CaskError, "It seems the #{self.class.english_name} source '#{source}' is not there."
// 82:         end
// 83:
// 84:         if Utils.path_occupied?(target)
// 85:           if target.directory? && target.children.empty? && matching_artifact?(predecessor)
// 86:             # An upgrade removed the directory contents but left the directory itself (see below).
// 87:             unless source.directory?
// 88:               if target.parent.writable? && !force
// 89:                 target.rmdir
// 90:               else
// 91:                 Utils.gain_permissions_remove(target, command:)
// 92:               end
// 93:             end
// 94:           else
// 95:             if adopt
// 96:               ohai "Adopting existing #{self.class.english_name} at '#{target}'"
// 97:
// 98:               unless auto_updates
// 99:                 source_plist = Pathname("#{source}/Contents/Info.plist")
// 100:                 target_plist = Pathname("#{target}/Contents/Info.plist")
// 101:                 same = if source_plist.size? &&
// 102:                           (source_bundle_version = Homebrew::BundleVersion.from_info_plist(source_plist)) &&
// 103:                           target_plist.size? &&
// 104:                           (target_bundle_version = Homebrew::BundleVersion.from_info_plist(target_plist))
// 105:                   if source_bundle_version.short_version == target_bundle_version.short_version
// 106:                     if source_bundle_version.version == target_bundle_version.version
// 107:                       true
// 108:                     else
// 109:                       onoe "The bundle version of #{source} is #{source_bundle_version.version} but " \
// 110:                            "is #{target_bundle_version.version} for #{target}!"
// 111:                       false
// 112:                     end
// 113:                   else
// 114:                     onoe "The bundle short version of #{source} is #{source_bundle_version.short_version} but " \
// 115:                          "is #{target_bundle_version.short_version} for #{target}!"
// 116:                     false
// 117:                   end
// 118:                 else
// 119:                   command.run(
// 120:                     "/usr/bin/diff",
// 121:                     args:         ["--recursive", "--brief", source, target],
// 122:                     verbose:,
// 123:                     print_stdout: verbose,
// 124:                   ).success?
// 125:                 end
// 126:
// 127:                 unless same
// 128:                   raise CaskError,
// 129:                         "It seems the existing #{self.class.english_name} is different from " \
// 130:                         "the one being installed."
// 131:                 end
// 132:               end
// 133:
// 134:               # Remove the source as we don't need to move it to the target location
// 135:               FileUtils.rm_r(source)
// 136:
// 137:               return post_move(command)
// 138:             end
// 139:
// 140:             message = "It seems there is already #{self.class.english_article} " \
// 141:                       "#{self.class.english_name} at '#{target}'"
// 142:             raise CaskError, "#{message}." if !force && !adopt
// 143:
// 144:             opoo "#{message}; overwriting."
// 145:             delete(target, force:, successor:, command:)
// 146:           end
// 147:         end
// 148:
// 149:         ohai "Moving #{self.class.english_name} '#{source.basename}' to '#{target}'"
// 150:
// 151:         Utils.gain_permissions_mkpath(target.dirname, command:) unless target.dirname.exist?
// 152:
// 153:         if target.directory? && Quarantine.app_management_permissions_granted?(app: target, command:)
// 154:           if target.writable?
// 155:             source.children.each { |child| FileUtils.move(child, target/child.basename) }
// 156:           else
// 157:             command.run!("/bin/cp", args: ["-pR", *source.children, target],
// 158:                                     sudo: true)
// 159:           end
// 160:           Quarantine.copy_xattrs(source, target, command:)
// 161:           FileUtils.rm_r(source)
// 162:         elsif target.dirname.writable?
// 163:           FileUtils.move(source, target)
// 164:         else
// 165:           # default sudo user isn't necessarily able to write to Homebrew's locations
// 166:           # e.g. with runas_default set in the sudoers (5) file.
// 167:           command.run!("/bin/cp", args: ["-pR", source, target], sudo: true)
// 168:           FileUtils.rm_r(source)
// 169:         end
// 170:
// 171:         post_move(command)
// 172:       end
// 173:
// 174:       # Performs any actions necessary after the source has been moved to the target location.
// 175:       sig { params(command: T.class_of(SystemCommand)).returns(T.nilable(SystemCommand::Result)) }
// 176:       def post_move(command)
// 177:         FileUtils.ln_sf target, source
// 178:
// 179:         add_altname_metadata(target, source.basename, command:)
// 180:       end
// 181:
// 182:       sig { params(cask: T.nilable(Cask)).returns(T::Boolean) }
// 183:       def matching_artifact?(cask)
// 184:         return false unless cask
// 185:
// 186:         cask.artifacts.any? do |a|
// 187:           a.instance_of?(self.class) && instance_of?(a.class) && a.target == target
// 188:         end
// 189:       end
// 190:
// 191:       sig {
// 192:         params(
// 193:           skip:      T::Boolean,
// 194:           force:     T::Boolean,
// 195:           adopt:     T::Boolean,
// 196:           command:   T.class_of(SystemCommand),
// 197:           successor: T.nilable(Cask),
// 198:         ).void
// 199:       }
// 200:       def move_back(skip: false, force: false, adopt: false, command: SystemCommand, successor: nil)
// 201:         FileUtils.rm source if source.symlink? && source.dirname.join(source.readlink) == target
// 202:
// 203:         if Utils.path_occupied?(source)
// 204:           message = "It seems there is already #{self.class.english_article} " \
// 205:                     "#{self.class.english_name} at '#{source}'"
// 206:           raise CaskError, "#{message}." if !force && !adopt
// 207:
// 208:           opoo "#{message}; overwriting."
// 209:           delete(source, force:, successor:, command:)
// 210:         end
// 211:
// 212:         unless target.exist?
// 213:           return if skip || force
// 214:
// 215:           raise CaskError, "It seems the #{self.class.english_name} source '#{target}' is not there."
// 216:         end
// 217:
// 218:         ohai "Backing up #{self.class.english_name} '#{target.basename}' to '#{source}'"
// 219:         source.dirname.mkpath
// 220:
// 221:         # We need to preserve extended attributes between copies.
// 222:         # This may fail and need sudo if the source has files with restricted permissions.
// 223:         [!source.parent.writable?, true].uniq.each do |sudo|
// 224:           result = command.run(
// 225:             "/bin/cp",
// 226:             args:         backup_copy_args(target, source),
// 227:             must_succeed: sudo,
// 228:             sudo:,
// 229:           )
// 230:           break if result.success?
// 231:         end
// 232:
// 233:         delete(target, force:, successor:, command:)
// 234:       end
// 235:
// 236:       sig {
// 237:         params(
// 238:           target:    Pathname,
// 239:           force:     T::Boolean,
// 240:           successor: T.nilable(Cask),
// 241:           command:   T.class_of(SystemCommand),
// 242:         ).void
// 243:       }
// 244:       def delete(target, force: false, successor: nil, command: SystemCommand)
// 245:         ohai "Removing #{self.class.english_name} '#{target}'"
// 246:         raise CaskError, "Cannot remove undeletable #{self.class.english_name}." if undeletable?(target)
// 247:
// 248:         return unless Utils.path_occupied?(target)
// 249:
// 250:         if target.directory? && matching_artifact?(successor) && Quarantine.app_management_permissions_granted?(
// 251:           app: target, command:,
// 252:         )
// 253:           # If an app folder is deleted, macOS considers the app uninstalled and removes some data.
// 254:           # Remove only the contents to handle this case.
// 255:           target.children.each do |child|
// 256:             Utils.gain_permissions_remove(child, command:)
// 257:           end
// 258:         else
// 259:           Utils.gain_permissions_remove(target, command:)
// 260:         end
// 261:       end
// 262:
// 263:       sig { params(target: Pathname).returns(T::Boolean) }
// 264:       def undeletable?(target)
// 265:         !target.parent.writable?
// 266:       end
// 267:     end
// 268:   end
// 269: end
// 270:
// 271: require "extend/os/cask/artifact/moved"
