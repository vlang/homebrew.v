module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/remover.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.remove(*args, type:, global:, file:)` at line 12.
pub fn ruby_remover_l12_d1_self_remove(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remove', ...args)
}

// Ruby method `self.possible_names(formula_name, raise_error: true)` at line 56.
pub fn ruby_remover_l56_d2_self_possible_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.possible_names', ...args)
}

// Ruby method `self.remove_package_description_comment(lines, package_name)` at line 64.
pub fn ruby_remover_l64_d3_self_remove_package_description_comment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remove_package_description_comment', ...args)
}

// Ruby method `self.find_formula_or_cask(name, raise_error: false)` at line 73.
pub fn ruby_remover_l73_d4_self_find_formula_or_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_formula_or_cask', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     module Remover
// 9:       extend ::Utils::Output::Mixin
// 10:
// 11:       sig { params(args: String, type: Symbol, global: T::Boolean, file: T.nilable(String)).void }
// 12:       def self.remove(*args, type:, global:, file:)
// 13:         require "bundle/brewfile"
// 14:         require "bundle/dumper"
// 15:
// 16:         brewfile = Brewfile.read(global:, file:)
// 17:         content = brewfile.input
// 18:         entry_type = type.to_s if type != :none
// 19:         escaped_args = args.flat_map do |arg|
// 20:           names = if type == :brew
// 21:             possible_names(arg)
// 22:           else
// 23:             [arg]
// 24:           end
// 25:
// 26:           names.uniq.map { |a| Regexp.escape(a) }
// 27:         end
// 28:
// 29:         entry_regex = /#{entry_type}(\s+|\(\s*)"(#{escaped_args.join("|")})"/
// 30:         new_lines = T.let([], T::Array[String])
// 31:
// 32:         content.split("\n").compact.each do |line|
// 33:           if line.match?(entry_regex)
// 34:             name = line[entry_regex, 2]
// 35:             remove_package_description_comment(new_lines, T.must(name))
// 36:           else
// 37:             new_lines << line
// 38:           end
// 39:         end
// 40:
// 41:         new_content = "#{new_lines.join("\n")}\n"
// 42:
// 43:         if content.chomp == new_content.chomp &&
// 44:            type == :none &&
// 45:            args.any? { |arg| possible_names(arg, raise_error: false).count > 1 }
// 46:           opoo "No matching entries found in Brewfile. Try again with `--formula` to match formula " \
// 47:                "aliases and old formula names."
// 48:           return
// 49:         end
// 50:
// 51:         path = Dumper.brewfile_path(global:, file:)
// 52:         Dumper.write_file path, new_content
// 53:       end
// 54:
// 55:       sig { params(formula_name: String, raise_error: T::Boolean).returns(T::Array[String]) }
// 56:       def self.possible_names(formula_name, raise_error: true)
// 57:         formula = find_formula_or_cask(formula_name, raise_error:)
// 58:         return [] if formula.nil? || !formula.is_a?(Formula)
// 59:
// 60:         [formula_name, formula.name, formula.full_name, *formula.aliases, *formula.oldnames].compact.uniq
// 61:       end
// 62:
// 63:       sig { params(lines: T::Array[String], package_name: String).void }
// 64:       def self.remove_package_description_comment(lines, package_name)
// 65:         comment = lines.last&.match(/^\s*#\s+(?<desc>.+)$/)&.[](:desc)
// 66:         return unless comment
// 67:         return if find_formula_or_cask(package_name)&.desc != comment
// 68:
// 69:         lines.pop
// 70:       end
// 71:
// 72:       sig { params(name: String, raise_error: T::Boolean).returns(T.nilable(T.any(Formula, ::Cask::Cask))) }
// 73:       def self.find_formula_or_cask(name, raise_error: false)
// 74:         formula = begin
// 75:           Formulary.factory(name)
// 76:         rescue FormulaUnavailableError
// 77:           raise if raise_error
// 78:         end
// 79:
// 80:         return formula if formula.present?
// 81:
// 82:         begin
// 83:           ::Cask::CaskLoader.load(name)
// 84:         rescue ::Cask::CaskUnavailableError
// 85:           raise if raise_error
// 86:         end
// 87:       end
// 88:     end
// 89:   end
// 90: end
