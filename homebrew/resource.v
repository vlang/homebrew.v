module homebrew

import ruby
import crypto.sha256
import homebrew.download_strategy
import homebrew.unpack_strategy
import json2

// Translated from Homebrew/brew `resource.rb`.
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
			''
		} == expected_ref {
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
