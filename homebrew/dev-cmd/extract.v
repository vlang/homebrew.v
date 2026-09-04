module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/extract.rb`.

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
	result        ruby.Value
	error_message string
}

pub fn extract_input_boundary(input &ExtractInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Extract::Input', '', {
		'extract_input_address': u64(voidptr(input)).str()
	})
}

fn extract_input_from_value(value ruby.Value) !&ExtractInput {
	address := value.attributes['extract_input_address'] or {
		return error('invalid Extract input')
	}
	return unsafe { &ExtractInput(voidptr(address.u64())) }
}

pub fn extract_formula_revision_input_boundary(input &ExtractFormulaRevisionInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Extract::FormulaRevisionInput', '', {
		'extract_formula_revision_input_address': u64(voidptr(input)).str()
	})
}

fn extract_formula_revision_input_from_value(value ruby.Value) !&ExtractFormulaRevisionInput {
	address := value.attributes['extract_formula_revision_input_address'] or {
		return error('invalid Extract formula revision input')
	}
	return unsafe { &ExtractFormulaRevisionInput(voidptr(address.u64())) }
}

pub fn extract_monkey_patch_input_boundary(input &ExtractMonkeyPatchInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Extract::MonkeyPatchInput', '', {
		'extract_monkey_patch_input_address': u64(voidptr(input)).str()
	})
}

fn extract_monkey_patch_input_from_value(value ruby.Value) !&ExtractMonkeyPatchInput {
	address := value.attributes['extract_monkey_patch_input_address'] or {
		return error('invalid Extract monkey patch input')
	}
	return unsafe { &ExtractMonkeyPatchInput(voidptr(address.u64())) }
}

fn extract_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn extract_formula_value(formula ExtractFormula) ruby.Value {
	return ruby.map_value({
		'name':     ruby.string_value(formula.name)
		'path':     ruby.object_value('Pathname', formula.path)
		'version':  ruby.string_value(formula.version)
		'contents': ruby.string_value(formula.contents)
	})
}

fn extract_result_value(result ExtractResult) ruby.Value {
	return ruby.map_value({
		'name':                      ruby.string_value(result.name)
		'version':                   ruby.string_value(result.version)
		'formula_version':           ruby.string_value(result.formula_version)
		'revision':                  ruby.string_value(result.revision)
		'path':                      ruby.object_value('Pathname', result.path)
		'contents':                  ruby.string_value(result.contents)
		'stdout':                    ruby.string_array_value(result.stdout)
		'debug':                     ruby.string_array_value(result.debug)
		'destination_tap_installed': ruby.bool_value(result.destination_tap_installed)
		'overwrote':                 ruby.bool_value(result.overwrote)
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

pub fn with_extract_monkey_patch(mut state ExtractMonkeyPatchState, result ruby.Value,
	error_message string) !ruby.Value {
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

fn extract_patch_alias(args []ruby.Value, target string) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'monkey patch input is required')
	}
	mut input := extract_monkey_patch_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
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
	return ruby.structured_value('AliasMethod', target, {
		'target': target
		'action': 'save'
	})
}

fn extract_patch_restore(args []ruby.Value, target string) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'monkey patch input is required')
	}
	mut input := extract_monkey_patch_input_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
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
	return ruby.structured_value('AliasMethod', target, {
		'target': target
		'action': 'restore'
	})
}
