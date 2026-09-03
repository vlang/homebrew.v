module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/release_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn release_spec_base_options() ReleaseOptions {
	return ReleaseOptions{
		latest_release: ReleaseRecord{
			tag_name: '1.2.3'
		}
		release_notes: 'Release notes'
	}
}

// Ruby it `it "requires an up-to-date origin/main before triggering the release workflow" do` at line 11.
pub fn ruby_release_spec_l11_d1_requires(args ...brew_runtime.Value) brew_runtime.Value {
	options := ReleaseOptions{
		...release_spec_base_options()
		force: true
		current_sha: 'local-sha'
		upstream_sha: 'upstream-sha'
	}
	run_release(options) or {
		return brew_runtime.bool_value(err.msg().contains('Run `brew update` before `brew release --force`.'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "refuses to release when open release blockers exist" do` at line 36.
pub fn ruby_release_spec_l36_d2_refuses(args ...brew_runtime.Value) brew_runtime.Value {
	options := ReleaseOptions{
		...release_spec_base_options()
		issues: {
			'release blocker': [ReleaseRecord{
				html_url: 'https://github.com/Homebrew/brew/issues/12345'
			}]
		}
	}
	run_release(options) or {
		return brew_runtime.bool_value(err.msg().contains('issues/12345'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "refuses to release when open major/minor release blockers exist for a major release" do` at line 49.
pub fn ruby_release_spec_l49_d3_refuses(args ...brew_runtime.Value) brew_runtime.Value {
	options := ReleaseOptions{
		...release_spec_base_options()
		major: true
		issues: {
			'release blocker':             []ReleaseRecord{}
			'major/minor release blocker': [ReleaseRecord{
				html_url: 'https://github.com/Homebrew/brew/pull/54321'
			}]
		}
	}
	run_release(options) or {
		return brew_runtime.bool_value(err.msg().contains('pull/54321'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:command) { described_class.new([]) }` at line 67.
pub fn ruby_release_spec_l67_d4_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Homebrew::DevCmd::Release', 'brew release')
}

// Ruby let `let(:releases) do` at line 68.
pub fn ruby_release_spec_l68_d5_releases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(release_spec_releases().map(release_record_value(it)))
}

pub fn release_spec_releases() []ReleaseRecord {
	return [
		ReleaseRecord{
			id: 1
			name: '1.2.3'
			created_at: '2025-01-01T00:00:00Z'
			html_url: 'https://github.com/Homebrew/brew/releases/tag/1.2.3'
		},
		ReleaseRecord{
			id: 2
			name: '1.2.3'
			created_at: '2025-01-02T00:00:00Z'
			html_url: 'https://github.com/Homebrew/brew/releases/tag/1.2.3-2'
		},
		ReleaseRecord{
			id: 3
			name: '1.2.2'
			created_at: '2024-12-31T00:00:00Z'
			html_url: 'https://github.com/Homebrew/brew/releases/tag/1.2.2'
		},
		ReleaseRecord{
			id: 4
			tag_name: '1.2.3'
			created_at: '2025-01-03T00:00:00Z'
			html_url: 'https://github.com/Homebrew/brew/releases/tag/1.2.3-3'
		},
	]
}

// Ruby it `it "filters releases by name or tag name" do` at line 102.
pub fn ruby_release_spec_l102_d6_filters(args ...brew_runtime.Value) brew_runtime.Value {
	ids := matching_releases('1.2.3', release_spec_releases()).map(it.id)
	return brew_runtime.bool_value(ids == [i64(1), 2, 4])
}

// Ruby it `it "selects the latest matching release by creation time" do` at line 107.
pub fn ruby_release_spec_l107_d7_selects(args ...brew_runtime.Value) brew_runtime.Value {
	latest := latest_matching_release('1.2.3', release_spec_releases()) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(latest.id == 4)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/release"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Release do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "#run" do
// 11:     it "requires an up-to-date origin/main before triggering the release workflow" do
// 12:       command = described_class.new(["--force"])
// 13:
// 14:       allow(Homebrew::EnvConfig).to receive(:no_auto_update?).and_return(false)
// 15:       allow(GitHub).to receive_messages(
// 16:         issues:                 [],
// 17:         get_latest_release:     { "tag_name" => "1.2.3" },
// 18:         generate_release_notes: { "body" => "Release notes" },
// 19:       )
// 20:       allow(Utils).to receive(:safe_popen_read).with(
// 21:         "git", "-C", HOMEBREW_REPOSITORY, "rev-parse", "origin/main"
// 22:       ).and_return("local-sha\n")
// 23:       allow(GitHub::API).to receive(:open_rest).with(
// 24:         "#{GitHub::API_URL}/repos/Homebrew/brew/releases?per_page=#{GitHub::MAX_PER_PAGE}",
// 25:         request_method: :GET,
// 26:         scopes:         GitHub::CREATE_ISSUE_FORK_OR_PR_SCOPES,
// 27:       ).and_return([])
// 28:       expect(GitHub::API).to receive(:commit).with("Homebrew", "brew").and_return({ "sha" => "upstream-sha" })
// 29:       expect(GitHub).not_to receive(:workflow_dispatch_event)
// 30:
// 31:       expect { command.run }
// 32:         .to raise_error(SystemExit)
// 33:         .and output(/Run `brew update` before `brew release --force`\./).to_stderr
// 34:     end
// 35:
// 36:     it "refuses to release when open release blockers exist" do
// 37:       command = described_class.new([])
// 38:
// 39:       allow(Homebrew::EnvConfig).to receive(:no_auto_update?).and_return(false)
// 40:       allow(GitHub).to receive(:issues)
// 41:         .with(repo: "Homebrew/brew", state: "open", labels: "release blocker")
// 42:         .and_return([{ "html_url" => "https://github.com/Homebrew/brew/issues/12345" }])
// 43:
// 44:       expect { command.run }
// 45:         .to raise_error(SystemExit)
// 46:         .and output(%r{issues/12345}).to_stderr
// 47:     end
// 48:
// 49:     it "refuses to release when open major/minor release blockers exist for a major release" do
// 50:       command = described_class.new(["--major"])
// 51:
// 52:       allow(Homebrew::EnvConfig).to receive(:no_auto_update?).and_return(false)
// 53:       allow(GitHub).to receive(:issues)
// 54:         .with(repo: "Homebrew/brew", state: "open", labels: "release blocker")
// 55:         .and_return([])
// 56:       allow(GitHub).to receive(:issues)
// 57:         .with(repo: "Homebrew/brew", state: "open", labels: "major/minor release blocker")
// 58:         .and_return([{ "html_url" => "https://github.com/Homebrew/brew/pull/54321" }])
// 59:
// 60:       expect { command.run }
// 61:         .to raise_error(SystemExit)
// 62:         .and output(%r{pull/54321}).to_stderr
// 63:     end
// 64:   end
// 65:
// 66:   describe "release lookup helpers" do
// 67:     let(:command) { described_class.new([]) }
// 68:     let(:releases) do
// 69:       [
// 70:         {
// 71:           "id"         => 1,
// 72:           "name"       => "1.2.3",
// 73:           "created_at" => "2025-01-01T00:00:00Z",
// 74:           "html_url"   => "https://github.com/Homebrew/brew/releases/tag/1.2.3",
// 75:         },
// 76:         {
// 77:           "id"         => 2,
// 78:           "name"       => "1.2.3",
// 79:           "created_at" => "2025-01-02T00:00:00Z",
// 80:           "html_url"   => "https://github.com/Homebrew/brew/releases/tag/1.2.3-2",
// 81:         },
// 82:         {
// 83:           "id"         => 3,
// 84:           "name"       => "1.2.2",
// 85:           "created_at" => "2024-12-31T00:00:00Z",
// 86:           "html_url"   => "https://github.com/Homebrew/brew/releases/tag/1.2.2",
// 87:         },
// 88:         {
// 89:           "id"         => 4,
// 90:           "name"       => nil,
// 91:           "tag_name"   => "1.2.3",
// 92:           "created_at" => "2025-01-03T00:00:00Z",
// 93:           "html_url"   => "https://github.com/Homebrew/brew/releases/tag/1.2.3-3",
// 94:         },
// 95:       ]
// 96:     end
// 97:
// 98:     before do
// 99:       allow(GitHub::API).to receive(:open_rest).and_return(releases)
// 100:     end
// 101:
// 102:     it "filters releases by name or tag name" do
// 103:       matching = command.matching_releases("1.2.3")
// 104:       expect(matching.map { |release| release["id"] }).to eq([1, 2, 4])
// 105:     end
// 106:
// 107:     it "selects the latest matching release by creation time" do
// 108:       latest = command.latest_matching_release("1.2.3")
// 109:       expect(latest["id"]).to eq(4)
// 110:     end
// 111:   end
// 112: end
