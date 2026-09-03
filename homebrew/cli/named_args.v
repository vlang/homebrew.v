module cli

import brew_runtime
import homebrew.api
import os

// Translated from Homebrew/brew `cli/named_args.rb`.
// The original source is retained below until every stub has a typed V body.
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
		candidate := if argument.contains('/') || argument.ends_with('.tar.gz') || brew_runtime.path_exists(argument) {
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
	if brew_runtime.is_file(name) {
		if name.ends_with('.json') {
			return api.decode_local_formula_metadata(brew_runtime.read_file(name)!, os.abs_path(name))
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
						[package_conflicts_message(name, 'cask', formula)]} else {
						[]string{}}
				}
			}
			return PackageResolution{
				package: formula
				warnings: if warn {
					[package_conflicts_message(name, 'formula', cask_reference)]} else {
					[]string{}}
			}
		}
		return PackageResolution{
			package: formula
			warnings: if warn && cask_error != '' {
				['Failed to load cask: ${name}\n${cask_error}']} else {
				[]string{}}
		}
	}
	if cask_reference := cask {
		return PackageResolution{
			package: cask_reference
			warnings: if warn && formula_error != '' {
				['Failed to load formula: ${name}\n${formula_error}']} else {
				[]string{}}
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

// Ruby attr_reader `attr_reader :parent` at line 19.
pub fn ruby_named_args_l19_d1_parent(args NamedArgs) NamedArgsParent {
	return args.parent
}

// Ruby method `initialize(` at line 32.
pub fn ruby_named_args_l32_d2_initialize(values []string, config NamedArgsConfig) NamedArgs {
	return new_named_args_with_config(values, config)
}

// Ruby method `to_casks` at line 52.
pub fn ruby_named_args_l52_d3_to_casks(args NamedArgs) ![]api.PackageReference {
	return args.to_casks()
}

// Ruby method `to_formulae` at line 60.
pub fn ruby_named_args_l60_d4_to_formulae(args NamedArgs) ![]api.PackageReference {
	return args.to_formulae()
}

// Ruby method `to_formulae_and_casks(` at line 79.
pub fn ruby_named_args_l79_d5_to_formulae_and_casks(args NamedArgs,
	options PackageConversionOptions) ![]api.PackageReference {
	return args.resolve_formulae_and_casks(options)
}

// Ruby method `to_formulae_to_casks(only: parent.only_formula_or_cask, method: nil)` at line 108.
pub fn ruby_named_args_l108_d6_to_formulae_to_casks(args NamedArgs,
	options PackageConversionOptions) !PackagePartition {
	return args.to_formulae_to_casks(options)
}

// Ruby method `to_formulae_and_casks_with_taps` at line 123.
pub fn ruby_named_args_l123_d7_to_formulae_and_casks_with_taps(args NamedArgs) ![]api.PackageReference {
	return args.to_formulae_and_casks_with_taps()
}

// Ruby method `to_formulae_and_casks_and_unavailable(only: parent.only_formula_or_cask, method: nil, uniq: true)` at line 149.
pub fn ruby_named_args_l149_d8_to_formulae_and_casks_and_unavailable(args NamedArgs,
	options PackageConversionOptions) []api.PackageReference {
	return args.to_formulae_and_casks_and_unavailable(options)
}

// Ruby method `to_resolved_formulae(uniq: true)` at line 168.
pub fn ruby_named_args_l168_d9_to_resolved_formulae(args NamedArgs,
	unique bool) ![]api.PackageReference {
	return args.to_resolved_formulae(unique)
}

// Ruby method `to_resolved_formulae_to_casks(only: parent.only_formula_or_cask)` at line 177.
pub fn ruby_named_args_l177_d10_to_resolved_formulae_to_casks(args NamedArgs,
	only string) !PackagePartition {
	return args.to_resolved_formulae_to_casks(only)
}

// Ruby method `to_paths(only: parent.only_formula_or_cask, recurse_tap: false)` at line 189.
pub fn ruby_named_args_l189_d11_to_paths(args NamedArgs, only string,
	recurse_tap bool) ![]string {
	return args.to_paths(only, recurse_tap)
}

// Ruby method `to_default_kegs` at line 234.
pub fn ruby_named_args_l234_d12_to_default_kegs(args NamedArgs) ![]api.PackageReference {
	return args.to_keg_references('default_kegs')
}

// Ruby method `to_latest_kegs` at line 249.
pub fn ruby_named_args_l249_d13_to_latest_kegs(args NamedArgs) ![]api.PackageReference {
	return args.to_keg_references('latest_kegs')
}

// Ruby method `to_kegs` at line 264.
pub fn ruby_named_args_l264_d14_to_kegs(args NamedArgs) ![]api.PackageReference {
	return args.to_keg_references('kegs')
}

// Ruby method `to_kegs_to_casks(only: parent.only_formula_or_cask, ignore_unavailable: false, all_kegs: nil)` at line 282.
pub fn ruby_named_args_l282_d15_to_kegs_to_casks(args NamedArgs, only string,
	ignore_unavailable bool, all_kegs bool) !PackagePartition {
	return args.to_kegs_to_casks(only, ignore_unavailable, all_kegs)
}

// Ruby method `to_taps` at line 304.
pub fn ruby_named_args_l304_d16_to_taps(args NamedArgs) ![]string {
	return args.to_taps()
}

// Ruby method `to_installed_taps` at line 309.
pub fn ruby_named_args_l309_d17_to_installed_taps(args NamedArgs) ![]string {
	return args.to_installed_taps()
}

// Ruby method `homebrew_tap_cask_names` at line 316.
pub fn ruby_named_args_l316_d18_homebrew_tap_cask_names(args NamedArgs) []string {
	return args.homebrew_tap_cask_names()
}

// Ruby method `downcased_unique_named` at line 321.
pub fn ruby_named_args_l321_d19_downcased_unique_named(args NamedArgs) []string {
	return args.downcased_unique_named()
}

// Ruby method `load_formula_or_cask(name, only: nil, method: nil, warn: false)` at line 338.
pub fn ruby_named_args_l338_d20_load_formula_or_cask(args NamedArgs, name string, only string,
	method string, warn bool) !PackageResolution {
	return args.resolve_formula_or_cask(name, only, method, warn)
}

// Ruby method `load_untrusted_installed_cask(name, config: nil)` at line 480.
pub fn ruby_named_args_l480_d21_load_untrusted_installed_cask(args NamedArgs,
	name string) ?api.PackageReference {
	return args.load_untrusted_installed_cask(name)
}

// Ruby method `resolve_formula(name)` at line 509.
pub fn ruby_named_args_l509_d22_resolve_formula(args NamedArgs,
	name string) !api.PackageReference {
	return args.formula_reference(name, 'resolve')
}

// Ruby method `resolve_kegs(name)` at line 514.
pub fn ruby_named_args_l514_d23_resolve_kegs(args NamedArgs,
	name string) !(string, []NamedKeg) {
	return args.resolve_kegs(name)
}

// Ruby method `resolve_latest_keg(name)` at line 538.
pub fn ruby_named_args_l538_d24_resolve_latest_keg(args NamedArgs,
	name string) !api.PackageReference {
	return args.resolve_latest_keg(name)
}

// Ruby method `resolve_default_keg(name)` at line 557.
pub fn ruby_named_args_l557_d25_resolve_default_keg(args NamedArgs,
	name string) !api.PackageReference {
	return args.resolve_default_keg(name)
}

// Ruby method `package_conflicts_message(ref, loaded_type, package)` at line 597.
pub fn ruby_named_args_l597_d26_package_conflicts_message(ref string, loaded_type string,
	package api.PackageReference) string {
	return package_conflicts_message(ref, loaded_type, package)
}

// Ruby method `warn_if_cask_conflicts(ref, loaded_type)` at line 617.
pub fn ruby_named_args_l617_d27_warn_if_cask_conflicts(args NamedArgs, ref string,
	loaded_type string) ?string {
	cask := args.cask_reference(ref) or { return none }
	return package_conflicts_message(ref, loaded_type, cask)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/caskroom"
// 5: require "cli/args"
// 6: require "utils"
// 7: require "utils/output"
// 8:
// 9: module Homebrew
// 10:   module CLI
// 11:     # Helper class for loading formulae/casks from named arguments.
// 12:     class NamedArgs < Array
// 13:       include Utils::Output::Mixin
// 14:       extend T::Generic
// 15:
// 16:       Elem = type_member(:out) { { fixed: String } }
// 17:
// 18:       sig { returns(Args) }
// 19:       attr_reader :parent
// 20:
// 21:       sig {
// 22:         params(
// 23:           args:          String,
// 24:           parent:        Args,
// 25:           override_spec: T.nilable(Symbol),
// 26:           force_bottle:  T::Boolean,
// 27:           flags:         T::Array[String],
// 28:           cask_options:  T::Boolean,
// 29:           without_api:   T::Boolean,
// 30:         ).void
// 31:       }
// 32:       def initialize(
// 33:         *args,
// 34:         parent: Args.new,
// 35:         override_spec: nil,
// 36:         force_bottle: false,
// 37:         flags: [],
// 38:         cask_options: false,
// 39:         without_api: false
// 40:       )
// 41:         super(args)
// 42:
// 43:         @override_spec = override_spec
// 44:         @force_bottle = force_bottle
// 45:         @flags = flags
// 46:         @cask_options = cask_options
// 47:         @without_api = without_api
// 48:         @parent = parent
// 49:       end
// 50:
// 51:       sig { returns(T::Array[Cask::Cask]) }
// 52:       def to_casks
// 53:         @to_casks ||= T.let(
// 54:           to_formulae_and_casks(only: :cask).freeze, T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)])
// 55:         )
// 56:         T.cast(@to_casks, T::Array[Cask::Cask])
// 57:       end
// 58:
// 59:       sig { returns(T::Array[Formula]) }
// 60:       def to_formulae
// 61:         @to_formulae ||= T.let(
// 62:           to_formulae_and_casks(only: :formula).freeze, T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)])
// 63:         )
// 64:         T.cast(@to_formulae, T::Array[Formula])
// 65:       end
// 66:
// 67:       # Convert named arguments to {Formula} or {Cask} objects.
// 68:       # If both a formula and cask with the same name exist, returns
// 69:       # the formula and prints a warning unless `only` is specified.
// 70:       sig {
// 71:         params(
// 72:           only:               T.nilable(Symbol),
// 73:           ignore_unavailable: T::Boolean,
// 74:           method:             T.nilable(Symbol),
// 75:           uniq:               T::Boolean,
// 76:           warn:               T::Boolean,
// 77:         ).returns(T::Array[T.any(Formula, Keg, Cask::Cask)])
// 78:       }
// 79:       def to_formulae_and_casks(
// 80:         only: parent.only_formula_or_cask, ignore_unavailable: false, method: nil, uniq: true, warn: false
// 81:       )
// 82:         @to_formulae_and_casks ||= T.let(
// 83:           {}, T.nilable(T::Hash[T.nilable(Symbol), T::Array[T.any(Formula, Keg, Cask::Cask)]])
// 84:         )
// 85:         @to_formulae_and_casks[only] ||= downcased_unique_named.flat_map do |name|
// 86:           load_formula_or_cask(name, only:, method:, warn:)
// 87:         rescue FormulaUnreadableError, FormulaClassUnavailableError,
// 88:                TapFormulaUnreadableError, TapFormulaClassUnavailableError,
// 89:                Cask::CaskUnreadableError
// 90:           # Need to rescue before `*UnavailableError` (superclass of this)
// 91:           # The formula/cask was found, but there's a problem with its implementation
// 92:           raise
// 93:         rescue NoSuchKegError, FormulaUnavailableError, Cask::CaskUnavailableError, FormulaOrCaskUnavailableError
// 94:           ignore_unavailable ? [] : raise
// 95:         end.freeze
// 96:
// 97:         if uniq
// 98:           @to_formulae_and_casks.fetch(only).uniq.freeze
// 99:         else
// 100:           @to_formulae_and_casks.fetch(only)
// 101:         end
// 102:       end
// 103:
// 104:       sig {
// 105:         params(only: T.nilable(Symbol), method: T.nilable(Symbol))
// 106:           .returns([T::Array[T.any(Formula, Keg)], T::Array[Cask::Cask]])
// 107:       }
// 108:       def to_formulae_to_casks(only: parent.only_formula_or_cask, method: nil)
// 109:         @to_formulae_to_casks ||= T.let(
// 110:           {}, T.nilable(T::Hash[[T.nilable(Symbol), T.nilable(Symbol)],
// 111:                                 [T::Array[T.any(Formula, Keg)], T::Array[Cask::Cask]]])
// 112:         )
// 113:         @to_formulae_to_casks[[method, only]] =
// 114:           T.cast(
// 115:             to_formulae_and_casks(only:, method:).partition { |o| o.is_a?(Formula) || o.is_a?(Keg) }
// 116:                     .map(&:freeze).freeze,
// 117:             [T::Array[T.any(Formula, Keg)], T::Array[Cask::Cask]],
// 118:           )
// 119:       end
// 120:
// 121:       # Returns formulae and casks after validating that a tap is present for each of them.
// 122:       sig { returns(T::Array[T.any(Formula, Keg, Cask::Cask)]) }
// 123:       def to_formulae_and_casks_with_taps
// 124:         formulae_and_casks_with_taps, formulae_and_casks_without_taps =
// 125:           to_formulae_and_casks.partition do |formula_or_cask|
// 126:             T.cast(formula_or_cask, T.any(Formula, Cask::Cask)).tap&.installed?
// 127:           end
// 128:
// 129:         return formulae_and_casks_with_taps if formulae_and_casks_without_taps.empty?
// 130:
// 131:         types = []
// 132:         types << "formulae" if formulae_and_casks_without_taps.any?(Formula)
// 133:         types << "casks" if formulae_and_casks_without_taps.any?(Cask::Cask)
// 134:
// 135:         odie <<~ERROR
// 136:           These #{types.join(" and ")} are not in any locally installed taps!
// 137:
// 138:             #{formulae_and_casks_without_taps.sort_by(&:to_s).join("\n  ")}
// 139:
// 140:           You may need to run `brew tap` to install additional taps.
// 141:         ERROR
// 142:       end
// 143:
// 144:       sig {
// 145:         params(only: T.nilable(Symbol), method: T.nilable(Symbol), uniq: T::Boolean)
// 146:           .returns(T::Array[T.any(Formula, Keg, Cask::Cask, T::Array[Keg],
// 147:                                   FormulaOrCaskUnavailableError, NoSuchKegError)])
// 148:       }
// 149:       def to_formulae_and_casks_and_unavailable(only: parent.only_formula_or_cask, method: nil, uniq: true)
// 150:         @to_formulae_casks_unknowns ||= T.let(
// 151:           {},
// 152:           T.nilable(T::Hash[
// 153:             [T.nilable(Symbol), T::Boolean],
// 154:             T::Array[T.any(Formula, Keg, Cask::Cask, T::Array[Keg],
// 155:                            FormulaOrCaskUnavailableError, NoSuchKegError)],
// 156:           ]),
// 157:         )
// 158:         items = downcased_unique_named.map do |name|
// 159:           load_formula_or_cask(name, only:, method:)
// 160:         rescue FormulaOrCaskUnavailableError, NoSuchKegError => e
// 161:           e
// 162:         end
// 163:         items = items.uniq if uniq
// 164:         @to_formulae_casks_unknowns[[method, uniq]] = items.freeze
// 165:       end
// 166:
// 167:       sig { params(uniq: T::Boolean).returns(T::Array[Formula]) }
// 168:       def to_resolved_formulae(uniq: true)
// 169:         @to_resolved_formulae ||= T.let(
// 170:           to_formulae_and_casks(only: :formula, method: :resolve, uniq:).freeze,
// 171:           T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)]),
// 172:         )
// 173:         T.cast(@to_resolved_formulae, T::Array[Formula])
// 174:       end
// 175:
// 176:       sig { params(only: T.nilable(Symbol)).returns([T::Array[Formula], T::Array[Cask::Cask]]) }
// 177:       def to_resolved_formulae_to_casks(only: parent.only_formula_or_cask)
// 178:         T.cast(to_formulae_to_casks(only:, method: :resolve), [T::Array[Formula], T::Array[Cask::Cask]])
// 179:       end
// 180:
// 181:       LOCAL_PATH_REGEX = %r{^/|[.]|/$}
// 182:       TAP_NAME_REGEX = %r{^[^./]+/[^./]+$}
// 183:       private_constant :LOCAL_PATH_REGEX, :TAP_NAME_REGEX
// 184:
// 185:       # Keep existing paths and try to convert others to tap, formula or cask paths.
// 186:       # If a cask and formula with the same name exist, includes both their paths
// 187:       # unless `only` is specified.
// 188:       sig { params(only: T.nilable(Symbol), recurse_tap: T::Boolean).returns(T::Array[Pathname]) }
// 189:       def to_paths(only: parent.only_formula_or_cask, recurse_tap: false)
// 190:         @to_paths ||= T.let({}, T.nilable(T::Hash[T.nilable(Symbol), T::Array[Pathname]]))
// 191:         @to_paths[only] ||= Homebrew.with_no_api_env_if_needed(@without_api) do
// 192:           downcased_unique_named.flat_map do |name|
// 193:             path = Pathname(name).expand_path
// 194:             if only.nil? && name.match?(LOCAL_PATH_REGEX) && path.exist?
// 195:               path
// 196:             elsif name.match?(TAP_NAME_REGEX)
// 197:               tap = Tap.fetch(name)
// 198:
// 199:               if recurse_tap
// 200:                 next tap.formula_files if only == :formula
// 201:                 next tap.cask_files if only == :cask
// 202:               end
// 203:
// 204:               tap.path
// 205:             else
// 206:               next Formulary.path(name) if only == :formula
// 207:               next Cask::CaskLoader.path(name) if only == :cask
// 208:
// 209:               formula_path = Formulary.path(name)
// 210:               cask_path = Cask::CaskLoader.path(name)
// 211:
// 212:               paths = []
// 213:
// 214:               if formula_path.exist? ||
// 215:                  (!Homebrew::EnvConfig.no_install_from_api? &&
// 216:                  !CoreTap.instance.installed? &&
// 217:                  Homebrew::API.formula_name?(path.basename.to_s))
// 218:                 paths << formula_path
// 219:               end
// 220:               if cask_path.exist? ||
// 221:                  (!Homebrew::EnvConfig.no_install_from_api? &&
// 222:                  !CoreCaskTap.instance.installed? &&
// 223:                  Homebrew::API.cask_token?(path.basename.to_s))
// 224:                 paths << cask_path
// 225:               end
// 226:
// 227:               paths.empty? ? path : paths
// 228:             end
// 229:           end.uniq.freeze
// 230:         end
// 231:       end
// 232:
// 233:       sig { returns(T::Array[Keg]) }
// 234:       def to_default_kegs
// 235:         require "missing_formula"
// 236:
// 237:         @to_default_kegs ||= T.let(begin
// 238:           to_formulae_and_casks(only: :formula, method: :default_kegs).freeze
// 239:         rescue NoSuchKegError => e
// 240:           if (reason = MissingFormula.suggest_command(e.name, "uninstall"))
// 241:             $stderr.puts reason
// 242:           end
// 243:           raise e
// 244:         end, T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)]))
// 245:         T.cast(@to_default_kegs, T::Array[Keg])
// 246:       end
// 247:
// 248:       sig { returns(T::Array[Keg]) }
// 249:       def to_latest_kegs
// 250:         require "missing_formula"
// 251:
// 252:         @to_latest_kegs ||= T.let(begin
// 253:           to_formulae_and_casks(only: :formula, method: :latest_kegs).freeze
// 254:         rescue NoSuchKegError => e
// 255:           if (reason = MissingFormula.suggest_command(e.name, "uninstall"))
// 256:             $stderr.puts reason
// 257:           end
// 258:           raise e
// 259:         end, T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)]))
// 260:         T.cast(@to_latest_kegs, T::Array[Keg])
// 261:       end
// 262:
// 263:       sig { returns(T::Array[Keg]) }
// 264:       def to_kegs
// 265:         require "missing_formula"
// 266:
// 267:         @to_kegs ||= T.let(begin
// 268:           to_formulae_and_casks(only: :formula, method: :kegs).freeze
// 269:         rescue NoSuchKegError => e
// 270:           if (reason = MissingFormula.suggest_command(e.name, "uninstall"))
// 271:             $stderr.puts reason
// 272:           end
// 273:           raise e
// 274:         end, T.nilable(T::Array[T.any(Formula, Keg, Cask::Cask)]))
// 275:         T.cast(@to_kegs, T::Array[Keg])
// 276:       end
// 277:
// 278:       sig {
// 279:         params(only: T.nilable(Symbol), ignore_unavailable: T::Boolean, all_kegs: T.nilable(T::Boolean))
// 280:           .returns([T::Array[Keg], T::Array[Cask::Cask]])
// 281:       }
// 282:       def to_kegs_to_casks(only: parent.only_formula_or_cask, ignore_unavailable: false, all_kegs: nil)
// 283:         method = all_kegs ? :kegs : :default_kegs
// 284:         key = [method, only, ignore_unavailable]
// 285:
// 286:         @to_kegs_to_casks ||= T.let(
// 287:           {},
// 288:           T.nilable(
// 289:             T::Hash[
// 290:               [T.nilable(Symbol), T.nilable(Symbol), T::Boolean],
// 291:               [T::Array[Keg], T::Array[Cask::Cask]],
// 292:             ],
// 293:           ),
// 294:         )
// 295:         @to_kegs_to_casks[key] ||= T.cast(
// 296:           to_formulae_and_casks(only:, ignore_unavailable:, method:)
// 297:             .partition { |o| o.is_a?(Keg) }
// 298:             .map(&:freeze).freeze,
// 299:           [T::Array[Keg], T::Array[Cask::Cask]],
// 300:         )
// 301:       end
// 302:
// 303:       sig { returns(T::Array[Tap]) }
// 304:       def to_taps
// 305:         @to_taps ||= T.let(downcased_unique_named.map { |name| Tap.fetch name }.uniq.freeze, T.nilable(T::Array[Tap]))
// 306:       end
// 307:
// 308:       sig { returns(T::Array[Tap]) }
// 309:       def to_installed_taps
// 310:         @to_installed_taps ||= T.let(to_taps.each do |tap|
// 311:           raise TapUnavailableError, tap.name unless tap.installed?
// 312:         end.uniq.freeze, T.nilable(T::Array[Tap]))
// 313:       end
// 314:
// 315:       sig { returns(T::Array[String]) }
// 316:       def homebrew_tap_cask_names
// 317:         downcased_unique_named.grep(HOMEBREW_CASK_TAP_CASK_REGEX)
// 318:       end
// 319:
// 320:       sig { returns(T::Array[String]) }
// 321:       def downcased_unique_named
// 322:         # Only lowercase names, not paths, bottle filenames or URLs
// 323:         map do |arg|
// 324:           if arg.include?("/") || arg.end_with?(".tar.gz") || File.exist?(arg)
// 325:             arg
// 326:           else
// 327:             arg.downcase
// 328:           end
// 329:         end.uniq
// 330:       end
// 331:
// 332:       private
// 333:
// 334:       sig {
// 335:         params(name: String, only: T.nilable(Symbol), method: T.nilable(Symbol), warn: T::Boolean)
// 336:           .returns(T.any(Formula, Keg, Cask::Cask, T::Array[Keg]))
// 337:       }
// 338:       def load_formula_or_cask(name, only: nil, method: nil, warn: false)
// 339:         Homebrew.with_no_api_env_if_needed(@without_api) do
// 340:           unreadable_error = nil
// 341:
// 342:           formula_or_kegs = if only != :cask
// 343:             begin
// 344:               case method
// 345:               when nil, :factory
// 346:                 Formulary.factory(name, *@override_spec, warn:, force_bottle: @force_bottle, flags: @flags)
// 347:               when :resolve
// 348:                 resolve_formula(name)
// 349:               when :latest_kegs
// 350:                 resolve_latest_keg(name)
// 351:               when :default_kegs
// 352:                 resolve_default_keg(name)
// 353:               when :kegs
// 354:                 _, kegs = resolve_kegs(name)
// 355:                 kegs
// 356:               else
// 357:                 raise
// 358:               end
// 359:             rescue FormulaUnreadableError, FormulaClassUnavailableError,
// 360:                    TapFormulaUnreadableError, TapFormulaClassUnavailableError,
// 361:                    FormulaSpecificationError => e
// 362:               # Need to rescue before `FormulaUnavailableError` (superclass of this)
// 363:               # The formula was found, but there's a problem with its implementation
// 364:               unreadable_error ||= e
// 365:               nil
// 366:             rescue NoSuchKegError, FormulaUnavailableError => e
// 367:               raise e if only == :formula
// 368:
// 369:               nil
// 370:             end
// 371:           end
// 372:
// 373:           if only == :formula
// 374:             return formula_or_kegs if formula_or_kegs
// 375:           elsif formula_or_kegs && (!formula_or_kegs.is_a?(Formula) || formula_or_kegs.tap&.core_tap?)
// 376:             warn_if_cask_conflicts(name, "formula")
// 377:             return formula_or_kegs
// 378:           else
// 379:             want_keg_like_cask = [:latest_kegs, :default_kegs, :kegs].include?(method)
// 380:
// 381:             cask = begin
// 382:               config = Cask::Config.from_args(@parent) if @cask_options
// 383:               options = { warn: }.compact
// 384:               untrusted_installed_cask = (load_untrusted_installed_cask(name, config:) if want_keg_like_cask)
// 385:               candidate_cask = untrusted_installed_cask || Cask::CaskLoader.load(name, config:, **options)
// 386:               skip_installed_caskfile_load = if untrusted_installed_cask
// 387:                 !untrusted_installed_cask.loaded_from_api?
// 388:               else
// 389:                 false
// 390:               end
// 391:
// 392:               if unreadable_error
// 393:                 onoe <<~EOS
// 394:                   Failed to load formula: #{name}
// 395:                   #{unreadable_error}
// 396:                 EOS
// 397:                 opoo "Treating #{name} as a cask."
// 398:               end
// 399:
// 400:               # If we're trying to get a keg-like Cask, do our best to use the same cask
// 401:               # file that was used for installation, if possible.
// 402:               if want_keg_like_cask && !skip_installed_caskfile_load &&
// 403:                  (installed_caskfile = candidate_cask.installed_caskfile) &&
// 404:                  installed_caskfile.exist?
// 405:                 cask = Cask::CaskLoader.load_from_installed_caskfile(installed_caskfile)
// 406:
// 407:                 requested_tap, requested_token = Tap.with_cask_token(name)
// 408:                 if requested_tap && requested_token
// 409:                   installed_cask_tap = cask.tab.tap
// 410:
// 411:                   if installed_cask_tap && installed_cask_tap != requested_tap
// 412:                     raise Cask::TapCaskUnavailableError.new(requested_tap, requested_token)
// 413:                   end
// 414:                 end
// 415:
// 416:                 cask
// 417:               else
// 418:                 candidate_cask
// 419:               end
// 420:             rescue Homebrew::UntrustedTapError
// 421:               raise unless want_keg_like_cask
// 422:
// 423:               raise unless (untrusted_installed_cask = load_untrusted_installed_cask(name, config:))
// 424:
// 425:               untrusted_installed_cask
// 426:             rescue Cask::CaskUnreadableError, Cask::CaskInvalidError => e
// 427:               # If we're trying to get a keg-like Cask, do our best to handle it
// 428:               # not being readable and return something that can be used.
// 429:               if want_keg_like_cask
// 430:                 cask_version = Cask::Caskroom.cask_installed_version(name)
// 431:                 Cask::Cask.new(name, config:) do
// 432:                   version cask_version if cask_version
// 433:                 end
// 434:               else
// 435:                 # Need to rescue before `CaskUnavailableError` (superclass of this)
// 436:                 # The cask was found, but there's a problem with its implementation
// 437:                 unreadable_error ||= e
// 438:                 nil
// 439:               end
// 440:             rescue Cask::CaskUnavailableError => e
// 441:               raise e if only == :cask
// 442:
// 443:               nil
// 444:             end
// 445:
// 446:             # Prioritise formulae unless it's a core tap cask (we already prioritised core tap formulae above)
// 447:             if formula_or_kegs && !cask&.tap&.core_cask_tap?
// 448:               if cask || unreadable_error
// 449:                 onoe <<~EOS if unreadable_error
// 450:                   Failed to load cask: #{name}
// 451:                   #{unreadable_error}
// 452:                 EOS
// 453:                 opoo package_conflicts_message(name, "formula", cask) unless Context.current.quiet?
// 454:               end
// 455:               return formula_or_kegs
// 456:             elsif cask
// 457:               if formula_or_kegs && !Context.current.quiet?
// 458:                 opoo package_conflicts_message(name, "cask", formula_or_kegs)
// 459:               end
// 460:               return cask
// 461:             end
// 462:           end
// 463:
// 464:           raise unreadable_error if unreadable_error
// 465:
// 466:           downcased_name = name.downcase
// 467:           if (tap_name = Utils.tap_from_full_name(downcased_name))
// 468:             raise TapFormulaOrCaskUnavailableError.new(Tap.fetch(tap_name),
// 469:                                                        Utils.name_from_full_name(downcased_name))
// 470:           end
// 471:
// 472:           raise NoSuchKegError, name if resolve_formula(name)
// 473:         end
// 474:       end
// 475:
// 476:       sig {
// 477:         params(name: String, config: T.nilable(Cask::Config))
// 478:           .returns(T.nilable(Cask::Cask))
// 479:       }
// 480:       def load_untrusted_installed_cask(name, config: nil)
// 481:         return unless Homebrew::EnvConfig.require_tap_trust?
// 482:
// 483:         require "trust"
// 484:
// 485:         requested_tap, token = Tap.with_cask_token(name) || [nil, name]
// 486:         token = ::Utils.name_from_full_name(token)
// 487:         installed_cask = Cask::Cask.new(token, config:)
// 488:         installed_caskfile = installed_cask.installed_caskfile
// 489:         return unless installed_caskfile&.exist?
// 490:
// 491:         installed_tap = installed_cask.tab.tap
// 492:         return unless installed_tap
// 493:         return if requested_tap && requested_tap != installed_tap
// 494:         return if Homebrew::Trust.trusted?(:cask, "#{installed_tap.name}/#{token}")
// 495:
// 496:         if installed_caskfile.extname == ".json"
// 497:           return Cask::CaskLoader.load_from_installed_caskfile(installed_caskfile,
// 498:                                                                config:)
// 499:         end
// 500:
// 501:         return unless (cask_version = Cask::Caskroom.cask_installed_version(token))
// 502:
// 503:         Cask::Cask.new(token, tap: installed_tap, config:) do
// 504:           version cask_version
// 505:         end
// 506:       end
// 507:
// 508:       sig { params(name: String).returns(Formula) }
// 509:       def resolve_formula(name)
// 510:         Formulary.resolve(name, spec: @override_spec, force_bottle: @force_bottle, flags: @flags)
// 511:       end
// 512:
// 513:       sig { params(name: String).returns([Pathname, T::Array[Keg]]) }
// 514:       def resolve_kegs(name)
// 515:         raise UsageError if name.blank?
// 516:
// 517:         require "keg"
// 518:
// 519:         rack = Formulary.to_rack(name.downcase)
// 520:
// 521:         kegs = rack.directory? ? rack.subdirs.map { |d| Keg.new(d) } : []
// 522:
// 523:         requested_tap, requested_formula = Tap.with_formula_name(name)
// 524:         if requested_tap && requested_formula
// 525:           kegs = kegs.select do |keg|
// 526:             keg.tab.tap == requested_tap
// 527:           end
// 528:
// 529:           raise NoSuchKegError.new(requested_formula, tap: requested_tap) if kegs.none?
// 530:         end
// 531:
// 532:         raise NoSuchKegError, name if kegs.none?
// 533:
// 534:         [rack, kegs]
// 535:       end
// 536:
// 537:       sig { params(name: String).returns(Keg) }
// 538:       def resolve_latest_keg(name)
// 539:         _, kegs = resolve_kegs(name)
// 540:
// 541:         # Return keg if it is the only installed keg
// 542:         return kegs.fetch(0) if kegs.length == 1
// 543:
// 544:         stable_kegs = kegs.reject { |keg| keg.version.head? }
// 545:
// 546:         latest_keg = if stable_kegs.empty?
// 547:           kegs.max_by do |keg|
// 548:             [keg.tab.source_modified_time, keg.version.revision]
// 549:           end
// 550:         else
// 551:           stable_kegs.max_by(&:scheme_and_version)
// 552:         end
// 553:         T.must(latest_keg)
// 554:       end
// 555:
// 556:       sig { params(name: String).returns(Keg) }
// 557:       def resolve_default_keg(name)
// 558:         rack, kegs = resolve_kegs(name)
// 559:
// 560:         linked_keg_ref = HOMEBREW_LINKED_KEGS/rack.basename
// 561:         opt_prefix = HOMEBREW_PREFIX/"opt/#{rack.basename}"
// 562:
// 563:         begin
// 564:           return Keg.new(opt_prefix.resolved_path) if opt_prefix.symlink? && opt_prefix.directory?
// 565:           return Keg.new(linked_keg_ref.resolved_path) if linked_keg_ref.symlink? && linked_keg_ref.directory?
// 566:           return kegs.fetch(0) if kegs.length == 1
// 567:
// 568:           f = if name.include?("/") || File.exist?(name)
// 569:             Formulary.factory(name)
// 570:           else
// 571:             Formulary.from_rack(rack)
// 572:           end
// 573:
// 574:           unless (prefix = f.latest_installed_prefix).directory?
// 575:             raise MultipleVersionsInstalledError, <<~EOS
// 576:               #{rack.basename} has multiple installed versions
// 577:               Run `brew uninstall --force #{rack.basename}` to remove all versions.
// 578:             EOS
// 579:           end
// 580:
// 581:           Keg.new(prefix)
// 582:         rescue FormulaUnavailableError
// 583:           raise MultipleVersionsInstalledError, <<~EOS
// 584:             Multiple kegs installed to #{rack}
// 585:             However we don't know which one you refer to.
// 586:             Please delete (with `rm -rf`!) all but one and then try again.
// 587:           EOS
// 588:         end
// 589:       end
// 590:
// 591:       sig {
// 592:         params(
// 593:           ref: String, loaded_type: String,
// 594:           package: T.nilable(T.any(T::Array[T.any(Formula, Keg)], Cask::Cask, Formula, Keg))
// 595:         ).returns(String)
// 596:       }
// 597:       def package_conflicts_message(ref, loaded_type, package)
// 598:         message = "Treating #{ref} as a #{loaded_type}."
// 599:         case package
// 600:         when Formula, Keg, Array
// 601:           message += " For the formula, "
// 602:           if package.is_a?(Formula) && (tap = package.tap)
// 603:             message += "use #{tap.name}/#{package.name} or "
// 604:           end
// 605:           message += "specify the `--formula` flag. To silence this message, use the `--cask` flag."
// 606:         when Cask::Cask
// 607:           message += " For the cask, "
// 608:           if (tap = package.tap)
// 609:             message += "use #{tap.name}/#{package.token} or "
// 610:           end
// 611:           message += "specify the `--cask` flag. To silence this message, use the `--formula` flag."
// 612:         end
// 613:         message.freeze
// 614:       end
// 615:
// 616:       sig { params(ref: String, loaded_type: String).void }
// 617:       def warn_if_cask_conflicts(ref, loaded_type)
// 618:         available = true
// 619:         cask = begin
// 620:           Cask::CaskLoader.load(ref, warn: false)
// 621:         rescue Cask::CaskUnreadableError => e
// 622:           # Need to rescue before `CaskUnavailableError` (superclass of this)
// 623:           # The cask was found, but there's a problem with its implementation
// 624:           onoe <<~EOS
// 625:             Failed to load cask: #{ref}
// 626:             #{e}
// 627:           EOS
// 628:           nil
// 629:         rescue Cask::CaskUnavailableError
// 630:           # No ref conflict with a cask, do nothing
// 631:           available = false
// 632:           nil
// 633:         end
// 634:         return unless available
// 635:         return if Context.current.quiet?
// 636:         return if cask&.old_tokens&.include?(ref)
// 637:
// 638:         opoo package_conflicts_message(ref, loaded_type, cask)
// 639:       end
// 640:     end
// 641:   end
// 642: end
