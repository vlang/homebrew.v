module homebrew

import ruby
import time

// Translated from Homebrew/brew `download_queue.rb`.
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
	configured := ruby.environment_value('HOMEBREW_DOWNLOAD_CONCURRENCY').int()
	concurrency := if configured > 0 { configured } else { 1 }
	return DownloadQueue{
		concurrency: concurrency
		quiet: concurrency > 1
		tries: retries + 1
		force: force
		pour: pour
		tty: ruby.stdout_is_terminal()
		dumb_tty: ruby.environment_value('TERM') == 'dumb'
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
