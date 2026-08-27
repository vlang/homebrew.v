module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-many-languages.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-many-languages" do
// 4:   version "1.2.3"
// 5:
// 6:   language "en", default: true do
// 7:     sha256 :no_check
// 8:     "en"
// 9:   end
// 10:   language "cs" do
// 11:     sha256 :no_check
// 12:     "cs"
// 13:   end
// 14:   language "es-AR" do
// 15:     sha256 :no_check
// 16:     "es-AR"
// 17:   end
// 18:   language "ff" do
// 19:     sha256 :no_check
// 20:     "ff"
// 21:   end
// 22:   language "fi" do
// 23:     sha256 :no_check
// 24:     "fi"
// 25:   end
// 26:   language "gn" do
// 27:     sha256 :no_check
// 28:     "gn"
// 29:   end
// 30:   language "gu" do
// 31:     sha256 :no_check
// 32:     "gu"
// 33:   end
// 34:   language "ko" do
// 35:     sha256 :no_check
// 36:     "ko"
// 37:   end
// 38:   language "ru" do
// 39:     sha256 :no_check
// 40:     "ru"
// 41:   end
// 42:   language "sv" do
// 43:     sha256 :no_check
// 44:     "sv"
// 45:   end
// 46:   language "th" do
// 47:     sha256 :no_check
// 48:     "th"
// 49:   end
// 50:
// 51:   url "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip"
// 52:   name "Caffeine"
// 53:   desc "Keep your computer awake"
// 54:   homepage "https://brew.sh/"
// 55:
// 56:   app "Caffeine.app"
// 57: end
