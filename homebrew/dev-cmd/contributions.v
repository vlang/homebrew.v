module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/contributions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 98.
pub fn ruby_contributions_l98_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `maintainer_report_users(repository_refs, to)` at line 241.
pub fn ruby_contributions_l241_d2_maintainer_report_users(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('maintainer_report_users', ...args)
}

// Ruby method `maintainer_since(repository_path, ref, user, name)` at line 298.
pub fn ruby_contributions_l298_d3_maintainer_since(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('maintainer_since', ...args)
}

// Ruby method `scan_contributions(organisation, repositories, repository_refs, users, from:, to:,` at line 335.
pub fn ruby_contributions_l335_d4_scan_contributions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scan_contributions', ...args)
}

// Ruby method `github_username_for(user, to:)` at line 471.
pub fn ruby_contributions_l471_d5_github_username_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_username_for', ...args)
}

// Ruby method `github_search_with_rate_limit(cache_key, to:, &block)` at line 498.
pub fn ruby_contributions_l498_d6_github_search_with_rate_limit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('github_search_with_rate_limit', ...args)
}

// Ruby method `parse_git_log(output, users, authored_pull_requests: nil, merged_pull_requests: nil)` at line 532.
pub fn ruby_contributions_l532_d7_parse_git_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_git_log', ...args)
}

// Ruby method `generate_maintainer_report_csv(results, grand_totals, user_names, lead_maintainers, maintainer_since_dates,` at line 620.
pub fn ruby_contributions_l620_d8_generate_maintainer_report_csv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_maintainer_report_csv', ...args)
}

// Ruby method `prepare_contribution_repositories(repositories, required:)` at line 693.
pub fn ruby_contributions_l693_d9_prepare_contribution_repositories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prepare_contribution_repositories', ...args)
}

// Ruby method `readme_mentions?(readme, user, name)` at line 723.
pub fn ruby_contributions_l723_d10_readme_mentions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('readme_mentions?', ...args)
}

// Ruby method `add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_requests)` at line 735.
pub fn ruby_contributions_l735_d11_add_merged_pull_request_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_merged_pull_request_id', ...args)
}

// Ruby method `update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_requests)` at line 751.
pub fn ruby_contributions_l751_d12_update_merged_pull_request_counts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_merged_pull_request_counts', ...args)
}

// Ruby method `user_for_git_identity(name, email, identity_users)` at line 763.
pub fn ruby_contributions_l763_d13_user_for_git_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('user_for_git_identity', ...args)
}

// Ruby method `increment_contribution_count(counts, type)` at line 770.
pub fn ruby_contributions_l770_d14_increment_contribution_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('increment_contribution_count', ...args)
}

// Ruby method `repository_path_and_tap(repository)` at line 776.
pub fn ruby_contributions_l776_d15_repository_path_and_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository_path_and_tap', ...args)
}

// Ruby method `time_period(from:, to:)` at line 788.
pub fn ruby_contributions_l788_d16_time_period(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('time_period', ...args)
}

// Ruby method `generate_csv(totals)` at line 801.
pub fn ruby_contributions_l801_d17_generate_csv(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_csv', ...args)
}

// Ruby method `grand_total_row(user, grand_total)` at line 815.
pub fn ruby_contributions_l815_d18_grand_total_row(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('grand_total_row', ...args)
}

// Ruby method `total(results)` at line 822.
pub fn ruby_contributions_l822_d19_total(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('total', ...args)
}

// Ruby method `contribution_count(contributions)` at line 836.
pub fn ruby_contributions_l836_d20_contribution_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contribution_count', ...args)
}

// Ruby method `lead_activity_met?(repositories)` at line 841.
pub fn ruby_contributions_l841_d21_lead_activity_met(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lead_activity_met?', ...args)
}

