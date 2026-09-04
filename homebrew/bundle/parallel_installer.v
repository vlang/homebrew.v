module bundle

import ruby
import os

// Translated from Homebrew/brew `bundle/parallel_installer.rb`.

pub struct ParallelInstallerConfig {
pub:
	jobs                      int = 1
	no_upgrade                bool
	verbose                   bool
	force                     bool
	quiet                     bool
	verify_attestations       bool
	installed_taps            []string
	direct_dependencies       map[string][]string
	recursive_dependencies    map[string][]string
	cask_dependencies         map[string][]string
	tap_dependencies          map[string][]string
	implicit_dependency_names []string
	tty_path                  string = '/dev/tty'
}

@[heap]
pub struct ParallelInstaller {
pub:
	entries []InstallableEntry
	config  ParallelInstallerConfig
pub mut:
	installed_taps       []string
	output               []string
	errors               []string
	installation_order   []string
	attestation_prepared bool
	tap_cache_cleared    bool
	tty_clear_count      int
}

pub fn new_parallel_installer(entries []InstallableEntry,
	config ParallelInstallerConfig) &ParallelInstaller {
	jobs := if config.jobs > 0 { config.jobs } else { 1 }
	return &ParallelInstaller{
		entries: entries.clone()
		config: ParallelInstallerConfig{
			...config
			jobs: jobs
		}
		installed_taps: config.installed_taps.clone()
	}
}

fn parallel_installer_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value != '' && value !in result {
			result << value
		}
	}
	return result
}

fn parallel_installer_intersects(left []string, right []string) bool {
	for value in left {
		if value in right {
			return true
		}
	}
	return false
}

pub fn parallel_installer_normalize_formula_name(name string) string {
	parts := name.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { name }
}

pub fn (installer &ParallelInstaller) cask_dep_names(name string,
	cask_names []string) []string {
	direct := installer.config.cask_dependencies[name] or { return [] }
	return parallel_installer_unique(direct.filter(it in cask_names))
}

pub fn (installer &ParallelInstaller) build_dependency_map(entries []InstallableEntry) map[string][]string {
	mut entry_name_map := map[string]string{}
	for entry in entries {
		entry_name_map[entry.name] = entry.name
		entry_name_map[parallel_installer_normalize_formula_name(entry.name)] = entry.name
	}

	mut attestation_formula := ''
	if installer.config.verify_attestations {
		for entry in entries {
			if entry.package_kind == .brew && entry.name == 'gh' {
				attestation_formula = entry.name
				break
			}
		}
	}

	mut direct_dependencies := map[string][]string{}
	mut recursive_dependencies := map[string][]string{}
	mut cask_names := []string{}
	for entry in entries {
		if entry.package_kind == .cask {
			cask_names << entry.name
		}
	}
	for entry in entries {
		mut dependencies := installer.config.direct_dependencies[entry.name] or { []string{} }
		dependencies = dependencies.clone()
		if configured_taps := installer.config.tap_dependencies[entry.name] {
			for tap_name in configured_taps {
				if tap_name !in installer.installed_taps {
					dependencies << tap_name
				}
			}
		} else if tap_name := entry.tap_name() {
			if tap_name !in installer.installed_taps {
				dependencies << tap_name
			}
		}
		if attestation_formula != '' && entry.package_kind in [.brew, .cask]
			&& entry.name != attestation_formula {
			dependencies << attestation_formula
		}
		direct_dependencies[entry.name] = parallel_installer_unique(dependencies)
		recursive_dependencies[entry.name] = match entry.package_kind {
			.brew {
				parallel_installer_unique(installer.config.recursive_dependencies[entry.name] or {
					[]string{}
				})
			}
			.cask { installer.cask_dep_names(entry.name, cask_names) }
			else { []string{} }
		}
	}

	mut implicit_pioneer := ''
	if installer.config.implicit_dependency_names.len > 0 {
		for entry in entries {
			if entry.package_kind == .brew {
				implicit_pioneer = entry.name
				break
			}
		}
	}

	mut result := map[string][]string{}
	for entry in entries {
		mut depends_on := []string{}
		for dependency in direct_dependencies[entry.name] or { []string{} } {
			name := entry_name_map[dependency] or {
				entry_name_map[parallel_installer_normalize_formula_name(dependency)] or { '' }
			}
			if name != '' && name != entry.name && name !in depends_on {
				depends_on << name
			}
		}
		entry_recursive := recursive_dependencies[entry.name] or { []string{} }
		for earlier in entries {
			if earlier.name == entry.name {
				break
			}
			if earlier.name in depends_on {
				continue
			}
			earlier_recursive := recursive_dependencies[earlier.name] or { []string{} }
			if parallel_installer_intersects(entry_recursive, earlier_recursive) {
				depends_on << earlier.name
			}
		}
		if implicit_pioneer != '' && entry.name != implicit_pioneer
			&& entry.package_kind == .brew && implicit_pioneer !in depends_on {
			depends_on << implicit_pioneer
		}
		result[entry.name] = depends_on
	}
	return result
}

