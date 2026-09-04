module cmd

import ruby

// Translated from Homebrew/brew `cmd/sandbox-exec.rb`.
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

pub fn sandbox_exec_plan_to_value(plan SandboxExecPlan) ruby.Value {
	return ruby.map_value({
		'writable_path': ruby.string_value(plan.writable_path)
		'command':       ruby.string_array_value(plan.command)
		'deny_network':  ruby.bool_value(plan.deny_network)
	})
}
