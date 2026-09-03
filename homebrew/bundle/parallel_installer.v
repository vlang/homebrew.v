module bundle

import brew_runtime
import os

// Translated from Homebrew/brew `bundle/parallel_installer.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn parallel_installer_entry_value(entry InstallableEntry) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Installer::InstallableEntry'
		repr: entry.name
		map_data: {
			'name':         brew_runtime.string_value(entry.name)
			'full_name':    brew_runtime.string_value(entry.options.full_name)
			'verb':         brew_runtime.string_value(entry.verb)
			'package_kind': brew_runtime.string_value(entry.package_kind.str())
			'fetchable':    brew_runtime.string_value(entry.fetchable_name)
			'preinstall':   brew_runtime.bool_value(entry.preinstall)
			'install':      brew_runtime.bool_value(entry.install)
		}
	}
}

pub fn parallel_installer_entry_boundary(entry InstallableEntry) brew_runtime.Value {
	return parallel_installer_entry_value(entry)
}

fn parallel_installer_entry_from_value(value brew_runtime.Value) InstallableEntry {
	fields := value.map_data.clone()
	kind_name := (fields['package_kind'] or { brew_runtime.string_value('other') }).as_string()
	return InstallableEntry{
		name: (fields['name'] or { brew_runtime.string_value(value.repr) }).as_string()
		options: InstallerEntryOptions{
			full_name: (fields['full_name'] or { brew_runtime.string_value('') }).as_string()
		}
		verb: (fields['verb'] or { brew_runtime.string_value('Installing') }).as_string()
		package_kind: match kind_name {
			'brew' { .brew }
			'cask' { .cask }
			'tap' { .tap }
			else { .other }
		}
		fetchable_name: (fields['fetchable'] or { brew_runtime.string_value('') }).as_string()
		preinstall: (fields['preinstall'] or { brew_runtime.bool_value(true) }).bool_data
		install: (fields['install'] or { brew_runtime.bool_value(true) }).bool_data
	}
}

fn parallel_installer_entries_from_value(value brew_runtime.Value) []InstallableEntry {
	return (value.as_array() or { panic(err) }).map(parallel_installer_entry_from_value(it))
}

fn parallel_installer_value(installer &ParallelInstaller) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Bundle::ParallelInstaller', '', {
		'parallel_installer_address': u64(voidptr(installer)).str()
	})
}

pub fn parallel_installer_boundary(installer &ParallelInstaller) brew_runtime.Value {
	return parallel_installer_value(installer)
}

fn parallel_installer_from_args(args []brew_runtime.Value,
	method string) &ParallelInstaller {
	if args.len == 0 || args[0].type_name != 'Homebrew::Bundle::ParallelInstaller' {
		panic('ParallelInstaller#${method} requires a translated receiver')
	}
	address := args[0].attributes['parallel_installer_address'] or {
		panic('ParallelInstaller receiver has no translated state')
	}
	return unsafe { &ParallelInstaller(voidptr(address.u64())) }
}

fn parallel_installer_config_from_value(value brew_runtime.Value) ParallelInstallerConfig {
	fields := value.map_data.clone()
	return ParallelInstallerConfig{
		jobs: int((fields['jobs'] or { brew_runtime.int_value(1) }).int_data)
		no_upgrade: (fields['no_upgrade'] or { brew_runtime.bool_value(false) }).bool_data
		verbose: (fields['verbose'] or { brew_runtime.bool_value(false) }).bool_data
		force: (fields['force'] or { brew_runtime.bool_value(false) }).bool_data
		quiet: (fields['quiet'] or { brew_runtime.bool_value(false) }).bool_data
		verify_attestations: (fields['verify_attestations'] or { brew_runtime.bool_value(false) }).bool_data
		tty_path: (fields['tty_path'] or { brew_runtime.string_value('/dev/tty') }).as_string()
	}
}

