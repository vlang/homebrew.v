module cask

import ruby

// Translated from Homebrew/brew `cask/reinstall.rb`.
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
