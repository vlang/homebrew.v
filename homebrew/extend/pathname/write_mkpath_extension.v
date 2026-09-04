module pathname

import ruby
import os

// Translated from Homebrew/brew `extend/pathname/write_mkpath_extension.rb`.
pub fn write_mkpath(path string, content string, offset ?int, mode string) !int {
	if os.exists(path) && offset == none && mode !in ['a', 'a+'] {
		return error('Will not overwrite ${path}')
	}
	os.mkdir_all(os.dir(path))!
	if position := offset {
		mut file := os.open_file(path, 'r+') or { os.create(path)! }
		defer { file.close() }
		return file.write_to(u64(position), content.bytes())
	}
	if mode in ['a', 'a+'] {
		mut file := os.open_append(path)!
		defer { file.close() }
		return file.write_string(content)
	}
	os.write_file(path, content)!
	return content.len
}
