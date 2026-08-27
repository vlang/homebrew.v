module homebrew

// Translated from Homebrew/brew `compilers.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module CompilerConstants
// 5:   # GCC 8 is the minimum version needed for `-ffile-prefix-map`.
// 6:   # Oldest GCC versions in use by LTS distros include:
// 7:   # * Ubuntu 18.04 (ESM ends 2028-04-01) - GCC 7 default, GCC 8 is available
// 8:   # * RHEL 8 (ELS ends 2032-05-31) - GCC 8 default and newer versions via gcc-toolset
// 9:   GNU_GCC_VERSIONS = %w[8 9 10 11 12 13 14 15 16].freeze
// 10:   GNU_GCC_REGEXP = /^gcc-(#{GNU_GCC_VERSIONS.join("|")})$/
// 11:   COMPILER_SYMBOL_MAP = T.let({
// 12:     "gcc"        => :gcc,
// 13:     "clang"      => :clang,
// 14:     "llvm_clang" => :llvm_clang,
// 15:   }.freeze, T::Hash[String, Symbol])
// 16:
// 17:   COMPILERS = T.let((COMPILER_SYMBOL_MAP.values +
// 18:                      GNU_GCC_VERSIONS.map { |n| "gcc-#{n}" }).freeze, T::Array[T.any(String, Symbol)])
// 19: end
// 20: require "compilers/compiler_failure"
// 21: require "compilers/compiler_selector"
// 22:
// 23: require "extend/os/compilers"
