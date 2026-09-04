module test

import ruby
import homebrew
import os
import time

fn cleanup_spec_root(name string) string {
	return os.join_path(os.temp_dir(), 'brew-v-cleanup-spec-${name}')
}

fn cleanup_spec_reset(name string) string {
	root := cleanup_spec_root(name)
	if os.exists(root) {
		os.rmdir_all(root) or { panic(err) }
	}
	os.mkdir_all(root) or { panic(err) }
	return root
}

fn cleanup_spec_touch(path string) {
	os.mkdir_all(os.dir(path)) or { panic(err) }
	os.write_file(path, '') or { panic(err) }
}

fn cleanup_spec_path(path string, attributes map[string]string) ruby.Value {
	mut values := attributes.clone()
	values['exists'] = values['exists'] or { (os.exists(path) || os.is_link(path)).str() }
	values['directory'] = values['directory'] or { os.is_dir(path).str() }
	values['file'] = values['file'] or { os.is_file(path).str() }
	values['symlink'] = values['symlink'] or { os.is_link(path).str() }
	values['resolved_file'] = values['resolved_file'] or { os.is_file(path).str() }
	return ruby.structured_value('Pathname', path, values)
}

fn cleanup_spec_formula(name string, latest bool, version string) ruby.Value {
	return ruby.structured_value('Formula', name, {
		'name':                     name
		'latest_version_installed': latest.str()
		'pkg_version':              version
		'installed_versions':       version
		'eligible_versions':        version
	})
}

fn cleanup_spec_cask(token string, version string, installed string, latest bool,
	url string) ruby.Value {
	return ruby.structured_value('Cask::Cask', token, {
		'token':             token
		'version':           version
		'installed_version': installed
		'latest':            latest.str()
		'url':               url
		'caskroom_path':     os.join_path(cleanup_spec_root('caskroom'), token)
	})
}

fn cleanup_spec_new(cache string, dry_run bool, scrub bool, days ?int) ruby.Value {
	days_value := if cleanup_days := days {
		ruby.int_value(cleanup_days)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return homebrew.ruby_cleanup_l271_d16_initialize(ruby.array_value([]), ruby.map_value({
		'cache':   ruby.object_value('Pathname', cache)
		'dry_run': ruby.bool_value(dry_run)
		'scrub':   ruby.bool_value(scrub)
		'days':    days_value
	}))
}

fn cleanup_spec_entry(path ruby.Value, type_name string,
	additional map[string]ruby.Value) ruby.Value {
	mut values := additional.clone()
	values['path'] = path
	values['type'] = if type_name == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.object_value('Symbol', ':${type_name}')
	}
	return ruby.Value{
		type_name: 'Hash'
		map_data: values
		attributes: path.attributes.clone()
	}
}

fn cleanup_spec_nested_cache(name string) bool {
	root := cleanup_spec_reset('nested-${name}')
	path := os.join_path(root, name)
	os.mkdir_all(path) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(cleanup_spec_path(path, {}), '', {}),
	]), ruby.bool_value(false))
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return result
}

fn cleanup_spec_bool(result bool) ruby.Value {
	return ruby.bool_value(result)
}

// Translated from Homebrew/brew `test/cleanup_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cleanup) { described_class.new }` at line 12.
pub fn ruby_cleanup_spec_l12_d1_cleanup(args ...ruby.Value) ruby.Value {
	return cleanup_spec_new(ruby.environment_value('HOMEBREW_CACHE'), false, false, none)
}

// Ruby let `let(:ds_store) { Pathname.new("#{HOMEBREW_CELLAR}/.DS_Store") }` at line 14.
pub fn ruby_cleanup_spec_l14_d2_ds_store(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CELLAR'), '.DS_Store'))
}

// Ruby let `let(:lock_file) { Pathname.new("#{HOMEBREW_LOCKS}/foo") }` at line 15.
pub fn ruby_cleanup_spec_l15_d3_lock_file(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_LOCKS'), 'foo'))
}

// Ruby subject `subject(:path) { HOMEBREW_CACHE/"foo" }` at line 31.
pub fn ruby_cleanup_spec_l31_d4_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CACHE'), 'foo'))
}

// Ruby it `it "returns true when ctime and mtime < days_default" do` at line 37.
pub fn ruby_cleanup_spec_l37_d5_returns(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	path := cleanup_spec_path('/cache/foo', {
		'exists': 'true'
		'mtime':  (now - 172800).str()
		'ctime':  (now - 172800).str()
	})
	return cleanup_spec_bool(homebrew.ruby_cleanup_l50_d4_prune(path, ruby.int_value(1), ruby.int_value(now)).bool_data)
}

// Ruby it `it "returns false when ctime and mtime >= days_default" do` at line 43.
pub fn ruby_cleanup_spec_l43_d6_returns(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	path := cleanup_spec_path('/cache/foo', {
		'exists': 'true'
		'mtime':  now.str()
		'ctime':  now.str()
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l50_d4_prune(path, ruby.int_value(2), ruby.int_value(now)).bool_data)
}

// Ruby it `it "removes .DS_Store and lock files" do` at line 49.
pub fn ruby_cleanup_spec_l49_d7_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('clean-files')
	ds_store := os.join_path(root, 'Cellar', '.DS_Store')
	lock_path := os.join_path(root, 'locks', 'foo')
	cleanup_spec_touch(ds_store)
	cleanup_spec_touch(lock_path)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l810_d51_rm_ds_store(cleanup, ruby.array_value([
		ruby.object_value('Pathname', os.join_path(root, 'Cellar')),
	]))
	homebrew.ruby_cleanup_l711_d46_cleanup_lockfiles(cleanup, cleanup_spec_path(lock_path, {}))
	result := !os.exists(ds_store) && !os.exists(lock_path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "doesn't remove anything if `dry_run` is true" do` at line 56.
pub fn ruby_cleanup_spec_l56_d8_doesn(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('dry-run')
	ds_store := os.join_path(root, '.DS_Store')
	lock_path := os.join_path(root, 'foo.lock')
	cleanup_spec_touch(ds_store)
	cleanup_spec_touch(lock_path)
	cleanup := cleanup_spec_new(root, true, false, none)
	homebrew.ruby_cleanup_l810_d51_rm_ds_store(cleanup, ruby.array_value([
		ruby.object_value('Pathname', root),
	]))
	homebrew.ruby_cleanup_l711_d46_cleanup_lockfiles(cleanup, cleanup_spec_path(lock_path, {}))
	result := os.exists(ds_store) && os.exists(lock_path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes leftover `.reinstall` kegs in the Cellar" do` at line 63.
pub fn ruby_cleanup_spec_l63_d9_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('reinstall')
	reinstall := os.join_path(root, 'Cellar', 'foo', '1.0.reinstall')
	os.mkdir_all(reinstall) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l582_d40_cleanup_reinstall_kegs(cleanup, ruby.object_value('Pathname', os.join_path(root, 'Cellar')))
	result := !os.exists(reinstall)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "doesn't remove the lock file if it is locked" do` at line 72.
pub fn ruby_cleanup_spec_l72_d10_doesn(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('locked')
	lock_path := os.join_path(root, 'foo')
	cleanup_spec_touch(lock_path)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l711_d46_cleanup_lockfiles(cleanup, cleanup_spec_path(lock_path, {
		'locked': 'true'
	}))
	result := os.exists(lock_path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up unreferenced downloads once, however many formulae are installed" do` at line 80.
pub fn ruby_cleanup_spec_l80_d11_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('unreferenced-once')
	download := os.join_path(root, 'downloads', 'orphan')
	cleanup_spec_touch(download)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l636_d43_cleanup_unreferenced_downloads(cleanup)
	result := !os.exists(download)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "doesn't load untrusted installed formulae while cleaning the cache" do` at line 92.
pub fn ruby_cleanup_spec_l92_d12_doesn(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/untrusted--1.0', {
		'exists':        'true'
		'file':          'true'
		'resolved_file': 'true'
	})
	formula := ruby.structured_value('Formula', 'untrusted', {
		'name':      'untrusted'
		'untrusted': 'true'
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(false), formula, ruby.bool_value(true)).bool_data)
}

// Ruby let `let(:formula_zero_dot_one) { Class.new(Testball) { version "0.1" }.new }` at line 106.
pub fn ruby_cleanup_spec_l106_d13_formula_zero_dot_one(args ...ruby.Value) ruby.Value {
	return cleanup_spec_formula('testball', true, '0.1')
}

// Ruby let `let(:formula_zero_dot_two) { Class.new(Testball) { version "0.2" }.new }` at line 107.
pub fn ruby_cleanup_spec_l107_d14_formula_zero_dot_two(args ...ruby.Value) ruby.Value {
	return cleanup_spec_formula('testball', true, '0.2')
}

// Ruby it `it "doesn't remove any kegs" do` at line 123.
pub fn ruby_cleanup_spec_l123_d15_doesn(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('keg-failure')
	keg := os.join_path(root, 'testball', '0.1')
	os.mkdir_all(keg) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l554_d37_cleanup_keg(cleanup, cleanup_spec_path(keg, {
		'uninstall_error': 'true'
	}))
	result := os.exists(keg)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "lists the unremovable kegs" do` at line 128.
pub fn ruby_cleanup_spec_l128_d16_lists(args ...ruby.Value) ruby.Value {
	cleanup := cleanup_spec_new('/cache', false, false, none)
	keg := cleanup_spec_path('/Cellar/testball/0.1', {
		'exists':          'true'
		'directory':       'true'
		'uninstall_error': 'true'
	})
	homebrew.ruby_cleanup_l554_d37_cleanup_keg(cleanup, keg)
	actual := (homebrew.ruby_cleanup_l466_d30_unremovable_kegs(cleanup).as_array() or { [] }).map(it.repr)
	return cleanup_spec_bool(actual == [
		keg.repr,
	])
}

// Ruby let `let(:removable_keg) { instance_double(Keg, name: "libthai") }` at line 136.
pub fn ruby_cleanup_spec_l136_d17_removable_keg(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Keg', '/Cellar/libthai/1.0', {
		'name': 'libthai'
	})
}

