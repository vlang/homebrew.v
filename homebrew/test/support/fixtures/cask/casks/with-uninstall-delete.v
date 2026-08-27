module casks

// Translated from Homebrew/brew `test/support/fixtures/cask/Casks/with-uninstall-delete.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2:
// 3: cask "with-uninstall-delete" do
// 4:   version "1.2.3"
// 5:   sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 6:
// 7:   url "file://#{TEST_FIXTURE_DIR}/cask/MyFancyPkg.zip"
// 8:   homepage "https://brew.sh/fancy-pkg"
// 9:
// 10:   pkg "Fancy.pkg"
// 11:
// 12:   uninstall delete: [
// 13:     "#{TEST_TMPDIR}/absolute_path",
// 14:     "#{TEST_TMPDIR}/glob_path*",
// 15:     "/another/impermissible/../relative/path",
// 16:     "impermissible/relative/path",
// 17:     "~/path_with_tilde",
// 18:   ]
// 19: end
