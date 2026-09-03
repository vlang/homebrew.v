module utils

import brew_runtime
import x.json2

// Translated from Homebrew/brew `utils/pypi.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type PypiMetadataFetch = fn(string) !string

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
		key := '${name}\0${installation.metadata.version}'
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

fn pypi_package_value(package &PypiPackage) brew_runtime.Value {
	return brew_runtime.structured_value('PyPI::Package', package.package_string, {
		'pypi_package_address': u64(voidptr(package)).str()
		'package_string':       package.package_string
		'is_url':               package.is_url.str()
		'python_name':          package.python_name
	})
}

fn pypi_package_from_value(value brew_runtime.Value) &PypiPackage {
	address := value.attribute('pypi_package_address') or { panic('invalid PyPI::Package receiver') }
	return unsafe { &PypiPackage(voidptr(address.u64())) }
}

fn pypi_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn pypi_info_value(lookup PypiInfoLookup) brew_runtime.Value {
	if !lookup.found {
		return pypi_nil_value()
	}
	return brew_runtime.string_array_value([lookup.info.name, lookup.info.download_url,
		lookup.info.checksum, lookup.info.version, lookup.info.package_error])
}

fn pypi_boundary_fetch(_ string) !string {
	return error('PyPI response was not supplied')
}

// Ruby method `initialize(package_string, is_url: false, python_name: "python")` at line 24.
pub fn ruby_pypi_l24_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PyPI::Package#initialize requires a package string')
	}
	package_string := args[0].as_string()
	options := if args.len > 1 { args[1].map_data } else { map[string]brew_runtime.Value{} }
	is_url := options['is_url'] or { brew_runtime.bool_value(false) }
	python_name := options['python_name'] or { brew_runtime.string_value('python') }
	return pypi_package_value(new_pypi_package(package_string, is_url.bool_data, python_name.as_string()))
}

// Ruby method `name` at line 33.
pub fn ruby_pypi_l33_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	return brew_runtime.string_value(package.name() or { panic(err) })
}

// Ruby method `extras` at line 39.
pub fn ruby_pypi_l39_d3_extras(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	return brew_runtime.string_array_value(package.extras() or { panic(err) })
}

// Ruby method `version` at line 45.
pub fn ruby_pypi_l45_d4_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	version := package.version() or { panic(err) }
	if version.len > 0 {
		return brew_runtime.string_value(version)
	}
	return pypi_nil_value()
}

// Ruby method `version=(new_version)` at line 51.
pub fn ruby_pypi_l51_d5_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('PyPI::Package#version= requires a version')
	}
	mut package := pypi_package_from_value(args[0])
	package.set_version(args[1].as_string()) or { panic(err) }
	return args[1]
}

// Ruby method `valid_pypi_package?` at line 58.
pub fn ruby_pypi_l58_d6_valid_pypi_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(pypi_package_from_value(args[0]).valid())
}

// Ruby method `pypi_info(new_version: nil, ignore_errors: false)` at line 69.
pub fn ruby_pypi_l69_d7_pypi_info(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	options := if args.len > 1 { args[1].map_data } else { map[string]brew_runtime.Value{} }
	new_version := if value := options['new_version'] {
		if value.type_name == 'NilClass' { none } else { ?string(value.as_string()) }
	} else {
		none
	}
	ignore_errors := options['ignore_errors'] or { brew_runtime.bool_value(false) }.bool_data
	if args.len > 2 {
		payload := args[2].as_string()
		return pypi_info_value(package.pypi_info(new_version, ignore_errors, fn [payload] (_ string) !string {
			return payload
		}) or { PypiInfoLookup{} })
	}
	return pypi_info_value(package.pypi_info(new_version, ignore_errors, pypi_boundary_fetch) or {
		PypiInfoLookup{}
	})
}

// Ruby method `to_s` at line 114.
pub fn ruby_pypi_l114_d8_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	return brew_runtime.string_value(package.string() or { panic(err) })
}

// Ruby method `same_package?(other)` at line 128.
pub fn ruby_pypi_l128_d9_same_package(args ...brew_runtime.Value) brew_runtime.Value {
	mut left := pypi_package_from_value(args[0])
	mut right := pypi_package_from_value(args[1])
	return brew_runtime.bool_value(left.same_package(mut right) or { panic(err) })
}

