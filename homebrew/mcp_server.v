module homebrew

import brew_runtime

// Translated from Homebrew/brew `mcp_server.rb`.
// The original source is retained below until every stub has a typed V body.
pub const mcp_json_rpc_version = '2.0'
pub const mcp_protocol_version = '2025-03-26'
pub const mcp_error_code = i64(-32601)

pub struct McpTool {
pub:
	name         string
	description  string
	command      string
	input_schema brew_runtime.Value
	required     []string
}

pub struct McpCommandExecution {
pub:
	output string
	chunks []string
}

pub type McpCommandRunner = fn(string, []string) !McpCommandExecution

pub struct McpServerState {
pub:
	brew_file string
	version   string
pub mut:
	debug_logging     bool
	ping_switch       bool
	stdin_lines       []string
	stdout_lines      []string
	stderr_lines      []string
	exit_code         int
	interrupt_on_read bool
	read_error        string
}

pub struct McpResponse {
pub:
	present bool
	value   brew_runtime.Value
}

fn mcp_string_property(description string) brew_runtime.Value {
	return brew_runtime.map_value({
		'type':        brew_runtime.string_value('string')
		'description': brew_runtime.string_value(description)
	})
}

fn mcp_boolean_property(description string) brew_runtime.Value {
	return brew_runtime.map_value({
		'type':        brew_runtime.string_value('boolean')
		'description': brew_runtime.string_value(description)
	})
}

fn mcp_schema(properties map[string]brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.map_value({
		'type':       brew_runtime.string_value('object')
		'properties': brew_runtime.map_value(properties)
	})
}

pub fn mcp_tools() []McpTool {
	formula_or_cask := {
		'formula_or_cask': mcp_string_property('Formula or cask name')
	}
	return [
		McpTool{
			name: 'search'
			description: 'Perform a substring search of cask tokens and formula names for <text>. If <text> is flanked by slashes, it is interpreted as a regular expression.'
			command: 'brew search'
			input_schema: mcp_schema({
				'text_or_regex': mcp_string_property('Text or regex to search for')
			})
			required: ['text_or_regex']
		},
		McpTool{
			name: 'info'
			description: 'Display brief statistics for your Homebrew installation. If a <formula> or <cask> is provided, show summary of information about it.'
			command: 'brew info'
			input_schema: mcp_schema(formula_or_cask)
		},
		McpTool{
			name: 'install'
			description: 'Install a <formula> or <cask>.'
			command: 'brew install'
			input_schema: mcp_schema(formula_or_cask)
			required: ['formula_or_cask']
		},
		McpTool{
			name: 'update'
			description: 'Fetch the newest version of Homebrew and all formulae from GitHub using `git` and perform any necessary migrations.'
			command: 'brew update'
			input_schema: mcp_schema(map[string]brew_runtime.Value{})
		},
		McpTool{
			name: 'upgrade'
			description: 'Upgrade outdated, unpinned packages using the same options they were originally installed with, plus any appended brew formula options. If <cask> or <formula> are specified, upgrade only the given <cask> or <formula> (unless they are pinned).'
			command: 'brew upgrade'
			input_schema: mcp_schema(formula_or_cask)
		},
		McpTool{
			name: 'uninstall'
			description: 'Uninstall a <formula> or <cask>.'
			command: 'brew uninstall'
			input_schema: mcp_schema(formula_or_cask)
			required: ['formula_or_cask']
		},
		McpTool{
			name: 'list'
			description: 'List all installed formulae and casks. If <formula> is provided, summarise the paths within its current keg. If <cask> is provided, list its artifacts.'
			command: 'brew list'
			input_schema: mcp_schema(formula_or_cask)
		},
		McpTool{
			name: 'config'
			description: 'Show Homebrew and system configuration info useful for debugging. If you file a bug report, you will be required to provide this information.'
			command: 'brew config'
			input_schema: mcp_schema(map[string]brew_runtime.Value{})
		},
		McpTool{
			name: 'doctor'
			description: "Check your system for potential problems. Will exit with a non-zero status if any potential problems are found. Please note that these warnings are just used to help the Homebrew maintainers with debugging if you file an issue. If everything you use Homebrew for is working fine: please don't worry or file an issue; just ignore this."
			command: 'brew doctor'
			input_schema: mcp_schema(map[string]brew_runtime.Value{})
		},
		McpTool{
			name: 'typecheck'
			description: 'Check for typechecking errors using Sorbet.'
			command: 'brew typecheck'
			input_schema: mcp_schema(map[string]brew_runtime.Value{})
		},
		McpTool{
			name: 'style'
			description: 'Check formulae or files for conformance to Homebrew style guidelines.'
			command: 'brew style'
			input_schema: mcp_schema({
				'fix':     mcp_boolean_property("Fix style violations automatically using RuboCop's auto-correct feature")
				'files':   mcp_string_property('Specific files to check (space-separated)')
				'changed': mcp_boolean_property('Only check files that were changed from the `main` branch')
			})
		},
		McpTool{
			name: 'tests'
			description: "Run Homebrew's unit and integration tests."
			command: 'brew tests'
			input_schema: mcp_schema({
				'only':      mcp_string_property('Specific tests to run (comma-separated) e.g. for `<file>_spec.rb` pass `<file>`. Appending `:<line_number>` will start at a specific line')
				'fail_fast': mcp_boolean_property('Exit early on the first failing test')
				'changed':   mcp_boolean_property('Only runs tests on files that were changed from the `main` branch')
				'online':    mcp_boolean_property('Run online tests')
			})
		},
		McpTool{
			name: 'commands'
			description: 'Show lists of built-in and external commands.'
			command: 'brew commands'
			input_schema: mcp_schema(map[string]brew_runtime.Value{})
		},
		McpTool{
			name: 'help'
			description: 'Outputs the usage instructions for `brew` <command>.'
			command: 'brew help'
			input_schema: mcp_schema({
				'command': mcp_string_property('Command to get help for')
			})
		},
	]
}

