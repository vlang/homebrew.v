module homebrew

import ruby
import homebrew.api
import homebrew.utils as spdx
import os
import time
import x.json2

// Translated from Homebrew/brew `formula_installer.rb`.
pub enum InstallerFetchAction {
	none
	bottle_metadata
	source
}

pub struct FormulaInstallerConfig {
pub:
	link_keg                    bool
	installed_on_request        bool
	show_header                 bool
	build_bottle                bool
	skip_post_install           bool
	skip_link                   bool
	force_bottle                bool
	bottle_arch                 string
	ignore_deps                 bool
	only_deps                   bool
	include_test_formulae       []string
	build_from_source_formulae  []string
	environment                 string
	git                         bool
	interactive                 bool
	keep_tmp                    bool
	debug_symbols               bool
	compiler                    string
	options                     []string
	force                       bool
	overwrite                   bool
	debug                       bool
	quiet                       bool
	verbose                     bool
	head                        bool
	pour_bottle_allowed         bool = true
	bottle_locations_compatible bool = true
	local_bottle_path           string
	keg_only_versioned          bool
	any_version_installed       bool
	related_formula_installed   bool
	forbidden_formulae          []string
	forbidden_taps              []string
	allowed_taps                []string
	forbidden_licenses          []string
	forbidden_owner             string = 'your system administrator'
	forbidden_owner_contact     string
	link_overwrite_reason       string
	developer                   bool
	default_prefix              bool
	integration_test            bool
	fresh_install               bool
	pour_bottle_failure_reason  string
	prefix                      string
	cellar                      string
	temporary_cellar            string
}

// FormulaDependencyResolutionConfig is the injectable half of Formulary
// resolution used while expanding a formula's dependency graph. The source
// resolves dependencies lazily through Dependency#to_formula; retaining a map
// here makes that behavior deterministic for callers and specs while the API
// lookup remains the production fallback.
pub struct FormulaDependencyResolutionConfig {
pub:
	formula_lookup  api.FormulaLookupConfig
	references      map[string]api.PackageReference
	installations   map[string]DependencyInstallation
	sanity          []InstallerDependencySanity
	current_arch    string
	check_installed bool
	prefix          string
	cellar          string
}

pub struct InstallerDependencySanity {
pub:
	name         string
	receipt_arch string
	pinned       bool
	satisfied    bool
}

pub struct FormulaDependencyPlan {
pub:
	dependency        Dependency
	formula           api.PackageReference
	minimum           DependencyMinimum
	declared_directly bool
}

pub struct FormulaFetchDependenciesPlan {
pub:
	dependencies []FormulaDependencyPlan
	recompute    bool
}

pub enum InstallerDownloadKind {
	bottle
	source
	local
}

@[heap]
pub struct InstallerDownloadPlan {
pub:
	formula           api.PackageReference
	kind              InstallerDownloadKind
	check_attestation bool
	stage             bool
	has_bottle        bool
pub mut:
	bottle       Bottle
	resource     Resource
	staged_path  string
	stage_marker string
}

pub struct FormulaPourResult {
pub:
	formula       Formula
	keg           Keg
	tab           Tab
	changed_files []string
}

pub struct FormulaFinishResult {
pub:
	summary     string
	linked      bool
	optlinked   bool
	completions []string
	executable  string
}

pub struct FormulaBottleInstallResult {
pub:
	formula string
	finish  FormulaFinishResult
}

// FormulaInstallerState contains the mutable instance variables used by the
// source installer. Keeping this separate from FormulaInstaller preserves the
// value semantics of the translated configuration while making every state
// transition explicit to V callers.
pub struct FormulaInstallerState {
pub mut:
	download_queue                  DownloadQueue
	has_download_queue              bool
	ran_prelude_fetch_metadata      bool
	ran_prelude_fetch               bool
	ran_prelude                     bool
	bottle_tab_runtime_dependencies map[string]map[string]string
	bottle_built_os_version         string
	compute_dependencies            []FormulaDependencyPlan
	has_compute_dependencies        bool
	requirement_messages            []string
	etc_var_preinstall              []string
	poured_bottle                   bool
	start_time_millisecond          i64
	has_start_time                  bool
	build_time_seconds              f64
	has_build_time                  bool
	hold_locks                      bool
	show_summary_heading            bool
}

pub struct FormulaInstallerIdentity {
pub:
	full_name   string
	active_spec string
}

pub struct FormulaInstallerClassState {
pub mut:
	missing_bottle_metadata_warning_shown bool
	attempted                             []FormulaInstallerIdentity
	installed                             []FormulaInstallerIdentity
	fetched                               []FormulaInstallerIdentity
	locked                                []FormulaInstallerIdentity
}

pub struct FormulaInstallerPreludeResult {
pub:
	fetch_plan                 InstallerPreludePlan
	dependencies               []FormulaDependencyPlan
	install_fetch_dependencies []FormulaDependencyPlan
}

pub struct FormulaConflict {
pub:
	name       string
	linked_keg bool
	opt_prefix bool
	available  bool = true
}

pub struct InstallerRequirement {
pub:
	name                               string
	message                            string
	fatal                              bool
	build                              bool
	test                               bool
	satisfied                          bool
	dependent                          api.PackageReference
	dependent_latest_version_installed bool
	macos_maximum                      bool
	runtime                            bool
	pruned_from_option                 bool
	dependent_is_build_dependency      bool
}

pub struct InstallerRequirementGroup {
pub:
	dependent    api.PackageReference
	requirements []InstallerRequirement
}

pub struct InstallerServiceDefinition {
pub:
	defined              bool
	systemd_service_path string
	systemd_service      string
	timed                bool
	systemd_timer_path   string
	systemd_timer        string
	launchd_service_path string
	launchd_service      string
	log_directory        string
}

pub struct PostInstallFormulaPathConfig {
pub:
	post_install_defined bool
	installed_prefix     string
	tap_formula_exists   bool
	tap_formula_version  string
	keg_formula_version  string
	formulae_readable    bool = true
}

pub struct FormulaInstallerAuditInput {
pub:
	bin_path_problem  string
	sbin_path_problem string
	cellar_problems   []string
}

pub type FormulaInstallerBuildHook = fn (Formula) !

pub type FormulaInstallerPostInstallHook = fn (string) !

pub type FormulaInstallerCleaner = fn (Formula) !

pub type FormulaInstallerLinkageFixer = fn (Keg) !

pub type FormulaInstallerLockHook = fn (string) !

pub struct InstallerPreludePlan {
pub:
	action   InstallerFetchAction
	warnings []string
}

pub struct InstallerBottleTabPlan {
pub:
	bottle   Bottle
	manifest BottleManifestPlan
	enqueue  bool
}

pub struct FormulaInstaller {
pub:
	formula                         api.PackageReference
	options                         []string
	link_keg                        bool
	installed_on_request            bool
	show_header                     bool
	build_bottle_value              bool
	skip_post_install_value         bool
	skip_link_value                 bool
	force_bottle_value              bool
	bottle_arch                     string
	ignore_deps_value               bool
	only_deps_value                 bool
	include_test_formulae           []string
	build_from_source_formulae      []string
	environment                     string
	git_value                       bool
	interactive_value               bool
	keep_tmp_value                  bool
	debug_symbols_value             bool
	compiler                        string
	force_value                     bool
	overwrite_value                 bool
	debug_value                     bool
	quiet_value                     bool
	verbose_value                   bool
	head                            bool
	pour_bottle_allowed             bool
	bottle_locations_compatible     bool
	local_bottle_path               string
	forbidden_formulae              []string
	forbidden_taps                  []string
	allowed_taps                    []string
	forbidden_licenses              []string
	forbidden_owner                 string
	forbidden_owner_contact         string
	link_overwrite_reason           string
	developer                       bool
	default_prefix                  bool
	integration_test                bool
	fresh_install                   bool
	pour_bottle_failure_reason      string
	prefix                          string
	cellar                          string
	temporary_cellar                string
	show_summary_heading            bool
	bottle_tab_runtime_dependencies map[string]map[string]string
}

fn auto_link_versioned_keg_only(formula api.PackageReference, config FormulaInstallerConfig) bool {
	return config.installed_on_request && formula.keg_only && config.keg_only_versioned && !config.any_version_installed && !config.related_formula_installed
}

