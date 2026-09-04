module homebrew

import ruby

pub struct MissingFormulaReason {
pub:
	present bool
	text    string
}

pub struct MissingFormulaTap {
pub:
	name       string
	issues_url string
	migrations map[string]string
}

pub struct MissingDeletedFormula {
pub:
	name                 string
	tap_name             string
	tap_issues_url       string
	path_exists          bool
	tap_path_exists      bool
	core_tap             bool
	deleted_in_diff      bool
	commit_hash          string
	short_hash           string
	commit_message       string
	relative_path        string
	relative_path_string string
}

pub struct MissingFormulaCask {
pub:
	name      string
	available bool
	installed bool
	info      string
}

pub struct MissingFormulaContext {
pub:
	taps    []MissingFormulaTap
	deleted ?MissingDeletedFormula
	cask    ?MissingFormulaCask
}

fn missing_reason(text string) MissingFormulaReason {
	return MissingFormulaReason{ present: text != '', text: text }
}

pub fn missing_formula_disallowed_reason(name string) MissingFormulaReason {
	return match name.to_lower() {
		'gem', 'rubygem', 'rubygems' {
			missing_reason('macOS provides gem as part of Ruby. To install a newer version:\n  brew install ruby\n')
		}
		'pip' { missing_reason('pip is part of the python formula:\n  brew install python\n') }
		'pil' { missing_reason('Instead of PIL, consider pillow:\n  brew install pillow\n') }
		'macruby' {
			missing_reason('MacRuby has been discontinued. Consider RubyMotion:\n  brew install --cask rubymotion\n')
		}
		'lzma', 'liblzma' {
			missing_reason('lzma is now part of the xz formula:\n  brew install xz\n')
		}
		'gsutil' { missing_reason('gsutil is available through pip:\n  pip3 install gsutil\n') }
		'gfortran' {
			missing_reason('GNU Fortran is part of the GCC formula:\n  brew install gcc\n')
		}
		'play' {
			missing_reason('Play 2.3 replaces the play command with activator:\n  brew install typesafe-activator\n\nYou can read more about this change at:\n  https://www.playframework.com/documentation/2.3.x/Migration23\n  https://www.playframework.com/documentation/2.3.x/Highlights23\n')
		}
		'haskell-platform' {
			missing_reason('The components of the Haskell Platform are available separately.\n\nGlasgow Haskell Compiler:\n  brew install ghc\n\nCabal build system:\n  brew install cabal-install\n\nHaskell Stack tool:\n  brew install haskell-stack\n')
		}
		'mysqldump-secure' {
			missing_reason('The creator of mysqldump-secure tried to game our popularity metrics.\n')
		}
		'ngrok' {
			missing_reason('Upstream sunsetted 1.x in March 2016 and 2.x is not open-source.\n\nIf you wish to use the 2.x release you can install it with:\n  brew install --cask ngrok\n')
		}
		'cargo' { missing_reason('cargo is part of the rust formula:\n  brew install rust\n') }
		'cargo-completion' {
			missing_reason('cargo-completion is part of the rust formula:\n  brew install rust\n')
		}
		'uconv' { missing_reason('uconv is part of the icu4c formula:\n  brew install icu4c\n') }
		'postgresql', 'postgres' {
			missing_reason('postgresql breaks existing databases on upgrade without human intervention.\n\nSee a more specific version to install with:\n  brew formulae | grep postgresql@\n')
		}
		else { MissingFormulaReason{} }
	}
}

fn missing_formula_full_name_parts(full_name string) (string, string) {
	parts := full_name.split('/')
	if parts.len >= 3 {
		return '${parts[0]}/${parts[1]}', parts[2..].join('/')
	}
	return '', ''
}

