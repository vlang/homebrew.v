module bundle

import ruby
import homebrew

// Translated from Homebrew/brew `bundle/trust.rb`.
pub enum BrewfileEntryType {
	tap
	brew
	cask
	other
}

pub enum TrustTargetType {
	tap
	formula
	cask
	command
}

pub struct BrewfileTrustOptions {
pub:
	trusted       bool
	trusted_items map[string][]string
	clone_target  string
	full_name     string
}

pub struct BrewfileEntry {
pub:
	entry_type BrewfileEntryType
	name       string
	options    BrewfileTrustOptions
}

pub struct TrustTarget {
pub:
	target_type TrustTargetType
	name        string
}

pub struct BundleTrustUsageError {
pub:
	message string
}

pub fn (usage_error BundleTrustUsageError) msg() string {
	return usage_error.message
}

pub fn (usage_error BundleTrustUsageError) code() int {
	return 64
}

pub type TrustTargetCanonicalizer = fn (name string, target_type TrustTargetType, tap_remote string, installed_tap_remotes map[string]string) !TrustTarget

pub struct BundleTrustContext {
pub:
	installed_tap_remotes map[string]string
	canonicalizer         TrustTargetCanonicalizer = canonical_bundle_trust_target
}

pub fn sanitize_bundle_tap_name(name string) string {
	parts := name.to_lower().split('/')
	if parts.len != 2 {
		return name.to_lower()
	}
	mut repository := parts[1]
	for prefix in ['homebrew-', 'linuxbrew-'] {
		if repository.starts_with(prefix) {
			repository = repository[prefix.len..]
			break
		}
	}
	return '${parts[0]}/${repository}'
}

fn bundle_name_from_full_name(full_name string) string {
	parts := full_name.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { full_name }
}

