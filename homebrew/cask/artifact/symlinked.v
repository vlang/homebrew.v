module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/symlinked.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.link_type_english_name` at line 11.
pub fn ruby_symlinked_l11_d1_self_link_type_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.link_type_english_name', ...args)
}

// Ruby method `self.english_description` at line 16.
pub fn ruby_symlinked_l16_d2_self_english_description(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_description', ...args)
}

// Ruby method `install_phase(force: false, adopt: false, command: SystemCommand, **options)` at line 28.
pub fn ruby_symlinked_l28_d3_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 38.
pub fn ruby_symlinked_l38_d4_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `summarize_installed` at line 43.
pub fn ruby_symlinked_l43_d5_summarize_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize_installed', ...args)
}

// Ruby method `link(force: false, adopt: false, command: SystemCommand, **_options)` at line 67.
pub fn ruby_symlinked_l67_d6_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('link', ...args)
}

// Ruby method `unlink(command: SystemCommand)` at line 98.
pub fn ruby_symlinked_l98_d7_unlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlink', ...args)
}

// Ruby method `create_filesystem_link(command)` at line 112.
pub fn ruby_symlinked_l112_d8_create_filesystem_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_filesystem_link', ...args)
}

// Ruby method `target_links_to_source?` at line 120.
pub fn ruby_symlinked_l120_d9_target_links_to_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_links_to_source?', ...args)
}

// Ruby method `conflicting_formula` at line 130.
pub fn ruby_symlinked_l130_d10_conflicting_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('conflicting_formula', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Superclass for all artifacts which are installed by symlinking them to the target location.
// 9:     class Symlinked < Relocated
// 10:       sig { returns(String) }
// 11:       def self.link_type_english_name
// 12:         "Symlink"
// 13:       end
// 14:
// 15:       sig { returns(String) }
// 16:       def self.english_description
// 17:         "#{english_name} #{link_type_english_name}s"
// 18:       end
// 19:
// 20:       sig {
// 21:         params(
// 22:           force:   T::Boolean,
// 23:           adopt:   T::Boolean,
// 24:           command: T.class_of(SystemCommand),
// 25:           options: T.anything,
// 26:         ).void
// 27:       }
// 28:       def install_phase(force: false, adopt: false, command: SystemCommand, **options)
// 29:         link(force:, adopt:, command:, **options)
// 30:       end
// 31:
// 32:       sig {
// 33:         params(
// 34:           command:  T.class_of(SystemCommand),
// 35:           _options: T.anything,
// 36:         ).void
// 37:       }
// 38:       def uninstall_phase(command: SystemCommand, **_options)
// 39:         unlink(command:)
// 40:       end
// 41:
// 42:       sig { returns(String) }
// 43:       def summarize_installed
// 44:         if target.symlink? && target.exist? && target.readlink.exist?
// 45:           "#{printable_target} -> #{target.readlink} (#{target.readlink.abv})"
// 46:         else
// 47:           string = if target.symlink?
// 48:             "#{printable_target} -> #{target.readlink}"
// 49:           else
// 50:             printable_target
// 51:           end
// 52:
// 53:           Formatter.error(string, label: "Broken Link")
// 54:         end
// 55:       end
// 56:
// 57:       private
// 58:
// 59:       sig {
// 60:         overridable.params(
// 61:           force:    T::Boolean,
// 62:           adopt:    T::Boolean,
// 63:           command:  T.class_of(SystemCommand),
// 64:           _options: T.anything,
// 65:         ).void
// 66:       }
// 67:       def link(force: false, adopt: false, command: SystemCommand, **_options)
// 68:         unless source.exist?
// 69:           raise CaskError,
// 70:                 "It seems the #{self.class.link_type_english_name.downcase} " \
// 71:                 "source '#{source}' is not there."
// 72:         end
// 73:
// 74:         if target.exist?
// 75:           message = "It seems there is already #{self.class.english_article} " \
// 76:                     "#{self.class.english_name} at '#{target}'"
// 77:
// 78:           if (force || adopt) && target.symlink? &&
// 79:              (target.realpath == source.realpath || target.realpath.to_s.start_with?("#{cask.caskroom_path}/"))
// 80:             opoo "#{message}; overwriting."
// 81:             Utils.gain_permissions_remove(target, command:)
// 82:           elsif target_links_to_source?
// 83:             ohai "#{self.class.english_name} '#{source.basename}' is already linked to '#{target}'"
// 84:             return
// 85:           elsif (formula = conflicting_formula)
// 86:             opoo "#{message} from formula #{formula}; skipping link."
// 87:             return
// 88:           else
// 89:             raise CaskError, "#{message}."
// 90:           end
// 91:         end
// 92:
// 93:         ohai "Linking #{self.class.english_name} '#{source.basename}' to '#{target}'"
// 94:         create_filesystem_link(command)
// 95:       end
// 96:
// 97:       sig { params(command: T.class_of(SystemCommand)).void }
// 98:       def unlink(command: SystemCommand)
// 99:         return unless target.symlink?
// 100:
// 101:         ohai "Unlinking #{self.class.english_name} '#{target}'"
// 102:
// 103:         if (formula = conflicting_formula)
// 104:           odebug "#{target} is from formula #{formula}; skipping unlink."
// 105:           return
// 106:         end
// 107:
// 108:         Utils.gain_permissions_remove(target, command:)
// 109:       end
// 110:
// 111:       sig { params(command: T.class_of(SystemCommand)).void }
// 112:       def create_filesystem_link(command)
// 113:         Utils.gain_permissions_mkpath(target.dirname, command:)
// 114:
// 115:         command.run! "/bin/ln", args: ["--no-dereference", "--force", "--symbolic", source, target],
// 116:                                 sudo: !target.dirname.writable?
// 117:       end
// 118:
// 119:       sig { returns(T::Boolean) }
// 120:       def target_links_to_source?
// 121:         target.symlink? && target.realpath == source.realpath
// 122:       rescue => e
// 123:         odebug "Error checking whether #{target} links to #{source}: #{e}"
// 124:         false
// 125:       end
// 126:
// 127:       # Check if the target file is a symlink that originates from a formula
// 128:       # with the same name as this cask, indicating a potential conflict
// 129:       sig { returns(T.nilable(String)) }
// 130:       def conflicting_formula
// 131:         if target.symlink? && target.exist? &&
// 132:            (match = target.realpath.to_s.match(%r{^#{HOMEBREW_CELLAR}/(?<formula>[^/]+)/}o))
// 133:           match[:formula]
// 134:         end
// 135:       rescue => e
// 136:         # If we can't determine the realpath or any other error occurs,
// 137:         # don't treat it as a conflicting formula file
// 138:         odebug "Error checking for conflicting formula file: #{e}"
// 139:         nil
// 140:       end
// 141:     end
// 142:   end
// 143: end
// 144:
// 145: require "extend/os/cask/artifact/symlinked"
