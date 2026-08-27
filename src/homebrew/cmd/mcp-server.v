module cmd

// Translated from Homebrew/brew `cmd/mcp-server.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "shell_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class McpServerCmd < AbstractCommand
// 10:       # This is a shell command as MCP servers need a faster startup time
// 11:       # than a normal Homebrew Ruby command allows.
// 12:       include ShellCommand
// 13:
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Starts the Homebrew MCP (Model Context Protocol) server.
// 17:         EOS
// 18:         switch "-d", "--debug", description: "Enable debug logging to stderr."
// 19:         switch "--ping", description: "Start the server, act as if receiving a ping and then exit.", hidden: true
// 20:       end
// 21:     end
// 22:   end
// 23: end
