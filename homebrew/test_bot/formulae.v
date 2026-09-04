module test_bot

import crypto.sha256
import ruby
import json2
import os

// Translated from Homebrew/brew `test_bot/formulae.rb`.

pub struct FormulaeDependency {
pub:
	name                 string
	full_name            string
	build                bool
	optional             bool
	test                 bool
	bottled              bool = true
	bottled_current      bool = true
	runtime_dependencies []string
	conflicts            []string
	versioned            bool
	versioned_formulae   []string
}

pub struct FormulaeFormula {
pub:
	name                       string
	full_name                  string
	pkg_version                string
	path                       string
	disabled                   bool
	deprecated                 bool
	latest_version_installed   bool
	linked                     bool
	keg_only                   bool
	versioned                  bool
	versioned_formulae         []string
	dependencies               []FormulaeDependency
	conflicts                  []string
	test_defined               bool
	requirement_messages       []string
	install_etc_var_path       string
	bottle_prefix              string
	prefix_root                string
	bottle_file                string
	bottle_json_file           string
	bottle_output              string
	has_all_bottle             bool
	bottle_dsl_tags            []string
	current_bottle_tag         string
	livecheck_defined          bool
	livecheck_skip             bool
	livecheck_status           string
	livecheck_messages         []string
	livecheck_newer_upstream   bool
	livecheck_current_version  string
	livecheck_latest_version   string
	portable_dependencies      []string
	added_dependency_names     []string
	dependency_installed_sizes map[string]i64
}

pub struct FormulaeArgs {
pub:
	dry_run                    bool
	test_default_formula       bool
	build_from_source          bool
	keep_old                   bool
	skip_relocation            bool
	only_json_tab              bool
	skip_online_checks         bool
	skip_new                   bool
	skip_new_strict            bool
	skip_checksum_only_audit   bool
	skip_stable_version_audit  bool
	skip_revision_audit        bool
	skip_livecheck             bool
	cleanup                    bool
	root_url                   string
	integration_portable_ruby  bool = true
	ca_file_handles_most_https bool = true
}

pub struct FormulaeConfig {
pub:
	test_config      TestConfig
	output_paths     map[string]string
	formulae         map[string]FormulaeFormula
	artifact_cache   string = 'artifact-cache'
	work_dir         string = '.'
	github_output    string
	current_tap_core bool
}

pub struct FormulaeAnnotation {
pub:
	kind    string
	message string
	file    string
	line    int
	title   string
}

pub struct FormulaeTagHash {
pub:
	cellar string
	sha256 string
}

pub struct FormulaeDependencySetup {
pub:
	unlinked                     []string
	linked                       []string
	unchanged_dependencies       []string
	changed_dependencies         []string
	unchanged_build_dependencies []string
}

@[heap]
pub struct FormulaeRunner {
pub mut:
	base                         &Test
	formulae                     map[string]FormulaeFormula
	artifact_cache               string
	work_dir                     string
	bottle_output_path           string
	linkage_output_path          string
	skipped_output_path          string
	github_output                string
	current_tap_core             bool
	built_formulae               []string
	bottle_checksums             map[string]string
	testing_formulae             []string
	added_formulae               []string
	deleted_formulae             []string
	testing_formulae_count       int
	tested_formulae_count        int
	unchanged_dependencies       []string
	unchanged_build_dependencies []string
	bottle_filename              string
	bottle_json_filename         string
	skipped_or_failed_formulae   []string
	annotations                  []FormulaeAnnotation
	warnings                     []string
}

@[heap]
pub struct FormulaeBoundaryInput {
pub:
	config          FormulaeConfig
	args            FormulaeArgs
	formula         FormulaeFormula
	dependency      FormulaeDependency
	dependencies    []FormulaeDependency
	formula_name    string
	dependency_name string
	directory       string
}

pub struct FormulaeBottleJsonEntry {
pub:
	bottle FormulaeBottleJsonSpec
}

pub struct FormulaeBottleJsonSpec {
pub:
	cellar string
	tags   map[string]FormulaeBottleJsonTag
}

pub struct FormulaeBottleJsonTag {
pub:
	cellar string
	sha256 string
}

fn formulae_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if value != '' && !seen[value] {
			seen[value] = true
			result << value
		}
	}
	return result
}

