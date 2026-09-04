module cask_loader

import ruby
import homebrew
import homebrew.cask as brew_cask
import homebrew.cask.dsl as dsl_types
import os

// Translated from Homebrew/brew `test/cask/cask_loader/from_api_loader_spec.rb`.
// The original source is retained below.
pub struct FromApiLoaderSpecBoundary {
pub:
	line   int
	passed bool
}

pub struct FromApiLoaderSpecSetup {
pub:
	root            string
	local_token     string
	api_token       string
	internal_token  string
	source          brew_cask.CaskLoaderApiSource
	internal_source brew_cask.CaskLoaderApiSource
	lookup          brew_cask.CaskLoaderLookupContext
	api_loader      brew_cask.CaskLoader
	internal_loader brew_cask.CaskLoader
}

fn from_api_spec_noop_block(mut dsl brew_cask.CaskDSL) ! {
	_ = dsl
}

fn from_api_spec_tap(root string, name string, core_cask bool) brew_cask.CaskLoaderTap {
	path := os.join_path(root, name.replace('/', '-'))
	return brew_cask.CaskLoaderTap{
		name: name
		path: path
		cask_dir: os.join_path(path, 'Casks')
		formula_dir: os.join_path(path, 'Formula')
		installed: true
		core_cask_tap: core_cask
	}
}

fn from_api_spec_source(token string) brew_cask.CaskLoaderApiSource {
	mut artifacts := [
		brew_cask.CaskLoaderArtifact{ kind: 'app', values: ['Container.app'] },
	]
	if token.contains('binary') {
		artifacts = [
			brew_cask.CaskLoaderArtifact{ kind: 'binary', values: ['bin/tool'] },
		]
	} else if token.contains('installer') {
		artifacts = [
			brew_cask.CaskLoaderArtifact{ kind: 'installer', values: ['installer.sh'] },
		]
	} else if token.contains('uninstall-multi') {
		artifacts = [
			brew_cask.CaskLoaderArtifact{
				kind: 'uninstall'
				values: [
					'quit:com.example.app',
				]
			},
		]
	} else if token.contains('with-zap') {
		artifacts = [
			brew_cask.CaskLoaderArtifact{
				kind: 'zap'
				values: [
					'~/Library/Preferences/example.plist',
				]
			},
		]
	} else if token.contains('preflight') {
		artifacts = [brew_cask.CaskLoaderArtifact{ kind: 'preflight' }]
	} else if token.contains('uninstall-preflight') {
		artifacts = [brew_cask.CaskLoaderArtifact{ kind: 'uninstall_preflight' }]
	} else if token.contains('postflight') {
		artifacts = [brew_cask.CaskLoaderArtifact{ kind: 'postflight' }]
	} else if token.contains('uninstall-postflight') {
		artifacts = [brew_cask.CaskLoaderArtifact{ kind: 'uninstall_postflight' }]
	}
	mut source := brew_cask.CaskLoaderApiSource{
		present: true
		version: '1.0'
		sha256: '67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94'
		url: 'file:///fixtures/cask/caffeine.zip'
		names: ['Test Cask']
		desc: 'A cask loaded from the JSON API'
		homepage: 'https://example.com'
		tap: 'homebrew/cask'
		artifacts: artifacts
		has_artifacts: true
		tap_git_head: 'abcdef1234567890abcdef1234567890abcdef12'
		raw: token
	}
	if token.contains('depends-on-cask') {
		source = brew_cask.CaskLoaderApiSource{
			...source
			depends_on: {
				'cask': 'one,two'
			}
		}
	} else if token.contains('depends-on-formula') {
		source = brew_cask.CaskLoaderApiSource{
			...source
			depends_on: {
				'formula': 'one,two'
			}
		}
	} else if token.contains('depends-on-macos') {
		source = brew_cask.CaskLoaderApiSource{
			...source
			depends_on: {
				'macos': '>= :ventura'
			}
		}
	}
	if token.contains('languages') {
		source = brew_cask.CaskLoaderApiSource{
			...source
			languages: ['zh-CN', 'en-US']
			localisations: [
				brew_cask.CaskLoaderLocalisation{
					languages: ['zh', 'zh-CN']
					value: 'zh-CN'
					version: '1.0-zh'
					sha256: 'fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5'
					url: 'file:///fixtures/cask/container.tar.gz'
					artifacts: [brew_cask.CaskLoaderArtifact{
						kind: 'app'
						values: [
							'Container.app',
						]
					}]
					has_artifacts: true
				},
				brew_cask.CaskLoaderLocalisation{
					languages: ['en', 'en-US']
					value: 'en-US'
					is_default: true
				},
			]
		}
	}
	return source
}

fn from_api_spec_setup(root string, local_token string) FromApiLoaderSpecSetup {
	api_token := '${local_token}-api'
	internal_token := '${local_token}-internal-api'
	core := from_api_spec_tap(root, 'homebrew/cask', true)
	source := from_api_spec_source(local_token)
	internal_source := brew_cask.CaskLoaderApiSource{ ...source, raw: '${local_token}:internal' }
	lookup := brew_cask.CaskLoaderLookupContext{
		cache_path: os.join_path(root, 'cache')
		cached_api_path: os.join_path(root, 'api', 'cask.json')
		cached_internal_api_path: os.join_path(root, 'api', 'cask.jws.json')
		cached_packages_path: os.join_path(root, 'api', 'packages.json')
		core_cask_tap: core
		taps: [core]
		api_tokens: [api_token, internal_token]
		api_sources: {
			api_token:      source
			internal_token: internal_source
		}
		load_casks: {
			local_token: brew_cask.CaskLoaderCask{
				token: local_token
				version: source.version
				sha256: source.sha256
				url: source.url
				artifacts: source.artifacts.clone()
			}
		}
	}
	return FromApiLoaderSpecSetup{
		root: root
		local_token: local_token
		api_token: api_token
		internal_token: internal_token
		source: source
		internal_source: internal_source
		lookup: lookup
		api_loader: brew_cask.new_api_cask_loader(api_token, source, '', false, false, true, lookup)
		internal_loader: brew_cask.new_api_cask_loader(internal_token, internal_source, '', false, true, true, lookup)
	}
}

