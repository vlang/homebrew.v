module unpack_strategy

import ruby
import os
import time

// StrategyKind is the typed equivalent of the concrete strategy class selected
// by UnpackStrategy.detect. Its order mirrors the Ruby strategy list because
// several formats share magic bytes and rely on the first matching class.
pub enum StrategyKind {
	tar
	pax
	gzip
	dmg
	lzma
	bzip2
	xz
	zstd
	lzip
	air
	jar
	lua_rock
	microsoft_office_xml
	zip
	pkg
	xar
	ttf
	otf
	git
	mercurial
	subversion
	cvs
	self_extracting_executable
	cab
	executable
	fossil
	bazaar
	compress
	p7zip
	sit
	rar
	lha
	directory
	uncompressed
}

pub struct DetectOptions {
pub:
	prioritize_extension bool
	type_name            string
	ref_type             string
	ref                  string
	merge_xattrs         bool
}

pub struct ExtractOptions {
pub:
	destination          string
	basename             string
	verbose              bool
	prioritize_extension bool
}

pub struct Strategy {
pub:
	kind         StrategyKind
	path         string
	ref_type     string
	ref          string
	merge_xattrs bool
	move         bool
}

pub fn strategies() []StrategyKind {
	// Tar must precede the standalone compression strategies: a compressed tar
	// archive has both kinds of magic, and tar should consume it in one pass.
	return [.tar, .pax, .gzip, .dmg, .lzma, .xz, .zstd, .lzip, .air, .jar, .lua_rock,
		.microsoft_office_xml, .zip, .pkg, .xar, .ttf, .otf, .git, .mercurial, .subversion, .cvs,
		.self_extracting_executable, .cab, .executable, .bzip2, .fossil, .bazaar, .compress, .p7zip,
		.sit, .rar, .lha]
}

pub fn extensions(kind StrategyKind) []string {
	return match kind {
		.tar {
			tar_extensions()
		}
		.pax {
			pax_extensions()
		}
		.gzip {
			gzip_extensions()
		}
		.dmg {
			dmg_extensions()
		}
		.lzma {
			lzma_extensions()
		}
		.bzip2 {
			bzip2_extensions()
		}
		.xz {
			xz_extensions()
		}
		.zstd {
			zstd_extensions()
		}
		.lzip {
			lzip_extensions()
		}
		.air {
			air_extensions()
		}
		.jar {
			jar_extensions()
		}
		.lua_rock {
			lua_rock_extensions()
		}
		.microsoft_office_xml {
			microsoft_office_xml_extensions()
		}
		.zip {
			zip_extensions()
		}
		.pkg {
			pkg_extensions()
		}
		.xar {
			xar_extensions()
		}
		.ttf {
			ttf_extensions()
		}
		.otf {
			otf_extensions()
		}
		.git, .mercurial, .subversion, .cvs, .fossil, .bazaar, .directory {
			directory_extensions()
		}
		.self_extracting_executable {
			self_extracting_executable_extensions()
		}
		.cab {
			cab_extensions()
		}
		.executable {
			executable_extensions()
		}
		.compress {
			compress_extensions()
		}
		.p7zip {
			p7zip_extensions()
		}
		.sit {
			sit_extensions()
		}
		.rar {
			rar_extensions()
		}
		.lha {
			lha_extensions()
		}
		.uncompressed {
			uncompressed_extensions()
		}
	}
}

pub fn can_extract(kind StrategyKind, path string) bool {
	return match kind {
		.tar { tar_can_extract(path) }
		.pax { pax_can_extract(path) }
		.gzip { gzip_can_extract(path) }
		.dmg { dmg_can_extract(path) }
		.lzma { lzma_can_extract(path) }
		.bzip2 { bzip2_can_extract(path) }
		.xz { xz_can_extract(path) }
		.zstd { zstd_can_extract(path) }
		.lzip { lzip_can_extract(path) }
		.air { air_can_extract(path) }
		.jar { jar_can_extract(path) }
		.lua_rock { lua_rock_can_extract(path) }
		.microsoft_office_xml { microsoft_office_xml_can_extract(path) }
		.zip { zip_can_extract(path) }
		.pkg { pkg_can_extract(path) }
		.xar { xar_can_extract(path) }
		.ttf { ttf_can_extract(path) }
		.otf { otf_can_extract(path) }
		.git { git_can_extract(path) }
		.mercurial { mercurial_can_extract(path) }
		.subversion { subversion_can_extract(path) }
		.cvs { cvs_can_extract(path) }
		.self_extracting_executable { self_extracting_executable_can_extract(path) }
		.cab { cab_can_extract(path) }
		.executable { executable_can_extract(path) }
		.fossil { fossil_can_extract(path) }
		.bazaar { bazaar_can_extract(path) }
		.compress { compress_can_extract(path) }
		.p7zip { p7zip_can_extract(path) }
		.sit { sit_can_extract(path) }
		.rar { rar_can_extract(path) }
		.lha { lha_can_extract(path) }
		.directory { directory_can_extract(path) }
		.uncompressed { uncompressed_can_extract(path) }
	}
}

