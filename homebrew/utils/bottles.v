module utils

import ruby
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `utils/bottles.rb`.
const bottles_all_archs = ['x86_64', 'i386', 'ppc64le', 'ppc64', 'ppc970', 'ppc7450', 'ppc7400',
	'ppc32', 'ppc', 'arm64', 'aarch64']

const bottles_macos_versions = {
	'golden_gate': '27'
	'tahoe':       '26'
	'sequoia':     '15'
	'sonoma':      '14'
	'ventura':     '13'
	'monterey':    '12'
	'big_sur':     '11'
	'catalina':    '10.15'
}

// BottlesTag is the source `Utils::Bottles::Tag` with Ruby symbols represented
// by their spelling. It is local to this module so the leaf utilities do not
// create an import cycle with the root Homebrew module.
pub struct BottlesTag {
pub:
	system string
	arch   string
}

// BottlesTagSpecification translates the checksum/cellar tuple stored for a tag.
pub struct BottlesTagSpecification {
pub:
	tag      BottlesTag
	checksum string
	cellar   string
}

// BottlesCollector translates Ruby's Tag-keyed Hash. V maps use the canonical
// tag symbol as the key, while order retains Ruby Hash insertion order.
pub struct BottlesCollector {
pub mut:
	tag_specs map[string]BottlesTagSpecification
	order     []string
}

pub struct BottlesFormulaState {
pub:
	latest_version_installed bool
	built_as_bottle          bool
	has_bottle               bool
	bottle_tag               string
	bottle_rebuild           int
}

pub struct BottlesPathResolution {
pub:
	path              string
	resolved_basename string
	github_packages   bool
}

pub struct BottlesRuntimeDependency {
pub:
	full_name string
	version   string
}

pub struct BottlesTab {
pub:
	built_os             string
	runtime_dependencies []BottlesRuntimeDependency
}

pub struct BottlesLoadTabInput {
pub:
	tab_attributes_json  string
	tabfile              string
	bottle_json_path     string
	local_bottle_path    string
	full_name            string
	existing_tab_json    string
	runtime_dependencies []BottlesRuntimeDependency
	current_system       string
}

pub fn new_bottles_tag(system string, arch string) BottlesTag {
	return BottlesTag{
		system: system
		arch: arch
	}
}

// bottles_tag_from_symbol translates Tag.from_symbol and its ALL_ARCHS regexp.
pub fn bottles_tag_from_symbol(value string) !BottlesTag {
	if value == 'all' {
		return new_bottles_tag('all', 'all')
	}
	if value == '' {
		return error('Invalid bottle tag symbol')
	}
	for character in value {
		if !(character.is_alnum() || character in [`_`, `.`]) {
			return error('Invalid bottle tag symbol')
		}
	}
	for arch in bottles_all_archs {
		prefix := '${arch}_'
		if value.starts_with(prefix) && value.len > prefix.len {
			return new_bottles_tag(value[prefix.len..], arch)
		}
	}
	return new_bottles_tag(value, 'x86_64')
}

pub fn bottles_tag_from_arg(argument ?string, system string, arch string) !BottlesTag {
	if value := argument {
		return bottles_tag_from_symbol(value)
	}
	return new_bottles_tag(system, arch)
}

pub fn current_bottles_tag() BottlesTag {
	information := ruby.kernel_info()
	mut system := information.name.to_lower()
	if system == 'darwin' {
		system = match information.release.all_before('.').int() {
			26 { 'golden_gate' }
			25 { 'tahoe' }
			24 { 'sequoia' }
			23 { 'sonoma' }
			22 { 'ventura' }
			21 { 'monterey' }
			20 { 'big_sur' }
			19 { 'catalina' }
			else { information.release.all_before('.') }
		}
	}
	configured_system := ruby.environment_value('HOMEBREW_BOTTLE_SYSTEM')
	if configured_system != '' {
		system = configured_system.to_lower()
	}
	mut arch := 'x86_64'
	$if arm64 {
		arch = 'arm64'
	} $else $if aarch64 {
		arch = 'arm64'
	}
	configured_arch := ruby.environment_value('HOMEBREW_PROCESSOR')
	if configured_arch != '' {
		arch = configured_arch.to_lower()
	}
	return new_bottles_tag(system, arch)
}

