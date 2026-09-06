module dev_cmd

import homebrew.unpack_strategy
import os

// Translated from Homebrew/brew `dev-cmd/unpack.rb`.

pub enum UnpackPackageKind {
	formula
	cask
}

pub struct UnpackPackage {
pub:
	kind                UnpackPackageKind
	name                string
	token               string
	version             string
	full_name           string
	aliases             []string
	core_cask_tap       bool
	source_path         string
	patched_source_path string
	downloaded          bool
	cached_download     string
	fetched_download    string
}

pub struct UnpackOptions {
pub:
	named                []string
	packages             []UnpackPackage
	destdir              string
	current_directory    string
	destination_writable bool = true
	patch                bool
	git                  bool
	force                bool
	formulae             bool
	casks                bool
}

pub struct UnpackCommand {
pub:
	program           string
	arguments         []string
	working_directory string
}

pub struct UnpackItemResult {
pub:
	kind                 UnpackPackageKind
	name                 string
	full_name            string
	version              string
	stage_dir            string
	headline             string
	removed_existing     bool
	brew                 bool
	verbose_environment  map[string]string
	patch_applied        bool
	copy_source          string
	copy_preserve        bool
	download_path        string
	used_cached_download bool
	fetched              bool
	fetch_quiet          bool
	created_stage_dir    bool
	strategy             string
	extract_nestedly     bool
	extraction_verbose   bool
	git_setup_message    string
	git_commands         []UnpackCommand
}

pub struct UnpackResult {
pub:
	unpack_dir      string
	resolution_mode string
	items           []UnpackItemResult
}

@[heap]
pub struct UnpackInput {
pub:
	options UnpackOptions
}

@[heap]
pub struct UnpackItemInput {
pub:
	package    UnpackPackage
	options    UnpackOptions
	unpack_dir string
}

fn unpack_package_name(package UnpackPackage) string {
	return if package.kind == .cask { package.token } else { package.name }
}

fn unpack_package_full_name(package UnpackPackage) string {
	return if package.full_name == '' { unpack_package_name(package) } else { package.full_name }
}

fn unpack_package_matches(package UnpackPackage, raw_name string) bool {
	name := raw_name.to_lower()
	if unpack_package_name(package).to_lower() == name
		|| unpack_package_full_name(package).to_lower() == name {
		return true
	}
	return package.aliases.any(it.to_lower() == name)
}

fn unpack_resolution_mode(options UnpackOptions) !string {
	if options.formulae && options.casks {
		return error('Options --formula and --cask are mutually exclusive.')
	}
	if options.git && options.patch {
		return error('Options --git and --patch are mutually exclusive.')
	}
	if options.casks && options.patch {
		return error('Options --cask and --patch are mutually exclusive.')
	}
	if options.casks && options.git {
		return error('Options --cask and --git are mutually exclusive.')
	}
	return if options.casks {
		'cask'
	} else if options.formulae {
		'formula'
	} else {
		'automatic'
	}
}

fn resolve_unpack_package(name string, packages []UnpackPackage, mode string) !UnpackPackage {
	mut formula := ?UnpackPackage(none)
	mut cask := ?UnpackPackage(none)
	for package in packages {
		if !unpack_package_matches(package, name) {
			continue
		}
		if package.kind == .formula && formula == none {
			formula = package
		} else if package.kind == .cask && cask == none {
			cask = package
		}
	}
	if mode == 'formula' {
		return formula or { return error('FormulaUnavailableError: ${name}') }
	}
	if mode == 'cask' {
		return cask or { return error('CaskUnavailableError: ${name}') }
	}
	if formula_package := formula {
		if cask_package := cask {
			// NamedArgs gives an identically named core cask priority; otherwise
			// a formula wins the ambiguous automatic lookup.
			return if cask_package.core_cask_tap { cask_package } else { formula_package }
		}
		return formula_package
	}
	if cask_package := cask {
		return cask_package
	}
	return error('FormulaOrCaskUnavailableError: ${name}')
}

pub fn resolve_unpack_packages(options UnpackOptions) ![]UnpackPackage {
	mode := unpack_resolution_mode(options)!
	if options.named.len == 0 {
		return error('at least one formula or cask is required')
	}
	mut resolved := []UnpackPackage{}
	mut seen := map[string]bool{}
	for raw_name in options.named {
		name := raw_name.to_lower()
		if seen[name] {
			continue
		}
		seen[name] = true
		resolved << resolve_unpack_package(name, options.packages, mode)!
	}
	return resolved
}

fn unpack_destination(options UnpackOptions) string {
	working_directory := if options.current_directory == '' {
		os.getwd()
	} else {
		options.current_directory
	}
	if options.destdir == '' {
		return os.norm_path(os.abs_path(working_directory))
	}
	return os.norm_path(if os.is_abs_path(options.destdir) {
		options.destdir
	} else {
		os.join_path(working_directory, options.destdir)
	})
}

