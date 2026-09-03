module homebrew

import brew_runtime

// Translated from Homebrew/brew `patch.rb`.
// The original source is retained below.

// PatchResolution is the typed V representation of the CycloneDX resolution
// classification returned by Patch.resolves_type.
pub enum PatchResolution {
	security
	defect
}

pub fn (resolution PatchResolution) value() string {
	return match resolution {
		.security { 'security' }
		.defect { 'defect' }
	}
}

// PatchType translates the source-diff values in Patch::TYPES.
pub enum PatchType {
	unofficial
	backport
	cherry_pick
}

pub fn (patch_type PatchType) description() string {
	return match patch_type {
		.unofficial {
			'A patch that has not been developed by the upstream maintainers (e.g. a Homebrew- or distribution-specific build fix).'
		}
		.backport {
			'A patch that takes code from a newer version of the software and applies it to the older version Homebrew ships (e.g. an unreleased upstream security fix).'
		}
		.cherry_pick {
			'A patch created by selectively applying upstream commits that are not strictly from a newer release (e.g. a fix from a maintenance branch).'
		}
	}
}

// extract_cves scans all strings using Patch::CVE_PATTERN, normalises matches,
// and retains only the first occurrence of each CVE.
pub fn extract_cves(strings []string) []string {
	mut cves := []string{}
	for text in strings {
		mut index := 0
		for index + 12 <= text.len {
			if !matches_cve_prefix(text, index) {
				index++
				continue
			}
			mut year_start := index + 3
			if year_start < text.len && text[year_start] == `-` {
				year_start++
			}
			if year_start + 5 > text.len || !digits_between(text, year_start, year_start + 4) || text[year_start + 4] != `-` {
				index++
				continue
			}
			id_start := year_start + 5
			mut id_end := id_start
			for id_end < text.len && is_ascii_digit(text[id_end]) {
				id_end++
			}
			if id_end - id_start < 4 {
				index++
				continue
			}
			cve := 'CVE-${text[year_start..year_start + 4]}-${text[id_start..id_end]}'
			if cve !in cves {
				cves << cve
			}
			index = id_end
		}
	}
	return cves
}

fn matches_cve_prefix(text string, index int) bool {
	if index + 3 > text.len {
		return false
	}
	return ascii_lower(text[index]) == `c` && ascii_lower(text[index + 1]) == `v` && ascii_lower(text[index + 2]) == `e`
}

fn ascii_lower(character u8) u8 {
	return if character >= `A` && character <= `Z` { character + 32 } else { character }
}

fn is_ascii_digit(character u8) bool {
	return character >= `0` && character <= `9`
}

fn digits_between(text string, start int, end int) bool {
	if start < 0 || end > text.len || start >= end {
		return false
	}
	for index in start .. end {
		if !is_ascii_digit(text[index]) {
			return false
		}
	}
	return true
}

// classify_resolve translates Patch.resolves_type without losing its type in
// V. resolves_type below retains the Ruby string-returning API.
pub fn classify_resolve(id string) PatchResolution {
	if is_cve_identifier(id) || is_ghsa_identifier(id) || is_osv_identifier(id) {
		return .security
	}
	return .defect
}

pub fn resolves_type(id string) string {
	return classify_resolve(id).value()
}

fn is_cve_identifier(id string) bool {
	return id.len >= 13 && id.starts_with('CVE-') && digits_between(id, 4, 8) && id[8] == `-` && id.len - 9 >= 4 && digits_between(id, 9, id.len)
}

fn is_ghsa_identifier(id string) bool {
	if id.len != 19 || !id.starts_with('GHSA') {
		return false
	}
	allowed := '23456789cfghjmpqrvwx'
	for group in 0 .. 3 {
		separator := 4 + group * 5
		if id[separator] != `-` {
			return false
		}
		for index in separator + 1 .. separator + 5 {
			if !allowed.contains(id[index].ascii_str()) {
				return false
			}
		}
	}
	return true
}

fn is_osv_identifier(id string) bool {
	if id.len < 10 || !id.starts_with('OSV-') || !digits_between(id, 4, 8) || id[8] != `-` {
		return false
	}
	return digits_between(id, 9, id.len)
}

