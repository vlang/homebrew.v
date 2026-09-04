module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/stage_only.rb`.

pub struct StageOnly {
pub:
	cask_token string
	value      bool
}

pub fn stage_only_from_args(cask_token string, arguments []string,
	has_keyword_arguments bool) !StageOnly {
	if arguments.len != 1 || arguments[0] != 'true' || has_keyword_arguments {
		return error('${cask_token}: `stage_only` takes only a single argument: true')
	}
	return StageOnly{
		cask_token: cask_token
		value: true
	}
}

pub fn (stage StageOnly) to_array() []bool {
	return [true]
}

pub fn (stage StageOnly) summarize() string {
	return 'true'
}
