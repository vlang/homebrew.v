module utils

import ruby
import x.json2

// Translated from Homebrew/brew `utils/pypi.rb`.
pub const pythonhosted_url_prefix = 'https://files.pythonhosted.org/packages/'

pub struct PypiReleaseInfo {
pub:
	name          string
	download_url  string
	checksum      string
	version       string
	package_error string
}

pub struct PypiInfoLookup {
pub:
	found bool
	info  PypiReleaseInfo
}

pub type PypiMetadataFetch = fn (string) !string

@[heap]
pub struct PypiPackage {
pub:
	package_string string
	is_url         bool
	is_pypi_url    bool
	python_name    string
mut:
	name_cache       string
	extras_cache     []string
	version_cache    string
	metadata_ready   bool
	info_cache       ?PypiReleaseInfo
	external_name    string
	external_version string
}

struct PypiDigestDocument {
pub:
	sha256 string
}

struct PypiDistributionDocument {
pub:
	packagetype string
	filename    string
	url         string
	digests     PypiDigestDocument
}

struct PypiProjectDocument {
pub:
	name    string
	version string
}

struct PypiMetadataDocument {
pub:
	info PypiProjectDocument
	urls []PypiDistributionDocument
}

struct PipInstallMetadataDocument {
pub:
	metadata PypiProjectDocument
}

struct PipReportDocument {
pub:
	install []PipInstallMetadataDocument
}

pub fn normalize_python_package(name string) string {
	mut output := []u8{cap: name.len}
	mut separator := false
	for character in name.to_lower().bytes() {
		if character in [`-`, `_`, `.`] {
			if !separator {
				output << `-`
				separator = true
			}
		} else {
			output << character
			separator = false
		}
	}
	return output.bytestr()
}

pub fn new_pypi_package(package_string string, is_url bool,
	python_name string) &PypiPackage {
	return &PypiPackage{
		package_string: package_string
		is_url: is_url
		is_pypi_url: package_string.starts_with(pythonhosted_url_prefix)
		python_name: if python_name.len > 0 { python_name } else { 'python' }
	}
}

pub fn (mut package PypiPackage) set_external_metadata(name string, version string) {
	package.external_name = name
	package.external_version = version
	package.metadata_ready = false
}

fn pypi_url_metadata(package_string string) !(string, string) {
	filename := package_string.all_after_last('/')
	stem := if filename.ends_with('.tar.gz') {
		filename[..filename.len - 7]
	} else if filename.ends_with('.zip') {
		filename[..filename.len - 4]
	} else {
		return error('Package should be a valid PyPI URL')
	}
	separator := stem.last_index('-') or { return error('Package should be a valid PyPI URL') }
	name := stem[..separator]
	version := stem[separator + 1..]
	if name.len == 0 || version.len == 0 {
		return error('Package should be a valid PyPI URL')
	}
	for character in version {
		if !(character.is_letter() || character.is_digit() || character == `.`) {
			return error('Package should be a valid PyPI URL')
		}
	}
	return normalize_python_package(name), version
}

pub fn (mut package PypiPackage) resolve_basic_metadata() ! {
	if package.metadata_ready {
		return
	}
	if package.is_pypi_url {
		name, version := pypi_url_metadata(package.package_string)!
		package.name_cache = name
		package.version_cache = version
		package.extras_cache = []string{}
	} else if package.is_url {
		if package.external_name.len == 0 {
			return error('Unable to determine metadata for "${package.package_string}" because pip metadata was not supplied.')
		}
		package.name_cache = normalize_python_package(package.external_name)
		package.version_cache = package.external_version
		package.extras_cache = []string{}
	} else {
		mut specification := package.package_string
		mut version := ''
		if specification.contains('==') {
			parts := specification.split_nth('==', 2)
			specification = parts[0]
			version = parts[1]
		}
		mut extras := []string{}
		if open := specification.index('[') {
			if specification.ends_with(']') {
				extras = specification[open + 1..specification.len - 1].split(',').filter(it.len > 0)
				specification = specification[..open]
			}
		}
		package.name_cache = normalize_python_package(specification)
		package.version_cache = version
		package.extras_cache = extras
	}
	package.metadata_ready = true
}

