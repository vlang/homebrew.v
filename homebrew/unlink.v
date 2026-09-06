module homebrew

import os

// Translated from Homebrew/brew `unlink.rb`.
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

pub type UnlinkKegAction = fn (UnlinkKeg, UnlinkOptions) !int

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
