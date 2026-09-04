module tap

import os

// Translated from Homebrew/brew `tap/core_cask_tap.rb`.
pub struct CoreCaskTapState {
pub:
	user       string
	repository string
	name       string
}

pub fn new_core_cask_tap_state() CoreCaskTapState {
	return CoreCaskTapState{ user: 'Homebrew', repository: 'cask', name: 'homebrew/cask' }
}

pub fn core_cask_tap_new_subdirectory(token string) string {
	if token == '' {
		return ''
	}
	if token.starts_with('font-') {
		remainder := token['font-'.len..]
		return if remainder == '' { 'font/font-' } else { 'font/font-${remainder[..1]}' }
	}
	return token[..1]
}

pub fn core_cask_tap_new_path(cask_dir string, token string) string {
	return os.join_path(cask_dir, core_cask_tap_new_subdirectory(token), '${token.to_lower()}.rb')
}

pub fn core_cask_tap_files_by_name(cask_dir string, tokens []string) map[string]string {
	mut files := map[string]string{}
	for token in tokens {
		new_path := core_cask_tap_new_path(cask_dir, token)
		existing := files[token] or { '' }
		if existing == '' || existing.len < new_path.len {
			files[token] = new_path
		}
	}
	return files
}

pub fn core_cask_tap_files(no_install_from_api bool, local_files []string, cask_dir string,
	api_tokens []string) []string {
	if no_install_from_api {
		return local_files
	}
	by_name := core_cask_tap_files_by_name(cask_dir, api_tokens)
	return api_tokens.map(by_name[it])
}
