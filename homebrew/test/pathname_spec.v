module test

import ruby
import homebrew
import homebrew.extend as pathname_ext
import homebrew.extend.pathname as path_usage
import os

// Translated from Homebrew/brew `test/pathname_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct PathnameSpecFixture {
	src  string
	dst  string
	file string
	dir  string
}

fn pathname_spec_fixture(name string) !PathnameSpecFixture {
	root := os.join_path(os.temp_dir(), 'brew-v-pathname-spec-${name}-${os.getpid()}')
	if os.exists(root) {
		os.rmdir_all(root)!
	}
	src := os.join_path(root, 'src')
	dst := os.join_path(root, 'dst')
	os.mkdir_all(src)!
	os.mkdir_all(dst)!
	return PathnameSpecFixture{
		src: src
		dst: dst
		file: os.join_path(src, 'foo')
		dir: os.join_path(src, 'bar')
	}
}

fn pathname_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn pathname_spec_disk_fixture(name string) !PathnameSpecFixture {
	fixture := pathname_spec_fixture(name)!
	os.mkdir_all(os.join_path(fixture.dir, 'a-directory'))!
	os.write_file(os.join_path(fixture.dir, '.DS_Store'), '')!
	file := os.join_path(fixture.dir, 'a-file')
	os.write_file(file, 'x'.repeat(1_048_576))!
	os.symlink(file, os.join_path(fixture.dir, 'a-symlink'))!
	os.link(file, os.join_path(fixture.dir, 'a-hardlink'))!
	return fixture
}

fn pathname_spec_install_fixture(name string) !PathnameSpecFixture {
	fixture := pathname_spec_fixture(name)!
	os.write_file(os.join_path(fixture.src, 'a.txt'), 'This is sample file a.')!
	os.write_file(os.join_path(fixture.src, 'b.txt'), 'This is sample file b.')!
	return fixture
}

fn pathname_spec_writable_action(path string) ! {
	if !os.is_writable(path) {
		return error('${path} was not made writable')
	}
}

// Ruby let `let(:src) { mktmpdir }` at line 8.
pub fn ruby_pathname_spec_l8_d1_src(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pathname_spec_fixture('src') or { panic(err) }.src)
}

// Ruby let `let(:dst) { mktmpdir }` at line 9.
pub fn ruby_pathname_spec_l9_d2_dst(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pathname_spec_fixture('dst') or { panic(err) }.dst)
}

// Ruby let `let(:file) { src/"foo" }` at line 10.
pub fn ruby_pathname_spec_l10_d3_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pathname_spec_fixture('file') or { panic(err) }.file)
}

// Ruby let `let(:dir) { src/"bar" }` at line 11.
pub fn ruby_pathname_spec_l11_d4_dir(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pathname_spec_fixture('dir') or { panic(err) }.dir)
}

// Ruby it `it "defines the lazy memoised ivars on every new Pathname" do` at line 16.
pub fn ruby_pathname_spec_l16_d5_defines(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('eager') or { return pathname_spec_bool(false) }
	path := path_usage.new_eager_pathname(fixture.file)
	return pathname_spec_bool(path.path == fixture.file && path.magic_number == none && path.file_type == none && path.zipinfo == none && path.which_install_info == none && path.disk_usage == none && path.file_count == none)
}

// Ruby it `it "returns the number of files in a directory" do` at line 38.
pub fn ruby_pathname_spec_l38_d6_returns(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_disk_fixture('file-count') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(path_usage.pathname_file_count(fixture.dir) or { return pathname_spec_bool(false) } == 3)
}

// Ruby it `it "returns a string with the file count and disk usage" do` at line 45.
pub fn ruby_pathname_spec_l45_d7_returns(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_disk_fixture('directory-abv') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(path_usage.pathname_abv(fixture.dir) or { return pathname_spec_bool(false) } == '3 files, 1MB')
}

// Ruby it `it "returns the disk usage" do` at line 51.
pub fn ruby_pathname_spec_l51_d8_returns(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_disk_fixture('file-abv') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(path_usage.pathname_abv(os.join_path(fixture.dir, 'a-file')) or {
		return pathname_spec_bool(false)
	} == '1MB')
}

