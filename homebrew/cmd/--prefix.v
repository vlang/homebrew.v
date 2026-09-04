module cmd

import ruby

// Translated from Homebrew/brew `cmd/--prefix.rb`.
// The original source is retained below until every stub has a typed V body.

const unbrewed_exclude_files = ['.DS_Store']

const unbrewed_exclude_paths = ['*/.keepme', '.github/*', 'bin/brew', 'completions/zsh/_brew',
	'docs/*', 'lib/gdk-pixbuf-2.0/*', 'lib/gio/*', 'lib/node_modules/*',
	'lib/python[23].[0-9]/*', 'lib/python3.[0-9][0-9]/*', 'lib/pypy/*', 'lib/pypy3/*',
	'lib/ruby/gems/[12].*', 'lib/ruby/site_ruby/[12].*', 'lib/ruby/vendor_ruby/[12].*',
	'manpages/brew.1', 'share/pypy/*', 'share/pypy3/*', 'share/info/dir', 'share/man/whatis',
	'share/mime/*', 'texlive/*']

pub struct PrefixFormula {
pub:
	name              string
	opt_prefix        string
	opt_prefix_exists bool
	optlinked         bool
}

pub struct PrefixOptions {
pub:
	prefix            string
	unbrewed          bool
	installed         bool
	formulae          []PrefixFormula
	named             []string
	resolution_error  string
	subdirs           []string
	cache             string
	logs              string
	repository        string
}

pub struct PrefixResult {
pub:
	stdout      string
	working_dir string
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
		'stdout': ruby.string_value(result.stdout)
		'working_dir': ruby.string_value(result.working_dir)
		'find_command': ruby.string_array_value(result.find_command)
	})
}

// Ruby method `self.command_name = "--prefix"` at line 39.
pub fn ruby_prefix_l39_d1_self_command_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('--prefix')
}

// Ruby method `run` at line 62.
pub fn ruby_prefix_l62_d2_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return prefix_result_value(run_prefix(prefix_input_from_value(args[0]).options) or {
		message := err.msg()
		type_name := if message.starts_with('UsageError:') {
			'UsageError'
		} else if message.starts_with('FormulaUnavailableError:') {
			'FormulaUnavailableError'
		} else if message.starts_with('NotAKegError:') {
			'NotAKegError'
		} else {
			'Error'
		}
		return ruby.object_value(type_name, message.all_after(': ').trim_space())
	})
}

// Ruby method `list_unbrewed` at line 96.
pub fn ruby_prefix_l96_d3_list_unbrewed(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return ruby.string_array_value(prefix_unbrewed_find_command(prefix_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Prefix < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       UNBREWED_EXCLUDE_FILES = %w[.DS_Store].freeze
// 13:       UNBREWED_EXCLUDE_PATHS = %w[
// 14:         */.keepme
// 15:         .github/*
// 16:         bin/brew
// 17:         completions/zsh/_brew
// 18:         docs/*
// 19:         lib/gdk-pixbuf-2.0/*
// 20:         lib/gio/*
// 21:         lib/node_modules/*
// 22:         lib/python[23].[0-9]/*
// 23:         lib/python3.[0-9][0-9]/*
// 24:         lib/pypy/*
// 25:         lib/pypy3/*
// 26:         lib/ruby/gems/[12].*
// 27:         lib/ruby/site_ruby/[12].*
// 28:         lib/ruby/vendor_ruby/[12].*
// 29:         manpages/brew.1
// 30:         share/pypy/*
// 31:         share/pypy3/*
// 32:         share/info/dir
// 33:         share/man/whatis
// 34:         share/mime/*
// 35:         texlive/*
// 36:       ].freeze
// 37:
// 38:       sig { override.returns(String) }
// 39:       def self.command_name = "--prefix"
// 40:
// 41:       cmd_args do
// 42:         description <<~EOS
// 43:           Display Homebrew's install path. *Default:*
// 44:
// 45:             - macOS ARM: `#{HOMEBREW_MACOS_ARM_DEFAULT_PREFIX}`
// 46:             - macOS Intel: `#{HOMEBREW_DEFAULT_PREFIX}`
// 47:             - Linux: `#{HOMEBREW_LINUX_DEFAULT_PREFIX}`
// 48:
// 49:           If <formula> is provided, display the location where <formula> is or would be installed.
// 50:         EOS
// 51:         switch "--unbrewed",
// 52:                description: "List files in Homebrew's prefix not installed by Homebrew."
// 53:         switch "--installed",
// 54:                description: "Outputs nothing and returns a failing status code if <formula> is not installed."
// 55:
// 56:         conflicts "--unbrewed", "--installed"
// 57:
// 58:         named_args :formula
// 59:       end
// 60:
// 61:       sig { override.void }
// 62:       def run
// 63:         raise UsageError, "`--installed` requires a formula argument." if args.installed? && args.no_named?
// 64:
// 65:         if args.unbrewed?
// 66:           raise UsageError, "`--unbrewed` does not take a formula argument." unless args.no_named?
// 67:
// 68:           list_unbrewed
// 69:         elsif args.no_named?
// 70:           puts HOMEBREW_PREFIX
// 71:         else
// 72:           formulae = args.named.to_resolved_formulae
// 73:           prefixes = formulae.filter_map do |f|
// 74:             next nil if args.installed? && !f.opt_prefix.exist?
// 75:
// 76:             # this case will be short-circuited by brew.sh logic for a single formula
// 77:             f.opt_prefix
// 78:           end
// 79:           puts prefixes
// 80:           if args.installed?
// 81:             missing_formulae = formulae.reject(&:optlinked?)
// 82:                                        .map(&:name)
// 83:             return if missing_formulae.blank?
// 84:
// 85:             raise NotAKegError, <<~EOS
// 86:               The following formulae are not installed:
// 87:               #{missing_formulae.join(" ")}
// 88:             EOS
// 89:           end
// 90:         end
// 91:       end
// 92:
// 93:       private
// 94:
// 95:       sig { void }
// 96:       def list_unbrewed
// 97:         dirs  = HOMEBREW_PREFIX.subdirs.map { |dir| dir.basename.to_s }
// 98:         dirs -= %w[Library Cellar Caskroom .git]
// 99:
// 100:         # Exclude cache, logs and repository, if they are located under the prefix.
// 101:         [HOMEBREW_CACHE, HOMEBREW_LOGS, HOMEBREW_REPOSITORY].each do |dir|
// 102:           dirs.delete dir.relative_path_from(HOMEBREW_PREFIX).to_s
// 103:         end
// 104:         dirs.delete "etc"
// 105:         dirs.delete "var"
// 106:
// 107:         arguments = dirs.sort + %w[-type f (]
// 108:         arguments.concat UNBREWED_EXCLUDE_FILES.flat_map { |f| %W[! -name #{f}] }
// 109:         arguments.concat UNBREWED_EXCLUDE_PATHS.flat_map { |d| %W[! -path #{d}] }
// 110:         arguments.push ")"
// 111:
// 112:         cd(HOMEBREW_PREFIX) { safe_system("find", *arguments) }
// 113:       end
// 114:     end
// 115:   end
// 116: end
