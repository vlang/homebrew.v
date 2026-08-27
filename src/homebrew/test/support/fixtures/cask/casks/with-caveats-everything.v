module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-caveats-everything.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-caveats-everything" do
// 4:   version "1.2.3"
// 5:   sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 8:   homepage "https://brew.sh/"
// 9:
// 10:   depends_on macos: :catalina
// 11:
// 12:   app "Caffeine.app"
// 13:
// 14:   # simple string is evaluated at compile-time
// 15:   caveats <<~EOS
// 16:     Here are some things you might want to know.
// 17:   EOS
// 18:   # do block is evaluated at install-time
// 19:   caveats do
// 20:     "Cask token: #{token}"
// 21:   end
// 22:   # a do block may print and use a DSL
// 23:   caveats do
// 24:     puts "Custom text via puts followed by DSL-generated text:"
// 25:     kext
// 26:     unsigned_accessibility
// 27:     path_environment_variable "/custom/path/bin"
// 28:     zsh_path_helper "/example/path"
// 29:     files_in_usr_local
// 30:     depends_on_java "11+"
// 31:     requires_rosetta
// 32:     logout
// 33:     reboot
// 34:     license "https://brew.sh/test-license/"
// 35:     free_license "https://brew.sh/test-free-license/"
// 36:   end
// 37: end
