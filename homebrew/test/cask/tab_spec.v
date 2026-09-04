module cask

import homebrew
import homebrew.cask as cask_core
import json2
import os
import time

// Translated from Homebrew/brew `test/cask/tab_spec.rb`.
pub struct CaskTabSpecFormula {
pub:
	url string
}

fn cask_tab_spec_environment(now i64) cask_core.CaskTabEnvironment {
	return cask_core.CaskTabEnvironment{
		homebrew_version: '4.3.7'
		now: now
		arch: 'arm64'
		built_on: {
			'os':         json2.Any('Macintosh')
			'os_version': json2.Any('macOS 14')
		}
	}
}

fn cask_tab_spec_dependency(kind cask_core.CaskTabDependencyKind, full_name string,
	version string) cask_core.CaskTabDependency {
	return cask_core.CaskTabDependency{
		kind: kind
		full_name: full_name
		version: version
	}
}

fn cask_tab_spec_string_array(values []string) json2.Any {
	return json2.Any(values.map(json2.Any(it)))
}

fn cask_tab_spec_app_artifact(name string) json2.Any {
	return json2.Any({
		'app': cask_tab_spec_string_array([name])
	})
}

fn cask_tab_spec_zap_artifact(path string) json2.Any {
	return json2.Any({
		'zap': json2.Any([json2.Any({
			'trash': json2.Any(path)
		})])
	})
}

fn cask_tab_spec_map_string(values map[string]json2.Any, key string) string {
	value := values[key] or { return '' }
	return value.str()
}

fn cask_tab_spec_cask(name string, root string) cask_core.CaskTabCask {
	mut cask := cask_core.CaskTabCask{
		metadata_main_container_path: os.join_path(root, 'Caskroom', name, '1.2.3')
		sourcefile_path: os.join_path(root, 'homebrew-cask', 'Casks', '${name}.rb')
		tap_name: 'homebrew/cask'
		version: '1.2.3'
	}
	match name {
		'with-depends-on-cask' {
			cask = cask_core.CaskTabCask{
				...cask
				dependency_graph: [
					cask_tab_spec_dependency(.cask, 'local-transmission-zip', '2.61'),
				]
				declared_casks: ['local-transmission-zip']
			}
		}
		'with-depends-on-everything' {
			cask = cask_core.CaskTabCask{
				...cask
				dependency_graph: [
					cask_tab_spec_dependency(.cask, 'local-caffeine', '1.2.3'),
					cask_tab_spec_dependency(.cask, 'with-depends-on-cask', '1.2.3'),
					cask_tab_spec_dependency(.cask, 'local-transmission-zip', '2.61'),
					cask_core.CaskTabDependency{
						kind: .formula
						full_name: 'unar'
						version: '1.2'
						revision: 0
						has_revision: true
						pkg_version: '1.2'
					},
				]
				declared_casks: ['local-caffeine', 'with-depends-on-cask']
				declared_formulae: ['unar']
			}
		}
		'local-caffeine' {
			cask = cask_core.CaskTabCask{
				...cask
				uninstall_artifacts: [
					cask_tab_spec_app_artifact('Caffeine.app'),
					cask_tab_spec_zap_artifact(os.join_path(root, 'cask', 'caffeine', 'org.example.caffeine.plist')),
				]
			}
		}
		else {}
	}
	return cask
}

fn cask_tab_spec_runtime() cask_core.CaskTabRuntimeDependencies {
	return cask_core.CaskTabRuntimeDependencies{
		present: true
		casks: [homebrew.RuntimeDependencyReceipt{
			full_name: 'bar'
			version: '2.0'
			declared_directly: false
			has_declared_directly: true
		}]
	}
}

fn cask_tab_spec_subject(install_time i64, root string) cask_core.CaskTab {
	return cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{
			homebrew_version: '4.3.7'
			has_homebrew_version: true
			loaded_from_api: false
			has_loaded_from_api: true
			loaded_from_internal_api: false
			has_loaded_from_internal_api: true
			installed_on_request: true
			has_installed_on_request: true
			time: install_time
			has_time: true
			arch: 'arm64'
			has_arch: true
			source: {
				'path':         json2.Any(os.join_path(root, 'homebrew-cask'))
				'tap':          json2.Any('homebrew/cask')
				'tap_git_head': json2.Any('8b79aa759500f0ffdf65a23e12950cbe3bf8fe17')
				'version':      json2.Any('1.2.3')
			}
			built_on: {
				'os': json2.Any('Macintosh')
			}
			has_built_on: true
		}
		uninstall_flight_blocks: cask_core.CaskTabOptionalBool{
			present: true
			value: true
		}
		uninstall_artifacts: cask_core.CaskTabArtifacts{
			present: true
			values: [cask_tab_spec_app_artifact('Foo.app')]
		}
		runtime_dependencies: cask_tab_spec_runtime()
	})
}

