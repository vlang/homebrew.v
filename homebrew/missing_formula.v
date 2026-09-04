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
// The original source is retained below until every stub has a typed V body.

// Ruby method `reason(name, silent: false, show_info: false)` at line 15.
pub fn ruby_missing_formula_l15_d1_reason(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('reason requires a formula name') }
	return missing_formula_reason_value(missing_formula_reason(args[0].as_string(), false, false, MissingFormulaContext{}))
}

// Ruby method `disallowed_reason(name)` at line 21.
pub fn ruby_missing_formula_l21_d2_disallowed_reason(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('disallowed_reason requires a formula name') }
	return missing_formula_reason_value(missing_formula_disallowed_reason(args[0].as_string()))
}

// Ruby method `tap_migration_reason(name)` at line 102.
pub fn ruby_missing_formula_l102_d3_tap_migration_reason(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('NilClass', 'nil')
	}
	tap := MissingFormulaTap{
		name: args[1].as_string()
		migrations: {
			args[0].as_string(): args[2].as_string()
		}
	}
	return missing_formula_reason_value(missing_formula_tap_migration_reason(args[0].as_string(), [
		tap,
	]))
}

// Ruby method `deleted_reason(name, silent: false)` at line 155.
pub fn ruby_missing_formula_l155_d4_deleted_reason(args ...ruby.Value) ruby.Value {
	if args.len < 7 {
		return ruby.object_value('NilClass', 'nil')
	}
	record := MissingDeletedFormula{
		name: args[0].as_string()
		tap_name: args[1].as_string()
		tap_issues_url: args[2].as_string()
		tap_path_exists: true
		deleted_in_diff: true
		commit_hash: args[3].as_string()
		short_hash: args[4].as_string()
		commit_message: args[5].as_string()
		relative_path_string: args[6].as_string()
	}
	return missing_formula_reason_value(missing_formula_deleted_reason(record))
}

