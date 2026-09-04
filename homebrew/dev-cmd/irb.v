module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/irb.rb`.
// The original source is retained below until every stub has a typed V body.

const irb_examples = "'v8'.f # => instance of the v8 formula\n:hub.f.latest_version_installed?\n:lua.f.methods - 1.methods\n:mpd.f.recursive_dependencies.reject(&:installed?)\n\n'vlc'.c # => instance of the vlc cask\n:tsh.c.livecheck_defined?\n"

pub struct IrbOptions {
pub:
	argv          []string
	examples      bool
	pry           bool
	library_path  string
	ruby_bindir   string
	load_path     []string
	named         []string
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
	mut command := [os.join_path(options.ruby_bindir, 'irb'), '-I', options.load_path.join(os.path_delimiter)]
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
		'argv': ruby.string_array_value(plan.argv)
		'stdout': ruby.string_value(plan.stdout)
		'required_files': ruby.string_array_value(plan.required_files)
		'heading': ruby.string_value(plan.heading)
		'subheading': ruby.string_value(plan.subheading)
		'environment': ruby.map_value(environment)
		'flush_stdout': ruby.bool_value(plan.flush_stdout)
		'flush_stderr': ruby.bool_value(plan.flush_stderr)
		'command': ruby.string_array_value(plan.command)
	})
}

// Ruby method `initialize(argv = nil) = super(argv || ARGV.dup.freeze)` at line 24.
pub fn ruby_irb_l24_d1_initialize(args ...ruby.Value) ruby.Value {
	argv_provided := args.len > 0 && args[0].type_name !in ['Nil', 'NilClass', '']
	argv := if argv_provided { args[0].as_string_array() or {
		return ruby.object_value('TypeError', err.msg())
	} } else { []string{} }
	default_argv := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	return ruby.string_array_value(initialize_irb(argv, default_argv, argv_provided) or {
		return ruby.object_value('MethodDeprecatedError', err.msg())
	})
}

// Ruby method `run` at line 27.
pub fn ruby_irb_l27_d2_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return irb_plan_value(irb_plan(irb_input_from_value(args[0]).options) or {
		return ruby.object_value('MethodDeprecatedError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class Irb < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Enter the interactive Homebrew Ruby shell.
// 12:         EOS
// 13:         switch "--examples",
// 14:                description: "Show several examples."
// 15:         switch "--pry",
// 16:                description: "Use Pry instead of IRB.",
// 17:                env:         :pry,
// 18:                replacement: "the default IRB backend (Pry is largely unmaintained upstream)",
// 19:                odeprecated: true
// 20:       end
// 21:
// 22:       # work around IRB modifying ARGV.
// 23:       sig { params(argv: T.nilable(T::Array[String])).void }
// 24:       def initialize(argv = nil) = super(argv || ARGV.dup.freeze)
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         if args.examples?
// 29:           puts <<~EOS
// 30:             'v8'.f # => instance of the v8 formula
// 31:             :hub.f.latest_version_installed?
// 32:             :lua.f.methods - 1.methods
// 33:             :mpd.f.recursive_dependencies.reject(&:installed?)
// 34:
// 35:             'vlc'.c # => instance of the vlc cask
// 36:             :tsh.c.livecheck_defined?
// 37:           EOS
// 38:           return
// 39:         end
// 40:
// 41:         require "keg"
// 42:         require "cask"
// 43:
// 44:         ohai "Interactive Homebrew Shell", "Example commands available with: `brew irb --examples`"
// 45:         ENV["IRBRC"] = (HOMEBREW_LIBRARY_PATH/"brew_irbrc").to_s
// 46:
// 47:         $stdout.flush
// 48:         $stderr.flush
// 49:         exec File.join(RbConfig::CONFIG["bindir"], "irb"), "-I", $LOAD_PATH.join(File::PATH_SEPARATOR), *args.named
// 50:       end
// 51:     end
// 52:   end
// 53: end
