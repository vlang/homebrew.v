module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/tap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :tap` at line 13.
pub fn ruby_tap_l13_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `check_label = "Tap"` at line 16.
pub fn ruby_tap_l16_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_label', ...args)
}

// Ruby method `reset!` at line 19.
pub fn ruby_tap_l19_d3_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `preinstall!(name, no_upgrade: false, verbose: false, **_options)` at line 32.
pub fn ruby_tap_l32_d4_preinstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preinstall!', ...args)
}

// Ruby method `install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, clone_target: nil,` at line 54.
pub fn ruby_tap_l54_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install!', ...args)
}

// Ruby method `install_verb(_name = "", _options = {})` at line 84.
pub fn ruby_tap_l84_d6_install_verb(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_verb', ...args)
}

// Ruby method `dump(dumped_formulae: [], dumped_casks: [])` at line 89.
pub fn ruby_tap_l89_d7_dump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dump', ...args)
}

// Ruby method `dump_output(describe: false, no_restart: false)` at line 136.
pub fn ruby_tap_l136_d8_dump_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dump_output', ...args)
}

// Ruby method `tap_names` at line 144.
pub fn ruby_tap_l144_d9_tap_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_names', ...args)
}

// Ruby method `installed_taps` at line 149.
pub fn ruby_tap_l149_d10_installed_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_taps', ...args)
}

// Ruby method `taps` at line 154.
pub fn ruby_tap_l154_d11_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('taps', ...args)
}

// Ruby method `find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 167.
pub fn ruby_tap_l167_d12_find_actionable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_actionable', ...args)
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 180.
pub fn ruby_tap_l180_d13_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_and_up_to_date?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "bundle/package_type"
// 6: require "trust"
// 7:
// 8: module Homebrew
// 9:   module Bundle
// 10:     class Tap < Homebrew::Bundle::PackageType
// 11:       class << self
// 12:         sig { override.returns(Symbol) }
// 13:         def type = :tap
// 14:
// 15:         sig { override.returns(String) }
// 16:         def check_label = "Tap"
// 17:
// 18:         sig { override.void }
// 19:         def reset!
// 20:           @taps = T.let(nil, T.nilable(T::Array[::Tap]))
// 21:           @installed_taps = T.let(nil, T.nilable(T::Array[String]))
// 22:         end
// 23:
// 24:         sig {
// 25:           override.params(
// 26:             name:       String,
// 27:             no_upgrade: T::Boolean,
// 28:             verbose:    T::Boolean,
// 29:             _options:   Homebrew::Bundle::EntryOption,
// 30:           ).returns(T::Boolean)
// 31:         }
// 32:         def preinstall!(name, no_upgrade: false, verbose: false, **_options)
// 33:           _ = no_upgrade
// 34:
// 35:           if installed_taps.include? name
// 36:             puts "Skipping install of #{name} tap. It is already installed." if verbose
// 37:             return false
// 38:           end
// 39:
// 40:           true
// 41:         end
// 42:
// 43:         sig {
// 44:           override.params(
// 45:             name:         String,
// 46:             preinstall:   T::Boolean,
// 47:             no_upgrade:   T::Boolean,
// 48:             verbose:      T::Boolean,
// 49:             force:        T::Boolean,
// 50:             clone_target: T.nilable(String),
// 51:             _options:     Homebrew::Bundle::EntryOption,
// 52:           ).returns(T::Boolean)
// 53:         }
// 54:         def install!(name, preinstall: true, no_upgrade: false, verbose: false, force: false, clone_target: nil,
// 55:                      **_options)
// 56:           _ = no_upgrade
// 57:
// 58:           return true unless preinstall
// 59:
// 60:           puts "Installing #{name} tap. It is not currently installed." if verbose
// 61:           args = []
// 62:           official_tap = name.downcase.start_with? "homebrew/"
// 63:           args << "--force" if force || (official_tap && Homebrew::EnvConfig.developer?)
// 64:
// 65:           success = if clone_target
// 66:             Bundle.brew("tap", name, clone_target, *args, verbose:)
// 67:           else
// 68:             Bundle.brew("tap", name, *args, verbose:)
// 69:           end
// 70:
// 71:           unless success
// 72:             require "bundle/skipper"
// 73:             Homebrew::Bundle::Skipper.tap_failed!(name)
// 74:             return false
// 75:           end
// 76:
// 77:           require "tap"
// 78:           ::Tap.fetch(name).clear_cache
// 79:           installed_taps << name
// 80:           true
// 81:         end
// 82:
// 83:         sig { override.params(_name: String, _options: Homebrew::Bundle::EntryOptions).returns(String) }
// 84:         def install_verb(_name = "", _options = {})
// 85:           "Tapping"
// 86:         end
// 87:
// 88:         sig { override.params(dumped_formulae: T::Array[String], dumped_casks: T::Array[String]).returns(String) }
// 89:         def dump(dumped_formulae: [], dumped_casks: [])
// 90:           taps.map do |tap|
// 91:             remote = if (tap_remote = tap.remote) && tap_remote != tap.default_remote
// 92:               if (api_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", false).presence)
// 93:                 # Replace the API token in the remote URL with interpolation.
// 94:                 # Keep the interpolation unevaluated until the Brewfile is evaluated.
// 95:                 tap_remote = tap_remote.gsub api_token, "\#{ENV.fetch(\"HOMEBREW_GITHUB_API_TOKEN\")}"
// 96:               end
// 97:               ", \"#{tap_remote}\""
// 98:             end
// 99:             tapline = "tap \"#{tap.name}\"#{remote}"
// 100:             trusted = if Homebrew::Trust.explicitly_trusted_tap?(tap)
// 101:               true
// 102:             else
// 103:               tap_trust = T.let({}, T::Hash[Symbol, T::Array[String]])
// 104:               {
// 105:                 formula: [:formulae, dumped_formulae],
// 106:                 cask:    [:casks, dumped_casks],
// 107:                 command: [:commands, []],
// 108:               }.each do |type, values|
// 109:                 key, dumped_items = values
// 110:                 trusted_items = Homebrew::Trust.trusted_entries(type).filter_map do |entry|
// 111:                   reference, _, item = entry.rpartition("/")
// 112:                   next if reference.blank? || item.blank?
// 113:                   next if reference != tap.name && !tap.matches_reference?(reference)
// 114:                   next if dumped_items.include?("#{tap.name}/#{item}")
// 115:
// 116:                   item
// 117:                 end.sort.uniq
// 118:                 tap_trust[key] = trusted_items if trusted_items.present?
// 119:               end
// 120:               tap_trust.presence
// 121:             end
// 122:
// 123:             if trusted == true
// 124:               tapline += ", trusted: true"
// 125:             elsif trusted.present?
// 126:               trusted_options = trusted.map do |key, values|
// 127:                 "#{key}: [#{values.map(&:inspect).join(", ")}]"
// 128:               end.join(", ")
// 129:               tapline += ", trusted: { #{trusted_options} }"
// 130:             end
// 131:             tapline
// 132:           end.sort.uniq.join("\n")
// 133:         end
// 134:
// 135:         sig { override.params(describe: T::Boolean, no_restart: T::Boolean).returns(String) }
// 136:         def dump_output(describe: false, no_restart: false)
// 137:           _ = describe
// 138:           _ = no_restart
// 139:
// 140:           dump
// 141:         end
// 142:
// 143:         sig { returns(T::Array[String]) }
// 144:         def tap_names
// 145:           taps.map(&:name)
// 146:         end
// 147:
// 148:         sig { returns(T::Array[String]) }
// 149:         def installed_taps
// 150:           @installed_taps ||= T.let(tap_names, T.nilable(T::Array[String]))
// 151:         end
// 152:
// 153:         sig { returns(T::Array[::Tap]) }
// 154:         def taps
// 155:           @taps ||= begin
// 156:             require "tap"
// 157:             ::Tap.select(&:installed?).to_a
// 158:           end
// 159:         end
// 160:         private :taps
// 161:       end
// 162:
// 163:       sig {
// 164:         override.params(entries: T::Array[Dsl::Entry], exit_on_first_error: T::Boolean,
// 165:                         no_upgrade: T::Boolean, verbose: T::Boolean).returns(T::Array[String])
// 166:       }
// 167:       def find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 168:         _ = exit_on_first_error
// 169:         _ = no_upgrade
// 170:         _ = verbose
// 171:
// 172:         requested_taps = format_checkable(entries)
// 173:         return [] if requested_taps.empty?
// 174:
// 175:         current_taps = self.class.tap_names
// 176:         (requested_taps - current_taps).map { |entry| "Tap #{entry} needs to be tapped." }
// 177:       end
// 178:
// 179:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 180:       def installed_and_up_to_date?(package, no_upgrade: false)
// 181:         _ = no_upgrade
// 182:
// 183:         self.class.installed_taps.include?(T.cast(package, String))
// 184:       end
// 185:     end
// 186:   end
// 187: end
