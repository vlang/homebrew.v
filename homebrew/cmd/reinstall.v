module cmd

import ruby

// Translated from Homebrew/brew `cmd/reinstall.rb`.
pub enum ReinstallCommandItemKind {
	formula
	cask
	unavailable
}

pub struct ReinstallCommandItem {
pub:
	kind         ReinstallCommandItemKind
	name         string
	pinned       bool
	bottled      bool
	fail_message ?string
}

pub struct ReinstallCommandOptions {
pub:
	no_ask             bool
	build_from_source  bool
	devtools_installed bool = true
	developer          bool = true
	force              bool
	force_bottle       bool
	binaries           bool
	require_sha        bool
	skip_cask_deps     bool
	zap                bool
	display_times      bool
}

pub struct ReinstallCommandResult {
pub:
	events               []string
	formulae_reinstalled []string
	casks_reinstalled    []string
	errors               []string
	failed               bool
	queue_created        bool
	queue_shutdown       bool
	casks_prefetched     bool
}

pub fn run_reinstall_command(items []ReinstallCommandItem,
	options ReinstallCommandOptions) !ReinstallCommandResult {
	if items.len == 0 {
		return error('at least one formula or cask is required')
	}
	mut events := ['trust_fully_qualified_items']
	mut formulae := []ReinstallCommandItem{}
	mut casks := []ReinstallCommandItem{}
	mut unavailable := []string{}
	for item in items {
		match item.kind {
			.formula { formulae << item }
			.cask { casks << item }
			.unavailable { unavailable << item.name }
		}
	}
	if options.build_from_source && !options.devtools_installed {
		return error('BuildFlagsError: --build-from-source requires development tools')
	}
	if options.build_from_source && !options.developer {
		events << 'warning: building from source is not supported'
	}
	mut errors := []string{}
	mut eligible_casks := []ReinstallCommandItem{}
	for cask in casks {
		if cask.pinned {
			errors << '${cask.name} is pinned. You must unpin it to reinstall.'
		} else {
			eligible_casks << cask
		}
	}
	ask := !options.no_ask
	if ask && eligible_casks.len > 0 {
		events << 'ask_casks'
	}
	mut eligible_formulae := []ReinstallCommandItem{}
	if formulae.len > 0 {
		events << 'perform_preinstall_checks_once'
		for formula in formulae {
			if formula.pinned {
				errors << '${formula.name} is pinned. You must unpin it to reinstall.'
				continue
			}
			events << 'build_install_context:${formula.name}'
			eligible_formulae << formula
		}
	}
	mut queue_created := false
	mut queue_shutdown := false
	if !ask && eligible_formulae.len > 0 {
		queue_created = true
		events << 'download_queue_new'
		for formula in eligible_formulae {
			events << 'prelude_fetch:${formula.name}'
		}
	}
	if eligible_formulae.len > 0 {
		events << 'dependants'
		if ask {
			events << 'ask_formulae'
		}
	}
	mut casks_prefetched := false
	if eligible_formulae.len > 0 && eligible_casks.len > 0 {
		if !queue_created {
			queue_created = true
			events << 'download_queue_new'
		}
		events << 'enqueue_formulae'
		events << 'enqueue_cask_installers'
		events << 'combined_fetch'
		casks_prefetched = true
		queue_shutdown = true
		events << 'download_queue_shutdown'
	} else if eligible_formulae.len > 0 {
		if queue_created {
			events << 'fetch_formulae_shared_queue'
			queue_shutdown = true
			events << 'download_queue_shutdown'
		} else {
			events << 'fetch_formulae'
		}
	}
	mut reinstalled_formulae := []string{}
	for formula in eligible_formulae {
		if failure := formula.fail_message {
			errors << '${formula.name}: ${failure}'
			continue
		}
		events << 'reinstall_formula:${formula.name}'
		events << 'cleanup_formula:${formula.name}'
		reinstalled_formulae << formula.name
	}
	if eligible_formulae.len > 0 {
		events << 'upgrade_dependents'
	}
	mut reinstalled_casks := []string{}
	if eligible_casks.len > 0 {
		events << 'reinstall_casks:skip_prefetch=${casks_prefetched}'
		reinstalled_casks = eligible_casks.map(it.name)
	}
	for message in unavailable {
		errors << message
	}
	events << 'periodic_clean'
	events << 'display_messages:${options.display_times}'
	return ReinstallCommandResult{
		events: events
		formulae_reinstalled: reinstalled_formulae
		casks_reinstalled: reinstalled_casks
		errors: errors
		failed: errors.len > 0
		queue_created: queue_created
		queue_shutdown: queue_shutdown
		casks_prefetched: casks_prefetched
	}
}

pub fn reinstall_command_item_to_value(item ReinstallCommandItem) ruby.Value {
	mut attributes := {
		'kind':    item.kind.str()
		'name':    item.name
		'pinned':  item.pinned.str()
		'bottled': item.bottled.str()
	}
	if failure := item.fail_message {
		attributes['fail_message'] = failure
	}
	return ruby.structured_value('ReinstallItem', item.name, attributes)
}

fn reinstall_command_item_from_value(value ruby.Value) ReinstallCommandItem {
	failure := if message := value.attributes['fail_message'] { ?string(message) } else { none }
	return ReinstallCommandItem{
		kind: match value.attributes['kind'] or { 'formula' } {
			'cask' { ReinstallCommandItemKind.cask }
			'unavailable' { ReinstallCommandItemKind.unavailable }
			else { ReinstallCommandItemKind.formula }
		}
		name: value.attributes['name'] or { value.as_string() }
		pinned: (value.attributes['pinned'] or { 'false' }) == 'true'
		bottled: (value.attributes['bottled'] or { 'false' }) == 'true'
		fail_message: failure
	}
}

pub fn reinstall_command_result_to_value(result ReinstallCommandResult) ruby.Value {
	return ruby.map_value({
		'events':               ruby.string_array_value(result.events)
		'formulae_reinstalled': ruby.string_array_value(result.formulae_reinstalled)
		'casks_reinstalled':    ruby.string_array_value(result.casks_reinstalled)
		'errors':               ruby.string_array_value(result.errors)
		'failed':               ruby.bool_value(result.failed)
		'queue_created':        ruby.bool_value(result.queue_created)
		'queue_shutdown':       ruby.bool_value(result.queue_shutdown)
		'casks_prefetched':     ruby.bool_value(result.casks_prefetched)
	})
}