fn mcp_tool_value(tool McpTool) brew_runtime.Value {
	mut values := {
		'name':        brew_runtime.string_value(tool.name)
		'description': brew_runtime.string_value(tool.description)
		'command':     brew_runtime.string_value(tool.command)
		'inputSchema': tool.input_schema
	}
	if tool.required.len > 0 {
		values['required'] = brew_runtime.string_array_value(tool.required)
	}
	return brew_runtime.map_value(values)
}

pub fn new_mcp_server(argv []string, stdin_lines []string, brew_file string,
	version string) McpServerState {
	return McpServerState{
		brew_file: if brew_file == '' {
			brew_runtime.environment_value('HOMEBREW_BREW_FILE')} else {
			brew_file}
		version: if version == '' {
			brew_runtime.environment_value('HOMEBREW_VERSION')} else {
			version}
		debug_logging: '--debug' in argv || '-d' in argv
		ping_switch: '--ping' in argv
		stdin_lines: stdin_lines.clone()
	}
}

pub fn mcp_server_info(version string) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':    brew_runtime.string_value('brew-mcp-server')
		'version': brew_runtime.string_value(version)
	})
}

pub fn mcp_debug(mut server McpServerState, text string) {
	if server.debug_logging {
		mcp_log(mut server, text)
	}
}

pub fn mcp_log(mut server McpServerState, text string) {
	server.stderr_lines << '${text}\n'
}

fn mcp_response(id brew_runtime.Value, key string, payload brew_runtime.Value) brew_runtime.Value {
	mut values := {
		'jsonrpc': brew_runtime.string_value(mcp_json_rpc_version)
		'id':      id
	}
	values[key] = payload
	return brew_runtime.map_value(values)
}

pub fn mcp_respond_result(id ?brew_runtime.Value, result brew_runtime.Value) McpResponse {
	response_id := id or { return McpResponse{} }
	return McpResponse{
		present: true
		value: mcp_response(response_id, 'result', result)
	}
}

pub fn mcp_respond_error(id brew_runtime.Value, message string) McpResponse {
	return McpResponse{
		present: true
		value: mcp_response(id, 'error', brew_runtime.map_value({
			'code':    brew_runtime.int_value(mcp_error_code)
			'message': brew_runtime.string_value(message)
		}))
	}
}

fn mcp_bool(arguments map[string]brew_runtime.Value, key string) bool {
	value := arguments[key] or { return false }
	return value.type_name == 'Bool' && value.bool_data
}

pub fn mcp_tool_command_arguments(tool_name string,
	arguments map[string]brew_runtime.Value) []string {
	match tool_name {
		'style' {
			mut output := []string{}
			if mcp_bool(arguments, 'fix') { output << '--fix' }
			if mcp_bool(arguments, 'changed') { output << '--changed' }
			files := (arguments['files'] or { brew_runtime.string_value('') }).as_string().trim_space()
			if files != '' { output << files.fields() }
			return output
		}
		'tests' {
			mut output := []string{}
			only := (arguments['only'] or { brew_runtime.string_value('') }).as_string().trim_space()
			if only != '' { output << '--only=${only}' }
			if mcp_bool(arguments, 'fail_fast') { output << '--fail-fast' }
			if mcp_bool(arguments, 'changed') { output << '--changed' }
			if mcp_bool(arguments, 'online') { output << '--online' }
			return output
		}
		'search' {
			return [
				(arguments['text_or_regex'] or { brew_runtime.string_value('') }).as_string(),
			].filter(it != '')
		}
		'help' {
			return [
				(arguments['command'] or { brew_runtime.string_value('') }).as_string(),
			].filter(it != '')
		}
		else {
			return [
				(arguments['formula_or_cask'] or { brew_runtime.string_value('') }).as_string(),
			].filter(it != '')
		}
	}
}

