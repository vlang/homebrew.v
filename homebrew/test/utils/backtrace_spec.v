module utils

import brew_runtime
import homebrew.utils as production_utils

// Translated from Homebrew/brew `test/utils/backtrace_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:backtrace_no_sorbet_paths) do` at line 7.
pub fn ruby_backtrace_spec_l7_d1_backtrace_no_sorbet_paths(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(backtrace_spec_without_sorbet())
}

// Ruby let `let(:backtrace_with_sorbet_paths) do` at line 24.
pub fn ruby_backtrace_spec_l24_d2_backtrace_with_sorbet_paths(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(backtrace_spec_with_sorbet())
}

// Ruby let `let(:backtrace_with_sorbet_error) do` at line 50.
pub fn ruby_backtrace_spec_l50_d3_backtrace_with_sorbet_error(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(backtrace_spec_with_sorbet()[1..])
}

// Ruby method `exception_with(backtrace:)` at line 54.
pub fn ruby_backtrace_spec_l54_d4_exception_with(args ...brew_runtime.Value) brew_runtime.Value {
	backtrace := if args.len > 0 { args[0] } else { brew_runtime.object_value('NilClass', '') }
	return brew_runtime.map_value({
		'backtrace': backtrace
	})
}

// Ruby it `it "handles nil backtrace" do` at line 66.
pub fn ruby_backtrace_spec_l66_d5_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_utils.clean_backtrace(false, []string{}, false, backtrace_spec_sorbet_path)
	return brew_runtime.bool_value(!result.has_backtrace)
}

// Ruby it `it "handles empty array backtrace" do` at line 71.
pub fn ruby_backtrace_spec_l71_d6_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_utils.clean_backtrace(true, []string{}, false, backtrace_spec_sorbet_path)
	return brew_runtime.bool_value(result.has_backtrace && result.backtrace.len == 0)
}

// Ruby it `it "removes sorbet paths when top error is not from sorbet" do` at line 76.
pub fn ruby_backtrace_spec_l76_d7_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_utils.clean_backtrace(true, backtrace_spec_with_sorbet(), false, backtrace_spec_sorbet_path)
	return brew_runtime.bool_value(result.backtrace == backtrace_spec_without_sorbet()
		&& result.removed_sorbet_lines)
}

// Ruby it `it "includes sorbet paths when top error is not from sorbet and verbose is set" do` at line 81.
pub fn ruby_backtrace_spec_l81_d8_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	with_sorbet := backtrace_spec_with_sorbet()
	result := production_utils.clean_backtrace(true, with_sorbet, true, backtrace_spec_sorbet_path)
	return brew_runtime.bool_value(result.backtrace == with_sorbet && !result.removed_sorbet_lines)
}

// Ruby it `it "doesn't change backtrace when error is from sorbet" do` at line 87.
pub fn ruby_backtrace_spec_l87_d9_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	sorbet_error := backtrace_spec_with_sorbet()[1..]
	result := production_utils.clean_backtrace(true, sorbet_error, false, backtrace_spec_sorbet_path)
	return brew_runtime.bool_value(result.backtrace == sorbet_error && !result.removed_sorbet_lines)
}

const backtrace_spec_sorbet_path = '/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime'

fn backtrace_spec_without_sorbet() []string {
	return [
		'/Library/Homebrew/downloadable.rb:75:in',
		'/Library/Homebrew/downloadable.rb:50:in',
		'/Library/Homebrew/cmd/fetch.rb:236:in',
		'/Library/Homebrew/cmd/fetch.rb:201:in',
		'/Library/Homebrew/cmd/fetch.rb:178:in',
		'/Library/Homebrew/simulate_system.rb:29:in',
		'/Library/Homebrew/cmd/fetch.rb:166:in',
		'/Library/Homebrew/cmd/fetch.rb:163:in',
		'/Library/Homebrew/cmd/fetch.rb:163:in',
		'/Library/Homebrew/cmd/fetch.rb:94:in',
		'/Library/Homebrew/cmd/fetch.rb:94:in',
		'/Library/Homebrew/brew.rb:94:in',
	]
}

