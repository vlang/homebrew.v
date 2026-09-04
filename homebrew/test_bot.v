module homebrew

import ruby
import os

// Translated from Homebrew/brew `test_bot.rb`.

pub const test_bot_git = '/usr/bin/git'

pub struct TestBotArgs {
pub:
	cleanup              bool
	local_mode           bool
	only_cleanup_before  bool
	only_tap_syntax      bool
	only_formulae_detect bool
	only_bottles_fetch   bool
	only_cleanup_after   bool
	only_formulae        bool
	tap                  string
	git_name             string
	git_email            string
}

pub struct TestBotTap {
pub:
	name        string
	full_name   string
	path        string
	official    bool
	core_tap    bool
	installed   bool = true
	path_exists bool = true
	shallow     bool
}

pub struct TestBotSandboxResult {
pub:
	attempted  bool
	configured bool
	ensured    bool
	disabled   bool
	reset      bool
}

pub struct TestBotRunContext {
pub:
	cwd                 string
	prefix              string
	repository          string
	github_actions      bool
	github_repository   string
	github_owner        string
	sandbox_linux       bool
	sandbox_configured  bool = true
	core_tap_full_name  string = 'Homebrew/homebrew-core'
	core_tap_path       string
	core_tap_installed  bool
	gitconfig           string
	trust_file          string
	brew_version        string
	brew_commit_subject string
	core_revision       string
	tap_revision        string
	runner_success      bool = true
	environment         map[string]string
}

pub struct TestBotRunResult {
pub:
	environment map[string]string
	tap         ?TestBotTap
	actions     []string
	output      []string
	sandbox     TestBotSandboxResult
	failed      bool
}

pub fn test_bot_cleanup(args TestBotArgs, github_actions bool) bool {
	return args.cleanup || github_actions
}

pub fn test_bot_local(args TestBotArgs, github_actions bool) bool {
	return args.local_mode || github_actions
}

pub fn test_bot_trust_tap(tap ?TestBotTap, newly_trusted bool) ?string {
	actual := tap or { return none }
	if actual.official {
		return none
	}
	action := if newly_trusted { 'Trusted' } else { 'Already trusted' }
	return '${action} tap: ${actual.name}'
}

pub fn test_bot_setup_github_actions_sandbox(github_actions bool, sandbox_linux bool,
	configured bool, owner string) TestBotSandboxResult {
	if !github_actions || !sandbox_linux {
		return TestBotSandboxResult{}
	}
	if configured {
		return TestBotSandboxResult{ attempted: true, configured: true }
	}
	return TestBotSandboxResult{
		attempted: true
		ensured: owner == 'Homebrew'
		disabled: true
		reset: true
	}
}

fn test_bot_valid_repository_component(value string) bool {
	if value == '' {
		return false
	}
	for character in value {
		if !character.is_alnum() && character != `_` && character != `-` {
			return false
		}
	}
	return true
}

fn test_bot_repository_path(raw string) string {
	mut path := raw.trim_space()
	for prefix in ['https://github.com/', 'http://github.com/'] {
		if path.starts_with(prefix) {
			path = path[prefix.len..]
			break
		}
	}
	path = path.trim_right('/')
	if path.ends_with('.git') {
		path = path[..path.len - 4]
	}
	return path
}

pub fn test_bot_resolve_test_tap(explicit_tap ?string, github_repository string,
	core_full_name string) ?TestBotTap {
	mut path := explicit_tap or { test_bot_repository_path(github_repository) }
	if path == '' {
		return none
	}
	path = test_bot_repository_path(path)
	if path.to_lower() == core_full_name.to_lower()
		|| path.to_lower() in ['homebrew/core', 'homebrew/homebrew-core'] {
		return TestBotTap{
			name: 'homebrew/core'
			full_name: core_full_name
			official: true
			core_tap: true
		}
	}
	parts := path.split('/')
	if parts.len != 2 || !test_bot_valid_repository_component(parts[0])
		|| !parts[1].starts_with('homebrew-') {
		return none
	}
	repository := parts[1]['homebrew-'.len..]
	if !test_bot_valid_repository_component(repository) {
		return none
	}
	return TestBotTap{
		name: '${parts[0]}/${repository}'
		full_name: path
		official: parts[0].to_lower() == 'homebrew'
	}
}

fn test_bot_exclusive_mode(args TestBotArgs) bool {
	return args.only_cleanup_before || args.only_tap_syntax || args.only_formulae_detect
		|| args.only_bottles_fetch || args.only_cleanup_after
}

