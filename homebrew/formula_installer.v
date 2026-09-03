module homebrew

import brew_runtime
import homebrew.api
import homebrew.utils as spdx
import os
import time
import x.json2

// Translated from Homebrew/brew `formula_installer.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type FormulaInstallerBuildHook = fn(Formula) !

pub type FormulaInstallerPostInstallHook = fn(string) !

pub type FormulaInstallerCleaner = fn(Formula) !

pub type FormulaInstallerLinkageFixer = fn(Keg) !

pub type FormulaInstallerLockHook = fn(string) !

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
	temporary_cellar_value := brew_runtime.environment_value('HOMEBREW_TEMP_CELLAR')
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
		brew_runtime.environment_value('HOMEBREW_PREFIX').trim_right('/')
	}
	if prefix == '' {
		return error('HOMEBREW_PREFIX is required to install ${installer.formula.full_name}')
	}
	cellar := if installer.cellar != '' {
		installer.cellar.trim_right('/')
	} else {
		configured := brew_runtime.environment_value('HOMEBREW_CELLAR').trim_right('/')
		if configured != '' { configured } else { os.join_path(prefix, 'Cellar') }
	}
	temporary_cellar := if installer.temporary_cellar != '' {
		installer.temporary_cellar.trim_right('/')
	} else {
		configured := brew_runtime.environment_value('HOMEBREW_TEMP_CELLAR').trim_right('/')
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
	if brew_runtime.path_exists(target) || os.is_link(target) {
		return error('${formula.full_name()} ${version.to_s()} is already installed')
	}
	mut staged_path := download.staged_path
	if staged_path == '' {
		cached := download.resource.cached_download()!
		staged_path = download.bottle.stage_from_download_queue_in(cached, true, temporary_cellar)!
		download.staged_path = staged_path
		download.stage_marker = '${staged_path}.poured'
	}
	if !brew_runtime.is_dir(staged_path) {
		return error('Staged bottle keg does not exist: ${staged_path}')
	}
	if brew_runtime.real_path(staged_path) == brew_runtime.real_path(target) {
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

	repository_value := brew_runtime.environment_value('HOMEBREW_REPOSITORY')
	repository := if repository_value != '' { repository_value } else { prefix }
	library_value := brew_runtime.environment_value('HOMEBREW_LIBRARY_PATH')
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
	if brew_runtime.is_file(preferred) {
		return preferred
	}
	bin := keg.join('bin')
	mut entries := brew_runtime.list_dir(bin) or { return '' }
	entries.sort()
	for entry in entries {
		path := brew_runtime.join_path(bin, entry)
		if brew_runtime.is_file(path) {
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
		summary: '${brew_runtime.real_path(result.keg.path)}: ${result.keg.abbreviated_size()}'
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
	if !brew_runtime.path_exists(path) && !os.is_link(path) {
		return
	}
	paths << path
	if !brew_runtime.is_dir(path) || os.is_link(path) {
		return
	}
	mut children := brew_runtime.list_dir(path) or { return }
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
		if brew_runtime.path_exists(destination) || os.is_link(destination) {
			os.rm(destination)!
		}
		os.symlink(os.readlink(source)!, destination)!
	} else if brew_runtime.is_dir(source) {
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
		if brew_runtime.is_dir(formula.prefix()) {
			os.rmdir_all(formula.prefix()) or {}
		}
		return error(err.msg())
	}
	if !brew_runtime.is_dir(formula.prefix()) {
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
			none} else {
			input.bin_path_problem}, mut state) {
			problems << problem
		}
		if problem := problem_if_installer_output(if input.sbin_path_problem == '' {
			none} else {
			input.sbin_path_problem}, mut state) {
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

// Ruby attr_reader `attr_reader :formula` at line 38.
pub fn ruby_formula_installer_l38_d1_formula(installer FormulaInstaller) api.PackageReference {
	return installer.formula
}

// Ruby attr_reader `attr_reader :bottle_tab_runtime_dependencies` at line 41.
pub fn ruby_formula_installer_l41_d2_bottle_tab_runtime_dependencies(installer FormulaInstaller) map[string]map[string]string {
	return installer.bottle_tab_runtime_dependencies.clone()
}

// Ruby attr_accessor `attr_accessor :options` at line 44.
pub fn ruby_formula_installer_l44_d3_options(installer FormulaInstaller) []string {
	return installer.options.clone()
}

// Ruby attr_accessor `attr_accessor :options` at line 44.
pub fn ruby_formula_installer_l44_d4_options(installer FormulaInstaller,
	options []string) FormulaInstaller {
	return FormulaInstaller{
		...installer
		options: options.clone()
	}
}

// Ruby attr_accessor `attr_accessor :link_keg` at line 47.
pub fn ruby_formula_installer_l47_d5_link_keg(installer FormulaInstaller) bool {
	return installer.link_keg
}

// Ruby attr_accessor `attr_accessor :link_keg` at line 47.
pub fn ruby_formula_installer_l47_d6_link_keg(installer FormulaInstaller,
	link_keg bool) FormulaInstaller {
	return FormulaInstaller{
		...installer
		link_keg: link_keg
	}
}

// Ruby attr_accessor `attr_accessor :download_queue` at line 50.
pub fn ruby_formula_installer_l50_d7_download_queue(state &FormulaInstallerState) DownloadQueue {
	return state.download_queue
}

// Ruby attr_accessor `attr_accessor :download_queue` at line 50.
pub fn ruby_formula_installer_l50_d8_download_queue(mut state FormulaInstallerState,
	queue DownloadQueue) {
	state.download_queue = queue
	state.has_download_queue = true
}

// Ruby attr_writer `attr_writer :ran_prelude` at line 53.
pub fn ruby_formula_installer_l53_d9_ran_prelude(mut state FormulaInstallerState,
	ran_prelude bool) {
	state.ran_prelude = ran_prelude
}

// Ruby method `initialize(` at line 85.
pub fn ruby_formula_installer_l85_d10_initialize(formula api.PackageReference,
	config FormulaInstallerConfig) FormulaInstaller {
	return new_formula_installer(formula, config)
}

// Ruby method `debug? = @debug` at line 162.
pub fn ruby_formula_installer_l162_d11_debug(installer FormulaInstaller) bool {
	return installer.debug()
}

// Ruby method `debug_symbols? = @debug_symbols` at line 165.
pub fn ruby_formula_installer_l165_d12_debug_symbols(installer FormulaInstaller) bool {
	return installer.debug_symbols()
}

// Ruby method `force? = @force` at line 168.
pub fn ruby_formula_installer_l168_d13_force(installer FormulaInstaller) bool {
	return installer.force()
}

// Ruby method `force_bottle? = @force_bottle` at line 171.
pub fn ruby_formula_installer_l171_d14_force_bottle(installer FormulaInstaller) bool {
	return installer.force_bottle()
}

// Ruby method `git? = @git` at line 174.
pub fn ruby_formula_installer_l174_d15_git(installer FormulaInstaller) bool {
	return installer.git()
}

// Ruby method `ignore_deps? = @ignore_deps` at line 177.
pub fn ruby_formula_installer_l177_d16_ignore_deps(installer FormulaInstaller) bool {
	return installer.ignore_deps()
}

// Ruby method `installed_on_request? = @installed_on_request` at line 180.
pub fn ruby_formula_installer_l180_d17_installed_on_request(installer FormulaInstaller) bool {
	return installer.installed_on_request_value()
}

// Ruby method `interactive? = @interactive` at line 183.
pub fn ruby_formula_installer_l183_d18_interactive(installer FormulaInstaller) bool {
	return installer.interactive()
}

// Ruby method `keep_tmp? = @keep_tmp` at line 186.
pub fn ruby_formula_installer_l186_d19_keep_tmp(installer FormulaInstaller) bool {
	return installer.keep_tmp()
}

// Ruby method `only_deps? = @only_deps` at line 189.
pub fn ruby_formula_installer_l189_d20_only_deps(installer FormulaInstaller) bool {
	return installer.only_deps()
}

// Ruby method `overwrite? = @overwrite` at line 192.
pub fn ruby_formula_installer_l192_d21_overwrite(installer FormulaInstaller) bool {
	return installer.overwrite()
}

// Ruby method `quiet? = @quiet` at line 195.
pub fn ruby_formula_installer_l195_d22_quiet(installer FormulaInstaller) bool {
	return installer.quiet()
}

// Ruby method `show_header? = @show_header` at line 198.
pub fn ruby_formula_installer_l198_d23_show_header(installer FormulaInstaller) bool {
	return installer.show_header_value()
}

// Ruby method `show_summary_heading? = @show_summary_heading` at line 201.
pub fn ruby_formula_installer_l201_d24_show_summary_heading(installer FormulaInstaller) bool {
	return installer.show_summary_heading_value()
}

// Ruby method `verbose? = @verbose` at line 204.
pub fn ruby_formula_installer_l204_d25_verbose(installer FormulaInstaller) bool {
	return installer.verbose()
}

// Ruby method `self.show_missing_bottle_metadata_warning?` at line 207.
pub fn ruby_formula_installer_l207_d26_self_show_missing_bottle_metadata_warning(
	mut state FormulaInstallerClassState) bool {
	return state.show_missing_bottle_metadata_warning()
}

// Ruby method `self.attempted` at line 215.
pub fn ruby_formula_installer_l215_d27_self_attempted(state &FormulaInstallerClassState) []FormulaInstallerIdentity {
	return state.attempted.clone()
}

// Ruby method `self.installed` at line 220.
pub fn ruby_formula_installer_l220_d28_self_installed(state &FormulaInstallerClassState) []FormulaInstallerIdentity {
	return state.installed.clone()
}

// Ruby method `self.fetched` at line 225.
pub fn ruby_formula_installer_l225_d29_self_fetched(state &FormulaInstallerClassState) []FormulaInstallerIdentity {
	return state.fetched.clone()
}

// Ruby method `build_from_source?` at line 230.
pub fn ruby_formula_installer_l230_d30_build_from_source(installer FormulaInstaller) bool {
	return installer.build_from_source()
}

// Ruby method `include_test?` at line 235.
pub fn ruby_formula_installer_l235_d31_include_test(installer FormulaInstaller) bool {
	return installer.include_test()
}

// Ruby method `build_bottle?` at line 240.
pub fn ruby_formula_installer_l240_d32_build_bottle(installer FormulaInstaller) bool {
	return installer.build_bottle()
}

// Ruby method `skip_post_install?` at line 245.
pub fn ruby_formula_installer_l245_d33_skip_post_install(installer FormulaInstaller) bool {
	return installer.skip_post_install()
}

// Ruby method `skip_link?` at line 250.
pub fn ruby_formula_installer_l250_d34_skip_link(installer FormulaInstaller) bool {
	return installer.skip_link()
}

// Ruby method `pour_bottle?(output_warning: false)` at line 255.
pub fn ruby_formula_installer_l255_d35_pour_bottle(installer FormulaInstaller) bool {
	return installer.pour_bottle()
}

// Ruby method `install_bottle_for?(dep, build)` at line 293.
pub fn ruby_formula_installer_l293_d36_install_bottle_for(installer FormulaInstaller,
	dependency api.PackageReference, build_used_options []string, dependency_pour_allowed bool,
	locations_compatible bool) bool {
	return installer.install_bottle_for(dependency, build_used_options, dependency_pour_allowed, locations_compatible)
}

// Ruby method `prelude_fetch(metadata_only: false)` at line 306.
pub fn ruby_formula_installer_l306_d37_prelude_fetch(installer FormulaInstaller,
	metadata_only bool) !InstallerPreludePlan {
	return installer.prelude_fetch_plan(metadata_only)
}

// Ruby method `prelude` at line 350.
pub fn ruby_formula_installer_l350_d38_prelude(installer &FormulaInstaller,
	attributes map[string]json2.Any, config FormulaDependencyResolutionConfig,
	mut state FormulaInstallerState,
	class_state FormulaInstallerClassState) !FormulaInstallerPreludeResult {
	return installer.prelude(attributes, config, mut state, class_state)
}

// Ruby method `determine_bottle_tab_attributes` at line 368.
pub fn ruby_formula_installer_l368_d39_determine_bottle_tab_attributes(
	attributes map[string]json2.Any) !(map[string]map[string]string, string) {
	return determine_bottle_tab_attributes(attributes)
}

// Ruby method `verify_deps_exist` at line 391.
pub fn ruby_formula_installer_l391_d40_verify_deps_exist(installer &FormulaInstaller,
	attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	return installer.verify_deps_exist(attributes, config)
}

// Ruby method `check_installation_already_attempted` at line 399.
pub fn ruby_formula_installer_l399_d41_check_installation_already_attempted(
	installer &FormulaInstaller, state FormulaInstallerClassState) ! {
	installer.check_installation_already_attempted(state)!
}

// Ruby method `check_install_sanity` at line 404.
pub fn ruby_formula_installer_l404_d42_check_install_sanity(installer &FormulaInstaller,
	config FormulaDependencyResolutionConfig, state FormulaInstallerClassState) ! {
	installer.check_install_sanity(config, state)!
}

// Ruby method `fresh_install?(_formula) = false` at line 506.
pub fn ruby_formula_installer_l506_d43_fresh_install(_installer FormulaInstaller,
	_formula api.PackageReference) bool {
	return false
}

// Ruby method `fetch_fetch_deps` at line 509.
pub fn ruby_formula_installer_l509_d44_fetch_fetch_deps(installer &FormulaInstaller,
	computed []FormulaDependencyPlan) FormulaFetchDependenciesPlan {
	return installer.fetch_fetch_deps(computed)
}

// Ruby method `install_fetch_deps` at line 521.
pub fn ruby_formula_installer_l521_d45_install_fetch_deps(installer &FormulaInstaller,
	computed []FormulaDependencyPlan) []FormulaDependencyPlan {
	return installer.install_fetch_deps(computed)
}

// Ruby method `build_bottle_preinstall` at line 534.
pub fn ruby_formula_installer_l534_d46_build_bottle_preinstall(prefix string) []string {
	return build_bottle_preinstall(prefix)
}

// Ruby method `build_bottle_postinstall` at line 539.
pub fn ruby_formula_installer_l539_d47_build_bottle_postinstall(prefix string,
	bottle_prefix string, preinstall []string) ![]string {
	return build_bottle_postinstall(prefix, bottle_prefix, preinstall)
}

// Ruby method `install` at line 549.
pub fn ruby_formula_installer_l549_d48_install(installer &FormulaInstaller,
	mut downloads []InstallerDownloadPlan,
	root_attributes map[string]json2.Any) ![]FormulaBottleInstallResult {
	return installer.install_poured_downloads(mut downloads, root_attributes)
}

// Ruby method `check_conflicts` at line 648.
pub fn ruby_formula_installer_l648_d49_check_conflicts(installer &FormulaInstaller,
	conflicts []FormulaConflict) ! {
	installer.check_conflicts(conflicts)!
}

// Ruby method `compute_dependencies(use_cache: true)` at line 685.
pub fn ruby_formula_installer_l685_d50_compute_dependencies(installer &FormulaInstaller,
	attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	return installer.compute_dependencies(attributes, config)
}

// Ruby method `unbottled_dependencies(deps)` at line 697.
pub fn ruby_formula_installer_l697_d51_unbottled_dependencies(installer &FormulaInstaller,
	dependencies []FormulaDependencyPlan) []api.PackageReference {
	return installer.unbottled_dependencies(dependencies)
}

// Ruby method `check_requirements(req_map)` at line 706.
pub fn ruby_formula_installer_l706_d52_check_requirements(groups []InstallerRequirementGroup,
	mut state FormulaInstallerState) ! {
	check_installer_requirements(groups, mut state)!
}

// Ruby method `runtime_requirements(formula)` at line 726.
pub fn ruby_formula_installer_l726_d53_runtime_requirements(
	recursive []InstallerRequirement, direct []InstallerRequirement) []InstallerRequirement {
	return runtime_installer_requirements(recursive, direct)
}

// Ruby method `expand_requirements` at line 735.
pub fn ruby_formula_installer_l735_d54_expand_requirements(installer &FormulaInstaller,
	groups []InstallerRequirementGroup) []InstallerRequirementGroup {
	return installer.expand_installer_requirements(groups)
}

// Ruby method `expand_dependencies_for_formula(formula)` at line 770.
pub fn ruby_formula_installer_l770_d55_expand_dependencies_for_formula(installer &FormulaInstaller,
	attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	return installer.compute_dependencies(attributes, config)
}

// Ruby method `expand_dependencies = expand_dependencies_for_formula(formula)` at line 809.
pub fn ruby_formula_installer_l809_d56_expand_dependencies(installer &FormulaInstaller,
	attributes map[string]json2.Any,
	config FormulaDependencyResolutionConfig) ![]FormulaDependencyPlan {
	return installer.compute_dependencies(attributes, config)
}

// Ruby method `effective_build_options_for(dependent)` at line 812.
pub fn ruby_formula_installer_l812_d57_effective_build_options_for(installer &FormulaInstaller,
	dependent api.PackageReference) BuildOptions {
	return installer.effective_build_options_for(dependent)
}

// Ruby method `display_options(formula)` at line 821.
pub fn ruby_formula_installer_l821_d58_display_options(installer &FormulaInstaller,
	formula api.PackageReference) []string {
	return installer.display_options(formula)
}

// Ruby method `install_dependencies(deps)` at line 832.
pub fn ruby_formula_installer_l832_d59_install_dependencies(installer &FormulaInstaller,
	mut downloads []InstallerDownloadPlan,
	root_attributes map[string]json2.Any) ![]FormulaBottleInstallResult {
	return installer.install_poured_downloads(mut downloads, root_attributes)
}

// Ruby method `fetch_dependency(dep)` at line 854.
pub fn ruby_formula_installer_l854_d60_fetch_dependency(installer &FormulaInstaller,
	dependency FormulaDependencyPlan) !InstallerDownloadPlan {
	return installer.fetch_dependency(dependency)
}

// Ruby method `install_dependency(dep, dep_formula = dep.to_formula)` at line 879.
pub fn ruby_formula_installer_l879_d61_install_dependency(installer &FormulaInstaller,
	mut download InstallerDownloadPlan) !FormulaBottleInstallResult {
	child := installer.dependency_installer(download.formula)
	poured := child.pour_download(mut download)!
	finished := child.finish_poured(poured)!
	return FormulaBottleInstallResult{
		formula: download.formula.full_name
		finish: finished
	}
}

// Ruby method `caveats` at line 950.
pub fn ruby_formula_installer_l950_d62_caveats(installer &FormulaInstaller,
	result FormulaPourResult) []string {
	if installer.only_deps() || !installer.installed_on_request_value() || installer.quiet() {
		return []string{}
	}
	return keg_installed_completions(result.keg)
}

// Ruby method `link_manual_command_warning` at line 970.
pub fn ruby_formula_installer_l970_d63_link_manual_command_warning(
	installer &FormulaInstaller) ?string {
	return installer.link_manual_command_warning()
}

// Ruby method `finish` at line 988.
pub fn ruby_formula_installer_l988_d64_finish(installer &FormulaInstaller,
	result FormulaPourResult) !FormulaFinishResult {
	return installer.finish_poured(result)
}

// Ruby method `summary` at line 1082.
pub fn ruby_formula_installer_l1082_d65_summary(keg &Keg) string {
	return '${brew_runtime.real_path(keg.path)}: ${keg.abbreviated_size()}'
}

// Ruby method `build_time` at line 1091.
pub fn ruby_formula_installer_l1091_d66_build_time(mut state FormulaInstallerState,
	interactive bool) ?f64 {
	return state.build_time(interactive)
}

// Ruby method `sanitized_argv_options` at line 1096.
pub fn ruby_formula_installer_l1096_d67_sanitized_argv_options(installer FormulaInstaller) []string {
	return installer.sanitized_argv_options()
}

// Ruby method `build_argv = sanitized_argv_options + options.as_flags` at line 1129.
pub fn ruby_formula_installer_l1129_d68_build_argv(installer FormulaInstaller) []string {
	return installer.build_argv()
}

// Ruby method `build` at line 1132.
pub fn ruby_formula_installer_l1132_d69_build(installer &FormulaInstaller,
	mut state FormulaInstallerState, hook FormulaInstallerBuildHook) ! {
	installer.build(mut state, hook)!
}

// Ruby method `link(keg)` at line 1197.
pub fn ruby_formula_installer_l1197_d70_link(installer &FormulaInstaller, keg &Keg) !int {
	if !installer.link_keg || installer.skip_link() {
		keg.optlink(false, installer.overwrite())!
		return 0
	}
	if keg.linked() {
		keg.remove_linked_keg_record()!
	}
	return keg.link(false, installer.overwrite())
}

// Ruby method `install_service` at line 1290.
pub fn ruby_formula_installer_l1290_d71_install_service(
	definition InstallerServiceDefinition) ![]string {
	return install_formula_service(definition)
}

// Ruby method `fix_dynamic_linkage(keg)` at line 1321.
pub fn ruby_formula_installer_l1321_d72_fix_dynamic_linkage(keg Keg,
	fixer FormulaInstallerLinkageFixer, mut state FormulaInstallerState) ?string {
	return fix_formula_dynamic_linkage(keg, fixer, mut state)
}

// Ruby method `clean` at line 1337.
pub fn ruby_formula_installer_l1337_d73_clean(installer &FormulaInstaller,
	cleaner FormulaInstallerCleaner, mut state FormulaInstallerState) ?string {
	return installer.clean(cleaner, mut state)
}

// Ruby method `post_install_formula_path` at line 1353.
pub fn ruby_formula_installer_l1353_d74_post_install_formula_path(
	installer &FormulaInstaller, config PostInstallFormulaPathConfig) !string {
	return installer.post_install_formula_path(config)
}

// Ruby method `post_install` at line 1392.
pub fn ruby_formula_installer_l1392_d75_post_install(installer &FormulaInstaller,
	config PostInstallFormulaPathConfig, hook FormulaInstallerPostInstallHook,
	mut state FormulaInstallerState) ?string {
	return installer.post_install(config, hook, mut state)
}

// Ruby method `fetch_dependencies` at line 1432.
pub fn ruby_formula_installer_l1432_d76_fetch_dependencies(installer &FormulaInstaller,
	computed []FormulaDependencyPlan, previously_fetched []string) []FormulaDependencyPlan {
	return installer.fetch_dependencies(computed, previously_fetched)
}

// Ruby method `previously_fetched_formula` at line 1446.
pub fn ruby_formula_installer_l1446_d77_previously_fetched_formula(
	installer &FormulaInstaller,
	state FormulaInstallerClassState) ?FormulaInstallerIdentity {
	return installer.previously_fetched_formula(state)
}

// Ruby method `fetch_bottle_tab(quiet: false, enqueue: false)` at line 1458.
pub fn ruby_formula_installer_l1458_d78_fetch_bottle_tab(installer &FormulaInstaller,
	enqueue bool) !InstallerBottleTabPlan {
	return installer.fetch_bottle_tab_plan(enqueue)
}

// Ruby method `fetch` at line 1478.
pub fn ruby_formula_installer_l1478_d79_fetch(mut downloads []InstallerDownloadPlan,
	mut queue DownloadQueue, heading ?string) ! {
	fetch_downloads(mut downloads, mut queue, heading)!
}

// Ruby method `enqueue_fetch` at line 1484.
pub fn ruby_formula_installer_l1484_d80_enqueue_fetch(installer &FormulaInstaller,
	dependencies []FormulaDependencyPlan) ![]InstallerDownloadPlan {
	return installer.enqueue_fetch(dependencies)
}

// Ruby method `enqueue_bottle_download(stage:)` at line 1534.
pub fn ruby_formula_installer_l1534_d81_enqueue_bottle_download(installer &FormulaInstaller,
	stage bool) !InstallerDownloadPlan {
	return installer.enqueue_bottle_download(stage)
}

// Ruby method `verify_bottle_attestation?` at line 1544.
pub fn ruby_formula_installer_l1544_d82_verify_bottle_attestation(installer &FormulaInstaller) bool {
	return installer.verify_bottle_attestation()
}

// Ruby method `downloadable` at line 1553.
pub fn ruby_formula_installer_l1553_d83_downloadable(installer &FormulaInstaller,
	formula api.PackageReference, stage bool) !InstallerDownloadPlan {
	return installer.downloadable(formula, stage)
}

// Ruby method `api_bottle` at line 1570.
pub fn ruby_formula_installer_l1570_d84_api_bottle(installer &FormulaInstaller) !Bottle {
	return api_bottle_for_formula(installer.formula, current_bottle_tag())
}

// Ruby method `pour` at line 1584.
pub fn ruby_formula_installer_l1584_d85_pour(installer &FormulaInstaller,
	mut download InstallerDownloadPlan,
	attributes map[string]json2.Any) !FormulaPourResult {
	return installer.pour_download_with_tab(mut download, attributes)
}

// Ruby method `problem_if_output(output)` at line 1657.
pub fn ruby_formula_installer_l1657_d86_problem_if_output(output ?string,
	mut state FormulaInstallerState) ?string {
	return problem_if_installer_output(output, mut state)
}

// Ruby method `audit_installed` at line 1665.
pub fn ruby_formula_installer_l1665_d87_audit_installed(installer &FormulaInstaller,
	input FormulaInstallerAuditInput, mut state FormulaInstallerState) []string {
	return installer.audit_installed(input, mut state)
}

// Ruby method `self.locked` at line 1674.
pub fn ruby_formula_installer_l1674_d88_self_locked(state &FormulaInstallerClassState) []FormulaInstallerIdentity {
	return state.locked.clone()
}

// Ruby method `forbidden_license_check` at line 1679.
pub fn ruby_formula_installer_l1679_d89_forbidden_license_check(
	installer &FormulaInstaller, dependencies []FormulaDependencyPlan) ! {
	installer.forbidden_license_check(dependencies)!
}

// Ruby method `forbidden_tap_check(formula_only: false)` at line 1740.
pub fn ruby_formula_installer_l1740_d90_forbidden_tap_check(installer &FormulaInstaller,
	dependencies []FormulaDependencyPlan, formula_only bool) ! {
	installer.forbidden_tap_check(dependencies, formula_only)!
}

// Ruby method `forbidden_formula_check(formula_only: false)` at line 1787.
pub fn ruby_formula_installer_l1787_d91_forbidden_formula_check(
	installer &FormulaInstaller, dependencies []FormulaDependencyPlan, formula_only bool) ! {
	installer.forbidden_formula_check(dependencies, formula_only)!
}

// Ruby method `auto_link_versioned_keg_only?` at line 1835.
pub fn ruby_formula_installer_l1835_d92_auto_link_versioned_keg_only(
	installer &FormulaInstaller, config FormulaInstallerConfig) bool {
	return installer.auto_link_versioned_keg_only(config)
}

// Ruby method `lock` at line 1849.
pub fn ruby_formula_installer_l1849_d93_lock(installer &FormulaInstaller,
	dependencies []api.PackageReference, mut state FormulaInstallerState,
	mut class_state FormulaInstallerClassState, hook FormulaInstallerLockHook) ! {
	installer.lock(dependencies, mut state, mut class_state, hook)!
}

// Ruby method `unlock` at line 1864.
pub fn ruby_formula_installer_l1864_d94_unlock(mut state FormulaInstallerState,
	mut class_state FormulaInstallerClassState, hook FormulaInstallerLockHook) ! {
	unlock_formula_installer(mut state, mut class_state, hook)!
}

// Ruby method `puts_requirement_messages` at line 1873.
pub fn ruby_formula_installer_l1873_d95_puts_requirement_messages(
	state FormulaInstallerState) []string {
	return puts_requirement_messages(state)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "api/formula_bottle"
// 6: require "keg"
// 7: require "tab"
// 8: require "utils/bottles"
// 9: require "caveats"
// 10: require "cleaner"
// 11: require "formula_cellar_checks"
// 12: require "install_renamed"
// 13: require "sandbox"
// 14: require "development_tools"
// 15: require "cache_store"
// 16: require "linkage_checker"
// 17: require "messages"
// 18: require "cask/caskroom"
// 19: require "cmd/install"
// 20: require "find"
// 21: require "utils/spdx"
// 22: require "deprecate_disable"
// 23: require "unlink"
// 24: require "service"
// 25: require "attestation"
// 26: require "utils/fork"
// 27: require "utils/output"
// 28: require "utils/attestation"
// 29:
// 30: # Installer for a formula.
// 31: class FormulaInstaller
// 32:   include FormulaCellarChecks
// 33:   include Utils::Output::Mixin
// 34:
// 35:   ETC_VAR_DIRS = T.let([HOMEBREW_PREFIX/"etc", HOMEBREW_PREFIX/"var"].freeze, T::Array[Pathname])
// 36:
// 37:   sig { override.returns(Formula) }
// 38:   attr_reader :formula
// 39:
// 40:   sig { returns(T::Hash[String, T::Hash[String, String]]) }
// 41:   attr_reader :bottle_tab_runtime_dependencies
// 42:
// 43:   sig { returns(Options) }
// 44:   attr_accessor :options
// 45:
// 46:   sig { returns(T::Boolean) }
// 47:   attr_accessor :link_keg
// 48:
// 49:   sig { returns(Homebrew::DownloadQueue) }
// 50:   attr_accessor :download_queue
// 51:
// 52:   sig { params(ran_prelude: T::Boolean).void }
// 53:   attr_writer :ran_prelude
// 54:
// 55:   sig {
// 56:     params(
// 57:       formula:                    Formula,
// 58:       download_queue:             Homebrew::DownloadQueue,
// 59:       link_keg:                   T::Boolean,
// 60:       installed_on_request:       T::Boolean,
// 61:       show_header:                T::Boolean,
// 62:       build_bottle:               T::Boolean,
// 63:       skip_post_install:          T::Boolean,
// 64:       skip_link:                  T::Boolean,
// 65:       force_bottle:               T::Boolean,
// 66:       bottle_arch:                T.nilable(String),
// 67:       ignore_deps:                T::Boolean,
// 68:       only_deps:                  T::Boolean,
// 69:       include_test_formulae:      T::Array[String],
// 70:       build_from_source_formulae: T::Array[String],
// 71:       env:                        T.nilable(String),
// 72:       git:                        T::Boolean,
// 73:       interactive:                T::Boolean,
// 74:       keep_tmp:                   T::Boolean,
// 75:       debug_symbols:              T::Boolean,
// 76:       cc:                         T.nilable(String),
// 77:       options:                    Options,
// 78:       force:                      T::Boolean,
// 79:       overwrite:                  T::Boolean,
// 80:       debug:                      T::Boolean,
// 81:       quiet:                      T::Boolean,
// 82:       verbose:                    T::Boolean,
// 83:     ).void
// 84:   }
// 85:   def initialize(
// 86:     formula,
// 87:     download_queue: Homebrew.default_download_queue,
// 88:     link_keg: false,
// 89:     installed_on_request: false,
// 90:     show_header: false,
// 91:     build_bottle: false,
// 92:     skip_post_install: false,
// 93:     skip_link: false,
// 94:     force_bottle: false,
// 95:     bottle_arch: nil,
// 96:     ignore_deps: false,
// 97:     only_deps: false,
// 98:     include_test_formulae: [],
// 99:     build_from_source_formulae: [],
// 100:     env: nil,
// 101:     git: false,
// 102:     interactive: false,
// 103:     keep_tmp: false,
// 104:     debug_symbols: false,
// 105:     cc: nil,
// 106:     options: Options.new,
// 107:     force: false,
// 108:     overwrite: false,
// 109:     debug: false,
// 110:     quiet: false,
// 111:     verbose: false
// 112:   )
// 113:     @formula = formula
// 114:     @env = env
// 115:     @force = force
// 116:     @overwrite = overwrite
// 117:     @keep_tmp = keep_tmp
// 118:     @debug_symbols = debug_symbols
// 119:     @installed_on_request = installed_on_request
// 120:     link_keg ||= !formula.keg_only? || auto_link_versioned_keg_only?
// 121:     @link_keg = link_keg
// 122:     @show_header = show_header
// 123:     @ignore_deps = ignore_deps
// 124:     @only_deps = only_deps
// 125:     @build_from_source_formulae = build_from_source_formulae
// 126:     @build_bottle = build_bottle
// 127:     @skip_post_install = skip_post_install
// 128:     @skip_link = skip_link
// 129:     @bottle_arch = bottle_arch
// 130:     @formula.force_bottle ||= force_bottle
// 131:     @force_bottle = T.let(@formula.force_bottle, T::Boolean)
// 132:     @include_test_formulae = include_test_formulae
// 133:     @interactive = interactive
// 134:     @git = git
// 135:     @cc = cc
// 136:     @verbose = verbose
// 137:     @quiet = quiet
// 138:     @debug = debug
// 139:     @options = options
// 140:     @requirement_messages = T.let([], T::Array[String])
// 141:     @poured_bottle = T.let(false, T::Boolean)
// 142:     @start_time = T.let(nil, T.nilable(Time))
// 143:     @bottle_tab_runtime_dependencies = T.let({}.freeze, T::Hash[String, T::Hash[String, String]])
// 144:     @bottle_built_os_version = T.let(nil, T.nilable(String))
// 145:     @hold_locks = T.let(false, T::Boolean)
// 146:     @show_summary_heading = T.let(false, T::Boolean)
// 147:     @etc_var_preinstall = T.let([], T::Array[Pathname])
// 148:     @download_queue = download_queue
// 149:     @api_bottle = T.let(nil, T.nilable(Bottle))
// 150:     @api_bottle_loaded = T.let(false, T::Boolean)
// 151:     @enqueued_bottle_download = T.let(nil, T.nilable(Downloadable))
// 152:
// 153:     # Take the original formula instance, which might have been swapped from an API instance to a source instance
// 154:     @formula = T.let(T.must(previously_fetched_formula), Formula) if previously_fetched_formula
// 155:
// 156:     @ran_prelude_fetch_metadata = T.let(false, T::Boolean)
// 157:     @ran_prelude_fetch = T.let(false, T::Boolean)
// 158:     @ran_prelude = T.let(false, T::Boolean)
// 159:   end
// 160:
// 161:   sig { returns(T::Boolean) }
// 162:   def debug? = @debug
// 163:
// 164:   sig { returns(T::Boolean) }
// 165:   def debug_symbols? = @debug_symbols
// 166:
// 167:   sig { returns(T::Boolean) }
// 168:   def force? = @force
// 169:
// 170:   sig { returns(T::Boolean) }
// 171:   def force_bottle? = @force_bottle
// 172:
// 173:   sig { returns(T::Boolean) }
// 174:   def git? = @git
// 175:
// 176:   sig { returns(T::Boolean) }
// 177:   def ignore_deps? = @ignore_deps
// 178:
// 179:   sig { returns(T::Boolean) }
// 180:   def installed_on_request? = @installed_on_request
// 181:
// 182:   sig { returns(T::Boolean) }
// 183:   def interactive? = @interactive
// 184:
// 185:   sig { returns(T::Boolean) }
// 186:   def keep_tmp? = @keep_tmp
// 187:
// 188:   sig { returns(T::Boolean) }
// 189:   def only_deps? = @only_deps
// 190:
// 191:   sig { returns(T::Boolean) }
// 192:   def overwrite? = @overwrite
// 193:
// 194:   sig { returns(T::Boolean) }
// 195:   def quiet? = @quiet
// 196:
// 197:   sig { returns(T::Boolean) }
// 198:   def show_header? = @show_header
// 199:
// 200:   sig { returns(T::Boolean) }
// 201:   def show_summary_heading? = @show_summary_heading
// 202:
// 203:   sig { returns(T::Boolean) }
// 204:   def verbose? = @verbose
// 205:
// 206:   sig { returns(T::Boolean) }
// 207:   def self.show_missing_bottle_metadata_warning?
// 208:     return false if @missing_bottle_metadata_warning_shown
// 209:
// 210:     @missing_bottle_metadata_warning_shown = T.let(true, T.nilable(TrueClass))
// 211:     true
// 212:   end
// 213:
// 214:   sig { returns(T::Set[Formula]) }
// 215:   def self.attempted
// 216:     @attempted ||= T.let(Set.new, T.nilable(T::Set[Formula]))
// 217:   end
// 218:
// 219:   sig { returns(T::Set[Formula]) }
// 220:   def self.installed
// 221:     @installed ||= T.let(Set.new, T.nilable(T::Set[Formula]))
// 222:   end
// 223:
// 224:   sig { returns(T::Set[Formula]) }
// 225:   def self.fetched
// 226:     @fetched ||= T.let(Set.new, T.nilable(T::Set[Formula]))
// 227:   end
// 228:
// 229:   sig { returns(T::Boolean) }
// 230:   def build_from_source?
// 231:     @build_from_source_formulae.include?(formula.full_name)
// 232:   end
// 233:
// 234:   sig { returns(T::Boolean) }
// 235:   def include_test?
// 236:     @include_test_formulae.include?(formula.full_name)
// 237:   end
// 238:
// 239:   sig { returns(T::Boolean) }
// 240:   def build_bottle?
// 241:     @build_bottle.present?
// 242:   end
// 243:
// 244:   sig { returns(T::Boolean) }
// 245:   def skip_post_install?
// 246:     @skip_post_install.present?
// 247:   end
// 248:
// 249:   sig { returns(T::Boolean) }
// 250:   def skip_link?
// 251:     @skip_link.present?
// 252:   end
// 253:
// 254:   sig { params(output_warning: T::Boolean).returns(T::Boolean) }
// 255:   def pour_bottle?(output_warning: false)
// 256:     return false if !formula.bottle_tag? && !formula.local_bottle_path
// 257:     return true  if force_bottle?
// 258:     return false if build_from_source? || build_bottle? || interactive?
// 259:     return false if @cc
// 260:     return false unless options.empty?
// 261:
// 262:     unless formula.pour_bottle?
// 263:       if output_warning && formula.pour_bottle_check_unsatisfied_reason
// 264:         opoo <<~EOS
// 265:           Building #{formula.full_name} from source:
// 266:             #{formula.pour_bottle_check_unsatisfied_reason}
// 267:         EOS
// 268:       end
// 269:       return false
// 270:     end
// 271:
// 272:     return true if formula.local_bottle_path
// 273:
// 274:     bottle = api_bottle || formula.bottle_for_tag(Utils::Bottles.tag)
// 275:     return false if bottle.nil?
// 276:
// 277:     unless bottle.compatible_locations?
// 278:       if output_warning
// 279:         prefix = Pathname(bottle.cellar.to_s).parent
// 280:         opoo <<~EOS
// 281:           Building #{formula.full_name} from source as the bottle needs:
// 282:           - `HOMEBREW_CELLAR=#{bottle.cellar}` (yours is #{HOMEBREW_CELLAR})
// 283:           - `HOMEBREW_PREFIX=#{prefix}` (yours is #{HOMEBREW_PREFIX})
// 284:         EOS
// 285:       end
// 286:       return false
// 287:     end
// 288:
// 289:     true
// 290:   end
// 291:
// 292:   sig { params(dep: Formula, build: BuildOptions).returns(T::Boolean) }
// 293:   def install_bottle_for?(dep, build)
// 294:     return pour_bottle? if dep == formula
// 295:
// 296:     (
// 297:       @build_from_source_formulae.exclude?(dep.full_name) &&
// 298:         dep.bottle.present? &&
// 299:         dep.pour_bottle? &&
// 300:         build.used_options.empty? &&
// 301:         dep.bottle&.compatible_locations?
// 302:     ) || false
// 303:   end
// 304:
// 305:   sig { params(metadata_only: T::Boolean).void }
// 306:   def prelude_fetch(metadata_only: false)
// 307:     unless @ran_prelude_fetch_metadata
// 308:       deprecate_disable_type = DeprecateDisable.type(formula)
// 309:       if deprecate_disable_type.present?
// 310:         message = "#{formula.full_name} has been #{DeprecateDisable.message(formula)}"
// 311:
// 312:         case deprecate_disable_type
// 313:         when :deprecated
// 314:           opoo message
// 315:         when :disabled
// 316:           if force?
// 317:             opoo message
// 318:           else
// 319:             GitHub::Actions.puts_annotation_if_env_set!(:error, message)
// 320:             raise CannotInstallFormulaError, message
// 321:           end
// 322:         end
// 323:       end
// 324:
// 325:       # Run the formula-self forbidden checks before any source or bottle
// 326:       # download is enqueued so a forbidden formula never triggers a fetch.
// 327:       forbidden_tap_check(formula_only: true)
// 328:       forbidden_formula_check(formula_only: true)
// 329:
// 330:       # Needs to be done before expand_dependencies for compute_dependencies
// 331:       fetch_bottle_tab(enqueue: true) if pour_bottle?
// 332:
// 333:       fetch_fetch_deps unless ignore_deps?
// 334:
// 335:       @ran_prelude_fetch_metadata = true
// 336:     end
// 337:
// 338:     return if metadata_only || @ran_prelude_fetch
// 339:
// 340:     if pour_bottle?
// 341:       @enqueued_bottle_download = enqueue_bottle_download(stage: true)
// 342:     elsif formula.loaded_from_api?
// 343:       Homebrew::API::Formula.source_download(formula, download_queue:, enqueue: true)
// 344:     end
// 345:
// 346:     @ran_prelude_fetch = true
// 347:   end
// 348:
// 349:   sig { void }
// 350:   def prelude
// 351:     prelude_fetch unless @ran_prelude_fetch
// 352:
// 353:     determine_bottle_tab_attributes
// 354:
// 355:     verify_deps_exist unless ignore_deps?
// 356:
// 357:     forbidden_license_check
// 358:     forbidden_tap_check
// 359:     forbidden_formula_check
// 360:
// 361:     check_install_sanity
// 362:
// 363:     install_fetch_deps if !ignore_deps? && Homebrew::EnvConfig.download_concurrency <= 1
// 364:     @ran_prelude = true
// 365:   end
// 366:
// 367:   sig { void }
// 368:   def determine_bottle_tab_attributes
// 369:     Tab.clear_cache
// 370:
// 371:     # Setup bottle_tab_runtime_dependencies for compute_dependencies and
// 372:     # bottle_built_os_version for dependency resolution.
// 373:     begin
// 374:       bottle_tab_attributes = formula.bottle_tab_attributes
// 375:       raw_deps = bottle_tab_attributes.fetch("runtime_dependencies", []).then { |deps| deps || [] }
// 376:       @bottle_tab_runtime_dependencies = raw_deps.to_h { |dep| [dep["full_name"], dep] }.freeze
// 377:
// 378:       if (bottle_tag = formula.bottle_for_tag(Utils::Bottles.tag)&.tag) &&
// 379:          bottle_tag.system != :all
// 380:         # Extract the OS version the bottle was built on.
// 381:         # This ensures that when installing older bottles (e.g. Sonoma bottle on Sequoia),
// 382:         # we resolve dependencies according to the bottle's built OS, not the current OS.
// 383:         @bottle_built_os_version = bottle_tab_attributes.dig("built_on", "os_version")
// 384:       end
// 385:     rescue Resource::BottleManifest::Error
// 386:       # If we can't get the bottle manifest, assume a full dependencies install.
// 387:     end
// 388:   end
// 389:
// 390:   sig { void }
// 391:   def verify_deps_exist
// 392:     compute_dependencies
// 393:   rescue FormulaUnavailableError => e
// 394:     e.dependent = formula.full_name
// 395:     raise
// 396:   end
// 397:
// 398:   sig { void }
// 399:   def check_installation_already_attempted
// 400:     raise FormulaInstallationAlreadyAttemptedError, formula if self.class.attempted.include?(formula)
// 401:   end
// 402:
// 403:   sig { void }
// 404:   def check_install_sanity
// 405:     check_installation_already_attempted
// 406:
// 407:     if force_bottle? && !pour_bottle?
// 408:       raise CannotInstallFormulaError, "`--force-bottle` passed but #{formula.full_name} has no bottle!"
// 409:     end
// 410:
// 411:     if Homebrew.default_prefix? &&
// 412:        !build_from_source? && !build_bottle? && !formula.head? && formula.tap&.core_tap? &&
// 413:        # Integration tests override homebrew-core locations
// 414:        ENV["HOMEBREW_INTEGRATION_TEST"].nil? &&
// 415:        !pour_bottle?
// 416:       message = if !formula.pour_bottle? && formula.pour_bottle_check_unsatisfied_reason
// 417:         formula_message = formula.pour_bottle_check_unsatisfied_reason
// 418:         formula_message[0] = formula_message[0].downcase
// 419:
// 420:         <<~EOS
// 421:           #{formula}: #{formula_message}
// 422:         EOS
// 423:       # don't want to complain about no bottle available if doing an
// 424:       # upgrade/reinstall/dependency install (but do in the case the bottle
// 425:       # check fails)
// 426:       elsif fresh_install?(formula)
// 427:         <<~EOS
// 428:           #{formula}: no bottle available!
// 429:         EOS
// 430:       end
// 431:
// 432:       if message
// 433:         message += <<~EOS
// 434:           If you're feeling brave, you can try to install from source with:
// 435:             brew install --build-from-source #{formula}
// 436:
// 437:           This is a Tier 3 configuration:
// 438:             #{Formatter.url("https://docs.brew.sh/Support-Tiers#tier-3")}
// 439:           #{Formatter.bold("Do not report any issues to Homebrew/* repositories!")}
// 440:           Read the above document instead before opening any issues or PRs.
// 441:         EOS
// 442:         raise CannotInstallFormulaError, message
// 443:       end
// 444:     end
// 445:
// 446:     return if ignore_deps?
// 447:
// 448:     if Homebrew::EnvConfig.developer?
// 449:       # `recursive_dependencies` trims cyclic dependencies, so we do one level and take the recursive deps of that.
// 450:       # Mapping direct dependencies to deeper dependencies in a hash is also useful for the cyclic output below.
// 451:       recursive_dep_map = formula.deps.to_h { |dep| [dep, dep.to_formula.recursive_dependencies] }
// 452:
// 453:       cyclic_dependencies = []
// 454:       recursive_dep_map.each do |dep, recursive_deps|
// 455:         if [formula.name, formula.full_name].include?(dep.name)
// 456:           cyclic_dependencies << "#{formula.full_name} depends on itself directly"
// 457:         elsif recursive_deps.any? { |rdep| [formula.name, formula.full_name].include?(rdep.name) }
// 458:           cyclic_dependencies << "#{formula.full_name} depends on itself via #{dep.name}"
// 459:         end
// 460:       end
// 461:
// 462:       if cyclic_dependencies.present?
// 463:         raise CannotInstallFormulaError, <<~EOS
// 464:           #{formula.full_name} contains a recursive dependency on itself:
// 465:             #{cyclic_dependencies.join("\n  ")}
// 466:         EOS
// 467:       end
// 468:     end
// 469:
// 470:     recursive_deps = if pour_bottle?
// 471:       # Include implicit dependencies (except duplicates) in formulae to check
// 472:       (formula.runtime_dependencies + formula.deps.select(&:implicit?)).uniq(&:name)
// 473:     else
// 474:       formula.recursive_dependencies
// 475:     end
// 476:
// 477:     invalid_arch_dependencies = []
// 478:     pinned_unsatisfied_deps = []
// 479:     recursive_deps.each do |dep|
// 480:       tab = Tab.for_formula(dep.to_formula)
// 481:       if tab.arch.present? && tab.arch.to_s != Hardware::CPU.arch.to_s
// 482:         invalid_arch_dependencies << "#{dep} was built for #{tab.arch}"
// 483:       end
// 484:
// 485:       next unless dep.to_formula.pinned?
// 486:       next if dep.satisfied?
// 487:
// 488:       pinned_unsatisfied_deps << dep
// 489:     end
// 490:
// 491:     if invalid_arch_dependencies.present?
// 492:       raise CannotInstallFormulaError, <<~EOS
// 493:         #{formula.full_name} dependencies not built for the #{Hardware::CPU.arch} CPU architecture:
// 494:           #{invalid_arch_dependencies.join("\n  ")}
// 495:       EOS
// 496:     end
// 497:
// 498:     return if pinned_unsatisfied_deps.empty?
// 499:
// 500:     raise CannotInstallFormulaError,
// 501:           "You must `brew unpin #{pinned_unsatisfied_deps * " "}` as installing " \
// 502:           "#{formula.full_name} requires the latest version of pinned dependencies."
// 503:   end
// 504:
// 505:   sig { params(_formula: Formula).returns(T.nilable(T::Boolean)) }
// 506:   def fresh_install?(_formula) = false
// 507:
// 508:   sig { void }
// 509:   def fetch_fetch_deps
// 510:     return if @compute_dependencies.blank?
// 511:
// 512:     compute_dependencies(use_cache: false) if @compute_dependencies.any? do |dep|
// 513:       next false unless dep.implicit?
// 514:
// 515:       fetch_dependencies
// 516:       true
// 517:     end
// 518:   end
// 519:
// 520:   sig { void }
// 521:   def install_fetch_deps
// 522:     return if @compute_dependencies.blank?
// 523:
// 524:     compute_dependencies(use_cache: false) if @compute_dependencies.any? do |dep|
// 525:       next false unless dep.implicit?
// 526:
// 527:       fetch_dependencies
// 528:       install_dependency(dep)
// 529:       true
// 530:     end
// 531:   end
// 532:
// 533:   sig { void }
// 534:   def build_bottle_preinstall
// 535:     @etc_var_preinstall = Find.find(*ETC_VAR_DIRS.select(&:directory?)).to_a
// 536:   end
// 537:
// 538:   sig { void }
// 539:   def build_bottle_postinstall
// 540:     etc_var_postinstall = Find.find(*ETC_VAR_DIRS.select(&:directory?)).to_a
// 541:     (etc_var_postinstall - @etc_var_preinstall).each do |file|
// 542:       # Keep new `etc`/`var` files in `.bottle` so `Formula#install_etc_var`
// 543:       # can restore them later with `InstallRenamed` config handling.
// 544:       Pathname.new(file).cp_path_sub(HOMEBREW_PREFIX, formula.bottle_prefix)
// 545:     end
// 546:   end
// 547:
// 548:   sig { void }
// 549:   def install
// 550:     lock
// 551:
// 552:     start_time = Time.now
// 553:     unless pour_bottle?
// 554:       require "install"
// 555:       Homebrew::Install.perform_build_from_source_checks
// 556:     end
// 557:
// 558:     # Warn if a more recent version of this formula is available in the tap.
// 559:     begin
// 560:       if !quiet? &&
// 561:          formula.pkg_version < (v = Formulary.factory(formula.full_name, force_bottle: force_bottle?).pkg_version)
// 562:         opoo "#{formula.full_name} #{v} is available and more recent than version #{formula.pkg_version}."
// 563:       end
// 564:     rescue FormulaUnavailableError
// 565:       nil
// 566:     end
// 567:
// 568:     check_conflicts
// 569:
// 570:     raise UnbottledError, [formula] if !pour_bottle? && !DevelopmentTools.installed?
// 571:
// 572:     unless ignore_deps?
// 573:       deps = compute_dependencies(use_cache: false)
// 574:       if ((pour_bottle? && !DevelopmentTools.installed?) || build_bottle?) &&
// 575:          (unbottled = unbottled_dependencies(deps)).presence
// 576:         # Check that each dependency in deps has a bottle available, terminating
// 577:         # abnormally with a UnbottledError if one or more don't.
// 578:         raise UnbottledError, unbottled
// 579:       end
// 580:
// 581:       install_dependencies(deps)
// 582:     end
// 583:
// 584:     return if only_deps?
// 585:
// 586:     formula.deprecated_flags.each do |deprecated_option|
// 587:       old_flag = deprecated_option.old_flag
// 588:       new_flag = deprecated_option.current_flag
// 589:       opoo "#{formula.full_name}: #{old_flag} was deprecated; using #{new_flag} instead!"
// 590:     end
// 591:
// 592:     options = display_options(formula).join(" ")
// 593:     oh1 "Installing #{Formatter.identifier(formula.full_name)} #{options}".strip if show_header?
// 594:
// 595:     if (tap = formula.tap) && tap.should_report_analytics?
// 596:       require "utils/analytics"
// 597:       Utils::Analytics.report_package_event(:formula_install, package_name: formula.name, tap_name: tap.name,
// 598: on_request: installed_on_request?, options:)
// 599:     end
// 600:
// 601:     self.class.attempted << formula
// 602:
// 603:     if pour_bottle?
// 604:       begin
// 605:         pour
// 606:       # Catch any other types of exceptions as they leave us with nothing installed.
// 607:       rescue Exception # rubocop:disable Lint/RescueException
// 608:         Keg.new(formula.prefix).ignore_interrupts_and_uninstall! if formula.prefix.exist?
// 609:         raise
// 610:       else
// 611:         @poured_bottle = true
// 612:       end
// 613:     end
// 614:
// 615:     puts_requirement_messages
// 616:
// 617:     build_bottle_preinstall if build_bottle?
// 618:
// 619:     unless @poured_bottle
// 620:       build
// 621:       clean
// 622:
// 623:       # Store the formula used to build the keg in the keg.
// 624:       formula_contents = if (local_bottle_path = formula.local_bottle_path)
// 625:         Utils::Bottles.formula_contents local_bottle_path, name: formula.name
// 626:       else
// 627:         formula.path.read
// 628:       end
// 629:       s = formula_contents.gsub(/  bottle do.+?end\n\n?/m, "")
// 630:       brew_prefix = formula.prefix/".brew"
// 631:       brew_prefix.mkpath
// 632:       Pathname(brew_prefix/"#{formula.name}.rb").atomic_write(s)
// 633:
// 634:       keg = Keg.new(formula.prefix)
// 635:       tab = keg.tab
// 636:       tab.installed_on_request = installed_on_request?
// 637:       tab.write
// 638:     end
// 639:
// 640:     build_bottle_postinstall if build_bottle?
// 641:
// 642:     opoo "Nothing was installed to #{formula.prefix}" unless formula.latest_version_installed?
// 643:     end_time = Time.now
// 644:     Homebrew.messages.package_installed(formula.name, end_time - start_time)
// 645:   end
// 646:
// 647:   sig { void }
// 648:   def check_conflicts
// 649:     return if force?
// 650:     return if skip_link?
// 651:     return unless link_keg
// 652:
// 653:     conflicts = formula.conflicts.select do |c|
// 654:       next false if c.name == formula.name || c.name == formula.full_name
// 655:
// 656:       f = Formulary.factory(c.name)
// 657:     rescue TapFormulaUnavailableError
// 658:       # If the formula name is a fully-qualified name let's silently
// 659:       # ignore it as we don't care about things used in taps that aren't
// 660:       # currently tapped.
// 661:       false
// 662:     rescue FormulaUnavailableError => e
// 663:       # If the formula name doesn't exist any more then complain but don't
// 664:       # stop installation from continuing.
// 665:       opoo <<~EOS
// 666:         #{formula}: #{e.message}
// 667:         'conflicts_with "#{c.name}"' should be removed from #{formula.path.basename}.
// 668:       EOS
// 669:
// 670:       raise if Homebrew::EnvConfig.developer?
// 671:
// 672:       $stderr.puts "Please report this issue to the #{formula.tap&.full_name} tap".squeeze(" ")
// 673:       $stderr.puts " (not Homebrew/* repositories)!" unless formula.core_formula?
// 674:       false
// 675:     else
// 676:       f.linked_keg.exist? && f.opt_prefix.exist?
// 677:     end
// 678:
// 679:     raise FormulaConflictError.new(formula, conflicts) unless conflicts.empty?
// 680:   end
// 681:
// 682:   # Compute and collect the dependencies needed by the formula currently
// 683:   # being installed.
// 684:   sig { params(use_cache: T::Boolean).returns(T::Array[Dependency]) }
// 685:   def compute_dependencies(use_cache: true)
// 686:     @compute_dependencies = T.let(nil, T.nilable(T::Array[Dependency])) unless use_cache
// 687:     @compute_dependencies ||= begin
// 688:       # Needs to be done before expand_dependencies
// 689:       fetch_bottle_tab if pour_bottle?
// 690:
// 691:       check_requirements(expand_requirements)
// 692:       expand_dependencies
// 693:     end
// 694:   end
// 695:
// 696:   sig { params(deps: T::Array[Dependency]).returns(T::Array[Formula]) }
// 697:   def unbottled_dependencies(deps)
// 698:     deps.map(&:to_formula).reject do |dep_f|
// 699:       next false unless dep_f.pour_bottle?
// 700:
// 701:       dep_f.bottled?
// 702:     end
// 703:   end
// 704:
// 705:   sig { params(req_map: T::Hash[Formula, T::Array[Requirement]]).void }
// 706:   def check_requirements(req_map)
// 707:     @requirement_messages = []
// 708:     fatals = []
// 709:
// 710:     req_map.each_pair do |dependent, reqs|
// 711:       reqs.each do |req|
// 712:         next if dependent.latest_version_installed? && req.is_a?(MacOSRequirement) && req.comparator == "<="
// 713:
// 714:         @requirement_messages << "#{dependent}: #{req.message}"
// 715:         fatals << req if req.fatal?
// 716:       end
// 717:     end
// 718:
// 719:     return if fatals.empty?
// 720:
// 721:     puts_requirement_messages
// 722:     raise UnsatisfiedRequirements, fatals
// 723:   end
// 724:
// 725:   sig { params(formula: Formula).returns(T::Array[Requirement]) }
// 726:   def runtime_requirements(formula)
// 727:     runtime_deps = formula.runtime_formula_dependencies(undeclared: false)
// 728:     recursive_requirements = formula.recursive_requirements do |dependent, _|
// 729:       next Dependable::PRUNE unless runtime_deps.include?(dependent)
// 730:     end
// 731:     (recursive_requirements.to_a + formula.requirements.to_a).reject(&:build?).uniq
// 732:   end
// 733:
// 734:   sig { returns(T::Hash[Formula, T::Array[Requirement]]) }
// 735:   def expand_requirements
// 736:     unsatisfied_reqs = Hash.new { |h, k| h[k] = [] }
// 737:     formulae = [formula]
// 738:     formula_deps_map = formula.recursive_dependencies
// 739:                               .to_h { |dep| [dep.name, dep] }
// 740:
// 741:     while (f = formulae.pop)
// 742:       runtime_requirements = runtime_requirements(f)
// 743:       f.recursive_requirements do |dependent, req|
// 744:         dependent = T.cast(dependent, Formula)
// 745:         build = effective_build_options_for(dependent)
// 746:         install_bottle_for_dependent = install_bottle_for?(dependent, build)
// 747:
// 748:         keep_build_test = false
// 749:         keep_build_test ||= runtime_requirements.include?(req)
// 750:         keep_build_test ||= req.test? && include_test? && dependent == f
// 751:         keep_build_test ||= req.build? && !install_bottle_for_dependent && !dependent.latest_version_installed?
// 752:
// 753:         if req.prune_from_option?(build) ||
// 754:            req.satisfied?(env: @env, cc: @cc, build_bottle: @build_bottle, bottle_arch: @bottle_arch) ||
// 755:            ((req.build? || req.test?) && !keep_build_test) ||
// 756:            formula_deps_map[dependent.name]&.build? ||
// 757:            (only_deps? && f == dependent)
// 758:           next Dependable::PRUNE
// 759:         else
// 760:           unsatisfied_reqs[dependent] << req
// 761:           nil # Return nil to satisfy T.nilable(Symbol) block sig (Array from << would violate it).
// 762:         end
// 763:       end
// 764:     end
// 765:
// 766:     unsatisfied_reqs
// 767:   end
// 768:
// 769:   sig { params(formula: Formula).returns(T::Array[Dependency]) }
// 770:   def expand_dependencies_for_formula(formula)
// 771:     # Cache for this expansion only. FormulaInstaller has a lot of inputs which can alter expansion.
// 772:     cache_key = "FormulaInstaller-#{formula.full_name}-#{Time.now.to_f}"
// 773:     formula_cache = T.let({}, T::Hash[Dependency, Formula])
// 774:     satisfied_cache = T.let(
// 775:       {},
// 776:       T::Hash[T::Array[T.nilable(T.any(Dependency, String, Integer))], T::Boolean],
// 777:     )
// 778:     Dependency.expand(formula, cache_key:, formula_cache:) do |dependent, dep|
// 779:       dependent = T.cast(dependent, Formula)
// 780:       build = effective_build_options_for(dependent)
// 781:
// 782:       keep_build_test = false
// 783:       keep_build_test ||= dep.test? && include_test? && @include_test_formulae.include?(dependent.full_name)
// 784:       keep_build_test ||= dep.build? && !install_bottle_for?(dependent, build) &&
// 785:                           (formula.head? || !dependent.latest_version_installed?)
// 786:
// 787:       minimum_version = @bottle_tab_runtime_dependencies.dig(dep.name, "version").presence
// 788:       minimum_version = Version.new(minimum_version) if minimum_version
// 789:       minimum_revision = @bottle_tab_runtime_dependencies.dig(dep.name, "revision")&.to_i
// 790:       bottle_os_version = @bottle_built_os_version
// 791:
// 792:       next Dependable::PRUNE if dep.prune_from_option?(build) || ((dep.build? || dep.test?) && !keep_build_test)
// 793:
// 794:       satisfied_cache_key = T.let([
// 795:         dep,
// 796:         minimum_version&.to_s,
// 797:         minimum_revision,
// 798:         bottle_os_version,
// 799:       ], T::Array[T.nilable(T.any(Dependency, String, Integer))])
// 800:       satisfied = satisfied_cache.fetch(satisfied_cache_key) do
// 801:         satisfied_cache[satisfied_cache_key] = dep.satisfied?(minimum_version:, minimum_revision:, bottle_os_version:)
// 802:       end
// 803:
// 804:       next Dependable::SKIP if satisfied
// 805:     end
// 806:   end
// 807:
// 808:   sig { returns(T::Array[Dependency]) }
// 809:   def expand_dependencies = expand_dependencies_for_formula(formula)
// 810:
// 811:   sig { params(dependent: Formula).returns(BuildOptions) }
// 812:   def effective_build_options_for(dependent)
// 813:     args  = dependent.build.used_options
// 814:     args |= options if dependent == formula
// 815:     args |= Tab.for_formula(dependent).used_options
// 816:     args &= dependent.options
// 817:     BuildOptions.new(args, dependent.options)
// 818:   end
// 819:
// 820:   sig { params(formula: Formula).returns(T::Array[String]) }
// 821:   def display_options(formula)
// 822:     options = if formula.head?
// 823:       ["--HEAD"]
// 824:     else
// 825:       []
// 826:     end
// 827:     options += effective_build_options_for(formula).used_options.to_a.map(&:to_s)
// 828:     options
// 829:   end
// 830:
// 831:   sig { params(deps: T::Array[Dependency]).void }
// 832:   def install_dependencies(deps)
// 833:     if deps.empty? && only_deps?
// 834:       puts "All dependencies for #{formula.full_name} are satisfied."
// 835:     elsif !deps.empty?
// 836:       deps_with_formulae = deps.map { |dep| [dep, dep.to_formula] }
// 837:       if deps.length > 1
// 838:         names = deps_with_formulae.map do |dep, dep_formula|
// 839:           installed = dep_formula.any_version_installed?
// 840:           pretty_install_status(Formatter.identifier(dep), installed:,
// 841:                                 outdated: installed && dep_formula.outdated?, mark_uninstalled: false,
// 842:                                 bold: false)
// 843:         end
// 844:         oh1 "Installing dependencies for #{formula.full_name}:#{Tty.reset} #{names.to_sentence}",
// 845:             truncate: false
// 846:       end
// 847:       deps_with_formulae.each { |dep, dep_formula| install_dependency(dep, dep_formula) }
// 848:     end
// 849:
// 850:     @show_header = true unless deps.empty?
// 851:   end
// 852:
// 853:   sig { params(dep: Dependency).void }
// 854:   def fetch_dependency(dep)
// 855:     df = dep.to_formula
// 856:     fi = FormulaInstaller.new(
// 857:       df,
// 858:       force_bottle:               false,
// 859:       # When fetching we don't need to recurse the dependency tree as it's already
// 860:       # been done for us in `compute_dependencies` and there's no requirement to
// 861:       # fetch in a particular order.
// 862:       # Note, this tree can vary when pouring bottles so we need to check it then.
// 863:       ignore_deps:                !pour_bottle?,
// 864:       include_test_formulae:      @include_test_formulae,
// 865:       build_from_source_formulae: @build_from_source_formulae,
// 866:       keep_tmp:                   keep_tmp?,
// 867:       debug_symbols:              debug_symbols?,
// 868:       force:                      force?,
// 869:       debug:                      debug?,
// 870:       quiet:                      quiet?,
// 871:       verbose:                    verbose?,
// 872:     )
// 873:     fi.download_queue = download_queue
// 874:     fi.prelude
// 875:     fi.enqueue_fetch
// 876:   end
// 877:
// 878:   sig { params(dep: Dependency, dep_formula: Formula).void }
// 879:   def install_dependency(dep, dep_formula = dep.to_formula)
// 880:     if dep_formula.linked_keg.directory?
// 881:       linked_keg = Keg.new(dep_formula.linked_keg.resolved_path)
// 882:       tab = linked_keg.tab
// 883:       keg_had_linked_keg = true
// 884:       keg_was_linked = linked_keg.linked?
// 885:       linked_keg.unlink
// 886:     else
// 887:       keg_had_linked_keg = false
// 888:     end
// 889:
// 890:     if dep_formula.latest_version_installed?
// 891:       installed_keg = Keg.new(dep_formula.prefix)
// 892:       tab ||= installed_keg.tab
// 893:       tmp_keg = Pathname.new("#{installed_keg}.tmp")
// 894:       installed_keg.rename(tmp_keg) unless tmp_keg.directory?
// 895:     end
// 896:
// 897:     if dep_formula.tap.present? && tab.present? && (tab_tap = tab.source["tap"].presence) &&
// 898:        dep_formula.tap.to_s != tab_tap.to_s
// 899:       odie <<~EOS
// 900:         #{dep_formula} is already installed from #{tab_tap}!
// 901:         Please `brew uninstall #{dep_formula}` first."
// 902:       EOS
// 903:     end
// 904:
// 905:     options = Options.new
// 906:     options |= tab.used_options if tab.present?
// 907:     options |= Tab.remap_deprecated_options(dep_formula.deprecated_options, dep.options)
// 908:     options &= dep_formula.options
// 909:
// 910:     installed_on_request = dep_formula.any_version_installed? && tab.present? && tab.installed_on_request
// 911:     installed_on_request ||= false
// 912:
// 913:     fi = FormulaInstaller.new(
// 914:       dep_formula,
// 915:       options:,
// 916:       link_keg:                   keg_had_linked_keg && keg_was_linked,
// 917:       installed_on_request:,
// 918:       force_bottle:               false,
// 919:       include_test_formulae:      @include_test_formulae,
// 920:       build_from_source_formulae: @build_from_source_formulae,
// 921:       keep_tmp:                   keep_tmp?,
// 922:       debug_symbols:              debug_symbols?,
// 923:       force:                      force?,
// 924:       debug:                      debug?,
// 925:       quiet:                      quiet?,
// 926:       verbose:                    verbose?,
// 927:     )
// 928:     action = dep_formula.outdated? ? "Upgrading" : "Installing"
// 929:     oh1 "#{action} #{formula.full_name} dependency: #{Formatter.identifier(dep.name)}"
// 930:     # prelude only needed to populate bottle_tab_runtime_dependencies, fetching has already been done.
// 931:     fi.prelude
// 932:     fi.install
// 933:     fi.finish
// 934:   # Handle all possible exceptions installing deps.
// 935:   rescue Exception => e # rubocop:disable Lint/RescueException
// 936:     ignore_interrupts do
// 937:       tmp_keg.rename(installed_keg.to_path) if tmp_keg && !installed_keg.directory?
// 938:       linked_keg.link(verbose: verbose?) if keg_was_linked
// 939:     end
// 940:     raise unless e.is_a? FormulaInstallationAlreadyAttemptedError
// 941:
// 942:     # We already attempted to install f as part of another formula's
// 943:     # dependency tree. In that case, don't generate an error, just move on.
// 944:     nil
// 945:   else
// 946:     ignore_interrupts { FileUtils.rm_r(tmp_keg) if tmp_keg&.directory? }
// 947:   end
// 948:
// 949:   sig { void }
// 950:   def caveats
// 951:     return if only_deps?
// 952:
// 953:     audit_installed if Homebrew::EnvConfig.developer?
// 954:
// 955:     return unless installed_on_request?
// 956:     return if quiet?
// 957:
// 958:     caveats = Caveats.new(formula)
// 959:     return if caveats.empty?
// 960:
// 961:     Homebrew.messages.record_completions_and_elisp(caveats.completions_and_elisp)
// 962:     return if caveats.caveats.empty?
// 963:
// 964:     @show_summary_heading = true
// 965:     ohai "Caveats", caveats.to_s
// 966:     Homebrew.messages.record_caveats(formula.name, caveats)
// 967:   end
// 968:
// 969:   sig { returns(T.nilable(String)) }
// 970:   def link_manual_command_warning
// 971:     return unless installed_on_request?
// 972:     return unless formula.keg_only?
// 973:     return unless formula.keg_only_reason.versioned_formula?
// 974:     return if link_keg
// 975:     return if formula.linked?
// 976:
// 977:     reason = formula.link_overwrite_reason
// 978:     return if reason.blank?
// 979:
// 980:     <<~EOS
// 981:       #{formula.full_name} was installed but not linked because #{reason}.
// 982:       To link this version, run:
// 983:         brew link #{formula.full_name}
// 984:     EOS
// 985:   end
// 986:
// 987:   sig { void }
// 988:   def finish
// 989:     return if only_deps?
// 990:
// 991:     ohai "Finishing up" if verbose?
// 992:
// 993:     keg = Keg.new(formula.prefix)
// 994:     link(keg)
// 995:     warning = link_manual_command_warning
// 996:     opoo warning if !quiet? && warning.present?
// 997:
// 998:     install_service
// 999:
// 1000:     fix_dynamic_linkage(keg) if !@poured_bottle || !formula.bottle_specification.skip_relocation?(tab: keg.tab)
// 1001:
// 1002:     require "install"
// 1003:     Homebrew::Install.global_post_install
// 1004:
// 1005:     if build_bottle? || skip_post_install?
// 1006:       unless quiet?
// 1007:         if build_bottle?
// 1008:           ohai "Not running 'post_install' as we're building a bottle"
// 1009:         elsif skip_post_install?
// 1010:           ohai "Skipping 'post_install' on request"
// 1011:         end
// 1012:         puts "You can run it manually using:"
// 1013:         puts "  brew postinstall #{formula.full_name}"
// 1014:       end
// 1015:     else
// 1016:       formula.install_etc_var
// 1017:       post_install if formula.post_install_steps_defined? || formula.post_install_defined?
// 1018:     end
// 1019:
// 1020:     keg.prepare_debug_symbols if debug_symbols?
// 1021:
// 1022:     # Updates the cache for a particular formula after doing an install
// 1023:     CacheStoreDatabase.use(:linkage) do |db|
// 1024:       break unless db.created?
// 1025:
// 1026:       typed_db = T.cast(db, CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]])
// 1027:       LinkageChecker.new(keg, formula, cache_db: typed_db, rebuild_cache: true)
// 1028:     end
// 1029:
// 1030:     # Update tab with actual runtime dependencies
// 1031:     tab = keg.tab
// 1032:     Tab.clear_cache
// 1033:     f_runtime_deps = formula.runtime_dependencies(read_from_tab: false)
// 1034:     tab.runtime_dependencies = Tab.runtime_deps_hash(formula, f_runtime_deps)
// 1035:     tab.write
// 1036:
// 1037:     # Update packaged SBOM metadata or write a source-install SBOM.
// 1038:     if @poured_bottle
// 1039:       if (install_time = tab.time)
// 1040:         require "sbom"
// 1041:         SBOM.update_pour_metadata(
// 1042:           SBOM.spdxfile(formula),
// 1043:           homebrew_version: HOMEBREW_VERSION,
// 1044:           time:             install_time,
// 1045:           supplement:       (api_bottle || formula.bottle)&.sbom_supplement,
// 1046:         )
// 1047:       end
// 1048:     elsif Homebrew::EnvConfig.sbom? && !build_bottle?
// 1049:       require "sbom"
// 1050:       sbom = SBOM.create(formula, tab)
// 1051:       sbom.write(validate: Homebrew::EnvConfig.developer?)
// 1052:     end
// 1053:
// 1054:     # let's reset Utils::Git.available? if we just installed git
// 1055:     Utils::Git.clear_available_cache if formula.name == "git"
// 1056:
// 1057:     # use installed ca-certificates when it's needed and available
// 1058:     if formula.name == "ca-certificates" &&
// 1059:        !DevelopmentTools.ca_file_handles_most_https_certificates?
// 1060:       ENV["SSL_CERT_FILE"] = ENV["GIT_SSL_CAINFO"] = (formula.pkgetc/"cert.pem").to_s
// 1061:       ENV["GIT_SSL_CAPATH"] = formula.pkgetc.to_s
// 1062:     end
// 1063:
// 1064:     # use installed curl when it's needed and available
// 1065:     if formula.name == "curl" &&
// 1066:        !DevelopmentTools.curl_handles_most_https_certificates?
// 1067:       ENV["HOMEBREW_CURL"] = (formula.opt_bin/"curl").to_s
// 1068:       Utils::Curl.clear_path_cache
// 1069:     end
// 1070:
// 1071:     caveats
// 1072:
// 1073:     ohai "Summary" if verbose? || show_summary_heading?
// 1074:     puts summary
// 1075:
// 1076:     self.class.installed << formula
// 1077:   ensure
// 1078:     unlock
// 1079:   end
// 1080:
// 1081:   sig { returns(String) }
// 1082:   def summary
// 1083:     s = +""
// 1084:     s << "#{Homebrew::EnvConfig.install_badge}  " unless Homebrew::EnvConfig.no_emoji?
// 1085:     s << "#{formula.prefix.resolved_path}: #{formula.prefix.abv}"
// 1086:     s << ", built in #{pretty_duration build_time}" if build_time
// 1087:     s.freeze
// 1088:   end
// 1089:
// 1090:   sig { returns(T.nilable(Float)) }
// 1091:   def build_time
// 1092:     @build_time ||= T.let(Time.now - @start_time, T.nilable(Float)) if @start_time && !interactive?
// 1093:   end
// 1094:
// 1095:   sig { returns(T::Array[String]) }
// 1096:   def sanitized_argv_options
// 1097:     args = []
// 1098:     args << "--ignore-dependencies" if ignore_deps?
// 1099:
// 1100:     if build_bottle?
// 1101:       args << "--build-bottle"
// 1102:       args << "--bottle-arch=#{@bottle_arch}" if @bottle_arch
// 1103:     end
// 1104:
// 1105:     args << "--git" if git?
// 1106:     args << "--interactive" if interactive?
// 1107:     args << "--verbose" if verbose?
// 1108:     args << "--debug" if debug?
// 1109:     args << "--cc=#{@cc}" if @cc
// 1110:     args << "--keep-tmp" if keep_tmp?
// 1111:
// 1112:     if debug_symbols?
// 1113:       args << "--debug-symbols"
// 1114:       args << "--build-from-source"
// 1115:     end
// 1116:
// 1117:     if @env.present?
// 1118:       args << "--env=#{@env}"
// 1119:     elsif formula.env.std? || formula.deps.select(&:build?).any? { |d| d.name == "scons" }
// 1120:       args << "--env=std"
// 1121:     end
// 1122:
// 1123:     args << "--HEAD" if formula.head?
// 1124:
// 1125:     args
// 1126:   end
// 1127:
// 1128:   sig { returns(T::Array[String]) }
// 1129:   def build_argv = sanitized_argv_options + options.as_flags
// 1130:
// 1131:   sig { void }
// 1132:   def build
// 1133:     FileUtils.rm_rf(formula.logs)
// 1134:
// 1135:     @start_time = Time.now
// 1136:
// 1137:     # If the formula is still loaded from the API (i.e. the source .rb was never
// 1138:     # fetched), attempt to download the source now. Without this, specified_path
// 1139:     # would point at a JSON file (e.g. formula.jws.json) which build.rb cannot
// 1140:     # load. See: https://github.com/orgs/Homebrew/discussions/6455
// 1141:     @formula = Homebrew::API::Formula.source_download_formula(formula) if formula.loaded_from_api?
// 1142:
// 1143:     # 1. formulae can modify ENV, so we must ensure that each
// 1144:     #    installation has a pristine ENV when it starts, forking now is
// 1145:     #    the easiest way to do this
// 1146:     formula_path = formula.specified_path
// 1147:     args = [
// 1148:       "nice",
// 1149:       *HOMEBREW_RUBY_EXEC_ARGS,
// 1150:       "--",
// 1151:       HOMEBREW_LIBRARY_PATH/"build.rb",
// 1152:       formula_path,
// 1153:     ].concat(build_argv)
// 1154:
// 1155:     Sandbox.run_or_fork(*args, step: "building") do |sandbox|
// 1156:       sandbox.allow_read_if_exists path: formula_path
// 1157:       if Homebrew::EnvConfig.require_tap_trust?
// 1158:         require "trust"
// 1159:         sandbox.allow_read_if_exists path: Homebrew::Trust.trust_file
// 1160:       end
// 1161:       formula.logs.mkpath
// 1162:       sandbox.record_log(formula.logs/"build.sandbox.log")
// 1163:       if interactive?
// 1164:         sandbox.allow_write_path(Dir.home)
// 1165:       else
// 1166:         sandbox.deny_read_home
// 1167:       end
// 1168:       sandbox.allow_write_temp_and_cache
// 1169:       sandbox.allow_write_log(formula)
// 1170:       sandbox.allow_cvs
// 1171:       sandbox.allow_fossil
// 1172:       sandbox.allow_write_xcode
// 1173:       sandbox.allow_write_cellar(formula)
// 1174:       sandbox.deny_all_network unless formula.network_access_allowed?(:build)
// 1175:     end
// 1176:
// 1177:     formula.update_head_version
// 1178:
// 1179:     raise "Empty installation" if !formula.prefix.directory? || Keg.new(formula.prefix).empty_installation?
// 1180:   # Handle all possible exceptions when building.
// 1181:   rescue Exception => e # rubocop:disable Lint/RescueException
// 1182:     if e.is_a? BuildError
// 1183:       e.formula = formula
// 1184:       e.options = display_options(formula)
// 1185:     end
// 1186:
// 1187:     ignore_interrupts do
// 1188:       # any exceptions must leave us with nothing installed
// 1189:       formula.update_head_version
// 1190:       FileUtils.rm_r(formula.prefix) if formula.prefix.directory?
// 1191:       formula.rack.rmdir_if_possible
// 1192:     end
// 1193:     raise e
// 1194:   end
// 1195:
// 1196:   sig { params(keg: Keg).void }
// 1197:   def link(keg)
// 1198:     Formula.clear_cache
// 1199:
// 1200:     cask_installed_with_formula_name = Cask::Caskroom.cask_installed?(formula.name)
// 1201:
// 1202:     if cask_installed_with_formula_name
// 1203:       ohai "#{formula.name} cask is installed, skipping link."
// 1204:       @link_keg = false
// 1205:     elsif skip_link? && !quiet?
// 1206:       ohai "Skipping 'link' on request"
// 1207:       puts "You can run it manually using:"
// 1208:       puts "  brew link #{formula.full_name}"
// 1209:     end
// 1210:
// 1211:     if !link_keg || skip_link?
// 1212:       begin
// 1213:         keg.optlink(verbose: verbose?, overwrite: overwrite?)
// 1214:       rescue Keg::LinkError => e
// 1215:         ofail "Failed to create #{formula.opt_prefix}"
// 1216:         puts "Things that depend on #{formula.full_name} will probably not build."
// 1217:         puts e
// 1218:       end
// 1219:       return
// 1220:     end
// 1221:
// 1222:     if keg.linked?
// 1223:       opoo "This keg was marked linked already, continuing anyway"
// 1224:       keg.remove_linked_keg_record
// 1225:     end
// 1226:
// 1227:     Homebrew::Unlink.unlink_link_overwrite_formulae(formula, verbose: verbose?)
// 1228:
// 1229:     link_overwrite_backup = {} # Hash: conflict file -> backup file
// 1230:     backup_dir = HOMEBREW_CACHE/"Backup"
// 1231:
// 1232:     begin
// 1233:       keg.link(verbose: verbose?, overwrite: overwrite?)
// 1234:     rescue Keg::ConflictError => e
// 1235:       conflict_file = e.dst
// 1236:       if formula.link_overwrite?(conflict_file) && !link_overwrite_backup.key?(conflict_file)
// 1237:         backup_file = backup_dir/conflict_file.relative_path_from(HOMEBREW_PREFIX).to_s
// 1238:         backup_file.parent.mkpath
// 1239:         FileUtils.mv conflict_file, backup_file
// 1240:         link_overwrite_backup[conflict_file] = backup_file
// 1241:         retry
// 1242:       end
// 1243:       ofail "The `brew link` step did not complete successfully"
// 1244:       puts "The formula built, but is not symlinked into #{HOMEBREW_PREFIX}"
// 1245:       puts e
// 1246:       puts
// 1247:       puts "Possible conflicting files are:"
// 1248:       keg.link(dry_run: true, overwrite: true, verbose: verbose?)
// 1249:       @show_summary_heading = true
// 1250:     rescue Keg::LinkError => e
// 1251:       ofail "The `brew link` step did not complete successfully"
// 1252:       puts "The formula built, but is not symlinked into #{HOMEBREW_PREFIX}"
// 1253:       puts e
// 1254:       puts
// 1255:       puts "You can try again using:"
// 1256:       puts "  brew link #{formula.name}"
// 1257:       @show_summary_heading = true
// 1258:     # Handle all other possible exceptions when linking.
// 1259:     rescue Exception => e # rubocop:disable Lint/RescueException
// 1260:       ofail "An unexpected error occurred during the `brew link` step"
// 1261:       puts "The formula built, but is not symlinked into #{HOMEBREW_PREFIX}"
// 1262:       puts e
// 1263:
// 1264:       if debug?
// 1265:         require "utils/backtrace"
// 1266:         puts Utils::Backtrace.clean(e)
// 1267:       end
// 1268:
// 1269:       @show_summary_heading = true
// 1270:       ignore_interrupts do
// 1271:         keg.unlink
// 1272:         link_overwrite_backup.each do |origin, backup|
// 1273:           origin.parent.mkpath
// 1274:           FileUtils.mv backup, origin
// 1275:         end
// 1276:       end
// 1277:       raise
// 1278:     end
// 1279:
// 1280:     return if link_overwrite_backup.empty?
// 1281:
// 1282:     opoo "These files were overwritten during the `brew link` step:"
// 1283:     puts link_overwrite_backup.keys
// 1284:     puts
// 1285:     puts "They have been backed up to: #{backup_dir}"
// 1286:     @show_summary_heading = true
// 1287:   end
// 1288:
// 1289:   sig { void }
// 1290:   def install_service
// 1291:     service = if formula.service? && formula.service.command?
// 1292:       service_path = formula.systemd_service_path
// 1293:       service_path.atomic_write(formula.service.to_systemd_unit)
// 1294:       service_path.chmod 0644
// 1295:
// 1296:       if formula.service.timed?
// 1297:         timer_path = formula.systemd_timer_path
// 1298:         timer_path.atomic_write(formula.service.to_systemd_timer)
// 1299:         timer_path.chmod 0644
// 1300:       end
// 1301:
// 1302:       formula.service.to_plist
// 1303:     end
// 1304:     return unless service
// 1305:
// 1306:     launchd_service_path = formula.launchd_service_path
// 1307:     launchd_service_path.atomic_write(service)
// 1308:     launchd_service_path.chmod 0644
// 1309:     log = formula.var/"log"
// 1310:     log.mkpath if service.include? log.to_s
// 1311:   # Handle all possible exceptions when installing service files.
// 1312:   rescue Exception => e # rubocop:disable Lint/RescueException
// 1313:     puts e
// 1314:     ofail "Failed to install service files"
// 1315:
// 1316:     require "utils/backtrace"
// 1317:     odebug e, Utils::Backtrace.clean(e)
// 1318:   end
// 1319:
// 1320:   sig { params(keg: Keg).void }
// 1321:   def fix_dynamic_linkage(keg)
// 1322:     keg.fix_dynamic_linkage
// 1323:   # Rescue all possible exceptions when fixing linkage.
// 1324:   rescue Exception => e # rubocop:disable Lint/RescueException
// 1325:     ofail "Failed to fix install linkage"
// 1326:     puts e
// 1327:     puts "The formula built, but you may encounter issues using it or linking other"
// 1328:     puts "formulae against it."
// 1329:
// 1330:     require "utils/backtrace"
// 1331:     odebug "Backtrace", Utils::Backtrace.clean(e)
// 1332:
// 1333:     @show_summary_heading = true
// 1334:   end
// 1335:
// 1336:   sig { void }
// 1337:   def clean
// 1338:     ohai "Cleaning" if verbose?
// 1339:     Cleaner.new(formula).clean
// 1340:   # Handle all possible exceptions when cleaning does not complete.
// 1341:   rescue Exception => e # rubocop:disable Lint/RescueException
// 1342:     opoo "The cleaning step did not complete successfully"
// 1343:     puts "Still, the installation was successful, so we will link it into your prefix."
// 1344:
// 1345:     require "utils/backtrace"
// 1346:     odebug e, Utils::Backtrace.clean(e)
// 1347:
// 1348:     Homebrew.failed = true
// 1349:     @show_summary_heading = true
// 1350:   end
// 1351:
// 1352:   sig { returns(T.any(String, Pathname)) }
// 1353:   def post_install_formula_path
// 1354:     # Use the formula from the keg when any of the following is true:
// 1355:     # * We're installing from the JSON API and it has a Ruby post-install hook
// 1356:     # * We're installing a local bottle file
// 1357:     # * We're building from source
// 1358:     # * The formula doesn't exist in the tap (or the tap isn't installed)
// 1359:     # * The formula in the tap has a different `pkg_version``.
// 1360:     #
// 1361:     # In all other cases, including if the formula from the keg is unreadable
// 1362:     # (third-party taps may `require` some of their own libraries) or if there
// 1363:     # is no formula present in the keg (as is the case with very old bottles),
// 1364:     # use the formula from the tap.
// 1365:     tap_formula_path = T.must(formula.specified_path)
// 1366:     installed_prefix = formula.any_installed_prefix
// 1367:     return tap_formula_path if installed_prefix.nil?
// 1368:
// 1369:     keg_formula_path = installed_prefix/".brew/#{formula.name}.rb"
// 1370:     if formula.loaded_from_api?
// 1371:       return formula.full_name unless formula.post_install_defined?
// 1372:
// 1373:       return keg_formula_path
// 1374:     end
// 1375:     return keg_formula_path if formula.local_bottle_path
// 1376:     return keg_formula_path if build_from_source?
// 1377:
// 1378:     return keg_formula_path unless tap_formula_path.exist?
// 1379:
// 1380:     begin
// 1381:       keg_formula = Formulary.factory(keg_formula_path)
// 1382:       tap_formula = Formulary.factory(tap_formula_path)
// 1383:       return keg_formula_path if keg_formula.pkg_version != tap_formula.pkg_version
// 1384:
// 1385:       tap_formula_path
// 1386:     rescue FormulaUnavailableError, FormulaUnreadableError
// 1387:       tap_formula_path
// 1388:     end
// 1389:   end
// 1390:
// 1391:   sig { void }
// 1392:   def post_install
// 1393:     args = [
// 1394:       "nice",
// 1395:       *HOMEBREW_RUBY_EXEC_ARGS,
// 1396:       "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 1397:       "--",
// 1398:       HOMEBREW_LIBRARY_PATH/"postinstall.rb"
// 1399:     ]
// 1400:
// 1401:     args << post_install_formula_path
// 1402:
// 1403:     Sandbox.with_preserved_brew_file do
// 1404:       Sandbox.run_or_fork(*args, step: "running post-install") do |sandbox|
// 1405:         formula.logs.mkpath
// 1406:         sandbox.record_log(formula.logs/"postinstall.sandbox.log")
// 1407:         sandbox.allow_write_log(formula)
// 1408:         sandbox.allow_write_xcode
// 1409:         sandbox.allow_write_cellar(formula)
// 1410:         sandbox.add_install_hook_rules(
// 1411:           network_access_allowed: formula.network_access_allowed?(:postinstall),
// 1412:         )
// 1413:         Keg.keg_link_directories.each do |dir|
// 1414:           sandbox.allow_write_path "#{HOMEBREW_PREFIX}/#{dir}"
// 1415:         end
// 1416:       end
// 1417:     end
// 1418:   # Handle all possible exceptions when postinstall does not complete.
// 1419:   rescue Exception => e # rubocop:disable Lint/RescueException
// 1420:     opoo "The post-install step did not complete successfully"
// 1421:     puts "You can try again using:"
// 1422:     puts "  brew postinstall #{formula.full_name}"
// 1423:
// 1424:     require "utils/backtrace"
// 1425:     odebug e, Utils::Backtrace.clean(e), always_display: Homebrew::EnvConfig.developer?
// 1426:
// 1427:     Homebrew.failed = true
// 1428:     @show_summary_heading = true
// 1429:   end
// 1430:
// 1431:   sig { void }
// 1432:   def fetch_dependencies
// 1433:     return if ignore_deps?
// 1434:
// 1435:     # Don't output dependencies if we're explicitly installing them.
// 1436:     deps = compute_dependencies.reject do |dep|
// 1437:       self.class.fetched.include?(dep.to_formula)
// 1438:     end
// 1439:
// 1440:     return if deps.empty?
// 1441:
// 1442:     deps.each { fetch_dependency(it) }
// 1443:   end
// 1444:
// 1445:   sig { returns(T.nilable(Formula)) }
// 1446:   def previously_fetched_formula
// 1447:     # We intentionally don't compare classes here:
// 1448:     # from-API-JSON and from-source formula classes are not equal but we
// 1449:     # want to equate them to be the same thing here given mixing bottle and
// 1450:     # from-source installs of the same formula within the same operation
// 1451:     # doesn't make sense.
// 1452:     self.class.fetched.find do |fetched_formula|
// 1453:       fetched_formula.full_name == formula.full_name && fetched_formula.active_spec_sym == formula.active_spec_sym
// 1454:     end
// 1455:   end
// 1456:
// 1457:   sig { params(quiet: T::Boolean, enqueue: T::Boolean).void }
// 1458:   def fetch_bottle_tab(quiet: false, enqueue: false)
// 1459:     return if @fetch_bottle_tab
// 1460:     return if formula.local_bottle_path
// 1461:
// 1462:     if (bottle = api_bottle || formula.bottle) &&
// 1463:        (manifest_resource = bottle.github_packages_manifest_resource) &&
// 1464:        enqueue
// 1465:       download_queue.enqueue(manifest_resource) unless manifest_resource.downloaded_and_valid?
// 1466:     else
// 1467:       begin
// 1468:         formula.fetch_bottle_tab(quiet: quiet)
// 1469:       rescue DownloadError, Resource::BottleManifest::Error
// 1470:         # do nothing
// 1471:       end
// 1472:     end
// 1473:
// 1474:     @fetch_bottle_tab = T.let(true, T.nilable(TrueClass))
// 1475:   end
// 1476:
// 1477:   sig { void }
// 1478:   def fetch
// 1479:     enqueue_fetch
// 1480:     download_queue.fetch(heading: "Fetching downloads for: #{Formatter.identifier(formula.full_name)}")
// 1481:   end
// 1482:
// 1483:   sig { void }
// 1484:   def enqueue_fetch
// 1485:     return if previously_fetched_formula
// 1486:
// 1487:     downloadable_object = T.let(nil, T.nilable(Downloadable))
// 1488:     check_attestation = T.let(false, T::Boolean)
// 1489:     local_bottle_path = formula.local_bottle_path
// 1490:     bottle_install = !only_deps? && local_bottle_path.nil? && pour_bottle?(output_warning: true)
// 1491:     # We skip bottle installs from local bottle paths, as these are done in CI
// 1492:     # as part of the build lifecycle before attestations are produced.
// 1493:     verify_attestation = bottle_install && verify_bottle_attestation?
// 1494:     bottle_download = @enqueued_bottle_download
// 1495:     bottle_download = enqueue_bottle_download(stage: false) if bottle_download.nil? && bottle_install && @ran_prelude
// 1496:
// 1497:     fetch_dependencies
// 1498:
// 1499:     return if only_deps?
// 1500:     return if local_bottle_path
// 1501:
// 1502:     downloadable_object = bottle_download || downloadable
// 1503:     if bottle_install
// 1504:       if bottle_download.nil?
// 1505:         fetch_bottle_tab(enqueue: true)
// 1506:         check_attestation = verify_attestation && !downloadable_object.cached_download.exist?
// 1507:       end
// 1508:     else
// 1509:       @formula = Homebrew::API::Formula.source_download_formula(formula) if formula.loaded_from_api?
// 1510:
// 1511:       formula.enqueue_resources_and_patches(download_queue:)
// 1512:
// 1513:       downloadable_object = downloadable
// 1514:     end
// 1515:
// 1516:     # Check attestation after download completes. Skip downloads already
// 1517:     # enqueued (with staging) by `prelude_fetch` so a completed early fetch is
// 1518:     # not requeued and reported a second time.
// 1519:     download_queue.enqueue(downloadable_object, check_attestation:) if @enqueued_bottle_download.nil?
// 1520:
// 1521:     self.class.fetched << formula
// 1522:   rescue CannotInstallFormulaError
// 1523:     if (cached_download = downloadable_object&.cached_download)&.exist?
// 1524:       cached_download.unlink
// 1525:     end
// 1526:
// 1527:     raise
// 1528:   end
// 1529:
// 1530:   # Start the formula's own bottle download without waiting for its bottle
// 1531:   # manifest or dependency resolution; both call sites have already checked
// 1532:   # `pour_bottle?`.
// 1533:   sig { params(stage: T::Boolean).returns(T.nilable(Downloadable)) }
// 1534:   def enqueue_bottle_download(stage:)
// 1535:     return if only_deps? || formula.local_bottle_path
// 1536:
// 1537:     bottle_download = downloadable
// 1538:     check_attestation = verify_bottle_attestation? && !bottle_download.cached_download.exist?
// 1539:     download_queue.enqueue(bottle_download, check_attestation:, stage:)
// 1540:     bottle_download
// 1541:   end
// 1542:
// 1543:   sig { returns(T::Boolean) }
// 1544:   def verify_bottle_attestation?
// 1545:     # We skip `gh` to avoid a bootstrapping cycle, in the off-chance a user attempts
// 1546:     # to explicitly `brew install gh` without already having a version for bootstrapping.
// 1547:     Homebrew::EnvConfig.verify_attestations? &&
// 1548:       (formula.tap&.core_tap? || false) &&
// 1549:       formula.name != "gh"
// 1550:   end
// 1551:
// 1552:   sig { returns(Downloadable) }
// 1553:   def downloadable
// 1554:     if (bottle_path = formula.local_bottle_path)
// 1555:       Resource::Local.new(bottle_path.to_s)
// 1556:     elsif pour_bottle?
// 1557:       bottle = api_bottle || formula.bottle
// 1558:       odie "Bottle for #{formula.full_name} is unavailable." if bottle.nil?
// 1559:
// 1560:       bottle
// 1561:     else
// 1562:       resource = formula.resource
// 1563:       odie "Resource for #{formula.full_name} is unavailable." if resource.nil?
// 1564:
// 1565:       resource
// 1566:     end
// 1567:   end
// 1568:
// 1569:   sig { returns(T.nilable(Bottle)) }
// 1570:   def api_bottle
// 1571:     return @api_bottle if @api_bottle_loaded
// 1572:
// 1573:     @api_bottle_loaded = true
// 1574:     return unless formula.loaded_from_internal_api?
// 1575:     return unless formula.core_formula?
// 1576:
// 1577:     @api_bottle = Homebrew::API::FormulaBottle.bottle(
// 1578:       name:           formula.name,
// 1579:       formula_struct: Homebrew::API::Internal.formula_struct(formula.name),
// 1580:     )
// 1581:   end
// 1582:
// 1583:   sig { void }
// 1584:   def pour
// 1585:     HOMEBREW_CELLAR.cd do
// 1586:       downloadable_object = downloadable
// 1587:       ohai "Pouring #{downloadable_object.downloader.basename}"
// 1588:
// 1589:       formula.rack.mkpath
// 1590:
// 1591:       # Download queue may have already extracted the bottle to a temporary directory.
// 1592:       # We cannot rely on `download_queue` here as dependencies may be poured by another installer.
// 1593:       if downloadable_object.is_a?(Bottle) &&
// 1594:          (bottle_poured_file = downloadable_object.staged_path_from_download_queue_marker).exist?
// 1595:         bottle_tmp_keg = downloadable_object.staged_path_from_download_queue
// 1596:         FileUtils.rm(bottle_poured_file)
// 1597:         FileUtils.mv(bottle_tmp_keg, formula.prefix)
// 1598:         bottle_tmp_keg.parent.rmdir_if_possible
// 1599:       elsif downloadable_object.is_a?(Bottle)
// 1600:         # Retries with a fresh download if the cached bottle turns out corrupt.
// 1601:         downloadable_object.stage
// 1602:       else
// 1603:         downloadable_object.downloader.stage
// 1604:       end
// 1605:     end
// 1606:
// 1607:     Tab.clear_cache
// 1608:
// 1609:     tab = Utils::Bottles.load_tab(formula)
// 1610:
// 1611:     # fill in missing/outdated parts of the tab
// 1612:     # keep in sync with Tab#to_bottle_hash
// 1613:     tab.used_options = []
// 1614:     tab.unused_options = []
// 1615:     tab.built_as_bottle = true
// 1616:     tab.poured_from_bottle = true
// 1617:     tab.loaded_from_api = formula.loaded_from_api?
// 1618:     tab.loaded_from_internal_api = formula.loaded_from_internal_api?
// 1619:     tab.installed_on_request = installed_on_request?
// 1620:     tab.time = Time.now.to_i
// 1621:     tab.aliases = formula.aliases
// 1622:     tab.arch = Hardware::CPU.arch
// 1623:     tab.source["versions"]["stable"] = T.must(formula.stable).version&.to_s
// 1624:     tab.source["versions"]["version_scheme"] = formula.version_scheme
// 1625:     tab.source["path"] = formula.specified_path.to_s
// 1626:     tab.source["tap_git_head"] = formula.tap&.installed? ? formula.tap&.git_head : nil
// 1627:     tab.tap = formula.tap
// 1628:     tab.write
// 1629:
// 1630:     keg = Keg.new(formula.prefix)
// 1631:     skip_linkage = formula.bottle_specification.skip_relocation?(tab:)
// 1632:     if Homebrew::EnvConfig.bottle_domain_custom? && tab.changed_files.nil?
// 1633:       if self.class.show_missing_bottle_metadata_warning?
// 1634:         opoo <<~EOS
// 1635:           No bottle relocation metadata was found for this `HOMEBREW_BOTTLE_DOMAIN`.
// 1636:           Homebrew will perform full relocation. Ask the mirror operator to provide
// 1637:           an OCI registry proxy of `ghcr.io` that includes manifests and their
// 1638:           `sh.brew.tab` annotations, then use `HOMEBREW_ARTIFACT_DOMAIN` instead.
// 1639:         EOS
// 1640:       end
// 1641:       skip_linkage = false
// 1642:     end
// 1643:     keg.replace_placeholders_with_locations(tab.changed_files, skip_linkage:)
// 1644:
// 1645:     cellar = formula.bottle_specification.tag_to_cellar(Utils::Bottles.tag)
// 1646:     return if BottleSpecification::RELOCATABLE_CELLARS.include?(cellar)
// 1647:
// 1648:     prefix = Pathname(cellar).parent.to_s
// 1649:     return if cellar == HOMEBREW_CELLAR.to_s && prefix == HOMEBREW_PREFIX.to_s
// 1650:
// 1651:     return unless ENV["HOMEBREW_RELOCATE_BUILD_PREFIX"]
// 1652:
// 1653:     keg.relocate_build_prefix(keg, prefix, HOMEBREW_PREFIX)
// 1654:   end
// 1655:
// 1656:   sig { override.params(output: T.nilable(String)).void }
// 1657:   def problem_if_output(output)
// 1658:     return unless output
// 1659:
// 1660:     opoo output
// 1661:     @show_summary_heading = true
// 1662:   end
// 1663:
// 1664:   sig { void }
// 1665:   def audit_installed
// 1666:     unless formula.keg_only?
// 1667:       problem_if_output(check_env_path(formula.bin))
// 1668:       problem_if_output(check_env_path(formula.sbin))
// 1669:     end
// 1670:     super
// 1671:   end
// 1672:
// 1673:   sig { returns(T::Array[Formula]) }
// 1674:   def self.locked
// 1675:     @locked ||= T.let([], T.nilable(T::Array[Formula]))
// 1676:   end
// 1677:
// 1678:   sig { void }
// 1679:   def forbidden_license_check
// 1680:     forbidden_licenses = Homebrew::EnvConfig.forbidden_licenses.to_s.dup
// 1681:     SPDX::ALLOWED_LICENSE_SYMBOLS.each do |s|
// 1682:       pattern = /#{s.to_s.tr("_", " ")}/i
// 1683:       forbidden_licenses.sub!(pattern, s.to_s)
// 1684:     end
// 1685:
// 1686:     invalid_licenses = []
// 1687:     forbidden_licenses = forbidden_licenses.split.each_with_object({}) do |license, hash|
// 1688:       license_sym = license.to_sym
// 1689:       license = license_sym if SPDX::ALLOWED_LICENSE_SYMBOLS.include?(license_sym)
// 1690:
// 1691:       unless SPDX.valid_license?(license)
// 1692:         invalid_licenses << license
// 1693:         next
// 1694:       end
// 1695:
// 1696:       hash[license] = SPDX.license_version_info(license)
// 1697:     end
// 1698:
// 1699:     if invalid_licenses.present?
// 1700:       opoo <<~EOS
// 1701:         `$HOMEBREW_FORBIDDEN_LICENSES` contains invalid license identifiers: #{invalid_licenses.to_sentence}
// 1702:         These licenses will not be forbidden. See the valid SPDX license identifiers at:
// 1703:           #{Formatter.url("https://spdx.org/licenses/")}
// 1704:         And the licenses for a formula with:
// 1705:           brew info <formula>
// 1706:       EOS
// 1707:     end
// 1708:
// 1709:     return if forbidden_licenses.blank?
// 1710:
// 1711:     owner = Homebrew::EnvConfig.forbidden_owner
// 1712:     owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 1713:       "\n#{contact}"
// 1714:     end
// 1715:
// 1716:     unless ignore_deps?
// 1717:       compute_dependencies.each do |dep|
// 1718:         dep_f = dep.to_formula
// 1719:         next unless SPDX.licenses_forbid_installation? dep_f.license, forbidden_licenses
// 1720:
// 1721:         raise CannotInstallFormulaError, <<~EOS
// 1722:           The installation of #{formula.name} has a dependency on #{dep.name} where all
// 1723:           its licenses were forbidden by #{owner} in `$HOMEBREW_FORBIDDEN_LICENSES`:
// 1724:             #{SPDX.license_expression_to_string dep_f.license}#{owner_contact}
// 1725:         EOS
// 1726:       end
// 1727:     end
// 1728:
// 1729:     return if only_deps?
// 1730:
// 1731:     return unless SPDX.licenses_forbid_installation? formula.license, forbidden_licenses
// 1732:
// 1733:     raise CannotInstallFormulaError, <<~EOS
// 1734:       #{formula.name}'s licenses are all forbidden by #{owner} in `$HOMEBREW_FORBIDDEN_LICENSES`:
// 1735:         #{SPDX.license_expression_to_string formula.license}#{owner_contact}
// 1736:     EOS
// 1737:   end
// 1738:
// 1739:   sig { params(formula_only: T::Boolean).void }
// 1740:   def forbidden_tap_check(formula_only: false)
// 1741:     return if Tap.allowed_taps.blank? && Tap.forbidden_taps.blank?
// 1742:
// 1743:     owner = Homebrew::EnvConfig.forbidden_owner
// 1744:     owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 1745:       "\n#{contact}"
// 1746:     end
// 1747:
// 1748:     # Check the formula itself before its dependencies, since dependency
// 1749:     # resolution can trigger downloads via `compute_dependencies`.
// 1750:     unless only_deps?
// 1751:       formula_tap = formula.tap
// 1752:       if formula_tap.present? && (!formula_tap.allowed_by_env? || formula_tap.forbidden_by_env?)
// 1753:         formula_error_message = "The installation of #{formula.full_name} has the tap #{formula_tap}\n" \
// 1754:                                 "but #{owner} "
// 1755:         unless formula_tap.allowed_by_env?
// 1756:           formula_error_message << "has not allowed this tap in `$HOMEBREW_ALLOWED_TAPS`"
// 1757:         end
// 1758:         formula_error_message << " and\n" if !formula_tap.allowed_by_env? && formula_tap.forbidden_by_env?
// 1759:         if formula_tap.forbidden_by_env?
// 1760:           formula_error_message << "has forbidden this tap in `$HOMEBREW_FORBIDDEN_TAPS`"
// 1761:         end
// 1762:         formula_error_message << ".#{owner_contact}"
// 1763:
// 1764:         raise CannotInstallFormulaError, formula_error_message
// 1765:       end
// 1766:     end
// 1767:
// 1768:     return if formula_only
// 1769:     return if ignore_deps?
// 1770:
// 1771:     compute_dependencies.each do |dep|
// 1772:       dep_tap = dep.tap
// 1773:       next if dep_tap.blank? || (dep_tap.allowed_by_env? && !dep_tap.forbidden_by_env?)
// 1774:
// 1775:       error_message = "The installation of #{formula.name} has a dependency #{dep.name}\n" \
// 1776:                       "from the #{dep_tap} tap but #{owner} "
// 1777:       error_message << "has not allowed this tap in `$HOMEBREW_ALLOWED_TAPS`" unless dep_tap.allowed_by_env?
// 1778:       error_message << " and\n" if !dep_tap.allowed_by_env? && dep_tap.forbidden_by_env?
// 1779:       error_message << "has forbidden this tap in `$HOMEBREW_FORBIDDEN_TAPS`" if dep_tap.forbidden_by_env?
// 1780:       error_message << ".#{owner_contact}"
// 1781:
// 1782:       raise CannotInstallFormulaError, error_message
// 1783:     end
// 1784:   end
// 1785:
// 1786:   sig { params(formula_only: T::Boolean).void }
// 1787:   def forbidden_formula_check(formula_only: false)
// 1788:     forbidden_formulae = Set.new(Homebrew::EnvConfig.forbidden_formulae.to_s.split)
// 1789:     return if forbidden_formulae.blank?
// 1790:
// 1791:     owner = Homebrew::EnvConfig.forbidden_owner
// 1792:     owner_contact = if (contact = Homebrew::EnvConfig.forbidden_owner_contact.presence)
// 1793:       "\n#{contact}"
// 1794:     end
// 1795:
// 1796:     unless only_deps?
// 1797:       formula_name = if forbidden_formulae.include?(formula.name)
// 1798:         formula.name
// 1799:       elsif forbidden_formulae.include?(formula.full_name)
// 1800:         formula.full_name
// 1801:       end
// 1802:
// 1803:       if formula_name
// 1804:         raise CannotInstallFormulaError, <<~EOS
// 1805:           The installation of #{formula_name} was forbidden by #{owner}
// 1806:           in `$HOMEBREW_FORBIDDEN_FORMULAE`.#{owner_contact}
// 1807:         EOS
// 1808:       end
// 1809:     end
// 1810:
// 1811:     return if formula_only
// 1812:     return if ignore_deps?
// 1813:
// 1814:     compute_dependencies.each do |dep|
// 1815:       dep_name = if forbidden_formulae.include?(dep.name)
// 1816:         dep.name
// 1817:       elsif dep.tap.present? &&
// 1818:             (dep_full_name = "#{dep.tap}/#{dep.name}") &&
// 1819:             forbidden_formulae.include?(dep_full_name)
// 1820:         dep_full_name
// 1821:       else
// 1822:         next
// 1823:       end
// 1824:
// 1825:       raise CannotInstallFormulaError, <<~EOS
// 1826:         The installation of #{formula.name} has a dependency #{dep_name}
// 1827:         but the #{dep_name} formula was forbidden by #{owner} in `$HOMEBREW_FORBIDDEN_FORMULAE`.#{owner_contact}
// 1828:       EOS
// 1829:     end
// 1830:   end
// 1831:
// 1832:   private
// 1833:
// 1834:   sig { returns(T::Boolean) }
// 1835:   def auto_link_versioned_keg_only?
// 1836:     return false unless installed_on_request?
// 1837:     return false unless formula.keg_only?
// 1838:     return false unless formula.keg_only_reason.versioned_formula?
// 1839:     return false if formula.any_version_installed?
// 1840:     return false if formula.link_overwrite_formulae.any? do |related_formula|
// 1841:       related_formula.any_version_installed? ||
// 1842:       (related_formula.name == formula.unversioned_formula_name && related_formula.keg_only?)
// 1843:     end
// 1844:
// 1845:     true
// 1846:   end
// 1847:
// 1848:   sig { void }
// 1849:   def lock
// 1850:     return unless self.class.locked.empty?
// 1851:
// 1852:     unless ignore_deps?
// 1853:       formula.recursive_dependencies.each do |dep|
// 1854:         self.class.locked << dep.to_formula
// 1855:       end
// 1856:     end
// 1857:     self.class.locked.unshift(formula)
// 1858:     self.class.locked.uniq!
// 1859:     self.class.locked.each(&:lock)
// 1860:     @hold_locks = true
// 1861:   end
// 1862:
// 1863:   sig { void }
// 1864:   def unlock
// 1865:     return unless @hold_locks
// 1866:
// 1867:     self.class.locked.each(&:unlock)
// 1868:     self.class.locked.clear
// 1869:     @hold_locks = false
// 1870:   end
// 1871:
// 1872:   sig { void }
// 1873:   def puts_requirement_messages
// 1874:     return if @requirement_messages.empty?
// 1875:
// 1876:     $stderr.puts @requirement_messages
// 1877:   end
// 1878: end
// 1879:
// 1880: require "extend/os/formula_installer"
