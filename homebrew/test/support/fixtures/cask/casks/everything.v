module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/everything.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # Used to test cask hash generation.
// 2: cask "everything" do
// 3:   version "1.2.3"
// 4:
// 5:   language "en", default: true do
// 6:     sha256 "c64c05bdc0be845505d6e55e69e696a7f50d40846e76155f0c85d5ff5e7bbb84"
// 7:     "en-US"
// 8:   end
// 9:   language "eo" do
// 10:     sha256 "e8ffa07370a7fb7e1696b04c269e01d3459725965a32facdd54629a95d148908"
// 11:     "eo"
// 12:   end
// 13:
// 14:   url "https://cachefly.everything.app/releases/Everything_#{version}.zip",
// 15:       user_agent: :fake,
// 16:       cookies:    { "ALL" => "1234" }
// 17:   name "Everything"
// 18:   desc "Little bit of everything"
// 19:   homepage "https://www.everything.app/"
// 20:
// 21:   auto_updates true
// 22:   conflicts_with cask: "nothing"
// 23:   depends_on cask: "something"
// 24:   depends_on macos: :catalina
// 25:   container type: :naked
// 26:
// 27:   rename "Foobar.app", "Foo.app"
// 28:   rename "Foo.app", "Bar.app"
// 29:
// 30:   app "Everything.app"
// 31:   installer script: {
// 32:     executable:   "~/just/another/path/install.sh",
// 33:     args:         ["--mode=silent"],
// 34:     sudo:         true,
// 35:     print_stderr: false,
// 36:   }
// 37:
// 38:   uninstall launchctl: "com.every.thing.agent",
// 39:             signal:    [
// 40:               ["TERM", "com.every.thing.controller#{version.major}"],
// 41:               ["TERM", "com.every.thing.bin"],
// 42:             ],
// 43:             kext:      "com.every.thing.driver",
// 44:             delete:    "/Library/EverythingHelperTools"
// 45:
// 46:   zap trash: [
// 47:     "~/.everything",
// 48:     "~/Library/Everything",
// 49:   ]
// 50:
// 51:   caveats "Installing everything might take a while..."
// 52: end
