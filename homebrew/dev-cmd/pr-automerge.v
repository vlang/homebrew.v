module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/pr-automerge.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn pr_automerge_input_boundary(input &PrAutomergeInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::PrAutomerge::Input', '', {
		'pr_automerge_input_address': u64(voidptr(input)).str()
	})
}

fn pr_automerge_input_from_value(value brew_runtime.Value) &PrAutomergeInput {
	address := value.attributes['pr_automerge_input_address'] or {
		panic('invalid PrAutomerge command input')
	}
	return unsafe { &PrAutomergeInput(voidptr(address.u64())) }
}

fn pr_automerge_result_value(result PrAutomergeResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'query':              brew_runtime.string_value(result.query)
		'debug_messages':     brew_runtime.string_array_value(result.debug_messages)
		'ohai_messages':      brew_runtime.string_array_value(result.ohai_messages)
		'pull_request_lines': brew_runtime.string_array_value(result.pull_request_lines)
		'pr_urls':            brew_runtime.string_array_value(result.pr_urls)
		'publish_args':       brew_runtime.string_array_value(result.publish_args)
		'publish_command':    brew_runtime.string_array_value(result.publish_command)
		'instruction':        brew_runtime.string_value(result.instruction)
		'published':          brew_runtime.bool_value(result.published)
		'no_matches':         brew_runtime.bool_value(result.no_matches)
	})
}

// Ruby method `run` at line 41.
pub fn ruby_pr_automerge_l41_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := pr_automerge_input_from_value(args[0])
	return pr_automerge_result_value(run_pr_automerge(input.options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6: require "utils/github"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class PrAutomerge < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Find pull requests that can be automatically merged using `brew pr-publish`.
// 14:         EOS
// 15:         flag   "--tap=",
// 16:                description: "Target tap repository (default: `homebrew/core`)."
// 17:         flag   "--workflow=",
// 18:                description: "Workflow file to use with `brew pr-publish`."
// 19:         flag   "--with-label=",
// 20:                description: "Pull requests must have this label."
// 21:         comma_array "--without-labels",
// 22:                     description: "Pull requests must not have these labels (default: " \
// 23:                                  "`do not merge`, `new formula`, `automerge-skip`, " \
// 24:                                  "`pre-release`, `CI-published-bottle-commits`)."
// 25:         switch "--without-approval",
// 26:                description: "Pull requests do not require approval to be merged."
// 27:         switch "--publish",
// 28:                description: "Run `brew pr-publish` on matching pull requests."
// 29:         switch "--autosquash",
// 30:                description: "Instruct `brew pr-publish` to automatically reformat and reword commits " \
// 31:                             "in the pull request to the preferred format."
// 32:         switch "--ignore-failures",
// 33:                description: "Include pull requests that have failing status checks."
// 34:
// 35:         named_args :none
// 36:
// 37:         hide_from_man_page!
// 38:       end
// 39:
// 40:       sig { override.void }
// 41:       def run
// 42:         without_labels = args.without_labels || [
// 43:           "do not merge",
// 44:           "new formula",
// 45:           "automerge-skip",
// 46:           "pre-release",
// 47:           "CI-published-bottle-commits",
// 48:         ]
// 49:         tap = Tap.fetch(args.tap || CoreTap.instance.name)
// 50:
// 51:         query = "is:pr is:open repo:#{tap.full_name} draft:false"
// 52:         query += args.ignore_failures? ? " -status:pending" : " status:success"
// 53:         query += " review:approved" unless args.without_approval?
// 54:         query += " label:\"#{args.with_label}\"" if args.with_label
// 55:         without_labels.each { |label| query += " -label:\"#{label}\"" }
// 56:         odebug "Searching: #{query}"
// 57:
// 58:         prs = GitHub.search_issues query
// 59:         if prs.blank?
// 60:           ohai "No matching pull requests!"
// 61:           return
// 62:         end
// 63:
// 64:         ohai "#{prs.count} matching pull #{Utils.pluralize("request", prs.count)}:"
// 65:         pr_urls = []
// 66:         prs.each do |pr|
// 67:           puts "#{tap.full_name unless tap.core_tap?}##{pr["number"]}: #{pr["title"]}"
// 68:           pr_urls << pr["html_url"]
// 69:         end
// 70:
// 71:         publish_args = ["pr-publish"]
// 72:         publish_args << "--tap=#{tap}" if tap
// 73:         publish_args << "--workflow=#{args.workflow}" if args.workflow
// 74:         publish_args << "--autosquash" if args.autosquash?
// 75:         if args.publish?
// 76:           safe_system HOMEBREW_BREW_FILE, *publish_args, *pr_urls
// 77:         else
// 78:           ohai "Now run:", "  brew #{publish_args.join " "} \\\n    #{pr_urls.join " \\\n    "}"
// 79:         end
// 80:       end
// 81:     end
// 82:   end
// 83: end
