module homebrew

import os

// Translated from Homebrew/brew `unversioned_cask_checker.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum UnversionedArtifactKind {
	app
	keyboard_layout
	qlplugin
	dictionary
	screen_saver
	colorpicker
	mdimporter
	installer
	pkg
	other
}

pub struct UnversionedArtifact {
pub:
	kind          UnversionedArtifactKind
	source        string
	path          string
	expanded_path string
	package_ids   []string
}

pub struct UnversionedCask {
pub:
	token            string
	artifacts        []UnversionedArtifact
	staged_path      string
	extraction_error string
}

pub struct UnversionedCaskInstaller {
pub:
	cask_token                string
	staged_path               string
	verify_download_integrity bool
}

pub struct UnversionedBundleVersion {
pub:
	short_version ?string
	version       ?string
}

pub struct UnversionedVersionGuess {
pub:
	found    bool
	version  string
	warnings []string
	errors   []string
	paths    []string
}

pub struct UnversionedCaskChecker {
pub:
	cask UnversionedCask
}

pub fn new_unversioned_cask_checker(cask UnversionedCask) UnversionedCaskChecker {
	return UnversionedCaskChecker{
		cask: cask
	}
}

pub fn unversioned_cask_installer(checker UnversionedCaskChecker) UnversionedCaskInstaller {
	return UnversionedCaskInstaller{
		cask_token: checker.cask.token
		staged_path: checker.cask.staged_path
		verify_download_integrity: false
	}
}

fn unversioned_artifacts(checker UnversionedCaskChecker,
	kind UnversionedArtifactKind) []UnversionedArtifact {
	return checker.cask.artifacts.filter(it.kind == kind)
}

pub fn unversioned_apps(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .app)
}

pub fn unversioned_keyboard_layouts(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .keyboard_layout)
}

pub fn unversioned_qlplugins(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .qlplugin)
}

pub fn unversioned_dictionaries(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .dictionary)
}

pub fn unversioned_screen_savers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .screen_saver)
}

pub fn unversioned_colorpickers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .colorpicker)
}

pub fn unversioned_mdimporters(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .mdimporter)
}

pub fn unversioned_installers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .installer)
}

pub fn unversioned_pkgs(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_artifacts(checker, .pkg)
}

pub fn unversioned_single_app_cask(checker UnversionedCaskChecker) bool {
	return unversioned_apps(checker).len == 1
}

pub fn unversioned_single_qlplugin_cask(checker UnversionedCaskChecker) bool {
	return unversioned_qlplugins(checker).len == 1
}

pub fn unversioned_single_pkg_cask(checker UnversionedCaskChecker) bool {
	return unversioned_pkgs(checker).len == 1
}

fn sorted_distinct_paths(paths []string) []string {
	mut seen := map[string]bool{}
	mut output := []string{}
	for path in paths {
		if path != '' && !seen[path] {
			seen[path] = true
			output << path
		}
	}
	output.sort()
	return output
}

fn distinct_paths(paths []string) []string {
	mut seen := map[string]bool{}
	mut output := []string{}
	for path in paths {
		if path != '' && !seen[path] {
			seen[path] = true
			output << path
		}
	}
	return output
}

pub fn top_level_info_plists(paths []string) []string {
	mut top_level_paths := map[string]bool{}
	for path in paths {
		top_level_paths[os.dir(os.dir(path))] = true
	}
	mut output := []string{}
	for path in paths {
		mut ancestor := os.dir(os.dir(os.dir(path)))
		mut nested := false
		for ancestor != '' {
			if top_level_paths[ancestor] {
				nested = true
				break
			}
			parent := os.dir(ancestor)
			if parent == ancestor {
				break
			}
			ancestor = parent
		}
		if !nested {
			output << path
		}
	}
	return output
}

fn present_unversioned_version(value ?string) ?string {
	if raw := value {
		trimmed := raw.trim_space()
		if trimmed != '' {
			return trimmed
		}
	}
	return none
}

