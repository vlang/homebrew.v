module utils

import brew_runtime
import x.json2

// Translated from Homebrew/brew `utils/cpan.rb`.
// The original source is retained below until every stub has a typed V body.
pub const metacpan_url_prefix = 'https://cpan.metacpan.org/authors/id/'

pub struct CpanReleaseInfo {
pub:
	name         string
	download_url string
	checksum     string
	version      string
}

pub struct CpanInfoLookup {
pub:
	found bool
	info  CpanReleaseInfo
}

pub type CpanMetadataFetch = fn(string) !string

@[heap]
pub struct CpanPackage {
pub:
	resource_name string
	resource_url  string
	is_cpan_url   bool
mut:
	current_version_cache string
	info_cache            ?CpanReleaseInfo
	metadata_queried      bool
}

struct CpanMetadataDocument {
pub:
	download_url    ?string
	checksum_sha256 ?string
	version         ?string
}

pub fn new_cpan_package(resource_name string, resource_url string) &CpanPackage {
	return &CpanPackage{
		resource_name: resource_name
		resource_url: resource_url
		is_cpan_url: resource_url.starts_with(metacpan_url_prefix)
	}
}

pub fn (package &CpanPackage) name() string {
	return package.resource_name
}

fn cpan_archive_version(url string) ?string {
	filename := url.all_after_last('/')
	mut stem := ''
	if filename.ends_with('.tar.gz') {
		stem = filename[..filename.len - 7]
	} else if filename.ends_with('.tgz') {
		stem = filename[..filename.len - 4]
	} else {
		return none
	}
	separator := stem.last_index('-') or { return none }
	version := stem[separator + 1..]
	mut invalid := version.len == 0
	for character in version {
		if !(character.is_digit() || character in [`v`, `.`]) {
			invalid = true
			break
		}
	}
	if invalid {
		return none
	}
	return version
}

pub fn (mut package CpanPackage) current_version() ?string {
	if package.current_version_cache.len == 0 && package.is_cpan_url {
		package.current_version_cache = cpan_archive_version(package.resource_url) or { '' }
	}
	return if package.current_version_cache.len > 0 { package.current_version_cache } else { none }
}

pub fn (package &CpanPackage) valid() bool {
	return package.is_cpan_url
}

pub fn (mut package CpanPackage) latest_info(fetch CpanMetadataFetch) !CpanInfoLookup {
	if cached := package.info_cache {
		return CpanInfoLookup{
			found: true
			info: cached
		}
	}
	if package.metadata_queried || !package.valid() {
		return CpanInfoLookup{}
	}
	package.metadata_queried = true
	metadata_url := 'https://fastapi.metacpan.org/v1/download_url/${package.resource_name}'
	payload := fetch(metadata_url) or { return CpanInfoLookup{} }
	document := json2.decode[CpanMetadataDocument](payload) or { return CpanInfoLookup{} }
	download_url := document.download_url or { return CpanInfoLookup{} }
	checksum := document.checksum_sha256 or { return CpanInfoLookup{} }
	info := CpanReleaseInfo{
		name: package.resource_name
		download_url: download_url
		checksum: checksum
		version: document.version or { '' }
	}
	package.info_cache = info
	return CpanInfoLookup{
		found: true
		info: info
	}
}

pub struct CpanResource {
pub:
	name      string
	url       string
	livecheck bool
}

pub struct CpanFormula {
pub:
	name      string
	path      string
	source    string
	resources []CpanResource
}

pub struct CpanUpdateOptions {
pub:
	print_only    bool
	quiet         bool
	verbose       bool
	ignore_errors bool
}

pub struct CpanUpdateResult {
pub:
	resource_section string
	updated_source   string
	messages         []string
	errors           []string
	updated_count    int
	failed           bool
}

fn cpan_resource_block(info CpanReleaseInfo) string {
	return '  resource "${info.name}" do\n    url "${info.download_url}"\n    sha256 "${info.checksum}"\n  end\n\n'
}

