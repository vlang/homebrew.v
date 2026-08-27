module cask

import brew_runtime

// Translated from Homebrew/brew `test/api/cask/cask_struct_generator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:depends_on_non_macos) do` at line 8.
pub fn ruby_cask_struct_generator_spec_l8_d1_depends_on_non_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_non_macos', ...args)
}

// Ruby let `let(:depends_on_linux) { { linux: LinuxRequirement.new } }` at line 14.
pub fn ruby_cask_struct_generator_spec_l14_d2_depends_on_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_linux', ...args)
}

// Ruby let `let(:depends_on_macos_equals) { { macos: { :== => ["15"] } } }` at line 15.
pub fn ruby_cask_struct_generator_spec_l15_d3_depends_on_macos_equals(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_macos_equals', ...args)
}

// Ruby let `let(:depends_on_macos_greater) { { macos: MacOSRequirement.new([:sequoia], comparator: ">=") } }` at line 16.
pub fn ruby_cask_struct_generator_spec_l16_d4_depends_on_macos_greater(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_macos_greater', ...args)
}

// Ruby let `let(:depends_on_macos_bare) { { macos: MacOSRequirement.new([]) } }` at line 17.
pub fn ruby_cask_struct_generator_spec_l17_d5_depends_on_macos_bare(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_macos_bare', ...args)
}

// Ruby let `let(:depends_on_maximum_macos) { { maximum_macos: MacOSRequirement.new([:sequoia], comparator: "<=") } }` at line 18.
pub fn ruby_cask_struct_generator_spec_l18_d6_depends_on_maximum_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_maximum_macos', ...args)
}

// Ruby specify `specify :aggregate_failures do` at line 20.
pub fn ruby_cask_struct_generator_spec_l20_d7_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby specify `specify "::process_artifacts" do` at line 45.
pub fn ruby_cask_struct_generator_spec_l45_d8_process_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_artifacts', ...args)
}

// Ruby specify `specify "::process_url_specs" do` at line 77.
pub fn ruby_cask_struct_generator_spec_l77_d9_process_url_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::process_url_specs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::Cask::CaskStructGenerator do
// 7:   describe ":process_depends_on" do
// 8:     let(:depends_on_non_macos) do
// 9:       {
// 10:         arch:    [{ type: :intel, bits: 64 }],
// 11:         formula: ["foo"],
// 12:       }
// 13:     end
// 14:     let(:depends_on_linux) { { linux: LinuxRequirement.new } }
// 15:     let(:depends_on_macos_equals) { { macos: { :== => ["15"] } } }
// 16:     let(:depends_on_macos_greater) { { macos: MacOSRequirement.new([:sequoia], comparator: ">=") } }
// 17:     let(:depends_on_macos_bare) { { macos: MacOSRequirement.new([]) } }
// 18:     let(:depends_on_maximum_macos) { { maximum_macos: MacOSRequirement.new([:sequoia], comparator: "<=") } }
// 19:
// 20:     specify :aggregate_failures do
// 21:       expect(
// 22:         described_class.process_depends_on(depends_on_non_macos),
// 23:       ).to eq({ arch: :intel, formula: ["foo"] })
// 24:       expect(
// 25:         described_class.process_depends_on(depends_on_linux),
// 26:       ).to eq({ linux: :any })
// 27:       expect(
// 28:         described_class.process_depends_on(depends_on_macos_equals),
// 29:       ).to eq({ macos: [:sequoia] })
// 30:       expect(
// 31:         described_class.process_depends_on(depends_on_macos_greater),
// 32:       ).to eq({ macos: :sequoia })
// 33:       expect(
// 34:         described_class.process_depends_on(depends_on_macos_bare),
// 35:       ).to eq({ macos: :any })
// 36:       expect(
// 37:         described_class.process_depends_on({ macos: {} }),
// 38:       ).to eq({ macos: :any })
// 39:       expect(
// 40:         described_class.process_depends_on(depends_on_maximum_macos),
// 41:       ).to eq({ maximum_macos: :sequoia })
// 42:     end
// 43:   end
// 44:
// 45:   specify "::process_artifacts" do
// 46:     input = [
// 47:       { preflight: nil },
// 48:       { foo:       ["arg1", "arg2"] },
// 49:       { bar:       ["arg1", "arg2", { kwarg1: "value1" }] },
// 50:       { baz:       [{ kwarg1: "value1" }] },
// 51:       {
// 52:         target:         "$HOMEBREW_PREFIX/share/zsh/site-functions/_foo",
// 53:         zsh_completion: ["$APPDIR/Foo.app/Contents/Resources/completions/zsh/_foo"],
// 54:       },
// 55:       {
// 56:         zsh_completion: ["$APPDIR/Bar.app/Contents/Resources/completions/zsh/_bar"],
// 57:         target:         "$HOMEBREW_PREFIX/share/zsh/site-functions/_bar",
// 58:       },
// 59:       {
// 60:         target: "/Applications/Bar.app",
// 61:         app:    ["Foo.app", { target: "Bar.app" }],
// 62:       },
// 63:     ]
// 64:     expected_output = [
// 65:       [:preflight, [], {}, Homebrew::API::CaskStruct::EMPTY_BLOCK],
// 66:       [:foo, ["arg1", "arg2"], {}, nil],
// 67:       [:bar, ["arg1", "arg2"], { kwarg1: "value1" }, nil],
// 68:       [:baz, [], { kwarg1: "value1" }, nil],
// 69:       [:zsh_completion, ["$APPDIR/Foo.app/Contents/Resources/completions/zsh/_foo"], {}, nil],
// 70:       [:zsh_completion, ["$APPDIR/Bar.app/Contents/Resources/completions/zsh/_bar"], {}, nil],
// 71:       [:app, ["Foo.app"], { target: "Bar.app" }, nil],
// 72:     ]
// 73:     output = described_class.process_artifacts(input)
// 74:     expect(output).to eq expected_output
// 75:   end
// 76:
// 77:   specify "::process_url_specs" do
// 78:     input = {
// 79:       user_agent: ":fake",
// 80:       using:      "curl",
// 81:       foo:        nil,
// 82:       bar:        "baz",
// 83:     }
// 84:     expected_output = {
// 85:       user_agent: :fake,
// 86:       using:      :curl,
// 87:       bar:        "baz",
// 88:     }
// 89:     output = described_class.process_url_specs(input)
// 90:     expect(output).to eq expected_output
// 91:   end
// 92: end
