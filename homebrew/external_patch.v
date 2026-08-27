module homebrew

import brew_runtime

// Translated from Homebrew/brew `external_patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :resource` at line 16.
pub fn ruby_external_patch_l16_d1_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby attr_reader `attr_reader :strip` at line 19.
pub fn ruby_external_patch_l19_d2_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d3_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d4_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d5_patch_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_files', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d6_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_download_integrity', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d7_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_download', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d8_downloaded(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloaded?', ...args)
}

// Ruby def_delegators `def_delegators :resource, :url, :fetch, :patch_files, :verify_download_integrity, :cached_download, :downloaded?, :clear_cache` at line 21.
pub fn ruby_external_patch_l21_d9_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_cache', ...args)
}

// Ruby method `initialize(strip, &block)` at line 26.
pub fn ruby_external_patch_l26_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `external?` at line 32.
pub fn ruby_external_patch_l32_d11_external(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('external?', ...args)
}

// Ruby method `resolves` at line 37.
pub fn ruby_external_patch_l37_d12_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolves', ...args)
}

// Ruby method `type` at line 42.
pub fn ruby_external_patch_l42_d13_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `owner=(owner)` at line 47.
pub fn ruby_external_patch_l47_d14_owner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('owner=', ...args)
}

// Ruby method `apply` at line 53.
pub fn ruby_external_patch_l53_d15_apply(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apply', ...args)
}

// Ruby method `inspect` at line 95.
pub fn ruby_external_patch_l95_d16_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
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
