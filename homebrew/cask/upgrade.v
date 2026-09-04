module cask

// Translated from Homebrew/brew `cask/upgrade.rb`.
pub enum CaskUpgradeArtifactKind {
	app
	uninstall
	installer
	other
}

pub enum CaskUpgradeLoadStatus {
	loaded
	invalid
	unreadable
	deprecated
	missing
}

pub enum CaskUpgradeIdentityMatch {
	missing
	matches
	changed
}

pub enum CaskUpgradeQuarantineDecision {
	skip
	unapproved
	signer_unverified
	signer_changed
	release
}

pub enum CaskUpgradeFailurePhase {
	none
	prelude
	fetch
	start_upgrade
	stage
	install_artifacts
	quarantine
	finalize
}

pub struct CaskUpgradeArtifact {
pub:
	kind               CaskUpgradeArtifactKind
	target             string
	exists             bool
	manual_install     bool
	bundle_ids         []string
	user_approved      bool
	old_identity       string
	new_identity_match CaskUpgradeIdentityMatch
}

pub struct CaskUpgradeCandidate {
pub:
	token                    string
	full_name                string
	version                  string
	version_present          bool = true
	version_latest           bool
	installed                bool = true
	installed_after_outdated bool = true
	installed_caskfile       bool = true
	installed_version        string
	outdated_default         bool
	outdated_greedy          bool
	auto_updates             bool
	pinned                   bool
	disabled                 bool
	deprecated               bool
	disable_message          string = 'disabled'
	load_status              CaskUpgradeLoadStatus
	recovery_succeeds        bool
	requirement_error        string
	upgrade_error            string
	artifacts                []CaskUpgradeArtifact
}

pub struct CaskUpgradeOutdatedOptions {
pub:
	explicit_casks               bool
	force                        bool
	quiet                        bool
	greedy                       bool
	greedy_latest                bool
	greedy_auto_updates          bool
	env_upgrade_greedy           bool
	upgrade_auto_updates_default bool = true
	greedy_casks                 []string
}

pub struct CaskUpgradeOutdatedResult {
pub:
	casks    []CaskUpgradeCandidate
	warnings []string
	errors   []string
	pinned   []string
	disabled []string
}

pub struct CaskUpgradeSummary {
pub:
	heading string
	lines   []string
}

pub struct CaskUpgradeOptions {
pub:
	outdated          CaskUpgradeOutdatedOptions
	dry_run           bool
	skip_prefetch     bool
	show_summary      bool = true
	quit              bool = true
	no_env_hints      bool
	prefetched_errors []string
}

pub struct CaskUpgradeRunResult {
pub:
	success                bool
	upgraded               []string
	upgrade_attempts       []string
	pinned                 []string
	deprecated             []string
	disabled               []string
	warnings               []string
	errors                 []string
	hints                  []string
	summary                CaskUpgradeSummary
	created_download_queue bool
	queue_shutdown         bool
}

pub struct CaskUpgradeReopenResult {
pub:
	heading  string
	commands [][]string
}

pub struct CaskUpgradeTransactionInput {
pub:
	old_cask                 CaskUpgradeCandidate
	new_cask                 CaskUpgradeCandidate
	quit                     bool = true
	verbose                  bool
	quarantine_available     bool
	failure_phase            CaskUpgradeFailurePhase
	rollback_fails           bool
	inherit_fails            bool
	old_tabfile_present      bool
	old_installed_on_request bool
}

pub struct CaskUpgradeTransactionResult {
pub:
	success              bool
	operations           []string
	warnings             []string
	error_message        string
	rollback_error       string
	tab_written          bool
	installed_on_request bool
	quarantine_decision  CaskUpgradeQuarantineDecision
}

pub fn cask_upgrade_greedy_casks(value string) []string {
	return value.fields()
}

fn cask_upgrade_display_name(cask CaskUpgradeCandidate) string {
	return if cask.full_name != '' { cask.full_name } else { cask.token }
}

