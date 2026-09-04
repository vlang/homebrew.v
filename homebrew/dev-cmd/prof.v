module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/prof.rb`.

pub struct ProfOptions {
pub:
	library_path      string
	ruby_exec_args    []string
	ruby_path         string
	vernier_gem_path  string
	named             []string
	command_extension string
	stackprof         bool
	vernier           bool
	timings           bool
	stdout_tty        bool
	invalid_option    string
	argv              []string
}

pub struct ProfPlan {
pub:
	install_bundler_gems  bool
	bundler_groups        []string
	setup_gem_environment bool
	directory             string
	mode                  string
	environment           map[string]string
	command               []string
	command_is_safe       bool
	post_command          []string
	output_filename       string
	browser_path          string
	messages              []string
	invalid_option        string
	suggestion            string
}

pub fn prof_plan(options ProfOptions) !ProfPlan {
	if options.invalid_option.len > 0 {
		argv := options.argv.filter(it != '--')
		return ProfPlan{
			invalid_option: options.invalid_option
			suggestion: 'Try `brew prof -- ${argv.join(' ')}` instead.'
		}
	}
	if options.named.len == 0 {
		return error('at least one command is required')
	}
	cmd := options.named[0]
	match options.command_extension {
		'.rb' {}
		'.sh' {
			return error('`${cmd}` is a Bash command!\nTry `hyperfine` for benchmarking instead.')
		}
		else {
			return error('`${cmd}` is an unknown command!')
		}
	}
	brew_rb := os.join_path(options.library_path, 'brew.rb')
	if options.timings {
		output_filename := 'prof/timings.json'
		mut command := options.ruby_exec_args.clone()
		command << brew_rb
		command << options.named
		return ProfPlan{
			directory: 'prof'
			mode: 'timings'
			environment: {
				'HOMEBREW_PHASE_TIMINGS': output_filename
			}
			command: command
			command_is_safe: true
			output_filename: output_filename
			messages: ['Phase timings written to ${output_filename}']
		}
	}
	if options.stackprof {
		output_filename := 'prof/d3-flamegraph.html'
		mut command := options.ruby_exec_args.clone()
		command << brew_rb
		command << options.named
		return ProfPlan{
			install_bundler_gems: true
			bundler_groups: ['prof']
			setup_gem_environment: true
			directory: 'prof'
			mode: 'stackprof'
			environment: {
				'HOMEBREW_STACKPROF': '1'
			}
			command: command
			post_command: [
				'stackprof --d3-flamegraph prof/stackprof.dump > ${output_filename}',
			]
			output_filename: output_filename
			browser_path: if options.stdout_tty { output_filename } else { '' }
		}
	}
	if options.vernier {
		output_filename := 'prof/vernier.json'
		command := [
			options.ruby_path,
			'-I',
			os.join_path(options.vernier_gem_path, 'lib'),
			'-r',
			'vernier/autorun',
			'-r',
			os.join_path(options.library_path, 'prof', 'vernier_fork_guard'),
			brew_rb,
		].clone()
		mut full_command := command.clone()
		full_command << options.named
		return ProfPlan{
			install_bundler_gems: true
			bundler_groups: ['prof']
			setup_gem_environment: true
			directory: 'prof'
			mode: 'vernier'
			environment: {
				'HOMEBREW_SPAWN_SYSTEM':       '1'
				'VERNIER_ALLOCATION_INTERVAL': '500'
				'VERNIER_OUTPUT':              output_filename
			}
			command: full_command
			command_is_safe: true
			output_filename: output_filename
			messages: [
				'Profiling complete!',
				'Upload the results from ${output_filename} to:',
				'  https://vernier.prof',
			]
		}
	}
	output_filename := 'prof/call_stack.html'
	mut command := ['ruby-prof', '--printer=call_stack', '--file=${output_filename}', brew_rb, '--']
	command << options.named
	return ProfPlan{
		install_bundler_gems: true
		bundler_groups: ['prof']
		setup_gem_environment: true
		directory: 'prof'
		mode: 'ruby-prof'
		command: command
		command_is_safe: true
		output_filename: output_filename
		browser_path: if options.stdout_tty { output_filename } else { '' }
	}
}

@[heap]
pub struct ProfInput {
pub:
	options ProfOptions
}

pub fn prof_input_boundary(input &ProfInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Prof::Input', '', {
		'prof_input_address': u64(voidptr(input)).str()
	})
}

fn prof_input_from_value(value ruby.Value) &ProfInput {
	address := value.attributes['prof_input_address'] or { panic('invalid Prof input') }
	return unsafe { &ProfInput(voidptr(address.u64())) }
}

fn prof_plan_value(plan ProfPlan) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in plan.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'install_bundler_gems':  ruby.bool_value(plan.install_bundler_gems)
		'bundler_groups':        ruby.string_array_value(plan.bundler_groups)
		'setup_gem_environment': ruby.bool_value(plan.setup_gem_environment)
		'directory':             ruby.string_value(plan.directory)
		'mode':                  ruby.object_value('Symbol', plan.mode)
		'environment':           ruby.map_value(environment)
		'command':               ruby.string_array_value(plan.command)
		'command_is_safe':       ruby.bool_value(plan.command_is_safe)
		'post_command':          ruby.string_array_value(plan.post_command)
		'output_filename':       ruby.string_value(plan.output_filename)
		'browser_path':          ruby.string_value(plan.browser_path)
		'messages':              ruby.string_array_value(plan.messages)
		'invalid_option':        ruby.string_value(plan.invalid_option)
		'suggestion':            ruby.string_value(plan.suggestion)
	})
}
