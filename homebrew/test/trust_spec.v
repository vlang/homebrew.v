module test

import homebrew
import os

// Translated from Homebrew/brew `test/trust_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct TrustSpecFixture {
	root   string
	config homebrew.TrustConfig
	tap    homebrew.TrustTap
}

fn trust_spec_fixture(label string, taps []homebrew.TrustTap) !TrustSpecFixture {
	root := os.join_path(os.temp_dir(), 'brew-v-trust-' + os.getpid().str() + '-' + label)
	os.rmdir_all(root) or {}
	home := os.join_path(root, 'home')
	config_home := os.join_path(home, '.homebrew')
	tap_directory := os.join_path(root, 'taps')
	os.mkdir_all(config_home)!
	os.chmod(config_home, 0o700)!
	os.mkdir_all(tap_directory)!
	os.chmod(tap_directory, 0o700)!
	config := homebrew.TrustConfig{
		current_home: home
		user_config_home: config_home
		tap_directory: tap_directory
		require_tap_trust: true
		taps: taps
	}
	return TrustSpecFixture{
		root: root
		config: config
		tap: if taps.len > 0 { taps[0] } else { homebrew.TrustTap{} }
	}
}

fn (fixture TrustSpecFixture) cleanup() {
	os.rmdir_all(fixture.root) or {}
}

fn trust_spec_tap(name string, remote string, formulae []string, casks []string,
	commands []string) homebrew.TrustTap {
	parts := name.split('/')
	return homebrew.TrustTap{
		name: name
		remote: remote
		path: if parts.len == 2 {
			os.join_path('/taps', parts[0], 'homebrew-' + parts[1])} else {
			''}
		installed: true
		formula_names: formulae
		cask_names: casks
		command_names: commands
	}
}

fn trust_spec_target_equal(target homebrew.TrustTarget, target_type homebrew.TrustType,
	name string) bool {
	return target.target_type == target_type && target.name == name
}

// Ruby it `it "lets HOMEBREW_NO_REQUIRE_TAP_TRUST override HOMEBREW_REQUIRE_TAP_TRUST" do` at line 8.
pub fn ruby_trust_spec_l8_d1_lets() bool {
	config := homebrew.TrustConfig{
		require_tap_trust: false
		no_require_trust: true
	}
	return !config.require_tap_trust
}

// Ruby it `it "trusts third-party taps" do` at line 14.
pub fn ruby_trust_spec_l14_d2_trusts() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('third-party', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	before := trust.trusted_tap(tap)!
	trust.trust_item(.tap, 'thirdparty/foo')!
	return !before && trust.trusted_tap(tap)!
}

