module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/appimage.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ExecutableArtifactLinkResult {
pub:
	source             string
	already_executable bool
	chmod_applied      bool
	sudo_required      bool
	command_arguments  []string
}

pub fn resolve_appimage_target(appimagedir string, target string) string {
	return os.join_path(appimagedir, target)
}

// link_executable_artifact performs the post-link executable repair shared by
// AppImage and Binary. Non-writable sources return the exact sudo chmod plan so
// callers can execute it through their SystemCommand boundary.
pub fn link_executable_artifact(source string) !ExecutableArtifactLinkResult {
	if !os.exists(source) {
		return error('artifact source does not exist: ${source}')
	}
	if os.is_executable(source) {
		return ExecutableArtifactLinkResult{
			source: source
			already_executable: true
		}
	}
	if !os.is_writable(source) {
		return ExecutableArtifactLinkResult{
			source: source
			sudo_required: true
			command_arguments: ['+x', source]
		}
	}
	mode := int(os.stat(source)!.get_mode().bitmask())
	os.chmod(source, mode | 0o111)!
	return ExecutableArtifactLinkResult{
		source: source
		chmod_applied: true
		command_arguments: ['+x', source]
	}
}

fn executable_artifact_link_value(result ExecutableArtifactLinkResult) ruby.Value {
	return ruby.Value{
		type_name: 'ExecutableArtifactLinkResult'
		repr: result.source
		attributes: {
			'source':             result.source
			'already_executable': result.already_executable.str()
			'chmod_applied':      result.chmod_applied.str()
			'sudo_required':      result.sudo_required.str()
		}
		map_data: {
			'command_arguments': ruby.string_array_value(result.command_arguments)
		}
	}
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 11.
pub fn ruby_appimage_l11_d1_resolve_target(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'AppImage#resolve_target requires target and appimagedir')
	}
	return ruby.string_value(resolve_appimage_target(args[1].as_string(), args[0].as_string()))
}

// Ruby method `link(force: false, adopt: false, command: SystemCommand, **_options)` at line 23.
pub fn ruby_appimage_l23_d2_link(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'AppImage#link requires a source')
	}
	result := link_executable_artifact(args[0].as_string()) or {
		return ruby.object_value('CaskError', err.msg())
	}
	return executable_artifact_link_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/symlinked"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `app_image` stanza.
// 9:     class AppImage < Symlinked
// 10:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(target, base_dir: nil)
// 12:         Pathname.new("#{config.appimagedir}/#{target}")
// 13:       end
// 14:
// 15:       sig {
// 16:         override.params(
// 17:           force:    T::Boolean,
// 18:           adopt:    T::Boolean,
// 19:           command:  T.class_of(SystemCommand),
// 20:           _options: T.anything,
// 21:         ).void
// 22:       }
// 23:       def link(force: false, adopt: false, command: SystemCommand, **_options)
// 24:         super
// 25:         return if source.executable?
// 26:
// 27:         if source.writable?
// 28:           FileUtils.chmod "+x", source
// 29:         else
// 30:           command.run!("chmod", args: ["+x", source], sudo: true)
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
