module dev_cmd

import ruby
import homebrew.unpack_strategy
import os

// Translated from Homebrew/brew `dev-cmd/unpack.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn unpack_input_boundary(input &UnpackInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Unpack::Input', '', {
		'unpack_input_address': u64(voidptr(input)).str()
	})
}

pub fn unpack_item_input_boundary(input &UnpackItemInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Unpack::ItemInput', '', {
		'unpack_item_input_address': u64(voidptr(input)).str()
	})
}

fn unpack_input_from_value(value ruby.Value) &UnpackInput {
	address := value.attributes['unpack_input_address'] or { panic('invalid Unpack input') }
	return unsafe { &UnpackInput(voidptr(address.u64())) }
}

fn unpack_item_input_from_value(value ruby.Value) &UnpackItemInput {
	address := value.attributes['unpack_item_input_address'] or {
		panic('invalid Unpack item input')
	}
	return unsafe { &UnpackItemInput(voidptr(address.u64())) }
}

fn unpack_command_value(command UnpackCommand) ruby.Value {
	return ruby.map_value({
		'program':           ruby.string_value(command.program)
		'arguments':         ruby.string_array_value(command.arguments)
		'working_directory': ruby.string_value(command.working_directory)
	})
}

fn unpack_item_result_value(result UnpackItemResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in result.verbose_environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'kind':                 ruby.object_value('Symbol', result.kind.str())
		'name':                 ruby.string_value(result.name)
		'full_name':            ruby.string_value(result.full_name)
		'version':              ruby.string_value(result.version)
		'stage_dir':            ruby.object_value('Pathname', result.stage_dir)
		'headline':             ruby.string_value(result.headline)
		'removed_existing':     ruby.bool_value(result.removed_existing)
		'brew':                 ruby.bool_value(result.brew)
		'verbose_environment':  ruby.map_value(environment)
		'patch_applied':        ruby.bool_value(result.patch_applied)
		'copy_source':          ruby.object_value('Pathname', result.copy_source)
		'copy_preserve':        ruby.bool_value(result.copy_preserve)
		'download_path':        ruby.object_value('Pathname', result.download_path)
		'used_cached_download': ruby.bool_value(result.used_cached_download)
		'fetched':              ruby.bool_value(result.fetched)
		'fetch_quiet':          ruby.bool_value(result.fetch_quiet)
		'created_stage_dir':    ruby.bool_value(result.created_stage_dir)
		'strategy':             ruby.string_value(result.strategy)
		'extract_nestedly':     ruby.bool_value(result.extract_nestedly)
		'extraction_verbose':   ruby.bool_value(result.extraction_verbose)
		'git_setup_message':    ruby.string_value(result.git_setup_message)
		'git_commands':         ruby.array_value(result.git_commands.map(unpack_command_value(it)))
	})
}

fn unpack_result_value(result UnpackResult) ruby.Value {
	return ruby.map_value({
		'unpack_dir':      ruby.object_value('Pathname', result.unpack_dir)
		'resolution_mode': ruby.object_value('Symbol', result.resolution_mode)
		'items':           ruby.array_value(result.items.map(unpack_item_result_value(it)))
	})
}

// Ruby method `run` at line 44.
pub fn ruby_unpack_l44_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return unpack_result_value(run_unpack(unpack_input_from_value(args[0]).options) or {
		return ruby.object_value('FatalError', err.msg())
	})
}

// Ruby method `unpack_formula(formula, unpack_dir)` at line 74.
pub fn ruby_unpack_l74_d2_unpack_formula(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'formula input is required')
	}
	input := unpack_item_input_from_value(args[0])
	return unpack_item_result_value(unpack_formula(input.package, input.unpack_dir, input.options) or {
		return ruby.object_value('FatalError', err.msg())
	})
}

