module cask

import homebrew
import json2
import os
import time

// Translated from Homebrew/brew `cask/tab.rb`.
pub enum CaskTabDependencyKind {
	cask
	formula
	ignored
}

pub struct CaskTabDependency {
pub:
	kind                      CaskTabDependencyKind
	full_name                 string
	version                   string
	revision                  int
	has_revision              bool
	bottle_rebuild            int
	has_bottle_rebuild        bool
	pkg_version               string
	compatibility_version     int
	has_compatibility_version bool
}

pub struct CaskTabRuntimeDependencies {
pub:
	present  bool
	casks    []homebrew.RuntimeDependencyReceipt
	formulae []homebrew.RuntimeDependencyReceipt
	other    map[string]json2.Any
}

pub struct CaskTabOptionalBool {
pub:
	present bool
	value   bool
}

pub struct CaskTabArtifacts {
pub:
	present bool
	values  []json2.Any
}

pub struct CaskTab {
pub mut:
	base                     homebrew.Tab
	uninstall_flight_blocks  bool
	has_uninstall_flight     bool
	uninstall_artifact_items []json2.Any
	has_uninstall_artifacts  bool
	runtime_dependencies     CaskTabRuntimeDependencies
}

pub struct CaskTabConfig {
pub:
	base                    homebrew.TabConfig
	uninstall_flight_blocks CaskTabOptionalBool
	uninstall_artifacts     CaskTabArtifacts
	runtime_dependencies    CaskTabRuntimeDependencies
}

pub struct CaskTabEnvironment {
pub:
	homebrew_version string
	now              i64
	arch             string
	built_on         map[string]json2.Any
}

pub struct CaskTabCask {
pub:
	metadata_main_container_path string
	uninstall_flight_blocks      bool
	loaded_from_api              bool
	loaded_from_internal_api     bool
	sourcefile_path              string
	tap_name                     string
	tap_git_head                 string
	version                      string
	uninstall_artifacts          []json2.Any
	dependency_graph             []CaskTabDependency
	declared_casks               []string
	declared_formulae            []string
}

pub fn new_cask_tab(config CaskTabConfig) CaskTab {
	return CaskTab{
		base: homebrew.new_tab(config.base)
		uninstall_flight_blocks: config.uninstall_flight_blocks.value
		has_uninstall_flight: config.uninstall_flight_blocks.present
		uninstall_artifact_items: config.uninstall_artifacts.values.clone()
		has_uninstall_artifacts: config.uninstall_artifacts.present
		runtime_dependencies: CaskTabRuntimeDependencies{
			present: config.runtime_dependencies.present
			casks: config.runtime_dependencies.casks.clone()
			formulae: config.runtime_dependencies.formulae.clone()
			other: config.runtime_dependencies.other.clone()
		}
	}
}

fn cask_tab_null_or_string(value string) json2.Any {
	return if value == '' { json2.null } else { json2.Any(value) }
}

fn cask_tab_base_for_create(cask CaskTabCask, environment CaskTabEnvironment) homebrew.Tab {
	return homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: environment.homebrew_version
		has_homebrew_version: true
		loaded_from_api: cask.loaded_from_api
		has_loaded_from_api: true
		loaded_from_internal_api: cask.loaded_from_internal_api
		has_loaded_from_internal_api: true
		installed_on_request: false
		has_installed_on_request: true
		time: environment.now
		has_time: true
		arch: environment.arch
		has_arch: true
		source: {
			'tap':          cask_tab_null_or_string(cask.tap_name)
			'tap_git_head': cask_tab_null_or_string(cask.tap_git_head)
		}
		built_on: environment.built_on
		has_built_on: true
	})
}

fn cask_tab_dependency_receipt(dependency CaskTabDependency,
	declared []string) homebrew.RuntimeDependencyReceipt {
	return homebrew.RuntimeDependencyReceipt{
		full_name: dependency.full_name
		version: dependency.version
		revision: dependency.revision
		has_revision: dependency.has_revision
		bottle_rebuild: dependency.bottle_rebuild
		has_bottle_rebuild: dependency.has_bottle_rebuild
		pkg_version: dependency.pkg_version
		declared_directly: dependency.full_name in declared
		has_declared_directly: true
		compatibility_version: dependency.compatibility_version
		has_compatibility_version: dependency.has_compatibility_version
	}
}

fn cask_tab_any_string(attributes map[string]json2.Any, key string) (string, bool) {
	value := attributes[key] or { return '', false }
	if value is json2.Null {
		return '', false
	}
	return value.str(), true
}

fn cask_tab_any_bool(attributes map[string]json2.Any, key string) (bool, bool) {
	value := attributes[key] or { return false, false }
	if value is json2.Null {
		return false, false
	}
	return value.bool(), true
}

fn cask_tab_any_i64(attributes map[string]json2.Any, key string) (i64, bool) {
	value := attributes[key] or { return 0, false }
	if value is json2.Null {
		return 0, false
	}
	return value.i64(), true
}