// Ruby it `it "returns true and removes a directory if it doesn't contain files" do` at line 61.
pub fn ruby_pathname_spec_l61_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('rmdir-empty') or { return pathname_spec_bool(false) }
	os.mkdir_all(fixture.dir) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(pathname_ext.pathname_rmdir_if_possible(fixture.dir) && !os.exists(fixture.dir))
}

// Ruby it `it "returns false and doesn't delete a directory if it contains files" do` at line 66.
pub fn ruby_pathname_spec_l66_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('rmdir-full') or { return pathname_spec_bool(false) }
	os.mkdir_all(fixture.dir) or { return pathname_spec_bool(false) }
	os.write_file(os.join_path(fixture.dir, 'foo'), '') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(!pathname_ext.pathname_rmdir_if_possible(fixture.dir) && os.is_dir(fixture.dir))
}

// Ruby it `it "ignores .DS_Store files" do` at line 72.
pub fn ruby_pathname_spec_l72_d11_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('rmdir-ds-store') or { return pathname_spec_bool(false) }
	os.mkdir_all(fixture.dir) or { return pathname_spec_bool(false) }
	os.write_file(os.join_path(fixture.dir, '.DS_Store'), '') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(pathname_ext.pathname_rmdir_if_possible(fixture.dir) && !os.exists(fixture.dir))
}

// Ruby it `it "appends lines to a file" do` at line 80.
pub fn ruby_pathname_spec_l80_d12_appends(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('append') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_append_lines(fixture.file, 'CONTENT') or { return pathname_spec_bool(false) }
	if os.read_file(fixture.file) or { '' } != 'CONTENT\n' {
		return pathname_spec_bool(false)
	}
	pathname_ext.pathname_append_lines(fixture.file, 'CONTENTS') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.read_file(fixture.file) or { '' } == 'CONTENT\nCONTENTS\n')
}

// Ruby it `it "raises an error if the file does not exist" do` at line 95.
pub fn ruby_pathname_spec_l95_d13_raises(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('append-missing') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_append_lines(fixture.file, 'CONTENT') or {
		return pathname_spec_bool(err.msg().contains("doesn't exist"))
	}
	return pathname_spec_bool(false)
}

// Ruby it `it "atomically replaces a file" do` at line 102.
pub fn ruby_pathname_spec_l102_d14_atomically(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('atomic') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_atomic_write(fixture.file, 'CONTENT') or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.read_file(fixture.file) or { '' } == 'CONTENT')
}

// Ruby it `it "preserves permissions" do` at line 108.
pub fn ruby_pathname_spec_l108_d15_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('atomic-mode') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	os.chmod(fixture.file, 0o777) or { return pathname_spec_bool(false) }
	before := os.stat(fixture.file) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_atomic_write(fixture.file, 'CONTENT') or { return pathname_spec_bool(false) }
	after := os.stat(fixture.file) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(before.get_mode().bitmask() == after.get_mode().bitmask())
}

// Ruby it `it "preserves default permissions" do` at line 116.
pub fn ruby_pathname_spec_l116_d16_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('atomic-default-mode') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_atomic_write(fixture.file, 'CONTENT') or { return pathname_spec_bool(false) }
	sentinel := os.join_path(fixture.src, 'sentinel')
	os.write_file(sentinel, '') or { return pathname_spec_bool(false) }
	file_mode := os.stat(fixture.file) or { return pathname_spec_bool(false) }
	sentinel_mode := os.stat(sentinel) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(file_mode.get_mode().bitmask() == sentinel_mode.get_mode().bitmask())
}

// Ruby it `it "makes a file writable and restores permissions afterwards" do` at line 125.
pub fn ruby_pathname_spec_l125_d17_makes(args ...ruby.Value) ruby.Value {
	_ = args
	if os.geteuid() == 0 {
		return pathname_spec_bool(true)
	}
	fixture := pathname_spec_fixture('ensure-writable') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	os.chmod(fixture.file, 0o555) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_ensure_writable(fixture.file, pathname_spec_writable_action) or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(!os.is_writable(fixture.file))
}

