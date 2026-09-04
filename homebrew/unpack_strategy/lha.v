module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/lha.rb`.

pub fn lha_extensions() []string {
	return ['.lha', '.lzh']
}

pub fn lha_can_extract(path string) bool {
	bytes := read_file_prefix(path, 8) or { return false }
	if bytes.len < 7 || bytes[2] != `-` || bytes[6] != `-` {
		return false
	}
	method := bytes[3..6].bytestr()
	return method in ['lh0', 'lh1', 'lz4', 'lz5', 'lzs', 'lh ', 'lhd', 'lh2', 'lh3', 'lh4', 'lh5']
}

pub fn lha_dependencies() []string {
	return ['lha']
}

pub fn lha_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	lha := command_path('lha')!
	members := archive_listing(lha, ['lq', path])!
	validate_archive_members(members)!
	checked_command(lha, ['xq2w=${unpack_dir}', path])!
}
