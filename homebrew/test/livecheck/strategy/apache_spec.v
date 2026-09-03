module strategy

import brew_runtime
import homebrew.livecheck
import homebrew.livecheck.strategy as apache_core
import homebrew.utils

// Translated from Homebrew/brew `test/livecheck/strategy/apache_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ApacheSpecContent {
pub:
	directories string
	files       string
}

pub struct ApacheSpecMatches {
pub:
	directories []string
	files       []string
}

pub struct ApacheSpecMatchData {
pub:
	cached_dirs         apache_core.PageMatchData
	cached_files        apache_core.PageMatchData
	cached_dirs_default apache_core.PageMatchData
}

fn apache_spec_scan_block(page string,
	provided ?apache_core.PageMatchRegex) !livecheck.StrategyBlockValue {
	match_regex := provided or { return livecheck.StrategyBlockValue{ kind: .nil_value } }
	versions := apache_core.page_match_scan(page, match_regex)!
	return livecheck.StrategyBlockValue{
		kind: .array
		values: versions.map(livecheck.StrategyBlockItem{
			kind: .string_value
			value: it
		})
	}
}

fn apache_spec_unused_fetcher(_ livecheck.StrategyCurlRequest) !utils.CurlCommandResult {
	return error('cached Apache content unexpectedly fetched')
}

fn apache_spec_regex_equal(left ?apache_core.PageMatchRegex,
	right ?apache_core.PageMatchRegex) bool {
	if left_value := left {
		right_value := right or { return false }
		return left_value == right_value
	}
	if _ := right {
		return false
	}
	return true
}

fn apache_spec_match_data_equal(left apache_core.PageMatchData,
	right apache_core.PageMatchData) bool {
	return left.matches == right.matches && apache_spec_regex_equal(left.regex, right.regex) && left.url == right.url && left.cached == right.cached && left.has_cached == right.has_cached && left.content == right.content && left.has_content == right.has_content && left.final_url == right.final_url && left.has_final_url == right.has_final_url && left.messages == right.messages && left.has_messages == right.has_messages
}

// Ruby subject `subject(:apache) { described_class }` at line 7.
pub fn ruby_apache_spec_l7_d1_apache() brew_runtime.Value {
	return brew_runtime.object_value('Class', 'Homebrew::Livecheck::Strategy::Apache')
}

// Ruby let `let(:apache_urls) do` at line 9.
pub fn ruby_apache_spec_l9_d2_apache_urls() map[string]string {
	return {
		'version_dir':                    'https://www.apache.org/dyn/closer.lua?path=abc/1.2.3/def-1.2.3.tar.gz'
		'version_dir_root':               'https://www.apache.org/dyn/closer.lua?path=/abc/1.2.3/def-1.2.3.tar.gz'
		'name_and_version_dir':           'https://www.apache.org/dyn/closer.lua?path=abc/def-1.2.3/ghi-1.2.3.tar.gz'
		'name_dir_bin':                   'https://www.apache.org/dyn/closer.lua?path=abc/def/ghi-1.2.3-bin.tar.gz'
		'name_dir_bin_no_suffix':         'https://www.apache.org/dyn/closer.lua?path=abc/def/ghi-1.2.3'
		'archive_version_dir':            'https://archive.apache.org/dist/abc/1.2.3/def-1.2.3.tar.gz'
		'archive_name_and_version_dir':   'https://archive.apache.org/dist/abc/def-1.2.3/ghi-1.2.3.tar.gz'
		'archive_name_dir_bin':           'https://archive.apache.org/dist/abc/def/ghi-1.2.3-bin.tar.gz'
		'dlcdn_version_dir':              'https://dlcdn.apache.org/abc/1.2.3/def-1.2.3.tar.gz'
		'dlcdn_name_and_version_dir':     'https://dlcdn.apache.org/abc/def-1.2.3/ghi-1.2.3.tar.gz'
		'dlcdn_name_dir_bin':             'https://dlcdn.apache.org/abc/def/ghi-1.2.3-bin.tar.gz'
		'downloads_version_dir':          'https://downloads.apache.org/abc/1.2.3/def-1.2.3.tar.gz'
		'downloads_name_and_version_dir': 'https://downloads.apache.org/abc/def-1.2.3/ghi-1.2.3.tar.gz'
		'downloads_name_dir_bin':         'https://downloads.apache.org/abc/def/ghi-1.2.3-bin.tar.gz'
		'mirrors_version_dir':            'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/1.2.3/def-1.2.3.tar.gz'
		'mirrors_version_dir_root':       'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=/abc/1.2.3/def-1.2.3.tar.gz'
		'mirrors_name_and_version_dir':   'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/def-1.2.3/ghi-1.2.3.tar.gz'
		'mirrors_name_dir_bin':           'https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/def/ghi-1.2.3-bin.tar.gz'
	}
}

