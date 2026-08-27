module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/purl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :type, :name` at line 14.
pub fn ruby_purl_l14_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby attr_reader `attr_reader :type, :name` at line 14.
pub fn ruby_purl_l14_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :namespace, :version` at line 17.
pub fn ruby_purl_l17_d3_namespace(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('namespace', ...args)
}

// Ruby attr_reader `attr_reader :namespace, :version` at line 17.
pub fn ruby_purl_l17_d4_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `initialize(type:, name:, namespace: nil, version: nil)` at line 22.
pub fn ruby_purl_l22_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 36.
pub fn ruby_purl_l36_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `==(other)` at line 48.
pub fn ruby_purl_l48_d7_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('==', ...args)
}

// Ruby alias `alias eql? ==` at line 56.
pub fn ruby_purl_l56_d8_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eql?', ...args)
}

// Ruby method `hash` at line 59.
pub fn ruby_purl_l59_d9_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash', ...args)
}

// Ruby method `self.encode(component)` at line 67.
pub fn ruby_purl_l67_d10_self_encode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.encode', ...args)
}

// Ruby method `self.normalize(type, namespace, name)` at line 76.
pub fn ruby_purl_l76_d11_self_normalize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.normalize', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Vulns
// 6:     # A package URL per https://github.com/package-url/purl-spec.
// 7:     #
// 8:     # Minimal builder for the registry types Homebrew derives from formula
// 9:     # source URLs. Applies the spec's per-type name normalisation and RFC 3986
// 10:     # percent-encoding when serialised. Parsing, qualifiers and subpath are
// 11:     # intentionally omitted.
// 12:     class Purl
// 13:       sig { returns(String) }
// 14:       attr_reader :type, :name
// 15:
// 16:       sig { returns(T.nilable(String)) }
// 17:       attr_reader :namespace, :version
// 18:
// 19:       sig {
// 20:         params(type: String, name: String, namespace: T.nilable(String), version: T.nilable(String)).void
// 21:       }
// 22:       def initialize(type:, name:, namespace: nil, version: nil)
// 23:         raise ArgumentError, "type is required" if type.empty?
// 24:         raise ArgumentError, "name is required" if name.empty?
// 25:
// 26:         @type = T.let(type.downcase.freeze, String)
// 27:         namespace = nil if namespace && namespace.empty?
// 28:         namespace, name = self.class.normalize(@type, namespace, name)
// 29:         @namespace = T.let(namespace && -namespace, T.nilable(String))
// 30:         @name = T.let(-name, String)
// 31:         version = nil if version && version.empty?
// 32:         @version = T.let(version && -version, T.nilable(String))
// 33:       end
// 34:
// 35:       sig { returns(String) }
// 36:       def to_s
// 37:         purl = "pkg:#{@type}/"
// 38:         if @namespace
// 39:           purl << @namespace.split("/").reject(&:empty?).map { |s| self.class.encode(s) }.join("/")
// 40:           purl << "/"
// 41:         end
// 42:         purl << self.class.encode(@name)
// 43:         purl << "@#{self.class.encode(@version)}" if @version
// 44:         purl.freeze
// 45:       end
// 46:
// 47:       sig { params(other: T.anything).returns(T::Boolean) }
// 48:       def ==(other)
// 49:         case other
// 50:         when Purl
// 51:           type == other.type && namespace == other.namespace &&
// 52:             name == other.name && version == other.version
// 53:         else false
// 54:         end
// 55:       end
// 56:       alias eql? ==
// 57:
// 58:       sig { returns(Integer) }
// 59:       def hash
// 60:         [type, namespace, name, version].hash
// 61:       end
// 62:
// 63:       # Percent-encode a single purl component. The spec permits the RFC 3986
// 64:       # unreserved set plus `:` unencoded; `+` for space is forbidden so
// 65:       # `URI.encode_www_form_component` is unsuitable.
// 66:       sig { params(component: String).returns(String) }
// 67:       def self.encode(component)
// 68:         component.b.gsub(/[^A-Za-z0-9\-._~:]/n) { |c| format("%%%02X", c.ord) }
// 69:       end
// 70:
// 71:       # Per-type normalisation from purl-spec PURL-TYPES.rst for the types we emit.
// 72:       sig {
// 73:         params(type: String, namespace: T.nilable(String), name: String)
// 74:           .returns([T.nilable(String), String])
// 75:       }
// 76:       def self.normalize(type, namespace, name)
// 77:         case type
// 78:         when "pypi"
// 79:           [namespace, name.downcase.tr("_", "-")]
// 80:         when "hex"
// 81:           [namespace&.downcase, name.downcase]
// 82:         when "cpan"
// 83:           [namespace&.upcase, name]
// 84:         else
// 85:           [namespace, name]
// 86:         end
// 87:       end
// 88:     end
// 89:   end
// 90: end
