module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/debugger.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct DebuggerOptions {
pub:
	using_portable_ruby bool
	valid_ruby_commands []string
	named               []string
	open                bool
	library_path        string
	ruby_exec_args      []string
	load_path           []string
	homebrew_rdbg_set   bool
}

pub struct DebuggerPlan {
pub:
	command     []string
	environment map[string]string
}

@[heap]
pub struct DebuggerInput {
pub:
	options DebuggerOptions
}

pub fn debugger_plan(options DebuggerOptions) !DebuggerPlan {
	if !options.using_portable_ruby {
		return error('Debugger is only supported with portable Ruby!')
	}
	if options.named.len == 0 || options.named[0] !in options.valid_ruby_commands {
		name := if options.named.len > 0 { options.named[0] } else { '' }
		return error('`${name}` is not a valid Ruby command!')
	}
	debugger_method := if options.open { 'open' } else { 'start' }
	mut environment := {
		'RUBY_DEBUG_FORK_MODE': 'parent'
	}
	if !options.homebrew_rdbg_set {
		environment['RUBY_DEBUG_NONSTOP'] = '1'
	}
	mut command := options.ruby_exec_args.clone()
	command << ['-I', options.load_path.join(os.path_delimiter), '-rdebug/${debugger_method}',
		os.real_path(os.join_path(options.library_path, 'brew.rb'))]
	command << options.named
	return DebuggerPlan{
		command: command
		environment: environment
	}
}

pub fn debugger_input_boundary(input &DebuggerInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Debugger::Input', '', {
		'debugger_input_address': u64(voidptr(input)).str()
	})
}

fn debugger_input_from_value(value brew_runtime.Value) &DebuggerInput {
	address := value.attributes['debugger_input_address'] or { panic('invalid Debugger input') }
	return unsafe { &DebuggerInput(voidptr(address.u64())) }
}

fn debugger_plan_value(plan DebuggerPlan) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in plan.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'command':     brew_runtime.string_array_value(plan.command)
		'environment': brew_runtime.map_value(environment)
	})
}

// Ruby method `run` at line 21.
pub fn ruby_debugger_l21_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return debugger_plan_value(debugger_plan(debugger_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('UsageError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module DevCmd
// 6:     class Debugger < AbstractCommand
// 7:       cmd_args do
// 8:         description <<~EOS
// 9:           Run the specified Homebrew command in debug mode.
// 10:
// 11:           To pass flags to the command, use `--` to separate them from the `brew` flags.
// 12:           For example: `brew debugger -- list --formula`.
// 13:         EOS
// 14:         switch "-O", "--open",
// 15:                description: "Start remote debugging over a Unix socket."
// 16:
// 17:         named_args :command, min: 1
// 18:       end
// 19:
// 20:       sig { override.void }
// 21:       def run
// 22:         raise UsageError, "Debugger is only supported with portable Ruby!" unless HOMEBREW_USING_PORTABLE_RUBY
// 23:
// 24:         unless Commands.valid_ruby_cmd?(T.must(args.named.first))
// 25:           raise UsageError, "`#{args.named.first}` is not a valid Ruby command!"
// 26:         end
// 27:
// 28:         brew_rb = (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path
// 29:         debugger_method = if args.open?
// 30:           "open"
// 31:         else
// 32:           "start"
// 33:         end
// 34:
// 35:         env = {}
// 36:         env[:RUBY_DEBUG_FORK_MODE] = "parent"
// 37:         env[:RUBY_DEBUG_NONSTOP] = "1" unless ENV["HOMEBREW_RDBG"]
// 38:
// 39:         with_env(**env) do
// 40:           system(*HOMEBREW_RUBY_EXEC_ARGS,
// 41:                  "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 42:                  "-rdebug/#{debugger_method}",
// 43:                  brew_rb, *args.named)
// 44:         end
// 45:       end
// 46:     end
// 47:   end
// 48: end
