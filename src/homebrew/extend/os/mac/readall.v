module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/readall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_casks?(tap, os_name: nil, arch: ::Hardware::CPU.type, files: nil)` at line 23.
pub fn ruby_readall_l23_d1_valid_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_casks?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Readall
// 9:       module ClassMethods
// 10:         extend T::Helpers
// 11:         include ::Utils::Output::Mixin
// 12:
// 13:         requires_ancestor { Kernel }
// 14:
// 15:         sig {
// 16:           params(
// 17:             tap:     ::Tap,
// 18:             os_name: T.nilable(Symbol),
// 19:             arch:    T.nilable(Symbol),
// 20:             files:   T.nilable(T::Array[::Pathname]),
// 21:           ).returns(T::Boolean)
// 22:         }
// 23:         def valid_casks?(tap, os_name: nil, arch: ::Hardware::CPU.type, files: nil)
// 24:           return super if os_name == :linux
// 25:
// 26:           current_macos_version = if os_name.is_a?(Symbol)
// 27:             MacOSVersion.from_symbol(os_name)
// 28:           else
// 29:             MacOS.version
// 30:           end
// 31:
// 32:           success = T.let(true, T::Boolean)
// 33:           (files || tap.cask_files).each do |file|
// 34:             cask = ::Cask::CaskLoader.load(file)
// 35:
// 36:             # Fine to have missing URLs for unsupported macOS
// 37:             macos_req = cask.depends_on.macos
// 38:             next if macos_req&.version && Array(macos_req.version).none? do |macos_version|
// 39:               current_macos_version.compare(macos_req.comparator, macos_version)
// 40:             end
// 41:
// 42:             raise "Missing URL" if cask.url.nil?
// 43:           rescue Interrupt
// 44:             raise
// 45:           # Handle all possible exceptions reading Casks.
// 46:           rescue Exception => e # rubocop:disable Lint/RescueException
// 47:             os_and_arch = "macOS #{current_macos_version} on #{arch}"
// 48:             onoe "Invalid cask (#{os_and_arch}): #{file}"
// 49:             $stderr.puts e
// 50:             success = false
// 51:           end
// 52:           success
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57: end
// 58:
// 59: Readall.singleton_class.prepend(OS::Mac::Readall::ClassMethods)