fn parallel_installer_counts_value(success int, failure int) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.int_value(success),
		brew_runtime.int_value(failure),
	])
}

fn parallel_installer_dependency_map_value(dependencies map[string][]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for name, values in dependencies {
		result[name] = brew_runtime.string_array_value(values)
	}
	return brew_runtime.map_value(result)
}

// Ruby method `initialize(entries, jobs:, no_upgrade:, verbose:, force:, quiet:)` at line 25.
pub fn ruby_parallel_installer_l25_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('ParallelInstaller#initialize requires entries')
	}
	config := if args.len > 1 {
		parallel_installer_config_from_value(args[1])
	} else {
		ParallelInstallerConfig{}
	}
	return parallel_installer_value(new_parallel_installer(parallel_installer_entries_from_value(args[0]), config))
}

// Ruby method `run!` at line 41.
pub fn ruby_parallel_installer_l41_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'run!')
	success, failure := installer.run()
	return parallel_installer_counts_value(success, failure)
}

// Ruby method `build_dependency_map(entries)` at line 107.
pub fn ruby_parallel_installer_l107_d3_build_dependency_map(args ...brew_runtime.Value) brew_runtime.Value {
	installer := parallel_installer_from_args(args, 'build_dependency_map')
	entries := if args.len > 1 {
		parallel_installer_entries_from_value(args[1])
	} else {
		installer.entries.clone()
	}
	return parallel_installer_dependency_map_value(installer.build_dependency_map(entries))
}

// Ruby method `write_output(message, stream: $stdout)` at line 191.
pub fn ruby_parallel_installer_l191_d4_write_output(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'write_output')
	if args.len < 2 {
		panic('ParallelInstaller#write_output requires a message')
	}
	stream := if args.len > 2 { args[2].map_data } else { map[string]brew_runtime.Value{} }
	installer.write_output(args[1].as_string(), (stream['tty'] or { brew_runtime.bool_value(false) }).bool_data, (stream['stderr'] or { brew_runtime.bool_value(false) }).bool_data)
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `normalize_formula_name(name)` at line 206.
pub fn ruby_parallel_installer_l206_d5_normalize_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('normalize_formula_name requires a name')
	}
	return brew_runtime.string_value(parallel_installer_normalize_formula_name(args[args.len - 1].as_string()))
}

// Ruby method `prepare_attestation_verification!(entries)` at line 211.
pub fn ruby_parallel_installer_l211_d6_prepare_attestation_verification(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'prepare_attestation_verification!')
	entries := if args.len > 1 {
		parallel_installer_entries_from_value(args[1])
	} else {
		installer.entries.clone()
	}
	installer.prepare_attestation_verification(entries)
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `cask_dep_names(name, cask_names)` at line 224.
pub fn ruby_parallel_installer_l224_d7_cask_dep_names(args ...brew_runtime.Value) brew_runtime.Value {
	installer := parallel_installer_from_args(args, 'cask_dep_names')
	if args.len < 3 {
		panic('ParallelInstaller#cask_dep_names requires name and cask names')
	}
	return brew_runtime.string_array_value(installer.cask_dep_names(args[1].as_string(), args[2].as_string_array() or { panic(err) }))
}

// Ruby method `install_entries_parallel!(entries)` at line 237.
pub fn ruby_parallel_installer_l237_d8_install_entries_parallel(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'install_entries_parallel!')
	entries := if args.len > 1 {
		parallel_installer_entries_from_value(args[1])
	} else {
		installer.entries.clone()
	}
	success, failure := installer.install_entries_parallel(entries)
	return parallel_installer_counts_value(success, failure)
}

// Ruby method `install_entry!(entry)` at line 266.
pub fn ruby_parallel_installer_l266_d9_install_entry(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'install_entry!')
	if args.len < 2 {
		panic('ParallelInstaller#install_entry! requires an entry')
	}
	return brew_runtime.bool_value(installer.install_entry(parallel_installer_entry_from_value(args[1])))
}

