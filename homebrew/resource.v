module homebrew

import ruby
import crypto.sha256
import homebrew.download_strategy
import homebrew.unpack_strategy
import json2

// Translated from Homebrew/brew `resource.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum ResourcePhase {
	preparing
	downloading
	downloaded
	verifying
	verified
	extracting
}

pub enum ResourceKind {
	resource
	local
	formula
	bottle_manifest
	patch
}

pub struct ResourcePatch {
pub mut:
	strip      string
	source     string
	owner_name string
}

pub struct ResourcePartial {
pub:
	resource_name string
	files         []string
}

pub struct LivecheckSpec {
pub:
	url   string
	regex string
}

// Resource is the typed V representation of Downloadable plus Resource's DSL
// state. Formula/Cask ownership is represented by its stable name until those
// object graphs are translated.
@[heap]
pub struct Resource {
pub mut:
	name                     string
	has_name                 bool
	source_modified_time     i64
	has_source_modified_time bool
	patches                  []ResourcePatch
	owner_name               string
	has_owner                bool
	checksum                 Checksum
	has_checksum             bool
	url_value                Url
	has_url                  bool
	version_value            Version
	has_version              bool
	strategy_value           download_strategy.DownloadStrategy
	has_strategy             bool
	mirrors                  []string
	downloader_value         download_strategy.CurlDownloadStrategy
	has_downloader           bool
	phase                    ResourcePhase
	livecheck_value          LivecheckSpec
	livecheck_defined_value  bool
	insecure                 bool
	kind                     ResourceKind
}

pub fn new_resource(name string) Resource {
	return Resource{
		name: name
		has_name: name != ''
		phase: .preparing
		kind: .resource
	}
}

pub fn (resource Resource) duplicate() Resource {
	mut copy := resource
	copy.patches = resource.patches.clone()
	copy.mirrors = resource.mirrors.clone()
	copy.url_value.specs.clone()
	return copy
}

pub fn (resource Resource) frozen_copy() Resource {
	return resource.duplicate()
}

pub fn (mut resource Resource) set_owner(owner_name ?string) {
	if owner := owner_name {
		resource.owner_name = owner
		resource.has_owner = true
		for mut patch in resource.patches {
			patch.owner_name = owner
		}
	} else {
		resource.owner_name = ''
		resource.has_owner = false
	}
}

pub fn (resource &Resource) download_queue_type() string {
	return match resource.kind {
		.formula { 'Formula' }
		.bottle_manifest { 'Bottle Manifest' }
		.patch { 'Patch' }
		else { 'Resource' }
	}
}

pub fn (resource &Resource) download_queue_name() !string {
	if resource.kind == .formula {
		if !resource.has_owner {
			return error('Formula resource has no owner')
		}
		version := resource.version_value.to_s()
		return '${resource.owner_name} (${version})'
	}
	return resource.download_name()
}

pub fn (resource &Resource) download_queue_message() !string {
	return '${resource.download_queue_type()} ${resource.download_queue_name()!}'
}

pub fn (mut resource Resource) set_checksum(checksum ?Checksum) {
	if value := checksum {
		resource.checksum = value
		resource.has_checksum = true
	} else {
		resource.checksum = Checksum{}
		resource.has_checksum = false
	}
}

pub fn (mut resource Resource) sha256(value string) Checksum {
	resource.checksum = new_checksum(value)
	resource.has_checksum = true
	return resource.checksum
}

pub fn (mut resource Resource) set_url(value string, source_specs map[string]string) !string {
	mut url_specs := source_specs.clone()
	url_specs.delete('insecure')
	if resource.insecure {
		url_specs['insecure'] = 'true'
	}
	resource.url_value = new_url(value, url_specs)
	resource.has_url = true
	resource.strategy_value = resource.url_value.download_strategy()!
	resource.has_strategy = true
	resource.has_downloader = false
	return value
}

pub fn (resource &Resource) url() ?string {
	if resource.has_url {
		return resource.url_value.to_s()
	}
	return none
}

pub fn (mut resource Resource) set_version(value string) !Version {
	resource.version_value = if value.trim_space() == '' {
		null_version()
	} else {
		new_version(value)!
	}
	resource.has_version = true
	resource.has_downloader = false
	return resource.version_value
}

pub fn (resource &Resource) version() ?Version {
	if resource.has_version && !resource.version_value.is_null() {
		return resource.version_value
	}
	if resource.has_url {
		detected := resource.url_value.version()
		if !detected.is_null() {
			return detected
		}
	}
	return none
}

pub fn (mut resource Resource) mirror(value string) []string {
	resource.mirrors << value
	resource.has_downloader = false
	return resource.mirrors.clone()
}

pub fn (mut resource Resource) add_patch(strip string, source string) []ResourcePatch {
	resource.patches << ResourcePatch{
		strip: strip
		source: source
		owner_name: resource.owner_name
	}
	return resource.patches.clone()
}

pub fn (resource &Resource) using() ?string {
	if resource.has_url {
		return resource.url_value.using()
	}
	return none
}

pub fn (resource &Resource) specs() map[string]string {
	if resource.has_url {
		return resource.url_value.specs.clone()
	}
	return map[string]string{}
}

pub fn (mut resource Resource) set_download_strategy(strategy ?download_strategy.DownloadStrategy) {
	if value := strategy {
		resource.strategy_value = value
		resource.has_strategy = true
	} else {
		resource.has_strategy = false
	}
	resource.has_downloader = false
}

pub fn (resource &Resource) download_strategy() !download_strategy.DownloadStrategy {
	if resource.has_strategy {
		return resource.strategy_value
	}
	if resource.has_url {
		return resource.url_value.download_strategy()
	}
	return error('attempted to use a Resource without a URL')
}

pub fn (resource &Resource) download_name() !string {
	if resource.has_name {
		escaped_name := resource.name.replace('/', '-')
		return if resource.has_owner {
			'${resource.owner_name}--${escaped_name}'
		} else {
			escaped_name
		}
	}
	if resource.has_owner {
		return resource.owner_name
	}
	return error('Resource name and owner name are both nil')
}

pub fn (resource &Resource) determine_url_mirrors() ![]string {
	primary_url := resource.url() or { return error('attempted to use a Resource without a URL') }
	mut extra_urls := []string{}
	if primary_url.starts_with('https://github.com/Homebrew/glibc-bootstrap/releases/download') {
		artifact_domain := ruby.environment_value('HOMEBREW_ARTIFACT_DOMAIN').trim_right('/')
		if artifact_domain != '' {
			artifact_url := primary_url.replace_once('https://github.com', artifact_domain)
			if environment_enabled('HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK') {
				return [artifact_url]
			}
			extra_urls << artifact_url
		}
		bottle_domain := ruby.environment_value('HOMEBREW_BOTTLE_DOMAIN').trim_right('/')
		if bottle_domain != '' {
			parts := primary_url.split('/')
			if parts.len >= 2 {
				extra_urls << '${bottle_domain}/glibc-bootstrap/${parts[parts.len - 2]}/${parts.last()}'
			}
		}
	}
	pip_index := ruby.environment_value('HOMEBREW_PIP_INDEX_URL').trim_right('/')
	if pip_index != '' {
		pip_base := pip_index.trim_string_right('/simple')
		for base_url in ['https://files.pythonhosted.org', 'https://pypi.org'] {
			if primary_url.starts_with('${base_url}/packages') {
				extra_urls << primary_url.replace_once(base_url, pip_base)
			}
		}
	}
	mut urls := extra_urls.clone()
	urls << primary_url
	urls << resource.mirrors
	return unique_strings(urls)
}

