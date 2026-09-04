module homebrew

import ruby
import os
import x.json2

#include <sys/file.h>

fn C.flock(fd int, operation int) int

// Translated from Homebrew/brew `trust.rb`.
pub enum TrustType {
	tap
	formula
	cask
	command
}

pub struct TrustTap {
pub:
	name               string
	remote             string
	path               string
	official           bool
	implicitly_trusted bool
	installed          bool
	formula_names      []string
	cask_names         []string
	command_names      []string
}

pub struct TrustConfig {
pub:
	current_home      string
	user_config_home  string
	tap_directory     string
	running_as_root   bool
	sudo_user         string
	sudo_homes        map[string]string
	require_tap_trust bool = true
	no_require_trust  bool
	argv              []string
	taps              []TrustTap
}

pub struct TrustTarget {
pub:
	target_type TrustType
	name        string
}

pub struct Trust {
pub:
	config TrustConfig
pub mut:
	warnings []string
	info     []string
}

struct TrustStoreLock {
mut:
	file os.File
}

fn (mut store_guard TrustStoreLock) release() bool {
	if C.flock(store_guard.file.fd, 8) != 0 {
		return false
	}
	store_guard.file.close()
	return true
}

pub fn new_trust(config TrustConfig) Trust {
	return Trust{ config: config }
}

fn trust_type_name(target_type TrustType) string {
	return match target_type {
		.tap { 'tap' }
		.formula { 'formula' }
		.cask { 'cask' }
		.command { 'command' }
	}
}

pub fn trust_setting_key(target_type TrustType) string {
	return match target_type {
		.tap { 'trustedtaps' }
		.formula { 'trustedformulae' }
		.cask { 'trustedcasks' }
		.command { 'trustedcommands' }
	}
}

pub fn trust_normalise_name(name string) string {
	return name.to_lower()
}

pub fn trust_file(config TrustConfig, home string) string {
	if os.norm_path(config.user_config_home) == os.join_path(os.norm_path(config.current_home), '.homebrew') {
		return os.join_path(home, '.homebrew', 'trust.json')
	}
	return os.join_path(config.user_config_home, 'trust.json')
}

fn trust_remote_reference(reference string) bool {
	if reference.starts_with('/') || reference.starts_with('.') || reference.starts_with('~') || reference.contains('://') {
		return true
	}
	colon := reference.index(':') or { return false }
	slash := reference.index('/') or { reference.len }
	return colon < slash && colon + 1 < reference.len
}

fn trust_strip_known_remote_suffix(remote string) string {
	mut result := remote.trim_right('/')
	if result.ends_with('.git') {
		result = result[..result.len - 4]
	}
	return result
}

fn trust_remote_host_and_path(remote string) (string, string, bool) {
	if scheme := remote.index('://') {
		remainder := remote[scheme + 3..]
		slash := remainder.index('/') or { return remainder.all_after_last('@'), '', true }
		authority := remainder[..slash]
		return authority.all_after_last('@').all_before(':'), remainder[slash + 1..], true
	}
	mut separator := remote.index('/') or { remote.len }
	if colon := remote.index(':') {
		if colon < separator {
			separator = colon
		}
	}
	authority := remote[..separator]
	path := if separator < remote.len { remote[separator + 1..] } else { '' }
	return authority.all_after_last('@'), path, false
}

pub fn trust_normalize_remote(value string) string {
	mut remote := value.trim_space().to_lower()
	if remote == '' {
		return ''
	}
	host, path, has_scheme := trust_remote_host_and_path(remote)
	if host == 'github.com' {
		// With a scheme, a colon after the host introduces a port and is not the
		// SCP separator accepted by the source's GitHub prefix expression.
		scheme_authority := if has_scheme { remote.all_after('://').all_before('/') } else { '' }
		if !has_scheme || !scheme_authority.contains(':') {
			remote = 'https://github.com/${path}'
		}
	}
	normalized_host, _, _ := trust_remote_host_and_path(remote)
	if normalized_host in ['github.com', 'gitlab.com'] {
		return trust_strip_known_remote_suffix(remote)
	}
	return remote
}

