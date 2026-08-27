module bottles

import brew_runtime

// Translated from Homebrew/brew `test/utils/bottles/collector_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:collector) { described_class.new }` at line 7.
pub fn ruby_collector_spec_l7_d1_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collector', ...args)
}

// Ruby let `let(:tahoe) { Utils::Bottles::Tag.from_symbol(:tahoe) }` at line 9.
pub fn ruby_collector_spec_l9_d2_tahoe(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tahoe', ...args)
}

// Ruby let `let(:sequoia) { Utils::Bottles::Tag.from_symbol(:sequoia) }` at line 10.
pub fn ruby_collector_spec_l10_d3_sequoia(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sequoia', ...args)
}

// Ruby let `let(:sonoma) { Utils::Bottles::Tag.from_symbol(:sonoma) }` at line 11.
pub fn ruby_collector_spec_l11_d4_sonoma(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sonoma', ...args)
}

// Ruby it `it "returns passed tags" do` at line 14.
pub fn ruby_collector_spec_l14_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil if empty" do` at line 24.
pub fn ruby_collector_spec_l24_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil when there is no match" do` at line 28.
pub fn ruby_collector_spec_l28_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "uses older tags when needed", :needs_macos do` at line 33.
pub fn ruby_collector_spec_l33_d8_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "does not use older tags when requested not to", :needs_macos do` at line 39.
pub fn ruby_collector_spec_l39_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "ignores HOMEBREW_SKIP_OR_LATER_BOTTLES on release versions", :needs_macos do` at line 47.
pub fn ruby_collector_spec_l47_d10_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/bottles"
// 5:
// 6: RSpec.describe Utils::Bottles::Collector do
// 7:   subject(:collector) { described_class.new }
// 8:
// 9:   let(:tahoe) { Utils::Bottles::Tag.from_symbol(:tahoe) }
// 10:   let(:sequoia) { Utils::Bottles::Tag.from_symbol(:sequoia) }
// 11:   let(:sonoma) { Utils::Bottles::Tag.from_symbol(:sonoma) }
// 12:
// 13:   describe "#specification_for" do
// 14:     it "returns passed tags" do
// 15:       collector.add(sonoma, checksum: Checksum.new("foo_checksum"), cellar: "foo_cellar")
// 16:       collector.add(sequoia, checksum: Checksum.new("bar_checksum"), cellar: "bar_cellar")
// 17:       spec = collector.specification_for(sequoia)
// 18:       expect(spec).not_to be_nil
// 19:       expect(spec.tag).to eq(sequoia)
// 20:       expect(spec.checksum).to eq("bar_checksum")
// 21:       expect(spec.cellar).to eq("bar_cellar")
// 22:     end
// 23:
// 24:     it "returns nil if empty" do
// 25:       expect(collector.specification_for(Utils::Bottles::Tag.from_symbol(:foo))).to be_nil
// 26:     end
// 27:
// 28:     it "returns nil when there is no match" do
// 29:       collector.add(sequoia, checksum: Checksum.new("bar_checksum"), cellar: "bar_cellar")
// 30:       expect(collector.specification_for(Utils::Bottles::Tag.from_symbol(:foo))).to be_nil
// 31:     end
// 32:
// 33:     it "uses older tags when needed", :needs_macos do
// 34:       collector.add(sonoma, checksum: Checksum.new("foo_checksum"), cellar: "foo_cellar")
// 35:       expect(collector.find_matching_tag(sonoma)).to eq(sonoma)
// 36:       expect(collector.find_matching_tag(sequoia)).to eq(sonoma)
// 37:     end
// 38:
// 39:     it "does not use older tags when requested not to", :needs_macos do
// 40:       allow(Homebrew::EnvConfig).to receive_messages(developer?: true, skip_or_later_bottles?: true)
// 41:       allow(OS::Mac.version).to receive(:prerelease?).and_return(true)
// 42:       collector.add(sonoma, checksum: Checksum.new("foo_checksum"), cellar: "foo_cellar")
// 43:       expect(collector.find_matching_tag(sonoma)).to eq(sonoma)
// 44:       expect(collector.find_matching_tag(sequoia)).to be_nil
// 45:     end
// 46:
// 47:     it "ignores HOMEBREW_SKIP_OR_LATER_BOTTLES on release versions", :needs_macos do
// 48:       allow(Homebrew::EnvConfig).to receive(:skip_or_later_bottles?).and_return(true)
// 49:       allow(OS::Mac.version).to receive(:prerelease?).and_return(false)
// 50:       collector.add(sonoma, checksum: Checksum.new("foo_checksum"), cellar: "foo_cellar")
// 51:       expect(collector.find_matching_tag(sonoma)).to eq(sonoma)
// 52:       expect(collector.find_matching_tag(sequoia)).to eq(sonoma)
// 53:     end
// 54:   end
// 55: end
