module homebrew

import ruby
import crypto.sha256
import homebrew.unpack_strategy
import os
import time

// Translated from Homebrew/brew `external_patch.rb`.
// The original source is retained below until every stub has a typed V body.
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
			parse_patch_type(patch.resource.patch_type_name) or { PatchType.unofficial }} else {
			PatchType.unofficial}
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

// Ruby attr_reader `attr_reader :resource` at line 16.
pub fn ruby_external_patch_l16_d1_resource(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.map_value({
		'url':       ruby.string_value(patch.resource.url)
		'apply':     ruby.string_array_value(patch.resource.patch_files)
		'directory': ruby.string_value(patch.resource.directory)
		'sha256':    ruby.string_value(patch.resource.checksum)
	})
}

// Ruby attr_reader `attr_reader :strip` at line 19.
pub fn ruby_external_patch_l19_d2_strip(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.object_value('Symbol', patch.strip)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d3_url(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.url())
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d4_fetch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.fetch() or { return ruby.object_value('ErrorDuringExecution', err.msg()) })
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d5_patch_files(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_array_value(patch.patch_files())
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d6_verify_download_integrity(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	path := if args.len > 1 { args[1].as_string() } else { patch.cached_download() }
	patch.verify_download_integrity(path) or { return ruby.object_value('ChecksumMismatchError', err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d7_cached_download(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.cached_download())
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d8_downloaded(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.bool_value(patch.downloaded())
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d9_clear_cache(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	mut patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	patch.clear_cache() or { return ruby.object_value('ErrorDuringExecution', err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `initialize(strip, &block)` at line 26.
pub fn ruby_external_patch_l26_d10_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'strip is required')
	}
	config := if args.len > 1 { args[1] } else { ruby.map_value({}) }
	model_value := ruby_patch_l73_d4_self_create(ruby.object_value('Symbol', args[0].as_string()), ruby.object_value('NilClass', ''), config)
	model := patch_model_from_value(model_value) or { return ruby.object_value('ArgumentError', err.msg()) }
	patch := external_patch_from_model(model) or { return ruby.object_value('ArgumentError', err.msg()) }
	return external_patch_value(patch)
}

// Ruby method `external?` at line 32.
pub fn ruby_external_patch_l32_d11_external(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0)
}

// Ruby method `resolves` at line 37.
pub fn ruby_external_patch_l37_d12_resolves(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_array_value(patch.resolved_identifiers())
}

// Ruby method `type` at line 42.
pub fn ruby_external_patch_l42_d13_type(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	if name := patch.type_name() {
		return ruby.object_value('Symbol', name)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `owner=(owner)` at line 47.
pub fn ruby_external_patch_l47_d14_owner(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'receiver is required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	owner := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	return external_patch_value(patch.with_owner(if owner == '' { none } else { owner }))
}

// Ruby method `apply` at line 53.
pub fn ruby_external_patch_l53_d15_apply(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'receiver and base directory are required')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	applied := patch.apply(args[1].as_string(), if args.len > 2 {
		args[2].as_string()
	} else {
		'/opt/homebrew'
	}) or {
		name := if err.msg().starts_with('There should be exactly one patch file') {
			'MissingApplyError'
		} else if err.msg().starts_with('No such file') { 'Errno::ENOENT' } else { 'BuildError' }
		return ruby.object_value(name, err.msg())
	}
	return ruby.string_array_value(applied)
}

// Ruby method `inspect` at line 95.
pub fn ruby_external_patch_l95_d16_inspect(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	patch := external_patch_from_value(args[0]) or { return ruby.object_value('ArgumentError', err.msg()) }
	return ruby.string_value(patch.inspect())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "erb"
// 5: require "forwardable"
// 6: require "resource"
// 7: require "utils/output"
// 8:
// 9: # A file containing a patch.
// 10: class ExternalPatch
// 11:   include Utils::Output::Mixin
// 12:
// 13:   extend Forwardable
// 14:
// 15:   sig { returns(Resource::Patch) }
// 16:   attr_reader :resource
// 17:
// 18:   sig { returns(T.any(String, Symbol)) }
// 19:   attr_reader :strip
// 20:
// 21:   def_delegators :resource,
// 22:                  :url, :fetch, :patch_files, :verify_download_integrity,
// 23:                  :cached_download, :downloaded?, :clear_cache
// 24:
// 25:   sig { params(strip: T.any(String, Symbol), block: T.nilable(T.proc.bind(Resource::Patch).void)).void }
// 26:   def initialize(strip, &block)
// 27:     @strip    = strip
// 28:     @resource = T.let(Resource::Patch.new(&block), Resource::Patch)
// 29:   end
// 30:
// 31:   sig { returns(T::Boolean) }
// 32:   def external?
// 33:     true
// 34:   end
// 35:
// 36:   sig { returns(T::Array[String]) }
// 37:   def resolves
// 38:     (resource.resolves + Patch.extract_cves(url.to_s, *resource.patch_files.map(&:to_s))).uniq
// 39:   end
// 40:
// 41:   sig { returns(T.nilable(Symbol)) }
// 42:   def type
// 43:     resource.type
// 44:   end
// 45:
// 46:   sig { params(owner: T.nilable(Resource::Owner)).void }
// 47:   def owner=(owner)
// 48:     resource.owner = owner
// 49:     resource.version(resource.checksum&.hexdigest || ERB::Util.url_encode(resource.url))
// 50:   end
// 51:
// 52:   sig { void }
// 53:   def apply
// 54:     base_dir = Pathname.pwd
// 55:     resource.unpack do
// 56:       patch_dir = Pathname.pwd
// 57:       if patch_files.empty?
// 58:         children = patch_dir.children
// 59:         if children.length != 1 || !children.fetch(0).file?
// 60:           raise MissingApplyError, <<~EOS
// 61:             There should be exactly one patch file in the staging directory unless
// 62:             the "apply" method was used one or more times in the patch-do block.
// 63:           EOS
// 64:         end
// 65:
// 66:         patch_files << children.fetch(0).basename
// 67:       end
// 68:       dir = base_dir
// 69:       dir /= T.must(resource.directory) if resource.directory.present?
// 70:       dir.cd do
// 71:         patch_files.each do |patch_file|
// 72:           ohai "Applying #{patch_file}"
// 73:           patch_file = patch_dir/patch_file
// 74:           Patch.ensure_targets_within!(
// 75:             patch_file.read.gsub("@@HOMEBREW_PREFIX@@", HOMEBREW_PREFIX), strip:, base: dir
// 76:           )
// 77:           Utils.safe_popen_write("patch", "-g", "0", "-f", "-#{strip}") do |p|
// 78:             File.foreach(patch_file) do |line|
// 79:               data = line.gsub("@@HOMEBREW_PREFIX@@", HOMEBREW_PREFIX)
// 80:               p.write(data)
// 81:             end
// 82:           end
// 83:         end
// 84:       end
// 85:     end
// 86:   rescue ErrorDuringExecution => e
// 87:     onoe e
// 88:     spec_owner = T.cast(T.must(resource.owner), SoftwareSpec).owner
// 89:     f = spec_owner.is_a?(::Formula) ? spec_owner : nil
// 90:     cmd, *args = e.cmd
// 91:     raise BuildError.new(f, cmd, args, ENV.to_hash)
// 92:   end
// 93:
// 94:   sig { returns(String) }
// 95:   def inspect
// 96:     "#<#{self.class.name}: #{strip.inspect} #{url.inspect}>"
// 97:   end
// 98: end
