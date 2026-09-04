module api

import ruby

// Translated from Homebrew/brew `api/formula_bottle.rb`.
pub struct FormulaBottleTagChecksum {
pub:
	tag      string
	checksum string
	cellar   string = 'any'
}

pub struct FormulaBottleStruct {
pub:
	stable           bool
	bottle           bool
	stable_version   string
	revision         int
	bottle_rebuild   int
	bottle_checksums []FormulaBottleTagChecksum
}

pub struct FormulaBottle {
pub:
	name        string
	pkg_version string
	tag         string
	root_url    string
	rebuild     int
	checksum    string
	cellar      string
}

pub fn formula_bottle(name string, formula FormulaBottleStruct, bottle_tag string,
	default_domain string, custom_domain string) ?FormulaBottle {
	if !formula.stable || !formula.bottle {
		return none
	}
	checksum := formula.bottle_checksums.filter(it.tag == bottle_tag)
	if checksum.len == 0 {
		return none
	}
	version := if formula.revision > 0 {
		'${formula.stable_version}_${formula.revision}'
	} else {
		formula.stable_version
	}
	return FormulaBottle{
		name: name
		pkg_version: version
		tag: bottle_tag
		root_url: if custom_domain == '' { default_domain } else { custom_domain }
		rebuild: formula.bottle_rebuild
		checksum: checksum[0].checksum
		cellar: checksum[0].cellar
	}
}

fn formula_bottle_struct_from_value(value ruby.Value) FormulaBottleStruct {
	return FormulaBottleStruct{
		stable: (value.attributes['stable'] or { 'false' }).bool()
		bottle: (value.attributes['bottle'] or { 'false' }).bool()
		stable_version: value.attributes['stable_version'] or { '' }
		revision: (value.attributes['revision'] or { '0' }).int()
		bottle_rebuild: (value.attributes['bottle_rebuild'] or { '0' }).int()
		bottle_checksums: value.array_data.map(FormulaBottleTagChecksum{
			tag: it.attributes['tag'] or { '' }
			checksum: it.attributes['checksum'] or { it.as_string() }
			cellar: it.attributes['cellar'] or { 'any' }
		})
	}
}

// Ruby method `self.bottle(name:, formula_struct:, bottle_tag: Utils::Bottles.tag)` at line 19.
pub fn ruby_formula_bottle_l19_self_bottle(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', '')
	}
	name := args[0].as_string()
	tag := if args.len > 2 { args[2].as_string() } else { '' }
	default_domain := if args.len > 3 {
		args[3].as_string()
	} else {
		'https://ghcr.io/v2/homebrew/core'
	}
	custom_domain := if args.len > 4 { args[4].as_string() } else { '' }
	bottle := formula_bottle(name, formula_bottle_struct_from_value(args[1]), tag, default_domain, custom_domain) or { return ruby.object_value('NilClass', '') }
	return ruby.structured_value('Bottle', bottle.name, {
		'name':        bottle.name
		'pkg_version': bottle.pkg_version
		'tag':         bottle.tag
		'root_url':    bottle.root_url
		'rebuild':     bottle.rebuild.str()
		'checksum':    bottle.checksum
		'cellar':      bottle.cellar
	})
}