fn mcp_inline_cask_definition(value string) bool {
	trimmed := value.trim_space()
	if !trimmed.starts_with('cask') || trimmed.len <= 4 {
		return false
	}
	remainder := trimmed[4..].trim_space()
	return remainder.len > 0 && remainder[0] in [`'`, `"`, `(`]
}

fn mcp_default_command_runner(executable string, arguments []string) !McpCommandExecution {
	result := brew_runtime.run_command(executable, arguments)
	return McpCommandExecution{ output: result.output, chunks: [result.output] }
}

pub fn mcp_respond_to_tools_call(mut server McpServerState, id brew_runtime.Value,
	request brew_runtime.Value, runner McpCommandRunner) !McpResponse {
	request_values := request.map_data.clone()
	params_value := request_values['params'] or { return mcp_respond_error(id, 'Unknown tool') }
	params := params_value.map_data.clone()
	tool_name := (params['name'] or { brew_runtime.string_value('') }).as_string()
	tool := mcp_tools().filter(it.name == tool_name)
	if tool.len == 0 {
		return mcp_respond_error(id, 'Unknown tool')
	}
	arguments_value := params['arguments'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }
	arguments := arguments_value.map_data.clone()
	formula_or_cask := (arguments['formula_or_cask'] or { brew_runtime.string_value('') }).as_string()
	if formula_or_cask != '' && mcp_inline_cask_definition(formula_or_cask) {
		return mcp_respond_error(id, 'Invalid formula or cask argument')
	}
	command_arguments := mcp_tool_command_arguments(tool_name, arguments)
	brew_command := tool[0].command.trim_string_left('brew ')
	mut brew_arguments := [brew_command]
	brew_arguments << command_arguments
	execution := runner(server.brew_file, brew_arguments)!
	progress_token := if meta_value := params['_meta'] {
		(meta_value.map_data['progressToken'] or { brew_runtime.Value{} }).as_string()
	} else {
		''
	}
	if progress_token != '' {
		chunks := if execution.chunks.len > 0 {
			execution.chunks
		} else {
			[
				execution.output,
			]
		}
		for index, chunk in chunks {
			if chunk == '' {
				continue
			}
			progress := brew_runtime.map_value({
				'jsonrpc': brew_runtime.string_value(mcp_json_rpc_version)
				'method':  brew_runtime.string_value('notifications/progress')
				'params':  brew_runtime.map_value({
					'progressToken': brew_runtime.string_value(progress_token)
					'progress':      brew_runtime.int_value(index + 1)
				})
			})
			server.stdout_lines << brew_runtime.json_value_to_string(progress)
		}
	}
	return mcp_respond_result(id, brew_runtime.map_value({
		'content': brew_runtime.array_value([
			brew_runtime.map_value({
				'type': brew_runtime.string_value('text')
				'text': brew_runtime.string_value(execution.output)
			}),
		])
	}))
}