fn cask_tab_dependency_from_any(value json2.Any) homebrew.RuntimeDependencyReceipt {
	attributes := value.as_map()
	full_name, _ := cask_tab_any_string(attributes, 'full_name')
	version, _ := cask_tab_any_string(attributes, 'version')
	revision, has_revision := cask_tab_any_i64(attributes, 'revision')
	bottle_rebuild, has_bottle_rebuild := cask_tab_any_i64(attributes, 'bottle_rebuild')
	pkg_version, _ := cask_tab_any_string(attributes, 'pkg_version')
	declared_directly, has_declared_directly := cask_tab_any_bool(attributes, 'declared_directly')
	compatibility_version, has_compatibility_version := cask_tab_any_i64(attributes, 'compatibility_version')
	return homebrew.RuntimeDependencyReceipt{
		full_name: full_name
		version: version
		revision: int(revision)
		has_revision: has_revision
		bottle_rebuild: int(bottle_rebuild)
		has_bottle_rebuild: has_bottle_rebuild
		pkg_version: pkg_version
		declared_directly: declared_directly
		has_declared_directly: has_declared_directly
		compatibility_version: int(compatibility_version)
		has_compatibility_version: has_compatibility_version
	}
}

fn cask_tab_runtime_from_any(value json2.Any) CaskTabRuntimeDependencies {
	if value is json2.Null {
		return CaskTabRuntimeDependencies{}
	}
	attributes := value.as_map()
	mut casks := []homebrew.RuntimeDependencyReceipt{}
	mut formulae := []homebrew.RuntimeDependencyReceipt{}
	mut other := map[string]json2.Any{}
	for key, raw in attributes {
		match key {
			'cask' {
				casks = raw.as_array().map(cask_tab_dependency_from_any(it))
			}
			'formula' {
				formulae = raw.as_array().map(cask_tab_dependency_from_any(it))
			}
			else {
				other[key] = raw
			}
		}
	}
	return CaskTabRuntimeDependencies{
		present: true
		casks: casks
		formulae: formulae
		other: other
	}
}

pub fn cask_tab_from_json(content string, path string) !CaskTab {
	decoded := json2.decode[json2.Any](content) or { return error('Cannot parse ${path}: ${err}') }
	attributes := decoded.as_map()
	homebrew_version, has_homebrew_version := cask_tab_any_string(attributes, 'homebrew_version')
	loaded_from_api, has_loaded_from_api := cask_tab_any_bool(attributes, 'loaded_from_api')
	loaded_from_internal_api, has_loaded_from_internal_api := cask_tab_any_bool(attributes, 'loaded_from_internal_api')
	installed_on_request, has_installed_on_request := cask_tab_any_bool(attributes, 'installed_on_request')
	install_time, has_time := cask_tab_any_i64(attributes, 'time')
	arch, has_arch := cask_tab_any_string(attributes, 'arch')
	uninstall_flight, has_uninstall_flight := cask_tab_any_bool(attributes, 'uninstall_flight_blocks')
	mut artifacts := CaskTabArtifacts{}
	if raw := attributes['uninstall_artifacts'] {
		if raw !is json2.Null {
			artifacts = CaskTabArtifacts{
				present: true
				values: raw.as_array()
			}
		}
	}
	runtime := cask_tab_runtime_from_any(attributes['runtime_dependencies'] or { json2.null })
	return new_cask_tab(CaskTabConfig{
		base: homebrew.TabConfig{
			homebrew_version: homebrew_version
			has_homebrew_version: has_homebrew_version
			tabfile: path
			loaded_from_api: loaded_from_api
			has_loaded_from_api: has_loaded_from_api
			loaded_from_internal_api: loaded_from_internal_api
			has_loaded_from_internal_api: has_loaded_from_internal_api
			installed_on_request: installed_on_request
			has_installed_on_request: has_installed_on_request
			time: install_time
			has_time: has_time
			arch: arch
			has_arch: has_arch
			source: (attributes['source'] or { json2.Any(map[string]json2.Any{}) }).as_map()
			built_on: (attributes['built_on'] or {
				json2.Any(map[string]json2.Any{})
			}).as_map()
			has_built_on: 'built_on' in attributes
		}
		uninstall_flight_blocks: CaskTabOptionalBool{
			present: has_uninstall_flight
			value: uninstall_flight
		}
		uninstall_artifacts: artifacts
		runtime_dependencies: runtime
	})
}

pub fn cask_tab_from_file(path string, environment CaskTabEnvironment) !CaskTab {
	content := os.read_file(path)!
	if content.trim_space() == '' {
		return tab_empty(environment)
	}
	return cask_tab_from_json(content, path)
}