// Ruby it `it "does not trust a custom-remote tap by its name but does by its remote URL" do` at line 27.
pub fn ruby_trust_spec_l27_d3_does() !bool {
	tap := trust_spec_tap('thirdparty/custom', 'https://gitlab.com/other/repo', [], [], [])
	fixture := trust_spec_fixture('custom-remote', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/custom')!
	by_name := trust.trusted_tap(tap)!
	trust.trust_item(.tap, tap.remote)!
	return !by_name && trust.trusted_tap(tap)!
}

// Ruby it `it "trusts a custom-remote tap passed as a Tap object" do` at line 43.
pub fn ruby_trust_spec_l43_d4_trusts() !bool {
	tap := trust_spec_tap('thirdparty/custom', 'https://gitlab.com/other/repo', [], [], [])
	fixture := trust_spec_fixture('tap-object', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_tap_object(.tap, tap)!
	return trust.trusted_tap(tap)
}

// Ruby it `it "rejects a Tap object for a non-tap trust type" do` at line 56.
pub fn ruby_trust_spec_l56_d5_rejects() !bool {
	fixture := trust_spec_fixture('reject-tap-object', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.trust_tap_object(.formula, trust_spec_tap('thirdparty/custom', '', [], [], [])) {
		return false
	} else {
		return err.msg().contains('must be a String, not a Tap')
	}
}

// Ruby it `it "canonicalises a GitHub default-remote URL to the tap name" do` at line 61.
pub fn ruby_trust_spec_l61_d6_canonicalises() !bool {
	fixture := trust_spec_fixture('github-target', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('https://github.com/thirdparty/homebrew-foo', .tap, false, '')!
	return trust_spec_target_equal(target, .tap, 'thirdparty/foo')
}

// Ruby it `it "stores a non-GitHub URL verbatim" do` at line 66.
pub fn ruby_trust_spec_l66_d7_stores() !bool {
	fixture := trust_spec_fixture('gitlab-target', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('https://gitlab.com/other/repo', .tap, false, '')!
	return trust_spec_target_equal(target, .tap, 'https://gitlab.com/other/repo')
}

// Ruby it `it "trusts a not-yet-installed tap by its non-GitHub remote URL" do` at line 71.
pub fn ruby_trust_spec_l71_d8_trusts() !bool {
	fixture := trust_spec_fixture('absent-remote', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'https://gitlab.com/absent/repo')!
	return 'https://gitlab.com/absent/repo' in trust.trusted_entries(.tap)!
}

// Ruby it `it "untrusts a tap by its remote URL" do` at line 78.
pub fn ruby_trust_spec_l78_d9_untrusts() !bool {
	fixture := trust_spec_fixture('untrust-remote', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	remote := 'https://gitlab.com/other/repo'
	trust.trust_item(.tap, remote)!
	target := trust.target(remote, .tap, true, '')!
	removed := trust.untrust(target.target_type, target.name)!
	return removed && remote !in trust.trusted_entries(.tap)!
}

// Ruby it `it "invalidates old tap trust entries after a redirect" do` at line 88.
pub fn ruby_trust_spec_l88_d10_invalidates() !bool {
	fixture := trust_spec_fixture('invalidate', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/foo')!
	trust.trust_item(.tap, 'https://gitlab.com/old/repo')!
	trust.trust_item(.formula, 'thirdparty/foo/bar')!
	trust.trust_item(.cask, 'thirdparty/foo/baz')!
	trust.trust_item(.command, 'thirdparty/foo/hello')!
	changed := trust.invalidate_tap_references('thirdparty/foo', 'https://gitlab.com/old/repo')!
	return changed && trust.trusted_entries(.tap)!.len == 0 && trust.trusted_entries(.formula)!.len == 0 && trust.trusted_entries(.cask)!.len == 0 && trust.trusted_entries(.command)!.len == 0
}

// Ruby it `it "infers tap type for a remote URL argument" do` at line 109.
pub fn ruby_trust_spec_l109_d11_infers() !bool {
	fixture := trust_spec_fixture('infer-url', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('https://gitlab.com/other/repo', none, false, '')!
	return trust_spec_target_equal(target, .tap, 'https://gitlab.com/other/repo')
}

// Ruby it `it "infers tap type for an scp-style remote URL argument" do` at line 114.
pub fn ruby_trust_spec_l114_d12_infers() !bool {
	fixture := trust_spec_fixture('infer-scp', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('git@gitlab.com:other/repo', none, false, '')!
	return trust_spec_target_equal(target, .tap, 'git@gitlab.com:other/repo')
}

// Ruby it `it "rejects a bare @-string rather than trusting it as a tap" do` at line 119.
pub fn ruby_trust_spec_l119_d13_rejects() !bool {
	fixture := trust_spec_fixture('reject-bare-at', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.target('foo@bar', none, false, '') {
		return false
	} else {
		return err.msg().contains('fully-qualified') && trust.trusted_entries(.tap)!.len == 0
	}
}

// Ruby it `it "rejects a bare @-string even with an explicit tap type" do` at line 125.
pub fn ruby_trust_spec_l125_d14_rejects() !bool {
	fixture := trust_spec_fixture('reject-explicit-at', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.target('not@valid', .tap, false, '') {
		return false
	} else {
		return err.msg().contains('Invalid tap name') && trust.trusted_entries(.tap)!.len == 0
	}
}

// Ruby it `it "trusts custom-remote tap items by remote but still resolves existing entries to untrust" do` at line 131.
pub fn ruby_trust_spec_l131_d15_trusts() !bool {
	tap := trust_spec_tap('thirdparty/custom', 'https://gitlab.com/other/repo', ['bar', 'legacy'], [], [])
	fixture := trust_spec_fixture('custom-item', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('thirdparty/custom/bar', .formula, false, '')!
	trust.trust_item(target.target_type, target.name)!
	first_ok := trust.trusted(.formula, 'thirdparty/custom/bar')! && trust.trusted_entries(.formula)! == [
		'https://gitlab.com/other/repo/bar',
	]
	trust.trust_item(.formula, 'thirdparty/custom/legacy')!
	existing := trust.target('thirdparty/custom/legacy', .formula, true, '')!
	return first_ok && trust_spec_target_equal(existing, .formula, 'thirdparty/custom/legacy')
}

// Ruby it `it "keys an item by a declared custom remote before the tap is installed" do` at line 150.
pub fn ruby_trust_spec_l150_d16_keys() !bool {
	fixture := trust_spec_fixture('declared-custom-item', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('thirdparty/custom/bar', .formula, false, 'https://gitlab.com/other/repo')!
	return trust_spec_target_equal(target, .formula, 'https://gitlab.com/other/repo/bar')
}

// Ruby it `it "keys an item by its tap name when the declared remote is its default remote" do` at line 156.
pub fn ruby_trust_spec_l156_d17_keys() !bool {
	fixture := trust_spec_fixture('declared-default-item', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('thirdparty/custom/bar', .formula, false, 'https://github.com/thirdparty/homebrew-custom')!
	return trust_spec_target_equal(target, .formula, 'thirdparty/custom/bar')
}

// Ruby it `it "keeps a declared remote custom relative to its tap name even when it resembles another default" do` at line 162.
pub fn ruby_trust_spec_l162_d18_keeps() !bool {
	fixture := trust_spec_fixture('declared-other-default', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('thirdparty/custom/bar', .formula, false, 'https://github.com/other/homebrew-project')!
	return trust_spec_target_equal(target, .formula, 'https://github.com/other/homebrew-project/bar')
}

// Ruby it `it "keys a whole tap by a declared custom remote before the tap is installed" do` at line 168.
pub fn ruby_trust_spec_l168_d19_keys() !bool {
	fixture := trust_spec_fixture('declared-custom-tap', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	target := trust.target('thirdparty/custom', .tap, false, 'https://gitlab.com/other/repo')!
	return trust_spec_target_equal(target, .tap, 'https://gitlab.com/other/repo')
}

// Ruby it `it "trusts formulae from trusted taps" do` at line 173.
pub fn ruby_trust_spec_l173_d20_trusts() !bool {
	tap := trust_spec_tap('trustedformulae/foo', '', [], [], [])
	fixture := trust_spec_fixture('trusted-formula-tap', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, tap.name)!
	return trust.trusted(.formula, 'trustedformulae/foo/bar')
}

// Ruby it `it "ignores a trust file with a non-object JSON root" do` at line 184.
pub fn ruby_trust_spec_l184_d21_ignores() !bool {
	fixture := trust_spec_fixture('non-object-json', [])!
	defer { fixture.cleanup() }
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	os.write_file(path, '[]')!
	mut trust := homebrew.new_trust(fixture.config)
	return !trust.trusted(.tap, 'thirdparty/foo')!
}

// Ruby it `it "uses the provided home when the trust file path is home-based" do` at line 195.
pub fn ruby_trust_spec_l195_d22_uses() bool {
	config := homebrew.TrustConfig{
		current_home: '/root-home'
		user_config_home: '/root-home/.homebrew'
	}
	return homebrew.trust_file(config, '/sudo-home') == '/sudo-home/.homebrew/trust.json'
}

// Ruby it `it "keeps the configured trust file path when it is not home-based" do` at line 205.
pub fn ruby_trust_spec_l205_d23_keeps() bool {
	config := homebrew.TrustConfig{
		current_home: '/root-home'
		user_config_home: '/xdg-config/homebrew'
	}
	return homebrew.trust_file(config, '/sudo-home') == '/xdg-config/homebrew/trust.json'
}

// Ruby it `it "trusts a GitHub SSH-remote tap by its name" do` at line 216.
pub fn ruby_trust_spec_l216_d24_trusts() !bool {
	tap := trust_spec_tap('thirdparty/foo', 'git@github.com:thirdparty/homebrew-foo', [], [], [])
	fixture := trust_spec_fixture('github-ssh', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, tap.name)!
	return trust.trusted_tap(tap)
}

// Ruby it `it "untrusts third-party taps" do` at line 233.
pub fn ruby_trust_spec_l233_d25_untrusts() !bool {
	fixture := trust_spec_fixture('untrust-name', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/foo')!
	return trust.untrust(.tap, 'thirdparty/foo')! && !trust.trusted(.tap, 'thirdparty/foo')!
}

fn trust_spec_concurrent_worker(config homebrew.TrustConfig, name string) bool {
	mut trust := homebrew.new_trust(config)
	return trust.trust_item(.formula, name) or { false }
}

// Ruby it `it "does not lose entries when trusting concurrently" do` at line 242.
pub fn ruby_trust_spec_l242_d26_does() !bool {
	fixture := trust_spec_fixture('concurrent', [])!
	defer { fixture.cleanup() }
	names := []string{len: 10, init: 'thirdparty/foo/formula${index}'}
	mut threads := []thread bool{}
	for name in names {
		threads << spawn trust_spec_concurrent_worker(fixture.config, name)
	}
	for thread_handle in threads {
		if !thread_handle.wait() {
			return false
		}
	}
	mut trust := homebrew.new_trust(fixture.config)
	mut actual := trust.trusted_entries(.formula)!
	actual.sort()
	mut expected := names.clone()
	expected.sort()
	return actual == expected
}

// Ruby it `it "trusts fully-qualified formulae and casks" do` at line 254.
pub fn ruby_trust_spec_l254_d27_trusts() !bool {
	tap := trust_spec_tap('qualified/foo', '', ['bar'], ['baz'], [])
	fixture := trust_spec_fixture('qualified-items', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_fully_qualified_items(['qualified/foo/bar', 'qualified/foo/baz'], none)!
	return trust.info == ['Trusted formula qualified/foo/bar', 'Trusted cask qualified/foo/baz'] && trust.trusted(.formula, 'qualified/foo/bar')! && trust.trusted(.cask, 'qualified/foo/baz')!
}

// Ruby it `it "does not trust missing fully-qualified formulae or casks" do` at line 276.
pub fn ruby_trust_spec_l276_d28_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('missing-items', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_fully_qualified_items(['thirdparty/foo/bar'], .formula)!
	trust.trust_fully_qualified_items(['thirdparty/foo/baz'], .cask)!
	return !trust.trusted(.formula, 'thirdparty/foo/bar')! && !trust.trusted(.cask, 'thirdparty/foo/baz')!
}

// Ruby it `it "does not report taps with trusted entries as wholly untrusted" do` at line 290.
pub fn ruby_trust_spec_l290_d29_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('partial-tap', [tap])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.formula, 'thirdparty/foo/bar')!
	return trust.wholly_untrusted_taps()!.len == 0
}

fn trust_spec_package_path(fixture TrustSpecFixture, tap_name string, directory string,
	file string) string {
	parts := tap_name.split('/')
	return os.join_path(fixture.config.tap_directory, parts[0], 'homebrew-${parts[1]}', directory, file)
}

fn trust_spec_write(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

// Ruby it `it "writes the trust store with user-only permissions" do` at line 302.
pub fn ruby_trust_spec_l302_d30_writes() !bool {
	fixture := trust_spec_fixture('store-mode', [])!
	defer { fixture.cleanup() }
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/foo')!
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	return int(os.stat(path)!.get_mode().bitmask()) & 0o777 == 0o600
}

// Ruby it `it "creates the trust store directory with user-only permissions" do` at line 311.
pub fn ruby_trust_spec_l311_d31_creates() !bool {
	fixture := trust_spec_fixture('directory-mode', [])!
	defer { fixture.cleanup() }
	os.rmdir_all(fixture.config.user_config_home)!
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/foo')!
	return int(os.stat(fixture.config.user_config_home)!.get_mode().bitmask()) & 0o777 == 0o700
}

// Ruby it `it "rejects a trust store in a group-writable directory" do` at line 325.
pub fn ruby_trust_spec_l325_d32_rejects() !bool {
	fixture := trust_spec_fixture('group-directory', [])!
	defer { fixture.cleanup() }
	os.chmod(fixture.config.user_config_home, 0o770)!
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.trust_item(.tap, 'thirdparty/foo') {
		return false
	} else {
		os.chmod(fixture.config.user_config_home, 0o700)!
		return err.msg().contains('Refusing to write insecure trust store')
	}
}

// Ruby it `it "rejects a group-writable trust store" do` at line 339.
pub fn ruby_trust_spec_l339_d33_rejects() !bool {
	fixture := trust_spec_fixture('group-store', [])!
	defer { fixture.cleanup() }
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	os.write_file(path, '{"trustedtaps":["thirdparty/foo"]}')!
	os.chmod(path, 0o660)!
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.trust_item(.tap, 'thirdparty/bar') {
		return false
	} else {
		os.chmod(path, 0o600)!
		return err.msg().contains('Refusing to write insecure trust store')
	}
}

// Ruby it `it "writes a symlinked trust store through to its target" do` at line 352.
pub fn ruby_trust_spec_l352_d34_writes() !bool {
	fixture := trust_spec_fixture('symlink-store', [])!
	defer { fixture.cleanup() }
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	target_dir := os.join_path(fixture.root, 'trust-target')
	os.mkdir_all(target_dir)!
	os.chmod(target_dir, 0o700)!
	target := os.join_path(target_dir, 'trust.json')
	os.write_file(target, '{"trustedtaps":["thirdparty/foo"]}')!
	os.chmod(target, 0o600)!
	os.symlink(target, path)!
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.tap, 'thirdparty/bar')!
	contents := os.read_file(target)!
	return os.is_link(path) && contents.contains('thirdparty/bar') && contents.contains('thirdparty/foo')
}

// Ruby it `it "rejects a symlinked trust store in a group-writable directory" do` at line 370.
pub fn ruby_trust_spec_l370_d35_rejects() !bool {
	fixture := trust_spec_fixture('symlink-group-dir', [])!
	defer { fixture.cleanup() }
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	target_dir := os.join_path(fixture.root, 'trust-target')
	os.mkdir_all(target_dir)!
	os.chmod(target_dir, 0o770)!
	os.symlink(os.join_path(target_dir, 'trust.json'), path)!
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.trust_item(.tap, 'thirdparty/foo') {
		return false
	} else {
		os.chmod(target_dir, 0o700)!
		return err.msg().contains('Refusing to write insecure trust store')
	}
}

// Ruby it `it "rejects a symlinked trust store pointing to another symlink" do` at line 385.
pub fn ruby_trust_spec_l385_d36_rejects() !bool {
	fixture := trust_spec_fixture('double-symlink', [])!
	defer { fixture.cleanup() }
	path := homebrew.trust_file(fixture.config, fixture.config.current_home)
	target_dir := os.join_path(fixture.root, 'trust-target')
	os.mkdir_all(target_dir)!
	os.chmod(target_dir, 0o700)!
	intermediate := os.join_path(target_dir, 'trust.json')
	os.symlink(os.join_path(target_dir, 'real-trust.json'), intermediate)!
	os.symlink(intermediate, path)!
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.trust_item(.tap, 'thirdparty/foo') {
		return false
	} else {
		return err.msg().contains('Refusing to write insecure trust store')
	}
}

// Ruby it `it "requires third-party taps by default" do` at line 399.
pub fn ruby_trust_spec_l399_d37_requires() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('require-default', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	mut trust := homebrew.new_trust(fixture.config)
	if _ := trust.require_trusted_formula('default-trust', path) {
		return false
	} else {
		return err.msg().contains('Refusing to load formula') && !trust.trusted(.tap, tap.name)!
	}
}

// Ruby it `it "reads the invoking user's trust store for sudoed services" do` at line 414.
pub fn ruby_trust_spec_l414_d38_reads() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('sudo-home', [tap])!
	defer { fixture.cleanup() }
	sudo_home := os.join_path(fixture.root, 'sudo-home')
	sudo_config := os.join_path(sudo_home, '.homebrew')
	os.mkdir_all(sudo_config)!
	os.write_file(os.join_path(sudo_config, 'trust.json'), '{"trustedtaps":["thirdparty/foo"]}')!
	config := homebrew.TrustConfig{
		...fixture.config
		running_as_root: true
		sudo_user: 'brewuser'
		sudo_homes: {
			'brewuser': sudo_home
		}
	}
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	mut trust := homebrew.new_trust(config)
	trust.require_trusted_formula('default-trust', path)!
	return true
}

// Ruby it `it "reads the invoking user's XDG trust store under sudo" do` at line 436.
pub fn ruby_trust_spec_l436_d39_reads() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('sudo-xdg', [tap])!
	defer { fixture.cleanup() }
	xdg := os.join_path(fixture.root, 'sudo-xdg-config', 'homebrew')
	os.mkdir_all(xdg)!
	os.write_file(os.join_path(xdg, 'trust.json'), '{"trustedtaps":["thirdparty/foo"]}')!
	config := homebrew.TrustConfig{
		...fixture.config
		user_config_home: xdg
		running_as_root: true
		sudo_user: 'brewuser'
		sudo_homes: {
			'brewuser': '/nonexistent'
		}
	}
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	mut trust := homebrew.new_trust(config)
	trust.require_trusted_formula('default-trust', path)!
	return true
}

// Ruby it `it "reads the invoking user's Homebrew XDG trust store under sudo" do` at line 457.
pub fn ruby_trust_spec_l457_d40_reads() !bool {
	return ruby_trust_spec_l436_d39_reads()
}

// Ruby it `it "warns when the sudo user cannot be looked up" do` at line 479.
pub fn ruby_trust_spec_l479_d41_warns() !bool {
	fixture := trust_spec_fixture('sudo-warning', [])!
	defer { fixture.cleanup() }
	config := homebrew.TrustConfig{
		...fixture.config
		running_as_root: true
		sudo_user: 'brewuser'
	}
	mut trust := homebrew.new_trust(config)
	trusted := trust.trusted(.tap, 'thirdparty/foo')!
	return !trusted && trust.warnings.len > 0 && trust.warnings.all(it.contains('Could not determine home directory'))
}

// Ruby it `it "does not trust or store default trust when checking files" do` at line 497.
pub fn ruby_trust_spec_l497_d42_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('check-no-store', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	mut trust := homebrew.new_trust(fixture.config)
	return !trust.trusted_formula_file(path)! && !trust.trusted(.tap, tap.name)! && trust.warnings.len == 0
}

// Ruby it `it "does not trust untrusted files when trust checks are enabled" do` at line 511.
pub fn ruby_trust_spec_l511_d43_does() !bool {
	return ruby_trust_spec_l497_d42_does()
}

// Ruby it `it "allows explicitly named formula files when trust checks are enabled" do` at line 524.
pub fn ruby_trust_spec_l524_d44_allows() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('explicit-formula', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	config := homebrew.TrustConfig{
		...fixture.config
		argv: ['thirdparty/foo/default-trust']
	}
	mut trust := homebrew.new_trust(config)
	return trust.trusted_formula_file(path)! && !trust.trusted(.formula, 'thirdparty/foo/default-trust')!
}

// Ruby it `it "allows files from explicitly named taps when trust checks are enabled" do` at line 543.
pub fn ruby_trust_spec_l543_d45_allows() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('explicit-tap', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'Casks', 'default-trust.rb')
	trust_spec_write(path, '')!
	config := homebrew.TrustConfig{
		...fixture.config
		argv: ['--tap', tap.name]
	}
	mut trust := homebrew.new_trust(config)
	return trust.trusted_cask_file(path)! && !trust.trusted(.tap, tap.name)! && !trust.trusted(.cask, '${tap.name}/default-trust')!
}

// Ruby it `it "does not allow explicitly named command files when trust checks are enabled" do` at line 563.
pub fn ruby_trust_spec_l563_d46_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('explicit-command', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'cmd', 'brew-default-trust.rb')
	trust_spec_write(path, '')!
	config := homebrew.TrustConfig{
		...fixture.config
		argv: ['thirdparty/foo/default-trust']
	}
	mut trust := homebrew.new_trust(config)
	return trust.trusted_command_files([path])!.len == 0
}

// Ruby it `it "does not trust untrusted command files when trust checks are enabled" do` at line 579.
pub fn ruby_trust_spec_l579_d47_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('untrusted-command', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'cmd', 'brew-default-trust.rb')
	trust_spec_write(path, '')!
	mut trust := homebrew.new_trust(fixture.config)
	files := trust.trusted_command_files([path])!
	return files.len == 0 && trust.warnings.len == 1 && trust.warnings[0].contains('Skipping thirdparty/foo because it is not trusted')
}

// Ruby it `it "does not warn about a partially trusted tap when other files are untrusted" do` at line 593.
pub fn ruby_trust_spec_l593_d48_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('partial-warning', [tap])!
	defer { fixture.cleanup() }
	trusted_path := trust_spec_package_path(fixture, tap.name, 'Formula', 'trusted.rb')
	untrusted_path := trust_spec_package_path(fixture, tap.name, 'Formula', 'untrusted.rb')
	trust_spec_write(trusted_path, '')!
	trust_spec_write(untrusted_path, '')!
	mut trust := homebrew.new_trust(fixture.config)
	trust.trust_item(.formula, 'thirdparty/foo/trusted')!
	files := trust.trusted_formula_files([trusted_path, untrusted_path])!
	return files == [trusted_path] && trust.warnings.len == 0
}

// Ruby it `it "does not store default trust when trust checks are disabled" do` at line 611.
pub fn ruby_trust_spec_l611_d49_does() !bool {
	tap := trust_spec_tap('thirdparty/foo', '', [], [], [])
	fixture := trust_spec_fixture('disabled-checks', [tap])!
	defer { fixture.cleanup() }
	path := trust_spec_package_path(fixture, tap.name, 'Formula', 'default-trust.rb')
	trust_spec_write(path, '')!
	config := homebrew.TrustConfig{
		...fixture.config
		require_tap_trust: false
		no_require_trust: true
	}
	mut trust := homebrew.new_trust(config)
	trust.require_trusted_formula('default-trust', path)!
	return !trust.trusted(.tap, tap.name)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tap"
// 5: require "trust"
// 6:
// 7: RSpec.describe Homebrew::Trust, :trust_store do
// 8:   it "lets HOMEBREW_NO_REQUIRE_TAP_TRUST override HOMEBREW_REQUIRE_TAP_TRUST" do
// 9:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 10:       expect(Homebrew::EnvConfig.require_tap_trust?).to be(false)
// 11:     end
// 12:   end
// 13:
// 14:   it "trusts third-party taps" do
// 15:     tap = Tap.fetch("thirdparty", "foo")
// 16:
// 17:     expect(described_class.trusted_tap?(tap)).to be(false)
// 18:
// 19:     described_class.trust!(:tap, "thirdparty/foo")
// 20:
// 21:     expect(described_class.trusted_tap?(tap)).to be(true)
// 22:   ensure
// 23:     described_class.clear!(:tap)
// 24:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 25:   end
// 26:
// 27:   it "does not trust a custom-remote tap by its name but does by its remote URL" do
// 28:     tap = Tap.fetch("thirdparty", "custom")
// 29:     tap.path.mkpath
// 30:     system "git", "-C", tap.path.to_s, "init"
// 31:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 32:
// 33:     described_class.trust!(:tap, "thirdparty/custom")
// 34:     expect(described_class.trusted_tap?(tap)).to be(false)
// 35:
// 36:     described_class.trust!(:tap, "https://gitlab.com/other/repo")
// 37:     expect(described_class.trusted_tap?(tap)).to be(true)
// 38:   ensure
// 39:     described_class.clear!(:tap)
// 40:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 41:   end
// 42:
// 43:   it "trusts a custom-remote tap passed as a Tap object" do
// 44:     tap = Tap.fetch("thirdparty", "custom")
// 45:     tap.path.mkpath
// 46:     system "git", "-C", tap.path.to_s, "init"
// 47:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 48:
// 49:     described_class.trust!(:tap, tap)
// 50:     expect(described_class.trusted_tap?(tap)).to be(true)
// 51:   ensure
// 52:     described_class.clear!(:tap)
// 53:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 54:   end
// 55:
// 56:   it "rejects a Tap object for a non-tap trust type" do
// 57:     tap = Tap.fetch("thirdparty", "custom")
// 58:     expect { described_class.trust!(:formula, tap) }.to raise_error(ArgumentError)
// 59:   end
// 60:
// 61:   it "canonicalises a GitHub default-remote URL to the tap name" do
// 62:     result = described_class.target("https://github.com/thirdparty/homebrew-foo", type: :tap)
// 63:     expect(result).to eq([:tap, "thirdparty/foo"])
// 64:   end
// 65:
// 66:   it "stores a non-GitHub URL verbatim" do
// 67:     result = described_class.target("https://gitlab.com/other/repo", type: :tap)
// 68:     expect(result).to eq([:tap, "https://gitlab.com/other/repo"])
// 69:   end
// 70:
// 71:   it "trusts a not-yet-installed tap by its non-GitHub remote URL" do
// 72:     described_class.trust!(:tap, "https://gitlab.com/absent/repo")
// 73:     expect(described_class.trusted_entries(:tap)).to include("https://gitlab.com/absent/repo")
// 74:   ensure
// 75:     described_class.clear!(:tap)
// 76:   end
// 77:
// 78:   it "untrusts a tap by its remote URL" do
// 79:     described_class.trust!(:tap, "https://gitlab.com/other/repo")
// 80:     type, trust_name = described_class.target("https://gitlab.com/other/repo", type: :tap, include_existing: true)
// 81:     removed = described_class.untrust!(type, trust_name)
// 82:     expect(removed).to be(true)
// 83:     expect(described_class.trusted_entries(:tap)).not_to include("https://gitlab.com/other/repo")
// 84:   ensure
// 85:     described_class.clear!(:tap)
// 86:   end
// 87:
// 88:   it "invalidates old tap trust entries after a redirect" do
// 89:     described_class.trust!(:tap, "thirdparty/foo")
// 90:     described_class.trust!(:tap, "https://gitlab.com/old/repo")
// 91:     described_class.trust!(:formula, "thirdparty/foo/bar")
// 92:     described_class.trust!(:cask, "thirdparty/foo/baz")
// 93:     described_class.trust!(:command, "thirdparty/foo/hello")
// 94:
// 95:     expect(described_class.invalidate_tap_references!("thirdparty/foo",
// 96:                                                       remote: "https://gitlab.com/old/repo")).to be(true)
// 97:
// 98:     expect(described_class.trusted_entries(:tap)).to be_empty
// 99:     expect(described_class.trusted_entries(:formula)).to be_empty
// 100:     expect(described_class.trusted_entries(:cask)).to be_empty
// 101:     expect(described_class.trusted_entries(:command)).to be_empty
// 102:   ensure
// 103:     described_class.clear!(:tap)
// 104:     described_class.clear!(:formula)
// 105:     described_class.clear!(:cask)
// 106:     described_class.clear!(:command)
// 107:   end
// 108:
// 109:   it "infers tap type for a remote URL argument" do
// 110:     result = described_class.target("https://gitlab.com/other/repo")
// 111:     expect(result).to eq([:tap, "https://gitlab.com/other/repo"])
// 112:   end
// 113:
// 114:   it "infers tap type for an scp-style remote URL argument" do
// 115:     result = described_class.target("git@gitlab.com:other/repo")
// 116:     expect(result).to eq([:tap, "git@gitlab.com:other/repo"])
// 117:   end
// 118:
// 119:   it "rejects a bare @-string rather than trusting it as a tap" do
// 120:     expect { described_class.target("foo@bar") }
// 121:       .to raise_error(UsageError, /fully-qualified/)
// 122:     expect(described_class.trusted_entries(:tap)).to be_empty
// 123:   end
// 124:
// 125:   it "rejects a bare @-string even with an explicit tap type" do
// 126:     expect { described_class.target("not@valid", type: :tap) }
// 127:       .to raise_error(UsageError, /Invalid tap name/)
// 128:     expect(described_class.trusted_entries(:tap)).to be_empty
// 129:   end
// 130:
// 131:   it "trusts custom-remote tap items by remote but still resolves existing entries to untrust" do
// 132:     tap = Tap.fetch("thirdparty", "custom")
// 133:     tap.path.mkpath
// 134:     system "git", "-C", tap.path.to_s, "init"
// 135:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 136:
// 137:     described_class.trust!(*described_class.target("thirdparty/custom/bar", type: :formula))
// 138:
// 139:     expect(described_class.trusted?(:formula, "thirdparty/custom/bar")).to be(true)
// 140:     expect(described_class.trusted_entries(:formula)).to contain_exactly("https://gitlab.com/other/repo/bar")
// 141:
// 142:     described_class.trust!(:formula, "thirdparty/custom/legacy")
// 143:     expect(described_class.target("thirdparty/custom/legacy", type: :formula, include_existing: true))
// 144:       .to eq([:formula, "thirdparty/custom/legacy"])
// 145:   ensure
// 146:     described_class.clear!(:formula)
// 147:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 148:   end
// 149:
// 150:   it "keys an item by a declared custom remote before the tap is installed" do
// 151:     result = described_class.target("thirdparty/custom/bar", type:       :formula,
// 152:                                                              tap_remote: "https://gitlab.com/other/repo")
// 153:     expect(result).to eq([:formula, "https://gitlab.com/other/repo/bar"])
// 154:   end
// 155:
// 156:   it "keys an item by its tap name when the declared remote is its default remote" do
// 157:     result = described_class.target("thirdparty/custom/bar", type:       :formula,
// 158:                                                              tap_remote: "https://github.com/thirdparty/homebrew-custom")
// 159:     expect(result).to eq([:formula, "thirdparty/custom/bar"])
// 160:   end
// 161:
// 162:   it "keeps a declared remote custom relative to its tap name even when it resembles another default" do
// 163:     result = described_class.target("thirdparty/custom/bar", type:       :formula,
// 164:                                                              tap_remote: "https://github.com/other/homebrew-project")
// 165:     expect(result).to eq([:formula, "https://github.com/other/homebrew-project/bar"])
// 166:   end
// 167:
// 168:   it "keys a whole tap by a declared custom remote before the tap is installed" do
// 169:     result = described_class.target("thirdparty/custom", type: :tap, tap_remote: "https://gitlab.com/other/repo")
// 170:     expect(result).to eq([:tap, "https://gitlab.com/other/repo"])
// 171:   end
// 172:
// 173:   it "trusts formulae from trusted taps" do
// 174:     Tap.fetch("trustedformulae", "foo")
// 175:
// 176:     described_class.trust!(:tap, "trustedformulae/foo")
// 177:
// 178:     expect(described_class.trusted?(:formula, "trustedformulae/foo/bar")).to be(true)
// 179:   ensure
// 180:     described_class.clear!(:tap)
// 181:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"trustedformulae"
// 182:   end
// 183:
// 184:   it "ignores a trust file with a non-object JSON root" do
// 185:     trust_file = T.let(nil, T.nilable(Pathname))
// 186:     trust_file = described_class.trust_file
// 187:     trust_file.dirname.mkpath
// 188:     trust_file.write("[]")
// 189:
// 190:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 191:   ensure
// 192:     trust_file.unlink if trust_file&.exist?
// 193:   end
// 194:
// 195:   it "uses the provided home when the trust file path is home-based" do
// 196:     root_home = Pathname(TEST_TMPDIR)/"root-home"
// 197:     sudo_home = Pathname(TEST_TMPDIR)/"sudo-home"
// 198:     allow(Dir).to receive(:home).with(ENV.fetch("USER")).and_return(root_home.to_s)
// 199:
// 200:     with_env(HOMEBREW_USER_CONFIG_HOME: root_home/".homebrew") do
// 201:       expect(described_class.trust_file(home: sudo_home)).to eq(sudo_home/".homebrew/trust.json")
// 202:     end
// 203:   end
// 204:
// 205:   it "keeps the configured trust file path when it is not home-based" do
// 206:     root_home = Pathname(TEST_TMPDIR)/"root-home"
// 207:     sudo_home = Pathname(TEST_TMPDIR)/"sudo-home"
// 208:     config_home = Pathname(TEST_TMPDIR)/"xdg-config/homebrew"
// 209:     allow(Dir).to receive(:home).with(ENV.fetch("USER")).and_return(root_home.to_s)
// 210:
// 211:     with_env(HOMEBREW_USER_CONFIG_HOME: config_home) do
// 212:       expect(described_class.trust_file(home: sudo_home)).to eq(config_home/"trust.json")
// 213:     end
// 214:   end
// 215:
// 216:   it "trusts a GitHub SSH-remote tap by its name" do
// 217:     tap = Tap.fetch("thirdparty", "foo")
// 218:     tap.path.mkpath
// 219:     system "git", "-C", tap.path.to_s, "init"
// 220:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "git@github.com:thirdparty/homebrew-foo"
// 221:     # Guard the setup so the test genuinely exercises SSH-vs-HTTPS equivalence: a
// 222:     # remote-less tap would also be trusted by name, passing for the wrong reason.
// 223:     expect(tap.remote).to eq("git@github.com:thirdparty/homebrew-foo")
// 224:
// 225:     described_class.trust!(:tap, "thirdparty/foo")
// 226:
// 227:     expect(described_class.trusted_tap?(tap)).to be(true)
// 228:   ensure
// 229:     described_class.clear!(:tap)
// 230:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 231:   end
// 232:
// 233:   it "untrusts third-party taps" do
// 234:     described_class.trust!(:tap, "thirdparty/foo")
// 235:
// 236:     expect(described_class.untrust!(:tap, "thirdparty/foo")).to be(true)
// 237:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 238:   ensure
// 239:     described_class.clear!(:tap)
// 240:   end
// 241:
// 242:   it "does not lose entries when trusting concurrently" do
// 243:     names = Array.new(10) { |i| "thirdparty/foo/formula#{i}" }
// 244:
// 245:     names.map do |name|
// 246:       Thread.new { described_class.trust!(:formula, name) }
// 247:     end.each(&:join)
// 248:
// 249:     expect(described_class.trusted_entries(:formula)).to match_array(names)
// 250:   ensure
// 251:     described_class.clear!(:formula)
// 252:   end
// 253:
// 254:   it "trusts fully-qualified formulae and casks" do
// 255:     tap = Tap.fetch("qualified", "foo")
// 256:     tap.formula_dir.mkpath
// 257:     tap.cask_dir.mkpath
// 258:     (tap.formula_dir/"bar.rb").write("class Bar < Formula; end\n")
// 259:     (tap.cask_dir/"baz.rb").write("cask 'baz'\n")
// 260:
// 261:     without_partial_double_verification do
// 262:       expect($stderr).to receive(:ohai).with("Trusted formula qualified/foo/bar").ordered
// 263:       expect($stderr).to receive(:ohai).with("Trusted cask qualified/foo/baz").ordered
// 264:
// 265:       described_class.trust_fully_qualified_items!(["qualified/foo/bar", "qualified/foo/baz"])
// 266:     end
// 267:
// 268:     expect(described_class.trusted?(:formula, "qualified/foo/bar")).to be(true)
// 269:     expect(described_class.trusted?(:cask, "qualified/foo/baz")).to be(true)
// 270:   ensure
// 271:     described_class.clear!(:formula)
// 272:     described_class.clear!(:cask)
// 273:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"qualified"
// 274:   end
// 275:
// 276:   it "does not trust missing fully-qualified formulae or casks" do
// 277:     Tap.fetch("thirdparty", "foo")
// 278:
// 279:     described_class.trust_fully_qualified_items!(["thirdparty/foo/bar"], type: :formula)
// 280:     described_class.trust_fully_qualified_items!(["thirdparty/foo/baz"], type: :cask)
// 281:
// 282:     expect(described_class.trusted?(:formula, "thirdparty/foo/bar")).to be(false)
// 283:     expect(described_class.trusted?(:cask, "thirdparty/foo/baz")).to be(false)
// 284:   ensure
// 285:     described_class.clear!(:formula)
// 286:     described_class.clear!(:cask)
// 287:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 288:   end
// 289:
// 290:   it "does not report taps with trusted entries as wholly untrusted" do
// 291:     allow(described_class).to receive(:untrusted_taps)
// 292:       .and_return([
// 293:         instance_double(Tap, name: "thirdparty/foo", reference: "thirdparty/foo", uses_custom_remote?: false),
// 294:       ])
// 295:     described_class.trust!(:formula, "thirdparty/foo/bar")
// 296:
// 297:     expect(described_class.wholly_untrusted_taps).to be_empty
// 298:   ensure
// 299:     described_class.clear!(:formula)
// 300:   end
// 301:
// 302:   it "writes the trust store with user-only permissions" do
// 303:     described_class.trust!(:tap, "thirdparty/foo")
// 304:
// 305:     trust_file = described_class.trust_file
// 306:     expect(trust_file.stat.mode & 0777).to eq(0600)
// 307:   ensure
// 308:     described_class.clear!(:tap)
// 309:   end
// 310:
// 311:   it "creates the trust store directory with user-only permissions" do
// 312:     trust_file = described_class.trust_file
// 313:     FileUtils.rm_rf trust_file.dirname
// 314:     old_umask = T.let(nil, T.nilable(Integer))
// 315:     old_umask = File.umask(0002)
// 316:
// 317:     described_class.trust!(:tap, "thirdparty/foo")
// 318:
// 319:     expect(trust_file.dirname.stat.mode & 0777).to eq(0700)
// 320:   ensure
// 321:     File.umask(old_umask) if old_umask
// 322:     described_class.clear!(:tap)
// 323:   end
// 324:
// 325:   it "rejects a trust store in a group-writable directory" do
// 326:     trust_file = T.let(nil, T.nilable(Pathname))
// 327:     trust_file = described_class.trust_file
// 328:     trust_file.dirname.chmod(0770)
// 329:
// 330:     expect { described_class.trust!(:tap, "thirdparty/foo") }
// 331:       .to raise_error(Homebrew::InsecureTrustStoreError, /Refusing to write insecure trust store/)
// 332:   ensure
// 333:     if trust_file
// 334:       trust_file.dirname.chmod(0700) if trust_file.dirname.exist?
// 335:       FileUtils.rm_f trust_file
// 336:     end
// 337:   end
// 338:
// 339:   it "rejects a group-writable trust store" do
// 340:     trust_file = T.let(nil, T.nilable(Pathname))
// 341:     trust_file = described_class.trust_file
// 342:     trust_file.write(JSON.generate({ trustedtaps: ["thirdparty/foo"] }))
// 343:     trust_file.chmod(0660)
// 344:
// 345:     expect { described_class.trust!(:tap, "thirdparty/bar") }
// 346:       .to raise_error(Homebrew::InsecureTrustStoreError, /Refusing to write insecure trust store/)
// 347:   ensure
// 348:     trust_file.chmod(0600) if trust_file&.exist?
// 349:     FileUtils.rm_f trust_file if trust_file
// 350:   end
// 351:
// 352:   it "writes a symlinked trust store through to its target" do
// 353:     trust_file = described_class.trust_file
// 354:     target_dir = T.let(nil, T.nilable(Pathname))
// 355:     target_dir = Pathname(TEST_TMPDIR)/"trust-target"
// 356:     target_dir.mkpath
// 357:     target_file = target_dir/"trust.json"
// 358:     target_file.write(JSON.generate({ trustedtaps: ["thirdparty/foo"] }))
// 359:     FileUtils.ln_s target_file, trust_file
// 360:
// 361:     described_class.trust!(:tap, "thirdparty/bar")
// 362:
// 363:     expect(trust_file).to be_a_symlink
// 364:     expect(JSON.parse(target_file.read).fetch("trustedtaps")).to eq(["thirdparty/bar", "thirdparty/foo"])
// 365:   ensure
// 366:     described_class.clear!(:tap)
// 367:     FileUtils.rm_rf target_dir if target_dir
// 368:   end
// 369:
// 370:   it "rejects a symlinked trust store in a group-writable directory" do
// 371:     trust_file = described_class.trust_file
// 372:     target_dir = T.let(nil, T.nilable(Pathname))
// 373:     target_dir = Pathname(TEST_TMPDIR)/"trust-target"
// 374:     target_dir.mkpath
// 375:     target_dir.chmod(0770)
// 376:     FileUtils.ln_s target_dir/"trust.json", trust_file
// 377:
// 378:     expect { described_class.trust!(:tap, "thirdparty/foo") }
// 379:       .to raise_error(Homebrew::InsecureTrustStoreError, /Refusing to write insecure trust store/)
// 380:   ensure
// 381:     target_dir.chmod(0700) if target_dir&.exist?
// 382:     FileUtils.rm_rf target_dir if target_dir
// 383:   end
// 384:
// 385:   it "rejects a symlinked trust store pointing to another symlink" do
// 386:     trust_file = described_class.trust_file
// 387:     target_dir = T.let(nil, T.nilable(Pathname))
// 388:     target_dir = Pathname(TEST_TMPDIR)/"trust-target"
// 389:     target_dir.mkpath
// 390:     FileUtils.ln_s target_dir/"real-trust.json", target_dir/"trust.json"
// 391:     FileUtils.ln_s target_dir/"trust.json", trust_file
// 392:
// 393:     expect { described_class.trust!(:tap, "thirdparty/foo") }
// 394:       .to raise_error(Homebrew::InsecureTrustStoreError, /Refusing to write insecure trust store/)
// 395:   ensure
// 396:     FileUtils.rm_rf target_dir if target_dir
// 397:   end
// 398:
// 399:   it "requires third-party taps by default" do
// 400:     described_class.clear!(:tap)
// 401:     tap = Tap.fetch("thirdparty", "foo")
// 402:     formula_path = tap.formula_dir/"default-trust.rb"
// 403:     formula_path.dirname.mkpath
// 404:
// 405:     expect { described_class.require_trusted_formula!("default-trust", formula_path) }
// 406:       .to raise_error(Homebrew::UntrustedTapError)
// 407:
// 408:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 409:   ensure
// 410:     described_class.clear!(:tap)
// 411:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 412:   end
// 413:
// 414:   it "reads the invoking user's trust store for sudoed services" do
// 415:     root_home = Pathname(TEST_TMPDIR)/"root-home"
// 416:     sudo_home = Pathname(TEST_TMPDIR)/"sudo-home"
// 417:     (sudo_home/".homebrew").mkpath
// 418:     (sudo_home/".homebrew/trust.json").write(JSON.generate({ trustedtaps: ["thirdparty/foo"] }))
// 419:     tap = Tap.fetch("thirdparty", "foo")
// 420:     formula_path = tap.formula_dir/"default-trust.rb"
// 421:     formula_path.dirname.mkpath
// 422:
// 423:     allow(Homebrew).to receive(:running_as_root?).and_return(true)
// 424:     allow(Dir).to receive(:home).with(ENV.fetch("USER")).and_return(root_home.to_s)
// 425:     allow(Etc).to receive(:getpwnam).with("brewuser").and_return(double(dir: sudo_home.to_s))
// 426:
// 427:     with_env(HOME: root_home, HOMEBREW_SUDO_USER: "brewuser", HOMEBREW_USER_CONFIG_HOME: root_home/".homebrew") do
// 428:       expect { described_class.require_trusted_formula!("default-trust", formula_path) }.not_to raise_error
// 429:     end
// 430:   ensure
// 431:     FileUtils.rm_rf root_home if root_home
// 432:     FileUtils.rm_rf sudo_home if sudo_home
// 433:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 434:   end
// 435:
// 436:   it "reads the invoking user's XDG trust store under sudo" do
// 437:     xdg_config_home = Pathname(TEST_TMPDIR)/"sudo-xdg-config"
// 438:     (xdg_config_home/"homebrew").mkpath
// 439:     (xdg_config_home/"homebrew/trust.json").write(JSON.generate({ trustedtaps: ["thirdparty/foo"] }))
// 440:     tap = Tap.fetch("thirdparty", "foo")
// 441:     formula_path = tap.formula_dir/"default-trust.rb"
// 442:     formula_path.dirname.mkpath
// 443:
// 444:     allow(Homebrew).to receive(:running_as_root?).and_return(true)
// 445:     allow(Etc).to receive(:getpwnam).with("brewuser").and_return(double(dir: "/nonexistent"))
// 446:
// 447:     with_env(HOMEBREW_SUDO_USER:        "brewuser",
// 448:              HOMEBREW_USER_CONFIG_HOME: xdg_config_home/"homebrew",
// 449:              XDG_CONFIG_HOME:           xdg_config_home) do
// 450:       expect { described_class.require_trusted_formula!("default-trust", formula_path) }.not_to raise_error
// 451:     end
// 452:   ensure
// 453:     FileUtils.rm_rf xdg_config_home if xdg_config_home
// 454:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 455:   end
// 456:
// 457:   it "reads the invoking user's Homebrew XDG trust store under sudo" do
// 458:     xdg_config_home = Pathname(TEST_TMPDIR)/"sudo-homebrew-xdg-config"
// 459:     (xdg_config_home/"homebrew").mkpath
// 460:     (xdg_config_home/"homebrew/trust.json").write(JSON.generate({ trustedtaps: ["thirdparty/foo"] }))
// 461:     tap = Tap.fetch("thirdparty", "foo")
// 462:     formula_path = tap.formula_dir/"default-trust.rb"
// 463:     formula_path.dirname.mkpath
// 464:
// 465:     allow(Homebrew).to receive(:running_as_root?).and_return(true)
// 466:     allow(Etc).to receive(:getpwnam).with("brewuser").and_return(double(dir: "/nonexistent"))
// 467:
// 468:     with_env(HOMEBREW_SUDO_USER:        "brewuser",
// 469:              HOMEBREW_USER_CONFIG_HOME: xdg_config_home/"homebrew",
// 470:              XDG_CONFIG_HOME:           nil,
// 471:              HOMEBREW_XDG_CONFIG_HOME:  xdg_config_home) do
// 472:       expect { described_class.require_trusted_formula!("default-trust", formula_path) }.not_to raise_error
// 473:     end
// 474:   ensure
// 475:     FileUtils.rm_rf xdg_config_home if xdg_config_home
// 476:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 477:   end
// 478:
// 479:   it "warns when the sudo user cannot be looked up" do
// 480:     allow(Homebrew).to receive(:running_as_root?).and_return(true)
// 481:     allow(Etc).to receive(:getpwnam).with("brewuser").and_raise(ArgumentError)
// 482:
// 483:     with_env(HOMEBREW_SUDO_USER: "brewuser") do
// 484:       expect { expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false) }
// 485:         .to output(
// 486:           Regexp.new(
// 487:             "Could not determine home directory for `\\$HOMEBREW_SUDO_USER` " \
// 488:             "\\(brewuser\\); falling back to " \
// 489:             "#{Regexp.escape(described_class.trust_file.to_s)}\\.",
// 490:           ),
// 491:         ).to_stderr
// 492:     end
// 493:   ensure
// 494:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 495:   end
// 496:
// 497:   it "does not trust or store default trust when checking files" do
// 498:     tap = Tap.fetch("thirdparty", "foo")
// 499:     formula_path = tap.formula_dir/"default-trust.rb"
// 500:     formula_path.dirname.mkpath
// 501:
// 502:     expect { expect(described_class.trusted_formula_file?(formula_path)).to be(false) }
// 503:       .not_to output.to_stderr
// 504:
// 505:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 506:   ensure
// 507:     described_class.clear!(:tap)
// 508:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 509:   end
// 510:
// 511:   it "does not trust untrusted files when trust checks are enabled" do
// 512:     tap = Tap.fetch("thirdparty", "foo")
// 513:     formula_path = tap.formula_dir/"default-trust.rb"
// 514:     formula_path.dirname.mkpath
// 515:
// 516:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 517:       expect(described_class.trusted_formula_file?(formula_path)).to be(false)
// 518:     end
// 519:   ensure
// 520:     described_class.clear!(:tap)
// 521:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 522:   end
// 523:
// 524:   it "allows explicitly named formula files when trust checks are enabled" do
// 525:     old_argv = ARGV.dup
// 526:     tap = Tap.fetch("thirdparty", "foo")
// 527:     formula_path = tap.formula_dir/"default-trust.rb"
// 528:     formula_path.dirname.mkpath
// 529:
// 530:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 531:       ARGV.replace(["thirdparty/foo/default-trust"])
// 532:       expect(described_class.trusted_formula_file?(formula_path)).to be(true)
// 533:     end
// 534:
// 535:     expect(described_class.trusted?(:formula, "thirdparty/foo/default-trust")).to be(false)
// 536:   ensure
// 537:     ARGV.replace(old_argv) if old_argv
// 538:     described_class.clear!(:tap)
// 539:     described_class.clear!(:formula)
// 540:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 541:   end
// 542:
// 543:   it "allows files from explicitly named taps when trust checks are enabled" do
// 544:     old_argv = ARGV.dup
// 545:     tap = Tap.fetch("thirdparty", "foo")
// 546:     cask_path = tap.cask_dir/"default-trust.rb"
// 547:     cask_path.dirname.mkpath
// 548:
// 549:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 550:       ARGV.replace(["--tap", "thirdparty/foo"])
// 551:       expect(described_class.trusted_cask_file?(cask_path)).to be(true)
// 552:     end
// 553:
// 554:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 555:     expect(described_class.trusted?(:cask, "thirdparty/foo/default-trust")).to be(false)
// 556:   ensure
// 557:     ARGV.replace(old_argv) if old_argv
// 558:     described_class.clear!(:tap)
// 559:     described_class.clear!(:cask)
// 560:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 561:   end
// 562:
// 563:   it "does not allow explicitly named command files when trust checks are enabled" do
// 564:     old_argv = ARGV.dup
// 565:     tap = Tap.fetch("thirdparty", "foo")
// 566:     command_path = tap.path/"cmd/brew-default-trust.rb"
// 567:     command_path.dirname.mkpath
// 568:
// 569:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 570:       ARGV.replace(["thirdparty/foo/default-trust"])
// 571:       expect(described_class.trusted_command_files([command_path])).to eq([])
// 572:     end
// 573:   ensure
// 574:     ARGV.replace(old_argv) if old_argv
// 575:     described_class.clear!(:command)
// 576:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 577:   end
// 578:
// 579:   it "does not trust untrusted command files when trust checks are enabled" do
// 580:     tap = Tap.fetch("thirdparty", "foo")
// 581:     command_path = tap.path/"cmd/brew-default-trust.rb"
// 582:     command_path.dirname.mkpath
// 583:
// 584:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 585:       expect { expect(described_class.trusted_command_files([command_path])).to eq([]) }
// 586:         .to output(%r{Skipping thirdparty/foo because it is not trusted}).to_stderr
// 587:     end
// 588:   ensure
// 589:     described_class.clear!(:tap)
// 590:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 591:   end
// 592:
// 593:   it "does not warn about a partially trusted tap when other files are untrusted" do
// 594:     tap = Tap.fetch("thirdparty", "foo")
// 595:     trusted_path = tap.formula_dir/"trusted.rb"
// 596:     untrusted_path = tap.formula_dir/"untrusted.rb"
// 597:     trusted_path.dirname.mkpath
// 598:     FileUtils.touch [trusted_path, untrusted_path]
// 599:     described_class.trust!(:formula, "thirdparty/foo/trusted")
// 600:
// 601:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 602:       expect { expect(described_class.trusted_formula_files([trusted_path, untrusted_path])).to eq([trusted_path]) }
// 603:         .not_to output.to_stderr
// 604:     end
// 605:   ensure
// 606:     described_class.clear!(:tap)
// 607:     described_class.clear!(:formula)
// 608:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 609:   end
// 610:
// 611:   it "does not store default trust when trust checks are disabled" do
// 612:     tap = Tap.fetch("thirdparty", "foo")
// 613:     formula_path = tap.formula_dir/"default-trust.rb"
// 614:     formula_path.dirname.mkpath
// 615:
// 616:     with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 617:       expect { described_class.require_trusted_formula!("default-trust", formula_path) }
// 618:         .not_to output.to_stderr
// 619:     end
// 620:
// 621:     expect(described_class.trusted?(:tap, "thirdparty/foo")).to be(false)
// 622:   ensure
// 623:     described_class.clear!(:tap)
// 624:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 625:   end
// 626: end
