module test_bot

import ruby
import homebrew.test_bot as junit_core
import os

// Translated from Homebrew/brew `test/test_bot/junit_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "loads REXML and produces valid JUnit XML without NameError" do` at line 11.
pub fn ruby_junit_spec_l11_d1_loads(args ...ruby.Value) ruby.Value {
	mut junit := junit_core.new_junit([junit_core.JunitTest{
		steps: [junit_core.JunitStep{
			command_short: 'audit'
			status: 'passed'
			time: '1.5'
			start_time: '2024-01-15T12:00:00Z'
			passed: true
			command: ['brew', 'audit', 'foo']
		}]
	}], 'arm64_sonoma')
	junit.build(['audit'])
	path := os.join_path(os.temp_dir(), 'brew-v-junit-passed-${os.getpid()}.xml')
	defer { os.rm(path) or {} }
	junit.write(path) or { return ruby.bool_value(false) }
	content := os.read_file(path) or { return ruby.bool_value(false) }
	return ruby.bool_value(os.exists(path) && content.contains('<?xml')
		&& content.contains('testsuites') && content.contains('testcase')
		&& content.contains("name='audit'"))
}

// Ruby it `it "includes failure element when a step did not pass" do` at line 40.
pub fn ruby_junit_spec_l40_d2_includes(args ...ruby.Value) ruby.Value {
	mut junit := junit_core.new_junit([junit_core.JunitTest{
		steps: [junit_core.JunitStep{
			command_short: 'test'
			status: 'failed'
			time: '2.0'
			start_time: '2024-01-15T12:00:00Z'
			command: ['brew', 'test', 'foo']
		}]
	}], 'arm64_sonoma')
	junit.build(['test'])
	path := os.join_path(os.temp_dir(), 'brew-v-junit-failed-${os.getpid()}.xml')
	defer { os.rm(path) or {} }
	junit.write(path) or { return ruby.bool_value(false) }
	content := os.read_file(path) or { return ruby.bool_value(false) }
	return ruby.bool_value(content.contains('<failure ') && content.contains('failed'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::Junit do
// 7:   # Regression test: Junit requires REXML before use. Without the require calls in #initialize,
// 8:   # environments that don't load REXML elsewhere (e.g. Linux CI) raise
// 9:   # "uninitialized constant Homebrew::TestBot::Junit::REXML".
// 10:   describe "#initialize and #build and #write" do
// 11:     it "loads REXML and produces valid JUnit XML without NameError" do
// 12:       start_time = Time.utc(2024, 1, 15, 12, 0, 0)
// 13:       step = instance_double(
// 14:         Homebrew::TestBot::Step,
// 15:         command_short: "audit",
// 16:         status:        :passed,
// 17:         time:          1.5,
// 18:         start_time:    start_time,
// 19:         passed?:       true,
// 20:         command:       ["brew", "audit", "foo"],
// 21:       )
// 22:       test = instance_double(Homebrew::TestBot::Test, steps: [step])
// 23:
// 24:       junit = described_class.new([test])
// 25:       junit.build(filters: ["audit"])
// 26:
// 27:       Dir.mktmpdir do |tmpdir|
// 28:         path = "#{tmpdir}/junit.xml"
// 29:         junit.write(path)
// 30:
// 31:         expect(File).to exist(path)
// 32:         content = File.read(path)
// 33:         expect(content).to include("<?xml")
// 34:         expect(content).to include("testsuites")
// 35:         expect(content).to include("testcase")
// 36:         expect(content).to include("name='audit'")
// 37:       end
// 38:     end
// 39:
// 40:     it "includes failure element when a step did not pass" do
// 41:       start_time = Time.utc(2024, 1, 15, 12, 0, 0)
// 42:       step = instance_double(
// 43:         Homebrew::TestBot::Step,
// 44:         command_short: "test",
// 45:         status:        :failed,
// 46:         time:          2.0,
// 47:         start_time:    start_time,
// 48:         passed?:       false,
// 49:         command:       ["brew", "test", "foo"],
// 50:       )
// 51:       test = instance_double(Homebrew::TestBot::Test, steps: [step])
// 52:
// 53:       junit = described_class.new([test])
// 54:       junit.build(filters: ["test"])
// 55:
// 56:       Dir.mktmpdir do |tmpdir|
// 57:         path = "#{tmpdir}/junit.xml"
// 58:         junit.write(path)
// 59:
// 60:         content = File.read(path)
// 61:         expect(content).to include("<failure ")
// 62:         expect(content).to include("failed")
// 63:       end
// 64:     end
// 65:   end
// 66: end
