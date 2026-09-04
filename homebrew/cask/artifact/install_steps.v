module artifact

import ruby
import homebrew
import os

// Translated from Homebrew/brew `cask/artifact/install_steps.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn cask_install_steps_error(message string) ruby.Value {
	return ruby.structured_value('ArgumentError', message, {
		'message': message
	})
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

pub fn new_cask_install_steps_artifact(cask ruby.Value, steps homebrew.InstallSteps,
	class_name string) CaskInstallStepsArtifact {
	return CaskInstallStepsArtifact{
		cask: cask
		steps: cask_install_steps_normalise(steps)
		class_name: if class_name == '' {
			'Cask::Artifact::AbstractInstallSteps'
		} else {
			class_name
		}
	}
}

fn cask_install_steps_artifact_value(artifact CaskInstallStepsArtifact) ruby.Value {
	return ruby.Value{
		type_name: artifact.class_name
		repr: cask_install_steps_summarize(artifact)
		map_data: {
			'cask':  artifact.cask
			'steps': homebrew.install_steps_value(artifact.steps)
		}
		attributes: {
			'class_name': artifact.class_name
		}
	}
}

fn cask_install_steps_artifact_from_value(value ruby.Value) CaskInstallStepsArtifact {
	class_name := value.attributes['class_name'] or {
		if value.type_name.starts_with('Cask::Artifact::') {
			value.type_name
		} else {
			'Cask::Artifact::AbstractInstallSteps'
		}
	}
	return new_cask_install_steps_artifact(value.map_data['cask'] or {
		ruby.object_value('Cask::Cask', '')
	}, homebrew.install_steps_from_value(value.map_data['steps'] or {
		ruby.array_value([])
	}), class_name)
}

pub fn cask_install_steps_to_args(artifact CaskInstallStepsArtifact) []ruby.Value {
	return [ruby.map_value({
		'steps': homebrew.install_steps_value(artifact.steps)
	})]
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

fn cask_install_steps_plan_value(plan CaskInstallStepsSandboxPlan) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::InstallSteps::SandboxPlan'
		repr: '${plan.phase}: ${plan.allowed_write_paths.len} write paths'
		map_data: {
			'phase':                  ruby.string_value(plan.phase)
			'network_access_allowed': ruby.bool_value(plan.network_access_allowed)
			'allow_sudo':             ruby.bool_value(plan.allow_sudo)
			'allowed_write_paths':    ruby.string_array_value(plan.allowed_write_paths)
			'allowed_read_paths':     ruby.string_array_value(plan.allowed_read_paths)
			'payload':                ruby.map_value(plan.payload)
		}
	}
}

fn cask_install_steps_run_result_value(result CaskInstallStepsRunResult) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::InstallSteps::RunResult'
		repr: result.phase
		map_data: {
			'phase':     ruby.string_value(result.phase)
			'sandboxed': ruby.bool_value(result.sandboxed)
			'executed':  ruby.bool_value(result.executed)
			'plan':      cask_install_steps_plan_value(result.plan)
		}
	}
}

fn cask_install_steps_options(args []ruby.Value, start int) map[string]ruby.Value {
	for index := args.len - 1; index >= start; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn cask_install_steps_run_boundary(args []ruby.Value, default_phase string) ruby.Value {
	if args.len == 0 {
		return cask_install_steps_error('install steps require an artifact receiver')
	}
	artifact := cask_install_steps_artifact_from_value(args[0])
	options := cask_install_steps_options(args, 1)
	phase := if value := options['phase'] {
		cask_install_steps_string(value)
	} else {
		default_phase
	}
	sandboxed := cask_install_steps_bool(options['sandboxed'] or {
		ruby.bool_value(false)
	}, false)
	result := run_cask_install_steps(artifact, phase, sandboxed, homebrew.NativeInstallStepsCommandExecutor{}) or {
		return ruby.structured_value('RuntimeError', err.msg(), {
			'message': err.msg()
		})
	}
	return cask_install_steps_run_result_value(result)
}

// Ruby method `initialize(cask, steps)` at line 15.
pub fn ruby_install_steps_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return cask_install_steps_error('initialize requires a cask and steps')
	}
	class_name := if args.len > 2 { cask_install_steps_string(args[2]) } else { '' }
	steps := if args[1].type_name == 'Hash' {
		homebrew.install_steps_normalise([args[1]])
	} else {
		homebrew.install_steps_from_value(args[1])
	}
	return cask_install_steps_artifact_value(new_cask_install_steps_artifact(args[0], steps, class_name))
}

// Ruby attr_reader `attr_reader :steps` at line 21.
pub fn ruby_install_steps_l21_d2_steps(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return homebrew.install_steps_value(homebrew.InstallSteps{})
	}
	return homebrew.install_steps_value(cask_install_steps_artifact_from_value(args[0]).steps)
}

// Ruby method `to_args = [{ steps: }]` at line 24.
pub fn ruby_install_steps_l24_d3_to_args(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	return ruby.array_value(cask_install_steps_to_args(cask_install_steps_artifact_from_value(args[0])))
}

// Ruby method `summarize` at line 27.
pub fn ruby_install_steps_l27_d4_summarize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('0 install steps')
	}
	return ruby.string_value(cask_install_steps_summarize(cask_install_steps_artifact_from_value(args[0])))
}