const patch_shell = '/bin/sh'
const patch_environment = '/usr/bin/env'
const patch_dry_run_script = 'cd -- "\$1" && printf %s "\$2" | patch -g 0 -f "-\$3" --dry-run 2>&1'
const patch_apply_script = 'cd -- "\$1" && printf %s "\$2" | patch -g 0 -f "-\$3" 2>&1'

// ensure_patch_targets_within translates Patch.ensure_targets_within!. The
// dry-run determines the same target names as patch itself; selected diff
// headers are also checked before execution so a malformed dry-run can never
// turn target parsing into an escape bypass.
pub fn ensure_patch_targets_within(text string, strip string, base string) ! {
	if !brew_runtime.is_dir(base) {
		return error('Patch base directory does not exist: ${base}')
	}
	for target in selected_patch_targets(text, strip) {
		ensure_patch_target_child(base, target)!
	}
	result := run_patch_process(patch_dry_run_script, base, text, strip)
	for line in result.output.split_into_lines() {
		mut target := ''
		if line.starts_with('patching file ') {
			target = line.all_after('patching file ')
		} else if line.starts_with('checking file ') {
			target = line.all_after('checking file ')
		} else {
			continue
		}
		target = target.trim_space()
		if target.len >= 2 && target.starts_with("'") && target.ends_with("'") {
			target = target[1..target.len - 1]
		}
		ensure_patch_target_child(base, target)!
	}
}

fn run_patch_process(script string, base string, text string, strip string) brew_runtime.CommandResult {
	return brew_runtime.run_command(patch_environment, ['LC_ALL=C', 'LANG=C', patch_shell, '-c',
		script, 'brew-v-patch', base, text, strip])
}

fn selected_patch_targets(text string, strip string) []string {
	lines := text.split_into_lines()
	mut targets := []string{}
	mut index := 0
	for index < lines.len {
		line := lines[index]
		if line.starts_with('Index: ') {
			targets << strip_patch_path(line.all_after('Index: ').trim_space(), strip)
			index++
			continue
		}
		if line.starts_with('==== ') && line.ends_with(' ====') {
			path := line[5..line.len - 5].trim_space()
			targets << strip_patch_path(path, strip)
			index++
			continue
		}
		if index + 1 < lines.len && line.starts_with('--- ') && lines[index + 1].starts_with('+++ ') {
			old_path := diff_header_path(line[4..])
			new_path := diff_header_path(lines[index + 1][4..])
			selected := if new_path == '/dev/null' { old_path } else { new_path }
			if selected != '/dev/null' {
				targets << strip_patch_path(selected, strip)
			}
			index += 2
			continue
		}
		if index + 1 < lines.len && line.starts_with('*** ') && lines[index + 1].starts_with('--- ') {
			old_path := diff_header_path(line[4..])
			new_path := diff_header_path(lines[index + 1][4..])
			selected := if new_path == '/dev/null' { old_path } else { new_path }
			if selected != '/dev/null' {
				targets << strip_patch_path(selected, strip)
			}
			index += 2
			continue
		}
		index++
	}
	return targets.filter(it != '')
}

fn diff_header_path(header string) string {
	tab_index := header.index_u8(`\t`)
	if tab_index >= 0 {
		return header[..tab_index]
	}
	return header.trim_space()
}

fn strip_patch_path(path string, strip string) string {
	if !strip.starts_with('p') {
		return path
	}
	strip_count := strip[1..].int()
	if strip_count <= 0 {
		return path
	}
	mut remaining := path
	for _ in 0 .. strip_count {
		slash := remaining.index_u8(`/`)
		if slash < 0 {
			return ''
		}
		remaining = remaining[slash + 1..]
	}
	return remaining
}

fn ensure_patch_target_child(base string, target string) ! {
	base_path := lexical_absolute_path(brew_runtime.real_path(base), '')
	target_path := lexical_absolute_path(base_path, target)
	if target_path != base_path && !target_path.starts_with('${base_path}/') {
		return error('Patch target path escapes the staged source tree: ${target}')
	}
}

