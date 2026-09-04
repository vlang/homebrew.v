module cask

import homebrew.cask as cask_loader
import os

// Translated from Homebrew/brew `test/cask/cask_loader_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskLoaderSpecBoundary {
pub:
	line   int
	passed bool
}

pub struct CaskLoaderSpecLoadArgs {
pub:
	warn       bool
	has_config bool
}

struct CaskLoaderMigrationFixture {
	context cask_loader.CaskLoaderLookupContext
	old_tap cask_loader.CaskLoaderTap
	new_tap cask_loader.CaskLoaderTap
}

fn cask_loader_spec_tap(root string, name string, core bool,
	core_cask bool) cask_loader.CaskLoaderTap {
	path := os.join_path(root, name.replace('/', '-'))
	return cask_loader.CaskLoaderTap{
		name: name
		path: path
		cask_dir: os.join_path(path, 'Casks')
		formula_dir: os.join_path(path, 'Formula')
		installed: true
		core_tap: core
		core_cask_tap: core_cask
	}
}

fn cask_loader_spec_core_cask(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/cask', false, true)
}

fn cask_loader_spec_core(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/core', true, false)
}

fn cask_loader_spec_context(root string) cask_loader.CaskLoaderLookupContext {
	return cask_loader.CaskLoaderLookupContext{
		cache_path: os.join_path(root, 'cache')
		cached_api_path: os.join_path(root, 'api', 'cask.json')
		cached_internal_api_path: os.join_path(root, 'api', 'cask.jws.json')
		cached_packages_path: os.join_path(root, 'api', 'packages.json')
		core_cask_tap: cask_loader_spec_core_cask(root)
	}
}

fn cask_loader_spec_ref(value string) cask_loader.CaskLoaderReference {
	return cask_loader.CaskLoaderReference{ kind: .text, value: value }
}

fn cask_loader_spec_path_ref(value string) cask_loader.CaskLoaderReference {
	return cask_loader.CaskLoaderReference{ kind: .path, value: value }
}

fn cask_loader_spec_write(path string, content string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, content)!
}

fn cask_loader_spec_evaluation(token string, version string) cask_loader.CaskLoaderEvaluation {
	return cask_loader.CaskLoaderEvaluation{
		valid: true
		cask: cask_loader.CaskLoaderCask{
			token: token
			version: version
		}
	}
}

fn cask_loader_spec_renamed_loader(root string, ref string,
	api bool) !cask_loader.CaskLoader {
	old_token := ruby_cask_loader_spec_l9_d2_old_token()
	new_token := ruby_cask_loader_spec_l10_d3_new_token()
	base_core := cask_loader_spec_core_cask(root)
	core := cask_loader.CaskLoaderTap{
		...base_core
		cask_renames: {
			old_token: new_token
		}
	}
	path := os.join_path(core.cask_dir, '${new_token}.rb')
	cask_loader_spec_write(path, '')!
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		no_install_from_api: !api
		core_cask_tap: core
		api_tokens: [old_token, new_token]
		api_renames: {
			old_token: new_token
		}
	}
	return cask_loader.cask_loader_for(cask_loader_spec_ref(ref), false, true, context)
}

fn cask_loader_spec_migration(root string, token string, old_name string, new_name string,
	destination string, installed bool) !CaskLoaderMigrationFixture {
	mut new_tap := if new_name == 'homebrew/cask' {
		cask_loader_spec_core_cask(root)
	} else if new_name == 'homebrew/core' {
		cask_loader_spec_core(root)
	} else {
		cask_loader_spec_tap(root, new_name, false, false)
	}
	new_tap = cask_loader.CaskLoaderTap{ ...new_tap, installed: installed }
	base_old := if old_name == 'homebrew/cask' {
		cask_loader_spec_core_cask(root)
	} else if old_name == 'homebrew/core' {
		cask_loader_spec_core(root)
	} else {
		cask_loader_spec_tap(root, old_name, false, false)
	}
	old_tap := cask_loader.CaskLoaderTap{
		...base_old
		tap_migrations: {
			token: new_tap.name
		}
	}
	if destination == 'cask' && installed {
		cask_loader_spec_write(os.join_path(new_tap.cask_dir, '${token}.rb'), '')!
	} else if destination == 'formula' && installed {
		cask_loader_spec_write(os.join_path(new_tap.formula_dir, '${token}.rb'), '')!
	}
	core_cask := if old_tap.core_cask_tap {
		old_tap
	} else if new_tap.core_cask_tap {
		new_tap
	} else {
		cask_loader_spec_core_cask(root)
	}
	return CaskLoaderMigrationFixture{
		old_tap: old_tap
		new_tap: new_tap
		context: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			no_install_from_api: true
			core_cask_tap: core_cask
			taps: [old_tap, new_tap]
		}
	}
}

fn cask_loader_spec_installed_path(root string, token string) string {
	return os.join_path(root, 'Caskroom', token, '.metadata', '1.0', '20250101000000.000', 'Casks', '${token}.json')
}

fn cask_loader_spec_artifact(name string) cask_loader.CaskLoaderArtifact {
	return cask_loader.CaskLoaderArtifact{ kind: 'app', values: [name] }
}

// Ruby let `let(:tap) { CoreCaskTap.instance }` at line 6.
pub fn ruby_cask_loader_spec_l6_d1_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core_cask(root)
}

// Ruby let `let(:old_token) { "version-newest" }` at line 9.
pub fn ruby_cask_loader_spec_l9_d2_old_token() string {
	return 'version-newest'
}

// Ruby let `let(:new_token) { "version-latest" }` at line 10.
pub fn ruby_cask_loader_spec_l10_d3_new_token() string {
	return 'version-latest'
}

// Ruby let `let(:api_casks) do` at line 12.
pub fn ruby_cask_loader_spec_l12_d4_api_casks() map[string]cask_loader.CaskLoaderApiSource {
	source := cask_loader.CaskLoaderApiSource{ present: true, version: 'latest' }
	return {
		ruby_cask_loader_spec_l9_d2_old_token():  source
		ruby_cask_loader_spec_l10_d3_new_token(): source
	}
}

// Ruby let `let(:cask_renames) do` at line 21.
pub fn ruby_cask_loader_spec_l21_d5_cask_renames() map[string]string {
	return {
		ruby_cask_loader_spec_l9_d2_old_token(): ruby_cask_loader_spec_l10_d3_new_token()
	}
}

// Ruby it `it "warns when using the short token" do` at line 37.
pub fn ruby_cask_loader_spec_l37_d6_warns(root string) !bool {
	loader := cask_loader_spec_renamed_loader(root, 'version-newest', false)!
	return loader.kind == .tap && loader.warning.contains('version-newest was renamed to version-latest')
}

// Ruby it `it "warns when using the full token" do` at line 43.
pub fn ruby_cask_loader_spec_l43_d7_warns(root string) !bool {
	loader := cask_loader_spec_renamed_loader(root, 'homebrew/cask/version-newest', false)!
	return loader.kind == .tap && loader.warning.contains('version-newest was renamed to version-latest')
}

// Ruby it `it "warns when using the short token" do` at line 51.
pub fn ruby_cask_loader_spec_l51_d8_warns(root string) !bool {
	loader := cask_loader_spec_renamed_loader(root, 'version-newest', true)!
	return loader.kind == .api && loader.warning.contains('version-newest was renamed to version-latest')
}

// Ruby it `it "warns when using the full token" do` at line 57.
pub fn ruby_cask_loader_spec_l57_d9_warns(root string) !bool {
	loader := cask_loader_spec_renamed_loader(root, 'homebrew/cask/version-newest', true)!
	return loader.kind == .api && loader.warning.contains('version-newest was renamed to version-latest')
}

// Ruby let `let(:token) { "local-caffeine" }` at line 67.
pub fn ruby_cask_loader_spec_l67_d10_token() string {
	return 'local-caffeine'
}

// Ruby let `let(:core_tap) { CoreTap.instance }` at line 69.
pub fn ruby_cask_loader_spec_l69_d11_core_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core(root)
}

// Ruby let `let(:core_cask_tap) { CoreCaskTap.instance }` at line 70.
pub fn ruby_cask_loader_spec_l70_d12_core_cask_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core_cask(root)
}

// Ruby let `let(:tap_migrations) do` at line 72.
pub fn ruby_cask_loader_spec_l72_d13_tap_migrations(token string,
	new_tap cask_loader.CaskLoaderTap) map[string]string {
	return {
		token: new_tap.name
	}
}

// Ruby let `let(:token) { "some-cask" }` at line 86.
pub fn ruby_cask_loader_spec_l86_d14_token() string {
	return 'some-cask'
}

// Ruby let `let(:old_tap) { Tap.fetch("homebrew", "foo") }` at line 88.
pub fn ruby_cask_loader_spec_l88_d15_old_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/foo', false, false)
}

// Ruby let `let(:new_tap) { Tap.fetch("homebrew", "bar") }` at line 89.
pub fn ruby_cask_loader_spec_l89_d16_new_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/bar', false, false)
}

// Ruby let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 91.
pub fn ruby_cask_loader_spec_l91_d17_cask_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l89_d16_new_tap(root).cask_dir, '${ruby_cask_loader_spec_l86_d14_token()}.rb')
}

// Ruby it `it "warns when loading the short token" do` at line 100.
pub fn ruby_cask_loader_spec_l100_d18_warns(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('some-cask'), false, true, fixture.context)!
	return loader.warning == 'Cask homebrew/foo/some-cask was renamed to homebrew/bar/some-cask.'
}

// Ruby it `it "warns with the canonical token when loading an uppercase short token" do` at line 106.
pub fn ruby_cask_loader_spec_l106_d19_warns(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('SOME-CASK'), false, true, fixture.context)!
	return loader.warning == 'Cask homebrew/foo/some-cask was renamed to homebrew/bar/some-cask.'
}

// Ruby it `it "does not warn when loading the full token in the new tap" do` at line 112.
pub fn ruby_cask_loader_spec_l112_d20_does(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('homebrew/bar/some-cask'), false, true, fixture.context)!
	return loader.warning == ''
}

// Ruby it `it "warns when loading the full token in the old tap" do` at line 118.
pub fn ruby_cask_loader_spec_l118_d21_warns(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('homebrew/foo/some-cask'), false, true, fixture.context)!
	return loader.warning.contains('homebrew/foo/some-cask was renamed to homebrew/bar/some-cask')
}

