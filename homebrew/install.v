module homebrew

import brew_runtime
import homebrew.api

// Translated from Homebrew/brew `install.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct InstallDependencyPlan {
pub:
	name      string
	full_name string
	installed bool
}

pub struct FormulaInstallCandidate {
pub:
	name                string
	full_name           string
	ignore_dependencies bool
	dependencies        []InstallDependencyPlan
	step_error          string
	prelude_fetch_error string
	prelude_error       string
	enqueue_fetch_error string
	install_error       string
	already_attempted   bool
	linked              bool
	outdated            bool
	head                bool
	no_install_upgrade  bool
	linked_kegs         []InstallKegPlan
}

pub struct CaskInstallCandidate {
pub:
	full_name            string
	installed            bool
	dependencies         []InstallDependencyPlan
	runtime_dependencies []InstallDependencyPlan
	installed_version    string
	version              string
	outdated             bool
	source_download      string
	prelude_fetch_error  string
	enqueue_error        string
	install_error        string
}

pub enum InstallDiagnosticKind {
	supported_configuration_checks
	preinstall_checks
	fatal_preinstall_checks
	fatal_build_from_source_checks
	build_from_source_checks
}

pub struct InstallDiagnosticCall {
pub:
	kind  InstallDiagnosticKind
	fatal bool
}

pub struct InstallPreinstallContext {
pub:
	platform               InstallPlatform
	must_exist_directories []string
	all_fatal              bool
}

pub struct InstallPreinstallResult {
pub:
	diagnostics         []InstallDiagnosticCall
	directories_created []string
}

pub struct InstallPreinstallOnceResult {
pub:
	ran    bool
	result InstallPreinstallResult
}

pub struct InstallPreinstallMemo {
pub mut:
	nonfatal_complete bool
	fatal_complete    bool
}

pub enum InstallQueueEventKind {
	assign_download_queue
	prelude_fetch
	download_bottle_manifests
	prelude
	enqueue_fetch
	download_formulae
	enqueue_source_download
	download_cask_files
	enqueue_cask_downloads
	shutdown
}

pub struct InstallQueueEvent {
pub:
	kind          InstallQueueEventKind
	package       string
	heading       string
	metadata_only bool
}

pub struct InstallFormulaFetchOptions {
pub:
	metadata_only           bool
	fetch_after_enqueue     bool = true
	shutdown_download_queue bool = true
	show_downloads_heading  bool = true
	failed_downloads        []string
}

pub struct InstallFormulaFetchResult {
pub:
	candidates []FormulaInstallCandidate
	events     []InstallQueueEvent
	errors     []string
	shutdown   bool
}

pub struct InstallCaskEnqueueResult {
pub:
	enqueued         []string
	source_downloads []string
	events           []InstallQueueEvent
	errors           []string
}

pub struct InstallFormulaBatchOptions {
pub:
	dry_run        bool
	dry_run_action string = 'install'
}

pub struct InstallFormulaBatchResult {
pub:
	installed []string
	cleaned   []string
	upgraded  []string
	events    []string
	errors    []string
	output    string
}

pub struct InstallKegPlan {
pub:
	path      string
	directory bool
	linked    bool
}

pub struct InstallFormulaResult {
pub:
	name          string
	upgrade       bool
	skipped       bool
	unlinked_kegs []string
	relinked_kegs []string
	events        []string
	error         string
}

pub struct InstallAskInput {
pub:
	action          string = 'installation'
	stdin_tty       bool
	stdout_tty      bool
	characters      []int
	interrupt_index int = -1
}

pub struct InstallAskResult {
pub:
	accepted bool
	exited   bool
	consumed int
	output   string
}

pub struct DryRunCaskPlan {
pub:
	output           string
	dependency_names []string
}

pub struct InstallAskPlan {
pub:
	output        string
	prompt_needed bool
	action        string
}

pub struct FormulaBottleSizes {
pub:
	has_download_size  bool
	download_size      i64
	has_installed_size bool
	installed_size     i64
}

pub struct InstallTotalSizes {
pub:
	download  i64
	installed i64
}

pub struct InstallPlatform {
pub:
	prefix                   string
	intel                    bool
	in_rosetta2              bool
	arm                      bool
	ppc                      bool
	macos_arm_default_prefix string
	default_prefix           string
}

pub enum InstallDecisionMessageKind {
	info
	warning
	error
}

pub struct InstallDecisionMessage {
pub:
	kind InstallDecisionMessageKind
	text string
}

pub struct FormulaInstallState {
pub:
	any_version_installed     bool
	prefix_installed          bool
	latest_head_version       string
	head_version_outdated     bool
	installed_tap_name        string
	keg_only                  bool
	optlinked                 bool
	outdated                  bool
	pinned                    bool
	no_install_upgrade        bool
	linked                    bool
	linked_version            string
	pkg_version               string
	old_formula_full_name     string
	old_formula_version       string
	old_formula_linked        bool
	old_formula_keg_only      bool
	migration_needed          bool
	oldname_to_migrate        string
	opt_prefix_exists         bool
	installed_on_request      bool
	keg_only_versioned        bool
	related_formula_installed bool
}

pub struct InstallFormulaCheckOptions {
pub:
	head              bool
	fetch_head        bool
	only_dependencies bool
	force             bool
	quiet             bool
	skip_link         bool
	overwrite         bool
}

pub struct FormulaInstallDecision {
pub:
	install                   bool
	mark_installed_on_request bool
	messages                  []InstallDecisionMessage
}

pub struct FormulaInstallersConfig {
pub:
	installed_on_request        bool = true
	build_bottle                bool
	force_bottle                bool
	bottle_arch                 string
	ignore_deps                 bool
	only_deps                   bool
	include_test_formulae       []string
	build_from_source_formulae  []string
	compiler                    string
	git                         bool
	interactive                 bool
	keep_tmp                    bool
	debug_symbols               bool
	force                       bool
	overwrite                   bool
	debug                       bool
	quiet                       bool
	verbose                     bool
	dry_run                     bool
	skip_post_install           bool
	skip_link                   bool
	head                        bool
	used_options                map[string][]string
	states                      map[string]FormulaInstallState
	migration_errors            map[string]string
	pour_bottle_allowed         bool = true
	bottle_locations_compatible bool = true
	prefix                      string
	cellar                      string
	temporary_cellar            string
}

fn formula_pkg_version(formula api.PackageReference, state FormulaInstallState) string {
	if state.pkg_version.len > 0 {
		return state.pkg_version
	}
	if formula.revision > 0 {
		return '${formula.stable_version}_${formula.revision}'
	}
	return formula.stable_version
}

fn install_decision_message(kind InstallDecisionMessageKind, text string) InstallDecisionMessage {
	return InstallDecisionMessage{
		kind: kind
		text: text
	}
}

pub fn install_formula_decision(formula api.PackageReference, state FormulaInstallState,
	options InstallFormulaCheckOptions) !FormulaInstallDecision {
	if !options.head && formula.stable_version.len == 0 {
		return error('${formula.full_name} is a HEAD-only formula.\nTo install it, run:\n  brew install --HEAD ${formula.full_name}')
	}
	if options.head && formula.head_version.len == 0 {
		return error('No head is defined for ${formula.full_name}')
	}
	new_head_installed := state.latest_head_version.len > 0 && !state.head_version_outdated
	if state.any_version_installed && formula.tap.len > 0 && state.installed_tap_name.len > 0 && state.installed_tap_name != formula.tap {
		return error('${formula.name} was installed from the ${state.installed_tap_name} tap\nbut you are trying to install it from the ${formula.tap} tap.\nFormulae with the same name from different taps cannot be installed at the same time.\n\nTo install this version, you must first uninstall the existing formula:\n  brew uninstall ${formula.name}\nThen you can install the desired version:\n  brew install ${formula.full_name}')
	}
	mut messages := []InstallDecisionMessage{}
	pkg_version := formula_pkg_version(formula, state)
	if state.keg_only && state.any_version_installed && state.optlinked && !options.force {
		if state.outdated {
			if !state.no_install_upgrade && !state.pinned {
				messages << install_decision_message(.info, '${formula.name} ${state.linked_version} is already installed but outdated (so it will be upgraded).')
				return FormulaInstallDecision{
					install: true
					messages: messages
				}
			}
			unpin := if state.pinned { 'brew unpin ${formula.full_name} && ' } else { '' }
			messages << install_decision_message(.error, '${formula.full_name} ${state.linked_version} is already installed.\nTo upgrade to ${pkg_version}, run:\n  ${unpin}brew upgrade ${formula.full_name}')
		} else if options.only_dependencies {
			return FormulaInstallDecision{
				install: true
			}
		} else if !options.quiet {
			messages << install_decision_message(.warning, '${formula.full_name} ${pkg_version} is already installed and up-to-date.\nTo reinstall ${pkg_version}, run:\n  brew reinstall ${formula.name}')
		}
	} else if (options.head && new_head_installed) || state.prefix_installed {
		installed_version := if options.head { state.latest_head_version } else { pkg_version }
		mut message := '${formula.full_name} ${installed_version} is already installed'
		if state.linked && state.linked_version != installed_version {
			if !options.quiet {
				message += '.\nThe currently linked version is: ${state.linked_version}'
				messages << install_decision_message(.warning, message)
			}
		} else if options.only_dependencies || (!state.linked && options.overwrite) {
			return FormulaInstallDecision{
				install: true
			}
		} else if !state.linked || state.keg_only {
			messages << install_decision_message(.warning, "${message}, it's just not linked.\nTo link this version, run:\n  brew link ${formula.full_name}")
		} else if !options.quiet {
			messages << install_decision_message(.warning, '${message} and up-to-date.\nTo reinstall ${pkg_version}, run:\n  brew reinstall ${formula.name}')
		}
	} else if !state.any_version_installed && state.old_formula_full_name.len > 0 {
		mut message := '${state.old_formula_full_name} ${state.old_formula_version} already installed'
		if !state.old_formula_linked && !state.old_formula_keg_only {
			message += ", it's just not linked.\nTo link this version, run:\n  brew link ${state.old_formula_full_name}"
		} else if options.quiet {
			message = ''
		} else {
			message += '.'
		}
		if message.len > 0 {
			messages << install_decision_message(.warning, message)
		}
	} else if state.migration_needed && !options.force {
		messages << install_decision_message(.warning, "${state.oldname_to_migrate} is already installed, it's just not migrated.\nTo migrate this formula, run:\n  brew migrate ${formula.full_name}\nOr to force-install it, run:\n  brew install ${formula.full_name} --force")
	} else if state.linked {
		message := '${formula.name} ${state.linked_version} is already installed'
		if state.outdated && !options.head {
			if !state.no_install_upgrade && !state.pinned {
				messages << install_decision_message(.info, '${message} but outdated (so it will be upgraded).')
				return FormulaInstallDecision{
					install: true
					messages: messages
				}
			}
			unpin := if state.pinned { 'brew unpin ${formula.full_name} && ' } else { '' }
			messages << install_decision_message(.error, '${message}\nTo upgrade to ${pkg_version}, run:\n  ${unpin}brew upgrade ${formula.full_name}')
		} else if options.only_dependencies || options.skip_link {
			return FormulaInstallDecision{
				install: true
			}
		} else {
			messages << install_decision_message(.error, '${message}\nTo install ${pkg_version}, first run:\n  brew unlink ${formula.name}')
		}
	} else {
		return FormulaInstallDecision{
			install: true
		}
	}
	return FormulaInstallDecision{
		mark_installed_on_request: state.opt_prefix_exists && !state.installed_on_request
		messages: messages
	}
}

