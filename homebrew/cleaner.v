module homebrew

import ruby
import homebrew.extend
import homebrew.extend.file
import homebrew.language
import homebrew.utils
import os

// Translated from Homebrew/brew `cleaner.rb`.
pub struct CleanerObserver {
pub mut:
	n                   int
	d                   int
	removed_files       []string
	removed_directories []string
	removed_symlinks    []string
	permissioned_files  []string
	rewritten_shebangs  []string
	modified_metadata   []string
}

pub fn (observer CleanerObserver) total() int {
	return observer.n + observer.d
}

@[heap]
pub struct Cleaner {
pub:
	formula Formula
pub mut:
	observer CleanerObserver
}

pub fn new_cleaner(formula Formula) &Cleaner {
	return &Cleaner{
		formula: formula
	}
}

fn cleaner_boundary_value(cleaner &Cleaner) ruby.Value {
	return ruby.structured_value('Cleaner', '#<Cleaner: ${cleaner.formula.full_name()}>', {
		'cleaner_address': u64(voidptr(cleaner)).str()
		'formula':         cleaner.formula.full_name()
		'prefix':          cleaner.formula.prefix()
	})
}

fn cleaner_from_args(args []ruby.Value, method string) &Cleaner {
	if args.len == 0 {
		panic('Cleaner#${method} requires a receiver')
	}
	if args[0].type_name != 'Cleaner' {
		panic('expected Cleaner, got ${args[0].type_name}')
	}
	address := args[0].attribute('cleaner_address') or {
		panic('Cleaner receiver has no translated state')
	}
	return unsafe { &Cleaner(voidptr(address.u64())) }
}

fn cleaner_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn cleaner_error(err IError) ruby.Value {
	return ruby.object_value('IOError', err.msg())
}

fn (cleaner Cleaner) prefix_path(parts ...string) string {
	mut path := cleaner.formula.prefix()
	for part in parts {
		path = os.join_path(path, part)
	}
	return path
}

fn (cleaner Cleaner) skip_clean(path string) bool {
	if os.file_ext(path) == '.la' && ':la' in cleaner.formula.skip_clean_path_values {
		return true
	}
	prefix := os.norm_path(cleaner.formula.prefix()).trim_right(os.path_separator)
	normalized := os.norm_path(path)
	relative := if normalized == prefix {
		''
	} else if normalized.starts_with('${prefix}${os.path_separator}') {
		normalized[prefix.len + 1..]
	} else {
		normalized
	}
	return relative in cleaner.formula.skip_clean_path_values
}

fn cleaner_children(path string) ![]string {
	mut names := os.ls(path)!
	names.sort()
	return names.map(os.join_path(path, it))
}

fn cleaner_walk(path string, visit fn (string) !bool) ! {
	if !os.exists(path) && !os.is_link(path) {
		return
	}
	prune := visit(path)!
	if prune || os.is_link(path) || !os.is_dir(path) {
		return
	}
	for child in cleaner_children(path)! {
		cleaner_walk(child, visit)!
	}
}

fn (mut cleaner Cleaner) observed_unlink(path string) ! {
	os.rm(path)!
	cleaner.observer.n++
	cleaner.observer.removed_files << path
}

// Clean the formula's installed prefix in the same sequence as Cleaner#clean.
pub fn (mut cleaner Cleaner) clean() ! {
	cleaner.observer = CleanerObserver{}
	prefix := cleaner.formula.prefix()
	if !os.exists(prefix) && !os.is_link(prefix) {
		return
	}

	cleaner.observe_file_removal(cleaner.prefix_path('lib', 'charset.alias'))!
	for directory in [cleaner.prefix_path('bin'), cleaner.prefix_path('sbin'),
		cleaner.prefix_path('lib')] {
		if os.exists(directory) {
			cleaner.clean_dir(directory)!
		}
	}

	info := cleaner.prefix_path('share', 'info')
	name_info_dir := os.join_path(os.join_path(info, cleaner.formula.name()), 'dir')
	if os.is_dir(info) {
		cleaner_walk(info, fn [mut cleaner, name_info_dir] (path string) !bool {
			if os.is_file(path) && os.base(path) == 'dir' && os.norm_path(path) != os.norm_path(name_info_dir) && !cleaner.skip_clean(path) {
				cleaner.observe_file_removal(path)!
			}
			return false
		})!
	}

	cleaner.rewrite_shebangs()!
	cleaner.clean_python_metadata()!
	cleaner.prune()!
}

