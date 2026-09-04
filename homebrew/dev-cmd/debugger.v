module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/debugger.rb`.
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

pub fn debugger_input_boundary(input &DebuggerInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Debugger::Input', '', {
		'debugger_input_address': u64(voidptr(input)).str()
	})
}

fn debugger_input_from_value(value ruby.Value) &DebuggerInput {
	address := value.attributes['debugger_input_address'] or { panic('invalid Debugger input') }
	return unsafe { &DebuggerInput(voidptr(address.u64())) }
}

fn debugger_plan_value(plan DebuggerPlan) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in plan.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'command':     ruby.string_array_value(plan.command)
		'environment': ruby.map_value(environment)
	})
}
