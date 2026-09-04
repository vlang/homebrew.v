module bundle

// Translated from Homebrew/brew `bundle/installer.rb`.
pub enum InstallerPackageKind {
	brew
	cask
	tap
	other
}

pub struct InstallerEntryOptions {
pub:
	full_name    string
	clone_target string
}

pub struct BundleInstallerEntry {
pub:
	name              string
	options           InstallerEntryOptions
	package_kind      InstallerPackageKind
	install_supported bool = true
	skipped           bool
	verb              string = 'Installing'
	fetchable_name    string
	preinstall        bool = true
	install           bool = true
	trust_targets     []TrustTarget
}

pub struct InstallableEntry {
pub:
	name           string
	options        InstallerEntryOptions
	verb           string
	package_kind   InstallerPackageKind
	fetchable_name string
	preinstall     bool
	install        bool
}

pub struct InstallerApiMetadata {
pub:
	formula_names   map[string]bool
	formula_aliases map[string]bool
	formula_renames map[string]bool
	cask_tokens     map[string]bool
	cask_renames    map[string]bool
	error_message   string
}

pub struct BundleInstallOptions {
pub:
	global     bool
	file       string
	no_lock    bool
	no_upgrade bool
	verbose    bool
	force      bool
	jobs       int = 1
	quiet      bool
}

pub struct BundleInstallResult {
pub:
	succeeded bool
	success   int
	failure   int
}

pub struct BundleInstallerContext {
pub mut:
	bundle_reset_count int
	cask_reset_count   int
	tap_reset_count    int
	installed_taps     []string
	api                InstallerApiMetadata
	fetch_failure      bool
	fetched            [][]string
	trusted            []TrustTarget
	installed          []string
	events             []string
	output             []string
	errors             []string
	warnings           []string
	parallel_used      bool
}

pub fn (entry InstallableEntry) full_name() string {
	return if entry.options.full_name != '' { entry.options.full_name } else { entry.name }
}

pub fn (entry InstallableEntry) tap_name() ?string {
	parts := entry.full_name().split('/')
	if parts.len != 3 || parts.any(it == '') {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

fn clone_installer_api_metadata(metadata InstallerApiMetadata) InstallerApiMetadata {
	return InstallerApiMetadata{
		formula_names: metadata.formula_names.clone()
		formula_aliases: metadata.formula_aliases.clone()
		formula_renames: metadata.formula_renames.clone()
		cask_tokens: metadata.cask_tokens.clone()
		cask_renames: metadata.cask_renames.clone()
		error_message: metadata.error_message
	}
}

// Ruby method `self.fetchable_formulae_and_casks(entries, no_upgrade:)` at line 131.
pub fn installer_fetchable_formulae_and_casks(mut context BundleInstallerContext,
	entries []InstallableEntry, no_upgrade bool) []string {
	_ = no_upgrade
	mut fetchable := []string{}
	for entry in entries {
		if installer_tap_dependencies(mut context, entry, entries, context.installed_taps).len > 0 {
			continue
		}
		if entry.fetchable_name != '' {
			fetchable << entry.fetchable_name
		}
	}
	return fetchable
}

// Ruby method `self.tap_dependencies(entry, entries:, installed_taps:)` at line 148.
pub fn installer_tap_dependencies(mut context BundleInstallerContext,
	entry InstallableEntry, entries []InstallableEntry, installed_taps []string) []string {
	if entry.package_kind !in [.brew, .cask] {
		return []
	}
	if tap_name := entry.tap_name() {
		return if tap_name in installed_taps { [] } else { [tap_name] }
	}
	mut tap_names := []string{}
	for tap_entry in entries {
		if tap_entry.package_kind == .tap && tap_entry.name !in installed_taps {
			tap_names << tap_entry.name
		}
	}
	if tap_names.len == 0 || !installer_unavailable_without_tap(mut context, entry) {
		return []
	}
	return tap_names
}

// Ruby method `self.unavailable_without_tap?(entry)` at line 165.
pub fn installer_unavailable_without_tap(mut context BundleInstallerContext,
	entry InstallableEntry) bool {
	metadata := clone_installer_api_metadata(context.api)
	if metadata.error_message != '' {
		context.warnings << 'Treating `${entry.name}` as dependent on Brewfile taps because Homebrew could not check API metadata: ${metadata.error_message}'
		return true
	}
	return match entry.package_kind {
		.brew {
			entry.name !in metadata.formula_names && entry.name !in metadata.formula_aliases && entry.name !in metadata.formula_renames
		}
		.cask { entry.name !in metadata.cask_tokens && entry.name !in metadata.cask_renames }
		else { false }
	}
}

// Ruby method `self.install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)` at line 195.
pub fn installer_install_entry(mut context BundleInstallerContext,
	entry InstallableEntry, no_upgrade bool, verbose bool, force bool, quiet bool) bool {
	_ = no_upgrade
	_ = verbose
	_ = force
	if entry.preinstall {
		context.output << '${entry.verb} ${entry.name}'
	} else if !quiet {
		context.output << 'Using ${entry.name}'
	}
	context.events << 'install:${entry.name}'
	context.installed << entry.name
	if entry.install {
		return true
	}
	context.errors << '${entry.verb} ${entry.name} has failed!'
	return false
}