fn lexical_absolute_path(base string, path string) string {
	combined := if path.starts_with('/') {
		path
	} else if path == '' {
		base
	} else {
		'${base}/${path}'
	}
	mut components := []string{}
	for component in combined.split('/') {
		if component == '' || component == '.' {
			continue
		}
		if component == '..' {
			if components.len > 0 {
				components.delete_last()
			}
			continue
		}
		components << component
	}
	return '/' + components.join('/')
}

// apply_patch_text validates and then applies embedded patch contents through
// the shared process boundary. Values are positional shell arguments rather
// than interpolated script text.
pub fn apply_patch_text(text string, strip string, base string, homebrew_prefix string) ! {
	data := text.replace('@@HOMEBREW_PREFIX@@', homebrew_prefix)
	ensure_patch_targets_within(data, strip, base)!
	result := run_patch_process(patch_apply_script, base, data, strip)
	if result.exit_code != 0 {
		return error('patch failed: ${result.output.trim_space()}')
	}
}

// PatchKind identifies the concrete patch implementation selected by
// Patch.create without depending on the still-generic class translations.
pub enum PatchKind {
	external
	local
	string
	data
}

// PatchArgumentKind preserves the Ruby distinction between Symbol and String
// arguments. That distinction determines whether the first argument is patch
// contents or a strip level.
pub enum PatchArgumentKind {
	symbol
	string
	data
}

pub enum PatchSourceKind {
	none
	string
	data
}

// PatchResourceModel is the Resource::Patch state consumed by Patch.create.
// Mutable patch_files mirrors Resource::Patch#apply, including ordered de-duping.
pub struct PatchResourceModel {
pub mut:
	url                  string
	file                 string
	has_file             bool
	directory            string
	checksum             string
	patch_files          []string
	explicit_resolves    []string
	has_patch_type       bool
	patch_type_name      string
	cached_download_path string
}

pub fn (mut resource PatchResourceModel) apply(paths ...string) {
	for path in paths {
		if path !in resource.patch_files {
			resource.patch_files << path
		}
	}
}

pub struct PatchFactoryRequest {
pub:
	strip       string = 'p1'
	strip_kind  PatchArgumentKind = .symbol
	source_kind PatchSourceKind
	source      string
	resource    PatchResourceModel
}

// PatchModel is a typed, closed representation of every result of
// Patch.create. Only fields applicable to kind are populated.
pub struct PatchModel {
pub mut:
	resource PatchResourceModel
pub:
	kind           PatchKind
	strip          string
	text           string
	file           string
	directory      string
	has_patch_type bool
	patch_type     PatchType
}

pub fn (kind PatchKind) value() string {
	return match kind {
		.external { 'ExternalPatch' }
		.local { 'LocalPatch' }
		.string { 'StringPatch' }
		.data { 'DATAPatch' }
	}
}

pub fn parse_patch_type(name string) !PatchType {
	return match name {
		'unofficial' { .unofficial }
		'backport' { .backport }
		'cherry_pick' { .cherry_pick }
		else {
			return error('Patch type must be one of unofficial, backport, cherry_pick')
		}
	}
}

// valid_local_patch_path translates LocalPatch.valid_path? for the factory's
// file branch, normalising dot components before checking repository escape.
pub fn valid_local_patch_path(path string) bool {
	if path.trim_space() == '' || path.ends_with('/') || path.starts_with('/') {
		return false
	}
	mut components := []string{}
	for component in path.split('/') {
		if component == '' || component == '.' {
			continue
		}
		if component == '..' {
			if components.len == 0 {
				return false
			}
			components.delete_last()
			continue
		}
		components << component
	}
	return components.len > 0
}

