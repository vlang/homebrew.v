module dev_cmd

import ruby
import time

// Translated from Homebrew/brew `dev-cmd/release.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct ReleaseRecord {
pub:
	id           i64
	name         string
	tag_name     string
	created_at   string
	published_at string
	html_url     string
	draft        bool
}

pub struct ReleaseWorkflowRun {
pub:
	head_sha   string
	created_at string
	status     string
	conclusion string
	html_url   string
}

pub struct ReleaseOptions {
pub:
	major                              bool
	minor                              bool
	force                              bool
	no_auto_update                     bool
	today                              string
	issues                             map[string][]ReleaseRecord
	issues_error                       string
	latest_release                     ReleaseRecord
	latest_release_missing             bool
	latest_major_minor_release         ReleaseRecord
	latest_major_minor_release_present bool
	blog_release_notes                 string
	release_notes                      string
	release_notes_error                string
	releases                           []ReleaseRecord
	created_releases                   []ReleaseRecord
	matching_releases_error            string
	current_sha                        string
	upstream_sha                       string
	upstream_sha_error                 string
	dispatch_error                     string
	dispatch_time                      string
	workflow_runs                      [][]ReleaseWorkflowRun
	workflow_status_error_at_attempt   int
	workflow_status_error              string
	max_attempts                       int = 180
	locate_created_release_error       string
}

pub struct ReleaseResult {
pub mut:
	new_version         string
	latest_version      string
	blog_post_notes     []string
	release_notes       string
	stdout              []string
	warnings            []string
	commands            [][]string
	blocking_labels     []string
	dispatched          bool
	dispatched_tag      string
	workflow_attempts   int
	workflow_conclusion string
	release_url         string
	browser_url         string
}

pub struct ReleaseCommand {
pub:
	options ReleaseOptions
}

@[heap]
pub struct ReleaseRunInput {
pub:
	options ReleaseOptions
}

@[heap]
pub struct ReleaseLookupInput {
pub:
	name     string
	releases []ReleaseRecord
}

@[heap]
pub struct ReleaseUrlsInput {
pub:
	releases []ReleaseRecord
}

struct ReleaseVersion {
	major int
	minor int
	patch int
}

pub fn new_release_command(options ReleaseOptions) ReleaseCommand {
	return ReleaseCommand{
		options: options
	}
}

fn parse_release_version(value string) !ReleaseVersion {
	mut normalized := value.trim_space()
	if normalized.starts_with('v') && normalized.len > 1 {
		normalized = normalized[1..]
	}
	if underscore := normalized.index('_') {
		normalized = normalized[..underscore]
	}
	if dash := normalized.index('-') {
		normalized = normalized[..dash]
	}
	parts := normalized.split('.')
	if parts.len < 1 || parts.len > 3 || parts[0] == '' {
		return error('invalid release version `${value}`')
	}
	major := parts[0].int()
	minor := if parts.len > 1 { parts[1].int() } else { 0 }
	patch := if parts.len > 2 { parts[2].int() } else { 0 }
	if major < 0 || minor < 0 || patch < 0 || major.str() != parts[0]
		|| (parts.len > 1 && minor.str() != parts[1])
		|| (parts.len > 2 && patch.str() != parts[2]) {
		return error('invalid release version `${value}`')
	}
	return ReleaseVersion{
		major: major
		minor: minor
		patch: patch
	}
}

fn release_version_string(version ReleaseVersion) string {
	return '${version.major}.${version.minor}.${version.patch}'
}

fn next_release_version(version ReleaseVersion, major bool, minor bool) string {
	if major {
		return '${version.major + 1}.0.0'
	}
	if minor {
		return '${version.major}.${version.minor + 1}.0'
	}
	return '${version.major}.${version.minor}.${version.patch + 1}'
}

fn release_is_leap_year(year int) bool {
	return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
}

fn release_days_in_month(year int, month int) int {
	return match month {
		2 {
			if release_is_leap_year(year) { 29 } else { 28 }
		}
		4, 6, 9, 11 { 30 }
		else { 31 }
	}
}

