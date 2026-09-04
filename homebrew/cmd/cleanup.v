module cmd

import ruby
import os

// Translated from Homebrew/brew `cmd/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CleanupCommandRequest {
pub:
	named             []string
	prune             ?string
	dry_run           bool
	scrub             bool
	prune_prefix      bool
	quiet             bool
	cache_files       []string
	disk_cleanup_size i64
	unremovable_kegs  []string
}

pub struct CleanupCommandResult {
pub:
	days          ?int
	removed       []string
	would_remove  []string
	pruned_prefix bool
	output        []string
	errors        []string
}

pub fn cleanup_prune_days(value ?string) !int {
	if raw := value {
		if raw == '' {
			return -1
		}
		if raw == 'all' {
			return 0
		}
		if raw.bytes().all(it >= `0` && it <= `9`) {
			return raw.int()
		}
		return error('`--prune` expects an integer or `all`.')
	}
	return -1
}

fn cleanup_disk_usage_readable(bytes i64) string {
	if bytes >= 1024 * 1024 {
		return '${f64(bytes) / (1024.0 * 1024.0):.1f}MB'
	}
	if bytes >= 1024 {
		return '${f64(bytes) / 1024.0:.1f}KB'
	}
	return '${bytes}B'
}

pub fn run_cleanup_command(request CleanupCommandRequest) !CleanupCommandResult {
	parsed_days := cleanup_prune_days(request.prune)!
	days := if parsed_days >= 0 { ?int(parsed_days) } else { none }
	if request.prune_prefix {
		return CleanupCommandResult{
			days: days
			pruned_prefix: true
		}
	}
	mut removed := []string{}
	mut would_remove := []string{}
	mut output := []string{}
	for path in request.cache_files {
		if !os.exists(path) {
			continue
		}
		if request.dry_run {
			would_remove << path
			output << path
			continue
		}
		if os.is_dir(path) {
			os.rmdir_all(path)!
		} else {
			os.rm(path)!
		}
		removed << path
		output << path
	}
	if request.disk_cleanup_size != 0 {
		disk_space := cleanup_disk_usage_readable(request.disk_cleanup_size)
		if request.dry_run {
			output << 'This operation would free approximately ${disk_space} of disk space.'
		} else {
			output << 'This operation has freed approximately ${disk_space} of disk space.'
		}
	}
	mut errors := []string{}
	if request.unremovable_kegs.len > 0 {
		errors << 'Could not cleanup old kegs! Fix your permissions on:\n  ${request.unremovable_kegs.join('\n  ')}'
	}
	return CleanupCommandResult{
		days: days
		removed: removed
		would_remove: would_remove
		output: output
		errors: errors
	}
}

pub fn cleanup_command_result_to_value(result CleanupCommandResult) ruby.Value {
	return ruby.map_value({
		'days':          if value := result.days {
			ruby.int_value(value)
		} else {
			ruby.object_value('NilClass', 'nil')
		}
		'removed':       ruby.string_array_value(result.removed)
		'would_remove':  ruby.string_array_value(result.would_remove)
		'pruned_prefix': ruby.bool_value(result.pruned_prefix)
		'output':        ruby.string_array_value(result.output)
		'errors':        ruby.string_array_value(result.errors)
	})
}

// Ruby method `run` at line 34.
pub fn ruby_cleanup_l34_d1_run(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_map() or { return ruby.object_value('UsageError', err.msg()) }
	} else {
		map[string]ruby.Value{}
	}
	mut prune := ?string(none)
	if value := values['prune'] {
		if value.type_name != 'NilClass' {
			prune = value.as_string()
		}
	}
	request := CleanupCommandRequest{
		named: if value := values['named'] {
			value.as_string_array() or { []string{} }} else {
			[]string{}}
		prune: prune
		dry_run: if value := values['dry_run'] { value.as_bool() or { false } } else { false }
		scrub: if value := values['scrub'] { value.as_bool() or { false } } else { false }
		prune_prefix: if value := values['prune_prefix'] {
			value.as_bool() or { false }} else {
			false}
		quiet: if value := values['quiet'] { value.as_bool() or { false } } else { false }
		cache_files: if value := values['cache_files'] {
			value.as_string_array() or { []string{} }} else {
			[]string{}}
		disk_cleanup_size: if value := values['disk_cleanup_size'] {
			value.as_int() or { 0 }} else {
			0}
		unremovable_kegs: if value := values['unremovable_kegs'] {
			value.as_string_array() or { []string{} }} else {
			[]string{}}
	}
	result := run_cleanup_command(request) or {
		return ruby.object_value('UsageError', err.msg())
	}
	return cleanup_command_result_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cleanup"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class CleanupCmd < AbstractCommand
// 10:       cmd_args do
// 11:         days = Homebrew::EnvConfig::ENVS[:HOMEBREW_CLEANUP_MAX_AGE_DAYS]&.dig(:default)
// 12:         description <<~EOS
// 13:           Remove stale lock files and outdated downloads for all formulae and casks,
// 14:           and remove old versions of installed formulae. If arguments are specified,
// 15:           only do this for the given formulae and casks. Removes all downloads more than
// 16:           #{days} days old. This can be adjusted with `$HOMEBREW_CLEANUP_MAX_AGE_DAYS`.
// 17:         EOS
// 18:         flag   "--prune=",
// 19:                description: "Remove all cache files older than specified <days>. " \
// 20:                             "If you want to remove everything, use `--prune=all`."
// 21:         switch "-n", "--dry-run",
// 22:                description: "Show what would be removed, but do not actually remove anything."
// 23:         switch "-s", "--scrub",
// 24:                description: "Scrub the cache, including downloads for even the latest versions. " \
// 25:                             "Note that downloads for any installed formulae or casks will still not be deleted. " \
// 26:                             "If you want to delete those too: `rm -rf \"$(brew --cache)\"`"
// 27:         switch "--prune-prefix",
// 28:                description: "Only prune the symlinks and directories from the prefix and remove no other files."
// 29:
// 30:         named_args [:formula, :cask]
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def run
// 35:         days = args.prune.presence&.then do |prune|
// 36:           case prune
// 37:           when /\A\d+\Z/
// 38:             prune.to_i
// 39:           when "all"
// 40:             0
// 41:           else
// 42:             raise UsageError, "`--prune` expects an integer or `all`."
// 43:           end
// 44:         end
// 45:
// 46:         cleanup = Cleanup.new(*args.named, dry_run: args.dry_run?, scrub: args.s?, days:)
// 47:         if args.prune_prefix?
// 48:           cleanup.prune_prefix_symlinks_and_directories
// 49:           return
// 50:         end
// 51:
// 52:         cleanup.clean!(quiet: args.quiet?, periodic: false)
// 53:
// 54:         unless cleanup.disk_cleanup_size.zero?
// 55:           disk_space = Formatter.disk_usage_readable(cleanup.disk_cleanup_size)
// 56:           if args.dry_run?
// 57:             ohai "This operation would free approximately #{disk_space} of disk space."
// 58:           else
// 59:             ohai "This operation has freed approximately #{disk_space} of disk space."
// 60:           end
// 61:         end
// 62:
// 63:         return if cleanup.unremovable_kegs.empty?
// 64:
// 65:         ofail <<~EOS
// 66:           Could not cleanup old kegs! Fix your permissions on:
// 67:             #{cleanup.unremovable_kegs.join "\n  "}
// 68:         EOS
// 69:       end
// 70:     end
// 71:   end
// 72: end