pub fn new_unversioned_bundle_version(short_version ?string,
	version ?string) !UnversionedBundleVersion {
	mut normalized_short := present_unversioned_version(short_version)
	normalized_version := present_unversioned_version(version)
	if raw_version := normalized_version {
		if raw_short := normalized_short {
			suffix := '(${raw_version})'
			if raw_short.ends_with(suffix) {
				normalized_short = present_unversioned_version(raw_short[..raw_short.len - suffix.len].trim_space())
			}
		}
	}
	if normalized_short == none && normalized_version == none {
		return error('`short_version` and `version` cannot both be `nil` or empty')
	}
	return UnversionedBundleVersion{
		short_version: normalized_short
		version: normalized_version
	}
}

fn numeric_dotted_version(value string, require_dot bool) bool {
	if value == '' || (require_dot && !value.contains('.')) {
		return false
	}
	parts := value.split('.')
	return parts.all(it != '' && all_digits(it))
}

pub fn (bundle UnversionedBundleVersion) nice_parts() []string {
	short_version := bundle.short_version or { '' }
	version := bundle.version or { '' }
	if short_version != '' && short_version == version {
		return [short_version]
	}
	if short_version != '' && version != '' {
		if numeric_dotted_version(version, true) && version.starts_with('${short_version}.') {
			return [version]
		}
		if numeric_dotted_version(short_version, true) && short_version.starts_with('${version}.') {
			return [short_version]
		}
		if numeric_dotted_version(short_version, false) && version.bytes().all(it.is_digit()) {
			if short_version.starts_with('${version}.') || short_version.ends_with('.${version}') {
				return [short_version]
			}
			return [short_version, version]
		}
	}
	mut parts := []string{}
	if short_version != '' {
		parts << short_version
	}
	if version != '' {
		parts << version
	}
	return parts
}

pub fn (bundle UnversionedBundleVersion) nice_version() string {
	return bundle.nice_parts().join(',')
}

fn comparable_unversioned_version(value ?string) Version {
	if raw := value {
		return new_version(raw) or { null_version() }
	}
	return null_version()
}

pub fn compare_unversioned_bundle_versions(left UnversionedBundleVersion,
	right UnversionedBundleVersion) int {
	version_difference := comparable_unversioned_version(left.version).compare_to(comparable_unversioned_version(right.version))
	if version_difference != 0 {
		return version_difference
	}
	return comparable_unversioned_version(left.short_version).compare_to(comparable_unversioned_version(right.short_version))
}

fn xml_unescape(value string) string {
	return value.replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&apos;', "'").replace('&amp;', '&')
}

fn xml_element_after(contents string, offset int, element string) ?string {
	if offset < 0 || offset >= contents.len {
		return none
	}
	opening := '<${element}>'
	start_relative := contents[offset..].index(opening) or { return none }
	start := offset + start_relative + opening.len
	closing := '</${element}>'
	end_relative := contents[start..].index(closing) or { return none }
	return xml_unescape(contents[start..start + end_relative].trim_space())
}

fn plist_value(contents string, key string) ?string {
	key_marker := '<key>${key}</key>'
	key_index := contents.index(key_marker) or { return none }
	offset := key_index + key_marker.len
	if string_value := xml_element_after(contents, offset, 'string') {
		return present_unversioned_version(string_value)
	}
	if integer_value := xml_element_after(contents, offset, 'integer') {
		return present_unversioned_version(integer_value)
	}
	return none
}

pub fn unversioned_bundle_version_from_info_plist_content(contents string) ?UnversionedBundleVersion {
	short_version := plist_value(contents, 'CFBundleShortVersionString')
	version := plist_value(contents, 'CFBundleVersion')
	return new_unversioned_bundle_version(short_version, version) or { return none }
}

pub fn unversioned_bundle_version_from_info_plist(path string) ?UnversionedBundleVersion {
	contents := os.read_file(path) or { return none }
	return unversioned_bundle_version_from_info_plist_content(contents)
}

fn xml_attribute(tag string, name string) ?string {
	for quote in ['"', "'"] {
		marker := '${name}=${quote}'
		start_index := tag.index(marker) or { continue }
		start := start_index + marker.len
		end_relative := tag[start..].index(quote) or { continue }
		return xml_unescape(tag[start..start + end_relative])
	}
	return none
}