pub fn trust_same_remote(first string, second string) bool {
	first_normalized := trust_normalize_remote(first)
	return first_normalized != '' && first_normalized == trust_normalize_remote(second)
}

fn trust_tap_parts(name string) !(string, string) {
	parts := name.split('/')
	if parts.len != 2 || parts[0] == '' || parts[1] == '' || parts[0] in ['.', '..'] || parts[1] in [
		'.',
		'..',
	] || parts[0].contains('@') || parts[1].contains('@') {
		return error("Invalid tap name: '${name}'")
	}
	return parts[0], parts[1].trim_string_left('homebrew-')
}

fn trust_tap_name(name string) !string {
	user, repository := trust_tap_parts(name)!
	return '${user}/${repository}'.to_lower()
}

fn trust_default_remote(name string) !string {
	user, repository := trust_tap_parts(name)!
	return 'https://github.com/${user}/homebrew-${repository}'
}

pub fn trust_remote_to_reference(remote string) ?string {
	normalized := trust_normalize_remote(remote)
	if normalized == '' {
		return none
	}
	prefix := 'https://github.com/'
	if normalized.starts_with(prefix) {
		parts := normalized[prefix.len..].split('/')
		if parts.len == 2 && parts[1].starts_with('homebrew-') {
			name := '${parts[0]}/${parts[1]['homebrew-'.len..]}'
			if default_remote := trust_default_remote(name) {
				if trust_same_remote(normalized, default_remote) {
					return name.to_lower()
				}
			}
		}
	}
	return normalized
}

fn (trust &Trust) tap(name string) !TrustTap {
	canonical := trust_tap_name(name)!
	for tap in trust.config.taps {
		if tap.name.to_lower() == canonical {
			return TrustTap{
				...tap
				name: canonical
			}
		}
	}
	return TrustTap{
		name: canonical
		path: os.join_path(trust.config.tap_directory, canonical.split('/')[0], 'homebrew-${canonical.split('/')[1]}')
	}
}

fn trust_tap_reference(tap TrustTap, declared_remote string) !string {
	remote := if declared_remote.trim_space() != '' { declared_remote } else { tap.remote }
	if remote == '' || trust_same_remote(remote, trust_default_remote(tap.name)!) {
		return tap.name
	}
	return remote
}

fn trust_tap_matches_reference(tap TrustTap, reference string) bool {
	if trust_remote_reference(reference) {
		return trust_same_remote(reference, tap.remote)
	}
	default_remote := trust_default_remote(tap.name) or { return false }
	uses_custom := tap.remote != '' && !trust_same_remote(tap.remote, default_remote)
	return !uses_custom && tap.name == reference.to_lower()
}

fn trust_uses_custom_remote(tap TrustTap) bool {
	default_remote := trust_default_remote(tap.name) or { return false }
	return tap.remote != '' && !trust_same_remote(tap.remote, default_remote)
}

fn trust_full_package(name string, noun string) !(TrustTap, string) {
	parts := name.split('/')
	if parts.len != 3 || parts.any(it == '') || parts[0] in ['.', '..'] || parts[1] in [
		'.',
		'..',
	] {
		return error('${noun} must be fully-qualified as <user>/<tap>/<name>.')
	}
	return TrustTap{ name: trust_tap_name('${parts[0]}/${parts[1]}')! }, parts[2].to_lower()
}

fn (trust &Trust) resolved_full_package(name string, noun string) !(TrustTap, string) {
	base, item := trust_full_package(name, noun)!
	return trust.tap(base.name)!, item
}

pub fn (mut trust Trust) item_trust_name(target_type TrustType, tap TrustTap, item_name string,
	include_existing bool, tap_remote string) !string {
	item := trust_normalise_name(item_name)
	full_name := '${tap.name}/${item}'
	if include_existing && trust.trusted_entries(target_type)!.contains(full_name.to_lower()) {
		return full_name
	}
	reference := trust_tap_reference(tap, tap_remote)!
	if reference == tap.name {
		return full_name
	}
	return '${trust_normalise_name(reference)}/${item}'
}