// Ruby let `let(:removable_formula) do` at line 137.
pub fn ruby_cleanup_spec_l137_d18_removable_formula(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Formula', 'libthai', {
		'name':              'libthai'
		'full_name':         'libthai'
		'any_installed_keg': '/Cellar/libthai/1.0'
	})
}

// Ruby it `it "does not print or uninstall formulae required by installed dependents" do` at line 153.
pub fn ruby_cleanup_spec_l153_d19_does(args ...ruby.Value) ruby.Value {
	formula := ruby_cleanup_spec_l137_d18_removable_formula()
	result := homebrew.ruby_cleanup_l938_d54_self_autoremove(ruby.bool_value(false), ruby.array_value([
		formula,
	]), ruby.array_value([]), ruby.array_value([formula]), ruby.string_array_value([
		'libthai',
	]), ruby.string_value(''))
	return cleanup_spec_bool(result.repr == '' && result.array_data.len == 0)
}

// Ruby let `let(:lib) { HOMEBREW_PREFIX/"lib" }` at line 161.
pub fn ruby_cleanup_spec_l161_d20_lib(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'lib'))
}

// Ruby it `it "keeps required empty directories" do` at line 167.
pub fn ruby_cleanup_spec_l167_d21_keeps(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('required-empty')
	lib := os.join_path(root, 'lib')
	os.mkdir_all(lib) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([
		ruby.object_value('Pathname', lib),
	]))
	result := os.is_dir(lib) && (os.ls(lib) or { [] }).len == 0
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes broken symlinks" do` at line 173.
pub fn ruby_cleanup_spec_l173_d22_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('broken-link')
	lib := os.join_path(root, 'lib')
	os.mkdir_all(lib) or { panic(err) }
	os.symlink(os.join_path(lib, 'foo'), os.join_path(lib, 'bar')) or { panic(err) }
	cleanup_spec_touch(os.join_path(lib, 'baz'))
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([
		ruby.object_value('Pathname', lib),
	]))
	result := !os.is_link(os.join_path(lib, 'bar')) && os.exists(os.join_path(lib, 'baz'))
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes empty directories" do` at line 182.
pub fn ruby_cleanup_spec_l182_d23_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('empty-dir')
	lib := os.join_path(root, 'lib')
	empty := os.join_path(lib, 'test')
	file := os.join_path(lib, 'keep', 'file')
	os.mkdir_all(empty) or { panic(err) }
	cleanup_spec_touch(file)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([
		ruby.object_value('Pathname', lib),
	]))
	result := !os.exists(empty) && os.exists(file)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby let `let(:dir) { HOMEBREW_PREFIX/"lib/foo" }` at line 195.
pub fn ruby_cleanup_spec_l195_d24_dir(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'lib', 'foo'))
}

// Ruby let `let(:child_dir) { dir/"bar" }` at line 196.
pub fn ruby_cleanup_spec_l196_d25_child_dir(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l195_d24_dir().repr, 'bar'))
}

// Ruby let `let(:grandchild_dir) { child_dir/"baz" }` at line 197.
pub fn ruby_cleanup_spec_l197_d26_grandchild_dir(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l196_d25_child_dir().repr, 'baz'))
}

// Ruby let `let(:broken_link) { dir/"broken" }` at line 198.
pub fn ruby_cleanup_spec_l198_d27_broken_link(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l195_d24_dir().repr, 'broken'))
}

// Ruby let `let(:link_to_broken_link) { child_dir/"another-broken" }` at line 199.
pub fn ruby_cleanup_spec_l199_d28_link_to_broken_link(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l196_d25_child_dir().repr, 'another-broken'))
}

// Ruby it `it "removes broken symlinks and resulting empty directories" do` at line 207.
pub fn ruby_cleanup_spec_l207_d29_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('nested-broken')
	dir := os.join_path(root, 'lib', 'foo')
	child := os.join_path(dir, 'bar')
	os.mkdir_all(os.join_path(child, 'baz')) or { panic(err) }
	os.symlink(os.join_path(dir, 'missing'), os.join_path(dir, 'broken')) or { panic(err) }
	os.symlink(os.join_path(dir, 'broken'), os.join_path(child, 'another-broken')) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([
		ruby.object_value('Pathname', os.join_path(root, 'lib')),
	]))
	result := !os.exists(dir)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "doesn't remove anything and only prints removal steps if `dry_run` is true" do` at line 212.
pub fn ruby_cleanup_spec_l212_d30_doesn(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('nested-broken-dry')
	dir := os.join_path(root, 'lib', 'foo')
	child := os.join_path(dir, 'bar')
	grandchild := os.join_path(child, 'baz')
	os.mkdir_all(grandchild) or { panic(err) }
	broken := os.join_path(dir, 'broken')
	other_broken := os.join_path(child, 'another-broken')
	os.symlink(os.join_path(dir, 'missing'), broken) or { panic(err) }
	os.symlink(broken, other_broken) or { panic(err) }
	cleanup := cleanup_spec_new(root, true, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([
		ruby.object_value('Pathname', os.join_path(root, 'lib')),
	]))
	result := os.is_link(broken) && os.is_link(other_broken) && os.is_dir(grandchild)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes broken symlinks for uninstalled migrated Casks" do` at line 229.
pub fn ruby_cleanup_spec_l229_d31_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('migrated-cask')
	caskroom := os.join_path(root, 'Caskroom')
	other := os.join_path(caskroom, 'other')
	os.mkdir_all(other) or { panic(err) }
	old := os.join_path(caskroom, 'old')
	os.symlink(os.join_path(caskroom, 'new'), old) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l875_d53_prune_prefix_symlinks_and_directories(cleanup, ruby.array_value([]), ruby.object_value('Pathname', caskroom))
	result := os.exists(other) && !os.is_link(old) && !os.exists(old)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby specify `specify "::cleanup_formula" do` at line 244.
pub fn ruby_cleanup_spec_l244_d32_cleanup_formula(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('cleanup-formula')
	old_one := os.join_path(root, 'Cellar', 'testball', '1.0')
	old_two := os.join_path(root, 'Cellar', 'testball', '0.2')
	current := os.join_path(root, 'Cellar', 'testball', '0.3')
	current_scheme := os.join_path(root, 'Cellar', 'testball', '0.1_2')
	for path in [old_one, old_two, current, current_scheme] {
		os.mkdir_all(path) or { panic(err) }
	}
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l554_d37_cleanup_keg(cleanup, cleanup_spec_path(old_one, {}))
	homebrew.ruby_cleanup_l554_d37_cleanup_keg(cleanup, cleanup_spec_path(old_two, {}))
	result := !os.exists(old_one) && !os.exists(old_two) && os.exists(current) && os.exists(current_scheme)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby let `let(:cache) { mktmpdir/"cache" }` at line 286.
pub fn ruby_cleanup_spec_l286_d33_cache(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', cleanup_spec_root('formula-cache'))
}

// Ruby let `let(:testball) { instance_double(Formula, name: "testball") }` at line 287.
pub fn ruby_cleanup_spec_l287_d34_testball(args ...ruby.Value) ruby.Value {
	return cleanup_spec_formula('testball', true, '1.0')
}

// Ruby it `it "returns only the formula's own downloads and bottle manifests" do` at line 293.
pub fn ruby_cleanup_spec_l293_d35_returns(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('formula-paths')
	matching := ['testball--1.0.tar.gz', 'testball--rsrc--1.0.txt',
		'testball_bottle_manifest--1.0.bottle_manifest.json']
	for name in matching {
		cleanup_spec_touch(os.join_path(root, name))
	}
	for name in ['.testball--1.0.tar.gz', 'testball-foo--1.0.tar.gz', 'testball_bottle_manifest',
		'testballs--1.0.tar.gz'] {
		cleanup_spec_touch(os.join_path(root, name))
	}
	cleanup := cleanup_spec_new(root, false, false, none)
	actual := (homebrew.ruby_cleanup_l490_d33_formula_cache_paths(cleanup, cleanup_spec_formula('testball', true, '1.0')).as_array() or { [] }).map(os.base(it.repr))
	result := actual == matching
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "reads the cache directory only once for multiple formulae" do` at line 310.
pub fn ruby_cleanup_spec_l310_d36_reads(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('formula-index')
	cleanup_spec_touch(os.join_path(root, 'testball--1.0.tar.gz'))
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l490_d33_formula_cache_paths(cleanup, cleanup_spec_formula('testball', true, '1.0'))
	cleanup_spec_touch(os.join_path(root, 'other--1.0.tar.gz'))
	second := homebrew.ruby_cleanup_l490_d33_formula_cache_paths(cleanup, cleanup_spec_formula('other', true, '1.0'))
	result := (second.as_array() or { [] }).len == 0
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load("local-transmission") }` at line 326.
pub fn ruby_cleanup_spec_l326_d37_cask(args ...ruby.Value) ruby.Value {
	return cleanup_spec_cask('local-transmission', '2.61', '2.61', false, 'https://example.com/transmission-2.61.dmg')
}

// Ruby it `it "removes the download if it is not for the latest version" do` at line 328.
pub fn ruby_cleanup_spec_l328_d38_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('cask-old')
	path := os.join_path(root, 'Cask', 'local-transmission--7.8.9')
	cleanup_spec_touch(path)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, ruby_cleanup_spec_l326_d37_cask())
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes legacy URL-basename downloads if they are not for the latest version" do` at line 338.
pub fn ruby_cleanup_spec_l338_d39_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('legacy-old')
	path := os.join_path(root, 'Cask', 'transmission-2.61.dmg--7.8.9.dmg')
	cleanup_spec_touch(path)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, ruby_cleanup_spec_l326_d37_cask())
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not remove downloads for the latest version" do` at line 348.
pub fn ruby_cleanup_spec_l348_d40_does(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('cask-current')
	path := os.join_path(root, 'Cask', 'local-transmission--2.61')
	cleanup_spec_touch(path)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, ruby_cleanup_spec_l326_d37_cask())
	result := os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "removes legacy URL-basename downloads when the token-named download exists" do` at line 358.
pub fn ruby_cleanup_spec_l358_d41_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('legacy-token')
	legacy := os.join_path(root, 'Cask', 'transmission-2.61.dmg--2.61.dmg')
	current := os.join_path(root, 'Cask', 'local-transmission--2.61.dmg')
	cleanup_spec_touch(legacy)
	cleanup_spec_touch(current)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, ruby_cleanup_spec_l326_d37_cask())
	result := !os.exists(legacy) && os.exists(current)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not remove downloads when the latest version ends with a comma" do` at line 370.
