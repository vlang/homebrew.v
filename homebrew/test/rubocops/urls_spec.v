module rubocops

import ruby
import homebrew.rubocops as urls_core

// Translated from Homebrew/brew `test/rubocops/urls_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct UrlsSpecCase {
	url     string
	message string
	tap     string
}

fn urls_spec_cases() []UrlsSpecCase {
	return [
		UrlsSpecCase{
			url: 'https://ftp.gnu.org/lightning/lightning-2.1.0.tar.gz'
			message: 'https://ftp.gnu.org/lightning/lightning-2.1.0.tar.gz should be: https://ftpmirror.gnu.org/gnu/lightning/lightning-2.1.0.tar.gz'
		},
		UrlsSpecCase{
			url: 'https://fossies.org/linux/privat/monit-5.23.0.tar.gz'
			message: 'Please don\'t use "fossies.org" in the `url` (using as a mirror is fine)'
		},
		UrlsSpecCase{
			url: 'http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz'
			message: 'Please use https:// for http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz'
		},
		UrlsSpecCase{
			url: 'https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2'
			message: 'https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2 should be: https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.0.tar.bz2'
		},
		UrlsSpecCase{
			url: 'http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz'
			message: 'http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz should be: https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz'
		},
		UrlsSpecCase{
			url: 'http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg'
			message: 'http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg should be: https://download.gnome.org/binaries/mac/banshee/banshee-2.macosx.intel.dmg'
		},
		UrlsSpecCase{
			url: 'git://anonscm.debian.org/users/foo/foostrap.git'
			message: 'git://anonscm.debian.org/users/foo/foostrap.git should be: https://anonscm.debian.org/git/users/foo/foostrap.git'
		},
		UrlsSpecCase{
			url: 'ftp://ftp.mirrorservice.org/foo-1.tar.gz'
			message: 'Please use https:// for ftp://ftp.mirrorservice.org/foo-1.tar.gz'
		},
		UrlsSpecCase{
			url: 'ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz'
			message: 'ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz should be: http://search.cpan.org/CPAN/foo-1.tar.gz'
		},
		UrlsSpecCase{
			url: 'http://sourceforge.net/projects/something/files/Something-1.2.3.dmg'
			message: 'Use "https://downloads.sourceforge.net" to get geolocation (`url` is http://sourceforge.net/projects/something/files/Something-1.2.3.dmg).'
		},
		UrlsSpecCase{
			url: 'https://downloads.sourceforge.net/project/foo/download'
			message: 'Don\'t use "/download" in SourceForge URLs (`url` is https://downloads.sourceforge.net/project/foo/download).'
		},
		UrlsSpecCase{
			url: 'https://sourceforge.net/project/foo'
			message: 'Use "https://downloads.sourceforge.net" to get geolocation (`url` is https://sourceforge.net/project/foo).'
		},
		UrlsSpecCase{
			url: 'http://prdownloads.sourceforge.net/foo/foo-1.tar.gz'
			message: 'Don\'t use "prdownloads" in SourceForge URLs (`url` is http://prdownloads.sourceforge.net/foo/foo-1.tar.gz).'
		},
		UrlsSpecCase{
			url: 'http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2'
			message: 'Don\'t use specific "dl" mirrors in SourceForge URLs (`url` is http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2).'
		},
		UrlsSpecCase{
			url: 'http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip'
			message: 'Please use https:// for http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip'
		},
		UrlsSpecCase{
			url: 'http://http.debian.net/debian/dists/foo/'
			message: 'Please use a secure mirror for Debian URLs.\nWe recommend:\n  https://deb.debian.org/debian/dists/foo/\n'
		},
		UrlsSpecCase{
			url: 'https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz'
			message: 'Please use https://deb.debian.org/debian/ for https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz'
		},
		UrlsSpecCase{
			url: 'https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz'
			message: 'Please use https://deb.debian.org/debian/ for https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz'
		},
		UrlsSpecCase{
			url: 'https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz'
			message: 'Please use https://deb.debian.org/debian/ for https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz'
		},
		UrlsSpecCase{
			url: 'https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz'
			message: 'Please use https://deb.debian.org/debian/ for https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz'
		},
		UrlsSpecCase{
			url: 'http://foo.googlecode.com/files/foo-1.0.zip'
			message: 'Please use https:// for http://foo.googlecode.com/files/foo-1.0.zip'
		},
		UrlsSpecCase{
			url: 'git://github.com/foo.git'
			message: 'Please use https:// for git://github.com/foo.git'
		},
		UrlsSpecCase{
			url: 'git://gitorious.org/foo/foo5'
			message: 'Please use https:// for git://gitorious.org/foo/foo5'
		},
		UrlsSpecCase{
			url: 'http://github.com/foo/foo5.git'
			message: 'Please use https:// for http://github.com/foo/foo5.git'
		},
		UrlsSpecCase{
			url: 'https://github.com/foo/foobar/archive/main.zip'
			message: 'Use versioned rather than branch tarballs for stable checksums.'
		},
		UrlsSpecCase{
			url: 'https://github.com/foo/bar/tarball/v1.2.3'
			message: 'Use /archive/ URLs for GitHub tarballs (`url` is https://github.com/foo/bar/tarball/v1.2.3).'
		},
		UrlsSpecCase{
			url: 'https://codeload.github.com/foo/bar/tar.gz/v0.1.1'
			message: 'Use GitHub archive URLs:\n  https://github.com/foo/bar/archive/v0.1.1.tar.gz\nRather than codeload:\n  https://codeload.github.com/foo/bar/tar.gz/v0.1.1\n'
		},
		UrlsSpecCase{
			url: 'https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar'
			message: 'https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar should be: https://search.maven.org/remotecontent?filepath=com/bar/foo/1.1/foo-1.1.jar'
		},
		UrlsSpecCase{
			url: 'https://brew.sh/example-darwin.x86_64.tar.gz'
			message: 'https://brew.sh/example-darwin.x86_64.tar.gz looks like a binary package, not a source archive; homebrew/core is source-only.'
			tap: 'homebrew-core'
		},
		UrlsSpecCase{
			url: 'https://brew.sh/example-darwin.amd64.tar.gz'
			message: 'https://brew.sh/example-darwin.amd64.tar.gz looks like a binary package, not a source archive; homebrew/core is source-only.'
			tap: 'homebrew-core'
		},
		UrlsSpecCase{
			url: 'https://github.com/foo/bar/archive/refs/tags/darwin.tar.gz'
			message: 'https://github.com/foo/bar/archive/refs/tags/darwin.tar.gz looks like a binary package, not a source archive; homebrew/core is source-only.'
			tap: 'homebrew-core'
		},
		UrlsSpecCase{
			url: 'cvs://brew.sh/foo/bar'
			message: 'Use of the "cvs://" scheme is deprecated, pass `using: :cvs` instead'
		},
		UrlsSpecCase{
			url: 'bzr://brew.sh/foo/bar'
			message: 'Use of the "bzr://" scheme is deprecated, pass `using: :bzr` instead'
		},
		UrlsSpecCase{
			url: 'hg://brew.sh/foo/bar'
			message: 'Use of the "hg://" scheme is deprecated, pass `using: :hg` instead'
		},
		UrlsSpecCase{
			url: 'fossil://brew.sh/foo/bar'
			message: 'Use of the "fossil://" scheme is deprecated, pass `using: :fossil` instead'
		},
		UrlsSpecCase{
			url: 'svn+http://brew.sh/foo/bar'
			message: 'Use of the "svn+http://" scheme is deprecated, pass `using: :svn` instead'
		},
		UrlsSpecCase{
			url: 'https://🫠.sh/foo/bar'
			message: 'Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of https://🫠.sh/foo/bar.'
		},
		UrlsSpecCase{
			url: 'https://ßreｗ.sh/foo/bar'
			message: 'Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of https://ßreｗ.sh/foo/bar.'
		},
	]
}

