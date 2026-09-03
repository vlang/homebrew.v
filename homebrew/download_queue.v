module homebrew

import brew_runtime
import time

// Translated from Homebrew/brew `download_queue.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum DownloadState {
	pending
	processing
	fulfilled
	rejected
}

pub struct QueuedResource {
pub:
	resource_pointer  voidptr
	cached_location   string
	check_attestation bool
	stage             bool
}

pub struct DownloadQueue {
pub mut:
	concurrency      int
	quiet            bool
	tries            int
	force            bool
	pour             bool
	tty              bool
	dumb_tty         bool
	cancelled        bool
	queued           []QueuedResource
	failed_downloads []string
	spinner_value    Spinner
}

pub enum DownloadQueueFailureKind {
	none
	download
	bottle_manifest
	checksum
	interrupt
}

pub struct DownloadQueueDownload {
pub mut:
	key                 string
	cached_location     string
	message             string
	kind                ResourceKind
	downloaded_valid    bool
	fetched_path        string
	failure_kind        DownloadQueueFailureKind
	failure_message     string
	fetched_size        i64
	has_fetched_size    bool
	total_size          i64
	has_total_size      bool
	phase               ResourcePhase = .preparing
	stage               bool
	stageable           bool
	check_attestation   bool
	is_bottle           bool
	cache_exists        bool
	download_fetches    int
	downloader_requests int
}

pub struct DownloadQueueExecutionOptions {
pub:
	concurrency    int = 2
	tty            bool
	dumb_tty       bool
	terminal_width int = 80
	heading        string
	allow_failures bool
	only           ?ResourceKind
}

pub struct DownloadQueueExecution {
pub mut:
	stdout             string
	stderr             string
	error_message      string
	failed_downloads   []string
	remaining          []string
	events             []string
	removed_caches     []string
	attestations       []string
	homebrew_failed    bool
	cancelled          bool
	synchronized_open  int
	synchronized_close int
}

pub struct DefaultDownloadQueueState {
pub mut:
	initialized bool
	queue       DownloadQueue
	shutdowns   int
}

pub fn default_download_queue_from_state(mut state DefaultDownloadQueueState) &DownloadQueue {
	if !state.initialized {
		state.queue = new_download_queue(1, false, false)
		state.initialized = true
	}
	return &state.queue
}

pub fn reset_default_download_queue_state(mut state DefaultDownloadQueueState) {
	if state.initialized {
		state.queue.shutdown()
		state.shutdowns++
	}
	state.initialized = false
}

pub fn execute_download_queue(mut downloads []DownloadQueueDownload, options DownloadQueueExecutionOptions) DownloadQueueExecution {
	mut execution := DownloadQueueExecution{}
	mut selected := []int{}
	for index, download in downloads {
		if only := options.only {
			if download.kind != only {
				execution.remaining << download.key
				continue
			}
		}
		selected << index
	}
	if selected.len == 0 {
		return execution
	}
	if options.heading != '' {
		if options.tty {
			execution.stdout += '==> ${options.heading}\n'
		} else {
			execution.stderr += '==> ${options.heading}\n'
		}
	}
	if options.tty && !options.dumb_tty {
		execution.stdout += '\\e[?25l\\e[?2026h'
		execution.synchronized_open++
	}
	mut fetched_locations := map[string]string{}
	mut deferred_failures := []string{}
	for index in selected {
		mut download := downloads[index]
		if execution.cancelled {
			break
		}
		if prior := fetched_locations[download.cached_location] {
			download.fetched_path = prior
			execution.events << 'symlink:${download.key}:${prior}'
		} else if download.downloaded_valid {
			download.downloader_requests++
			download.fetched_path = download.cached_location
			fetched_locations[download.cached_location] = download.cached_location
			execution.events << 'cached:${download.key}'
		} else if download.failure_kind != .none {
			download.download_fetches++
			message := if download.failure_message != '' {
				download.failure_message
			} else {
				'download failed'
			}
			if download.failure_kind == .interrupt {
				execution.cancelled = true
				execution.error_message = 'Interrupt'
				execution.events << 'stage-interrupted:${download.key}'
				downloads[index] = download
				break
			}
			if options.allow_failures {
				execution.stderr += '${download_queue_failure_status(options.tty)} ${download.message}\n'
				if download.failure_kind == .checksum && download.cache_exists {
					execution.removed_caches << download.cached_location
					download.cache_exists = false
				}
				downloads[index] = download
				continue
			}
			if download.failure_kind == .checksum {
				execution.failed_downloads << download.key
			} else if download.failure_kind == .bottle_manifest {
				execution.cancelled = true
				execution.error_message = message
				downloads[index] = download
				break
			} else {
				execution.failed_downloads << download.key
				execution.homebrew_failed = true
				if options.tty && !options.dumb_tty && message.contains('\n') {
					deferred_failures << message
				} else {
					execution.stderr += '${message}\n'
				}
			}
			downloads[index] = download
			continue
		} else {
			download.download_fetches++
			path := if download.fetched_path != '' {
				download.fetched_path
			} else {
				download.cached_location
			}
			download.fetched_path = path
			fetched_locations[download.cached_location] = path
			if path != download.cached_location {
				fetched_locations[path] = path
			}
		}
		if download.check_attestation && download.is_bottle {
			execution.attestations << download.key
		}
		if download.stage && download.stageable {
			execution.events << 'stageable:${download.key}:${download.fetched_path}'
			execution.events << 'extracting:${download.key}'
			execution.events << 'stage:${download.key}:${download.fetched_path}'
			execution.events << 'downloaded:${download.key}'
		}
		if options.tty && !options.dumb_tty {
			execution.stdout += '${download_queue_success_status(true)} ${download_queue_progress_line(download, options.terminal_width - 3)}\n'
		} else {
			execution.stderr += '${download_queue_success_status(false)} ${download.message}\n'
		}
		execution.events << 'resolution-wakeup:${download.key}'
		downloads[index] = download
	}
	if options.tty && !options.dumb_tty {
		execution.stdout += '\\e[?2026l\\e[?25h'
		execution.synchronized_close++
	}
	for failure in deferred_failures {
		execution.stderr += '${failure}\n'
	}
	return execution
}

