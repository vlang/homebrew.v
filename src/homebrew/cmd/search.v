module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/search.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 67.
pub fn ruby_search_l67_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `print_missing_formula_help(query, found_matches)` at line 94.
pub fn ruby_search_l94_d2_print_missing_formula_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_missing_formula_help', ...args)
}

// Ruby method `print_regex_help` at line 111.
pub fn ruby_search_l111_d3_print_regex_help(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_regex_help', ...args)
}

// Ruby method `search_package_manager!` at line 128.
pub fn ruby_search_l128_d4_search_package_manager(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('search_package_manager!', ...args)
}

// Ruby method `search_pull_requests(query)` at line 138.
pub fn ruby_search_l138_d5_search_pull_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('search_pull_requests', ...args)
}

// Ruby method `print_results(all_formulae, all_casks, query)` at line 149.
pub fn ruby_search_l149_d6_print_results(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_results', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "missing_formula"
// 7: require "search"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class SearchCmd < AbstractCommand
// 12:       PACKAGE_MANAGERS = T.let({
// 13:         alpine:    ->(query) { "https://pkgs.alpinelinux.org/packages?name=#{query}" },
// 14:         repology:  ->(query) { "https://repology.org/projects/?search=#{query}" },
// 15:         macports:  ->(query) { "https://ports.macports.org/search/?q=#{query}" },
// 16:         fink:      ->(query) { "https://pdb.finkproject.org/pdb/browse.php?summary=#{query}" },
// 17:         opensuse:  ->(query) { "https://software.opensuse.org/search?q=#{query}" },
// 18:         fedora:    ->(query) { "https://packages.fedoraproject.org/search?query=#{query}" },
// 19:         archlinux: ->(query) { "https://archlinux.org/packages/?q=#{query}" },
// 20:         debian:    lambda { |query|
// 21:           "https://packages.debian.org/search?keywords=#{query}&searchon=names&suite=all&section=all"
// 22:         },
// 23:         ubuntu:    lambda { |query|
// 24:           "https://packages.ubuntu.com/search?keywords=#{query}&searchon=names&suite=all&section=all"
// 25:         },
// 26:       }.freeze, T::Hash[Symbol, T.proc.params(query: String).returns(String)])
// 27:
// 28:       cmd_args do
// 29:         description <<~EOS
// 30:           Perform a substring search of cask tokens and formula names for <text>. If <text>
// 31:           is flanked by slashes, it is interpreted as a regular expression.
// 32:         EOS
// 33:         switch "--formula", "--formulae",
// 34:                description: "Search for formulae."
// 35:         switch "--cask", "--casks",
// 36:                description: "Search for casks."
// 37:         switch "--desc",
// 38:                description: "Search for formulae with a description matching <text> and casks with " \
// 39:                             "a name or description matching <text>."
// 40:         switch "--eval-all",
// 41:                description: "Evaluate all available formulae and casks, whether installed or not, to search their " \
// 42:                             "descriptions.",
// 43:                env:         :eval_all,
// 44:                odeprecated: true
// 45:         switch "--pull-request",
// 46:                description: "Search for GitHub pull requests containing <text>."
// 47:         switch "--open",
// 48:                depends_on:  "--pull-request",
// 49:                description: "Search for only open GitHub pull requests."
// 50:         switch "--closed",
// 51:                depends_on:  "--pull-request",
// 52:                description: "Search for only closed GitHub pull requests."
// 53:         package_manager_switches = PACKAGE_MANAGERS.keys.map { |name| "--#{name}" }
// 54:         package_manager_switches.each do |s|
// 55:           switch s,
// 56:                  description: "Search for <text> in the given database."
// 57:         end
// 58:
// 59:         conflicts "--desc", "--pull-request"
// 60:         conflicts "--open", "--closed"
// 61:         conflicts(*package_manager_switches)
// 62:
// 63:         named_args :text_or_regex, min: 1
// 64:       end
// 65:
// 66:       sig { override.void }
// 67:       def run
// 68:         return if search_package_manager!
// 69:
// 70:         query = args.named.join(" ")
// 71:         string_or_regex = Search.query_regexp(query)
// 72:
// 73:         if args.desc?
// 74:           if !args.eval_all? && !Homebrew::EnvConfig.tap_trust_configured? && Homebrew::EnvConfig.no_install_from_api?
// 75:             raise UsageError,
// 76:                   "`brew search --desc` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 77:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 78:           end
// 79:
// 80:           Search.search_descriptions(string_or_regex, args, show_missing: true)
// 81:         elsif args.pull_request?
// 82:           search_pull_requests(query)
// 83:         else
// 84:           formulae, casks = Search.search_names(string_or_regex, args)
// 85:           print_results(formulae, casks, query)
// 86:         end
// 87:
// 88:         puts "Use `brew desc` to list packages with a short description." if args.verbose?
// 89:
// 90:         print_regex_help
// 91:       end
// 92:
// 93:       sig { params(query: String, found_matches: T::Boolean).void }
// 94:       def print_missing_formula_help(query, found_matches)
// 95:         return unless $stdout.tty?
// 96:         return if query.match?(Search::QUERY_REGEX)
// 97:
// 98:         reason = MissingFormula.reason(query, silent: true)
// 99:         return if reason.nil?
// 100:
// 101:         if found_matches
// 102:           puts
// 103:           puts "If you meant #{query.inspect} specifically:"
// 104:         end
// 105:         puts reason
// 106:       end
// 107:
// 108:       private
// 109:
// 110:       sig { void }
// 111:       def print_regex_help
// 112:         return unless $stdout.tty?
// 113:
// 114:         metacharacters = %w[\\ | ( ) [ ] { } ^ $ * + ?].freeze
// 115:         return unless metacharacters.any? do |char|
// 116:           args.named.any? do |arg|
// 117:             arg.include?(char) && !arg.start_with?("/")
// 118:           end
// 119:         end
// 120:
// 121:         opoo <<~EOS
// 122:           Did you mean to perform a regular expression search?
// 123:           Surround your query with /slashes/ to search locally by regex.
// 124:         EOS
// 125:       end
// 126:
// 127:       sig { returns(T::Boolean) }
// 128:       def search_package_manager!
// 129:         package_manager = PACKAGE_MANAGERS.find { |name,| args.public_send(:"#{name}?") }
// 130:         return false if package_manager.nil?
// 131:
// 132:         _, url = package_manager
// 133:         exec_browser url.call(URI.encode_www_form_component(args.named.join(" ")))
// 134:         true
// 135:       end
// 136:
// 137:       sig { params(query: String).void }
// 138:       def search_pull_requests(query)
// 139:         only = if args.open? && !args.closed?
// 140:           "open"
// 141:         elsif args.closed? && !args.open?
// 142:           "closed"
// 143:         end
// 144:
// 145:         GitHub.print_pull_requests_matching(query, only)
// 146:       end
// 147:
// 148:       sig { params(all_formulae: T::Array[String], all_casks: T::Array[String], query: String).void }
// 149:       def print_results(all_formulae, all_casks, query)
// 150:         count = all_formulae.size + all_casks.size
// 151:
// 152:         if all_formulae.any?
// 153:           if $stdout.tty?
// 154:             ohai "Formulae", Formatter.columns(all_formulae)
// 155:           else
// 156:             puts all_formulae
// 157:           end
// 158:         end
// 159:         puts if all_formulae.any? && all_casks.any?
// 160:         if all_casks.any?
// 161:           if $stdout.tty?
// 162:             ohai "Casks", Formatter.columns(all_casks)
// 163:           else
// 164:             puts all_casks
// 165:           end
// 166:         end
// 167:
// 168:         print_missing_formula_help(query, count.positive?) if all_casks.exclude?(query)
// 169:
// 170:         odie "No formulae or casks found for #{query.inspect}." if count.zero?
// 171:       end
// 172:     end
// 173:   end
// 174: end
