module homebrew

import brew_runtime

// Translated from Homebrew/brew `uninstall.rb`.
// The original source is retained below until every stub has a typed V body.

// UninstallPath is a candidate configuration path discovered by the source
// `Dir.glob`. Directories retain their complete basename while files have only
// their final extension removed when they are compared with formula names.
pub struct UninstallPath {
pub:
	path      string
	directory bool
}

// UninstallFormula is the portion of a Formulary result used while removing a
// rack. `available` models the source's broad rescue around `from_rack`.
pub struct UninstallFormula {
pub:
	available        bool
	name             string
	full_name        string
	pinned           bool
	remove_pin_error bool
	pkgetc_exists    bool
	pkgetc_paths     []string
	maybe_paths      []UninstallPath
	excluded_names   []string
}

pub struct UninstallKeg {
pub:
	id                   string
	name                 string
	rack                 string
	abv                  string
	rack_directory_after bool
	remaining_versions   []string
}

pub struct UninstallRack {
pub:
	path      string
	name      string
	abv       string
	directory bool
	formula   UninstallFormula
	kegs      []UninstallKeg
}

pub struct UninstallCellarRack {
pub:
	path            string
	symlink         bool
	resolved_exists bool
}

// UninstallRequest makes the filesystem and installed-package registries that
// the Ruby implementation reads explicit. This keeps the ordering and rescue
// behavior source-faithful while allowing callers to execute it deterministically.
pub struct UninstallRequest {
pub:
	racks                   []UninstallRack
	force                   bool
	ignore_dependencies     bool
	named_args              []string
	dependents              InstalledDependentsContext
	method_deprecated_error bool
	initial_failed          bool
	multiple_versions_error string
	cellar_directory        bool
	cellar_racks            []UninstallCellarRack
}

pub struct UninstallDependencyResult {
pub:
	failed              bool
	ignored_deprecation bool
	output              string
}

pub struct UninstallPinResult {
pub:
	attempted     bool
	removed       bool
	ignored_error bool
}

pub struct UninstallResult {
pub mut:
	failed              bool
	ignored_deprecation bool
	outputs             []string
	warnings            []string
	errors              []string
	operations          []string
	pin_attempts        []string
	removed_pins        []string
	broken_symlinks     []string
}

fn uninstall_unique_sorted(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	result.sort()
	return result
}

fn uninstall_sentence(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} and ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')} and ${values.last()}'
}

fn uninstall_path_basename(candidate UninstallPath) string {
	trimmed := candidate.path.trim_right('/')
	basename := trimmed.all_after_last('/')
	if candidate.directory {
		return basename
	}
	extension := basename.last_index('.') or { return basename }
	if extension <= 0 {
		return basename
	}
	return basename[..extension]
}

fn uninstall_formula_name(formula UninstallFormula) string {
	return if formula.name == '' { formula.full_name } else { formula.name }
}

fn uninstall_formula_full_name(formula UninstallFormula) string {
	return if formula.full_name == '' { formula.name } else { formula.full_name }
}

fn uninstall_keg_name(keg UninstallKeg, rack UninstallRack) string {
	return if keg.name != '' {
		keg.name
	} else if rack.name != '' { rack.name } else { rack.path.all_after_last('/') }
}

fn uninstall_keg_display(keg UninstallKeg) string {
	return if keg.id == '' { keg.name } else { keg.id }
}

fn uninstall_rack_name(rack UninstallRack) string {
	return if rack.name == '' { rack.path.trim_right('/').all_after_last('/') } else { rack.name }
}

fn uninstall_rack_abv(rack UninstallRack) string {
	return if rack.abv == '' { rack.path } else { rack.abv }
}

fn uninstall_keg_abv(keg UninstallKeg) string {
	return if keg.abv == '' { keg.id } else { keg.abv }
}

// check_for_uninstall_dependents is the typed translation of
// `check_for_dependents!`. A returned string is exactly the error emitted by
// DependentsMessage; no value means the source returned false.
pub fn check_for_uninstall_dependents(context InstalledDependentsContext,
	named_args []string) ?string {
	result := find_some_installed_dependents(context) or { return none }
	required_names := result.required_kegs.map(if it.name == '' { it.id } else { it.name })
	return new_dependents_message(required_names, result.dependents, named_args).output()
}

