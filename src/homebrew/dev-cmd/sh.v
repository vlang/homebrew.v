module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/sh.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 40.
pub fn ruby_sh_l40_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `setup_ruby_environment!` at line 61.
pub fn ruby_sh_l61_d2_setup_ruby_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_ruby_environment!', ...args)
}

// Ruby method `setup_build_environment!` at line 78.
pub fn ruby_sh_l78_d3_setup_build_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_build_environment!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "extend/ENV"
// 6: require "formula"
// 7: require "utils/gem_setup"
// 8: require "utils/shell"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Sh < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Enter an interactive shell for Homebrew's build environment. Use years-battle-hardened
// 16:           build logic to help your `./configure && make && make install`
// 17:           and even your `gem install` succeed. Especially handy if you run Homebrew
// 18:           in an Xcode-only configuration since it adds tools like `make` to your `$PATH`
// 19:           which build systems would not find otherwise.
// 20:
// 21:           With `--ruby`, enter an interactive shell for Homebrew's Ruby environment.
// 22:           This sets up the correct Ruby paths, `$GEM_HOME` and bundle
// 23:           configuration used by Homebrew's development tools.
// 24:           The environment includes gems from the installed groups,
// 25:           making tools like RuboCop, Sorbet and RSpec available via `bundle exec`.
// 26:         EOS
// 27:         switch "-r", "--ruby",
// 28:                description: "Set up Homebrew's Ruby environment."
// 29:         flag   "--env=",
// 30:                description: "Use the standard `$PATH` instead of superenv's when `std` is passed."
// 31:         flag   "-c=", "--cmd=",
// 32:                description: "Execute commands in a non-interactive shell."
// 33:
// 34:         conflicts "--ruby", "--env="
// 35:
// 36:         named_args :file, max: 1
// 37:       end
// 38:
// 39:       sig { override.void }
// 40:       def run
// 41:         prompt, notice = if args.ruby?
// 42:           setup_ruby_environment!
// 43:         else
// 44:           setup_build_environment!
// 45:         end
// 46:
// 47:         preferred_path = Utils::Shell.preferred_path(default: "/bin/bash")
// 48:
// 49:         if args.cmd.present?
// 50:           safe_system(preferred_path, "-c", args.cmd)
// 51:         elsif args.named.present?
// 52:           safe_system(preferred_path, args.named.first)
// 53:         else
// 54:           system Utils::Shell.shell_with_prompt(prompt, preferred_path:, notice:)
// 55:         end
// 56:       end
// 57:
// 58:       private
// 59:
// 60:       sig { returns([String, T.nilable(String)]) }
// 61:       def setup_ruby_environment!
// 62:         Homebrew.install_bundler_gems!(setup_path: true)
// 63:
// 64:         notice = unless Homebrew::EnvConfig.no_env_hints?
// 65:           <<~EOS
// 66:             Your shell has been configured to use Homebrew's Ruby environment.
// 67:             This includes the correct Ruby version, GEM_HOME, and bundle configuration.
// 68:             Tools like RuboCop, Sorbet, and RSpec are available via `bundle exec`.
// 69:             Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 70:             When done, type `exit`.
// 71:           EOS
// 72:         end
// 73:
// 74:         ["brew ruby", notice]
// 75:       end
// 76:
// 77:       sig { returns([String, T.nilable(String)]) }
// 78:       def setup_build_environment!
// 79:         ENV.activate_extensions!(env: args.env)
// 80:
// 81:         if superenv?(args.env)
// 82:           ENV.deps = Formula.installed.select do |f|
// 83:             f.keg_only? && f.opt_prefix.directory?
// 84:           end
// 85:         end
// 86:         ENV.setup_build_environment
// 87:         if superenv?(args.env)
// 88:           # superenv stopped adding brew's bin but generally users will want it
// 89:           ENV["PATH"] = PATH.new(ENV.fetch("PATH")).insert(1, HOMEBREW_PREFIX/"bin").to_s
// 90:         end
// 91:
// 92:         ENV["VERBOSE"] = "1" if args.verbose?
// 93:
// 94:         notice = unless Homebrew::EnvConfig.no_env_hints?
// 95:           <<~EOS
// 96:             Your shell has been configured to use Homebrew's build environment;
// 97:             this should help you build stuff. Notably though, the system versions of
// 98:             gem and pip will ignore our configuration and insist on using the
// 99:             environment they were built under (mostly). Sadly, scons will also
// 100:             ignore our configuration.
// 101:             Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 102:             When done, type `exit`.
// 103:           EOS
// 104:         end
// 105:
// 106:         ["brew", notice]
// 107:       end
// 108:     end
// 109:   end
// 110: end
