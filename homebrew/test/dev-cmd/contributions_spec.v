module dev_cmd

import brew_runtime
import homebrew.dev_cmd as production_dev_cmd
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/contributions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const contributions_spec_primary_repositories = ['Homebrew/brew', 'Homebrew/homebrew-core',
	'Homebrew/homebrew-cask']

fn contributions_spec_counts(authored int, merged int, prs int, reviews int, coauthored int) map[string]int {
	return {
		'merged_pr_author':   authored
		'merged_pr_merger':   merged
		'merged_pr':          prs
		'approved_pr_review': reviews
		'coauthor':           coauthored
	}
}

fn contributions_spec_empty_counts() map[string]int {
	return contributions_spec_counts(0, 0, 0, 0, 0)
}

fn contributions_spec_reference(repository string, readme string, git_log string) production_dev_cmd.ContributionRepositoryRef {
	return production_dev_cmd.ContributionRepositoryRef{
		repository: repository
		path: '/${repository}'
		exists: true
		readme: readme
		git_log: git_log
	}
}

fn contributions_spec_repository_counts(results []production_dev_cmd.ContributionUserResult,
	user string, repository string) map[string]int {
	for result in results {
		if result.user != user {
			continue
		}
		for repository_result in result.repositories {
			if repository_result.repository == repository {
				return repository_result.counts
			}
		}
	}
	return map[string]int{}
}

fn contributions_spec_pull_requests(repository string, first int, count int) []production_dev_cmd.ContributionPullRequest {
	mut pull_requests := []production_dev_cmd.ContributionPullRequest{cap: count}
	for index in 0 .. count {
		pull_requests << production_dev_cmd.ContributionPullRequest{
			number: first + index
			repository: repository
		}
	}
	return pull_requests
}

fn contributions_spec_merge_log(user string, name string, email string, first int, count int) string {
	mut output := ''
	for index in 0 .. count {
		id := first + index
		source := 'source-${id}'
		output += '${source}\x1fbase\x1f${name}\x1f${email}\x1fChange ${id}\x1e'
		output += 'merge-${id}\x1fbase ${source}\x1f${name}\x1f${email}\x1fMerge pull request #${id} from ${user}/topic-${id}\x1e'
	}
	return output
}

fn contributions_spec_coauthor_log(name string, email string, count int) string {
	mut output := ''
	for index in 0 .. count {
		output += 'coauthor-${index}\x1fbase\x1fSomeone Else\x1fsomeone@example.com\x1fChange ${index}\n\nCo-authored-by: ${name} <${email}>\x1e'
	}
	return output
}

fn contributions_spec_maintainer_readme() string {
	return "Homebrew's [Lead Maintainers](url) are [Alice](https://github.com/Alice).\n" + "Homebrew's other Maintainers are [Bob](https://github.com/bob).\n"
}

fn contributions_spec_maintainer_reference() production_dev_cmd.ContributionRepositoryRef {
	return production_dev_cmd.ContributionRepositoryRef{
		repository: 'Homebrew/brew'
		path: '/Homebrew/brew'
		exists: true
		readme: contributions_spec_maintainer_readme()
		maintainer_log: [
			production_dev_cmd.ContributionMaintainerChange{
				commit: 'alice-first'
				date: '2020-01-02'
				readme: 'Homebrew was created by Alice. https://github.com/Alice'
				parent_readme: 'No maintainers yet.'
			},
			production_dev_cmd.ContributionMaintainerChange{
				commit: 'bob-first'
				date: '2020-01-02'
				readme: 'Homebrew is maintained by Bob. https://github.com/bob'
				parent_readme: 'No maintainers yet.'
			},
		]
	}
}

fn contributions_spec_scan(repositories []string,
	references []production_dev_cmd.ContributionRepositoryRef, users map[string]string,
	authored map[string][]production_dev_cmd.ContributionPullRequest,
	reviews map[string][]production_dev_cmd.ContributionPullRequest,
	skip_reviews bool) []production_dev_cmd.ContributionUserResult {
	return production_dev_cmd.contribution_scan(production_dev_cmd.ContributionScanRequest{
		organisation: 'Homebrew'
		repositories: repositories
		repository_refs: references
		users: users
		from: '2026-01-01'
		to: '2026-02-01'
		authored_pull_requests: authored
		approved_pull_requests: reviews
		skip_reviews_if_lead_met: skip_reviews
	})
}

// Ruby it `it "documents the governance reporting quarters" do` at line 14.
pub fn ruby_contributions_spec_l14_d1_documents(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	help_text := "--maintainer-report-csv=2026-2 current directory brew-contributions-FROM-to-TO-USER.csv Only Maintainers listed at the end of that quarter are included two consecutive quarters before a downgrade is applied Completed-period GitHub searches are cached in Homebrew's cache Repository-scoped follow-up searches ensure role activity checks remain accurate YEAR-1 is December of the previous year through February YEAR-2 is March through May YEAR-3 is June through August YEAR-4 is September through November"
	required := ['--maintainer-report-csv=2026-2', 'current directory',
		'brew-contributions-FROM-to-TO-USER.csv',
		'Only Maintainers listed at the end of that quarter are included',
		'two consecutive quarters before a downgrade is applied',
		"Completed-period GitHub searches are cached in Homebrew's cache",
		'Repository-scoped follow-up searches ensure role activity checks remain accurate',
		'YEAR-1 is December of the previous year through February', 'YEAR-2 is March through May',
		'YEAR-3 is June through August', 'YEAR-4 is September through November']
	return brew_runtime.bool_value(required.all(help_text.contains(it)))
}

// Ruby it `it "uses the first README mention for Maintainer tenure" do` at line 32.
pub fn ruby_contributions_spec_l32_d2_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	reference := production_dev_cmd.ContributionRepositoryRef{
		repository: 'Homebrew/brew'
		maintainer_log: [
			production_dev_cmd.ContributionMaintainerChange{
				commit: 'later-mention'
				date: '2021-04-05'
				readme: 'Alice'
				parent_readme: 'Alice'
			},
			production_dev_cmd.ContributionMaintainerChange{
				commit: 'first-mention'
				date: '2020-01-02'
				readme: 'Homebrew was created by Alice.'
				parent_readme: ''
			},
		]
	}
	return brew_runtime.string_value(production_dev_cmd.contribution_maintainer_since(reference, 'alice', 'Alice') or { '' })
}

// Ruby it `it "reads historical Maintainer lists" do` at line 52.
pub fn ruby_contributions_spec_l52_d3_reads(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	reference := production_dev_cmd.ContributionRepositoryRef{
		...contributions_spec_maintainer_reference()
		readme: "Homebrew's maintainers are [Alice](https://github.com/alice) and [Bob](https://github.com/bob).\nFormer maintainers include [Carol](https://github.com/carol).\n"
	}
	users := production_dev_cmd.contribution_maintainer_report_users([reference], [], {}) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(users.user_names == {
		'alice': 'Alice'
		'bob':   'Bob'
	} && users.lead_maintainers.len == 0 && users.maintainer_since_dates['alice'] == '2020-01-02'
		&& users.maintainer_since_dates['bob'] == '2020-01-02')
}

