module file

import ruby
import os
import time

// Translated from Homebrew/brew `extend/file/atomic.rb`.

pub struct AtomicFileStat {
pub:
	uid  int
	gid  int
	mode int
}

fn atomic_file_stat(path string) !AtomicFileStat {
	stat := os.stat(path)!
	return AtomicFileStat{
		uid: int(stat.uid)
		gid: int(stat.gid)
		mode: int(stat.get_mode().bitmask())
	}
}

fn atomic_file_stat_value(stat AtomicFileStat) ruby.Value {
	return ruby.structured_value('File::Stat', 'mode=${stat.mode:o}', {
		'uid':  stat.uid.str()
		'gid':  stat.gid.str()
		'mode': stat.mode.str()
	})
}

pub fn probe_stat_in(dir string) ?AtomicFileStat {
	if !os.is_dir(dir) {
		return none
	}
	probe := os.join_path(dir, '.permissions_check.${os.getpid()}.${time.now().unix_micro()}')
	os.write_file(probe, '') or { return none }
	defer {
		os.rm(probe) or {}
	}
	return atomic_file_stat(probe) or { none }
}

pub fn atomic_write_contents(file_name string, temp_dir string, contents string) ! {
	if file_name == '' {
		return error('file name is required')
	}
	destination_dir := os.dir(file_name)
	if !os.is_dir(destination_dir) {
		return error('destination directory does not exist: ${destination_dir}')
	}
	if !os.is_dir(temp_dir) {
		return error('temporary directory does not exist: ${temp_dir}')
	}
	temporary := os.join_path(temp_dir, '.${os.base(file_name)}.brew-v-${os.getpid()}-${time.now().unix_micro()}')
	mut renamed := false
	defer {
		if !renamed {
			os.rm(temporary) or {}
		}
	}
	os.write_file(temporary, contents)!
	mut old_stat := ?AtomicFileStat(none)
	if os.exists(file_name) {
		if stat := atomic_file_stat(file_name) {
			old_stat = stat
		}
	} else {
		old_stat = probe_stat_in(destination_dir)
	}
	if stat := old_stat {
		os.chown(temporary, stat.uid, stat.gid) or {}
		os.chmod(temporary, stat.mode) or {}
	}
	os.mv(temporary, file_name)!
	renamed = true
}