pub fn new_formula_installer(formula api.PackageReference,
	config FormulaInstallerConfig) FormulaInstaller {
	link_keg := config.link_keg || !formula.keg_only || auto_link_versioned_keg_only(formula, config)
	return FormulaInstaller{
		formula: formula
		options: config.options.clone()
		link_keg: link_keg
		installed_on_request: config.installed_on_request
		show_header: config.show_header
		build_bottle_value: config.build_bottle
		skip_post_install_value: config.skip_post_install
		skip_link_value: config.skip_link
		force_bottle_value: config.force_bottle
		bottle_arch: config.bottle_arch
		ignore_deps_value: config.ignore_deps
		only_deps_value: config.only_deps
		include_test_formulae: config.include_test_formulae.clone()
		build_from_source_formulae: config.build_from_source_formulae.clone()
		environment: config.environment
		git_value: config.git
		interactive_value: config.interactive
		keep_tmp_value: config.keep_tmp
		debug_symbols_value: config.debug_symbols
		compiler: config.compiler
		force_value: config.force
		overwrite_value: config.overwrite
		debug_value: config.debug
		quiet_value: config.quiet
		verbose_value: config.verbose
		head: config.head
		pour_bottle_allowed: config.pour_bottle_allowed
		bottle_locations_compatible: config.bottle_locations_compatible
		local_bottle_path: config.local_bottle_path
		forbidden_formulae: config.forbidden_formulae.clone()
		forbidden_taps: config.forbidden_taps.clone()
		allowed_taps: config.allowed_taps.clone()
		forbidden_licenses: config.forbidden_licenses.clone()
		forbidden_owner: config.forbidden_owner
		forbidden_owner_contact: config.forbidden_owner_contact
		link_overwrite_reason: config.link_overwrite_reason
		developer: config.developer
		default_prefix: config.default_prefix
		integration_test: config.integration_test
		fresh_install: config.fresh_install
		pour_bottle_failure_reason: config.pour_bottle_failure_reason
		prefix: config.prefix
		cellar: config.cellar
		temporary_cellar: config.temporary_cellar
		bottle_tab_runtime_dependencies: map[string]map[string]string{}
	}
}

pub fn (installer FormulaInstaller) debug() bool {
	return installer.debug_value
}

pub fn (installer FormulaInstaller) debug_symbols() bool {
	return installer.debug_symbols_value
}

pub fn (installer FormulaInstaller) force() bool {
	return installer.force_value
}

pub fn (installer FormulaInstaller) force_bottle() bool {
	return installer.force_bottle_value
}

pub fn (installer FormulaInstaller) git() bool {
	return installer.git_value
}

pub fn (installer FormulaInstaller) ignore_deps() bool {
	return installer.ignore_deps_value
}

pub fn (installer FormulaInstaller) installed_on_request_value() bool {
	return installer.installed_on_request
}

pub fn (installer FormulaInstaller) interactive() bool {
	return installer.interactive_value
}

pub fn (installer FormulaInstaller) keep_tmp() bool {
	return installer.keep_tmp_value
}

pub fn (installer FormulaInstaller) only_deps() bool {
	return installer.only_deps_value
}

pub fn (installer FormulaInstaller) overwrite() bool {
	return installer.overwrite_value
}

pub fn (installer FormulaInstaller) quiet() bool {
	return installer.quiet_value
}

pub fn (installer FormulaInstaller) show_header_value() bool {
	return installer.show_header
}

pub fn (installer FormulaInstaller) show_summary_heading_value() bool {
	return installer.show_summary_heading
}

pub fn (installer FormulaInstaller) verbose() bool {
	return installer.verbose_value
}

pub fn (installer FormulaInstaller) build_from_source() bool {
	return installer.formula.full_name in installer.build_from_source_formulae
}

pub fn (installer FormulaInstaller) include_test() bool {
	return installer.formula.full_name in installer.include_test_formulae
}

pub fn (installer FormulaInstaller) build_bottle() bool {
	return installer.build_bottle_value
}

pub fn (installer FormulaInstaller) skip_post_install() bool {
	return installer.skip_post_install_value
}

pub fn (installer FormulaInstaller) skip_link() bool {
	return installer.skip_link_value
}

pub fn (installer FormulaInstaller) pour_bottle() bool {
	if !installer.formula.bottle_available && installer.local_bottle_path.len == 0 {
		return false
	}
	if installer.force_bottle() {
		return true
	}
	if installer.build_from_source() || installer.build_bottle() || installer.interactive() {
		return false
	}
	if installer.compiler.len > 0 || installer.options.len > 0 {
		return false
	}
	if !installer.pour_bottle_allowed {
		return false
	}
	if installer.local_bottle_path.len > 0 {
		return true
	}
	return installer.formula.bottle_tags.len > 0 && installer.bottle_locations_compatible
}

pub fn (installer FormulaInstaller) install_bottle_for(dependency api.PackageReference,
	build_used_options []string, dependency_pour_allowed bool,
	locations_compatible bool) bool {
	if dependency.full_name == installer.formula.full_name {
		return installer.pour_bottle()
	}
	return dependency.full_name !in installer.build_from_source_formulae && dependency.bottle_available && dependency_pour_allowed && build_used_options.len == 0 && locations_compatible
}

pub fn (installer FormulaInstaller) prelude_fetch_plan(metadata_only bool) !InstallerPreludePlan {
	mut warnings := []string{}
	if installer.formula.deprecated {
		warnings << '${installer.formula.full_name} has been deprecated'
	}
	if installer.formula.disabled {
		message := '${installer.formula.full_name} has been disabled'
		if installer.force() {
			warnings << message
		} else {
			return error(message)
		}
	}
	if installer.formula.name in installer.forbidden_formulae || installer.formula.full_name in installer.forbidden_formulae {
		return error('The installation of ${installer.formula.name} is forbidden.')
	}
	if installer.formula.tap in installer.forbidden_taps {
		return error('The installation of formulae from ${installer.formula.tap} is forbidden.')
	}
	if installer.pour_bottle() {
		return InstallerPreludePlan{
			action: .bottle_metadata
			warnings: warnings
		}
	}
	if !metadata_only && installer.formula.loaded_from_api {
		return InstallerPreludePlan{
			action: .source
			warnings: warnings
		}
	}
	return InstallerPreludePlan{
		warnings: warnings
	}
}

// fetch_bottle_tab_plan translates FormulaInstaller#fetch_bottle_tab through
// bottle selection and manifest preparation. DownloadQueue ownership remains
// at the caller boundary, matching the Ruby enqueue: branch.
pub fn (installer FormulaInstaller) fetch_bottle_tab_plan(enqueue bool) !InstallerBottleTabPlan {
	bottle := api_bottle_for_formula(installer.formula, current_bottle_tag())!
	manifest := bottle.github_packages_manifest_plan() or {
		return error('Bottle manifest metadata is unavailable for ${installer.formula.full_name}')
	}
	return InstallerBottleTabPlan{
		bottle: bottle
		manifest: manifest
		enqueue: enqueue
	}
}

fn dependency_reference(name string, config FormulaDependencyResolutionConfig) !api.PackageReference {
	if reference := config.references[name] {
		return reference
	}
	short_name := name.all_after_last('/')
	if reference := config.references[short_name] {
		return reference
	}
	return api.resolve_formula_reference(name, config.formula_lookup)
}

fn runtime_dependency_minimum(receipt RuntimeDependencyReceipt) !DependencyMinimum {
	mut version := null_version()
	if receipt.version != '' {
		version = new_version(receipt.version)!
	}
	return DependencyMinimum{
		has_version: receipt.version != ''
		version: version
		has_revision: receipt.has_revision
		revision: receipt.revision
		has_compatibility_version: receipt.has_compatibility_version
		compatibility_version: receipt.compatibility_version
	}
}

// bottle_runtime_dependencies translates the Tab runtime dependency metadata
// consumed by FormulaInstaller#expand_dependencies_for_formula. Bottle tabs
// contain the complete runtime closure and the minimum version/revision used
// to decide whether an installed keg still satisfies that dependency.
pub fn bottle_runtime_dependencies(attributes map[string]json2.Any) ![]RuntimeDependencyReceipt {
	if attributes.len == 0 {
		return []RuntimeDependencyReceipt{}
	}
	tab := tab_from_json(json2.encode(json2.Any(attributes)), 'bottle manifest tab')!
	return tab.runtime_dependencies() or { []RuntimeDependencyReceipt{} }
}

fn (installer FormulaInstaller) dependency_is_satisfied(plan FormulaDependencyPlan,
	config FormulaDependencyResolutionConfig) bool {
	if installation := config.installations[plan.formula.full_name] {
		return plan.dependency.satisfied_from(installation, plan.minimum)
	}
	if installation := config.installations[plan.formula.name] {
		return plan.dependency.satisfied_from(installation, plan.minimum)
	}
	if !config.check_installed {
		return false
	}
	formula := formula_from_reference(plan.formula, config.prefix, config.cellar) or {
		return false
	}
	return plan.dependency.satisfied_for_formula(formula, plan.minimum)
}

