module shared

import brew_runtime
import regex

// Translated from Homebrew/brew `rubocops/shared/url_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// UrlAuditNode is the typed counterpart of the send/block nodes accepted by the
// The Ruby helper's `source` is the complete method-call source and `content` is the
// value returned by HelperFunctions#string_content for its first parameter.
pub struct UrlAuditNode {
pub:
	source         string
	content        string
	begin_pos      int
	end_pos        int
	argument_begin int
	argument_end   int
}

pub struct UrlAuditMatch {
pub:
	url       string
	content   string
	index     int
	begin_pos int
	end_pos   int
	matched   string
}

pub struct UrlProblem {
pub:
	kind              string
	url               string
	index             int
	begin_pos         int
	end_pos           int
	message           string
	has_correction    bool
	replacement_begin int
	replacement_end   int
	replacement       string
}

fn url_display(url_type string, node UrlAuditNode) string {
	return if url_type == 'cask' { node.source } else { node.content }
}

pub fn simple_url_audit_nodes(urls []string) []UrlAuditNode {
	mut offset := 0
	mut nodes := []UrlAuditNode{cap: urls.len}
	for url in urls {
		nodes << UrlAuditNode{
			source: url
			content: url
			begin_pos: offset
			end_pos: offset + url.len
			argument_begin: offset
			argument_end: offset + url.len
		}
		offset += url.len + 1
	}
	return nodes
}

// audit_urls_pattern preserves audit_urls' iteration order and its cask/formula
// distinction. V's regex engine is used only for this public generic boundary;
// the source policies below are represented explicitly to retain Ruby semantics.
pub fn audit_urls_pattern(url_type string, urls []UrlAuditNode, pattern string) []UrlAuditMatch {
	mut matches := []UrlAuditMatch{}
	for index, node in urls {
		mut expression := regex.regex_opt(pattern) or { continue }
		begin_pos, end_pos := expression.find(node.content)
		if begin_pos < 0 {
			continue
		}
		matches << UrlAuditMatch{
			url: url_display(url_type, node)
			content: node.content
			index: index
			begin_pos: begin_pos
			end_pos: end_pos
			matched: node.content[begin_pos..end_pos]
		}
	}
	return matches
}

fn url_problem(kind string, url string, index int, node UrlAuditNode, message string) UrlProblem {
	return UrlProblem{
		kind: kind
		url: url
		index: index
		begin_pos: node.begin_pos
		end_pos: node.end_pos
		message: message
	}
}

fn url_correction_problem(kind string, url string, index int, node UrlAuditNode, message string,
	replacement string) UrlProblem {
	return UrlProblem{
		kind: kind
		url: url
		index: index
		begin_pos: node.begin_pos
		end_pos: node.end_pos
		message: message
		has_correction: true
		replacement_begin: node.argument_begin
		replacement_end: node.argument_end
		replacement: replacement
	}
}

fn url_has_non_ascii(value string) bool {
	for character in value.bytes() {
		if character > 0x7f {
			return true
		}
	}
	return false
}

fn url_scheme_remainder(value string) ?string {
	separator := value.index('://') or { return none }
	return value[separator + 3..]
}

fn url_host_and_path(value string) (string, string) {
	remainder := url_scheme_remainder(value) or { return '', '' }
	slash := remainder.index('/') or { return remainder, '' }
	return remainder[..slash], remainder[slash + 1..]
}

fn url_apache_release_path(value string) ?string {
	lower := value.to_lower()
	for prefix in [
		'http://dist.apache.org/repos/dist/release/',
		'https://dist.apache.org/repos/dist/release/',
		'http://dlcdn.apache.org/',
		'https://dlcdn.apache.org/',
		'http://downloads.apache.org/',
		'https://downloads.apache.org/',
	] {
		if lower.starts_with(prefix) {
			return value[prefix.len..]
		}
	}
	if !lower.starts_with('http://') && !lower.starts_with('https://') {
		return none
	}
	host, path := url_host_and_path(value)
	lower_host := host.to_lower()
	if lower_host != 'apache.org' && !lower_host.ends_with('.apache.org') {
		return none
	}
	lower_path := path.to_lower()
	if lower_path.starts_with('dist/') {
		return path['dist/'.len..]
	}
	if !lower_path.starts_with('dyn/') {
		return none
	}
	mut marker_end := -1
	for marker in ['closer.cgi?', 'mirrors.cgi?'] {
		if position := lower_path.index(marker) {
			if position != 'dyn/'.len && (position == 0 || lower_path[position - 1] != `/`) {
				continue
			}
			candidate := position + marker.len
			if marker_end < 0 || candidate < marker_end {
				marker_end = candidate
			}
		}
	}
	if marker_end < 0 {
		return none
	}
	query := path[marker_end..]
	lower_query := lower_path[marker_end..]
	mut value_start := -1
	for prefix in ['action=download&filename=', 'action=download&path=', 'filename=', 'path='] {
		if lower_query.starts_with(prefix) {
			value_start = prefix.len
			break
		}
	}
	if value_start < 0 {
		return none
	}
	result := query[value_start..]
	return if result.starts_with('/') { result[1..] } else { result }
}