pub fn (mut trust Trust) trust_name(target_type TrustType, name string, include_existing bool,
	tap_remote string) !string {
	return match target_type {
		.tap {
			if trust_remote_reference(name) {
				trust_remote_to_reference(name) or { return error('Invalid tap remote URL: ${name}') }
			} else {
				tap := trust.tap(name) or { return error(err.msg()) }
				trust_tap_reference(tap, tap_remote)!
			}
		}
		.formula {
			tap, item := trust.resolved_full_package(name, 'Formulae')!
			trust.item_trust_name(target_type, tap, item, include_existing, tap_remote)!
		}
		.cask {
			tap, item := trust.resolved_full_package(name, 'Casks')!
			trust.item_trust_name(target_type, tap, item, include_existing, tap_remote)!
		}
		.command {
			tap, item := trust.resolved_full_package(name, 'Commands')!
			trust.item_trust_name(target_type, tap, item, include_existing, tap_remote)!
		}
	}
}

pub fn (mut trust Trust) target(name string, target_type ?TrustType, include_existing bool,
	tap_remote string) !TrustTarget {
	if explicit_type := target_type {
		return TrustTarget{
			target_type: explicit_type
			name: trust.trust_name(explicit_type, name, include_existing, tap_remote)!
		}
	}
	if name.count('/') == 1 || trust_remote_reference(name) {
		return TrustTarget{
			target_type: .tap
			name: trust.trust_name(.tap, name, false, '')!
		}
	}
	parts := name.split('/')
	if parts.len != 3 || parts[0] in ['.', '..'] || parts[1] in ['.', '..'] {
		return error('Trust targets must be fully-qualified tap, formula, cask or command names.')
	}
	tap := trust.tap('${parts[0]}/${parts[1]}')!
	token := parts[2].to_lower()
	mut candidates := []TrustType{}
	if token in tap.formula_names {
		candidates << .formula
	}
	if token in tap.cask_names {
		candidates << .cask
	}
	if token in tap.command_names {
		candidates << .command
	}
	if include_existing {
		full_name := '${tap.name}/${token}'
		for candidate in [TrustType.formula, .cask, .command] {
			if trust.trusted(candidate, full_name)! && candidate !in candidates {
				candidates << candidate
			}
		}
	}
	if candidates.len == 0 {
		return error('No formula, cask or command found for ${name}.')
	}
	if candidates.len > 1 {
		return error('Ambiguous trust target ${name}. Use `--formula`, `--cask` or `--command`.')
	}
	return TrustTarget{
		target_type: candidates[0]
		name: trust.item_trust_name(candidates[0], tap, token, include_existing, '')!
	}
}

fn trust_store_json(store map[string][]string) string {
	mut root := map[string]json2.Any{}
	for key, entries in store {
		root[key] = json2.Any(entries.map(json2.Any(it)))
	}
	return '${json2.encode(json2.Any(root), prettify: true)}\n'
}

fn trust_parse_store(contents string) !map[string][]string {
	decoded := json2.decode[json2.Any](contents)!
	if decoded !is map[string]json2.Any {
		return map[string][]string{}
	}
	mut store := map[string][]string{}
	for key, raw_entries in decoded.as_map() {
		mut entries := []string{}
		if raw_entries is []json2.Any {
			for entry in raw_entries {
				entries << trust_normalise_name(entry.str())
			}
		} else {
			entries << trust_normalise_name(raw_entries.str())
		}
		store[key] = entries
	}
	return store
}