fn dependency_options_for(reference api.PackageReference) Options {
	mut flags := []string{}
	for name in reference.optional_dependencies {
		flags << '--with-${name.all_after_last('/')}'
	}
	for name in reference.recommended_dependencies {
		flags << '--without-${name.all_after_last('/')}'
	}
	return new_options(...flags)
}

// effective_build_options_for translates the source union/intersection for the
// API metadata adapter. API formulae do not carry build-used or installed Tab
// options, so the requested options are intersected with dependency switches
// declared by the selected formula.
pub fn (installer FormulaInstaller) effective_build_options_for(reference api.PackageReference) BuildOptions {
	requested := if reference.full_name == installer.formula.full_name {
		new_options(...installer.options)
	} else {
		new_options()
	}
	return new_build_options(requested, dependency_options_for(reference))
}

fn formula_reference_dependencies(reference api.PackageReference) []Dependency {
	mut dependencies := reference.dependencies.map(new_dependency(it, []string{}))
	dependencies << reference.build_dependencies.map(new_dependency(it, [':build']))
	dependencies << reference.test_dependencies.map(new_dependency(it, [':test']))
	dependencies << reference.recommended_dependencies.map(new_dependency(it, [
		':recommended',
	]))
	dependencies << reference.optional_dependencies.map(new_dependency(it, [
		':optional',
	]))
	return dependencies
}

fn (installer FormulaInstaller) keep_dependency(dependent api.PackageReference,
	dependency Dependency, build BuildOptions, config FormulaDependencyResolutionConfig) bool {
	if dependency.prune_from_option(build) {
		return false
	}
	if dependency.test() {
		return installer.include_test() && dependent.full_name in installer.include_test_formulae
	}
	if dependency.build() {
		mut latest_installed := false
		if config.check_installed {
			formula := formula_from_reference(dependent, config.prefix, config.cellar) or {
				return true
			}
			latest_installed = formula.latest_version_installed()
		}
		return !installer.install_bottle_for(dependent, build.used_options().as_flags(), true, true) && (installer.head || !latest_installed)
	}
	return true
}

fn (installer FormulaInstaller) expand_api_dependencies(dependent api.PackageReference,
	config FormulaDependencyResolutionConfig, minimums map[string]RuntimeDependencyReceipt,
	mut visiting map[string]bool, mut emitted map[string]bool,
	mut expanded []FormulaDependencyPlan) ! {
	if visiting[dependent.full_name] {
		return
	}
	visiting[dependent.full_name] = true
	build := installer.effective_build_options_for(dependent)
	for dependency in formula_reference_dependencies(dependent) {
		if !installer.keep_dependency(dependent, dependency, build, config) {
			continue
		}
		reference := dependency_reference(dependency.name, config)!
		receipt := minimums[dependency.name] or {
			minimums[reference.full_name] or { RuntimeDependencyReceipt{} }
		}
		minimum := runtime_dependency_minimum(receipt)!
		plan := FormulaDependencyPlan{
			dependency: dependency.duplicate_with_formula_name(reference.full_name)
			formula: reference
			minimum: minimum
			declared_directly: dependent.full_name == installer.formula.full_name
		}
		// Dependency::SKIP omits a satisfied dependency but still traverses its
		// recursive dependencies, matching Dependency.expand.
		installer.expand_api_dependencies(reference, config, minimums, mut visiting, mut emitted, mut expanded)!
		if !installer.dependency_is_satisfied(plan, config) && !emitted[reference.full_name] {
			expanded << plan
			emitted[reference.full_name] = true
		}
	}
	visiting.delete(dependent.full_name)
}

// compute_dependencies translates FormulaInstaller#compute_dependencies and
// expand_dependencies for typed API formula metadata. For bottles, the Tab's
// runtime dependency closure supplies source-faithful minimum versions. Older
// or non-bottle metadata falls back to recursive API dependency expansion.
pub fn (installer FormulaInstaller) compute_dependencies(attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	if installer.ignore_deps() {
		return []FormulaDependencyPlan{}
	}
	receipts := bottle_runtime_dependencies(attributes)!
	if receipts.len > 0 {
		mut plans := []FormulaDependencyPlan{cap: receipts.len}
		mut emitted := map[string]bool{}
		for receipt in receipts {
			if receipt.full_name == '' || emitted[receipt.full_name] {
				continue
			}
			reference := dependency_reference(receipt.full_name, config)!
			plan := FormulaDependencyPlan{
				dependency: new_dependency(reference.full_name, []string{})
				formula: reference
				minimum: runtime_dependency_minimum(receipt)!
				declared_directly: receipt.declared_directly
			}
			if !installer.dependency_is_satisfied(plan, config) {
				plans << plan
			}
			emitted[receipt.full_name] = true
		}
		return plans
	}
	mut minimums := map[string]RuntimeDependencyReceipt{}
	for receipt in receipts {
		minimums[receipt.full_name] = receipt
	}
	mut visiting := map[string]bool{}
	mut emitted := map[string]bool{}
	mut expanded := []FormulaDependencyPlan{}
	installer.expand_api_dependencies(installer.formula, config, minimums, mut visiting, mut emitted, mut expanded)!
	return expanded
}

// fetch_fetch_deps translates the early implicit-dependency branch. Only an
// implicit dependency triggers an early fetch and a subsequent uncached
// recomputation after that formula becomes available.
pub fn (installer FormulaInstaller) fetch_fetch_deps(computed []FormulaDependencyPlan) FormulaFetchDependenciesPlan {
	_ = installer
	if computed.len == 0 || !computed.any(it.dependency.implicit()) {
		return FormulaFetchDependenciesPlan{}
	}
	return FormulaFetchDependenciesPlan{
		dependencies: computed.clone()
		recompute: true
	}
}

pub fn (installer FormulaInstaller) fetch_dependencies(computed []FormulaDependencyPlan,
	previously_fetched []string) []FormulaDependencyPlan {
	if installer.ignore_deps() {
		return []FormulaDependencyPlan{}
	}
	return computed.filter(it.formula.full_name !in previously_fetched)
}

pub fn (installer FormulaInstaller) verify_bottle_attestation() bool {
	return environment_enabled('HOMEBREW_VERIFY_ATTESTATIONS') && !environment_enabled('HOMEBREW_NO_VERIFY_ATTESTATIONS') && installer.formula.core_tap && installer.formula.name != 'gh'
}

fn source_download_plan(reference api.PackageReference, stage bool) !InstallerDownloadPlan {
	if reference.source_url == '' {
		return error('Resource for ${reference.full_name} is unavailable.')
	}
	mut resource := new_formula_resource(reference.name)
	resource.set_owner(reference.full_name)
	resource.set_url(reference.source_url, map[string]string{})!
	if reference.stable_version != '' {
		resource.set_version(reference.stable_version)!
	}
	if reference.source_checksum != '' {
		resource.sha256(reference.source_checksum)
	}
	return InstallerDownloadPlan{
		formula: reference
		kind: .source
		stage: stage
		resource: resource
	}
}

// downloadable translates FormulaInstaller#downloadable for a typed formula
// reference, including local bottles, API bottles and formula source resources.
pub fn (installer FormulaInstaller) downloadable(reference api.PackageReference,
	stage bool) !InstallerDownloadPlan {
	is_main := reference.full_name == installer.formula.full_name
	if is_main && installer.local_bottle_path != '' {
		resource := new_local_resource(installer.local_bottle_path)!
		return InstallerDownloadPlan{
			formula: reference
			kind: .local
			stage: stage
			resource: resource
		}
	}
	use_bottle := if is_main {
		installer.pour_bottle()
	} else {
		installer.install_bottle_for(reference, []string{}, true, true)
	}
	if use_bottle {
		mut bottle := api_bottle_for_formula(reference, current_bottle_tag()) or {
			if is_main && installer.force_bottle() {
				return error('Bottle for ${reference.full_name} is unavailable.')
			}
			return source_download_plan(reference, stage)
		}
		resource := bottle.resource.duplicate()
		return InstallerDownloadPlan{
			formula: reference
			kind: .bottle
			check_attestation: installer.verify_bottle_attestation()
			stage: stage
			has_bottle: true
			bottle: bottle
			resource: resource
		}
	}
	return source_download_plan(reference, stage)
}

// fetch_dependency translates the child FormulaInstaller construction used by
// FormulaInstaller#fetch_dependencies. Dependency recursion is disabled after
// the parent has already computed the complete graph.
pub fn (installer FormulaInstaller) fetch_dependency(plan FormulaDependencyPlan) !InstallerDownloadPlan {
	child := new_formula_installer(plan.formula, FormulaInstallerConfig{
		force_bottle: false
		ignore_deps: !installer.pour_bottle()
		include_test_formulae: installer.include_test_formulae
		build_from_source_formulae: installer.build_from_source_formulae
		keep_tmp: installer.keep_tmp()
		debug_symbols: installer.debug_symbols()
		force: installer.force()
		debug: installer.debug()
		quiet: installer.quiet()
		verbose: installer.verbose()
		prefix: installer.prefix
		cellar: installer.cellar
		temporary_cellar: installer.temporary_cellar
	})
	return child.downloadable(plan.formula, true)
}

