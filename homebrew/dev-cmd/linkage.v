module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/linkage.rb`.
pub struct LinkageCommandKeg {
pub:
	name                  string
	normal_output         []string
	reverse_output        []string
	test_output           []string
	broken                bool
	undeclared_with_links bool
}

pub struct LinkageCommandOptions {
pub:
	named_kegs     []LinkageCommandKeg
	installed_kegs []LinkageCommandKeg
	test           bool
	strict         bool
	reverse        bool
	cached         bool
}

pub struct LinkageCommandResult {
pub:
	kegs       []string
	output     []string
	mode       string
	cache_name string
	cached     bool
	failed     bool
}

@[heap]
pub struct LinkageCommandInput {
pub:
	options LinkageCommandOptions
}

pub fn run_linkage_command(options LinkageCommandOptions) LinkageCommandResult {
	kegs := if options.named_kegs.len == 0 { options.installed_kegs } else { options.named_kegs }
	mode := if options.test {
		'test'
	} else if options.reverse { 'reverse' } else { 'normal' }
	mut output := []string{}
	mut failed := false
	for keg in kegs {
		if kegs.len > 1 {
			output << 'Checking ${keg.name} linkage'
		}
		if options.test {
			output << keg.test_output
			if keg.broken || (options.strict && keg.undeclared_with_links) {
				failed = true
			}
		} else if options.reverse {
			output << keg.reverse_output
		} else {
			output << keg.normal_output
		}
	}
	return LinkageCommandResult{
		kegs: kegs.map(it.name)
		output: output
		mode: mode
		cache_name: 'linkage'
		cached: options.cached
		failed: failed
	}
}

pub fn linkage_command_input_boundary(input &LinkageCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Linkage::Input', '', {
		'linkage_command_input_address': u64(voidptr(input)).str()
	})
}

fn linkage_command_input_from_value(value ruby.Value) &LinkageCommandInput {
	address := value.attributes['linkage_command_input_address'] or {
		panic('invalid Linkage command input')
	}
	return unsafe { &LinkageCommandInput(voidptr(address.u64())) }
}

fn linkage_command_result_value(result LinkageCommandResult) ruby.Value {
	return ruby.map_value({
		'kegs':       ruby.string_array_value(result.kegs)
		'output':     ruby.string_array_value(result.output)
		'mode':       ruby.object_value('Symbol', result.mode)
		'cache_name': ruby.object_value('Symbol', result.cache_name)
		'cached':     ruby.bool_value(result.cached)
		'failed':     ruby.bool_value(result.failed)
	})
}