fn prepare_unpack_stage(stage_dir string, force bool) !bool {
	mut removed_existing := false
	if os.exists(stage_dir) || os.is_link(stage_dir) {
		if !force {
			return error('Destination ${stage_dir} already exists!')
		}
		if os.is_dir(stage_dir) && !os.is_link(stage_dir) {
			os.rmdir_all(stage_dir)!
		} else {
			os.rm(stage_dir)!
		}
		removed_existing = true
	}
	return removed_existing
}

fn unpack_git_commands(stage_dir string) []UnpackCommand {
	return [
		UnpackCommand{
			program: 'git'
			arguments: ['init', '-q']
			working_directory: stage_dir
		},
		UnpackCommand{
			program: 'git'
			arguments: ['add', '-A']
			working_directory: stage_dir
		},
		UnpackCommand{
			program: 'git'
			arguments: ['commit', '-q', '-m', 'brew-unpack']
			working_directory: stage_dir
		},
	]
}

pub fn unpack_formula(package UnpackPackage, unpack_dir string, options UnpackOptions) !UnpackItemResult {
	if package.kind != .formula {
		return error('unpack_formula requires a formula')
	}
	stage_dir := os.join_path(unpack_dir, '${package.name}-${package.version}')
	removed_existing := prepare_unpack_stage(stage_dir, options.force)!
	copy_source := if options.patch && package.patched_source_path != '' {
		package.patched_source_path
	} else {
		package.source_path
	}
	if copy_source == '' || !os.is_dir(copy_source) {
		return error('Formula source directory does not exist: ${copy_source}')
	}
	os.cp_all(copy_source, stage_dir, true)!
	git_commands := if options.git { unpack_git_commands(stage_dir) } else { []UnpackCommand{} }
	full_name := unpack_package_full_name(package)
	return UnpackItemResult{
		kind: package.kind
		name: package.name
		full_name: full_name
		version: package.version
		stage_dir: stage_dir
		headline: 'Unpacking ${full_name} to: ${stage_dir}'
		removed_existing: removed_existing
		brew: true
		verbose_environment: {
			'VERBOSE': '1'
		}
		patch_applied: options.patch
		copy_source: copy_source
		copy_preserve: true
		created_stage_dir: os.is_dir(stage_dir)
		git_setup_message: if options.git { 'Setting up Git repository' } else { '' }
		git_commands: git_commands
	}
}

pub fn unpack_cask(package UnpackPackage, unpack_dir string, options UnpackOptions) !UnpackItemResult {
	if package.kind != .cask {
		return error('unpack_cask requires a cask')
	}
	stage_dir := os.join_path(unpack_dir, '${package.token}-${package.version}')
	removed_existing := prepare_unpack_stage(stage_dir, options.force)!
	download_path := if package.downloaded {
		package.cached_download
	} else {
		package.fetched_download
	}
	if download_path == '' || !os.is_file(download_path) {
		return error('Cask download does not exist: ${download_path}')
	}
	os.mkdir_all(stage_dir)!
	strategy := unpack_strategy.detect(download_path, unpack_strategy.DetectOptions{})
	strategy.extract_nestedly(unpack_strategy.ExtractOptions{
		destination: stage_dir
		verbose: true
	})!
	full_name := unpack_package_full_name(package)
	return UnpackItemResult{
		kind: package.kind
		name: package.token
		full_name: full_name
		version: package.version
		stage_dir: stage_dir
		headline: 'Unpacking ${full_name} to: ${stage_dir}'
		removed_existing: removed_existing
		download_path: download_path
		used_cached_download: package.downloaded
		fetched: !package.downloaded
		fetch_quiet: false
		created_stage_dir: os.is_dir(stage_dir)
		strategy: strategy.kind.str()
		extract_nestedly: true
		extraction_verbose: true
	}
}

pub fn run_unpack(options UnpackOptions) !UnpackResult {
	mode := unpack_resolution_mode(options)!
	packages := resolve_unpack_packages(options)!
	unpack_dir := unpack_destination(options)
	os.mkdir_all(unpack_dir)!
	if !options.destination_writable || !os.is_writable(unpack_dir) {
		return error('Cannot write to ${unpack_dir}')
	}
	mut items := []UnpackItemResult{}
	for package in packages {
		if package.kind == .cask {
			items << unpack_cask(package, unpack_dir, options)!
		} else {
			items << unpack_formula(package, unpack_dir, options)!
		}
	}
	return UnpackResult{
		unpack_dir: unpack_dir
		resolution_mode: mode
		items: items
	}
}
