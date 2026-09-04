module dev_cmd

import crypto.sha256
import ruby
import homebrew.utils
import os
import time

// Translated from Homebrew/brew `dev-cmd/bottle.rb`.

pub const bottle_default_domain = 'https://ghcr.io/v2/homebrew/core'
pub const bottle_any_cellar = 'any'
pub const bottle_any_skip_relocation_cellar = 'any_skip_relocation'
pub const bottle_maximum_string_matches = 100

pub struct BottleCellar {
pub:
	value     string
	is_symbol bool
}

pub struct BottleChecksum {
pub:
	tag    string
	digest string
	cellar BottleCellar
}

pub struct BottleSpecification {
pub:
	root_url  string = bottle_default_domain
	rebuild   int
	checksums []BottleChecksum
}

pub struct BottleJsonFormula {
pub:
	name             string
	pkg_version      string
	path             string
	tap_git_path     string
	tap_git_revision string
	tap_git_remote   string
	desc             string
	license          string
	homepage         string
	raw              map[string]ruby.Value
}

pub struct BottleJsonTag {
pub:
	cellar          string
	filename        string
	local_filename  string
	sha256          string
	path_exec_files []string
	all_files       []string
	installed_size  i64
	tab             ruby.Value
	sbom            ruby.Value
	raw             map[string]ruby.Value
}

pub struct BottleJsonBottle {
pub:
	root_url string
	cellar   string
	rebuild  int
	date     string
	tags     map[string]BottleJsonTag
	raw      map[string]ruby.Value
}

pub struct BottleJsonEntry {
pub:
	formula BottleJsonFormula
	bottle  BottleJsonBottle
}

pub struct BottleJsonDocument {
pub:
	entries map[string]BottleJsonEntry
}

pub struct BottleMergeSpecResult {
pub:
	mismatches []string
	checksums  []BottleChecksum
}

pub struct BottleKegInspection {
pub:
	contains bool
	files    []string
	output   []string
}

pub struct BottleTarFormula {
pub:
	available bool
	installed bool
	opt_bin   string
}

pub struct BottleTarSetup {
pub:
	tar               string
	args              []string
	installed_gnu_tar bool
}

pub struct BottleFormula {
pub:
	name                 string
	full_name            string
	pkg_version          string
	prefix               string
	formula_path         string
	local_bottle_path    string
	tap_name             string
	tap_path             string
	tap_git_revision     string
	tap_git_remote       string
	tap_installed        bool = true
	latest_version       bool = true
	built_as_bottle      bool = true
	stable               bool = true
	desc                 string
	license              string
	homepage             string
	dependencies         []string
	runtime_dependencies []string
	old_bottle           BottleSpecification
	upstream_pkg_version string
	upstream_rebuild     int
	source_modified_time i64
}

pub struct BottleCommandOptions {
pub:
	merge            bool
	write            bool
	no_commit        bool
	no_all_checks    bool
	keep_old         bool
	no_rebuild       bool
	json             bool
	only_json_tab    bool
	skip_relocation  bool
	force_core_tap   bool
	verbose          bool
	root_url         string
	root_url_using   string
	committer        string
	output_directory string = '.'
	prefix           string = '/usr/local'
	cellar           string = '/usr/local/Cellar'
	repository       string
	library          string
	bottle_tag       string = 'all'
	sudo_purge       bool
}

pub struct BottleFormulaResult {
pub:
	formula_name    string
	bottle_path     string
	json_path       string
	output          string
	specification   BottleSpecification
	relocatable     bool
	skip_relocation bool
}

pub struct BottleMergeResult {
pub:
	formula_name string
	output       string
	formula_path string
	updated      bool
	all_bottle   bool
	commit       []string
}

pub struct BottleCommandResult {
pub:
	bundler_groups []string
	bottles        []BottleFormulaResult
	merged         []BottleMergeResult
}

pub struct BottleCommand {
pub:
	options    BottleCommandOptions
	formulae   []BottleFormula
	json_files []string
	gnu_tar    BottleTarFormula
}

pub struct BottleOldChecksumsInput {
pub:
	has_bottle_block  bool
	old_keys          []string
	old_specification BottleSpecification
	new_bottle        BottleJsonBottle
}

pub struct BottleOldChecksumsResult {
pub:
	exists    bool
	checksums []BottleChecksum
}

@[heap]
pub struct BottleBoundaryInput {
pub:
	command          BottleCommand
	specification    BottleSpecification
	json_files       []BottleJsonDocument
	old_keys         []string
	new_bottle       BottleJsonBottle
	needle           string
	keg              string
	ignores          []string
	dependency_names []string
	verbose          bool
	mtime            string
	default_tar      bool
	only_json_tab    bool
	gnu_tar          BottleTarFormula
	formula          BottleFormula
	old_checksums    BottleOldChecksumsInput
}