fn xml_tags(contents string, name string) []string {
	mut tags := []string{}
	prefix := '<${name}'
	mut offset := 0
	for offset < contents.len {
		start_relative := contents[offset..].index(prefix) or { break }
		start := offset + start_relative
		boundary := start + prefix.len
		if boundary < contents.len && !contents[boundary].is_space() && contents[boundary] !in [
			`>`,
			`/`,
		] {
			offset = boundary
			continue
		}
		end_relative := contents[start..].index('>') or { break }
		end := start + end_relative + 1
		tags << contents[start..end]
		offset = end
	}
	return tags
}

pub fn unversioned_bundle_version_from_package_info(path string) ?UnversionedBundleVersion {
	contents := os.read_file(path) or { return none }
	bundle_version_start := contents.index('<bundle-version') or { return none }
	bundle_version_end_relative := contents[bundle_version_start..].index('</bundle-version>') or {
		return none
	}
	bundle_version_section := contents[bundle_version_start..bundle_version_start + bundle_version_end_relative]
	reference_tags := xml_tags(bundle_version_section, 'bundle')
	if reference_tags.len == 0 {
		return none
	}
	reference_tag := reference_tags[0]
	bundle_id := xml_attribute(reference_tag, 'id') or { return none }
	if bundle_id.trim_space() == '' {
		return none
	}
	for tag in xml_tags(contents, 'bundle') {
		if (xml_attribute(tag, 'id') or { '' }) != bundle_id {
			continue
		}
		short_version := xml_attribute(tag, 'CFBundleShortVersionString')
		version := xml_attribute(tag, 'CFBundleVersion')
		if bundle := new_unversioned_bundle_version(short_version, version) {
			return bundle
		}
	}
	return none
}

fn distribution_product_version(path string) ?string {
	contents := os.read_file(path) or { return none }
	for tag in xml_tags(contents, 'product') {
		if version := xml_attribute(tag, 'version') {
			return present_unversioned_version(version)
		}
	}
	return none
}

fn recursive_paths(root string) []string {
	if !os.is_dir(root) {
		return []
	}
	mut remaining := [root]
	mut paths := []string{}
	for remaining.len > 0 {
		directory := remaining.pop()
		entries := os.ls(directory) or { continue }
		for entry in entries {
			path := os.join_path(directory, entry)
			paths << path
			if os.is_dir(path) && !os.is_link(path) {
				remaining << path
			}
		}
	}
	paths.sort()
	return paths
}

fn recursive_info_plists(root string) []string {
	return recursive_paths(root).filter(os.base(it) == 'Info.plist')
}

fn artifact_source_names(artifact UnversionedArtifact) []string {
	if artifact.kind != .installer {
		candidate := if artifact.source != '' { artifact.source } else { artifact.path }
		return if candidate == '' { [] } else { [os.base(candidate)] }
	}
	mut names := []string{}
	mut current := artifact.path
	for current != '' {
		if current == artifact.path || os.file_ext(current) == '.app' {
			names << os.base(current)
		}
		parent := os.dir(current)
		if parent == current || parent == '.' {
			break
		}
		current = parent
	}
	return sorted_distinct_paths(names)
}

fn artifact_info_plists(root string, artifacts []UnversionedArtifact) []string {
	all_paths := recursive_info_plists(root)
	mut matches := []string{}
	for artifact in artifacts {
		sources := artifact_source_names(artifact)
		for path in all_paths {
			bundle_name := os.base(os.dir(os.dir(path)))
			if bundle_name in sources {
				matches << path
			}
		}
	}
	return top_level_info_plists(matches)
}

fn unversioned_bundle_identifier(path string) ?string {
	contents := os.read_file(path) or { return none }
	return plist_value(contents, 'CFBundleIdentifier')
}

struct UnversionedPackageRoot {
	path        string
	package_ids []string
}