// Ruby method `cask_reason(name, silent: false, show_info: false); end` at line 220.
pub fn ruby_missing_formula_l220_d5_cask_reason(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `suggest_command(name, command); end` at line 223.
pub fn ruby_missing_formula_l223_d6_suggest_command(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formulary"
// 5: require "utils"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Helper module for checking if there is a reason a formula is missing.
// 10:   module MissingFormula
// 11:     extend Utils::Output::Mixin
// 12:
// 13:     class << self
// 14:       sig { params(name: String, silent: T::Boolean, show_info: T::Boolean).returns(T.nilable(String)) }
// 15:       def reason(name, silent: false, show_info: false)
// 16:         cask_reason(name, silent:, show_info:) || disallowed_reason(name) ||
// 17:           tap_migration_reason(name) || deleted_reason(name, silent:)
// 18:       end
// 19:
// 20:       sig { params(name: String).returns(T.nilable(String)) }
// 21:       def disallowed_reason(name)
// 22:         case name.downcase
// 23:         when "gem", /^rubygems?$/ then <<~EOS
// 24:           macOS provides gem as part of Ruby. To install a newer version:
// 25:             brew install ruby
// 26:         EOS
// 27:         when "pip" then <<~EOS
// 28:           pip is part of the python formula:
// 29:             brew install python
// 30:         EOS
// 31:         when "pil" then <<~EOS
// 32:           Instead of PIL, consider pillow:
// 33:             brew install pillow
// 34:         EOS
// 35:         when "macruby" then <<~EOS
// 36:           MacRuby has been discontinued. Consider RubyMotion:
// 37:             brew install --cask rubymotion
// 38:         EOS
// 39:         when /(lib)?lzma/ then <<~EOS
// 40:           lzma is now part of the xz formula:
// 41:             brew install xz
// 42:         EOS
// 43:         when "gsutil" then <<~EOS
// 44:           gsutil is available through pip:
// 45:             pip3 install gsutil
// 46:         EOS
// 47:         when "gfortran" then <<~EOS
// 48:           GNU Fortran is part of the GCC formula:
// 49:             brew install gcc
// 50:         EOS
// 51:         when "play" then <<~EOS
// 52:           Play 2.3 replaces the play command with activator:
// 53:             brew install typesafe-activator
// 54:
// 55:           You can read more about this change at:
// 56:             #{Formatter.url("https://www.playframework.com/documentation/2.3.x/Migration23")}
// 57:             #{Formatter.url("https://www.playframework.com/documentation/2.3.x/Highlights23")}
// 58:         EOS
// 59:         when "haskell-platform" then <<~EOS
// 60:           The components of the Haskell Platform are available separately.
// 61:
// 62:           Glasgow Haskell Compiler:
// 63:             brew install ghc
// 64:
// 65:           Cabal build system:
// 66:             brew install cabal-install
// 67:
// 68:           Haskell Stack tool:
// 69:             brew install haskell-stack
// 70:         EOS
// 71:         when "mysqldump-secure" then <<~EOS
// 72:           The creator of mysqldump-secure tried to game our popularity metrics.
// 73:         EOS
// 74:         when "ngrok" then <<~EOS
// 75:           Upstream sunsetted 1.x in March 2016 and 2.x is not open-source.
// 76:
// 77:           If you wish to use the 2.x release you can install it with:
// 78:             brew install --cask ngrok
// 79:         EOS
// 80:         when "cargo" then <<~EOS
// 81:           cargo is part of the rust formula:
// 82:             brew install rust
// 83:         EOS
// 84:         when "cargo-completion" then <<~EOS
// 85:           cargo-completion is part of the rust formula:
// 86:             brew install rust
// 87:         EOS
// 88:         when "uconv" then <<~EOS
// 89:           uconv is part of the icu4c formula:
// 90:             brew install icu4c
// 91:         EOS
// 92:         when "postgresql", "postgres" then <<~EOS
// 93:           postgresql breaks existing databases on upgrade without human intervention.
// 94:
// 95:           See a more specific version to install with:
// 96:             brew formulae | grep postgresql@
// 97:         EOS
// 98:         end
// 99:       end
// 100:
// 101:       sig { params(name: String).returns(T.nilable(String)) }
// 102:       def tap_migration_reason(name)
// 103:         message = T.let(nil, T.nilable(String))
// 104:
// 105:         Tap.each do |old_tap|
// 106:           new_tap = old_tap.tap_migrations[name]
// 107:           next unless new_tap
// 108:
// 109:           same_tap = new_tap == name
// 110:           migrated_tap_name = Utils.tap_from_full_name(new_tap)
// 111:           same_tap_new_name = !same_tap && migrated_tap_name.nil? && new_tap.exclude?("/")
// 112:           new_tap_name = if migrated_tap_name
// 113:             migrated_tap_name
// 114:           elsif new_tap.include?("/")
// 115:             new_tap
// 116:           elsif same_tap_new_name
// 117:             old_tap.name
// 118:           end
// 119:           new_tap_new_name = if migrated_tap_name
// 120:             Utils.name_from_full_name(new_tap)
// 121:           elsif same_tap_new_name
// 122:             new_tap
// 123:           end
// 124:
// 125:           message = if same_tap
// 126:             "It was migrated from a formula to a cask.\n"
// 127:           else
// 128:             "It was migrated from #{old_tap} to #{new_tap}.\n"
// 129:           end
// 130:
// 131:           install_cmd = if new_tap_name&.start_with?("homebrew/cask") || same_tap
// 132:             "install --cask"
// 133:           else
// 134:             "install"
// 135:           end
// 136:           new_tap_new_name ||= name
// 137:
// 138:           message += if same_tap || same_tap_new_name || new_tap_name == CoreTap.instance.name
// 139:             "You can install it by running:\n"
// 140:           else
// 141:             <<~EOS
// 142:               You can access it again by running:
// 143:                 brew tap #{T.must(new_tap_name)}
// 144:               And then you can install it by running:
// 145:             EOS
// 146:           end
// 147:           message += "  brew #{install_cmd} #{new_tap_new_name}\n"
// 148:           break
// 149:         end
// 150:
// 151:         message
// 152:       end
// 153:
// 154:       sig { params(name: String, silent: T::Boolean).returns(T.nilable(String)) }
// 155:       def deleted_reason(name, silent: false)
// 156:         path = Formulary.path name
// 157:         return if File.exist? path
// 158:
// 159:         tap = Tap.from_path(path)
// 160:         return if tap.nil? || !File.exist?(tap.path)
// 161:
// 162:         relative_path = path.relative_path_from tap.path
// 163:
// 164:         tap.path.cd do
// 165:           unless silent
// 166:             ohai "Searching for a previously deleted formula (in the last month)..."
// 167:             if (tap.path/".git/shallow").exist?
// 168:               opoo <<~EOS
// 169:                 #{tap} is shallow clone. To get its complete history, run:
// 170:                   git -C "$(brew --repo #{tap})" fetch --unshallow
// 171:
// 172:               EOS
// 173:             end
// 174:           end
// 175:
// 176:           # Optimization for the core tap which has many monthly commits
// 177:           if tap.core_tap?
// 178:             # Check if the formula has been deleted in the last month.
// 179:             diff_command = ["git", "diff", "--diff-filter=D", "--name-only",
// 180:                             "@{'1 month ago'}", "--", relative_path]
// 181:             deleted_formula = Utils.popen_read(*diff_command)
// 182:
// 183:             if deleted_formula.blank?
// 184:               ofail "No previously deleted formula found." unless silent
// 185:               return
// 186:             end
// 187:           end
// 188:
// 189:           # Find commit where formula was deleted in the last month.
// 190:           log_command = "git log --since='1 month ago' --diff-filter=D " \
// 191:                         "--name-only --max-count=1 " \
// 192:                         "--format=%H\\\\n%h\\\\n%B -- #{relative_path}"
// 193:           hash, short_hash, *commit_message, relative_path_string =
// 194:             Utils.popen_read(log_command).gsub("\\n", "\n").lines.map(&:chomp)
// 195:
// 196:           if hash.blank? || short_hash.blank? || relative_path_string.blank?
// 197:             ofail "No previously deleted formula found." unless silent
// 198:             return
// 199:           end
// 200:
// 201:           commit_message = commit_message.reject(&:empty?).join("\n  ")
// 202:
// 203:           commit_message.sub!(/ \(#(\d+)\)$/, " (#{tap.issues_url}/\\1)")
// 204:           commit_message.gsub!(/(Closes|Fixes) #(\d+)/, "\\1 #{tap.issues_url}/\\2")
// 205:
// 206:           <<~EOS
// 207:             #{name} was deleted from #{tap.name} in commit #{short_hash}:
// 208:               #{commit_message}
// 209:
// 210:             To show the formula before removal, run:
// 211:               git -C "$(brew --repo #{tap})" show #{short_hash}^:#{relative_path_string}
// 212:
// 213:             If you still use this formula, consider creating your own tap:
// 214:               #{Formatter.url("https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap")}
// 215:           EOS
// 216:         end
// 217:       end
// 218:
// 219:       sig { params(name: String, silent: T::Boolean, show_info: T::Boolean).returns(T.nilable(String)) }
// 220:       def cask_reason(name, silent: false, show_info: false); end
// 221:
// 222:       sig { params(name: String, command: String).returns(T.nilable(String)) }
// 223:       def suggest_command(name, command); end
// 224:
// 225:       require "extend/os/missing_formula"
// 226:     end
// 227:   end
// 228: end
