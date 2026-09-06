module cask

import homebrew.utils

// Translated from Homebrew/brew `cask/list.rb`.

pub struct CaskListArtifact {
pub:
	class_name           string
	english_name         string
	display              string
	summary              string
	summarizes_installed bool
}

pub struct CaskListCask {
pub:
	token             string
	full_name         string
	installed         bool = true
	installed_version ?string
	artifacts         []CaskListArtifact
}

pub struct CaskListOptions {
pub:
	one           bool
	full_name     bool
	versions      bool
	console_width int = 80
	stream_is_tty bool
}

pub struct CaskListRequest {
pub:
	casks          []CaskListCask
	caskroom_casks []CaskListCask
	options        CaskListOptions
}

fn cask_list_tap_and_name_compare(left &string, right &string) int {
	left_has_tap := left.contains('/')
	right_has_tap := right.contains('/')
	if left_has_tap && !right_has_tap {
		return 1
	}
	if !left_has_tap && right_has_tap {
		return -1
	}
	return left.compare(right)
}

pub fn cask_list_sort_tap_and_name(values []string) []string {
	mut sorted := values.clone()
	sorted.sort_with_compare(cask_list_tap_and_name_compare)
	return sorted
}

pub fn cask_list_format_versioned(cask CaskListCask) string {
	if version := cask.installed_version {
		return '${cask.token} ${version}'
	}
	return cask.token
}

pub fn cask_list_artifacts(cask CaskListCask) string {
	mut grouped := map[string][]CaskListArtifact{}
	mut english_names := map[string]string{}
	for artifact in cask.artifacts {
		if artifact.class_name in ['Uninstall', 'Zap', 'Cask::Artifact::Uninstall',
			'Cask::Artifact::Zap'] {
			continue
		}
		grouped[artifact.class_name] << artifact
		english_names[artifact.class_name] = artifact.english_name
	}
	mut classes := grouped.keys()
	classes.sort_with_compare(fn [english_names] (left &string, right &string) int {
		return (english_names[*left] or { *left }).compare(english_names[*right] or { *right })
	})
	mut output := ''
	for class_name in classes {
		output += '${utils.output_ohai_title(english_names[class_name] or { class_name }, utils.OutputOptions{})}\n'
		for artifact in grouped[class_name] {
			output += if artifact.summarizes_installed {
				'${artifact.summary}\n'
			} else {
				'${artifact.display}\n'
			}
		}
	}
	return output
}

pub fn cask_list_casks(request CaskListRequest) !string {
	explicit := request.casks.len > 0
	output := if explicit { request.casks } else { request.caskroom_casks }
	if explicit {
		for cask in output {
			if !cask.installed {
				return error('CaskNotInstalledError: ${cask.token}')
			}
		}
	}
	if output.len == 0 {
		return ''
	}
	if request.options.one {
		return '${output.map(it.token).join('\n')}\n'
	}
	if request.options.full_name {
		return '${cask_list_sort_tap_and_name(output.map(it.full_name)).join('\n')}\n'
	}
	if request.options.versions {
		return '${output.map(cask_list_format_versioned(it)).join('\n')}\n'
	}
	if explicit {
		return output.map(cask_list_artifacts(it)).join('')
	}
	return utils.formatter_columns(output.map(it.token), request.options.console_width, request.options.stream_is_tty, 2, 0)
}
