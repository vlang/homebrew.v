module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/pr-publish.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct PrPublishOptions {
pub:
	tap_full_name     string = 'homebrew/core'
	tap_default_remote string = 'https://github.com/Homebrew/homebrew-core'
	tap_explicit      bool
	workflow          string = 'publish-commit-bottles.yml'
	branch            string = 'main'
	autosquash        bool
	large_runner      bool
	message           string
	named             []string
	labels            map[string][]string
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

pub fn pr_publish_input_boundary(input &PrPublishInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::PrPublish::Input', '', {
		'pr_publish_input_address': u64(voidptr(input)).str()
	})
}

fn pr_publish_input_from_value(value brew_runtime.Value) &PrPublishInput {
	address := value.attributes['pr_publish_input_address'] or { panic('invalid PrPublish input') }
	return unsafe { &PrPublishInput(voidptr(address.u64())) }
}

fn pr_publish_dispatch_value(dispatch PrPublishDispatch) brew_runtime.Value {
	return brew_runtime.map_value({
		'user': brew_runtime.string_value(dispatch.user)
		'repo': brew_runtime.string_value(dispatch.repo)
		'issue': brew_runtime.string_value(dispatch.issue)
		'workflow': brew_runtime.string_value(dispatch.workflow)
		'ref': brew_runtime.string_value(dispatch.ref)
		'autosquash': brew_runtime.bool_value(dispatch.autosquash)
		'large_runner': brew_runtime.bool_value(dispatch.large_runner)
		'message': brew_runtime.string_value(dispatch.message)
	})
}

fn pr_publish_result_value(result PrPublishResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'tap': brew_runtime.string_value(result.tap)
		'messages': brew_runtime.string_array_value(result.messages)
		'dispatches': brew_runtime.array_value(result.dispatches.map(pr_publish_dispatch_value(it)))
	})
}

// Ruby method `run` at line 37.
pub fn ruby_pr_publish_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return pr_publish_result_value(run_pr_publish(pr_publish_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('Error', err.msg())
	})
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
// 10:     class PrPublish < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Publish bottles for a pull request with GitHub Actions.
// 14:           Requires write access to the repository.
// 15:         EOS
// 16:         switch "--autosquash",
// 17:                description: "If supported on the target tap, automatically reformat and reword commits " \
// 18:                             "to our preferred format."
// 19:         switch "--large-runner",
// 20:                description: "Run the upload job on a large runner."
// 21:         flag   "--branch=",
// 22:                description: "Branch to use the workflow from (default: `main`)."
// 23:         flag   "--message=",
// 24:                depends_on:  "--autosquash",
// 25:                description: "Message to include when autosquashing revision bumps, deletions and rebuilds."
// 26:         flag   "--tap=",
// 27:                description: "Target tap repository (default: `homebrew/core`)."
// 28:         flag   "--workflow=",
// 29:                description: "Target workflow filename (default: `publish-commit-bottles.yml`)."
// 30:
// 31:         named_args :pull_request, min: 1
// 32:
// 33:         hide_from_man_page!
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         tap = Tap.fetch(args.tap || CoreTap.instance.name)
// 39:         workflow = args.workflow || "publish-commit-bottles.yml"
// 40:         ref = args.branch || "main"
// 41:
// 42:         inputs = {
// 43:           autosquash:   args.autosquash?,
// 44:           large_runner: args.large_runner?,
// 45:         }
// 46:         inputs[:message] = args.message if args.message.presence
// 47:
// 48:         args.named.uniq.each do |arg|
// 49:           arg = "#{tap.default_remote}/pull/#{arg}" if arg.to_i.positive?
// 50:           url_match = arg.match HOMEBREW_PULL_OR_COMMIT_URL_REGEX
// 51:           _, user, repo, issue = *url_match
// 52:           odie "Not a GitHub pull request: #{arg}" if !user || !repo || !issue
// 53:
// 54:           inputs[:pull_request] = issue
// 55:
// 56:           pr_labels = GitHub.pull_request_labels(user, repo, issue)
// 57:           if pr_labels.include?("autosquash")
// 58:             oh1 "Found `autosquash` label on ##{issue}. Requesting autosquash."
// 59:             inputs[:autosquash] = true
// 60:           end
// 61:           if pr_labels.include?("large-bottle-upload")
// 62:             oh1 "Found `large-bottle-upload` label on ##{issue}. Requesting upload on large runner."
// 63:             inputs[:large_runner] = true
// 64:           end
// 65:
// 66:           if args.tap.present? && !T.must("#{user}/#{repo}".casecmp(tap.full_name)).zero?
// 67:             odie "Pull request URL is for #{user}/#{repo} but `--tap=#{tap.full_name}` was specified!"
// 68:           end
// 69:
// 70:           ohai "Dispatching #{tap} pull request ##{issue}"
// 71:           GitHub.workflow_dispatch_event(user, repo, workflow, ref, **inputs)
// 72:         end
// 73:       end
// 74:     end
// 75:   end
// 76: end
