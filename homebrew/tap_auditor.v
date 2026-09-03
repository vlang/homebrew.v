module homebrew

import homebrew.extend
import os
import x.json2

// Translated from Homebrew/brew `tap_auditor.rb`.
// The original source is retained below until every stub has a typed V body.
const tap_auditor_json_patterns = [
	'formula_renames.json',
	'cask_renames.json',
	'tap_migrations.json',
	'synced_versions_formulae.json',
	'disabled_new_usr_local_relocation_formulae.json',
	'audit_exceptions/*.json',
	'style_exceptions/*.json',
]

pub struct TapAuditorFormulaList {
pub:
	items            []string
	valid_collection bool = true
}

pub fn tap_auditor_array_list(items []string) TapAuditorFormulaList {
	return TapAuditorFormulaList{
		items: items.clone()
	}
}

pub fn tap_auditor_hash_list(keys []string) TapAuditorFormulaList {
	return TapAuditorFormulaList{
		items: keys.clone()
	}
}

pub fn tap_auditor_invalid_list() TapAuditorFormulaList {
	return TapAuditorFormulaList{
		valid_collection: false
	}
}

pub struct TapAuditorTap {
pub:
	name                                       string
	path                                       string
	audit_exceptions                           map[string]TapAuditorFormulaList
	style_exceptions                           map[string]TapAuditorFormulaList
	synced_versions_formulae                   [][]string
	disabled_new_usr_local_relocation_formulae []string
	autobump                                   []string
	official                                   bool
	formula_renames                            map[string]string
	cask_renames                               map[string]string
	cask_tokens                                []string
	aliases                                    []string
	formula_names                              []string
}

pub struct TapAuditProblem {
pub:
	message   string
	location  ?string
	corrected bool
}

pub struct TapAuditor {
pub:
	name                                           string
	path                                           string
	formula_names                                  []string
	formula_aliases                                []string
	formula_renames                                map[string]string
	cask_tokens                                    []string
	cask_renames                                   map[string]string
	tap_audit_exceptions                           map[string]TapAuditorFormulaList
	tap_style_exceptions                           map[string]TapAuditorFormulaList
	tap_synced_versions_formulae                   [][]string
	tap_disabled_new_usr_local_relocation_formulae []string
	tap_autobump                                   []string
	tap_official                                   bool
pub mut:
	problems []TapAuditProblem
}

pub fn new_tap_auditor(tap TapAuditorTap, strict ?bool) TapAuditor {
	_ = strict
	return TapAuditor{
		name: tap.name
		path: tap.path
		formula_names: tap.formula_names.map(name_from_full_name(it))
		formula_aliases: tap.aliases.map(name_from_full_name(it))
		formula_renames: tap.formula_renames.clone()
		cask_tokens: tap.cask_tokens.map(name_from_full_name(it))
		cask_renames: tap.cask_renames.clone()
		tap_audit_exceptions: tap.audit_exceptions.clone()
		tap_style_exceptions: tap.style_exceptions.clone()
		tap_synced_versions_formulae: tap.synced_versions_formulae.clone()
		tap_disabled_new_usr_local_relocation_formulae: tap.disabled_new_usr_local_relocation_formulae.clone()
		tap_autobump: tap.autobump.clone()
		tap_official: tap.official
	}
}

pub fn (mut auditor TapAuditor) audit() {
	auditor.audit_json_files()
	auditor.audit_tap_formula_lists()
	auditor.audit_aliases_renames_duplicates()
}

pub fn (mut auditor TapAuditor) audit_json_files() {
	for pattern in tap_auditor_json_patterns {
		full_pattern := os.join_path(auditor.path, pattern)
		mut files := if pattern.contains('*') {
			os.glob(full_pattern) or { []string{} }
		} else if os.is_file(full_pattern) {
			[full_pattern]
		} else {
			[]string{}
		}
		files.sort()
		for file in files {
			contents := os.read_file(file) or { panic(err) }
			json2.decode[json2.Any](contents) or {
				prefix := auditor.path.trim_right(os.path_separator) + os.path_separator
				relative := if file.starts_with(prefix) { file[prefix.len..] } else { file }
				auditor.problem('${relative} contains invalid JSON')
			}
		}
	}
}

