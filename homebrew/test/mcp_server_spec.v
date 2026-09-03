module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/mcp_server_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:stdin) { StringIO.new }` at line 9.
pub fn ruby_mcp_server_spec_l9_d1_stdin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('StringIO', '')
}

// Ruby let `let(:stdout) { StringIO.new }` at line 10.
pub fn ruby_mcp_server_spec_l10_d2_stdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('StringIO', '')
}

// Ruby let `let(:stderr) { StringIO.new }` at line 11.
pub fn ruby_mcp_server_spec_l11_d3_stderr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('StringIO', '')
}

// Ruby let `let(:server) { described_class.new(stdin:, stdout:, stderr:) }` at line 12.
pub fn ruby_mcp_server_spec_l12_d4_server(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.mcp_server_state_value(homebrew.new_mcp_server([], [], '/brew', '4.0.0'))
}

// Ruby let `let(:jsonrpc) { Homebrew::McpServer::JSON_RPC_VERSION }` at line 13.
pub fn ruby_mcp_server_spec_l13_d5_jsonrpc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(homebrew.mcp_json_rpc_version)
}

// Ruby let `let(:id) { Random.rand(1000) }` at line 14.
pub fn ruby_mcp_server_spec_l14_d6_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(42)
}

// Ruby let `let(:code) { Homebrew::McpServer::ERROR_CODE }` at line 15.
pub fn ruby_mcp_server_spec_l15_d7_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(homebrew.mcp_error_code)
}

// Ruby it `it "sets debug_logging to false by default" do` at line 18.
pub fn ruby_mcp_server_spec_l18_d8_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!homebrew.new_mcp_server([], [], '/brew', '4.0.0').debug_logging)
}

// Ruby it `it "sets debug_logging to true if --debug is in ARGV" do` at line 22.
pub fn ruby_mcp_server_spec_l22_d9_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.new_mcp_server(['--debug'], [], '/brew', '4.0.0').debug_logging)
}

// Ruby it `it "sets debug_logging to true if -d is in ARGV" do` at line 27.
pub fn ruby_mcp_server_spec_l27_d10_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.new_mcp_server(['-d'], [], '/brew', '4.0.0').debug_logging)
}

// Ruby it `it "logs debug output when debug_logging is true" do` at line 34.
pub fn ruby_mcp_server_spec_l34_d11_logs(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server(['--debug'], [], '/brew', '4.0.0')
	homebrew.mcp_debug(mut server, 'foo')
	return brew_runtime.bool_value(server.stderr_lines.join('').contains('foo'))
}

// Ruby it `it "does not log debug output when debug_logging is false" do` at line 40.
pub fn ruby_mcp_server_spec_l40_d12_does(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	homebrew.mcp_debug(mut server, 'foo')
	return brew_runtime.bool_value(server.stderr_lines.len == 0)
}

// Ruby it `it "logs to stderr" do` at line 45.
pub fn ruby_mcp_server_spec_l45_d13_logs(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	homebrew.mcp_log(mut server, 'bar')
	return brew_runtime.bool_value(server.stderr_lines.join('').contains('bar'))
}

// Ruby it `it "responds to initialize method" do` at line 52.
pub fn ruby_mcp_server_spec_l52_d14_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_handle('initialize', brew_runtime.map_value(map[string]brew_runtime.Value{}))
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	protocol := result.map_data['protocolVersion'] or { return brew_runtime.bool_value(false) }
	server_info := result.map_data['serverInfo'] or { return brew_runtime.bool_value(false) }
	name := server_info.map_data['name'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(response.present && protocol.as_string() == homebrew.mcp_protocol_version && name.as_string() == 'brew-mcp-server')
}

// Ruby it `it "responds to resources/list" do` at line 72.
pub fn ruby_mcp_server_spec_l72_d15_responds(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_spec_result_array_empty('resources/list', 'resources')
}

// Ruby it `it "responds to resources/templates/list" do` at line 78.
pub fn ruby_mcp_server_spec_l78_d16_responds(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_spec_result_array_empty('resources/templates/list', 'resourceTemplates')
}

// Ruby it `it "responds to prompts/list" do` at line 84.
pub fn ruby_mcp_server_spec_l84_d17_responds(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_spec_result_array_empty('prompts/list', 'prompts')
}

// Ruby it `it "responds to ping" do` at line 90.
pub fn ruby_mcp_server_spec_l90_d18_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_handle('ping', brew_runtime.map_value(map[string]brew_runtime.Value{}))
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(response.present && result.map_data.len == 0)
}

// Ruby it `it "responds to get_server_info" do` at line 96.
pub fn ruby_mcp_server_spec_l96_d19_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_handle('get_server_info', brew_runtime.map_value(map[string]brew_runtime.Value{}))
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	name := result.map_data['name'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(response.present && name.as_string() == 'brew-mcp-server')
}

// Ruby it `it "responds to logging/setLevel with debug" do` at line 102.
pub fn ruby_mcp_server_spec_l102_d20_responds(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	response := homebrew.mcp_handle_request(mut server, mcp_spec_request('logging/setLevel', brew_runtime.map_value({
		'level': brew_runtime.string_value('debug')
	}), true), mcp_spec_runner) or { return brew_runtime.bool_value(false) }
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(server.debug_logging && response.present && result.map_data.len == 0)
}

// Ruby it `it "responds to logging/setLevel with non-debug" do` at line 109.
pub fn ruby_mcp_server_spec_l109_d21_responds(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server(['--debug'], [], '/brew', '4.0.0')
	response := homebrew.mcp_handle_request(mut server, mcp_spec_request('logging/setLevel', brew_runtime.map_value({
		'level': brew_runtime.string_value('info')
	}), true), mcp_spec_runner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!server.debug_logging && response.present)
}

// Ruby it `it "responds to notifications/initialized" do` at line 116.
pub fn ruby_mcp_server_spec_l116_d22_responds(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_spec_notification('notifications/initialized')
}

// Ruby it `it "responds to notifications/cancelled" do` at line 121.
pub fn ruby_mcp_server_spec_l121_d23_responds(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_spec_notification('notifications/cancelled')
}

// Ruby it `it "responds to tools/list" do` at line 126.
pub fn ruby_mcp_server_spec_l126_d24_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_handle('tools/list', brew_runtime.map_value(map[string]brew_runtime.Value{}))
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	tools_value := result.map_data['tools'] or { return brew_runtime.bool_value(false) }
	tools := tools_value.as_array() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(tools.len == homebrew.mcp_tools().len && tools.len == 14)
}

// Ruby it `it "responds to tools/call for` at line 133.
pub fn ruby_mcp_server_spec_l133_d25_responds(args ...brew_runtime.Value) brew_runtime.Value {
	for tool in homebrew.mcp_tools() {
		mut arguments := map[string]brew_runtime.Value{}
		for required in tool.required {
			arguments[required] = brew_runtime.string_value('dummy')
		}
		response := mcp_spec_tools_call(tool.name, arguments)
		if !response.present || mcp_spec_content_text(response) != 'output for ${tool.name}' {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "passes tool arguments as argv when spawning brew" do` at line 156.
pub fn ruby_mcp_server_spec_l156_d26_passes(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_tools_call('search', {
		'text_or_regex': brew_runtime.string_value('visual studio;beta')
	})
	return brew_runtime.bool_value(mcp_spec_content_text(response) == 'output for search' && homebrew.mcp_tool_command_arguments('search', {
		'text_or_regex': brew_runtime.string_value('visual studio;beta')
	}) == ['visual studio;beta'])
}

// Ruby it `it "rejects an inline cask definition argument without spawning brew" do` at line 172.
pub fn ruby_mcp_server_spec_l172_d27_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_tools_call('info', {
		'formula_or_cask': brew_runtime.string_value('cask "evil" do\n  url "https://example.com"\nend')
	})
	return brew_runtime.bool_value(mcp_spec_error(response) == 'Invalid formula or cask argument')
}

// Ruby it `it "responds to tools/call for unknown tool" do` at line 186.
pub fn ruby_mcp_server_spec_l186_d28_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_tools_call('not_a_tool', map[string]brew_runtime.Value{})
	return brew_runtime.bool_value(mcp_spec_error(response) == 'Unknown tool')
}

// Ruby it `it "responds with error for unknown method" do` at line 192.
pub fn ruby_mcp_server_spec_l192_d29_responds(args ...brew_runtime.Value) brew_runtime.Value {
	response := mcp_spec_handle('not_a_method', brew_runtime.map_value(map[string]brew_runtime.Value{}))
	return brew_runtime.bool_value(mcp_spec_error(response) == 'Method not found')
}

// Ruby it `it "returns nil if id is nil" do` at line 198.
pub fn ruby_mcp_server_spec_l198_d30_returns(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	response := homebrew.mcp_handle_request(mut server, mcp_spec_request('initialize', brew_runtime.map_value(map[string]brew_runtime.Value{}), false), mcp_spec_runner) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!response.present)
}

// Ruby it `it "returns nil if id is nil" do` at line 205.
pub fn ruby_mcp_server_spec_l205_d31_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(!homebrew.mcp_respond_result(none, brew_runtime.map_value(map[string]brew_runtime.Value{})).present)
}

// Ruby it `it "returns a result hash if id is present" do` at line 209.
pub fn ruby_mcp_server_spec_l209_d32_returns(args ...brew_runtime.Value) brew_runtime.Value {
	response := homebrew.mcp_respond_result(brew_runtime.int_value(42), brew_runtime.map_value({
		'foo': brew_runtime.string_value('bar')
	}))
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	foo := result.map_data['foo'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(response.present && foo.as_string() == 'bar')
}

// Ruby it `it "returns an error hash" do` at line 216.
pub fn ruby_mcp_server_spec_l216_d33_returns(args ...brew_runtime.Value) brew_runtime.Value {
	response := homebrew.mcp_respond_error(brew_runtime.int_value(42), 'fail')
	error_value := response.value.map_data['error'] or { return brew_runtime.bool_value(false) }
	code := error_value.map_data['code'] or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(mcp_spec_error(response) == 'fail' && code.int_data == homebrew.mcp_error_code)
}

// Ruby it `it "preserves search text as a single raw argv argument" do` at line 223.
pub fn ruby_mcp_server_spec_l223_d34_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	arguments := homebrew.mcp_tool_command_arguments('search', {
		'text_or_regex': brew_runtime.string_value('visual studio;beta')
	})
	return brew_runtime.bool_value(arguments == ['visual studio;beta'])
}

// Ruby let `let(:sleep_time) { 0.001 }` at line 231.
pub fn ruby_mcp_server_spec_l231_d35_sleep_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.float_value(0.001)
}

// Ruby it `it "runs the loop and exits cleanly on interrupt" do` at line 233.
pub fn ruby_mcp_server_spec_l233_d36_runs(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server(['--debug'], ['{"id":42,"method":"ping"}'], '/brew', '4.0.0')
	homebrew.mcp_run(mut server, mcp_spec_runner)
	return brew_runtime.bool_value(server.exit_code == 0 && server.stderr_lines.join('').contains('Response: {'))
}

// Ruby it `it "runs the loop and logs 'Response: nil' when handle_request returns nil" do` at line 251.
pub fn ruby_mcp_server_spec_l251_d37_runs(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server(['--debug'], [
		'{"id":42,"method":"notifications/initialized"}',
	], '/brew', '4.0.0')
	homebrew.mcp_run(mut server, mcp_spec_runner)
	return brew_runtime.bool_value(server.exit_code == 0 && server.stderr_lines.join('').contains('Response: nil'))
}

// Ruby it `it "exits on Interrupt" do` at line 269.
pub fn ruby_mcp_server_spec_l269_d38_exits(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	server.interrupt_on_read = true
	homebrew.mcp_run(mut server, mcp_spec_runner)
	return brew_runtime.bool_value(server.exit_code == 0)
}

// Ruby it `it "exits on error" do` at line 280.
pub fn ruby_mcp_server_spec_l280_d39_exits(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	server.read_error = 'fail'
	homebrew.mcp_run(mut server, mcp_spec_runner)
	return brew_runtime.bool_value(server.exit_code == 1 && server.stderr_lines.join('').contains('Error: fail'))
}

fn mcp_spec_runner(_executable string, arguments []string) !homebrew.McpCommandExecution {
	name := if arguments.len > 0 { arguments[0] } else { '' }
	return homebrew.McpCommandExecution{
		output: 'output for ${name}'
		chunks: [
			'output for ${name}',
		]
	}
}

fn mcp_spec_request(method string, params brew_runtime.Value, with_id bool) brew_runtime.Value {
	mut values := {
		'method': brew_runtime.string_value(method)
		'params': params
	}
	if with_id {
		values['id'] = brew_runtime.int_value(42)
	}
	return brew_runtime.map_value(values)
}

fn mcp_spec_handle(method string, params brew_runtime.Value) homebrew.McpResponse {
	mut server := homebrew.new_mcp_server([], [], '/brew', '4.0.0')
	return homebrew.mcp_handle_request(mut server, mcp_spec_request(method, params, true), mcp_spec_runner) or { homebrew.McpResponse{} }
}

fn mcp_spec_result_array_empty(method string, key string) brew_runtime.Value {
	response := mcp_spec_handle(method, brew_runtime.map_value(map[string]brew_runtime.Value{}))
	if !response.present {
		return brew_runtime.bool_value(false)
	}
	result := response.value.map_data['result'] or { return brew_runtime.bool_value(false) }
	entries_value := result.map_data[key] or { return brew_runtime.bool_value(false) }
	entries := entries_value.as_array() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(entries.len == 0)
}

fn mcp_spec_notification(method string) brew_runtime.Value {
	return brew_runtime.bool_value(!mcp_spec_handle(method, brew_runtime.map_value(map[string]brew_runtime.Value{})).present)
}

fn mcp_spec_tools_call(name string, arguments map[string]brew_runtime.Value) homebrew.McpResponse {
	return mcp_spec_handle('tools/call', brew_runtime.map_value({
		'name':      brew_runtime.string_value(name)
		'arguments': brew_runtime.map_value(arguments)
	}))
}

fn mcp_spec_content_text(response homebrew.McpResponse) string {
	if !response.present {
		return ''
	}
	content := response.value.map_data['result'] or { return '' }
	items := (content.map_data['content'] or { return '' }).as_array() or { return '' }
	if items.len == 0 {
		return ''
	}
	return (items[0].map_data['text'] or { return '' }).as_string()
}

fn mcp_spec_error(response homebrew.McpResponse) string {
	if !response.present {
		return ''
	}
	error_value := response.value.map_data['error'] or { return '' }
	return (error_value.map_data['message'] or { return '' }).as_string()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "mcp_server"
// 5: require "stringio"
// 6: require "timeout"
// 7:
// 8: RSpec.describe Homebrew::McpServer do
// 9:   let(:stdin) { StringIO.new }
// 10:   let(:stdout) { StringIO.new }
// 11:   let(:stderr) { StringIO.new }
// 12:   let(:server) { described_class.new(stdin:, stdout:, stderr:) }
// 13:   let(:jsonrpc) { Homebrew::McpServer::JSON_RPC_VERSION }
// 14:   let(:id) { Random.rand(1000) }
// 15:   let(:code) { Homebrew::McpServer::ERROR_CODE }
// 16:
// 17:   describe "#initialize" do
// 18:     it "sets debug_logging to false by default" do
// 19:       expect(server.debug_logging?).to be(false)
// 20:     end
// 21:
// 22:     it "sets debug_logging to true if --debug is in ARGV" do
// 23:       stub_const("ARGV", ["--debug"])
// 24:       expect(server.debug_logging?).to be(true)
// 25:     end
// 26:
// 27:     it "sets debug_logging to true if -d is in ARGV" do
// 28:       stub_const("ARGV", ["-d"])
// 29:       expect(server.debug_logging?).to be(true)
// 30:     end
// 31:   end
// 32:
// 33:   describe "#debug and #log" do
// 34:     it "logs debug output when debug_logging is true" do
// 35:       stub_const("ARGV", ["--debug"])
// 36:       server.debug("foo")
// 37:       expect(stderr.string).to include("foo")
// 38:     end
// 39:
// 40:     it "does not log debug output when debug_logging is false" do
// 41:       server.debug("foo")
// 42:       expect(stderr.string).to eq("")
// 43:     end
// 44:
// 45:     it "logs to stderr" do
// 46:       server.log("bar")
// 47:       expect(stderr.string).to include("bar")
// 48:     end
// 49:   end
// 50:
// 51:   describe "#handle_request" do
// 52:     it "responds to initialize method" do
// 53:       request = { "id" => id, "method" => "initialize" }
// 54:       result = server.handle_request(request)
// 55:       expect(result).to eq({
// 56:         jsonrpc:,
// 57:         id:,
// 58:         result:  {
// 59:           protocolVersion: Homebrew::McpServer::MCP_PROTOCOL_VERSION,
// 60:           capabilities:    {
// 61:             tools:     { listChanged: false },
// 62:             prompts:   {},
// 63:             resources: {},
// 64:             logging:   {},
// 65:             roots:     {},
// 66:           },
// 67:           serverInfo:      Homebrew::McpServer::SERVER_INFO,
// 68:         },
// 69:       })
// 70:     end
// 71:
// 72:     it "responds to resources/list" do
// 73:       request = { "id" => id, "method" => "resources/list" }
// 74:       result = server.handle_request(request)
// 75:       expect(result).to eq({ jsonrpc:, id:, result: { resources: [] } })
// 76:     end
// 77:
// 78:     it "responds to resources/templates/list" do
// 79:       request = { "id" => id, "method" => "resources/templates/list" }
// 80:       result = server.handle_request(request)
// 81:       expect(result).to eq({ jsonrpc:, id:, result: { resourceTemplates: [] } })
// 82:     end
// 83:
// 84:     it "responds to prompts/list" do
// 85:       request = { "id" => id, "method" => "prompts/list" }
// 86:       result = server.handle_request(request)
// 87:       expect(result).to eq({ jsonrpc:, id:, result: { prompts: [] } })
// 88:     end
// 89:
// 90:     it "responds to ping" do
// 91:       request = { "id" => id, "method" => "ping" }
// 92:       result = server.handle_request(request)
// 93:       expect(result).to eq({ jsonrpc:, id:, result: {} })
// 94:     end
// 95:
// 96:     it "responds to get_server_info" do
// 97:       request = { "id" => id, "method" => "get_server_info" }
// 98:       result = server.handle_request(request)
// 99:       expect(result).to eq({ jsonrpc:, id:, result: Homebrew::McpServer::SERVER_INFO })
// 100:     end
// 101:
// 102:     it "responds to logging/setLevel with debug" do
// 103:       request = { "id" => id, "method" => "logging/setLevel", "params" => { "level" => "debug" } }
// 104:       result = server.handle_request(request)
// 105:       expect(server.debug_logging?).to be(true)
// 106:       expect(result).to eq({ jsonrpc:, id:, result: {} })
// 107:     end
// 108:
// 109:     it "responds to logging/setLevel with non-debug" do
// 110:       request = { "id" => id, "method" => "logging/setLevel", "params" => { "level" => "info" } }
// 111:       result = server.handle_request(request)
// 112:       expect(server.debug_logging?).to be(false)
// 113:       expect(result).to eq({ jsonrpc:, id:, result: {} })
// 114:     end
// 115:
// 116:     it "responds to notifications/initialized" do
// 117:       request = { "id" => id, "method" => "notifications/initialized" }
// 118:       expect(server.handle_request(request)).to be_nil
// 119:     end
// 120:
// 121:     it "responds to notifications/cancelled" do
// 122:       request = { "id" => id, "method" => "notifications/cancelled" }
// 123:       expect(server.handle_request(request)).to be_nil
// 124:     end
// 125:
// 126:     it "responds to tools/list" do
// 127:       request = { "id" => id, "method" => "tools/list" }
// 128:       result = server.handle_request(request)
// 129:       expect(result[:result][:tools]).to match_array(Homebrew::McpServer::TOOLS.values)
// 130:     end
// 131:
// 132:     test_each(Homebrew::McpServer::TOOLS) do |(tool_name, tool_definition)|
// 133:       it "responds to tools/call for #{tool_name}" do
// 134:         allow(Open3).to receive(:popen2e).and_return("output for #{tool_name}")
// 135:         arguments = {}
// 136:         Array(tool_definition[:required]).each do |required_key|
// 137:           arguments[required_key] = "dummy"
// 138:         end
// 139:         request = {
// 140:           "id"     => id,
// 141:           "method" => "tools/call",
// 142:           "params" => {
// 143:             "name"      => tool_name.to_s,
// 144:             "arguments" => arguments,
// 145:           },
// 146:         }
// 147:         result = server.handle_request(request)
// 148:         expect(result).to eq({
// 149:           jsonrpc: jsonrpc,
// 150:           id:      id,
// 151:           result:  { content: [{ type: "text", text: "output for #{tool_name}" }] },
// 152:         })
// 153:       end
// 154:     end
// 155:
// 156:     it "passes tool arguments as argv when spawning brew" do
// 157:       expect(Open3).to receive(:popen2e)
// 158:         .with(Homebrew::McpServer::HOMEBREW_BREW_FILE, "search", "visual studio;beta")
// 159:         .and_return("output")
// 160:       request = {
// 161:         "id"     => id,
// 162:         "method" => "tools/call",
// 163:         "params" => {
// 164:           "name"      => "search",
// 165:           "arguments" => { "text_or_regex" => "visual studio;beta" },
// 166:         },
// 167:       }
// 168:
// 169:       server.handle_request(request)
// 170:     end
// 171:
// 172:     it "rejects an inline cask definition argument without spawning brew" do
// 173:       expect(Open3).not_to receive(:popen2e)
// 174:       request = {
// 175:         "id"     => id,
// 176:         "method" => "tools/call",
// 177:         "params" => {
// 178:           "name"      => "info",
// 179:           "arguments" => { "formula_or_cask" => %Q(cask "evil" do\n  url "https://example.com"\nend) },
// 180:         },
// 181:       }
// 182:       result = server.handle_request(request)
// 183:       expect(result).to eq({ jsonrpc:, id:, error: { message: "Invalid formula or cask argument", code: } })
// 184:     end
// 185:
// 186:     it "responds to tools/call for unknown tool" do
// 187:       request = { "id" => id, "method" => "tools/call", "params" => { "name" => "not_a_tool", "arguments" => {} } }
// 188:       result = server.handle_request(request)
// 189:       expect(result).to eq({ jsonrpc:, id:, error: { message: "Unknown tool", code: } })
// 190:     end
// 191:
// 192:     it "responds with error for unknown method" do
// 193:       request = { "id" => id, "method" => "not_a_method" }
// 194:       result = server.handle_request(request)
// 195:       expect(result).to eq({ jsonrpc:, id:, error: { message: "Method not found", code: } })
// 196:     end
// 197:
// 198:     it "returns nil if id is nil" do
// 199:       request = { "method" => "initialize" }
// 200:       expect(server.handle_request(request)).to be_nil
// 201:     end
// 202:   end
// 203:
// 204:   describe "#respond_result" do
// 205:     it "returns nil if id is nil" do
// 206:       expect(server.respond_result(nil, {})).to be_nil
// 207:     end
// 208:
// 209:     it "returns a result hash if id is present" do
// 210:       result = server.respond_result(id, { foo: "bar" })
// 211:       expect(result).to eq({ jsonrpc:, id:, result: { foo: "bar" } })
// 212:     end
// 213:   end
// 214:
// 215:   describe "#respond_error" do
// 216:     it "returns an error hash" do
// 217:       result = server.respond_error(id, "fail")
// 218:       expect(result).to eq({ jsonrpc:, id:, error: { message: "fail", code: } })
// 219:     end
// 220:   end
// 221:
// 222:   describe "#tool_command_arguments" do
// 223:     it "preserves search text as a single raw argv argument" do
// 224:       arguments = { "text_or_regex" => "visual studio;beta" }
// 225:
// 226:       expect(server.tool_command_arguments(:search, arguments)).to eq(["visual studio;beta"])
// 227:     end
// 228:   end
// 229:
// 230:   describe "#run" do
// 231:     let(:sleep_time) { 0.001 }
// 232:
// 233:     it "runs the loop and exits cleanly on interrupt" do
// 234:       stub_const("ARGV", ["--debug"])
// 235:       stdin.puts({ id:, method: "ping" }.to_json)
// 236:       stdin.rewind
// 237:       server_thread = Thread.new do
// 238:         server.run
// 239:       rescue SystemExit
// 240:         # expected, do nothing
// 241:       end
// 242:
// 243:       response_hash_string = "Response: {"
// 244:       sleep(sleep_time)
// 245:       server_thread.raise(Interrupt)
// 246:       server_thread.join
// 247:
// 248:       expect(stderr.string).to include(response_hash_string)
// 249:     end
// 250:
// 251:     it "runs the loop and logs 'Response: nil' when handle_request returns nil" do
// 252:       stub_const("ARGV", ["--debug"])
// 253:       stdin.puts({ id:, method: "notifications/initialized" }.to_json)
// 254:       stdin.rewind
// 255:       server_thread = Thread.new do
// 256:         server.run
// 257:       rescue SystemExit
// 258:         # expected, do nothing
// 259:       end
// 260:
// 261:       response_nil_string = "Response: nil"
// 262:       sleep(sleep_time)
// 263:       server_thread.raise(Interrupt)
// 264:       server_thread.join
// 265:
// 266:       expect(stderr.string).to include(response_nil_string)
// 267:     end
// 268:
// 269:     it "exits on Interrupt" do
// 270:       stdin.puts
// 271:       stdin.rewind
// 272:       allow(stdin).to receive(:gets).and_raise(Interrupt)
// 273:       expect do
// 274:         server.run
// 275:       rescue
// 276:         SystemExit
// 277:       end.to raise_error(SystemExit)
// 278:     end
// 279:
// 280:     it "exits on error" do
// 281:       stdin.puts
// 282:       stdin.rewind
// 283:       allow(stdin).to receive(:gets).and_raise(StandardError, "fail")
// 284:       expect do
// 285:         server.run
// 286:       rescue
// 287:         SystemExit
// 288:       end.to raise_error(SystemExit)
// 289:       expect(stderr.string).to include("Error: fail")
// 290:     end
// 291:   end
// 292: end
