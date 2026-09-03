module utils

import brew_runtime

// Translated from Homebrew/brew `utils/clang.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.write_system_config_files(config_dir:, macos_version:, kernel_version:, arch:)` at line 14.
pub fn ruby_clang_l14_d1_self_write_system_config_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		return brew_runtime.bool_value(false)
	}
	write_clang_system_config_files(args[0].as_string(), args[1].as_string(), args[2].as_string(),
		args[3].as_string(), args[1].as_string(), '/Library/Developer/CommandLineTools/SDKs') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// write_clang_system_config_files translates the source's Set iteration and
// atomic writes. current_macos_version is explicit so tests and simulated
// systems do not depend on the host operating system.
pub fn write_clang_system_config_files(config_dir string, macos_version string,
	kernel_version string, arch string, current_macos_version string, clt_pkg_path string) ! {
	brew_runtime.make_dir_all(config_dir)!
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
			path := brew_runtime.join_path(config_dir,
				'${target_arch}-apple-${system}${version}.cfg')
			brew_runtime.atomic_write_file(path, '-isysroot ${sysroot}\n')!
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   module Clang
// 6:     sig {
// 7:       params(
// 8:         config_dir:     Pathname,
// 9:         macos_version:  T.any(String, MacOSVersion),
// 10:         kernel_version: T.any(String, Version),
// 11:         arch:           Symbol,
// 12:       ).void
// 13:     }
// 14:     def self.write_system_config_files(config_dir:, macos_version:, kernel_version:, arch:)
// 15:       config_dir.mkpath
// 16:       arches = Set.new([:arm64, :x86_64, :aarch64, arch])
// 17:       sysroot = if macos_version.blank? || MacOS.version > macos_version
// 18:         "#{MacOS::CLT::PKG_PATH}/SDKs/MacOSX.sdk"
// 19:       else
// 20:         "#{MacOS::CLT::PKG_PATH}/SDKs/MacOSX#{macos_version}.sdk"
// 21:       end
// 22:
// 23:       { darwin: kernel_version, macosx: macos_version }.each do |system, version|
// 24:         arches.each do |target_arch|
// 25:           (config_dir/"#{target_arch}-apple-#{system}#{version}.cfg").atomic_write <<~CONFIG
// 26:             -isysroot #{sysroot}
// 27:           CONFIG
// 28:         end
// 29:       end
// 30:     end
// 31:   end
// 32: end
