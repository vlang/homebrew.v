module artifact

import ruby
import homebrew
import os

// Translated from Homebrew/brew `cask/artifact/install_steps.rb`.

pub struct CaskInstallStepsArtifact {
pub:
	cask       ruby.Value
	steps      homebrew.InstallSteps
	class_name string
}

pub struct CaskInstallStepsSandboxPlan {
pub:
	phase                  string
	network_access_allowed bool
	allow_sudo             bool
	allowed_write_paths    []string
	allowed_read_paths     []string
	payload                map[string]ruby.Value
}

pub struct CaskInstallStepsRunResult {
pub:
	phase     string
	sandboxed bool
	executed  bool
	plan      CaskInstallStepsSandboxPlan
}

fn cask_install_steps_string(value ruby.Value) string {
	if value.type_name == 'Symbol' {
		return value.as_string().trim_left(':')
	}
	return value.as_string()
}

fn cask_install_steps_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn cask_install_steps_value_at(cask ruby.Value, key string) string {
	if value := cask.map_data[key] {
		if value.type_name != 'NilClass' {
			return cask_install_steps_string(value)
		}
	}
	return cask.attributes[key] or { '' }
}

fn cask_install_steps_config_at(cask ruby.Value, key string) string {
	if config := cask.map_data['config'] {
		if value := config.map_data[key] {
			return cask_install_steps_string(value)
		}
		if value := config.attributes[key] {
			return value
		}
	}
	return cask_install_steps_value_at(cask, key)
}

fn cask_install_steps_normalise(steps homebrew.InstallSteps) homebrew.InstallSteps {
	return homebrew.install_steps_normalise(steps.map(ruby.map_value(it)))
}

pub fn cask_install_steps_summarize(artifact CaskInstallStepsArtifact) string {
	return homebrew.pluralize('install step', artifact.steps.len, 's', '', true)
}

fn cask_install_steps_context(artifact CaskInstallStepsArtifact) homebrew.InstallStepsContext {
	mut values := artifact.cask.attributes.clone()
	for key in ['name', 'token', 'version', 'staged_path', 'caskroom_path', 'home', 'prefix'] {
		value := cask_install_steps_value_at(artifact.cask, key)
		if value != '' {
			values[key] = value
		}
	}
	if values['name'] or { '' } == '' {
		values['name'] = artifact.cask.as_string()
	}
	if values['token'] or { '' } == '' {
		values['token'] = artifact.cask.as_string()
	}
	if values['home'] or { '' } == '' {
		values['home'] = ruby.environment_value('HOME')
	}
	if values['prefix'] or { '' } == '' {
		values['prefix'] = ruby.environment_value('HOMEBREW_PREFIX')
	}
	return homebrew.InstallStepsContext{
		values: values
		config: {
			'appdir': cask_install_steps_config_at(artifact.cask, 'appdir')
		}
	}
}

fn cask_install_steps_has_network_access(steps homebrew.InstallSteps) bool {
	for step in steps {
		kind := step['type'] or { continue }
		network_access := step['network_access'] or { continue }
		if cask_install_steps_string(kind) == 'run'
			&& cask_install_steps_bool(network_access, false) {
			return true
		}
	}
	return false
}

fn cask_install_steps_append_unique(mut values []string, value string) {
	if value != '' && value !in values {
		values << value
	}
}

fn cask_install_steps_is_within(path string, root string) bool {
	if path == '' || root == '' {
		return false
	}
	absolute_path := os.abs_path(path).trim_string_right(os.path_separator)
	absolute_root := os.abs_path(root).trim_string_right(os.path_separator)
	return absolute_path == absolute_root
		|| absolute_path.starts_with('${absolute_root}${os.path_separator}')
}

fn cask_install_steps_context_value(context homebrew.InstallStepsContext,
	key string) ruby.Value {
	return ruby.string_value(context.values[key] or { '' })
}

pub fn plan_cask_install_steps(artifact CaskInstallStepsArtifact,
	phase string) !CaskInstallStepsSandboxPlan {
	context := cask_install_steps_context(artifact)
	mut write_paths := []string{}
	cask_install_steps_append_unique(mut write_paths, context.values['caskroom_path'] or { '' })
	cask_install_steps_append_unique(mut write_paths, context.config['appdir'] or { '' })
	prefix := context.values['prefix'] or { '' }
	if prefix != '' {
		for directory in homebrew.keg_link_directories {
			cask_install_steps_append_unique(mut write_paths, os.join_path(prefix, directory))
		}
	}
	for path in homebrew.install_steps_sandbox_write_paths(context, artifact.steps, phase)! {
		cask_install_steps_append_unique(mut write_paths, path)
	}
	mut read_paths := []string{}
	cask_install_steps_append_unique(mut read_paths, context.values['staged_path'] or { '' })
	home := context.values['home'] or { ruby.environment_value('HOME') }
	for path in write_paths {
		if cask_install_steps_is_within(path, home) {
			cask_install_steps_append_unique(mut read_paths, path)
		}
	}
	mut config := map[string]ruby.Value{}
	for key, value in context.config {
		config[key] = ruby.string_value(value)
	}
	return CaskInstallStepsSandboxPlan{
		phase: phase
		network_access_allowed: cask_install_steps_has_network_access(artifact.steps)
		allow_sudo: homebrew.install_steps_sudo_required(artifact.steps)
		allowed_write_paths: write_paths
		allowed_read_paths: read_paths
		payload: {
			'action':  ruby.string_value('install_steps')
			'context': ruby.map_value({
				'name':          cask_install_steps_context_value(context, 'name')
				'token':         cask_install_steps_context_value(context, 'token')
				'version':       cask_install_steps_context_value(context, 'version')
				'staged_path':   cask_install_steps_context_value(context, 'staged_path')
				'caskroom_path': cask_install_steps_context_value(context, 'caskroom_path')
				'home':          ruby.string_value(home)
				'config':        ruby.map_value(config)
			})
			'phase':   ruby.string_value(phase)
			'steps':   homebrew.install_steps_value(artifact.steps)
		}
	}
}

pub fn run_cask_install_steps(artifact CaskInstallStepsArtifact, phase string, sandboxed bool,
	executor homebrew.InstallStepsCommandExecutor) !CaskInstallStepsRunResult {
	plan := plan_cask_install_steps(artifact, phase)!
	if sandboxed {
		return CaskInstallStepsRunResult{
			phase: phase
			sandboxed: true
			plan: plan
		}
	}
	mut runner := homebrew.new_install_steps_runner(cask_install_steps_context(artifact), executor)
	homebrew.install_steps_run(mut runner, artifact.steps, phase)!
	return CaskInstallStepsRunResult{
		phase: phase
		executed: true
		plan: plan
	}
}
