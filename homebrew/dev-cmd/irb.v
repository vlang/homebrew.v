module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/irb.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(argv = nil) = super(argv || ARGV.dup.freeze)` at line 24.
pub fn ruby_irb_l24_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run` at line 27.
pub fn ruby_irb_l27_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class Irb < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Enter the interactive Homebrew Ruby shell.
// 12:         EOS
// 13:         switch "--examples",
// 14:                description: "Show several examples."
// 15:         switch "--pry",
// 16:                description: "Use Pry instead of IRB.",
// 17:                env:         :pry,
// 18:                replacement: "the default IRB backend (Pry is largely unmaintained upstream)",
// 19:                odeprecated: true
// 20:       end
// 21:
// 22:       # work around IRB modifying ARGV.
// 23:       sig { params(argv: T.nilable(T::Array[String])).void }
// 24:       def initialize(argv = nil) = super(argv || ARGV.dup.freeze)
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         if args.examples?
// 29:           puts <<~EOS
// 30:             'v8'.f # => instance of the v8 formula
// 31:             :hub.f.latest_version_installed?
// 32:             :lua.f.methods - 1.methods
// 33:             :mpd.f.recursive_dependencies.reject(&:installed?)
// 34:
// 35:             'vlc'.c # => instance of the vlc cask
// 36:             :tsh.c.livecheck_defined?
// 37:           EOS
// 38:           return
// 39:         end
// 40:
// 41:         require "keg"
// 42:         require "cask"
// 43:
// 44:         ohai "Interactive Homebrew Shell", "Example commands available with: `brew irb --examples`"
// 45:         ENV["IRBRC"] = (HOMEBREW_LIBRARY_PATH/"brew_irbrc").to_s
// 46:
// 47:         $stdout.flush
// 48:         $stderr.flush
// 49:         exec File.join(RbConfig::CONFIG["bindir"], "irb"), "-I", $LOAD_PATH.join(File::PATH_SEPARATOR), *args.named
// 50:       end
// 51:     end
// 52:   end
// 53: end
