module api

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
