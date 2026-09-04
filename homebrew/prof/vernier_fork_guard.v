module prof

import ruby

// Translated from Homebrew/brew `prof/vernier_fork_guard.rb`.

pub struct VernierForkRequest {
pub:
	block_provided      bool
	vernier_defined     bool
	collector_running   bool
	yield_returns_pid   bool
	pid                 int
	running_after_yield bool
}

pub struct VernierForkResult {
pub:
	yielded             bool
	collector_stopped   bool
	collector_cleared   bool
	collector_restarted bool
	has_pid             bool
	pid                 int
}

pub struct VernierStopResult {
pub:
	collector_stopped bool
}

pub struct VernierExecResult {
pub:
	collector_stopped bool
	command           []string
	original_exec     string
}

pub fn vernier_without_running_collector(request VernierForkRequest) !VernierForkResult {
	if !request.block_provided {
		return error('block required')
	}
	if !request.vernier_defined || !request.collector_running {
		return VernierForkResult{
			yielded: true
			has_pid: request.yield_returns_pid
			pid: request.pid
		}
	}
	return VernierForkResult{
		yielded: true
		collector_stopped: true
		collector_cleared: true
		collector_restarted: request.yield_returns_pid && !request.running_after_yield
		has_pid: request.yield_returns_pid
		pid: request.pid
	}
}

pub fn vernier_stop_running_collector(vernier_defined bool, collector_running bool) VernierStopResult {
	return VernierStopResult{
		collector_stopped: vernier_defined && collector_running
	}
}

pub fn vernier_guarded_exec(vernier_defined bool, collector_running bool, command []string) VernierExecResult {
	return VernierExecResult{
		collector_stopped: vernier_stop_running_collector(vernier_defined, collector_running).collector_stopped
		command: command.clone()
		original_exec: 'homebrew_vernier_fork_guard_exec'
	}
}

@[heap]
pub struct VernierForkGuardInput {
pub:
	request VernierForkRequest
	command []string
}

pub fn vernier_fork_guard_input_boundary(input &VernierForkGuardInput) ruby.Value {
	return ruby.structured_value('Homebrew::VernierForkGuard::Input', '', {
		'vernier_fork_guard_input_address': u64(voidptr(input)).str()
	})
}

fn vernier_fork_guard_input_from_value(value ruby.Value) &VernierForkGuardInput {
	address := value.attributes['vernier_fork_guard_input_address'] or {
		panic('invalid VernierForkGuard input')
	}
	return unsafe { &VernierForkGuardInput(voidptr(address.u64())) }
}

fn vernier_fork_result_value(result VernierForkResult) ruby.Value {
	return ruby.map_value({
		'yielded':             ruby.bool_value(result.yielded)
		'collector_stopped':   ruby.bool_value(result.collector_stopped)
		'collector_cleared':   ruby.bool_value(result.collector_cleared)
		'collector_restarted': ruby.bool_value(result.collector_restarted)
		'has_pid':             ruby.bool_value(result.has_pid)
		'pid':                 ruby.int_value(result.pid)
	})
}