pub fn (mut package PypiPackage) name() !string {
	package.resolve_basic_metadata()!
	return package.name_cache
}

pub fn (mut package PypiPackage) extras() ![]string {
	package.resolve_basic_metadata()!
	return package.extras_cache.clone()
}

pub fn (mut package PypiPackage) version() !string {
	package.resolve_basic_metadata()!
	return package.version_cache
}

pub fn (mut package PypiPackage) set_version(version string) ! {
	if !package.valid() {
		return error("can't update version for non-PyPI packages")
	}
	package.resolve_basic_metadata()!
	package.version_cache = version
}

pub fn (package &PypiPackage) valid() bool {
	return package.is_pypi_url || !package.is_url
}

fn pypi_wheel_suitable(filename string) bool {
	return filename.ends_with('-none-any.whl') && (filename.contains('-py3') || filename.contains('.py3'))
}

pub fn (mut package PypiPackage) pypi_info(new_version ?string, ignore_errors bool,
	fetch PypiMetadataFetch) !PypiInfoLookup {
	if !package.valid() {
		return PypiInfoLookup{}
	}
	if cached := package.info_cache {
		if new_version == none {
			return PypiInfoLookup{
				found: true
				info: cached
			}
		}
	}
	name := package.name()!
	requested_version := if supplied := new_version {
		supplied
	} else {
		package.version() or { '' }
	}
	metadata_url := if requested_version.len > 0 {
		'https://pypi.org/pypi/${name}/${requested_version}/json'
	} else {
		'https://pypi.org/pypi/${name}/json'
	}
	payload := fetch(metadata_url) or { return PypiInfoLookup{} }
	document := json2.decode[PypiMetadataDocument](payload) or { return PypiInfoLookup{} }
	mut selected := ?PypiDistributionDocument(none)
	for distribution in document.urls {
		if distribution.packagetype == 'sdist' {
			selected = distribution
			break
		}
	}
	if selected == none {
		for distribution in document.urls {
			if pypi_wheel_suitable(distribution.filename) {
				selected = distribution
				break
			}
		}
	}
	if distribution := selected {
		info := PypiReleaseInfo{
			name: normalize_python_package(document.info.name)
			download_url: distribution.url
			checksum: distribution.digests.sha256
			version: document.info.version
		}
		package.info_cache = info
		return PypiInfoLookup{
			found: true
			info: info
		}
	}
	if ignore_errors {
		return PypiInfoLookup{
			found: true
			info: PypiReleaseInfo{
				package_error: 'no suitable source distribution on PyPI'
			}
		}
	}
	return PypiInfoLookup{}
}

pub fn (mut package PypiPackage) string() !string {
	if !package.valid() {
		return package.package_string
	}
	mut output := package.name()!
	extras := package.extras()!
	if extras.len > 0 {
		output += '[${extras.join(',')}]'
	}
	version := package.version()!
	if version.len > 0 {
		output += '==${version}'
	}
	return output
}

pub fn (mut package PypiPackage) same_package(mut other PypiPackage) !bool {
	return package.name()! == other.name()!
}

pub fn (mut package PypiPackage) hash_value() !i64 {
	mut hash := u64(14695981039346656037)
	for character in package.name()!.bytes() {
		hash = (hash ^ u64(character)) * u64(1099511628211)
	}
	return i64(hash)
}

pub fn pypi_resource_blocks_from_formula(contents string) map[string]string {
	lines := contents.split_into_lines()
	mut blocks := map[string]string{}
	mut index := 0
	for index < lines.len {
		line := lines[index]
		trimmed := line.trim_space()
		if trimmed.starts_with('resource "') && trimmed.ends_with(' do') {
			name := trimmed.all_after('resource "').all_before('"')
			mut block := [line]
			index++
			mut depth := 1
			for index < lines.len && depth > 0 {
				current := lines[index]
				text := current.trim_space()
				if text.ends_with(' do') {
					depth++
				}
				if text == 'end' {
					depth--
				}
				block << current
				index++
			}
			blocks[name] = block.join('').trim_space()
			continue
		}
		index++
	}
	return blocks
}

