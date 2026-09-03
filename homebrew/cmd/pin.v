module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/pin.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PinPackageKind {
	formula
	cask
}

pub struct PinPackageState {
pub:
	kind         PinPackageKind
	full_name    string
	version      string
	auto_updates bool
pub mut:
	installed      bool
	pinnable       bool
	pinned         bool
	pin_symlink    bool
	pinned_version ?string
}

pub struct PinCommandResult {
pub:
	warnings []string
	failures []string
}

pub fn (result PinCommandResult) failed() bool {
	return result.failures.len > 0
}

pub fn (mut package PinPackageState) pin() {
	if !package.installed || !package.pinnable {
		return
	}
	package.pinned = true
	package.pin_symlink = true
	package.pinned_version = package.version
}

pub fn (mut package PinPackageState) unpin() {
	package.pinned = false
	package.pin_symlink = false
	package.pinned_version = none
}

pub fn pin_packages(mut packages []PinPackageState) PinCommandResult {
	mut warnings := []string{}
	mut failures := []string{}
	for mut package in packages {
		if package.pinned {
			warnings << '${package.full_name} already pinned'
		} else if !package.installed || !package.pinnable {
			failures << '${package.full_name} not installed'
		} else {
			package.pin()
			if package.kind == .cask && package.auto_updates {
				warnings << '${package.full_name} has `auto_updates true` and may update itself outside Homebrew despite being pinned.'
			}
		}
	}
	return PinCommandResult{
		warnings: warnings
		failures: failures
	}
}

// Ruby method `run` at line 32.
pub fn ruby_pin_l32_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut packages := pin_boundary_packages(args)
	result := pin_packages(mut packages)
	return pin_command_result_value(result, packages)
}

fn pin_boundary_packages(args []brew_runtime.Value) []PinPackageState {
	if args.len == 0 {
		return []PinPackageState{}
	}
	if 'formulae' in args[0].map_data || 'casks' in args[0].map_data {
		mut packages := []PinPackageState{}
		if formulae := args[0].map_data['formulae'] {
			packages << pin_packages_from_value(formulae, .formula)
		}
		if casks := args[0].map_data['casks'] {
			packages << pin_packages_from_value(casks, .cask)
		}
		return packages
	}
	mut packages := pin_packages_from_value(args[0], .formula)
	if args.len > 1 {
		packages << pin_packages_from_value(args[1], .cask)
	}
	return packages
}

fn pin_packages_from_value(value brew_runtime.Value, default_kind PinPackageKind) []PinPackageState {
	values := if value.type_name == 'Array' { value.array_data } else { [value] }
	return values.map(pin_package_from_value(it, default_kind))
}

fn pin_package_from_value(value brew_runtime.Value, default_kind PinPackageKind) PinPackageState {
	kind_name := pin_value_attribute(value, 'kind', '')
	kind := if kind_name.to_lower() == 'cask' || value.type_name.to_lower().contains('cask') {
		PinPackageKind.cask
	} else if kind_name.to_lower() == 'formula' || value.type_name.to_lower().contains('formula') {
		PinPackageKind.formula
	} else {
		default_kind
	}
	installed := pin_value_bool_attribute(value, 'installed', true)
	version := pin_value_attribute(value, 'version', '')
	pinned := pin_value_bool_attribute(value, 'pinned', false)
	return PinPackageState{
		kind: kind
		full_name: pin_value_attribute(value, 'full_name', value.as_string())
		version: version
		auto_updates: pin_value_bool_attribute(value, 'auto_updates', false)
		installed: installed
		pinnable: pin_value_bool_attribute(value, 'pinnable', installed)
		pinned: pinned
		pin_symlink: pin_value_bool_attribute(value, 'pin_symlink', pin_value_bool_attribute(value, 'dangling_pin', pinned))
		pinned_version: if pinned_version := pin_value_attribute_optional(value, 'pinned_version') {
			pinned_version} else if pinned && version != '' {
			version} else {
			none}
	}
}

fn pin_value_attribute(value brew_runtime.Value, name string, fallback string) string {
	if attribute := value.attributes[name] {
		return attribute
	}
	if item := value.map_data[name] {
		return item.as_string()
	}
	return fallback
}

fn pin_value_attribute_optional(value brew_runtime.Value, name string) ?string {
	attribute := pin_value_attribute(value, name, '')
	return if attribute == '' { none } else { attribute }
}

fn pin_value_bool_attribute(value brew_runtime.Value, name string, fallback bool) bool {
	if attribute := value.attributes[name] {
		return attribute.to_lower() in ['true', '1', 'yes']
	}
	if item := value.map_data[name] {
		return item.as_bool() or { item.as_string().to_lower() in ['true', '1', 'yes'] }
	}
	return fallback
}

fn pin_package_value(package PinPackageState) brew_runtime.Value {
	return brew_runtime.structured_value(if package.kind == .cask { 'Cask' } else { 'Formula' }, package.full_name, {
		'kind':           package.kind.str()
		'full_name':      package.full_name
		'version':        package.version
		'auto_updates':   package.auto_updates.str()
		'installed':      package.installed.str()
		'pinnable':       package.pinnable.str()
		'pinned':         package.pinned.str()
		'pin_symlink':    package.pin_symlink.str()
		'pinned_version': package.pinned_version or { '' }
	})
}

fn pin_command_result_value(result PinCommandResult, packages []PinPackageState) brew_runtime.Value {
	mut messages := result.warnings.clone()
	messages << result.failures
	return brew_runtime.Value{
		type_name: 'PinCommandResult'
		repr: messages.join('\n')
		map_data: {
			'warnings': brew_runtime.string_array_value(result.warnings)
			'failures': brew_runtime.string_array_value(result.failures)
			'packages': brew_runtime.array_value(packages.map(pin_package_value(it)))
		}
		attributes: {
			'failed': result.failed().str()
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/cask"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Pin < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Pin the specified package, preventing it from being upgraded when
// 14:           issuing the `brew upgrade` <formula> or <cask> command. See also `unpin`.
// 15:
// 16:           *Note:* Other packages which depend on newer versions of a pinned formula
// 17:           might not install or run correctly.
// 18:           Pinned casks with `auto_updates true` may update themselves outside Homebrew.
// 19:         EOS
// 20:
// 21:         switch "--formula", "--formulae",
// 22:                description: "Treat all named arguments as formulae."
// 23:         switch "--cask", "--casks",
// 24:                description: "Treat all named arguments as casks."
// 25:
// 26:         conflicts "--formula", "--cask"
// 27:
// 28:         named_args [:installed_formula, :installed_cask], min: 1
// 29:       end
// 30:
// 31:       sig { override.void }
// 32:       def run
// 33:         formulae, casks = args.named.to_resolved_formulae_to_casks
// 34:
// 35:         (formulae + casks).each do |package|
// 36:           if package.pinned?
// 37:             opoo "#{package.full_name} already pinned"
// 38:           elsif !package.pinnable?
// 39:             ofail "#{package.full_name} not installed"
// 40:           else
// 41:             package.pin
// 42:             if package.is_a?(Cask::Cask) && package.auto_updates
// 43:               opoo "#{package.full_name} has `auto_updates true` and may update itself outside Homebrew despite " \
// 44:                    "being pinned."
// 45:             end
// 46:           end
// 47:         end
// 48:       end
// 49:     end
// 50:   end
// 51: end