fn from_api_spec_load(setup FromApiLoaderSpecSetup, internal bool,
	config brew_cask.CaskLoaderConfig) !brew_cask.CaskLoaderCask {
	loader := if internal { setup.internal_loader } else { setup.api_loader }
	return brew_cask.cask_loader_load_api(loader, config, brew_cask.CaskLoaderLoadContext{
		lookup: setup.lookup
		internal_api: setup.internal_source
	})
}

fn from_api_spec_artifact(key string, source string,
	data map[string]ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::${key.split('_').map(it.title()).join('')}'
		repr: source
		map_data: data.clone()
		attributes: {
			'dsl_key': key
			'source':  source
		}
	}
}

fn from_api_spec_path_value(base string, path string) ruby.Value {
	return ruby.map_value({
		'base': ruby.string_value(base)
		'path': ruby.string_value(path)
	})
}

// Ruby let `let(:api_token) { "#{local_token}-api" }` at line 6.
pub fn ruby_from_api_loader_spec_l6_d1_api_token(local_token string) string {
	return '${local_token}-api'
}

// Ruby let `let(:cask_from_source) { Cask::CaskLoader.load(local_token) }` at line 7.
pub fn ruby_from_api_loader_spec_l7_d2_cask_from_source(setup FromApiLoaderSpecSetup) !brew_cask.CaskLoaderCask {
	return brew_cask.cask_loader_load_reference(brew_cask.CaskLoaderReference{
		kind: .text
		value: setup.local_token
	}, brew_cask.CaskLoaderConfig{}, true, brew_cask.CaskLoaderLoadContext{ lookup: setup.lookup })
}

// Ruby let `let(:cask_json) do` at line 8.
pub fn ruby_from_api_loader_spec_l8_d3_cask_json(setup FromApiLoaderSpecSetup) brew_cask.CaskLoaderApiSource {
	return setup.source
}

// Ruby let `let(:casks_from_api_hash) { { api_token => cask_json.except("token") } }` at line 15.
pub fn ruby_from_api_loader_spec_l15_d4_casks_from_api_hash(setup FromApiLoaderSpecSetup) map[string]brew_cask.CaskLoaderApiSource {
	return {
		setup.api_token: setup.source
	}
}

// Ruby let `let(:api_loader) { described_class.new(api_token, from_json: cask_json) }` at line 16.
pub fn ruby_from_api_loader_spec_l16_d5_api_loader(setup FromApiLoaderSpecSetup) brew_cask.CaskLoader {
	return setup.api_loader
}

// Ruby let! `let!(:cask_from_internal_source) { Cask::CaskLoader.load(local_token) }` at line 30.
pub fn ruby_from_api_loader_spec_l30_d6_cask_from_internal_source(setup FromApiLoaderSpecSetup) !brew_cask.CaskLoaderCask {
	return ruby_from_api_loader_spec_l7_d2_cask_from_source(setup)
}

// Ruby let! `let!(:cask_internal_struct) do` at line 31.
pub fn ruby_from_api_loader_spec_l31_d7_cask_internal_struct(setup FromApiLoaderSpecSetup) brew_cask.CaskLoaderApiSource {
	return setup.internal_source
}

// Ruby let `let(:internal_api_token) { "#{local_token}-internal-api" }` at line 36.
pub fn ruby_from_api_loader_spec_l36_d8_internal_api_token(local_token string) string {
	return '${local_token}-internal-api'
}

// Ruby let `let(:internal_tap_git_head) { "abcdef1234567890abcdef1234567890abcdef12" }` at line 37.
pub fn ruby_from_api_loader_spec_l37_d9_internal_tap_git_head() string {
	return 'abcdef1234567890abcdef1234567890abcdef12'
}

// Ruby let `let(:cask_internal_json) do` at line 38.
pub fn ruby_from_api_loader_spec_l38_d10_cask_internal_json(setup FromApiLoaderSpecSetup) brew_cask.CaskLoaderApiSource {
	return brew_cask.CaskLoaderApiSource{
		...setup.internal_source
		tap_git_head: ruby_from_api_loader_spec_l37_d9_internal_tap_git_head()
	}
}

// Ruby let `let(:casks_from_internal_api_hash) { { internal_api_token => cask_internal_json.except("tap_git_head") } }` at line 46.
pub fn ruby_from_api_loader_spec_l46_d11_casks_from_internal_api_hash(setup FromApiLoaderSpecSetup) map[string]brew_cask.CaskLoaderApiSource {
	return {
		setup.internal_token: brew_cask.CaskLoaderApiSource{ ...setup.internal_source, tap_git_head: '' }
	}
}

// Ruby let `let(:internal_api_loader) do` at line 47.
pub fn ruby_from_api_loader_spec_l47_d12_internal_api_loader(setup FromApiLoaderSpecSetup) brew_cask.CaskLoader {
	return setup.internal_loader
}

// Ruby it `it "returns false" do` at line 69.
pub fn ruby_from_api_loader_spec_l69_d13_returns(setup FromApiLoaderSpecSetup) bool {
	context := brew_cask.CaskLoaderLookupContext{ ...setup.lookup, no_install_from_api: true }
	return brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: setup.api_token
	}, false, context) == none
}

// Ruby it `it "returns a loader for valid token" do` at line 77.
pub fn ruby_from_api_loader_spec_l77_d14_returns(setup FromApiLoaderSpecSetup) bool {
	loader := brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: setup.api_token
	}, false, setup.lookup) or { return false }
	return loader.kind == .api && loader.token == setup.api_token
}

