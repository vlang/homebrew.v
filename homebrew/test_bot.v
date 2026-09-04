module homebrew

import ruby
import os

// Translated from Homebrew/brew `test_bot.rb`.
// The original source is retained below for exact boundary auditing.

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

// Ruby method `cleanup?(args)` at line 33.
pub fn ruby_test_bot_l33_d1_cleanup(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { test_bot_args_from_value(args[0]) } else { TestBotArgs{} }
	github_actions := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return ruby.bool_value(test_bot_cleanup(options, github_actions))
}

// Ruby method `local?(args)` at line 38.
pub fn ruby_test_bot_l38_d2_local(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { test_bot_args_from_value(args[0]) } else { TestBotArgs{} }
	github_actions := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return ruby.bool_value(test_bot_local(options, github_actions))
}

// Ruby method `trust_test_tap!(tap)` at line 43.
pub fn ruby_test_bot_l43_d3_trust_test_tap(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.object_value('NilClass', 'nil')
	}
	tap := TestBotTap{
		name: args[0].attributes['name'] or { args[0].as_string() }
		official: (args[0].attributes['official'] or { 'false' }).bool()
	}
	newly_trusted := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	return if message := test_bot_trust_tap(tap, newly_trusted) {
		ruby.string_value(message)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `setup_github_actions_sandbox!` at line 51.
pub fn ruby_test_bot_l51_d4_setup_github_actions_sandbox(args ...ruby.Value) ruby.Value {
	github_actions := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	sandbox_linux := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	configured := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	owner := if args.len > 3 { args[3].as_string() } else { '' }
	result := test_bot_setup_github_actions_sandbox(github_actions, sandbox_linux, configured, owner)
	return ruby.structured_value('SandboxResult', '', {
		'attempted':  result.attempted.str()
		'configured': result.configured.str()
		'ensured':    result.ensured.str()
		'disabled':   result.disabled.str()
		'reset':      result.reset.str()
	})
}

// Ruby method `configure_sandbox! = true` at line 67.
pub fn ruby_test_bot_l67_d5_configure_sandbox(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(true)
}

// Ruby method `resolve_test_tap(tap = nil)` at line 70.
pub fn ruby_test_bot_l70_d6_resolve_test_tap(args ...ruby.Value) ruby.Value {
	explicit := if args.len > 0 && args[0].type_name != 'NilClass' && args[0].as_string() != '' {
		?string(args[0].as_string())
	} else {
		none
	}
	github_repository := if args.len > 1 { args[1].as_string() } else { '' }
	core_full_name := if args.len > 2 { args[2].as_string() } else { 'Homebrew/homebrew-core' }
	return test_bot_tap_value(test_bot_resolve_test_tap(explicit, github_repository, core_full_name))
}

// Ruby method `run!(args)` at line 92.
pub fn ruby_test_bot_l92_d7_run(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { test_bot_args_from_value(args[0]) } else { TestBotArgs{} }
	context_value := if args.len > 1 { args[1] } else { ruby.Value{} }
	context := TestBotRunContext{
		cwd: context_value.attributes['cwd'] or { os.getwd() }
		prefix: context_value.attributes['prefix'] or { '/home/linuxbrew/.linuxbrew' }
		github_actions: (context_value.attributes['github_actions'] or { 'false' }).bool()
		github_repository: context_value.attributes['github_repository'] or { '' }
		github_owner: context_value.attributes['github_owner'] or { '' }
		sandbox_linux: (context_value.attributes['sandbox_linux'] or { 'false' }).bool()
		sandbox_configured: (context_value.attributes['sandbox_configured'] or { 'true' }).bool()
		runner_success: (context_value.attributes['runner_success'] or { 'true' }).bool()
		environment: {
			'PATH': context_value.attributes['path'] or { '' }
		}
	}
	result := test_bot_run(options, context) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return ruby.map_value({
		'environment': test_bot_environment_value(result.environment)
		'tap':         test_bot_tap_value(result.tap)
		'actions':     ruby.string_array_value(result.actions)
		'output':      ruby.string_array_value(result.output)
		'failed':      ruby.bool_value(result.failed)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot/step"
// 5: require "test_bot/test_runner"
// 6:
// 7: require "date"
// 8: require "env_config"
// 9: require "json"
// 10:
// 11: require "development_tools"
// 12: require "formula"
// 13: require "formula_installer"
// 14: require "os"
// 15: require "tap"
// 16: require "trust"
// 17: require "utils"
// 18: require "utils/bottles"
// 19: require "utils/output"
// 20: require "utils/portable_ruby"
// 21:
// 22: module Homebrew
// 23:   module TestBot
// 24:     extend Utils::Output::Mixin
// 25:
// 26:     module_function
// 27:
// 28:     GIT = "/usr/bin/git"
// 29:
// 30:     HOMEBREW_TAP_REGEX = %r{^([\w-]+)/homebrew-([\w-]+)$}
// 31:
// 32:     sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 33:     def cleanup?(args)
// 34:       args.cleanup? || GitHub::Actions.env_set?
// 35:     end
// 36:
// 37:     sig { params(args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 38:     def local?(args)
// 39:       args.local? || GitHub::Actions.env_set?
// 40:     end
// 41:
// 42:     sig { params(tap: T.nilable(Tap)).void }
// 43:     def trust_test_tap!(tap)
// 44:       return if tap.nil? || tap.official?
// 45:
// 46:       action = Homebrew::Trust.trust!(:tap, tap) ? "Trusted" : "Already trusted"
// 47:       Homebrew::TestBot.ohai "#{action} tap: #{tap.name}"
// 48:     end
// 49:
// 50:     sig { void }
// 51:     def setup_github_actions_sandbox!
// 52:       return unless GitHub::Actions.env_set?
// 53:
// 54:       # TODO: odeprecated: make Linux sandbox support mandatory when using `test-bot`.
// 55:       return unless Homebrew::EnvConfig.sandbox_linux?
// 56:
// 57:       return if configure_sandbox!
// 58:
// 59:       require "sandbox"
// 60:       Sandbox.ensure_sandbox_available! if ENV["GITHUB_REPOSITORY_OWNER"] == "Homebrew"
// 61:
// 62:       ENV["HOMEBREW_NO_SANDBOX_LINUX"] = "1"
// 63:       Sandbox.reset_state!
// 64:     end
// 65:
// 66:     sig { returns(T::Boolean) }
// 67:     def configure_sandbox! = true
// 68:
// 69:     sig { params(tap: T.nilable(String)).returns(T.nilable(Tap)) }
// 70:     def resolve_test_tap(tap = nil)
// 71:       return Tap.fetch(tap) if tap
// 72:
// 73:       # Get tap from GitHub Actions GITHUB_REPOSITORY
// 74:       git_url = ENV.fetch("GITHUB_REPOSITORY", nil)
// 75:       return if git_url.blank?
// 76:
// 77:       url_path = git_url.sub(%r{^https?://github\.com/}, "")
// 78:                         .chomp("/")
// 79:                         .sub(/\.git$/, "")
// 80:
// 81:       return CoreTap.instance if url_path == CoreTap.instance.full_name
// 82:
// 83:       begin
// 84:         Tap.fetch(url_path) if url_path.match?(HOMEBREW_TAP_REGEX)
// 85:       rescue
// 86:         # Don't care if tap fetch fails
// 87:         nil
// 88:       end
// 89:     end
// 90:
// 91:     sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 92:     def run!(args)
// 93:       $stdout.sync = true
// 94:       $stderr.sync = true
// 95:
// 96:       if Pathname.pwd == HOMEBREW_PREFIX && cleanup?(args)
// 97:         raise UsageError, "cannot use --cleanup from HOMEBREW_PREFIX as it will delete all output."
// 98:       end
// 99:
// 100:       ENV["HOMEBREW_DEVELOPER"] = "1"
// 101:       ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
// 102:       ENV["HOMEBREW_NO_EMOJI"] = "1"
// 103:       ENV["HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK"] = "1"
// 104:       ENV["HOMEBREW_FAIL_LOG_LINES"] = "150"
// 105:       ENV["HOMEBREW_CURL"] = ENV["HOMEBREW_CURL_PATH"] = "/usr/bin/curl"
// 106:       ENV["HOMEBREW_GIT"] = ENV["HOMEBREW_GIT_PATH"] = GIT
// 107:       ENV["HOMEBREW_DISALLOW_LIBNSL1"] = "1"
// 108:       ENV["HOMEBREW_NO_ENV_HINTS"] = "1"
// 109:       ENV["HOMEBREW_PATH"] = ENV["PATH"] =
// 110:         "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:#{ENV.fetch("PATH")}"
// 111:
// 112:       if local?(args)
// 113:         home = "#{Dir.pwd}/home"
// 114:         logs = "#{Dir.pwd}/logs"
// 115:         gitconfig = "#{Dir.home}/.gitconfig"
// 116:         trust_file = Homebrew::Trust.trust_file
// 117:         ENV["HOMEBREW_HOME"] = ENV["HOME"] = home
// 118:         ENV["HOMEBREW_USER_CONFIG_HOME"] = "#{home}/.homebrew"
// 119:         ENV["HOMEBREW_LOGS"] = logs
// 120:         FileUtils.mkdir_p home
// 121:         FileUtils.mkdir_p ENV.fetch("HOMEBREW_USER_CONFIG_HOME")
// 122:         FileUtils.chmod 0700, ENV.fetch("HOMEBREW_USER_CONFIG_HOME")
// 123:         FileUtils.mkdir_p logs
// 124:         FileUtils.cp gitconfig, home if File.exist?(gitconfig)
// 125:         FileUtils.cp trust_file, ENV.fetch("HOMEBREW_USER_CONFIG_HOME") if trust_file.exist?
// 126:       end
// 127:
// 128:       if !args.only_cleanup_before? &&
// 129:          !args.only_tap_syntax? &&
// 130:          !args.only_formulae_detect? &&
// 131:          !args.only_bottles_fetch? &&
// 132:          !args.only_cleanup_after?
// 133:         setup_github_actions_sandbox!
// 134:       end
// 135:
// 136:       tap = resolve_test_tap(args.tap)
// 137:
// 138:       if tap&.core_tap?
// 139:         ENV["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
// 140:         ENV["HOMEBREW_VERIFY_ATTESTATIONS"] = "1" if args.only_formulae?
// 141:       end
// 142:
// 143:       # Tap repository if required, this is done before everything else
// 144:       # because Formula parsing and/or git commit hash lookup depends on it.
// 145:       # At the same time, make sure Tap is not a shallow clone.
// 146:       # bottle rebuild and bottle upload rely on full clone.
// 147:       if tap
// 148:         if !tap.path.exist?
// 149:           safe_system "brew", "tap", tap.name
// 150:         elsif (tap.path/".git/shallow").exist?
// 151:           raise unless quiet_system GIT, "-C", tap.path, "fetch", "--unshallow"
// 152:         end
// 153:
// 154:         trust_test_tap!(tap)
// 155:       end
// 156:
// 157:       brew_version = Utils.safe_popen_read(
// 158:         GIT, "-C", HOMEBREW_REPOSITORY.to_s,
// 159:         "describe", "--tags", "--abbrev", "--dirty"
// 160:       ).strip
// 161:       brew_commit_subject = Utils.safe_popen_read(
// 162:         GIT, "-C", HOMEBREW_REPOSITORY.to_s,
// 163:         "log", "-1", "--format=%s"
// 164:       ).strip
// 165:       puts Formatter.headline("Using Homebrew/brew #{brew_version} (#{brew_commit_subject})", color: :cyan)
// 166:
// 167:       if tap.to_s != CoreTap.instance.name && CoreTap.instance.installed?
// 168:         core_revision = Utils.safe_popen_read(
// 169:           GIT, "-C", CoreTap.instance.path.to_s,
// 170:           "log", "-1", "--format=%h (%s)"
// 171:         ).strip
// 172:         puts Formatter.headline("Using #{CoreTap.instance.full_name} #{core_revision}", color: :cyan)
// 173:       end
// 174:
// 175:       if tap
// 176:         tap_github = " (#{ENV["GITHUB_REPOSITORY"]})" if tap.full_name != ENV["GITHUB_REPOSITORY"]
// 177:         tap_revision = Utils.safe_popen_read(
// 178:           GIT, "-C", tap.path.to_s,
// 179:           "log", "-1", "--format=%h (%s)"
// 180:         ).strip
// 181:         puts Formatter.headline("Testing #{tap.full_name}#{tap_github} #{tap_revision}:", color: :cyan)
// 182:       end
// 183:
// 184:       ENV["HOMEBREW_GIT_NAME"] = args.git_name || "BrewTestBot"
// 185:       ENV["HOMEBREW_GIT_EMAIL"] = args.git_email ||
// 186:                                   "1589480+BrewTestBot@users.noreply.github.com"
// 187:
// 188:       Homebrew.failed = !TestRunner.run!(tap, git: GIT, args:)
// 189:     end
// 190:   end
// 191: end
// 192:
// 193: require "extend/os/test_bot"
