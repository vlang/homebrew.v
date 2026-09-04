module unpack_strategy

import ruby
import os
import time

// Translated from Homebrew/brew `unpack_strategy/dmg.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(path)` at line 40.
pub fn ruby_dmg_l40_d1_initialize(path string) string {
	return "BOM for path '${path}' is empty."
}

// Ruby method `self.dmg_metadata?(pathname)` at line 47.
pub fn ruby_dmg_l47_d2_self_dmg_metadata(pathname string) bool {
	return dmg_metadata(pathname)
}

// Ruby method `self.system_dir_symlink?(pathname)` at line 53.
pub fn ruby_dmg_l53_d3_self_system_dir_symlink(pathname string) bool {
	return dmg_system_dir_symlink(pathname)
}

// Ruby method `self.bom(pathname)` at line 58.
pub fn ruby_dmg_l58_d4_self_bom(pathname string) !string {
	return dmg_bom(pathname)
}

// Ruby method `eject(verbose: false)` at line 90.
pub fn ruby_dmg_l90_d5_eject(mut mount DmgMount, verbose bool) ! {
	mount.eject(verbose)!
}

// Ruby method `self.extensions = []` at line 131.
pub fn ruby_dmg_l131_d6_self_extensions() []string {
	return []
}

// Ruby method `self.can_extract?(_path) = false` at line 134.
pub fn ruby_dmg_l134_d7_self_can_extract(path string) bool {
	_ = path
	return false
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 139.
pub fn ruby_dmg_l139_d8_extract_to_dir(mount DmgMount, unpack_dir string, basename string, verbose bool) ! {
	dmg_mount_extract_to_dir(mount.path, unpack_dir, basename, verbose)!
}

// Ruby method `self.extensions` at line 176.
pub fn ruby_dmg_l176_d9_self_extensions() []string {
	return dmg_extensions()
}

// Ruby method `self.can_extract?(path)` at line 181.
pub fn ruby_dmg_l181_d10_self_can_extract(path string) bool {
	return dmg_can_extract(path)
}

// Ruby method `mount(verbose: false, &_block)` at line 187.
pub fn ruby_dmg_l187_d11_mount(path string, verbose bool) ![]DmgMount {
	return dmg_mount(path, verbose)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 257.
pub fn ruby_dmg_l257_d12_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	dmg_extract_to_dir(path, unpack_dir, basename, verbose)!
}

const dmg_metadata_names = ['.background', '.com.apple.timemachine.donotpresent',
	'.com.apple.timemachine.supported', '.DocumentRevisions-V100', '.DS_Store', '.fseventsd',
	'.MobileBackups', '.Spotlight-V100', '.TemporaryItems', '.Trashes', '.VolumeIcon.icns',
	'.HFS+ Private Directory Data\r', '.HFS+ Private Data\r']

pub struct DmgMount {
pub:
	path       string
	mount_root string
pub mut:
	ejected bool
}

pub fn dmg_metadata(pathname string) bool {
	clean := pathname.replace('\\', '/').trim_string_left('./')
	root_name := clean.split('/')[0]
	return root_name in dmg_metadata_names
}

pub fn dmg_system_dir_symlink(pathname string) bool {
	if !os.is_link(pathname) { return false }
	target := os.readlink(pathname) or { return false }
	resolved := if target.starts_with('/') {
		target
	} else {
		clean_absolute_path(os.join_path(os.dir(pathname), target))
	}
	return resolved == '/Applications' || resolved == '/Library' || resolved == '/System'
		|| resolved == '/Users' || resolved == '/Volumes'
}

pub fn dmg_bom(pathname string) !string {
	mut paths := []string{}
	collect_dmg_bom(pathname, '.', mut paths)!
	if paths.len == 0 { return error("BOM for path '${pathname}' is empty.") }
	return paths.join('\n')
}

fn collect_dmg_bom(root string, relative string, mut paths []string) ! {
	path := if relative == '.' { root } else { os.join_path(root, relative) }
	if dmg_metadata(relative) || dmg_system_dir_symlink(path) { return }
	paths << relative
	if os.is_dir(path) && !os.is_link(path) {
		for name in os.ls(path)! {
			next := if relative == '.' { name } else { os.join_path(relative, name) }
			collect_dmg_bom(root, next, mut paths)!
		}
	}
}

pub fn (mut mount DmgMount) eject(verbose bool) ! {
	_ = verbose
	if mount.ejected || !os.exists(mount.path) { return }
	diskutil := command_path('diskutil')!
	mut last_error := ''
	for attempt in 0 .. 3 {
		args := if attempt < 2 { ['eject', mount.path] } else { ['unmount', 'force', mount.path] }
		result := ruby.run_command(diskutil, args)
		if result.exit_code == 0 {
			mount.ejected = true
			if mount.mount_root != '' && os.is_dir(mount.mount_root) {
				os.rmdir_all(mount.mount_root) or {}
			}
			return
		}
		last_error = result.output.trim_space()
		time.sleep(100 * time.millisecond)
	}
	return error('failed to eject ${mount.path}: ${last_error}')
}

pub fn dmg_extensions() []string {
	return ['.dmg']
}

pub fn dmg_can_extract(path string) bool {
	hdiutil := command_path('hdiutil') or { return false }
	result := ruby.run_command(hdiutil, ['imageinfo', '-format', path])
	return result.exit_code == 0 && result.output.trim_space() != ''
}

pub fn dmg_mount(path string, verbose bool) ![]DmgMount {
	_ = verbose
	hdiutil := command_path('hdiutil')!
	mount_root := os.join_path(os.temp_dir(),
		'.brew-v-dmg-${os.getpid()}-${time.now().unix_nano()}')
	os.mkdir_all(mount_root)!
	mut process := os.new_process(hdiutil)
	process.set_args(['attach', '-plist', '-nobrowse', '-readonly', '-mountrandom', mount_root,
		path])
	process.set_redirect_stdio()
	process.run()
	process.stdin_write('qn\n')
	stdout := process.stdout_slurp()
	stderr := process.stderr_slurp()
	process.wait()
	code := process.code
	process.close()
	if code != 0 {
		os.rmdir_all(mount_root) or {}
		return error('hdiutil attach failed (${code}): ${if stderr.trim_space() != '' {
			stderr.trim_space()
		} else {
			stdout.trim_space()
		}}')
	}
	mut mounts := []DmgMount{}
	for mount_path in plist_mount_points(stdout) {
		mounts << DmgMount{
			path:       mount_path
			mount_root: mount_root
		}
	}
	if mounts.len == 0 {
		os.rmdir_all(mount_root) or {}
		return error("No mounts found in '${path}'; perhaps this is a bad disk image?")
	}
	return mounts
}

