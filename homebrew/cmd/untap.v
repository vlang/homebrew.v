module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/untap.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct UntapTap {
pub:
	name          string
	core_tap      bool
	core_cask_tap bool
	formula_names []string
	cask_tokens   []string
}

pub struct UntapKeg {
pub:
	rack string
	tap  string
}

pub struct UntapFormula {
pub:
	name                    string
	full_name               string
	available               bool = true
	valid                   bool = true
	installed_kegs          []UntapKeg
	remains_after_uninstall bool
}

pub struct UntapCask {
pub:
	token                   string
	full_name               string
	available               bool = true
	deprecated              bool
	installed               bool
	remains_after_uninstall bool
	uninstall_error         ?string
}

pub struct UntapCommandInput {
pub:
	named                    []string
	taps                     []UntapTap
	formulae                 []UntapFormula
	casks                    []UntapCask
	installed_formula_names  []string
	installed_cask_tokens    []string
	force                    bool
	no_install_from_api      bool
	developer                bool
	confirmations            map[string]bool
	confirmation_exits       []string
	dependent_check_failures []string
	keg_uninstall_failures   []string
}

pub struct UntapCommandResult {
pub:
	stdout               string
	stderr               string
	failed               bool
	untapped             []string
	uninstalled_formulae []string
	uninstalled_casks    []string
	kegs_by_rack         map[string][]string
	actions              []string
}

pub struct UntapFormulaQuery {
pub:
	tap                     UntapTap
	formulae                []UntapFormula
	installed_formula_names []string
}

pub struct UntapCaskQuery {
pub:
	tap                   UntapTap
	casks                 []UntapCask
	installed_cask_tokens []string
}

fn untap_name_from_full_name(full_name string) string {
	parts := full_name.split('/')
	return parts.last()
}

fn untap_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

fn untap_formula_full_name(formula UntapFormula) string {
	return if formula.full_name != '' { formula.full_name } else { formula.name }
}

fn untap_cask_full_name(cask UntapCask) string {
	return if cask.full_name != '' { cask.full_name } else { cask.token }
}

fn untap_find_tap(taps []UntapTap, name string) ?UntapTap {
	for tap in taps {
		if tap.name == name {
			return tap
		}
	}
	return none
}

fn untap_validate_tap_name(name string) ! {
	parts := name.split('/')
	if parts.len != 2 || parts.any(it == '') {
		return error("Invalid tap name: '${name}'")
	}
}

fn untap_installed_formulae_for(tap UntapTap, formulae []UntapFormula,
	installed_formula_names []string, removed []string) []UntapFormula {
	mut result := []UntapFormula{}
	for formula_name in tap.formula_names {
		short_name := untap_name_from_full_name(formula_name)
		if short_name !in installed_formula_names || formula_name in removed {
			continue
		}
		for formula in formulae {
			full_name := untap_formula_full_name(formula)
			if full_name != formula_name || !formula.available || !formula.valid {
				continue
			}
			if formula.installed_kegs.any(it.tap == tap.name) {
				result << formula
			}
			break
		}
	}
	return result
}

// All installed formulae currently available in a tap by formula full name.
pub fn installed_formulae_for(tap UntapTap, formulae []UntapFormula,
	installed_formula_names []string) []UntapFormula {
	return untap_installed_formulae_for(tap, formulae, installed_formula_names, [])
}

fn untap_installed_casks_for(tap UntapTap, casks []UntapCask,
	installed_cask_tokens []string, removed []string) []UntapCask {
	mut result := []UntapCask{}
	for cask_token in tap.cask_tokens {
		short_token := untap_name_from_full_name(cask_token)
		if short_token !in installed_cask_tokens || cask_token in removed {
			continue
		}
		for cask in casks {
			full_name := untap_cask_full_name(cask)
			if full_name != cask_token || !cask.available || cask.deprecated {
				continue
			}
			if cask.installed {
				result << cask
			}
			break
		}
	}
	return result
}

// All installed casks currently available in a tap by cask full name.
pub fn installed_casks_for(tap UntapTap, casks []UntapCask,
	installed_cask_tokens []string) []UntapCask {
	return untap_installed_casks_for(tap, casks, installed_cask_tokens, [])
}

fn untap_append_error(mut stderr []string, message string) {
	stderr << 'Error: ${message}'
}

