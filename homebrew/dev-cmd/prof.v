module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/prof.rb`.
// The original source is retained below until every stub has a typed V body.

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
	install_bundler_gems bool
	bundler_groups       []string
	setup_gem_environment bool
	directory            string
	mode                 string
	environment          map[string]string
	command              []string
	command_is_safe      bool
	post_command         []string
	output_filename      string
	browser_path         string
	messages             []string
	invalid_option       string
	suggestion           string
}

pub fn prof_plan(options ProfOptions) !ProfPlan {
	if options.invalid_option.len > 0 {
		argv := options.argv.filter(it != '--')
		return ProfPlan{
			invalid_option: options.invalid_option
			suggestion: "Try `brew prof -- ${argv.join(' ')}` instead."
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
			post_command: ['stackprof --d3-flamegraph prof/stackprof.dump > ${output_filename}']
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
				'HOMEBREW_SPAWN_SYSTEM': '1'
				'VERNIER_ALLOCATION_INTERVAL': '500'
				'VERNIER_OUTPUT': output_filename
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

pub fn prof_input_boundary(input &ProfInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Prof::Input', '', {
		'prof_input_address': u64(voidptr(input)).str()
	})
}

fn prof_input_from_value(value brew_runtime.Value) &ProfInput {
	address := value.attributes['prof_input_address'] or { panic('invalid Prof input') }
	return unsafe { &ProfInput(voidptr(address.u64())) }
}

fn prof_plan_value(plan ProfPlan) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in plan.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'install_bundler_gems': brew_runtime.bool_value(plan.install_bundler_gems)
		'bundler_groups': brew_runtime.string_array_value(plan.bundler_groups)
		'setup_gem_environment': brew_runtime.bool_value(plan.setup_gem_environment)
		'directory': brew_runtime.string_value(plan.directory)
		'mode': brew_runtime.object_value('Symbol', plan.mode)
		'environment': brew_runtime.map_value(environment)
		'command': brew_runtime.string_array_value(plan.command)
		'command_is_safe': brew_runtime.bool_value(plan.command_is_safe)
		'post_command': brew_runtime.string_array_value(plan.post_command)
		'output_filename': brew_runtime.string_value(plan.output_filename)
		'browser_path': brew_runtime.string_value(plan.browser_path)
		'messages': brew_runtime.string_array_value(plan.messages)
		'invalid_option': brew_runtime.string_value(plan.invalid_option)
		'suggestion': brew_runtime.string_value(plan.suggestion)
	})
}

// Ruby method `run` at line 27.
pub fn ruby_prof_l27_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return prof_plan_value(prof_plan(prof_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('UsageError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Prof < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Run Homebrew with a Ruby profiler. For example, `brew prof readall`.
// 13:         EOS
// 14:         switch "--stackprof",
// 15:                description: "Use `stackprof` instead of `ruby-prof` (the default)."
// 16:         switch "--vernier",
// 17:                description: "Use `vernier` instead of `ruby-prof` (the default)."
// 18:         switch "--timings",
// 19:                description: "Record machine-readable timings for Homebrew command phases."
// 20:         conflicts "--timings", "--stackprof"
// 21:         conflicts "--timings", "--vernier"
// 22:
// 23:         named_args :command, min: 1
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         Homebrew.install_bundler_gems!(groups: ["prof"], setup_path: false) unless args.timings?
// 29:
// 30:         brew_rb = (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path
// 31:         FileUtils.mkdir_p "prof"
// 32:         cmd = T.must(args.named.first)
// 33:
// 34:         case Commands.path(cmd)&.extname
// 35:         when ".rb"
// 36:           # expected file extension so we do nothing
// 37:         when ".sh"
// 38:           raise UsageError, <<~EOS
// 39:             `#{cmd}` is a Bash command!
// 40:             Try `hyperfine` for benchmarking instead.
// 41:           EOS
// 42:         else
// 43:           raise UsageError, "`#{cmd}` is an unknown command!"
// 44:         end
// 45:
// 46:         if args.timings?
// 47:           output_filename = "prof/timings.json"
// 48:           safe_system({ "HOMEBREW_PHASE_TIMINGS" => output_filename },
// 49:                       *HOMEBREW_RUBY_EXEC_ARGS, brew_rb, *args.named)
// 50:           ohai "Phase timings written to #{output_filename}"
// 51:           return
// 52:         end
// 53:
// 54:         Homebrew.setup_gem_environment!
// 55:
// 56:         if args.stackprof?
// 57:           with_env HOMEBREW_STACKPROF: "1" do
// 58:             system(*HOMEBREW_RUBY_EXEC_ARGS, brew_rb, *args.named)
// 59:           end
// 60:           output_filename = "prof/d3-flamegraph.html"
// 61:           safe_system "stackprof --d3-flamegraph prof/stackprof.dump > #{output_filename}"
// 62:           # `brew prof` is often run from tests or scripts. Only open the HTML
// 63:           # report automatically when the user is attached to a terminal.
// 64:           exec_browser output_filename if $stdout.tty?
// 65:         elsif args.vernier?
// 66:           output_filename = "prof/vernier.json"
// 67:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 68:           # Avoid `vernier run`: it injects `vernier/autorun` through `RUBYOPT`,
// 69:           # which child Ruby processes inherit. Profiling only this Ruby process
// 70:           # keeps nested `brew` commands from trying to write the same profile.
// 71:           #
// 72:           # `HOMEBREW_SPAWN_SYSTEM` is intentionally scoped to this profiled
// 73:           # process. It lets selected process helpers avoid manual fork paths
// 74:           # that can inherit Vernier's active native collector state.
// 75:           safe_system({ "HOMEBREW_SPAWN_SYSTEM" => "1",
// 76:                         "VERNIER_ALLOCATION_INTERVAL" => "500", "VERNIER_OUTPUT" => output_filename },
// 77:                       RUBY_PATH, "-I", (Pathname(Gem::Specification.find_by_name("vernier").full_gem_path)/"lib").to_s,
// 78:                       "-r", "vernier/autorun",
// 79:                       "-r", (HOMEBREW_LIBRARY_PATH/"prof/vernier_fork_guard").to_s, brew_rb, *args.named)
// 80:           ohai "Profiling complete!"
// 81:           puts "Upload the results from #{output_filename} to:"
// 82:           puts "  #{Formatter.url("https://vernier.prof")}"
// 83:         else
// 84:           output_filename = "prof/call_stack.html"
// 85:           safe_system "ruby-prof", "--printer=call_stack", "--file=#{output_filename}", brew_rb, "--", *args.named
// 86:           # Match the stackprof behaviour above: generating the file is useful
// 87:           # in non-interactive runs but launching a browser is not.
// 88:           exec_browser output_filename if $stdout.tty?
// 89:         end
// 90:       rescue OptionParser::InvalidOption => e
// 91:         ofail e
// 92:
// 93:         # The invalid option could have been meant for the subcommand.
// 94:         # Suggest `brew prof list -r` -> `brew prof -- list -r`
// 95:         args = ARGV - ["--"]
// 96:         puts "Try `brew prof -- #{args.join(" ")}` instead."
// 97:       end
// 98:     end
// 99:   end
// 100: end
