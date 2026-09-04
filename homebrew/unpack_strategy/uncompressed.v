module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/uncompressed.rb`.

pub fn uncompressed_extensions() []string {
	return []
}

pub fn uncompressed_can_extract(path string) bool {
	_ = path
	return false
}

pub fn uncompressed_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = verbose
	name := strip_download_digest(basename)
	if !safe_basename(name) {
		return error('unsafe uncompressed basename: ${basename}')
	}
	os.cp(path, ruby.join_path(unpack_dir, name))!
}

fn strip_download_digest(name string) string {
	if name.len > 66 && name[64..66] == '--' {
		for byte in name[..64].bytes() {
			if !byte.is_hex_digit() || (byte >= `A` && byte <= `F`) {
				return name
			}
		}
		return name[66..]
	}
	return name
}
