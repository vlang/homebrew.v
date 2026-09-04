module utils

import ruby

// Translated from Homebrew/brew `utils/backtrace.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct BacktraceCleanResult {
pub:
	has_backtrace bool
	backtrace     []string
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
		stdout: if no_env_hints { '' } else { 'Rerun with `--verbose` to see the original backtrace\n' }
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

// Ruby method `self.clean(error)` at line 17.
pub fn ruby_backtrace_l17_d1_self_clean(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'error is required')
	}
	has_backtrace := args[0].type_name !in ['Nil', 'NilClass', '']
	backtrace := if has_backtrace { args[0].as_string_array() or { []string{} } } else { []string{} }
	verbose := args.len > 1 && (args[1].as_bool() or { false })
	path := if args.len > 2 { args[2].as_string() } else { sorbet_runtime_path('') }
	result := clean_backtrace(has_backtrace, backtrace, verbose, path)
	return if result.has_backtrace {
		ruby.string_array_value(result.backtrace)
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Ruby method `self.sorbet_runtime_path` at line 30.
pub fn ruby_backtrace_l30_d2_self_sorbet_runtime_path(args ...ruby.Value) ruby.Value {
	gem_home := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value(sorbet_runtime_path(gem_home))
}

// Ruby method `self.print_backtrace_message` at line 35.
pub fn ruby_backtrace_l35_d3_self_print_backtrace_message(args ...ruby.Value) ruby.Value {
	already_printed := args.len > 0 && (args[0].as_bool() or { false })
	github_actions := args.len > 1 && (args[1].as_bool() or { false })
	no_env_hints := args.len > 2 && (args[2].as_bool() or { false })
	result := print_backtrace_message(already_printed, github_actions, no_env_hints)
	return ruby.map_value({
		'printed': ruby.bool_value(result.printed)
		'warning': ruby.string_value(result.warning)
		'stdout': ruby.string_value(result.stdout)
	})
}

// Ruby method `self.tap_error_url(error)` at line 46.
pub fn ruby_backtrace_l46_d4_self_tap_error_url(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name in ['Nil', 'NilClass', ''] {
		return ruby.object_value('NilClass', '')
	}
	backtrace := args[0].as_string_array() or { []string{} }
	url := tap_error_url(true, backtrace)
	return if url.len > 0 {
		ruby.string_value(url)
	} else {
		ruby.object_value('NilClass', '')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   module Backtrace
// 8:     extend Utils::Output::Mixin
// 9:
// 10:     @print_backtrace_message = T.let(false, T::Boolean)
// 11:
// 12:     # Cleans `sorbet-runtime` gem paths from the backtrace unless...
// 13:     # 1. `verbose` is set
// 14:     # 2. first backtrace line starts with `sorbet-runtime`
// 15:     #   - This implies that the error is related to Sorbet.
// 16:     sig { params(error: Exception).returns(T.nilable(T::Array[String])) }
// 17:     def self.clean(error)
// 18:       backtrace = error.backtrace
// 19:
// 20:       return backtrace if Context.current.verbose?
// 21:       return backtrace if backtrace.blank?
// 22:       return backtrace if backtrace.fetch(0).start_with?(sorbet_runtime_path)
// 23:
// 24:       old_backtrace_length = backtrace.length
// 25:       backtrace.reject { |line| line.start_with?(sorbet_runtime_path) }
// 26:                .tap { |new_backtrace| print_backtrace_message if old_backtrace_length > new_backtrace.length }
// 27:     end
// 28:
// 29:     sig { returns(String) }
// 30:     def self.sorbet_runtime_path
// 31:       @sorbet_runtime_path ||= T.let("#{Gem.paths.home}/gems/sorbet-runtime", T.nilable(String))
// 32:     end
// 33:
// 34:     sig { void }
// 35:     def self.print_backtrace_message
// 36:       return if @print_backtrace_message
// 37:
// 38:       # This is just unactionable noise in GitHub Actions.
// 39:       opoo_outside_github_actions "Removed Sorbet lines from backtrace!"
// 40:       puts "Rerun with `--verbose` to see the original backtrace" unless Homebrew::EnvConfig.no_env_hints?
// 41:
// 42:       @print_backtrace_message = true
// 43:     end
// 44:
// 45:     sig { params(error: Exception).returns(T.nilable(String)) }
// 46:     def self.tap_error_url(error)
// 47:       backtrace = error.backtrace
// 48:       return if backtrace.blank?
// 49:
// 50:       backtrace.each do |line|
// 51:         if (tap = line.match(%r{/Library/Taps/([^/]+/[^/]+)/}))
// 52:           return "https://github.com/#{tap[1]}/issues/new"
// 53:         end
// 54:       end
// 55:
// 56:       nil
// 57:     end
// 58:   end
// 59: end
