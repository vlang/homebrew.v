module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/identify.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RegistryPackage {
pub:
	ecosystem string
	name      string
	version   string
	purl      string
}

fn identify_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn identify_optional_arg(value brew_runtime.Value) ?string {
	if value.type_name == 'NilClass' {
		return none
	}
	return value.as_string()
}

fn identify_unwrap_wayback(raw_url string) string {
	for scheme in ['https://web.archive.org/web/', 'http://web.archive.org/web/'] {
		if raw_url.starts_with(scheme) {
			remainder := raw_url[scheme.len..]
			if slash := remainder.index('/') {
				return remainder[slash + 1..]
			}
		}
	}
	return raw_url
}

pub fn identify_repo_url(urls []string) ?string {
	for raw_url in urls {
		if raw_url == '' {
			continue
		}
		url := identify_unwrap_wayback(raw_url)
		mut remainder := if url.starts_with('https://') {
			url[8..]
		} else if url.starts_with('http://') {
			url[7..]
		} else {
			continue
		}
		host_end := remainder.index('/') or { continue }
		host := remainder[..host_end]
		mut path := remainder[host_end + 1..]
		if host in ['github.com', 'codeberg.org'] {
			parts := path.split('/')
			if parts.len < 2 || parts[0] == '' || parts[1] == '' {
				continue
			}
			mut repo_path := '${parts[0]}/${parts[1]}'.trim_string_right('.git')
			if host == 'github.com' {
				repo_path = repo_path.to_lower()
			}
			return 'https://${host}/${repo_path}'
		}
		if host !in ['gitlab.com', 'gitlab.gnome.org', 'gitlab.freedesktop.org', 'invent.kde.org'] {
			continue
		}
		if path.starts_with('-/') || path.starts_with('api/') {
			continue
		}
		for boundary in ['/-/', '/uploads/', '/wikis/'] {
			if index := path.index(boundary) {
				path = path[..index]
				break
			}
		}
		path = path.trim_string_right('/').trim_string_right('.git')
		parts := path.split('/')
		if parts.len < 2 || parts.any(it == '') {
			continue
		}
		return 'https://${host}/${path}'
	}
	return none
}

// Ruby method `self.repo_url(*urls)` at line 58.
pub fn ruby_identify_l58_d1_self_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	mut urls := []string{cap: args.len}
	for arg in args {
		urls << identify_optional_arg(arg) or { '' }
	}
	return if repo := identify_repo_url(urls) {
		brew_runtime.string_value(repo)
	} else {
		identify_nil()
	}
}

// Ruby method `self.tag(url)` at line 76.
pub fn ruby_identify_l76_d2_self_tag(args ...brew_runtime.Value) brew_runtime.Value {
	url := if args.len > 0 { identify_optional_arg(args[0]) } else { none }
	return if release_tag := identify_tag(url) {
		brew_runtime.string_value(release_tag)
	} else {
		identify_nil()
	}
}

// Ruby method `self.registry_package(url)` at line 118.
pub fn ruby_identify_l118_d3_self_registry_package(args ...brew_runtime.Value) brew_runtime.Value {
	url := if args.len > 0 { identify_optional_arg(args[0]) } else { none }
	package := identify_registry_package(url) or { return identify_nil() }
	return identify_registry_package_value(package)
}

// Ruby method `self.registry_purl(url)` at line 136.
pub fn ruby_identify_l136_d4_self_registry_purl(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return identify_nil()
	}
	ecosystem, package_url := identify_registry_purl(args[0].as_string()) or { return identify_nil() }
	return brew_runtime.array_value([
		brew_runtime.string_value(ecosystem),
		purl_value(package_url),
	])
}