fn cask_tab_dependency_to_any(dependency homebrew.RuntimeDependencyReceipt) json2.Any {
	mut attributes := map[string]json2.Any{}
	attributes['full_name'] = json2.Any(dependency.full_name)
	attributes['version'] = json2.Any(dependency.version)
	if dependency.has_revision {
		attributes['revision'] = json2.Any(dependency.revision)
	}
	if dependency.has_bottle_rebuild {
		attributes['bottle_rebuild'] = json2.Any(dependency.bottle_rebuild)
	}
	if dependency.pkg_version != '' {
		attributes['pkg_version'] = json2.Any(dependency.pkg_version)
	}
	if dependency.has_declared_directly {
		attributes['declared_directly'] = json2.Any(dependency.declared_directly)
	}
	if dependency.has_compatibility_version {
		attributes['compatibility_version'] = json2.Any(dependency.compatibility_version)
	}
	return json2.Any(attributes)
}

fn cask_tab_runtime_to_any(runtime CaskTabRuntimeDependencies) json2.Any {
	if !runtime.present {
		return json2.null
	}
	mut attributes := runtime.other.clone()
	if runtime.casks.len > 0 {
		attributes['cask'] = json2.Any(runtime.casks.map(cask_tab_dependency_to_any(it)))
	}
	if runtime.formulae.len > 0 {
		attributes['formula'] = json2.Any(runtime.formulae.map(cask_tab_dependency_to_any(it)))
	}
	return json2.Any(attributes)
}

pub fn cask_tab_json_attributes(tab CaskTab) map[string]json2.Any {
	mut attributes := map[string]json2.Any{}
	attributes['homebrew_version'] = if tab.base.has_homebrew_version {
		json2.Any(tab.base.homebrew_version)
	} else {
		json2.null
	}
	attributes['loaded_from_api'] = if tab.base.has_loaded_from_api {
		json2.Any(tab.base.loaded_from_api)
	} else {
		json2.null
	}
	attributes['loaded_from_internal_api'] = if tab.base.has_loaded_from_internal_api {
		json2.Any(tab.base.loaded_from_internal_api)
	} else {
		json2.null
	}
	attributes['uninstall_flight_blocks'] = if tab.has_uninstall_flight {
		json2.Any(tab.uninstall_flight_blocks)
	} else {
		json2.null
	}
	attributes['installed_on_request'] = json2.Any(tab.base.installed_on_request)
	attributes['time'] = if tab.base.has_time { json2.Any(tab.base.time) } else { json2.null }
	attributes['runtime_dependencies'] = cask_tab_runtime_to_any(tab.runtime_dependencies)
	attributes['source'] = json2.Any(tab.base.source)
	attributes['arch'] = if tab.base.has_arch { json2.Any(tab.base.arch) } else { json2.null }
	attributes['uninstall_artifacts'] = if tab.has_uninstall_artifacts {
		json2.Any(tab.uninstall_artifact_items)
	} else {
		json2.null
	}
	attributes['built_on'] = if tab.base.has_built_on {
		json2.Any(tab.base.built_on)
	} else {
		json2.null
	}
	return attributes
}

pub fn cask_tab_runtime_equal(left CaskTabRuntimeDependencies,
	right CaskTabRuntimeDependencies) bool {
	return json2.encode(cask_tab_runtime_to_any(left)) == json2.encode(cask_tab_runtime_to_any(right))
}

// Ruby method `self.empty` at line 66.
pub fn tab_empty(environment CaskTabEnvironment) CaskTab {
	return new_cask_tab(CaskTabConfig{
		base: homebrew.TabConfig{
			homebrew_version: environment.homebrew_version
			has_homebrew_version: true
			has_installed_on_request: true
			has_loaded_from_api: true
			has_loaded_from_internal_api: true
			source: {
				'path':         json2.null
				'tap':          json2.null
				'tap_git_head': json2.null
				'version':      json2.null
			}
			built_on: environment.built_on
			has_built_on: true
		}
		uninstall_flight_blocks: CaskTabOptionalBool{
			present: true
		}
		uninstall_artifacts: CaskTabArtifacts{
			present: true
		}
	})
}

// Ruby method `self.runtime_deps_hash(cask)` at line 76.
pub fn tab_runtime_deps_hash(cask CaskTabCask) CaskTabRuntimeDependencies {
	mut casks := []homebrew.RuntimeDependencyReceipt{}
	mut formulae := []homebrew.RuntimeDependencyReceipt{}
	mut seen := map[string]bool{}
	for dependency in cask.dependency_graph {
		key := '${dependency.kind}:${dependency.full_name}'
		if seen[key] {
			continue
		}
		seen[key] = true
		match dependency.kind {
			.cask {
				casks << cask_tab_dependency_receipt(dependency, cask.declared_casks)
			}
			.formula {
				formulae << cask_tab_dependency_receipt(dependency, cask.declared_formulae)
			}
			.ignored {}
		}
	}
	return CaskTabRuntimeDependencies{
		present: true
		casks: casks
		formulae: formulae
	}
}