pub fn (mut installer ParallelInstaller) write_output(message string, tty bool,
	standard_error bool) {
	line := if tty { '${message}\r\n' } else { '${message}\n' }
	if standard_error {
		installer.errors << line
	} else {
		installer.output << line
	}
}

pub fn (mut installer ParallelInstaller) prepare_attestation_verification(entries []InstallableEntry) {
	if !installer.config.verify_attestations {
		return
	}
	mut has_installable := false
	for entry in entries {
		if entry.package_kind in [.brew, .cask] {
			has_installable = true
		}
		if entry.package_kind == .brew && entry.name == 'gh' {
			return
		}
	}
	if has_installable {
		// Resolving gh_executable is represented as explicit prepared state; the
		// caller can perform the external lookup before running installations.
		installer.attestation_prepared = true
	}
}

pub fn (mut installer ParallelInstaller) clear_tty_line() {
	sequence := '\x1b[?2026h\r\x1b[K\x1b[?2026l'
	mut terminal := os.open_file(installer.config.tty_path, 'w') or { return }
	defer {
		terminal.close()
	}
	terminal.write_string(sequence) or { return }
	installer.tty_clear_count++
}

pub fn (mut installer ParallelInstaller) do_install_entry(entry InstallableEntry) bool {
	if entry.preinstall {
		installer.write_output('${entry.verb} ${entry.name}', false, false)
	} else if !installer.config.quiet {
		installer.write_output('Using ${entry.name}', false, false)
	}
	installer.installation_order << entry.name
	if entry.install {
		return true
	}
	installer.write_output('${entry.verb} ${entry.name} has failed!', false, true)
	return false
}

pub fn (mut installer ParallelInstaller) install_entry(entry InstallableEntry) bool {
	installed := installer.do_install_entry(entry)
	if entry.package_kind == .cask {
		installer.clear_tty_line()
	}
	return installed
}

pub fn (mut installer ParallelInstaller) install_entries_parallel(entries []InstallableEntry) (int, int) {
	// V's translated package-type operations are deterministic values today;
	// process each scheduled batch in source order while preserving the Ruby
	// success/failure join semantics.
	mut success := 0
	mut failure := 0
	for entry in entries {
		if installer.install_entry(entry) {
			success++
		} else {
			failure++
		}
	}
	return success, failure
}

pub fn (mut installer ParallelInstaller) run() (int, int) {
	mut success := 0
	mut failure := 0
	mut tap_entries := []InstallableEntry{}
	mut pending_entries := []InstallableEntry{}
	for entry in installer.entries {
		if entry.package_kind == .tap {
			tap_entries << entry
		} else {
			pending_entries << entry
		}
	}
	for start := 0; start < tap_entries.len; start += installer.config.jobs {
		end := if start + installer.config.jobs < tap_entries.len {
			start + installer.config.jobs
		} else {
			tap_entries.len
		}
		batch_success, batch_failure := installer.install_entries_parallel(tap_entries[start..end])
		success += batch_success
		failure += batch_failure
		for entry in tap_entries[start..end] {
			if entry.install && entry.name !in installer.installed_taps {
				installer.installed_taps << entry.name
			}
		}
	}
	installer.tap_cache_cleared = tap_entries.len > 0

	for entry in pending_entries {
		if tap_name := entry.tap_name() {
			if tap_name !in installer.installed_taps && !tap_entries.any(it.name == tap_name) {
				installer.installed_taps << tap_name
			}
		}
	}
	installer.prepare_attestation_verification(pending_entries)
	dependency_map := installer.build_dependency_map(pending_entries)
	mut completed := []string{}
	for pending_entries.len > 0 {
		mut ready_entries := []InstallableEntry{}
		for entry in pending_entries {
			dependencies := dependency_map[entry.name] or { []string{} }
			if dependencies.all(it in completed) {
				ready_entries << entry
			}
		}
		if ready_entries.len == 0 {
			for entry in pending_entries {
				if installer.install_entry(entry) {
					success++
				} else {
					failure++
				}
				completed << entry.name
			}
			break
		}
		batch_size := if ready_entries.len < installer.config.jobs {
			ready_entries.len
		} else {
			installer.config.jobs
		}
		batch := ready_entries[..batch_size].clone()
		batch_success, batch_failure := installer.install_entries_parallel(batch)
		success += batch_success
		failure += batch_failure
		batch_names := batch.map(it.name)
		pending_entries = pending_entries.filter(it.name !in batch_names)
		completed << batch_names
	}
	return success, failure
}

