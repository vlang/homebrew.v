module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/extract.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct ExtractFile {
pub:
	path     string
	contents string
}

pub struct ExtractRevision {
pub:
	revision string
	path     string
	contents string
}

pub struct ExtractOptions {
pub:
	formula                   string
	source_tap_name           string = 'homebrew/core'
	source_tap_path           string
	source_tap_installed      bool = true
	source_tap_core           bool = true
	source_tap_shallow        bool
	destination_tap_name      string
	destination_tap_path      string
	destination_tap_core      bool
	destination_tap_core_cask bool
	destination_tap_installed bool = true
	developer                 bool
	git_revision              string
	version                   string
	force                     bool
	current_files             []ExtractFile
	history                   []ExtractRevision
}

pub struct ExtractFormula {
pub:
	name     string
	path     string
	version  string
	contents string
}

pub struct ExtractResult {
pub:
	name                      string
	version                   string
	formula_version           string
	revision                  string
	path                      string
	contents                  string
	stdout                    []string
	debug                     []string
	destination_tap_installed bool
	overwrote                 bool
}

pub struct ExtractMonkeyPatchState {
pub mut:
	dependency_cache_clears         int
	bottle_method_missing_adapter   bool
	module_method_missing_adapter   bool
	resource_method_missing_adapter bool
	dependency_symbol_adapter       bool
	saved_bottle_adapter            bool
	saved_module_adapter            bool
	saved_resource_adapter          bool
	saved_dependency_adapter        bool
}

@[heap]
pub struct ExtractInput {
pub:
	options ExtractOptions
}

@[heap]
pub struct ExtractFormulaRevisionInput {
pub mut:
	patch_state ExtractMonkeyPatchState
pub:
	repo     string
	name     string
	file     string
	revision string
	contents string
}

@[heap]
pub struct ExtractMonkeyPatchInput {
pub mut:
	patch_state ExtractMonkeyPatchState
pub:
	result        brew_runtime.Value
	error_message string
}

pub fn extract_input_boundary(input &ExtractInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Extract::Input', '', {
		'extract_input_address': u64(voidptr(input)).str()
	})
}

fn extract_input_from_value(value brew_runtime.Value) !&ExtractInput {
	address := value.attributes['extract_input_address'] or {
		return error('invalid Extract input')
	}
	return unsafe { &ExtractInput(voidptr(address.u64())) }
}

pub fn extract_formula_revision_input_boundary(input &ExtractFormulaRevisionInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Extract::FormulaRevisionInput', '', {
		'extract_formula_revision_input_address': u64(voidptr(input)).str()
	})
}

fn extract_formula_revision_input_from_value(value brew_runtime.Value) !&ExtractFormulaRevisionInput {
	address := value.attributes['extract_formula_revision_input_address'] or {
		return error('invalid Extract formula revision input')
	}
	return unsafe { &ExtractFormulaRevisionInput(voidptr(address.u64())) }
}

pub fn extract_monkey_patch_input_boundary(input &ExtractMonkeyPatchInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Extract::MonkeyPatchInput', '', {
		'extract_monkey_patch_input_address': u64(voidptr(input)).str()
	})
}

fn extract_monkey_patch_input_from_value(value brew_runtime.Value) !&ExtractMonkeyPatchInput {
	address := value.attributes['extract_monkey_patch_input_address'] or {
		return error('invalid Extract monkey patch input')
	}
	return unsafe { &ExtractMonkeyPatchInput(voidptr(address.u64())) }
}

fn extract_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn extract_formula_value(formula ExtractFormula) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':     brew_runtime.string_value(formula.name)
		'path':     brew_runtime.object_value('Pathname', formula.path)
		'version':  brew_runtime.string_value(formula.version)
		'contents': brew_runtime.string_value(formula.contents)
	})
}

