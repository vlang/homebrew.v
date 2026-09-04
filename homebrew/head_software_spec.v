module homebrew

// Translated from Homebrew/brew `head_software_spec.rb`.

pub struct HeadSoftwareSpec {
pub:
	flags   []string
	version Version
}

pub fn new_head_software_spec(flags []string) HeadSoftwareSpec {
	return HeadSoftwareSpec{
		flags: flags.clone()
		version: new_version('HEAD') or { panic(err) }
	}
}

pub fn (spec HeadSoftwareSpec) verify_download_integrity(_filename string) {
	// HEAD downloads are moving VCS targets, so the Ruby body intentionally does
	// no checksum verification.
}
