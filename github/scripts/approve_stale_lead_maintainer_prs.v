module scripts

import ruby

// Translated from Homebrew/brew `scripts/approve_stale_lead_maintainer_prs.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 74.
pub fn ruby_approve_stale_lead_maintainer_prs_l74_d1_initialize(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('initialize', ...args)
}

// Ruby method `run` at line 102.
pub fn ruby_approve_stale_lead_maintainer_prs_l102_d2_run(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('run', ...args)
}

// Ruby method `approve` at line 113.
pub fn ruby_approve_stale_lead_maintainer_prs_l113_d3_approve(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('approve', ...args)
}

// Ruby method `report` at line 164.
pub fn ruby_approve_stale_lead_maintainer_prs_l164_d4_report(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('report', ...args)
}

// Ruby method `evaluate(pull_request, exhaustive:)` at line 176.
pub fn ruby_approve_stale_lead_maintainer_prs_l176_d5_evaluate(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('evaluate', ...args)
}

// Ruby method `finish(data, failure_messages)` at line 369.
pub fn ruby_approve_stale_lead_maintainer_prs_l369_d6_finish(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('finish', ...args)
}

// Ruby method `status_label(value)` at line 440.
pub fn ruby_approve_stale_lead_maintainer_prs_l440_d7_status_label(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('status_label', ...args)
}

// Ruby method `failures_for(data, include_ci: true)` at line 447.
pub fn ruby_approve_stale_lead_maintainer_prs_l447_d8_failures_for(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('failures_for', ...args)
}

// Ruby method `summarise(facts)` at line 477.
pub fn ruby_approve_stale_lead_maintainer_prs_l477_d9_summarise(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('summarise', ...args)
}

// Ruby method `approved_pr_link(data)` at line 519.
pub fn ruby_approve_stale_lead_maintainer_prs_l519_d10_approved_pr_link(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('approved_pr_link', ...args)
}

// Ruby method `reviews_for(number)` at line 526.
pub fn ruby_approve_stale_lead_maintainer_prs_l526_d11_reviews_for(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('reviews_for', ...args)
}

// Ruby method `paginated_rest(url, additional_query_params = "")` at line 531.
pub fn ruby_approve_stale_lead_maintainer_prs_l531_d12_paginated_rest(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('paginated_rest', ...args)
}