pub fn (tag BottlesTag) standardized_arch() string {
	if tag.arch in ['x86_64', 'intel'] {
		return 'x86_64'
	}
	if tag.arch in ['arm64', 'arm', 'aarch64'] {
		return 'arm64'
	}
	return tag.arch
}

pub fn (tag BottlesTag) macos() bool {
	return tag.system in bottles_macos_versions
}

pub fn (tag BottlesTag) linux() bool {
	return tag.system == 'linux'
}

fn bottles_arch_symbol(tag BottlesTag, arch string) string {
	if tag.system == 'all' && arch == 'all' {
		return 'all'
	}
	if tag.macos() && tag.standardized_arch() == 'x86_64' {
		return tag.system
	}
	return '${arch}_${tag.system}'
}

pub fn (tag BottlesTag) symbol() string {
	return bottles_arch_symbol(tag, tag.standardized_arch())
}

pub fn (tag BottlesTag) str() string {
	return tag.symbol()
}

pub fn (tag BottlesTag) unstandardized_symbol() string {
	// Never allow these generic names.
	if tag.arch in ['intel', 'arm'] {
		return tag.symbol()
	}
	// Backwards compatibility with older bottle names.
	return bottles_arch_symbol(tag, tag.arch)
}

pub fn (tag BottlesTag) equals(other BottlesTag) bool {
	return tag.system == other.system && tag.standardized_arch() == other.standardized_arch()
}

pub fn (tag BottlesTag) macos_version() !string {
	return bottles_macos_versions[tag.system] or {
		return error('unknown or unsupported macOS version: ${tag.system}')
	}
}

fn bottles_macos_rank(system string) int {
	return match system {
		'catalina' { 1015 }
		'big_sur' { 1100 }
		'monterey' { 1200 }
		'ventura' { 1300 }
		'sonoma' { 1400 }
		'sequoia' { 1500 }
		'tahoe' { 2600 }
		'golden_gate' { 2700 }
		else { 0 }
	}
}

pub fn (tag BottlesTag) valid_combination() bool {
	if tag.arch !in ['arm64', 'arm', 'aarch64'] || !tag.macos() {
		return true
	}
	// Big Sur is the first version of macOS that runs on ARM.
	return bottles_macos_rank(tag.system) >= bottles_macos_rank('big_sur')
}

pub fn (tag BottlesTag) default_prefix() string {
	if tag.linux() {
		return '/home/linuxbrew/.linuxbrew'
	}
	if tag.standardized_arch() == 'arm64' {
		return '/opt/homebrew'
	}
	return '/usr/local'
}

pub fn (tag BottlesTag) default_cellar() string {
	return '${tag.default_prefix()}/Cellar'
}

pub fn bottles_built_as(formula BottlesFormulaState) bool {
	return formula.latest_version_installed && formula.built_as_bottle
}

// bottles_extname_tag_rebuild translates HOMEBREW_BOTTLES_EXTNAME_REGEX's
// three MatchData entries: the complete suffix, tag, and optional rebuild.
pub fn bottles_extname_tag_rebuild(filename string) []string {
	if !filename.ends_with('.tar.gz') {
		return []
	}
	without_archive := filename[..filename.len - '.tar.gz'.len]
	bottle_index := without_archive.last_index('.bottle') or { return [] }
	mut rebuild := without_archive[bottle_index + '.bottle'.len..]
	if rebuild.starts_with('.') {
		rebuild = rebuild[1..]
	} else if rebuild != '' {
		return []
	}
	tag_end := bottle_index
	tag_start := without_archive[..tag_end].last_index('.') or { return [] }
	tag := without_archive[tag_start + 1..tag_end]
	if tag == '' || (rebuild != '' && !rebuild.is_int()) {
		return []
	}
	return [filename[tag_start..], tag, rebuild]
}