// Ruby let `let(:non_apache_url) { "https://brew.sh/test" }` at line 31.
pub fn ruby_apache_spec_l31_d3_non_apache_url() string {
	return 'https://brew.sh/test'
}

// Ruby let `let(:generated) do` at line 32.
pub fn ruby_apache_spec_l32_d4_generated() map[string]apache_core.ApacheInputValues {
	version_dir := apache_core.ApacheInputValues{
		present: true
		url: 'https://archive.apache.org/dist/abc/'
		regex: apache_core.PageMatchRegex{
			pattern: 'href=["\']?v?(\\d+(?:\\.\\d+)+)/'
			case_insensitive: true
		}
	}
	name_and_version_dir := apache_core.ApacheInputValues{
		present: true
		url: 'https://archive.apache.org/dist/abc/'
		regex: apache_core.PageMatchRegex{
			pattern: 'href=["\']?def-v?(\\d+(?:\\.\\d+)+)/'
			case_insensitive: true
		}
	}
	name_dir_bin := apache_core.ApacheInputValues{
		present: true
		url: 'https://archive.apache.org/dist/abc/def/'
		regex: apache_core.PageMatchRegex{
			pattern: 'href=["\']?ghi-v?(\\d+(?:\\.\\d+)+)-bin\\.t'
			case_insensitive: true
		}
	}
	name_dir_bin_no_suffix := apache_core.ApacheInputValues{
		present: true
		url: 'https://archive.apache.org/dist/abc/def/'
		regex: apache_core.PageMatchRegex{
			pattern: 'href=["\']?ghi-v?(\\d+(?:\\.\\d+)+)'
			case_insensitive: true
		}
	}
	return {
		'version_dir':                    version_dir
		'version_dir_root':               version_dir
		'name_and_version_dir':           name_and_version_dir
		'name_dir_bin':                   name_dir_bin
		'name_dir_bin_no_suffix':         name_dir_bin_no_suffix
		'archive_version_dir':            version_dir
		'archive_name_and_version_dir':   name_and_version_dir
		'archive_name_dir_bin':           name_dir_bin
		'dlcdn_version_dir':              version_dir
		'dlcdn_name_and_version_dir':     name_and_version_dir
		'dlcdn_name_dir_bin':             name_dir_bin
		'downloads_version_dir':          version_dir
		'downloads_name_and_version_dir': name_and_version_dir
		'downloads_name_dir_bin':         name_dir_bin
		'mirrors_version_dir':            version_dir
		'mirrors_version_dir_root':       version_dir
		'mirrors_name_and_version_dir':   name_and_version_dir
		'mirrors_name_dir_bin':           name_dir_bin
	}
}

