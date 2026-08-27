module homebrew

import brew_runtime

// Translated from Homebrew/brew `cleaner.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 22.
pub fn ruby_cleaner_l22_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `clean` at line 28.
pub fn ruby_cleaner_l28_d2_clean(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clean', ...args)
}

// Ruby method `observe_file_removal(path)` at line 74.
pub fn ruby_cleaner_l74_d3_observe_file_removal(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('observe_file_removal', ...args)
}

// Ruby method `prune` at line 82.
pub fn ruby_cleaner_l82_d4_prune(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prune', ...args)
}

// Ruby method `executable_path?(path)` at line 111.
pub fn ruby_cleaner_l111_d5_executable_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable_path?', ...args)
}

// Ruby method `clean_dir(directory)` at line 132.
pub fn ruby_cleaner_l132_d6_clean_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clean_dir', ...args)
}

// Ruby method `rewrite_shebangs` at line 161.
pub fn ruby_cleaner_l161_d7_rewrite_shebangs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rewrite_shebangs', ...args)
}

// Ruby method `clean_python_metadata` at line 190.
pub fn ruby_cleaner_l190_d8_clean_python_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clean_python_metadata', ...args)
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
