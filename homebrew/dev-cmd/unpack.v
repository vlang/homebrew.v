module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/unpack.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 44.
pub fn ruby_unpack_l44_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `unpack_formula(formula, unpack_dir)` at line 74.
pub fn ruby_unpack_l74_d2_unpack_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpack_formula', ...args)
}

// Ruby method `unpack_cask(cask, unpack_dir)` at line 104.
pub fn ruby_unpack_l104_d3_unpack_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unpack_cask', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "stringio"
// 7: require "formula"
// 8: require "cask/download"
// 9: require "unpack_strategy"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class Unpack < AbstractCommand
// 14:       include FileUtils
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Unpack the files for the <formula> or <cask> into subdirectories of the current
// 19:           working directory.
// 20:         EOS
// 21:         flag   "--destdir=",
// 22:                description: "Create subdirectories in the directory named by <path> instead."
// 23:         switch "--patch",
// 24:                description: "Patches for <formula> will be applied to the unpacked source."
// 25:         switch "-g", "--git",
// 26:                description: "Initialise a Git repository in the unpacked source. This is useful for creating " \
// 27:                             "patches for the software."
// 28:         switch "-f", "--force",
// 29:                description: "Overwrite the destination directory if it already exists."
// 30:         switch "--formula", "--formulae",
// 31:                description: "Treat all named arguments as formulae."
// 32:         switch "--cask", "--casks",
// 33:                description: "Treat all named arguments as casks."
// 34:
// 35:         conflicts "--git", "--patch"
// 36:         conflicts "--formula", "--cask"
// 37:         conflicts "--cask", "--patch"
// 38:         conflicts "--cask", "--git"
// 39:
// 40:         named_args [:formula, :cask], min: 1
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         formulae_and_casks = if args.casks?
// 46:           args.named.to_formulae_and_casks(only: :cask)
// 47:         elsif args.formulae?
// 48:           args.named.to_formulae_and_casks(only: :formula)
// 49:         else
// 50:           args.named.to_formulae_and_casks
// 51:         end
// 52:
// 53:         if (dir = args.destdir)
// 54:           unpack_dir = Pathname.new(dir).expand_path
// 55:           unpack_dir.mkpath
// 56:         else
// 57:           unpack_dir = Pathname.pwd
// 58:         end
// 59:
// 60:         odie "Cannot write to #{unpack_dir}" unless unpack_dir.writable?
// 61:
// 62:         formulae_and_casks.each do |formula_or_cask|
// 63:           if formula_or_cask.is_a?(Cask::Cask)
// 64:             unpack_cask(formula_or_cask, unpack_dir)
// 65:           elsif (formula = T.cast(formula_or_cask, Formula))
// 66:             unpack_formula(formula, unpack_dir)
// 67:           end
// 68:         end
// 69:       end
// 70:
// 71:       private
// 72:
// 73:       sig { params(formula: Formula, unpack_dir: Pathname).void }
// 74:       def unpack_formula(formula, unpack_dir)
// 75:         stage_dir = unpack_dir/"#{formula.name}-#{formula.version}"
// 76:
// 77:         if stage_dir.exist?
// 78:           odie "Destination #{stage_dir} already exists!" unless args.force?
// 79:
// 80:           rm_rf stage_dir
// 81:         end
// 82:
// 83:         oh1 "Unpacking #{Formatter.identifier(formula.full_name)} to: #{stage_dir}"
// 84:
// 85:         # show messages about tar
// 86:         with_env VERBOSE: "1" do
// 87:           formula.brew do
// 88:             formula.patch if args.patch?
// 89:             cp_r getwd, stage_dir, preserve: true
// 90:           end
// 91:         end
// 92:
// 93:         return unless args.git?
// 94:
// 95:         ohai "Setting up Git repository"
// 96:         cd(stage_dir) do
// 97:           system "git", "init", "-q"
// 98:           system "git", "add", "-A"
// 99:           system "git", "commit", "-q", "-m", "brew-unpack"
// 100:         end
// 101:       end
// 102:
// 103:       sig { params(cask: Cask::Cask, unpack_dir: Pathname).void }
// 104:       def unpack_cask(cask, unpack_dir)
// 105:         stage_dir = unpack_dir/"#{cask.token}-#{cask.version}"
// 106:
// 107:         if stage_dir.exist?
// 108:           odie "Destination #{stage_dir} already exists!" unless args.force?
// 109:
// 110:           rm_rf stage_dir
// 111:         end
// 112:
// 113:         oh1 "Unpacking #{Formatter.identifier(cask.full_name)} to: #{stage_dir}"
// 114:
// 115:         download = Cask::Download.new(cask)
// 116:
// 117:         downloaded_path = if download.downloaded?
// 118:           download.cached_download
// 119:         else
// 120:           download.fetch(quiet: false)
// 121:         end
// 122:
// 123:         stage_dir.mkpath
// 124:         UnpackStrategy.detect(downloaded_path).extract_nestedly(to: stage_dir, verbose: true)
// 125:       end
// 126:     end
// 127:   end
// 128: end
