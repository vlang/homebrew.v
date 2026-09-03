module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/vendor-gems.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct VendorGemsOptions {
pub:
	library_path       string
	path               string
	homebrew_path      string
	valid_gem_groups   []string
	update             []string
	update_set         bool
	no_commit          bool
	non_bundler_gems   bool
	github_actions     bool
	prefix             string
	linux_default_prefix string
	mechanize_directories []string
	mechanize_source   string
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
			'PATH': vendor_gems_union_path(options.path, options.homebrew_path)
			'BUNDLE_WITH': options.valid_gem_groups.join(':')
		}
		working_dir: options.library_path
		headings: headings
		commands: commands
		bundle_commands: bundle_commands
		removed_directories: if options.non_bundler_gems { options.mechanize_directories.clone() } else { []string{} }
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

pub fn vendor_gems_input_boundary(input &VendorGemsInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::VendorGems::Input', '', {
		'vendor_gems_input_address': u64(voidptr(input)).str()
	})
}

fn vendor_gems_input_from_value(value brew_runtime.Value) &VendorGemsInput {
	address := value.attributes['vendor_gems_input_address'] or { panic('invalid VendorGems input') }
	return unsafe { &VendorGemsInput(voidptr(address.u64())) }
}

fn vendor_gems_result_value(result VendorGemsResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in result.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'setup_gem_environment': brew_runtime.bool_value(result.setup_gem_environment)
		'environment': brew_runtime.map_value(environment)
		'working_dir': brew_runtime.string_value(result.working_dir)
		'headings': brew_runtime.string_array_value(result.headings)
		'commands': brew_runtime.array_value(result.commands.map(brew_runtime.string_array_value(it)))
		'bundle_commands': brew_runtime.array_value(result.bundle_commands.map(brew_runtime.string_array_value(it)))
		'removed_directories': brew_runtime.string_array_value(result.removed_directories)
		'symlink_source': brew_runtime.string_value(result.symlink_source)
		'symlink_destination': brew_runtime.string_value(result.symlink_destination)
		'set_git_name_email': brew_runtime.bool_value(result.set_git_name_email)
		'setup_git_gpg': brew_runtime.bool_value(result.setup_git_gpg)
	})
}

// Ruby method `run` at line 28.
pub fn ruby_vendor_gems_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return vendor_gems_result_value(run_vendor_gems(vendor_gems_input_from_value(args[0]).options))
}

// Ruby method `run_bundle(*args)` at line 97.
pub fn ruby_vendor_gems_l97_d2_run_bundle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'bundle arguments are required')
	}
	arguments := args[0].as_string_array() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	success := if args.len > 1 { args[1].as_bool() or { false } } else { true }
	return brew_runtime.string_array_value(vendor_gems_run_bundle(arguments, success) or {
		return brew_runtime.object_value('ErrorDuringExecution', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/git"
// 6: require "fileutils"
// 7: require "utils/github"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class VendorGems < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Install and commit Homebrew's vendored gems.
// 15:         EOS
// 16:         comma_array "--update",
// 17:                     description: "Update the specified list of vendored gems to the latest version."
// 18:         switch "--no-commit",
// 19:                description: "Do not generate a new commit upon completion."
// 20:         switch "--non-bundler-gems",
// 21:                description: "Update vendored gems that aren't using Bundler.",
// 22:                hidden:      true
// 23:
// 24:         named_args :none
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         Homebrew.setup_gem_environment!
// 30:         ENV["PATH"] = (ENV.fetch("PATH").split(":") | ENV.fetch("HOMEBREW_PATH", "").split(":")).join(":")
// 31:         ENV["BUNDLE_WITH"] = Homebrew.valid_gem_groups.join(":")
// 32:
// 33:         ohai "cd #{HOMEBREW_LIBRARY_PATH}"
// 34:         HOMEBREW_LIBRARY_PATH.cd do
// 35:           if args.update
// 36:             ohai "bundle update"
// 37:             run_bundle "update", *args.update
// 38:
// 39:             unless args.no_commit?
// 40:               ohai "git add Gemfile.lock"
// 41:               system "git", "add", "Gemfile.lock"
// 42:             end
// 43:           end
// 44:
// 45:           ohai "bundle install --standalone"
// 46:           run_bundle "install", "--standalone"
// 47:
// 48:           if GitHub::Actions.env_set? && HOMEBREW_PREFIX.to_s == HOMEBREW_LINUX_DEFAULT_PREFIX
// 49:             ohai "chmod +t -R /home/linuxbrew/"
// 50:             system "sudo", "chmod", "+t", "-R", "/home/linuxbrew/"
// 51:           end
// 52:
// 53:           ohai "bundle pristine"
// 54:           run_bundle "pristine"
// 55:
// 56:           ohai "bundle clean"
// 57:           run_bundle "clean"
// 58:
// 59:           system "git", "add", "Gemfile.lock" unless args.no_commit?
// 60:
// 61:           if args.non_bundler_gems?
// 62:             %w[
// 63:               mechanize
// 64:             ].each do |gem|
// 65:               (HOMEBREW_LIBRARY_PATH/"vendor/gems").cd do
// 66:                 Pathname.glob("#{gem}-*/").each { |path| FileUtils.rm_r(path) }
// 67:               end
// 68:               ohai "gem install #{gem}"
// 69:               safe_system "gem", "install", gem, "--install-dir", "vendor",
// 70:                           "--no-document", "--no-wrappers", "--ignore-dependencies", "--force"
// 71:               (HOMEBREW_LIBRARY_PATH/"vendor/gems").cd do
// 72:                 source = Pathname.glob("#{gem}-*/").first
// 73:                 next unless source
// 74:
// 75:                 # We cannot use `#ln_sf` here because that has unintended consequences when
// 76:                 # the symlink we want to create exists and points to an existing directory.
// 77:                 FileUtils.rm_f gem
// 78:                 FileUtils.ln_s source, gem
// 79:               end
// 80:             end
// 81:           end
// 82:
// 83:           unless args.no_commit?
// 84:             ohai "git add vendor"
// 85:             system "git", "add", "vendor"
// 86:
// 87:             Utils::Git.set_name_email!
// 88:             Utils::Git.setup_gpg!
// 89:
// 90:             ohai "git commit"
// 91:             system "git", "commit", "--message", "brew vendor-gems: commit updates."
// 92:           end
// 93:         end
// 94:       end
// 95:
// 96:       sig { params(args: String).void }
// 97:       def run_bundle(*args)
// 98:         Process.wait(fork do
// 99:           # Native build scripts fail if EUID != UID
// 100:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 101:           exec "bundle", *args
// 102:         end)
// 103:
// 104:         raise ErrorDuringExecution.new(["bundle", *args], status: $CHILD_STATUS) unless $CHILD_STATUS.success?
// 105:       end
// 106:     end
// 107:   end
// 108: end
