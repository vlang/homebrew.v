module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/pr-automerge.rb`.

pub struct PrAutomergePullRequest {
pub:
	number   int
	title    string
	html_url string
}

pub struct PrAutomergeOptions {
pub:
	brew_file          string = 'brew'
	tap_name           string = 'homebrew/core'
	tap_full_name      string = 'Homebrew/homebrew-core'
	workflow           string
	with_label         string
	without_labels     []string
	without_labels_set bool
	without_approval   bool
	publish            bool
	autosquash         bool
	ignore_failures    bool
	pull_requests      []PrAutomergePullRequest
}

pub struct PrAutomergeResult {
pub mut:
	query              string
	debug_messages     []string
	ohai_messages      []string
	pull_request_lines []string
	pr_urls            []string
	publish_args       []string
	publish_command    []string
	instruction        string
	published          bool
	no_matches         bool
}

fn pr_automerge_default_without_labels() []string {
	return [
		'do not merge',
		'new formula',
		'automerge-skip',
		'pre-release',
		'CI-published-bottle-commits',
	]
}

pub fn run_pr_automerge(options PrAutomergeOptions) PrAutomergeResult {
	without_labels := if options.without_labels_set {
		options.without_labels.clone()
	} else {
		pr_automerge_default_without_labels()
	}
	mut query := 'is:pr is:open repo:${options.tap_full_name} draft:false'
	query += if options.ignore_failures { ' -status:pending' } else { ' status:success' }
	if !options.without_approval {
		query += ' review:approved'
	}
	if options.with_label.len > 0 {
		query += ' label:"${options.with_label}"'
	}
	for label in without_labels {
		query += ' -label:"${label}"'
	}

	mut result := PrAutomergeResult{
		query: query
		debug_messages: ['Searching: ${query}']
	}
	if options.pull_requests.len == 0 {
		result.ohai_messages << 'No matching pull requests!'
		return PrAutomergeResult{
			...result
			no_matches: true
		}
	}

	request_word := if options.pull_requests.len == 1 { 'request' } else { 'requests' }
	result.ohai_messages << '${options.pull_requests.len} matching pull ${request_word}:'
	is_core_tap := options.tap_name.to_lower() == 'homebrew/core'
	for pr in options.pull_requests {
		prefix := if is_core_tap { '' } else { options.tap_full_name }
		result.pull_request_lines << '${prefix}#${pr.number}: ${pr.title}'
		result.pr_urls << pr.html_url
	}

	result.publish_args << 'pr-publish'
	result.publish_args << '--tap=${options.tap_name}'
	if options.workflow.len > 0 {
		result.publish_args << '--workflow=${options.workflow}'
	}
	if options.autosquash {
		result.publish_args << '--autosquash'
	}
	if options.publish {
		result.publish_command << options.brew_file
		result.publish_command << result.publish_args
		result.publish_command << result.pr_urls
		return PrAutomergeResult{
			...result
			published: true
		}
	}

	continuation := ' \\\n    '
	result.instruction = '  brew ' + result.publish_args.join(' ') + continuation + result.pr_urls.join(continuation)
	result.ohai_messages << 'Now run:'
	result.ohai_messages << result.instruction
	return result
}

@[heap]
pub struct PrAutomergeInput {
pub:
	options PrAutomergeOptions
}

pub fn pr_automerge_input_boundary(input &PrAutomergeInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::PrAutomerge::Input', '', {
		'pr_automerge_input_address': u64(voidptr(input)).str()
	})
}

fn pr_automerge_input_from_value(value ruby.Value) &PrAutomergeInput {
	address := value.attributes['pr_automerge_input_address'] or {
		panic('invalid PrAutomerge command input')
	}
	return unsafe { &PrAutomergeInput(voidptr(address.u64())) }
}

fn pr_automerge_result_value(result PrAutomergeResult) ruby.Value {
	return ruby.map_value({
		'query':              ruby.string_value(result.query)
		'debug_messages':     ruby.string_array_value(result.debug_messages)
		'ohai_messages':      ruby.string_array_value(result.ohai_messages)
		'pull_request_lines': ruby.string_array_value(result.pull_request_lines)
		'pr_urls':            ruby.string_array_value(result.pr_urls)
		'publish_args':       ruby.string_array_value(result.publish_args)
		'publish_command':    ruby.string_array_value(result.publish_command)
		'instruction':        ruby.string_value(result.instruction)
		'published':          ruby.bool_value(result.published)
		'no_matches':         ruby.bool_value(result.no_matches)
	})
}
