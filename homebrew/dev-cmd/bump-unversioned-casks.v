module dev_cmd

import ruby
import os
import time
import x.json2

// Translated from Homebrew/brew `dev-cmd/bump-unversioned-casks.rb`.

pub struct BumpUnversionedState {
pub:
	sha256_present    bool
	sha256            string
	check_time        string
	time_present      bool
	time              string
	file_size_present bool
	file_size         i64
}

pub struct BumpUnversionedCask {
pub mut:
	full_name                  string
	name                       string
	version                    string
	sourcefile_path            string
	url_unversioned            bool
	livecheck_defined          bool
	single_app                 bool
	single_pkg                 bool
	single_qlplugin            bool
	dequeue_time               i64
	check_time                 i64
	download_failed            bool
	download_time_present      bool
	download_time              i64
	download_file_size_present bool
	download_file_size         i64
	sha256                     string
	sha256_error               string
	guessed_version            string
	guess_timed_out            bool
	guess_error                string
	bump_command_succeeded     bool = true
	bump_command_error         string
}

pub struct BumpUnversionedOptions {
pub:
	casks                    []BumpUnversionedCask
	state                    map[string]BumpUnversionedState
	state_file               string
	cache_directory          string
	dry_run                  bool
	limit_present            bool
	limit_minutes            int
	now                      i64
	brew_file                string = 'brew'
	shuffled_unchecked_names []string
}

pub enum BumpUnversionedMessageKind {
	ohai
	warning
	error
	info
}

pub struct BumpUnversionedMessage {
pub:
	kind BumpUnversionedMessageKind
	text string
}

pub struct BumpUnversionedCheckOptions {
pub:
	dry_run   bool
	now       i64
	brew_file string = 'brew'
}

pub struct BumpUnversionedCheckResult {
pub:
	skipped  bool
	state    BumpUnversionedState
	messages []BumpUnversionedMessage
	commands [][]string
}

pub struct BumpUnversionedResult {
pub:
	bundler_groups  []string
	state_file      string
	state_directory string
	selected        []string
	queued          []string
pub mut:
	processed    []string
	state        map[string]BumpUnversionedState
	state_writes []string
	commands     [][]string
	messages     []BumpUnversionedMessage
	timed_out    bool
}

fn bump_unversioned_name(cask BumpUnversionedCask) string {
	return if cask.name != '' { cask.name } else { cask.full_name }
}

fn bump_unversioned_iso8601(epoch i64) string {
	return time.unix(epoch).format_rfc3339().replace('.000Z', 'Z')
}

fn bump_unversioned_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn bump_unversioned_state_value(state BumpUnversionedState) ruby.Value {
	return ruby.map_value({
		'sha256':     if state.sha256_present {
			ruby.string_value(state.sha256)
		} else {
			bump_unversioned_nil_value()
		}
		'check_time': ruby.string_value(state.check_time)
		'time':       if state.time_present {
			ruby.string_value(state.time)
		} else {
			bump_unversioned_nil_value()
		}
		'file_size':  if state.file_size_present {
			ruby.int_value(state.file_size)
		} else {
			bump_unversioned_nil_value()
		}
	})
}

fn bump_unversioned_state_map_value(state map[string]BumpUnversionedState) ruby.Value {
	mut names := state.keys()
	names.sort()
	mut values := map[string]ruby.Value{}
	for name in names {
		values[name] = bump_unversioned_state_value(state[name])
	}
	return ruby.map_value(values)
}

fn bump_unversioned_pretty_state(state map[string]BumpUnversionedState) string {
	encoded := json2.encode(ruby.json_any_from_value(bump_unversioned_state_map_value(state)),
		prettify: true
	)
	mut lines := []string{cap: encoded.count('\n') + 1}
	for line in encoded.split('\n') {
		content := line.trim_left(' ')
		indent := line.len - content.len
		lines << ' '.repeat(indent / 2) + content
	}
	return lines.join('\n')
}

fn bump_unversioned_time_matches(state BumpUnversionedState,
	cask BumpUnversionedCask) !bool {
	mut state_time := i64(0)
	if state.time_present {
		state_time = time.parse_iso8601(state.time)!.unix()
	}
	if state.time_present != cask.download_time_present {
		return false
	}
	if !state.time_present {
		return true
	}
	return state_time == cask.download_time
}

fn bump_unversioned_size_matches(state BumpUnversionedState,
	cask BumpUnversionedCask) bool {
	return state.file_size_present == cask.download_file_size_present
		&& (!state.file_size_present || state.file_size == cask.download_file_size)
}

