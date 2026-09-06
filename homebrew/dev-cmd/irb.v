module dev_cmd

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
