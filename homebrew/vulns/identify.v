module vulns

import ruby

// Translated from Homebrew/brew `vulns/identify.rb`.
pub struct RegistryPackage {
pub:
	ecosystem string
	name      string
	version   string
	purl      string
}

fn identify_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn identify_optional_arg(value ruby.Value) ?string {
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

pub fn identify_registry_package_value(package RegistryPackage) ruby.Value {
	return ruby.map_value({
		'ecosystem': ruby.string_value(package.ecosystem)
		'name':      ruby.string_value(package.name)
		'version':   ruby.string_value(package.version)
		'purl':      ruby.string_value(package.purl)
	})
}
