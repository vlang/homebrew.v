module cmd

import ruby

// Translated from Homebrew/brew `cmd/--cache.rb`.
pub struct FormulaCacheEntry {
pub:
	full_name            string
	cached_download      string
	head_cached_download string
	has_head             bool
	bottles              map[string]string
}

pub struct CaskCacheEntry {
pub:
	token           string
	cached_location string
}

pub type CacheEntry = CaskCacheEntry | FormulaCacheEntry

pub struct CacheOsArch {
pub:
	os   string
	arch string
}

pub struct CacheCommandOptions {
pub:
	fetch_bottle bool
	bottle_tag   ?string
	head         bool
}

pub struct CacheCommandResult {
pub mut:
	paths    []string
	warnings []string
}

fn cache_bottle_tag(options CacheCommandOptions, combination CacheOsArch) string {
	if tag := options.bottle_tag {
		return tag
	}
	return if combination.arch == '' {
		combination.os
	} else {
		'${combination.arch}_${combination.os}'
	}
}

pub fn formula_cache_result(formula FormulaCacheEntry, combination CacheOsArch,
	options CacheCommandOptions) CacheCommandResult {
	if options.fetch_bottle {
		tag := cache_bottle_tag(options, combination)
		if path := formula.bottles[tag] {
			return CacheCommandResult{
				paths: [path]
			}
		}
		return CacheCommandResult{
			warnings: ["Bottle for tag '${tag}' is unavailable."]
		}
	}
	if options.head {
		if formula.has_head {
			return CacheCommandResult{
				paths: [formula.head_cached_download]
			}
		}
		return CacheCommandResult{
			warnings: ['No head is defined for ${formula.full_name}.']
		}
	}
	return CacheCommandResult{
		paths: [formula.cached_download]
	}
}

pub fn cask_cache_result(cask CaskCacheEntry) CacheCommandResult {
	return CacheCommandResult{
		paths: [cask.cached_location]
	}
}

pub fn cache_command(cache_root string, entries []CacheEntry, combinations []CacheOsArch,
	options CacheCommandOptions) CacheCommandResult {
	if entries.len == 0 {
		return CacheCommandResult{
			paths: [cache_root]
		}
	}
	actual_combinations := if combinations.len == 0 {
		[CacheOsArch{}]
	} else {
		combinations
	}
	mut result := CacheCommandResult{}
	for entry in entries {
		match entry {
			FormulaCacheEntry {
				for combination in actual_combinations {
					item := formula_cache_result(entry, combination, options)
					result.paths << item.paths
					result.warnings << item.warnings
				}
			}
			CaskCacheEntry {
				for combination in actual_combinations {
					if combination.os == 'linux' {
						continue
					}
					item := cask_cache_result(entry)
					result.paths << item.paths
				}
			}
		}
	}
	return result
}

pub fn formula_cache_entry_value(formula FormulaCacheEntry) ruby.Value {
	mut bottles := map[string]ruby.Value{}
	for tag, path in formula.bottles {
		bottles[tag] = ruby.string_value(path)
	}
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		attributes: {
			'full_name':            formula.full_name
			'cached_download':      formula.cached_download
			'head_cached_download': formula.head_cached_download
			'has_head':             formula.has_head.str()
		}
		map_data: {
			'bottles': ruby.map_value(bottles)
		}
	}
}

pub fn cask_cache_entry_value(cask CaskCacheEntry) ruby.Value {
	return ruby.structured_value('Cask', cask.token, {
		'token':           cask.token
		'cached_location': cask.cached_location
	})
}

fn cache_entry_from_value(value ruby.Value) CacheEntry {
	if value.type_name == 'Cask' {
		return CaskCacheEntry{
			token: value.attribute('token') or { value.as_string() }
			cached_location: value.attribute('cached_location') or { '' }
		}
	}
	mut bottles := map[string]string{}
	if bottle_value := value.map_data['bottles'] {
		for tag, path in bottle_value.map_data {
			bottles[tag] = path.as_string()
		}
	}
	return FormulaCacheEntry{
		full_name: value.attribute('full_name') or { value.as_string() }
		cached_download: value.attribute('cached_download') or { '' }
		head_cached_download: value.attribute('head_cached_download') or { '' }
		has_head: (value.attribute('has_head') or { 'false' }) == 'true'
		bottles: bottles
	}
}

pub fn cache_combination_value(combination CacheOsArch) ruby.Value {
	return ruby.structured_value('OsArch', '${combination.os}/${combination.arch}', {
		'os':   combination.os
		'arch': combination.arch
	})
}

pub fn cache_options_value(options CacheCommandOptions) ruby.Value {
	return ruby.structured_value('CacheCommandOptions', '', {
		'fetch_bottle':   options.fetch_bottle.str()
		'bottle_tag':     options.bottle_tag or { '' }
		'has_bottle_tag': (options.bottle_tag != none).str()
		'head':           options.head.str()
	})
}

fn cache_options_from_value(value ruby.Value) CacheCommandOptions {
	return CacheCommandOptions{
		fetch_bottle: (value.attribute('fetch_bottle') or { 'false' }) == 'true'
		bottle_tag: if (value.attribute('has_bottle_tag') or { 'false' }) == 'true' {
			?string(value.attribute('bottle_tag') or { '' })
		} else {
			none
		}
		head: (value.attribute('head') or { 'false' }) == 'true'
	}
}

fn cache_result_value(result CacheCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'CacheCommandResult'
		repr: result.paths.join('\n')
		map_data: {
			'paths':    ruby.string_array_value(result.paths)
			'warnings': ruby.string_array_value(result.warnings)
		}
	}
}
