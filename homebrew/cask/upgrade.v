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

// Ruby method `self.greedy_casks` at line 17.
pub fn ruby_upgrade_l17_d1_self_greedy_casks(value string) []string {
	return cask_upgrade_greedy_casks(value)
}

// Ruby method `self.outdated_casks(casks, args:, force:, quiet:,` at line 38.
pub fn ruby_upgrade_l38_d2_self_outdated_casks(casks []CaskUpgradeCandidate,
	options CaskUpgradeOutdatedOptions) !CaskUpgradeOutdatedResult {
	return cask_upgrade_outdated_casks(casks, options)
}

// Ruby method `self.show_upgrade_summary(cask_upgrades, dry_run: false)` at line 95.
pub fn ruby_upgrade_l95_d3_self_show_upgrade_summary(upgrades []string,
	dry_run bool) CaskUpgradeSummary {
	return cask_upgrade_show_summary(upgrades, dry_run)
}

// Ruby method `self.upgrade_casks!(` at line 128.
pub fn ruby_upgrade_l128_d4_self_upgrade_casks(casks []CaskUpgradeCandidate,
	options CaskUpgradeOptions) !CaskUpgradeRunResult {
	return cask_upgrade_casks(casks, options)
}

// Ruby method `self.quarantine_release_decision(old_cask, new_cask, old_signing_identities, old_user_approved)` at line 302.
pub fn ruby_upgrade_l302_d5_self_quarantine_release_decision(old_artifacts []CaskUpgradeArtifact,
	new_artifacts []CaskUpgradeArtifact) CaskUpgradeQuarantineDecision {
	return cask_upgrade_quarantine_release_decision(old_artifacts, new_artifacts)
}

// Ruby method `self.reopen_apps_after_upgrade(old_cask, new_cask)` at line 325.
pub fn ruby_upgrade_l325_d6_self_reopen_apps_after_upgrade(old_artifacts []CaskUpgradeArtifact,
	new_artifacts []CaskUpgradeArtifact, lsregister_executable bool) CaskUpgradeReopenResult {
	return cask_upgrade_reopen_apps(old_artifacts, new_artifacts, lsregister_executable)
}