pub fn create_patch(request PatchFactoryRequest) !PatchModel {
	if request.strip_kind == .data {
		return PatchModel{
			kind: .data
			strip: 'p1'
		}
	}
	if request.strip_kind == .string {
		return PatchModel{
			kind: .string
			strip: 'p1'
			text: request.strip
		}
	}
	if request.source_kind == .data {
		return PatchModel{
			kind: .data
			strip: request.strip
		}
	}
	if request.source_kind == .string {
		return PatchModel{
			kind: .string
			strip: request.strip
			text: request.source
		}
	}
	resource := request.resource
	mut has_patch_type := false
	mut patch_type := PatchType.unofficial
	if resource.has_patch_type {
		patch_type = parse_patch_type(resource.patch_type_name)!
		has_patch_type = true
	}
	if resource.has_file {
		if !valid_local_patch_path(resource.file) {
			return error('Patch file must be a relative path within the repository.')
		}
		if resource.url != '' {
			return error('Patch cannot have both `file` and `url`.')
		}
		if resource.checksum != '' {
			return error('Patch cannot use `sha256` with `file`.')
		}
		if resource.patch_files.len > 0 {
			return error('Patch cannot use `apply` with `file`.')
		}
		return PatchModel{
			kind: .local
			strip: request.strip
			file: resource.file
			directory: resource.directory
			resource: resource
			has_patch_type: has_patch_type
			patch_type: patch_type
		}
	}
	return PatchModel{
		kind: .external
		strip: request.strip
		resource: resource
		has_patch_type: has_patch_type
		patch_type: patch_type
	}
}

pub fn (patch PatchModel) is_external() bool {
	return patch.kind == .external
}

pub fn (patch PatchModel) url() string {
	return patch.resource.url
}

pub fn (patch PatchModel) patch_files() []string {
	return patch.resource.patch_files.clone()
}

pub fn (patch PatchModel) cached_download() string {
	return patch.resource.cached_download_path
}

pub fn (patch PatchModel) resolves() []string {
	mut resolved := patch.resource.explicit_resolves.clone()
	inferred := if patch.kind == .local {
		extract_cves([patch.file])
	} else if patch.kind == .external {
		mut sources := [patch.resource.url]
		sources << patch.resource.patch_files
		extract_cves(sources)
	} else {
		[]string{}
	}
	for identifier in inferred {
		if identifier !in resolved {
			resolved << identifier
		}
	}
	return resolved
}

pub fn (patch PatchModel) inspect() string {
	return match patch.kind {
		.external { '#<ExternalPatch: :${patch.strip} "${patch.resource.url}">' }
		.local { '#<LocalPatch: :${patch.strip} "${patch.file}">' }
		.string { '#<StringPatch: :${patch.strip}>' }
		.data { '#<DATAPatch: :${patch.strip}>' }
	}
}

pub fn (patch PatchModel) apply(base string, homebrew_prefix string) ! {
	if patch.kind != .string {
		return error('Only StringPatch can be applied without a resource owner')
	}
	apply_patch_text(patch.text, patch.strip, base, homebrew_prefix)!
}

const patch_value_separator = '\x1f'

// patch_model_value and patch_model_from_value bridge translated generic Ruby
// callers while preserving the factory's concrete V representation.
pub fn patch_model_value(patch PatchModel) brew_runtime.Value {
	return brew_runtime.structured_value(patch.kind.value(), patch.inspect(), {
		'kind':            patch.kind.value()
		'strip':           patch.strip
		'text':            patch.text
		'file':            patch.file
		'has_file':        patch.resource.has_file.str()
		'directory':       patch.directory
		'url':             patch.resource.url
		'checksum':        patch.resource.checksum
		'patch_files':     patch.resource.patch_files.join(patch_value_separator)
		'resolves':        patch.resource.explicit_resolves.join(patch_value_separator)
		'has_patch_type':  patch.has_patch_type.str()
		'patch_type':      if patch.has_patch_type { patch.patch_type.str() } else { '' }
		'cached_download': patch.resource.cached_download_path
	})
}

pub fn patch_model_from_value(value brew_runtime.Value) !PatchModel {
	kind := match value.attribute('kind')! {
		'ExternalPatch' { PatchKind.external }
		'LocalPatch' { PatchKind.local }
		'StringPatch' { PatchKind.string }
		'DATAPatch' { PatchKind.data }
		else {
			return error('unknown patch model ${value.type_name}')
		}
	}
	has_patch_type := value.attribute('has_patch_type')! == 'true'
	patch_type := if has_patch_type {
		parse_patch_type(value.attribute('patch_type')!)!
	} else {
		PatchType.unofficial
	}
	return PatchModel{
		kind: kind
		strip: value.attribute('strip')!
		text: value.attribute('text')!
		file: value.attribute('file')!
		directory: value.attribute('directory')!
		has_patch_type: has_patch_type
		patch_type: patch_type
		resource: PatchResourceModel{
			url: value.attribute('url')!
			file: value.attribute('file')!
			has_file: value.attribute('has_file')! == 'true'
			directory: value.attribute('directory')!
			checksum: value.attribute('checksum')!
			patch_files: split_patch_value_list(value.attribute('patch_files')!)
			explicit_resolves: split_patch_value_list(value.attribute('resolves')!)
			has_patch_type: has_patch_type
			patch_type_name: value.attribute('patch_type')!
			cached_download_path: value.attribute('cached_download')!
		}
	}
}

