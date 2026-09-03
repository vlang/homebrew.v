module services

import brew_runtime
import homebrew.services.subcommand as list_subcommand

// Translated from Homebrew/brew `test/cmd/services/list_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn list_subcommand_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn list_subcommand_spec_formula(name string, status string, user string, file string,
	loaded bool) list_subcommand.ServiceListFormula {
	return list_subcommand.ServiceListFormula{
		name: name
		status: status
		user: user
		user_present: true
		file: file
		file_present: true
		loaded: loaded
	}
}

fn list_subcommand_spec_formulae_value(formulae []list_subcommand.ServiceListFormula) brew_runtime.Value {
	return brew_runtime.array_value(formulae.map(list_subcommand.service_list_formula_value(it)))
}

// Ruby it `it "fails with empty list" do` at line 8.
pub fn ruby_list_subcommand_spec_l8_d1_fails(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := list_subcommand.run_service_list(list_subcommand.ServiceListRequest{
		stderr_tty: true
	}) or { return list_subcommand_spec_bool(false) }
	return list_subcommand_spec_bool(result.stderr.contains('No services available to control with `brew services`'))
}

// Ruby it `it "outputs empty JSON array with empty list and --json" do` at line 16.
pub fn ruby_list_subcommand_spec_l16_d2_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := list_subcommand.run_service_list(list_subcommand.ServiceListRequest{
		json: true
	}) or { return list_subcommand_spec_bool(false) }
	return list_subcommand_spec_bool(result.stdout == '[]\n')
}

// Ruby it `it "succeeds with list" do` at line 23.
pub fn ruby_list_subcommand_spec_l23_d3_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := list_subcommand.run_service_list(list_subcommand.ServiceListRequest{
		formulae: [list_subcommand_spec_formula('service', 'started', 'user', '/dev/null', true)]
	}) or { return list_subcommand_spec_bool(false) }
	return list_subcommand_spec_bool(result.stdout == 'Name    Status User File\nservice started         user /dev/null\n')
}

// Ruby it `it "succeeds with list - JSON" do` at line 38.
pub fn ruby_list_subcommand_spec_l38_d4_succeeds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := list_subcommand.run_service_list(list_subcommand.ServiceListRequest{
		json: true
		formulae: [list_subcommand_spec_formula('service', 'started', 'user', '/dev/null', true)]
	}) or { return list_subcommand_spec_bool(false) }
	expected := '[\n  {\n    "name": "service",\n    "status": "started",\n    "user": "user",\n    "file": "/dev/null"\n  }\n]\n'
	return list_subcommand_spec_bool(result.stdout == expected)
}

// Ruby it `it "prints all standard values" do` at line 60.
pub fn ruby_list_subcommand_spec_l60_d5_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := list_subcommand.service_list_print_table([
		list_subcommand_spec_formula('a', 'stopped', 'u', '/tmp/file.file', false),
	], '/tmp', list_subcommand.ServiceListStyle{}) or { return list_subcommand_spec_bool(false) }
	return list_subcommand_spec_bool(output == 'Name Status User File\na    stopped         u    \n')
}

// Ruby it `it "prints without user or file data" do` at line 67.
pub fn ruby_list_subcommand_spec_l67_d6_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand.ServiceListFormula{
		name: 'a'
		status: 'started'
		user_present: true
		user_nil: true
		file_present: true
		file_nil: true
		loaded: true
	}
	output := list_subcommand.service_list_print_table([formula], '/tmp', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(output == 'Name Status User File\na    started              \n')
}

// Ruby it `it "prints shortened home directory" do` at line 74.
pub fn ruby_list_subcommand_spec_l74_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand_spec_formula('a', 'started', 'u', '/tmp/file.file', true)
	output := list_subcommand.service_list_print_table([formula], '/tmp', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(output == 'Name Status User File\na    started         u    ~/file.file\n')
}

// Ruby it `it "prints an error code" do` at line 83.
pub fn ruby_list_subcommand_spec_l83_d8_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand.ServiceListFormula{
		...list_subcommand_spec_formula('a', 'error', 'u', '/tmp/file.file', true)
		exit_code: 256
		exit_present: true
	}
	output := list_subcommand.service_list_print_table([formula], '/home/test', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(output == 'Name Status User File\na    error  256      u    /tmp/file.file\n')
}