// Ruby let `let(:content) do` at line 68.
pub fn ruby_apache_spec_l68_d5_content() ApacheSpecContent {
	start_html := [
		'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">',
		'<html>',
		'<head>',
		'  <title>Index of /dist/abc</title>',
		'</head>',
		'<body>',
		'  <h1>Index of /dist/abc</h1>',
		'  <pre>',
		'    <img src="/icons/blank.gif" alt="Icon ">',
		'    <a href="?C=N;O=D">Name</a>',
		'    <a href="?C=M;O=A">Last modified</a>',
		'    <a href="?C=S;O=A">Size</a>',
		'    <a href="?C=D;O=A">Description</a>',
		'    <hr>',
		'    <img src="/icons/back.gif" alt="[PARENTDIR]">',
		'    <a href="/dist/">Parent Directory</a>',
		'                                                       -',
	].join('\n') + '\n'
	end_html := [
		'    <hr>',
		'  </pre>',
		'</body>',
		'</html>',
	].join('\n') + '\n'
	directories := [
		'<img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.0/">1.2.0/</a>                  2022-01-20 01:20    -',
		'<img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.1/">1.2.1/</a>                  2022-01-21 01:21    -',
		'<img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.2/">1.2.2/</a>                  2022-01-22 01:22    -',
		'<img src="/icons/folder.gif" alt="[DIR]"> <a href="abc-other/">abc-other/</a>         2022-01-02 01:02    -',
		'<img src="/icons/folder.gif" alt="[DIR]"> <a href="abc-something/">abc-something/</a> 2022-01-03 01:03    -',
	].join('\n') + '\n'
	files := [
		'<img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.3-bin.tar.gz">ghi-1.2.3-bin.tar.gz</a>        2022-01-23 01:23   45M',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-bin.tar.gz.asc">ghi-1.2.3-bin.tar.gz.asc</a>    2022-01-23 01:23  456',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-bin.tar.gz.sha512">ghi-1.2.3-bin.tar.gz.sha512</a> 2022-01-23 01:23  123',
		'<img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.3-src.tar.gz">ghi-1.2.3-src.tar.gz</a>        2022-01-23 01:23  4.5M',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-src.tar.gz.asc">ghi-1.2.3-src.tar.gz.asc</a>    2022-01-23 01:23  456',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-src.tar.gz.sha512">ghi-1.2.3-src.tar.gz.sha512</a> 2022-01-23 01:23  123',
		'<img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.4-bin.tar.gz">ghi-1.2.4-bin.tar.gz</a>        2022-01-24 01:24   56M',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-bin.tar.gz.asc">ghi-1.2.4-bin.tar.gz.asc</a>    2022-01-24 01:24  567',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-bin.tar.gz.sha512">ghi-1.2.4-bin.tar.gz.sha512</a> 2022-01-24 01:24  124',
		'<img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.4-src.tar.gz">ghi-1.2.4-src.tar.gz</a>        2022-01-24 01:24  5.6M',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-src.tar.gz.asc">ghi-1.2.4-src.tar.gz.asc</a>    2022-01-24 01:24  567',
		'<img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-src.tar.gz.sha512">ghi-1.2.4-src.tar.gz.sha512</a> 2022-01-24 01:24  124',
	].join('\n') + '\n'
	return ApacheSpecContent{
		directories: start_html + directories + end_html
		files: start_html + files + end_html
	}
}

// Ruby let `let(:matches) do` at line 124.
pub fn ruby_apache_spec_l124_d6_matches() ApacheSpecMatches {
	return ApacheSpecMatches{
		directories: ['1.2.0', '1.2.1', '1.2.2']
		files: ['1.2.3', '1.2.4']
	}
}

// Ruby it `it "returns true for an Apache URL" do` at line 132.
pub fn ruby_apache_spec_l132_d7_returns() bool {
	for url in ruby_apache_spec_l9_d2_apache_urls().values() {
		if !apache_core.apache_matches_url(url) {
			return false
		}
	}
	return true
}

// Ruby it `it "returns false for a non-Apache URL" do` at line 136.
pub fn ruby_apache_spec_l136_d8_returns() bool {
	return !apache_core.apache_matches_url(ruby_apache_spec_l31_d3_non_apache_url())
}

