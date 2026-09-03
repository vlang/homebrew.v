module test

import homebrew

// Translated from Homebrew/brew `test/bottle_specification_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:bottle_spec) { described_class.new }` at line 7.
pub fn ruby_bottle_specification_spec_l7_d1_bottle_spec() homebrew.BottleSpecification {
	return homebrew.new_bottle_specification()
}

fn bottle_specification_spec_add(mut specification homebrew.BottleSpecification, tag string,
	digest string, cellar ?homebrew.BottleCellar) !homebrew.BottleTagSpecification {
	specification.sha256(tag, digest, cellar)!
	typed_tag := homebrew.bottle_tag_from_symbol(tag)!
	return specification.tag_specification_for(typed_tag, false) or {
		return error('missing bottle tag specification for ${tag}')
	}
}

fn bottle_specification_spec_skip(cellar homebrew.BottleCellar, linux bool,
	homebrew_version string) !bool {
	mut specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	tag := homebrew.current_bottle_tag()
	specification.sha256(tag.symbol(), ruby_bottle_specification_spec_l58_d7_digest(), cellar)!
	return specification.skip_relocation(tag, homebrew.BottleLocationContext{
		linux: linux
		tab_homebrew_version: homebrew_version
	})
}

// Ruby it `it "works without cellar" do` at line 10.
pub fn ruby_bottle_specification_spec_l10_d2_works() !bool {
	mut specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	checksums := {
		'arm64_tahoe': 'deadbeef'.repeat(8)
		'tahoe':       'faceb00c'.repeat(8)
		'sequoia':     'baadf00d'.repeat(8)
		'sonoma':      '8badf00d'.repeat(8)
	}
	for tag, digest in checksums {
		tag_specification := bottle_specification_spec_add(mut specification, tag, digest, none)!
		if tag_specification.checksum.hexdigest != digest {
			return false
		}
	}
	return true
}

// Ruby it `it "works with cellar" do` at line 25.
pub fn ruby_bottle_specification_spec_l25_d3_works() !bool {
	mut specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	entries := [
		['arm64_tahoe', 'deadbeef'.repeat(8), 'any_skip_relocation'],
		['tahoe', 'faceb00c'.repeat(8), 'any'],
		['sequoia', 'baadf00d'.repeat(8), '/usr/local/Cellar'],
		['sonoma', '8badf00d'.repeat(8), '/opt/homebrew/Cellar'],
	]
	for entry in entries {
		cellar := homebrew.parse_bottle_cellar(entry[2])
		tag_specification := bottle_specification_spec_add(mut specification, entry[0], entry[1], cellar)!
		if tag_specification.checksum.hexdigest != entry[1] || tag_specification.tag.symbol() != entry[0] || !tag_specification.cellar.equals(cellar) {
			return false
		}
	}
	return true
}

// Ruby it `it "checks if the bottle cellar is relocatable" do` at line 45.
pub fn ruby_bottle_specification_spec_l45_d4_checks() bool {
	specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	return !specification.compatible_locations(homebrew.current_bottle_tag(), homebrew.BottleLocationContext{
		prefix: '/different-prefix'
		cellar: '/different-prefix/Cellar'
	})
}

// Ruby it `it "returns the cellar for a tag" do` at line 51.
pub fn ruby_bottle_specification_spec_l51_d5_returns() bool {
	tag := homebrew.current_bottle_tag()
	return ruby_bottle_specification_spec_l7_d1_bottle_spec().tag_to_cellar(tag).equals(tag.default_cellar())
}

// Ruby let `let(:tag) { Utils::Bottles.tag.to_sym }` at line 57.
pub fn ruby_bottle_specification_spec_l57_d6_tag() string {
	return homebrew.current_bottle_tag().symbol()
}

// Ruby let `let(:digest) { "deadbeef" * 8 }` at line 58.
pub fn ruby_bottle_specification_spec_l58_d7_digest() string {
	return 'deadbeef'.repeat(8)
}

// Ruby it `it "returns false when there is no matching spec" do` at line 60.
pub fn ruby_bottle_specification_spec_l60_d8_returns() bool {
	return !ruby_bottle_specification_spec_l7_d1_bottle_spec().skip_relocation(homebrew.current_bottle_tag(), homebrew.BottleLocationContext{})
}

// Ruby let `let(:tab) { Tab.new(homebrew_version: "5.1.15") }` at line 66.
pub fn ruby_bottle_specification_spec_l66_d9_tab() string {
	return '5.1.15'
}

