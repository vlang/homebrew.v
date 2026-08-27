module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/tap-info.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_tap_info_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `print_tap_info(taps)` at line 44.
pub fn ruby_tap_info_l44_d2_print_tap_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_tap_info', ...args)
}

// Ruby method `print_tap_listings(tap)` at line 97.
pub fn ruby_tap_info_l97_d3_print_tap_listings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_tap_listings', ...args)
}

// Ruby method `decorate_formula(tap, name, installed:)` at line 123.
pub fn ruby_tap_info_l123_d4_decorate_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate_formula', ...args)
}

// Ruby method `decorate_cask(tap, token, installed:)` at line 138.
pub fn ruby_tap_info_l138_d5_decorate_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate_cask', ...args)
}

// Ruby method `print_tap_json(taps)` at line 153.
pub fn ruby_tap_info_l153_d6_print_tap_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_tap_json', ...args)
}

// Ruby method `print_section(tap, label, all, installed, min_width:, &block)` at line 175.
pub fn ruby_tap_info_l175_d7_print_section(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_section', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class TapInfo < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Show detailed information about one or more <tap>s.
// 12:           If no <tap> names are provided, display brief statistics for all installed taps.
// 13:         EOS
// 14:         switch "--installed",
// 15:                description: "Show information on each installed tap."
// 16:         flag   "--json",
// 17:                description: "Print a JSON representation of <tap>. Currently the default and only accepted " \
// 18:                             "value for <version> is `v1`. See the docs for examples of using the JSON " \
// 19:                             "output: <https://docs.brew.sh/Querying-Brew>"
// 20:
// 21:         named_args :tap
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         require "tap"
// 27:
// 28:         taps = if args.installed?
// 29:           Tap
// 30:         else
// 31:           args.named.to_taps
// 32:         end
// 33:
// 34:         if args.json
// 35:           raise UsageError, "invalid JSON version: #{args.json}" unless ["v1", true].include? args.json
// 36:
// 37:           print_tap_json(taps.sort_by(&:to_s))
// 38:         else
// 39:           print_tap_info(taps.sort_by(&:to_s))
// 40:         end
// 41:       end
// 42:
// 43:       sig { params(taps: T::Array[Tap]).void }
// 44:       def print_tap_info(taps)
// 45:         if taps.none?
// 46:           # Tap#private? queries the GitHub API for each non-core tap.
// 47:           tap_stats = Utils.parallel_map(Tap.installed) do |tap|
// 48:             [tap.formula_files.size, tap.command_files.size, tap.private?]
// 49:           end
// 50:           tap_count = tap_stats.count
// 51:           formula_count = tap_stats.sum(&:first)
// 52:           command_count = tap_stats.sum { |_, command_files_count, _| command_files_count }
// 53:           private_count = tap_stats.count { |_, _, private_tap| private_tap }
// 54:           info = Utils.pluralize("tap", tap_count, include_count: true)
// 55:           info += ", #{private_count} private"
// 56:           info += ", #{Utils.pluralize("formula", formula_count, include_count: true)}"
// 57:           info += ", #{Utils.pluralize("command", command_count, include_count: true)}"
// 58:           info += ", #{HOMEBREW_TAP_DIRECTORY.dup.abv}" if HOMEBREW_TAP_DIRECTORY.directory?
// 59:           puts info
// 60:         else
// 61:           info = ""
// 62:           default_branches = %w[main master].freeze
// 63:
// 64:           taps.each_with_index do |tap, i|
// 65:             puts unless i.zero?
// 66:             info = "#{tap}: "
// 67:             if tap.installed?
// 68:               info += "Installed"
// 69:               if Homebrew::EnvConfig.require_tap_trust?
// 70:                 require "trust"
// 71:                 info += "\n#{Homebrew::Trust.trusted_tap?(tap) ? "Trusted" : "Untrusted"}"
// 72:               end
// 73:               info += if (contents = tap.contents).blank?
// 74:                 "\nNo commands/casks/formulae"
// 75:               else
// 76:                 "\n#{contents.join(", ")}"
// 77:               end
// 78:               info += "\nPrivate" if tap.private?
// 79:               info += "\n#{tap.path} (#{tap.path.abv})"
// 80:               info += "\nFrom: #{tap.remote.presence || "N/A"}"
// 81:               info += "\norigin: #{tap.remote}" if tap.remote != tap.default_remote
// 82:               info += "\nHEAD: #{tap.git_head || "(none)"}"
// 83:               info += "\nlast commit: #{tap.git_last_commit || "never"}"
// 84:               info += "\nbranch: #{tap.git_branch || "(none)"}" if default_branches.exclude?(tap.git_branch)
// 85:               puts info
// 86:               print_tap_listings(tap)
// 87:             else
// 88:               info += "Not installed"
// 89:               Homebrew.failed = true
// 90:               puts info
// 91:             end
// 92:           end
// 93:         end
// 94:       end
// 95:
// 96:       sig { params(tap: Tap).void }
// 97:       def print_tap_listings(tap)
// 98:         commands = tap.command_files
// 99:                       .map { |path| path.basename(path.extname).to_s.delete_prefix("brew-") }
// 100:                       .sort
// 101:         installed_formula_names = Formula.installed_formula_names.to_set
// 102:         installed_cask_tokens = Cask::Caskroom.tokens.to_set
// 103:         formula_names = tap.formula_names.map { |name| Utils.name_from_full_name(name) }.sort
// 104:         cask_tokens = tap.cask_tokens.map { |token| Utils.name_from_full_name(token) }.sort
// 105:         installed_formulae = formula_names.select { |name| installed_formula_names.include?(name) }
// 106:         installed_casks = cask_tokens.select { |token| installed_cask_tokens.include?(token) }
// 107:
// 108:         if commands.any?
// 109:           ohai "Commands"
// 110:           puts commands.join(", ")
// 111:         end
// 112:
// 113:         min_width = (formula_names + cask_tokens).map { |n| Tty.strip_ansi(pretty_uninstalled(n)).length }.max || 0
// 114:         print_section(tap, "Formulae", formula_names, installed_formulae, min_width:) do |name|
// 115:           decorate_formula(tap, name, installed: installed_formula_names.include?(name))
// 116:         end
// 117:         print_section(tap, "Casks", cask_tokens, installed_casks, min_width:) do |token|
// 118:           decorate_cask(tap, token, installed: installed_cask_tokens.include?(token))
// 119:         end
// 120:       end
// 121:
// 122:       sig { params(tap: Tap, name: String, installed: T::Boolean).returns(String) }
// 123:       def decorate_formula(tap, name, installed:)
// 124:         formula = Formulary.factory("#{tap.name}/#{name}")
// 125:         pretty_install_status(
// 126:           name,
// 127:           installed:,
// 128:           outdated:         installed && formula.outdated?,
// 129:           deprecated:       formula.deprecated?,
// 130:           disabled:         formula.disabled?,
// 131:           mark_uninstalled: false,
// 132:         )
// 133:       rescue
// 134:         pretty_install_status(name, installed:, mark_uninstalled: false)
// 135:       end
// 136:
// 137:       sig { params(tap: Tap, token: String, installed: T::Boolean).returns(String) }
// 138:       def decorate_cask(tap, token, installed:)
// 139:         cask = Cask::CaskLoader.load("#{tap.name}/#{token}")
// 140:         pretty_install_status(
// 141:           token,
// 142:           installed:,
// 143:           outdated:         installed && cask.outdated?,
// 144:           deprecated:       cask.deprecated?,
// 145:           disabled:         cask.disabled?,
// 146:           mark_uninstalled: false,
// 147:         )
// 148:       rescue
// 149:         pretty_install_status(token, installed:, mark_uninstalled: false)
// 150:       end
// 151:
// 152:       sig { params(taps: T::Array[Tap]).void }
// 153:       def print_tap_json(taps)
// 154:         # Tap#to_hash shells out to Git and queries the GitHub API.
// 155:         hashes = Utils.parallel_map(taps, &:to_hash)
// 156:
// 157:         puts JSON.pretty_generate(hashes)
// 158:       end
// 159:
// 160:       private
// 161:
// 162:       LISTING_LIMIT = 30
// 163:       private_constant :LISTING_LIMIT
// 164:
// 165:       sig {
// 166:         params(
// 167:           tap:       Tap,
// 168:           label:     String,
// 169:           all:       T::Array[String],
// 170:           installed: T::Array[String],
// 171:           min_width: Integer,
// 172:           block:     T.proc.params(name: String).returns(String),
// 173:         ).void
// 174:       }
// 175:       def print_section(tap, label, all, installed, min_width:, &block)
// 176:         return if all.none?
// 177:
// 178:         if all.size <= LISTING_LIMIT
// 179:           ohai label, Formatter.columns(all.map(&block), min_width:)
// 180:         elsif installed.any?
// 181:           ohai label
// 182:           opoo "Tap has more than #{LISTING_LIMIT} #{label.downcase}; showing only installed entries."
// 183:           puts Formatter.columns(installed.map(&block), min_width:)
// 184:         else
// 185:           ohai label
// 186:           opoo "Tap has more than #{LISTING_LIMIT} #{label.downcase} and none are installed."
// 187:           puts "See: #{tap.remote}" if tap.remote.present?
// 188:         end
// 189:       end
// 190:     end
// 191:   end
// 192: end