pub fn run_untap_command(input UntapCommandInput) !UntapCommandResult {
	if input.named.len == 0 {
		return error('This command requires at least 1 tap argument.')
	}
	mut selected_taps := []UntapTap{}
	for name in input.named {
		untap_validate_tap_name(name)!
		if tap := untap_find_tap(input.taps, name) {
			selected_taps << tap
		} else {
			return error('No available tap ${name}.')
		}
	}
	mut stdout := []string{}
	mut stderr := []string{}
	mut failed := false
	mut untapped := []string{}
	mut removed_formulae := []string{}
	mut removed_casks := []string{}
	mut kegs_by_rack := map[string][]string{}
	mut actions := []string{}
	for tap in selected_taps {
		if tap.core_tap && input.no_install_from_api {
			untap_append_error(mut stderr, 'Untapping ${tap.name} is not allowed')
			failed = true
			continue
		}
		if input.no_install_from_api || (!tap.core_tap && !tap.core_cask_tap) {
			installed_formulae := untap_installed_formulae_for(tap, input.formulae, input.installed_formula_names, removed_formulae)
			installed_casks := untap_installed_casks_for(tap, input.casks, input.installed_cask_tokens, removed_casks)
			if installed_formulae.len > 0 || installed_casks.len > 0 {
				formula_names := installed_formulae.map(untap_formula_full_name(it))
				cask_names := installed_casks.map(untap_cask_full_name(it))
				package_types := if formula_names.len == 0 {
					'casks'
				} else if cask_names.len == 0 {
					'formulae'
				} else {
					'formulae and casks'
				}
				mut installed_names := formula_names.clone()
				installed_names << cask_names
				if input.developer && !input.force {
					stderr << 'Warning: Untapping ${tap.name} even though it contains the following installed ${package_types}:\n${installed_names.join('\n')}'
				} else {
					if !input.force {
						stdout << '==> Would untap ${tap.name} after uninstalling the following ${package_types}:\n${installed_names.join('\n')}'
						confirmed := tap.name !in input.confirmation_exits && (input.confirmations[tap.name] or {
							false
						})
						if !confirmed {
							untap_append_error(mut stderr, 'Refusing to untap ${tap.name} because it contains the following installed ${package_types}:\n${installed_names.join('\n')}')
							failed = true
							continue
						}
					}
					actions << 'check_dependent_casks:${tap.name}:${installed_names.join(',')}'
					if tap.name in input.dependent_check_failures {
						failed = true
						continue
					}
					for formula in installed_formulae {
						full_name := untap_formula_full_name(formula)
						for keg in formula.installed_kegs {
							if keg.tap == tap.name {
								kegs_by_rack[keg.rack] << full_name
							}
						}
					}
					actions << 'uninstall_kegs:${tap.name}:force=${input.force}'
					if tap.name in input.keg_uninstall_failures {
						failed = true
						continue
					}
					for cask in installed_casks {
						full_name := untap_cask_full_name(cask)
						actions << 'uninstall_cask:${full_name}:force=${input.force}'
						if message := cask.uninstall_error {
							untap_append_error(mut stderr, message)
							failed = true
							break
						}
					}
					if failed {
						continue
					}
					for formula in installed_formulae {
						if !formula.remains_after_uninstall {
							removed_formulae << untap_formula_full_name(formula)
						}
					}
					for cask in installed_casks {
						if !cask.remains_after_uninstall {
							removed_casks << untap_cask_full_name(cask)
						}
					}
					remaining_formulae := untap_installed_formulae_for(tap, input.formulae, input.installed_formula_names, removed_formulae)
					remaining_casks := untap_installed_casks_for(tap, input.casks, input.installed_cask_tokens, removed_casks)
					if remaining_formulae.len > 0 || remaining_casks.len > 0 {
						untap_append_error(mut stderr, 'Failed to fully uninstall ${package_types} from ${tap.name}')
						failed = true
						continue
					}
				}
			}
		}
		actions << 'uninstall_tap:${tap.name}:manual=true'
		untapped << tap.name
	}
	return UntapCommandResult{
		stdout: if stdout.len > 0 { '${stdout.join('\n')}\n' } else { '' }
		stderr: if stderr.len > 0 { '${stderr.join('\n')}\n' } else { '' }
		failed: failed
		untapped: untapped
		uninstalled_formulae: untap_unique(removed_formulae)
		uninstalled_casks: untap_unique(removed_casks)
		kegs_by_rack: kegs_by_rack
		actions: actions
	}
}

pub fn untap_command_input_boundary(input &UntapCommandInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::Untap::Input', '', {
		'untap_command_input_address': u64(voidptr(input)).str()
	})
}

fn untap_command_input_from_value(value brew_runtime.Value) &UntapCommandInput {
	address := value.attributes['untap_command_input_address'] or { panic('invalid Untap command input') }
	return unsafe { &UntapCommandInput(voidptr(address.u64())) }
}

pub fn untap_formula_query_boundary(query &UntapFormulaQuery) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::Untap::FormulaQuery', '', {
		'untap_formula_query_address': u64(voidptr(query)).str()
	})
}

fn untap_formula_query_from_value(value brew_runtime.Value) &UntapFormulaQuery {
	address := value.attributes['untap_formula_query_address'] or { panic('invalid Untap formula query') }
	return unsafe { &UntapFormulaQuery(voidptr(address.u64())) }
}