// handle_uninstall_unsatisfied_dependents preserves the early return for
// `--ignore-dependencies` and the source's silent MethodDeprecatedError rescue.
pub fn handle_uninstall_unsatisfied_dependents(context InstalledDependentsContext,
	ignore_dependencies bool, named_args []string,
	method_deprecated_error bool) UninstallDependencyResult {
	if ignore_dependencies {
		return UninstallDependencyResult{}
	}
	if method_deprecated_error {
		return UninstallDependencyResult{
			ignored_deprecation: true
		}
	}
	if output := check_for_uninstall_dependents(context, named_args) {
		return UninstallDependencyResult{
			failed: true
			output: output
		}
	}
	return UninstallDependencyResult{}
}

// remove_uninstall_pin models `Formulary.from_rack(rack).unpin`; every lookup
// or unlink error is intentionally swallowed by the source.
pub fn remove_uninstall_pin(rack UninstallRack) UninstallPinResult {
	if !rack.formula.available {
		return UninstallPinResult{
			attempted: true
			ignored_error: true
		}
	}
	if rack.formula.remove_pin_error {
		return UninstallPinResult{
			attempted: true
			ignored_error: true
		}
	}
	return UninstallPinResult{
		attempted: true
		removed: rack.formula.pinned
	}
}

fn record_uninstall_pin(rack UninstallRack, mut result UninstallResult) {
	pin := remove_uninstall_pin(rack)
	if pin.attempted {
		result.pin_attempts << rack.path
	}
	if pin.removed {
		result.removed_pins << rack.path
	}
}

fn append_uninstall_configuration_warnings(formula UninstallFormula,
	mut result UninstallResult) {
	if !formula.available {
		return
	}
	name := uninstall_formula_name(formula)
	mut paths := []string{}
	if formula.pkgetc_exists {
		paths = uninstall_unique_sorted(formula.pkgetc_paths)
	}
	if paths.len > 0 {
		result.warnings << 'The following ${name} configuration files have not been removed!\nIf desired, remove them manually with `rm -rf`:\n  ${paths.join('\n  ')}'
	}

	mut maybe_paths := []string{}
	for candidate in formula.maybe_paths {
		if uninstall_path_basename(candidate) in formula.excluded_names {
			continue
		}
		if paths.len > 0 && candidate.path in paths {
			continue
		}
		maybe_paths << candidate.path
	}
	maybe_paths = uninstall_unique_sorted(maybe_paths)
	if maybe_paths.len > 0 {
		result.warnings << 'The following may be ${name} configuration files and have not been removed!\nIf desired, remove them manually with `rm -rf`:\n  ${maybe_paths.join('\n  ')}'
	}
}

fn cleanup_uninstall_broken_symlinks(request UninstallRequest, mut result UninstallResult) {
	if !request.cellar_directory {
		return
	}
	for rack in request.cellar_racks {
		if rack.symlink && !rack.resolved_exists {
			result.broken_symlinks << rack.path
			result.operations << 'unlink-broken-symlink:${rack.path}'
		}
	}
}

// uninstall_kegs executes the source algorithm against an explicit package and
// filesystem snapshot. Operations are retained in the same order as unlink,
// uninstall, pin removal, and final Cellar symlink cleanup in Ruby.
pub fn uninstall_kegs(request UninstallRequest) UninstallResult {
	dependency := handle_uninstall_unsatisfied_dependents(request.dependents, request.ignore_dependencies, request.named_args, request.method_deprecated_error)
	mut result := UninstallResult{
		failed: request.initial_failed || dependency.failed
		ignored_deprecation: dependency.ignored_deprecation
	}
	if dependency.output != '' {
		result.errors << dependency.output
	}

	if !result.failed {
		if request.multiple_versions_error != '' {
			result.failed = true
			result.errors << request.multiple_versions_error
		} else {
			for rack in request.racks {
				if request.force {
					if rack.directory {
						result.outputs << 'Uninstalling ${uninstall_rack_name(rack)}... (${uninstall_rack_abv(rack)})'
						for keg in rack.kegs {
							result.operations << 'unlink:${uninstall_keg_display(keg)}'
							result.operations << 'uninstall:${uninstall_keg_display(keg)}'
						}
					}
					record_uninstall_pin(rack, mut result)
					continue
				}

				for keg in rack.kegs {
					if rack.formula.available && rack.formula.pinned {
						result.errors << '${uninstall_formula_full_name(rack.formula)} is pinned. You must unpin it to uninstall.'
						break
					}
					result.operations << 'lock:${uninstall_keg_display(keg)}'
					result.outputs << 'Uninstalling ${uninstall_keg_display(keg)}... (${uninstall_keg_abv(keg)})'
					result.operations << 'unlink:${uninstall_keg_display(keg)}'
					result.operations << 'uninstall:${uninstall_keg_display(keg)}'
					keg_rack := UninstallRack{
						...rack
						path: if keg.rack == '' { rack.path } else { keg.rack }
					}
					record_uninstall_pin(keg_rack, mut result)
					if keg.rack_directory_after {
						versions := keg.remaining_versions.map(it.trim_right('/').all_after_last('/'))
						verb := if versions.len == 1 { 'is' } else { 'are' }
						name := uninstall_keg_name(keg, rack)
						result.outputs << '${name} ${uninstall_sentence(versions)} ${verb} still installed.\nTo remove all versions, run:\n  brew uninstall --force ${name}'
					}
					append_uninstall_configuration_warnings(rack.formula, mut result)
					result.operations << 'unlock:${uninstall_keg_display(keg)}'
				}
			}
		}
	}
	cleanup_uninstall_broken_symlinks(request, mut result)
	return result
}

