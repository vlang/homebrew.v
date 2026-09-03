module utils

import brew_runtime
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `test/utils/user_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:user) { described_class.current }` at line 7.
pub fn ruby_user_spec_l7_d1_user(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_utils.ruby_user_l26_d2_self_current()
}

// Ruby it `it { is_expected.to eq ENV.fetch("USER") }` at line 9.
pub fn ruby_user_spec_l9_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	user := brew_utils.current_user() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(user.name == brew_runtime.environment_value('USER')
		|| user.name == brew_runtime.current_username())
}

// Ruby let `let(:who_output) { "" }` at line 12.
pub fn ruby_user_spec_l12_d3_who_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby let `let(:who_output) do` at line 22.
pub fn ruby_user_spec_l22_d4_who_output(args ...brew_runtime.Value) brew_runtime.Value {
	name := brew_runtime.current_username()
	return brew_runtime.string_value('${name}   console  Oct  1 11:23\n${name}   ttys001  Oct  1 11:25\n')
}

// Ruby it `it(:gui?) { expect(user.gui?).to be true }` at line 29.
pub fn ruby_user_spec_l29_d5_gui(args ...brew_runtime.Value) brew_runtime.Value {
	user := brew_utils.current_user() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(user.gui_from_who_output(ruby_user_spec_l22_d4_who_output().as_string(),
		true))
}

// Ruby let `let(:who_output) do` at line 33.
pub fn ruby_user_spec_l33_d6_who_output(args ...brew_runtime.Value) brew_runtime.Value {
	name := brew_runtime.current_username()
	return brew_runtime.string_value('${name}   ttys001  Oct  1 11:25\nfake_user              ttys002  Oct  1 11:27\n')
}

// Ruby it `it(:gui?) { expect(user.gui?).to be false }` at line 40.
pub fn ruby_user_spec_l40_d7_gui(args ...brew_runtime.Value) brew_runtime.Value {
	user := brew_utils.current_user() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!user.gui_from_who_output(ruby_user_spec_l33_d6_who_output().as_string(),
		true))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5:
// 6: RSpec.describe User do
// 7:   subject(:user) { described_class.current }
// 8:
// 9:   it { is_expected.to eq ENV.fetch("USER") }
// 10:
// 11:   describe "#gui?" do
// 12:     let(:who_output) { "" }
// 13:
// 14:     before do
// 15:       allow(SystemCommand).to receive(:run)
// 16:         .with("who", any_args)
// 17:         .and_return(instance_double(SystemCommand::Result,
// 18:                                     to_a: [who_output, "", instance_double(Process::Status, success?: true)]))
// 19:     end
// 20:
// 21:     context "when the current user is in a console session" do
// 22:       let(:who_output) do
// 23:         <<~EOS
// 24:           #{ENV.fetch("USER")}   console  Oct  1 11:23
// 25:           #{ENV.fetch("USER")}   ttys001  Oct  1 11:25
// 26:         EOS
// 27:       end
// 28:
// 29:       it(:gui?) { expect(user.gui?).to be true }
// 30:     end
// 31:
// 32:     context "when the current user is not in a console session" do
// 33:       let(:who_output) do
// 34:         <<~EOS
// 35:           #{ENV.fetch("USER")}   ttys001  Oct  1 11:25
// 36:           fake_user              ttys002  Oct  1 11:27
// 37:         EOS
// 38:       end
// 39:
// 40:       it(:gui?) { expect(user.gui?).to be false }
// 41:     end
// 42:   end
// 43: end
