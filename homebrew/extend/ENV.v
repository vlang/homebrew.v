module extend

import ruby

// Translated from Homebrew/brew `extend/ENV.rb`.
pub enum EnvironmentExtension {
	stdenv
	superenv
}

pub struct BuildEnvironmentOptions {
pub:
	env           ?string
	cc            ?string
	build_bottle  bool
	bottle_arch   ?string
	debug_symbols ?bool
}

pub type BuildEnvironmentSetup = fn (environment map[string]string, extension EnvironmentExtension, options BuildEnvironmentOptions) !map[string]string

pub type BuildEnvironmentBlock = fn (environment map[string]string) !ruby.Value

pub fn activate_environment_extensions(env ?string, superenv_bin ?string) EnvironmentExtension {
	if requested := env {
		if requested == 'std' {
			return .stdenv
		}
	}
	if _ := superenv_bin {
		return .superenv
	}
	return .stdenv
}

// with_build_environment passes a temporary, configured copy to the callback.
// The caller's map is value-isolated, matching Ruby's ensure-based restoration.
pub fn with_build_environment(environment map[string]string, options BuildEnvironmentOptions,
	superenv_bin ?string, setup BuildEnvironmentSetup,
	block BuildEnvironmentBlock) !ruby.Value {
	extension := activate_environment_extensions(options.env, superenv_bin)
	temporary := setup(environment.clone(), extension, options)!
	return block(temporary)
}