// Ruby specify `specify do` at line 138.
pub fn ruby_pathname_spec_l138_d18_do(args ...ruby.Value) ruby.Value {
	_ = args
	return pathname_spec_bool(pathname_ext.pathname_extname('foo-0.1.tar.gz') == '.tar.gz' && pathname_ext.pathname_extname('foo-0.1.cpio.gz') == '.cpio.gz' && pathname_ext.pathname_extname('foo-0.1') == '' && pathname_ext.pathname_extname('foo-1.0-rc1') == '' && pathname_ext.pathname_extname('foo-1.2.3') == '' && pathname_ext.pathname_extname('snap7-full-1.4.2.7z') == '.7z')
}

// Ruby it `it "returns the basename without double extensions" do` at line 149.
pub fn ruby_pathname_spec_l149_d19_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return pathname_spec_bool(pathname_ext.pathname_stem('foo-0.1.tar.gz') == 'foo-0.1' && pathname_ext.pathname_stem('foo-0.1.cpio.gz') == 'foo-0.1')
}

// Ruby it `it "raises an error if the file doesn't exist" do` at line 161.
pub fn ruby_pathname_spec_l161_d20_raises(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-missing') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [pathname_ext.PathInstallSource{
		path: os.join_path(fixture.src, 'non_existent_file')
	}]) or {
		return pathname_spec_bool(err.msg().contains('ENOENT'))
	}
	return pathname_spec_bool(false)
}

// Ruby it `it "installs a file to a directory with its basename" do` at line 165.
pub fn ruby_pathname_spec_l165_d21_installs(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-basename') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [pathname_ext.PathInstallSource{
		path: fixture.file
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, os.base(fixture.file))) && !os.exists(fixture.file))
}

// Ruby it `it "creates intermediate directories" do` at line 172.
pub fn ruby_pathname_spec_l172_d22_creates(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-intermediate') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, '') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dir, [pathname_ext.PathInstallSource{
		path: fixture.file
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.is_dir(fixture.dir))
}

// Ruby it `it "can install a file" do` at line 179.
pub fn ruby_pathname_spec_l179_d23_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-one') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [pathname_ext.PathInstallSource{
		path: os.join_path(fixture.src, 'a.txt')
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, 'a.txt')) && !os.exists(os.join_path(fixture.dst, 'b.txt')))
}

// Ruby it `it "can install an array of files" do` at line 185.
pub fn ruby_pathname_spec_l185_d24_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-array') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [
		pathname_ext.PathInstallSource{ path: os.join_path(fixture.src, 'a.txt') },
		pathname_ext.PathInstallSource{ path: os.join_path(fixture.src, 'b.txt') },
	]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, 'a.txt')) && os.exists(os.join_path(fixture.dst, 'b.txt')))
}

// Ruby it `it "can install a directory" do` at line 192.
pub fn ruby_pathname_spec_l192_d25_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('install-directory') or { return pathname_spec_bool(false) }
	bin := os.join_path(fixture.src, 'bin')
	os.mkdir_all(bin) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'a.txt'), os.join_path(bin, 'a.txt')) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'b.txt'), os.join_path(bin, 'b.txt')) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [
		pathname_ext.PathInstallSource{ path: bin },
	]) or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, 'bin', 'a.txt')) && os.exists(os.join_path(fixture.dst, 'bin', 'b.txt')))
}

// Ruby it `it "supports renaming files" do` at line 202.
pub fn ruby_pathname_spec_l202_d26_supports(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('rename-one') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [pathname_ext.PathInstallSource{
		path: os.join_path(fixture.src, 'a.txt')
		new_basename: 'c.txt'
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, 'c.txt')) && !os.exists(os.join_path(fixture.dst, 'a.txt')) && !os.exists(os.join_path(fixture.dst, 'b.txt')))
}