// Ruby it `it "returns a hash containing url and regex for an Apache URL" do` at line 142.
pub fn ruby_apache_spec_l142_d9_returns() bool {
	generated := ruby_apache_spec_l32_d4_generated()
	for key, url in ruby_apache_spec_l9_d2_apache_urls() {
		if apache_core.apache_generate_input_values(url) != generated[key] {
			return false
		}
	}
	return true
}

// Ruby it `it "returns an empty hash for a non-Apache URL" do` at line 148.
pub fn ruby_apache_spec_l148_d10_returns() bool {
	return !apache_core.apache_generate_input_values(ruby_apache_spec_l31_d3_non_apache_url()).present
}

// Ruby let `let(:match_data) do` at line 154.
pub fn ruby_apache_spec_l154_d11_match_data() ApacheSpecMatchData {
	generated := ruby_apache_spec_l32_d4_generated()
	matches := ruby_apache_spec_l124_d6_matches()
	mut directory_versions := map[string]string{}
	for version in matches.directories {
		directory_versions[version] = version
	}
	mut file_versions := map[string]string{}
	for version in matches.files {
		file_versions[version] = version
	}
	cached_dirs := apache_core.PageMatchData{
		matches: directory_versions
		regex: generated['version_dir'].regex
		url: generated['version_dir'].url
		cached: true
		has_cached: true
	}
	return ApacheSpecMatchData{
		cached_dirs: cached_dirs
		cached_files: apache_core.PageMatchData{
			matches: file_versions
			regex: generated['name_dir_bin'].regex
			url: generated['name_dir_bin'].url
			cached: true
			has_cached: true
		}
		cached_dirs_default: apache_core.PageMatchData{
			...cached_dirs
			matches: map[string]string{}
		}
	}
}

