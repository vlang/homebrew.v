module dev_cmd

import ruby
import os
import rand

// Translated from Homebrew/brew `dev-cmd/tap-new.rb`.

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

pub fn tap_new_input_boundary(input &TapNewInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::TapNew::Input', '', {
		'tap_new_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_input_from_value(value ruby.Value) &TapNewInput {
	address := value.attributes['tap_new_input_address'] or { panic('invalid TapNew input') }
	return unsafe { &TapNewInput(voidptr(address.u64())) }
}

pub fn tap_new_render_input_boundary(input &TapNewRenderInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::TapNew::RenderInput', '', {
		'tap_new_render_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_render_input_from_value(value ruby.Value) &TapNewRenderInput {
	address := value.attributes['tap_new_render_input_address'] or {
		panic('invalid TapNew render input')
	}
	return unsafe { &TapNewRenderInput(voidptr(address.u64())) }
}

pub fn tap_new_write_input_boundary(input &TapNewWriteInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::TapNew::WriteInput', '', {
		'tap_new_write_input_address': u64(voidptr(input)).str()
	})
}

fn tap_new_write_input_from_value(value ruby.Value) &TapNewWriteInput {
	address := value.attributes['tap_new_write_input_address'] or {
		panic('invalid TapNew write input')
	}
	return unsafe { &TapNewWriteInput(voidptr(address.u64())) }
}

fn tap_new_git_command_value(command TapNewGitCommand) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for key, value in command.environment {
		environment[key] = ruby.string_value(value)
	}
	return ruby.map_value({
		'program':           ruby.string_value(command.program)
		'arguments':         ruby.string_array_value(command.arguments)
		'working_directory': ruby.string_value(command.working_directory)
		'environment':       ruby.map_value(environment)
		'unset_environment': ruby.string_array_value(command.unset_environment)
		'print_stdout':      ruby.bool_value(command.print_stdout)
		'run_as_real_uid':   ruby.bool_value(command.run_as_real_uid)
		'safe':              ruby.bool_value(command.safe)
	})
}

fn tap_new_result_value(result TapNewResult) ruby.Value {
	mut commands := []ruby.Value{}
	for command in result.git_commands {
		commands << tap_new_git_command_value(command)
	}
	return ruby.map_value({
		'tap':                ruby.string_value(result.tap)
		'path':               ruby.string_value(result.path)
		'branch':             ruby.string_value(result.branch)
		'root_url':           ruby.string_value(result.root_url or { '' })
		'created_files':      ruby.string_array_value(result.created_files)
		'set_git_name_email': ruby.bool_value(result.set_git_name_email)
		'setup_git_gpg':      ruby.bool_value(result.setup_git_gpg)
		'git_commands':       ruby.array_value(commands)
		'headline':           ruby.string_value(result.headline)
		'stdout':             ruby.string_value(result.stdout)
	})
}