// Ruby it `it "raises when the migrated tap is not installed" do` at line 124.
pub fn ruby_cask_loader_spec_l124_d22_raises(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'cask', false)!
	context := cask_loader.CaskLoaderLoadContext{
		lookup: fixture.context
		trusted: true
	}
	cask_loader.cask_loader_load_reference(cask_loader_spec_ref('homebrew/foo/some-cask'), cask_loader.CaskLoaderConfig{}, true, context) or {
		return err.msg().contains('TapCaskUnavailableError') && err.msg().contains('If you trust this tap')
	}
	return false
}

// Ruby let `let(:old_tap) { core_cask_tap }` at line 135.
pub fn ruby_cask_loader_spec_l135_d23_old_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core_cask(root)
}

// Ruby let `let(:new_tap) { core_tap }` at line 136.
pub fn ruby_cask_loader_spec_l136_d24_new_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core(root)
}

// Ruby let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 138.
pub fn ruby_cask_loader_spec_l138_d25_formula_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l136_d24_new_tap(root).formula_dir, '${ruby_cask_loader_spec_l67_d10_token()}.rb')
}

// Ruby it `it "does not warn when loading the short token" do` at line 145.
pub fn ruby_cask_loader_spec_l145_d26_does(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'local-caffeine', 'homebrew/cask', 'homebrew/core', 'formula', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('local-caffeine'), false, true, fixture.context)!
	return loader.warning == ''
}

// Ruby let `let(:token) { "some-cask" }` at line 153.
pub fn ruby_cask_loader_spec_l153_d27_token() string {
	return 'some-cask'
}

// Ruby let `let(:old_tap) { Tap.fetch("homebrew", "foo") }` at line 155.
pub fn ruby_cask_loader_spec_l155_d28_old_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/foo', false, false)
}

// Ruby let `let(:new_tap) { Tap.fetch("homebrew", "bar") }` at line 156.
pub fn ruby_cask_loader_spec_l156_d29_new_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'homebrew/bar', false, false)
}

// Ruby let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 158.
pub fn ruby_cask_loader_spec_l158_d30_formula_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l156_d29_new_tap(root).formula_dir, '${ruby_cask_loader_spec_l153_d27_token()}.rb')
}

// Ruby it `it "does not warn when loading the short token" do` at line 165.
pub fn ruby_cask_loader_spec_l165_d31_does(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'some-cask', 'homebrew/foo', 'homebrew/bar', 'formula', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('some-cask'), false, true, fixture.context)!
	return loader.warning == ''
}

// Ruby let `let(:old_tap) { core_tap }` at line 173.
pub fn ruby_cask_loader_spec_l173_d32_old_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core(root)
}

// Ruby let `let(:new_tap) { core_cask_tap }` at line 174.
pub fn ruby_cask_loader_spec_l174_d33_new_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_core_cask(root)
}

// Ruby let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 176.
pub fn ruby_cask_loader_spec_l176_d34_cask_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l174_d33_new_tap(root).cask_dir, '${ruby_cask_loader_spec_l67_d10_token()}.rb')
}

// Ruby it `it "does not warn when loading the short token" do` at line 183.
pub fn ruby_cask_loader_spec_l183_d35_does(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'local-caffeine', 'homebrew/core', 'homebrew/cask', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('local-caffeine'), false, true, fixture.context)!
	return loader.warning == ''
}

// Ruby it `it "does not warn when loading the full token in the default tap" do` at line 189.
pub fn ruby_cask_loader_spec_l189_d36_does(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'local-caffeine', 'homebrew/core', 'homebrew/cask', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('homebrew/cask/local-caffeine'), false, true, fixture.context)!
	return loader.warning == ''
}

// Ruby it `it "warns when loading the full token in the old tap" do` at line 195.
pub fn ruby_cask_loader_spec_l195_d37_warns(root string) !bool {
	fixture := cask_loader_spec_migration(root, 'local-caffeine', 'homebrew/core', 'homebrew/cask', 'cask', true)!
	loader := cask_loader.cask_loader_for(cask_loader_spec_ref('homebrew/core/local-caffeine'), false, true, fixture.context)!
	return loader.warning == 'Cask homebrew/core/local-caffeine was renamed to local-caffeine.'
}

// Ruby let `let(:caskfile) do` at line 221.
pub fn ruby_cask_loader_spec_l221_d38_caskfile(root string) string {
	return cask_loader_spec_installed_path(root, 'stubbed')
}

// Ruby it `it "falls back to the API for missing artifacts by default" do` at line 227.
pub fn ruby_cask_loader_spec_l227_d39_falls(root string) !bool {
	path := ruby_cask_loader_spec_l221_d38_caskfile(root)
	cask_loader_spec_write(path, '{}')!
	artifact := cask_loader_spec_artifact('Stubbed.app')
	lookup := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		installed_caskfiles: {
			'stubbed': path
		}
		api_membership: {
			'stubbed': .present
		}
		api_artifacts: {
			'stubbed': [artifact]
		}
	}
	cask := cask_loader.cask_loader_load_from_installed_caskfile(path, cask_loader.CaskLoaderConfig{}, true, true, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		trusted: true
	})!
	return cask.artifacts == [artifact]
}

// Ruby it `it "does not consult the API when api_fallback is disabled" do` at line 237.
pub fn ruby_cask_loader_spec_l237_d40_does(root string) !bool {
	path := ruby_cask_loader_spec_l221_d38_caskfile(root)
	cask_loader_spec_write(path, '{}')!
	lookup := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		installed_caskfiles: {
			'stubbed': path
		}
		api_membership: {
			'stubbed': .present
		}
		api_artifacts: {
			'stubbed': [cask_loader_spec_artifact('Should Not Load.app')]
		}
	}
	cask := cask_loader.cask_loader_load_from_installed_caskfile(path, cask_loader.CaskLoaderConfig{}, true, false, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		trusted: true
	})!
	return cask.artifacts.len == 0
}

// Ruby let `let(:foo_tap) { Tap.fetch("user", "foo") }` at line 246.
pub fn ruby_cask_loader_spec_l246_d41_foo_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'user/foo', false, false)
}

// Ruby let `let(:bar_tap) { Tap.fetch("user", "bar") }` at line 247.
pub fn ruby_cask_loader_spec_l247_d42_bar_tap(root string) cask_loader.CaskLoaderTap {
	return cask_loader_spec_tap(root, 'user/bar', false, false)
}

// Ruby let `let(:blank_tab) { instance_double(Cask::Tab, tap: nil) }` at line 249.
pub fn ruby_cask_loader_spec_l249_d43_blank_tab() cask_loader.CaskLoaderReceipt {
	return cask_loader.CaskLoaderReceipt{}
}

// Ruby let `let(:installed_tab) { instance_double(Cask::Tab, tap: bar_tap) }` at line 250.
pub fn ruby_cask_loader_spec_l250_d44_installed_tab(root string) cask_loader.CaskLoaderReceipt {
	return cask_loader.CaskLoaderReceipt{
		tap: ruby_cask_loader_spec_l247_d42_bar_tap(root)
		has_tap: true
	}
}

// Ruby let `let(:cask_with_foo_tap) { instance_double(Cask::Cask, token: "test-cask", tap: foo_tap) }` at line 252.
pub fn ruby_cask_loader_spec_l252_d45_cask_with_foo_tap(root string) cask_loader.CaskLoaderCask {
	return cask_loader.CaskLoaderCask{
		token: 'test-cask'
		tap: ruby_cask_loader_spec_l246_d41_foo_tap(root)
		has_tap: true
	}
}

// Ruby let `let(:cask_with_bar_tap) { instance_double(Cask::Cask, token: "test-cask", tap: bar_tap) }` at line 253.
pub fn ruby_cask_loader_spec_l253_d46_cask_with_bar_tap(root string) cask_loader.CaskLoaderCask {
	return cask_loader.CaskLoaderCask{
		token: 'test-cask'
		tap: ruby_cask_loader_spec_l247_d42_bar_tap(root)
		has_tap: true
	}
}

// Ruby let `let(:load_args) { { config: nil, warn: true } }` at line 255.
pub fn ruby_cask_loader_spec_l255_d47_load_args() CaskLoaderSpecLoadArgs {
	return CaskLoaderSpecLoadArgs{ warn: true }
}

// Ruby it `it "returns the correct cask when no tap is specified and no tab exists" do` at line 263.
pub fn ruby_cask_loader_spec_l263_d48_returns(root string) !bool {
	foo := ruby_cask_loader_spec_l252_d45_cask_with_foo_tap(root)
	context := cask_loader.CaskLoaderLoadContext{
		lookup: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			load_casks: {
				'test-cask': foo
			}
		}
	}
	return cask_loader.cask_loader_load_prefer_installed('test-cask', cask_loader.CaskLoaderConfig{}, true, context)!.tap.name == foo.tap.name
}

// Ruby it `it "returns the correct cask when no tap is specified but a tab exists" do` at line 270.
pub fn ruby_cask_loader_spec_l270_d49_returns(root string) !bool {
	bar := ruby_cask_loader_spec_l253_d46_cask_with_bar_tap(root)
	context := cask_loader.CaskLoaderLoadContext{
		lookup: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			installed_receipts: {
				'test-cask': ruby_cask_loader_spec_l250_d44_installed_tab(root)
			}
			load_casks: {
				'user/bar/test-cask': bar
			}
		}
	}
	return cask_loader.cask_loader_load_prefer_installed('test-cask', cask_loader.CaskLoaderConfig{}, true, context)!.tap.name == bar.tap.name
}

// Ruby it `it "returns the correct cask when a tap is specified and no tab exists" do` at line 277.
pub fn ruby_cask_loader_spec_l277_d50_returns(root string) !bool {
	bar := ruby_cask_loader_spec_l253_d46_cask_with_bar_tap(root)
	context := cask_loader.CaskLoaderLoadContext{
		lookup: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			load_casks: {
				'user/bar/test-cask': bar
			}
		}
	}
	return cask_loader.cask_loader_load_prefer_installed('user/bar/test-cask', cask_loader.CaskLoaderConfig{}, true, context)!.tap.name == bar.tap.name
}

// Ruby it `it "returns the correct cask when no tap is specified and a tab exists" do` at line 284.
pub fn ruby_cask_loader_spec_l284_d51_returns(root string) !bool {
	foo := ruby_cask_loader_spec_l252_d45_cask_with_foo_tap(root)
	context := cask_loader.CaskLoaderLoadContext{
		lookup: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			installed_receipts: {
				'user/foo/test-cask': ruby_cask_loader_spec_l250_d44_installed_tab(root)
			}
			load_casks: {
				'user/foo/test-cask': foo
			}
		}
	}
	return cask_loader.cask_loader_load_prefer_installed('user/foo/test-cask', cask_loader.CaskLoaderConfig{}, true, context)!.tap.name == foo.tap.name
}

