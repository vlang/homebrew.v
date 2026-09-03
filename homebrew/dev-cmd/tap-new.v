module dev_cmd

import brew_runtime
import os
import rand

// Translated from Homebrew/brew `dev-cmd/tap-new.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct TapNewTap {
pub:
	user       string
	repository string
	path       string
	installed  bool
}

pub struct TapNewOptions {
pub:
	tap                   TapNewTap
	branch                string = 'main'
	no_git                bool
	github_packages       bool
	workflow_template_dir string
	workflow_templates    map[string]string
	uid                   int = -1
	euid                  int = -1
	git_owner             int = -1
	uid_home              string
	tmpdir                string
	tmpdir_writable_real  bool = true
	random_hour           int = -1
	random_minute         int = -1
}

pub struct TapNewGitCommand {
pub:
	program           string
	arguments         []string
	working_directory string
	environment       map[string]string
	unset_environment []string
	print_stdout      bool
	run_as_real_uid   bool
	safe              bool
}

pub struct TapNewResult {
pub:
	tap                string
	path               string
	branch             string
	root_url           ?string
	created_files      []string
	set_git_name_email bool
	setup_git_gpg      bool
	git_commands       []TapNewGitCommand
	headline           string
	stdout             string
}

@[heap]
pub struct TapNewInput {
pub:
	options TapNewOptions
}

@[heap]
pub struct TapNewRenderInput {
pub:
	filename        string
	branch          string
	github_packages bool
	root_url        ?string
	template        string
	hour            int = -1
	minute          int = -1
}

@[heap]
pub struct TapNewWriteInput {
pub:
	tap      TapNewTap
	filename string
	content  string
}

fn tap_new_name(tap TapNewTap) string {
	return '${tap.user}/${tap.repository}'.to_lower()
}

fn tap_new_titleize(value string) string {
	if value == '' {
		return ''
	}
	return value[..1].to_upper() + value[1..]
}

fn tap_new_valid_path(tap TapNewTap) bool {
	if tap.user == '' || tap.repository == '' || tap.user.contains('/')
		|| tap.repository.contains('/') {
		return false
	}
	expected := os.join_path('Taps', tap.user.to_lower(), 'homebrew-${tap.repository.to_lower()}')
	path := os.norm_path(tap.path)
	return path == expected || path.ends_with('${os.path_separator}${expected}')
}

fn tap_new_root_url(tap TapNewTap) string {
	return 'https://ghcr.io/v2/${tap.user.to_lower()}/${tap.repository}'
}

fn tap_new_random_schedule(hour int, minute int) (int, int) {
	selected_hour := if hour >= 0 { hour } else { rand.intn(24) or { 0 } }
	selected_minute := if minute >= 0 { minute } else { (rand.intn(12) or { 0 }) * 5 }
	return selected_hour, selected_minute
}

fn tap_new_strip_github_packages_markers(workflow string, github_packages bool) string {
	trailing_newline := workflow.ends_with('\n')
	mut output := []string{}
	mut in_github_packages_block := false
	for line in workflow.split('\n') {
		trimmed := line.trim_space()
		if trimmed == '# tap-new-github-packages-start' {
			in_github_packages_block = true
			continue
		}
		if trimmed == '# tap-new-github-packages-end' {
			in_github_packages_block = false
			continue
		}
		if !github_packages && in_github_packages_block {
			continue
		}
		output << line
	}
	if trailing_newline && output.len > 0 && output.last() == '' {
		output.delete_last()
	}
	mut rendered := output.join('\n')
	if trailing_newline {
		rendered += '\n'
	}
	return rendered
}

pub fn render_tap_new_workflow_template(filename string, branch string, github_packages bool,
	root_url ?string, template string, hour int, minute int) string {
	mut workflow := template
	workflow = workflow.replace_once('name: tap-new tests template', 'name: brew test-bot')
	workflow = workflow.replace_once('name: tap-new publish template', 'name: brew pr-pull')
	workflow = workflow.replace_once('name: tap-new autobump template', 'name: brew bump')
	if filename == 'tap-new-tests.yml' {
		workflow = workflow.replace_once('on:\n  workflow_dispatch:\n', 'on:\n  push:\n    branches:\n      - ${branch}\n  pull_request:\n')
	}
	// Pick a random 5 minute block in which to execute the autobump action to avoid peak GitHub loads
	schedule_hour, schedule_minute := tap_new_random_schedule(hour, minute)
	workflow = workflow.replace('this will be changed later and randomised by brew tap-new', 'Every day at ${schedule_hour}:${schedule_minute} UTC')
	workflow = workflow.replace('"1 1 1 1 1"', '${schedule_minute} ${schedule_hour} * * *')
	workflow = workflow.replace_once("    if: github.repository == ''\n", '')
	workflow = workflow.replace('TAP_NEW_BRANCH', branch)
	root_url_argument := if value := root_url { ' --root-url=${value}' } else { '' }
	workflow = workflow.replace('TAP_NEW_ROOT_URL_ARGUMENT', root_url_argument)
	return tap_new_strip_github_packages_markers(workflow, github_packages)
}

