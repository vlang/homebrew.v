module os

import ruby
import homebrew.os.mac as sdk
import os

pub struct MacFormulaRequirement {
pub:
	is_xcode bool
	build    bool
	test     bool
}

pub struct MacAppCandidate {
pub:
	path           string
	bundle_version string
	plist_exists   bool
}

pub struct MacContext {
pub mut:
	full_version         string
	languages            []string
	active_developer_dir string
	clt_installed        bool
	clt_locator          &sdk.SdkLocator = unsafe { nil }
	xcode_locator        &sdk.SdkLocator = unsafe { nil }
	xcode_sdk            sdk.MacSdk
	mdfind_results       map[string][]string
	app_candidates       map[string]MacAppCandidate
	pkgutil_results      map[string]string
	mdfind_cache         map[string][]string
	pkgutil_cache        map[string]string
}

pub fn new_mac_context(version string, languages_output string, system_languages_output string,
	active_developer_dir string, clt_installed bool, clt_locator &sdk.SdkLocator,
	xcode_locator &sdk.SdkLocator) &MacContext {
	selected_languages := if languages_output.trim_space() == '' {
		mac_parse_languages(system_languages_output)
	} else {
		mac_parse_languages(languages_output)
	}
	return &MacContext{
		full_version: version.trim_space()
		languages: selected_languages
		active_developer_dir: active_developer_dir.trim_space()
		clt_installed: clt_installed
		clt_locator: clt_locator
		xcode_locator: xcode_locator
		mdfind_results: map[string][]string{}
		app_candidates: map[string]MacAppCandidate{}
		pkgutil_results: map[string]string{}
		mdfind_cache: map[string][]string{}
		pkgutil_cache: map[string]string{}
	}
}

fn default_mac_context() &MacContext {
	version := os.getenv_opt('HOMEBREW_FAKE_MACOS') or { os.getenv('HOMEBREW_MACOS_VERSION') }
	clt := sdk.new_sdk_locator('/Library/Developer/CommandLineTools/SDKs', 'clt')
	xcode := sdk.new_sdk_locator('', 'xcode')
	return new_mac_context(version, os.getenv('AppleLanguages'), '', '', false, clt, xcode)
}

pub fn mac_parse_languages(output string) []string {
	mut normalized := output
	for delimiter in ['\n', ' ', '"', '(', ')', ','] {
		normalized = normalized.replace(delimiter, ' ')
	}
	return normalized.fields()
}

pub fn mac_strip_patch(version string) string {
	parts := version.trim_space().split('.')
	return if parts.len > 1 { parts[..2].join('.') } else { version.trim_space() }
}

fn mac_version_parts(version string) []int {
	return version.split('.').map(it.int())
}

fn mac_version_compare(left string, right string) int {
	a := mac_version_parts(left)
	b := mac_version_parts(right)
	maximum := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. maximum {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av < bv {
			return -1
		}
		if av > bv {
			return 1
		}
	}
	return 0
}

pub fn (context MacContext) version() string {
	return mac_strip_patch(context.full_version)
}

pub fn (mut context MacContext) set_full_version(version string) {
	context.full_version = version.trim_right('\n')
}

pub fn (context MacContext) preferred_perl_version() string {
	if mac_version_compare(context.version(), '14') >= 0 {
		return '5.34'
	}
	if mac_version_compare(context.version(), '11') >= 0 {
		return '5.30'
	}
	return '5.18'
}

pub fn (context MacContext) language() ?string {
	if context.languages.len == 0 {
		return none
	}
	return context.languages[0]
}

pub fn (context MacContext) sdk_locator() &sdk.SdkLocator {
	return if context.clt_installed { context.clt_locator } else { context.xcode_locator }
}

pub fn (context MacContext) selected_sdk(version string) ?sdk.MacSdk {
	mut locator := context.sdk_locator()
	return locator.sdk_if_applicable(version, context.version())
}

pub fn (context MacContext) sdk_for_formula(requirements []MacFormulaRequirement, version string,
	check_only_runtime_requirements bool) ?sdk.MacSdk {
	for requirement in requirements {
		if requirement.is_xcode && !(check_only_runtime_requirements && requirement.build && !requirement.test) {
			if context.xcode_sdk.path == '' {
				return none
			}
			return context.xcode_sdk
		}
	}
	return context.selected_sdk(version)
}

pub fn (context MacContext) sdk_path(version string) ?string {
	selected := context.selected_sdk(version) or { return none }
	return selected.path
}

pub fn mac_mdfind_query(ids []string) string {
	return ids.map('kMDItemCFBundleIdentifier == ${it}').join(' || ')
}

fn mac_ids_key(ids []string) string {
	return ids.join('\x1f')
}

pub fn (mut context MacContext) mdfind(ids []string) []string {
	key := mac_ids_key(ids)
	if key in context.mdfind_cache {
		return context.mdfind_cache[key].clone()
	}
	results := (context.mdfind_results[key] or { []string{} }).clone()
	context.mdfind_cache[key] = results.clone()
	return results
}

pub fn (mut context MacContext) pkgutil_info(identifier string) string {
	if identifier in context.pkgutil_cache {
		return context.pkgutil_cache[identifier]
	}
	result := (context.pkgutil_results[identifier] or { '' }).trim_space()
	context.pkgutil_cache[identifier] = result
	return result
}

pub fn (mut context MacContext) app_with_bundle_id(ids []string) ?string {
	paths := context.mdfind(ids).filter(!it.contains('/Backups.backupdb/'))
	if paths.len == 0 {
		return none
	}
	if paths.any(!(context.app_candidates[it] or { MacAppCandidate{ path: it } }).plist_exists) {
		return paths[0]
	}
	mut newest := context.app_candidates[paths[0]] or { MacAppCandidate{ path: paths[0] } }
	for path in paths[1..] {
		candidate := context.app_candidates[path] or { MacAppCandidate{ path: path } }
		if mac_version_compare(candidate.bundle_version, newest.bundle_version) > 0 {
			newest = candidate
		}
	}
	return newest.path
}

fn mac_context_value(context &MacContext) ruby.Value {
	return ruby.structured_value('OS::Mac', context.full_version, {
		'mac_context_address': u64(voidptr(context)).str()
	})
}

fn mac_context_from_args(args []ruby.Value) &MacContext {
	if args.len > 0 && 'mac_context_address' in args[0].attributes {
		return unsafe { &MacContext(voidptr(args[0].attributes['mac_context_address'].u64())) }
	}
	return default_mac_context()
}

pub fn mac_context_boundary(context &MacContext) ruby.Value {
	return mac_context_value(context)
}

fn mac_sdk_value(value sdk.MacSdk) ruby.Value {
	return ruby.structured_value('OS::Mac::SDK', value.path, {
		'version': value.version
		'path':    value.path
		'source':  value.source
	})
}

// Translated from Homebrew/brew `os/mac.rb`.