fn unique_strings(values []string) []string {
	mut output := []string{}
	for value in values {
		if value !in output {
			output << value
		}
	}
	return output
}

fn environment_enabled(name string) bool {
	return ruby.environment_value(name).to_lower() in ['1', 'true', 'yes', 'on']
}

fn strategy_is_curl_derived(strategy download_strategy.DownloadStrategy) bool {
	return strategy in [.curl, .curl_apache_mirror, .curl_github_packages, .curl_post, .homebrew_curl,
		.no_unzip_curl, .pypi]
}

pub fn (mut resource Resource) downloader() !&download_strategy.CurlDownloadStrategy {
	if resource.has_downloader {
		return &resource.downloader_value
	}
	strategy := resource.download_strategy()!
	if !strategy_is_curl_derived(strategy) {
		return error('${strategy.class_name()} is not translated into a concrete V downloader yet')
	}
	urls := resource.determine_url_mirrors()!
	if urls.len == 0 || urls[0] == '' {
		return error('attempted to use a Resource without a URL')
	}
	version := resource.version() or { null_version() }
	mut metadata := download_strategy.DownloadMeta{
		mirrors: urls[1..].clone()
	}
	specs := resource.specs()
	metadata.cache = specs['cache'] or { '' }
	metadata.header = specs['header'] or { '' }
	metadata.referer = specs['referer'] or { '' }
	metadata.user = specs['user'] or { '' }
	metadata.user_agent = specs['user_agent'] or { '' }
	resource.downloader_value = download_strategy.new_curl_download_strategy(urls[0], resource.download_name()!, version.to_s(), metadata)
	if download_strategy.expand_deferred_environment_for(strategy) {
		resource.downloader_value.allow_deferred_environment_expansion()
	}
	resource.has_downloader = true
	return &resource.downloader_value
}

pub fn (mut resource Resource) cached_download() !string {
	mut downloader := resource.downloader()!
	return downloader.cached_location()
}

pub fn (mut resource Resource) downloaded() bool {
	path := resource.cached_download() or { return false }
	return ruby.path_exists(path)
}

pub fn (mut resource Resource) downloaded_and_valid() bool {
	path := resource.cached_download() or { return false }
	if !ruby.is_file(path) || !resource.has_checksum || resource.checksum.is_empty() {
		return false
	}
	resource.verify_download_integrity(path) or { return false }
	return true
}

pub fn (mut resource Resource) verify_download_integrity(filename string) ! {
	resource.phase = .verifying
	if !ruby.is_file(filename) {
		return
	}
	if !resource.has_checksum || resource.checksum.is_empty() {
		return
	}
	actual := sha256.sum256(ruby.read_bytes(filename)!).hex()
	if actual != resource.checksum.hexdigest {
		return error('SHA-256 mismatch for ${filename}: expected ${resource.checksum.hexdigest}, got ${actual}')
	}
	resource.phase = .verified
}

pub fn (mut resource Resource) fetch(verify_download_integrity bool, timeout ?f64, quiet bool, skip_patches bool) !string {
	if !skip_patches {
		resource.fetch_patches(false)!
	}
	resource.phase = .downloading
	mut downloader := resource.downloader()!
	if quiet {
		downloader.file.base.quiet()
	}
	downloader.fetch(timeout)!
	resource.phase = .downloaded
	download := downloader.cached_location()
	if verify_download_integrity {
		resource.verify_download_integrity(download)!
	}
	return download
}

pub fn (mut resource Resource) clear_cache() ! {
	mut downloader := resource.downloader()!
	downloader.clear_cache()!
}

pub fn (mut resource Resource) fetched_size() ?i64 {
	mut downloader := resource.downloader() or { return none }
	return downloader.file.fetched_size()
}

pub fn (mut resource Resource) total_size() ?i64 {
	downloader := resource.downloader() or { return none }
	return downloader.total_size()
}

pub fn (mut resource Resource) stage(target string, debug_symbols bool) !string {
	_ = debug_symbols
	if target == '' {
		return error('Target directory or block is required')
	}
	resource.prepare_patches()!
	resource.fetch_patches(true)!
	if !resource.downloaded() {
		resource.fetch(true, none, false, true)!
	}
	return resource.unpack(target, debug_symbols)
}

pub fn (mut resource Resource) prepare_patches() ! {
	// DATAPatch owner-path mutation remains at the Formula/SoftwareSpec boundary.
}

pub fn (mut resource Resource) fetch_patches(skip_downloaded bool) ! {
	_ = skip_downloaded
	if resource.patches.len > 0 {
		return error('external patch fetching requires the untranslated Formula/Patch object boundary')
	}
}

pub fn (mut resource Resource) apply_patches() ! {
	if resource.patches.len > 0 {
		return error('patch application requires the untranslated Formula/Patch object boundary')
	}
}

pub fn (mut resource Resource) unpack(target string, debug_symbols bool) !string {
	_ = debug_symbols
	mut downloader := resource.downloader()!
	cached := downloader.cached_location()
	basename := downloader.file.basename()
	strategy := unpack_strategy.detect(cached, unpack_strategy.DetectOptions{
		prioritize_extension: true
	})
	strategy.extract_nestedly(unpack_strategy.ExtractOptions{
		destination: target
		basename: basename
		prioritize_extension: true
	})!
	working_directory := downloader.file.base.stage_working_directory(target)!
	resource.source_modified_time = downloader.file.base.source_modified_time(working_directory)!
	resource.has_source_modified_time = true
	resource.apply_patches()!
	return working_directory
}

pub fn (resource &Resource) files(paths []string) ResourcePartial {
	return ResourcePartial{
		resource_name: resource.name
		files: paths.clone()
	}
}

pub fn (mut resource Resource) set_livecheck(spec LivecheckSpec) LivecheckSpec {
	resource.livecheck_value = spec
	resource.livecheck_defined_value = true
	return spec
}

pub fn (resource &Resource) stage_resource(prefix string, debug_symbols bool) string {
	_ = debug_symbols
	return '${prefix}.stage'
}

pub fn new_local_resource(path string) !Resource {
	name := path.replace('\\', '/').all_after_last('/')
	mut resource := new_resource(name)
	resource.kind = .local
	resource.set_url(if path.starts_with('file://') { path } else { 'file://${path}' }, map[string]string{})!
	return resource
}