fn formulae_difference(values []string, remove []string) []string {
	return values.filter(it !in remove)
}

fn formulae_sha256(path string) !string {
	return sha256.sum256(os.read_bytes(path)!).hex()
}

pub fn new_formulae_runner(config FormulaeConfig) &FormulaeRunner {
	return &FormulaeRunner{
		base: new_test(config.test_config)
		formulae: config.formulae.clone()
		artifact_cache: config.artifact_cache
		work_dir: config.work_dir
		bottle_output_path: config.output_paths['bottle']
		linkage_output_path: config.output_paths['linkage']
		skipped_output_path: config.output_paths['skipped_or_failed_formulae']
		github_output: config.github_output
		current_tap_core: config.current_tap_core
	}
}

fn (mut runner FormulaeRunner) command(arguments []string, named_args []string, ignore_failures bool) Step {
	return runner.base.run_step(TestRequest{
		arguments: arguments
		named_args: named_args
		ignore_failures: ignore_failures
	})
}

pub fn (mut runner FormulaeRunner) set_testing_formulae(values []string) {
	runner.testing_formulae = values.clone()
}

pub fn (mut runner FormulaeRunner) set_added_formulae(values []string) {
	runner.added_formulae = values.clone()
}

pub fn (mut runner FormulaeRunner) set_deleted_formulae(values []string) {
	runner.deleted_formulae = values.clone()
}

fn (runner &FormulaeRunner) sorted_formula_names() []string {
	mut remaining := runner.testing_formulae.clone()
	mut sorted := []string{}
	for remaining.len > 0 {
		mut progressed := false
		for name in remaining.clone() {
			formula := runner.formulae[name]
			blocking := formula.dependencies.any(it.name in remaining || it.full_name in remaining)
			if !blocking {
				sorted << name
				remaining.delete(remaining.index(name))
				progressed = true
			}
		}
		if !progressed {
			sorted << remaining
			break
		}
	}
	return sorted
}

pub fn (mut runner FormulaeRunner) run(args FormulaeArgs) {
	runner.base.test_header('Formulae', 'run!')
	runner.verify_local_bottles()
	runner.testing_formulae_count = runner.testing_formulae.len
	runner.tested_formulae_count = 0
	perform_bash_cleanup := 'bash' in runner.testing_formulae
	for name in runner.sorted_formula_names() {
		runner.verify_local_bottles()
		if runner.testing_portable_ruby() {
			runner.portable_formula(name, args)
		} else {
			runner.formula(name, args)
		}
		if runner.testing_formulae_count >= 3 {
			runner.base.info_header('Test progress: ${runner.tested_formulae_count} formula(e) tested, ${runner.testing_formulae_count - runner.tested_formulae_count} remaining')
		}
	}
	for name in runner.deleted_formulae {
		runner.deleted_formula(name)
		runner.verify_local_bottles()
	}
	if runner.base.github_actions {
		if perform_bash_cleanup {
			runner.command(['brew', 'uninstall', '--formula', '--force', 'bash'], [], false)
		}
		joined := runner.skipped_or_failed_formulae.join(',')
		if runner.github_output != '' {
			os.write_file(runner.github_output, 'skipped_or_failed_formulae=${joined}\n') or {}
		}
		if runner.skipped_output_path != '' {
			os.write_file(runner.skipped_output_path, joined) or {}
		}
	}
	runner.verify_local_bottles()
}

pub fn (runner &FormulaeRunner) cleanup_bottle_etc_var(formula FormulaeFormula) {
	if formula.bottle_prefix != '' && formula.prefix_root != '' {
		for directory in ['etc', 'var'] {
			source := os.join_path(formula.bottle_prefix, directory)
			if !os.is_dir(source) {
				continue
			}
			destination := os.join_path(formula.prefix_root, directory)
			os.mkdir_all(destination) or { continue }
			for entry in os.ls(source) or { [] } {
				os.cp_all(os.join_path(source, entry), os.join_path(destination, entry), true) or {}
			}
		}
		return
	}
	if formula.install_etc_var_path != '' {
		os.mkdir_all(formula.install_etc_var_path) or {}
	}
}

fn formulae_bottle_files(root string) []string {
	if !os.exists(root) {
		return []
	}
	mut files := []string{}
	for path in os.walk_ext(root, '', hidden: true) {
		if path.ends_with('.json') || path.ends_with('.tar.gz') {
			files << os.real_path(path)
		}
	}
	return files
}

