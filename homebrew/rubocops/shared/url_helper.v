module shared

import ruby
import regex

// Translated from Homebrew/brew `rubocops/shared/url_helper.rb`.

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

fn url_node_from_value(value ruby.Value) UrlAuditNode {
	content := value.attributes['content'] or { value.as_string() }
	source := value.attributes['source'] or { value.as_string() }
	begin_pos := (value.attributes['begin_pos'] or { '0' }).int()
	end_pos := (value.attributes['end_pos'] or { (begin_pos + source.len).str() }).int()
	argument_begin := (value.attributes['argument_begin'] or { begin_pos.str() }).int()
	argument_end := (value.attributes['argument_end'] or { (argument_begin + content.len).str() }).int()
	return UrlAuditNode{source, content, begin_pos, end_pos, argument_begin, argument_end}
}

fn url_nodes_from_value(value ruby.Value) []UrlAuditNode {
	items := value.as_array() or { return [] }
	return items.map(url_node_from_value(it))
}

fn url_match_value(item UrlAuditMatch) ruby.Value {
	return ruby.structured_value('MatchData', item.matched, {
		'url':       item.url
		'content':   item.content
		'index':     item.index.str()
		'begin_pos': item.begin_pos.str()
		'end_pos':   item.end_pos.str()
		'matched':   item.matched
	})
}

pub fn url_problem_value(problem UrlProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
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
