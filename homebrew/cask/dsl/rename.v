module dsl

import ruby
import os

// Translated from Homebrew/brew `cask/dsl/rename.rb`.
pub struct CaskRename {
pub:
	from string
	to   string
}

pub fn new_cask_rename(from string, to string) CaskRename {
	return CaskRename{
		from: from
		to: to
	}
}

pub fn (rename CaskRename) perform(staged_path string) ! {
	if !os.exists(staged_path) {
		return
	}
	mut matches := if rename.from.contains('*') {
		os.glob(os.join_path(staged_path, rename.from)) or { []string{} }
	} else {
		candidate := os.join_path(staged_path, rename.from)
		if os.exists(candidate) { [candidate] } else { []string{} }
	}
	if matches.len == 0 {
		return
	}
	matches.sort()
	source := matches[0]
	target := os.join_path(staged_path, rename.to)
	os.mkdir_all(os.dir(target))!
	if os.exists(source) {
		os.mv(source, target)!
	}
}

pub fn cask_rename_value(rename CaskRename) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::Rename'
		repr: '{:from=>"${rename.from}", :to=>"${rename.to}"}'
		map_data: {
			'from': ruby.string_value(rename.from)
			'to':   ruby.string_value(rename.to)
		}
		attributes: {
			'from': rename.from
			'to':   rename.to
		}
	}
}

pub fn cask_rename_from_value(value ruby.Value) !CaskRename {
	if value.type_name != 'Cask::DSL::Rename' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::Rename, got ${value.type_name}')
	}
	return CaskRename{
		from: if raw := value.map_data['from'] {
			raw.as_string()
		} else {
			value.attributes['from'] or { '' }
		}
		to: if raw := value.map_data['to'] {
			raw.as_string()
		} else {
			value.attributes['to'] or { '' }
		}
	}
}

fn cask_rename_receiver(args []ruby.Value) ?CaskRename {
	if args.len == 0 {
		return none
	}
	return cask_rename_from_value(args[0]) or { return none }
}
