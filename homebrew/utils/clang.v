module utils

import ruby

// Translated from Homebrew/brew `utils/clang.rb`.

// write_clang_system_config_files translates the source's Set iteration and
// atomic writes. current_macos_version is explicit so tests and simulated
// systems do not depend on the host operating system.
pub fn write_clang_system_config_files(config_dir string, macos_version string,
	kernel_version string, arch string, current_macos_version string, clt_pkg_path string) ! {
	ruby.make_dir_all(config_dir)!
	mut arches := ['arm64', 'x86_64', 'aarch64']
	if arch !in arches {
		arches << arch
	}
	sysroot := if macos_version == ''
		|| version_number_greater(current_macos_version, macos_version) {
		'${clt_pkg_path}/MacOSX.sdk'
	} else {
		'${clt_pkg_path}/MacOSX${macos_version}.sdk'
	}
	for system, version in {
		'darwin': kernel_version
		'macosx': macos_version
	} {
		for target_arch in arches {
			path := ruby.join_path(config_dir, '${target_arch}-apple-${system}${version}.cfg')
			ruby.atomic_write_file(path, '-isysroot ${sysroot}\n')!
		}
	}
}

fn version_number_greater(left string, right string) bool {
	left_parts := left.split('.').map(it.int())
	right_parts := right.split('.').map(it.int())
	maximum_parts := if left_parts.len > right_parts.len {
		left_parts.len
	} else {
		right_parts.len
	}
	for index in 0 .. maximum_parts {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part != right_part {
			return left_part > right_part
		}
	}
	return false
}