// Ruby method `reporting_quarter_dates(quarter, current_year = Date.today.year)` at line 848.
pub fn ruby_contributions_l848_d22_reporting_quarter_dates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reporting_quarter_dates', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "digest"
// 6: require "json"
// 7: require "system_command"
// 8: require "tap"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Contributions < AbstractCommand
// 13:       include SystemCommand::Mixin
// 14:
// 15:       PRIMARY_REPOS = %w[
// 16:         Homebrew/brew
// 17:         Homebrew/homebrew-core
// 18:         Homebrew/homebrew-cask
// 19:       ].freeze
// 20:       CONTRIBUTION_TYPES = T.let({
// 21:         merged_pr_author:   "merged PRs authored",
// 22:         merged_pr_merger:   "PRs merged",
// 23:         merged_pr:          "qualifying merged PRs",
// 24:         approved_pr_review: "approved-review search matches",
// 25:         coauthor:           "co-authored commits",
// 26:       }.freeze, T::Hash[Symbol, String])
// 27:       MAX_PR_SEARCH = 100
// 28:       # https://docs.brew.sh/Homebrew-Governance#maintainer
// 29:       MAINTAINER_ACTIVITY_THRESHOLD = 50
// 30:       # https://docs.brew.sh/Homebrew-Governance#lead-maintainer
// 31:       LEAD_REPOSITORY_ACTIVITY_THRESHOLD = 25
// 32:       MAX_CONTRIBUTIONS = T.let(MAINTAINER_ACTIVITY_THRESHOLD * 10, Integer)
// 33:       QUALIFYING_CONTRIBUTION_TYPES = [:merged_pr, :approved_pr_review, :coauthor].freeze
// 34:
// 35:       cmd_args do
// 36:         usage_banner "`contributions` [`--user=`] [`--repositories=`] [`--quarter=`] [`--from=`] [`--to=`] " \
// 37:                      "[`--csv`] [`--maintainer-report-csv=`]"
// 38:         description <<~EOS
// 39:           Summarise contributions to Homebrew repositories.
// 40:         EOS
// 41:         comma_array "--user=",
// 42:                     description: "Specify a comma-separated list of GitHub usernames or email addresses to find " \
// 43:                                  "contributions from. Omitting this flag searches Homebrew maintainers and " \
// 44:                                  "requires access to the `Homebrew/maintainers` team. " \
// 45:                                  "With `--maintainer-report-csv`, only matching quarter-end Maintainers are included."
// 46:         comma_array "--repositories",
// 47:                     description: "Specify a comma-separated list of repositories to search. " \
// 48:                                  "All repositories must be under the same user or organisation. " \
// 49:                                  "Omitting this flag, or specifying `--repositories=primary`, searches only the " \
// 50:                                  "main repositories: `Homebrew/brew`, `Homebrew/homebrew-core`, " \
// 51:                                  "`Homebrew/homebrew-cask`."
// 52:         flag   "--organisation=", "--organization=", "--org=",
// 53:                description: "Specify the organisation to populate sources repositories from. " \
// 54:                             "Omitting this flag searches the Homebrew primary repositories."
// 55:         flag   "--team=",
// 56:                description: "Specify the team to populate users from. " \
// 57:                             "The first part of the team name will be used as the organisation."
// 58:         flag   "--quarter=",
// 59:                description: "Homebrew contributions quarter to search (1-4). " \
// 60:                             "Omitting this flag searches the past year. " \
// 61:                             "If `--from` or `--to` are set, they take precedence."
// 62:         flag   "--from=",
// 63:                description: "Date (ISO 8601 format) to start searching contributions. " \
// 64:                             "Omitting this flag searches the past year."
// 65:         flag   "--to=",
// 66:                description: "Date (ISO 8601 format) to stop searching contributions."
// 67:         switch "--csv",
// 68:                description: "Print a CSV of contributions across repositories over the time period."
// 69:         flag   "--maintainer-report-csv=",
// 70:                description: "Print a CSV of Maintainer and Lead Maintainer activity criteria using fetched Git " \
// 71:                             "histories and GitHub's existing approved-review search for the Homebrew " \
// 72:                             "governance quarter, for example " \
// 73:                             "`--maintainer-report-csv=2026-2`. " \
// 74:                             "Also write it in the current directory as `brew-contributions-FROM-to-TO.csv`, or " \
// 75:                             "`brew-contributions-FROM-to-TO-USER.csv` when filtered with `--user`. " \
// 76:                             "Only Maintainers listed at the end of that quarter are included. " \
// 77:                             "The `new role` value must show a downgrade for two consecutive " \
// 78:                             "quarters before a downgrade is applied. " \
// 79:                             "Review searches return at most 100 results and other counts are capped at 500 per " \
// 80:                             "repository and contribution type. Repository-scoped follow-up searches ensure " \
// 81:                             "role activity checks remain accurate when a count is capped. Completed-period " \
// 82:                             "GitHub searches are cached in Homebrew's cache and removed by normal cache pruning. " \
// 83:                             "`YEAR-1` is December of the previous year through February, `YEAR-2` is March " \
// 84:                             "through May, `YEAR-3` is June through August and `YEAR-4` is September through " \
// 85:                             "November."
// 86:         conflicts "--organisation", "--repositories"
// 87:         conflicts "--organisation", "--team"
// 88:         conflicts "--user", "--team"
// 89:         conflicts "--maintainer-report-csv", "--repositories"
// 90:         conflicts "--maintainer-report-csv", "--organisation"
// 91:         conflicts "--maintainer-report-csv", "--team"
// 92:         conflicts "--maintainer-report-csv", "--quarter"
// 93:         conflicts "--maintainer-report-csv", "--from"
// 94:         conflicts "--maintainer-report-csv", "--to"
// 95:       end
// 96:
// 97:       sig { override.void }
// 98:       def run
// 99:         maintainer_report_csv = args.maintainer_report_csv
// 100:         requested_users = args.user || []
// 101:         odie "`--user` must not contain empty values." if requested_users.compact.length != requested_users.length
// 102:
// 103:         odie "Cannot get contributions as `$HOMEBREW_NO_GITHUB_API` is set!" if Homebrew::EnvConfig.no_github_api?
// 104:         Homebrew.install_bundler_gems!(groups: ["contributions"]) if args.csv? || maintainer_report_csv
// 105:
// 106:         if maintainer_report_csv
// 107:           odie "`--maintainer-report-csv` must be in YEAR-QUARTER format." unless maintainer_report_csv.match?(
// 108:             /\A\d{4}-[1-4]\z/,
// 109:           )
// 110:           quarter_parts = maintainer_report_csv.split("-")
// 111:           from, to = reporting_quarter_dates(quarter_parts.fetch(1).to_i, quarter_parts.fetch(0).to_i)
// 112:           $stderr.puts "Maintainer report dates: #{from}-to-#{to}"
// 113:         else
// 114:           quarter = args.quarter.presence.to_i
// 115:           odie "Value for `--quarter` must be between 1 and 4." if args.quarter.present? && !quarter.between?(1, 4)
// 116:           quarter_dates = reporting_quarter_dates(quarter) unless quarter.zero?
// 117:           from = args.from.presence || quarter_dates&.first || Date.today.prev_year.iso8601
// 118:           to = args.to.presence || quarter_dates&.last || (Date.today + 1).iso8601
// 119:           puts "Date range is #{time_period(from:, to:)}." if args.verbose?
// 120:         end
// 121:
// 122:         require "utils/github"
// 123:
// 124:         organisation = T.let(nil, T.nilable(String))
// 125:         users = if maintainer_report_csv
// 126:           []
// 127:         elsif (team = args.team.presence)
// 128:           team_sections = team.split("/")
// 129:           organisation = team_sections.first.presence
// 130:           team_name = team_sections.last.presence
// 131:           if team_sections.length != 2 || organisation.nil? || team_name.nil?
// 132:             odie "Team must be in the format `organisation/team`!"
// 133:           end
// 134:
// 135:           puts "Getting members for #{organisation}/#{team_name}..." if args.verbose?
// 136:           GitHub.members_by_team(organisation, team_name).keys
// 137:         elsif requested_users.present?
// 138:           requested_users
// 139:         else
// 140:           puts "Getting members for Homebrew/maintainers..." if args.verbose?
// 141:           GitHub.members_by_team("Homebrew", "maintainers").keys
// 142:         end
// 143:         user_names = users.to_h { |user| [user, user] }
// 144:
// 145:         repositories = if maintainer_report_csv
// 146:           organisation = "Homebrew"
// 147:           PRIMARY_REPOS
// 148:         elsif (org = organisation.presence) || (org = args.organisation.presence)
// 149:           organisation = org
// 150:           puts "Getting repositories for #{organisation}..." if args.verbose?
// 151:           GitHub.organisation_repositories(organisation, from, to, args.verbose?)
// 152:         elsif (repos = args.repositories.presence) && repos.length == 1 && (first_repository = repos.first)
// 153:           case first_repository
// 154:           when "primary"
// 155:             PRIMARY_REPOS
// 156:           else
// 157:             Array(first_repository)
// 158:           end
// 159:         elsif (repos = args.repositories.presence)
// 160:           organisations = repos.map { |repository| repository.split("/").first }.uniq
// 161:           odie "All repositories must be under the same user or organisation!" if organisations.length > 1
// 162:
// 163:           repos
// 164:         else
// 165:           PRIMARY_REPOS
// 166:         end
// 167:         organisation ||= repositories.fetch(0).split("/").fetch(0)
// 168:         repository_refs = prepare_contribution_repositories(repositories, required: maintainer_report_csv.present?)
// 169:
// 170:         lead_maintainers = T.let({}, T::Hash[String, T::Boolean])
// 171:         maintainer_since_dates = T.let({}, T::Hash[String, T.nilable(String)])
// 172:         if maintainer_report_csv
// 173:           user_names, lead_maintainers, maintainer_since_dates = maintainer_report_users(repository_refs, to)
// 174:         end
// 175:
// 176:         results = scan_contributions(
// 177:           organisation, repositories, repository_refs, user_names, from:, to:,
// 178:           skip_reviews_if_lead_met: maintainer_report_csv.present?,
// 179:           progress:                 maintainer_report_csv.present? || args.verbose?
// 180:         )
// 181:         grand_totals = results.transform_values { |user_results| total(user_results) }
// 182:
// 183:         if maintainer_report_csv
// 184:           csv = generate_maintainer_report_csv(
// 185:             results, grand_totals, user_names, lead_maintainers, maintainer_since_dates, to
// 186:           )
// 187:           filename = "brew-contributions-#{from}-to-#{to}"
// 188:           filename += "-#{user_names.keys.map(&:downcase).sort.join("-")}" if requested_users.present?
// 189:           File.write("#{filename}.csv", csv)
// 190:           puts csv
// 191:           return
// 192:         end
// 193:
// 194:         user_names.each_key do |username|
// 195:           grand_total = grand_totals.fetch(username)
// 196:           greater_than_total = T.let(grand_total.fetch(:merged_pr_author_hit_cap, 0).positive?, T::Boolean)
// 197:           contributions = CONTRIBUTION_TYPES.keys.filter_map do |type|
// 198:             type_count = grand_total[type]
// 199:             next if type_count.nil? || type_count.zero?
// 200:
// 201:             count_prefix = ""
// 202:             if ([:merged_pr_author, :merged_pr].include?(type) && grand_total.fetch(:merged_pr_author_hit_cap,
// 203:                                                                                     0).positive?) ||
// 204:                (type == :approved_pr_review && type_count >= MAX_PR_SEARCH) || type_count >= MAX_CONTRIBUTIONS
// 205:               greater_than_total ||= true
// 206:               count_prefix = ">="
// 207:             end
// 208:
// 209:             pretty_type = CONTRIBUTION_TYPES.fetch(type)
// 210:             "#{count_prefix}#{Utils.pluralize("time", type_count, include_count: true)} (#{pretty_type})"
// 211:           end
// 212:           qualifying_total = contribution_count(
// 213:             grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES),
// 214:           )
// 215:           total = Utils.pluralize("time", qualifying_total, include_count: true)
// 216:           total_prefix = ">=" if greater_than_total
// 217:           contributions << "#{total_prefix}#{total} (total)"
// 218:
// 219:           contributions_string = [
// 220:             "#{username} contributed",
// 221:             *contributions.to_sentence,
// 222:             "#{time_period(from:, to:)}.",
// 223:           ].join(" ")
// 224:           if args.csv?
// 225:             $stderr.puts contributions_string
// 226:           else
// 227:             puts contributions_string
// 228:           end
// 229:         end
// 230:
// 231:         return unless args.csv?
// 232:
// 233:         $stderr.puts
// 234:         puts generate_csv(grand_totals)
// 235:       end
// 236:
// 237:       sig {
// 238:         params(repository_refs: T::Hash[String, [Pathname, String]], to: String)
// 239:           .returns([T::Hash[String, String], T::Hash[String, T::Boolean], T::Hash[String, T.nilable(String)]])
// 240:       }
// 241:       def maintainer_report_users(repository_refs, to)
// 242:         brew_path, brew_ref = repository_refs.fetch("Homebrew/brew")
// 243:         require "utils/git"
// 244:         quarter_end_ref = Utils.safe_popen_read(
// 245:           Utils::Git.git, "-C", brew_path, "rev-list", "-1", "--before=#{to}", brew_ref, "--", "README.md"
// 246:         ).strip
// 247:         odie "Could not find Homebrew/brew's README at the end of the reporting quarter." if quarter_end_ref.empty?
// 248:
// 249:         user_names = T.let({}, T::Hash[String, String])
// 250:         lead_maintainers = T.let({}, T::Hash[String, T::Boolean])
// 251:         Utils.safe_popen_read(Utils::Git.git, "-C", brew_path, "show", "#{quarter_end_ref}:README.md")
// 252:              .dup.force_encoding(Encoding::UTF_8).each_line do |line|
// 253:           lead = line.start_with?("Homebrew's [Lead Maintainers]")
// 254:           next if !lead &&
// 255:                   !line.start_with?("Homebrew's other Maintainers") &&
// 256:                   !line.start_with?("Homebrew's maintainers are")
// 257:
// 258:           line.scan(%r{\[([^\]]+)\]\(https://github\.com/([A-Za-z\d-]+)\)}).each do |match|
// 259:             next unless match.is_a?(Array)
// 260:
// 261:             name = match.fetch(0)
// 262:             user = match.fetch(1)
// 263:             user_names[user] = name
// 264:             lead_maintainers[user.downcase] = true if lead
// 265:           end
// 266:         end
// 267:         odie "Could not read the maintainers from Homebrew/brew's README." if user_names.empty?
// 268:
// 269:         if (users = args.user.presence)
// 270:           requested_usernames = users.to_h do |user|
// 271:             [user, github_username_for(user, to:)&.downcase]
// 272:           end
// 273:           unresolved_users = requested_usernames.filter_map { |user, username| user if username.nil? }
// 274:           odie "Could not resolve GitHub usernames for: #{unresolved_users.to_sentence}." if unresolved_users.present?
// 275:
// 276:           maintainer_usernames = user_names.keys.map(&:downcase)
// 277:           non_maintainers = requested_usernames.filter_map do |user, username|
// 278:             user if username && maintainer_usernames.exclude?(username)
// 279:           end
// 280:           unless non_maintainers.empty?
// 281:             odie "Not listed as #{Utils.pluralize("Maintainer", non_maintainers.length)} at the end of the " \
// 282:                  "reporting quarter: #{non_maintainers.to_sentence}."
// 283:           end
// 284:
// 285:           selected_usernames = requested_usernames.values.compact
// 286:           user_names.select! { |user| selected_usernames.include?(user.downcase) }
// 287:         end
// 288:
// 289:         maintainer_count = Utils.pluralize("maintainer", user_names.length, include_count: true)
// 290:         $stderr.puts "Scanning contributions for #{maintainer_count}..."
// 291:         maintainer_since_dates = user_names.to_h do |user, name|
// 292:           [user, maintainer_since(brew_path, quarter_end_ref, user, name)]
// 293:         end
// 294:         [user_names, lead_maintainers, maintainer_since_dates]
// 295:       end
// 296:
// 297:       sig { params(repository_path: Pathname, ref: String, user: String, name: String).returns(T.nilable(String)) }
// 298:       def maintainer_since(repository_path, ref, user, name)
// 299:         require "utils/git"
// 300:
// 301:         candidates = ["https://github.com/#{user}", name].flat_map do |identity|
// 302:           Utils.safe_popen_read(
// 303:             Utils::Git.git, "-C", repository_path, "log", ref, "--fixed-strings",
// 304:             "-S#{identity}", "--format=%H%x1f%cs", "--", "README.md"
// 305:           ).lines(chomp: true)
// 306:         end
// 307:         candidates.uniq!
// 308:         candidates.sort_by! { |candidate| candidate.split("\x1f", 2).fetch(1) }
// 309:         candidates.each do |candidate|
// 310:           commit, date = candidate.split("\x1f", 2)
// 311:           next if date.nil?
// 312:
// 313:           readme = Utils.safe_popen_read(Utils::Git.git, "-C", repository_path, "show", "#{commit}:README.md")
// 314:           parent_readme = system_command(Utils::Git.git,
// 315:                                          args:         ["-C", repository_path, "show", "#{commit}^:README.md"],
// 316:                                          print_stderr: false).stdout
// 317:           return date if readme_mentions?(readme, user, name) && !readme_mentions?(parent_readme, user, name)
// 318:         end
// 319:
// 320:         nil
// 321:       end
// 322:
// 323:       sig {
// 324:         params(
// 325:           organisation:             String,
// 326:           repositories:             T::Array[String],
// 327:           repository_refs:          T::Hash[String, [Pathname, String]],
// 328:           users:                    T::Hash[String, String],
// 329:           from:                     String,
// 330:           to:                       String,
// 331:           skip_reviews_if_lead_met: T::Boolean,
// 332:           progress:                 T::Boolean,
// 333:         ).returns(T::Hash[String, T::Hash[String, T::Hash[Symbol, Integer]]])
// 334:       }
// 335:       def scan_contributions(organisation, repositories, repository_refs, users, from:, to:,
// 336:                              skip_reviews_if_lead_met:, progress:)
// 337:         results = users.to_h do |user, _|
// 338:           user_results = repositories.to_h do |repository|
// 339:             [repository, CONTRIBUTION_TYPES.keys.to_h { |type| [type, 0] }]
// 340:           end
// 341:           [user, user_results]
// 342:         end
// 343:
// 344:         require "utils/github"
// 345:         github_users = users.keys.to_h { |user| [user, github_username_for(user, to:)] }
// 346:         git_authored_pull_requests = users.keys.to_h do |user|
// 347:           [user, repositories.to_h { |repository| [repository, Set.new] }]
// 348:         end
// 349:         git_merged_pull_requests = users.keys.to_h do |user|
// 350:           [user, repositories.to_h { |repository| [repository, Set.new] }]
// 351:         end
// 352:         repository_refs.each do |repository, (repository_path, ref)|
// 353:           require "utils/git"
// 354:           output = Utils.safe_popen_read(
// 355:             Utils::Git.git, "-C", repository_path, "log", ref, "--since=#{from}", "--before=#{to}",
// 356:             "--format=%H%x1f%P%x1f%an%x1f%ae%x1f%B%x1e"
// 357:           )
// 358:           authored_pull_requests = users.keys.to_h { |user| [user, Set.new] }
// 359:           merged_pull_requests = users.keys.to_h { |user| [user, Set.new] }
// 360:           parse_git_log(output, users, authored_pull_requests:, merged_pull_requests:).each do |user, counts|
// 361:             results.fetch(user)[repository] = counts
// 362:             git_authored_pull_requests.fetch(user)[repository] = authored_pull_requests.fetch(user)
// 363:             git_merged_pull_requests.fetch(user)[repository] = merged_pull_requests.fetch(user)
// 364:           end
// 365:         end
// 366:
// 367:         merged_range = "#{from}..#{Date.iso8601(to).prev_day.iso8601}"
// 368:         users.each_key do |user|
// 369:           github_user = github_users.fetch(user)
// 370:           next if github_user.nil?
// 371:
// 372:           cache_key = ["merged-at", organisation, github_user, merged_range].join("\0")
// 373:           merged_pull_requests = github_search_with_rate_limit(cache_key, to:) do
// 374:             GitHub.search_issues("", is: "merged", user: organisation, author: github_user, merged: merged_range)
// 375:           rescue GitHub::API::ValidationFailedError
// 376:             opoo "Couldn't search GitHub for PRs authored by #{github_user}. Their profile might be private. " \
// 377:                  "Defaulting to 0."
// 378:             []
// 379:           end
// 380:           capped_merged_pull_requests = merged_pull_requests.length >= MAX_PR_SEARCH
// 381:           if capped_merged_pull_requests
// 382:             results.fetch(user).fetch(repositories.fetch(0))[:merged_pr_author_hit_cap] =
// 383:               1
// 384:           end
// 385:           merged_pull_requests.each do |pull_request|
// 386:             repository = pull_request.fetch("repository_url").delete_prefix("#{GitHub::API_URL}/repos/")
// 387:             next unless repositories.include?(repository)
// 388:
// 389:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 390:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 391:             add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_request_ids)
// 392:           end
// 393:           repositories.each do |repository|
// 394:             counts = results.fetch(user).fetch(repository)
// 395:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 396:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 397:             update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_request_ids)
// 398:           end
// 399:           next unless skip_reviews_if_lead_met
// 400:           next unless capped_merged_pull_requests
// 401:           next if lead_activity_met?(results.fetch(user))
// 402:
// 403:           repositories.each do |repository|
// 404:             break if lead_activity_met?(results.fetch(user))
// 405:
// 406:             repository_counts = results.fetch(user).fetch(repository)
// 407:             repository_total = contribution_count(repository_counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 408:             qualifying_total = contribution_count(total(results.fetch(user)).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 409:             next if repository_total >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD &&
// 410:                     qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 411:
// 412:             $stderr.puts "Querying merged-PR search for #{user} in #{repository}..." if progress
// 413:             cache_key = ["merged-at", repository, github_user, merged_range].join("\0")
// 414:             repository_pull_requests = github_search_with_rate_limit(cache_key, to:) do
// 415:               GitHub.search_issues("", is: "merged", repo: repository, author: github_user, merged: merged_range)
// 416:             end
// 417:             authored_pull_requests = git_authored_pull_requests.fetch(user).fetch(repository)
// 418:             merged_pull_request_ids = git_merged_pull_requests.fetch(user).fetch(repository)
// 419:             repository_pull_requests.each do |pull_request|
// 420:               add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_request_ids)
// 421:             end
// 422:             update_merged_pull_request_counts(repository_counts, authored_pull_requests, merged_pull_request_ids)
// 423:           end
// 424:         end
// 425:
// 426:         review_users = github_users.filter_map { |user, github_user| [user, github_user] if github_user }
// 427:         review_users.reject! { |user, _| lead_activity_met?(results.fetch(user)) } if skip_reviews_if_lead_met
// 428:         review_users.each_with_index do |(user, github_user), index|
// 429:           if progress
// 430:             $stderr.puts "Querying approved-review search for #{user} (#{index + 1}/#{review_users.length})..."
// 431:           end
// 432:           cache_key = ["approved", organisation, github_user, from, to].join("\0")
// 433:           approved_reviews = github_search_with_rate_limit(cache_key, to:) do
// 434:             GitHub.search_approved_pull_requests_in_user_or_organisation(organisation, github_user, from:, to:)
// 435:           end
// 436:           capped_reviews = approved_reviews.length >= MAX_PR_SEARCH
// 437:           results.fetch(user).fetch(repositories.fetch(0))[:approved_pr_review_hit_cap] = 1 if capped_reviews
// 438:           approved_reviews.each do |pull_request|
// 439:             repository = pull_request.fetch("repository_url").delete_prefix("#{GitHub::API_URL}/repos/")
// 440:             next unless repositories.include?(repository)
// 441:
// 442:             increment_contribution_count(results.fetch(user).fetch(repository), :approved_pr_review)
// 443:           end
// 444:           next unless skip_reviews_if_lead_met
// 445:           next unless capped_reviews
// 446:           next if lead_activity_met?(results.fetch(user))
// 447:
// 448:           repositories.each do |repository|
// 449:             break if lead_activity_met?(results.fetch(user))
// 450:
// 451:             repository_counts = results.fetch(user).fetch(repository)
// 452:             repository_total = contribution_count(repository_counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 453:             qualifying_total = contribution_count(total(results.fetch(user)).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 454:             next if repository_total >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD &&
// 455:                     qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 456:
// 457:             $stderr.puts "Querying approved-review search for #{user} in #{repository}..." if progress
// 458:             cache_key = ["approved", repository, github_user, from, to].join("\0")
// 459:             repository_reviews = github_search_with_rate_limit(cache_key, to:) do
// 460:               GitHub.search_issues("", is: "pr", review: "approved", repo: repository, reviewed_by: github_user,
// 461:                                    from:, to:)
// 462:             end
// 463:             repository_counts[:approved_pr_review] = repository_reviews.length
// 464:           end
// 465:         end
// 466:
// 467:         results
// 468:       end
// 469:
// 470:       sig { params(user: String, to: String).returns(T.nilable(String)) }
// 471:       def github_username_for(user, to:)
// 472:         return user unless user.include?("@")
// 473:         if user.end_with?("@users.noreply.github.com")
// 474:           return user.delete_suffix("@users.noreply.github.com").sub(/\A\d+\+/,
// 475:                                                                      "")
// 476:         end
// 477:
// 478:         cache_key = ["public-email", user].join("\0")
// 479:         matches = github_search_with_rate_limit(cache_key, to:) do
// 480:           GitHub.search("users", "\"#{user}\" in:email").fetch("items", [])
// 481:         end
// 482:         if matches.one?
// 483:           login = matches.fetch(0)["login"]
// 484:           return login if login.is_a?(String)
// 485:         end
// 486:
// 487:         opoo "Could not find a unique public GitHub account for #{user}; skipping GitHub PR searches."
// 488:         nil
// 489:       rescue GitHub::API::ValidationFailedError
// 490:         opoo "Could not search for a public GitHub account for #{user}; skipping GitHub PR searches."
// 491:         nil
// 492:       end
// 493:
// 494:       sig {
// 495:         params(cache_key: String, to: String, block: T.proc.returns(T::Array[T::Hash[String, T.untyped]]))
// 496:           .returns(T::Array[T::Hash[String, T.untyped]])
// 497:       }
// 498:       def github_search_with_rate_limit(cache_key, to:, &block)
// 499:         cache_path = if Date.iso8601(to) <= Date.today
// 500:           HOMEBREW_CACHE/"contributions--#{Digest::SHA256.hexdigest("1\0#{cache_key}")}.json"
// 501:         end
// 502:         if cache_path&.file?
// 503:           begin
// 504:             cached_results = JSON.parse(cache_path.read)
// 505:             return cached_results if cached_results.is_a?(Array)
// 506:           rescue JSON::ParserError, Errno::ENOENT
// 507:             nil
// 508:           end
// 509:           cache_path.unlink if cache_path.exist?
// 510:         end
// 511:
// 512:         results = yield
// 513:         if cache_path
// 514:           HOMEBREW_CACHE.mkpath
// 515:           cache_path.atomic_write(JSON.generate(results))
// 516:         end
// 517:         results
// 518:       rescue GitHub::API::RateLimitExceededError => e
// 519:         GitHub::API.sleep_for_rate_limit(e)
// 520:         retry
// 521:       end
// 522:
// 523:       sig {
// 524:         params(
// 525:           output:                 String,
// 526:           users:                  T::Hash[String, String],
// 527:           authored_pull_requests: T.nilable(T::Hash[String, T::Set[String]]),
// 528:           merged_pull_requests:   T.nilable(T::Hash[String, T::Set[String]]),
// 529:         )
// 530:           .returns(T::Hash[String, T::Hash[Symbol, Integer]])
// 531:       }
// 532:       def parse_git_log(output, users, authored_pull_requests: nil, merged_pull_requests: nil)
// 533:         counts = users.to_h do |user, _|
// 534:           [user, CONTRIBUTION_TYPES.keys.to_h { |type| [type, 0] }]
// 535:         end
// 536:         identity_users = T.let({}, T::Hash[String, String])
// 537:         users.each do |user, name|
// 538:           identity_users[user.downcase] = user
// 539:           identity_users[name.downcase] = user
// 540:           identity_users[user.split("@").first.to_s.sub(/\A\d+\+/, "").downcase] = user
// 541:         end
// 542:         records = output.split("\x1e").filter_map do |record|
// 543:           fields = record.strip.split("\x1f", 5)
// 544:           fields if fields.length == 5
// 545:         end
// 546:         record_identities = records.to_h do |fields|
// 547:           [fields.fetch(0), [fields.fetch(2), fields.fetch(3)]]
// 548:         end
// 549:         records.each do |fields|
// 550:           parents = fields.fetch(1).split
// 551:           source_owner = fields.fetch(4)[%r{\AMerge pull request #\d+ from ([^/\s]+)/}, 1]
// 552:           next if parents.length < 2 || source_owner.nil?
// 553:
// 554:           user = identity_users[source_owner.downcase]
// 555:           source_identity = record_identities[parents.fetch(1)]
// 556:           next if user.nil? || source_identity.nil?
// 557:
// 558:           name, email = source_identity
// 559:           identity_users[name.strip.downcase] ||= user
// 560:           identity_users[email.downcase] ||= user
// 561:           identity_users[email.split("@").first.to_s.sub(/\A\d+\+/, "").downcase] ||= user
// 562:         end
// 563:         commit_authors = T.let(records.to_h do |fields|
// 564:           sha = fields.fetch(0)
// 565:           author_name = fields.fetch(2)
// 566:           author_email = fields.fetch(3)
// 567:           [sha, user_for_git_identity(author_name, author_email, identity_users)]
// 568:         end, T::Hash[String, T.nilable(String)])
// 569:
// 570:         records.each do |fields|
// 571:           parents_string = fields.fetch(1)
// 572:           author_name = fields.fetch(2)
// 573:           author_email = fields.fetch(3)
// 574:           body = fields.fetch(4)
// 575:           coauthors = body.scan(/^Co-authored-by:\s*(.*?)\s*<([^>]+)>/i).filter_map do |match|
// 576:             next unless match.is_a?(Array)
// 577:
// 578:             user_for_git_identity(match.fetch(0), match.fetch(1), identity_users)
// 579:           end
// 580:           coauthors.uniq.each do |user|
// 581:             increment_contribution_count(counts.fetch(user), :coauthor)
// 582:           end
// 583:
// 584:           parents = parents_string.split
// 585:           pull_request = body.match(%r{\AMerge pull request #(\d+) from ([^/\s]+)/})
// 586:           next if parents.length < 2 || pull_request.nil?
// 587:
// 588:           merger = user_for_git_identity(author_name, author_email, identity_users)
// 589:           pull_request_id = pull_request[1]
// 590:           source_owner = pull_request[2]
// 591:           next if pull_request_id.nil? || source_owner.nil?
// 592:
// 593:           author = identity_users[source_owner.downcase] || commit_authors[parents.fetch(1)]
// 594:           if author
// 595:             increment_contribution_count(counts.fetch(author), :merged_pr_author)
// 596:             authored_pull_requests&.fetch(author)&.add(pull_request_id)
// 597:           end
// 598:           increment_contribution_count(counts.fetch(merger), :merged_pr_merger) if merger
// 599:           [author, merger].compact.uniq.each do |user|
// 600:             increment_contribution_count(counts.fetch(user), :merged_pr)
// 601:             merged_pull_requests&.fetch(user)&.add(pull_request_id)
// 602:           end
// 603:         end
// 604:
// 605:         counts
// 606:       end
// 607:
// 608:       private
// 609:
// 610:       sig {
// 611:         params(
// 612:           results:                T::Hash[String, T::Hash[String, T::Hash[Symbol, Integer]]],
// 613:           grand_totals:           T::Hash[String, T::Hash[Symbol, Integer]],
// 614:           user_names:             T::Hash[String, String],
// 615:           lead_maintainers:       T::Hash[String, T::Boolean],
// 616:           maintainer_since_dates: T::Hash[String, T.nilable(String)],
// 617:           to:                     String,
// 618:         ).returns(String)
// 619:       }
// 620:       def generate_maintainer_report_csv(results, grand_totals, user_names, lead_maintainers, maintainer_since_dates,
// 621:                                          to)
// 622:         require "csv"
// 623:
// 624:         rows = results.sort_by do |user, _|
// 625:           qualifying_total = contribution_count(grand_totals.fetch(user).slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 626:           [-qualifying_total, user.downcase]
// 627:         end
// 628:         rows.map! do |user, user_repositories|
// 629:           grand_total = grand_totals.fetch(user)
// 630:           repository_qualifying_totals = user_repositories.transform_values do |counts|
// 631:             contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 632:           end
// 633:           qualifying_total = contribution_count(grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 634:           maintainer_activity_met = qualifying_total >= MAINTAINER_ACTIVITY_THRESHOLD
// 635:           maintainer_since = maintainer_since_dates.fetch(user)
// 636:           maintainer_since_date = Date.iso8601(maintainer_since) if maintainer_since
// 637:           period_end = Date.iso8601(to)
// 638:           lead_maintainer = lead_maintainers.key?(user.downcase)
// 639:           lead_activity_met = lead_activity_met?(user_repositories)
// 640:           new_role = if lead_activity_met &&
// 641:                         (lead_maintainer ||
// 642:                          (maintainer_since_date && maintainer_since_date <= period_end.prev_year(3)))
// 643:             "Lead Maintainer"
// 644:           elsif maintainer_activity_met
// 645:             "Maintainer"
// 646:           else
// 647:             "None"
// 648:           end
// 649:
// 650:           capped = grand_total.fetch(:merged_pr_author_hit_cap, 0).positive? ||
// 651:                    grand_total.fetch(:approved_pr_review_hit_cap, 0).positive?
// 652:           capped ||= user_repositories.any? do |_, counts|
// 653:             counts.fetch(:approved_pr_review) >= MAX_PR_SEARCH ||
// 654:               counts.except(:approved_pr_review).values.any? do |count|
// 655:                 count >= MAX_CONTRIBUTIONS
// 656:               end
// 657:           end
// 658:
// 659:           [
// 660:             user,
// 661:             user_names.fetch(user),
// 662:             maintainer_since,
// 663:             maintainer_since_date ? [(period_end - maintainer_since_date).to_i, 0].max : nil,
// 664:             *PRIMARY_REPOS.flat_map do |repository|
// 665:               counts = user_repositories.fetch(repository)
// 666:               [*counts.values_at(*CONTRIBUTION_TYPES.keys), repository_qualifying_totals.fetch(repository)]
// 667:             end,
// 668:             qualifying_total,
// 669:             maintainer_activity_met,
// 670:             lead_activity_met,
// 671:             capped,
// 672:             lead_maintainer ? "Lead Maintainer" : "Maintainer",
// 673:             new_role,
// 674:           ]
// 675:         end
// 676:         CSV.generate do |csv|
// 677:           csv << [
// 678:             "username", "name", "since", "tenure days",
// 679:             *PRIMARY_REPOS.flat_map do |repository|
// 680:               repository = repository.delete_prefix("Homebrew/").delete_prefix("homebrew-")
// 681:               [
// 682:                 "#{repository} authored", "#{repository} merged", "#{repository} PRs",
// 683:                 "#{repository} reviews", "#{repository} coauthored", "#{repository} total"
// 684:               ]
// 685:             end,
// 686:             "total", "maintainer met", "lead met", "capped", "role", "new role"
// 687:           ]
// 688:           rows.each { |row| csv << row }
// 689:         end
// 690:       end
// 691:
// 692:       sig { params(repositories: T::Array[String], required: T::Boolean).returns(T::Hash[String, [Pathname, String]]) }
// 693:       def prepare_contribution_repositories(repositories, required:)
// 694:         require "utils/git"
// 695:
// 696:         repository_refs = T.let({}, T::Hash[String, [Pathname, String]])
// 697:         repositories.each do |repository|
// 698:           repository_path, tap = repository_path_and_tap(repository)
// 699:           if repository_path && tap && !repository_path.exist?
// 700:             opoo "Repository #{repository} not yet tapped! Tapping it now..."
// 701:             tap.install(force: true)
// 702:           end
// 703:           unless repository_path&.exist?
// 704:             odie "Could not find a local Git repository for #{repository}." if required
// 705:             next
// 706:           end
// 707:
// 708:           $stderr.puts "Fetching latest commits for #{repository}..."
// 709:           system_command!(Utils::Git.git,
// 710:                           args:         ["-C", repository_path, "fetch", "--quiet", "--force", "origin",
// 711:                                          "+refs/heads/*:refs/remotes/origin/*"],
// 712:                           print_stderr: false)
// 713:           system_command!(Utils::Git.git,
// 714:                           args:         ["-C", repository_path, "remote", "set-head", "origin", "--auto"],
// 715:                           print_stderr: false)
// 716:
// 717:           repository_refs[repository] = [repository_path, "origin/HEAD"]
// 718:         end
// 719:         repository_refs
// 720:       end
// 721:
// 722:       sig { params(readme: String, user: String, name: String).returns(T::Boolean) }
// 723:       def readme_mentions?(readme, user, name)
// 724:         readme = readme.dup.force_encoding(Encoding::UTF_8)
// 725:         readme.include?("https://github.com/#{user}") || readme.include?(name)
// 726:       end
// 727:
// 728:       sig {
// 729:         params(
// 730:           pull_request:           T::Hash[String, T.untyped],
// 731:           authored_pull_requests: T::Set[String],
// 732:           merged_pull_requests:   T::Set[String],
// 733:         ).void
// 734:       }
// 735:       def add_merged_pull_request_id(pull_request, authored_pull_requests, merged_pull_requests)
// 736:         number = pull_request["number"]
// 737:         return unless number.is_a?(Integer)
// 738:
// 739:         pull_request_id = number.to_s
// 740:         authored_pull_requests << pull_request_id
// 741:         merged_pull_requests << pull_request_id
// 742:       end
// 743:
// 744:       sig {
// 745:         params(
// 746:           counts:                 T::Hash[Symbol, Integer],
// 747:           authored_pull_requests: T::Set[String],
// 748:           merged_pull_requests:   T::Set[String],
// 749:         ).void
// 750:       }
// 751:       def update_merged_pull_request_counts(counts, authored_pull_requests, merged_pull_requests)
// 752:         unless authored_pull_requests.empty?
// 753:           counts[:merged_pr_author] = [authored_pull_requests.length, MAX_CONTRIBUTIONS].min
// 754:         end
// 755:         return if merged_pull_requests.empty?
// 756:
// 757:         counts[:merged_pr] = [merged_pull_requests.length, MAX_CONTRIBUTIONS].min
// 758:       end
// 759:
// 760:       sig {
// 761:         params(name: String, email: String, identity_users: T::Hash[String, String]).returns(T.nilable(String))
// 762:       }
// 763:       def user_for_git_identity(name, email, identity_users)
// 764:         identity_users[name.strip.downcase] ||
// 765:           identity_users[email.downcase] ||
// 766:           identity_users[email.split("@").first.to_s.sub(/\A\d+\+/, "").downcase]
// 767:       end
// 768:
// 769:       sig { params(counts: T::Hash[Symbol, Integer], type: Symbol).void }
// 770:       def increment_contribution_count(counts, type)
// 771:         count = counts.fetch(type)
// 772:         counts[type] = count + 1 if count < MAX_CONTRIBUTIONS
// 773:       end
// 774:
// 775:       sig { params(repository: String).returns([T.nilable(Pathname), T.nilable(Tap)]) }
// 776:       def repository_path_and_tap(repository)
// 777:         return [HOMEBREW_REPOSITORY, nil] if repository == "Homebrew/brew"
// 778:         return [nil, nil] if repository.exclude?("/homebrew-")
// 779:
// 780:         require "tap"
// 781:         tap = Tap.fetch(repository)
// 782:         return [nil, nil] if tap.user == "Homebrew" && DEPRECATED_OFFICIAL_TAPS.include?(tap.repository)
// 783:
// 784:         [tap.path, tap]
// 785:       end
// 786:
// 787:       sig { params(from: T.nilable(String), to: T.nilable(String)).returns(String) }
// 788:       def time_period(from:, to:)
// 789:         if from && to
// 790:           "between #{from} and #{to}"
// 791:         elsif from
// 792:           "after #{from}"
// 793:         elsif to
// 794:           "before #{to}"
// 795:         else
// 796:           "in all time"
// 797:         end
// 798:       end
// 799:
// 800:       sig { params(totals: T::Hash[String, T::Hash[Symbol, Integer]]).returns(String) }
// 801:       def generate_csv(totals)
// 802:         require "csv"
// 803:
// 804:         CSV.generate do |csv|
// 805:           csv << %w[username repo authored merged PRs reviews coauthored total]
// 806:
// 807:           totals.sort_by { |_, counts| -contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES)) }
// 808:                 .each do |user, total|
// 809:             csv << grand_total_row(user, total)
// 810:           end
// 811:         end
// 812:       end
// 813:
// 814:       sig { params(user: String, grand_total: T::Hash[Symbol, Integer]).returns(T::Array[T.any(String, T.nilable(Integer))]) }
// 815:       def grand_total_row(user, grand_total)
// 816:         grand_totals = grand_total.slice(*CONTRIBUTION_TYPES.keys).values
// 817:         qualifying_total = contribution_count(grand_total.slice(*QUALIFYING_CONTRIBUTION_TYPES))
// 818:         [user, "all", *grand_totals, qualifying_total]
// 819:       end
// 820:
// 821:       sig { params(results: T::Hash[String, T::Hash[Symbol, Integer]]).returns(T::Hash[Symbol, Integer]) }
// 822:       def total(results)
// 823:         totals = {}
// 824:
// 825:         results.each_value do |counts|
// 826:           counts.each do |kind, count|
// 827:             totals[kind] ||= 0
// 828:             totals[kind] += count
// 829:           end
// 830:         end
// 831:
// 832:         totals
// 833:       end
// 834:
// 835:       sig { params(contributions: T::Hash[Symbol, Integer]).returns(Integer) }
// 836:       def contribution_count(contributions)
// 837:         contributions.values.sum
// 838:       end
// 839:
// 840:       sig { params(repositories: T::Hash[String, T::Hash[Symbol, Integer]]).returns(T::Boolean) }
// 841:       def lead_activity_met?(repositories)
// 842:         repositories.count do |_, counts|
// 843:           contribution_count(counts.slice(*QUALIFYING_CONTRIBUTION_TYPES)) >= LEAD_REPOSITORY_ACTIVITY_THRESHOLD
// 844:         end >= 2
// 845:       end
// 846:
// 847:       sig { params(quarter: Integer, current_year: Integer).returns([String, String]) }
// 848:       def reporting_quarter_dates(quarter, current_year = Date.today.year)
// 849:         # These aren't standard quarterly dates. We've chosen our own so that we
// 850:         # can use recent maintainer activity stats as part of checking
// 851:         # eligibility for expensed attendance at the AGM in February each year.
// 852:         last_year = current_year - 1
// 853:         dates = {
// 854:           1 => [Date.new(last_year, 12, 1).iso8601, Date.new(current_year, 3, 1).iso8601],
// 855:           2 => [Date.new(current_year, 3, 1).iso8601, Date.new(current_year,  6, 1).iso8601],
// 856:           3 => [Date.new(current_year, 6, 1).iso8601, Date.new(current_year,  9, 1).iso8601],
// 857:           4 => [Date.new(current_year, 9, 1).iso8601, Date.new(current_year, 12, 1).iso8601],
// 858:         }
// 859:         dates.fetch(quarter)
// 860:       end
// 861:     end
// 862:   end
// 863: end
