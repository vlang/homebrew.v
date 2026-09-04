module homebrew

import compress.gzip
import crypto.sha256
import ruby
import os
import x.json2

pub const github_packages_url_domain = 'ghcr.io'
pub const github_packages_url_prefix = 'https://${github_packages_url_domain}/v2/'
pub const github_packages_docker_prefix = 'docker://${github_packages_url_domain}/'
pub const github_packages_image_config_schema_uri = 'https://opencontainers.org/schema/image/config'
pub const github_packages_image_index_schema_uri = 'https://opencontainers.org/schema/image/index'
pub const github_packages_image_layout_schema_uri = 'https://opencontainers.org/schema/image/layout'
pub const github_packages_image_manifest_schema_uri = 'https://opencontainers.org/schema/image/manifest'

const github_packages_schema_revision = '170393e57ed656f7f81c3070bfa8c3346eaa0a5a'

pub struct GitHubPackagesWriteResult {
pub:
	sha256 string
	size   int
	path   string
}

pub struct GitHubPackagesCommandPlan {
pub:
	program string
	args    []string
	display string
}

pub struct GitHubPackagesInspectResult {
pub:
	success bool
	stderr  string
}

pub struct GitHubPackagesPreuploadOptions {
pub:
	keep_old       bool
	dry_run        bool
	warn_on_error  bool
	inspect_result GitHubPackagesInspectResult
}

pub struct GitHubPackagesPreuploadResult {
pub:
	formula_name    string
	org             string
	repo            string
	version         string
	rebuild         int
	version_rebuild string
	image_name      string
	image_uri       string
	keep_old        bool
	skipped         bool
	warning         string
	inspect_command GitHubPackagesCommandPlan
}

pub struct GitHubPackagesUploadOptions {
pub:
	user           string
	token          string
	skopeo         string = 'skopeo'
	root_parent    string = '.'
	keep_old       bool
	dry_run        bool = true
	warn_on_error  bool
	inspect_result GitHubPackagesInspectResult
}

pub struct GitHubPackagesUploadResult {
pub:
	root              string
	version_rebuild   string
	image_uri         string
	manifest_count    int
	index_json_sha256 string
	index_json_size   int
	skipped           bool
	warning           string
	command           GitHubPackagesCommandPlan
}

pub struct GitHubPackagesUploadProgress {
pub:
	events         []string
	uploaded_count int
	bottle_count   int
}