pub fn (mut runner FormulaeRunner) verify_local_bottles() bool {
	if runner.testing_portable_ruby() {
		return false
	}
	mut bad := false
	mut remove := []string{}
	for path, expected in runner.bottle_checksums {
		if !os.exists(path) {
			runner.warnings << 'Missing bottle ${if path.ends_with('.json') {
				'JSON'
			} else {
				'tarball'
			}}: ${path}'
			bad = true
			continue
		}
		actual := formulae_sha256(path) or { '' }
		if actual != expected {
			runner.warnings << 'Bottle checksum mismatch for ${path}!\n  Expected: ${expected}\n  Actual:   ${actual}'
			remove << path
			bad = true
		}
	}
	for path in formulae_bottle_files(runner.work_dir) {
		if path !in runner.bottle_checksums {
			runner.warnings << 'Unexpected bottle ${if path.ends_with('.json') {
				'JSON'
			} else {
				'tarball'
			}}: ${path}'
			remove << path
			bad = true
		}
	}
	for path in formulae_unique(remove) {
		os.rm(path) or {}
	}
	if bad {
		runner.command(['false'], [], false)
	}
	return !bad
}

pub fn dependency_name_match(dependency FormulaeDependency, dependency_name string) bool {
	if dependency.name == dependency_name || dependency.full_name == dependency_name {
		return true
	}
	if dependency.name.contains('/') || dependency_name.contains('/') {
		return false
	}
	return dependency.name.all_after_last('/') == dependency_name.all_after_last('/')
}

pub fn (mut runner FormulaeRunner) annotate_added_dependencies(formula FormulaeFormula) {
	if !runner.base.github_actions || formula.name in runner.added_formulae || !runner.base.has_git {
		return
	}
	direct := formula.dependencies.filter(!it.build && !it.optional && !it.test)
	for dependency_name in formula.added_dependency_names {
		dependency := direct.filter(dependency_name_match(it, dependency_name))
		if dependency.len == 0 {
			continue
		}
		mut existing := []string{}
		for other in direct {
			if !dependency_name_match(other, dependency[0].name) {
				existing << recursive_runtime_dependency_names(formula, [other])
			}
		}
		mut added := [
			if dependency[0].full_name != '' { dependency[0].full_name } else { dependency[0].name },
		]
		added << dependency[0].runtime_dependencies
		added = formulae_difference(formulae_unique(added), formulae_unique(existing))
		if added.len == 0 {
			continue
		}
		mut total := i64(0)
		mut unknown := 0
		for name in added {
			if name in formula.dependency_installed_sizes {
				total += formula.dependency_installed_sizes[name]
			} else {
				unknown++
			}
		}
		mut message := 'Adding `${dependency_name}` adds ${added.len} new recursive ${if added.len == 1 {
			'dependency'
		} else {
			'dependencies'
		}} (${total} bytes'
		if unknown > 0 {
			message += ', plus ${unknown} unknown ${if unknown == 1 { 'size' } else { 'sizes' }}'
		}
		message += ').'
		runner.annotations << FormulaeAnnotation{
			kind: 'warning'
			message: message
			file: formula.path.trim_string_left('${runner.base.repository.trim_right('/')}/')
			title: '${formula.full_name}: new dependency impact'
		}
	}
}

pub fn (mut runner FormulaeRunner) annotate_missing_all_bottle(formula FormulaeFormula, bottle_dir string) {
	if !formula.has_all_bottle || 'all' in formula.bottle_dsl_tags {
		return
	}
	tags := local_bottle_tag_hashes(formula.name, bottle_dir)
	if 'all' in tags || tags.len < 2 {
		return
	}
	mut unique := map[string]bool{}
	for _, tag in tags {
		unique['${tag.cellar}\x1f${tag.sha256}'] = true
	}
	if unique.len <= 1 {
		return
	}
	current := if formula.current_bottle_tag != '' { formula.current_bottle_tag } else { 'current' }
	detail := if current in tags {
		' (cellar `${tags[current].cellar}`, sha256 `${tags[current].sha256}`)'
	} else {
		''
	}
	message := 'This formula had an `:all` bottle but the ${current} test-bot bottle is platform-specific${detail}. If the final bottle merge cannot create a new `:all` bottle, a platform-specific bottle will be published; this is for information only and should not block merge.'
	if runner.base.github_actions {
		runner.annotations << FormulaeAnnotation{
			kind: 'warning'
			message: message
			file: formula.path.trim_string_left('${runner.base.repository.trim_right('/')}/')
			title: '${formula.full_name}: missing :all bottle'
		}
	} else {
		runner.warnings << message
	}
}

