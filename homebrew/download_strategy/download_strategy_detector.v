module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/download_strategy_detector.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.detect(url, using = nil)` at line 10.
pub fn ruby_download_strategy_detector_l10_d1_self_detect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.detect', ...args)
}

// Ruby method `self.detect_from_url(url)` at line 24.
pub fn ruby_download_strategy_detector_l24_d2_self_detect_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.detect_from_url', ...args)
}

// Ruby method `self.detect_from_symbol(symbol)` at line 64.
pub fn ruby_download_strategy_detector_l64_d3_self_detect_from_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.detect_from_symbol', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper class for detecting a download strategy from a URL.
// 5: class DownloadStrategyDetector
// 6:   sig {
// 7:     params(url: String, using: T.nilable(T.any(Symbol, T::Class[AbstractDownloadStrategy])))
// 8:       .returns(T::Class[AbstractDownloadStrategy])
// 9:   }
// 10:   def self.detect(url, using = nil)
// 11:     if using.nil?
// 12:       detect_from_url(url)
// 13:     elsif using.is_a?(Class) && using < AbstractDownloadStrategy
// 14:       using
// 15:     elsif using.is_a?(Symbol)
// 16:       detect_from_symbol(using)
// 17:     else
// 18:       raise TypeError,
// 19:             "Unknown download strategy specification: #{using.inspect}"
// 20:     end
// 21:   end
// 22:
// 23:   sig { params(url: String).returns(T::Class[AbstractDownloadStrategy]) }
// 24:   def self.detect_from_url(url)
// 25:     case url
// 26:     when GitHubPackages::URL_REGEX
// 27:       CurlGitHubPackagesDownloadStrategy
// 28:     when %r{^https?://github\.com/[^/]+/[^/]+\.git$}
// 29:       GitHubGitDownloadStrategy
// 30:     when %r{^https?://.+\.git$},
// 31:          %r{^git://},
// 32:          %r{^https?://git\.sr\.ht/[^/]+/[^/]+$},
// 33:          %r{^https?://tangled\.sh/[^/]+/[^/]+$},
// 34:          %r{^ssh://git}
// 35:       GitDownloadStrategy
// 36:     when %r{^https?://www\.apache\.org/dyn/closer\.cgi},
// 37:          %r{^https?://www\.apache\.org/dyn/closer\.lua}
// 38:       CurlApacheMirrorDownloadStrategy
// 39:     when %r{^https?://files\.pythonhosted\.org/packages/}
// 40:       PyPIDownloadStrategy
// 41:     when %r{^https?://([A-Za-z0-9\-.]+\.)?googlecode\.com/svn},
// 42:          %r{^https?://svn\.},
// 43:          %r{^svn://},
// 44:          %r{^svn\+http://},
// 45:          %r{^http://svn\.apache\.org/repos/},
// 46:          %r{^https?://([A-Za-z0-9\-.]+\.)?sourceforge\.net/svnroot/}
// 47:       SubversionDownloadStrategy
// 48:     when %r{^cvs://}
// 49:       CVSDownloadStrategy
// 50:     when %r{^hg://},
// 51:          %r{^https?://([A-Za-z0-9\-.]+\.)?googlecode\.com/hg},
// 52:          %r{^https?://([A-Za-z0-9\-.]+\.)?sourceforge\.net/hgweb/}
// 53:       MercurialDownloadStrategy
// 54:     when %r{^bzr://}
// 55:       BazaarDownloadStrategy
// 56:     when %r{^fossil://}
// 57:       FossilDownloadStrategy
// 58:     else
// 59:       CurlDownloadStrategy
// 60:     end
// 61:   end
// 62:
// 63:   sig { params(symbol: Symbol).returns(T::Class[AbstractDownloadStrategy]) }
// 64:   def self.detect_from_symbol(symbol)
// 65:     case symbol
// 66:     when :hg                     then MercurialDownloadStrategy
// 67:     when :nounzip                then NoUnzipCurlDownloadStrategy
// 68:     when :git                    then GitDownloadStrategy
// 69:     when :bzr                    then BazaarDownloadStrategy
// 70:     when :svn                    then SubversionDownloadStrategy
// 71:     when :curl                   then CurlDownloadStrategy
// 72:     when :homebrew_curl          then HomebrewCurlDownloadStrategy
// 73:     when :cvs                    then CVSDownloadStrategy
// 74:     when :post                   then CurlPostDownloadStrategy
// 75:     when :fossil                 then FossilDownloadStrategy
// 76:     else
// 77:       raise TypeError, "Unknown download strategy #{symbol} was requested."
// 78:     end
// 79:   end
// 80: end
