module pathname

import ruby

// Translated from Homebrew/brew `extend/pathname/eager_initialize_extension.rb`.
pub struct EagerPathname {
pub:
	path               string
	magic_number       ?string
	file_type          ?string
	zipinfo            ?[]string
	which_install_info ?string
	disk_usage         ?i64
	file_count         ?i64
}

pub fn new_eager_pathname(path string) EagerPathname {
	return EagerPathname{ path: path }
}
