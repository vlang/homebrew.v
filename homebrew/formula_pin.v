module homebrew

import ruby
import os

// Translated from Homebrew/brew `formula_pin.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `initialize(formula)` at line 9.
pub fn ruby_formula_pin_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula is required')
	}
	formula := args[0]
	name := formula.attributes['name'] or { formula.map_data['name'].as_string() }
	rack := formula.attributes['rack'] or { formula.map_data['rack'].as_string() }
	pinned_kegs := formula.attributes['pinned_kegs'] or {
		if args.len > 1 { args[1].as_string() } else { os.getenv('HOMEBREW_PINNED_KEGS') }
	}
	return formula_pin_value(new_formula_pin(name, rack, pinned_kegs))
}

// Ruby method `path` at line 14.
pub fn ruby_formula_pin_l14_d2_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'FormulaPin is required')
	}
	return ruby.object_value('Pathname', formula_pin_from_value(args[0]).path())
}

// Ruby method `pin_at(version)` at line 19.
pub fn ruby_formula_pin_l19_d3_pin_at(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'FormulaPin and version are required')
	}
	version := parse_pkg_version(args[1].as_string()) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	formula_pin_from_value(args[0]).pin_at(version) or {
		return ruby.object_value('SystemCallError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `pin` at line 26.
pub fn ruby_formula_pin_l26_d4_pin(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'FormulaPin is required')
	}
	formula_pin_from_value(args[0]).pin_latest() or {
		return ruby.object_value('SystemCallError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `unpin` at line 34.
pub fn ruby_formula_pin_l34_d5_unpin(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'FormulaPin is required')
	}
	formula_pin_from_value(args[0]).unpin() or {
		return ruby.object_value('SystemCallError', err.msg())
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `pinned?` at line 40.
pub fn ruby_formula_pin_l40_d6_pinned(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && formula_pin_from_value(args[0]).pinned())
}

// Ruby method `pinnable?` at line 45.
pub fn ruby_formula_pin_l45_d7_pinnable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && formula_pin_from_value(args[0]).pinnable())
}

// Ruby method `pinned_version` at line 50.
pub fn ruby_formula_pin_l50_d8_pinned_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	version := formula_pin_from_value(args[0]).pinned_version() or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.object_value('PkgVersion', version.to_s())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5:
// 6: # Helper functions for pinning a formula.
// 7: class FormulaPin
// 8:   sig { params(formula: Formula).void }
// 9:   def initialize(formula)
// 10:     @formula = formula
// 11:   end
// 12:
// 13:   sig { returns(Pathname) }
// 14:   def path
// 15:     HOMEBREW_PINNED_KEGS/@formula.name
// 16:   end
// 17:
// 18:   sig { params(version: PkgVersion).void }
// 19:   def pin_at(version)
// 20:     HOMEBREW_PINNED_KEGS.mkpath
// 21:     version_path = @formula.rack/version.to_s
// 22:     path.make_relative_symlink(version_path) if !pinned? && version_path.exist?
// 23:   end
// 24:
// 25:   sig { void }
// 26:   def pin
// 27:     latest_keg = @formula.installed_kegs.max_by(&:scheme_and_version)
// 28:     return if latest_keg.nil?
// 29:
// 30:     pin_at(latest_keg.version)
// 31:   end
// 32:
// 33:   sig { void }
// 34:   def unpin
// 35:     path.unlink if pinned?
// 36:     HOMEBREW_PINNED_KEGS.rmdir_if_possible
// 37:   end
// 38:
// 39:   sig { returns(T::Boolean) }
// 40:   def pinned?
// 41:     path.symlink?
// 42:   end
// 43:
// 44:   sig { returns(T::Boolean) }
// 45:   def pinnable?
// 46:     !@formula.installed_prefixes.empty?
// 47:   end
// 48:
// 49:   sig { returns(T.nilable(PkgVersion)) }
// 50:   def pinned_version
// 51:     Keg.new(path.resolved_path).version if pinned?
// 52:   end
// 53: end
