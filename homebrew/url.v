module homebrew

import homebrew.download_strategy

// Translated from Homebrew/brew `url.rb`.
// The original source is retained below until every stub has a typed V body.

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
		raw_url:          url
		specs:            specs
		using_symbol:     using_symbol
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

// Ruby attr_reader `attr_reader :specs` at line 8.
pub fn ruby_url_l8_d1_specs(url Url) map[string]string {
	return url.specs
}

// Ruby attr_reader `attr_reader :using` at line 11.
pub fn ruby_url_l11_d2_using(url Url) ?string {
	return url.using()
}

// Ruby method `initialize(url, specs = {})` at line 14.
pub fn ruby_url_l14_d3_initialize(url string, specs map[string]string) Url {
	return new_url(url, specs)
}

// Ruby method `to_s` at line 22.
pub fn ruby_url_l22_d4_to_s(url Url) string {
	return url.to_s()
}

// Ruby method `download_strategy` at line 27.
pub fn ruby_url_l27_d5_download_strategy(url Url) !download_strategy.DownloadStrategy {
	return url.download_strategy()
}

// Ruby method `version` at line 33.
pub fn ruby_url_l33_d6_version(url Url) Version {
	return url.version()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: class URL
// 7:   sig { returns(T::Hash[Symbol, T.untyped]) }
// 8:   attr_reader :specs
// 9:
// 10:   sig { returns(T.nilable(T.any(Symbol, T::Class[AbstractDownloadStrategy]))) }
// 11:   attr_reader :using
// 12:
// 13:   sig { params(url: String, specs: T::Hash[Symbol, T.untyped]).void }
// 14:   def initialize(url, specs = {})
// 15:     @url = T.let(url.freeze, String)
// 16:     @specs = T.let(specs.dup, T::Hash[Symbol, T.untyped])
// 17:     @using = T.let(@specs.delete(:using), T.nilable(T.any(Symbol, T::Class[AbstractDownloadStrategy])))
// 18:     @specs.freeze
// 19:   end
// 20:
// 21:   sig { returns(String) }
// 22:   def to_s
// 23:     @url
// 24:   end
// 25:
// 26:   sig { returns(T::Class[AbstractDownloadStrategy]) }
// 27:   def download_strategy
// 28:     @download_strategy ||=
// 29:       T.let(DownloadStrategyDetector.detect(@url, @using), T.nilable(T::Class[AbstractDownloadStrategy]))
// 30:   end
// 31:
// 32:   sig { returns(Version) }
// 33:   def version
// 34:     @version ||= T.let(Version.detect(@url, **@specs), T.nilable(Version))
// 35:   end
// 36: end
