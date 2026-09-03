module dev_cmd

import crypto.sha256
import brew_runtime
import homebrew.utils
import os
import time

// Translated from Homebrew/brew `dev-cmd/bottle.rb`.
// The original source is retained below until every stub has a typed V body.

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
	raw              map[string]brew_runtime.Value
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
	tab             brew_runtime.Value
	sbom            brew_runtime.Value
	raw             map[string]brew_runtime.Value
}

pub struct BottleJsonBottle {
pub:
	root_url string
	cellar   string
	rebuild  int
	date     string
	tags     map[string]BottleJsonTag
	raw      map[string]brew_runtime.Value
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

fn bottle_value_string(value brew_runtime.Value) string {
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn bottle_value_int(value brew_runtime.Value) i64 {
	return if value.type_name == 'Integer' { value.int_data } else { value.as_string().i64() }
}

fn bottle_value_strings(value brew_runtime.Value) []string {
	if value.type_name != 'Array' {
		return []
	}
	return (value.as_array() or { return [] }).map(it.as_string())
}

fn bottle_nil_value() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn bottle_formula_from_value(value brew_runtime.Value) !BottleJsonFormula {
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

fn bottle_tag_from_value(value brew_runtime.Value, legacy_cellar string) !BottleJsonTag {
	data := value.as_map()!
	cellar := bottle_value_string(data['cellar'] or { brew_runtime.string_value(legacy_cellar) })
	return BottleJsonTag{
		cellar: cellar
		filename: bottle_value_string(data['filename'] or { bottle_nil_value() })
		local_filename: bottle_value_string(data['local_filename'] or { bottle_nil_value() })
		sha256: bottle_value_string(data['sha256'] or { bottle_nil_value() })
		path_exec_files: bottle_value_strings(data['path_exec_files'] or { bottle_nil_value() })
		all_files: bottle_value_strings(data['all_files'] or { bottle_nil_value() })
		installed_size: bottle_value_int(data['installed_size'] or { brew_runtime.int_value(0) })
		tab: data['tab'] or { bottle_nil_value() }
		sbom: data['sbom'] or { bottle_nil_value() }
		raw: data.clone()
	}
}

fn bottle_json_bottle_from_value(value brew_runtime.Value) !BottleJsonBottle {
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
		rebuild: int(bottle_value_int(data['rebuild'] or { brew_runtime.int_value(0) }))
		date: bottle_value_string(data['date'] or { bottle_nil_value() })
		tags: tags
		raw: data.clone()
	}
}

fn bottle_json_document_from_value(value brew_runtime.Value) !BottleJsonDocument {
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

fn bottle_formula_value(formula BottleJsonFormula) brew_runtime.Value {
	mut data := formula.raw.clone()
	data['name'] = brew_runtime.string_value(formula.name)
	data['pkg_version'] = brew_runtime.string_value(formula.pkg_version)
	data['path'] = brew_runtime.string_value(formula.path)
	data['tap_git_path'] = brew_runtime.string_value(formula.tap_git_path)
	data['tap_git_revision'] = brew_runtime.string_value(formula.tap_git_revision)
	data['tap_git_remote'] = brew_runtime.string_value(formula.tap_git_remote)
	data['desc'] = brew_runtime.string_value(formula.desc)
	data['license'] = brew_runtime.string_value(formula.license)
	data['homepage'] = brew_runtime.string_value(formula.homepage)
	return brew_runtime.map_value(data)
}

fn bottle_tag_value(tag BottleJsonTag) brew_runtime.Value {
	mut data := tag.raw.clone()
	data['cellar'] = brew_runtime.string_value(tag.cellar)
	data['filename'] = brew_runtime.string_value(tag.filename)
	data['local_filename'] = brew_runtime.string_value(tag.local_filename)
	data['sha256'] = brew_runtime.string_value(tag.sha256)
	data['path_exec_files'] = brew_runtime.string_array_value(tag.path_exec_files)
	data['all_files'] = brew_runtime.string_array_value(tag.all_files)
	data['installed_size'] = brew_runtime.int_value(tag.installed_size)
	if tag.tab.type_name != '' {
		data['tab'] = tag.tab
	}
	if tag.sbom.type_name != '' {
		data['sbom'] = tag.sbom
	}
	return brew_runtime.map_value(data)
}

fn bottle_json_bottle_value(bottle BottleJsonBottle) brew_runtime.Value {
	mut data := bottle.raw.clone()
	data.delete('cellar')
	data['root_url'] = brew_runtime.string_value(bottle.root_url)
	data['rebuild'] = brew_runtime.int_value(bottle.rebuild)
	if bottle.date != '' {
		data['date'] = brew_runtime.string_value(bottle.date)
	}
	mut tags := map[string]brew_runtime.Value{}
	for tag, value in bottle.tags {
		tags[tag] = bottle_tag_value(value)
	}
	data['tags'] = brew_runtime.map_value(tags)
	return brew_runtime.map_value(data)
}

pub fn bottle_json_document_value(document BottleJsonDocument) brew_runtime.Value {
	mut data := map[string]brew_runtime.Value{}
	for name, entry in document.entries {
		data[name] = brew_runtime.map_value({
			'formula': bottle_formula_value(entry.formula)
			'bottle':  bottle_json_bottle_value(entry.bottle)
		})
	}
	return brew_runtime.map_value(data)
}

pub fn parse_bottle_json_files(filenames []string) ![]BottleJsonDocument {
	mut documents := []BottleJsonDocument{cap: filenames.len}
	for filename in filenames {
		contents := os.read_file(filename) or { return error('${filename}: ${err.msg()}') }
		value := brew_runtime.parse_json_value(contents) or { return error('${filename}: ${err.msg()}') }
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
	result := brew_runtime.run_command('/usr/bin/sudo', ['--non-interactive', '/usr/sbin/purge'])
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
	result := brew_runtime.run_command(program, arguments)
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
			tab: brew_runtime.map_value({})
			sbom: brew_runtime.map_value({})
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
		os.write_file(json_path, brew_runtime.json_value_to_string(bottle_json_document_value(document)))!
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

pub fn bottle_boundary_input(input &BottleBoundaryInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Bottle::Input', '', {
		'bottle_input_address': u64(voidptr(input)).str()
	})
}

fn bottle_boundary_from_value(value brew_runtime.Value) &BottleBoundaryInput {
	address := value.attributes['bottle_input_address'] or { panic('invalid Bottle input') }
	return unsafe { &BottleBoundaryInput(voidptr(address.u64())) }
}

fn bottle_cellar_from_value(value brew_runtime.Value) BottleCellar {
	return BottleCellar{ value: value.as_string(), is_symbol: value.type_name == 'Symbol' }
}

fn bottle_checksum_value(checksum BottleChecksum) brew_runtime.Value {
	return brew_runtime.map_value({
		'tag':    brew_runtime.string_value(checksum.tag)
		'digest': brew_runtime.string_value(checksum.digest)
		'cellar': brew_runtime.structured_value(if checksum.cellar.is_symbol {
			'Symbol'
		} else {
			'String'
		}, checksum.cellar.value, {})
	})
}

fn bottle_specification_value(specification BottleSpecification) brew_runtime.Value {
	return brew_runtime.map_value({
		'root_url':  brew_runtime.string_value(specification.root_url)
		'rebuild':   brew_runtime.int_value(specification.rebuild)
		'checksums': brew_runtime.array_value(specification.checksums.map(bottle_checksum_value(it)))
	})
}

fn bottle_formula_result_value(result BottleFormulaResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'formula_name':    brew_runtime.string_value(result.formula_name)
		'bottle_path':     brew_runtime.string_value(result.bottle_path)
		'json_path':       brew_runtime.string_value(result.json_path)
		'output':          brew_runtime.string_value(result.output)
		'specification':   bottle_specification_value(result.specification)
		'relocatable':     brew_runtime.bool_value(result.relocatable)
		'skip_relocation': brew_runtime.bool_value(result.skip_relocation)
	})
}

fn bottle_merge_result_value(result BottleMergeResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'formula_name': brew_runtime.string_value(result.formula_name)
		'output':       brew_runtime.string_value(result.output)
		'formula_path': brew_runtime.string_value(result.formula_path)
		'updated':      brew_runtime.bool_value(result.updated)
		'all_bottle':   brew_runtime.bool_value(result.all_bottle)
		'commit':       brew_runtime.string_array_value(result.commit)
	})
}