fn release_previous_month(date string) !string {
	parts := date.split('-')
	if parts.len != 3 {
		return error('invalid date `${date}`')
	}
	mut year := parts[0].int()
	mut month := parts[1].int() - 1
	day := parts[2].int()
	if month == 0 {
		month = 12
		year--
	}
	if year <= 0 || month < 1 || month > 12 || day < 1 {
		return error('invalid date `${date}`')
	}
	clamped_day := if day > release_days_in_month(year, month) {
		release_days_in_month(year, month)
	} else {
		day
	}
	return '${year:04d}-${month:02d}-${clamped_day:02d}'
}

fn release_date_prefix(value string) !string {
	if value.len < 10 {
		return error('invalid date `${value}`')
	}
	date := value[..10]
	parts := date.split('-')
	if parts.len != 3 || parts[0].len != 4 || parts[1].len != 2 || parts[2].len != 2 {
		return error('invalid date `${value}`')
	}
	year := parts[0].int()
	month := parts[1].int()
	day := parts[2].int()
	if year <= 0 || month < 1 || month > 12 || day < 1 || day > release_days_in_month(year, month) {
		return error('invalid date `${value}`')
	}
	return date
}

fn release_time_epoch(value string) i64 {
	if parsed := time.parse_iso8601(value) {
		return parsed.unix()
	}
	return 0
}

fn release_unique(values []string) []string {
	mut result := []string{}
	mut seen := map[string]bool{}
	for value in values {
		if value !in seen {
			seen[value] = true
			result << value
		}
	}
	return result
}

pub fn release_urls(releases []ReleaseRecord) []string {
	mut urls := []string{}
	for release in releases {
		url := release.html_url.trim_space()
		if url != '' {
			urls << '  ${url}'
		}
	}
	return urls
}

pub fn matching_releases(name string, releases []ReleaseRecord) []ReleaseRecord {
	mut matching := []ReleaseRecord{}
	for release in releases {
		release_name := if release.name.trim_space() == '' {
			release.tag_name
		} else {
			release.name
		}
		if release_name == name {
			matching << release
		}
	}
	return matching
}

pub fn latest_matching_release(name string, releases []ReleaseRecord) ?ReleaseRecord {
	matches := matching_releases(name, releases)
	if matches.len == 0 {
		return none
	}
	mut latest := matches[0]
	mut latest_time := release_time_epoch(latest.created_at)
	for release in matches[1..] {
		created_at := release_time_epoch(release.created_at)
		if created_at > latest_time {
			latest = release
			latest_time = created_at
		}
	}
	return latest
}

fn release_blog_post_notes(body string) []string {
	mut notes := []string{}
	for raw_line in body.split_into_lines() {
		line := raw_line.trim_right('\r')
		if !line.starts_with('* ') {
			continue
		}
		by_index := line.index(' by @') or { continue }
		in_index := line.index_after(' in ', by_index + 5) or { continue }
		title := line[2..by_index]
		username := line[by_index + 5..in_index]
		url := line[in_index + 4..]
		if title == '' || username == '' || url == '' {
			continue
		}
		mut valid_username := true
		for character in username {
			if !character.is_alnum() && character != `-` && character != `_` {
				valid_username = false
				break
			}
		}
		if valid_username {
			notes << '- [${title}](${url})'
		}
	}
	notes.sort()
	return notes
}

fn release_result_value(result ReleaseResult) ruby.Value {
	return ruby.map_value({
		'new_version':         ruby.string_value(result.new_version)
		'latest_version':      ruby.string_value(result.latest_version)
		'blog_post_notes':     ruby.string_array_value(result.blog_post_notes)
		'release_notes':       ruby.string_value(result.release_notes)
		'stdout':              ruby.string_array_value(result.stdout)
		'warnings':            ruby.string_array_value(result.warnings)
		'commands':            ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'blocking_labels':     ruby.string_array_value(result.blocking_labels)
		'dispatched':          ruby.bool_value(result.dispatched)
		'dispatched_tag':      ruby.string_value(result.dispatched_tag)
		'workflow_attempts':   ruby.int_value(result.workflow_attempts)
		'workflow_conclusion': ruby.string_value(result.workflow_conclusion)
		'release_url':         ruby.string_value(result.release_url)
		'browser_url':         ruby.string_value(result.browser_url)
	})
}

fn release_record_value(release ReleaseRecord) ruby.Value {
	return ruby.map_value({
		'id':           ruby.int_value(release.id)
		'name':         if release.name == '' {
			ruby.object_value('NilClass', 'nil')
		} else {
			ruby.string_value(release.name)
		}
		'tag_name':     ruby.string_value(release.tag_name)
		'created_at':   ruby.string_value(release.created_at)
		'published_at': ruby.string_value(release.published_at)
		'html_url':     ruby.string_value(release.html_url)
		'draft':        ruby.bool_value(release.draft)
	})
}