// Ruby method `do_install_entry!(entry)` at line 291.
pub fn ruby_parallel_installer_l291_d10_do_install_entry(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'do_install_entry!')
	if args.len < 2 {
		panic('ParallelInstaller#do_install_entry! requires an entry')
	}
	return brew_runtime.bool_value(installer.do_install_entry(parallel_installer_entry_from_value(args[1])))
}

// Ruby method `clear_tty_line` at line 315.
pub fn ruby_parallel_installer_l315_d11_clear_tty_line(args ...brew_runtime.Value) brew_runtime.Value {
	mut installer := parallel_installer_from_args(args, 'clear_tty_line')
	installer.clear_tty_line()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "concurrent/executors"
// 5: require "concurrent/promises"
// 6: require "monitor"
// 7: require "utils"
// 8: require "utils/tty"
// 9: require "bundle/package_types"
// 10: require "dependency_collector"
// 11:
// 12: module Homebrew
// 13:   module Bundle
// 14:     class ParallelInstaller
// 15:       sig {
// 16:         params(
// 17:           entries:    T::Array[Installer::InstallableEntry],
// 18:           jobs:       Integer,
// 19:           no_upgrade: T::Boolean,
// 20:           verbose:    T::Boolean,
// 21:           force:      T::Boolean,
// 22:           quiet:      T::Boolean,
// 23:         ).void
// 24:       }
// 25:       def initialize(entries, jobs:, no_upgrade:, verbose:, force:, quiet:)
// 26:         @entries = entries
// 27:         @jobs = jobs
// 28:         @no_upgrade = no_upgrade
// 29:         @verbose = verbose
// 30:         @force = force
// 31:         @quiet = quiet
// 32:         @pool = T.let(Concurrent::FixedThreadPool.new(jobs), Concurrent::FixedThreadPool)
// 33:         @output_mutex = T.let(Monitor.new, Monitor)
// 34:         # Cask installs may trigger interactive sudo prompts that write
// 35:         # directly to the terminal.  Serialize them so Password: prompts
// 36:         # don't interleave with status output from other workers.
// 37:         @cask_install_mutex = T.let(Mutex.new, Mutex)
// 38:       end
// 39:
// 40:       sig { returns([Integer, Integer]) }
// 41:       def run!
// 42:         success = 0
// 43:         failure = 0
// 44:
// 45:         tap_entries, pending_entries = @entries.partition { |entry| entry.cls == Homebrew::Bundle::Tap }
// 46:         tap_entries.each_slice(@jobs) do |batch|
// 47:           tap_success, tap_failure = install_entries_parallel!(batch)
// 48:           success += tap_success
// 49:           failure += tap_failure
// 50:         end
// 51:         ::Tap.clear_cache if tap_entries.present?
// 52:
// 53:         require "tap"
// 54:         installed_taps = Homebrew::Bundle::Tap.installed_taps
// 55:         pending_entries.each do |entry|
// 56:           tap_with_name = if entry.cls == Homebrew::Bundle::Brew
// 57:             ::Tap.with_formula_name(entry.full_name)
// 58:           elsif entry.cls == Homebrew::Bundle::Cask
// 59:             ::Tap.with_cask_token(entry.full_name)
// 60:           end
// 61:           next unless tap_with_name
// 62:
// 63:           tap = tap_with_name.first
// 64:           next if installed_taps.include?(tap.name) || tap_entries.any? { |tap_entry| tap_entry.name == tap.name }
// 65:
// 66:           tap.ensure_installed!
// 67:           installed_taps << tap.name
// 68:         end
// 69:
// 70:         prepare_attestation_verification!(pending_entries)
// 71:         dependency_map = build_dependency_map(pending_entries)
// 72:         completed = T.let(Set.new, T::Set[String])
// 73:         until pending_entries.empty?
// 74:           ready_entries = pending_entries.select do |entry|
// 75:             dependency_map.fetch(entry.name, Set.new).all? { |dependency| completed.include?(dependency) }
// 76:           end
// 77:
// 78:           if ready_entries.empty?
// 79:             pending_entries.each do |entry|
// 80:               installed = install_entry!(entry)
// 81:               completed << entry.name
// 82:               if installed
// 83:                 success += 1
// 84:               else
// 85:                 failure += 1
// 86:               end
// 87:             end
// 88:             break
// 89:           end
// 90:
// 91:           batch = ready_entries.take(@jobs)
// 92:           batch_success, batch_failure = install_entries_parallel!(batch)
// 93:           success += batch_success
// 94:           failure += batch_failure
// 95:
// 96:           pending_entries -= batch
// 97:           completed.merge(batch.map(&:name))
// 98:         end
// 99:
// 100:         [success, failure]
// 101:       ensure
// 102:         @pool.shutdown
// 103:         @pool.wait_for_termination
// 104:       end
// 105:
// 106:       sig { params(entries: T::Array[Installer::InstallableEntry]).returns(T::Hash[String, T::Set[String]]) }
// 107:       def build_dependency_map(entries)
// 108:         installed_taps = Homebrew::Bundle::Tap.installed_taps
// 109:         attestation_formula = if Homebrew::EnvConfig.verify_attestations?
// 110:           entries.find { |entry| entry.cls == Homebrew::Bundle::Brew && entry.name == "gh" }
// 111:         end
// 112:
// 113:         # Phase 1: Map both full and short names so dep lookups work either way.
// 114:         entry_name_map = entries.each_with_object({}) do |entry, map|
// 115:           map[entry.name] = entry.name
// 116:           map[normalize_formula_name(entry.name)] = entry.name
// 117:         end
// 118:
// 119:         # Phase 2: Direct dependencies declared in the Brewfile. Determines
// 120:         # install ordering (entry A must finish before entry B starts).
// 121:         brewfile_deps = T.let({}, T::Hash[String, T::Array[String]])
// 122:         entries.each do |entry|
// 123:           deps = case entry.cls.name
// 124:           when "Homebrew::Bundle::Brew"
// 125:             Homebrew::Bundle::Brew.formula_dep_names(entry.name)
// 126:           when "Homebrew::Bundle::Cask"
// 127:             Homebrew::Bundle::Cask.formula_dependencies([entry.full_name])
// 128:           else
// 129:             []
// 130:           end
// 131:
// 132:           # Entries from non-default taps depend on the tap being installed first.
// 133:           deps += Homebrew::Bundle::Installer.tap_dependencies(entry, entries:, installed_taps:)
// 134:           if attestation_formula && [Homebrew::Bundle::Brew, Homebrew::Bundle::Cask].include?(entry.cls) &&
// 135:              entry.name != attestation_formula.name
// 136:             deps << attestation_formula.name
// 137:           end
// 138:
// 139:           brewfile_deps[entry.name] = deps
// 140:         end
// 141:
// 142:         # Phase 3: Recursive dependency sets for lock conflict detection.
// 143:         # `FormulaInstaller#lock` locks all recursive dependencies before
// 144:         # installing, even when pouring bottles.
// 145:         cask_names = T.let(entries.select { |e| e.cls == Homebrew::Bundle::Cask }.to_set(&:name), T::Set[String])
// 146:         recursive_deps = T.let({}, T::Hash[String, T::Set[String]])
// 147:         entries.each do |entry|
// 148:           recursive_deps[entry.name] = case entry.cls.name
// 149:           when "Homebrew::Bundle::Brew"
// 150:             Homebrew::Bundle::Brew.recursive_dep_names(entry.name)
// 151:           when "Homebrew::Bundle::Cask"
// 152:             cask_dep_names(entry.name, cask_names)
// 153:           else
// 154:             Set.new
// 155:           end
// 156:         end
// 157:
// 158:         # Phase 3.5: formulae racing for an undeclared implicit dependency (e.g. a
// 159:         # Linux sandbox executable) wait on just the first one, not on each other.
// 160:         implicit_pioneer = T.let(nil, T.nilable(String))
// 161:         unless DependencyCollector.new.implicit_dependency_names.empty?
// 162:           implicit_pioneer = entries.find { |entry| entry.cls == Homebrew::Bundle::Brew }&.name
// 163:         end
// 164:
// 165:         # Phase 4: Merge explicit ordering and implicit lock conflicts.
// 166:         entries.each_with_object({}) do |entry, map|
// 167:           depends_on = brewfile_deps.fetch(entry.name).each_with_object(Set.new) do |dep, set|
// 168:             name = entry_name_map[dep] || entry_name_map[normalize_formula_name(dep)]
// 169:             set << name if name.present? && name != entry.name
// 170:           end
// 171:
// 172:           # Later entries wait for earlier ones when they share any recursive dep.
// 173:           entry_rdeps = recursive_deps.fetch(entry.name)
// 174:           entries.each do |earlier|
// 175:             break if earlier.name == entry.name
// 176:             next if depends_on.include?(earlier.name)
// 177:
// 178:             earlier_rdeps = recursive_deps.fetch(earlier.name)
// 179:             depends_on << earlier.name if entry_rdeps.intersect?(earlier_rdeps)
// 180:           end
// 181:
// 182:           if implicit_pioneer && entry.name != implicit_pioneer && entry.cls == Homebrew::Bundle::Brew
// 183:             depends_on << implicit_pioneer
// 184:           end
// 185:
// 186:           map[entry.name] = depends_on
// 187:         end
// 188:       end
// 189:
// 190:       sig { params(message: String, stream: IO).void }
// 191:       def write_output(message, stream: $stdout)
// 192:         @output_mutex.synchronize do
// 193:           # Interactive installers can leave ONLCR disabled, so use CRLF to
// 194:           # ensure terminal status output returns to column 0.
// 195:           if stream.tty?
// 196:             stream.write(message, "\r\n")
// 197:           else
// 198:             stream.puts(message)
// 199:           end
// 200:         end
// 201:       end
// 202:
// 203:       private
// 204:
// 205:       sig { params(name: String).returns(String) }
// 206:       def normalize_formula_name(name)
// 207:         Utils.name_from_full_name(name)
// 208:       end
// 209:
// 210:       sig { params(entries: T::Array[Installer::InstallableEntry]).void }
// 211:       def prepare_attestation_verification!(entries)
// 212:         return unless Homebrew::EnvConfig.verify_attestations?
// 213:         return unless entries.any? { |entry| [Homebrew::Bundle::Brew, Homebrew::Bundle::Cask].include?(entry.cls) }
// 214:         return if entries.any? { |entry| entry.cls == Homebrew::Bundle::Brew && entry.name == "gh" }
// 215:
// 216:         require "attestation"
// 217:
// 218:         Homebrew::Attestation.gh_executable
// 219:       end
// 220:
// 221:       # Walk cask-on-cask dependencies transitively, returning the set of
// 222:       # cask names (from the Brewfile) that this cask depends on.
// 223:       sig { params(name: String, cask_names: T::Set[String]).returns(T::Set[String]) }
// 224:       def cask_dep_names(name, cask_names)
// 225:         return Set.new unless Bundle.cask_installed?
// 226:
// 227:         require "cask/cask_loader"
// 228:         cask = ::Cask::CaskLoader.load(name)
// 229:         direct = Array(cask.depends_on[:cask]).to_set
// 230:         # Only include deps that are also in the Brewfile.
// 231:         direct & cask_names
// 232:       rescue ::Cask::CaskUnavailableError
// 233:         Set.new
// 234:       end
// 235:
// 236:       sig { params(entries: T::Array[Installer::InstallableEntry]).returns([Integer, Integer]) }
// 237:       def install_entries_parallel!(entries)
// 238:         futures = entries.to_h do |entry|
// 239:           [entry, Concurrent::Promises.future_on(@pool, entry) do |install_entry|
// 240:             install_entry!(install_entry)
// 241:           end]
// 242:         end
// 243:
// 244:         success = 0
// 245:         failure = 0
// 246:         entries.each do |entry|
// 247:           installed = begin
// 248:             futures.fetch(entry).value! == true
// 249:           rescue => e
// 250:             write_output(Formatter.error("Installing #{entry.name} has failed!"), stream: $stderr)
// 251:             write_output("[#{entry.name}] #{e.message}", stream: $stderr) if @verbose
// 252:             false
// 253:           end
// 254:
// 255:           if installed
// 256:             success += 1
// 257:           else
// 258:             failure += 1
// 259:           end
// 260:         end
// 261:
// 262:         [success, failure]
// 263:       end
// 264:
// 265:       sig { params(entry: Installer::InstallableEntry).returns(T::Boolean) }
// 266:       def install_entry!(entry)
// 267:         # Cask installs can trigger sudo password prompts that write directly
// 268:         # to /dev/tty.  Hold the output lock for the entire install so that
// 269:         # status messages from parallel formula workers don't interleave with
// 270:         # the Password: prompt.  Monitor is reentrant, so write_output calls
// 271:         # inside do_install_entry! can re-acquire the lock on the same thread.
// 272:         if entry.cls == Homebrew::Bundle::Cask
// 273:           @cask_install_mutex.synchronize do
// 274:             result = @output_mutex.synchronize { do_install_entry!(entry) }
// 275:             # Interactive prompts (sudo, macOS security frameworks) can leave
// 276:             # the terminal cursor mid-line on /dev/tty with no trailing
// 277:             # newline.  Clear any trailing prompt text with \r + CSI-K so the
// 278:             # next worker's status message overwrites it rather than appending
// 279:             # to produce "Password:Using foo".  Writes nothing visible when
// 280:             # the line is already clean, so formula and cask output stay
// 281:             # visually uniform.
// 282:             clear_tty_line
// 283:             result
// 284:           end
// 285:         else
// 286:           do_install_entry!(entry)
// 287:         end
// 288:       end
// 289:
// 290:       sig { params(entry: Installer::InstallableEntry).returns(T::Boolean) }
// 291:       def do_install_entry!(entry)
// 292:         name = entry.name
// 293:         options = entry.options
// 294:         verb = entry.verb
// 295:         cls = entry.cls
// 296:
// 297:         preinstall = if cls.preinstall!(name, **options, no_upgrade: @no_upgrade, verbose: @verbose)
// 298:           write_output(Formatter.success("#{verb} #{name}"))
// 299:           true
// 300:         else
// 301:           write_output("Using #{name}") unless @quiet
// 302:           false
// 303:         end
// 304:
// 305:         if cls.install!(name, **options,
// 306:                         preinstall:, no_upgrade: @no_upgrade, verbose: @verbose, force: @force)
// 307:           true
// 308:         else
// 309:           write_output(Formatter.error("#{verb} #{name} has failed!"), stream: $stderr)
// 310:           false
// 311:         end
// 312:       end
// 313:
// 314:       sig { void }
// 315:       def clear_tty_line
// 316:         File.open("/dev/tty", "w") do |f|
// 317:           f.print("#{Tty.begin_synchronized_update}\r\e[K#{Tty.end_synchronized_update}")
// 318:         end
// 319:       rescue Errno::ENXIO, Errno::ENOENT, Errno::EACCES, Errno::EPERM
// 320:         # No TTY available (CI, piped output) - nothing to clean up.
// 321:         nil
// 322:       end
// 323:     end
// 324:   end
// 325: end
