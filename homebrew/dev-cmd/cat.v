module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/cat.rb`.
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