pub fn formula_installers_plan(formulae []api.PackageReference,
	config FormulaInstallersConfig) ![]FormulaInstaller {
	mut installers := []FormulaInstaller{}
	for formula in formulae {
		state := config.states[formula.full_name] or { FormulaInstallState{} }
		if state.migration_needed && config.force {
			if migration_error := config.migration_errors[formula.full_name] {
				return error(migration_error)
			}
		}
		used_options := config.used_options[formula.full_name] or { []string{} }
		installers << new_formula_installer(formula, FormulaInstallerConfig{
			installed_on_request: config.installed_on_request
			build_bottle: config.build_bottle
			force_bottle: config.force_bottle
			bottle_arch: config.bottle_arch
			ignore_deps: config.ignore_deps
			only_deps: config.only_deps
			include_test_formulae: config.include_test_formulae
			build_from_source_formulae: config.build_from_source_formulae
			compiler: config.compiler
			git: config.git
			interactive: config.interactive
			keep_tmp: config.keep_tmp
			debug_symbols: config.debug_symbols
			force: config.force
			overwrite: config.overwrite
			debug: config.debug
			quiet: config.quiet
			verbose: config.verbose
			skip_post_install: config.skip_post_install
			skip_link: config.skip_link
			head: config.head
			options: used_options
			pour_bottle_allowed: config.pour_bottle_allowed
			bottle_locations_compatible: config.bottle_locations_compatible
			keg_only_versioned: state.keg_only_versioned
			any_version_installed: state.any_version_installed
			related_formula_installed: state.related_formula_installed
			prefix: config.prefix
			cellar: config.cellar
			temporary_cellar: config.temporary_cellar
		})
	}
	return installers
}

fn install_plural(noun string, count int) string {
	if count == 1 {
		return noun
	}
	return match noun {
		'formula' { 'formulae' }
		'dependency' { 'dependencies' }
		else { '${noun}s' }
	}
}

fn install_to_sentence(values []string) string {
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]} and ${values[1]}' }
		else { '${values[..values.len - 1].join(', ')}, and ${values.last()}' }
	}
}

fn unique_install_names(values []string) []string {
	mut seen := map[string]bool{}
	mut unique := []string{}
	for value in values {
		if !seen[value] {
			seen[value] = true
			unique << value
		}
	}
	return unique
}

// check_cc_argument is the output-producing part of check_cc_argv. The tier
// detail itself belongs to Diagnostic::Finding and remains outside this slice.
pub fn check_cc_argument(cc string) ?string {
	if cc.len == 0 {
		return none
	}
	return 'You passed `--cc=${cc}`.\n\nThis is a Tier 3 configuration.'
}

pub fn check_install_prefix(platform InstallPlatform) ! {
	if (platform.intel || platform.in_rosetta2) && platform.prefix == platform.macos_arm_default_prefix {
		if platform.in_rosetta2 {
			return error('Cannot install under Rosetta 2 in ARM default prefix (${platform.prefix})!\nTo rerun under ARM use:\n    arch -arm64 brew install ...\nTo install under x86_64, install Homebrew into ${platform.default_prefix}.')
		}
		return error('Cannot install on Intel processor in ARM default prefix (${platform.prefix})!')
	}
	if platform.arm && platform.prefix == platform.default_prefix {
		return error('Cannot install in Homebrew on ARM processor in Intel default prefix (${platform.prefix})!\nPlease create a new installation in ${platform.macos_arm_default_prefix} using one of the\n"Alternative Installs" from:\n  https://docs.brew.sh/Installation\nYou can migrate your previously installed formula list with:\n  brew bundle dump')
	}
}

pub fn check_install_cpu(ppc bool) ! {
	if ppc {
		return error("Sorry, Homebrew does not support your computer's CPU architecture!\nFor PowerPC Mac (PPC32/PPC64BE) support, see:\n  https://github.com/mistydemeo/tigerbrew")
	}
}

pub fn combined_fetch_downloads_heading(formula_names []string, cask_names []string) ?string {
	mut targets := formula_names.clone()
	targets << cask_names
	if targets.len == 0 {
		return none
	}
	return 'Fetching downloads for: ${install_to_sentence(targets)}'
}

pub fn ask_prompt_needed(planned_names []string, requested_names []string, force bool,
	named bool) bool {
	if planned_names.len == 0 {
		return false
	}
	if force {
		return true
	}
	if !named {
		return true
	}
	return planned_names.any(it !in requested_names)
}

pub fn dry_run_action(action string) string {
	return match action {
		'reinstallation' { 'reinstall' }
		'upgrade' { 'upgrade' }
		else { 'install' }
	}
}

pub fn reject_failed_downloads(candidates []FormulaInstallCandidate, failed_names []string) []FormulaInstallCandidate {
	if failed_names.len == 0 {
		return candidates.clone()
	}
	return candidates.filter(it.name !in failed_names)
}

pub fn select_install_candidates(candidates []FormulaInstallCandidate) []FormulaInstallCandidate {
	return candidates.filter(it.step_error.len == 0)
}

pub fn dry_run_dependencies_plan(formula_name string, dependencies []InstallDependencyPlan,
	skip_formula_names []string) string {
	mut install_names := []string{}
	mut upgrade_names := []string{}
	for dependency in dependencies {
		full_name := if dependency.full_name.len > 0 {
			dependency.full_name
		} else {
			dependency.name
		}
		if full_name in skip_formula_names {
			continue
		}
		name := if dependency.name.len > 0 { dependency.name } else { full_name }
		if dependency.installed {
			upgrade_names << name
		} else {
			install_names << name
		}
	}
	mut output := ''
	if install_names.len > 0 {
		output += '==> Would install ${install_names.len} ${install_plural('dependency', install_names.len)} for ${formula_name}:\n${install_names.join(' ')}\n'
	}
	if upgrade_names.len > 0 {
		output += '==> Would upgrade ${upgrade_names.len} ${install_plural('dependency', upgrade_names.len)} for ${formula_name}:\n${upgrade_names.join(' ')}\n'
	}
	return output
}

pub fn dry_run_formulae_plan(candidates []FormulaInstallCandidate, action string) string {
	if candidates.len == 0 {
		return ''
	}
	names := candidates.map(if it.name.len > 0 { it.name } else { it.full_name })
	mut output := '==> Would ${action} ${names.len} ${install_plural('formula', names.len)}:\n${names.join(' ')}\n'
	for candidate in candidates {
		if candidate.ignore_dependencies {
			continue
		}
		name := if candidate.name.len > 0 { candidate.name } else { candidate.full_name }
		output += dry_run_dependencies_plan(name, candidate.dependencies, []string{})
	}
	return output
}

pub fn formulae_ask_prompt_needed(candidates []FormulaInstallCandidate,
	dependant_upgradeable []string) bool {
	return candidates.any(!it.ignore_dependencies && it.dependencies.len > 0) || dependant_upgradeable.len > 0
}

pub fn ask_formulae_plan(candidates []FormulaInstallCandidate, dependant_upgradeable []string,
	action string, prompt bool) InstallAskPlan {
	if candidates.len == 0 {
		return InstallAskPlan{}
	}
	formula_names := candidates.map(if it.full_name.len > 0 { it.full_name } else { it.name })
	force := formulae_ask_prompt_needed(candidates, dependant_upgradeable)
	return InstallAskPlan{
		output: dry_run_formulae_plan(candidates, dry_run_action(action))
		prompt_needed: prompt && ask_prompt_needed(formula_names, formula_names, force, true)
		action: action
	}
}

