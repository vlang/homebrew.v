module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/many-artifacts.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "many-artifacts" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/ManyArtifacts.zip"
// 8:   homepage "https://brew.sh/many-artifacts"
// 9:
// 10:   app "ManyArtifacts/ManyArtifacts.app"
// 11:   pkg "ManyArtifacts/ManyArtifacts.pkg"
// 12:
// 13:   preflight do
// 14:     # do nothing
// 15:   end
// 16:
// 17:   postflight do
// 18:     # do nothing
// 19:   end
// 20:
// 21:   uninstall_preflight do
// 22:     # do nothing
// 23:   end
// 24:
// 25:   uninstall_postflight do
// 26:     # do nothing
// 27:   end
// 28:
// 29:   uninstall trash: ["#{TEST_TMPDIR}/foo", "#{TEST_TMPDIR}/bar"],
// 30:             rmdir: "#{TEST_TMPDIR}/empty_directory_path"
// 31:
// 32:   zap trash: "~/Library/Logs/ManyArtifacts.log",
// 33:       rmdir: ["~/Library/Caches/ManyArtifacts", "~/Library/Application Support/ManyArtifacts"]
// 34: end
