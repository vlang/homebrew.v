module homebrew

import ruby

// Translated from Homebrew/brew `data_patch.rb`.

pub struct DataPatch {
pub:
	strip    string
	has_path bool
	path     string
}

pub fn new_data_patch(strip string) DataPatch {
	return DataPatch{
		strip: strip
	}
}

pub fn (patch DataPatch) with_path(path string) DataPatch {
	return DataPatch{
		strip: patch.strip
		has_path: true
		path: path
	}
}

pub fn (patch DataPatch) filename() string {
	return 'embedded DATA patch'
}

// contents returns every byte following the first standalone __END__ line.
pub fn (patch DataPatch) contents() !string {
	if !patch.has_path {
		return error('DATAPatch#contents called before path was set!')
	}
	data := ruby.read_file(patch.path)!
	mut line_start := 0
	for index, character in data.bytes() {
		if character != `\n` {
			continue
		}
		if data[line_start..index] == '__END__' {
			return data[index + 1..]
		}
		line_start = index + 1
	}
	return ''
}
