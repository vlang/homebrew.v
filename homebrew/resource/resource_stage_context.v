module resource

import ruby
import homebrew

// Translated from Homebrew/brew `resource/resource_stage_context.rb`.
// The original source is retained below until every stub has a typed V body.

// ResourceStageContext keeps the two Ruby objects by identity. The generic
// Value boundary remains necessary while Resource#stage's block ABI is being
// translated, but the context itself has concrete state and delegates to the
// real translated Mktemp implementation.
@[heap]
pub struct ResourceStageContext {
pub:
	resource ruby.Value
	staging  ruby.Value
}

pub fn new_resource_stage_context(resource_value ruby.Value,
	staging_value ruby.Value) &ResourceStageContext {
	if resource_value.type_name != 'Resource' {
		panic('ResourceStageContext requires a Resource, got ${resource_value.type_name}')
	}
	if staging_value.type_name != 'Mktemp' {
		panic('ResourceStageContext requires a Mktemp, got ${staging_value.type_name}')
	}
	return &ResourceStageContext{
		resource: resource_value
		staging: staging_value
	}
}

fn resource_stage_string_map(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

// resource_stage_resource_boundary adapts the already typed Resource while
// its stage callback still crosses the generic translation boundary.
pub fn resource_stage_resource_boundary(resource_value &homebrew.Resource,
	representation string) ruby.Value {
	version := if value := resource_value.version() {
		ruby.object_value('Version', value.to_s())
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	url := if value := resource_value.url() {
		ruby.string_value(value)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	using := if value := resource_value.using() {
		ruby.object_value('Class', value)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	modified_time := if resource_value.has_source_modified_time {
		ruby.int_value(resource_value.source_modified_time)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return ruby.Value{
		type_name: 'Resource'
		repr: representation
		map_data: {
			'version':              version
			'url':                  url
			'mirrors':              ruby.string_array_value(resource_value.mirrors)
			'specs':                resource_stage_string_map(resource_value.specs())
			'using':                using
			'source_modified_time': modified_time
		}
	}
}

fn resource_stage_context_value(context &ResourceStageContext) ruby.Value {
	return ruby.structured_value('ResourceStageContext', context.str(), {
		'context_address': u64(voidptr(context)).str()
	})
}

fn resource_stage_context_from_args(args []ruby.Value,
	method string) &ResourceStageContext {
	if args.len == 0 || args[0].type_name != 'ResourceStageContext' {
		panic('ResourceStageContext#${method} requires a translated receiver')
	}
	address := args[0].attributes['context_address'] or {
		panic('ResourceStageContext receiver has no translated state')
	}
	return unsafe { &ResourceStageContext(voidptr(address.u64())) }
}

fn (context &ResourceStageContext) delegated_resource_value(name string) ruby.Value {
	return context.resource.map_data[name] or {
		panic('ResourceStageContext cannot delegate `${name}` to an incomplete Resource boundary')
	}
}

pub fn (context &ResourceStageContext) retain_files() {
	homebrew.ruby_mktemp_l27_d3_retain(context.staging)
}

pub fn (context &ResourceStageContext) str() string {
	return '<ResourceStageContext: resource=${context.resource.as_string()} staging=${context.staging.as_string()}>'
}

// Ruby attr_reader `attr_reader :resource` at line 12.
pub fn ruby_resource_stage_context_l12_d1_resource(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'resource').resource
}

// Ruby attr_reader `attr_reader :staging` at line 16.
pub fn ruby_resource_stage_context_l16_d2_staging(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'staging').staging
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d3_version(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'version').delegated_resource_value('version')
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d4_url(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'url').delegated_resource_value('url')
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d5_mirrors(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'mirrors').delegated_resource_value('mirrors')
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d6_specs(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'specs').delegated_resource_value('specs')
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d7_using(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'using').delegated_resource_value('using')
}

// Ruby def_delegators `def_delegators :@resource, :version, :url, :mirrors, :specs, :using, :source_modified_time` at line 18.
pub fn ruby_resource_stage_context_l18_d8_source_modified_time(args ...ruby.Value) ruby.Value {
	return resource_stage_context_from_args(args, 'source_modified_time').delegated_resource_value('source_modified_time')
}

// Ruby def_delegators `def_delegators :@staging, :retain!` at line 19.
pub fn ruby_resource_stage_context_l19_d9_retain(args ...ruby.Value) ruby.Value {
	context := resource_stage_context_from_args(args, 'retain!')
	context.retain_files()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `initialize(resource, staging)` at line 22.
pub fn ruby_resource_stage_context_l22_d10_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('ResourceStageContext#initialize requires resource and staging')
	}
	return resource_stage_context_value(new_resource_stage_context(args[0], args[1]))
}

// Ruby method `to_s` at line 28.
pub fn ruby_resource_stage_context_l28_d11_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(resource_stage_context_from_args(args, 'to_s').str())
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