// enqueue_bottle_download translates the source's early main-bottle enqueue
// decision. Queue ownership remains with the caller so all resource pointers
// can be made stable before enqueueing begins.
pub fn (installer FormulaInstaller) enqueue_bottle_download(stage bool) !InstallerDownloadPlan {
	if installer.only_deps() || installer.local_bottle_path != '' || !installer.pour_bottle() {
		return error('Bottle download is not enqueueable for ${installer.formula.full_name}')
	}
	return installer.downloadable(installer.formula, stage)!
}

// enqueue_fetch translates dependency and own-download selection after the
// prelude. The early main bottle is retained first, as in the Ruby queue.
pub fn (installer FormulaInstaller) enqueue_fetch(dependencies []FormulaDependencyPlan) ![]InstallerDownloadPlan {
	mut downloads := []InstallerDownloadPlan{cap: dependencies.len + 1}
	if !installer.only_deps() && installer.local_bottle_path == '' && installer.pour_bottle() {
		downloads << installer.enqueue_bottle_download(true)!
	}
	for dependency in dependencies {
		downloads << installer.fetch_dependency(dependency)!
	}
	if !installer.only_deps() && !installer.pour_bottle() && installer.local_bottle_path == '' {
		downloads << installer.downloadable(installer.formula, false)!
	}
	return downloads
}

// fetch_downloads performs the DownloadQueue half of FormulaInstaller#fetch.
// The slice must be complete before this function is called because the queue
// stores pointers to its Resource elements.
pub fn fetch_downloads(mut downloads []InstallerDownloadPlan, mut queue DownloadQueue,
	heading ?string) ! {
	for mut download in downloads {
		queue.enqueue(mut download.resource, download.check_attestation, download.stage)!
	}
	queue.fetch(none, heading, false)!
	for mut download in downloads {
		path := download.resource.cached_download()!
		download.resource.verify_download_integrity(path)!
	}
}

// stage_bottle_downloads completes DownloadQueue's Bottle specialization after
// the serial queue has verified each archive. Source resources remain staged by
// Formula#install, while poured bottles use the temporary-cellar marker path.
pub fn stage_bottle_downloads(mut downloads []InstallerDownloadPlan) ![]string {
	temporary_cellar_value := ruby.environment_value('HOMEBREW_TEMP_CELLAR')
	temporary_cellar := if temporary_cellar_value != '' {
		temporary_cellar_value
	} else {
		'/tmp/homebrew/Cellar'
	}
	return stage_bottle_downloads_in(mut downloads, temporary_cellar)
}

pub fn stage_bottle_downloads_in(mut downloads []InstallerDownloadPlan,
	temporary_cellar string) ![]string {
	mut staged := []string{}
	for mut download in downloads {
		if download.kind != .bottle || !download.stage || !download.has_bottle {
			continue
		}
		path := download.resource.cached_download()!
		download.staged_path = download.bottle.stage_from_download_queue_in(path, true, temporary_cellar)!
		download.stage_marker = '${download.staged_path}.poured'
		staged << download.staged_path
	}
	return staged
}

fn (installer FormulaInstaller) configured_install_locations() !(string, string, string) {
	prefix := if installer.prefix != '' {
		installer.prefix.trim_right('/')
	} else {
		ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	}
	if prefix == '' {
		return error('HOMEBREW_PREFIX is required to install ${installer.formula.full_name}')
	}
	cellar := if installer.cellar != '' {
		installer.cellar.trim_right('/')
	} else {
		configured := ruby.environment_value('HOMEBREW_CELLAR').trim_right('/')
		if configured != '' { configured } else { os.join_path(prefix, 'Cellar') }
	}
	temporary_cellar := if installer.temporary_cellar != '' {
		installer.temporary_cellar.trim_right('/')
	} else {
		configured := ruby.environment_value('HOMEBREW_TEMP_CELLAR').trim_right('/')
		if configured != '' { configured } else { '/tmp/homebrew/Cellar' }
	}
	return prefix, cellar, temporary_cellar
}

// bottle_tab_attributes_for completes the Bottle#fetch_tab side of
// FormulaInstaller#prelude for dependencies whose manifest was not part of the
// parent queue. The downloaded OCI annotation is the source of the receipt and
// selective relocation metadata used by #pour.
pub fn (installer FormulaInstaller) bottle_tab_attributes_for(mut download InstallerDownloadPlan) !map[string]json2.Any {
	if download.kind != .bottle || !download.has_bottle {
		return error('Bottle metadata is unavailable for ${download.formula.full_name}')
	}
	if download.bottle.tab_attributes().len == 0 {
		download.bottle.fetch_tab(none, installer.quiet())!
	}
	return download.bottle.tab_attributes()
}

fn poured_tab_for_formula(formula Formula, attributes map[string]json2.Any,
	installed_on_request bool, receipt string) !Tab {
	mut tab := if attributes.len == 0 {
		empty_tab()
	} else {
		tab_from_json(json2.encode(json2.Any(attributes)), receipt)!
	}
	tab.tabfile = receipt
	tab.used_option_flags = []string{}
	tab.unused_option_flags = []string{}
	tab.built_as_bottle = true
	tab.has_built_as_bottle = true
	tab.poured_from_bottle = true
	tab.has_poured_from_bottle = true
	tab.loaded_from_api = formula.loaded_from_api()
	tab.has_loaded_from_api = true
	tab.loaded_from_internal_api = false
	tab.has_loaded_from_internal_api = true
	tab.installed_on_request = installed_on_request
	tab.installed_on_request_present = true
	tab.time = time.now().unix()
	tab.has_time = true
	tab.aliases = formula.aliases()
	tab.has_aliases = true
	tab.arch = current_bottle_tag().standardized_arch()
	tab.has_arch = true
	mut versions := tab.versions()
	versions['stable'] = if formula.reference.stable_version == '' {
		json2.null
	} else {
		json2.Any(formula.reference.stable_version)
	}
	versions['version_scheme'] = json2.Any(formula.reference.version_scheme)
	tab.source['versions'] = json2.Any(versions)
	tab.source['spec'] = json2.Any(formula.active_spec)
	tab.source['path'] = json2.Any(formula.specified_path())
	tab.set_tap(formula.tap)
	return tab
}

fn remove_pour_marker(path string) ! {
	if os.is_link(path) || os.is_file(path) {
		os.rm(path)!
	}
}

fn remove_empty_staging_rack(path string) {
	if os.is_dir(path) && (os.ls(path) or { []string{} }).len == 0 {
		os.rmdir(path) or {}
	}
}

// pour_download_with_tab translates FormulaInstaller#pour for an already
// fetched Bottle. It consumes the download-queue marker, moves the staged keg
// into the configured Cellar, writes INSTALL_RECEIPT.json, and performs the
// placeholder relocation described by the bottle manifest.
pub fn (installer FormulaInstaller) pour_download_with_tab(mut download InstallerDownloadPlan,
	attributes map[string]json2.Any) !FormulaPourResult {
	if download.kind != .bottle || !download.has_bottle {
		return error('unimplemented Ruby function `FormulaInstaller#pour` for non-bottle resource `${download.formula.full_name}`')
	}
	prefix, cellar, temporary_cellar := installer.configured_install_locations()!
	formula := formula_from_reference(download.formula, prefix, cellar)!
	version := formula.pkg_version()!
	target := formula.versioned_prefix(version)
	if ruby.path_exists(target) || os.is_link(target) {
		return error('${formula.full_name()} ${version.to_s()} is already installed')
	}
	mut staged_path := download.staged_path
	if staged_path == '' {
		cached := download.resource.cached_download()!
		staged_path = download.bottle.stage_from_download_queue_in(cached, true, temporary_cellar)!
		download.staged_path = staged_path
		download.stage_marker = '${staged_path}.poured'
	}
	if !ruby.is_dir(staged_path) {
		return error('Staged bottle keg does not exist: ${staged_path}')
	}
	if ruby.real_path(staged_path) == ruby.real_path(target) {
		return error('Bottle staging path must differ from its Cellar destination: ${target}')
	}
	marker := if download.stage_marker != '' {
		download.stage_marker
	} else {
		'${staged_path}.poured'
	}
	remove_pour_marker(marker)!
	os.mkdir_all(formula.rack())!
	os.mv(staged_path, target)!
	remove_empty_staging_rack(os.dir(staged_path))

	mut keg := new_keg_with_paths(target, cellar, prefix)!
	receipt := keg.join(tab_filename)
	mut tab := poured_tab_for_formula(formula, attributes, installer.installed_on_request, receipt)!
	tab.write()!

	repository_value := ruby.environment_value('HOMEBREW_REPOSITORY')
	repository := if repository_value != '' { repository_value } else { prefix }
	library_value := ruby.environment_value('HOMEBREW_LIBRARY_PATH')
	library := if library_value != '' {
		library_value
	} else {
		os.join_path(repository, 'Library')
	}
	location_context := BottleLocationContext{
		prefix: prefix
		cellar: cellar
		linux: current_bottle_tag().linux()
		tab_homebrew_version: tab.homebrew_version
	}
	skip_linkage := download.bottle.skip_relocation(location_context)
	relocation := prepare_keg_relocation_to_locations(prefix, cellar, repository, library)
	mut changed_files := []string{}
	if !skip_linkage {
		changed_files << keg.relocate_dynamic_linkage(relocation)!
	}
	if tab.has_changed_files {
		if tab.changed_files.len > 0 {
			changed_files << keg.replace_text_in_files(relocation, tab.changed_files)!
		}
	} else {
		changed_files << keg.replace_text_in_files(relocation, []string{})!
	}
	return FormulaPourResult{
		formula: formula
		keg: keg
		tab: tab
		changed_files: changed_files
	}
}

