module homebrew

import ruby
import homebrew.api

// Translated from Homebrew/brew `install.rb`.
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
		if ruby.path_exists(directory) {
			continue
		}
		ruby.make_dir_all(directory) or {
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
