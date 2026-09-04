module homebrew

import ruby

// Translated from Homebrew/brew `api_hashable.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `generating_hash!` at line 7.
pub fn ruby_api_hashable_l7_d1_generating_hash(args ...ruby.Value) ruby.Value {
	mut state := ApiHashableState{
		homebrew_prefix: if args.len > 0 { args[0].as_string() } else { '' }
		home: if args.len > 1 {
			args[1].as_string()} else {
			ruby.environment_value('HOME')}
		git_config_global: if args.len > 2 {
			args[2].as_string()} else {
			ruby.environment_value('GIT_CONFIG_GLOBAL')}
	}
	state.start_generating_hash()
	return ruby.structured_value('APIHashableState', state.homebrew_prefix, {
		'generating_hash':       state.generating_hash.str()
		'old_homebrew_prefix':   state.old_homebrew_prefix
		'old_home':              state.old_home
		'old_git_config_global': state.old_git_config_global
		'homebrew_prefix':       state.homebrew_prefix
		'home':                  state.home
		'git_config_global':     state.git_config_global
	})
}

// Ruby method `generating_hash?` at line 23.
pub fn ruby_api_hashable_l23_d2_generating_hash(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && (args[0].attribute('generating_hash') or {
		'false'
	}) == 'true')
}

// Ruby method `deep_remove_placeholders(value)` at line 29.
pub fn ruby_api_hashable_l29_d3_deep_remove_placeholders(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', '')
	}
	generating := args.len > 1 && (args[1].as_bool() or { false })
	paths := PlaceholderPaths{
		prefix: if args.len > 2 {
			args[2].as_string()} else {
			ruby.environment_value('HOMEBREW_PREFIX')}
		cellar: if args.len > 3 {
			args[3].as_string()} else {
			ruby.environment_value('HOMEBREW_CELLAR')}
		home: if args.len > 4 {
			args[4].as_string()} else {
			ruby.environment_value('HOME')}
	}
	return deep_remove_placeholders(args[0], generating, paths)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Used to substitute common paths with generic placeholders when generating JSON for the API.
// 5: module APIHashable
// 6:   sig { void }
// 7:   def generating_hash!
// 8:     return if generating_hash?
// 9:
// 10:     # Apply monkeypatches for API generation
// 11:     @old_homebrew_prefix = T.let(HOMEBREW_PREFIX, T.nilable(Pathname))
// 12:     @old_home = T.let(Dir.home, T.nilable(String))
// 13:     @old_git_config_global = T.let(ENV.fetch("GIT_CONFIG_GLOBAL", nil), T.nilable(String))
// 14:     Object.send(:remove_const, :HOMEBREW_PREFIX)
// 15:     Object.const_set(:HOMEBREW_PREFIX, Pathname.new(HOMEBREW_PREFIX_PLACEHOLDER))
// 16:     ENV["HOME"] = HOMEBREW_HOME_PLACEHOLDER
// 17:     ENV["GIT_CONFIG_GLOBAL"] = File.join(@old_home, ".gitconfig")
// 18:
// 19:     @generating_hash = T.let(true, T.nilable(T::Boolean))
// 20:   end
// 21:
// 22:   sig { returns(T::Boolean) }
// 23:   def generating_hash?
// 24:     @generating_hash ||= false
// 25:     @generating_hash == true
// 26:   end
// 27:
// 28:   sig { type_parameters(:U).params(value: T.type_parameter(:U)).returns(T.type_parameter(:U)) }
// 29:   def deep_remove_placeholders(value)
// 30:     return value if generating_hash?
// 31:
// 32:     value = case value
// 33:     when Hash
// 34:       value.transform_values { |v| deep_remove_placeholders(v) }
// 35:     when Array
// 36:       value.map { |v| deep_remove_placeholders(v) }
// 37:     when String
// 38:       value.gsub(HOMEBREW_PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 39:            .gsub(HOMEBREW_CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 40:            .gsub(HOMEBREW_HOME_PLACEHOLDER, Dir.home)
// 41:     else
// 42:       value
// 43:     end
// 44:
// 45:     T.cast(value, T.type_parameter(:U))
// 46:   end
// 47: end