pub fn bump_unversioned_cask(cask BumpUnversionedCask, state BumpUnversionedState,
	options BumpUnversionedCheckOptions) !BumpUnversionedCheckResult {
	mut messages := [BumpUnversionedMessage{
		kind: .ohai
		text: 'Checking ${cask.full_name}'
	}]
	if !cask.single_app && !cask.single_pkg && !cask.single_qlplugin {
		messages << BumpUnversionedMessage{
			kind: .warning
			text: 'Skipping, not a single-app or PKG cask.'
		}
		return BumpUnversionedCheckResult{
			skipped: true
			messages: messages
		}
	}

	check_time := if cask.check_time != 0 { cask.check_time } else { options.now }
	if state.check_time != '' {
		last_check_time := time.parse_iso8601(state.check_time)!
		if check_time - last_check_time.unix() < 24 * 60 * 60 {
			messages << BumpUnversionedMessage{
				kind: .warning
				text: 'Skipping, already checked within the last 24 hours.'
			}
			return BumpUnversionedCheckResult{
				skipped: true
				messages: messages
			}
		}
	}

	mut observed := cask
	if cask.download_failed {
		observed.download_time_present = false
		observed.download_file_size_present = false
	}
	metadata_changed := !(bump_unversioned_time_matches(state, observed)!)
		|| !bump_unversioned_size_matches(state, observed)
	mut sha256 := ''
	mut commands := [][]string{}
	if metadata_changed {
		if cask.sha256_error != '' {
			messages << BumpUnversionedMessage{
				kind: .error
				text: cask.sha256_error
			}
		} else {
			sha256 = cask.sha256
		}
		if sha256 != '' && (!state.sha256_present || state.sha256 != sha256) {
			if cask.guess_timed_out {
				messages << BumpUnversionedMessage{
					kind: .error
					text: "Timed out guessing version for cask '${bump_unversioned_name(cask)}'."
				}
			} else if cask.guess_error != '' {
				return error(cask.guess_error)
			} else if cask.guessed_version != '' {
				name := bump_unversioned_name(cask)
				if cask.version == cask.guessed_version {
					messages << BumpUnversionedMessage{
						kind: .info
						text: 'Cask ${name} is up-to-date at ${cask.guessed_version}'
					}
				} else {
					if cask.sourcefile_path == '' {
						return error('unexpected nil cask.sourcefile_path')
					}
					mut command := [options.brew_file, 'bump-cask-pr', '--version',
						cask.guessed_version, '--sha256', ':no_check', '--message',
						'Automatic update via `brew bump-unversioned-casks`.', cask.sourcefile_path]
					if options.dry_run {
						command << '--dry-run'
						messages << BumpUnversionedMessage{
							kind: .info
							text: 'Would bump ${name} from ${cask.version} to ${cask.guessed_version}'
						}
					} else {
						messages << BumpUnversionedMessage{
							kind: .info
							text: 'Bumping ${name} from ${cask.version} to ${cask.guessed_version}'
						}
					}
					commands << command
					if !cask.bump_command_succeeded {
						messages << BumpUnversionedMessage{
							kind: .error
							text: if cask.bump_command_error != '' {
								cask.bump_command_error
							} else {
								'brew bump-cask-pr failed'
							}
						}
					}
				}
			}
		}
	}
	return BumpUnversionedCheckResult{
		state: BumpUnversionedState{
			sha256_present: sha256 != ''
			sha256: sha256
			check_time: bump_unversioned_iso8601(check_time)
			time_present: observed.download_time_present
			time: if observed.download_time_present {
				bump_unversioned_iso8601(observed.download_time)
			} else {
				''
			}
			file_size_present: observed.download_file_size_present
			file_size: observed.download_file_size
		}
		messages: messages
		commands: commands
	}
}

fn bump_unversioned_unchecked(casks []BumpUnversionedCask, preferred []string) []BumpUnversionedCask {
	mut ordered := []BumpUnversionedCask{cap: casks.len}
	mut used := map[string]bool{}
	for name in preferred {
		for cask in casks {
			if cask.full_name == name && !used[name] {
				ordered << cask
				used[name] = true
				break
			}
		}
	}
	for cask in casks {
		if !used[cask.full_name] {
			ordered << cask
			used[cask.full_name] = true
		}
	}
	return ordered
}

fn bump_unversioned_checked(casks []BumpUnversionedCask,
	state map[string]BumpUnversionedState) []BumpUnversionedCask {
	mut ordered := []BumpUnversionedCask{}
	for cask in casks {
		check_time := state[cask.full_name].check_time
		mut inserted := false
		for index, existing in ordered {
			if check_time < state[existing.full_name].check_time {
				ordered.insert(index, cask)
				inserted = true
				break
			}
		}
		if !inserted {
			ordered << cask
		}
	}
	return ordered
}

