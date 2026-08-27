module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/tab.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 36.
pub fn ruby_tab_l36_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `update_tab(formula_or_cask, installed_on_request:)` at line 61.
pub fn ruby_tab_l61_d2_update_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_tab', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "tab"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class TabCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Edit tab information for installed formulae or casks.
// 14:
// 15:           This can be useful when you want to control whether an installed
// 16:           formula should be removed by `brew autoremove`.
// 17:           To prevent removal, mark the formula as installed on request;
// 18:           to allow removal, mark the formula as not installed on request.
// 19:         EOS
// 20:         switch "--installed-on-request",
// 21:                description: "Mark <installed_formula> or <installed_cask> as installed on request."
// 22:         switch "--no-installed-on-request",
// 23:                description: "Mark <installed_formula> or <installed_cask> as not installed on request."
// 24:         switch "--formula", "--formulae",
// 25:                description: "Only mark formulae."
// 26:         switch "--cask", "--casks",
// 27:                description: "Only mark casks."
// 28:
// 29:         conflicts "--formula", "--cask"
// 30:         conflicts "--installed-on-request", "--no-installed-on-request"
// 31:
// 32:         named_args [:installed_formula, :installed_cask], min: 1
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         installed_on_request = if args.installed_on_request?
// 38:           true
// 39:         elsif args.no_installed_on_request?
// 40:           false
// 41:         end
// 42:         raise UsageError, "No marking option specified." if installed_on_request.nil?
// 43:
// 44:         formulae, casks = T.cast(args.named.to_formulae_to_casks, [T::Array[Formula], T::Array[Cask::Cask]])
// 45:         packages = formulae + casks
// 46:         not_installed = packages.reject(&:any_version_installed?)
// 47:         if not_installed.any?
// 48:           names = not_installed.map(&:to_s)
// 49:           is_or_are = (names.length == 1) ? "is" : "are"
// 50:           odie "#{names.to_sentence} #{is_or_are} not installed."
// 51:         end
// 52:
// 53:         packages.each do |formula_or_cask|
// 54:           update_tab formula_or_cask, installed_on_request:
// 55:         end
// 56:       end
// 57:
// 58:       private
// 59:
// 60:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask), installed_on_request: T::Boolean).void }
// 61:       def update_tab(formula_or_cask, installed_on_request:)
// 62:         name, tab, created_tab = if formula_or_cask.is_a?(Formula)
// 63:           [formula_or_cask.name, Tab.for_formula(formula_or_cask), false]
// 64:         else
// 65:           cask = formula_or_cask
// 66:           cask_tab = cask.tab
// 67:           cask_tabfile = cask_tab.tabfile
// 68:           if cask_tabfile&.exist?
// 69:             [cask.token, cask_tab, false]
// 70:           else
// 71:             [cask.token, Cask::Tab.create(cask), true]
// 72:           end
// 73:         end
// 74:
// 75:         tabfile = tab.tabfile
// 76:         if !created_tab && !tabfile&.exist?
// 77:           raise ArgumentError,
// 78:                 "Tab file for #{name} does not exist."
// 79:         end
// 80:
// 81:         installed_on_request_str = "#{"not " unless installed_on_request}installed on request"
// 82:         if (tab.installed_on_request && installed_on_request) ||
// 83:            (!tab.installed_on_request && !installed_on_request)
// 84:           tab.write if created_tab
// 85:           ohai "#{name} is already marked as #{installed_on_request_str}."
// 86:           return
// 87:         end
// 88:
// 89:         tab.installed_on_request = installed_on_request
// 90:         tab.write
// 91:         ohai "#{name} is now marked as #{installed_on_request_str}."
// 92:       end
// 93:     end
// 94:   end
// 95: end