pub fn (mut auditor TapAuditor) audit_tap_formula_lists() {
	auditor.check_formula_list_directory('audit_exceptions', auditor.tap_audit_exceptions)
	auditor.check_formula_list_directory('style_exceptions', auditor.tap_style_exceptions)
	auditor.check_renames('formula_renames.json', auditor.formula_renames, auditor.formula_names, auditor.formula_aliases)
	auditor.check_renames('cask_renames.json', auditor.cask_renames, auditor.cask_tokens, []string{})
	if !auditor.tap_official {
		auditor.check_formula_list('.github/autobump.txt', tap_auditor_array_list(auditor.tap_autobump))
	}
	mut synced := []string{}
	for formulae in auditor.tap_synced_versions_formulae {
		synced << formulae
	}
	auditor.check_formula_list('synced_versions_formulae', tap_auditor_array_list(synced))
	auditor.check_formula_list('disabled_new_usr_local_relocation_formulae.json', tap_auditor_array_list(auditor.tap_disabled_new_usr_local_relocation_formulae))
}

pub fn (mut auditor TapAuditor) audit_aliases_renames_duplicates() {
	mut duplicates := []string{}
	for formula_alias in auditor.formula_aliases {
		if formula_alias in auditor.formula_renames {
			duplicates << formula_alias
		}
	}
	if duplicates.len == 0 {
		return
	}
	auditor.problem('The following should either be an alias or a rename, not both: ${extend.array_to_sentence(duplicates, ', ', ' and ', ' and ')}')
}

pub fn (mut auditor TapAuditor) problem(message string) {
	auditor.problems << TapAuditProblem{
		message: message
		location: none
		corrected: false
	}
}

pub fn (mut auditor TapAuditor) check_formula_list(list_file_value string,
	list TapAuditorFormulaList) {
	mut list_file := list_file_value
	if os.file_ext(list_file) == '' {
		list_file += '.json'
	}
	if !list.valid_collection {
		auditor.problem('${list_file} should contain a JSON array\nof formula names or a JSON object mapping formula names to values\n')
		return
	}
	mut invalid_formulae_casks := []string{}
	for formula_or_cask_name in list.items {
		if formula_or_cask_name !in auditor.formula_names && formula_or_cask_name !in auditor.formula_aliases && formula_or_cask_name !in auditor.cask_tokens {
			invalid_formulae_casks << formula_or_cask_name
		}
	}
	if invalid_formulae_casks.len == 0 {
		return
	}
	auditor.problem('${list_file} references\nformulae or casks that are not found in the ${auditor.name} tap.\nInvalid formulae or casks: ${invalid_formulae_casks.join(', ')}\n')
}

pub fn (mut auditor TapAuditor) check_formula_list_directory(directory_name string,
	lists map[string]TapAuditorFormulaList) {
	for list_name, list in lists {
		auditor.check_formula_list('${directory_name}/${list_name}', list)
	}
}