// Ruby method `==(other)` at line 135.
pub fn ruby_pypi_l135_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[1].type_name != 'PyPI::Package' {
		return brew_runtime.bool_value(false)
	}
	return ruby_pypi_l128_d9_same_package(args[0], args[1])
}

// Ruby alias `alias eql? ==` at line 143.
pub fn ruby_pypi_l143_d11_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_pypi_l135_d10_anonymous(...args)
}

// Ruby method `hash` at line 146.
pub fn ruby_pypi_l146_d12_hash(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	return brew_runtime.int_value(package.hash_value() or { panic(err) })
}

// Ruby method `<=>(other)` at line 151.
pub fn ruby_pypi_l151_d13_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	mut left := pypi_package_from_value(args[0])
	mut right := pypi_package_from_value(args[1])
	left_name := left.name() or { panic(err) }
	right_name := right.name() or { panic(err) }
	return brew_runtime.int_value(if left_name < right_name {
		-1
	} else if left_name > right_name { 1 } else { 0 })
}

// Ruby method `basic_metadata` at line 159.
pub fn ruby_pypi_l159_d14_basic_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := pypi_package_from_value(args[0])
	package.resolve_basic_metadata() or { panic(err) }
	return brew_runtime.array_value([
		brew_runtime.string_value(package.name_cache),
		brew_runtime.string_array_value(package.extras_cache),
		if package.version_cache.len > 0 {
			brew_runtime.string_value(package.version_cache)
		} else {
			pypi_nil_value()
		},
	])
}

// Ruby method `self.update_pypi_url(url, version)` at line 216.
pub fn ruby_pypi_l216_d15_self_update_pypi_url(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return pypi_nil_value()
	}
	mut package := new_pypi_package(args[0].as_string(), true, 'python')
	payload := if args.len > 2 { args[2].as_string() } else { '' }
	lookup := package.pypi_info(args[1].as_string(), false, fn [payload] (_ string) !string {
		if payload.len == 0 {
			return error('PyPI response was not supplied')
		}
		return payload
	}) or { return pypi_nil_value() }
	return if lookup.found {
		brew_runtime.string_value(lookup.info.download_url)
	} else {
		pypi_nil_value()
	}
}

// Ruby method `self.update_python_resources!(formula, version: nil, package_name: nil, extra_packages: nil,` at line 245.
pub fn ruby_pypi_l245_d16_self_update_python_resources(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 {
		args[args.len - 1].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	package_name := options['package_name'] or { brew_runtime.string_value('') }
	version := options['version'] or { brew_runtime.string_value('') }
	extra := options['extra_packages'] or { brew_runtime.string_array_value([]string{}) }
	excluded := options['exclude_packages'] or { brew_runtime.string_array_value([]string{}) }
	python := options['python_name'] or { brew_runtime.string_value('python') }
	plan := plan_python_resources(package_name.as_string(), version.as_string(), extra.string_array_data, excluded.string_array_data, python.as_string()) or { panic(err) }
	return brew_runtime.Value{
		type_name: 'PyPI::UpdatePlan'
		repr: plan.pip_plan.command.join(' ')
		string_array_data: plan.pip_plan.requirements.clone()
		map_data: {
			'excluded_packages': brew_runtime.string_array_value(plan.excluded_packages)
			'extra_packages':    brew_runtime.string_array_value(plan.extra_packages)
		}
		attributes: {
			'main_package': plan.main_package
			'python_name':  plan.pip_plan.python_name
		}
	}
}

// Ruby method `self.resource_blocks_from_formula(contents)` at line 466.
pub fn ruby_pypi_l466_d17_self_resource_blocks_from_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.map_value(map[string]brew_runtime.Value{})
	}
	blocks := pypi_resource_blocks_from_formula(args[args.len - 1].as_string())
	mut values := map[string]brew_runtime.Value{}
	for name, block in blocks {
		values[name] = brew_runtime.string_value(block)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `self.normalize_python_package(name)` at line 486.
pub fn ruby_pypi_l486_d18_self_normalize_python_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(normalize_python_package(args[args.len - 1].as_string()))
}

