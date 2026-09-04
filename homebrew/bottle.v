module homebrew

import ruby
import homebrew.api
import homebrew.unpack_strategy
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `bottle.rb`.

pub struct BottleFilename {
pub:
	name    string
	version PkgVersion
	tag     string
	rebuild int
}

pub struct BottleUrlDecision {
pub:
	path              string
	resolved_basename string
	url               string
	github_packages   bool
}

pub struct BottleManifestPlan {
pub:
	descriptor        BottleDescriptor
	url               string
	mirrors           []string
	version_rebuild   string
	resolved_basename string
}

pub struct Bottle {
pub mut:
	name                  string
	pkg_version           PkgVersion
	specification         BottleSpecification
	tag                   BottleTag
	cellar                BottleCellar
	rebuild               int
	resource              Resource
	root_url_value        string
	has_root_url          bool
	manifest              BottleManifestResource
	has_manifest          bool
	fetch_tab_retried     bool
	bottle_size_value     i64
	has_bottle_size       bool
	installed_size_value  i64
	has_installed_size    bool
	path_exec_files_value []string
	has_path_exec_files   bool
	tab_attributes_value  map[string]json2.Any
	has_tab_attributes    bool
}

fn safe_bottle_filename_component(value string) bool {
	for character in value {
		if character.ascii_str() in ['/', '\\'] || character < 32 || character == 127 {
			return false
		}
	}
	return true
}

pub fn new_bottle_filename(name string, version PkgVersion, tag BottleTag,
	rebuild int) !BottleFilename {
	basename := name.replace('\\', '/').all_after_last('/')
	if !safe_bottle_filename_component(basename) {
		return error('Invalid bottle name')
	}
	if !safe_bottle_filename_component(version.to_s()) {
		return error('Invalid bottle version')
	}
	return BottleFilename{
		name: basename
		version: version
		tag: tag.unstandardized_symbol()
		rebuild: rebuild
	}
}

pub fn (filename BottleFilename) extname() string {
	rebuild_suffix := if filename.rebuild > 0 { '.${filename.rebuild}' } else { '' }
	return '.${filename.tag}.bottle${rebuild_suffix}.tar.gz'
}

pub fn (filename BottleFilename) str() string {
	return '${filename.name}--${filename.version.to_s()}${filename.extname()}'
}

pub fn (filename BottleFilename) json() string {
	return '${filename.name}--${filename.version.to_s()}.${filename.tag}.bottle.json'
}

pub fn (filename BottleFilename) url_encode() string {
	encoded :=
		urllib.query_escape('${filename.name}-${filename.version.to_s()}${filename.extname()}')
	return encoded.replace('+', '%20')
}

pub fn (filename BottleFilename) github_packages() string {
	return filename.str()
}

pub fn bottle_github_image_name(name string) string {
	return name.replace('@', '/').replace('+', 'x')
}

// brew.sh supplies this header before Ruby starts. The native V entry point
// performs the same source-derived setup because it does not execute brew.sh.
fn github_packages_authorization() ?string {
	configured := ruby.environment_value('HOMEBREW_GITHUB_PACKAGES_AUTH')
	if configured != '' {
		return configured
	}
	token := ruby.environment_value('HOMEBREW_DOCKER_REGISTRY_TOKEN')
	if token != '' {
		return 'Bearer ${token}'
	}
	basic := ruby.environment_value('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN')
	if basic != '' {
		if basic == 'none' {
			return none
		}
		return 'Basic ${basic}'
	}
	return 'Bearer QQ=='
}

fn add_github_packages_authorization(mut resource Resource) ! {
	url := resource.url() or { return }
	if !url.starts_with('https://ghcr.io/') {
		return
	}
	authorization := github_packages_authorization() or { return }
	mut downloader := resource.downloader()!
	header := 'Authorization: ${authorization}'
	if header !in downloader.file.base.meta.headers {
		downloader.file.base.meta.headers << header
	}
}

pub fn bottle_version_rebuild(version string, rebuild int, tag string) string {
	tag_suffix := if tag != '' { '.${tag}' } else { '' }
	rebuild_suffix := if rebuild > 0 {
		if tag != '' { '.${rebuild}' } else { '-${rebuild}' }
	} else {
		''
	}
	return '${version}${tag_suffix}${rebuild_suffix}'
}

pub fn bottle_path_resolved_basename(root_url string, name string, checksum Checksum,
	filename BottleFilename) BottleUrlDecision {
	if github_packages_root_url_if_match(root_url) != none {
		path := '${bottle_github_image_name(name)}/blobs/sha256:${checksum.hexdigest}'
		return BottleUrlDecision{
			path: path
			resolved_basename: filename.github_packages()
			url: '${root_url.trim_string_right('/')}/${path}'
			github_packages: true
		}
	}
	path := filename.url_encode()
	return BottleUrlDecision{
		path: path
		url: '${root_url.trim_string_right('/')}/${path}'
	}
}