pub fn dry_run_casks_plan(casks []CaskInstallCandidate, action string, skip_cask_dependencies bool,
	include_installed bool) DryRunCaskPlan {
	casks_to_print := if include_installed { casks.clone() } else { casks.filter(!it.installed) }
	mut output := ''
	if casks_to_print.len > 0 {
		output += '==> Would ${action} ${casks_to_print.len} ${install_plural('cask', casks_to_print.len)}:\n${casks_to_print.map(it.full_name).join(' ')}\n'
	}
	mut all_dependency_names := []string{}
	for cask in casks {
		mut dependency_names := []string{}
		if !skip_cask_dependencies {
			for dependency in cask.dependencies {
				if !dependency.installed {
					name := if dependency.full_name.len > 0 {
						dependency.full_name
					} else {
						dependency.name
					}
					if name != cask.full_name {
						dependency_names << name
					}
				}
			}
		}
		for dependency in cask.runtime_dependencies {
			if !dependency.installed {
				dependency_names << if dependency.name.len > 0 {
					dependency.name
				} else {
					dependency.full_name
				}
			}
		}
		dependency_names = unique_install_names(dependency_names)
		if dependency_names.len == 0 {
			continue
		}
		output += '==> Would install ${dependency_names.len} ${install_plural('dependency', dependency_names.len)} for ${cask.full_name}:\n${dependency_names.join(' ')}\n'
		all_dependency_names << dependency_names
	}
	return DryRunCaskPlan{
		output: output
		dependency_names: all_dependency_names
	}
}

pub fn ask_casks_plan(casks []CaskInstallCandidate, action string, prompt bool,
	skip_cask_dependencies bool) InstallAskPlan {
	if casks.len == 0 {
		return InstallAskPlan{}
	}
	dry_run := dry_run_casks_plan(casks, dry_run_action(action), skip_cask_dependencies, true)
	cask_names := casks.map(it.full_name)
	mut planned_names := cask_names.clone()
	planned_names << dry_run.dependency_names
	return InstallAskPlan{
		output: dry_run.output
		prompt_needed: prompt && ask_prompt_needed(planned_names, cask_names, false, true)
		action: action
	}
}

pub fn ask_question(action string) string {
	return 'Do you want to proceed with the ${action}? [y/n]'
}

pub fn compute_total_sizes(sized_formulae []FormulaBottleSizes) InstallTotalSizes {
	mut download := i64(0)
	mut installed := i64(0)
	for formula in sized_formulae {
		if formula.has_download_size {
			download += formula.download_size
		}
		if formula.has_installed_size {
			installed += formula.installed_size
		}
	}
	return InstallTotalSizes{
		download: download
		installed: installed
	}
}

pub fn collect_dependencies(candidates []FormulaInstallCandidate, dependant_upgradeable []string) []string {
	mut formulae_dependencies := []string{}
	for candidate in candidates {
		formulae_dependencies << if candidate.full_name.len > 0 {
			candidate.full_name
		} else {
			candidate.name
		}
		for dependency in candidate.dependencies {
			formulae_dependencies << if dependency.full_name.len > 0 {
				dependency.full_name
			} else {
				dependency.name
			}
		}
	}
	formulae_dependencies << dependant_upgradeable
	return unique_install_names(formulae_dependencies)
}

fn install_candidate_name(candidate FormulaInstallCandidate) string {
	return if candidate.name.len > 0 { candidate.name } else { candidate.full_name }
}

fn install_candidate_error(candidate FormulaInstallCandidate, message string) string {
	return '${if candidate.full_name.len > 0 { candidate.full_name } else { candidate.name }}: ${message}'
}

pub fn perform_build_from_source_checks(all_fatal bool) []InstallDiagnosticCall {
	return [
		InstallDiagnosticCall{
			kind: .fatal_build_from_source_checks
			fatal: true
		},
		InstallDiagnosticCall{
			kind: .build_from_source_checks
			fatal: all_fatal
		},
	]
}

pub fn attempt_install_directory_creation(directories []string) []string {
	mut created := []string{}
	for directory in directories {
		if brew_runtime.path_exists(directory) {
			continue
		}
		brew_runtime.make_dir_all(directory) or {
			// FileUtils.mkdir_p failures are intentionally ignored by the source.
			continue
		}
		created << directory
	}
	return created
}

pub fn perform_preinstall_checks(context InstallPreinstallContext) !InstallPreinstallResult {
	check_install_prefix(context.platform)!
	check_install_cpu(context.platform.ppc)!
	created := attempt_install_directory_creation(context.must_exist_directories)
	return InstallPreinstallResult{
		directories_created: created
		diagnostics: [
			InstallDiagnosticCall{
				kind: .supported_configuration_checks
				fatal: context.all_fatal
			},
			InstallDiagnosticCall{
				kind: .preinstall_checks
				fatal: false
			},
			InstallDiagnosticCall{
				kind: .fatal_preinstall_checks
				fatal: true
			},
		]
	}
}

pub fn perform_preinstall_checks_once(mut memo InstallPreinstallMemo,
	context InstallPreinstallContext) !InstallPreinstallOnceResult {
	if (context.all_fatal && memo.fatal_complete) || (!context.all_fatal && memo.nonfatal_complete) {
		return InstallPreinstallOnceResult{}
	}
	result := perform_preinstall_checks(context)!
	if context.all_fatal {
		memo.fatal_complete = true
	} else {
		memo.nonfatal_complete = true
	}
	return InstallPreinstallOnceResult{
		ran: true
		result: result
	}
}

fn select_formula_phase(candidates []FormulaInstallCandidate, phase string,
	mut events []InstallQueueEvent, mut errors []string) []FormulaInstallCandidate {
	mut selected := []FormulaInstallCandidate{}
	for candidate in candidates {
		name := install_candidate_name(candidate)
		message := match phase {
			'prelude_fetch' { candidate.prelude_fetch_error }
			'prelude' { candidate.prelude_error }
			'enqueue_fetch' { candidate.enqueue_fetch_error }
			else { candidate.step_error }
		}
		events << InstallQueueEvent{
			kind: match phase {
				'prelude_fetch' { .prelude_fetch }
				'prelude' { .prelude }
				else { .enqueue_fetch }
			}
			package: name
		}
		if message.len > 0 {
			errors << install_candidate_error(candidate, message)
			continue
		}
		selected << candidate
	}
	return selected
}

pub fn prelude_fetch_formulae(candidates []FormulaInstallCandidate,
	metadata_only bool) InstallFormulaFetchResult {
	mut events := []InstallQueueEvent{}
	mut errors := []string{}
	for candidate in candidates {
		events << InstallQueueEvent{
			kind: .assign_download_queue
			package: install_candidate_name(candidate)
		}
	}
	mut selected := select_formula_phase(candidates, 'prelude_fetch', mut events, mut errors)
	if metadata_only {
		for index in 0 .. events.len {
			if events[index].kind == .prelude_fetch {
				events[index] = InstallQueueEvent{
					...events[index]
					metadata_only: true
				}
			}
		}
	}
	return InstallFormulaFetchResult{
		candidates: selected
		events: events
		errors: errors
	}
}

pub fn fetch_formulae(candidates []FormulaInstallCandidate,
	options InstallFormulaFetchOptions) InstallFormulaFetchResult {
	if candidates.len == 0 {
		return InstallFormulaFetchResult{
			candidates: candidates.clone()
		}
	}
	prelude_result := prelude_fetch_formulae(candidates, options.metadata_only)
	mut selected := prelude_result.candidates.clone()
	mut events := prelude_result.events.clone()
	mut errors := prelude_result.errors.clone()
	events << InstallQueueEvent{
		kind: .download_bottle_manifests
		heading: 'Downloading bottle manifests'
	}
	selected = select_formula_phase(selected, 'prelude', mut events, mut errors)
	events << InstallQueueEvent{
		kind: .download_bottle_manifests
		heading: 'Downloading bottle manifests'
	}
	selected = select_formula_phase(selected, 'enqueue_fetch', mut events, mut errors)
	if options.fetch_after_enqueue {
		formula_names := selected.map(install_candidate_name(it))
		heading := if options.show_downloads_heading {
			combined_fetch_downloads_heading(formula_names, []) or { '' }
		} else {
			''
		}
		events << InstallQueueEvent{
			kind: .download_formulae
			heading: heading
		}
		selected = reject_failed_downloads(selected, options.failed_downloads)
	}
	if options.shutdown_download_queue {
		events << InstallQueueEvent{
			kind: .shutdown
		}
	}
	return InstallFormulaFetchResult{
		candidates: selected
		events: events
		errors: errors
		shutdown: options.shutdown_download_queue
	}
}

pub fn enqueue_formulae(candidates []FormulaInstallCandidate) InstallFormulaFetchResult {
	return fetch_formulae(candidates, InstallFormulaFetchOptions{
		fetch_after_enqueue: false
		shutdown_download_queue: false
		show_downloads_heading: false
	})
}

pub fn enqueue_cask_installers(casks []CaskInstallCandidate) InstallCaskEnqueueResult {
	mut valid := []CaskInstallCandidate{}
	mut source_downloads := []string{}
	mut events := []InstallQueueEvent{}
	mut errors := []string{}
	for cask in casks {
		if cask.prelude_fetch_error.len > 0 {
			errors << '${cask.full_name}: ${cask.prelude_fetch_error}'
			continue
		}
		if cask.source_download.len > 0 {
			source_downloads << cask.source_download
			events << InstallQueueEvent{
				kind: .enqueue_source_download
				package: cask.full_name
			}
		}
		valid << cask
	}
	if source_downloads.len > 0 {
		events << InstallQueueEvent{
			kind: .download_cask_files
			heading: 'Downloading Cask files'
		}
	}
	mut enqueued := []string{}
	for cask in valid {
		events << InstallQueueEvent{
			kind: .enqueue_cask_downloads
			package: cask.full_name
		}
		if cask.enqueue_error.len > 0 {
			errors << '${cask.full_name}: ${cask.enqueue_error}'
			continue
		}
		enqueued << cask.full_name
	}
	return InstallCaskEnqueueResult{
		enqueued: enqueued
		source_downloads: source_downloads
		events: events
		errors: errors
	}
}