fn extract_result_value(result ExtractResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':                      brew_runtime.string_value(result.name)
		'version':                   brew_runtime.string_value(result.version)
		'formula_version':           brew_runtime.string_value(result.formula_version)
		'revision':                  brew_runtime.string_value(result.revision)
		'path':                      brew_runtime.object_value('Pathname', result.path)
		'contents':                  brew_runtime.string_value(result.contents)
		'stdout':                    brew_runtime.string_array_value(result.stdout)
		'debug':                     brew_runtime.string_array_value(result.debug)
		'destination_tap_installed': brew_runtime.bool_value(result.destination_tap_installed)
		'overwrote':                 brew_runtime.bool_value(result.overwrote)
	})
}

pub fn extract_class_name(name string) string {
	if name == '' {
		return ''
	}
	mut lowered := name.to_lower()
	mut result := lowered[..1].to_upper()
	mut capitalize_next := false
	for character in lowered[1..].bytes() {
		if character == `-` || character == `_` || character == `.` || character == ` ` {
			capitalize_next = true
			continue
		}
		if character == `+` {
			result += 'x'
			capitalize_next = false
			continue
		}
		if capitalize_next && ((character >= `a` && character <= `z`)
			|| (character >= `0` && character <= `9`)) {
			result += character.ascii_str().to_upper()
		} else {
			result += character.ascii_str()
		}
		capitalize_next = false
	}
	for index := 1; index + 1 < result.len; index++ {
		if result[index] == `@` && result[index + 1] >= `0` && result[index + 1] <= `9` {
			return result[..index] + 'AT' + result[index + 1..]
		}
	}
	return result
}

pub fn extract_version_string(version string) string {
	mut first := -1
	mut last := -1
	for index, character in version.bytes() {
		if character >= `0` && character <= `9` {
			if first < 0 {
				first = index
			}
			last = index
		}
	}
	if first < 0 {
		return version
	}
	mut result := ''
	mut separator := false
	for character in version[first..last + 1].bytes() {
		if character >= `0` && character <= `9` {
			if separator && result != '' {
				result += '.'
			}
			result += character.ascii_str()
			separator = false
		} else {
			separator = true
		}
	}
	return result
}

fn extract_quoted_value(line string) string {
	for quote in [`\"`, `'`] {
		start := line.index_u8(quote)
		if start < 0 {
			continue
		}
		for index := start + 1; index < line.len; index++ {
			if line[index] == quote {
				return line[start + 1..index]
			}
		}
	}
	return ''
}

fn extract_stanza_value(contents string, stanza string) string {
	for line in contents.split('\n') {
		trimmed := line.trim_space()
		if trimmed.starts_with('${stanza} ') {
			return extract_quoted_value(trimmed)
		}
	}
	return ''
}

fn extract_version_from_url(url string) string {
	mut clean := url
	if index := clean.index('?') {
		clean = clean[..index]
	}
	if index := clean.index('#') {
		clean = clean[..index]
	}
	mut basename := clean.all_after_last('/')
	for extension in ['.tar.gz', '.tar.bz2', '.tar.xz', '.tgz', '.tbz', '.txz', '.zip', '.gz', '.bz2',
		'.xz'] {
		if basename.to_lower().ends_with(extension) {
			basename = basename[..basename.len - extension.len]
			break
		}
	}
	mut candidate := ''
	mut index := 0
	for index < basename.len {
		if basename[index] < `0` || basename[index] > `9` {
			index++
			continue
		}
		start := index
		for index < basename.len && ((basename[index] >= `0` && basename[index] <= `9`)
			|| basename[index] == `.`) {
			index++
		}
		value := basename[start..index].trim('.')
		if value != '' {
			candidate = value
		}
	}
	return candidate
}

fn parse_extract_formula(name string, file string, contents string) ?ExtractFormula {
	if !contents.contains('class ') || !contents.contains('< Formula') {
		return none
	}
	mut version := extract_stanza_value(contents, 'version')
	if version == '' {
		version = extract_version_from_url(extract_stanza_value(contents, 'url'))
	}
	if version == '' {
		return none
	}
	return ExtractFormula{
		name: name
		path: file
		version: version
		contents: contents
	}
}

