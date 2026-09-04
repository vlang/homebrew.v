module artifact

import os

// Translated from Homebrew/brew `cask/artifact/manpage.rb`.
pub struct ManpageArtifact {
pub:
	cask_token  string
	staged_path string
	manpagedir  string
	source      string
	source_name string
	section     string
	symlinked   SymlinkedArtifact
}

fn manpage_section(source string) ?string {
	name := if source.ends_with('.gz') { source[..source.len - 3] } else { source }
	section := name.all_after_last('.')
	if section in ['1', '2', '3', '4', '5', '6', '7', '8', 'n', 'l'] {
		return section
	}
	return none
}

pub fn resolve_manpage_target(manpagedir string, section string, target string) string {
	return os.join_path(manpagedir, 'man${section}', target)
}

pub fn new_manpage_artifact(cask_token string, staged_path string, manpagedir string,
	source string, section string) ManpageArtifact {
	source_path := if os.is_abs_path(source) { source } else { os.join_path(staged_path, source) }
	source_name := os.file_name(source)
	target := resolve_manpage_target(manpagedir, section, source_name)
	return ManpageArtifact{
		cask_token: cask_token
		staged_path: staged_path
		manpagedir: manpagedir
		source: source_path
		source_name: source_name
		section: section
		symlinked: SymlinkedArtifact{
			source: source_path
			target: target
			english_name: 'Manpage'
			printable_target: target
		}
	}
}

pub fn manpage_from_args(cask_token string, staged_path string, manpagedir string,
	source string) !ManpageArtifact {
	section := manpage_section(source) or {
		return error("'${source}' is not a valid man page name")
	}
	return new_manpage_artifact(cask_token, staged_path, manpagedir, source, section)
}

pub fn install_manpage(artifact ManpageArtifact) !SymlinkedOperationResult {
	result := install_symlinked_artifact(artifact.symlinked, SymlinkedInstallOptions{})
	if !result.success {
		return error(result.error)
	}
	return result
}