pub fn (mut auditor TapAuditor) check_renames(list_file string,
	renames_hash map[string]string, valid_tokens []string, valid_aliases []string) {
	item_type := if list_file.contains('cask') { 'casks' } else { 'formulae' }
	mut invalid_format_entries := []string{}
	mut invalid_targets := []string{}
	mut chained_rename_suggestions := []string{}
	mut conflicts := []string{}
	for old_name, new_name in renames_hash {
		if old_name.ends_with('.rb') || new_name.ends_with('.rb') {
			invalid_format_entries << '"${old_name}": "${new_name}"'
		}
		if new_name !in valid_tokens && new_name !in valid_aliases && new_name !in renames_hash {
			invalid_targets << new_name
		}
		if new_name in renames_hash {
			mut final_name := new_name
			mut seen := {
				old_name: true
				new_name: true
			}
			for (final_name in renames_hash) {
				next_name := renames_hash[final_name]
				if next_name in seen {
					break
				}
				final_name = next_name
				seen[final_name] = true
			}
			chained_rename_suggestions << '  "${old_name}": "${final_name}" (instead of chained rename)'
		}
		if old_name in valid_tokens {
			conflicts << old_name
		}
	}
	if invalid_format_entries.len > 0 {
		auditor.problem("${list_file} contains entries with '.rb' file extensions.\nRename entries should use formula/cask names only, without '.rb' extensions.\nInvalid entries: ${invalid_format_entries.join(', ')}\n")
	}
	if invalid_targets.len > 0 {
		auditor.problem('${list_file} contains renames to ${item_type} that do not exist in the ${auditor.name} tap.\nInvalid targets: ${invalid_targets.join(', ')}\n')
	}
	if chained_rename_suggestions.len > 0 {
		auditor.problem("${list_file} contains chained renames that should be collapsed.\nChained renames don't work automatically; each old name should point directly to the final target:\n${chained_rename_suggestions.join('\n')}\n")
	}
	if conflicts.len == 0 {
		return
	}
	auditor.problem('${list_file} contains old names that conflict with existing ${item_type} in the ${auditor.name} tap.\nRenames only work after the old ${item_type} are deleted. Conflicting names: ${conflicts.join(', ')}\n')
}

// Ruby attr_reader `attr_reader :name` at line 10.
pub fn ruby_tap_auditor_l10_d1_name(auditor TapAuditor) string {
	return auditor.name
}

// Ruby attr_reader `attr_reader :path` at line 13.
pub fn ruby_tap_auditor_l13_d2_path(auditor TapAuditor) string {
	return auditor.path
}

// Ruby attr_reader `attr_reader :formula_names` at line 16.
pub fn ruby_tap_auditor_l16_d3_formula_names(auditor TapAuditor) []string {
	return auditor.formula_names.clone()
}

// Ruby attr_reader `attr_reader :formula_aliases` at line 19.
pub fn ruby_tap_auditor_l19_d4_formula_aliases(auditor TapAuditor) []string {
	return auditor.formula_aliases.clone()
}

// Ruby attr_reader `attr_reader :formula_renames` at line 22.
pub fn ruby_tap_auditor_l22_d5_formula_renames(auditor TapAuditor) map[string]string {
	return auditor.formula_renames.clone()
}

// Ruby attr_reader `attr_reader :cask_tokens` at line 25.
pub fn ruby_tap_auditor_l25_d6_cask_tokens(auditor TapAuditor) []string {
	return auditor.cask_tokens.clone()
}

// Ruby attr_reader `attr_reader :cask_renames` at line 28.
pub fn ruby_tap_auditor_l28_d7_cask_renames(auditor TapAuditor) map[string]string {
	return auditor.cask_renames.clone()
}

// Ruby attr_reader `attr_reader :tap_audit_exceptions` at line 31.
pub fn ruby_tap_auditor_l31_d8_tap_audit_exceptions(auditor TapAuditor) map[string]TapAuditorFormulaList {
	return auditor.tap_audit_exceptions.clone()
}

// Ruby attr_reader `attr_reader :tap_style_exceptions` at line 34.
pub fn ruby_tap_auditor_l34_d9_tap_style_exceptions(auditor TapAuditor) map[string]TapAuditorFormulaList {
	return auditor.tap_style_exceptions.clone()
}

// Ruby attr_reader `attr_reader :problems` at line 37.
pub fn ruby_tap_auditor_l37_d10_problems(auditor TapAuditor) []TapAuditProblem {
	return auditor.problems.clone()
}

// Ruby method `initialize(tap, strict:)` at line 40.
pub fn ruby_tap_auditor_l40_d11_initialize(tap TapAuditorTap, strict ?bool) TapAuditor {
	return new_tap_auditor(tap, strict)
}

// Ruby method `audit` at line 76.
pub fn ruby_tap_auditor_l76_d12_audit(mut auditor TapAuditor) {
	auditor.audit()
}