fn uninstall_path_value(path UninstallPath) brew_runtime.Value {
	return brew_runtime.structured_value('Uninstall::Path', path.path, {
		'path':      path.path
		'directory': path.directory.str()
	})
}

fn uninstall_path_from_value(value brew_runtime.Value) UninstallPath {
	return UninstallPath{
		path: value.attributes['path'] or { value.repr }
		directory: (value.attributes['directory'] or { 'false' }).bool()
	}
}

fn uninstall_formula_value(formula UninstallFormula) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Uninstall::Formula'
		repr: uninstall_formula_full_name(formula)
		attributes: {
			'available':        formula.available.str()
			'name':             formula.name
			'full_name':        formula.full_name
			'pinned':           formula.pinned.str()
			'remove_pin_error': formula.remove_pin_error.str()
			'pkgetc_exists':    formula.pkgetc_exists.str()
		}
		map_data: {
			'pkgetc_paths':   brew_runtime.string_array_value(formula.pkgetc_paths)
			'maybe_paths':    brew_runtime.array_value(formula.maybe_paths.map(uninstall_path_value(it)))
			'excluded_names': brew_runtime.string_array_value(formula.excluded_names)
		}
	}
}

fn uninstall_formula_from_value(value brew_runtime.Value) !UninstallFormula {
	if value.type_name != 'Uninstall::Formula' {
		return error('expected Uninstall::Formula')
	}
	return UninstallFormula{
		available: (value.attributes['available'] or { 'false' }).bool()
		name: value.attributes['name'] or { '' }
		full_name: value.attributes['full_name'] or { value.repr }
		pinned: (value.attributes['pinned'] or { 'false' }).bool()
		remove_pin_error: (value.attributes['remove_pin_error'] or { 'false' }).bool()
		pkgetc_exists: (value.attributes['pkgetc_exists'] or { 'false' }).bool()
		pkgetc_paths: (value.map_data['pkgetc_paths'] or { brew_runtime.string_array_value([]) }).as_string_array()!
		maybe_paths: (value.map_data['maybe_paths'] or { brew_runtime.array_value([]) }).as_array()!.map(uninstall_path_from_value(it))
		excluded_names: (value.map_data['excluded_names'] or { brew_runtime.string_array_value([]) }).as_string_array()!
	}
}

fn uninstall_keg_value(keg UninstallKeg) brew_runtime.Value {
	return brew_runtime.structured_value('Uninstall::Keg', uninstall_keg_display(keg), {
		'id':                   keg.id
		'name':                 keg.name
		'rack':                 keg.rack
		'abv':                  keg.abv
		'rack_directory_after': keg.rack_directory_after.str()
		'remaining_versions':   keg.remaining_versions.join('\x1e')
	})
}

fn uninstall_keg_from_value(value brew_runtime.Value) UninstallKeg {
	remaining := value.attributes['remaining_versions'] or { '' }
	return UninstallKeg{
		id: value.attributes['id'] or { value.repr }
		name: value.attributes['name'] or { '' }
		rack: value.attributes['rack'] or { '' }
		abv: value.attributes['abv'] or { '' }
		rack_directory_after: (value.attributes['rack_directory_after'] or { 'false' }).bool()
		remaining_versions: if remaining == '' { []string{} } else { remaining.split('\x1e') }
	}
}