pub fn remove_extract_bottle_block(contents string) string {
	lines := contents.split('\n')
	mut output := []string{}
	mut index := 0
	mut removed := false
	for index < lines.len {
		line := lines[index]
		trimmed := line.trim_space()
		if !removed && line.starts_with('  bottle ') && (trimmed == 'bottle do'
			|| trimmed.starts_with('bottle :')) {
			removed = true
			if trimmed == 'bottle do' {
				mut depth := 1
				index++
				for index < lines.len && depth > 0 {
					body_line := lines[index].trim_space()
					if body_line.ends_with(' do') {
						depth++
					}
					if body_line == 'end' {
						depth--
					}
					index++
				}
			} else {
				index++
			}
			if index < lines.len && lines[index] == '' {
				index++
			}
			continue
		}
		output << line
		index++
	}
	return output.join('\n')
}

pub fn prepare_extract_formula_contents(contents string) string {
	return remove_extract_bottle_block(contents.replace('@url=', 'url ').replace("require 'brewkit'", "require 'formula'"))
}

pub fn begin_extract_monkey_patch(mut state ExtractMonkeyPatchState) {
	state.dependency_cache_clears++
	state.saved_bottle_adapter = state.bottle_method_missing_adapter
	state.saved_module_adapter = state.module_method_missing_adapter
	state.saved_resource_adapter = state.resource_method_missing_adapter
	state.saved_dependency_adapter = state.dependency_symbol_adapter
	state.bottle_method_missing_adapter = true
	state.module_method_missing_adapter = true
	state.resource_method_missing_adapter = true
	state.dependency_symbol_adapter = true
}

pub fn end_extract_monkey_patch(mut state ExtractMonkeyPatchState) {
	state.bottle_method_missing_adapter = state.saved_bottle_adapter
	state.module_method_missing_adapter = state.saved_module_adapter
	state.resource_method_missing_adapter = state.saved_resource_adapter
	state.dependency_symbol_adapter = state.saved_dependency_adapter
	state.dependency_cache_clears++
}

pub fn with_extract_monkey_patch(mut state ExtractMonkeyPatchState, result brew_runtime.Value,
	error_message string) !brew_runtime.Value {
	begin_extract_monkey_patch(mut state)
	if error_message != '' {
		end_extract_monkey_patch(mut state)
		return error(error_message)
	}
	end_extract_monkey_patch(mut state)
	return result
}

pub fn extract_formula_at_revision(mut state ExtractMonkeyPatchState, repo string, name string,
	file string, revision string, contents string) ?ExtractFormula {
	if revision == '' {
		return none
	}
	_ = repo
	prepared := prepare_extract_formula_contents(contents)
	begin_extract_monkey_patch(mut state)
	formula := parse_extract_formula(name, file, prepared) or {
		end_extract_monkey_patch(mut state)
		return none
	}
	end_extract_monkey_patch(mut state)
	return formula
}

fn extract_numeric_segments(version string) ![]int {
	if version == '' {
		return error('empty version')
	}
	mut segments := []int{}
	for part in version.split('.') {
		if part == '' {
			return error('invalid version')
		}
		for character in part.bytes() {
			if character < `0` || character > `9` {
				return error('invalid version')
			}
		}
		segments << part.int()
	}
	return segments
}

pub fn extract_version_matches(desired string, candidate string) bool {
	if desired == candidate {
		return true
	}
	desired_segments := extract_numeric_segments(desired) or { return false }
	candidate_segments := extract_numeric_segments(candidate) or { return false }
	if desired_segments.len >= candidate_segments.len {
		return false
	}
	for index, segment in desired_segments {
		if candidate_segments[index] != segment {
			return false
		}
	}
	return true
}

fn extract_name_and_source(options ExtractOptions) (string, string) {
	parts := options.formula.split('/')
	if parts.len >= 3 {
		return parts.last().to_lower(), parts[..parts.len - 1].join('/')
	}
	return options.formula.to_lower(), options.source_tap_name
}

fn extract_revision_start(history []ExtractRevision, start_revision string) int {
	if start_revision == '' || start_revision == 'HEAD' {
		return 0
	}
	for index, revision in history {
		if revision.revision == start_revision {
			return index
		}
	}
	return history.len
}

fn extract_revision_matches_name(revision ExtractRevision, name string) bool {
	return os.base(revision.path) == '${name}.rb'
}