pub fn new_bottle(name string, pkg_version PkgVersion, mut specification BottleSpecification,
	tag BottleTag) !Bottle {
	tag_specification := specification.tag_specification_for(tag, false) or {
		return error('${name} tag specification for tag ${tag.symbol()} is nil')
	}
	mut resource := new_resource(name)
	resource.set_version(pkg_version.to_s())!
	resource.set_checksum(tag_specification.checksum)
	mut bottle := Bottle{
		name: name
		pkg_version: pkg_version
		specification: specification
		tag: tag_specification.tag
		cellar: tag_specification.cellar
		rebuild: specification.rebuild()
		resource: resource
		fetch_tab_retried: false
		tab_attributes_value: map[string]json2.Any{}
	}
	bottle.set_root_url(specification.root_url(), specification.root_url_specs)!
	return bottle
}

fn bottle_root_from_archive_url(value string) string {
	if root := github_packages_root_url_if_match(value) {
		return root
	}
	trimmed := value.trim_string_right('/')
	if index := trimmed.last_index('/') {
		return trimmed[..index]
	}
	return trimmed
}

// api_bottle_for_formula translates Homebrew::API::FormulaBottle.bottle for
// the PackageReference metadata adapter used by the install command.
pub fn api_bottle_for_formula(formula api.PackageReference, requested_tag BottleTag) !Bottle {
	if formula.stable_version == '' || !formula.bottle_available {
		return error('No stable bottle is available for ${formula.full_name}')
	}
	mut specification := new_bottle_specification()
	specification.set_rebuild(formula.bottle_rebuild)
	for tag_symbol, file in formula.bottle_files {
		specification.sha256(tag_symbol, file.sha256, parse_bottle_cellar(file.cellar))!
	}
	selected := specification.tag_specification_for(requested_tag, false) or {
		return error('${formula.full_name} has no bottle for tag ${requested_tag.symbol()}')
	}
	selected_file := formula.bottle_files[selected.tag.symbol()] or {
		return error('${formula.full_name} bottle metadata is missing tag ${selected.tag.symbol()}')
	}
	custom_domain_value := custom_bottle_domain() or { '' }
	root := if custom_domain_value != '' {
		custom_domain_value
	} else {
		bottle_root_from_archive_url(selected_file.url)
	}
	specification.set_root_url(root, map[string]string{})
	version := new_version(formula.stable_version)!
	pkg_version := new_pkg_version(version, formula.revision)
	return new_bottle(formula.name, pkg_version, mut specification, requested_tag)
}

pub fn (bottle Bottle) filename() !BottleFilename {
	return new_bottle_filename(bottle.name, bottle.pkg_version, bottle.tag, bottle.rebuild)
}

pub fn (mut bottle Bottle) set_root_url(value string, specs map[string]string) !string {
	bottle.root_url_value = value.trim_string_right('/')
	bottle.has_root_url = true
	filename := bottle.filename()!
	decision := bottle_path_resolved_basename(bottle.root_url_value, bottle.name, bottle.resource.checksum, filename)
	mut selected_specs := specs.clone()
	selected_specs['bottle'] = 'true'
	bottle.resource.set_url(decision.url, selected_specs)!
	add_github_packages_authorization(mut bottle.resource)!
	if decision.resolved_basename != '' {
		mut downloader := bottle.resource.downloader()!
		downloader.file.resolved_url_value = decision.url
		downloader.file.resolved_basename_value = decision.resolved_basename
		downloader.file.has_resolved_url_basename = true
	}
	return bottle.root_url_value
}

pub fn (bottle Bottle) root_url() ?string {
	if bottle.has_root_url {
		return bottle.root_url_value
	}
	return none
}

pub fn (bottle Bottle) compatible_locations(context BottleLocationContext) bool {
	return bottle.specification.compatible_locations(bottle.tag, context)
}

pub fn (bottle Bottle) skip_relocation(context BottleLocationContext) bool {
	return bottle.specification.skip_relocation(bottle.tag, context)
}

fn custom_bottle_domain() ?string {
	domain := ruby.environment_value('HOMEBREW_BOTTLE_DOMAIN').trim_string_right('/')
	default_domain_value :=
		ruby.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN').trim_string_right('/')
	if domain != '' && domain != default_domain_value {
		return domain
	}
	return none
}