pub fn uninstall_rack_value(rack UninstallRack) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Uninstall::Rack'
		repr: rack.path
		attributes: {
			'path':      rack.path
			'name':      rack.name
			'abv':       rack.abv
			'directory': rack.directory.str()
		}
		map_data: {
			'formula': uninstall_formula_value(rack.formula)
			'kegs':    brew_runtime.array_value(rack.kegs.map(uninstall_keg_value(it)))
		}
	}
}

fn uninstall_rack_from_value(value brew_runtime.Value) !UninstallRack {
	if value.type_name != 'Uninstall::Rack' {
		return error('expected Uninstall::Rack')
	}
	return UninstallRack{
		path: value.attributes['path'] or { value.repr }
		name: value.attributes['name'] or { '' }
		abv: value.attributes['abv'] or { '' }
		directory: (value.attributes['directory'] or { 'false' }).bool()
		formula: uninstall_formula_from_value(value.map_data['formula'] or { return error('formula is required') })!
		kegs: (value.map_data['kegs'] or { brew_runtime.array_value([]) }).as_array()!.map(uninstall_keg_from_value(it))
	}
}

fn uninstall_cellar_rack_value(rack UninstallCellarRack) brew_runtime.Value {
	return brew_runtime.structured_value('Uninstall::CellarRack', rack.path, {
		'path':            rack.path
		'symlink':         rack.symlink.str()
		'resolved_exists': rack.resolved_exists.str()
	})
}

fn uninstall_cellar_rack_from_value(value brew_runtime.Value) UninstallCellarRack {
	return UninstallCellarRack{
		path: value.attributes['path'] or { value.repr }
		symlink: (value.attributes['symlink'] or { 'false' }).bool()
		resolved_exists: (value.attributes['resolved_exists'] or { 'false' }).bool()
	}
}

pub fn uninstall_request_value(request UninstallRequest) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Uninstall::Request'
		repr: 'uninstall request'
		attributes: {
			'force':                   request.force.str()
			'ignore_dependencies':     request.ignore_dependencies.str()
			'method_deprecated_error': request.method_deprecated_error.str()
			'initial_failed':          request.initial_failed.str()
			'multiple_versions_error': request.multiple_versions_error
			'cellar_directory':        request.cellar_directory.str()
		}
		map_data: {
			'racks':        brew_runtime.array_value(request.racks.map(uninstall_rack_value(it)))
			'named_args':   brew_runtime.string_array_value(request.named_args)
			'dependents':   installed_dependents_context_value(request.dependents)
			'cellar_racks': brew_runtime.array_value(request.cellar_racks.map(uninstall_cellar_rack_value(it)))
		}
	}
}

fn uninstall_request_from_value(value brew_runtime.Value) !UninstallRequest {
	if value.type_name != 'Uninstall::Request' {
		return error('expected Uninstall::Request')
	}
	return UninstallRequest{
		racks: (value.map_data['racks'] or { brew_runtime.array_value([]) }).as_array()!.map(uninstall_rack_from_value(it)!)
		force: (value.attributes['force'] or { 'false' }).bool()
		ignore_dependencies: (value.attributes['ignore_dependencies'] or { 'false' }).bool()
		named_args: (value.map_data['named_args'] or { brew_runtime.string_array_value([]) }).as_string_array()!
		dependents: installed_dependents_context_from_value(value.map_data['dependents'] or { installed_dependents_context_value(InstalledDependentsContext{}) })!
		method_deprecated_error: (value.attributes['method_deprecated_error'] or { 'false' }).bool()
		initial_failed: (value.attributes['initial_failed'] or { 'false' }).bool()
		multiple_versions_error: value.attributes['multiple_versions_error'] or { '' }
		cellar_directory: (value.attributes['cellar_directory'] or { 'false' }).bool()
		cellar_racks: (value.map_data['cellar_racks'] or { brew_runtime.array_value([]) }).as_array()!.map(uninstall_cellar_rack_from_value(it))
	}
}