pub fn release_run_input_boundary(input &ReleaseRunInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Release::RunInput', '', {
		'release_run_input_address': u64(voidptr(input)).str()
	})
}

fn release_run_input_from_value(value ruby.Value) &ReleaseRunInput {
	address := value.attributes['release_run_input_address'] or {
		panic('invalid Release run input')
	}
	return unsafe { &ReleaseRunInput(voidptr(address.u64())) }
}

pub fn release_lookup_input_boundary(input &ReleaseLookupInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Release::LookupInput', '', {
		'release_lookup_input_address': u64(voidptr(input)).str()
	})
}

fn release_lookup_input_from_value(value ruby.Value) &ReleaseLookupInput {
	address := value.attributes['release_lookup_input_address'] or {
		panic('invalid Release lookup input')
	}
	return unsafe { &ReleaseLookupInput(voidptr(address.u64())) }
}

pub fn release_urls_input_boundary(input &ReleaseUrlsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Release::UrlsInput', '', {
		'release_urls_input_address': u64(voidptr(input)).str()
	})
}

fn release_urls_input_from_value(value ruby.Value) &ReleaseUrlsInput {
	address := value.attributes['release_urls_input_address'] or {
		panic('invalid Release URLs input')
	}
	return unsafe { &ReleaseUrlsInput(voidptr(address.u64())) }
}