fn bottle_command_result_value(result BottleCommandResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'bundler_groups': brew_runtime.string_array_value(result.bundler_groups)
		'bottles':        brew_runtime.array_value(result.bottles.map(bottle_formula_result_value(it)))
		'merged':         brew_runtime.array_value(result.merged.map(bottle_merge_result_value(it)))
	})
}

fn bottle_inspection_value(result BottleKegInspection) brew_runtime.Value {
	return brew_runtime.map_value({
		'contains': brew_runtime.bool_value(result.contains)
		'files':    brew_runtime.string_array_value(result.files)
		'output':   brew_runtime.string_array_value(result.output)
	})
}

// Ruby method `run` at line 100.
pub fn ruby_bottle_l100_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	result := run_bottle_command(bottle_boundary_from_value(args[0]).command) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return bottle_command_result_value(result)
}

// Ruby method `generate_sha256_line(tag, digest, cellar, tag_column, digest_column)` at line 119.
pub fn ruby_bottle_l119_d2_generate_sha256_line(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		return brew_runtime.object_value('ArgumentError', 'tag, digest, cellar, tag_column and digest_column are required')
	}
	return brew_runtime.string_value(generate_bottle_sha256_line(args[0].as_string(), args[1].as_string(), bottle_cellar_from_value(args[2]), int(args[3].int_data), int(args[4].int_data)))
}

// Ruby method `bottle_output(bottle, root_url_using)` at line 135.
pub fn ruby_bottle_l135_d3_bottle_output(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'bottle input is required')
	}
	input := bottle_boundary_from_value(args[0])
	root_url_using := if args.len > 1 {
		args[1].as_string()
	} else {
		input.command.options.root_url_using
	}
	return brew_runtime.string_value(bottle_output(input.specification, root_url_using))
}

// Ruby method `parse_json_files(filenames)` at line 164.
pub fn ruby_bottle_l164_d4_parse_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'filenames are required')
	}
	documents := parse_bottle_json_files(args[0].as_string_array() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}) or { return brew_runtime.object_value('JSONError', err.msg()) }
	return brew_runtime.array_value(documents.map(bottle_json_document_value(it)))
}

// Ruby method `merge_json_files(json_files)` at line 171.
pub fn ruby_bottle_l171_d5_merge_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'JSON files are required')
	}
	return bottle_json_document_value(merge_bottle_json_files(bottle_boundary_from_value(args[0]).json_files))
}

// Ruby method `merge_bottle_spec(old_keys, old_bottle_spec, new_bottle_hash)` at line 189.
pub fn ruby_bottle_l189_d6_merge_bottle_spec(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'merge input is required')
	}
	input := bottle_boundary_from_value(args[0])
	result := merge_bottle_spec(input.old_keys, input.specification, input.new_bottle)
	return brew_runtime.map_value({
		'mismatches': brew_runtime.string_array_value(result.mismatches)
		'checksums':  brew_runtime.array_value(result.checksums.map(bottle_checksum_value(it)))
	})
}

// Ruby method `keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil)` at line 237.
pub fn ruby_bottle_l237_d7_keg_contain(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'keg inspection input is required')
	}
	input := bottle_boundary_from_value(args[0])
	return bottle_inspection_value(keg_contain(input.needle, input.keg, input.ignores, input.dependency_names, input.verbose))
}

// Ruby method `keg_contain_absolute_symlink_starting_with?(string, keg)` at line 289.
pub fn ruby_bottle_l289_d8_keg_contain_absolute_symlink_starting_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'keg inspection input is required')
	}
	input := bottle_boundary_from_value(args[0])
	return bottle_inspection_value(keg_contain_absolute_symlink_starting_with(input.needle, input.keg, input.verbose))
}

// Ruby method `cellar_parameter_needed?(cellar)` at line 308.
pub fn ruby_bottle_l308_d9_cellar_parameter_needed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cellar_parameter_needed(bottle_cellar_from_value(args[0])))
}

// Ruby method `sudo_purge` at line 318.
pub fn ruby_bottle_l318_d10_sudo_purge(args ...brew_runtime.Value) brew_runtime.Value {
	enabled := if args.len > 0 {
		args[0].as_bool() or { false }
	} else {
		os.getenv('HOMEBREW_BOTTLE_SUDO_PURGE') != ''
	}
	purged := sudo_purge(enabled) or { return brew_runtime.object_value('CommandError', err.msg()) }
	return brew_runtime.bool_value(purged)
}

// Ruby method `tar_args` at line 325.
pub fn ruby_bottle_l325_d11_tar_args(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(bottle_tar_args())
}

// Ruby method `gnu_tar(gnu_tar_formula)` at line 330.
pub fn ruby_bottle_l330_d12_gnu_tar(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'gnu-tar formula is required')
	}
	return brew_runtime.string_value(gnu_tar(bottle_boundary_from_value(args[0]).gnu_tar))
}

// Ruby method `reproducible_gnutar_args(mtime)` at line 335.
pub fn ruby_bottle_l335_d13_reproducible_gnutar_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'mtime is required')
	}
	return brew_runtime.string_array_value(reproducible_gnutar_args(args[0].as_string()))
}

// Ruby method `gnu_tar_formula_ensure_installed_if_needed!` at line 353.
pub fn ruby_bottle_l353_d14_gnu_tar_formula_ensure_installed_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return bottle_nil_value()
	}
	formula := gnu_tar_formula_ensure_installed_if_needed(bottle_boundary_from_value(args[0]).gnu_tar)
	if !formula.available {
		return bottle_nil_value()
	}
	return brew_runtime.structured_value('Formula', 'gnu-tar', {
		'installed': formula.installed.str()
		'opt_bin':   formula.opt_bin
	})
}

// Ruby method `setup_tar_and_args!(mtime, default_tar: false)` at line 366.
pub fn ruby_bottle_l366_d15_setup_tar_and_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'tar setup input is required')
	}
	input := bottle_boundary_from_value(args[0])
	result := setup_tar_and_args(input.mtime, input.only_json_tab, input.default_tar, input.gnu_tar)
	return brew_runtime.map_value({
		'tar':               brew_runtime.string_value(result.tar)
		'args':              brew_runtime.string_array_value(result.args)
		'installed_gnu_tar': brew_runtime.bool_value(result.installed_gnu_tar)
	})
}

// Ruby method `formula_ignores(formula)` at line 380.
pub fn ruby_bottle_l380_d16_formula_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula input is required')
	}
	input := bottle_boundary_from_value(args[0])
	cellar := if args.len > 1 { args[1].as_string() } else { input.command.options.cellar }
	return brew_runtime.string_array_value(formula_ignores(input.formula, cellar))
}

