module cmd

import ruby
import homebrew.extend

// Translated from Homebrew/brew `cmd/docs.rb`.
// The original source is retained below until every stub has a typed V body.
pub const homebrew_docs_url = 'https://docs.brew.sh'

pub fn docs_browser_plan(browser string, display string, dbus_session_address string) extend.BrowserPlan {
	return extend.browser_plan(browser, [homebrew_docs_url], display, dbus_session_address)
}

// Ruby method `run` at line 16.
pub fn ruby_docs_l16_d1_run(args ...ruby.Value) ruby.Value {
	browser := if args.len > 0 { args[0].as_string() } else { '' }
	display := if args.len > 1 { args[1].as_string() } else { '' }
	dbus := if args.len > 2 { args[2].as_string() } else { '' }
	plan := docs_browser_plan(browser, display, dbus)
	dbus_setting := plan.command.environment['DBUS_SESSION_BUS_ADDRESS'] or {
		extend.EnvironmentValue{ unset: true }
	}
	return ruby.structured_value('BrowserPlan', plan.command.program, {
		'available':            plan.available.str()
		'program':              plan.command.program
		'arguments':            plan.command.arguments.join('\n')
		'display':              plan.display.value
		'display_unset':        plan.display.unset.str()
		'dbus_session_address': dbus_setting.value
		'dbus_unset':           dbus_setting.unset.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Docs < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Open Homebrew's online documentation at <#{HOMEBREW_DOCS_WWW}> in a browser.
// 12:         EOS
// 13:       end
// 14:
// 15:       sig { override.void }
// 16:       def run
// 17:         exec_browser HOMEBREW_DOCS_WWW
// 18:       end
// 19:     end
// 20:   end
// 21: end
