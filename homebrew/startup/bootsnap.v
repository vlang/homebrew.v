module startup

import ruby
import crypto.sha256
import os

// Translated from Homebrew/brew `startup/bootsnap.rb`.

pub struct BootsnapEnvironment {
pub:
	ruby_version       string
	ruby_platform      string
	gem_directories    []string
	cache              string
	cache_set          bool
	default_cache      string
	default_cache_set  bool
	library_path       string
	gem_path           string
	no_bootsnap_set    bool
	tests_set          bool
	tests_coverage_set bool
	ruby_exec_args     []string
	load_path          []string
}

pub struct BootsnapSetup {
pub:
	cache_dir          string
	ignore_directories []string
	development_mode   bool
	load_path_cache    bool
	compile_cache_iseq bool
	compile_cache_yaml bool
}

pub struct BootsnapState {
pub mut:
	cached_key   string
	setup_calls  []BootsnapSetup
	unload_calls int
}

pub struct BootsnapSpawnRequest {
pub:
	arguments   []string
	stdin_null  bool
	stdout_null bool
	stderr_null bool
	pgroup      bool
}

pub struct BootsnapProcess {
pub:
	pid          int
	spawn_error  string
	detach_error string
pub mut:
	spawn_requests []BootsnapSpawnRequest
	detached_pids  []int
}

pub struct BootsnapPrewarmResult {
pub:
	spawn_attempted  bool
	detach_attempted bool
	pid              int
	suppressed_error string
}

pub struct BootsnapBoundaryInput {
pub:
	environment   BootsnapEnvironment
	gem_available bool
	compile_cache bool = true
	pid           int = 12345
	spawn_error   string
	detach_error  string
}

pub fn bootsnap_key(mut state BootsnapState, environment BootsnapEnvironment) string {
	if state.cached_key == '' {
		material := environment.ruby_version + environment.ruby_platform + environment.gem_directories.join(',')
		state.cached_key = sha256.sum256(material.bytes()).hex()
	}
	return state.cached_key
}

pub fn bootsnap_cache_dir(mut state BootsnapState, environment BootsnapEnvironment) !string {
	cache := if environment.cache_set {
		environment.cache
	} else if environment.default_cache_set {
		environment.default_cache
	} else {
		''
	}
	if cache == '' {
		return error('Needs `\$HOMEBREW_CACHE` or `\$HOMEBREW_DEFAULT_CACHE`!')
	}
	return os.join_path(cache, 'bootsnap', bootsnap_key(mut state, environment))
}

pub fn bootsnap_ignore_directories(library_path string) []string {
	return [
		os.join_path(library_path, 'vendor/bundle/ruby'),
		os.join_path(library_path, 'vendor/portable-ruby'),
	]
}

pub fn bootsnap_enabled(environment BootsnapEnvironment) bool {
	return environment.gem_path != '' && !environment.no_bootsnap_set
}

pub fn bootsnap_load(mut state BootsnapState, environment BootsnapEnvironment, gem_available bool,
	compile_cache bool) !bool {
	if !bootsnap_enabled(environment) || !gem_available {
		return false
	}
	state.setup_calls << BootsnapSetup{
		cache_dir: bootsnap_cache_dir(mut state, environment)!
		ignore_directories: bootsnap_ignore_directories(environment.library_path)
		development_mode: true
		load_path_cache: true
		compile_cache_iseq: compile_cache && !environment.tests_coverage_set
		compile_cache_yaml: compile_cache
	}
	return true
}

pub fn bootsnap_reset(mut state BootsnapState, environment BootsnapEnvironment,
	gem_available bool) !bool {
	if !bootsnap_enabled(environment) {
		return false
	}
	state.unload_calls++
	state.cached_key = ''
	// The compile cache doesn't get unloaded so we don't need to load it again!
	return bootsnap_load(mut state, environment, gem_available, false)
}

pub fn bootsnap_spawn_request(environment BootsnapEnvironment) BootsnapSpawnRequest {
	mut arguments := environment.ruby_exec_args.clone()
	arguments << ['-I', environment.load_path.join(os.path_delimiter.str()), '-rglobal',
		'-rcmd/install', '-rcmd/fetch', '-rcmd/upgrade', '-e', '']
	return BootsnapSpawnRequest{
		arguments: arguments
		stdin_null: true
		stdout_null: true
		stderr_null: true
		pgroup: true
	}
}

fn (mut process BootsnapProcess) spawn(request BootsnapSpawnRequest) !int {
	process.spawn_requests << request
	if process.spawn_error != '' {
		return error(process.spawn_error)
	}
	return process.pid
}

fn (mut process BootsnapProcess) detach(pid int) ! {
	process.detached_pids << pid
	if process.detach_error != '' {
		return error(process.detach_error)
	}
}

pub fn bootsnap_prewarm(environment BootsnapEnvironment,
	mut process BootsnapProcess) BootsnapPrewarmResult {
	if !bootsnap_enabled(environment) || environment.tests_set {
		return BootsnapPrewarmResult{}
	}
	pid := process.spawn(bootsnap_spawn_request(environment)) or {
		return BootsnapPrewarmResult{
			spawn_attempted: true
			suppressed_error: err.msg()
		}
	}
	process.detach(pid) or {
		return BootsnapPrewarmResult{
			spawn_attempted: true
			detach_attempted: true
			pid: pid
			suppressed_error: err.msg()
		}
	}
	return BootsnapPrewarmResult{
		spawn_attempted: true
		detach_attempted: true
		pid: pid
	}
}