pub fn (installer FormulaInstaller) pour_download(mut download InstallerDownloadPlan) !FormulaPourResult {
	attributes := installer.bottle_tab_attributes_for(mut download)!
	return installer.pour_download_with_tab(mut download, attributes)
}

// dependency_installer translates the child FormulaInstaller created by
// FormulaInstaller#install_dependency. The parent has already expanded the
// complete dependency graph, so this child only pours and finishes its bottle.
fn (installer FormulaInstaller) dependency_installer(reference api.PackageReference) FormulaInstaller {
	return new_formula_installer(reference, FormulaInstallerConfig{
		installed_on_request: false
		force_bottle: installer.force_bottle()
		ignore_deps: true
		include_test_formulae: installer.include_test_formulae
		build_from_source_formulae: installer.build_from_source_formulae
		keep_tmp: installer.keep_tmp()
		debug_symbols: installer.debug_symbols()
		force: installer.force()
		overwrite: installer.overwrite()
		debug: installer.debug()
		quiet: installer.quiet()
		verbose: installer.verbose()
		skip_post_install: installer.skip_post_install()
		skip_link: installer.skip_link()
		pour_bottle_allowed: installer.pour_bottle_allowed
		bottle_locations_compatible: installer.bottle_locations_compatible
		prefix: installer.prefix
		cellar: installer.cellar
		temporary_cellar: installer.temporary_cellar
	})
}

// install_poured_downloads translates the dependency-first install loop after
// FormulaInstaller#fetch. enqueue_fetch retains the main formula at index zero,
// while its remaining entries are in dependency postorder, so dependencies are
// poured and linked before the requested formula. Source downloads deliberately
// retain their exact Formula#install boundary.
pub fn (installer FormulaInstaller) install_poured_downloads(mut downloads []InstallerDownloadPlan,
	root_attributes map[string]json2.Any) ![]FormulaBottleInstallResult {
	mut installed := []FormulaBottleInstallResult{}
	mut main_index := -1
	for index, download in downloads {
		if download.formula.full_name == installer.formula.full_name {
			main_index = index
			continue
		}
		if download.kind != .bottle || !download.has_bottle {
			return error('unimplemented Ruby function `FormulaInstaller#install` at source dependency boundary for: ${download.formula.full_name}')
		}
		child := installer.dependency_installer(download.formula)
		mut dependency_download := downloads[index]
		poured := child.pour_download(mut dependency_download)!
		finished := child.finish_poured(poured)!
		installed << FormulaBottleInstallResult{
			formula: download.formula.full_name
			finish: finished
		}
	}
	if installer.only_deps() {
		return installed
	}
	if main_index < 0 {
		return error('Downloaded bottle for ${installer.formula.full_name} is missing')
	}
	mut main_download := downloads[main_index]
	if main_download.kind != .bottle || !main_download.has_bottle {
		return error('unimplemented Ruby function `Formula#install` at formula source boundary for: ${installer.formula.full_name}')
	}
	poured := installer.pour_download_with_tab(mut main_download, root_attributes)!
	finished := installer.finish_poured(poured)!
	installed << FormulaBottleInstallResult{
		formula: installer.formula.full_name
		finish: finished
	}
	return installed
}

fn keg_installed_completions(keg Keg) []string {
	mut installed := []string{}
	for shell in ['bash', 'fish', 'zsh', 'pwsh'] {
		if keg.completion_installed(shell) {
			installed << shell
		}
	}
	if keg.functions_installed('fish') {
		installed << 'fish functions'
	}
	if keg.functions_installed('zsh') {
		installed << 'zsh functions'
	}
	if keg.elisp_installed() {
		installed << 'Emacs Lisp'
	}
	return installed
}

fn keg_primary_executable(keg Keg, formula Formula) string {
	preferred := keg.join('bin', formula.name())
	if ruby.is_file(preferred) {
		return preferred
	}
	bin := keg.join('bin')
	mut entries := ruby.list_dir(bin) or { return '' }
	entries.sort()
	for entry in entries {
		path := ruby.join_path(bin, entry)
		if ruby.is_file(path) {
			return path
		}
	}
	return ''
}

// finish_poured translates the bottle-relevant half of
// FormulaInstaller#finish: create opt and prefix links, retain the manifest's
// runtime-dependency receipt, collect completion state, and render the summary.
pub fn (installer FormulaInstaller) finish_poured(result FormulaPourResult) !FormulaFinishResult {
	if installer.only_deps() {
		return FormulaFinishResult{}
	}
	mut linked := false
	if !installer.link_keg || installer.skip_link() {
		result.keg.optlink(false, installer.overwrite())!
	} else {
		if result.keg.linked() {
			result.keg.remove_linked_keg_record()!
		}
		result.keg.link(false, installer.overwrite())!
		linked = result.keg.linked()
	}
	result.keg.remove_oldname_opt_records()!
	return FormulaFinishResult{
		summary: '${ruby.real_path(result.keg.path)}: ${result.keg.abbreviated_size()}'
		linked: linked
		optlinked: result.keg.optlinked()
		completions: keg_installed_completions(result.keg)
		executable: keg_primary_executable(result.keg, result.formula)
	}
}

pub fn (installer FormulaInstaller) sanitized_argv_options() []string {
	mut arguments := []string{}
	if installer.ignore_deps() {
		arguments << '--ignore-dependencies'
	}
	if installer.build_bottle() {
		arguments << '--build-bottle'
		if installer.bottle_arch.len > 0 {
			arguments << '--bottle-arch=${installer.bottle_arch}'
		}
	}
	if installer.git() {
		arguments << '--git'
	}
	if installer.interactive() {
		arguments << '--interactive'
	}
	if installer.verbose() {
		arguments << '--verbose'
	}
	if installer.debug() {
		arguments << '--debug'
	}
	if installer.compiler.len > 0 {
		arguments << '--cc=${installer.compiler}'
	}
	if installer.keep_tmp() {
		arguments << '--keep-tmp'
	}
	if installer.debug_symbols() {
		arguments << '--debug-symbols'
		arguments << '--build-from-source'
	}
	if installer.environment.len > 0 {
		arguments << '--env=${installer.environment}'
	}
	if installer.head {
		arguments << '--HEAD'
	}
	return arguments
}

pub fn (installer FormulaInstaller) build_argv() []string {
	mut arguments := installer.sanitized_argv_options()
	arguments << installer.options
	return arguments
}

fn installer_identity(reference api.PackageReference, active_spec string) FormulaInstallerIdentity {
	return FormulaInstallerIdentity{
		full_name: reference.full_name
		active_spec: active_spec
	}
}

fn installer_identity_in(values []FormulaInstallerIdentity, identity FormulaInstallerIdentity) bool {
	return values.any(it.full_name == identity.full_name && it.active_spec == identity.active_spec)
}

fn append_installer_identity(mut values []FormulaInstallerIdentity,
	identity FormulaInstallerIdentity) {
	if !installer_identity_in(values, identity) {
		values << identity
	}
}

pub fn (mut state FormulaInstallerClassState) show_missing_bottle_metadata_warning() bool {
	if state.missing_bottle_metadata_warning_shown {
		return false
	}
	state.missing_bottle_metadata_warning_shown = true
	return true
}

