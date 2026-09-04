module cmd

import ruby
import os

// Translated from Homebrew/brew `cmd/cleanup.rb`.
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
