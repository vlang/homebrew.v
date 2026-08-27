module cask

import brew_runtime

// Translated from Homebrew/brew `cask/reinstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.reinstall_casks(` at line 18.
pub fn ruby_reinstall_l18_d1_self_reinstall_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reinstall_casks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5: require "install"
// 6:
// 7: module Cask
// 8:   class Reinstall
// 9:     extend ::Utils::Output::Mixin
// 10:
// 11:     sig {
// 12:       params(
// 13:         casks: ::Cask::Cask, verbose: T::Boolean, force: T::Boolean, skip_cask_deps: T::Boolean, binaries: T::Boolean,
// 14:         require_sha: T::Boolean, zap: T::Boolean, skip_prefetch: T::Boolean,
// 15:         download_queue: T.nilable(Homebrew::DownloadQueue)
// 16:       ).void
// 17:     }
// 18:     def self.reinstall_casks(
// 19:       *casks,
// 20:       verbose: false,
// 21:       force: false,
// 22:       skip_cask_deps: false,
// 23:       binaries: false,
// 24:       require_sha: false,
// 25:       zap: false,
// 26:       skip_prefetch: false,
// 27:       download_queue: nil
// 28:     )
// 29:       require "cask/installer"
// 30:
// 31:       created_download_queue = T.let(false, T::Boolean)
// 32:       if download_queue.nil?
// 33:         if skip_prefetch
// 34:           download_queue = Homebrew.default_download_queue
// 35:         else
// 36:           download_queue = Homebrew::DownloadQueue.new(pour: true)
// 37:           created_download_queue = true
// 38:         end
// 39:       end
// 40:
// 41:       cask_installers = T.let([], T::Array[Installer])
// 42:       begin
// 43:         cask_installers = casks.map do |cask|
// 44:           Installer.new(
// 45:             cask,
// 46:             binaries:,
// 47:             verbose:,
// 48:             force:,
// 49:             skip_cask_deps:,
// 50:             require_sha:,
// 51:             reinstall:      true,
// 52:             zap:,
// 53:             download_queue:,
// 54:             defer_fetch:    true,
// 55:           )
// 56:         end
// 57:
// 58:         unless skip_prefetch
// 59:           Homebrew::Install.enqueue_cask_installers(cask_installers, download_queue:)
// 60:           download_queue.fetch(
// 61:             heading: Homebrew::Install.combined_fetch_downloads_heading(cask_names: casks.map(&:full_name)),
// 62:           )
// 63:         end
// 64:       ensure
// 65:         download_queue.shutdown if created_download_queue
// 66:       end
// 67:
// 68:       # Reinstall everything that did download and report each failure as it
// 69:       # happens, rather than aborting the whole run; the failures still exit
// 70:       # nonzero at the end.
// 71:       cask_installers.each do |installer|
// 72:         installer.install
// 73:       rescue => e
// 74:         ofail "#{installer.cask.full_name}: #{e}"
// 75:         next
// 76:       end
// 77:     end
// 78:   end
// 79: end
