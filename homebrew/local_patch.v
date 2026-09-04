module homebrew

import ruby
import os

// Translated from Homebrew/brew `local_patch.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :file` at line 9.
pub fn ruby_local_patch_l9_d1_file(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.file)
}

// Ruby attr_reader `attr_reader :owner` at line 12.
pub fn ruby_local_patch_l12_d2_owner(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	if !patch.has_owner {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.structured_value('SoftwareSpec', patch.owner.software_spec_name, {
		'formula_path': patch.owner.formula_path
	})
}

// Ruby method `self.valid_path?(path_string)` at line 15.
pub fn ruby_local_patch_l15_d3_self_valid_path(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && valid_local_patch_path(args[0].as_string()))
}

// Ruby attr_reader `attr_reader :type` at line 25.
pub fn ruby_local_patch_l25_d4_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return if patch.type_name == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.object_value('Symbol', patch.type_name)
	}
}

// Ruby method `initialize(strip, file, directory = nil, resolves: [], type: nil)` at line 36.
pub fn ruby_local_patch_l36_d5_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'strip and file are required')
	}
	patch := new_local_patch(args[0].as_string(), args[1].as_string(), if args.len > 2 {
		args[2].as_string()
	} else {
		''
	}, if args.len > 3 { args[3].string_array_data } else { []string{} }, if args.len > 4 {
		args[4].as_string()
	} else {
		''
	}) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return local_patch_value(patch)
}

// Ruby method `resolves` at line 45.
pub fn ruby_local_patch_l45_d6_resolves(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_array_value(patch.resolved_identifiers())
}

// Ruby method `filename = file.to_s.delete_prefix("Patches/")` at line 50.
pub fn ruby_local_patch_l50_d7_filename(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.filename())
}

// Ruby method `contents` at line 53.
pub fn ruby_local_patch_l53_d8_contents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	mut patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	if args.len > 1 {
		owner := args[1]
		patch = patch.with_owner(LocalPatchOwner{
			formula_path: owner.attributes['formula_path'] or { owner.repr }
			specified_path: owner.attributes['specified_path'] or { '' }
			tap_path: owner.attributes['tap_path'] or { '' }
			api_source_root: owner.attributes['api_source_root'] or { '' }
			cache_downloads: owner.attributes['cache_downloads'] or { '' }
			is_formula: (owner.attributes['is_formula'] or { 'true' }) == 'true'
			software_spec_name: owner.attributes['software_spec_name'] or { '' }
		})
	}
	return ruby.string_value(patch.contents() or {
		return ruby.object_value('ArgumentError', err.msg())
	})
}

// Ruby method `inspect` at line 86.
pub fn ruby_local_patch_l86_d9_inspect(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	patch := local_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.inspect())
}

// Ruby method `api_source_repository_path(path)` at line 93.
pub fn ruby_local_patch_l93_d10_api_source_repository_path(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', 'nil')
	}
	if path := local_patch_api_source_repository_path(args[0].as_string(), args[1].as_string()) {
		return ruby.string_value(path)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5:
// 6: # A patch file stored locally within a formula repository.
// 7: class LocalPatch < EmbeddedPatch
// 8:   sig { returns(T.any(String, Pathname)) }
// 9:   attr_reader :file
// 10:
// 11:   sig { returns(T.nilable(Resource::Owner)) }
// 12:   attr_reader :owner
// 13:
// 14:   sig { params(path_string: String).returns(T::Boolean) }
// 15:   def self.valid_path?(path_string)
// 16:     path = Pathname(path_string).cleanpath
// 17:     path_string.present? &&
// 18:       !path_string.end_with?("/") &&
// 19:       !path.absolute? &&
// 20:       %w[. ..].exclude?(path.to_s) &&
// 21:       !path.to_s.start_with?("../")
// 22:   end
// 23:
// 24:   sig { returns(T.nilable(Symbol)) }
// 25:   attr_reader :type
// 26:
// 27:   sig {
// 28:     params(
// 29:       strip:     T.any(String, Symbol),
// 30:       file:      T.any(String, Pathname),
// 31:       directory: T.nilable(T.any(String, Pathname)),
// 32:       resolves:  T::Array[String],
// 33:       type:      T.nilable(Symbol),
// 34:     ).void
// 35:   }
// 36:   def initialize(strip, file, directory = nil, resolves: [], type: nil)
// 37:     super(strip)
// 38:     @file = file
// 39:     self.directory = directory
// 40:     @resolves = T.let(resolves.dup, T::Array[String])
// 41:     @type = type
// 42:   end
// 43:
// 44:   sig { returns(T::Array[String]) }
// 45:   def resolves
// 46:     (@resolves + Patch.extract_cves(file.to_s)).uniq
// 47:   end
// 48:
// 49:   sig { override.returns(String) }
// 50:   def filename = file.to_s.delete_prefix("Patches/")
// 51:
// 52:   sig { override.returns(String) }
// 53:   def contents
// 54:     owner = self.owner
// 55:     raise ArgumentError, "LocalPatch#contents called before owner was set!" unless owner
// 56:
// 57:     formula = T.cast(owner, SoftwareSpec).owner
// 58:     raise ArgumentError, "LocalPatch#contents requires a formula owner!" unless formula.is_a?(::Formula)
// 59:
// 60:     formula_path = formula.specified_path || formula.path
// 61:     api_repository_path = api_source_repository_path(formula_path)
// 62:     repository_path = api_repository_path || formula.tap&.path || formula_path.dirname
// 63:     file_path = repository_path/Pathname(file)
// 64:     repository_realpath = repository_path.realpath
// 65:     file_realpath = begin
// 66:       file_path.realpath
// 67:     rescue Errno::ENOENT
// 68:       raise ArgumentError, "Patch file does not exist: #{file}"
// 69:     end
// 70:     if file_realpath.ascend.none?(repository_realpath) &&
// 71:        !(api_repository_path &&
// 72:          begin
// 73:            file_path.expand_path.ascend.any?(api_repository_path.expand_path) &&
// 74:              file_realpath.ascend.any?((HOMEBREW_CACHE/"downloads").realpath)
// 75:          rescue Errno::ENOENT
// 76:            false
// 77:          end)
// 78:       raise ArgumentError, "Patch file must be within the formula repository."
// 79:     end
// 80:     raise ArgumentError, "Patch file must be a file: #{file}" unless file_realpath.file?
// 81:
// 82:     file_realpath.read
// 83:   end
// 84:
// 85:   sig { override.returns(String) }
// 86:   def inspect
// 87:     "#<#{self.class.name}: #{strip.inspect} #{file.inspect}>"
// 88:   end
// 89:
// 90:   private
// 91:
// 92:   sig { params(path: Pathname).returns(T.nilable(Pathname)) }
// 93:   def api_source_repository_path(path)
// 94:     source_root = if defined?(Homebrew::API::HOMEBREW_CACHE_API_SOURCE)
// 95:       Homebrew::API::HOMEBREW_CACHE_API_SOURCE
// 96:     else
// 97:       HOMEBREW_CACHE/"api-source"
// 98:     end.expand_path
// 99:     relative_path = path.expand_path.relative_path_from(source_root)
// 100:     return if relative_path.to_s.start_with?("../")
// 101:
// 102:     path_parts = relative_path.each_filename.to_a.first(3)
// 103:     return if path_parts.length < 3
// 104:
// 105:     source_root/path_parts.fetch(0)/path_parts.fetch(1)/path_parts.fetch(2)
// 106:   rescue ArgumentError
// 107:     nil
// 108:   end
// 109: end
