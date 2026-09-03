module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/unlink.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct UnlinkCommandKeg {
pub:
	name string
	path string
}

pub struct UnlinkCommandOptions {
pub:
	dry_run bool
	verbose bool
}

pub struct UnlinkCommandResult {
pub:
	output string
	counts []int
}

pub type UnlinkCommandAction = fn(UnlinkCommandKeg, UnlinkCommandOptions) !int

pub fn unlink_command(kegs []UnlinkCommandKeg, options UnlinkCommandOptions,
	action UnlinkCommandAction) !UnlinkCommandResult {
	mut lines := []string{}
	mut counts := []int{}
	for keg in kegs {
		if options.dry_run {
			lines << 'Would remove:'
		}
		count := action(keg, options)!
		counts << count
		if !options.dry_run {
			mut message := 'Unlinking ${keg.path}... '
			if options.verbose {
				message += '\n'
			}
			lines << message + '${count} symlinks removed.'
		}
	}
	return UnlinkCommandResult{
		output: if lines.len == 0 { '' } else { lines.join('\n') + '\n' }
		counts: counts
	}
}

fn unlink_command_count(keg UnlinkCommandKeg, _ UnlinkCommandOptions) !int {
	return if keg.name == '' { 0 } else { 1 }
}

// Ruby method `run` at line 24.
pub fn ruby_unlink_l24_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	kegs := if args.len > 0 {
		args[0].array_data.map(UnlinkCommandKeg{
			name: it.attributes['name'] or { it.as_string() }
			path: it.attributes['path'] or { it.as_string() }
		})
	} else {
		[]UnlinkCommandKeg{}
	}
	options := UnlinkCommandOptions{
		dry_run: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		verbose: if args.len > 2 { args[2].as_bool() or { false } } else { false }
	}
	result := unlink_command(kegs, options, unlink_command_count) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.structured_value('UnlinkCommandResult', result.output, {
		'output': result.output
		'counts': result.counts.map(it.str()).join(',')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "unlink"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class UnlinkCmd < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Remove symlinks for <formula> from Homebrew's prefix. This can be useful
// 13:           for temporarily disabling a formula:
// 14:           `brew unlink` <formula> `&&` <commands> `&& brew link` <formula>
// 15:         EOS
// 16:         switch "-n", "--dry-run",
// 17:                description: "List files which would be unlinked without actually unlinking or " \
// 18:                             "deleting any files."
// 19:
// 20:         named_args :installed_formula, min: 1
// 21:       end
// 22:
// 23:       sig { override.void }
// 24:       def run
// 25:         options = { dry_run: args.dry_run?, verbose: args.verbose? }
// 26:
// 27:         args.named.to_default_kegs.each do |keg|
// 28:           if args.dry_run?
// 29:             puts "Would remove:"
// 30:             keg.unlink(**options)
// 31:             next
// 32:           end
// 33:
// 34:           Unlink.unlink(keg, dry_run: args.dry_run?, verbose: args.verbose?)
// 35:         end
// 36:       end
// 37:     end
// 38:   end
// 39: end
