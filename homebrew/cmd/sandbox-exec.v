module cmd

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