// Ruby method `audit_json_files` at line 83.
pub fn ruby_tap_auditor_l83_d13_audit_json_files(mut auditor TapAuditor) {
	auditor.audit_json_files()
}

// Ruby method `audit_tap_formula_lists` at line 93.
pub fn ruby_tap_auditor_l93_d14_audit_tap_formula_lists(mut auditor TapAuditor) {
	auditor.audit_tap_formula_lists()
}

// Ruby method `audit_aliases_renames_duplicates` at line 105.
pub fn ruby_tap_auditor_l105_d15_audit_aliases_renames_duplicates(mut auditor TapAuditor) {
	auditor.audit_aliases_renames_duplicates()
}

// Ruby method `problem(message)` at line 113.
pub fn ruby_tap_auditor_l113_d16_problem(mut auditor TapAuditor, message string) {
	auditor.problem(message)
}

// Ruby method `check_formula_list(list_file, list)` at line 120.
pub fn ruby_tap_auditor_l120_d17_check_formula_list(mut auditor TapAuditor, list_file string,
	list TapAuditorFormulaList) {
	auditor.check_formula_list(list_file, list)
}

// Ruby method `check_formula_list_directory(directory_name, lists)` at line 147.
pub fn ruby_tap_auditor_l147_d18_check_formula_list_directory(mut auditor TapAuditor,
	directory_name string, lists map[string]TapAuditorFormulaList) {
	auditor.check_formula_list_directory(directory_name, lists)
}

