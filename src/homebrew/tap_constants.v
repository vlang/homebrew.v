module homebrew

// Translated from Homebrew/brew `tap_constants.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Match a formula name.
// 5: HOMEBREW_TAP_FORMULA_NAME_REGEX = /(?<name>[\w+\-.@]+)/
// 6: # Match taps' formulae, e.g. `someuser/sometap/someformula`.
// 7: HOMEBREW_TAP_FORMULA_REGEX =
// 8:   %r{\A(?<user>[^/]+)/(?<repository>[^/]+)/#{HOMEBREW_TAP_FORMULA_NAME_REGEX.source}\Z}
// 9: # Match default formula taps' formulae, e.g. `homebrew/core/someformula` or `someformula`.
// 10: HOMEBREW_DEFAULT_TAP_FORMULA_REGEX =
// 11:   %r{\A(?:[Hh]omebrew/(?:homebrew-)?core/)?(?<name>#{HOMEBREW_TAP_FORMULA_NAME_REGEX.source})\Z}
// 12: # Match taps' remote repository, e.g. `someuser/somerepo`.
// 13: HOMEBREW_TAP_REPOSITORY_REGEX =
// 14:   %r{\A.+[/:](?<remote_repository>[^/:]+/[^/:]+?(?=\.git/*\Z|/*\Z))}
// 15:
// 16: # Match a cask token.
// 17: HOMEBREW_TAP_CASK_TOKEN_REGEX = /(?<token>[\w+\-.@]+)/
// 18: # Match taps' casks, e.g. `someuser/sometap/somecask`.
// 19: HOMEBREW_TAP_CASK_REGEX =
// 20:   %r{\A(?<user>[^/]+)/(?<repository>[^/]+)/#{HOMEBREW_TAP_CASK_TOKEN_REGEX.source}\Z}
// 21: # Match default cask taps' casks, e.g. `homebrew/cask/somecask` or `somecask`.
// 22: HOMEBREW_DEFAULT_TAP_CASK_REGEX =
// 23:   %r{\A(?:[Hh]omebrew/(?:homebrew-)?cask/)?#{HOMEBREW_TAP_CASK_TOKEN_REGEX.source}\Z}
// 24:
// 25: # Match taps' directory paths, e.g. `HOMEBREW_LIBRARY/Taps/someuser/sometap`.
// 26: HOMEBREW_TAP_DIR_REGEX =
// 27:   %r{#{Regexp.escape(HOMEBREW_LIBRARY.to_s)}/Taps/(?<user>[^/]+)/(?<repository>[^/]+)}
// 28: # Match taps' formula paths, e.g. `HOMEBREW_LIBRARY/Taps/someuser/sometap/someformula`.
// 29: HOMEBREW_TAP_PATH_REGEX = Regexp.new(HOMEBREW_TAP_DIR_REGEX.source + %r{(?:/.*)?\Z}.source).freeze
// 30: # Match official cask taps, e.g `homebrew/cask`.
// 31: HOMEBREW_CASK_TAP_REGEX =
// 32:   %r{(?:([Cc]askroom)/(cask)|([Hh]omebrew)/(?:homebrew-)?(cask|cask-[\w-]+))}
// 33: # Match official taps' casks, e.g. `homebrew/cask/somecask`.
// 34: HOMEBREW_CASK_TAP_CASK_REGEX =
// 35:   %r{\A#{HOMEBREW_CASK_TAP_REGEX.source}/#{HOMEBREW_TAP_CASK_TOKEN_REGEX.source}\Z}
// 36: HOMEBREW_OFFICIAL_REPO_PREFIXES_REGEX = /\A(home|linux)brew-/
