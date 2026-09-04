module homebrew

import ruby

// Translated from Homebrew/brew `metafiles.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `list?(file)` at line 19.
pub fn ruby_metafiles_l19_d1_list(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Metafiles.list? requires a file')
	}
	return ruby.bool_value(is_metafile_listed(args[0].as_string()))
}

// Ruby method `copy?(file)` at line 26.
pub fn ruby_metafiles_l26_d2_copy(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Metafiles.copy? requires a file')
	}
	return ruby.bool_value(is_metafile_copied(args[0].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper for checking if a file is considered a metadata file.
// 5: module Metafiles
// 6:   LICENSES = T.let(Set.new(%w[copying copyright license licence]).freeze, T::Set[String])
// 7:   # {https://github.com/github/markup#markups}
// 8:   EXTENSIONS = T.let(Set.new(%w[
// 9:     .adoc .asc .asciidoc .creole .html .markdown .md .mdown .mediawiki .mkdn
// 10:     .org .pod .rdoc .rst .rtf .textile .txt .wiki
// 11:   ]).freeze, T::Set[String])
// 12:   BASENAMES = T.let(Set.new(%w[
// 13:     about authors changelog changes history news notes notice readme todo
// 14:   ]).freeze, T::Set[String])
// 15:
// 16:   module_function
// 17:
// 18:   sig { params(file: String).returns(T::Boolean) }
// 19:   def list?(file)
// 20:     return false if %w[.DS_Store INSTALL_RECEIPT.json].include?(file)
// 21:
// 22:     !copy?(file)
// 23:   end
// 24:
// 25:   sig { params(file: String).returns(T::Boolean) }
// 26:   def copy?(file)
// 27:     file = file.downcase
// 28:     license = file.split(/\.|-/).first
// 29:     return false unless license
// 30:     return true if LICENSES.include?(license)
// 31:
// 32:     ext  = File.extname(file)
// 33:     file = File.basename(file, ext) if EXTENSIONS.include?(ext)
// 34:     BASENAMES.include?(file)
// 35:   end
// 36: end
