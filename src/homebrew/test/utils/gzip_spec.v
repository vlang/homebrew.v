module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/gzip_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses the explicitly specified mtime, orig_name and output path when passed" do` at line 10.
pub fn ruby_gzip_spec_l10_d1_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "uses SOURCE_DATE_EPOCH as mtime when not explicitly specified" do` at line 28.
pub fn ruby_gzip_spec_l28_d2_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "creates non-reproducible gz files from input files" do` at line 44.
pub fn ruby_gzip_spec_l44_d3_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates reproducible gz files from input files with explicit mtime" do` at line 57.
pub fn ruby_gzip_spec_l57_d4_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Ruby it `it "creates reproducible gz files from input files with SOURCE_DATE_EPOCH as mtime" do` at line 77.
pub fn ruby_gzip_spec_l77_d5_creates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('creates', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/gzip"
// 5:
// 6: RSpec.describe Utils::Gzip do
// 7:   include FileUtils
// 8:
// 9:   describe "compress_with_options" do
// 10:     it "uses the explicitly specified mtime, orig_name and output path when passed" do
// 11:       mktmpdir do |path|
// 12:         mtime = Time.at(12345).utc
// 13:         orig_name = "someotherfile"
// 14:         output = path/"subdir/anotherfile.gz"
// 15:         file_content = "Hello world"
// 16:         expected_checksum = "df509051b519faa8a1143157d2750d1694dc5fe6373e493c0d5c360be3e61516"
// 17:
// 18:         somefile = path/"somefile"
// 19:         File.write(somefile, file_content)
// 20:         mkdir path/"subdir"
// 21:
// 22:         expect(described_class.compress_with_options(somefile, mtime:, orig_name:,
// 23: output:)).to eq(output)
// 24:         expect(Digest::SHA256.hexdigest(File.read(output))).to eq(expected_checksum)
// 25:       end
// 26:     end
// 27:
// 28:     it "uses SOURCE_DATE_EPOCH as mtime when not explicitly specified" do
// 29:       mktmpdir do |path|
// 30:         ENV["SOURCE_DATE_EPOCH"] = "23456"
// 31:         file_content = "Hello world"
// 32:         expected_checksum = "a579be88ec8073391a5753b1df4d87fbf008aaec6b5a03f8f16412e2e01f119a"
// 33:
// 34:         somefile = path/"somefile"
// 35:         File.write(somefile, file_content)
// 36:
// 37:         expect(described_class.compress_with_options(somefile).to_s).to eq("#{somefile}.gz")
// 38:         expect(Digest::SHA256.hexdigest(File.read("#{somefile}.gz"))).to eq(expected_checksum)
// 39:       end
// 40:     end
// 41:   end
// 42:
// 43:   describe "compress" do
// 44:     it "creates non-reproducible gz files from input files" do
// 45:       mktmpdir do |path|
// 46:         files = (0..2).map { |n| path/"somefile#{n}" }
// 47:         FileUtils.touch files
// 48:
// 49:         results = described_class.compress(*files, reproducible: false)
// 50:         3.times do |n|
// 51:           expect(results[n].to_s).to eq("#{files[n]}.gz")
// 52:           expect(Pathname.new("#{files[n]}.gz")).to exist
// 53:         end
// 54:       end
// 55:     end
// 56:
// 57:     it "creates reproducible gz files from input files with explicit mtime" do
// 58:       mtime = Time.at(12345).utc
// 59:       expected_checksums = %w[
// 60:         5b45cabc7f0192854365aeccd82036e482e35131ba39fbbc6d0684266eb2e88a
// 61:         d422bf4cbede17ae242135d7f32ba5379fbffb288c29cd38b7e5e1a5f89073f8
// 62:         1d93a3808e2bd5d8c6371ea1c9b8b538774d6486af260719400fc3a5b7ac8d6f
// 63:       ]
// 64:
// 65:       mktmpdir do |path|
// 66:         files = (0..2).map { |n| path/"somefile#{n}" }
// 67:         files.each { |f| File.write(f, "Hello world") }
// 68:
// 69:         results = described_class.compress(*files, mtime:)
// 70:         3.times do |n|
// 71:           expect(results[n].to_s).to eq("#{files[n]}.gz")
// 72:           expect(Digest::SHA256.hexdigest(File.read(results[n]))).to eq(expected_checksums[n])
// 73:         end
// 74:       end
// 75:     end
// 76:
// 77:     it "creates reproducible gz files from input files with SOURCE_DATE_EPOCH as mtime" do
// 78:       ENV["SOURCE_DATE_EPOCH"] = "23456"
// 79:       expected_checksums = %w[
// 80:         d5e0cc3259b1eb61d93ee5a30d41aef4a382c1cf2b759719c289f625e27b915c
// 81:         068657725bca5f9c2bc62bc6bf679eb63786e92d16cae575dee2fd9787a338f3
// 82:         e566e9fdaf9aa2a7c9501f9845fed1b70669bfa679b0de609e3b63f99988784d
// 83:       ]
// 84:
// 85:       mktmpdir do |path|
// 86:         files = (0..2).map { |n| path/"somefile#{n}" }
// 87:         files.each { |f| File.write(f, "Hello world") }
// 88:
// 89:         results = described_class.compress(*files)
// 90:         3.times do |n|
// 91:           expect(results[n].to_s).to eq("#{files[n]}.gz")
// 92:           expect(Digest::SHA256.hexdigest(File.read(results[n]))).to eq(expected_checksums[n])
// 93:         end
// 94:       end
// 95:     end
// 96:   end
// 97: end