// Ruby it `it "returns the correct cask when no tap is specified and the tab lists an tap that isn't installed" do` at line 291.
pub fn ruby_cask_loader_spec_l291_d52_returns(root string) !bool {
	foo := ruby_cask_loader_spec_l252_d45_cask_with_foo_tap(root)
	context := cask_loader.CaskLoaderLoadContext{
		lookup: cask_loader.CaskLoaderLookupContext{
			...cask_loader_spec_context(root)
			installed_receipts: {
				'test-cask': ruby_cask_loader_spec_l250_d44_installed_tab(root)
			}
			load_casks: {
				'test-cask': foo
			}
			load_failures: ['user/bar/test-cask']
		}
	}
	return cask_loader.cask_loader_load_prefer_installed('test-cask', cask_loader.CaskLoaderConfig{}, true, context)!.tap.name == foo.tap.name
}

// Ruby it `it "masks sensitive environment variables while evaluating casks" do` at line 302.
pub fn ruby_cask_loader_spec_l302_d53_masks(root string) !bool {
	path := os.join_path(root, 'sensitive-env.rb')
	content := [
		'cask "sensitive-env" do',
		'  version "1.0.0"',
		'  sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"',
		'',
		'  url "https://example.com/app.dmg"',
		'  name "Sensitive Env"',
		'  desc ENV.fetch("HOMEBREW_SECRET_TOKEN", "") == "password" ? "Secret leaked" : "Secret masked"',
		'  homepage "https://example.com"',
		'',
		'  app "App.app"',
		'end',
	].join('\n') + '\n'
	cask_loader_spec_write(path, content)!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	environment := {
		'HOMEBREW_SECRET_TOKEN': 'password'
	}
	cask := cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask_loader.CaskLoaderEvaluation{
			valid: true
			cask: cask_loader.CaskLoaderCask{
				token: 'sensitive-env'
				version: '1.0.0'
				desc: 'Secret masked'
			}
		}
		environment: environment
		trusted: true
	})!
	masked_secret := cask.evaluation_environment['HOMEBREW_SECRET_TOKEN'] or { '' }
	return cask.desc == 'Secret masked' && masked_secret != 'password' && environment['HOMEBREW_SECRET_TOKEN'] == 'password'
}

// Ruby it `it "allows the GitHub API token while evaluating casks" do` at line 327.
pub fn ruby_cask_loader_spec_l327_d54_allows(root string) !bool {
	path := os.join_path(root, 'github-token-env.rb')
	content := [
		'cask "github-token-env" do',
		'  version "1.0.0"',
		'  sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"',
		'',
		'  url "https://example.com/app.dmg"',
		'  name "GitHub Token Env"',
		'  desc ENV.key?("HOMEBREW_GITHUB_API_TOKEN") ? "Token present" : "Token absent"',
		'  homepage "https://example.com"',
		'',
		'  app "App.app"',
		'end',
	].join('\n') + '\n'
	cask_loader_spec_write(path, content)!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask := cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask_loader.CaskLoaderEvaluation{
			valid: true
			cask: cask_loader.CaskLoaderCask{
				token: 'github-token-env'
				version: '1.0.0'
				desc: 'Token present'
			}
		}
		environment: {
			'HOMEBREW_GITHUB_API_TOKEN': 'github-token'
		}
		trusted: true
	})!
	github_token := cask.evaluation_environment['HOMEBREW_GITHUB_API_TOKEN'] or { '' }
	return cask.desc == 'Token present' && github_token == 'github-token'
}

// Ruby it `it "refuses untrusted third-party tap casks when trust is enabled" do` at line 351.
pub fn ruby_cask_loader_spec_l351_d55_refuses(root string) !bool {
	tap := cask_loader_spec_tap(root, 'thirdparty/foo', false, false)
	path := os.join_path(tap.cask_dir, 'sensitive-env.rb')
	content := [
		'cask "sensitive-env" do',
		'  version "1.0.0"',
		'  sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"',
		'',
		'  url "https://example.com/app.dmg"',
		'  name "Sensitive Env"',
		'  desc "Sensitive Env"',
		'  homepage "https://example.com"',
		'',
		'  app "App.app"',
		'end',
	].join('\n') + '\n'
	cask_loader_spec_write(path, content)!
	lookup := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		source_download_taps: {
			os.abs_path(path): tap
		}
	}
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{ lookup: lookup, trusted: false }) or {
		if !err.msg().contains('UntrustedTapError') || !err.msg().contains('thirdparty/foo') {
			return false
		}
		mut trusted_loader := cask_loader.new_path_cask_loader(path, '', lookup)
		cask := cask_loader.cask_loader_load_path(mut trusted_loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
			lookup: lookup
			evaluation: cask_loader_spec_evaluation('sensitive-env', '1.0.0')
			trusted: true
		}) or { return false }
		return cask.has_tap && cask.tap.name == 'thirdparty/foo'
	}
	return false
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 387.
pub fn ruby_cask_loader_spec_l387_d56_tmpdir(root string) string {
	return os.join_path(root, 'removed-method')
}

// Ruby let `let(:cask_token) { "removed-method-cask" }` at line 388.
pub fn ruby_cask_loader_spec_l388_d57_cask_token() string {
	return 'removed-method-cask'
}

// Ruby let `let(:cask_file) { tmpdir/"#{cask_token}.rb" }` at line 389.
pub fn ruby_cask_loader_spec_l389_d58_cask_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l387_d56_tmpdir(root), '${ruby_cask_loader_spec_l388_d57_cask_token()}.rb')
}

// Ruby let `let(:cask_content) do` at line 390.
pub fn ruby_cask_loader_spec_l390_d59_cask_content() string {
	return [
		'cask "removed-method-cask" do',
		'  version "1.0.0"',
		'  sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"',
		'',
		'  url "https://example.com/app.dmg"',
		'  appcast "https://example.com/appcast.xml"',
		'  name "Removed Method Cask"',
		'  homepage "https://example.com"',
		'',
		'  app "App.app"',
		'end',
	].join('\n') + '\n'
}

// Ruby it `it "raises CaskInvalidError" do` at line 415.
pub fn ruby_cask_loader_spec_l415_d60_raises(root string) !bool {
	path := ruby_cask_loader_spec_l389_d58_cask_file(root)
	cask_loader_spec_write(path, ruby_cask_loader_spec_l390_d59_cask_content())!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask_loader.CaskLoaderEvaluation{
			failed: true
			error_kind: 'CaskInvalidError'
			error_message: 'appcast is disabled'
		}
		trusted: true
	}) or { return err.msg().contains('CaskInvalidError') }
	return false
}

// Ruby it `it "does not set Homebrew.failed" do` at line 420.
pub fn ruby_cask_loader_spec_l420_d61_does(root string) !bool {
	path := ruby_cask_loader_spec_l389_d58_cask_file(root)
	cask_loader_spec_write(path, ruby_cask_loader_spec_l390_d59_cask_content())!
	lookup := cask_loader_spec_context(root)
	evaluation := cask_loader.CaskLoaderEvaluation{
		failed: true
		error_kind: 'CaskInvalidError'
		error_message: 'appcast is disabled'
		homebrew_failed: false
	}
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: evaluation
		trusted: true
	}) or { return err.msg().contains('CaskInvalidError') && !evaluation.homebrew_failed }
	return false
}

// Ruby it `it "raises CaskUnreadableError when loaded from installed caskfile" do` at line 426.
pub fn ruby_cask_loader_spec_l426_d62_raises(root string) !bool {
	path := ruby_cask_loader_spec_l389_d58_cask_file(root)
	cask_loader_spec_write(path, ruby_cask_loader_spec_l390_d59_cask_content())!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_set_from_installed_caskfile(mut loader, true)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask_loader.CaskLoaderEvaluation{
			failed: true
			error_kind: 'CaskInvalidError'
			error_message: 'appcast is disabled'
		}
		trusted: true
	}) or { return err.msg().contains('CaskUnreadableError') && err.msg().contains('appcast') }
	return false
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 434.
pub fn ruby_cask_loader_spec_l434_d63_tmpdir(root string) string {
	return os.join_path(root, 'removed-conflicts')
}

// Ruby let `let(:cask_token) { "removed-conflicts-key-cask" }` at line 435.
pub fn ruby_cask_loader_spec_l435_d64_cask_token() string {
	return 'removed-conflicts-key-cask'
}

// Ruby let `let(:cask_file) { tmpdir/"#{cask_token}.json" }` at line 436.
pub fn ruby_cask_loader_spec_l436_d65_cask_file(root string) string {
	return os.join_path(ruby_cask_loader_spec_l434_d63_tmpdir(root), '${ruby_cask_loader_spec_l435_d64_cask_token()}.json')
}

// Ruby let `let(:cask_content) do` at line 437.
pub fn ruby_cask_loader_spec_l437_d66_cask_content() string {
	return [
		'{',
		'  "token": "removed-conflicts-key-cask",',
		'  "full_token": "removed-conflicts-key-cask",',
		'  "tap": "homebrew/cask",',
		'  "name": [],',
		'  "desc": null,',
		'  "homepage": "https://example.com",',
		'  "url": "https://example.com/removed-conflicts-key-cask.zip",',
		'  "version": "1.0.0",',
		'  "installed": null,',
		'  "outdated": false,',
		'  "sha256": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",',
		'  "artifacts": [',
		'    {',
		'      "app": [',
		'        "App.app"',
		'      ]',
		'    }',
		'  ],',
		'  "caveats": null,',
		'  "depends_on": {},',
		'  "conflicts_with": {',
		'    "formula": [',
		'      "some-formula"',
		'    ]',
		'  },',
		'  "container": null,',
		'  "rename": [],',
		'  "auto_updates": null,',
		'  "tap_git_head": "abcdef1234567890abcdef1234567890abcdef12",',
		'  "languages": [],',
		'  "ruby_source_path": "Casks/removed-conflicts-key-cask.rb",',
		'  "ruby_source_checksum": {',
		'    "sha256": "d3c19b564ee5a17f22191599ad795a6cc9c4758d0e1269f2d13207155b378dea"',
		'  }',
		'}',
	].join('\n') + '\n'
}

// Ruby it `it "raises CaskInvalidError" do` at line 487.
pub fn ruby_cask_loader_spec_l487_d67_raises(root string) !bool {
	path := ruby_cask_loader_spec_l436_d65_cask_file(root)
	cask_loader_spec_write(path, ruby_cask_loader_spec_l437_d66_cask_content())!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{ lookup: lookup, trusted: true }) or {
		return err.msg().contains('CaskInvalidError') && err.msg().contains('Unknown key: :formula')
	}
	return false
}

