module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/checker.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.check(global: false, file: nil, exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 37.
pub fn ruby_checker_l37_d1_self_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check', ...args)
}

// Ruby method `self.apps_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 64.
pub fn ruby_checker_l64_d2_self_apps_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.apps_to_install', ...args)
}

// Ruby method `self.formulae_to_start(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 75.
pub fn ruby_checker_l75_d3_self_formulae_to_start(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formulae_to_start', ...args)
}

// Ruby method `self.taps_to_tap(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 91.
pub fn ruby_checker_l91_d4_self_taps_to_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.taps_to_tap', ...args)
}

// Ruby method `self.casks_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 102.
pub fn ruby_checker_l102_d5_self_casks_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.casks_to_install', ...args)
}

// Ruby method `self.formulae_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 113.
pub fn ruby_checker_l113_d6_self_formulae_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formulae_to_install', ...args)
}

// Ruby method `self.registered_extensions_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)` at line 124.
pub fn ruby_checker_l124_d7_self_registered_extensions_to_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.registered_extensions_to_install', ...args)
}

// Ruby method `self.extension_errors(step, exit_on_first_error:, no_upgrade:, verbose:)` at line 136.
pub fn ruby_checker_l136_d8_self_extension_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extension_errors', ...args)
}

// Ruby method `self.reset!` at line 158.
pub fn ruby_checker_l158_d9_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reset!', ...args)
}