fn url_http_upgrade_required(value string) bool {
	if !value.starts_with('http://') {
		return false
	}
	host, _ := url_host_and_path(value)
	after_host := value['http://'.len + host.len..]
	if host in [
		'ftp.gnu.org',
		'ftpmirror.gnu.org',
		'download.savannah.gnu.org',
		'download-mirror.savannah.gnu.org',
		'code.google.com',
		'fossies.org',
		'mirrors.kernel.org',
		'mirrors.ocf.berkeley.edu',
		'tools.ietf.org',
		'launchpad.net',
		'github.com',
		'bitbucket.org',
		'anonscm.debian.org',
		'cpan.metacpan.org',
		'hackage.haskell.org',
	] && after_host.starts_with('/') {
		return true
	}
	if ((host == 'apache.org' || host.ends_with('.apache.org')) && after_host.starts_with('/')) || ((host == 'bintray.com' || host.ends_with('.bintray.com')) && after_host.starts_with('/')) || host == 'archive.org' || host.ends_with('.archive.org') || host == 'freedesktop.org' || host.ends_with('.freedesktop.org') || ((host == 'mirrorservice.org' || host.ends_with('.mirrorservice.org')) && after_host.starts_with('/')) {
		return true
	}
	return (host == 'download.sourceforge.net' || host == 'downloads.sourceforge.net') && after_host.starts_with('/')
}

fn url_sourceforge(value string) bool {
	if !value.starts_with('http://') && !value.starts_with('https://') {
		return false
	}
	lower := value
	for domain in ['sourceforge.com', 'sourceforge.net', 'sf.com', 'sf.net'] {
		position := lower.index(domain) or { continue }
		before_ok := position == 0 || (!lower[position - 1].is_alnum() && lower[position - 1] != `_`)
		after := position + domain.len
		after_ok := after == lower.len || (!lower[after].is_alnum() && lower[after] != `_`)
		if before_ok && after_ok {
			return true
		}
	}
	return false
}

fn url_word_host_prefix(value string, prefix string) bool {
	if !value.starts_with(prefix) {
		return false
	}
	remainder := value[prefix.len..]
	dot := remainder.index('.') or { return false }
	if dot == 0 {
		return false
	}
	for character in remainder[..dot].bytes() {
		if !character.is_alnum() && character != `_` {
			return false
		}
	}
	return remainder[dot..].starts_with('.dl.')
}

fn url_starts_hex_40(value string) bool {
	if value.len < 40 {
		return false
	}
	for character in value[..40].bytes() {
		if !character.is_hex_digit() {
			return false
		}
	}
	return true
}

fn url_github_archive_reference(value string) ?string {
	if !value.starts_with('https://') || !value.contains('github') || !value.ends_with('.tar.gz') {
		return none
	}
	marker := '/archive/'
	position := value.index(marker) or { return none }
	reference := value[position + marker.len..value.len - '.tar.gz'.len]
	if url_starts_hex_40(reference) || reference.starts_with('refs/tags/') || reference.starts_with('refs/heads/') {
		return none
	}
	return reference
}

fn url_codeload_parts(value string) ?[]string {
	for scheme in ['http://codeload.github.com/', 'https://codeload.github.com/'] {
		if !value.starts_with(scheme) {
			continue
		}
		remainder := value[scheme.len..]
		mut marker_position := -1
		mut marker_length := 0
		for marker in ['/tar.gz/', '/zip/'] {
			if position := remainder.last_index(marker) {
				marker_position = position
				marker_length = marker.len
				break
			}
		}
		if marker_position <= 0 {
			continue
		}
		owner_repo := remainder[..marker_position]
		repo_separator := owner_repo.last_index('/') or { continue }
		owner := owner_repo[..repo_separator]
		repo := owner_repo[repo_separator + 1..]
		reference := remainder[marker_position + marker_length..]
		if owner != '' && repo != '' && reference != '' {
			return [owner, repo, reference]
		}
	}
	return none
}

fn url_maven_path(value string) ?string {
	mut start := -1
	for scheme in ['http://', 'https://'] {
		if position := value.index(scheme) {
			if start < 0 || position < start {
				start = position
			}
		}
	}
	if start < 0 {
		return none
	}
	candidate := value[start..]
	host, path := url_host_and_path(candidate)
	mut valid_host := host == 'central.maven.org'
	if host.starts_with('repo') && host.ends_with('.maven.org') {
		digits := host['repo'.len..host.len - '.maven.org'.len]
		valid_host = digits != '' && digits.bytes().all(it.is_digit())
	}
	if !valid_host || !path.starts_with('maven2/') {
		return none
	}
	return path['maven2/'.len..]
}