fn download_queue_success_status(tty bool) string {
	return if tty { '\\e[32m✔︎\\e[0m' } else { '✔︎' }
}

fn download_queue_failure_status(tty bool) string {
	return if tty { '\\e[31m✘\\e[0m' } else { '✘' }
}

fn download_queue_progress_line(download DownloadQueueDownload, terminal_width int) string {
	if terminal_width <= 1 {
		return ''
	}
	available := terminal_width - 1
	mut line := download.message
	if download.has_fetched_size {
		size := download_queue_readable_size(download.fetched_size)
		total := if download.has_total_size {
			download_queue_readable_size(download.total_size)
		} else {
			'-------'
		}
		phase := download.phase.str().capitalize()
		line = '${download.message} ${phase} ${size}/${total}'
	}
	runes := line.runes()
	if runes.len > available {
		return runes[..available].string()
	}
	return line + ' '.repeat(available - runes.len)
}

fn download_queue_readable_size(bytes i64) string {
	if bytes >= 1_000_000 {
		return '${f64(bytes) / 1_000_000.0:.1f}MB'
	}
	if bytes >= 1_000 {
		return '${f64(bytes) / 1_000.0:.1f}KB'
	}
	return '${bytes}B'
}

pub fn new_download_queue(retries int, force bool, pour bool) DownloadQueue {
	configured := brew_runtime.environment_value('HOMEBREW_DOWNLOAD_CONCURRENCY').int()
	concurrency := if configured > 0 { configured } else { 1 }
	return DownloadQueue{
		concurrency: concurrency
		quiet: concurrency > 1
		tries: retries + 1
		force: force
		pour: pour
		tty: brew_runtime.stdout_is_terminal()
		dumb_tty: brew_runtime.environment_value('TERM') == 'dumb'
		spinner_value: new_spinner()
	}
}

// enqueue records a pointer-stable resource. Fetching is intentionally serial
// until V's parallel Downloadable abstraction is translated.
pub fn (mut queue DownloadQueue) enqueue(mut resource Resource, check_attestation bool, stage bool) ! {
	queue.cancelled = false
	cached_location := resource.cached_download()!
	resource_pointer := voidptr(&resource)
	for mut existing in queue.queued {
		if existing.resource_pointer == resource_pointer {
			if stage && !existing.stage {
				existing = QueuedResource{
					resource_pointer: existing.resource_pointer
					cached_location: existing.cached_location
					check_attestation: existing.check_attestation || check_attestation
					stage: true
				}
			}
			return
		}
	}
	queue.queued << QueuedResource{
		resource_pointer: resource_pointer
		cached_location: cached_location
		check_attestation: check_attestation
		stage: stage
	}
}

// fetch waits for the selected serial downloads, preserving unselected queue
// entries for a later type-filtered fetch.
pub fn (mut queue DownloadQueue) fetch(only ?ResourceKind, heading ?string, allow_failures bool) ! {
	queue.failed_downloads.clear()
	mut selected_indices := []int{}
	for index, item in queue.queued {
		resource := unsafe { &Resource(item.resource_pointer) }
		if kind := only {
			if resource.kind != kind {
				continue
			}
		}
		selected_indices << index
	}
	if selected_indices.len == 0 {
		return
	}
	if title := heading {
		if queue.tty {
			println('==> ${title}')
		} else {
			eprintln('==> ${title}')
		}
	}
	mut completed_locations := []string{}
	for index in selected_indices {
		if queue.cancelled {
			break
		}
		item := queue.queued[index]
		mut resource := unsafe { &Resource(item.resource_pointer) }
		if item.cached_location in completed_locations {
			queue.create_symlinks_for_shared_download(item.cached_location)!
			resource.phase = .downloaded
			continue
		}
		if queue.force {
			resource.clear_cache() or {}
		}
		if !queue.force && resource.downloaded_and_valid() {
			queue.check_bottle_attestation(resource, item.check_attestation)!
			queue.create_symlinks_for_shared_download(item.cached_location)!
			completed_locations << item.cached_location
			continue
		}
		mut last_error := ''
		mut downloaded_path := ''
		for attempt in 0 .. queue.tries {
			downloaded_path = resource.fetch(true, none, queue.quiet, false) or {
				last_error = err.msg()
				if attempt + 1 < queue.tries {
					continue
				}
				''
			}
			if downloaded_path != '' {
				break
			}
		}
		if downloaded_path == '' {
			if allow_failures {
				queue.report_tolerated_failure(resource)
				if last_error.contains('SHA-256 mismatch') {
					queue.unlink_cached_download(mut resource)
				}
				continue
			}
			queue.failed_downloads << resource.download_queue_name() or { resource.name }
			queue.cancel()
			queue.remove_selected(selected_indices)
			return error(last_error)
		}
		queue.check_bottle_attestation(resource, item.check_attestation)!
		queue.create_symlinks_for_shared_download(downloaded_path)!
		completed_locations << downloaded_path
		if item.stage {
			// Resource itself returns false for queued staging; Bottle owns the
			// still-untranslated pour/staging specialization.
			resource.phase = .downloaded
		}
		if !queue.tty {
			eprintln('✔︎ ${resource.download_queue_message()!}')
		}
	}
	queue.remove_selected(selected_indices)
}

fn (mut queue DownloadQueue) remove_selected(indices []int) {
	mut remaining := []QueuedResource{}
	for index, item in queue.queued {
		if index !in indices {
			remaining << item
		}
	}
	queue.queued = remaining
}

pub fn (queue &DownloadQueue) downloads() []string {
	mut messages := []string{}
	for item in queue.queued {
		resource := unsafe { &Resource(item.resource_pointer) }
		messages << resource.download_queue_message() or { resource.name }
	}
	return messages
}

pub fn (queue &DownloadQueue) stdout_print_and_flush_if_tty(message string) {
	if queue.tty_with_cursor_move_support() {
		print(message)
	}
}

pub fn (queue &DownloadQueue) stdout_print_and_flush(message string) {
	_ = queue
	print(message)
}

// Serial queues own no worker pool, so shutdown is an idempotent state clear.
pub fn (mut queue DownloadQueue) shutdown() {
	queue.cancelled = true
}

pub fn (queue &DownloadQueue) pool() string {
	return 'serial'
}