fn (mut trust Trust) trust_store() !map[string][]string {
	mut read_path := trust_file(trust.config, trust.config.current_home)
	if trust.config.running_as_root && trust.config.sudo_user != '' && trust.config.sudo_user != 'root' {
		if sudo_home := trust.config.sudo_homes[trust.config.sudo_user] {
			read_path = trust_file(trust.config, sudo_home)
		} else {
			trust.warnings << 'Could not determine home directory for `\$HOMEBREW_SUDO_USER` (${trust.config.sudo_user}); falling back to ${read_path}.'
		}
	}
	if !os.exists(read_path) {
		return map[string][]string{}
	}
	contents := os.read_file(read_path) or { return map[string][]string{} }
	return trust_parse_store(contents) or { map[string][]string{} }
}

fn assert_secure_trust_store_path(path string, description string) ! {
	stat := os.stat(path)!
	if int(stat.uid) != os.geteuid() {
		return error('Refusing to write insecure trust store: ${description} ${path} is not owned by the current user.')
	}
	if stat.get_mode().bitmask() & 0o022 != 0 {
		return error('Refusing to write insecure trust store: ${description} ${path} is group or world writable.')
	}
}

fn ensure_secure_trust_store_directory(path string, description string) ! {
	existed := os.exists(path)
	os.mkdir_all(path)!
	if !existed {
		os.chmod(path, 0o700)!
	}
	assert_secure_trust_store_path(path, description)!
}

fn (trust &Trust) write_trust_store(store map[string][]string) ! {
	mut write_path := trust_file(trust.config, trust.config.current_home)
	if os.is_link(write_path) {
		link_parent := os.real_path(os.dir(write_path))
		assert_secure_trust_store_path(link_parent, 'symlink directory')!
		link_stat := os.lstat(write_path)!
		if int(link_stat.uid) != os.geteuid() {
			return error('Refusing to write insecure trust store: symlink ${write_path} is not owned by the current user.')
		}
		mut target_path := os.readlink(write_path)!
		if !target_path.starts_with('/') {
			target_path = os.join_path(os.dir(write_path), target_path)
		}
		target_parent := os.real_path(os.dir(target_path))
		if !os.exists(target_parent) {
			return error('Refusing to write insecure trust store: target directory does not exist.')
		}
		assert_secure_trust_store_path(target_parent, 'target directory')!
		write_path = os.join_path(target_parent, os.base(target_path))
		if os.is_link(write_path) {
			return error('Refusing to write insecure trust store: target is a symlink.')
		}
		if os.exists(write_path) {
			assert_secure_trust_store_path(write_path, 'target')!
			if !os.is_file(write_path) {
				return error('Refusing to write insecure trust store: target is not a regular file.')
			}
		}
	} else {
		ensure_secure_trust_store_directory(os.dir(write_path), 'trust store directory')!
		if os.exists(write_path) {
			assert_secure_trust_store_path(write_path, 'trust store')!
			if !os.is_file(write_path) {
				return error('Refusing to write insecure trust store: trust store is not a regular file.')
			}
		}
	}
	if store.len == 0 {
		if os.exists(write_path) {
			os.rm(write_path)!
		}
		return
	}
	ruby.atomic_write_file(write_path, trust_store_json(store))!
	os.chmod(write_path, 0o600)!
}

fn (trust &Trust) acquire_lock() !TrustStoreLock {
	lock_path := '${trust_file(trust.config, trust.config.current_home)}.lock'
	ensure_secure_trust_store_directory(os.dir(lock_path), 'trust store directory')!
	mut lock_file := os.open_file(lock_path, 'r+', 0o600) or {
		os.open_file(lock_path, 'w+', 0o600)!
	}
	os.chmod(lock_path, 0o600)!
	if C.flock(lock_file.fd, 2) != 0 {
		lock_file.close()
		return error('cannot lock ${lock_path}')
	}
	return TrustStoreLock{
		file: lock_file
	}
}

pub fn (mut trust Trust) trusted_entries(target_type TrustType) ![]string {
	store := trust.trust_store()!
	return store[trust_setting_key(target_type)] or { []string{} }
}

