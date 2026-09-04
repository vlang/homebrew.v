module homebrew

import ruby

// Translated from Homebrew/brew `formula_assertions.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaAssertions {
mut:
	assertion_count int
pub:
	verbose bool
}

// Ruby attr_writer `attr_writer :assertions` at line 20.
pub fn (mut assertions FormulaAssertions) set_assertion_count(value int) int {
	assertions.assertion_count = value
	return value
}

// Ruby method `assertions` at line 23.
pub fn (assertions &FormulaAssertions) assertions() int {
	return assertions.assertion_count
}

// Ruby method `assert_equal(exp, act, msg = nil)` at line 28.
pub fn (mut assertions FormulaAssertions) assert_equal[T](expected T, actual T,
	message string) !bool {
	assertions.assertion_count++
	if expected == actual {
		return true
	}
	prefix := if message == '' { '' } else { '${message}: ' }
	return error('${prefix}Expected ${expected}, got ${actual}')
}

pub fn (mut assertions FormulaAssertions) assert_nil[T](actual ?T, message string) !bool {
	assertions.assertion_count++
	if value := actual {
		prefix := if message == '' { '' } else { '${message}: ' }
		return error('${prefix}Expected ${value} to be nil')
	}
	return true
}

// Ruby method `shell_output(cmd, result = 0)` at line 39.
pub fn (mut assertions FormulaAssertions) shell_output(command string,
	expected_status int) !string {
	result := ruby.run_captured_command(['/bin/sh', '-c', command], ruby.CapturedCommandOptions{ environment: ruby.environment() })!
	assertions.assert_equal(expected_status, result.exit_code, 'command `${command}` exit status') or {
		if assertions.verbose && result.stdout != '' {
			return error('${err.msg()}\n${result.stdout}')
		}
		return err
	}
	return result.stdout
}

// Ruby method `pipe_output(cmd, input = nil, result = nil)` at line 55.
pub fn (mut assertions FormulaAssertions) pipe_output(command string, input string,
	expected_status ?int) !string {
	result := ruby.run_captured_command(['/bin/sh', '-c', command], ruby.CapturedCommandOptions{
		environment: ruby.environment()
		input: input
	})!
	if status := expected_status {
		assertions.assert_equal(status, result.exit_code, 'command `${command}` exit status') or {
			if assertions.verbose && result.stdout != '' {
				return error('${err.msg()}\n${result.stdout}')
			}
			return err
		}
	}
	return result.stdout
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Homebrew
// 7:   # Helper functions available in formula `test` blocks.
// 8:   module Assertions
// 9:     include Context
// 10:     include ::Utils::Output::Mixin
// 11:     extend T::Helpers
// 12:
// 13:     requires_ancestor { Kernel }
// 14:
// 15:     require "minitest"
// 16:     require "minitest/assertions"
// 17:     include ::Minitest::Assertions
// 18:
// 19:     sig { params(assertions: Integer).returns(Integer) }
// 20:     attr_writer :assertions
// 21:
// 22:     sig { returns(Integer) }
// 23:     def assertions
// 24:       @assertions ||= T.let(0, T.nilable(Integer))
// 25:     end
// 26:
// 27:     sig { params(exp: Object, act: Object, msg: T.nilable(String)).returns(TrueClass) }
// 28:     def assert_equal(exp, act, msg = nil)
// 29:       return super unless exp.nil?
// 30:
// 31:       odisabled "assert_equal(nil, ...)", "assert_nil(...)"
// 32:       assert_nil(act, msg)
// 33:     end
// 34:
// 35:     # Returns the output of running cmd and asserts the exit status.
// 36:     #
// 37:     # @api public
// 38:     sig { params(cmd: T.any(Pathname, String), result: Integer).returns(String) }
// 39:     def shell_output(cmd, result = 0)
// 40:       ohai cmd.to_s
// 41:       assert_path_exists cmd, "Pathname '#{cmd}' does not exist!" if cmd.is_a?(Pathname)
// 42:       output = `#{cmd}`
// 43:       assert_equal result, $CHILD_STATUS.exitstatus
// 44:       output
// 45:     rescue Minitest::Assertion
// 46:       puts output if verbose?
// 47:       raise
// 48:     end
// 49:
// 50:     # Returns the output of running the cmd with the optional input and
// 51:     # optionally asserts the exit status.
// 52:     #
// 53:     # @api public
// 54:     sig { params(cmd: T.any(String, Pathname), input: T.nilable(String), result: T.nilable(Integer)).returns(String) }
// 55:     def pipe_output(cmd, input = nil, result = nil)
// 56:       ohai cmd.to_s
// 57:       assert_path_exists cmd, "Pathname '#{cmd}' does not exist!" if cmd.is_a?(Pathname)
// 58:       output = IO.popen(cmd, "w+") do |pipe|
// 59:         pipe.write(input) unless input.nil?
// 60:         pipe.close_write
// 61:         pipe.read
// 62:       end
// 63:       assert_equal result, $CHILD_STATUS.exitstatus unless result.nil?
// 64:       output
// 65:     rescue Minitest::Assertion
// 66:       puts output if verbose?
// 67:       raise
// 68:     end
// 69:   end
// 70: end
