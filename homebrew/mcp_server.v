module homebrew

import brew_runtime

// Translated from Homebrew/brew `mcp_server.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)` at line 194.
pub fn ruby_mcp_server_l194_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `debug_logging? = @debug_logging` at line 203.
pub fn ruby_mcp_server_l203_d2_debug_logging(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('debug_logging?', ...args)
}

// Ruby method `ping_switch? = @ping_switch` at line 206.
pub fn ruby_mcp_server_l206_d3_ping_switch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ping_switch?', ...args)
}

// Ruby method `run` at line 209.
pub fn ruby_mcp_server_l209_d4_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `debug(text)` at line 246.
pub fn ruby_mcp_server_l246_d5_debug(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('debug', ...args)
}

// Ruby method `log(text)` at line 253.
pub fn ruby_mcp_server_l253_d6_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('log', ...args)
}

// Ruby method `handle_request(request)` at line 259.
pub fn ruby_mcp_server_l259_d7_handle_request(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handle_request', ...args)
}

// Ruby method `respond_to_tools_call(id, request)` at line 301.
pub fn ruby_mcp_server_l301_d8_respond_to_tools_call(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_tools_call', ...args)
}

// Ruby method `tool_command_arguments(tool_name, arguments)` at line 366.
pub fn ruby_mcp_server_l366_d9_tool_command_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tool_command_arguments', ...args)
}

// Ruby method `respond_result(id = nil, result = {})` at line 397.
pub fn ruby_mcp_server_l397_d10_respond_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_result', ...args)
}

// Ruby method `respond_error(id, message)` at line 404.
pub fn ruby_mcp_server_l404_d11_respond_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_error', ...args)
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