pub fn bottles_file_outdated(formula BottlesFormulaState, filename string) bool {
	if !formula.has_bottle {
		return false
	}
	parts := bottles_extname_tag_rebuild(os.base(filename))
	if parts.len < 3 || parts[1] == '' {
		return false
	}
	return parts[1] != formula.bottle_tag || parts[2].int() != formula.bottle_rebuild
}

pub fn bottles_file_list(bottle_file string) ![]string {
	result := os.execute_opt('tar --list --file ${os.quoted_path(bottle_file)}')!
	return result.output.split_into_lines().map(it.trim_string_right('\r'))
}

pub fn bottles_receipt_path(bottle_file string) !string {
	for line in bottles_file_list(bottle_file)! {
		parts := line.split('/')
		if parts.len >= 3 && parts.last() == 'INSTALL_RECEIPT.json' {
			return line
		}
	}
	return ''
}

pub fn bottles_file_from_bottle(bottle_file string, file_path string) !string {
	result := os.execute_opt('tar --extract --to-stdout --file ${os.quoted_path(bottle_file)} ${os.quoted_path(file_path)}')!
	return result.output
}

fn bottles_json_sidecar_path(bottle_file string) string {
	if !bottle_file.ends_with('.tar.gz') {
		return '${bottle_file}.json'
	}
	mut base := bottle_file[..bottle_file.len - '.tar.gz'.len]
	if index := base.last_index('.bottle') {
		base = base[..index + '.bottle'.len]
	}
	return '${base}.json'
}

fn bottles_receipt_tap(contents string) string {
	decoded := json2.decode[json2.Any](contents) or { return '' }
	attributes := decoded.as_map()
	return (attributes['tap'] or { json2.Any('') }).str()
}

pub fn bottles_resolve_formula_names(bottle_file string) ![]string {
	listing := bottles_file_list(bottle_file)!
	if listing.len == 0 {
		return error('Bottle archive is empty: ${bottle_file}')
	}
	name := listing[0].split('/')[0]
	mut full_name := ''
	receipt := bottles_receipt_path(bottle_file)!
	if receipt != '' {
		tap := bottles_receipt_tap(bottles_file_from_bottle(bottle_file, receipt)!)
		if tap != '' && tap != 'homebrew/core' {
			full_name = '${tap}/${name}'
		}
	} else {
		sidecar := bottles_json_sidecar_path(bottle_file)
		if os.exists(sidecar) {
			contents := os.read_file(sidecar) or { '' }
			if contents.trim_space() != '' {
				decoded := json2.decode[json2.Any](contents) or { json2.Any(map[string]json2.Any{}) }
				for key, _ in decoded.as_map() {
					full_name = key
					break
				}
			}
		}
	}
	if full_name == '' {
		full_name = name
	}
	return [name, full_name]
}

pub fn bottles_resolve_version(bottle_file string) !string {
	listing := bottles_file_list(bottle_file)!
	if listing.len == 0 {
		return error('Bottle archive is empty: ${bottle_file}')
	}
	parts := listing[0].split('/')
	if parts.len < 2 || parts[1] == '' {
		return error('Bottle archive has no package version: ${bottle_file}')
	}
	return parts[1]
}

pub fn bottles_formula_contents(bottle_file string, requested_name ?string) !string {
	name := requested_name or { bottles_resolve_formula_names(bottle_file)![0] }
	version := bottles_resolve_version(bottle_file)!
	formula_path := '${name}/${version}/.brew/${name}.rb'
	return bottles_file_from_bottle(bottle_file, formula_path) or {
		return error('Bottle formula unavailable: ${bottle_file} does not contain ${formula_path}')
	}
}

fn bottles_github_packages_root(root_url string) bool {
	return root_url.starts_with('https://ghcr.io/v2/') || root_url.starts_with('docker://ghcr.io/')
}