fn github_packages_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn github_packages_error(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

fn github_packages_map(value ruby.Value, context string) !map[string]ruby.Value {
	if value.type_name != 'Hash' {
		return error('${context} must be a Hash')
	}
	return value.as_map()
}

fn github_packages_field(values map[string]ruby.Value, key string) ruby.Value {
	return values[key] or { github_packages_nil() }
}

fn github_packages_string(values map[string]ruby.Value, key string) string {
	value := github_packages_field(values, key)
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn github_packages_integer(values map[string]ruby.Value, key string) int {
	value := github_packages_field(values, key)
	return if value.type_name == 'Integer' {
		int(value.as_int() or { 0 })
	} else {
		value.as_string().int()
	}
}

fn github_packages_json_string(value string) string {
	return json2.encode(json2.Any(value))
}

fn github_packages_pretty_json_at(value ruby.Value, depth int) string {
	indent := '  '.repeat(depth)
	next_indent := '  '.repeat(depth + 1)
	return match value.type_name {
		'NilClass' { 'null' }
		'Bool' { value.bool_data.str() }
		'Integer' { value.int_data.str() }
		'Float' { value.float_data.str() }
		'Array' {
			entries := value.as_array() or { []ruby.Value{} }
			if entries.len == 0 {
				'[]'
			} else {
				parts := entries.map('${next_indent}${github_packages_pretty_json_at(it, depth + 1)}')
				'[\n${parts.join(',\n')}\n${indent}]'
			}
		}
		'Hash' {
			if value.map_data.len == 0 {
				'{}'
			} else {
				mut parts := []string{cap: value.map_data.len}
				for key, entry in value.map_data {
					parts << '${next_indent}${github_packages_json_string(key)}: ${github_packages_pretty_json_at(entry, depth + 1)}'
				}
				'{\n${parts.join(',\n')}\n${indent}}'
			}
		}
		else { github_packages_json_string(value.as_string()) }
	}
}

pub fn github_packages_pretty_json(value ruby.Value) string {
	return github_packages_pretty_json_at(value, 0)
}

pub fn github_packages_version_rebuild(version string, rebuild int, bottle_tag ?string) string {
	tag := bottle_tag or { '' }
	tag_part := if tag == '' { '' } else { '.${tag}' }
	rebuild_part := if rebuild > 0 {
		if tag_part == '' { '-${rebuild}' } else { '.${rebuild}' }
	} else {
		''
	}
	return '${version}${tag_part}${rebuild_part}'
}

pub fn github_packages_repo_without_prefix(repo string) string {
	return if repo.starts_with('homebrew-') { repo['homebrew-'.len..] } else { repo }
}

pub fn github_packages_root_url(org string, repo string, prefix string) string {
	return '${prefix}${org.to_lower()}/${github_packages_repo_without_prefix(repo)}'
}

fn github_packages_url_token(input string) string {
	mut end := 0
	for end < input.len {
		character := input[end]
		if !(character.is_alnum() || character == `_` || character == `-`) {
			break
		}
		end++
	}
	return input[..end]
}

pub fn github_packages_root_url_match(url string) ?string {
	mut offset := url.index(github_packages_url_prefix) or { -1 }
	mut prefix := github_packages_url_prefix
	if offset < 0 {
		offset = url.index(github_packages_docker_prefix) or { return none }
		prefix = github_packages_docker_prefix
	}
	remainder := url[offset + prefix.len..]
	slash := remainder.index('/') or { return none }
	org := github_packages_url_token(remainder[..slash])
	repo := github_packages_url_token(remainder[slash + 1..])
	if org == '' || repo == '' {
		return none
	}
	return github_packages_root_url(org, repo, github_packages_url_prefix)
}

pub fn github_packages_image_formula_name(formula_name string) string {
	return formula_name.replace('@', '/').replace('+', 'x')
}

pub fn github_packages_image_version_rebuild(version_rebuild string) !string {
	if version_rebuild.len == 0 || version_rebuild.len > 128 {
		return error('GitHub Packages versions must match ^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}\$!')
	}
	for index, character in version_rebuild.bytes() {
		valid := character.is_alnum() || character == `_` || (index > 0
			&& character in [u8(`.`), `-`])
		if !valid {
			return error('GitHub Packages versions must match ^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}\$!')
		}
	}
	return version_rebuild
}

pub fn github_packages_upload_progress(formulae []string, skipped map[string]bool) GitHubPackagesUploadProgress {
	mut events := []string{}
	for index, formula in formulae {
		if !(skipped[formula] or { false }) {
			events << 'Uploaded ${formula}'
		}
		if formulae.len >= 3 {
			uploaded := index + 1
			events << 'Upload progress: ${uploaded} formula(e) uploaded, ${formulae.len - uploaded} remaining'
		}
	}
	return GitHubPackagesUploadProgress{
		events: events
		uploaded_count: formulae.len
		bottle_count: formulae.len
	}
}

fn github_packages_append_arg(args []string, argument string) []string {
	mut result := args.clone()
	result << argument
	return result
}

pub fn github_packages_preupload_check(bottle_hash ruby.Value, skopeo string, user string,
	token string, options GitHubPackagesPreuploadOptions) !GitHubPackagesPreuploadResult {
	formula := github_packages_map(github_packages_field(github_packages_map(bottle_hash, 'bottle JSON')!, 'formula'), "bottle JSON 'formula'")!
	bottle := github_packages_map(github_packages_field(github_packages_map(bottle_hash, 'bottle JSON')!, 'bottle'), "bottle JSON 'bottle'")!
	formula_name := github_packages_string(formula, 'name')
	root_url := github_packages_string(bottle, 'root_url')
	canonical_root := github_packages_root_url_match(root_url) or {
		return error('invalid GitHub Packages root URL: ${root_url}')
	}
	remainder := canonical_root.all_after(github_packages_url_prefix)
	parts := remainder.split('/')
	if formula_name == '' || parts.len < 2 {
		return error('bottle JSON is missing formula name or repository')
	}
	org := parts[0]
	mut repo := parts[1]
	if !repo.starts_with('homebrew-') {
		repo = 'homebrew-${repo}'
	}
	version := github_packages_string(formula, 'pkg_version')
	rebuild := github_packages_integer(bottle, 'rebuild')
	version_rebuild := github_packages_version_rebuild(version, rebuild, none)
	image_name := github_packages_image_formula_name(formula_name)
	image_tag := github_packages_image_version_rebuild(version_rebuild)!
	image_uri := '${github_packages_root_url(org, repo, github_packages_docker_prefix)}/${image_name}:${image_tag}'
	inspect_args := ['inspect', '--raw', image_uri]
	inspect_command := GitHubPackagesCommandPlan{
		program: skopeo
		args: if options.dry_run {
			inspect_args
		} else {
			github_packages_append_arg(inspect_args, '--creds=${user}:${token}')
		}
		display: '${skopeo} ${inspect_args.join(' ')} --creds=${user}:\$HOMEBREW_GITHUB_PACKAGES_TOKEN'
	}
	mut keep_old := options.keep_old
	mut skipped := false
	mut warning := ''
	if !options.dry_run {
		unknown := options.inspect_result.stderr.contains('name unknown')
			|| options.inspect_result.stderr.contains('manifest unknown')
		if !options.inspect_result.success && !unknown {
			message := '${image_uri} inspection returned an error!\n${options.inspect_result.stderr}'
			if options.warn_on_error {
				skipped = true
				warning = message.replace('an error!', 'an error, skipping upload!')
			} else {
				return error(message)
			}
		} else if keep_old {
			keep_old = options.inspect_result.success
		} else if options.inspect_result.success {
			if options.warn_on_error {
				skipped = true
				warning = '${image_uri} already exists, skipping upload!'
			} else {
				return error('${image_uri} already exists!')
			}
		}
	}
	return GitHubPackagesPreuploadResult{
		formula_name: formula_name
		org: org
		repo: repo
		version: version
		rebuild: rebuild
		version_rebuild: version_rebuild
		image_name: image_name
		image_uri: image_uri
		keep_old: keep_old
		skipped: skipped
		warning: warning
		inspect_command: inspect_command
	}
}

pub fn github_packages_download_command(user string, token string, skopeo string, image_uri string,
	root string, dry_run bool) GitHubPackagesCommandPlan {
	base := ['copy', '--all', image_uri, 'oci:${root}']
	return GitHubPackagesCommandPlan{
		program: skopeo
		args: if dry_run {
			base
		} else {
			github_packages_append_arg(base, '--src-creds=${user}:${token}')
		}
		display: '${skopeo} ${base.join(' ')} --src-creds=${user}:\$HOMEBREW_GITHUB_PACKAGES_TOKEN'
	}
}

fn github_packages_validate_descriptor(descriptor ruby.Value) ! {
	values := github_packages_map(descriptor, 'OCI descriptor')!
	for key in ['mediaType', 'digest', 'size'] {
		if key !in values {
			return error("OCI descriptor is missing '${key}'")
		}
	}
	if !github_packages_string(values, 'digest').starts_with('sha256:') {
		return error('OCI descriptor digest must use sha256')
	}
}

pub fn github_packages_validate_schema(schema_uri string, document ruby.Value) ! {
	values := github_packages_map(document, 'OCI JSON')!
	match schema_uri {
		github_packages_image_layout_schema_uri {
			if github_packages_string(values, 'imageLayoutVersion') != '1.0.0' {
				return error("OCI image layout requires imageLayoutVersion '1.0.0'")
			}
		}
		github_packages_image_config_schema_uri {
			rootfs := github_packages_map(github_packages_field(values, 'rootfs'), "OCI config 'rootfs'")!
			if github_packages_string(rootfs, 'type') != 'layers' {
				return error("OCI image config rootfs type must be 'layers'")
			}
			diff_ids := github_packages_field(rootfs, 'diff_ids').as_array() or {
				return error("OCI image config rootfs requires 'diff_ids'")
			}
			if diff_ids.len == 0 || diff_ids.any(!it.as_string().starts_with('sha256:')) {
				return error('OCI image config diff IDs must use sha256')
			}
		}
		github_packages_image_manifest_schema_uri {
			if github_packages_integer(values, 'schemaVersion') != 2 {
				return error('OCI image manifest requires schemaVersion 2')
			}
			github_packages_validate_descriptor(github_packages_field(values, 'config'))!
			layers := github_packages_field(values, 'layers').as_array() or {
				return error("OCI image manifest requires 'layers'")
			}
			for layer in layers {
				github_packages_validate_descriptor(layer)!
			}
		}
		github_packages_image_index_schema_uri {
			if github_packages_integer(values, 'schemaVersion') != 2 {
				return error('OCI image index requires schemaVersion 2')
			}
			manifests := github_packages_field(values, 'manifests').as_array() or {
				return error("OCI image index requires 'manifests'")
			}
			for manifest in manifests {
				github_packages_validate_descriptor(manifest)!
			}
		}
		else {
			return error('unknown OCI schema URI: ${schema_uri}')
		}
	}
}

pub fn github_packages_write_hash(directory string, value ruby.Value, filename string) !GitHubPackagesWriteResult {
	json := github_packages_pretty_json(value)
	digest := sha256.sum256(json.bytes()).hex()
	name := if filename == '' { digest } else { filename }
	os.mkdir_all(directory)!
	path := os.join_path(directory, name)
	if os.exists(path) {
		os.rm(path)!
	}
	os.write_file(path, json)!
	return GitHubPackagesWriteResult{
		sha256: digest
		size: json.len
		path: path
	}
}

pub fn github_packages_write_image_layout(root string) !GitHubPackagesWriteResult {
	value := ruby.map_value({
		'imageLayoutVersion': ruby.string_value('1.0.0')
	})
	github_packages_validate_schema(github_packages_image_layout_schema_uri, value)!
	return github_packages_write_hash(root, value, 'oci-layout')
}

pub fn github_packages_write_tar_gz(local_file string, blobs string) !string {
	contents := os.read_bytes(local_file)!
	digest := sha256.sum256(contents).hex()
	os.mkdir_all(blobs)!
	destination := os.join_path(blobs, digest)
	if os.exists(destination) {
		os.rm(destination)!
	}
	os.link(local_file, destination) or {
		os.cp(local_file, destination, os.CopyParams{})!
	}
	return digest
}

pub fn github_packages_write_image_config(platform map[string]ruby.Value, tar_sha256 string,
	blobs string) !GitHubPackagesWriteResult {
	mut image_config := platform.clone()
	image_config['rootfs'] = ruby.map_value({
		'type':     ruby.string_value('layers')
		'diff_ids': ruby.string_array_value(['sha256:${tar_sha256}'])
	})
	value := ruby.map_value(image_config)
	github_packages_validate_schema(github_packages_image_config_schema_uri, value)!
	return github_packages_write_hash(blobs, value, '')
}

pub fn github_packages_write_image_index(manifests []ruby.Value, blobs string,
	annotations map[string]ruby.Value) !GitHubPackagesWriteResult {
	value := ruby.map_value({
		'schemaVersion': ruby.int_value(2)
		'manifests':     ruby.array_value(manifests)
		'annotations':   ruby.map_value(annotations)
	})
	github_packages_validate_schema(github_packages_image_index_schema_uri, value)!
	return github_packages_write_hash(blobs, value, '')
}

pub fn github_packages_write_index_json(index_sha256 string, index_size int, root string,
	annotations map[string]ruby.Value) !GitHubPackagesWriteResult {
	descriptor := ruby.map_value({
		'mediaType':   ruby.string_value('application/vnd.oci.image.index.v1+json')
		'digest':      ruby.string_value('sha256:${index_sha256}')
		'size':        ruby.int_value(index_size)
		'annotations': ruby.map_value(annotations)
	})
	value := ruby.map_value({
		'schemaVersion': ruby.int_value(2)
		'manifests':     ruby.array_value([descriptor])
	})
	github_packages_validate_schema(github_packages_image_index_schema_uri, value)!
	return github_packages_write_hash(root, value, 'index.json')
}

fn github_packages_compact_strings(values map[string]string) map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		if value != '' {
			result[key] = ruby.string_value(value)
		}
	}
	return result
}

