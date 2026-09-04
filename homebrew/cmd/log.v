module cmd

import ruby

// Translated from Homebrew/brew `cmd/log.rb`.
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

pub fn git_log_request_value(request GitLogRequest) ruby.Value {
	return ruby.Value{
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

fn git_log_request_from_value(value ruby.Value) !GitLogRequest {
	if value.type_name != 'GitLogRequest' {
		return error('expected GitLogRequest, got ${value.type_name}')
	}
	return GitLogRequest{
		cd_dir: value.attribute('cd_dir')!
		path: if (value.attribute('has_path') or { 'false' }) == 'true' {
			?string(value.attribute('path') or { '' })
		} else {
			none
		}
		tap: if (value.attribute('has_tap') or { 'false' }) == 'true' {
			?string(value.attribute('tap') or { '' })
		} else {
			none
		}
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
				?string(value.attribute('max_count') or { '' })
			} else {
				none
			}
		}
	}
}

fn git_log_plan_value(plan GitLogPlan) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for name, value in plan.environment {
		environment[name] = ruby.string_value(value)
	}
	return ruby.Value{
		type_name: 'GitLogPlan'
		repr: '${plan.program} ${plan.arguments.join(' ')}'
		attributes: {
			'cd_dir':  plan.cd_dir
			'program': plan.program
			'warning': plan.warning or { '' }
		}
		map_data: {
			'arguments':   ruby.string_array_value(plan.arguments)
			'environment': ruby.map_value(environment)
		}
	}
}