// Ruby method `self.package_type_errors(type, exit_on_first_error:, no_upgrade:, verbose:)` at line 172.
pub fn ruby_checker_l172_d10_self_package_type_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.package_type_errors', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5: require "bundle/extensions"
// 6: require "bundle/package_types"
// 7: require "bundle/brew_services"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     module Checker
// 12:       class CheckResult < T::Struct
// 13:         const :work_to_be_done, T::Boolean
// 14:         const :errors, T::Array[String]
// 15:       end
// 16:
// 17:       CheckStep = T.type_alias { Symbol }
// 18:
// 19:       CORE_CHECKS = [
// 20:         :taps_to_tap,
// 21:         :casks_to_install,
// 22:         :registered_extensions_to_install,
// 23:         :apps_to_install,
// 24:         :formulae_to_install,
// 25:         :formulae_to_start,
// 26:       ].freeze
// 27:
// 28:       sig {
// 29:         params(
// 30:           global:              T::Boolean,
// 31:           file:                T.nilable(String),
// 32:           exit_on_first_error: T::Boolean,
// 33:           no_upgrade:          T::Boolean,
// 34:           verbose:             T::Boolean,
// 35:         ).returns(CheckResult)
// 36:       }
// 37:       def self.check(global: false, file: nil, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 38:         require "bundle/brewfile"
// 39:         @dsl = T.let(@dsl, T.nilable(Homebrew::Bundle::Dsl))
// 40:         @dsl ||= Brewfile.read(global:, file:)
// 41:
// 42:         errors = T.let([], T::Array[String])
// 43:         enumerator = exit_on_first_error ? :find : :map
// 44:
// 45:         work_to_be_done = CORE_CHECKS.public_send(enumerator) do |check_step|
// 46:           check_errors = public_send(check_step, exit_on_first_error:, no_upgrade:, verbose:)
// 47:           any_errors = check_errors.any?
// 48:           errors.concat(check_errors) if any_errors
// 49:           any_errors
// 50:         end
// 51:
// 52:         work_to_be_done = Array(work_to_be_done).flatten.any?
// 53:
// 54:         CheckResult.new(work_to_be_done:, errors:)
// 55:       end
// 56:
// 57:       sig {
// 58:         params(
// 59:           exit_on_first_error: T::Boolean,
// 60:           no_upgrade:          T::Boolean,
// 61:           verbose:             T::Boolean,
// 62:         ).returns(T::Array[String])
// 63:       }
// 64:       def self.apps_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 65:         extension_errors(:apps_to_install, exit_on_first_error:, no_upgrade:, verbose:)
// 66:       end
// 67:
// 68:       sig {
// 69:         params(
// 70:           exit_on_first_error: T::Boolean,
// 71:           no_upgrade:          T::Boolean,
// 72:           verbose:             T::Boolean,
// 73:         ).returns(T::Array[String])
// 74:       }
// 75:       def self.formulae_to_start(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 76:         raise ArgumentError, "dsl is unset!" unless @dsl
// 77:
// 78:         Homebrew::Bundle::Brew::Services.new.find_actionable(
// 79:           @dsl.entries,
// 80:           exit_on_first_error:, no_upgrade:, verbose:,
// 81:         )
// 82:       end
// 83:
// 84:       sig {
// 85:         params(
// 86:           exit_on_first_error: T::Boolean,
// 87:           no_upgrade:          T::Boolean,
// 88:           verbose:             T::Boolean,
// 89:         ).returns(T::Array[String])
// 90:       }
// 91:       def self.taps_to_tap(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 92:         package_type_errors(:tap, exit_on_first_error:, no_upgrade:, verbose:)
// 93:       end
// 94:
// 95:       sig {
// 96:         params(
// 97:           exit_on_first_error: T::Boolean,
// 98:           no_upgrade:          T::Boolean,
// 99:           verbose:             T::Boolean,
// 100:         ).returns(T::Array[String])
// 101:       }
// 102:       def self.casks_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 103:         package_type_errors(:cask, exit_on_first_error:, no_upgrade:, verbose:)
// 104:       end
// 105:
// 106:       sig {
// 107:         params(
// 108:           exit_on_first_error: T::Boolean,
// 109:           no_upgrade:          T::Boolean,
// 110:           verbose:             T::Boolean,
// 111:         ).returns(T::Array[String])
// 112:       }
// 113:       def self.formulae_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 114:         package_type_errors(:brew, exit_on_first_error:, no_upgrade:, verbose:)
// 115:       end
// 116:
// 117:       sig {
// 118:         params(
// 119:           exit_on_first_error: T::Boolean,
// 120:           no_upgrade:          T::Boolean,
// 121:           verbose:             T::Boolean,
// 122:         ).returns(T::Array[String])
// 123:       }
// 124:       def self.registered_extensions_to_install(exit_on_first_error: false, no_upgrade: false, verbose: false)
// 125:         extension_errors(:registered_extensions_to_install, exit_on_first_error:, no_upgrade:, verbose:)
// 126:       end
// 127:
// 128:       sig {
// 129:         params(
// 130:           step:                Symbol,
// 131:           exit_on_first_error: T::Boolean,
// 132:           no_upgrade:          T::Boolean,
// 133:           verbose:             T::Boolean,
// 134:         ).returns(T::Array[String])
// 135:       }
// 136:       def self.extension_errors(step, exit_on_first_error:, no_upgrade:, verbose:)
// 137:         raise ArgumentError, "dsl is unset!" unless @dsl
// 138:
// 139:         matching_extensions = Homebrew::Bundle.extensions.select { |extension| extension.legacy_check_step == step }
// 140:         errors = T.let([], T::Array[String])
// 141:
// 142:         matching_extensions.each do |extension|
// 143:           check_errors = extension.check(
// 144:             @dsl.entries,
// 145:             exit_on_first_error:, no_upgrade:, verbose:,
// 146:           )
// 147:           next if check_errors.empty?
// 148:
// 149:           return check_errors if exit_on_first_error
// 150:
// 151:           errors.concat(check_errors)
// 152:         end
// 153:
// 154:         errors
// 155:       end
// 156:
// 157:       sig { void }
// 158:       def self.reset!
// 159:         @dsl = T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 160:         Homebrew::Bundle.package_types.each(&:reset!)
// 161:         Homebrew::Bundle.extensions.each(&:reset!)
// 162:       end
// 163:
// 164:       sig {
// 165:         params(
// 166:           type:                Symbol,
// 167:           exit_on_first_error: T::Boolean,
// 168:           no_upgrade:          T::Boolean,
// 169:           verbose:             T::Boolean,
// 170:         ).returns(T::Array[String])
// 171:       }
// 172:       def self.package_type_errors(type, exit_on_first_error:, no_upgrade:, verbose:)
// 173:         raise ArgumentError, "dsl is unset!" unless @dsl
// 174:
// 175:         package_type = Homebrew::Bundle.package_type(type)
// 176:         return [] if package_type.nil?
// 177:
// 178:         package_type.check(@dsl.entries, exit_on_first_error:, no_upgrade:, verbose:)
// 179:       end
// 180:     end
// 181:   end
// 182: end
