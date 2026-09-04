module homebrew

// Translated from Homebrew/brew `metafiles.rb`.

const metafile_licenses = ['copying', 'copyright', 'license', 'licence']
const metafile_extensions = ['.adoc', '.asc', '.asciidoc', '.creole', '.html', '.markdown', '.md',
	'.mdown', '.mediawiki', '.mkdn', '.org', '.pod', '.rdoc', '.rst', '.rtf', '.textile', '.txt',
	'.wiki']
const metafile_basenames = ['about', 'authors', 'changelog', 'changes', 'history', 'news', 'notes',
	'notice', 'readme', 'todo']

// is_metafile_listed translates Metafiles.list?.
pub fn is_metafile_listed(file string) bool {
	if file == '.DS_Store' || file == 'INSTALL_RECEIPT.json' {
		return false
	}
	return !is_metafile_copied(file)
}

// is_metafile_copied translates Metafiles.copy?.
pub fn is_metafile_copied(input string) bool {
	mut file := input.to_lower()
	mut separator := file.len
	for candidate in [file.index('.') or { file.len }, file.index('-') or { file.len }] {
		if candidate < separator {
			separator = candidate
		}
	}
	license := file[..separator]
	if license in metafile_licenses {
		return true
	}
	last_dot := file.last_index('.') or { -1 }
	if last_dot >= 0 {
		extension := file[last_dot..]
		if extension in metafile_extensions {
			file = file[..last_dot]
		}
	}
	return file in metafile_basenames
}
