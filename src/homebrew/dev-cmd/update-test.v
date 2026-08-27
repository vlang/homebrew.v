module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/update-test.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 30.
pub fn ruby_update_test_l30_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `git_tags` at line 146.
pub fn ruby_update_test_l146_d2_git_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('git_tags', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class UpdateTest < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Run a test of `brew update` with a new repository clone.
// 15:           If no options are passed, use `origin/main` as the start commit.
// 16:         EOS
// 17:         switch "--to-tag",
// 18:                description: "Set `$HOMEBREW_UPDATE_TO_TAG` to test updating between tags."
// 19:         switch "--keep-tmp",
// 20:                description: "Retain the temporary directory containing the new repository clone."
// 21:         flag   "--commit=",
// 22:                description: "Use the specified <commit> as the start commit."
// 23:         flag   "--before=",
// 24:                description: "Use the commit at the specified <date> as the start commit."
// 25:
// 26:         named_args :none
// 27:       end
// 28:
// 29:       sig { override.void }
// 30:       def run
// 31:         # Avoid `update-report.rb` tapping Homebrew/homebrew-core
// 32:         ENV["HOMEBREW_UPDATE_TEST"] = "1"
// 33:
// 34:         # Avoid accidentally updating when we don't expect it.
// 35:         ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
// 36:
// 37:         # Use default behaviours
// 38:         ENV["HOMEBREW_AUTO_UPDATE_SECS"] = nil
// 39:         ENV["HOMEBREW_DEVELOPER"] = nil
// 40:         ENV["HOMEBREW_DEV_CMD_RUN"] = nil
// 41:         ENV["HOMEBREW_MERGE"] = nil
// 42:         ENV["HOMEBREW_NO_UPDATE_CLEANUP"] = nil
// 43:         ENV["HOMEBREW_UPDATE_TO_TAG"] = nil
// 44:
// 45:         branch = if args.to_tag?
// 46:           ENV["HOMEBREW_UPDATE_TO_TAG"] = "1"
// 47:           "stable"
// 48:         else
// 49:           ENV["HOMEBREW_DEV_CMD_RUN"] = "1"
// 50:           "main"
// 51:         end
// 52:
// 53:         # Utils.popen_read returns a String without a block argument, but that isn't easily typed. We thus label this
// 54:         # as untyped for now.
// 55:         start_commit = T.let("", T.untyped)
// 56:         end_commit = "HEAD"
// 57:         cd HOMEBREW_REPOSITORY do
// 58:           start_commit = if (commit = args.commit)
// 59:             commit
// 60:           elsif (date = args.before)
// 61:             Utils.popen_read("git", "rev-list", "-n1", "--before=#{date}", "origin/main").chomp
// 62:           elsif args.to_tag?
// 63:             tags = git_tags
// 64:             current_tag, previous_tag, = tags.lines
// 65:             current_tag = current_tag.to_s.chomp
// 66:             odie "Could not find current tag in:\n#{tags}" if current_tag.empty?
// 67:             # ^0 ensures this points to the commit rather than the tag object.
// 68:             end_commit = "#{current_tag}^0"
// 69:
// 70:             previous_tag = previous_tag.to_s.chomp
// 71:             odie "Could not find previous tag in:\n#{tags}" if previous_tag.empty?
// 72:             # ^0 ensures this points to the commit rather than the tag object.
// 73:             "#{previous_tag}^0"
// 74:           else
// 75:             Utils.popen_read("git", "merge-base", "origin/main", end_commit).chomp
// 76:           end
// 77:           odie "Could not find start commit!" if start_commit.empty?
// 78:
// 79:           start_commit = Utils.popen_read("git", "rev-parse", start_commit).chomp
// 80:           odie "Could not find start commit!" if start_commit.empty?
// 81:
// 82:           end_commit = Utils.popen_read("git", "rev-parse", end_commit).chomp
// 83:           odie "Could not find end commit!" if end_commit.empty?
// 84:
// 85:           if Utils.popen_read("git", "branch", "--list", "main").blank?
// 86:             safe_system "git", "branch", "main", "origin/HEAD"
// 87:           end
// 88:         end
// 89:
// 90:         puts <<~EOS
// 91:           Start commit: #{start_commit}
// 92:             End commit: #{end_commit}
// 93:         EOS
// 94:
// 95:         mkdir "update-test"
// 96:         chdir "update-test" do
// 97:           curdir = Pathname.new(Dir.pwd)
// 98:
// 99:           oh1 "Preparing test environment..."
// 100:           # copy Homebrew installation
// 101:           safe_system "git", "clone", "#{HOMEBREW_REPOSITORY}/.git", ".",
// 102:                       "--branch", "main", "--single-branch"
// 103:
// 104:           # set git origin to another copy
// 105:           safe_system "git", "clone", "#{HOMEBREW_REPOSITORY}/.git", "remote.git",
// 106:                       "--bare", "--branch", "main", "--single-branch"
// 107:           safe_system "git", "config", "remote.origin.url", "#{curdir}/remote.git"
// 108:           ENV["HOMEBREW_BREW_GIT_REMOTE"] = "#{curdir}/remote.git"
// 109:
// 110:           # force push origin to end_commit
// 111:           safe_system "git", "checkout", "-B", "main", end_commit
// 112:           safe_system "git", "push", "--force", "origin", "main"
// 113:
// 114:           # set test copy to start_commit
// 115:           safe_system "git", "reset", "--hard", start_commit
// 116:
// 117:           # update ENV["PATH"]
// 118:           ENV["PATH"] = PATH.new(ENV.fetch("PATH")).prepend(curdir/"bin").to_s
// 119:
// 120:           # Run `brew help` to install `portable-ruby` (if needed).
// 121:           quiet_system "brew", "help"
// 122:
// 123:           # run brew update
// 124:           oh1 "Running `brew update`..."
// 125:           safe_system "brew", "update", "--verbose", "--debug"
// 126:           actual_end_commit = Utils.popen_read("git", "rev-parse", branch).chomp
// 127:           if actual_end_commit != end_commit
// 128:             start_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", start_commit).chomp
// 129:             end_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", end_commit).chomp
// 130:             actual_log = Utils.popen_read("git", "log", "-1", "--decorate", "--oneline", actual_end_commit).chomp
// 131:             odie <<~EOS
// 132:               `brew update` didn't update #{branch}!
// 133:               Start commit:        #{start_log}
// 134:               Expected end commit: #{end_log}
// 135:               Actual end commit:   #{actual_log}
// 136:             EOS
// 137:           end
// 138:         end
// 139:       ensure
// 140:         FileUtils.rm_rf "update-test" unless args.keep_tmp?
// 141:       end
// 142:
// 143:       private
// 144:
// 145:       sig { returns(String) }
// 146:       def git_tags
// 147:         tags = Utils.popen_read("git", "tag", "--list", "--sort=-version:refname")
// 148:         if tags.blank?
// 149:           tags = if (HOMEBREW_REPOSITORY/".git/shallow").exist?
// 150:             safe_system "git", "fetch", "--tags", "--depth=1"
// 151:             Utils.popen_read("git", "tag", "--list", "--sort=-version:refname")
// 152:           end
// 153:         end
// 154:         odie "Could not find git tags!" if tags.blank?
// 155:         tags
// 156:       end
// 157:     end
// 158:   end
// 159: end
// 160:
// 161: require "extend/os/dev-cmd/update-test"
