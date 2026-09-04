module cli

import ruby
import homebrew.api
import os

// Translated from Homebrew/brew `cli/named_args.rb`.
pub struct NamedArgsParent {
pub:
	package_type string
	options_only []string
}

pub struct NamedArgsConfig {
pub:
	parent            NamedArgsParent
	override_spec     string
	force_bottle      bool
	flags             []string
	cask_options      bool
	without_api       bool
	formula_lookup    api.FormulaLookupConfig
	formulae          map[string]api.PackageReference
	casks             map[string]api.PackageReference
	formula_directory string
	tap_paths         map[string]string
	tap_formula_files map[string][]string
	tap_cask_files    map[string][]string
	installed_taps    []string
	kegs              map[string][]NamedKeg
	opt_prefixes      map[string]string
	linked_prefixes   map[string]string
	latest_prefixes   map[string]string
	require_tap_trust bool
	installed_casks   map[string]api.PackageReference
	trusted_casks     []string
	formula_errors    map[string]string
	cask_errors       map[string]string
}

pub struct NamedKeg {
pub:
	name                 string
	path                 string
	version              string
	revision             int
	head                 bool
	source_modified_time i64
	tap                  string
}

pub struct PackageConversionOptions {
pub:
	only               string
	ignore_unavailable bool
	method             string
	unique             bool = true
	warn               bool
}

pub struct PackagePartition {
pub:
	formulae []api.PackageReference
	casks    []api.PackageReference
}

pub struct PackageResolution {
pub:
	package  api.PackageReference
	warnings []string
}

// NamedArgs is the typed V representation of the Ruby NamedArgs array. Formula
// and cask metadata retains the constructor context used by the Ruby class
// without embedding Args recursively.
pub struct NamedArgs {
pub:
	values            []string
	parent            NamedArgsParent
	override_spec     string
	force_bottle      bool
	flags             []string
	cask_options      bool
	without_api       bool
	formula_lookup    api.FormulaLookupConfig
	formulae          map[string]api.PackageReference
	casks             map[string]api.PackageReference
	formula_directory string
	tap_paths         map[string]string
	tap_formula_files map[string][]string
	tap_cask_files    map[string][]string
	installed_taps    []string
	kegs              map[string][]NamedKeg
	opt_prefixes      map[string]string
	linked_prefixes   map[string]string
	latest_prefixes   map[string]string
	require_tap_trust bool
	installed_casks   map[string]api.PackageReference
	trusted_casks     []string
	formula_errors    map[string]string
	cask_errors       map[string]string
}

pub fn new_named_args(values []string) NamedArgs {
	return new_named_args_with_config(values, NamedArgsConfig{
		formula_lookup: api.default_formula_lookup_config()
	})
}

pub fn new_named_args_with_config(values []string, config NamedArgsConfig) NamedArgs {
	lookup := if config.formula_lookup.api_base_url.len == 0 && config.formula_lookup.cache_directory.len == 0 && config.formula_lookup.formula_json_by_name.len == 0 {
		api.FormulaLookupConfig{
			...config.formula_lookup
			api_base_url: api.default_formula_lookup_config().api_base_url
			without_api: config.without_api || config.formula_lookup.without_api
		}
	} else {
		api.FormulaLookupConfig{
			...config.formula_lookup
			without_api: config.without_api || config.formula_lookup.without_api
		}
	}
	return NamedArgs{
		values: values.clone()
		parent: config.parent
		override_spec: config.override_spec
		force_bottle: config.force_bottle
		flags: config.flags.clone()
		cask_options: config.cask_options
		without_api: config.without_api
		formula_lookup: lookup
		formulae: config.formulae.clone()
		casks: config.casks.clone()
		formula_directory: config.formula_directory
		tap_paths: config.tap_paths.clone()
		tap_formula_files: config.tap_formula_files.clone()
		tap_cask_files: config.tap_cask_files.clone()
		installed_taps: config.installed_taps.clone()
		kegs: config.kegs.clone()
		opt_prefixes: config.opt_prefixes.clone()
		linked_prefixes: config.linked_prefixes.clone()
		latest_prefixes: config.latest_prefixes.clone()
		require_tap_trust: config.require_tap_trust
		installed_casks: config.installed_casks.clone()
		trusted_casks: config.trusted_casks.clone()
		formula_errors: config.formula_errors.clone()
		cask_errors: config.cask_errors.clone()
	}
}

