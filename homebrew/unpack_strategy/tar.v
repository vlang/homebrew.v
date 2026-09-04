module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/tar.rb`.

pub fn tar_extensions() []string {
	return ['.tar', '.tbz', '.tbz2', '.tar.bz2', '.tgz', '.tar.gz', '.tlzma', '.tar.lzma', '.txz',
		'.tar.xz', '.tar.zst', '.crate']
}

pub fn tar_can_extract(path string) bool {
	if file_has_bytes_at(path, 257, 'ustar'.bytes()) {
		return true
	}
	if !gzip_can_extract(path) && !bzip2_can_extract(path) && !lzip_can_extract(path)
		&& !xz_can_extract(path) && !zstd_can_extract(path) {
		return false
	}
	tar := command_path('tar') or { return false }
	result := ruby.run_command(tar, ['--list', '--file', path])
	return result.exit_code == 0 && result.output != ''
}

pub fn tar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	tar := command_path('tar')!
	listing := checked_command(tar, ['--list', '--file', path])!
	validate_archive_members(listing.output.split_into_lines())!
	checked_command(tar, ['--extract', '--no-same-owner', '--file', path, '--directory', unpack_dir])!
}

pub fn tar_subextract(path string, kind StrategyKind, dir string, verbose bool) !string {
	Strategy{
		kind: kind
		path: path
	}.extract(ExtractOptions{
		destination: dir
		verbose: verbose
	})!
	children := ruby.list_dir(dir)!
	if children.len == 0 {
		return error('compressed tar extraction produced no file')
	}
	return ruby.join_path(dir, children[0])
}