fn cask_tab_spec_receipt_content() string {
	cask_dep := json2.Any({
		'full_name':         json2.Any('bar')
		'version':           json2.Any('2.0')
		'declared_directly': json2.Any(true)
	})
	formula_dep := json2.Any({
		'full_name':         json2.Any('baz')
		'version':           json2.Any('3.0')
		'revision':          json2.Any(0)
		'pkg_version':       json2.Any('3.0')
		'declared_directly': json2.Any(true)
	})
	return json2.encode(json2.Any({
		'homebrew_version':         json2.Any('4.3.7')
		'loaded_from_api':          json2.Any(false)
		'loaded_from_internal_api': json2.Any(false)
		'uninstall_flight_blocks':  json2.Any(true)
		'installed_on_request':     json2.Any(true)
		'time':                     json2.Any(i64(1_719_289_256))
		'runtime_dependencies':     json2.Any({
			'cask':    json2.Any([cask_dep])
			'formula': json2.Any([formula_dep])
			'macos':   json2.Any({
				'>=': cask_tab_spec_string_array(['12'])
			})
		})
		'source':                   json2.Any({
			'path':         json2.Any('/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/f/foo.rb')
			'tap':          json2.Any('homebrew/cask')
			'tap_git_head': json2.Any('8b79aa759500f0ffdf65a23e12950cbe3bf8fe17')
			'version':      json2.Any('1.2.3')
		})
		'arch':                     json2.Any('arm64')
		'uninstall_artifacts':      json2.Any([cask_tab_spec_app_artifact('Foo.app')])
		'built_on':                 json2.Any({
			'os':             json2.Any('Macintosh')
			'os_version':     json2.Any('macOS 14')
			'cpu_family':     json2.Any('arm_firestorm_icestorm')
			'xcode':          json2.Any('15.4')
			'clt':            json2.Any('15.3.0.0.1.1708646388')
			'preferred_perl': json2.Any('5.34')
		})
	}),
		prettify: true
	)
}

fn cask_tab_spec_parsed(tab cask_core.CaskTab, path string) bool {
	version := cask_core.ruby_tab_l104_d10_version(tab) or { return false }
	return !tab.base.loaded_from_api && !tab.base.loaded_from_internal_api && tab.uninstall_flight_blocks && tab.base.installed_on_request && tab.base.time == 1_719_289_256 && cask_tab_spec_map_string(tab.base.source, 'path') == '/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/f/foo.rb' && version == '1.2.3' && tab.base.tap_name() == 'homebrew/cask' && tab.base.tabfile == path && tab.runtime_dependencies.casks.len == 1 && tab.runtime_dependencies.formulae.len == 1 && 'macos' in tab.runtime_dependencies.other
}

// Ruby subject `subject(:tab) do` at line 7.
pub fn ruby_tab_spec_l7_d1_tab(install_time i64, root string) cask_core.CaskTab {
	return cask_tab_spec_subject(install_time, root)
}

// Ruby let `let(:time) { Time.now.to_i }` at line 30.
pub fn ruby_tab_spec_l30_d2_time() i64 {
	return time.now().unix()
}

// Ruby let `let(:f) do` at line 31.
pub fn ruby_tab_spec_l31_d3_f() CaskTabSpecFormula {
	return CaskTabSpecFormula{ url: 'foo-1.0' }
}

// Ruby matcher `matcher :be_installed_on_request do` at line 38.
pub fn ruby_tab_spec_l38_d4_be_installed_on_request(tab cask_core.CaskTab) bool {
	return tab.base.installed_on_request
}

// Ruby matcher `matcher :be_loaded_from_api do` at line 44.
pub fn ruby_tab_spec_l44_d5_be_loaded_from_api(tab cask_core.CaskTab) bool {
	return tab.base.loaded_from_api
}

// Ruby matcher `matcher :be_loaded_from_internal_api do` at line 50.
pub fn ruby_tab_spec_l50_d6_be_loaded_from_internal_api(tab cask_core.CaskTab) bool {
	return tab.base.loaded_from_internal_api
}

// Ruby matcher `matcher :have_uninstall_flight_blocks do` at line 56.
pub fn ruby_tab_spec_l56_d7_have_uninstall_flight_blocks(tab cask_core.CaskTab) bool {
	return tab.uninstall_flight_blocks
}

// Ruby specify `specify "defaults" do` at line 62.
pub fn ruby_tab_spec_l62_d8_defaults() bool {
	tab := cask_core.tab_empty(cask_tab_spec_environment(0))
	return tab.base.homebrew_version == '4.3.7' && !tab.base.installed_on_request && !tab.base.loaded_from_api && !tab.base.loaded_from_internal_api && !tab.uninstall_flight_blocks && tab.base.tap_name() == '' && !tab.base.has_time && !tab.runtime_dependencies.present && (tab.base.source['path'] or { json2.null }) is json2.Null
}

