module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/keg_relocate.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `file_linked_libraries(file, string)` at line 13.
pub fn ruby_keg_relocate_l13_d1_file_linked_libraries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_linked_libraries', ...args)
}

// Ruby method `relocate_dynamic_linkage(relocation, skip_protodesc_cold: false)` at line 27.
pub fn ruby_keg_relocate_l27_d2_relocate_dynamic_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocate_dynamic_linkage', ...args)
}

// Ruby method `fix_dynamic_linkage` at line 58.
pub fn ruby_keg_relocate_l58_d3_fix_dynamic_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fix_dynamic_linkage', ...args)
}

// Ruby method `loader_name_for(file, target)` at line 107.
pub fn ruby_keg_relocate_l107_d4_loader_name_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loader_name_for', ...args)
}

// Ruby method `fixed_name(file, bad_name)` at line 123.
pub fn ruby_keg_relocate_l123_d5_fixed_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixed_name', ...args)
}

// Ruby method `each_linkage_for(file, linkage_type, resolve_variable_references: false, &block)` at line 145.
pub fn ruby_keg_relocate_l145_d6_each_linkage_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_linkage_for', ...args)
}

// Ruby method `dylib_id_for(file)` at line 152.
pub fn ruby_keg_relocate_l152_d7_dylib_id_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dylib_id_for', ...args)
}

// Ruby method `formula_preserve_rpath?` at line 168.
pub fn ruby_keg_relocate_l168_d8_formula_preserve_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_preserve_rpath?', ...args)
}

// Ruby method `relocated_name_for(old_name, relocation)` at line 175.
pub fn ruby_keg_relocate_l175_d9_relocated_name_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocated_name_for', ...args)
}

// Ruby method `find_dylib_suffix_from(bad_name)` at line 191.
pub fn ruby_keg_relocate_l191_d10_find_dylib_suffix_from(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_dylib_suffix_from', ...args)
}

// Ruby method `find_dylib(bad_name)` at line 200.
pub fn ruby_keg_relocate_l200_d11_find_dylib(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_dylib', ...args)
}

// Ruby method `mach_o_files` at line 208.
pub fn ruby_keg_relocate_l208_d12_mach_o_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mach_o_files', ...args)
}

// Ruby method `prepare_relocation_to_locations` at line 228.
pub fn ruby_keg_relocate_l228_d13_prepare_relocation_to_locations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepare_relocation_to_locations', ...args)
}

// Ruby method `recursive_fgrep_args` at line 257.
pub fn ruby_keg_relocate_l257_d14_recursive_fgrep_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_fgrep_args', ...args)
}

// Ruby method `egrep_args` at line 264.
pub fn ruby_keg_relocate_l264_d15_egrep_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('egrep_args', ...args)
}

// Ruby method `opt_name_for(filename)` at line 278.
pub fn ruby_keg_relocate_l278_d16_opt_name_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opt_name_for', ...args)
}

