module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/keyboard_layout.rb`.
// The original source is retained below until every stub has a typed V body.
fn run_refresh_command(command ArtifactCommand, runner ArtifactCommandRunner,
	mut result MovedOperationResult) {
	result.commands << command
	succeeded := runner(command) or {
		result.success = false
		result.error = err.msg()
		return
	}
	if !succeeded {
		result.success = false
		result.error = 'Command failed: ${command.executable}'
	}
}

pub fn delete_keyboard_layout_cache_with_command(runner ArtifactCommandRunner,
	mut result MovedOperationResult) {
	run_refresh_command(ArtifactCommand{
		executable: '/bin/rm'
		args: ['-f', '--', '/System/Library/Caches/com.apple.IntlDataCache.le*']
		sudo: true
		sudo_as_root: true
	}, runner, mut result)
}

pub fn install_keyboard_layout_with_command(artifact MovedArtifact,
	options MovedInstallOptions, runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_artifact_with_command(artifact, options, runner)
	if result.success {
		delete_keyboard_layout_cache_with_command(runner, mut result)
	}
	return result
}

pub fn install_keyboard_layout(artifact MovedArtifact,
	options MovedInstallOptions) MovedOperationResult {
	return install_keyboard_layout_with_command(artifact, options, default_artifact_command_runner)
}

pub fn uninstall_keyboard_layout_with_command(artifact MovedArtifact,
	options MovedUninstallOptions, runner ArtifactCommandRunner) MovedOperationResult {
	mut result := move_back_artifact_with_command(artifact, options, runner)
	if result.success {
		delete_keyboard_layout_cache_with_command(runner, mut result)
	}
	return result
}

pub fn uninstall_keyboard_layout(artifact MovedArtifact,
	options MovedUninstallOptions) MovedOperationResult {
	return uninstall_keyboard_layout_with_command(artifact, options, default_artifact_command_runner)
}

// Ruby method `install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,` at line 22.
pub fn ruby_keyboard_layout_l22_d1_install_phase(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		moved_install_options_from_value(args[1])
	} else {
		MovedInstallOptions{}
	}
	return moved_operation_to_value(install_keyboard_layout(artifact, options))
}

// Ruby method `uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,` at line 40.
pub fn ruby_keyboard_layout_l40_d2_uninstall_phase(args ...ruby.Value) ruby.Value {
	artifact := moved_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		moved_uninstall_options_from_value(args[1])
	} else {
		MovedUninstallOptions{}
	}
	return moved_operation_to_value(uninstall_keyboard_layout(artifact, options))
}

// Ruby method `delete_keyboard_layout_cache(command: SystemCommand)` at line 49.
pub fn ruby_keyboard_layout_l49_d3_delete_keyboard_layout_cache(args ...ruby.Value) ruby.Value {
	_ = args
	mut result := MovedOperationResult{}
	delete_keyboard_layout_cache_with_command(default_artifact_command_runner, mut result)
	return moved_operation_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/moved"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `keyboard_layout` stanza.
// 9:     class KeyboardLayout < Moved
// 10:       sig {
// 11:         override.params(
// 12:           adopt:        T::Boolean,
// 13:           auto_updates: T.nilable(T::Boolean),
// 14:           force:        T::Boolean,
// 15:           verbose:      T::Boolean,
// 16:           predecessor:  T.nilable(Cask),
// 17:           successor:    T.nilable(Cask),
// 18:           reinstall:    T::Boolean,
// 19:           command:      T.class_of(SystemCommand),
// 20:         ).void
// 21:       }
// 22:       def install_phase(adopt: false, auto_updates: false, force: false, verbose: false, predecessor: nil,
// 23:                         successor: nil, reinstall: false, command: SystemCommand)
// 24:         super
// 25:         delete_keyboard_layout_cache(command:)
// 26:       end
// 27:
// 28:       sig {
// 29:         override.params(
// 30:           skip:      T::Boolean,
// 31:           force:     T::Boolean,
// 32:           adopt:     T::Boolean,
// 33:           verbose:   T::Boolean,
// 34:           successor: T.nilable(Cask),
// 35:           upgrade:   T::Boolean,
// 36:           reinstall: T::Boolean,
// 37:           command:   T.class_of(SystemCommand),
// 38:         ).void
// 39:       }
// 40:       def uninstall_phase(skip: false, force: false, adopt: false, verbose: false, successor: nil, upgrade: false,
// 41:                           reinstall: false, command: SystemCommand)
// 42:         super
// 43:         delete_keyboard_layout_cache(command:)
// 44:       end
// 45:
// 46:       private
// 47:
// 48:       sig { params(command: T.class_of(SystemCommand)).void }
// 49:       def delete_keyboard_layout_cache(command: SystemCommand)
// 50:         command.run!(
// 51:           "/bin/rm",
// 52:           args:         ["-f", "--", "/System/Library/Caches/com.apple.IntlDataCache.le*"],
// 53:           sudo:         true,
// 54:           sudo_as_root: true,
// 55:         )
// 56:       end
// 57:     end
// 58:   end
// 59: end