pub fn outdated_kegs(kegs []InstallKegPlan) []InstallKegPlan {
	return kegs.filter(it.directory)
}

pub fn install_formula(candidate FormulaInstallCandidate, upgrade bool) InstallFormulaResult {
	name := install_candidate_name(candidate)
	if candidate.already_attempted {
		return InstallFormulaResult{
			name: name
			upgrade: upgrade
			skipped: true
			events: ['check_installation_already_attempted']
		}
	}
	mut events := ['check_installation_already_attempted']
	mut unlinked := []string{}
	mut relinked := []string{}
	if upgrade {
		events << 'print_upgrade_message'
		for keg in outdated_kegs(candidate.linked_kegs) {
			if keg.linked {
				unlinked << keg.path
				events << 'unlink:${keg.path}'
			}
		}
	} else {
		events << 'print_tap_action'
	}
	events << 'install'
	if candidate.install_error.len > 0 {
		for path in unlinked {
			relinked << path
			events << 'relink:${path}'
		}
		return InstallFormulaResult{
			name: name
			upgrade: upgrade
			unlinked_kegs: unlinked
			relinked_kegs: relinked
			events: events
			error: candidate.install_error
		}
	}
	events << 'finish'
	return InstallFormulaResult{
		name: name
		upgrade: upgrade
		unlinked_kegs: unlinked
		events: events
	}
}

pub fn install_formulae(candidates []FormulaInstallCandidate,
	options InstallFormulaBatchOptions) InstallFormulaBatchResult {
	if candidates.len == 0 {
		return InstallFormulaBatchResult{}
	}
	if options.dry_run {
		return InstallFormulaBatchResult{
			output: dry_run_formulae_plan(candidates, options.dry_run_action)
		}
	}
	mut installed := []string{}
	mut cleaned := []string{}
	mut upgraded := []string{}
	mut events := []string{}
	mut errors := []string{}
	for candidate in candidates {
		upgrade := candidate.linked && candidate.outdated && !candidate.head && !candidate.no_install_upgrade
		result := install_formula(candidate, upgrade)
		events << result.events
		if result.error.len > 0 {
			errors << install_candidate_error(candidate, result.error)
			continue
		}
		if result.skipped {
			continue
		}
		installed << result.name
		cleaned << result.name
		if result.upgrade {
			upgraded << result.name
		}
	}
	return InstallFormulaBatchResult{
		installed: installed
		cleaned: cleaned
		upgraded: upgraded
		events: events
		errors: errors
	}
}

pub fn ask_input(input InstallAskInput) InstallAskResult {
	if !input.stdin_tty || !input.stdout_tty {
		return InstallAskResult{}
	}
	mut output := '==> ${ask_question(input.action)}\n'
	for index, character in input.characters {
		if index == input.interrupt_index {
			return InstallAskResult{
				exited: true
				consumed: index
				output: output
			}
		}
		match confirmation_key_action(character) {
			.accept {
				return InstallAskResult{
					accepted: true
					consumed: index + 1
					output: output
				}
			}
			.cancel {
				return InstallAskResult{
					exited: true
					consumed: index + 1
					output: output
				}
			}
			.retry {
				output += "Invalid input. Please press 'y' to proceed, or 'n' to abort.\n"
			}
		}
	}
	return InstallAskResult{
		exited: true
		consumed: input.characters.len
		output: output
	}
}

// Ruby method `perform_preinstall_checks_once(all_fatal: false)` at line 22.
pub fn ruby_install_l22_d1_perform_preinstall_checks_once(mut memo InstallPreinstallMemo,
	context InstallPreinstallContext) !InstallPreinstallOnceResult {
	return perform_preinstall_checks_once(mut memo, context)
}

// Ruby method `check_cc_argv(cc)` at line 31.
pub fn ruby_install_l31_d2_check_cc_argv(cc string) ?string {
	return check_cc_argument(cc)
}

// Ruby method `perform_build_from_source_checks(all_fatal: false)` at line 42.
pub fn ruby_install_l42_d3_perform_build_from_source_checks(all_fatal bool) []InstallDiagnosticCall {
	return perform_build_from_source_checks(all_fatal)
}

// Ruby method `global_post_install; end` at line 48.
pub fn ruby_install_l48_d4_global_post_install() {
}

// Ruby method `check_prefix` at line 51.
pub fn ruby_install_l51_d5_check_prefix(platform InstallPlatform) ! {
	check_install_prefix(platform)!
}

// Ruby method `install_formula?(` at line 81.
pub fn ruby_install_l81_d6_install_formula(formula api.PackageReference, state FormulaInstallState,
	options InstallFormulaCheckOptions) !FormulaInstallDecision {
	return install_formula_decision(formula, state, options)
}

// Ruby method `formula_installers(` at line 276.
pub fn ruby_install_l276_d7_formula_installers(formulae []api.PackageReference,
	config FormulaInstallersConfig) ![]FormulaInstaller {
	return formula_installers_plan(formulae, config)
}

// Ruby method `fetch_formulae(` at line 340.
pub fn ruby_install_l340_d8_fetch_formulae(candidates []FormulaInstallCandidate,
	options InstallFormulaFetchOptions) InstallFormulaFetchResult {
	return fetch_formulae(candidates, options)
}

// Ruby method `reject_failed_downloads(formula_installers, download_queue:)` at line 387.
pub fn ruby_install_l387_d9_reject_failed_downloads(candidates []FormulaInstallCandidate,
	failed_names []string) []FormulaInstallCandidate {
	return reject_failed_downloads(candidates, failed_names)
}

// Ruby method `prelude_fetch_formulae(formula_installers, download_queue:, metadata_only: false)` at line 406.
pub fn ruby_install_l406_d10_prelude_fetch_formulae(candidates []FormulaInstallCandidate,
	metadata_only bool) InstallFormulaFetchResult {
	return prelude_fetch_formulae(candidates, metadata_only)
}

// Ruby method `select_formula_installers(formula_installers, step: nil, action: nil)` at line 424.
pub fn ruby_install_l424_d11_select_formula_installers(candidates []FormulaInstallCandidate) []FormulaInstallCandidate {
	return select_install_candidates(candidates)
}

// Ruby method `enqueue_formulae(formula_installers, download_queue:)` at line 442.
pub fn ruby_install_l442_d12_enqueue_formulae(candidates []FormulaInstallCandidate) InstallFormulaFetchResult {
	return enqueue_formulae(candidates)
}

// Ruby method `combined_fetch_downloads_heading(formula_names: [], cask_names: [])` at line 453.
pub fn ruby_install_l453_d13_combined_fetch_downloads_heading(formula_names []string,
	cask_names []string) ?string {
	return combined_fetch_downloads_heading(formula_names, cask_names)
}

// Ruby method `enqueue_cask_installers(cask_installers, download_queue:)` at line 462.
pub fn ruby_install_l462_d14_enqueue_cask_installers(casks []CaskInstallCandidate) InstallCaskEnqueueResult {
	return enqueue_cask_installers(casks)
}

// Ruby method `install_formulae(` at line 497.
pub fn ruby_install_l497_d15_install_formulae(candidates []FormulaInstallCandidate,
	options InstallFormulaBatchOptions) InstallFormulaBatchResult {
	return install_formulae(candidates, options)
}

// Ruby method `print_dry_run_dependencies(formula, dependencies, skip_formula_names: [], &_block)` at line 561.
pub fn ruby_install_l561_d16_print_dry_run_dependencies(formula_name string,
	dependencies []InstallDependencyPlan, skip_formula_names []string) string {
	return dry_run_dependencies_plan(formula_name, dependencies, skip_formula_names)
}

// Ruby method `ask_formulae(formulae_installer, dependants,` at line 600.
pub fn ruby_install_l600_d17_ask_formulae(candidates []FormulaInstallCandidate,
	dependant_upgradeable []string, action string, prompt bool) InstallAskPlan {
	return ask_formulae_plan(candidates, dependant_upgradeable, action, prompt)
}

// Ruby method `ask_casks(casks, action: "installation", prompt: true, skip_cask_deps: false)` at line 654.
pub fn ruby_install_l654_d18_ask_casks(casks []CaskInstallCandidate, action string, prompt bool,
	skip_cask_dependencies bool) InstallAskPlan {
	return ask_casks_plan(casks, action, prompt, skip_cask_dependencies)
}

// Ruby method `print_dry_run_casks(casks, action: "install", skip_cask_deps: false, include_installed: true)` at line 674.
pub fn ruby_install_l674_d19_print_dry_run_casks(casks []CaskInstallCandidate, action string,
	skip_cask_dependencies bool, include_installed bool) DryRunCaskPlan {
	return dry_run_casks_plan(casks, action, skip_cask_dependencies, include_installed)
}

// Ruby method `ask_prompt_needed?(planned_names:, requested_names:, force: false, named: true)` at line 716.
pub fn ruby_install_l716_d20_ask_prompt_needed(planned_names []string, requested_names []string,
	force bool, named bool) bool {
	return ask_prompt_needed(planned_names, requested_names, force, named)
}

// Ruby method `formulae_ask_prompt_needed?(formulae_installer, dependants)` at line 730.
pub fn ruby_install_l730_d21_formulae_ask_prompt_needed(candidates []FormulaInstallCandidate,
	dependant_upgradeable []string) bool {
	return formulae_ask_prompt_needed(candidates, dependant_upgradeable)
}

// Ruby method `install_formula(formula_installer, upgrade:)` at line 738.
pub fn ruby_install_l738_d22_install_formula(candidate FormulaInstallCandidate,
	upgrade bool) InstallFormulaResult {
	return install_formula(candidate, upgrade)
}

// Ruby method `ask(action: "installation")` at line 773.
pub fn ruby_install_l773_d23_ask(action string) string {
	return ask_question(action)
}

