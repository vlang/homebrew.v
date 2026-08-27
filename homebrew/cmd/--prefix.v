module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/--prefix.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.command_name = "--prefix"` at line 39.
pub fn ruby_prefix_l39_d1_self_command_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.command_name', ...args)
}

// Ruby method `run` at line 62.
pub fn ruby_prefix_l62_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `list_unbrewed` at line 96.
pub fn ruby_prefix_l96_d3_list_unbrewed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list_unbrewed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Prefix < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       UNBREWED_EXCLUDE_FILES = %w[.DS_Store].freeze
// 13:       UNBREWED_EXCLUDE_PATHS = %w[
// 14:         */.keepme
// 15:         .github/*
// 16:         bin/brew
// 17:         completions/zsh/_brew
// 18:         docs/*
// 19:         lib/gdk-pixbuf-2.0/*
// 20:         lib/gio/*
// 21:         lib/node_modules/*
// 22:         lib/python[23].[0-9]/*
// 23:         lib/python3.[0-9][0-9]/*
// 24:         lib/pypy/*
// 25:         lib/pypy3/*
// 26:         lib/ruby/gems/[12].*
// 27:         lib/ruby/site_ruby/[12].*
// 28:         lib/ruby/vendor_ruby/[12].*
// 29:         manpages/brew.1
// 30:         share/pypy/*
// 31:         share/pypy3/*
// 32:         share/info/dir
// 33:         share/man/whatis
// 34:         share/mime/*
// 35:         texlive/*
// 36:       ].freeze
// 37:
// 38:       sig { override.returns(String) }
// 39:       def self.command_name = "--prefix"
// 40:
// 41:       cmd_args do
// 42:         description <<~EOS
// 43:           Display Homebrew's install path. *Default:*
// 44:
// 45:             - macOS ARM: `#{HOMEBREW_MACOS_ARM_DEFAULT_PREFIX}`
// 46:             - macOS Intel: `#{HOMEBREW_DEFAULT_PREFIX}`
// 47:             - Linux: `#{HOMEBREW_LINUX_DEFAULT_PREFIX}`
// 48:
// 49:           If <formula> is provided, display the location where <formula> is or would be installed.
// 50:         EOS
// 51:         switch "--unbrewed",
// 52:                description: "List files in Homebrew's prefix not installed by Homebrew."
// 53:         switch "--installed",
// 54:                description: "Outputs nothing and returns a failing status code if <formula> is not installed."
// 55:
// 56:         conflicts "--unbrewed", "--installed"
// 57:
// 58:         named_args :formula
// 59:       end
// 60:
// 61:       sig { override.void }
// 62:       def run
// 63:         raise UsageError, "`--installed` requires a formula argument." if args.installed? && args.no_named?
// 64:
// 65:         if args.unbrewed?
// 66:           raise UsageError, "`--unbrewed` does not take a formula argument." unless args.no_named?
// 67:
// 68:           list_unbrewed
// 69:         elsif args.no_named?
// 70:           puts HOMEBREW_PREFIX
// 71:         else
// 72:           formulae = args.named.to_resolved_formulae
// 73:           prefixes = formulae.filter_map do |f|
// 74:             next nil if args.installed? && !f.opt_prefix.exist?
// 75:
// 76:             # this case will be short-circuited by brew.sh logic for a single formula
// 77:             f.opt_prefix
// 78:           end
// 79:           puts prefixes
// 80:           if args.installed?
// 81:             missing_formulae = formulae.reject(&:optlinked?)
// 82:                                        .map(&:name)
// 83:             return if missing_formulae.blank?
// 84:
// 85:             raise NotAKegError, <<~EOS
// 86:               The following formulae are not installed:
// 87:               #{missing_formulae.join(" ")}
// 88:             EOS
// 89:           end
// 90:         end
// 91:       end
// 92:
// 93:       private
// 94:
// 95:       sig { void }
// 96:       def list_unbrewed
// 97:         dirs  = HOMEBREW_PREFIX.subdirs.map { |dir| dir.basename.to_s }
// 98:         dirs -= %w[Library Cellar Caskroom .git]
// 99:
// 100:         # Exclude cache, logs and repository, if they are located under the prefix.
// 101:         [HOMEBREW_CACHE, HOMEBREW_LOGS, HOMEBREW_REPOSITORY].each do |dir|
// 102:           dirs.delete dir.relative_path_from(HOMEBREW_PREFIX).to_s
// 103:         end
// 104:         dirs.delete "etc"
// 105:         dirs.delete "var"
// 106:
// 107:         arguments = dirs.sort + %w[-type f (]
// 108:         arguments.concat UNBREWED_EXCLUDE_FILES.flat_map { |f| %W[! -name #{f}] }
// 109:         arguments.concat UNBREWED_EXCLUDE_PATHS.flat_map { |d| %W[! -path #{d}] }
// 110:         arguments.push ")"
// 111:
// 112:         cd(HOMEBREW_PREFIX) { safe_system("find", *arguments) }
// 113:       end
// 114:     end
// 115:   end
// 116: end
