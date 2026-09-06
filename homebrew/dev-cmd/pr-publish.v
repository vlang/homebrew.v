module dev_cmd

// Translated from Homebrew/brew `dev-cmd/pr-publish.rb`.

pub struct PrPublishOptions {
pub:
	tap_full_name      string = 'homebrew/core'
	tap_default_remote string = 'https://github.com/Homebrew/homebrew-core'
	tap_explicit       bool
	workflow           string = 'publish-commit-bottles.yml'
	branch             string = 'main'
	autosquash         bool
	large_runner       bool
	message            string
	named              []string
	labels             map[string][]string
}

pub struct PrPublishDispatch {
pub:
	user         string
	repo         string
	issue        string
	workflow     string
	ref          string
	autosquash   bool
	large_runner bool
	message      string
}

pub struct PrPublishResult {
pub:
	tap        string
	messages   []string
	dispatches []PrPublishDispatch
}

fn pr_publish_positive_integer(value string) bool {
	if value.len == 0 || value[0] < `0` || value[0] > `9` {
		return false
	}
	mut end := 0
	for end < value.len && value[end] >= `0` && value[end] <= `9` {
		end++
	}
	return value[..end].int() > 0
}

fn pr_publish_parse_url(value string) !(string, string, string) {
	prefix := 'https://github.com/'
	if !value.starts_with(prefix) {
		return error('Not a GitHub pull request: ${value}')
	}
	parts := value[prefix.len..].split('/')
	if parts.len != 4 || parts[0].len == 0 || parts[1].len == 0 || parts[2] != 'pull'
		|| parts[3].len == 0 || !parts[3].bytes().all(it >= `0` && it <= `9`) {
		return error('Not a GitHub pull request: ${value}')
	}
	return parts[0], parts[1], parts[3]
}

pub fn run_pr_publish(options PrPublishOptions) !PrPublishResult {
	mut messages := []string{}
	mut dispatches := []PrPublishDispatch{}
	mut seen := []string{}
	mut autosquash := options.autosquash
	mut large_runner := options.large_runner
	for original in options.named {
		if original in seen {
			continue
		}
		seen << original
		arg := if pr_publish_positive_integer(original) {
			'${options.tap_default_remote}/pull/${original}'
		} else {
			original
		}
		user, repo, issue := pr_publish_parse_url(arg)!
		labels := options.labels[issue] or { []string{} }
		if 'autosquash' in labels {
			messages << 'Found `autosquash` label on #${issue}. Requesting autosquash.'
			autosquash = true
		}
		if 'large-bottle-upload' in labels {
			messages << 'Found `large-bottle-upload` label on #${issue}. Requesting upload on large runner.'
			large_runner = true
		}
		url_full_name := '${user}/${repo}'
		if options.tap_explicit && url_full_name.to_lower() != options.tap_full_name.to_lower() {
			return error('Pull request URL is for ${url_full_name} but `--tap=${options.tap_full_name}` was specified!')
		}
		messages << 'Dispatching ${options.tap_full_name} pull request #${issue}'
		dispatches << PrPublishDispatch{
			user: user
			repo: repo
			issue: issue
			workflow: options.workflow
			ref: options.branch
			autosquash: autosquash
			large_runner: large_runner
			message: options.message
		}
	}
	return PrPublishResult{
		tap: options.tap_full_name
		messages: messages
		dispatches: dispatches
	}
}

@[heap]
pub struct PrPublishInput {
pub:
	options PrPublishOptions
}
