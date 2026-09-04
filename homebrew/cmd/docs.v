module cmd

import homebrew.extend

// Translated from Homebrew/brew `cmd/docs.rb`.
pub const homebrew_docs_url = 'https://docs.brew.sh'

pub fn docs_browser_plan(browser string, display string, dbus_session_address string) extend.BrowserPlan {
	return extend.browser_plan(browser, [homebrew_docs_url], display, dbus_session_address)
}