pub fn new_formula_resource(name string) Resource {
	mut resource := new_resource(name)
	resource.kind = .formula
	return resource
}

pub struct BottleDescriptor {
pub:
	name     string
	version  string
	checksum string
	rebuild  int
	tag      string
}

pub struct BottleManifestResource {
pub mut:
	resource                   Resource
	bottle                     BottleDescriptor
	manifest_annotations_value map[string]string
	has_manifest_annotations   bool
}

pub fn new_bottle_manifest_resource(bottle BottleDescriptor) BottleManifestResource {
	mut resource := new_resource('${bottle.name}_bottle_manifest')
	resource.kind = .bottle_manifest
	return BottleManifestResource{
		resource: resource
		bottle: bottle
	}
}

pub fn (mut manifest BottleManifestResource) set_manifest_annotations(annotations map[string]string) {
	manifest.manifest_annotations_value = annotations.clone()
	manifest.has_manifest_annotations = true
}

pub fn (mut manifest BottleManifestResource) clear_cache() ! {
	manifest.resource.clear_cache()!
	manifest.manifest_annotations_value.clear()
	manifest.has_manifest_annotations = false
}

pub fn (mut manifest BottleManifestResource) manifest_annotations() !map[string]string {
	if manifest.has_manifest_annotations {
		return manifest.manifest_annotations_value.clone()
	}
	path := manifest.resource.cached_download()!
	decoded := json2.decode[json2.Any](ruby.read_file(path)!) or {
		return error('The downloaded GitHub Packages manifest is not valid JSON: ${path}')
	}
	root := decoded.as_map()
	manifests_value := root['manifests'] or { return error("Missing 'manifests' section.") }
	// GitHub Packages uses `version.tag.rebuild` for tagged bottle refs (and
	// `version-rebuild` for untagged manifest names), matching
	// GitHubPackages.version_rebuild in the Ruby source.
	expected_ref := bottle_version_rebuild(manifest.bottle.version, manifest.bottle.rebuild, manifest.bottle.tag)
	for entry in manifests_value.as_array() {
		entry_map := entry.as_map()
		annotations_value := entry_map['annotations'] or { continue }
		annotations := annotations_value.as_map_of_strings()
		if annotations['sh.brew.bottle.digest'] or { '' } == manifest.bottle.checksum && annotations['org.opencontainers.image.ref.name'] or {
			''} == expected_ref {
			manifest.set_manifest_annotations(annotations)
			return annotations
		}
	}
	return error("Couldn't find manifest matching bottle checksum.")
}

pub fn (mut manifest BottleManifestResource) verify_download_integrity(filename string) ! {
	_ = filename
	manifest.tab()!
}

pub fn (mut manifest BottleManifestResource) downloaded_and_valid() bool {
	if !manifest.resource.downloaded() {
		return false
	}
	manifest.verify_download_integrity('') or {
		manifest.clear_cache() or {}
		return false
	}
	return true
}

pub fn (mut manifest BottleManifestResource) tab() !map[string]json2.Any {
	annotations := manifest.manifest_annotations()!
	tab_text := annotations['sh.brew.tab'] or { return error("Couldn't find tab from manifest.") }
	parsed := json2.decode[json2.Any](tab_text) or { return error("Couldn't parse tab JSON.") }
	return parsed.as_map()
}

fn annotation_i64(annotations map[string]string, key string) ?i64 {
	value := annotations[key] or { return none }
	if value == '' || !value.bytes().all(it.is_digit()) {
		return none
	}
	return value.i64()
}

pub fn (mut manifest BottleManifestResource) bottle_size() ?i64 {
	annotations := manifest.manifest_annotations() or { return none }
	return annotation_i64(annotations, 'sh.brew.bottle.size')
}

pub fn (mut manifest BottleManifestResource) installed_size() ?i64 {
	annotations := manifest.manifest_annotations() or { return none }
	return annotation_i64(annotations, 'sh.brew.bottle.installed_size')
}

pub fn (mut manifest BottleManifestResource) path_exec_files() ?[]string {
	annotations := manifest.manifest_annotations() or { return none }
	value := annotations['sh.brew.path_exec_files'] or { return none }
	return value.split(',')
}

pub fn (mut manifest BottleManifestResource) sbom_supplement(current_tag string) ?map[string]json2.Any {
	annotations := manifest.manifest_annotations() or { return none }
	value := annotations['sh.brew.sbom.supplement'] or { return none }
	parsed := json2.decode[json2.Any](value) or { return none }
	supplement := parsed.as_map()
	if tags_value := supplement['tags'] {
		tags := tags_value.as_map()
		if tag_value := tags[current_tag] {
			return tag_value.as_map()
		}
		return none
	}
	return supplement
}

pub struct PatchResource {
pub mut:
	resource      Resource
	patch_files   []string
	directory     string
	has_directory bool
	file          string
	has_file      bool
	resolves_ids  []string
	patch_type    PatchType
	has_type      bool
}

pub fn new_patch_resource() PatchResource {
	mut resource := new_resource('patch')
	resource.kind = .patch
	return PatchResource{
		resource: resource
	}
}

pub fn (mut patch PatchResource) apply(paths []string) {
	for path in paths {
		if path !in patch.patch_files {
			patch.patch_files << path
		}
	}
}

pub fn (mut patch PatchResource) resolves(cves []string) []string {
	for cve in cves {
		if cve !in patch.resolves_ids {
			patch.resolves_ids << cve
		}
	}
	return patch.resolves_ids.clone()
}

pub fn (mut patch PatchResource) set_type(value ?PatchType) ?PatchType {
	if patch_type := value {
		patch.patch_type = patch_type
		patch.has_type = true
		return patch_type
	}
	if patch.has_type {
		return patch.patch_type
	}
	return none
}

pub fn (mut patch PatchResource) set_directory(value ?string) ?string {
	if directory := value {
		patch.directory = directory
		patch.has_directory = true
		return directory
	}
	if patch.has_directory {
		return patch.directory
	}
	return none
}

pub fn (mut patch PatchResource) set_file(value ?string) !string {
	if path := value {
		if path.starts_with('/') || path.split('/').any(it == '..') {
			return error('Patch file must be a relative path within the repository.')
		}
		patch.file = path
		patch.has_file = true
		return path
	}
	if patch.has_file {
		return patch.file
	}
	return ''
}

pub fn (mut patch PatchResource) download_queue_name() !string {
	if raw_url := patch.resource.url() {
		component := raw_url.split('/').last()
		if component != '' {
			return component
		}
	}
	return patch.resource.download_queue_name()
}

// Source entrypoint translations.
// Ruby attr_reader `attr_reader :source_modified_time` at line 23.
pub fn ruby_resource_l23_d1_source_modified_time(resource &Resource) ?i64 {
	return if resource.has_source_modified_time { resource.source_modified_time } else { none }
}

// Ruby attr_reader `attr_reader :patches` at line 26.
pub fn ruby_resource_l26_d2_patches(resource &Resource) []ResourcePatch {
	return resource.patches.clone()
}