pub fn ruby_cleanup_spec_l370_d42_does(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('trailing-comma')
	path := os.join_path(root, 'Cask', 'trailing-comma--7.2,2023.3,.zip')
	cleanup_spec_touch(path)
	cask := cleanup_spec_cask('trailing-comma', '7.2,2023.3,', '7.2,2023.3,', false, '')
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, cask)
	result := os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load("latest") }` at line 390.
pub fn ruby_cleanup_spec_l390_d43_cask(args ...ruby.Value) ruby.Value {
	return cleanup_spec_cask('latest', 'latest', 'latest', true, 'https://example.com/latest.zip')
}

// Ruby it `it "does not remove the download for the latest version" do` at line 392.
pub fn ruby_cleanup_spec_l392_d44_does(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	path := cleanup_spec_path('/cache/Cask/latest--latest', {
		'exists': 'true'
		'file':   'true'
		'mtime':  now.str()
		'ctime':  now.str()
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l84_d7_stale_cask_download(path, ruby_cleanup_spec_l390_d43_cask(), ruby.string_value('latest'), ruby.bool_value(false), ruby.int_value(now)).bool_data)
}

// Ruby it `it "removes the download for the latest version after 30 days" do` at line 402.
pub fn ruby_cleanup_spec_l402_d45_removes(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	old := now - 30 * 24 * 60 * 60 - 3600
	path := cleanup_spec_path('/cache/Cask/latest--latest', {
		'exists': 'true'
		'file':   'true'
		'mtime':  old.str()
		'ctime':  old.str()
	})
	return cleanup_spec_bool(homebrew.ruby_cleanup_l84_d7_stale_cask_download(path, ruby_cleanup_spec_l390_d43_cask(), ruby.string_value('latest'), ruby.bool_value(false), ruby.int_value(now)).bool_data)
}

// Ruby it `it "removes broken legacy URL-basename downloads" do` at line 413.
pub fn ruby_cleanup_spec_l413_d46_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('broken-legacy')
	path := os.join_path(root, 'Cask', 'caffeine.zip--latest.zip')
	os.mkdir_all(os.dir(path)) or { panic(err) }
	os.symlink(os.join_path(root, 'Cask', 'missing.zip'), path) or { panic(err) }
	cask := cleanup_spec_cask('latest-cask', 'latest', '', true, 'file:///fixtures/caffeine.zip')
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l517_d35_cleanup_cask(cleanup, cask)
	result := !os.is_link(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby let `let(:path) { HOMEBREW_LOGS/"delete_me" }` at line 432.
pub fn ruby_cleanup_spec_l432_d47_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_LOGS'), 'delete_me'))
}

// Ruby it `it "cleans all logs if prune is 0" do` at line 438.
pub fn ruby_cleanup_spec_l438_d48_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('logs-zero')
	path := os.join_path(root, 'delete_me')
	os.mkdir_all(path) or { panic(err) }
	cleanup := cleanup_spec_new('/cache', false, false, 0)
	homebrew.ruby_cleanup_l562_d38_cleanup_logs(cleanup, ruby.object_value('Pathname', root))
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up logs if older than 30 days" do` at line 443.
pub fn ruby_cleanup_spec_l443_d49_cleans(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	old := now - 31 * 24 * 60 * 60
	path := cleanup_spec_path('/logs/delete_me', {
		'exists':    'true'
		'directory': 'true'
		'mtime':     old.str()
		'ctime':     old.str()
	})
	return cleanup_spec_bool(homebrew.ruby_cleanup_l50_d4_prune(path, ruby.int_value(30), ruby.int_value(now)).bool_data)
}

// Ruby it `it "does not clean up logs less than 30 days old" do` at line 450.
pub fn ruby_cleanup_spec_l450_d50_does(args ...ruby.Value) ruby.Value {
	now := time.now().unix()
	recent := now - 15 * 24 * 60 * 60
	path := cleanup_spec_path('/logs/delete_me', {
		'exists':    'true'
		'directory': 'true'
		'mtime':     recent.str()
		'ctime':     recent.str()
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l50_d4_prune(path, ruby.int_value(30), ruby.int_value(now)).bool_data)
}

// Ruby it `it "removes legacy cask downloads during full cache cleanup", :cask do` at line 459.
pub fn ruby_cleanup_spec_l459_d51_removes(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('full-legacy')
	legacy := os.join_path(root, 'Cask', 'transmission-2.61.dmg--7.8.9.dmg')
	cleanup_spec_touch(legacy)
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l530_d36_cleanup_legacy_cask_downloads(cleanup, ruby.array_value([
		ruby_cleanup_spec_l326_d37_cask(),
	]))
	result := !os.exists(legacy)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up incomplete downloads" do` at line 472.
pub fn ruby_cleanup_spec_l472_d52_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('incomplete')
	path := os.join_path(root, 'something.incomplete')
	os.mkdir_all(path) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, none)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(cleanup_spec_path(path, {}), '', {}),
	]), ruby.bool_value(false))
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up 'cargo_cache'" do` at line 481.
pub fn ruby_cleanup_spec_l481_d53_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('cargo_cache'))
}

// Ruby it `it "cleans up 'go_cache'" do` at line 490.
pub fn ruby_cleanup_spec_l490_d54_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('go_cache'))
}

// Ruby it `it "cleans up 'glide_home'" do` at line 499.
pub fn ruby_cleanup_spec_l499_d55_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('glide_home'))
}

// Ruby it `it "cleans up 'java_cache'" do` at line 508.
pub fn ruby_cleanup_spec_l508_d56_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('java_cache'))
}

// Ruby it `it "cleans up 'npm_cache'" do` at line 517.
pub fn ruby_cleanup_spec_l517_d57_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('npm_cache'))
}

// Ruby it `it "cleans up 'gclient_cache'" do` at line 526.
pub fn ruby_cleanup_spec_l526_d58_cleans(args ...ruby.Value) ruby.Value {
	return cleanup_spec_bool(cleanup_spec_nested_cache('gclient_cache'))
}

// Ruby it `it "cleans up all files and directories" do` at line 535.
pub fn ruby_cleanup_spec_l535_d59_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('prune-all')
	git := os.join_path(root, 'gist--git')
	gist := os.join_path(root, 'gist')
	svn := os.join_path(root, 'gist--svn')
	os.mkdir_all(git) or { panic(err) }
	os.mkdir_all(gist) or { panic(err) }
	cleanup_spec_touch(svn)
	cleanup := cleanup_spec_new(root, false, false, 0)
	entries := [git, gist, svn].map(cleanup_spec_entry(cleanup_spec_path(it, {}), '', {}))
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value(entries), ruby.bool_value(false))
	result := !os.exists(git) && os.exists(gist) && !os.exists(svn)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not clean up directories that are not VCS checkouts" do` at line 551.
pub fn ruby_cleanup_spec_l551_d60_does(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('plain-directory')
	git := os.join_path(root, 'git')
	os.mkdir_all(git) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, 0)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(cleanup_spec_path(git, {}), '', {}),
	]), ruby.bool_value(false))
	result := os.exists(git)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up VCS checkout directories with modified time < prune time" do` at line 560.
pub fn ruby_cleanup_spec_l560_d61_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('old-vcs')
	path := os.join_path(root, '--foo')
	os.mkdir_all(path) or { panic(err) }
	now := time.now().unix()
	old := now - 2 * 24 * 60 * 60
	path_value := cleanup_spec_path(path, {
		'mtime': old.str()
		'ctime': old.str()
	})
	cleanup := cleanup_spec_new(root, false, false, 1)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(path_value, '', {}),
	]), ruby.bool_value(false))
	result := !os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not clean up VCS checkout directories with modified time >= prune time" do` at line 569.