fn package_roots(checker UnversionedCaskChecker, fallback bool) []UnversionedPackageRoot {
	mut roots := []UnversionedPackageRoot{}
	for pkg in unversioned_pkgs(checker) {
		if pkg.expanded_path != '' && os.is_dir(pkg.expanded_path) {
			roots << UnversionedPackageRoot{
				path: pkg.expanded_path
				package_ids: pkg.package_ids
			}
		} else if pkg.path != '' && os.is_dir(pkg.path) {
			roots << UnversionedPackageRoot{
				path: pkg.path
				package_ids: pkg.package_ids
			}
		}
	}
	if fallback && roots.len == 0 {
		for path in recursive_paths(checker.cask.staged_path).filter(os.is_dir(it) && os.file_ext(it) == '.pkg') {
			roots << UnversionedPackageRoot{
				path: path
			}
		}
	}
	mut seen := map[string]bool{}
	mut distinct := []UnversionedPackageRoot{}
	for root in roots {
		if !seen[root.path] {
			seen[root.path] = true
			distinct << root
		}
	}
	return distinct
}

pub fn unversioned_all_versions(checker UnversionedCaskChecker) map[string]UnversionedBundleVersion {
	mut versions := map[string]UnversionedBundleVersion{}
	if checker.cask.extraction_error != '' {
		return versions
	}
	mut artifacts := []UnversionedArtifact{}
	for kind in [UnversionedArtifactKind.app, .keyboard_layout, .mdimporter, .colorpicker,
		.dictionary, .qlplugin, .installer, .screen_saver] {
		artifacts << unversioned_artifacts(checker, kind)
	}
	mut info_plists := artifact_info_plists(checker.cask.staged_path, artifacts)
	for pkg_root in package_roots(checker, true) {
		info_plists << top_level_info_plists(recursive_info_plists(pkg_root.path))
	}
	for path in distinct_paths(info_plists) {
		identifier := unversioned_bundle_identifier(path) or { continue }
		version := unversioned_bundle_version_from_info_plist(path) or { continue }
		versions[identifier] = version
	}
	return versions
}

fn guess_with_warning(message string) UnversionedVersionGuess {
	return UnversionedVersionGuess{
		warnings: [message]
	}
}

pub fn guess_unversioned_cask_version(checker UnversionedCaskChecker) UnversionedVersionGuess {
	if unversioned_apps(checker).len == 0 && unversioned_pkgs(checker).len == 0 && unversioned_qlplugins(checker).len == 0 {
		return guess_with_warning('Cask ${checker.cask.token} does not contain any apps, qlplugins or PKG installers.')
	}
	if checker.cask.extraction_error != '' {
		return UnversionedVersionGuess{
			errors: [checker.cask.extraction_error]
		}
	}
	for path in artifact_info_plists(checker.cask.staged_path, unversioned_apps(checker)) {
		if version := unversioned_bundle_version_from_info_plist(path) {
			return UnversionedVersionGuess{
				found: true
				version: version.nice_version()
			}
		}
	}
	mut accumulated_warnings := []string{}
	mut accumulated_errors := []string{}
	mut accumulated_paths := []string{}
	for pkg_root in package_roots(checker, false) {
		mut info_versions := []string{}
		for path in top_level_info_plists(recursive_info_plists(pkg_root.path)) {
			if version := unversioned_bundle_version_from_info_plist(path) {
				nice := version.nice_version()
				if nice != '' && nice !in info_versions {
					info_versions << nice
				}
			}
		}
		if info_versions.len == 1 {
			return UnversionedVersionGuess{
				found: true
				version: info_versions[0]
			}
		}
		package_info_path := os.join_path(pkg_root.path, 'PackageInfo')
		if version := unversioned_bundle_version_from_package_info(package_info_path) {
			return UnversionedVersionGuess{
				found: true
				version: version.nice_version()
			}
		}
		if !os.exists(package_info_path) && pkg_root.package_ids.len == 1 {
			accumulated_errors << '${os.base(pkg_root.path)} does not contain a `PackageInfo` file.'
		}
		if product_version := distribution_product_version(os.join_path(pkg_root.path, 'Distribution')) {
			return UnversionedVersionGuess{
				found: true
				version: product_version
				warnings: accumulated_warnings
				errors: accumulated_errors
				paths: accumulated_paths
			}
		}
		if pkg_root.package_ids.len != 1 {
			accumulated_warnings << '${os.base(pkg_root.path)} contains multiple packages: ${pkg_root.package_ids}'
		}
		accumulated_paths << recursive_paths(pkg_root.path)
	}
	return UnversionedVersionGuess{
		warnings: accumulated_warnings
		errors: accumulated_errors
		paths: distinct_paths(accumulated_paths)
	}
}