// Ruby attr_reader `attr_reader :owner` at line 29.
pub fn ruby_resource_l29_d3_owner(resource &Resource) ?string {
	return if resource.has_owner { resource.owner_name } else { none }
}

// Ruby attr_writer `attr_writer :checksum` at line 32.
pub fn ruby_resource_l32_d4_checksum(mut resource Resource, checksum ?Checksum) {
	resource.set_checksum(checksum)
}

// Ruby method `download_strategy` at line 35.
pub fn ruby_resource_l35_d5_download_strategy(resource &Resource) !download_strategy.DownloadStrategy {
	return resource.download_strategy()
}

// Ruby attr_writer `attr_writer :download_strategy` at line 40.
pub fn ruby_resource_l40_d6_download_strategy(mut resource Resource, strategy ?download_strategy.DownloadStrategy) {
	resource.set_download_strategy(strategy)
}

// Ruby attr_accessor `attr_accessor :name` at line 45.
pub fn ruby_resource_l45_d7_name(resource &Resource) ?string {
	return if resource.has_name { resource.name } else { none }
}

// Ruby attr_accessor `attr_accessor :name` at line 45.
pub fn ruby_resource_l45_d8_name(mut resource Resource, name ?string) {
	if value := name {
		resource.name = value
		resource.has_name = true
	} else {
		resource.name = ''
		resource.has_name = false
	}
}

// Ruby method `initialize(name = nil, &block)` at line 48.
pub fn ruby_resource_l48_d9_initialize(name string) Resource {
	return new_resource(name)
}

// Ruby method `initialize_dup(other)` at line 63.
pub fn ruby_resource_l63_d10_initialize_dup(resource Resource) Resource {
	return resource.duplicate()
}

// Ruby method `freeze` at line 71.
pub fn ruby_resource_l71_d11_freeze(resource Resource) Resource {
	return resource.frozen_copy()
}

// Ruby method `owner=(owner)` at line 79.
pub fn ruby_resource_l79_d12_owner(mut resource Resource, owner ?string) {
	resource.set_owner(owner)
}

// Ruby method `download_queue_type = "Resource"` at line 85.
pub fn ruby_resource_l85_d13_download_queue_type(resource &Resource) string {
	return resource.download_queue_type()
}

// Ruby method `stage(target = nil, debug_symbols: false, &block)` at line 100.
pub fn ruby_resource_l100_d14_stage(mut resource Resource, target string, debug_symbols bool) !string {
	return resource.stage(target, debug_symbols)
}

// Ruby method `prepare_patches` at line 111.
pub fn ruby_resource_l111_d15_prepare_patches(mut resource Resource) ! {
	resource.prepare_patches()!
}

// Ruby method `fetch_patches(skip_downloaded: false)` at line 116.
pub fn ruby_resource_l116_d16_fetch_patches(mut resource Resource, skip_downloaded bool) ! {
	resource.fetch_patches(skip_downloaded)!
}

// Ruby method `apply_patches` at line 123.
pub fn ruby_resource_l123_d17_apply_patches(mut resource Resource) ! {
	resource.apply_patches()!
}

// Ruby method `unpack(target = nil, debug_symbols: false, &block)` at line 141.
pub fn ruby_resource_l141_d18_unpack(mut resource Resource, target string, debug_symbols bool) !string {
	return resource.unpack(target, debug_symbols)
}

// Ruby method `files(*files)` at line 161.
pub fn ruby_resource_l161_d19_files(resource &Resource, paths []string) ResourcePartial {
	return resource.files(paths)
}

// Ruby method `fetch(verify_download_integrity: true, timeout: nil, quiet: false, skip_patches: false)` at line 174.
pub fn ruby_resource_l174_d20_fetch(mut resource Resource, verify bool, timeout ?f64, quiet bool, skip_patches bool) !string {
	return resource.fetch(verify, timeout, quiet, skip_patches)
}

// Ruby method `livecheck(&block)` at line 195.
pub fn ruby_resource_l195_d21_livecheck(mut resource Resource, spec ?LivecheckSpec) LivecheckSpec {
	if value := spec {
		return resource.set_livecheck(value)
	}
	return resource.livecheck_value
}

// Ruby method `livecheck_defined?` at line 207.
pub fn ruby_resource_l207_d22_livecheck_defined(resource &Resource) bool {
	return resource.livecheck_defined_value
}

// Ruby method `sha256(val)` at line 212.
pub fn ruby_resource_l212_d23_sha256(mut resource Resource, value string) Checksum {
	return resource.sha256(value)
}

// Ruby method `url(val = nil, **specs)` at line 217.
pub fn ruby_resource_l217_d24_url(mut resource Resource, value ?string, specs map[string]string) !string {
	if url_value := value {
		return resource.set_url(url_value, specs)!
	}
	return resource.url() or { '' }
}

// Ruby method `version(val = nil)` at line 233.
pub fn ruby_resource_l233_d25_version(mut resource Resource, value ?string) !Version {
	if version_value := value {
		return resource.set_version(version_value)!
	}
	return resource.version() or { null_version() }
}

// Ruby method `mirror(val)` at line 245.
pub fn ruby_resource_l245_d26_mirror(mut resource Resource, value string) []string {
	return resource.mirror(value)
}

// Ruby method `patch(strip = :p1, src = nil, &block)` at line 256.
pub fn ruby_resource_l256_d27_patch(mut resource Resource, strip string, source string) []ResourcePatch {
	return resource.add_patch(strip, source)
}

// Ruby method `using` at line 262.
pub fn ruby_resource_l262_d28_using(resource &Resource) ?string {
	return resource.using()
}

// Ruby method `specs` at line 267.
pub fn ruby_resource_l267_d29_specs(resource &Resource) map[string]string {
	return resource.specs()
}

// Ruby method `stage_resource(prefix, debug_symbols: false, &block)` at line 281.
pub fn ruby_resource_l281_d30_stage_resource(resource &Resource, prefix string, debug_symbols bool) string {
	return resource.stage_resource(prefix, debug_symbols)
}

// Ruby method `download_name` at line 288.
pub fn ruby_resource_l288_d31_download_name(resource &Resource) !string {
	return resource.download_name()
}

// Ruby method `determine_url_mirrors` at line 305.
pub fn ruby_resource_l305_d32_determine_url_mirrors(resource &Resource) ![]string {
	return resource.determine_url_mirrors()
}

// Ruby method `initialize(path)` at line 339.
pub fn ruby_resource_l339_d33_initialize(path string) !Resource {
	return new_local_resource(path)
}

// Ruby method `download_queue_type = "Formula"` at line 348.
pub fn ruby_resource_l348_d34_download_queue_type(resource &Resource) string {
	return resource.download_queue_type()
}

// Ruby method `download_queue_name = "#{T.must(owner).name} (#{version})"` at line 351.
pub fn ruby_resource_l351_d35_download_queue_name(resource &Resource) !string {
	return resource.download_queue_name()
}

