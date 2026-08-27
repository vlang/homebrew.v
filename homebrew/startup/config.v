module startup

// Translated from Homebrew/brew `startup/config.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: raise "HOMEBREW_BREW_FILE was not exported! Please call bin/brew directly!" unless ENV["HOMEBREW_BREW_FILE"]
// 5:
// 6: # The path to the executable that should be used to run `brew`.
// 7: # This may be HOMEBREW_ORIGINAL_BREW_FILE depending on the system configuration.
// 8: # Favour this instead of running `brew` and expecting it to be in the `PATH`.
// 9: # @api public
// 10: HOMEBREW_BREW_FILE = Pathname(ENV.fetch("HOMEBREW_BREW_FILE")).freeze
// 11:
// 12: # Where Homebrew is installed and files are linked to.
// 13: # @api public
// 14: HOMEBREW_PREFIX = Pathname(ENV.fetch("HOMEBREW_PREFIX")).freeze
// 15:
// 16: # Where Homebrew stores built formulae packages, linking (non-keg-only) ones
// 17: # back to `HOMEBREW_PREFIX`.
// 18: # @api public
// 19: HOMEBREW_CELLAR = Pathname(ENV.fetch("HOMEBREW_CELLAR")).freeze
// 20:
// 21: # Where Homebrew downloads (bottles, source tarballs, casks etc.) are cached.
// 22: # @api public
// 23: HOMEBREW_CACHE = Pathname(ENV.fetch("HOMEBREW_CACHE")).freeze
// 24:
// 25: # Where Homebrew stores temporary files.
// 26: # We use `/tmp` instead of `TMPDIR` because long paths break Unix domain
// 27: # sockets.
// 28: # @api public
// 29: HOMEBREW_TEMP = Pathname(ENV.fetch("HOMEBREW_TEMP")).then do |tmp|
// 30:   tmp.mkpath unless tmp.exist?
// 31:   tmp.realpath
// 32: end.freeze
// 33:
// 34: # Path to `bin/brew` main executable in `HOMEBREW_PREFIX`
// 35: # Used for e.g. permissions checks.
// 36: HOMEBREW_ORIGINAL_BREW_FILE = Pathname(ENV.fetch("HOMEBREW_ORIGINAL_BREW_FILE")).freeze
// 37:
// 38: # Where `.git` is found
// 39: HOMEBREW_REPOSITORY = Pathname(ENV.fetch("HOMEBREW_REPOSITORY")).freeze
// 40:
// 41: # Where we store most of Homebrew, taps and various metadata
// 42: HOMEBREW_LIBRARY = Pathname(ENV.fetch("HOMEBREW_LIBRARY")).freeze
// 43:
// 44: # Where shim scripts for various build and SCM tools are stored
// 45: HOMEBREW_SHIMS_PATH = (HOMEBREW_LIBRARY/"Homebrew/shims").freeze
// 46:
// 47: # Where external data that has been incorporated into Homebrew is stored
// 48: HOMEBREW_DATA_PATH = (HOMEBREW_LIBRARY/"Homebrew/data").freeze
// 49:
// 50: # Where we store symlinks to currently linked kegs
// 51: HOMEBREW_LINKED_KEGS = (HOMEBREW_PREFIX/"var/homebrew/linked").freeze
// 52:
// 53: # Where we store symlinks to currently version-pinned kegs
// 54: HOMEBREW_PINNED_KEGS = (HOMEBREW_PREFIX/"var/homebrew/pinned").freeze
// 55:
// 56: # Where we store symlinks to currently version-pinned casks
// 57: HOMEBREW_PINNED_CASKS = (HOMEBREW_PREFIX/"var/homebrew/pinned_casks").freeze
// 58:
// 59: # Where we store lock files
// 60: HOMEBREW_LOCKS = (HOMEBREW_PREFIX/"var/homebrew/locks").freeze
// 61:
// 62: # Where we store temporary cellar files that must be in the prefix
// 63: HOMEBREW_TEMP_CELLAR = (HOMEBREW_PREFIX/"var/homebrew/tmp/.cellar").freeze
// 64:
// 65: # Where we store Casks
// 66: HOMEBREW_CASKROOM = Pathname(ENV.fetch("HOMEBREW_CASKROOM")).freeze
// 67:
// 68: # Where formulae installed via URL are cached
// 69: HOMEBREW_CACHE_FORMULA = (HOMEBREW_CACHE/"Formula").freeze
// 70:
// 71: # Where build, postinstall and test logs of formulae are written to
// 72: HOMEBREW_LOGS = Pathname(ENV.fetch("HOMEBREW_LOGS")).expand_path.freeze
// 73:
// 74: # Where installed taps live
// 75: HOMEBREW_TAP_DIRECTORY = (HOMEBREW_LIBRARY/"Taps").freeze
// 76:
// 77: # The Ruby path and args to use for forked Ruby calls
// 78: HOMEBREW_RUBY_EXEC_ARGS = [
// 79:   RUBY_PATH,
// 80:   ENV.fetch("HOMEBREW_RUBY_WARNINGS"),
// 81:   ENV.fetch("HOMEBREW_RUBY_DISABLE_OPTIONS"),
// 82: ].freeze
// 83:
// 84: # Location for `brew alias` and `brew unalias` commands.
// 85: #
// 86: # Unix-Like systems store config in $HOME/.config whose location can be
// 87: # overridden by the XDG_CONFIG_HOME environment variable. Unfortunately
// 88: # Homebrew strictly filters environment variables in BuildEnvironment.
// 89: HOMEBREW_ALIASES = if (path = Pathname.new("~/.config/brew-aliases").expand_path).exist? ||
// 90:                       (path = Pathname.new("~/.brew-aliases").expand_path).exist?
// 91:   path.realpath
// 92: else
// 93:   path
// 94: end.freeze
