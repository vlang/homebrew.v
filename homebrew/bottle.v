module homebrew

import brew_runtime
import homebrew.api
import homebrew.download_strategy
import homebrew.unpack_strategy
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `bottle.rb`.
// The original source is retained below until every stub has a typed V body.

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
		name:    basename
		version: version
		tag:     tag.unstandardized_symbol()
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
	configured := brew_runtime.environment_value('HOMEBREW_GITHUB_PACKAGES_AUTH')
	if configured != '' {
		return configured
	}
	token := brew_runtime.environment_value('HOMEBREW_DOCKER_REGISTRY_TOKEN')
	if token != '' {
		return 'Bearer ${token}'
	}
	basic := brew_runtime.environment_value('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN')
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
			path:              path
			resolved_basename: filename.github_packages()
			url:               '${root_url.trim_string_right('/')}/${path}'
			github_packages:   true
		}
	}
	path := filename.url_encode()
	return BottleUrlDecision{
		path: path
		url:  '${root_url.trim_string_right('/')}/${path}'
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
		name:                 name
		pkg_version:          pkg_version
		specification:        specification
		tag:                  tag_specification.tag
		cellar:               tag_specification.cellar
		rebuild:              specification.rebuild()
		resource:             resource
		fetch_tab_retried:    false
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
	decision := bottle_path_resolved_basename(bottle.root_url_value, bottle.name,
		bottle.resource.checksum, filename)
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
	domain := brew_runtime.environment_value('HOMEBREW_BOTTLE_DOMAIN').trim_string_right('/')
	default_domain_value :=
		brew_runtime.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN').trim_string_right('/')
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
			brew_runtime.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN').trim_string_right('/')
		default_domain := if default_domain_value != '' {
			default_domain_value
		} else {
			'https://ghcr.io/v2/homebrew/core'
		}
		mirrors << '${default_domain}/${manifest_path}'
	}
	return BottleManifestPlan{
		descriptor:        BottleDescriptor{
			name:     bottle.name
			version:  bottle.pkg_version.to_s()
			checksum: bottle.resource.checksum.hexdigest
			rebuild:  bottle.rebuild
			tag:      bottle.tag.symbol()
		}
		url:               '${root}/${manifest_path}'
		mirrors:           mirrors
		version_rebuild:   version_rebuild
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
		if !ruby_bottle_l179_d26_discard_corrupt_cached_download(mut bottle)! {
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
		destination:          temporary_cellar
		basename:             os.file_name(download)
		prioritize_extension: true
	})!
}