pub fn mcp_handle_request(mut server McpServerState, request brew_runtime.Value,
	runner McpCommandRunner) !McpResponse {
	values := request.map_data.clone()
	id := values['id'] or { return McpResponse{} }
	if id.type_name == 'NilClass' || id.type_name == '' {
		return McpResponse{}
	}
	method := (values['method'] or { brew_runtime.string_value('') }).as_string()
	match method {
		'initialize' {
			return mcp_respond_result(id, brew_runtime.map_value({
				'protocolVersion': brew_runtime.string_value(mcp_protocol_version)
				'capabilities':    brew_runtime.map_value({
					'tools':     brew_runtime.map_value({
						'listChanged': brew_runtime.bool_value(false)
					})
					'prompts':   brew_runtime.map_value(map[string]brew_runtime.Value{})
					'resources': brew_runtime.map_value(map[string]brew_runtime.Value{})
					'logging':   brew_runtime.map_value(map[string]brew_runtime.Value{})
					'roots':     brew_runtime.map_value(map[string]brew_runtime.Value{})
				})
				'serverInfo':      mcp_server_info(server.version)
			}))
		}
		'resources/list' {
			return mcp_respond_result(id, brew_runtime.map_value({
				'resources': brew_runtime.array_value([])
			}))
		}
		'resources/templates/list' {
			return mcp_respond_result(id, brew_runtime.map_value({
				'resourceTemplates': brew_runtime.array_value([])
			}))
		}
		'prompts/list' {
			return mcp_respond_result(id, brew_runtime.map_value({
				'prompts': brew_runtime.array_value([])
			}))
		}
		'ping' {
			return mcp_respond_result(id, brew_runtime.map_value(map[string]brew_runtime.Value{}))
		}
		'get_server_info' {
			return mcp_respond_result(id, mcp_server_info(server.version))
		}
		'logging/setLevel' {
			params := (values['params'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).map_data.clone()
			server.debug_logging = (params['level'] or { brew_runtime.string_value('') }).as_string() == 'debug'
			return mcp_respond_result(id, brew_runtime.map_value(map[string]brew_runtime.Value{}))
		}
		'notifications/initialized', 'notifications/cancelled' {
			return McpResponse{}
		}
		'tools/list' {
			return mcp_respond_result(id, brew_runtime.map_value({
				'tools': brew_runtime.array_value(mcp_tools().map(mcp_tool_value(it)))
			}))
		}
		'tools/call' {
			return mcp_respond_to_tools_call(mut server, id, request, runner)!
		}
		else {
			return mcp_respond_error(id, 'Method not found')
		}
	}
}

pub fn mcp_run(mut server McpServerState, runner McpCommandRunner) {
	mcp_log(mut server, '==> Started Homebrew MCP server...')
	if server.interrupt_on_read {
		server.exit_code = 0
		return
	}
	if server.read_error != '' {
		mcp_log(mut server, 'Error: ${server.read_error}')
		server.exit_code = 1
		return
	}
	mut inputs := server.stdin_lines.clone()
	if server.ping_switch {
		inputs = ['{"jsonrpc":"2.0","id":1,"method":"ping"}']
	}
	for input in inputs {
		if input.trim_space() == '' {
			continue
		}
		request := brew_runtime.parse_json_value(input) or {
			mcp_log(mut server, 'Error: ${err.msg()}')
			server.exit_code = 1
			return
		}
		mcp_debug(mut server, 'Request: ${brew_runtime.json_value_to_string(request)}')
		response := mcp_handle_request(mut server, request, runner) or {
			mcp_log(mut server, 'Error: ${err.msg()}')
			server.exit_code = 1
			return
		}
		if !response.present {
			mcp_debug(mut server, 'Response: nil')
			continue
		}
		mcp_debug(mut server, 'Response: ${brew_runtime.json_value_to_string(response.value)}')
		server.stdout_lines << brew_runtime.json_value_to_string(response.value)
		if server.ping_switch {
			break
		}
	}
}

pub fn mcp_server_state_value(server McpServerState) brew_runtime.Value {
	return brew_runtime.map_value({
		'brew_file':         brew_runtime.string_value(server.brew_file)
		'version':           brew_runtime.string_value(server.version)
		'debug_logging':     brew_runtime.bool_value(server.debug_logging)
		'ping_switch':       brew_runtime.bool_value(server.ping_switch)
		'stdin':             brew_runtime.string_array_value(server.stdin_lines)
		'stdout':            brew_runtime.string_array_value(server.stdout_lines)
		'stderr':            brew_runtime.string_array_value(server.stderr_lines)
		'exit_code':         brew_runtime.int_value(server.exit_code)
		'interrupt_on_read': brew_runtime.bool_value(server.interrupt_on_read)
		'read_error':        brew_runtime.string_value(server.read_error)
	})
}

fn mcp_server_state_from_value(value brew_runtime.Value) McpServerState {
	values := value.map_data.clone()
	return McpServerState{
		brew_file: (values['brew_file'] or { brew_runtime.string_value('brew') }).as_string()
		version: (values['version'] or { brew_runtime.string_value('') }).as_string()
		debug_logging: (values['debug_logging'] or { brew_runtime.bool_value(false) }).bool_data
		ping_switch: (values['ping_switch'] or { brew_runtime.bool_value(false) }).bool_data
		stdin_lines: (values['stdin'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		stdout_lines: (values['stdout'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		stderr_lines: (values['stderr'] or { brew_runtime.string_array_value([]) }).as_string_array() or { []string{} }
		exit_code: int((values['exit_code'] or { brew_runtime.int_value(0) }).int_data)
		interrupt_on_read: (values['interrupt_on_read'] or { brew_runtime.bool_value(false) }).bool_data
		read_error: (values['read_error'] or { brew_runtime.string_value('') }).as_string()
	}
}

// Ruby method `initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)` at line 194.
pub fn ruby_mcp_server_l194_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	argv := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	stdin_lines := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return mcp_server_state_value(new_mcp_server(argv, stdin_lines, if args.len > 2 {
		args[2].as_string()
	} else {
		''
	}, if args.len > 3 { args[3].as_string() } else { '' }))
}

// Ruby method `debug_logging? = @debug_logging` at line 203.
pub fn ruby_mcp_server_l203_d2_debug_logging(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && mcp_server_state_from_value(args[0]).debug_logging)
}

// Ruby method `ping_switch? = @ping_switch` at line 206.
pub fn ruby_mcp_server_l206_d3_ping_switch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && mcp_server_state_from_value(args[0]).ping_switch)
}

// Ruby method `run` at line 209.
pub fn ruby_mcp_server_l209_d4_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := mcp_server_state_from_value(args[0] or { mcp_server_state_value(new_mcp_server([], [], '', '')) })
	mcp_run(mut server, mcp_default_command_runner)
	return mcp_server_state_value(server)
}

