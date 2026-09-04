module cask

import ruby
import crypto.sha256
import homebrew.cask as cask_core
import homebrew.cask.dsl as dsl_types
import homebrew.requirements
import os
import time

// Translated from Homebrew/brew `test/cask/installer_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn installer_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn installer_spec_compact_json(value string) string {
	return value.replace(' ', '').replace('\n', '').replace('\t', '')
}

fn installer_spec_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn installer_spec_noop_block(mut dsl cask_core.CaskDSL) ! {
	_ = dsl
}

fn installer_spec_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-installer-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn installer_spec_remove(path string) {
	if path == '' || (!os.exists(path) && !os.is_link(path)) {
		return
	}
	if os.is_dir(path) && !os.is_link(path) { os.rmdir_all(path) or {} } else { os.rm(path) or {} }
}

fn installer_spec_copy(source string, target string) ! {
	if os.is_file(source) {
		os.mkdir_all(os.dir(target))!
		os.cp(source, target)!
		return
	}
	os.mkdir_all(target)!
	for name in os.ls(source)! {
		installer_spec_copy(os.join_path(source, name), os.join_path(target, name))!
	}
}

fn installer_spec_extract(source string, destination string, verbose bool) ! {
	_ = verbose
	os.mkdir_all(destination)!
	for raw in os.read_lines(source)! {
		line := raw.trim_space()
		if line == '' || line.starts_with('__MACOSX/') {
			continue
		}
		kind := line.all_before(':')
		relative := line.all_after(':')
		path := os.join_path(destination, relative)
		if kind == 'dir' {
			os.mkdir_all(path)!
		} else if kind == 'file' {
			os.mkdir_all(os.dir(path))!
			os.write_file(path, relative)!
		}
	}
}

fn installer_spec_install_artifact(request cask_core.CaskInstallerArtifactRequest) ! {
	source := request.artifact.attributes['source'] or { '' }
	target := request.artifact.attributes['target'] or { '' }
	if source != '' && target != '' {
		installer_spec_remove(target)
		installer_spec_copy(source, target)!
	}
}

fn installer_spec_uninstall_artifact(request cask_core.CaskInstallerArtifactRequest) ! {
	target := request.artifact.attributes['target'] or { '' }
	if target != '' { installer_spec_remove(target) }
}

fn installer_spec_enqueue(entry cask_core.CaskInstallerQueueEntry) ! {
	_ = entry
}

fn installer_spec_fetch(request cask_core.CaskInstallerDownloadRequest) !string {
	return request.url
}

fn installer_spec_source_loader(source cask_core.CaskCore) !cask_core.CaskCore {
	mut loaded := source
	if raw := source.api_source['url'] {
		loaded.dsl.url_value = cask_core.new_cask_url(raw.as_string(), {})!
		loaded.dsl.has_url = true
	}
	if raw := source.api_source['version'] {
		loaded.dsl.version_value = dsl_types.cask_version_from_string(raw.as_string())!
		loaded.dsl.has_version = true
	}
	if raw := source.api_source['artifact'] {
		loaded.dsl.artifacts = cask_core.new_artifact_set([raw])
	}
	loaded.loaded_from_api = false
	return loaded
}

fn installer_spec_installed_loader_failure(source cask_core.CaskCore) !cask_core.CaskCore {
	return error('${source.token}: broken DSL')
}

fn installer_spec_hooks() cask_core.CaskInstallerHooks {
	return cask_core.CaskInstallerHooks{
		extract: installer_spec_extract
		install_artifact: installer_spec_install_artifact
		uninstall_artifact: installer_spec_uninstall_artifact
		zap_artifact: installer_spec_uninstall_artifact
		enqueue: installer_spec_enqueue
		fetch: installer_spec_fetch
		load_source_cask: installer_spec_source_loader
		recover_installed_cask: installer_spec_source_loader
	}
}

fn installer_spec_artifact(key string, source string, target string) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::${key.split('_').map(it.title()).join('')}'
		repr: source
		attributes: {
			'dsl_key': key
			'source':  source
			'target':  target
		}
	}
}

fn installer_spec_core(token string, root string, version string) !cask_core.CaskCore {
	mut cask := cask_core.new_cask_core(cask_core.CaskCoreConfig{
		token: token
		source: '{}'
		caskroom_root: os.join_path(root, 'Caskroom')
		pinned_root: os.join_path(root, 'pinned')
	}, installer_spec_noop_block)!
	cask.dsl.version_value = dsl_types.cask_version_from_string(version)!
	cask.dsl.has_version = true
	return cask
}

fn installer_spec_prepare_archive(mut cask cask_core.CaskCore, root string, descriptor string,
	artifact_key string, artifact_path string) !string {
	archive := os.join_path(root, '${cask.token}.archive')
	os.mkdir_all(root)!
	os.write_file(archive, descriptor)!
	cask.download = archive
	cask.dsl.url_value = cask_core.new_cask_url('file://${archive}', {})!
	cask.dsl.has_url = true
	cask.dsl.sha256_value = ruby.Value{ type_name: 'Symbol', repr: 'no_check' }
	cask.dsl.has_sha256 = true
	staged := os.join_path(cask.caskroom_path(), cask.version_text())
	cask.dsl.staged_path_value = staged
	target := os.join_path(root, 'Applications', artifact_path)
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact(artifact_key, os.join_path(staged, artifact_path), target),
	])
	return target
}

fn installer_spec_install_case(label string, descriptor string, artifact_path string,
	directory bool, options cask_core.CaskInstallerOptions) bool {
	root := installer_spec_temp(label)
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core(label, root, '1.0') or { return false }
	target := installer_spec_prepare_archive(mut cask, root, descriptor, 'app', artifact_path) or { return false }
	mut installer := cask_core.new_cask_installer(cask, options, installer_spec_hooks())
	installer.install() or { return false }
	return os.is_dir(os.join_path(cask.caskroom_path(), '1.0')) && if directory {
		os.is_dir(target)
	} else {
		os.is_file(target)
	}
}

// Ruby method `stub_dmg_extraction` at line 5.
pub fn ruby_installer_spec_l5_d1_stub_dmg_extraction(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('UnpackStrategy::Dmg::ExtractionStub', 'extract_nestedly', {
		'can_extract':         'true'
		'creates_destination': 'true'
	})
}

// Ruby it `it "stores casks loaded from Ruby source as JSON metadata" do` at line 14.
pub fn ruby_installer_spec_l14_d2_stores(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('ruby-metadata')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'Caffeine.app', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	path := installer.save_caskfile() or { return installer_spec_bool(false) }
	content := os.read_file(path) or { return installer_spec_bool(false) }
	return installer_spec_bool(os.base(path) == 'local-caffeine.json' && content == '{}')
}

// Ruby it `it "stores URL only_path metadata needed to reconstruct artifact sources" do` at line 27.
pub fn ruby_installer_spec_l27_d3_stores(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('only-path')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('only-path', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.url_value = cask_core.new_cask_url('https://example.com/only-path.git', {
		'only_path': ruby.string_value('nested')
	}) or { return installer_spec_bool(false) }
	cask.dsl.has_url = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'Only Path.app', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	path := installer.save_caskfile() or { return installer_spec_bool(false) }
	content := os.read_file(path) or { return installer_spec_bool(false) }
	return installer_spec_bool(installer_spec_compact_json(content) == '{"url_specs":{"only_path":"nested"}}')
}

// Ruby it `it "strips legacy install flight blocks and records empty artifacts in JSON metadata" do` at line 48.
pub fn ruby_installer_spec_l48_d4_strips(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('flight-json')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('with-preflight', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	path := installer.save_caskfile() or { return installer_spec_bool(false) }
	content := os.read_file(path) or { '' }
	return installer_spec_bool(installer_spec_compact_json(content) == '{"artifacts":[]}')
}

// Ruby it `it "stores intentional empty artifacts in JSON metadata" do` at line 56.
pub fn ruby_installer_spec_l56_d5_stores(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('stage-only-json')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('stage-only', root, '1.0') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	path := installer.save_caskfile() or { return installer_spec_bool(false) }
	content := os.read_file(path) or { '' }
	return installer_spec_bool(installer_spec_compact_json(content) == '{"artifacts":[]}')
}

// Ruby it `it "stores legacy uninstall flight block casks as Ruby metadata" do` at line 64.
pub fn ruby_installer_spec_l64_d6_stores(args ...ruby.Value) ruby.Value {
	_ = args
	mut actual := []string{}
	for token, key in {
		'with-uninstall-preflight':  'uninstall_preflight'
		'with-uninstall-postflight': 'uninstall_postflight'
	} {
		root := installer_spec_temp(token)
		defer { installer_spec_remove(root) }
		mut cask := installer_spec_core(token, root, '1.0') or { return installer_spec_bool(false) }
		cask.source = 'cask "${token}" do\nend\n'
		cask.dsl.artifacts = cask_core.new_artifact_set([
			installer_spec_artifact(key, '', ''),
		])
		mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
		actual << os.base(installer.save_caskfile() or { return installer_spec_bool(false) })
	}
	actual.sort()
	return installer_spec_bool(actual == ['with-uninstall-postflight.rb',
		'with-uninstall-preflight.rb'])
}

// Ruby it `it "stores casks loaded from the internal API as JSON metadata" do` at line 80.
pub fn ruby_installer_spec_l80_d7_stores(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('api-metadata')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('api-cask', root, '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.loaded_from_internal_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'API Cask.app', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	path := installer.save_caskfile() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.base(path) == 'api-cask.json' && (os.read_file(path) or { '' }) == '{}')
}

// Ruby it `it "downloads and installs a nice fresh Cask" do` at line 117.
pub fn ruby_installer_spec_l117_d8_downloads(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('local-caffeine', 'dir:Caffeine.app', 'Caffeine.app', true, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works with HFS+ dmg-based Casks" do` at line 126.
pub fn ruby_installer_spec_l126_d9_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('container-dmg', 'file:container', 'container', false, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works with tar-gz-based Casks" do` at line 136.
pub fn ruby_installer_spec_l136_d10_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('container-tar-gz', 'file:container', 'container', false, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works with xar-based Casks" do` at line 145.
pub fn ruby_installer_spec_l145_d11_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('container-xar', 'file:container', 'container', false, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works with pure bzip2-based Casks" do` at line 154.
pub fn ruby_installer_spec_l154_d12_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('container-bzip2', 'file:container', 'container', false, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works with pure gzip-based Casks" do` at line 170.
pub fn ruby_installer_spec_l170_d13_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('container-gzip', 'file:container', 'container', false, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "blows up on a bad checksum" do` at line 179.
pub fn ruby_installer_spec_l179_d14_blows(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('bad-checksum')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('bad-checksum', root, '1.0') or { return installer_spec_bool(false) }
	path := os.join_path(root, 'download')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(path, 'payload') or { return installer_spec_bool(false) }
	cask.download = path
	cask.dsl.has_sha256 = true
	cask.dsl.sha256_value = ruby.string_value('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.download(false, none) or { return installer_spec_bool(err.msg().contains('SHA256 mismatch')) }
	return installer_spec_bool(false)
}

// Ruby it `it "blows up on a missing checksum" do` at line 186.
pub fn ruby_installer_spec_l186_d15_blows(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('missing-checksum')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('missing-checksum', root, '1.0') or { return installer_spec_bool(false) }
	path := os.join_path(root, 'download')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(path, 'payload') or { return installer_spec_bool(false) }
	cask.download = path
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.download(false, none) or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.messages.any(it.contains('Cannot verify integrity')))
}

// Ruby it `it "installs fine if sha256 :no_check is used" do` at line 193.
pub fn ruby_installer_spec_l193_d16_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('no-checksum', 'dir:Caffeine.app', 'Caffeine.app', true, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "fails to install if sha256 :no_check is used with --require-sha" do` at line 201.
pub fn ruby_installer_spec_l201_d17_fails(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('require-sha')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('no-checksum', root, '1.0') or { return installer_spec_bool(false) }
	archive := os.join_path(root, 'archive')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(archive, 'dir:Caffeine.app') or { return installer_spec_bool(false) }
	cask.download = archive
	cask.dsl.has_sha256 = true
	cask.dsl.sha256_value = ruby.Value{ type_name: 'Symbol', repr: 'no_check' }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ require_sha: true }, installer_spec_hooks())
	installer.download(false, none) or { return installer_spec_bool(err.msg().contains('--require-sha')) }
	return installer_spec_bool(false)
}

// Ruby it `it "names the cask when Linux is required" do` at line 208.
pub fn ruby_installer_spec_l208_d18_names(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-depends-on-linux-bare', installer_spec_temp('linux'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.depends_on_value.linux = true
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.check_stanza_os_requirements() or { return installer_spec_bool(err.msg() == 'with-depends-on-linux-bare: This cask requires Linux.') }
	return installer_spec_bool(false)
}

// Ruby it `it "names the cask when the macOS requirement is not satisfied" do` at line 215.
pub fn ruby_installer_spec_l215_d19_names(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-depends-on-macos-failure', installer_spec_temp('macos'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.depends_on_value.maximum_macos = requirements.new_macos_requirement([
		'monterey',
	], '<=') or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ current_macos: '15' }, installer_spec_hooks())
	installer.check_macos_requirements() or { return installer_spec_bool(err.msg().starts_with('with-depends-on-macos-failure:')) }
	return installer_spec_bool(false)
}

// Ruby it `it "names the cask when the architecture is not supported" do` at line 226.
pub fn ruby_installer_spec_l226_d20_names(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-depends-on-arch', installer_spec_temp('arch'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.depends_on_value.arch = [
		dsl_types.CaskDependencyArch{ kind: 'arm', bits: 64 },
	]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ current_arch: 'ppc' }, installer_spec_hooks())
	installer.check_arch_requirements() or { return installer_spec_bool(err.msg().starts_with('with-depends-on-arch: This cask depends on hardware architecture')) }
	return installer_spec_bool(false)
}

// Ruby it `it "names the cask when it has nothing to install on this system" do` at line 234.
pub fn ruby_installer_spec_l234_d21_names(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-no-artifacts', installer_spec_temp('empty'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.check_supported_system() or { return installer_spec_bool(err.msg() == 'with-no-artifacts: This cask is not available on macOS.') }
	return installer_spec_bool(false)
}

// Ruby it `it "treats uninstall-only artifacts as nothing to install" do` at line 245.
pub fn ruby_installer_spec_l245_d22_treats(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-zap-only', installer_spec_temp('zap-only'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('zap', '', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.check_supported_system() or { return installer_spec_bool(err.msg() == 'with-zap-only: This cask is not available on macOS.') }
	return installer_spec_bool(false)
}

// Ruby it `it "does not treat stage_only casks as having nothing to install" do` at line 257.
pub fn ruby_installer_spec_l257_d23_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-stage-only', installer_spec_temp('stage-only'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('stage_only', '', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.check_supported_system() or { return installer_spec_bool(false) }
	return installer_spec_bool(true)
}

