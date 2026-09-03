module homebrew

import brew_runtime
import homebrew.extend
import homebrew.extend.file
import homebrew.language
import homebrew.utils
import os

// Translated from Homebrew/brew `cleaner.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn cleaner_boundary_value(cleaner &Cleaner) brew_runtime.Value {
	return brew_runtime.structured_value('Cleaner', '#<Cleaner: ${cleaner.formula.full_name()}>', {
		'cleaner_address': u64(voidptr(cleaner)).str()
		'formula':         cleaner.formula.full_name()
		'prefix':          cleaner.formula.prefix()
	})
}

fn cleaner_from_args(args []brew_runtime.Value, method string) &Cleaner {
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

fn cleaner_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn cleaner_error(err IError) brew_runtime.Value {
	return brew_runtime.object_value('IOError', err.msg())
}

// Ruby method `initialize(formula)` at line 22.
pub fn ruby_cleaner_l22_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Formula' {
		return brew_runtime.object_value('ArgumentError', 'formula is required')
	}
	return cleaner_boundary_value(new_cleaner(formula_from_boundary(args[0])))
}

// Ruby method `clean` at line 28.
pub fn ruby_cleaner_l28_d2_clean(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'clean')
	cleaner.clean() or { return cleaner_error(err) }
	return cleaner_nil()
}

// Ruby method `observe_file_removal(path)` at line 74.
pub fn ruby_cleaner_l74_d3_observe_file_removal(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'observe_file_removal')
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'path is required')
	}
	cleaner.observe_file_removal(args[1].as_string()) or { return cleaner_error(err) }
	return cleaner_nil()
}

// Ruby method `prune` at line 82.
pub fn ruby_cleaner_l82_d4_prune(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'prune')
	cleaner.prune() or { return cleaner_error(err) }
	return cleaner_nil()
}

// Ruby method `executable_path?(path)` at line 111.
pub fn ruby_cleaner_l111_d5_executable_path(args ...brew_runtime.Value) brew_runtime.Value {
	cleaner := cleaner_from_args(args, 'executable_path?')
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cleaner.executable_path(args[1].as_string()))
}

// Ruby method `clean_dir(directory)` at line 132.
pub fn ruby_cleaner_l132_d6_clean_dir(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'clean_dir')
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'directory is required')
	}
	cleaner.clean_dir(args[1].as_string()) or { return cleaner_error(err) }
	return cleaner_nil()
}

// Ruby method `rewrite_shebangs` at line 161.
pub fn ruby_cleaner_l161_d7_rewrite_shebangs(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'rewrite_shebangs')
	cleaner.rewrite_shebangs() or { return cleaner_error(err) }
	return cleaner_nil()
}

// Ruby method `clean_python_metadata` at line 190.
pub fn ruby_cleaner_l190_d8_clean_python_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	mut cleaner := cleaner_from_args(args, 'clean_python_metadata')
	cleaner.clean_python_metadata() or { return cleaner_error(err) }
	return cleaner_nil()
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

