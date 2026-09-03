module linux

import brew_runtime
import os
import time

// Translated from Homebrew/brew `test/os/linux/libstdcxx_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub const libstdcxx_spec_soversion_number = 6
pub const libstdcxx_spec_soname = 'libstdc++.so.6'
pub const libstdcxx_spec_ci_version = '6.0.33'

pub struct LibstdcxxSpecVersion {
pub:
	value      string
	null_value bool
}

pub fn libstdcxx_spec_version(value string) LibstdcxxSpecVersion {
	return LibstdcxxSpecVersion{
		value: value
	}
}

pub fn libstdcxx_spec_null_version() LibstdcxxSpecVersion {
	return LibstdcxxSpecVersion{
		value: 'NULL'
		null_value: true
	}
}

pub fn (version LibstdcxxSpecVersion) to_s() string {
	return version.value
}

pub fn (version LibstdcxxSpecVersion) compare_to(other LibstdcxxSpecVersion) int {
	if version.null_value {
		return if other.null_value { 0 } else { -1 }
	}
	if other.null_value {
		return 1
	}
	left := version.value.split('.')
	right := other.value.split('.')
	part_count := if left.len > right.len { left.len } else { right.len }
	for index in 0 .. part_count {
		left_part := if index < left.len { left[index].int() } else { 0 }
		right_part := if index < right.len { right[index].int() } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

pub fn libstdcxx_spec_version_from_path(path ?string) LibstdcxxSpecVersion {
	library := path or { return libstdcxx_spec_null_version() }
	real_basename := os.base(os.real_path(library))
	suffix := if real_basename.starts_with(libstdcxx_spec_soname) {
		real_basename[libstdcxx_spec_soname.len..]
	} else {
		''
	}
	return libstdcxx_spec_version('${libstdcxx_spec_soversion_number}${suffix}')
}

pub fn libstdcxx_spec_below_ci_version(version LibstdcxxSpecVersion) bool {
	return version.compare_to(libstdcxx_spec_version(libstdcxx_spec_ci_version)) < 0
}

pub fn libstdcxx_spec_tmpdir(path string) !string {
	root := if path != '' {
		path
	} else {
		os.join_path(os.temp_dir(), 'brew-v-libstdcxx-spec-${os.getpid()}-${time.now().unix_micro()}')
	}
	os.mkdir_all(root)!
	return root
}

pub fn libstdcxx_spec_library_path(tmpdir string) string {
	return os.join_path(tmpdir, libstdcxx_spec_soname)
}

pub fn libstdcxx_spec_soversion() LibstdcxxSpecVersion {
	return libstdcxx_spec_version(libstdcxx_spec_soversion_number.str())
}

pub fn libstdcxx_spec_full_version_case(root string) !bool {
	tmpdir := libstdcxx_spec_tmpdir(root)!
	library := libstdcxx_spec_library_path(tmpdir)
	full_version := '${libstdcxx_spec_soversion_number}.0.999'
	real_library := os.join_path(tmpdir, 'libstdc++.so.${full_version}')
	os.write_file(real_library, '')!
	os.symlink(real_library, library)!
	return libstdcxx_spec_version_from_path(library).to_s() == full_version
}

pub fn libstdcxx_spec_soname_case(root string) !bool {
	tmpdir := libstdcxx_spec_tmpdir(root)!
	library := libstdcxx_spec_library_path(tmpdir)
	os.write_file(library, '')!
	return libstdcxx_spec_version_from_path(library).compare_to(libstdcxx_spec_soversion()) == 0
}

pub fn libstdcxx_spec_unexpected_realpath_case(root string) !bool {
	tmpdir := libstdcxx_spec_tmpdir(root)!
	library := libstdcxx_spec_library_path(tmpdir)
	real_library := os.join_path(tmpdir, 'libstdc++.so.real')
	os.write_file(real_library, '')!
	os.symlink(real_library, library)!
	return libstdcxx_spec_version_from_path(library).compare_to(libstdcxx_spec_soversion()) == 0
}

fn libstdcxx_spec_case_root(args []brew_runtime.Value, suffix string) !(string, bool) {
	if args.len > 0 && args[0].as_string() != '' {
		return libstdcxx_spec_tmpdir(args[0].as_string())!, false
	}
	return libstdcxx_spec_tmpdir(os.join_path(os.temp_dir(), 'brew-v-libstdcxx-${suffix}-${os.getpid()}-${time.now().unix_micro()}'))!, true
}

// Ruby it `it "returns false when system version matches CI version" do` at line 8.
pub fn ruby_libstdcxx_spec_l8_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	version_text := if args.len > 0 {
		args[0].as_string()
	} else {
		libstdcxx_spec_ci_version
	}
	return brew_runtime.bool_value(!libstdcxx_spec_below_ci_version(libstdcxx_spec_version(version_text)))
}

// Ruby it `it "returns true when system version cannot be detected" do` at line 13.
pub fn ruby_libstdcxx_spec_l13_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	version := if args.len > 0 && args[0].as_string() != 'NULL' {
		libstdcxx_spec_version(args[0].as_string())
	} else {
		libstdcxx_spec_null_version()
	}
	return brew_runtime.bool_value(libstdcxx_spec_below_ci_version(version))
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 20.
pub fn ruby_libstdcxx_spec_l20_d3_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	requested := if args.len > 0 { args[0].as_string() } else { '' }
	root := libstdcxx_spec_tmpdir(requested) or {
		return brew_runtime.object_value('Pathname', '')
	}
	return brew_runtime.object_value('Pathname', root)
}

