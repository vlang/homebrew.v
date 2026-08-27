module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/desc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 42.
pub fn ruby_desc_l42_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "descriptions"
// 6: require "search"
// 7: require "description_cache_store"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Desc < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Display <formula>'s name and one-line description.
// 15:           The cache is created on the first search, making that search slower than subsequent ones.
// 16:         EOS
// 17:         switch "-s", "--search",
// 18:                description: "Search both names and descriptions for <text>. If <text> is flanked by " \
// 19:                             "slashes, it is interpreted as a regular expression."
// 20:         switch "-n", "--name",
// 21:                description: "Search just names for <text>. If <text> is flanked by slashes, it is " \
// 22:                             "interpreted as a regular expression."
// 23:         switch "-d", "--description",
// 24:                description: "Search just descriptions for <text>. If <text> is flanked by slashes, " \
// 25:                             "it is interpreted as a regular expression."
// 26:         switch "--eval-all",
// 27:                description: "Evaluate all available formulae and casks, whether installed or not, to search their " \
// 28:                             "descriptions.",
// 29:                env:         :eval_all,
// 30:                odeprecated: true
// 31:         switch "--formula", "--formulae",
// 32:                description: "Treat all named arguments as formulae."
// 33:         switch "--cask", "--casks",
// 34:                description: "Treat all named arguments as casks."
// 35:
// 36:         conflicts "--search", "--name", "--description"
// 37:
// 38:         named_args [:formula, :cask, :text_or_regex], min: 1
// 39:       end
// 40:
// 41:       sig { override.void }
// 42:       def run
// 43:         search_type = if args.search?
// 44:           Descriptions::SearchField::Either
// 45:         elsif args.name?
// 46:           Descriptions::SearchField::Name
// 47:         elsif args.description?
// 48:           Descriptions::SearchField::Description
// 49:         end
// 50:
// 51:         if search_type
// 52:           if !args.eval_all? && !Homebrew::EnvConfig.tap_trust_configured? && Homebrew::EnvConfig.no_install_from_api?
// 53:             raise UsageError,
// 54:                   "`brew desc --search` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 55:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 56:           end
// 57:
// 58:           query = args.named.join(" ")
// 59:           string_or_regex = Search.query_regexp(query)
// 60:           return Search.search_descriptions(string_or_regex, args, search_type:)
// 61:         end
// 62:
// 63:         desc = {}
// 64:         args.named.to_formulae_and_casks.each do |formula_or_cask|
// 65:           case formula_or_cask
// 66:           when Formula
// 67:             desc[formula_or_cask.full_name] = formula_or_cask.desc
// 68:           when Cask::Cask
// 69:             desc[formula_or_cask.full_name] = [formula_or_cask.name.join(", "), formula_or_cask.desc.presence]
// 70:           else
// 71:             raise TypeError, "Unsupported formula_or_cask type: #{formula_or_cask.class}"
// 72:           end
// 73:         end
// 74:         Descriptions.new(desc).print
// 75:       end
// 76:     end
// 77:   end
// 78: end