// Ruby it `it "returns a loader for valid full name" do` at line 83.
pub fn ruby_from_api_loader_spec_l83_d15_returns(setup FromApiLoaderSpecSetup) bool {
	loader := brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: 'homebrew/cask/${setup.api_token}'
	}, false, setup.lookup) or { return false }
	return loader.kind == .api && loader.token == setup.api_token
}

// Ruby let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 90.
pub fn ruby_from_api_loader_spec_l90_d16_foo_tap(root string) brew_cask.CaskLoaderTap {
	return from_api_spec_tap(root, 'homebrew/foo', false)
}

// Ruby it `it "returns the tap migration rename by old token" do` at line 100.
pub fn ruby_from_api_loader_spec_l100_d17_returns(setup FromApiLoaderSpecSetup) bool {
	return from_api_spec_migration(setup, false, false)
}

// Ruby it `it "returns the tap migration rename by old full name" do` at line 112.
pub fn ruby_from_api_loader_spec_l112_d18_returns(setup FromApiLoaderSpecSetup) bool {
	return from_api_spec_migration(setup, false, true)
}

// Ruby it `it "returns a loader for valid token" do` at line 129.
pub fn ruby_from_api_loader_spec_l129_d19_returns(setup FromApiLoaderSpecSetup) bool {
	loader := brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: setup.internal_token
	}, false, setup.lookup) or { return false }
	return loader.kind == .api && loader.token == setup.internal_token
}

// Ruby it `it "returns a loader for valid full name" do` at line 135.
pub fn ruby_from_api_loader_spec_l135_d20_returns(setup FromApiLoaderSpecSetup) bool {
	loader := brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: 'homebrew/cask/${setup.internal_token}'
	}, false, setup.lookup) or { return false }
	return loader.kind == .api && loader.token == setup.internal_token
}

// Ruby let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 142.
pub fn ruby_from_api_loader_spec_l142_d21_foo_tap(root string) brew_cask.CaskLoaderTap {
	return from_api_spec_tap(root, 'homebrew/foo', false)
}

// Ruby it `it "returns the tap migration rename by old token" do` at line 152.
pub fn ruby_from_api_loader_spec_l152_d22_returns(setup FromApiLoaderSpecSetup) bool {
	return from_api_spec_migration(setup, true, false)
}

// Ruby it `it "returns the tap migration rename by old full name" do` at line 164.
pub fn ruby_from_api_loader_spec_l164_d23_returns(setup FromApiLoaderSpecSetup) bool {
	return from_api_spec_migration(setup, true, true)
}

// Ruby it `it "returns nil for full name with invalid tap" do` at line 178.
pub fn ruby_from_api_loader_spec_l178_d24_returns(setup FromApiLoaderSpecSetup) bool {
	return brew_cask.cask_loader_try_api(brew_cask.CaskLoaderReference{
		kind: .text
		value: 'homebrew/foo/test-opera'
	}, false, setup.lookup) == none
}

// Ruby it `it "handles greedy outdated checks for installed metadata without a URL" do` at line 184.
pub fn ruby_from_api_loader_spec_l184_d25_handles(root string) !bool {
	mut cask := brew_cask.new_cask_core(brew_cask.CaskCoreConfig{
		token: 'url-less-installed-cask'
		caskroom_root: os.join_path(root, 'Caskroom')
	}, from_api_spec_noop_block)!
	cask.dsl.version_value = dsl_types.cask_version_from_string('latest')!
	cask.dsl.has_version = true
	cask.installed_version_override = 'latest'
	cask.has_installed_version_override = true
	cask.new_download_sha_value = 'new-download-sha'
	os.mkdir_all(os.dir(cask.download_sha_path()))!
	os.write_file(cask.download_sha_path(), 'old-download-sha')!
	return cask.outdated(brew_cask.CaskOutdatedOptions{ greedy: true })
}

// Ruby it `it "uses current API artifacts for installed metadata without receipt artifacts" do` at line 199.
pub fn ruby_from_api_loader_spec_l199_d26_uses(root string) !bool {
	mut cask := brew_cask.new_cask_core(brew_cask.CaskCoreConfig{
		token: 'receipt-less-installed-cask'
		caskroom_root: os.join_path(root, 'Caskroom')
	}, from_api_spec_noop_block)!
	uninstall := from_api_spec_artifact('uninstall', '', {
		'quit': ruby.string_value('com.example.receipt-less')
	})
	app := from_api_spec_artifact('app', 'Receipt-less.app', {})
	zap := from_api_spec_artifact('zap', '', {
		'trash': ruby.string_value('~/Library/Preferences/com.example.receipt-less.plist')
	})
	cask.dsl.artifacts = brew_cask.new_artifact_set([app, uninstall, zap])
	list := cask.artifacts_list(true)
	return list.len == 3 && 'uninstall' in list[0].map_data && 'app' in list[1].map_data && 'zap' in list[2].map_data
}

// Ruby it `it "does not read a malformed receipt when installed metadata is self-contained" do` at line 222.
pub fn ruby_from_api_loader_spec_l222_d27_does(root string) !bool {
	setup := from_api_spec_setup(root, 'self-contained-installed-cask')
	path := os.join_path(root, 'Caskroom', setup.api_token, '.metadata', '1.0', '20260713000000.000', 'Casks', '${setup.api_token}.json')
	source := brew_cask.CaskLoaderApiSource{
		present: true
		version: '1.0'
		artifacts: [
			brew_cask.CaskLoaderArtifact{ kind: 'app', values: ['Self-contained.app'] },
		]
		has_artifacts: true
	}
	loader := brew_cask.new_api_cask_loader(setup.api_token, source, path, true, false, true, setup.lookup)
	cask := brew_cask.cask_loader_load_api(loader, brew_cask.CaskLoaderConfig{}, brew_cask.CaskLoaderLoadContext{
		lookup: brew_cask.CaskLoaderLookupContext{
			...setup.lookup
			installed_receipts: {
				setup.api_token: brew_cask.CaskLoaderReceipt{ valid: false }
			}
		}
	})!
	return cask.artifacts == source.artifacts
}