fn backtrace_spec_with_sorbet() []string {
	sorbet_call := '${backtrace_spec_sorbet_path}-0.5.10461/lib/call_validation.rb:157:in'
	sorbet_methods := '${backtrace_spec_sorbet_path}-0.5.10461/lib/_methods.rb:270:in'
	return [
		'/Library/Homebrew/downloadable.rb:75:in',
		sorbet_call,
		sorbet_call,
		sorbet_methods,
		'/Library/Homebrew/downloadable.rb:50:in',
		sorbet_call,
		sorbet_call,
		sorbet_methods,
		'/Library/Homebrew/cmd/fetch.rb:236:in',
		'/Library/Homebrew/cmd/fetch.rb:201:in',
		'/Library/Homebrew/cmd/fetch.rb:178:in',
		'/Library/Homebrew/simulate_system.rb:29:in',
		sorbet_call,
		sorbet_call,
		sorbet_methods,
		'/Library/Homebrew/cmd/fetch.rb:166:in',
		'/Library/Homebrew/cmd/fetch.rb:163:in',
		'/Library/Homebrew/cmd/fetch.rb:163:in',
		'/Library/Homebrew/cmd/fetch.rb:94:in',
		'/Library/Homebrew/cmd/fetch.rb:94:in',
		'/Library/Homebrew/brew.rb:94:in',
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/backtrace"
// 5:
// 6: RSpec.describe Utils::Backtrace do
// 7:   let(:backtrace_no_sorbet_paths) do
// 8:     [
// 9:       "/Library/Homebrew/downloadable.rb:75:in",
// 10:       "/Library/Homebrew/downloadable.rb:50:in",
// 11:       "/Library/Homebrew/cmd/fetch.rb:236:in",
// 12:       "/Library/Homebrew/cmd/fetch.rb:201:in",
// 13:       "/Library/Homebrew/cmd/fetch.rb:178:in",
// 14:       "/Library/Homebrew/simulate_system.rb:29:in",
// 15:       "/Library/Homebrew/cmd/fetch.rb:166:in",
// 16:       "/Library/Homebrew/cmd/fetch.rb:163:in",
// 17:       "/Library/Homebrew/cmd/fetch.rb:163:in",
// 18:       "/Library/Homebrew/cmd/fetch.rb:94:in",
// 19:       "/Library/Homebrew/cmd/fetch.rb:94:in",
// 20:       "/Library/Homebrew/brew.rb:94:in",
// 21:     ]
// 22:   end
// 23:
// 24:   let(:backtrace_with_sorbet_paths) do
// 25:     [
// 26:       "/Library/Homebrew/downloadable.rb:75:in",
// 27:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 28:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 29:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/_methods.rb:270:in",
// 30:       "/Library/Homebrew/downloadable.rb:50:in",
// 31:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 32:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 33:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/_methods.rb:270:in",
// 34:       "/Library/Homebrew/cmd/fetch.rb:236:in",
// 35:       "/Library/Homebrew/cmd/fetch.rb:201:in",
// 36:       "/Library/Homebrew/cmd/fetch.rb:178:in",
// 37:       "/Library/Homebrew/simulate_system.rb:29:in",
// 38:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 39:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/call_validation.rb:157:in",
// 40:       "/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime-0.5.10461/lib/_methods.rb:270:in",
// 41:       "/Library/Homebrew/cmd/fetch.rb:166:in",
// 42:       "/Library/Homebrew/cmd/fetch.rb:163:in",
// 43:       "/Library/Homebrew/cmd/fetch.rb:163:in",
// 44:       "/Library/Homebrew/cmd/fetch.rb:94:in",
// 45:       "/Library/Homebrew/cmd/fetch.rb:94:in",
// 46:       "/Library/Homebrew/brew.rb:94:in",
// 47:     ]
// 48:   end
// 49:
// 50:   let(:backtrace_with_sorbet_error) do
// 51:     backtrace_with_sorbet_paths.drop(1)
// 52:   end
// 53:
// 54:   def exception_with(backtrace:)
// 55:     exception = StandardError.new
// 56:     exception.set_backtrace(backtrace) if backtrace
// 57:     exception
// 58:   end
// 59:
// 60:   before do
// 61:     allow(described_class).to receive(:sorbet_runtime_path)
// 62:       .and_return("/Library/Homebrew/vendor/bundle/ruby/2.6.0/gems/sorbet-runtime")
// 63:     allow(Context).to receive(:current).and_return(Context::ContextStruct.new(verbose: false))
// 64:   end
// 65:
// 66:   it "handles nil backtrace" do
// 67:     exception = exception_with backtrace: nil
// 68:     expect(described_class.clean(exception)).to be_nil
// 69:   end
// 70:
// 71:   it "handles empty array backtrace" do
// 72:     exception = exception_with backtrace: []
// 73:     expect(described_class.clean(exception)).to eq []
// 74:   end
// 75:
// 76:   it "removes sorbet paths when top error is not from sorbet" do
// 77:     exception = exception_with backtrace: backtrace_with_sorbet_paths
// 78:     expect(described_class.clean(exception)).to eq backtrace_no_sorbet_paths
// 79:   end
// 80:
// 81:   it "includes sorbet paths when top error is not from sorbet and verbose is set" do
// 82:     allow(Context).to receive(:current).and_return(Context::ContextStruct.new(verbose: true))
// 83:     exception = exception_with backtrace: backtrace_with_sorbet_paths
// 84:     expect(described_class.clean(exception)).to eq backtrace_with_sorbet_paths
// 85:   end
// 86:
// 87:   it "doesn't change backtrace when error is from sorbet" do
// 88:     exception = exception_with backtrace: backtrace_with_sorbet_error
// 89:     expect(described_class.clean(exception)).to eq backtrace_with_sorbet_error
// 90:   end
// 91: end
