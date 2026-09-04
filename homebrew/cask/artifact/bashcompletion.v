module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/bashcompletion.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn resolve_bash_completion_target(target string, completion_directory string) string {
	extension := os.file_ext(target)
	name := if extension == '' {
		os.base(target)
	} else {
		os.base(target).trim_string_right(extension)
	}
	return ruby.join_path(completion_directory, name)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 11.
pub fn ruby_bashcompletion_l11_d1_resolve_target(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('BashCompletion#resolve_target requires a target') }
	directory := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.join_path(cask_artifact_prefix(), 'etc/bash_completion.d')
	}
	return ruby.object_value('Pathname', resolve_bash_completion_target(args[0].as_string(), directory))
}

fn cask_artifact_prefix() string {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	return if prefix == '' { '/opt/homebrew' } else { prefix }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/shellcompletion"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `bash_completion` stanza.
// 9:     class BashCompletion < ShellCompletion
// 10:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(target, base_dir: nil)
// 12:         name = if File.extname(target).nil?
// 13:           target
// 14:         else
// 15:           new_name = File.basename(target, File.extname(target))
// 16:           odebug "Renaming completion #{target} to #{new_name}"
// 17:
// 18:           new_name
// 19:         end
// 20:
// 21:         config.bash_completion/name
// 22:       end
// 23:     end
// 24:   end
// 25: end
