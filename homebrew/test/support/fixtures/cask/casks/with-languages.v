module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-languages.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-languages" do
// 4:   version "1.2.3"
// 5:
// 6:   language "zh" do
// 7:     sha256 "fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5"
// 8:     app "Container.app"
// 9:     "zh-CN"
// 10:   end
// 11:   language "en-US", default: true do
// 12:     sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 13:     app "Caffeine.app"
// 14:     "en-US"
// 15:   end
// 16:
// 17:   archive = (language == "zh-CN") ? "container.tar.gz" : "caffeine.zip"
// 18:   url "file://#{TEST_FIXTURE_DIR}/cask/#{archive}"
// 19:   name "Caffeine"
// 20:   homepage "https://brew.sh/"
// 21:
// 22:   depends_on macos: :catalina
// 23: end
