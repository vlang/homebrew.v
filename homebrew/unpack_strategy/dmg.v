module unpack_strategy

import ruby
import os
import time

// Translated from Homebrew/brew `unpack_strategy/dmg.rb`.

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
	if !os.is_link(pathname) {
		return false
	}
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
	if paths.len == 0 {
		return error("BOM for path '${pathname}' is empty.")
	}
	return paths.join('\n')
}

fn collect_dmg_bom(root string, relative string, mut paths []string) ! {
	path := if relative == '.' { root } else { os.join_path(root, relative) }
	if dmg_metadata(relative) || dmg_system_dir_symlink(path) {
		return
	}
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
	if mount.ejected || !os.exists(mount.path) {
		return
	}
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
	mount_root := os.join_path(os.temp_dir(), '.brew-v-dmg-${os.getpid()}-${time.now().unix_nano()}')
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
			path: mount_path
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
		if dmg_metadata(name) || dmg_system_dir_symlink(source) {
			continue
		}
		destination := os.join_path(unpack_dir, name)
		checked_command(command_path('ditto')!, [source, destination])!
		make_tree_owner_writable(destination)!
	}
}

fn make_tree_owner_writable(path string) ! {
	if os.is_link(path) {
		return
	}
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