// Ruby method `perform_preinstall_checks(all_fatal: false)` at line 778.
pub fn ruby_install_l778_d24_perform_preinstall_checks(context InstallPreinstallContext) !InstallPreinstallResult {
	return perform_preinstall_checks(context)
}

// Ruby method `dry_run_action(action)` at line 790.
pub fn ruby_install_l790_d25_dry_run_action(action string) string {
	return dry_run_action(action)
}

// Ruby method `outdated_kegs(formula)` at line 802.
pub fn ruby_install_l802_d26_outdated_kegs(kegs []InstallKegPlan) []InstallKegPlan {
	return outdated_kegs(kegs)
}

// Ruby method `attempt_directory_creation` at line 809.
pub fn ruby_install_l809_d27_attempt_directory_creation(directories []string) []string {
	return attempt_install_directory_creation(directories)
}

// Ruby method `check_cpu` at line 818.
pub fn ruby_install_l818_d28_check_cpu(ppc bool) ! {
	check_install_cpu(ppc)!
}

// Ruby method `ask_input(action: "installation")` at line 829.
pub fn ruby_install_l829_d29_ask_input(input InstallAskInput) InstallAskResult {
	return ask_input(input)
}

// Ruby method `compute_total_sizes(sized_formulae, debug: false)` at line 836.
pub fn ruby_install_l836_d30_compute_total_sizes(sized_formulae []FormulaBottleSizes) InstallTotalSizes {
	return compute_total_sizes(sized_formulae)
}