pub fn (runner &FormulaeRunner) testing_portable_ruby() bool {
	return runner.base.has_tap && runner.current_tap_core && 'portable-ruby' in runner.testing_formulae
}

pub fn (mut runner FormulaeRunner) install_ca_certificates_if_needed(args FormulaeArgs) {
	if !args.ca_file_handles_most_https {
		runner.command(['brew', 'install', '--formulae', 'ca-certificates'], [], false)
	}
}

pub fn (mut runner FormulaeRunner) setup_formulae_deps_instances(formula FormulaeFormula, formula_name string, args FormulaeArgs) FormulaeDependencySetup {
	mut conflicts := formula.conflicts.clone()
	for dependency in formula.dependencies {
		conflicts << dependency.conflicts
		if dependency.versioned {
			for alternative in dependency.versioned_formulae {
				if !formula.dependencies.any(it.name == alternative || it.full_name == alternative) {
					conflicts << alternative
				}
			}
		}
	}
	conflicts = formulae_unique(conflicts)
	for name in conflicts {
		runner.command(['brew', 'unlink', name], [], false)
	}
	dependencies := formulae_unique(formula.dependencies.map(if it.full_name != '' {
		it.full_name
	} else {
		it.name
	}))
	mut unchanged := dependencies.filter(it !in runner.testing_formulae)
	mut changed := formulae_difference(dependencies, unchanged)
	if unchanged.len > 0 {
		runner.command(['brew', 'fetch', '--formulae', '--retry'], unchanged, false)
	}
	if changed.len > 0 {
		runner.command(['brew', 'fetch', '--formulae', '--retry', '--build-from-source'], changed, false)
		ignore := !args.test_default_formula && formula.dependencies.any((it.name in changed || it.full_name in changed) && !it.bottled_current)
		runner.command(['brew', 'install', '--formulae', '--build-from-source'], changed, ignore)
		runner.command(['brew', 'postinstall'], changed, ignore)
	}
	build_names := formula.dependencies.filter(it.build && !it.test).map(if it.full_name != '' {
		it.full_name
	} else {
		it.name
	})
	runner.unchanged_dependencies = unchanged.clone()
	runner.unchanged_build_dependencies = unchanged.filter(it in build_names)
	return FormulaeDependencySetup{
		unlinked: conflicts
		unchanged_dependencies: unchanged
		changed_dependencies: changed
		unchanged_build_dependencies: runner.unchanged_build_dependencies.clone()
	}
}

