module cask

import ruby

// Translated from Homebrew/brew `cask/reinstall.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ReinstallCask {
pub:
	full_name    string
	installed    bool
	fail_message ?string
}

pub struct ReinstallCaskOptions {
pub:
	verbose             bool
	force               bool
	skip_cask_deps      bool
	binaries            bool
	require_sha         bool
	zap                 bool
	skip_prefetch       bool
	download_queue_name ?string
	global_failed       bool
}

pub struct ReinstallCaskResult {
pub:
	installed              []string
	failures               map[string]string
	prefetched             []string
	output                 []string
	created_download_queue bool
	queue_name             string
	queue_shutdown         bool
}

pub fn reinstall_casks(casks []ReinstallCask, options ReinstallCaskOptions) ReinstallCaskResult {
	mut created_queue := false
	queue_name := if supplied := options.download_queue_name {
		supplied
	} else if options.skip_prefetch {
		'default'
	} else {
		created_queue = true
		'reinstall'
	}
	mut prefetched := []string{}
	if !options.skip_prefetch {
		prefetched = casks.map(it.full_name)
	}
	mut installed := []string{}
	mut failures := map[string]string{}
	mut output := []string{}
	for cask in casks {
		if options.zap {
			output << 'Dispatching zap stanza for ${cask.full_name}'
		} else if cask.installed {
			output << 'Uninstalling Cask ${cask.full_name}'
		}
		output << 'Installing Cask ${cask.full_name}'
		if failure := cask.fail_message {
			failures[cask.full_name] = failure
			output << '${cask.full_name}: ${failure}'
			continue
		}
		installed << cask.full_name
		output << '${cask.full_name} was successfully installed!'
	}
	return ReinstallCaskResult{
		installed: installed
		failures: failures
		prefetched: prefetched
		output: output
		created_download_queue: created_queue
		queue_name: queue_name
		queue_shutdown: created_queue
	}
}

pub fn reinstall_cask_to_value(cask ReinstallCask) ruby.Value {
	mut attributes := {
		'full_name': cask.full_name
		'installed': cask.installed.str()
	}
	if failure := cask.fail_message {
		attributes['fail_message'] = failure
	}
	return ruby.structured_value('Cask', cask.full_name, attributes)
}

fn reinstall_cask_from_value(value ruby.Value) ReinstallCask {
	failure := if message := value.attributes['fail_message'] { ?string(message) } else { none }
	return ReinstallCask{
		full_name: value.attributes['full_name'] or { value.as_string() }
		installed: (value.attributes['installed'] or { 'false' }) == 'true'
		fail_message: failure
	}
}

pub fn reinstall_cask_result_to_value(result ReinstallCaskResult) ruby.Value {
	mut failures := map[string]ruby.Value{}
	for name, message in result.failures {
		failures[name] = ruby.string_value(message)
	}
	return ruby.map_value({
		'installed':              ruby.string_array_value(result.installed)
		'failures':               ruby.map_value(failures)
		'prefetched':             ruby.string_array_value(result.prefetched)
		'output':                 ruby.string_array_value(result.output)
		'created_download_queue': ruby.bool_value(result.created_download_queue)
		'queue_name':             ruby.string_value(result.queue_name)
		'queue_shutdown':         ruby.bool_value(result.queue_shutdown)
	})
}

// Ruby method `self.reinstall_casks(` at line 18.
pub fn ruby_reinstall_l18_d1_self_reinstall_casks(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reinstall_cask_result_to_value(reinstall_casks([]ReinstallCask{}, ReinstallCaskOptions{}))
	}
	values := args[0].as_map() or { return ruby.object_value('ArgumentError', err.msg()) }
	cask_values := if value := values['casks'] {
		value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	mut queue := ?string(none)
	if value := values['download_queue'] {
		if value.type_name != 'NilClass' {
			queue = value.as_string()
		}
	}
	options := ReinstallCaskOptions{
		verbose: if value := values['verbose'] { value.as_bool() or { false } } else { false }
		force: if value := values['force'] { value.as_bool() or { false } } else { false }
		skip_cask_deps: if value := values['skip_cask_deps'] {
			value.as_bool() or { false }} else {
			false}
		binaries: if value := values['binaries'] { value.as_bool() or { false } } else { false }
		require_sha: if value := values['require_sha'] {
			value.as_bool() or { false }} else {
			false}
		zap: if value := values['zap'] { value.as_bool() or { false } } else { false }
		skip_prefetch: if value := values['skip_prefetch'] {
			value.as_bool() or { false }} else {
			false}
		download_queue_name: queue
		global_failed: if value := values['global_failed'] {
			value.as_bool() or { false }} else {
			false}
	}
	return reinstall_cask_result_to_value(reinstall_casks(cask_values.map(reinstall_cask_from_value(it)), options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5: require "install"
// 6:
// 7: module Cask
// 8:   class Reinstall
// 9:     extend ::Utils::Output::Mixin
// 10:
// 11:     sig {
// 12:       params(
// 13:         casks: ::Cask::Cask, verbose: T::Boolean, force: T::Boolean, skip_cask_deps: T::Boolean, binaries: T::Boolean,
// 14:         require_sha: T::Boolean, zap: T::Boolean, skip_prefetch: T::Boolean,
// 15:         download_queue: T.nilable(Homebrew::DownloadQueue)
// 16:       ).void
// 17:     }
// 18:     def self.reinstall_casks(
// 19:       *casks,
// 20:       verbose: false,
// 21:       force: false,
// 22:       skip_cask_deps: false,
// 23:       binaries: false,
// 24:       require_sha: false,
// 25:       zap: false,
// 26:       skip_prefetch: false,
// 27:       download_queue: nil
// 28:     )
// 29:       require "cask/installer"
// 30:
// 31:       created_download_queue = T.let(false, T::Boolean)
// 32:       if download_queue.nil?
// 33:         if skip_prefetch
// 34:           download_queue = Homebrew.default_download_queue
// 35:         else
// 36:           download_queue = Homebrew::DownloadQueue.new(pour: true)
// 37:           created_download_queue = true
// 38:         end
// 39:       end
// 40:
// 41:       cask_installers = T.let([], T::Array[Installer])
// 42:       begin
// 43:         cask_installers = casks.map do |cask|
// 44:           Installer.new(
// 45:             cask,
// 46:             binaries:,
// 47:             verbose:,
// 48:             force:,
// 49:             skip_cask_deps:,
// 50:             require_sha:,
// 51:             reinstall:      true,
// 52:             zap:,
// 53:             download_queue:,
// 54:             defer_fetch:    true,
// 55:           )
// 56:         end
// 57:
// 58:         unless skip_prefetch
// 59:           Homebrew::Install.enqueue_cask_installers(cask_installers, download_queue:)
// 60:           download_queue.fetch(
// 61:             heading: Homebrew::Install.combined_fetch_downloads_heading(cask_names: casks.map(&:full_name)),
// 62:           )
// 63:         end
// 64:       ensure
// 65:         download_queue.shutdown if created_download_queue
// 66:       end
// 67:
// 68:       # Reinstall everything that did download and report each failure as it
// 69:       # happens, rather than aborting the whole run; the failures still exit
// 70:       # nonzero at the end.
// 71:       cask_installers.each do |installer|
// 72:         installer.install
// 73:       rescue => e
// 74:         ofail "#{installer.cask.full_name}: #{e}"
// 75:         next
// 76:       end
// 77:     end
// 78:   end
// 79: end
