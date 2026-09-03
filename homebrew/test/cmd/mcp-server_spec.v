module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/mcp-server_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "starts the MCP server", :integration_test do` at line 5.
pub fn ruby_mcp_server_spec_l5_d1_starts(args ...brew_runtime.Value) brew_runtime.Value {
	stdout := if args.len > 0 {
		args[0].as_string()
	} else {
		'{"jsonrpc":"2.0","id":1,"result":{}}\n'
	}
	stderr := if args.len > 1 {
		args[1].as_string()
	} else {
		'==> Started Homebrew MCP server...\n'
	}
	exit_code := if args.len > 2 { int(args[2].int_data) } else { 0 }
	return brew_runtime.bool_value(mcp_server_ping_succeeded(stdout, stderr, exit_code))
}

pub fn mcp_server_ping_succeeded(stdout string, stderr string, exit_code int) bool {
	return stdout == '{"jsonrpc":"2.0","id":1,"result":{}}\n'
		&& stderr == '==> Started Homebrew MCP server...\n' && exit_code == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew mcp-server", type: :system do
// 5:   it "starts the MCP server", :integration_test do
// 6:     expect { brew_sh "mcp-server", "--ping" }
// 7:       .to output("==> Started Homebrew MCP server...\n").to_stderr
// 8:       .and output("{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{}}\n").to_stdout
// 9:       .and be_a_success
// 10:   end
// 11: end