// Ruby it `it "finds versions in provided content" do` at line 174.
pub fn ruby_apache_spec_l174_d12_finds() bool {
	urls := ruby_apache_spec_l9_d2_apache_urls()
	generated := ruby_apache_spec_l32_d4_generated()
	content := ruby_apache_spec_l68_d5_content()
	directories := apache_core.apache_find_versions(apache_core.ApacheFindRequest{
		url: urls['version_dir']
		content: content.directories
	}, apache_spec_unused_fetcher) or { return false }
	files := apache_core.apache_find_versions(apache_core.ApacheFindRequest{
		url: urls['name_dir_bin']
		regex: generated['name_dir_bin'].regex
		content: content.files
	}, apache_spec_unused_fetcher) or { return false }
	// This `strategy` block is unnecessary but it's intended to test using a
	// generated regex in a `strategy` block.
	with_block := apache_core.apache_find_versions(apache_core.ApacheFindRequest{
		url: urls['version_dir']
		content: content.directories
		has_block: true
		block: apache_spec_scan_block
	}, apache_spec_unused_fetcher) or { return false }
	expected := ruby_apache_spec_l154_d11_match_data()
	return apache_spec_match_data_equal(directories, expected.cached_dirs) && apache_spec_match_data_equal(files, expected.cached_files) && apache_spec_match_data_equal(with_block, expected.cached_dirs)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 193.
pub fn ruby_apache_spec_l193_d13_returns() bool {
	actual := apache_core.apache_find_versions(apache_core.ApacheFindRequest{
		url: ruby_apache_spec_l9_d2_apache_urls()['version_dir']
		content: ''
	}, apache_spec_unused_fetcher) or { return false }
	return apache_spec_match_data_equal(actual, ruby_apache_spec_l154_d11_match_data().cached_dirs_default)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::Apache do
// 7:   subject(:apache) { described_class }
// 8:
// 9:   let(:apache_urls) do
// 10:     {
// 11:       version_dir:                    "https://www.apache.org/dyn/closer.lua?path=abc/1.2.3/def-1.2.3.tar.gz",
// 12:       version_dir_root:               "https://www.apache.org/dyn/closer.lua?path=/abc/1.2.3/def-1.2.3.tar.gz",
// 13:       name_and_version_dir:           "https://www.apache.org/dyn/closer.lua?path=abc/def-1.2.3/ghi-1.2.3.tar.gz",
// 14:       name_dir_bin:                   "https://www.apache.org/dyn/closer.lua?path=abc/def/ghi-1.2.3-bin.tar.gz",
// 15:       name_dir_bin_no_suffix:         "https://www.apache.org/dyn/closer.lua?path=abc/def/ghi-1.2.3",
// 16:       archive_version_dir:            "https://archive.apache.org/dist/abc/1.2.3/def-1.2.3.tar.gz",
// 17:       archive_name_and_version_dir:   "https://archive.apache.org/dist/abc/def-1.2.3/ghi-1.2.3.tar.gz",
// 18:       archive_name_dir_bin:           "https://archive.apache.org/dist/abc/def/ghi-1.2.3-bin.tar.gz",
// 19:       dlcdn_version_dir:              "https://dlcdn.apache.org/abc/1.2.3/def-1.2.3.tar.gz",
// 20:       dlcdn_name_and_version_dir:     "https://dlcdn.apache.org/abc/def-1.2.3/ghi-1.2.3.tar.gz",
// 21:       dlcdn_name_dir_bin:             "https://dlcdn.apache.org/abc/def/ghi-1.2.3-bin.tar.gz",
// 22:       downloads_version_dir:          "https://downloads.apache.org/abc/1.2.3/def-1.2.3.tar.gz",
// 23:       downloads_name_and_version_dir: "https://downloads.apache.org/abc/def-1.2.3/ghi-1.2.3.tar.gz",
// 24:       downloads_name_dir_bin:         "https://downloads.apache.org/abc/def/ghi-1.2.3-bin.tar.gz",
// 25:       mirrors_version_dir:            "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/1.2.3/def-1.2.3.tar.gz",
// 26:       mirrors_version_dir_root:       "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=/abc/1.2.3/def-1.2.3.tar.gz",
// 27:       mirrors_name_and_version_dir:   "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/def-1.2.3/ghi-1.2.3.tar.gz",
// 28:       mirrors_name_dir_bin:           "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=abc/def/ghi-1.2.3-bin.tar.gz",
// 29:     }
// 30:   end
// 31:   let(:non_apache_url) { "https://brew.sh/test" }
// 32:   let(:generated) do
// 33:     values = {
// 34:       version_dir:            {
// 35:         url:   "https://archive.apache.org/dist/abc/",
// 36:         regex: %r{href=["']?v?(\d+(?:\.\d+)+)/}i,
// 37:       },
// 38:       name_and_version_dir:   {
// 39:         url:   "https://archive.apache.org/dist/abc/",
// 40:         regex: %r{href=["']?def-v?(\d+(?:\.\d+)+)/}i,
// 41:       },
// 42:       name_dir_bin:           {
// 43:         url:   "https://archive.apache.org/dist/abc/def/",
// 44:         regex: /href=["']?ghi-v?(\d+(?:\.\d+)+)-bin\.t/i,
// 45:       },
// 46:       name_dir_bin_no_suffix: {
// 47:         url:   "https://archive.apache.org/dist/abc/def/",
// 48:         regex: /href=["']?ghi-v?(\d+(?:\.\d+)+)/i,
// 49:       },
// 50:     }
// 51:     values[:version_dir_root] = values[:version_dir]
// 52:     values[:archive_version_dir] = values[:version_dir]
// 53:     values[:archive_name_and_version_dir] = values[:name_and_version_dir]
// 54:     values[:archive_name_dir_bin] = values[:name_dir_bin]
// 55:     values[:dlcdn_version_dir] = values[:version_dir]
// 56:     values[:dlcdn_name_and_version_dir] = values[:name_and_version_dir]
// 57:     values[:dlcdn_name_dir_bin] = values[:name_dir_bin]
// 58:     values[:downloads_version_dir] = values[:version_dir]
// 59:     values[:downloads_name_and_version_dir] = values[:name_and_version_dir]
// 60:     values[:downloads_name_dir_bin] = values[:name_dir_bin]
// 61:     values[:mirrors_version_dir] = values[:version_dir]
// 62:     values[:mirrors_version_dir_root] = values[:version_dir_root]
// 63:     values[:mirrors_name_and_version_dir] = values[:name_and_version_dir]
// 64:     values[:mirrors_name_dir_bin] = values[:name_dir_bin]
// 65:
// 66:     values
// 67:   end
// 68:   let(:content) do
// 69:     start_html = <<~HTML
// 70:       <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
// 71:       <html>
// 72:       <head>
// 73:         <title>Index of /dist/abc</title>
// 74:       </head>
// 75:       <body>
// 76:         <h1>Index of /dist/abc</h1>
// 77:         <pre>
// 78:           <img src="/icons/blank.gif" alt="Icon ">
// 79:           <a href="?C=N;O=D">Name</a>
// 80:           <a href="?C=M;O=A">Last modified</a>
// 81:           <a href="?C=S;O=A">Size</a>
// 82:           <a href="?C=D;O=A">Description</a>
// 83:           <hr>
// 84:           <img src="/icons/back.gif" alt="[PARENTDIR]">
// 85:           <a href="/dist/">Parent Directory</a>
// 86:                                                              -
// 87:     HTML
// 88:
// 89:     end_html = <<~HTML
// 90:           <hr>
// 91:         </pre>
// 92:       </body>
// 93:       </html>
// 94:     HTML
// 95:
// 96:     directories = <<~HTML
// 97:       <img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.0/">1.2.0/</a>                  2022-01-20 01:20    -
// 98:       <img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.1/">1.2.1/</a>                  2022-01-21 01:21    -
// 99:       <img src="/icons/folder.gif" alt="[DIR]"> <a href="1.2.2/">1.2.2/</a>                  2022-01-22 01:22    -
// 100:       <img src="/icons/folder.gif" alt="[DIR]"> <a href="abc-other/">abc-other/</a>         2022-01-02 01:02    -
// 101:       <img src="/icons/folder.gif" alt="[DIR]"> <a href="abc-something/">abc-something/</a> 2022-01-03 01:03    -
// 102:     HTML
// 103:
// 104:     files = <<~HTML
// 105:       <img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.3-bin.tar.gz">ghi-1.2.3-bin.tar.gz</a>        2022-01-23 01:23   45M
// 106:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-bin.tar.gz.asc">ghi-1.2.3-bin.tar.gz.asc</a>    2022-01-23 01:23  456
// 107:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-bin.tar.gz.sha512">ghi-1.2.3-bin.tar.gz.sha512</a> 2022-01-23 01:23  123
// 108:       <img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.3-src.tar.gz">ghi-1.2.3-src.tar.gz</a>        2022-01-23 01:23  4.5M
// 109:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-src.tar.gz.asc">ghi-1.2.3-src.tar.gz.asc</a>    2022-01-23 01:23  456
// 110:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.3-src.tar.gz.sha512">ghi-1.2.3-src.tar.gz.sha512</a> 2022-01-23 01:23  123
// 111:       <img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.4-bin.tar.gz">ghi-1.2.4-bin.tar.gz</a>        2022-01-24 01:24   56M
// 112:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-bin.tar.gz.asc">ghi-1.2.4-bin.tar.gz.asc</a>    2022-01-24 01:24  567
// 113:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-bin.tar.gz.sha512">ghi-1.2.4-bin.tar.gz.sha512</a> 2022-01-24 01:24  124
// 114:       <img src="/icons/compressed.gif" alt="[   ]"> <a href="ghi-1.2.4-src.tar.gz">ghi-1.2.4-src.tar.gz</a>        2022-01-24 01:24  5.6M
// 115:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-src.tar.gz.asc">ghi-1.2.4-src.tar.gz.asc</a>    2022-01-24 01:24  567
// 116:       <img src="/icons/text.gif" alt="[TXT]"> <a href="ghi-1.2.4-src.tar.gz.sha512">ghi-1.2.4-src.tar.gz.sha512</a> 2022-01-24 01:24  124
// 117:     HTML
// 118:
// 119:     {
// 120:       directories: start_html + directories + end_html,
// 121:       files:       start_html + files + end_html,
// 122:     }
// 123:   end
// 124:   let(:matches) do
// 125:     {
// 126:       directories: ["1.2.0", "1.2.1", "1.2.2"],
// 127:       files:       ["1.2.3", "1.2.4"],
// 128:     }
// 129:   end
// 130:
// 131:   describe "::match?" do
// 132:     it "returns true for an Apache URL" do
// 133:       apache_urls.each_value { |url| expect(apache.match?(url)).to be true }
// 134:     end
// 135:
// 136:     it "returns false for a non-Apache URL" do
// 137:       expect(apache.match?(non_apache_url)).to be false
// 138:     end
// 139:   end
// 140:
// 141:   describe "::generate_input_values" do
// 142:     it "returns a hash containing url and regex for an Apache URL" do
// 143:       apache_urls.each do |key, url|
// 144:         expect(apache.generate_input_values(url)).to eq(generated[key])
// 145:       end
// 146:     end
// 147:
// 148:     it "returns an empty hash for a non-Apache URL" do
// 149:       expect(apache.generate_input_values(non_apache_url)).to eq({})
// 150:     end
// 151:   end
// 152:
// 153:   describe "::find_versions" do
// 154:     let(:match_data) do
// 155:       cached_dirs = {
// 156:         matches: matches[:directories].to_h { |v| [v, Version.new(v)] },
// 157:         regex:   generated[:version_dir][:regex],
// 158:         url:     generated[:version_dir][:url],
// 159:         cached:  true,
// 160:       }
// 161:
// 162:       {
// 163:         cached_dirs:,
// 164:         cached_files:        {
// 165:           matches: matches[:files].to_h { |v| [v, Version.new(v)] },
// 166:           regex:   generated[:name_dir_bin][:regex],
// 167:           url:     generated[:name_dir_bin][:url],
// 168:           cached:  true,
// 169:         },
// 170:         cached_dirs_default: cached_dirs.merge({ matches: {} }),
// 171:       }
// 172:     end
// 173:
// 174:     it "finds versions in provided content" do
// 175:       expect(apache.find_versions(url: apache_urls[:version_dir], content: content[:directories]))
// 176:         .to eq(match_data[:cached_dirs])
// 177:
// 178:       expect(
// 179:         apache.find_versions(
// 180:           url:     apache_urls[:name_dir_bin],
// 181:           regex:   generated[:name_dir_bin][:regex],
// 182:           content: content[:files],
// 183:         ),
// 184:       ).to eq(match_data[:cached_files])
// 185:
// 186:       # This `strategy` block is unnecessary but it's intended to test using a
// 187:       # generated regex in a `strategy` block.
// 188:       expect(apache.find_versions(url: apache_urls[:version_dir], content: content[:directories]) do |page, regex|
// 189:         page.scan(regex).map(&:first)
// 190:       end).to eq(match_data[:cached_dirs])
// 191:     end
// 192:
// 193:     it "returns default match_data when content is blank" do
// 194:       expect(apache.find_versions(url: apache_urls[:version_dir], content: ""))
// 195:         .to eq(match_data[:cached_dirs_default])
// 196:     end
// 197:   end
// 198: end