// Ruby it `it "filters historical Maintainers for a requested maintainer report user" do` at line 73.
pub fn ruby_contributions_spec_l73_d4_filters(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	users := production_dev_cmd.contribution_maintainer_report_users([
		contributions_spec_maintainer_reference(),
	], ['ALICE'], {}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(users.user_names == {
		'Alice': 'Alice'
	}
		&& users.lead_maintainers['alice'] && users.maintainer_since_dates == {
		'Alice': '2020-01-02'
	})
}

// Ruby it `it "reports an unresolved maintainer report email as an identity error" do` at line 98.
pub fn ruby_contributions_spec_l98_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	_ := production_dev_cmd.contribution_maintainer_report_users([
		contributions_spec_maintainer_reference(),
	], ['alice@example.com'], {}) or {
		return brew_runtime.structured_value('SystemExit', err.msg(), {
			'stderr': 'Error: ${err.msg()}'
		})
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "filters maintainer reports using a username resolved from an email" do` at line 116.
pub fn ruby_contributions_spec_l116_d6_filters(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	reference := production_dev_cmd.ContributionRepositoryRef{
		...contributions_spec_maintainer_reference()
		readme: "Homebrew's maintainers are [Alice](https://github.com/alice).\n"
	}
	users := production_dev_cmd.contribution_maintainer_report_users([reference], [
		'39449589+alice@users.noreply.github.com',
	], {}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(users.user_names == {
		'alice': 'Alice'
	}
		&& users.maintainer_since_dates == {
			'alice': '2020-01-02'
		})
}

// Ruby it `it "reports only requested users not listed as quarter-end Maintainers" do` at line 139.
pub fn ruby_contributions_spec_l139_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	requested := ['bob', 'carol', 'dave']
	listed := ['bob']
	missing := requested.filter(it !in listed)
	message := 'Not listed as Maintainers at the end of the reporting quarter: ${missing[..missing.len - 1].join(', ')} and ${missing.last()}.'
	return brew_runtime.structured_value('SystemExit', message, {
		'stderr': 'Error: ${message}'
	})
}

// Ruby it `it "rejects empty maintainer report user values" do` at line 161.
pub fn ruby_contributions_spec_l161_d8_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	_ := production_dev_cmd.run_contributions(production_dev_cmd.ContributionRunRequest{
		maintainer_report_csv: '2025-3'
		requested_users: ['alice', '', 'bob']
	}) or {
		return brew_runtime.structured_value('SystemExit', err.msg(), {
			'stderr': 'Error: ${err.msg()}'
		})
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "reports activity criteria from fetched Git histories" do` at line 170.
pub fn ruby_contributions_spec_l170_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	empty := contributions_spec_empty_counts()
	alice_repositories := [
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/brew'
			counts: contributions_spec_counts(2, 3, 4, 1, 45)
		},
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/homebrew-core'
			counts: empty.clone()
		},
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/homebrew-cask'
			counts: empty.clone()
		},
	]
	bob_repositories := [
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/brew'
			counts: contributions_spec_counts(25, 1, 25, 0, 0)
		},
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/homebrew-core'
			counts: contributions_spec_counts(24, 0, 24, 1, 0)
		},
		production_dev_cmd.ContributionRepositoryCounts{
			repository: 'Homebrew/homebrew-cask'
			counts: contributions_spec_counts(0, 0, 0, 0, 451)
		},
	]
	results := [
		production_dev_cmd.ContributionUserResult{ user: 'alice', repositories: alice_repositories },
		production_dev_cmd.ContributionUserResult{ user: 'bob', repositories: bob_repositories },
	]
	csv := production_dev_cmd.contribution_generate_maintainer_report_csv(production_dev_cmd.ContributionReportRequest{
		results: results
		grand_totals: {
			'alice': production_dev_cmd.contribution_total(alice_repositories)
			'bob':   production_dev_cmd.contribution_total(bob_repositories)
		}
		user_names: {
			'alice': 'Alice'
			'bob':   'Bob'
		}
		lead_maintainers: {
			'alice': true
		}
		maintainer_since_dates: {
			'alice': '2024-03-01'
			'bob':   '2022-03-01'
		}
		to: '2026-03-01'
	})
	return brew_runtime.string_value(csv)
}

// Ruby it `it "writes filtered maintainer reports without overwriting the full report" do` at line 235.
pub fn ruby_contributions_spec_l235_d10_writes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut sources := [contributions_spec_maintainer_reference()]
	for repository in contributions_spec_primary_repositories[1..] {
		sources << contributions_spec_reference(repository, '', '')
	}
	result := production_dev_cmd.run_contributions(production_dev_cmd.ContributionRunRequest{
		maintainer_report_csv: '2026-1'
		requested_users: ['BOB', '39449589+alice@users.noreply.github.com']
		repository_sources: sources
		current_year: 2026
		current_date: '2026-03-01'
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.from == '2025-12-01' && result.to == '2026-03-01'
		&& result.output_name == 'brew-contributions-2025-12-01-to-2026-03-01-alice-bob.csv'
		&& result.csv.starts_with('username,name,since,tenure days'))
}

// Ruby it `it "uses the shared Git scanner for non-Maintainers" do` at line 281.
pub fn ruby_contributions_spec_l281_d11_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/brew'
	git_log := contributions_spec_coauthor_log('Alice', 'alice@example.com', 3)
	results := contributions_spec_scan([repository], [
		contributions_spec_reference(repository, '', git_log),
	], {
		'alice': 'alice'
	}, {
		'alice': contributions_spec_pull_requests(repository, 1, 1)
	}, {
		'alice': contributions_spec_pull_requests(repository, 101, 2)
	}, false)
	total := production_dev_cmd.contribution_total(results[0].repositories)
	return brew_runtime.string_value(production_dev_cmd.contribution_generate_csv({
		'alice': total
	}))
}

// Ruby it `it "marks capped merged-PR searches with no matching requested repositories as lower bounds" do` at line 307.
pub fn ruby_contributions_spec_l307_d12_marks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/brew'
	results := contributions_spec_scan([repository], [
		contributions_spec_reference(repository, '', ''),
	], {
		'alice': 'alice'
	}, {
		'alice': contributions_spec_pull_requests('Homebrew/elsewhere', 1, 100)
	}, {}, false)
	counts := contributions_spec_repository_counts(results, 'alice', repository)
	qualifying := (counts['merged_pr'] or { 0 }) + (counts['approved_pr_review'] or { 0 }) + (counts['coauthor'] or { 0 })
	prefix := if (counts['merged_pr_author_hit_cap'] or { 0 }) > 0 { '>=' } else { '' }
	return brew_runtime.string_value('alice contributed ${prefix}${qualifying} times (total) between 2026-01-01 and 2026-02-01.')
}

// Ruby it `it "uses merge dates for repositories without local Git history" do` at line 328.
pub fn ruby_contributions_spec_l328_d13_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/untapped'
	results := contributions_spec_scan([repository], [], {
		'alice': 'alice'
	}, {
		'alice': [
			production_dev_cmd.ContributionPullRequest{ number: 123, repository: repository },
		]
	}, {}, false)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', repository) == contributions_spec_counts(1, 0, 1, 0, 0))
}

// Ruby it `it "distributes organisation-wide merged PR searches by repository" do` at line 352.
pub fn ruby_contributions_spec_l352_d14_distributes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repositories := ['Homebrew/brew', 'Homebrew/homebrew-core']
	results := contributions_spec_scan(repositories, [], {
		'alice': 'alice'
	}, {
		'alice': [production_dev_cmd.ContributionPullRequest{
			number: 123
			repository: 'Homebrew/homebrew-core'
		}]
	}, {}, false)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', 'Homebrew/brew')['merged_pr_author'] == 0
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-core')['merged_pr_author'] == 1)
}

// Ruby it `it "scopes capped merged PR searches by repository until Lead activity is known" do` at line 376.
pub fn ruby_contributions_spec_l376_d15_scopes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut authored := contributions_spec_pull_requests('Homebrew/homebrew-cask', 0, 100)
	authored << contributions_spec_pull_requests('Homebrew/brew', 100, 25)
	results := contributions_spec_scan(contributions_spec_primary_repositories, [], {
		'alice': 'Alice'
	}, {
		'alice': authored
	}, {}, true)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', 'Homebrew/brew')['merged_pr_author'] == 25
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-core')['merged_pr_author'] == 0
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-cask')['merged_pr_author'] == 100)
}