pub fn from_type(type_name string) ?StrategyKind {
	canonical := match type_name.to_lower().replace('-', '_') {
		'naked', 'nounzip' { 'uncompressed' }
		'seven_zip' { 'p7zip' }
		else { type_name.to_lower().replace('-', '_') }
	}
	return match canonical {
		'tar' { StrategyKind.tar }
		'pax' { StrategyKind.pax }
		'gzip', 'gz' { StrategyKind.gzip }
		'dmg' { StrategyKind.dmg }
		'lzma' { StrategyKind.lzma }
		'bzip2', 'bz2' { StrategyKind.bzip2 }
		'xz' { StrategyKind.xz }
		'zstd', 'zst' { StrategyKind.zstd }
		'lzip' { StrategyKind.lzip }
		'air' { StrategyKind.air }
		'jar' { StrategyKind.jar }
		'lua_rock' { StrategyKind.lua_rock }
		'microsoft_office_xml' { StrategyKind.microsoft_office_xml }
		'zip' { StrategyKind.zip }
		'pkg' { StrategyKind.pkg }
		'xar' { StrategyKind.xar }
		'ttf' { StrategyKind.ttf }
		'otf' { StrategyKind.otf }
		'git' { StrategyKind.git }
		'mercurial' { StrategyKind.mercurial }
		'subversion' { StrategyKind.subversion }
		'cvs' { StrategyKind.cvs }
		'self_extracting_executable' { StrategyKind.self_extracting_executable }
		'cab' { StrategyKind.cab }
		'executable' { StrategyKind.executable }
		'fossil' { StrategyKind.fossil }
		'bazaar' { StrategyKind.bazaar }
		'compress' { StrategyKind.compress }
		'p7zip', '7zip' { StrategyKind.p7zip }
		'sit' { StrategyKind.sit }
		'rar' { StrategyKind.rar }
		'lha' { StrategyKind.lha }
		'directory' { StrategyKind.directory }
		'uncompressed' { StrategyKind.uncompressed }
		else { none }
	}
}

pub fn from_extension(extension string) ?StrategyKind {
	mut ordered := strategies()
	ordered.sort_with_compare(fn (a &StrategyKind, b &StrategyKind) int {
		return longest_extension(*b) - longest_extension(*a)
	})
	for kind in ordered {
		for candidate in extensions(kind) {
			if extension.to_lower().ends_with(candidate.to_lower()) {
				return kind
			}
		}
	}
	return none
}

fn longest_extension(kind StrategyKind) int {
	mut longest := 0
	for extension in extensions(kind) {
		if extension.len > longest {
			longest = extension.len
		}
	}
	return longest
}

pub fn from_magic(path string) ?StrategyKind {
	for kind in strategies() {
		if can_extract(kind, path) {
			return kind
		}
	}
	return none
}

pub fn detect(path string, options DetectOptions) Strategy {
	absolute := os.abs_path(path)
	mut selected := ?StrategyKind(none)
	if options.type_name != '' {
		selected = from_type(options.type_name)
	}
	if options.prioritize_extension && path_extension(path) != '' {
		if selected == none {
			selected = from_extension(path_extension(path))
		}
		if selected == none {
			for kind in [StrategyKind.git, .mercurial, .subversion, .cvs, .fossil, .bazaar] {
				if can_extract(kind, absolute) {
					selected = kind
					break
				}
			}
		}
	} else {
		if selected == none {
			selected = from_magic(absolute)
		}
		if selected == none {
			selected = from_extension(path_extension(path))
		}
	}
	return Strategy{
		kind:         selected or { StrategyKind.uncompressed }
		path:         absolute
		ref_type:     options.ref_type
		ref:          options.ref
		merge_xattrs: options.merge_xattrs
	}
}

fn path_extension(path string) string {
	name := os.file_name(path)
	index := name.last_index('.') or { return '' }
	if index == 0 {
		return ''
	}
	return name[index..].to_lower()
}

