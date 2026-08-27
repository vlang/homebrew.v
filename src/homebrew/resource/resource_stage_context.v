module resource

import brew_runtime

// Translated from Homebrew/brew `resource/resource_stage_context.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :resource` at line 12.
pub fn ruby_resource_stage_context_l12_d1_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby attr_reader `attr_reader :staging` at line 16.
pub fn ruby_resource_stage_context_l16_d2_staging(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staging', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d3_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d4_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d5_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mirrors', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d6_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d7_using(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('using', ...args)
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d8_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_modified_time', ...args)
}

// Ruby def_delegators `def_delegators :@staging, :retain!` at line 19.
pub fn ruby_resource_stage_context_l19_d9_retain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retain!', ...args)
}

// Ruby method `initialize(resource, staging)` at line 22.
pub fn ruby_resource_stage_context_l22_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 28.
pub fn ruby_resource_stage_context_l28_d11_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # The context in which a {Resource#stage} occurs. Supports access to both
// 5: # the {Resource} and associated {Mktemp} in a single block argument. The interface
// 6: # is back-compatible with {Resource} itself as used in that context.
// 7: class ResourceStageContext
// 8:   extend Forwardable
// 9:
// 10:   # The {Resource} that is being staged.
// 11:   sig { returns(Resource) }
// 12:   attr_reader :resource
// 13:
// 14:   # The {Mktemp} in which {#resource} is staged.
// 15:   sig { returns(Mktemp) }
// 16:   attr_reader :staging
// 17:
// 18:   def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time
// 19:   def_delegators :@staging, :retain!
// 20:
// 21:   sig { params(resource: Resource, staging: Mktemp).void }
// 22:   def initialize(resource, staging)
// 23:     @resource = resource
// 24:     @staging = staging
// 25:   end
// 26:
// 27:   sig { returns(String) }
// 28:   def to_s
// 29:     "<#{self.class}: resource=#{resource} staging=#{staging}>"
// 30:   end
// 31: end