// Ruby it `it "supports renaming multiple files" do` at line 210.
pub fn ruby_pathname_spec_l210_d27_supports(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('rename-many') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [
		pathname_ext.PathInstallSource{
			path: os.join_path(fixture.src, 'a.txt')
			new_basename: 'c.txt'
		},
		pathname_ext.PathInstallSource{
			path: os.join_path(fixture.src, 'b.txt')
			new_basename: 'd.txt'
		},
	]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.exists(os.join_path(fixture.dst, 'c.txt')) && os.exists(os.join_path(fixture.dst, 'd.txt')) && !os.exists(os.join_path(fixture.dst, 'a.txt')) && !os.exists(os.join_path(fixture.dst, 'b.txt')))
}

// Ruby it `it "supports renaming directories" do` at line 219.
pub fn ruby_pathname_spec_l219_d28_supports(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('rename-directory') or { return pathname_spec_bool(false) }
	bin := os.join_path(fixture.src, 'bin')
	os.mkdir_all(bin) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'a.txt'), os.join_path(bin, 'a.txt')) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'b.txt'), os.join_path(bin, 'b.txt')) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install(fixture.dst, [pathname_ext.PathInstallSource{
		path: bin
		new_basename: 'libexec'
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(!os.exists(os.join_path(fixture.dst, 'bin')) && os.exists(os.join_path(fixture.dst, 'libexec', 'a.txt')) && os.exists(os.join_path(fixture.dst, 'libexec', 'b.txt')))
}

// Ruby it `it "can install directories as relative symlinks" do` at line 230.
pub fn ruby_pathname_spec_l230_d29_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('symlink-directory') or { return pathname_spec_bool(false) }
	bin := os.join_path(fixture.src, 'bin')
	os.mkdir_all(bin) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'a.txt'), os.join_path(bin, 'a.txt')) or { return pathname_spec_bool(false) }
	os.mv(os.join_path(fixture.src, 'b.txt'), os.join_path(bin, 'b.txt')) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install_symlink(fixture.dst, [
		pathname_ext.PathInstallSource{ path: bin },
	]) or {
		return pathname_spec_bool(false)
	}
	link := os.join_path(fixture.dst, 'bin')
	target := os.readlink(link) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.is_link(link) && os.is_dir(link) && os.exists(os.join_path(link, 'a.txt')) && os.exists(os.join_path(link, 'b.txt')) && !os.is_abs_path(target))
}

// Ruby it `it "can install relative paths as symlinks" do` at line 243.
pub fn ruby_pathname_spec_l243_d30_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('symlink-relative') or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install_symlink(fixture.dst, [pathname_ext.PathInstallSource{
		path: 'foo'
		new_basename: 'bar'
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.readlink(os.join_path(fixture.dst, 'bar')) or { '' } == 'foo')
}

// Ruby it `it "can install relative symlinks in a symlinked directory" do` at line 248.
pub fn ruby_pathname_spec_l248_d31_can(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_install_fixture('symlink-nested') or { return pathname_spec_bool(false) }
	os.mkdir_all(os.join_path(fixture.dst, '1', '2')) or { return pathname_spec_bool(false) }
	pathname_ext.pathname_install_symlink(fixture.dst, [pathname_ext.PathInstallSource{
		path: '1/2'
		new_basename: '12'
	}]) or { return pathname_spec_bool(false) }
	if os.readlink(os.join_path(fixture.dst, '12')) or { '' } != '1/2' {
		return pathname_spec_bool(false)
	}
	pathname_ext.pathname_install_symlink(os.join_path(fixture.dst, '12'), [pathname_ext.PathInstallSource{
		path: os.join_path(fixture.dst, 'foo')
	}]) or { return pathname_spec_bool(false) }
	return pathname_spec_bool(os.readlink(os.join_path(fixture.dst, '12', 'foo')) or { '' } == '../../foo')
}

// Ruby it `it "renames the installed file if it already exists" do` at line 262.
pub fn ruby_pathname_spec_l262_d32_renames(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('install-renamed-file') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, 'a') or { return pathname_spec_bool(false) }
	homebrew.install_renamed_install_p(fixture.dst, fixture.file, os.base(fixture.file), '') or {
		return pathname_spec_bool(false)
	}
	os.write_file(fixture.file, 'b') or { return pathname_spec_bool(false) }
	homebrew.install_renamed_install_p(fixture.dst, fixture.file, os.base(fixture.file), '') or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.read_file(os.join_path(fixture.dst, os.base(fixture.file))) or { '' } == 'a' && os.read_file(os.join_path(fixture.dst, '${os.base(fixture.file)}.default')) or { '' } == 'b')
}