// Ruby attr_reader `attr_reader :bottle` at line 359.
pub fn ruby_resource_l359_d36_bottle(manifest &BottleManifestResource) BottleDescriptor {
	return manifest.bottle
}

// Ruby attr_writer `attr_writer :manifest_annotations` at line 362.
pub fn ruby_resource_l362_d37_manifest_annotations(mut manifest BottleManifestResource, annotations map[string]string) {
	manifest.set_manifest_annotations(annotations)
}

// Ruby method `initialize(bottle)` at line 365.
pub fn ruby_resource_l365_d38_initialize(bottle BottleDescriptor) BottleManifestResource {
	return new_bottle_manifest_resource(bottle)
}

// Ruby method `clear_cache` at line 372.
pub fn ruby_resource_l372_d39_clear_cache(mut manifest BottleManifestResource) ! {
	manifest.clear_cache()!
}

// Ruby method `verify_download_integrity(_filename)` at line 378.
pub fn ruby_resource_l378_d40_verify_download_integrity(mut manifest BottleManifestResource, filename string) ! {
	manifest.verify_download_integrity(filename)!
}

// Ruby method `downloaded_and_valid?` at line 384.
pub fn ruby_resource_l384_d41_downloaded_and_valid(mut manifest BottleManifestResource) bool {
	return manifest.downloaded_and_valid()
}

// Ruby method `tab` at line 395.
pub fn ruby_resource_l395_d42_tab(mut manifest BottleManifestResource) !map[string]json2.Any {
	return manifest.tab()
}

// Ruby method `bottle_size` at line 407.
pub fn ruby_resource_l407_d43_bottle_size(mut manifest BottleManifestResource) ?i64 {
	return manifest.bottle_size()
}

// Ruby method `installed_size` at line 412.
pub fn ruby_resource_l412_d44_installed_size(mut manifest BottleManifestResource) ?i64 {
	return manifest.installed_size()
}

// Ruby method `path_exec_files` at line 417.
pub fn ruby_resource_l417_d45_path_exec_files(mut manifest BottleManifestResource) ?[]string {
	return manifest.path_exec_files()
}

// Ruby method `sbom_supplement` at line 422.
pub fn ruby_resource_l422_d46_sbom_supplement(mut manifest BottleManifestResource, current_tag string) ?map[string]json2.Any {
	return manifest.sbom_supplement(current_tag)
}

// Ruby method `download_queue_type = "Bottle Manifest"` at line 442.
pub fn ruby_resource_l442_d47_download_queue_type(manifest &BottleManifestResource) string {
	return manifest.resource.download_queue_type()
}

// Ruby method `download_queue_name = "#{bottle.name} (#{bottle.resource.version})"` at line 445.
pub fn ruby_resource_l445_d48_download_queue_name(manifest &BottleManifestResource) string {
	return '${manifest.bottle.name} (${manifest.bottle.version})'
}

// Ruby method `manifest_annotations` at line 450.
pub fn ruby_resource_l450_d49_manifest_annotations(mut manifest BottleManifestResource) !map[string]string {
	return manifest.manifest_annotations()
}

// Ruby attr_reader `attr_reader :patch_files` at line 489.
pub fn ruby_resource_l489_d50_patch_files(patch &PatchResource) []string {
	return patch.patch_files.clone()
}

// Ruby method `initialize(&block)` at line 492.
pub fn ruby_resource_l492_d51_initialize() PatchResource {
	return new_patch_resource()
}

// Ruby method `apply(*paths)` at line 502.
pub fn ruby_resource_l502_d52_apply(mut patch PatchResource, paths []string) {
	patch.apply(paths)
}

// Ruby method `resolves(*cves)` at line 508.
pub fn ruby_resource_l508_d53_resolves(mut patch PatchResource, cves []string) []string {
	return patch.resolves(cves)
}

// Ruby method `type(val = nil)` at line 516.
pub fn ruby_resource_l516_d54_type(mut patch PatchResource, value ?PatchType) ?PatchType {
	return patch.set_type(value)
}

// Ruby method `directory(val = nil)` at line 526.
pub fn ruby_resource_l526_d55_directory(mut patch PatchResource, value ?string) ?string {
	return patch.set_directory(value)
}

// Ruby method `file(val = nil)` at line 533.
pub fn ruby_resource_l533_d56_file(mut patch PatchResource, value ?string) !string {
	return patch.set_file(value)
}

// Ruby method `download_queue_type = "Patch"` at line 545.
pub fn ruby_resource_l545_d57_download_queue_type(patch &PatchResource) string {
	return patch.resource.download_queue_type()
}