// Ruby method `rooted_in_build_directory?(filename)` at line 287.
pub fn ruby_keg_relocate_l287_d17_rooted_in_build_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rooted_in_build_directory?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Keg
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::Keg }
// 10:
// 11:       module ClassMethods
// 12:         sig { params(file: ::Pathname, string: String).returns(T::Array[String]) }
// 13:         def file_linked_libraries(file, string)
// 14:           file = MachOPathname.wrap(file)
// 15:
// 16:           # Check dynamic library linkage. Importantly, do not perform for static
// 17:           # libraries, which will falsely report "linkage" to themselves.
// 18:           if file.mach_o_executable? || file.dylib? || file.mach_o_bundle?
// 19:             file.dynamically_linked_libraries.select { |lib| lib.include? string }
// 20:           else
// 21:             []
// 22:           end
// 23:         end
// 24:       end
// 25:
// 26:       sig { params(relocation: ::Keg::Relocation, skip_protodesc_cold: T::Boolean).void }
// 27:       def relocate_dynamic_linkage(relocation, skip_protodesc_cold: false)
// 28:         mach_o_files.each do |file|
// 29:           file.ensure_writable do
// 30:             modified = T.let(false, T::Boolean)
// 31:             needs_codesigning = T.let(false, T::Boolean)
// 32:
// 33:             if file.dylib? && (dylib_id = file.dylib_id)
// 34:               id = relocated_name_for(dylib_id, relocation)
// 35:               modified = change_dylib_id(id, file) if id
// 36:               needs_codesigning ||= modified
// 37:             end
// 38:
// 39:             each_linkage_for(file, :dynamically_linked_libraries) do |old_name|
// 40:               new_name = relocated_name_for(old_name, relocation)
// 41:               modified = change_install_name(old_name, new_name, file) if new_name
// 42:               needs_codesigning ||= modified
// 43:             end
// 44:
// 45:             each_linkage_for(file, :rpaths) do |old_name|
// 46:               new_name = relocated_name_for(old_name, relocation)
// 47:               modified = change_rpath(old_name, new_name, file) if new_name
// 48:               needs_codesigning ||= modified
// 49:             end
// 50:
// 51:             # codesign the file if needed
// 52:             codesign_patched_binary(file.to_s) if needs_codesigning
// 53:           end
// 54:         end
// 55:       end
// 56:
// 57:       sig { void }
// 58:       def fix_dynamic_linkage
// 59:         mach_o_files.each do |file|
// 60:           file.ensure_writable do
// 61:             modified = T.let(false, T::Boolean)
// 62:             needs_codesigning = T.let(false, T::Boolean)
// 63:
// 64:             modified = change_dylib_id(dylib_id_for(file), file) if file.dylib?
// 65:             needs_codesigning ||= modified
// 66:
// 67:             each_linkage_for(file, :dynamically_linked_libraries) do |bad_name|
// 68:               # Don't fix absolute paths unless they are rooted in the build directory.
// 69:               new_name = if bad_name.start_with?("/") && !rooted_in_build_directory?(bad_name)
// 70:                 bad_name
// 71:               else
// 72:                 fixed_name(file, bad_name)
// 73:               end
// 74:               loader_name = loader_name_for(file, new_name)
// 75:               modified = change_install_name(bad_name, loader_name, file) if loader_name != bad_name
// 76:               needs_codesigning ||= modified
// 77:             end
// 78:
// 79:             each_linkage_for(file, :rpaths) do |bad_name|
// 80:               new_name = opt_name_for(bad_name)
// 81:               loader_name = loader_name_for(file, new_name)
// 82:               next if loader_name == bad_name
// 83:
// 84:               modified = change_rpath(bad_name, loader_name, file)
// 85:               needs_codesigning ||= modified
// 86:             end
// 87:
// 88:             # Strip duplicate rpaths and rpaths rooted in the build directory.
// 89:             # We do this separately from the rpath relocation above to avoid
// 90:             # failing to relocate an rpath whose variable duplicate we deleted.
// 91:             each_linkage_for(file, :rpaths, resolve_variable_references: true) do |bad_name|
// 92:               next if !rooted_in_build_directory?(bad_name) && file.rpaths.count(bad_name) == 1
// 93:
// 94:               modified = delete_rpath(bad_name, file)
// 95:               needs_codesigning ||= modified
// 96:             end
// 97:
// 98:             # codesign the file if needed
// 99:             codesign_patched_binary(file.to_s) if needs_codesigning
// 100:           end
// 101:         end
// 102:
// 103:         super
// 104:       end
// 105:
// 106:       sig { params(file: MachOShim, target: String).returns(String) }
// 107:       def loader_name_for(file, target)
// 108:         # Use @loader_path-relative install names for other Homebrew-installed binaries.
// 109:         if ENV["HOMEBREW_RELOCATABLE_INSTALL_NAMES"] && target.start_with?(HOMEBREW_PREFIX)
// 110:           dylib_suffix = find_dylib_suffix_from(target)
// 111:           target_dir = ::Pathname.new(target.delete_suffix(dylib_suffix)).cleanpath
// 112:
// 113:           "@loader_path/#{target_dir.relative_path_from(file.dirname)/dylib_suffix}"
// 114:         else
// 115:           target
// 116:         end
// 117:       end
// 118:
// 119:       # If file is a dylib or bundle itself, look for the dylib named by
// 120:       # bad_name relative to the lib directory, so that we can skip the more
// 121:       # expensive recursive search if possible.
// 122:       sig { params(file: MachOShim, bad_name: String).returns(String) }
// 123:       def fixed_name(file, bad_name)
// 124:         if bad_name.start_with? ::Keg::PREFIX_PLACEHOLDER
// 125:           bad_name.sub(::Keg::PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 126:         elsif bad_name.start_with? ::Keg::CELLAR_PLACEHOLDER
// 127:           bad_name.sub(::Keg::CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 128:         elsif (file.dylib? || file.mach_o_bundle?) && (file.dirname/bad_name).exist?
// 129:           "@loader_path/#{bad_name}"
// 130:         elsif file.mach_o_executable? && (lib/bad_name).exist?
// 131:           "#{lib}/#{bad_name}"
// 132:         elsif file.mach_o_executable? && (libexec/"lib"/bad_name).exist?
// 133:           "#{libexec}/lib/#{bad_name}"
// 134:         elsif (abs_name = find_dylib(bad_name)) && abs_name.exist?
// 135:           abs_name.to_s
// 136:         else
// 137:           opoo "Could not fix #{bad_name} in #{file}"
// 138:           bad_name
// 139:         end
// 140:       end
// 141:
// 142:       VARIABLE_REFERENCE_RX = /^@(loader_|executable_|r)path/
// 143:
// 144:       sig { params(file: MachOShim, linkage_type: Symbol, resolve_variable_references: T::Boolean, block: T.proc.params(arg0: String).void).void }
// 145:       def each_linkage_for(file, linkage_type, resolve_variable_references: false, &block)
// 146:         file.public_send(linkage_type, resolve_variable_references:)
// 147:             .grep_v(VARIABLE_REFERENCE_RX)
// 148:             .each(&block)
// 149:       end
// 150:
// 151:       sig { params(file: MachOShim).returns(String) }
// 152:       def dylib_id_for(file)
// 153:         dylib_id = T.must(file.dylib_id)
// 154:         # Swift dylib IDs should be /usr/lib/swift
// 155:         return dylib_id if dylib_id.start_with?("/usr/lib/swift/libswift")
// 156:
// 157:         # Preserve @rpath install names if the formula has specified preserve_rpath
// 158:         return dylib_id if dylib_id.start_with?("@rpath") && formula_preserve_rpath?
// 159:
// 160:         # The new dylib ID should have the same basename as the old dylib ID, not
// 161:         # the basename of the file itself.
// 162:         basename = File.basename(dylib_id)
// 163:         relative_dirname = file.dirname.relative_path_from(path)
// 164:         (opt_record/relative_dirname/basename).to_s
// 165:       end
// 166:
// 167:       sig { returns(T::Boolean) }
// 168:       def formula_preserve_rpath?
// 169:         ::Formula[name].preserve_rpath?
// 170:       rescue FormulaUnavailableError
// 171:         false
// 172:       end
// 173:
// 174:       sig { params(old_name: String, relocation: ::Keg::Relocation).returns(T.nilable(String)) }
// 175:       def relocated_name_for(old_name, relocation)
// 176:         old_prefix, new_prefix = relocation.replacement_pair_for(:prefix)
// 177:         old_cellar, new_cellar = relocation.replacement_pair_for(:cellar)
// 178:
// 179:         if old_name.start_with? old_cellar
// 180:           old_name.sub(old_cellar, new_cellar)
// 181:         elsif old_name.start_with? old_prefix
// 182:           old_name.sub(old_prefix, new_prefix)
// 183:         end
// 184:       end
// 185:
// 186:       # Matches framework references like `XXX.framework/Versions/YYY/XXX` and
// 187:       # `XXX.framework/XXX`, both with or without a slash-delimited prefix.
// 188:       FRAMEWORK_RX = %r{(?:^|/)(([^/]+)\.framework/(?:Versions/[^/]+/)?\2)$}
// 189:
// 190:       sig { params(bad_name: String).returns(String) }
// 191:       def find_dylib_suffix_from(bad_name)
// 192:         if (framework = bad_name.match(FRAMEWORK_RX))
// 193:           T.must(framework[1])
// 194:         else
// 195:           File.basename(bad_name)
// 196:         end
// 197:       end
// 198:
// 199:       sig { params(bad_name: String).returns(T.nilable(::Pathname)) }
// 200:       def find_dylib(bad_name)
// 201:         return unless lib.directory?
// 202:
// 203:         suffix = "/#{find_dylib_suffix_from(bad_name)}"
// 204:         lib.find { |pn| break pn if pn.to_s.end_with?(suffix) }
// 205:       end
// 206:
// 207:       sig { returns(T::Array[MachOShim]) }
// 208:       def mach_o_files
// 209:         hardlinks = Set.new
// 210:         mach_o_files = []
// 211:         path.find do |pn|
// 212:           next if pn.symlink? || pn.directory?
// 213:
// 214:           pn = MachOPathname.wrap(pn)
// 215:           next if !pn.dylib? && !pn.mach_o_bundle? && !pn.mach_o_executable?
// 216:
// 217:           # if we've already processed a file, ignore its hardlinks (which have the same dev ID and inode)
// 218:           # this prevents relocations from being performed on a binary more than once
// 219:           next unless hardlinks.add? [pn.stat.dev, pn.stat.ino]
// 220:
// 221:           mach_o_files << pn
// 222:         end
// 223:
// 224:         mach_o_files
// 225:       end
// 226:
// 227:       sig { returns(::Keg::Relocation) }
// 228:       def prepare_relocation_to_locations
// 229:         relocation = super
// 230:
// 231:         brewed_perl = runtime_dependencies&.any? do |dep|
// 232:           dep = T.cast(dep, T::Hash[String, T.untyped])
// 233:           dep["full_name"] == "perl" && dep["declared_directly"]
// 234:         end
// 235:         perl_path = if brewed_perl || name == "perl"
// 236:           "#{HOMEBREW_PREFIX}/opt/perl/bin/perl"
// 237:         elsif tab.built_on.present? &&
// 238:               (preferred_perl_version = tab.built_on&.[]("preferred_perl")&.presence) &&
// 239:               preferred_perl_version.match?(/^\d+\.\d+$/) &&
// 240:               (perl_path = "/usr/bin/perl#{preferred_perl_version}") &&
// 241:               File.exist?(perl_path)
// 242:           perl_path
// 243:         else
// 244:           "/usr/bin/perl#{MacOS.preferred_perl_version}"
// 245:         end
// 246:         relocation.add_replacement_pair(:perl, ::Keg::PERL_PLACEHOLDER, perl_path)
// 247:
// 248:         if (openjdk = openjdk_dep_name_if_applicable)
// 249:           openjdk_path = HOMEBREW_PREFIX/"opt"/openjdk/"libexec/openjdk.jdk/Contents/Home"
// 250:           relocation.add_replacement_pair(:java, ::Keg::JAVA_PLACEHOLDER, openjdk_path.to_s)
// 251:         end
// 252:
// 253:         relocation
// 254:       end
// 255:
// 256:       sig { returns(String) }
// 257:       def recursive_fgrep_args
// 258:         # Don't recurse into symlinks; the man page says this is the default, but
// 259:         # it's wrong. -O is a BSD-grep-only option.
// 260:         "-lrO"
// 261:       end
// 262:
// 263:       sig { returns([String, String]) }
// 264:       def egrep_args
// 265:         grep_bin = "egrep"
// 266:         grep_args = "--files-with-matches"
// 267:         [grep_bin, grep_args]
// 268:       end
// 269:
// 270:       private
// 271:
// 272:       CELLAR_RX = %r{\A#{HOMEBREW_CELLAR}/(?<formula_name>[^/]+)/[^/]+}
// 273:       private_constant :CELLAR_RX
// 274:
// 275:       # Replace HOMEBREW_CELLAR references with HOMEBREW_PREFIX/opt references
// 276:       # if the Cellar reference is to a different keg.
// 277:       sig { params(filename: String).returns(String) }
// 278:       def opt_name_for(filename)
// 279:         return filename unless filename.start_with?(HOMEBREW_PREFIX.to_s)
// 280:         return filename if filename.start_with?(path.to_s)
// 281:         return filename if (matches = CELLAR_RX.match(filename)).blank?
// 282:
// 283:         filename.sub(CELLAR_RX, "#{HOMEBREW_PREFIX}/opt/#{matches[:formula_name]}")
// 284:       end
// 285:
// 286:       sig { params(filename: String).returns(T::Boolean) }
// 287:       def rooted_in_build_directory?(filename)
// 288:         # CMake normalises `/private/tmp` to `/tmp`.
// 289:         # https://gitlab.kitware.com/cmake/cmake/-/issues/23251
// 290:         return true if HOMEBREW_TEMP.to_s == "/private/tmp" && filename.start_with?("/tmp/")
// 291:
// 292:         filename.start_with?(HOMEBREW_TEMP.to_s, HOMEBREW_TEMP.realpath.to_s)
// 293:       end
// 294:     end
// 295:   end
// 296: end
// 297:
// 298: Keg.singleton_class.prepend(OS::Mac::Keg::ClassMethods)
// 299: Keg.prepend(OS::Mac::Keg)
