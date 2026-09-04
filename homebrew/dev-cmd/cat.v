module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/cat.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CatOptions {
pub:
	repository      string
	named           []string
	paths           []string
	cask            bool
	formula         bool
	bat             bool
	bat_path        string
	bat_config_path string
	bat_theme       string
}

pub struct CatResult {
pub:
	command     []string
	working_dir string
	environment map[string]string
	stdout      string
	stderr      string
	success     bool
}

@[heap]
pub struct CatInput {
pub:
	options CatOptions
}

pub fn run_cat(options CatOptions) !CatResult {
	pager := if options.bat { options.bat_path } else { 'cat' }
	mut missing_messages := []string{}
	for path in options.paths {
		if os.exists(path) {
			continue
		}
		display_path := if options.cask {
			os.file_name(path).trim_string_right('.rb')
		} else {
			path
		}
		missing_messages << "${display_path}'s source doesn't exist on disk."
	}
	mut environment := map[string]string{}
	if options.bat {
		environment['BAT_CONFIG_PATH'] = options.bat_config_path
		environment['BAT_THEME'] = options.bat_theme
	}
	if missing_messages.len > 0 {
		treat_as := if options.cask {
			'--cask '
		} else if options.formula {
			'--formula '
		} else {
			''
		}
		missing_messages << "The name may be wrong, or the tap hasn't been tapped. Instead try:"
		missing_messages << '  brew info --github ${treat_as}${options.named.join(' ')}'
		return CatResult{
			working_dir: options.repository
			environment: environment
			stderr: '${missing_messages.join('\n')}\n'
		}
	}
	mut stdout := ''
	if !options.bat {
		for path in options.paths {
			stdout += os.read_file(path)!
		}
	}
	mut command := [pager]
	command << options.paths
	return CatResult{
		command: command
		working_dir: options.repository
		environment: environment
		stdout: stdout
		success: true
	}
}

pub fn cat_input_boundary(input &CatInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Cat::Input', '', {
		'cat_input_address': u64(voidptr(input)).str()
	})
}

fn cat_input_from_value(value ruby.Value) &CatInput {
	address := value.attributes['cat_input_address'] or { panic('invalid Cat input') }
	return unsafe { &CatInput(voidptr(address.u64())) }
}

fn cat_result_value(result CatResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in result.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'command':     ruby.string_array_value(result.command)
		'working_dir': ruby.string_value(result.working_dir)
		'environment': ruby.map_value(environment)
		'stdout':      ruby.string_value(result.stdout)
		'stderr':      ruby.string_value(result.stderr)
		'success':     ruby.bool_value(result.success)
	})
}

// Ruby method `run` at line 27.
pub fn ruby_cat_l27_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return cat_result_value(run_cat(cat_input_from_value(args[0]).options) or {
		return ruby.object_value('Error', err.msg())
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
// 9:     class Cat < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Display the source of a <formula> or <cask>.
// 15:         EOS
// 16:         switch "--formula", "--formulae",
// 17:                description: "Treat all named arguments as formulae."
// 18:         switch "--cask", "--casks",
// 19:                description: "Treat all named arguments as casks."
// 20:
// 21:         conflicts "--formula", "--cask"
// 22:
// 23:         named_args [:formula, :cask], min: 1, without_api: true
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         cd HOMEBREW_REPOSITORY do
// 29:           pager = if Homebrew::EnvConfig.bat?
// 30:             ENV["BAT_CONFIG_PATH"] = Homebrew::EnvConfig.bat_config_path
// 31:             ENV["BAT_THEME"] = Homebrew::EnvConfig.bat_theme
// 32:             require "formula"
// 33:             T.cast(Formula["bat"].ensure_installed!(
// 34:                      reason:           "displaying <formula>/<cask> source",
// 35:                      # The user might want to capture the output of `brew cat ...`
// 36:                      # Redirect stdout to stderr
// 37:                      output_to_stderr: true,
// 38:                      executable:       "bat",
// 39:                    ), Pathname)
// 40:           else
// 41:             "cat"
// 42:           end
// 43:
// 44:           args.named.to_paths.each do |path|
// 45:             next path if path.exist?
// 46:
// 47:             path = path.basename(".rb") if args.cask?
// 48:
// 49:             ofail "#{path}'s source doesn't exist on disk."
// 50:           end
// 51:
// 52:           if Homebrew.failed?
// 53:             $stderr.puts "The name may be wrong, or the tap hasn't been tapped. Instead try:"
// 54:             treat_as = "--cask " if args.cask?
// 55:             treat_as = "--formula " if args.formula?
// 56:             $stderr.puts "  brew info --github #{treat_as}#{args.named.join(" ")}"
// 57:             return
// 58:           end
// 59:
// 60:           safe_system pager, *args.named.to_paths
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