pub fn (mut state FormulaInstallerClassState) record_attempted(reference api.PackageReference,
	active_spec string) {
	append_installer_identity(mut state.attempted, installer_identity(reference, active_spec))
}

pub fn (mut state FormulaInstallerClassState) record_installed(reference api.PackageReference,
	active_spec string) {
	append_installer_identity(mut state.installed, installer_identity(reference, active_spec))
}

pub fn (mut state FormulaInstallerClassState) record_fetched(reference api.PackageReference,
	active_spec string) {
	append_installer_identity(mut state.fetched, installer_identity(reference, active_spec))
}

pub fn determine_bottle_tab_attributes(attributes map[string]json2.Any) !(map[string]map[string]string, string) {
	if attributes.len == 0 {
		return map[string]map[string]string{}, ''
	}
	tab := tab_from_json(json2.encode(json2.Any(attributes)), 'bottle manifest tab')!
	mut dependencies := map[string]map[string]string{}
	for dependency in tab.runtime_dependency_entries {
		mut entry := map[string]string{}
		entry['full_name'] = dependency.full_name
		entry['version'] = dependency.version
		if dependency.has_revision {
			entry['revision'] = dependency.revision.str()
		}
		if dependency.has_bottle_rebuild {
			entry['bottle_rebuild'] = dependency.bottle_rebuild.str()
		}
		if dependency.has_compatibility_version {
			entry['compatibility_version'] = dependency.compatibility_version.str()
		}
		entry['declared_directly'] = dependency.declared_directly.str()
		dependencies[dependency.full_name] = entry.clone()
	}
	built_os := (tab.built_on['os_version'] or { json2.Any('') }).str()
	return dependencies, built_os
}

pub fn (installer FormulaInstaller) verify_deps_exist(attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	return installer.compute_dependencies(attributes, config) or {
		return error('${installer.formula.full_name}: ${err.msg()}')
	}
}

fn dependency_graph_reaches(name string, target string,
	config FormulaDependencyResolutionConfig, mut visiting map[string]bool) bool {
	if name == target || name.all_after_last('/') == target.all_after_last('/') {
		return true
	}
	if visiting[name] {
		return false
	}
	visiting[name] = true
	reference := config.references[name] or {
		config.references[name.all_after_last('/')] or {
			visiting.delete(name)
			return false
		}
	}
	for dependency in formula_reference_dependencies(reference) {
		if dependency_graph_reaches(dependency.name, target, config, mut visiting) {
			visiting.delete(name)
			return true
		}
	}
	visiting.delete(name)
	return false
}

pub fn (installer FormulaInstaller) check_installation_already_attempted(
	class_state FormulaInstallerClassState) ! {
	identity := installer_identity(installer.formula, if installer.head { 'head' } else { 'stable' })
	if installer_identity_in(class_state.attempted, identity) {
		return error('Formula installation already attempted: ${installer.formula.full_name}')
	}
}

pub fn (installer FormulaInstaller) check_install_sanity(config FormulaDependencyResolutionConfig,
	class_state FormulaInstallerClassState) ! {
	installer.check_installation_already_attempted(class_state)!
	if installer.force_bottle() && !installer.pour_bottle() {
		return error('`--force-bottle` passed but ${installer.formula.full_name} has no bottle!')
	}
	if installer.default_prefix && !installer.build_from_source() && !installer.build_bottle() && !installer.head && installer.formula.core_tap && !installer.integration_test && !installer.pour_bottle() && (installer.pour_bottle_failure_reason != '' || installer.fresh_install) {
		reason := if installer.pour_bottle_failure_reason != '' {
			installer.pour_bottle_failure_reason
		} else {
			'no bottle available!'
		}
		return error("${installer.formula.full_name}: ${reason}\nIf you're feeling brave, you can try to install from source with:\n  brew install --build-from-source ${installer.formula.full_name}\n\nThis is a Tier 3 configuration:\n  https://docs.brew.sh/Support-Tiers#tier-3\nDo not report any issues to Homebrew/* repositories!")
	}
	if installer.ignore_deps() {
		return
	}
	if installer.developer {
		for dependency in formula_reference_dependencies(installer.formula) {
			if dependency.name == installer.formula.name || dependency.name == installer.formula.full_name {
				return error('${installer.formula.full_name} contains a recursive dependency on itself:\n  ${installer.formula.full_name} depends on itself directly')
			}
			mut visiting := map[string]bool{}
			if dependency_graph_reaches(dependency.name, installer.formula.full_name, config, mut visiting) {
				return error('${installer.formula.full_name} contains a recursive dependency on itself:\n  ${installer.formula.full_name} depends on itself via ${dependency.name}')
			}
		}
	}
	current_arch := if config.current_arch != '' {
		config.current_arch
	} else {
		current_bottle_tag().standardized_arch()
	}
	mut invalid_arch := []string{}
	mut pinned := []string{}
	for dependency in config.sanity {
		if dependency.receipt_arch != '' && dependency.receipt_arch != current_arch {
			invalid_arch << '${dependency.name} was built for ${dependency.receipt_arch}'
		}
		if dependency.pinned && !dependency.satisfied {
			pinned << dependency.name
		}
	}
	if invalid_arch.len > 0 {
		return error('${installer.formula.full_name} dependencies not built for the ${current_arch} CPU architecture:\n  ${invalid_arch.join('\n  ')}')
	}
	if pinned.len > 0 {
		return error('You must `brew unpin ${pinned.join(' ')}` as installing ${installer.formula.full_name} requires the latest version of pinned dependencies.')
	}
}

pub fn (installer FormulaInstaller) install_fetch_deps(computed []FormulaDependencyPlan) []FormulaDependencyPlan {
	if installer.ignore_deps() || computed.len == 0 || !computed.any(it.dependency.implicit()) {
		return []FormulaDependencyPlan{}
	}
	return computed.clone()
}

fn installer_find_paths(path string, mut paths []string) {
	if !ruby.path_exists(path) && !os.is_link(path) {
		return
	}
	paths << path
	if !ruby.is_dir(path) || os.is_link(path) {
		return
	}
	mut children := ruby.list_dir(path) or { return }
	children.sort()
	for child in children {
		installer_find_paths(os.join_path(path, child), mut paths)
	}
}

pub fn build_bottle_preinstall(prefix string) []string {
	mut paths := []string{}
	for directory in [os.join_path(prefix, 'etc'), os.join_path(prefix, 'var')] {
		installer_find_paths(directory, mut paths)
	}
	return paths
}

fn copy_bottle_path(source string, destination string) ! {
	if os.is_link(source) {
		os.mkdir_all(os.dir(destination))!
		if ruby.path_exists(destination) || os.is_link(destination) {
			os.rm(destination)!
		}
		os.symlink(os.readlink(source)!, destination)!
	} else if ruby.is_dir(source) {
		os.mkdir_all(destination)!
	} else {
		os.mkdir_all(os.dir(destination))!
		os.cp(source, destination)!
	}
}

pub fn build_bottle_postinstall(prefix string, bottle_prefix string,
	preinstall []string) ![]string {
	postinstall := build_bottle_preinstall(prefix)
	mut copied := []string{}
	for path in postinstall {
		if path in preinstall {
			continue
		}
		relative := path.trim_string_left(prefix).trim_left('/')
		destination := os.join_path(bottle_prefix, relative)
		copy_bottle_path(path, destination)!
		copied << destination
	}
	return copied
}

pub fn (installer FormulaInstaller) check_conflicts(conflicts []FormulaConflict) ! {
	if installer.force() || installer.skip_link() || !installer.link_keg {
		return
	}
	mut found := []string{}
	for conflict in conflicts {
		if conflict.name == installer.formula.name || conflict.name == installer.formula.full_name {
			continue
		}
		if conflict.available && conflict.linked_keg && conflict.opt_prefix {
			found << conflict.name
		}
	}
	if found.len > 0 {
		return error('${installer.formula.full_name} conflicts with ${found.join(', ')}')
	}
}

pub fn (installer FormulaInstaller) unbottled_dependencies(
	dependencies []FormulaDependencyPlan) []api.PackageReference {
	mut unbottled := []api.PackageReference{}
	for dependency in dependencies {
		if !dependency.formula.bottle_available || dependency.formula.bottle_tags.len == 0 {
			unbottled << dependency.formula
		}
	}
	return unbottled
}

pub fn check_installer_requirements(groups []InstallerRequirementGroup,
	mut state FormulaInstallerState) ! {
	state.requirement_messages.clear()
	mut fatals := []string{}
	for group in groups {
		for requirement in group.requirements {
			if requirement.dependent_latest_version_installed && requirement.macos_maximum {
				continue
			}
			state.requirement_messages << '${group.dependent.full_name}: ${requirement.message}'
			if requirement.fatal {
				fatals << requirement.name
			}
		}
	}
	if fatals.len > 0 {
		return error('Unsatisfied requirements: ${fatals.join(', ')}')
	}
}