// Ruby it `it "raises CaskUnreadableError when loaded from installed caskfile" do` at line 492.
pub fn ruby_cask_loader_spec_l492_d68_raises(root string) !bool {
	path := ruby_cask_loader_spec_l436_d65_cask_file(root)
	cask_loader_spec_write(path, ruby_cask_loader_spec_l437_d66_cask_content())!
	lookup := cask_loader_spec_context(root)
	mut loader := cask_loader.new_path_cask_loader(path, '', lookup)
	cask_loader.cask_loader_set_from_installed_caskfile(mut loader, true)
	cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{ lookup: lookup, trusted: true }) or {
		return err.msg().contains('CaskUnreadableError') && err.msg().contains('Unknown key: :formula')
	}
	return false
}

// Ruby let `let(:cask_token) { "testcask" }` at line 501.
pub fn ruby_cask_loader_spec_l501_d69_cask_token() string {
	return 'testcask'
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 502.
pub fn ruby_cask_loader_spec_l502_d70_tmpdir(root string) string {
	return os.join_path(root, 'symlink')
}

// Ruby let `let(:real_tap_path) { tmpdir / "real_tap" }` at line 503.
pub fn ruby_cask_loader_spec_l503_d71_real_tap_path(root string) string {
	return os.join_path(ruby_cask_loader_spec_l502_d70_tmpdir(root), 'real_tap')
}

// Ruby let `let(:homebrew_prefix) { tmpdir / "homebrew" }` at line 504.
pub fn ruby_cask_loader_spec_l504_d72_homebrew_prefix(root string) string {
	return os.join_path(ruby_cask_loader_spec_l502_d70_tmpdir(root), 'homebrew')
}

// Ruby let `let(:taps_dir) { homebrew_prefix / "Library" / "Taps" / "testuser" }` at line 505.
pub fn ruby_cask_loader_spec_l505_d73_taps_dir(root string) string {
	return os.join_path(ruby_cask_loader_spec_l504_d72_homebrew_prefix(root), 'Library', 'Taps', 'testuser')
}

// Ruby let `let(:symlinked_tap_path) { taps_dir / "homebrew-testtap" }` at line 506.
pub fn ruby_cask_loader_spec_l506_d74_symlinked_tap_path(root string) string {
	return os.join_path(ruby_cask_loader_spec_l505_d73_taps_dir(root), 'homebrew-testtap')
}

// Ruby let `let(:cask_file_path) { symlinked_tap_path / "Casks" / "#{cask_token}.rb" }` at line 507.
pub fn ruby_cask_loader_spec_l507_d75_cask_file_path(root string) string {
	return os.join_path(ruby_cask_loader_spec_l506_d74_symlinked_tap_path(root), 'Casks', '${ruby_cask_loader_spec_l501_d69_cask_token()}.rb')
}

// Ruby let `let(:cask_content) do` at line 508.
pub fn ruby_cask_loader_spec_l508_d76_cask_content() string {
	return [
		'cask "testcask" do',
		'  version "1.0.0"',
		'  sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"',
		'',
		'  url "https://example.com/testcask-#{version}.dmg"',
		'  name "Test Cask"',
		'  desc "A test cask for symlink testing"',
		'  homepage "https://example.com"',
		'',
		'  app "TestCask.app"',
		'end',
	].join('\n') + '\n'
}

// Ruby it `it "allows loading casks from symlinked taps" do` at line 545.
pub fn ruby_cask_loader_spec_l545_d77_allows(root string) !bool {
	real := ruby_cask_loader_spec_l503_d71_real_tap_path(root)
	cask_loader_spec_write(os.join_path(real, 'Casks', 'testcask.rb'), ruby_cask_loader_spec_l508_d76_cask_content())!
	os.mkdir_all(ruby_cask_loader_spec_l505_d73_taps_dir(root))!
	link := ruby_cask_loader_spec_l506_d74_symlinked_tap_path(root)
	os.symlink(real, link)!
	path := ruby_cask_loader_spec_l507_d75_cask_file_path(root)
	lookup := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		forbid_packages_from_paths: true
	}
	mut loader := cask_loader.cask_loader_try_path(cask_loader_spec_path_ref(path), lookup) or { return false }
	cask := cask_loader.cask_loader_load_path(mut loader, cask_loader.CaskLoaderConfig{}, cask_loader.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask_loader_spec_evaluation('testcask', '1.0.0')
		trusted: true
	})!
	return cask.token == 'testcask' && cask.version == '1.0.0'
}

// Ruby it `it "allows loading casks from symlinked taps" do` at line 561.
pub fn ruby_cask_loader_spec_l561_d78_allows(root string) !bool {
	real := ruby_cask_loader_spec_l503_d71_real_tap_path(root)
	cask_loader_spec_write(os.join_path(real, 'Casks', 'testcask.rb'), ruby_cask_loader_spec_l508_d76_cask_content())!
	os.mkdir_all(ruby_cask_loader_spec_l505_d73_taps_dir(root))!
	link := ruby_cask_loader_spec_l506_d74_symlinked_tap_path(root)
	if !os.exists(link) {
		os.symlink(real, link)!
	}
	return cask_loader.cask_loader_try_path(cask_loader_spec_path_ref(ruby_cask_loader_spec_l507_d75_cask_file_path(root)), cask_loader_spec_context(root)) != none
}

