module homebrew

import ruby
import os

// Translated from Homebrew/brew `unlink.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct UnlinkKeg {
pub:
	name      string
	path      string
	linked    bool
	installed bool
	directory bool
	symlinks  []string
}

pub struct LinkOverwriteFormula {
pub:
	name     string
	keg_only bool
	kegs     []UnlinkKeg
}

pub struct UnlinkFormula {
pub:
	name                    string
	keg_only                bool
	link_overwrite_formulae []LinkOverwriteFormula
}

pub struct UnlinkOptions {
pub:
	dry_run bool
	verbose bool
}

pub struct UnlinkResult {
pub:
	keg_name string
	count    int
	output   string
}

pub type UnlinkKegAction = fn(UnlinkKeg, UnlinkOptions) !int

// unlink_managed_symlinks is a small native Keg.unlink boundary. Only symlinks
// explicitly owned by the keg are removed; dry runs report them without mutation.
pub fn unlink_managed_symlinks(keg UnlinkKeg, options UnlinkOptions) !int {
	mut count := 0
	for path in keg.symlinks {
		if !os.is_link(path) {
			continue
		}
		count++
		if !options.dry_run {
			os.rm(path)!
		}
	}
	return count
}

pub fn unlink_keg(keg UnlinkKeg, options UnlinkOptions, action UnlinkKegAction) !UnlinkResult {
	count := action(keg, options)!
	mut output := 'Unlinking ${keg.path}... '
	if options.verbose {
		output += '\n'
	}
	output += '${count} symlinks removed.\n'
	return UnlinkResult{
		keg_name: keg.name
		count: count
		output: output
	}
}

pub fn unlink_link_overwrite_formulae(formula UnlinkFormula, verbose bool,
	action UnlinkKegAction) ![]UnlinkResult {
	mut results := []UnlinkResult{}
	for overwrite in formula.link_overwrite_formulae {
		if !overwrite.keg_only && !formula.keg_only {
			continue
		}
		if !overwrite.kegs.any(it.linked) {
			continue
		}
		for keg in overwrite.kegs {
			if !keg.linked || !keg.installed || !keg.directory {
				continue
			}
			results << unlink_keg(keg, UnlinkOptions{ verbose: verbose }, action)!
			break
		}
	}
	return results
}

fn unlink_keg_from_value(value ruby.Value) UnlinkKeg {
	return UnlinkKeg{
		name: value.attributes['name'] or { value.as_string() }
		path: value.attributes['path'] or { value.as_string() }
		linked: (value.attributes['linked'] or { 'true' }).bool()
		installed: (value.attributes['installed'] or { 'true' }).bool()
		directory: (value.attributes['directory'] or { 'true' }).bool()
		symlinks: (value.attributes['symlinks'] or { '' }).split('|').filter(it != '')
	}
}

fn unlink_formula_from_value(value ruby.Value) UnlinkFormula {
	mut overwrite_formulae := []LinkOverwriteFormula{}
	for overwrite in value.array_data {
		overwrite_formulae << LinkOverwriteFormula{
			name: overwrite.attributes['name'] or { overwrite.as_string() }
			keg_only: (overwrite.attributes['keg_only'] or { 'false' }).bool()
			kegs: overwrite.array_data.map(unlink_keg_from_value(it))
		}
	}
	return UnlinkFormula{
		name: value.attributes['name'] or { value.as_string() }
		keg_only: (value.attributes['keg_only'] or { 'false' }).bool()
		link_overwrite_formulae: overwrite_formulae
	}
}

fn unlink_results_value(results []UnlinkResult) ruby.Value {
	return ruby.array_value(results.map(ruby.structured_value('UnlinkResult', it.output, {
		'keg_name': it.keg_name
		'count':    it.count.str()
		'output':   it.output
	})))
}

// Ruby method `self.unlink_link_overwrite_formulae(formula, verbose: false)` at line 8.
pub fn ruby_unlink_l8_d1_self_unlink_link_overwrite_formulae(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	verbose := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	results := unlink_link_overwrite_formulae(unlink_formula_from_value(args[0]), verbose, unlink_managed_symlinks) or { return ruby.object_value('Error', err.msg()) }
	return unlink_results_value(results)
}

// Ruby method `self.unlink(keg, dry_run: false, verbose: false)` at line 20.
pub fn ruby_unlink_l20_d2_self_unlink(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Error', 'missing keg')
	}
	options := UnlinkOptions{
		dry_run: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		verbose: if args.len > 2 { args[2].as_bool() or { false } } else { false }
	}
	result := unlink_keg(unlink_keg_from_value(args[0]), options, unlink_managed_symlinks) or {
		return ruby.object_value('Error', err.msg())
	}
	return unlink_results_value([result])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # Provides helper methods for unlinking formulae and kegs with consistent output.
// 6:   module Unlink
// 7:     sig { params(formula: Formula, verbose: T::Boolean).void }
// 8:     def self.unlink_link_overwrite_formulae(formula, verbose: false)
// 9:       overwrite_formulae = formula.link_overwrite_formulae.select(&:linked?)
// 10:       overwrite_formulae.select!(&:keg_only?) unless formula.keg_only?
// 11:
// 12:       overwrite_formulae.filter_map(&:any_installed_keg)
// 13:                         .select(&:directory?)
// 14:                         .each do |keg|
// 15:         unlink(keg, verbose:)
// 16:       end
// 17:     end
// 18:
// 19:     sig { params(keg: Keg, dry_run: T::Boolean, verbose: T::Boolean).void }
// 20:     def self.unlink(keg, dry_run: false, verbose: false)
// 21:       options = { dry_run:, verbose: }
// 22:
// 23:       keg.lock do
// 24:         print "Unlinking #{keg}... "
// 25:         puts if verbose
// 26:         puts "#{keg.unlink(**options)} symlinks removed."
// 27:       end
// 28:     end
// 29:   end
// 30: end
