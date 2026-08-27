module lib

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # BinData -- Binary data manipulator.
// 2: # Copyright (c) 2007 - 2025 Dion Mendel.
// 3:
// 4: require 'bindata/version'
// 5: require 'bindata/array'
// 6: require 'bindata/bits'
// 7: require 'bindata/buffer'
// 8: require 'bindata/choice'
// 9: require 'bindata/count_bytes_remaining'
// 10: require 'bindata/delayed_io'
// 11: require 'bindata/float'
// 12: require 'bindata/int'
// 13: require 'bindata/primitive'
// 14: require 'bindata/record'
// 15: require 'bindata/rest'
// 16: require 'bindata/section'
// 17: require 'bindata/skip'
// 18: require 'bindata/string'
// 19: require 'bindata/stringz'
// 20: require 'bindata/struct'
// 21: require 'bindata/trace'
// 22: require 'bindata/uint8_array'
// 23: require 'bindata/virtual'
// 24: require 'bindata/alignment'
// 25: require 'bindata/warnings'
// 26:
// 27: # = BinData
// 28: #
// 29: # A declarative way to read and write structured binary data.
// 30: #
// 31: # A full reference manual is available online at
// 32: # https://github.com/dmendel/bindata/wiki
// 33: #
// 34: # == License
// 35: #
// 36: # BinData is released under the same license as Ruby.
// 37: #
// 38: # Copyright (c) 2007 - 2025 Dion Mendel.