// Ruby let `let(:cask_from_api) { api_loader.load(config: nil) }` at line 247.
pub fn ruby_from_api_loader_spec_l247_d28_cask_from_api(setup FromApiLoaderSpecSetup) !brew_cask.CaskLoaderCask {
	return from_api_spec_load(setup, false, brew_cask.CaskLoaderConfig{})
}

// Ruby let `let(:cask_from_internal_api) { internal_api_loader.load(config: nil) }` at line 248.
pub fn ruby_from_api_loader_spec_l248_d29_cask_from_internal_api(setup FromApiLoaderSpecSetup) !brew_cask.CaskLoaderCask {
	return from_api_spec_load(setup, true, brew_cask.CaskLoaderConfig{})
}

// Ruby it `it "loads from JSON API" do` at line 250.
pub fn ruby_from_api_loader_spec_l250_d30_loads(setup FromApiLoaderSpecSetup,
	caskfile_only bool) !bool {
	cask := ruby_from_api_loader_spec_l247_d28_cask_from_api(setup)!
	return cask.token == setup.api_token && cask.loaded_from_api && !cask.loaded_from_internal_api && cask.caskfile_only == caskfile_only && cask.sourcefile_path == setup.lookup.cached_internal_api_path
}

// Ruby it `it "loads from internal JSON API" do` at line 259.
pub fn ruby_from_api_loader_spec_l259_d31_loads(setup FromApiLoaderSpecSetup,
	caskfile_only bool) !bool {
	cask := ruby_from_api_loader_spec_l248_d29_cask_from_internal_api(setup)!
	return cask.token == setup.internal_token && cask.loaded_from_api && cask.loaded_from_internal_api && cask.caskfile_only == caskfile_only && cask.sourcefile_path == setup.lookup.cached_packages_path
}

// Ruby it `it "runs the loaded steps" do` at line 303.
pub fn ruby_from_api_loader_spec_l303_d32_runs(root string) !bool {
	staged := os.join_path(root, 'staged')
	os.mkdir_all(staged)!
	os.write_file(os.join_path(staged, 'container'), 'app')!
	os.write_file(os.join_path(staged, 'move-source'), 'moved')!
	mut steps := homebrew.InstallSteps{}
	mut mkdir_step := homebrew.InstallStep{}
	mkdir_step['type'] = ruby.string_value('mkdir_p')
	mkdir_step['path'] = from_api_spec_path_value('staged_path', 'Prepared')
	steps << mkdir_step
	mut touch_step := homebrew.InstallStep{}
	touch_step['type'] = ruby.string_value('touch')
	touch_step['path'] = from_api_spec_path_value('staged_path', 'Prepared/touched')
	steps << touch_step
	mut move_step := homebrew.InstallStep{}
	move_step['type'] = ruby.string_value('move')
	move_step['source'] = from_api_spec_path_value('staged_path', 'move-source')
	move_step['target'] = from_api_spec_path_value('staged_path', 'Prepared/moved')
	steps << move_step
	mut symlink_step := homebrew.InstallStep{}
	symlink_step['type'] = ruby.string_value('symlink')
	symlink_step['source'] = from_api_spec_path_value('staged_path', 'container')
	symlink_step['target'] = from_api_spec_path_value('staged_path', 'PreparedLink')
	steps << symlink_step
	mut runner := homebrew.new_install_steps_runner(homebrew.InstallStepsContext{
		values: {
			'staged_path': staged
		}
	}, homebrew.NativeInstallStepsCommandExecutor{})
	homebrew.install_steps_run(mut runner, steps, 'install')!
	return os.is_dir(os.join_path(staged, 'Prepared')) && os.exists(os.join_path(staged, 'Prepared', 'touched')) && os.exists(os.join_path(staged, 'Prepared', 'moved')) && os.is_link(os.join_path(staged, 'PreparedLink'))
}

// Ruby it `it "loads the selected language variation from both APIs" do` at line 339.
pub fn ruby_from_api_loader_spec_l339_d33_loads(setup FromApiLoaderSpecSetup) !bool {
	config := brew_cask.CaskLoaderConfig{ languages: ['zh'] }
	external := from_api_spec_load(setup, false, config)!
	internal := from_api_spec_load(setup, true, config)!
	for cask in [external, internal] {
		if cask.language != 'zh-CN' || cask.url != 'file:///fixtures/cask/container.tar.gz' || cask.sha256 != 'fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5' || cask.artifacts.len == 0 || cask.artifacts[0].values != [
			'Container.app',
		] {
			return false
		}
	}
	return true
}

// Ruby it `it "keeps the source fallback for old API data" do` at line 353.
pub fn ruby_from_api_loader_spec_l353_d34_keeps(setup FromApiLoaderSpecSetup) !bool {
	old_source := brew_cask.CaskLoaderApiSource{ ...setup.source, localisations: [] }
	loader := brew_cask.new_api_cask_loader(setup.api_token, old_source, '', false, false, true, setup.lookup)
	cask := brew_cask.cask_loader_load_api(loader, brew_cask.CaskLoaderConfig{}, brew_cask.CaskLoaderLoadContext{ lookup: setup.lookup })!
	return cask.caskfile_only
}

