module homebrew

import ruby

// Translated from Homebrew/brew `uninstall.rb`.

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

fn uninstall_path_value(path UninstallPath) ruby.Value {
	return ruby.structured_value('Uninstall::Path', path.path, {
		'path':      path.path
		'directory': path.directory.str()
	})
}

fn uninstall_path_from_value(value ruby.Value) UninstallPath {
	return UninstallPath{
		path: value.attributes['path'] or { value.repr }
		directory: (value.attributes['directory'] or { 'false' }).bool()
	}
}

fn uninstall_formula_value(formula UninstallFormula) ruby.Value {
	return ruby.Value{
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
			'pkgetc_paths':   ruby.string_array_value(formula.pkgetc_paths)
			'maybe_paths':    ruby.array_value(formula.maybe_paths.map(uninstall_path_value(it)))
			'excluded_names': ruby.string_array_value(formula.excluded_names)
		}
	}
}

fn uninstall_formula_from_value(value ruby.Value) !UninstallFormula {
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
		pkgetc_paths: (value.map_data['pkgetc_paths'] or { ruby.string_array_value([]) }).as_string_array()!
		maybe_paths: (value.map_data['maybe_paths'] or { ruby.array_value([]) }).as_array()!.map(uninstall_path_from_value(it))
		excluded_names: (value.map_data['excluded_names'] or { ruby.string_array_value([]) }).as_string_array()!
	}
}

fn uninstall_keg_value(keg UninstallKeg) ruby.Value {
	return ruby.structured_value('Uninstall::Keg', uninstall_keg_display(keg), {
		'id':                   keg.id
		'name':                 keg.name
		'rack':                 keg.rack
		'abv':                  keg.abv
		'rack_directory_after': keg.rack_directory_after.str()
		'remaining_versions':   keg.remaining_versions.join('\x1e')
	})
}

fn uninstall_keg_from_value(value ruby.Value) UninstallKeg {
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

pub fn uninstall_rack_value(rack UninstallRack) ruby.Value {
	return ruby.Value{
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
			'kegs':    ruby.array_value(rack.kegs.map(uninstall_keg_value(it)))
		}
	}
}

fn uninstall_rack_from_value(value ruby.Value) !UninstallRack {
	if value.type_name != 'Uninstall::Rack' {
		return error('expected Uninstall::Rack')
	}
	return UninstallRack{
		path: value.attributes['path'] or { value.repr }
		name: value.attributes['name'] or { '' }
		abv: value.attributes['abv'] or { '' }
		directory: (value.attributes['directory'] or { 'false' }).bool()
		formula: uninstall_formula_from_value(value.map_data['formula'] or { return error('formula is required') })!
		kegs: (value.map_data['kegs'] or { ruby.array_value([]) }).as_array()!.map(uninstall_keg_from_value(it))
	}
}

fn uninstall_cellar_rack_value(rack UninstallCellarRack) ruby.Value {
	return ruby.structured_value('Uninstall::CellarRack', rack.path, {
		'path':            rack.path
		'symlink':         rack.symlink.str()
		'resolved_exists': rack.resolved_exists.str()
	})
}

fn uninstall_cellar_rack_from_value(value ruby.Value) UninstallCellarRack {
	return UninstallCellarRack{
		path: value.attributes['path'] or { value.repr }
		symlink: (value.attributes['symlink'] or { 'false' }).bool()
		resolved_exists: (value.attributes['resolved_exists'] or { 'false' }).bool()
	}
}

pub fn uninstall_request_value(request UninstallRequest) ruby.Value {
	return ruby.Value{
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
			'racks':        ruby.array_value(request.racks.map(uninstall_rack_value(it)))
			'named_args':   ruby.string_array_value(request.named_args)
			'dependents':   installed_dependents_context_value(request.dependents)
			'cellar_racks': ruby.array_value(request.cellar_racks.map(uninstall_cellar_rack_value(it)))
		}
	}
}

fn uninstall_request_from_value(value ruby.Value) !UninstallRequest {
	if value.type_name != 'Uninstall::Request' {
		return error('expected Uninstall::Request')
	}
	return UninstallRequest{
		racks: (value.map_data['racks'] or { ruby.array_value([]) }).as_array()!.map(uninstall_rack_from_value(it)!)
		force: (value.attributes['force'] or { 'false' }).bool()
		ignore_dependencies: (value.attributes['ignore_dependencies'] or { 'false' }).bool()
		named_args: (value.map_data['named_args'] or { ruby.string_array_value([]) }).as_string_array()!
		dependents: installed_dependents_context_from_value(value.map_data['dependents'] or { installed_dependents_context_value(InstalledDependentsContext{}) })!
		method_deprecated_error: (value.attributes['method_deprecated_error'] or { 'false' }).bool()
		initial_failed: (value.attributes['initial_failed'] or { 'false' }).bool()
		multiple_versions_error: value.attributes['multiple_versions_error'] or { '' }
		cellar_directory: (value.attributes['cellar_directory'] or { 'false' }).bool()
		cellar_racks: (value.map_data['cellar_racks'] or { ruby.array_value([]) }).as_array()!.map(uninstall_cellar_rack_from_value(it))
	}
}

fn uninstall_result_value(result UninstallResult) ruby.Value {
	return ruby.Value{
		type_name: 'Uninstall::Result'
		repr: result.outputs.join('\n')
		attributes: {
			'failed':              result.failed.str()
			'ignored_deprecation': result.ignored_deprecation.str()
		}
		map_data: {
			'outputs':         ruby.string_array_value(result.outputs)
			'warnings':        ruby.string_array_value(result.warnings)
			'errors':          ruby.string_array_value(result.errors)
			'operations':      ruby.string_array_value(result.operations)
			'pin_attempts':    ruby.string_array_value(result.pin_attempts)
			'removed_pins':    ruby.string_array_value(result.removed_pins)
			'broken_symlinks': ruby.string_array_value(result.broken_symlinks)
		}
	}
}