// Ruby it `it "renames the installed directory" do` at line 273.
pub fn ruby_pathname_spec_l273_d33_renames(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('install-renamed-directory') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, 'a') or { return pathname_spec_bool(false) }
	homebrew.install_renamed_install_p(fixture.dst, fixture.src, os.base(fixture.src), '') or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.read_file(os.join_path(fixture.dst, os.base(fixture.src), os.base(fixture.file))) or { '' } == 'a')
}

// Ruby it `it "recursively renames directories" do` at line 279.
pub fn ruby_pathname_spec_l279_d34_recursively(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('install-renamed-recursive') or { return pathname_spec_bool(false) }
	target_dir := os.join_path(fixture.dst, os.base(fixture.dir))
	os.mkdir_all(target_dir) or { return pathname_spec_bool(false) }
	os.write_file(os.join_path(target_dir, 'another_file'), 'a') or { return pathname_spec_bool(false) }
	os.mkdir_all(fixture.dir) or { return pathname_spec_bool(false) }
	os.write_file(os.join_path(fixture.dir, 'another_file'), 'b') or { return pathname_spec_bool(false) }
	homebrew.install_renamed_install_p(fixture.dst, fixture.dir, os.base(fixture.dir), '') or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.read_file(os.join_path(target_dir, 'another_file.default')) or { '' } == 'b')
}

// Ruby it `it "copies a file and replaces the given pattern" do` at line 290.
pub fn ruby_pathname_spec_l290_d35_copies(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('copy-file') or { return pathname_spec_bool(false) }
	os.write_file(fixture.file, 'a') or { return pathname_spec_bool(false) }
	destination := pathname_ext.pathname_cp_path_sub(fixture.file, fixture.src, fixture.dst) or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.read_file(destination) or { '' } == 'a' && destination == os.join_path(fixture.dst, os.base(fixture.file)))
}

// Ruby it `it "copies a directory and replaces the given pattern" do` at line 296.
pub fn ruby_pathname_spec_l296_d36_copies(args ...ruby.Value) ruby.Value {
	_ = args
	fixture := pathname_spec_fixture('copy-directory') or { return pathname_spec_bool(false) }
	os.mkdir_all(fixture.dir) or { return pathname_spec_bool(false) }
	destination := pathname_ext.pathname_cp_path_sub(fixture.dir, fixture.src, fixture.dst) or {
		return pathname_spec_bool(false)
	}
	return pathname_spec_bool(os.is_dir(destination) && destination == os.join_path(fixture.dst, os.base(fixture.dir)))
}

