module cmd

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
