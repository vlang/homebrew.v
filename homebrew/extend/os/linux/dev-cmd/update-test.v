module dev_cmd

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/update-test.rb`.
// The original source is retained below until every stub has a typed V body.
pub type GitTagsReader = fn() !string

pub fn linux_git_tags(super_tags string, reader GitTagsReader) !string {
	if super_tags.trim_space() != '' {
		return super_tags
	}
	return reader()!
}

// Ruby method `git_tags` at line 11.
pub fn ruby_update_test_l11_d1_git_tags(super_tags string, reader GitTagsReader) !string {
	return linux_git_tags(super_tags, reader)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module DevCmd
// 7:       module UpdateTest
// 8:         private
// 9:
// 10:         sig { returns(String) }
// 11:         def git_tags
// 12:           super.presence || Utils.popen_read("git tag --list | sort -rV")
// 13:         end
// 14:       end
// 15:     end
// 16:   end
// 17: end
// 18:
// 19: Homebrew::DevCmd::UpdateTest.prepend(OS::Linux::DevCmd::UpdateTest)