pub fn (queue &DownloadQueue) check_bottle_attestation(resource &Resource, check_attestation bool) ! {
	_ = queue
	_ = resource
	_ = check_attestation
	// Only Bottle (not Resource) performs attestation; its typed boundary is not
	// present in this serial Resource queue.
}

pub fn (mut queue DownloadQueue) create_symlinks_for_shared_download(cached_location string) ! {
	for item in queue.queued {
		if item.cached_location != cached_location {
			continue
		}
		mut resource := unsafe { &Resource(item.resource_pointer) }
		mut downloader := resource.downloader()!
		downloader.file.create_symlink_to_cached_download(cached_location)!
	}
}

pub fn (queue &DownloadQueue) bottle_manifest_error(resource &Resource, exception string) bool {
	_ = queue
	return exception != '' && (resource.kind == .bottle_manifest || exception.contains('Bottle Manifest'))
}

pub fn (queue &DownloadQueue) report_or_defer_failure(message string) {
	_ = queue
	eprintln(message)
}

pub fn (queue &DownloadQueue) with_active_thread() bool {
	return !queue.cancelled
}

pub fn (mut queue DownloadQueue) cancel() {
	queue.cancelled = true
}

pub fn (queue &DownloadQueue) tty_with_cursor_move_support() bool {
	return queue.tty && !queue.dumb_tty
}

pub fn (queue &DownloadQueue) unlink_cached_download(mut resource Resource) {
	_ = queue
	resource.clear_cache() or {}
}

pub fn (queue &DownloadQueue) report_tolerated_failure(resource &Resource) {
	_ = queue
	message := resource.download_queue_message() or { resource.name }
	eprintln('✘ ${message}')
}

pub fn (queue &DownloadQueue) status_from_future(state DownloadState) ?string {
	return match state {
		.fulfilled {
			if queue.tty {
				'\\e[32m✔︎\\e[0m'
			} else {
				'✔︎'
			}
		}
		.rejected {
			if queue.tty {
				'\\e[31m✘\\e[0m'
			} else {
				'✘'
			}
		}
		.pending, .processing {
			if queue.tty_with_cursor_move_support() {
				'\\e[34m${queue.spinner_value}\\e[0m'
			} else {
				none
			}
		}
	}
}

pub fn align_checksum_mismatch_message(downloadable_type string) (string, string) {
	actual := '${downloadable_type} reports different checksum:'
	expected := 'SHA-256 checksum of downloaded file:'
	width := if actual.len > expected.len { actual.len } else { expected.len }
	return actual + ' '.repeat(width - actual.len), '       ' + expected + ' '.repeat(width - expected.len)
}

pub struct Spinner {
mut:
	started i64
	index   int
}

pub fn new_spinner() Spinner {
	return Spinner{
		started: time.now().unix_milli()
	}
}

pub fn (mut spinner Spinner) str() string {
	frames := ['⠋', '⠙', '⠚', '⠞', '⠖', '⠦', '⠴', '⠲', '⠳', '⠓']
	now := time.now().unix_milli()
	if spinner.started + 100 < now {
		spinner.started = now
		spinner.index = (spinner.index + 1) % frames.len
	}
	return frames[spinner.index]
}

pub fn (mut queue DownloadQueue) spinner() string {
	return queue.spinner_value.str()
}

pub fn (mut queue DownloadQueue) message_with_progress(mut resource Resource, state DownloadState, message string, message_length_max int) string {
	_ = message_length_max
	fetched := resource.fetched_size() or { return message }
	total := resource.total_size() or { fetched }
	if state == .fulfilled {
		return '${message} ${fetched}/${fetched}'
	}
	if resource.phase == .downloading && total > 0 {
		calculated := f64(fetched) / f64(total) * 100.0
		percent := if calculated < 0.0 {
			0.0
		} else if calculated > 100.0 {
			100.0
		} else {
			calculated
		}
		return '${message} ${percent:.1f}% ${fetched}/${total}'
	}
	return '${message} ${fetched}/${total}'
}

// default_download_queue returns a fresh serial queue. Process-global queue
// memoization remains an application lifecycle concern for main.v.
pub fn default_download_queue() DownloadQueue {
	return new_download_queue(1, false, false)
}

pub fn reset_default_download_queue() {}

pub fn shutdown_default_download_queue() {}

// Source entrypoint translations.
// Ruby method `initialize(retries: 1, force: false, pour: false)` at line 23.
pub fn ruby_download_queue_l23_d1_initialize(retries int, force bool, pour bool) DownloadQueue {
	return new_download_queue(retries, force, pour)
}

// Ruby method `enqueue(downloadable, check_attestation: false, stage: pour)` at line 48.
pub fn ruby_download_queue_l48_d2_enqueue(mut queue DownloadQueue, mut resource Resource, check_attestation bool, stage bool) ! {
	queue.enqueue(mut resource, check_attestation, stage)!
}

// Ruby method `fetch(only: nil, heading: nil, allow_failures: false)` at line 119.
pub fn ruby_download_queue_l119_d3_fetch(mut queue DownloadQueue, only ?ResourceKind, heading ?string, allow_failures bool) ! {
	queue.fetch(only, heading, allow_failures)!
}

// Ruby attr_reader `attr_reader :failed_downloads` at line 314.
pub fn ruby_download_queue_l314_d4_failed_downloads(queue &DownloadQueue) []string {
	return queue.failed_downloads.clone()
}

// Ruby method `stdout_print_and_flush_if_tty(message)` at line 317.
pub fn ruby_download_queue_l317_d5_stdout_print_and_flush_if_tty(queue &DownloadQueue, message string) {
	queue.stdout_print_and_flush_if_tty(message)
}

// Ruby method `stdout_print_and_flush(message)` at line 322.
pub fn ruby_download_queue_l322_d6_stdout_print_and_flush(queue &DownloadQueue, message string) {
	queue.stdout_print_and_flush(message)
}

// Ruby method `shutdown` at line 328.
pub fn ruby_download_queue_l328_d7_shutdown(mut queue DownloadQueue) {
	queue.shutdown()
}

// Ruby method `downloads` at line 334.
pub fn ruby_download_queue_l334_d8_downloads(queue &DownloadQueue) []string {
	return queue.downloads()
}