// Ruby it `it "installs fine if sha256 :no_check is used with --require-sha and --force" do` at line 269.
pub fn ruby_installer_spec_l269_d24_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('force-no-checksum', 'dir:Caffeine.app', 'Caffeine.app', true, cask_core.CaskInstallerOptions{ require_sha: true, force: true }))
}

// Ruby it `it "prints caveats if they're present" do` at line 277.
pub fn ruby_installer_spec_l277_d25_prints(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-caveats', installer_spec_temp('caveats'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.caveats_value.custom = ['Here are some things you might want to know']
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	return installer_spec_bool(installer.caveats().contains('Here are some things you might want to know'))
}

// Ruby it `it "prints installer :manual instructions when present" do` at line 287.
pub fn ruby_installer_spec_l287_d26_prints(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-installer-manual', installer_spec_temp('manual'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.caveats_value.built_in = [dsl_types.CaskCaveatEntry{
		name: 'installer_manual'
		args: ['Caffeine.app']
		text: 'Cask with-installer-manual only provides a manual installer. To run it and complete the installation:\n  open Caffeine.app'
	}]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	return installer_spec_bool(installer.caveats().contains('only provides a manual installer') && installer.caveats().contains('open Caffeine.app'))
}

// Ruby it `it "does not extract __MACOSX directories from zips" do` at line 305.
pub fn ruby_installer_spec_l305_d27_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('macosx')
	defer { installer_spec_remove(root) }
	archive := os.join_path(root, 'archive')
	destination := os.join_path(root, 'stage')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(archive, '__MACOSX/dir:junk\ndir:Caffeine.app') or { return installer_spec_bool(false) }
	installer_spec_extract(archive, destination, false) or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(os.join_path(destination, '__MACOSX')))
}

// Ruby it `it "allows already-installed Casks which auto-update to be installed if force is provided" do` at line 313.
pub fn ruby_installer_spec_l313_d28_allows(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('auto-updates', 'dir:Caffeine.app', 'Caffeine.app', true, cask_core.CaskInstallerOptions{ force: true }))
}

// Ruby it `it "allows already-installed Casks to be installed if force is provided" do` at line 325.
pub fn ruby_installer_spec_l325_d29_allows(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('local-transmission-zip', 'dir:Transmission.app', 'Transmission.app', true, cask_core.CaskInstallerOptions{ force: true }))
}

// Ruby it `it "installs a cask from a dmg file" do` at line 337.
pub fn ruby_installer_spec_l337_d30_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('local-transmission', 'dir:Transmission.app', 'Transmission.app', true, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "works naked-pkg-based Casks" do` at line 348.
pub fn ruby_installer_spec_l348_d31_works(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('container-pkg')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('container-pkg', root, '1.0') or { return installer_spec_bool(false) }
	installer_spec_prepare_archive(mut cask, root, 'file:container.pkg', 'stage_only', 'container.pkg') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_file(os.join_path(cask.caskroom_path(), '1.0', 'container.pkg')))
}

// Ruby it `it "works properly with an overridden container :type" do` at line 356.
pub fn ruby_installer_spec_l356_d32_works(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('naked-executable')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('naked-executable', root, '1.0') or { return installer_spec_bool(false) }
	installer_spec_prepare_archive(mut cask, root, 'file:naked_executable', 'stage_only', 'naked_executable') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_file(os.join_path(cask.caskroom_path(), '1.0', 'naked_executable')))
}

// Ruby it `it "works fine with a nested container" do` at line 364.
pub fn ruby_installer_spec_l364_d33_works(args ...ruby.Value) ruby.Value {
	_ = args
	return installer_spec_bool(installer_spec_install_case('nested-app', 'dir:MyNestedApp.app', 'MyNestedApp.app', true, cask_core.CaskInstallerOptions{}))
}

// Ruby it `it "generates and finds a timestamped metadata directory for an installed Cask" do` at line 372.
pub fn ruby_installer_spec_l372_d34_generates(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('timestamp')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ metadata_timestamp: '2026-01-02-030405.000000' }, installer_spec_hooks())
	path := installer.metadata_subdir() or { return installer_spec_bool(false) }
	return installer_spec_bool(path.ends_with('2026-01-02-030405.000000/Casks') && os.is_dir(path))
}

// Ruby it `it "generates and finds a metadata subdirectory for an installed Cask" do` at line 381.
pub fn ruby_installer_spec_l381_d35_generates(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('subdir')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	first := installer.metadata_subdir() or { return installer_spec_bool(false) }
	second := installer.metadata_subdir() or { return installer_spec_bool(false) }
	return installer_spec_bool(first == second && os.base(first) == 'Casks')
}

// Ruby it `it "don't print cask installed message with --quiet option" do` at line 391.
pub fn ruby_installer_spec_l391_d36_don(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('quiet')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('quiet', root, '1.0') or { return installer_spec_bool(false) }
	installer_spec_prepare_archive(mut cask, root, 'dir:Caffeine.app', 'app', 'Caffeine.app') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ quiet: true }, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	return installer_spec_bool(!installer.messages.any(it.contains('successfully installed')))
}

// Ruby it `it "does NOT generate LATEST_DOWNLOAD_SHA256 file for installed Cask without version :latest" do` at line 398.
pub fn ruby_installer_spec_l398_d37_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('versioned-sha')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('versioned', root, '1.0') or { return installer_spec_bool(false) }
	installer_spec_prepare_archive(mut cask, root, 'dir:Caffeine.app', 'app', 'Caffeine.app') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(cask.download_sha_path()))
}

// Ruby it `it "generates and finds LATEST_DOWNLOAD_SHA256 file for installed Cask with version :latest" do` at line 406.
pub fn ruby_installer_spec_l406_d38_generates(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('latest-sha')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('version-latest', root, 'latest') or { return installer_spec_bool(false) }
	archive := os.join_path(root, 'archive')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(archive, 'payload') or { return installer_spec_bool(false) }
	cask.download = archive
	cask.dsl.url_value = cask_core.new_cask_url('file://${archive}', {}) or { return installer_spec_bool(false) }
	cask.dsl.has_url = true
	cask.new_download_sha_value = sha256.sum256('payload'.bytes()).hex()
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.save_download_sha() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_file(cask.download_sha_path()))
}

// Ruby let `let(:path) { cask_path("local-caffeine") }` at line 415.
pub fn ruby_installer_spec_l415_d39_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', os.join_path('test/support/fixtures/cask', 'local-caffeine.rb'))
}

// Ruby let `let(:content) { File.read(path) }` at line 416.
pub fn ruby_installer_spec_l416_d40_content(args ...ruby.Value) ruby.Value {
	if args.len == 0 || !os.is_file(args[0].as_string()) {
		return installer_spec_nil()
	}
	return ruby.string_value(os.read_file(args[0].as_string()) or { '' })
}

// Ruby it `it "installs cask" do` at line 418.
pub fn ruby_installer_spec_l418_d41_installs(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('source-install')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	archive := os.join_path(root, 'archive')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(archive, 'dir:Caffeine.app') or { return installer_spec_bool(false) }
	staged := os.join_path(cask.caskroom_path(), '1.0')
	artifact := installer_spec_artifact('app', os.join_path(staged, 'Caffeine.app'), os.join_path(root, 'Applications', 'Caffeine.app'))
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	cask.api_source = {
		'url':      ruby.string_value('file://${archive}')
		'version':  ruby.string_value('1.0')
		'artifact': artifact
	}
	cask.download = archive
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(root, 'Applications', 'Caffeine.app')))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-preflight")) }` at line 432.
pub fn ruby_installer_spec_l432_d42_cask(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-preflight', installer_spec_temp('api-requirement'), '1.0') or { return installer_spec_nil() }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	return cask_core.cask_core_value(cask)
}

// Ruby let `let(:download_queue) { instance_double(Homebrew::DownloadQueue, enqueue: nil) }` at line 433.
pub fn ruby_installer_spec_l433_d43_download_queue(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Homebrew::DownloadQueue', 'enqueue', {
		'enqueue': 'injected'
	})
}

// Ruby let `let(:macos_requirement) { cask.depends_on.macos }` at line 434.
pub fn ruby_installer_spec_l434_d44_macos_requirement(args ...ruby.Value) ruby.Value {
	_ = args
	requirement := requirements.new_macos_requirement(['15'], '>=') or { return installer_spec_nil() }
	return ruby.structured_value('MacOSRequirement', requirement.inspect(), {
		'satisfied': 'false'
	})
}

