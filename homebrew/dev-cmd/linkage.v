module dev_cmd

// Translated from Homebrew/brew `dev-cmd/linkage.rb`.
pub struct LinkageCommandKeg {
pub:
	name                  string
	normal_output         []string
	reverse_output        []string
	test_output           []string
	broken                bool
	undeclared_with_links bool
}

pub struct LinkageCommandOptions {
pub:
	named_kegs     []LinkageCommandKeg
	installed_kegs []LinkageCommandKeg
	test           bool
	strict         bool
	reverse        bool
	cached         bool
}

pub struct LinkageCommandResult {
pub:
	kegs       []string
	output     []string
	mode       string
	cache_name string
	cached     bool
	failed     bool
}

@[heap]
pub struct LinkageCommandInput {
pub:
	options LinkageCommandOptions
}

pub fn run_linkage_command(options LinkageCommandOptions) LinkageCommandResult {
	kegs := if options.named_kegs.len == 0 { options.installed_kegs } else { options.named_kegs }
	mode := if options.test {
		'test'
	} else if options.reverse { 'reverse' } else { 'normal' }
	mut output := []string{}
	mut failed := false
	for keg in kegs {
		if kegs.len > 1 {
			output << 'Checking ${keg.name} linkage'
		}
		if options.test {
			output << keg.test_output
			if keg.broken || (options.strict && keg.undeclared_with_links) {
				failed = true
			}
		} else if options.reverse {
			output << keg.reverse_output
		} else {
			output << keg.normal_output
		}
	}
	return LinkageCommandResult{
		kegs: kegs.map(it.name)
		output: output
		mode: mode
		cache_name: 'linkage'
		cached: options.cached
		failed: failed
	}
}