// Ruby specify `specify "#runtime_dependencies" do` at line 78.
pub fn ruby_tab_spec_l78_d9_runtime_dependencies() bool {
	mut tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{})
	if tab.runtime_dependencies.present {
		return false
	}
	tab.runtime_dependencies = cask_core.CaskTabRuntimeDependencies{ present: true }
	if !tab.runtime_dependencies.present {
		return false
	}
	tab.runtime_dependencies = cask_tab_spec_runtime()
	return tab.runtime_dependencies.present
}

// Ruby specify `specify "with no dependencies" do` at line 92.
pub fn ruby_tab_spec_l92_d10_with(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('local-transmission', root))
	return result.present && result.casks.len == 0 && result.formulae.len == 0
}

// Ruby specify `specify "with cask dependencies" do` at line 98.
pub fn ruby_tab_spec_l98_d11_with(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('with-depends-on-cask', root))
	return result.casks.len == 1 && result.casks[0].full_name == 'local-transmission-zip' && result.casks[0].version == '2.61' && result.casks[0].declared_directly
}

// Ruby it `it "ignores macos symbol dependencies" do` at line 109.
pub fn ruby_tab_spec_l109_d12_ignores(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('with-depends-on-macos-symbol', root))
	return result.casks.len == 0 && result.formulae.len == 0
}

// Ruby it `it "ignores macos array dependencies" do` at line 115.
pub fn ruby_tab_spec_l115_d13_ignores(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('with-depends-on-macos-array', root))
	return result.casks.len == 0 && result.formulae.len == 0
}

// Ruby it `it "ignores arch dependencies" do` at line 121.
pub fn ruby_tab_spec_l121_d14_ignores(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('with-depends-on-arch', root))
	return result.casks.len == 0 && result.formulae.len == 0
}

// Ruby specify `specify "with all types of dependencies" do` at line 127.
pub fn ruby_tab_spec_l127_d15_with(root string) bool {
	result := cask_core.tab_runtime_deps_hash(cask_tab_spec_cask('with-depends-on-everything', root))
	return result.casks.map(it.full_name) == ['local-caffeine', 'with-depends-on-cask',
		'local-transmission-zip'] && result.casks.map(it.declared_directly) == [true, true, false] && result.formulae.len == 1 && result.formulae[0].full_name == 'unar' && result.formulae[0].version == '1.2' && result.formulae[0].revision == 0 && result.formulae[0].pkg_version == '1.2' && result.formulae[0].declared_directly
}

// Ruby specify `specify "other attributes" do` at line 154.
pub fn ruby_tab_spec_l154_d16_other(install_time i64, root string) bool {
	tab := cask_tab_spec_subject(install_time, root)
	return tab.base.tap_name() == 'homebrew/cask' && tab.base.time == install_time && !tab.base.loaded_from_api && !tab.base.loaded_from_internal_api && tab.uninstall_flight_blocks && tab.base.installed_on_request
}

// Ruby it `it "parses a cask Tab from a file" do` at line 164.
pub fn ruby_tab_spec_l164_d17_parses(path string) bool {
	tab := cask_core.cask_tab_from_file(path, cask_tab_spec_environment(0)) or { return false }
	return cask_tab_spec_parsed(tab, path)
}

// Ruby it `it "parses a cask Tab from a file" do` at line 205.
pub fn ruby_tab_spec_l205_d18_parses(path string, content string) bool {
	tab := cask_core.cask_tab_from_json(content, path) or { return false }
	return cask_tab_spec_parsed(tab, path)
}

// Ruby it `it "raises a parse exception message including the Tab filename" do` at line 245.
pub fn ruby_tab_spec_l245_d19_raises() bool {
	mut message := ''
	cask_core.cask_tab_from_json("''", 'cask_receipt.json') or { message = err.msg() }
	return message.contains('receipt.json:')
}