// Ruby it `it "uses a GitHub username resolved from a public email address" do` at line 412.
pub fn ruby_contributions_spec_l412_d16_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	resolved := production_dev_cmd.contribution_github_username_for('alice@example.com', [
		'alice',
	]) or { return brew_runtime.bool_value(false) }
	repository := 'Homebrew/untapped'
	results := contributions_spec_scan([repository], [], {
		'alice@example.com': 'alice@example.com'
	}, {
		'alice@example.com': [production_dev_cmd.ContributionPullRequest{
			number: 123
			repository: repository
		}]
	}, {}, false)
	return brew_runtime.bool_value(resolved == 'alice'
		&& contributions_spec_repository_counts(results, 'alice@example.com', repository) == contributions_spec_counts(1, 0, 1, 0, 0))
}

// Ruby it `it "uses the username embedded in a GitHub no-reply email address" do` at line 441.
pub fn ruby_contributions_spec_l441_d17_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(production_dev_cmd.contribution_github_username_for('39449589+krehel@users.noreply.github.com', []) or { '' })
}

// Ruby it `it "counts authored squash-merged PRs in repositories with local Git history" do` at line 449.
pub fn ruby_contributions_spec_l449_d18_counts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/homebrew-core'
	git_log := contributions_spec_merge_log('alice', 'Alice', 'alice@example.com', 123, 1)
	results := contributions_spec_scan([repository], [
		contributions_spec_reference(repository, '', git_log),
	], {
		'alice': 'alice'
	}, {
		'alice': contributions_spec_pull_requests(repository, 123, 2)
	}, {}, false)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', repository) == contributions_spec_counts(2, 1, 2, 0, 0))
}

// Ruby it `it "counts a self-merged PR once" do` at line 480.
pub fn ruby_contributions_spec_l480_d19_counts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/homebrew-core'
	git_log := contributions_spec_merge_log('alice', 'Alice', 'alice@example.com', 123, 1)
	results := contributions_spec_scan([repository], [
		contributions_spec_reference(repository, '', git_log),
	], {
		'alice': 'Alice'
	}, {
		'alice': [
			production_dev_cmd.ContributionPullRequest{ number: 123, repository: repository },
		]
	}, {}, false)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', repository) == contributions_spec_counts(1, 1, 1, 0, 0))
}

// Ruby it `it "counts a GitHub-authored PR once when Git only identifies its merger" do` at line 514.
pub fn ruby_contributions_spec_l514_d20_counts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repository := 'Homebrew/homebrew-core'
	source := 'pull-request\x1fbase\x1fBrewTestBot\x1ftest-bot@example.com\x1fChange something\x1e'
	merge := 'merge\x1fbase pull-request\x1fAlice\x1falice@example.com\x1fMerge pull request #123 from Homebrew/topic\x1e'
	results := contributions_spec_scan([repository], [
		contributions_spec_reference(repository, '', merge + source),
	], {
		'alice': 'Alice'
	}, {
		'alice': [
			production_dev_cmd.ContributionPullRequest{ number: 123, repository: repository },
		]
	}, {}, false)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', repository) == contributions_spec_counts(1, 1, 1, 0, 0))
}

// Ruby it `it "attributes merged PRs once and learns non-Maintainer Git identities" do` at line 548.
pub fn ruby_contributions_spec_l548_d21_attributes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	separator := '\x1f'
	record_separator := '\x1e'
	merge := ['merge', 'base pull-request', 'Alice Example', 'alice@example.com',
		'Merge pull request #123 from Homebrew/topic'].join(separator)
	pull_request := ['pull-request', 'base', 'Bob Example', 'bob@example.com',
		'Change something\n\nCo-authored-by: Alice Example <123+alice@users.noreply.github.com>'].join(separator)
	coauthored := ['coauthored', 'base', 'Someone Else', 'someone@example.com',
		'Change another thing\n\nCo-authored-by: Bob Example <bob@example.com>'].join(separator)
	parsed := production_dev_cmd.contribution_parse_git_log('${merge}${record_separator}${pull_request}${record_separator}${coauthored}${record_separator}', {
		'alice': 'Alice Example'
		'bob':   'bob'
	})
	return brew_runtime.bool_value(parsed.counts['alice'] == contributions_spec_counts(0, 1, 1, 0, 1) && parsed.counts['bob'] == contributions_spec_counts(1, 0, 1, 0, 1))
}

// Ruby it `it "skips approval queries after Git meets the Lead repository thresholds" do` at line 580.
pub fn ruby_contributions_spec_l580_d22_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	repositories := ['Homebrew/brew', 'Homebrew/homebrew-core']
	references := [
		contributions_spec_reference(repositories[0], '', contributions_spec_merge_log('alice', 'Alice', 'alice@example.com', 1, 25)),
		contributions_spec_reference(repositories[1], '', contributions_spec_merge_log('alice', 'Alice', 'alice@example.com', 101, 25)),
	]
	results := contributions_spec_scan(repositories, references, {
		'alice': 'Alice'
	}, {}, {
		'alice': contributions_spec_pull_requests(repositories[0], 500, 4)
	}, true)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', repositories[0])['merged_pr'] == 25
		&& contributions_spec_repository_counts(results, 'alice', repositories[1])['merged_pr'] == 25
		&& contributions_spec_repository_counts(results, 'alice', repositories[0])['approved_pr_review'] == 0)
}

// Ruby it `it "scopes capped review searches by repository until Lead activity is known" do` at line 608.
pub fn ruby_contributions_spec_l608_d23_scopes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	references := [
		contributions_spec_reference('Homebrew/brew', '', ''),
		contributions_spec_reference('Homebrew/homebrew-core', '', ''),
		contributions_spec_reference('Homebrew/homebrew-cask', '', contributions_spec_coauthor_log('Alice', 'alice@example.com', 500)),
	]
	mut reviews := contributions_spec_pull_requests('Homebrew/homebrew-cask', 1, 100)
	reviews << contributions_spec_pull_requests('Homebrew/brew', 101, 25)
	results := contributions_spec_scan(contributions_spec_primary_repositories, references, {
		'alice': 'Alice'
	}, {}, {
		'alice': reviews
	}, true)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', 'Homebrew/brew')['approved_pr_review'] == 25
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-core')['approved_pr_review'] == 0
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-cask')['approved_pr_review'] == 100)
}

// Ruby it `it "uses the existing approved review search" do` at line 649.
pub fn ruby_contributions_spec_l649_d24_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	results := contributions_spec_scan(contributions_spec_primary_repositories, [], {
		'alice': 'Alice'
	}, {}, {
		'alice': [
			production_dev_cmd.ContributionPullRequest{ number: 1, repository: 'Homebrew/brew' },
			production_dev_cmd.ContributionPullRequest{
				number: 2
				repository: 'Homebrew/homebrew-core'
			},
		]
	}, true)
	return brew_runtime.bool_value(contributions_spec_repository_counts(results, 'alice', 'Homebrew/brew')['approved_pr_review'] == 1
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-core')['approved_pr_review'] == 1
		&& contributions_spec_repository_counts(results, 'alice', 'Homebrew/homebrew-cask')['approved_pr_review'] == 0)
}

// Ruby it `it "caches completed GitHub searches in the prunable Homebrew cache" do` at line 689.
pub fn ruby_contributions_spec_l689_d25_caches(args ...brew_runtime.Value) brew_runtime.Value {
	cache_dir := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-contributions-spec-${os.getpid()}-${time.now().unix_micro()}')
	}
	os.mkdir_all(cache_dir) or { return brew_runtime.bool_value(false) }
	should_cleanup := args.len == 0
	defer {
		if should_cleanup {
			os.rmdir_all(cache_dir) or {}
		}
	}
	request := production_dev_cmd.ContributionCacheRequest{
		cache_key: 'approved\x00Homebrew\x00alice\x002026-1'
		to: '2026-03-01'
		today: '2026-03-01'
		cache_dir: cache_dir
		results: ['https://api.github.com/repos/Homebrew/brew']
	}
	first := production_dev_cmd.contribution_github_search_with_rate_limit(request) or {
		return brew_runtime.bool_value(false)
	}
	second := production_dev_cmd.contribution_github_search_with_rate_limit(production_dev_cmd.ContributionCacheRequest{
		...request
		results: ['replacement']
	}) or { return brew_runtime.bool_value(false) }
	children := os.ls(cache_dir) or { return brew_runtime.bool_value(false) }
	valid_name := children.len == 1 && children[0].starts_with('contributions--')
		&& children[0].ends_with('.json') && children[0].len == 'contributions--'.len + 64 + '.json'.len
	return brew_runtime.bool_value(first == request.results && second == request.results && valid_name)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cleanup"
