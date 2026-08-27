module homebrew

// Translated from Homebrew/brew `autobump_constants.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: NO_AUTOBUMP_REASONS_INTERNAL = T.let({
// 5:   extract_plist:  "livecheck uses `:extract_plist` strategy",
// 6:   latest_version: "`version` is set to `:latest`",
// 7: }.freeze, T::Hash[Symbol, String])
// 8:
// 9: NO_AUTOBUMP_REASONS_DEPRECATED = T.let({
// 10:   requires_manual_review: "a manual review of this package is required for inclusion in autobump",
// 11: }.freeze, T::Hash[Symbol, String])
// 12:
// 13: # The valid symbols for passing to `no_autobump!` in a `Formula` or `Cask`.
// 14: # @api public
// 15: NO_AUTOBUMP_REASONS_LIST = T.let(
// 16:   {
// 17:     incompatible_version_format: "the package has a version format that can only be updated manually",
// 18:     bumped_by_upstream:          "updates to the package are handled by the upstream developers",
// 19:   }
// 20:     .merge(NO_AUTOBUMP_REASONS_INTERNAL)
// 21:     .merge(NO_AUTOBUMP_REASONS_DEPRECATED)
// 22:     .freeze,
// 23:   T::Hash[Symbol, String],
// 24: )
