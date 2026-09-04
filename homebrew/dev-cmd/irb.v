module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/irb.rb`.

const irb_examples = "'v8'.f # => instance of the v8 formula\n:hub.f.latest_version_installed?\n:lua.f.methods - 1.methods\n:mpd.f.recursive_dependencies.reject(&:installed?)\n\n'vlc'.c # => instance of the vlc cask\n:tsh.c.livecheck_defined?\n"

pub struct IrbOptions {
pub:
	argv         []string
	examples     bool
	pry          bool
	library_path string
	ruby_bindir  string
	load_path    []string
	named        []string
}

pub struct IrbPlan {
pub:
	argv           []string
	stdout         string
	required_files []string
	heading        string
	subheading     string
	environment    map[string]string
	flush_stdout   bool
	flush_stderr   bool
	command        []string
}

pub fn initialize_irb(argv []string, default_argv []string, argv_provided bool) ![]string {
	selected := if argv_provided { argv.clone() } else { default_argv.clone() }
	if '--pry' in selected {
		return error('Use the default IRB backend instead; Pry is largely unmaintained upstream')
	}
	return selected
}

pub fn irb_plan(options IrbOptions) !IrbPlan {
	if options.pry || '--pry' in options.argv {
		return error('Use the default IRB backend instead; Pry is largely unmaintained upstream')
	}
	if options.examples {
		return IrbPlan{
			argv: options.argv.clone()
			stdout: irb_examples
		}
	}
	mut command := [os.join_path(options.ruby_bindir, 'irb'), '-I',
		options.load_path.join(os.path_delimiter)]
	command << options.named
	return IrbPlan{
		argv: options.argv.clone()
		required_files: ['keg', 'cask']
		heading: 'Interactive Homebrew Shell'
		subheading: 'Example commands available with: `brew irb --examples`'
		environment: {
			'IRBRC': os.join_path(options.library_path, 'brew_irbrc')
		}
		flush_stdout: true
		flush_stderr: true
		command: command
	}
}

@[heap]
pub struct IrbInput {
pub:
	options IrbOptions
}

pub fn irb_input_boundary(input &IrbInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Irb::Input', '', {
		'irb_input_address': u64(voidptr(input)).str()
	})
}

fn irb_input_from_value(value ruby.Value) &IrbInput {
	address := value.attributes['irb_input_address'] or { panic('invalid Irb input') }
	return unsafe { &IrbInput(voidptr(address.u64())) }
}

fn irb_plan_value(plan IrbPlan) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in plan.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'argv':           ruby.string_array_value(plan.argv)
		'stdout':         ruby.string_value(plan.stdout)
		'required_files': ruby.string_array_value(plan.required_files)
		'heading':        ruby.string_value(plan.heading)
		'subheading':     ruby.string_value(plan.subheading)
		'environment':    ruby.map_value(environment)
		'flush_stdout':   ruby.bool_value(plan.flush_stdout)
		'flush_stderr':   ruby.bool_value(plan.flush_stderr)
		'command':        ruby.string_array_value(plan.command)
	})
}
