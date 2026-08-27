module bundle

// Translated from Homebrew/brew `bundle/extensions.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: extensions_dir = File.join(__dir__, "extensions")
// 7: # Preserve the historical Brewfile section order for dumped extension entries;
// 8: # add new extensions to the end.
// 9: legacy_order = %w[mac_app_store vscode_extension go cargo uv flatpak winget].freeze
// 10: extension_files = Dir.glob(File.join(extensions_dir, "*.rb")).sort_by do |file|
// 11:   basename = File.basename(file, ".rb")
// 12:   [legacy_order.index(basename) || legacy_order.length, basename]
// 13: end
// 14: extension_files.each do |file|
// 15:   basename = File.basename(file, ".rb")
// 16:   next if basename == "extension"
// 17:
// 18:   require "bundle/extensions/#{basename}"
// 19: end
