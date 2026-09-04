module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/fishcompletion.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn resolve_fish_completion_target(target string, completion_directory string) string {
	name := if target.ends_with('.fish') {
		target
	} else {
		'${os.base(target).trim_string_right(os.file_ext(target))}.fish'
	}
	return ruby.join_path(completion_directory, name)
}

// Ruby method `resolve_target(target, base_dir: nil)` at line 11.
pub fn ruby_fishcompletion_l11_d1_resolve_target(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('FishCompletion#resolve_target requires a target') }
	directory := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.join_path(cask_artifact_prefix(), 'share/fish/vendor_completions.d')
	}
	return ruby.object_value('Pathname', resolve_fish_completion_target(args[0].as_string(), directory))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/shellcompletion"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `fish_completion` stanza.
// 9:     class FishCompletion < ShellCompletion
// 10:       sig { override.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 11:       def resolve_target(target, base_dir: nil)
// 12:         name = if target.to_s.end_with? ".fish"
// 13:           target
// 14:         else
// 15:           new_name = "#{File.basename(target, File.extname(target))}.fish"
// 16:           odebug "Renaming completion #{target} to #{new_name}"
// 17:
// 18:           new_name
// 19:         end
// 20:
// 21:         config.fish_completion/name
// 22:       end
// 23:     end
// 24:   end
// 25: end
