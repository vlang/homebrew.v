module api

import x.json2

// Translated from Homebrew/brew `api/analytics.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AnalyticsItem {
pub:
	formula    string
	cask       string
	os_version string
	count      string
}

pub struct AnalyticsResponse {
pub:
	items []AnalyticsItem
}

pub struct AnalyticsFetchConfig {
pub:
	responses map[string]string
}

pub fn analytics_api_path() string {
	return 'analytics'
}

pub fn analytics_endpoint(category string, days string) string {
	return '${analytics_api_path()}/${category}/${days}d.json'
}

// The enclosing API fetcher remains injectable until Homebrew::API.fetch is
// translated. Tests and offline callers provide the exact endpoint response.
pub fn fetch_analytics(category string, days string, config AnalyticsFetchConfig) !AnalyticsResponse {
	endpoint := analytics_endpoint(category, days)
	payload := config.responses[endpoint] or {
		return error('analytics API response unavailable for ${endpoint}')
	}
	return json2.decode[AnalyticsResponse](payload)!
}

// Ruby method `analytics_api_path` at line 10.
pub fn ruby_analytics_l10_analytics_api_path() string {
	return analytics_api_path()
}

// Ruby method `fetch(category, days)` at line 15.
pub fn ruby_analytics_l15_fetch(category string, days string,
	config AnalyticsFetchConfig) !AnalyticsResponse {
	return fetch_analytics(category, days, config)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module API
// 6:     # Helper functions for using the analytics JSON API.
// 7:     module Analytics
// 8:       class << self
// 9:         sig { returns(String) }
// 10:         def analytics_api_path
// 11:           "analytics"
// 12:         end
// 13:
// 14:         sig { params(category: String, days: T.any(Integer, String)).returns(T::Hash[String, T.untyped]) }
// 15:         def fetch(category, days)
// 16:           Homebrew::API.fetch "#{analytics_api_path}/#{category}/#{days}d.json"
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
