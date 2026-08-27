module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-uninstall-script-app.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-uninstall-script-app" do
// 4:   version "1.2.3"
// 5:   sha256 "5633c3a0f2e572cbf021507dec78c50998b398c343232bdfc7e26221d0a5db4d"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/MyFancyApp.zip"
// 8:   homepage "https://brew.sh/MyFancyApp"
// 9:
// 10:   app "MyFancyApp/MyFancyApp.app"
// 11:
// 12:   postflight do
// 13:     File.write "#{appdir}/MyFancyApp.app/uninstall.sh", <<~SH
// 14:       #!/bin/sh
// 15:       /bin/rm -r "#{appdir}/MyFancyApp.app"
// 16:     SH
// 17:   end
// 18:
// 19:   uninstall script: {
// 20:     executable:   "#{appdir}/MyFancyApp.app/uninstall.sh",
// 21:     sudo:         false,
// 22:     sudo_as_root: false,
// 23:   }
// 24: end