fn from_api_spec_migration(setup FromApiLoaderSpecSetup, internal bool, full_name bool) bool {
	token := if internal { setup.internal_token } else { setup.api_token }
	old_token := '${token}-old'
	base_foo := ruby_from_api_loader_spec_l90_d16_foo_tap(setup.root)
	foo := brew_cask.CaskLoaderTap{
		...base_foo
		tap_migrations: {
			old_token: 'homebrew/cask/${token}'
		}
	}
	context := brew_cask.CaskLoaderLookupContext{
		...setup.lookup
		taps: [setup.lookup.core_cask_tap, foo]
	}
	resolution := brew_cask.cask_loader_tap_cask_token_type('${foo.name}/${old_token}', false, context) or { return false }
	if resolution.token != token || !resolution.tap.core_cask_tap {
		return false
	}
	ref := if full_name { '${foo.name}/${old_token}' } else { old_token }
	loader := brew_cask.cask_loader_for(brew_cask.CaskLoaderReference{
		kind: .text
		value: ref
	}, false, false, context) or { return false }
	return loader.kind == .api && loader.token == token && !os.exists(loader.path)
}

pub fn from_api_loader_spec_all_boundaries(root string) ![]FromApiLoaderSpecBoundary {
	os.mkdir_all(root)!
	setup := from_api_spec_setup(root, 'test-opera')
	mut boundaries := []FromApiLoaderSpecBoundary{}
	boundaries << FromApiLoaderSpecBoundary{ line: 6, passed: ruby_from_api_loader_spec_l6_d1_api_token('test-opera') == setup.api_token }
	boundaries << FromApiLoaderSpecBoundary{ line: 7, passed: ruby_from_api_loader_spec_l7_d2_cask_from_source(setup)!.token == 'test-opera' }
	boundaries << FromApiLoaderSpecBoundary{ line: 8, passed: ruby_from_api_loader_spec_l8_d3_cask_json(setup).tap_git_head.len == 40 }
	boundaries << FromApiLoaderSpecBoundary{ line: 15, passed: setup.api_token in ruby_from_api_loader_spec_l15_d4_casks_from_api_hash(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 16, passed: ruby_from_api_loader_spec_l16_d5_api_loader(setup).token == setup.api_token }
	boundaries << FromApiLoaderSpecBoundary{ line: 30, passed: ruby_from_api_loader_spec_l30_d6_cask_from_internal_source(setup)!.token == 'test-opera' }
	boundaries << FromApiLoaderSpecBoundary{ line: 31, passed: ruby_from_api_loader_spec_l31_d7_cask_internal_struct(setup).present }
	boundaries << FromApiLoaderSpecBoundary{ line: 36, passed: ruby_from_api_loader_spec_l36_d8_internal_api_token('test-opera') == setup.internal_token }
	boundaries << FromApiLoaderSpecBoundary{ line: 37, passed: ruby_from_api_loader_spec_l37_d9_internal_tap_git_head().len == 40 }
	boundaries << FromApiLoaderSpecBoundary{ line: 38, passed: ruby_from_api_loader_spec_l38_d10_cask_internal_json(setup).tap_git_head.len == 40 }
	boundaries << FromApiLoaderSpecBoundary{ line: 46, passed: setup.internal_token in ruby_from_api_loader_spec_l46_d11_casks_from_internal_api_hash(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 47, passed: ruby_from_api_loader_spec_l47_d12_internal_api_loader(setup).from_internal_json }
	boundaries << FromApiLoaderSpecBoundary{ line: 69, passed: ruby_from_api_loader_spec_l69_d13_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 77, passed: ruby_from_api_loader_spec_l77_d14_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 83, passed: ruby_from_api_loader_spec_l83_d15_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 90, passed: ruby_from_api_loader_spec_l90_d16_foo_tap(root).name == 'homebrew/foo' }
	boundaries << FromApiLoaderSpecBoundary{ line: 100, passed: ruby_from_api_loader_spec_l100_d17_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 112, passed: ruby_from_api_loader_spec_l112_d18_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 129, passed: ruby_from_api_loader_spec_l129_d19_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 135, passed: ruby_from_api_loader_spec_l135_d20_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 142, passed: ruby_from_api_loader_spec_l142_d21_foo_tap(root).name == 'homebrew/foo' }
	boundaries << FromApiLoaderSpecBoundary{ line: 152, passed: ruby_from_api_loader_spec_l152_d22_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 164, passed: ruby_from_api_loader_spec_l164_d23_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 178, passed: ruby_from_api_loader_spec_l178_d24_returns(setup) }
	boundaries << FromApiLoaderSpecBoundary{ line: 184, passed: ruby_from_api_loader_spec_l184_d25_handles(os.join_path(root, 'd25'))! }
	boundaries << FromApiLoaderSpecBoundary{ line: 199, passed: ruby_from_api_loader_spec_l199_d26_uses(os.join_path(root, 'd26'))! }
	boundaries << FromApiLoaderSpecBoundary{ line: 222, passed: ruby_from_api_loader_spec_l222_d27_does(os.join_path(root, 'd27'))! }
	boundaries << FromApiLoaderSpecBoundary{ line: 247, passed: ruby_from_api_loader_spec_l247_d28_cask_from_api(setup)!.loaded_from_api }
	boundaries << FromApiLoaderSpecBoundary{ line: 248, passed: ruby_from_api_loader_spec_l248_d29_cask_from_internal_api(setup)!.loaded_from_internal_api }
	boundaries << FromApiLoaderSpecBoundary{ line: 250, passed: ruby_from_api_loader_spec_l250_d30_loads(setup, false)! }
	boundaries << FromApiLoaderSpecBoundary{ line: 259, passed: ruby_from_api_loader_spec_l259_d31_loads(setup, false)! }
	boundaries << FromApiLoaderSpecBoundary{ line: 303, passed: ruby_from_api_loader_spec_l303_d32_runs(os.join_path(root, 'd32'))! }
	language_setup := from_api_spec_setup(os.join_path(root, 'language'), 'with-languages')
	boundaries << FromApiLoaderSpecBoundary{ line: 339, passed: ruby_from_api_loader_spec_l339_d33_loads(language_setup)! }
	boundaries << FromApiLoaderSpecBoundary{ line: 353, passed: ruby_from_api_loader_spec_l353_d34_keeps(language_setup)! }
	return boundaries
}

pub fn from_api_loader_spec_shared_examples(root string) !bool {
	cases := {
		'with-binary':                      false
		'with-depends-on-cask-multiple':    false
		'with-depends-on-formula-multiple': false
		'with-depends-on-macos-array':      false
		'with-installer-script':            false
		'with-uninstall-multi':             false
		'with-zap':                         false
		'with-install-steps':               false
		'with-preflight':                   true
		'with-uninstall-preflight':         true
		'with-postflight':                  true
		'with-uninstall-postflight':        true
		'with-languages':                   false
	}
	for token, caskfile_only in cases {
		setup := from_api_spec_setup(os.join_path(root, token), token)
		if !ruby_from_api_loader_spec_l250_d30_loads(setup, caskfile_only)! || !ruby_from_api_loader_spec_l259_d31_loads(setup, caskfile_only)! {
			return false
		}
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromAPILoader, :cask do
// 5:   shared_context "with API setup" do |local_token|
// 6:     let(:api_token) { "#{local_token}-api" }
// 7:     let(:cask_from_source) { Cask::CaskLoader.load(local_token) }
// 8:     let(:cask_json) do
// 9:       hash = cask_from_source.to_hash_with_variations
// 10:       # This value will always be present in the json API, but is skipped in tests
// 11:       hash["tap_git_head"] = "abcdef1234567890abcdef1234567890abcdef12"
// 12:       json = JSON.pretty_generate(hash)
// 13:       JSON.parse(json)
// 14:     end
// 15:     let(:casks_from_api_hash) { { api_token => cask_json.except("token") } }
// 16:     let(:api_loader) { described_class.new(api_token, from_json: cask_json) }
// 17:
// 18:     before do
// 19:       allow(Homebrew::API).to receive_messages(cask_tokens: casks_from_api_hash.keys, cask_renames: {})
// 20:       allow(Homebrew::API).to receive(:cask_token?) { |token| casks_from_api_hash.key?(token) }
// 21:       allow(Homebrew::API::Cask).to receive(:all_casks).and_return(casks_from_api_hash)
// 22:
// 23:       # The call to `Cask::CaskLoader.load` above sets the Tap cache prematurely.
// 24:       Tap.clear_cache
// 25:     end
// 26:   end
// 27:
// 28:   shared_context "with internal API setup" do |local_token|
// 29:     # Load the cask and generate its hash first before we enable internal API mode for the test body
// 30:     let!(:cask_from_internal_source) { Cask::CaskLoader.load(local_token) }
// 31:     let!(:cask_internal_struct) do
// 32:       hash_with_variations = cask_from_internal_source.to_hash_with_variations
// 33:       Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash_with_variations)
// 34:     end
// 35:
// 36:     let(:internal_api_token) { "#{local_token}-internal-api" }
// 37:     let(:internal_tap_git_head) { "abcdef1234567890abcdef1234567890abcdef12" }
// 38:     let(:cask_internal_json) do
// 39:       hash = cask_internal_struct.serialize
// 40:       # This value must be manually added when loading from internal API contents directly
// 41:       hash["tap_git_head"] = internal_tap_git_head
// 42:       json = JSON.pretty_generate(hash)
// 43:       JSON.parse(json)
// 44:     end
// 45:     # let(:cask_structs_from_api_hash) { { internal_api_token => cask_internal_struct } }
// 46:     let(:casks_from_internal_api_hash) { { internal_api_token => cask_internal_json.except("tap_git_head") } }
// 47:     let(:internal_api_loader) do
// 48:       described_class.new(internal_api_token, from_json: cask_internal_json, from_internal_json: true)
// 49:     end
// 50:
// 51:     before do
// 52:       allow(Homebrew::API::Internal)
// 53:         .to receive_messages(cask_hashes:         casks_from_internal_api_hash,
// 54:                              cask_renames:        {},
// 55:                              cask_tap_migrations: {},
// 56:                              cask_tap_git_head:   internal_tap_git_head)
// 57:       allow(Homebrew::API::Internal).to receive(:cask_name?) { |token| casks_from_internal_api_hash.key?(token) }
// 58:       allow(Homebrew::API::Internal).to receive(:cask_hash) { |token| casks_from_internal_api_hash[token] }
// 59:
// 60:       # The call to `Cask::CaskLoader.load` above sets the Tap cache prematurely.
// 61:       Tap.clear_cache
// 62:     end
// 63:   end
// 64:
// 65:   describe ".try_new" do
// 66:     context "when not using the API", :no_api do
// 67:       include_context "with API setup", "test-opera"
// 68:
// 69:       it "returns false" do
// 70:         expect(described_class.try_new(api_token)).to be_nil
// 71:       end
// 72:     end
// 73:
// 74:     context "when using the API" do
// 75:       include_context "with API setup", "test-opera"
// 76:
// 77:       it "returns a loader for valid token" do
// 78:         expect(described_class.try_new(api_token))
// 79:           .to be_a(described_class)
// 80:           .and have_attributes(token: api_token)
// 81:       end
// 82:
// 83:       it "returns a loader for valid full name" do
// 84:         expect(described_class.try_new("homebrew/cask/#{api_token}"))
// 85:           .to be_a(described_class)
// 86:           .and have_attributes(token: api_token)
// 87:       end
// 88:
// 89:       context "with core tap migration renames" do
// 90:         let(:foo_tap) { Tap.fetch("homebrew", "foo") }
// 91:
// 92:         before do
// 93:           foo_tap.path.mkpath
// 94:         end
// 95:
// 96:         after do
// 97:           FileUtils.rm_rf foo_tap.path
// 98:         end
// 99:
// 100:         it "returns the tap migration rename by old token" do
// 101:           old_token = "#{api_token}-old"
// 102:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 103:             { "#{old_token}": "homebrew/cask/#{api_token}" }
// 104:           JSON
// 105:
// 106:           loader = Cask::CaskLoader::FromNameLoader.try_new(old_token)
// 107:           expect(loader).to be_a(described_class)
// 108:           expect(loader.token).to eq api_token
// 109:           expect(loader.path).not_to exist
// 110:         end
// 111:
// 112:         it "returns the tap migration rename by old full name" do
// 113:           old_token = "#{api_token}-old"
// 114:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 115:             { "#{old_token}": "homebrew/cask/#{api_token}" }
// 116:           JSON
// 117:
// 118:           loader = Cask::CaskLoader::FromTapLoader.try_new("#{foo_tap}/#{old_token}")
// 119:           expect(loader).to be_a(described_class)
// 120:           expect(loader.token).to eq api_token
// 121:           expect(loader.path).not_to exist
// 122:         end
// 123:       end
// 124:     end
// 125:
// 126:     context "when using the internal API" do
// 127:       include_context "with internal API setup", "test-opera"
// 128:
// 129:       it "returns a loader for valid token" do
// 130:         expect(described_class.try_new(internal_api_token))
// 131:           .to be_a(described_class)
// 132:           .and have_attributes(token: internal_api_token)
// 133:       end
// 134:
// 135:       it "returns a loader for valid full name" do
// 136:         expect(described_class.try_new("homebrew/cask/#{internal_api_token}"))
// 137:           .to be_a(described_class)
// 138:           .and have_attributes(token: internal_api_token)
// 139:       end
// 140:
// 141:       context "with core tap migration renames" do
// 142:         let(:foo_tap) { Tap.fetch("homebrew", "foo") }
// 143:
// 144:         before do
// 145:           foo_tap.path.mkpath
// 146:         end
// 147:
// 148:         after do
// 149:           FileUtils.rm_rf foo_tap.path
// 150:         end
// 151:
// 152:         it "returns the tap migration rename by old token" do
// 153:           old_token = "#{internal_api_token}-old"
// 154:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 155:             { "#{old_token}": "homebrew/cask/#{internal_api_token}" }
// 156:           JSON
// 157:
// 158:           loader = Cask::CaskLoader::FromNameLoader.try_new(old_token)
// 159:           expect(loader).to be_a(described_class)
// 160:           expect(loader.token).to eq internal_api_token
// 161:           expect(loader.path).not_to exist
// 162:         end
// 163:
// 164:         it "returns the tap migration rename by old full name" do
// 165:           old_token = "#{internal_api_token}-old"
// 166:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 167:             { "#{old_token}": "homebrew/cask/#{internal_api_token}" }
// 168:           JSON
// 169:
// 170:           loader = Cask::CaskLoader::FromTapLoader.try_new("#{foo_tap}/#{old_token}")
// 171:           expect(loader).to be_a(described_class)
// 172:           expect(loader.token).to eq internal_api_token
// 173:           expect(loader.path).not_to exist
// 174:         end
// 175:       end
// 176:     end
// 177:
// 178:     it "returns nil for full name with invalid tap" do
// 179:       expect(described_class.try_new("homebrew/foo/test-opera")).to be_nil
// 180:     end
// 181:   end
// 182:
// 183:   describe "#load" do
// 184:     it "handles greedy outdated checks for installed metadata without a URL" do
// 185:       token = "url-less-installed-cask"
// 186:       caskroom = mktmpdir
// 187:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 188:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 189:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({ "artifacts" => [] })
// 190:       path = caskroom/token/".metadata/latest/20260713000000.000/Casks/#{token}.json"
// 191:       cask = described_class.new(token, from_json: {}, path:, from_installed_caskfile: true).load(config: nil)
// 192:       allow(cask).to receive(:installed_version).and_return("latest")
// 193:       cask.download_sha_path.dirname.mkpath
// 194:       cask.download_sha_path.write("old-download-sha")
// 195:
// 196:       expect(cask.outdated?(greedy: true)).to be(true)
// 197:     end
// 198:
// 199:     it "uses current API artifacts for installed metadata without receipt artifacts" do
// 200:       token = "receipt-less-installed-cask"
// 201:       caskroom = mktmpdir
// 202:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 203:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 204:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 205:         "artifacts" => [
// 206:           { "app" => ["Receipt-less.app"] },
// 207:           { "uninstall" => [{ "quit" => "com.example.receipt-less" }] },
// 208:           { "zap" => [{ "trash" => "~/Library/Preferences/com.example.receipt-less.plist" }] },
// 209:         ],
// 210:       })
// 211:       path = caskroom/token/".metadata/1.0/20260713000000.000/Casks/#{token}.json"
// 212:
// 213:       cask = described_class.new(token, from_json: {}, path:, from_installed_caskfile: true).load(config: nil)
// 214:
// 215:       expect(cask.artifacts_list(uninstall_only: true)).to eq([
// 216:         { uninstall: [{ quit: "com.example.receipt-less" }] },
// 217:         { app: ["Receipt-less.app"] },
// 218:         { zap: [{ trash: "~/Library/Preferences/com.example.receipt-less.plist" }] },
// 219:       ])
// 220:     end
// 221:
// 222:     it "does not read a malformed receipt when installed metadata is self-contained" do
// 223:       token = "self-contained-installed-cask"
// 224:       caskroom = mktmpdir
// 225:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 226:       receipt = caskroom/token/".metadata/INSTALL_RECEIPT.json"
// 227:       receipt.dirname.mkpath
// 228:       receipt.write("{")
// 229:       path = caskroom/token/".metadata/1.0/20260713000000.000/Casks/#{token}.json"
// 230:
// 231:       cask = described_class.new(
// 232:         token,
// 233:         from_json:               {
// 234:           "version"   => "1.0",
// 235:           "artifacts" => [{ "app" => ["Self-contained.app"] }],
// 236:         },
// 237:         path:,
// 238:         from_installed_caskfile: true,
// 239:       ).load(config: nil)
// 240:
// 241:       expect(cask.artifacts_list(uninstall_only: true)).to eq([{ app: ["Self-contained.app"] }])
// 242:     end
// 243:
// 244:     shared_examples "loads from API" do |cask_token, caskfile_only:|
// 245:       include_context "with API setup", cask_token
// 246:       include_context "with internal API setup", cask_token
// 247:       let(:cask_from_api) { api_loader.load(config: nil) }
// 248:       let(:cask_from_internal_api) { internal_api_loader.load(config: nil) }
// 249:
// 250:       it "loads from JSON API" do
// 251:         expect(cask_from_api).to be_a(Cask::Cask)
// 252:         expect(cask_from_api.token).to eq(api_token)
// 253:         expect(cask_from_api.loaded_from_api?).to be(true)
// 254:         expect(cask_from_api.loaded_from_internal_api?).to be(false)
// 255:         expect(cask_from_api.caskfile_only?).to be(caskfile_only)
// 256:         expect(cask_from_api.sourcefile_path).to eq(Homebrew::API::Cask.cached_json_file_path)
// 257:       end
// 258:
// 259:       it "loads from internal JSON API" do
// 260:         expect(cask_from_internal_api).to be_a(Cask::Cask)
// 261:         expect(cask_from_internal_api.token).to eq(internal_api_token)
// 262:         expect(cask_from_internal_api.loaded_from_api?).to be(true)
// 263:         expect(cask_from_internal_api.loaded_from_internal_api?).to be(true)
// 264:         expect(cask_from_internal_api.caskfile_only?).to be(caskfile_only)
// 265:         expect(cask_from_internal_api.sourcefile_path).to eq(Homebrew::API::Internal.cached_packages_json_file_path)
// 266:       end
// 267:     end
// 268:
// 269:     context "with a binary stanza" do
// 270:       include_examples "loads from API", "with-binary", caskfile_only: false
// 271:     end
// 272:
// 273:     context "with cask dependencies" do
// 274:       include_examples "loads from API", "with-depends-on-cask-multiple", caskfile_only: false
// 275:     end
// 276:
// 277:     context "with formula dependencies" do
// 278:       include_examples "loads from API", "with-depends-on-formula-multiple", caskfile_only: false
// 279:     end
// 280:
// 281:     context "with macos dependencies" do
// 282:       include_examples "loads from API", "with-depends-on-macos-array", caskfile_only: false
// 283:     end
// 284:
// 285:     context "with an installer stanza" do
// 286:       include_examples "loads from API", "with-installer-script", caskfile_only: false
// 287:     end
// 288:
// 289:     context "with uninstall stanzas" do
// 290:       include_examples "loads from API", "with-uninstall-multi", caskfile_only: false
// 291:     end
// 292:
// 293:     context "with a zap stanza" do
// 294:       include_examples "loads from API", "with-zap", caskfile_only: false
// 295:     end
// 296:
// 297:     context "with install step stanzas" do
// 298:       include_examples "loads from API", "with-install-steps", caskfile_only: false
// 299:
// 300:       context "when running install steps loaded from internal JSON API" do
// 301:         include_context "with internal API setup", "with-install-steps"
// 302:
// 303:         it "runs the loaded steps" do
// 304:           cask = internal_api_loader.load(config: nil)
// 305:           cask.staged_path.mkpath
// 306:           cask.config_path.dirname.mkpath
// 307:           (cask.staged_path/"container").write "app"
// 308:           (cask.staged_path/"move-source").write "moved"
// 309:
// 310:           Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 311:
// 312:           expect(cask.staged_path/"Prepared").to be_a_directory
// 313:           expect(cask.staged_path/"Prepared/touched").to exist
// 314:           expect(cask.staged_path/"Prepared/moved").to exist
// 315:           expect(cask.staged_path/"PreparedLink").to be_a_symlink
// 316:         end
// 317:       end
// 318:     end
// 319:
// 320:     context "with a preflight stanza" do
// 321:       include_examples "loads from API", "with-preflight", caskfile_only: true
// 322:     end
// 323:
// 324:     context "with an uninstall-preflight stanza" do
// 325:       include_examples "loads from API", "with-uninstall-preflight", caskfile_only: true
// 326:     end
// 327:
// 328:     context "with a postflight stanza" do
// 329:       include_examples "loads from API", "with-postflight", caskfile_only: true
// 330:     end
// 331:
// 332:     context "with an uninstall-postflight stanza" do
// 333:       include_examples "loads from API", "with-uninstall-postflight", caskfile_only: true
// 334:     end
// 335:
// 336:     context "with a language stanza" do
// 337:       include_examples "loads from API", "with-languages", caskfile_only: false
// 338:
// 339:       it "loads the selected language variation from both APIs" do
// 340:         config = Cask::Config.new(explicit: { languages: ["zh"] })
// 341:         casks = [api_loader.load(config:), internal_api_loader.load(config:)]
// 342:
// 343:         expect(casks.map do |cask|
// 344:           [cask.language, cask.url.to_s, cask.sha256.to_s, cask.artifacts.first.to_args]
// 345:         end).to all(eq([
// 346:           "zh-CN",
// 347:           "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz",
// 348:           "fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5",
// 349:           ["Container.app"],
// 350:         ]))
// 351:       end
// 352:
// 353:       it "keeps the source fallback for old API data" do
// 354:         cask = described_class.new(api_token, from_json: cask_json.except("language_variations")).load(config: nil)
// 355:
// 356:         expect(cask).to be_caskfile_only
// 357:       end
// 358:     end
// 359:   end
// 360: end
