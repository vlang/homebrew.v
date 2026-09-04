module homebrew

import ruby
import time

// Translated from Homebrew/brew `homebrew.rb`.
pub type HomebrewRequireLoader = fn (string) !

pub type HomebrewSystemRunner = fn (HomebrewSystemRequest) !ruby.CommandResult

pub type DumpStatsMatcher = fn (string) bool

pub type DumpStatsMethod = fn () !string

pub struct HomebrewSystemRequest {
pub:
	command     ?string
	argv0       ?string
	arguments   []string
	environment map[string]string
	chdir       ?string
	quiet       bool
}

pub struct DumpStatsState {
pub mut:
	injected_methods []string
	times            map[string]f64
}

fn default_homebrew_system_runner(request HomebrewSystemRequest) !ruby.CommandResult {
	command := request.command or { return ruby.CommandResult{ exit_code: 1 } }
	if request.environment.len > 0 {
		return ruby.run_command_with_environment(command, request.arguments, request.environment)
	}
	return ruby.run_command(command, request.arguments)
}

pub fn homebrew_require(path ?string, loader HomebrewRequireLoader) bool {
	value := path or { return false }
	loader(value) or { return false }
	return true
}

pub fn homebrew_system_with_runner(request HomebrewSystemRequest,
	runner HomebrewSystemRunner) bool {
	result := runner(request) or { return false }
	if !request.quiet && result.output != '' {
		print(result.output)
	}
	return result.exit_code == 0
}

pub fn homebrew_system(request HomebrewSystemRequest) bool {
	return homebrew_system_with_runner(request, default_homebrew_system_runner)
}

pub fn homebrew_safe_system(request HomebrewSystemRequest) ! {
	if homebrew_system(request) {
		return
	}
	command := request.command or { '' }
	mut command_line := [command]
	command_line << request.arguments
	return error('Failure while executing: ${command_line.join(' ')}')
}

pub fn inject_dump_stats(mut state DumpStatsState, method_names []string,
	matcher DumpStatsMatcher) []string {
	mut wrapped := []string{}
	for name in method_names {
		if !matcher(name) || name in state.injected_methods {
			continue
		}
		state.injected_methods << name
		wrapped << name
	}
	return wrapped
}

pub fn run_dump_stats_method(mut state DumpStatsState, name string,
	method DumpStatsMethod) !string {
	started := time.now()
	result := method() or {
		elapsed := f64(time.since(started)) / f64(time.second)
		state.times[name] = (state.times[name] or { 0.0 }) + elapsed
		return err
	}
	elapsed := f64(time.since(started)) / f64(time.second)
	state.times[name] = (state.times[name] or { 0.0 }) + elapsed
	return result
}
