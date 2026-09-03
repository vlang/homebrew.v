module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/sandbox-exec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct SandboxExecRequest {
pub:
	writable_path string
	command       []string
	deny_network  bool
}

pub struct SandboxExecPlan {
pub:
	writable_path string
	command       []string
	deny_network  bool
}

pub fn sandbox_exec_plan(request SandboxExecRequest) !SandboxExecPlan {
	if request.writable_path == '' {
		return error('`sandbox-exec` requires a writable path.')
	}
	if request.command.len == 0 || request.command[0] == '' {
		return error('`sandbox-exec` requires a command.')
	}
	return SandboxExecPlan{
		writable_path: request.writable_path
		command: request.command.clone()
		deny_network: request.deny_network
	}
}

pub fn sandbox_exec_plan_to_value(plan SandboxExecPlan) brew_runtime.Value {
	return brew_runtime.map_value({
		'writable_path': brew_runtime.string_value(plan.writable_path)
		'command':       brew_runtime.string_array_value(plan.command)
		'deny_network':  brew_runtime.bool_value(plan.deny_network)
	})
}

// Ruby method `run` at line 27.
pub fn ruby_sandbox_exec_l27_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('UsageError', '`sandbox-exec` requires a writable path.')
	}
	values := args[0].as_map() or { return brew_runtime.object_value('UsageError', err.msg()) }
	request := SandboxExecRequest{
		writable_path: values['writable_path'] or { brew_runtime.string_value('') }.as_string()
		command: if value := values['command'] {
			value.as_string_array() or { []string{} }} else {
			[]string{}}
		deny_network: if value := values['deny_network'] {
			value.as_bool() or { false }} else {
			false}
	}
	plan := sandbox_exec_plan(request) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return sandbox_exec_plan_to_value(plan)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "sandbox"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class SandboxExec < AbstractCommand
// 10:       cmd_args do
// 11:         usage_banner <<~EOS
// 12:           `sandbox-exec` [`--deny-network`] <writable-path> [`--`] <command> [<args> ...]
// 13:
// 14:           Run <command> in Homebrew's sandbox, allowing writes to <writable-path> and
// 15:           Homebrew's temporary and cache directories.
// 16:
// 17:           Example: `brew sandbox-exec . -- make test`
// 18:         EOS
// 19:
// 20:         switch "--deny-network",
// 21:                description: "Deny network access from inside the sandbox."
// 22:
// 23:         named_args min: 2
// 24:       end
// 25:
// 26:       sig { override.void }
// 27:       def run
// 28:         writable_path = args.named.first
// 29:         raise UsageError, "`sandbox-exec` requires a writable path." unless writable_path
// 30:
// 31:         Sandbox.run_command(
// 32:           *args.named.drop(1),
// 33:           writable_path:,
// 34:           deny_network:  args.deny_network?,
// 35:         )
// 36:       end
// 37:     end
// 38:   end
// 39: end