// Ruby method `rest(url, data: {}, request_method: :GET)` at line 551.
pub fn ruby_approve_stale_lead_maintainer_prs_l551_d13_rest(args ...ruby.Value) ruby.Value {
	return ruby.unimplemented_fn('rest', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "date"
// 5: require "time"
// 6: require "uri"
// 7: require "utils/formatter"
// 8: require "utils/github"
// 9: require "utils/output"
// 10:
// 11: # Approves stale lead maintainer PRs from GitHub Actions.
// 12: class StaleLeadMaintainerPrApproval
// 13:   include Utils::Output::Mixin
// 14:
// 15:   REPOSITORY = "Homebrew/brew"
// 16:   GITHUB_ACTIONS_URL = "https://github.com/apps/github-actions"
// 17:   APPROVABLE_CHECK_RUN_CONCLUSIONS = ["success", "neutral", "skipped"].freeze
// 18:   HUMAN_REVIEW_WINDOW_HOURS = 48
// 19:   SENSITIVE_PATH_PREFIXES = [".github/"].freeze
// 20:   SENSITIVE_PATHS = [
// 21:     "Library/Homebrew/utils/github.rb",
// 22:     "README.md",
// 23:   ].freeze
// 24:   REPORT_BRANCH = "approve-stale-lead-maintainer-prs"
// 25:   GitHubPayload = T.type_alias { T::Hash[String, BasicObject] }
// 26:   GitHubPayloads = T.type_alias { T::Array[GitHubPayload] }
// 27:   GitHubPage = T.type_alias { T.any(GitHubPayload, GitHubPayloads) }
// 28:   GitHubResult = T.type_alias { T.any(GitHubPayload, GitHubPayloads) }
// 29:   RequestData = T.type_alias { T::Hash[Symbol, String] }
// 30:
// 31:   # Recent qualifying approval for another Homebrew/brew PR.
// 32:   class RecentApproval < T::Struct
// 33:     const :number, Integer
// 34:     const :url, String
// 35:   end
// 36:
// 37:   # Decision facts for a stale lead maintainer PR.
// 38:   class PullRequestFacts < T::Struct
// 39:     const :number, Integer
// 40:     const :title, String
// 41:     const :author, String
// 42:     const :created_at, Time
// 43:     const :head_sha, String
// 44:     const :pr_url, String
// 45:     const :checks_url, String
// 46:     const :author_url, String
// 47:     const :not_from_fork, T::Boolean
// 48:     const :draft, T::Boolean
// 49:     const :weekday_approval_window, T::Boolean
// 50:     const :old_enough_for_approval, T::Boolean
// 51:     prop :lead_maintainer, T::Boolean, default: false
// 52:     prop :lead_maintainer_checked, T::Boolean, default: false
// 53:     prop :approved_another_pr, T::Boolean, default: false
// 54:     prop :approved_another_pr_checked, T::Boolean, default: false
// 55:     prop :approved_pr_number, String, default: ""
// 56:     prop :approved_pr_url, String, default: ""
// 57:     prop :no_human_review_since_creation, T::Boolean, default: false
// 58:     prop :reviews_checked, T::Boolean, default: false
// 59:     prop :human_reviews_since_creation, T::Array[String], default: []
// 60:     prop :copilot_reviewed, T::Boolean, default: false
// 61:     prop :already_approved, T::Boolean, default: false
// 62:     prop :sensitive_files_unchanged, T::Boolean, default: false
// 63:     prop :sensitive_files_checked, T::Boolean, default: false
// 64:     prop :changed_sensitive_files, T::Array[String], default: []
// 65:     prop :ci_passing, T::Boolean, default: false
// 66:     prop :ci_checked, T::Boolean, default: false
// 67:     prop :failing_ci_jobs, T::Array[String], default: []
// 68:     prop :requirements_met, T::Boolean, default: false
// 69:     prop :should_approve, T::Boolean, default: false
// 70:     prop :failure_messages, T::Array[String], default: []
// 71:   end
// 72:
// 73:   sig { void }
// 74:   def initialize
// 75:     @repository = T.let(ENV.fetch("GITHUB_REPOSITORY"), String)
// 76:     raise "This workflow must only run in #{REPOSITORY}." if @repository != REPOSITORY
// 77:
// 78:     @server_url = T.let(ENV.fetch("GITHUB_SERVER_URL", "https://github.com"), String)
// 79:     @event_name = T.let(ENV.fetch("GITHUB_EVENT_NAME"), String)
// 80:     @pull_request_number = T.let(ENV.fetch("PR_NUMBER", ""), String)
// 81:     lead_maintainers_line = File.read("README.md").each_line.find do |line|
// 82:       line.start_with?("Homebrew's [Lead Maintainers]")
// 83:     end
// 84:     raise "Could not find lead maintainers in README.md." if lead_maintainers_line.blank?
// 85:
// 86:     lead_maintainers = T.let({}, T::Hash[String, T::Boolean])
// 87:     lead_maintainers_line.scan(%r{https://github\.com/([A-Za-z0-9-]+)}) do |login|
// 88:       lead_maintainers[T.cast(login.fetch(0), String)] = true
// 89:     end
// 90:     @lead_maintainers = T.let(lead_maintainers, T::Hash[String, T::Boolean])
// 91:     @recent_approval_issues = T.let({}, T::Hash[String, GitHubPayloads])
// 92:     @recent_approval_search_complete = T.let({}, T::Hash[String, T::Boolean])
// 93:     @recent_approval_search_pages = T.let({}, T::Hash[String, Integer])
// 94:     @recent_approval_checks = T.let({}, T::Hash[[String, Integer], T.any(RecentApproval, FalseClass)])
// 95:     @recent_approval_results = T.let({}, T::Hash[String, T::Array[RecentApproval]])
// 96:     @reviews = T.let({}, T::Hash[Integer, GitHubPayloads])
// 97:     @printed_pull_request_summary = T.let(false, T::Boolean)
// 98:     @weekday_approval_window = T.let((1..5).cover?(Time.now.utc.wday), T::Boolean)
// 99:   end
// 100:
// 101:   sig { void }
// 102:   def run
// 103:     if @event_name == "push"
// 104:       report
// 105:     else
// 106:       approve
// 107:     end
// 108:   end
// 109:
// 110:   private
// 111:
// 112:   sig { void }
// 113:   def approve
// 114:     if @event_name == "workflow_dispatch" && @pull_request_number.empty?
// 115:       raise "PR_NUMBER must be set for workflow_dispatch."
// 116:     end
// 117:
// 118:     pull_requests = if @pull_request_number.empty?
// 119:       paginated_rest("#{GitHub::API_URL}/repos/#{@repository}/pulls", "state=open&per_page=#{GitHub::MAX_PER_PAGE}")
// 120:     else
// 121:       [T.cast(rest("#{GitHub::API_URL}/repos/#{@repository}/pulls/#{Integer(@pull_request_number)}"), GitHubPayload)]
// 122:     end
// 123:     puts "Evaluating #{pull_requests.length} pull request(s)."
// 124:     facts = pull_requests.map { |pull_request| evaluate(pull_request, exhaustive: false) }
// 125:
// 126:     if @event_name == "workflow_dispatch"
// 127:       requested = facts.fetch(0)
// 128:       unless requested.should_approve
// 129:         requested.failure_messages.each { |failure| puts "::error::#{failure}" }
// 130:         exit 1
// 131:       end
// 132:     end
// 133:
// 134:     approval_facts = facts.select(&:should_approve)
// 135:     puts "Approving #{approval_facts.length} pull request(s)."
// 136:     approval_facts.each do |data|
// 137:       puts "Approving pull request ##{data.number}."
// 138:       rest(
// 139:         "#{GitHub::API_URL}/repos/#{@repository}/pulls/#{data.number}/reviews",
// 140:         data:           {
// 141:           event: "APPROVE",
// 142:           body:  <<~MARKDOWN,
// 143:             Automated approval by [github-actions\\[bot\\]](#{GITHUB_ACTIONS_URL}) for [##{data.number}](#{data.pr_url}) because all requirements are met:
// 144:
// 145:             - [##{data.number}](#{data.pr_url}) is not from a fork.
// 146:             - [##{data.number}](#{data.pr_url}) is not a draft.
// 147:             - The approval workflow is running on a weekday.
// 148:             - [@#{data.author}](#{data.author_url}) is listed as a lead maintainer in [README.md](#{@server_url}/#{@repository}/blob/HEAD/README.md).
// 149:             - [@#{data.author}](#{data.author_url}) approved Homebrew/brew PR [##{data.approved_pr_number}](#{data.approved_pr_url}) in the last 7 days.
// 150:             - [##{data.number}](#{data.pr_url}) was created at least #{HUMAN_REVIEW_WINDOW_HOURS} hours ago and has had no human review since creation.
// 151:             - Copilot has already reviewed [##{data.number}](#{data.pr_url}).
// 152:             - [##{data.number}](#{data.pr_url}) does not modify `.github/` or other sensitive files.
// 153:             - All [CI jobs](#{data.checks_url}) are passing, including non-required jobs.
// 154:           MARKDOWN
// 155:         },
// 156:         request_method: :POST,
// 157:       )
// 158:       puts "Approved pull request ##{data.number}."
// 159:     end
// 160:     summarise(facts)
// 161:   end
// 162:
// 163:   sig { void }
// 164:   def report
// 165:     branch = ENV.fetch("GITHUB_REF_NAME", REPORT_BRANCH)
// 166:     query = URI.encode_www_form(state: "open", head: "Homebrew:#{branch}", per_page: 1)
// 167:     pull_requests = T.cast(rest("#{GitHub::API_URL}/repos/#{@repository}/pulls?#{query}"), GitHubPayloads)
// 168:     raise "No open pull request found for branch #{branch}." if pull_requests.empty?
// 169:
// 170:     data = evaluate(pull_requests.fetch(0), exhaustive: true)
// 171:
// 172:     puts "Reported stale lead maintainer PR approval facts for pull request ##{data.number}."
// 173:   end
// 174:
// 175:   sig { params(pull_request: GitHubPayload, exhaustive: T::Boolean).returns(PullRequestFacts) }
// 176:   def evaluate(pull_request, exhaustive:)
// 177:     number = T.cast(pull_request.fetch("number"), Integer)
// 178:     title = T.cast(pull_request.fetch("title"), String)
// 179:     author = T.cast(T.cast(pull_request.fetch("user"), GitHubPayload).fetch("login"), String)
// 180:     created_at = Time.parse(T.cast(pull_request.fetch("created_at"), String))
// 181:     draft = T.cast(pull_request.fetch("draft"), T::Boolean)
// 182:     head = T.cast(pull_request.fetch("head"), GitHubPayload)
// 183:     head_sha = T.cast(head.fetch("sha"), String)
// 184:     head_repo = T.cast(head.fetch("repo"), GitHubPayload)
// 185:     data = PullRequestFacts.new(
// 186:       number:,
// 187:       title:,
// 188:       author:,
// 189:       created_at:,
// 190:       head_sha:,
// 191:       pr_url:                  "#{@server_url}/#{@repository}/pull/#{number}",
// 192:       checks_url:              "#{@server_url}/#{@repository}/commit/#{head_sha}/checks",
// 193:       author_url:              "#{@server_url}/#{author}",
// 194:       not_from_fork:           T.cast(head_repo.fetch("full_name"), String) == @repository &&
// 195:                      !T.cast(head_repo.fetch("fork"), T::Boolean),
// 196:       draft:,
// 197:       weekday_approval_window: @weekday_approval_window,
// 198:       old_enough_for_approval: created_at <= Time.now.utc - (HUMAN_REVIEW_WINDOW_HOURS * 60 * 60),
// 199:     )
// 200:     raw_failures = []
// 201:     raw_failures << "Pull request ##{data.number} is from a fork." unless data.not_from_fork
// 202:     raw_failures << "Pull request ##{data.number} is a draft." if data.draft
// 203:     return finish(data, raw_failures) if raw_failures.any?
// 204:
// 205:     if !exhaustive && !data.weekday_approval_window
// 206:       return finish(data, ["Stale lead maintainer PR approvals do not run on Saturdays or Sundays."])
// 207:     end
// 208:
// 209:     data.lead_maintainer_checked = true
// 210:     data.lead_maintainer = @lead_maintainers.fetch(data.author, false)
// 211:     if !exhaustive && !data.lead_maintainer
// 212:       return finish(data, ["@#{data.author} is not listed as a lead maintainer in README.md."])
// 213:     end
// 214:
// 215:     approved_pr = T.let(
// 216:       @recent_approval_results[data.author]&.find { |approval| approval.number != data.number },
// 217:       T.nilable(RecentApproval),
// 218:     )
// 219:     unless approved_pr
// 220:       @recent_approval_results[data.author] ||= []
// 221:       @recent_approval_issues[data.author] ||= []
// 222:
// 223:       loop do
// 224:         @recent_approval_issues.fetch(data.author).each do |issue|
// 225:           number = T.cast(issue.fetch("number"), Integer)
// 226:           next if number == data.number
// 227:
// 228:           unless @recent_approval_checks.key?([data.author, number])
// 229:             cutoff = Time.now.utc - (7 * 24 * 60 * 60)
// 230:             @recent_approval_checks[[data.author, number]] = if reviews_for(number).any? do |review|
// 231:               review_user = T.cast(review.fetch("user"),
// 232:                                    GitHubPayload)
// 233:               T.cast(review_user.fetch("login"), String) ==
// 234:               data.author &&
// 235:               T.cast(review.fetch("state"), String) == "APPROVED" &&
// 236:               Time.parse(
// 237:                 T.cast(review.fetch("submitted_at"), String),
// 238:               ) >= cutoff
// 239:             end
// 240:               RecentApproval.new(
// 241:                 number:,
// 242:                 url:    "#{@server_url}/#{@repository}/pull/#{number}",
// 243:               )
// 244:             else
// 245:               false
// 246:             end
// 247:           end
// 248:
// 249:           approval = @recent_approval_checks.fetch([data.author, number])
// 250:           next unless approval
// 251:
// 252:           approval_results = @recent_approval_results.fetch(data.author)
// 253:           approval_results << approval unless approval_results.include?(approval)
// 254:           approved_pr = approval
// 255:           break
// 256:         end
// 257:         break if approved_pr || @recent_approval_search_complete[data.author]
// 258:
// 259:         page = @recent_approval_search_pages.fetch(data.author, 0) + 1
// 260:         cutoff_date = (Time.now.utc - (7 * 24 * 60 * 60)).to_date.iso8601
// 261:         query = "repo:#{@repository} is:pr reviewed-by:#{data.author} review:approved updated:>=#{cutoff_date}"
// 262:         issues = T.cast(
// 263:           T.cast(
// 264:             rest(
// 265:               "#{GitHub::API_URL}/search/issues?#{URI.encode_www_form(q: query, per_page: GitHub::MAX_PER_PAGE,
// 266:                                                                       page:)}",
// 267:             ),
// 268:             GitHubPayload,
// 269:           ).fetch("items"),
// 270:           GitHubPayloads,
// 271:         )
// 272:         @recent_approval_search_pages[data.author] = page
// 273:         @recent_approval_issues.fetch(data.author).concat(issues)
// 274:         @recent_approval_search_complete[data.author] = true if issues.length < GitHub::MAX_PER_PAGE
// 275:       end
// 276:     end
// 277:     data.approved_another_pr_checked = true
// 278:     data.approved_another_pr = !approved_pr.nil?
// 279:     data.approved_pr_number = approved_pr&.number.to_s
// 280:     data.approved_pr_url = approved_pr&.url.to_s
// 281:     if !exhaustive && !data.approved_another_pr
// 282:       return finish(data, [
// 283:         "@#{data.author} has not approved another Homebrew/brew PR in the last 7 days.",
// 284:       ])
// 285:     end
// 286:
// 287:     if !exhaustive && !data.old_enough_for_approval
// 288:       return finish(data, [
// 289:         "Pull request ##{data.number} was created less than #{HUMAN_REVIEW_WINDOW_HOURS} hours ago.",
// 290:       ])
// 291:     end
// 292:
// 293:     reviews = reviews_for(data.number)
// 294:     data.reviews_checked = true
// 295:     data.human_reviews_since_creation = reviews.filter_map do |review|
// 296:       review_user = T.cast(review.fetch("user"), GitHubPayload)
// 297:       submitted_at = Time.parse(T.cast(review.fetch("submitted_at"), String))
// 298:       next if submitted_at < data.created_at
// 299:       next if T.cast(review_user.fetch("type"), String) == "Bot"
// 300:
// 301:       "@#{T.cast(review_user.fetch("login"), String)} #{T.cast(review.fetch("state"), String).downcase} " \
// 302:         "at #{submitted_at.utc.iso8601}"
// 303:     end
// 304:     data.no_human_review_since_creation = data.human_reviews_since_creation.empty?
// 305:     data.copilot_reviewed = reviews.any? do |review|
// 306:       review_user = T.cast(review.fetch("user"), GitHubPayload)
// 307:       T.cast(review_user.fetch("type"), String) == "Bot" &&
// 308:         T.cast(review_user.fetch("login"), String).downcase.include?("copilot")
// 309:     end
// 310:     data.already_approved = reviews.any? do |review|
// 311:       review_user = T.cast(review.fetch("user"), GitHubPayload)
// 312:       T.cast(review_user.fetch("login"), String) == "github-actions[bot]" &&
// 313:         T.cast(review.fetch("state"), String) == "APPROVED" &&
// 314:         T.cast(review.fetch("commit_id"), String) == data.head_sha
// 315:     end
// 316:     if !exhaustive &&
// 317:        (!data.old_enough_for_approval || !data.no_human_review_since_creation || !data.copilot_reviewed ||
// 318:         data.already_approved)
// 319:       return finish(data, failures_for(data, include_ci: false))
// 320:     end
// 321:
// 322:     changed_files = paginated_rest("#{GitHub::API_URL}/repos/#{@repository}/pulls/#{data.number}/files")
// 323:     data.sensitive_files_checked = true
// 324:     data.changed_sensitive_files = changed_files.filter_map do |file|
// 325:       filename = T.cast(file.fetch("filename"), String)
// 326:       next if SENSITIVE_PATH_PREFIXES.none? { |prefix| filename.start_with?(prefix) } &&
// 327:               SENSITIVE_PATHS.exclude?(filename)
// 328:
// 329:       filename
// 330:     end
// 331:     data.sensitive_files_unchanged = data.changed_sensitive_files.empty?
// 332:     if !exhaustive && !data.sensitive_files_unchanged
// 333:       return finish(data,
// 334:                     failures_for(data, include_ci: false))
// 335:     end
// 336:
// 337:     check_runs = paginated_rest("#{GitHub::API_URL}/repos/#{@repository}/commits/#{data.head_sha}/check-runs")
// 338:                  .flat_map do |page|
// 339:                    T.cast(page.fetch("check_runs"), GitHubPayloads)
// 340:                  end
// 341:     commit_status = T.cast(rest("#{GitHub::API_URL}/repos/#{@repository}/commits/#{data.head_sha}/status"),
// 342:                            GitHubPayload)
// 343:     data.ci_checked = true
// 344:     data.failing_ci_jobs = check_runs.filter_map do |check_run|
// 345:       status = T.cast(check_run.fetch("status"), String)
// 346:       conclusion = T.cast(check_run.fetch("conclusion", nil), T.nilable(String))
// 347:       next if status == "completed" && !conclusion.nil? && APPROVABLE_CHECK_RUN_CONCLUSIONS.include?(conclusion)
// 348:
// 349:       name = T.cast(check_run.fetch("name"), String)
// 350:       url = T.cast(check_run.fetch("html_url", nil), T.nilable(String))
// 351:       "#{name}: #{status}#{"/#{conclusion}" unless conclusion.nil?}" \
// 352:         "#{" (#{url})" unless url.nil?}"
// 353:     end
// 354:     data.failing_ci_jobs << "No check runs found." if check_runs.empty?
// 355:     T.cast(commit_status.fetch("statuses"), GitHubPayloads).each do |status|
// 356:       next if T.cast(status.fetch("state"), String) == "success"
// 357:
// 358:       context = T.cast(status.fetch("context"), String)
// 359:       url = T.cast(status.fetch("target_url", nil), T.nilable(String))
// 360:       data.failing_ci_jobs << "#{context}: #{T.cast(status.fetch("state"), String)}" \
// 361:                               "#{" (#{url})" unless url.nil?}"
// 362:     end
// 363:     data.ci_passing = data.failing_ci_jobs.empty?
// 364:
// 365:     finish(data, failures_for(data))
// 366:   end
// 367:
// 368:   sig { params(data: PullRequestFacts, failure_messages: T::Array[String]).returns(PullRequestFacts) }
// 369:   def finish(data, failure_messages)
// 370:     data.requirements_met = data.not_from_fork &&
// 371:                             !data.draft &&
// 372:                             data.weekday_approval_window &&
// 373:                             data.lead_maintainer &&
// 374:                             data.approved_another_pr &&
// 375:                             data.old_enough_for_approval &&
// 376:                             data.no_human_review_since_creation &&
// 377:                             data.copilot_reviewed &&
// 378:                             data.sensitive_files_unchanged &&
// 379:                             data.ci_passing
// 380:     data.should_approve = data.requirements_met && !data.already_approved
// 381:     data.failure_messages = failure_messages
// 382:     puts if @printed_pull_request_summary
// 383:     @printed_pull_request_summary = true
// 384:     result = if @event_name == "push"
// 385:       data.should_approve ? Formatter.success("would approve") : Formatter.error("would not approve")
// 386:     elsif data.should_approve
// 387:       Formatter.success("will approve")
// 388:     else
// 389:       Formatter.error("will not approve")
// 390:     end
// 391:     oh1 "Pull request ##{data.number}: #{data.title}"
// 392:     puts "- Result: #{result}"
// 393:     puts "- Author: #{Formatter.identifier("@#{data.author}")}"
// 394:     puts "- Not from a fork: #{status_label(data.not_from_fork)}"
// 395:     puts "- Not a draft: #{status_label(!data.draft)}"
// 396:     puts "- Weekday approval window: #{status_label(data.weekday_approval_window)}"
// 397:     puts "- Created at: #{data.created_at.utc.iso8601}"
// 398:     puts "- Created at least #{HUMAN_REVIEW_WINDOW_HOURS} hours ago: #{status_label(data.old_enough_for_approval)}"
// 399:     lead_maintainer = data.lead_maintainer_checked ? data.lead_maintainer : nil
// 400:     puts "- Author listed as a lead maintainer in README.md: #{status_label(lead_maintainer)}"
// 401:     approved_another_pr = data.approved_another_pr_checked ? data.approved_another_pr : nil
// 402:     puts "- Author approved another Homebrew/brew PR in the last 7 days: #{status_label(approved_another_pr)}"
// 403:     no_human_review_since_creation = data.reviews_checked ? data.no_human_review_since_creation : nil
// 404:     puts "- No human review since creation: #{status_label(no_human_review_since_creation)}"
// 405:     if data.reviews_checked
// 406:       puts "- Human reviews since creation:"
// 407:       if data.human_reviews_since_creation.empty?
// 408:         puts "  - #{Formatter.success("none")}"
// 409:       else
// 410:         data.human_reviews_since_creation.each { |review| puts "  - #{Formatter.warning(review)}" }
// 411:       end
// 412:     else
// 413:       puts "- Human reviews since creation: #{Formatter.warning("not checked")}"
// 414:     end
// 415:     puts "- Copilot reviewed: #{status_label(data.reviews_checked ? data.copilot_reviewed : nil)}"
// 416:     sensitive_files_unchanged = data.sensitive_files_checked ? data.sensitive_files_unchanged : nil
// 417:     puts "- .github/ and sensitive files unchanged: #{status_label(sensitive_files_unchanged)}"
// 418:     if data.sensitive_files_checked && !data.changed_sensitive_files.empty?
// 419:       puts "- Changed .github/ or sensitive files:"
// 420:       data.changed_sensitive_files.each { |file| puts "  - #{Formatter.error(file)}" }
// 421:     end
// 422:     puts "- CI passing: #{status_label(data.ci_checked ? data.ci_passing : nil)}"
// 423:     if data.ci_checked
// 424:       puts "- Failing CI jobs:"
// 425:       if data.failing_ci_jobs.empty?
// 426:         puts "  - #{Formatter.success("none")}"
// 427:       else
// 428:         data.failing_ci_jobs.each { |job| puts "  - #{Formatter.error(job)}" }
// 429:       end
// 430:     else
// 431:       puts "- Failing CI jobs: #{Formatter.warning("not checked")}"
// 432:     end
// 433:     already_approved = data.reviews_checked ? data.already_approved : nil
// 434:     puts "- Already approved by github-actions[bot] for this commit: #{status_label(already_approved)}"
// 435:     data.failure_messages.each { |failure| puts "- Failure: #{failure}" }
// 436:     data
// 437:   end
// 438:
// 439:   sig { params(value: T.nilable(T::Boolean)).returns(String) }
// 440:   def status_label(value)
// 441:     return Formatter.warning("not checked") if value.nil?
// 442:
// 443:     value ? Formatter.success("true") : Formatter.error("false")
// 444:   end
// 445:
// 446:   sig { params(data: PullRequestFacts, include_ci: T::Boolean).returns(T::Array[String]) }
// 447:   def failures_for(data, include_ci: true)
// 448:     failures = []
// 449:     failures << "Pull request ##{data.number} is from a fork." unless data.not_from_fork
// 450:     failures << "Pull request ##{data.number} is a draft." if data.draft
// 451:     unless data.weekday_approval_window
// 452:       failures << "Stale lead maintainer PR approvals do not run on Saturdays or Sundays."
// 453:     end
// 454:     failures << "@#{data.author} is not listed as a lead maintainer in README.md." unless data.lead_maintainer
// 455:     unless data.approved_another_pr
// 456:       failures << "@#{data.author} has not approved another Homebrew/brew PR in the last 7 days."
// 457:     end
// 458:     unless data.old_enough_for_approval
// 459:       failures << "Pull request ##{data.number} was created less than #{HUMAN_REVIEW_WINDOW_HOURS} hours ago."
// 460:     end
// 461:     unless data.no_human_review_since_creation
// 462:       failures << "Pull request ##{data.number} has a human review since creation."
// 463:     end
// 464:     failures << "Copilot has not reviewed pull request ##{data.number}." unless data.copilot_reviewed
// 465:     unless data.sensitive_files_unchanged
// 466:       failures << "Pull request ##{data.number} changes .github/ or other sensitive files: " \
// 467:                   "#{data.changed_sensitive_files.join(", ")}."
// 468:     end
// 469:     failures << "Not all CI jobs are passing for pull request ##{data.number}." if include_ci && !data.ci_passing
// 470:     if data.already_approved
// 471:       failures << "github-actions[bot] has already approved pull request ##{data.number} for this commit."
// 472:     end
// 473:     failures
// 474:   end
// 475:
// 476:   sig { params(facts: T::Array[PullRequestFacts]).void }
// 477:   def summarise(facts)
// 478:     summary_path = ENV.fetch("GITHUB_STEP_SUMMARY", nil)
// 479:     return if summary_path.blank?
// 480:
// 481:     File.open(summary_path, "a") do |summary|
// 482:       summary.puts "## Stale lead maintainer PR approval"
// 483:       summary.puts
// 484:       facts.each do |data|
// 485:         summary.puts "### [##{data.number}](#{data.pr_url})"
// 486:         summary.puts
// 487:         summary.puts "- Pull request: [##{data.number}](#{data.pr_url})"
// 488:         summary.puts "- Author: [@#{data.author}](#{data.author_url})"
// 489:         summary.puts "- Not from a fork: #{data.not_from_fork}"
// 490:         summary.puts "- Not a draft: #{!data.draft}"
// 491:         summary.puts "- Weekday approval window: #{data.weekday_approval_window}"
// 492:         summary.puts "- Created at: #{data.created_at.utc.iso8601}"
// 493:         summary.puts "- Created at least #{HUMAN_REVIEW_WINDOW_HOURS} hours ago: " \
// 494:                      "#{data.old_enough_for_approval}"
// 495:         summary.puts "- [@#{data.author}](#{data.author_url}) is listed as a lead maintainer in " \
// 496:                      "[README.md](#{@server_url}/#{@repository}/blob/HEAD/README.md): #{data.lead_maintainer}"
// 497:         summary.puts "- [@#{data.author}](#{data.author_url}) approved another " \
// 498:                      "[Homebrew/brew PR](#{@server_url}/#{@repository}/pulls) in the last 7 days: " \
// 499:                      "#{data.approved_another_pr} (#{approved_pr_link(data)})"
// 500:         summary.puts "- No human review on [##{data.number}](#{data.pr_url}) since creation: " \
// 501:                      "#{data.no_human_review_since_creation}"
// 502:         summary.puts "- Copilot has reviewed [##{data.number}](#{data.pr_url}): " \
// 503:                      "#{data.copilot_reviewed}"
// 504:         summary.puts "- `.github/` and sensitive files are unchanged in " \
// 505:                      "[##{data.number}](#{data.pr_url}): " \
// 506:                      "#{data.sensitive_files_unchanged}"
// 507:         summary.puts "- All [CI jobs](#{data.checks_url}) are passing: #{data.ci_passing}"
// 508:         summary.puts "- Requirements met: #{data.requirements_met}"
// 509:         summary.puts "- Already approved by [github-actions\\[bot\\]](#{GITHUB_ACTIONS_URL}) for " \
// 510:                      "`#{data.head_sha}`: #{data.already_approved}"
// 511:         summary.puts "- Eligible for approval: #{data.should_approve}"
// 512:         summary.puts "- Approved by this run: #{data.should_approve}"
// 513:         summary.puts
// 514:       end
// 515:     end
// 516:   end
// 517:
// 518:   sig { params(data: PullRequestFacts).returns(String) }
// 519:   def approved_pr_link(data)
// 520:     return "none" if data.approved_pr_number.empty?
// 521:
// 522:     "[##{data.approved_pr_number}](#{data.approved_pr_url})"
// 523:   end
// 524:
// 525:   sig { params(number: Integer).returns(GitHubPayloads) }
// 526:   def reviews_for(number)
// 527:     @reviews[number] ||= paginated_rest("#{GitHub::API_URL}/repos/#{@repository}/pulls/#{number}/reviews")
// 528:   end
// 529:
// 530:   sig { params(url: T.any(String, URI::Generic), additional_query_params: String).returns(GitHubPayloads) }
// 531:   def paginated_rest(url, additional_query_params = "")
// 532:     results = T.let([], GitHubPayloads)
// 533:     GitHub::API.paginate_rest(url, additional_query_params:) do |result|
// 534:       page = T.cast(result, GitHubPage)
// 535:       if page.is_a?(Array)
// 536:         results.concat(page)
// 537:       else
// 538:         results << page
// 539:       end
// 540:     end
// 541:     results
// 542:   end
// 543:
// 544:   sig {
// 545:     params(
// 546:       url:            T.any(String, URI::Generic),
// 547:       data:           RequestData,
// 548:       request_method: Symbol,
// 549:     ).returns(GitHubResult)
// 550:   }
// 551:   def rest(url, data: {}, request_method: :GET)
// 552:     GitHub::API.open_rest(url, data:, request_method:)
// 553:   end
// 554: end
// 555:
// 556: StaleLeadMaintainerPrApproval.new.run
