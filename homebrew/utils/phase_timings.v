module utils

import json2
import math
import os
import sync
import time

// Translated from Homebrew/brew `utils/phase_timings.rb`.
pub struct PhaseTimingEvent {
pub:
	phase     string
	start     i64
	duration  i64
	thread_id u64
	detail    ?string @[omitempty]
}

pub struct PhaseTimingsOutput {
pub:
	schema_version int = 1
	time_unit      string = 'microseconds'
	command        []string
	events         []PhaseTimingEvent
}

@[heap]
pub struct PhaseTimings {
mut:
	command     []string
	events      []PhaseTimingEvent
	mutex       sync.Mutex
	output_path string
	started_at  f64
}

pub enum PhaseTimingVisibility {
	private_method
	protected_method
	public_method
}

pub struct PhaseTimingMethod {
pub:
	receiver    string
	method_name string
	visibility  PhaseTimingVisibility
}

pub struct PhaseTimingInstrumentation {
pub:
	receiver    string
	method_name string
	phase       string
	visibility  PhaseTimingVisibility
}

pub struct PhaseTimingDetailObject {
pub:
	full_name           string
	download_queue_name string
	value               string
	string_like         bool
}

pub struct PhaseTimingDetailInput {
pub:
	formula ?PhaseTimingDetailObject
	url     ?PhaseTimingDetailObject
	args    []PhaseTimingDetailObject
}

pub fn new_phase_timings() &PhaseTimings {
	return &PhaseTimings{}
}

pub fn phase_timings_monotonic_time() f64 {
	return f64(time.sys_mono_now()) / 1_000_000_000.0
}

pub fn (mut timings PhaseTimings) record(phase string, started_at f64, completed_at f64,
	detail ?string) {
	event := PhaseTimingEvent{
		phase: phase
		start: i64(math.round((started_at - timings.started_at) * 1_000_000.0))
		duration: i64(math.round((completed_at - started_at) * 1_000_000.0))
		thread_id: sync.thread_id()
		detail: detail
	}
	timings.mutex.lock()
	timings.events << event
	timings.mutex.unlock()
}

pub fn (mut timings PhaseTimings) start(output_path string, started_at f64, command []string) {
	timings.output_path = output_path
	timings.started_at = started_at
	timings.command = command.clone()
	timings.mutex.lock()
	timings.events = []PhaseTimingEvent{}
	timings.mutex.unlock()
	timings.record('startup', started_at, phase_timings_monotonic_time(), none)
}

pub fn (mut timings PhaseTimings) measure[T](phase string, detail ?string,
	operation fn () !T) !T {
	// Recording is opt-in via `$HOMEBREW_PHASE_TIMINGS`, so callers on the
	// startup path can measure unconditionally without paying for it.
	if timings.output_path == '' {
		return operation()
	}
	started_at := phase_timings_monotonic_time()
	result := operation() or {
		timings.record(phase, started_at, phase_timings_monotonic_time(), detail)
		return err
	}
	timings.record(phase, started_at, phase_timings_monotonic_time(), detail)
	return result
}

pub fn (mut timings PhaseTimings) events() []PhaseTimingEvent {
	timings.mutex.lock()
	events := timings.events.clone()
	timings.mutex.unlock()
	return events
}

pub fn (mut timings PhaseTimings) write() ! {
	output_path := timings.output_path
	if output_path == '' {
		return
	}
	mut events := timings.events()
	events.sort(a.start < b.start)
	directory := os.dir(output_path)
	if directory != '' && directory != '.' {
		os.mkdir_all(directory)!
	}
	os.write_file(output_path, '${json2.encode(PhaseTimingsOutput{
		command: timings.command.clone()
		events: events
	},
		prettify: true
		escape_unicode: true
	)}\n')!
}

pub fn phase_timing_detail_for(input PhaseTimingDetailInput) ?string {
	object := if formula := input.formula {
		formula
	} else if url := input.url {
		url
	} else if input.args.len > 0 {
		input.args[0]
	} else {
		return none
	}
	if object.full_name != '' {
		return object.full_name
	}
	if object.download_queue_name != '' {
		return object.download_queue_name
	}
	if object.string_like {
		return object.value
	}
	return none
}

pub fn phase_timing_instrument(available []PhaseTimingMethod, receiver string,
	method_name string, phase string) ?PhaseTimingInstrumentation {
	for visibility in [PhaseTimingVisibility.private_method, .protected_method, .public_method] {
		for method in available {
			if method.receiver == receiver && method.method_name == method_name && method.visibility == visibility {
				return PhaseTimingInstrumentation{
					receiver: receiver
					method_name: method_name
					phase: phase
					visibility: visibility
				}
			}
		}
	}
	return none
}

pub fn phase_timings_installation_plan(available []PhaseTimingMethod) []PhaseTimingInstrumentation {
	candidates := [
		['Homebrew::CLI::NamedArgs', 'to_formulae_and_casks', 'formula_resolution'],
		['Formulary.singleton_class', 'factory', 'formula_inflation'],
		['Homebrew::API.singleton_class', 'fetch_api_files!', 'api_metadata_load'],
		['Homebrew::API::Internal.singleton_class', 'formula_struct', 'api_metadata_load'],
		['Homebrew::Install.singleton_class', 'formula_installers', 'planning'],
		['Homebrew::Install.singleton_class', 'perform_preinstall_checks_once', 'preinstall_checks'],
		['FormulaInstaller', 'prelude', 'planning'],
		['FormulaInstaller', 'compute_dependencies', 'dependency_resolution'],
		['FormulaInstaller', 'pour', 'pour'],
		['FormulaInstaller', 'link', 'link'],
		['FormulaInstaller', 'clean', 'cleanup'],
		['FormulaInstaller', 'post_install', 'postinstall'],
		['Homebrew::DownloadQueue', 'enqueue', 'download_enqueue'],
		['Utils::Curl', 'curl_headers', 'curl_headers'],
		['Utils::Curl.singleton_class', 'curl_headers', 'curl_headers'],
		['Utils::Curl', 'curl_download', 'curl_body'],
		['Utils::Curl.singleton_class', 'curl_download', 'curl_body'],
		['Downloadable::VerificationCache', 'verify', 'checksum'],
		['AbstractFileDownloadStrategy', 'create_symlink_to_cached_download', 'symlink'],
		['AbstractDownloadStrategy', 'stage', 'extraction'],
		['Bottle', 'stage_from_download_queue', 'extraction'],
		['Cask::Download', 'stage_from_download_queue', 'extraction'],
		['Tab', 'write', 'tab_write'],
		['Cleanup.singleton_class', 'install_formula_clean!', 'cleanup'],
	]
	mut plan := []PhaseTimingInstrumentation{}
	for candidate in candidates {
		if instrumentation := phase_timing_instrument(available, candidate[0], candidate[1], candidate[2]) {
			plan << instrumentation
		}
	}
	return plan
}

pub fn (mut timings PhaseTimings) run_instrumentation[T](instrumentation PhaseTimingInstrumentation,
	input PhaseTimingDetailInput, operation fn () !T) !T {
	detail := phase_timing_detail_for(input)
	return timings.measure(instrumentation.phase, detail, operation)
}
