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

pub fn deep_remove_placeholders(value ruby.Value, generating_hash bool,
	paths PlaceholderPaths) ruby.Value {
	if generating_hash {
		return value
	}
	if value.type_name == 'String' {
		return ruby.string_value(value.as_string().replace(r'$HOMEBREW_PREFIX', paths.prefix).replace(r'$HOMEBREW_CELLAR', paths.cellar).replace(r'/$HOME', paths.home))
	}
	if value.type_name == 'Array' {
		values := value.as_array() or { return value }
		return ruby.array_value(values.map(deep_remove_placeholders(it, false, paths)))
	}
	if value.attributes.len > 0 {
		mut attributes := map[string]string{}
		for key, attribute in value.attributes {
			attributes[key] = attribute.replace(r'$HOMEBREW_PREFIX', paths.prefix).replace(r'$HOMEBREW_CELLAR', paths.cellar).replace(r'/$HOME', paths.home)
		}
		return ruby.structured_value(value.type_name, value.repr, attributes)
	}
	return value
}
