module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/linkage.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn linkage_command_input_boundary(input &LinkageCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Linkage::Input', '', {
		'linkage_command_input_address': u64(voidptr(input)).str()
	})
}

fn linkage_command_input_from_value(value ruby.Value) &LinkageCommandInput {
	address := value.attributes['linkage_command_input_address'] or {
		panic('invalid Linkage command input')
	}
	return unsafe { &LinkageCommandInput(voidptr(address.u64())) }
}

fn linkage_command_result_value(result LinkageCommandResult) ruby.Value {
	return ruby.map_value({
		'kegs':       ruby.string_array_value(result.kegs)
		'output':     ruby.string_array_value(result.output)
		'mode':       ruby.object_value('Symbol', result.mode)
		'cache_name': ruby.object_value('Symbol', result.cache_name)
		'cached':     ruby.bool_value(result.cached)
		'failed':     ruby.bool_value(result.failed)
	})
}

// Ruby method `run` at line 33.
pub fn ruby_linkage_l33_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return linkage_command_result_value(run_linkage_command(linkage_command_input_from_value(args[0]).options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cache_store"
// 6: require "linkage_checker"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class Linkage < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Check the library links from the given <formula> kegs. If no <formula> are
// 14:           provided, check all kegs. Raises an error if run on uninstalled formulae.
// 15:         EOS
// 16:         switch "--test",
// 17:                description: "Show only missing libraries and exit with a non-zero status if any missing " \
// 18:                             "libraries are found."
// 19:         switch "--strict",
// 20:                depends_on:  "--test",
// 21:                description: "Exit with a non-zero status if any undeclared dependencies with linkage are found."
// 22:         switch "--reverse",
// 23:                description: "For every library that a keg references, print its dylib path followed by the " \
// 24:                             "binaries that link to it."
// 25:         switch "--cached",
// 26:                description: "Print the cached linkage values stored in `$HOMEBREW_CACHE`, set by a previous " \
// 27:                             "`brew linkage` run."
// 28:
// 29:         named_args :installed_formula
// 30:       end
// 31:
// 32:       sig { override.void }
// 33:       def run
// 34:         CacheStoreDatabase.use(:linkage) do |db|
// 35:           kegs = if args.named.to_default_kegs.empty?
// 36:             Formula.installed.filter_map(&:any_installed_keg)
// 37:           else
// 38:             args.named.to_default_kegs
// 39:           end
// 40:           kegs.each do |keg|
// 41:             ohai "Checking #{keg.name} linkage" if kegs.size > 1
// 42:
// 43:             result = LinkageChecker.new(keg,
// 44:                                         cache_db: T.cast(db,
// 45:                                                          CacheStoreDatabase[String,
// 46:                                                                             T::Hash[T.any(String, Symbol),
// 47:                                                                                     T.anything]]))
// 48:
// 49:             if args.test?
// 50:               result.display_test_output(strict: args.strict?)
// 51:               Homebrew.failed = true if result.broken_library_linkage?(test: true, strict: args.strict?)
// 52:             elsif args.reverse?
// 53:               result.display_reverse_output
// 54:             else
// 55:               result.display_normal_output
// 56:             end
// 57:           end
// 58:         end
// 59:       end
// 60:     end
// 61:   end
// 62: end
