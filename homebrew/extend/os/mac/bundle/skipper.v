module bundle

import brew_runtime
import homebrew.bundle as base_bundle

pub fn mac_bundle_linux_only_entry(entry base_bundle.BundleSkipEntry) bool {
	return entry.type_name == 'flatpak'
}

pub fn mac_bundle_skip(skipper &base_bundle.BundleSkipper,
	entry base_bundle.BundleSkipEntry, silent bool) base_bundle.BundleSkipResult {
	if entry.type_name == 'winget' {
		return base_bundle.BundleSkipResult{
			skipped: true
			warning: if silent {
				''} else {
				'Warning: Skipping winget ${entry.name} (requires WSL)'}
		}
	}
	if mac_bundle_linux_only_entry(entry) {
		return base_bundle.BundleSkipResult{
			skipped: true
			warning: if silent {
				''} else {
				'Warning: Skipping flatpak ${entry.name} (unsupported on macOS)'}
		}
	}
	return skipper.skip(entry, silent)
}

fn mac_bundle_entry_from_value(value brew_runtime.Value) !base_bundle.BundleSkipEntry {
	values := value.as_map()!
	return base_bundle.BundleSkipEntry{
		type_name: (values['type'] or { return error('entry type is required') }).as_string()
		name: (values['name'] or { return error('entry name is required') }).as_string()
		full_name: (values['full_name'] or { brew_runtime.string_value('') }).as_string()
		id: (values['id'] or { brew_runtime.string_value('') }).as_string()
	}
}

// Translated from Homebrew/brew `extend/os/mac/bundle/skipper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `linux_only_entry?(entry)` at line 10.
pub fn ruby_skipper_l10_d1_linux_only_entry(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('linux_only_entry? requires an entry') }
	return brew_runtime.bool_value(mac_bundle_linux_only_entry(mac_bundle_entry_from_value(args[0]) or { panic(err) }))
}

// Ruby method `skip?(entry, silent: false)` at line 15.
pub fn ruby_skipper_l15_d2_skip(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('skip? requires an entry') }
	silent := if args.len > 1 { args[1].as_bool() or { panic(err) } } else { false }
	skipper := base_bundle.new_bundle_skipper(map[string]string{})
	result := mac_bundle_skip(&skipper, mac_bundle_entry_from_value(args[0]) or { panic(err) }, silent)
	return brew_runtime.map_value({
		'skipped': brew_runtime.bool_value(result.skipped)
		'warning': brew_runtime.string_value(result.warning)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Bundle
// 7:       module Skipper
// 8:         module ClassMethods
// 9:           sig { params(entry: Homebrew::Bundle::Dsl::Entry).returns(T::Boolean) }
// 10:           def linux_only_entry?(entry)
// 11:             entry.type == :flatpak
// 12:           end
// 13:
// 14:           sig { params(entry: Homebrew::Bundle::Dsl::Entry, silent: T::Boolean).returns(T::Boolean) }
// 15:           def skip?(entry, silent: false)
// 16:             if entry.type == :winget
// 17:               Kernel.puts Formatter.warning "Skipping #{entry.type} #{entry.name} (requires WSL)" unless silent
// 18:               true
// 19:             elsif linux_only_entry?(entry)
// 20:               unless silent
// 21:                 Kernel.puts Formatter.warning "Skipping #{entry.type} #{entry.name} (unsupported on macOS)"
// 22:               end
// 23:               true
// 24:             else
// 25:               super
// 26:             end
// 27:           end
// 28:         end
// 29:       end
// 30:     end
// 31:   end
// 32: end
// 33:
// 34: Homebrew::Bundle::Skipper.singleton_class.prepend(OS::Mac::Bundle::Skipper::ClassMethods)