pub fn (args NamedArgs) len() int {
	return args.values.len
}

pub fn (args NamedArgs) empty() bool {
	return args.values.len == 0
}

pub fn (args NamedArgs) downcased_unique_named() []string {
	mut seen := map[string]bool{}
	mut normalised := []string{}
	for argument in args.values {
		candidate := if argument.contains('/') || argument.ends_with('.tar.gz') || ruby.path_exists(argument) {
			argument
		} else {
			argument.to_lower()
		}
		if !seen[candidate] {
			seen[candidate] = true
			normalised << candidate
		}
	}
	return normalised
}

pub fn (args NamedArgs) homebrew_tap_cask_names() []string {
	return args.downcased_unique_named().filter(it.starts_with('homebrew/cask/'))
}

fn (args NamedArgs) selected_package_type(only string) string {
	if only.len > 0 {
		return only
	}
	return args.parent.package_type
}

fn package_reference_key(reference api.PackageReference) string {
	return '${reference.kind}|${reference.full_name}|${reference.local_path}'
}

fn unique_package_references(references []api.PackageReference) []api.PackageReference {
	mut seen := map[string]bool{}
	mut unique := []api.PackageReference{}
	for reference in references {
		key := package_reference_key(reference)
		if !seen[key] {
			seen[key] = true
			unique << reference
		}
	}
	return unique
}

fn (args NamedArgs) formula_reference(name string, method string) !api.PackageReference {
	if message := args.formula_errors[name] {
		return error(message)
	}
	if reference := args.formulae[name] {
		return reference
	}
	if method == 'latest_kegs' {
		return args.resolve_latest_keg(name)
	}
	if method == 'default_kegs' {
		return args.resolve_default_keg(name)
	}
	if method == 'kegs' {
		_, kegs := args.resolve_kegs(name)!
		return named_keg_reference(kegs[0])
	}
	if ruby.is_file(name) {
		if name.ends_with('.json') {
			return api.decode_local_formula_metadata(ruby.read_file(name)!, os.abs_path(name))
		}
		return error('FormulaUnreadableError: no Formula loader was provided for `${os.abs_path(name)}`')
	}
	return api.resolve_formula_reference(name, args.formula_lookup)
}

fn named_keg_reference(keg NamedKeg) api.PackageReference {
	return api.PackageReference{
		kind: .keg
		name: keg.name
		full_name: keg.name
		tap: keg.tap
		stable_version: keg.version
		revision: keg.revision
		local_path: keg.path
		tap_installed: true
	}
}

fn named_args_version_compare(left string, right string) int {
	left_parts := left.split('.')
	right_parts := right.split('.')
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index].int() } else { 0 }
		right_part := if index < right_parts.len { right_parts[index].int() } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

fn named_args_requested_tap(name string) (string, string) {
	parts := name.split('/')
	if parts.len >= 3 {
		return '${parts[0]}/${parts[1]}', parts[parts.len - 1]
	}
	return '', name
}

pub fn (args NamedArgs) resolve_kegs(name string) !(string, []NamedKeg) {
	if name.trim_space() == '' {
		return error('UsageError')
	}
	requested_tap, formula_name := named_args_requested_tap(name)
	mut kegs := (args.kegs[formula_name.to_lower()] or { []NamedKeg{} }).clone()
	if requested_tap != '' {
		kegs = kegs.filter(it.tap == requested_tap)
	}
	if kegs.len == 0 {
		return if requested_tap != '' {
			error('NoSuchKegError: ${requested_tap}/${formula_name}')
		} else {
			error('NoSuchKegError: ${name}')
		}
	}
	return formula_name.to_lower(), kegs
}

pub fn (args NamedArgs) resolve_latest_keg(name string) !api.PackageReference {
	_, kegs := args.resolve_kegs(name)!
	if kegs.len == 1 {
		return named_keg_reference(kegs[0])
	}
	stable := kegs.filter(!it.head)
	mut latest := if stable.len > 0 { stable[0] } else { kegs[0] }
	candidates := if stable.len > 0 { stable.clone() } else { kegs.clone() }
	for keg in candidates {
		if stable.len > 0 {
			comparison := named_args_version_compare(keg.version, latest.version)
			if comparison > 0 || (comparison == 0 && keg.revision > latest.revision) {
				latest = keg
			}
		} else if keg.source_modified_time > latest.source_modified_time || (keg.source_modified_time == latest.source_modified_time && keg.revision > latest.revision) {
			latest = keg
		}
	}
	return named_keg_reference(latest)
}