pub fn runtime_installer_requirements(recursive []InstallerRequirement,
	direct []InstallerRequirement) []InstallerRequirement {
	mut result := []InstallerRequirement{}
	mut names := []string{}
	mut combined := recursive.clone()
	combined << direct
	for requirement in combined {
		if requirement.build || requirement.name in names {
			continue
		}
		result << requirement
		names << requirement.name
	}
	return result
}

pub fn (installer FormulaInstaller) expand_installer_requirements(
	groups []InstallerRequirementGroup) []InstallerRequirementGroup {
	mut result := []InstallerRequirementGroup{}
	for group in groups {
		mut requirements := []InstallerRequirement{}
		for requirement in group.requirements {
			keep_build_test := requirement.runtime || (!requirement.build && !requirement.test) || (requirement.test && installer.include_test() && requirement.dependent.full_name == group.dependent.full_name) || (requirement.build && !installer.install_bottle_for(requirement.dependent, []string{}, true, true) && !requirement.dependent_latest_version_installed)
			if !requirement.pruned_from_option && !requirement.dependent_is_build_dependency && !requirement.satisfied && keep_build_test && !(installer.only_deps() && group.dependent.full_name == installer.formula.full_name) {
				requirements << requirement
			}
		}
		if requirements.len > 0 {
			result << InstallerRequirementGroup{
				dependent: group.dependent
				requirements: requirements
			}
		}
	}
	return result
}

pub fn (installer FormulaInstaller) display_options(reference api.PackageReference) []string {
	mut displayed := []string{}
	if installer.head || (reference.head_version != '' && reference.stable_version == '') {
		displayed << '--HEAD'
	}
	displayed << installer.effective_build_options_for(reference).used_options().as_flags()
	return displayed
}

pub fn (installer FormulaInstaller) link_manual_command_warning() ?string {
	if !installer.installed_on_request || !installer.formula.keg_only || installer.link_keg || installer.link_overwrite_reason.trim_space() == '' {
		return none
	}
	return '${installer.formula.full_name} was installed but not linked because ${installer.link_overwrite_reason}.\nTo link this version, run:\n  brew link ${installer.formula.full_name}\n'
}

pub fn (mut state FormulaInstallerState) build_time(interactive bool) ?f64 {
	if interactive {
		return none
	}
	if state.has_build_time {
		return state.build_time_seconds
	}
	if !state.has_start_time {
		return none
	}
	state.build_time_seconds = f64(time.now().unix_milli() - state.start_time_millisecond) / 1000.0
	state.has_build_time = true
	return state.build_time_seconds
}

pub fn (installer FormulaInstaller) build(mut state FormulaInstallerState,
	hook FormulaInstallerBuildHook) ! {
	state.start_time_millisecond = time.now().unix_milli()
	state.has_start_time = true
	formula := formula_from_reference(installer.formula, installer.prefix, installer.cellar)!
	hook(formula) or {
		if ruby.is_dir(formula.prefix()) {
			os.rmdir_all(formula.prefix()) or {}
		}
		return error(err.msg())
	}
	if !ruby.is_dir(formula.prefix()) {
		return error('Empty installation')
	}
	keg := new_keg_with_paths(formula.prefix(), formula.cellar, formula.prefix_root)!
	if keg.empty_installation() {
		return error('Empty installation')
	}
}

fn atomic_write_installer_file(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	temporary := '${path}.brew-v-${os.getpid()}'
	os.write_file(temporary, contents)!
	os.chmod(temporary, 0o644)!
	os.mv(temporary, path)!
}

pub fn install_formula_service(definition InstallerServiceDefinition) ![]string {
	if !definition.defined {
		return []string{}
	}
	mut installed := []string{}
	if definition.systemd_service != '' && definition.systemd_service_path != '' {
		atomic_write_installer_file(definition.systemd_service_path, definition.systemd_service)!
		installed << definition.systemd_service_path
	}
	if definition.timed && definition.systemd_timer != '' && definition.systemd_timer_path != '' {
		atomic_write_installer_file(definition.systemd_timer_path, definition.systemd_timer)!
		installed << definition.systemd_timer_path
	}
	if definition.launchd_service != '' && definition.launchd_service_path != '' {
		atomic_write_installer_file(definition.launchd_service_path, definition.launchd_service)!
		installed << definition.launchd_service_path
		if definition.log_directory != '' && definition.launchd_service.contains(definition.log_directory) {
			os.mkdir_all(definition.log_directory)!
		}
	}
	return installed
}

pub fn fix_formula_dynamic_linkage(keg Keg, fixer FormulaInstallerLinkageFixer,
	mut state FormulaInstallerState) ?string {
	fixer(keg) or {
		state.show_summary_heading = true
		return 'Failed to fix install linkage\n${err.msg()}\nThe formula built, but you may encounter issues using it or linking other formulae against it.'
	}
	return none
}

pub fn (installer FormulaInstaller) clean(cleaner FormulaInstallerCleaner,
	mut state FormulaInstallerState) ?string {
	formula := formula_from_reference(installer.formula, installer.prefix, installer.cellar) or {
		state.show_summary_heading = true
		return err.msg()
	}
	cleaner(formula) or {
		state.show_summary_heading = true
		return 'The cleaning step did not complete successfully\nStill, the installation was successful, so we will link it into your prefix.\n${err.msg()}'
	}
	return none
}

pub fn (installer FormulaInstaller) post_install_formula_path(
	config PostInstallFormulaPathConfig) !string {
	formula := formula_from_reference(installer.formula, installer.prefix, installer.cellar)!
	tap_formula_path := formula.specified_path()
	installed_prefix := if config.installed_prefix != '' {
		config.installed_prefix
	} else {
		formula.any_installed_prefix() or { return tap_formula_path }
	}
	keg_formula_path := os.join_path(installed_prefix, '.brew', '${formula.name()}.rb')
	if formula.loaded_from_api() {
		return if config.post_install_defined { keg_formula_path } else { formula.full_name() }
	}
	if installer.local_bottle_path != '' || installer.build_from_source() {
		return keg_formula_path
	}
	if !config.tap_formula_exists {
		return keg_formula_path
	}
	if !config.formulae_readable {
		return tap_formula_path
	}
	if config.keg_formula_version != config.tap_formula_version {
		return keg_formula_path
	}
	return tap_formula_path
}

pub fn (installer FormulaInstaller) post_install(config PostInstallFormulaPathConfig,
	hook FormulaInstallerPostInstallHook, mut state FormulaInstallerState) ?string {
	path := installer.post_install_formula_path(config) or {
		state.show_summary_heading = true
		return err.msg()
	}
	hook(path) or {
		state.show_summary_heading = true
		return 'The post-install step did not complete successfully\nYou can try again using:\n  brew postinstall ${installer.formula.full_name}\n${err.msg()}'
	}
	return none
}

pub fn (installer FormulaInstaller) previously_fetched_formula(
	class_state FormulaInstallerClassState) ?FormulaInstallerIdentity {
	active_spec := if installer.head { 'head' } else { 'stable' }
	for identity in class_state.fetched {
		if identity.full_name == installer.formula.full_name && identity.active_spec == active_spec {
			return identity
		}
	}
	return none
}

pub fn problem_if_installer_output(output ?string, mut state FormulaInstallerState) ?string {
	if value := output {
		state.show_summary_heading = true
		return value
	}
	return none
}

pub fn (installer FormulaInstaller) audit_installed(input FormulaInstallerAuditInput,
	mut state FormulaInstallerState) []string {
	mut problems := []string{}
	if !installer.formula.keg_only {
		if problem := problem_if_installer_output(if input.bin_path_problem == '' {
			none
		} else {
			input.bin_path_problem
		}, mut state) {
			problems << problem
		}
		if problem := problem_if_installer_output(if input.sbin_path_problem == '' {
			none
		} else {
			input.sbin_path_problem
		}, mut state) {
			problems << problem
		}
	}
	for problem in input.cellar_problems {
		if recorded := problem_if_installer_output(problem, mut state) {
			problems << recorded
		}
	}
	return problems
}

fn installer_policy_owner(installer FormulaInstaller) string {
	return if installer.forbidden_owner == '' {
		'your system administrator'
	} else {
		installer.forbidden_owner
	}
}

fn installer_policy_contact(installer FormulaInstaller) string {
	return if installer.forbidden_owner_contact == '' {
		''
	} else {
		'\n${installer.forbidden_owner_contact}'
	}
}

struct InstallerSpdxPolicy {
	forbidden map[string]spdx.SpdxLicenseVersionInfo
	invalid   []string
}

