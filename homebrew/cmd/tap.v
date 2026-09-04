module cmd

import ruby

// Translated from Homebrew/brew `cmd/tap.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TapCommandTap {
pub:
	name      string
	installed bool
}

pub struct TapCommandRequest {
pub:
	named         []string
	installed     []TapCommandTap
	repair        bool
	custom_remote bool
	quiet         bool
	verify        bool
	force         bool
}

pub struct TapCommandResult {
pub:
	listed         []string
	repaired       []string
	installed      ?string
	clone_target   ?string
	custom_remote  bool
	quiet          bool
	verify         bool
	force          bool
	already_tapped bool
	output         string
}

pub fn run_tap_command(request TapCommandRequest) !TapCommandResult {
	if request.repair {
		mut repaired := request.installed.map(it.name)
		repaired.sort()
		return TapCommandResult{
			repaired: repaired
		}
	}
	if request.named.len == 0 {
		mut listed := request.installed.map(it.name)
		listed.sort()
		return TapCommandResult{
			listed: listed
			output: if listed.len > 0 { listed.join('\n') + '\n' } else { '' }
		}
	}
	name := request.named[0]
	parts := name.split('/')
	if parts.len != 2 || parts.any(it == '') {
		return error('Invalid tap name `${name}`')
	}
	mut clone_target := ?string(none)
	if request.named.len > 1 && request.named[1] != '' {
		clone_target = request.named[1]
	}
	already_tapped := request.installed.any(it.name == name && it.installed)
	return TapCommandResult{
		installed: if already_tapped { none } else { name }
		clone_target: clone_target
		custom_remote: request.custom_remote
		quiet: request.quiet
		verify: request.verify
		force: request.force
		already_tapped: already_tapped
		output: if already_tapped { '' } else { 'Tapped ${name}\n' }
	}
}

pub fn tap_command_tap_to_value(tap TapCommandTap) ruby.Value {
	return ruby.structured_value('Tap', tap.name, {
		'name':      tap.name
		'installed': tap.installed.str()
	})
}

fn tap_command_tap_from_value(value ruby.Value) TapCommandTap {
	return TapCommandTap{
		name: value.attributes['name'] or { value.as_string() }
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
	}
}

pub fn tap_command_result_to_value(result TapCommandResult) ruby.Value {
	return ruby.map_value({
		'listed':         ruby.string_array_value(result.listed)
		'repaired':       ruby.string_array_value(result.repaired)
		'installed':      if value := result.installed {
			ruby.string_value(value)
		} else {
			ruby.object_value('NilClass', 'nil')
		}
		'clone_target':   if value := result.clone_target {
			ruby.string_value(value)
		} else {
			ruby.object_value('NilClass', 'nil')
		}
		'already_tapped': ruby.bool_value(result.already_tapped)
		'output':         ruby.string_value(result.output)
	})
}

// Ruby method `run` at line 43.
pub fn ruby_tap_l43_d1_run(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 {
		args[0].as_map() or { return ruby.object_value('UsageError', err.msg()) }
	} else {
		map[string]ruby.Value{}
	}
	installed_values := if value := values['installed'] {
		value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	request := TapCommandRequest{
		named: if value := values['named'] {
			value.as_string_array() or { []string{} }} else {
			[]string{}}
		installed: installed_values.map(tap_command_tap_from_value(it))
		repair: if value := values['repair'] { value.as_bool() or { false } } else { false }
		custom_remote: if value := values['custom_remote'] {
			value.as_bool() or { false }} else {
			false}
		quiet: if value := values['quiet'] { value.as_bool() or { false } } else { false }
		verify: if value := values['eval_all'] { value.as_bool() or { false } } else { false }
		force: if value := values['force'] { value.as_bool() or { false } } else { false }
	}
	result := run_tap_command(request) or {
		return ruby.object_value('Tap::InvalidNameError', err.msg())
	}
	return tap_command_result_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class TapCmd < AbstractCommand
// 10:       cmd_args do
// 11:         usage_banner "`tap` [<options>] [<user>`/`<repo>] [<URL>]"
// 12:         description <<~EOS
// 13:           Tap a formula repository.
// 14:           If no arguments are provided, list all installed taps.
// 15:
// 16:           With <URL> unspecified, tap a formula repository from GitHub using HTTPS.
// 17:           Since so many taps are hosted on GitHub, this command is a shortcut for
// 18:           `brew tap` <user>`/`<repo> `https://github.com/`<user>`/homebrew-`<repo>.
// 19:
// 20:           With <URL> specified, tap a formula repository from anywhere, using
// 21:           any transport protocol that `git`(1) handles. The one-argument form of `tap`
// 22:           simplifies but also limits. This two-argument command makes no
// 23:           assumptions, so taps can be cloned from places other than GitHub and
// 24:           using protocols other than HTTPS, e.g. SSH, git, HTTP, FTP(S), rsync.
// 25:         EOS
// 26:         switch "--custom-remote",
// 27:                description: "Install or change a tap with a custom remote. Useful for mirrors."
// 28:         switch "--repair",
// 29:                description: "Add missing symlinks to tap manpages and shell completions. Correct git remote " \
// 30:                             "refs for any taps where upstream HEAD branch has been renamed."
// 31:         switch "--eval-all",
// 32:                description: "Evaluate all available formulae, casks and aliases in the new tap to check their " \
// 33:                             "validity.",
// 34:                env:         :eval_all,
// 35:                odeprecated: true
// 36:         switch "-f", "--force",
// 37:                description: "Force install core taps even under API mode."
// 38:
// 39:         named_args :tap, max: 2
// 40:       end
// 41:
// 42:       sig { override.void }
// 43:       def run
// 44:         if args.repair?
// 45:           Tap.installed.each do |tap|
// 46:             tap.link_completions_and_manpages
// 47:             tap.fix_remote_configuration
// 48:           end
// 49:         elsif args.no_named?
// 50:           puts Tap.installed.sort_by(&:name)
// 51:         else
// 52:           begin
// 53:             tap = Tap.fetch(args.named.fetch(0))
// 54:             tap.install clone_target:  args.named.second,
// 55:                         custom_remote: args.custom_remote?,
// 56:                         quiet:         args.quiet?,
// 57:                         verify:        args.eval_all?,
// 58:                         force:         args.force?
// 59:           rescue Tap::InvalidNameError, TapRemoteMismatchError, TapNoCustomRemoteError => e
// 60:             odie e
// 61:           rescue TapAlreadyTappedError
// 62:             nil
// 63:           end
// 64:         end
// 65:       end
// 66:     end
// 67:   end
// 68: end