pub fn (args NamedArgs) resolve_default_keg(name string) !api.PackageReference {
	rack, kegs := args.resolve_kegs(name)!
	for path in [args.opt_prefixes[rack] or { '' }, args.linked_prefixes[rack] or { '' }] {
		if path != '' {
			for keg in kegs {
				if keg.path == path {
					return named_keg_reference(keg)
				}
			}
		}
	}
	if kegs.len == 1 {
		return named_keg_reference(kegs[0])
	}
	if prefix := args.latest_prefixes[rack] {
		for keg in kegs {
			if keg.path == prefix {
				return named_keg_reference(keg)
			}
		}
	}
	return error('${rack} has multiple installed versions\nRun `brew uninstall --force ${rack}` to remove all versions.')
}

pub fn (args NamedArgs) to_keg_references(method string) ![]api.PackageReference {
	mut references := []api.PackageReference{}
	for name in args.downcased_unique_named() {
		if method == 'kegs' {
			_, kegs := args.resolve_kegs(name)!
			references << kegs.map(named_keg_reference(it))
		} else if method == 'latest_kegs' {
			references << args.resolve_latest_keg(name)!
		} else {
			references << args.resolve_default_keg(name)!
		}
	}
	return unique_package_references(references)
}

pub fn (args NamedArgs) to_kegs_to_casks(only string, ignore_unavailable bool,
	all_kegs bool) !PackagePartition {
	mut formulae := []api.PackageReference{}
	mut casks := []api.PackageReference{}
	for name in args.downcased_unique_named() {
		mut found_formula := false
		if only != 'cask' {
			if all_kegs {
				keg_references := args.keg_references_for_name(name) or {
					if !ignore_unavailable && only == 'formula' {
						return err
					}
					[]api.PackageReference{}
				}
				if keg_references.len > 0 {
					formulae << keg_references
					found_formula = true
				}
			} else {
				keg := args.resolve_default_keg(name) or {
					if !ignore_unavailable && only == 'formula' {
						return err
					}
					api.PackageReference{}
				}
				if keg.name != '' {
					formulae << keg
					found_formula = true
				}
			}
		}
		if found_formula {
			continue
		}
		if only != 'formula' {
			if cask := args.cask_reference(name) {
				casks << cask
			} else if !ignore_unavailable && only == 'cask' {
				return error('CaskUnavailableError: ${name}')
			}
		}
	}
	return PackagePartition{
		formulae: unique_package_references(formulae)
		casks: unique_package_references(casks)
	}
}

fn (args NamedArgs) keg_references_for_name(name string) ![]api.PackageReference {
	_, kegs := args.resolve_kegs(name)!
	return kegs.map(named_keg_reference(it))
}

pub fn (args NamedArgs) load_untrusted_installed_cask(name string) ?api.PackageReference {
	if !args.require_tap_trust {
		return none
	}
	requested_tap, raw_token := named_args_requested_tap(name)
	token := raw_token.split('/').last()
	installed := args.installed_casks[token] or { return none }
	if installed.local_path == '' || installed.tap == '' {
		return none
	}
	if requested_tap != '' && requested_tap != installed.tap {
		return none
	}
	if '${installed.tap}/${token}' in args.trusted_casks {
		return none
	}
	return installed
}

fn (args NamedArgs) cask_reference(name string) ?api.PackageReference {
	if reference := args.casks[name] {
		return reference
	}
	return none
}

pub fn package_conflicts_message(ref string, loaded_type string,
	package api.PackageReference) string {
	mut message := 'Treating ${ref} as a ${loaded_type}.'
	if package.kind in [.formula, .keg] {
		message += ' For the formula, '
		if package.tap.len > 0 {
			message += 'use ${package.tap}/${package.name} or '
		}
		message += 'specify the `--formula` flag. To silence this message, use the `--cask` flag.'
	} else if package.kind == .cask {
		message += ' For the cask, '
		if package.tap.len > 0 {
			message += 'use ${package.tap}/${package.name} or '
		}
		message += 'specify the `--cask` flag. To silence this message, use the `--formula` flag.'
	}
	return message
}