fn tap_new_workflow_template(options TapNewOptions, filename string) !string {
	if workflow_template := options.workflow_templates[filename] {
		return workflow_template
	}
	if options.workflow_template_dir == '' {
		return error('workflow template ${filename} is unavailable')
	}
	return os.read_file(os.join_path(options.workflow_template_dir, filename))
}

pub fn write_tap_new_path(tap TapNewTap, filename string, content string) !string {
	path := os.join_path(tap.path, filename)
	os.mkdir_all(tap.path)!
	if os.exists(path) {
		return error('${path} already exists')
	}
	os.write_file(path, content)!
	return path
}

fn tap_new_readme(tap TapNewTap) string {
	name := tap_new_name(tap)
	return '# ${tap_new_titleize(tap.user)} ${tap_new_titleize(tap.repository)}\n\n' + '## How do I install these formulae?\n\n' + '`brew install ${name}/<formula>`\n\n' + 'Or `brew tap ${name}` and then `brew install <formula>`.\n\n' + 'Or, in a `brew bundle` `Brewfile`:\n\n' + '```ruby\n' + 'tap "${name}"\n' + 'brew "<formula>"\n' + '```\n\n' + '## Documentation\n\n' + "`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).\n"
}

fn tap_new_dependabot() string {
	return 'version: 2\n' + 'updates:\n' + '  - package-ecosystem: github-actions\n' + '    directory: "/"\n' + '    schedule:\n' + '      interval: weekly\n' + '    groups:\n' + '      github-actions:\n' + '        patterns:\n' + '          - "*"\n'
}

fn tap_new_git_commands(options TapNewOptions, branch string) []TapNewGitCommand {
	mut configuration_arguments := []string{}
	if options.git_owner >= 0 && options.uid >= 0 && options.euid >= 0
		&& options.git_owner != options.uid && options.git_owner == options.euid {
		// Under Homebrew user model, EUID is permitted to execute commands under the UID.
		// Root users are never allowed (see brew.sh).
		configuration_arguments = ['-c', 'safe.directory=${options.tap.path}']
	}
	// Use the configuration of the original user, which will have author information and signing keys.
	mut environment := map[string]string{}
	if options.uid_home != '' {
		environment['HOME'] = options.uid_home
	}
	mut unset_environment := []string{}
	if options.tmpdir != '' && !options.tmpdir_writable_real {
		unset_environment << 'TMPDIR'
	}
	mut commands := [TapNewGitCommand{
		program: 'git'
		arguments: ['init', '--initial-branch=${branch}']
		working_directory: options.tap.path
		safe: true
	}]
	for arguments in [
		['add', '--all'],
		['commit', '-m', 'Create ${tap_new_name(options.tap)} tap'],
		['branch', '-m', branch],
	] {
		mut command_arguments := configuration_arguments.clone()
		command_arguments << arguments
		commands << TapNewGitCommand{
			program: 'git'
			arguments: command_arguments
			working_directory: options.tap.path
			environment: environment.clone()
			unset_environment: unset_environment.clone()
			print_stdout: true
			run_as_real_uid: true
		}
	}
	return commands
}