fn extract_current_formula(options ExtractOptions, name string) ?ExtractFile {
	for file in options.current_files {
		if os.base(file.path) == '${name}.rb' {
			return file
		}
	}
	return none
}

fn extract_unversioned_name(name string) string {
	if index := name.last_index('@') {
		return name[..index]
	}
	return name
}

pub fn rewrite_extracted_formula(name string, version string, contents string) string {
	class_name := extract_class_name(name)
	unversioned_name := extract_unversioned_name(name)
	version_string := extract_version_string(version)
	versioned_name := extract_class_name('${unversioned_name}@${version_string}')
	prepared := prepare_extract_formula_contents(contents)
	return prepared.replace_once('class ${class_name} < Formula', 'class ${versioned_name} < Formula')
}

pub fn run_extract(options ExtractOptions) !ExtractResult {
	mut name, source_tap_name := extract_name_and_source(options)
	if name == '' || options.destination_tap_name == '' || options.destination_tap_path == '' {
		return error('formula and destination tap are required')
	}
	if !options.source_tap_installed {
		return error('TapFormulaUnavailableError: ${source_tap_name}/${name}')
	}
	if !options.developer {
		if options.destination_tap_core {
			return error('Cannot extract formula to homebrew/core!')
		}
		if options.destination_tap_core_cask {
			return error('Cannot extract formula to homebrew/cask!')
		}
		if options.destination_tap_name == source_tap_name {
			return error('Cannot extract formula to the same tap!')
		}
	}
	start_revision := if options.git_revision == '' { 'HEAD' } else { options.git_revision }
	mut revision := ''
	mut selected := ExtractFormula{}
	mut output_version := options.version
	mut debug := []string{}
	mut patch_state := ExtractMonkeyPatchState{}
	if options.version != '' {
		start := extract_revision_start(options.history, start_revision)
		for index := start; index < options.history.len; index++ {
			entry := options.history[index]
			if !extract_revision_matches_name(entry, name) {
				continue
			}
			revision = entry.revision
			if entry.contents == '' {
				debug << 'Skipping revision ${revision} - file is empty at this revision'
				continue
			}
			formula := extract_formula_at_revision(mut patch_state, options.source_tap_path, name, entry.path, revision, entry.contents) or { break }
			selected = formula
			if extract_version_matches(options.version, formula.version) {
				break
			}
			debug << 'Trying ${formula.version} from revision ${revision} against desired ${options.version}'
			selected = ExtractFormula{}
		}
		if selected.version == '' {
			if options.source_tap_shallow {
				return error('Could not find ${name} but ${source_tap_name} is a shallow clone!\nTry again after running:\n  git -C "${options.source_tap_path}" fetch --unshallow')
			}
			return error('Could not find ${name}! The formula or version may not have existed.')
		}
	} else if start_revision == 'HEAD' {
		if current := extract_current_formula(options, name) {
			prepared := prepare_extract_formula_contents(current.contents)
			selected = parse_extract_formula(name, current.path, prepared) or {
				return error('Could not find ${name}! The formula or version may not have existed.')
			}
			revision = 'HEAD'
			output_version = selected.version
		} else {
			start := extract_revision_start(options.history, start_revision)
			for index := start; index < options.history.len; index++ {
				entry := options.history[index]
				if !extract_revision_matches_name(entry, name) || entry.contents == '' {
					continue
				}
				selected = extract_formula_at_revision(mut patch_state, options.source_tap_path, name, entry.path, entry.revision, entry.contents) or { continue }
				revision = entry.revision
				output_version = selected.version
				break
			}
		}
	} else {
		start := extract_revision_start(options.history, start_revision)
		for index := start; index < options.history.len; index++ {
			entry := options.history[index]
			if !extract_revision_matches_name(entry, name) || entry.contents == '' {
				continue
			}
			selected = extract_formula_at_revision(mut patch_state, options.source_tap_path, name, entry.path, entry.revision, entry.contents) or { continue }
			revision = entry.revision
			output_version = selected.version
			break
		}
	}
	if selected.version == '' {
		return error('Could not find ${name}! The formula or version may not have existed.')
	}
	name = extract_unversioned_name(name)
	version_string := extract_version_string(output_version)
	contents := rewrite_extracted_formula(selected.name, output_version, selected.contents)
	path := os.join_path(options.destination_tap_path, 'Formula', '${name}@${version_string}.rb')
	mut overwrote := false
	if os.exists(path) {
		if !options.force {
			return error('Destination formula already exists: ${path}\nTo overwrite it and continue anyways, run:\n  brew extract --force --version=${output_version} ${name} ${options.destination_tap_name}')
		}
		os.rm(path)!
		overwrote = true
		debug << 'Overwriting existing formula at ${path}'
	}
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
	return ExtractResult{
		name: name
		version: output_version
		formula_version: selected.version
		revision: revision
		path: path
		contents: contents
		stdout: [path]
		debug: debug
		destination_tap_installed: true
		overwrote: overwrote
	}
}