pub fn untap_cask_query_boundary(query &UntapCaskQuery) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Cmd::Untap::CaskQuery', '', {
		'untap_cask_query_address': u64(voidptr(query)).str()
	})
}

fn untap_cask_query_from_value(value brew_runtime.Value) &UntapCaskQuery {
	address := value.attributes['untap_cask_query_address'] or { panic('invalid Untap cask query') }
	return unsafe { &UntapCaskQuery(voidptr(address.u64())) }
}

fn untap_formula_value(formula UntapFormula) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', untap_formula_full_name(formula), {
		'name':      formula.name
		'full_name': untap_formula_full_name(formula)
	})
}

fn untap_cask_value(cask UntapCask) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Cask', untap_cask_full_name(cask), {
		'token':     cask.token
		'full_name': untap_cask_full_name(cask)
	})
}

fn untap_result_value(result UntapCommandResult) brew_runtime.Value {
	mut racks := map[string]brew_runtime.Value{}
	for rack, formulae in result.kegs_by_rack {
		racks[rack] = brew_runtime.string_array_value(formulae)
	}
	return brew_runtime.Value{
		type_name: 'UntapCommandResult'
		repr: result.stdout
		bool_data: result.failed
		map_data: {
			'stdout':               brew_runtime.string_value(result.stdout)
			'stderr':               brew_runtime.string_value(result.stderr)
			'failed':               brew_runtime.bool_value(result.failed)
			'untapped':             brew_runtime.string_array_value(result.untapped)
			'uninstalled_formulae': brew_runtime.string_array_value(result.uninstalled_formulae)
			'uninstalled_casks':    brew_runtime.string_array_value(result.uninstalled_casks)
			'kegs_by_rack':         brew_runtime.map_value(racks)
			'actions':              brew_runtime.string_array_value(result.actions)
		}
	}
}

// Ruby method `run` at line 25.
pub fn ruby_untap_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := untap_command_input_from_value(args[0])
	result := run_untap_command(input) or {
		return brew_runtime.object_value(if err.msg().starts_with('Invalid tap name') {
			'Tap::InvalidNameError'
		} else {
			'UsageError'
		}, err.msg())
	}
	return untap_result_value(result)
}

// Ruby method `installed_formulae_for(tap:)` at line 108.
pub fn ruby_untap_l108_d2_installed_formulae_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'formula query is required')
	}
	query := untap_formula_query_from_value(args[0])
	return brew_runtime.array_value(installed_formulae_for(query.tap, query.formulae, query.installed_formula_names).map(untap_formula_value(it)))
}

// Ruby method `installed_casks_for(tap:)` at line 127.
pub fn ruby_untap_l127_d3_installed_casks_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'cask query is required')
	}
	query := untap_cask_query_from_value(args[0])
	return brew_runtime.array_value(installed_casks_for(query.tap, query.casks, query.installed_cask_tokens).map(untap_cask_value(it)))
}

// Ruby method `installed_formulae_names` at line 145.
pub fn ruby_untap_l145_d4_installed_formulae_names(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(untap_unique(args[0].as_string_array() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}))
}