// Ruby method `run_steps(command, phase: :install)` at line 34.
pub fn ruby_install_steps_l34_d5_run_steps(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'install')
}

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 76.
pub fn ruby_install_steps_l76_d6_install_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'install')
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 81.
pub fn ruby_install_steps_l81_d7_uninstall_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'uninstall')
}

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 89.
pub fn ruby_install_steps_l89_d8_install_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'install')
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 94.
pub fn ruby_install_steps_l94_d9_uninstall_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'uninstall')
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 102.
pub fn ruby_install_steps_l102_d10_uninstall_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'install')
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 110.
pub fn ruby_install_steps_l110_d11_uninstall_phase(args ...ruby.Value) ruby.Value {
	return cask_install_steps_run_boundary(args, 'install')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5: require "install_steps"
// 6: require "keg"
// 7:
// 8: module Cask
// 9:   module Artifact
// 10:     # Abstract superclass for install steps artifacts.
// 11:     class AbstractInstallSteps < AbstractArtifact
// 12:       abstract!
// 13:
// 14:       sig { params(cask: Cask, steps: Homebrew::InstallSteps::Steps).void }
// 15:       def initialize(cask, steps)
// 16:         super
// 17:         @steps = T.let(Homebrew::InstallSteps::DSL.normalise_steps(steps), Homebrew::InstallSteps::Steps)
// 18:       end
// 19:
// 20:       sig { returns(Homebrew::InstallSteps::Steps) }
// 21:       attr_reader :steps
// 22:
// 23:       sig { override.returns(T::Array[T.anything]) }
// 24:       def to_args = [{ steps: }]
// 25:
// 26:       sig { override.returns(String) }
// 27:       def summarize
// 28:         ::Utils.pluralize("install step", steps.length, include_count: true)
// 29:       end
// 30:
// 31:       private
// 32:
// 33:       sig { params(command: T.class_of(SystemCommand), phase: Symbol).void }
// 34:       def run_steps(command, phase: :install)
// 35:         runner = Homebrew::InstallSteps::Runner.new(context: cask, command:)
// 36:         sandbox = cask_sandbox(network_access_allowed: steps.any? do |step|
// 37:           step["type"] == "run" && step["network_access"] == true
// 38:         end)
// 39:         unless sandbox
// 40:           runner.run(steps, phase:)
// 41:           return
// 42:         end
// 43:
// 44:         sandbox.allow_write_path cask.caskroom_path
// 45:         sandbox.allow_write_path cask.config.appdir
// 46:         sandbox.allow_process_exec "/usr/bin/sudo", no_sandbox: true if runner.sudo_required?(steps)
// 47:         Keg.keg_link_directories.each { |directory| sandbox.allow_write_path HOMEBREW_PREFIX/directory }
// 48:         original_home = Pathname(Dir.home).expand_path
// 49:         runner.sandbox_write_paths(steps, phase:).each do |path|
// 50:           sandbox.allow_write_path path
// 51:           sandbox.allow_read(path:, type: :subpath) if path.expand_path.ascend.include?(original_home)
// 52:         end
// 53:         run_cask_sandbox(
// 54:           sandbox,
// 55:           {
// 56:             "action"  => "install_steps",
// 57:             "context" => {
// 58:               "name"          => cask.name,
// 59:               "token"         => cask.token,
// 60:               "version"       => cask.version.to_s,
// 61:               "staged_path"   => cask.staged_path.to_s,
// 62:               "caskroom_path" => cask.caskroom_path.to_s,
// 63:               "home"          => Dir.home,
// 64:               "config"        => cask.config.to_json,
// 65:             },
// 66:             "phase"   => phase.to_s,
// 67:             "steps"   => steps,
// 68:           },
// 69:         )
// 70:       end
// 71:     end
// 72:
// 73:     # Artifact corresponding to the `preflight_steps` stanza.
// 74:     class PreflightSteps < AbstractInstallSteps
// 75:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 76:       def install_phase(command: SystemCommand, **_options)
// 77:         run_steps(command)
// 78:       end
// 79:
// 80:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 81:       def uninstall_phase(command: SystemCommand, **_options)
// 82:         run_steps(command, phase: :uninstall)
// 83:       end
// 84:     end
// 85:
// 86:     # Artifact corresponding to the `postflight_steps` stanza.
// 87:     class PostflightSteps < AbstractInstallSteps
// 88:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 89:       def install_phase(command: SystemCommand, **_options)
// 90:         run_steps(command)
// 91:       end
// 92:
// 93:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 94:       def uninstall_phase(command: SystemCommand, **_options)
// 95:         run_steps(command, phase: :uninstall)
// 96:       end
// 97:     end
// 98:
// 99:     # Artifact corresponding to the `uninstall_preflight_steps` stanza.
// 100:     class UninstallPreflightSteps < AbstractInstallSteps
// 101:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 102:       def uninstall_phase(command: SystemCommand, **_options)
// 103:         run_steps(command)
// 104:       end
// 105:     end
// 106:
// 107:     # Artifact corresponding to the `uninstall_postflight_steps` stanza.
// 108:     class UninstallPostflightSteps < AbstractInstallSteps
// 109:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 110:       def uninstall_phase(command: SystemCommand, **_options)
// 111:         run_steps(command)
// 112:       end
// 113:     end
// 114:   end
// 115: end
