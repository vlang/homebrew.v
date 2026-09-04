module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/caveats.rb`.
const conditional_caveats = ['requires_rosetta', 'files_in_usr_local']

pub struct CaskCaveatEntry {
pub:
	name string
	args []string
	text string
}

pub struct CaskCaveats {
pub mut:
	cask         ruby.Value
	built_in     []CaskCaveatEntry
	custom       []string
	discontinued bool
	invoked      []string
}

fn caveats_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_cask_caveats(cask ruby.Value) CaskCaveats {
	return CaskCaveats{ cask: cask }
}

pub fn cask_caveats_value(caveats CaskCaveats) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::Caveats'
		repr: caveats_text(caveats, true)
		map_data: {
			'cask':             caveats.cask
			'built_in_caveats': ruby.array_value(caveats.built_in.map(ruby.map_value({
				'name': ruby.string_value(it.name)
				'args': ruby.string_array_value(it.args)
				'text': ruby.string_value(it.text)
			})))
			'custom_caveats':   ruby.string_array_value(caveats.custom)
			'discontinued':     ruby.bool_value(caveats.discontinued)
			'invoked_caveats':  ruby.string_array_value(caveats.invoked)
		}
	}
}

pub fn cask_caveats_from_value(value ruby.Value) !CaskCaveats {
	if value.type_name != 'Cask::DSL::Caveats' {
		return error('expected Cask::DSL::Caveats, got ${value.type_name}')
	}
	mut caveats := CaskCaveats{
		cask: value.map_data['cask'] or { ruby.object_value('Cask', value.repr) }
		custom: (value.map_data['custom_caveats'] or { ruby.string_array_value([]) }).as_string_array()!
		discontinued: (value.map_data['discontinued'] or { ruby.bool_value(false) }).as_bool() or { false }
		invoked: (value.map_data['invoked_caveats'] or { ruby.string_array_value([]) }).as_string_array()!
	}
	for raw in (value.map_data['built_in_caveats'] or { ruby.array_value([]ruby.Value{}) }).as_array()! {
		caveats.built_in << CaskCaveatEntry{
			name: (raw.map_data['name'] or { ruby.string_value('') }).as_string()
			args: (raw.map_data['args'] or { ruby.string_array_value([]) }).as_string_array()!
			text: (raw.map_data['text'] or { ruby.string_value('') }).as_string()
		}
	}
	return caveats
}

fn caveats_text(caveats CaskCaveats, include_conditional bool) string {
	mut texts := caveats.custom.clone()
	for entry in caveats.built_in {
		if include_conditional || entry.name !in conditional_caveats { texts << entry.text }
	}
	return texts.join('\n')
}

fn caveats_cask_name(caveats CaskCaveats) string {
	return (caveats.cask.map_data['token'] or { ruby.string_value(caveats.cask.as_string()) }).as_string()
}

fn caveats_builtin_text(caveats CaskCaveats, name string, arguments []string) ?string {
	cask := caveats_cask_name(caveats)
	first := if arguments.len > 0 { arguments[0] } else { '' }
	match name {
		'kext' {
			version := (caveats.cask.map_data['macos_version'] or { ruby.string_value('sonoma') }).as_string()
			if version !in ['sonoma', 'sequoia', 'tahoe'] {
				return none
			}
			return '${cask} requires a kernel extension to work.\nIf the installation fails, retry after you enable it in:\n  System Settings → Privacy & Security\n\nFor more information, refer to vendor documentation or this Apple Technical Note:\n  https://developer.apple.com/library/content/technotes/tn2459/_index.html\n'
		}
		'unsigned_accessibility' {
			access := if first == '' || first == 'nil' { 'Accessibility' } else { first }
			version := (caveats.cask.map_data['macos_version'] or { ruby.string_value('ventura') }).as_string()
			navigation := if version in ['ventura', 'sonoma', 'sequoia', 'tahoe'] {
				'System Settings → Privacy & Security'
			} else {
				'System Preferences → Security & Privacy → Privacy'
			}
			return '${cask} is not signed and requires Accessibility access,\nso you will need to re-grant Accessibility access every time the app is updated.\n\nEnable or re-enable it in:\n  ${navigation} → ${access}\nTo re-enable, untick and retick ${cask}.app.\n'
		}
		'path_environment_variable' {
			return 'To use ${cask}, you may need to add the ${first} directory\nto your PATH environment variable, e.g. (for Bash shell):\n  export PATH=${first}:"\$PATH"\n'
		}
		'zsh_path_helper' {
			return 'To use ${cask}, zsh users may need to add the following line to their\n~/.zprofile. (Among other effects, ${first} will be added to the\nPATH environment variable):\n  eval `/usr/libexec/path_helper -s`\n'
		}
		'files_in_usr_local' {
			prefix := (caveats.cask.map_data['homebrew_prefix'] or { ruby.string_value('/opt/homebrew') }).as_string()
			if !prefix.to_lower().starts_with('/usr/local') {
				return none
			}
			return "Cask ${cask} installs files under /usr/local. The presence of such\nfiles can cause warnings when running `brew doctor`, which is considered\nto be a bug in Homebrew's cask handling.\n"
		}
		'depends_on_java' {
			version := if first == '' { 'any' } else { first.trim_left(':') }
			if version == 'any' {
				return '${cask} requires Java. You can install the latest version with:\n  brew install --cask temurin\n'
			}
			if version.contains('+') {
				return '${cask} requires Java ${version}. You can install the latest version with:\n  brew install --cask temurin\n'
			}
			return '${cask} requires Java ${version}. You can install it with:\n  brew install --cask temurin@${version}\n'
		}
		'requires_rosetta' {
			arch := (caveats.cask.map_data['system_arch'] or { ruby.string_value('intel') }).as_string().trim_left(':')
			installed := (caveats.cask.map_data['rosetta_installed'] or { ruby.bool_value(false) }).as_bool() or { false }
			if arch !in ['arm', 'arm64'] || installed {
				return none
			}
			return '${cask} is built for Intel macOS and so requires Rosetta 2 to be installed.\nYou can install Rosetta 2 with:\n  softwareupdate --install-rosetta --agree-to-license\nNote that it is very difficult to remove Rosetta 2 once it is installed.\n'
		}
		'logout' {
			return 'You must log out and log back in for the installation of ${cask} to take effect.\n'
		}
		'reboot' {
			return 'You must reboot for the installation of ${cask} to take effect.\n'
		}
		'license' {
			return 'Installing ${cask} means you have AGREED to the license at:\n  ${first}\n'
		}
		'free_license' {
			return 'The vendor offers a free license for ${cask} at:\n  ${first}\n'
		}
		else {
			return none
		}
	}
}

pub fn (mut caveats CaskCaveats) invoke(name string, arguments []string) {
	if name !in caveats.invoked { caveats.invoked << name }
	text := caveats_builtin_text(caveats, name, arguments) or { return }
	for index, entry in caveats.built_in {
		if entry.name == name && entry.args == arguments {
			caveats.built_in[index] = CaskCaveatEntry{ name: name, args: arguments, text: text }
			return
		}
	}
	caveats.built_in << CaskCaveatEntry{ name: name, args: arguments, text: text }
}

// Ruby method `to_s` at line 51.
pub fn ruby_caveats_l51_d5_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'to_s requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.string_value(caveats_text(caveats, true))
}
