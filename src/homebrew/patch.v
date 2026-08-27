module homebrew

import brew_runtime

// Translated from Homebrew/brew `patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extract_cves(*strings)` at line 31.
pub fn ruby_patch_l31_d1_self_extract_cves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extract_cves', ...args)
}

// Ruby method `self.resolves_type(id)` at line 38.
pub fn ruby_patch_l38_d2_self_resolves_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.resolves_type', ...args)
}

// Ruby method `self.ensure_targets_within!(text, strip:, base:)` at line 46.
pub fn ruby_patch_l46_d3_self_ensure_targets_within(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ensure_targets_within!', ...args)
}

// Ruby method `self.create(strip, src, &block)` at line 73.
pub fn ruby_patch_l73_d4_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5: require "data_patch"
// 6: require "external_patch"
// 7: require "string_patch"
// 8: require "local_patch"
// 9: require "utils/path"
// 10: require "utils/popen"
// 11:
// 12: # Helper module for creating patches.
// 13: module Patch
// 14:   CVE_PATTERN = /CVE-?(\d{4})-(\d{4,})/i
// 15:   GHSA_PATTERN = /\AGHSA(-[23456789cfghjmpqrvwx]{4}){3}\z/
// 16:   OSV_PATTERN = /\AOSV-\d{4}-\d+\z/
// 17:   # CycloneDX `pedigree.patches.type` values applicable to source diffs.
// 18:   # `monkey` is omitted: it describes runtime modification, which `patch do` cannot express.
// 19:   # Keep in sync with `PATCH_TYPES` in `Library/Homebrew/rubocops/patches.rb`.
// 20:   TYPES = T.let({
// 21:     unofficial:  "A patch that has not been developed by the upstream maintainers " \
// 22:                  "(e.g. a Homebrew- or distribution-specific build fix).",
// 23:     backport:    "A patch that takes code from a newer version of the software and " \
// 24:                  "applies it to the older version Homebrew ships (e.g. an unreleased " \
// 25:                  "upstream security fix).",
// 26:     cherry_pick: "A patch created by selectively applying upstream commits that are " \
// 27:                  "not strictly from a newer release (e.g. a fix from a maintenance branch).",
// 28:   }.freeze, T::Hash[Symbol, String])
// 29:
// 30:   sig { params(strings: String).returns(T::Array[String]) }
// 31:   def self.extract_cves(*strings)
// 32:     strings.flat_map { |s| s.scan(CVE_PATTERN) }
// 33:            .map { |year, id| "CVE-#{year}-#{id}" }
// 34:            .uniq
// 35:   end
// 36:
// 37:   sig { params(id: String).returns(String) }
// 38:   def self.resolves_type(id)
// 39:     return "security" if id.match?(/\ACVE-\d{4}-\d{4,}\z/) || id.match?(GHSA_PATTERN) || id.match?(OSV_PATTERN)
// 40:
// 41:     "defect"
// 42:   end
// 43:
// 44:   # Reject patch target paths (absolute or `..`-traversing) that escape the staged source tree.
// 45:   sig { params(text: String, strip: T.any(Symbol, String), base: Pathname).void }
// 46:   def self.ensure_targets_within!(text, strip:, base:)
// 47:     # Resolve targets with `patch --dry-run` so containment matches what `patch`
// 48:     # actually writes, covering `Index:`/`====` and non-selected context headers.
// 49:     output = with_env(LC_ALL: "C", LANG: "C") do
// 50:       base.cd do
// 51:         Utils.popen_write("patch", "-g", "0", "-f", "-#{strip}", "--dry-run", err: :out) { |p| p.write(text) }
// 52:       end
// 53:     end
// 54:
// 55:     output.each_line do |line|
// 56:       next unless (target = line.chomp[/\A(?:patching|checking) file (.+)\z/, 1])
// 57:
// 58:       target = target.delete_prefix("'").delete_suffix("'") if target.start_with?("'") && target.end_with?("'")
// 59:       Utils::Path.ensure_child_of!(
// 60:         base, base/target,
// 61:         message: "Patch target path escapes the staged source tree: #{target}"
// 62:       )
// 63:     end
// 64:   end
// 65:
// 66:   sig {
// 67:     params(
// 68:       strip: T.any(Symbol, String),
// 69:       src:   T.nilable(T.any(Symbol, String)),
// 70:       block: T.nilable(T.proc.bind(Resource::Patch).void),
// 71:     ).returns(T.any(EmbeddedPatch, ExternalPatch))
// 72:   }
// 73:   def self.create(strip, src, &block)
// 74:     case strip
// 75:     when :DATA
// 76:       DATAPatch.new(:p1)
// 77:     when String
// 78:       StringPatch.new(:p1, strip)
// 79:     when Symbol
// 80:       case src
// 81:       when :DATA
// 82:         DATAPatch.new(strip)
// 83:       when String
// 84:         StringPatch.new(strip, src)
// 85:       else
// 86:         external_patch = ExternalPatch.new(strip, &block)
// 87:         resource = external_patch.resource
// 88:         if (file = resource.file)
// 89:           raise ArgumentError, "Patch cannot have both `file` and `url`." if resource.url.present?
// 90:           raise ArgumentError, "Patch cannot use `sha256` with `file`." if resource.checksum
// 91:           raise ArgumentError, "Patch cannot use `apply` with `file`." if resource.patch_files.present?
// 92:
// 93:           LocalPatch.new(strip, file, resource.directory, resolves: resource.resolves, type: resource.type)
// 94:         else
// 95:           external_patch
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