fn uninstall_result_value(result UninstallResult) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Uninstall::Result'
		repr: result.outputs.join('\n')
		attributes: {
			'failed':              result.failed.str()
			'ignored_deprecation': result.ignored_deprecation.str()
		}
		map_data: {
			'outputs':         brew_runtime.string_array_value(result.outputs)
			'warnings':        brew_runtime.string_array_value(result.warnings)
			'errors':          brew_runtime.string_array_value(result.errors)
			'operations':      brew_runtime.string_array_value(result.operations)
			'pin_attempts':    brew_runtime.string_array_value(result.pin_attempts)
			'removed_pins':    brew_runtime.string_array_value(result.removed_pins)
			'broken_symlinks': brew_runtime.string_array_value(result.broken_symlinks)
		}
	}
}

// Ruby method `self.uninstall_kegs(kegs_by_rack, casks: [], force: false, ignore_dependencies: false, named_args: [])` at line 22.
pub fn ruby_uninstall_l22_d1_self_uninstall_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'uninstall request is required')
	}
	request := uninstall_request_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return uninstall_result_value(uninstall_kegs(request))
}

// Ruby method `self.handle_unsatisfied_dependents(kegs_by_rack, casks: [], ignore_dependencies: false, named_args: [])` at line 132.
pub fn ruby_uninstall_l132_d2_self_handle_unsatisfied_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'uninstall request is required')
	}
	request := uninstall_request_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := handle_uninstall_unsatisfied_dependents(request.dependents, request.ignore_dependencies, request.named_args, request.method_deprecated_error)
	return brew_runtime.structured_value('Uninstall::DependencyResult', result.output, {
		'failed':              result.failed.str()
		'ignored_deprecation': result.ignored_deprecation.str()
		'output':              result.output
	})
}

// Ruby method `self.check_for_dependents!(kegs, casks: [], named_args: [])` at line 143.
pub fn ruby_uninstall_l143_d3_self_check_for_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'installed dependents context is required')
	}
	context := installed_dependents_context_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	named_args := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	output := check_for_uninstall_dependents(context, named_args) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.structured_value('DependentsMessage', output, {
		'output': output
	})
}

