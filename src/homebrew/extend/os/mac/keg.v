module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/keg.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `keg_link_directories` at line 13.
pub fn ruby_keg_l13_d1_keg_link_directories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_link_directories', ...args)
}

// Ruby method `must_exist_subdirectories` at line 18.
pub fn ruby_keg_l18_d2_must_exist_subdirectories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('must_exist_subdirectories', ...args)
}

// Ruby method `must_exist_directories` at line 26.
pub fn ruby_keg_l26_d3_must_exist_directories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('must_exist_directories', ...args)
}

// Ruby method `must_be_writable_directories` at line 34.
pub fn ruby_keg_l34_d4_must_be_writable_directories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('must_be_writable_directories', ...args)
}

// Ruby method `change_dylib_id(id, file)` at line 43.
pub fn ruby_keg_l43_d5_change_dylib_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('change_dylib_id', ...args)
}

// Ruby method `change_install_name(old, new, file)` at line 60.
pub fn ruby_keg_l60_d6_change_install_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('change_install_name', ...args)
}

// Ruby method `change_rpath(old, new, file)` at line 77.
pub fn ruby_keg_l77_d7_change_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('change_rpath', ...args)
}

// Ruby method `delete_rpath(rpath, file)` at line 94.
pub fn ruby_keg_l94_d8_delete_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_rpath', ...args)
}

// Ruby method `binary_executable_or_library_files = mach_o_files` at line 105.
pub fn ruby_keg_l105_d9_binary_executable_or_library_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('binary_executable_or_library_files', ...args)
}

// Ruby method `codesign_patched_binary(file)` at line 108.
pub fn ruby_keg_l108_d10_codesign_patched_binary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('codesign_patched_binary', ...args)
}

// Ruby method `prepare_debug_symbols` at line 160.
pub fn ruby_keg_l160_d11_prepare_debug_symbols(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepare_debug_symbols', ...args)
}