fn split_patch_value_list(value string) []string {
	return if value == '' { []string{} } else { value.split(patch_value_separator) }
}

fn patch_request_from_values(args []brew_runtime.Value) !PatchFactoryRequest {
	if args.len == 0 {
		return error('Patch.create requires strip and src')
	}
	strip_value := args[0]
	mut request := PatchFactoryRequest{
		strip: strip_value.as_string()
	}
	if strip_value.type_name == 'String' {
		request = PatchFactoryRequest{
			strip: strip_value.as_string()
			strip_kind: .string
		}
	} else if strip_value.as_string() == 'DATA' {
		request = PatchFactoryRequest{
			strip_kind: .data
		}
	}
	mut source_kind := PatchSourceKind.none
	mut source := ''
	if args.len > 1 && args[1].type_name == 'String' {
		source_kind = .string
		source = args[1].as_string()
	} else if args.len > 1 && args[1].as_string() == 'DATA' {
		source_kind = .data
	}
	mut resource := PatchResourceModel{}
	if args.len > 2 {
		config := args[2].as_map()!
		resource.url = patch_config_string(config, 'url')
		resource.file = patch_config_string(config, 'file')
		resource.has_file = 'file' in config
		resource.directory = patch_config_string(config, 'directory')
		resource.checksum = patch_config_string(config, 'sha256')
		resource.cached_download_path = patch_config_string(config, 'cached_download')
		resource.patch_files = patch_config_strings(config, 'apply')!
		resource.explicit_resolves = patch_config_strings(config, 'resolves')!
		resource.patch_type_name = patch_config_string(config, 'type')
		resource.has_patch_type = resource.patch_type_name != ''
	}
	return PatchFactoryRequest{
		strip: request.strip
		strip_kind: request.strip_kind
		source_kind: source_kind
		source: source
		resource: resource
	}
}

fn patch_config_string(config map[string]brew_runtime.Value, key string) string {
	return if key in config { config[key].as_string() } else { '' }
}

fn patch_config_strings(config map[string]brew_runtime.Value, key string) ![]string {
	if key !in config {
		return []string{}
	}
	if config[key].type_name == 'Array' {
		return config[key].as_array()!.map(it.as_string())
	}
	return [config[key].as_string()]
}

// Ruby method `self.extract_cves(*strings)` at line 31.
pub fn ruby_patch_l31_d1_self_extract_cves(strings ...string) []string {
	return extract_cves(strings)
}

// Ruby method `self.resolves_type(id)` at line 38.
pub fn ruby_patch_l38_d2_self_resolves_type(id string) string {
	return resolves_type(id)
}

// Ruby method `self.ensure_targets_within!(text, strip:, base:)` at line 46.
pub fn ruby_patch_l46_d3_self_ensure_targets_within(text string, strip string, base string) ! {
	ensure_patch_targets_within(text, strip, base)!
}

