module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/installer.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `full_name` at line 23.
pub fn ruby_installer_l23_d1_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_name', ...args)
}

// Ruby method `tap_name` at line 28.
pub fn ruby_installer_l28_d2_tap_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_name', ...args)
}

// Ruby method `self.reset!` at line 34.
pub fn ruby_installer_l34_d3_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reset!', ...args)
}

// Ruby method `self.install!(entries, global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false,` at line 53.
pub fn ruby_installer_l53_d4_self_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install!', ...args)
}

// Ruby method `self.fetchable_formulae_and_casks(entries, no_upgrade:)` at line 131.
pub fn ruby_installer_l131_d5_self_fetchable_formulae_and_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetchable_formulae_and_casks', ...args)
}

// Ruby method `self.tap_dependencies(entry, entries:, installed_taps:)` at line 148.
pub fn ruby_installer_l148_d6_self_tap_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_dependencies', ...args)
}

// Ruby method `self.unavailable_without_tap?(entry)` at line 165.
pub fn ruby_installer_l165_d7_self_unavailable_without_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unavailable_without_tap?', ...args)
}

// Ruby method `self.install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)` at line 195.
pub fn ruby_installer_l195_d8_self_install_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_entry!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5: require "bundle/package_types"
// 6: require "bundle/skipper"
// 7: require "bundle/trust"
// 8: require "trust"
// 9: require "utils/output"
// 10:
// 11: module Homebrew
// 12:   module Bundle
// 13:     module Installer
// 14:       extend ::Utils::Output::Mixin
// 15:
// 16:       class InstallableEntry < T::Struct
// 17:         const :name, String
// 18:         const :options, Homebrew::Bundle::EntryOptions
// 19:         const :verb, String
// 20:         const :cls, T.class_of(Homebrew::Bundle::PackageType)
// 21:
// 22:         sig { returns(String) }
// 23:         def full_name
// 24:           T.cast(options.fetch(:full_name, name), String)
// 25:         end
// 26:
// 27:         sig { returns(T.nilable(String)) }
// 28:         def tap_name
// 29:           ::Utils.tap_from_full_name(full_name)
// 30:         end
// 31:       end
// 32:
// 33:       sig { void }
// 34:       def self.reset!
// 35:         Homebrew::Bundle.reset!
// 36:         Homebrew::Bundle::Cask.reset!
// 37:         Homebrew::Bundle::Tap.reset!
// 38:       end
// 39:
// 40:       sig {
// 41:         params(
// 42:           entries:    T::Array[Dsl::Entry],
// 43:           global:     T::Boolean,
// 44:           file:       T.nilable(String),
// 45:           no_lock:    T::Boolean,
// 46:           no_upgrade: T::Boolean,
// 47:           verbose:    T::Boolean,
// 48:           force:      T::Boolean,
// 49:           jobs:       Integer,
// 50:           quiet:      T::Boolean,
// 51:         ).returns(T::Boolean)
// 52:       }
// 53:       def self.install!(entries, global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false,
// 54:                         force: false, jobs: 1, quiet: false)
// 55:         success = 0
// 56:         failure = 0
// 57:
// 58:         installable_entries = T.let([], T::Array[InstallableEntry])
// 59:         installable_brewfile_entries = T.let([], T::Array[Dsl::Entry])
// 60:         entries.each do |entry|
// 61:           next if Homebrew::Bundle::Skipper.skip? entry
// 62:
// 63:           name = entry.name
// 64:           options = entry.options
// 65:           type = entry.type
// 66:           cls = Homebrew::Bundle.installable(type)
// 67:           next if cls.nil? || !cls.install_supported?
// 68:
// 69:           installable_brewfile_entries << entry
// 70:           installable_entries << InstallableEntry.new(name:, options:, verb: cls.install_verb(name, options), cls:)
// 71:         end
// 72:
// 73:         # Apply `trusted: true` Brewfile options before anything fetches or
// 74:         # loads the entries: the fetch phase and upgrade checks load formulae
// 75:         # and casks, which triggers the tap trust check before the per-entry
// 76:         # install step could grant trust.
// 77:         Homebrew::Bundle::Trust.entries(installable_brewfile_entries).each do |type, name|
// 78:           Homebrew::Trust.trust!(type, name)
// 79:         end
// 80:
// 81:         if (fetchable_names = fetchable_formulae_and_casks(installable_entries, no_upgrade:).presence)
// 82:           fetchable_names_joined = fetchable_names.join(", ")
// 83:           puts Formatter.success("Fetching #{fetchable_names_joined}") unless quiet
// 84:           unless Bundle.brew("fetch", *fetchable_names, verbose:)
// 85:             $stderr.puts Formatter.error "`brew bundle` failed! Failed to fetch #{fetchable_names_joined}"
// 86:             return false
// 87:           end
// 88:         end
// 89:
// 90:         if jobs > 1 && installable_entries.size > 1
// 91:           require "bundle/parallel_installer"
// 92:
// 93:           parallel = ParallelInstaller.new(
// 94:             installable_entries, jobs:, no_upgrade:, verbose:, force:, quiet:
// 95:           )
// 96:           parallel_success, parallel_failure = parallel.run!
// 97:           success += parallel_success
// 98:           failure += parallel_failure
// 99:         else
// 100:           installable_entries.each do |entry|
// 101:             if install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)
// 102:               success += 1
// 103:             else
// 104:               failure += 1
// 105:             end
// 106:           end
// 107:         end
// 108:
// 109:         unless failure.zero?
// 110:           require "utils"
// 111:           dependency = Utils.pluralize("dependency", failure)
// 112:           $stderr.puts Formatter.error "`brew bundle` failed! #{failure} Brewfile #{dependency} failed to install"
// 113:           return false
// 114:         end
// 115:
// 116:         unless quiet
// 117:           require "utils"
// 118:           dependency = Utils.pluralize("dependency", success)
// 119:           puts Formatter.success "`brew bundle` complete! #{success} Brewfile #{dependency} now installed."
// 120:         end
// 121:
// 122:         true
// 123:       end
// 124:
// 125:       sig {
// 126:         params(
// 127:           entries:    T::Array[InstallableEntry],
// 128:           no_upgrade: T::Boolean,
// 129:         ).returns(T::Array[String])
// 130:       }
// 131:       def self.fetchable_formulae_and_casks(entries, no_upgrade:)
// 132:         installed_taps = Tap.installed_taps
// 133:
// 134:         entries.filter_map do |entry|
// 135:           next if tap_dependencies(entry, entries:, installed_taps:).present?
// 136:
// 137:           entry.cls.fetchable_name(entry.name, entry.options, no_upgrade:)
// 138:         end
// 139:       end
// 140:
// 141:       sig {
// 142:         params(
// 143:           entry:          InstallableEntry,
// 144:           entries:        T::Array[InstallableEntry],
// 145:           installed_taps: T::Array[String],
// 146:         ).returns(T::Array[String])
// 147:       }
// 148:       def self.tap_dependencies(entry, entries:, installed_taps:)
// 149:         return [] unless [Brew, Cask].include?(entry.cls)
// 150:
// 151:         if (tap_name = entry.tap_name)
// 152:           return installed_taps.exclude?(tap_name) ? [tap_name] : []
// 153:         end
// 154:
// 155:         tap_names = entries.filter_map do |tap_entry|
// 156:           tap_entry.name if tap_entry.cls == Tap && installed_taps.exclude?(tap_entry.name)
// 157:         end
// 158:         return [] if tap_names.empty?
// 159:         return [] unless unavailable_without_tap?(entry)
// 160:
// 161:         tap_names
// 162:       end
// 163:
// 164:       sig { params(entry: InstallableEntry).returns(T::Boolean) }
// 165:       def self.unavailable_without_tap?(entry)
// 166:         require "api"
// 167:
// 168:         case entry.cls.name
// 169:         when "Homebrew::Bundle::Brew"
// 170:           !Homebrew::API.formula_name?(entry.name) &&
// 171:             Homebrew::API.formula_aliases.exclude?(entry.name) &&
// 172:             Homebrew::API.formula_renames.exclude?(entry.name)
// 173:         when "Homebrew::Bundle::Cask"
// 174:           !Homebrew::API.cask_token?(entry.name) &&
// 175:             Homebrew::API.cask_renames.exclude?(entry.name)
// 176:         else
// 177:           false
// 178:         end
// 179:       rescue => e
// 180:         opoo "Treating `#{entry.name}` as dependent on Brewfile taps because Homebrew could not " \
// 181:              "check API metadata: #{e}"
// 182:         true
// 183:       end
// 184:       private_class_method :unavailable_without_tap?
// 185:
// 186:       sig {
// 187:         params(
// 188:           entry:      InstallableEntry,
// 189:           no_upgrade: T::Boolean,
// 190:           verbose:    T::Boolean,
// 191:           force:      T::Boolean,
// 192:           quiet:      T::Boolean,
// 193:         ).returns(T::Boolean)
// 194:       }
// 195:       def self.install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)
// 196:         name = entry.name
// 197:         options = entry.options
// 198:         verb = entry.verb
// 199:         cls = entry.cls
// 200:
// 201:         preinstall = if cls.preinstall!(name, **options, no_upgrade:, verbose:)
// 202:           puts Formatter.success("#{verb} #{name}")
// 203:           true
// 204:         else
// 205:           puts "Using #{name}" unless quiet
// 206:           false
// 207:         end
// 208:
// 209:         if cls.install!(name, **options,
// 210:                         preinstall:, no_upgrade:, verbose:, force:)
// 211:           true
// 212:         else
// 213:           $stderr.puts Formatter.error("#{verb} #{name} has failed!")
// 214:           false
// 215:         end
// 216:       end
// 217:       private_class_method :install_entry!
// 218:     end
// 219:   end
// 220: end