fn bootsnap_value_string(values map[string]ruby.Value, key string,
	fallback string) string {
	return if key in values { values[key].as_string() } else { fallback }
}

fn bootsnap_value_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	return if key in values { values[key].as_bool() or { fallback } } else { fallback }
}

fn bootsnap_value_strings(values map[string]ruby.Value, key string) []string {
	return if key in values { values[key].as_string_array() or { []string{} } } else { []string{} }
}

fn bootsnap_value_int(values map[string]ruby.Value, key string, fallback int) int {
	return if key in values { int(values[key].as_int() or { i64(fallback) }) } else { fallback }
}

pub fn bootsnap_boundary_value(input BootsnapBoundaryInput) ruby.Value {
	environment := input.environment
	return ruby.map_value({
		'ruby_version':       ruby.string_value(environment.ruby_version)
		'ruby_platform':      ruby.string_value(environment.ruby_platform)
		'gem_directories':    ruby.string_array_value(environment.gem_directories)
		'cache':              ruby.string_value(environment.cache)
		'cache_set':          ruby.bool_value(environment.cache_set)
		'default_cache':      ruby.string_value(environment.default_cache)
		'default_cache_set':  ruby.bool_value(environment.default_cache_set)
		'library_path':       ruby.string_value(environment.library_path)
		'gem_path':           ruby.string_value(environment.gem_path)
		'no_bootsnap_set':    ruby.bool_value(environment.no_bootsnap_set)
		'tests_set':          ruby.bool_value(environment.tests_set)
		'tests_coverage_set': ruby.bool_value(environment.tests_coverage_set)
		'ruby_exec_args':     ruby.string_array_value(environment.ruby_exec_args)
		'load_path':          ruby.string_array_value(environment.load_path)
		'gem_available':      ruby.bool_value(input.gem_available)
		'compile_cache':      ruby.bool_value(input.compile_cache)
		'pid':                ruby.int_value(input.pid)
		'spawn_error':        ruby.string_value(input.spawn_error)
		'detach_error':       ruby.string_value(input.detach_error)
	})
}

fn bootsnap_boundary_from_value(value ruby.Value) !BootsnapBoundaryInput {
	values := value.as_map()!
	return BootsnapBoundaryInput{
		environment: BootsnapEnvironment{
			ruby_version: bootsnap_value_string(values, 'ruby_version', '')
			ruby_platform: bootsnap_value_string(values, 'ruby_platform', '')
			gem_directories: bootsnap_value_strings(values, 'gem_directories')
			cache: bootsnap_value_string(values, 'cache', '')
			cache_set: bootsnap_value_bool(values, 'cache_set', false)
			default_cache: bootsnap_value_string(values, 'default_cache', '')
			default_cache_set: bootsnap_value_bool(values, 'default_cache_set', false)
			library_path: bootsnap_value_string(values, 'library_path', '')
			gem_path: bootsnap_value_string(values, 'gem_path', '')
			no_bootsnap_set: bootsnap_value_bool(values, 'no_bootsnap_set', false)
			tests_set: bootsnap_value_bool(values, 'tests_set', false)
			tests_coverage_set: bootsnap_value_bool(values, 'tests_coverage_set', false)
			ruby_exec_args: bootsnap_value_strings(values, 'ruby_exec_args')
			load_path: bootsnap_value_strings(values, 'load_path')
		}
		gem_available: bootsnap_value_bool(values, 'gem_available', false)
		compile_cache: bootsnap_value_bool(values, 'compile_cache', true)
		pid: bootsnap_value_int(values, 'pid', 12345)
		spawn_error: bootsnap_value_string(values, 'spawn_error', '')
		detach_error: bootsnap_value_string(values, 'detach_error', '')
	}
}

fn bootsnap_load_value(loaded bool, state BootsnapState) ruby.Value {
	last_setup := if state.setup_calls.len > 0 { state.setup_calls.last() } else { BootsnapSetup{} }
	return ruby.map_value({
		'loaded':             ruby.bool_value(loaded)
		'setup_calls':        ruby.int_value(state.setup_calls.len)
		'unload_calls':       ruby.int_value(state.unload_calls)
		'cached_key':         ruby.string_value(state.cached_key)
		'cache_dir':          ruby.string_value(last_setup.cache_dir)
		'compile_cache_iseq': ruby.bool_value(last_setup.compile_cache_iseq)
		'compile_cache_yaml': ruby.bool_value(last_setup.compile_cache_yaml)
	})
}

fn bootsnap_prewarm_value(result BootsnapPrewarmResult,
	process BootsnapProcess) ruby.Value {
	arguments := if process.spawn_requests.len > 0 {
		process.spawn_requests[0].arguments
	} else {
		[]string{}
	}
	return ruby.map_value({
		'spawn_attempted':  ruby.bool_value(result.spawn_attempted)
		'detach_attempted': ruby.bool_value(result.detach_attempted)
		'pid':              ruby.int_value(result.pid)
		'suppressed_error': ruby.string_value(result.suppressed_error)
		'arguments':        ruby.string_array_value(arguments)
	})
}
