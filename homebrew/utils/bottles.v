module utils

import ruby
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `utils/bottles.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `tag(tag = nil)` at line 16.
pub fn ruby_bottles_l16_d1_tag(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].type_name != 'NilClass' {
		return bottles_tag_value(bottles_tag_from_value(args[0]) or { panic(err) })
	}
	return bottles_tag_value(current_bottles_tag())
}

// Ruby method `built_as?(formula)` at line 31.
pub fn ruby_bottles_l31_d2_built_as(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('built_as? requires a formula')
	}
	return ruby.bool_value(bottles_built_as(bottles_formula_state_from_value(args[0])))
}

// Ruby method `file_outdated?(formula, file)` at line 39.
pub fn ruby_bottles_l39_d3_file_outdated(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('file_outdated? requires a formula and file')
	}
	return ruby.bool_value(bottles_file_outdated(bottles_formula_state_from_value(args[0]), args[1].repr))
}

// Ruby method `extname_tag_rebuild(filename)` at line 53.
pub fn ruby_bottles_l53_d4_extname_tag_rebuild(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('extname_tag_rebuild requires a filename')
	}
	return ruby.string_array_value(bottles_extname_tag_rebuild(args[0].repr))
}

// Ruby method `receipt_path(bottle_file)` at line 58.
pub fn ruby_bottles_l58_d5_receipt_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('receipt_path requires a bottle file')
	}
	path := bottles_receipt_path(args[0].repr) or { panic(err) }
	return if path == '' {
		bottles_nil_value()
	} else {
		ruby.string_value(path)
	}
}

// Ruby method `file_from_bottle(bottle_file, file_path)` at line 65.
pub fn ruby_bottles_l65_d6_file_from_bottle(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('file_from_bottle requires a bottle file and file path')
	}
	return ruby.string_value(bottles_file_from_bottle(args[0].repr, args[1].repr) or {
		panic(err)
	})
}

// Ruby method `resolve_formula_names(bottle_file)` at line 70.
pub fn ruby_bottles_l70_d7_resolve_formula_names(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('resolve_formula_names requires a bottle file')
	}
	return ruby.string_array_value(bottles_resolve_formula_names(args[0].repr) or {
		panic(err)
	})
}

// Ruby method `resolve_version(bottle_file)` at line 91.
pub fn ruby_bottles_l91_d8_resolve_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('resolve_version requires a bottle file')
	}
	return ruby.object_value('PkgVersion', bottles_resolve_version(args[0].repr) or {
		panic(err)
	})
}

// Ruby method `formula_contents(bottle_file, name: resolve_formula_names(bottle_file)[0])` at line 97.
pub fn ruby_bottles_l97_d9_formula_contents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('formula_contents requires a bottle file')
	}
	name := if args.len > 1 && args[1].type_name != 'NilClass' {
		?string(args[1].repr)
	} else {
		none
	}
	return ruby.string_value(bottles_formula_contents(args[0].repr, name) or { panic(err) })
}

// Ruby method `path_resolved_basename(root_url, name, checksum, filename)` at line 110.
pub fn ruby_bottles_l110_d10_path_resolved_basename(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('path_resolved_basename requires root URL, name, and checksum')
	}
	filename := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].attributes['github_packages'] or { args[3].repr })
	} else {
		none
	}
	resolution := bottles_path_resolved_basename(args[0].repr, args[1].repr, args[2].repr, filename) or { return bottles_nil_value() }
	if resolution.github_packages {
		return ruby.array_value([
			ruby.string_value(resolution.path),
			if resolution.resolved_basename != '' {
				ruby.string_value(resolution.resolved_basename)
			} else {
				bottles_nil_value()
			},
		])
	}
	return ruby.string_value(resolution.path)
}

// Ruby method `load_tab(formula)` at line 120.
pub fn ruby_bottles_l120_d11_load_tab(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('load_tab requires a formula')
	}
	formula := args[0]
	mut dependencies := []BottlesRuntimeDependency{}
	for value in formula.array_data {
		dependencies << BottlesRuntimeDependency{
			full_name: value.attributes['full_name'] or { value.repr }
			version: value.attributes['version'] or { '' }
		}
	}
	input := BottlesLoadTabInput{
		tab_attributes_json: formula.attributes['bottle_tab_attributes'] or { '' }
		tabfile: formula.attributes['tabfile'] or { '' }
		bottle_json_path: formula.attributes['bottle_json_path'] or { '' }
		local_bottle_path: formula.attributes['local_bottle_path'] or { '' }
		full_name: formula.attributes['full_name'] or { '' }
		existing_tab_json: formula.attributes['existing_tab'] or { '' }
		runtime_dependencies: dependencies
		current_system: formula.attributes['current_system'] or {
			ruby.kernel_info().name}
	}
	tab := bottles_load_tab(input) or { panic(err) }
	return ruby.Value{
		type_name: 'Tab'
		repr: tab.built_os
		attributes: {
			'built_os': tab.built_os
		}
		array_data: tab.runtime_dependencies.map(ruby.structured_value('RuntimeDependency', it.full_name, {
			'full_name': it.full_name
			'version':   it.version
		}))
	}
}

// Ruby method `missing_all_bottle_publish_note` at line 146.
pub fn ruby_bottles_l146_d12_missing_all_bottle_publish_note(args ...ruby.Value) ruby.Value {
	return ruby.string_value(bottles_missing_all_bottle_publish_note())
}

// Ruby method `bottle_file_list(bottle_file)` at line 153.
pub fn ruby_bottles_l153_d13_bottle_file_list(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('bottle_file_list requires a bottle file')
	}
	return ruby.string_array_value(bottles_file_list(args[0].repr) or { panic(err) })
}

// Ruby attr_reader `attr_reader :system, :arch` at line 164.
pub fn ruby_bottles_l164_d14_system(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#system requires a receiver')
	}
	return ruby.object_value('Symbol', bottles_tag_from_value(args[0]) or { panic(err) }.system)
}

// Ruby attr_reader `attr_reader :system, :arch` at line 164.
pub fn ruby_bottles_l164_d15_arch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#arch requires a receiver')
	}
	return ruby.object_value('Symbol', bottles_tag_from_value(args[0]) or { panic(err) }.arch)
}

// Ruby method `self.from_symbol(value)` at line 167.
pub fn ruby_bottles_l167_d16_self_from_symbol(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag.from_symbol requires a symbol')
	}
	return bottles_tag_value(bottles_tag_from_symbol(args[0].repr) or { panic(err) })
}

// Ruby method `self.from_arg(arg, os:, arch:)` at line 186.
pub fn ruby_bottles_l186_d17_self_from_arg(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Tag.from_arg requires argument, os, and arch')
	}
	argument := if args[0].type_name == 'NilClass' { none } else { ?string(args[0].repr) }
	return bottles_tag_value(bottles_tag_from_arg(argument, args[1].repr, args[2].repr) or {
		panic(err)
	})
}

// Ruby method `initialize(system:, arch:)` at line 195.
pub fn ruby_bottles_l195_d18_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Tag#initialize requires system and arch')
	}
	return bottles_tag_value(new_bottles_tag(args[0].repr, args[1].repr))
}

// Ruby method `==(other)` at line 201.
pub fn ruby_bottles_l201_d19_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	left := bottles_tag_from_value(args[0]) or { return ruby.bool_value(false) }
	if args[1].type_name in ['Symbol', 'String'] {
		return ruby.bool_value(left.symbol() == args[1].repr)
	}
	right := bottles_tag_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(left.equals(right))
}

// Ruby method `eql?(other)` at line 212.
pub fn ruby_bottles_l212_d20_eql(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Utils::Bottles::Tag' {
		return ruby.bool_value(false)
	}
	return ruby_bottles_l201_d19_anonymous(...args)
}

// Ruby method `hash` at line 221.
pub fn ruby_bottles_l221_d21_hash(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#hash requires a receiver')
	}
	tag := bottles_tag_from_value(args[0]) or { panic(err) }
	mut hash := u64(5381)
	for character in '${tag.system}\0${tag.standardized_arch()}' {
		hash = ((hash << 5) + hash) ^ u64(character)
	}
	return ruby.int_value(i64(hash))
}

// Ruby method `standardized_arch` at line 226.
pub fn ruby_bottles_l226_d22_standardized_arch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#standardized_arch requires a receiver')
	}
	return ruby.object_value('Symbol', bottles_tag_from_value(args[0]) or {
		panic(err)
	}.standardized_arch())
}

// Ruby method `to_sym` at line 234.
pub fn ruby_bottles_l234_d23_to_sym(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#to_sym requires a receiver')
	}
	return ruby.object_value('Symbol', bottles_tag_from_value(args[0]) or {
		panic(err)
	}.symbol())
}

// Ruby method `to_s` at line 239.
pub fn ruby_bottles_l239_d24_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#to_s requires a receiver')
	}
	return ruby.string_value(bottles_tag_from_value(args[0]) or { panic(err) }.str())
}

// Ruby method `to_unstandardized_sym` at line 244.
pub fn ruby_bottles_l244_d25_to_unstandardized_sym(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#to_unstandardized_sym requires a receiver')
	}
	return ruby.object_value('Symbol', bottles_tag_from_value(args[0]) or {
		panic(err)
	}.unstandardized_symbol())
}

// Ruby method `to_macos_version` at line 253.
pub fn ruby_bottles_l253_d26_to_macos_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#to_macos_version requires a receiver')
	}
	return ruby.object_value('MacOSVersion', bottles_tag_from_value(args[0]) or {
		panic(err)
	}.macos_version() or { panic(err) })
}

// Ruby method `linux?` at line 258.
pub fn ruby_bottles_l258_d27_linux(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#linux? requires a receiver')
	}
	return ruby.bool_value(bottles_tag_from_value(args[0]) or { panic(err) }.linux())
}

// Ruby method `macos?` at line 263.
pub fn ruby_bottles_l263_d28_macos(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#macos? requires a receiver')
	}
	return ruby.bool_value(bottles_tag_from_value(args[0]) or { panic(err) }.macos())
}

// Ruby method `valid_combination?` at line 268.
pub fn ruby_bottles_l268_d29_valid_combination(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#valid_combination? requires a receiver')
	}
	return ruby.bool_value(bottles_tag_from_value(args[0]) or {
		panic(err)
	}.valid_combination())
}

// Ruby method `default_prefix` at line 277.
pub fn ruby_bottles_l277_d30_default_prefix(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#default_prefix requires a receiver')
	}
	return ruby.string_value(bottles_tag_from_value(args[0]) or {
		panic(err)
	}.default_prefix())
}

// Ruby method `default_cellar` at line 288.
pub fn ruby_bottles_l288_d31_default_cellar(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tag#default_cellar requires a receiver')
	}
	return ruby.string_value(bottles_tag_from_value(args[0]) or {
		panic(err)
	}.default_cellar())
}

// Ruby method `arch_to_symbol(arch)` at line 301.
pub fn ruby_bottles_l301_d32_arch_to_symbol(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Tag#arch_to_symbol requires a receiver and arch')
	}
	return ruby.object_value('Symbol', bottles_arch_symbol(bottles_tag_from_value(args[0]) or {
		panic(err)
	}, args[1].repr))
}

// Ruby attr_reader `attr_reader :tag` at line 315.
pub fn ruby_bottles_l315_d33_tag(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TagSpecification#tag requires a receiver')
	}
	return bottles_tag_value(bottles_specification_from_value(args[0]) or { panic(err) }.tag)
}

// Ruby attr_reader `attr_reader :checksum` at line 318.
pub fn ruby_bottles_l318_d34_checksum(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TagSpecification#checksum requires a receiver')
	}
	return ruby.object_value('Checksum', bottles_specification_from_value(args[0]) or {
		panic(err)
	}.checksum)
}

// Ruby attr_reader `attr_reader :cellar` at line 321.
pub fn ruby_bottles_l321_d35_cellar(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TagSpecification#cellar requires a receiver')
	}
	return ruby.object_value('SymbolOrString', bottles_specification_from_value(args[0]) or {
		panic(err)
	}.cellar)
}

// Ruby method `initialize(tag:, checksum:, cellar:)` at line 324.
pub fn ruby_bottles_l324_d36_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('TagSpecification#initialize requires tag, checksum, and cellar')
	}
	return bottles_specification_value(BottlesTagSpecification{
		tag: bottles_tag_from_value(args[0]) or { panic(err) }
		checksum: args[1].repr
		cellar: args[2].repr
	})
}

// Ruby method `==(other)` at line 331.
pub fn ruby_bottles_l331_d37_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Utils::Bottles::TagSpecification' {
		return ruby.bool_value(false)
	}
	left := bottles_specification_from_value(args[0]) or { return ruby.bool_value(false) }
	right := bottles_specification_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(left.tag.equals(right.tag) && left.checksum == right.checksum && left.cellar == right.cellar)
}

// Ruby alias `alias eql? ==` at line 338.
pub fn ruby_bottles_l338_d38_eql(args ...ruby.Value) ruby.Value {
	return ruby_bottles_l331_d37_anonymous(...args)
}

// Ruby method `initialize` at line 344.
pub fn ruby_bottles_l344_d39_initialize(args ...ruby.Value) ruby.Value {
	return bottles_collector_value(new_bottles_collector())
}

// Ruby method `tags` at line 349.
pub fn ruby_bottles_l349_d40_tags(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Collector#tags requires a receiver')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	return ruby.array_value(collector.tags().map(bottles_tag_value(it)))
}

// Ruby method `==(other)` at line 354.
pub fn ruby_bottles_l354_d41_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'Utils::Bottles::Collector' {
		return ruby.bool_value(false)
	}
	left := bottles_collector_from_value(args[0]) or { return ruby.bool_value(false) }
	right := bottles_collector_from_value(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(left.equals(right))
}

// Ruby alias `alias eql? ==` at line 361.
pub fn ruby_bottles_l361_d42_eql(args ...ruby.Value) ruby.Value {
	return ruby_bottles_l354_d41_anonymous(...args)
}

// Ruby method `add(tag, checksum:, cellar:)` at line 364.
pub fn ruby_bottles_l364_d43_add(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Collector#add requires receiver, tag, checksum, and cellar')
	}
	mut collector := bottles_collector_from_value(args[0]) or { panic(err) }
	collector.add(bottles_tag_from_value(args[1]) or { panic(err) }, args[2].repr, args[3].repr)
	return bottles_collector_value(collector)
}

// Ruby method `tag?(tag, no_older_versions: false)` at line 370.
pub fn ruby_bottles_l370_d44_tag(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Collector#tag? requires a receiver and tag')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	return ruby.bool_value(collector.has_tag(bottles_tag_from_value(args[1]) or {
		panic(err)
	}, bottles_no_older_versions(args, 2)))
}

// Ruby method `each_tag(&block)` at line 376.
pub fn ruby_bottles_l376_d45_each_tag(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Collector#each_tag requires a receiver')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	// V callbacks cannot cross the generic Value boundary, so return the exact
	// source iteration sequence for typed callers to consume.
	return ruby.array_value(collector.tags().map(bottles_tag_value(it)))
}

// Ruby method `specification_for(tag, no_older_versions: false)` at line 384.
pub fn ruby_bottles_l384_d46_specification_for(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Collector#specification_for requires a receiver and tag')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	tag := bottles_tag_from_value(args[1]) or { panic(err) }
	return if specification := collector.specification_for(tag, bottles_no_older_versions(args, 2)) {
		bottles_specification_value(specification)
	} else {
		bottles_nil_value()
	}
}

// Ruby method `find_matching_tag(tag, no_older_versions: false)` at line 390.
pub fn ruby_bottles_l390_d47_find_matching_tag(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Collector#find_matching_tag requires a receiver and tag')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	tag := bottles_tag_from_value(args[1]) or { panic(err) }
	return if matching := collector.find_matching_tag(tag, bottles_no_older_versions(args, 2)) {
		bottles_tag_value(matching)
	} else {
		bottles_nil_value()
	}
}

// Ruby attr_reader `attr_reader :tag_specs` at line 402.
pub fn ruby_bottles_l402_d48_tag_specs(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Collector#tag_specs requires a receiver')
	}
	collector := bottles_collector_from_value(args[0]) or { panic(err) }
	mut values := map[string]ruby.Value{}
	for symbol, specification in collector.tag_specs {
		values[symbol] = bottles_specification_value(specification)
	}
	return ruby.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tab"
// 5:
// 6: module Utils
// 7:   # Helper functions for bottles.
// 8:   #
// 9:   # @api internal
// 10:   module Bottles
// 11:     class << self
// 12:       # Gets the tag for the running OS.
// 13:       #
// 14:       # @api internal
// 15:       sig { params(tag: T.nilable(T.any(Symbol, Tag))).returns(Tag) }
// 16:       def tag(tag = nil)
// 17:         case tag
// 18:         when Symbol
// 19:           Tag.from_symbol(tag)
// 20:         when Tag
// 21:           tag
// 22:         else
// 23:           @tag ||= T.let(Tag.new(
// 24:                            system: HOMEBREW_SYSTEM.downcase.to_sym,
// 25:                            arch:   HOMEBREW_PROCESSOR.downcase.to_sym,
// 26:                          ), T.nilable(Tag))
// 27:         end
// 28:       end
// 29:
// 30:       sig { params(formula: Formula).returns(T::Boolean) }
// 31:       def built_as?(formula)
// 32:         return false unless formula.latest_version_installed?
// 33:
// 34:         tab = Keg.new(formula.latest_installed_prefix).tab
// 35:         !!tab.built_as_bottle
// 36:       end
// 37:
// 38:       sig { params(formula: Formula, file: Pathname).returns(T::Boolean) }
// 39:       def file_outdated?(formula, file)
// 40:         file = file.resolved_path
// 41:
// 42:         filename = file.basename.to_s
// 43:         bottle = formula.bottle
// 44:         return false unless bottle
// 45:
// 46:         _, bottle_tag, bottle_rebuild = extname_tag_rebuild(filename)
// 47:         return false if bottle_tag.blank?
// 48:
// 49:         bottle_tag != bottle.tag.to_s || bottle_rebuild.to_i != bottle.rebuild
// 50:       end
// 51:
// 52:       sig { params(filename: String).returns(T::Array[String]) }
// 53:       def extname_tag_rebuild(filename)
// 54:         HOMEBREW_BOTTLES_EXTNAME_REGEX.match(filename).to_a.map(&:to_s)
// 55:       end
// 56:
// 57:       sig { params(bottle_file: Pathname).returns(T.nilable(String)) }
// 58:       def receipt_path(bottle_file)
// 59:         bottle_file_list(bottle_file).find do |line|
// 60:           %r{.+/.+/INSTALL_RECEIPT.json}.match?(line)
// 61:         end
// 62:       end
// 63:
// 64:       sig { params(bottle_file: Pathname, file_path: String).returns(String) }
// 65:       def file_from_bottle(bottle_file, file_path)
// 66:         Utils.popen_read("tar", "--extract", "--to-stdout", "--file", bottle_file, file_path)
// 67:       end
// 68:
// 69:       sig { params(bottle_file: Pathname).returns([String, String]) }
// 70:       def resolve_formula_names(bottle_file)
// 71:         name = bottle_file_list(bottle_file).first.to_s.split("/").fetch(0)
// 72:         full_name = if (receipt_file_path = receipt_path(bottle_file))
// 73:           receipt_file = file_from_bottle(bottle_file, receipt_file_path)
// 74:           tap = Tab.from_file_content(receipt_file, "#{bottle_file}/#{receipt_file_path}").tap
// 75:           "#{tap}/#{name}" if tap.present? && !tap.core_tap?
// 76:         else
// 77:           bottle_json_path = Pathname(bottle_file.sub(/\.(\d+\.)?tar\.gz$/, ".json"))
// 78:           if bottle_json_path.exist? &&
// 79:              (bottle_json_path_contents = bottle_json_path.read.presence) &&
// 80:              (bottle_json = JSON.parse(bottle_json_path_contents).presence) &&
// 81:              bottle_json.is_a?(Hash)
// 82:             bottle_json.keys.first.presence
// 83:           end
// 84:         end
// 85:         full_name ||= name
// 86:
// 87:         [name, full_name]
// 88:       end
// 89:
// 90:       sig { params(bottle_file: Pathname).returns(PkgVersion) }
// 91:       def resolve_version(bottle_file)
// 92:         version = bottle_file_list(bottle_file).first.to_s.split("/").fetch(1)
// 93:         PkgVersion.parse(version)
// 94:       end
// 95:
// 96:       sig { params(bottle_file: Pathname, name: String).returns(String) }
// 97:       def formula_contents(bottle_file, name: resolve_formula_names(bottle_file)[0])
// 98:         bottle_version = resolve_version bottle_file
// 99:         formula_path = "#{name}/#{bottle_version}/.brew/#{name}.rb"
// 100:         contents = file_from_bottle(bottle_file, formula_path)
// 101:         raise BottleFormulaUnavailableError.new(bottle_file, formula_path) unless $CHILD_STATUS.success?
// 102:
// 103:         contents
// 104:       end
// 105:
// 106:       sig {
// 107:         params(root_url: String, name: String, checksum: T.any(Checksum, String),
// 108:                filename: T.nilable(Bottle::Filename)).returns(T.nilable(T.any([String, T.nilable(String)], String)))
// 109:       }
// 110:       def path_resolved_basename(root_url, name, checksum, filename)
// 111:         if root_url.match?(GitHubPackages::URL_REGEX)
// 112:           image_name = GitHubPackages.image_formula_name(name)
// 113:           ["#{image_name}/blobs/sha256:#{checksum}", filename&.github_packages]
// 114:         else
// 115:           filename&.url_encode
// 116:         end
// 117:       end
// 118:
// 119:       sig { params(formula: Formula).returns(Tab) }
// 120:       def load_tab(formula)
// 121:         keg = Keg.new(formula.prefix)
// 122:         tabfile = keg/AbstractTab::FILENAME
// 123:         bottle_json_path = formula.local_bottle_path&.sub(/\.(\d+\.)?tar\.gz$/, ".json")
// 124:
// 125:         if bottle_json_path.nil? && (tab_attributes = formula.bottle_tab_attributes.presence)
// 126:           tab = Tab.from_file_content(tab_attributes.to_json, tabfile)
// 127:           return tab if tab.built_on&.[]("os") == HOMEBREW_SYSTEM
// 128:         elsif !tabfile.exist? && bottle_json_path&.exist?
// 129:           _, tag, = Utils::Bottles.extname_tag_rebuild(formula.local_bottle_path.to_s)
// 130:           bottle_hash = JSON.parse(File.read(bottle_json_path))
// 131:           tab_json = bottle_hash[formula.full_name]["bottle"]["tags"][tag]["tab"].to_json
// 132:           return Tab.from_file_content(tab_json, tabfile)
// 133:         else
// 134:           tab = keg.tab
// 135:         end
// 136:
// 137:         tab.runtime_dependencies = begin
// 138:           f_runtime_deps = formula.runtime_dependencies(read_from_tab: false)
// 139:           Tab.runtime_deps_hash(formula, f_runtime_deps)
// 140:         end
// 141:
// 142:         tab
// 143:       end
// 144:
// 145:       sig { returns(String) }
// 146:       def missing_all_bottle_publish_note
// 147:         "publishing without one anyway"
// 148:       end
// 149:
// 150:       private
// 151:
// 152:       sig { params(bottle_file: Pathname).returns(T::Array[String]) }
// 153:       def bottle_file_list(bottle_file)
// 154:         @bottle_file_list ||= T.let({}, T.nilable(T::Hash[Pathname, T::Array[String]]))
// 155:         @bottle_file_list[bottle_file] ||= Utils.popen_read("tar", "--list", "--file", bottle_file)
// 156:                                                 .lines
// 157:                                                 .map(&:chomp)
// 158:       end
// 159:     end
// 160:
// 161:     # Denotes the arch and OS of a bottle.
// 162:     class Tag
// 163:       sig { returns(Symbol) }
// 164:       attr_reader :system, :arch
// 165:
// 166:       sig { params(value: Symbol).returns(T.attached_class) }
// 167:       def self.from_symbol(value)
// 168:         return new(system: :all, arch: :all) if value == :all
// 169:
// 170:         @all_archs_regex ||= T.let(begin
// 171:           all_archs = Hardware::CPU::ALL_ARCHS.map(&:to_s)
// 172:           /
// 173:             ^((?<arch>#{Regexp.union(all_archs)})_)?
// 174:             (?<system>[\w.]+)$
// 175:           /x
// 176:         end, T.nilable(Regexp))
// 177:         match = @all_archs_regex.match(value.to_s)
// 178:         raise ArgumentError, "Invalid bottle tag symbol" unless match
// 179:
// 180:         system = T.must(match[:system]).to_sym
// 181:         arch = match[:arch]&.to_sym || :x86_64
// 182:         new(system:, arch:)
// 183:       end
// 184:
// 185:       sig { params(arg: T.nilable(Symbol), os: Symbol, arch: Symbol).returns(T.attached_class) }
// 186:       def self.from_arg(arg, os:, arch:)
// 187:         if arg
// 188:           from_symbol(arg)
// 189:         else
// 190:           new(system: os, arch:)
// 191:         end
// 192:       end
// 193:
// 194:       sig { params(system: Symbol, arch: Symbol).void }
// 195:       def initialize(system:, arch:)
// 196:         @system = system
// 197:         @arch = arch
// 198:       end
// 199:
// 200:       sig { override.params(other: BasicObject).returns(T::Boolean) }
// 201:       def ==(other)
// 202:         case other
// 203:         when Symbol
// 204:           to_sym == other
// 205:         when self.class
// 206:           system == other.system && standardized_arch == other.standardized_arch
// 207:         else false
// 208:         end
// 209:       end
// 210:
// 211:       sig { override.params(other: BasicObject).returns(T::Boolean) }
// 212:       def eql?(other)
// 213:         case other
// 214:         when self.class
// 215:           self == other
// 216:         else false
// 217:         end
// 218:       end
// 219:
// 220:       sig { override.returns(Integer) }
// 221:       def hash
// 222:         [system, standardized_arch].hash
// 223:       end
// 224:
// 225:       sig { returns(Symbol) }
// 226:       def standardized_arch
// 227:         return :x86_64 if [:x86_64, :intel].include? arch
// 228:         return :arm64 if [:arm64, :arm, :aarch64].include? arch
// 229:
// 230:         arch
// 231:       end
// 232:
// 233:       sig { returns(Symbol) }
// 234:       def to_sym
// 235:         arch_to_symbol(standardized_arch)
// 236:       end
// 237:
// 238:       sig { override.returns(String) }
// 239:       def to_s
// 240:         to_sym.to_s
// 241:       end
// 242:
// 243:       sig { returns(Symbol) }
// 244:       def to_unstandardized_sym
// 245:         # Never allow these generic names
// 246:         return to_sym if [:intel, :arm].include? arch
// 247:
// 248:         # Backwards compatibility with older bottle names
// 249:         arch_to_symbol(arch)
// 250:       end
// 251:
// 252:       sig { returns(MacOSVersion) }
// 253:       def to_macos_version
// 254:         @to_macos_version ||= T.let(MacOSVersion.from_symbol(system), T.nilable(MacOSVersion))
// 255:       end
// 256:
// 257:       sig { returns(T::Boolean) }
// 258:       def linux?
// 259:         system == :linux
// 260:       end
// 261:
// 262:       sig { returns(T::Boolean) }
// 263:       def macos?
// 264:         MacOSVersion::SYMBOLS.key?(system)
// 265:       end
// 266:
// 267:       sig { returns(T::Boolean) }
// 268:       def valid_combination?
// 269:         return true unless [:arm64, :arm, :aarch64].include? arch
// 270:         return true unless macos?
// 271:
// 272:         # Big Sur is the first version of macOS that runs on ARM
// 273:         to_macos_version >= :big_sur
// 274:       end
// 275:
// 276:       sig { returns(String) }
// 277:       def default_prefix
// 278:         if linux?
// 279:           T.must(HOMEBREW_LINUX_DEFAULT_PREFIX)
// 280:         elsif standardized_arch == :arm64
// 281:           T.must(HOMEBREW_MACOS_ARM_DEFAULT_PREFIX)
// 282:         else
// 283:           HOMEBREW_DEFAULT_PREFIX
// 284:         end
// 285:       end
// 286:
// 287:       sig { returns(String) }
// 288:       def default_cellar
// 289:         if linux?
// 290:           Homebrew::DEFAULT_LINUX_CELLAR
// 291:         elsif standardized_arch == :arm64
// 292:           Homebrew::DEFAULT_MACOS_ARM_CELLAR
// 293:         else
// 294:           Homebrew::DEFAULT_MACOS_CELLAR
// 295:         end
// 296:       end
// 297:
// 298:       private
// 299:
// 300:       sig { params(arch: Symbol).returns(Symbol) }
// 301:       def arch_to_symbol(arch)
// 302:         if system == :all && arch == :all
// 303:           :all
// 304:         elsif macos? && standardized_arch == :x86_64
// 305:           system
// 306:         else
// 307:           :"#{arch}_#{system}"
// 308:         end
// 309:       end
// 310:     end
// 311:
// 312:     # The specification for a specific tag
// 313:     class TagSpecification
// 314:       sig { returns(Utils::Bottles::Tag) }
// 315:       attr_reader :tag
// 316:
// 317:       sig { returns(Checksum) }
// 318:       attr_reader :checksum
// 319:
// 320:       sig { returns(T.any(Symbol, String)) }
// 321:       attr_reader :cellar
// 322:
// 323:       sig { params(tag: Utils::Bottles::Tag, checksum: Checksum, cellar: T.any(Symbol, String)).void }
// 324:       def initialize(tag:, checksum:, cellar:)
// 325:         @tag = tag
// 326:         @checksum = checksum
// 327:         @cellar = cellar
// 328:       end
// 329:
// 330:       sig { override.params(other: BasicObject).returns(T::Boolean) }
// 331:       def ==(other)
// 332:         case other
// 333:         when self.class
// 334:           tag == other.tag && checksum == other.checksum && cellar == other.cellar
// 335:         else false
// 336:         end
// 337:       end
// 338:       alias eql? ==
// 339:     end
// 340:
// 341:     # Collector for bottle specifications.
// 342:     class Collector
// 343:       sig { void }
// 344:       def initialize
// 345:         @tag_specs = T.let({}, T::Hash[Utils::Bottles::Tag, Utils::Bottles::TagSpecification])
// 346:       end
// 347:
// 348:       sig { returns(T::Array[Utils::Bottles::Tag]) }
// 349:       def tags
// 350:         @tag_specs.keys
// 351:       end
// 352:
// 353:       sig { override.params(other: BasicObject).returns(T::Boolean) }
// 354:       def ==(other)
// 355:         case other
// 356:         when self.class
// 357:           @tag_specs == other.tag_specs
// 358:         else false
// 359:         end
// 360:       end
// 361:       alias eql? ==
// 362:
// 363:       sig { params(tag: Utils::Bottles::Tag, checksum: Checksum, cellar: T.any(Symbol, String)).void }
// 364:       def add(tag, checksum:, cellar:)
// 365:         spec = Utils::Bottles::TagSpecification.new(tag:, checksum:, cellar:)
// 366:         @tag_specs[tag] = spec
// 367:       end
// 368:
// 369:       sig { params(tag: Utils::Bottles::Tag, no_older_versions: T::Boolean).returns(T::Boolean) }
// 370:       def tag?(tag, no_older_versions: false)
// 371:         tag = find_matching_tag(tag, no_older_versions:)
// 372:         tag.present?
// 373:       end
// 374:
// 375:       sig { params(block: T.proc.params(tag: Utils::Bottles::Tag).void).void }
// 376:       def each_tag(&block)
// 377:         @tag_specs.each_key(&block)
// 378:       end
// 379:
// 380:       sig {
// 381:         params(tag: Utils::Bottles::Tag, no_older_versions: T::Boolean)
// 382:           .returns(T.nilable(Utils::Bottles::TagSpecification))
// 383:       }
// 384:       def specification_for(tag, no_older_versions: false)
// 385:         tag = find_matching_tag(tag, no_older_versions:)
// 386:         @tag_specs[tag] if tag
// 387:       end
// 388:
// 389:       sig { params(tag: Utils::Bottles::Tag, no_older_versions: T::Boolean).returns(T.nilable(Utils::Bottles::Tag)) }
// 390:       def find_matching_tag(tag, no_older_versions: false)
// 391:         if @tag_specs.key?(tag)
// 392:           tag
// 393:         else
// 394:           all = Tag.from_symbol(:all)
// 395:           all if @tag_specs.key?(all)
// 396:         end
// 397:       end
// 398:
// 399:       protected
// 400:
// 401:       sig { returns(T::Hash[Utils::Bottles::Tag, Utils::Bottles::TagSpecification]) }
// 402:       attr_reader :tag_specs
// 403:     end
// 404:   end
// 405: end
// 406:
// 407: require "extend/os/bottles"
