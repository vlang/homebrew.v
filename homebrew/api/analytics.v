module api

import x.json2

// Translated from Homebrew/brew `api/analytics.rb`.
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
