module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/release.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 39.
pub fn ruby_release_l39_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `matching_releases(name)` at line 233.
pub fn ruby_release_l233_d2_matching_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matching_releases', ...args)
}

// Ruby method `latest_matching_release(name)` at line 247.
pub fn ruby_release_l247_d3_latest_matching_release(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latest_matching_release', ...args)
}

// Ruby method `release_urls(releases)` at line 258.
pub fn ruby_release_l258_d4_release_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('release_urls', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class Release < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Create a new draft Homebrew/brew release with the appropriate version number and release notes.
// 12:
// 13:           By default, `brew release` will bump the patch version number. Pass
// 14:           `--major` or `--minor` to bump the major or minor version numbers, respectively.
// 15:           The command will fail if the previous major or minor release was made less than
// 16:           one month ago.
// 17:
// 18:           Without `--force`, this command will just output the release notes without creating
// 19:           the release or triggering the workflow.
// 20:
// 21:           *Note:* Requires write access to the Homebrew/brew repository.
// 22:         EOS
// 23:         switch "--major",
// 24:                description: "Create a major release."
// 25:         switch "--minor",
// 26:                description: "Create a minor release."
// 27:         switch "--force",
// 28:                description: "Actually create the release and trigger the workflow. Without this, just show " \
// 29:                             "what would be done."
// 30:
// 31:         conflicts "--major", "--minor"
// 32:
// 33:         named_args :none
// 34:
// 35:         hide_from_man_page!
// 36:       end
// 37:
// 38:       sig { override.void }
// 39:       def run
// 40:         safe_system "git", "-C", HOMEBREW_REPOSITORY, "fetch", "origin" if Homebrew::EnvConfig.no_auto_update?
// 41:
// 42:         require "utils/github"
// 43:
// 44:         # Keep in sync with the "Check for release blockers" step in
// 45:         # .github/workflows/release.yml.
// 46:         blocking_labels = ["release blocker"]
// 47:         blocking_labels << "major/minor release blocker" if args.major? || args.minor?
// 48:         release_blockers = blocking_labels.flat_map do |label|
// 49:           GitHub.issues(repo: "Homebrew/brew", state: "open", labels: label)
// 50:         rescue *GitHub::API::ERRORS => e
// 51:           odie "Unable to check for release blockers: #{e.message}!"
// 52:         end
// 53:         if release_blockers.present?
// 54:           blocker_urls = release_urls(release_blockers).uniq.join("\n")
// 55:           odie "Open issues or pull requests are blocking this release:\n#{blocker_urls}"
// 56:         end
// 57:
// 58:         begin
// 59:           latest_release = GitHub.get_latest_release "Homebrew", "brew"
// 60:         rescue GitHub::API::HTTPNotFoundError
// 61:           odie "No existing releases found!"
// 62:         end
// 63:         latest_version = Version.new latest_release["tag_name"]
// 64:
// 65:         if args.major? || args.minor?
// 66:           one_month_ago = Date.today << 1
// 67:           latest_major_minor_release = begin
// 68:             GitHub.get_release "Homebrew", "brew", "#{latest_version.major_minor}.0"
// 69:           rescue GitHub::API::HTTPNotFoundError
// 70:             nil
// 71:           end
// 72:
// 73:           if latest_major_minor_release.blank?
// 74:             opoo "Unable to determine the release date of the latest major/minor release."
// 75:           elsif Date.parse(latest_major_minor_release["published_at"]) > one_month_ago
// 76:             odie "The latest major/minor release was less than one month ago."
// 77:           end
// 78:         end
// 79:
// 80:         new_version = if args.major?
// 81:           Version.new "#{latest_version.major.to_i + 1}.0.0"
// 82:         elsif args.minor?
// 83:           Version.new "#{latest_version.major}.#{latest_version.minor.to_i + 1}.0"
// 84:         else
// 85:           Version.new "#{latest_version.major}.#{latest_version.minor}.#{latest_version.patch.to_i + 1}"
// 86:         end.to_s
// 87:
// 88:         if args.major? || args.minor?
// 89:           latest_major_minor_version = "#{latest_version.major}.#{latest_version.minor.to_i}.0"
// 90:           ohai "Release notes since #{latest_major_minor_version} for #{new_version} blog post:"
// 91:           # release notes without usernames, new contributors, or extra lines
// 92:           blog_post_notes = GitHub.generate_release_notes("Homebrew", "brew", new_version,
// 93:                                                           previous_tag: latest_major_minor_version)["body"]
// 94:           blog_post_notes = blog_post_notes.lines.filter_map do |line|
// 95:             next unless (match = line.match(/^\* (.*) by @[\w-]+ in (.*)$/))
// 96:
// 97:             "- [#{match[1]}](#{match[2]})"
// 98:           end.sort
// 99:           puts blog_post_notes
// 100:         end
// 101:
// 102:         ohai "Generating release notes for #{new_version}"
// 103:         release_notes = if args.major? || args.minor?
// 104:           "Release notes for this release can be found on the [Homebrew blog](https://brew.sh/blog/#{new_version}).\n"
// 105:         else
// 106:           ""
// 107:         end
// 108:         release_notes += GitHub.generate_release_notes("Homebrew", "brew", new_version,
// 109:                                                        previous_tag: latest_version.to_s)["body"]
// 110:
// 111:         puts release_notes
// 112:         puts
// 113:
// 114:         unless args.force?
// 115:           opoo "Use `brew release --force` to trigger the release workflow and create the draft release."
// 116:           return
// 117:         end
// 118:
// 119:         # Not actually useless, needed for Sorbet.
// 120:         # rubocop:disable Lint/UselessAssignment
// 121:         e = T.let(nil, T.nilable(Exception))
// 122:         # rubocop:enable Lint/UselessAssignment
// 123:
// 124:         existing_releases = begin
// 125:           matching_releases(new_version)
// 126:         rescue *GitHub::API::ERRORS => e
// 127:           odie "Unable to check existing releases: #{e.message}!"
// 128:         end
// 129:
// 130:         if existing_releases.present?
// 131:           draft_releases, published_releases = existing_releases.partition { |release| release["draft"] }
// 132:           error_message = +""
// 133:
// 134:           if draft_releases.present?
// 135:             error_message << "Draft releases already exist for #{new_version}. " \
// 136:                              "Delete them in the web interface first:\n"
// 137:             error_message << release_urls(draft_releases).join("\n")
// 138:           end
// 139:
// 140:           if published_releases.present?
// 141:             error_message << "\n" if error_message.present?
// 142:             error_message << "Published releases already exist for #{new_version}. " \
// 143:                              "Run `brew update` instead:\n"
// 144:             error_message << release_urls(published_releases).join("\n")
// 145:           end
// 146:
// 147:           odie error_message
// 148:         end
// 149:
// 150:         # Get the current commit SHA
// 151:         current_sha = Utils.safe_popen_read("git", "-C", HOMEBREW_REPOSITORY, "rev-parse", "origin/main").strip
// 152:         upstream_sha = begin
// 153:           GitHub::API.commit("Homebrew", "brew")["sha"].to_s
// 154:         rescue *GitHub::API::ERRORS => e
// 155:           odie "Unable to check upstream Homebrew/brew main: #{e.message}!"
// 156:         end
// 157:         if current_sha != upstream_sha
// 158:           odie "Local Homebrew/brew `origin/main` is not up-to-date with upstream `main`. " \
// 159:                "Run `brew update` before `brew release --force`."
// 160:         end
// 161:         release_workflow = "release.yml"
// 162:
// 163:         dispatch_time = Time.now
// 164:         ohai "Triggering release workflow for #{new_version}..."
// 165:         begin
// 166:           GitHub.workflow_dispatch_event("Homebrew", "brew", release_workflow, "main", tag: new_version)
// 167:         # Cannot use `e` as Sorbet needs it used below instead.
// 168:         # rubocop:disable Naming/RescuedExceptionsVariableName
// 169:         rescue *GitHub::API::ERRORS => error
// 170:           odie "Unable to trigger workflow: #{error.message}!"
// 171:         end
// 172:         # rubocop:enable Naming/RescuedExceptionsVariableName
// 173:
// 174:         # Poll for workflow completion
// 175:         initial_sleep_time = 15
// 176:         sleep_time = 5
// 177:         max_attempts = 180 # 15 minutes (5 seconds * 180 attempts)
// 178:         attempt = 0
// 179:         run_conclusion = T.let(nil, T.nilable(String))
// 180:
// 181:         while attempt < max_attempts
// 182:           sleep attempt.zero? ? initial_sleep_time : sleep_time
// 183:           attempt += 1
// 184:
// 185:           # Check workflow runs for the commit SHA
// 186:           begin
// 187:             runs_url = "#{GitHub::API_URL}/repos/Homebrew/brew/actions/workflows/#{release_workflow}/runs"
// 188:             response = GitHub::API.open_rest("#{runs_url}?event=workflow_dispatch&per_page=5")
// 189:             run = response["workflow_runs"]&.find do |r|
// 190:               r["head_sha"] == current_sha && Time.parse(r["created_at"]) >= dispatch_time
// 191:             end
// 192:
// 193:             if run
// 194:               if run["status"] == "completed"
// 195:                 run_conclusion = run["conclusion"]
// 196:                 puts if attempt > 1
// 197:                 break
// 198:               end
// 199:
// 200:               if attempt == 1
// 201:                 puts "This will take a few minutes. You can monitor progress at:"
// 202:                 puts "  #{Formatter.url(run["html_url"])}"
// 203:                 print "Waiting for workflow to complete..."
// 204:               else
// 205:                 print "."
// 206:               end
// 207:             else
// 208:               puts
// 209:               odie "Unable to find workflow for commit: #{current_sha}!"
// 210:             end
// 211:           rescue *GitHub::API::ERRORS => e
// 212:             puts
// 213:             odie "Unable to check workflow status: #{e.message}!"
// 214:           end
// 215:         end
// 216:
// 217:         odie "Workflow completed with status: #{run_conclusion}!" if run_conclusion != "success"
// 218:
// 219:         puts
// 220:         ohai "Release created at:"
// 221:         releases_page_url = "https://github.com/Homebrew/brew/releases"
// 222:         release_url = begin
// 223:           latest_matching_release(new_version)&.fetch("html_url", nil) || releases_page_url
// 224:         rescue *GitHub::API::ERRORS => e
// 225:           opoo "Unable to locate created release: #{e.message}"
// 226:           releases_page_url
// 227:         end
// 228:         puts "  #{Formatter.url(release_url)}"
// 229:         exec_browser release_url
// 230:       end
// 231:
// 232:       sig { params(name: String).returns(T::Array[T::Hash[String, T.untyped]]) }
// 233:       def matching_releases(name)
// 234:         releases_url = "#{GitHub::API_URL}/repos/Homebrew/brew/releases?per_page=#{GitHub::MAX_PER_PAGE}"
// 235:         releases = T.cast(GitHub::API.open_rest(releases_url,
// 236:                                                 request_method: :GET,
// 237:                                                 scopes:         GitHub::CREATE_ISSUE_FORK_OR_PR_SCOPES),
// 238:                           T::Array[T::Hash[String, T.untyped]])
// 239:         releases.select do |release|
// 240:           release_name = release["name"].to_s
// 241:           release_name = release.fetch("tag_name", "").to_s if release_name.blank?
// 242:           release_name == name
// 243:         end
// 244:       end
// 245:
// 246:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 247:       def latest_matching_release(name)
// 248:         matching_releases(name).max_by do |release|
// 249:           Time.parse(release.fetch("created_at", ""))
// 250:         rescue ArgumentError, TypeError
// 251:           Time.at(0)
// 252:         end
// 253:       end
// 254:
// 255:       private
// 256:
// 257:       sig { params(releases: T::Array[T::Hash[String, T.untyped]]).returns(T::Array[String]) }
// 258:       def release_urls(releases)
// 259:         releases.filter_map do |release|
// 260:           url = release["html_url"].to_s
// 261:           next if url.blank?
// 262:
// 263:           "  #{Formatter.url(url)}"
// 264:         end
// 265:       end
// 266:     end
// 267:   end
// 268: end
