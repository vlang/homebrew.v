module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/vendor-gems.rb`.

pub struct VendorGemsOptions {
pub:
	library_path          string
	path                  string
	homebrew_path         string
	valid_gem_groups      []string
	update                []string
	update_set            bool
	no_commit             bool
	non_bundler_gems      bool
	github_actions        bool
	prefix                string
	linux_default_prefix  string
	mechanize_directories []string
	mechanize_source      string
}

pub struct VendorGemsResult {
pub:
	setup_gem_environment bool
	environment           map[string]string
	working_dir           string
	headings              []string
	commands              [][]string
	bundle_commands       [][]string
	removed_directories   []string
	symlink_source        string
	symlink_destination   string
	set_git_name_email    bool
	setup_git_gpg         bool
}

fn vendor_gems_union_path(path string, homebrew_path string) string {
	mut entries := []string{}
	for entry in path.split(':') {
		if entry !in entries {
			entries << entry
		}
	}
	for entry in homebrew_path.split(':') {
		if entry !in entries {
			entries << entry
		}
	}
	return entries.join(':')
}

pub fn vendor_gems_run_bundle(arguments []string, success bool) ![]string {
	command := ['bundle'].clone()
	mut full_command := command.clone()
	full_command << arguments
	if !success {
		return error('Error during execution: ${full_command.join(' ')}')
	}
	return full_command
}

pub fn run_vendor_gems(options VendorGemsOptions) VendorGemsResult {
	mut headings := ['cd ${options.library_path}']
	mut commands := [][]string{}
	mut bundle_commands := [][]string{}
	if options.update_set {
		headings << 'bundle update'
		mut update := ['bundle', 'update']
		update << options.update
		commands << update
		bundle_commands << update
		if !options.no_commit {
			headings << 'git add Gemfile.lock'
			commands << ['git', 'add', 'Gemfile.lock']
		}
	}
	headings << 'bundle install --standalone'
	commands << ['bundle', 'install', '--standalone']
	bundle_commands << ['bundle', 'install', '--standalone']
	if options.github_actions && options.prefix == options.linux_default_prefix {
		headings << 'chmod +t -R /home/linuxbrew/'
		commands << ['sudo', 'chmod', '+t', '-R', '/home/linuxbrew/']
	}
	headings << 'bundle pristine'
	commands << ['bundle', 'pristine']
	bundle_commands << ['bundle', 'pristine']
	headings << 'bundle clean'
	commands << ['bundle', 'clean']
	bundle_commands << ['bundle', 'clean']
	if !options.no_commit {
		commands << ['git', 'add', 'Gemfile.lock']
	}
	mut symlink_source := ''
	mut symlink_destination := ''
	if options.non_bundler_gems {
		headings << 'gem install mechanize'
		commands << ['gem', 'install', 'mechanize', '--install-dir', 'vendor', '--no-document',
			'--no-wrappers', '--ignore-dependencies', '--force']
		if options.mechanize_source.len > 0 {
			symlink_source = options.mechanize_source
			symlink_destination = 'mechanize'
		}
	}
	if !options.no_commit {
		headings << 'git add vendor'
		commands << ['git', 'add', 'vendor']
		headings << 'git commit'
		commands << ['git', 'commit', '--message', 'brew vendor-gems: commit updates.']
	}
	return VendorGemsResult{
		setup_gem_environment: true
		environment: {
			'PATH':        vendor_gems_union_path(options.path, options.homebrew_path)
			'BUNDLE_WITH': options.valid_gem_groups.join(':')
		}
		working_dir: options.library_path
		headings: headings
		commands: commands
		bundle_commands: bundle_commands
		removed_directories: if options.non_bundler_gems {
			options.mechanize_directories.clone()
		} else {
			[]string{}
		}
		symlink_source: symlink_source
		symlink_destination: symlink_destination
		set_git_name_email: !options.no_commit
		setup_git_gpg: !options.no_commit
	}
}

@[heap]
pub struct VendorGemsInput {
pub:
	options VendorGemsOptions
}

pub fn vendor_gems_input_boundary(input &VendorGemsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::VendorGems::Input', '', {
		'vendor_gems_input_address': u64(voidptr(input)).str()
	})
}

fn vendor_gems_input_from_value(value ruby.Value) &VendorGemsInput {
	address := value.attributes['vendor_gems_input_address'] or { panic('invalid VendorGems input') }
	return unsafe { &VendorGemsInput(voidptr(address.u64())) }
}

fn vendor_gems_result_value(result VendorGemsResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in result.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'setup_gem_environment': ruby.bool_value(result.setup_gem_environment)
		'environment':           ruby.map_value(environment)
		'working_dir':           ruby.string_value(result.working_dir)
		'headings':              ruby.string_array_value(result.headings)
		'commands':              ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'bundle_commands':       ruby.array_value(result.bundle_commands.map(ruby.string_array_value(it)))
		'removed_directories':   ruby.string_array_value(result.removed_directories)
		'symlink_source':        ruby.string_value(result.symlink_source)
		'symlink_destination':   ruby.string_value(result.symlink_destination)
		'set_git_name_email':    ruby.bool_value(result.set_git_name_email)
		'setup_git_gpg':         ruby.bool_value(result.setup_git_gpg)
	})
}
