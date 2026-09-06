module cask

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
