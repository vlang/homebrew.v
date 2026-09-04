module cmd

import homebrew.aliases

// Translated from Homebrew/brew `cmd/alias.rb`.
pub fn run_alias(config aliases.AliasConfig, named ?string, edit bool,
	editor aliases.AliasEditor) ![]string {
	aliases.init_aliases(config)!
	if argument := named {
		mut name := argument
		mut command := ?string(none)
		if separator := argument.index('=') {
			name = argument[..separator]
			command = argument[separator + 1..]
		}
		if value := command {
			aliases.add_alias(config, name, value)!
			if edit {
				aliases.edit_alias(config, name, none, editor)!
			}
			return []string{}
		}
		if edit {
			aliases.edit_alias(config, name, none, editor)!
			return []string{}
		}
		return aliases.show_aliases(config, [name])
	}
	if edit {
		aliases.edit_all_aliases(config, editor)!
		return []string{}
	}
	return aliases.show_aliases(config, []string{})
}