pub fn ruby_cleanup_spec_l569_d62_does(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('recent-vcs')
	path := os.join_path(root, '--foo')
	os.mkdir_all(path) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, 1)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(cleanup_spec_path(path, {}), '', {}),
	]), ruby.bool_value(false))
	result := os.exists(path)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not clean up internal package API files without scrub even when pruning" do` at line 576.
pub fn ruby_cleanup_spec_l576_d63_does(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('api-no-scrub')
	first := os.join_path(root, 'api', 'internal', 'packages.arm64_golden_gate.jws.json')
	second := os.join_path(root, 'api', 'internal', 'packages.arm64_tahoe.jws.json')
	cleanup_spec_touch(first)
	cleanup_spec_touch(second)
	cleanup := cleanup_spec_new(root, false, false, 0)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.object_value('NilClass', 'nil'), ruby.bool_value(false))
	result := os.exists(first) && os.exists(second)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up non-current internal package API files with scrub" do` at line 591.
pub fn ruby_cleanup_spec_l591_d64_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('api-scrub')
	current := os.join_path(root, 'api', 'internal', 'packages.current.jws.json')
	stale := os.join_path(root, 'api', 'internal', 'packages.stale.jws.json')
	cleanup_spec_touch(current)
	cleanup_spec_touch(stale)
	cleanup := cleanup_spec_new(root, false, true, none)
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value([
		cleanup_spec_entry(cleanup_spec_path(stale, {}), 'api_package', {}),
	]), ruby.bool_value(false))
	result := os.exists(current) && !os.exists(stale)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up non-current internal package API payload sidecars with scrub" do` at line 615.
pub fn ruby_cleanup_spec_l615_d65_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('api-sidecars')
	current := os.join_path(root, 'api', 'internal', 'packages.current.jws.json')
	kept := [current, '${current}.payload', '${current}.payload.index']
	scrubbed := [
		os.join_path(root, 'api', 'internal', 'packages.stale.jws.json.payload'),
		os.join_path(root, 'api', 'internal', 'packages.stale.jws.json.payload.index'),
		'${current}.payload.tmp',
	]
	mut all_files := kept.clone()
	all_files << scrubbed
	for path in all_files {
		cleanup_spec_touch(path)
	}
	cleanup := cleanup_spec_new(root, false, true, none)
	entries := scrubbed.map(cleanup_spec_entry(cleanup_spec_path(it, {}), 'api_package', {}))
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value(entries), ruby.bool_value(false))
	result := kept.all(os.exists(it)) && scrubbed.all(!os.exists(it))
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up API source files and symlinks at any depth without cleaning directories" do` at line 639.
pub fn ruby_cleanup_spec_l639_d66_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('api-source-depth')
	root_file := os.join_path(root, 'api-source', 'Homebrew', 'homebrew-core', 'abc123', 'README.md')
	nested := os.join_path(root, 'api-source', 'Homebrew', 'homebrew-core', 'abc123', 'Formula', 'a', 'testball.rb')
	directory := os.join_path(root, 'api-source', 'Homebrew', 'homebrew-core', 'abc123', 'patches', 'keep')
	cleanup_spec_touch(root_file)
	cleanup_spec_touch(nested)
	os.mkdir_all(directory) or { panic(err) }
	cleanup := cleanup_spec_new(root, false, false, 0)
	entries := [root_file, nested].map(cleanup_spec_entry(cleanup_spec_path(it, {}), 'api_source', {}))
	homebrew.ruby_cleanup_l666_d44_cleanup_cache(cleanup, ruby.array_value(entries), ruby.bool_value(false))
	result := !os.exists(root_file) && !os.exists(nested) && os.exists(directory)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "does not remove recent API source local patches as stale" do` at line 661.
pub fn ruby_cleanup_spec_l661_d67_does(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/api-source/Homebrew/homebrew-core/abc123/patches/noop-a.diff', {
		'exists':        'true'
		'file':          'true'
		'resolved_file': 'true'
		'mtime':         time.now().unix().str()
		'ctime':         time.now().unix().str()
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l100_d8_stale_api_source(path, ruby.bool_value(false), ruby.structured_value('Package', '', {
		'found': 'false'
	})).bool_data)
}

// Ruby it `it "keeps current API formula source paths when tap git head matches" do` at line 674.
pub fn ruby_cleanup_spec_l674_d68_keeps(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/api-source/Homebrew/homebrew-core/abc123/Formula/a/testball.rb', {
		'exists':        'true'
		'file':          'true'
		'resolved_file': 'true'
	})
	package := ruby.structured_value('Formula', 'testball', {
		'found':        'true'
		'tap_git_head': 'abc123'
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l100_d8_stale_api_source(path, ruby.bool_value(false), package).bool_data)
}

// Ruby let `let(:bottle) { HOMEBREW_CACHE/"testball--0.0.1.tag.bottle.tar.gz" }` at line 691.
pub fn ruby_cleanup_spec_l691_d69_bottle(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CACHE'), 'testball--0.0.1.tag.bottle.tar.gz'))
}

// Ruby let `let(:testball) { HOMEBREW_CACHE/"testball--0.0.1" }` at line 692.
pub fn ruby_cleanup_spec_l692_d70_testball(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CACHE'), 'testball--0.0.1'))
}

// Ruby let `let(:testball_resource) { HOMEBREW_CACHE/"testball--rsrc--0.0.1.txt" }` at line 693.
pub fn ruby_cleanup_spec_l693_d71_testball_resource(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CACHE'), 'testball--rsrc--0.0.1.txt'))
}

// Ruby it `it "cleans up file if outdated" do` at line 705.
pub fn ruby_cleanup_spec_l705_d72_cleans(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/testball--0.0.1', {
		'exists': 'true'
		'file':   'true'
	})
	formula := ruby.structured_value('Formula', 'testball', {
		'name':                     'testball'
		'latest_version_installed': 'true'
		'pkg_version':              '0.0.1'
		'installed_versions':       '0.0.1'
		'eligible_versions':        '0.0.1'
		'bottle_outdated':          'true'
	})
	return cleanup_spec_bool(homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(false), formula, ruby.bool_value(true)).bool_data)
}

// Ruby it `it "cleans up file if `scrub` is true and formula not installed" do` at line 713.
pub fn ruby_cleanup_spec_l713_d73_cleans(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/testball--0.0.1', {
		'exists': 'true'
		'file':   'true'
	})
	formula := cleanup_spec_formula('testball', false, '0.0.1')
	return cleanup_spec_bool(homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(true), formula, ruby.bool_value(true)).bool_data)
}

// Ruby it `it "cleans up file if stale" do` at line 720.
pub fn ruby_cleanup_spec_l720_d74_cleans(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/testball--0.0.1', {
		'exists': 'true'
		'file':   'true'
	})
	formula := cleanup_spec_formula('testball', true, '0.1')
	return cleanup_spec_bool(homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(false), formula, ruby.bool_value(true)).bool_data)
}

// Ruby let `let(:bottle_manifest_path) { HOMEBREW_CACHE/"testball_bottle_manifest--1.0.bottle_manifest.json" }` at line 729.
pub fn ruby_cleanup_spec_l729_d75_bottle_manifest_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_CACHE'), 'testball_bottle_manifest--1.0.bottle_manifest.json'))
}

// Ruby it `it "does not remove the file when bottle resource version is nil" do` at line 738.
pub fn ruby_cleanup_spec_l738_d76_does(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/testball_bottle_manifest--1.0.json', {
		'exists': 'true'
		'file':   'true'
	})
	formula := ruby.structured_value('Formula', 'testball', {
		'name':                     'testball'
		'latest_version_installed': 'true'
		'pkg_version':              '1.0'
		'installed_versions':       '1.0'
		'eligible_versions':        '1.0'
		'bottle_version':           ''
	})
	return cleanup_spec_bool(!homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(false), formula, ruby.bool_value(true)).bool_data)
}

// Ruby it `it "removes the file when path version differs from bottle version_rebuild" do` at line 755.
pub fn ruby_cleanup_spec_l755_d77_removes(args ...ruby.Value) ruby.Value {
	path := cleanup_spec_path('/cache/testball_bottle_manifest--2.0.json', {
		'exists': 'true'
		'file':   'true'
	})
	formula := ruby.structured_value('Formula', 'testball', {
		'name':                     'testball'
		'latest_version_installed': 'true'
		'pkg_version':              '1.0'
		'installed_versions':       '1.0'
		'eligible_versions':        '1.0'
		'bottle_version':           '1.0'
		'bottle_rebuild':           '0'
	})
	return cleanup_spec_bool(homebrew.ruby_cleanup_l148_d10_stale_formula(path, ruby.bool_value(false), formula, ruby.bool_value(true)).bool_data)
}

// Ruby let `let(:foo_module) { HOMEBREW_PREFIX/"lib/python3.99/site-packages/foo" }` at line 778.
pub fn ruby_cleanup_spec_l778_d78_foo_module(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'lib', 'python3.99', 'site-packages', 'foo'))
}

// Ruby let `let(:foo_pycache) { foo_module/"__pycache__" }` at line 779.
pub fn ruby_cleanup_spec_l779_d79_foo_pycache(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l778_d78_foo_module().repr, '__pycache__'))
}

// Ruby let `let(:foo_pyc) { foo_pycache/"foo.cypthon-399.pyc" }` at line 780.
pub fn ruby_cleanup_spec_l780_d80_foo_pyc(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', os.join_path(ruby_cleanup_spec_l779_d79_foo_pycache().repr, 'foo.cypthon-399.pyc'))
}

// Ruby it `it "cleans up stray `*.pyc` files" do` at line 787.
pub fn ruby_cleanup_spec_l787_d81_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('pyc-stray')
	pyc := os.join_path(root, 'lib', 'python3.99', 'site-packages', 'foo', '__pycache__', 'foo.cypthon-399.pyc')
	cleanup_spec_touch(pyc)
	cleanup := cleanup_spec_new('/cache', false, false, none)
	homebrew.ruby_cleanup_l825_d52_cleanup_python_site_packages(cleanup, ruby.object_value('Pathname', root))
	result := !os.exists(pyc)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "retains `*.pyc` files of installed modules" do` at line 792.