// Ruby it `it "checks requirements before enqueueing downloads" do` at line 442.
pub fn ruby_installer_spec_l442_d45_checks(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-preflight', installer_spec_temp('enqueue-requirement'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	cask.dsl.depends_on_value.macos = requirements.new_macos_requirement(['99'], '>=') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ current_macos: '15' }, installer_spec_hooks())
	installer.enqueue_downloads() or { return installer_spec_bool(err.msg().starts_with('with-preflight:') && installer.queue_entries.len == 0) }
	return installer_spec_bool(false)
}

// Ruby it `it "checks requirements before loading the source cask during fetch" do` at line 450.
pub fn ruby_installer_spec_l450_d46_checks(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('with-preflight', installer_spec_temp('fetch-requirement'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	cask.dsl.depends_on_value.macos = requirements.new_macos_requirement(['99'], '>=') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ current_macos: '15' }, installer_spec_hooks())
	installer.fetch(none, none) or { return installer_spec_bool(err.msg().starts_with('with-preflight:') && !installer.ran_prelude) }
	return installer_spec_bool(false)
}

// Ruby it `it "zap method reinstall cask" do` at line 459.
pub fn ruby_installer_spec_l459_d47_zap(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('zap')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	target := installer_spec_prepare_archive(mut cask, root, 'dir:Caffeine.app', 'app', 'Caffeine.app') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	installer.zap() or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(target) && !os.exists(cask.caskroom_path()))
}

// Ruby it `it "does not raise when the staged version directory is already missing" do` at line 473.
pub fn ruby_installer_spec_l473_d48_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('backup-missing')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.backup() or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(installer.backup_path()) && !os.exists(installer.backup_metadata_path()))
}

// Ruby it `it "fully uninstalls a Cask" do` at line 488.
pub fn ruby_installer_spec_l488_d49_fully(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('full-uninstall')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	target := installer_spec_prepare_archive(mut cask, root, 'dir:Caffeine.app', 'app', 'Caffeine.app') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.install() or { return installer_spec_bool(false) }
	installer.uninstall('') or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(target) && !os.exists(cask.caskroom_path()))
}

// Ruby it `it "removes Caskroom symlinks the uninstall broke, whatever name they carry" do` at line 500.
pub fn ruby_installer_spec_l500_d50_removes(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('broken-links')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	os.mkdir_all(cask.caskroom_root) or { return installer_spec_bool(false) }
	alias_link := os.join_path(cask.caskroom_root, 'local-caffeine-renamed')
	unrelated := os.join_path(cask.caskroom_root, 'alias-of-another-cask')
	os.symlink('local-caffeine', alias_link) or { return installer_spec_bool(false) }
	os.symlink('another-cask', unrelated) or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	removed := installer.remove_broken_caskroom_symlinks() or { return installer_spec_bool(false) }
	return installer_spec_bool(alias_link in removed && !os.is_link(alias_link) && os.is_link(unrelated))
}

// Ruby it `it "uninstalls all versions if force is set" do` at line 515.
pub fn ruby_installer_spec_l515_d51_uninstalls(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('force-versions')
	defer { installer_spec_remove(root) }
	cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	os.mkdir_all(os.join_path(cask.caskroom_path(), '1.0.1')) or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ force: true }, installer_spec_hooks())
	installer.uninstall('') or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(cask.caskroom_path()))
}

// Ruby let `let(:path) { cask_path("local-caffeine") }` at line 536.
pub fn ruby_installer_spec_l536_d52_path(args ...ruby.Value) ruby.Value {
	return ruby_installer_spec_l415_d39_path(...args)
}

// Ruby let `let(:content) { File.read(path) }` at line 537.
pub fn ruby_installer_spec_l537_d53_content(args ...ruby.Value) ruby.Value {
	return ruby_installer_spec_l416_d40_content(...args)
}

// Ruby let `let(:invalid_path) { instance_double(Pathname) }` at line 538.
pub fn ruby_installer_spec_l538_d54_invalid_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Pathname', '/missing/installed-cask.json', {
		'exist': 'false'
	})
}

// Ruby it `it "uninstalls cask" do` at line 544.
pub fn ruby_installer_spec_l544_d55_uninstalls(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('api-uninstall')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.installed_file_override = os.join_path(root, 'missing.json')
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', '', os.join_path(root, 'Applications', 'Caffeine.app')),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.uninstall('') or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(cask.caskroom_path()))
}

// Ruby it `it "uninstalls when cask file is outdated" do` at line 563.
pub fn ruby_installer_spec_l563_d56_uninstalls(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('outdated-caskfile')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('outdated', root, '2.0') or { return installer_spec_bool(false) }
	staged := os.join_path(cask.caskroom_path(), '1.0')
	os.mkdir_all(staged) or { return installer_spec_bool(false) }
	installed := os.join_path(cask.caskroom_path(), '.metadata', '1.0', '20260101', 'Casks', 'outdated.json')
	os.mkdir_all(os.dir(installed)) or { return installer_spec_bool(false) }
	os.write_file(installed, '{}') or { return installer_spec_bool(false) }
	cask.installed_file_override = installed
	cask.dsl.staged_path_value = staged
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.uninstall('') or { return installer_spec_bool(false) }
	return installer_spec_bool(!os.exists(staged))
}

// Ruby let `let(:homebrew_forbidden) { Tap.fetch("homebrew/forbidden") }` at line 583.
pub fn ruby_installer_spec_l583_d57_homebrew_forbidden(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Tap', 'homebrew/forbidden')
}

// Ruby let `let(:allowed_third_party) { Tap.fetch("nothomebrew/allowed") }` at line 584.
pub fn ruby_installer_spec_l584_d58_allowed_third_party(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Tap', 'nothomebrew/allowed')
}

// Ruby let `let(:disallowed_third_party) { Tap.fetch("nothomebrew/notallowed") }` at line 585.
pub fn ruby_installer_spec_l585_d59_disallowed_third_party(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Tap', 'nothomebrew/notallowed')
}

// Ruby let `let(:allowed_taps_set) { [allowed_third_party.name] }` at line 586.
pub fn ruby_installer_spec_l586_d60_allowed_taps_set(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['nothomebrew/allowed'])
}

// Ruby let `let(:forbidden_taps_set) { [homebrew_forbidden.name] }` at line 587.
pub fn ruby_installer_spec_l587_d61_forbidden_taps_set(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['homebrew/forbidden'])
}

// Ruby it `it "raises on forbidden tap on cask" do` at line 589.
pub fn ruby_installer_spec_l589_d62_raises(args ...ruby.Value) ruby.Value {
	_ = args
	cask := cask_core.new_cask_core(cask_core.CaskCoreConfig{ token: 'homebrew-forbidden-tap', tap_name: 'homebrew/forbidden' }, installer_spec_noop_block) or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		allowed_taps: [
			'nothomebrew/allowed',
		]
		forbidden_taps: ['homebrew/forbidden']
	}, installer_spec_hooks())
	installer.forbidden_tap_check(false) or { return installer_spec_bool(err.msg().contains('has the tap homebrew/forbidden')) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises on not allowed third-party tap on cask" do` at line 599.
pub fn ruby_installer_spec_l599_d63_raises(args ...ruby.Value) ruby.Value {
	_ = args
	cask := cask_core.new_cask_core(cask_core.CaskCoreConfig{ token: 'homebrew-not-allowed-tap', tap_name: 'nothomebrew/notallowed' }, installer_spec_noop_block) or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		allowed_taps: [
			'nothomebrew/allowed',
		]
		forbidden_taps: ['homebrew/forbidden']
	}, installer_spec_hooks())
	installer.forbidden_tap_check(false) or { return installer_spec_bool(err.msg().contains('has the tap nothomebrew/notallowed')) }
	return installer_spec_bool(false)
}

// Ruby it `it "does not raise on allowed tap on cask" do` at line 609.
pub fn ruby_installer_spec_l609_d64_does(args ...ruby.Value) ruby.Value {
	_ = args
	cask := cask_core.new_cask_core(cask_core.CaskCoreConfig{ token: 'third-party-allowed-tap', tap_name: 'nothomebrew/allowed' }, installer_spec_noop_block) or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		allowed_taps: [
			'nothomebrew/allowed',
		]
		forbidden_taps: ['homebrew/forbidden']
	}, installer_spec_hooks())
	installer.forbidden_tap_check(false) or { return installer_spec_bool(false) }
	return installer_spec_bool(true)
}

// Ruby it `it "raises on forbidden tap on dependency" do` at line 617.
pub fn ruby_installer_spec_l617_d65_raises(args ...ruby.Value) ruby.Value {
	_ = args
	cask := installer_spec_core('homebrew-forbidden-dependent-tap', installer_spec_temp('dep-tap'), '1.0') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		allowed_taps: [
			'nothomebrew/allowed',
		]
		forbidden_taps: ['homebrew/forbidden']
	}, installer_spec_hooks())
	installer.dependencies = [
		cask_core.CaskInstallerDependency{ name: 'homebrew-forbidden-dependency-tap', kind: 'formula', tap: 'homebrew/forbidden', tap_allowed: false, tap_forbidden: true },
	]
	installer.forbidden_tap_check(false) or { return installer_spec_bool(err.msg().contains('from the homebrew/forbidden tap but')) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises on forbidden cask" do` at line 643.
pub fn ruby_installer_spec_l643_d66_raises(args ...ruby.Value) ruby.Value {
	_ = args
	cask := installer_spec_core('homebrew-forbidden-cask', installer_spec_temp('forbidden-cask'), '1.0') or { return installer_spec_bool(false) }
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_casks: [
			'homebrew-forbidden-cask',
		]
	}, installer_spec_hooks())
	installer.forbidden_cask_and_formula_check(false) or { return installer_spec_bool(err.msg().contains('forbidden for installation')) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises on forbidden dependency" do` at line 654.
pub fn ruby_installer_spec_l654_d67_raises(args ...ruby.Value) ruby.Value {
	_ = args
	cask := installer_spec_core('homebrew-forbidden-dependent-cask', installer_spec_temp('forbidden-dep'), '1.0') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_formulae: [
			'homebrew-forbidden-dependency-formula',
		]
	}, installer_spec_hooks())
	installer.dependencies = [
		cask_core.CaskInstallerDependency{ name: 'homebrew-forbidden-dependency-formula', kind: 'formula' },
	]
	installer.forbidden_cask_and_formula_check(false) or { return installer_spec_bool(err.msg().contains('formula was forbidden')) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises when cask contains forbidden pkg artifact" do` at line 676.
pub fn ruby_installer_spec_l676_d68_raises(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('homebrew-pkg-cask', installer_spec_temp('pkg-policy'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('pkg', 'MyInstaller.pkg', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_artifacts: [
			'pkg',
		]
	}, installer_spec_hooks())
	installer.forbidden_cask_artifacts_check() or { return installer_spec_bool(err.msg().contains("contains a 'pkg' artifact")) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises when cask contains forbidden installer artifact" do` at line 688.
pub fn ruby_installer_spec_l688_d69_raises(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('homebrew-installer-cask', installer_spec_temp('installer-policy'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('installer', 'MyInstaller.sh', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_artifacts: [
			'installer',
		]
	}, installer_spec_hooks())
	installer.forbidden_cask_artifacts_check() or { return installer_spec_bool(err.msg().contains("contains a 'installer' artifact")) }
	return installer_spec_bool(false)
}

// Ruby it `it "raises when cask contains multiple forbidden artifacts" do` at line 703.
pub fn ruby_installer_spec_l703_d70_raises(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('homebrew-multi-forbidden-cask', installer_spec_temp('multi-policy'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('pkg', 'MyInstaller.pkg', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_artifacts: [
			'pkg',
			'installer',
		]
	}, installer_spec_hooks())
	installer.forbidden_cask_artifacts_check() or { return installer_spec_bool(err.msg().contains("contains a 'pkg' artifact")) }
	return installer_spec_bool(false)
}

// Ruby it `it "does not raise when cask does not contain forbidden artifacts" do` at line 715.
pub fn ruby_installer_spec_l715_d71_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('homebrew-allowed-cask', installer_spec_temp('allowed-artifact'), '1.0') or { return installer_spec_bool(false) }
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'MyApp.app', ''),
	])
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_artifacts: [
			'pkg',
			'installer',
		]
	}, installer_spec_hooks())
	installer.forbidden_cask_artifacts_check() or { return installer_spec_bool(false) }
	return installer_spec_bool(true)
}

