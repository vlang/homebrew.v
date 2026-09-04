module homebrew

import ruby
import homebrew.livecheck as livecheck_options

// Translated from Homebrew/brew `livecheck.rb`.
const livecheck_url_option_keys = ['compressed', 'cookies', 'header', 'homebrew_curl', 'post_form',
	'post_json', 'referer', 'user_agent']

pub struct LivecheckDSL {
pub mut:
	package_or_resource ruby.Value
	options             livecheck_options.LivecheckOptions
	referenced_cask     ruby.Value
	referenced_formula  ruby.Value
	regex               ruby.Value
	skip                bool
	skip_msg            ruby.Value
	strategy            ruby.Value
	strategy_block      ruby.Value
	throttle            ruby.Value
	throttle_days       ruby.Value
	url                 ruby.Value
}

fn livecheck_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_livecheck_dsl(package_or_resource ruby.Value) LivecheckDSL {
	return LivecheckDSL{
		package_or_resource: package_or_resource
		options: livecheck_options.new_livecheck_options({})
		referenced_cask: livecheck_nil()
		referenced_formula: livecheck_nil()
		regex: livecheck_nil()
		skip_msg: livecheck_nil()
		strategy: livecheck_nil()
		strategy_block: livecheck_nil()
		throttle: livecheck_nil()
		throttle_days: livecheck_nil()
		url: livecheck_nil()
	}
}

pub fn livecheck_dsl_value(livecheck LivecheckDSL) ruby.Value {
	return ruby.Value{
		type_name: 'Livecheck'
		repr: 'Livecheck'
		map_data: {
			'package_or_resource': livecheck.package_or_resource
			'options':             livecheck_options.livecheck_options_value(livecheck.options)
			'cask':                livecheck.referenced_cask
			'formula':             livecheck.referenced_formula
			'regex':               livecheck.regex
			'skip':                ruby.bool_value(livecheck.skip)
			'skip_msg':            livecheck.skip_msg
			'strategy':            livecheck.strategy
			'strategy_block':      livecheck.strategy_block
			'throttle':            livecheck.throttle
			'throttle_days':       livecheck.throttle_days
			'url':                 livecheck.url
		}
	}
}

pub fn livecheck_dsl_from_value(value ruby.Value) !LivecheckDSL {
	if value.type_name != 'Livecheck' {
		return error('expected Livecheck, got ${value.type_name}')
	}
	return LivecheckDSL{
		package_or_resource: value.map_data['package_or_resource'] or { livecheck_nil() }
		options: livecheck_options.livecheck_options_from_value(value.map_data['options'] or { livecheck_options.livecheck_options_value(livecheck_options.new_livecheck_options({})) })!
		referenced_cask: value.map_data['cask'] or { livecheck_nil() }
		referenced_formula: value.map_data['formula'] or { livecheck_nil() }
		regex: value.map_data['regex'] or { livecheck_nil() }
		skip: (value.map_data['skip'] or { ruby.bool_value(false) }).as_bool() or { false }
		skip_msg: value.map_data['skip_msg'] or { livecheck_nil() }
		strategy: value.map_data['strategy'] or { livecheck_nil() }
		strategy_block: value.map_data['strategy_block'] or { livecheck_nil() }
		throttle: value.map_data['throttle'] or { livecheck_nil() }
		throttle_days: value.map_data['throttle_days'] or { livecheck_nil() }
		url: value.map_data['url'] or { livecheck_nil() }
	}
}

fn livecheck_receiver(args []ruby.Value, method string) ?LivecheckDSL {
	if args.len == 0 {
		_ = method
		return none
	}
	return livecheck_dsl_from_value(args[0]) or { return none }
}

fn livecheck_keywords(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 1; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn livecheck_argument_error(method string) ruby.Value {
	return ruby.object_value('ArgumentError', '${method} requires a Livecheck receiver')
}