fn cask_upgrade_is_outdated(cask CaskUpgradeCandidate, options CaskUpgradeOutdatedOptions) bool {
	if options.explicit_casks {
		return cask.outdated_greedy
	}
	greedy := options.greedy || options.env_upgrade_greedy || cask.token in options.greedy_casks
	if cask.version_latest {
		return cask.outdated_greedy && (greedy || options.greedy_latest)
	}
	if cask.auto_updates {
		return cask.outdated_greedy && (greedy || options.greedy_auto_updates || options.upgrade_auto_updates_default)
	}
	return cask.outdated_default || (greedy && cask.outdated_greedy)
}

pub fn cask_upgrade_outdated_casks(casks []CaskUpgradeCandidate,
	options CaskUpgradeOutdatedOptions) !CaskUpgradeOutdatedResult {
	mut selected := []CaskUpgradeCandidate{}
	mut warnings := []string{}
	mut errors := []string{}
	mut pinned := []string{}
	mut disabled := []string{}
	for cask in casks {
		name := cask_upgrade_display_name(cask)
		if options.explicit_casks && !cask.installed && !options.force {
			return error('Cask ${name} is not installed.')
		}
		if cask.disabled {
			disabled << name
			if !options.quiet {
				warnings << 'Not upgrading ${cask.token}, it is ${cask.disable_message}'
			}
			continue
		}
		if options.explicit_casks && !cask.version_present {
			if !options.quiet {
				warnings << 'Not upgrading ${cask.token}, no version is available for the current platform'
			}
			continue
		}
		if !cask_upgrade_is_outdated(cask, options) {
			if options.explicit_casks && !options.quiet {
				if cask.version_latest {
					warnings << 'Not upgrading ${cask.token}, the downloaded artifact has not changed'
				} else {
					warnings << 'Not upgrading ${cask.token}, the latest version is already installed'
				}
			}
			continue
		}
		if cask.pinned {
			pinned << '${name} ${cask.installed_version}'
			continue
		}
		selected << cask
	}
	if pinned.len > 0 && (!options.quiet || options.explicit_casks) {
		word := if pinned.len == 1 { 'package' } else { 'packages' }
		message := 'Not upgrading ${pinned.len} pinned ${word}:'
		if options.explicit_casks {
			errors << message
		} else {
			warnings << message
		}
		if !options.quiet {
			warnings << pinned.join(', ')
		}
	}
	return CaskUpgradeOutdatedResult{
		casks: selected
		warnings: warnings
		errors: errors
		pinned: pinned
		disabled: disabled
	}
}

pub fn cask_upgrade_show_summary(upgrades []string, dry_run bool) CaskUpgradeSummary {
	if upgrades.len == 0 {
		return CaskUpgradeSummary{}
	}
	verb := if dry_run { 'Would upgrade' } else { 'Upgrading' }
	word := if upgrades.len == 1 { 'package' } else { 'packages' }
	return CaskUpgradeSummary{
		heading: '${verb} ${upgrades.len} outdated ${word}:'
		lines: upgrades.clone()
	}
}

fn cask_upgrade_loaded(cask CaskUpgradeCandidate) bool {
	if !cask.installed_after_outdated || !cask.installed_caskfile {
		return false
	}
	return match cask.load_status {
		.loaded { true }
		.invalid, .deprecated { cask.recovery_succeeds }
		else { false }
	}
}

