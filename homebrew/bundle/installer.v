module bundle

// Translated from Homebrew/brew `bundle/installer.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `full_name` at line 23.
pub fn ruby_installer_l23_d1_full_name(entry InstallableEntry) string {
	return entry.full_name()
}

// Ruby method `tap_name` at line 28.
pub fn ruby_installer_l28_d2_tap_name(entry InstallableEntry) ?string {
	return entry.tap_name()
}

// Ruby method `self.reset!` at line 34.
pub fn ruby_installer_l34_d3_self_reset(mut context BundleInstallerContext) {
	context.bundle_reset_count++
	context.cask_reset_count++
	context.tap_reset_count++
}

// Ruby method `self.install!(entries, global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false,` at line 53.
pub fn ruby_installer_l53_d4_self_install(mut context BundleInstallerContext,
	entries []BundleInstallerEntry, options BundleInstallOptions) BundleInstallResult {
	// These arguments are intentionally accepted for parity with Bundle::Installer;
	// the Ruby implementation currently delegates their handling to its caller.
	_ = options.global
	_ = options.file
	_ = options.no_lock
	mut installable_entries := []InstallableEntry{}
	mut trusted_targets := []TrustTarget{}
	for entry in entries {
		if entry.skipped || !entry.install_supported {
			continue
		}
		installable_entries << InstallableEntry{
			name: entry.name
			options: entry.options
			verb: entry.verb
			package_kind: entry.package_kind
			fetchable_name: entry.fetchable_name
			preinstall: entry.preinstall
			install: entry.install
		}
		trusted_targets << entry.trust_targets
	}
	// Trust is applied before fetchability checks because both may load tap code.
	for target in trusted_targets {
		context.trusted << target
		context.events << 'trust:${target.name}'
	}
	fetchable := installer_fetchable_formulae_and_casks(mut context, installable_entries, options.no_upgrade)
	if fetchable.len > 0 {
		if !options.quiet {
			context.output << 'Fetching ${fetchable.join(', ')}'
		}
		context.fetched << fetchable.clone()
		context.events << 'fetch:${fetchable.join(',')}'
		if context.fetch_failure {
			context.errors << '`brew bundle` failed! Failed to fetch ${fetchable.join(', ')}'
			return BundleInstallResult{ failure: 1 }
		}
	}
	context.parallel_used = options.jobs > 1 && installable_entries.len > 1
	mut success := 0
	mut failure := 0
	for entry in installable_entries {
		if installer_install_entry(mut context, entry, options.no_upgrade, options.verbose, options.force, options.quiet) {
			success++
		} else {
			failure++
		}
	}
	if failure > 0 {
		dependency := if failure == 1 { 'dependency' } else { 'dependencies' }
		context.errors << '`brew bundle` failed! ${failure} Brewfile ${dependency} failed to install'
		return BundleInstallResult{ success: success, failure: failure }
	}
	if !options.quiet {
		dependency := if success == 1 { 'dependency' } else { 'dependencies' }
		context.output << '`brew bundle` complete! ${success} Brewfile ${dependency} now installed.'
	}
	return BundleInstallResult{
		succeeded: true
		success: success
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5: require "bundle/package_types"
// 6: require "bundle/skipper"
// 7: require "bundle/trust"
// 8: require "trust"
// 9: require "utils/output"
// 10:
// 11: module Homebrew
// 12:   module Bundle
// 13:     module Installer
// 14:       extend ::Utils::Output::Mixin
// 15:
// 16:       class InstallableEntry < T::Struct
// 17:         const :name, String
// 18:         const :options, Homebrew::Bundle::EntryOptions
// 19:         const :verb, String
// 20:         const :cls, T.class_of(Homebrew::Bundle::PackageType)
// 21:
// 22:         sig { returns(String) }
// 23:         def full_name
// 24:           T.cast(options.fetch(:full_name, name), String)
// 25:         end
// 26:
// 27:         sig { returns(T.nilable(String)) }
// 28:         def tap_name
// 29:           ::Utils.tap_from_full_name(full_name)
// 30:         end
// 31:       end
// 32:
// 33:       sig { void }
// 34:       def self.reset!
// 35:         Homebrew::Bundle.reset!
// 36:         Homebrew::Bundle::Cask.reset!
// 37:         Homebrew::Bundle::Tap.reset!
// 38:       end
// 39:
// 40:       sig {
// 41:         params(
// 42:           entries:    T::Array[Dsl::Entry],
// 43:           global:     T::Boolean,
// 44:           file:       T.nilable(String),
// 45:           no_lock:    T::Boolean,
// 46:           no_upgrade: T::Boolean,
// 47:           verbose:    T::Boolean,
// 48:           force:      T::Boolean,
// 49:           jobs:       Integer,
// 50:           quiet:      T::Boolean,
// 51:         ).returns(T::Boolean)
// 52:       }
// 53:       def self.install!(entries, global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false,
// 54:                         force: false, jobs: 1, quiet: false)
// 55:         success = 0
// 56:         failure = 0
// 57:
// 58:         installable_entries = T.let([], T::Array[InstallableEntry])
// 59:         installable_brewfile_entries = T.let([], T::Array[Dsl::Entry])
// 60:         entries.each do |entry|
// 61:           next if Homebrew::Bundle::Skipper.skip? entry
// 62:
// 63:           name = entry.name
// 64:           options = entry.options
// 65:           type = entry.type
// 66:           cls = Homebrew::Bundle.installable(type)
// 67:           next if cls.nil? || !cls.install_supported?
// 68:
// 69:           installable_brewfile_entries << entry
// 70:           installable_entries << InstallableEntry.new(name:, options:, verb: cls.install_verb(name, options), cls:)
// 71:         end
// 72:
// 73:         # Apply `trusted: true` Brewfile options before anything fetches or
// 74:         # loads the entries: the fetch phase and upgrade checks load formulae
// 75:         # and casks, which triggers the tap trust check before the per-entry
// 76:         # install step could grant trust.
// 77:         Homebrew::Bundle::Trust.entries(installable_brewfile_entries).each do |type, name|
// 78:           Homebrew::Trust.trust!(type, name)
// 79:         end
// 80:
// 81:         if (fetchable_names = fetchable_formulae_and_casks(installable_entries, no_upgrade:).presence)
// 82:           fetchable_names_joined = fetchable_names.join(", ")
// 83:           puts Formatter.success("Fetching #{fetchable_names_joined}") unless quiet
// 84:           unless Bundle.brew("fetch", *fetchable_names, verbose:)
// 85:             $stderr.puts Formatter.error "`brew bundle` failed! Failed to fetch #{fetchable_names_joined}"
// 86:             return false
// 87:           end
// 88:         end
// 89:
// 90:         if jobs > 1 && installable_entries.size > 1
// 91:           require "bundle/parallel_installer"
// 92:
// 93:           parallel = ParallelInstaller.new(
// 94:             installable_entries, jobs:, no_upgrade:, verbose:, force:, quiet:
// 95:           )
// 96:           parallel_success, parallel_failure = parallel.run!
// 97:           success += parallel_success
// 98:           failure += parallel_failure
// 99:         else
// 100:           installable_entries.each do |entry|
// 101:             if install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)
// 102:               success += 1
// 103:             else
// 104:               failure += 1
// 105:             end
// 106:           end
// 107:         end
// 108:
// 109:         unless failure.zero?
// 110:           require "utils"
// 111:           dependency = Utils.pluralize("dependency", failure)
// 112:           $stderr.puts Formatter.error "`brew bundle` failed! #{failure} Brewfile #{dependency} failed to install"
// 113:           return false
// 114:         end
// 115:
// 116:         unless quiet
// 117:           require "utils"
// 118:           dependency = Utils.pluralize("dependency", success)
// 119:           puts Formatter.success "`brew bundle` complete! #{success} Brewfile #{dependency} now installed."
// 120:         end
// 121:
// 122:         true
// 123:       end
// 124:
// 125:       sig {
// 126:         params(
// 127:           entries:    T::Array[InstallableEntry],
// 128:           no_upgrade: T::Boolean,
// 129:         ).returns(T::Array[String])
// 130:       }
// 131:       def self.fetchable_formulae_and_casks(entries, no_upgrade:)
// 132:         installed_taps = Tap.installed_taps
// 133:
// 134:         entries.filter_map do |entry|
// 135:           next if tap_dependencies(entry, entries:, installed_taps:).present?
// 136:
// 137:           entry.cls.fetchable_name(entry.name, entry.options, no_upgrade:)
// 138:         end
// 139:       end
// 140:
// 141:       sig {
// 142:         params(
// 143:           entry:          InstallableEntry,
// 144:           entries:        T::Array[InstallableEntry],
// 145:           installed_taps: T::Array[String],
// 146:         ).returns(T::Array[String])
// 147:       }
// 148:       def self.tap_dependencies(entry, entries:, installed_taps:)
// 149:         return [] unless [Brew, Cask].include?(entry.cls)
// 150:
// 151:         if (tap_name = entry.tap_name)
// 152:           return installed_taps.exclude?(tap_name) ? [tap_name] : []
// 153:         end
// 154:
// 155:         tap_names = entries.filter_map do |tap_entry|
// 156:           tap_entry.name if tap_entry.cls == Tap && installed_taps.exclude?(tap_entry.name)
// 157:         end
// 158:         return [] if tap_names.empty?
// 159:         return [] unless unavailable_without_tap?(entry)
// 160:
// 161:         tap_names
// 162:       end
// 163:
// 164:       sig { params(entry: InstallableEntry).returns(T::Boolean) }
// 165:       def self.unavailable_without_tap?(entry)
// 166:         require "api"
// 167:
// 168:         case entry.cls.name
// 169:         when "Homebrew::Bundle::Brew"
// 170:           !Homebrew::API.formula_name?(entry.name) &&
// 171:             Homebrew::API.formula_aliases.exclude?(entry.name) &&
// 172:             Homebrew::API.formula_renames.exclude?(entry.name)
// 173:         when "Homebrew::Bundle::Cask"
// 174:           !Homebrew::API.cask_token?(entry.name) &&
// 175:             Homebrew::API.cask_renames.exclude?(entry.name)
// 176:         else
// 177:           false
// 178:         end
// 179:       rescue => e
// 180:         opoo "Treating `#{entry.name}` as dependent on Brewfile taps because Homebrew could not " \
// 181:              "check API metadata: #{e}"
// 182:         true
// 183:       end
// 184:       private_class_method :unavailable_without_tap?
// 185:
// 186:       sig {
// 187:         params(
// 188:           entry:      InstallableEntry,
// 189:           no_upgrade: T::Boolean,
// 190:           verbose:    T::Boolean,
// 191:           force:      T::Boolean,
// 192:           quiet:      T::Boolean,
// 193:         ).returns(T::Boolean)
// 194:       }
// 195:       def self.install_entry!(entry, no_upgrade:, verbose:, force:, quiet:)
// 196:         name = entry.name
// 197:         options = entry.options
// 198:         verb = entry.verb
// 199:         cls = entry.cls
// 200:
// 201:         preinstall = if cls.preinstall!(name, **options, no_upgrade:, verbose:)
// 202:           puts Formatter.success("#{verb} #{name}")
// 203:           true
// 204:         else
// 205:           puts "Using #{name}" unless quiet
// 206:           false
// 207:         end
// 208:
// 209:         if cls.install!(name, **options,
// 210:                         preinstall:, no_upgrade:, verbose:, force:)
// 211:           true
// 212:         else
// 213:           $stderr.puts Formatter.error("#{verb} #{name} has failed!")
// 214:           false
// 215:         end
// 216:       end
// 217:       private_class_method :install_entry!
// 218:     end
// 219:   end
// 220: end
