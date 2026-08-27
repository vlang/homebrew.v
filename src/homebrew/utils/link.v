module utils

import brew_runtime

// Translated from Homebrew/brew `utils/link.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.link_src_dst_dirs(src_dir, dst_dir, command, link_dir: false)` at line 12.
pub fn ruby_link_l12_d1_self_link_src_dst_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.link_src_dst_dirs', ...args)
}

// Ruby method `self.unlink_src_dst_dirs(src_dir, dst_dir, unlink_dir: false)` at line 47.
pub fn ruby_link_l47_d2_self_unlink_src_dst_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unlink_src_dst_dirs', ...args)
}

// Ruby method `self.link_manpages(path, command)` at line 62.
pub fn ruby_link_l62_d3_self_link_manpages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.link_manpages', ...args)
}

// Ruby method `self.unlink_manpages(path)` at line 67.
pub fn ruby_link_l67_d4_self_unlink_manpages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unlink_manpages', ...args)
}

// Ruby method `self.link_completions(path, command)` at line 72.
pub fn ruby_link_l72_d5_self_link_completions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.link_completions', ...args)
}

// Ruby method `self.unlink_completions(path)` at line 79.
pub fn ruby_link_l79_d6_self_unlink_completions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.unlink_completions', ...args)
}

// Ruby method `self.link_docs(path, command)` at line 86.
pub fn ruby_link_l86_d7_self_link_docs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.link_docs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   # Helper functions for creating symlinks.
// 8:   module Link
// 9:     extend Utils::Output::Mixin
// 10:
// 11:     sig { params(src_dir: Pathname, dst_dir: Pathname, command: String, link_dir: T::Boolean).void }
// 12:     def self.link_src_dst_dirs(src_dir, dst_dir, command, link_dir: false)
// 13:       return unless src_dir.exist?
// 14:
// 15:       conflicts = []
// 16:       src_paths = link_dir ? [src_dir] : src_dir.find
// 17:       src_paths.each do |src|
// 18:         next if src.directory? && !link_dir
// 19:
// 20:         dst = dst_dir/src.relative_path_from(src_dir)
// 21:         if dst.symlink?
// 22:           next if src == dst.resolved_path
// 23:
// 24:           dst.unlink
// 25:         end
// 26:         if dst.exist?
// 27:           conflicts << dst
// 28:           next
// 29:         end
// 30:         dst_dir.parent.mkpath
// 31:         dst.make_relative_symlink(src)
// 32:       end
// 33:
// 34:       return if conflicts.empty?
// 35:
// 36:       onoe <<~EOS
// 37:         Could not link:
// 38:         #{conflicts.join("\n")}
// 39:
// 40:         Please delete these paths and run:
// 41:           #{command}
// 42:       EOS
// 43:     end
// 44:     private_class_method :link_src_dst_dirs
// 45:
// 46:     sig { params(src_dir: Pathname, dst_dir: Pathname, unlink_dir: T::Boolean).void }
// 47:     def self.unlink_src_dst_dirs(src_dir, dst_dir, unlink_dir: false)
// 48:       return unless src_dir.exist?
// 49:
// 50:       src_paths = unlink_dir ? [src_dir] : src_dir.find
// 51:       src_paths.each do |src|
// 52:         next if src.directory? && !unlink_dir
// 53:
// 54:         dst = dst_dir/src.relative_path_from(src_dir)
// 55:         dst.delete if dst.symlink? && src == dst.resolved_path
// 56:         dst.parent.rmdir_if_possible
// 57:       end
// 58:     end
// 59:     private_class_method :unlink_src_dst_dirs
// 60:
// 61:     sig { params(path: Pathname, command: String).void }
// 62:     def self.link_manpages(path, command)
// 63:       link_src_dst_dirs(path/"manpages", HOMEBREW_PREFIX/"share/man/man1", command)
// 64:     end
// 65:
// 66:     sig { params(path: Pathname).void }
// 67:     def self.unlink_manpages(path)
// 68:       unlink_src_dst_dirs(path/"manpages", HOMEBREW_PREFIX/"share/man/man1")
// 69:     end
// 70:
// 71:     sig { params(path: Pathname, command: String).void }
// 72:     def self.link_completions(path, command)
// 73:       link_src_dst_dirs(path/"completions/bash", HOMEBREW_PREFIX/"etc/bash_completion.d", command)
// 74:       link_src_dst_dirs(path/"completions/zsh", HOMEBREW_PREFIX/"share/zsh/site-functions", command)
// 75:       link_src_dst_dirs(path/"completions/fish", HOMEBREW_PREFIX/"share/fish/vendor_completions.d", command)
// 76:     end
// 77:
// 78:     sig { params(path: Pathname).void }
// 79:     def self.unlink_completions(path)
// 80:       unlink_src_dst_dirs(path/"completions/bash", HOMEBREW_PREFIX/"etc/bash_completion.d")
// 81:       unlink_src_dst_dirs(path/"completions/zsh", HOMEBREW_PREFIX/"share/zsh/site-functions")
// 82:       unlink_src_dst_dirs(path/"completions/fish", HOMEBREW_PREFIX/"share/fish/vendor_completions.d")
// 83:     end
// 84:
// 85:     sig { params(path: Pathname, command: String).void }
// 86:     def self.link_docs(path, command)
// 87:       link_src_dst_dirs(path/"docs", HOMEBREW_PREFIX/"share/doc/homebrew", command, link_dir: true)
// 88:     end
// 89:   end
// 90: end
