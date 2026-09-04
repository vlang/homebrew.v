module homebrew

import homebrew.download_strategy

// Translated from Homebrew/brew `url.rb`.

// Url is the typed V equivalent of Homebrew's URL value object.
pub struct Url {
	raw_url string
pub:
	specs map[string]string
mut:
	using_symbol      string
	has_using_symbol  bool
	strategy_override ?download_strategy.DownloadStrategy
}

// new_url translates URL#initialize, duplicating specs and removing :using.
pub fn new_url(url string, source_specs map[string]string) Url {
	mut specs := source_specs.clone()
	mut using_symbol := ''
	mut has_using_symbol := false
	if requested := specs['using'] {
		using_symbol = requested
		has_using_symbol = true
		specs.delete('using')
	}
	return Url{
		raw_url: url
		specs: specs
		using_symbol: using_symbol
		has_using_symbol: has_using_symbol
	}
}

// new_url_with_strategy represents Ruby's concrete strategy-class :using value.
pub fn new_url_with_strategy(url string, source_specs map[string]string, strategy download_strategy.DownloadStrategy) Url {
	mut value := new_url(url, source_specs)
	value.using_symbol = ''
	value.has_using_symbol = false
	value.strategy_override = strategy
	return value
}

// to_s translates URL#to_s.
pub fn (url Url) to_s() string {
	return url.raw_url
}

// using translates URL#using for a symbolic strategy specification.
pub fn (url Url) using() ?string {
	if url.has_using_symbol {
		return url.using_symbol
	}
	if strategy := url.strategy_override {
		return strategy.class_name()
	}
	return none
}

// download_strategy translates URL#download_strategy.
pub fn (url Url) download_strategy() !download_strategy.DownloadStrategy {
	if strategy := url.strategy_override {
		return strategy
	}
	if url.has_using_symbol {
		return download_strategy.detect_from_symbol(url.using_symbol)
	}
	return download_strategy.detect_from_url(url.raw_url)
}

// version translates URL#version and forwards the retained :tag spec.
pub fn (url Url) version() Version {
	tag := url.specs['tag'] or { '' }
	return detect_version(url.raw_url, tag)
}