fn bottle_value_string(value ruby.Value) string {
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn bottle_value_int(value ruby.Value) i64 {
	return if value.type_name == 'Integer' { value.int_data } else { value.as_string().i64() }
}

fn bottle_value_strings(value ruby.Value) []string {
	if value.type_name != 'Array' {
		return []
	}
	return (value.as_array() or { return [] }).map(it.as_string())
}

fn bottle_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn bottle_formula_from_value(value ruby.Value) !BottleJsonFormula {
	data := value.as_map()!
	return BottleJsonFormula{
		name: bottle_value_string(data['name'] or { bottle_nil_value() })
		pkg_version: bottle_value_string(data['pkg_version'] or { bottle_nil_value() })
		path: bottle_value_string(data['path'] or { bottle_nil_value() })
		tap_git_path: bottle_value_string(data['tap_git_path'] or { bottle_nil_value() })
		tap_git_revision: bottle_value_string(data['tap_git_revision'] or { bottle_nil_value() })
		tap_git_remote: bottle_value_string(data['tap_git_remote'] or { bottle_nil_value() })
		desc: bottle_value_string(data['desc'] or { bottle_nil_value() })
		license: bottle_value_string(data['license'] or { bottle_nil_value() })
		homepage: bottle_value_string(data['homepage'] or { bottle_nil_value() })
		raw: data.clone()
	}
}

fn bottle_tag_from_value(value ruby.Value, legacy_cellar string) !BottleJsonTag {
	data := value.as_map()!
	cellar := bottle_value_string(data['cellar'] or { ruby.string_value(legacy_cellar) })
	return BottleJsonTag{
		cellar: cellar
		filename: bottle_value_string(data['filename'] or { bottle_nil_value() })
		local_filename: bottle_value_string(data['local_filename'] or { bottle_nil_value() })
		sha256: bottle_value_string(data['sha256'] or { bottle_nil_value() })
		path_exec_files: bottle_value_strings(data['path_exec_files'] or { bottle_nil_value() })
		all_files: bottle_value_strings(data['all_files'] or { bottle_nil_value() })
		installed_size: bottle_value_int(data['installed_size'] or { ruby.int_value(0) })
		tab: data['tab'] or { bottle_nil_value() }
		sbom: data['sbom'] or { bottle_nil_value() }
		raw: data.clone()
	}
}

fn bottle_json_bottle_from_value(value ruby.Value) !BottleJsonBottle {
	data := value.as_map()!
	legacy_cellar := bottle_value_string(data['cellar'] or { bottle_nil_value() })
	tag_values := (data['tags'] or { return error('bottle is missing tags') }).as_map()!
	mut tags := map[string]BottleJsonTag{}
	for tag, tag_value in tag_values {
		tags[tag] = bottle_tag_from_value(tag_value, legacy_cellar)!
	}
	return BottleJsonBottle{
		root_url: bottle_value_string(data['root_url'] or { bottle_nil_value() })
		cellar: legacy_cellar
		rebuild: int(bottle_value_int(data['rebuild'] or { ruby.int_value(0) }))
		date: bottle_value_string(data['date'] or { bottle_nil_value() })
		tags: tags
		raw: data.clone()
	}
}

fn bottle_json_document_from_value(value ruby.Value) !BottleJsonDocument {
	data := value.as_map()!
	mut entries := map[string]BottleJsonEntry{}
	for name, entry_value in data {
		entry := entry_value.as_map()!
		entries[name] = BottleJsonEntry{
			formula: bottle_formula_from_value(entry['formula'] or { return error('${name}: missing formula') })!
			bottle: bottle_json_bottle_from_value(entry['bottle'] or { return error('${name}: missing bottle') })!
		}
	}
	return BottleJsonDocument{ entries: entries }
}

fn bottle_formula_value(formula BottleJsonFormula) ruby.Value {
	mut data := formula.raw.clone()
	data['name'] = ruby.string_value(formula.name)
	data['pkg_version'] = ruby.string_value(formula.pkg_version)
	data['path'] = ruby.string_value(formula.path)
	data['tap_git_path'] = ruby.string_value(formula.tap_git_path)
	data['tap_git_revision'] = ruby.string_value(formula.tap_git_revision)
	data['tap_git_remote'] = ruby.string_value(formula.tap_git_remote)
	data['desc'] = ruby.string_value(formula.desc)
	data['license'] = ruby.string_value(formula.license)
	data['homepage'] = ruby.string_value(formula.homepage)
	return ruby.map_value(data)
}

fn bottle_tag_value(tag BottleJsonTag) ruby.Value {
	mut data := tag.raw.clone()
	data['cellar'] = ruby.string_value(tag.cellar)
	data['filename'] = ruby.string_value(tag.filename)
	data['local_filename'] = ruby.string_value(tag.local_filename)
	data['sha256'] = ruby.string_value(tag.sha256)
	data['path_exec_files'] = ruby.string_array_value(tag.path_exec_files)
	data['all_files'] = ruby.string_array_value(tag.all_files)
	data['installed_size'] = ruby.int_value(tag.installed_size)
	if tag.tab.type_name != '' {
		data['tab'] = tag.tab
	}
	if tag.sbom.type_name != '' {
		data['sbom'] = tag.sbom
	}
	return ruby.map_value(data)
}

fn bottle_json_bottle_value(bottle BottleJsonBottle) ruby.Value {
	mut data := bottle.raw.clone()
	data.delete('cellar')
	data['root_url'] = ruby.string_value(bottle.root_url)
	data['rebuild'] = ruby.int_value(bottle.rebuild)
	if bottle.date != '' {
		data['date'] = ruby.string_value(bottle.date)
	}
	mut tags := map[string]ruby.Value{}
	for tag, value in bottle.tags {
		tags[tag] = bottle_tag_value(value)
	}
	data['tags'] = ruby.map_value(tags)
	return ruby.map_value(data)
}

pub fn bottle_json_document_value(document BottleJsonDocument) ruby.Value {
	mut data := map[string]ruby.Value{}
	for name, entry in document.entries {
		data[name] = ruby.map_value({
			'formula': bottle_formula_value(entry.formula)
			'bottle':  bottle_json_bottle_value(entry.bottle)
		})
	}
	return ruby.map_value(data)
}

pub fn parse_bottle_json_files(filenames []string) ![]BottleJsonDocument {
	mut documents := []BottleJsonDocument{cap: filenames.len}
	for filename in filenames {
		contents := os.read_file(filename) or { return error('${filename}: ${err.msg()}') }
		value := ruby.parse_json_value(contents) or { return error('${filename}: ${err.msg()}') }
		documents << bottle_json_document_from_value(value) or {
			return error('${filename}: ${err.msg()}')
		}
	}
	return documents
}

pub fn merge_bottle_json_files(documents []BottleJsonDocument) BottleJsonDocument {
	mut merged := map[string]BottleJsonEntry{}
	for document in documents {
		for name, incoming in document.entries {
			if current := merged[name] {
				mut tags := current.bottle.tags.clone()
				for tag, value in incoming.bottle.tags {
					tags[tag] = value
				}
				merged[name] = BottleJsonEntry{
					formula: incoming.formula
					bottle: BottleJsonBottle{
						root_url: if incoming.bottle.root_url != '' {
							incoming.bottle.root_url
						} else {
							current.bottle.root_url
						}
						cellar: incoming.bottle.cellar
						rebuild: incoming.bottle.rebuild
						date: if incoming.bottle.date != '' {
							incoming.bottle.date
						} else {
							current.bottle.date
						}
						tags: tags
						raw: incoming.bottle.raw.clone()
					}
				}
			} else {
				merged[name] = incoming
			}
		}
	}
	return BottleJsonDocument{ entries: merged }
}

pub fn cellar_parameter_needed(cellar BottleCellar) bool {
	if cellar.value == '' {
		return false
	}
	return cellar.value !in ['/usr/local/Cellar', '/opt/homebrew/Cellar',
		'/home/linuxbrew/.linuxbrew/Cellar']
}

pub fn generate_bottle_sha256_line(tag string, digest string, cellar BottleCellar,
	tag_column int, digest_column int) string {
	mut line := 'sha256 '
	adjusted_tag_column := tag_column + line.len
	adjusted_digest_column := digest_column + line.len
	if cellar.is_symbol {
		line += 'cellar: :${cellar.value},'
	} else if cellar_parameter_needed(cellar) {
		line += 'cellar: "${cellar.value}",'
	}
	if adjusted_tag_column > line.len {
		line += ' '.repeat(adjusted_tag_column - line.len)
	}
	line += '${tag}:'
	if adjusted_digest_column > line.len {
		line += ' '.repeat(adjusted_digest_column - line.len)
	}
	return '${line}"${digest}"'
}

pub fn bottle_output(specification BottleSpecification, root_url_using string) string {
	if specification.checksums.len == 0 {
		return ''
	}
	mut cellar_width := 0
	mut tag_width := 0
	for checksum in specification.checksums {
		if cellar_parameter_needed(checksum.cellar) {
			shown := if checksum.cellar.is_symbol {
				':${checksum.cellar.value}'
			} else {
				'"${checksum.cellar.value}"'
			}
			if shown.len > cellar_width {
				cellar_width = shown.len
			}
		}
		if checksum.tag.len > tag_width {
			tag_width = checksum.tag.len
		}
	}
	tag_column := if cellar_width == 0 { 0 } else { 'cellar: '.len + cellar_width + ', '.len }
	digest_column := tag_column + tag_width + 2
	mut lines := ['  bottle do']
	if specification.root_url != '' && specification.root_url != bottle_default_domain
		&& specification.root_url != '${bottle_default_domain}/bottles' {
		if root_url_using == '' {
			lines << '    root_url "${specification.root_url}"'
		} else {
			lines << '    root_url "${specification.root_url}",'
			lines << '      using: ${root_url_using}'
		}
	}
	if specification.rebuild > 0 {
		lines << '    rebuild ${specification.rebuild}'
	}
	for checksum in specification.checksums {
		lines << '    ${generate_bottle_sha256_line(checksum.tag, checksum.digest, checksum.cellar, tag_column, digest_column)}'
	}
	lines << '  end'
	return lines.join('\n') + '\n'
}

pub fn merge_bottle_spec(old_keys []string, old_specification BottleSpecification,
	new_bottle BottleJsonBottle) BottleMergeSpecResult {
	mut mismatches := []string{}
	mut checksums := []BottleChecksum{}
	for key in old_keys {
		if key in ['sha256', 'cellar'] {
			continue
		}
		old_value := match key {
			'root_url' { old_specification.root_url }
			'rebuild' { old_specification.rebuild.str() }
			else { '' }
		}
		new_value := match key {
			'root_url' { new_bottle.root_url }
			'rebuild' { new_bottle.rebuild.str() }
			else { '' }
		}
		if old_value == '' || new_value != old_value {
			mismatches << '${key}: old: "${old_value}", new: "${new_value}"'
		}
	}
	if 'sha256' !in old_keys {
		return BottleMergeSpecResult{ mismatches: mismatches, checksums: checksums }
	}
	for old_checksum in old_specification.checksums {
		if new_tag := new_bottle.tags[old_checksum.tag] {
			if new_tag.sha256 != old_checksum.digest {
				mismatches << 'sha256 ${old_checksum.tag}: old: "${old_checksum.digest}", new: "${new_tag.sha256}"'
			} else if new_tag.cellar != old_checksum.cellar.value {
				mismatches << 'cellar ${old_checksum.tag}: old: "${old_checksum.cellar.value}", new: "${new_tag.cellar}"'
			} else {
				checksums << old_checksum
			}
		} else {
			checksums << old_checksum
		}
	}
	return BottleMergeSpecResult{ mismatches: mismatches, checksums: checksums }
}

fn bottle_collect_paths(root string, mut paths []string) ! {
	for name in os.ls(root)! {
		path := os.join_path(root, name)
		paths << path
		if os.is_dir(path) && !os.is_link(path) {
			bottle_collect_paths(path, mut paths)!
		}
	}
}

fn bottle_document_extension(path string) bool {
	return os.file_ext(path).to_lower() in ['.md', '.markdown', '.txt', '.rst', '.html', '.htm',
		'.man', '.info']
}

fn bottle_ignored_match(path string, ignores []string) bool {
	for ignore in ignores {
		if ignore != '' && path.contains(ignore) {
			return true
		}
	}
	return false
}

pub fn keg_contain_absolute_symlink_starting_with(needle string, keg string,
	verbose bool) BottleKegInspection {
	mut paths := []string{}
	bottle_collect_paths(keg, mut paths) or {
		return BottleKegInspection{ output: [err.msg()] }
	}
	mut matches := []string{}
	mut output := []string{}
	for path in paths {
		if !os.is_link(path) {
			continue
		}
		target := os.readlink(path) or { continue }
		if target.starts_with('/') && target.starts_with(needle) {
			matches << path
			if verbose {
				output << '  ${path} -> ${target}'
			}
		}
	}
	if verbose && matches.len > 0 {
		output.prepend('Absolute symlink starting with ${needle}:')
	}
	return BottleKegInspection{ contains: matches.len > 0, files: matches, output: output }
}

pub fn keg_contain(needle string, keg string, ignores []string, dependency_names []string,
	verbose bool) BottleKegInspection {
	mut paths := []string{}
	bottle_collect_paths(keg, mut paths) or {
		return BottleKegInspection{ output: [err.msg()] }
	}
	mut matches := []string{}
	mut output := []string{}
	for path in paths {
		if os.is_dir(path) || os.is_link(path) || bottle_document_extension(path)
			|| bottle_ignored_match(path, ignores) {
			continue
		}
		contents := os.read_bytes(path) or { continue }
		text := contents.bytestr()
		if !text.contains(needle) {
			continue
		}
		// References ending in a known runtime dependency are legitimate only when
		// the dependency name is the complete cellar path component.
		mut legitimate_dependency := false
		for dependency in dependency_names {
			if dependency != '' && text.contains('${needle}/${dependency}/') {
				legitimate_dependency = true
			}
		}
		if legitimate_dependency && text.count(needle) == 1 {
			continue
		}
		matches << path
		if verbose {
			if matches.len == 1 {
				output << "String '${needle}' still exists in these files:"
			}
			output << path
			mut start := 0
			mut emitted := 0
			for emitted < bottle_maximum_string_matches {
				offset := text.index_after(needle, start) or { break }
				output << " --> match '${needle}' at offset 0x${offset.hex()}"
				start = offset + needle.len
				emitted++
			}
			if text.count(needle) > bottle_maximum_string_matches {
				output << 'Only the first ${bottle_maximum_string_matches} matches were output.'
			}
		}
	}
	symlinks := keg_contain_absolute_symlink_starting_with(needle, keg, verbose)
	for file in symlinks.files {
		if file !in matches {
			matches << file
		}
	}
	output << symlinks.output
	return BottleKegInspection{ contains: matches.len > 0, files: matches, output: output }
}

pub fn sudo_purge(enabled bool) !bool {
	if !enabled {
		return false
	}
	result := ruby.run_command('/usr/bin/sudo', ['--non-interactive', '/usr/sbin/purge'])
	if result.exit_code != 0 {
		return error('purge failed (${result.exit_code}): ${result.output.trim_space()}')
	}
	return true
}

pub fn bottle_tar_args() []string {
	// The default bsdtar needs no extra arguments; callers still receive a fresh,
	// typed argument vector which can be extended by OS-specific translations.
	return []string{}
}

pub fn gnu_tar(formula BottleTarFormula) string {
	return os.join_path(formula.opt_bin, 'tar')
}

pub fn reproducible_gnutar_args(mtime string) []string {
	return ['--mtime=${mtime}', '--sort=name', '--owner=0', '--group=0', '--numeric-owner',
		'--format=pax',
		'--pax-option=globexthdr.name=/GlobalHead.%n,exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime']
}

pub fn gnu_tar_formula_ensure_installed_if_needed(formula BottleTarFormula) BottleTarFormula {
	if !formula.available {
		return formula
	}
	return BottleTarFormula{ available: true, installed: true, opt_bin: formula.opt_bin }
}

pub fn setup_tar_and_args(mtime string, only_json_tab bool, default_tar bool,
	formula BottleTarFormula) BottleTarSetup {
	if !only_json_tab || default_tar {
		return BottleTarSetup{ tar: 'tar', args: bottle_tar_args() }
	}
	installed := gnu_tar_formula_ensure_installed_if_needed(formula)
	if !installed.available {
		return BottleTarSetup{ tar: 'tar', args: bottle_tar_args() }
	}
	return BottleTarSetup{
		tar: gnu_tar(installed)
		args: reproducible_gnutar_args(mtime)
		installed_gnu_tar: installed.installed
	}
}

pub fn formula_ignores(formula BottleFormula, cellar string) []string {
	for dependency in formula.dependencies {
		if dependency == 'go' || dependency.starts_with('go@') {
			return [os.join_path(cellar, dependency)]
		}
	}
	return []string{}
}

fn bottle_filename(formula BottleFormula, tag string, rebuild int) string {
	rebuild_suffix := if rebuild > 0 { '.${rebuild}' } else { '' }
	return '${formula.name}--${formula.pkg_version}.${tag}.bottle${rebuild_suffix}.tar.gz'
}

fn bottle_run_checked(program string, arguments []string) ! {
	result := ruby.run_command(program, arguments)
	if result.exit_code != 0 {
		return error('${os.file_name(program)} failed (${result.exit_code}): ${result.output.trim_space()}')
	}
}

fn bottle_archive_formula(formula BottleFormula, destination string, options BottleCommandOptions,
	gnu_tar_formula BottleTarFormula) ! {
	if !os.is_dir(formula.prefix) {
		return error('formula prefix does not exist: ${formula.prefix}')
	}
	tar_path := destination.trim_string_right('.gz')
	mtime := time.unix(if formula.source_modified_time > 0 {
		formula.source_modified_time
	} else {
		1
	}).format_ss()
	setup := setup_tar_and_args(mtime, options.only_json_tab, formula.name == 'gnu-tar', gnu_tar_formula)
	tar_program := if setup.tar == 'tar' {
		os.find_abs_path_of_executable('tar') or { 'tar' }
	} else {
		setup.tar
	}
	mut arguments := ['--create', '--numeric-owner']
	arguments << setup.args
	arguments << ['--file', tar_path, '--directory', os.dir(formula.prefix),
		os.file_name(formula.prefix)]
	sudo_purge(options.sudo_purge)!
	bottle_run_checked(tar_program, arguments)!
	utils.gzip_compress_with_options(tar_path,
		mtime: formula.source_modified_time
		orig_name: '${formula.name}-bottle.tar'
		output: destination
	)!
	sudo_purge(options.sudo_purge)!
}

fn bottle_all_files(root string) ([]string, []string, i64) {
	mut paths := []string{}
	bottle_collect_paths(root, mut paths) or { return []string{}, []string{}, i64(0) }
	mut files := []string{}
	mut executables := []string{}
	mut size := i64(0)
	for path in paths {
		if !os.is_file(path) {
			continue
		}
		relative := path.trim_string_left('${root}/')
		files << relative
		size += os.file_size(path)
		if relative.starts_with('bin/') || relative.starts_with('sbin/') {
			executables << relative
		}
	}
	files.sort()
	executables.sort()
	return files, executables, size
}

pub fn bottle_formula(formula BottleFormula, options BottleCommandOptions,
	gnu_tar_formula BottleTarFormula) !BottleFormulaResult {
	local_bottle := options.json && formula.local_bottle_path != ''
	if !local_bottle && !formula.latest_version {
		return error('Formula not installed or up-to-date: ${formula.full_name}')
	}
	if !local_bottle && !formula.built_as_bottle {
		return error('Formula was not installed with `--build-bottle`: ${formula.full_name}')
	}
	if formula.tap_name == '' && !options.force_core_tap {
		return error('Formula not from core or any installed taps: ${formula.full_name}')
	}
	if !formula.tap_installed {
		return error('Tap is not installed: ${formula.tap_name}')
	}
	if !formula.stable {
		return error('Formula has no stable version: ${formula.full_name}')
	}
	mut rebuild := 0
	if local_bottle {
		parts := os.file_name(formula.local_bottle_path).split('.bottle.')
		if parts.len == 2 {
			tail := parts[1].split('.')
			if tail.len > 3 {
				rebuild = tail[1].int()
			}
		}
	} else if options.keep_old {
		rebuild = formula.old_bottle.rebuild
	} else if !options.no_rebuild && formula.upstream_pkg_version == formula.pkg_version {
		rebuild = formula.upstream_rebuild + 1
	}
	tag := options.bottle_tag
	filename := bottle_filename(formula, tag, rebuild)
	output_directory := if options.output_directory == '' { '.' } else { options.output_directory }
	os.mkdir_all(output_directory)!
	bottle_path := if local_bottle {
		formula.local_bottle_path
	} else {
		os.join_path(output_directory, filename)
	}
	if !local_bottle {
		bottle_archive_formula(formula, bottle_path, options, gnu_tar_formula)!
	}
	if !os.is_file(bottle_path) {
		return error('bottle does not exist: ${bottle_path}')
	}
	mut relocatable := true
	mut skip_relocation := options.skip_relocation
	if !local_bottle && !options.skip_relocation {
		mut ignores := ['/include/', '.c', '.cc', '.cpp', '.h', '.hpp']
		ignores << formula_ignores(formula, options.cellar)
		mut runtime_names := [formula.name]
		runtime_names << formula.runtime_dependencies
		for needle in [options.repository, options.prefix, options.cellar, options.library] {
			if needle != ''
				&& keg_contain(needle, formula.prefix, ignores, runtime_names, options.verbose).contains {
				relocatable = false
			}
		}
		skip_relocation = relocatable
	}
	cellar := if relocatable {
		BottleCellar{
			value: if skip_relocation {
				bottle_any_skip_relocation_cellar
			} else {
				bottle_any_cellar
			}
			is_symbol: true
		}
	} else {
		BottleCellar{ value: options.cellar }
	}
	digest := sha256.sum256(os.read_bytes(bottle_path)!).hex()
	root_url := if options.root_url == '' { bottle_default_domain } else { options.root_url }
	specification := BottleSpecification{
		root_url: root_url
		rebuild: rebuild
		checksums: [BottleChecksum{ tag: tag, digest: digest, cellar: cellar }]
	}
	if options.keep_old && formula.old_bottle.checksums.len > 0
		&& (formula.old_bottle.root_url != specification.root_url
			|| formula.old_bottle.rebuild != specification.rebuild) {
		return error('`--keep-old` was passed but root_url or rebuild changed')
	}
	output := bottle_output(specification, options.root_url_using)
	mut json_path := ''
	if options.json {
		files, executables, installed_size := bottle_all_files(formula.prefix)
		tag_data := BottleJsonTag{
			cellar: cellar.value
			filename: filename
			local_filename: filename
			sha256: digest
			path_exec_files: executables
			all_files: files
			installed_size: installed_size
			tab: ruby.map_value({})
			sbom: ruby.map_value({})
		}
		document := BottleJsonDocument{
			entries: {
				formula.full_name: BottleJsonEntry{
					formula: BottleJsonFormula{
						name: formula.name
						pkg_version: formula.pkg_version
						path: formula.formula_path
						tap_git_path: formula.formula_path.trim_string_left('${formula.tap_path}/')
						tap_git_revision: formula.tap_git_revision
						tap_git_remote: formula.tap_git_remote
						desc: formula.desc
						license: formula.license
						homepage: formula.homepage
					}
					bottle: BottleJsonBottle{
						root_url: root_url
						cellar: cellar.value
						rebuild: rebuild
						date: time.now().format_rfc3339()
						tags: {
							tag: tag_data
						}
					}
				}
			}
		}
		json_path = os.join_path(output_directory, '${filename}.json')
		os.write_file(json_path, ruby.json_value_to_string(bottle_json_document_value(document)))!
	}
	return BottleFormulaResult{
		formula_name: formula.full_name
		bottle_path: bottle_path
		json_path: json_path
		output: output
		specification: specification
		relocatable: relocatable
		skip_relocation: skip_relocation
	}
}

fn bottle_cellar_from_json(value string) BottleCellar {
	return BottleCellar{
		value: value
		is_symbol: value in [bottle_any_cellar, bottle_any_skip_relocation_cellar]
	}
}

fn bottle_source_has_block(source string) bool {
	return source.split_into_lines().any(it.trim_space() == 'bottle do')
}

fn bottle_replace_or_add_block(source string, output string) string {
	lines := source.split_into_lines()
	mut start := -1
	mut finish := -1
	for index, line in lines {
		if line.trim_space() == 'bottle do' {
			start = index
			mut depth := 1
			for inner in index + 1 .. lines.len {
				trimmed := lines[inner].trim_space()
				if trimmed.ends_with(' do') {
					depth++
				} else if trimmed == 'end' {
					depth--
					if depth == 0 {
						finish = inner
						break
					}
				}
			}
			break
		}
	}
	block := output.trim_right('\n').split_into_lines()
	if start >= 0 && finish >= start {
		mut replaced := lines[..start].clone()
		replaced << block
		replaced << lines[finish + 1..]
		return replaced.join('\n') + '\n'
	}
	mut insertion := lines.len
	for index := lines.len - 1; index >= 0; index-- {
		if lines[index].trim_space() == 'end' {
			insertion = index
			break
		}
	}
	mut added := lines[..insertion].clone()
	added << ''
	added << block
	added << lines[insertion..]
	return added.join('\n') + '\n'
}

pub fn old_checksums(input BottleOldChecksumsInput) !BottleOldChecksumsResult {
	if !input.has_bottle_block {
		return BottleOldChecksumsResult{}
	}
	if input.old_keys.len == 0 {
		return BottleOldChecksumsResult{ exists: true }
	}
	merged := merge_bottle_spec(input.old_keys, input.old_specification, input.new_bottle)
	if merged.mismatches.len > 0 {
		return error('`--keep-old` was passed but there are changes in:\n${merged.mismatches.join('\n')}')
	}
	return BottleOldChecksumsResult{ exists: true, checksums: merged.checksums }
}

fn bottle_tags_identical(tags map[string]BottleJsonTag) bool {
	mut identity := ''
	for _, tag in tags {
		current := '${tag.cellar}-${tag.sha256}'
		if identity == '' {
			identity = current
		} else if current != identity {
			return false
		}
	}
	return tags.len > 1
}

pub fn merge_bottles(command BottleCommand) ![]BottleMergeResult {
	documents := parse_bottle_json_files(command.json_files)!
	document := merge_bottle_json_files(documents)
	mut results := []BottleMergeResult{}
	for formula_name, entry in document.entries {
		all_bottle := !command.options.no_all_checks && bottle_tags_identical(entry.bottle.tags)
		mut checksums := []BottleChecksum{}
		for tag, tag_data in entry.bottle.tags {
			checksums << BottleChecksum{
				tag: if all_bottle { 'all' } else { tag }
				digest: tag_data.sha256
				cellar: bottle_cellar_from_json(tag_data.cellar)
			}
			if all_bottle {
				break
			}
		}
		checksums.sort(a.tag < b.tag)
		mut specification := BottleSpecification{
			root_url: entry.bottle.root_url
			rebuild: entry.bottle.rebuild
			checksums: checksums
		}
		mut formula_path := entry.formula.path
		if formula_path != '' && !os.is_abs_path(formula_path) && command.options.repository != '' {
			formula_path = os.join_path(command.options.repository, formula_path)
		}
		mut updated := false
		mut commit := []string{}
		if command.options.write {
			if formula_path == '' || !os.is_file(formula_path) {
				return error('${formula_name}: formula file does not exist: ${formula_path}')
			}
			source := os.read_file(formula_path)!
			if command.options.keep_old && bottle_source_has_block(source) {
				old_formula := command.formulae.filter(it.full_name == formula_name)
				if old_formula.len > 0 {
					preserved := old_checksums(BottleOldChecksumsInput{
						has_bottle_block: true
						old_keys: ['root_url', 'rebuild', 'sha256']
						old_specification: old_formula[0].old_bottle
						new_bottle: entry.bottle
					})!
					if preserved.exists {
						mut combined_checksums := specification.checksums.clone()
						combined_checksums << preserved.checksums
						specification = BottleSpecification{
							root_url: specification.root_url
							rebuild: specification.rebuild
							checksums: combined_checksums
						}
					}
				}
			}
			output := bottle_output(specification, command.options.root_url_using)
			os.write_file(formula_path, bottle_replace_or_add_block(source, output))!
			updated = true
			if !command.options.no_commit {
				commit = ['git', 'commit', '--no-edit', '--verbose', '--message=${entry.formula.name}: ${if bottle_source_has_block(source) {
					'update'
				} else {
					'add'
				}} ${entry.formula.pkg_version} bottle.', '--', formula_path]
			}
		}
		results << BottleMergeResult{
			formula_name: formula_name
			output: bottle_output(specification, command.options.root_url_using)
			formula_path: formula_path
			updated: updated
			all_bottle: all_bottle
			commit: commit
		}
	}
	results.sort(a.formula_name < b.formula_name)
	return results
}

