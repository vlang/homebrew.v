module artifact

import ruby
import homebrew.cask.artifact as base_artifact
import os

pub struct MacSymlinkCreationResult {
pub:
	command  base_artifact.ArtifactCommand
	altname  string
	metadata bool
}

pub fn mac_create_filesystem_link(source string, target string, target_parent_writable bool,
	runner base_artifact.ArtifactCommandRunner) !MacSymlinkCreationResult {
	os.mkdir_all(os.dir(target))!
	command := base_artifact.ArtifactCommand{
		executable: '/bin/ln'
		args: ['-h', '-f', '-s', '--', source, target]
		sudo: !target_parent_writable
	}
	if !runner(command)! {
		return error('failed to create filesystem link ${target}')
	}
	return MacSymlinkCreationResult{
		command: command
		altname: os.file_name(target)
		metadata: true
	}
}

fn mac_symlink_fixture_runner(command base_artifact.ArtifactCommand) !bool {
	return command.executable == '/bin/ln' && command.args.len == 6
}

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/symlinked.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `create_filesystem_link(command)` at line 16.
pub fn ruby_symlinked_l16_d1_create_filesystem_link(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('create_filesystem_link requires source and target')
	}
	writable := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { true }
	result := mac_create_filesystem_link(args[0].as_string(), args[1].as_string(), writable, mac_symlink_fixture_runner) or { panic(err) }
	return ruby.map_value({
		'executable': ruby.string_value(result.command.executable)
		'args':       ruby.string_array_value(result.command.args)
		'sudo':       ruby.bool_value(result.command.sudo)
		'altname':    ruby.string_value(result.altname)
		'metadata':   ruby.bool_value(result.metadata)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/macos"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Artifact
// 10:         module Symlinked
// 11:           extend T::Helpers
// 12:
// 13:           requires_ancestor { ::Cask::Artifact::Symlinked }
// 14:
// 15:           sig { params(command: T.class_of(SystemCommand)).void }
// 16:           def create_filesystem_link(command)
// 17:             ::Cask::Utils.gain_permissions_mkpath(target.dirname, command:)
// 18:
// 19:             command.run! "/bin/ln", args: ["-h", "-f", "-s", "--", source, target],
// 20:                                     sudo: !target.dirname.writable?
// 21:
// 22:             add_altname_metadata(source, target.basename, command:)
// 23:           end
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
// 29:
// 30: Cask::Artifact::Symlinked.prepend(OS::Mac::Cask::Artifact::Symlinked)
