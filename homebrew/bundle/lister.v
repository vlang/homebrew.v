module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/lister.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.list(entries, formulae:, casks:, taps:, extension_types: {})` at line 14.
pub fn ruby_lister_l14_d1_self_list(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	entries := bundle_list_entries_from_value(args[0])
	formulae := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	casks := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	taps := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	extensions := if args.len > 4 {
		bundle_extension_types_from_value(args[4])
	} else {
		map[string]bool{}
	}
	return brew_runtime.string_array_value(list_bundle_entries(entries, formulae, casks, taps, extensions))
}

// Ruby method `self.show?(type, formulae:, casks:, taps:, extension_types:)` at line 25.
pub fn ruby_lister_l25_d2_self_show(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	entry_type := args[0].as_string()
	formulae := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	casks := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	taps := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	extensions := if args.len > 4 {
		bundle_extension_types_from_value(args[4])
	} else {
		map[string]bool{}
	}
	return brew_runtime.bool_value(show_bundle_entry(entry_type, formulae, casks, taps, extensions))
}

pub struct BundleListEntry {
pub:
	entry_type string
	name       string
}

pub fn show_bundle_entry(entry_type string, formulae bool, casks bool, taps bool,
	extension_types map[string]bool) bool {
	return (formulae && entry_type == 'brew') || (casks && entry_type == 'cask') || (taps && entry_type == 'tap') || extension_types[entry_type]
}

pub fn list_bundle_entries(entries []BundleListEntry, formulae bool, casks bool, taps bool,
	extension_types map[string]bool) []string {
	mut names := []string{cap: entries.len}
	for entry in entries {
		if show_bundle_entry(entry.entry_type, formulae, casks, taps, extension_types) {
			names << entry.name
		}
	}
	return names
}

fn bundle_list_entry_from_value(value brew_runtime.Value) BundleListEntry {
	return BundleListEntry{
		entry_type: value.attribute('type') or { value.attribute('entry_type') or { '' } }
		name: value.attribute('name') or { value.as_string() }
	}
}

fn bundle_list_entries_from_value(value brew_runtime.Value) []BundleListEntry {
	values := value.as_array() or { [] }
	return values.map(bundle_list_entry_from_value(it))
}

fn bundle_extension_types_from_value(value brew_runtime.Value) map[string]bool {
	values := value.as_map() or { return map[string]bool{} }
	mut extensions := map[string]bool{}
	for name, enabled in values {
		extensions[name] = enabled.as_bool() or { enabled.as_string() == 'true' }
	}
	return extensions
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5: require "bundle/extensions"
// 6:
// 7: module Homebrew
// 8:   module Bundle
// 9:     module Lister
// 10:       sig {
// 11:         params(entries: T::Array[Dsl::Entry], formulae: T::Boolean, casks: T::Boolean, taps: T::Boolean,
// 12:                extension_types: Homebrew::Bundle::ExtensionTypes).void
// 13:       }
// 14:       def self.list(entries, formulae:, casks:, taps:, extension_types: {})
// 15:         entries.each do |entry|
// 16:           puts entry.name if show?(entry.type, formulae:, casks:, taps:, extension_types:)
// 17:         end
// 18:       end
// 19:
// 20:       sig {
// 21:         params(type: Symbol, formulae: T::Boolean, casks: T::Boolean, taps: T::Boolean,
// 22:                extension_types: Homebrew::Bundle::ExtensionTypes)
// 23:           .returns(T::Boolean)
// 24:       }
// 25:       private_class_method def self.show?(type, formulae:, casks:, taps:, extension_types:)
// 26:         return true if formulae && type == :brew
// 27:         return true if casks && type == :cask
// 28:         return true if taps && type == :tap
// 29:         return true if extension_types.fetch(type, false)
// 30:
// 31:         false
// 32:       end
// 33:     end
// 34:   end
// 35: end
