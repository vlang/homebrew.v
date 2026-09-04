module options

// Translated from Homebrew/brew `options/options.rb`.

// Options is an insertion-ordered set of formula options. Ruby's Set preserves
// the first equal object added, so equality and duplicate detection use only an
// option's name while retaining the first option's description.
pub struct Options {
mut:
	items  []FormulaOption
	frozen bool
}

// new_options translates Options.new(options = nil).
pub fn new_options(initial ...FormulaOption) Options {
	mut options := Options{}
	for option in initial {
		options.add(option)
	}
	return options
}

// create translates Options.create(array), including Homebrew's extraction of
// the option name from flags such as --feature and --prefix=/path.
pub fn create(arguments []string) Options {
	mut options := Options{}
	for argument in arguments {
		options.add(new_option(option_name_from_argument(argument)))
	}
	return options
}

fn option_name_from_argument(argument string) string {
	if !argument.starts_with('--') || argument.len <= 2 {
		return argument
	}
	name_and_value := argument[2..]
	if name_and_value.starts_with('=') {
		return argument
	}
	if equals_index := name_and_value.index('=') {
		return name_and_value[..equals_index + 1]
	}
	return name_and_value
}

// duplicate translates initialize_dup by copying the backing collection and
// returning an unfrozen Options value.
pub fn (options Options) duplicate() Options {
	return Options{
		items: options.items.clone()
	}
}

// freeze translates Options#freeze. Ruby freezes the Options wrapper but not its
// backing Set, so << remains usable after this call; the flag records the wrapper
// state without changing that source behavior.
pub fn (mut options Options) freeze() {
	options.frozen = true
}

pub fn (options Options) is_frozen() bool {
	return options.frozen
}

// each translates Options#each.
pub fn (options Options) each(block fn (FormulaOption)) {
	for option in options.items {
		block(option)
	}
}

// add translates Options#<<.
pub fn (mut options Options) add(other FormulaOption) {
	if !options.contains_option(other) {
		options.items << other
	}
}

// plus translates Options#+.
pub fn (options Options) plus(other Options) Options {
	mut result := options.duplicate()
	for option in other.items {
		result.add(option)
	}
	return result
}

// minus translates Options#-.
pub fn (options Options) minus(other Options) Options {
	mut result := Options{}
	for option in options.items {
		if !other.contains_option(option) {
			result.add(option)
		}
	}
	return result
}

// intersection translates Options#&.
pub fn (options Options) intersection(other Options) Options {
	mut result := Options{}
	for option in options.items {
		if other.contains_option(option) {
			result.add(option)
		}
	}
	return result
}

// union translates Options#|.
pub fn (options Options) union(other Options) Options {
	return options.plus(other)
}

// join translates Options#* with a String argument.
pub fn (options Options) join(separator string) string {
	return options.as_flags().join(separator)
}

// equal translates Options#== and Options#eql?. Like the Ruby implementation,
// it compares the insertion-ordered arrays rather than Set equality.
pub fn (options Options) equal(other Options) bool {
	if options.items.len != other.items.len {
		return false
	}
	for index, option in options.items {
		if !option.equal(other.items[index]) {
			return false
		}
	}
	return true
}

pub fn (options Options) empty() bool {
	return options.items.len == 0
}

pub fn (options Options) len() int {
	return options.items.len
}

// as_flags translates Options#as_flags.
pub fn (options Options) as_flags() []string {
	return options.items.map(it.flag)
}

// contains translates the String branch of Options#include?.
pub fn (options Options) contains(value string) bool {
	return options.items.any(it.name == value || it.flag == value)
}

// contains_option translates the FormulaOption branch of Options#include?.
pub fn (options Options) contains_option(value FormulaOption) bool {
	return options.items.any(it.equal(value))
}

// to_array translates Enumerable#to_a and the to_ary alias.
pub fn (options Options) to_array() []FormulaOption {
	return options.items.clone()
}

// str translates Options#to_s.
pub fn (options Options) str() string {
	return options.as_flags().join(' ')
}

// inspect translates Options#inspect.
pub fn (options Options) inspect() string {
	return '#<Options: [${options.items.map(it.inspect()).join(', ')}]>'
}

// FormulaOptionProvider is the typed V counterpart of the Formula properties
// consumed by Options.dump_for_formula.
pub interface FormulaOptionProvider {
	formula_options() Options
	formula_has_head() bool
}

// format_for_formula contains the output behavior of Options.dump_for_formula.
pub fn format_for_formula(options Options, has_head bool) string {
	mut sorted_options := options.to_array()
	sorted_options.sort(a.flag < b.flag)
	mut lines := []string{}
	for option in sorted_options {
		lines << option.flag
		lines << '\t${option.description}'
	}
	if has_head {
		lines << '--HEAD'
		lines << '\tInstall HEAD version'
	}
	if lines.len == 0 {
		return ''
	}
	return lines.join('\n') + '\n'
}

// dump_for_formula translates Options.dump_for_formula(formula).
pub fn dump_for_formula(formula FormulaOptionProvider) {
	print(format_for_formula(formula.formula_options(), formula.formula_has_head()))
}
