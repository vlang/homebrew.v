module homebrew

import brew_runtime

// Translated from Homebrew/brew `uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.uninstall_kegs(kegs_by_rack, casks: [], force: false, ignore_dependencies: false, named_args: [])` at line 22.
pub fn ruby_uninstall_l22_d1_self_uninstall_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.uninstall_kegs', ...args)
}

// Ruby method `self.handle_unsatisfied_dependents(kegs_by_rack, casks: [], ignore_dependencies: false, named_args: [])` at line 132.
pub fn ruby_uninstall_l132_d2_self_handle_unsatisfied_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.handle_unsatisfied_dependents', ...args)
}

// Ruby method `self.check_for_dependents!(kegs, casks: [], named_args: [])` at line 143.
pub fn ruby_uninstall_l143_d3_self_check_for_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_for_dependents!', ...args)
}

// Ruby method `self.rm_pin(rack)` at line 151.
pub fn ruby_uninstall_l151_d4_self_rm_pin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.rm_pin', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependents_message"
// 5: require "installed_dependents"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Helper module for uninstalling kegs.
// 10:   module Uninstall
// 11:     extend ::Utils::Output::Mixin
// 12:
// 13:     sig {
// 14:       params(
// 15:         kegs_by_rack:        T::Hash[Pathname, T::Array[Keg]],
// 16:         casks:               T::Array[Cask::Cask],
// 17:         force:               T::Boolean,
// 18:         ignore_dependencies: T::Boolean,
// 19:         named_args:          T::Array[String],
// 20:       ).void
// 21:     }
// 22:     def self.uninstall_kegs(kegs_by_rack, casks: [], force: false, ignore_dependencies: false, named_args: [])
// 23:       handle_unsatisfied_dependents(kegs_by_rack,
// 24:                                     casks:,
// 25:                                     ignore_dependencies:,
// 26:                                     named_args:)
// 27:       return if Homebrew.failed?
// 28:
// 29:       kegs_by_rack.each do |rack, kegs|
// 30:         if force
// 31:           name = rack.basename
// 32:
// 33:           if rack.directory?
// 34:             puts "Uninstalling #{name}... (#{rack.abv})"
// 35:             kegs.each do |keg|
// 36:               keg.unlink
// 37:               keg.uninstall
// 38:             end
// 39:           end
// 40:
// 41:           rm_pin rack
// 42:         else
// 43:           kegs.each do |keg|
// 44:             begin
// 45:               f = Formulary.from_rack(rack)
// 46:               if f.pinned?
// 47:                 onoe "#{f.full_name} is pinned. You must unpin it to uninstall."
// 48:                 break # exit keg loop and move on to next rack
// 49:               end
// 50:             rescue
// 51:               nil
// 52:             end
// 53:
// 54:             keg.lock do
// 55:               puts "Uninstalling #{keg}... (#{keg.abv})"
// 56:               keg.unlink
// 57:               keg.uninstall
// 58:               rack = keg.rack
// 59:               rm_pin rack
// 60:
// 61:               if rack.directory?
// 62:                 versions = rack.subdirs.map(&:basename)
// 63:                 puts <<~EOS
// 64:                   #{keg.name} #{versions.to_sentence} #{versions.one? ? "is" : "are"} still installed.
// 65:                   To remove all versions, run:
// 66:                     brew uninstall --force #{keg.name}
// 67:                 EOS
// 68:               end
// 69:
// 70:               next unless f
// 71:
// 72:               paths = f.pkgetc.find.map(&:to_s) if f.pkgetc.exist?
// 73:               if paths.present?
// 74:                 puts
// 75:                 opoo <<~EOS
// 76:                   The following #{f.name} configuration files have not been removed!
// 77:                   If desired, remove them manually with `rm -rf`:
// 78:                     #{paths.sort.uniq.join("\n  ")}
// 79:                 EOS
// 80:               end
// 81:
// 82:               unversioned_name = f.name.gsub(/@.+$/, "")
// 83:               maybe_paths = Dir.glob("#{f.etc}/#{unversioned_name}*")
// 84:               excluded_names = if Homebrew::EnvConfig.no_install_from_api?
// 85:                 Formula.names
// 86:               else
// 87:                 Homebrew::API.formula_names
// 88:               end.to_set
// 89:               maybe_paths = maybe_paths.reject do |path|
// 90:                 # Remove extension only if a file
// 91:                 # (e.g. directory with name "openssl@1.1" will be trimmed to "openssl@1")
// 92:                 basename = if File.directory?(path)
// 93:                   File.basename(path)
// 94:                 else
// 95:                   File.basename(path, ".*")
// 96:                 end
// 97:                 excluded_names.include?(basename)
// 98:               end
// 99:               maybe_paths -= paths if paths.present?
// 100:               if maybe_paths.present?
// 101:                 puts
// 102:                 opoo <<~EOS
// 103:                   The following may be #{f.name} configuration files and have not been removed!
// 104:                   If desired, remove them manually with `rm -rf`:
// 105:                     #{maybe_paths.sort.uniq.join("\n  ")}
// 106:                 EOS
// 107:               end
// 108:             end
// 109:           end
// 110:         end
// 111:       end
// 112:     rescue MultipleVersionsInstalledError => e
// 113:       ofail e
// 114:     ensure
// 115:       # If we delete Cellar/newname, then Cellar/oldname symlink
// 116:       # can become broken and we have to remove it.
// 117:       if HOMEBREW_CELLAR.directory?
// 118:         HOMEBREW_CELLAR.children.each do |rack|
// 119:           rack.unlink if rack.symlink? && !rack.resolved_path_exists?
// 120:         end
// 121:       end
// 122:     end
// 123:
// 124:     sig {
// 125:       params(
// 126:         kegs_by_rack:        T::Hash[Pathname, T::Array[Keg]],
// 127:         casks:               T::Array[Cask::Cask],
// 128:         ignore_dependencies: T::Boolean,
// 129:         named_args:          T::Array[String],
// 130:       ).void
// 131:     }
// 132:     def self.handle_unsatisfied_dependents(kegs_by_rack, casks: [], ignore_dependencies: false, named_args: [])
// 133:       return if ignore_dependencies
// 134:
// 135:       all_kegs = kegs_by_rack.values.flatten(1)
// 136:       check_for_dependents!(all_kegs, casks:, named_args:)
// 137:     rescue MethodDeprecatedError
// 138:       # Silently ignore deprecations when uninstalling.
// 139:       nil
// 140:     end
// 141:
// 142:     sig { params(kegs: T::Array[Keg], casks: T::Array[Cask::Cask], named_args: T::Array[String]).returns(T::Boolean) }
// 143:     def self.check_for_dependents!(kegs, casks: [], named_args: [])
// 144:       return false unless (result = InstalledDependents.find_some_installed_dependents(kegs, casks:))
// 145:
// 146:       DependentsMessage.new(*result, named_args:).output
// 147:       true
// 148:     end
// 149:
// 150:     sig { params(rack: Pathname).void }
// 151:     def self.rm_pin(rack)
// 152:       Formulary.from_rack(rack).unpin
// 153:     rescue
// 154:       nil
// 155:     end
// 156:   end
// 157: end