// Remove a present path through the observer, matching the extension's unlink
// count and leaving missing or dangling paths alone.
pub fn (mut cleaner Cleaner) observe_file_removal(path string) ! {
	if os.exists(path) {
		cleaner.observed_unlink(path)!
	}
}

fn (mut cleaner Cleaner) collect_prune_paths(path string, mut directories []string,
	mut symlinks []string) !bool {
	if os.norm_path(path) == os.norm_path(cleaner.prefix_path('libexec')) || cleaner.skip_clean(path) {
		return true
	}
	if os.is_link(path) {
		symlinks << path
		return true
	}
	if os.is_dir(path) {
		directories << path
	}
	return false
}

fn (mut cleaner Cleaner) collect_prune_tree(path string, mut directories []string,
	mut symlinks []string) ! {
	if !os.exists(path) && !os.is_link(path) {
		return
	}
	prune := cleaner.collect_prune_paths(path, mut directories, mut symlinks)!
	if prune || os.is_link(path) || !os.is_dir(path) {
		return
	}
	for child in cleaner_children(path)! {
		cleaner.collect_prune_tree(child, mut directories, mut symlinks)!
	}
}

// Remove empty directories bottom-up, then remove links whose targets no
// longer resolve. Neither operation is observer-extended in the Ruby source.
pub fn (mut cleaner Cleaner) prune() ! {
	prefix := cleaner.formula.prefix()
	if !os.exists(prefix) && !os.is_link(prefix) {
		return
	}
	mut directories := []string{}
	mut symlinks := []string{}
	cleaner.collect_prune_tree(prefix, mut directories, mut symlinks)!
	for index := directories.len - 1; index >= 0; index-- {
		directory := directories[index]
		if os.is_dir(directory) && !os.is_link(directory) && (os.ls(directory) or { []string{} }).len == 0 {
			os.rmdir(directory)!
			cleaner.observer.removed_directories << directory
		}
	}
	for index := symlinks.len - 1; index >= 0; index-- {
		symlink := symlinks[index]
		if os.is_link(symlink) && !os.exists(symlink) {
			os.rm(symlink)!
			cleaner.observer.removed_symlinks << symlink
		}
	}
}

fn cleaner_u32_be(data []u8, offset int) u32 {
	if offset < 0 || offset + 4 > data.len {
		return 0
	}
	return (u32(data[offset]) << 24) | (u32(data[offset + 1]) << 16) | (u32(data[offset + 2]) << 8) | u32(data[offset + 3])
}

fn cleaner_u32_le(data []u8, offset int) u32 {
	if offset < 0 || offset + 4 > data.len {
		return 0
	}
	return u32(data[offset]) | (u32(data[offset + 1]) << 8) | (u32(data[offset + 2]) << 16) | (u32(data[offset + 3]) << 24)
}

fn cleaner_macho_executable_at(data []u8, offset int) bool {
	magic := cleaner_u32_be(data, offset)
	return match magic {
		0xfeedface, 0xfeedfacf { cleaner_u32_be(data, offset + 12) == 2 }
		0xcefaedfe, 0xcffaedfe { cleaner_u32_le(data, offset + 12) == 2 }
		else { false }
	}
}

fn cleaner_macho_executable(data []u8) bool {
	if cleaner_macho_executable_at(data, 0) {
		return true
	}
	magic := cleaner_u32_be(data, 0)
	if magic !in [u32(0xcafebabe), 0xbebafeca, 0xcafebabf, 0xbfbafeca] {
		return false
	}
	little := magic in [u32(0xbebafeca), 0xbfbafeca]
	fat64 := magic in [u32(0xcafebabf), 0xbfbafeca]
	architectures := int(if little { cleaner_u32_le(data, 4) } else { cleaner_u32_be(data, 4) })
	entry_size := if fat64 { 32 } else { 20 }
	for index in 0 .. architectures {
		entry := 8 + index * entry_size
		slice_offset := int(if little {
			cleaner_u32_le(data, entry + 8)
		} else {
			cleaner_u32_be(data, entry + 8)
		})
		if cleaner_macho_executable_at(data, slice_offset) {
			return true
		}
	}
	return false
}

