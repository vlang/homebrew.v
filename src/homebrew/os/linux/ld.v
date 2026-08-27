module linux

import brew_runtime

// Translated from Homebrew/brew `os/linux/ld.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :system_ld_so` at line 24.
pub fn ruby_ld_l24_d1_system_ld_so(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('system_ld_so=', ...args)
}

// Ruby method `self.system_ld_so` at line 29.
pub fn ruby_ld_l29_d2_self_system_ld_so(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.system_ld_so', ...args)
}

// Ruby method `self.ld_so_diagnostics(brewed: true)` at line 38.
pub fn ruby_ld_l38_d3_self_ld_so_diagnostics(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ld_so_diagnostics', ...args)
}

// Ruby method `self.sysconfdir(brewed: true)` at line 62.
pub fn ruby_ld_l62_d4_self_sysconfdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sysconfdir', ...args)
}

// Ruby method `self.system_dirs(brewed: true)` at line 72.
pub fn ruby_ld_l72_d5_self_system_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.system_dirs', ...args)
}

// Ruby method `self.library_paths(conf_path = "ld.so.conf", brewed: true)` at line 86.
pub fn ruby_ld_l86_d6_self_library_paths(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.library_paths', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     # Helper functions for querying `ld` information.
// 7:     module Ld
// 8:       # This is a list of known paths to the host dynamic linker on Linux if
// 9:       # the host glibc is new enough. Brew will fail to create a symlink for
// 10:       # ld.so if the host linker cannot be found in this list.
// 11:       DYNAMIC_LINKERS = %w[
// 12:         /lib64/ld-linux-x86-64.so.2
// 13:         /lib64/ld64.so.2
// 14:         /lib/ld-linux.so.3
// 15:         /lib/ld-linux.so.2
// 16:         /lib/ld-linux-aarch64.so.1
// 17:         /lib/ld-linux-armhf.so.3
// 18:         /system/bin/linker64
// 19:         /system/bin/linker
// 20:       ].freeze
// 21:
// 22:       class << self
// 23:         sig { params(system_ld_so: T.nilable(::Pathname)).returns(T.nilable(::Pathname)) }
// 24:         attr_writer :system_ld_so
// 25:       end
// 26:
// 27:       # The path to the system's dynamic linker or `nil` if not found
// 28:       sig { returns(T.nilable(::Pathname)) }
// 29:       def self.system_ld_so
// 30:         @system_ld_so ||= T.let(nil, T.nilable(::Pathname))
// 31:         @system_ld_so ||= begin
// 32:           linker = DYNAMIC_LINKERS.find { |s| File.executable? s }
// 33:           Pathname(linker) if linker
// 34:         end
// 35:       end
// 36:
// 37:       sig { params(brewed: T::Boolean).returns(String) }
// 38:       def self.ld_so_diagnostics(brewed: true)
// 39:         @ld_so_diagnostics ||= T.let({}, T.nilable(T::Hash[Pathname, T.nilable(String)]))
// 40:
// 41:         ld_so_target = if brewed
// 42:           ld_so = HOMEBREW_PREFIX/"lib/ld.so"
// 43:           return "" unless ld_so.exist?
// 44:
// 45:           ld_so.readlink
// 46:         else
// 47:           ld_so = system_ld_so
// 48:           return "" unless ld_so&.exist?
// 49:
// 50:           ld_so
// 51:         end
// 52:
// 53:         @ld_so_diagnostics[ld_so_target] ||= begin
// 54:           ld_so_output = Utils.popen_read(ld_so, "--list-diagnostics")
// 55:           ld_so_output if $CHILD_STATUS.success?
// 56:         end
// 57:
// 58:         @ld_so_diagnostics[ld_so_target].to_s
// 59:       end
// 60:
// 61:       sig { params(brewed: T::Boolean).returns(String) }
// 62:       def self.sysconfdir(brewed: true)
// 63:         fallback_sysconfdir = "/etc"
// 64:
// 65:         match = ld_so_diagnostics(brewed:).match(/path.sysconfdir="(.+)"/)
// 66:         return fallback_sysconfdir unless match
// 67:
// 68:         match.captures.compact.first || fallback_sysconfdir
// 69:       end
// 70:
// 71:       sig { params(brewed: T::Boolean).returns(T::Array[String]) }
// 72:       def self.system_dirs(brewed: true)
// 73:         dirs = []
// 74:
// 75:         ld_so_diagnostics(brewed:).split("\n").each do |line|
// 76:           match = line.match(/path.system_dirs\[0x.*\]="(.*)"/)
// 77:           next unless match
// 78:
// 79:           dirs << match.captures.compact.first
// 80:         end
// 81:
// 82:         dirs
// 83:       end
// 84:
// 85:       sig { params(conf_path: T.any(::Pathname, String), brewed: T::Boolean).returns(T::Array[String]) }
// 86:       def self.library_paths(conf_path = "ld.so.conf", brewed: true)
// 87:         conf_file = Pathname(sysconfdir(brewed:))/conf_path
// 88:         return [] unless conf_file.exist?
// 89:         return [] unless conf_file.file?
// 90:         return [] unless conf_file.readable?
// 91:
// 92:         @library_paths_cache ||= T.let({}, T.nilable(T::Hash[String, T::Array[String]]))
// 93:         cache_key = conf_file.to_s
// 94:         if (cached_library_path_contents = @library_paths_cache[cache_key])
// 95:           return cached_library_path_contents
// 96:         end
// 97:
// 98:         paths = Set.new
// 99:         directory = conf_file.realpath.dirname
// 100:
// 101:         conf_file.open("r") do |file|
// 102:           file.each_line do |line|
// 103:             # Remove comments and leading/trailing whitespace
// 104:             line.strip!
// 105:             line.sub!(/\s*#.*$/, "")
// 106:
// 107:             if line.start_with?(/\s*include\s+/)
// 108:               wildcard = Pathname(line.sub(/^\s*include\s+/, "")).expand_path(directory)
// 109:
// 110:               Dir.glob(wildcard.to_s).each do |include_file|
// 111:                 paths += library_paths(include_file)
// 112:               end
// 113:             elsif line.empty?
// 114:               next
// 115:             else
// 116:               paths << line
// 117:             end
// 118:           end
// 119:         end
// 120:
// 121:         @library_paths_cache[cache_key] = paths.to_a
// 122:       end
// 123:     end
// 124:   end
// 125: end