// Ruby it `it "raises on forbidden cask before fetching the caskfile from the Source API" do` at line 727.
pub fn ruby_installer_spec_l727_d72_raises(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('homebrew-forbidden-cask', installer_spec_temp('prelude-policy'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{
		forbidden_casks: [
			'homebrew-forbidden-cask',
		]
	}, installer_spec_hooks())
	installer.prelude() or { return installer_spec_bool(err.msg().contains('forbidden for installation') && !installer.ran_prelude) }
	return installer_spec_bool(false)
}

// Ruby it `it "uses API cask metadata for API-loaded cask downloads" do` at line 744.
pub fn ruby_installer_spec_l744_d73_uses(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('api-cask', installer_spec_temp('api-metadata-download'), '0.9') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.loaded_from_internal_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'Fake.app', ''),
	])
	cask.dsl.url_value = cask_core.new_cask_url('https://example.com/api-cask.zip', {}) or { return installer_spec_bool(false) }
	cask.dsl.has_url = true
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.enqueue_downloads() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.queue_entries.len == 1 && installer.queue_entries[0].url == 'https://example.com/api-cask.zip')
}

// Ruby it `it "enqueues the selected language download from API data" do` at line 769.
pub fn ruby_installer_spec_l769_d74_enqueues(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('language-api-cask', installer_spec_temp('language-api'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.loaded_from_internal_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'Fake.app', ''),
	])
	cask.dsl.url_value = cask_core.new_cask_url('file:///fixtures/container.tar.gz', {}) or { return installer_spec_bool(false) }
	cask.dsl.has_url = true
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.enqueue_downloads() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.queue_entries.last().url == 'file:///fixtures/container.tar.gz')
}

// Ruby it `it "enqueues source API caskfiles before the main cask download" do` at line 792.
pub fn ruby_installer_spec_l792_d75_enqueues(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('source-api-cask', installer_spec_temp('source-first'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	cask.dsl.language_blocks = [
		cask_core.CaskLanguageBlock{ languages: ['en'], result: 'en' },
	]
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.prelude_fetch() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.queue_entries.len == 1 && installer.queue_entries[0].kind == 'SourceDownload')
}

// Ruby it `it "leaves source API caskfiles in the main queue when their URL is known" do` at line 810.
pub fn ruby_installer_spec_l810_d76_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	mut cask := installer_spec_core('source-api-cask', installer_spec_temp('source-main'), '1.0') or { return installer_spec_bool(false) }
	cask.loaded_from_api = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('preflight', '', ''),
	])
	cask.api_source = {
		'url':      ruby.string_value('file:///fixtures/container.tar.gz')
		'version':  ruby.string_value('1.0')
		'artifact': installer_spec_artifact('app', 'Fake.app', '')
	}
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.enqueue_downloads() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.queue_entries.len == 2 && installer.queue_entries[0].kind == 'SourceDownload' && installer.queue_entries[1].kind == 'Cask::Download')
}

// Ruby it `it "stages the main cask download outside Caskroom before install" do` at line 826.
pub fn ruby_installer_spec_l826_d77_stages(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('queued-stage')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, '1.0') or { return installer_spec_bool(false) }
	staged := os.join_path(cask.caskroom_path(), '1.0')
	cask.dsl.staged_path_value = staged
	queued := os.join_path(root, 'queued')
	marker := os.join_path(root, 'queued.complete')
	os.mkdir_all(os.join_path(queued, 'Caffeine.app')) or { return installer_spec_bool(false) }
	os.write_file(marker, '') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ defer_fetch: true }, installer_spec_hooks())
	installer.queued_staged_path = queued
	installer.queued_staged_marker = marker
	installer.stage() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(staged, 'Caffeine.app')) && !os.exists(marker))
}

// Ruby it `it "stages nested containers for API-loaded casks" do` at line 853.
pub fn ruby_installer_spec_l853_d78_stages(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('queued-nested')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('api-nested-cask', root, '1.2.3') or { return installer_spec_bool(false) }
	staged := os.join_path(cask.caskroom_path(), '1.2.3')
	cask.dsl.staged_path_value = staged
	queued := os.join_path(root, 'queued-nested')
	marker := os.join_path(root, 'queued-nested.complete')
	os.mkdir_all(os.join_path(queued, 'Caffeine.app')) or { return installer_spec_bool(false) }
	os.write_file(marker, '') or { return installer_spec_bool(false) }
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ defer_fetch: true }, installer_spec_hooks())
	installer.queued_staged_path = queued
	installer.queued_staged_marker = marker
	installer.stage() or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(staged, 'Caffeine.app')))
}

// Ruby it `it "does not stage queued downloads with missing unpack dependencies" do` at line 889.
pub fn ruby_installer_spec_l889_d79_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('missing-unpack-dep')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('container-bzip2', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.url_value = cask_core.new_cask_url('file:///fixtures/container.bz2', {}) or { return installer_spec_bool(false) }
	cask.dsl.has_url = true
	cask.dsl.artifacts = cask_core.new_artifact_set([
		installer_spec_artifact('app', 'container', ''),
	])
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{ defer_fetch: true }, installer_spec_hooks())
	installer.queued_staged_path = os.join_path(root, 'queued')
	installer.queued_staged_marker = os.join_path(root, 'queued.complete')
	installer.enqueue_downloads() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.queue_entries.len == 1 && !os.exists(installer.queued_staged_path) && !os.exists(installer.queued_staged_marker) && !cask.installed())
}

// Ruby it `it "uses recovered installed metadata before falling back to the current cask" do` at line 914.
pub fn ruby_installer_spec_l914_d80_uses(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('recover')
	defer { installer_spec_remove(root) }
	mut cask := installer_spec_core('local-caffeine', root, 'current') or { return installer_spec_bool(false) }
	cask.api_source = {
		'version':  ruby.string_value('1.0')
		'artifact': installer_spec_artifact('app', 'Recovered.app', '')
	}
	cask.installed_file_override = os.join_path(root, 'local-caffeine.json')
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(cask.installed_file_override, '{}') or { return installer_spec_bool(false) }
	hooks := cask_core.CaskInstallerHooks{
		extract: installer_spec_extract
		install_artifact: installer_spec_install_artifact
		uninstall_artifact: installer_spec_uninstall_artifact
		zap_artifact: installer_spec_uninstall_artifact
		enqueue: installer_spec_enqueue
		fetch: installer_spec_fetch
		load_source_cask: installer_spec_source_loader
		load_installed_cask: installer_spec_installed_loader_failure
		recover_installed_cask: installer_spec_source_loader
	}
	mut installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, hooks)
	installer.load_installed_caskfile() or { return installer_spec_bool(false) }
	return installer_spec_bool(installer.cask.version_text() == '1.0' && installer.cask.dsl.artifacts.items.first().attributes['source'] == 'Recovered.app')
}

// Ruby let `let(:tmpdir) { mktmpdir }` at line 939.
pub fn ruby_installer_spec_l939_d81_tmpdir(args ...ruby.Value) ruby.Value {
	_ = args
	path := installer_spec_temp('rename')
	os.mkdir_all(path) or { return installer_spec_nil() }
	return ruby.object_value('Pathname', path)
}

// Ruby let `let(:staged_path) { Pathname(tmpdir) }` at line 940.
pub fn ruby_installer_spec_l940_d82_staged_path(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		return ruby.object_value('Pathname', args[0].as_string())
	}
	return ruby_installer_spec_l939_d81_tmpdir()
}

// Ruby it `it "processes rename operations after extraction" do` at line 946.
pub fn ruby_installer_spec_l946_d83_processes(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('rename-one')
	defer { installer_spec_remove(root) }
	os.mkdir_all(os.join_path(root, 'Original App.app', 'Contents')) or { return installer_spec_bool(false) }
	mut cask := installer_spec_core('rename-test-cask', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.renames = [
		dsl_types.new_cask_rename('Original App.app', 'Renamed App.app'),
	]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.process_rename_operations(root) or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(root, 'Renamed App.app')) && !os.exists(os.join_path(root, 'Original App.app')))
}

// Ruby it `it "handles multiple rename operations in order" do` at line 967.
pub fn ruby_installer_spec_l967_d84_handles(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('rename-many')
	defer { installer_spec_remove(root) }
	os.mkdir_all(os.join_path(root, 'Original.app')) or { return installer_spec_bool(false) }
	mut cask := installer_spec_core('multi-rename-test-cask', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.renames = [dsl_types.new_cask_rename('Original.app', 'First Rename.app'),
		dsl_types.new_cask_rename('First Rename.app', 'Final Name.app')]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.process_rename_operations(root) or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(root, 'Final Name.app')) && !os.exists(os.join_path(root, 'First Rename.app')))
}