// Ruby method `bottle_formula(formula)` at line 393.
pub fn ruby_bottle_l393_d17_bottle_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula input is required')
	}
	input := bottle_boundary_from_value(args[0])
	result := bottle_formula(input.formula, input.command.options, input.gnu_tar) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return bottle_formula_result_value(result)
}

// Ruby method `merge` at line 713.
pub fn ruby_bottle_l713_d18_merge(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	results := merge_bottles(bottle_boundary_from_value(args[0]).command) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.array_value(results.map(bottle_merge_result_value(it)))
}

// Ruby method `old_checksums(formula, formula_ast, bottle_hash)` at line 897.
pub fn ruby_bottle_l897_d19_old_checksums(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'checksum input is required')
	}
	result := old_checksums(bottle_boundary_from_value(args[0]).old_checksums) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	if result.exists {
		return brew_runtime.array_value(result.checksums.map(bottle_checksum_value(it)))
	}
	return bottle_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "formula"
// 7: require "utils/bottles"
// 8: require "tab"
// 9: require "sbom"
// 10: require "keg"
// 11: require "formula_versions"
// 12: require "erb"
// 13: require "utils/gzip"
// 14: require "api"
// 15: require "extend/hash/deep_merge"
// 16: require "metafiles"
// 17: require "utils/github"
// 18:
// 19: module Homebrew
// 20:   module DevCmd
// 21:     class Bottle < AbstractCommand
// 22:       include FileUtils
// 23:
// 24:       BOTTLE_ERB = T.let(<<-EOS.freeze, String)
// 25:   bottle do
// 26:     <% if [HOMEBREW_BOTTLE_DEFAULT_DOMAIN.to_s,
// 27:            "#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/bottles"].exclude?(root_url) %>
// 28:     root_url "<%= root_url %>"<% if root_url_using.present? %>,
// 29:       using: <%= root_url_using %>
// 30:     <% end %>
// 31:     <% end %>
// 32:     <% if rebuild.positive? %>
// 33:     rebuild <%= rebuild %>
// 34:     <% end %>
// 35:     <% sha256_lines.each do |line| %>
// 36:     <%= line %>
// 37:     <% end %>
// 38:   end
// 39:       EOS
// 40:
// 41:       MAXIMUM_STRING_MATCHES = 100
// 42:
// 43:       ALLOWABLE_HOMEBREW_REPOSITORY_LINKS = T.let([
// 44:         %r{#{Regexp.escape(HOMEBREW_LIBRARY)}/Homebrew/os/(mac|linux)/pkgconfig},
// 45:       ].freeze, T::Array[Regexp])
// 46:
// 47:       cmd_args do
// 48:         description <<~EOS
// 49:           Generate a bottle (binary package) from a formula that was installed with
// 50:           `--build-bottle`.
// 51:           If the formula specifies a rebuild version, it will be incremented in the
// 52:           generated DSL. Passing `--keep-old` will attempt to keep it at its original
// 53:           value, while `--no-rebuild` will remove it.
// 54:         EOS
// 55:         switch "--skip-relocation",
// 56:                description: "Do not check if the bottle can be marked as relocatable."
// 57:         switch "--force-core-tap",
// 58:                description: "Build a bottle even if <formula> is not in `homebrew/core` or any installed taps."
// 59:         switch "--no-rebuild",
// 60:                description: "If the formula specifies a rebuild version, remove it from the generated DSL."
// 61:         switch "--keep-old",
// 62:                description: "If the formula specifies a rebuild version, attempt to preserve its value in the " \
// 63:                             "generated DSL."
// 64:         switch "--json",
// 65:                description: "Write bottle information to a JSON file, which can be used as the value for " \
// 66:                             "`--merge`."
// 67:         switch "--merge",
// 68:                description: "Generate an updated bottle block for a formula and optionally merge it into the " \
// 69:                             "formula file. Instead of a formula name, requires the path to a JSON file generated " \
// 70:                             "with `brew bottle --json` <formula>."
// 71:         switch "--write",
// 72:                depends_on:  "--merge",
// 73:                description: "Write changes to the formula file. A new commit will be generated unless " \
// 74:                             "`--no-commit` is passed."
// 75:         switch "--no-commit",
// 76:                depends_on:  "--write",
// 77:                description: "When passed with `--write`, a new commit will not generated after writing changes " \
// 78:                             "to the formula file."
// 79:         switch "--only-json-tab",
// 80:                depends_on:  "--json",
// 81:                description: "When passed with `--json`, the tab will be written to the JSON file but not the bottle."
// 82:         switch "--no-all-checks",
// 83:                depends_on:  "--merge",
// 84:                description: "Don't try to create an `all` bottle or stop a no-change upload."
// 85:         flag   "--committer=",
// 86:                description: "Specify a committer name and email in `git`'s standard author format.",
// 87:                odeprecated: true
// 88:         flag   "--root-url=",
// 89:                description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
// 90:         flag   "--root-url-using=",
// 91:                description: "Use the specified download strategy class for downloading the bottle's URL instead of " \
// 92:                             "Homebrew's default."
// 93:
// 94:         conflicts "--no-rebuild", "--keep-old"
// 95:
// 96:         named_args [:installed_formula, :file], min: 1, without_api: true
// 97:       end
// 98:
// 99:       sig { override.void }
// 100:       def run
// 101:         if args.merge?
// 102:           Homebrew.install_bundler_gems!(groups: ["ast"])
// 103:           return merge
// 104:         end
// 105:
// 106:         Homebrew.install_bundler_gems!(groups: ["bottle"])
// 107:
// 108:         gnu_tar_formula_ensure_installed_if_needed! if args.only_json_tab?
// 109:
// 110:         args.named.to_resolved_formulae(uniq: false).each do |formula|
// 111:           bottle_formula formula
// 112:         end
// 113:       end
// 114:
// 115:       sig {
// 116:         params(tag: Symbol, digest: T.any(Checksum, String), cellar: T.nilable(T.any(String, Symbol)),
// 117:                tag_column: Integer, digest_column: Integer).returns(String)
// 118:       }
// 119:       def generate_sha256_line(tag, digest, cellar, tag_column, digest_column)
// 120:         line = "sha256 "
// 121:         tag_column += line.length
// 122:         digest_column += line.length
// 123:         if cellar.is_a?(Symbol)
// 124:           line += "cellar: :#{cellar},"
// 125:         elsif cellar_parameter_needed?(cellar)
// 126:           line += %Q(cellar: "#{cellar}",)
// 127:         end
// 128:         line += " " * (tag_column - line.length)
// 129:         line += "#{tag}:"
// 130:         line += " " * (digest_column - line.length)
// 131:         %Q(#{line}"#{digest}")
// 132:       end
// 133:
// 134:       sig { params(bottle: BottleSpecification, root_url_using: T.nilable(String)).returns(String) }
// 135:       def bottle_output(bottle, root_url_using)
// 136:         cellars = bottle.checksums.filter_map do |checksum|
// 137:           cellar = checksum["cellar"]
// 138:           next unless cellar_parameter_needed? cellar
// 139:
// 140:           case cellar
// 141:           when String
// 142:             %Q("#{cellar}")
// 143:           when Symbol
// 144:             ":#{cellar}"
// 145:           end
// 146:         end
// 147:         tag_column = cellars.empty? ? 0 : "cellar: #{cellars.max_by(&:length)}, ".length
// 148:
// 149:         tags = bottle.checksums.map { |checksum| checksum["tag"] }
// 150:         # Start where the tag ends, add the max length of the tag, add two for the `: `
// 151:         digest_column = tag_column + tags.max_by(&:length).length + 2
// 152:
// 153:         sha256_lines = bottle.checksums.map do |checksum|
// 154:           generate_sha256_line(checksum["tag"], checksum["digest"], checksum["cellar"], tag_column, digest_column)
// 155:         end
// 156:         erb_binding = bottle.instance_eval { binding }
// 157:         erb_binding.local_variable_set(:sha256_lines, sha256_lines)
// 158:         erb_binding.local_variable_set(:root_url_using, root_url_using)
// 159:         erb = ERB.new BOTTLE_ERB
// 160:         erb.result(erb_binding).gsub(/^\s*$\n/, "")
// 161:       end
// 162:
// 163:       sig { params(filenames: T::Array[String]).returns(T::Array[T::Hash[String, T.untyped]]) }
// 164:       def parse_json_files(filenames)
// 165:         filenames.map do |filename|
// 166:           JSON.parse(File.read(filename))
// 167:         end
// 168:       end
// 169:
// 170:       sig { params(json_files: T::Array[T::Hash[String, T.untyped]]).returns(T::Hash[String, T.untyped]) }
// 171:       def merge_json_files(json_files)
// 172:         json_files.reduce({}) do |hash, json_file|
// 173:           json_file.each_value do |json_hash|
// 174:             json_bottle = json_hash["bottle"]
// 175:             cellar = json_bottle.delete("cellar")
// 176:             json_bottle["tags"].each_value do |json_platform|
// 177:               json_platform["cellar"] ||= cellar
// 178:             end
// 179:           end
// 180:           hash.deep_merge(json_file)
// 181:         end
// 182:       end
// 183:
// 184:       sig {
// 185:         params(old_keys: T::Array[Symbol], old_bottle_spec: BottleSpecification,
// 186:                new_bottle_hash: T::Hash[String, T.untyped])
// 187:           .returns([T::Array[String], T::Array[T::Hash[Symbol, T.any(String, Symbol)]]])
// 188:       }
// 189:       def merge_bottle_spec(old_keys, old_bottle_spec, new_bottle_hash)
// 190:         mismatches = []
// 191:         checksums = []
// 192:
// 193:         new_values = {
// 194:           root_url: new_bottle_hash["root_url"],
// 195:           rebuild:  new_bottle_hash["rebuild"],
// 196:         }
// 197:
// 198:         skip_keys = [:sha256, :cellar]
// 199:         old_keys.each do |key|
// 200:           next if skip_keys.include?(key)
// 201:
// 202:           old_value = old_bottle_spec.public_send(key).to_s
// 203:           new_value = new_values[key].to_s
// 204:
// 205:           next if old_value.present? && new_value == old_value
// 206:
// 207:           mismatches << "#{key}: old: #{old_value.inspect}, new: #{new_value.inspect}"
// 208:         end
// 209:
// 210:         return [mismatches, checksums] if old_keys.exclude? :sha256
// 211:
// 212:         old_bottle_spec.collector.each_tag do |tag|
// 213:           old_tag_spec = old_bottle_spec.collector.specification_for(tag)
// 214:           odie "Specification for tag #{tag} is nil" if old_tag_spec.nil?
// 215:
// 216:           old_hexdigest = old_tag_spec.checksum.hexdigest
// 217:           old_cellar = old_tag_spec.cellar
// 218:           new_value = new_bottle_hash.dig("tags", tag.to_s)
// 219:           if new_value.present? && new_value["sha256"] != old_hexdigest
// 220:             mismatches << "sha256 #{tag}: old: #{old_hexdigest.inspect}, new: #{new_value["sha256"].inspect}"
// 221:           elsif new_value.present? && new_value["cellar"] != old_cellar.to_s
// 222:             mismatches << "cellar #{tag}: old: #{old_cellar.to_s.inspect}, new: #{new_value["cellar"].inspect}"
// 223:           else
// 224:             checksums << { cellar: old_cellar, tag.to_sym => old_hexdigest }
// 225:           end
// 226:         end
// 227:
// 228:         [mismatches, checksums]
// 229:       end
// 230:
// 231:       private
// 232:
// 233:       sig {
// 234:         params(string: String, keg: Keg, ignores: T::Array[Regexp],
// 235:                formula_and_runtime_deps_names: T.nilable(T::Array[String])).returns(T::Boolean)
// 236:       }
// 237:       def keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil)
// 238:         @put_string_exists_header, @put_filenames = nil
// 239:
// 240:         print_filename = lambda do |str, filename|
// 241:           unless @put_string_exists_header
// 242:             opoo "String '#{str}' still exists in these files:"
// 243:             @put_string_exists_header = T.let(true, T.nilable(T::Boolean))
// 244:           end
// 245:
// 246:           @put_filenames ||= T.let([], T.nilable(T::Array[T.any(String, Pathname)]))
// 247:
// 248:           return false if @put_filenames.include?(filename)
// 249:
// 250:           puts Formatter.error(filename.to_s)
// 251:           @put_filenames << filename
// 252:         end
// 253:
// 254:         result = T.let(false, T::Boolean)
// 255:
// 256:         keg.each_unique_file_matching(string) do |file|
// 257:           next if Metafiles::EXTENSIONS.include?(file.extname) # Skip document files.
// 258:
// 259:           linked_libraries = Keg.file_linked_libraries(file, string)
// 260:           result ||= !linked_libraries.empty?
// 261:
// 262:           if args.verbose?
// 263:             print_filename.call(string, file) unless linked_libraries.empty?
// 264:             linked_libraries.each do |lib|
// 265:               puts " #{Tty.bold}-->#{Tty.reset} links to #{lib}"
// 266:             end
// 267:           end
// 268:
// 269:           text_matches = Keg.text_matches_in_file(file, string, ignores, linked_libraries,
// 270:                                                   formula_and_runtime_deps_names)
// 271:           result = true if text_matches.any?
// 272:
// 273:           next if !args.verbose? || text_matches.empty?
// 274:
// 275:           print_filename.call(string, file)
// 276:           text_matches.first(MAXIMUM_STRING_MATCHES).each do |match, offset|
// 277:             puts " #{Tty.bold}-->#{Tty.reset} match '#{match}' at offset #{Tty.bold}0x#{offset}#{Tty.reset}"
// 278:           end
// 279:
// 280:           if text_matches.size > MAXIMUM_STRING_MATCHES
// 281:             puts "Only the first #{MAXIMUM_STRING_MATCHES} matches were output."
// 282:           end
// 283:         end
// 284:
// 285:         keg_contain_absolute_symlink_starting_with?(string, keg) || result
// 286:       end
// 287:
// 288:       sig { params(string: String, keg: Keg).returns(T::Boolean) }
// 289:       def keg_contain_absolute_symlink_starting_with?(string, keg)
// 290:         absolute_symlinks_start_with_string = []
// 291:         keg.find do |pn|
// 292:           next if !pn.symlink? || !(link = pn.readlink).absolute?
// 293:
// 294:           absolute_symlinks_start_with_string << pn if link.to_s.start_with?(string)
// 295:         end
// 296:
// 297:         if args.verbose? && absolute_symlinks_start_with_string.present?
// 298:           opoo "Absolute symlink starting with #{string}:"
// 299:           absolute_symlinks_start_with_string.each do |pn|
// 300:             puts "  #{pn} -> #{pn.resolved_path}"
// 301:           end
// 302:         end
// 303:
// 304:         !absolute_symlinks_start_with_string.empty?
// 305:       end
// 306:
// 307:       sig { params(cellar: T.nilable(T.any(String, Symbol))).returns(T::Boolean) }
// 308:       def cellar_parameter_needed?(cellar)
// 309:         default_cellars = [
// 310:           Homebrew::DEFAULT_MACOS_CELLAR,
// 311:           Homebrew::DEFAULT_MACOS_ARM_CELLAR,
// 312:           Homebrew::DEFAULT_LINUX_CELLAR,
// 313:         ]
// 314:         cellar.present? && default_cellars.exclude?(cellar)
// 315:       end
// 316:
// 317:       sig { returns(T.nilable(T::Boolean)) }
// 318:       def sudo_purge
// 319:         return unless ENV["HOMEBREW_BOTTLE_SUDO_PURGE"]
// 320:
// 321:         system "/usr/bin/sudo", "--non-interactive", "/usr/sbin/purge"
// 322:       end
// 323:
// 324:       sig { returns(T::Array[String]) }
// 325:       def tar_args
// 326:         [].freeze
// 327:       end
// 328:
// 329:       sig { params(gnu_tar_formula: Formula).returns(String) }
// 330:       def gnu_tar(gnu_tar_formula)
// 331:         "#{gnu_tar_formula.opt_bin}/tar"
// 332:       end
// 333:
// 334:       sig { params(mtime: String).returns(T::Array[String]) }
// 335:       def reproducible_gnutar_args(mtime)
// 336:         # Ensure gnu tar is set up for reproducibility.
// 337:         # https://reproducible-builds.org/docs/archives/
// 338:         [
// 339:           # File modification times
// 340:           "--mtime=#{mtime}",
// 341:           # File ordering
// 342:           "--sort=name",
// 343:           # Users, groups and numeric ids
// 344:           "--owner=0", "--group=0", "--numeric-owner",
// 345:           # PAX headers
// 346:           "--format=pax",
// 347:           # Set exthdr names to exclude PID (for GNU tar <1.33). Also don't store atime and ctime.
// 348:           "--pax-option=globexthdr.name=/GlobalHead.%n,exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime"
// 349:         ].freeze
// 350:       end
// 351:
// 352:       sig { returns(T.nilable(Formula)) }
// 353:       def gnu_tar_formula_ensure_installed_if_needed!
// 354:         gnu_tar_formula = begin
// 355:           Formula["gnu-tar"]
// 356:         rescue FormulaUnavailableError
// 357:           nil
// 358:         end
// 359:         return if gnu_tar_formula.blank?
// 360:
// 361:         gnu_tar_formula.ensure_installed!(reason: "bottling")
// 362:         gnu_tar_formula
// 363:       end
// 364:
// 365:       sig { params(mtime: String, default_tar: T::Boolean).returns([String, T::Array[String]]) }
// 366:       def setup_tar_and_args!(mtime, default_tar: false)
// 367:         # Without --only-json-tab bottles are never reproducible
// 368:         default_tar_args = ["tar", tar_args].freeze
// 369:         return default_tar_args if !args.only_json_tab? || default_tar
// 370:
// 371:         # Use gnu-tar as it can be set up for reproducibility better than libarchive
// 372:         # and to be consistent between macOS and Linux.
// 373:         gnu_tar_formula = gnu_tar_formula_ensure_installed_if_needed!
// 374:         return default_tar_args if gnu_tar_formula.blank?
// 375:
// 376:         [gnu_tar(gnu_tar_formula), reproducible_gnutar_args(mtime)].freeze
// 377:       end
// 378:
// 379:       sig { params(formula: Formula).returns(T::Array[Regexp]) }
// 380:       def formula_ignores(formula)
// 381:         # Ignore matches to go keg, because all go binaries are statically linked.
// 382:         any_go_deps = formula.deps.any? do |dep|
// 383:           Version.formula_optionally_versioned_regex(:go).match?(dep.name)
// 384:         end
// 385:         return [] unless any_go_deps
// 386:
// 387:         cellar_regex = Regexp.escape(HOMEBREW_CELLAR)
// 388:         go_regex = Version.formula_optionally_versioned_regex(:go, full: false)
// 389:         Array(%r{#{cellar_regex}/#{go_regex}/[\d.]+/libexec})
// 390:       end
// 391:
// 392:       sig { params(formula: Formula).void }
// 393:       def bottle_formula(formula)
// 394:         local_bottle_json = args.json? && formula.local_bottle_path
// 395:
// 396:         unless local_bottle_json
// 397:           unless formula.latest_version_installed?
// 398:             return ofail "Formula not installed or up-to-date: #{formula.full_name}"
// 399:           end
// 400:           unless Utils::Bottles.built_as? formula
// 401:             return ofail "Formula was not installed with `--build-bottle`: #{formula.full_name}"
// 402:           end
// 403:         end
// 404:
// 405:         tap = formula.tap
// 406:         if tap.nil?
// 407:           return ofail "Formula not from core or any installed taps: #{formula.full_name}" unless args.force_core_tap?
// 408:
// 409:           tap = CoreTap.instance
// 410:         end
// 411:         raise TapUnavailableError, tap.name unless tap.installed?
// 412:
// 413:         return ofail "Formula has no stable version: #{formula.full_name}" unless formula.stable
// 414:
// 415:         bottle_tag, rebuild = if local_bottle_json
// 416:           _, tag_string, rebuild_string = Utils::Bottles.extname_tag_rebuild(formula.local_bottle_path.to_s)
// 417:           [T.must(tag_string).to_sym, rebuild_string.to_i]
// 418:         end
// 419:
// 420:         bottle_tag = if bottle_tag
// 421:           Utils::Bottles::Tag.from_symbol(bottle_tag)
// 422:         else
// 423:           Utils::Bottles.tag
// 424:         end
// 425:
// 426:         rebuild ||= if args.no_rebuild? || !tap
// 427:           0
// 428:         elsif args.keep_old?
// 429:           formula.bottle_specification.rebuild
// 430:         else
// 431:           ohai "Determining #{formula.full_name} bottle rebuild..."
// 432:           FormulaVersions.new(formula).formula_at_revision("origin/HEAD") do |upstream_formula|
// 433:             if formula.pkg_version == upstream_formula.pkg_version
// 434:               upstream_formula.bottle_specification.rebuild + 1
// 435:             else
// 436:               0
// 437:             end
// 438:           end || 0
// 439:         end
// 440:
// 441:         filename = ::Bottle::Filename.create(formula, bottle_tag, rebuild)
// 442:         local_filename = filename.to_s
// 443:         bottle_path = Pathname.pwd/local_filename
// 444:
// 445:         tab = nil
// 446:         keg = nil
// 447:
// 448:         tap_path = tap.path
// 449:         tap_git_revision = tap.git_head
// 450:         tap_git_remote = tap.remote
// 451:
// 452:         root_url = args.root_url
// 453:
// 454:         relocatable = T.let(false, T::Boolean)
// 455:         skip_relocation = T.let(false, T::Boolean)
// 456:
// 457:         prefix = HOMEBREW_PREFIX.to_s
// 458:         cellar = HOMEBREW_CELLAR.to_s
// 459:
// 460:         if local_bottle_json
// 461:           bottle_path = formula.local_bottle_path
// 462:           return unless bottle_path
// 463:
// 464:           local_filename = bottle_path.basename.to_s
// 465:
// 466:           tab_path = Utils::Bottles.receipt_path(bottle_path)
// 467:           raise "This bottle does not contain the file INSTALL_RECEIPT.json: #{bottle_path}" unless tab_path
// 468:
// 469:           tab_json = Utils::Bottles.file_from_bottle(bottle_path, tab_path)
// 470:           tab = Tab.from_file_content(tab_json, tab_path)
// 471:
// 472:           tag_spec = Formula[formula.name].bottle_specification
// 473:                                           .tag_specification_for(bottle_tag, no_older_versions: true)
// 474:           relocatable = BottleSpecification::RELOCATABLE_CELLARS.include?(tag_spec.cellar)
// 475:           skip_relocation = tag_spec.cellar == BottleSpecification::ANY_SKIP_RELOCATION_CELLAR
// 476:
// 477:           prefix = bottle_tag.default_prefix
// 478:           cellar = bottle_tag.default_cellar
// 479:         else
// 480:           tar_filename = filename.to_s.sub(/.gz$/, "")
// 481:           tar_path = Pathname.pwd/tar_filename
// 482:           return if tar_path.blank?
// 483:
// 484:           keg = Keg.new(formula.prefix)
// 485:         end
// 486:
// 487:         ohai "Bottling #{local_filename}..."
// 488:
// 489:         formula_and_runtime_deps_names = [formula.name] + formula.runtime_dependencies.map(&:name)
// 490:
// 491:         # this will be nil when using a local bottle
// 492:         keg&.lock do
// 493:           original_tab = nil
// 494:           changed_files = nil
// 495:
// 496:           begin
// 497:             keg.delete_pyc_files!
// 498:
// 499:             changed_files = keg.replace_locations_with_placeholders unless args.skip_relocation?
// 500:
// 501:             Formula.clear_cache
// 502:             Keg.clear_cache
// 503:             Tab.clear_cache
// 504:             Dependency.clear_cache
// 505:             Requirement.clear_cache
// 506:
// 507:             tab = keg.tab
// 508:             original_tab = tab.dup
// 509:             tab.poured_from_bottle = false
// 510:             tab.time = nil
// 511:             tab.changed_files = changed_files.dup
// 512:             if args.only_json_tab?
// 513:               tab.changed_files&.delete(Pathname.new(AbstractTab::FILENAME))
// 514:               tab.tabfile&.unlink
// 515:             else
// 516:               tab.write
// 517:             end
// 518:
// 519:             sbom = SBOM.create(formula, tab)
// 520:             sbom.write(bottling: true)
// 521:
// 522:             keg.consistent_reproducible_symlink_permissions!
// 523:
// 524:             cd cellar do
// 525:               sudo_purge
// 526:               # Tar then gzip for reproducible bottles.
// 527:               # GNU tar fails to create a bottle if modification time is unsigned integer
// 528:               # (i.e. before 1970)
// 529:               time_at_epoch = Time.at(1)
// 530:               tab_source_modified_time = [time_at_epoch, tab.source_modified_time].max
// 531:               tar_mtime = tab_source_modified_time.strftime("%Y-%m-%d %H:%M:%S")
// 532:               tar, tar_args = setup_tar_and_args!(tar_mtime, default_tar: formula.name == "gnu-tar")
// 533:               safe_system tar, "--create", "--numeric-owner",
// 534:                           *tar_args,
// 535:                           "--file", tar_path, "#{formula.name}/#{formula.pkg_version}"
// 536:               sudo_purge
// 537:               # Set filename as it affects the tarball checksum.
// 538:               relocatable_tar_path = "#{formula}-bottle.tar"
// 539:               mv T.must(tar_path), relocatable_tar_path
// 540:               # Use gzip, faster to compress than bzip2, faster to uncompress than bzip2
// 541:               # or an uncompressed tarball (and more bandwidth friendly).
// 542:               Utils::Gzip.compress_with_options(relocatable_tar_path,
// 543:                                                 mtime:     tab.source_modified_time,
// 544:                                                 orig_name: relocatable_tar_path,
// 545:                                                 output:    bottle_path)
// 546:               sudo_purge
// 547:             end
// 548:
// 549:             ohai "Detecting if #{local_filename} is relocatable..." if bottle_path.size > 1 * 1024 * 1024
// 550:
// 551:             is_usr_local_prefix = prefix == "/usr/local"
// 552:             prefix_check = if is_usr_local_prefix
// 553:               "#{prefix}/opt"
// 554:             else
// 555:               prefix
// 556:             end
// 557:
// 558:             # Ignore matches to source code, which is not required at run time.
// 559:             # These matches may be caused by debugging symbols.
// 560:             ignores = [%r{/include/|\.(c|cc|cpp|h|hpp)$}]
// 561:
// 562:             # Add additional workarounds to ignore
// 563:             ignores += formula_ignores(formula)
// 564:
// 565:             repository_reference = if HOMEBREW_PREFIX == HOMEBREW_REPOSITORY
// 566:               HOMEBREW_LIBRARY
// 567:             else
// 568:               HOMEBREW_REPOSITORY
// 569:             end.to_s
// 570:             if keg_contain?(repository_reference, keg, ignores + ALLOWABLE_HOMEBREW_REPOSITORY_LINKS)
// 571:               odie "Bottle contains non-relocatable reference to #{repository_reference}!"
// 572:             end
// 573:
// 574:             relocatable = true
// 575:             if args.skip_relocation?
// 576:               skip_relocation = true
// 577:             else
// 578:               relocatable = false if keg_contain?(prefix_check, keg, ignores, formula_and_runtime_deps_names)
// 579:               relocatable = false if keg_contain?(cellar, keg, ignores, formula_and_runtime_deps_names)
// 580:               relocatable = false if keg_contain?(HOMEBREW_LIBRARY.to_s, keg, ignores, formula_and_runtime_deps_names)
// 581:               if is_usr_local_prefix
// 582:                 relocatable = false if keg_contain_absolute_symlink_starting_with?(prefix, keg)
// 583:                 if tap.disabled_new_usr_local_relocation_formulae.exclude?(formula.name)
// 584:                   keg.new_usr_local_replacement_pairs.each_value do |value|
// 585:                     relocatable = false if keg_contain?(value.fetch(:old), keg, ignores)
// 586:                   end
// 587:                 else
// 588:                   relocatable = false if keg_contain?("#{prefix}/etc", keg, ignores)
// 589:                   relocatable = false if keg_contain?("#{prefix}/var", keg, ignores)
// 590:                   relocatable = false if keg_contain?("#{prefix}/share/vim", keg, ignores)
// 591:                 end
// 592:               end
// 593:               skip_relocation = relocatable && !keg.require_relocation?
// 594:             end
// 595:             puts if !relocatable && args.verbose?
// 596:           rescue Interrupt
// 597:             ignore_interrupts { bottle_path.unlink if bottle_path.exist? }
// 598:             raise
// 599:           ensure
// 600:             ignore_interrupts do
// 601:               original_tab&.write
// 602:               keg.replace_placeholders_with_locations(changed_files) if changed_files && !args.skip_relocation?
// 603:             end
// 604:           end
// 605:         end
// 606:
// 607:         bottle = BottleSpecification.new
// 608:         bottle.tap = tap
// 609:         bottle.root_url(root_url) if root_url
// 610:         bottle_cellar = if relocatable
// 611:           if skip_relocation
// 612:             BottleSpecification::ANY_SKIP_RELOCATION_CELLAR
// 613:           else
// 614:             BottleSpecification::ANY_CELLAR
// 615:           end
// 616:         else
// 617:           cellar
// 618:         end
// 619:         bottle.rebuild rebuild
// 620:         sha256 = bottle_path.sha256
// 621:         bottle.sha256 cellar: bottle_cellar, bottle_tag.to_sym => sha256
// 622:
// 623:         old_spec = formula.bottle_specification
// 624:         if args.keep_old? && !old_spec.checksums.empty?
// 625:           mismatches = [:root_url, :rebuild].reject do |key|
// 626:             old_spec.public_send(key) == bottle.public_send(key)
// 627:           end
// 628:           unless mismatches.empty?
// 629:             bottle_path.unlink if bottle_path.exist?
// 630:
// 631:             mismatches.map! do |key|
// 632:               old_value = old_spec.public_send(key).inspect
// 633:               value = bottle.public_send(key).inspect
// 634:               "#{key}: old: #{old_value}, new: #{value}"
// 635:             end
// 636:
// 637:             odie <<~EOS
// 638:               `--keep-old` was passed but there are changes in:
// 639:               #{mismatches.join("\n")}
// 640:             EOS
// 641:           end
// 642:         end
// 643:
// 644:         output = bottle_output(bottle, args.root_url_using)
// 645:
// 646:         puts "./#{local_filename}"
// 647:         puts output
// 648:
// 649:         return unless args.json?
// 650:
// 651:         if keg
// 652:           keg_prefix = "#{keg}/"
// 653:           path_exec_files = [keg/"bin", keg/"sbin"].select(&:exist?)
// 654:                                                    .flat_map(&:children)
// 655:                                                    .select(&:executable?)
// 656:                                                    .map { |path| path.to_s.delete_prefix(keg_prefix) }
// 657:           all_files = keg.find
// 658:                          .select(&:file?)
// 659:                          .map { |path| path.to_s.delete_prefix(keg_prefix) }
// 660:           installed_size = keg.disk_usage
// 661:         end
// 662:
// 663:         bottle_tab = tab
// 664:         odie "Cannot generate bottle JSON without an installation receipt." if bottle_tab.nil?
// 665:
// 666:         json = {
// 667:           formula.full_name => {
// 668:             "formula" => {
// 669:               "name"             => formula.name,
// 670:               "pkg_version"      => formula.pkg_version.to_s,
// 671:               "path"             => formula.tap_path.to_s.delete_prefix("#{HOMEBREW_REPOSITORY}/"),
// 672:               "tap_git_path"     => formula.tap_path.to_s.delete_prefix("#{tap_path}/"),
// 673:               "tap_git_revision" => tap_git_revision,
// 674:               "tap_git_remote"   => tap_git_remote,
// 675:               # descriptions can contain emoji. sigh.
// 676:               "desc"             => formula.desc.to_s.encode(
// 677:                 Encoding.find("ASCII"),
// 678:                 invalid: :replace, undef: :replace, replace: "",
// 679:               ).strip,
// 680:               "license"          => SPDX.license_expression_to_string(formula.license),
// 681:               "homepage"         => formula.homepage,
// 682:             },
// 683:             "bottle"  => {
// 684:               "root_url" => bottle.root_url,
// 685:               "cellar"   => bottle_cellar.to_s,
// 686:               "rebuild"  => bottle.rebuild,
// 687:               # date is used for org.opencontainers.image.created which is an RFC 3339 date-time.
// 688:               # Time#iso8601 produces an XML Schema date-time that meets RFC 3339 ABNF.
// 689:               "date"     => Pathname(filename.to_s).mtime.utc.iso8601,
// 690:               "tags"     => {
// 691:                 bottle_tag.to_s => {
// 692:                   "filename"        => filename.url_encode,
// 693:                   "local_filename"  => filename.to_s,
// 694:                   "sha256"          => sha256,
// 695:                   "tab"             => bottle_tab.to_bottle_hash,
// 696:                   "sbom"            => SBOM.create(formula, bottle_tab).to_spdx_supplement,
// 697:                   "path_exec_files" => path_exec_files,
// 698:                   "all_files"       => all_files,
// 699:                   "installed_size"  => installed_size,
// 700:                 },
// 701:               },
// 702:             },
// 703:           },
// 704:         }
// 705:
// 706:         puts "Writing #{filename.json}" if args.verbose?
// 707:         json_path = Pathname(filename.json)
// 708:         json_path.unlink if json_path.exist?
// 709:         json_path.write(JSON.pretty_generate(json))
// 710:       end
// 711:
// 712:       sig { returns(T::Hash[String, T.untyped]) }
// 713:       def merge
// 714:         bottles_hash = merge_json_files(parse_json_files(args.named))
// 715:
// 716:         any_cellars = BottleSpecification::RELOCATABLE_CELLARS.map(&:to_s)
// 717:         bottles_hash.each do |formula_name, bottle_hash|
// 718:           ohai formula_name
// 719:
// 720:           bottle = BottleSpecification.new
// 721:           bottle.root_url bottle_hash["bottle"]["root_url"]
// 722:           bottle.rebuild bottle_hash["bottle"]["rebuild"]
// 723:
// 724:           path = HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]
// 725:           formula = Formulary.factory(path)
// 726:
// 727:           old_bottle_spec = formula.bottle_specification
// 728:           old_pkg_version = formula.pkg_version
// 729:           FormulaVersions.new(formula).formula_at_revision("origin/HEAD") do |upstream_formula|
// 730:             old_pkg_version = upstream_formula.pkg_version
// 731:           end
// 732:
// 733:           old_bottle_spec_matches = old_bottle_spec &&
// 734:                                     bottle_hash["formula"]["pkg_version"] == old_pkg_version.to_s &&
// 735:                                     bottle.root_url == old_bottle_spec.root_url &&
// 736:                                     old_bottle_spec.collector.tags.present?
// 737:
// 738:           # if all the cellars and checksums are the same: we can create an
// 739:           # `all: $SHA256` bottle.
// 740:           tag_hashes = bottle_hash["bottle"]["tags"].values
// 741:           all_bottle = !args.no_all_checks? &&
// 742:                        (!old_bottle_spec_matches || bottle.rebuild != old_bottle_spec.rebuild) &&
// 743:                        tag_hashes.count > 1 &&
// 744:                        tag_hashes.uniq { |tag_hash| "#{tag_hash["cellar"]}-#{tag_hash["sha256"]}" }.one?
// 745:
// 746:           old_all_bottle = old_bottle_spec.tag?(Utils::Bottles.tag(:all))
// 747:           github_event_path = ENV.fetch("GITHUB_EVENT_PATH", nil)
// 748:           if !all_bottle && old_all_bottle && !args.no_all_checks? && github_event_path.present?
// 749:             begin
// 750:               github_event = JSON.parse(File.read(github_event_path))
// 751:               repository = github_event.dig("repository", "full_name")
// 752:               pull_request_number = github_event.dig("pull_request", "number")
// 753:               if repository.present? && pull_request_number.present?
// 754:                 GitHub.create_issue_comment(repository, pull_request_number, <<~MARKDOWN)
// 755:                   Warning: #{formula} should have had an `:all` bottle but one could not be created.
// 756:                   #{Utils::Bottles.missing_all_bottle_publish_note.capitalize}.
// 757:
// 758:                   ```json
// 759:                   #{JSON.pretty_generate(tag_hashes)}
// 760:                   ```
// 761:                 MARKDOWN
// 762:               end
// 763:             rescue GitHub::API::Error, JSON::ParserError, Errno::ENOENT => e
// 764:               opoo "Failed to post missing `:all` bottle warning to pull request: #{e.message}"
// 765:             end
// 766:           end
// 767:
// 768:           bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
// 769:             cellar = tag_hash["cellar"]
// 770:             cellar = cellar.to_sym if any_cellars.include?(cellar)
// 771:
// 772:             tag_sym = if all_bottle
// 773:               :all
// 774:             else
// 775:               tag.to_sym
// 776:             end
// 777:
// 778:             sha256_hash = { cellar:, tag_sym => tag_hash["sha256"] }
// 779:             bottle.sha256 sha256_hash
// 780:
// 781:             break if all_bottle
// 782:           end
// 783:
// 784:           unless args.write?
// 785:             puts bottle_output(bottle, args.root_url_using)
// 786:             next
// 787:           end
// 788:
// 789:           no_bottle_changes = if !args.no_all_checks? && old_bottle_spec_matches &&
// 790:                                  bottle.rebuild != old_bottle_spec.rebuild
// 791:             bottle.collector.tags.all? do |tag|
// 792:               tag_spec = bottle.collector.specification_for(tag)
// 793:               next false if tag_spec.blank?
// 794:
// 795:               old_tag_spec = old_bottle_spec.collector.specification_for(tag)
// 796:               next false if old_tag_spec.blank?
// 797:
// 798:               next false if tag_spec.cellar != old_tag_spec.cellar
// 799:
// 800:               tag_spec.checksum.hexdigest == old_tag_spec.checksum.hexdigest
// 801:             end
// 802:           end
// 803:
// 804:           all_bottle_hash = T.let(nil, T.nilable(T::Hash[String, T.untyped]))
// 805:           bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
// 806:             filename = ::Bottle::Filename.new(
// 807:               formula_name,
// 808:               PkgVersion.parse(bottle_hash["formula"]["pkg_version"]),
// 809:               Utils::Bottles::Tag.from_symbol(tag.to_sym),
// 810:               bottle_hash["bottle"]["rebuild"],
// 811:             )
// 812:
// 813:             if all_bottle && all_bottle_hash.nil?
// 814:               all_bottle_tag_hash = tag_hash.dup
// 815:
// 816:               all_filename = ::Bottle::Filename.new(
// 817:                 formula_name,
// 818:                 PkgVersion.parse(bottle_hash["formula"]["pkg_version"]),
// 819:                 Utils::Bottles::Tag.from_symbol(:all),
// 820:                 bottle_hash["bottle"]["rebuild"],
// 821:               )
// 822:
// 823:               all_bottle_tag_hash["filename"] = all_filename.url_encode
// 824:               all_bottle_tag_hash["local_filename"] = all_filename.to_s
// 825:               cellar = all_bottle_tag_hash.delete("cellar")
// 826:               sbom_tags = bottle_hash["bottle"]["tags"].filter_map do |tag, tag_hash|
// 827:                 [tag, tag_hash["sbom"]] if tag_hash["sbom"].present?
// 828:               end.to_h
// 829:               all_bottle_tag_hash["sbom"] = { "tags" => sbom_tags } if sbom_tags.present?
// 830:
// 831:               all_bottle_formula_hash = bottle_hash.dup
// 832:               all_bottle_formula_hash["bottle"]["cellar"] = cellar
// 833:               all_bottle_formula_hash["bottle"]["tags"] = { all: all_bottle_tag_hash }
// 834:
// 835:               all_bottle_hash = { formula_name => all_bottle_formula_hash }
// 836:
// 837:               puts "Copying #{filename} to #{all_filename}" if args.verbose?
// 838:               FileUtils.cp filename.to_s, all_filename.to_s
// 839:
// 840:               puts "Writing #{all_filename.json}" if args.verbose?
// 841:               all_local_json_path = Pathname(all_filename.json)
// 842:               all_local_json_path.unlink if all_local_json_path.exist?
// 843:               all_local_json_path.write(JSON.pretty_generate(all_bottle_hash))
// 844:             end
// 845:
// 846:             if all_bottle || no_bottle_changes
// 847:               puts "Removing #{filename} and #{filename.json}" if args.verbose?
// 848:               FileUtils.rm_f [filename.to_s, filename.json]
// 849:             end
// 850:           end
// 851:
// 852:           next if no_bottle_changes
// 853:
// 854:           require "utils/ast"
// 855:           formula_ast = Utils::AST::FormulaAST.new(path.read)
// 856:           checksums = old_checksums(formula, formula_ast, bottle_hash)
// 857:           update_or_add = checksums.nil? ? "add" : "update"
// 858:
// 859:           checksums&.each { |checksum| bottle.sha256(checksum) }
// 860:           output = bottle_output(bottle, args.root_url_using)
// 861:           puts output
// 862:
// 863:           case update_or_add
// 864:           when "update"
// 865:             formula_ast.replace_bottle_block(output)
// 866:           when "add"
// 867:             formula_ast.add_bottle_block(output)
// 868:           end
// 869:           path.atomic_write(formula_ast.process)
// 870:
// 871:           next if args.no_commit?
// 872:
// 873:           Utils::Git.set_name_email!(committer: args.committer.blank?)
// 874:           Utils::Git.setup_gpg!
// 875:
// 876:           if (committer = args.committer)
// 877:             committer = Utils.parse_author!(committer)
// 878:             ENV["GIT_COMMITTER_NAME"] = committer[:name]
// 879:             ENV["GIT_COMMITTER_EMAIL"] = committer[:email]
// 880:           end
// 881:
// 882:           short_name = Utils.name_from_full_name(formula_name)
// 883:           pkg_version = bottle_hash["formula"]["pkg_version"]
// 884:
// 885:           path.parent.cd do
// 886:             safe_system "git", "commit", "--no-edit", "--verbose",
// 887:                         "--message=#{short_name}: #{update_or_add} #{pkg_version} bottle.",
// 888:                         "--", path
// 889:           end
// 890:         end
// 891:       end
// 892:
// 893:       sig {
// 894:         params(formula: Formula, formula_ast: Utils::AST::FormulaAST, bottle_hash: T::Hash[String, T.untyped])
// 895:           .returns(T.nilable(T::Array[T::Hash[Symbol, T.any(String, Symbol)]]))
// 896:       }
// 897:       def old_checksums(formula, formula_ast, bottle_hash)
// 898:         bottle_node = T.cast(formula_ast.bottle_block, T.nilable(RuboCop::AST::BlockNode))
// 899:         return if bottle_node.nil?
// 900:         return [] unless args.keep_old?
// 901:
// 902:         old_keys = T.cast(Utils::AST.body_children(bottle_node.body), T::Array[RuboCop::AST::SendNode])
// 903:                     .map(&:method_name)
// 904:         old_bottle_spec = formula.bottle_specification
// 905:         mismatches, checksums = merge_bottle_spec(old_keys, old_bottle_spec, bottle_hash["bottle"])
// 906:         if mismatches.present?
// 907:           odie <<~EOS
// 908:             `--keep-old` was passed but there are changes in:
// 909:             #{mismatches.join("\n")}
// 910:           EOS
// 911:         end
// 912:         checksums
// 913:       end
// 914:     end
// 915:   end
// 916: end
// 917:
// 918: require "extend/os/dev-cmd/bottle"
