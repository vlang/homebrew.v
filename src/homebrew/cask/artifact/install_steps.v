module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/install_steps.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(cask, steps)` at line 15.
pub fn ruby_install_steps_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :steps` at line 21.
pub fn ruby_install_steps_l21_d2_steps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('steps', ...args)
}

// Ruby method `to_args = [{ steps: }]` at line 24.
pub fn ruby_install_steps_l24_d3_to_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_args', ...args)
}

// Ruby method `summarize` at line 27.
pub fn ruby_install_steps_l27_d4_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `run_steps(command, phase: :install)` at line 34.
pub fn ruby_install_steps_l34_d5_run_steps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_steps', ...args)
}

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 76.
pub fn ruby_install_steps_l76_d6_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 81.
pub fn ruby_install_steps_l81_d7_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 89.
pub fn ruby_install_steps_l89_d8_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 94.
pub fn ruby_install_steps_l94_d9_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 102.
pub fn ruby_install_steps_l102_d10_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 110.
pub fn ruby_install_steps_l110_d11_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_phase', ...args)
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