pub fn run_release(options ReleaseOptions) !ReleaseResult {
	if options.major && options.minor {
		return error('`--major` and `--minor` are mutually exclusive')
	}
	mut result := ReleaseResult{}
	if options.no_auto_update {
		result.commands << ['git', '-C', 'HOMEBREW_REPOSITORY', 'fetch', 'origin']
	}

	result.blocking_labels = ['release blocker']
	if options.major || options.minor {
		result.blocking_labels << 'major/minor release blocker'
	}
	if options.issues_error != '' {
		return error('Unable to check for release blockers: ${options.issues_error}!')
	}
	mut blockers := []ReleaseRecord{}
	for label in result.blocking_labels {
		blockers << options.issues[label]
	}
	if blockers.len > 0 {
		urls := release_unique(release_urls(blockers))
		return error('Open issues or pull requests are blocking this release:\n${urls.join('\n')}')
	}

	if options.latest_release_missing || options.latest_release.tag_name.trim_space() == '' {
		return error('No existing releases found!')
	}
	latest := parse_release_version(options.latest_release.tag_name)!
	result.latest_version = release_version_string(latest)

	if options.major || options.minor {
		if !options.latest_major_minor_release_present {
			result.warnings << 'Unable to determine the release date of the latest major/minor release.'
		} else {
			today := if options.today == '' {
				time.now().format_ss_micro()[..10]
			} else {
				options.today
			}
			one_month_ago := release_previous_month(today)!
			published_at := release_date_prefix(options.latest_major_minor_release.published_at)!
			if published_at > one_month_ago {
				return error('The latest major/minor release was less than one month ago.')
			}
		}
	}

	result.new_version = next_release_version(latest, options.major, options.minor)
	if options.release_notes_error != '' {
		return error(options.release_notes_error)
	}
	if options.major || options.minor {
		latest_major_minor_version := '${latest.major}.${latest.minor}.0'
		result.stdout << 'Release notes since ${latest_major_minor_version} for ${result.new_version} blog post:'
		result.blog_post_notes = release_blog_post_notes(options.blog_release_notes)
		result.stdout << result.blog_post_notes
	}
	result.stdout << 'Generating release notes for ${result.new_version}'
	mut notes := ''
	if options.major || options.minor {
		notes = 'Release notes for this release can be found on the [Homebrew blog](https://brew.sh/blog/${result.new_version}).\n'
	}
	notes += options.release_notes
	result.release_notes = notes
	result.stdout << notes
	result.stdout << ''

	if !options.force {
		result.warnings << 'Use `brew release --force` to trigger the release workflow and create the draft release.'
		return result
	}
	if options.matching_releases_error != '' {
		return error('Unable to check existing releases: ${options.matching_releases_error}!')
	}
	existing_releases := matching_releases(result.new_version, options.releases)
	if existing_releases.len > 0 {
		mut drafts := []ReleaseRecord{}
		mut published := []ReleaseRecord{}
		for release in existing_releases {
			if release.draft {
				drafts << release
			} else {
				published << release
			}
		}
		mut messages := []string{}
		if drafts.len > 0 {
			messages << 'Draft releases already exist for ${result.new_version}. Delete them in the web interface first:\n${release_urls(drafts).join('\n')}'
		}
		if published.len > 0 {
			messages << 'Published releases already exist for ${result.new_version}. Run `brew update` instead:\n${release_urls(published).join('\n')}'
		}
		return error(messages.join('\n'))
	}

	if options.upstream_sha_error != '' {
		return error('Unable to check upstream Homebrew/brew main: ${options.upstream_sha_error}!')
	}
	current_sha := options.current_sha.trim_space()
	if current_sha != options.upstream_sha {
		return error('Local Homebrew/brew `origin/main` is not up-to-date with upstream `main`. Run `brew update` before `brew release --force`.')
	}
	if options.dispatch_error != '' {
		return error('Unable to trigger workflow: ${options.dispatch_error}!')
	}
	result.stdout << 'Triggering release workflow for ${result.new_version}...'
	result.dispatched = true
	result.dispatched_tag = result.new_version

	dispatch_time := release_time_epoch(options.dispatch_time)
	max_attempts := if options.max_attempts > 0 { options.max_attempts } else { 180 }
	mut conclusion := ''
	for attempt in 1 .. max_attempts + 1 {
		result.workflow_attempts = attempt
		if options.workflow_status_error_at_attempt == attempt {
			return error('Unable to check workflow status: ${options.workflow_status_error}!')
		}
		runs := if options.workflow_runs.len == 0 {
			[]ReleaseWorkflowRun{}
		} else if attempt <= options.workflow_runs.len {
			options.workflow_runs[attempt - 1]
		} else {
			options.workflow_runs.last()
		}
		mut matching_run := ?ReleaseWorkflowRun(none)
		for run in runs {
			if run.head_sha == current_sha && release_time_epoch(run.created_at) >= dispatch_time {
				matching_run = run
				break
			}
		}
		run := matching_run or {
			return error('Unable to find workflow for commit: ${current_sha}!')
		}
		if run.status == 'completed' {
			conclusion = run.conclusion
			break
		}
		if attempt == 1 {
			result.stdout << 'This will take a few minutes. You can monitor progress at:'
			result.stdout << '  ${run.html_url}'
			result.stdout << 'Waiting for workflow to complete...'
		} else {
			result.stdout << '.'
		}
	}
	result.workflow_conclusion = conclusion
	if conclusion != 'success' {
		return error('Workflow completed with status: ${conclusion}!')
	}

	result.stdout << ''
	result.stdout << 'Release created at:'
	default_url := 'https://github.com/Homebrew/brew/releases'
	mut release_url := default_url
	if options.locate_created_release_error != '' {
		result.warnings << 'Unable to locate created release: ${options.locate_created_release_error}'
	} else if release := latest_matching_release(result.new_version, options.created_releases) {
		if release.html_url != '' {
			release_url = release.html_url
		}
	}
	result.release_url = release_url
	result.browser_url = release_url
	result.stdout << '  ${release_url}'
	return result
}

// Ruby method `run` at line 39.
pub fn ruby_release_l39_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	input := release_run_input_from_value(args[0])
	result := run_release(input.options) or {
		return ruby.object_value('SystemExit', err.msg())
	}
	return release_result_value(result)
}

// Ruby method `matching_releases(name)` at line 233.
pub fn ruby_release_l233_d2_matching_releases(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'lookup input is required')
	}
	input := release_lookup_input_from_value(args[0])
	return ruby.array_value(matching_releases(input.name, input.releases).map(release_record_value(it)))
}

// Ruby method `latest_matching_release(name)` at line 247.
pub fn ruby_release_l247_d3_latest_matching_release(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'lookup input is required')
	}
	input := release_lookup_input_from_value(args[0])
	if release := latest_matching_release(input.name, input.releases) {
		return release_record_value(release)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `release_urls(releases)` at line 258.
pub fn ruby_release_l258_d4_release_urls(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'releases input is required')
	}
	input := release_urls_input_from_value(args[0])
	return ruby.string_array_value(release_urls(input.releases))
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