fn github_packages_tab_platform(tag string, tab map[string]ruby.Value) !(map[string]ruby.Value, string, string) {
	arch_value := github_packages_string(tab, 'arch')
	default_arch := if tag.starts_with('arm64_') || tag == 'all' { 'arm64' } else { 'x86_64' }
	architecture := match if arch_value == '' { default_arch } else { arch_value } {
		'arm64' { 'arm64' }
		'x86_64' { 'amd64' }
		else {
			return error("unknown tab['arch']: ${arch_value}")
		}
	}
	built_on_value := github_packages_field(tab, 'built_on')
	built_on := if built_on_value.type_name == 'Hash' {
		built_on_value.map_data
	} else {
		map[string]ruby.Value{}
	}
	os_name := github_packages_string(built_on, 'os')
	platform_os := match os_name {
		'Linux' { 'linux' }
		'Macintosh' { 'darwin' }
		'' {
			if tag.contains('linux') { 'linux' } else { 'darwin' }
		}
		else {
			return error("unknown tab['built_on']['os']: ${os_name}")
		}
	}
	mut os_version := github_packages_string(built_on, 'os_version')
	mut glibc_version := ''
	mut cpu_variant := ''
	if platform_os == 'linux' {
		os_version = os_version.trim_string_right(' LTS')
		if os_version == '' {
			os_version = 'Ubuntu 22.04'
		}
		glibc_version = github_packages_string(built_on, 'glibc_version')
		if glibc_version == '' {
			glibc_version = '2.35'
		}
		cpu_variant = github_packages_string(built_on, 'oldest_cpu_family')
		if cpu_variant == '' {
			cpu_variant = 'core2'
		}
	} else if os_version == '' {
		os_version = 'macOS ${tag.all_after_last('_')}'
	}
	return github_packages_compact_strings({
		'architecture': architecture
		'os':           platform_os
		'os.version':   os_version
	}), glibc_version, cpu_variant
}