// Ruby method `self.upgrade_cask(` at line 364.
pub fn ruby_upgrade_l364_d7_self_upgrade_cask(input CaskUpgradeTransactionInput) CaskUpgradeTransactionResult {
	return cask_upgrade_transaction(input)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "env_config"
// 5: require "cask/config"
// 6: require "cask/quarantine"
// 7: require "deprecate_disable"
// 8: require "install"
// 9: require "upgrade"
// 10: require "utils/output"
// 11:
// 12: module Cask
// 13:   class Upgrade
// 14:     extend ::Utils::Output::Mixin
// 15:
// 16:     sig { returns(T::Array[String]) }
// 17:     def self.greedy_casks
// 18:       if (upgrade_greedy_casks = Homebrew::EnvConfig.upgrade_greedy_casks.presence)
// 19:         upgrade_greedy_casks.split
// 20:       else
// 21:         []
// 22:       end
// 23:     end
// 24:
// 25:     sig {
// 26:       params(
// 27:         casks:               T::Array[Cask],
// 28:         args:                Homebrew::CLI::Args,
// 29:         force:               T.nilable(T::Boolean),
// 30:         quiet:               T.nilable(T::Boolean),
// 31:         greedy:              T.nilable(T::Boolean),
// 32:         greedy_latest:       T.nilable(T::Boolean),
// 33:         greedy_auto_updates: T.nilable(T::Boolean),
// 34:         summary_pinned:      T.nilable(T::Array[String]),
// 35:         summary_disabled:    T.nilable(T::Array[String]),
// 36:       ).returns(T::Array[Cask])
// 37:     }
// 38:     def self.outdated_casks(casks, args:, force:, quiet:,
// 39:                             greedy: false, greedy_latest: false, greedy_auto_updates: false,
// 40:                             summary_pinned: nil, summary_disabled: nil)
// 41:       greedy = true if Homebrew::EnvConfig.upgrade_greedy?
// 42:
// 43:       outdated_casks = if casks.empty?
// 44:         Caskroom.casks(config: Config.from_args(args)).select do |cask|
// 45:           if cask.disabled?
// 46:             summary_disabled&.push(cask.full_name)
// 47:             opoo "Not upgrading #{cask.token}, it is #{DeprecateDisable.message(cask)}" unless quiet
// 48:             next false
// 49:           end
// 50:
// 51:           cask_greedy = greedy || greedy_casks.include?(cask.token)
// 52:           cask.outdated?(greedy: cask_greedy, greedy_latest:,
// 53:                          greedy_auto_updates:)
// 54:         end
// 55:       else
// 56:         casks.select do |cask|
// 57:           raise CaskNotInstalledError, cask if !cask.installed? && !force
// 58:
// 59:           if cask.disabled?
// 60:             summary_disabled&.push(cask.full_name)
// 61:             opoo "Not upgrading #{cask.token}, it is #{DeprecateDisable.message(cask)}" unless quiet
// 62:             next false
// 63:           end
// 64:
// 65:           version = cask.version
// 66:           if version.nil?
// 67:             opoo "Not upgrading #{cask.token}, no version is available for the current platform" unless quiet
// 68:             false
// 69:           elsif cask.outdated?(greedy: true)
// 70:             true
// 71:           elsif version.latest?
// 72:             opoo "Not upgrading #{cask.token}, the downloaded artifact has not changed" unless quiet
// 73:             false
// 74:           else
// 75:             opoo "Not upgrading #{cask.token}, the latest version is already installed" unless quiet
// 76:             false
// 77:           end
// 78:         end
// 79:       end
// 80:
// 81:       pinned_casks = outdated_casks.select(&:pinned?)
// 82:       outdated_casks -= pinned_casks
// 83:       summary_pinned&.concat(pinned_casks.map { |cask| "#{cask.full_name} #{cask.installed_version}" })
// 84:
// 85:       if pinned_casks.any? && (!quiet || casks.any?)
// 86:         message = "Not upgrading #{pinned_casks.count} pinned #{::Utils.pluralize("package", pinned_casks.count)}:"
// 87:         casks.any? ? ofail(message) : opoo(message)
// 88:         $stderr.puts pinned_casks.map { |cask| "#{cask.full_name} #{cask.installed_version}" } * ", " unless quiet
// 89:       end
// 90:
// 91:       outdated_casks
// 92:     end
// 93:
// 94:     sig { params(cask_upgrades: T::Array[String], dry_run: T.nilable(T::Boolean)).void }
// 95:     def self.show_upgrade_summary(cask_upgrades, dry_run: false)
// 96:       return if cask_upgrades.empty?
// 97:
// 98:       verb = dry_run ? "Would upgrade" : "Upgrading"
// 99:       oh1 "#{verb} #{cask_upgrades.count} outdated #{::Utils.pluralize("package", cask_upgrades.count)}:"
// 100:       puts Homebrew::Upgrade.format_upgrade_summary(cask_upgrades).join("\n")
// 101:     end
// 102:
// 103:     sig {
// 104:       params(
// 105:         casks:                Cask,
// 106:         args:                 Homebrew::CLI::Args,
// 107:         force:                T.nilable(T::Boolean),
// 108:         greedy:               T.nilable(T::Boolean),
// 109:         greedy_latest:        T.nilable(T::Boolean),
// 110:         greedy_auto_updates:  T.nilable(T::Boolean),
// 111:         dry_run:              T.nilable(T::Boolean),
// 112:         skip_cask_deps:       T.nilable(T::Boolean),
// 113:         verbose:              T.nilable(T::Boolean),
// 114:         quiet:                T.nilable(T::Boolean),
// 115:         binaries:             T.nilable(T::Boolean),
// 116:         require_sha:          T.nilable(T::Boolean),
// 117:         quit:                 T::Boolean,
// 118:         skip_prefetch:        T::Boolean,
// 119:         show_upgrade_summary: T::Boolean,
// 120:         download_queue:       T.nilable(Homebrew::DownloadQueue),
// 121:         summary_upgrades:     T.nilable(T::Array[String]),
// 122:         summary_pinned:       T.nilable(T::Array[String]),
// 123:         summary_deprecated:   T.nilable(T::Array[String]),
// 124:         summary_disabled:     T.nilable(T::Array[String]),
// 125:         prefetched_errors:    T.nilable(T::Array[StandardError]),
// 126:       ).returns(T::Boolean)
// 127:     }
// 128:     def self.upgrade_casks!(
// 129:       *casks,
// 130:       args:,
// 131:       force: false,
// 132:       greedy: false,
// 133:       greedy_latest: false,
// 134:       greedy_auto_updates: false,
// 135:       dry_run: false,
// 136:       skip_cask_deps: false,
// 137:       verbose: false,
// 138:       quiet: false,
// 139:       binaries: nil,
// 140:       require_sha: nil,
// 141:       quit: true,
// 142:       skip_prefetch: false,
// 143:       show_upgrade_summary: true,
// 144:       download_queue: nil,
// 145:       summary_upgrades: nil,
// 146:       summary_pinned: nil,
// 147:       summary_deprecated: nil,
// 148:       summary_disabled: nil,
// 149:       prefetched_errors: nil
// 150:     )
// 151:       outdated_casks =
// 152:         self.outdated_casks(casks, args:, greedy:, greedy_latest:, greedy_auto_updates:, force:, quiet:,
// 153:                                    summary_pinned:, summary_disabled:)
// 154:
// 155:       manual_installer_casks = outdated_casks.select do |cask|
// 156:         cask.artifacts.any? do |artifact|
// 157:           artifact.is_a?(Artifact::Installer) && artifact.manual_install
// 158:         end
// 159:       end
// 160:
// 161:       if manual_installer_casks.present?
// 162:         count = manual_installer_casks.count
// 163:         ofail "Not upgrading #{count} `installer manual` #{::Utils.pluralize("cask", count)}."
// 164:         puts manual_installer_casks.map(&:to_s)
// 165:         outdated_casks -= manual_installer_casks
// 166:       end
// 167:
// 168:       return false if outdated_casks.empty?
// 169:
// 170:       if !Homebrew::EnvConfig.no_env_hints? && casks.empty? && !greedy && greedy_casks.empty?
// 171:         output_hint = false
// 172:         if !greedy_auto_updates && outdated_casks.any?(&:auto_updates)
// 173:           puts "Homebrew will now attempt to upgrade casks with `auto_updates true`."
// 174:           puts "Disable this behaviour with `HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1`."
// 175:           output_hint ||= true
// 176:         end
// 177:         if !greedy_auto_updates && !greedy_latest
// 178:           puts "Some casks with `auto_updates true` or `version :latest` may still require `--greedy`,"
// 179:           puts "`HOMEBREW_UPGRADE_GREEDY` or `HOMEBREW_UPGRADE_GREEDY_CASKS` to be upgraded."
// 180:           output_hint ||= true
// 181:         end
// 182:         if greedy_auto_updates && !greedy_latest
// 183:           puts "Casks with `version :latest` will not be upgraded; pass `--greedy-latest` to upgrade them."
// 184:           output_hint ||= true
// 185:         end
// 186:         if !greedy_auto_updates && greedy_latest
// 187:           puts "Some casks with `auto_updates true` may still require `--greedy-auto-updates` to be upgraded."
// 188:           output_hint ||= true
// 189:         end
// 190:         puts "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`)." if output_hint
// 191:       end
// 192:
// 193:       upgradable_casks = outdated_casks.filter_map do |c|
// 194:         loaded_cask = if c.installed? && (installed_caskfile = c.installed_caskfile)
// 195:           begin
// 196:             CaskLoader.load_from_installed_caskfile(installed_caskfile)
// 197:           rescue CaskInvalidError, CaskUnavailableError, MethodDeprecatedError
// 198:             CaskLoader.recover_from_installed_caskfile(installed_caskfile, fallback_cask: c)
// 199:           end
// 200:         end
// 201:
// 202:         if loaded_cask.nil?
// 203:           opoo <<~EOS
// 204:             The cask '#{c.token}' cannot be upgraded as-is. To fix this, run:
// 205:             brew reinstall --cask --force #{c.token}
// 206:           EOS
// 207:           next
// 208:         end
// 209:
// 210:         [loaded_cask, c]
// 211:       end
// 212:
// 213:       return false if upgradable_casks.empty?
// 214:
// 215:       # Report each failure as it happens and carry on with the other casks,
// 216:       # rather than aborting the run; `ofail` still exits nonzero at the end.
// 217:       prefetched_errors&.each { |error| ofail error }
// 218:       failed = T.let(prefetched_errors.present?, T::Boolean)
// 219:
// 220:       created_download_queue = T.let(false, T::Boolean)
// 221:       download_queue ||= if !dry_run && !skip_prefetch
// 222:         created_download_queue = true
// 223:         Homebrew::DownloadQueue.new(pour: true)
// 224:       end
// 225:
// 226:       if !dry_run && !skip_prefetch
// 227:         prefetch_download_queue = download_queue || Homebrew.default_download_queue
// 228:         begin
// 229:           fetchable_cask_installers = []
// 230:           upgradable_casks.select! do |(_, cask)|
// 231:             # This is significantly easier given the weird difference in Sorbet signatures here.
// 232:             # rubocop:disable Style/DoubleNegation
// 233:             installer = Installer.new(cask, binaries: !!binaries, verbose: !!verbose, force: !!force,
// 234:                                              skip_cask_deps: !!skip_cask_deps, require_sha: !!require_sha,
// 235:                                              upgrade: true,
// 236:                                              download_queue: prefetch_download_queue, defer_fetch: true)
// 237:             # rubocop:enable Style/DoubleNegation
// 238:             begin
// 239:               installer.check_requirements
// 240:             rescue CaskError => e
// 241:               ofail e
// 242:               failed = true
// 243:               next false
// 244:             end
// 245:
// 246:             fetchable_cask_installers << installer
// 247:             true
// 248:           end
// 249:
// 250:           fetchable_casks = upgradable_casks.map(&:last)
// 251:           Homebrew::Install.enqueue_cask_installers(fetchable_cask_installers,
// 252:                                                     download_queue: prefetch_download_queue)
// 253:           prefetch_download_queue.fetch(
// 254:             heading: Homebrew::Install.combined_fetch_downloads_heading(
// 255:               cask_names: fetchable_casks.map(&:full_name),
// 256:             ),
// 257:           )
// 258:         ensure
// 259:           prefetch_download_queue.shutdown if created_download_queue
// 260:         end
// 261:       end
// 262:
// 263:       return false if upgradable_casks.empty? && !failed
// 264:
// 265:       cask_upgrades = upgradable_casks.map do |(old_cask, new_cask)|
// 266:         "#{new_cask.full_name} #{old_cask.version} -> #{new_cask.version}"
// 267:       end
// 268:       summary_upgrades&.concat(cask_upgrades) if dry_run
// 269:       summary_deprecated&.concat(upgradable_casks.filter_map do |(_, new_cask)|
// 270:         new_cask.full_name if new_cask.deprecated?
// 271:       end)
// 272:
// 273:       show_upgrade_summary(cask_upgrades, dry_run:) if show_upgrade_summary
// 274:       return true if dry_run
// 275:
// 276:       download_queue ||= Homebrew.default_download_queue
// 277:
// 278:       upgradable_casks.each_with_index do |(old_cask, new_cask), index|
// 279:         upgrade_cask(
// 280:           old_cask, new_cask,
// 281:           binaries:, force:, skip_cask_deps:, verbose:,
// 282:           require_sha:, quit:, download_queue:
// 283:         )
// 284:         summary_upgrades&.push(cask_upgrades.fetch(index))
// 285:       rescue => e
// 286:         ofail "#{new_cask.full_name}: #{e}"
// 287:         failed = true
// 288:         next
// 289:       end
// 290:
// 291:       !failed
// 292:     end
// 293:
// 294:     sig {
// 295:       params(
// 296:         old_cask:               Cask,
// 297:         new_cask:               Cask,
// 298:         old_signing_identities: T::Hash[String, T.nilable(Quarantine::SigningIdentity)],
// 299:         old_user_approved:      T::Hash[String, T::Boolean],
// 300:       ).returns(Symbol)
// 301:     }
// 302:     def self.quarantine_release_decision(old_cask, new_cask, old_signing_identities, old_user_approved)
// 303:       old_app_artifacts = old_cask.artifacts.grep(Artifact::App)
// 304:       new_app_artifacts = new_cask.artifacts.grep(Artifact::App)
// 305:       return :skip if old_app_artifacts.empty? || old_app_artifacts.length != new_app_artifacts.length
// 306:       return :unapproved unless old_app_artifacts.all? do |artifact|
// 307:         old_user_approved.fetch(artifact.target.to_s, false)
// 308:       end
// 309:
// 310:       old_app_artifacts.each_with_index do |artifact, index|
// 311:         old_identity = old_signing_identities[artifact.target.to_s]
// 312:         return :signer_unverified if old_identity.nil?
// 313:
// 314:         identity_matches = Quarantine.signing_identity_match(new_app_artifacts.fetch(index).target, old_identity)
// 315:         return :signer_unverified if identity_matches.nil?
// 316:         return :signer_changed unless identity_matches
// 317:       end
// 318:
// 319:       :release
// 320:     rescue
// 321:       :skip
// 322:     end
// 323:
// 324:     sig { params(old_cask: Cask, new_cask: Cask).void }
// 325:     def self.reopen_apps_after_upgrade(old_cask, new_cask)
// 326:       bundle_ids = old_cask.artifacts
// 327:                            .grep(Artifact::Uninstall)
// 328:                            .flat_map(&:bundle_ids_to_reopen)
// 329:       return if bundle_ids.empty?
// 330:
// 331:       # Re-register newly installed apps with Launch Services before reopening
// 332:       lsregister = Pathname(
// 333:         "/System/Library/Frameworks/CoreServices.framework" \
// 334:         "/Frameworks/LaunchServices.framework/Support/lsregister",
// 335:       )
// 336:       if lsregister.executable?
// 337:         new_cask.artifacts.grep(Artifact::App).each do |artifact|
// 338:           system(lsregister.to_s, "-f", artifact.target.to_s) if artifact.target.exist?
// 339:         end
// 340:       end
// 341:
// 342:       ohai "Reopening #{bundle_ids.count} #{::Utils.pluralize("application",
// 343:                                                               bundle_ids.count)} closed during upgrade:"
// 344:       bundle_ids.each do |bundle_id|
// 345:         puts bundle_id
// 346:         system("open", "-b", bundle_id)
// 347:       end
// 348:     end
// 349:     private_class_method :reopen_apps_after_upgrade
// 350:
// 351:     sig {
// 352:       params(
// 353:         old_cask:       Cask,
// 354:         new_cask:       Cask,
// 355:         binaries:       T.nilable(T::Boolean),
// 356:         force:          T.nilable(T::Boolean),
// 357:         require_sha:    T.nilable(T::Boolean),
// 358:         quit:           T::Boolean,
// 359:         skip_cask_deps: T.nilable(T::Boolean),
// 360:         verbose:        T.nilable(T::Boolean),
// 361:         download_queue: Homebrew::DownloadQueue,
// 362:       ).void
// 363:     }
// 364:     def self.upgrade_cask(
// 365:       old_cask, new_cask,
// 366:       binaries:, force:, require_sha:, quit:, skip_cask_deps:, verbose:, download_queue:
// 367:     )
// 368:       require "cask/installer"
// 369:
// 370:       start_time = Time.now
// 371:       odebug "Started upgrade process for Cask #{old_cask}"
// 372:       old_config = old_cask.config
// 373:
// 374:       old_options = {
// 375:         binaries:,
// 376:         verbose:,
// 377:         force:,
// 378:         upgrade:  true,
// 379:       }.compact
// 380:
// 381:       old_cask_installer =
// 382:         Installer.new(old_cask, **old_options)
// 383:       old_tab = old_cask.tab
// 384:
// 385:       new_cask.config = new_cask.default_config.merge(old_config)
// 386:
// 387:       new_options = {
// 388:         binaries:,
// 389:         verbose:,
// 390:         force:,
// 391:         skip_cask_deps:,
// 392:         require_sha:,
// 393:         upgrade:        true,
// 394:         download_queue:,
// 395:       }.compact
// 396:
// 397:       new_cask_installer =
// 398:         Installer.new(new_cask, **new_options, defer_fetch: true)
// 399:
// 400:       started_upgrade = false
// 401:       new_artifacts_installed = false
// 402:       old_signing_identities = T.let({}, T::Hash[String, T.nilable(Quarantine::SigningIdentity)])
// 403:       old_user_approved = T.let({}, T::Hash[String, T::Boolean])
// 404:
// 405:       begin
// 406:         oh1 "Upgrading #{Formatter.identifier(old_cask)}"
// 407:         puts "  #{old_cask.version} -> #{new_cask.version}"
// 408:
// 409:         # Start new cask's installation steps
// 410:         new_cask_installer.prelude
// 411:
// 412:         if (caveats = new_cask_installer.caveats)
// 413:           puts caveats
// 414:         end
// 415:
// 416:         new_cask_installer.fetch
// 417:
// 418:         old_cask.artifacts.grep(Artifact::App).each do |artifact|
// 419:           old_user_approved[artifact.target.to_s] =
// 420:             if artifact.target.exist?
// 421:               Quarantine.user_approved?(artifact.target)
// 422:             else
// 423:               false
// 424:             end
// 425:           old_signing_identities[artifact.target.to_s] = Quarantine.signing_identity(artifact.target)
// 426:         end
// 427:
// 428:         # Move the old cask's artifacts back to staging
// 429:         old_cask_installer.start_upgrade(successor: new_cask, quit:)
// 430:         # And flag it so in case of error
// 431:         started_upgrade = true
// 432:
// 433:         # Install the new cask
// 434:         new_cask_installer.stage
// 435:
// 436:         new_cask_installer.install_artifacts(predecessor: old_cask)
// 437:         new_artifacts_installed = true
// 438:
// 439:         if Quarantine.available?
// 440:           case quarantine_release_decision(old_cask, new_cask, old_signing_identities, old_user_approved)
// 441:           when :release
// 442:             new_cask.artifacts.grep(Artifact::App).each do |artifact|
// 443:               Quarantine.inherit_user_approval!(download_path: artifact.target)
// 444:             rescue CaskQuarantineReleaseError => e
// 445:               odebug e
// 446:               opoo "Homebrew couldn't inherit #{new_cask.token}'s quarantine approval so macOS may prompt at " \
// 447:                    "next launch."
// 448:             end
// 449:           when :signer_changed
// 450:             opoo "#{new_cask.token}'s signer changed so macOS may prompt at next launch."
// 451:           when :signer_unverified
// 452:             opoo "Homebrew couldn't verify #{new_cask.token}'s signer so macOS may prompt at next launch."
// 453:           when :unapproved
// 454:             message = "#{new_cask.token} wasn't quarantine approved so not approving now. " \
// 455:                       "macOS may prompt at next launch."
// 456:             if verbose
// 457:               ohai message
// 458:             else
// 459:               odebug message
// 460:             end
// 461:           end
// 462:         end
// 463:
// 464:         # If successful, wipe the old cask from staging.
// 465:         old_cask_installer.finalize_upgrade
// 466:
// 467:         reopen_apps_after_upgrade(old_cask, new_cask) if quit
// 468:       rescue => e
// 469:         begin
// 470:           new_cask_installer.uninstall_artifacts(successor: old_cask, quit:) if new_artifacts_installed
// 471:           new_cask_installer.purge_versioned_files
// 472:           old_cask_installer.revert_upgrade(predecessor: new_cask) if started_upgrade
// 473:         rescue => rollback_error
// 474:           opoo "Rolling back the failed upgrade of #{old_cask.token} also failed: " \
// 475:                "#{rollback_error.class}: #{rollback_error.message}"
// 476:           if (rollback_backtrace = rollback_error.backtrace)
// 477:             odebug "Rollback backtrace:", rollback_backtrace
// 478:           end
// 479:         end
// 480:         raise e
// 481:       end
// 482:
// 483:       # Wait until rollback is no longer possible so failures keep the old
// 484:       # receipt, while successful upgrades can load artifacts next time.
// 485:       tab = Tab.create(new_cask)
// 486:       tab.installed_on_request = old_tab.tabfile.nil? || old_tab.installed_on_request
// 487:       tab.write
// 488:
// 489:       end_time = Time.now
// 490:       Homebrew.messages.package_installed(new_cask.token, end_time - start_time)
// 491:     end
// 492:   end
// 493: end
