module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/dispatch-build-bottle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 43.
pub fn ruby_dispatch_build_bottle_l43_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6: require "utils/bottles"
// 7: require "utils/github"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class DispatchBuildBottle < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Build bottles for these formulae with GitHub Actions.
// 15:         EOS
// 16:         flag   "--tap=",
// 17:                description: "Target tap repository (default: `homebrew/core`)."
// 18:         flag   "--timeout=",
// 19:                description: "Build timeout (in minutes, default: 60)."
// 20:         flag   "--issue=",
// 21:                description: "If specified, post a comment to this issue number if the job fails."
// 22:         comma_array "--macos",
// 23:                     description: "macOS version (or comma-separated list of versions) the bottle should be built for."
// 24:         flag   "--workflow=",
// 25:                description: "Dispatch specified workflow (default: `dispatch-build-bottle.yml`)."
// 26:         switch "--upload",
// 27:                description: "Upload built bottles."
// 28:         switch "--linux",
// 29:                description: "Dispatch bottle for Linux x86_64 (using GitHub runners)."
// 30:         switch "--linux-arm64",
// 31:                description: "Dispatch bottle for Linux arm64 (using GitHub runners)."
// 32:         switch "--linux-self-hosted",
// 33:                description: "Dispatch bottle for Linux x86_64 (using self-hosted runner)."
// 34:
// 35:         conflicts "--linux", "--linux-self-hosted"
// 36:
// 37:         named_args :formula, min: 1
// 38:
// 39:         hide_from_man_page!
// 40:       end
// 41:
// 42:       sig { override.void }
// 43:       def run
// 44:         tap = Tap.fetch(args.tap || CoreTap.instance.name)
// 45:         user, repo = tap.full_name.split("/")
// 46:         raise "Unexpected tap name: #{tap.full_name}" if user.nil? || repo.nil?
// 47:
// 48:         ref = "main"
// 49:         workflow = args.workflow || "dispatch-build-bottle.yml"
// 50:
// 51:         runners = []
// 52:
// 53:         if (macos = args.macos&.compact_blank) && macos.present?
// 54:           runners += macos.map do |element|
// 55:             # We accept runner name syntax (11-arm64) or bottle syntax (arm64_big_sur)
// 56:             os, arch = element.then do |s|
// 57:               tag = Utils::Bottles::Tag.from_symbol(s.to_sym)
// 58:               [tag.to_macos_version, tag.arch]
// 59:             rescue ArgumentError, MacOSVersion::Error
// 60:               os, arch = s.split("-", 2)
// 61:               [MacOSVersion.new(os), arch&.to_sym]
// 62:             end
// 63:
// 64:             if arch.present? && arch != :x86_64
// 65:               "#{os}-#{arch}"
// 66:             else
// 67:               os.to_s
// 68:             end
// 69:           end
// 70:         end
// 71:
// 72:         if args.linux?
// 73:           runners << "ubuntu-latest"
// 74:         elsif args.linux_self_hosted?
// 75:           runners << "linux-self-hosted-1"
// 76:         end
// 77:
// 78:         runners << OS::LINUX_CI_ARM_RUNNER if args.linux_arm64?
// 79:
// 80:         if runners.empty?
// 81:           raise UsageError, "Must specify `--macos`, `--linux`, `--linux-arm64`, or `--linux-self-hosted` option."
// 82:         end
// 83:
// 84:         args.named.to_resolved_formulae.each do |formula|
// 85:           # Required inputs
// 86:           inputs = {
// 87:             runner:  runners.join(","),
// 88:             formula: formula.name,
// 89:           }
// 90:
// 91:           # Optional inputs
// 92:           # These cannot be passed as nil to GitHub API
// 93:           inputs[:timeout] = args.timeout if args.timeout
// 94:           inputs[:issue] = args.issue if args.issue
// 95:           inputs[:upload] = args.upload?
// 96:
// 97:           ohai "Dispatching #{tap} bottling request of formula \"#{formula.name}\" for #{runners.join(", ")}"
// 98:           GitHub.workflow_dispatch_event(user, repo, workflow, ref, **inputs)
// 99:         end
// 100:       end
// 101:     end
// 102:   end
// 103: end