fn github_packages_tab_annotation(tab map[string]ruby.Value, all_bottle bool) string {
	mut selected := tab.clone()
	if all_bottle {
		selected.delete('arch')
		selected.delete('built_on')
	}
	return ruby.json_value_to_string(ruby.map_value(selected))
}

fn github_packages_sbom_annotation(supplement ruby.Value, formula_full_name string,
	formula_name string, version string, tar_digest string, root_url string, license string,
	created string) string {
	if supplement.type_name != 'Hash' {
		return ''
	}
	mut values := supplement.map_data.clone()
	mut packages := if package_value := values['packages'] {
		package_value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	mut describes := if describes_value := values['documentDescribes'] {
		(describes_value.as_array() or { []ruby.Value{} }).map(it.as_string())
	} else {
		[]string{}
	}
	namespace := if formula_full_name.contains('/') {
		formula_full_name.all_before_last('/')
	} else {
		''
	}
	purl_name := formula_full_name.all_after_last('/')
	purl := if namespace == '' {
		'pkg:brew/${purl_name}@${version}'
	} else {
		'pkg:brew/${namespace}/${purl_name}@${version}'
	}
	bottle_id := 'SPDXRef-Bottle-${formula_name}'
	bottle_package := ruby.map_value({
		'SPDXID':           ruby.string_value(bottle_id)
		'name':             ruby.string_value(formula_name)
		'versionInfo':      ruby.string_value(version)
		'filesAnalyzed':    ruby.bool_value(false)
		'licenseDeclared':  ruby.string_value('NOASSERTION')
		'builtDate':        ruby.string_value(created)
		'licenseConcluded': ruby.string_value(if license == '' {
			'NOASSERTION'
		} else {
			license
		})
		'downloadLocation': ruby.string_value('${root_url.trim_string_right('/')}/${github_packages_image_formula_name(formula_name)}/blobs/sha256:${tar_digest}')
		'copyrightText':    ruby.string_value('NOASSERTION')
		'externalRefs':     ruby.array_value([
			ruby.map_value({
				'referenceCategory': ruby.string_value('PACKAGE-MANAGER')
				'referenceLocator':  ruby.string_value(purl)
				'referenceType':     ruby.string_value('purl')
			}),
		])
		'checksums':        ruby.array_value([
			ruby.map_value({
				'algorithm':     ruby.string_value('SHA256')
				'checksumValue': ruby.string_value(tar_digest)
			}),
		])
	})
	packages << bottle_package
	describes << bottle_id
	values['packages'] = ruby.array_value(packages)
	values['documentDescribes'] = ruby.string_array_value(describes)
	if 'relationships' !in values {
		values['relationships'] = ruby.array_value([])
	}
	return ruby.json_value_to_string(ruby.map_value(values))
}

pub fn github_packages_upload_bottle(bottle_hash ruby.Value, formula_full_name string,
	options GitHubPackagesUploadOptions) !GitHubPackagesUploadResult {
	preflight := github_packages_preupload_check(bottle_hash, options.skopeo, options.user, options.token, GitHubPackagesPreuploadOptions{
		keep_old: options.keep_old
		dry_run: options.dry_run
		warn_on_error: options.warn_on_error
		inspect_result: options.inspect_result
	})!
	if preflight.skipped {
		return GitHubPackagesUploadResult{ skipped: true, warning: preflight.warning }
	}
	if preflight.keep_old {
		return error('an existing OCI layout is required to use --keep-old in offline mode')
	}
	root := os.join_path(options.root_parent, '${preflight.formula_name}--${preflight.version_rebuild}')
	if os.exists(root) {
		os.rmdir_all(root)!
	}
	os.mkdir_all(root)!
	github_packages_write_image_layout(root)!
	blobs := os.join_path(root, 'blobs', 'sha256')
	os.mkdir_all(blobs)!
	root_values := github_packages_map(bottle_hash, 'bottle JSON')!
	formula := github_packages_map(github_packages_field(root_values, 'formula'), "bottle JSON 'formula'")!
	bottle := github_packages_map(github_packages_field(root_values, 'bottle'), "bottle JSON 'bottle'")!
	git_path := github_packages_string(formula, 'tap_git_path')
	git_revision := github_packages_string(formula, 'tap_git_revision')
	revision_path := if git_revision == '' { 'HEAD' } else { git_revision }
	source := 'https://github.com/${preflight.org}/${preflight.repo}/blob/${revision_path}/${git_path}'
	core_formula := !formula_full_name.contains('/')
	mut documentation := if core_formula {
		'https://formulae.brew.sh/formula/${preflight.formula_name}'
	} else {
		remote := github_packages_string(formula, 'tap_git_remote')
		if remote.starts_with('https://github.com/') { remote } else { '' }
	}
	license := github_packages_string(formula, 'license')
	created := github_packages_string(bottle, 'date')
	mut formula_annotations := github_packages_compact_strings({
		'com.github.package.type':                'homebrew_bottle'
		'org.opencontainers.image.created':       created
		'org.opencontainers.image.description':   github_packages_string(formula, 'desc')
		'org.opencontainers.image.documentation': documentation
		'org.opencontainers.image.licenses':      license
		'org.opencontainers.image.ref.name':      preflight.version_rebuild
		'org.opencontainers.image.revision':      git_revision
		'org.opencontainers.image.source':        source
		'org.opencontainers.image.title':         formula_full_name
		'org.opencontainers.image.url':           github_packages_string(formula, 'homepage')
		'org.opencontainers.image.vendor':        preflight.org
		'org.opencontainers.image.version':       preflight.version
	})
	tags := github_packages_map(github_packages_field(bottle, 'tags'), "bottle JSON 'tags'")!
	mut manifests := []ruby.Value{cap: tags.len}
	mut processed := map[string]bool{}
	for bottle_tag, tag_value in tags {
		tag_hash := github_packages_map(tag_value, "bottle tag '${bottle_tag}'")!
		tag := github_packages_version_rebuild(preflight.version, preflight.rebuild, bottle_tag)
		if processed[tag] or { false } {
			return error('A bottle JSON for ${bottle_tag} is present, but it is already in the image index!')
		}
		processed[tag] = true
		local_file := github_packages_string(tag_hash, 'local_filename')
		if !os.is_file(local_file) {
			return error('bottle file does not exist: ${local_file}')
		}
		tar_gz_digest := github_packages_write_tar_gz(local_file, blobs)!
		tab := github_packages_map(github_packages_field(tag_hash, 'tab'), "bottle tag '${bottle_tag}' tab")!
		platform, glibc_version, cpu_variant := github_packages_tab_platform(bottle_tag, tab)!
		uncompressed := gzip.decompress(os.read_bytes(local_file)!)!
		tar_digest := sha256.sum256(uncompressed).hex()
		config := github_packages_write_image_config(platform, tar_digest, blobs)!
		if core_formula {
			documentation = 'https://formulae.brew.sh/formula/${preflight.formula_name}'
		}
		file_size := os.file_size(local_file)
		paths_value := github_packages_field(tag_hash, 'path_exec_files')
		path_exec_files := if paths_value.type_name == 'Array' {
			(paths_value.as_array() or { [] }).map(it.as_string()).join(',')
		} else {
			''
		}
		sbom := github_packages_sbom_annotation(github_packages_field(tag_hash, 'sbom'), formula_full_name, preflight.formula_name, preflight.version, tar_gz_digest, github_packages_string(bottle, 'root_url'), license, created)
		all_bottle := bottle_tag == 'all'
		descriptor_annotations := github_packages_compact_strings({
			'org.opencontainers.image.ref.name': tag
			'sh.brew.bottle.cpu.variant':        cpu_variant
			'sh.brew.bottle.digest':             tar_gz_digest
			'sh.brew.bottle.glibc.version':      glibc_version
			'sh.brew.bottle.size':               file_size.str()
			'sh.brew.bottle.installed_size':     github_packages_integer(tag_hash, 'installed_size').str()
			'sh.brew.license':                   license
			'sh.brew.tab':                       github_packages_tab_annotation(tab, all_bottle)
			'sh.brew.sbom.supplement':           sbom
			'sh.brew.path_exec_files':           path_exec_files
		})
		mut annotations := formula_annotations.clone()
		for key, value in descriptor_annotations {
			annotations[key] = value
		}
		annotations['org.opencontainers.image.created'] = ruby.string_value(created)
		if documentation != '' {
			annotations['org.opencontainers.image.documentation'] = ruby.string_value(documentation)
		}
		annotations['org.opencontainers.image.title'] = ruby.string_value('${formula_full_name} ${tag}')
		image_manifest := ruby.map_value({
			'schemaVersion': ruby.int_value(2)
			'config':        ruby.map_value({
				'mediaType': ruby.string_value('application/vnd.oci.image.config.v1+json')
				'digest':    ruby.string_value('sha256:${config.sha256}')
				'size':      ruby.int_value(config.size)
			})
			'layers':        ruby.array_value([
				ruby.map_value({
					'mediaType':   ruby.string_value('application/vnd.oci.image.layer.v1.tar+gzip')
					'digest':      ruby.string_value('sha256:${tar_gz_digest}')
					'size':        ruby.int_value(file_size)
					'annotations': ruby.map_value({
						'org.opencontainers.image.title': ruby.string_value(local_file)
					})
				}),
			])
			'annotations':   ruby.map_value(annotations)
		})
		github_packages_validate_schema(github_packages_image_manifest_schema_uri, image_manifest)!
		written_manifest := github_packages_write_hash(blobs, image_manifest, '')!
		mut descriptor := map[string]ruby.Value{}
		descriptor['mediaType'] = ruby.string_value('application/vnd.oci.image.manifest.v1+json')
		descriptor['digest'] = ruby.string_value('sha256:${written_manifest.sha256}')
		descriptor['size'] = ruby.int_value(written_manifest.size)
		descriptor['annotations'] = ruby.map_value(descriptor_annotations)
		if !all_bottle {
			descriptor['platform'] = ruby.map_value(platform)
		}
		manifests << ruby.map_value(descriptor)
	}
	index := github_packages_write_image_index(manifests, blobs, formula_annotations)!
	if index.size >= 4 * 1024 * 1024 {
		return error('Image index too large!')
	}
	github_packages_write_index_json(index.sha256, index.size, root, {
		'org.opencontainers.image.ref.name': ruby.string_value(preflight.version_rebuild)
	})!
	copy_args := ['copy', '--retry-times=3', '--format=oci', '--all', 'oci:${root}',
		preflight.image_uri]
	command := GitHubPackagesCommandPlan{
		program: options.skopeo
		args: if options.dry_run {
			copy_args
		} else {
			github_packages_append_arg(copy_args, '--dest-creds=${options.user}:${options.token}')
		}
		display: '${options.skopeo} ${copy_args.join(' ')} --dest-creds=${options.user}:\$HOMEBREW_GITHUB_PACKAGES_TOKEN'
	}
	return GitHubPackagesUploadResult{
		root: root
		version_rebuild: preflight.version_rebuild
		image_uri: preflight.image_uri
		manifest_count: manifests.len
		index_json_sha256: index.sha256
		index_json_size: index.size
		command: command
	}
}

pub fn github_packages_schema_sources() map[string]string {
	base := 'https://raw.githubusercontent.com/opencontainers/image-spec/${github_packages_schema_revision}/schema'
	mut result := map[string]string{}
	result['https://opencontainers.org/schema/image/content-descriptor.json'] = '${base}/content-descriptor.json'
	for uri in [
		'https://opencontainers.org/schema/defs.json',
		'https://opencontainers.org/schema/descriptor/defs.json',
		'https://opencontainers.org/schema/image/defs.json',
		'https://opencontainers.org/schema/image/descriptor/defs.json',
		'https://opencontainers.org/schema/image/index/defs.json',
		'https://opencontainers.org/schema/image/manifest/defs.json',
	] {
		result[uri] = '${base}/defs.json'
	}
	for uri in [
		'https://opencontainers.org/schema/descriptor.json',
		'https://opencontainers.org/schema/defs-descriptor.json',
		'https://opencontainers.org/schema/descriptor/defs-descriptor.json',
		'https://opencontainers.org/schema/image/defs-descriptor.json',
		'https://opencontainers.org/schema/image/descriptor/defs-descriptor.json',
		'https://opencontainers.org/schema/image/index/defs-descriptor.json',
		'https://opencontainers.org/schema/image/manifest/defs-descriptor.json',
		'https://opencontainers.org/schema/index/defs-descriptor.json',
	] {
		result[uri] = '${base}/defs-descriptor.json'
	}
	result[github_packages_image_config_schema_uri] = '${base}/config-schema.json'
	result[github_packages_image_index_schema_uri] = '${base}/image-index-schema.json'
	result[github_packages_image_layout_schema_uri] = '${base}/image-layout-schema.json'
	result[github_packages_image_manifest_schema_uri] = '${base}/image-manifest-schema.json'
	return result
}

// Translated from Homebrew/brew `github_packages.rb`.