// Ruby method `run` at line 36.
pub fn ruby_extract_l36_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := extract_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := run_extract(input.options) or {
		return brew_runtime.object_value('SystemExit', err.msg())
	}
	return extract_result_value(result)
}

// Ruby method `formula_at_revision(repo, name, file, rev)` at line 165.
pub fn ruby_extract_l165_d2_formula_at_revision(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula revision input is required')
	}
	mut input := extract_formula_revision_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	formula := extract_formula_at_revision(mut input.patch_state, input.repo, input.name, input.file, input.revision, input.contents) or { return extract_nil() }
	return extract_formula_value(formula)
}

// Ruby method `with_monkey_patch(&_block)` at line 176.
pub fn ruby_extract_l176_d3_with_monkey_patch(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'monkey patch input is required')
	}
	mut input := extract_monkey_patch_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return with_extract_monkey_patch(mut input.patch_state, input.result, input.error_message) or {
		brew_runtime.object_value('RuntimeError', err.msg())
	}
}

fn extract_patch_alias(args []brew_runtime.Value, target string) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'monkey patch input is required')
	}
	mut input := extract_monkey_patch_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	match target {
		'BottleSpecification' {
			input.patch_state.saved_bottle_adapter = input.patch_state.bottle_method_missing_adapter
			input.patch_state.bottle_method_missing_adapter = true
		}
		'Module' {
			input.patch_state.saved_module_adapter = input.patch_state.module_method_missing_adapter
			input.patch_state.module_method_missing_adapter = true
		}
		'Resource' {
			input.patch_state.saved_resource_adapter = input.patch_state.resource_method_missing_adapter
			input.patch_state.resource_method_missing_adapter = true
		}
		else {
			input.patch_state.saved_dependency_adapter = input.patch_state.dependency_symbol_adapter
			input.patch_state.dependency_symbol_adapter = true
		}
	}
	return brew_runtime.structured_value('AliasMethod', target, {
		'target': target
		'action': 'save'
	})
}

fn extract_patch_restore(args []brew_runtime.Value, target string) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'monkey patch input is required')
	}
	mut input := extract_monkey_patch_input_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	match target {
		'BottleSpecification' {
			input.patch_state.bottle_method_missing_adapter = input.patch_state.saved_bottle_adapter
		}
		'Module' {
			input.patch_state.module_method_missing_adapter = input.patch_state.saved_module_adapter
		}
		'Resource' {
			input.patch_state.resource_method_missing_adapter = input.patch_state.saved_resource_adapter
		}
		else {
			input.patch_state.dependency_symbol_adapter = input.patch_state.saved_dependency_adapter
		}
	}
	return brew_runtime.structured_value('AliasMethod', target, {
		'target': target
		'action': 'restore'
	})
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 181.
pub fn ruby_extract_l181_d4_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_alias(args, 'BottleSpecification')
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 184.
pub fn ruby_extract_l184_d5_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extract_nil()
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 192.
pub fn ruby_extract_l192_d6_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_alias(args, 'Module')
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 195.
pub fn ruby_extract_l195_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extract_nil()
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 203.
pub fn ruby_extract_l203_d8_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_alias(args, 'Resource')
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 206.
pub fn ruby_extract_l206_d9_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extract_nil()
}

