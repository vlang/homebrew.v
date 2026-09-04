module homebrew

import os

// Translated from Homebrew/brew `unversioned_cask_checker.rb`.
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
