module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-install-steps.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: cask "with-install-steps" do
// 5:   version "1.2.3"
// 6:   sha256 "67cdb184572d137c3fbd7adc93b707117f0bfb0096684a43f82aa75f924d2c63"
// 7:
// 8:   url "file://#{TEST_FIXTURE_DIR}/cask/container.zip"
// 9:   name "With Install Steps"
// 10:   desc "Cask with structured install steps"
// 11:   homepage "https://brew.sh/with-install-steps"
// 12:
// 13:   app "container"
// 14:
// 15:   preflight_steps do
// 16:     mkdir_p "Prepared"
// 17:     set_permissions "Prepared", "0755"
// 18:     touch "Prepared/touched"
// 19:   end
// 20:
// 21:   postflight_steps do
// 22:     move "move-source", "Prepared/moved"
// 23:     symlink "Prepared/moved", "PreparedLink", source_base: :relative, remove_on_uninstall: true
// 24:   end
// 25:
// 26:   uninstall_preflight_steps do
// 27:     mkdir_p "UninstallPrepared"
// 28:     set_ownership "UninstallPrepared", user: "root", group: "wheel"
// 29:     touch "UninstallPrepared/touched"
// 30:   end
// 31:
// 32:   uninstall_postflight_steps do
// 33:     move_contents "UninstallPrepared", "UninstallMoved"
// 34:   end
// 35: end