// Ruby attr_reader `attr_reader :cask` at line 18.
pub fn ruby_unversioned_cask_checker_l18_d1_cask(checker UnversionedCaskChecker) UnversionedCask {
	return checker.cask
}

// Ruby method `initialize(cask)` at line 21.
pub fn ruby_unversioned_cask_checker_l21_d2_initialize(cask UnversionedCask) UnversionedCaskChecker {
	return new_unversioned_cask_checker(cask)
}

// Ruby method `installer` at line 26.
pub fn ruby_unversioned_cask_checker_l26_d3_installer(checker UnversionedCaskChecker) UnversionedCaskInstaller {
	return unversioned_cask_installer(checker)
}

// Ruby method `apps` at line 31.
pub fn ruby_unversioned_cask_checker_l31_d4_apps(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_apps(checker)
}

// Ruby method `keyboard_layouts` at line 36.
pub fn ruby_unversioned_cask_checker_l36_d5_keyboard_layouts(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_keyboard_layouts(checker)
}

// Ruby method `qlplugins` at line 42.
pub fn ruby_unversioned_cask_checker_l42_d6_qlplugins(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_qlplugins(checker)
}

// Ruby method `dictionaries` at line 48.
pub fn ruby_unversioned_cask_checker_l48_d7_dictionaries(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_dictionaries(checker)
}

// Ruby method `screen_savers` at line 54.
pub fn ruby_unversioned_cask_checker_l54_d8_screen_savers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_screen_savers(checker)
}

// Ruby method `colorpickers` at line 60.
pub fn ruby_unversioned_cask_checker_l60_d9_colorpickers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_colorpickers(checker)
}

// Ruby method `mdimporters` at line 66.
pub fn ruby_unversioned_cask_checker_l66_d10_mdimporters(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_mdimporters(checker)
}

// Ruby method `installers` at line 72.
pub fn ruby_unversioned_cask_checker_l72_d11_installers(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_installers(checker)
}

// Ruby method `pkgs` at line 78.
pub fn ruby_unversioned_cask_checker_l78_d12_pkgs(checker UnversionedCaskChecker) []UnversionedArtifact {
	return unversioned_pkgs(checker)
}

// Ruby method `single_app_cask?` at line 83.
pub fn ruby_unversioned_cask_checker_l83_d13_single_app_cask(checker UnversionedCaskChecker) bool {
	return unversioned_single_app_cask(checker)
}

// Ruby method `single_qlplugin_cask?` at line 88.
pub fn ruby_unversioned_cask_checker_l88_d14_single_qlplugin_cask(checker UnversionedCaskChecker) bool {
	return unversioned_single_qlplugin_cask(checker)
}

// Ruby method `single_pkg_cask?` at line 93.
pub fn ruby_unversioned_cask_checker_l93_d15_single_pkg_cask(checker UnversionedCaskChecker) bool {
	return unversioned_single_pkg_cask(checker)
}

// Ruby method `top_level_info_plists(paths)` at line 100.
pub fn ruby_unversioned_cask_checker_l100_d16_top_level_info_plists(paths []string) []string {
	return top_level_info_plists(paths)
}

// Ruby method `all_versions` at line 110.
pub fn ruby_unversioned_cask_checker_l110_d17_all_versions(checker UnversionedCaskChecker) map[string]UnversionedBundleVersion {
	return unversioned_all_versions(checker)
}

