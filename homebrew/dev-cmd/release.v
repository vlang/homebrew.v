module dev_cmd

import ruby
import time

// Translated from Homebrew/brew `dev-cmd/release.rb`.

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
