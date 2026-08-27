module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/tap-new.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 36.
pub fn ruby_tap_new_l36_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `render_workflow_template(filename, branch:, github_packages:, root_url: nil)` at line 150.
pub fn ruby_tap_new_l150_d2_render_workflow_template(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('render_workflow_template', ...args)
}

// Ruby method `write_path(tap, filename, content)` at line 186.
pub fn ruby_tap_new_l186_d3_write_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "system_command"
// 7: require "tap"
// 8: require "utils/uid"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class TapNew < AbstractCommand
// 13:       include FileUtils
// 14:       include SystemCommand::Mixin
// 15:
// 16:       cmd_args do
// 17:         usage_banner "`tap-new` [<options>] <user>`/`<repo>"
// 18:         description <<~EOS
// 19:           Generate the template files for a new tap.
// 20:         EOS
// 21:         switch "--no-git",
// 22:                description: "Don't initialise a Git repository for the tap."
// 23:         flag   "--pull-label=",
// 24:                description: "Ignored; publishing pull requests is now manually dispatched.",
// 25:                odeprecated: true
// 26:         flag   "--branch=",
// 27:                description: "Initialise a Git repository and set up GitHub Actions workflows with the " \
// 28:                             "specified branch name (default: `main`)."
// 29:         switch "--github-packages",
// 30:                description: "Upload bottles to GitHub Packages."
// 31:
// 32:         named_args :tap, number: 1
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         branch = args.branch || "main"
// 38:
// 39:         tap = args.named.to_taps.fetch(0)
// 40:         odie "Invalid tap name '#{tap}'" unless tap.path.to_s.match?(HOMEBREW_TAP_PATH_REGEX)
// 41:         odie "Tap is already installed!" if tap.installed?
// 42:
// 43:         titleized_user = tap.user.dup
// 44:         titleized_repository = tap.repository.dup
// 45:         titleized_user[0] = T.must(titleized_user[0]).upcase
// 46:         titleized_repository[0] = T.must(titleized_repository[0]).upcase
// 47:         root_url = GitHubPackages.root_url(tap.user, "homebrew-#{tap.repository}") if args.github_packages?
// 48:
// 49:         (tap.path/"Formula").mkpath
// 50:
// 51:         readme = <<~MARKDOWN
// 52:           # #{titleized_user} #{titleized_repository}
// 53:
// 54:           ## How do I install these formulae?
// 55:
// 56:           `brew install #{tap}/<formula>`
// 57:
// 58:           Or `brew tap #{tap}` and then `brew install <formula>`.
// 59:
// 60:           Or, in a `brew bundle` `Brewfile`:
// 61:
// 62:           ```ruby
// 63:           tap "#{tap}"
// 64:           brew "<formula>"
// 65:           ```
// 66:
// 67:           ## Documentation
// 68:
// 69:           `brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
// 70:         MARKDOWN
// 71:         write_path(tap, "README.md", readme)
// 72:
// 73:         dependabot_yml = <<~YAML
// 74:           version: 2
// 75:           updates:
// 76:             - package-ecosystem: github-actions
// 77:               directory: "/"
// 78:               schedule:
// 79:                 interval: weekly
// 80:               groups:
// 81:                 github-actions:
// 82:                   patterns:
// 83:                     - "*"
// 84:         YAML
// 85:
// 86:         tests_yml = render_workflow_template(
// 87:           "tap-new-tests.yml", branch:, github_packages: args.github_packages?, root_url:
// 88:         )
// 89:         publish_yml = render_workflow_template(
// 90:           "tap-new-publish.yml", branch:, github_packages: args.github_packages?
// 91:         )
// 92:         autobump_yml = render_workflow_template(
// 93:           "tap-new-autobump.yml", branch:, github_packages: args.github_packages?
// 94:         )
// 95:         (tap.path/".github/workflows").mkpath
// 96:         write_path(tap, ".github/dependabot.yml", dependabot_yml)
// 97:         write_path(tap, ".github/workflows/tests.yml", tests_yml)
// 98:         write_path(tap, ".github/workflows/publish.yml", publish_yml)
// 99:         write_path(tap, ".github/workflows/autobump.yml", autobump_yml)
// 100:
// 101:         unless args.no_git?
// 102:           cd tap.path do |path|
// 103:             Utils::Git.set_name_email!
// 104:             Utils::Git.setup_gpg!
// 105:
// 106:             safe_system "git", "init", "--initial-branch=#{branch}"
// 107:
// 108:             args = []
// 109:             git_owner = File.stat(File.join(path, ".git")).uid
// 110:             if git_owner != Process.uid && git_owner == Process.euid
// 111:               # Under Homebrew user model, EUID is permitted to execute commands under the UID.
// 112:               # Root users are never allowed (see brew.sh).
// 113:               args << "-c" << "safe.directory=#{path}"
// 114:             end
// 115:
// 116:             # Use the configuration of the original user, which will have author information and signing keys.
// 117:             env = { "HOME" => Utils::UID.uid_home }.compact
// 118:             env["TMPDIR"] = nil if (tmpdir = ENV.fetch("TMPDIR", nil)) && !File.writable_real?(tmpdir)
// 119:             system_command!("git", args: [*args, "add", "--all"], env:,
// 120:                             print_stdout: true, run_as_real_uid: true)
// 121:             system_command!("git", args: [*args, "commit", "-m", "Create #{tap} tap"], env:,
// 122:                             print_stdout: true, run_as_real_uid: true)
// 123:             system_command!("git", args: [*args, "branch", "-m", branch], env:,
// 124:                             print_stdout: true, run_as_real_uid: true)
// 125:           end
// 126:         end
// 127:
// 128:         ohai "Created #{tap}"
// 129:         puts <<~EOS
// 130:           #{tap.path}
// 131:
// 132:           When a pull request making changes to a formula (or formulae) becomes green
// 133:           (all checks passed), then you can publish the built bottles.
// 134:           To do so, run `brew pr-pull` locally or run the `brew pr-pull`
// 135:           workflow with the pull request number and, optionally, the pull
// 136:           request's expected head commit SHA.
// 137:         EOS
// 138:       end
// 139:
// 140:       private
// 141:
// 142:       sig {
// 143:         params(
// 144:           filename:        String,
// 145:           branch:          String,
// 146:           github_packages: T::Boolean,
// 147:           root_url:        T.nilable(String),
// 148:         ).returns(String)
// 149:       }
// 150:       def render_workflow_template(filename, branch:, github_packages:, root_url: nil)
// 151:         workflow = (HOMEBREW_LIBRARY_PATH.parent.parent/".github/workflows"/filename).read
// 152:         workflow.sub!("name: tap-new tests template", "name: brew test-bot")
// 153:         workflow.sub!("name: tap-new publish template", "name: brew pr-pull")
// 154:         workflow.sub!("name: tap-new autobump template", "name: brew bump")
// 155:         if filename == "tap-new-tests.yml"
// 156:           workflow.sub!("on:\n  workflow_dispatch:\n", <<~YAML)
// 157:             on:
// 158:               push:
// 159:                 branches:
// 160:                   - #{branch}
// 161:               pull_request:
// 162:           YAML
// 163:         end
// 164:         # Pick a random 5 minute block in which to execute the autobump action to avoid peak GitHub loads
// 165:         hour = Random.rand(24)
// 166:         minute = Random.rand(12) * 5
// 167:         workflow.gsub!("this will be changed later and randomised by brew tap-new") do
// 168:           "Every day at #{hour}:#{minute} UTC"
// 169:         end
// 170:         workflow.gsub!("\"1 1 1 1 1\"") { "#{minute} #{hour} * * *" }
// 171:
// 172:         workflow.sub!("    if: github.repository == ''\n", "")
// 173:         workflow.gsub!("TAP_NEW_BRANCH") { branch }
// 174:         workflow.gsub!("TAP_NEW_ROOT_URL_ARGUMENT") { root_url ? " --root-url=#{root_url}" : "" }
// 175:         unless github_packages
// 176:           workflow.gsub!(
// 177:             /^[ \t]*# tap-new-github-packages-start\n.*?^[ \t]*# tap-new-github-packages-end\n/m,
// 178:             "",
// 179:           )
// 180:         end
// 181:         workflow.gsub!(/^[ \t]*# tap-new-github-packages-(?:start|end)\n/, "")
// 182:         workflow
// 183:       end
// 184:
// 185:       sig { params(tap: Tap, filename: T.any(String, Pathname), content: String).void }
// 186:       def write_path(tap, filename, content)
// 187:         path = tap.path/filename
// 188:         tap.path.mkpath
// 189:         odie "#{path} already exists" if path.exist?
// 190:
// 191:         path.write content
// 192:       end
// 193:     end
// 194:   end
// 195: end