// Ruby method `unpack_cask(cask, unpack_dir)` at line 104.
pub fn ruby_unpack_l104_d3_unpack_cask(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'cask input is required')
	}
	input := unpack_item_input_from_value(args[0])
	return unpack_item_result_value(unpack_cask(input.package, input.unpack_dir, input.options) or {
		return ruby.object_value('FatalError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "stringio"
// 7: require "formula"
// 8: require "cask/download"
// 9: require "unpack_strategy"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class Unpack < AbstractCommand
// 14:       include FileUtils
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Unpack the files for the <formula> or <cask> into subdirectories of the current
// 19:           working directory.
// 20:         EOS
// 21:         flag   "--destdir=",
// 22:                description: "Create subdirectories in the directory named by <path> instead."
// 23:         switch "--patch",
// 24:                description: "Patches for <formula> will be applied to the unpacked source."
// 25:         switch "-g", "--git",
// 26:                description: "Initialise a Git repository in the unpacked source. This is useful for creating " \
// 27:                             "patches for the software."
// 28:         switch "-f", "--force",
// 29:                description: "Overwrite the destination directory if it already exists."
// 30:         switch "--formula", "--formulae",
// 31:                description: "Treat all named arguments as formulae."
// 32:         switch "--cask", "--casks",
// 33:                description: "Treat all named arguments as casks."
// 34:
// 35:         conflicts "--git", "--patch"
// 36:         conflicts "--formula", "--cask"
// 37:         conflicts "--cask", "--patch"
// 38:         conflicts "--cask", "--git"
// 39:
// 40:         named_args [:formula, :cask], min: 1
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         formulae_and_casks = if args.casks?
// 46:           args.named.to_formulae_and_casks(only: :cask)
// 47:         elsif args.formulae?
// 48:           args.named.to_formulae_and_casks(only: :formula)
// 49:         else
// 50:           args.named.to_formulae_and_casks
// 51:         end
// 52:
// 53:         if (dir = args.destdir)
// 54:           unpack_dir = Pathname.new(dir).expand_path
// 55:           unpack_dir.mkpath
// 56:         else
// 57:           unpack_dir = Pathname.pwd
// 58:         end
// 59:
// 60:         odie "Cannot write to #{unpack_dir}" unless unpack_dir.writable?
// 61:
// 62:         formulae_and_casks.each do |formula_or_cask|
// 63:           if formula_or_cask.is_a?(Cask::Cask)
// 64:             unpack_cask(formula_or_cask, unpack_dir)
// 65:           elsif (formula = T.cast(formula_or_cask, Formula))
// 66:             unpack_formula(formula, unpack_dir)
// 67:           end
// 68:         end
// 69:       end
// 70:
// 71:       private
// 72:
// 73:       sig { params(formula: Formula, unpack_dir: Pathname).void }
// 74:       def unpack_formula(formula, unpack_dir)
// 75:         stage_dir = unpack_dir/"#{formula.name}-#{formula.version}"
// 76:
// 77:         if stage_dir.exist?
// 78:           odie "Destination #{stage_dir} already exists!" unless args.force?
// 79:
// 80:           rm_rf stage_dir
// 81:         end
// 82:
// 83:         oh1 "Unpacking #{Formatter.identifier(formula.full_name)} to: #{stage_dir}"
// 84:
// 85:         # show messages about tar
// 86:         with_env VERBOSE: "1" do
// 87:           formula.brew do
// 88:             formula.patch if args.patch?
// 89:             cp_r getwd, stage_dir, preserve: true
// 90:           end
// 91:         end
// 92:
// 93:         return unless args.git?
// 94:
// 95:         ohai "Setting up Git repository"
// 96:         cd(stage_dir) do
// 97:           system "git", "init", "-q"
// 98:           system "git", "add", "-A"
// 99:           system "git", "commit", "-q", "-m", "brew-unpack"
// 100:         end
// 101:       end
// 102:
// 103:       sig { params(cask: Cask::Cask, unpack_dir: Pathname).void }
// 104:       def unpack_cask(cask, unpack_dir)
// 105:         stage_dir = unpack_dir/"#{cask.token}-#{cask.version}"
// 106:
// 107:         if stage_dir.exist?
// 108:           odie "Destination #{stage_dir} already exists!" unless args.force?
// 109:
// 110:           rm_rf stage_dir
// 111:         end
// 112:
// 113:         oh1 "Unpacking #{Formatter.identifier(cask.full_name)} to: #{stage_dir}"
// 114:
// 115:         download = Cask::Download.new(cask)
// 116:
// 117:         downloaded_path = if download.downloaded?
// 118:           download.cached_download
// 119:         else
// 120:           download.fetch(quiet: false)
// 121:         end
// 122:
// 123:         stage_dir.mkpath
// 124:         UnpackStrategy.detect(downloaded_path).extract_nestedly(to: stage_dir, verbose: true)
// 125:       end
// 126:     end
// 127:   end
// 128: end