// Ruby method `self.decode(component)` at line 200.
pub fn ruby_identify_l200_d5_self_decode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(identify_decode(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.version_after_prefix(basename, name)` at line 208.
pub fn ruby_identify_l208_d6_self_version_after_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return identify_nil()
	}
	return if version := identify_version_after_prefix(args[0].as_string(), args[1].as_string()) {
		brew_runtime.string_value(version)
	} else {
		identify_nil()
	}
}

// Ruby method `self.gem_name_version(basename)` at line 219.
pub fn ruby_identify_l219_d7_self_gem_name_version(args ...brew_runtime.Value) brew_runtime.Value {
	name, version := identify_gem_name_version(if args.len > 0 { args[0].as_string() } else { '' })
	return brew_runtime.array_value([
		if value := name { brew_runtime.string_value(value) } else { identify_nil() },
		if value := version { brew_runtime.string_value(value) } else { identify_nil() },
	])
}

fn identify_between(url string, prefix string, suffixes []string) ?string {
	start := url.index(prefix) or { return none }
	remainder := url[start + prefix.len..]
	mut end := remainder.len
	for suffix in suffixes {
		if index := remainder.index(suffix) {
			if index < end {
				end = index
			}
		}
	}
	if end == 0 {
		return none
	}
	return remainder[..end]
}

pub fn identify_tag(url ?string) ?string {
	raw_url := url or { return none }
	for prefix, suffixes in {
		'/archive/refs/tags/': ['.tar.gz', '.zip']
		'/archive/':           ['.tar.gz', '.zip']
		'/releases/download/': ['/']
		'/tarball/':           []string{}
	} {
		if value := identify_between(raw_url, prefix, suffixes) {
			if prefix == '/tarball/' && raw_url != '${raw_url[..raw_url.len - value.len]}${value}' {
				continue
			}
			return value
		}
	}
	return none
}

fn identify_hex_value(character u8) ?u8 {
	if character >= `0` && character <= `9` {
		return u8(character - `0`)
	}
	if character >= `A` && character <= `F` {
		return u8(character - `A` + 10)
	}
	if character >= `a` && character <= `f` {
		return u8(character - `a` + 10)
	}
	return none
}

pub fn identify_decode(component string) string {
	if !component.contains('%') {
		return component
	}
	mut bytes := []u8{cap: component.len}
	mut index := 0
	for index < component.len {
		if component[index] == `%` && index + 2 < component.len {
			if high := identify_hex_value(component[index + 1]) {
				if low := identify_hex_value(component[index + 2]) {
					bytes << (high << 4 | low)
					index += 3
					continue
				}
			}
		}
		bytes << component[index]
		index++
	}
	return bytes.bytestr()
}

fn identify_basename(url string) string {
	path := if question := url.index('?') { url[..question] } else { url }
	return path.trim_string_right('/').all_after_last('/')
}

fn identify_strip_archive_extension(filename string) string {
	lower := filename.to_lower()
	for extension in ['.tar.gz', '.tar.bz2', '.tar.xz', '.nupkg', '.tgz', '.zip', '.gem', '.crate',
		'.tar'] {
		if lower.ends_with(extension) {
			return filename[..filename.len - extension.len]
		}
	}
	return filename
}

pub fn identify_version_after_prefix(basename string, name string) ?string {
	prefix := '${name}-'
	if !basename.starts_with(prefix) || basename.len == prefix.len {
		return none
	}
	return basename[prefix.len..]
}

fn identify_version_chars(version string, allow_v bool) bool {
	if version == '' {
		return false
	}
	mut start := 0
	if allow_v && version[0] == `v` {
		start = 1
	}
	if start >= version.len || version[start] < `0` || version[start] > `9` {
		return false
	}
	return version[start..].bytes().all((it >= `0` && it <= `9`) || it in [`.`, `_`])
}

fn identify_name_numeric_version(value string, allow_v bool) ?(string, string) {
	mut index := value.len
	for index > 0 {
		prefix := value[..index]
		hyphen := prefix.last_index('-') or { return none }
		version := value[hyphen + 1..]
		if identify_version_chars(version, allow_v) && hyphen > 0 {
			return value[..hyphen], version
		}
		index = hyphen
	}
	return none
}

fn identify_gem_deplatform(basename string) string {
	parts := basename.split('-')
	if parts.len < 2 {
		return basename
	}
	if parts.last() in ['java', 'jruby', 'truffleruby', 'dalvik', 'dotnet'] || parts.last().starts_with('mswin') {
		return parts[..parts.len - 1].join('-')
	}
	operating_systems := ['aix', 'cygwin', 'darwin', 'freebsd', 'linux', 'macruby', 'mingw', 'mswin',
		'netbsd', 'openbsd', 'bitrig', 'solaris', 'wasi']
	for index in 1 .. parts.len {
		if operating_systems.any(parts[index].starts_with(it)) && index >= 1 {
			cpu := parts[index - 1]
			if cpu != '' && cpu.bytes().all((it >= `A` && it <= `Z`) || (it >= `a` && it <= `z`) || (it >= `0` && it <= `9`) || it == `_`) {
				return parts[..index - 1].join('-')
			}
		}
	}
	return basename
}

pub fn identify_gem_name_version(basename string) (?string, ?string) {
	deplatformed := identify_gem_deplatform(basename)
	hyphen := deplatformed.last_index('-') or { return none, none }
	if hyphen == 0 || hyphen + 1 >= deplatformed.len {
		return none, none
	}
	version := deplatformed[hyphen + 1..]
	if version[0] < `0` || version[0] > `9` || !version.bytes().all((it >= `0` && it <= `9`) || (it >= `A` && it <= `Z`) || (it >= `a` && it <= `z`) || it in [
		`.`,
		`_`,
	]) {
		return none, none
	}
	return deplatformed[..hyphen], version
}

fn identify_new_purl(package_type string, namespace ?string, name string,
	version string) ?PackageUrl {
	return new_package_url(PackageUrlConfig{
		package_type: package_type
		name: name
		namespace: namespace
		version: version
	}) or { none }
}

fn identify_registry_pair(ecosystem string, package_type string, namespace ?string,
	name string, version string) ?(string, PackageUrl) {
	purl := identify_new_purl(package_type, namespace, name, version) or { return none }
	return ecosystem, purl
}

fn identify_pypi(url string, basename string) ?(string, PackageUrl) {
	prefix := 'https://files.pythonhosted.org/packages/'
	if !url.starts_with(prefix) || url.to_lower().ends_with('.whl') {
		return none
	}
	parts := url[prefix.len..].split('/')
	if parts.len < 4 {
		return none
	}
	hyphen := basename.last_index('-') or { return none }
	if hyphen == 0 || hyphen + 1 >= basename.len {
		return none
	}
	return identify_registry_pair('PyPI', 'pypi', none, basename[..hyphen], basename[hyphen + 1..])
}

fn identify_npm(url string, basename string) ?(string, PackageUrl) {
	prefix := 'https://registry.npmjs.org/'
	if !url.starts_with(prefix) {
		return none
	}
	path := url[prefix.len..]
	marker := path.index('/-/') or { return none }
	package_path := path[..marker]
	parts := package_path.split('/')
	mut namespace := ?string(none)
	mut name := ''
	if parts.len == 2 && (parts[0].starts_with('@') || parts[0].to_lower().starts_with('%40')) {
		namespace = '@${identify_decode(parts[0]).trim_string_left('@')}'
		name = identify_decode(parts[1])
	} else if parts.len == 1 && parts[0] != '' {
		name = identify_decode(parts[0])
	} else {
		return none
	}
	version := identify_version_after_prefix(basename, name) or { return none }
	return identify_registry_pair('npm', 'npm', namespace, name, version)
}

fn identify_crate(url string, basename string) ?(string, PackageUrl) {
	prefix := 'https://static.crates.io/crates/'
	if !url.starts_with(prefix) {
		return none
	}
	name := identify_decode(url[prefix.len..].all_before('/'))
	version := identify_version_after_prefix(basename, name) or { return none }
	return identify_registry_pair('crates.io', 'cargo', none, name, version)
}

fn identify_rubygem(url string, basename string) ?(string, PackageUrl) {
	if !url.starts_with('https://rubygems.org/downloads/') && !url.starts_with('https://rubygems.org/gems/') {
		return none
	}
	name, version := identify_gem_name_version(basename)
	return identify_registry_pair('RubyGems', 'gem', none, name or { return none }, version or { return none })
}

fn identify_hackage(url string) ?(string, PackageUrl) {
	prefix := 'https://hackage.haskell.org/package/'
	if !url.starts_with(prefix) {
		return none
	}
	pkgid := url[prefix.len..].all_before('/')
	name, version := identify_name_numeric_version(pkgid, false) or { return none }
	return identify_registry_pair('Hackage', 'hackage', none, name, version)
}

fn identify_hex(url string, basename string) ?(string, PackageUrl) {
	if !url.starts_with('https://repo.hex.pm/tarballs/') {
		return none
	}
	hyphen := basename.index('-') or { return none }
	if hyphen == 0 || hyphen + 1 >= basename.len {
		return none
	}
	return identify_registry_pair('Hex', 'hex', none, basename[..hyphen], basename[hyphen + 1..])
}

fn identify_cpan(url string, basename string) ?(string, PackageUrl) {
	marker := '/authors/id/'
	start := url.index(marker) or { return none }
	parts := url[start + marker.len..].split('/')
	if parts.len < 4 || parts[2] == '' || parts[2].bytes().any(!((it >= `A` && it <= `Z`) || (it >= `0` && it <= `9`) || it == `-`)) {
		return none
	}
	author := parts[2]
	trimmed := if basename.ends_with('-TRIAL') {
		basename.trim_string_right('-TRIAL')
	} else {
		mut trial := basename
		if index := trial.last_index('-TRIAL') {
			suffix := trial[index + 6..]
			if suffix.bytes().all(it >= `0` && it <= `9`) {
				trial = trial[..index]
			}
		}
		trial
	}
	name, version := identify_name_numeric_version(trimmed, true) or { return none }
	return identify_registry_pair('CPAN', 'cpan', author, name, version)
}

fn identify_maven(url string) ?(string, PackageUrl) {
	mut path := ''
	if url.starts_with('https://repo.maven.apache.org/maven2/') {
		path = url['https://repo.maven.apache.org/maven2/'.len..]
	} else if url.starts_with('https://repo1.maven.org/maven2/') {
		path = url['https://repo1.maven.org/maven2/'.len..]
	} else if url.starts_with('https://search.maven.org/remotecontent?filepath=') {
		path = url['https://search.maven.org/remotecontent?filepath='.len..]
	} else {
		return none
	}
	parts := path.split('/')
	if parts.len < 4 {
		return none
	}
	artifact := parts[parts.len - 3]
	version := parts[parts.len - 2]
	filename := parts.last()
	prefix := '${artifact}-${version}'
	if !filename.starts_with(prefix) || filename.len <= prefix.len || filename[prefix.len] !in [
		`.`,
		`-`,
	] {
		return none
	}
	group := parts[..parts.len - 3].join('.')
	if group == '' {
		return none
	}
	return identify_registry_pair('Maven', 'maven', group, artifact, version)
}

fn identify_cran(url string) ?(string, PackageUrl) {
	mut remainder := ''
	for prefix in ['https://cran.r-project.org/src/contrib/',
		'https://cloud.r-project.org/src/contrib/'] {
		if url.starts_with(prefix) {
			remainder = url[prefix.len..]
			break
		}
	}
	if remainder == '' || !remainder.ends_with('.tar.gz') {
		return none
	}
	if remainder.starts_with('Archive/') {
		archive_parts := remainder.split('/')
		if archive_parts.len != 3 {
			return none
		}
		remainder = archive_parts[2]
	}
	base := remainder.trim_string_right('.tar.gz')
	underscore := base.last_index('_') or { return none }
	if underscore == 0 || underscore + 1 >= base.len {
		return none
	}
	return identify_registry_pair('CRAN', 'cran', none, base[..underscore], base[underscore + 1..])
}

fn identify_nuget(url string) ?(string, PackageUrl) {
	mut remainder := ''
	if url.starts_with('https://api.nuget.org/v3-flatcontainer/') {
		remainder = url['https://api.nuget.org/v3-flatcontainer/'.len..]
	} else if url.starts_with('https://www.nuget.org/api/v2/package/') {
		remainder = url['https://www.nuget.org/api/v2/package/'.len..]
	} else {
		return none
	}
	parts := remainder.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	return identify_registry_pair('NuGet', 'nuget', none, parts[0], parts[1])
}

pub fn identify_registry_purl(url string) ?(string, PackageUrl) {
	basename := identify_strip_archive_extension(identify_decode(identify_basename(url)))
	if ecosystem, purl := identify_pypi(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_npm(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_crate(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_rubygem(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_hackage(url) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_hex(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_cpan(url, basename) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_maven(url) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_cran(url) {
		return ecosystem, purl
	}
	if ecosystem, purl := identify_nuget(url) {
		return ecosystem, purl
	}
	return none
}

pub fn identify_registry_package(url ?string) ?RegistryPackage {
	raw_url := url or { return none }
	ecosystem, purl := identify_registry_purl(raw_url) or { return none }
	name := match purl.package_type() {
		'maven' { '${purl.namespace() or { '' }}:${purl.name()}' }
		'pypi' { purl.name().replace('_', '-').replace('.', '-').to_lower() }
		'cpan' { purl.name() }
		else {
			if namespace := purl.namespace() { '${namespace}/${purl.name()}' } else { purl.name() }
		}
	}
	return RegistryPackage{
		ecosystem: ecosystem
		name: name
		version: purl.version() or { '' }
		purl: purl.str()
	}
}

pub fn identify_registry_package_value(package RegistryPackage) brew_runtime.Value {
	return brew_runtime.map_value({
		'ecosystem': brew_runtime.string_value(package.ecosystem)
		'name':      brew_runtime.string_value(package.name)
		'version':   brew_runtime.string_value(package.version)
		'purl':      brew_runtime.string_value(package.purl)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/purl"
// 5:
// 6: module Homebrew
// 7:   module Vulns
// 8:     # Derives OSV.dev query keys (forge repo URL, release tag) from formula
// 9:     # source URLs. Shared between {Scanner} and the advisory-matching pipeline.
// 10:     module Identify
// 11:       TWO_SEGMENT_PATH = %r{/([^/]+/[^/]+)}
// 12:       private_constant :TWO_SEGMENT_PATH
// 13:
// 14:       # GitLab supports nested subgroups (e.g. `xorg/lib/libx11`); the path is
// 15:       # bounded by `.git`, the `/-/` route marker, the legacy `/uploads/` and
// 16:       # `/wikis/` routes, or the end of the URL. Host-level `/-/` and `/api/`
// 17:       # routes are rejected via the leading negative lookahead.
// 18:       GITLAB_PATH = %r{/(?!-|api/)([^/]+(?:/[^/]+)+?)(?:\.git)?(?=/-/|/uploads/|/wikis/|/?\z)}
// 19:       private_constant :GITLAB_PATH
// 20:
// 21:       FORGES = T.let(
// 22:         {
// 23:           "github.com"             => TWO_SEGMENT_PATH,
// 24:           "codeberg.org"           => TWO_SEGMENT_PATH,
// 25:           "gitlab.com"             => GITLAB_PATH,
// 26:           "gitlab.gnome.org"       => GITLAB_PATH,
// 27:           "gitlab.freedesktop.org" => GITLAB_PATH,
// 28:           "invent.kde.org"         => GITLAB_PATH,
// 29:         }.freeze,
// 30:         T::Hash[String, Regexp],
// 31:       )
// 32:       private_constant :FORGES
// 33:
// 34:       TAG_PATTERNS = T.let(
// 35:         [
// 36:           %r{/archive/refs/tags/([^/]+)\.tar\.gz$},
// 37:           %r{/archive/refs/tags/([^/]+)\.zip$},
// 38:           %r{/archive/([^/]+)\.tar\.gz$},
// 39:           %r{/archive/([^/]+)\.zip$},
// 40:           %r{/releases/download/([^/]+)/},
// 41:           %r{/tarball/([^/]+)$},
// 42:         ].freeze,
// 43:         T::Array[Regexp],
// 44:       )
// 45:       private_constant :TAG_PATTERNS
// 46:
// 47:       WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d+[a-z_*]*/}
// 48:       private_constant :WAYBACK_PREFIX
// 49:
// 50:       # OSV.dev's GIT ecosystem indexes repository URLs case-sensitively but
// 51:       # normalises `github.com` paths to lowercase (GitHub itself is
// 52:       # case-insensitive). GitLab and Codeberg are case-sensitive so their
// 53:       # paths are preserved.
// 54:       LOWERCASE_PATH_HOSTS = ["github.com"].freeze
// 55:       private_constant :LOWERCASE_PATH_HOSTS
// 56:
// 57:       sig { params(urls: T.nilable(String)).returns(T.nilable(String)) }
// 58:       def self.repo_url(*urls)
// 59:         urls.each do |url|
// 60:           next if url.nil?
// 61:
// 62:           url = url.sub(WAYBACK_PREFIX, "")
// 63:           FORGES.each do |host, path_pattern|
// 64:             match = url.match(%r{\Ahttps?://#{Regexp.escape(host)}#{path_pattern}})
// 65:             next if match.nil?
// 66:
// 67:             repo_path = T.must(match[1]).sub(/\.git$/, "")
// 68:             repo_path = repo_path.downcase if LOWERCASE_PATH_HOSTS.include?(host)
// 69:             return "https://#{host}/#{repo_path}"
// 70:           end
// 71:         end
// 72:         nil
// 73:       end
// 74:
// 75:       sig { params(url: T.nilable(String)).returns(T.nilable(String)) }
// 76:       def self.tag(url)
// 77:         return if url.nil?
// 78:
// 79:         TAG_PATTERNS.each do |pattern|
// 80:           match = url.match(pattern)
// 81:           return match[1] if match
// 82:         end
// 83:         nil
// 84:       end
// 85:
// 86:       # `ecosystem` is the OSV.dev ecosystem identifier for `name`, or `"CPAN"`
// 87:       # for CPAN distributions (queried via CPANSA, not OSV).
// 88:       RegistryPackage = Struct.new(:ecosystem, :name, :version, :purl, keyword_init: true)
// 89:
// 90:       ARCHIVE_EXTENSIONS = /\.(?:tar\.gz|tar\.bz2|tar\.xz|tgz|zip|gem|crate|tar|nupkg)\z/i
// 91:       private_constant :ARCHIVE_EXTENSIONS
// 92:
// 93:       # Cabal package versions are dot-separated non-negative integers only.
// 94:       HACKAGE_PKGID = /\A(.+)-(\d+(?:\.\d+)*)\z/
// 95:       private_constant :HACKAGE_PKGID
// 96:
// 97:       # Simplified from CPAN::DistnameInfo: greedy name, version is digits/
// 98:       # dots/underscores optionally `v`-prefixed. A -TRIAL suffix is stripped.
// 99:       # Does not handle the rare `_`-separated form (e.g. `libao-perl_0.03-1`);
// 100:       # no homebrew-core formula currently uses it.
// 101:       CPAN_DISTNAME = /\A(.+)-(v?\d[\d._]*)(?:-TRIAL\d*)?\z/
// 102:       private_constant :CPAN_DISTNAME
// 103:
// 104:       # Recognise a `Gem::Platform` suffix by its OS token; the CPU token is
// 105:       # open-ended (riscv64, s390x, ppc64le, ...) so is matched generically.
// 106:       GEM_PLATFORM_SUFFIX = /
// 107:         -(?:
// 108:           java|jruby|truffleruby|dalvik|dotnet|mswin\d+(?:_\d+)?|
// 109:           \w+-
// 110:           (?:aix|cygwin|darwin|freebsd|linux|macruby|mingw\w*|mswin\d*|
// 111:              netbsd\w*|openbsd|bitrig|solaris|wasi)
// 112:           (?:[-_][\w.]+)?
// 113:         )\z
// 114:       /x
// 115:       private_constant :GEM_PLATFORM_SUFFIX
// 116:
// 117:       sig { params(url: T.nilable(String)).returns(T.nilable(RegistryPackage)) }
// 118:       def self.registry_package(url)
// 119:         return if url.nil?
// 120:
// 121:         ecosystem, purl = registry_purl(url)
// 122:         return if purl.nil?
// 123:
// 124:         name = case purl.type
// 125:         when "maven" then "#{purl.namespace}:#{purl.name}"
// 126:         # OSV keys PyPI packages by their PEP 503 normalised name.
// 127:         when "pypi" then purl.name.gsub(/[-_.]+/, "-")
// 128:         # CPANSA is keyed on the distribution name alone, without the author.
// 129:         when "cpan" then purl.name
// 130:         else purl.namespace ? "#{purl.namespace}/#{purl.name}" : purl.name
// 131:         end
// 132:         RegistryPackage.new(ecosystem:, name:, version: purl.version, purl: purl.to_s).freeze
// 133:       end
// 134:
// 135:       sig { params(url: String).returns(T.nilable([String, Purl])) }
// 136:       def self.registry_purl(url)
// 137:         basename = decode(File.basename(url)).sub(ARCHIVE_EXTENSIONS, "")
// 138:
// 139:         case url
// 140:         when %r{\Ahttps://files\.pythonhosted\.org/packages/(?:[^/]+/){3}(?![^/]+\.whl\z)}
// 141:           # PEP 440 canonical versions contain no hyphen, so the last one delimits.
// 142:           name, _, version = basename.rpartition("-")
// 143:           return if name.empty?
// 144:
// 145:           ["PyPI", Purl.new(type: "pypi", name:, version:)]
// 146:         when %r{\Ahttps://registry\.npmjs\.org/(?:((?:@|%40)[^/]+)/)?([^/@%][^/]*)/-/}
// 147:           namespace = Regexp.last_match(1)
// 148:           name = T.must(Regexp.last_match(2))
// 149:           namespace &&= "@#{decode(namespace).delete_prefix("@")}"
// 150:           name = decode(name)
// 151:           return unless (version = version_after_prefix(basename, name))
// 152:
// 153:           ["npm", Purl.new(type: "npm", namespace:, name:, version:)]
// 154:         when %r{\Ahttps://static\.crates\.io/crates/([^/]+)/}
// 155:           name = decode(T.must(Regexp.last_match(1)))
// 156:           return unless (version = version_after_prefix(basename, name))
// 157:
// 158:           ["crates.io", Purl.new(type: "cargo", name:, version:)]
// 159:         when %r{\Ahttps://rubygems\.org/(?:downloads|gems)/}
// 160:           name, version = gem_name_version(basename)
// 161:           return if name.nil?
// 162:
// 163:           ["RubyGems", Purl.new(type: "gem", name:, version:)]
// 164:         when %r{\Ahttps://hackage\.haskell\.org/package/([^/]+)}
// 165:           match = T.must(Regexp.last_match(1)).match(HACKAGE_PKGID)
// 166:           return if match.nil?
// 167:
// 168:           ["Hackage", Purl.new(type: "hackage", name: T.must(match[1]), version: match[2])]
// 169:         when %r{\Ahttps://repo\.hex\.pm/tarballs/}
// 170:           # Hex package names are `[a-z][a-z0-9_]*` so the first hyphen delimits.
// 171:           name, sep, version = basename.partition("-")
// 172:           return if sep.empty?
// 173:
// 174:           ["Hex", Purl.new(type: "hex", name:, version:)]
// 175:         when %r{/authors/id/[A-Z]/[A-Z]{2}/([A-Z][A-Z0-9-]+)/}
// 176:           author = T.must(Regexp.last_match(1))
// 177:           match = basename.match(CPAN_DISTNAME)
// 178:           return if match.nil?
// 179:
// 180:           ["CPAN", Purl.new(type: "cpan", namespace: author, name: T.must(match[1]), version: match[2])]
// 181:         # Maven Central only: OSV's bare `Maven` ecosystem is Central-scoped,
// 182:         # so third-party repositories (Google, fabricmc, jfrog, ...) are skipped.
// 183:         when %r{\Ahttps://repo1?\.maven\.(?:apache\.)?org/maven2/(.+)/([^/]+)/([^/]+)/\2-\3[.-][^/]+\z},
// 184:              %r{\Ahttps://search\.maven\.org/remotecontent\?filepath=(.+)/([^/]+)/([^/]+)/\2-\3[.-][^/]+\z}
// 185:           group_id = T.must(Regexp.last_match(1)).tr("/", ".")
// 186:           artifact_id = T.must(Regexp.last_match(2))
// 187:           version = Regexp.last_match(3)
// 188:           ["Maven", Purl.new(type: "maven", namespace: group_id, name: artifact_id, version:)]
// 189:         when %r{\Ahttps://(?:cran|cloud)\.r-project\.org/src/contrib/(?:Archive/[^/]+/)?([^/_]+)_([^/]+)\.tar\.gz\z}
// 190:           ["CRAN", Purl.new(type: "cran", name: T.must(Regexp.last_match(1)), version: Regexp.last_match(2))]
// 191:         when %r{\Ahttps://(?:api|www)\.nuget\.org/(?:v3-flatcontainer|api/v2/package)/([^/]+)/([^/]+)(?:/|\z)}
// 192:           ["NuGet", Purl.new(type: "nuget", name: T.must(Regexp.last_match(1)), version: Regexp.last_match(2))]
// 193:         end
// 194:       end
// 195:
// 196:       # Percent-decode a URL path segment. Unlike `decode_www_form_component`
// 197:       # this leaves `+` alone and unlike `decode_uri_component` (missing from
// 198:       # Sorbet's stdlib RBI) it never raises on malformed input.
// 199:       sig { params(component: String).returns(String) }
// 200:       def self.decode(component)
// 201:         return component unless component.include?("%")
// 202:
// 203:         component.b.gsub(/%[0-9A-Fa-f]{2}/) { |m| Integer(m[1, 2], 16).chr }
// 204:                  .force_encoding(component.encoding)
// 205:       end
// 206:
// 207:       sig { params(basename: String, name: String).returns(T.nilable(String)) }
// 208:       def self.version_after_prefix(basename, name)
// 209:         prefix = "#{name}-"
// 210:         return unless basename.start_with?(prefix)
// 211:
// 212:         version = basename[prefix.length..]
// 213:         version.presence
// 214:       end
// 215:
// 216:       # Split a `.gem` basename into name and version, discarding any trailing
// 217:       # {Gem::Platform} suffix (e.g. `nokogiri-1.16.0-arm64-darwin-22`).
// 218:       sig { params(basename: String).returns([T.nilable(String), T.nilable(String)]) }
// 219:       def self.gem_name_version(basename)
// 220:         deplatformed = basename.sub(GEM_PLATFORM_SUFFIX, "")
// 221:         name, sep, version = deplatformed.rpartition("-")
// 222:         return [nil, nil] if sep.empty? || !version.match?(/\A\d[\w.]*\z/)
// 223:
// 224:         [name, version]
// 225:       end
// 226:     end
// 227:   end
// 228: end