pub fn audit_url_nodes(url_type string, input_urls []UrlAuditNode, mirrors []UrlAuditNode,
	livecheck_urls []string) []UrlProblem {
	mut problems := []UrlProblem{}
	for index, node in input_urls {
		url := url_display(url_type, node)
		content := node.content
		if url_has_non_ascii(content) {
			problems << url_problem('ascii', url, index, node, 'Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of ${url}.')
		}
		for prefix in ['http://ftp.gnu.org/', 'https://ftp.gnu.org/', 'ftp://ftp.gnu.org/'] {
			if content.starts_with(prefix) {
				problems << url_problem('gnu_mirror', url, index, node, '${url} should be: https://ftpmirror.gnu.org/gnu/${content[prefix.len..]}')
				break
			}
		}
		if content.starts_with('http://fossies.org/') || content.starts_with('https://fossies.org/') {
			problems << url_problem('fossies', url, index, node, 'Please don\'t use "fossies.org" in the `url` (using as a mirror is fine)')
		}
		if release_path := url_apache_release_path(content) {
			if url !in livecheck_urls {
				fixed := 'https://www.apache.org/dyn/closer.lua?path=${release_path}'
				problems << url_correction_problem('apache', url, index, node, '${url} should be: ${fixed}', '"${fixed}"')
			}
		}
		for scheme in ['cvs', 'bzr', 'hg', 'fossil'] {
			if content.starts_with('${scheme}://') {
				problems << url_problem('version_control', url, index, node, 'Use of the "${scheme}://" scheme is deprecated, pass `using: :${scheme}` instead')
				break
			}
		}
		if content.starts_with('svn+http://') {
			problems << url_problem('svn', url, index, node, 'Use of the "svn+http://" scheme is deprecated, pass `using: :svn` instead')
		}
	}

	for mirror_index, mirror in mirrors {
		mirror_url := url_display(url_type, mirror)
		for node in input_urls {
			if node.content == mirror.content {
				problems << url_problem('duplicate_mirror', mirror_url, mirror_index, mirror, 'URL should not be duplicated as a mirror: ${node.content}')
			}
		}
	}

	mut urls := input_urls.clone()
	urls << mirrors
	for index, node in urls {
		url := url_display(url_type, node)
		content := node.content
		if url_http_upgrade_required(content) {
			https_url := if url.len >= 4 { url[..4] + 's' + url[4..] } else { url }
			mut https_index := -1
			for found_index, candidate in urls {
				if candidate.content.contains(https_url) {
					https_index = found_index
				}
			}
			if https_index < 0 || https_index > index {
				problems << url_problem('https', url, index, node, 'Please use https:// for ${url}')
			}
		}
	}

	for index, mirror in mirrors {
		url := url_display(url_type, mirror)
		lower := mirror.content.to_lower()
		if lower.starts_with('http://') || lower.starts_with('https://') {
			host, path := url_host_and_path(mirror.content)
			lower_host := host.to_lower()
			if lower_host == 'apache.org' || lower_host.ends_with('.apache.org') {
				lower_path := path.to_lower()
				for marker in ['dyn/closer.cgi?path=', 'dyn/closer.lua?path='] {
					if lower_path.starts_with(marker) {
						mut archive_path := path[marker.len..]
						if archive_path.starts_with('/') {
							archive_path = archive_path[1..]
						}
						problems << url_problem('apache_archive_mirror', url, index, mirror, '${url} should be: https://archive.apache.org/dist/${archive_path}')
						break
					}
				}
			}
		}
	}

	for index, node in urls {
		url := url_display(url_type, node)
		content := node.content
		lower := content.to_lower()
		cpan_prefix := 'http://search.mcpan.org/cpan/'
		if lower.starts_with(cpan_prefix) {
			problems << url_problem('cpan', url, index, node, '${url} should be: https://cpan.metacpan.org/${content[cpan_prefix.len..]}')
		}
		for prefix in ['http://ftp.gnome.org/pub/gnome/', 'ftp://ftp.gnome.org/pub/gnome/'] {
			if lower.starts_with(prefix) {
				problems << url_problem('gnome', url, index, node, '${url} should be: https://download.gnome.org/${content[prefix.len..]}')
				break
			}
		}
		debian_prefix := 'git://anonscm.debian.org/users/'
		if lower.starts_with(debian_prefix) {
			problems << url_problem('debian_git', url, index, node, '${url} should be: https://anonscm.debian.org/git/users/${content[debian_prefix.len..]}')
		}
		if content.starts_with('ftp://ftp.mirrorservice.org') {
			problems << url_problem('mirrorservice_ftp', url, index, node, 'Please use https:// for ${url}')
		}
		cpan_ftp_prefix := 'ftp://ftp.cpan.org/pub/CPAN'
		if lower.starts_with(cpan_ftp_prefix.to_lower()) {
			problems << url_problem('cpan_ftp', url, index, node, '${url} should be: http://search.cpan.org/CPAN${content[cpan_ftp_prefix.len..]}')
		}
	}

	for index, node in urls {
		content := node.content
		if !url_sourceforge(content) || content.contains('/svnroot/') || content.contains('svn.sourceforge') || content.contains('/p/') {
			continue
		}
		url := url_display(url_type, node)
		mut delimiter := ''
		if content.contains('?use_mirror=') {
			delimiter = '?'
		} else if content.contains('&use_mirror=') {
			delimiter = '&'
		}
		if delimiter != '' {
			problems << url_problem('sourceforge_use_mirror', url, index, node, 'Don\'t use "${delimiter}use_mirror" in SourceForge URLs (`url` is ${url}).')
		}
		if content.ends_with('/download') {
			problems << url_problem('sourceforge_download', url, index, node, 'Don\'t use "/download" in SourceForge URLs (`url` is ${url}).')
		}
		if (content.starts_with('http://sourceforge.') || content.starts_with('https://sourceforge.') || content.starts_with('http://sf.') || content.starts_with('https://sf.')) && url !in livecheck_urls {
			problems << url_problem('sourceforge_geolocation', url, index, node, 'Use "https://downloads.sourceforge.net" to get geolocation (`url` is ${url}).')
		}
		if content.starts_with('http://prdownloads.') || content.starts_with('https://prdownloads.') {
			problems << url_problem('sourceforge_prdownloads', url, index, node, 'Don\'t use "prdownloads" in SourceForge URLs (`url` is ${url}).')
		}
		if url_word_host_prefix(content, 'http://') {
			problems << url_problem('sourceforge_dl_mirror', url, index, node, 'Don\'t use specific "dl" mirrors in SourceForge URLs (`url` is ${url}).')
		}
		if content.starts_with('http://download.sf.net') || content.starts_with('https://download.sf.net') || content.starts_with('http://downloads.sf.net') || content.starts_with('https://downloads.sf.net') {
			problems << url_problem('sourceforge_sf_alias', url, index, node, 'Use "https://downloads.sourceforge.net" instead of "downloads.sf.net" (`url` is ${url})')
		}
	}

	for index, node in urls {
		url := url_display(url_type, node)
		content := node.content
		lower := content.to_lower()
		unsecure_debian := 'http://http.debian.net/debian/'
		if lower.starts_with(unsecure_debian) {
			problems << url_problem('debian_insecure', url, index, node, 'Please use a secure mirror for Debian URLs.\nWe recommend:\n  https://deb.debian.org/debian/${content[unsecure_debian.len..]}\n')
		}
		mut noncanonical := content.starts_with('https://mirrors.kernel.org/debian/') || content.starts_with('https://mirrors.ocf.berkeley.edu/debian/')
		if content.starts_with('https://') {
			host, path := url_host_and_path(content)
			noncanonical = noncanonical || ((host == 'mirrorservice.org' || host.ends_with('.mirrorservice.org')) && path.starts_with('sites/ftp.debian.org/debian/'))
		}
		if noncanonical {
			problems << url_problem('debian_canonical', url, index, node, 'Please use https://deb.debian.org/debian/ for ${url}')
		}
		mut google_code := content.starts_with('http://code.google.com/')
		if content.starts_with('http://') {
			host, path := url_host_and_path(content)
			google_code = google_code || (host.len > '.googlecode.com'.len && host.ends_with('.googlecode.com') && path.starts_with('files'))
		}
		if google_code {
			problems << url_problem('google_code_https', url, index, node, 'Please use https:// for ${url}')
		}
		if content.starts_with('git://') {
			host, _ := url_host_and_path(content)
			if host.ends_with('github.com') {
				problems << url_problem('github_git', url, index, node, 'Please use https:// for ${url}')
			}
			if host.ends_with('gitorious.org') {
				problems << url_problem('gitorious_git', url, index, node, 'Please use https:// for ${url}')
			}
		}
		if content.starts_with('http://github.com/') && content.ends_with('.git') {
			problems << url_problem('github_http_git', url, index, node, 'Please use https:// for ${url}')
		}
		if url_type == 'formula' && content.starts_with('https://github.com/') && (content.ends_with('/archive/main.tar.gz') || content.ends_with('/archive/master.tar.gz') || content.ends_with('/archive/main.zip') || content.ends_with('/archive/master.zip')) {
			problems << url_problem('github_branch_archive', url, index, node, 'Use versioned rather than branch tarballs for stable checksums.')
		}
		if content.starts_with('https://') && content.contains('github') && (content.contains('/tarball/') || content.contains('/zipball/')) && !content.ends_with('.git') {
			problems << url_problem('github_old_archive', url, index, node, 'Use /archive/ URLs for GitHub tarballs (`url` is ${url}).')
		}
		if reference := url_github_archive_reference(content) {
			if !content.ends_with('.git') {
				problems << url_problem('github_archive_ref', url, index, node, 'Use "refs/tags/${reference}" or "refs/heads/${reference}" for GitHub references (`url` is ${url}).')
			}
		}
		if content.starts_with('https://') && content.contains('github') && content.ends_with('.zip') && (content.contains('/archive/') || content.contains('/releases/')) && !content.contains('releases/download') && !content.contains('desktop.githubusercontent.com/releases/') && !(content.contains('raw.githubusercontent.com/') && (content.contains('/main/') || content.contains('/master/') || content.contains('/HEAD/'))) {
			problems << url_problem('github_zip', url, index, node, 'Use GitHub tarballs rather than zipballs (`url` is ${url}).')
		}
		if parts := url_codeload_parts(content) {
			problems << url_problem('github_codeload', url, index, node, 'Use GitHub archive URLs:\n  https://github.com/${parts[0]}/${parts[1]}/archive/${parts[2]}.tar.gz\nRather than codeload:\n  ${url}\n')
		}
		if maven_path := url_maven_path(content) {
			problems << url_problem('maven', url, index, node, '${url} should be: https://search.maven.org/remotecontent?filepath=${maven_path}')
		}
	}
	return problems
}

