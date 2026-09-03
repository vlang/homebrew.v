module bundle

import brew_runtime
import os

// Translated from Homebrew/brew `bundle/remover.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.remove(*args, type:, global:, file:)` at line 12.
pub fn ruby_remover_l12_d1_self_remove(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'items, type, and Brewfile are required')
	}
	items := if args[0].type_name == 'Array' {
		args[0].as_array() or { [] }.map(it.as_string())
	} else {
		[args[0].as_string()]
	}
	entry_type := args[1].as_string()
	file := args[2].as_string()
	packages := if args.len > 3 { bundle_packages_from_value(args[3]) } else { []BundlePackage{} }
	result := remove_bundle_entries(file, items, entry_type, packages) or {
		return brew_runtime.object_value('BundleRemoveError', err.msg())
	}
	return bundle_remove_result_value(result)
}

// Ruby method `self.possible_names(formula_name, raise_error: true)` at line 56.
pub fn ruby_remover_l56_d2_self_possible_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	packages := if args.len > 1 { bundle_packages_from_value(args[1]) } else { []BundlePackage{} }
	raise_error := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	names := possible_bundle_names(args[0].as_string(), packages, raise_error) or {
		return brew_runtime.object_value('FormulaUnavailableError', err.msg())
	}
	return brew_runtime.string_array_value(names)
}

// Ruby method `self.remove_package_description_comment(lines, package_name)` at line 64.
pub fn ruby_remover_l64_d3_self_remove_package_description_comment(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	mut lines := args[0].as_string_array() or { [] }
	packages := if args.len > 2 { bundle_packages_from_value(args[2]) } else { []BundlePackage{} }
	remove_bundle_description_comment(mut lines, args[1].as_string(), packages)
	return brew_runtime.string_array_value(lines)
}

// Ruby method `self.find_formula_or_cask(name, raise_error: false)` at line 73.
pub fn ruby_remover_l73_d4_self_find_formula_or_cask(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', '')
	}
	packages := if args.len > 1 { bundle_packages_from_value(args[1]) } else { []BundlePackage{} }
	raise_error := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	package := find_bundle_formula_or_cask(args[0].as_string(), packages, raise_error) or {
		return brew_runtime.object_value('PackageUnavailableError', err.msg())
	}
	return if package.name != '' {
		bundle_package_value(package)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
}

pub enum BundlePackageKind {
	formula
	cask
}

pub struct BundlePackage {
pub:
	kind      BundlePackageKind
	name      string
	full_name string
	aliases   []string
	oldnames  []string
	desc      string
}

pub struct BundleRemoveResult {
pub:
	path    string
	content string
	removed []string
	warning string
}

pub fn find_bundle_formula_or_cask(name string, packages []BundlePackage,
	raise_error bool) !BundlePackage {
	for package in packages {
		if name == package.name || name == package.full_name || name in package.aliases || name in package.oldnames {
			return package
		}
	}
	if raise_error {
		return error('No available formula or cask with the name "${name}".')
	}
	return BundlePackage{}
}

pub fn possible_bundle_names(formula_name string, packages []BundlePackage,
	raise_error bool) ![]string {
	package := find_bundle_formula_or_cask(formula_name, packages, raise_error)!
	if package.name == '' || package.kind != .formula {
		return []
	}
	mut names := [formula_name, package.name, package.full_name]
	names << package.aliases
	names << package.oldnames
	mut unique := []string{}
	for name in names {
		if name != '' && name !in unique {
			unique << name
		}
	}
	return unique
}

pub fn remove_bundle_description_comment(mut lines []string, package_name string,
	packages []BundlePackage) {
	if lines.len == 0 {
		return
	}
	trimmed := lines.last().trim_space()
	if !trimmed.starts_with('# ') {
		return
	}
	comment := trimmed[2..]
	package := find_bundle_formula_or_cask(package_name, packages, false) or { return }
	if package.name != '' && package.desc == comment {
		lines.delete_last()
	}
}

fn bundle_line_entry(line string) ?(string, string) {
	trimmed := line.trim_space()
	quote := trimmed.index_u8(`"`)
	if quote < 0 {
		return none
	}
	after := trimmed[quote + 1..]
	end := after.index_u8(`"`)
	if end < 0 {
		return none
	}
	entry_type := trimmed[..quote].trim_space().trim_right('(').trim_space()
	if entry_type == '' {
		return none
	}
	return entry_type, after[..end]
}

pub fn remove_bundle_entries(file string, items []string, requested_type string,
	packages []BundlePackage) !BundleRemoveResult {
	content := if os.exists(file) { os.read_file(file)! } else { '' }
	mut candidates := []string{}
	for item in items {
		if requested_type == 'brew' {
			candidates << possible_bundle_names(item, packages, true)!
		} else {
			candidates << item
		}
	}
	mut unique_candidates := []string{}
	for candidate in candidates {
		if candidate !in unique_candidates {
			unique_candidates << candidate
		}
	}
	mut new_lines := []string{}
	mut removed := []string{}
	for line in content.split_into_lines() {
		entry_type, name := bundle_line_entry(line) or {
			new_lines << line
			continue
		}
		type_matches := requested_type == 'none' || requested_type == '' || requested_type == entry_type
		if type_matches && name in unique_candidates {
			remove_bundle_description_comment(mut new_lines, name, packages)
			removed << name
			continue
		}
		new_lines << line
	}
	new_content := '${new_lines.join('\n')}\n'
	mut warning := ''
	if content.trim_right('\n') == new_content.trim_right('\n') && requested_type in ['', 'none'] {
		for item in items {
			if (possible_bundle_names(item, packages, false) or { [] }).len > 1 {
				warning = 'No matching entries found in Brewfile. Try again with `--formula` to match formula aliases and old formula names.'
				break
			}
		}
	}
	brew_runtime.atomic_write_file(file, new_content)!
	return BundleRemoveResult{
		path: file
		content: new_content
		removed: removed
		warning: warning
	}
}

fn bundle_package_from_value(value brew_runtime.Value) BundlePackage {
	kind := if (value.attribute('kind') or { 'formula' }) == 'cask' {
		BundlePackageKind.cask
	} else {
		BundlePackageKind.formula
	}
	return BundlePackage{
		kind: kind
		name: value.attribute('name') or { value.as_string() }
		full_name: value.attribute('full_name') or { value.as_string() }
		aliases: (value.attribute('aliases') or { '' }).split(',').filter(it != '')
		oldnames: (value.attribute('oldnames') or { '' }).split(',').filter(it != '')
		desc: value.attribute('desc') or { '' }
	}
}

fn bundle_packages_from_value(value brew_runtime.Value) []BundlePackage {
	return value.as_array() or { [] }.map(bundle_package_from_value(it))
}

fn bundle_package_value(package BundlePackage) brew_runtime.Value {
	return brew_runtime.structured_value(if package.kind == .formula { 'Formula' } else { 'Cask' }, package.full_name, {
		'kind':      package.kind.str()
		'name':      package.name
		'full_name': package.full_name
		'aliases':   package.aliases.join(',')
		'oldnames':  package.oldnames.join(',')
		'desc':      package.desc
	})
}

fn bundle_remove_result_value(result BundleRemoveResult) brew_runtime.Value {
	return brew_runtime.structured_value('Bundle::Remover::Result', result.path, {
		'path':    result.path
		'content': result.content
		'removed': result.removed.join(',')
		'warning': result.warning
	})
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