// Ruby alias_method `send(:alias_method, :old_parse_symbol_spec, :parse_symbol_spec)` at line 214.
pub fn ruby_extract_l214_d10_old_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_alias(args, 'DependencyCollector')
}

// Ruby define_method `define_method(:parse_symbol_spec) do |*_|` at line 217.
pub fn ruby_extract_l217_d11_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extract_nil()
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 227.
pub fn ruby_extract_l227_d12_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_restore(args, 'BottleSpecification')
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 235.
pub fn ruby_extract_l235_d13_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_restore(args, 'Module')
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 243.
pub fn ruby_extract_l243_d14_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_restore(args, 'Resource')
}

// Ruby alias_method `send(:alias_method, :parse_symbol_spec, :old_parse_symbol_spec)` at line 251.
pub fn ruby_extract_l251_d15_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return extract_patch_restore(args, 'DependencyCollector')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/git"
// 6: require "formulary"
// 7: require "software_spec"
// 8: require "tap"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Extract < AbstractCommand
// 13:       BOTTLE_BLOCK_REGEX = /  bottle (?:do.+?end|:[a-z]+)\n\n/m
// 14:
// 15:       cmd_args do
// 16:         usage_banner "`extract` [`--version=`] [`--git-revision=`] [`--force`] <formula> <tap>"
// 17:         description <<~EOS
// 18:           Look through repository history to find the most recent version of <formula> and
// 19:           create a copy in <tap>. Specifically, the command will create the new
// 20:           formula file at <tap>`/Formula/`<formula>`@`<version>`.rb`. If the tap is not
// 21:           installed yet, attempt to install/clone the tap before continuing. To extract
// 22:           a formula from a tap that is not `homebrew/core` use its fully-qualified form of
// 23:           <user>`/`<repo>`/`<formula>.
// 24:         EOS
// 25:         flag   "--git-revision=",
// 26:                description: "Search for the specified <version> of <formula> starting at <revision> instead of HEAD."
// 27:         flag   "--version=",
// 28:                description: "Extract the specified <version> of <formula> instead of the most recent."
// 29:         switch "-f", "--force",
// 30:                description: "Overwrite the destination formula if it already exists."
// 31:
// 32:         named_args [:formula, :tap], number: 2, without_api: true
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         if (tap_with_name = args.named.first&.then { Tap.with_formula_name(it) })
// 38:           source_tap, name = tap_with_name
// 39:         else
// 40:           name = args.named.fetch(0).downcase
// 41:           source_tap = CoreTap.instance
// 42:         end
// 43:         raise TapFormulaUnavailableError.new(source_tap, name) unless source_tap.installed?
// 44:
// 45:         destination_tap = Tap.fetch(args.named.fetch(1))
// 46:         unless Homebrew::EnvConfig.developer?
// 47:           odie "Cannot extract formula to homebrew/core!" if destination_tap.core_tap?
// 48:           odie "Cannot extract formula to homebrew/cask!" if destination_tap.core_cask_tap?
// 49:           odie "Cannot extract formula to the same tap!" if destination_tap == source_tap
// 50:         end
// 51:         destination_tap.install unless destination_tap.installed?
// 52:
// 53:         repo = source_tap.path
// 54:         start_rev = args.git_revision || "HEAD"
// 55:         pattern = if source_tap.core_tap?
// 56:           [source_tap.new_formula_path(name), repo/"Formula/#{name}.rb"].uniq
// 57:         else
// 58:           # A formula can technically live in the root directory of a tap or in any of its subdirectories
// 59:           [repo/"#{name}.rb", repo/"**/#{name}.rb"]
// 60:         end
// 61:
// 62:         rev = T.let(nil, T.nilable(String))
// 63:         if args.version
// 64:           ohai "Searching repository history"
// 65:           version = args.version
// 66:           version_segments = Gem::Version.new(version).segments if Gem::Version.correct?(version)
// 67:           test_formula = T.let(nil, T.nilable(Formula))
// 68:           result = ""
// 69:           loop do
// 70:             rev = rev.nil? ? start_rev : "#{rev}~1"
// 71:             rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern, before_commit: rev)
// 72:             if rev.nil? && source_tap.shallow?
// 73:               odie <<~EOS
// 74:                 Could not find #{name} but #{source_tap} is a shallow clone!
// 75:                 Try again after running:
// 76:                   git -C "#{source_tap.path}" fetch --unshallow
// 77:               EOS
// 78:             elsif rev.nil?
// 79:               odie "Could not find #{name}! The formula or version may not have existed."
// 80:             end
// 81:
// 82:             file = repo/T.must(path)
// 83:             result = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
// 84:             if result.empty?
// 85:               odebug "Skipping revision #{rev} - file is empty at this revision"
// 86:               next
// 87:             end
// 88:
// 89:             test_formula = formula_at_revision(repo, name, file, rev)
// 90:             break if test_formula.nil? || test_formula.version == version
// 91:
// 92:             if version_segments && Gem::Version.correct?(test_formula.version)
// 93:               test_formula_version_segments = Gem::Version.new(test_formula.version).segments
// 94:               if version_segments.length < test_formula_version_segments.length
// 95:                 odebug "Apply semantic versioning with #{test_formula_version_segments}"
// 96:                 break if version_segments == test_formula_version_segments.first(version_segments.length)
// 97:               end
// 98:             end
// 99:
// 100:             odebug "Trying #{test_formula.version} from revision #{rev} against desired #{version}"
// 101:           end
// 102:           odie "Could not find #{name}! The formula or version may not have existed." if test_formula.nil?
// 103:         else
// 104:           # Search in the root directory of `repository` as well as recursively in all of its subdirectories.
// 105:           files = if start_rev == "HEAD"
// 106:             Dir[repo/"{,**/}"].filter_map do |dir|
// 107:               Pathname.glob("#{dir}/#{name}.rb").find(&:file?)
// 108:             end
// 109:           else
// 110:             []
// 111:           end
// 112:
// 113:           if files.empty?
// 114:             ohai "Searching repository history"
// 115:             rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern, before_commit: start_rev)
// 116:             odie "Could not find #{name}! The formula or version may not have existed." if rev.nil?
// 117:             file = repo/T.must(path)
// 118:             version = T.must(formula_at_revision(repo, name, file, rev)).version
// 119:             result = Utils::Git.last_revision_of_file(repo, file)
// 120:           else
// 121:             file = files.fetch(0).realpath
// 122:             rev = T.let("HEAD", T.nilable(String))
// 123:             version = Formulary.factory(file).version
// 124:             result = File.read(file)
// 125:           end
// 126:         end
// 127:
// 128:         # The class name has to be renamed to match the new filename,
// 129:         # e.g. Foo version 1.2.3 becomes FooAT123 and resides in Foo@1.2.3.rb.
// 130:         class_name = Formulary.class_s(name)
// 131:
// 132:         # The version can only contain digits with decimals in between.
// 133:         version_string = version.to_s
// 134:                                 .sub(/\D*(.+?)\D*$/, "\\1")
// 135:                                 .gsub(/\D+/, ".")
// 136:
// 137:         # Remove any existing version suffixes, as a new one will be added later.
// 138:         name.sub!(/\b@(.*)\z\b/i, "")
// 139:         versioned_name = Formulary.class_s("#{name}@#{version_string}")
// 140:         result.sub!("class #{class_name} < Formula", "class #{versioned_name} < Formula")
// 141:
// 142:         # Remove bottle blocks, as they won't work.
// 143:         result.sub!(BOTTLE_BLOCK_REGEX, "")
// 144:
// 145:         path = destination_tap.path/"Formula/#{name}@#{version_string}.rb"
// 146:         if path.exist?
// 147:           unless args.force?
// 148:             odie <<~EOS
// 149:               Destination formula already exists: #{path}
// 150:               To overwrite it and continue anyways, run:
// 151:                 brew extract --force --version=#{version} #{name} #{destination_tap.name}
// 152:             EOS
// 153:           end
// 154:           odebug "Overwriting existing formula at #{path}"
// 155:           path.delete
// 156:         end
// 157:         ohai "Writing formula for #{name} at #{version} from revision #{rev} to:", path
// 158:         path.dirname.mkpath
// 159:         path.write result
// 160:       end
// 161:
// 162:       private
// 163:
// 164:       sig { params(repo: Pathname, name: String, file: Pathname, rev: String).returns(T.nilable(Formula)) }
// 165:       def formula_at_revision(repo, name, file, rev)
// 166:         return if rev.empty?
// 167:
// 168:         contents = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
// 169:         contents.gsub!("@url=", "url ")
// 170:         contents.gsub!("require 'brewkit'", "require 'formula'")
// 171:         contents.sub!(BOTTLE_BLOCK_REGEX, "")
// 172:         with_monkey_patch { Formulary.from_contents(name, file, contents, ignore_errors: true) }
// 173:       end
// 174:
// 175:       sig { params(_block: T.proc.void).returns(T.untyped) }
// 176:       def with_monkey_patch(&_block)
// 177:         DependencyCollector.clear_cache
// 178:
// 179:         BottleSpecification.class_eval do
// 180:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 181:             send(:alias_method, :old_method_missing, :method_missing)
// 182:             send(:private, :old_method_missing)
// 183:           end
// 184:           define_method(:method_missing) do |*_|
// 185:             # do nothing
// 186:           end
// 187:           send(:private, :method_missing)
// 188:         end
// 189:
// 190:         Module.class_eval do
// 191:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 192:             send(:alias_method, :old_method_missing, :method_missing)
// 193:             send(:private, :old_method_missing)
// 194:           end
// 195:           define_method(:method_missing) do |*_|
// 196:             # do nothing
// 197:           end
// 198:           send(:private, :method_missing)
// 199:         end
// 200:
// 201:         Resource.class_eval do
// 202:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 203:             send(:alias_method, :old_method_missing, :method_missing)
// 204:             send(:private, :old_method_missing)
// 205:           end
// 206:           define_method(:method_missing) do |*_|
// 207:             # do nothing
// 208:           end
// 209:           send(:private, :method_missing)
// 210:         end
// 211:
// 212:         DependencyCollector.class_eval do
// 213:           if method_defined?(:parse_symbol_spec) || private_method_defined?(:parse_symbol_spec)
// 214:             send(:alias_method, :old_parse_symbol_spec, :parse_symbol_spec)
// 215:             send(:private, :old_parse_symbol_spec)
// 216:           end
// 217:           define_method(:parse_symbol_spec) do |*_|
// 218:             # do nothing
// 219:           end
// 220:           send(:private, :parse_symbol_spec)
// 221:         end
// 222:
// 223:         yield
// 224:       ensure
// 225:         BottleSpecification.class_eval do
// 226:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 227:             send(:alias_method, :method_missing, :old_method_missing)
// 228:             send(:private, :method_missing)
// 229:             send(:undef_method, :old_method_missing)
// 230:           end
// 231:         end
// 232:
// 233:         Module.class_eval do
// 234:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 235:             send(:alias_method, :method_missing, :old_method_missing)
// 236:             send(:private, :method_missing)
// 237:             send(:undef_method, :old_method_missing)
// 238:           end
// 239:         end
// 240:
// 241:         Resource.class_eval do
// 242:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 243:             send(:alias_method, :method_missing, :old_method_missing)
// 244:             send(:private, :method_missing)
// 245:             send(:undef_method, :old_method_missing)
// 246:           end
// 247:         end
// 248:
// 249:         DependencyCollector.class_eval do
// 250:           if method_defined?(:old_parse_symbol_spec) || private_method_defined?(:old_parse_symbol_spec)
// 251:             send(:alias_method, :parse_symbol_spec, :old_parse_symbol_spec)
// 252:             send(:private, :parse_symbol_spec)
// 253:             send(:undef_method, :old_parse_symbol_spec)
// 254:           end
// 255:         end
// 256:         DependencyCollector.clear_cache
// 257:       end
// 258:     end
// 259:   end
// 260: end
