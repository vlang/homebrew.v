module shared_examples

import ruby
import homebrew.cask as core

// Translated from Homebrew/brew `test/cask/dsl/shared_examples/staged.rb`.
// The original source is retained below until every stub has a typed V body.
const staged_existing_path = '/path/to/file/that/exists'
const staged_missing_path = '/path/to/file/that/does/not/exist'

fn staged_example(denied bool) &core.StagedState {
	return core.new_staged_state('sample', 'fake_user', [staged_existing_path], if denied {
		[staged_existing_path]
	} else {
		[]
	})
}

// Ruby let `let(:existing_path) { Pathname("/path/to/file/that/exists") }` at line 7.
pub fn ruby_staged_l7_d1_existing_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', staged_existing_path)
}

// Ruby let `let(:non_existent_path) { Pathname("/path/to/file/that/does/not/exist") }` at line 8.
pub fn ruby_staged_l8_d2_non_existent_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', staged_missing_path)
}

// Ruby it `it "can run system commands with list-form arguments" do` at line 15.
pub fn ruby_staged_l15_d3_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.system_command('echo', ['homebrew-cask', 'rocks!'], false)
	return ruby.bool_value(state.invocations == [core.StagedCommandInvocation{
		executable: 'echo'
		args: ['homebrew-cask', 'rocks!']
	}])
}

// Ruby it `it "can set the permissions of a file" do` at line 22.
pub fn ruby_staged_l22_d4_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_permissions([staged_existing_path], '777')
	return ruby.bool_value(state.invocations.len == 1 && state.invocations[0].executable == 'chmod' && state.invocations[0].args == [
		'-R',
		'--',
		'777',
		staged_existing_path,
	] && !state.invocations[0].sudo)
}

// Ruby it `it "can set the permissions of multiple files" do` at line 32.
pub fn ruby_staged_l32_d5_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_permissions([staged_existing_path, staged_existing_path], '777')
	return ruby.bool_value(state.invocations.len == 1 && state.invocations[0].args == [
		'-R',
		'--',
		'777',
		staged_existing_path,
		staged_existing_path,
	])
}

// Ruby it `it "cannot set the permissions of a file that does not exist" do` at line 42.
pub fn ruby_staged_l42_d6_cannot(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_permissions([staged_missing_path], '777')
	return ruby.bool_value(state.invocations.len == 0)
}

// Ruby it `it "can set the ownership of a file" do` at line 49.
pub fn ruby_staged_l49_d7_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_ownership([staged_existing_path], '', '') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.invocations.len == 1 && state.invocations[0].args == [
		'-R',
		'--',
		'fake_user:staff',
		staged_existing_path,
	] && state.invocations[0].sudo)
}

// Ruby it `it "can set the ownership of multiple files" do` at line 61.
pub fn ruby_staged_l61_d8_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_ownership([staged_existing_path, staged_existing_path], '', '') or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(state.invocations.len == 1 && state.invocations[0].args == [
		'-R',
		'--',
		'fake_user:staff',
		staged_existing_path,
		staged_existing_path,
	])
}

// Ruby it `it "can set the ownership of a file with a different user and group" do` at line 77.
pub fn ruby_staged_l77_d9_can(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_ownership([staged_existing_path], 'other_user', 'other_group') or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(state.invocations[0].args == ['-R', '--', 'other_user:other_group',
		staged_existing_path])
}

// Ruby it `it "sets the ownership of an app when App Management permissions are granted" do` at line 92.
pub fn ruby_staged_l92_d10_sets(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_ownership([staged_existing_path], '', '') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.invocations.len == 1 && state.invocations[0].executable == 'chown')
}

// Ruby it `it "does not set the ownership of an app when App Management permissions are missing" do` at line 107.
pub fn ruby_staged_l107_d11_does(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(true)
	state.set_ownership([staged_existing_path], '', '') or {
		return ruby.bool_value(err.msg().contains('App Management permissions') && state.invocations.len == 0)
	}
	return ruby.bool_value(false)
}