pub fn run_tap_new(options TapNewOptions) !TapNewResult {
	branch := if options.branch == '' { 'main' } else { options.branch }
	tap := options.tap
	name := tap_new_name(tap)
	if !tap_new_valid_path(tap) {
		return error("Invalid tap name '${name}'")
	}
	if tap.installed {
		return error('Tap is already installed!')
	}
	root_url := if options.github_packages { ?string(tap_new_root_url(tap)) } else { none }

	os.mkdir_all(os.join_path(tap.path, 'Formula'))!
	mut created_files := []string{}
	write_tap_new_path(tap, 'README.md', tap_new_readme(tap))!
	created_files << 'README.md'

	tests_yml := render_tap_new_workflow_template('tap-new-tests.yml', branch, options.github_packages, root_url, tap_new_workflow_template(options, 'tap-new-tests.yml')!, options.random_hour, options.random_minute)
	publish_yml := render_tap_new_workflow_template('tap-new-publish.yml', branch, options.github_packages, none, tap_new_workflow_template(options, 'tap-new-publish.yml')!, options.random_hour, options.random_minute)
	autobump_yml := render_tap_new_workflow_template('tap-new-autobump.yml', branch, options.github_packages, none, tap_new_workflow_template(options, 'tap-new-autobump.yml')!, options.random_hour, options.random_minute)
	os.mkdir_all(os.join_path(tap.path, '.github', 'workflows'))!
	for file in [
		['.github/dependabot.yml', tap_new_dependabot()],
		['.github/workflows/tests.yml', tests_yml],
		['.github/workflows/publish.yml', publish_yml],
		['.github/workflows/autobump.yml', autobump_yml],
	] {
		filename := file[0]
		content := file[1]
		write_tap_new_path(tap, filename, content)!
		created_files << filename
	}

	git_commands := if options.no_git {
		[]TapNewGitCommand{}
	} else {
		tap_new_git_commands(options, branch)
	}
	stdout := '${tap.path}\n\n' + 'When a pull request making changes to a formula (or formulae) becomes green\n' + '(all checks passed), then you can publish the built bottles.\n' + 'To do so, run `brew pr-pull` locally or run the `brew pr-pull`\n' + 'workflow with the pull request number and, optionally, the pull\n' + "request's expected head commit SHA.\n"
	return TapNewResult{
		tap: name
		path: tap.path
		branch: branch
		root_url: root_url
		created_files: created_files
		set_git_name_email: !options.no_git
		setup_git_gpg: !options.no_git
		git_commands: git_commands
		headline: 'Created ${name}'
		stdout: stdout
	}
}

pub fn tap_new_input_boundary(input &TapNewInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::TapNew::Input', '', {
		'tap_new_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_input_from_value(value brew_runtime.Value) &TapNewInput {
	address := value.attributes['tap_new_input_address'] or { panic('invalid TapNew input') }
	return unsafe { &TapNewInput(voidptr(address.u64())) }
}

pub fn tap_new_render_input_boundary(input &TapNewRenderInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::TapNew::RenderInput', '', {
		'tap_new_render_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_render_input_from_value(value brew_runtime.Value) &TapNewRenderInput {
	address := value.attributes['tap_new_render_input_address'] or {
		panic('invalid TapNew render input')
	}
	return unsafe { &TapNewRenderInput(voidptr(address.u64())) }
}

pub fn tap_new_write_input_boundary(input &TapNewWriteInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::TapNew::WriteInput', '', {
		'tap_new_write_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_write_input_from_value(value brew_runtime.Value) &TapNewWriteInput {
	address := value.attributes['tap_new_write_input_address'] or {
		panic('invalid TapNew write input')
	}
	return unsafe { &TapNewWriteInput(voidptr(address.u64())) }
}

fn tap_new_git_command_value(command TapNewGitCommand) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for key, value in command.environment {
		environment[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'program':           brew_runtime.string_value(command.program)
		'arguments':         brew_runtime.string_array_value(command.arguments)
		'working_directory': brew_runtime.string_value(command.working_directory)
		'environment':       brew_runtime.map_value(environment)
		'unset_environment': brew_runtime.string_array_value(command.unset_environment)
		'print_stdout':      brew_runtime.bool_value(command.print_stdout)
		'run_as_real_uid':   brew_runtime.bool_value(command.run_as_real_uid)
		'safe':              brew_runtime.bool_value(command.safe)
	})
}

fn tap_new_result_value(result TapNewResult) brew_runtime.Value {
	mut commands := []brew_runtime.Value{}
	for command in result.git_commands {
		commands << tap_new_git_command_value(command)
	}
	return brew_runtime.map_value({
		'tap':                brew_runtime.string_value(result.tap)
		'path':               brew_runtime.string_value(result.path)
		'branch':             brew_runtime.string_value(result.branch)
		'root_url':           brew_runtime.string_value(result.root_url or { '' })
		'created_files':      brew_runtime.string_array_value(result.created_files)
		'set_git_name_email': brew_runtime.bool_value(result.set_git_name_email)
		'setup_git_gpg':      brew_runtime.bool_value(result.setup_git_gpg)
		'git_commands':       brew_runtime.array_value(commands)
		'headline':           brew_runtime.string_value(result.headline)
		'stdout':             brew_runtime.string_value(result.stdout)
	})
}

// Ruby method `run` at line 36.
pub fn ruby_tap_new_l36_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return tap_new_result_value(run_tap_new(tap_new_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('FatalError', err.msg())
	})
}

