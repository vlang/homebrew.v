module homebrew

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