// Ruby it `it "cannot set the ownership of a file that does not exist" do` at line 123.
pub fn ruby_staged_l123_d12_cannot(args ...ruby.Value) ruby.Value {
	_ = args
	mut state := staged_example(false)
	state.set_ownership([staged_missing_path], '', '') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.invocations.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/staged"
// 5:
// 6: RSpec.shared_examples Cask::Staged do
// 7:   let(:existing_path) { Pathname("/path/to/file/that/exists") }
// 8:   let(:non_existent_path) { Pathname("/path/to/file/that/does/not/exist") }
// 9:
// 10:   before do
// 11:     allow(existing_path).to receive_messages(exist?: true, expand_path: existing_path)
// 12:     allow(non_existent_path).to receive_messages(exist?: false, expand_path: non_existent_path)
// 13:   end
// 14:
// 15:   it "can run system commands with list-form arguments" do
// 16:     expect(fake_system_command).to receive(:run!)
// 17:       .with("echo", args: ["homebrew-cask", "rocks!"])
// 18:
// 19:     staged.system_command("echo", args: ["homebrew-cask", "rocks!"])
// 20:   end
// 21:
// 22:   it "can set the permissions of a file" do
// 23:     fake_pathname = existing_path
// 24:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 25:
// 26:     expect(fake_system_command).to receive(:run!)
// 27:       .with("chmod", args: ["-R", "--", "777", fake_pathname], sudo: false)
// 28:
// 29:     staged.set_permissions(fake_pathname.to_s, "777")
// 30:   end
// 31:
// 32:   it "can set the permissions of multiple files" do
// 33:     fake_pathname = existing_path
// 34:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 35:
// 36:     expect(fake_system_command).to receive(:run!)
// 37:       .with("chmod", args: ["-R", "--", "777", fake_pathname, fake_pathname], sudo: false)
// 38:
// 39:     staged.set_permissions([fake_pathname.to_s, fake_pathname.to_s], "777")
// 40:   end
// 41:
// 42:   it "cannot set the permissions of a file that does not exist" do
// 43:     fake_pathname = non_existent_path
// 44:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 45:     expect(fake_system_command).not_to receive(:run!)
// 46:     staged.set_permissions(fake_pathname.to_s, "777")
// 47:   end
// 48:
// 49:   it "can set the ownership of a file" do
// 50:     fake_pathname = existing_path
// 51:
// 52:     allow(User).to receive(:current).and_return(User.new("fake_user"))
// 53:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 54:
// 55:     expect(fake_system_command).to receive(:run!)
// 56:       .with("chown", args: ["-R", "--", "fake_user:staff", fake_pathname], sudo: true)
// 57:
// 58:     staged.set_ownership(fake_pathname.to_s)
// 59:   end
// 60:
// 61:   it "can set the ownership of multiple files" do
// 62:     fake_pathname = existing_path
// 63:
// 64:     allow(User).to receive(:current).and_return(User.new("fake_user"))
// 65:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 66:
// 67:     expect(fake_system_command).to receive(:run!)
// 68:       .with(
// 69:         "chown",
// 70:         args: ["-R", "--", "fake_user:staff", fake_pathname, fake_pathname],
// 71:         sudo: true,
// 72:       )
// 73:
// 74:     staged.set_ownership([fake_pathname.to_s, fake_pathname.to_s])
// 75:   end
// 76:
// 77:   it "can set the ownership of a file with a different user and group" do
// 78:     fake_pathname = existing_path
// 79:
// 80:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 81:
// 82:     expect(fake_system_command).to receive(:run!)
// 83:       .with(
// 84:         "chown",
// 85:         args: ["-R", "--", "other_user:other_group", fake_pathname],
// 86:         sudo: true,
// 87:       )
// 88:
// 89:     staged.set_ownership(fake_pathname.to_s, user: "other_user", group: "other_group")
// 90:   end
// 91:
// 92:   it "sets the ownership of an app when App Management permissions are granted" do
// 93:     fake_pathname = existing_path
// 94:
// 95:     allow(User).to receive(:current).and_return(User.new("fake_user"))
// 96:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 97:     allow(Cask::Quarantine).to receive(:app_management_permissions_granted?)
// 98:       .with(app: fake_pathname, command: fake_system_command)
// 99:       .and_return(true)
// 100:
// 101:     expect(fake_system_command).to receive(:run!)
// 102:       .with("chown", args: ["-R", "--", "fake_user:staff", fake_pathname], sudo: true)
// 103:
// 104:     staged.set_ownership(fake_pathname.to_s)
// 105:   end
// 106:
// 107:   it "does not set the ownership of an app when App Management permissions are missing" do
// 108:     fake_pathname = existing_path
// 109:
// 110:     allow(User).to receive(:current).and_return(User.new("fake_user"))
// 111:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 112:     allow(Cask::Quarantine).to receive(:app_management_permissions_granted?)
// 113:       .with(app: fake_pathname, command: fake_system_command)
// 114:       .and_return(false)
// 115:
// 116:     expect(fake_system_command).not_to receive(:run!)
// 117:
// 118:     expect do
// 119:       staged.set_ownership(fake_pathname.to_s)
// 120:     end.to raise_error(Cask::CaskError, /App Management permissions/)
// 121:   end
// 122:
// 123:   it "cannot set the ownership of a file that does not exist" do
// 124:     allow(User).to receive(:current).and_return(User.new("fake_user"))
// 125:     fake_pathname = non_existent_path
// 126:     allow(staged).to receive(:Pathname).and_return(fake_pathname)
// 127:     expect(fake_system_command).not_to receive(:run!)
// 128:     staged.set_ownership(fake_pathname.to_s)
// 129:   end
// 130: end