// Ruby method `self.pip_report(packages, python_name: "python", print_stderr: false, ignore_cooldown_package: nil)` at line 498.
pub fn ruby_pypi_l498_d19_self_pip_report(args ...brew_runtime.Value) brew_runtime.Value {
	packages_value := if args.len > 0 {
		args[0]
	} else {
		brew_runtime.array_value([]brew_runtime.Value{})
	}
	mut packages := packages_value.array_data.map(pypi_package_from_value(it))
	options := if args.len > 1 { args[1].map_data } else { map[string]brew_runtime.Value{} }
	python := options['python_name'] or { brew_runtime.string_value('python') }
	print_stderr := options['print_stderr'] or { brew_runtime.bool_value(false) }
	plan := build_pip_report_plan(mut packages, python.as_string(), print_stderr.bool_data, none) or {
		panic(err)
	}
	return brew_runtime.Value{
		type_name: 'PyPI::PipReportPlan'
		repr: plan.command.join(' ')
		string_array_data: plan.requirements.clone()
	}
}

// Ruby method `self.pip_report_to_packages(report)` at line 542.
pub fn ruby_pypi_l542_d20_self_pip_report_to_packages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([]brew_runtime.Value{})
	}
	packages := pip_report_to_packages(args[args.len - 1].as_string()) or { panic(err) }
	return brew_runtime.array_value(packages.map(pypi_package_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "release_cooldown"
// 5: require "utils/output"
// 6: require "utils/ast"
// 7: require "utils/path"
// 8: require "time"
// 9:
// 10: # Helper functions for updating PyPI resources.
// 11: module PyPI
// 12:   extend Utils::Output::Mixin
// 13:
// 14:   PYTHONHOSTED_URL_PREFIX = "https://files.pythonhosted.org/packages/"
// 15:   private_constant :PYTHONHOSTED_URL_PREFIX
// 16:
// 17:   # Represents a Python package.
// 18:   # This package can be a PyPI package (either by name/version or PyPI distribution URL),
// 19:   # or it can be a non-PyPI URL.
// 20:   class Package
// 21:     include Utils::Output::Mixin
// 22:
// 23:     sig { params(package_string: String, is_url: T::Boolean, python_name: String).void }
// 24:     def initialize(package_string, is_url: false, python_name: "python")
// 25:       @pypi_info = T.let(nil, T.nilable(T::Array[String]))
// 26:       @package_string = package_string
// 27:       @is_url = is_url
// 28:       @is_pypi_url = T.let(package_string.start_with?(PYTHONHOSTED_URL_PREFIX), T::Boolean)
// 29:       @python_name = python_name
// 30:     end
// 31:
// 32:     sig { returns(T.nilable(String)) }
// 33:     def name
// 34:       basic_metadata if @name.blank?
// 35:       @name
// 36:     end
// 37:
// 38:     sig { returns(T.nilable(T::Array[String])) }
// 39:     def extras
// 40:       basic_metadata if @extras.blank?
// 41:       @extras
// 42:     end
// 43:
// 44:     sig { returns(T.nilable(String)) }
// 45:     def version
// 46:       basic_metadata if @version.blank?
// 47:       @version
// 48:     end
// 49:
// 50:     sig { params(new_version: String).void }
// 51:     def version=(new_version)
// 52:       raise ArgumentError, "can't update version for non-PyPI packages" unless valid_pypi_package?
// 53:
// 54:       @version = T.let(new_version, T.nilable(String))
// 55:     end
// 56:
// 57:     sig { returns(T::Boolean) }
// 58:     def valid_pypi_package?
// 59:       @is_pypi_url || !@is_url
// 60:     end
// 61:
// 62:     # Get name, URL, SHA-256 checksum and latest version for a given package.
// 63:     # This only works for packages from PyPI or from a PyPI URL; packages
// 64:     # derived from non-PyPI URLs will produce `nil` here.
// 65:     sig {
// 66:       params(new_version:   T.nilable(T.any(String, Version)),
// 67:              ignore_errors: T.nilable(T::Boolean)).returns(T.nilable(T::Array[String]))
// 68:     }
// 69:     def pypi_info(new_version: nil, ignore_errors: false)
// 70:       return unless valid_pypi_package?
// 71:       return @pypi_info if @pypi_info.present? && new_version.blank?
// 72:
// 73:       new_version ||= version
// 74:       metadata_url = if new_version.present?
// 75:         "https://pypi.org/pypi/#{name}/#{new_version}/json"
// 76:       else
// 77:         "https://pypi.org/pypi/#{name}/json"
// 78:       end
// 79:       result = Utils::Curl.curl_output(metadata_url, "--location", "--fail")
// 80:
// 81:       return unless result.status.success?
// 82:
// 83:       begin
// 84:         json = JSON.parse(result.stdout)
// 85:       rescue JSON::ParserError
// 86:         return
// 87:       end
// 88:
// 89:       dist = json["urls"].find do |url|
// 90:         url["packagetype"] == "sdist"
// 91:       end
// 92:
// 93:       # If there isn't an sdist, we use the first pure Python3 or universal wheel
// 94:       if dist.nil?
// 95:         dist = json["urls"].find do |url|
// 96:           url["filename"].match?("[.-]py3[^-]*-none-any.whl$")
// 97:         end
// 98:       end
// 99:
// 100:       if dist.nil?
// 101:         return ["", "", "", "", "no suitable source distribution on PyPI"] if ignore_errors
// 102:
// 103:         onoe "#{name} exists on PyPI but lacks a suitable source distribution"
// 104:         return
// 105:       end
// 106:
// 107:       @pypi_info = [
// 108:         PyPI.normalize_python_package(json["info"]["name"]), dist["url"],
// 109:         dist["digests"]["sha256"], json["info"]["version"]
// 110:       ]
// 111:     end
// 112:
// 113:     sig { returns(String) }
// 114:     def to_s
// 115:       if valid_pypi_package?
// 116:         out = T.must(name)
// 117:         if (pypi_extras = extras.presence)
// 118:           out += "[#{pypi_extras.join(",")}]"
// 119:         end
// 120:         out += "==#{version}" if version.present?
// 121:         out
// 122:       else
// 123:         @package_string
// 124:       end
// 125:     end
// 126:
// 127:     sig { params(other: Package).returns(T::Boolean) }
// 128:     def same_package?(other)
// 129:       # These names are pre-normalized, so we can compare them directly.
// 130:       name == other.name
// 131:     end
// 132:
// 133:     # Compare only names so we can use .include? and .uniq on a Package array
// 134:     sig { params(other: T.anything).returns(T::Boolean) }
// 135:     def ==(other)
// 136:       case other
// 137:       when Package
// 138:         same_package?(other)
// 139:       else
// 140:         false
// 141:       end
// 142:     end
// 143:     alias eql? ==
// 144:
// 145:     sig { returns(Integer) }
// 146:     def hash
// 147:       name.hash
// 148:     end
// 149:
// 150:     sig { params(other: Package).returns(T.nilable(Integer)) }
// 151:     def <=>(other)
// 152:       name <=> other.name
// 153:     end
// 154:
// 155:     private
// 156:
// 157:     # Returns [name, [extras], version] for this package.
// 158:     sig { returns(T.nilable(T.any(String, T::Array[String]))) }
// 159:     def basic_metadata
// 160:       if @is_pypi_url
// 161:         match = File.basename(@package_string).match(/^(.+)-([a-z\d.]+?)(?:.tar.gz|.zip)$/)
// 162:         raise ArgumentError, "Package should be a valid PyPI URL" if match.blank?
// 163:
// 164:         @name ||= T.let(PyPI.normalize_python_package(T.must(match[1])), T.nilable(String))
// 165:         @extras ||= T.let([], T.nilable(T::Array[String]))
// 166:         @version ||= T.let(match[2], T.nilable(String))
// 167:       elsif @is_url
// 168:         require "formula"
// 169:         Formula[@python_name].ensure_installed!
// 170:
// 171:         # The URL might be a source distribution hosted somewhere;
// 172:         # try and use `pip install -q --no-deps --dry-run --report ...` to get its
// 173:         # name and version.
// 174:         # Note that this is different from the (similar) `pip install --report` we
// 175:         # do below, in that it uses `--no-deps` because we only care about resolving
// 176:         # this specific URL's project metadata.
// 177:         command =
// 178:           [Utils::Path.formula_opt_libexec(@python_name)/"bin/python", "-m", "pip", "install", "-q", "--no-deps",
// 179:            "--dry-run", "--ignore-installed", "--report", "/dev/stdout", @package_string]
// 180:         pip_output = Utils.popen_read({ "PIP_REQUIRE_VIRTUALENV" => "false" }, *command)
// 181:         unless $CHILD_STATUS.success?
// 182:           raise ArgumentError, <<~EOS
// 183:             Unable to determine metadata for "#{@package_string}" because of a failure when running
// 184:             `#{command.join(" ")}`.
// 185:           EOS
// 186:         end
// 187:
// 188:         metadata = JSON.parse(pip_output)["install"].first["metadata"]
// 189:
// 190:         @name ||= T.let(PyPI.normalize_python_package(metadata["name"]), T.nilable(String))
// 191:         @extras ||= T.let([], T.nilable(T::Array[String]))
// 192:         @version ||= T.let(metadata["version"], T.nilable(String))
// 193:       else
// 194:         if @package_string.include? "=="
// 195:           name, version = @package_string.split("==")
// 196:         else
// 197:           name = @package_string
// 198:           version = nil
// 199:         end
// 200:
// 201:         if (match = T.must(name).match(/^(.*?)\[(.+)\]$/))
// 202:           name = match[1]
// 203:           extras = T.must(match[2]).split ","
// 204:         else
// 205:           extras = []
// 206:         end
// 207:
// 208:         @name ||= T.let(PyPI.normalize_python_package(T.must(name)), T.nilable(String))
// 209:         @extras ||= extras
// 210:         @version ||= version
// 211:       end
// 212:     end
// 213:   end
// 214:
// 215:   sig { params(url: String, version: T.any(String, Version)).returns(T.nilable(String)) }
// 216:   def self.update_pypi_url(url, version)
// 217:     package = Package.new url, is_url: true
// 218:
// 219:     return unless package.valid_pypi_package?
// 220:
// 221:     _, url = package.pypi_info(new_version: version)
// 222:     url
// 223:   rescue ArgumentError
// 224:     nil
// 225:   end
// 226:
// 227:   # Return true if resources were checked (even if no change).
// 228:   sig {
// 229:     params(
// 230:       formula:                      Formula,
// 231:       version:                      T.nilable(String),
// 232:       package_name:                 T.nilable(String),
// 233:       extra_packages:               T.nilable(T::Array[String]),
// 234:       exclude_packages:             T.nilable(T::Array[String]),
// 235:       dependencies:                 T.nilable(T::Array[String]),
// 236:       install_dependencies:         T.nilable(T::Boolean),
// 237:       print_only:                   T.nilable(T::Boolean),
// 238:       quiet:                        T.nilable(T::Boolean),
// 239:       verbose:                      T.nilable(T::Boolean),
// 240:       ignore_errors:                T.nilable(T::Boolean),
// 241:       ignore_non_pypi_packages:     T.nilable(T::Boolean),
// 242:       ignore_main_package_cooldown: T.nilable(T::Boolean),
// 243:     ).returns(T.nilable(T::Boolean))
// 244:   }
// 245:   def self.update_python_resources!(formula, version: nil, package_name: nil, extra_packages: nil,
// 246:                                     exclude_packages: nil, dependencies: nil, install_dependencies: false,
// 247:                                     print_only: false, quiet: false, verbose: false,
// 248:                                     ignore_errors: false, ignore_non_pypi_packages: false,
// 249:                                     ignore_main_package_cooldown: false)
// 250:     if [package_name, extra_packages, exclude_packages, dependencies].all?(&:blank?)
// 251:       list_entry = formula.pypi_packages_info
// 252:
// 253:       package_name = list_entry.package_name
// 254:       extra_packages = list_entry.extra_packages
// 255:       exclude_packages = list_entry.exclude_packages
// 256:       dependencies = list_entry.dependencies
// 257:     end
// 258:
// 259:     missing_dependencies = Array(dependencies).reject do |dependency|
// 260:       Formula[dependency].any_version_installed?
// 261:     rescue FormulaUnavailableError
// 262:       odie "Formula \"#{dependency}\" not found but it is a dependency to update \"#{formula.name}\" resources."
// 263:     end
// 264:     if missing_dependencies.present?
// 265:       missing_msg = "formulae required to update \"#{formula.name}\" resources: #{missing_dependencies.join(", ")}"
// 266:       odie "Missing #{missing_msg}" unless install_dependencies
// 267:       ohai "Installing #{missing_msg}"
// 268:       require "formula"
// 269:       missing_dependencies.each { |dep| Formula[dep].ensure_installed! }
// 270:     end
// 271:
// 272:     python_deps = formula.deps
// 273:                          .select { |d| d.name.match?(/^python(@.+)?$/) }
// 274:                          .map(&:to_formula)
// 275:                          .sort_by(&:version)
// 276:                          .reverse
// 277:     python_name = if python_deps.empty?
// 278:       "python"
// 279:     else
// 280:       (python_deps.find(&:any_version_installed?) || python_deps.first).name
// 281:     end
// 282:
// 283:     main_package = if package_name.present?
// 284:       package_string = package_name
// 285:       package_string += "==#{formula.version}" if version.blank? && formula.version.present?
// 286:       Package.new(package_string, python_name:)
// 287:     elsif package_name == ""
// 288:       nil
// 289:     else
// 290:       stable = T.must(formula.stable)
// 291:       url = if stable.specs[:tag].present?
// 292:         "git+#{stable.url}@#{stable.specs[:tag]}"
// 293:       else
// 294:         T.must(stable.url)
// 295:       end
// 296:       Package.new(url, is_url: true, python_name:)
// 297:     end
// 298:
// 299:     if main_package.nil?
// 300:       odie "The main package was skipped but no PyPI `extra_packages` were provided." if extra_packages.blank?
// 301:     elsif version.present?
// 302:       if main_package.valid_pypi_package?
// 303:         main_package.version = version
// 304:       else
// 305:         return if ignore_non_pypi_packages
// 306:
// 307:         odie "The main package is not a PyPI package, meaning that version-only updates cannot be \
// 308:           performed. Please update its URL manually."
// 309:       end
// 310:     end
// 311:
// 312:     extra_packages = (extra_packages || []).map { |p| Package.new p }
// 313:     exclude_packages = (exclude_packages || []).map { |p| Package.new p }
// 314:     exclude_packages += %w[argparse pip wsgiref].map { |p| Package.new p }
// 315:     if (newest_python = python_deps.first) && newest_python.version < Version.new("3.12")
// 316:       exclude_packages.append(Package.new("setuptools"))
// 317:     end
// 318:     # remove packages from the exclude list if we've explicitly requested them as an extra package
// 319:     exclude_packages.delete_if { |package| extra_packages.include?(package) }
// 320:
// 321:     input_packages = Array(main_package)
// 322:     extra_packages.each do |extra_package|
// 323:       if !extra_package.valid_pypi_package? && !ignore_non_pypi_packages
// 324:         odie "\"#{extra_package}\" is not available on PyPI."
// 325:       end
// 326:
// 327:       input_packages.each do |existing_package|
// 328:         if existing_package.same_package?(extra_package) && existing_package.version != extra_package.version
// 329:           odie "Conflicting versions specified for the `#{extra_package.name}` package: " \
// 330:                "#{existing_package.version}, #{extra_package.version}"
// 331:         end
// 332:       end
// 333:
// 334:       input_packages << extra_package unless input_packages.include? extra_package
// 335:     end
// 336:
// 337:     non_pypi_resource_names = formula.resources.filter_map do |resource|
// 338:       next if resource.url.start_with?(PYTHONHOSTED_URL_PREFIX)
// 339:       next if resource.livecheck_defined?
// 340:
// 341:       resource.name
// 342:     end.to_set
// 343:
// 344:     existing_resources_by_name = formula.resources.to_h { |resource| [resource.name, resource] }
// 345:     formula_contents = formula.path.read
// 346:     existing_resource_blocks = resource_blocks_from_formula(formula_contents)
// 347:
// 348:     require "formula"
// 349:     Formula[python_name].ensure_installed!
// 350:
// 351:     # Resolve the dependency tree of all input packages
// 352:     show_info = !print_only && !quiet
// 353:     ohai "Retrieving PyPI dependencies for \"#{input_packages.join(" ")}\"..." if show_info
// 354:
// 355:     print_stderr = verbose && show_info
// 356:     print_stderr ||= false
// 357:
// 358:     ignore_cooldown_package = main_package if ignore_main_package_cooldown
// 359:     found_packages = pip_report(input_packages, python_name:, print_stderr:,
// 360:                                 ignore_cooldown_package:)
// 361:     # Resolve the dependency tree of excluded packages to prune the above
// 362:     exclude_packages.delete_if { |package| found_packages.exclude? package }
// 363:     if exclude_packages.present?
// 364:       ohai "Retrieving PyPI dependencies for excluded \"#{exclude_packages.join(" ")}\"..." if show_info
// 365:       exclude_packages = pip_report(exclude_packages, python_name:, print_stderr:)
// 366:     end
// 367:     # Keep extra_packages even if they are dependencies of exclude_packages
// 368:     exclude_packages.delete_if { |package| extra_packages.include? package }
// 369:     if (main_package_name = main_package&.name)
// 370:       exclude_packages += [Package.new(main_package_name)]
// 371:     end
// 372:
// 373:     new_resource_blocks = ""
// 374:     package_errors = ""
// 375:     found_packages.sort.each do |package|
// 376:       if exclude_packages.include? package
// 377:         ohai "Excluding \"#{package}\"" if show_info
// 378:         exclude_packages.delete package
// 379:         next
// 380:       end
// 381:       next if existing_resources_by_name[T.must(package.name)]&.livecheck_defined?
// 382:
// 383:       ohai "Getting PyPI info for \"#{package}\"" if show_info
// 384:       name, url, checksum, version, package_error = package.pypi_info(ignore_errors: ignore_errors)
// 385:       if package_error.blank?
// 386:         # Fail if unable to find name, url or checksum for any resource
// 387:         if name.blank?
// 388:           if ignore_errors
// 389:             package_error = "unknown failure"
// 390:           else
// 391:             odie "Unable to resolve some dependencies. Please update the resources for \"#{formula.name}\" manually."
// 392:           end
// 393:         elsif url.blank? || checksum.blank?
// 394:           if ignore_errors
// 395:             package_error = "unable to find URL and/or sha256"
// 396:           else
// 397:             odie <<~EOS
// 398:               Unable to find the URL and/or sha256 for the "#{name}" resource.
// 399:               Please update the resources for "#{formula.name}" manually.
// 400:             EOS
// 401:           end
// 402:         else
// 403:           existing_is_non_pypi = !non_pypi_resource_names.delete?(name).nil?
// 404:
// 405:           if (existing_resource = existing_resources_by_name[name]) &&
// 406:              (existing_block = existing_resource_blocks[name]) &&
// 407:              ((existing_resource.url == url && existing_resource.checksum&.hexdigest == checksum) ||
// 408:               (existing_is_non_pypi && existing_resource.version.to_s == version))
// 409:             new_resource_blocks += <<-EOS
// 410:   #{existing_block.dup}
// 411:
// 412:             EOS
// 413:             next
// 414:           end
// 415:           # Append indented resource block
// 416:           new_resource_blocks += <<-EOS
// 417:   resource "#{name}" do
// 418:     url "#{url}"
// 419:     sha256 "#{checksum}"
// 420:   end
// 421:
// 422:           EOS
// 423:         end
// 424:       end
// 425:
// 426:       if package_error.present?
// 427:         # Leave a placeholder for formula author to investigate
// 428:         package_errors += "  # RESOURCE-ERROR: Unable to resolve \"#{package}\" (#{package_error})\n"
// 429:       end
// 430:     end
// 431:
// 432:     package_errors += "\n" if package_errors.present?
// 433:     resource_section = "#{package_errors}#{new_resource_blocks}"
// 434:
// 435:     odie "Excluded superfluous packages: #{exclude_packages.join(", ")}" if exclude_packages.any?
// 436:
// 437:     if print_only
// 438:       puts resource_section.chomp
// 439:       return
// 440:     end
// 441:
// 442:     odie <<~EOS unless non_pypi_resource_names.empty?
// 443:       "#{formula.name}" contains non-PyPI resources: #{non_pypi_resource_names.sort.join(", ")}
// 444:       Please update the resources manually.
// 445:     EOS
// 446:
// 447:     ohai "Updating resource blocks" unless quiet
// 448:     formula_ast = Utils::AST::FormulaAST.new(formula.path.read)
// 449:     if formula_ast.replace_resource_stanzas(
// 450:       resource_section,
// 451:       replace_existing:   formula.resources.any? { |resource| !resource.name.start_with?("homebrew-") },
// 452:       preserve_livecheck: true,
// 453:     ) == :multiple_groups
// 454:       odie "Unable to update resource blocks for \"#{formula.name}\" automatically. Please update them manually."
// 455:     end
// 456:     formula.path.atomic_write(formula_ast.process)
// 457:
// 458:     if package_errors.present?
// 459:       ofail "Unable to resolve some dependencies. Please check #{formula.path} for RESOURCE-ERROR comments."
// 460:     end
// 461:
// 462:     true
// 463:   end
// 464:
// 465:   sig { params(contents: String).returns(T::Hash[String, String]) }
// 466:   def self.resource_blocks_from_formula(contents)
// 467:     blocks = {}
// 468:     _processed_source, root_node = Utils::AST.process_source(contents)
// 469:     return blocks if root_node.nil?
// 470:
// 471:     root_node.each_node(:block) do |node|
// 472:       next unless Utils::AST.call_node_match?(node, name: :resource, type: :block_call)
// 473:
// 474:       send_node = node.send_node
// 475:       name_node = send_node.arguments.first
// 476:       next if name_node.blank? || !name_node.str_type?
// 477:
// 478:       resource_name = name_node.str_content
// 479:       blocks[resource_name] = node.location.expression.source
// 480:     end
// 481:
// 482:     blocks
// 483:   end
// 484:
// 485:   sig { params(name: String).returns(String) }
// 486:   def self.normalize_python_package(name)
// 487:     # This normalization is defined in the PyPA packaging specifications;
// 488:     # https://packaging.python.org/en/latest/specifications/name-normalization/#name-normalization
// 489:     name.gsub(/[-_.]+/, "-").downcase
// 490:   end
// 491:
// 492:   sig {
// 493:     params(
// 494:       packages: T::Array[Package], python_name: String, print_stderr: T::Boolean,
// 495:       ignore_cooldown_package: T.nilable(Package)
// 496:     ).returns(T::Array[Package])
// 497:   }
// 498:   def self.pip_report(packages, python_name: "python", print_stderr: false, ignore_cooldown_package: nil)
// 499:     return [] if packages.blank?
// 500:
// 501:     # Delay packages published in the last day so resource resolution is less
// 502:     # likely to pick a freshly compromised PyPI release. A cooldown-exempt main
// 503:     # package (third-party taps only) is passed by its direct sdist URL so pip's
// 504:     # index upload-time filter cannot hide a just-published release; its
// 505:     # dependencies stay index-resolved and cooled.
// 506:     requirements = packages.map do |package|
// 507:       exempt = ignore_cooldown_package && package == ignore_cooldown_package && package.valid_pypi_package?
// 508:       next package.to_s unless exempt
// 509:
// 510:       name, sdist_url = package.pypi_info
// 511:       next package.to_s if sdist_url.blank?
// 512:
// 513:       # PEP 508 direct reference. Any extras are preserved so their dependencies
// 514:       # still resolve, while the URL bypasses the index upload-time filter.
// 515:       extras = package.extras.presence
// 516:       next sdist_url unless extras
// 517:
// 518:       "#{name}[#{extras.join(",")}] @ #{sdist_url}"
// 519:     end
// 520:
// 521:     command = [
// 522:       Utils::Path.formula_opt_libexec(python_name)/"bin/python",
// 523:       "-m", "pip", "install", "-q", "--disable-pip-version-check",
// 524:       "--dry-run", "--ignore-installed",
// 525:       "--uploaded-prior-to=P#{Homebrew::RELEASE_COOLDOWN_DAYS}D",
// 526:       "--report=/dev/stdout", *requirements
// 527:     ]
// 528:     options = {}
// 529:     options[:err] = :err if print_stderr
// 530:     pip_output = Utils.popen_read({ "PIP_REQUIRE_VIRTUALENV" => "false" }, *command, **options)
// 531:     unless $CHILD_STATUS.success?
// 532:       odie <<~EOS
// 533:         Unable to determine dependencies for "#{packages.join(" ")}" because of a failure when running
// 534:         `#{command.join(" ")}`.
// 535:         Please update the resources manually.
// 536:       EOS
// 537:     end
// 538:     pip_report_to_packages(JSON.parse(pip_output)).uniq
// 539:   end
// 540:
// 541:   sig { params(report: T::Hash[String, T.untyped]).returns(T::Array[Package]) }
// 542:   def self.pip_report_to_packages(report)
// 543:     return [] if report.blank?
// 544:
// 545:     report["install"].filter_map do |package|
// 546:       name = normalize_python_package(package["metadata"]["name"])
// 547:       version = package["metadata"]["version"]
// 548:
// 549:       Package.new "#{name}==#{version}"
// 550:     end
// 551:   end
// 552: end
