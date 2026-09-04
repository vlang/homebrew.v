module bundle

import ruby
import os

// Translated from Homebrew/brew `bundle/adder.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `add(*args, type:, global:, file:, describe: false)` at line 15.
pub fn ruby_adder_l15_d1_add(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'items, type, and Brewfile are required')
	}
	items := if args[0].type_name == 'Array' {
		args[0].as_array() or { [] }.map(it.as_string())
	} else {
		[args[0].as_string()]
	}
	entry_type := args[1].as_string()
	file := args[2].as_string()
	describe := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	descriptions := if args.len > 4 {
		bundle_add_descriptions_from_value(args[4])
	} else {
		map[string]string{}
	}
	taps := if args.len > 5 { args[5].as_string_array() or { [] } } else { []string{} }
	result := add_bundle_entries(BundleAddOptions{
		items: items
		entry_type: entry_type
		file: file
		describe: describe
		descriptions: descriptions
		taps: taps
	}) or { return ruby.object_value('IOError', err.msg()) }
	return bundle_add_result_value(result)
}

pub struct BundleAddOptions {
pub:
	items        []string
	entry_type   string
	file         string
	describe     bool
	descriptions map[string]string
	taps         []string
}

pub struct BundleAddResult {
pub:
	path             string
	content          string
	ensured_taps     []string
	trusted_type     string
	trusted_items    []string
	appended_entries []string
}

fn bundle_entry_description_lines(description string) string {
	return description.split_into_lines().map('# ${it}\n').join('')
}

pub fn render_bundle_add_entry(entry_type string, item string, description string,
	describe bool) string {
	entry := '${entry_type} "${item}"'
	if describe && description.trim_space() != '' {
		return '${bundle_entry_description_lines(description)}${entry}'
	}
	return entry
}

pub fn add_bundle_entries(options BundleAddOptions) !BundleAddResult {
	if options.entry_type !in ['brew', 'cask'] && options.entry_type.trim_space() == '' {
		return error('bundle entry type is required')
	}
	if options.file.trim_space() == '' {
		return error('Brewfile path is required')
	}
	parent := os.dir(options.file)
	if !os.is_dir(parent) {
		os.mkdir_all(parent)!
	}
	mut existing := if os.exists(options.file) { os.read_file(options.file)! } else { '' }
	mut entries := []string{cap: options.items.len}
	for item in options.items {
		entries << render_bundle_add_entry(options.entry_type, item, options.descriptions[item], options.describe)
	}
	if entries.len > 0 {
		existing += '${entries.join('\n')}\n'
	}
	ruby.atomic_write_file(options.file, existing)!
	trusted_type := match options.entry_type {
		'brew' { 'formula' }
		'cask' { 'cask' }
		else { '' }
	}
	return BundleAddResult{
		path: options.file
		content: existing
		ensured_taps: options.taps.clone()
		trusted_type: trusted_type
		trusted_items: if trusted_type != '' { options.items.clone() } else { [] }
		appended_entries: entries
	}
}

fn bundle_add_descriptions_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return map[string]string{} }
	mut descriptions := map[string]string{}
	for name, description in values {
		descriptions[name] = description.as_string()
	}
	return descriptions
}

fn bundle_add_result_value(result BundleAddResult) ruby.Value {
	return ruby.structured_value('Bundle::Adder::Result', result.path, {
		'path':             result.path
		'content':          result.content
		'ensured_taps':     result.ensured_taps.join(',')
		'trusted_type':     result.trusted_type
		'trusted_items':    result.trusted_items.join(',')
		'appended_entries': result.appended_entries.join('\n')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/brewfile"
// 5: require "bundle/dumper"
// 6: require "tap"
// 7: require "trust"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     module Adder
// 12:       module_function
// 13:
// 14:       sig { params(args: String, type: Symbol, global: T::Boolean, file: String, describe: T::Boolean).void }
// 15:       def add(*args, type:, global:, file:, describe: false)
// 16:         item_type = case type
// 17:         when :brew
// 18:           :formula
// 19:         when :cask
// 20:           :cask
// 21:         end
// 22:         if item_type
// 23:           args.each do |arg|
// 24:             tap_with_name = if type == :brew
// 25:               ::Tap.with_formula_name(arg)
// 26:             else
// 27:               ::Tap.with_cask_token(arg)
// 28:             end
// 29:             next unless tap_with_name
// 30:
// 31:             tap, = tap_with_name
// 32:             tap.ensure_installed!
// 33:           end
// 34:           Homebrew::Trust.trust_fully_qualified_items!(args, type: item_type)
// 35:         end
// 36:
// 37:         brewfile_path = Brewfile.path(global:, file:)
// 38:         brewfile_path.write("") unless brewfile_path.exist?
// 39:
// 40:         brewfile = Brewfile.read(global:, file:)
// 41:         content = brewfile.input
// 42:         new_content = args.map do |arg|
// 43:           desc = case type
// 44:           when :brew
// 45:             Formulary.factory(arg).desc
// 46:           when :cask
// 47:             ::Cask::CaskLoader.load(arg).desc
// 48:           end
// 49:
// 50:           entry = "#{type} \"#{arg}\""
// 51:           if describe && desc.present?
// 52:             desc.split("\n").map { |s| "# #{s}\n" }.join + entry
// 53:           else
// 54:             entry
// 55:           end
// 56:         end
// 57:
// 58:         content << new_content.join("\n") << "\n"
// 59:         path = Dumper.brewfile_path(global:, file:)
// 60:
// 61:         Dumper.write_file path, content
// 62:       end
// 63:     end
// 64:   end
// 65: end