pub fn (mut runner FormulaeRunner) bottle_reinstall_formula(formula FormulaeFormula, new_formula bool, args FormulaeArgs) {
	if !runner.build_bottle(formula, args) {
		runner.bottle_filename = ''
		return
	}
	mut root_url := args.root_url
	if root_url == '' && runner.base.has_tap && !runner.current_tap_core && !args.test_default_formula {
		root_url = '${runner.base.tap.full_name}/releases/download/${formula.name}-${formula.pkg_version}'
	}
	mut bottle_args := ['brew', 'bottle', '--verbose', '--json', formula.full_name]
	if args.keep_old && !new_formula { bottle_args << '--keep-old' }
	if args.skip_relocation { bottle_args << '--skip-relocation' }
	if args.test_default_formula { bottle_args << '--force-core-tap' }
	if root_url != '' { bottle_args << '--root-url=${root_url}' }
	if args.only_json_tab { bottle_args << '--only-json-tab' }
	runner.verify_local_bottles()
	runner.command(bottle_args, [], false)
	if formula.bottle_file == '' || formula.bottle_json_file == '' || !os.exists(formula.bottle_file) || !os.exists(formula.bottle_json_file) {
		if !args.dry_run { runner.skip_or_fail(formula.full_name, 'bottling failed') }
		return
	}
	runner.bottle_filename = os.real_path(formula.bottle_file)
	runner.bottle_json_filename = os.real_path(formula.bottle_json_file)
	runner.bottle_checksums[runner.bottle_filename] = formulae_sha256(runner.bottle_filename) or { '' }
	runner.bottle_checksums[runner.bottle_json_filename] = formulae_sha256(runner.bottle_json_filename) or { '' }
	if runner.bottle_output_path != '' {
		os.write_file(runner.bottle_output_path, formula.bottle_output) or {}
	}
	mut merge_args := ['brew', 'bottle', '--merge', '--write', '--no-commit', '--no-all-checks',
		runner.bottle_json_filename]
	if args.keep_old && !new_formula { merge_args << '--keep-old' }
	runner.command(merge_args, [], false)
	runner.annotate_missing_all_bottle(formula, runner.work_dir)
	runner.command(['brew', 'uninstall', '--formula', '--force', '--ignore-dependencies',
		formula.full_name], [], false)
	runner.testing_formulae = runner.testing_formulae.filter(it != formula.name)
	if runner.unchanged_build_dependencies.len > 0 {
		runner.command(['brew', 'uninstall', '--formulae', '--force', '--ignore-dependencies'], runner.unchanged_build_dependencies, false)
		runner.unchanged_dependencies = formulae_difference(runner.unchanged_dependencies, runner.unchanged_build_dependencies)
	}
	runner.command(['brew', 'install', '--only-dependencies', runner.bottle_filename], [], false)
	runner.command(['brew', 'install', runner.bottle_filename], [], false)
}

pub fn (runner &FormulaeRunner) build_bottle(formula FormulaeFormula, args FormulaeArgs) bool {
	available := formulae_difference(runner.built_formulae, runner.skipped_or_failed_formulae)
	for dependency in formula.dependencies {
		if !(dependency.full_name in available || dependency.name in available || if dependency.test {
			dependency.bottled
		} else {
			dependency.bottled_current
		}) {
			return false
		}
	}
	return !args.build_from_source
}

pub fn setup_bottle_sudo_purge(_ FormulaeArgs) {}

pub fn recursive_runtime_dependency_names(_ FormulaeFormula, dependencies []FormulaeDependency) []string {
	mut names := []string{}
	for dependency in dependencies {
		names << if dependency.full_name != '' { dependency.full_name } else { dependency.name }
		names << dependency.runtime_dependencies
	}
	return formulae_unique(names)
}

pub fn local_bottle_tag_hashes(formula_name string, bottle_dir string) map[string]FormulaeTagHash {
	mut result := map[string]FormulaeTagHash{}
	if !os.exists(bottle_dir) {
		return result
	}
	for path in os.walk_ext(bottle_dir, '.json', hidden: true) {
		if !os.base(path).starts_with('${formula_name}--') && !os.base(path).starts_with('${formula_name}-') {
			continue
		}
		contents := os.read_file(path) or { continue }
		document := json2.decode[map[string]FormulaeBottleJsonEntry](contents) or { continue }
		if formula_name !in document {
			continue
		}
		bottle := document[formula_name].bottle
		for tag, value in bottle.tags {
			result[tag] = FormulaeTagHash{
				cellar: if value.cellar != '' { value.cellar } else { bottle.cellar }
				sha256: value.sha256
			}
		}
	}
	return result
}

pub fn (mut runner FormulaeRunner) livecheck(formula FormulaeFormula) {
	if !formula.livecheck_defined || formula.livecheck_skip {
		return
	}
	runner.command(['brew', 'livecheck', '--autobump', '--formula', '--json', '--full-name',
		formula.full_name], [], false)
	if formula.livecheck_status == 'error' {
		message := if formula.livecheck_messages.len > 0 {
			formula.livecheck_messages.join('\n')
		} else {
			'Error encountered (no message provided)'
		}
		runner.add_livecheck_message('error', formula, message, '${formula.full_name}: livecheck error')
		return
	}
	if formula.livecheck_status != '' || !formula.livecheck_newer_upstream {
		return
	}
	message := if formula.livecheck_current_version != '' && formula.livecheck_latest_version != '' {
		'The formula version (${formula.livecheck_current_version}) is newer than the version from `brew livecheck` (${formula.livecheck_latest_version}).'
	} else {
		'The formula version is newer than the version from `brew livecheck`.'
	}
	runner.add_livecheck_message('warning', formula, message, '${formula.full_name}: Formula version newer than livecheck')
}