pub fn correct_url_problems(source string, problems []UrlProblem) string {
	mut correctable := problems.filter(it.has_correction)
	correctable.sort(a.replacement_begin > b.replacement_begin)
	mut corrected := source
	for problem in correctable {
		if problem.replacement_begin >= 0 && problem.replacement_end >= problem.replacement_begin && problem.replacement_end <= corrected.len {
			corrected = corrected[..problem.replacement_begin] + problem.replacement + corrected[problem.replacement_end..]
		}
	}
	return corrected
}

fn url_node_from_value(value brew_runtime.Value) UrlAuditNode {
	content := value.attributes['content'] or { value.as_string() }
	source := value.attributes['source'] or { value.as_string() }
	begin_pos := (value.attributes['begin_pos'] or { '0' }).int()
	end_pos := (value.attributes['end_pos'] or { (begin_pos + source.len).str() }).int()
	argument_begin := (value.attributes['argument_begin'] or { begin_pos.str() }).int()
	argument_end := (value.attributes['argument_end'] or { (argument_begin + content.len).str() }).int()
	return UrlAuditNode{source, content, begin_pos, end_pos, argument_begin, argument_end}
}

fn url_nodes_from_value(value brew_runtime.Value) []UrlAuditNode {
	items := value.as_array() or { return [] }
	return items.map(url_node_from_value(it))
}