// Ruby method `debug(text)` at line 246.
pub fn ruby_mcp_server_l246_d5_debug(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := mcp_server_state_from_value(args[0] or { mcp_server_state_value(new_mcp_server([], [], '', '')) })
	mcp_debug(mut server, if args.len > 1 { args[1].as_string() } else { '' })
	return mcp_server_state_value(server)
}

// Ruby method `log(text)` at line 253.
pub fn ruby_mcp_server_l253_d6_log(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := mcp_server_state_from_value(args[0] or { mcp_server_state_value(new_mcp_server([], [], '', '')) })
	mcp_log(mut server, if args.len > 1 { args[1].as_string() } else { '' })
	return mcp_server_state_value(server)
}

// Ruby method `handle_request(request)` at line 259.
pub fn ruby_mcp_server_l259_d7_handle_request(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := mcp_server_state_from_value(args[0] or { mcp_server_state_value(new_mcp_server([], [], '', '')) })
	response := mcp_handle_request(mut server, args[1] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }, mcp_default_command_runner) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return if response.present {
		response.value
	} else {
		brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby method `respond_to_tools_call(id, request)` at line 301.
pub fn ruby_mcp_server_l301_d8_respond_to_tools_call(args ...brew_runtime.Value) brew_runtime.Value {
	mut server := mcp_server_state_from_value(args[0] or { mcp_server_state_value(new_mcp_server([], [], '', '')) })
	response := mcp_respond_to_tools_call(mut server, args[1] or { brew_runtime.int_value(0) }, args[2] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }, mcp_default_command_runner) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return response.value
}

// Ruby method `tool_command_arguments(tool_name, arguments)` at line 366.
pub fn ruby_mcp_server_l366_d9_tool_command_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	arguments := (args[1] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) }).map_data.clone()
	return brew_runtime.string_array_value(mcp_tool_command_arguments((args[0] or { brew_runtime.string_value('') }).as_string(), arguments))
}

