module homebrew

import ruby
import os

// Translated from Homebrew/brew `formula_pin.rb`.
pub struct FormulaPin {
pub:
	name        string
	rack        string
	pinned_kegs string
}

pub fn new_formula_pin(name string, rack string, pinned_kegs string) &FormulaPin {
	return &FormulaPin{
		name: name
		rack: rack
		pinned_kegs: pinned_kegs
	}
}

pub fn (pin FormulaPin) path() string {
	return os.join_path(pin.pinned_kegs, pin.name)
}

pub fn (pin FormulaPin) installed_prefixes() []string {
	mut prefixes := []string{}
	for name in os.ls(pin.rack) or { return prefixes } {
		path := os.join_path(pin.rack, name)
		if os.is_dir(path) && !os.is_link(path) {
			prefixes << path
		}
	}
	prefixes.sort()
	return prefixes
}

pub fn (pin FormulaPin) pinned() bool {
	return os.is_link(pin.path())
}

pub fn (pin FormulaPin) pinnable() bool {
	return pin.installed_prefixes().len > 0
}

pub fn formula_pin_relative_path(target string, directory string) string {
	target_parts := os.norm_path(target).trim_left(os.path_separator).split(os.path_separator)
	directory_parts := os.norm_path(directory).trim_left(os.path_separator).split(os.path_separator)
	mut common := 0
	for common < target_parts.len && common < directory_parts.len && target_parts[common] == directory_parts[common] {
		common++
	}
	mut parts := []string{cap: directory_parts.len - common + target_parts.len - common}
	for _ in common .. directory_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join(os.path_separator) }
}

pub fn (pin FormulaPin) pin_at(version PkgVersion) ! {
	os.mkdir_all(pin.pinned_kegs)!
	version_path := os.join_path(pin.rack, version.to_s())
	if !pin.pinned() && os.exists(version_path) {
		target := formula_pin_relative_path(version_path, pin.pinned_kegs)
		os.symlink(target, pin.path())!
	}
}

fn formula_pin_newer(left string, right string) bool {
	left_version := parse_pkg_version(left) or { return left > right }
	right_version := parse_pkg_version(right) or { return left > right }
	return left_version.compare_to(right_version) > 0
}

pub fn (pin FormulaPin) pin_latest() ! {
	prefixes := pin.installed_prefixes()
	if prefixes.len == 0 {
		return
	}
	mut latest := os.base(prefixes[0])
	for prefix in prefixes[1..] {
		candidate := os.base(prefix)
		if formula_pin_newer(candidate, latest) {
			latest = candidate
		}
	}
	pin.pin_at(parse_pkg_version(latest)!)!
}

pub fn (pin FormulaPin) unpin() ! {
	if pin.pinned() {
		os.rm(pin.path())!
	}
	entries := os.ls(pin.pinned_kegs) or { return }
	if entries.len == 0 {
		os.rmdir(pin.pinned_kegs)!
	}
}

pub fn (pin FormulaPin) pinned_version() ?PkgVersion {
	if !pin.pinned() {
		return none
	}
	resolved := os.real_path(pin.path())
	return parse_pkg_version(os.base(resolved)) or { none }
}

fn formula_pin_value(pin &FormulaPin) ruby.Value {
	return ruby.structured_value('FormulaPin', pin.path(), {
		'formula_pin_address': u64(voidptr(pin)).str()
		'name':                pin.name
		'rack':                pin.rack
		'pinned_kegs':         pin.pinned_kegs
	})
}

fn formula_pin_from_value(value ruby.Value) &FormulaPin {
	if address := value.attributes['formula_pin_address'] {
		return unsafe { &FormulaPin(voidptr(address.u64())) }
	}
	name := value.attributes['name'] or { value.map_data['name'].as_string() }
	rack := value.attributes['rack'] or { value.map_data['rack'].as_string() }
	pinned_kegs := value.attributes['pinned_kegs'] or {
		value.map_data['pinned_kegs'].as_string()
	}
	return new_formula_pin(name, rack, pinned_kegs)
}

pub fn formula_pin_boundary(pin &FormulaPin) ruby.Value {
	return formula_pin_value(pin)
}