fn (mut runner FormulaeRunner) add_livecheck_message(kind string, formula FormulaeFormula, message string, title string) {
	if runner.base.github_actions {
		runner.annotations << FormulaeAnnotation{ kind: kind, message: message, file: formula.path, title: title }
	} else {
		runner.warnings << message
	}
}

fn (mut runner FormulaeRunner) skip_or_fail(name string, reason string) {
	runner.skipped_or_failed_formulae << name
	runner.warnings << '${name}: ${reason}'
}

pub fn (mut runner FormulaeRunner) formula(formula_name string, args FormulaeArgs) {
	runner.base.test_header('Formulae', 'formula!(${formula_name})')
	if formula_name !in runner.formulae {
		runner.skip_or_fail(formula_name, 'formula unavailable')
		return
	}
	formula := runner.formulae[formula_name]
	defer {
		runner.tested_formulae_count++
		if args.cleanup { runner.cleanup_bottle_etc_var(formula) }
		if runner.unchanged_dependencies.len > 0 {
			runner.command(['brew', 'uninstall', '--formulae', '--force', '--ignore-dependencies'], runner.unchanged_dependencies, false)
		}
	}
	if formula.disabled {
		runner.skip_or_fail(formula_name, '${formula.full_name} has been disabled!')
		return
	}
	new_formula := formula_name in runner.added_formulae
	if !new_formula { runner.annotate_added_dependencies(formula) }
	runner.command(['brew', 'deps', '--tree', '--prune', '--annotate', '--include-build',
		'--include-test'], [formula_name], false)
	if !runner.build_bottle(formula, args) {
		runner.skip_or_fail(formula_name, 'No bottle built.')
		return
	}
	skip_online := args.skip_online_checks || runner.testing_formulae_count > 5
	runner.install_ca_certificates_if_needed(args)
	if formula.requirement_messages.len > 0 {
		runner.command(['brew', 'fetch', '--formula', '--retry', formula_name, '--build-bottle'], [], false)
		runner.command(['brew', 'audit', '--formula', formula_name], [], false)
		runner.skip_or_fail(formula_name, formula.requirement_messages.join('\n'))
		return
	}
	runner.setup_formulae_deps_instances(formula, formula_name, args)
	if formula.latest_version_installed {
		runner.command(['brew', 'uninstall', '--formula', '--force', formula_name], [], false)
	}
	runner.command(['brew', 'install', '--only-dependencies', '--verbose', '--formula',
		'--build-bottle', formula_name], [], false)
	runner.base.info_header('Starting tests for ${formula_name}')
	runner.command(['brew', 'fetch', '--formula', '--retry', formula_name, '--build-bottle'], [], false)
	runner.command(['brew', 'install', '--verbose', '--formula', '--build-bottle'], [
		formula_name,
	], false)
	if !args.skip_livecheck && !skip_online { runner.livecheck(formula) }
	runner.command(['brew', 'style', '--formula', formula_name], [], false)
	if !formula.deprecated { runner.command(['brew', 'audit', '--formula', formula_name], [], false) }
	runner.bottle_reinstall_formula(formula, new_formula, args)
	runner.built_formulae << formula.full_name
	runner.command(['brew', 'linkage', '--test'], [formula_name], false)
	runner.command(['brew', 'linkage', '--cached', '--test', '--strict'], [
		formula_name,
	], !args.test_default_formula)
	linkage := runner.command(['brew', 'linkage', '--cached', formula_name], [], false)
	if runner.linkage_output_path != '' {
		os.write_file(runner.linkage_output_path, linkage.output) or {}
	}
	runner.command(['brew', 'install', '--formula', '--only-dependencies', '--include-test',
		formula_name], [], false)
	if formula.test_defined {
		runner.command(['brew', 'test', '--verbose'], [
			formula_name,
		], false)
	}
}