fn cpan_replace_resource_stanzas(source string, replacement string) !string {
	// `String#split_into_lines` discards separators in V. Ruby's AST replacement
	// retains the complete formula layout, including its trailing newline, so use
	// explicit newline elements and join them with the same separator below.
	lines := source.split('\n')
	mut output := []string{cap: lines.len}
	mut first_resource_index := -1
	mut index := 0
	for index < lines.len {
		line := lines[index]
		if line.starts_with('  resource "') && line.trim_space().ends_with(' do') {
			if first_resource_index < 0 {
				first_resource_index = output.len
			}
			index++
			mut depth := 1
			for index < lines.len && depth > 0 {
				trimmed := lines[index].trim_space()
				if trimmed.ends_with(' do') {
					depth++
				}
				if trimmed == 'end' {
					depth--
				}
				index++
			}
			if index < lines.len && lines[index].trim_space() == '' {
				index++
			}
			continue
		}
		output << line
		index++
	}
	if first_resource_index < 0 {
		for i, line in output {
			if line.starts_with('  def install') {
				first_resource_index = i
				break
			}
		}
	}
	if first_resource_index < 0 {
		return error('multiple_groups')
	}
	// Resource sections end with a blank separator. Remove only the final newline
	// before splitting so insertion adds one blank line, not two, ahead of the
	// following formula stanza.
	replacement_body := if replacement.ends_with('\n') {
		replacement[..replacement.len - 1]
	} else {
		replacement
	}
	replacement_lines := replacement_body.split('\n')
	mut combined := []string{cap: output.len + replacement_lines.len}
	combined << output[..first_resource_index]
	combined << replacement_lines
	combined << output[first_resource_index..]
	return combined.join('\n')
}

pub fn update_perl_resources(formula CpanFormula, options CpanUpdateOptions,
	fetch CpanMetadataFetch) !CpanUpdateResult {
	cpan_resources := formula.resources.filter(it.url.starts_with(metacpan_url_prefix))
	if cpan_resources.len == 0 {
		return error('"${formula.name}" has no CPAN resources to update.')
	}
	non_cpan_names := formula.resources.filter(!it.url.starts_with(metacpan_url_prefix)).map(it.name).sorted()
	livecheck_names := cpan_resources.filter(it.livecheck).map(it.name).sorted()
	if !options.print_only && non_cpan_names.len > 0 {
		return error('"${formula.name}" contains non-CPAN resources: ${non_cpan_names.join(', ')}\nPlease update the resources manually.')
	}
	if !options.print_only && livecheck_names.len > 0 {
		return error('"${formula.name}" contains CPAN resources with livecheck blocks: ${livecheck_names.join(', ')}\nPlease update the resources manually.')
	}
	show_info := !options.print_only && !options.quiet
	mut messages := []string{}
	if show_info {
		messages << 'Found ${cpan_resources.len} CPAN resources to update'
	}
	mut resource_blocks := ''
	mut package_errors := ''
	mut updated_count := 0
	for resource in cpan_resources {
		mut package := new_cpan_package(resource.name, resource.url)
		if show_info {
			messages << 'Checking "${resource.name}" for updates...'
		}
		lookup := package.latest_info(fetch) or { CpanInfoLookup{} }
		if lookup.found {
			resolved := lookup.info
			current := package.current_version()
			if current_version := current {
				if resolved.version.len > 0 && current_version != resolved.version {
					if show_info {
						messages << '"${resource.name}": ${current_version} -> ${resolved.version}'
					}
					updated_count++
				} else if show_info {
					messages << '"${resource.name}": already up to date (${current_version})'
				}
			}
			resource_blocks += cpan_resource_block(resolved)
		} else if options.ignore_errors {
			package_errors += '  # RESOURCE-ERROR: Unable to resolve "${resource.name}"\n'
		} else {
			return error('Unable to resolve "${resource.name}"')
		}
	}
	if package_errors.len > 0 {
		package_errors += '\n'
	}
	section := package_errors + resource_blocks
	if options.print_only {
		return CpanUpdateResult{
			resource_section: section.trim_right('\n')
			updated_source: formula.source
			messages: messages
			updated_count: updated_count
		}
	}
	if !options.quiet {
		messages << 'Updating resource blocks'
	}
	updated_source := cpan_replace_resource_stanzas(formula.source, section) or {
		return error('Unable to update resource blocks for "${formula.name}" automatically. Please update them manually.')
	}
	mut errors := []string{}
	mut failed := false
	if package_errors.len > 0 {
		errors << 'Unable to resolve some dependencies. Please check ${formula.path} for RESOURCE-ERROR comments.'
		failed = true
	} else if updated_count > 0 && !options.quiet {
		messages << 'Updated ${updated_count} CPAN resource${if updated_count != 1 {
			's'
		} else {
			''
		}}'
	}
	return CpanUpdateResult{
		resource_section: section
		updated_source: updated_source
		messages: messages
		errors: errors
		updated_count: updated_count
		failed: failed
	}
}