pub fn run_bump_unversioned_casks(options BumpUnversionedOptions) !BumpUnversionedResult {
	now := if options.now != 0 { options.now } else { time.now().unix() }
	cache_directory := if options.cache_directory != '' { options.cache_directory } else { '.' }
	state_file := if options.state_file != '' {
		os.abs_path(options.state_file)
	} else {
		os.join_path(cache_directory, 'bump_unversioned_casks.json')
	}
	mut selected_casks := []BumpUnversionedCask{}
	for cask in options.casks {
		if cask.url_unversioned && !cask.livecheck_defined {
			selected_casks << cask
		}
	}
	mut unchecked := []BumpUnversionedCask{}
	mut checked := []BumpUnversionedCask{}
	for cask in selected_casks {
		if cask.full_name in options.state {
			checked << cask
		} else {
			unchecked << cask
		}
	}
	mut queue := bump_unversioned_unchecked(unchecked, options.shuffled_unchecked_names)
	queue << bump_unversioned_checked(checked, options.state)
	mut result := BumpUnversionedResult{
		bundler_groups: ['bump_unversioned_casks']
		state_file: state_file
		state_directory: os.dir(state_file)
		selected: selected_casks.map(it.full_name)
		queued: queue.map(it.full_name)
		state: options.state.clone()
		messages: [BumpUnversionedMessage{
			kind: .ohai
			text: 'Unversioned Casks: ${selected_casks.len} (${options.state.len} cached)'
		}]
	}
	end_time := now + i64(options.limit_minutes * 60)
	for cask in queue {
		dequeue_time := if cask.dequeue_time != 0 { cask.dequeue_time } else { now }
		if options.limit_present && end_time < dequeue_time {
			result.timed_out = true
			break
		}
		state := result.state[cask.full_name] or { BumpUnversionedState{} }
		check := bump_unversioned_cask(cask, state, BumpUnversionedCheckOptions{
			dry_run: options.dry_run
			now: now
			brew_file: options.brew_file
		})!
		result.processed << cask.full_name
		result.messages << check.messages
		result.commands << check.commands
		if check.skipped {
			continue
		}
		result.state[cask.full_name] = check.state
		if !options.dry_run {
			result.state_writes << bump_unversioned_pretty_state(result.state)
		}
	}
	return result
}

@[heap]
pub struct BumpUnversionedInput {
pub:
	options BumpUnversionedOptions
}

@[heap]
pub struct BumpUnversionedCheckInput {
pub:
	cask    BumpUnversionedCask
	state   BumpUnversionedState
	options BumpUnversionedCheckOptions
}

pub fn bump_unversioned_input_boundary(input &BumpUnversionedInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::BumpUnversionedCasks::Input', '', {
		'bump_unversioned_input_address': u64(voidptr(input)).str()
	})
}

pub fn bump_unversioned_check_input_boundary(input &BumpUnversionedCheckInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::BumpUnversionedCasks::CheckInput', '', {
		'bump_unversioned_check_input_address': u64(voidptr(input)).str()
	})
}

fn bump_unversioned_input_from_value(value ruby.Value) &BumpUnversionedInput {
	address := value.attributes['bump_unversioned_input_address'] or { panic('invalid bump-unversioned-casks input') }
	return unsafe { &BumpUnversionedInput(voidptr(address.u64())) }
}

fn bump_unversioned_check_input_from_value(value ruby.Value) &BumpUnversionedCheckInput {
	address := value.attributes['bump_unversioned_check_input_address'] or { panic('invalid bump-unversioned-casks check input') }
	return unsafe { &BumpUnversionedCheckInput(voidptr(address.u64())) }
}

fn bump_unversioned_messages_value(messages []BumpUnversionedMessage) ruby.Value {
	return ruby.array_value(messages.map(ruby.map_value({
		'kind': ruby.string_value(it.kind.str())
		'text': ruby.string_value(it.text)
	})))
}

fn bump_unversioned_result_value(result BumpUnversionedResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups':  ruby.string_array_value(result.bundler_groups)
		'state_file':      ruby.string_value(result.state_file)
		'state_directory': ruby.string_value(result.state_directory)
		'selected':        ruby.string_array_value(result.selected)
		'queued':          ruby.string_array_value(result.queued)
		'processed':       ruby.string_array_value(result.processed)
		'state':           bump_unversioned_state_map_value(result.state)
		'state_writes':    ruby.string_array_value(result.state_writes)
		'commands':        ruby.array_value(result.commands.map(ruby.string_array_value(it)))
		'messages':        bump_unversioned_messages_value(result.messages)
		'timed_out':       ruby.bool_value(result.timed_out)
	})
}
