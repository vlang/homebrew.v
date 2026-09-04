module bundle

import ruby
import os

// Translated from Homebrew/brew `bundle/adder.rb`.

pub struct BundleAddOptions {
pub:
	items        []string
	entry_type   string
	file         string
	describe     bool
	descriptions map[string]string
	taps         []string
}

pub struct BundleAddResult {
pub:
	path             string
	content          string
	ensured_taps     []string
	trusted_type     string
	trusted_items    []string
	appended_entries []string
}

fn bundle_entry_description_lines(description string) string {
	return description.split_into_lines().map('# ${it}\n').join('')
}

pub fn render_bundle_add_entry(entry_type string, item string, description string,
	describe bool) string {
	entry := '${entry_type} "${item}"'
	if describe && description.trim_space() != '' {
		return '${bundle_entry_description_lines(description)}${entry}'
	}
	return entry
}

pub fn add_bundle_entries(options BundleAddOptions) !BundleAddResult {
	if options.entry_type !in ['brew', 'cask'] && options.entry_type.trim_space() == '' {
		return error('bundle entry type is required')
	}
	if options.file.trim_space() == '' {
		return error('Brewfile path is required')
	}
	parent := os.dir(options.file)
	if !os.is_dir(parent) {
		os.mkdir_all(parent)!
	}
	mut existing := if os.exists(options.file) { os.read_file(options.file)! } else { '' }
	mut entries := []string{cap: options.items.len}
	for item in options.items {
		entries << render_bundle_add_entry(options.entry_type, item, options.descriptions[item], options.describe)
	}
	if entries.len > 0 {
		existing += '${entries.join('\n')}\n'
	}
	ruby.atomic_write_file(options.file, existing)!
	trusted_type := match options.entry_type {
		'brew' { 'formula' }
		'cask' { 'cask' }
		else { '' }
	}
	return BundleAddResult{
		path: options.file
		content: existing
		ensured_taps: options.taps.clone()
		trusted_type: trusted_type
		trusted_items: if trusted_type != '' { options.items.clone() } else { [] }
		appended_entries: entries
	}
}

fn bundle_add_descriptions_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return map[string]string{} }
	mut descriptions := map[string]string{}
	for name, description in values {
		descriptions[name] = description.as_string()
	}
	return descriptions
}

fn bundle_add_result_value(result BundleAddResult) ruby.Value {
	return ruby.structured_value('Bundle::Adder::Result', result.path, {
		'path':             result.path
		'content':          result.content
		'ensured_taps':     result.ensured_taps.join(',')
		'trusted_type':     result.trusted_type
		'trusted_items':    result.trusted_items.join(',')
		'appended_entries': result.appended_entries.join('\n')
	})
}
