module homebrew

import ruby

// Translated from Homebrew/brew `api_hashable.rb`.
pub struct ApiHashableState {
pub mut:
	generating_hash       bool
	old_homebrew_prefix   string
	old_home              string
	old_git_config_global string
	homebrew_prefix       string
	home                  string
	git_config_global     string
}

pub struct PlaceholderPaths {
pub:
	prefix string
	cellar string
	home   string
}

pub fn (mut state ApiHashableState) start_generating_hash() {
	if state.generating_hash {
		return
	}
	state.old_homebrew_prefix = state.homebrew_prefix
	state.old_home = state.home
	state.old_git_config_global = state.git_config_global
	state.homebrew_prefix = r'$HOMEBREW_PREFIX'
	state.home = r'/$HOME'
	state.git_config_global = ruby.join_path(state.old_home, '.gitconfig')
	state.generating_hash = true
}

pub fn (mut state ApiHashableState) finish_generating_hash() {
	if !state.generating_hash {
		return
	}
	state.homebrew_prefix = state.old_homebrew_prefix
	state.home = state.old_home
	state.git_config_global = state.old_git_config_global
	state.generating_hash = false
}