fn bundle_tap_from_full_name(full_name string) ?string {
	parts := full_name.split_nth('/', 3)
	if parts.len != 3 {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

fn bundle_full_name(full_name string) bool {
	return full_name.count('/') == 2
}

fn canonical_installed_tap_remotes(remotes map[string]string) map[string]string {
	mut canonical := map[string]string{}
	for name, remote in remotes {
		canonical[sanitize_bundle_tap_name(name)] = remote
	}
	return canonical
}

pub fn canonical_bundle_trust_target(name string, target_type TrustTargetType, tap_remote string,
	installed_tap_remotes map[string]string) !TrustTarget {
	canonical_installed := canonical_installed_tap_remotes(installed_tap_remotes)
	if target_type == .tap {
		tap_name := sanitize_bundle_tap_name(name)
		remote := if tap_remote.trim_space() != '' {
			tap_remote
		} else {
			canonical_installed[tap_name] or { '' }
		}
		tap := homebrew.new_tap_reference(tap_name, remote) or {
			return BundleTrustUsageError{ message: err.msg() }
		}
		return TrustTarget{
			target_type: target_type
			name: tap.reference()
		}
	}
	if !bundle_full_name(name) {
		return BundleTrustUsageError{
			message: '${target_type} must be fully-qualified as <user>/<tap>/<name>.'
		}
	}
	tap_name := sanitize_bundle_tap_name(bundle_tap_from_full_name(name) or {
		return BundleTrustUsageError{ message: 'invalid fully-qualified trust target: ${name}' }
	})
	item_name := bundle_name_from_full_name(name).to_lower()
	remote := if tap_remote.trim_space() != '' {
		tap_remote
	} else {
		canonical_installed[tap_name] or { '' }
	}
	tap := homebrew.new_tap_reference(tap_name, remote) or {
		return BundleTrustUsageError{ message: err.msg() }
	}
	reference := tap.reference().to_lower()
	return TrustTarget{
		target_type: target_type
		name: '${reference}/${item_name}'
	}
}

fn trusted_target_type(key string) ?TrustTargetType {
	return match key {
		'formula', 'formulae' { TrustTargetType.formula }
		'cask', 'casks' { TrustTargetType.cask }
		'command', 'commands' { TrustTargetType.command }
		else { none }
	}
}

fn append_unique_trust_target(mut targets []TrustTarget, target TrustTarget) {
	if target !in targets {
		targets << target
	}
}

pub fn bundle_trust_entries(entries []BrewfileEntry, context BundleTrustContext) ![]TrustTarget {
	mut tap_remotes := map[string]string{}
	for entry in entries {
		if entry.entry_type == .tap && entry.options.clone_target.trim_space() != '' {
			tap_remotes[sanitize_bundle_tap_name(entry.name)] = entry.options.clone_target
		}
	}
	mut targets := []TrustTarget{}
	for entry in entries {
		if !entry.options.trusted && entry.options.trusted_items.len == 0 {
			continue
		}
		match entry.entry_type {
			.tap {
				remote := entry.options.clone_target
				if entry.options.trusted {
					target := context.canonicalizer(entry.name, TrustTargetType.tap, remote, context.installed_tap_remotes)!
					append_unique_trust_target(mut targets, target)
				} else {
					mut unsupported := []string{}
					for key in entry.options.trusted_items.keys() {
						if trusted_target_type(key) == none {
							unsupported << key
						}
					}
					if unsupported.len > 0 {
						unsupported.sort()
						return BundleTrustUsageError{
							message: 'Unsupported trusted keys: ${unsupported.join(', ')}'
						}
					}
					for key in ['formula', 'formulae', 'cask', 'casks', 'command', 'commands'] {
						target_type := trusted_target_type(key) or { continue }
						for item in entry.options.trusted_items[key] or { [] } {
							item_name := bundle_name_from_full_name(item).trim_space()
							if item_name == '' {
								continue
							}
							full_name := '${sanitize_bundle_tap_name(entry.name)}/${item_name}'
							target := context.canonicalizer(full_name, target_type, remote, context.installed_tap_remotes)!
							append_unique_trust_target(mut targets, target)
						}
					}
				}
			}
			.brew, .cask {
				if !entry.options.trusted {
					continue
				}
				full_name := if entry.options.full_name != '' {
					entry.options.full_name
				} else {
					entry.name
				}
				if !bundle_full_name(full_name) {
					continue
				}
				tap_name := sanitize_bundle_tap_name(bundle_tap_from_full_name(full_name) or {
					continue
				})
				remote := tap_remotes[tap_name] or { '' }
				target_type := if entry.entry_type == .brew {
					TrustTargetType.formula
				} else {
					TrustTargetType.cask
				}
				target := context.canonicalizer(full_name, target_type, remote, context.installed_tap_remotes)!
				append_unique_trust_target(mut targets, target)
			}
			.other {}
		}
	}
	return targets
}

pub fn brewfile_entry_value(entry BrewfileEntry) ruby.Value {
	mut attributes := {
		'entry_type':   entry.entry_type.str()
		'name':         entry.name
		'trusted':      entry.options.trusted.str()
		'clone_target': entry.options.clone_target
		'full_name':    entry.options.full_name
	}
	for key, items in entry.options.trusted_items {
		attributes['trusted.${key}'] = items.join('\x1f')
	}
	return ruby.structured_value('Homebrew::Bundle::Dsl::Entry', entry.name, attributes)
}

pub fn brewfile_entry_from_value(value ruby.Value) BrewfileEntry {
	entry_type := match value.attributes['entry_type'] or { '' } {
		'tap' { BrewfileEntryType.tap }
		'brew' { BrewfileEntryType.brew }
		'cask' { BrewfileEntryType.cask }
		else { BrewfileEntryType.other }
	}
	mut trusted_items := map[string][]string{}
	for key, items in value.attributes {
		if key.starts_with('trusted.') {
			trusted_items[key['trusted.'.len..]] = if items == '' {
				[]
			} else {
				items.split('\x1f')
			}
		}
	}
	return BrewfileEntry{
		entry_type: entry_type
		name: value.attributes['name'] or { value.as_string() }
		options: BrewfileTrustOptions{
			trusted: (value.attributes['trusted'] or { 'false' }) == 'true'
			trusted_items: trusted_items
			clone_target: value.attributes['clone_target'] or { '' }
			full_name: value.attributes['full_name'] or { '' }
		}
	}
}

pub fn trust_target_value(target TrustTarget) ruby.Value {
	return ruby.structured_value('TrustTarget', target.name, {
		'type': target.target_type.str()
		'name': target.name
	})
}