// Ruby method `render_workflow_template(filename, branch:, github_packages:, root_url: nil)` at line 150.
pub fn ruby_tap_new_l150_d2_render_workflow_template(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'render input is required')
	}
	input := tap_new_render_input_from_value(args[0])
	return brew_runtime.string_value(render_tap_new_workflow_template(input.filename, input.branch, input.github_packages, input.root_url, input.template, input.hour, input.minute))
}

// Ruby method `write_path(tap, filename, content)` at line 186.
pub fn ruby_tap_new_l186_d3_write_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'write input is required')
	}
	input := tap_new_write_input_from_value(args[0])
	path := write_tap_new_path(input.tap, input.filename, input.content) or {
		return brew_runtime.object_value('FatalError', err.msg())
	}
	return brew_runtime.string_value(path)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "system_command"
// 7: require "tap"
// 8: require "utils/uid"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class TapNew < AbstractCommand
// 13:       include FileUtils
// 14:       include SystemCommand::Mixin
// 15:
// 16:       cmd_args do
// 17:         usage_banner "`tap-new` [<options>] <user>`/`<repo>"
// 18:         description <<~EOS
// 19:           Generate the template files for a new tap.
// 20:         EOS
// 21:         switch "--no-git",
// 22:                description: "Don't initialise a Git repository for the tap."
// 23:         flag   "--pull-label=",
// 24:                description: "Ignored; publishing pull requests is now manually dispatched.",
// 25:                odeprecated: true
// 26:         flag   "--branch=",
// 27:                description: "Initialise a Git repository and set up GitHub Actions workflows with the " \
// 28:                             "specified branch name (default: `main`)."
// 29:         switch "--github-packages",
// 30:                description: "Upload bottles to GitHub Packages."
// 31:
// 32:         named_args :tap, number: 1
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         branch = args.branch || "main"
// 38:
// 39:         tap = args.named.to_taps.fetch(0)
// 40:         odie "Invalid tap name '#{tap}'" unless tap.path.to_s.match?(HOMEBREW_TAP_PATH_REGEX)
// 41:         odie "Tap is already installed!" if tap.installed?
// 42:
// 43:         titleized_user = tap.user.dup
// 44:         titleized_repository = tap.repository.dup
// 45:         titleized_user[0] = T.must(titleized_user[0]).upcase
// 46:         titleized_repository[0] = T.must(titleized_repository[0]).upcase
// 47:         root_url = GitHubPackages.root_url(tap.user, "homebrew-#{tap.repository}") if args.github_packages?
// 48:
// 49:         (tap.path/"Formula").mkpath
// 50:
// 51:         readme = <<~MARKDOWN
// 52:           # #{titleized_user} #{titleized_repository}
// 53:
// 54:           ## How do I install these formulae?
// 55:
// 56:           `brew install #{tap}/<formula>`
// 57:
// 58:           Or `brew tap #{tap}` and then `brew install <formula>`.
// 59:
// 60:           Or, in a `brew bundle` `Brewfile`:
// 61:
// 62:           ```ruby
// 63:           tap "#{tap}"
// 64:           brew "<formula>"
// 65:           ```
// 66:
// 67:           ## Documentation
// 68:
// 69:           `brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
// 70:         MARKDOWN
// 71:         write_path(tap, "README.md", readme)
// 72:
// 73:         dependabot_yml = <<~YAML
// 74:           version: 2
// 75:           updates:
// 76:             - package-ecosystem: github-actions
// 77:               directory: "/"
// 78:               schedule:
// 79:                 interval: weekly
// 80:               groups:
// 81:                 github-actions:
// 82:                   patterns:
// 83:                     - "*"
// 84:         YAML
// 85:
// 86:         tests_yml = render_workflow_template(
// 87:           "tap-new-tests.yml", branch:, github_packages: args.github_packages?, root_url:
// 88:         )
// 89:         publish_yml = render_workflow_template(
// 90:           "tap-new-publish.yml", branch:, github_packages: args.github_packages?
// 91:         )
// 92:         autobump_yml = render_workflow_template(
// 93:           "tap-new-autobump.yml", branch:, github_packages: args.github_packages?
// 94:         )
// 95:         (tap.path/".github/workflows").mkpath
// 96:         write_path(tap, ".github/dependabot.yml", dependabot_yml)
// 97:         write_path(tap, ".github/workflows/tests.yml", tests_yml)
// 98:         write_path(tap, ".github/workflows/publish.yml", publish_yml)
// 99:         write_path(tap, ".github/workflows/autobump.yml", autobump_yml)
// 100:
// 101:         unless args.no_git?
// 102:           cd tap.path do |path|
// 103:             Utils::Git.set_name_email!
// 104:             Utils::Git.setup_gpg!
// 105:
// 106:             safe_system "git", "init", "--initial-branch=#{branch}"
// 107:
// 108:             args = []
// 109:             git_owner = File.stat(File.join(path, ".git")).uid
// 110:             if git_owner != Process.uid && git_owner == Process.euid
// 111:               # Under Homebrew user model, EUID is permitted to execute commands under the UID.
// 112:               # Root users are never allowed (see brew.sh).
// 113:               args << "-c" << "safe.directory=#{path}"
// 114:             end
// 115:
// 116:             # Use the configuration of the original user, which will have author information and signing keys.
// 117:             env = { "HOME" => Utils::UID.uid_home }.compact
// 118:             env["TMPDIR"] = nil if (tmpdir = ENV.fetch("TMPDIR", nil)) && !File.writable_real?(tmpdir)
// 119:             system_command!("git", args: [*args, "add", "--all"], env:,
// 120:                             print_stdout: true, run_as_real_uid: true)
// 121:             system_command!("git", args: [*args, "commit", "-m", "Create #{tap} tap"], env:,
// 122:                             print_stdout: true, run_as_real_uid: true)
// 123:             system_command!("git", args: [*args, "branch", "-m", branch], env:,
// 124:                             print_stdout: true, run_as_real_uid: true)
// 125:           end
// 126:         end
// 127:
// 128:         ohai "Created #{tap}"
// 129:         puts <<~EOS
// 130:           #{tap.path}
// 131:
// 132:           When a pull request making changes to a formula (or formulae) becomes green
// 133:           (all checks passed), then you can publish the built bottles.
// 134:           To do so, run `brew pr-pull` locally or run the `brew pr-pull`
// 135:           workflow with the pull request number and, optionally, the pull
// 136:           request's expected head commit SHA.
// 137:         EOS
// 138:       end
// 139:
// 140:       private
// 141:
// 142:       sig {
// 143:         params(
// 144:           filename:        String,
// 145:           branch:          String,
// 146:           github_packages: T::Boolean,
// 147:           root_url:        T.nilable(String),
// 148:         ).returns(String)
// 149:       }
// 150:       def render_workflow_template(filename, branch:, github_packages:, root_url: nil)
// 151:         workflow = (HOMEBREW_LIBRARY_PATH.parent.parent/".github/workflows"/filename).read
// 152:         workflow.sub!("name: tap-new tests template", "name: brew test-bot")
// 153:         workflow.sub!("name: tap-new publish template", "name: brew pr-pull")
// 154:         workflow.sub!("name: tap-new autobump template", "name: brew bump")
// 155:         if filename == "tap-new-tests.yml"
// 156:           workflow.sub!("on:\n  workflow_dispatch:\n", <<~YAML)
// 157:             on:
// 158:               push:
// 159:                 branches:
// 160:                   - #{branch}
// 161:               pull_request:
// 162:           YAML
// 163:         end
// 164:         # Pick a random 5 minute block in which to execute the autobump action to avoid peak GitHub loads
// 165:         hour = Random.rand(24)
// 166:         minute = Random.rand(12) * 5
// 167:         workflow.gsub!("this will be changed later and randomised by brew tap-new") do
// 168:           "Every day at #{hour}:#{minute} UTC"
// 169:         end
// 170:         workflow.gsub!("\"1 1 1 1 1\"") { "#{minute} #{hour} * * *" }
// 171:
// 172:         workflow.sub!("    if: github.repository == ''\n", "")
// 173:         workflow.gsub!("TAP_NEW_BRANCH") { branch }
// 174:         workflow.gsub!("TAP_NEW_ROOT_URL_ARGUMENT") { root_url ? " --root-url=#{root_url}" : "" }
// 175:         unless github_packages
// 176:           workflow.gsub!(
// 177:             /^[ \t]*# tap-new-github-packages-start\n.*?^[ \t]*# tap-new-github-packages-end\n/m,
// 178:             "",
// 179:           )
// 180:         end
// 181:         workflow.gsub!(/^[ \t]*# tap-new-github-packages-(?:start|end)\n/, "")
// 182:         workflow
// 183:       end
// 184:
// 185:       sig { params(tap: Tap, filename: T.any(String, Pathname), content: String).void }
// 186:       def write_path(tap, filename, content)
// 187:         path = tap.path/filename
// 188:         tap.path.mkpath
// 189:         odie "#{path} already exists" if path.exist?
// 190:
// 191:         path.write content
// 192:       end
// 193:     end
// 194:   end
// 195: end