// Ruby method `consistent_reproducible_symlink_permissions!` at line 179.
pub fn ruby_keg_l179_d12_consistent_reproducible_symlink_permissions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('consistent_reproducible_symlink_permissions!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Keg
// 9:       include SystemCommand::Mixin
// 10:
// 11:       module ClassMethods
// 12:         sig { returns(T::Array[String]) }
// 13:         def keg_link_directories
// 14:           @keg_link_directories ||= T.let((super + ["Frameworks"]).freeze, T.nilable(T::Array[String]))
// 15:         end
// 16:
// 17:         sig { returns(T::Array[::Pathname]) }
// 18:         def must_exist_subdirectories
// 19:           @must_exist_subdirectories ||= T.let((
// 20:             super +
// 21:             [HOMEBREW_PREFIX/"Frameworks"]
// 22:           ).sort.uniq.freeze, T.nilable(T::Array[::Pathname]))
// 23:         end
// 24:
// 25:         sig { returns(T::Array[::Pathname]) }
// 26:         def must_exist_directories
// 27:           @must_exist_directories ||= T.let((
// 28:             super +
// 29:             [HOMEBREW_PREFIX/"Frameworks"]
// 30:           ).sort.uniq.freeze, T.nilable(T::Array[::Pathname]))
// 31:         end
// 32:
// 33:         sig { returns(T::Array[::Pathname]) }
// 34:         def must_be_writable_directories
// 35:           @must_be_writable_directories ||= T.let((
// 36:             super +
// 37:             [HOMEBREW_PREFIX/"Frameworks"]
// 38:           ).sort.uniq.freeze, T.nilable(T::Array[::Pathname]))
// 39:         end
// 40:       end
// 41:
// 42:       sig { params(id: String, file: MachOShim).returns(T::Boolean) }
// 43:       def change_dylib_id(id, file)
// 44:         return false if file.dylib_id == id
// 45:
// 46:         require_relocation!
// 47:         odebug "Changing dylib ID of #{file}\n  from #{file.dylib_id}\n    to #{id}"
// 48:         file.change_dylib_id(id, strict: false)
// 49:         true
// 50:       rescue MachO::MachOError
// 51:         onoe <<~EOS
// 52:           Failed changing dylib ID of #{file}
// 53:             from #{file.dylib_id}
// 54:               to #{id}
// 55:         EOS
// 56:         raise
// 57:       end
// 58:
// 59:       sig { params(old: String, new: String, file: MachOShim).returns(T::Boolean) }
// 60:       def change_install_name(old, new, file)
// 61:         return false if old == new
// 62:
// 63:         require_relocation!
// 64:         odebug "Changing install name in #{file}\n  from #{old}\n    to #{new}"
// 65:         file.change_install_name(old, new, strict: false)
// 66:         true
// 67:       rescue MachO::MachOError
// 68:         onoe <<~EOS
// 69:           Failed changing install name in #{file}
// 70:             from #{old}
// 71:               to #{new}
// 72:         EOS
// 73:         raise
// 74:       end
// 75:
// 76:       sig { params(old: String, new: String, file: MachOShim).returns(T::Boolean) }
// 77:       def change_rpath(old, new, file)
// 78:         return false if old == new
// 79:
// 80:         require_relocation!
// 81:         odebug "Changing rpath in #{file}\n  from #{old}\n    to #{new}"
// 82:         file.change_rpath(old, new, strict: false)
// 83:         true
// 84:       rescue MachO::MachOError
// 85:         onoe <<~EOS
// 86:           Failed changing rpath in #{file}
// 87:             from #{old}
// 88:               to #{new}
// 89:         EOS
// 90:         raise
// 91:       end
// 92:
// 93:       sig { params(rpath: String, file: MachOShim).returns(T::Boolean) }
// 94:       def delete_rpath(rpath, file)
// 95:         odebug "Deleting rpath #{rpath} in #{file}"
// 96:         !file.delete_rpath(rpath, strict: false).nil?
// 97:       rescue MachO::MachOError
// 98:         onoe <<~EOS
// 99:           Failed deleting rpath #{rpath} in #{file}
// 100:         EOS
// 101:         raise
// 102:       end
// 103:
// 104:       sig { returns(T::Array[MachOShim]) }
// 105:       def binary_executable_or_library_files = mach_o_files
// 106:
// 107:       sig { params(file: String).void }
// 108:       def codesign_patched_binary(file)
// 109:         return if MacOS.version < :big_sur
// 110:
// 111:         unless ::Hardware::CPU.arm?
// 112:           # Intel macOS rejects ruby-macho's ad-hoc signatures on larger
// 113:           # binaries and does not require unsigned binaries to be signed,
// 114:           # so use `codesign` to re-sign only the binaries whose existing
// 115:           # signature our modifications have just broken:
// 116:           # https://github.com/Homebrew/brew/issues/23418
// 117:           result = system_command("codesign", args: ["--verify", file], print_stderr: false)
// 118:           return unless result.stderr.match?(/invalid signature/i)
// 119:
// 120:           odebug "Codesigning #{file}"
// 121:           return if quiet_system("codesign", "--sign", "-", "--force",
// 122:                                  "--preserve-metadata=entitlements,requirements,flags,runtime",
// 123:                                  file)
// 124:
// 125:           # If the codesigning fails, it may be a bug in Apple's codesign utility.
// 126:           # A known workaround is to copy the file to another inode, then move it back
// 127:           # erasing the previous file. Then sign again.
// 128:           Dir::Tmpname.create("workaround") do |tmppath|
// 129:             FileUtils.cp file, tmppath
// 130:             FileUtils.mv tmppath, file, force: true
// 131:           end
// 132:
// 133:           odebug "Codesigning (2nd try) #{file}"
// 134:           result = system_command("codesign", args: [
// 135:             "--sign", "-", "--force",
// 136:             "--preserve-metadata=entitlements,requirements,flags,runtime",
// 137:             file
// 138:           ], print_stderr: false)
// 139:           return if result.success?
// 140:
// 141:           onoe <<~EOS
// 142:             Failed applying an ad-hoc signature to #{file}:
// 143:             #{result.stderr}
// 144:           EOS
// 145:           return
// 146:         end
// 147:
// 148:         require "macho"
// 149:
// 150:         odebug "Codesigning #{file}"
// 151:         MachO.codesign! file
// 152:       rescue MachO::CodeSigningError => e
// 153:         onoe <<~EOS
// 154:           Failed applying an ad-hoc signature to #{file}:
// 155:           #{e.message}
// 156:         EOS
// 157:       end
// 158:
// 159:       sig { void }
// 160:       def prepare_debug_symbols
// 161:         binary_executable_or_library_files.each do |file|
// 162:           file = file.to_s
// 163:           odebug "Extracting symbols #{file}"
// 164:
// 165:           result = system_command("dsymutil", args: [file], print_stderr: false)
// 166:           next if result.success?
// 167:
// 168:           # If it fails again, error out
// 169:           ofail <<~EOS
// 170:             Failed to extract symbols from #{file}:
// 171:             #{result.stderr}
// 172:           EOS
// 173:         end
// 174:       end
// 175:
// 176:       # Needed to make symlink permissions consistent on macOS and Linux for
// 177:       # reproducible bottles.
// 178:       sig { void }
// 179:       def consistent_reproducible_symlink_permissions!
// 180:         path.find do |file|
// 181:           file.lchmod 0777 if file.symlink?
// 182:         end
// 183:       end
// 184:     end
// 185:   end
// 186: end
// 187:
// 188: Keg.singleton_class.prepend(OS::Mac::Keg::ClassMethods)
// 189: Keg.prepend(OS::Mac::Keg)