// Ruby it `it "prints all standard values" do` at line 94.
pub fn ruby_list_subcommand_spec_l94_d9_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand_spec_formula('a', 'stopped', 'u', '/tmp/file.file', false)
	output := list_subcommand.service_list_print_json([formula])
	expected := '[\n  {\n    "name": "a",\n    "status": "stopped",\n    "user": "u",\n    "file": "/tmp/file.file"\n  }\n]\n'
	return list_subcommand_spec_bool(output == expected)
}

// Ruby it `it "prints without user or file data" do` at line 102.
pub fn ruby_list_subcommand_spec_l102_d10_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand.ServiceListFormula{
		name: 'a'
		status: 'started'
		user_present: true
		user_nil: true
		file_present: true
		file_nil: true
		loaded: true
	}
	output := list_subcommand.service_list_print_json([formula])
	expected := '[\n  {\n    "name": "a",\n    "status": "started",\n    "user": null,\n    "file": null\n  }\n]\n'
	return list_subcommand_spec_bool(output == expected)
}

// Ruby it `it "includes an exit code" do` at line 111.
pub fn ruby_list_subcommand_spec_l111_d11_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	formula := list_subcommand.ServiceListFormula{
		...list_subcommand_spec_formula('a', 'error', 'u', '/tmp/file.file', true)
		exit_code: 256
		exit_present: true
	}
	output := list_subcommand.service_list_print_json([formula])
	expected := '[\n  {\n    "name": "a",\n    "status": "error",\n    "user": "u",\n    "file": "/tmp/file.file",\n    "exit_code": 256\n  }\n]\n'
	return list_subcommand_spec_bool(output == expected)
}

// Ruby it `it "returns started" do` at line 123.
pub fn ruby_list_subcommand_spec_l123_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	status := list_subcommand.service_list_get_status_string('started', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(status == 'started')
}

// Ruby it `it "returns stopped" do` at line 127.
pub fn ruby_list_subcommand_spec_l127_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	status := list_subcommand.service_list_get_status_string('stopped', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(status == 'stopped')
}

// Ruby it `it "returns error" do` at line 131.
pub fn ruby_list_subcommand_spec_l131_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	status := list_subcommand.service_list_get_status_string('error', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(status == 'error  ')
}

// Ruby it `it "returns unknown" do` at line 135.
pub fn ruby_list_subcommand_spec_l135_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	status := list_subcommand.service_list_get_status_string('unknown', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(status == 'unknown')
}

// Ruby it `it "returns other" do` at line 139.
pub fn ruby_list_subcommand_spec_l139_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	status := list_subcommand.service_list_get_status_string('other', list_subcommand.ServiceListStyle{}) or {
		return list_subcommand_spec_bool(false)
	}
	return list_subcommand_spec_bool(status == 'other')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/services"