pub fn bottles_path_resolved_basename(root_url string, name string, checksum string,
	filename ?string) ?BottlesPathResolution {
	if bottles_github_packages_root(root_url) {
		return BottlesPathResolution{
			path: '${name.replace('@', '/').replace('+', 'x')}/blobs/sha256:${checksum}'
			resolved_basename: filename or { '' }
			github_packages: true
		}
	}
	if value := filename {
		return BottlesPathResolution{
			path: urllib.query_escape(value.replace('--', '-')).replace('+', '%20')
		}
	}
	return none
}

fn bottles_tab_from_json(contents string) BottlesTab {
	if contents.trim_space() == '' {
		return BottlesTab{}
	}
	decoded := json2.decode[json2.Any](contents) or { return BottlesTab{} }
	attributes := decoded.as_map()
	built_on := (attributes['built_on'] or { json2.Any(map[string]json2.Any{}) }).as_map()
	mut dependencies := []BottlesRuntimeDependency{}
	for entry in (attributes['runtime_dependencies'] or { json2.Any([]json2.Any{}) }).as_array() {
		item := entry.as_map()
		dependencies << BottlesRuntimeDependency{
			full_name: (item['full_name'] or { json2.Any('') }).str()
			version: (item['version'] or { json2.Any('') }).str()
		}
	}
	return BottlesTab{
		built_os: (built_on['os'] or { json2.Any('') }).str()
		runtime_dependencies: dependencies
	}
}

pub fn bottles_load_tab(input BottlesLoadTabInput) !BottlesTab {
	if input.bottle_json_path == '' && input.tab_attributes_json.trim_space() != '' {
		tab := bottles_tab_from_json(input.tab_attributes_json)
		if tab.built_os == input.current_system {
			return tab
		}
	} else if !os.exists(input.tabfile) && input.bottle_json_path != '' && os.exists(input.bottle_json_path) {
		parts := bottles_extname_tag_rebuild(input.local_bottle_path)
		if parts.len >= 2 {
			contents := os.read_file(input.bottle_json_path)!
			root := json2.decode[json2.Any](contents)!.as_map()
			formula := (root[input.full_name] or { json2.Any(map[string]json2.Any{}) }).as_map()
			bottle := (formula['bottle'] or { json2.Any(map[string]json2.Any{}) }).as_map()
			tags := (bottle['tags'] or { json2.Any(map[string]json2.Any{}) }).as_map()
			tag := (tags[parts[1]] or { json2.Any(map[string]json2.Any{}) }).as_map()
			tab := tag['tab'] or { json2.Any(map[string]json2.Any{}) }
			return bottles_tab_from_json(json2.encode(tab))
		}
	}
	existing := bottles_tab_from_json(input.existing_tab_json)
	return BottlesTab{
		built_os: existing.built_os
		runtime_dependencies: input.runtime_dependencies.clone()
	}
}

pub fn bottles_missing_all_bottle_publish_note() string {
	return 'publishing without one anyway'
}

pub fn new_bottles_collector() BottlesCollector {
	return BottlesCollector{
		tag_specs: map[string]BottlesTagSpecification{}
	}
}

pub fn (collector BottlesCollector) tags() []BottlesTag {
	mut tags := []BottlesTag{}
	for symbol in collector.order {
		if specification := collector.tag_specs[symbol] {
			tags << specification.tag
		}
	}
	return tags
}

pub fn (collector BottlesCollector) equals(other BottlesCollector) bool {
	if collector.tag_specs.len != other.tag_specs.len {
		return false
	}
	for symbol, specification in collector.tag_specs {
		other_specification := other.tag_specs[symbol] or { return false }
		if !specification.tag.equals(other_specification.tag) || specification.checksum != other_specification.checksum || specification.cellar != other_specification.cellar {
			return false
		}
	}
	return true
}

pub fn (mut collector BottlesCollector) add(tag BottlesTag, checksum string, cellar string) {
	symbol := tag.symbol()
	if symbol !in collector.tag_specs {
		collector.order << symbol
	}
	collector.tag_specs[symbol] = BottlesTagSpecification{
		tag: tag
		checksum: checksum
		cellar: cellar
	}
}