// Ruby method `self.create(strip, src, &block)` at line 73.
pub fn ruby_patch_l73_d4_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	request := patch_request_from_values(args) or { panic(err) }
	return patch_model_value(create_patch(request) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5: require "data_patch"
// 6: require "external_patch"
// 7: require "string_patch"
// 8: require "local_patch"
// 9: require "utils/path"
// 10: require "utils/popen"
// 11:
// 12: # Helper module for creating patches.
// 13: module Patch
// 14:   CVE_PATTERN = /CVE-?(\d{4})-(\d{4,})/i
// 15:   GHSA_PATTERN = /\AGHSA(-[23456789cfghjmpqrvwx]{4}){3}\z/
// 16:   OSV_PATTERN = /\AOSV-\d{4}-\d+\z/
// 17:   # CycloneDX `pedigree.patches.type` values applicable to source diffs.
// 18:   # `monkey` is omitted: it describes runtime modification, which `patch do` cannot express.
// 19:   # Keep in sync with `PATCH_TYPES` in `Library/Homebrew/rubocops/patches.rb`.
// 20:   TYPES = T.let({
// 21:     unofficial:  "A patch that has not been developed by the upstream maintainers " \
// 22:                  "(e.g. a Homebrew- or distribution-specific build fix).",
// 23:     backport:    "A patch that takes code from a newer version of the software and " \
// 24:                  "applies it to the older version Homebrew ships (e.g. an unreleased " \
// 25:                  "upstream security fix).",
// 26:     cherry_pick: "A patch created by selectively applying upstream commits that are " \
// 27:                  "not strictly from a newer release (e.g. a fix from a maintenance branch).",
// 28:   }.freeze, T::Hash[Symbol, String])
// 29:
// 30:   sig { params(strings: String).returns(T::Array[String]) }
// 31:   def self.extract_cves(*strings)
// 32:     strings.flat_map { |s| s.scan(CVE_PATTERN) }
// 33:            .map { |year, id| "CVE-#{year}-#{id}" }
// 34:            .uniq
// 35:   end
// 36:
// 37:   sig { params(id: String).returns(String) }
// 38:   def self.resolves_type(id)
// 39:     return "security" if id.match?(/\ACVE-\d{4}-\d{4,}\z/) || id.match?(GHSA_PATTERN) || id.match?(OSV_PATTERN)
// 40:
// 41:     "defect"
// 42:   end
// 43:
// 44:   # Reject patch target paths (absolute or `..`-traversing) that escape the staged source tree.
// 45:   sig { params(text: String, strip: T.any(Symbol, String), base: Pathname).void }
// 46:   def self.ensure_targets_within!(text, strip:, base:)
// 47:     # Resolve targets with `patch --dry-run` so containment matches what `patch`
// 48:     # actually writes, covering `Index:`/`====` and non-selected context headers.
// 49:     output = with_env(LC_ALL: "C", LANG: "C") do
// 50:       base.cd do
// 51:         Utils.popen_write("patch", "-g", "0", "-f", "-#{strip}", "--dry-run", err: :out) { |p| p.write(text) }
// 52:       end
// 53:     end
// 54:
// 55:     output.each_line do |line|
// 56:       next unless (target = line.chomp[/\A(?:patching|checking) file (.+)\z/, 1])
// 57:
// 58:       target = target.delete_prefix("'").delete_suffix("'") if target.start_with?("'") && target.end_with?("'")
// 59:       Utils::Path.ensure_child_of!(
// 60:         base, base/target,
// 61:         message: "Patch target path escapes the staged source tree: #{target}"
// 62:       )
// 63:     end
// 64:   end
// 65:
// 66:   sig {
// 67:     params(
// 68:       strip: T.any(Symbol, String),
// 69:       src:   T.nilable(T.any(Symbol, String)),
// 70:       block: T.nilable(T.proc.bind(Resource::Patch).void),
// 71:     ).returns(T.any(EmbeddedPatch, ExternalPatch))
// 72:   }
// 73:   def self.create(strip, src, &block)
// 74:     case strip
// 75:     when :DATA
// 76:       DATAPatch.new(:p1)
// 77:     when String
// 78:       StringPatch.new(:p1, strip)
// 79:     when Symbol
// 80:       case src
// 81:       when :DATA
// 82:         DATAPatch.new(strip)
// 83:       when String
// 84:         StringPatch.new(strip, src)
// 85:       else
// 86:         external_patch = ExternalPatch.new(strip, &block)
// 87:         resource = external_patch.resource
// 88:         if (file = resource.file)
// 89:           raise ArgumentError, "Patch cannot have both `file` and `url`." if resource.url.present?
// 90:           raise ArgumentError, "Patch cannot use `sha256` with `file`." if resource.checksum
// 91:           raise ArgumentError, "Patch cannot use `apply` with `file`." if resource.patch_files.present?
// 92:
// 93:           LocalPatch.new(strip, file, resource.directory, resolves: resource.resolves, type: resource.type)
// 94:         else
// 95:           external_patch
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