// Ruby method `collect_dependencies(formulae_installer, dependants)` at line 859.
pub fn ruby_install_l859_d31_collect_dependencies(candidates []FormulaInstallCandidate,
	dependant_upgradeable []string) []string {
	return collect_dependencies(candidates, dependant_upgradeable)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic"
// 5: require "diagnostic/finding"
// 6: require "fileutils"
// 7: require "hardware"
// 8: require "development_tools"
// 9: require "upgrade"
// 10: require "download_queue"
// 11: require "ask"
// 12: require "utils/output"
// 13: require "utils/topological_hash"
// 14:
// 15: module Homebrew
// 16:   # Helper module for performing (pre-)install checks.
// 17:   module Install
// 18:     extend Utils::Output::Mixin
// 19:
// 20:     class << self
// 21:       sig { params(all_fatal: T::Boolean).void }
// 22:       def perform_preinstall_checks_once(all_fatal: false)
// 23:         @perform_preinstall_checks_once ||= T.let({}, T.nilable(T::Hash[T::Boolean, TrueClass]))
// 24:         @perform_preinstall_checks_once[all_fatal] ||= begin
// 25:           perform_preinstall_checks(all_fatal:)
// 26:           true
// 27:         end
// 28:       end
// 29:
// 30:       sig { params(cc: T.nilable(String)).void }
// 31:       def check_cc_argv(cc)
// 32:         return unless cc
// 33:
// 34:         opoo <<~EOS
// 35:           You passed `--cc=#{cc}`.
// 36:
// 37:           #{Diagnostic::Finding.support_tier_message(tier: 3)}
// 38:         EOS
// 39:       end
// 40:
// 41:       sig { params(all_fatal: T::Boolean).void }
// 42:       def perform_build_from_source_checks(all_fatal: false)
// 43:         Diagnostic.checks(:fatal_build_from_source_checks)
// 44:         Diagnostic.checks(:build_from_source_checks, fatal: all_fatal)
// 45:       end
// 46:
// 47:       sig { void }
// 48:       def global_post_install; end
// 49:
// 50:       sig { void }
// 51:       def check_prefix
// 52:         if (Hardware::CPU.intel? || Hardware::CPU.in_rosetta2?) &&
// 53:            HOMEBREW_PREFIX.to_s == HOMEBREW_MACOS_ARM_DEFAULT_PREFIX
// 54:           if Hardware::CPU.in_rosetta2?
// 55:             odie <<~EOS
// 56:               Cannot install under Rosetta 2 in ARM default prefix (#{HOMEBREW_PREFIX})!
// 57:               To rerun under ARM use:
// 58:                   arch -arm64 brew install ...
// 59:               To install under x86_64, install Homebrew into #{HOMEBREW_DEFAULT_PREFIX}.
// 60:             EOS
// 61:           else
// 62:             odie "Cannot install on Intel processor in ARM default prefix (#{HOMEBREW_PREFIX})!"
// 63:           end
// 64:         elsif Hardware::CPU.arm? && HOMEBREW_PREFIX.to_s == HOMEBREW_DEFAULT_PREFIX
// 65:           odie <<~EOS
// 66:             Cannot install in Homebrew on ARM processor in Intel default prefix (#{HOMEBREW_PREFIX})!
// 67:             Please create a new installation in #{HOMEBREW_MACOS_ARM_DEFAULT_PREFIX} using one of the
// 68:             "Alternative Installs" from:
// 69:               #{Formatter.url("https://docs.brew.sh/Installation")}
// 70:             You can migrate your previously installed formula list with:
// 71:               brew bundle dump
// 72:           EOS
// 73:         end
// 74:       end
// 75:
// 76:       sig {
// 77:         params(formula: Formula, head: T::Boolean, fetch_head: T::Boolean,
// 78:                only_dependencies: T::Boolean, force: T::Boolean, quiet: T::Boolean,
// 79:                skip_link: T::Boolean, overwrite: T::Boolean).returns(T::Boolean)
// 80:       }
// 81:       def install_formula?(
// 82:         formula,
// 83:         head: false,
// 84:         fetch_head: false,
// 85:         only_dependencies: false,
// 86:         force: false,
// 87:         quiet: false,
// 88:         skip_link: false,
// 89:         overwrite: false
// 90:       )
// 91:         # HEAD-only without --HEAD is an error
// 92:         if !head && formula.stable.nil?
// 93:           odie <<~EOS
// 94:             #{formula.full_name} is a HEAD-only formula.
// 95:             To install it, run:
// 96:               brew install --HEAD #{formula.full_name}
// 97:           EOS
// 98:         end
// 99:
// 100:         # --HEAD, fail with no head defined
// 101:         odie "No head is defined for #{formula.full_name}" if head && formula.head.nil?
// 102:
// 103:         installed_head_version = formula.latest_head_version
// 104:         if installed_head_version &&
// 105:            !formula.head_version_outdated?(installed_head_version, fetch_head:)
// 106:           new_head_installed = true
// 107:         end
// 108:         prefix_installed = formula.prefix.exist? && !formula.prefix.empty?
// 109:
// 110:         # Check if the installed formula is from a different tap
// 111:         if formula.any_version_installed? &&
// 112:            (current_tap_name = formula.tap&.name.presence) &&
// 113:            (installed_keg_tab = formula.any_installed_keg&.tab.presence) &&
// 114:            (installed_tap_name = installed_keg_tab.tap&.name.presence) &&
// 115:            installed_tap_name != current_tap_name
// 116:           odie <<~EOS
// 117:             #{formula.name} was installed from the #{Formatter.identifier(installed_tap_name)} tap
// 118:             but you are trying to install it from the #{Formatter.identifier(current_tap_name)} tap.
// 119:             Formulae with the same name from different taps cannot be installed at the same time.
// 120:
// 121:             To install this version, you must first uninstall the existing formula:
// 122:               brew uninstall #{formula.name}
// 123:             Then you can install the desired version:
// 124:               brew install #{formula.full_name}
// 125:           EOS
// 126:         end
// 127:
// 128:         if formula.keg_only? && formula.any_version_installed? && formula.optlinked? && !force
// 129:           # keg-only install is only possible when no other version is
// 130:           # linked to opt, because installing without any warnings can break
// 131:           # dependencies. Therefore before performing other checks we need to be
// 132:           # sure the --force switch is passed.
// 133:           if formula.outdated?
// 134:             if !Homebrew::EnvConfig.no_install_upgrade? && !formula.pinned?
// 135:               name = formula.name
// 136:               version = formula.linked_version
// 137:               puts "#{name} #{version} is already installed but outdated (so it will be upgraded)."
// 138:               return true
// 139:             end
// 140:
// 141:             unpin_cmd_if_needed = ("brew unpin #{formula.full_name} && " if formula.pinned?)
// 142:             optlinked_version = Keg.for(formula.opt_prefix).version
// 143:             onoe <<~EOS
// 144:               #{formula.full_name} #{optlinked_version} is already installed.
// 145:               To upgrade to #{formula.version}, run:
// 146:                 #{unpin_cmd_if_needed}brew upgrade #{formula.full_name}
// 147:             EOS
// 148:           elsif only_dependencies
// 149:             return true
// 150:           elsif !quiet
// 151:             opoo_without_github_actions_annotation <<~EOS
// 152:               #{formula.full_name} #{formula.pkg_version} is already installed and up-to-date.
// 153:               To reinstall #{formula.pkg_version}, run:
// 154:                 brew reinstall #{formula.name}
// 155:             EOS
// 156:           end
// 157:         elsif (head && new_head_installed) || prefix_installed
// 158:           # After we're sure the --force switch was passed for linking to opt
// 159:           # keg-only we need to be sure that the version we're attempting to
// 160:           # install is not already installed.
// 161:
// 162:           installed_version = if head
// 163:             formula.latest_head_version
// 164:           else
// 165:             formula.pkg_version
// 166:           end
// 167:
// 168:           msg = "#{formula.full_name} #{installed_version} is already installed"
// 169:           linked_not_equals_installed = formula.linked_version != installed_version
// 170:           if formula.linked? && linked_not_equals_installed
// 171:             msg = if quiet
// 172:               nil
// 173:             else
// 174:               <<~EOS
// 175:                 #{msg}.
// 176:                 The currently linked version is: #{formula.linked_version}
// 177:               EOS
// 178:             end
// 179:           elsif only_dependencies || (!formula.linked? && overwrite)
// 180:             msg = nil
// 181:             return true
// 182:           elsif !formula.linked? || formula.keg_only?
// 183:             msg = <<~EOS
// 184:               #{msg}, it's just not linked.
// 185:               To link this version, run:
// 186:                 brew link #{formula.full_name}
// 187:             EOS
// 188:           else
// 189:             unless quiet
// 190:               opoo_without_github_actions_annotation <<~EOS
// 191:                 #{msg} and up-to-date.
// 192:                 To reinstall #{formula.pkg_version}, run:
// 193:                   brew reinstall #{formula.name}
// 194:               EOS
// 195:             end
// 196:             msg = nil
// 197:           end
// 198:           opoo msg if msg
// 199:         elsif !formula.any_version_installed? && (old_formula = formula.old_installed_formulae.first)
// 200:           msg = "#{old_formula.full_name} #{old_formula.any_installed_version} already installed"
// 201:           msg = if !old_formula.linked? && !old_formula.keg_only?
// 202:             <<~EOS
// 203:               #{msg}, it's just not linked.
// 204:               To link this version, run:
// 205:                 brew link #{old_formula.full_name}
// 206:             EOS
// 207:           elsif quiet
// 208:             nil
// 209:           else
// 210:             "#{msg}."
// 211:           end
// 212:           opoo msg if msg
// 213:         elsif formula.migration_needed? && !force
// 214:           # Check if the formula we try to install is the same as installed
// 215:           # but not migrated one. If --force is passed then install anyway.
// 216:           opoo <<~EOS
// 217:             #{formula.oldnames_to_migrate.first} is already installed, it's just not migrated.
// 218:             To migrate this formula, run:
// 219:               brew migrate #{formula}
// 220:             Or to force-install it, run:
// 221:               brew install #{formula} --force
// 222:           EOS
// 223:         elsif formula.linked?
// 224:           message = "#{formula.name} #{formula.linked_version} is already installed"
// 225:           if formula.outdated? && !head
// 226:             if !Homebrew::EnvConfig.no_install_upgrade? && !formula.pinned?
// 227:               puts "#{message} but outdated (so it will be upgraded)."
// 228:               return true
// 229:             end
// 230:
// 231:             unpin_cmd_if_needed = ("brew unpin #{formula.full_name} && " if formula.pinned?)
// 232:             onoe <<~EOS
// 233:               #{message}
// 234:               To upgrade to #{formula.pkg_version}, run:
// 235:                 #{unpin_cmd_if_needed}brew upgrade #{formula.full_name}
// 236:             EOS
// 237:           elsif only_dependencies || skip_link
// 238:             return true
// 239:           else
// 240:             onoe <<~EOS
// 241:               #{message}
// 242:               To install #{formula.pkg_version}, first run:
// 243:                 brew unlink #{formula.name}
// 244:             EOS
// 245:           end
// 246:         else
// 247:           # If none of the above is true and the formula is linked, then
// 248:           # FormulaInstaller will handle this case.
// 249:           return true
// 250:         end
// 251:
// 252:         # Even if we don't install this formula mark it as no longer just
// 253:         # installed as a dependency.
// 254:         return false unless formula.opt_prefix.directory?
// 255:
// 256:         keg = Keg.new(formula.opt_prefix.resolved_path)
// 257:         tab = keg.tab
// 258:         unless tab.installed_on_request
// 259:           tab.installed_on_request = true
// 260:           tab.write
// 261:         end
// 262:
// 263:         false
// 264:       end
// 265:
// 266:       sig {
// 267:         params(formulae_to_install: T::Array[Formula], installed_on_request: T::Boolean,
// 268:                build_bottle: T::Boolean, force_bottle: T::Boolean,
// 269:                bottle_arch: T.nilable(String), ignore_deps: T::Boolean, only_deps: T::Boolean,
// 270:                include_test_formulae: T::Array[String], build_from_source_formulae: T::Array[String],
// 271:                cc: T.nilable(String), git: T::Boolean, interactive: T::Boolean, keep_tmp: T::Boolean,
// 272:                debug_symbols: T::Boolean, force: T::Boolean, overwrite: T::Boolean, debug: T::Boolean,
// 273:                quiet: T::Boolean, verbose: T::Boolean, dry_run: T::Boolean, skip_post_install: T::Boolean,
// 274:                skip_link: T::Boolean).returns(T::Array[FormulaInstaller])
// 275:       }
// 276:       def formula_installers(
// 277:         formulae_to_install,
// 278:         installed_on_request: true,
// 279:         build_bottle: false,
// 280:         force_bottle: false,
// 281:         bottle_arch: nil,
// 282:         ignore_deps: false,
// 283:         only_deps: false,
// 284:         include_test_formulae: [],
// 285:         build_from_source_formulae: [],
// 286:         cc: nil,
// 287:         git: false,
// 288:         interactive: false,
// 289:         keep_tmp: false,
// 290:         debug_symbols: false,
// 291:         force: false,
// 292:         overwrite: false,
// 293:         debug: false,
// 294:         quiet: false,
// 295:         verbose: false,
// 296:         dry_run: false,
// 297:         skip_post_install: false,
// 298:         skip_link: false
// 299:       )
// 300:         formulae_to_install.filter_map do |formula|
// 301:           Migrator.migrate_if_needed(formula, force:, dry_run:)
// 302:           build_options = formula.build
// 303:
// 304:           FormulaInstaller.new(
// 305:             formula,
// 306:             options:                    build_options.used_options,
// 307:             installed_on_request:,
// 308:             build_bottle:,
// 309:             force_bottle:,
// 310:             bottle_arch:,
// 311:             ignore_deps:,
// 312:             only_deps:,
// 313:             include_test_formulae:,
// 314:             build_from_source_formulae:,
// 315:             cc:,
// 316:             git:,
// 317:             interactive:,
// 318:             keep_tmp:,
// 319:             debug_symbols:,
// 320:             force:,
// 321:             overwrite:,
// 322:             debug:,
// 323:             quiet:,
// 324:             verbose:,
// 325:             skip_post_install:,
// 326:             skip_link:,
// 327:           )
// 328:         end
// 329:       end
// 330:
// 331:       sig {
// 332:         params(
// 333:           formula_installers:      T::Array[FormulaInstaller],
// 334:           download_queue:          T.nilable(Homebrew::DownloadQueue),
// 335:           fetch_after_enqueue:     T::Boolean,
// 336:           shutdown_download_queue: T::Boolean,
// 337:           show_downloads_heading:  T::Boolean,
// 338:         ).returns(T::Array[FormulaInstaller])
// 339:       }
// 340:       def fetch_formulae(
// 341:         formula_installers,
// 342:         download_queue: nil,
// 343:         fetch_after_enqueue: true,
// 344:         shutdown_download_queue: true,
// 345:         show_downloads_heading: true
// 346:       )
// 347:         return formula_installers if formula_installers.empty?
// 348:
// 349:         download_queue = T.let(download_queue || Homebrew::DownloadQueue.new(pour: true), Homebrew::DownloadQueue)
// 350:
// 351:         begin
// 352:           valid_formula_installers = prelude_fetch_formulae(formula_installers, download_queue:)
// 353:           # Wait on just the bottle manifests dependency resolution needs so
// 354:           # in-flight bottles are only reported under the downloads heading.
// 355:           download_queue.fetch(only: Resource::BottleManifest, heading: "Downloading bottle manifests",
// 356:                                allow_failures: true)
// 357:
// 358:           [:prelude, :enqueue_fetch].each do |step|
// 359:             valid_formula_installers = select_formula_installers(valid_formula_installers, step:)
// 360:             next if step == :enqueue_fetch && !fetch_after_enqueue
// 361:
// 362:             if step == :prelude
// 363:               download_queue.fetch(only: Resource::BottleManifest, heading: "Downloading bottle manifests",
// 364:                                    allow_failures: true)
// 365:             else
// 366:               heading = if show_downloads_heading
// 367:                 combined_fetch_downloads_heading(formula_names: valid_formula_installers.map { |fi| fi.formula.name })
// 368:               end
// 369:               download_queue.fetch(heading:)
// 370:               valid_formula_installers = reject_failed_downloads(valid_formula_installers, download_queue:)
// 371:             end
// 372:           end
// 373:         ensure
// 374:           download_queue.shutdown if shutdown_download_queue
// 375:         end
// 376:
// 377:         valid_formula_installers
// 378:       end
// 379:
// 380:       # A failed download has already been reported, so skip installing its
// 381:       # formula rather than failing a second time on the missing or known-bad
// 382:       # download, while still installing everything else.
// 383:       sig {
// 384:         params(formula_installers: T::Array[FormulaInstaller],
// 385:                download_queue:     Homebrew::DownloadQueue).returns(T::Array[FormulaInstaller])
// 386:       }
// 387:       def reject_failed_downloads(formula_installers, download_queue:)
// 388:         failed_names = download_queue.failed_downloads.filter_map do |downloadable|
// 389:           case downloadable
// 390:           when Bottle then downloadable.name
// 391:           when Resource then downloadable.owner&.name
// 392:           end
// 393:         end
// 394:         return formula_installers if failed_names.empty?
// 395:
// 396:         formula_installers.reject { |fi| failed_names.include?(fi.formula.name) }
// 397:       end
// 398:
// 399:       sig {
// 400:         params(
// 401:           formula_installers: T::Array[FormulaInstaller],
// 402:           download_queue:     Homebrew::DownloadQueue,
// 403:           metadata_only:      T::Boolean,
// 404:         ).returns(T::Array[FormulaInstaller])
// 405:       }
// 406:       def prelude_fetch_formulae(formula_installers, download_queue:, metadata_only: false)
// 407:         formula_installers.each do |fi|
// 408:           fi.download_queue = download_queue
// 409:         end
// 410:
// 411:         # Only pass the keyword when limiting the fetch so mocks and
// 412:         # overrides expecting the historical no-argument call keep working.
// 413:         action = ->(fi) { metadata_only ? fi.prelude_fetch(metadata_only: true) : fi.prelude_fetch }
// 414:         select_formula_installers(formula_installers, action:)
// 415:       end
// 416:
// 417:       sig {
// 418:         params(
// 419:           formula_installers: T::Array[FormulaInstaller],
// 420:           step:               T.nilable(Symbol),
// 421:           action:             T.nilable(T.proc.params(formula_installer: FormulaInstaller).void),
// 422:         ).returns(T::Array[FormulaInstaller])
// 423:       }
// 424:       def select_formula_installers(formula_installers, step: nil, action: nil)
// 425:         formula_installers.select do |fi|
// 426:           if action
// 427:             action.call(fi)
// 428:           elsif step
// 429:             fi.public_send(step)
// 430:           end
// 431:           true
// 432:         rescue CannotInstallFormulaError => e
// 433:           ofail e.message
// 434:           false
// 435:         rescue => e
// 436:           ofail "#{fi.formula}: #{e}"
// 437:           false
// 438:         end
// 439:       end
// 440:
// 441:       sig { params(formula_installers: T::Array[FormulaInstaller], download_queue: Homebrew::DownloadQueue).returns(T::Array[FormulaInstaller]) }
// 442:       def enqueue_formulae(formula_installers, download_queue:)
// 443:         fetch_formulae(
// 444:           formula_installers,
// 445:           download_queue:,
// 446:           fetch_after_enqueue:     false,
// 447:           shutdown_download_queue: false,
// 448:           show_downloads_heading:  false,
// 449:         )
// 450:       end
// 451:
// 452:       sig { params(formula_names: T::Array[String], cask_names: T::Array[String]).returns(T.nilable(String)) }
// 453:       def combined_fetch_downloads_heading(formula_names: [], cask_names: [])
// 454:         combined_fetch_targets = formula_names.map { |name| Formatter.identifier(name) } +
// 455:                                  cask_names.map { |name| Formatter.identifier(name) }
// 456:         return if combined_fetch_targets.empty?
// 457:
// 458:         "Fetching downloads for: #{combined_fetch_targets.to_sentence}"
// 459:       end
// 460:
// 461:       sig { params(cask_installers: T::Array[T.untyped], download_queue: Homebrew::DownloadQueue).void }
// 462:       def enqueue_cask_installers(cask_installers, download_queue:)
// 463:         source_downloads = []
// 464:         valid_cask_installers = cask_installers.select do |cask_installer|
// 465:           if cask_installer.source_download_requires_pre_fetch? &&
// 466:              (source_download = cask_installer.prelude_fetch_download)
// 467:             source_downloads << source_download
// 468:           end
// 469:           true
// 470:         rescue => e
// 471:           ofail "#{cask_installer.cask}: #{e}"
// 472:           false
// 473:         end
// 474:
// 475:         if source_downloads.any?
// 476:           source_downloads.each { |source_download| download_queue.enqueue(source_download) }
// 477:           download_queue.fetch(only: Cask::Download, heading: "Downloading Cask files")
// 478:         end
// 479:
// 480:         valid_cask_installers.each do |cask_installer|
// 481:           cask_installer.enqueue_downloads
// 482:         rescue => e
// 483:           ofail "#{cask_installer.cask}: #{e}"
// 484:         end
// 485:       end
// 486:
// 487:       sig {
// 488:         params(formula_installers: T::Array[FormulaInstaller], installed_on_request: T::Boolean,
// 489:                build_bottle: T::Boolean, force_bottle: T::Boolean,
// 490:                bottle_arch: T.nilable(String), ignore_deps: T::Boolean, only_deps: T::Boolean,
// 491:                include_test_formulae: T::Array[String], build_from_source_formulae: T::Array[String],
// 492:                cc: T.nilable(String), git: T::Boolean, interactive: T::Boolean, keep_tmp: T::Boolean,
// 493:                debug_symbols: T::Boolean, force: T::Boolean, overwrite: T::Boolean, debug: T::Boolean,
// 494:                quiet: T::Boolean, verbose: T::Boolean, dry_run: T::Boolean,
// 495:                dry_run_action: String, skip_post_install: T::Boolean, skip_link: T::Boolean).void
// 496:       }
// 497:       def install_formulae(
// 498:         formula_installers,
// 499:         installed_on_request: true,
// 500:         build_bottle: false,
// 501:         force_bottle: false,
// 502:         bottle_arch: nil,
// 503:         ignore_deps: false,
// 504:         only_deps: false,
// 505:         include_test_formulae: [],
// 506:         build_from_source_formulae: [],
// 507:         cc: nil,
// 508:         git: false,
// 509:         interactive: false,
// 510:         keep_tmp: false,
// 511:         debug_symbols: false,
// 512:         force: false,
// 513:         overwrite: false,
// 514:         debug: false,
// 515:         quiet: false,
// 516:         verbose: false,
// 517:         dry_run: false,
// 518:         dry_run_action: "install",
// 519:         skip_post_install: false,
// 520:         skip_link: false
// 521:       )
// 522:         formulae_names_to_install = formula_installers.map { |fi| fi.formula.name }
// 523:         return if formulae_names_to_install.empty?
// 524:
// 525:         if dry_run
// 526:           ohai "Would #{dry_run_action} #{Utils.pluralize("formula", formulae_names_to_install.count,
// 527:                                                           include_count: true)}:"
// 528:           puts formulae_names_to_install.join(" ")
// 529:
// 530:           formula_installers.each do |fi|
// 531:             next if fi.ignore_deps?
// 532:
// 533:             print_dry_run_dependencies(fi.formula, fi.compute_dependencies, &:name)
// 534:           end
// 535:           return
// 536:         end
// 537:
// 538:         formula_installers.each do |fi|
// 539:           formula = fi.formula
// 540:           upgrade = formula.linked? && formula.outdated? && !formula.head? && !Homebrew::EnvConfig.no_install_upgrade?
// 541:           install_formula(fi, upgrade:)
// 542:           Cleanup.install_formula_clean!(formula)
// 543:         rescue BuildError
// 544:           # Reported (with analytics) by the global handler in `brew.rb`.
// 545:           raise
// 546:         rescue => e
// 547:           # Keep a single failed install (e.g. a bottle that fails to extract)
// 548:           # from aborting the rest of the batch while still failing the run.
// 549:           ofail "#{fi.formula.full_specified_name}: #{e}"
// 550:         end
// 551:       end
// 552:
// 553:       sig {
// 554:         params(
// 555:           formula:            Formula,
// 556:           dependencies:       T::Array[Dependency],
// 557:           skip_formula_names: T::Array[String],
// 558:           _block:             T.proc.params(arg0: Formula).returns(String),
// 559:         ).void
// 560:       }
// 561:       def print_dry_run_dependencies(formula, dependencies, skip_formula_names: [], &_block)
// 562:         return if dependencies.empty?
// 563:
// 564:         entries = dependencies.filter_map do |dep|
// 565:           dependency = dep.to_formula
// 566:           next if skip_formula_names.include?(dependency.full_name)
// 567:
// 568:           [dependency.any_version_installed?, yield(dependency)]
// 569:         end
// 570:
// 571:         upgrade, install = entries.partition(&:first)
// 572:         { install:, upgrade: }.each do |verb, group|
// 573:           next if group.empty?
// 574:
// 575:           ohai "Would #{verb} #{Utils.pluralize("dependency", group.count, include_count: true)} " \
// 576:                "for #{formula.name}:"
// 577:           puts Upgrade.format_upgrade_summary(group.map(&:last))
// 578:         end
// 579:       end
// 580:
// 581:       # If asking the user is enabled, show dry-run information.
// 582:       sig {
// 583:         params(
// 584:           formulae_installer:         T::Array[FormulaInstaller],
// 585:           dependants:                 Homebrew::Upgrade::Dependents,
// 586:           flags:                      T::Array[String],
// 587:           force_bottle:               T::Boolean,
// 588:           build_from_source_formulae: T::Array[String],
// 589:           interactive:                T::Boolean,
// 590:           keep_tmp:                   T::Boolean,
// 591:           debug_symbols:              T::Boolean,
// 592:           force:                      T::Boolean,
// 593:           debug:                      T::Boolean,
// 594:           quiet:                      T::Boolean,
// 595:           verbose:                    T::Boolean,
// 596:           prompt:                     T::Boolean,
// 597:           action:                     String,
// 598:         ).void
// 599:       }
// 600:       def ask_formulae(formulae_installer, dependants,
// 601:                        flags: [],
// 602:                        force_bottle: false,
// 603:                        build_from_source_formulae: [],
// 604:                        interactive: false,
// 605:                        keep_tmp: false,
// 606:                        debug_symbols: false,
// 607:                        force: false,
// 608:                        debug: false,
// 609:                        quiet: false,
// 610:                        verbose: false,
// 611:                        prompt: true,
// 612:                        action: "installation")
// 613:         return if formulae_installer.empty?
// 614:
// 615:         formula_names = formulae_installer.map { |formula_installer| formula_installer.formula.full_name }
// 616:
// 617:         install_formulae(formulae_installer, dry_run: true, dry_run_action: dry_run_action(action))
// 618:
// 619:         Upgrade.upgrade_dependents(
// 620:           Homebrew::Upgrade::Dependents.new(
// 621:             upgradeable: dependants.upgradeable.dup,
// 622:             pinned:      dependants.pinned.dup,
// 623:             skipped:     dependants.skipped.dup,
// 624:           ),
// 625:           formulae_installer.map(&:formula),
// 626:           flags:,
// 627:           dry_run:                    true,
// 628:           force_bottle:,
// 629:           build_from_source_formulae:,
// 630:           interactive:,
// 631:           keep_tmp:,
// 632:           debug_symbols:,
// 633:           force:,
// 634:           debug:,
// 635:           quiet:,
// 636:           verbose:,
// 637:         )
// 638:
// 639:         ask_input(action:) if prompt && ask_prompt_needed?(
// 640:           planned_names:   formula_names,
// 641:           requested_names: formula_names,
// 642:           force:           formulae_ask_prompt_needed?(formulae_installer, dependants),
// 643:         )
// 644:       end
// 645:
// 646:       sig {
// 647:         params(
// 648:           casks:          T::Array[Cask::Cask],
// 649:           action:         String,
// 650:           prompt:         T::Boolean,
// 651:           skip_cask_deps: T::Boolean,
// 652:         ).void
// 653:       }
// 654:       def ask_casks(casks, action: "installation", prompt: true, skip_cask_deps: false)
// 655:         return if casks.empty?
// 656:
// 657:         cask_names = casks.map(&:full_name)
// 658:         dependency_names = print_dry_run_casks(casks, action: dry_run_action(action), skip_cask_deps:)
// 659:
// 660:         ask_input(action:) if prompt && ask_prompt_needed?(
// 661:           planned_names:   cask_names + dependency_names,
// 662:           requested_names: cask_names,
// 663:         )
// 664:       end
// 665:
// 666:       sig {
// 667:         params(
// 668:           casks:             T::Array[Cask::Cask],
// 669:           action:            String,
// 670:           skip_cask_deps:    T::Boolean,
// 671:           include_installed: T::Boolean,
// 672:         ).returns(T::Array[String])
// 673:       }
// 674:       def print_dry_run_casks(casks, action: "install", skip_cask_deps: false, include_installed: true)
// 675:         if (casks_to_print = (include_installed ? casks : casks.reject(&:installed?)).presence)
// 676:           ohai "Would #{action} #{::Utils.pluralize("cask", casks_to_print.count, include_count: true)}:"
// 677:           puts casks_to_print.map(&:full_name).join(" ")
// 678:         end
// 679:
// 680:         casks.flat_map do |cask|
// 681:           dep_names = T.let([], T::Array[String])
// 682:           unless skip_cask_deps
// 683:             dep_names.concat(
// 684:               ::Utils::TopologicalHash.graph_package_dependencies([cask]).tsort.grep(Cask::Cask).filter_map do |dep|
// 685:                 next if dep.full_name == cask.full_name
// 686:                 next if dep.installed?
// 687:
// 688:                 dep.full_name
// 689:               end,
// 690:             )
// 691:           end
// 692:           dep_names.concat(
// 693:             CaskDependent.new(cask)
// 694:                          .runtime_dependencies(read_from_tab: false, undeclared: false)
// 695:                          .reject(&:installed?)
// 696:                          .map(&:name),
// 697:           )
// 698:           dep_names.uniq!
// 699:           next [] if dep_names.blank?
// 700:
// 701:           ohai "Would install #{::Utils.pluralize("dependency", dep_names.count, include_count: true)} " \
// 702:                "for #{cask.full_name}:"
// 703:           puts dep_names.join(" ")
// 704:           dep_names
// 705:         end
// 706:       end
// 707:
// 708:       sig {
// 709:         params(
// 710:           planned_names:   T::Array[String],
// 711:           requested_names: T::Array[String],
// 712:           force:           T::Boolean,
// 713:           named:           T::Boolean,
// 714:         ).returns(T::Boolean)
// 715:       }
// 716:       def ask_prompt_needed?(planned_names:, requested_names:, force: false, named: true)
// 717:         return false if planned_names.empty?
// 718:         return true if force
// 719:         return true unless named
// 720:
// 721:         planned_names.any? { |planned_name| requested_names.exclude?(planned_name) }
// 722:       end
// 723:
// 724:       sig {
// 725:         params(
// 726:           formulae_installer: T::Array[FormulaInstaller],
// 727:           dependants:         Homebrew::Upgrade::Dependents,
// 728:         ).returns(T::Boolean)
// 729:       }
// 730:       def formulae_ask_prompt_needed?(formulae_installer, dependants)
// 731:         formulae_installer.any? do |formula_installer|
// 732:           !formula_installer.ignore_deps? && formula_installer.compute_dependencies.present?
// 733:         end ||
// 734:           dependants.upgradeable.present?
// 735:       end
// 736:
// 737:       sig { params(formula_installer: FormulaInstaller, upgrade: T::Boolean).void }
// 738:       def install_formula(formula_installer, upgrade:)
// 739:         formula = formula_installer.formula
// 740:
// 741:         formula_installer.check_installation_already_attempted
// 742:
// 743:         if upgrade
// 744:           Upgrade.print_upgrade_message(formula, formula_installer.options)
// 745:
// 746:           kegs = Upgrade.outdated_kegs(formula)
// 747:           linked_kegs = kegs.select(&:linked?)
// 748:         else
// 749:           formula.print_tap_action
// 750:         end
// 751:
// 752:         # first we unlink the currently active keg for this formula otherwise it is
// 753:         # possible for the existing build to interfere with the build we are about to
// 754:         # do! Seriously, it happens!
// 755:         kegs.each(&:unlink) if kegs.present?
// 756:
// 757:         formula_installer.install
// 758:         formula_installer.finish
// 759:       rescue FormulaInstallationAlreadyAttemptedError
// 760:         # We already attempted to upgrade f as part of the dependency tree of
// 761:         # another formula. In that case, don't generate an error, just move on.
// 762:         nil
// 763:       ensure
// 764:         # restore previous installation state if build failed
// 765:         begin
// 766:           linked_kegs&.each(&:link) unless formula&.latest_version_installed?
// 767:         rescue
// 768:           nil
// 769:         end
// 770:       end
// 771:
// 772:       sig { params(action: String).void }
// 773:       def ask(action: "installation")
// 774:         ask_input(action:)
// 775:       end
// 776:
// 777:       sig { params(all_fatal: T::Boolean).void }
// 778:       def perform_preinstall_checks(all_fatal: false)
// 779:         check_prefix
// 780:         check_cpu
// 781:         attempt_directory_creation
// 782:         Diagnostic.checks(:supported_configuration_checks, fatal: all_fatal)
// 783:         Diagnostic.checks(:preinstall_checks, fatal: false)
// 784:         Diagnostic.checks(:fatal_preinstall_checks)
// 785:       end
// 786:
// 787:       private
// 788:
// 789:       sig { params(action: String).returns(String) }
// 790:       def dry_run_action(action)
// 791:         case action
// 792:         when "reinstallation"
// 793:           "reinstall"
// 794:         when "upgrade"
// 795:           "upgrade"
// 796:         else
// 797:           "install"
// 798:         end
// 799:       end
// 800:
// 801:       sig { params(formula: Formula).returns(T::Array[Keg]) }
// 802:       def outdated_kegs(formula)
// 803:         [formula, *formula.old_installed_formulae].map(&:linked_keg)
// 804:                                                   .select(&:directory?)
// 805:                                                   .map { |k| Keg.new(k.resolved_path) }
// 806:       end
// 807:
// 808:       sig { void }
// 809:       def attempt_directory_creation
// 810:         Keg.must_exist_directories.each do |dir|
// 811:           FileUtils.mkdir_p(dir) unless dir.exist?
// 812:         rescue
// 813:           nil
// 814:         end
// 815:       end
// 816:
// 817:       sig { void }
// 818:       def check_cpu
// 819:         return unless Hardware::CPU.ppc?
// 820:
// 821:         odie <<~EOS
// 822:           Sorry, Homebrew does not support your computer's CPU architecture!
// 823:           For PowerPC Mac (PPC32/PPC64BE) support, see:
// 824:             #{Formatter.url("https://github.com/mistydemeo/tigerbrew")}
// 825:         EOS
// 826:       end
// 827:
// 828:       sig { params(action: String).void }
// 829:       def ask_input(action: "installation")
// 830:         Homebrew::Ask.confirm?(action:)
// 831:         nil
// 832:       end
// 833:
// 834:       # Compute the total sizes (download and installed) for the given formulae.
// 835:       sig { params(sized_formulae: T::Array[Formula], debug: T::Boolean).returns(T::Hash[Symbol, Integer]) }
// 836:       def compute_total_sizes(sized_formulae, debug: false)
// 837:         total_download_size  = 0
// 838:         total_installed_size = 0
// 839:
// 840:         sized_formulae.each do |formula|
// 841:           bottle = formula.bottle
// 842:           next unless bottle
// 843:
// 844:           # Fetch additional bottle metadata (if necessary).
// 845:           bottle.fetch_tab(quiet: !debug)
// 846:
// 847:           total_download_size  += bottle.bottle_size.to_i if bottle.bottle_size
// 848:           total_installed_size += bottle.installed_size.to_i if bottle.installed_size
// 849:         end
// 850:
// 851:         { download:  total_download_size,
// 852:           installed: total_installed_size }
// 853:       end
// 854:
// 855:       sig {
// 856:         params(formulae_installer: T::Array[FormulaInstaller],
// 857:                dependants:         Homebrew::Upgrade::Dependents).returns(T::Array[Formula])
// 858:       }
// 859:       def collect_dependencies(formulae_installer, dependants)
// 860:         formulae_dependencies = formulae_installer.flat_map do |f|
// 861:           [f.formula, f.compute_dependencies.flatten.grep(Dependency).flat_map(&:to_formula)]
// 862:         end.flatten.uniq
// 863:         formulae_dependencies.concat(dependants.upgradeable) if dependants.upgradeable
// 864:         formulae_dependencies.uniq
// 865:       end
// 866:     end
// 867:   end
// 868: end
// 869:
// 870: require "extend/os/install"