pub fn run_bottle_command(command BottleCommand) !BottleCommandResult {
	if command.options.merge {
		return BottleCommandResult{
			bundler_groups: ['ast']
			merged: merge_bottles(command)!
		}
	}
	mut results := []BottleFormulaResult{}
	for formula in command.formulae {
		results << bottle_formula(formula, command.options, command.gnu_tar)!
	}
	return BottleCommandResult{ bundler_groups: ['bottle'], bottles: results }
}

pub fn bottle_boundary_input(input &BottleBoundaryInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Bottle::Input', '', {
		'bottle_input_address': u64(voidptr(input)).str()
	})
}

fn bottle_boundary_from_value(value ruby.Value) &BottleBoundaryInput {
	address := value.attributes['bottle_input_address'] or { panic('invalid Bottle input') }
	return unsafe { &BottleBoundaryInput(voidptr(address.u64())) }
}

fn bottle_cellar_from_value(value ruby.Value) BottleCellar {
	return BottleCellar{ value: value.as_string(), is_symbol: value.type_name == 'Symbol' }
}

fn bottle_checksum_value(checksum BottleChecksum) ruby.Value {
	return ruby.map_value({
		'tag':    ruby.string_value(checksum.tag)
		'digest': ruby.string_value(checksum.digest)
		'cellar': ruby.structured_value(if checksum.cellar.is_symbol {
			'Symbol'
		} else {
			'String'
		}, checksum.cellar.value, {})
	})
}