// Ruby it `it "returns true for `:any_skip_relocation` cellar" do` at line 68.
pub fn ruby_bottle_specification_spec_l68_d10_returns() !bool {
	return bottle_specification_spec_skip(homebrew.bottle_cellar_any_skip_relocation(), true, ruby_bottle_specification_spec_l66_d9_tab())
}

// Ruby it `it "returns false for `:any` cellar" do` at line 73.
pub fn ruby_bottle_specification_spec_l73_d11_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any(), true, ruby_bottle_specification_spec_l66_d9_tab())!
}

// Ruby let `let(:tab) { Tab.new(homebrew_version: "5.1.14") }` at line 80.
pub fn ruby_bottle_specification_spec_l80_d12_tab() string {
	return '5.1.14'
}

// Ruby it `it "returns false for `:any_skip_relocation` cellar" do` at line 82.
pub fn ruby_bottle_specification_spec_l82_d13_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any_skip_relocation(), true, ruby_bottle_specification_spec_l80_d12_tab())!
}

// Ruby it `it "returns false for `:any` cellar" do` at line 87.
pub fn ruby_bottle_specification_spec_l87_d14_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any(), true, ruby_bottle_specification_spec_l80_d12_tab())!
}

// Ruby it `it "returns false for `:any_skip_relocation` cellar" do` at line 94.
pub fn ruby_bottle_specification_spec_l94_d15_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any_skip_relocation(), true, '')!
}

// Ruby it `it "returns false for `:any` cellar" do` at line 99.
pub fn ruby_bottle_specification_spec_l99_d16_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any(), true, '')!
}

// Ruby it `it "returns true for `:any_skip_relocation` cellar" do` at line 107.
pub fn ruby_bottle_specification_spec_l107_d17_returns() !bool {
	return bottle_specification_spec_skip(homebrew.bottle_cellar_any_skip_relocation(), false, '')
}

// Ruby it `it "returns false for `:any` cellar" do` at line 112.
pub fn ruby_bottle_specification_spec_l112_d18_returns() !bool {
	return !bottle_specification_spec_skip(homebrew.bottle_cellar_any(), false, '')!
}

// Ruby specify `specify "#rebuild" do` at line 119.
pub fn ruby_bottle_specification_spec_l119_d19_rebuild() bool {
	mut specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	specification.set_rebuild(1337)
	return specification.rebuild() == 1337
}

