module homebrew

import brew_runtime

// Translated from Homebrew/brew `metafiles.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `list?(file)` at line 19.
pub fn ruby_metafiles_l19_d1_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list?', ...args)
}

// Ruby method `copy?(file)` at line 26.
pub fn ruby_metafiles_l26_d2_copy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('copy?', ...args)
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