pub fn missing_formula_tap_migration_reason(name string,
	taps []MissingFormulaTap) MissingFormulaReason {
	for tap in taps {
		new_target := tap.migrations[name] or { continue }
		same_tap := new_target == name
		migrated_tap, migrated_name := missing_formula_full_name_parts(new_target)
		same_tap_new_name := !same_tap && migrated_tap == '' && !new_target.contains('/')
		new_tap_name := if migrated_tap != '' {
			migrated_tap
		} else if new_target.contains('/') {
			new_target
		} else if same_tap_new_name {
			tap.name
		} else {
			''
		}
		new_name := if migrated_name != '' {
			migrated_name
		} else if same_tap_new_name {
			new_target
		} else {
			name
		}
		mut message := if same_tap {
			'It was migrated from a formula to a cask.\n'
		} else {
			'It was migrated from ${tap.name} to ${new_target}.\n'
		}
		install_command := if new_tap_name.starts_with('homebrew/cask') || same_tap {
			'install --cask'
		} else {
			'install'
		}
		if same_tap || same_tap_new_name || new_tap_name == 'homebrew/core' {
			message += 'You can install it by running:\n'
		} else {
			message += 'You can access it again by running:\n  brew tap ${new_tap_name}\nAnd then you can install it by running:\n'
		}
		message += '  brew ${install_command} ${new_name}\n'
		return missing_reason(message)
	}
	return MissingFormulaReason{}
}

fn missing_formula_expand_issue_links(message string, issues_url string) string {
	mut result := message
	for prefix in ['Closes #', 'Fixes #'] {
		mut start := 0
		for {
			index := result.index_after(prefix, start) or { break }
			digit_start := index + prefix.len
			mut digit_end := digit_start
			for digit_end < result.len && result[digit_end].is_digit() {
				digit_end++
			}
			if digit_end == digit_start {
				break
			}
			number := result[digit_start..digit_end]
			result = result[..digit_start - 1] + '${issues_url}/${number}' + result[digit_end..]
			start = digit_start + issues_url.len + number.len
		}
	}
	mut lines := result.split('\n')
	for index, line in lines {
		if !line.ends_with(')') {
			continue
		}
		marker := line.last_index(' (#') or { continue }
		number := line[marker + 3..line.len - 1]
		if number != '' && number.bytes().all(it.is_digit()) {
			lines[index] = line[..marker] + ' (${issues_url}/${number})'
		}
	}
	return lines.join('\n')
}

pub fn missing_formula_deleted_reason(record MissingDeletedFormula) MissingFormulaReason {
	if record.path_exists || !record.tap_path_exists {
		return MissingFormulaReason{}
	}
	if record.core_tap && !record.deleted_in_diff {
		return MissingFormulaReason{}
	}
	if record.commit_hash == '' || record.short_hash == '' || record.relative_path_string == '' {
		return MissingFormulaReason{}
	}
	message := missing_formula_expand_issue_links(record.commit_message.split_into_lines().filter(it != '').join('\n  '), record.tap_issues_url)
	return missing_reason('${record.name} was deleted from ${record.tap_name} in commit ${record.short_hash}:\n  ${message}\n\nTo show the formula before removal, run:\n  git -C "\$(brew --repo ${record.tap_name})" show ${record.short_hash}^:${record.relative_path_string}\n\nIf you still use this formula, consider creating your own tap:\n  https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap\n')
}

pub fn missing_formula_suggest_command(name string, command string,
	cask MissingFormulaCask) MissingFormulaReason {
	if command !in ['install', 'uninstall', 'info'] || !cask.available || (command == 'uninstall' && !cask.installed) {
		return MissingFormulaReason{}
	}
	if command == 'info' {
		return missing_reason('Found a cask named "${name}" instead.\n\n${cask.info}\n')
	}
	return missing_reason('Found a cask named "${name}" instead. Try\n  brew ${command} --cask ${name}\n')
}

pub fn missing_formula_cask_reason(name string, silent bool, show_info bool,
	cask MissingFormulaCask) MissingFormulaReason {
	if silent {
		return MissingFormulaReason{}
	}
	return missing_formula_suggest_command(name, if show_info { 'info' } else { 'install' }, cask)
}

pub fn missing_formula_reason(name string, silent bool, show_info bool,
	context MissingFormulaContext) MissingFormulaReason {
	if cask := context.cask {
		cask_result := missing_formula_cask_reason(name, silent, show_info, cask)
		if cask_result.present {
			return cask_result
		}
	}
	disallowed := missing_formula_disallowed_reason(name)
	if disallowed.present {
		return disallowed
	}
	migration := missing_formula_tap_migration_reason(name, context.taps)
	if migration.present {
		return migration
	}
	if record := context.deleted {
		return missing_formula_deleted_reason(record)
	}
	return MissingFormulaReason{}
}

pub fn missing_formula_reason_value(reason MissingFormulaReason) ruby.Value {
	if !reason.present {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(reason.text)
}

// Translated from Homebrew/brew `missing_formula.rb`.
