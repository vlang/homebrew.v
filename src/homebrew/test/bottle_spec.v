module test

import brew_runtime

// Translated from Homebrew/brew `test/bottle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "renders the bottle filename" do` at line 9.
pub fn ruby_bottle_spec_l9_d1_renders(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('renders', ...args)
}

// Ruby it `it "trusts cached immutable GitHub Packages bottle blobs matching the expected checksum" do` at line 20.
pub fn ruby_bottle_spec_l20_d2_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby method `cached_bottle(checksum, content)` at line 42.
pub fn ruby_bottle_spec_l42_d3_cached_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_bottle', ...args)
}

// Ruby it `it "downloads a corrupt cached bottle again and extracts it", :aggregate_failures do` at line 53.
pub fn ruby_bottle_spec_l53_d4_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloads', ...args)
}

// Ruby it `it "keeps a cached bottle matching its checksum that fails to extract", :aggregate_failures do` at line 72.
pub fn ruby_bottle_spec_l72_d5_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby method `bottle_domain = "https://mirror.example.com/homebrew-bottles"` at line 87.
pub fn ruby_bottle_spec_l87_d6_bottle_domain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_domain', ...args)
}

// Ruby method `test_bottle(root_url = bottle_domain)` at line 90.
pub fn ruby_bottle_spec_l90_d7_test_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_bottle', ...args)
}