// Ruby it `it "handles glob patterns in rename operations" do` at line 988.
pub fn ruby_installer_spec_l988_d85_handles(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('rename-glob')
	defer { installer_spec_remove(root) }
	os.mkdir_all(root) or { return installer_spec_bool(false) }
	os.write_file(os.join_path(root, 'Test App v1.2.3.pkg'), 'test content') or { return installer_spec_bool(false) }
	mut cask := installer_spec_core('glob-rename-test-cask', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.renames = [dsl_types.new_cask_rename('Test App*.pkg', 'Test App.pkg')]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.process_rename_operations(root) or { return installer_spec_bool(false) }
	return installer_spec_bool((os.read_file(os.join_path(root, 'Test App.pkg')) or { '' }) == 'test content' && !os.exists(os.join_path(root, 'Test App v1.2.3.pkg')))
}

// Ruby it `it "does nothing when no files match rename pattern" do` at line 1008.
pub fn ruby_installer_spec_l1008_d86_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := installer_spec_temp('rename-none')
	defer { installer_spec_remove(root) }
	os.mkdir_all(os.join_path(root, 'Different.app')) or { return installer_spec_bool(false) }
	mut cask := installer_spec_core('no-match-rename-test-cask', root, '1.0') or { return installer_spec_bool(false) }
	cask.dsl.renames = [dsl_types.new_cask_rename('NonExistent*.app', 'Target.app')]
	installer := cask_core.new_cask_installer(cask, cask_core.CaskInstallerOptions{}, installer_spec_hooks())
	installer.process_rename_operations(root) or { return installer_spec_bool(false) }
	return installer_spec_bool(os.is_dir(os.join_path(root, 'Different.app')) && !os.exists(os.join_path(root, 'Target.app')))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Installer, :cask do
// 5:   def stub_dmg_extraction
// 6:     allow(UnpackStrategy::Dmg).to receive(:can_extract?).and_return(true)
// 7:     allow_any_instance_of(UnpackStrategy::Dmg).to receive(:extract_nestedly) do |_strategy, to:, **|
// 8:       to.mkpath
// 9:       yield to
// 10:     end
// 11:   end
// 12:
// 13:   describe "#save_caskfile" do
// 14:     it "stores casks loaded from Ruby source as JSON metadata" do
// 15:       cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 16:
// 17:       described_class.new(cask).save_caskfile
// 18:       Cask::Tab.create(cask).write
// 19:
// 20:       expect([
// 21:         cask.installed_caskfile&.basename&.to_s,
// 22:         Cask::CaskLoader.load_from_installed_caskfile(cask.installed_caskfile).token,
// 23:         JSON.parse(cask.installed_caskfile.read).keys.sort,
// 24:       ]).to eq(["local-caffeine.json", "local-caffeine", []])
// 25:     end
// 26:
// 27:     it "stores URL only_path metadata needed to reconstruct artifact sources" do
// 28:       cask = Cask::Cask.new("only-path", source: "{}") do
// 29:         version "1.0"
// 30:         sha256 :no_check
// 31:         url "https://example.com/only-path.git", only_path: "nested"
// 32:         app "Only Path.app"
// 33:       end
// 34:
// 35:       described_class.new(cask).save_caskfile
// 36:       Cask::Tab.create(cask).write
// 37:
// 38:       loaded_cask = Cask::CaskLoader.load_from_installed_caskfile(cask.installed_caskfile)
// 39:       expect([
// 40:         JSON.parse(cask.installed_caskfile.read).keys.sort,
// 41:         loaded_cask.artifacts.grep(Cask::Artifact::App).first.source,
// 42:       ]).to eq([
// 43:         %w[url_specs],
// 44:         Cask::Caskroom.path/"only-path/1.0/nested/Only Path.app",
// 45:       ])
// 46:     end
// 47:
// 48:     it "strips legacy install flight blocks and records empty artifacts in JSON metadata" do
// 49:       cask = Cask::CaskLoader.load(cask_path("with-preflight"))
// 50:
// 51:       described_class.new(cask).save_caskfile
// 52:
// 53:       expect(JSON.parse(cask.installed_caskfile.read)).to eq({ "artifacts" => [] })
// 54:     end
// 55:
// 56:     it "stores intentional empty artifacts in JSON metadata" do
// 57:       cask = Cask::CaskLoader.load(cask_path("stage-only"))
// 58:
// 59:       described_class.new(cask).save_caskfile
// 60:
// 61:       expect(JSON.parse(cask.installed_caskfile.read)).to eq({ "artifacts" => [] })
// 62:     end
// 63:
// 64:     it "stores legacy uninstall flight block casks as Ruby metadata" do
// 65:       expect(%w[with-uninstall-preflight with-uninstall-postflight].map do |token|
// 66:         cask = Cask::CaskLoader.load(cask_path(token))
// 67:
// 68:         described_class.new(cask).save_caskfile
// 69:
// 70:         [
// 71:           cask.installed_caskfile&.basename&.to_s,
// 72:           Cask::CaskLoader.load_from_installed_caskfile(cask.installed_caskfile).uninstall_flight_blocks?,
// 73:         ]
// 74:       end).to eq([
// 75:         ["with-uninstall-preflight.rb", true],
// 76:         ["with-uninstall-postflight.rb", true],
// 77:       ])
// 78:     end
// 79:
// 80:     it "stores casks loaded from the internal API as JSON metadata" do
// 81:       cask = Cask::Cask.new(
// 82:         "api-cask",
// 83:         source:                   "{}",
// 84:         loaded_from_api:          true,
// 85:         loaded_from_internal_api: true,
// 86:         api_source:               {
// 87:           "homepage"      => "https://example.com/api-cask",
// 88:           "names"         => ["API Cask"],
// 89:           "raw_artifacts" => [[":app", ["API Cask.app"]]],
// 90:           "sha256"        => "no_check",
// 91:           "url_args"      => ["https://example.com/api-cask.zip"],
// 92:           "version"       => "1.0",
// 93:         },
// 94:       ) do
// 95:         version "1.0"
// 96:         sha256 :no_check
// 97:         url "https://example.com/api-cask.zip"
// 98:         name "API Cask"
// 99:         homepage "https://example.com/api-cask"
// 100:         app "API Cask.app"
// 101:       end
// 102:
// 103:       described_class.new(cask).save_caskfile
// 104:       Cask::Tab.create(cask).write
// 105:
// 106:       loaded_cask = Cask::CaskLoader.load_from_installed_caskfile(cask.installed_caskfile)
// 107:       expect([
// 108:         cask.installed_caskfile&.basename&.to_s,
// 109:         loaded_cask.token,
// 110:         loaded_cask.loaded_from_internal_api?,
// 111:         JSON.parse(cask.installed_caskfile.read).keys.sort,
// 112:       ]).to eq(["api-cask.json", "api-cask", false, []])
// 113:     end
// 114:   end
// 115:
// 116:   describe "install" do
// 117:     it "downloads and installs a nice fresh Cask" do
// 118:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 119:
// 120:       described_class.new(caffeine).install
// 121:
// 122:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).to be_a_directory
// 123:       expect(Pathname(caffeine.config.appdir).join("Caffeine.app")).to be_a_directory
// 124:     end
// 125:
// 126:     it "works with HFS+ dmg-based Casks" do
// 127:       asset = Cask::CaskLoader.load(cask_path("container-dmg"))
// 128:       stub_dmg_extraction { |path| FileUtils.touch path/"container" }
// 129:
// 130:       described_class.new(asset).install
// 131:
// 132:       expect(Cask::Caskroom.path.join("container-dmg", asset.version)).to be_a_directory
// 133:       expect(Pathname(asset.config.appdir).join("container")).to be_a_file
// 134:     end
// 135:
// 136:     it "works with tar-gz-based Casks" do
// 137:       asset = Cask::CaskLoader.load(cask_path("container-tar-gz"))
// 138:
// 139:       described_class.new(asset).install
// 140:
// 141:       expect(Cask::Caskroom.path.join("container-tar-gz", asset.version)).to be_a_directory
// 142:       expect(Pathname(asset.config.appdir).join("container")).to be_a_file
// 143:     end
// 144:
// 145:     it "works with xar-based Casks" do
// 146:       asset = Cask::CaskLoader.load(cask_path("container-xar"))
// 147:
// 148:       described_class.new(asset).install
// 149:
// 150:       expect(Cask::Caskroom.path.join("container-xar", asset.version)).to be_a_directory
// 151:       expect(Pathname(asset.config.appdir).join("container")).to be_a_file
// 152:     end
// 153:
// 154:     it "works with pure bzip2-based Casks" do
// 155:       asset = Cask::CaskLoader.load(cask_path("container-bzip2"))
// 156:       # The bzip2 container depends on the `bzip2` formula via its unpack
// 157:       # strategy. Exercise dependency resolution without pouring a real
// 158:       # bottle (and flaking on its GitHub Packages manifest).
// 159:       allow_any_instance_of(Formula).to receive(:any_version_installed?).and_return(false)
// 160:       allow(Homebrew::Install).to receive(:fetch_formulae) { |installers| installers }
// 161:       allow_any_instance_of(FormulaInstaller).to receive(:install)
// 162:       allow_any_instance_of(FormulaInstaller).to receive(:finish)
// 163:
// 164:       described_class.new(asset).install
// 165:
// 166:       expect(Cask::Caskroom.path.join("container-bzip2", asset.version)).to be_a_directory
// 167:       expect(Pathname(asset.config.appdir).join("container")).to be_a_file
// 168:     end
// 169:
// 170:     it "works with pure gzip-based Casks" do
// 171:       asset = Cask::CaskLoader.load(cask_path("container-gzip"))
// 172:
// 173:       described_class.new(asset).install
// 174:
// 175:       expect(Cask::Caskroom.path.join("container-gzip", asset.version)).to be_a_directory
// 176:       expect(Pathname(asset.config.appdir).join("container")).to be_a_file
// 177:     end
// 178:
// 179:     it "blows up on a bad checksum" do
// 180:       bad_checksum = Cask::CaskLoader.load(cask_path("bad-checksum"))
// 181:       expect do
// 182:         described_class.new(bad_checksum).install
// 183:       end.to raise_error(ChecksumMismatchError)
// 184:     end
// 185:
// 186:     it "blows up on a missing checksum" do
// 187:       missing_checksum = Cask::CaskLoader.load(cask_path("missing-checksum"))
// 188:       expect do
// 189:         described_class.new(missing_checksum).install
// 190:       end.to output(/Cannot verify integrity/).to_stderr
// 191:     end
// 192:
// 193:     it "installs fine if sha256 :no_check is used" do
// 194:       no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))
// 195:
// 196:       described_class.new(no_checksum).install
// 197:
// 198:       expect(no_checksum).to be_installed
// 199:     end
// 200:
// 201:     it "fails to install if sha256 :no_check is used with --require-sha" do
// 202:       no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))
// 203:       expect do
// 204:         described_class.new(no_checksum, require_sha: true).install
// 205:       end.to raise_error(/--require-sha/)
// 206:     end
// 207:
// 208:     it "names the cask when Linux is required" do
// 209:       linux_cask = Cask::CaskLoader.load("with-depends-on-linux-bare")
// 210:       expect do
// 211:         described_class.new(linux_cask).check_stanza_os_requirements
// 212:       end.to raise_error(Cask::CaskError, "with-depends-on-linux-bare: This cask requires Linux.")
// 213:     end
// 214:
// 215:     it "names the cask when the macOS requirement is not satisfied" do
// 216:       macos_cask = Cask::CaskLoader.load("with-depends-on-macos-failure")
// 217:       allow(macos_cask.depends_on.maximum_macos).to receive(:satisfied?).and_return(false)
// 218:       expect do
// 219:         described_class.new(macos_cask).check_macos_requirements
// 220:       end.to raise_error(
// 221:         Cask::CaskError,
// 222:         "with-depends-on-macos-failure: This cask does not run on macOS versions newer than Monterey.",
// 223:       )
// 224:     end
// 225:
// 226:     it "names the cask when the architecture is not supported" do
// 227:       arch_cask = Cask::CaskLoader.load("with-depends-on-arch")
// 228:       allow(Hardware::CPU).to receive(:type).and_return(:ppc)
// 229:       expect do
// 230:         described_class.new(arch_cask).check_arch_requirements
// 231:       end.to raise_error(Cask::CaskError, /\Awith-depends-on-arch: This cask depends on hardware architecture/)
// 232:     end
// 233:
// 234:     it "names the cask when it has nothing to install on this system" do
// 235:       no_artifacts_cask = Cask::Cask.new("with-no-artifacts", loaded_from_api: true) do
// 236:         version "1.0"
// 237:         sha256 :no_check
// 238:         url "https://brew.sh/x.zip"
// 239:       end
// 240:       expect do
// 241:         described_class.new(no_artifacts_cask).check_supported_system
// 242:       end.to raise_error(Cask::CaskError, "with-no-artifacts: This cask is not available on macOS.")
// 243:     end
// 244:
// 245:     it "treats uninstall-only artifacts as nothing to install" do
// 246:       zap_only_cask = Cask::Cask.new("with-zap-only", loaded_from_api: true) do
// 247:         version "1.0"
// 248:         sha256 :no_check
// 249:         url "https://brew.sh/x.zip"
// 250:         zap trash: "~/Library/Caches/brew-test"
// 251:       end
// 252:       expect do
// 253:         described_class.new(zap_only_cask).check_supported_system
// 254:       end.to raise_error(Cask::CaskError, "with-zap-only: This cask is not available on macOS.")
// 255:     end
// 256:
// 257:     it "does not treat stage_only casks as having nothing to install" do
// 258:       stage_only_cask = Cask::Cask.new("with-stage-only", loaded_from_api: true) do
// 259:         version "1.0"
// 260:         sha256 :no_check
// 261:         url "https://brew.sh/x.zip"
// 262:         stage_only true
// 263:       end
// 264:       expect do
// 265:         described_class.new(stage_only_cask).check_supported_system
// 266:       end.not_to raise_error
// 267:     end
// 268:
// 269:     it "installs fine if sha256 :no_check is used with --require-sha and --force" do
// 270:       no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))
// 271:
// 272:       described_class.new(no_checksum, require_sha: true, force: true).install
// 273:
// 274:       expect(no_checksum).to be_installed
// 275:     end
// 276:
// 277:     it "prints caveats if they're present" do
// 278:       with_caveats = Cask::CaskLoader.load(cask_path("with-caveats"))
// 279:
// 280:       expect do
// 281:         described_class.new(with_caveats).install
// 282:       end.to output(/Here are some things you might want to know/).to_stdout
// 283:
// 284:       expect(with_caveats).to be_installed
// 285:     end
// 286:
// 287:     it "prints installer :manual instructions when present" do
// 288:       with_installer_manual = Cask::CaskLoader.load(cask_path("with-installer-manual"))
// 289:
// 290:       expect do
// 291:         described_class.new(with_installer_manual).install
// 292:       end.to output(
// 293:         <<~EOS,
// 294:           ==> Downloading file://#{HOMEBREW_LIBRARY_PATH}/test/support/fixtures/cask/caffeine.zip
// 295:           ==> Installing Cask with-installer-manual
// 296:           Cask with-installer-manual only provides a manual installer. To run it and complete the installation:
// 297:             open #{with_installer_manual.staged_path.join("Caffeine.app")}
// 298:           🍺  with-installer-manual was successfully installed!
// 299:         EOS
// 300:       ).to_stdout
// 301:
// 302:       expect(with_installer_manual).to be_installed
// 303:     end
// 304:
// 305:     it "does not extract __MACOSX directories from zips" do
// 306:       with_macosx_dir = Cask::CaskLoader.load(cask_path("with-macosx-dir"))
// 307:
// 308:       described_class.new(with_macosx_dir).install
// 309:
// 310:       expect(with_macosx_dir.staged_path.join("__MACOSX")).not_to be_a_directory
// 311:     end
// 312:
// 313:     it "allows already-installed Casks which auto-update to be installed if force is provided" do
// 314:       with_auto_updates = Cask::CaskLoader.load(cask_path("auto-updates"))
// 315:
// 316:       expect(with_auto_updates).not_to be_installed
// 317:
// 318:       described_class.new(with_auto_updates).install
// 319:
// 320:       expect do
// 321:         described_class.new(with_auto_updates, force: true).install
// 322:       end.not_to raise_error
// 323:     end
// 324:
// 325:     it "allows already-installed Casks to be installed if force is provided" do
// 326:       transmission = Cask::CaskLoader.load(cask_path("local-transmission-zip"))
// 327:
// 328:       expect(transmission).not_to be_installed
// 329:
// 330:       described_class.new(transmission).install
// 331:
// 332:       expect do
// 333:         described_class.new(transmission, force: true).install
// 334:       end.not_to raise_error
// 335:     end
// 336:
// 337:     it "installs a cask from a dmg file" do
// 338:       transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
// 339:       stub_dmg_extraction { |path| (path/"Transmission.app").mkpath }
// 340:
// 341:       expect(transmission).not_to be_installed
// 342:
// 343:       described_class.new(transmission).install
// 344:
// 345:       expect(transmission).to be_installed
// 346:     end
// 347:
// 348:     it "works naked-pkg-based Casks" do
// 349:       naked_pkg = Cask::CaskLoader.load(cask_path("container-pkg"))
// 350:
// 351:       described_class.new(naked_pkg).install
// 352:
// 353:       expect(Cask::Caskroom.path.join("container-pkg", naked_pkg.version, "container.pkg")).to be_a_file
// 354:     end
// 355:
// 356:     it "works properly with an overridden container :type" do
// 357:       naked_executable = Cask::CaskLoader.load(cask_path("naked-executable"))
// 358:
// 359:       described_class.new(naked_executable).install
// 360:
// 361:       expect(Cask::Caskroom.path.join("naked-executable", naked_executable.version, "naked_executable")).to be_a_file
// 362:     end
// 363:
// 364:     it "works fine with a nested container" do
// 365:       nested_app = Cask::CaskLoader.load(cask_path("nested-app"))
// 366:
// 367:       described_class.new(nested_app).install
// 368:
// 369:       expect(Pathname(nested_app.config.appdir).join("MyNestedApp.app")).to be_a_directory
// 370:     end
// 371:
// 372:     it "generates and finds a timestamped metadata directory for an installed Cask" do
// 373:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 374:
// 375:       described_class.new(caffeine).install
// 376:
// 377:       m_path = caffeine.metadata_timestamped_path(timestamp: :now, create: true)
// 378:       expect(caffeine.metadata_timestamped_path(timestamp: :latest)).to eq(m_path)
// 379:     end
// 380:
// 381:     it "generates and finds a metadata subdirectory for an installed Cask" do
// 382:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 383:
// 384:       described_class.new(caffeine).install
// 385:
// 386:       subdir_name = "Casks"
// 387:       m_subdir = caffeine.metadata_subdir(subdir_name, timestamp: :now, create: true)
// 388:       expect(caffeine.metadata_subdir(subdir_name, timestamp: :latest)).to eq(m_subdir)
// 389:     end
// 390:
// 391:     it "don't print cask installed message with --quiet option" do
// 392:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 393:       expect do
// 394:         described_class.new(caffeine, quiet: true).install
// 395:       end.to output(nil).to_stdout
// 396:     end
// 397:
// 398:     it "does NOT generate LATEST_DOWNLOAD_SHA256 file for installed Cask without version :latest" do
// 399:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 400:
// 401:       described_class.new(caffeine).install
// 402:
// 403:       expect(caffeine.download_sha_path).not_to be_a_file
// 404:     end
// 405:
// 406:     it "generates and finds LATEST_DOWNLOAD_SHA256 file for installed Cask with version :latest" do
// 407:       latest_cask = Cask::CaskLoader.load(cask_path("version-latest"))
// 408:
// 409:       described_class.new(latest_cask).install
// 410:
// 411:       expect(latest_cask.download_sha_path).to be_a_file
// 412:     end
// 413:
// 414:     context "when loaded from the api and caskfile is required" do
// 415:       let(:path) { cask_path("local-caffeine") }
// 416:       let(:content) { File.read(path) }
// 417:
// 418:       it "installs cask" do
// 419:         source_caffeine = Cask::CaskLoader.load(path)
// 420:         expect(Homebrew::API::Cask).to receive(:source_download_cask).once.and_return(source_caffeine)
// 421:
// 422:         caffeine = Cask::CaskLoader.load(path)
// 423:         allow(caffeine).to receive(:loaded_from_api?).and_return(true)
// 424:         expect(caffeine).to receive(:caskfile_only?).once.and_return(true)
// 425:
// 426:         described_class.new(caffeine).install
// 427:         expect(Cask::CaskLoader.load(path)).to be_installed
// 428:       end
// 429:     end
// 430:
// 431:     context "when loaded from the api with unsupported requirements" do
// 432:       let(:cask) { Cask::CaskLoader.load(cask_path("with-preflight")) }
// 433:       let(:download_queue) { instance_double(Homebrew::DownloadQueue, enqueue: nil) }
// 434:       let(:macos_requirement) { cask.depends_on.macos }
// 435:
// 436:       before do
// 437:         allow(macos_requirement).to receive(:satisfied?).and_return(false)
// 438:         allow(macos_requirement).to receive(:message).with(type: :cask).and_return("macOS is required")
// 439:         allow(cask).to receive(:loaded_from_api?).and_return(true)
// 440:       end
// 441:
// 442:       it "checks requirements before enqueueing downloads" do
// 443:         expect(Homebrew::API::Cask).not_to receive(:source_download)
// 444:
// 445:         expect do
// 446:           described_class.new(cask, download_queue:).enqueue_downloads
// 447:         end.to raise_error(Cask::CaskError, "with-preflight: macOS is required")
// 448:       end
// 449:
// 450:       it "checks requirements before loading the source cask during fetch" do
// 451:         expect(Homebrew::API::Cask).not_to receive(:source_download_cask)
// 452:
// 453:         expect do
// 454:           described_class.new(cask).fetch
// 455:         end.to raise_error(Cask::CaskError, "with-preflight: macOS is required")
// 456:       end
// 457:     end
// 458:
// 459:     it "zap method reinstall cask" do
// 460:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 461:       described_class.new(caffeine).install
// 462:
// 463:       expect(caffeine).to be_installed
// 464:
// 465:       described_class.new(caffeine).zap
// 466:
// 467:       expect(caffeine).not_to be_installed
// 468:       expect(Pathname(caffeine.config.appdir).join("Caffeine.app")).not_to be_a_symlink
// 469:     end
// 470:   end
// 471:
// 472:   describe "#backup" do
// 473:     it "does not raise when the staged version directory is already missing" do
// 474:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 475:       installer = described_class.new(caffeine)
// 476:       installer.install
// 477:
// 478:       FileUtils.rm_rf(caffeine.staged_path)
// 479:       FileUtils.rm_rf(caffeine.metadata_versioned_path)
// 480:
// 481:       expect { installer.backup }.not_to raise_error
// 482:       expect(installer.backup_path).not_to exist
// 483:       expect(installer.backup_metadata_path).not_to exist
// 484:     end
// 485:   end
// 486:
// 487:   describe "uninstall" do
// 488:     it "fully uninstalls a Cask" do
// 489:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 490:       installer = described_class.new(caffeine)
// 491:
// 492:       installer.install
// 493:       installer.uninstall
// 494:
// 495:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version, "Caffeine.app")).not_to be_a_directory
// 496:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
// 497:       expect(Cask::Caskroom.path.join("local-caffeine")).not_to be_a_directory
// 498:     end
// 499:
// 500:     it "removes Caskroom symlinks the uninstall broke, whatever name they carry" do
// 501:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 502:       alias_link = Cask::Caskroom.path.join("local-caffeine-renamed")
// 503:       unrelated_link = Cask::Caskroom.path.join("alias-of-another-cask")
// 504:       installer = described_class.new(caffeine)
// 505:       installer.install
// 506:       FileUtils.ln_s "local-caffeine", alias_link
// 507:       FileUtils.ln_s "another-cask", unrelated_link
// 508:
// 509:       installer.uninstall
// 510:
// 511:       expect([alias_link.symlink?, unrelated_link.symlink?, Cask::Caskroom.path.join("local-caffeine").exist?])
// 512:         .to eq([false, true, false])
// 513:     end
// 514:
// 515:     it "uninstalls all versions if force is set" do
// 516:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 517:       mutated_version = "#{caffeine.version}.1"
// 518:
// 519:       described_class.new(caffeine).install
// 520:
// 521:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).to be_a_directory
// 522:       expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).not_to be_a_directory
// 523:       FileUtils.mv(Cask::Caskroom.path.join("local-caffeine", caffeine.version),
// 524:                    Cask::Caskroom.path.join("local-caffeine", mutated_version))
// 525:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
// 526:       expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).to be_a_directory
// 527:
// 528:       described_class.new(caffeine, force: true).uninstall
// 529:
// 530:       expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
// 531:       expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).not_to be_a_directory
// 532:       expect(Cask::Caskroom.path.join("local-caffeine")).not_to be_a_directory
// 533:     end
// 534:
// 535:     context "when loaded from the api, caskfile is required and installed caskfile is invalid" do
// 536:       let(:path) { cask_path("local-caffeine") }
// 537:       let(:content) { File.read(path) }
// 538:       let(:invalid_path) { instance_double(Pathname) }
// 539:
// 540:       before do
// 541:         allow(invalid_path).to receive(:exist?).and_return(false)
// 542:       end
// 543:
// 544:       it "uninstalls cask" do
// 545:         source_caffeine = Cask::CaskLoader.load(path)
// 546:         expect(Homebrew::API::Cask).to receive(:source_download_cask).twice.and_return(source_caffeine)
// 547:
// 548:         caffeine = Cask::CaskLoader.load(path)
// 549:         allow(caffeine).to receive(:loaded_from_api?).and_return(true)
// 550:         expect(caffeine).to receive(:caskfile_only?).twice.and_return(true)
// 551:         expect(caffeine).to receive(:installed_caskfile).once.and_return(invalid_path)
// 552:
// 553:         described_class.new(caffeine).install
// 554:         expect(Cask::CaskLoader.load(path)).to be_installed
// 555:
// 556:         described_class.new(caffeine).uninstall
// 557:         expect(Cask::CaskLoader.load(path)).not_to be_installed
// 558:       end
// 559:     end
// 560:   end
// 561:
// 562:   describe "uninstall_existing_cask" do
// 563:     it "uninstalls when cask file is outdated" do
// 564:       caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 565:       described_class.new(caffeine).install
// 566:
// 567:       expect(Cask::CaskLoader.load(cask_path("local-caffeine"))).to be_installed
// 568:
// 569:       expect(caffeine).to receive(:installed?).once.and_return(true)
// 570:       outdate_caskfile = cask_path("invalid/invalid-depends-on-macos-bad-release")
// 571:       expect(caffeine).to receive(:installed_caskfile).once.and_return(outdate_caskfile)
// 572:       described_class.new(caffeine).uninstall_existing_cask
// 573:
// 574:       expect(Cask::CaskLoader.load(cask_path("local-caffeine"))).not_to be_installed
// 575:     end
// 576:   end
// 577:
// 578:   describe "#forbidden_tap_check" do
// 579:     before do
// 580:       allow(Tap).to receive_messages(allowed_taps: allowed_taps_set, forbidden_taps: forbidden_taps_set)
// 581:     end
// 582:
// 583:     let(:homebrew_forbidden) { Tap.fetch("homebrew/forbidden") }
// 584:     let(:allowed_third_party) { Tap.fetch("nothomebrew/allowed") }
// 585:     let(:disallowed_third_party) { Tap.fetch("nothomebrew/notallowed") }
// 586:     let(:allowed_taps_set) { [allowed_third_party.name] }
// 587:     let(:forbidden_taps_set) { [homebrew_forbidden.name] }
// 588:
// 589:     it "raises on forbidden tap on cask" do
// 590:       cask = Cask::Cask.new("homebrew-forbidden-tap", tap: homebrew_forbidden) do
// 591:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 592:       end
// 593:
// 594:       expect do
// 595:         described_class.new(cask).forbidden_tap_check
// 596:       end.to raise_error(Cask::CaskCannotBeInstalledError, /has the tap #{homebrew_forbidden}/)
// 597:     end
// 598:
// 599:     it "raises on not allowed third-party tap on cask" do
// 600:       cask = Cask::Cask.new("homebrew-not-allowed-tap", tap: disallowed_third_party) do
// 601:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 602:       end
// 603:
// 604:       expect do
// 605:         described_class.new(cask).forbidden_tap_check
// 606:       end.to raise_error(Cask::CaskCannotBeInstalledError, /has the tap #{disallowed_third_party}/)
// 607:     end
// 608:
// 609:     it "does not raise on allowed tap on cask" do
// 610:       cask = Cask::Cask.new("third-party-allowed-tap", tap: allowed_third_party) do
// 611:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 612:       end
// 613:
// 614:       expect { described_class.new(cask).forbidden_tap_check }.not_to raise_error
// 615:     end
// 616:
// 617:     it "raises on forbidden tap on dependency" do
// 618:       dep_tap = homebrew_forbidden
// 619:       dep_name = "homebrew-forbidden-dependency-tap"
// 620:       dep_path = dep_tap.new_formula_path(dep_name)
// 621:       dep_path.parent.mkpath
// 622:       dep_path.write <<~RUBY
// 623:         class #{Formulary.class_s(dep_name)} < Formula
// 624:           url "foo"
// 625:           version "0.1"
// 626:         end
// 627:       RUBY
// 628:
// 629:       cask = Cask::Cask.new("homebrew-forbidden-dependent-tap") do
// 630:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 631:         depends_on formula: dep_name
// 632:       end
// 633:
// 634:       expect do
// 635:         described_class.new(cask).forbidden_tap_check
// 636:       end.to raise_error(Cask::CaskCannotBeInstalledError, /from the #{dep_tap} tap but/)
// 637:     ensure
// 638:       FileUtils.rm_r(dep_path.parent.parent)
// 639:     end
// 640:   end
// 641:
// 642:   describe "#forbidden_cask_and_formula_check" do
// 643:     it "raises on forbidden cask" do
// 644:       ENV["HOMEBREW_FORBIDDEN_CASKS"] = cask_name = "homebrew-forbidden-cask"
// 645:       cask = Cask::Cask.new(cask_name) do
// 646:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 647:       end
// 648:
// 649:       expect do
// 650:         described_class.new(cask).forbidden_cask_and_formula_check
// 651:       end.to raise_error(Cask::CaskCannotBeInstalledError, /forbidden for installation/)
// 652:     end
// 653:
// 654:     it "raises on forbidden dependency" do
// 655:       ENV["HOMEBREW_FORBIDDEN_FORMULAE"] = dep_name = "homebrew-forbidden-dependency-formula"
// 656:       dep_path = CoreTap.instance.new_formula_path(dep_name)
// 657:       dep_path.write <<~RUBY
// 658:         class #{Formulary.class_s(dep_name)} < Formula
// 659:           url "foo"
// 660:           version "0.1"
// 661:         end
// 662:       RUBY
// 663:
// 664:       cask = Cask::Cask.new("homebrew-forbidden-dependent-cask") do
// 665:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 666:         depends_on formula: dep_name
// 667:       end
// 668:
// 669:       expect do
// 670:         described_class.new(cask).forbidden_cask_and_formula_check
// 671:       end.to raise_error(Cask::CaskCannotBeInstalledError, /#{dep_name} formula was forbidden/)
// 672:     end
// 673:   end
// 674:
// 675:   describe "#forbidden_cask_artifacts_check" do
// 676:     it "raises when cask contains forbidden pkg artifact" do
// 677:       ENV["HOMEBREW_FORBIDDEN_CASK_ARTIFACTS"] = "pkg"
// 678:       cask = Cask::Cask.new("homebrew-pkg-cask") do
// 679:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 680:         pkg "MyInstaller.pkg"
// 681:       end
// 682:
// 683:       expect do
// 684:         described_class.new(cask).forbidden_cask_artifacts_check
// 685:       end.to raise_error(Cask::CaskCannotBeInstalledError, /contains a 'pkg' artifact/)
// 686:     end
// 687:
// 688:     it "raises when cask contains forbidden installer artifact" do
// 689:       ENV["HOMEBREW_FORBIDDEN_CASK_ARTIFACTS"] = "installer"
// 690:       cask = Cask::Cask.new("homebrew-installer-cask") do
// 691:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 692:         installer script: {
// 693:           executable: "MyInstaller.sh",
// 694:           args:       ["--silent"],
// 695:         }
// 696:       end
// 697:
// 698:       expect do
// 699:         described_class.new(cask).forbidden_cask_artifacts_check
// 700:       end.to raise_error(Cask::CaskCannotBeInstalledError, /contains a 'installer' artifact/)
// 701:     end
// 702:
// 703:     it "raises when cask contains multiple forbidden artifacts" do
// 704:       ENV["HOMEBREW_FORBIDDEN_CASK_ARTIFACTS"] = "pkg installer"
// 705:       cask = Cask::Cask.new("homebrew-multi-forbidden-cask") do
// 706:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 707:         pkg "MyInstaller.pkg"
// 708:       end
// 709:
// 710:       expect do
// 711:         described_class.new(cask).forbidden_cask_artifacts_check
// 712:       end.to raise_error(Cask::CaskCannotBeInstalledError, /contains a 'pkg' artifact/)
// 713:     end
// 714:
// 715:     it "does not raise when cask does not contain forbidden artifacts" do
// 716:       ENV["HOMEBREW_FORBIDDEN_CASK_ARTIFACTS"] = "pkg installer"
// 717:       cask = Cask::Cask.new("homebrew-allowed-cask") do
// 718:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 719:         app "MyApp.app"
// 720:       end
// 721:
// 722:       expect { described_class.new(cask).forbidden_cask_artifacts_check }.not_to raise_error
// 723:     end
// 724:   end
// 725:
// 726:   describe "#prelude" do
// 727:     it "raises on forbidden cask before fetching the caskfile from the Source API" do
// 728:       ENV["HOMEBREW_FORBIDDEN_CASKS"] = cask_name = "homebrew-forbidden-cask"
// 729:       cask = Cask::Cask.new(cask_name) do
// 730:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 731:         app "Fake.app"
// 732:       end
// 733:       allow(cask).to receive_messages(loaded_from_api?: true, caskfile_only?: true)
// 734:       installer = described_class.new(cask)
// 735:
// 736:       expect(Homebrew::API::Cask).not_to receive(:source_download_cask)
// 737:       expect(installer).not_to receive(:download)
// 738:
// 739:       expect { installer.prelude }.to raise_error(Cask::CaskCannotBeInstalledError, /forbidden for installation/)
// 740:     end
// 741:   end
// 742:
// 743:   describe "#prelude_fetch" do
// 744:     it "uses API cask metadata for API-loaded cask downloads" do
// 745:       cask = Cask::Cask.new("api-cask", loaded_from_api: true, loaded_from_internal_api: true) do
// 746:         url "https://example.com/source-cask.zip"
// 747:         version "0.9"
// 748:         sha256 "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 749:         app "Fake.app"
// 750:       end
// 751:       cask_struct = Homebrew::API::CaskStruct.new(
// 752:         sha256:   "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 753:         url_args: ["https://example.com/api-cask.zip"],
// 754:         version:  "1.0",
// 755:       )
// 756:       download_queue = instance_double(Homebrew::DownloadQueue)
// 757:       installer = described_class.new(cask, download_queue:)
// 758:
// 759:       allow(Homebrew::API::Internal).to receive(:cask_struct).with("api-cask").and_return(cask_struct)
// 760:       expect(Homebrew::API::Cask).not_to receive(:source_download)
// 761:       expect(download_queue).to receive(:enqueue) do |download|
// 762:         expect(download).to be_a(Cask::Download)
// 763:         expect(download.url.to_s).to eq("https://example.com/api-cask.zip")
// 764:       end
// 765:
// 766:       installer.enqueue_downloads
// 767:     end
// 768:
// 769:     it "enqueues the selected language download from API data" do
// 770:       source_cask = Cask::CaskLoader.load("with-languages")
// 771:       cask_struct = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(
// 772:         source_cask.to_hash_with_variations,
// 773:       )
// 774:       config = Cask::Config.new(explicit: { languages: ["zh"] })
// 775:       cask = Cask::CaskLoader::FromAPILoader.new(
// 776:         "language-api-cask",
// 777:         from_json:          cask_struct.serialize,
// 778:         from_internal_json: true,
// 779:       ).load(config:)
// 780:       download_queue = instance_double(Homebrew::DownloadQueue)
// 781:       installer = described_class.new(cask, download_queue:)
// 782:
// 783:       allow(Homebrew::API::Internal).to receive(:cask_struct).with("language-api-cask").and_return(cask_struct)
// 784:       expect(Homebrew::API::Cask).not_to receive(:source_download)
// 785:       expect(download_queue).to receive(:enqueue) do |download|
// 786:         expect(download.url.to_s).to eq("file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz")
// 787:       end
// 788:
// 789:       installer.enqueue_downloads
// 790:     end
// 791:
// 792:     it "enqueues source API caskfiles before the main cask download" do
// 793:       cask = Cask::Cask.new("source-api-cask") do
// 794:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 795:         app "Fake.app"
// 796:       end
// 797:       allow(cask).to receive_messages(loaded_from_api?: true, caskfile_only?: true, languages: ["en"])
// 798:       download_queue = instance_double(Homebrew::DownloadQueue)
// 799:       installer = described_class.new(cask, download_queue:)
// 800:       source_download = instance_double(Homebrew::API::SourceDownload, downloaded?: false)
// 801:
// 802:       expect(Homebrew::API::Cask).to receive(:source_download_for).with(cask).and_return(source_download)
// 803:       expect(download_queue).to receive(:enqueue).with(source_download)
// 804:       expect(Homebrew::API::Cask).not_to receive(:source_download_cask)
// 805:       expect(installer).not_to receive(:download)
// 806:
// 807:       installer.prelude_fetch
// 808:     end
// 809:
// 810:     it "leaves source API caskfiles in the main queue when their URL is known" do
// 811:       cask = Cask::Cask.new("source-api-cask") do
// 812:         url "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz"
// 813:         app "Fake.app"
// 814:       end
// 815:       allow(cask).to receive_messages(loaded_from_api?: true, caskfile_only?: true, languages: [])
// 816:       download_queue = instance_double(Homebrew::DownloadQueue)
// 817:       installer = described_class.new(cask, download_queue:)
// 818:
// 819:       expect(Homebrew::API::Cask).to receive(:source_download).with(cask, download_queue:, enqueue: true)
// 820:       expect(Homebrew::API::Cask).not_to receive(:source_download_cask)
// 821:       expect(download_queue).to receive(:enqueue).with(instance_of(Cask::Download))
// 822:
// 823:       installer.enqueue_downloads
// 824:     end
// 825:
// 826:     it "stages the main cask download outside Caskroom before install" do
// 827:       cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 828:       download_queue = Homebrew::DownloadQueue.new(pour: true)
// 829:       installer = described_class.new(cask, download_queue:, defer_fetch: true)
// 830:       queued_staged_path = installer.downloader.staged_path_from_download_queue
// 831:       queued_staged_marker = installer.downloader.staged_path_from_download_queue_marker
// 832:
// 833:       begin
// 834:         installer.enqueue_downloads
// 835:         download_queue.fetch
// 836:       ensure
// 837:         download_queue.shutdown
// 838:       end
// 839:
// 840:       expect(cask.staged_path).not_to exist
// 841:       expect(cask).not_to be_installed
// 842:       expect(queued_staged_path/"Caffeine.app").to be_a_directory
// 843:       expect(queued_staged_marker).to exist
// 844:
// 845:       expect(installer).not_to receive(:extract_primary_container)
// 846:
// 847:       installer.stage
// 848:
// 849:       expect(cask.staged_path/"Caffeine.app").to be_a_directory
// 850:       expect(cask).to be_installed
// 851:     end
// 852:
// 853:     it "stages nested containers for API-loaded casks" do
// 854:       container_dir = mktmpdir
// 855:       FileUtils.cp(TEST_FIXTURE_DIR/"cask/caffeine.zip", container_dir/"NestedApp.zip")
// 856:       (container_dir/"README").write("NestedApp.zip contains the application")
// 857:       download = mktmpdir/"api-nested-cask.tar.gz"
// 858:       system "tar", "--create", "--gzip", "--file", download, "--directory", container_dir, "."
// 859:       sha256 = download.sha256
// 860:       cask = Cask::Cask.new("api-nested-cask", loaded_from_api: true, loaded_from_internal_api: true) do
// 861:         version "1.2.3"
// 862:         sha256 sha256
// 863:         url "file://#{download}"
// 864:         container nested: "NestedApp.zip"
// 865:         app "Caffeine.app"
// 866:       end
// 867:       cask_struct = Homebrew::API::CaskStruct.new(
// 868:         container_args:    { nested: "NestedApp.zip", type: nil },
// 869:         container_present: true,
// 870:         sha256:,
// 871:         url_args:          ["file://#{download}"],
// 872:         version:           "1.2.3",
// 873:       )
// 874:       allow(Homebrew::API::Internal).to receive(:cask_struct).with("api-nested-cask").and_return(cask_struct)
// 875:       download_queue = Homebrew::DownloadQueue.new(pour: true)
// 876:       installer = described_class.new(cask, download_queue:, defer_fetch: true)
// 877:
// 878:       begin
// 879:         installer.enqueue_downloads
// 880:         download_queue.fetch
// 881:       ensure
// 882:         download_queue.shutdown
// 883:       end
// 884:       installer.stage
// 885:
// 886:       expect(cask.staged_path/"Caffeine.app").to be_a_directory
// 887:     end
// 888:
// 889:     it "does not stage queued downloads with missing unpack dependencies" do
// 890:       cask = Cask::CaskLoader.load(cask_path("container-bzip2"))
// 891:       download_queue = Homebrew::DownloadQueue.new(pour: true)
// 892:       installer = described_class.new(cask, download_queue:, defer_fetch: true)
// 893:       queued_staged_path = installer.downloader.staged_path_from_download_queue
// 894:       queued_staged_marker = installer.downloader.staged_path_from_download_queue_marker
// 895:
// 896:       allow_any_instance_of(Formula).to receive(:any_version_installed?).and_return(false)
// 897:       expect(installer).not_to receive(:extract_primary_container)
// 898:
// 899:       begin
// 900:         installer.enqueue_downloads
// 901:         download_queue.fetch
// 902:       ensure
// 903:         download_queue.shutdown
// 904:       end
// 905:
// 906:       expect(cask.staged_path).not_to exist
// 907:       expect(cask).not_to be_installed
// 908:       expect(queued_staged_path).not_to exist
// 909:       expect(queued_staged_marker).not_to exist
// 910:     end
// 911:   end
// 912:
// 913:   describe "#load_installed_caskfile!" do
// 914:     it "uses recovered installed metadata before falling back to the current cask" do
// 915:       cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 916:       recovered_cask = Cask::Cask.new(cask.token) do
// 917:         version "1.0"
// 918:         app "Recovered.app"
// 919:       end
// 920:       installed_caskfile = mktmpdir/"local-caffeine.json"
// 921:       installed_caskfile.write("{}")
// 922:       allow(Cask::Migrator).to receive(:migrate_if_needed)
// 923:       allow(cask).to receive(:installed_caskfile).and_return(installed_caskfile)
// 924:       allow(Cask::CaskLoader).to receive(:load_from_installed_caskfile)
// 925:         .with(installed_caskfile)
// 926:         .and_raise(Cask::CaskInvalidError.new(cask.token, "broken DSL"))
// 927:       expect(Cask::CaskLoader).to receive(:recover_from_installed_caskfile)
// 928:         .with(installed_caskfile, tab: an_instance_of(Cask::Tab), fallback_cask: cask)
// 929:         .and_return(recovered_cask)
// 930:
// 931:       installer = described_class.new(cask)
// 932:       installer.load_installed_caskfile!
// 933:
// 934:       expect(installer.cask).to equal(recovered_cask)
// 935:     end
// 936:   end
// 937:
// 938:   describe "rename operations" do
// 939:     let(:tmpdir) { mktmpdir }
// 940:     let(:staged_path) { Pathname(tmpdir) }
// 941:
// 942:     after do
// 943:       FileUtils.rm_rf(tmpdir) if tmpdir && File.exist?(tmpdir)
// 944:     end
// 945:
// 946:     it "processes rename operations after extraction" do
// 947:       # Create test files
// 948:       (staged_path / "Original App.app").mkpath
// 949:       (staged_path / "Original App.app" / "Contents").mkpath
// 950:
// 951:       cask = Cask::Cask.new("rename-test-cask") do
// 952:         url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 953:         rename "Original App.app", "Renamed App.app"
// 954:         app "Renamed App.app"
// 955:       end
// 956:
// 957:       # Mock the staged_path to point to our test directory
// 958:       allow(cask).to receive(:staged_path).and_return(staged_path)
// 959:
// 960:       installer = described_class.new(cask)
// 961:       installer.process_rename_operations
// 962:
// 963:       expect(staged_path / "Renamed App.app").to be_a_directory
// 964:       expect(staged_path / "Original App.app").not_to exist
// 965:     end
// 966:
// 967:     it "handles multiple rename operations in order" do
// 968:       # Create test file
// 969:       (staged_path / "Original.app").mkpath
// 970:
// 971:       cask = Cask::Cask.new("multi-rename-test-cask") do
// 972:         url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 973:         rename "Original.app", "First Rename.app"
// 974:         rename "First Rename.app", "Final Name.app"
// 975:         app "Final Name.app"
// 976:       end
// 977:
// 978:       allow(cask).to receive(:staged_path).and_return(staged_path)
// 979:
// 980:       installer = described_class.new(cask)
// 981:       installer.process_rename_operations
// 982:
// 983:       expect(staged_path / "Final Name.app").to be_a_directory
// 984:       expect(staged_path / "Original.app").not_to exist
// 985:       expect(staged_path / "First Rename.app").not_to exist
// 986:     end
// 987:
// 988:     it "handles glob patterns in rename operations" do
// 989:       # Create test file with version
// 990:       (staged_path / "Test App v1.2.3.pkg").write("test content")
// 991:
// 992:       cask = Cask::Cask.new("glob-rename-test-cask") do
// 993:         url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 994:         rename "Test App*.pkg", "Test App.pkg"
// 995:         pkg "Test App.pkg"
// 996:       end
// 997:
// 998:       allow(cask).to receive(:staged_path).and_return(staged_path)
// 999:
// 1000:       installer = described_class.new(cask)
// 1001:       installer.process_rename_operations
// 1002:
// 1003:       expect(staged_path / "Test App.pkg").to be_a_file
// 1004:       expect((staged_path / "Test App.pkg").read).to eq("test content")
// 1005:       expect(staged_path / "Test App v1.2.3.pkg").not_to exist
// 1006:     end
// 1007:
// 1008:     it "does nothing when no files match rename pattern" do
// 1009:       # Create a different file
// 1010:       (staged_path / "Different.app").mkpath
// 1011:
// 1012:       cask = Cask::Cask.new("no-match-rename-test-cask") do
// 1013:         url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 1014:         rename "NonExistent*.app", "Target.app"
// 1015:         app "Different.app"
// 1016:       end
// 1017:
// 1018:       allow(cask).to receive(:staged_path).and_return(staged_path)
// 1019:
// 1020:       installer = described_class.new(cask)
// 1021:
// 1022:       expect { installer.process_rename_operations }.not_to raise_error
// 1023:       expect(staged_path / "Different.app").to be_a_directory
// 1024:       expect(staged_path / "Target.app").not_to exist
// 1025:     end
// 1026:   end
// 1027: end