fn url_match_value(item UrlAuditMatch) brew_runtime.Value {
	return brew_runtime.structured_value('MatchData', item.matched, {
		'url':       item.url
		'content':   item.content
		'index':     item.index.str()
		'begin_pos': item.begin_pos.str()
		'end_pos':   item.end_pos.str()
		'matched':   item.matched
	})
}

pub fn url_problem_value(problem UrlProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':              problem.kind
		'url':               problem.url
		'index':             problem.index.str()
		'begin_pos':         problem.begin_pos.str()
		'end_pos':           problem.end_pos.str()
		'message':           problem.message
		'has_correction':    problem.has_correction.str()
		'replacement_begin': problem.replacement_begin.str()
		'replacement_end':   problem.replacement_end.str()
		'replacement':       problem.replacement
	})
}

// Ruby method `audit_urls(urls, regex, &_block)` at line 23.
pub fn ruby_url_helper_l23_d1_audit_urls(args ...brew_runtime.Value) brew_runtime.Value {
	urls := if args.len > 0 { url_nodes_from_value(args[0]) } else { []UrlAuditNode{} }
	pattern := if args.len > 1 { args[1].as_string() } else { '.*' }
	url_type := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'formula' }
	return brew_runtime.array_value(audit_urls_pattern(url_type, urls, pattern).map(url_match_value(it)))
}

