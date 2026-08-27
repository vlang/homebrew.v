module utils

import brew_runtime

// Translated from Homebrew/brew `utils/clang.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.write_system_config_files(config_dir:, macos_version:, kernel_version:, arch:)` at line 14.
pub fn ruby_clang_l14_d1_self_write_system_config_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_system_config_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   module Clang
// 6:     sig {
// 7:       params(
// 8:         config_dir:     Pathname,
// 9:         macos_version:  T.any(String, MacOSVersion),
// 10:         kernel_version: T.any(String, Version),
// 11:         arch:           Symbol,
// 12:       ).void
// 13:     }
// 14:     def self.write_system_config_files(config_dir:, macos_version:, kernel_version:, arch:)
// 15:       config_dir.mkpath
// 16:       arches = Set.new([:arm64, :x86_64, :aarch64, arch])
// 17:       sysroot = if macos_version.blank? || MacOS.version > macos_version
// 18:         "#{MacOS::CLT::PKG_PATH}/SDKs/MacOSX.sdk"
// 19:       else
// 20:         "#{MacOS::CLT::PKG_PATH}/SDKs/MacOSX#{macos_version}.sdk"
// 21:       end
// 22:
// 23:       { darwin: kernel_version, macosx: macos_version }.each do |system, version|
// 24:         arches.each do |target_arch|
// 25:           (config_dir/"#{target_arch}-apple-#{system}#{version}.cfg").atomic_write <<~CONFIG
// 26:             -isysroot #{sysroot}
// 27:           CONFIG
// 28:         end
// 29:       end
// 30:     end
// 31:   end
// 32: end