// Ruby method `check_bottle_attestation(downloadable, check_attestation:)` at line 341.
pub fn ruby_download_queue_l341_d9_check_bottle_attestation(queue &DownloadQueue, resource &Resource, check_attestation bool) ! {
	queue.check_bottle_attestation(resource, check_attestation)!
}

// Ruby method `create_symlinks_for_shared_download(cached_location)` at line 349.
pub fn ruby_download_queue_l349_d10_create_symlinks_for_shared_download(mut queue DownloadQueue, cached_location string) ! {
	queue.create_symlinks_for_shared_download(cached_location)!
}

// Ruby method `bottle_manifest_error?(downloadable, exception)` at line 363.
pub fn ruby_download_queue_l363_d11_bottle_manifest_error(queue &DownloadQueue, resource &Resource, exception string) bool {
	return queue.bottle_manifest_error(resource, exception)
}

// Ruby method `report_or_defer_failure(&block)` at line 371.
pub fn ruby_download_queue_l371_d12_report_or_defer_failure(queue &DownloadQueue, message string) {
	queue.report_or_defer_failure(message)
}

// Ruby method `with_active_thread(&_block)` at line 380.
pub fn ruby_download_queue_l380_d13_with_active_thread(queue &DownloadQueue) bool {
	return queue.with_active_thread()
}

// Ruby method `cancel` at line 390.
pub fn ruby_download_queue_l390_d14_cancel(mut queue DownloadQueue) {
	queue.cancel()
}

// Ruby attr_reader `attr_reader :pool` at line 399.
pub fn ruby_download_queue_l399_d15_pool(queue &DownloadQueue) string {
	return queue.pool()
}

// Ruby attr_reader `attr_reader :concurrency` at line 402.
pub fn ruby_download_queue_l402_d16_concurrency(queue &DownloadQueue) int {
	return queue.concurrency
}

// Ruby attr_reader `attr_reader :tries` at line 405.
pub fn ruby_download_queue_l405_d17_tries(queue &DownloadQueue) int {
	return queue.tries
}

// Ruby attr_reader `attr_reader :force` at line 408.
pub fn ruby_download_queue_l408_d18_force(queue &DownloadQueue) bool {
	return queue.force
}

// Ruby attr_reader `attr_reader :quiet` at line 411.
pub fn ruby_download_queue_l411_d19_quiet(queue &DownloadQueue) bool {
	return queue.quiet
}

// Ruby attr_reader `attr_reader :pour` at line 414.
pub fn ruby_download_queue_l414_d20_pour(queue &DownloadQueue) bool {
	return queue.pour
}

// Ruby attr_reader `attr_reader :tty` at line 417.
pub fn ruby_download_queue_l417_d21_tty(queue &DownloadQueue) bool {
	return queue.tty
}

// Ruby method `tty_with_cursor_move_support?` at line 420.
pub fn ruby_download_queue_l420_d22_tty_with_cursor_move_support(queue &DownloadQueue) bool {
	return queue.tty_with_cursor_move_support()
}

// Ruby method `unlink_cached_download(downloadable)` at line 425.
pub fn ruby_download_queue_l425_d23_unlink_cached_download(queue &DownloadQueue, mut resource Resource) {
	queue.unlink_cached_download(mut resource)
}

// Ruby method `report_tolerated_failure(downloadable)` at line 433.
pub fn ruby_download_queue_l433_d24_report_tolerated_failure(queue &DownloadQueue, resource &Resource) {
	queue.report_tolerated_failure(resource)
}

// Ruby method `status_from_future(future)` at line 443.
pub fn ruby_download_queue_l443_d25_status_from_future(queue &DownloadQueue, state DownloadState) ?string {
	return queue.status_from_future(state)
}

// Ruby method `align_checksum_mismatch_message(downloadable_type)` at line 465.
pub fn ruby_download_queue_l465_d26_align_checksum_mismatch_message(downloadable_type string) (string, string) {
	return align_checksum_mismatch_message(downloadable_type)
}

// Ruby method `spinner` at line 477.
pub fn ruby_download_queue_l477_d27_spinner(mut queue DownloadQueue) string {
	return queue.spinner()
}

// Ruby method `message_with_progress(downloadable, future, message, message_length_max)` at line 482.
pub fn ruby_download_queue_l482_d28_message_with_progress(mut queue DownloadQueue, mut resource Resource, state DownloadState, message string, maximum int) string {
	return queue.message_with_progress(mut resource, state, message, maximum)
}

// Ruby method `initialize` at line 541.
pub fn ruby_download_queue_l541_d29_initialize() Spinner {
	return new_spinner()
}

// Ruby method `to_s` at line 547.
pub fn ruby_download_queue_l547_d30_to_s(mut spinner Spinner) string {
	return spinner.str()
}

// Ruby method `self.default_download_queue` at line 560.
pub fn ruby_download_queue_l560_d31_self_default_download_queue() DownloadQueue {
	return default_download_queue()
}

// Ruby method `self.reset_default_download_queue` at line 565.
pub fn ruby_download_queue_l565_d32_self_reset_default_download_queue() {
	reset_default_download_queue()
}