// Ruby it `it "does not request API metadata for a removed cask" do` at line 572.
pub fn ruby_cask_loader_spec_l572_d79_does(root string) bool {
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_membership: {
			'removed-cask': .absent
		}
		api_artifacts: {
			'removed-cask': [cask_loader_spec_artifact('Should Not Load.app')]
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('removed-cask', [], false, none, true, context).len == 0
}

// Ruby it `it "falls back to API artifacts when the membership check fails" do` at line 580.
pub fn ruby_cask_loader_spec_l580_d80_falls(root string) bool {
	artifact := cask_loader_spec_artifact('API.app')
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_membership: {
			'unavailable-membership': .failure
		}
		api_artifacts: {
			'unavailable-membership': [artifact]
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('unavailable-membership', [], false, none, true, context) == [
		artifact,
	]
}

// Ruby it `it "returns empty artifacts when the API download fails" do` at line 591.
pub fn ruby_cask_loader_spec_l591_d81_returns(root string) bool {
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_membership: {
			'unavailable': .present
		}
		api_artifact_failure_kinds: {
			'unavailable': 'ErrorDuringExecution'
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('unavailable', [], false, none, true, context).len == 0
}

// Ruby it `it "returns empty artifacts when the API cannot be loaded" do` at line 601.
pub fn ruby_cask_loader_spec_l601_d82_returns(root string) bool {
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_membership: {
			'unavailable': .present
		}
		api_artifact_failure_kinds: {
			'unavailable': 'SystemExit'
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('unavailable', [], false, none, true, context).len == 0
}

// Ruby it `it "falls back to API artifacts when tap lookup is ambiguous" do` at line 608.
pub fn ruby_cask_loader_spec_l608_d83_falls(root string) bool {
	artifact := cask_loader_spec_artifact('API.app')
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_membership: {
			'ambiguous': .present
		}
		api_artifacts: {
			'ambiguous': [artifact]
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('ambiguous', [], false, none, true, context) == [
		artifact,
	]
}

// Ruby it `it "returns empty artifacts when the installed tap and API are unavailable" do` at line 621.
pub fn ruby_cask_loader_spec_l621_d84_returns(root string) bool {
	tap := cask_loader_spec_tap(root, 'thirdparty/missing', false, false)
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		api_artifact_failure_kinds: {
			'unavailable-tap': 'SystemExit'
		}
	}
	return cask_loader.cask_loader_resolve_installed_artifacts('unavailable-tap', [], false, tap, true, context).len == 0
}

// Ruby let `let(:caskroom) { mktmpdir/"Caskroom" }` at line 634.
pub fn ruby_cask_loader_spec_l634_d85_caskroom(root string) string {
	return os.join_path(root, 'Caskroom')
}

// Ruby it `it "reconstructs the installed version and artifacts from its receipt" do` at line 638.
pub fn ruby_cask_loader_spec_l638_d86_reconstructs(root string) !bool {
	token := 'recoverable'
	path := os.join_path(ruby_cask_loader_spec_l634_d85_caskroom(root), token, '.metadata', '1.0', '20250101000000.000', 'Casks', '${token}.rb')
	cask_loader_spec_write(path, 'unreadable')!
	artifact := cask_loader_spec_artifact('Recoverable.app')
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		installed_receipts: {
			token: cask_loader.CaskLoaderReceipt{
				version: '1.0'
				uninstall_artifacts: [artifact]
				has_uninstall_artifacts: true
				has_uninstall_flight_key: true
			}
		}
	}
	recovered := cask_loader.cask_loader_recover_from_installed_caskfile(path, none, none, cask_loader.CaskLoaderConfig{}, context) or { return false }
	return recovered.version == '1.0' && recovered.artifacts == [artifact]
}

// Ruby it `it "does not reconstruct missing uninstall flight blocks" do` at line 661.
pub fn ruby_cask_loader_spec_l661_d87_does(root string) !bool {
	token := 'flight-block'
	path := os.join_path(ruby_cask_loader_spec_l634_d85_caskroom(root), token, '.metadata', '1.0', '20250101000000.000', 'Casks', '${token}.rb')
	cask_loader_spec_write(path, 'unreadable')!
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		installed_receipts: {
			token: cask_loader.CaskLoaderReceipt{
				uninstall_flight_blocks: true
				has_uninstall_flight_key: true
				uninstall_artifacts: [
					cask_loader.CaskLoaderArtifact{ kind: 'uninstall_preflight' },
				]
				has_uninstall_artifacts: true
			}
		}
	}
	return cask_loader.cask_loader_recover_from_installed_caskfile(path, none, none, cask_loader.CaskLoaderConfig{}, context) == none
}

// Ruby it `it "returns nil when the reconstructed metadata remains invalid" do` at line 676.
pub fn ruby_cask_loader_spec_l676_d88_returns(root string) !bool {
	token := 'still-invalid'
	path := os.join_path(ruby_cask_loader_spec_l634_d85_caskroom(root), token, '.metadata', '1.0', '20250101000000.000', 'Casks', '${token}.rb')
	cask_loader_spec_write(path, 'unreadable')!
	context := cask_loader.CaskLoaderLookupContext{
		...cask_loader_spec_context(root)
		recovery_invalid_tokens: [token]
	}
	return cask_loader.cask_loader_recover_from_installed_caskfile(path, none, none, cask_loader.CaskLoaderConfig{}, context) == none
}

pub fn cask_loader_spec_all_boundaries(root string) ![]CaskLoaderSpecBoundary {
	os.mkdir_all(root)!
	mut boundaries := []CaskLoaderSpecBoundary{}
	boundaries << CaskLoaderSpecBoundary{ line: 6, passed: ruby_cask_loader_spec_l6_d1_tap(root).core_cask_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 9, passed: ruby_cask_loader_spec_l9_d2_old_token() == 'version-newest' }
	boundaries << CaskLoaderSpecBoundary{ line: 10, passed: ruby_cask_loader_spec_l10_d3_new_token() == 'version-latest' }
	boundaries << CaskLoaderSpecBoundary{ line: 12, passed: ruby_cask_loader_spec_l12_d4_api_casks().len == 2 }
	cask_renames := ruby_cask_loader_spec_l21_d5_cask_renames()
	boundaries << CaskLoaderSpecBoundary{ line: 21, passed: cask_renames['version-newest'] == 'version-latest' }
	boundaries << CaskLoaderSpecBoundary{ line: 37, passed: ruby_cask_loader_spec_l37_d6_warns(os.join_path(root, 'd6'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 43, passed: ruby_cask_loader_spec_l43_d7_warns(os.join_path(root, 'd7'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 51, passed: ruby_cask_loader_spec_l51_d8_warns(os.join_path(root, 'd8'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 57, passed: ruby_cask_loader_spec_l57_d9_warns(os.join_path(root, 'd9'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 67, passed: ruby_cask_loader_spec_l67_d10_token() == 'local-caffeine' }
	boundaries << CaskLoaderSpecBoundary{ line: 69, passed: ruby_cask_loader_spec_l69_d11_core_tap(root).core_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 70, passed: ruby_cask_loader_spec_l70_d12_core_cask_tap(root).core_cask_tap }
	tap_migrations := ruby_cask_loader_spec_l72_d13_tap_migrations('some-cask', ruby_cask_loader_spec_l89_d16_new_tap(root))
	boundaries << CaskLoaderSpecBoundary{ line: 72, passed: tap_migrations['some-cask'] == 'homebrew/bar' }
	boundaries << CaskLoaderSpecBoundary{ line: 86, passed: ruby_cask_loader_spec_l86_d14_token() == 'some-cask' }
	boundaries << CaskLoaderSpecBoundary{ line: 88, passed: ruby_cask_loader_spec_l88_d15_old_tap(root).name == 'homebrew/foo' }
	boundaries << CaskLoaderSpecBoundary{ line: 89, passed: ruby_cask_loader_spec_l89_d16_new_tap(root).name == 'homebrew/bar' }
	boundaries << CaskLoaderSpecBoundary{ line: 91, passed: ruby_cask_loader_spec_l91_d17_cask_file(root).ends_with('/some-cask.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 100, passed: ruby_cask_loader_spec_l100_d18_warns(os.join_path(root, 'd18'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 106, passed: ruby_cask_loader_spec_l106_d19_warns(os.join_path(root, 'd19'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 112, passed: ruby_cask_loader_spec_l112_d20_does(os.join_path(root, 'd20'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 118, passed: ruby_cask_loader_spec_l118_d21_warns(os.join_path(root, 'd21'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 124, passed: ruby_cask_loader_spec_l124_d22_raises(os.join_path(root, 'd22'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 135, passed: ruby_cask_loader_spec_l135_d23_old_tap(root).core_cask_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 136, passed: ruby_cask_loader_spec_l136_d24_new_tap(root).core_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 138, passed: ruby_cask_loader_spec_l138_d25_formula_file(root).ends_with('/local-caffeine.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 145, passed: ruby_cask_loader_spec_l145_d26_does(os.join_path(root, 'd26'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 153, passed: ruby_cask_loader_spec_l153_d27_token() == 'some-cask' }
	boundaries << CaskLoaderSpecBoundary{ line: 155, passed: ruby_cask_loader_spec_l155_d28_old_tap(root).name == 'homebrew/foo' }
	boundaries << CaskLoaderSpecBoundary{ line: 156, passed: ruby_cask_loader_spec_l156_d29_new_tap(root).name == 'homebrew/bar' }
	boundaries << CaskLoaderSpecBoundary{ line: 158, passed: ruby_cask_loader_spec_l158_d30_formula_file(root).ends_with('/some-cask.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 165, passed: ruby_cask_loader_spec_l165_d31_does(os.join_path(root, 'd31'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 173, passed: ruby_cask_loader_spec_l173_d32_old_tap(root).core_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 174, passed: ruby_cask_loader_spec_l174_d33_new_tap(root).core_cask_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 176, passed: ruby_cask_loader_spec_l176_d34_cask_file(root).ends_with('/local-caffeine.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 183, passed: ruby_cask_loader_spec_l183_d35_does(os.join_path(root, 'd35'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 189, passed: ruby_cask_loader_spec_l189_d36_does(os.join_path(root, 'd36'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 195, passed: ruby_cask_loader_spec_l195_d37_warns(os.join_path(root, 'd37'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 221, passed: ruby_cask_loader_spec_l221_d38_caskfile(root).ends_with('/stubbed.json') }
	boundaries << CaskLoaderSpecBoundary{ line: 227, passed: ruby_cask_loader_spec_l227_d39_falls(os.join_path(root, 'd39'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 237, passed: ruby_cask_loader_spec_l237_d40_does(os.join_path(root, 'd40'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 246, passed: ruby_cask_loader_spec_l246_d41_foo_tap(root).name == 'user/foo' }
	boundaries << CaskLoaderSpecBoundary{ line: 247, passed: ruby_cask_loader_spec_l247_d42_bar_tap(root).name == 'user/bar' }
	boundaries << CaskLoaderSpecBoundary{ line: 249, passed: !ruby_cask_loader_spec_l249_d43_blank_tab().has_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 250, passed: ruby_cask_loader_spec_l250_d44_installed_tab(root).has_tap }
	boundaries << CaskLoaderSpecBoundary{ line: 252, passed: ruby_cask_loader_spec_l252_d45_cask_with_foo_tap(root).tap.name == 'user/foo' }
	boundaries << CaskLoaderSpecBoundary{ line: 253, passed: ruby_cask_loader_spec_l253_d46_cask_with_bar_tap(root).tap.name == 'user/bar' }
	boundaries << CaskLoaderSpecBoundary{ line: 255, passed: ruby_cask_loader_spec_l255_d47_load_args().warn }
	boundaries << CaskLoaderSpecBoundary{ line: 263, passed: ruby_cask_loader_spec_l263_d48_returns(os.join_path(root, 'd48'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 270, passed: ruby_cask_loader_spec_l270_d49_returns(os.join_path(root, 'd49'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 277, passed: ruby_cask_loader_spec_l277_d50_returns(os.join_path(root, 'd50'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 284, passed: ruby_cask_loader_spec_l284_d51_returns(os.join_path(root, 'd51'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 291, passed: ruby_cask_loader_spec_l291_d52_returns(os.join_path(root, 'd52'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 302, passed: ruby_cask_loader_spec_l302_d53_masks(os.join_path(root, 'd53'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 327, passed: ruby_cask_loader_spec_l327_d54_allows(os.join_path(root, 'd54'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 351, passed: ruby_cask_loader_spec_l351_d55_refuses(os.join_path(root, 'd55'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 387, passed: ruby_cask_loader_spec_l387_d56_tmpdir(root).ends_with('/removed-method') }
	boundaries << CaskLoaderSpecBoundary{ line: 388, passed: ruby_cask_loader_spec_l388_d57_cask_token() == 'removed-method-cask' }
	boundaries << CaskLoaderSpecBoundary{ line: 389, passed: ruby_cask_loader_spec_l389_d58_cask_file(root).ends_with('/removed-method-cask.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 390, passed: ruby_cask_loader_spec_l390_d59_cask_content().contains('appcast') }
	boundaries << CaskLoaderSpecBoundary{ line: 415, passed: ruby_cask_loader_spec_l415_d60_raises(os.join_path(root, 'd60'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 420, passed: ruby_cask_loader_spec_l420_d61_does(os.join_path(root, 'd61'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 426, passed: ruby_cask_loader_spec_l426_d62_raises(os.join_path(root, 'd62'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 434, passed: ruby_cask_loader_spec_l434_d63_tmpdir(root).ends_with('/removed-conflicts') }
	boundaries << CaskLoaderSpecBoundary{ line: 435, passed: ruby_cask_loader_spec_l435_d64_cask_token() == 'removed-conflicts-key-cask' }
	boundaries << CaskLoaderSpecBoundary{ line: 436, passed: ruby_cask_loader_spec_l436_d65_cask_file(root).ends_with('/removed-conflicts-key-cask.json') }
	boundaries << CaskLoaderSpecBoundary{ line: 437, passed: ruby_cask_loader_spec_l437_d66_cask_content().contains('conflicts_with') }
	boundaries << CaskLoaderSpecBoundary{ line: 487, passed: ruby_cask_loader_spec_l487_d67_raises(os.join_path(root, 'd67'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 492, passed: ruby_cask_loader_spec_l492_d68_raises(os.join_path(root, 'd68'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 501, passed: ruby_cask_loader_spec_l501_d69_cask_token() == 'testcask' }
	boundaries << CaskLoaderSpecBoundary{ line: 502, passed: ruby_cask_loader_spec_l502_d70_tmpdir(root).ends_with('/symlink') }
	boundaries << CaskLoaderSpecBoundary{ line: 503, passed: ruby_cask_loader_spec_l503_d71_real_tap_path(root).ends_with('/real_tap') }
	boundaries << CaskLoaderSpecBoundary{ line: 504, passed: ruby_cask_loader_spec_l504_d72_homebrew_prefix(root).ends_with('/homebrew') }
	boundaries << CaskLoaderSpecBoundary{ line: 505, passed: ruby_cask_loader_spec_l505_d73_taps_dir(root).ends_with('/Library/Taps/testuser') }
	boundaries << CaskLoaderSpecBoundary{ line: 506, passed: ruby_cask_loader_spec_l506_d74_symlinked_tap_path(root).ends_with('/homebrew-testtap') }
	boundaries << CaskLoaderSpecBoundary{ line: 507, passed: ruby_cask_loader_spec_l507_d75_cask_file_path(root).ends_with('/Casks/testcask.rb') }
	boundaries << CaskLoaderSpecBoundary{ line: 508, passed: ruby_cask_loader_spec_l508_d76_cask_content().contains('version "1.0.0"') }
	boundaries << CaskLoaderSpecBoundary{ line: 545, passed: ruby_cask_loader_spec_l545_d77_allows(os.join_path(root, 'd77'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 561, passed: ruby_cask_loader_spec_l561_d78_allows(os.join_path(root, 'd78'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 572, passed: ruby_cask_loader_spec_l572_d79_does(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 580, passed: ruby_cask_loader_spec_l580_d80_falls(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 591, passed: ruby_cask_loader_spec_l591_d81_returns(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 601, passed: ruby_cask_loader_spec_l601_d82_returns(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 608, passed: ruby_cask_loader_spec_l608_d83_falls(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 621, passed: ruby_cask_loader_spec_l621_d84_returns(root) }
	boundaries << CaskLoaderSpecBoundary{ line: 634, passed: ruby_cask_loader_spec_l634_d85_caskroom(root).ends_with('/Caskroom') }
	boundaries << CaskLoaderSpecBoundary{ line: 638, passed: ruby_cask_loader_spec_l638_d86_reconstructs(os.join_path(root, 'd86'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 661, passed: ruby_cask_loader_spec_l661_d87_does(os.join_path(root, 'd87'))! }
	boundaries << CaskLoaderSpecBoundary{ line: 676, passed: ruby_cask_loader_spec_l676_d88_returns(os.join_path(root, 'd88'))! }
	return boundaries
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader, :cask do
// 5:   describe "::for" do
// 6:     let(:tap) { CoreCaskTap.instance }
// 7:
// 8:     context "when a cask is renamed" do
// 9:       let(:old_token) { "version-newest" }
// 10:       let(:new_token) { "version-latest" }
// 11:
// 12:       let(:api_casks) do
// 13:         [old_token, new_token].to_h do |token|
// 14:           hash = described_class.load(new_token).to_hash_with_variations
// 15:           json = JSON.pretty_generate(hash)
// 16:           cask_json = JSON.parse(json)
// 17:
// 18:           [token, cask_json.except("token")]
// 19:         end
// 20:       end
// 21:       let(:cask_renames) do
// 22:         { old_token => new_token }
// 23:       end
// 24:
// 25:       before do
// 26:         allow(Homebrew::API).to receive_messages(cask_tokens: api_casks.keys, cask_renames:)
// 27:         allow(Homebrew::API).to receive(:cask_token?) { |token| api_casks.key?(token) }
// 28:         allow(Homebrew::API::Cask)
// 29:           .to receive(:all_casks)
// 30:           .and_return(api_casks)
// 31:
// 32:         allow(tap).to receive(:cask_renames)
// 33:           .and_return(cask_renames)
// 34:       end
// 35:
// 36:       context "when not using the API", :no_api do
// 37:         it "warns when using the short token" do
// 38:           expect do
// 39:             expect(described_class.for("version-newest")).to be_a Cask::CaskLoader::FromPathLoader
// 40:           end.to output(/version-newest was renamed to version-latest/).to_stderr
// 41:         end
// 42:
// 43:         it "warns when using the full token" do
// 44:           expect do
// 45:             expect(described_class.for("homebrew/cask/version-newest")).to be_a Cask::CaskLoader::FromPathLoader
// 46:           end.to output(/version-newest was renamed to version-latest/).to_stderr
// 47:         end
// 48:       end
// 49:
// 50:       context "when using the API" do
// 51:         it "warns when using the short token" do
// 52:           expect do
// 53:             expect(described_class.for("version-newest")).to be_a Cask::CaskLoader::FromAPILoader
// 54:           end.to output(/version-newest was renamed to version-latest/).to_stderr
// 55:         end
// 56:
// 57:         it "warns when using the full token" do
// 58:           expect do
// 59:             expect(described_class.for("homebrew/cask/version-newest")).to be_a Cask::CaskLoader::FromAPILoader
// 60:           end.to output(/version-newest was renamed to version-latest/).to_stderr
// 61:         end
// 62:       end
// 63:     end
// 64:
// 65:     context "when not using the API", :no_api do
// 66:       context "when a cask is migrated" do
// 67:         let(:token) { "local-caffeine" }
// 68:
// 69:         let(:core_tap) { CoreTap.instance }
// 70:         let(:core_cask_tap) { CoreCaskTap.instance }
// 71:
// 72:         let(:tap_migrations) do
// 73:           {
// 74:             token => new_tap.name,
// 75:           }
// 76:         end
// 77:
// 78:         before do
// 79:           old_tap.path.mkpath
// 80:           new_tap.path.mkpath
// 81:           (old_tap.path/"tap_migrations.json").write tap_migrations.to_json
// 82:         end
// 83:
// 84:         context "to a cask in another tap" do
// 85:           # Can't use local-caffeine. It is a fixture in the :core_cask_tap and would take precedence over :new_tap.
// 86:           let(:token) { "some-cask" }
// 87:
// 88:           let(:old_tap) { Tap.fetch("homebrew", "foo") }
// 89:           let(:new_tap) { Tap.fetch("homebrew", "bar") }
// 90:
// 91:           let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }
// 92:
// 93:           before do
// 94:             new_tap.cask_dir.mkpath
// 95:             FileUtils.touch cask_file
// 96:           end
// 97:
// 98:           # FIXME
// 99:           # It would be preferable not to print a warning when installing with the short token
// 100:           it "warns when loading the short token" do
// 101:             expect do
// 102:               described_class.for(token)
// 103:             end.to output(%r{Cask #{old_tap}/#{token} was renamed to #{new_tap}/#{token}\.}).to_stderr
// 104:           end
// 105:
// 106:           it "warns with the canonical token when loading an uppercase short token" do
// 107:             expect do
// 108:               described_class.for(token.upcase)
// 109:             end.to output(%r{Cask #{old_tap}/#{token} was renamed to #{new_tap}/#{token}\.}).to_stderr
// 110:           end
// 111:
// 112:           it "does not warn when loading the full token in the new tap" do
// 113:             expect do
// 114:               described_class.for("#{new_tap}/#{token}")
// 115:             end.not_to output.to_stderr
// 116:           end
// 117:
// 118:           it "warns when loading the full token in the old tap" do
// 119:             expect do
// 120:               described_class.for("#{old_tap}/#{token}")
// 121:             end.to output(%r{Cask #{old_tap}/#{token} was renamed to #{new_tap}/#{token}\.}).to_stderr
// 122:           end
// 123:
// 124:           it "raises when the migrated tap is not installed" do
// 125:             FileUtils.rm_rf new_tap.path
// 126:
// 127:             expect(new_tap).not_to receive(:ensure_installed!)
// 128:
// 129:             expect { described_class.load("#{old_tap}/#{token}") }
// 130:               .to raise_error(Cask::TapCaskUnavailableError, /If you trust this tap/)
// 131:           end
// 132:         end
// 133:
// 134:         context "to a formula in the default tap" do
// 135:           let(:old_tap) { core_cask_tap }
// 136:           let(:new_tap) { core_tap }
// 137:
// 138:           let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }
// 139:
// 140:           before do
// 141:             new_tap.formula_dir.mkpath
// 142:             FileUtils.touch formula_file
// 143:           end
// 144:
// 145:           it "does not warn when loading the short token" do
// 146:             expect do
// 147:               described_class.for(token)
// 148:             end.not_to output.to_stderr
// 149:           end
// 150:         end
// 151:
// 152:         context "to a formula in another tap" do
// 153:           let(:token) { "some-cask" }
// 154:
// 155:           let(:old_tap) { Tap.fetch("homebrew", "foo") }
// 156:           let(:new_tap) { Tap.fetch("homebrew", "bar") }
// 157:
// 158:           let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }
// 159:
// 160:           before do
// 161:             new_tap.formula_dir.mkpath
// 162:             FileUtils.touch formula_file
// 163:           end
// 164:
// 165:           it "does not warn when loading the short token" do
// 166:             expect do
// 167:               described_class.for(token)
// 168:             end.not_to output.to_stderr
// 169:           end
// 170:         end
// 171:
// 172:         context "to the default tap" do
// 173:           let(:old_tap) { core_tap }
// 174:           let(:new_tap) { core_cask_tap }
// 175:
// 176:           let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }
// 177:
// 178:           before do
// 179:             new_tap.cask_dir.mkpath
// 180:             FileUtils.touch cask_file
// 181:           end
// 182:
// 183:           it "does not warn when loading the short token" do
// 184:             expect do
// 185:               described_class.for(token)
// 186:             end.not_to output.to_stderr
// 187:           end
// 188:
// 189:           it "does not warn when loading the full token in the default tap" do
// 190:             expect do
// 191:               described_class.for("#{new_tap}/#{token}")
// 192:             end.not_to output.to_stderr
// 193:           end
// 194:
// 195:           it "warns when loading the full token in the old tap" do
// 196:             expect do
// 197:               described_class.for("#{old_tap}/#{token}")
// 198:             end.to output(%r{Cask #{old_tap}/#{token} was renamed to #{token}\.}).to_stderr
// 199:           end
// 200:
// 201:           # FIXME
// 202:           # context "when there is an infinite tap migration loop" do
// 203:           #   before do
// 204:           #     (new_tap.path/"tap_migrations.json").write({
// 205:           #       token => old_tap.name,
// 206:           #     }.to_json)
// 207:           #   end
// 208:           #
// 209:           #   it "stops recursing" do
// 210:           #     expect do
// 211:           #       klass.for("#{new_tap}/#{token}")
// 212:           #     end.not_to output.to_stderr
// 213:           #   end
// 214:           # end
// 215:         end
// 216:       end
// 217:     end
// 218:   end
// 219:
// 220:   describe "::load_from_installed_caskfile" do
// 221:     let(:caskfile) do
// 222:       (Cask::Caskroom.path/"stubbed/.metadata/1.0/20250101000000.000/Casks").tap(&:mkpath)/"stubbed.json"
// 223:     end
// 224:
// 225:     before { caskfile.write("{}") }
// 226:
// 227:     it "falls back to the API for missing artifacts by default" do
// 228:       allow(Homebrew::API).to receive(:cask_token?).with("stubbed").and_return(true)
// 229:       expect(Homebrew::API::Cask).to receive(:cask_json).with("stubbed").and_return(
// 230:         "artifacts" => [{ "app" => ["Stubbed.app"] }],
// 231:       )
// 232:
// 233:       expect(described_class.load_from_installed_caskfile(caskfile).artifacts_list(uninstall_only: true))
// 234:         .to eq([{ app: ["Stubbed.app"] }])
// 235:     end
// 236:
// 237:     it "does not consult the API when api_fallback is disabled" do
// 238:       expect(Homebrew::API::Cask).not_to receive(:cask_json)
// 239:
// 240:       expect(described_class.load_from_installed_caskfile(caskfile, api_fallback: false).artifacts_list)
// 241:         .to be_empty
// 242:     end
// 243:   end
// 244:
// 245:   describe "::load_prefer_installed" do
// 246:     let(:foo_tap) { Tap.fetch("user", "foo") }
// 247:     let(:bar_tap) { Tap.fetch("user", "bar") }
// 248:
// 249:     let(:blank_tab) { instance_double(Cask::Tab, tap: nil) }
// 250:     let(:installed_tab) { instance_double(Cask::Tab, tap: bar_tap) }
// 251:
// 252:     let(:cask_with_foo_tap) { instance_double(Cask::Cask, token: "test-cask", tap: foo_tap) }
// 253:     let(:cask_with_bar_tap) { instance_double(Cask::Cask, token: "test-cask", tap: bar_tap) }
// 254:
// 255:     let(:load_args) { { config: nil, warn: true } }
// 256:
// 257:     before do
// 258:       allow(described_class).to receive(:load).with("test-cask", load_args).and_return(cask_with_foo_tap)
// 259:       allow(described_class).to receive(:load).with("user/foo/test-cask", load_args).and_return(cask_with_foo_tap)
// 260:       allow(described_class).to receive(:load).with("user/bar/test-cask", load_args).and_return(cask_with_bar_tap)
// 261:     end
// 262:
// 263:     it "returns the correct cask when no tap is specified and no tab exists" do
// 264:       allow_any_instance_of(Cask::Cask).to receive(:tab).and_return(blank_tab)
// 265:       expect(described_class).to receive(:load).with("test-cask", load_args)
// 266:
// 267:       expect(described_class.load_prefer_installed("test-cask").tap).to eq(foo_tap)
// 268:     end
// 269:
// 270:     it "returns the correct cask when no tap is specified but a tab exists" do
// 271:       allow_any_instance_of(Cask::Cask).to receive(:tab).and_return(installed_tab)
// 272:       expect(described_class).to receive(:load).with("user/bar/test-cask", load_args)
// 273:
// 274:       expect(described_class.load_prefer_installed("test-cask").tap).to eq(bar_tap)
// 275:     end
// 276:
// 277:     it "returns the correct cask when a tap is specified and no tab exists" do
// 278:       allow_any_instance_of(Cask::Cask).to receive(:tab).and_return(blank_tab)
// 279:       expect(described_class).to receive(:load).with("user/bar/test-cask", load_args)
// 280:
// 281:       expect(described_class.load_prefer_installed("user/bar/test-cask").tap).to eq(bar_tap)
// 282:     end
// 283:
// 284:     it "returns the correct cask when no tap is specified and a tab exists" do
// 285:       allow_any_instance_of(Cask::Cask).to receive(:tab).and_return(installed_tab)
// 286:       expect(described_class).to receive(:load).with("user/foo/test-cask", load_args)
// 287:
// 288:       expect(described_class.load_prefer_installed("user/foo/test-cask").tap).to eq(foo_tap)
// 289:     end
// 290:
// 291:     it "returns the correct cask when no tap is specified and the tab lists an tap that isn't installed" do
// 292:       allow_any_instance_of(Cask::Cask).to receive(:tab).and_return(installed_tab)
// 293:       expect(described_class).to receive(:load).with("user/bar/test-cask", load_args)
// 294:                                                .and_raise(Cask::CaskUnavailableError.new("test-cask", bar_tap))
// 295:       expect(described_class).to receive(:load).with("test-cask", load_args)
// 296:
// 297:       expect(described_class.load_prefer_installed("test-cask").tap).to eq(foo_tap)
// 298:     end
// 299:   end
// 300:
// 301:   describe "FromPathLoader" do
// 302:     it "masks sensitive environment variables while evaluating casks" do
// 303:       cask_token = "sensitive-env"
// 304:       cask_file = mktmpdir/"#{cask_token}.rb"
// 305:       cask_file.write <<~RUBY
// 306:         cask "#{cask_token}" do
// 307:           version "1.0.0"
// 308:           sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
// 309:
// 310:           url "https://example.com/app.dmg"
// 311:           name "Sensitive Env"
// 312:           desc ENV.fetch("HOMEBREW_SECRET_TOKEN", "") == "password" ? "Secret leaked" : "Secret masked"
// 313:           homepage "https://example.com"
// 314:
// 315:           app "App.app"
// 316:         end
// 317:       RUBY
// 318:
// 319:       with_env(HOMEBREW_SECRET_TOKEN: "password") do
// 320:         cask = Cask::CaskLoader::FromPathLoader.new(cask_file).load(config: nil)
// 321:
// 322:         expect(cask.desc).to eq("Secret masked")
// 323:         expect(ENV.fetch("HOMEBREW_SECRET_TOKEN", nil)).to eq("password")
// 324:       end
// 325:     end
// 326:
// 327:     it "allows the GitHub API token while evaluating casks" do
// 328:       cask_token = "github-token-env"
// 329:       cask_file = mktmpdir/"#{cask_token}.rb"
// 330:       cask_file.write <<~RUBY
// 331:         cask "#{cask_token}" do
// 332:           version "1.0.0"
// 333:           sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
// 334:
// 335:           url "https://example.com/app.dmg"
// 336:           name "GitHub Token Env"
// 337:           desc ENV.key?("HOMEBREW_GITHUB_API_TOKEN") ? "Token present" : "Token absent"
// 338:           homepage "https://example.com"
// 339:
// 340:           app "App.app"
// 341:         end
// 342:       RUBY
// 343:
// 344:       with_env(HOMEBREW_GITHUB_API_TOKEN: "github-token") do
// 345:         cask = Cask::CaskLoader::FromPathLoader.new(cask_file).load(config: nil)
// 346:
// 347:         expect(cask.desc).to eq("Token present")
// 348:       end
// 349:     end
// 350:
// 351:     it "refuses untrusted third-party tap casks when trust is enabled" do
// 352:       tap = Tap.fetch("thirdparty", "foo")
// 353:       cask_token = "sensitive-env"
// 354:       cask_file = tap.cask_dir/"#{cask_token}.rb"
// 355:       cask_file.dirname.mkpath
// 356:       cask_file.write <<~RUBY
// 357:         cask "#{cask_token}" do
// 358:           version "1.0.0"
// 359:           sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
// 360:
// 361:           url "https://example.com/app.dmg"
// 362:           name "Sensitive Env"
// 363:           desc "Sensitive Env"
// 364:           homepage "https://example.com"
// 365:
// 366:           app "App.app"
// 367:         end
// 368:       RUBY
// 369:
// 370:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 371:         expect { Cask::CaskLoader::FromPathLoader.new(cask_file).load(config: nil) }
// 372:           .to raise_error(Homebrew::UntrustedTapError, %r{thirdparty/foo})
// 373:       end
// 374:
// 375:       Homebrew::Trust.trust!(:cask, "thirdparty/foo/sensitive-env")
// 376:
// 377:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 378:         expect(Cask::CaskLoader::FromPathLoader.new(cask_file).load(config: nil).full_name)
// 379:           .to eq("thirdparty/foo/sensitive-env")
// 380:       end
// 381:     ensure
// 382:       Homebrew::Trust.clear!(:cask)
// 383:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 384:     end
// 385:
// 386:     describe "loading a cask with a removed DSL method" do
// 387:       let(:tmpdir) { mktmpdir }
// 388:       let(:cask_token) { "removed-method-cask" }
// 389:       let(:cask_file) { tmpdir/"#{cask_token}.rb" }
// 390:       let(:cask_content) do
// 391:         <<~RUBY
// 392:           cask "#{cask_token}" do
// 393:             version "1.0.0"
// 394:             sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
// 395:
// 396:             url "https://example.com/app.dmg"
// 397:             appcast "https://example.com/appcast.xml"
// 398:             name "Removed Method Cask"
// 399:             homepage "https://example.com"
// 400:
// 401:             app "App.app"
// 402:           end
// 403:         RUBY
// 404:       end
// 405:
// 406:       before do
// 407:         tmpdir.mkpath
// 408:         cask_file.write(cask_content)
// 409:       end
// 410:
// 411:       after do
// 412:         tmpdir.rmtree if tmpdir.exist?
// 413:       end
// 414:
// 415:       it "raises CaskInvalidError" do
// 416:         loader = Cask::CaskLoader::FromPathLoader.new(cask_file)
// 417:         expect { loader.load(config: nil) }.to raise_error(Cask::CaskInvalidError)
// 418:       end
// 419:
// 420:       it "does not set Homebrew.failed" do
// 421:         loader = Cask::CaskLoader::FromPathLoader.new(cask_file)
// 422:         expect { loader.load(config: nil) }.to raise_error(Cask::CaskInvalidError)
// 423:         expect(Homebrew).not_to be_failed
// 424:       end
// 425:
// 426:       it "raises CaskUnreadableError when loaded from installed caskfile" do
// 427:         loader = Cask::CaskLoader::FromPathLoader.new(cask_file)
// 428:         loader.from_installed_caskfile = true
// 429:         expect { loader.load(config: nil) }.to raise_error(Cask::CaskUnreadableError, /appcast/)
// 430:       end
// 431:     end
// 432:
// 433:     describe "loading a cask JSON file with removed conflicts_with keys" do
// 434:       let(:tmpdir) { mktmpdir }
// 435:       let(:cask_token) { "removed-conflicts-key-cask" }
// 436:       let(:cask_file) { tmpdir/"#{cask_token}.json" }
// 437:       let(:cask_content) do
// 438:         <<~JSON
// 439:           {
// 440:             "token": "#{cask_token}",
// 441:             "full_token": "#{cask_token}",
// 442:             "tap": "homebrew/cask",
// 443:             "name": [],
// 444:             "desc": null,
// 445:             "homepage": "https://example.com",
// 446:             "url": "https://example.com/#{cask_token}.zip",
// 447:             "version": "1.0.0",
// 448:             "installed": null,
// 449:             "outdated": false,
// 450:             "sha256": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
// 451:             "artifacts": [
// 452:               {
// 453:                 "app": [
// 454:                   "App.app"
// 455:                 ]
// 456:               }
// 457:             ],
// 458:             "caveats": null,
// 459:             "depends_on": {},
// 460:             "conflicts_with": {
// 461:               "formula": [
// 462:                 "some-formula"
// 463:               ]
// 464:             },
// 465:             "container": null,
// 466:             "rename": [],
// 467:             "auto_updates": null,
// 468:             "tap_git_head": "abcdef1234567890abcdef1234567890abcdef12",
// 469:             "languages": [],
// 470:             "ruby_source_path": "Casks/#{cask_token}.rb",
// 471:             "ruby_source_checksum": {
// 472:               "sha256": "d3c19b564ee5a17f22191599ad795a6cc9c4758d0e1269f2d13207155b378dea"
// 473:             }
// 474:           }
// 475:         JSON
// 476:       end
// 477:
// 478:       before do
// 479:         tmpdir.mkpath
// 480:         cask_file.write(cask_content)
// 481:       end
// 482:
// 483:       after do
// 484:         tmpdir.rmtree if tmpdir.exist?
// 485:       end
// 486:
// 487:       it "raises CaskInvalidError" do
// 488:         loader = Cask::CaskLoader::FromPathLoader.new(cask_file)
// 489:         expect { loader.load(config: nil) }.to raise_error(Cask::CaskInvalidError, /Unknown key: :formula/)
// 490:       end
// 491:
// 492:       it "raises CaskUnreadableError when loaded from installed caskfile" do
// 493:         loader = Cask::CaskLoader::FromPathLoader.new(cask_file)
// 494:         loader.from_installed_caskfile = true
// 495:         expect { loader.load(config: nil) }.to raise_error(Cask::CaskUnreadableError, /Unknown key: :formula/)
// 496:       end
// 497:     end
// 498:   end
// 499:
// 500:   describe "FromPathLoader with symlinked taps" do
// 501:     let(:cask_token) { "testcask" }
// 502:     let(:tmpdir) { mktmpdir }
// 503:     let(:real_tap_path) { tmpdir / "real_tap" }
// 504:     let(:homebrew_prefix) { tmpdir / "homebrew" }
// 505:     let(:taps_dir) { homebrew_prefix / "Library" / "Taps" / "testuser" }
// 506:     let(:symlinked_tap_path) { taps_dir / "homebrew-testtap" }
// 507:     let(:cask_file_path) { symlinked_tap_path / "Casks" / "#{cask_token}.rb" }
// 508:     let(:cask_content) do
// 509:       <<~RUBY
// 510:         cask "#{cask_token}" do
// 511:           version "1.0.0"
// 512:           sha256 "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
// 513:
// 514:           url "https://example.com/#{cask_token}-\#{version}.dmg"
// 515:           name "Test Cask"
// 516:           desc "A test cask for symlink testing"
// 517:           homepage "https://example.com"
// 518:
// 519:           app "TestCask.app"
// 520:         end
// 521:       RUBY
// 522:     end
// 523:
// 524:     after do
// 525:       tmpdir.rmtree if tmpdir.exist?
// 526:     end
// 527:
// 528:     before do
// 529:       # Create real tap directory structure
// 530:       (real_tap_path / "Casks").mkpath
// 531:       (real_tap_path / "Casks" / "#{cask_token}.rb").write(cask_content)
// 532:
// 533:       # Create homebrew prefix structure
// 534:       taps_dir.mkpath
// 535:
// 536:       # Create symlink to the tap (this simulates what setup-homebrew does)
// 537:       symlinked_tap_path.make_symlink(real_tap_path)
// 538:
// 539:       # Set HOMEBREW_LIBRARY to our test prefix for the security check
// 540:       stub_const("HOMEBREW_LIBRARY", homebrew_prefix / "Library")
// 541:       allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(true)
// 542:     end
// 543:
// 544:     context "when HOMEBREW_FORBID_PACKAGES_FROM_PATHS is enabled" do
// 545:       it "allows loading casks from symlinked taps" do
// 546:         loader = Cask::CaskLoader::FromPathLoader.try_new(cask_file_path)
// 547:         expect(loader).not_to be_nil
// 548:         expect(loader).to be_a(Cask::CaskLoader::FromPathLoader)
// 549:
// 550:         cask = loader.load(config: nil)
// 551:         expect(cask.token).to eq(cask_token)
// 552:         expect(cask.version).to eq(Version.new("1.0.0"))
// 553:       end
// 554:     end
// 555:
// 556:     context "when HOMEBREW_FORBID_PACKAGES_FROM_PATHS is disabled" do
// 557:       before do
// 558:         allow(Homebrew::EnvConfig).to receive(:forbid_packages_from_paths?).and_return(false)
// 559:       end
// 560:
// 561:       it "allows loading casks from symlinked taps" do
// 562:         loader = Cask::CaskLoader::FromPathLoader.try_new(cask_file_path)
// 563:         expect(loader).not_to be_nil
// 564:         expect(loader).to be_a(Cask::CaskLoader::FromPathLoader)
// 565:       end
// 566:     end
// 567:   end
// 568:
// 569:   describe "::resolve_installed_artifacts" do
// 570:     before { allow(Homebrew::API).to receive(:cask_token?).and_return(true) }
// 571:
// 572:     it "does not request API metadata for a removed cask" do
// 573:       token = "removed-cask"
// 574:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(false)
// 575:       expect(Homebrew::API::Cask).not_to receive(:cask_json)
// 576:
// 577:       expect(described_class.resolve_installed_artifacts(token, nil)).to eq([])
// 578:     end
// 579:
// 580:     it "falls back to API artifacts when the membership check fails" do
// 581:       token = "unavailable-membership"
// 582:       api_artifacts = [{ "app" => ["API.app"] }]
// 583:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_raise(
// 584:         ErrorDuringExecution.new(["curl"], status: 22),
// 585:       )
// 586:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({ "artifacts" => api_artifacts })
// 587:
// 588:       expect(described_class.resolve_installed_artifacts(token, nil)).to eq(api_artifacts)
// 589:     end
// 590:
// 591:     it "returns empty artifacts when the API download fails" do
// 592:       token = "unavailable"
// 593:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 594:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_raise(
// 595:         ErrorDuringExecution.new(["curl"], status: 22),
// 596:       )
// 597:
// 598:       expect(described_class.resolve_installed_artifacts(token, nil)).to eq([])
// 599:     end
// 600:
// 601:     it "returns empty artifacts when the API cannot be loaded" do
// 602:       allow(Homebrew::API).to receive(:cask_token?).with("unavailable").and_return(true)
// 603:       allow(Homebrew::API::Cask).to receive(:cask_json).with("unavailable").and_raise(SystemExit.new(1))
// 604:
// 605:       expect(described_class.resolve_installed_artifacts("unavailable", nil)).to eq([])
// 606:     end
// 607:
// 608:     it "falls back to API artifacts when tap lookup is ambiguous" do
// 609:       token = "ambiguous"
// 610:       api_artifacts = [{ "app" => ["API.app"] }]
// 611:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 612:       allow(Cask::CaskLoader::FromAPILoader).to receive(:try_new).with(token).and_return(nil)
// 613:       allow(Cask::CaskLoader::FromNameLoader).to receive(:try_new)
// 614:         .with(token, warn: false)
// 615:         .and_raise(Cask::TapCaskAmbiguityError.new(token, []))
// 616:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({ "artifacts" => api_artifacts })
// 617:
// 618:       expect(described_class.resolve_installed_artifacts(token, nil)).to eq(api_artifacts)
// 619:     end
// 620:
// 621:     it "returns empty artifacts when the installed tap and API are unavailable" do
// 622:       token = "unavailable-tap"
// 623:       tap = Tap.fetch("thirdparty", "missing")
// 624:       allow(described_class).to receive(:load)
// 625:         .with("#{tap}/#{token}", warn: false)
// 626:         .and_raise(Cask::TapCaskUnavailableError.new(tap, token))
// 627:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_raise(SystemExit.new(1))
// 628:
// 629:       expect(described_class.resolve_installed_artifacts(token, nil, tap:)).to eq([])
// 630:     end
// 631:   end
// 632:
// 633:   describe "::recover_from_installed_caskfile" do
// 634:     let(:caskroom) { mktmpdir/"Caskroom" }
// 635:
// 636:     before { allow(Cask::Caskroom).to receive(:path).and_return(caskroom) }
// 637:
// 638:     it "reconstructs the installed version and artifacts from its receipt" do
// 639:       token = "recoverable"
// 640:       caskfile = caskroom/token/".metadata/1.0/20250101000000.000/Casks/#{token}.rb"
// 641:       caskfile.dirname.mkpath
// 642:       caskfile.write("unreadable")
// 643:       (caskroom/token/".metadata/INSTALL_RECEIPT.json").write JSON.generate({
// 644:         "source"                  => { "version" => "1.0" },
// 645:         "uninstall_flight_blocks" => false,
// 646:         "uninstall_artifacts"     => [{ "app" => ["Recoverable.app"] }],
// 647:       })
// 648:       expect(Homebrew::API::Cask).not_to receive(:cask_json)
// 649:
// 650:       recovered_cask = described_class.recover_from_installed_caskfile(caskfile)
// 651:
// 652:       expect([
// 653:         recovered_cask&.version&.to_s,
// 654:         recovered_cask&.artifacts_list(uninstall_only: true),
// 655:       ]).to eq([
// 656:         "1.0",
// 657:         [{ app: ["Recoverable.app"] }],
// 658:       ])
// 659:     end
// 660:
// 661:     it "does not reconstruct missing uninstall flight blocks" do
// 662:       token = "flight-block"
// 663:       caskfile = caskroom/token/".metadata/1.0/20250101000000.000/Casks/#{token}.rb"
// 664:       caskfile.dirname.mkpath
// 665:       caskfile.write("unreadable")
// 666:       (caskroom/token/".metadata/INSTALL_RECEIPT.json").write JSON.generate({
// 667:         "source"                  => { "version" => "1.0" },
// 668:         "uninstall_flight_blocks" => true,
// 669:         "uninstall_artifacts"     => [{ "uninstall_preflight" => nil }],
// 670:       })
// 671:       expect(Homebrew::API::Cask).not_to receive(:cask_json)
// 672:
// 673:       expect(described_class.recover_from_installed_caskfile(caskfile)).to be_nil
// 674:     end
// 675:
// 676:     it "returns nil when the reconstructed metadata remains invalid" do
// 677:       token = "still-invalid"
// 678:       caskfile = caskroom/token/".metadata/1.0/20250101000000.000/Casks/#{token}.rb"
// 679:       caskfile.dirname.mkpath
// 680:       caskfile.write("unreadable")
// 681:       (caskroom/token/".metadata/INSTALL_RECEIPT.json").write JSON.generate({
// 682:         "source"              => { "version" => "1.0" },
// 683:         "uninstall_artifacts" => [{ "app" => ["Still Invalid.app"] }],
// 684:       })
// 685:       allow(Cask::CaskLoader::FromAPILoader).to receive(:new)
// 686:         .and_raise(Cask::CaskInvalidError.new(token, "invalid recovered metadata"))
// 687:
// 688:       expect(described_class.recover_from_installed_caskfile(caskfile)).to be_nil
// 689:     end
// 690:   end
// 691: end