pub fn cask_upgrade_casks(casks []CaskUpgradeCandidate,
	options CaskUpgradeOptions) !CaskUpgradeRunResult {
	outdated := cask_upgrade_outdated_casks(casks, options.outdated)!
	mut warnings := outdated.warnings.clone()
	mut errors := outdated.errors.clone()
	mut eligible := []CaskUpgradeCandidate{}
	for cask in outdated.casks {
		if cask.artifacts.any(it.kind == .installer && it.manual_install) {
			errors << 'Not upgrading 1 `installer manual` cask.'
			continue
		}
		if !cask_upgrade_loaded(cask) {
			warnings << "The cask '${cask.token}' cannot be upgraded as-is. To fix this, run:\nbrew reinstall --cask --force ${cask.token}"
			continue
		}
		eligible << cask
	}
	mut hints := []string{}
	if eligible.len > 0 && !options.no_env_hints && !options.outdated.explicit_casks && !options.outdated.greedy && options.outdated.greedy_casks.len == 0 {
		if !options.outdated.greedy_auto_updates && eligible.any(it.auto_updates) {
			hints << 'Homebrew will now attempt to upgrade casks with `auto_updates true`.'
			hints << 'Disable this behaviour with `HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1`.'
		}
		if !options.outdated.greedy_auto_updates && !options.outdated.greedy_latest {
			hints << 'Some casks with `auto_updates true` or `version :latest` may still require `--greedy`,'
			hints << '`HOMEBREW_UPGRADE_GREEDY` or `HOMEBREW_UPGRADE_GREEDY_CASKS` to be upgraded.'
		} else if options.outdated.greedy_auto_updates && !options.outdated.greedy_latest {
			hints << 'Casks with `version :latest` will not be upgraded; pass `--greedy-latest` to upgrade them.'
		} else if !options.outdated.greedy_auto_updates && options.outdated.greedy_latest {
			hints << 'Some casks with `auto_updates true` may still require `--greedy-auto-updates` to be upgraded.'
		}
		if hints.len > 0 {
			hints << 'Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).'
		}
	}
	mut failed := options.prefetched_errors.len > 0
	errors << options.prefetched_errors
	mut created_queue := false
	mut queue_shutdown := false
	if !options.dry_run && !options.skip_prefetch && eligible.len > 0 {
		created_queue = true
		mut fetchable := []CaskUpgradeCandidate{}
		for cask in eligible {
			if cask.requirement_error != '' {
				errors << cask.requirement_error
				failed = true
			} else {
				fetchable << cask
			}
		}
		eligible = fetchable.clone()
		queue_shutdown = true
	}
	mut descriptions := []string{}
	mut deprecated := []string{}
	for cask in eligible {
		descriptions << '${cask_upgrade_display_name(cask)} ${cask.installed_version} -> ${cask.version}'
		if cask.deprecated {
			deprecated << cask_upgrade_display_name(cask)
		}
	}
	summary := if options.show_summary {
		cask_upgrade_show_summary(descriptions, options.dry_run)
	} else {
		CaskUpgradeSummary{}
	}
	if options.dry_run {
		return CaskUpgradeRunResult{
			success: eligible.len > 0
			upgraded: descriptions
			pinned: outdated.pinned
			deprecated: deprecated
			disabled: outdated.disabled
			warnings: warnings
			errors: errors
			hints: hints
			summary: summary
		}
	}
	mut upgraded := []string{}
	mut attempts := []string{}
	for index, cask in eligible {
		attempts << cask.token
		if cask.upgrade_error != '' {
			errors << '${cask_upgrade_display_name(cask)}: ${cask.upgrade_error}'
			failed = true
			continue
		}
		upgraded << descriptions[index]
	}
	return CaskUpgradeRunResult{
		success: eligible.len > 0 && !failed
		upgraded: upgraded
		upgrade_attempts: attempts
		pinned: outdated.pinned
		deprecated: deprecated
		disabled: outdated.disabled
		warnings: warnings
		errors: errors
		hints: hints
		summary: summary
		created_download_queue: created_queue
		queue_shutdown: queue_shutdown
	}
}

pub fn cask_upgrade_quarantine_release_decision(old_artifacts []CaskUpgradeArtifact,
	new_artifacts []CaskUpgradeArtifact) CaskUpgradeQuarantineDecision {
	old_apps := old_artifacts.filter(it.kind == .app)
	new_apps := new_artifacts.filter(it.kind == .app)
	if old_apps.len == 0 || old_apps.len != new_apps.len {
		return .skip
	}
	if old_apps.any(!it.user_approved) {
		return .unapproved
	}
	for index, old_app in old_apps {
		if old_app.old_identity == '' {
			return .signer_unverified
		}
		match new_apps[index].new_identity_match {
			.missing {
				return .signer_unverified
			}
			.changed {
				return .signer_changed
			}
			.matches {}
		}
	}
	return .release
}

