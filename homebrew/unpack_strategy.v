module homebrew

import homebrew.unpack_strategy

// Translated from Homebrew/brew `unpack_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `extensions; end` at line 28.
pub fn ruby_unpack_strategy_l28_d1_extensions(kind unpack_strategy.StrategyKind) []string {
	return unpack_strategy.extensions(kind)
}

// Ruby method `can_extract?(path); end` at line 31.
pub fn ruby_unpack_strategy_l31_d2_can_extract(kind unpack_strategy.StrategyKind, path string) bool {
	return unpack_strategy.can_extract(kind, path)
}

// Ruby method `self.strategies` at line 37.
pub fn ruby_unpack_strategy_l37_d3_self_strategies() []unpack_strategy.StrategyKind {
	return unpack_strategy.strategies()
}

// Ruby method `self.from_type(type)` at line 76.
pub fn ruby_unpack_strategy_l76_d4_self_from_type(type_name string) ?unpack_strategy.StrategyKind {
	return unpack_strategy.from_type(type_name)
}

// Ruby method `self.from_extension(extension)` at line 94.
pub fn ruby_unpack_strategy_l94_d5_self_from_extension(extension string) ?unpack_strategy.StrategyKind {
	return unpack_strategy.from_extension(extension)
}

// Ruby method `self.from_magic(path)` at line 100.
pub fn ruby_unpack_strategy_l100_d6_self_from_magic(path string) ?unpack_strategy.StrategyKind {
	return unpack_strategy.from_magic(path)
}

// Ruby method `self.detect(path, prioritize_extension: false, type: nil, ref_type: nil, ref: nil, merge_xattrs: false)` at line 108.
pub fn ruby_unpack_strategy_l108_d7_self_detect(path string, options unpack_strategy.DetectOptions) unpack_strategy.Strategy {
	return unpack_strategy.detect(path, options)
}

// Ruby attr_reader `attr_reader :path` at line 126.
pub fn ruby_unpack_strategy_l126_d8_path(strategy unpack_strategy.Strategy) string {
	return strategy.path
}

// Ruby attr_reader `attr_reader :merge_xattrs` at line 129.
pub fn ruby_unpack_strategy_l129_d9_merge_xattrs(strategy unpack_strategy.Strategy) bool {
	return strategy.merge_xattrs
}