fn cleaner_elf(data []u8) bool {
	return data.len > 7 && data[0] == 0x7f && data[1] == `E` && data[2] == `L` && data[3] == `F` && data[7] in [
		u8(0),
		3,
	]
}

// The platform overrides in extend/os/cleaner treat text shebangs first, then
// Mach-O executables on macOS or every ELF object on Linux.
pub fn (cleaner Cleaner) executable_path(path string) bool {
	_ = cleaner
	if extend.pathname_text_executable(path) or { false } {
		return true
	}
	data := os.read_bytes(path) or { return false }
	$if macos {
		return cleaner_macho_executable(data)
	} $else $if linux {
		return cleaner_elf(data)
	} $else {
		mode := os.stat(path) or { return false }
		return mode.get_mode().bitmask() & 0o111 != 0
	}
}

// Recursively remove package-manager metadata and normalize ordinary file
// modes while pruning every explicitly protected subtree.
pub fn (mut cleaner Cleaner) clean_dir(directory string) ! {
	cleaner_walk(directory, fn [mut cleaner] (path string) !bool {
		if cleaner.skip_clean(path) {
			return true
		}
		if os.is_dir(path) {
			return false
		}
		extension := os.file_ext(path)
		if extension in ['.la', '.tbd'] || os.base(path) in ['perllocal.pod', '.packlist'] {
			cleaner.observed_unlink(path)!
		} else if !os.is_link(path) {
			permissions := if cleaner.executable_path(path) { 0o555 } else { 0o444 }
			os.chmod(path, permissions)!
			cleaner.observer.permissioned_files << path
		}
		return os.is_link(path)
	})!
}

fn (cleaner Cleaner) declared_node_dependencies() []language.NodeDependency {
	return cleaner.formula.deps().map(language.NodeDependency{
		name: it.name
		required: it.required()
	})
}

fn (cleaner Cleaner) declared_perl_dependencies() []language.PerlDependency {
	return cleaner.formula.deps().map(language.PerlDependency{
		name: it.name
		required: it.required()
		uses_from_macos: it.uses_from_macos_dependency()
		use_macos_install: false
	})
}

// Detect the two language rewrites independently; a detection failure omits
// only that rewrite, as the Ruby rescue inside filter_map does.
pub fn (mut cleaner Cleaner) rewrite_shebangs() ! {
	mut rewrites := []utils.RewriteInfo{}
	if node := language.detected_node_shebang(cleaner.declared_node_dependencies(), cleaner.formula.prefix_root) {
		rewrites << node
	}
	if perl := language.detected_perl_shebang(cleaner.declared_perl_dependencies(), cleaner.formula.prefix_root, '') {
		rewrites << perl
	}
	if rewrites.len == 0 {
		return
	}
	prefix := os.real_path(cleaner.formula.prefix())
	cleaner_walk(prefix, fn [mut cleaner, rewrites] (path string) !bool {
		if cleaner.skip_clean(path) {
			return true
		}
		if os.is_dir(path) || os.is_link(path) {
			return os.is_link(path)
		}
		for rewrite in rewrites {
			if utils.rewrite_shebang(rewrite, [path])! > 0 {
				cleaner.observer.rewritten_shebangs << path
			}
		}
		return false
	})!
}

// Remove non-reproducible Python installation records and atomically replace
// INSTALLER while preserving its mode and ownership.
pub fn (mut cleaner Cleaner) clean_python_metadata() ! {
	prefix := cleaner.formula.prefix()
	if !os.exists(prefix) {
		return
	}
	basepath := os.real_path(prefix)
	cleaner_walk(basepath, fn [mut cleaner] (path string) !bool {
		if cleaner.skip_clean(path) {
			return true
		}
		if os.is_dir(path) || os.is_link(path) {
			return os.is_link(path)
		}
		if os.file_ext(os.dir(path)) != '.dist-info' {
			return false
		}
		match os.base(path) {
			'direct_url.json', 'RECORD' {
				cleaner.observe_file_removal(path)!
			}
			'INSTALLER' {
				file.atomic_write_contents(path, os.dir(path), 'brew\n')!
				cleaner.observer.modified_metadata << path
			}
			else {}
		}
		return false
	})!
}