// Ruby method `self.rm_pin(rack)` at line 151.
pub fn ruby_uninstall_l151_d4_self_rm_pin(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'rack is required')
	}
	rack := uninstall_rack_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := remove_uninstall_pin(rack)
	return brew_runtime.structured_value('Uninstall::PinResult', rack.path, {
		'attempted':     result.attempted.str()
		'removed':       result.removed.str()
		'ignored_error': result.ignored_error.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependents_message"
// 5: require "installed_dependents"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Helper module for uninstalling kegs.
// 10:   module Uninstall
// 11:     extend ::Utils::Output::Mixin
// 12:
// 13:     sig {
// 14:       params(
// 15:         kegs_by_rack:        T::Hash[Pathname, T::Array[Keg]],
// 16:         casks:               T::Array[Cask::Cask],
// 17:         force:               T::Boolean,
// 18:         ignore_dependencies: T::Boolean,
// 19:         named_args:          T::Array[String],
// 20:       ).void
// 21:     }
// 22:     def self.uninstall_kegs(kegs_by_rack, casks: [], force: false, ignore_dependencies: false, named_args: [])
// 23:       handle_unsatisfied_dependents(kegs_by_rack,
// 24:                                     casks:,
// 25:                                     ignore_dependencies:,
// 26:                                     named_args:)
// 27:       return if Homebrew.failed?
// 28:
// 29:       kegs_by_rack.each do |rack, kegs|
// 30:         if force
// 31:           name = rack.basename
// 32:
// 33:           if rack.directory?
// 34:             puts "Uninstalling #{name}... (#{rack.abv})"
// 35:             kegs.each do |keg|
// 36:               keg.unlink
// 37:               keg.uninstall
// 38:             end
// 39:           end
// 40:
// 41:           rm_pin rack
// 42:         else
// 43:           kegs.each do |keg|
// 44:             begin
// 45:               f = Formulary.from_rack(rack)
// 46:               if f.pinned?
// 47:                 onoe "#{f.full_name} is pinned. You must unpin it to uninstall."
// 48:                 break # exit keg loop and move on to next rack
// 49:               end
// 50:             rescue
// 51:               nil
// 52:             end
// 53:
// 54:             keg.lock do
// 55:               puts "Uninstalling #{keg}... (#{keg.abv})"
// 56:               keg.unlink
// 57:               keg.uninstall
// 58:               rack = keg.rack
// 59:               rm_pin rack
// 60:
// 61:               if rack.directory?
// 62:                 versions = rack.subdirs.map(&:basename)
// 63:                 puts <<~EOS
// 64:                   #{keg.name} #{versions.to_sentence} #{versions.one? ? "is" : "are"} still installed.
// 65:                   To remove all versions, run:
// 66:                     brew uninstall --force #{keg.name}
// 67:                 EOS
// 68:               end
// 69:
// 70:               next unless f
// 71:
// 72:               paths = f.pkgetc.find.map(&:to_s) if f.pkgetc.exist?
// 73:               if paths.present?
// 74:                 puts
// 75:                 opoo <<~EOS
// 76:                   The following #{f.name} configuration files have not been removed!
// 77:                   If desired, remove them manually with `rm -rf`:
// 78:                     #{paths.sort.uniq.join("\n  ")}
// 79:                 EOS
// 80:               end
// 81:
// 82:               unversioned_name = f.name.gsub(/@.+$/, "")
// 83:               maybe_paths = Dir.glob("#{f.etc}/#{unversioned_name}*")
// 84:               excluded_names = if Homebrew::EnvConfig.no_install_from_api?
// 85:                 Formula.names
// 86:               else
// 87:                 Homebrew::API.formula_names
// 88:               end.to_set
// 89:               maybe_paths = maybe_paths.reject do |path|
// 90:                 # Remove extension only if a file
// 91:                 # (e.g. directory with name "openssl@1.1" will be trimmed to "openssl@1")
// 92:                 basename = if File.directory?(path)
// 93:                   File.basename(path)
// 94:                 else
// 95:                   File.basename(path, ".*")
// 96:                 end
// 97:                 excluded_names.include?(basename)
// 98:               end
// 99:               maybe_paths -= paths if paths.present?
// 100:               if maybe_paths.present?
// 101:                 puts
// 102:                 opoo <<~EOS
// 103:                   The following may be #{f.name} configuration files and have not been removed!
// 104:                   If desired, remove them manually with `rm -rf`:
// 105:                     #{maybe_paths.sort.uniq.join("\n  ")}
// 106:                 EOS
// 107:               end
// 108:             end
// 109:           end
// 110:         end
// 111:       end
// 112:     rescue MultipleVersionsInstalledError => e
// 113:       ofail e
// 114:     ensure
// 115:       # If we delete Cellar/newname, then Cellar/oldname symlink
// 116:       # can become broken and we have to remove it.
// 117:       if HOMEBREW_CELLAR.directory?
// 118:         HOMEBREW_CELLAR.children.each do |rack|
// 119:           rack.unlink if rack.symlink? && !rack.resolved_path_exists?
// 120:         end
// 121:       end
// 122:     end
// 123:
// 124:     sig {
// 125:       params(
// 126:         kegs_by_rack:        T::Hash[Pathname, T::Array[Keg]],
// 127:         casks:               T::Array[Cask::Cask],
// 128:         ignore_dependencies: T::Boolean,
// 129:         named_args:          T::Array[String],
// 130:       ).void
// 131:     }
// 132:     def self.handle_unsatisfied_dependents(kegs_by_rack, casks: [], ignore_dependencies: false, named_args: [])
// 133:       return if ignore_dependencies
// 134:
// 135:       all_kegs = kegs_by_rack.values.flatten(1)
// 136:       check_for_dependents!(all_kegs, casks:, named_args:)
// 137:     rescue MethodDeprecatedError
// 138:       # Silently ignore deprecations when uninstalling.
// 139:       nil
// 140:     end
// 141:
// 142:     sig { params(kegs: T::Array[Keg], casks: T::Array[Cask::Cask], named_args: T::Array[String]).returns(T::Boolean) }
// 143:     def self.check_for_dependents!(kegs, casks: [], named_args: [])
// 144:       return false unless (result = InstalledDependents.find_some_installed_dependents(kegs, casks:))
// 145:
// 146:       DependentsMessage.new(*result, named_args:).output
// 147:       true
// 148:     end
// 149:
// 150:     sig { params(rack: Pathname).void }
// 151:     def self.rm_pin(rack)
// 152:       Formulary.from_rack(rack).unpin
// 153:     rescue
// 154:       nil
// 155:     end
// 156:   end
// 157: end