pub fn test_bot_run(args TestBotArgs, context TestBotRunContext) !TestBotRunResult {
	if os.real_path(context.cwd) == os.real_path(context.prefix)
		&& test_bot_cleanup(args, context.github_actions) {
		return error('UsageError: cannot use --cleanup from HOMEBREW_PREFIX as it will delete all output.')
	}
	mut environment := context.environment.clone()
	for key, value in {
		'HOMEBREW_DEVELOPER':                     '1'
		'HOMEBREW_NO_AUTO_UPDATE':                '1'
		'HOMEBREW_NO_EMOJI':                      '1'
		'HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK': '1'
		'HOMEBREW_FAIL_LOG_LINES':                '150'
		'HOMEBREW_CURL':                          '/usr/bin/curl'
		'HOMEBREW_CURL_PATH':                     '/usr/bin/curl'
		'HOMEBREW_GIT':                           test_bot_git
		'HOMEBREW_GIT_PATH':                      test_bot_git
		'HOMEBREW_DISALLOW_LIBNSL1':              '1'
		'HOMEBREW_NO_ENV_HINTS':                  '1'
	} {
		environment[key] = value
	}
	original_path := environment['PATH'] or { '' }
	environment['HOMEBREW_PATH'] = '${context.prefix}/bin:${context.prefix}/sbin:${original_path}'
	environment['PATH'] = environment['HOMEBREW_PATH']
	if test_bot_local(args, context.github_actions) {
		home := os.join_path(context.cwd, 'home')
		user_config := os.join_path(home, '.homebrew')
		logs := os.join_path(context.cwd, 'logs')
		environment['HOMEBREW_HOME'] = home
		environment['HOME'] = home
		environment['HOMEBREW_USER_CONFIG_HOME'] = user_config
		environment['HOMEBREW_LOGS'] = logs
		os.mkdir_all(user_config)!
		os.chmod(user_config, 0o700)!
		os.mkdir_all(logs)!
		if os.is_file(context.gitconfig) {
			os.cp(context.gitconfig, os.join_path(home, os.file_name(context.gitconfig)))!
		}
		if os.is_file(context.trust_file) {
			os.cp(context.trust_file, os.join_path(user_config, os.file_name(context.trust_file)))!
		}
	}
	mut sandbox := TestBotSandboxResult{}
	if !test_bot_exclusive_mode(args) {
		sandbox = test_bot_setup_github_actions_sandbox(context.github_actions, context.sandbox_linux, context.sandbox_configured, context.github_owner)
		if sandbox.disabled {
			environment['HOMEBREW_NO_SANDBOX_LINUX'] = '1'
		}
	}
	mut resolved_tap := ?TestBotTap(none)
	if tap := test_bot_resolve_test_tap(if args.tap != '' { ?string(args.tap) } else { none }, context.github_repository, context.core_tap_full_name) {
		resolved_tap = tap
	}
	mut actions := []string{}
	mut output := []string{}
	if tap := resolved_tap {
		if tap.core_tap {
			environment['HOMEBREW_NO_INSTALL_FROM_API'] = '1'
			if args.only_formulae {
				environment['HOMEBREW_VERIFY_ATTESTATIONS'] = '1'
			}
		}
		if !tap.path_exists {
			actions << 'brew tap ${tap.name}'
		} else if tap.shallow {
			actions << '${test_bot_git} -C ${tap.path} fetch --unshallow'
		}
		if trust_message := test_bot_trust_tap(tap, true) {
			output << trust_message
		}
	}
	if context.brew_version != '' || context.brew_commit_subject != '' {
		output << 'Using Homebrew/brew ${context.brew_version} (${context.brew_commit_subject})'
	}
	if tap := resolved_tap {
		if context.tap_revision != '' {
			repository_suffix := if tap.full_name != context.github_repository
				&& context.github_repository != '' {
				' (${context.github_repository})'
			} else {
				''
			}
			output << 'Testing ${tap.full_name}${repository_suffix} ${context.tap_revision}:'
		}
	}
	environment['HOMEBREW_GIT_NAME'] = if args.git_name != '' {
		args.git_name
	} else {
		'BrewTestBot'
	}
	environment['HOMEBREW_GIT_EMAIL'] = if args.git_email != '' {
		args.git_email
	} else {
		'1589480+BrewTestBot@users.noreply.github.com'
	}
	return TestBotRunResult{
		environment: environment
		tap: resolved_tap
		actions: actions
		output: output
		sandbox: sandbox
		failed: !context.runner_success
	}
}

fn test_bot_args_from_value(value ruby.Value) TestBotArgs {
	return TestBotArgs{
		cleanup: (value.attributes['cleanup'] or { 'false' }).bool()
		local_mode: (value.attributes['local'] or { 'false' }).bool()
		only_cleanup_before: (value.attributes['only_cleanup_before'] or { 'false' }).bool()
		only_tap_syntax: (value.attributes['only_tap_syntax'] or { 'false' }).bool()
		only_formulae_detect: (value.attributes['only_formulae_detect'] or { 'false' }).bool()
		only_bottles_fetch: (value.attributes['only_bottles_fetch'] or { 'false' }).bool()
		only_cleanup_after: (value.attributes['only_cleanup_after'] or { 'false' }).bool()
		only_formulae: (value.attributes['only_formulae'] or { 'false' }).bool()
		tap: value.attributes['tap'] or { '' }
		git_name: value.attributes['git_name'] or { '' }
		git_email: value.attributes['git_email'] or { '' }
	}
}

fn test_bot_tap_value(tap ?TestBotTap) ruby.Value {
	actual := tap or { return ruby.object_value('NilClass', 'nil') }
	return ruby.structured_value('Tap', actual.name, {
		'name':      actual.name
		'full_name': actual.full_name
		'official':  actual.official.str()
		'core_tap':  actual.core_tap.str()
	})
}

fn test_bot_environment_value(environment map[string]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, value in environment {
		values[key] = ruby.string_value(value)
	}
	return ruby.map_value(values)
}