fn parallel_installer_entry_value(entry InstallableEntry) ruby.Value {
	return ruby.Value{
		type_name: 'Installer::InstallableEntry'
		repr: entry.name
		map_data: {
			'name':         ruby.string_value(entry.name)
			'full_name':    ruby.string_value(entry.options.full_name)
			'verb':         ruby.string_value(entry.verb)
			'package_kind': ruby.string_value(entry.package_kind.str())
			'fetchable':    ruby.string_value(entry.fetchable_name)
			'preinstall':   ruby.bool_value(entry.preinstall)
			'install':      ruby.bool_value(entry.install)
		}
	}
}

pub fn parallel_installer_entry_boundary(entry InstallableEntry) ruby.Value {
	return parallel_installer_entry_value(entry)
}

fn parallel_installer_entry_from_value(value ruby.Value) InstallableEntry {
	fields := value.map_data.clone()
	kind_name := (fields['package_kind'] or { ruby.string_value('other') }).as_string()
	return InstallableEntry{
		name: (fields['name'] or { ruby.string_value(value.repr) }).as_string()
		options: InstallerEntryOptions{
			full_name: (fields['full_name'] or { ruby.string_value('') }).as_string()
		}
		verb: (fields['verb'] or { ruby.string_value('Installing') }).as_string()
		package_kind: match kind_name {
			'brew' { .brew }
			'cask' { .cask }
			'tap' { .tap }
			else { .other }
		}
		fetchable_name: (fields['fetchable'] or { ruby.string_value('') }).as_string()
		preinstall: (fields['preinstall'] or { ruby.bool_value(true) }).bool_data
		install: (fields['install'] or { ruby.bool_value(true) }).bool_data
	}
}

fn parallel_installer_entries_from_value(value ruby.Value) []InstallableEntry {
	return (value.as_array() or { panic(err) }).map(parallel_installer_entry_from_value(it))
}

fn parallel_installer_value(installer &ParallelInstaller) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::ParallelInstaller', '', {
		'parallel_installer_address': u64(voidptr(installer)).str()
	})
}

pub fn parallel_installer_boundary(installer &ParallelInstaller) ruby.Value {
	return parallel_installer_value(installer)
}

fn parallel_installer_from_args(args []ruby.Value,
	method string) &ParallelInstaller {
	if args.len == 0 || args[0].type_name != 'Homebrew::Bundle::ParallelInstaller' {
		panic('ParallelInstaller#${method} requires a translated receiver')
	}
	address := args[0].attributes['parallel_installer_address'] or {
		panic('ParallelInstaller receiver has no translated state')
	}
	return unsafe { &ParallelInstaller(voidptr(address.u64())) }
}

fn parallel_installer_config_from_value(value ruby.Value) ParallelInstallerConfig {
	fields := value.map_data.clone()
	return ParallelInstallerConfig{
		jobs: int((fields['jobs'] or { ruby.int_value(1) }).int_data)
		no_upgrade: (fields['no_upgrade'] or { ruby.bool_value(false) }).bool_data
		verbose: (fields['verbose'] or { ruby.bool_value(false) }).bool_data
		force: (fields['force'] or { ruby.bool_value(false) }).bool_data
		quiet: (fields['quiet'] or { ruby.bool_value(false) }).bool_data
		verify_attestations: (fields['verify_attestations'] or { ruby.bool_value(false) }).bool_data
		tty_path: (fields['tty_path'] or { ruby.string_value('/dev/tty') }).as_string()
	}
}

fn parallel_installer_counts_value(success int, failure int) ruby.Value {
	return ruby.array_value([
		ruby.int_value(success),
		ruby.int_value(failure),
	])
}

fn parallel_installer_dependency_map_value(dependencies map[string][]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for name, values in dependencies {
		result[name] = ruby.string_array_value(values)
	}
	return ruby.map_value(result)
}