pub fn pip_report_to_packages(report string) ![]&PypiPackage {
	if report.trim_space().len == 0 {
		return []&PypiPackage{}
	}
	document := json2.decode[PipReportDocument](report)!
	mut packages := []&PypiPackage{}
	mut seen := []string{}
	for installation in document.install {
		name := normalize_python_package(installation.metadata.name)
		key := '${name}\x00${installation.metadata.version}'
		if key in seen {
			continue
		}
		seen << key
		packages << new_pypi_package('${name}==${installation.metadata.version}', false, 'python')
	}
	return packages
}

pub struct PipReportPlan {
pub:
	python_name  string
	requirements []string
	command      []string
	print_stderr bool
}

pub fn build_pip_report_plan(mut packages []&PypiPackage, python_name string,
	print_stderr bool, ignore_cooldown_package ?&PypiPackage) !PipReportPlan {
	mut requirements := []string{cap: packages.len}
	for mut package in packages {
		mut requirement := package.string()!
		if exempt := ignore_cooldown_package {
			if package == exempt && package.valid() {
				if cached := package.info_cache {
					extras := package.extras()!
					requirement = if extras.len > 0 {
						'${cached.name}[${extras.join(',')}] @ ${cached.download_url}'
					} else {
						cached.download_url
					}
				}
			}
		}
		requirements << requirement
	}
	python := if python_name.len > 0 { python_name } else { 'python' }
	mut command := ['/opt/homebrew/opt/${python}/libexec/bin/python', '-m', 'pip', 'install', '-q',
		'--disable-pip-version-check', '--dry-run', '--ignore-installed', '--uploaded-prior-to=P1D',
		'--report=/dev/stdout']
	command << requirements
	return PipReportPlan{
		python_name: python
		requirements: requirements
		command: command
		print_stderr: print_stderr
	}
}

pub struct PythonResourcesPlan {
pub:
	main_package      string
	extra_packages    []string
	excluded_packages []string
	pip_plan          PipReportPlan
}

pub fn plan_python_resources(package_name string, version string, extra_packages []string,
	exclude_packages []string, python_name string) !PythonResourcesPlan {
	mut inputs := []&PypiPackage{}
	if package_name.len > 0 {
		main_spec := if version.len > 0 {
			'${package_name}==${version}'
		} else {
			package_name
		}
		inputs << new_pypi_package(main_spec, false, python_name)
	}
	for specification in extra_packages {
		mut candidate := new_pypi_package(specification, false, python_name)
		mut duplicate := false
		for mut existing in inputs {
			if existing.same_package(mut candidate)! {
				existing_version := existing.version() or { '' }
				candidate_version := candidate.version() or { '' }
				if existing_version != candidate_version {
					return error('Conflicting versions specified for the `${candidate.name()!}` package: ${existing_version}, ${candidate_version}')
				}
				duplicate = true
			}
		}
		if !duplicate {
			inputs << candidate
		}
	}
	plan := build_pip_report_plan(mut inputs, python_name, false, none)!
	mut excluded := exclude_packages.clone()
	excluded << ['argparse', 'pip', 'wsgiref']
	return PythonResourcesPlan{
		main_package: if inputs.len > 0 { inputs[0].string()! } else { '' }
		extra_packages: extra_packages.clone()
		excluded_packages: excluded
		pip_plan: plan
	}
}

fn pypi_package_value(package &PypiPackage) ruby.Value {
	return ruby.structured_value('PyPI::Package', package.package_string, {
		'pypi_package_address': u64(voidptr(package)).str()
		'package_string':       package.package_string
		'is_url':               package.is_url.str()
		'python_name':          package.python_name
	})
}

fn pypi_package_from_value(value ruby.Value) &PypiPackage {
	address := value.attribute('pypi_package_address') or { panic('invalid PyPI::Package receiver') }
	return unsafe { &PypiPackage(voidptr(address.u64())) }
}

fn pypi_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn pypi_info_value(lookup PypiInfoLookup) ruby.Value {
	if !lookup.found {
		return pypi_nil_value()
	}
	return ruby.string_array_value([lookup.info.name, lookup.info.download_url, lookup.info.checksum,
		lookup.info.version, lookup.info.package_error])
}

fn pypi_boundary_fetch(_ string) !string {
	return error('PyPI response was not supplied')
}