pub fn ruby_cleanup_spec_l792_d82_retains(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('pyc-installed')
	module_root := os.join_path(root, 'lib', 'python3.99', 'site-packages', 'foo')
	pyc := os.join_path(module_root, '__pycache__', 'foo.cypthon-399.pyc')
	cleanup_spec_touch(pyc)
	cleanup_spec_touch(os.join_path(module_root, '__init__.py'))
	cleanup := cleanup_spec_new('/cache', false, false, none)
	homebrew.ruby_cleanup_l825_d52_cleanup_python_site_packages(cleanup, ruby.object_value('Pathname', root))
	result := os.exists(pyc)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Ruby it `it "cleans up stale `*.pyc` files in the top-level `__pycache__`" do` at line 800.
pub fn ruby_cleanup_spec_l800_d83_cleans(args ...ruby.Value) ruby.Value {
	root := cleanup_spec_reset('pyc-top')
	pyc := os.join_path(root, 'lib', 'python3.99', 'site-packages', '__pycache__', 'foo.cypthon-3.99.pyc')
	cleanup_spec_touch(pyc)
	cleanup := cleanup_spec_new('/cache', false, false, 0)
	homebrew.ruby_cleanup_l825_d52_cleanup_python_site_packages(cleanup, ruby.object_value('Pathname', root))
	result := !os.exists(pyc)
	os.rmdir_all(root) or {}
	return cleanup_spec_bool(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/support/fixtures/testball"
// 5: require "cleanup"
// 6: require "utils/autoremove"
// 7: require "cask/cache"
// 8: require "uninstall"
// 9: require "fileutils"
// 10:
// 11: RSpec.describe Homebrew::Cleanup do
// 12:   subject(:cleanup) { described_class.new }
// 13:
// 14:   let(:ds_store) { Pathname.new("#{HOMEBREW_CELLAR}/.DS_Store") }
// 15:   let(:lock_file) { Pathname.new("#{HOMEBREW_LOCKS}/foo") }
// 16:
// 17:   around do |example|
// 18:     FileUtils.touch ds_store
// 19:     FileUtils.touch lock_file
// 20:     FileUtils.mkdir_p HOMEBREW_LIBRARY/"Homebrew/vendor"
// 21:     FileUtils.touch HOMEBREW_LIBRARY/"Homebrew/vendor/portable-ruby-version"
// 22:
// 23:     example.run
// 24:   ensure
// 25:     FileUtils.rm_f ds_store
// 26:     FileUtils.rm_f lock_file
// 27:     FileUtils.rm_rf HOMEBREW_LIBRARY/"Homebrew"
// 28:   end
// 29:
// 30:   describe "::prune?" do
// 31:     subject(:path) { HOMEBREW_CACHE/"foo" }
// 32:
// 33:     before do
// 34:       path.mkpath
// 35:     end
// 36:
// 37:     it "returns true when ctime and mtime < days_default" do
// 38:       allow_any_instance_of(Pathname).to receive(:ctime).and_return((DateTime.now - 2).to_time)
// 39:       allow_any_instance_of(Pathname).to receive(:mtime).and_return((DateTime.now - 2).to_time)
// 40:       expect(described_class.prune?(path, 1)).to be true
// 41:     end
// 42:
// 43:     it "returns false when ctime and mtime >= days_default" do
// 44:       expect(described_class.prune?(path, 2)).to be false
// 45:     end
// 46:   end
// 47:
// 48:   describe "::cleanup" do
// 49:     it "removes .DS_Store and lock files" do
// 50:       cleanup.clean!
// 51:
// 52:       expect(ds_store).not_to exist
// 53:       expect(lock_file).not_to exist
// 54:     end
// 55:
// 56:     it "doesn't remove anything if `dry_run` is true" do
// 57:       described_class.new(dry_run: true).clean!
// 58:
// 59:       expect(ds_store).to exist
// 60:       expect(lock_file).to exist
// 61:     end
// 62:
// 63:     it "removes leftover `.reinstall` kegs in the Cellar" do
// 64:       reinstall_keg = HOMEBREW_CELLAR/"foo/1.0.reinstall"
// 65:       reinstall_keg.mkpath
// 66:
// 67:       cleanup.clean!
// 68:
// 69:       expect(reinstall_keg).not_to exist
// 70:     end
// 71:
// 72:     it "doesn't remove the lock file if it is locked" do
// 73:       lock_file.open(File::RDWR | File::CREAT).flock(File::LOCK_EX | File::LOCK_NB)
// 74:
// 75:       cleanup.clean!
// 76:
// 77:       expect(lock_file).to exist
// 78:     end
// 79:
// 80:     it "cleans up unreferenced downloads once, however many formulae are installed" do
// 81:       ENV["HOMEBREW_NO_AUTOREMOVE"] = "1"
// 82:       installed = ["foo", "bar", "baz"].map do |name|
// 83:         instance_double(Formula, name:, eligible_kegs_for_cleanup: [])
// 84:       end
// 85:       allow(Formula).to receive(:installed).and_return(installed)
// 86:
// 87:       expect(cleanup).to receive(:cleanup_unreferenced_downloads).once.and_call_original
// 88:
// 89:       cleanup.clean!
// 90:     end
// 91:
// 92:     it "doesn't load untrusted installed formulae while cleaning the cache" do
// 93:       cache_file = HOMEBREW_CACHE/"untrusted--1.0"
// 94:       cache_file.write "cached"
// 95:       (HOMEBREW_CELLAR/"untrusted/1.0").mkpath
// 96:
// 97:       expect(Formulary).to receive(:from_rack).with(HOMEBREW_CELLAR/"untrusted")
// 98:                                               .and_raise(Homebrew::UntrustedTapError)
// 99:
// 100:       expect { cleanup.cleanup_cache([{ path: cache_file, type: nil }]) }
// 101:         .to output(/Skipping untrusted: tap formula is not trusted/).to_stderr
// 102:       expect(cache_file).to exist
// 103:     end
// 104:
// 105:     context "when it can't remove a keg" do
// 106:       let(:formula_zero_dot_one) { Class.new(Testball) { version "0.1" }.new }
// 107:       let(:formula_zero_dot_two) { Class.new(Testball) { version "0.2" }.new }
// 108:
// 109:       before do
// 110:         [formula_zero_dot_one, formula_zero_dot_two].each do |f|
// 111:           f.brew do
// 112:             f.install
// 113:           end
// 114:
// 115:           Tab.create(f, DevelopmentTools.default_compiler, :libcxx).write
// 116:         end
// 117:
// 118:         allow_any_instance_of(Keg)
// 119:           .to receive(:uninstall)
// 120:           .and_raise(Errno::EACCES)
// 121:       end
// 122:
// 123:       it "doesn't remove any kegs" do
// 124:         cleanup.cleanup_formula formula_zero_dot_one
// 125:         expect(formula_zero_dot_one.installed_kegs.size).to eq(2)
// 126:       end
// 127:
// 128:       it "lists the unremovable kegs" do
// 129:         cleanup.cleanup_formula formula_zero_dot_two
// 130:         expect(cleanup.unremovable_kegs).to contain_exactly(formula_zero_dot_one.installed_kegs[0])
// 131:       end
// 132:     end
// 133:   end
// 134:
// 135:   describe "::autoremove" do
// 136:     let(:removable_keg) { instance_double(Keg, name: "libthai") }
// 137:     let(:removable_formula) do
// 138:       instance_double(Formula, name: "libthai", full_name: "libthai", any_installed_keg: removable_keg)
// 139:     end
// 140:
// 141:     before do
// 142:       allow(Formula).to receive(:clear_cache)
// 143:       allow(Formula).to receive(:installed).and_return([removable_formula])
// 144:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 145:       allow(Homebrew::EnvConfig).to receive(:no_cleanup_formulae).and_return([])
// 146:       allow(Utils::Autoremove).to receive(:removable_formulae).with([removable_formula],
// 147:                                                                     []).and_return([removable_formula])
// 148:       allow(InstalledDependents).to receive(:find_some_installed_dependents)
// 149:         .with([removable_keg])
// 150:         .and_return([[removable_keg], ["pango"]])
// 151:     end
// 152:
// 153:     it "does not print or uninstall formulae required by installed dependents" do
// 154:       expect(Homebrew::Uninstall).not_to receive(:uninstall_kegs)
// 155:
// 156:       expect { described_class.autoremove }.not_to output.to_stdout
// 157:     end
// 158:   end
// 159:
// 160:   describe "::prune_prefix_symlinks_and_directories" do
// 161:     let(:lib) { HOMEBREW_PREFIX/"lib" }
// 162:
// 163:     before do
// 164:       lib.mkpath
// 165:     end
// 166:
// 167:     it "keeps required empty directories" do
// 168:       cleanup.prune_prefix_symlinks_and_directories
// 169:       expect(lib).to exist
// 170:       expect(lib.children).to be_empty
// 171:     end
// 172:
// 173:     it "removes broken symlinks" do
// 174:       FileUtils.ln_s lib/"foo", lib/"bar"
// 175:       FileUtils.touch lib/"baz"
// 176:
// 177:       cleanup.prune_prefix_symlinks_and_directories
// 178:       expect(lib).to exist
// 179:       expect(lib.children).to eq([lib/"baz"])
// 180:     end
// 181:
// 182:     it "removes empty directories" do
// 183:       dir = lib/"test"
// 184:       dir.mkpath
// 185:       file = lib/"keep/file"
// 186:       file.dirname.mkpath
// 187:       FileUtils.touch file
// 188:
// 189:       cleanup.prune_prefix_symlinks_and_directories
// 190:       expect(dir).not_to exist
// 191:       expect(file).to exist
// 192:     end
// 193:
// 194:     context "when nested directories exist with only broken symlinks" do
// 195:       let(:dir) { HOMEBREW_PREFIX/"lib/foo" }
// 196:       let(:child_dir) { dir/"bar" }
// 197:       let(:grandchild_dir) { child_dir/"baz" }
// 198:       let(:broken_link) { dir/"broken" }
// 199:       let(:link_to_broken_link) { child_dir/"another-broken" }
// 200:
// 201:       before do
// 202:         grandchild_dir.mkpath
// 203:         FileUtils.ln_s dir/"missing", broken_link
// 204:         FileUtils.ln_s broken_link, link_to_broken_link
// 205:       end
// 206:
// 207:       it "removes broken symlinks and resulting empty directories" do
// 208:         cleanup.prune_prefix_symlinks_and_directories
// 209:         expect(dir).not_to exist
// 210:       end
// 211:
// 212:       it "doesn't remove anything and only prints removal steps if `dry_run` is true" do
// 213:         expect do
// 214:           described_class.new(dry_run: true).prune_prefix_symlinks_and_directories
// 215:         end.to output(<<~EOS).to_stdout
// 216:           Would remove (broken link): #{link_to_broken_link}
// 217:           Would remove (broken link): #{broken_link}
// 218:           Would remove (empty directory): #{grandchild_dir}
// 219:           Would remove (empty directory): #{child_dir}
// 220:           Would remove (empty directory): #{dir}
// 221:         EOS
// 222:
// 223:         expect(broken_link).to be_a_symlink
// 224:         expect(link_to_broken_link).to be_a_symlink
// 225:         expect(grandchild_dir).to exist
// 226:       end
// 227:     end
// 228:
// 229:     it "removes broken symlinks for uninstalled migrated Casks" do
// 230:       caskroom = Cask::Caskroom.path
// 231:       old_cask_dir = caskroom/"old"
// 232:       new_cask_dir = caskroom/"new"
// 233:       unrelated_cask_dir = caskroom/"other"
// 234:       unrelated_cask_dir.mkpath
// 235:       FileUtils.ln_s new_cask_dir, old_cask_dir
// 236:
// 237:       cleanup.prune_prefix_symlinks_and_directories
// 238:       expect(unrelated_cask_dir).to exist
// 239:       expect(old_cask_dir).not_to be_a_symlink
// 240:       expect(old_cask_dir).not_to exist
// 241:     end
// 242:   end
// 243:
// 244:   specify "::cleanup_formula" do
// 245:     f1 = Class.new(Testball) do
// 246:       version "1.0"
// 247:     end.new
// 248:
// 249:     f2 = Class.new(Testball) do
// 250:       version "0.2"
// 251:       version_scheme 1
// 252:     end.new
// 253:
// 254:     f3 = Class.new(Testball) do
// 255:       version "0.3"
// 256:       version_scheme 1
// 257:     end.new
// 258:
// 259:     f4 = Class.new(Testball) do
// 260:       version "0.1"
// 261:       version_scheme 2
// 262:     end.new
// 263:
// 264:     [f1, f2, f3, f4].each do |f|
// 265:       f.brew do
// 266:         f.install
// 267:       end
// 268:
// 269:       Tab.create(f, DevelopmentTools.default_compiler, :libcxx).write
// 270:     end
// 271:
// 272:     expect(f1).to be_latest_version_installed
// 273:     expect(f2).to be_latest_version_installed
// 274:     expect(f3).to be_latest_version_installed
// 275:     expect(f4).to be_latest_version_installed
// 276:
// 277:     cleanup.cleanup_formula f3
// 278:
// 279:     expect(f1).not_to be_latest_version_installed
// 280:     expect(f2).not_to be_latest_version_installed
// 281:     expect(f3).to be_latest_version_installed
// 282:     expect(f4).to be_latest_version_installed
// 283:   end
// 284:
// 285:   describe "#formula_cache_paths" do
// 286:     let(:cache) { mktmpdir/"cache" }
// 287:     let(:testball) { instance_double(Formula, name: "testball") }
// 288:
// 289:     before do
// 290:       cache.mkpath
// 291:     end
// 292:
// 293:     it "returns only the formula's own downloads and bottle manifests" do
// 294:       matching = [
// 295:         cache/"testball--1.0.tar.gz",
// 296:         cache/"testball--rsrc--1.0.txt",
// 297:         cache/"testball_bottle_manifest--1.0.bottle_manifest.json",
// 298:       ]
// 299:       non_matching = [
// 300:         cache/".testball--1.0.tar.gz",
// 301:         cache/"testball-foo--1.0.tar.gz",
// 302:         cache/"testball_bottle_manifest",
// 303:         cache/"testballs--1.0.tar.gz",
// 304:       ]
// 305:       (matching + non_matching).each { |path| FileUtils.touch path }
// 306:
// 307:       expect(described_class.new(cache:).formula_cache_paths(testball)).to eq(matching)
// 308:     end
// 309:
// 310:     it "reads the cache directory only once for multiple formulae" do
// 311:       cleanup = described_class.new(cache:)
// 312:
// 313:       expect(cache).to receive(:children).once.and_return([cache/"testball--1.0.tar.gz"])
// 314:
// 315:       cleanup.formula_cache_paths(testball)
// 316:       cleanup.formula_cache_paths(instance_double(Formula, name: "other"))
// 317:     end
// 318:   end
// 319:
// 320:   describe "#cleanup_cask", :cask do
// 321:     before do
// 322:       Cask::Cache.path.mkpath
// 323:     end
// 324:
// 325:     context "when given a versioned cask" do
// 326:       let(:cask) { Cask::CaskLoader.load("local-transmission") }
// 327:
// 328:       it "removes the download if it is not for the latest version" do
// 329:         download = Cask::Cache.path/"#{cask.token}--7.8.9"
// 330:
// 331:         FileUtils.touch download
// 332:
// 333:         cleanup.cleanup_cask(cask)
// 334:
// 335:         expect(download).not_to exist
// 336:       end
// 337:
// 338:       it "removes legacy URL-basename downloads if they are not for the latest version" do
// 339:         download = Cask::Cache.path/"transmission-2.61.dmg--7.8.9.dmg"
// 340:
// 341:         FileUtils.touch download
// 342:
// 343:         cleanup.cleanup_cask(cask)
// 344:
// 345:         expect(download).not_to exist
// 346:       end
// 347:
// 348:       it "does not remove downloads for the latest version" do
// 349:         download = Cask::Cache.path/"#{cask.token}--#{cask.version}"
// 350:
// 351:         FileUtils.touch download
// 352:
// 353:         cleanup.cleanup_cask(cask)
// 354:
// 355:         expect(download).to exist
// 356:       end
// 357:
// 358:       it "removes legacy URL-basename downloads when the token-named download exists" do
// 359:         legacy_download = Cask::Cache.path/"transmission-2.61.dmg--#{cask.version}.dmg"
// 360:         download = Cask::Cache.path/"#{cask.token}--#{cask.version}.dmg"
// 361:
// 362:         FileUtils.touch legacy_download
// 363:         FileUtils.touch download
// 364:
// 365:         cleanup.cleanup_cask(cask)
// 366:
// 367:         expect([legacy_download.exist?, download.exist?]).to eq([false, true])
// 368:       end
// 369:
// 370:       it "does not remove downloads when the latest version ends with a comma" do
// 371:         version = Cask::DSL::Version.new("7.2,2023.3,")
// 372:         cask = instance_double(Cask::Cask,
// 373:                                token:             "trailing-comma",
// 374:                                version:,
// 375:                                installed_version: version,
// 376:                                url:               nil,
// 377:                                caskroom_path:     Cask::Caskroom.path/"trailing-comma")
// 378:         download = Cask::Cache.path/"#{cask.token}--#{cask.version}.zip"
// 379:
// 380:         allow(Cask::CaskLoader).to receive(:load).with(cask.token, warn: false).and_return(cask)
// 381:         FileUtils.touch download
// 382:
// 383:         cleanup.cleanup_cask(cask)
// 384:
// 385:         expect(download).to exist
// 386:       end
// 387:     end
// 388:
// 389:     context "when given a `:latest` cask" do
// 390:       let(:cask) { Cask::CaskLoader.load("latest") }
// 391:
// 392:       it "does not remove the download for the latest version" do
// 393:         download = Cask::Cache.path/"#{cask.token}--#{cask.version}"
// 394:
// 395:         FileUtils.touch download
// 396:
// 397:         cleanup.cleanup_cask(cask)
// 398:
// 399:         expect(download).to exist
// 400:       end
// 401:
// 402:       it "removes the download for the latest version after 30 days" do
// 403:         download = Cask::Cache.path/"#{cask.token}--#{cask.version}"
// 404:
// 405:         allow(download).to receive_messages(ctime: (DateTime.now - 30).to_time - (60 * 60),
// 406:                                             mtime: (DateTime.now - 30).to_time - (60 * 60))
// 407:
// 408:         cleanup.cleanup_cask(cask)
// 409:
// 410:         expect(download).not_to exist
// 411:       end
// 412:
// 413:       it "removes broken legacy URL-basename downloads" do
// 414:         version = Cask::DSL::Version.new(:latest)
// 415:         cask = instance_double(Cask::Cask,
// 416:                                token:         "latest-cask",
// 417:                                version:,
// 418:                                url:           "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip",
// 419:                                caskroom_path: Cask::Caskroom.path/"latest-cask")
// 420:         download = Cask::Cache.path/"caffeine.zip--#{version}.zip"
// 421:
// 422:         FileUtils.ln_s Cask::Cache.path/"missing.zip", download
// 423:
// 424:         cleanup.cleanup_cask(cask)
// 425:
// 426:         expect(download).not_to be_a_symlink
// 427:       end
// 428:     end
// 429:   end
// 430:
// 431:   describe "::cleanup_logs" do
// 432:     let(:path) { HOMEBREW_LOGS/"delete_me" }
// 433:
// 434:     before do
// 435:       path.mkpath
// 436:     end
// 437:
// 438:     it "cleans all logs if prune is 0" do
// 439:       described_class.new(days: 0).cleanup_logs
// 440:       expect(path).not_to exist
// 441:     end
// 442:
// 443:     it "cleans up logs if older than 30 days" do
// 444:       allow_any_instance_of(Pathname).to receive(:ctime).and_return((DateTime.now - 31).to_time)
// 445:       allow_any_instance_of(Pathname).to receive(:mtime).and_return((DateTime.now - 31).to_time)
// 446:       cleanup.cleanup_logs
// 447:       expect(path).not_to exist
// 448:     end
// 449:
// 450:     it "does not clean up logs less than 30 days old" do
// 451:       allow_any_instance_of(Pathname).to receive(:ctime).and_return((DateTime.now - 15).to_time)
// 452:       allow_any_instance_of(Pathname).to receive(:mtime).and_return((DateTime.now - 15).to_time)
// 453:       cleanup.cleanup_logs
// 454:       expect(path).to exist
// 455:     end
// 456:   end
// 457:
// 458:   describe "::cleanup_cache" do
// 459:     it "removes legacy cask downloads during full cache cleanup", :cask do
// 460:       cask = Cask::CaskLoader.load("local-transmission")
// 461:       download = Cask::Cache.path/"transmission-2.61.dmg--7.8.9.dmg"
// 462:
// 463:       Cask::Cache.path.mkpath
// 464:       FileUtils.touch download
// 465:       allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 466:
// 467:       cleanup.cleanup_cache
// 468:
// 469:       expect(download).not_to exist
// 470:     end
// 471:
// 472:     it "cleans up incomplete downloads" do
// 473:       incomplete = (HOMEBREW_CACHE/"something.incomplete")
// 474:       incomplete.mkpath
// 475:
// 476:       cleanup.cleanup_cache
// 477:
// 478:       expect(incomplete).not_to exist
// 479:     end
// 480:
// 481:     it "cleans up 'cargo_cache'" do
// 482:       cargo_cache = (HOMEBREW_CACHE/"cargo_cache")
// 483:       cargo_cache.mkpath
// 484:
// 485:       cleanup.cleanup_cache
// 486:
// 487:       expect(cargo_cache).not_to exist
// 488:     end
// 489:
// 490:     it "cleans up 'go_cache'" do
// 491:       go_cache = (HOMEBREW_CACHE/"go_cache")
// 492:       go_cache.mkpath
// 493:
// 494:       cleanup.cleanup_cache
// 495:
// 496:       expect(go_cache).not_to exist
// 497:     end
// 498:
// 499:     it "cleans up 'glide_home'" do
// 500:       glide_home = (HOMEBREW_CACHE/"glide_home")
// 501:       glide_home.mkpath
// 502:
// 503:       cleanup.cleanup_cache
// 504:
// 505:       expect(glide_home).not_to exist
// 506:     end
// 507:
// 508:     it "cleans up 'java_cache'" do
// 509:       java_cache = (HOMEBREW_CACHE/"java_cache")
// 510:       java_cache.mkpath
// 511:
// 512:       cleanup.cleanup_cache
// 513:
// 514:       expect(java_cache).not_to exist
// 515:     end
// 516:
// 517:     it "cleans up 'npm_cache'" do
// 518:       npm_cache = (HOMEBREW_CACHE/"npm_cache")
// 519:       npm_cache.mkpath
// 520:
// 521:       cleanup.cleanup_cache
// 522:
// 523:       expect(npm_cache).not_to exist
// 524:     end
// 525:
// 526:     it "cleans up 'gclient_cache'" do
// 527:       gclient_cache = (HOMEBREW_CACHE/"gclient_cache")
// 528:       gclient_cache.mkpath
// 529:
// 530:       cleanup.cleanup_cache
// 531:
// 532:       expect(gclient_cache).not_to exist
// 533:     end
// 534:
// 535:     it "cleans up all files and directories" do
// 536:       git = (HOMEBREW_CACHE/"gist--git")
// 537:       gist = (HOMEBREW_CACHE/"gist")
// 538:       svn = (HOMEBREW_CACHE/"gist--svn")
// 539:
// 540:       git.mkpath
// 541:       gist.mkpath
// 542:       FileUtils.touch svn
// 543:
// 544:       described_class.new(days: 0).cleanup_cache
// 545:
// 546:       expect(git).not_to exist
// 547:       expect(gist).to exist
// 548:       expect(svn).not_to exist
// 549:     end
// 550:
// 551:     it "does not clean up directories that are not VCS checkouts" do
// 552:       git = (HOMEBREW_CACHE/"git")
// 553:       git.mkpath
// 554:
// 555:       described_class.new(days: 0).cleanup_cache
// 556:
// 557:       expect(git).to exist
// 558:     end
// 559:
// 560:     it "cleans up VCS checkout directories with modified time < prune time" do
// 561:       foo = (HOMEBREW_CACHE/"--foo")
// 562:       foo.mkpath
// 563:       allow_any_instance_of(Pathname).to receive(:ctime).and_return(Time.now - (2 * 60 * 60 * 24))
// 564:       allow_any_instance_of(Pathname).to receive(:mtime).and_return(Time.now - (2 * 60 * 60 * 24))
// 565:       described_class.new(days: 1).cleanup_cache
// 566:       expect(foo).not_to exist
// 567:     end
// 568:
// 569:     it "does not clean up VCS checkout directories with modified time >= prune time" do
// 570:       foo = (HOMEBREW_CACHE/"--foo")
// 571:       foo.mkpath
// 572:       described_class.new(days: 1).cleanup_cache
// 573:       expect(foo).to exist
// 574:     end
// 575:
// 576:     it "does not clean up internal package API files without scrub even when pruning" do
// 577:       api_package_files = [
// 578:         HOMEBREW_CACHE/"api/internal/packages.arm64_golden_gate.jws.json",
// 579:         HOMEBREW_CACHE/"api/internal/packages.arm64_tahoe.jws.json",
// 580:       ]
// 581:       api_package_files.each do |api_package_file|
// 582:         api_package_file.dirname.mkpath
// 583:         FileUtils.touch api_package_file
// 584:       end
// 585:
// 586:       described_class.new(days: 0).cleanup_cache
// 587:
// 588:       expect(api_package_files.map(&:exist?)).to eq([true, true])
// 589:     end
// 590:
// 591:     it "cleans up non-current internal package API files with scrub" do
// 592:       cache = mktmpdir/"cache"
// 593:       api_internal = cache/"api/internal"
// 594:       current_api_package_file = api_internal/Homebrew::API::Internal.cached_packages_json_file_path.basename
// 595:       stale_api_package_file = api_internal/"packages.stale.jws.json"
// 596:       api_package_files = [current_api_package_file, stale_api_package_file]
// 597:       api_jws_files = [
// 598:         cache/"api/formula.jws.json",
// 599:         cache/"api/cask.jws.json",
// 600:       ]
// 601:       api_package_files.each do |api_package_file|
// 602:         api_package_file.dirname.mkpath
// 603:         FileUtils.touch api_package_file
// 604:       end
// 605:       api_jws_files.each do |api_jws_file|
// 606:         api_jws_file.dirname.mkpath
// 607:         FileUtils.touch api_jws_file
// 608:       end
// 609:
// 610:       described_class.new(scrub: true, cache:).cleanup_cache
// 611:
// 612:       expect([*api_package_files, *api_jws_files].map(&:exist?)).to eq([true, false, true, true])
// 613:     end
// 614:
// 615:     it "cleans up non-current internal package API payload sidecars with scrub" do
// 616:       cache = mktmpdir/"cache"
// 617:       api_internal = cache/"api/internal"
// 618:       current_basename = Homebrew::API::Internal.cached_packages_json_file_path.basename
// 619:       kept_files = [
// 620:         api_internal/current_basename,
// 621:         api_internal/"#{current_basename}.payload",
// 622:         api_internal/"#{current_basename}.payload.index",
// 623:       ]
// 624:       scrubbed_files = [
// 625:         api_internal/"packages.stale.jws.json.payload",
// 626:         api_internal/"packages.stale.jws.json.payload.index",
// 627:         api_internal/"#{current_basename}.payload.tmp",
// 628:       ]
// 629:       (kept_files + scrubbed_files).each do |file|
// 630:         file.dirname.mkpath
// 631:         FileUtils.touch file
// 632:       end
// 633:
// 634:       described_class.new(scrub: true, cache:).cleanup_cache
// 635:
// 636:       expect((kept_files + scrubbed_files).map(&:exist?)).to eq([true, true, true, false, false, false])
// 637:     end
// 638:
// 639:     it "cleans up API source files and symlinks at any depth without cleaning directories" do
// 640:       root_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/README.md"
// 641:       nested_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/Formula/a/testball.rb"
// 642:       nested_symlink = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/patches/subdir/noop-a.diff"
// 643:       nested_directory = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/patches/keep"
// 644:       symlink_target = mktmpdir/"noop-a.diff"
// 645:
// 646:       root_file.dirname.mkpath
// 647:       nested_file.dirname.mkpath
// 648:       nested_symlink.dirname.mkpath
// 649:       nested_directory.mkpath
// 650:       FileUtils.touch root_file
// 651:       FileUtils.touch nested_file
// 652:       FileUtils.touch symlink_target
// 653:       FileUtils.ln_s symlink_target, nested_symlink
// 654:
// 655:       described_class.new(days: 0).cleanup_cache
// 656:
// 657:       expect([root_file.exist?, nested_file.exist?, nested_symlink.exist?, nested_directory.exist?])
// 658:         .to eq([false, false, false, true])
// 659:     end
// 660:
// 661:     it "does not remove recent API source local patches as stale" do
// 662:       patch_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/patches/noop-a.diff"
// 663:       nested_patch_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/patches/subdir/noop-b.diff"
// 664:       patch_file.dirname.mkpath
// 665:       nested_patch_file.dirname.mkpath
// 666:       FileUtils.touch patch_file
// 667:       FileUtils.touch nested_patch_file
// 668:
// 669:       cleanup.cleanup_cache
// 670:
// 671:       expect([patch_file.exist?, nested_patch_file.exist?]).to eq([true, true])
// 672:     end
// 673:
// 674:     it "keeps current API formula source paths when tap git head matches" do
// 675:       source_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/Formula/testball.rb"
// 676:       nested_source_file = HOMEBREW_CACHE/"api-source/Homebrew/homebrew-core/abc123/Formula/a/testball.rb"
// 677:       package = instance_double(Formula, tap_git_head: "abc123")
// 678:       source_file.dirname.mkpath
// 679:       nested_source_file.dirname.mkpath
// 680:       FileUtils.touch source_file
// 681:       FileUtils.touch nested_source_file
// 682:       expect(Formulary).to receive(:factory).with("Homebrew/homebrew-core/testball").twice.and_return(package)
// 683:
// 684:       cleanup.cleanup_cache([{ path: source_file, type: :api_source },
// 685:                              { path: nested_source_file, type: :api_source }])
// 686:
// 687:       expect([source_file.exist?, nested_source_file.exist?]).to eq([true, true])
// 688:     end
// 689:
// 690:     context "when cleaning old files in HOMEBREW_CACHE" do
// 691:       let(:bottle) { HOMEBREW_CACHE/"testball--0.0.1.tag.bottle.tar.gz" }
// 692:       let(:testball) { HOMEBREW_CACHE/"testball--0.0.1" }
// 693:       let(:testball_resource) { HOMEBREW_CACHE/"testball--rsrc--0.0.1.txt" }
// 694:
// 695:       before do
// 696:         FileUtils.touch bottle
// 697:         FileUtils.touch testball
// 698:         FileUtils.touch testball_resource
// 699:         (HOMEBREW_CELLAR/"testball"/"0.0.1").mkpath
// 700:         # Create the latest version of testball so the older version is eligible for cleanup.
// 701:         (HOMEBREW_CELLAR/"testball"/"0.1/bin").mkpath
// 702:         FileUtils.touch(CoreTap.instance.new_formula_path("testball"))
// 703:       end
// 704:
// 705:       it "cleans up file if outdated" do
// 706:         allow(Utils::Bottles).to receive(:file_outdated?).with(any_args).and_return(true)
// 707:         cleanup.cleanup_cache
// 708:         expect(bottle).not_to exist
// 709:         expect(testball).not_to exist
// 710:         expect(testball_resource).not_to exist
// 711:       end
// 712:
// 713:       it "cleans up file if `scrub` is true and formula not installed" do
// 714:         described_class.new(scrub: true).cleanup_cache
// 715:         expect(bottle).not_to exist
// 716:         expect(testball).not_to exist
// 717:         expect(testball_resource).not_to exist
// 718:       end
// 719:
// 720:       it "cleans up file if stale" do
// 721:         cleanup.cleanup_cache
// 722:         expect(bottle).not_to exist
// 723:         expect(testball).not_to exist
// 724:         expect(testball_resource).not_to exist
// 725:       end
// 726:     end
// 727:
// 728:     context "when the cache path is a bottle manifest file" do
// 729:       let(:bottle_manifest_path) { HOMEBREW_CACHE/"testball_bottle_manifest--1.0.bottle_manifest.json" }
// 730:
// 731:       before do
// 732:         HOMEBREW_CACHE.mkpath
// 733:         FileUtils.touch bottle_manifest_path
// 734:         (HOMEBREW_CELLAR/"testball"/"0.1/bin").mkpath
// 735:         FileUtils.touch(CoreTap.instance.new_formula_path("testball"))
// 736:       end
// 737:
// 738:       it "does not remove the file when bottle resource version is nil" do
// 739:         allow(Formulary).to receive(:from_rack).with(HOMEBREW_CELLAR/"testball_bottle_manifest").and_return(nil)
// 740:         allow(Formulary).to receive(:from_rack).and_call_original
// 741:         allow(Formulary).to receive(:from_rack).with(HOMEBREW_CELLAR/"testball").and_wrap_original do |m, *args|
// 742:           formula = m.call(*args)
// 743:           if formula
// 744:             bottle_nil_version = instance_double(Bottle,
// 745:                                                  resource: instance_double(Resource, version: nil),
// 746:                                                  rebuild:  0)
// 747:             allow(formula).to receive(:bottle).and_return(bottle_nil_version)
// 748:           end
// 749:           formula
// 750:         end
// 751:         cleanup.cleanup_cache([{ path: bottle_manifest_path, type: nil }])
// 752:         expect(bottle_manifest_path).to exist
// 753:       end
// 754:
// 755:       it "removes the file when path version differs from bottle version_rebuild" do
// 756:         pathname_mismatch = (HOMEBREW_CACHE/"testball_bottle_manifest--2.0.bottle_manifest.json")
// 757:         FileUtils.touch pathname_mismatch
// 758:         allow(Formulary).to receive(:from_rack).with(HOMEBREW_CELLAR/"testball_bottle_manifest").and_return(nil)
// 759:         allow(Formulary).to receive(:from_rack).and_call_original
// 760:         allow(Formulary).to receive(:from_rack).with(HOMEBREW_CELLAR/"testball").and_wrap_original do |m, *args|
// 761:           formula = m.call(*args)
// 762:           if formula
// 763:             bottle_double = instance_double(Bottle,
// 764:                                             resource: instance_double(Resource, version: Version.new("1.0")),
// 765:                                             rebuild:  0)
// 766:             allow(formula).to receive(:bottle).and_return(bottle_double)
// 767:           end
// 768:           formula
// 769:         end
// 770:         cleanup.cleanup_cache([{ path: pathname_mismatch, type: nil }])
// 771:         expect(pathname_mismatch).not_to exist
// 772:       end
// 773:     end
// 774:   end
// 775:
// 776:   describe "::cleanup_python_site_packages" do
// 777:     context "when cleaning up Python modules" do
// 778:       let(:foo_module) { HOMEBREW_PREFIX/"lib/python3.99/site-packages/foo" }
// 779:       let(:foo_pycache) { foo_module/"__pycache__" }
// 780:       let(:foo_pyc) { foo_pycache/"foo.cypthon-399.pyc" }
// 781:
// 782:       before do
// 783:         foo_pycache.mkpath
// 784:         FileUtils.touch foo_pyc
// 785:       end
// 786:
// 787:       it "cleans up stray `*.pyc` files" do
// 788:         cleanup.cleanup_python_site_packages
// 789:         expect(foo_pyc).not_to exist
// 790:       end
// 791:
// 792:       it "retains `*.pyc` files of installed modules" do
// 793:         FileUtils.touch foo_module/"__init__.py"
// 794:
// 795:         cleanup.cleanup_python_site_packages
// 796:         expect(foo_pyc).to exist
// 797:       end
// 798:     end
// 799:
// 800:     it "cleans up stale `*.pyc` files in the top-level `__pycache__`" do
// 801:       pycache = HOMEBREW_PREFIX/"lib/python3.99/site-packages/__pycache__"
// 802:       foo_pyc = pycache/"foo.cypthon-3.99.pyc"
// 803:       pycache.mkpath
// 804:       FileUtils.touch foo_pyc
// 805:
// 806:       allow_any_instance_of(Pathname).to receive(:ctime).and_return(Time.now - (2 * 60 * 60 * 24))
// 807:       allow_any_instance_of(Pathname).to receive(:mtime).and_return(Time.now - (2 * 60 * 60 * 24))
// 808:       described_class.new(days: 1).cleanup_python_site_packages
// 809:       expect(foo_pyc).not_to exist
// 810:     end
// 811:   end
// 812: end
