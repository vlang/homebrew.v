module homebrew

// Translated from Homebrew/brew `fetch.rb`.
pub struct FetchBottleFormula {
pub:
	full_name            string
	bottle_present       bool
	pour_bottle          bool
	compatible_locations bool
	bottled_tags         []string
}

pub struct FetchBottleOptions {
pub:
	force_bottle               bool
	bottle_tag                 string
	build_from_source_formulae []string
	os                         string
	arch                       string
	test_generic_os            bool
}

pub fn fetch_bottle(formula FetchBottleFormula, options FetchBottleOptions) bool {
	if options.force_bottle && formula.bottle_present {
		return true
	}
	if options.os != '' {
		return true
	}
	if options.test_generic_os {
		return false
	}
	if options.arch != '' {
		return true
	}
	if options.bottle_tag != '' && options.bottle_tag in formula.bottled_tags {
		return true
	}
	return formula.bottle_present && formula.pour_bottle && formula.full_name !in options.build_from_source_formulae && formula.compatible_locations
}
