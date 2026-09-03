module api

import homebrew.api as brew_api

// Translated from Homebrew/brew `test/api/cask_download_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "preserves rename operations so staging can perform them" do` at line 8.
pub fn ruby_cask_download_spec_l8_d1_preserves() bool {
	download := brew_api.cask_download('test-cask', brew_api.CaskDownloadStruct{
		version: '1.0.0'
		sha256: 'abc123'
		url_args: ['https://example.com/file.zip']
		renames: [brew_api.CaskDownloadRename{ from: 'Test *.pkg', to: 'Test.pkg' }]
	}, [], [], false) or { return false }
	return download.cask.renames == [brew_api.CaskDownloadRename{
		from: 'Test *.pkg'
		to: 'Test.pkg'
	}]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "api/cask_download"
// 5:
// 6: RSpec.describe Homebrew::API::CaskDownload do
// 7:   describe "::download" do
// 8:     it "preserves rename operations so staging can perform them" do
// 9:       cask_struct = Homebrew::API::CaskStruct.from_hash({
// 10:         "sha256"   => "abc123",
// 11:         "version"  => "1.0.0",
// 12:         "url_args" => ["https://example.com/file.zip"],
// 13:         "renames"  => [["Test *.pkg", "Test.pkg"]],
// 14:       })
// 15:
// 16:       download = described_class.download(token: "test-cask", cask_struct:)
// 17:       renames = download&.cask&.rename
// 18:
// 19:       expect(renames&.map(&:pairs)).to eq([{ from: "Test *.pkg", to: "Test.pkg" }])
// 20:     end
// 21:   end
// 22: end