// Ruby method `installed_cask_tokens` at line 150.
pub fn ruby_untap_l150_d5_installed_cask_tokens(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(untap_unique(args[0].as_string_array() or {
		return brew_runtime.object_value('TypeError', err.msg())
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "English"
// 5: require "abstract_command"
// 6: require "ask"
// 7: require "cask/uninstall"
// 8: require "uninstall"
// 9: require "utils"
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class Untap < AbstractCommand
// 14:       cmd_args do
// 15:         description <<~EOS
// 16:           Remove a tapped formula repository.
// 17:         EOS
// 18:         switch "-f", "--force",
// 19:                description: "Uninstall all formulae and casks from this tap with `--force` before untapping."
// 20:
// 21:         named_args :tap, min: 1
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         taps = begin
// 27:           args.named.to_installed_taps
// 28:         rescue Tap::InvalidNameError => e
// 29:           odie e.message
// 30:         end
// 31:
// 32:         taps.each do |tap|
// 33:           if tap.core_tap? && Homebrew::EnvConfig.no_install_from_api?
// 34:             ofail "Untapping #{tap} is not allowed"
// 35:             next
// 36:           end
// 37:
// 38:           if Homebrew::EnvConfig.no_install_from_api? || (!tap.core_tap? && !tap.core_cask_tap?)
// 39:             installed_tap_formulae = installed_formulae_for(tap:)
// 40:             installed_tap_casks = installed_casks_for(tap:)
// 41:
// 42:             if installed_tap_formulae.present? || installed_tap_casks.present?
// 43:               installed_formulae_names = installed_tap_formulae.map(&:full_name)
// 44:               installed_cask_names = installed_tap_casks.map(&:full_name)
// 45:               installed_package_types = if installed_formulae_names.empty?
// 46:                 "casks"
// 47:               elsif installed_cask_names.empty?
// 48:                 "formulae"
// 49:               else
// 50:                 "formulae and casks"
// 51:               end
// 52:               installed_names = (installed_formulae_names + installed_cask_names).join("\n")
// 53:               if Homebrew::EnvConfig.developer? && !args.force?
// 54:                 opoo <<~EOS
// 55:                   Untapping #{tap} even though it contains the following installed #{installed_package_types}:
// 56:                   #{installed_names}
// 57:                 EOS
// 58:               else
// 59:                 unless args.force?
// 60:                   ohai "Would untap #{tap} after uninstalling the following #{installed_package_types}:"
// 61:                   puts installed_names
// 62:                   confirmed = begin
// 63:                     Homebrew::Ask.confirm?(action: "changes")
// 64:                   rescue SystemExit
// 65:                     false
// 66:                   end
// 67:                   unless confirmed
// 68:                     ofail <<~EOS
// 69:                       Refusing to untap #{tap} because it contains the following installed #{installed_package_types}:
// 70:                       #{installed_names}
// 71:                     EOS
// 72:                     next
// 73:                   end
// 74:                 end
// 75:
// 76:                 named_args = installed_formulae_names + installed_cask_names
// 77:                 kegs_by_rack = installed_tap_formulae.flat_map do |formula|
// 78:                   formula.installed_kegs.select { |keg| keg.tab.tap == tap }
// 79:                 end.group_by(&:rack)
// 80:
// 81:                 Cask::Uninstall.check_dependent_casks(*installed_tap_casks, named_args:)
// 82:                 next if Homebrew.failed?
// 83:
// 84:                 Uninstall.uninstall_kegs(kegs_by_rack, casks: installed_tap_casks, force: args.force?, named_args:)
// 85:                 next if Homebrew.failed?
// 86:
// 87:                 begin
// 88:                   Cask::Uninstall.uninstall_casks(*installed_tap_casks, force: args.force?)
// 89:                 rescue
// 90:                   ofail $ERROR_INFO
// 91:                   next
// 92:                 end
// 93:
// 94:                 if installed_formulae_for(tap:).present? || installed_casks_for(tap:).present?
// 95:                   ofail "Failed to fully uninstall #{installed_package_types} from #{tap}"
// 96:                   next
// 97:                 end
// 98:               end
// 99:             end
// 100:           end
// 101:
// 102:           tap.uninstall manual: true
// 103:         end
// 104:       end
// 105:
// 106:       # All installed formulae currently available in a tap by formula full name.
// 107:       sig { params(tap: Tap).returns(T::Array[Formula]) }
// 108:       def installed_formulae_for(tap:)
// 109:         tap.formula_names.filter_map do |formula_name|
// 110:           next unless installed_formulae_names.include?(Utils.name_from_full_name(formula_name))
// 111:
// 112:           formula = begin
// 113:             Formulary.factory(formula_name)
// 114:           rescue FormulaUnavailableError, FormulaSpecificationError
// 115:             # Don't blow up because of a single unavailable or invalid formula.
// 116:             next
// 117:           end
// 118:
// 119:           # Can't use Formula#any_version_installed? because it doesn't consider
// 120:           # taps correctly.
// 121:           formula if formula.installed_kegs.any? { |keg| keg.tab.tap == tap }
// 122:         end
// 123:       end
// 124:
// 125:       # All installed casks currently available in a tap by cask full name.
// 126:       sig { params(tap: Tap).returns(T::Array[Cask::Cask]) }
// 127:       def installed_casks_for(tap:)
// 128:         tap.cask_tokens.filter_map do |cask_token|
// 129:           next unless installed_cask_tokens.include?(Utils.name_from_full_name(cask_token))
// 130:
// 131:           cask = begin
// 132:             Cask::CaskLoader.load(cask_token)
// 133:           rescue Cask::CaskUnavailableError, MethodDeprecatedError
// 134:             # Don't blow up because of a single unavailable cask or a deprecated method.
// 135:             next
// 136:           end
// 137:
// 138:           cask if cask.installed?
// 139:         end
// 140:       end
// 141:
// 142:       private
// 143:
// 144:       sig { returns(T::Set[String]) }
// 145:       def installed_formulae_names
// 146:         @installed_formulae_names ||= T.let(Formula.installed_formula_names.to_set.freeze, T.nilable(T::Set[String]))
// 147:       end
// 148:
// 149:       sig { returns(T::Set[String]) }
// 150:       def installed_cask_tokens
// 151:         @installed_cask_tokens ||= T.let(Cask::Caskroom.tokens.to_set.freeze, T.nilable(T::Set[String]))
// 152:       end
// 153:     end
// 154:   end
// 155: end
