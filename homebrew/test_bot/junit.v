module test_bot

import ruby
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

fn junit_tests_from_value(value ruby.Value) []JunitTest {
	values := value.as_array() or { return [] }
	mut tests := []JunitTest{cap: values.len}
	for test_value in values {
		test_map := test_value.as_map() or { continue }
		step_values := (test_map['steps'] or { continue }).as_array() or { continue }
		mut steps := []JunitStep{cap: step_values.len}
		for step_value in step_values {
			step := step_value.as_map() or { continue }
			steps << JunitStep{
				command_short: (step['command_short'] or { ruby.string_value('') }).as_string()
				status: (step['status'] or { ruby.string_value('') }).as_string()
				time: (step['time'] or { ruby.string_value('') }).as_string()
				start_time: (step['start_time'] or { ruby.string_value('') }).as_string()
				passed: (step['passed'] or { ruby.bool_value(false) }).bool_data
				command: (step['command'] or { ruby.string_array_value([]) }).as_string_array() or { [] }
			}
		}
		tests << JunitTest{ steps: steps }
	}
	return tests
}