// 5:
// 6: RSpec.describe Homebrew::Cmd::Services::ListSubcommand do
// 7:   describe "#run" do
// 8:     it "fails with empty list" do
// 9:       expect(Homebrew::Services::Formulae).to receive(:services_list).and_return([])
// 10:       expect do
// 11:         allow($stderr).to receive(:tty?).and_return(true)
// 12:         described_class.new(Homebrew::Cmd::Services.new(%w[list]).args).run
// 13:       end.to output(a_string_including("No services available to control with `brew services`")).to_stderr
// 14:     end
// 15:
// 16:     it "outputs empty JSON array with empty list and --json" do
// 17:       expect(Homebrew::Services::Formulae).to receive(:services_list).and_return([])
// 18:       expect do
// 19:         described_class.new(Homebrew::Cmd::Services.new(%w[list --json]).args).run
// 20:       end.to output("[]\n").to_stdout
// 21:     end
// 22:
// 23:     it "succeeds with list" do
// 24:       out = "Name    Status User File\nservice started         user /dev/null\n"
// 25:       formula = {
// 26:         name:   "service",
// 27:         user:   "user",
// 28:         status: :started,
// 29:         file:   "/dev/null",
// 30:         loaded: true,
// 31:       }
// 32:       expect(Homebrew::Services::Formulae).to receive(:services_list).and_return([formula])
// 33:       expect do
// 34:         described_class.new(Homebrew::Cmd::Services.new(%w[list]).args).run
// 35:       end.to output(out).to_stdout
// 36:     end
// 37:
// 38:     it "succeeds with list - JSON" do
// 39:       formula = {
// 40:         name:        "service",
// 41:         user:        "user",
// 42:         status:      :started,
// 43:         file:        "/dev/null",
// 44:         running:     true,
// 45:         loaded:      true,
// 46:         schedulable: false,
// 47:       }
// 48:
// 49:       filtered_formula = formula.slice(*Homebrew::Cmd::Services::ListSubcommand::JSON_FIELDS)
// 50:       expected_output = "#{JSON.pretty_generate([filtered_formula])}\n"
// 51:
// 52:       expect(Homebrew::Services::Formulae).to receive(:services_list).and_return([formula])
// 53:       expect do
// 54:         described_class.new(Homebrew::Cmd::Services.new(%w[list --json]).args).run
// 55:       end.to output(expected_output).to_stdout
// 56:     end
// 57:   end
// 58:
// 59:   describe "#print_table" do
// 60:     it "prints all standard values" do
// 61:       formula = { name: "a", user: "u", file: Pathname.new("/tmp/file.file"), status: :stopped }
// 62:       expect do
// 63:         described_class.print_table([formula])
// 64:       end.to output("Name Status User File\na    stopped         u    \n").to_stdout
// 65:     end
// 66:
// 67:     it "prints without user or file data" do
// 68:       formula = { name: "a", user: nil, file: nil, status: :started, loaded: true }
// 69:       expect do
// 70:         described_class.print_table([formula])
// 71:       end.to output("Name Status User File\na    started              \n").to_stdout
// 72:     end
// 73:
// 74:     it "prints shortened home directory" do
// 75:       ENV["HOME"] = "/tmp"
// 76:       formula = { name: "a", user: "u", file: Pathname.new("/tmp/file.file"), status: :started, loaded: true }
// 77:       expected_output = "Name Status User File\na    started         u    ~/file.file\n"
// 78:       expect do
// 79:         described_class.print_table([formula])
// 80:       end.to output(expected_output).to_stdout
// 81:     end
// 82:
// 83:     it "prints an error code" do
// 84:       file = Pathname.new("/tmp/file.file")
// 85:       formula = { name: "a", user: "u", file:, status: :error, exit_code: 256, loaded: true }
// 86:       expected_output = "Name Status User File\na    error  256      u    /tmp/file.file\n"
// 87:       expect do
// 88:         described_class.print_table([formula])
// 89:       end.to output(expected_output).to_stdout
// 90:     end
// 91:   end
// 92:
// 93:   describe "#print_json" do
// 94:     it "prints all standard values" do
// 95:       formula = { name: "a", status: :stopped, user: "u", file: Pathname.new("/tmp/file.file") }
// 96:       expected_output = "#{JSON.pretty_generate([formula])}\n"
// 97:       expect do
// 98:         described_class.print_json([formula])
// 99:       end.to output(expected_output).to_stdout
// 100:     end
// 101:
// 102:     it "prints without user or file data" do
// 103:       formula = { name: "a", user: nil, file: nil, status: :started, loaded: true }
// 104:       filtered_formula = formula.slice(*Homebrew::Cmd::Services::ListSubcommand::JSON_FIELDS)
// 105:       expected_output = "#{JSON.pretty_generate([filtered_formula])}\n"
// 106:       expect do
// 107:         described_class.print_json([formula])
// 108:       end.to output(expected_output).to_stdout
// 109:     end
// 110:
// 111:     it "includes an exit code" do
// 112:       file = Pathname.new("/tmp/file.file")
// 113:       formula = { name: "a", user: "u", file:, status: :error, exit_code: 256, loaded: true }
// 114:       filtered_formula = formula.slice(*Homebrew::Cmd::Services::ListSubcommand::JSON_FIELDS)
// 115:       expected_output = "#{JSON.pretty_generate([filtered_formula])}\n"
// 116:       expect do
// 117:         described_class.print_json([formula])
// 118:       end.to output(expected_output).to_stdout
// 119:     end
// 120:   end
// 121:
// 122:   describe "#get_status_string" do
// 123:     it "returns started" do
// 124:       expect(described_class.get_status_string(:started)).to eq("started")
// 125:     end
// 126:
// 127:     it "returns stopped" do
// 128:       expect(described_class.get_status_string(:stopped)).to eq("stopped")
// 129:     end
// 130:
// 131:     it "returns error" do
// 132:       expect(described_class.get_status_string(:error)).to eq("error  ")
// 133:     end
// 134:
// 135:     it "returns unknown" do
// 136:       expect(described_class.get_status_string(:unknown)).to eq("unknown")
// 137:     end
// 138:
// 139:     it "returns other" do
// 140:       expect(described_class.get_status_string(:other)).to eq("other")
// 141:     end
// 142:   end
// 143: end