// Ruby it `it "creates a cask Tab" do` at line 254.
pub fn ruby_tab_spec_l254_d20_creates(root string) bool {
	cask := cask_tab_spec_cask('local-caffeine', root)
	tab := cask_core.ruby_tab_l31_d6_self_create(cask, cask_tab_spec_environment(1))
	version := cask_core.ruby_tab_l104_d10_version(tab) or { return false }
	return !tab.base.loaded_from_api && !tab.base.loaded_from_internal_api && !tab.uninstall_flight_blocks && !tab.base.installed_on_request && cask_tab_spec_map_string(tab.base.source, 'path') == cask.sourcefile_path && tab.base.tap_name() == 'homebrew/cask' && version == '1.2.3' && tab.runtime_dependencies.present && tab.runtime_dependencies.casks.len == 0 && json2.encode(json2.Any(tab.uninstall_artifact_items)) == json2.encode(json2.Any(cask.uninstall_artifacts))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load("local-transmission") }` at line 278.
pub fn ruby_tab_spec_l278_d21_cask(root string) cask_core.CaskTabCask {
	return cask_tab_spec_cask('local-transmission', root)
}

// Ruby let `let(:cask_tab_path) { cask.metadata_main_container_path/AbstractTab::FILENAME }` at line 279.
pub fn ruby_tab_spec_l279_d22_cask_tab_path(root string) string {
	return os.join_path(cask_tab_spec_cask('local-transmission', root).metadata_main_container_path, homebrew.tab_filename)
}

// Ruby let `let(:cask_tab_content) { (TEST_FIXTURE_DIR/"cask_receipt.json").read }` at line 280.
pub fn ruby_tab_spec_l280_d23_cask_tab_content() string {
	return cask_tab_spec_receipt_content()
}

// Ruby it `it "creates a Tab for a given cask" do` at line 282.
pub fn ruby_tab_spec_l282_d24_creates(root string) bool {
	cask := cask_tab_spec_cask('local-transmission', root)
	tab := cask_core.ruby_tab_l48_d7_self_for_cask(cask, cask_tab_spec_environment(0)) or {
		return false
	}
	return cask_tab_spec_map_string(tab.base.source, 'path') == cask.sourcefile_path
}

// Ruby it `it "creates a Tab for a given cask with existing Tab" do` at line 287.
pub fn ruby_tab_spec_l287_d25_creates(root string) bool {
	cask := cask_tab_spec_cask('local-transmission', root)
	path := ruby_tab_spec_l279_d22_cask_tab_path(root)
	os.mkdir_all(os.dir(path)) or { return false }
	os.write_file(path, cask_tab_spec_receipt_content()) or { return false }
	tab := cask_core.ruby_tab_l48_d7_self_for_cask(cask, cask_tab_spec_environment(0)) or {
		return false
	}
	return tab.base.tabfile == path
}

// Ruby it `it "can create a Tab for a non-existent cask" do` at line 295.
pub fn ruby_tab_spec_l295_d26_can(root string) bool {
	cask := cask_tab_spec_cask('local-transmission', root)
	os.mkdir_all(cask.metadata_main_container_path) or { return false }
	tab := cask_core.ruby_tab_l48_d7_self_for_cask(cask, cask_tab_spec_environment(0)) or {
		return false
	}
	return tab.base.tabfile == ''
}

// Ruby specify `specify "#to_json" do` at line 303.
pub fn ruby_tab_spec_l303_d27_to_json(install_time i64, root string) bool {
	tab := cask_tab_spec_subject(install_time, root)
	parsed := cask_core.cask_tab_from_json(cask_core.ruby_tab_l109_d11_to_json(tab), 'receipt.json') or { return false }
	version := cask_core.ruby_tab_l104_d10_version(tab) or { return false }
	parsed_version := cask_core.ruby_tab_l104_d10_version(parsed) or { return false }
	return parsed.base.homebrew_version == tab.base.homebrew_version && parsed.base.loaded_from_api == tab.base.loaded_from_api && parsed.base.loaded_from_internal_api == tab.base.loaded_from_internal_api && parsed.uninstall_flight_blocks == tab.uninstall_flight_blocks && parsed.base.installed_on_request == tab.base.installed_on_request && parsed.base.time == tab.base.time && cask_core.cask_tab_runtime_equal(parsed.runtime_dependencies, tab.runtime_dependencies) && cask_tab_spec_map_string(parsed.base.source, 'path') == cask_tab_spec_map_string(tab.base.source, 'path') && parsed.base.tap_name() == tab.base.tap_name() && cask_tab_spec_map_string(parsed.base.source, 'tap_git_head') == cask_tab_spec_map_string(tab.base.source, 'tap_git_head') && parsed_version == version && parsed.base.arch == tab.base.arch && json2.encode(json2.Any(parsed.uninstall_artifact_items)) == json2.encode(json2.Any(tab.uninstall_artifact_items)) && cask_tab_spec_map_string(parsed.base.built_on, 'os') == cask_tab_spec_map_string(tab.base.built_on, 'os')
}

// Ruby let `let(:time_string) { Time.at(1_720_189_863).strftime("%Y-%m-%d at %H:%M:%S") }` at line 323.
pub fn ruby_tab_spec_l323_d28_time_string() string {
	return time.unix(1_720_189_863).local().strftime('%Y-%m-%d at %H:%M:%S')
}

// Ruby it `it "returns install information for a Tab with a time that was loaded from the API" do` at line 325.
pub fn ruby_tab_spec_l325_d29_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: true, has_loaded_from_api: true, time: 1_720_189_863, has_time: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed using the formulae.brew.sh API on ${ruby_tab_spec_l323_d28_time_string()}'
}

// Ruby it `it "returns install information for a Tab with a time that was loaded from the internal API" do` at line 334.
pub fn ruby_tab_spec_l334_d30_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: true, has_loaded_from_api: true, loaded_from_internal_api: true, has_loaded_from_internal_api: true, time: 1_720_189_863, has_time: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed using the internal formulae.brew.sh API on ${ruby_tab_spec_l323_d28_time_string()}'
}

// Ruby it `it "returns install information for a Tab with a time that was not loaded from the API" do` at line 344.
pub fn ruby_tab_spec_l344_d31_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: false, has_loaded_from_api: true, time: 1_720_189_863, has_time: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed on ${ruby_tab_spec_l323_d28_time_string()}'
}

// Ruby it `it "returns install information for a Tab without a time that was loaded from the API" do` at line 353.
pub fn ruby_tab_spec_l353_d32_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: true, has_loaded_from_api: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed using the formulae.brew.sh API'
}

// Ruby it `it "returns install information for a Tab without a time that was loaded from the internal API" do` at line 362.
pub fn ruby_tab_spec_l362_d33_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: true, has_loaded_from_api: true, loaded_from_internal_api: true, has_loaded_from_internal_api: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed using the internal formulae.brew.sh API'
}

// Ruby it `it "returns install information for a Tab without a time that was not loaded from the API" do` at line 372.
pub fn ruby_tab_spec_l372_d34_returns() bool {
	tab := cask_core.ruby_tab_l22_d5_initialize(cask_core.CaskTabConfig{
		base: homebrew.TabConfig{ loaded_from_api: false, has_loaded_from_api: true }
	})
	return cask_core.ruby_tab_l128_d12_to_s(tab) == 'Installed'
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask"
// 5:
// 6: RSpec.describe Cask::Tab, :cask do
// 7:   subject(:tab) do
// 8:     described_class.new(
// 9:       homebrew_version:         HOMEBREW_VERSION,
// 10:       loaded_from_api:          false,
// 11:       loaded_from_internal_api: false,
// 12:       uninstall_flight_blocks:  true,
// 13:       installed_on_request:     true,
// 14:       time:,
// 15:       runtime_dependencies:     {
// 16:         "cask" => [{ "full_name" => "bar", "version" => "2.0", "declared_directly" => false }],
// 17:       },
// 18:       source:                   {
// 19:         "path"         => CoreCaskTap.instance.path.to_s,
// 20:         "tap"          => CoreCaskTap.instance.to_s,
// 21:         "tap_git_head" => "8b79aa759500f0ffdf65a23e12950cbe3bf8fe17",
// 22:         "version"      => "1.2.3",
// 23:       },
// 24:       arch:                     Hardware::CPU.arch,
// 25:       uninstall_artifacts:      [{ "app" => ["Foo.app"] }],
// 26:       built_on:                 DevelopmentTools.build_system_info,
// 27:     )
// 28:   end
// 29:
// 30:   let(:time) { Time.now.to_i }
// 31:   let(:f) do
// 32:     formula do
// 33:       T.bind(self, T.class_of(Formula))
// 34:       url "foo-1.0"
// 35:     end
// 36:   end
// 37:
// 38:   matcher :be_installed_on_request do
// 39:     match do |actual|
// 40:       actual.installed_on_request == true
// 41:     end
// 42:   end
// 43:
// 44:   matcher :be_loaded_from_api do
// 45:     match do |actual|
// 46:       actual.loaded_from_api == true
// 47:     end
// 48:   end
// 49:
// 50:   matcher :be_loaded_from_internal_api do
// 51:     match do |actual|
// 52:       actual.loaded_from_internal_api == true
// 53:     end
// 54:   end
// 55:
// 56:   matcher :have_uninstall_flight_blocks do
// 57:     match do |actual|
// 58:       actual.uninstall_flight_blocks == true
// 59:     end
// 60:   end
// 61:
// 62:   specify "defaults" do
// 63:     stub_const("HOMEBREW_VERSION", "4.3.7")
// 64:
// 65:     tab = described_class.empty
// 66:
// 67:     expect(tab.homebrew_version).to eq(HOMEBREW_VERSION)
// 68:     expect(tab).not_to be_installed_on_request
// 69:     expect(tab).not_to be_loaded_from_api
// 70:     expect(tab).not_to be_loaded_from_internal_api
// 71:     expect(tab).not_to have_uninstall_flight_blocks
// 72:     expect(tab.tap).to be_nil
// 73:     expect(tab.time).to be_nil
// 74:     expect(tab.runtime_dependencies).to be_nil
// 75:     expect(tab.source["path"]).to be_nil
// 76:   end
// 77:
// 78:   specify "#runtime_dependencies" do
// 79:     tab = described_class.new
// 80:     expect(tab.runtime_dependencies).to be_nil
// 81:
// 82:     tab.runtime_dependencies = {}
// 83:     expect(tab.runtime_dependencies).not_to be_nil
// 84:
// 85:     tab.runtime_dependencies = {
// 86:       "cask" => [{ "full_name" => "bar", "version" => "2.0", "declared_directly" => false }],
// 87:     }
// 88:     expect(tab.runtime_dependencies).not_to be_nil
// 89:   end
// 90:
// 91:   describe "::runtime_deps_hash" do
// 92:     specify "with no dependencies" do
// 93:       cask = Cask::CaskLoader.load("local-transmission")
// 94:
// 95:       expect(described_class.runtime_deps_hash(cask)).to eq({})
// 96:     end
// 97:
// 98:     specify "with cask dependencies" do
// 99:       cask = Cask::CaskLoader.load("with-depends-on-cask")
// 100:
// 101:       expected_hash = {
// 102:         cask: [
// 103:           { "full_name"=>"local-transmission-zip", "version"=>"2.61", "declared_directly"=>true },
// 104:         ],
// 105:       }
// 106:       expect(described_class.runtime_deps_hash(cask)).to eq(expected_hash)
// 107:     end
// 108:
// 109:     it "ignores macos symbol dependencies" do
// 110:       cask = Cask::CaskLoader.load("with-depends-on-macos-symbol")
// 111:
// 112:       expect(described_class.runtime_deps_hash(cask)).to eq({})
// 113:     end
// 114:
// 115:     it "ignores macos array dependencies" do
// 116:       cask = Cask::CaskLoader.load("with-depends-on-macos-array")
// 117:
// 118:       expect(described_class.runtime_deps_hash(cask)).to eq({})
// 119:     end
// 120:
// 121:     it "ignores arch dependencies" do
// 122:       cask = Cask::CaskLoader.load("with-depends-on-arch")
// 123:
// 124:       expect(described_class.runtime_deps_hash(cask)).to eq({})
// 125:     end
// 126:
// 127:     specify "with all types of dependencies" do
// 128:       cask = Cask::CaskLoader.load("with-depends-on-everything")
// 129:
// 130:       unar = Class.new(Formula) do
// 131:         url "my_url"
// 132:         version "1.2"
// 133:       end.new("unar", Pathname.new(__FILE__).expand_path, :stable)
// 134:       expect(Formulary).to receive(:factory).with("unar").and_return(unar)
// 135:
// 136:       expected_hash = {
// 137:         cask:    [
// 138:           { "full_name"=>"local-caffeine", "version"=>"1.2.3", "declared_directly"=>true },
// 139:           { "full_name"=>"with-depends-on-cask", "version"=>"1.2.3", "declared_directly"=>true },
// 140:           { "full_name"=>"local-transmission-zip", "version"=>"2.61", "declared_directly"=>false },
// 141:         ],
// 142:         formula: [
// 143:           { "full_name"=>"unar", "version"=>"1.2", "revision"=>0, "pkg_version"=>"1.2", "declared_directly"=>true },
// 144:         ],
// 145:       }
// 146:
// 147:       runtime_deps_hash = described_class.runtime_deps_hash(cask)
// 148:       tab = described_class.new
// 149:       tab.runtime_dependencies = runtime_deps_hash
// 150:       expect(tab.runtime_dependencies).to eql(expected_hash)
// 151:     end
// 152:   end
// 153:
// 154:   specify "other attributes" do
// 155:     expect(tab.tap.name).to eq("homebrew/cask")
// 156:     expect(tab.time).to eq(time)
// 157:     expect(tab).not_to be_loaded_from_api
// 158:     expect(tab).not_to be_loaded_from_internal_api
// 159:     expect(tab).to have_uninstall_flight_blocks
// 160:     expect(tab).to be_installed_on_request
// 161:   end
// 162:
// 163:   describe "::from_file" do
// 164:     it "parses a cask Tab from a file" do
// 165:       path = Pathname.new("#{TEST_FIXTURE_DIR}/cask_receipt.json")
// 166:       tab = described_class.from_file(path)
// 167:       source_path = "/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/f/foo.rb"
// 168:       runtime_dependencies = {
// 169:         "cask"    => [
// 170:           {
// 171:             "full_name"         => "bar",
// 172:             "version"           => "2.0",
// 173:             "declared_directly" => true,
// 174:           },
// 175:         ],
// 176:         "formula" => [
// 177:           {
// 178:             "full_name"         => "baz",
// 179:             "version"           => "3.0",
// 180:             "revision"          => 0,
// 181:             "pkg_version"       => "3.0",
// 182:             "declared_directly" => true,
// 183:           },
// 184:         ],
// 185:         "macos"   => {
// 186:           ">=" => [
// 187:             "12",
// 188:           ],
// 189:         },
// 190:       }
// 191:
// 192:       expect(tab).not_to be_loaded_from_api
// 193:       expect(tab).not_to be_loaded_from_internal_api
// 194:       expect(tab).to have_uninstall_flight_blocks
// 195:       expect(tab).to be_installed_on_request
// 196:       expect(tab.time).to eq(Time.at(1_719_289_256).to_i)
// 197:       expect(tab.runtime_dependencies).to eq(runtime_dependencies)
// 198:       expect(tab.source["path"]).to eq(source_path)
// 199:       expect(tab.version).to eq("1.2.3")
// 200:       expect(tab.tap.name).to eq("homebrew/cask")
// 201:     end
// 202:   end
// 203:
// 204:   describe "::from_file_content" do
// 205:     it "parses a cask Tab from a file" do
// 206:       path = Pathname.new("#{TEST_FIXTURE_DIR}/cask_receipt.json")
// 207:       tab = described_class.from_file_content(path.read, path)
// 208:       source_path = "/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/f/foo.rb"
// 209:       runtime_dependencies = {
// 210:         "cask"    => [
// 211:           {
// 212:             "full_name"         => "bar",
// 213:             "version"           => "2.0",
// 214:             "declared_directly" => true,
// 215:           },
// 216:         ],
// 217:         "formula" => [
// 218:           {
// 219:             "full_name"         => "baz",
// 220:             "version"           => "3.0",
// 221:             "revision"          => 0,
// 222:             "pkg_version"       => "3.0",
// 223:             "declared_directly" => true,
// 224:           },
// 225:         ],
// 226:         "macos"   => {
// 227:           ">=" => [
// 228:             "12",
// 229:           ],
// 230:         },
// 231:       }
// 232:
// 233:       expect(tab).not_to be_loaded_from_api
// 234:       expect(tab).not_to be_loaded_from_internal_api
// 235:       expect(tab).to have_uninstall_flight_blocks
// 236:       expect(tab).to be_installed_on_request
// 237:       expect(tab.tabfile).to eq(path)
// 238:       expect(tab.time).to eq(Time.at(1_719_289_256).to_i)
// 239:       expect(tab.runtime_dependencies).to eq(runtime_dependencies)
// 240:       expect(tab.source["path"]).to eq(source_path)
// 241:       expect(tab.version).to eq("1.2.3")
// 242:       expect(tab.tap.name).to eq("homebrew/cask")
// 243:     end
// 244:
// 245:     it "raises a parse exception message including the Tab filename" do
// 246:       expect { described_class.from_file_content("''", "cask_receipt.json") }.to raise_error(
// 247:         JSON::ParserError,
// 248:         /receipt.json:/,
// 249:       )
// 250:     end
// 251:   end
// 252:
// 253:   describe "::create" do
// 254:     it "creates a cask Tab" do
// 255:       cask = Cask::CaskLoader.load("local-caffeine")
// 256:       expected_artifacts = [
// 257:         { app: ["Caffeine.app"] },
// 258:         { zap: [{ trash: "#{TEST_FIXTURE_DIR}/cask/caffeine/org.example.caffeine.plist" }] },
// 259:       ]
// 260:
// 261:       tab = described_class.create(cask)
// 262:       expect(tab).not_to be_loaded_from_api
// 263:       expect(tab).not_to be_loaded_from_internal_api
// 264:       expect(tab).not_to have_uninstall_flight_blocks
// 265:       expect(tab).not_to be_installed_on_request
// 266:       expect(tab.source).to eq({
// 267:         "path"         => "#{CoreCaskTap.instance.path}/Casks/local-caffeine.rb",
// 268:         "tap"          => CoreCaskTap.instance.name,
// 269:         "tap_git_head" => nil,
// 270:         "version"      => "1.2.3",
// 271:       })
// 272:       expect(tab.runtime_dependencies).to eq({})
// 273:       expect(tab.uninstall_artifacts).to eq(expected_artifacts)
// 274:     end
// 275:   end
// 276:
// 277:   describe "::for_cask" do
// 278:     let(:cask) { Cask::CaskLoader.load("local-transmission") }
// 279:     let(:cask_tab_path) { cask.metadata_main_container_path/AbstractTab::FILENAME }
// 280:     let(:cask_tab_content) { (TEST_FIXTURE_DIR/"cask_receipt.json").read }
// 281:
// 282:     it "creates a Tab for a given cask" do
// 283:       tab = described_class.for_cask(cask)
// 284:       expect(tab.source["path"]).to eq(cask.sourcefile_path.to_s)
// 285:     end
// 286:
// 287:     it "creates a Tab for a given cask with existing Tab" do
// 288:       cask_tab_path.dirname.mkpath
// 289:       cask_tab_path.write cask_tab_content
// 290:
// 291:       tab = described_class.for_cask(cask)
// 292:       expect(tab.tabfile).to eq(cask_tab_path)
// 293:     end
// 294:
// 295:     it "can create a Tab for a non-existent cask" do
// 296:       cask_tab_path.dirname.mkpath
// 297:
// 298:       tab = described_class.for_cask(cask)
// 299:       expect(tab.tabfile).to be_nil
// 300:     end
// 301:   end
// 302:
// 303:   specify "#to_json" do
// 304:     json_tab = described_class.new(**JSON.parse(tab.to_json).transform_keys(&:to_sym))
// 305:     expect(json_tab.homebrew_version).to eq(tab.homebrew_version)
// 306:     expect(json_tab.loaded_from_api).to eq(tab.loaded_from_api)
// 307:     expect(json_tab.loaded_from_internal_api).to eq(tab.loaded_from_internal_api)
// 308:     expect(json_tab.uninstall_flight_blocks).to eq(tab.uninstall_flight_blocks)
// 309:     expect(json_tab.installed_on_request).to eq(tab.installed_on_request)
// 310:     expect(json_tab.installed_on_request).to eq(tab.installed_on_request)
// 311:     expect(json_tab.time).to eq(tab.time)
// 312:     expect(json_tab.runtime_dependencies).to eq(tab.runtime_dependencies)
// 313:     expect(json_tab.source["path"]).to eq(tab.source["path"])
// 314:     expect(json_tab.tap).to eq(tab.tap)
// 315:     expect(json_tab.source["tap_git_head"]).to eq(tab.source["tap_git_head"])
// 316:     expect(json_tab.version).to eq(tab.version)
// 317:     expect(json_tab.arch).to eq(tab.arch.to_s)
// 318:     expect(json_tab.uninstall_artifacts).to eq(tab.uninstall_artifacts)
// 319:     expect(json_tab.built_on["os"]).to eq(tab.built_on["os"])
// 320:   end
// 321:
// 322:   describe "#to_s" do
// 323:     let(:time_string) { Time.at(1_720_189_863).strftime("%Y-%m-%d at %H:%M:%S") }
// 324:
// 325:     it "returns install information for a Tab with a time that was loaded from the API" do
// 326:       tab = described_class.new(
// 327:         loaded_from_api: true,
// 328:         time:            1_720_189_863,
// 329:       )
// 330:       output = "Installed using the formulae.brew.sh API on #{time_string}"
// 331:       expect(tab.to_s).to eq(output)
// 332:     end
// 333:
// 334:     it "returns install information for a Tab with a time that was loaded from the internal API" do
// 335:       tab = described_class.new(
// 336:         loaded_from_api:          true,
// 337:         loaded_from_internal_api: true,
// 338:         time:                     1_720_189_863,
// 339:       )
// 340:       output = "Installed using the internal formulae.brew.sh API on #{time_string}"
// 341:       expect(tab.to_s).to eq(output)
// 342:     end
// 343:
// 344:     it "returns install information for a Tab with a time that was not loaded from the API" do
// 345:       tab = described_class.new(
// 346:         loaded_from_api: false,
// 347:         time:            1_720_189_863,
// 348:       )
// 349:       output = "Installed on #{time_string}"
// 350:       expect(tab.to_s).to eq(output)
// 351:     end
// 352:
// 353:     it "returns install information for a Tab without a time that was loaded from the API" do
// 354:       tab = described_class.new(
// 355:         loaded_from_api: true,
// 356:         time:            nil,
// 357:       )
// 358:       output = "Installed using the formulae.brew.sh API"
// 359:       expect(tab.to_s).to eq(output)
// 360:     end
// 361:
// 362:     it "returns install information for a Tab without a time that was loaded from the internal API" do
// 363:       tab = described_class.new(
// 364:         loaded_from_api:          true,
// 365:         loaded_from_internal_api: true,
// 366:         time:                     nil,
// 367:       )
// 368:       output = "Installed using the internal formulae.brew.sh API"
// 369:       expect(tab.to_s).to eq(output)
// 370:     end
// 371:
// 372:     it "returns install information for a Tab without a time that was not loaded from the API" do
// 373:       tab = described_class.new(
// 374:         loaded_from_api: false,
// 375:         time:            nil,
// 376:       )
// 377:       output = "Installed"
// 378:       expect(tab.to_s).to eq(output)
// 379:     end
// 380:   end
// 381: end