// resolve_formula_or_cask translates the source's formula-first rules. Core
// formulae win immediately; a core cask wins over a non-core formula; otherwise
// formulae take precedence and a source-derived conflict warning is retained.
pub fn (args NamedArgs) resolve_formula_or_cask(name string, only string, method string,
	warn bool) !PackageResolution {
	package_type := args.selected_package_type(only)
	mut formula_error := ''
	mut formula := api.PackageReference{}
	mut has_formula := false
	if package_type != 'cask' {
		formula = args.formula_reference(name, method) or {
			formula_error = err.msg()
			api.PackageReference{}
		}
		has_formula = formula.name.len > 0 && (formula.kind == .formula || formula.kind == .keg)
	}
	if package_type == 'formula' {
		if has_formula {
			return PackageResolution{
				package: formula
			}
		}
		message := if formula_error.len > 0 {
			formula_error
		} else {
			'FormulaUnavailableError: ${name}'
		}
		return error(message)
	}
	cask := args.cask_reference(name)
	cask_error := args.cask_errors[name] or { '' }
	if has_formula && formula.core_tap {
		mut warnings := []string{}
		if warn {
			if cask_reference := cask {
				warnings << package_conflicts_message(name, 'formula', cask_reference)
			} else if cask_error != '' {
				warnings << 'Failed to load cask: ${name}\n${cask_error}'
			}
		}
		return PackageResolution{
			package: formula
			warnings: warnings
		}
	}
	if package_type == 'cask' {
		if cask_reference := cask {
			return PackageResolution{
				package: cask_reference
			}
		}
		message := if cask_error != '' { cask_error } else { 'CaskUnavailableError: ${name}' }
		return error(message)
	}
	if has_formula {
		if cask_reference := cask {
			if cask_reference.core_cask_tap {
				return PackageResolution{
					package: cask_reference
					warnings: if warn {
						[package_conflicts_message(name, 'cask', formula)]
					} else {
						[]string{}
					}
				}
			}
			return PackageResolution{
				package: formula
				warnings: if warn {
					[package_conflicts_message(name, 'formula', cask_reference)]
				} else {
					[]string{}
				}
			}
		}
		return PackageResolution{
			package: formula
			warnings: if warn && cask_error != '' {
				['Failed to load cask: ${name}\n${cask_error}']
			} else {
				[]string{}
			}
		}
	}
	if cask_reference := cask {
		return PackageResolution{
			package: cask_reference
			warnings: if warn && formula_error != '' {
				['Failed to load formula: ${name}\n${formula_error}']
			} else {
				[]string{}
			}
		}
	}
	if formula_error.contains('Unreadable') {
		return error(formula_error)
	}
	if cask_error.contains('Unreadable') {
		return error(cask_error)
	}
	if formula_error.starts_with('FormulaUnreadableError:') {
		return error(formula_error)
	}
	return error('FormulaOrCaskUnavailableError: ${name}')
}

pub fn (args NamedArgs) resolve_formulae_and_casks(options PackageConversionOptions) ![]api.PackageReference {
	mut packages := []api.PackageReference{}
	for name in args.downcased_unique_named() {
		resolved := args.resolve_formula_or_cask(name, options.only, options.method, options.warn) or {
			if options.ignore_unavailable {
				continue
			}
			return err
		}
		packages << resolved.package
	}
	if options.unique {
		return unique_package_references(packages)
	}
	return packages
}

pub fn (args NamedArgs) to_formulae_and_casks() ![]api.PackageReference {
	return args.resolve_formulae_and_casks(PackageConversionOptions{
		unique: true
	})
}

pub fn (args NamedArgs) to_formulae() ![]api.PackageReference {
	return args.resolve_formulae_and_casks(PackageConversionOptions{
		only: 'formula'
		unique: true
	})
}

pub fn (args NamedArgs) to_casks() ![]api.PackageReference {
	return args.resolve_formulae_and_casks(PackageConversionOptions{
		only: 'cask'
		unique: true
	})
}

pub fn (args NamedArgs) to_formulae_to_casks(options PackageConversionOptions) !PackagePartition {
	references := args.resolve_formulae_and_casks(options)!
	return PackagePartition{
		formulae: references.filter(it.kind in [.formula, .keg])
		casks: references.filter(it.kind == .cask)
	}
}

