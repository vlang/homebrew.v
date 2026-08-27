module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/hockeyapp-with-livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "hockeyapp-with-livecheck" do
// 4:   version "1.0,123"
// 5:   sha256 "a69e7357bea014f4c14ac9699274f559086844ffa46563c4619bf1addfd72ad9"
// 6:
// 7:   url "https://rink.hockeyapp.net/api/2/apps/67503a7926431872c4b6c1549f5bd6b1/app_versions/#{version.csv.second}?format=zip"
// 8:   name "HockeyApp"
// 9:   homepage "https://www.brew.sh/"
// 10:
// 11:   livecheck do
// 12:     url "https://rink.hockeyapp.net/api/2/apps/67503a7926431872c4b6c1549f5bd6b1"
// 13:   end
// 14:
// 15:   app "HockeyApp.app"
// 16: end
