module test

import brew_runtime

// Translated from Homebrew/brew `test/github_releases_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports progress when uploading many bottles" do` at line 8.
pub fn ruby_github_releases_spec_l8_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report progress when uploading fewer than three bottles" do` at line 49.
pub fn ruby_github_releases_spec_l49_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "github_releases"
// 5:
// 6: RSpec.describe GitHubReleases do
// 7:   describe "#upload_bottles" do
// 8:     it "reports progress when uploading many bottles" do
// 9:       events = []
// 10:       bottles_hash = %w[foo bar baz].to_h do |formula_name|
// 11:         [formula_name, {
// 12:           "bottle" => {
// 13:             "root_url" => "https://github.com/homebrew/homebrew-core/releases/download/test",
// 14:             "tags"     => {
// 15:               "arm64"  => {
// 16:                 "filename"       => "#{formula_name}-arm64.bottle.tar.gz",
// 17:                 "local_filename" => "#{formula_name}-arm64.local.bottle.tar.gz",
// 18:               },
// 19:               "x86_64" => {
// 20:                 "filename"       => "#{formula_name}-x86_64.bottle.tar.gz",
// 21:                 "local_filename" => "#{formula_name}-x86_64.local.bottle.tar.gz",
// 22:               },
// 23:             },
// 24:           },
// 25:         }]
// 26:       end
// 27:       allow(GitHub).to receive(:get_release).and_return({ "id" => 123 })
// 28:       allow(GitHub).to receive(:upload_release_asset) do |_, _, _, local_file:, remote_file:|
// 29:         events << "Uploaded #{remote_file} from #{local_file}"
// 30:       end
// 31:       github_releases = described_class.new
// 32:       allow(github_releases).to receive(:ohai) { |message| events << message }
// 33:
// 34:       github_releases.upload_bottles(bottles_hash)
// 35:
// 36:       expect(events).to eq([
// 37:         "Uploaded foo-arm64.bottle.tar.gz from foo-arm64.local.bottle.tar.gz",
// 38:         "Uploaded foo-x86_64.bottle.tar.gz from foo-x86_64.local.bottle.tar.gz",
// 39:         "Upload progress: 1 formula(e) uploaded, 2 remaining",
// 40:         "Uploaded bar-arm64.bottle.tar.gz from bar-arm64.local.bottle.tar.gz",
// 41:         "Uploaded bar-x86_64.bottle.tar.gz from bar-x86_64.local.bottle.tar.gz",
// 42:         "Upload progress: 2 formula(e) uploaded, 1 remaining",
// 43:         "Uploaded baz-arm64.bottle.tar.gz from baz-arm64.local.bottle.tar.gz",
// 44:         "Uploaded baz-x86_64.bottle.tar.gz from baz-x86_64.local.bottle.tar.gz",
// 45:         "Upload progress: 3 formula(e) uploaded, 0 remaining",
// 46:       ])
// 47:     end
// 48:
// 49:     it "does not report progress when uploading fewer than three bottles" do
// 50:       events = []
// 51:       bottles_hash = %w[foo bar].to_h do |formula_name|
// 52:         [formula_name, {
// 53:           "bottle" => {
// 54:             "root_url" => "https://github.com/homebrew/homebrew-core/releases/download/test",
// 55:             "tags"     => {
// 56:               "arm64" => {
// 57:                 "filename"       => "#{formula_name}-arm64.bottle.tar.gz",
// 58:                 "local_filename" => "#{formula_name}-arm64.local.bottle.tar.gz",
// 59:               },
// 60:             },
// 61:           },
// 62:         }]
// 63:       end
// 64:       allow(GitHub).to receive(:get_release).and_return({ "id" => 123 })
// 65:       allow(GitHub).to receive(:upload_release_asset) do |_, _, _, local_file:, remote_file:|
// 66:         events << "Uploaded #{remote_file} from #{local_file}"
// 67:       end
// 68:       github_releases = described_class.new
// 69:       allow(github_releases).to receive(:ohai) { |message| events << message }
// 70:
// 71:       github_releases.upload_bottles(bottles_hash)
// 72:
// 73:       expect(events).to eq([
// 74:         "Uploaded foo-arm64.bottle.tar.gz from foo-arm64.local.bottle.tar.gz",
// 75:         "Uploaded bar-arm64.bottle.tar.gz from bar-arm64.local.bottle.tar.gz",
// 76:       ])
// 77:     end
// 78:   end
// 79: end