pub fn (mut trust Trust) trust_item(target_type TrustType, name string) !bool {
	key := trust_setting_key(target_type)
	normalized := trust_normalise_name(name)
	mut store_guard := trust.acquire_lock()!
	defer {
		store_guard.release()
	}
	mut store := trust.trust_store()!
	mut entries := store[key] or { []string{} }
	if normalized in entries {
		return false
	}
	entries << normalized
	entries.sort()
	store[key] = entries
	trust.write_trust_store(store)!
	return true
}

pub fn (mut trust Trust) trust_tap_object(target_type TrustType, tap TrustTap) !bool {
	if target_type != .tap {
		return error('a ${trust_type_name(target_type)} trust name must be a String, not a Tap')
	}
	return trust.trust_item(.tap, trust_tap_reference(tap, '')!)
}

pub fn (mut trust Trust) untrust(target_type TrustType, name string) !bool {
	key := trust_setting_key(target_type)
	normalized := trust_normalise_name(name)
	mut entries_to_delete := [normalized]
	if target_type != .tap && name.split('/').len == 3 {
		if tap, item := trust.resolved_full_package(name, 'Items') {
			if trust_uses_custom_remote(tap) {
				entries_to_delete << trust.item_trust_name(target_type, tap, item, false, '')!
			}
		}
	}
	mut store_guard := trust.acquire_lock()!
	defer {
		store_guard.release()
	}
	mut store := trust.trust_store()!
	mut entries := store[key] or { []string{} }
	mut removed := false
	for entry in entries_to_delete {
		for index := entries.len - 1; index >= 0; index-- {
			if entries[index] == entry {
				entries.delete(index)
				removed = true
			}
		}
	}
	if !removed {
		return false
	}
	if entries.len == 0 {
		store.delete(key)
	} else {
		entries.sort()
		store[key] = entries
	}
	trust.write_trust_store(store)!
	return true
}

pub fn (mut trust Trust) invalidate_tap_references(name string, remote string) !bool {
	normalized_name := trust_normalise_name(name)
	mut references := [normalized_name]
	if remote.trim_space() != '' {
		references << trust_normalise_name(remote)
		if reference := trust_remote_to_reference(remote) {
			references << trust_normalise_name(reference)
		}
	}
	mut store_guard := trust.acquire_lock()!
	defer {
		store_guard.release()
	}
	mut store := trust.trust_store()!
	mut changed := false
	for key in store.keys() {
		entries := store[key]
		mut filtered := entries.filter(it !in references && !it.starts_with('${normalized_name}/'))
		if filtered != entries {
			changed = true
			if filtered.len == 0 {
				store.delete(key)
			} else {
				filtered.sort()
				store[key] = filtered
			}
		}
	}
	if changed {
		trust.write_trust_store(store)!
	}
	return changed
}

pub fn (mut trust Trust) clear(target_type TrustType) ! {
	mut store_guard := trust.acquire_lock()!
	defer {
		store_guard.release()
	}
	mut store := trust.trust_store()!
	store.delete(trust_setting_key(target_type))
	trust.write_trust_store(store)!
}

pub fn (mut trust Trust) replace(entries []TrustTarget) ! {
	mut store := map[string][]string{}
	for entry in entries {
		key := trust_setting_key(entry.target_type)
		store[key] << trust_normalise_name(entry.name)
	}
	for key in store.keys() {
		mut sorted := store[key].clone()
		sorted.sort()
		mut unique := []string{}
		for item in sorted {
			if unique.len == 0 || unique.last() != item {
				unique << item
			}
		}
		store[key] = unique
	}
	mut store_guard := trust.acquire_lock()!
	defer {
		store_guard.release()
	}
	trust.write_trust_store(store)!
}

pub fn (mut trust Trust) explicitly_trusted_tap(tap TrustTap) !bool {
	for reference in trust.trusted_entries(.tap)! {
		if trust_tap_matches_reference(tap, reference) {
			return true
		}
	}
	return false
}

pub fn (mut trust Trust) trusted_tap(tap TrustTap) !bool {
	return tap.official || tap.implicitly_trusted || trust.explicitly_trusted_tap(tap)!
}