// Ruby method `guess_cask_version` at line 182.
pub fn ruby_unversioned_cask_checker_l182_d18_guess_cask_version(checker UnversionedCaskChecker) ?string {
	guess := guess_unversioned_cask_version(checker)
	return if guess.found { guess.version } else { none }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5: require "cask/cask"
// 6: require "cask/installer"
// 7: require "system_command"
// 8: require "utils/output"
// 9:
// 10: module Homebrew
// 11:   # Check unversioned casks for updates by extracting their
// 12:   # contents and guessing the version from contained files.
// 13:   class UnversionedCaskChecker
// 14:     include SystemCommand::Mixin
// 15:     include Utils::Output::Mixin
// 16:
// 17:     sig { returns(Cask::Cask) }
// 18:     attr_reader :cask
// 19:
// 20:     sig { params(cask: Cask::Cask).void }
// 21:     def initialize(cask)
// 22:       @cask = cask
// 23:     end
// 24:
// 25:     sig { returns(Cask::Installer) }
// 26:     def installer
// 27:       @installer ||= T.let(Cask::Installer.new(cask, verify_download_integrity: false), T.nilable(Cask::Installer))
// 28:     end
// 29:
// 30:     sig { returns(T::Array[Cask::Artifact::App]) }
// 31:     def apps
// 32:       @apps ||= T.let(@cask.artifacts.grep(Cask::Artifact::App), T.nilable(T::Array[Cask::Artifact::App]))
// 33:     end
// 34:
// 35:     sig { returns(T::Array[Cask::Artifact::KeyboardLayout]) }
// 36:     def keyboard_layouts
// 37:       @keyboard_layouts ||= T.let(@cask.artifacts.grep(Cask::Artifact::KeyboardLayout),
// 38:                                   T.nilable(T::Array[Cask::Artifact::KeyboardLayout]))
// 39:     end
// 40:
// 41:     sig { returns(T::Array[Cask::Artifact::Qlplugin]) }
// 42:     def qlplugins
// 43:       @qlplugins ||= T.let(@cask.artifacts.grep(Cask::Artifact::Qlplugin),
// 44:                            T.nilable(T::Array[Cask::Artifact::Qlplugin]))
// 45:     end
// 46:
// 47:     sig { returns(T::Array[Cask::Artifact::Dictionary]) }
// 48:     def dictionaries
// 49:       @dictionaries ||= T.let(@cask.artifacts.grep(Cask::Artifact::Dictionary),
// 50:                               T.nilable(T::Array[Cask::Artifact::Dictionary]))
// 51:     end
// 52:
// 53:     sig { returns(T::Array[Cask::Artifact::ScreenSaver]) }
// 54:     def screen_savers
// 55:       @screen_savers ||= T.let(@cask.artifacts.grep(Cask::Artifact::ScreenSaver),
// 56:                                T.nilable(T::Array[Cask::Artifact::ScreenSaver]))
// 57:     end
// 58:
// 59:     sig { returns(T::Array[Cask::Artifact::Colorpicker]) }
// 60:     def colorpickers
// 61:       @colorpickers ||= T.let(@cask.artifacts.grep(Cask::Artifact::Colorpicker),
// 62:                               T.nilable(T::Array[Cask::Artifact::Colorpicker]))
// 63:     end
// 64:
// 65:     sig { returns(T::Array[Cask::Artifact::Mdimporter]) }
// 66:     def mdimporters
// 67:       @mdimporters ||= T.let(@cask.artifacts.grep(Cask::Artifact::Mdimporter),
// 68:                              T.nilable(T::Array[Cask::Artifact::Mdimporter]))
// 69:     end
// 70:
// 71:     sig { returns(T::Array[Cask::Artifact::Installer]) }
// 72:     def installers
// 73:       @installers ||= T.let(@cask.artifacts.grep(Cask::Artifact::Installer),
// 74:                             T.nilable(T::Array[Cask::Artifact::Installer]))
// 75:     end
// 76:
// 77:     sig { returns(T::Array[Cask::Artifact::Pkg]) }
// 78:     def pkgs
// 79:       @pkgs ||= T.let(@cask.artifacts.grep(Cask::Artifact::Pkg), T.nilable(T::Array[Cask::Artifact::Pkg]))
// 80:     end
// 81:
// 82:     sig { returns(T::Boolean) }
// 83:     def single_app_cask?
// 84:       apps.one?
// 85:     end
// 86:
// 87:     sig { returns(T::Boolean) }
// 88:     def single_qlplugin_cask?
// 89:       qlplugins.one?
// 90:     end
// 91:
// 92:     sig { returns(T::Boolean) }
// 93:     def single_pkg_cask?
// 94:       pkgs.one?
// 95:     end
// 96:
// 97:     # Filter paths to `Info.plist` files so that ones belonging
// 98:     # to e.g. nested `.app`s are ignored.
// 99:     sig { params(paths: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 100:     def top_level_info_plists(paths)
// 101:       # Go from `./Contents/Info.plist` to `./`.
// 102:       top_level_paths = paths.map { |path| path.parent.parent }
// 103:
// 104:       paths.reject do |path|
// 105:         path.ascend.drop(3).intersect?(top_level_paths)
// 106:       end
// 107:     end
// 108:
// 109:     sig { returns(T::Hash[String, BundleVersion]) }
// 110:     def all_versions
// 111:       versions = {}
// 112:
// 113:       parse_info_plist = proc do |info_plist_path|
// 114:         plist = system_command!("plutil", args: ["-convert", "xml1", "-o", "-", info_plist_path]).plist
// 115:
// 116:         id = plist["CFBundleIdentifier"]
// 117:         version = BundleVersion.from_info_plist_content(plist)
// 118:
// 119:         versions[id] = version if id && version
// 120:       end
// 121:
// 122:       Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |dir|
// 123:         dir = Pathname(dir)
// 124:
// 125:         installer.extract_primary_container(to: dir)
// 126:         installer.process_rename_operations(target_dir: dir)
// 127:
// 128:         info_plist_paths = [
// 129:           *apps,
// 130:           *keyboard_layouts,
// 131:           *mdimporters,
// 132:           *colorpickers,
// 133:           *dictionaries,
// 134:           *qlplugins,
// 135:           *installers,
// 136:           *screen_savers,
// 137:         ].flat_map do |artifact|
// 138:           sources = if artifact.is_a?(Cask::Artifact::Installer)
// 139:             # Installers are sometimes contained within an `.app`, so try both.
// 140:             installer_path = artifact.path
// 141:             installer_path.ascend
// 142:                           .select { |path| path == installer_path || path.extname == ".app" }
// 143:                           .sort
// 144:           else
// 145:             [artifact.source.basename]
// 146:           end
// 147:
// 148:           sources.flat_map do |source|
// 149:             top_level_info_plists(Pathname.glob(dir/"**"/source/"Contents"/"Info.plist")).sort
// 150:           end
// 151:         end
// 152:
// 153:         info_plist_paths.each(&parse_info_plist)
// 154:
// 155:         pkg_paths = pkgs.flat_map { |pkg| Pathname.glob(dir/"**"/pkg.path.basename).sort }
// 156:         pkg_paths = Pathname.glob(dir/"**"/"*.pkg").sort if pkg_paths.empty?
// 157:
// 158:         pkg_paths.each do |pkg_path|
// 159:           Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |extract_dir|
// 160:             extract_dir = Pathname(extract_dir)
// 161:             FileUtils.rmdir extract_dir
// 162:
// 163:             system_command! "pkgutil", args: ["--expand-full", pkg_path, extract_dir]
// 164:
// 165:             top_level_info_plist_paths = top_level_info_plists(Pathname.glob(extract_dir/"**/Contents/Info.plist"))
// 166:
// 167:             top_level_info_plist_paths.each(&parse_info_plist)
// 168:           ensure
// 169:             extract_dir = Pathname(extract_dir)
// 170:             Cask::Utils.gain_permissions_remove(extract_dir)
// 171:             extract_dir.mkpath
// 172:           end
// 173:         end
// 174:
// 175:         nil
// 176:       end
// 177:
// 178:       versions
// 179:     end
// 180:
// 181:     sig { returns(T.nilable(String)) }
// 182:     def guess_cask_version
// 183:       if apps.empty? && pkgs.empty? && qlplugins.empty?
// 184:         opoo "Cask #{cask} does not contain any apps, qlplugins or PKG installers."
// 185:         return
// 186:       end
// 187:
// 188:       Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |dir|
// 189:         dir = Pathname(dir)
// 190:
// 191:         installer.then do |i|
// 192:           i.extract_primary_container(to: dir)
// 193:         rescue ErrorDuringExecution => e
// 194:           onoe e
// 195:           return nil
// 196:         end
// 197:
// 198:         info_plist_paths = apps.flat_map do |app|
// 199:           top_level_info_plists(Pathname.glob(dir/"**"/app.source.basename/"Contents"/"Info.plist")).sort
// 200:         end
// 201:
// 202:         info_plist_paths.each do |info_plist_path|
// 203:           if (version = BundleVersion.from_info_plist(info_plist_path))
// 204:             return version.nice_version
// 205:           end
// 206:         end
// 207:
// 208:         pkg_paths = pkgs.flat_map do |pkg|
// 209:           Pathname.glob(dir/"**"/pkg.path.basename).sort
// 210:         end
// 211:
// 212:         pkg_paths.each do |pkg_path|
// 213:           packages =
// 214:             system_command!("installer", args: ["-plist", "-pkginfo", "-pkg", pkg_path])
// 215:             .plist
// 216:             .map { |package| package.fetch("Package") }
// 217:
// 218:           Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |extract_dir|
// 219:             extract_dir = Pathname(extract_dir)
// 220:             FileUtils.rmdir extract_dir
// 221:
// 222:             begin
// 223:               system_command! "pkgutil", args: ["--expand-full", pkg_path, extract_dir]
// 224:             rescue ErrorDuringExecution => e
// 225:               onoe "Failed to extract #{pkg_path.basename}: #{e}"
// 226:               next
// 227:             end
// 228:
// 229:             top_level_info_plist_paths = top_level_info_plists(Pathname.glob(extract_dir/"**/Contents/Info.plist"))
// 230:
// 231:             unique_info_plist_versions =
// 232:               top_level_info_plist_paths.filter_map { |i| BundleVersion.from_info_plist(i)&.nice_version }
// 233:                                         .uniq
// 234:             return unique_info_plist_versions.first if unique_info_plist_versions.one?
// 235:
// 236:             package_info_path = extract_dir/"PackageInfo"
// 237:             if package_info_path.exist?
// 238:               if (version = BundleVersion.from_package_info(package_info_path))
// 239:                 return version.nice_version
// 240:               end
// 241:             elsif packages.one?
// 242:               onoe "#{pkg_path.basename} does not contain a `PackageInfo` file."
// 243:             end
// 244:
// 245:             distribution_path = extract_dir/"Distribution"
// 246:             if distribution_path.exist?
// 247:               require "rexml/document"
// 248:
// 249:               xml = REXML::Document.new(distribution_path.read)
// 250:
// 251:               product = xml.get_elements("//installer-gui-script//product").first
// 252:               product_version = product["version"] if product
// 253:               return product_version if product_version.present?
// 254:             end
// 255:
// 256:             opoo "#{pkg_path.basename} contains multiple packages: #{packages}" if packages.count != 1
// 257:
// 258:             $stderr.puts Pathname.glob(extract_dir/"**/*")
// 259:                                  .map { |path|
// 260:                                    regex = %r{\A(.*?\.(app|qlgenerator|saver|plugin|kext|bundle|osax))/.*\Z}
// 261:                                    path.to_s.sub(regex, '\1')
// 262:                                  }.uniq
// 263:           ensure
// 264:             extract_dir = Pathname(extract_dir)
// 265:             Cask::Utils.gain_permissions_remove(extract_dir)
// 266:             extract_dir.mkpath
// 267:           end
// 268:         end
// 269:
// 270:         nil
// 271:       end
// 272:     end
// 273:   end
// 274: end
