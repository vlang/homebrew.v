module download_strategy

// Translated from Homebrew/brew `download_strategy/local_bottle_download_strategy.rb`.

pub struct LocalBottleDownloadStrategy {
pub mut:
	file AbstractFileDownloadStrategy
}

pub fn new_local_bottle_download_strategy(path string) LocalBottleDownloadStrategy {
	mut file := new_abstract_file_download_strategy('', '', '', DownloadMeta{})
	file.cached_location_value = path
	return LocalBottleDownloadStrategy{
		file: file
	}
}

pub fn (strategy &LocalBottleDownloadStrategy) cached_location() string {
	return strategy.file.cached_location_value
}

// A local bottle path is consumed directly and must never be removed by cache
// cleanup.
pub fn (strategy &LocalBottleDownloadStrategy) clear_cache() {
	_ = strategy
}