// Ruby method `audit_url(type, urls, mirrors, livecheck_urls: [])` at line 52.
pub fn ruby_url_helper_l52_d2_audit_url(args ...brew_runtime.Value) brew_runtime.Value {
	url_type := if args.len > 0 { args[0].as_string().trim_left(':') } else { 'formula' }
	urls := if args.len > 1 { url_nodes_from_value(args[1]) } else { []UrlAuditNode{} }
	mirrors := if args.len > 2 { url_nodes_from_value(args[2]) } else { []UrlAuditNode{} }
	livecheck_urls := if args.len > 3 {
		(args[3].as_array() or { [] }).map(it.as_string())
	} else {
		[]string{}
	}
	return brew_runtime.array_value(audit_url_nodes(url_type, urls, mirrors, livecheck_urls).map(url_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # This module performs common checks the `homepage` field in both formulae and casks.
// 9:     module UrlHelper
// 10:       include HelperFunctions
// 11:
// 12:       # Yields to block when there is a match.
// 13:       #
// 14:       # @param urls [Array] url/mirror method call nodes
// 15:       # @param regex [Regexp] pattern to match URLs
// 16:       sig {
// 17:         params(
// 18:           urls:   T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 19:           regex:  T.any(Regexp, String),
// 20:           _block: T.proc.params(match_object: MatchData, url: String, index: Integer).void,
// 21:         ).void
// 22:       }
// 23:       def audit_urls(urls, regex, &_block)
// 24:         urls.each_with_index do |url_node, index|
// 25:           if @type == :cask
// 26:             url_string_node = T.cast(url_node, RuboCop::AST::SendNode).first_argument
// 27:             url_string = url_node.source
// 28:           else
// 29:             url_string_node = parameters(url_node).first
// 30:             next unless url_string_node
// 31:
// 32:             url_string = string_content(url_string_node)
// 33:           end
// 34:
// 35:           match_object = regex_match_group(url_string_node, regex)
// 36:           next unless match_object
// 37:
// 38:           offending_node(url_string_node.parent)
// 39:
// 40:           yield match_object, url_string, index
// 41:         end
// 42:       end
// 43:
// 44:       sig {
// 45:         params(
// 46:           type:           Symbol,
// 47:           urls:           T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 48:           mirrors:        T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 49:           livecheck_urls: T::Array[String],
// 50:         ).void
// 51:       }
// 52:       def audit_url(type, urls, mirrors, livecheck_urls: [])
// 53:         @type = T.let(type, T.nilable(Symbol))
// 54:
// 55:         # URLs must be ASCII; IDNs must be punycode
// 56:         ascii_pattern = /[^\p{ASCII}]+/
// 57:         audit_urls(urls, ascii_pattern) do |_, url|
// 58:           problem "Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of #{url}."
// 59:         end
// 60:
// 61:         # Prefer ftpmirror.gnu.org as suggested by https://www.gnu.org/prep/ftp.en.html
// 62:         gnu_pattern = %r{^(?:https?|ftp)://ftp\.gnu\.org/(.*)}
// 63:         audit_urls(urls, gnu_pattern) do |match, url|
// 64:           problem "#{url} should be: https://ftpmirror.gnu.org/gnu/#{match[1]}"
// 65:         end
// 66:
// 67:         # Fossies upstream requests they aren't used as primary URLs
// 68:         # https://github.com/Homebrew/homebrew-core/issues/14486#issuecomment-307753234
// 69:         fossies_pattern = %r{^https?://fossies\.org/}
// 70:         audit_urls(urls, fossies_pattern) do
// 71:           problem "Please don't use \"fossies.org\" in the `url` (using as a mirror is fine)"
// 72:         end
// 73:
// 74:         apache_pattern = %r{
// 75:           ^https?://
// 76:           (?:dist\.apache\.org/repos/dist/release/
// 77:             |(?:dlcdn|downloads)\.apache\.org/
// 78:             |(?:[^/]*\.)?apache\.org/
// 79:              (?:dyn/(?:.*/)?(?:closer|mirrors)\.cgi\?(?:action=download&)?(?:filename|path)=/?
// 80:                |dist/))
// 81:           (.*)
// 82:         }ix
// 83:         audit_urls(urls, apache_pattern) do |match, url, index|
// 84:           next if livecheck_urls.include?(url)
// 85:
// 86:           fixed = "https://www.apache.org/dyn/closer.lua?path=#{match[1]}"
// 87:           url_parameter_node = parameters(urls.fetch(index)).fetch(0)
// 88:           problem "#{url} should be: #{fixed}" do |corrector|
// 89:             corrector.replace(url_parameter_node.source_range, "\"#{fixed}\"")
// 90:           end
// 91:         end
// 92:
// 93:         version_control_pattern = %r{^(cvs|bzr|hg|fossil)://}
// 94:         audit_urls(urls, version_control_pattern) do |match, _|
// 95:           problem "Use of the \"#{match[1]}://\" scheme is deprecated, pass `using: :#{match[1]}` instead"
// 96:         end
// 97:
// 98:         svn_pattern = %r{^svn\+http://}
// 99:         audit_urls(urls, svn_pattern) do |_, _|
// 100:           problem "Use of the \"svn+http://\" scheme is deprecated, pass `using: :svn` instead"
// 101:         end
// 102:
// 103:         audit_urls(mirrors, /.*/) do |_, mirror|
// 104:           urls.each do |url|
// 105:             url_string = string_content(parameters(url).fetch(0))
// 106:             next unless url_string.eql?(mirror)
// 107:
// 108:             problem "URL should not be duplicated as a mirror: #{url_string}"
// 109:           end
// 110:         end
// 111:
// 112:         urls += mirrors
// 113:
// 114:         # Check a variety of SSL/TLS URLs that don't consistently auto-redirect
// 115:         # or are overly common errors that need to be reduced & fixed over time.
// 116:         http_to_https_patterns = Regexp.union([%r{^http://ftp\.gnu\.org/},
// 117:                                                %r{^http://ftpmirror\.gnu\.org/},
// 118:                                                %r{^http://download\.savannah\.gnu\.org/},
// 119:                                                %r{^http://download-mirror\.savannah\.gnu\.org/},
// 120:                                                %r{^http://(?:[^/]*\.)?apache\.org/},
// 121:                                                %r{^http://code\.google\.com/},
// 122:                                                %r{^http://fossies\.org/},
// 123:                                                %r{^http://mirrors\.kernel\.org/},
// 124:                                                %r{^http://mirrors\.ocf\.berkeley\.edu/},
// 125:                                                %r{^http://(?:[^/]*\.)?bintray\.com/},
// 126:                                                %r{^http://tools\.ietf\.org/},
// 127:                                                %r{^http://launchpad\.net/},
// 128:                                                %r{^http://github\.com/},
// 129:                                                %r{^http://bitbucket\.org/},
// 130:                                                %r{^http://anonscm\.debian\.org/},
// 131:                                                %r{^http://cpan\.metacpan\.org/},
// 132:                                                %r{^http://hackage\.haskell\.org/},
// 133:                                                %r{^http://(?:[^/]*\.)?archive\.org},
// 134:                                                %r{^http://(?:[^/]*\.)?freedesktop\.org},
// 135:                                                %r{^http://(?:[^/]*\.)?mirrorservice\.org/},
// 136:                                                %r{^http://downloads?\.sourceforge\.net/}])
// 137:         audit_urls(urls, http_to_https_patterns) do |_, url, index|
// 138:           # It's fine to have a plain HTTP mirror further down the mirror list.
// 139:           https_url = url.dup.insert(4, "s")
// 140:           https_index = T.let(nil, T.nilable(Integer))
// 141:           audit_urls(urls, https_url) do |_, _, found_https_index|
// 142:             https_index = found_https_index
// 143:           end
// 144:           problem "Please use https:// for #{url}" if !https_index || https_index > index
// 145:         end
// 146:
// 147:         apache_mirror_pattern = %r{^https?://(?:[^/]*\.)?apache\.org/dyn/closer\.(?:cgi|lua)\?path=/?(.*)}i
// 148:         audit_urls(mirrors, apache_mirror_pattern) do |match, mirror|
// 149:           problem "#{mirror} should be: https://archive.apache.org/dist/#{match[1]}"
// 150:         end
// 151:
// 152:         cpan_pattern = %r{^http://search\.mcpan\.org/CPAN/(.*)}i
// 153:         audit_urls(urls, cpan_pattern) do |match, url|
// 154:           problem "#{url} should be: https://cpan.metacpan.org/#{match[1]}"
// 155:         end
// 156:
// 157:         gnome_pattern = %r{^(http|ftp)://ftp\.gnome\.org/pub/gnome/(.*)}i
// 158:         audit_urls(urls, gnome_pattern) do |match, url|
// 159:           problem "#{url} should be: https://download.gnome.org/#{match[2]}"
// 160:         end
// 161:
// 162:         debian_pattern = %r{^git://anonscm\.debian\.org/users/(.*)}i
// 163:         audit_urls(urls, debian_pattern) do |match, url|
// 164:           problem "#{url} should be: https://anonscm.debian.org/git/users/#{match[1]}"
// 165:         end
// 166:
// 167:         # Prefer HTTP/S when possible over FTP protocol due to possible firewalls.
// 168:         mirror_service_pattern = %r{^ftp://ftp\.mirrorservice\.org}
// 169:         audit_urls(urls, mirror_service_pattern) do |_, url|
// 170:           problem "Please use https:// for #{url}"
// 171:         end
// 172:
// 173:         cpan_ftp_pattern = %r{^ftp://ftp\.cpan\.org/pub/CPAN(.*)}i
// 174:         audit_urls(urls, cpan_ftp_pattern) do |match_obj, url|
// 175:           problem "#{url} should be: http://search.cpan.org/CPAN#{match_obj[1]}"
// 176:         end
// 177:
// 178:         # SourceForge url patterns
// 179:         sourceforge_patterns = %r{^https?://.*\b(sourceforge|sf)\.(com|net)}
// 180:         audit_urls(urls, sourceforge_patterns) do |_, url|
// 181:           # Skip if the URL looks like a SVN repository.
// 182:           next if url.include? "/svnroot/"
// 183:           next if url.include? "svn.sourceforge"
// 184:           next if url.include? "/p/"
// 185:
// 186:           if url =~ /(\?|&)use_mirror=/
// 187:             problem "Don't use \"#{Regexp.last_match(1)}use_mirror\" in SourceForge URLs (`url` is #{url})."
// 188:           end
// 189:
// 190:           problem "Don't use \"/download\" in SourceForge URLs (`url` is #{url})." if url.end_with?("/download")
// 191:
// 192:           if url.match?(%r{^https?://(sourceforge|sf)\.}) && !livecheck_urls.include?(url)
// 193:             problem "Use \"https://downloads.sourceforge.net\" to get geolocation (`url` is #{url})."
// 194:           end
// 195:
// 196:           if url.match?(%r{^https?://prdownloads\.})
// 197:             problem "Don't use \"prdownloads\" in SourceForge URLs (`url` is #{url})."
// 198:           end
// 199:
// 200:           if url.match?(%r{^http://\w+\.dl\.})
// 201:             problem "Don't use specific \"dl\" mirrors in SourceForge URLs (`url` is #{url})."
// 202:           end
// 203:
// 204:           # sf.net does HTTPS -> HTTP redirects.
// 205:           if url.match?(%r{^https?://downloads?\.sf\.net})
// 206:             problem "Use \"https://downloads.sourceforge.net\" instead of \"downloads.sf.net\" (`url` is #{url})"
// 207:           end
// 208:         end
// 209:
// 210:         # Debian has an abundance of secure mirrors. Let's not pluck the insecure
// 211:         # one out of the grab bag.
// 212:         unsecure_deb_pattern = %r{^http://http\.debian\.net/debian/(.*)}i
// 213:         audit_urls(urls, unsecure_deb_pattern) do |match, _|
// 214:           problem <<~EOS
// 215:             Please use a secure mirror for Debian URLs.
// 216:             We recommend:
// 217:               https://deb.debian.org/debian/#{match[1]}
// 218:           EOS
// 219:         end
// 220:
// 221:         # Check to use canonical URLs for Debian packages
// 222:         noncanon_deb_pattern =
// 223:           Regexp.union([%r{^https://mirrors\.kernel\.org/debian/},
// 224:                         %r{^https://mirrors\.ocf\.berkeley\.edu/debian/},
// 225:                         %r{^https://(?:[^/]*\.)?mirrorservice\.org/sites/ftp\.debian\.org/debian/}])
// 226:         audit_urls(urls, noncanon_deb_pattern) do |_, url|
// 227:           problem "Please use https://deb.debian.org/debian/ for #{url}"
// 228:         end
// 229:
// 230:         # Check for new-url Google Code download URLs, https:// is preferred
// 231:         google_code_pattern = Regexp.union([%r{^http://[A-Za-z0-9\-.]*\.googlecode\.com/files.*},
// 232:                                             %r{^http://code\.google\.com/}])
// 233:         audit_urls(urls, google_code_pattern) do |_, url|
// 234:           problem "Please use https:// for #{url}"
// 235:         end
// 236:
// 237:         # Check for `git://` GitHub repository URLs, https:// is preferred.
// 238:         git_gh_pattern = %r{^git://[^/]*github\.com/}
// 239:         audit_urls(urls, git_gh_pattern) do |_, url|
// 240:           problem "Please use https:// for #{url}"
// 241:         end
// 242:
// 243:         # Check for `git://` Gitorious repository URLs, https:// is preferred.
// 244:         git_gitorious_pattern = %r{^git://[^/]*gitorious\.org/}
// 245:         audit_urls(urls, git_gitorious_pattern) do |_, url|
// 246:           problem "Please use https:// for #{url}"
// 247:         end
// 248:
// 249:         # Check for `http://` GitHub repository URLs, https:// is preferred.
// 250:         gh_pattern = %r{^http://github\.com/.*\.git$}
// 251:         audit_urls(urls, gh_pattern) do |_, url|
// 252:           problem "Please use https:// for #{url}"
// 253:         end
// 254:
// 255:         # Check for default branch GitHub archives.
// 256:         if type == :formula
// 257:           tarball_gh_pattern = %r{^https://github\.com/.*archive/(main|master)\.(tar\.gz|zip)$}
// 258:           audit_urls(urls, tarball_gh_pattern) do
// 259:             problem "Use versioned rather than branch tarballs for stable checksums."
// 260:           end
// 261:         end
// 262:
// 263:         # Use new-style archive downloads.
// 264:         archive_gh_pattern = %r{https://.*github.*/(?:tar|zip)ball/}
// 265:         audit_urls(urls, archive_gh_pattern) do |_, url|
// 266:           next if url.end_with?(".git")
// 267:
// 268:           problem "Use /archive/ URLs for GitHub tarballs (`url` is #{url})."
// 269:         end
// 270:
// 271:         archive_refs_gh_pattern = %r{https://.*github.+/archive/(?![a-fA-F0-9]{40})(?!refs/(tags|heads)/)(.*)\.tar\.gz$}
// 272:         audit_urls(urls, archive_refs_gh_pattern) do |match, url|
// 273:           next if url.end_with?(".git")
// 274:
// 275:           problem %Q(Use "refs/tags/#{match[2]}" or "refs/heads/#{match[2]}" for GitHub references (`url` is #{url}).)
// 276:         end
// 277:
// 278:         # Don't use GitHub .zip files
// 279:         zip_gh_pattern = %r{https://.*github.*/(archive|releases)/.*\.zip$}
// 280:         audit_urls(urls, zip_gh_pattern) do |_, url|
// 281:           next if url.match? %r{raw.githubusercontent.com/.*/.*/(main|master|HEAD)/}
// 282:           next if url.include?("releases/download")
// 283:           next if url.include?("desktop.githubusercontent.com/releases/")
// 284:
// 285:           problem "Use GitHub tarballs rather than zipballs (`url` is #{url})."
// 286:         end
// 287:
// 288:         # Don't use GitHub codeload URLs
// 289:         codeload_gh_pattern = %r{https?://codeload\.github\.com/(.+)/(.+)/(?:tar\.gz|zip)/(.+)}
// 290:         audit_urls(urls, codeload_gh_pattern) do |match, url|
// 291:           problem <<~EOS
// 292:             Use GitHub archive URLs:
// 293:               https://github.com/#{match[1]}/#{match[2]}/archive/#{match[3]}.tar.gz
// 294:             Rather than codeload:
// 295:               #{url}
// 296:           EOS
// 297:         end
// 298:
// 299:         # Check for Maven Central URLs, prefer HTTPS redirector over specific host
// 300:         maven_pattern = %r{https?://(?:central|repo\d+)\.maven\.org/maven2/(.+)$}
// 301:         audit_urls(urls, maven_pattern) do |match, url|
// 302:           problem "#{url} should be: https://search.maven.org/remotecontent?filepath=#{match[1]}"
// 303:         end
// 304:       end
// 305:     end
// 306:   end
// 307: end
