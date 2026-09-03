module utils

import homebrew.utils as homebrew_utils
import json2
import os

// Translated from Homebrew/brew `test/utils/phase_timings_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:output_path) { HOMEBREW_TEMP/"phase-timings.json" }` at line 7.
pub fn ruby_phase_timings_spec_l7_d1_output_path() string {
	return os.join_path(os.temp_dir(), 'phase-timings.json')
}

// Ruby it `it "writes machine-readable phase events" do` at line 11.
pub fn ruby_phase_timings_spec_l11_d2_writes() !bool {
	output_path := ruby_phase_timings_spec_l7_d1_output_path()
	defer {
		os.rm(output_path) or {}
	}
	mut timings := homebrew_utils.new_phase_timings()
	timings.start(output_path, homebrew_utils.phase_timings_monotonic_time(), [
		'install',
		'foo',
	])
	result := timings.measure('checksum', 'foo', fn () !string {
		return 'result'
	})!
	if result != 'result' {
		return false
	}
	timings.write()!
	output := json2.decode[homebrew_utils.PhaseTimingsOutput](os.read_file(output_path)!)!
	if output.schema_version != 1 || output.time_unit != 'microseconds' || output.command != [
		'install',
		'foo',
	] {
		return false
	}
	for event in output.events {
		detail := event.detail or { continue }
		if event.phase == 'checksum' && detail == 'foo' && event.start >= 0 && event.duration >= 0 && event.thread_id > 0 {
			return true
		}
	}
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/phase_timings"
// 5:
// 6: RSpec.describe Homebrew::PhaseTimings do
// 7:   let(:output_path) { HOMEBREW_TEMP/"phase-timings.json" }
// 8:
// 9:   after { output_path.unlink if output_path.exist? }
// 10:
// 11:   it "writes machine-readable phase events" do
// 12:     described_class.start!(
// 13:       output_path:,
// 14:       started_at:  Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f,
// 15:       command:     ["install", "foo"],
// 16:     )
// 17:
// 18:     expect(described_class.measure("checksum", detail: "foo") { :result }).to eq(:result)
// 19:     described_class.write!
// 20:
// 21:     timings = JSON.parse(output_path.read)
// 22:     expect(timings).to include(
// 23:       "schema_version" => 1,
// 24:       "time_unit"      => "microseconds",
// 25:       "command"        => ["install", "foo"],
// 26:     )
// 27:     expect(timings.fetch("events")).to include(
// 28:       hash_including(
// 29:         "phase"     => "checksum",
// 30:         "detail"    => "foo",
// 31:         "start"     => be_a(Integer),
// 32:         "duration"  => be_a(Integer),
// 33:         "thread_id" => be_a(Integer),
// 34:       ),
// 35:     )
// 36:   end
// 37: end
