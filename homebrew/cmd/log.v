module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/log.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GitLogOptions {
pub:
	patch     bool
	stat      bool
	oneline   bool
	one       bool
	max_count ?string
}

pub struct GitLogRequest {
pub:
	cd_dir              string
	path                ?string
	tap                 ?string
	repository_root     string
	homebrew_repository string
	path_is_file        bool
	shallow             bool
	original_path       string
	options             GitLogOptions
}

pub struct GitLogPlan {
pub:
	cd_dir      string
	environment map[string]string
	program     string
	arguments   []string
	warning     ?string
}

pub fn git_log_plan(request GitLogRequest) GitLogPlan {
	mut name := request.cd_dir
	mut git_cd := request.cd_dir
	if tap := request.tap {
		name = tap
		git_cd = '\$(brew --repo ${tap})'
	} else if request.cd_dir == request.homebrew_repository {
		name = 'Homebrew/brew'
		git_cd = '\$(brew --repo)'
	}
	warning := if request.shallow {
		'${name} is a shallow clone so only partial output will be shown.\nTo get a full clone, run:\n  git -C "${git_cd}" fetch --unshallow'
	} else {
		none
	}
	mut arguments := ['log']
	if request.options.patch {
		arguments << '--patch'
	}
	if request.options.stat {
		arguments << '--stat'
	}
	if request.options.oneline {
		arguments << '--oneline'
	}
	if request.options.one {
		arguments << '-1'
	}
	if max_count := request.options.max_count {
		arguments << '--max-count'
		arguments << max_count
	}
	if path := request.path {
		if request.path_is_file {
			arguments << '--follow'
			arguments << '--'
			arguments << path
		}
	}
	return GitLogPlan{
		cd_dir: request.cd_dir
		environment: {
			'PATH': request.original_path
		}
		program: 'git'
		arguments: arguments
		warning: warning
	}
}

pub fn git_log_request_value(request GitLogRequest) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'GitLogRequest'
		repr: request.cd_dir
		attributes: {
			'cd_dir':              request.cd_dir
			'path':                request.path or { '' }
			'has_path':            (request.path != none).str()
			'tap':                 request.tap or { '' }
			'has_tap':             (request.tap != none).str()
			'repository_root':     request.repository_root
			'homebrew_repository': request.homebrew_repository
			'path_is_file':        request.path_is_file.str()
			'shallow':             request.shallow.str()
			'original_path':       request.original_path
			'patch':               request.options.patch.str()
			'stat':                request.options.stat.str()
			'oneline':             request.options.oneline.str()
			'one':                 request.options.one.str()
			'max_count':           request.options.max_count or { '' }
			'has_max_count':       (request.options.max_count != none).str()
		}
	}
}

fn git_log_request_from_value(value brew_runtime.Value) !GitLogRequest {
	if value.type_name != 'GitLogRequest' {
		return error('expected GitLogRequest, got ${value.type_name}')
	}
	return GitLogRequest{
		cd_dir: value.attribute('cd_dir')!
		path: if (value.attribute('has_path') or { 'false' }) == 'true' {
			?string(value.attribute('path') or { '' })} else {
			none}
		tap: if (value.attribute('has_tap') or { 'false' }) == 'true' {
			?string(value.attribute('tap') or { '' })} else {
			none}
		repository_root: value.attribute('repository_root') or { '' }
		homebrew_repository: value.attribute('homebrew_repository') or { '' }
		path_is_file: (value.attribute('path_is_file') or { 'false' }) == 'true'
		shallow: (value.attribute('shallow') or { 'false' }) == 'true'
		original_path: value.attribute('original_path') or { '' }
		options: GitLogOptions{
			patch: (value.attribute('patch') or { 'false' }) == 'true'
			stat: (value.attribute('stat') or { 'false' }) == 'true'
			oneline: (value.attribute('oneline') or { 'false' }) == 'true'
			one: (value.attribute('one') or { 'false' }) == 'true'
			max_count: if (value.attribute('has_max_count') or { 'false' }) == 'true' {
				?string(value.attribute('max_count') or { '' })} else {
				none}
		}
	}
}