pub fn cask_upgrade_reopen_apps(old_artifacts []CaskUpgradeArtifact,
	new_artifacts []CaskUpgradeArtifact, lsregister_executable bool) CaskUpgradeReopenResult {
	mut bundle_ids := []string{}
	for artifact in old_artifacts.filter(it.kind == .uninstall) {
		bundle_ids << artifact.bundle_ids
	}
	if bundle_ids.len == 0 {
		return CaskUpgradeReopenResult{}
	}
	mut commands := [][]string{}
	if lsregister_executable {
		for artifact in new_artifacts.filter(it.kind == .app && it.exists) {
			commands << ['lsregister', '-f', artifact.target]
		}
	}
	for bundle_id in bundle_ids {
		commands << ['open', '-b', bundle_id]
	}
	word := if bundle_ids.len == 1 { 'application' } else { 'applications' }
	return CaskUpgradeReopenResult{
		heading: 'Reopening ${bundle_ids.len} ${word} closed during upgrade:'
		commands: commands
	}
}

pub fn cask_upgrade_transaction(input CaskUpgradeTransactionInput) CaskUpgradeTransactionResult {
	mut operations := ['new_prelude']
	mut warnings := []string{}
	mut started_upgrade := false
	mut installed_artifacts := false
	mut decision := CaskUpgradeQuarantineDecision.skip
	phases := [CaskUpgradeFailurePhase.prelude, .fetch, .start_upgrade, .stage, .install_artifacts,
		.quarantine, .finalize]
	for phase in phases {
		if phase == .fetch {
			operations << 'new_fetch'
		} else if phase == .start_upgrade {
			operations << 'old_start_upgrade'
			started_upgrade = true
		} else if phase == .stage {
			operations << 'new_stage'
		} else if phase == .install_artifacts {
			operations << 'new_install_artifacts'
			installed_artifacts = true
		} else if phase == .quarantine && input.quarantine_available {
			decision = cask_upgrade_quarantine_release_decision(input.old_cask.artifacts, input.new_cask.artifacts)
			operations << 'quarantine_${decision}'
			match decision {
				.release {
					if input.inherit_fails {
						warnings << "Homebrew couldn't inherit ${input.new_cask.token}'s quarantine approval so macOS may prompt at next launch."
					} else {
						operations << 'inherit_user_approval'
					}
				}
				.signer_changed {
					warnings << "${input.new_cask.token}'s signer changed so macOS may prompt at next launch."
				}
				.signer_unverified {
					warnings << "Homebrew couldn't verify ${input.new_cask.token}'s signer so macOS may prompt at next launch."
				}
				.unapproved {
					warnings << "${input.new_cask.token} wasn't quarantine approved so not approving now. macOS may prompt at next launch."
				}
				.skip {}
			}
		} else if phase == .finalize {
			operations << 'old_finalize_upgrade'
		}
		if input.failure_phase == phase {
			mut rollback_error := ''
			if installed_artifacts {
				operations << 'new_uninstall_artifacts'
			}
			operations << 'new_purge_versioned_files'
			if started_upgrade {
				operations << 'old_revert_upgrade'
			}
			if input.rollback_fails {
				rollback_error = 'rollback failed'
				warnings << 'Rolling back the failed upgrade of ${input.old_cask.token} also failed: rollback failed'
			}
			return CaskUpgradeTransactionResult{
				operations: operations
				warnings: warnings
				error_message: '${phase} failed'
				rollback_error: rollback_error
				quarantine_decision: decision
			}
		}
	}
	if input.quit {
		operations << 'reopen_apps'
	}
	operations << ['write_tab', 'package_installed']
	return CaskUpgradeTransactionResult{
		success: true
		operations: operations
		warnings: warnings
		tab_written: true
		installed_on_request: !input.old_tabfile_present || input.old_installed_on_request
		quarantine_decision: decision
	}
}
