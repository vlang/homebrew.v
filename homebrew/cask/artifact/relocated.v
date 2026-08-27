module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/relocated.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.from_args(cask, source_string, target_hash = nil)` at line 18.
pub fn ruby_relocated_l18_d1_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_args', ...args)
}

// Ruby method `resolve_target(target, base_dir: config.public_send(self.class.dirmethod))` at line 31.
pub fn ruby_relocated_l31_d2_resolve_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_target', ...args)
}

// Ruby method `initialize(cask, source, **target_hash)` at line 46.
pub fn ruby_relocated_l46_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `source` at line 57.
pub fn ruby_relocated_l57_d4_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby method `target` at line 66.
pub fn ruby_relocated_l66_d5_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target', ...args)
}

// Ruby method `to_a` at line 71.
pub fn ruby_relocated_l71_d6_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_a', ...args)
}

// Ruby method `summarize` at line 78.
pub fn ruby_relocated_l78_d7_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `add_altname_metadata(file, altname, command:)` at line 87.
pub fn ruby_relocated_l87_d8_add_altname_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_altname_metadata', ...args)
}

// Ruby method `printable_target` at line 116.
pub fn ruby_relocated_l116_d9_printable_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('printable_target', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5: require "extend/hash/keys"
// 6:
// 7: module Cask
// 8:   module Artifact
// 9:     # Superclass for all artifacts which have a source and a target location.
// 10:     class Relocated < AbstractArtifact
// 11:       sig {
// 12:         overridable.params(
// 13:           cask:          Cask,
// 14:           source_string: T.any(String, Pathname),
// 15:           target_hash:   T.untyped,
// 16:         ).returns(T.attached_class)
// 17:       }
// 18:       def self.from_args(cask, source_string, target_hash = nil)
// 19:         if target_hash
// 20:           raise CaskInvalidError, cask unless target_hash.respond_to?(:keys)
// 21:
// 22:           target_hash.assert_valid_keys(:target)
// 23:         end
// 24:
// 25:         target_hash ||= {}
// 26:
// 27:         new(cask, source_string, **target_hash)
// 28:       end
// 29:
// 30:       sig { overridable.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 31:       def resolve_target(target, base_dir: config.public_send(self.class.dirmethod))
// 32:         target = Pathname(target)
// 33:
// 34:         if target.relative?
// 35:           return target.expand_path if target.descend.first.to_s == "~"
// 36:           return base_dir/target if base_dir
// 37:         end
// 38:
// 39:         target
// 40:       end
// 41:
// 42:       sig {
// 43:         params(cask: Cask, source: T.any(String, Pathname), target_hash: T.any(String, Pathname))
// 44:           .void
// 45:       }
// 46:       def initialize(cask, source, **target_hash)
// 47:         super
// 48:
// 49:         target = target_hash[:target]
// 50:         @source = T.let(nil, T.nilable(Pathname))
// 51:         @source_string = T.let(source.to_s, String)
// 52:         @target = T.let(nil, T.nilable(Pathname))
// 53:         @target_string = T.let(target.to_s, String)
// 54:       end
// 55:
// 56:       sig { returns(Pathname) }
// 57:       def source
// 58:         @source ||= begin
// 59:           base_path = cask.staged_path
// 60:           base_path = base_path.join(T.must(cask.url).only_path) if cask.url&.only_path.present?
// 61:           base_path.join(@source_string)
// 62:         end
// 63:       end
// 64:
// 65:       sig { returns(Pathname) }
// 66:       def target
// 67:         @target ||= resolve_target(@target_string.presence || source.basename)
// 68:       end
// 69:
// 70:       sig { returns(T::Array[T.anything]) }
// 71:       def to_a
// 72:         [@source_string].tap do |ary|
// 73:           ary << { target: @target_string } unless @target_string.empty?
// 74:         end
// 75:       end
// 76:
// 77:       sig { override.returns(String) }
// 78:       def summarize
// 79:         target_string = @target_string.empty? ? "" : " -> #{@target_string}"
// 80:         "#{@source_string}#{target_string}"
// 81:       end
// 82:
// 83:       # Try to make the asset searchable under the target name. Spotlight
// 84:       # respects this attribute for many filetypes, but ignores it for App
// 85:       # bundles. Alfred 2.2 respects it even for App bundles.
// 86:       sig { params(file: Pathname, altname: Pathname, command: T.class_of(SystemCommand)).returns(T.nilable(SystemCommand::Result)) }
// 87:       def add_altname_metadata(file, altname, command:)
// 88:         return if altname.to_s.casecmp(file.basename.to_s)&.zero?
// 89:
// 90:         odebug "Adding #{ALT_NAME_ATTRIBUTE} metadata"
// 91:         altnames = command.run("/usr/bin/xattr",
// 92:                                args:         ["-p", ALT_NAME_ATTRIBUTE, file],
// 93:                                print_stderr: false).stdout.sub(/\A\((.*)\)\Z/, '\1')
// 94:         odebug "Existing metadata is: #{altnames}"
// 95:         altnames.concat(", ") unless altnames.empty?
// 96:         altnames.concat(%Q("#{altname}"))
// 97:         altnames = "(#{altnames})"
// 98:
// 99:         # Some packages are shipped as u=rx (e.g. Bitcoin Core)
// 100:         command.run!("chmod",
// 101:                      args: ["--", "u+rw", file, file.realpath],
// 102:                      sudo: !file.writable? || !file.realpath.writable?)
// 103:
// 104:         command.run!("/usr/bin/xattr",
// 105:                      args:         ["-w", ALT_NAME_ATTRIBUTE, altnames, file],
// 106:                      print_stderr: false,
// 107:                      sudo:         !file.writable?)
// 108:       end
// 109:
// 110:       private
// 111:
// 112:       ALT_NAME_ATTRIBUTE = "com.apple.metadata:kMDItemAlternateNames"
// 113:       private_constant :ALT_NAME_ATTRIBUTE
// 114:
// 115:       sig { returns(String) }
// 116:       def printable_target
// 117:         target.to_s.sub(/^#{Dir.home}(#{File::SEPARATOR}|$)/, "~/")
// 118:       end
// 119:     end
// 120:   end
// 121: end
// 122:
// 123: require "extend/os/cask/artifact/relocated"
