module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/doctor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 35.
pub fn ruby_doctor_l35_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "diagnostic"
// 6: require "diagnostic/finding"
// 7: require "cask/caskroom"
// 8: require "json"
// 9:
// 10: module Homebrew
// 11:   module Cmd
// 12:     class Doctor < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Check your system for potential problems. Will exit with a non-zero status
// 16:           if any potential problems are found.
// 17:
// 18:           Please note that these warnings are just used to help the Homebrew maintainers
// 19:           with debugging if you file an issue. If everything you use Homebrew for
// 20:           is working fine: please don't worry or file an issue; just ignore this.
// 21:         EOS
// 22:         switch "--list-checks",
// 23:                description: "List all audit methods, which can be run individually " \
// 24:                             "if provided as arguments."
// 25:         switch "--json",
// 26:                description: "Print a JSON representation.",
// 27:                hidden:      true
// 28:         switch "-D", "--audit-debug",
// 29:                description: "Enable debugging and profiling of audit methods."
// 30:
// 31:         named_args :diagnostic_check
// 32:       end
// 33:
// 34:       sig { override.void }
// 35:       def run
// 36:         Homebrew.inject_dump_stats!(Diagnostic::Checks, /^check_*/) if args.audit_debug?
// 37:
// 38:         checks = Diagnostic::Checks.new(verbose: args.verbose?)
// 39:
// 40:         if args.list_checks?
// 41:           puts checks.all
// 42:           return
// 43:         end
// 44:
// 45:         if args.no_named?
// 46:           slow_checks = %w[
// 47:             check_for_broken_symlinks
// 48:             check_missing_deps
// 49:           ]
// 50:           methods = (checks.all - slow_checks) + slow_checks
// 51:           methods -= checks.cask_checks unless Cask::Caskroom.any_casks_installed?
// 52:         else
// 53:           methods = args.named
// 54:         end
// 55:
// 56:         finding_collection = []
// 57:         first_warning = T.let(true, T::Boolean)
// 58:         methods.each do |method|
// 59:           $stderr.puts Formatter.headline("Checking #{method}", color: :magenta) if args.debug?
// 60:           unless checks.respond_to?(method)
// 61:             ofail "No check available by the name: #{method}"
// 62:             next
// 63:           end
// 64:
// 65:           finding         = checks.public_send(method)
// 66:           method_findings = T.let(Array(finding).compact, T::Array[T.any(Diagnostic::Finding, String)])
// 67:           next if method_findings.empty?
// 68:
// 69:           finding_collection.concat(method_findings.compact)
// 70:           Homebrew.failed = true
// 71:           next if args.json?
// 72:
// 73:           if first_warning && !args.quiet?
// 74:             $stderr.puts <<~EOS
// 75:               #{Tty.bold}Please note that these warnings are just used to help the Homebrew maintainers
// 76:               with debugging if you file an issue. If everything you use Homebrew for is
// 77:               working fine: please don't worry or file an issue; just ignore this. Thanks!#{Tty.reset}
// 78:             EOS
// 79:           end
// 80:
// 81:           $stderr.puts
// 82:           opoo method_findings.each(&:to_s).join("\n")
// 83:           first_warning = false
// 84:         end
// 85:
// 86:         # TODO: Remove string filtering when all diagnostics are Finding objects
// 87:         finding_maps = finding_collection.grep_v(String).map(&:to_h)
// 88:         tier = (finding_maps.max_by { |f| f[:tier] } || {}).fetch(:tier, 1)
// 89:         if args.json?
// 90:           puts JSON.pretty_generate({ tier:, findings: finding_maps }).gsub(/\[\n\n\s*\]/, "[]")
// 91:
// 92:           return
// 93:         end
// 94:
// 95:         return if args.quiet?
// 96:
// 97:         if Homebrew.failed?
// 98:           puts Diagnostic::Finding.support_tier_message(tier:)
// 99:         else
// 100:           puts "Your system is ready to brew."
// 101:         end
// 102:       end
// 103:     end
// 104:   end
// 105: end