// Ruby it `it "returns whether a file is .DS_Store or not" do` at line 304.
pub fn ruby_pathname_spec_l304_d37_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return pathname_spec_bool(!pathname_ext.pathname_ds_store('/tmp/foo') && pathname_ext.pathname_ds_store('/tmp/foo/.DS_Store'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/pathname"
// 5: require "install_renamed"
// 6:
// 7: RSpec.describe Pathname do
// 8:   let(:src) { mktmpdir }
// 9:   let(:dst) { mktmpdir }
// 10:   let(:file) { src/"foo" }
// 11:   let(:dir) { src/"bar" }
// 12:
// 13:   include FileUtils
// 14:
// 15:   describe EagerInitializeExtension do
// 16:     it "defines the lazy memoised ivars on every new Pathname" do
// 17:       pathname = Pathname.new(file.to_s)
// 18:       [:@magic_number, :@file_type, :@zipinfo, :@which_install_info, :@disk_usage, :@file_count].each do |ivar|
// 19:         expect(pathname.instance_variable_defined?(ivar)).to be(true), "expected #{ivar} to be defined"
// 20:         # Read the raw ivars: the names are dynamic and eager raw definition is under test.
// 21:         # rubocop:disable Homebrew/NoInstanceVariableAccessInTests
// 22:         expect(pathname.instance_variable_get(ivar)).to be_nil
// 23:         # rubocop:enable Homebrew/NoInstanceVariableAccessInTests
// 24:       end
// 25:     end
// 26:   end
// 27:
// 28:   describe DiskUsageExtension do
// 29:     before do
// 30:       mkdir_p dir/"a-directory"
// 31:       touch [dir/".DS_Store", dir/"a-file"]
// 32:       File.truncate(dir/"a-file", 1_048_576)
// 33:       ln_s dir/"a-file", dir/"a-symlink"
// 34:       ln dir/"a-file", dir/"a-hardlink"
// 35:     end
// 36:
// 37:     describe "#file_count" do
// 38:       it "returns the number of files in a directory" do
// 39:         expect(dir.file_count).to eq(3)
// 40:       end
// 41:     end
// 42:
// 43:     describe "#abv" do
// 44:       context "when called on a directory" do
// 45:         it "returns a string with the file count and disk usage" do
// 46:           expect(dir.abv).to eq("3 files, 1MB")
// 47:         end
// 48:       end
// 49:
// 50:       context "when called on a file" do
// 51:         it "returns the disk usage" do
// 52:           expect((dir/"a-file").abv).to eq("1MB")
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57:
// 58:   describe "#rmdir_if_possible" do
// 59:     before { mkdir_p dir }
// 60:
// 61:     it "returns true and removes a directory if it doesn't contain files" do
// 62:       expect(dir.rmdir_if_possible).to be true
// 63:       expect(dir).not_to exist
// 64:     end
// 65:
// 66:     it "returns false and doesn't delete a directory if it contains files" do
// 67:       touch dir/"foo"
// 68:       expect(dir.rmdir_if_possible).to be false
// 69:       expect(dir).to be_a_directory
// 70:     end
// 71:
// 72:     it "ignores .DS_Store files" do
// 73:       touch dir/".DS_Store"
// 74:       expect(dir.rmdir_if_possible).to be true
// 75:       expect(dir).not_to exist
// 76:     end
// 77:   end
// 78:
// 79:   describe "#append_lines" do
// 80:     it "appends lines to a file" do
// 81:       touch file
// 82:
// 83:       file.append_lines("CONTENT")
// 84:       expect(File.read(file)).to eq <<~EOS
// 85:         CONTENT
// 86:       EOS
// 87:
// 88:       file.append_lines("CONTENTS")
// 89:       expect(File.read(file)).to eq <<~EOS
// 90:         CONTENT
// 91:         CONTENTS
// 92:       EOS
// 93:     end
// 94:
// 95:     it "raises an error if the file does not exist" do
// 96:       expect(file).not_to exist
// 97:       expect { file.append_lines("CONTENT") }.to raise_error(RuntimeError)
// 98:     end
// 99:   end
// 100:
// 101:   describe "#atomic_write" do
// 102:     it "atomically replaces a file" do
// 103:       touch file
// 104:       file.atomic_write("CONTENT")
// 105:       expect(File.read(file)).to eq("CONTENT")
// 106:     end
// 107:
// 108:     it "preserves permissions" do
// 109:       File.open(file, "w", 0100777) do
// 110:         # do nothing
// 111:       end
// 112:       file.atomic_write("CONTENT")
// 113:       expect(file.stat.mode.to_s(8)).to eq((~File.umask & 0100777).to_s(8))
// 114:     end
// 115:
// 116:     it "preserves default permissions" do
// 117:       file.atomic_write("CONTENT")
// 118:       sentinel = file.dirname.join("sentinel")
// 119:       touch sentinel
// 120:       expect(file.stat.mode.to_s(8)).to eq(sentinel.stat.mode.to_s(8))
// 121:     end
// 122:   end
// 123:
// 124:   describe "#ensure_writable" do
// 125:     it "makes a file writable and restores permissions afterwards" do
// 126:       skip "User is root so everything is writable." if Process.euid.zero?
// 127:       touch file
// 128:       chmod 0555, file
// 129:       expect(file).not_to be_writable
// 130:       file.ensure_writable do
// 131:         expect(file).to be_writable
// 132:       end
// 133:       expect(file).not_to be_writable
// 134:     end
// 135:   end
// 136:
// 137:   describe "#extname" do
// 138:     specify do
// 139:       expect(described_class.new("foo-0.1.tar.gz").extname).to eq(".tar.gz")
// 140:       expect(described_class.new("foo-0.1.cpio.gz").extname).to eq(".cpio.gz")
// 141:       expect(described_class.new("foo-0.1").extname).to eq("")
// 142:       expect(described_class.new("foo-1.0-rc1").extname).to eq("")
// 143:       expect(described_class.new("foo-1.2.3").extname).to eq ""
// 144:       expect(described_class.new("snap7-full-1.4.2.7z").extname).to eq ".7z"
// 145:     end
// 146:   end
// 147:
// 148:   describe "#stem" do
// 149:     it "returns the basename without double extensions" do
// 150:       expect(Pathname("foo-0.1.tar.gz").stem).to eq("foo-0.1")
// 151:       expect(Pathname("foo-0.1.cpio.gz").stem).to eq("foo-0.1")
// 152:     end
// 153:   end
// 154:
// 155:   describe "#install" do
// 156:     before do
// 157:       (src/"a.txt").write "This is sample file a."
// 158:       (src/"b.txt").write "This is sample file b."
// 159:     end
// 160:
// 161:     it "raises an error if the file doesn't exist" do
// 162:       expect { dst.install "non_existent_file" }.to raise_error(Errno::ENOENT)
// 163:     end
// 164:
// 165:     it "installs a file to a directory with its basename" do
// 166:       touch file
// 167:       dst.install(file)
// 168:       expect(dst/file.basename).to exist
// 169:       expect(file).not_to exist
// 170:     end
// 171:
// 172:     it "creates intermediate directories" do
// 173:       touch file
// 174:       expect(dir).not_to be_a_directory
// 175:       dir.install(file)
// 176:       expect(dir).to be_a_directory
// 177:     end
// 178:
// 179:     it "can install a file" do
// 180:       dst.install src/"a.txt"
// 181:       expect(dst/"a.txt").to exist, "a.txt was not installed"
// 182:       expect(dst/"b.txt").not_to exist, "b.txt was installed."
// 183:     end
// 184:
// 185:     it "can install an array of files" do
// 186:       dst.install [src/"a.txt", src/"b.txt"]
// 187:
// 188:       expect(dst/"a.txt").to exist, "a.txt was not installed"
// 189:       expect(dst/"b.txt").to exist, "b.txt was not installed"
// 190:     end
// 191:
// 192:     it "can install a directory" do
// 193:       bin = src/"bin"
// 194:       bin.mkpath
// 195:       mv Dir[src/"*.txt"], bin
// 196:       dst.install bin
// 197:
// 198:       expect(dst/"bin/a.txt").to exist, "a.txt was not installed"
// 199:       expect(dst/"bin/b.txt").to exist, "b.txt was not installed"
// 200:     end
// 201:
// 202:     it "supports renaming files" do
// 203:       dst.install src/"a.txt" => "c.txt"
// 204:
// 205:       expect(dst/"c.txt").to exist, "c.txt was not installed"
// 206:       expect(dst/"a.txt").not_to exist, "a.txt was installed but not renamed"
// 207:       expect(dst/"b.txt").not_to exist, "b.txt was installed"
// 208:     end
// 209:
// 210:     it "supports renaming multiple files" do
// 211:       dst.install(src/"a.txt" => "c.txt", src/"b.txt" => "d.txt")
// 212:
// 213:       expect(dst/"c.txt").to exist, "c.txt was not installed"
// 214:       expect(dst/"d.txt").to exist, "d.txt was not installed"
// 215:       expect(dst/"a.txt").not_to exist, "a.txt was installed but not renamed"
// 216:       expect(dst/"b.txt").not_to exist, "b.txt was installed but not renamed"
// 217:     end
// 218:
// 219:     it "supports renaming directories" do
// 220:       bin = src/"bin"
// 221:       bin.mkpath
// 222:       mv Dir[src/"*.txt"], bin
// 223:       dst.install bin => "libexec"
// 224:
// 225:       expect(dst/"bin").not_to exist, "bin was installed but not renamed"
// 226:       expect(dst/"libexec/a.txt").to exist, "a.txt was not installed"
// 227:       expect(dst/"libexec/b.txt").to exist, "b.txt was not installed"
// 228:     end
// 229:
// 230:     it "can install directories as relative symlinks" do
// 231:       bin = src/"bin"
// 232:       bin.mkpath
// 233:       mv Dir[src/"*.txt"], bin
// 234:       dst.install_symlink bin
// 235:
// 236:       expect(dst/"bin").to be_a_symlink
// 237:       expect(dst/"bin").to be_a_directory
// 238:       expect(dst/"bin/a.txt").to exist
// 239:       expect(dst/"bin/b.txt").to exist
// 240:       expect((dst/"bin").readlink).to be_relative
// 241:     end
// 242:
// 243:     it "can install relative paths as symlinks" do
// 244:       dst.install_symlink "foo" => "bar"
// 245:       expect((dst/"bar").readlink).to eq(described_class.new("foo"))
// 246:     end
// 247:
// 248:     it "can install relative symlinks in a symlinked directory" do
// 249:       mkdir_p dst/"1/2"
// 250:       dst.install_symlink "1/2" => "12"
// 251:       expect((dst/"12").readlink).to eq(described_class.new("1/2"))
// 252:       (dst/"12").install_symlink dst/"foo"
// 253:       expect((dst/"12/foo").readlink).to eq(described_class.new("../../foo"))
// 254:     end
// 255:   end
// 256:
// 257:   describe InstallRenamed do
// 258:     before do
// 259:       dst.extend(described_class)
// 260:     end
// 261:
// 262:     it "renames the installed file if it already exists" do
// 263:       file.write "a"
// 264:       dst.install file
// 265:
// 266:       file.write "b"
// 267:       dst.install file
// 268:
// 269:       expect(File.read(dst/file.basename)).to eq("a")
// 270:       expect(File.read(dst/"#{file.basename}.default")).to eq("b")
// 271:     end
// 272:
// 273:     it "renames the installed directory" do
// 274:       file.write "a"
// 275:       dst.install src
// 276:       expect(File.read(dst/src.basename/file.basename)).to eq("a")
// 277:     end
// 278:
// 279:     it "recursively renames directories" do
// 280:       (dst/dir.basename).mkpath
// 281:       (dst/dir.basename/"another_file").write "a"
// 282:       dir.mkpath
// 283:       (dir/"another_file").write "b"
// 284:       dst.install dir
// 285:       expect(File.read(dst/dir.basename/"another_file.default")).to eq("b")
// 286:     end
// 287:   end
// 288:
// 289:   describe "#cp_path_sub" do
// 290:     it "copies a file and replaces the given pattern" do
// 291:       file.write "a"
// 292:       file.cp_path_sub src, dst
// 293:       expect(File.read(dst/file.basename)).to eq("a")
// 294:     end
// 295:
// 296:     it "copies a directory and replaces the given pattern" do
// 297:       dir.mkpath
// 298:       dir.cp_path_sub src, dst
// 299:       expect(dst/dir.basename).to be_a_directory
// 300:     end
// 301:   end
// 302:
// 303:   describe "#ds_store?" do
// 304:     it "returns whether a file is .DS_Store or not" do
// 305:       expect(file).not_to be_ds_store
// 306:       expect(file/".DS_Store").to be_ds_store
// 307:     end
// 308:   end
// 309: end