// Ruby specify `specify "#root_url" do` at line 124.
pub fn ruby_bottle_specification_spec_l124_d20_root_url() bool {
	mut specification := ruby_bottle_specification_spec_l7_d1_bottle_spec()
	specification.set_root_url('https://example.com', {})
	return specification.root_url() == 'https://example.com'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bottle_specification"
// 5:
// 6: RSpec.describe BottleSpecification do
// 7:   subject(:bottle_spec) { described_class.new }
// 8:
// 9:   describe "#sha256" do
// 10:     it "works without cellar" do
// 11:       checksums = {
// 12:         arm64_tahoe: "deadbeef" * 8,
// 13:         tahoe:       "faceb00c" * 8,
// 14:         sequoia:     "baadf00d" * 8,
// 15:         sonoma:      "8badf00d" * 8,
// 16:       }
// 17:
// 18:       checksums.each_pair do |cat, digest|
// 19:         bottle_spec.sha256(cat => digest)
// 20:         tag_spec = bottle_spec.tag_specification_for(Utils::Bottles::Tag.from_symbol(cat))
// 21:         expect(Checksum.new(digest)).to eq(tag_spec.checksum)
// 22:       end
// 23:     end
// 24:
// 25:     it "works with cellar" do
// 26:       checksums = [
// 27:         { cellar: :any_skip_relocation, tag: :arm64_tahoe, digest: "deadbeef" * 8 },
// 28:         { cellar: :any, tag: :tahoe, digest: "faceb00c" * 8 },
// 29:         { cellar: "/usr/local/Cellar", tag: :sequoia, digest: "baadf00d" * 8 },
// 30:         { cellar: Homebrew::DEFAULT_CELLAR, tag: :sonoma, digest: "8badf00d" * 8 },
// 31:       ]
// 32:
// 33:       checksums.each do |checksum|
// 34:         bottle_spec.sha256(cellar: checksum[:cellar], checksum[:tag] => checksum[:digest])
// 35:         tag_spec = bottle_spec.tag_specification_for(Utils::Bottles::Tag.from_symbol(checksum[:tag]))
// 36:         expect(Checksum.new(checksum[:digest])).to eq(tag_spec.checksum)
// 37:         expect(checksum[:tag]).to eq(tag_spec.tag.to_sym)
// 38:         checksum[:cellar] ||= Homebrew::DEFAULT_CELLAR
// 39:         expect(checksum[:cellar]).to eq(tag_spec.cellar)
// 40:       end
// 41:     end
// 42:   end
// 43:
// 44:   describe "#compatible_locations?" do
// 45:     it "checks if the bottle cellar is relocatable" do
// 46:       expect(bottle_spec.compatible_locations?).to be false
// 47:     end
// 48:   end
// 49:
// 50:   describe "#tag_to_cellar" do
// 51:     it "returns the cellar for a tag" do
// 52:       expect(bottle_spec.tag_to_cellar).to eq Utils::Bottles.tag.default_cellar
// 53:     end
// 54:   end
// 55:
// 56:   describe "#skip_relocation?" do
// 57:     let(:tag) { Utils::Bottles.tag.to_sym }
// 58:     let(:digest) { "deadbeef" * 8 }
// 59:
// 60:     it "returns false when there is no matching spec" do
// 61:       expect(bottle_spec.skip_relocation?).to be false
// 62:     end
// 63:
// 64:     context "when running on Linux", :needs_linux do
// 65:       context "with bottle built on Homebrew 5.1.15" do
// 66:         let(:tab) { Tab.new(homebrew_version: "5.1.15") }
// 67:
// 68:         it "returns true for `:any_skip_relocation` cellar" do
// 69:           bottle_spec.sha256(cellar: :any_skip_relocation, tag => digest)
// 70:           expect(bottle_spec.skip_relocation?(tab:)).to be true
// 71:         end
// 72:
// 73:         it "returns false for `:any` cellar" do
// 74:           bottle_spec.sha256(cellar: :any, tag => digest)
// 75:           expect(bottle_spec.skip_relocation?(tab:)).to be false
// 76:         end
// 77:       end
// 78:
// 79:       context "with bottle built on Homebrew 5.1.14" do
// 80:         let(:tab) { Tab.new(homebrew_version: "5.1.14") }
// 81:
// 82:         it "returns false for `:any_skip_relocation` cellar" do
// 83:           bottle_spec.sha256(cellar: :any_skip_relocation, tag => digest)
// 84:           expect(bottle_spec.skip_relocation?(tab:)).to be false
// 85:         end
// 86:
// 87:         it "returns false for `:any` cellar" do
// 88:           bottle_spec.sha256(cellar: :any, tag => digest)
// 89:           expect(bottle_spec.skip_relocation?(tab:)).to be false
// 90:         end
// 91:       end
// 92:
// 93:       context "without tab" do
// 94:         it "returns false for `:any_skip_relocation` cellar" do
// 95:           bottle_spec.sha256(cellar: :any_skip_relocation, tag => digest)
// 96:           expect(bottle_spec.skip_relocation?).to be false
// 97:         end
// 98:
// 99:         it "returns false for `:any` cellar" do
// 100:           bottle_spec.sha256(cellar: :any, tag => digest)
// 101:           expect(bottle_spec.skip_relocation?).to be false
// 102:         end
// 103:       end
// 104:     end
// 105:
// 106:     context "when running on macOS", :needs_macos do
// 107:       it "returns true for `:any_skip_relocation` cellar" do
// 108:         bottle_spec.sha256(cellar: :any_skip_relocation, tag => digest)
// 109:         expect(bottle_spec.skip_relocation?).to be true
// 110:       end
// 111:
// 112:       it "returns false for `:any` cellar" do
// 113:         bottle_spec.sha256(cellar: :any, tag => digest)
// 114:         expect(bottle_spec.skip_relocation?).to be false
// 115:       end
// 116:     end
// 117:   end
// 118:
// 119:   specify "#rebuild" do
// 120:     bottle_spec.rebuild(1337)
// 121:     expect(bottle_spec.rebuild).to eq(1337)
// 122:   end
// 123:
// 124:   specify "#root_url" do
// 125:     bottle_spec.root_url("https://example.com")
// 126:     expect(bottle_spec.root_url).to eq("https://example.com")
// 127:   end
// 128: end
