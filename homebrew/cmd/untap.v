module cmd

import ruby

// Translated from Homebrew/brew `cmd/untap.rb`.

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

pub fn untap_command_input_boundary(input &UntapCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::Untap::Input', '', {
		'untap_command_input_address': u64(voidptr(input)).str()
	})
}

fn untap_command_input_from_value(value ruby.Value) &UntapCommandInput {
	address := value.attributes['untap_command_input_address'] or { panic('invalid Untap command input') }
	return unsafe { &UntapCommandInput(voidptr(address.u64())) }
}

pub fn untap_formula_query_boundary(query &UntapFormulaQuery) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::Untap::FormulaQuery', '', {
		'untap_formula_query_address': u64(voidptr(query)).str()
	})
}

fn untap_formula_query_from_value(value ruby.Value) &UntapFormulaQuery {
	address := value.attributes['untap_formula_query_address'] or { panic('invalid Untap formula query') }
	return unsafe { &UntapFormulaQuery(voidptr(address.u64())) }
}

pub fn untap_cask_query_boundary(query &UntapCaskQuery) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::Untap::CaskQuery', '', {
		'untap_cask_query_address': u64(voidptr(query)).str()
	})
}

fn untap_cask_query_from_value(value ruby.Value) &UntapCaskQuery {
	address := value.attributes['untap_cask_query_address'] or { panic('invalid Untap cask query') }
	return unsafe { &UntapCaskQuery(voidptr(address.u64())) }
}

fn untap_formula_value(formula UntapFormula) ruby.Value {
	return ruby.structured_value('Formula', untap_formula_full_name(formula), {
		'name':      formula.name
		'full_name': untap_formula_full_name(formula)
	})
}

fn untap_cask_value(cask UntapCask) ruby.Value {
	return ruby.structured_value('Cask::Cask', untap_cask_full_name(cask), {
		'token':     cask.token
		'full_name': untap_cask_full_name(cask)
	})
}

fn untap_result_value(result UntapCommandResult) ruby.Value {
	mut racks := map[string]ruby.Value{}
	for rack, formulae in result.kegs_by_rack {
		racks[rack] = ruby.string_array_value(formulae)
	}
	return ruby.Value{
		type_name: 'UntapCommandResult'
		repr: result.stdout
		bool_data: result.failed
		map_data: {
			'stdout':               ruby.string_value(result.stdout)
			'stderr':               ruby.string_value(result.stderr)
			'failed':               ruby.bool_value(result.failed)
			'untapped':             ruby.string_array_value(result.untapped)
			'uninstalled_formulae': ruby.string_array_value(result.uninstalled_formulae)
			'uninstalled_casks':    ruby.string_array_value(result.uninstalled_casks)
			'kegs_by_rack':         ruby.map_value(racks)
			'actions':              ruby.string_array_value(result.actions)
		}
	}
}