// Ruby method `download_queue_name` at line 548.
pub fn ruby_resource_l548_d58_download_queue_name(mut patch PatchResource) !string {
	return patch.download_queue_name()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "downloadable"
// 5: require "formula_creator"
// 6: require "mktemp"
// 7: require "livecheck"
// 8: require "on_system"
// 9: require "utils/output"
// 10:
// 11: # Resource is the fundamental representation of an external resource. The
// 12: # primary formula download, along with other declared resources, are instances
// 13: # of this class.
// 14: class Resource
// 15:   include Downloadable
// 16:   include FileUtils
// 17:   include OnSystem::MacOSAndLinux
// 18:   include Utils::Output::Mixin
// 19:
// 20:   Owner = T.type_alias { T.any(Cask::Cask, ::Formula, Resource, SoftwareSpec, Homebrew::FormulaCreator) }
// 21:
// 22:   sig { returns(T.nilable(Time)) }
// 23:   attr_reader :source_modified_time
// 24:
// 25:   sig { returns(T::Array[T.any(EmbeddedPatch, ExternalPatch)]) }
// 26:   attr_reader :patches
// 27:
// 28:   sig { returns(T.nilable(Owner)) }
// 29:   attr_reader :owner
// 30:
// 31:   sig { params(checksum: T.nilable(Checksum)).returns(T.nilable(Checksum)) }
// 32:   attr_writer :checksum
// 33:
// 34:   sig { override.returns(T::Class[AbstractDownloadStrategy]) }
// 35:   def download_strategy
// 36:     @download_strategy || super
// 37:   end
// 38:
// 39:   sig { params(download_strategy: T.nilable(T::Class[AbstractDownloadStrategy])).void }
// 40:   attr_writer :download_strategy
// 41:
// 42:   # Formula name must be set after the DSL, as we have no access to the
// 43:   # formula name before initialization of the formula.
// 44:   sig { returns(T.nilable(String)) }
// 45:   attr_accessor :name
// 46:
// 47:   sig { params(name: T.nilable(String), block: T.nilable(T.proc.bind(Resource).void)).void }
// 48:   def initialize(name = nil, &block)
// 49:     super()
// 50:     # Generally ensure this is synced with `initialize_dup` and `freeze`
// 51:     # (excluding simple objects like integers & booleans, weak refs like `owner` or permafrozen objects)
// 52:     @name = name
// 53:     @source_modified_time = T.let(nil, T.nilable(Time))
// 54:     @patches = T.let([], T::Array[T.any(EmbeddedPatch, ExternalPatch)])
// 55:     @owner = T.let(nil, T.nilable(Owner))
// 56:     @livecheck = T.let(Livecheck.new(self), Livecheck)
// 57:     @livecheck_defined = T.let(false, T::Boolean)
// 58:     @insecure = T.let(false, T::Boolean)
// 59:     instance_eval(&block) if block
// 60:   end
// 61:
// 62:   sig { override.params(other: T.any(Resource, Downloadable)).void }
// 63:   def initialize_dup(other)
// 64:     super
// 65:     @name = @name.dup
// 66:     @patches = @patches.dup
// 67:     @livecheck = @livecheck.dup
// 68:   end
// 69:
// 70:   sig { override.returns(T.self_type) }
// 71:   def freeze
// 72:     @name.freeze
// 73:     @patches.freeze
// 74:     @livecheck.freeze
// 75:     super
// 76:   end
// 77:
// 78:   sig { params(owner: T.nilable(Owner)).void }
// 79:   def owner=(owner)
// 80:     @owner = T.let(owner, T.nilable(Owner))
// 81:     patches.each { |p| p.owner = owner }
// 82:   end
// 83:
// 84:   sig { override.returns(String) }
// 85:   def download_queue_type = "Resource"
// 86:
// 87:   # Verifies download and unpacks it.
// 88:   # The block may call `|resource, staging| staging.retain!` to retain the staging
// 89:   # directory. Subclasses that override stage should implement the tmp
// 90:   # dir using {Mktemp} so that works with all subtypes.
// 91:   #
// 92:   # @api public
// 93:   sig {
// 94:     params(
// 95:       target:        T.nilable(T.any(String, Pathname)),
// 96:       debug_symbols: T::Boolean,
// 97:       block:         T.nilable(T.proc.params(arg0: ResourceStageContext).void),
// 98:     ).void
// 99:   }
// 100:   def stage(target = nil, debug_symbols: false, &block)
// 101:     raise ArgumentError, "Target directory or block is required" if !target && !block_given?
// 102:
// 103:     prepare_patches
// 104:     fetch_patches(skip_downloaded: true)
// 105:     fetch unless downloaded?
// 106:
// 107:     unpack(target, debug_symbols:, &block)
// 108:   end
// 109:
// 110:   sig { void }
// 111:   def prepare_patches
// 112:     patches.grep(DATAPatch) { |p| p.path = T.cast(T.cast(T.must(owner), SoftwareSpec).owner, ::Formula).path }
// 113:   end
// 114:
// 115:   sig { params(skip_downloaded: T::Boolean).void }
// 116:   def fetch_patches(skip_downloaded: false)
// 117:     external_patches = patches.grep(ExternalPatch)
// 118:     external_patches.reject!(&:downloaded?) if skip_downloaded
// 119:     external_patches.each(&:fetch)
// 120:   end
// 121:
// 122:   sig { void }
// 123:   def apply_patches
// 124:     return if patches.empty?
// 125:
// 126:     ohai "Patching #{name}"
// 127:     patches.each(&:apply)
// 128:   end
// 129:
// 130:   # If a target is given, unpack there; else unpack to a temp folder.
// 131:   # If block is given, yield to that block with `|stage|`, where stage
// 132:   # is a {ResourceStageContext}.
// 133:   # A target or a block must be given, but not both.
// 134:   sig {
// 135:     params(
// 136:       target:        T.nilable(T.any(String, Pathname)),
// 137:       debug_symbols: T::Boolean,
// 138:       block:         T.nilable(T.proc.params(arg0: ResourceStageContext).void),
// 139:     ).void
// 140:   }
// 141:   def unpack(target = nil, debug_symbols: false, &block)
// 142:     current_working_directory = Pathname.pwd
// 143:     stage_resource(download_name, debug_symbols:) do |staging|
// 144:       downloader.stage do
// 145:         @source_modified_time = downloader.source_modified_time.freeze
// 146:         apply_patches
// 147:         if block
// 148:           yield(ResourceStageContext.new(self, staging))
// 149:         elsif target
// 150:           target = Pathname(target)
// 151:           target = current_working_directory/target if target.relative?
// 152:           target.install Pathname.pwd.children
// 153:         end
// 154:       end
// 155:     end
// 156:   end
// 157:
// 158:   Partial = Struct.new(:resource, :files)
// 159:
// 160:   sig { params(files: T.untyped).returns(Partial) }
// 161:   def files(*files)
// 162:     Partial.new(self, files)
// 163:   end
// 164:
// 165:   sig {
// 166:     override
// 167:       .params(
// 168:         verify_download_integrity: T::Boolean,
// 169:         timeout:                   T.nilable(T.any(Integer, Float)),
// 170:         quiet:                     T::Boolean,
// 171:         skip_patches:              T::Boolean,
// 172:       ).returns(Pathname)
// 173:   }
// 174:   def fetch(verify_download_integrity: true, timeout: nil, quiet: false, skip_patches: false)
// 175:     fetch_patches unless skip_patches
// 176:
// 177:     super(verify_download_integrity:, timeout:, quiet:)
// 178:   end
// 179:
// 180:   # {Livecheck} can be used to check for newer versions of the software.
// 181:   # This method evaluates the DSL specified in the `livecheck` block of the
// 182:   # {Resource} (if it exists) and sets the instance variables of a {Livecheck}
// 183:   # object accordingly. This is used by `brew livecheck` to check for newer
// 184:   # versions of the software.
// 185:   #
// 186:   # ### Example
// 187:   #
// 188:   # ```ruby
// 189:   # livecheck do
// 190:   #   url "https://example.com/foo/releases"
// 191:   #   regex /foo-(\d+(?:\.\d+)+)\.tar/
// 192:   # end
// 193:   # ```
// 194:   sig { params(block: T.nilable(T.proc.bind(Livecheck).void)).returns(T.untyped) }
// 195:   def livecheck(&block)
// 196:     return @livecheck unless block
// 197:
// 198:     @livecheck_defined = true
// 199:     @livecheck.instance_eval(&block)
// 200:   end
// 201:
// 202:   # Whether a livecheck specification is defined or not.
// 203:   #
// 204:   # It returns `true` when a `livecheck` block is present in the {Resource}
// 205:   # and `false` otherwise.
// 206:   sig { returns(T::Boolean) }
// 207:   def livecheck_defined?
// 208:     @livecheck_defined == true
// 209:   end
// 210:
// 211:   sig { params(val: String).returns(Checksum) }
// 212:   def sha256(val)
// 213:     @checksum = Checksum.new(val)
// 214:   end
// 215:
// 216:   sig { override.params(val: T.nilable(String), specs: T.anything).returns(T.nilable(String)) }
// 217:   def url(val = nil, **specs)
// 218:     return @url&.to_s if val.nil?
// 219:
// 220:     specs = specs.dup
// 221:     # Don't allow this to be set.
// 222:     specs.delete(:insecure)
// 223:
// 224:     specs[:insecure] = true if @insecure
// 225:
// 226:     @url = URL.new(val, specs)
// 227:     @downloader = nil
// 228:     @download_strategy = @url.download_strategy
// 229:     @url.to_s
// 230:   end
// 231:
// 232:   sig { override.params(val: T.nilable(T.any(String, Version))).returns(T.nilable(Version)) }
// 233:   def version(val = nil)
// 234:     return super() if val.nil?
// 235:
// 236:     @version = case val
// 237:     when String
// 238:       val.blank? ? Version::NULL : Version.new(val)
// 239:     when Version
// 240:       val
// 241:     end
// 242:   end
// 243:
// 244:   sig { params(val: String).returns(T::Array[String]) }
// 245:   def mirror(val)
// 246:     mirrors << val
// 247:   end
// 248:
// 249:   sig {
// 250:     params(
// 251:       strip: T.any(Symbol, String),
// 252:       src:   T.nilable(T.any(Symbol, String)),
// 253:       block: T.nilable(T.proc.bind(Resource::Patch).void),
// 254:     ).returns(T::Array[T.any(EmbeddedPatch, ExternalPatch)])
// 255:   }
// 256:   def patch(strip = :p1, src = nil, &block)
// 257:     p = ::Patch.create(strip, src, &block)
// 258:     patches << p
// 259:   end
// 260:
// 261:   sig { returns(T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol))) }
// 262:   def using
// 263:     @url&.using
// 264:   end
// 265:
// 266:   sig { returns(T::Hash[Symbol, T.untyped]) }
// 267:   def specs
// 268:     @url&.specs || {}.freeze
// 269:   end
// 270:
// 271:   protected
// 272:
// 273:   sig {
// 274:     type_parameters(:U)
// 275:       .params(
// 276:         prefix:        String,
// 277:         debug_symbols: T::Boolean,
// 278:         block:         T.proc.params(arg0: Mktemp).returns(T.type_parameter(:U)),
// 279:       ).returns(T.type_parameter(:U))
// 280:   }
// 281:   def stage_resource(prefix, debug_symbols: false, &block)
// 282:     Mktemp.new(prefix, retain_in_cache: debug_symbols).run(&block)
// 283:   end
// 284:
// 285:   private
// 286:
// 287:   sig { override.returns(String) }
// 288:   def download_name
// 289:     owner_name = owner&.name
// 290:     resource_name = name
// 291:     if resource_name.nil?
// 292:       raise "Resource name and owner name are both nil" if owner_name.nil?
// 293:
// 294:       owner_name
// 295:     else
// 296:       # Removes /s from resource names; this allows Go package names
// 297:       # to be used as resource names without confusing software that
// 298:       # interacts with {download_name}, e.g. `github.com/foo/bar`.
// 299:       escaped_name = resource_name.tr("/", "-")
// 300:       owner_name ? "#{owner_name}--#{escaped_name}" : escaped_name
// 301:     end
// 302:   end
// 303:
// 304:   sig { override.returns(T::Array[String]) }
// 305:   def determine_url_mirrors
// 306:     extra_urls = []
// 307:     url = T.must(self.url)
// 308:
// 309:     # glibc-bootstrap
// 310:     if url.start_with?("https://github.com/Homebrew/glibc-bootstrap/releases/download")
// 311:       if (artifact_domain = Homebrew::EnvConfig.artifact_domain.presence)
// 312:         artifact_url = url.sub("https://github.com", artifact_domain)
// 313:         return [artifact_url] if Homebrew::EnvConfig.artifact_domain_no_fallback?
// 314:
// 315:         extra_urls << artifact_url
// 316:       end
// 317:
// 318:       if Homebrew::EnvConfig.bottle_domain_custom?
// 319:         tag, filename = url.split("/").last(2)
// 320:         extra_urls << "#{Homebrew::EnvConfig.bottle_domain}/glibc-bootstrap/#{tag}/#{filename}"
// 321:       end
// 322:     end
// 323:
// 324:     # PyPI packages: PEP 503 – Simple Repository API <https://peps.python.org/pep-0503>
// 325:     if Homebrew::EnvConfig.non_default_variable?(:HOMEBREW_PIP_INDEX_URL) &&
// 326:        (pip_index_url = Homebrew::EnvConfig.pip_index_url.presence)
// 327:       pip_index_base_url = pip_index_url.chomp("/").chomp("/simple")
// 328:       %w[https://files.pythonhosted.org https://pypi.org].each do |base_url|
// 329:         extra_urls << url.sub(base_url, pip_index_base_url) if url.start_with?("#{base_url}/packages")
// 330:       end
// 331:     end
// 332:
// 333:     [*extra_urls, *super].uniq
// 334:   end
// 335:
// 336:   # A local resource that doesn't need to be downloaded.
// 337:   class Local < Resource
// 338:     sig { params(path: String).void }
// 339:     def initialize(path)
// 340:       super(File.basename(path))
// 341:       @downloader = T.let(LocalBottleDownloadStrategy.new(Pathname(path)), LocalBottleDownloadStrategy)
// 342:     end
// 343:   end
// 344:
// 345:   # A resource for a formula.
// 346:   class Formula < Resource
// 347:     sig { override.returns(String) }
// 348:     def download_queue_type = "Formula"
// 349:
// 350:     sig { override.returns(String) }
// 351:     def download_queue_name = "#{T.must(owner).name} (#{version})"
// 352:   end
// 353:
// 354:   # A resource for a bottle manifest.
// 355:   class BottleManifest < Resource
// 356:     class Error < RuntimeError; end
// 357:
// 358:     sig { returns(Bottle) }
// 359:     attr_reader :bottle
// 360:
// 361:     sig { params(manifest_annotations: T.nilable(T::Hash[String, String])).void }
// 362:     attr_writer :manifest_annotations
// 363:
// 364:     sig { params(bottle: Bottle).void }
// 365:     def initialize(bottle)
// 366:       super("#{bottle.name}_bottle_manifest")
// 367:       @bottle = bottle
// 368:       @manifest_annotations = T.let(nil, T.nilable(T::Hash[String, String]))
// 369:     end
// 370:
// 371:     sig { override.void }
// 372:     def clear_cache
// 373:       super
// 374:       @manifest_annotations = nil
// 375:     end
// 376:
// 377:     sig { override.params(_filename: Pathname).void }
// 378:     def verify_download_integrity(_filename)
// 379:       # We don't have a checksum, but we can at least try parsing it.
// 380:       tab
// 381:     end
// 382:
// 383:     sig { override.returns(T::Boolean) }
// 384:     def downloaded_and_valid?
// 385:       return false unless downloaded?
// 386:
// 387:       with_context(quiet: true) { verify_download_integrity(cached_download) }
// 388:       true
// 389:     rescue Error
// 390:       clear_cache
// 391:       false
// 392:     end
// 393:
// 394:     sig { returns(T::Hash[String, T.untyped]) }
// 395:     def tab
// 396:       tab = manifest_annotations["sh.brew.tab"]
// 397:       raise Error, "Couldn't find tab from manifest." if tab.blank?
// 398:
// 399:       begin
// 400:         JSON.parse(tab)
// 401:       rescue JSON::ParserError
// 402:         raise Error, "Couldn't parse tab JSON."
// 403:       end
// 404:     end
// 405:
// 406:     sig { returns(T.nilable(Integer)) }
// 407:     def bottle_size
// 408:       manifest_annotations["sh.brew.bottle.size"]&.to_i
// 409:     end
// 410:
// 411:     sig { returns(T.nilable(Integer)) }
// 412:     def installed_size
// 413:       manifest_annotations["sh.brew.bottle.installed_size"]&.to_i
// 414:     end
// 415:
// 416:     sig { returns(T.nilable(T::Array[String])) }
// 417:     def path_exec_files
// 418:       manifest_annotations["sh.brew.path_exec_files"]&.split(",")
// 419:     end
// 420:
// 421:     sig { returns(T.nilable(T::Hash[String, Object])) }
// 422:     def sbom_supplement
// 423:       supplement = manifest_annotations["sh.brew.sbom.supplement"]
// 424:       return if supplement.blank?
// 425:
// 426:       parsed_supplement = JSON.parse(supplement)
// 427:       return unless parsed_supplement.is_a?(Hash)
// 428:
// 429:       if (tags = parsed_supplement["tags"]).is_a?(Hash)
// 430:         tag_supplement = tags[Utils::Bottles.tag.to_s]
// 431:         return tag_supplement if tag_supplement.is_a?(Hash)
// 432:
// 433:         return
// 434:       end
// 435:
// 436:       parsed_supplement
// 437:     rescue JSON::ParserError
// 438:       nil
// 439:     end
// 440:
// 441:     sig { override.returns(String) }
// 442:     def download_queue_type = "Bottle Manifest"
// 443:
// 444:     sig { override.returns(String) }
// 445:     def download_queue_name = "#{bottle.name} (#{bottle.resource.version})"
// 446:
// 447:     private
// 448:
// 449:     sig { returns(T::Hash[String, String]) }
// 450:     def manifest_annotations
// 451:       cached = @manifest_annotations
// 452:       return cached unless cached.nil?
// 453:
// 454:       json = begin
// 455:         JSON.parse(cached_download.read)
// 456:       rescue JSON::ParserError
// 457:         raise Error, "The downloaded GitHub Packages manifest was corrupted or modified (it is not valid JSON): " \
// 458:                      "\n#{cached_download}"
// 459:       end
// 460:
// 461:       manifests = json["manifests"]
// 462:       raise Error, "Missing 'manifests' section." if manifests.blank?
// 463:
// 464:       manifests_annotations = manifests.filter_map { |m| m["annotations"] }
// 465:       raise Error, "Missing 'annotations' section." if manifests_annotations.blank?
// 466:
// 467:       checksum = bottle.resource.checksum
// 468:       raise "Checksum is nil" if checksum.nil?
// 469:
// 470:       bottle_digest = checksum.hexdigest
// 471:       version = bottle.resource.version
// 472:       raise "Version is nil" if version.nil?
// 473:
// 474:       image_ref = GitHubPackages.version_rebuild(version, bottle.rebuild, bottle.tag.to_s)
// 475:       manifests_annotation = manifests_annotations.find do |m|
// 476:         next if m["sh.brew.bottle.digest"] != bottle_digest
// 477:
// 478:         m["org.opencontainers.image.ref.name"] == image_ref
// 479:       end
// 480:       raise Error, "Couldn't find manifest matching bottle checksum." if manifests_annotation.blank?
// 481:
// 482:       @manifest_annotations = manifests_annotation.to_h { |key, value| [key.to_s, value.to_s] }
// 483:     end
// 484:   end
// 485:
// 486:   # A resource containing a patch.
// 487:   class Patch < Resource
// 488:     sig { returns(T::Array[T.any(String, Pathname)]) }
// 489:     attr_reader :patch_files
// 490:
// 491:     sig { params(block: T.nilable(T.proc.bind(Resource::Patch).void)).void }
// 492:     def initialize(&block)
// 493:       @patch_files = T.let([], T::Array[T.any(String, Pathname)])
// 494:       @directory = T.let(nil, T.nilable(T.any(String, Pathname)))
// 495:       @file = T.let(nil, T.nilable(T.any(String, Pathname)))
// 496:       @resolves = T.let([], T::Array[String])
// 497:       @type = T.let(nil, T.nilable(Symbol))
// 498:       super "patch", &block
// 499:     end
// 500:
// 501:     sig { params(paths: T.any(String, Pathname, T::Array[T.any(String, Pathname)])).void }
// 502:     def apply(*paths)
// 503:       @patch_files.concat(paths.flatten)
// 504:       @patch_files.uniq!
// 505:     end
// 506:
// 507:     sig { params(cves: String).returns(T::Array[String]) }
// 508:     def resolves(*cves)
// 509:       return @resolves if cves.empty?
// 510:
// 511:       @resolves.concat(cves).uniq!
// 512:       @resolves
// 513:     end
// 514:
// 515:     sig { params(val: T.nilable(Symbol)).returns(T.nilable(Symbol)) }
// 516:     def type(val = nil)
// 517:       return @type if val.nil?
// 518:       unless ::Patch::TYPES.key?(val)
// 519:         raise ArgumentError, "Patch type must be one of: #{::Patch::TYPES.keys.map(&:inspect).join(", ")}"
// 520:       end
// 521:
// 522:       @type = val
// 523:     end
// 524:
// 525:     sig { params(val: T.nilable(T.any(String, Pathname))).returns(T.nilable(T.any(String, Pathname))) }
// 526:     def directory(val = nil)
// 527:       return @directory if val.nil?
// 528:
// 529:       @directory = val
// 530:     end
// 531:
// 532:     sig { params(val: T.nilable(T.any(String, Pathname))).returns(T.nilable(T.any(String, Pathname))) }
// 533:     def file(val = nil)
// 534:       return @file if val.nil?
// 535:
// 536:       path_string = val.to_s
// 537:       unless LocalPatch.valid_path?(path_string)
// 538:         raise ArgumentError, "Patch file must be a relative path within the repository."
// 539:       end
// 540:
// 541:       @file = val
// 542:     end
// 543:
// 544:     sig { override.returns(String) }
// 545:     def download_queue_type = "Patch"
// 546:
// 547:     sig { override.returns(String) }
// 548:     def download_queue_name
// 549:       if (last_url_component = url.to_s.split("/").last)
// 550:         return last_url_component
// 551:       end
// 552:
// 553:       super
// 554:     end
// 555:   end
// 556: end
// 557: require "resource/resource_stage_context"
