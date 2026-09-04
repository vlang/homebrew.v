module cmd

import ruby

// Translated from Homebrew/brew `cmd/--prefix.rb`.

const unbrewed_exclude_files = ['.DS_Store']

const unbrewed_exclude_paths = ['*/.keepme', '.github/*', 'bin/brew', 'completions/zsh/_brew',
	'docs/*', 'lib/gdk-pixbuf-2.0/*', 'lib/gio/*', 'lib/node_modules/*', 'lib/python[23].[0-9]/*',
	'lib/python3.[0-9][0-9]/*', 'lib/pypy/*', 'lib/pypy3/*', 'lib/ruby/gems/[12].*',
	'lib/ruby/site_ruby/[12].*', 'lib/ruby/vendor_ruby/[12].*', 'manpages/brew.1', 'share/pypy/*',
	'share/pypy3/*', 'share/info/dir', 'share/man/whatis', 'share/mime/*', 'texlive/*']

pub struct PrefixFormula {
pub:
	name              string
	opt_prefix        string
	opt_prefix_exists bool
	optlinked         bool
}

pub struct PrefixOptions {
pub:
	prefix           string
	unbrewed         bool
	installed        bool
	formulae         []PrefixFormula
	named            []string
	resolution_error string
	subdirs          []string
	cache            string
	logs             string
	repository       string
}

pub struct PrefixResult {
pub:
	stdout       string
	working_dir  string
	find_command []string
}

pub fn prefix_unbrewed_find_command(options PrefixOptions) []string {
	mut directories := options.subdirs.filter(it !in ['Library', 'Cellar', 'Caskroom', '.git'])
	for path in [options.cache, options.logs, options.repository] {
		if path.len == 0 {
			continue
		}
		relative := path.trim_string_left('${options.prefix}/')
		directories = directories.filter(it != relative)
	}
	directories = directories.filter(it !in ['etc', 'var'])
	directories.sort()
	mut arguments := directories.clone()
	arguments << ['-type', 'f', '(']
	for file in unbrewed_exclude_files {
		arguments << ['!', '-name', file]
	}
	for path in unbrewed_exclude_paths {
		arguments << ['!', '-path', path]
	}
	arguments << ')'
	mut command := ['find']
	command << arguments
	return command
}

pub fn run_prefix(options PrefixOptions) !PrefixResult {
	if options.installed && options.named.len == 0 {
		return error('UsageError: `--installed` requires a formula argument.')
	}
	if options.unbrewed {
		if options.named.len > 0 {
			return error('UsageError: `--unbrewed` does not take a formula argument.')
		}
		return PrefixResult{
			working_dir: options.prefix
			find_command: prefix_unbrewed_find_command(options)
		}
	}
	if options.named.len == 0 {
		return PrefixResult{
			stdout: '${options.prefix}\n'
		}
	}
	if options.resolution_error.len > 0 {
		return error('FormulaUnavailableError: ${options.resolution_error}')
	}
	mut prefixes := []string{}
	for formula in options.formulae {
		if options.installed && !formula.opt_prefix_exists {
			continue
		}
		prefixes << formula.opt_prefix
	}
	if options.installed {
		missing := options.formulae.filter(!it.optlinked).map(it.name)
		if missing.len > 0 {
			return error('NotAKegError: The following formulae are not installed:\n${missing.join(' ')}')
		}
	}
	return PrefixResult{
		stdout: if prefixes.len > 0 { '${prefixes.join('\n')}\n' } else { '' }
	}
}

@[heap]
pub struct PrefixInput {
pub:
	options PrefixOptions
}

pub fn prefix_input_boundary(input &PrefixInput) ruby.Value {
	return ruby.structured_value('Homebrew::Cmd::Prefix::Input', '', {
		'prefix_input_address': u64(voidptr(input)).str()
	})
}

fn prefix_input_from_value(value ruby.Value) &PrefixInput {
	address := value.attributes['prefix_input_address'] or { panic('invalid Prefix input') }
	return unsafe { &PrefixInput(voidptr(address.u64())) }
}

fn prefix_result_value(result PrefixResult) ruby.Value {
	return ruby.map_value({
		'stdout':       ruby.string_value(result.stdout)
		'working_dir':  ruby.string_value(result.working_dir)
		'find_command': ruby.string_array_value(result.find_command)
	})
}