fn urls_spec_source(url string) string {
	return 'class Foo < Formula\n  desc "foo"\n  url "${url}"\nend'
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_urls_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::Urls', 'FormulaAudit/Urls')
}

// Ruby let `let(:offense_list) do` at line 9.
pub fn ruby_urls_spec_l9_d2_offense_list(args ...ruby.Value) ruby.Value {
	return ruby.array_value(urls_spec_cases().map(ruby.structured_value('Hash', it.url, {
		'url':         it.url
		'msg':         it.message
		'col':         '2'
		'formula_tap': it.tap
	})))
}

// Ruby it `it "reports all offenses in `offense_list`" do` at line 200.
pub fn ruby_urls_spec_l200_d3_reports(args ...ruby.Value) ruby.Value {
	for item in urls_spec_cases() {
		analysis := urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{
			source: urls_spec_source(item.url)
			formula_tap: item.tap
			formula_name: 'foo'
		})
		if !analysis.offenses.any(it.message == item.message) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "reports an offense for GitHub repositories with git:// prefix" do` at line 228.
pub fn ruby_urls_spec_l228_d4_reports(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  desc "foo"\n  url "https://foo.com"\n\n  stable do\n    url "git://github.com/foo.git",\n        :tag => "v1.0.1",\n        :revision => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"\n    version "1.0.1"\n  end\nend'
	offenses := urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{ source: source }).offenses
	return ruby.bool_value(offenses.len == 1 && offenses[0].message == 'Please use https:// for git://github.com/foo.git')
}

// Ruby it `it "reports an offense if `url` is the same as `mirror`" do` at line 245.
pub fn ruby_urls_spec_l245_d5_reports(args ...ruby.Value) ruby.Value {
	url := 'https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz'
	source := 'class Foo < Formula\n  desc "foo"\n  url "${url}"\n  mirror "${url}"\nend'
	offenses := urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{ source: source }).offenses
	return ruby.bool_value(offenses.len == 1 && offenses[0].kind == 'duplicate_mirror' && offenses[0].message == 'URL should not be duplicated as a mirror: ${url}')
}

// Ruby it `it "does not report offenses that are skipped for `livecheck` block URLs" do` at line 256.
pub fn ruby_urls_spec_l256_d6_does(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  desc "foo"\n  url "https://brew.sh/test-0.0.1.tgz"\n  livecheck do\n    url "https://sourceforge.net/projects/homebrew/rss?path=/brew"\n  end\n  resource "foo" do\n    url "https://brew.sh/foo-1.0.tar.gz"\n    livecheck do\n      url "https://sourceforge.net/projects/homebrew/rss?path=/resource"\n    end\n  end\n  resource "livecheck-url-symbol" do\n    url "https://brew.sh/livecheck-url-no-argument-1.0.tar.gz"\n    livecheck do\n      url :url\n    end\n  end\n  resource "livecheck-no-url" do\n    url "https://brew.sh/livecheck-no-url-1.0.tar.gz"\n    livecheck do\n      skip "No version information available"\n    end\n  end\n  resource "livecheck-url-no-arg" do\n    url "https://brew.sh/livecheck-url-no-arg-1.0.tar.gz"\n    livecheck do\n      url\n    end\n  end\nend'
	return ruby.bool_value(urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{
		source: source
	}).offenses.len == 0)
}

// Ruby it `it "does not report an offense based on the username or repo name of a GitHub URL" do` at line 312.
pub fn ruby_urls_spec_l312_d7_does(args ...ruby.Value) ruby.Value {
	source := urls_spec_source('https://github.com/scriptingosx/cool-darwin-app/archive/refs/tags/v0.1.1.tar.gz')
	return ruby.bool_value(urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{
		source: source
		formula_tap: 'homebrew-core'
		formula_name: 'foo'
	}).offenses.len == 0)
}

// Ruby let `let(:expected_url) { "https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.6.tar.bz2" }` at line 325.
pub fn ruby_urls_spec_l325_d8_expected_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.6.tar.bz2')
}

// Ruby it `it "registers an offense and corrects" do` at line 328.
pub fn ruby_urls_spec_l328_d9_registers(args ...ruby.Value) ruby.Value {
	expected := ruby_urls_spec_l325_d8_expected_url().as_string()
	mut urls := [
		'https://dist.apache.org/repos/dist/release/apr/apr-1.7.6.tar.bz2',
		'https://dlcdn.apache.org/apr/apr-1.7.6.tar.bz2',
		'https://downloads.apache.org/apr/apr-1.7.6.tar.bz2',
		'https://www.apache.org/dyn/closer.cgi?path=/apr/apr-1.7.6.tar.bz2',
		'https://www.apache.org/dyn/mirrors.cgi?path=apr/apr-1.7.6.tar.bz2',
		'https://www.apache.org/dyn/mirrors.cgi?filename=/apr/apr-1.7.6.tar.bz2',
		'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=apr/apr-1.7.6.tar.bz2',
	]
	if args.len > 0 {
		urls = [args[0].as_string()]
	}
	for url in urls {
		source := urls_spec_source(url)
		analysis := urls_core.audit_formula_urls(urls_core.FormulaUrlsContext{ source: source })
		if analysis.offenses.len != 1 {
			return ruby.bool_value(false)
		}
		if analysis.offenses[0].message != '${url} should be: ${expected}' || analysis.corrected != urls_spec_source(expected) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/urls"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Urls do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   let(:offense_list) do
// 10:     [{
// 11:       "url" => "https://ftp.gnu.org/lightning/lightning-2.1.0.tar.gz",
// 12:       "msg" => "https://ftp.gnu.org/lightning/lightning-2.1.0.tar.gz should be: " \
// 13:                "https://ftpmirror.gnu.org/gnu/lightning/lightning-2.1.0.tar.gz",
// 14:       "col" => 2,
// 15:     }, {
// 16:       "url" => "https://fossies.org/linux/privat/monit-5.23.0.tar.gz",
// 17:       "msg" => "Please don't use \"fossies.org\" in the `url` (using as a mirror is fine)",
// 18:       "col" => 2,
// 19:     }, {
// 20:       "url" => "http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz",
// 21:       "msg" => "Please use https:// for http://tools.ietf.org/tools/rfcmarkup/rfcmarkup-1.119.tgz",
// 22:       "col" => 2,
// 23:     }, {
// 24:       "url" => "https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2",
// 25:       "msg" => "https://apache.org/dyn/closer.cgi?path=/apr/apr-1.7.0.tar.bz2 should be: " \
// 26:                "https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.0.tar.bz2",
// 27:       "col" => 2,
// 28:     }, {
// 29:       "url" => "http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz",
// 30:       "msg" => "http://search.mcpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz should be: " \
// 31:                "https://cpan.metacpan.org/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz",
// 32:       "col" => 2,
// 33:     }, {
// 34:       "url" => "http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg",
// 35:       "msg" => "http://ftp.gnome.org/pub/GNOME/binaries/mac/banshee/banshee-2.macosx.intel.dmg should be: " \
// 36:                "https://download.gnome.org/binaries/mac/banshee/banshee-2.macosx.intel.dmg",
// 37:       "col" => 2,
// 38:     }, {
// 39:       "url" => "git://anonscm.debian.org/users/foo/foostrap.git",
// 40:       "msg" => "git://anonscm.debian.org/users/foo/foostrap.git should be: " \
// 41:                "https://anonscm.debian.org/git/users/foo/foostrap.git",
// 42:       "col" => 2,
// 43:     }, {
// 44:       "url" => "ftp://ftp.mirrorservice.org/foo-1.tar.gz",
// 45:       "msg" => "Please use https:// for ftp://ftp.mirrorservice.org/foo-1.tar.gz",
// 46:       "col" => 2,
// 47:     }, {
// 48:       "url" => "ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz",
// 49:       "msg" => "ftp://ftp.cpan.org/pub/CPAN/foo-1.tar.gz should be: http://search.cpan.org/CPAN/foo-1.tar.gz",
// 50:       "col" => 2,
// 51:     }, {
// 52:       "url" => "http://sourceforge.net/projects/something/files/Something-1.2.3.dmg",
// 53:       "msg" => "Use \"https://downloads.sourceforge.net\" to get geolocation (`url` is " \
// 54:                "http://sourceforge.net/projects/something/files/Something-1.2.3.dmg).",
// 55:       "col" => 2,
// 56:     }, {
// 57:       "url" => "https://downloads.sourceforge.net/project/foo/download",
// 58:       "msg" => "Don't use \"/download\" in SourceForge URLs (`url` is " \
// 59:                "https://downloads.sourceforge.net/project/foo/download).",
// 60:       "col" => 2,
// 61:     }, {
// 62:       "url" => "https://sourceforge.net/project/foo",
// 63:       "msg" => "Use \"https://downloads.sourceforge.net\" to get geolocation (`url` is " \
// 64:                "https://sourceforge.net/project/foo).",
// 65:       "col" => 2,
// 66:     }, {
// 67:       "url" => "http://prdownloads.sourceforge.net/foo/foo-1.tar.gz",
// 68:       "msg" => "Don't use \"prdownloads\" in SourceForge URLs (`url` is " \
// 69:                "http://prdownloads.sourceforge.net/foo/foo-1.tar.gz).",
// 70:       "col" => 2,
// 71:     }, {
// 72:       "url" => "http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2",
// 73:       "msg" => "Don't use specific \"dl\" mirrors in SourceForge URLs (`url` is " \
// 74:                "http://foo.dl.sourceforge.net/sourceforge/foozip/foozip_1.0.tar.bz2).",
// 75:       "col" => 2,
// 76:     }, {
// 77:       "url" => "http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip",
// 78:       "msg" => "Please use https:// for http://downloads.sourceforge.net/project/foo/foo/2/foo-2.zip",
// 79:       "col" => 2,
// 80:     }, {
// 81:       "url" => "http://http.debian.net/debian/dists/foo/",
// 82:       "msg" => <<~EOS,
// 83:         Please use a secure mirror for Debian URLs.
// 84:         We recommend:
// 85:           https://deb.debian.org/debian/dists/foo/
// 86:       EOS
// 87:       "col" => 2,
// 88:     }, {
// 89:       "url" => "https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz",
// 90:       "msg" => "Please use " \
// 91:                "https://deb.debian.org/debian/ for " \
// 92:                "https://mirrors.kernel.org/debian/pool/main/n/nc6/foo.tar.gz",
// 93:       "col" => 2,
// 94:     }, {
// 95:       "url" => "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz",
// 96:       "msg" => "Please use " \
// 97:                "https://deb.debian.org/debian/ for " \
// 98:                "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mkcue/foo.tar.gz",
// 99:       "col" => 2,
// 100:     }, {
// 101:       "url" => "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
// 102:       "msg" => "Please use " \
// 103:                "https://deb.debian.org/debian/ for " \
// 104:                "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
// 105:       "col" => 2,
// 106:     }, {
// 107:       "url" => "https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
// 108:       "msg" => "Please use " \
// 109:                "https://deb.debian.org/debian/ for " \
// 110:                "https://www.mirrorservice.org/sites/ftp.debian.org/debian/pool/main/n/netris/foo.tar.gz",
// 111:       "col" => 2,
// 112:     }, {
// 113:       "url" => "http://foo.googlecode.com/files/foo-1.0.zip",
// 114:       "msg" => "Please use https:// for http://foo.googlecode.com/files/foo-1.0.zip",
// 115:       "col" => 2,
// 116:     }, {
// 117:       "url" => "git://github.com/foo.git",
// 118:       "msg" => "Please use https:// for git://github.com/foo.git",
// 119:       "col" => 2,
// 120:     }, {
// 121:       "url" => "git://gitorious.org/foo/foo5",
// 122:       "msg" => "Please use https:// for git://gitorious.org/foo/foo5",
// 123:       "col" => 2,
// 124:     }, {
// 125:       "url" => "http://github.com/foo/foo5.git",
// 126:       "msg" => "Please use https:// for http://github.com/foo/foo5.git",
// 127:       "col" => 2,
// 128:     }, {
// 129:       "url" => "https://github.com/foo/foobar/archive/main.zip",
// 130:       "msg" => "Use versioned rather than branch tarballs for stable checksums.",
// 131:       "col" => 2,
// 132:     }, {
// 133:       "url" => "https://github.com/foo/bar/tarball/v1.2.3",
// 134:       "msg" => "Use /archive/ URLs for GitHub tarballs (`url` is https://github.com/foo/bar/tarball/v1.2.3).",
// 135:       "col" => 2,
// 136:     }, {
// 137:       "url" => "https://codeload.github.com/foo/bar/tar.gz/v0.1.1",
// 138:       "msg" => <<~EOS,
// 139:         Use GitHub archive URLs:
// 140:           https://github.com/foo/bar/archive/v0.1.1.tar.gz
// 141:         Rather than codeload:
// 142:           https://codeload.github.com/foo/bar/tar.gz/v0.1.1
// 143:       EOS
// 144:       "col" => 2,
// 145:     }, {
// 146:       "url" => "https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar",
// 147:       "msg" => "https://central.maven.org/maven2/com/bar/foo/1.1/foo-1.1.jar should be: " \
// 148:                "https://search.maven.org/remotecontent?filepath=com/bar/foo/1.1/foo-1.1.jar",
// 149:       "col" => 2,
// 150:     }, {
// 151:       "url"         => "https://brew.sh/example-darwin.x86_64.tar.gz",
// 152:       "msg"         => "https://brew.sh/example-darwin.x86_64.tar.gz looks like a binary package, " \
// 153:                        "not a source archive; homebrew/core is source-only.",
// 154:       "col"         => 2,
// 155:       "formula_tap" => "homebrew-core",
// 156:     }, {
// 157:       "url"         => "https://brew.sh/example-darwin.amd64.tar.gz",
// 158:       "msg"         => "https://brew.sh/example-darwin.amd64.tar.gz looks like a binary package, " \
// 159:                        "not a source archive; homebrew/core is source-only.",
// 160:       "col"         => 2,
// 161:       "formula_tap" => "homebrew-core",
// 162:     }, {
// 163:       "url"         => "https://github.com/foo/bar/archive/refs/tags/darwin.tar.gz",
// 164:       "msg"         => "https://github.com/foo/bar/archive/refs/tags/darwin.tar.gz looks like a binary package, " \
// 165:                        "not a source archive; homebrew/core is source-only.",
// 166:       "col"         => 2,
// 167:       "formula_tap" => "homebrew-core",
// 168:     }, {
// 169:       "url" => "cvs://brew.sh/foo/bar",
// 170:       "msg" => "Use of the \"cvs://\" scheme is deprecated, pass `using: :cvs` instead",
// 171:       "col" => 2,
// 172:     }, {
// 173:       "url" => "bzr://brew.sh/foo/bar",
// 174:       "msg" => "Use of the \"bzr://\" scheme is deprecated, pass `using: :bzr` instead",
// 175:       "col" => 2,
// 176:     }, {
// 177:       "url" => "hg://brew.sh/foo/bar",
// 178:       "msg" => "Use of the \"hg://\" scheme is deprecated, pass `using: :hg` instead",
// 179:       "col" => 2,
// 180:     }, {
// 181:       "url" => "fossil://brew.sh/foo/bar",
// 182:       "msg" => "Use of the \"fossil://\" scheme is deprecated, pass `using: :fossil` instead",
// 183:       "col" => 2,
// 184:     }, {
// 185:       "url" => "svn+http://brew.sh/foo/bar",
// 186:       "msg" => "Use of the \"svn+http://\" scheme is deprecated, pass `using: :svn` instead",
// 187:       "col" => 2,
// 188:     }, {
// 189:       "url" => "https://🫠.sh/foo/bar",
// 190:       "msg" => "Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of https://🫠.sh/foo/bar.",
// 191:       "col" => 2,
// 192:     }, {
// 193:       "url" => "https://ßreｗ.sh/foo/bar",
// 194:       "msg" => "Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of https://ßreｗ.sh/foo/bar.",
// 195:       "col" => 2,
// 196:     }]
// 197:   end
// 198:
// 199:   context "when auditing URLs" do
// 200:     it "reports all offenses in `offense_list`" do
// 201:       offense_list.each do |offense_info|
// 202:         allow_any_instance_of(RuboCop::Cop::FormulaCop).to receive(:formula_tap)
// 203:                                                        .and_return(offense_info["formula_tap"])
// 204:         source = <<~RUBY
// 205:           class Foo < Formula
// 206:             desc "foo"
// 207:             url "#{offense_info["url"]}"
// 208:           end
// 209:         RUBY
// 210:         expected_offenses = [{ message:  "FormulaAudit/Urls: #{offense_info["msg"]}",
// 211:                                severity: :convention,
// 212:                                line:     3,
// 213:                                column:   offense_info["col"],
// 214:                                source: }]
// 215:
// 216:         offenses = inspect_source(source)
// 217:
// 218:         expected_offenses.zip(offenses.reverse).each do |expected, actual|
// 219:           expect(actual).not_to be_nil
// 220:           expect(actual.message).to eq(expected[:message])
// 221:           expect(actual.severity).to eq(expected[:severity])
// 222:           expect(actual.line).to eq(expected[:line])
// 223:           expect(actual.column).to eq(expected[:column])
// 224:         end
// 225:       end
// 226:     end
// 227:
// 228:     it "reports an offense for GitHub repositories with git:// prefix" do
// 229:       expect_offense(<<~RUBY)
// 230:         class Foo < Formula
// 231:           desc "foo"
// 232:           url "https://foo.com"
// 233:
// 234:           stable do
// 235:             url "git://github.com/foo.git",
// 236:             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Urls: Please use https:// for git://github.com/foo.git
// 237:                 :tag => "v1.0.1",
// 238:                 :revision => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 239:             version "1.0.1"
// 240:           end
// 241:         end
// 242:       RUBY
// 243:     end
// 244:
// 245:     it "reports an offense if `url` is the same as `mirror`" do
// 246:       expect_offense(<<~RUBY)
// 247:         class Foo < Formula
// 248:           desc "foo"
// 249:           url "https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz"
// 250:           mirror "https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz"
// 251:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Urls: URL should not be duplicated as a mirror: https://ftpmirror.fnu.org/foo/foo-1.0.tar.gz
// 252:         end
// 253:       RUBY
// 254:     end
// 255:
// 256:     it "does not report offenses that are skipped for `livecheck` block URLs" do
// 257:       source = <<~RUBY
// 258:         class Foo < Formula
// 259:           desc "foo"
// 260:           url "https://brew.sh/test-0.0.1.tgz"
// 261:
// 262:           # This URL will trigger the 'Use "https://downloads.sourceforge.net"
// 263:           # to get geolocation' cop unless it's skipped for the `livecheck`
// 264:           # block URL.
// 265:           livecheck do
// 266:             url "https://sourceforge.net/projects/homebrew/rss?path=/brew"
// 267:           end
// 268:
// 269:           resource "foo" do
// 270:             url "https://brew.sh/foo-1.0.tar.gz"
// 271:
// 272:             # This URL will trigger the 'Use "https://downloads.sourceforge.net"
// 273:             # to get geolocation' cop unless it's skipped for all `livecheck`
// 274:             # block URLs (not just the main `livecheck` block).
// 275:             livecheck do
// 276:               url "https://sourceforge.net/projects/homebrew/rss?path=/resource"
// 277:             end
// 278:           end
// 279:
// 280:           resource "livecheck-url-symbol" do
// 281:             url "https://brew.sh/livecheck-url-no-argument-1.0.tar.gz"
// 282:
// 283:             # URL symbols shouldn't be checked..
// 284:             livecheck do
// 285:               url :url
// 286:             end
// 287:           end
// 288:
// 289:           resource "livecheck-no-url" do
// 290:             url "https://brew.sh/livecheck-no-url-1.0.tar.gz"
// 291:
// 292:             # No URL is present when `skip` is used.
// 293:             livecheck do
// 294:               skip "No version information available"
// 295:             end
// 296:           end
// 297:
// 298:           resource "livecheck-url-no-arg" do
// 299:             url "https://brew.sh/livecheck-url-no-arg-1.0.tar.gz"
// 300:
// 301:             # This shouldn't ever happen but this is simply to exercise a guard.
// 302:             livecheck do
// 303:               url
// 304:             end
// 305:           end
// 306:         end
// 307:       RUBY
// 308:
// 309:       expect(inspect_source(source)).to eq([])
// 310:     end
// 311:
// 312:     it "does not report an offense based on the username or repo name of a GitHub URL" do
// 313:       source = <<~RUBY
// 314:         class Foo < Formula
// 315:           desc "foo"
// 316:           url "https://github.com/scriptingosx/cool-darwin-app/archive/refs/tags/v0.1.1.tar.gz"
// 317:         end
// 318:       RUBY
// 319:
// 320:       expect(inspect_source(source)).to eq([])
// 321:     end
// 322:   end
// 323:
// 324:   context "when auditing Apache URLs" do
// 325:     let(:expected_url) { "https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.6.tar.bz2" }
// 326:
// 327:     shared_examples "offense" do |url|
// 328:       it "registers an offense and corrects" do
// 329:         message = "FormulaAudit/Urls: #{url} should be: #{expected_url}"
// 330:
// 331:         expect_offense(<<~RUBY, url:, message:)
// 332:           class Foo < Formula
// 333:             desc "foo"
// 334:             url "#{url}"
// 335:             ^^^^^#{"^" * url.size}^ #{message}
// 336:           end
// 337:         RUBY
// 338:
// 339:         expect_correction(<<~RUBY)
// 340:           class Foo < Formula
// 341:             desc "foo"
// 342:             url "#{expected_url}"
// 343:           end
// 344:         RUBY
// 345:       end
// 346:     end
// 347:
// 348:     it_behaves_like "offense", "https://dist.apache.org/repos/dist/release/apr/apr-1.7.6.tar.bz2"
// 349:     it_behaves_like "offense", "https://dlcdn.apache.org/apr/apr-1.7.6.tar.bz2"
// 350:     it_behaves_like "offense", "https://downloads.apache.org/apr/apr-1.7.6.tar.bz2"
// 351:     it_behaves_like "offense", "https://www.apache.org/dyn/closer.cgi?path=/apr/apr-1.7.6.tar.bz2"
// 352:     it_behaves_like "offense", "https://www.apache.org/dyn/mirrors.cgi?path=apr/apr-1.7.6.tar.bz2"
// 353:     it_behaves_like "offense", "https://www.apache.org/dyn/mirrors.cgi?filename=/apr/apr-1.7.6.tar.bz2"
// 354:     it_behaves_like "offense",
// 355:                     "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=apr/apr-1.7.6.tar.bz2"
// 356:   end
// 357: end
