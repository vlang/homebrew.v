module services

import brew_runtime
import homebrew.services.subcommand as info_subcommand

// Translated from Homebrew/brew `test/cmd/services/info_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn info_subcommand_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn info_subcommand_spec_formula(pid bool, verbose bool) map[string]brew_runtime.Value {
	mut formula := {
		'name':        brew_runtime.string_value('service')
		'user':        brew_runtime.string_value('user')
		'status':      brew_runtime.object_value('Symbol', 'started')
		'file':        brew_runtime.string_value('/dev/null')
		'running':     brew_runtime.bool_value(true)
		'loaded':      brew_runtime.bool_value(true)
		'schedulable': brew_runtime.bool_value(false)
	}
	if pid {
		formula['pid'] = brew_runtime.int_value(42)
	}
	if verbose {
		formula['registered'] = brew_runtime.bool_value(true)
		formula['command'] = brew_runtime.string_value('/bin/command')
		formula['working_dir'] = brew_runtime.string_value('/working/dir')
		formula['root_dir'] = brew_runtime.string_value('/root/dir')
		formula['log_path'] = brew_runtime.string_value('/log/dir')
		formula['error_log_path'] = brew_runtime.string_value('/log/dir/error')
		formula['interval'] = brew_runtime.int_value(3600)
		formula['cron'] = brew_runtime.string_value('5 * * * *')
	}
	return formula
}

// Ruby it `it "fails with empty list" do` at line 12.
pub fn ruby_info_subcommand_spec_l12_d1_fails(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := info_subcommand.run_service_info(info_subcommand.ServiceInfoRequest{}) {
		return info_subcommand_spec_bool(false)
	} else {
		return info_subcommand_spec_bool(err.msg() == 'Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.')
	}
}

// Ruby it `it "succeeds with items" do` at line 20.
pub fn ruby_info_subcommand_spec_l20_d2_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := info_subcommand.run_service_info(info_subcommand.ServiceInfoRequest{
		targets: [info_subcommand_spec_formula(false, false)]
	}) or { return info_subcommand_spec_bool(false) }
	return info_subcommand_spec_bool(output == 'service ()\nRunning: true\nLoaded: true\nSchedulable: false\n')
}

// Ruby it `it "succeeds with items - JSON" do` at line 37.
pub fn ruby_info_subcommand_spec_l37_d3_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := info_subcommand.run_service_info(info_subcommand.ServiceInfoRequest{
		targets: [info_subcommand_spec_formula(false, false)]
		json: true
	}) or { return info_subcommand_spec_bool(false) }
	expected := '[\n  {\n    "name": "service",\n    "user": "user",\n    "status": "started",\n    "file": "/dev/null",\n    "running": true,\n    "loaded": true,\n    "schedulable": false\n  }\n]\n'
	return info_subcommand_spec_bool(output == expected)
}

// Ruby it `it "returns minimal output" do` at line 57.
pub fn ruby_info_subcommand_spec_l57_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := info_subcommand.service_info_output(info_subcommand_spec_formula(false, false), false, false, false, info_subcommand.ServiceInfoStyle{})
	expected := 'service ()\nRunning: true\nLoaded: true\nSchedulable: false\n'
	return info_subcommand_spec_bool(output == expected)
}

// Ruby it `it "returns normal output" do` at line 72.
pub fn ruby_info_subcommand_spec_l72_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := info_subcommand.service_info_output(info_subcommand_spec_formula(true, false), false, false, false, info_subcommand.ServiceInfoStyle{})
	expected := 'service ()\nRunning: true\nLoaded: true\nSchedulable: false\nUser: user\nPID: 42\n'
	return info_subcommand_spec_bool(output == expected)
}

