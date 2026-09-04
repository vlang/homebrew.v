module dev_cmd

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/update-test.rb`.
pub type GitTagsReader = fn () !string

pub fn linux_git_tags(super_tags string, reader GitTagsReader) !string {
	if super_tags.trim_space() != '' {
		return super_tags
	}
	return reader()!
}
