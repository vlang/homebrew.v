module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-embedded-binary.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-embedded-binary" do
// 4:   version "1.2.3"
// 5:   sha256 "fe052d3e77d92676775fd916ddb8942e72a565b844ea7f6d055474c99bb4e47b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/AppWithEmbeddedBinary.zip"
// 8:   homepage "https://brew.sh/with-binary"
// 9:
// 10:   app "App.app"
// 11:   binary "#{appdir}/App.app/Contents/MacOS/App/binary"
// 12: end