fn plist_mount_points(plist string) []string {
	mut mounts := []string{}
	mut awaiting_value := false
	for line in plist.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed == '<key>mount-point</key>' {
			awaiting_value = true
			continue
		}
		if awaiting_value && trimmed.starts_with('<string>') && trimmed.ends_with('</string>') {
			mounts << trimmed.all_after('<string>').all_before('</string>').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>')
			awaiting_value = false
		}
	}
	return mounts
}

pub fn dmg_mount_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	for name in os.ls(path)! {
		source := os.join_path(path, name)
		if dmg_metadata(name) || dmg_system_dir_symlink(source) { continue
		 }
		destination := os.join_path(unpack_dir, name)
		checked_command(command_path('ditto')!, [source, destination])!
		make_tree_owner_writable(destination)!
	}
}

fn make_tree_owner_writable(path string) ! {
	if os.is_link(path) { return }
	info := os.inode(path)
	if !info.owner.write { os.chmod(path, int(info.bitmask() | u32(0o200)))! }
	if os.is_dir(path) {
		for name in os.ls(path)! {
			make_tree_owner_writable(os.join_path(path, name))!
		}
	}
}

pub fn dmg_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	mut mounts := dmg_mount(path, verbose)!
	defer {
		for mut mount in mounts {
			mount.eject(verbose) or {}
		}
	}
	for mount in mounts {
		dmg_mount_extract_to_dir(mount.path, unpack_dir, basename, verbose)!
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tempfile"
// 5: require "system_command"
// 6: require "utils/output"
// 7:
// 8: module UnpackStrategy
// 9:   # Strategy for unpacking disk images.
// 10:   class Dmg
// 11:     extend SystemCommand::Mixin
// 12:     include UnpackStrategy
// 13:
// 14:     # Helper module for listing the contents of a volume mounted from a disk image.
// 15:     module Bom
// 16:       extend Utils::Output::Mixin
// 17:       extend SystemCommand::Mixin
// 18:
// 19:       DMG_METADATA = T.let(Set.new([
// 20:         ".background",
// 21:         ".com.apple.timemachine.donotpresent",
// 22:         ".com.apple.timemachine.supported",
// 23:         ".DocumentRevisions-V100",
// 24:         ".DS_Store",
// 25:         ".fseventsd",
// 26:         ".MobileBackups",
// 27:         ".Spotlight-V100",
// 28:         ".TemporaryItems",
// 29:         ".Trashes",
// 30:         ".VolumeIcon.icns",
// 31:         ".HFS+ Private Directory Data\r", # do not remove `\r`, it is a part of directory name
// 32:         ".HFS+ Private Data\r",
// 33:       ]).freeze, T::Set[String])
// 34:       private_constant :DMG_METADATA
// 35:
// 36:       class Error < RuntimeError; end
// 37:
// 38:       class EmptyError < Error
// 39:         sig { params(path: Pathname).void }
// 40:         def initialize(path)
// 41:           super "BOM for path '#{path}' is empty."
// 42:         end
// 43:       end
// 44:
// 45:       # Check if path is considered disk image metadata.
// 46:       sig { params(pathname: Pathname).returns(T::Boolean) }
// 47:       def self.dmg_metadata?(pathname)
// 48:         DMG_METADATA.include?(pathname.cleanpath.ascend.to_a.last.to_s)
// 49:       end
// 50:
// 51:       # Check if path is a symlink to a system directory (commonly to /Applications).
// 52:       sig { params(pathname: Pathname).returns(T::Boolean) }
// 53:       def self.system_dir_symlink?(pathname)
// 54:         pathname.symlink? && MacOS.system_dir?(pathname.dirname.join(pathname.readlink))
// 55:       end
// 56:
// 57:       sig { params(pathname: Pathname).returns(String) }
// 58:       def self.bom(pathname)
// 59:         tries = 0
// 60:         result = loop do
// 61:           # We need to use `find` here instead of Ruby in order to properly handle
// 62:           # file names containing special characters, such as “e” + “´” vs. “é”.
// 63:           r = system_command("find", args: [".", "-print0"], chdir: pathname, print_stderr: false, reset_uid: true)
// 64:           tries += 1
// 65:
// 66:           # Spurious bug on CI, which in most cases can be worked around by retrying.
// 67:           break r unless r.stderr.match?(/Interrupted system call/i)
// 68:
// 69:           raise "Command `#{r.command.shelljoin}` was interrupted." if tries >= 3
// 70:         end
// 71:
// 72:         odebug "Command `#{result.command.shelljoin}` in '#{pathname}' took #{tries} tries." if tries > 1
// 73:
// 74:         bom_paths = result.stdout.split("\0")
// 75:
// 76:         raise EmptyError, pathname if bom_paths.empty?
// 77:
// 78:         bom_paths
// 79:           .reject { |path| dmg_metadata?(Pathname(path)) }
// 80:           .reject { |path| system_dir_symlink?(pathname/path) }
// 81:           .join("\n")
// 82:       end
// 83:     end
// 84:
// 85:     # Strategy for unpacking a volume mounted from a disk image.
// 86:     class Mount
// 87:       include UnpackStrategy
// 88:
// 89:       sig { params(verbose: T::Boolean).void }
// 90:       def eject(verbose: false)
// 91:         tries = 3
// 92:         begin
// 93:           return unless path.exist?
// 94:
// 95:           if tries > 1
// 96:             disk_info = system_command!(
// 97:               "diskutil",
// 98:               args:         ["info", "-plist", path],
// 99:               print_stderr: false,
// 100:               verbose:,
// 101:             )
// 102:
// 103:             # For HFS, just use <mount-path>
// 104:             # For APFS, find the <physical-store> corresponding to <mount-path>
// 105:             eject_paths = disk_info.plist
// 106:                                    .fetch("APFSPhysicalStores", [])
// 107:                                    .filter_map { |store| store["APFSPhysicalStore"] }
// 108:                                    .presence || [path]
// 109:
// 110:             eject_paths.each do |eject_path|
// 111:               system_command! "diskutil",
// 112:                               args:         ["eject", eject_path],
// 113:                               print_stderr: false,
// 114:                               verbose:
// 115:             end
// 116:           else
// 117:             system_command! "diskutil",
// 118:                             args:         ["unmount", "force", path],
// 119:                             print_stderr: false,
// 120:                             verbose:
// 121:           end
// 122:         rescue ErrorDuringExecution => e
// 123:           raise e if (tries -= 1).zero?
// 124:
// 125:           sleep 1
// 126:           retry
// 127:         end
// 128:       end
// 129:
// 130:       sig { override.returns(T::Array[String]) }
// 131:       def self.extensions = []
// 132:
// 133:       sig { override.params(_path: Pathname).returns(T::Boolean) }
// 134:       def self.can_extract?(_path) = false
// 135:
// 136:       private
// 137:
// 138:       sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 139:       def extract_to_dir(unpack_dir, basename:, verbose:)
// 140:         tries = 3
// 141:         bom = begin
// 142:           Bom.bom(path)
// 143:         rescue Bom::EmptyError => e
// 144:           raise e if (tries -= 1).zero?
// 145:
// 146:           sleep 1
// 147:           retry
// 148:         end
// 149:
// 150:         Tempfile.open(["", ".bom"]) do |bomfile|
// 151:           bomfile.close
// 152:
// 153:           Tempfile.open(["", ".list"]) do |filelist|
// 154:             filelist.puts(bom)
// 155:             filelist.close
// 156:
// 157:             system_command! "mkbom",
// 158:                             args:    ["-s", "-i", T.must(filelist.path), "--", T.must(bomfile.path)],
// 159:                             verbose:
// 160:           end
// 161:
// 162:           bomfile_path = T.must(bomfile.path)
// 163:
// 164:           system_command!("ditto",
// 165:                           args:      ["--bom", bomfile_path, "--", path, unpack_dir],
// 166:                           verbose:,
// 167:                           reset_uid: true)
// 168:
// 169:           FileUtils.chmod "u+w", Pathname.glob(unpack_dir/"**/*", File::FNM_DOTMATCH).reject(&:symlink?)
// 170:         end
// 171:       end
// 172:     end
// 173:     private_constant :Mount
// 174:
// 175:     sig { override.returns(T::Array[String]) }
// 176:     def self.extensions
// 177:       [".dmg"]
// 178:     end
// 179:
// 180:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 181:     def self.can_extract?(path)
// 182:       stdout, _, status = system_command("hdiutil", args: ["imageinfo", "-format", path], print_stderr: false).to_a
// 183:       (status.success? && !stdout.empty?) || false
// 184:     end
// 185:
// 186:     sig { params(verbose: T::Boolean, _block: T.proc.params(arg0: T::Array[Mount]).void).void }
// 187:     def mount(verbose: false, &_block)
// 188:       Dir.mktmpdir("homebrew-dmg", HOMEBREW_TEMP) do |mount_dir|
// 189:         mount_dir = Pathname(mount_dir)
// 190:
// 191:         without_eula = system_command(
// 192:           "hdiutil",
// 193:           args:         [
// 194:             "attach", "-plist", "-nobrowse", "-readonly",
// 195:             "-mountrandom", mount_dir, path
// 196:           ],
// 197:           input:        "qn\n",
// 198:           print_stderr: false,
// 199:           verbose:,
// 200:         )
// 201:
// 202:         # If mounting without agreeing to EULA succeeded, there is none.
// 203:         plist = if without_eula.success?
// 204:           without_eula.plist
// 205:         else
// 206:           without_eula.assert_success! if without_eula.stdout.empty?
// 207:
// 208:           cdr_path = mount_dir/path.basename.sub_ext(".cdr")
// 209:
// 210:           quiet_flag = "-quiet" unless verbose
// 211:
// 212:           system_command!(
// 213:             "hdiutil",
// 214:             args:    [
// 215:               "convert", *quiet_flag, "-format", "UDTO", "-o", cdr_path, path
// 216:             ],
// 217:             verbose:,
// 218:           )
// 219:
// 220:           with_eula = system_command!(
// 221:             "hdiutil",
// 222:             args:    [
// 223:               "attach", "-plist", "-nobrowse", "-readonly",
// 224:               "-mountrandom", mount_dir, cdr_path
// 225:             ],
// 226:             verbose:,
// 227:           )
// 228:
// 229:           if verbose && !(eula_text = without_eula.stdout).empty?
// 230:             ohai "Software License Agreement for '#{path}':", eula_text
// 231:           end
// 232:
// 233:           with_eula.plist
// 234:         end
// 235:
// 236:         mounts = if plist.respond_to?(:fetch)
// 237:           plist.fetch("system-entities", [])
// 238:                .filter_map { |entity| entity["mount-point"] }
// 239:                .map { |path| Mount.new(path) }
// 240:         else
// 241:           []
// 242:         end
// 243:
// 244:         begin
// 245:           yield mounts
// 246:         ensure
// 247:           mounts.each do |mount|
// 248:             mount.eject(verbose:)
// 249:           end
// 250:         end
// 251:       end
// 252:     end
// 253:
// 254:     private
// 255:
// 256:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 257:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 258:       mount(verbose:) do |mounts|
// 259:         raise "No mounts found in '#{path}'; perhaps this is a bad disk image?" if mounts.empty?
// 260:
// 261:         mounts.each do |mount|
// 262:           mount.extract(to: unpack_dir, verbose:)
// 263:         end
// 264:       end
// 265:     end
// 266:   end
// 267: end