fn bottle_specification_value(specification BottleSpecification) ruby.Value {
	return ruby.map_value({
		'root_url':  ruby.string_value(specification.root_url)
		'rebuild':   ruby.int_value(specification.rebuild)
		'checksums': ruby.array_value(specification.checksums.map(bottle_checksum_value(it)))
	})
}

fn bottle_formula_result_value(result BottleFormulaResult) ruby.Value {
	return ruby.map_value({
		'formula_name':    ruby.string_value(result.formula_name)
		'bottle_path':     ruby.string_value(result.bottle_path)
		'json_path':       ruby.string_value(result.json_path)
		'output':          ruby.string_value(result.output)
		'specification':   bottle_specification_value(result.specification)
		'relocatable':     ruby.bool_value(result.relocatable)
		'skip_relocation': ruby.bool_value(result.skip_relocation)
	})
}

fn bottle_merge_result_value(result BottleMergeResult) ruby.Value {
	return ruby.map_value({
		'formula_name': ruby.string_value(result.formula_name)
		'output':       ruby.string_value(result.output)
		'formula_path': ruby.string_value(result.formula_path)
		'updated':      ruby.bool_value(result.updated)
		'all_bottle':   ruby.bool_value(result.all_bottle)
		'commit':       ruby.string_array_value(result.commit)
	})
}

fn bottle_command_result_value(result BottleCommandResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups': ruby.string_array_value(result.bundler_groups)
		'bottles':        ruby.array_value(result.bottles.map(bottle_formula_result_value(it)))
		'merged':         ruby.array_value(result.merged.map(bottle_merge_result_value(it)))
	})
}

fn bottle_inspection_value(result BottleKegInspection) ruby.Value {
	return ruby.map_value({
		'contains': ruby.bool_value(result.contains)
		'files':    ruby.string_array_value(result.files)
		'output':   ruby.string_array_value(result.output)
	})
}