pub fn (args NamedArgs) to_formulae_and_casks_with_taps() ![]api.PackageReference {
	references := args.to_formulae_and_casks()!
	missing := references.filter(!it.tap_installed)
	if missing.len == 0 {
		return references
	}
	mut types := []string{}
	if missing.any(it.kind == .formula) {
		types << 'formulae'
	}
	if missing.any(it.kind == .cask) {
		types << 'casks'
	}
	names := missing.map(it.full_name).sorted()
	return error('These ${types.join(' and ')} are not in any locally installed taps!\n\n  ${names.join('\n  ')}\n\nYou may need to run `brew tap` to install additional taps.')
}

pub fn (args NamedArgs) to_formulae_and_casks_and_unavailable(options PackageConversionOptions) []api.PackageReference {
	mut references := []api.PackageReference{}
	for name in args.downcased_unique_named() {
		resolved := args.resolve_formula_or_cask(name, options.only, options.method, options.warn) or {
			references << api.PackageReference{
				kind: .unavailable
				name: name
				full_name: name
				error_message: err.msg()
			}
			continue
		}
		references << resolved.package
	}
	if options.unique {
		return unique_package_references(references)
	}
	return references
}

pub fn (args NamedArgs) to_resolved_formulae(unique bool) ![]api.PackageReference {
	return args.resolve_formulae_and_casks(PackageConversionOptions{
		only: 'formula'
		method: 'resolve'
		unique: unique
	})
}

pub fn (args NamedArgs) to_resolved_formulae_to_casks(only string) !PackagePartition {
	return args.to_formulae_to_casks(PackageConversionOptions{
		only: only
		method: 'resolve'
		unique: true
	})
}

fn core_formula_metadata_path(name string, formula_directory string) string {
	subdirectory := if name.starts_with('lib') { 'lib' } else { name[..1] }
	return os.join_path(formula_directory, subdirectory, '${name.to_lower()}.rb')
}

fn unique_strings(values []string) []string {
	mut seen := map[string]bool{}
	mut unique := []string{}
	for value in values {
		if !seen[value] {
			seen[value] = true
			unique << value
		}
	}
	return unique
}

pub fn (args NamedArgs) to_paths(only string, recurse_tap bool) ![]string {
	package_type := args.selected_package_type(only)
	mut paths := []string{}
	for name in args.downcased_unique_named() {
		path := os.abs_path(name)
		if package_type.len == 0 && (name.starts_with('/') || name.contains('.') || name.ends_with('/')) && os.exists(path) {
			paths << path
			continue
		}
		segments := name.split('/')
		if segments.len == 2 && segments.all(!it.contains('.')) {
			tap_path := args.tap_paths[name] or { return error('TapUnavailableError: ${name}') }
			if recurse_tap && package_type == 'formula' {
				paths << args.tap_formula_files[name] or { []string{} }
				continue
			}
			if recurse_tap && package_type == 'cask' {
				paths << args.tap_cask_files[name] or { []string{} }
				continue
			}
			paths << tap_path
			continue
		}
		if package_type == 'formula' {
			formula := args.formula_reference(name, '') or { api.PackageReference{} }
			paths << if formula.local_path != '' {
				formula.local_path
			} else {
				core_formula_metadata_path(name, args.formula_directory)
			}
			continue
		}
		if package_type == 'cask' {
			if cask := args.cask_reference(name) {
				paths << cask.local_path
			} else {
				paths << path
			}
			continue
		}
		mut matched := false
		if formula := args.formula_reference(name, '') {
			paths << if formula.local_path != '' {
				formula.local_path
			} else {
				core_formula_metadata_path(name, args.formula_directory)
			}
			matched = true
		}
		if cask := args.cask_reference(name) {
			paths << cask.local_path
			matched = true
		}
		if !matched {
			paths << path
		}
	}
	return unique_strings(paths)
}

pub fn (args NamedArgs) to_taps() ![]string {
	mut taps := []string{}
	for name in args.downcased_unique_named() {
		segments := name.split('/')
		if segments.len != 2 || segments.any(it.len == 0 || it.contains('.')) {
			return error('Invalid tap name: ${name}')
		}
		taps << name
	}
	return unique_strings(taps)
}

pub fn (args NamedArgs) to_installed_taps() ![]string {
	taps := args.to_taps()!
	for tap in taps {
		if tap !in args.installed_taps {
			return error('TapUnavailableError: ${tap}')
		}
	}
	return taps
}
