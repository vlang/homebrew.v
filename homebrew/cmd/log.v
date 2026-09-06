module cmd

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
