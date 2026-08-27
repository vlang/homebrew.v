module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/missing_formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `disallowed_reason(name)` at line 13.
pub fn ruby_missing_formula_l13_d1_disallowed_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disallowed_reason', ...args)
}

// Ruby method `cask_reason(name, silent: false, show_info: false)` at line 25.
pub fn ruby_missing_formula_l25_d2_cask_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_reason', ...args)
}

// Ruby method `suggest_command(name, command)` at line 32.
pub fn ruby_missing_formula_l32_d3_suggest_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('suggest_command', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/info"
// 5: require "cask/cask_loader"
// 6: require "cask/caskroom"
// 7:
// 8: module OS
// 9:   module Mac
// 10:     module MissingFormula
// 11:       module ClassMethods
// 12:         sig { params(name: String).returns(T.nilable(String)) }
// 13:         def disallowed_reason(name)
// 14:           case name.downcase
// 15:           when "xcode"
// 16:             <<~EOS
// 17:               Xcode can be installed from the App Store.
// 18:             EOS
// 19:           else
// 20:             super
// 21:           end
// 22:         end
// 23:
// 24:         sig { params(name: String, silent: T::Boolean, show_info: T::Boolean).returns(T.nilable(String)) }
// 25:         def cask_reason(name, silent: false, show_info: false)
// 26:           return if silent
// 27:
// 28:           suggest_command(name, show_info ? "info" : "install")
// 29:         end
// 30:
// 31:         sig { params(name: String, command: String).returns(T.nilable(String)) }
// 32:         def suggest_command(name, command)
// 33:           suggestion = <<~EOS
// 34:             Found a cask named "#{name}" instead. Try
// 35:               brew #{command} --cask #{name}
// 36:
// 37:           EOS
// 38:           case command
// 39:           when "install"
// 40:             ::Cask::CaskLoader.load(name)
// 41:           when "uninstall"
// 42:             cask = ::Cask::Caskroom.casks.find { |installed_cask| installed_cask.to_s == name }
// 43:             Kernel.raise ::Cask::CaskUnavailableError, name if cask.nil?
// 44:           when "info"
// 45:             cask = ::Cask::CaskLoader.load(name)
// 46:             suggestion = <<~EOS
// 47:               Found a cask named "#{name}" instead.
// 48:
// 49:               #{::Cask::Info.get_info(cask)}
// 50:             EOS
// 51:           else
// 52:             return
// 53:           end
// 54:           suggestion
// 55:         rescue ::Cask::CaskUnavailableError
// 56:           nil
// 57:         end
// 58:       end
// 59:     end
// 60:   end
// 61: end
// 62:
// 63: Homebrew::MissingFormula.singleton_class.prepend(OS::Mac::MissingFormula::ClassMethods)
