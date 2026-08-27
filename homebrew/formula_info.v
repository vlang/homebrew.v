module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_info.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :info` at line 8.
pub fn ruby_formula_info_l8_d1_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('info', ...args)
}

// Ruby attr_accessor `attr_accessor :info` at line 8.
pub fn ruby_formula_info_l8_d2_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('info=', ...args)
}

// Ruby method `initialize(info)` at line 11.
pub fn ruby_formula_info_l11_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.lookup(name)` at line 18.
pub fn ruby_formula_info_l18_d4_self_lookup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lookup', ...args)
}

// Ruby method `bottle_tags` at line 34.
pub fn ruby_formula_info_l34_d5_bottle_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_tags', ...args)
}

// Ruby method `bottle_info(my_bottle_tag = Utils::Bottles.tag)` at line 43.
pub fn ruby_formula_info_l43_d6_bottle_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_info', ...args)
}

// Ruby method `bottle_info_any` at line 54.
pub fn ruby_formula_info_l54_d7_bottle_info_any(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_info_any', ...args)
}

// Ruby method `any_bottle_tag` at line 59.
pub fn ruby_formula_info_l59_d8_any_bottle_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_bottle_tag', ...args)
}

// Ruby method `version(spec_type)` at line 66.
pub fn ruby_formula_info_l66_d9_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `pkg_version(spec_type = :stable)` at line 72.
pub fn ruby_formula_info_l72_d10_pkg_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkg_version', ...args)
}

// Ruby method `revision` at line 77.
pub fn ruby_formula_info_l77_d11_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('revision', ...args)
}

// Ruby method `self.force_utf8!(str)` at line 82.
pub fn ruby_formula_info_l82_d12_self_force_utf8(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.force_utf8!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Formula information drawn from an external `brew info --json` call.
// 5: class FormulaInfo
// 6:   # The whole info structure parsed from the JSON.
// 7:   sig { returns(T::Hash[String, T.untyped]) }
// 8:   attr_accessor :info
// 9:
// 10:   sig { params(info: T::Hash[String, T.untyped]).void }
// 11:   def initialize(info)
// 12:     @info = info
// 13:   end
// 14:
// 15:   # Looks up formula on disk and reads its info.
// 16:   # Returns nil if formula is absent or if there was an error reading it.
// 17:   sig { params(name: Pathname).returns(T.nilable(FormulaInfo)) }
// 18:   def self.lookup(name)
// 19:     json = Utils.popen_read(
// 20:       *HOMEBREW_RUBY_EXEC_ARGS,
// 21:       HOMEBREW_LIBRARY_PATH/"brew.rb",
// 22:       "info",
// 23:       "--json=v1",
// 24:       name,
// 25:     )
// 26:
// 27:     return unless $CHILD_STATUS.success?
// 28:
// 29:     force_utf8!(json)
// 30:     FormulaInfo.new(JSON.parse(json)[0])
// 31:   end
// 32:
// 33:   sig { returns(T::Array[String]) }
// 34:   def bottle_tags
// 35:     return [] unless info["bottle"]["stable"]
// 36:
// 37:     info["bottle"]["stable"]["files"].keys
// 38:   end
// 39:
// 40:   sig {
// 41:     params(my_bottle_tag: T.any(Utils::Bottles::Tag, T.nilable(String))).returns(T.nilable(T::Hash[String, String]))
// 42:   }
// 43:   def bottle_info(my_bottle_tag = Utils::Bottles.tag)
// 44:     tag_s = my_bottle_tag.to_s
// 45:     return unless info["bottle"]["stable"]
// 46:
// 47:     btl_info = info["bottle"]["stable"]["files"][tag_s]
// 48:     return unless btl_info
// 49:
// 50:     { "url" => btl_info["url"], "sha256" => btl_info["sha256"] }
// 51:   end
// 52:
// 53:   sig { returns(T.nilable(T::Hash[String, String])) }
// 54:   def bottle_info_any
// 55:     bottle_info(any_bottle_tag)
// 56:   end
// 57:
// 58:   sig { returns(T.nilable(String)) }
// 59:   def any_bottle_tag
// 60:     tag = Utils::Bottles.tag.to_s
// 61:     # Prefer native bottles as a convenience for download caching
// 62:     bottle_tags.include?(tag) ? tag : bottle_tags.first
// 63:   end
// 64:
// 65:   sig { params(spec_type: Symbol).returns(Version) }
// 66:   def version(spec_type)
// 67:     version_str = info["versions"][spec_type.to_s]
// 68:     Version.new(version_str)
// 69:   end
// 70:
// 71:   sig { params(spec_type: Symbol).returns(PkgVersion) }
// 72:   def pkg_version(spec_type = :stable)
// 73:     PkgVersion.new(version(spec_type), revision)
// 74:   end
// 75:
// 76:   sig { returns(Integer) }
// 77:   def revision
// 78:     info["revision"]
// 79:   end
// 80:
// 81:   sig { params(str: String).void }
// 82:   def self.force_utf8!(str)
// 83:     str.force_encoding("UTF-8") if str.respond_to?(:force_encoding)
// 84:   end
// 85: end
