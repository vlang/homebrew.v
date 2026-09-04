module homebrew

import ruby
import os

// Translated from Homebrew/brew `local_patch.rb`.
pub struct LocalPatchOwner {
pub:
	formula_path       string
	specified_path     string
	tap_path           string
	api_source_root    string
	cache_downloads    string
	is_formula         bool = true
	software_spec_name string
}

pub struct LocalPatch {
pub:
	embedded  EmbeddedPatch
	file      string
	resolves  []string
	type_name string
	owner     LocalPatchOwner
	has_owner bool
}

pub fn new_local_patch(strip string, file string, directory string, resolves []string,
	type_name string) !LocalPatch {
	if !valid_local_patch_path(file) {
		return error('Patch file must be a relative path within the repository.')
	}
	mut embedded := new_embedded_patch(strip)
	if directory != '' {
		embedded = embedded.with_directory(directory)
	}
	if type_name != '' {
		parse_patch_type(type_name)!
	}
	return LocalPatch{
		embedded: embedded
		file: file
		resolves: resolves.clone()
		type_name: type_name
	}
}

pub fn (patch LocalPatch) with_owner(owner LocalPatchOwner) LocalPatch {
	return LocalPatch{
		...patch
		embedded: patch.embedded.with_owner(owner.software_spec_name)
		owner: owner
		has_owner: true
	}
}

pub fn (patch LocalPatch) resolved_identifiers() []string {
	mut identifiers := patch.resolves.clone()
	for identifier in extract_cves([patch.file]) {
		if identifier !in identifiers {
			identifiers << identifier
		}
	}
	return identifiers
}

pub fn (patch LocalPatch) filename() string {
	return if patch.file.starts_with('Patches/') {
		patch.file['Patches/'.len..]
	} else {
		patch.file
	}
}

fn local_patch_path_within(path string, parent string) bool {
	normalized_path := os.norm_path(os.abs_path(path))
	normalized_parent := os.norm_path(os.abs_path(parent)).trim_string_right(os.path_separator)
	return normalized_path == normalized_parent || normalized_path.starts_with('${normalized_parent}${os.path_separator}')
}

pub fn local_patch_api_source_repository_path(path string, source_root string) ?string {
	if source_root == '' {
		return none
	}
	absolute_path := os.norm_path(os.abs_path(path))
	absolute_root := os.norm_path(os.abs_path(source_root)).trim_string_right(os.path_separator)
	if !local_patch_path_within(absolute_path, absolute_root) {
		return none
	}
	prefix := '${absolute_root}${os.path_separator}'
	relative := absolute_path[prefix.len..]
	parts := relative.split(os.path_separator)
	if parts.len < 3 {
		return none
	}
	return os.join_path(absolute_root, parts[0], parts[1], parts[2])
}

pub fn (patch LocalPatch) contents() !string {
	if !patch.has_owner {
		return error('LocalPatch#contents called before owner was set!')
	}
	if !patch.owner.is_formula {
		return error('LocalPatch#contents requires a formula owner!')
	}
	formula_path := if patch.owner.specified_path != '' {
		patch.owner.specified_path
	} else {
		patch.owner.formula_path
	}
	api_repository_path := local_patch_api_source_repository_path(formula_path, patch.owner.api_source_root)
	repository_path := api_repository_path or {
		if patch.owner.tap_path != '' { patch.owner.tap_path } else { os.dir(formula_path) }
	}
	file_path := os.join_path(repository_path, patch.file)
	if !os.exists(file_path) {
		return error('Patch file does not exist: ${patch.file}')
	}
	repository_realpath := os.real_path(repository_path)
	file_realpath := os.real_path(file_path)
	mut allowed := local_patch_path_within(file_realpath, repository_realpath)
	if !allowed {
		if actual_api_path := api_repository_path {
			candidate_within_api := local_patch_path_within(file_path, actual_api_path)
			cache_exists := patch.owner.cache_downloads != '' && os.exists(patch.owner.cache_downloads)
			allowed = candidate_within_api && cache_exists && local_patch_path_within(file_realpath, os.real_path(patch.owner.cache_downloads))
		}
	}
	if !allowed {
		return error('Patch file must be within the formula repository.')
	}
	if !os.is_file(file_realpath) {
		return error('Patch file must be a file: ${patch.file}')
	}
	return os.read_file(file_realpath)!
}

pub fn (patch LocalPatch) inspect() string {
	return '#<LocalPatch: :${patch.embedded.strip} "${patch.file}">'
}

pub fn local_patch_from_model(model PatchModel, owner LocalPatchOwner) !LocalPatch {
	mut patch := new_local_patch(model.strip, model.file, model.directory, model.resource.explicit_resolves, if model.has_patch_type {
		model.patch_type.str()
	} else {
		''
	})!
	patch = patch.with_owner(owner)
	return patch
}

fn local_patch_value(patch LocalPatch) ruby.Value {
	return ruby.structured_value('LocalPatch', patch.inspect(), {
		'strip':              patch.embedded.strip
		'file':               patch.file
		'directory':          patch.embedded.directory
		'resolves':           patch.resolves.join('\x1f')
		'type':               patch.type_name
		'has_owner':          patch.has_owner.str()
		'formula_path':       patch.owner.formula_path
		'specified_path':     patch.owner.specified_path
		'tap_path':           patch.owner.tap_path
		'api_source_root':    patch.owner.api_source_root
		'cache_downloads':    patch.owner.cache_downloads
		'is_formula':         patch.owner.is_formula.str()
		'software_spec_name': patch.owner.software_spec_name
	})
}

fn local_patch_from_value(value ruby.Value) !LocalPatch {
	mut patch := new_local_patch(value.attributes['strip'] or { 'p1' }, value.attributes['file'] or { '' }, value.attributes['directory'] or { '' }, if (value.attributes['resolves'] or { '' }) == '' {
		[]string{}
	} else {
		value.attributes['resolves'].split('\x1f')
	}, value.attributes['type'] or { '' })!
	if (value.attributes['has_owner'] or { 'false' }) == 'true' {
		patch = patch.with_owner(LocalPatchOwner{
			formula_path: value.attributes['formula_path'] or { '' }
			specified_path: value.attributes['specified_path'] or { '' }
			tap_path: value.attributes['tap_path'] or { '' }
			api_source_root: value.attributes['api_source_root'] or { '' }
			cache_downloads: value.attributes['cache_downloads'] or { '' }
			is_formula: (value.attributes['is_formula'] or { 'true' }) == 'true'
			software_spec_name: value.attributes['software_spec_name'] or { '' }
		})
	}
	return patch
}