pub fn (mut runner FormulaeRunner) portable_formula(formula_name string, args FormulaeArgs) {
	runner.base.test_header('Formulae', 'portable_formula!(${formula_name})')
	runner.install_ca_certificates_if_needed(args)
	formula := runner.formulae[formula_name]
	mut bottled := []string{}
	mut source := []string{}
	for dependency in formula.portable_dependencies {
		if dependency.starts_with('glibc@') || dependency.starts_with('linux-headers@') {
			bottled << dependency
		} else {
			source << dependency
		}
	}
	if bottled.len > 0 { runner.command(['brew', 'install'], bottled, false) }
	if source.len > 0 { runner.command(['brew', 'install', '--build-bottle'], source, false) }
	runner.command(['brew', 'install', '--build-bottle', formula_name], [], false)
	if source.len > 0 {
		runner.command(['brew', 'uninstall', '--force', '--ignore-dependencies'], source, false)
	}
	runner.command(['brew', 'test', formula_name], [], false)
	runner.command(['brew', 'linkage', formula_name], [], false)
	runner.command(['brew', 'bottle', '--skip-relocation', '--json', '--no-rebuild', formula_name], [], false)
	if formula_name != 'portable-ruby' || args.dry_run || !args.integration_portable_ruby {
		return
	}
	if formula.bottle_file == '' || !os.exists(formula.bottle_file) {
		runner.skip_or_fail(formula_name, 'no bottle file found for portable-ruby validation')
		return
	}
	filename := os.base(formula.bottle_file)
	if !filename.contains('.bottle') || !filename.ends_with('.tar.gz') {
		runner.skip_or_fail(formula_name, 'could not parse bottle filename ${filename}')
		return
	}
	for command in [
		['brew', 'vendor-install', 'ruby'],
		['brew', 'vendor-gems', '--no-commit', '--update=--ruby'],
		['brew', 'typecheck', '--update'],
		['brew', 'style'],
		['brew', 'typecheck'],
		['brew', 'install-bundler-gems', '--groups=all'],
		['brew', 'vendor-gems', '--non-bundler-gems', '--no-commit'],
		['brew', 'tests', '--online', '--coverage'],
		['brew', 'update-test'],
		['brew', 'update-test', '--to-tag'],
		['brew', 'update-test', '--commit=HEAD'],
		['brew', 'test-bot', '--only-formulae', '--only-json-tab', '--test-default-formula'],
	] {
		runner.command(command, [], false)
	}
}

pub fn (mut runner FormulaeRunner) deleted_formula(formula_name string) {
	runner.base.test_header('Formulae', 'deleted_formula!(${formula_name})')
	runner.command(['brew', 'uses', '--formula', '--include-build', '--include-optional',
		'--include-test', formula_name], [], false)
}

pub fn integration_test_portable_ruby() bool {
	return true
}

pub fn formulae_boundary_value(runner &FormulaeRunner) ruby.Value {
	return ruby.structured_value('Homebrew::TestBot::Formulae', runner.testing_formulae.str(), {
		'address': u64(voidptr(runner)).str()
	})
}

pub fn formulae_boundary_input(input &FormulaeBoundaryInput) ruby.Value {
	return ruby.structured_value('Homebrew::TestBot::FormulaeBoundaryInput', input.formula_name, {
		'address': u64(voidptr(input)).str()
	})
}

fn formulae_receiver(args []ruby.Value) !&FormulaeRunner {
	if args.len == 0 || args[0].type_name != 'Homebrew::TestBot::Formulae' {
		return error('Formulae receiver is required')
	}
	address := args[0].attributes['address'] or { return error('Formulae receiver has no address') }
	if address.u64() == 0 {
		return error('Formulae receiver has an invalid address')
	}
	return unsafe { &FormulaeRunner(voidptr(address.u64())) }
}

fn formulae_input(args []ruby.Value, index int) &FormulaeBoundaryInput {
	if args.len <= index || args[index].type_name != 'Homebrew::TestBot::FormulaeBoundaryInput' {
		return &FormulaeBoundaryInput{}
	}
	address := args[index].attributes['address'] or { return &FormulaeBoundaryInput{} }
	if address.u64() == 0 {
		return &FormulaeBoundaryInput{}
	}
	return unsafe { &FormulaeBoundaryInput(voidptr(address.u64())) }
}

fn formulae_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formulae_tags_boundary(tags map[string]FormulaeTagHash) ruby.Value {
	mut values := map[string]ruby.Value{}
	for tag, value in tags {
		values[tag] = ruby.structured_value('Hash', tag, {
			'cellar': value.cellar
			'sha256': value.sha256
		})
	}
	return ruby.map_value(values)
}
