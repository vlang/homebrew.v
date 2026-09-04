module tap

// Translated from Homebrew/brew `tap/tap_config.rb`.
pub struct TapConfigTap {
pub:
	name string
	path string
	git  bool
}

pub struct TapConfig {
pub:
	tap TapConfigTap
mut:
	settings map[string]string
}

pub fn new_tap_config(tap TapConfigTap) TapConfig {
	return TapConfig{
		tap: tap
		settings: map[string]string{}
	}
}

pub fn (config &TapConfig) get(key string, git_available bool) ?bool {
	if !config.tap.git || !git_available {
		return none
	}
	value := config.settings[key] or { return none }
	return match value {
		'true' { true }
		'false' { false }
		else { none }
	}
}

pub fn (mut config TapConfig) set(key string, value bool, git_available bool) {
	if config.tap.git && git_available {
		config.settings[key] = value.str()
	}
}

pub fn (mut config TapConfig) delete(key string, git_available bool) {
	if config.tap.git && git_available {
		config.settings.delete(key)
	}
}