fn installer_spdx_token(value string) spdx.SpdxLicenseToken {
	trimmed := value.trim_space()
	symbol := trimmed.trim_string_left(':').to_lower().replace(' ', '_')
	if symbol in spdx.spdx_allowed_license_symbols {
		return spdx.spdx_symbol_token(symbol)
	}
	return spdx.spdx_license_token(trimmed)
}

fn installer_spdx_policy(values []string) !InstallerSpdxPolicy {
	mut valid := []spdx.SpdxLicenseToken{}
	mut invalid := []string{}
	for value in values {
		token := installer_spdx_token(value)
		if !spdx.valid_spdx_license(token)! {
			invalid << value
			continue
		}
		valid << token
	}
	return InstallerSpdxPolicy{
		forbidden: spdx.spdx_forbidden_license_map(valid)
		invalid: invalid
	}
}

fn installer_spdx_expression(value string) ?spdx.SpdxLicenseExpression {
	trimmed := value.trim_space()
	if trimmed == '' {
		return none
	}
	symbol := trimmed.trim_string_left(':').to_lower().replace(' ', '_')
	if symbol in spdx.spdx_allowed_license_symbols {
		return spdx.spdx_symbol(symbol)
	}
	return spdx.string_to_spdx_license_expression(trimmed)
}

fn simple_spdx_license_forbidden(expression string,
	forbidden map[string]spdx.SpdxLicenseVersionInfo) bool {
	parsed := installer_spdx_expression(expression) or { return false }
	return spdx.spdx_licenses_forbid_installation(parsed, forbidden)
}

pub fn (installer FormulaInstaller) forbidden_license_check(
	dependencies []FormulaDependencyPlan) ! {
	if installer.forbidden_licenses.len == 0 {
		return
	}
	policy := installer_spdx_policy(installer.forbidden_licenses)!
	if policy.invalid.len > 0 {
		eprintln('Warning: `\$HOMEBREW_FORBIDDEN_LICENSES` contains invalid license identifiers: ${policy.invalid.join(', ')}\nThese licenses will not be forbidden. See the valid SPDX license identifiers at:\n  https://spdx.org/licenses/\nAnd the licenses for a formula with:\n  brew info <formula>')
	}
	if policy.forbidden.len == 0 {
		return
	}
	owner := installer_policy_owner(installer)
	contact := installer_policy_contact(installer)
	if !installer.ignore_deps() {
		for dependency in dependencies {
			if simple_spdx_license_forbidden(dependency.formula.license, policy.forbidden) {
				expression := installer_spdx_expression(dependency.formula.license) or {
					spdx.spdx_license(dependency.formula.license)
				}
				rendered := spdx.spdx_license_expression_to_string(expression, false)
				return error('The installation of ${installer.formula.name} has a dependency on ${dependency.formula.name} where all its licenses were forbidden by ${owner} in `\$HOMEBREW_FORBIDDEN_LICENSES`:\n  ${rendered}${contact}')
			}
		}
	}
	if !installer.only_deps() && simple_spdx_license_forbidden(installer.formula.license, policy.forbidden) {
		expression := installer_spdx_expression(installer.formula.license) or {
			spdx.spdx_license(installer.formula.license)
		}
		rendered := spdx.spdx_license_expression_to_string(expression, false)
		return error("${installer.formula.name}'s licenses are all forbidden by ${owner} in `\$HOMEBREW_FORBIDDEN_LICENSES`:\n  ${rendered}${contact}")
	}
}

fn tap_allowed(tap string, allowed []string, forbidden []string) !bool {
	if tap == '' {
		return true
	}
	reference := new_tap_reference(tap, '')!
	allowed_references := normalize_tap_references(allowed, 'HOMEBREW_ALLOWED_TAPS')
	forbidden_references := normalize_tap_references(forbidden, 'HOMEBREW_FORBIDDEN_TAPS')
	return reference.allowed_by_references(allowed_references) && !reference.forbidden_by_references(forbidden_references)
}

pub fn (installer FormulaInstaller) forbidden_tap_check(dependencies []FormulaDependencyPlan,
	formula_only bool) ! {
	if !installer.only_deps() && !tap_allowed(installer.formula.tap, installer.allowed_taps, installer.forbidden_taps)! {
		return error('The installation of ${installer.formula.full_name} has the tap ${installer.formula.tap}\nbut ${installer_policy_owner(installer)} has not allowed or has forbidden this tap.${installer_policy_contact(installer)}')
	}
	if formula_only || installer.ignore_deps() {
		return
	}
	for dependency in dependencies {
		if !tap_allowed(dependency.formula.tap, installer.allowed_taps, installer.forbidden_taps)! {
			return error('The installation of ${installer.formula.name} has a dependency ${dependency.formula.name}\nfrom the ${dependency.formula.tap} tap but ${installer_policy_owner(installer)} has not allowed or has forbidden this tap.${installer_policy_contact(installer)}')
		}
	}
}

pub fn (installer FormulaInstaller) forbidden_formula_check(
	dependencies []FormulaDependencyPlan, formula_only bool) ! {
	if installer.forbidden_formulae.len == 0 {
		return
	}
	owner := installer_policy_owner(installer)
	contact := installer_policy_contact(installer)
	if !installer.only_deps() && (installer.formula.name in installer.forbidden_formulae || installer.formula.full_name in installer.forbidden_formulae) {
		return error('The installation of ${installer.formula.full_name} was forbidden by ${owner} in `\$HOMEBREW_FORBIDDEN_FORMULAE`.${contact}')
	}
	if formula_only || installer.ignore_deps() {
		return
	}
	for dependency in dependencies {
		if dependency.formula.name in installer.forbidden_formulae || dependency.formula.full_name in installer.forbidden_formulae {
			return error('The installation of ${installer.formula.name} has a dependency ${dependency.formula.full_name}\nbut the ${dependency.formula.full_name} formula was forbidden by ${owner} in `\$HOMEBREW_FORBIDDEN_FORMULAE`.${contact}')
		}
	}
}

pub fn (installer FormulaInstaller) auto_link_versioned_keg_only(
	config FormulaInstallerConfig) bool {
	return auto_link_versioned_keg_only(installer.formula, config)
}

pub fn (installer FormulaInstaller) lock(dependencies []api.PackageReference,
	mut state FormulaInstallerState, mut class_state FormulaInstallerClassState,
	hook FormulaInstallerLockHook) ! {
	if class_state.locked.len > 0 {
		return
	}
	if !installer.ignore_deps() {
		for dependency in dependencies {
			append_installer_identity(mut class_state.locked, installer_identity(dependency, if dependency.stable_version == '' {
				'head'
			} else {
				'stable'
			}))
		}
	}
	class_state.locked.prepend(installer_identity(installer.formula, if installer.head {
		'head'
	} else {
		'stable'
	}))
	for identity in class_state.locked {
		hook(identity.full_name)!
	}
	state.hold_locks = true
}

pub fn unlock_formula_installer(mut state FormulaInstallerState,
	mut class_state FormulaInstallerClassState, hook FormulaInstallerLockHook) ! {
	if !state.hold_locks {
		return
	}
	for identity in class_state.locked {
		hook(identity.full_name)!
	}
	class_state.locked.clear()
	state.hold_locks = false
}

pub fn puts_requirement_messages(state FormulaInstallerState) []string {
	return state.requirement_messages.clone()
}

pub fn (installer FormulaInstaller) prelude(attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig, mut state FormulaInstallerState,
	class_state FormulaInstallerClassState) !FormulaInstallerPreludeResult {
	mut fetch_plan := InstallerPreludePlan{}
	if !state.ran_prelude_fetch {
		fetch_plan = installer.prelude_fetch_plan(false)!
		state.ran_prelude_fetch_metadata = true
		state.ran_prelude_fetch = true
	}
	dependencies, built_os := determine_bottle_tab_attributes(attributes)!
	state.bottle_tab_runtime_dependencies = dependencies.clone()
	state.bottle_built_os_version = built_os
	computed := if installer.ignore_deps() {
		[]FormulaDependencyPlan{}
	} else {
		installer.verify_deps_exist(attributes, config)!
	}
	state.compute_dependencies = computed.clone()
	state.has_compute_dependencies = true
	installer.forbidden_license_check(computed)!
	installer.forbidden_tap_check(computed, false)!
	installer.forbidden_formula_check(computed, false)!
	installer.check_install_sanity(config, class_state)!
	install_fetch := installer.install_fetch_deps(computed)
	state.ran_prelude = true
	return FormulaInstallerPreludeResult{
		fetch_plan: fetch_plan
		dependencies: computed
		install_fetch_dependencies: install_fetch
	}
}
