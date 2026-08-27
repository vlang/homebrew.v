module shared_context

// Translated from Homebrew/brew `test/support/helper/spec/shared_context/trust_store.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tmpdir"
// 5:
// 6: # Isolate the `Homebrew::Trust` store in a per-example config home so a parallel worker's teardown
// 7: # (which deletes the shared default `trust.json`) cannot clobber it between writing and re-reading.
// 8: RSpec.shared_context "trust store" do # rubocop:disable RSpec/ContextWording
// 9:   T.bind(self, T.class_of(RSpec::Core::ExampleGroup))
// 10:
// 11:   around do |example|
// 12:     Dir.mktmpdir do |config_home|
// 13:       with_env(HOMEBREW_USER_CONFIG_HOME: config_home) { example.run }
// 14:     end
// 15:   end
// 16: end
// 17:
// 18: RSpec.configure do |config|
// 19:   config.include_context "trust store", :trust_store
// 20: end