fn cleaner_walk(path string, visit fn(string) !bool) ! {
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Cleans a newly installed keg.
// 7: # By default:
// 8: #
// 9: # * removes `.la` files
// 10: # * removes `.tbd` files
// 11: # * removes `perllocal.pod` files
// 12: # * removes `.packlist` files
// 13: # * removes empty directories
// 14: # * sets permissions on executables
// 15: # * removes unresolved symlinks
// 16: class Cleaner
// 17:   include Context
// 18:   include Utils::Output::Mixin
// 19:
// 20:   # Create a cleaner for the given formula.
// 21:   sig { params(formula: Formula).void }
// 22:   def initialize(formula)
// 23:     @formula = formula
// 24:   end
// 25:
// 26:   # Clean the keg of the formula.
// 27:   sig { void }
// 28:   def clean
// 29:     ObserverPathnameExtension.reset_counts!
// 30:
// 31:     # Many formulae include `lib/charset.alias`, but it is not strictly needed
// 32:     # and will conflict if more than one formula provides it.
// 33:     observe_file_removal @formula.lib/"charset.alias"
// 34:
// 35:     [@formula.bin, @formula.sbin, @formula.lib].each { |dir| clean_dir(dir) if dir.exist? }
// 36:
// 37:     # Get rid of any info `dir` files, so they don't conflict at the link stage.
// 38:     #
// 39:     # The `dir` files come in at least 3 locations:
// 40:     #
// 41:     # 1. `info/dir`
// 42:     # 2. `info/#{name}/dir`
// 43:     # 3. `info/#{arch}/dir`
// 44:     #
// 45:     # Of these 3 only `info/#{name}/dir` is safe to keep since the rest will
// 46:     # conflict with other formulae because they use a shared location.
// 47:     #
// 48:     # See
// 49:     # [cleaner: recursively delete info `dir`s][1],
// 50:     # [emacs 28.1 bottle does not contain `dir` file][2] and
// 51:     # [Keep `info/#{f.name}/dir` files in cleaner][3]
// 52:     # for more info.
// 53:     #
// 54:     # [1]: https://github.com/Homebrew/brew/pull/11597
// 55:     # [2]: https://github.com/Homebrew/homebrew-core/issues/100190
// 56:     # [3]: https://github.com/Homebrew/brew/pull/13215
// 57:     @formula.info.glob("**/dir").each do |info_dir_file|
// 58:       next unless info_dir_file.file?
// 59:       next if info_dir_file == @formula.info/@formula.name/"dir"
// 60:       next if @formula.skip_clean?(info_dir_file)
// 61:
// 62:       observe_file_removal info_dir_file
// 63:     end
// 64:
// 65:     rewrite_shebangs
// 66:     clean_python_metadata
// 67:
// 68:     prune
// 69:   end
// 70:
// 71:   private
// 72:
// 73:   sig { params(path: Pathname).void }
// 74:   def observe_file_removal(path)
// 75:     path.extend(ObserverPathnameExtension).unlink if path.exist?
// 76:   end
// 77:
// 78:   # Removes any empty directories in the formula's prefix subtree
// 79:   # Keeps any empty directories protected by skip_clean
// 80:   # Removes any unresolved symlinks
// 81:   sig { void }
// 82:   def prune
// 83:     dirs = []
// 84:     symlinks = []
// 85:     @formula.prefix.find do |path|
// 86:       if path == @formula.libexec || @formula.skip_clean?(path)
// 87:         Find.prune
// 88:       elsif path.symlink?
// 89:         symlinks << path
// 90:       elsif path.directory?
// 91:         dirs << path
// 92:       end
// 93:     end
// 94:
// 95:     # Remove directories opposite from traversal, so that a subtree with no
// 96:     # actual files gets removed correctly.
// 97:     dirs.reverse_each do |d|
// 98:       if d.children.empty?
// 99:         puts "rmdir: #{d} (empty)" if verbose?
// 100:         d.rmdir
// 101:       end
// 102:     end
// 103:
// 104:     # Remove unresolved symlinks
// 105:     symlinks.reverse_each do |s|
// 106:       s.unlink unless s.resolved_path_exists?
// 107:     end
// 108:   end
// 109:
// 110:   sig { params(path: Pathname).returns(T::Boolean) }
// 111:   def executable_path?(path)
// 112:     path.text_executable? || path.executable?
// 113:   end
// 114:
// 115:   # Both these files are completely unnecessary to package and cause
// 116:   # pointless conflicts with other formulae. They are removed by Debian,
// 117:   # Arch & MacPorts amongst other packagers as well. The files are
// 118:   # created as part of installing any Perl module.
// 119:   PERL_BASENAMES = T.let(Set.new(%w[perllocal.pod .packlist]).freeze, T::Set[String])
// 120:   private_constant :PERL_BASENAMES
// 121:
// 122:   # Clean a top-level (`bin`, `sbin`, `lib`) directory, recursively, by fixing file
// 123:   # permissions and removing .la files, unless the files (or parent
// 124:   # directories) are protected by skip_clean.
// 125:   #
// 126:   # `bin` and `sbin` should not have any subdirectories; if either do that is
// 127:   # caught as an audit warning.
// 128:   #
// 129:   # `lib` may have a large directory tree (see Erlang for instance) and
// 130:   # clean_dir applies cleaning rules to the entire tree.
// 131:   sig { params(directory: Pathname).void }
// 132:   def clean_dir(directory)
// 133:     directory.find do |path|
// 134:       path.extend(ObserverPathnameExtension)
// 135:
// 136:       Find.prune if @formula.skip_clean? path
// 137:
// 138:       next if path.directory?
// 139:
// 140:       if path.extname == ".la" || path.extname == ".tbd" || PERL_BASENAMES.include?(path.basename.to_s)
// 141:         path.unlink
// 142:       elsif path.symlink?
// 143:         # Skip it.
// 144:       else
// 145:         # Set permissions for executables and non-executables.
// 146:         perms = if executable_path?(path)
// 147:           0555
// 148:         else
// 149:           0444
// 150:         end
// 151:         if debug?
// 152:           old_perms = path.stat.mode & 0777
// 153:           odebug "Fixing #{path} permissions from #{old_perms.to_s(8)} to #{perms.to_s(8)}" if perms != old_perms
// 154:         end
// 155:         path.chmod perms
// 156:       end
// 157:     end
// 158:   end
// 159:
// 160:   sig { void }
// 161:   def rewrite_shebangs
// 162:     require "language/node"
// 163:     require "language/perl"
// 164:     require "utils/shebang"
// 165:
// 166:     rewrites = [Language::Node::Shebang.method(:detected_node_shebang),
// 167:                 Language::Perl::Shebang.method(:detected_perl_shebang)].filter_map do |detector|
// 168:       detector.call(@formula)
// 169:     rescue ShebangDetectionError
// 170:       nil
// 171:     end
// 172:     return if rewrites.empty?
// 173:
// 174:     basepath = @formula.prefix.realpath
// 175:     basepath.find do |path|
// 176:       Find.prune if @formula.skip_clean? path
// 177:
// 178:       next if path.directory? || path.symlink?
// 179:
// 180:       rewrites.each { |rw| Utils::Shebang.rewrite_shebang rw, path }
// 181:     end
// 182:   end
// 183:
// 184:   # Remove non-reproducible pip direct_url.json which records the /tmp build directory.
// 185:   # Remove RECORD files to prevent changes to the installed Python package.
// 186:   # Modify INSTALLER to provide information that files are managed by brew.
// 187:   #
// 188:   # @see https://packaging.python.org/en/latest/specifications/recording-installed-packages/
// 189:   sig { void }
// 190:   def clean_python_metadata
// 191:     basepath = @formula.prefix.realpath
// 192:     basepath.find do |path|
// 193:       Find.prune if @formula.skip_clean?(path)
// 194:
// 195:       next if path.directory? || path.symlink?
// 196:       next if path.parent.extname != ".dist-info"
// 197:
// 198:       case path.basename.to_s
// 199:       when "direct_url.json", "RECORD"
// 200:         observe_file_removal path
// 201:       when "INSTALLER"
// 202:         odebug "Modifying #{path} contents from #{path.read.chomp} to brew"
// 203:         path.atomic_write("brew\n")
// 204:       end
// 205:     end
// 206:   end
// 207: end
// 208:
// 209: require "extend/os/cleaner"