fn cpan_package_value(package &CpanPackage) brew_runtime.Value {
	return brew_runtime.structured_value('CPAN::Package', package.resource_name, {
		'cpan_package_address': u64(voidptr(package)).str()
		'resource_name':        package.resource_name
		'resource_url':         package.resource_url
	})
}

fn cpan_package_from_value(value brew_runtime.Value) &CpanPackage {
	address := value.attribute('cpan_package_address') or { panic('invalid CPAN::Package receiver') }
	return unsafe { &CpanPackage(voidptr(address.u64())) }
}

fn cpan_boundary_fetch(_ string) !string {
	return error('MetaCPAN response was not supplied')
}

fn cpan_info_value(info CpanInfoLookup) brew_runtime.Value {
	if info.found {
		release := info.info
		return brew_runtime.string_array_value([release.name, release.download_url, release.checksum,
			release.version])
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

fn cpan_option_bool(values map[string]brew_runtime.Value, name string) bool {
	value := values[name] or { return false }
	return value.type_name == 'Bool' && value.bool_data
}

// Ruby method `initialize(resource_name, resource_url)` at line 17.
pub fn ruby_cpan_l17_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('CPAN::Package#initialize requires resource name and URL')
	}
	return cpan_package_value(new_cpan_package(args[args.len - 2].as_string(), args[args.len - 1].as_string()))
}

// Ruby method `name` at line 25.
pub fn ruby_cpan_l25_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(cpan_package_from_value(args[0]).name())
}

// Ruby method `current_version` at line 30.
pub fn ruby_cpan_l30_d3_current_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := cpan_package_from_value(args[0])
	if version := package.current_version() {
		return brew_runtime.string_value(version)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `valid_cpan_package?` at line 36.
pub fn ruby_cpan_l36_d4_valid_cpan_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cpan_package_from_value(args[0]).valid())
}

// Ruby method `latest_cpan_info` at line 42.
pub fn ruby_cpan_l42_d5_latest_cpan_info(args ...brew_runtime.Value) brew_runtime.Value {
	mut package := cpan_package_from_value(args[0])
	if args.len > 1 && args[1].type_name == 'String' {
		payload := args[1].as_string()
		return cpan_info_value(package.latest_info(fn [payload] (_ string) !string {
			return payload
		}) or { CpanInfoLookup{} })
	}
	return cpan_info_value(package.latest_info(cpan_boundary_fetch) or { CpanInfoLookup{} })
}

// Ruby method `to_s` at line 66.
pub fn ruby_cpan_l66_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_cpan_l25_d2_name(...args)
}

// Ruby method `extract_version_from_url` at line 73.
pub fn ruby_cpan_l73_d7_extract_version_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_cpan_l30_d3_current_version(...args)
}

