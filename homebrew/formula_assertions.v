module homebrew

import ruby

// Translated from Homebrew/brew `formula_assertions.rb`.
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