// Ruby it `it "returns verbose output" do` at line 89.
pub fn ruby_info_subcommand_spec_l89_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := info_subcommand.service_info_output(info_subcommand_spec_formula(true, true), true, false, false, info_subcommand.ServiceInfoStyle{})
	mut expected := 'service ()\nRunning: true\nLoaded: true\nSchedulable: false\n'
	expected += 'User: user\nPID: 42\nFile: /dev/null true\nRegistered at login: true\nCommand: /bin/command\n'
	expected += 'Working directory: /working/dir\nRoot directory: /root/dir\nLog: /log/dir\nError log: /log/dir/error\n'
	expected += 'Interval: 3600s\nCron: 5 * * * *\n'
	return info_subcommand_spec_bool(output == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/services"
// 5:
// 6: RSpec.describe Homebrew::Cmd::Services::InfoSubcommand do
// 7:   before do
// 8:     allow_any_instance_of(IO).to receive(:tty?).and_return(false)
// 9:   end
// 10:
// 11:   describe "#run" do
// 12:     it "fails with empty list" do
// 13:       expect do
// 14:         described_class.new(Homebrew::Cmd::Services.new(%w[info testball]).args,
// 15:                             targets: []).run
// 16:       end.to raise_error UsageError,
// 17:                          "Invalid usage: Formula(e) missing, please provide a formula name or use `--all`."
// 18:     end
// 19:
// 20:     it "succeeds with items" do
// 21:       out = "service ()\nRunning: true\nLoaded: true\nSchedulable: false\n"
// 22:       formula_wrapper = instance_double(Homebrew::Services::FormulaWrapper, to_hash: {
// 23:         name:        "service",
// 24:         user:        "user",
// 25:         status:      :started,
// 26:         file:        "/dev/null",
// 27:         running:     true,
// 28:         loaded:      true,
// 29:         schedulable: false,
// 30:       })
// 31:       expect do
// 32:         described_class.new(Homebrew::Cmd::Services.new(%w[info testball]).args,
// 33:                             targets: [formula_wrapper]).run
// 34:       end.to output(out).to_stdout
// 35:     end
// 36:
// 37:     it "succeeds with items - JSON" do
// 38:       formula = {
// 39:         name:        "service",
// 40:         user:        "user",
// 41:         status:      :started,
// 42:         file:        "/dev/null",
// 43:         running:     true,
// 44:         loaded:      true,
// 45:         schedulable: false,
// 46:       }
// 47:       out = "#{JSON.pretty_generate([formula])}\n"
// 48:       formula_wrapper = instance_double(Homebrew::Services::FormulaWrapper, to_hash: formula)
// 49:       expect do
// 50:         described_class.new(Homebrew::Cmd::Services.new(%w[info testball --json]).args,
// 51:                             targets: [formula_wrapper]).run
// 52:       end.to output(out).to_stdout
// 53:     end
// 54:   end
// 55:
// 56:   describe "#output" do
// 57:     it "returns minimal output" do
// 58:       out = "service ()\nRunning: true\n"
// 59:       out += "Loaded: true\nSchedulable: false\n"
// 60:       formula = {
// 61:         name:        "service",
// 62:         user:        "user",
// 63:         status:      :started,
// 64:         file:        "/dev/null",
// 65:         running:     true,
// 66:         loaded:      true,
// 67:         schedulable: false,
// 68:       }
// 69:       expect(described_class.output(formula, verbose: false)).to eq(out)
// 70:     end
// 71:
// 72:     it "returns normal output" do
// 73:       out = "service ()\nRunning: true\n"
// 74:       out += "Loaded: true\nSchedulable: false\n"
// 75:       out += "User: user\nPID: 42\n"
// 76:       formula = {
// 77:         name:        "service",
// 78:         user:        "user",
// 79:         status:      :started,
// 80:         file:        "/dev/null",
// 81:         running:     true,
// 82:         loaded:      true,
// 83:         schedulable: false,
// 84:         pid:         42,
// 85:       }
// 86:       expect(described_class.output(formula, verbose: false)).to eq(out)
// 87:     end
// 88:
// 89:     it "returns verbose output" do
// 90:       out = "service ()\nRunning: true\n"
// 91:       out += "Loaded: true\nSchedulable: false\n"
// 92:       out += "User: user\nPID: 42\nFile: /dev/null true\nRegistered at login: true\nCommand: /bin/command\n"
// 93:       out += "Working directory: /working/dir\nRoot directory: /root/dir\nLog: /log/dir\nError log: /log/dir/error\n"
// 94:       out += "Interval: 3600s\nCron: 5 * * * *\n"
// 95:       formula = {
// 96:         name:           "service",
// 97:         user:           "user",
// 98:         status:         :started,
// 99:         file:           "/dev/null",
// 100:         registered:     true,
// 101:         running:        true,
// 102:         loaded:         true,
// 103:         schedulable:    false,
// 104:         pid:            42,
// 105:         command:        "/bin/command",
// 106:         working_dir:    "/working/dir",
// 107:         root_dir:       "/root/dir",
// 108:         log_path:       "/log/dir",
// 109:         error_log_path: "/log/dir/error",
// 110:         interval:       3600,
// 111:         cron:           "5 * * * *",
// 112:       }
// 113:       expect(described_class.output(formula, verbose: true)).to eq(out)
// 114:     end
// 115:   end
// 116: end
