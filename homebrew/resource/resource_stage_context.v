module resource

import ruby
import homebrew

// Translated from Homebrew/brew `resource/resource_stage_context.rb`.

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
