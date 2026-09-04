module homebrew

import ruby
import crypto.sha256
import homebrew.unpack_strategy
import os
import time

// Translated from Homebrew/brew `external_patch.rb`.
pub struct ExternalPatch {
pub mut:
	resource  PatchResourceModel
	owner     string
	has_owner bool
	version   string
pub:
	strip string
}

pub fn new_external_patch(strip string, resource PatchResourceModel) !ExternalPatch {
	if resource.has_patch_type {
		parse_patch_type(resource.patch_type_name)!
	}
	return ExternalPatch{
		strip: strip
		resource: resource
	}
}

pub fn external_patch_from_model(model PatchModel) !ExternalPatch {
	if model.kind != .external {
		return error('ExternalPatch requires an external Patch model')
	}
	return new_external_patch(model.strip, model.resource)
}

pub fn (patch ExternalPatch) model() PatchModel {
	return PatchModel{
		kind: .external
		strip: patch.strip
		resource: patch.resource
		has_patch_type: patch.resource.has_patch_type
		patch_type: if patch.resource.has_patch_type {
			parse_patch_type(patch.resource.patch_type_name) or { PatchType.unofficial }
		} else {
			PatchType.unofficial
		}
	}
}

pub fn (patch ExternalPatch) url() string {
	return patch.resource.url
}

pub fn (patch ExternalPatch) patch_files() []string {
	return patch.resource.patch_files.clone()
}

pub fn (patch ExternalPatch) cached_download() string {
	if patch.resource.cached_download_path != '' {
		return patch.resource.cached_download_path
	}
	if patch.resource.url.starts_with('file://') {
		return patch.resource.url['file://'.len..]
	}
	return ''
}

pub fn (patch ExternalPatch) downloaded() bool {
	path := patch.cached_download()
	return path != '' && os.is_file(path)
}

pub fn (patch ExternalPatch) verify_download_integrity(path string) ! {
	if patch.resource.checksum == '' || !os.is_file(path) {
		return
	}
	actual := sha256.sum256(os.read_bytes(path)!).hex()
	if actual != patch.resource.checksum {
		return error('SHA-256 mismatch for ${path}: expected ${patch.resource.checksum}, got ${actual}')
	}
}

pub fn (patch ExternalPatch) fetch() !string {
	path := patch.cached_download()
	if path == '' || !os.is_file(path) {
		return error('Patch download is unavailable: ${patch.resource.url}')
	}
	patch.verify_download_integrity(path)!
	return path
}

pub fn (mut patch ExternalPatch) clear_cache() ! {
	path := patch.resource.cached_download_path
	if path != '' && os.exists(path) {
		os.rm(path)!
	}
}

pub fn (patch ExternalPatch) external() bool {
	return true
}

pub fn (patch ExternalPatch) resolved_identifiers() []string {
	return patch.model().resolves()
}

pub fn (patch ExternalPatch) type_name() ?string {
	if patch.resource.has_patch_type {
		return patch.resource.patch_type_name
	}
	return none
}

fn external_patch_url_encode(value string) string {
	mut encoded := ''
	hex := '0123456789ABCDEF'
	for character in value.bytes() {
		if character.is_alnum() || character in [`-`, `_`, `.`, `~`] {
			encoded += character.ascii_str()
		} else {
			encoded += '%${hex[int(character >> 4)].ascii_str()}${hex[int(character & 15)].ascii_str()}'
		}
	}
	return encoded
}

pub fn (patch ExternalPatch) with_owner(owner ?string) ExternalPatch {
	if actual := owner {
		return ExternalPatch{
			...patch
			owner: actual
			has_owner: true
			version: if patch.resource.checksum != '' {
				patch.resource.checksum
			} else {
				external_patch_url_encode(patch.resource.url)
			}
		}
	}
	return ExternalPatch{
		...patch
		owner: ''
		has_owner: false
		version: if patch.resource.checksum != '' {
			patch.resource.checksum
		} else {
			external_patch_url_encode(patch.resource.url)
		}
	}
}

fn external_patch_unpack(path string, destination string) !string {
	os.mkdir_all(destination)!
	strategy := unpack_strategy.detect(path, unpack_strategy.DetectOptions{
		prioritize_extension: true
	})
	strategy.extract_nestedly(unpack_strategy.ExtractOptions{
		destination: destination
		basename: os.base(path)
		prioritize_extension: true
	})!
	mut children := os.ls(destination)!
	children.sort()
	if children.len == 1 && os.is_dir(os.join_path(destination, children[0])) {
		return os.join_path(destination, children[0])
	}
	return destination
}

pub fn (patch ExternalPatch) apply(base_dir string, homebrew_prefix string) ![]string {
	if !os.is_dir(base_dir) {
		return error('Patch base directory does not exist: ${base_dir}')
	}
	download := patch.fetch()!
	staging := os.join_path(os.temp_dir(), 'brew-v-external-patch-${os.getpid()}-${time.now().unix_nano()}')
	defer { os.rmdir_all(staging) or {} }
	patch_dir := external_patch_unpack(download, staging)!
	mut patch_files := patch.resource.patch_files.clone()
	if patch_files.len == 0 {
		children := os.ls(patch_dir)!
		if children.len != 1 || !os.is_file(os.join_path(patch_dir, children[0])) {
			return error('There should be exactly one patch file in the staging directory unless\nthe "apply" method was used one or more times in the patch-do block.')
		}
		patch_files << children[0]
	}
	target := if patch.resource.directory != '' {
		os.join_path(base_dir, patch.resource.directory)
	} else {
		base_dir
	}
	mut applied := []string{}
	for patch_file in patch_files {
		path := os.join_path(patch_dir, patch_file)
		if !os.is_file(path) {
			return error('No such file or directory: ${path}')
		}
		contents := os.read_file(path)!
		apply_patch_text(contents, patch.strip, target, homebrew_prefix)!
		applied << patch_file
	}
	return applied
}

pub fn (patch ExternalPatch) inspect() string {
	return '#<ExternalPatch: :${patch.strip} "${patch.resource.url}">'
}

fn external_patch_value(patch ExternalPatch) ruby.Value {
	model_value := patch_model_value(patch.model())
	mut attributes := model_value.attributes.clone()
	attributes['owner'] = patch.owner
	attributes['has_owner'] = patch.has_owner.str()
	attributes['version'] = patch.version
	return ruby.structured_value('ExternalPatch', patch.inspect(), attributes)
}

fn external_patch_from_value(value ruby.Value) !ExternalPatch {
	model := patch_model_from_value(value)!
	mut patch := external_patch_from_model(model)!
	if (value.attributes['has_owner'] or { 'false' }) == 'true' {
		patch = patch.with_owner(value.attributes['owner'] or { '' })
	}
	return patch
}