// Ruby method `check_renames(list_file, renames_hash, valid_tokens, valid_aliases = [])` at line 157.
pub fn ruby_tap_auditor_l157_d19_check_renames(mut auditor TapAuditor, list_file string,
	renames_hash map[string]string, valid_tokens []string, valid_aliases []string) {
	auditor.check_renames(list_file, renames_hash, valid_tokens, valid_aliases)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5:
// 6: module Homebrew
// 7:   # Auditor for checking common violations in {Tap}s.
// 8:   class TapAuditor
// 9:     sig { returns(String) }
// 10:     attr_reader :name
// 11:
// 12:     sig { returns(Pathname) }
// 13:     attr_reader :path
// 14:
// 15:     sig { returns(T::Array[String]) }
// 16:     attr_reader :formula_names
// 17:
// 18:     sig { returns(T::Array[String]) }
// 19:     attr_reader :formula_aliases
// 20:
// 21:     sig { returns(T::Hash[String, String]) }
// 22:     attr_reader :formula_renames
// 23:
// 24:     sig { returns(T::Array[String]) }
// 25:     attr_reader :cask_tokens
// 26:
// 27:     sig { returns(T::Hash[String, String]) }
// 28:     attr_reader :cask_renames
// 29:
// 30:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 31:     attr_reader :tap_audit_exceptions
// 32:
// 33:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 34:     attr_reader :tap_style_exceptions
// 35:
// 36:     sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
// 37:     attr_reader :problems
// 38:
// 39:     sig { params(tap: Tap, strict: T.nilable(T::Boolean)).void }
// 40:     def initialize(tap, strict:)
// 41:       @name                                           = T.let(tap.name, String)
// 42:       @path                                           = T.let(tap.path, Pathname)
// 43:       @tap_audit_exceptions                           = T.let(tap.audit_exceptions, T::Hash[Symbol, T.untyped])
// 44:       @tap_style_exceptions                           = T.let(tap.style_exceptions, T::Hash[Symbol, T.untyped])
// 45:       @tap_synced_versions_formulae                   = T.let(tap.synced_versions_formulae,
// 46:                                                               T::Array[T::Array[String]])
// 47:       @tap_disabled_new_usr_local_relocation_formulae = T.let(tap.disabled_new_usr_local_relocation_formulae,
// 48:                                                               T::Array[String])
// 49:       @tap_autobump                                   = T.let(tap.autobump, T::Array[String])
// 50:       @tap_official                                   = T.let(tap.official?, T::Boolean)
// 51:       @problems                                       = T.let([], T::Array[T::Hash[Symbol, T.untyped]])
// 52:       @cask_tokens                                    = T.let([], T::Array[String])
// 53:       @formula_aliases                                = T.let([], T::Array[String])
// 54:       @formula_renames                                = T.let({}, T::Hash[String, String])
// 55:       @cask_renames                                   = T.let({}, T::Hash[String, String])
// 56:       @formula_names                                  = T.let([], T::Array[String])
// 57:
// 58:       Homebrew.with_no_api_env do
// 59:         tap.clear_cache if Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 60:
// 61:         @formula_renames = tap.formula_renames
// 62:         @cask_renames    = tap.cask_renames
// 63:         @cask_tokens = tap.cask_tokens.map do |cask_token|
// 64:           Utils.name_from_full_name(cask_token)
// 65:         end
// 66:         @formula_aliases = tap.aliases.map do |formula_alias|
// 67:           Utils.name_from_full_name(formula_alias)
// 68:         end
// 69:         @formula_names = tap.formula_names.map do |formula_name|
// 70:           Utils.name_from_full_name(formula_name)
// 71:         end
// 72:       end
// 73:     end
// 74:
// 75:     sig { void }
// 76:     def audit
// 77:       audit_json_files
// 78:       audit_tap_formula_lists
// 79:       audit_aliases_renames_duplicates
// 80:     end
// 81:
// 82:     sig { void }
// 83:     def audit_json_files
// 84:       json_patterns = Tap::HOMEBREW_TAP_JSON_FILES.map { |pattern| @path/pattern }
// 85:       Pathname.glob(json_patterns).each do |file|
// 86:         JSON.parse file.read
// 87:       rescue JSON::ParserError
// 88:         problem "#{file.to_s.delete_prefix("#{@path}/")} contains invalid JSON"
// 89:       end
// 90:     end
// 91:
// 92:     sig { void }
// 93:     def audit_tap_formula_lists
// 94:       check_formula_list_directory "audit_exceptions", @tap_audit_exceptions
// 95:       check_formula_list_directory "style_exceptions", @tap_style_exceptions
// 96:       check_renames "formula_renames.json", @formula_renames, @formula_names, @formula_aliases
// 97:       check_renames "cask_renames.json", @cask_renames, @cask_tokens
// 98:       check_formula_list ".github/autobump.txt", @tap_autobump unless @tap_official
// 99:       check_formula_list "synced_versions_formulae", @tap_synced_versions_formulae.flatten
// 100:       check_formula_list "disabled_new_usr_local_relocation_formulae.json",
// 101:                          @tap_disabled_new_usr_local_relocation_formulae
// 102:     end
// 103:
// 104:     sig { void }
// 105:     def audit_aliases_renames_duplicates
// 106:       duplicates = formula_aliases & formula_renames.keys
// 107:       return if duplicates.none?
// 108:
// 109:       problem "The following should either be an alias or a rename, not both: #{duplicates.to_sentence}"
// 110:     end
// 111:
// 112:     sig { params(message: String).void }
// 113:     def problem(message)
// 114:       @problems << { message:, location: nil, corrected: false }
// 115:     end
// 116:
// 117:     private
// 118:
// 119:     sig { params(list_file: String, list: T.untyped).void }
// 120:     def check_formula_list(list_file, list)
// 121:       list_file += ".json" if File.extname(list_file).empty?
// 122:       unless [Hash, Array].include? list.class
// 123:         problem <<~EOS
// 124:           #{list_file} should contain a JSON array
// 125:           of formula names or a JSON object mapping formula names to values
// 126:         EOS
// 127:         return
// 128:       end
// 129:
// 130:       list = list.keys if list.is_a? Hash
// 131:       invalid_formulae_casks = list.select do |formula_or_cask_name|
// 132:         formula_names.exclude?(formula_or_cask_name) &&
// 133:           formula_aliases.exclude?(formula_or_cask_name) &&
// 134:           cask_tokens.exclude?(formula_or_cask_name)
// 135:       end
// 136:
// 137:       return if invalid_formulae_casks.empty?
// 138:
// 139:       problem <<~EOS
// 140:         #{list_file} references
// 141:         formulae or casks that are not found in the #{@name} tap.
// 142:         Invalid formulae or casks: #{invalid_formulae_casks.join(", ")}
// 143:       EOS
// 144:     end
// 145:
// 146:     sig { params(directory_name: String, lists: T::Hash[Symbol, T.untyped]).void }
// 147:     def check_formula_list_directory(directory_name, lists)
// 148:       lists.each do |list_name, list|
// 149:         check_formula_list "#{directory_name}/#{list_name}", list
// 150:       end
// 151:     end
// 152:
// 153:     sig {
// 154:       params(list_file: String, renames_hash: T::Hash[String, String], valid_tokens: T::Array[String],
// 155:              valid_aliases: T::Array[String]).void
// 156:     }
// 157:     def check_renames(list_file, renames_hash, valid_tokens, valid_aliases = [])
// 158:       item_type = list_file.include?("cask") ? "casks" : "formulae"
// 159:
// 160:       # Collect all validation issues in a single pass
// 161:       invalid_format_entries = []
// 162:       invalid_targets = []
// 163:       chained_rename_suggestions = []
// 164:       conflicts = []
// 165:
// 166:       renames_hash.each do |old_name, new_name|
// 167:         # Check for .rb extensions
// 168:         if old_name.end_with?(".rb") || new_name.end_with?(".rb")
// 169:           invalid_format_entries << "\"#{old_name}\": \"#{new_name}\""
// 170:         end
// 171:
// 172:         # Check that new name exists
// 173:         if valid_tokens.exclude?(new_name) && valid_aliases.exclude?(new_name) && !renames_hash.key?(new_name)
// 174:           invalid_targets << new_name
// 175:         end
// 176:
// 177:         # Check for chained renames and follow to final target
// 178:         if renames_hash.key?(new_name)
// 179:           final = new_name
// 180:           seen = Set.new([old_name, new_name])
// 181:           while renames_hash.key?(final)
// 182:             next_name = renames_hash[final]
// 183:             break if next_name.nil? || seen.include?(next_name)
// 184:
// 185:             final = next_name
// 186:             seen << final
// 187:           end
// 188:           chained_rename_suggestions << "  \"#{old_name}\": \"#{final}\" (instead of chained rename)"
// 189:         end
// 190:
// 191:         # Check for conflicts
// 192:         conflicts << old_name if valid_tokens.include?(old_name)
// 193:       end
// 194:
// 195:       if invalid_format_entries.any?
// 196:         problem <<~EOS
// 197:           #{list_file} contains entries with '.rb' file extensions.
// 198:           Rename entries should use formula/cask names only, without '.rb' extensions.
// 199:           Invalid entries: #{invalid_format_entries.join(", ")}
// 200:         EOS
// 201:       end
// 202:
// 203:       if invalid_targets.any?
// 204:         problem <<~EOS
// 205:           #{list_file} contains renames to #{item_type} that do not exist in the #{@name} tap.
// 206:           Invalid targets: #{invalid_targets.join(", ")}
// 207:         EOS
// 208:       end
// 209:
// 210:       if chained_rename_suggestions.any?
// 211:         problem <<~EOS
// 212:           #{list_file} contains chained renames that should be collapsed.
// 213:           Chained renames don't work automatically; each old name should point directly to the final target:
// 214:           #{chained_rename_suggestions.join("\n")}
// 215:         EOS
// 216:       end
// 217:
// 218:       return if conflicts.none?
// 219:
// 220:       problem <<~EOS
// 221:         #{list_file} contains old names that conflict with existing #{item_type} in the #{@name} tap.
// 222:         Renames only work after the old #{item_type} are deleted. Conflicting names: #{conflicts.join(", ")}
// 223:       EOS
// 224:     end
// 225:   end
// 226: end