fn git_log_plan_value(plan GitLogPlan) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in plan.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.Value{
		type_name: 'GitLogPlan'
		repr: '${plan.program} ${plan.arguments.join(' ')}'
		attributes: {
			'cd_dir':  plan.cd_dir
			'program': plan.program
			'warning': plan.warning or { '' }
		}
		map_data: {
			'arguments':   brew_runtime.string_array_value(plan.arguments)
			'environment': brew_runtime.map_value(environment)
		}
	}
}

// Ruby method `run` at line 39.
pub fn ruby_log_l39_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'Log#run requires an execution request')
	}
	request := git_log_request_from_value(args[0]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	return git_log_plan_value(git_log_plan(request))
}

// Ruby method `git_log(cd_dir, path = nil, tap = nil)` at line 56.
pub fn ruby_log_l56_d2_git_log(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_log_l39_d1_run(...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Log < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Show the `git log` for <formula> or <cask>, or show the log for the Homebrew repository
// 15:           if no formula or cask is provided.
// 16:         EOS
// 17:         switch "-p", "-u", "--patch",
// 18:                description: "Also print patch from commit."
// 19:         switch "--stat",
// 20:                description: "Also print diffstat from commit."
// 21:         switch "--oneline",
// 22:                description: "Print only one line per commit."
// 23:         switch "-1",
// 24:                description: "Print only one commit."
// 25:         flag   "-n", "--max-count=",
// 26:                description: "Print only a specified number of commits."
// 27:         switch "--formula", "--formulae",
// 28:                description: "Treat all named arguments as formulae."
// 29:         switch "--cask", "--casks",
// 30:                description: "Treat all named arguments as casks."
// 31:
// 32:         conflicts "-1", "--max-count"
// 33:         conflicts "--formula", "--cask"
// 34:
// 35:         named_args [:formula, :cask], max: 1, without_api: true
// 36:       end
// 37:
// 38:       sig { override.void }
// 39:       def run
// 40:         # As this command is simplifying user-run commands then let's just use a
// 41:         # user path, too.
// 42:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 43:
// 44:         if args.no_named?
// 45:           git_log(HOMEBREW_REPOSITORY)
// 46:         else
// 47:           path = args.named.to_paths.fetch(0)
// 48:           tap = Tap.from_path(path)
// 49:           git_log path.dirname, path, tap
// 50:         end
// 51:       end
// 52:
// 53:       private
// 54:
// 55:       sig { params(cd_dir: Pathname, path: T.nilable(Pathname), tap: T.nilable(Tap)).void }
// 56:       def git_log(cd_dir, path = nil, tap = nil)
// 57:         cd cd_dir do
// 58:           repo = Utils.popen_read("git", "rev-parse", "--show-toplevel").chomp
// 59:           if tap
// 60:             name = tap.to_s
// 61:             git_cd = "$(brew --repo #{tap})"
// 62:           elsif cd_dir == HOMEBREW_REPOSITORY
// 63:             name = "Homebrew/brew"
// 64:             git_cd = "$(brew --repo)"
// 65:           else
// 66:             name, git_cd = cd_dir
// 67:           end
// 68:
// 69:           if File.exist? "#{repo}/.git/shallow"
// 70:             opoo <<~EOS
// 71:               #{name} is a shallow clone so only partial output will be shown.
// 72:               To get a full clone, run:
// 73:                 git -C "#{git_cd}" fetch --unshallow
// 74:             EOS
// 75:           end
// 76:
// 77:           git_args = []
// 78:           git_args << "--patch" if args.patch?
// 79:           git_args << "--stat" if args.stat?
// 80:           git_args << "--oneline" if args.oneline?
// 81:           git_args << "-1" if args.public_send(:"1?")
// 82:           git_args << "--max-count" << args.max_count if args.max_count
// 83:           git_args += ["--follow", "--", path] if path&.file?
// 84:           system "git", "log", *git_args
// 85:         end
// 86:       end
// 87:     end
// 88:   end
// 89: end