pub fn (mut trust Trust) trusted(target_type TrustType, name string) !bool {
	normalized := trust_normalise_name(name)
	entries := trust.trusted_entries(target_type)!
	if normalized in entries {
		return true
	}
	if target_type == .tap {
		if trust_remote_reference(normalized) {
			return false
		}
		tap := trust.tap(normalized) or { return false }
		return trust.explicitly_trusted_tap(tap)!
	}
	parts := normalized.split('/')
	if parts.len != 3 {
		return false
	}
	tap := trust.tap('${parts[0]}/${parts[1]}') or { return false }
	if trust.trusted_tap(tap)! {
		return true
	}
	item := parts[2]
	if trust.item_trust_name(target_type, tap, item, false, '')! in entries {
		return true
	}
	if !trust_uses_custom_remote(tap) {
		return false
	}
	for entry in entries {
		suffix := '/${item}'
		if entry.ends_with(suffix) && trust_same_remote(entry[..entry.len - suffix.len], tap.remote) {
			return true
		}
	}
	return false
}

pub fn (mut trust Trust) trust_fully_qualified_items(names []string, requested_type ?TrustType) ! {
	for name in names {
		parts := name.split('/')
		if parts.len != 3 {
			continue
		}
		tap := trust.tap('${parts[0]}/${parts[1]}') or { continue }
		if tap.official {
			continue
		}
		item := parts[2].to_lower()
		mut types := []TrustType{}
		if selected := requested_type {
			if selected == .formula && item in tap.formula_names {
				types << .formula
			} else if selected == .cask && item in tap.cask_names {
				types << .cask
			}
		} else if item in tap.formula_names {
			types << .formula
		} else if item in tap.cask_names {
			types << .cask
		}
		for item_type in types {
			trust_name := trust.item_trust_name(item_type, tap, item, false, '')!
			if trust.trust_item(item_type, trust_name)! {
				trust.info << 'Trusted ${trust_type_name(item_type)} ${tap.name}/${item}'
			}
		}
	}
}

fn (trust &Trust) tap_from_path(path string) ?TrustTap {
	abs_path := os.abs_path(path)
	tap_root := os.abs_path(trust.config.tap_directory)
	if !abs_path.starts_with('${tap_root}/') {
		return none
	}
	parts := abs_path[tap_root.len + 1..].split('/')
	if parts.len < 2 || !parts[1].starts_with('homebrew-') {
		return none
	}
	return trust.tap('${parts[0]}/${parts[1]['homebrew-'.len..]}') or { none }
}

fn trust_path_item_name(path string, target_type TrustType) string {
	mut name := os.file_name(path).all_before_last('.')
	if target_type == .command {
		name = name.trim_string_left('brew-')
	}
	return name
}

pub fn (trust &Trust) explicitly_allowed(target_type TrustType, full_name string,
	tap TrustTap) bool {
	if target_type == .command {
		return false
	}
	args := trust.config.argv.map(it.to_lower())
	name := full_name.to_lower()
	tap_name := tap.name.to_lower()
	if name in args || tap_name in args || '--tap=${tap_name}' in args {
		return true
	}
	if args.len > 1 {
		for index in 0 .. args.len - 1 {
			if args[index] == '--tap' && args[index + 1] == tap_name {
				return true
			}
		}
	}
	return false
}

pub fn (mut trust Trust) trusted_file(target_type TrustType, path string) !bool {
	if trust.config.no_require_trust {
		return true
	}
	tap := trust.tap_from_path(path) or { return true }
	if trust.trusted_tap(tap)! {
		return true
	}
	full_name := '${tap.name}/${trust_path_item_name(path, target_type)}'
	if trust.trusted(target_type, full_name)! || trust.explicitly_allowed(target_type, full_name, tap) {
		return true
	}
	return !trust.config.require_tap_trust
}

pub fn (mut trust Trust) trusted_formula_file(path string) !bool {
	return trust.trusted_file(.formula, path)
}

