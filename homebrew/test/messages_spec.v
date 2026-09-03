module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/messages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:messages) { described_class.new }` at line 8.
pub fn ruby_messages_spec_l8_d1_messages(args ...brew_runtime.Value) brew_runtime.Value {
	messages := homebrew.new_messages()
	return brew_runtime.structured_value('Messages', 'Messages', {
		'caveats':       messages.caveats.len.str()
		'package_count': messages.package_count.str()
		'install_times': messages.install_times.len.str()
	})
}

// Ruby let `let(:test_formula) do` at line 9.
pub fn ruby_messages_spec_l9_d2_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', 'foo', {
		'name': 'foo'
		'url':  'https://brew.sh/foo-0.1.tgz'
	})
}

// Ruby let `let(:elapsed_time) { 1.1 }` at line 15.
pub fn ruby_messages_spec_l15_d3_elapsed_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.float_value(1.1)
}

// Ruby it `it "adds a caveat" do` at line 18.
pub fn ruby_messages_spec_l18_d4_adds(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	before := messages.caveats.len
	messages.record_caveats('foo', 'Zsh completions were installed')
	return brew_runtime.bool_value(messages.caveats.len == before + 1)
}

// Ruby it `it "increases the package count" do` at line 26.
pub fn ruby_messages_spec_l26_d5_increases(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	before := messages.package_count
	messages.package_installed('foo', 1.1)
	return brew_runtime.bool_value(messages.package_count == before + 1)
}

// Ruby it `it "adds to install_times" do` at line 32.
pub fn ruby_messages_spec_l32_d6_adds(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	before := messages.install_times.len
	messages.package_installed('foo', 1.1)
	return brew_runtime.bool_value(messages.install_times.len == before + 1)
}

// Ruby it `it "doesn't print caveat details" do` at line 46.
pub fn ruby_messages_spec_l46_d7_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	messages.record_caveats('foo', 'Zsh completions were installed')
	messages.package_installed('foo', 1.1)
	return brew_runtime.bool_value(messages.display_messages(false, false) == '')
}

// Ruby it `it "doesn't print caveat details" do` at line 56.
pub fn ruby_messages_spec_l56_d8_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	messages.package_installed('foo', 1.1)
	return brew_runtime.bool_value(messages.display_messages(false, false) == '')
}

// Ruby let `let(:test_formula2) do` at line 62.
pub fn ruby_messages_spec_l62_d9_test_formula2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', 'bar', {
		'name': 'bar'
		'url':  'https://brew.sh/bar-0.1.tgz'
	})
}

// Ruby it `it "prints caveat details" do` at line 75.
pub fn ruby_messages_spec_l75_d10_prints(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	messages.record_caveats('foo', 'Zsh completions were installed')
	messages.package_installed('foo', 1.1)
	messages.package_installed('bar', 1.1)
	return brew_runtime.bool_value(messages.display_messages(false, false) == '==> Caveats\n==> foo\nZsh completions were installed')
}

// Ruby it `it "doesn't print anything" do` at line 88.
pub fn ruby_messages_spec_l88_d11_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	messages := homebrew.new_messages()
	return brew_runtime.bool_value(messages.display_messages(false, true) == '')
}

// Ruby it `it "prints installation times" do` at line 98.
pub fn ruby_messages_spec_l98_d12_prints(args ...brew_runtime.Value) brew_runtime.Value {
	mut messages := homebrew.new_messages()
	messages.package_installed('foo', 1.1)
	return brew_runtime.bool_value(messages.display_messages(false, true) == '==> Installation times\nfoo                       1.100 s')
}

// Ruby it `it "doesn't print installation times" do` at line 110.
pub fn ruby_messages_spec_l110_d13_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	messages := homebrew.new_messages()
	return brew_runtime.bool_value(messages.display_messages(false, false) == '')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "messages"
// 5: require "spec_helper"
// 6:
// 7: RSpec.describe Messages do
// 8:   let(:messages) { described_class.new }
// 9:   let(:test_formula) do
// 10:     formula("foo") do
// 11:       T.bind(self, T.class_of(Formula))
// 12:       url("https://brew.sh/foo-0.1.tgz")
// 13:     end
// 14:   end
// 15:   let(:elapsed_time) { 1.1 }
// 16:
// 17:   describe "#record_caveats" do
// 18:     it "adds a caveat" do
// 19:       expect do
// 20:         messages.record_caveats(test_formula.name, "Zsh completions were installed")
// 21:       end.to change(messages.caveats, :count).by(1)
// 22:     end
// 23:   end
// 24:
// 25:   describe "#package_installed" do
// 26:     it "increases the package count" do
// 27:       expect do
// 28:         messages.package_installed(test_formula.name, elapsed_time)
// 29:       end.to change(messages, :package_count).by(1)
// 30:     end
// 31:
// 32:     it "adds to install_times" do
// 33:       expect do
// 34:         messages.package_installed(test_formula.name, elapsed_time)
// 35:       end.to change(messages.install_times, :count).by(1)
// 36:     end
// 37:   end
// 38:
// 39:   describe "#display_messages" do
// 40:     context "when package_count is less than two" do
// 41:       before do
// 42:         messages.record_caveats(test_formula.name, "Zsh completions were installed")
// 43:         messages.package_installed(test_formula.name, elapsed_time)
// 44:       end
// 45:
// 46:       it "doesn't print caveat details" do
// 47:         expect { messages.display_messages }.not_to output.to_stdout
// 48:       end
// 49:     end
// 50:
// 51:     context "when caveats is empty" do
// 52:       before do
// 53:         messages.package_installed(test_formula.name, elapsed_time)
// 54:       end
// 55:
// 56:       it "doesn't print caveat details" do
// 57:         expect { messages.display_messages }.not_to output.to_stdout
// 58:       end
// 59:     end
// 60:
// 61:     context "when package_count is greater than one and caveats are present" do
// 62:       let(:test_formula2) do
// 63:         formula("bar") do
// 64:           T.bind(self, T.class_of(Formula))
// 65:           url("https://brew.sh/bar-0.1.tgz")
// 66:         end
// 67:       end
// 68:
// 69:       before do
// 70:         messages.record_caveats(test_formula.name, "Zsh completions were installed")
// 71:         messages.package_installed(test_formula.name, elapsed_time)
// 72:         messages.package_installed(test_formula2.name, elapsed_time)
// 73:       end
// 74:
// 75:       it "prints caveat details" do
// 76:         expect { messages.display_messages }.to output(
// 77:           <<~EOS,
// 78:             ==> Caveats
// 79:             ==> foo
// 80:             Zsh completions were installed
// 81:           EOS
// 82:         ).to_stdout
// 83:       end
// 84:     end
// 85:
// 86:     context "when the `display_times` argument is true" do
// 87:       context "when `install_times` is empty" do
// 88:         it "doesn't print anything" do
// 89:           expect { messages.display_messages(display_times: true) }.not_to output.to_stdout
// 90:         end
// 91:       end
// 92:
// 93:       context "when `install_times` is present" do
// 94:         before do
// 95:           messages.package_installed(test_formula.name, elapsed_time)
// 96:         end
// 97:
// 98:         it "prints installation times" do
// 99:           expect { messages.display_messages(display_times: true) }.to output(
// 100:             <<~EOS,
// 101:               ==> Installation times
// 102:               foo                       1.100 s
// 103:             EOS
// 104:           ).to_stdout
// 105:         end
// 106:       end
// 107:     end
// 108:
// 109:     context "when the `display_times` argument isn't specified" do
// 110:       it "doesn't print installation times" do
// 111:         expect { messages.display_messages }.not_to output.to_stdout
// 112:       end
// 113:     end
// 114:   end
// 115: end
