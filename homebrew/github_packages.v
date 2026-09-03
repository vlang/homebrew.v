module homebrew

import compress.gzip
import crypto.sha256
import brew_runtime
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

fn github_packages_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn github_packages_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

fn github_packages_map(value brew_runtime.Value, context string) !map[string]brew_runtime.Value {
	if value.type_name != 'Hash' {
		return error('${context} must be a Hash')
	}
	return value.as_map()
}

fn github_packages_field(values map[string]brew_runtime.Value, key string) brew_runtime.Value {
	return values[key] or { github_packages_nil() }
}

fn github_packages_string(values map[string]brew_runtime.Value, key string) string {
	value := github_packages_field(values, key)
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

fn github_packages_integer(values map[string]brew_runtime.Value, key string) int {
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

fn github_packages_pretty_json_at(value brew_runtime.Value, depth int) string {
	indent := '  '.repeat(depth)
	next_indent := '  '.repeat(depth + 1)
	return match value.type_name {
		'NilClass' { 'null' }
		'Bool' { value.bool_data.str() }
		'Integer' { value.int_data.str() }
		'Float' { value.float_data.str() }
		'Array' {
			entries := value.as_array() or { []brew_runtime.Value{} }
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

pub fn github_packages_pretty_json(value brew_runtime.Value) string {
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

pub fn github_packages_preupload_check(bottle_hash brew_runtime.Value, skopeo string, user string,
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

fn github_packages_validate_descriptor(descriptor brew_runtime.Value) ! {
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

pub fn github_packages_validate_schema(schema_uri string, document brew_runtime.Value) ! {
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

pub fn github_packages_write_hash(directory string, value brew_runtime.Value, filename string) !GitHubPackagesWriteResult {
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
	value := brew_runtime.map_value({
		'imageLayoutVersion': brew_runtime.string_value('1.0.0')
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

pub fn github_packages_write_image_config(platform map[string]brew_runtime.Value, tar_sha256 string,
	blobs string) !GitHubPackagesWriteResult {
	mut image_config := platform.clone()
	image_config['rootfs'] = brew_runtime.map_value({
		'type':     brew_runtime.string_value('layers')
		'diff_ids': brew_runtime.string_array_value(['sha256:${tar_sha256}'])
	})
	value := brew_runtime.map_value(image_config)
	github_packages_validate_schema(github_packages_image_config_schema_uri, value)!
	return github_packages_write_hash(blobs, value, '')
}

pub fn github_packages_write_image_index(manifests []brew_runtime.Value, blobs string,
	annotations map[string]brew_runtime.Value) !GitHubPackagesWriteResult {
	value := brew_runtime.map_value({
		'schemaVersion': brew_runtime.int_value(2)
		'manifests':     brew_runtime.array_value(manifests)
		'annotations':   brew_runtime.map_value(annotations)
	})
	github_packages_validate_schema(github_packages_image_index_schema_uri, value)!
	return github_packages_write_hash(blobs, value, '')
}

pub fn github_packages_write_index_json(index_sha256 string, index_size int, root string,
	annotations map[string]brew_runtime.Value) !GitHubPackagesWriteResult {
	descriptor := brew_runtime.map_value({
		'mediaType':   brew_runtime.string_value('application/vnd.oci.image.index.v1+json')
		'digest':      brew_runtime.string_value('sha256:${index_sha256}')
		'size':        brew_runtime.int_value(index_size)
		'annotations': brew_runtime.map_value(annotations)
	})
	value := brew_runtime.map_value({
		'schemaVersion': brew_runtime.int_value(2)
		'manifests':     brew_runtime.array_value([descriptor])
	})
	github_packages_validate_schema(github_packages_image_index_schema_uri, value)!
	return github_packages_write_hash(root, value, 'index.json')
}

fn github_packages_compact_strings(values map[string]string) map[string]brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		if value != '' {
			result[key] = brew_runtime.string_value(value)
		}
	}
	return result
}

fn github_packages_tab_platform(tag string, tab map[string]brew_runtime.Value) !(map[string]brew_runtime.Value, string, string) {
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
		map[string]brew_runtime.Value{}
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

fn github_packages_tab_annotation(tab map[string]brew_runtime.Value, all_bottle bool) string {
	mut selected := tab.clone()
	if all_bottle {
		selected.delete('arch')
		selected.delete('built_on')
	}
	return brew_runtime.json_value_to_string(brew_runtime.map_value(selected))
}

fn github_packages_sbom_annotation(supplement brew_runtime.Value, formula_full_name string,
	formula_name string, version string, tar_digest string, root_url string, license string,
	created string) string {
	if supplement.type_name != 'Hash' {
		return ''
	}
	mut values := supplement.map_data.clone()
	mut packages := if package_value := values['packages'] {
		package_value.as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	mut describes := if describes_value := values['documentDescribes'] {
		(describes_value.as_array() or { []brew_runtime.Value{} }).map(it.as_string())
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
	bottle_package := brew_runtime.map_value({
		'SPDXID':           brew_runtime.string_value(bottle_id)
		'name':             brew_runtime.string_value(formula_name)
		'versionInfo':      brew_runtime.string_value(version)
		'filesAnalyzed':    brew_runtime.bool_value(false)
		'licenseDeclared':  brew_runtime.string_value('NOASSERTION')
		'builtDate':        brew_runtime.string_value(created)
		'licenseConcluded': brew_runtime.string_value(if license == '' {
			'NOASSERTION'
		} else {
			license
		})
		'downloadLocation': brew_runtime.string_value('${root_url.trim_string_right('/')}/${github_packages_image_formula_name(formula_name)}/blobs/sha256:${tar_digest}')
		'copyrightText':    brew_runtime.string_value('NOASSERTION')
		'externalRefs':     brew_runtime.array_value([
			brew_runtime.map_value({
				'referenceCategory': brew_runtime.string_value('PACKAGE-MANAGER')
				'referenceLocator':  brew_runtime.string_value(purl)
				'referenceType':     brew_runtime.string_value('purl')
			}),
		])
		'checksums':        brew_runtime.array_value([
			brew_runtime.map_value({
				'algorithm':     brew_runtime.string_value('SHA256')
				'checksumValue': brew_runtime.string_value(tar_digest)
			}),
		])
	})
	packages << bottle_package
	describes << bottle_id
	values['packages'] = brew_runtime.array_value(packages)
	values['documentDescribes'] = brew_runtime.string_array_value(describes)
	if 'relationships' !in values {
		values['relationships'] = brew_runtime.array_value([])
	}
	return brew_runtime.json_value_to_string(brew_runtime.map_value(values))
}

pub fn github_packages_upload_bottle(bottle_hash brew_runtime.Value, formula_full_name string,
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
	mut manifests := []brew_runtime.Value{cap: tags.len}
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
		annotations['org.opencontainers.image.created'] = brew_runtime.string_value(created)
		if documentation != '' {
			annotations['org.opencontainers.image.documentation'] = brew_runtime.string_value(documentation)
		}
		annotations['org.opencontainers.image.title'] = brew_runtime.string_value('${formula_full_name} ${tag}')
		image_manifest := brew_runtime.map_value({
			'schemaVersion': brew_runtime.int_value(2)
			'config':        brew_runtime.map_value({
				'mediaType': brew_runtime.string_value('application/vnd.oci.image.config.v1+json')
				'digest':    brew_runtime.string_value('sha256:${config.sha256}')
				'size':      brew_runtime.int_value(config.size)
			})
			'layers':        brew_runtime.array_value([
				brew_runtime.map_value({
					'mediaType':   brew_runtime.string_value('application/vnd.oci.image.layer.v1.tar+gzip')
					'digest':      brew_runtime.string_value('sha256:${tar_gz_digest}')
					'size':        brew_runtime.int_value(file_size)
					'annotations': brew_runtime.map_value({
						'org.opencontainers.image.title': brew_runtime.string_value(local_file)
					})
				}),
			])
			'annotations':   brew_runtime.map_value(annotations)
		})
		github_packages_validate_schema(github_packages_image_manifest_schema_uri, image_manifest)!
		written_manifest := github_packages_write_hash(blobs, image_manifest, '')!
		mut descriptor := map[string]brew_runtime.Value{}
		descriptor['mediaType'] = brew_runtime.string_value('application/vnd.oci.image.manifest.v1+json')
		descriptor['digest'] = brew_runtime.string_value('sha256:${written_manifest.sha256}')
		descriptor['size'] = brew_runtime.int_value(written_manifest.size)
		descriptor['annotations'] = brew_runtime.map_value(descriptor_annotations)
		if !all_bottle {
			descriptor['platform'] = brew_runtime.map_value(platform)
		}
		manifests << brew_runtime.map_value(descriptor)
	}
	index := github_packages_write_image_index(manifests, blobs, formula_annotations)!
	if index.size >= 4 * 1024 * 1024 {
		return error('Image index too large!')
	}
	github_packages_write_index_json(index.sha256, index.size, root, {
		'org.opencontainers.image.ref.name': brew_runtime.string_value(preflight.version_rebuild)
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `upload_bottles(bottles_hash, keep_old:, dry_run:, warn_on_error:)` at line 57.
pub fn ruby_github_packages_l57_d1_upload_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return github_packages_error('UsageError', 'bottles_hash must be a Hash')
	}
	formulae := args[0].map_data.keys()
	mut skipped := map[string]bool{}
	if args.len > 1 && args[1].type_name == 'Hash' {
		for name, value in args[1].map_data {
			skipped[name] = value.as_bool() or { false }
		}
	}
	progress := github_packages_upload_progress(formulae, skipped)
	return brew_runtime.map_value({
		'events':         brew_runtime.string_array_value(progress.events)
		'uploaded_count': brew_runtime.int_value(progress.uploaded_count)
		'bottle_count':   brew_runtime.int_value(progress.bottle_count)
	})
}

// Ruby method `self.version_rebuild(version, rebuild, bottle_tag = nil)` at line 91.
pub fn ruby_github_packages_l91_d2_self_version_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	version := if args.len > 0 { args[0].as_string() } else { '' }
	rebuild := if args.len > 1 { int(args[1].as_int() or { 0 }) } else { 0 }
	tag := if args.len > 2 && args[2].type_name != 'NilClass' {
		?string(args[2].as_string())
	} else {
		none
	}
	return brew_runtime.string_value(github_packages_version_rebuild(version, rebuild, tag))
}

// Ruby method `self.repo_without_prefix(repo)` at line 106.
pub fn ruby_github_packages_l106_d3_self_repo_without_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(github_packages_repo_without_prefix(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.root_url(org, repo, prefix = URL_PREFIX)` at line 112.
pub fn ruby_github_packages_l112_d4_self_root_url(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 2 { args[2].as_string() } else { github_packages_url_prefix }
	return brew_runtime.string_value(github_packages_root_url(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_string() } else { '' }, prefix))
}

// Ruby method `self.root_url_if_match(url)` at line 120.
pub fn ruby_github_packages_l120_d5_self_root_url_if_match(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' || args[0].as_string() == '' {
		return github_packages_nil()
	}
	return brew_runtime.string_value(github_packages_root_url_match(args[0].as_string()) or {
		return github_packages_nil()
	})
}

// Ruby method `self.image_formula_name(formula_name)` at line 130.
pub fn ruby_github_packages_l130_d6_self_image_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(github_packages_image_formula_name(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.image_version_rebuild(version_rebuild)` at line 139.
pub fn ruby_github_packages_l139_d7_self_image_version_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	result := github_packages_image_version_rebuild(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}) or {
		return github_packages_error('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(result)
}

// Ruby method `upload_bottle(user, token, skopeo, formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)` at line 153.
pub fn ruby_github_packages_l153_d8_upload_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return github_packages_error('ArgumentError', 'upload_bottle requires a bottle Hash')
	}
	formula_name := if args.len > 1 {
		args[1].as_string()
	} else {
		formula := github_packages_field(args[0].map_data, 'formula')
		github_packages_string(formula.map_data, 'name')
	}
	result := github_packages_upload_bottle(args[0], formula_name, GitHubPackagesUploadOptions{
		user: if args.len > 3 { args[3].as_string() } else { 'brewtest' }
		token: if args.len > 4 { args[4].as_string() } else { 'ghp_test' }
		root_parent: if args.len > 2 { args[2].as_string() } else { '.' }
		dry_run: if args.len > 5 { args[5].as_bool() or { true } } else { true }
	}) or { return github_packages_error('RuntimeError', err.msg()) }
	return brew_runtime.map_value({
		'root':              brew_runtime.string_value(result.root)
		'image_uri':         brew_runtime.string_value(result.image_uri)
		'version_rebuild':   brew_runtime.string_value(result.version_rebuild)
		'manifest_count':    brew_runtime.int_value(result.manifest_count)
		'index_json_sha256': brew_runtime.string_value(result.index_json_sha256)
		'index_json_size':   brew_runtime.int_value(result.index_json_size)
		'command':           brew_runtime.string_value(result.command.display)
	})
}

// Ruby method `load_schemas!` at line 393.
pub fn ruby_github_packages_l393_d9_load_schemas(args ...brew_runtime.Value) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for uri, source in github_packages_schema_sources() {
		result[uri] = brew_runtime.string_value(source)
	}
	return brew_runtime.map_value(result)
}

// Ruby method `schema_uri(basename, uris)` at line 421.
pub fn ruby_github_packages_l421_d10_schema_uri(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return github_packages_error('ArgumentError', 'schema_uri requires a basename and URI list')
	}
	basename := args[0].as_string()
	uris := if args[1].type_name == 'Array' {
		(args[1].as_array() or { [] }).map(it.as_string())
	} else {
		[args[1].as_string()]
	}
	source := 'https://raw.githubusercontent.com/opencontainers/image-spec/${github_packages_schema_revision}/schema/${basename}.json'
	mut result := map[string]brew_runtime.Value{}
	for uri in uris {
		result[uri] = if args.len > 2 { args[2] } else { brew_runtime.string_value(source) }
	}
	return brew_runtime.map_value(result)
}

// Ruby method `schema_resolver(uri)` at line 436.
pub fn ruby_github_packages_l436_d11_schema_resolver(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[0].type_name != 'Hash' {
		return github_packages_nil()
	}
	uri := args[1].as_string().all_before('#')
	return args[0].map_data[uri] or { github_packages_nil() }
}

// Ruby method `validate_schema!(schema_uri, json)` at line 441.
pub fn ruby_github_packages_l441_d12_validate_schema(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return github_packages_error('ArgumentError', 'validate_schema! requires schema URI and JSON')
	}
	github_packages_validate_schema(args[0].as_string(), args[1]) or {
		return github_packages_error('SystemExit', err.msg())
	}
	return github_packages_nil()
}

// Ruby method `download(user, token, skopeo, image_uri, root, dry_run:)` at line 456.
pub fn ruby_github_packages_l456_d13_download(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		return github_packages_error('ArgumentError', 'download requires user, token, skopeo, image URI and root')
	}
	command := github_packages_download_command(args[0].as_string(), args[1].as_string(), args[2].as_string(), args[3].as_string(), args[4].as_string(), if args.len > 5 {
		args[5].as_bool() or { false }
	} else {
		false
	})
	return brew_runtime.map_value({
		'program': brew_runtime.string_value(command.program)
		'args':    brew_runtime.string_array_value(command.args)
		'display': brew_runtime.string_value(command.display)
	})
}

// Ruby method `preupload_check(user, token, skopeo, _formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)` at line 475.
pub fn ruby_github_packages_l475_d14_preupload_check(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return github_packages_error('ArgumentError', 'preupload_check requires a bottle Hash')
	}
	result := github_packages_preupload_check(args[0], if args.len > 1 {
		args[1].as_string()
	} else {
		'skopeo'
	}, if args.len > 2 { args[2].as_string() } else { 'brewtest' }, if args.len > 3 {
		args[3].as_string()
	} else {
		'ghp_test'
	}, GitHubPackagesPreuploadOptions{
		keep_old: args.len > 4 && (args[4].as_bool() or { false })
		dry_run: args.len < 6 || (args[5].as_bool() or { false })
		warn_on_error: args.len > 6 && (args[6].as_bool() or { false })
		inspect_result: GitHubPackagesInspectResult{
			success: args.len > 7 && (args[7].as_bool() or { false })
			stderr: if args.len > 8 { args[8].as_string() } else { '' }
		}
	}) or { return github_packages_error('RuntimeError', err.msg()) }
	if result.skipped {
		return github_packages_nil()
	}
	return brew_runtime.array_value([
		brew_runtime.string_value(result.formula_name),
		brew_runtime.string_value(result.org),
		brew_runtime.string_value(result.repo),
		brew_runtime.string_value(result.version),
		brew_runtime.int_value(result.rebuild),
		brew_runtime.string_value(result.version_rebuild),
		brew_runtime.string_value(result.image_name),
		brew_runtime.string_value(result.image_uri),
		brew_runtime.bool_value(result.keep_old),
	])
}

// Ruby method `write_image_layout(root)` at line 525.
pub fn ruby_github_packages_l525_d15_write_image_layout(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return github_packages_error('ArgumentError', 'write_image_layout requires a root')
	}
	result := github_packages_write_image_layout(args[0].as_string()) or {
		return github_packages_error('RuntimeError', err.msg())
	}
	return brew_runtime.array_value([brew_runtime.string_value(result.sha256),
		brew_runtime.int_value(result.size)])
}

// Ruby method `write_tar_gz(local_file, blobs)` at line 532.
pub fn ruby_github_packages_l532_d16_write_tar_gz(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return github_packages_error('ArgumentError', 'write_tar_gz requires a file and blobs directory')
	}
	return brew_runtime.string_value(github_packages_write_tar_gz(args[0].as_string(), args[1].as_string()) or { return github_packages_error('RuntimeError', err.msg()) })
}

// Ruby method `write_image_config(platform_hash, tar_sha256, blobs)` at line 540.
pub fn ruby_github_packages_l540_d17_write_image_config(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 || args[0].type_name != 'Hash' {
		return github_packages_error('ArgumentError', 'write_image_config requires platform, digest and blobs')
	}
	result := github_packages_write_image_config(args[0].map_data, args[1].as_string(), args[2].as_string()) or { return github_packages_error('RuntimeError', err.msg()) }
	return brew_runtime.array_value([brew_runtime.string_value(result.sha256),
		brew_runtime.int_value(result.size)])
}

// Ruby method `write_image_index(manifests, blobs, annotations)` at line 552.
pub fn ruby_github_packages_l552_d18_write_image_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 || args[0].type_name != 'Array' || args[2].type_name != 'Hash' {
		return github_packages_error('ArgumentError', 'write_image_index requires manifests, blobs and annotations')
	}
	result := github_packages_write_image_index(args[0].as_array() or { [] }, args[1].as_string(), args[2].map_data) or { return github_packages_error('RuntimeError', err.msg()) }
	return brew_runtime.array_value([brew_runtime.string_value(result.sha256),
		brew_runtime.int_value(result.size)])
}

// Ruby method `write_index_json(index_json_sha256, index_json_size, root, annotations)` at line 563.
pub fn ruby_github_packages_l563_d19_write_index_json(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 || args[3].type_name != 'Hash' {
		return github_packages_error('ArgumentError', 'write_index_json requires digest, size, root and annotations')
	}
	result := github_packages_write_index_json(args[0].as_string(), int(args[1].as_int() or { 0 }), args[2].as_string(), args[3].map_data) or {
		return github_packages_error('RuntimeError', err.msg())
	}
	return brew_runtime.array_value([brew_runtime.string_value(result.sha256),
		brew_runtime.int_value(result.size)])
}

// Ruby method `write_hash(directory, hash, filename = nil)` at line 578.
pub fn ruby_github_packages_l578_d20_write_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return github_packages_error('ArgumentError', 'write_hash requires directory and Hash')
	}
	result := github_packages_write_hash(args[0].as_string(), args[1], if args.len > 2 {
		args[2].as_string()
	} else {
		''
	}) or { return github_packages_error('RuntimeError', err.msg()) }
	return brew_runtime.array_value([brew_runtime.string_value(result.sha256),
		brew_runtime.int_value(result.size)])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5: require "utils/gzip"
// 6: require "utils/output"
// 7: require "json"
// 8: require "zlib"
// 9: require "extend/hash/keys"
// 10: require "system_command"
// 11:
// 12: # GitHub Packages client.
// 13: class GitHubPackages
// 14:   include Context
// 15:   include SystemCommand::Mixin
// 16:   include Utils::Output::Mixin
// 17:
// 18:   URL_DOMAIN = "ghcr.io"
// 19:   URL_PREFIX = T.let("https://#{URL_DOMAIN}/v2/".freeze, String)
// 20:   DOCKER_PREFIX = T.let("docker://#{URL_DOMAIN}/".freeze, String)
// 21:   public_constant :URL_DOMAIN
// 22:   private_constant :URL_PREFIX
// 23:   private_constant :DOCKER_PREFIX
// 24:
// 25:   URL_REGEX = %r{(?:#{Regexp.escape(URL_PREFIX)}|#{Regexp.escape(DOCKER_PREFIX)})([\w-]+)/([\w-]+)}
// 26:
// 27:   # Valid OCI tag characters
// 28:   # https://github.com/opencontainers/distribution-spec/blob/main/spec.md#workflow-categories
// 29:   VALID_OCI_TAG_REGEX = /^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}$/
// 30:
// 31:   # Translate Homebrew tab.arch to OCI platform.architecture
// 32:   TAB_ARCH_TO_PLATFORM_ARCHITECTURE = T.let(
// 33:     {
// 34:       "arm64"  => "arm64",
// 35:       "x86_64" => "amd64",
// 36:     }.freeze,
// 37:     T::Hash[String, String],
// 38:   )
// 39:
// 40:   # Translate Homebrew built_on.os to OCI platform.os
// 41:   BUILT_ON_OS_TO_PLATFORM_OS = T.let(
// 42:     {
// 43:       "Linux"     => "linux",
// 44:       "Macintosh" => "darwin",
// 45:     }.freeze,
// 46:     T::Hash[String, String],
// 47:   )
// 48:
// 49:   sig {
// 50:     params(
// 51:       bottles_hash:  T::Hash[String, T.untyped],
// 52:       keep_old:      T::Boolean,
// 53:       dry_run:       T::Boolean,
// 54:       warn_on_error: T::Boolean,
// 55:     ).void
// 56:   }
// 57:   def upload_bottles(bottles_hash, keep_old:, dry_run:, warn_on_error:)
// 58:     user = Homebrew::EnvConfig.github_packages_user
// 59:     token = Homebrew::EnvConfig.github_packages_token
// 60:
// 61:     raise UsageError, "HOMEBREW_GITHUB_PACKAGES_USER is unset." if user.blank?
// 62:     raise UsageError, "HOMEBREW_GITHUB_PACKAGES_TOKEN is unset." if token.blank?
// 63:
// 64:     skopeo = ensure_executable!("skopeo", reason: "upload")
// 65:
// 66:     require "json_schemer"
// 67:
// 68:     load_schemas!
// 69:
// 70:     bottles_hash.each do |formula_full_name, bottle_hash|
// 71:       # First, check that we won't encounter an error in the middle of uploading bottles.
// 72:       preupload_check(user, token, skopeo, formula_full_name, bottle_hash,
// 73:                       keep_old:, dry_run:, warn_on_error:)
// 74:     end
// 75:
// 76:     # We intentionally iterate over `bottles_hash` twice to
// 77:     # avoid erroring out in the middle of uploading bottles.
// 78:     bottle_count = bottles_hash.count
// 79:     bottles_hash.each_with_index do |(formula_full_name, bottle_hash), index|
// 80:       # Next, upload the bottles after checking them all.
// 81:       upload_bottle(user, token, skopeo, formula_full_name, bottle_hash,
// 82:                     keep_old:, dry_run:, warn_on_error:)
// 83:       next if bottle_count < 3
// 84:
// 85:       uploaded_count = index + 1
// 86:       ohai "Upload progress: #{uploaded_count} formula(e) uploaded, #{bottle_count - uploaded_count} remaining"
// 87:     end
// 88:   end
// 89:
// 90:   sig { params(version: Version, rebuild: Integer, bottle_tag: T.nilable(String)).returns(String) }
// 91:   def self.version_rebuild(version, rebuild, bottle_tag = nil)
// 92:     bottle_tag = (".#{bottle_tag}" if bottle_tag.present?)
// 93:
// 94:     rebuild = if rebuild.positive?
// 95:       if bottle_tag
// 96:         ".#{rebuild}"
// 97:       else
// 98:         "-#{rebuild}"
// 99:       end
// 100:     end
// 101:
// 102:     "#{version}#{bottle_tag}#{rebuild}"
// 103:   end
// 104:
// 105:   sig { params(repo: String).returns(String) }
// 106:   def self.repo_without_prefix(repo)
// 107:     # Remove redundant repository prefix for a shorter name.
// 108:     repo.delete_prefix("homebrew-")
// 109:   end
// 110:
// 111:   sig { params(org: String, repo: String, prefix: String).returns(String) }
// 112:   def self.root_url(org, repo, prefix = URL_PREFIX)
// 113:     # `docker`/`skopeo` insist on lowercase organisation (“repository name”).
// 114:     org = org.downcase
// 115:
// 116:     "#{prefix}#{org}/#{repo_without_prefix(repo)}"
// 117:   end
// 118:
// 119:   sig { params(url: T.nilable(String)).returns(T.nilable(String)) }
// 120:   def self.root_url_if_match(url)
// 121:     return if url.blank?
// 122:
// 123:     _, org, repo, = *url.to_s.match(URL_REGEX)
// 124:     return if org.blank? || repo.blank?
// 125:
// 126:     root_url(org, repo)
// 127:   end
// 128:
// 129:   sig { params(formula_name: String).returns(String) }
// 130:   def self.image_formula_name(formula_name)
// 131:     # Invalid docker name characters:
// 132:     # - `/` makes sense because we already use it to separate repository/formula.
// 133:     # - `x` makes sense because we already use it in `Formulary`.
// 134:     formula_name.tr("@", "/")
// 135:                 .tr("+", "x")
// 136:   end
// 137:
// 138:   sig { params(version_rebuild: String).returns(String) }
// 139:   def self.image_version_rebuild(version_rebuild)
// 140:     unless version_rebuild.match?(VALID_OCI_TAG_REGEX)
// 141:       raise ArgumentError, "GitHub Packages versions must match #{VALID_OCI_TAG_REGEX.source}!"
// 142:     end
// 143:
// 144:     version_rebuild
// 145:   end
// 146:
// 147:   sig {
// 148:     params(
// 149:       user: String, token: String, skopeo: Pathname, formula_full_name: String,
// 150:       bottle_hash: T::Hash[String, T.untyped], keep_old: T::Boolean, dry_run: T::Boolean, warn_on_error: T::Boolean
// 151:     ).void
// 152:   }
// 153:   def upload_bottle(user, token, skopeo, formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)
// 154:     # We run the preupload check twice to prevent TOCTOU bugs.
// 155:     result = preupload_check(user, token, skopeo, formula_full_name, bottle_hash,
// 156:                              keep_old:, dry_run:, warn_on_error:)
// 157:     # Skip upload if preupload check returned early.
// 158:     return if result.nil?
// 159:
// 160:     formula_name, org, repo, version, rebuild, version_rebuild, image_name, image_uri, keep_old = *result
// 161:
// 162:     root = Pathname("#{formula_name}--#{version_rebuild}")
// 163:     FileUtils.rm_rf root
// 164:     root.mkpath
// 165:
// 166:     if keep_old
// 167:       download(user, token, skopeo, image_uri, root, dry_run:)
// 168:     else
// 169:       write_image_layout(root)
// 170:     end
// 171:
// 172:     blobs = root/"blobs/sha256"
// 173:     blobs.mkpath
// 174:
// 175:     git_path = bottle_hash["formula"]["tap_git_path"]
// 176:     git_revision = bottle_hash["formula"]["tap_git_revision"]
// 177:
// 178:     source_org_repo = "#{org}/#{repo}"
// 179:     source = "https://github.com/#{source_org_repo}/blob/#{git_revision.presence || "HEAD"}/#{git_path}"
// 180:
// 181:     formula_core_tap = formula_full_name.exclude?("/")
// 182:     documentation = if formula_core_tap
// 183:       "https://formulae.brew.sh/formula/#{formula_name}"
// 184:     elsif (remote = bottle_hash["formula"]["tap_git_remote"]) && remote.start_with?("https://github.com/")
// 185:       remote
// 186:     end
// 187:
// 188:     license = bottle_hash["formula"]["license"].to_s
// 189:     created_date = bottle_hash["bottle"]["date"]
// 190:     if keep_old
// 191:       index = JSON.parse((root/"index.json").read)
// 192:       image_index_sha256 = index["manifests"].first["digest"].delete_prefix("sha256:")
// 193:       image_index = JSON.parse((blobs/image_index_sha256).read)
// 194:       (blobs/image_index_sha256).unlink
// 195:
// 196:       formula_annotations_hash = image_index["annotations"]
// 197:       manifests = image_index["manifests"]
// 198:     else
// 199:       require "utils/spdx"
// 200:       image_license = SPDX.truncate_license(license)
// 201:
// 202:       formula_annotations_hash = {
// 203:         "com.github.package.type"                => GITHUB_PACKAGE_TYPE,
// 204:         "org.opencontainers.image.created"       => created_date,
// 205:         "org.opencontainers.image.description"   => bottle_hash["formula"]["desc"],
// 206:         "org.opencontainers.image.documentation" => documentation,
// 207:         "org.opencontainers.image.licenses"      => image_license,
// 208:         "org.opencontainers.image.ref.name"      => version_rebuild,
// 209:         "org.opencontainers.image.revision"      => git_revision,
// 210:         "org.opencontainers.image.source"        => source,
// 211:         "org.opencontainers.image.title"         => formula_full_name,
// 212:         "org.opencontainers.image.url"           => bottle_hash["formula"]["homepage"],
// 213:         "org.opencontainers.image.vendor"        => org,
// 214:         "org.opencontainers.image.version"       => version.to_s, # Schema accepts strings for version
// 215:       }.compact_blank
// 216:       manifests = []
// 217:     end
// 218:
// 219:     processed_image_refs = Set.new
// 220:     manifests.each do |manifest|
// 221:       processed_image_refs << manifest["annotations"]["org.opencontainers.image.ref.name"]
// 222:     end
// 223:
// 224:     require "sbom"
// 225:
// 226:     manifests += bottle_hash["bottle"]["tags"].map do |bottle_tag, tag_hash|
// 227:       bottle_tag = Utils::Bottles::Tag.from_symbol(bottle_tag.to_sym)
// 228:       all_bottle = bottle_tag.to_sym == :all
// 229:
// 230:       tag = GitHubPackages.version_rebuild(version, rebuild, bottle_tag.to_s)
// 231:
// 232:       if processed_image_refs.include?(tag)
// 233:         puts
// 234:         odie "A bottle JSON for #{bottle_tag} is present, but it is already in the image index!"
// 235:       else
// 236:         processed_image_refs << tag
// 237:       end
// 238:
// 239:       local_file = tag_hash["local_filename"]
// 240:       odebug "Uploading #{local_file}"
// 241:
// 242:       tar_gz_sha256 = write_tar_gz(local_file, blobs)
// 243:
// 244:       tab = tag_hash["tab"]
// 245:       architecture = TAB_ARCH_TO_PLATFORM_ARCHITECTURE[tab["arch"].presence || bottle_tag.standardized_arch.to_s]
// 246:       raise TypeError, "unknown tab['arch']: #{tab["arch"]}" if architecture.blank?
// 247:
// 248:       os = if tab["built_on"].present? && tab["built_on"]["os"].present?
// 249:         BUILT_ON_OS_TO_PLATFORM_OS[tab["built_on"]["os"]]
// 250:       elsif bottle_tag.linux?
// 251:         "linux"
// 252:       else
// 253:         "darwin"
// 254:       end
// 255:       raise TypeError, "unknown tab['built_on']['os']: #{tab["built_on"]["os"]}" if os.blank?
// 256:
// 257:       os_version = tab["built_on"]["os_version"].presence if tab["built_on"].present?
// 258:       case os
// 259:       when "darwin"
// 260:         os_version ||= "macOS #{bottle_tag.to_macos_version}"
// 261:       when "linux"
// 262:         os_version&.delete_suffix!(" LTS")
// 263:         os_version ||= OS::LINUX_CI_OS_VERSION
// 264:         glibc_version = tab["built_on"]["glibc_version"].presence if tab["built_on"].present?
// 265:         glibc_version ||= OS::LINUX_GLIBC_CI_VERSION
// 266:         cpu_variant = tab.dig("built_on", "oldest_cpu_family") || Hardware::CPU::INTEL_64BIT_OLDEST_CPU.to_s
// 267:       end
// 268:
// 269:       platform_hash = {
// 270:         architecture:,
// 271:         os:,
// 272:         "os.version" => os_version,
// 273:       }.compact_blank
// 274:
// 275:       tar_sha256 = Digest::SHA256.new
// 276:       Zlib::GzipReader.open(local_file) do |gz|
// 277:         while (data = gz.read(Utils::Gzip::GZIP_BUFFER_SIZE))
// 278:           tar_sha256 << data
// 279:         end
// 280:       end
// 281:
// 282:       config_json_sha256, config_json_size = write_image_config(platform_hash, tar_sha256.hexdigest, blobs)
// 283:
// 284:       documentation = "https://formulae.brew.sh/formula/#{formula_name}" if formula_core_tap
// 285:
// 286:       local_file_size = File.size(local_file)
// 287:
// 288:       path_exec_files_string = if (path_exec_files = tag_hash["path_exec_files"].presence)
// 289:         path_exec_files.join(",")
// 290:       end
// 291:       sbom_supplement_annotation = SBOM.github_packages_sbom_supplement_annotation(
// 292:         tag_hash["sbom"],
// 293:         formula_full_name:,
// 294:         formula_name:,
// 295:         version:,
// 296:         tar_gz_sha256:,
// 297:         root_url:          bottle_hash["bottle"]["root_url"],
// 298:         license:,
// 299:         created_date:,
// 300:       )
// 301:
// 302:       descriptor_annotations_hash = {
// 303:         "org.opencontainers.image.ref.name" => tag,
// 304:         "sh.brew.bottle.cpu.variant"        => cpu_variant,
// 305:         "sh.brew.bottle.digest"             => tar_gz_sha256,
// 306:         "sh.brew.bottle.glibc.version"      => glibc_version,
// 307:         "sh.brew.bottle.size"               => local_file_size.to_s,
// 308:         "sh.brew.bottle.installed_size"     => tag_hash["installed_size"].to_s,
// 309:         "sh.brew.license"                   => license,
// 310:         "sh.brew.tab"                       => (all_bottle ? tab.except("arch", "built_on") : tab).to_json,
// 311:         "sh.brew.sbom.supplement"           => sbom_supplement_annotation,
// 312:         "sh.brew.path_exec_files"           => path_exec_files_string,
// 313:       }.compact_blank
// 314:
// 315:       # TODO: upload/add tag_hash["all_files"] somewhere.
// 316:
// 317:       annotations_hash = formula_annotations_hash.merge(descriptor_annotations_hash).merge(
// 318:         {
// 319:           "org.opencontainers.image.created"       => created_date,
// 320:           "org.opencontainers.image.documentation" => documentation,
// 321:           "org.opencontainers.image.title"         => "#{formula_full_name} #{tag}",
// 322:         },
// 323:       ).compact_blank.sort.to_h
// 324:
// 325:       image_manifest = {
// 326:         schemaVersion: 2,
// 327:         config:        {
// 328:           mediaType: "application/vnd.oci.image.config.v1+json",
// 329:           digest:    "sha256:#{config_json_sha256}",
// 330:           size:      config_json_size,
// 331:         },
// 332:         layers:        [{
// 333:           mediaType:   "application/vnd.oci.image.layer.v1.tar+gzip",
// 334:           digest:      "sha256:#{tar_gz_sha256}",
// 335:           size:        File.size(local_file),
// 336:           annotations: {
// 337:             "org.opencontainers.image.title" => local_file,
// 338:           },
// 339:         }],
// 340:         annotations:   annotations_hash,
// 341:       }
// 342:       validate_schema!(IMAGE_MANIFEST_SCHEMA_URI, image_manifest)
// 343:       manifest_json_sha256, manifest_json_size = write_hash(blobs, image_manifest)
// 344:
// 345:       {
// 346:         mediaType:   "application/vnd.oci.image.manifest.v1+json",
// 347:         digest:      "sha256:#{manifest_json_sha256}",
// 348:         size:        manifest_json_size,
// 349:         platform:    all_bottle ? nil : platform_hash,
// 350:         annotations: descriptor_annotations_hash,
// 351:       }.compact
// 352:     end
// 353:
// 354:     index_json_sha256, index_json_size = write_image_index(manifests, blobs, formula_annotations_hash)
// 355:     raise "Image index too large!" if index_json_size >= 4 * 1024 * 1024 # GitHub will error 500 if too large
// 356:
// 357:     write_index_json(index_json_sha256, index_json_size, root,
// 358:                      "org.opencontainers.image.ref.name" => version_rebuild)
// 359:
// 360:     puts
// 361:     args = ["copy", "--retry-times=3", "--format=oci", "--all", "oci:#{root}", image_uri.to_s]
// 362:     if dry_run
// 363:       puts "#{skopeo} #{args.join(" ")} --dest-creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 364:     else
// 365:       args << "--dest-creds=#{user}:#{token}"
// 366:       retry_count = 0
// 367:       begin
// 368:         system_command!(skopeo, verbose: true, print_stdout: true, args:)
// 369:       rescue ErrorDuringExecution
// 370:         retry_count += 1
// 371:         odie "Cannot perform an upload to registry after retrying multiple times!" if retry_count >= 10
// 372:         Utils.exponential_backoff_sleep(retry_count)
// 373:         retry
// 374:       end
// 375:
// 376:       package_name = "#{GitHubPackages.repo_without_prefix(repo)}/#{image_name}"
// 377:       ohai "Uploaded to https://github.com/orgs/#{org}/packages/container/package/#{package_name}"
// 378:     end
// 379:   end
// 380:
// 381:   private
// 382:
// 383:   IMAGE_CONFIG_SCHEMA_URI = "https://opencontainers.org/schema/image/config"
// 384:   IMAGE_INDEX_SCHEMA_URI = "https://opencontainers.org/schema/image/index"
// 385:   IMAGE_LAYOUT_SCHEMA_URI = "https://opencontainers.org/schema/image/layout"
// 386:   IMAGE_MANIFEST_SCHEMA_URI = "https://opencontainers.org/schema/image/manifest"
// 387:
// 388:   GITHUB_PACKAGE_TYPE = "homebrew_bottle"
// 389:   private_constant :IMAGE_CONFIG_SCHEMA_URI, :IMAGE_INDEX_SCHEMA_URI, :IMAGE_LAYOUT_SCHEMA_URI,
// 390:                    :IMAGE_MANIFEST_SCHEMA_URI, :GITHUB_PACKAGE_TYPE
// 391:
// 392:   sig { void }
// 393:   def load_schemas!
// 394:     schema_uri("content-descriptor",
// 395:                "https://opencontainers.org/schema/image/content-descriptor.json")
// 396:     schema_uri("defs", %w[
// 397:       https://opencontainers.org/schema/defs.json
// 398:       https://opencontainers.org/schema/descriptor/defs.json
// 399:       https://opencontainers.org/schema/image/defs.json
// 400:       https://opencontainers.org/schema/image/descriptor/defs.json
// 401:       https://opencontainers.org/schema/image/index/defs.json
// 402:       https://opencontainers.org/schema/image/manifest/defs.json
// 403:     ])
// 404:     schema_uri("defs-descriptor", %w[
// 405:       https://opencontainers.org/schema/descriptor.json
// 406:       https://opencontainers.org/schema/defs-descriptor.json
// 407:       https://opencontainers.org/schema/descriptor/defs-descriptor.json
// 408:       https://opencontainers.org/schema/image/defs-descriptor.json
// 409:       https://opencontainers.org/schema/image/descriptor/defs-descriptor.json
// 410:       https://opencontainers.org/schema/image/index/defs-descriptor.json
// 411:       https://opencontainers.org/schema/image/manifest/defs-descriptor.json
// 412:       https://opencontainers.org/schema/index/defs-descriptor.json
// 413:     ])
// 414:     schema_uri("config-schema", IMAGE_CONFIG_SCHEMA_URI)
// 415:     schema_uri("image-index-schema", IMAGE_INDEX_SCHEMA_URI)
// 416:     schema_uri("image-layout-schema", IMAGE_LAYOUT_SCHEMA_URI)
// 417:     schema_uri("image-manifest-schema", IMAGE_MANIFEST_SCHEMA_URI)
// 418:   end
// 419:
// 420:   sig { params(basename: String, uris: T.any(String, T::Array[String])).void }
// 421:   def schema_uri(basename, uris)
// 422:     # The current `main` version has an invalid JSON schema.
// 423:     # Going forward, this should probably be pinned to tags.
// 424:     # We currently use features newer than the last one (v1.0.2).
// 425:     url = "https://raw.githubusercontent.com/opencontainers/image-spec/170393e57ed656f7f81c3070bfa8c3346eaa0a5a/schema/#{basename}.json"
// 426:     out = Utils::Curl.curl_output(url).stdout
// 427:     json = JSON.parse(out)
// 428:
// 429:     @schema_json ||= T.let({}, T.nilable(T::Hash[String, T::Hash[String, T.untyped]]))
// 430:     Array(uris).each do |uri|
// 431:       @schema_json[uri] = json
// 432:     end
// 433:   end
// 434:
// 435:   T::Sig::WithoutRuntime.sig { params(uri: URI::Generic).returns(T.nilable(T::Hash[String, T.untyped])) }
// 436:   def schema_resolver(uri)
// 437:     @schema_json&.fetch(uri.to_s.gsub(/#.*/, ""))
// 438:   end
// 439:
// 440:   sig { params(schema_uri: String, json: T::Hash[T.any(String, Symbol), T.untyped]).void }
// 441:   def validate_schema!(schema_uri, json)
// 442:     schema = JSONSchemer.schema(@schema_json&.fetch(schema_uri), ref_resolver: method(:schema_resolver))
// 443:     json = json.deep_stringify_keys
// 444:     return if schema.valid?(json)
// 445:
// 446:     puts
// 447:     ofail "#{Formatter.url(schema_uri)} JSON schema validation failed!"
// 448:     oh1 "Errors"
// 449:     puts schema.validate(json).to_a.inspect
// 450:     oh1 "JSON"
// 451:     puts json.inspect
// 452:     exit 1
// 453:   end
// 454:
// 455:   sig { params(user: String, token: String, skopeo: Pathname, image_uri: String, root: Pathname, dry_run: T::Boolean).void }
// 456:   def download(user, token, skopeo, image_uri, root, dry_run:)
// 457:     puts
// 458:     args = ["copy", "--all", image_uri.to_s, "oci:#{root}"]
// 459:     if dry_run
// 460:       puts "#{skopeo} #{args.join(" ")} --src-creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 461:     else
// 462:       args << "--src-creds=#{user}:#{token}"
// 463:       system_command!(skopeo, verbose: true, print_stdout: true, args:)
// 464:     end
// 465:   end
// 466:
// 467:   sig {
// 468:     params(
// 469:       user: String, token: String, skopeo: Pathname, _formula_full_name: String,
// 470:       bottle_hash: T::Hash[String, T.untyped], keep_old: T::Boolean, dry_run: T::Boolean, warn_on_error: T::Boolean
// 471:     ).returns(
// 472:       T.nilable([String, String, String, Version, Integer, String, String, String, T::Boolean]),
// 473:     )
// 474:   }
// 475:   def preupload_check(user, token, skopeo, _formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)
// 476:     formula_name = bottle_hash["formula"]["name"]
// 477:
// 478:     _, org, repo, = *bottle_hash["bottle"]["root_url"].match(URL_REGEX)
// 479:     repo = "homebrew-#{repo}" unless repo.start_with?("homebrew-")
// 480:
// 481:     version = Version.new(bottle_hash["formula"]["pkg_version"])
// 482:     rebuild = bottle_hash["bottle"]["rebuild"].to_i
// 483:     version_rebuild = GitHubPackages.version_rebuild(version, rebuild)
// 484:
// 485:     image_name = GitHubPackages.image_formula_name(formula_name)
// 486:     image_tag = GitHubPackages.image_version_rebuild(version_rebuild)
// 487:     image_uri = "#{GitHubPackages.root_url(org, repo, DOCKER_PREFIX)}/#{image_name}:#{image_tag}"
// 488:
// 489:     puts
// 490:     inspect_args = ["inspect", "--raw", image_uri.to_s]
// 491:     if dry_run
// 492:       puts "#{skopeo} #{inspect_args.join(" ")} --creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 493:     else
// 494:       inspect_args << "--creds=#{user}:#{token}"
// 495:       inspect_result = system_command(skopeo, print_stderr: false, args: inspect_args)
// 496:
// 497:       # Order here is important.
// 498:       if !inspect_result.status.success? && !inspect_result.stderr.match?(/(name|manifest) unknown/)
// 499:         # We got an error and it was not about the tag or package being unknown.
// 500:         if warn_on_error
// 501:           opoo "#{image_uri} inspection returned an error, skipping upload!\n#{inspect_result.stderr}"
// 502:           return
// 503:         else
// 504:           odie "#{image_uri} inspection returned an error!\n#{inspect_result.stderr}"
// 505:         end
// 506:       elsif keep_old
// 507:         # If the tag doesn't exist, ignore `--keep-old`.
// 508:         keep_old = false unless inspect_result.status.success?
// 509:         # Otherwise, do nothing - the tag already existing is expected behaviour for --keep-old.
// 510:       elsif inspect_result.status.success?
// 511:         # The tag already exists and we are not passing `--keep-old`.
// 512:         if warn_on_error
// 513:           opoo "#{image_uri} already exists, skipping upload!"
// 514:           return
// 515:         else
// 516:           odie "#{image_uri} already exists!"
// 517:         end
// 518:       end
// 519:     end
// 520:
// 521:     [formula_name, org, repo, version, rebuild, version_rebuild, image_name, image_uri, keep_old]
// 522:   end
// 523:
// 524:   sig { params(root: Pathname).returns([String, Integer]) }
// 525:   def write_image_layout(root)
// 526:     image_layout = { imageLayoutVersion: "1.0.0" }
// 527:     validate_schema!(IMAGE_LAYOUT_SCHEMA_URI, image_layout)
// 528:     write_hash(root, image_layout, "oci-layout")
// 529:   end
// 530:
// 531:   sig { params(local_file: String, blobs: Pathname).returns(String) }
// 532:   def write_tar_gz(local_file, blobs)
// 533:     tar_gz_sha256 = Digest::SHA256.file(local_file)
// 534:                                   .hexdigest
// 535:     FileUtils.ln local_file, blobs/tar_gz_sha256, force: true
// 536:     tar_gz_sha256
// 537:   end
// 538:
// 539:   sig { params(platform_hash: T::Hash[T.any(String, Symbol), T.untyped], tar_sha256: String, blobs: Pathname).returns([String, Integer]) }
// 540:   def write_image_config(platform_hash, tar_sha256, blobs)
// 541:     image_config = platform_hash.merge({
// 542:       rootfs: {
// 543:         type:     "layers",
// 544:         diff_ids: ["sha256:#{tar_sha256}"],
// 545:       },
// 546:     })
// 547:     validate_schema!(IMAGE_CONFIG_SCHEMA_URI, image_config)
// 548:     write_hash(blobs, image_config)
// 549:   end
// 550:
// 551:   sig { params(manifests: T::Array[T::Hash[T.any(String, Symbol), T.untyped]], blobs: Pathname, annotations: T::Hash[String, String]).returns([String, Integer]) }
// 552:   def write_image_index(manifests, blobs, annotations)
// 553:     image_index = {
// 554:       schemaVersion: 2,
// 555:       manifests:,
// 556:       annotations:,
// 557:     }
// 558:     validate_schema!(IMAGE_INDEX_SCHEMA_URI, image_index)
// 559:     write_hash(blobs, image_index)
// 560:   end
// 561:
// 562:   sig { params(index_json_sha256: String, index_json_size: Integer, root: Pathname, annotations: T::Hash[String, String]).void }
// 563:   def write_index_json(index_json_sha256, index_json_size, root, annotations)
// 564:     index_json = {
// 565:       schemaVersion: 2,
// 566:       manifests:     [{
// 567:         mediaType:   "application/vnd.oci.image.index.v1+json",
// 568:         digest:      "sha256:#{index_json_sha256}",
// 569:         size:        index_json_size,
// 570:         annotations:,
// 571:       }],
// 572:     }
// 573:     validate_schema!(IMAGE_INDEX_SCHEMA_URI, index_json)
// 574:     write_hash(root, index_json, "index.json")
// 575:   end
// 576:
// 577:   sig { params(directory: Pathname, hash: T::Hash[T.any(String, Symbol), T.untyped], filename: T.nilable(String)).returns([String, Integer]) }
// 578:   def write_hash(directory, hash, filename = nil)
// 579:     json = JSON.pretty_generate(hash)
// 580:     sha256 = Digest::SHA256.hexdigest(json)
// 581:     filename ||= sha256
// 582:     path = directory/filename
// 583:     path.unlink if path.exist?
// 584:     path.write(json)
// 585:
// 586:     [sha256, json.size]
// 587:   end
// 588: end
