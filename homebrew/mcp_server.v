module homebrew

import ruby

// Translated from Homebrew/brew `mcp_server.rb`.
pub const mcp_json_rpc_version = '2.0'
pub const mcp_protocol_version = '2025-03-26'
pub const mcp_error_code = i64(-32601)

pub struct McpTool {
pub:
	name         string
	description  string
	command      string
	input_schema ruby.Value
	required     []string
}

pub struct McpCommandExecution {
pub:
	output string
	chunks []string
}

pub type McpCommandRunner = fn (string, []string) !McpCommandExecution

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
	value   ruby.Value
}

fn mcp_string_property(description string) ruby.Value {
	return ruby.map_value({
		'type':        ruby.string_value('string')
		'description': ruby.string_value(description)
	})
}

fn mcp_boolean_property(description string) ruby.Value {
	return ruby.map_value({
		'type':        ruby.string_value('boolean')
		'description': ruby.string_value(description)
	})
}

fn mcp_schema(properties map[string]ruby.Value) ruby.Value {
	return ruby.map_value({
		'type':       ruby.string_value('object')
		'properties': ruby.map_value(properties)
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
			input_schema: mcp_schema(map[string]ruby.Value{})
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
			input_schema: mcp_schema(map[string]ruby.Value{})
		},
		McpTool{
			name: 'doctor'
			description: "Check your system for potential problems. Will exit with a non-zero status if any potential problems are found. Please note that these warnings are just used to help the Homebrew maintainers with debugging if you file an issue. If everything you use Homebrew for is working fine: please don't worry or file an issue; just ignore this."
			command: 'brew doctor'
			input_schema: mcp_schema(map[string]ruby.Value{})
		},
		McpTool{
			name: 'typecheck'
			description: 'Check for typechecking errors using Sorbet.'
			command: 'brew typecheck'
			input_schema: mcp_schema(map[string]ruby.Value{})
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
			input_schema: mcp_schema(map[string]ruby.Value{})
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

fn mcp_tool_value(tool McpTool) ruby.Value {
	mut values := {
		'name':        ruby.string_value(tool.name)
		'description': ruby.string_value(tool.description)
		'command':     ruby.string_value(tool.command)
		'inputSchema': tool.input_schema
	}
	if tool.required.len > 0 {
		values['required'] = ruby.string_array_value(tool.required)
	}
	return ruby.map_value(values)
}

pub fn new_mcp_server(argv []string, stdin_lines []string, brew_file string,
	version string) McpServerState {
	return McpServerState{
		brew_file: if brew_file == '' {
			ruby.environment_value('HOMEBREW_BREW_FILE')
		} else {
			brew_file
		}
		version: if version == '' {
			ruby.environment_value('HOMEBREW_VERSION')
		} else {
			version
		}
		debug_logging: '--debug' in argv || '-d' in argv
		ping_switch: '--ping' in argv
		stdin_lines: stdin_lines.clone()
	}
}

pub fn mcp_server_info(version string) ruby.Value {
	return ruby.map_value({
		'name':    ruby.string_value('brew-mcp-server')
		'version': ruby.string_value(version)
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

fn mcp_response(id ruby.Value, key string, payload ruby.Value) ruby.Value {
	mut values := {
		'jsonrpc': ruby.string_value(mcp_json_rpc_version)
		'id':      id
	}
	values[key] = payload
	return ruby.map_value(values)
}

pub fn mcp_respond_result(id ?ruby.Value, result ruby.Value) McpResponse {
	response_id := id or { return McpResponse{} }
	return McpResponse{
		present: true
		value: mcp_response(response_id, 'result', result)
	}
}

pub fn mcp_respond_error(id ruby.Value, message string) McpResponse {
	return McpResponse{
		present: true
		value: mcp_response(id, 'error', ruby.map_value({
			'code':    ruby.int_value(mcp_error_code)
			'message': ruby.string_value(message)
		}))
	}
}

fn mcp_bool(arguments map[string]ruby.Value, key string) bool {
	value := arguments[key] or { return false }
	return value.type_name == 'Bool' && value.bool_data
}

pub fn mcp_tool_command_arguments(tool_name string,
	arguments map[string]ruby.Value) []string {
	match tool_name {
		'style' {
			mut output := []string{}
			if mcp_bool(arguments, 'fix') { output << '--fix' }
			if mcp_bool(arguments, 'changed') { output << '--changed' }
			files := (arguments['files'] or { ruby.string_value('') }).as_string().trim_space()
			if files != '' { output << files.fields() }
			return output
		}
		'tests' {
			mut output := []string{}
			only := (arguments['only'] or { ruby.string_value('') }).as_string().trim_space()
			if only != '' { output << '--only=${only}' }
			if mcp_bool(arguments, 'fail_fast') { output << '--fail-fast' }
			if mcp_bool(arguments, 'changed') { output << '--changed' }
			if mcp_bool(arguments, 'online') { output << '--online' }
			return output
		}
		'search' {
			return [
				(arguments['text_or_regex'] or { ruby.string_value('') }).as_string(),
			].filter(it != '')
		}
		'help' {
			return [
				(arguments['command'] or { ruby.string_value('') }).as_string(),
			].filter(it != '')
		}
		else {
			return [
				(arguments['formula_or_cask'] or { ruby.string_value('') }).as_string(),
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
	result := ruby.run_command(executable, arguments)
	return McpCommandExecution{ output: result.output, chunks: [result.output] }
}

pub fn mcp_respond_to_tools_call(mut server McpServerState, id ruby.Value,
	request ruby.Value, runner McpCommandRunner) !McpResponse {
	request_values := request.map_data.clone()
	params_value := request_values['params'] or { return mcp_respond_error(id, 'Unknown tool') }
	params := params_value.map_data.clone()
	tool_name := (params['name'] or { ruby.string_value('') }).as_string()
	tool := mcp_tools().filter(it.name == tool_name)
	if tool.len == 0 {
		return mcp_respond_error(id, 'Unknown tool')
	}
	arguments_value := params['arguments'] or { ruby.map_value(map[string]ruby.Value{}) }
	arguments := arguments_value.map_data.clone()
	formula_or_cask := (arguments['formula_or_cask'] or { ruby.string_value('') }).as_string()
	if formula_or_cask != '' && mcp_inline_cask_definition(formula_or_cask) {
		return mcp_respond_error(id, 'Invalid formula or cask argument')
	}
	command_arguments := mcp_tool_command_arguments(tool_name, arguments)
	brew_command := tool[0].command.trim_string_left('brew ')
	mut brew_arguments := [brew_command]
	brew_arguments << command_arguments
	execution := runner(server.brew_file, brew_arguments)!
	progress_token := if meta_value := params['_meta'] {
		(meta_value.map_data['progressToken'] or { ruby.Value{} }).as_string()
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
			progress := ruby.map_value({
				'jsonrpc': ruby.string_value(mcp_json_rpc_version)
				'method':  ruby.string_value('notifications/progress')
				'params':  ruby.map_value({
					'progressToken': ruby.string_value(progress_token)
					'progress':      ruby.int_value(index + 1)
				})
			})
			server.stdout_lines << ruby.json_value_to_string(progress)
		}
	}
	return mcp_respond_result(id, ruby.map_value({
		'content': ruby.array_value([
			ruby.map_value({
				'type': ruby.string_value('text')
				'text': ruby.string_value(execution.output)
			}),
		])
	}))
}

pub fn mcp_handle_request(mut server McpServerState, request ruby.Value,
	runner McpCommandRunner) !McpResponse {
	values := request.map_data.clone()
	id := values['id'] or { return McpResponse{} }
	if id.type_name == 'NilClass' || id.type_name == '' {
		return McpResponse{}
	}
	method := (values['method'] or { ruby.string_value('') }).as_string()
	match method {
		'initialize' {
			return mcp_respond_result(id, ruby.map_value({
				'protocolVersion': ruby.string_value(mcp_protocol_version)
				'capabilities':    ruby.map_value({
					'tools':     ruby.map_value({
						'listChanged': ruby.bool_value(false)
					})
					'prompts':   ruby.map_value(map[string]ruby.Value{})
					'resources': ruby.map_value(map[string]ruby.Value{})
					'logging':   ruby.map_value(map[string]ruby.Value{})
					'roots':     ruby.map_value(map[string]ruby.Value{})
				})
				'serverInfo':      mcp_server_info(server.version)
			}))
		}
		'resources/list' {
			return mcp_respond_result(id, ruby.map_value({
				'resources': ruby.array_value([])
			}))
		}
		'resources/templates/list' {
			return mcp_respond_result(id, ruby.map_value({
				'resourceTemplates': ruby.array_value([])
			}))
		}
		'prompts/list' {
			return mcp_respond_result(id, ruby.map_value({
				'prompts': ruby.array_value([])
			}))
		}
		'ping' {
			return mcp_respond_result(id, ruby.map_value(map[string]ruby.Value{}))
		}
		'get_server_info' {
			return mcp_respond_result(id, mcp_server_info(server.version))
		}
		'logging/setLevel' {
			params := (values['params'] or { ruby.map_value(map[string]ruby.Value{}) }).map_data.clone()
			server.debug_logging = (params['level'] or { ruby.string_value('') }).as_string() == 'debug'
			return mcp_respond_result(id, ruby.map_value(map[string]ruby.Value{}))
		}
		'notifications/initialized', 'notifications/cancelled' {
			return McpResponse{}
		}
		'tools/list' {
			return mcp_respond_result(id, ruby.map_value({
				'tools': ruby.array_value(mcp_tools().map(mcp_tool_value(it)))
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
		request := ruby.parse_json_value(input) or {
			mcp_log(mut server, 'Error: ${err.msg()}')
			server.exit_code = 1
			return
		}
		mcp_debug(mut server, 'Request: ${ruby.json_value_to_string(request)}')
		response := mcp_handle_request(mut server, request, runner) or {
			mcp_log(mut server, 'Error: ${err.msg()}')
			server.exit_code = 1
			return
		}
		if !response.present {
			mcp_debug(mut server, 'Response: nil')
			continue
		}
		mcp_debug(mut server, 'Response: ${ruby.json_value_to_string(response.value)}')
		server.stdout_lines << ruby.json_value_to_string(response.value)
		if server.ping_switch {
			break
		}
	}
}

pub fn mcp_server_state_value(server McpServerState) ruby.Value {
	return ruby.map_value({
		'brew_file':         ruby.string_value(server.brew_file)
		'version':           ruby.string_value(server.version)
		'debug_logging':     ruby.bool_value(server.debug_logging)
		'ping_switch':       ruby.bool_value(server.ping_switch)
		'stdin':             ruby.string_array_value(server.stdin_lines)
		'stdout':            ruby.string_array_value(server.stdout_lines)
		'stderr':            ruby.string_array_value(server.stderr_lines)
		'exit_code':         ruby.int_value(server.exit_code)
		'interrupt_on_read': ruby.bool_value(server.interrupt_on_read)
		'read_error':        ruby.string_value(server.read_error)
	})
}

fn mcp_server_state_from_value(value ruby.Value) McpServerState {
	values := value.map_data.clone()
	return McpServerState{
		brew_file: (values['brew_file'] or { ruby.string_value('brew') }).as_string()
		version: (values['version'] or { ruby.string_value('') }).as_string()
		debug_logging: (values['debug_logging'] or { ruby.bool_value(false) }).bool_data
		ping_switch: (values['ping_switch'] or { ruby.bool_value(false) }).bool_data
		stdin_lines: (values['stdin'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		stdout_lines: (values['stdout'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		stderr_lines: (values['stderr'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		exit_code: int((values['exit_code'] or { ruby.int_value(0) }).int_data)
		interrupt_on_read: (values['interrupt_on_read'] or { ruby.bool_value(false) }).bool_data
		read_error: (values['read_error'] or { ruby.string_value('') }).as_string()
	}
}
