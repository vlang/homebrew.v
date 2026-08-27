module test

import brew_runtime

// Translated from Homebrew/brew `test/PATH_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "can take multiple arguments" do` at line 8.
pub fn ruby_path_spec_l8_d1_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can parse a mix of arrays and arguments" do` at line 12.
pub fn ruby_path_spec_l12_d2_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "splits an existing PATH" do` at line 16.
pub fn ruby_path_spec_l16_d3_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "removes duplicates" do` at line 20.
pub fn ruby_path_spec_l20_d4_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "returns a PATH array" do` at line 26.
pub fn ruby_path_spec_l26_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "does not allow mutating the original" do` at line 30.
pub fn ruby_path_spec_l30_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "returns a PATH string" do` at line 39.
pub fn ruby_path_spec_l39_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 45.
pub fn ruby_path_spec_l45_d8_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 52.
pub fn ruby_path_spec_l52_d9_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 59.
pub fn ruby_path_spec_l59_d10_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby it `it "always returns false when comparing against something which does not respond to `#to_ary` or `#to_str`" do` at line 66.
pub fn ruby_path_spec_l66_d11_always(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('always', ...args)
}

// Ruby it `it "returns true if a path is included", :aggregate_failures do` at line 72.
pub fn ruby_path_spec_l72_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false if a path is not included" do` at line 79.
pub fn ruby_path_spec_l79_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "loops through each path" do` at line 85.
pub fn ruby_path_spec_l85_d14_loops(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loops', ...args)
}

// Ruby it `it "returns an object of the same class instead of an Array" do` at line 94.
pub fn ruby_path_spec_l94_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an object of the same class instead of an Array" do` at line 100.
pub fn ruby_path_spec_l100_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a new PATH without non-existent paths", :aggregate_failures do` at line 106.
pub fn ruby_path_spec_l106_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil instead of an empty` at line 117.
pub fn ruby_path_spec_l117_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "PATH"
// 5:
// 6: RSpec.describe PATH do
// 7:   describe "#initialize" do
// 8:     it "can take multiple arguments" do
// 9:       expect(described_class.new("/path1", "/path2")).to eq("/path1:/path2")
// 10:     end
// 11:
// 12:     it "can parse a mix of arrays and arguments" do
// 13:       expect(described_class.new(["/path1", "/path2"], "/path3")).to eq("/path1:/path2:/path3")
// 14:     end
// 15:
// 16:     it "splits an existing PATH" do
// 17:       expect(described_class.new("/path1:/path2")).to eq(["/path1", "/path2"])
// 18:     end
// 19:
// 20:     it "removes duplicates" do
// 21:       expect(described_class.new("/path1", "/path1")).to eq("/path1")
// 22:     end
// 23:   end
// 24:
// 25:   describe "#to_ary" do
// 26:     it "returns a PATH array" do
// 27:       expect(described_class.new("/path1", "/path2").to_ary).to eq(["/path1", "/path2"])
// 28:     end
// 29:
// 30:     it "does not allow mutating the original" do
// 31:       path = described_class.new("/path1", "/path2")
// 32:       path.to_ary << "/path3"
// 33:
// 34:       expect(path).not_to include("/path3")
// 35:     end
// 36:   end
// 37:
// 38:   describe "#to_str" do
// 39:     it "returns a PATH string" do
// 40:       expect(described_class.new("/path1", "/path2").to_str).to eq("/path1:/path2")
// 41:     end
// 42:   end
// 43:
// 44:   describe "#prepend" do
// 45:     specify(:aggregate_failures) do
// 46:       expect(described_class.new("/path1").prepend("/path2").to_str).to eq("/path2:/path1")
// 47:       expect(described_class.new("/path1").prepend("/path1").to_str).to eq("/path1")
// 48:     end
// 49:   end
// 50:
// 51:   describe "#append" do
// 52:     specify(:aggregate_failures) do
// 53:       expect(described_class.new("/path1").append("/path2").to_str).to eq("/path1:/path2")
// 54:       expect(described_class.new("/path1").append("/path1").to_str).to eq("/path1")
// 55:     end
// 56:   end
// 57:
// 58:   describe "#insert" do
// 59:     specify(:aggregate_failures) do
// 60:       expect(described_class.new("/path1").insert(0, "/path2").to_str).to eq("/path2:/path1")
// 61:       expect(described_class.new("/path1").insert(0, "/path2", "/path3")).to eq("/path2:/path3:/path1")
// 62:     end
// 63:   end
// 64:
// 65:   describe "#==" do
// 66:     it "always returns false when comparing against something which does not respond to `#to_ary` or `#to_str`" do
// 67:       expect(described_class.new).not_to eq Object.new
// 68:     end
// 69:   end
// 70:
// 71:   describe "#include?" do
// 72:     it "returns true if a path is included", :aggregate_failures do
// 73:       path = described_class.new("/path1", "/path2")
// 74:       expect(path).to include("/path1")
// 75:       expect(path).to include("/path2")
// 76:       expect(described_class.new("/path1", "/path2")).not_to include("/path1:")
// 77:     end
// 78:
// 79:     it "returns false if a path is not included" do
// 80:       expect(described_class.new("/path1")).not_to include("/path2")
// 81:     end
// 82:   end
// 83:
// 84:   describe "#each" do
// 85:     it "loops through each path" do
// 86:       enum = described_class.new("/path1", "/path2").each
// 87:
// 88:       expect(enum.next).to eq("/path1")
// 89:       expect(enum.next).to eq("/path2")
// 90:     end
// 91:   end
// 92:
// 93:   describe "#select" do
// 94:     it "returns an object of the same class instead of an Array" do
// 95:       expect(described_class.new.select { true }).to be_a(described_class)
// 96:     end
// 97:   end
// 98:
// 99:   describe "#reject" do
// 100:     it "returns an object of the same class instead of an Array" do
// 101:       expect(described_class.new.reject { true }).to be_a(described_class)
// 102:     end
// 103:   end
// 104:
// 105:   describe "#existing" do
// 106:     it "returns a new PATH without non-existent paths", :aggregate_failures do
// 107:       allow(File).to receive(:directory?).with("/path1").and_return(true)
// 108:       allow(File).to receive(:directory?).with("/path2").and_return(false)
// 109:
// 110:       path = described_class.new("/path1", "/path2")
// 111:       existing = path.existing
// 112:       expect(existing).not_to be_nil
// 113:       expect(existing&.to_ary).to eq(["/path1"])
// 114:       expect(path.to_ary).to eq(["/path1", "/path2"])
// 115:     end
// 116:
// 117:     it "returns nil instead of an empty #{described_class}" do
// 118:       expect(described_class.new.existing).to be_nil
// 119:     end
// 120:   end
// 121: end