// Ruby method `self.update_perl_resources!(formula, print_only: false, quiet: false, verbose: false, ignore_errors: false)` at line 93.
pub fn ruby_cpan_l93_d8_self_update_perl_resources(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('CPAN.update_perl_resources! requires a formula descriptor')
	}
	formula_value := args[0]
	resources := formula_value.array_data.map(CpanResource{
		name: it.attribute('name') or { it.as_string() }
		url: it.attribute('url') or { '' }
		livecheck: it.attribute('livecheck') or { 'false' } == 'true'
	})
	formula := CpanFormula{
		name: formula_value.attribute('name') or { formula_value.as_string() }
		path: formula_value.attribute('path') or { '' }
		source: formula_value.attribute('source') or { '' }
		resources: resources
	}
	option_values := if args.len > 1 { args[1].map_data } else { map[string]brew_runtime.Value{} }
	options := CpanUpdateOptions{
		print_only: cpan_option_bool(option_values, 'print_only')
		quiet: cpan_option_bool(option_values, 'quiet')
		verbose: cpan_option_bool(option_values, 'verbose')
		ignore_errors: cpan_option_bool(option_values, 'ignore_errors')
	}
	payload := if args.len > 2 { args[2].as_string() } else { '' }
	result := update_perl_resources(formula, options, fn [payload] (_ string) !string {
		if payload.len == 0 {
			return error('MetaCPAN response was not supplied')
		}
		return payload
	}) or { panic(err) }
	return brew_runtime.Value{
		type_name: 'CPAN::UpdateResult'
		repr: result.resource_section
		string_array_data: result.messages.clone()
		attributes: {
			'updated_source': result.updated_source
			'updated_count':  result.updated_count.str()
			'failed':         result.failed.str()
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Helper functions for updating CPAN resources.
// 7: module CPAN
// 8:   METACPAN_URL_PREFIX = "https://cpan.metacpan.org/authors/id/"
// 9:   CPAN_ARCHIVE_REGEX = /^(.+)-([0-9.v]+)\.(?:tar\.gz|tgz)$/
// 10:   private_constant :METACPAN_URL_PREFIX, :CPAN_ARCHIVE_REGEX
// 11:
// 12:   extend Utils::Output::Mixin
// 13:
// 14:   # Represents a Perl package from an existing resource.
// 15:   class Package
// 16:     sig { params(resource_name: String, resource_url: String).void }
// 17:     def initialize(resource_name, resource_url)
// 18:       @cpan_info = T.let(nil, T.nilable(T::Array[String]))
// 19:       @resource_name = resource_name
// 20:       @resource_url = resource_url
// 21:       @is_cpan_url = T.let(resource_url.start_with?(METACPAN_URL_PREFIX), T::Boolean)
// 22:     end
// 23:
// 24:     sig { returns(String) }
// 25:     def name
// 26:       @resource_name
// 27:     end
// 28:
// 29:     sig { returns(T.nilable(String)) }
// 30:     def current_version
// 31:       extract_version_from_url if @current_version.blank?
// 32:       @current_version
// 33:     end
// 34:
// 35:     sig { returns(T::Boolean) }
// 36:     def valid_cpan_package?
// 37:       @is_cpan_url
// 38:     end
// 39:
// 40:     # Get latest release information from MetaCPAN API.
// 41:     sig { returns(T.nilable(T::Array[String])) }
// 42:     def latest_cpan_info
// 43:       return @cpan_info if @cpan_info.present?
// 44:       return unless valid_cpan_package?
// 45:
// 46:       metadata_url = "https://fastapi.metacpan.org/v1/download_url/#{@resource_name}"
// 47:       result = Utils::Curl.curl_output(metadata_url, "--location", "--fail")
// 48:       return unless result.status.success?
// 49:
// 50:       begin
// 51:         json = JSON.parse(result.stdout)
// 52:       rescue JSON::ParserError
// 53:         return
// 54:       end
// 55:
// 56:       download_url = json["download_url"]
// 57:       return unless download_url
// 58:
// 59:       checksum = json["checksum_sha256"]
// 60:       return unless checksum
// 61:
// 62:       @cpan_info = [@resource_name, download_url, checksum, json["version"]]
// 63:     end
// 64:
// 65:     sig { returns(String) }
// 66:     def to_s
// 67:       @resource_name
// 68:     end
// 69:
// 70:     private
// 71:
// 72:     sig { returns(T.nilable(String)) }
// 73:     def extract_version_from_url
// 74:       return unless @is_cpan_url
// 75:
// 76:       match = File.basename(@resource_url).match(CPAN_ARCHIVE_REGEX)
// 77:       return unless match
// 78:
// 79:       @current_version = T.let(match[2], T.nilable(String))
// 80:     end
// 81:   end
// 82:
// 83:   # Update CPAN resources in a formula.
// 84:   sig {
// 85:     params(
// 86:       formula:       Formula,
// 87:       print_only:    T.nilable(T::Boolean),
// 88:       quiet:         T.nilable(T::Boolean),
// 89:       verbose:       T.nilable(T::Boolean),
// 90:       ignore_errors: T.nilable(T::Boolean),
// 91:     ).returns(T.nilable(T::Boolean))
// 92:   }
// 93:   def self.update_perl_resources!(formula, print_only: false, quiet: false, verbose: false, ignore_errors: false)
// 94:     cpan_resources = formula.resources.select { |resource| resource.url.start_with?(METACPAN_URL_PREFIX) }
// 95:
// 96:     odie "\"#{formula.name}\" has no CPAN resources to update." if cpan_resources.empty?
// 97:
// 98:     non_cpan_resource_names = formula.resources.filter_map do |resource|
// 99:       resource.name unless resource.url.start_with?(METACPAN_URL_PREFIX)
// 100:     end
// 101:     livecheck_resource_names = cpan_resources.filter_map do |resource|
// 102:       resource.name if resource.livecheck_defined?
// 103:     end
// 104:
// 105:     unless print_only
// 106:       odie <<~EOS unless non_cpan_resource_names.empty?
// 107:         "#{formula.name}" contains non-CPAN resources: #{non_cpan_resource_names.sort.join(", ")}
// 108:         Please update the resources manually.
// 109:       EOS
// 110:       odie <<~EOS unless livecheck_resource_names.empty?
// 111:         "#{formula.name}" contains CPAN resources with livecheck blocks: #{livecheck_resource_names.sort.join(", ")}
// 112:         Please update the resources manually.
// 113:       EOS
// 114:     end
// 115:
// 116:     show_info = !print_only && !quiet
// 117:
// 118:     ohai "Found #{cpan_resources.length} CPAN resources to update" if show_info
// 119:
// 120:     new_resource_blocks = ""
// 121:     package_errors = ""
// 122:     updated_count = 0
// 123:
// 124:     cpan_resources.each do |resource|
// 125:       package = Package.new(resource.name, resource.url)
// 126:
// 127:       unless package.valid_cpan_package?
// 128:         if ignore_errors
// 129:           package_errors += "  # RESOURCE-ERROR: \"#{resource.name}\" is not a valid CPAN resource\n"
// 130:           next
// 131:         else
// 132:           odie "\"#{resource.name}\" is not a valid CPAN resource"
// 133:         end
// 134:       end
// 135:
// 136:       ohai "Checking \"#{resource.name}\" for updates..." if show_info
// 137:
// 138:       info = package.latest_cpan_info
// 139:
// 140:       unless info
// 141:         if ignore_errors
// 142:           package_errors += "  # RESOURCE-ERROR: Unable to resolve \"#{resource.name}\"\n"
// 143:           next
// 144:         else
// 145:           odie "Unable to resolve \"#{resource.name}\""
// 146:         end
// 147:       end
// 148:
// 149:       name, url, checksum, new_version = info
// 150:       current_version = package.current_version
// 151:
// 152:       if current_version && new_version && current_version != new_version
// 153:         ohai "\"#{resource.name}\": #{current_version} -> #{new_version}" if show_info
// 154:         updated_count += 1
// 155:       elsif show_info
// 156:         ohai "\"#{resource.name}\": already up to date (#{current_version})" if current_version
// 157:       end
// 158:
// 159:       new_resource_blocks += <<-EOS
// 160:   resource "#{name}" do
// 161:     url "#{url}"
// 162:     sha256 "#{checksum}"
// 163:   end
// 164:
// 165:       EOS
// 166:     end
// 167:
// 168:     package_errors += "\n" if package_errors.present?
// 169:     resource_section = "#{package_errors}#{new_resource_blocks}"
// 170:
// 171:     if print_only
// 172:       puts resource_section.chomp
// 173:       return true
// 174:     end
// 175:
// 176:     ohai "Updating resource blocks" unless quiet
// 177:     require "utils/ast"
// 178:
// 179:     formula_ast = Utils::AST::FormulaAST.new(formula.path.read)
// 180:     if formula_ast.replace_resource_stanzas(
// 181:       resource_section,
// 182:       replace_existing: formula.resources.any? { |resource| !resource.name.start_with?("homebrew-") },
// 183:     ) == :multiple_groups
// 184:       odie "Unable to update resource blocks for \"#{formula.name}\" automatically. Please update them manually."
// 185:     end
// 186:     formula.path.atomic_write(formula_ast.process)
// 187:
// 188:     if package_errors.present?
// 189:       ofail "Unable to resolve some dependencies. Please check #{formula.path} for RESOURCE-ERROR comments."
// 190:     elsif updated_count.positive?
// 191:       ohai "Updated #{updated_count} CPAN resource#{"s" if updated_count != 1}" unless quiet
// 192:     end
// 193:
// 194:     true
// 195:   end
// 196: end