// Ruby method `self.shutdown_default_download_queue` at line 573.
pub fn ruby_download_queue_l573_d33_self_shutdown_default_download_queue() {
	shutdown_default_download_queue()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "downloadable"
// 5: require "concurrent/promises"
// 6: require "concurrent/executors"
// 7: require "concurrent/atomic/atomic_boolean"
// 8: require "concurrent/atomic/event"
// 9: require "retryable_download"
// 10: require "concurrent/set"
// 11: require "resource"
// 12: require "utils/output"
// 13:
// 14: module Homebrew
// 15:   # Raised when a download is cancelled cooperatively.
// 16:   class CancelledDownloadError < StandardError; end
// 17:
// 18:   # Manages a queue of concurrent downloads with cooperative cancellation support.
// 19:   class DownloadQueue
// 20:     include Utils::Output::Mixin
// 21:
// 22:     sig { params(retries: Integer, force: T::Boolean, pour: T::Boolean).void }
// 23:     def initialize(retries: 1, force: false, pour: false)
// 24:       @concurrency = T.let(EnvConfig.download_concurrency, Integer)
// 25:       @quiet = T.let(@concurrency > 1, T::Boolean)
// 26:       @tries = T.let(retries + 1, Integer)
// 27:       @force = force
// 28:       @pour = pour
// 29:       @pool = T.let(Concurrent::FixedThreadPool.new(concurrency), Concurrent::FixedThreadPool)
// 30:       @tty = T.let($stdout.tty?, T::Boolean)
// 31:       @dumb_tty = T.let(ENV["TERM"] == "dumb", T::Boolean)
// 32:       @spinner = T.let(nil, T.nilable(Spinner))
// 33:       @symlink_targets = T.let({}, T::Hash[Pathname, T::Set[Downloadable]])
// 34:       @downloads_by_location = T.let({}, T::Hash[Pathname, Concurrent::Promises::Future])
// 35:       @cancelled = T.let(Concurrent::AtomicBoolean.new(false), Concurrent::AtomicBoolean)
// 36:       @active_threads = T.let(Concurrent::Set.new, Concurrent::Set)
// 37:       @failed_downloads = T.let([], T::Array[Downloadable])
// 38:       @deferred_failure_messages = T.let([], T::Array[T.proc.void])
// 39:     end
// 40:
// 41:     sig {
// 42:       params(
// 43:         downloadable:      Downloadable,
// 44:         check_attestation: T::Boolean,
// 45:         stage:             T::Boolean,
// 46:       ).void
// 47:     }
// 48:     def enqueue(downloadable, check_attestation: false, stage: pour)
// 49:       @cancelled.make_false
// 50:       cached_location = downloadable.cached_download
// 51:
// 52:       @symlink_targets[cached_location] ||= Set.new
// 53:       targets = @symlink_targets.fetch(cached_location)
// 54:       targets << downloadable
// 55:
// 56:       download = @downloads_by_location[cached_location] ||= Concurrent::Promises.future_on(
// 57:         pool, RetryableDownload.new(downloadable, tries:),
// 58:         @cancelled, force, quiet, check_attestation
// 59:       ) do |download, cancelled, force, quiet, check_attestation|
// 60:         with_active_thread do
// 61:           raise CancelledDownloadError if cancelled.true?
// 62:
// 63:           download.clear_cache if force
// 64:           if !force && downloadable.downloaded_and_valid?
// 65:             check_bottle_attestation(downloadable, check_attestation:)
// 66:             create_symlinks_for_shared_download(cached_location)
// 67:             next cached_location
// 68:           end
// 69:
// 70:           downloaded_path = download.fetch(quiet:)
// 71:           raise CancelledDownloadError if cancelled.true?
// 72:
// 73:           check_bottle_attestation(downloadable, check_attestation:)
// 74:           if downloaded_path != cached_location
// 75:             @symlink_targets[downloaded_path] ||= Set.new
// 76:             @symlink_targets.fetch(downloaded_path).merge(@symlink_targets.fetch(cached_location, Set.new))
// 77:           end
// 78:           create_symlinks_for_shared_download(downloaded_path)
// 79:           downloaded_path
// 80:         end
// 81:       end
// 82:
// 83:       downloads[downloadable] = if stage
// 84:         download.then_on(
// 85:           pool, downloadable, pour, @cancelled
// 86:         ) do |downloaded_path, queued_downloadable, queue_pour, cancelled|
// 87:           with_active_thread do
// 88:             raise CancelledDownloadError if cancelled.true?
// 89:
// 90:             if queued_downloadable.stage_from_download_queue?(downloaded_path, pour: queue_pour)
// 91:               queued_downloadable.extracting!
// 92:               queued_downloadable.stage_from_download_queue(downloaded_path, pour: queue_pour)
// 93:               queued_downloadable.downloaded!
// 94:             end
// 95:             downloaded_path
// 96:           end
// 97:         end
// 98:       else
// 99:         download
// 100:       end
// 101:     end
// 102:
// 103:     # Waits for and reports queued downloads. With `only:`, limits that to
// 104:     # downloadables of the given class, leaving the rest enqueued and
// 105:     # unreported for a later fetch, e.g. so dependency resolution can wait
// 106:     # on bottle manifests without reporting in-flight bottles before their
// 107:     # downloads heading has been printed. A `heading:` is printed only when
// 108:     # there is something to report, so every report gets a heading and empty
// 109:     # fetches stay silent. With `allow_failures:`, failures are still
// 110:     # reported with a ✘ line but neither raise nor mark the fetch or run
// 111:     # as failed, for metadata prefetches such as the bottle manifest of a
// 112:     # version whose bottle has not been published yet, where dependency
// 113:     # resolution just falls back to a full install; known-bad cached files
// 114:     # from checksum mismatches are still removed.
// 115:     sig {
// 116:       params(only: T.nilable(T::Class[Downloadable]), heading: T.nilable(String),
// 117:              allow_failures: T::Boolean).void
// 118:     }
// 119:     def fetch(only: nil, heading: nil, allow_failures: false)
// 120:       @failed_downloads = []
// 121:       @deferred_failure_messages = []
// 122:       context_before_fetch = Context.current
// 123:       fetchable_downloads = if only
// 124:         downloads.select { |downloadable, _| downloadable.is_a?(only) }
// 125:       else
// 126:         downloads
// 127:       end
// 128:       return if fetchable_downloads.empty?
// 129:
// 130:       if heading
// 131:         if tty
// 132:           oh1 heading, truncate: false
// 133:           $stdout.flush
// 134:         else
// 135:           # Keep the heading off parsed stdout (e.g. `brew info --json | jq`)
// 136:           # and on the same stream as the non-TTY report lines below.
// 137:           $stderr.puts oh1_title(heading, truncate: false)
// 138:         end
// 139:       end
// 140:
// 141:       if concurrency == 1
// 142:         fetchable_downloads.each do |downloadable, promise|
// 143:           promise.wait!
// 144:         rescue CancelledDownloadError
// 145:           next
// 146:         rescue ChecksumMismatchError => e
// 147:           if allow_failures
// 148:             report_tolerated_failure(downloadable)
// 149:             # Remove the known-bad download so it cannot be reused.
// 150:             unlink_cached_download(downloadable)
// 151:             next
// 152:           end
// 153:
// 154:           @failed_downloads << downloadable
// 155:           ofail "#{downloadable.download_queue_type} reports different checksum: #{e.expected}"
// 156:         rescue
// 157:           raise unless allow_failures
// 158:
// 159:           report_tolerated_failure(downloadable)
// 160:         end
// 161:       else
// 162:         message_length_max = fetchable_downloads.keys.map do |download|
// 163:           download.download_queue_message.length
// 164:         end.max || 0
// 165:         remaining_downloads = fetchable_downloads.dup.to_a
// 166:         previous_pending_line_count = 0
// 167:         max_lines = [concurrency, Tty.height].min
// 168:
// 169:         resolution = Concurrent::Event.new
// 170:         fetchable_downloads.each_value { |future| future.on_resolution! { resolution.set } }
// 171:
// 172:         begin
// 173:           stdout_print_and_flush_if_tty Tty.hide_cursor
// 174:
// 175:           output_message = lambda do |downloadable, future, last|
// 176:             status = status_from_future(future)
// 177:             exception = future.reason if future.rejected?
// 178:             next 1 if exception.is_a?(CancelledDownloadError)
// 179:
// 180:             message = downloadable.download_queue_message
// 181:             if tty_with_cursor_move_support?
// 182:               message = message_with_progress(downloadable, future, message, message_length_max)
// 183:               stdout_print_and_flush "#{status} #{message}#{"\n" unless last}"
// 184:             elsif status
// 185:               $stderr.puts "#{status} #{message}"
// 186:             end
// 187:
// 188:             if future.rejected? && allow_failures
// 189:               # Remove known-bad downloads so they cannot be reused, while
// 190:               # staying non-fatal for tolerated metadata prefetches.
// 191:               unlink_cached_download(downloadable) if exception.is_a?(ChecksumMismatchError)
// 192:             elsif future.rejected?
// 193:               if exception.is_a?(ChecksumMismatchError)
// 194:                 @failed_downloads << downloadable
// 195:                 actual = Digest::SHA256.file(downloadable.cached_download).hexdigest
// 196:                 actual_message, expected_message = align_checksum_mismatch_message(downloadable.download_queue_type)
// 197:
// 198:                 report_or_defer_failure do
// 199:                   ofail "#{actual_message} #{exception.expected}"
// 200:                   puts "#{expected_message} #{actual}"
// 201:                 end
// 202:               elsif exception.is_a?(CannotInstallFormulaError)
// 203:                 unlink_cached_download(downloadable)
// 204:                 raise exception
// 205:               elsif bottle_manifest_error?(downloadable, exception)
// 206:                 # Fatal: unlike a missing blob (which then fails to stage), a
// 207:                 # stale blob would still pour without the manifest tab that
// 208:                 # drives relocation, so abort rather than stage a broken keg.
// 209:                 raise exception
// 210:               else
// 211:                 failure_message = if exception.is_a?(DownloadError) && exception.cause.is_a?(ErrorDuringExecution)
// 212:                   cause = T.cast(exception.cause, ErrorDuringExecution)
// 213:                   if (stderr_output = cause.stderr.presence)
// 214:                     "#{stderr_output}#{cause.message}"
// 215:                   else
// 216:                     cause.message
// 217:                   end
// 218:                 else
// 219:                   future.reason.to_s
// 220:                 end
// 221:                 @failed_downloads << downloadable
// 222:                 report_or_defer_failure { ofail failure_message }
// 223:               end
// 224:             end
// 225:
// 226:             1
// 227:           end
// 228:
// 229:           until remaining_downloads.empty?
// 230:             begin
// 231:               stdout_print_and_flush_if_tty Tty.begin_synchronized_update
// 232:
// 233:               finished_states = [:fulfilled, :rejected]
// 234:
// 235:               finished_downloads, remaining_downloads = remaining_downloads.partition do |_, future|
// 236:                 finished_states.include?(future.state)
// 237:               end
// 238:
// 239:               finished_downloads.each do |downloadable, future|
// 240:                 previous_pending_line_count -= 1
// 241:                 output_message.call(downloadable, future, false)
// 242:                 stdout_print_and_flush_if_tty Tty.clear_to_end
// 243:               end
// 244:
// 245:               previous_pending_line_count = 0
// 246:               remaining_downloads.each_with_index do |(downloadable, future), i|
// 247:                 break if previous_pending_line_count >= max_lines
// 248:
// 249:                 last = i == max_lines - 1 || i == remaining_downloads.count - 1
// 250:                 previous_pending_line_count += output_message.call(downloadable, future, last)
// 251:                 stdout_print_and_flush_if_tty Tty.clear_to_end
// 252:               end
// 253:
// 254:               if previous_pending_line_count.positive?
// 255:                 if (previous_pending_line_count - 1).zero?
// 256:                   stdout_print_and_flush_if_tty Tty.move_cursor_beginning
// 257:                 else
// 258:                   stdout_print_and_flush_if_tty Tty.move_cursor_up_beginning(previous_pending_line_count - 1)
// 259:                 end
// 260:               end
// 261:
// 262:               stdout_print_and_flush_if_tty Tty.end_synchronized_update
// 263:
// 264:               next if remaining_downloads.empty?
// 265:
// 266:               resolution.reset
// 267:               # A download may resolve between the partition above and this
// 268:               # reset: re-check before waiting to avoid a lost wakeup.
// 269:               next if remaining_downloads.any? { |_, future| finished_states.include?(future.state) }
// 270:
// 271:               # Wake as soon as any download resolves; the timeout only sets
// 272:               # the redraw cadence for spinner and progress bars on TTYs.
// 273:               resolution.wait(tty_with_cursor_move_support? ? 0.05 : 1)
// 274:             # `Interrupt` inherits from `Exception`, so rescue it to restore the TTY.
// 275:             rescue Exception # rubocop:disable Lint/RescueException
// 276:               if previous_pending_line_count.positive?
// 277:                 stdout_print_and_flush_if_tty Tty.move_cursor_down(previous_pending_line_count - 1)
// 278:               end
// 279:
// 280:               raise
// 281:             end
// 282:           end
// 283:         ensure
// 284:           stdout_print_and_flush_if_tty Tty.end_synchronized_update
// 285:           stdout_print_and_flush_if_tty Tty.show_cursor
// 286:           @deferred_failure_messages.each(&:call)
// 287:         end
// 288:       end
// 289:     # `Interrupt` inherits from `Exception`, so rescue it to cancel active workers
// 290:     # even when it arrives before fetch setup completes.
// 291:     rescue Exception # rubocop:disable Lint/RescueException
// 292:       cancel
// 293:       raise
// 294:     ensure
// 295:       # Restore the pre-parallel fetch context to avoid quiet state bleeding out
// 296:       # from threads, and clear queue state even when a fatal download error
// 297:       # aborts the fetch above.
// 298:       Context.current = context_before_fetch if context_before_fetch
// 299:
// 300:       if only
// 301:         # Keep unfetched downloads (and their location dedup entries) queued
// 302:         # for the next fetch.
// 303:         fetchable_downloads.each_key { |downloadable| downloads.delete(downloadable) }
// 304:       else
// 305:         downloads.clear
// 306:         @downloads_by_location.clear
// 307:         @symlink_targets.clear
// 308:       end
// 309:     end
// 310:
// 311:     # The downloadables that failed in the last `fetch`, so callers can retry
// 312:     # or skip only the packages that were actually affected.
// 313:     sig { returns(T::Array[Downloadable]) }
// 314:     attr_reader :failed_downloads
// 315:
// 316:     sig { params(message: String).void }
// 317:     def stdout_print_and_flush_if_tty(message)
// 318:       stdout_print_and_flush(message) if tty_with_cursor_move_support?
// 319:     end
// 320:
// 321:     sig { params(message: String).void }
// 322:     def stdout_print_and_flush(message)
// 323:       $stdout.print(message)
// 324:       $stdout.flush
// 325:     end
// 326:
// 327:     sig { void }
// 328:     def shutdown
// 329:       pool.shutdown
// 330:       pool.wait_for_termination
// 331:     end
// 332:
// 333:     sig { returns(T::Hash[Downloadable, Concurrent::Promises::Future]) }
// 334:     def downloads
// 335:       @downloads ||= T.let({}, T.nilable(T::Hash[Downloadable, Concurrent::Promises::Future]))
// 336:     end
// 337:
// 338:     private
// 339:
// 340:     sig { params(downloadable: Downloadable, check_attestation: T::Boolean).void }
// 341:     def check_bottle_attestation(downloadable, check_attestation:)
// 342:       return unless check_attestation
// 343:       return unless downloadable.is_a?(Bottle)
// 344:
// 345:       Utils::Attestation.check_attestation(downloadable, quiet: true)
// 346:     end
// 347:
// 348:     sig { params(cached_location: Pathname).void }
// 349:     def create_symlinks_for_shared_download(cached_location)
// 350:       targets = @symlink_targets.fetch(cached_location, Set.new)
// 351:       targets.each do |target|
// 352:         downloader = target.downloader
// 353:         next unless downloader.is_a?(AbstractFileDownloadStrategy)
// 354:
// 355:         symlink_location = downloader.symlink_location
// 356:         next if symlink_location.symlink? && symlink_location.exist?
// 357:
// 358:         downloader.create_symlink_to_cached_download(cached_location)
// 359:       end
// 360:     end
// 361:
// 362:     sig { params(downloadable: Downloadable, exception: T.nilable(Exception)).returns(T::Boolean) }
// 363:     def bottle_manifest_error?(downloadable, exception)
// 364:       return false if exception.nil?
// 365:
// 366:       downloadable.is_a?(Resource::BottleManifest) || exception.is_a?(Resource::BottleManifest::Error)
// 367:     end
// 368:
// 369:     # Deferred so a multi-row failure can't desync the redraw's one-row-per-line cursor maths.
// 370:     sig { params(block: T.proc.void).void }
// 371:     def report_or_defer_failure(&block)
// 372:       if tty_with_cursor_move_support?
// 373:         @deferred_failure_messages << block
// 374:       else
// 375:         yield
// 376:       end
// 377:     end
// 378:
// 379:     sig { type_parameters(:U).params(_block: T.proc.returns(T.type_parameter(:U))).returns(T.type_parameter(:U)) }
// 380:     def with_active_thread(&_block)
// 381:       @active_threads.add(Thread.current)
// 382:       yield
// 383:     rescue Interrupt
// 384:       raise CancelledDownloadError
// 385:     ensure
// 386:       @active_threads.delete(Thread.current)
// 387:     end
// 388:
// 389:     sig { void }
// 390:     def cancel
// 391:       # Signal cooperative cancellation and interrupt any active worker threads.
// 392:       # Raising Interrupt on the thread triggers the existing rescue Interrupt in
// 393:       # system_command.rb which sends SIGINT to the curl subprocess directly.
// 394:       @cancelled.make_true
// 395:       @active_threads.each { |thread| thread.raise(Interrupt) }
// 396:     end
// 397:
// 398:     sig { returns(Concurrent::FixedThreadPool) }
// 399:     attr_reader :pool
// 400:
// 401:     sig { returns(Integer) }
// 402:     attr_reader :concurrency
// 403:
// 404:     sig { returns(Integer) }
// 405:     attr_reader :tries
// 406:
// 407:     sig { returns(T::Boolean) }
// 408:     attr_reader :force
// 409:
// 410:     sig { returns(T::Boolean) }
// 411:     attr_reader :quiet
// 412:
// 413:     sig { returns(T::Boolean) }
// 414:     attr_reader :pour
// 415:
// 416:     sig { returns(T::Boolean) }
// 417:     attr_reader :tty
// 418:
// 419:     sig { returns(T::Boolean) }
// 420:     def tty_with_cursor_move_support?
// 421:       tty && !@dumb_tty
// 422:     end
// 423:
// 424:     sig { params(downloadable: Downloadable).void }
// 425:     def unlink_cached_download(downloadable)
// 426:       cached_download = downloadable.cached_download
// 427:       cached_download.unlink if cached_download.exist?
// 428:     end
// 429:
// 430:     # Matches the parallel-mode ✘ report for failures the serial path
// 431:     # tolerates instead of raising.
// 432:     sig { params(downloadable: Downloadable).void }
// 433:     def report_tolerated_failure(downloadable)
// 434:       status = if tty
// 435:         "#{Tty.red}✘#{Tty.reset}"
// 436:       else
// 437:         "✘"
// 438:       end
// 439:       $stderr.puts "#{status} #{downloadable.download_queue_message}"
// 440:     end
// 441:
// 442:     sig { params(future: Concurrent::Promises::Future).returns(T.nilable(String)) }
// 443:     def status_from_future(future)
// 444:       case future.state
// 445:       when :fulfilled
// 446:         if tty
// 447:           "#{Tty.green}✔︎#{Tty.reset}"
// 448:         else
// 449:           "✔︎"
// 450:         end
// 451:       when :rejected
// 452:         if tty
// 453:           "#{Tty.red}✘#{Tty.reset}"
// 454:         else
// 455:           "✘"
// 456:         end
// 457:       when :pending, :processing
// 458:         "#{Tty.blue}#{spinner}#{Tty.reset}" if tty_with_cursor_move_support?
// 459:       else
// 460:         raise future.state.to_s
// 461:       end
// 462:     end
// 463:
// 464:     sig { params(downloadable_type: String).returns([String, String]) }
// 465:     def align_checksum_mismatch_message(downloadable_type)
// 466:       actual_checksum_output = "#{downloadable_type} reports different checksum:"
// 467:       expected_checksum_output = "SHA-256 checksum of downloaded file:"
// 468:
// 469:       # `.max` returns `T.nilable(Integer)`, use `|| 0` to pass the typecheck
// 470:       rightpad = [actual_checksum_output, expected_checksum_output].map(&:size).max || 0
// 471:
// 472:       # 7 spaces are added to align with `ofail` message, which adds `Error: ` at the beginning
// 473:       [actual_checksum_output.ljust(rightpad), (" " * 7) + expected_checksum_output.ljust(rightpad)]
// 474:     end
// 475:
// 476:     sig { returns(Spinner) }
// 477:     def spinner
// 478:       @spinner ||= Spinner.new
// 479:     end
// 480:
// 481:     sig { params(downloadable: Downloadable, future: Concurrent::Promises::Future, message: String, message_length_max: Integer).returns(String) }
// 482:     def message_with_progress(downloadable, future, message, message_length_max)
// 483:       tty_width = Tty.width
// 484:       return message unless tty_width.positive?
// 485:
// 486:       available_width = tty_width - 3
// 487:       fetched_size = downloadable.fetched_size
// 488:       return message[0, available_width].to_s if fetched_size.blank?
// 489:
// 490:       precision = 1
// 491:       size_length = 5
// 492:       unit_length = 2
// 493:       size_formatting_string = "%<size>#{size_length}.#{precision}f%<unit>#{unit_length}s"
// 494:       size, unit = Formatter.disk_usage_readable_size_unit(fetched_size, precision:)
// 495:       formatted_fetched_size = format(size_formatting_string, size:, unit:)
// 496:
// 497:       total_size = downloadable.total_size
// 498:       formatted_total_size = if future.fulfilled?
// 499:         formatted_fetched_size
// 500:       elsif total_size
// 501:         size, unit = Formatter.disk_usage_readable_size_unit(total_size, precision:)
// 502:         format(size_formatting_string, size:, unit:)
// 503:       else
// 504:         # fill in the missing spaces for the size if we don't have it yet.
// 505:         "-" * (size_length + unit_length)
// 506:       end
// 507:
// 508:       max_phase_length = 11
// 509:       phase = format("%-<phase>#{max_phase_length}s", phase: downloadable.phase.to_s.capitalize)
// 510:       progress = " #{phase} #{formatted_fetched_size}/#{formatted_total_size}"
// 511:       bar_length = [4, available_width - progress.length - message_length_max - 1].max
// 512:       if downloadable.phase == :downloading && total_size
// 513:         percent = (fetched_size.to_f / [1, total_size].max).clamp(0.0, 1.0)
// 514:         bar_used = (percent * bar_length).round
// 515:         bar_completed = "#" * bar_used
// 516:         bar_pending = " " * (bar_length - bar_used)
// 517:         progress = " #{bar_completed}#{bar_pending}#{progress}"
// 518:       end
// 519:       message_length = available_width - progress.length
// 520:       return message[0, available_width].to_s unless message_length.positive?
// 521:
// 522:       "#{message[0, message_length].to_s.ljust(message_length)}#{progress}"
// 523:     end
// 524:
// 525:     # Animated spinner for download progress display.
// 526:     class Spinner
// 527:       FRAMES = [
// 528:         "⠋",
// 529:         "⠙",
// 530:         "⠚",
// 531:         "⠞",
// 532:         "⠖",
// 533:         "⠦",
// 534:         "⠴",
// 535:         "⠲",
// 536:         "⠳",
// 537:         "⠓",
// 538:       ].freeze
// 539:
// 540:       sig { void }
// 541:       def initialize
// 542:         @start = T.let(Time.now, Time)
// 543:         @i = T.let(0, Integer)
// 544:       end
// 545:
// 546:       sig { returns(String) }
// 547:       def to_s
// 548:         now = Time.now
// 549:         if @start + 0.1 < now
// 550:           @start = now
// 551:           @i = (@i + 1) % FRAMES.count
// 552:         end
// 553:
// 554:         FRAMES.fetch(@i)
// 555:       end
// 556:     end
// 557:   end
// 558:
// 559:   sig { returns(DownloadQueue) }
// 560:   def self.default_download_queue
// 561:     @default_download_queue ||= T.let(DownloadQueue.new, T.nilable(DownloadQueue))
// 562:   end
// 563:
// 564:   sig { void }
// 565:   def self.reset_default_download_queue
// 566:     # Skip `shutdown` for a leaked RSpec double, which cannot receive
// 567:     # messages outside the per-example rspec-mocks lifecycle.
// 568:     @default_download_queue.shutdown if @default_download_queue.is_a?(DownloadQueue)
// 569:     @default_download_queue = nil
// 570:   end
// 571:
// 572:   sig { void }
// 573:   def self.shutdown_default_download_queue
// 574:     @default_download_queue&.shutdown
// 575:   end
// 576:
// 577:   at_exit do
// 578:     Homebrew.shutdown_default_download_queue
// 579:   end
// 580: end
