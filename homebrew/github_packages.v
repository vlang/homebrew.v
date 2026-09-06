module homebrew

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
