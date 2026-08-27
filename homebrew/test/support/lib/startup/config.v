module startup

// Translated from Homebrew/brew `test/support/lib/startup/config.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: raise "HOMEBREW_BREW_FILE was not exported! Please call bin/brew directly!" unless ENV["HOMEBREW_BREW_FILE"]
// 5:
// 6: HOMEBREW_ORIGINAL_BREW_FILE = Pathname.new(ENV.fetch("HOMEBREW_ORIGINAL_BREW_FILE")).freeze
// 7: HOMEBREW_BREW_FILE = Pathname.new(ENV.fetch("HOMEBREW_BREW_FILE")).freeze
// 8:
// 9: TEST_TMPDIR = ENV.fetch("HOMEBREW_TEST_TMPDIR") do |k|
// 10:   dir = Dir.mktmpdir("homebrew-tests-", ENV.fetch("HOMEBREW_TEMP"))
// 11:   at_exit do
// 12:     # Child processes inherit this at_exit handler, but we don't want them
// 13:     # to clean TEST_TMPDIR up prematurely (i.e. when they exit early for a test).
// 14:     FileUtils.remove_entry(dir) unless ENV["HOMEBREW_TEST_NO_EXIT_CLEANUP"]
// 15:   end
// 16:   ENV[k] = dir
// 17: end.freeze
// 18:
// 19: # Paths pointing into the Homebrew code base that persist across test runs
// 20: HOMEBREW_SHIMS_PATH = (HOMEBREW_LIBRARY_PATH/"shims").freeze
// 21:
// 22: # Where external data that has been incorporated into Homebrew is stored
// 23: HOMEBREW_DATA_PATH = (HOMEBREW_LIBRARY_PATH/"data").freeze
// 24:
// 25: # Paths redirected to a temporary directory and wiped at the end of the test run
// 26: HOMEBREW_PREFIX        = (Pathname(TEST_TMPDIR)/"prefix").freeze
// 27: HOMEBREW_ALIASES       = (Pathname(TEST_TMPDIR)/"aliases").freeze
// 28: HOMEBREW_REPOSITORY    = HOMEBREW_PREFIX.dup.freeze
// 29: HOMEBREW_LIBRARY       = (HOMEBREW_REPOSITORY/"Library").freeze
// 30: HOMEBREW_CACHE         = (HOMEBREW_PREFIX.parent/"cache").freeze
// 31: HOMEBREW_CACHE_FORMULA = (HOMEBREW_PREFIX.parent/"formula_cache").freeze
// 32: HOMEBREW_LINKED_KEGS   = (HOMEBREW_PREFIX/"var/homebrew/linked").freeze
// 33: HOMEBREW_PINNED_KEGS   = (HOMEBREW_PREFIX/"var/homebrew/pinned").freeze
// 34: HOMEBREW_PINNED_CASKS  = (HOMEBREW_PREFIX/"var/homebrew/pinned_casks").freeze
// 35: HOMEBREW_LOCKS         = (HOMEBREW_PREFIX/"var/homebrew/locks").freeze
// 36: HOMEBREW_TEMP_CELLAR   = (HOMEBREW_PREFIX/"var/homebrew/tmp/.cellar").freeze
// 37: HOMEBREW_CELLAR        = (HOMEBREW_PREFIX/"Cellar").freeze
// 38: HOMEBREW_LOGS          = (HOMEBREW_PREFIX.parent/"logs").freeze
// 39: HOMEBREW_TEMP          = (HOMEBREW_PREFIX.parent/"temp").freeze
// 40: HOMEBREW_TAP_DIRECTORY = (HOMEBREW_LIBRARY/"Taps").freeze
// 41: HOMEBREW_RUBY_EXEC_ARGS = [
// 42:   RUBY_PATH,
// 43:   ENV.fetch("HOMEBREW_RUBY_WARNINGS"),
// 44:   ENV.fetch("HOMEBREW_RUBY_DISABLE_OPTIONS"),
// 45:   "-I", HOMEBREW_LIBRARY_PATH/"test/support/lib"
// 46: ].freeze
// 47:
// 48: TEST_FIXTURE_DIR = (HOMEBREW_LIBRARY_PATH/"test/support/fixtures").freeze
// 49:
// 50: TESTBALL_SHA256 = "91e3f7930c98d7ccfb288e115ed52d06b0e5bc16fec7dce8bdda86530027067b"
// 51:
// 52: TEST_SHA256 = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
