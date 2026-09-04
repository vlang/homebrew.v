module options

import hash.fnv1a

// FormulaOption is the typed V translation of Homebrew's Ruby Option class. Its
// identity, ordering, and hash are based only on its name.
pub struct FormulaOption {
pub:
	name        string
	description string
	flag        string
}

// new_option translates Option.new(name, description = "").
pub fn new_option(name string, description ...string) FormulaOption {
	return FormulaOption{
		name:        name
		description: if description.len == 0 { '' } else { description[0] }
		flag:        '--${name}'
	}
}

// str translates Option#to_s.
pub fn (option FormulaOption) str() string {
	return option.flag
}

// compare translates Option#<=> for another Option.
pub fn (option FormulaOption) compare(other FormulaOption) int {
	if option.name < other.name {
		return -1
	}
	if option.name > other.name {
		return 1
	}
	return 0
}

// equal translates Option#== and Option#eql?.
pub fn (option FormulaOption) equal(other FormulaOption) bool {
	return option.name == other.name
}

// hash_code translates Option#hash. The exact integer is V-runtime-specific,
// while retaining Ruby's required property that equal names have equal hashes.
pub fn (option FormulaOption) hash_code() u64 {
	return fnv1a.sum64_string(option.name)
}

// inspect translates Option#inspect.
pub fn (option FormulaOption) inspect() string {
	escaped_flag := option.flag.replace('\\', '\\\\').replace('"', '\\"')
	return '#<Option: "${escaped_flag}">'
}