pub fn (bottle Bottle) github_packages_manifest_plan() ?BottleManifestPlan {
	root := bottle.root_url() or { return none }
	custom_domain_value := custom_bottle_domain() or { '' }
	custom_domain := custom_domain_value != '' && root == custom_domain_value
	if github_packages_root_url_if_match(root) == none && !custom_domain {
		return none
	}
	version_rebuild := bottle_version_rebuild(bottle.pkg_version.to_s(), bottle.rebuild, '')
	image_name := bottle_github_image_name(bottle.name)
	manifest_path := '${image_name}/manifests/${version_rebuild}'
	mut mirrors := []string{}
	if custom_domain {
		default_domain_value :=
			ruby.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN').trim_string_right('/')
		default_domain := if default_domain_value != '' {
			default_domain_value
		} else {
			'https://ghcr.io/v2/homebrew/core'
		}
		mirrors << '${default_domain}/${manifest_path}'
	}
	return BottleManifestPlan{
		descriptor: BottleDescriptor{
			name: bottle.name
			version: bottle.pkg_version.to_s()
			checksum: bottle.resource.checksum.hexdigest
			rebuild: bottle.rebuild
			tag: bottle.tag.symbol()
		}
		url: '${root}/${manifest_path}'
		mirrors: mirrors
		version_rebuild: version_rebuild
		resolved_basename: '${bottle.name}-${version_rebuild}.bottle_manifest.json'
	}
}

pub fn (bottle Bottle) new_manifest_resource() !BottleManifestResource {
	plan := bottle.github_packages_manifest_plan() or {
		return error('Bottle manifest is unavailable for ${bottle.name}')
	}
	mut manifest := new_bottle_manifest_resource(plan.descriptor)
	manifest.resource.set_version(plan.version_rebuild)!
	manifest.resource.set_url(plan.url, {
		'header': 'Accept: application/vnd.oci.image.index.v1+json'
	})!
	add_github_packages_authorization(mut manifest.resource)!
	for mirror in plan.mirrors {
		manifest.resource.mirror(mirror)
	}
	mut downloader := manifest.resource.downloader()!
	downloader.file.resolved_url_value = plan.url
	downloader.file.resolved_basename_value = plan.resolved_basename
	downloader.file.has_resolved_url_basename = true
	return manifest
}

// fetch_tab translates Bottle#fetch_tab using the typed Resource boundary. It
// deliberately does not enqueue anything; FormulaInstaller owns that decision.
pub fn (mut bottle Bottle) fetch_tab(timeout ?f64, quiet bool) ! {
	mut manifest := bottle.new_manifest_resource()!
	manifest.resource.fetch(false, timeout, quiet, true)!
	manifest.verify_download_integrity('') or {
		if bottle.fetch_tab_retried {
			return err
		}
		bottle.fetch_tab_retried = true
		manifest.clear_cache()!
		manifest.resource.fetch(false, timeout, quiet, true)!
		manifest.verify_download_integrity('')!
	}
	bottle.apply_manifest_metadata(mut manifest)!
}

fn (mut bottle Bottle) apply_manifest_metadata(mut manifest BottleManifestResource) ! {
	bottle.tab_attributes_value = manifest.tab()!
	bottle.has_tab_attributes = true
	if value := manifest.bottle_size() {
		bottle.bottle_size_value = value
		bottle.has_bottle_size = true
	}
	if value := manifest.installed_size() {
		bottle.installed_size_value = value
		bottle.has_installed_size = true
	}
	if value := manifest.path_exec_files() {
		bottle.path_exec_files_value = value
		bottle.has_path_exec_files = true
	}
	bottle.manifest = manifest
	bottle.has_manifest = true
}

// load_manifest_annotations is the non-network half of Bottle#fetch_tab. It is
// used for API-provided or already-enqueued OCI manifest metadata.
pub fn (mut bottle Bottle) load_manifest_annotations(annotations map[string]string) ! {
	mut manifest := bottle.new_manifest_resource()!
	manifest.set_manifest_annotations(annotations)
	bottle.apply_manifest_metadata(mut manifest)!
}

pub fn (bottle Bottle) tab_attributes() map[string]json2.Any {
	if bottle.has_tab_attributes {
		return bottle.tab_attributes_value.clone()
	}
	return map[string]json2.Any{}
}

pub fn (bottle Bottle) bottle_size() ?i64 {
	if bottle.has_bottle_size {
		return bottle.bottle_size_value
	}
	return none
}

pub fn (bottle Bottle) installed_size() ?i64 {
	if bottle.has_installed_size {
		return bottle.installed_size_value
	}
	return none
}

pub fn (bottle Bottle) path_exec_files() ?[]string {
	if bottle.has_path_exec_files {
		return bottle.path_exec_files_value.clone()
	}
	return none
}

// stage translates Bottle#stage through the typed downloader and recursive
// UnpackStrategy boundary. The explicit destination represents the temporary
// staging directory supplied by the install orchestration in V.
pub fn (mut bottle Bottle) stage(destination string) !string {
	if destination == '' {
		return error('Bottle staging requires a destination')
	}
	if !bottle.resource.downloaded() {
		bottle.resource.fetch(true, none, false, true)!
	}
	return bottle.resource.unpack(destination, false) or {
		original_error := err.msg()
		if !bottle_discard_corrupt_cached_download(mut bottle)! {
			return error(original_error)
		}
		bottle.resource.fetch(true, none, false, true)!
		return bottle.resource.unpack(destination, false)!
	}
}

