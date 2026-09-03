module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/tar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 13.
pub fn ruby_tar_l13_d1_self_extensions() []string {
	return tar_extensions()
}

// Ruby method `self.can_extract?(path)` at line 26.
pub fn ruby_tar_l26_d2_self_can_extract(path string) bool {
	return tar_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 39.
pub fn ruby_tar_l39_d3_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	tar_extract_to_dir(path, unpack_dir, basename, verbose)!
}

// Ruby method `subextract(extractor, dir, verbose)` at line 63.
pub fn ruby_tar_l63_d4_subextract(path string, kind StrategyKind, dir string, verbose bool) !string {
	return tar_subextract(path, kind, dir, verbose)
}

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
	result := brew_runtime.run_command(tar, ['--list', '--file', path])
	return result.exit_code == 0 && result.output != ''
}

pub fn tar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	tar := command_path('tar')!
	listing := checked_command(tar, ['--list', '--file', path])!
	validate_archive_members(listing.output.split_into_lines())!
	checked_command(tar,
		['--extract', '--no-same-owner', '--file', path, '--directory', unpack_dir])!
}

pub fn tar_subextract(path string, kind StrategyKind, dir string, verbose bool) !string {
	Strategy{
		kind: kind
		path: path
	}.extract(ExtractOptions{
		destination: dir
		verbose:     verbose
	})!
	children := brew_runtime.list_dir(dir)!
	if children.len == 0 {
		return error('compressed tar extraction produced no file')
	}
	return brew_runtime.join_path(dir, children[0])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module UnpackStrategy
// 7:   # Strategy for unpacking tar archives.
// 8:   class Tar
// 9:     include UnpackStrategy
// 10:     extend SystemCommand::Mixin
// 11:
// 12:     sig { override.returns(T::Array[String]) }
// 13:     def self.extensions
// 14:       [
// 15:         ".tar",
// 16:         ".tbz", ".tbz2", ".tar.bz2",
// 17:         ".tgz", ".tar.gz",
// 18:         ".tlzma", ".tar.lzma",
// 19:         ".txz", ".tar.xz",
// 20:         ".tar.zst",
// 21:         ".crate"
// 22:       ]
// 23:     end
// 24:
// 25:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 26:     def self.can_extract?(path)
// 27:       return true if path.magic_number.match?(/\A.{257}ustar/n)
// 28:
// 29:       return false unless [Bzip2, Gzip, Lzip, Xz, Zstd].any? { |s| s.can_extract?(path) }
// 30:
// 31:       # Check if `tar` can list the contents, then it can also extract it.
// 32:       stdout, _, status = system_command("tar", args: ["--list", "--file", path], print_stderr: false).to_a
// 33:       (status.success? && !stdout.empty?) || false
// 34:     end
// 35:
// 36:     private
// 37:
// 38:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 39:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 40:       Dir.mktmpdir("homebrew-tar", HOMEBREW_TEMP) do |tmpdir|
// 41:         tar_path = if DependencyCollector.tar_needs_xz_dependency? && Xz.can_extract?(path)
// 42:           subextract(Xz, Pathname(tmpdir), verbose)
// 43:         elsif DependencyCollector.tar_needs_bzip2_dependency? && Bzip2.can_extract?(path)
// 44:           subextract(Bzip2, Pathname(tmpdir), verbose)
// 45:         elsif Zstd.can_extract?(path)
// 46:           subextract(Zstd, Pathname(tmpdir), verbose)
// 47:         else
// 48:           path
// 49:         end
// 50:
// 51:         system_command! "tar",
// 52:                         args:    ["--extract", "--no-same-owner",
// 53:                                   "--file", tar_path,
// 54:                                   "--directory", unpack_dir],
// 55:                         verbose:
// 56:       end
// 57:     end
// 58:
// 59:     sig {
// 60:       params(extractor: T.any(T.class_of(Bzip2), T.class_of(Xz), T.class_of(Zstd)), dir: Pathname,
// 61:              verbose: T::Boolean).returns(Pathname)
// 62:     }
// 63:     def subextract(extractor, dir, verbose)
// 64:       extractor.new(path).extract(to: dir, verbose:)
// 65:       dir.children.fetch(0)
// 66:     end
// 67:   end
// 68: end
