module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 57.
pub fn ruby_livecheck_l57_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `watchlist_path` at line 155.
pub fn ruby_livecheck_l155_d2_watchlist_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('watchlist_path', ...args)
}

// Ruby method `skip_autobump?` at line 160.
pub fn ruby_livecheck_l160_d3_skip_autobump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_autobump?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "livecheck/livecheck"
// 7: require "livecheck/strategy"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class LivecheckCmd < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check for newer versions of formulae and/or casks from upstream.
// 15:           If no formula or cask argument is passed, the list of formulae and
// 16:           casks to check is taken from `$HOMEBREW_LIVECHECK_WATCHLIST` or
// 17:           `${XDG_CONFIG_HOME}/homebrew/livecheck_watchlist.txt` if
// 18:           `$XDG_CONFIG_HOME` is set or `~/.homebrew/livecheck_watchlist.txt`
// 19:           otherwise.
// 20:         EOS
// 21:         switch "--full-name",
// 22:                description: "Print formulae and casks with fully-qualified names."
// 23:         flag   "--tap=",
// 24:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 25:         switch "--eval-all",
// 26:                description: "Evaluate all available formulae and casks, whether installed or not, to check them.",
// 27:                env:         :eval_all,
// 28:                odeprecated: true
// 29:         switch "--installed",
// 30:                description: "Check formulae and casks that are currently installed."
// 31:         switch "--newer-only",
// 32:                description: "Show the latest version only if it's newer than the current formula or cask version."
// 33:         switch "--json",
// 34:                description: "Output information in JSON format."
// 35:         switch "-r", "--resources",
// 36:                description: "Also check resources for formulae."
// 37:         switch "-q", "--quiet",
// 38:                description: "Suppress warnings, don't print a progress bar for JSON output."
// 39:         switch "--formula", "--formulae",
// 40:                description: "Only check formulae."
// 41:         switch "--cask", "--casks",
// 42:                description: "Only check casks."
// 43:         switch "--extract-plist",
// 44:                description: "Enable checking multiple casks with ExtractPlist strategy."
// 45:         switch "--autobump",
// 46:                description: "Include packages that are autobumped by BrewTestBot. By default these are skipped."
// 47:
// 48:         conflicts "--tap", "--installed", "--eval-all"
// 49:         conflicts "--json", "--debug"
// 50:         conflicts "--formula", "--cask"
// 51:         conflicts "--formula", "--extract-plist"
// 52:
// 53:         named_args [:formula, :cask], without_api: true
// 54:       end
// 55:
// 56:       sig { override.void }
// 57:       def run
// 58:         Homebrew.install_bundler_gems!(groups: ["livecheck"])
// 59:
// 60:         eval_all = args.eval_all?
// 61:         eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 62:
// 63:         if args.debug? && args.verbose?
// 64:           puts args
// 65:           puts Homebrew::EnvConfig.livecheck_watchlist if Homebrew::EnvConfig.livecheck_watchlist.present?
// 66:         end
// 67:
// 68:         formulae_and_casks_to_check = T.let(
// 69:           Homebrew.with_no_api_env do
// 70:             if args.tap
// 71:               tap = Tap.fetch(args.tap)
// 72:               formulae = args.cask? ? [] : tap.formula_files.map { |path| Formulary.factory(path) }
// 73:               casks = args.formula? ? [] : tap.cask_files.map { |path| Cask::CaskLoader.load(path) }
// 74:               formulae + casks
// 75:             elsif args.installed?
// 76:               formulae = args.cask? ? [] : Formula.installed
// 77:               casks = args.formula? ? [] : Cask::Caskroom.casks
// 78:               formulae + casks
// 79:             elsif args.named.present?
// 80:               args.named.to_formulae_and_casks_with_taps
// 81:             elsif eval_all
// 82:               formulae = args.cask? ? [] : Formula.all(eval_all:)
// 83:               casks = args.formula? ? [] : Cask::Cask.all(eval_all:)
// 84:               formulae + casks
// 85:             elsif File.exist?(watchlist_path)
// 86:               begin
// 87:                 # This removes blank lines, comment lines, and trailing comments
// 88:                 names = Pathname.new(watchlist_path).read.lines
// 89:                                 .filter_map do |line|
// 90:                                   comment_index = line.index("#")
// 91:                                   next if comment_index&.zero?
// 92:
// 93:                                   line = line[0...comment_index] if comment_index
// 94:                                   line&.strip.presence
// 95:                                 end
// 96:
// 97:                 named_args = CLI::NamedArgs.new(*names, parent: args)
// 98:                 named_args.to_formulae_and_casks(ignore_unavailable: true)
// 99:               rescue Errno::ENOENT => e
// 100:                 onoe e
// 101:               end
// 102:             else
// 103:               raise UsageError,
// 104:                     "`brew livecheck` with no arguments needs a watchlist file, " \
// 105:                     "`HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 106:             end
// 107:           end,
// 108:           T::Array[T.any(Formula, Cask::Cask)],
// 109:         )
// 110:
// 111:         skipped_autobump = T.let(false, T::Boolean)
// 112:         if skip_autobump?
// 113:           autobump_lists = {}
// 114:
// 115:           formulae_and_casks_to_check = formulae_and_casks_to_check.reject do |formula_or_cask|
// 116:             tap = formula_or_cask.tap
// 117:             next false if tap.nil?
// 118:
// 119:             autobump_lists[tap] ||= tap.autobump
// 120:
// 121:             name = Utils.name_or_token(formula_or_cask)
// 122:             next unless autobump_lists[tap].include?(name)
// 123:
// 124:             odebug "Skipping #{name} as it is autobumped in #{tap}."
// 125:             skipped_autobump = true
// 126:             true
// 127:           end
// 128:         end
// 129:
// 130:         formulae_and_casks_to_check = formulae_and_casks_to_check.sort_by do |formula_or_cask|
// 131:           Utils.name_or_token(formula_or_cask)
// 132:         end
// 133:
// 134:         raise UsageError, "No formulae or casks to check." if formulae_and_casks_to_check.blank? && !skipped_autobump
// 135:         return if formulae_and_casks_to_check.blank?
// 136:
// 137:         options = {
// 138:           json:                 args.json?,
// 139:           full_name:            args.full_name?,
// 140:           handle_name_conflict: !args.formula? && !args.cask?,
// 141:           check_resources:      args.resources?,
// 142:           newer_only:           args.newer_only?,
// 143:           extract_plist:        args.extract_plist?,
// 144:           quiet:                args.quiet?,
// 145:           debug:                args.debug?,
// 146:           verbose:              args.verbose?,
// 147:         }.compact
// 148:
// 149:         Livecheck.run_checks(formulae_and_casks_to_check, **options)
// 150:       end
// 151:
// 152:       private
// 153:
// 154:       sig { returns(String) }
// 155:       def watchlist_path
// 156:         @watchlist_path ||= T.let(File.expand_path(Homebrew::EnvConfig.livecheck_watchlist), T.nilable(String))
// 157:       end
// 158:
// 159:       sig { returns(T::Boolean) }
// 160:       def skip_autobump?
// 161:         !(args.autobump? || Homebrew::EnvConfig.livecheck_autobump?)
// 162:       end
// 163:     end
// 164:   end
// 165: end
