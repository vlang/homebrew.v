module unpack_strategy

import ruby
import homebrew.unpack_strategy as typed_unpack
import os

// Translated from Homebrew/brew `test/unpack_strategy/dmg_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:path) { TEST_FIXTURE_DIR/"cask/container.dmg" }` at line 8.
pub fn ruby_dmg_spec_l8_d1_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(spec_dmg_fixture())
}

// Ruby specify `specify "#extract" do` at line 12.
pub fn ruby_dmg_spec_l12_d2_extract(args ...ruby.Value) ruby.Value {
	if !spec_tool_available('hdiutil') || !spec_tool_available('ditto') {
		return spec_bool(true)
	}
	path := if args.len > 0 { args[0].as_string() } else { ruby_dmg_spec_l8_d1_path().as_string() }
	return spec_bool(spec_extract(path, .dmg, ['container'], false))
}

// Ruby it `it "does not treat an unrelated attach failure as a license agreement" do` at line 31.
pub fn ruby_dmg_spec_l31_d3_does(args ...ruby.Value) ruby.Value {
	if !spec_tool_available('hdiutil') {
		return spec_bool(true)
	}
	path := os.join_path(spec_temp_dir('invalid-dmg'), 'invalid.dmg')
	spec_write_bytes(path, 'not a disk image'.bytes())
	if _ := typed_unpack.dmg_mount(path, false) {
		return spec_bool(false)
	} else {
		return spec_bool(err.msg().contains('hdiutil attach failed') && !err.msg().to_lower().contains('license agreement'))
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "shared_examples"
// 5:
// 6: RSpec.describe UnpackStrategy::Dmg, :needs_macos do
// 7:   describe "#mount" do
// 8:     let(:path) { TEST_FIXTURE_DIR/"cask/container.dmg" }
// 9:
// 10:     include_examples "UnpackStrategy::detect"
// 11:
// 12:     specify "#extract" do
// 13:       Dir.mktmpdir do |dir|
// 14:         unpack_dir = Pathname(dir)
// 15:         # `Mount` is a private constant on the strategy under test.
// 16:         # rubocop:disable Sorbet/ConstantsFromStrings
// 17:         mount = instance_double(described_class.const_get(:Mount, false))
// 18:         # rubocop:enable Sorbet/ConstantsFromStrings
// 19:         unpack_strategy = described_class.new(path)
// 20:
// 21:         allow(unpack_strategy).to receive(:mount).with(verbose: false).and_yield([mount])
// 22:         allow(mount).to receive(:extract).with(to: unpack_dir, verbose: false) do
// 23:           (unpack_dir/"container").mkpath
// 24:         end
// 25:
// 26:         unpack_strategy.extract(to: unpack_dir)
// 27:         expect(unpack_dir.children(false).map(&:to_s)).to contain_exactly("container")
// 28:       end
// 29:     end
// 30:
// 31:     it "does not treat an unrelated attach failure as a license agreement" do
// 32:       unpack_strategy = described_class.new(path)
// 33:       attach_result = instance_double(SystemCommand::Result, success?: false, stdout: "")
// 34:       attach_error = ErrorDuringExecution.new(["hdiutil", "attach"], status: 1)
// 35:
// 36:       allow(unpack_strategy).to receive(:system_command).and_return(attach_result)
// 37:       expect(attach_result).to receive(:assert_success!).and_raise(attach_error)
// 38:       expect(unpack_strategy).not_to receive(:system_command!)
// 39:
// 40:       expect { unpack_strategy.mount { nil } }.to raise_error(attach_error)
// 41:     end
// 42:   end
// 43: end