// Ruby let `let(:libstdcxx) { tmpdir/OS::Linux::Libstdcxx::SONAME }` at line 21.
pub fn ruby_libstdcxx_spec_l21_d4_libstdcxx(args ...brew_runtime.Value) brew_runtime.Value {
	requested := if args.len > 0 { args[0].as_string() } else { '' }
	root := libstdcxx_spec_tmpdir(requested) or {
		return brew_runtime.object_value('Pathname', '')
	}
	return brew_runtime.object_value('Pathname', libstdcxx_spec_library_path(root))
}

// Ruby let `let(:soversion) { Version.new(OS::Linux::Libstdcxx::SOVERSION.to_s) }` at line 22.
pub fn ruby_libstdcxx_spec_l22_d5_soversion(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Version', libstdcxx_spec_soversion().to_s())
}

// Ruby it `it "returns NULL when unable to find system path" do` at line 34.
pub fn ruby_libstdcxx_spec_l34_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(libstdcxx_spec_version_from_path(none).null_value)
}

// Ruby it `it "returns full version from filename" do` at line 39.
pub fn ruby_libstdcxx_spec_l39_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	root, cleanup := libstdcxx_spec_case_root(args, 'full-version') or {
		return brew_runtime.bool_value(false)
	}
	defer {
		if cleanup {
			os.rmdir_all(root) or {}
		}
	}
	return brew_runtime.bool_value(libstdcxx_spec_full_version_case(root) or { false })
}

// Ruby it `it "returns major version when non-standard libstdc++ filename without full version" do` at line 47.
pub fn ruby_libstdcxx_spec_l47_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	root, cleanup := libstdcxx_spec_case_root(args, 'soname') or {
		return brew_runtime.bool_value(false)
	}
	defer {
		if cleanup {
			os.rmdir_all(root) or {}
		}
	}
	return brew_runtime.bool_value(libstdcxx_spec_soname_case(root) or { false })
}

// Ruby it `it "returns major version when non-standard libstdc++ filename with unexpected realpath" do` at line 52.
pub fn ruby_libstdcxx_spec_l52_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	root, cleanup := libstdcxx_spec_case_root(args, 'unexpected-realpath') or {
		return brew_runtime.bool_value(false)
	}
	defer {
		if cleanup {
			os.rmdir_all(root) or {}
		}
	}
	return brew_runtime.bool_value(libstdcxx_spec_unexpected_realpath_case(root) or { false })
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/libstdcxx"
// 5:
// 6: RSpec.describe OS::Linux::Libstdcxx do
// 7:   describe "::below_ci_version?" do
// 8:     it "returns false when system version matches CI version" do
// 9:       allow(described_class).to receive(:system_version).and_return(Version.new(OS::LINUX_LIBSTDCXX_CI_VERSION))
// 10:       expect(described_class.below_ci_version?).to be false
// 11:     end
// 12:
// 13:     it "returns true when system version cannot be detected" do
// 14:       allow(described_class).to receive(:system_version).and_return(Version::NULL)
// 15:       expect(described_class.below_ci_version?).to be true
// 16:     end
// 17:   end
// 18:
// 19:   describe "::system_version" do
// 20:     let(:tmpdir) { mktmpdir }
// 21:     let(:libstdcxx) { tmpdir/OS::Linux::Libstdcxx::SONAME }
// 22:     let(:soversion) { Version.new(OS::Linux::Libstdcxx::SOVERSION.to_s) }
// 23:
// 24:     before do
// 25:       tmpdir.mkpath
// 26:       described_class.system_version = nil
// 27:       allow(described_class).to receive(:system_path).and_return(libstdcxx)
// 28:     end
// 29:
// 30:     after do
// 31:       FileUtils.rm_rf(tmpdir)
// 32:     end
// 33:
// 34:     it "returns NULL when unable to find system path" do
// 35:       allow(described_class).to receive(:system_path).and_return(nil)
// 36:       expect(described_class.system_version).to be Version::NULL
// 37:     end
// 38:
// 39:     it "returns full version from filename" do
// 40:       full_version = Version.new("#{soversion}.0.999")
// 41:       libstdcxx_real = libstdcxx.sub_ext(".#{full_version}")
// 42:       FileUtils.touch libstdcxx_real
// 43:       FileUtils.ln_s libstdcxx_real, libstdcxx
// 44:       expect(described_class.system_version).to eq full_version
// 45:     end
// 46:
// 47:     it "returns major version when non-standard libstdc++ filename without full version" do
// 48:       FileUtils.touch libstdcxx
// 49:       expect(described_class.system_version).to eq soversion
// 50:     end
// 51:
// 52:     it "returns major version when non-standard libstdc++ filename with unexpected realpath" do
// 53:       libstdcxx_real = tmpdir/"libstdc++.so.real"
// 54:       FileUtils.touch libstdcxx_real
// 55:       FileUtils.ln_s libstdcxx_real, libstdcxx
// 56:       expect(described_class.system_version).to eq soversion
// 57:     end
// 58:   end
// 59: end
