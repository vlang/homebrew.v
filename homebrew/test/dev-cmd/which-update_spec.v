module dev_cmd

import os
import time

// Translated from Homebrew/brew `test/dev-cmd/which-update_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn which_update_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-which-update-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

pub fn which_update_spec_requires_pull_request() bool {
	run_which_update(WhichUpdateOptions{
		source: 'executables.txt'
		repository: 'Homebrew/homebrew-core'
	}) or {
		return err.msg() == '`--repository` requires `--pull-request`.'
	}
	return false
}

pub fn which_update_spec_rejects_repository_path() !bool {
	root := which_update_spec_root('repository')
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	database := os.join_path(root, 'executables.txt')
	run_which_update(WhichUpdateOptions{
		source: database
		pull_request: '123'
		repository: 'Homebrew/homebrew-core/extra'
	}) or {
		return err.msg() == '`--repository` must be in the form `owner/repo`.'
	}
	return false
}

fn which_update_spec_pull_request_files() [][]WhichUpdatePullFile {
	return [
		[
			WhichUpdatePullFile{
				filename: 'Formula/new-formula.rb'
				status: 'added'
			},
			WhichUpdatePullFile{
				filename: 'Formula/old-formula.rb'
				status: 'removed'
			},
		],
		[
			WhichUpdatePullFile{
				filename: 'Formula/renamed-new.rb'
				previous_filename: 'Formula/renamed-old.rb'
				status: 'renamed'
			},
			WhichUpdatePullFile{
				filename: '.github/workflows/tests.yml'
				status: 'modified'
			},
		],
	]
}

pub fn which_update_spec_removes_pull_request_formulae() !bool {
	root := which_update_spec_root('pull-request')
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	database := os.join_path(root, 'executables.txt')
	os.write_file(database, '')!
	result := run_which_update(WhichUpdateOptions{
		source: database
		pull_request: '123'
		repository: 'Homebrew/homebrew-core'
		pull_request_file_pages: which_update_spec_pull_request_files()
	})!
	return result.removed_formulae == ['old-formula', 'renamed-old']
		&& result.pull_request_url.ends_with('/repos/Homebrew/homebrew-core/pulls/123/files')
}

pub fn which_update_spec_updates_versionless_entries() !bool {
	root := which_update_spec_root('integration')
	os.mkdir_all(root)!
	defer {
		os.rmdir_all(root) or {}
	}
	database := os.join_path(root, 'executables.txt')
	os.write_file(database, 'bar(2.0.0):oldbar\nfoo(1.0.0):foo oldfoo\nremove-me(3.0.0):remove-me\nuntouched(4.0.0):untouched\n')!
	removed_formulae := os.join_path(root, 'removed-formulae.txt')
	os.write_file(removed_formulae, 'remove-me\n')!
	bottle_json_dir := os.join_path(root, 'bottle-json')
	os.mkdir_all(bottle_json_dir)!
	os.write_file(os.join_path(bottle_json_dir, 'invalid.bottle.json'), '{')!
	os.write_file(os.join_path(bottle_json_dir, 'foo.bottle.json'), '{
		"foo": {
			"formula": {"name": "foo"},
			"bottle": {"tags": {"arm64_sonoma": {
				"path_exec_files": ["bin/foo", "sbin/food"]
			}}}
		}
	}')!
	github_output := os.join_path(root, 'github-output.txt')
	result := run_which_update(WhichUpdateOptions{
		source: database
		bottle_json_dir: bottle_json_dir
		removed_formulae_file: removed_formulae
		github_output: github_output
	})!
	return result.updated && result.removed_entries == ['remove-me']
		&& result.warnings.len == 1
		&& os.read_file(database)! == 'bar:oldbar\nfoo:foo food\nuntouched:untouched\n'
		&& os.read_file(github_output)! == 'updated=true\n'
}

// Ruby it `it "requires --pull-request when --repository is passed" do` at line 10.
pub fn ruby_which_update_spec_l10_d1_requires() bool {
	return which_update_spec_requires_pull_request()
}

// Ruby it `it "rejects repositories with extra path segments" do` at line 20.
pub fn ruby_which_update_spec_l20_d2_rejects() !bool {
	return which_update_spec_rejects_repository_path()
}

// Ruby it `it "removes formulae from pull request files" do` at line 35.
pub fn ruby_which_update_spec_l35_d3_removes() !bool {
	return which_update_spec_removes_pull_request_formulae()
}

