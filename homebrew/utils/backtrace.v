module utils

// Translated from Homebrew/brew `utils/backtrace.rb`.

pub struct BacktraceCleanResult {
pub:
	has_backtrace        bool
	backtrace            []string
	removed_sorbet_lines bool
}

pub struct BacktraceMessageResult {
pub:
	printed bool
	warning string
	stdout  string
}

pub fn clean_backtrace(has_backtrace bool, backtrace []string, verbose bool, sorbet_path string) BacktraceCleanResult {
	if !has_backtrace {
		return BacktraceCleanResult{}
	}
	if verbose || backtrace.len == 0 || backtrace[0].starts_with(sorbet_path) {
		return BacktraceCleanResult{
			has_backtrace: true
			backtrace: backtrace.clone()
		}
	}
	cleaned := backtrace.filter(!it.starts_with(sorbet_path))
	return BacktraceCleanResult{
		has_backtrace: true
		backtrace: cleaned
		removed_sorbet_lines: cleaned.len < backtrace.len
	}
}

pub fn sorbet_runtime_path(gem_home string) string {
	return '${gem_home}/gems/sorbet-runtime'
}

pub fn print_backtrace_message(already_printed bool, github_actions bool, no_env_hints bool) BacktraceMessageResult {
	if already_printed {
		return BacktraceMessageResult{
			printed: true
		}
	}
	return BacktraceMessageResult{
		printed: true
		warning: if github_actions { '' } else { 'Removed Sorbet lines from backtrace!' }
		stdout: if no_env_hints {
			''
		} else {
			'Rerun with `--verbose` to see the original backtrace\n'
		}
	}
}

pub fn tap_error_url(has_backtrace bool, backtrace []string) string {
	if !has_backtrace {
		return ''
	}
	marker := '/Library/Taps/'
	for line in backtrace {
		start := line.index(marker) or { continue }
		remainder := line[start + marker.len..]
		parts := remainder.split('/')
		if parts.len >= 2 && parts[0].len > 0 && parts[1].len > 0 {
			return 'https://github.com/${parts[0]}/${parts[1]}/issues/new'
		}
	}
	return ''
}