// Ruby method `respond_result(id = nil, result = {})` at line 397.
pub fn ruby_mcp_server_l397_d10_respond_result(args ...brew_runtime.Value) brew_runtime.Value {
	id := if args.len > 0 && args[0].type_name != 'NilClass' {
		?brew_runtime.Value(args[0])
	} else {
		none
	}
	response := mcp_respond_result(id, args[1] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return if response.present {
		response.value
	} else {
		brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby method `respond_error(id, message)` at line 404.
pub fn ruby_mcp_server_l404_d11_respond_error(args ...brew_runtime.Value) brew_runtime.Value {
	return mcp_respond_error(args[0] or { brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' } }, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}).value
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # This is a standalone Ruby script as MCP servers need a faster startup time
// 5: # than a normal Homebrew Ruby command allows.
// 6: require_relative "standalone"
// 7: require "json"
// 8: require "stringio"
// 9:
// 10: module Homebrew
// 11:   # Provides a Model Context Protocol (MCP) server for Homebrew.
// 12:   # See https://modelcontextprotocol.io/introduction for more information.
// 13:   #
// 14:   # https://modelcontextprotocol.io/docs/tools/inspector is useful for testing.
// 15:   class McpServer
// 16:     HOMEBREW_BREW_FILE = T.let(ENV.fetch("HOMEBREW_BREW_FILE").freeze, String)
// 17:     HOMEBREW_VERSION = T.let(ENV.fetch("HOMEBREW_VERSION").freeze, String)
// 18:     JSON_RPC_VERSION = "2.0"
// 19:     MCP_PROTOCOL_VERSION = "2025-03-26"
// 20:     ERROR_CODE = -32601
// 21:
// 22:     # Reject inline `cask ... do`/`cask(...) {}` blocks the cask loader would eval as Ruby.
// 23:     INLINE_CASK_DSL_REGEX = /\A\s*cask\s*['"(]/
// 24:
// 25:     SERVER_INFO = T.let({
// 26:       name:    "brew-mcp-server",
// 27:       version: HOMEBREW_VERSION,
// 28:     }.freeze, T::Hash[Symbol, String])
// 29:
// 30:     FORMULA_OR_CASK_PROPERTIES = T.let({
// 31:       formula_or_cask: {
// 32:         type:        "string",
// 33:         description: "Formula or cask name",
// 34:       },
// 35:     }.freeze, T::Hash[Symbol, T.anything])
// 36:
// 37:     # NOTE: Cursor (as of June 2025) will only query/use a maximum of 40 tools.
// 38:     TOOLS = T.let({
// 39:       search:    {
// 40:         name:        "search",
// 41:         description: "Perform a substring search of cask tokens and formula names for <text>. " \
// 42:                      "If <text> is flanked by slashes, it is interpreted as a regular expression.",
// 43:         command:     "brew search",
// 44:         inputSchema: {
// 45:           type:       "object",
// 46:           properties: {
// 47:             text_or_regex: {
// 48:               type:        "string",
// 49:               description: "Text or regex to search for",
// 50:             },
// 51:           },
// 52:         },
// 53:         required:    ["text_or_regex"],
// 54:       },
// 55:       info:      {
// 56:         name:        "info",
// 57:         description: "Display brief statistics for your Homebrew installation. " \
// 58:                      "If a <formula> or <cask> is provided, show summary of information about it.",
// 59:         command:     "brew info",
// 60:         inputSchema: { type: "object", properties: FORMULA_OR_CASK_PROPERTIES },
// 61:       },
// 62:       install:   {
// 63:         name:        "install",
// 64:         description: "Install a <formula> or <cask>.",
// 65:         command:     "brew install",
// 66:         inputSchema: { type: "object", properties: FORMULA_OR_CASK_PROPERTIES },
// 67:         required:    ["formula_or_cask"],
// 68:       },
// 69:       update:    {
// 70:         name:        "update",
// 71:         description: "Fetch the newest version of Homebrew and all formulae from GitHub using `git` and " \
// 72:                      "perform any necessary migrations.",
// 73:         command:     "brew update",
// 74:         inputSchema: { type: "object", properties: {} },
// 75:       },
// 76:       upgrade:   {
// 77:         name:        "upgrade",
// 78:         description: "Upgrade outdated, unpinned packages using the same options they were originally " \
// 79:                      "installed with, plus any appended brew formula options. If <cask> or <formula> " \
// 80:                      "are specified, upgrade only the given <cask> or <formula> (unless they are pinned).",
// 81:         command:     "brew upgrade",
// 82:         inputSchema: { type: "object", properties: FORMULA_OR_CASK_PROPERTIES },
// 83:       },
// 84:       uninstall: {
// 85:         name:        "uninstall",
// 86:         description: "Uninstall a <formula> or <cask>.",
// 87:         command:     "brew uninstall",
// 88:         inputSchema: { type: "object", properties: FORMULA_OR_CASK_PROPERTIES },
// 89:         required:    ["formula_or_cask"],
// 90:       },
// 91:       list:      {
// 92:         name:        "list",
// 93:         description: "List all installed formulae and casks. " \
// 94:                      "If <formula> is provided, summarise the paths within its current keg. " \
// 95:                      "If <cask> is provided, list its artifacts.",
// 96:         command:     "brew list",
// 97:         inputSchema: { type: "object", properties: FORMULA_OR_CASK_PROPERTIES },
// 98:       },
// 99:       config:    {
// 100:         name:        "config",
// 101:         description: "Show Homebrew and system configuration info useful for debugging. " \
// 102:                      "If you file a bug report, you will be required to provide this information.",
// 103:         command:     "brew config",
// 104:         inputSchema: { type: "object", properties: {} },
// 105:       },
// 106:       doctor:    {
// 107:         name:        "doctor",
// 108:         description: "Check your system for potential problems. Will exit with a non-zero status " \
// 109:                      "if any potential problems are found. " \
// 110:                      "Please note that these warnings are just used to help the Homebrew maintainers " \
// 111:                      "with debugging if you file an issue. If everything you use Homebrew for " \
// 112:                      "is working fine: please don't worry or file an issue; just ignore this.",
// 113:         command:     "brew doctor",
// 114:         inputSchema: { type: "object", properties: {} },
// 115:       },
// 116:       typecheck: {
// 117:         name:        "typecheck",
// 118:         description: "Check for typechecking errors using Sorbet.",
// 119:         command:     "brew typecheck",
// 120:         inputSchema: { type: "object", properties: {} },
// 121:       },
// 122:       style:     {
// 123:         name:        "style",
// 124:         description: "Check formulae or files for conformance to Homebrew style guidelines.",
// 125:         command:     "brew style",
// 126:         inputSchema: {
// 127:           type:       "object",
// 128:           properties: {
// 129:             fix:     {
// 130:               type:        "boolean",
// 131:               description: "Fix style violations automatically using RuboCop's auto-correct feature",
// 132:             },
// 133:             files:   {
// 134:               type:        "string",
// 135:               description: "Specific files to check (space-separated)",
// 136:             },
// 137:             changed: {
// 138:               type:        "boolean",
// 139:               description: "Only check files that were changed from the `main` branch",
// 140:             },
// 141:           },
// 142:         },
// 143:       },
// 144:       tests:     {
// 145:         name:        "tests",
// 146:         description: "Run Homebrew's unit and integration tests.",
// 147:         command:     "brew tests",
// 148:         inputSchema: {
// 149:           type:       "object",
// 150:           properties: {
// 151:             only:      {
// 152:               type:        "string",
// 153:               description: "Specific tests to run (comma-separated) e.g. for `<file>_spec.rb` pass `<file>`. " \
// 154:                            "Appending `:<line_number>` will start at a specific line",
// 155:             },
// 156:             fail_fast: {
// 157:               type:        "boolean",
// 158:               description: "Exit early on the first failing test",
// 159:             },
// 160:             changed:   {
// 161:               type:        "boolean",
// 162:               description: "Only runs tests on files that were changed from the `main` branch",
// 163:             },
// 164:             online:    {
// 165:               type:        "boolean",
// 166:               description: "Run online tests",
// 167:             },
// 168:           },
// 169:         },
// 170:       },
// 171:       commands:  {
// 172:         name:        "commands",
// 173:         description: "Show lists of built-in and external commands.",
// 174:         command:     "brew commands",
// 175:         inputSchema: { type: "object", properties: {} },
// 176:       },
// 177:       help:      {
// 178:         name:        "help",
// 179:         description: "Outputs the usage instructions for `brew` <command>.",
// 180:         command:     "brew help",
// 181:         inputSchema: {
// 182:           type:       "object",
// 183:           properties: {
// 184:             command: {
// 185:               type:        "string",
// 186:               description: "Command to get help for",
// 187:             },
// 188:           },
// 189:         },
// 190:       },
// 191:     }.freeze, T::Hash[Symbol, T::Hash[Symbol, T.anything]])
// 192:
// 193:     sig { params(stdin: T.any(IO, StringIO), stdout: T.any(IO, StringIO), stderr: T.any(IO, StringIO)).void }
// 194:     def initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)
// 195:       @debug_logging = T.let(ARGV.include?("--debug") || ARGV.include?("-d"), T::Boolean)
// 196:       @ping_switch = T.let(ARGV.include?("--ping"), T::Boolean)
// 197:       @stdin = stdin
// 198:       @stdout = stdout
// 199:       @stderr = stderr
// 200:     end
// 201:
// 202:     sig { returns(T::Boolean) }
// 203:     def debug_logging? = @debug_logging
// 204:
// 205:     sig { returns(T::Boolean) }
// 206:     def ping_switch? = @ping_switch
// 207:
// 208:     sig { void }
// 209:     def run
// 210:       @stderr.puts "==> Started Homebrew MCP server..."
// 211:
// 212:       loop do
// 213:         input = if ping_switch?
// 214:           { jsonrpc: JSON_RPC_VERSION, id: 1, method: "ping" }.to_json
// 215:         else
// 216:           break if @stdin.eof?
// 217:
// 218:           @stdin.gets
// 219:         end
// 220:         next if input.nil? || input.strip.empty?
// 221:
// 222:         request = JSON.parse(input)
// 223:         debug("Request: #{JSON.pretty_generate(request)}")
// 224:
// 225:         response = handle_request(request)
// 226:         if response.nil?
// 227:           debug("Response: nil")
// 228:           next
// 229:         end
// 230:
// 231:         debug("Response: #{JSON.pretty_generate(response)}")
// 232:         output = JSON.dump(response).strip
// 233:         @stdout.puts(output)
// 234:         @stdout.flush
// 235:
// 236:         break if ping_switch?
// 237:       end
// 238:     rescue Interrupt
// 239:       exit 0
// 240:     rescue => e
// 241:       log("Error: #{e.message}")
// 242:       exit 1
// 243:     end
// 244:
// 245:     sig { params(text: String).void }
// 246:     def debug(text)
// 247:       return unless debug_logging?
// 248:
// 249:       log(text)
// 250:     end
// 251:
// 252:     sig { params(text: String).void }
// 253:     def log(text)
// 254:       @stderr.puts(text)
// 255:       @stderr.flush
// 256:     end
// 257:
// 258:     sig { params(request: T::Hash[String, T.untyped]).returns(T.nilable(T::Hash[Symbol, T.anything])) }
// 259:     def handle_request(request)
// 260:       id = request["id"]
// 261:       return if id.nil?
// 262:
// 263:       case request["method"]
// 264:       when "initialize"
// 265:         respond_result(id, {
// 266:           protocolVersion: MCP_PROTOCOL_VERSION,
// 267:           capabilities:    {
// 268:             tools:     { listChanged: false },
// 269:             prompts:   {},
// 270:             resources: {},
// 271:             logging:   {},
// 272:             roots:     {},
// 273:           },
// 274:           serverInfo:      SERVER_INFO,
// 275:         })
// 276:       when "resources/list"
// 277:         respond_result(id, { resources: [] })
// 278:       when "resources/templates/list"
// 279:         respond_result(id, { resourceTemplates: [] })
// 280:       when "prompts/list"
// 281:         respond_result(id, { prompts: [] })
// 282:       when "ping"
// 283:         respond_result(id)
// 284:       when "get_server_info"
// 285:         respond_result(id, SERVER_INFO)
// 286:       when "logging/setLevel"
// 287:         @debug_logging = request["params"]["level"] == "debug"
// 288:         respond_result(id)
// 289:       when "notifications/initialized", "notifications/cancelled"
// 290:         respond_result
// 291:       when "tools/list"
// 292:         respond_result(id, { tools: TOOLS.values })
// 293:       when "tools/call"
// 294:         respond_to_tools_call(id, request)
// 295:       else
// 296:         respond_error(id, "Method not found")
// 297:       end
// 298:     end
// 299:
// 300:     sig { params(id: Integer, request: T::Hash[String, T.untyped]).returns(T.nilable(T::Hash[Symbol, T.anything])) }
// 301:     def respond_to_tools_call(id, request)
// 302:       tool_name = request["params"]["name"].to_sym
// 303:       tool = TOOLS.fetch tool_name do
// 304:         return respond_error(id, "Unknown tool")
// 305:       end
// 306:
// 307:       require "open3"
// 308:
// 309:       formula_or_cask = request.dig("params", "arguments", "formula_or_cask")
// 310:       if formula_or_cask.is_a?(String) && INLINE_CASK_DSL_REGEX.match?(formula_or_cask)
// 311:         return respond_error(id, "Invalid formula or cask argument")
// 312:       end
// 313:
// 314:       command_args = tool_command_arguments(tool_name, request["params"]["arguments"])
// 315:       progress_token = request["params"]["_meta"]&.fetch("progressToken", nil)
// 316:       brew_command = T.cast(tool.fetch(:command), String)
// 317:                       .delete_prefix("brew ")
// 318:       buffer_size = 4096 # 4KB
// 319:       progress = T.let(0, Integer)
// 320:       done = T.let(false, T::Boolean)
// 321:       new_output = T.let(false, T::Boolean)
// 322:       output = +""
// 323:
// 324:       text = Open3.popen2e(HOMEBREW_BREW_FILE, brew_command, *command_args) do |stdin, io, _wait|
// 325:         stdin.close
// 326:
// 327:         reader = Thread.new do
// 328:           loop do
// 329:             output << io.readpartial(buffer_size)
// 330:             progress += 1
// 331:             new_output = true
// 332:           end
// 333:         rescue EOFError
// 334:           nil
// 335:         ensure
// 336:           done = true
// 337:         end
// 338:
// 339:         until done
// 340:           break unless progress_token
// 341:
// 342:           sleep 1
// 343:           next unless new_output
// 344:
// 345:           response = {
// 346:             jsonrpc: JSON_RPC_VERSION,
// 347:             method:  "notifications/progress",
// 348:             params:  { progressToken: progress_token, progress: },
// 349:           }
// 350:           progress_output = JSON.dump(response).strip
// 351:           @stdout.puts(progress_output)
// 352:           @stdout.flush
// 353:
// 354:           new_output = false
// 355:         end
// 356:
// 357:         reader.join
// 358:
// 359:         output
// 360:       end
// 361:
// 362:       respond_result(id, { content: [{ type: "text", text: }] })
// 363:     end
// 364:
// 365:     sig { params(tool_name: Symbol, arguments: T::Hash[String, T.untyped]).returns(T::Array[String]) }
// 366:     def tool_command_arguments(tool_name, arguments)
// 367:       case tool_name
// 368:       when :style
// 369:         style_args = []
// 370:         style_args << "--fix" if arguments["fix"]
// 371:         style_args << "--changed" if arguments["changed"]
// 372:         file_arguments = arguments.fetch("files", "").strip.split
// 373:         style_args.concat(file_arguments) unless file_arguments.empty?
// 374:         style_args
// 375:       when :tests
// 376:         tests_args = []
// 377:         only_arguments = arguments.fetch("only", "").strip
// 378:         tests_args << "--only=#{only_arguments}" unless only_arguments.empty?
// 379:         tests_args << "--fail-fast" if arguments["fail_fast"]
// 380:         tests_args << "--changed" if arguments["changed"]
// 381:         tests_args << "--online" if arguments["online"]
// 382:         tests_args
// 383:       when :search
// 384:         [arguments["text_or_regex"]]
// 385:       when :help
// 386:         [arguments["command"]]
// 387:       else
// 388:         [arguments["formula_or_cask"]]
// 389:       end.compact
// 390:         .reject(&:empty?)
// 391:     end
// 392:
// 393:     sig {
// 394:       params(id:     T.nilable(Integer),
// 395:              result: T::Hash[Symbol, T.anything]).returns(T.nilable(T::Hash[Symbol, T.anything]))
// 396:     }
// 397:     def respond_result(id = nil, result = {})
// 398:       return if id.nil?
// 399:
// 400:       { jsonrpc: JSON_RPC_VERSION, id:, result: }
// 401:     end
// 402:
// 403:     sig { params(id: T.nilable(Integer), message: String).returns(T::Hash[Symbol, T.anything]) }
// 404:     def respond_error(id, message)
// 405:       { jsonrpc: JSON_RPC_VERSION, id:, error: { code: ERROR_CODE, message: } }
// 406:     end
// 407:   end
// 408: end
