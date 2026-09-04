module linux

// Translated from Homebrew/brew `extend/os/linux/linkage_checker.rb`.
const linux_system_library_allowlist = [
	'ld-linux-x86-64.so.2',
	'ld-linux-aarch64.so.1',
	'libanl.so.1',
	'libatomic.so.1',
	'libc.so.6',
	'libdl.so.2',
	'libm.so.6',
	'libmvec.so.1',
	'libnss_files.so.2',
	'libpthread.so.0',
	'libresolv.so.2',
	'librt.so.1',
	'libthread_db.so.1',
	'libutil.so.1',
	'libgcc_s.so.1',
	'libgomp.so.1',
	'libstdc++.so.6',
	'libquadmath.so.0',
]

pub struct LinuxLinkageState {
pub:
	system_dylibs   []string
	undeclared_deps []string
	indirect_deps   []string
}

pub struct LinuxLinkageResult {
pub:
	unwanted_system_dylibs []string
	undeclared_deps        []string
	indirect_deps          []string
}

fn linux_path_basename(path string) string {
	return path.trim_right('/').split('/').last()
}

pub fn check_linux_dylibs(state LinuxLinkageState, _ bool) LinuxLinkageResult {
	return LinuxLinkageResult{
		unwanted_system_dylibs: state.system_dylibs.filter(linux_path_basename(it) !in linux_system_library_allowlist)
		undeclared_deps: state.undeclared_deps.filter(it != 'gcc')
		indirect_deps: state.indirect_deps.filter(it != 'gcc')
	}
}