// Ruby it `it "falls back to GHCR for a custom bottle domain" do` at line 105.
pub fn ruby_bottle_spec_l105_d8_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "keeps the bottle mirror when neither manifest URL is available", :aggregate_failures do` at line 117.
pub fn ruby_bottle_spec_l117_d9_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "does not create a manifest resource for an unrelated flat bottle domain" do` at line 129.
pub fn ruby_bottle_spec_l129_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reads the supplement from a valid bottle manifest" do` at line 137.
pub fn ruby_bottle_spec_l137_d11_reads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reads', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bottle_specification"
// 5: require "test/support/fixtures/testball_bottle"
// 6:
// 7: RSpec.describe Bottle do
// 8:   describe "#filename" do
// 9:     it "renders the bottle filename" do
// 10:       bottle_spec = BottleSpecification.new
// 11:       bottle_spec.sha256(arm64_big_sur: "deadbeef" * 8)
// 12:       tag = Utils::Bottles::Tag.from_symbol :arm64_big_sur
// 13:       bottle = described_class.new(TestballBottle.new, bottle_spec, tag)
// 14:
// 15:       expect(bottle.filename.to_s).to eq("testball_bottle--0.1.arm64_big_sur.bottle.tar.gz")
// 16:     end
// 17:   end
// 18:
// 19:   describe "#downloaded_and_valid?" do
// 20:     it "trusts cached immutable GitHub Packages bottle blobs matching the expected checksum" do
// 21:       tag = Utils::Bottles::Tag.from_symbol(:arm64_big_sur)
// 22:       bottle_spec = BottleSpecification.new
// 23:       bottle_spec.root_url(HOMEBREW_BOTTLE_DEFAULT_DOMAIN)
// 24:       bottle_spec.sha256(
// 25:         cellar:        :any_skip_relocation,
// 26:         arm64_big_sur: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 27:       )
// 28:       bottle = described_class.new(nil, bottle_spec, tag,
// 29:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 30:
// 31:       bottle.cached_download.dirname.mkpath
// 32:       bottle.cached_download.write("cached")
// 33:
// 34:       expect(bottle.resource).not_to receive(:verify_download_integrity)
// 35:
// 36:       expect(bottle.downloaded_and_valid?).to be true
// 37:     end
// 38:   end
// 39:
// 40:   describe "#stage_from_download_queue" do
// 41:     sig { params(checksum: String, content: String).returns(Bottle) }
// 42:     def cached_bottle(checksum, content)
// 43:       bottle_spec = BottleSpecification.new
// 44:       bottle_spec.root_url(HOMEBREW_BOTTLE_DEFAULT_DOMAIN)
// 45:       bottle_spec.sha256(cellar: :any_skip_relocation, arm64_big_sur: checksum)
// 46:       bottle = described_class.new(nil, bottle_spec, Utils::Bottles::Tag.from_symbol(:arm64_big_sur),
// 47:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 48:       bottle.cached_download.dirname.mkpath
// 49:       bottle.cached_download.write(content)
// 50:       bottle
// 51:     end
// 52:
// 53:     it "downloads a corrupt cached bottle again and extracts it", :aggregate_failures do
// 54:       bottle = cached_bottle("d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97", "corrupt")
// 55:       unpack_strategy = instance_double(UnpackStrategy::Tar)
// 56:       allow(unpack_strategy).to receive(:extract_nestedly) { bottle.staged_path_from_download_queue.mkpath }
// 57:       extractions = 0
// 58:       allow(UnpackStrategy).to receive(:detect) do
// 59:         extractions += 1
// 60:         raise "gzip decompression failed" if extractions == 1
// 61:
// 62:         unpack_strategy
// 63:       end
// 64:
// 65:       expect(bottle).to receive(:fetch) { bottle.cached_download.write("valid") }
// 66:
// 67:       expect { bottle.stage_from_download_queue(bottle.cached_download, pour: true) }
// 68:         .to output(/Removing corrupt cached download/).to_stderr
// 69:       expect(extractions).to eq(2)
// 70:     end
// 71:
// 72:     it "keeps a cached bottle matching its checksum that fails to extract", :aggregate_failures do
// 73:       content = "valid but unextractable"
// 74:       bottle = cached_bottle(Digest::SHA256.hexdigest(content), content)
// 75:       allow(UnpackStrategy).to receive(:detect).and_raise("gzip decompression failed")
// 76:
// 77:       expect(bottle).not_to receive(:fetch)
// 78:
// 79:       expect { bottle.stage_from_download_queue(bottle.cached_download, pour: true) }
// 80:         .to raise_error(RuntimeError, "gzip decompression failed")
// 81:       expect(bottle.cached_download).to exist
// 82:     end
// 83:   end
// 84:
// 85:   describe "#github_packages_manifest_resource" do
// 86:     sig { returns(String) }
// 87:     def bottle_domain = "https://mirror.example.com/homebrew-bottles"
// 88:
// 89:     sig { params(root_url: String).returns(Bottle) }
// 90:     def test_bottle(root_url = bottle_domain)
// 91:       bottle_spec = BottleSpecification.new
// 92:       bottle_spec.root_url(root_url)
// 93:       bottle_spec.sha256(
// 94:         cellar:            :any_skip_relocation,
// 95:         Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 96:       )
// 97:       described_class.new(nil, bottle_spec, Utils::Bottles.tag,
// 98:                           name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 99:     end
// 100:
// 101:     before do
// 102:       ENV["HOMEBREW_BOTTLE_DOMAIN"] = bottle_domain
// 103:     end
// 104:
// 105:     it "falls back to GHCR for a custom bottle domain" do
// 106:       bottle = test_bottle
// 107:       manifest_resource = bottle.github_packages_manifest_resource
// 108:       downloader = manifest_resource&.downloader
// 109:       raise "Expected a GitHub Packages download strategy" unless downloader.is_a?(CurlGitHubPackagesDownloadStrategy)
// 110:
// 111:       expect([manifest_resource&.url, downloader.mirrors]).to eq([
// 112:         "#{bottle_domain}/foo/manifests/1.2.3",
// 113:         ["#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/foo/manifests/1.2.3"],
// 114:       ])
// 115:     end
// 116:
// 117:     it "keeps the bottle mirror when neither manifest URL is available", :aggregate_failures do
// 118:       bottle = test_bottle
// 119:       manifest_resource = bottle.github_packages_manifest_resource
// 120:       raise "Expected a bottle manifest resource" if manifest_resource.nil?
// 121:
// 122:       allow(manifest_resource).to receive(:fetch)
// 123:         .and_raise(DownloadError.new(manifest_resource, RuntimeError.new("manifest missing")))
// 124:
// 125:       expect { bottle.fetch_tab }.to raise_error(DownloadError)
// 126:       expect(bottle.url).to start_with(bottle_domain)
// 127:     end
// 128:
// 129:     it "does not create a manifest resource for an unrelated flat bottle domain" do
// 130:       bottle = test_bottle("https://example.com/bottles")
// 131:
// 132:       expect(bottle.github_packages_manifest_resource).to be_nil
// 133:     end
// 134:   end
// 135:
// 136:   describe "#sbom_supplement" do
// 137:     it "reads the supplement from a valid bottle manifest" do
// 138:       bottle_spec = BottleSpecification.new
// 139:       bottle_spec.sha256(arm64_big_sur: "deadbeef" * 8)
// 140:       bottle = described_class.new(nil, bottle_spec, Utils::Bottles::Tag.from_symbol(:arm64_big_sur),
// 141:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 142:       supplement = { "packages" => [{ "SPDXID" => "SPDXRef-Compiler" }] }
// 143:       manifest_resource = instance_double(
// 144:         Resource::BottleManifest,
// 145:         downloaded_and_valid?: true,
// 146:         sbom_supplement:       supplement,
// 147:       )
// 148:
// 149:       allow(bottle).to receive(:github_packages_manifest_resource).and_return(manifest_resource)
// 150:
// 151:       expect(bottle.sbom_supplement).to eq(supplement)
// 152:     end
// 153:   end
// 154: end