pub fn (mut trust Trust) trusted_cask_file(path string) !bool {
	return trust.trusted_file(.cask, path)
}

fn (mut trust Trust) trusted_entry_prefix(target_type TrustType, tap TrustTap) !bool {
	mut prefixes := [trust_normalise_name(trust_tap_reference(tap, '')!)]
	if trust_uses_custom_remote(tap) {
		prefixes << tap.name
	}
	for entry in trust.trusted_entries(target_type)! {
		for prefix in prefixes {
			if entry.starts_with('${prefix}/') {
				return true
			}
		}
	}
	return false
}

fn (mut trust Trust) partially_trusted_tap(tap TrustTap) !bool {
	return trust.trusted_entry_prefix(.formula, tap)! || trust.trusted_entry_prefix(.cask, tap)! || trust.trusted_entry_prefix(.command, tap)!
}

pub fn (mut trust Trust) trusted_files(target_type TrustType, files []string) ![]string {
	mut accepted := []string{}
	for file in files {
		if trust.trusted_file(target_type, file)! {
			accepted << file
		}
	}
	if !trust.config.require_tap_trust {
		return accepted
	}
	mut skipped_names := []string{}
	for file in files {
		if file in accepted {
			continue
		}
		if tap := trust.tap_from_path(file) {
			if tap.name !in skipped_names {
				skipped_names << tap.name
			}
		}
	}
	skipped_names.sort()
	for name in skipped_names {
		tap := trust.tap(name)!
		if !trust.partially_trusted_tap(tap)! {
			trust.warnings << 'Skipping ${tap.name} because it is not trusted. Run `brew trust ${tap.name}` to trust it.'
		}
	}
	return accepted
}

pub fn (mut trust Trust) trusted_formula_files(files []string) ![]string {
	return trust.trusted_files(.formula, files)
}

pub fn (mut trust Trust) trusted_cask_files(files []string) ![]string {
	return trust.trusted_files(.cask, files)
}

pub fn (mut trust Trust) trusted_command_files(files []string) ![]string {
	return trust.trusted_files(.command, files)
}

pub fn (mut trust Trust) untrusted_taps() ![]TrustTap {
	mut result := []TrustTap{}
	for tap in trust.config.taps {
		if tap.installed && !tap.official && !trust.trusted_tap(tap)! {
			result << tap
		}
	}
	result.sort(a.name < b.name)
	return result
}

pub fn (mut trust Trust) wholly_untrusted_taps() ![]TrustTap {
	mut result := []TrustTap{}
	for tap in trust.untrusted_taps()! {
		if !trust.partially_trusted_tap(tap)! {
			result << tap
		}
	}
	return result
}

fn (mut trust Trust) require_trusted(target_type TrustType, item_name string, path string,
	command string) ! {
	if trust.config.no_require_trust {
		return
	}
	tap := trust.tap_from_path(path) or { return }
	if trust.trusted_tap(tap)! {
		return
	}
	name := if target_type == .command && command != '' {
		command
	} else if target_type == .command {
		trust_path_item_name(path, target_type)
	} else {
		item_name.split('/').last()
	}
	full_name := '${tap.name}/${name}'
	if trust.trusted(target_type, full_name)! {
		return
	}
	if target_type != .command && trust.explicitly_allowed(target_type, full_name, tap) {
		return
	}
	if !trust.config.require_tap_trust {
		return
	}
	return error('Refusing to load ${trust_type_name(target_type)} ${full_name} from untrusted tap ${tap.name}.\nRun `brew trust --${trust_type_name(target_type)} ${full_name}` or `brew trust ${tap.name}` to trust it.')
}

pub fn (mut trust Trust) require_trusted_formula(name string, path string) ! {
	trust.require_trusted(.formula, name, path, '')!
}

pub fn (mut trust Trust) require_trusted_cask(token string, path string) ! {
	trust.require_trusted(.cask, token, path, '')!
}

pub fn (mut trust Trust) require_trusted_command(path string, command string) ! {
	trust.require_trusted(.command, '', path, command)!
}