pub fn (collector BottlesCollector) find_matching_tag(tag BottlesTag,
	_no_older_versions bool) ?BottlesTag {
	if specification := collector.tag_specs[tag.symbol()] {
		return specification.tag
	}
	if specification := collector.tag_specs['all'] {
		return specification.tag
	}
	return none
}

pub fn (collector BottlesCollector) has_tag(tag BottlesTag, no_older_versions bool) bool {
	return collector.find_matching_tag(tag, no_older_versions) != none
}

pub fn (collector BottlesCollector) specification_for(tag BottlesTag,
	no_older_versions bool) ?BottlesTagSpecification {
	matching := collector.find_matching_tag(tag, no_older_versions) or { return none }
	return collector.tag_specs[matching.symbol()]
}

fn bottles_tag_value(tag BottlesTag) ruby.Value {
	return ruby.structured_value('Utils::Bottles::Tag', tag.symbol(), {
		'system': tag.system
		'arch':   tag.arch
	})
}

fn bottles_tag_from_value(value ruby.Value) !BottlesTag {
	if value.type_name == 'Utils::Bottles::Tag' || ('system' in value.attributes && 'arch' in value.attributes) {
		return new_bottles_tag(value.attributes['system'], value.attributes['arch'])
	}
	return bottles_tag_from_symbol(value.repr)
}

fn bottles_specification_value(specification BottlesTagSpecification) ruby.Value {
	return ruby.Value{
		type_name: 'Utils::Bottles::TagSpecification'
		repr: specification.tag.symbol()
		map_data: {
			'tag':      bottles_tag_value(specification.tag)
			'checksum': ruby.string_value(specification.checksum)
			'cellar':   ruby.string_value(specification.cellar)
		}
	}
}

fn bottles_specification_from_value(value ruby.Value) !BottlesTagSpecification {
	if value.type_name != 'Utils::Bottles::TagSpecification' {
		return error('expected Utils::Bottles::TagSpecification, got ${value.type_name}')
	}
	values := value.map_data.clone()
	return BottlesTagSpecification{
		tag: bottles_tag_from_value(values['tag'] or { return error('missing tag') })!
		checksum: (values['checksum'] or { return error('missing checksum') }).repr
		cellar: (values['cellar'] or { return error('missing cellar') }).repr
	}
}

fn bottles_collector_value(collector BottlesCollector) ruby.Value {
	values := collector.tags().map(bottles_specification_value(collector.tag_specs[it.symbol()]))
	return ruby.Value{
		type_name: 'Utils::Bottles::Collector'
		repr: collector.tags().map(it.symbol()).str()
		array_data: values
	}
}

fn bottles_collector_from_value(value ruby.Value) !BottlesCollector {
	if value.type_name != 'Utils::Bottles::Collector' {
		return error('expected Utils::Bottles::Collector, got ${value.type_name}')
	}
	mut collector := new_bottles_collector()
	for item in value.array_data {
		specification := bottles_specification_from_value(item)!
		collector.add(specification.tag, specification.checksum, specification.cellar)
	}
	return collector
}

fn bottles_bool_attribute(value ruby.Value, key string) bool {
	return (value.attributes[key] or { 'false' }).to_lower() in ['true', '1', 'yes']
}

fn bottles_formula_state_from_value(value ruby.Value) BottlesFormulaState {
	return BottlesFormulaState{
		latest_version_installed: bottles_bool_attribute(value, 'latest_version_installed')
		built_as_bottle: bottles_bool_attribute(value, 'built_as_bottle')
		has_bottle: bottles_bool_attribute(value, 'has_bottle')
		bottle_tag: value.attributes['bottle_tag'] or { '' }
		bottle_rebuild: (value.attributes['bottle_rebuild'] or { '0' }).int()
	}
}

fn bottles_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn bottles_no_older_versions(args []ruby.Value, index int) bool {
	return args.len > index && args[index].type_name == 'Bool' && args[index].bool_data
}
