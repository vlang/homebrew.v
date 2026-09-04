module mac

import homebrew
import os

// Translated from Homebrew/brew `extend/os/mac/sandbox.rb`.

// Ruby method `allow_write_temp_and_cache` at line 47.
pub struct MacSandboxCheckContext {
pub:
	function_available bool = true
	result             int
}

pub struct MacSandboxLogResult {
pub:
	syslog_arguments []string
	logs             string
	displayed        bool
}

// Ruby method `home_write_paths` at line 95.
pub fn sandbox_home_write_paths(user_home string) []string {
	return [os.join_path(user_home, 'Library/Developer'),
		os.join_path(user_home, 'Library/Caches/org.swift.swiftpm')]
}

// Ruby method `seatbelt_profile` at line 156.
pub fn sandbox_seatbelt_profile(profile homebrew.SandboxProfile) string {
	mut rules := []string{}
	for rule in profile.rules {
		rules << sandbox_seatbelt_rule(rule)
	}
	return '(version 1)\n(debug deny) ; log all denied operations to /var/log/system.log\n${rules.join('\n')}\n(allow file-write*\n    (literal "/dev/ptmx")\n    (literal "/dev/dtracehelper")\n    (literal "/dev/null")\n    (literal "/dev/random")\n    (literal "/dev/zero")\n    (regex #"^/dev/fd/[0-9]+\$")\n    (regex #"^/dev/tty[a-z0-9]*\$")\n    )\n(deny file-write*) ; deny non-allowlist file write operations\n(deny file-write-setugid) ; deny non-allowlist file write SUID/SGID operations\n(deny file-write-mode) ; deny non-allowlist file write mode operations\n(allow process-exec\n    (literal "/bin/ps")\n    (with no-sandbox)\n    ) ; allow certain processes running without sandbox\n(allow default) ; allow everything else\n'
}

// Ruby method `seatbelt_rule(rule)` at line 161.
pub fn sandbox_seatbelt_rule(rule homebrew.SandboxRule) string {
	mut value := '(' + if rule.allow { 'allow' } else { 'deny' }
	value += ' ${rule.operation}'
	if rule.has_filter {
		value += ' (${sandbox_seatbelt_path_filter(rule.filter)})'
	}
	if rule.modifier != '' {
		value += ' (with ${rule.modifier})'
	}
	return value + ')'
}

// Ruby method `seatbelt_path_filter(filter)` at line 172.
pub fn sandbox_seatbelt_path_filter(filter homebrew.SandboxPathFilter) string {
	return match filter.type_name {
		.regex { 'regex #"${filter.path}"' }
		.subpath { 'subpath "${sandbox_seatbelt_quote(filter.path)}"' }
		.literal { 'literal "${sandbox_seatbelt_quote(filter.path)}"' }
	}
}

// Ruby method `seatbelt_quote(path)` at line 185.
pub fn sandbox_seatbelt_quote(path string) string {
	return path.replace('\\', '\\\\').replace('"', '\\"')
}

fn mac_python_pyc_denial(line string) bool {
	python_start := line.index('Python(') or { return false }
	close := line.index_after(')', python_start + 7) or { return false }
	pid := line[python_start + 7..close]
	return pid != '' && pid.bytes().all(it >= `0` && it <= `9`) && line[close + 1..].contains(' deny file-write') && line.ends_with('pyc')
}