pub fn (strategy Strategy) dependencies() []string {
	return match strategy.kind {
		.bzip2 { bzip2_dependencies() }
		.xz { xz_dependencies() }
		.lzma { lzma_dependencies() }
		.zstd { zstd_dependencies() }
		.lzip { lzip_dependencies() }
		.self_extracting_executable { generic_unar_dependencies() }
		.air { air_dependencies() }
		.cab { cab_dependencies() }
		.p7zip { p7zip_dependencies() }
		.sit { generic_unar_dependencies() }
		.rar { rar_dependencies() }
		.lha { lha_dependencies() }
		else { []string{} }
	}
}

pub fn (strategy Strategy) extract(options ExtractOptions) ! {
	destination := if options.destination == '' {
		os.getwd()
	} else {
		os.abs_path(options.destination)
	}
	os.mkdir_all(destination)!
	basename := if options.basename == '' { os.file_name(strategy.path) } else { options.basename }
	if !safe_basename(basename) {
		return error('unsafe archive basename: ${basename}')
	}
	match strategy.kind {
		.tar {
			tar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.pax {
			pax_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.gzip {
			gzip_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.dmg {
			dmg_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.lzma {
			lzma_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.bzip2 {
			bzip2_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.xz {
			xz_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.zstd {
			zstd_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.lzip {
			lzip_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.air {
			air_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.jar, .lua_rock, .microsoft_office_xml, .pkg, .ttf, .otf, .executable {
			uncompressed_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.zip {
			zip_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.xar {
			xar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.self_extracting_executable {
			generic_unar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.cab {
			cab_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.git, .cvs, .directory {
			directory_extract_to_dir(strategy.path, destination, basename, options.verbose,
				strategy.move)!
		}
		.bazaar {
			bazaar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.mercurial {
			mercurial_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.subversion {
			subversion_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.fossil {
			fossil_extract_to_dir(strategy, destination, basename, options.verbose)!
		}
		.compress {
			tar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.p7zip {
			p7zip_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.rar {
			rar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.lha {
			lha_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.sit {
			generic_unar_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
		.uncompressed {
			uncompressed_extract_to_dir(strategy.path, destination, basename, options.verbose)!
		}
	}
	validate_extracted_tree(destination)!
}

pub fn (strategy Strategy) extract_nestedly(options ExtractOptions) ! {
	if strategy.kind in [.uncompressed, .jar, .lua_rock, .microsoft_office_xml, .pkg, .ttf, .otf,
		.executable] {
		strategy.extract(options)!
		return
	}
	destination := if options.destination == '' {
		os.getwd()
	} else {
		os.abs_path(options.destination)
	}
	os.mkdir_all(destination)!
	temporary := make_temporary_directory(destination)!
	defer {
		if os.exists(temporary) {
			os.rmdir_all(temporary) or {}
		}
	}
	strategy.extract(ExtractOptions{
		destination: temporary
		basename:    options.basename
		verbose:     options.verbose
	})!
	mut children := os.ls(temporary)!
	children.sort()
	if children.len == 1 {
		first_child := os.join_path(temporary, children[0])
		if !os.is_dir(first_child) && !os.is_link(first_child) {
			nested := detect(first_child, DetectOptions{
				prioritize_extension: options.prioritize_extension
			})
			nested.extract_nestedly(ExtractOptions{
				destination:          destination
				verbose:              options.verbose
				prioritize_extension: options.prioritize_extension
			})!
			return
		}
	}
	make_directories_writable(temporary)!
	validate_extracted_tree(temporary)!
	for child in children {
		from := os.join_path(temporary, child)
		to := os.join_path(destination, child)
		if os.exists(to) || os.is_link(to) {
			remove_path(to)!
		}
		os.mv(from, to)!
	}
}

fn make_temporary_directory(parent string) !string {
	for attempt in 0 .. 100 {
		candidate := os.join_path(parent,
			'.brew-v-unpack-${os.getpid()}-${time.now().unix_nano()}-${attempt}')
		if !os.exists(candidate) {
			os.mkdir(candidate)!
			return candidate
		}
	}
	return error('unable to create an unpack temporary directory in ${parent}')
}

fn make_directories_writable(root string) ! {
	if os.is_link(root) {
		return
	}
	if os.is_dir(root) {
		info := os.inode(root)
		if !info.owner.write {
			os.chmod(root, int(info.bitmask() | u32(0o200)))!
		}
		for name in os.ls(root)! {
			make_directories_writable(os.join_path(root, name))!
		}
	}
}

pub fn each_directory(root string) ![]string {
	mut directories := []string{}
	collect_directories(root, mut directories)!
	return directories
}

fn collect_directories(path string, mut directories []string) ! {
	if os.is_link(path) || !os.is_dir(path) {
		return
	}
	directories << path
	for name in os.ls(path)! {
		collect_directories(os.join_path(path, name), mut directories)!
	}
}

fn safe_basename(name string) bool {
	return name != '' && name != '.' && name != '..' && !name.contains('/') && !name.contains('\\')
}

fn safe_archive_member(name string) bool {
	if name == '' || name.starts_with('/') || name.starts_with('\\') {
		return false
	}
	if name.len >= 2 && name[1] == `:` {
		return false
	}
	for component in name.replace('\\', '/').split('/') {
		if component == '..' {
			return false
		}
	}
	return true
}

fn validate_archive_members(names []string) ! {
	for name in names {
		if !safe_archive_member(name.trim_space()) {
			return error('archive member escapes extraction directory: ${name}')
		}
	}
}

pub fn validate_archive_member_names(names []string) ! {
	validate_archive_members(names)!
}

fn validate_extracted_tree(root string) ! {
	absolute_root := clean_absolute_path(root)
	validate_extracted_path(absolute_root, absolute_root)!
}

fn validate_extracted_path(root string, path string) ! {
	if os.is_link(path) {
		target := os.readlink(path)!
		if target.starts_with('/') || target.starts_with('\\')
			|| (target.len >= 2 && target[1] == `:`) {
			return error('archive symlink escapes extraction directory: ${path} -> ${target}')
		}
		resolved := clean_absolute_path(os.join_path(os.dir(path), target))
		if resolved != root && !resolved.starts_with(root + os.path_separator) {
			return error('archive symlink escapes extraction directory: ${path} -> ${target}')
		}
		return
	}
	if os.is_dir(path) {
		for name in os.ls(path)! {
			if !safe_basename(name) {
				return error('unsafe extracted path: ${name}')
			}
			validate_extracted_path(root, os.join_path(path, name))!
		}
	}
}

fn clean_absolute_path(path string) string {
	absolute := os.abs_path(path).replace('\\', '/')
	mut components := []string{}
	for component in absolute.split('/') {
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

fn remove_path(path string) ! {
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else if os.exists(path) || os.is_link(path) {
		os.rm(path)!
	}
}

fn command_path(name string) !string {
	return ruby.find_executable(name)
}

fn checked_command(program string, arguments []string) !ruby.CommandResult {
	result := ruby.run_command(program, arguments)
	if result.exit_code != 0 {
		return error('${os.file_name(program)} failed (${result.exit_code}): ${result.output.trim_space()}')
	}
	return result
}

fn checked_command_in_directory(program string, arguments []string, directory string) !ruby.CommandResult {
	mut process := os.new_process(program)
	process.set_args(arguments)
	process.set_work_folder(directory)
	process.set_redirect_stdio_merged()
	process.run()
	output := process.stdout_slurp()
	process.wait()
	result := ruby.CommandResult{
		exit_code: process.code
		output:    output
	}
	process.close()
	if result.exit_code != 0 {
		return error('${os.file_name(program)} failed (${result.exit_code}): ${result.output.trim_space()}')
	}
	return result
}

fn archive_listing(program string, arguments []string) ![]string {
	result := checked_command(program, arguments)!
	mut names := []string{}
	for line in result.output.split_into_lines() {
		name := line.trim_space()
		if name != '' {
			names << name
		}
	}
	return names
}

fn file_starts_with(path string, magic []u8) bool {
	bytes := read_file_prefix(path, magic.len) or { return false }
	if bytes.len < magic.len {
		return false
	}
	return bytes[..magic.len] == magic
}

fn file_has_bytes_at(path string, offset int, magic []u8) bool {
	bytes := read_file_prefix(path, offset + magic.len) or { return false }
	if bytes.len < offset + magic.len {
		return false
	}
	return bytes[offset..offset + magic.len] == magic
}

fn file_prefix_contains(path string, magic []u8) bool {
	bytes := read_file_prefix(path, 4096) or { return false }
	if bytes.len < magic.len { return false }
	for index in 0 .. bytes.len - magic.len + 1 {
		if bytes[index..index + magic.len] == magic { return true }
	}
	return false
}

fn read_file_prefix(path string, length int) ![]u8 {
	mut file := os.open(path)!
	defer {
		file.close()
	}
	mut bytes := []u8{len: length}
	read := file.read(mut bytes) or { 0 }
	return bytes[..read].clone()
}