fn remove_staged_bottle_path(path string) {
	if path == '' {
		return
	}
	if os.is_link(path) || os.is_file(path) {
		os.rm(path) or {}
	} else if os.is_dir(path) {
		os.rmdir_all(path) or {}
	}
}

fn extract_queued_bottle(download string, temporary_cellar string) ! {
	strategy := unpack_strategy.detect(download, unpack_strategy.DetectOptions{
		prioritize_extension: true
	})
	strategy.extract_nestedly(unpack_strategy.ExtractOptions{
		destination: temporary_cellar
		basename: os.file_name(download)
		prioritize_extension: true
	})!
}

// stage_from_download_queue translates Bottle#stage_from_download_queue. The
// symlink marker is created only after the expected name/version directory has
// been extracted, retaining the source's interruption-safe completion check.
pub fn (mut bottle Bottle) stage_from_download_queue(download string, pour bool) !string {
	temporary_cellar_value := ruby.environment_value('HOMEBREW_TEMP_CELLAR')
	temporary_cellar := if temporary_cellar_value != '' {
		temporary_cellar_value
	} else {
		'/tmp/homebrew/Cellar'
	}
	return bottle.stage_from_download_queue_in(download, pour, temporary_cellar)
}

pub fn (mut bottle Bottle) stage_from_download_queue_in(download string, pour bool,
	temporary_cellar string) !string {
	if !pour {
		return ''
	}
	bottle_tmp_keg := bottle.staged_path_in(temporary_cellar)
	bottle_poured_file := '${bottle_tmp_keg}.poured'
	os.mkdir_all(temporary_cellar)!
	if ruby.path_exists(bottle_poured_file) && ruby.is_dir(bottle_tmp_keg) {
		return bottle_tmp_keg
	}
	if os.is_link(bottle_poured_file) {
		os.rm(bottle_poured_file)!
	}
	remove_staged_bottle_path(bottle_tmp_keg)
	extract_queued_bottle(download, temporary_cellar) or {
		original_error := err.msg()
		remove_staged_bottle_path(bottle_tmp_keg)
		parent := os.dir(bottle_tmp_keg)
		if os.is_dir(parent) && (os.ls(parent) or { []string{} }).len == 0 {
			os.rmdir(parent) or {}
		}
		bottle.resource.verify_download_integrity(download) or {
			bottle.clear_cache()!
			fresh_download := bottle.resource.fetch(true, none, true, true)!
			extract_queued_bottle(fresh_download, temporary_cellar)!
			if !ruby.is_dir(bottle_tmp_keg) {
				return error('Bottle archive did not contain ${bottle.name}/${bottle.pkg_version.to_s()}')
			}
			os.symlink(bottle_tmp_keg, bottle_poured_file)!
			return bottle_tmp_keg
		}
		return error(original_error)
	}
	if !ruby.is_dir(bottle_tmp_keg) {
		remove_staged_bottle_path(bottle_tmp_keg)
		return error('Bottle archive did not contain ${bottle.name}/${bottle.pkg_version.to_s()}')
	}
	os.symlink(bottle_tmp_keg, bottle_poured_file)!
	return bottle_tmp_keg
}

pub fn (mut bottle Bottle) clear_cache() ! {
	bottle.resource.clear_cache()!
	if bottle.has_manifest {
		bottle.manifest.clear_cache()!
	}
	bottle.fetch_tab_retried = false
	bottle.has_tab_attributes = false
	bottle.has_bottle_size = false
	bottle.has_installed_size = false
	bottle.has_path_exec_files = false
}

// Ruby method `discard_corrupt_cached_download` at line 179.
pub fn bottle_discard_corrupt_cached_download(mut bottle Bottle) !bool {
	path := bottle.resource.cached_download() or { return false }
	bottle.resource.verify_download_integrity(path) or {
		bottle.clear_cache()!
		return true
	}
	return false
}

// Ruby method `staged_path_from_download_queue` at line 278.
pub fn bottle_staged_path_from_download_queue(bottle &Bottle) string {
	temporary_cellar := ruby.environment_value('HOMEBREW_TEMP_CELLAR')
	root := if temporary_cellar != '' { temporary_cellar } else { '/tmp/homebrew/Cellar' }
	return bottle.staged_path_in(root)
}

pub fn (bottle Bottle) staged_path_in(temporary_cellar string) string {
	filename := bottle.filename() or { return temporary_cellar }
	return '${temporary_cellar}/${filename.name}/${filename.version.to_s()}'
}
