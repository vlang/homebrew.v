module lock_sh

// Translated from Homebrew/brew `utils/lock_sh/ruby_lock_file_descriptor.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: file_descriptor = ARGV.first.to_i
// 5: file = File.new(file_descriptor)
// 6: file.flock(File::LOCK_EX | File::LOCK_NB) || exit(1)