// Ruby it `it "updates versionless formula entries from bottle JSON", :integration_test do` at line 69.
pub fn ruby_which_update_spec_l69_d4_updates() !bool {
	return which_update_spec_updates_versionless_entries()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/which-update"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::WhichUpdate do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "requires --pull-request when --repository is passed" do
// 11:     mktmpdir do |path|
// 12:       database = path/"executables.txt"
// 13:
// 14:       expect do
// 15:         described_class.new(["--repository=Homebrew/homebrew-core", database.to_s]).run
// 16:       end.to raise_error(Homebrew::CLI::OptionConstraintError)
// 17:     end
// 18:   end
// 19:
// 20:   it "rejects repositories with extra path segments" do
// 21:     mktmpdir do |path|
// 22:       database = path/"executables.txt"
// 23:
// 24:       expect(GitHub::API).not_to receive(:paginate_rest)
// 25:       expect do
// 26:         described_class.new([
// 27:           "--pull-request=123",
// 28:           "--repository=Homebrew/homebrew-core/extra",
// 29:           database.to_s,
// 30:         ]).run
// 31:       end.to raise_error(UsageError, %r{`--repository` must be in the form `owner/repo`\.})
// 32:     end
// 33:   end
// 34:
// 35:   it "removes formulae from pull request files" do
// 36:     mktmpdir do |path|
// 37:       database = path/"executables.txt"
// 38:       database.write ""
// 39:
// 40:       db = instance_double(Homebrew::ExecutablesDB, save!: nil)
// 41:       allow(Homebrew::ExecutablesDB).to receive(:new).with(database.to_s).and_return(db)
// 42:       expect(db).to receive(:update!).with(
// 43:         bottle_json_dir:  nil,
// 44:         removed_formulae: ["old-formula", "renamed-old"],
// 45:       )
// 46:
// 47:       expect(GitHub::API).to receive(:paginate_rest) do |url, &block|
// 48:         expect(url.to_s).to end_with("/repos/Homebrew/homebrew-core/pulls/123/files")
// 49:         block.call [
// 50:           { "filename" => "Formula/new-formula.rb", "status" => "added" },
// 51:           { "filename" => "Formula/old-formula.rb", "status" => "removed" },
// 52:           {
// 53:             "filename"          => "Formula/renamed-new.rb",
// 54:             "previous_filename" => "Formula/renamed-old.rb",
// 55:             "status"            => "renamed",
// 56:           },
// 57:           { "filename" => ".github/workflows/tests.yml", "status" => "modified" },
// 58:         ]
// 59:       end
// 60:
// 61:       described_class.new([
// 62:         "--pull-request=123",
// 63:         "--repository=Homebrew/homebrew-core",
// 64:         database.to_s,
// 65:       ]).run
// 66:     end
// 67:   end
// 68:
// 69:   it "updates versionless formula entries from bottle JSON", :integration_test do
// 70:     mktmpdir do |path|
// 71:       database = path/"executables.txt"
// 72:       database.write <<~EOS
// 73:         bar(2.0.0):oldbar
// 74:         foo(1.0.0):foo oldfoo
// 75:         remove-me(3.0.0):remove-me
// 76:         untouched(4.0.0):untouched
// 77:       EOS
// 78:
// 79:       removed_formulae = path/"removed-formulae.txt"
// 80:       removed_formulae.write "remove-me\n"
// 81:
// 82:       bottle_json_dir = path/"bottle-json"
// 83:       bottle_json_dir.mkpath
// 84:       (bottle_json_dir/"invalid.bottle.json").write "{"
// 85:       (bottle_json_dir/"foo.bottle.json").write <<~JSON
// 86:         {
// 87:           "foo": {
// 88:             "formula": {
// 89:               "name": "foo"
// 90:             },
// 91:             "bottle": {
// 92:               "tags": {
// 93:                 "arm64_sonoma": {
// 94:                   "path_exec_files": ["bin/foo", "sbin/food"]
// 95:                 }
// 96:               }
// 97:             }
// 98:           }
// 99:         }
// 100:       JSON
// 101:
// 102:       github_output = path/"github-output.txt"
// 103:       expect do
// 104:         expect do
// 105:           brew "which-update",
// 106:                "--bottle-json-dir=#{bottle_json_dir}",
// 107:                "--removed-formulae-file=#{removed_formulae}",
// 108:                database.to_s,
// 109:                "GITHUB_OUTPUT" => github_output.to_s
// 110:         end.to be_a_success
// 111:       end.to output("Removed remove-me\n").to_stdout
// 112:
// 113:       expect(database.read).to eq <<~EOS
// 114:         bar:oldbar
// 115:         foo:foo food
// 116:         untouched:untouched
// 117:       EOS
// 118:       expect(github_output.read).to eq "updated=true\n"
// 119:     end
// 120:   end
// 121: end