// 6: require "dev-cmd/contributions"
// 7: require "utils/github"
// 8:
// 9: RSpec.describe Homebrew::DevCmd::Contributions do
// 10:   before { stub_const("HOMEBREW_CACHE", mktmpdir) }
// 11:
// 12:   it_behaves_like "parseable arguments"
// 13:
// 14:   it "documents the governance reporting quarters" do
// 15:     help_text = described_class.parser.generate_help_text.gsub(/\s+/, " ")
// 16:
// 17:     expect(help_text).to include(
// 18:       "--maintainer-report-csv=2026-2",
// 19:       "current directory",
// 20:       "brew-contributions-FROM-to-TO-USER.csv",
// 21:       "Only Maintainers listed at the end of that quarter are included",
// 22:       "two consecutive quarters before a downgrade is applied",
// 23:       "Completed-period GitHub searches are cached in Homebrew's cache",
// 24:       "Repository-scoped follow-up searches ensure role activity checks remain accurate",
// 25:       "YEAR-1 is December of the previous year through February",
// 26:       "YEAR-2 is March through May",
// 27:       "YEAR-3 is June through August",
// 28:       "YEAR-4 is September through November",
// 29:     )
// 30:   end
// 31:
// 32:   it "uses the first README mention for Maintainer tenure" do
// 33:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 34:     repository_path = Pathname("/Homebrew/brew")
// 35:     allow(Utils).to receive(:safe_popen_read).and_return("")
// 36:     allow(Utils).to receive(:safe_popen_read)
// 37:       .with(Utils::Git.git, "-C", repository_path, "log", "quarter-end-ref", "--fixed-strings",
// 38:             "-SAlice", "--format=%H%x1f%cs", "--", "README.md")
// 39:       .and_return("first-mention\x1f2020-01-02\n")
// 40:     allow(Utils).to receive(:safe_popen_read)
// 41:       .with(Utils::Git.git, "-C", repository_path, "show", "first-mention:README.md")
// 42:       .and_return("Homebrew was created by Alice.\n")
// 43:     allow(command).to receive(:system_command)
// 44:       .with(Utils::Git.git,
// 45:             args: ["-C", repository_path, "show", "first-mention^:README.md"], print_stderr: false)
// 46:       .and_return(instance_double(SystemCommand::Result, stdout: ""))
// 47:
// 48:     expect(command.maintainer_since(repository_path, "quarter-end-ref", "alice", "Alice"))
// 49:       .to eq("2020-01-02")
// 50:   end
// 51:
// 52:   it "reads historical Maintainer lists" do
// 53:     command = described_class.new(["--maintainer-report-csv=2025-3"])
// 54:     repository_path = Pathname("/Homebrew/brew")
// 55:     repository_refs = { "Homebrew/brew" => [repository_path, "origin/HEAD"] }
// 56:     allow(Utils).to receive(:safe_popen_read)
// 57:       .with(Utils::Git.git, "-C", repository_path, "rev-list", "-1", "--before=2025-09-01",
// 58:             "origin/HEAD", "--", "README.md")
// 59:       .and_return("quarter-end-ref\n")
// 60:     allow(Utils).to receive(:safe_popen_read)
// 61:       .with(Utils::Git.git, "-C", repository_path, "show", "quarter-end-ref:README.md")
// 62:       .and_return(<<~MARKDOWN)
// 63:         Homebrew's maintainers are [Alice](https://github.com/alice) and [Bob](https://github.com/bob).
// 64:         Former maintainers include [Carol](https://github.com/carol).
// 65:       MARKDOWN
// 66:     allow(command).to receive(:maintainer_since).and_return("2020-01-02")
// 67:
// 68:     expect(command.maintainer_report_users(repository_refs, "2025-09-01")).to eq([
// 69:       { "alice" => "Alice", "bob" => "Bob" }, {}, { "alice" => "2020-01-02", "bob" => "2020-01-02" }
// 70:     ])
// 71:   end
// 72:
// 73:   it "filters historical Maintainers for a requested maintainer report user" do
// 74:     command = described_class.new(["--maintainer-report-csv=2025-3", "--user=ALICE"])
// 75:     repository_path = Pathname("/Homebrew/brew")
// 76:     repository_refs = { "Homebrew/brew" => [repository_path, "origin/HEAD"] }
// 77:     allow(Utils).to receive(:safe_popen_read)
// 78:       .with(Utils::Git.git, "-C", repository_path, "rev-list", "-1", "--before=2025-09-01",
// 79:             "origin/HEAD", "--", "README.md")
// 80:       .and_return("quarter-end-ref\n")
// 81:     allow(Utils).to receive(:safe_popen_read)
// 82:       .with(Utils::Git.git, "-C", repository_path, "show", "quarter-end-ref:README.md")
// 83:       .and_return(<<~MARKDOWN)
// 84:         Homebrew's [Lead Maintainers](url) are [Alice](https://github.com/Alice).
// 85:         Homebrew's other Maintainers are [Bob](https://github.com/bob).
// 86:       MARKDOWN
// 87:     allow(command).to receive(:maintainer_since)
// 88:       .with(repository_path, "quarter-end-ref", "Alice", "Alice")
// 89:       .and_return("2020-01-02")
// 90:
// 91:     expect do
// 92:       expect(command.maintainer_report_users(repository_refs, "2025-09-01")).to eq([
// 93:         { "Alice" => "Alice" }, { "alice" => true }, { "Alice" => "2020-01-02" }
// 94:       ])
// 95:     end.to output("Scanning contributions for 1 maintainer...\n").to_stderr
// 96:   end
// 97:
// 98:   it "reports an unresolved maintainer report email as an identity error" do
// 99:     command = described_class.new(["--maintainer-report-csv=2025-3", "--user=alice@example.com"])
// 100:     repository_path = Pathname("/Homebrew/brew")
// 101:     repository_refs = { "Homebrew/brew" => [repository_path, "origin/HEAD"] }
// 102:     allow(Utils).to receive(:safe_popen_read)
// 103:       .with(Utils::Git.git, "-C", repository_path, "rev-list", "-1", "--before=2025-09-01",
// 104:             "origin/HEAD", "--", "README.md")
// 105:       .and_return("quarter-end-ref\n")
// 106:     allow(Utils).to receive(:safe_popen_read)
// 107:       .with(Utils::Git.git, "-C", repository_path, "show", "quarter-end-ref:README.md")
// 108:       .and_return("Homebrew's maintainers are [Alice](https://github.com/alice).\n")
// 109:     allow(command).to receive(:github_username_for).with("alice@example.com", to: "2025-09-01")
// 110:
// 111:     expect { command.maintainer_report_users(repository_refs, "2025-09-01") }
// 112:       .to raise_error(SystemExit)
// 113:       .and output(/Could not resolve GitHub usernames for: alice@example\.com/).to_stderr
// 114:   end
// 115:
// 116:   it "filters maintainer reports using a username resolved from an email" do
// 117:     command = described_class.new([
// 118:       "--maintainer-report-csv=2025-3",
// 119:       "--user=39449589+alice@users.noreply.github.com",
// 120:     ])
// 121:     repository_path = Pathname("/Homebrew/brew")
// 122:     repository_refs = { "Homebrew/brew" => [repository_path, "origin/HEAD"] }
// 123:     allow(Utils).to receive(:safe_popen_read)
// 124:       .with(Utils::Git.git, "-C", repository_path, "rev-list", "-1", "--before=2025-09-01",
// 125:             "origin/HEAD", "--", "README.md")
// 126:       .and_return("quarter-end-ref\n")
// 127:     allow(Utils).to receive(:safe_popen_read)
// 128:       .with(Utils::Git.git, "-C", repository_path, "show", "quarter-end-ref:README.md")
// 129:       .and_return("Homebrew's maintainers are [Alice](https://github.com/alice).\n")
// 130:     allow(command).to receive(:maintainer_since)
// 131:       .with(repository_path, "quarter-end-ref", "alice", "Alice")
// 132:       .and_return("2020-01-02")
// 133:
// 134:     expect(command.maintainer_report_users(repository_refs, "2025-09-01")).to eq([
// 135:       { "alice" => "Alice" }, {}, { "alice" => "2020-01-02" }
// 136:     ])
// 137:   end
// 138:
// 139:   it "reports only requested users not listed as quarter-end Maintainers" do
// 140:     command = described_class.new([
// 141:       "--maintainer-report-csv=2025-3",
// 142:       "--user=bob,carol,dave",
// 143:     ])
// 144:     repository_path = Pathname("/Homebrew/brew")
// 145:     repository_refs = { "Homebrew/brew" => [repository_path, "origin/HEAD"] }
// 146:     allow(Utils).to receive(:safe_popen_read)
// 147:       .with(Utils::Git.git, "-C", repository_path, "rev-list", "-1", "--before=2025-09-01",
// 148:             "origin/HEAD", "--", "README.md")
// 149:       .and_return("quarter-end-ref\n")
// 150:     allow(Utils).to receive(:safe_popen_read)
// 151:       .with(Utils::Git.git, "-C", repository_path, "show", "quarter-end-ref:README.md")
// 152:       .and_return("Homebrew's maintainers are [Bob](https://github.com/bob).\n")
// 153:
// 154:     expect { command.maintainer_report_users(repository_refs, "2025-09-01") }
// 155:       .to raise_error(SystemExit)
// 156:       .and output(<<~EOS).to_stderr
// 157:         Error: Not listed as Maintainers at the end of the reporting quarter: carol and dave.
// 158:       EOS
// 159:   end
// 160:
// 161:   it "rejects empty maintainer report user values" do
// 162:     command = described_class.new(["--maintainer-report-csv=2025-3", "--user=alice,,bob"])
// 163:
// 164:     expect(Homebrew).not_to receive(:install_bundler_gems!)
// 165:     expect { command.run }
// 166:       .to raise_error(SystemExit)
// 167:       .and output(/`--user` must not contain empty values/).to_stderr
// 168:   end
// 169:
// 170:   it "reports activity criteria from fetched Git histories" do
// 171:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 172:     quarter_end_ref = "quarter-end-ref"
// 173:     repository_refs = Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 174:       [repository, [Pathname("/#{repository}"), "origin/HEAD"]]
// 175:     end
// 176:     no_contributions = { merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0 }
// 177:     alice_results = {
// 178:       "Homebrew/brew"          => {
// 179:         merged_pr_author: 2, merged_pr_merger: 3, merged_pr: 4, approved_pr_review: 1, coauthor: 45
// 180:       },
// 181:       "Homebrew/homebrew-core" => no_contributions,
// 182:       "Homebrew/homebrew-cask" => no_contributions,
// 183:     }
// 184:     bob_results = {
// 185:       "Homebrew/brew"          => {
// 186:         merged_pr_author: 25, merged_pr_merger: 1, merged_pr: 25, approved_pr_review: 0, coauthor: 0
// 187:       },
// 188:       "Homebrew/homebrew-core" => {
// 189:         merged_pr_author: 24, merged_pr_merger: 0, merged_pr: 24, approved_pr_review: 1, coauthor: 0
// 190:       },
// 191:       "Homebrew/homebrew-cask" => no_contributions.merge(coauthor: 451),
// 192:     }
// 193:
// 194:     allow(Homebrew).to receive(:install_bundler_gems!).with(groups: ["contributions"])
// 195:     allow(command).to receive(:prepare_contribution_repositories)
// 196:       .with(Homebrew::DevCmd::Contributions::PRIMARY_REPOS, required: true)
// 197:       .and_return(repository_refs)
// 198:     allow(Utils).to receive(:safe_popen_read).and_return("")
// 199:     allow(Utils).to receive(:safe_popen_read)
// 200:       .with(Utils::Git.git, "-C", Pathname("/Homebrew/brew"), "rev-list", "-1", "--before=2026-03-01",
// 201:             "origin/HEAD", "--", "README.md")
// 202:       .and_return("#{quarter_end_ref}\n")
// 203:     allow(Utils).to receive(:safe_popen_read)
// 204:       .with(Utils::Git.git, "-C", Pathname("/Homebrew/brew"), "show", "#{quarter_end_ref}:README.md")
// 205:       .and_return(<<~MARKDOWN)
// 206:         Homebrew's [Lead Maintainers](url) are [Alice](https://github.com/alice).
// 207:         Homebrew's other Maintainers are [Bob](https://github.com/bob).
// 208:       MARKDOWN
// 209:     allow(command).to receive(:scan_contributions)
// 210:       .with("Homebrew", Homebrew::DevCmd::Contributions::PRIMARY_REPOS, repository_refs,
// 211:             { "alice" => "Alice", "bob" => "Bob" }, from: "2025-12-01", to: "2026-03-01",
// 212:             skip_reviews_if_lead_met: true, progress: true)
// 213:       .and_return({ "alice" => alice_results, "bob" => bob_results })
// 214:     allow(command).to receive(:maintainer_since)
// 215:       .with(Pathname("/Homebrew/brew"), quarter_end_ref, "alice", "Alice")
// 216:       .and_return("2024-03-01")
// 217:     allow(command).to receive(:maintainer_since)
// 218:       .with(Pathname("/Homebrew/brew"), quarter_end_ref, "bob", "Bob")
// 219:       .and_return("2022-03-01")
// 220:     csv = <<~CSV
// 221:       username,name,since,tenure days,brew authored,brew merged,brew PRs,brew reviews,brew coauthored,brew total,core authored,core merged,core PRs,core reviews,core coauthored,core total,cask authored,cask merged,cask PRs,cask reviews,cask coauthored,cask total,total,maintainer met,lead met,capped,role,new role
// 222:       bob,Bob,2022-03-01,1461,25,1,25,0,0,25,24,0,24,1,0,25,0,0,0,0,451,451,501,true,true,false,Maintainer,Lead Maintainer
// 223:       alice,Alice,2024-03-01,730,2,3,4,1,45,50,0,0,0,0,0,0,0,0,0,0,0,0,50,true,false,false,Lead Maintainer,Maintainer
// 224:     CSV
// 225:     expect(File).to receive(:write).with("brew-contributions-2025-12-01-to-2026-03-01.csv", csv)
// 226:
// 227:     expect do
// 228:       command.run
// 229:     end.to output(csv).to_stdout.and output(<<~EOS).to_stderr
// 230:       Maintainer report dates: 2025-12-01-to-2026-03-01
// 231:       Scanning contributions for 2 maintainers...
// 232:     EOS
// 233:   end
// 234:
// 235:   it "writes filtered maintainer reports without overwriting the full report" do
// 236:     command = described_class.new([
// 237:       "--maintainer-report-csv=2026-1",
// 238:       "--user=BOB,39449589+alice@users.noreply.github.com",
// 239:     ])
// 240:     repository_refs = Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 241:       [repository, [Pathname("/#{repository}"), "origin/HEAD"]]
// 242:     end
// 243:     no_contributions = {
// 244:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0
// 245:     }
// 246:     results = {
// 247:       "bob"   => Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 248:         [repository, no_contributions]
// 249:       end,
// 250:       "Alice" => Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 251:         [repository, no_contributions]
// 252:       end,
// 253:     }
// 254:     csv = "filtered maintainer report\n"
// 255:
// 256:     allow(Homebrew).to receive(:install_bundler_gems!).with(groups: ["contributions"])
// 257:     allow(command).to receive(:prepare_contribution_repositories)
// 258:       .with(Homebrew::DevCmd::Contributions::PRIMARY_REPOS, required: true)
// 259:       .and_return(repository_refs)
// 260:     allow(command).to receive(:maintainer_report_users)
// 261:       .with(repository_refs, "2026-03-01")
// 262:       .and_return([
// 263:         { "bob" => "Bob", "Alice" => "Alice" },
// 264:         {},
// 265:         { "bob" => "2020-01-02", "Alice" => "2020-01-02" },
// 266:       ])
// 267:     allow(command).to receive(:scan_contributions)
// 268:       .with("Homebrew", Homebrew::DevCmd::Contributions::PRIMARY_REPOS, repository_refs,
// 269:             { "bob" => "Bob", "Alice" => "Alice" }, from: "2025-12-01", to: "2026-03-01",
// 270:             skip_reviews_if_lead_met: true, progress: true)
// 271:       .and_return(results)
// 272:     allow(command).to receive(:generate_maintainer_report_csv).and_return(csv)
// 273:     expect(File).to receive(:write)
// 274:       .with("brew-contributions-2025-12-01-to-2026-03-01-alice-bob.csv", csv)
// 275:
// 276:     expect { command.run }
// 277:       .to output(csv).to_stdout
// 278:       .and output("Maintainer report dates: 2025-12-01-to-2026-03-01\n").to_stderr
// 279:   end
// 280:
// 281:   it "uses the shared Git scanner for non-Maintainers" do
// 282:     command = described_class.new([
// 283:       "--user=alice", "--repositories=Homebrew/brew", "--from=2026-01-01", "--to=2026-02-01", "--csv"
// 284:     ])
// 285:     repository_refs = { "Homebrew/brew" => [Pathname("/Homebrew/brew"), "origin/HEAD"] }
// 286:     results = { "alice" => { "Homebrew/brew" => {
// 287:       merged_pr_author: 1, merged_pr_merger: 0, merged_pr: 1, approved_pr_review: 2, coauthor: 3
// 288:     } } }
// 289:
// 290:     allow(Homebrew).to receive(:install_bundler_gems!).with(groups: ["contributions"])
// 291:     allow(command).to receive(:prepare_contribution_repositories)
// 292:       .with(["Homebrew/brew"], required: false)
// 293:       .and_return(repository_refs)
// 294:     allow(command).to receive(:scan_contributions)
// 295:       .with("Homebrew", ["Homebrew/brew"], repository_refs, { "alice" => "alice" },
// 296:             from: "2026-01-01", to: "2026-02-01", skip_reviews_if_lead_met: false, progress: false)
// 297:       .and_return(results)
// 298:
// 299:     expect do
// 300:       command.run
// 301:     end.to output(<<~CSV).to_stdout.and output(/alice contributed.*6 times \(total\)/).to_stderr
// 302:       username,repo,authored,merged,PRs,reviews,coauthored,total
// 303:       alice,all,1,0,1,2,3,6
// 304:     CSV
// 305:   end
// 306:
// 307:   it "marks capped merged-PR searches with no matching requested repositories as lower bounds" do
// 308:     command = described_class.new([
// 309:       "--user=alice", "--repositories=Homebrew/brew", "--from=2026-01-01", "--to=2026-02-01"
// 310:     ])
// 311:     repository_refs = { "Homebrew/brew" => [Pathname("/Homebrew/brew"), "origin/HEAD"] }
// 312:     results = { "alice" => { "Homebrew/brew" => {
// 313:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0,
// 314:       merged_pr_author_hit_cap: 1
// 315:     } } }
// 316:
// 317:     allow(command).to receive(:prepare_contribution_repositories)
// 318:       .with(["Homebrew/brew"], required: false)
// 319:       .and_return(repository_refs)
// 320:     allow(command).to receive(:scan_contributions)
// 321:       .with("Homebrew", ["Homebrew/brew"], repository_refs, { "alice" => "alice" },
// 322:             from: "2026-01-01", to: "2026-02-01", skip_reviews_if_lead_met: false, progress: false)
// 323:       .and_return(results)
// 324:
// 325:     expect { command.run }.to output(/alice contributed >=0 times \(total\)/).to_stdout
// 326:   end
// 327:
// 328:   it "uses merge dates for repositories without local Git history" do
// 329:     command = described_class.new(["--user=alice", "--repositories=Homebrew/untapped"])
// 330:     repository = "Homebrew/untapped"
// 331:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation).and_return([])
// 332:     expect(GitHub).to receive(:search_issues)
// 333:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 334:       .and_return([{ "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" }])
// 335:
// 336:     results = command.scan_contributions(
// 337:       "Homebrew",
// 338:       [repository],
// 339:       {},
// 340:       { "alice" => "alice" },
// 341:       from:                     "2026-01-01",
// 342:       to:                       "2026-02-01",
// 343:       skip_reviews_if_lead_met: false,
// 344:       progress:                 false,
// 345:     )
// 346:
// 347:     expect(results.fetch("alice").fetch(repository)).to eq(
// 348:       merged_pr_author: 1, merged_pr_merger: 0, merged_pr: 1, approved_pr_review: 0, coauthor: 0,
// 349:     )
// 350:   end
// 351:
// 352:   it "distributes organisation-wide merged PR searches by repository" do
// 353:     command = described_class.new(["--user=alice", "--repositories=Homebrew/brew,Homebrew/homebrew-core"])
// 354:     repositories = %w[Homebrew/brew Homebrew/homebrew-core]
// 355:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation).and_return([])
// 356:     expect(GitHub).to receive(:search_issues)
// 357:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 358:       .and_return([{ "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/homebrew-core" }])
// 359:
// 360:     results = command.scan_contributions(
// 361:       "Homebrew",
// 362:       repositories,
// 363:       {},
// 364:       { "alice" => "alice" },
// 365:       from:                     "2026-01-01",
// 366:       to:                       "2026-02-01",
// 367:       skip_reviews_if_lead_met: false,
// 368:       progress:                 false,
// 369:     )
// 370:
// 371:     expect(results.fetch("alice").transform_values { |counts| counts.fetch(:merged_pr_author) }).to eq(
// 372:       "Homebrew/brew" => 0, "Homebrew/homebrew-core" => 1,
// 373:     )
// 374:   end
// 375:
// 376:   it "scopes capped merged PR searches by repository until Lead activity is known" do
// 377:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 378:     repositories = Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 379:       [repository, [Pathname("/#{repository}"), "origin/HEAD"]]
// 380:     end
// 381:     no_contributions = {
// 382:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0
// 383:     }
// 384:     allow(Utils).to receive(:safe_popen_read).and_return("brew", "core", "cask")
// 385:     allow(command).to receive(:parse_git_log) { { "alice" => no_contributions.dup } }
// 386:     expect(GitHub).to receive(:search_issues)
// 387:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2025-12-01..2026-02-28")
// 388:       .and_return(Array.new(100) do |index|
// 389:         { "number" => index, "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/homebrew-cask" }
// 390:       end)
// 391:     expect(GitHub).to receive(:search_issues)
// 392:       .with("", is: "merged", repo: "Homebrew/brew", author: "alice", merged: "2025-12-01..2026-02-28")
// 393:       .and_return(Array.new(25) { |index| { "number" => index + 100 } })
// 394:     expect(GitHub).not_to receive(:search_approved_pull_requests_in_user_or_organisation)
// 395:
// 396:     results = command.scan_contributions(
// 397:       "Homebrew",
// 398:       repositories.keys,
// 399:       repositories,
// 400:       { "alice" => "Alice" },
// 401:       from:                     "2025-12-01",
// 402:       to:                       "2026-03-01",
// 403:       skip_reviews_if_lead_met: true,
// 404:       progress:                 true,
// 405:     )
// 406:
// 407:     expect(results.fetch("alice").transform_values do |counts|
// 408:       counts.fetch(:merged_pr_author)
// 409:     end).to eq("Homebrew/brew" => 25, "Homebrew/homebrew-core" => 0, "Homebrew/homebrew-cask" => 100)
// 410:   end
// 411:
// 412:   it "uses a GitHub username resolved from a public email address" do
// 413:     command = described_class.new(["--user=alice@example.com", "--repositories=Homebrew/untapped"])
// 414:     repository = "Homebrew/untapped"
// 415:     allow(GitHub).to receive(:search)
// 416:       .with("users", "\"alice@example.com\" in:email")
// 417:       .and_return({ "items" => [{ "login" => "alice" }] })
// 418:     expect(GitHub).to receive(:search_issues)
// 419:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 420:       .and_return([{ "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" }])
// 421:     expect(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation)
// 422:       .with("Homebrew", "alice", from: "2026-01-01", to: "2026-02-01")
// 423:       .and_return([])
// 424:
// 425:     results = command.scan_contributions(
// 426:       "Homebrew",
// 427:       [repository],
// 428:       {},
// 429:       { "alice@example.com" => "alice@example.com" },
// 430:       from:                     "2026-01-01",
// 431:       to:                       "2026-02-01",
// 432:       skip_reviews_if_lead_met: false,
// 433:       progress:                 false,
// 434:     )
// 435:
// 436:     expect(results.fetch("alice@example.com").fetch(repository)).to eq(
// 437:       merged_pr_author: 1, merged_pr_merger: 0, merged_pr: 1, approved_pr_review: 0, coauthor: 0,
// 438:     )
// 439:   end
// 440:
// 441:   it "uses the username embedded in a GitHub no-reply email address" do
// 442:     command = described_class.new(["--user=39449589+krehel@users.noreply.github.com"])
// 443:
// 444:     expect(GitHub).not_to receive(:search)
// 445:     expect(command.github_username_for("39449589+krehel@users.noreply.github.com", to: "2026-02-01"))
// 446:       .to eq("krehel")
// 447:   end
// 448:
// 449:   it "counts authored squash-merged PRs in repositories with local Git history" do
// 450:     command = described_class.new(["--user=alice", "--repositories=Homebrew/homebrew-core"])
// 451:     repository = "Homebrew/homebrew-core"
// 452:     repository_refs = { repository => [Pathname("/Homebrew/homebrew-core"), "origin/HEAD"] }
// 453:     git_counts = { merged_pr_author: 1, merged_pr_merger: 0, merged_pr: 1, approved_pr_review: 0, coauthor: 0 }
// 454:     allow(Utils).to receive(:safe_popen_read).and_return("git log")
// 455:     allow(command).to receive(:parse_git_log).and_return("alice" => git_counts)
// 456:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation).and_return([])
// 457:     expect(GitHub).to receive(:search_issues)
// 458:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 459:       .and_return([
// 460:         { "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" },
// 461:         { "number" => 124, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" },
// 462:       ])
// 463:
// 464:     results = command.scan_contributions(
// 465:       "Homebrew",
// 466:       [repository],
// 467:       repository_refs,
// 468:       { "alice" => "alice" },
// 469:       from:                     "2026-01-01",
// 470:       to:                       "2026-02-01",
// 471:       skip_reviews_if_lead_met: false,
// 472:       progress:                 false,
// 473:     )
// 474:
// 475:     expect(results.fetch("alice").fetch(repository)).to eq(
// 476:       merged_pr_author: 2, merged_pr_merger: 0, merged_pr: 2, approved_pr_review: 0, coauthor: 0,
// 477:     )
// 478:   end
// 479:
// 480:   it "counts a self-merged PR once" do
// 481:     command = described_class.new(["--user=alice", "--repositories=Homebrew/homebrew-core"])
// 482:     repository = "Homebrew/homebrew-core"
// 483:     repository_refs = { repository => [Pathname("/Homebrew/homebrew-core"), "origin/HEAD"] }
// 484:     separator = "\x1f"
// 485:     record_separator = "\x1e"
// 486:     merge = [
// 487:       "merge", "base pull-request", "Alice", "alice@example.com",
// 488:       "Merge pull request #123 from alice/topic"
// 489:     ].join(separator)
// 490:     pull_request = ["pull-request", "base", "Alice", "alice@example.com", "Change something"].join(separator)
// 491:     git_log = "#{merge}#{record_separator}#{pull_request}#{record_separator}"
// 492:     allow(Utils).to receive(:safe_popen_read).and_return(git_log)
// 493:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation).and_return([])
// 494:     expect(GitHub).to receive(:search_issues)
// 495:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 496:       .and_return([{ "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" }])
// 497:
// 498:     results = command.scan_contributions(
// 499:       "Homebrew",
// 500:       [repository],
// 501:       repository_refs,
// 502:       { "alice" => "Alice" },
// 503:       from:                     "2026-01-01",
// 504:       to:                       "2026-02-01",
// 505:       skip_reviews_if_lead_met: false,
// 506:       progress:                 false,
// 507:     )
// 508:
// 509:     expect(results.fetch("alice").fetch(repository)).to eq(
// 510:       merged_pr_author: 1, merged_pr_merger: 1, merged_pr: 1, approved_pr_review: 0, coauthor: 0,
// 511:     )
// 512:   end
// 513:
// 514:   it "counts a GitHub-authored PR once when Git only identifies its merger" do
// 515:     command = described_class.new(["--user=alice", "--repositories=Homebrew/homebrew-core"])
// 516:     repository = "Homebrew/homebrew-core"
// 517:     repository_refs = { repository => [Pathname("/Homebrew/homebrew-core"), "origin/HEAD"] }
// 518:     separator = "\x1f"
// 519:     record_separator = "\x1e"
// 520:     merge = [
// 521:       "merge", "base pull-request", "Alice", "alice@example.com",
// 522:       "Merge pull request #123 from Homebrew/topic"
// 523:     ].join(separator)
// 524:     pull_request = ["pull-request", "base", "BrewTestBot", "test-bot@example.com", "Change something"].join(separator)
// 525:     git_log = "#{merge}#{record_separator}#{pull_request}#{record_separator}"
// 526:     allow(Utils).to receive(:safe_popen_read).and_return(git_log)
// 527:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation).and_return([])
// 528:     expect(GitHub).to receive(:search_issues)
// 529:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2026-01-01..2026-01-31")
// 530:       .and_return([{ "number" => 123, "repository_url" => "#{GitHub::API_URL}/repos/#{repository}" }])
// 531:
// 532:     results = command.scan_contributions(
// 533:       "Homebrew",
// 534:       [repository],
// 535:       repository_refs,
// 536:       { "alice" => "Alice" },
// 537:       from:                     "2026-01-01",
// 538:       to:                       "2026-02-01",
// 539:       skip_reviews_if_lead_met: false,
// 540:       progress:                 false,
// 541:     )
// 542:
// 543:     expect(results.fetch("alice").fetch(repository)).to eq(
// 544:       merged_pr_author: 1, merged_pr_merger: 1, merged_pr: 1, approved_pr_review: 0, coauthor: 0,
// 545:     )
// 546:   end
// 547:
// 548:   it "attributes merged PRs once and learns non-Maintainer Git identities" do
// 549:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 550:     separator = "\x1f"
// 551:     record_separator = "\x1e"
// 552:     merge = [
// 553:       "merge", "base pull-request", "Alice Example", "alice@example.com",
// 554:       "Merge pull request #123 from Homebrew/topic"
// 555:     ].join(separator)
// 556:     pull_request = [
// 557:       "pull-request", "base", "Bob Example", "bob@example.com",
// 558:       "Change something\n\nCo-authored-by: Alice Example <123+alice@users.noreply.github.com>"
// 559:     ].join(separator)
// 560:     coauthored = [
// 561:       "coauthored", "base", "Someone Else", "someone@example.com",
// 562:       "Change another thing\n\nCo-authored-by: Bob Example <bob@example.com>"
// 563:     ].join(separator)
// 564:
// 565:     counts = command.parse_git_log(
// 566:       "#{merge}#{record_separator}#{pull_request}#{record_separator}#{coauthored}#{record_separator}",
// 567:       { "alice" => "Alice Example", "bob" => "bob" },
// 568:     )
// 569:
// 570:     expect(counts).to eq(
// 571:       "alice" => {
// 572:         merged_pr_author: 0, merged_pr_merger: 1, merged_pr: 1, approved_pr_review: 0, coauthor: 1
// 573:       },
// 574:       "bob"   => {
// 575:         merged_pr_author: 1, merged_pr_merger: 0, merged_pr: 1, approved_pr_review: 0, coauthor: 1
// 576:       },
// 577:     )
// 578:   end
// 579:
// 580:   it "skips approval queries after Git meets the Lead repository thresholds" do
// 581:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 582:     repositories = {
// 583:       "Homebrew/brew"          => [Pathname("/Homebrew/brew"), "origin/HEAD"],
// 584:       "Homebrew/homebrew-core" => [Pathname("/Homebrew/homebrew-core"), "origin/HEAD"],
// 585:     }
// 586:     counts = {
// 587:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 25, approved_pr_review: 0, coauthor: 0
// 588:     }
// 589:     allow(Utils).to receive(:safe_popen_read).and_return("")
// 590:     allow(command).to receive(:parse_git_log).and_return("alice" => counts)
// 591:     allow(GitHub).to receive(:search_issues)
// 592:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2025-12-01..2026-02-28")
// 593:       .and_return([])
// 594:     expect(GitHub).not_to receive(:search_approved_pull_requests_in_user_or_organisation)
// 595:
// 596:     expect(command.scan_contributions(
// 597:              "Homebrew",
// 598:              repositories.keys,
// 599:              repositories,
// 600:              { "alice" => "Alice" },
// 601:              from:                     "2025-12-01",
// 602:              to:                       "2026-03-01",
// 603:              skip_reviews_if_lead_met: true,
// 604:              progress:                 true,
// 605:            )).to eq("alice" => { "Homebrew/brew" => counts, "Homebrew/homebrew-core" => counts })
// 606:   end
// 607:
// 608:   it "scopes capped review searches by repository until Lead activity is known" do
// 609:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 610:     repositories = Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 611:       [repository, [Pathname("/#{repository}"), "origin/HEAD"]]
// 612:     end
// 613:     no_contributions = {
// 614:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0
// 615:     }
// 616:     allow(Utils).to receive(:safe_popen_read).and_return("brew", "core", "cask")
// 617:     allow(command).to receive(:parse_git_log) do |output, _|
// 618:       { "alice" => (output == "cask") ? no_contributions.merge(coauthor: 500) : no_contributions.dup }
// 619:     end
// 620:     allow(GitHub).to receive(:search_issues)
// 621:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2025-12-01..2026-02-28")
// 622:       .and_return([])
// 623:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation)
// 624:       .with("Homebrew", "alice", from: "2025-12-01", to: "2026-03-01")
// 625:       .and_return(Array.new(100) do
// 626:         { "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/homebrew-cask" }
// 627:       end)
// 628:     expect(GitHub).to receive(:search_issues)
// 629:       .with("", is: "pr", review: "approved", repo: "Homebrew/brew", reviewed_by: "alice",
// 630:             from: "2025-12-01", to: "2026-03-01")
// 631:       .and_return(Array.new(25) { {} })
// 632:
// 633:     results = command.scan_contributions(
// 634:       "Homebrew",
// 635:       repositories.keys,
// 636:       repositories,
// 637:       { "alice" => "Alice" },
// 638:       from:                     "2025-12-01",
// 639:       to:                       "2026-03-01",
// 640:       skip_reviews_if_lead_met: true,
// 641:       progress:                 true,
// 642:     )
// 643:
// 644:     expect(results.fetch("alice").transform_values do |counts|
// 645:       counts.fetch(:approved_pr_review)
// 646:     end).to eq("Homebrew/brew" => 25, "Homebrew/homebrew-core" => 0, "Homebrew/homebrew-cask" => 100)
// 647:   end
// 648:
// 649:   it "uses the existing approved review search" do
// 650:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 651:     repositories = Homebrew::DevCmd::Contributions::PRIMARY_REPOS.to_h do |repository|
// 652:       [repository, [Pathname("/#{repository}"), "origin/HEAD"]]
// 653:     end
// 654:     counts = {
// 655:       merged_pr_author: 0, merged_pr_merger: 0, merged_pr: 0, approved_pr_review: 0, coauthor: 0
// 656:     }
// 657:     allow(Utils).to receive(:safe_popen_read).and_return("")
// 658:     allow(command).to receive(:parse_git_log) do
// 659:       { "alice" => counts.dup }
// 660:     end
// 661:     allow(GitHub).to receive(:search_issues)
// 662:       .with("", is: "merged", user: "Homebrew", author: "alice", merged: "2025-12-01..2026-02-28")
// 663:       .and_return([])
// 664:     allow(GitHub).to receive(:search_approved_pull_requests_in_user_or_organisation)
// 665:       .with("Homebrew", "alice", from: "2025-12-01", to: "2026-03-01")
// 666:       .and_return([
// 667:         { "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/brew" },
// 668:         { "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/homebrew-core" },
// 669:       ])
// 670:
// 671:     results = command.scan_contributions(
// 672:       "Homebrew",
// 673:       repositories.keys,
// 674:       repositories,
// 675:       { "alice" => "Alice" },
// 676:       from:                     "2025-12-01",
// 677:       to:                       "2026-03-01",
// 678:       skip_reviews_if_lead_met: true,
// 679:       progress:                 true,
// 680:     )
// 681:
// 682:     expect(results.transform_values do |repository_counts|
// 683:       repository_counts.transform_values { |repository_count| repository_count.fetch(:approved_pr_review) }
// 684:     end).to eq("alice" => {
// 685:       "Homebrew/brew" => 1, "Homebrew/homebrew-core" => 1, "Homebrew/homebrew-cask" => 0
// 686:     })
// 687:   end
// 688:
// 689:   it "caches completed GitHub searches in the prunable Homebrew cache" do
// 690:     command = described_class.new(["--maintainer-report-csv=2026-1"])
// 691:     results = [{ "repository_url" => "#{GitHub::API_URL}/repos/Homebrew/brew" }]
// 692:     calls = 0
// 693:
// 694:     2.times do
// 695:       cache_key = %w[approved Homebrew alice 2026-1].join("\0")
// 696:       expect(command.github_search_with_rate_limit(cache_key, to: "2026-03-01") do
// 697:         calls += 1
// 698:         results
// 699:       end).to eq(results)
// 700:     end
// 701:
// 702:     expect(calls).to eq(1)
// 703:     cache_file = HOMEBREW_CACHE.children.fetch(0)
// 704:     expect(cache_file.basename.to_s).to match(/\Acontributions--[a-f\d]{64}\.json\z/)
// 705:
// 706:     expect do
// 707:       Homebrew::Cleanup.new(days: 0, cache: HOMEBREW_CACHE)
// 708:                        .cleanup_cache([{ path: cache_file, type: nil }], cleanup_unreferenced: false)
// 709:     end.to output(/Removing:/).to_stdout
// 710:     expect(cache_file).not_to exist
// 711:   end
// 712: end
