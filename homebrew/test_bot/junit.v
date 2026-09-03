module test_bot

import brew_runtime
import os

pub struct JunitStep {
pub:
	command_short string
	status        string
	time          string
	start_time    string
	passed        bool
	command       []string
}

pub struct JunitTest {
pub:
	steps []JunitStep
}

pub struct Junit {
pub:
	tests []JunitTest
	tag   string
pub mut:
	xml_document string
}

// Translated from Homebrew/brew `test_bot/junit.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(tests)` at line 10.
pub fn ruby_junit_l10_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	tests := if args.len > 0 { junit_tests_from_value(args[0]) } else { []JunitTest{} }
	return brew_runtime.map_value({
		'tests':        brew_runtime.int_value(tests.len)
		'xml_document': brew_runtime.object_value('NilClass', 'nil')
	})
}

// Ruby method `build(filters: nil)` at line 20.
pub fn ruby_junit_l20_d2_build(args ...brew_runtime.Value) brew_runtime.Value {
	tests := if args.len > 0 { junit_tests_from_value(args[0]) } else { []JunitTest{} }
	filters := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	tag := if args.len > 2 {
		args[2].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_TEST_BOT_TAG')
	}
	mut junit := new_junit(tests, tag)
	return brew_runtime.string_value(junit.build(filters))
}

// Ruby method `write(filename)` at line 52.
pub fn ruby_junit_l52_d3_write(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('RuntimeError', 'Junit.write requires a filename and built XML document')
	}
	write_junit(args[0].as_string(), args[1].as_string()) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_junit(tests []JunitTest, tag string) Junit {
	return Junit{
		tests: tests.clone()
		tag: tag
	}
}

pub fn (mut junit Junit) build(filters []string) string {
	mut lines := ["<?xml version='1.0'?>", '<testsuites>']
	for test in junit.tests {
		if test.steps.len == 0 {
			continue
		}
		suite_name := junit_xml_attribute('brew-test-bot.' + junit.tag)
		lines << "  <testsuite name='${suite_name}' timestamp='${junit_xml_attribute(test.steps[0].start_time)}'>"
		for step in test.steps {
			if !filters.any(step.command_short.starts_with(it)) {
				continue
			}
			attributes := "name='${junit_xml_attribute(step.command_short)}' status='${junit_xml_attribute(step.status)}' time='${junit_xml_attribute(step.time)}' timestamp='${junit_xml_attribute(step.start_time)}'"
			if step.passed {
				lines << '    <testcase ${attributes}/>'
				continue
			}
			lines << '    <testcase ${attributes}>'
			message := '${step.status}: ${step.command.join(' ')}'
			lines << "      <failure message='${junit_xml_attribute(message)}'/>"
			lines << '    </testcase>'
		}
		lines << '  </testsuite>'
	}
	lines << '</testsuites>'
	junit.xml_document = lines.join('\n')
	return junit.xml_document
}

pub fn (junit Junit) write(filename string) ! {
	if junit.xml_document == '' {
		return error('Junit report has not been built')
	}
	write_junit(filename, junit.xml_document)!
}

pub fn write_junit(filename string, document string) ! {
	if os.exists(filename) {
		os.rm(filename)!
	}
	os.write_file(filename, document)!
}

fn junit_xml_attribute(value string) string {
	return value.replace('&', '&amp;').replace("'", '&apos;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')
}

fn junit_tests_from_value(value brew_runtime.Value) []JunitTest {
	values := value.as_array() or { return [] }
	mut tests := []JunitTest{cap: values.len}
	for test_value in values {
		test_map := test_value.as_map() or { continue }
		step_values := (test_map['steps'] or { continue }).as_array() or { continue }
		mut steps := []JunitStep{cap: step_values.len}
		for step_value in step_values {
			step := step_value.as_map() or { continue }
			steps << JunitStep{
				command_short: (step['command_short'] or { brew_runtime.string_value('') }).as_string()
				status: (step['status'] or { brew_runtime.string_value('') }).as_string()
				time: (step['time'] or { brew_runtime.string_value('') }).as_string()
				start_time: (step['start_time'] or { brew_runtime.string_value('') }).as_string()
				passed: (step['passed'] or { brew_runtime.bool_value(false) }).bool_data
				command: (step['command'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
			}
		}
		tests << JunitTest{ steps: steps }
	}
	return tests
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     # Creates Junit report with only required by BuildPulse attributes
// 7:     # See https://github.com/Homebrew/homebrew-test-bot/pull/621#discussion_r658712640
// 8:     class Junit
// 9:       sig { params(tests: T::Array[Test]).void }
// 10:       def initialize(tests)
// 11:         require "rexml/document"
// 12:         require "rexml/xmldecl"
// 13:         require "rexml/cdata"
// 14:
// 15:         @tests = tests
// 16:         @xml_document = T.let(nil, T.nilable(REXML::Document))
// 17:       end
// 18:
// 19:       sig { params(filters: T.nilable(T::Array[String])).void }
// 20:       def build(filters: nil)
// 21:         filters ||= []
// 22:
// 23:         @xml_document = REXML::Document.new
// 24:         @xml_document << REXML::XMLDecl.new
// 25:         testsuites = @xml_document.add_element "testsuites"
// 26:
// 27:         @tests.each do |test|
// 28:           next if test.steps.empty?
// 29:
// 30:           testsuite = testsuites.add_element "testsuite"
// 31:           testsuite.add_attribute "name", "brew-test-bot.#{Utils::Bottles.tag}"
// 32:           testsuite.add_attribute "timestamp", T.must(test.steps.fetch(0).start_time).iso8601
// 33:
// 34:           test.steps.each do |step|
// 35:             next unless filters.any? { |filter| step.command_short.start_with? filter }
// 36:
// 37:             testcase = testsuite.add_element "testcase"
// 38:             testcase.add_attribute "name", step.command_short
// 39:             testcase.add_attribute "status", step.status
// 40:             testcase.add_attribute "time", step.time
// 41:             testcase.add_attribute "timestamp", T.must(step.start_time).iso8601
// 42:
// 43:             next if step.passed?
// 44:
// 45:             elem = testcase.add_element "failure"
// 46:             elem.add_attribute "message", "#{step.status}: #{step.command.join(" ")}"
// 47:           end
// 48:         end
// 49:       end
// 50:
// 51:       sig { params(filename: String).void }
// 52:       def write(filename)
// 53:         output_path = Pathname(filename)
// 54:         output_path.unlink if output_path.exist?
// 55:         output_path.open("w") do |xml_file|
// 56:           pretty_print_indent = 2
// 57:           T.must(@xml_document).write(xml_file, pretty_print_indent)
// 58:         end
// 59:       end
// 60:     end
// 61:   end
// 62: end