// stage_from_download_queue translates Bottle#stage_from_download_queue. The
// symlink marker is created only after the expected name/version directory has
// been extracted, retaining the source's interruption-safe completion check.
pub fn (mut bottle Bottle) stage_from_download_queue(download string, pour bool) !string {
	temporary_cellar_value := brew_runtime.environment_value('HOMEBREW_TEMP_CELLAR')
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
	if brew_runtime.path_exists(bottle_poured_file) && brew_runtime.is_dir(bottle_tmp_keg) {
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
			if !brew_runtime.is_dir(bottle_tmp_keg) {
				return error('Bottle archive did not contain ${bottle.name}/${bottle.pkg_version.to_s()}')
			}
			os.symlink(bottle_tmp_keg, bottle_poured_file)!
			return bottle_tmp_keg
		}
		return error(original_error)
	}
	if !brew_runtime.is_dir(bottle_tmp_keg) {
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

// Ruby attr_reader `attr_reader :name, :tag` at line 11.
pub fn ruby_bottle_l11_d1_name(filename &BottleFilename) string {
	return filename.name
}

// Ruby attr_reader `attr_reader :name, :tag` at line 11.
pub fn ruby_bottle_l11_d2_tag(filename &BottleFilename) string {
	return filename.tag
}

// Ruby attr_reader `attr_reader :version` at line 14.
pub fn ruby_bottle_l14_d3_version(filename &BottleFilename) PkgVersion {
	return filename.version
}

// Ruby attr_reader `attr_reader :rebuild` at line 17.
pub fn ruby_bottle_l17_d4_rebuild(filename &BottleFilename) int {
	return filename.rebuild
}

// Ruby method `self.create(formula, tag, rebuild)` at line 20.
pub fn ruby_bottle_l20_d5_self_create(name string, version PkgVersion, tag BottleTag,
	rebuild int) !BottleFilename {
	return new_bottle_filename(name, version, tag, rebuild)
}

// Ruby method `initialize(name, version, tag, rebuild)` at line 25.
pub fn ruby_bottle_l25_d6_initialize(name string, version PkgVersion, tag BottleTag,
	rebuild int) !BottleFilename {
	return new_bottle_filename(name, version, tag, rebuild)
}

// Ruby method `to_str` at line 37.
pub fn ruby_bottle_l37_d7_to_str(filename &BottleFilename) string {
	return filename.str()
}

// Ruby method `to_s = to_str` at line 42.
pub fn ruby_bottle_l42_d8_to_s(filename &BottleFilename) string {
	return filename.str()
}

// Ruby method `json` at line 45.
pub fn ruby_bottle_l45_d9_json(filename &BottleFilename) string {
	return filename.json()
}

// Ruby method `url_encode` at line 50.
pub fn ruby_bottle_l50_d10_url_encode(filename &BottleFilename) string {
	return filename.url_encode()
}

// Ruby method `github_packages` at line 55.
pub fn ruby_bottle_l55_d11_github_packages(filename &BottleFilename) string {
	return filename.github_packages()
}

// Ruby method `extname` at line 60.
pub fn ruby_bottle_l60_d12_extname(filename &BottleFilename) string {
	return filename.extname()
}

// Ruby attr_reader `attr_reader :name` at line 69.
pub fn ruby_bottle_l69_d13_name(bottle &Bottle) string {
	return bottle.name
}

// Ruby attr_reader `attr_reader :resource` at line 72.
pub fn ruby_bottle_l72_d14_resource(bottle &Bottle) Resource {
	return bottle.resource
}

// Ruby attr_reader `attr_reader :tag` at line 75.
pub fn ruby_bottle_l75_d15_tag(bottle &Bottle) BottleTag {
	return bottle.tag
}

// Ruby attr_reader `attr_reader :cellar` at line 78.
pub fn ruby_bottle_l78_d16_cellar(bottle &Bottle) BottleCellar {
	return bottle.cellar
}

// Ruby attr_reader `attr_reader :rebuild` at line 81.
pub fn ruby_bottle_l81_d17_rebuild(bottle &Bottle) int {
	return bottle.rebuild
}

// Ruby def_delegators `def_delegators :resource, :url, :verify_download_integrity` at line 83.
pub fn ruby_bottle_l83_d18_url(bottle &Bottle) ?string {
	return bottle.resource.url()
}

// Ruby def_delegators `def_delegators :resource, :url, :verify_download_integrity` at line 83.
pub fn ruby_bottle_l83_d19_verify_download_integrity(mut bottle Bottle, filename string) ! {
	bottle.resource.verify_download_integrity(filename)!
}

// Ruby def_delegators `def_delegators :resource, :cached_download, :downloader` at line 84.
pub fn ruby_bottle_l84_d20_cached_download(mut bottle Bottle) !string {
	return bottle.resource.cached_download()
}

// Ruby def_delegators `def_delegators :resource, :cached_download, :downloader` at line 84.
pub fn ruby_bottle_l84_d21_downloader(mut bottle Bottle) !&download_strategy.CurlDownloadStrategy {
	return bottle.resource.downloader()
}

// Ruby method `initialize(formula, spec, tag = nil, name: nil, pkg_version: nil)` at line 95.
pub fn ruby_bottle_l95_d22_initialize(name string, pkg_version PkgVersion,
	mut specification BottleSpecification, tag BottleTag) !Bottle {
	return new_bottle(name, pkg_version, mut specification, tag)
}

// Ruby method `fetch(verify_download_integrity: true, timeout: nil, quiet: false)` at line 138.
pub fn ruby_bottle_l138_d23_fetch(mut bottle Bottle, verify_download_integrity bool,
	timeout ?f64, quiet bool) !string {
	return bottle.resource.fetch(verify_download_integrity, timeout, quiet, false)
}

// Ruby method `downloaded_and_valid?` at line 148.
pub fn ruby_bottle_l148_d24_downloaded_and_valid(mut bottle Bottle) bool {
	return bottle.resource.downloaded_and_valid()
}

// Ruby method `with_corrupt_download_retry(quiet: false, &_block)` at line 166.
pub fn ruby_bottle_l166_d25_with_corrupt_download_retry[T](mut bottle Bottle, quiet bool,
	operation fn () !T) !T {
	return operation() or {
		original_error := err.msg()
		ruby_bottle_l179_d26_discard_corrupt_cached_download(mut bottle)!
		cached_download := bottle.resource.cached_download() or { '' }
		if cached_download != '' && brew_runtime.path_exists(cached_download) {
			return error(original_error)
		}
		bottle.resource.fetch(true, none, quiet, false)!
		return operation()
	}
}

// Ruby method `discard_corrupt_cached_download` at line 179.
pub fn ruby_bottle_l179_d26_discard_corrupt_cached_download(mut bottle Bottle) !bool {
	path := bottle.resource.cached_download() or { return false }
	bottle.resource.verify_download_integrity(path) or {
		bottle.clear_cache()!
		return true
	}
	return false
}

// Ruby method `total_size` at line 190.
pub fn ruby_bottle_l190_d27_total_size(mut bottle Bottle) ?i64 {
	if size := bottle.bottle_size() {
		return size
	}
	return bottle.resource.total_size()
}

// Ruby method `clear_cache` at line 195.
pub fn ruby_bottle_l195_d28_clear_cache(mut bottle Bottle) ! {
	bottle.clear_cache()!
}

// Ruby method `compatible_locations?` at line 202.
pub fn ruby_bottle_l202_d29_compatible_locations(bottle &Bottle,
	context BottleLocationContext) bool {
	return bottle.compatible_locations(context)
}

// Ruby method `skip_relocation?` at line 208.
pub fn ruby_bottle_l208_d30_skip_relocation(bottle &Bottle,
	context BottleLocationContext) bool {
	return bottle.skip_relocation(context)
}

// Ruby method `stage = with_corrupt_download_retry { downloader.stage }` at line 215.
pub fn ruby_bottle_l215_d31_stage(mut bottle Bottle, destination string) !string {
	return bottle.stage(destination)
}

// Ruby method `fetch_tab(timeout: nil, quiet: false)` at line 218.
pub fn ruby_bottle_l218_d32_fetch_tab(mut bottle Bottle, timeout ?f64, quiet bool) ! {
	bottle.fetch_tab(timeout, quiet)!
}

// Ruby method `tab_attributes` at line 234.
pub fn ruby_bottle_l234_d33_tab_attributes(bottle &Bottle) map[string]json2.Any {
	return bottle.tab_attributes()
}

// Ruby method `bottle_size` at line 243.
pub fn ruby_bottle_l243_d34_bottle_size(bottle &Bottle) ?i64 {
	return bottle.bottle_size()
}

// Ruby method `installed_size` at line 251.
pub fn ruby_bottle_l251_d35_installed_size(bottle &Bottle) ?i64 {
	return bottle.installed_size()
}

// Ruby method `path_exec_files` at line 259.
pub fn ruby_bottle_l259_d36_path_exec_files(bottle &Bottle) ?[]string {
	return bottle.path_exec_files()
}

// Ruby method `sbom_supplement` at line 267.
pub fn ruby_bottle_l267_d37_sbom_supplement(mut bottle Bottle,
	current_tag string) ?map[string]json2.Any {
	if !bottle.has_manifest {
		return none
	}
	return bottle.manifest.sbom_supplement(current_tag)
}

// Ruby method `filename = Filename.new(@name, @pkg_version, @tag, @spec.rebuild)` at line 275.
pub fn ruby_bottle_l275_d38_filename(bottle &Bottle) !BottleFilename {
	return bottle.filename()
}

// Ruby method `staged_path_from_download_queue` at line 278.
pub fn ruby_bottle_l278_d39_staged_path_from_download_queue(bottle &Bottle) string {
	temporary_cellar := brew_runtime.environment_value('HOMEBREW_TEMP_CELLAR')
	root := if temporary_cellar != '' { temporary_cellar } else { '/tmp/homebrew/Cellar' }
	return bottle.staged_path_in(root)
}

pub fn (bottle Bottle) staged_path_in(temporary_cellar string) string {
	filename := bottle.filename() or { return temporary_cellar }
	return '${temporary_cellar}/${filename.name}/${filename.version.to_s()}'
}

// Ruby method `staged_path_from_download_queue_marker` at line 284.
pub fn ruby_bottle_l284_d40_staged_path_from_download_queue_marker(bottle &Bottle) string {
	return '${ruby_bottle_l278_d39_staged_path_from_download_queue(bottle)}.poured'
}

// Ruby method `stage_from_download_queue?(_download, pour:)` at line 289.
pub fn ruby_bottle_l289_d41_stage_from_download_queue(_bottle &Bottle, _download string,
	pour bool) bool {
	return pour
}

// Ruby method `stage_from_download_queue(download, pour:)` at line 294.
pub fn ruby_bottle_l294_d42_stage_from_download_queue(mut bottle Bottle, download string,
	pour bool) !string {
	return bottle.stage_from_download_queue(download, pour)
}

// Ruby method `github_packages_manifest_resource` at line 329.
pub fn ruby_bottle_l329_d43_github_packages_manifest_resource(bottle &Bottle) ?BottleManifestPlan {
	return bottle.github_packages_manifest_plan()
}

// Ruby method `download_queue_type = "Bottle"` at line 369.
pub fn ruby_bottle_l369_d44_download_queue_type(_bottle &Bottle) string {
	return 'Bottle'
}

// Ruby method `download_queue_name = "#{name} (#{resource.version})"` at line 372.
pub fn ruby_bottle_l372_d45_download_queue_name(bottle &Bottle) string {
	return '${bottle.name} (${bottle.pkg_version.to_s()})'
}

// Ruby method `select_download_strategy(specs)` at line 377.
pub fn ruby_bottle_l377_d46_select_download_strategy(bottle &Bottle,
	specs map[string]string) !map[string]string {
	if !bottle.has_root_url {
		return error('cannot select download strategy for ${bottle.name} because root_url is nil')
	}
	mut selected := specs.clone()
	selected['bottle'] = 'true'
	return selected
}

// Ruby method `fallback_on_error?` at line 385.
pub fn ruby_bottle_l385_d47_fallback_on_error(mut bottle Bottle) !bool {
	configured := custom_bottle_domain() or { return false }
	url := bottle.resource.url() or { return false }
	if !url.starts_with(configured) {
		return false
	}
	default_domain_value :=
		brew_runtime.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN').trim_string_right('/')
	default_domain := if default_domain_value != '' {
		default_domain_value
	} else {
		'https://ghcr.io/v2/homebrew/core'
	}
	bottle.set_root_url(default_domain, map[string]string{})!
	bottle.has_manifest = false
	return true
}

// Ruby method `root_url(val = nil, specs = {})` at line 399.
pub fn ruby_bottle_l399_d48_root_url(mut bottle Bottle, value ?string,
	specs map[string]string) !string {
	if root := value {
		return bottle.set_root_url(root, specs)!
	}
	return bottle.root_url() or { return error('root_url is nil') }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "unpack_strategy"
// 5:
// 6: class Bottle
// 7:   include Downloadable
// 8:
// 9:   class Filename
// 10:     sig { returns(String) }
// 11:     attr_reader :name, :tag
// 12:
// 13:     sig { returns(PkgVersion) }
// 14:     attr_reader :version
// 15:
// 16:     sig { returns(Integer) }
// 17:     attr_reader :rebuild
// 18:
// 19:     sig { params(formula: Formula, tag: Utils::Bottles::Tag, rebuild: Integer).returns(T.attached_class) }
// 20:     def self.create(formula, tag, rebuild)
// 21:       new(formula.name, formula.pkg_version, tag, rebuild)
// 22:     end
// 23:
// 24:     sig { params(name: String, version: PkgVersion, tag: Utils::Bottles::Tag, rebuild: Integer).void }
// 25:     def initialize(name, version, tag, rebuild)
// 26:       @name = T.let(File.basename(name), String)
// 27:
// 28:       raise ArgumentError, "Invalid bottle name" unless Utils.safe_filename?(@name)
// 29:       raise ArgumentError, "Invalid bottle version" unless Utils.safe_filename?(version.to_s)
// 30:
// 31:       @version = version
// 32:       @tag = T.let(tag.to_unstandardized_sym.to_s, String)
// 33:       @rebuild = rebuild
// 34:     end
// 35:
// 36:     sig { returns(String) }
// 37:     def to_str
// 38:       "#{name}--#{version}#{extname}"
// 39:     end
// 40:
// 41:     sig { returns(String) }
// 42:     def to_s = to_str
// 43:
// 44:     sig { returns(String) }
// 45:     def json
// 46:       "#{name}--#{version}.#{tag}.bottle.json"
// 47:     end
// 48:
// 49:     sig { returns(String) }
// 50:     def url_encode
// 51:       ERB::Util.url_encode("#{name}-#{version}#{extname}")
// 52:     end
// 53:
// 54:     sig { returns(String) }
// 55:     def github_packages
// 56:       "#{name}--#{version}#{extname}"
// 57:     end
// 58:
// 59:     sig { returns(String) }
// 60:     def extname
// 61:       s = rebuild.positive? ? ".#{rebuild}" : ""
// 62:       ".#{tag}.bottle#{s}.tar.gz"
// 63:     end
// 64:   end
// 65:
// 66:   extend Forwardable
// 67:
// 68:   sig { returns(String) }
// 69:   attr_reader :name
// 70:
// 71:   sig { returns(Resource) }
// 72:   attr_reader :resource
// 73:
// 74:   sig { returns(Utils::Bottles::Tag) }
// 75:   attr_reader :tag
// 76:
// 77:   sig { returns(T.any(String, Symbol)) }
// 78:   attr_reader :cellar
// 79:
// 80:   sig { returns(Integer) }
// 81:   attr_reader :rebuild
// 82:
// 83:   def_delegators :resource, :url, :verify_download_integrity
// 84:   def_delegators :resource, :cached_download, :downloader
// 85:
// 86:   sig {
// 87:     params(
// 88:       formula:     T.nilable(Formula),
// 89:       spec:        BottleSpecification,
// 90:       tag:         T.nilable(Utils::Bottles::Tag),
// 91:       name:        T.nilable(String),
// 92:       pkg_version: T.nilable(PkgVersion),
// 93:     ).void
// 94:   }
// 95:   def initialize(formula, spec, tag = nil, name: nil, pkg_version: nil)
// 96:     super()
// 97:
// 98:     resource_name = T.let(nil, T.nilable(String))
// 99:     if formula
// 100:       name = formula.name
// 101:       pkg_version = formula.pkg_version
// 102:     else
// 103:       raise ArgumentError, "Bottle name is required" if name.nil?
// 104:       raise ArgumentError, "Bottle version is required" if pkg_version.nil?
// 105:
// 106:       resource_name = name
// 107:     end
// 108:
// 109:     @name = T.let(name, String)
// 110:     @pkg_version = T.let(pkg_version, PkgVersion)
// 111:     @resource = T.let(Resource.new(resource_name), Resource)
// 112:     @resource.owner = formula if formula
// 113:     @spec = spec
// 114:
// 115:     tag_spec = spec.tag_specification_for(Utils::Bottles.tag(tag))
// 116:
// 117:     odie "#{@name} tag specification for tag #{tag} is nil" if tag_spec.nil?
// 118:
// 119:     @tag = T.let(tag_spec.tag, Utils::Bottles::Tag)
// 120:     @cellar = T.let(tag_spec.cellar, T.any(String, Symbol))
// 121:     @rebuild = T.let(spec.rebuild, Integer)
// 122:
// 123:     @resource.version(@pkg_version.to_s)
// 124:     @resource.checksum = tag_spec.checksum
// 125:
// 126:     @fetch_tab_retried = T.let(false, T::Boolean)
// 127:
// 128:     root_url(spec.root_url, spec.root_url_specs)
// 129:   end
// 130:
// 131:   sig {
// 132:     override.params(
// 133:       verify_download_integrity: T::Boolean,
// 134:       timeout:                   T.nilable(T.any(Integer, Float)),
// 135:       quiet:                     T::Boolean,
// 136:     ).returns(Pathname)
// 137:   }
// 138:   def fetch(verify_download_integrity: true, timeout: nil, quiet: false)
// 139:     resource.fetch(verify_download_integrity:, timeout:, quiet:)
// 140:   rescue DownloadError
// 141:     raise unless fallback_on_error?
// 142:
// 143:     fetch_tab
// 144:     retry
// 145:   end
// 146:
// 147:   sig { override.returns(T::Boolean) }
// 148:   def downloaded_and_valid?
// 149:     return false unless cached_download.file?
// 150:
// 151:     resource_checksum = resource.checksum
// 152:     return false if resource_checksum.nil?
// 153:
// 154:     downloader = resource.downloader
// 155:     return false unless downloader.is_a?(CurlGitHubPackagesDownloadStrategy)
// 156:     return false unless downloader.immutable_bottle_blob?
// 157:
// 158:     downloader.bottle_blob_sha256 == resource_checksum.hexdigest
// 159:   end
// 160:
// 161:   # A cached immutable blob is trusted without rehashing it (see
// 162:   # `downloaded_and_valid?`), so a locally corrupted bottle would fail to
// 163:   # extract on every run: verify it after a failed extraction and, when it was
// 164:   # indeed corrupt, discard it and retry with a freshly downloaded one.
// 165:   sig { params(quiet: T::Boolean, _block: T.proc.void).void }
// 166:   def with_corrupt_download_retry(quiet: false, &_block)
// 167:     yield
// 168:   rescue
// 169:     discard_corrupt_cached_download
// 170:     raise if cached_download.exist?
// 171:
// 172:     downloading!
// 173:     fetch(quiet:)
// 174:     extracting!
// 175:     yield
// 176:   end
// 177:
// 178:   sig { void }
// 179:   def discard_corrupt_cached_download
// 180:     expected_checksum = resource.checksum
// 181:     return if expected_checksum.nil?
// 182:     return unless cached_download.file?
// 183:     return if cached_download.sha256 == expected_checksum.hexdigest
// 184:
// 185:     opoo "Removing corrupt cached download: #{cached_download.basename}"
// 186:     clear_cache
// 187:   end
// 188:
// 189:   sig { override.returns(T.nilable(Integer)) }
// 190:   def total_size
// 191:     bottle_size || super
// 192:   end
// 193:
// 194:   sig { override.void }
// 195:   def clear_cache
// 196:     @resource.clear_cache
// 197:     github_packages_manifest_resource&.clear_cache
// 198:     @fetch_tab_retried = false
// 199:   end
// 200:
// 201:   sig { returns(T::Boolean) }
// 202:   def compatible_locations?
// 203:     @spec.compatible_locations?(tag: @tag)
// 204:   end
// 205:
// 206:   # Does the bottle need to be relocated?
// 207:   sig { returns(T::Boolean) }
// 208:   def skip_relocation?
// 209:     attrs = tab_attributes
// 210:     tab = Tab.new(**attrs.transform_keys(&:to_sym)) unless attrs.empty?
// 211:     @spec.skip_relocation?(tag: @tag, tab:)
// 212:   end
// 213:
// 214:   sig { void }
// 215:   def stage = with_corrupt_download_retry { downloader.stage }
// 216:
// 217:   sig { params(timeout: T.nilable(T.any(Integer, Float)), quiet: T::Boolean).void }
// 218:   def fetch_tab(timeout: nil, quiet: false)
// 219:     return unless (resource = github_packages_manifest_resource)
// 220:
// 221:     begin
// 222:       # `$HOMEBREW_BOTTLE_DOMAIN` fallback is configured on the resource below.
// 223:       resource.fetch(timeout:, quiet:)
// 224:     rescue Resource::BottleManifest::Error
// 225:       raise if @fetch_tab_retried
// 226:
// 227:       @fetch_tab_retried = true
// 228:       resource.clear_cache
// 229:       retry
// 230:     end
// 231:   end
// 232:
// 233:   sig { returns(T::Hash[String, T.untyped]) }
// 234:   def tab_attributes
// 235:     if (resource = github_packages_manifest_resource) && resource.downloaded?
// 236:       return resource.tab
// 237:     end
// 238:
// 239:     {}
// 240:   end
// 241:
// 242:   sig { returns(T.nilable(Integer)) }
// 243:   def bottle_size
// 244:     resource = github_packages_manifest_resource
// 245:     return unless resource&.downloaded?
// 246:
// 247:     resource.bottle_size
// 248:   end
// 249:
// 250:   sig { returns(T.nilable(Integer)) }
// 251:   def installed_size
// 252:     resource = github_packages_manifest_resource
// 253:     return unless resource&.downloaded?
// 254:
// 255:     resource.installed_size
// 256:   end
// 257:
// 258:   sig { returns(T.nilable(T::Array[String])) }
// 259:   def path_exec_files
// 260:     resource = github_packages_manifest_resource
// 261:     return unless resource&.downloaded?
// 262:
// 263:     resource.path_exec_files
// 264:   end
// 265:
// 266:   sig { returns(T.nilable(T::Hash[String, Object])) }
// 267:   def sbom_supplement
// 268:     resource = github_packages_manifest_resource
// 269:     return unless resource&.downloaded_and_valid?
// 270:
// 271:     resource.sbom_supplement
// 272:   end
// 273:
// 274:   sig { returns(Filename) }
// 275:   def filename = Filename.new(@name, @pkg_version, @tag, @spec.rebuild)
// 276:
// 277:   sig { returns(Pathname) }
// 278:   def staged_path_from_download_queue
// 279:     bottle_filename = filename
// 280:     HOMEBREW_TEMP_CELLAR/bottle_filename.name/bottle_filename.version.to_s
// 281:   end
// 282:
// 283:   sig { returns(Pathname) }
// 284:   def staged_path_from_download_queue_marker
// 285:     Pathname("#{staged_path_from_download_queue}.poured")
// 286:   end
// 287:
// 288:   sig { override.params(_download: Pathname, pour: T::Boolean).returns(T::Boolean) }
// 289:   def stage_from_download_queue?(_download, pour:)
// 290:     pour
// 291:   end
// 292:
// 293:   sig { override.params(download: Pathname, pour: T::Boolean).void }
// 294:   def stage_from_download_queue(download, pour:)
// 295:     return unless pour
// 296:
// 297:     bottle_tmp_keg = staged_path_from_download_queue
// 298:     bottle_poured_file = staged_path_from_download_queue_marker
// 299:
// 300:     # Stay quiet on the retry: the download queue is redrawing its own
// 301:     # progress lines while this runs in a worker thread.
// 302:     with_corrupt_download_retry(quiet: true) do
// 303:       HOMEBREW_TEMP_CELLAR.mkpath
// 304:
// 305:       next if bottle_poured_file.exist?
// 306:
// 307:       FileUtils.rm(bottle_poured_file) if bottle_poured_file.symlink?
// 308:       FileUtils.rm_r(bottle_tmp_keg) if bottle_tmp_keg.directory?
// 309:
// 310:       UnpackStrategy.detect(download, prioritize_extension: true)
// 311:                     .extract_nestedly(to: HOMEBREW_TEMP_CELLAR)
// 312:
// 313:       # Create a separate file to mark a completed extraction. This avoids
// 314:       # a potential race condition if a user interrupts the install.
// 315:       # We use a symlink to easily check that both this extra status file
// 316:       # and the real extracted directory exist via `Pathname#exist?`.
// 317:       FileUtils.ln_s(bottle_tmp_keg, bottle_poured_file)
// 318:     # Catch any exception type here to clean up partial queued extractions.
// 319:     rescue Exception # rubocop:disable Lint/RescueException
// 320:       ignore_interrupts do
// 321:         FileUtils.rm_r(bottle_tmp_keg) if bottle_tmp_keg.directory?
// 322:         bottle_tmp_keg.parent.rmdir_if_possible
// 323:       end
// 324:       raise
// 325:     end
// 326:   end
// 327:
// 328:   sig { returns(T.nilable(Resource::BottleManifest)) }
// 329:   def github_packages_manifest_resource
// 330:     # `$HOMEBREW_BOTTLE_DOMAIN` may be a legacy flat-file mirror, so its
// 331:     # bottle resource does not necessarily use the GitHub Packages strategy.
// 332:     custom_bottle_domain = Homebrew::EnvConfig.bottle_domain_custom? &&
// 333:                            root_url == Homebrew::EnvConfig.bottle_domain
// 334:     return if @resource.download_strategy != CurlGitHubPackagesDownloadStrategy && !custom_bottle_domain
// 335:
// 336:     @github_packages_manifest_resource ||= T.let(
// 337:       begin
// 338:         resource = Resource::BottleManifest.new(self)
// 339:
// 340:         resource_version = @resource.version
// 341:         odie "resource version is nil" if resource_version.nil?
// 342:
// 343:         version_rebuild = GitHubPackages.version_rebuild(resource_version, rebuild)
// 344:         resource.version(version_rebuild)
// 345:
// 346:         image_name = GitHubPackages.image_formula_name(@name)
// 347:         image_tag = GitHubPackages.image_version_rebuild(version_rebuild)
// 348:         manifest_path = "#{image_name}/manifests/#{image_tag}"
// 349:         resource.url(
// 350:           "#{root_url}/#{manifest_path}",
// 351:           using:   CurlGitHubPackagesDownloadStrategy,
// 352:           headers: ["Accept: application/vnd.oci.image.index.v1+json"],
// 353:         )
// 354:         # Give a legacy mirror the first chance to serve the manifest. Many
// 355:         # contain only bottle archives, so retain GHCR as a fallback. By
// 356:         # contrast, `$HOMEBREW_ARTIFACT_DOMAIN` must provide an OCI registry
// 357:         # proxy for bottle blobs and manifests; the strategy rewrites the GHCR
// 358:         # URL for it.
// 359:         resource.mirror("#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/#{manifest_path}") if custom_bottle_domain
// 360:         T.cast(resource.downloader, CurlGitHubPackagesDownloadStrategy).resolved_basename =
// 361:           "#{name}-#{version_rebuild}.bottle_manifest.json"
// 362:         resource
// 363:       end,
// 364:       T.nilable(Resource::BottleManifest),
// 365:     )
// 366:   end
// 367:
// 368:   sig { override.returns(String) }
// 369:   def download_queue_type = "Bottle"
// 370:
// 371:   sig { override.returns(String) }
// 372:   def download_queue_name = "#{name} (#{resource.version})"
// 373:
// 374:   private
// 375:
// 376:   sig { params(specs: T::Hash[Symbol, T.anything]).returns(T::Hash[Symbol, T.anything]) }
// 377:   def select_download_strategy(specs)
// 378:     odie "cannot select download strategy for #{name} because root_url is nil" if @root_url.nil?
// 379:     specs[:using] ||= DownloadStrategyDetector.detect(@root_url)
// 380:     specs[:bottle] = true
// 381:     specs
// 382:   end
// 383:
// 384:   sig { returns(T::Boolean) }
// 385:   def fallback_on_error?
// 386:     # Use the default bottle domain as a fallback mirror
// 387:     if @resource.url&.start_with?(Homebrew::EnvConfig.bottle_domain) &&
// 388:        Homebrew::EnvConfig.bottle_domain_custom?
// 389:       opoo "Bottle missing, falling back to the default domain..."
// 390:       root_url(HOMEBREW_BOTTLE_DEFAULT_DOMAIN)
// 391:       @github_packages_manifest_resource = T.let(nil, T.nilable(Resource::BottleManifest))
// 392:       true
// 393:     else
// 394:       false
// 395:     end
// 396:   end
// 397:
// 398:   sig { params(val: T.nilable(String), specs: T::Hash[Symbol, T.anything]).returns(T.nilable(String)) }
// 399:   def root_url(val = nil, specs = {})
// 400:     return @root_url if val.nil?
// 401:
// 402:     @root_url = T.let(val, T.nilable(String))
// 403:
// 404:     filename = self.filename
// 405:     resource_checksum = resource.checksum
// 406:     odie "resource checksum is nil" if resource_checksum.nil?
// 407:
// 408:     path, resolved_basename = Utils::Bottles.path_resolved_basename(val, name, resource_checksum, filename)
// 409:     @resource.url("#{val}/#{path}", **select_download_strategy(specs))
// 410:     return unless resolved_basename.present?
// 411:
// 412:     downloader = @resource.downloader
// 413:     return unless downloader.is_a?(CurlGitHubPackagesDownloadStrategy)
// 414:
// 415:     downloader.resolved_basename = resolved_basename
// 416:   end
// 417: end
