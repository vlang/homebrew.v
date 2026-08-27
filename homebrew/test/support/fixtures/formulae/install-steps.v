module formulae

// Translated from Homebrew/brew `test/support/fixtures/formulae/install-steps.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class InstallSteps < Formula
// 5:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 6:
// 7:   desc "Formula with structured install steps"
// 8:   homepage "https://brew.sh/install-steps"
// 9:   url "https://brew.sh/install-steps-1.0"
// 10:
// 11:   post_install_steps do
// 12:     mkdir_p "log/install-steps"
// 13:     touch "install-steps/state"
// 14:     move "move-source", "move-target"
// 15:     move_contents "move-children-source", "move-children-target"
// 16:     symlink "move-target", "linked-target", source_base: :relative, overwrite: true, remove_on_uninstall: true
// 17:     init_data_dir "lib/install-steps", using: :postgresql
// 18:   end
// 19: end