// Ruby method `initialize(path, ref_type: nil, ref: nil, merge_xattrs: false)` at line 135.
pub fn ruby_unpack_strategy_l135_d10_initialize(path string, options unpack_strategy.DetectOptions) unpack_strategy.Strategy {
	return unpack_strategy.detect(path, options)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:); end` at line 143.
pub fn ruby_unpack_strategy_l143_d11_extract_to_dir(strategy unpack_strategy.Strategy, options unpack_strategy.ExtractOptions) ! {
	strategy.extract(options)!
}

// Ruby method `extract(to: nil, basename: nil, verbose: false)` at line 151.
pub fn ruby_unpack_strategy_l151_d12_extract(strategy unpack_strategy.Strategy, options unpack_strategy.ExtractOptions) ! {
	strategy.extract(options)!
}

// Ruby method `extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)` at line 166.
pub fn ruby_unpack_strategy_l166_d13_extract_nestedly(strategy unpack_strategy.Strategy, options unpack_strategy.ExtractOptions) ! {
	strategy.extract_nestedly(options)!
}

// Ruby method `dependencies` at line 197.
pub fn ruby_unpack_strategy_l197_d14_dependencies(strategy unpack_strategy.Strategy) []string {
	return strategy.dependencies()
}

// Ruby method `each_directory(pathname, &_block)` at line 208.
pub fn ruby_unpack_strategy_l208_d15_each_directory(path string) ![]string {
	return unpack_strategy.each_directory(path)
}

// unpack_detect exposes the translated dispatcher to Resource and download
// staging without coupling those callers to Ruby-style compatibility names.
pub fn unpack_detect(path string, options unpack_strategy.DetectOptions) unpack_strategy.Strategy {
	return unpack_strategy.detect(path, options)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "mktemp"
// 5: require "system_command"
// 6: require "utils/output"
// 7: require "utils/path"
// 8:
// 9: # Module containing all available strategies for unpacking archives.
// 10: module UnpackStrategy
// 11:   extend T::Helpers
// 12:   extend Utils::Output::Mixin
// 13:   include SystemCommand::Mixin
// 14:   include Utils::Output::Mixin
// 15:
// 16:   abstract!
// 17:
// 18:   requires_ancestor { Kernel }
// 19:
// 20:   UnpackStrategyType = T.type_alias { T.all(T::Class[UnpackStrategy], UnpackStrategy::ClassMethods) }
// 21:
// 22:   module ClassMethods
// 23:     extend T::Helpers
// 24:
// 25:     abstract!
// 26:
// 27:     sig { abstract.returns(T::Array[String]) }
// 28:     def extensions; end
// 29:
// 30:     sig { abstract.params(path: Pathname).returns(T::Boolean) }
// 31:     def can_extract?(path); end
// 32:   end
// 33:
// 34:   mixes_in_class_methods(ClassMethods)
// 35:
// 36:   sig { returns(T::Array[UnpackStrategyType]) }
// 37:   def self.strategies
// 38:     @strategies ||= T.let([
// 39:       Tar, # Needs to be before Bzip2/Gzip/Xz/Lzma/Zstd.
// 40:       Pax,
// 41:       Gzip,
// 42:       Dmg, # Needs to be before Bzip2/Xz/Lzma.
// 43:       Lzma,
// 44:       Xz,
// 45:       Zstd,
// 46:       Lzip,
// 47:       Air, # Needs to be before `Zip`.
// 48:       Jar, # Needs to be before `Zip`.
// 49:       LuaRock, # Needs to be before `Zip`.
// 50:       MicrosoftOfficeXml, # Needs to be before `Zip`.
// 51:       Zip,
// 52:       Pkg, # Needs to be before `Xar`.
// 53:       Xar,
// 54:       Ttf,
// 55:       Otf,
// 56:       Git,
// 57:       Mercurial,
// 58:       Subversion,
// 59:       Cvs,
// 60:       SelfExtractingExecutable, # Needs to be before `Cab`.
// 61:       Cab,
// 62:       Executable,
// 63:       Bzip2,
// 64:       Fossil,
// 65:       Bazaar,
// 66:       Compress,
// 67:       P7Zip,
// 68:       Sit,
// 69:       Rar,
// 70:       Lha,
// 71:     ].freeze, T.nilable(T::Array[UnpackStrategyType]))
// 72:   end
// 73:   private_class_method :strategies
// 74:
// 75:   sig { params(type: Symbol).returns(T.nilable(UnpackStrategyType)) }
// 76:   def self.from_type(type)
// 77:     type = {
// 78:       naked:     :uncompressed,
// 79:       nounzip:   :uncompressed,
// 80:       seven_zip: :p7zip,
// 81:     }.fetch(type, type)
// 82:
// 83:     begin
// 84:       # The strategy class name is derived dynamically from the type.
// 85:       # rubocop:disable Sorbet/ConstantsFromStrings
// 86:       const_get(type.to_s.split("_").map(&:capitalize).join.gsub(/\d+[a-z]/, &:upcase))
// 87:       # rubocop:enable Sorbet/ConstantsFromStrings
// 88:     rescue NameError
// 89:       nil
// 90:     end
// 91:   end
// 92:
// 93:   sig { params(extension: String).returns(T.nilable(UnpackStrategyType)) }
// 94:   def self.from_extension(extension)
// 95:     strategies.sort_by { |s| -(s.extensions.map(&:length).max || 0) }
// 96:               .find { |s| extension.end_with?(*s.extensions) }
// 97:   end
// 98:
// 99:   sig { params(path: Pathname).returns(T.nilable(UnpackStrategyType)) }
// 100:   def self.from_magic(path)
// 101:     strategies.find { |s| s.can_extract?(path) }
// 102:   end
// 103:
// 104:   sig {
// 105:     params(path: Pathname, prioritize_extension: T::Boolean, type: T.nilable(Symbol), ref_type: T.nilable(Symbol),
// 106:            ref: T.nilable(String), merge_xattrs: T::Boolean).returns(UnpackStrategy)
// 107:   }
// 108:   def self.detect(path, prioritize_extension: false, type: nil, ref_type: nil, ref: nil, merge_xattrs: false)
// 109:     strategy = from_type(type) if type
// 110:
// 111:     if prioritize_extension && path.extname.present?
// 112:       strategy ||= from_extension(path.extname)
// 113:
// 114:       strategy ||= strategies.find { |s| (s < Directory || s == Fossil) && s.can_extract?(path) }
// 115:     else
// 116:       strategy ||= from_magic(path)
// 117:       strategy ||= from_extension(path.extname)
// 118:     end
// 119:
// 120:     strategy ||= Uncompressed
// 121:
// 122:     strategy.new(path, ref_type:, ref:, merge_xattrs:)
// 123:   end
// 124:
// 125:   sig { returns(Pathname) }
// 126:   attr_reader :path
// 127:
// 128:   sig { returns(T::Boolean) }
// 129:   attr_reader :merge_xattrs
// 130:
// 131:   sig {
// 132:     params(path: T.any(String, Pathname), ref_type: T.nilable(Symbol), ref: T.nilable(String),
// 133:            merge_xattrs: T::Boolean).void
// 134:   }
// 135:   def initialize(path, ref_type: nil, ref: nil, merge_xattrs: false)
// 136:     @path = T.let(Pathname(path).expand_path, Pathname)
// 137:     @ref_type = ref_type
// 138:     @ref = ref
// 139:     @merge_xattrs = merge_xattrs
// 140:   end
// 141:
// 142:   sig { abstract.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 143:   def extract_to_dir(unpack_dir, basename:, verbose:); end
// 144:   private :extract_to_dir
// 145:
// 146:   sig {
// 147:     params(
// 148:       to: T.nilable(Pathname), basename: T.nilable(T.any(String, Pathname)), verbose: T::Boolean,
// 149:     ).void
// 150:   }
// 151:   def extract(to: nil, basename: nil, verbose: false)
// 152:     basename ||= path.basename
// 153:     unpack_dir = Pathname(to || Dir.pwd).expand_path
// 154:     unpack_dir.mkpath
// 155:     extract_to_dir(unpack_dir, basename: Pathname(basename), verbose:)
// 156:   end
// 157:
// 158:   sig {
// 159:     params(
// 160:       to:                   T.nilable(Pathname),
// 161:       basename:             T.nilable(T.any(String, Pathname)),
// 162:       verbose:              T::Boolean,
// 163:       prioritize_extension: T::Boolean,
// 164:     ).void
// 165:   }
// 166:   def extract_nestedly(to: nil, basename: nil, verbose: false, prioritize_extension: false)
// 167:     Mktemp.new("homebrew-unpack").run(chdir: false) do |unpack_dir|
// 168:       tmp_unpack_dir = T.must(unpack_dir.tmpdir)
// 169:
// 170:       extract(to: tmp_unpack_dir, basename:, verbose:)
// 171:
// 172:       children = tmp_unpack_dir.children
// 173:
// 174:       if children.size == 1 && !children.fetch(0).directory?
// 175:         first_child = children.first
// 176:         next if first_child.nil?
// 177:
// 178:         s = UnpackStrategy.detect(first_child, prioritize_extension:)
// 179:
// 180:         s.extract_nestedly(to:, verbose:, prioritize_extension:)
// 181:
// 182:         next
// 183:       end
// 184:
// 185:       # Ensure all extracted directories are writable.
// 186:       each_directory(tmp_unpack_dir) do |path|
// 187:         next if path.writable?
// 188:
// 189:         FileUtils.chmod "u+w", path, verbose:
// 190:       end
// 191:
// 192:       Directory.new(tmp_unpack_dir, move: true).extract(to:, verbose:)
// 193:     end
// 194:   end
// 195:
// 196:   sig { returns(T.any(T::Array[Cask::Cask], T::Array[Formula])) }
// 197:   def dependencies
// 198:     []
// 199:   end
// 200:
// 201:   # Helper method for iterating over directory trees.
// 202:   sig {
// 203:     params(
// 204:       pathname: Pathname,
// 205:       _block:   T.proc.params(path: Pathname).void,
// 206:     ).void
// 207:   }
// 208:   def each_directory(pathname, &_block)
// 209:     pathname.find do |path|
// 210:       yield path if path.directory?
// 211:     end
// 212:   end
// 213: end
// 214:
// 215: require "unpack_strategy/air"
// 216: require "unpack_strategy/bazaar"
// 217: require "unpack_strategy/bzip2"
// 218: require "unpack_strategy/cab"
// 219: require "unpack_strategy/compress"
// 220: require "unpack_strategy/cvs"
// 221: require "unpack_strategy/directory"
// 222: require "unpack_strategy/dmg"
// 223: require "unpack_strategy/executable"
// 224: require "unpack_strategy/fossil"
// 225: require "unpack_strategy/generic_unar"
// 226: require "unpack_strategy/git"
// 227: require "unpack_strategy/gzip"
// 228: require "unpack_strategy/jar"
// 229: require "unpack_strategy/lha"
// 230: require "unpack_strategy/lua_rock"
// 231: require "unpack_strategy/lzip"
// 232: require "unpack_strategy/lzma"
// 233: require "unpack_strategy/mercurial"
// 234: require "unpack_strategy/microsoft_office_xml"
// 235: require "unpack_strategy/otf"
// 236: require "unpack_strategy/p7zip"
// 237: require "unpack_strategy/pax"
// 238: require "unpack_strategy/pkg"
// 239: require "unpack_strategy/rar"
// 240: require "unpack_strategy/self_extracting_executable"
// 241: require "unpack_strategy/sit"
// 242: require "unpack_strategy/subversion"
// 243: require "unpack_strategy/tar"
// 244: require "unpack_strategy/ttf"
// 245: require "unpack_strategy/uncompressed"
// 246: require "unpack_strategy/xar"
// 247: require "unpack_strategy/xz"
// 248: require "unpack_strategy/zip"
// 249: require "unpack_strategy/zstd"
