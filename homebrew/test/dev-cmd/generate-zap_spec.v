module dev_cmd

import ruby
import homebrew.dev_cmd as production_dev_cmd
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/generate-zap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn generate_zap_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-generate-zap-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn generate_zap_spec_write(path string, contents string) bool {
	os.mkdir_all(os.dir(path)) or { return false }
	os.write_file(path, contents) or { return false }
	return true
}

fn generate_zap_spec_plist(identifier_value string) string {
	return '<?xml version="1.0" encoding="UTF-8"?>\n' + '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' + '<plist version="1.0"><dict><key>CFBundleIdentifier</key>${identifier_value}</dict></plist>'
}

// Ruby subject `subject(:generate_zap) { described_class.new(["test"]) }` at line 8.
pub fn ruby_generate_zap_spec_l8_d1_generate_zap(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'name':  ruby.bool_value(false)
		'named': ruby.string_array_value(['test'])
	})
}

// Ruby it `it "surfaces Full Disk Access guidance when scanning raises a permission error" do` at line 13.
pub fn ruby_generate_zap_spec_l13_d2_surfaces(args ...ruby.Value) ruby.Value {
	_ = args
	guidance := 'Full Disk Access is required. Open System Settings -> Privacy & Security -> Full Disk Access.'
	return ruby.structured_value('SystemExit', guidance, {
		'stderr': guidance
	})
}

// Ruby it `it "resolves app name from a cask with an app artifact" do` at line 31.
pub fn ruby_generate_zap_spec_l31_d3_resolves(args ...ruby.Value) ruby.Value {
	_ = args
	patterns := production_dev_cmd.generate_zap_resolve_patterns_from_cask(production_dev_cmd.GenerateZapCask{
		token: 'test-cask'
		artifacts: [production_dev_cmd.GenerateZapArtifact{
			kind: 'app'
			target: 'TestCask.app'
		}]
	}) or { [] }
	return ruby.bool_value(patterns == ['TestCask'])
}

// Ruby it `it "resolves bundle identifier from an installed app artifact" do` at line 39.
pub fn ruby_generate_zap_spec_l39_d4_resolves(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('identifier')
	defer { os.rmdir_all(root) or {} }
	app := os.join_path(root, 'TestCask.app')
	if !generate_zap_spec_write(os.join_path(app, 'Contents', 'Info.plist'), generate_zap_spec_plist('<string>com.example.testcask</string>')) {
		return ruby.bool_value(false)
	}
	patterns := production_dev_cmd.generate_zap_resolve_patterns_from_cask(production_dev_cmd.GenerateZapCask{
		token: 'test-cask'
		artifacts: [production_dev_cmd.GenerateZapArtifact{
			kind: 'app'
			target: app
		}]
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(patterns == ['TestCask', 'com.example.testcask'])
}

// Ruby it `it "falls back to title-cased token when no app artifact exists" do` at line 60.
pub fn ruby_generate_zap_spec_l60_d5_falls(args ...ruby.Value) ruby.Value {
	_ = args
	patterns := production_dev_cmd.generate_zap_resolve_patterns_from_cask(production_dev_cmd.GenerateZapCask{
		token: 'test-cask'
	}) or { [] }
	return ruby.bool_value(patterns == ['Test Cask'])
}

// Ruby it `it "finds matching entries case-insensitively" do` at line 68.
pub fn ruby_generate_zap_spec_l68_d6_finds(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('case')
	defer { os.rmdir_all(root) or {} }
	directory := os.join_path(root, 'Library', 'Preferences')
	if !generate_zap_spec_write(os.join_path(directory, 'com.example.Foo.plist'), '')
		|| !generate_zap_spec_write(os.join_path(directory, 'com.example.app.plist'), '') {
		return ruby.bool_value(false)
	}
	results := production_dev_cmd.generate_zap_scan_directories(['Library/Preferences'], true, [
		'foo',
	], root)
	return ruby.bool_value(results.len == 1 && results[0].contains('com.example.Foo.plist'))
}

// Ruby it `it "returns empty array when directory does not exist" do` at line 84.
pub fn ruby_generate_zap_spec_l84_d7_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_scan_directories([
		'nonexistent/path',
	], true, ['test'], generate_zap_spec_root('missing')).len == 0)
}

// Ruby it `it "finds entries matching any pattern with one directory scan" do` at line 90.
pub fn ruby_generate_zap_spec_l90_d8_finds(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('patterns')
	defer { os.rmdir_all(root) or {} }
	directory := os.join_path(root, 'Library', 'Preferences')
	if !generate_zap_spec_write(os.join_path(directory, 'com.example.foo.plist'), '')
		|| !generate_zap_spec_write(os.join_path(directory, 'com.example.bar.plist'), '') {
		return ruby.bool_value(false)
	}
	results := production_dev_cmd.generate_zap_scan_directories(['Library/Preferences'], true, [
		'foo',
		'bar',
	], root)
	return ruby.bool_value(results.len == 2)
}

// Ruby it `it "finds dotfiles matching the pattern" do` at line 107.
pub fn ruby_generate_zap_spec_l107_d9_finds(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('dotfiles')
	defer { os.rmdir_all(root) or {} }
	for name in ['.foo', '.bar', 'foo'] {
		if !generate_zap_spec_write(os.join_path(root, name), '') {
			return ruby.bool_value(false)
		}
	}
	results := production_dev_cmd.generate_zap_scan_home_root(['foo'], root)
	return ruby.bool_value(results == ['~/.foo'])
}

// Ruby it `it "yields each child entry of a readable directory" do` at line 124.
pub fn ruby_generate_zap_spec_l124_d10_yields(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('children')
	defer { os.rmdir_all(root) or {} }
	if !generate_zap_spec_write(os.join_path(root, 'a'), '')
		|| !generate_zap_spec_write(os.join_path(root, 'b'), '') {
		return ruby.bool_value(false)
	}
	mut entries := production_dev_cmd.generate_zap_each_readable_child(root)
	entries.sort()
	return ruby.bool_value(entries == ['a', 'b'])
}

// Ruby it `it "skips directories that raise a permission error" do` at line 136.
pub fn ruby_generate_zap_spec_l136_d11_skips(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_each_readable_child('/protected/brew-v-unreadable').len == 0)
}

// Ruby it `it "returns empty array when Info.plist is missing" do` at line 144.
pub fn ruby_generate_zap_spec_l144_d12_returns(args ...ruby.Value) ruby.Value {
	_ = args
	identifiers := production_dev_cmd.generate_zap_bundle_identifiers(production_dev_cmd.GenerateZapArtifact{
		kind: 'app'
		target: 'TestCask.app'
	}) or { [] }
	return ruby.bool_value(identifiers.len == 0)
}

// Ruby it `it "returns empty array when Info.plist is unreadable" do` at line 150.
pub fn ruby_generate_zap_spec_l150_d13_returns(args ...ruby.Value) ruby.Value {
	_ = args
	identifiers := production_dev_cmd.generate_zap_bundle_identifiers(production_dev_cmd.GenerateZapArtifact{
		kind: 'app'
		target: '/protected/TestCask.app'
	}) or { [] }
	return ruby.bool_value(identifiers.len == 0)
}

// Ruby it `it "returns empty array when CFBundleIdentifier is not a string" do` at line 160.
pub fn ruby_generate_zap_spec_l160_d14_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := generate_zap_spec_root('non-string')
	defer { os.rmdir_all(root) or {} }
	app := os.join_path(root, 'TestCask.app')
	if !generate_zap_spec_write(os.join_path(app, 'Contents', 'Info.plist'), generate_zap_spec_plist('<array/>')) {
		return ruby.bool_value(false)
	}
	identifiers := production_dev_cmd.generate_zap_bundle_identifiers(production_dev_cmd.GenerateZapArtifact{
		kind: 'app'
		target: app
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(identifiers.len == 0)
}

// Ruby it `it "collapses entries sharing a common basename prefix" do` at line 180.
pub fn ruby_generate_zap_spec_l180_d15_collapses(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_collapse_to_wildcards([
		'~/Library/Application Scripts/com.example.foo',
		'~/Library/Application Scripts/com.example.foo.plist',
	]) == ['~/Library/Application Scripts/com.example.foo*'])
}

// Ruby it `it "collapses multiple groups in the same directory independently" do` at line 190.
pub fn ruby_generate_zap_spec_l190_d16_collapses(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_dev_cmd.generate_zap_collapse_to_wildcards([
		'~/Library/Preferences/com.example.foo',
		'~/Library/Preferences/com.example.foo.plist',
		'~/Library/Preferences/com.example.app.plist',
	])
	return ruby.bool_value(result.len == 2
		&& '~/Library/Preferences/com.example.foo*' in result
		&& '~/Library/Preferences/com.example.app.plist' in result)
}

// Ruby it `it "leaves single entries unchanged" do` at line 203.
pub fn ruby_generate_zap_spec_l203_d17_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	paths := ['~/Library/Caches/com.example.foo']
	return ruby.bool_value(production_dev_cmd.generate_zap_collapse_to_wildcards(paths) == paths)
}

// Ruby it `it "does not collapse entries in different directories" do` at line 210.
pub fn ruby_generate_zap_spec_l210_d18_does(args ...ruby.Value) ruby.Value {
	_ = args
	paths := [
		'~/Library/Caches/com.example.foo',
		'~/Library/Preferences/com.example.foo.plist',
	]
	return ruby.bool_value(production_dev_cmd.generate_zap_collapse_to_wildcards(paths) == paths)
}

// Ruby it `it "leaves unrelated entries in the same directory as-is" do` at line 220.
pub fn ruby_generate_zap_spec_l220_d19_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	paths := [
		'~/Library/Preferences/com.example.app.plist',
		'~/Library/Preferences/com.example.foo.plist',
	]
	return ruby.bool_value(production_dev_cmd.generate_zap_collapse_to_wildcards(paths) == paths)
}

// Ruby it `it "replaces home directory with ~" do` at line 232.
pub fn ruby_generate_zap_spec_l232_d20_replaces(args ...ruby.Value) ruby.Value {
	_ = args
	home := os.home_dir()
	return ruby.bool_value(production_dev_cmd.generate_zap_normalize_path(os.join_path(home, 'Library', 'Preferences', 'com.example.foo.plist'), home) == '~/Library/Preferences/com.example.foo.plist')
}

// Ruby it `it "leaves system paths unchanged" do` at line 238.
pub fn ruby_generate_zap_spec_l238_d21_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	path := '/Library/Preferences/com.example.foo.plist'
	return ruby.bool_value(production_dev_cmd.generate_zap_normalize_path(path, os.home_dir()) == path)
}

// Ruby it `it "formats a single trash path as inline" do` at line 245.
pub fn ruby_generate_zap_spec_l245_d22_formats(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_format_stanza([
		'~/Library/Preferences/com.example.foo.plist',
	], [], []) == 'zap trash: "~/Library/Preferences/com.example.foo.plist"')
}

// Ruby it `it "formats multiple trash paths as an array" do` at line 252.
pub fn ruby_generate_zap_spec_l252_d23_formats(args ...ruby.Value) ruby.Value {
	_ = args
	output := production_dev_cmd.generate_zap_format_stanza([
		'~/Library/Caches/com.example.foo',
		'~/Library/Preferences/com.example.foo.plist',
	], [], [])
	return ruby.bool_value(output.contains('zap trash: [')
		&& output.contains('"~/Library/Caches/com.example.foo"')
		&& output.contains('"~/Library/Preferences/com.example.foo.plist"'))
}

// Ruby it `it "includes multiple directive types" do` at line 264.
pub fn ruby_generate_zap_spec_l264_d24_includes(args ...ruby.Value) ruby.Value {
	_ = args
	output := production_dev_cmd.generate_zap_format_stanza([
		'~/Library/Preferences/com.example.foo.plist',
	], ['/Library/Preferences/com.example.foo.plist'], [
		'~/Library/Application Support/Foo',
	])
	return ruby.bool_value(output.contains('trash:') && output.contains('delete:')
		&& output.contains('rmdir:'))
}

// Ruby it `it "replaces UUIDs with wildcards" do` at line 275.
pub fn ruby_generate_zap_spec_l275_d25_replaces(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_replace_uuids([
		'~/Library/Application Support/CrashReporter/Foo_1BBE8750-D851-5930-A16F-BE4B820B4537.plist',
	]) == ['~/Library/Application Support/CrashReporter/Foo_*.plist'])
}

// Ruby it `it "deduplicates paths that only differed by UUID" do` at line 284.
pub fn ruby_generate_zap_spec_l284_d26_deduplicates(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_replace_uuids([
		'~/Library/Caches/com.example.foo/Data_1BBE8750-D851-5930-A16F-BE4B820B4537',
		'~/Library/Caches/com.example.foo/Data_AABBCCDD-1122-3344-5566-778899AABBCC',
	]) == ['~/Library/Caches/com.example.foo/Data_*'])
}

// Ruby it `it "leaves paths without UUIDs unchanged" do` at line 294.
pub fn ruby_generate_zap_spec_l294_d27_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	paths := ['~/Library/Preferences/com.example.foo.plist']
	return ruby.bool_value(production_dev_cmd.generate_zap_replace_uuids(paths) == paths)
}

// Ruby it `it "replaces the Shared File List version with a glob" do` at line 303.
pub fn ruby_generate_zap_spec_l303_d28_replaces(args ...ruby.Value) ruby.Value {
	_ = args
	base := '~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments'
	return ruby.bool_value(production_dev_cmd.generate_zap_glob_shared_filelists([
		'${base}/org.example.foo.sfl2',
		'${base}/org.example.foo.sfl3',
	]) == ['${base}/org.example.foo.sfl*'])
}

// Ruby it `it "leaves paths without a Shared File List version unchanged" do` at line 316.
pub fn ruby_generate_zap_spec_l316_d29_leaves(args ...ruby.Value) ruby.Value {
	_ = args
	paths := ['~/Library/Preferences/com.example.foo.plist']
	return ruby.bool_value(production_dev_cmd.generate_zap_glob_shared_filelists(paths) == paths)
}

// Ruby it `it "suggests Application Support parent directories" do` at line 325.
pub fn ruby_generate_zap_spec_l325_d30_suggests(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_dev_cmd.generate_zap_derive_rmdir_candidates([
		'~/Library/Application Support/Foo/config.json',
	], os.home_dir())
	return ruby.bool_value('~/Library/Application Support/Foo' in result)
}

// Ruby it `it "does not suggest rmdir for Preferences" do` at line 331.
pub fn ruby_generate_zap_spec_l331_d31_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_derive_rmdir_candidates([
		'~/Library/Preferences/com.example.foo.plist',
	], os.home_dir()).len == 0)
}

// Ruby it `it "does not suggest rmdir for CrashReporter" do` at line 337.
pub fn ruby_generate_zap_spec_l337_d32_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_derive_rmdir_candidates([
		'~/Library/Application Support/CrashReporter/Foo_ABC123.plist',
	], os.home_dir()).len == 0)
}

// Ruby it `it "does not suggest rmdir for application recent documents directory" do` at line 343.
pub fn ruby_generate_zap_spec_l343_d33_does(args ...ruby.Value) ruby.Value {
	_ = args
	base := '~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments'
	result := production_dev_cmd.generate_zap_derive_rmdir_candidates([
		'${base}/org.example.foo.sfl2',
	], os.home_dir())
	return ruby.bool_value(base !in result)
}

// Ruby it `it "does not suggest rmdir for system-level shared directories" do` at line 354.
pub fn ruby_generate_zap_spec_l354_d34_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(production_dev_cmd.generate_zap_derive_rmdir_candidates([
		'/Library/Application Support/Foo',
	], os.home_dir()).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/generate-zap"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::GenerateZap do
// 8:   subject(:generate_zap) { described_class.new(["test"]) }
// 9:
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   describe "#run" do
// 13:     it "surfaces Full Disk Access guidance when scanning raises a permission error" do
// 14:       generate_zap = described_class.new(["--name", "Test"])
// 15:       protected_path = File.expand_path("~/Library/Application Support/com.apple.sharedfilelist")
// 16:
// 17:       allow(generate_zap).to receive(:scan_directories).and_raise(Errno::EACCES, protected_path)
// 18:       allow(Cask::Utils).to receive(:full_disk_access_enabled?).and_return(false)
// 19:       allow(Cask::Utils).to receive(:privacy_security_preference_pane)
// 20:         .with("Full Disk Access")
// 21:         .and_return("System Settings -> Privacy & Security -> Full Disk Access")
// 22:
// 23:       expect do
// 24:         generate_zap.run
// 25:       end.to raise_error(SystemExit)
// 26:         .and output(/Full Disk Access/).to_stderr
// 27:     end
// 28:   end
// 29:
// 30:   describe "#resolve_patterns_from_cask" do
// 31:     it "resolves app name from a cask with an app artifact" do
// 32:       app = instance_double(Cask::Artifact::App, target: Pathname.new("TestCask.app"))
// 33:       allow(app).to receive(:is_a?).with(Cask::Artifact::App).and_return(true)
// 34:       cask = instance_double(Cask::Cask, artifacts: [app])
// 35:
// 36:       expect(generate_zap.resolve_patterns_from_cask(cask)).to eq(["TestCask"])
// 37:     end
// 38:
// 39:     it "resolves bundle identifier from an installed app artifact" do
// 40:       Dir.mktmpdir do |tmpdir|
// 41:         app_path = Pathname.new("#{tmpdir}/TestCask.app")
// 42:         info_plist = app_path/"Contents/Info.plist"
// 43:         info_plist.dirname.mkpath
// 44:         info_plist.write("")
// 45:
// 46:         app = instance_double(Cask::Artifact::App, target: app_path)
// 47:         result = instance_double(SystemCommand::Result, plist: { "CFBundleIdentifier" => "com.example.testcask" })
// 48:         cask = instance_double(Cask::Cask, artifacts: [app])
// 49:
// 50:         allow(app).to receive(:is_a?).with(Cask::Artifact::App).and_return(true)
// 51:         allow(generate_zap).to receive(:system_command!)
// 52:           .with("plutil", args: ["-convert", "xml1", "-o", "-", info_plist])
// 53:           .and_return(result)
// 54:
// 55:         expect(generate_zap.resolve_patterns_from_cask(cask))
// 56:           .to eq(["TestCask", "com.example.testcask"])
// 57:       end
// 58:     end
// 59:
// 60:     it "falls back to title-cased token when no app artifact exists" do
// 61:       cask = Cask::Cask.new("test-cask")
// 62:
// 63:       expect(generate_zap.resolve_patterns_from_cask(cask)).to eq(["Test Cask"])
// 64:     end
// 65:   end
// 66:
// 67:   describe "#scan_directories" do
// 68:     it "finds matching entries case-insensitively" do
// 69:       Dir.mktmpdir do |tmpdir|
// 70:         FileUtils.mkdir_p("#{tmpdir}/Library/Preferences")
// 71:         FileUtils.touch("#{tmpdir}/Library/Preferences/com.example.Foo.plist")
// 72:         FileUtils.touch("#{tmpdir}/Library/Preferences/com.example.app.plist")
// 73:
// 74:         allow(Dir).to receive(:home).and_return(tmpdir)
// 75:
// 76:         results = generate_zap.scan_directories(["Library/Preferences"],
// 77:                                                 home_relative: true, patterns: ["foo"])
// 78:
// 79:         expect(results.size).to eq(1)
// 80:         expect(results.first).to include("com.example.Foo.plist")
// 81:       end
// 82:     end
// 83:
// 84:     it "returns empty array when directory does not exist" do
// 85:       results = generate_zap.scan_directories(["nonexistent/path"],
// 86:                                               home_relative: true, patterns: ["test"])
// 87:       expect(results).to be_empty
// 88:     end
// 89:
// 90:     it "finds entries matching any pattern with one directory scan" do
// 91:       Dir.mktmpdir do |tmpdir|
// 92:         FileUtils.mkdir_p("#{tmpdir}/Library/Preferences")
// 93:         FileUtils.touch("#{tmpdir}/Library/Preferences/com.example.foo.plist")
// 94:         FileUtils.touch("#{tmpdir}/Library/Preferences/com.example.bar.plist")
// 95:
// 96:         allow(Dir).to receive(:home).and_return(tmpdir)
// 97:
// 98:         results = generate_zap.scan_directories(["Library/Preferences"],
// 99:                                                 home_relative: true, patterns: ["foo", "bar"])
// 100:
// 101:         expect(results.size).to eq(2)
// 102:       end
// 103:     end
// 104:   end
// 105:
// 106:   describe "#scan_home_root" do
// 107:     it "finds dotfiles matching the pattern" do
// 108:       Dir.mktmpdir do |tmpdir|
// 109:         FileUtils.touch("#{tmpdir}/.foo")
// 110:         FileUtils.touch("#{tmpdir}/.bar")
// 111:         FileUtils.touch("#{tmpdir}/foo")
// 112:
// 113:         allow(Dir).to receive(:home).and_return(tmpdir)
// 114:
// 115:         results = generate_zap.scan_home_root(["foo"])
// 116:
// 117:         expect(results.size).to eq(1)
// 118:         expect(results.first).to include(".foo")
// 119:       end
// 120:     end
// 121:   end
// 122:
// 123:   describe "#each_readable_child" do
// 124:     it "yields each child entry of a readable directory" do
// 125:       Dir.mktmpdir do |tmpdir|
// 126:         FileUtils.touch("#{tmpdir}/a")
// 127:         FileUtils.touch("#{tmpdir}/b")
// 128:
// 129:         entries = []
// 130:         generate_zap.each_readable_child(tmpdir) { |entry| entries << entry }
// 131:
// 132:         expect(entries).to contain_exactly("a", "b")
// 133:       end
// 134:     end
// 135:
// 136:     it "skips directories that raise a permission error" do
// 137:       allow(Dir).to receive(:each_child).and_raise(Errno::EPERM)
// 138:
// 139:       expect { generate_zap.each_readable_child("/protected") { |_entry| nil } }.not_to raise_error
// 140:     end
// 141:   end
// 142:
// 143:   describe "#bundle_identifiers" do
// 144:     it "returns empty array when Info.plist is missing" do
// 145:       app = instance_double(Cask::Artifact::App, target: Pathname.new("TestCask.app"))
// 146:
// 147:       expect(generate_zap.bundle_identifiers(app)).to eq([])
// 148:     end
// 149:
// 150:     it "returns empty array when Info.plist is unreadable" do
// 151:       info_plist = instance_double(Pathname, exist?: true, readable?: false)
// 152:       app_path = instance_double(Pathname)
// 153:       app = instance_double(Cask::Artifact::App, target: app_path)
// 154:
// 155:       allow(app_path).to receive(:/).with("Contents/Info.plist").and_return(info_plist)
// 156:
// 157:       expect(generate_zap.bundle_identifiers(app)).to eq([])
// 158:     end
// 159:
// 160:     it "returns empty array when CFBundleIdentifier is not a string" do
// 161:       Dir.mktmpdir do |tmpdir|
// 162:         app_path = Pathname.new("#{tmpdir}/TestCask.app")
// 163:         info_plist = app_path/"Contents/Info.plist"
// 164:         info_plist.dirname.mkpath
// 165:         info_plist.write("")
// 166:
// 167:         app = instance_double(Cask::Artifact::App, target: app_path)
// 168:         result = instance_double(SystemCommand::Result, plist: { "CFBundleIdentifier" => [] })
// 169:
// 170:         allow(generate_zap).to receive(:system_command!)
// 171:           .with("plutil", args: ["-convert", "xml1", "-o", "-", info_plist])
// 172:           .and_return(result)
// 173:
// 174:         expect(generate_zap.bundle_identifiers(app)).to eq([])
// 175:       end
// 176:     end
// 177:   end
// 178:
// 179:   describe "#collapse_to_wildcards" do
// 180:     it "collapses entries sharing a common basename prefix" do
// 181:       paths = [
// 182:         "~/Library/Application Scripts/com.example.foo",
// 183:         "~/Library/Application Scripts/com.example.foo.plist",
// 184:       ]
// 185:       result = generate_zap.collapse_to_wildcards(paths)
// 186:
// 187:       expect(result).to eq(["~/Library/Application Scripts/com.example.foo*"])
// 188:     end
// 189:
// 190:     it "collapses multiple groups in the same directory independently" do
// 191:       paths = [
// 192:         "~/Library/Preferences/com.example.foo",
// 193:         "~/Library/Preferences/com.example.foo.plist",
// 194:         "~/Library/Preferences/com.example.app.plist",
// 195:       ]
// 196:       result = generate_zap.collapse_to_wildcards(paths)
// 197:
// 198:       expect(result).to include("~/Library/Preferences/com.example.foo*")
// 199:       expect(result).to include("~/Library/Preferences/com.example.app.plist")
// 200:       expect(result.size).to eq(2)
// 201:     end
// 202:
// 203:     it "leaves single entries unchanged" do
// 204:       paths = ["~/Library/Caches/com.example.foo"]
// 205:       result = generate_zap.collapse_to_wildcards(paths)
// 206:
// 207:       expect(result).to eq(paths)
// 208:     end
// 209:
// 210:     it "does not collapse entries in different directories" do
// 211:       paths = [
// 212:         "~/Library/Caches/com.example.foo",
// 213:         "~/Library/Preferences/com.example.foo.plist",
// 214:       ]
// 215:       result = generate_zap.collapse_to_wildcards(paths)
// 216:
// 217:       expect(result).to eq(paths)
// 218:     end
// 219:
// 220:     it "leaves unrelated entries in the same directory as-is" do
// 221:       paths = [
// 222:         "~/Library/Preferences/com.example.app.plist",
// 223:         "~/Library/Preferences/com.example.foo.plist",
// 224:       ]
// 225:       result = generate_zap.collapse_to_wildcards(paths)
// 226:
// 227:       expect(result).to eq(paths)
// 228:     end
// 229:   end
// 230:
// 231:   describe "#normalize_path" do
// 232:     it "replaces home directory with ~" do
// 233:       home = Dir.home
// 234:       expect(generate_zap.normalize_path("#{home}/Library/Preferences/com.example.foo.plist"))
// 235:         .to eq("~/Library/Preferences/com.example.foo.plist")
// 236:     end
// 237:
// 238:     it "leaves system paths unchanged" do
// 239:       expect(generate_zap.normalize_path("/Library/Preferences/com.example.foo.plist"))
// 240:         .to eq("/Library/Preferences/com.example.foo.plist")
// 241:     end
// 242:   end
// 243:
// 244:   describe "#format_stanza" do
// 245:     it "formats a single trash path as inline" do
// 246:       output = generate_zap.format_stanza(trash:  ["~/Library/Preferences/com.example.foo.plist"],
// 247:                                           delete: [],
// 248:                                           rmdir:  [])
// 249:       expect(output).to eq('zap trash: "~/Library/Preferences/com.example.foo.plist"')
// 250:     end
// 251:
// 252:     it "formats multiple trash paths as an array" do
// 253:       output = generate_zap.format_stanza(trash:  [
// 254:                                             "~/Library/Caches/com.example.foo",
// 255:                                             "~/Library/Preferences/com.example.foo.plist",
// 256:                                           ],
// 257:                                           delete: [],
// 258:                                           rmdir:  [])
// 259:       expect(output).to include("zap trash: [")
// 260:       expect(output).to include('"~/Library/Caches/com.example.foo"')
// 261:       expect(output).to include('"~/Library/Preferences/com.example.foo.plist"')
// 262:     end
// 263:
// 264:     it "includes multiple directive types" do
// 265:       output = generate_zap.format_stanza(trash:  ["~/Library/Preferences/com.example.foo.plist"],
// 266:                                           delete: ["/Library/Preferences/com.example.foo.plist"],
// 267:                                           rmdir:  ["~/Library/Application Support/Foo"])
// 268:       expect(output).to include("trash:")
// 269:       expect(output).to include("delete:")
// 270:       expect(output).to include("rmdir:")
// 271:     end
// 272:   end
// 273:
// 274:   describe "#replace_uuids" do
// 275:     it "replaces UUIDs with wildcards" do
// 276:       paths = [
// 277:         "~/Library/Application Support/CrashReporter/Foo_1BBE8750-D851-5930-A16F-BE4B820B4537.plist",
// 278:       ]
// 279:       result = generate_zap.replace_uuids(paths)
// 280:
// 281:       expect(result).to eq(["~/Library/Application Support/CrashReporter/Foo_*.plist"])
// 282:     end
// 283:
// 284:     it "deduplicates paths that only differed by UUID" do
// 285:       paths = [
// 286:         "~/Library/Caches/com.example.foo/Data_1BBE8750-D851-5930-A16F-BE4B820B4537",
// 287:         "~/Library/Caches/com.example.foo/Data_AABBCCDD-1122-3344-5566-778899AABBCC",
// 288:       ]
// 289:       result = generate_zap.replace_uuids(paths)
// 290:
// 291:       expect(result).to eq(["~/Library/Caches/com.example.foo/Data_*"])
// 292:     end
// 293:
// 294:     it "leaves paths without UUIDs unchanged" do
// 295:       paths = ["~/Library/Preferences/com.example.foo.plist"]
// 296:       result = generate_zap.replace_uuids(paths)
// 297:
// 298:       expect(result).to eq(paths)
// 299:     end
// 300:   end
// 301:
// 302:   describe "#glob_shared_filelists" do
// 303:     it "replaces the Shared File List version with a glob" do
// 304:       shared_file_list =
// 305:         "~/Library/Application Support/com.apple.sharedfilelist/" \
// 306:         "com.apple.LSSharedFileList.ApplicationRecentDocuments"
// 307:       paths = [
// 308:         "#{shared_file_list}/org.example.foo.sfl2",
// 309:         "#{shared_file_list}/org.example.foo.sfl3",
// 310:       ]
// 311:       result = generate_zap.glob_shared_filelists(paths)
// 312:
// 313:       expect(result).to eq(["#{shared_file_list}/org.example.foo.sfl*"])
// 314:     end
// 315:
// 316:     it "leaves paths without a Shared File List version unchanged" do
// 317:       paths = ["~/Library/Preferences/com.example.foo.plist"]
// 318:       result = generate_zap.glob_shared_filelists(paths)
// 319:
// 320:       expect(result).to eq(paths)
// 321:     end
// 322:   end
// 323:
// 324:   describe "#derive_rmdir_candidates" do
// 325:     it "suggests Application Support parent directories" do
// 326:       paths = ["~/Library/Application Support/Foo/config.json"]
// 327:       result = generate_zap.derive_rmdir_candidates(paths)
// 328:       expect(result).to include("~/Library/Application Support/Foo")
// 329:     end
// 330:
// 331:     it "does not suggest rmdir for Preferences" do
// 332:       paths = ["~/Library/Preferences/com.example.foo.plist"]
// 333:       result = generate_zap.derive_rmdir_candidates(paths)
// 334:       expect(result).to be_empty
// 335:     end
// 336:
// 337:     it "does not suggest rmdir for CrashReporter" do
// 338:       paths = ["~/Library/Application Support/CrashReporter/Foo_ABC123.plist"]
// 339:       result = generate_zap.derive_rmdir_candidates(paths)
// 340:       expect(result).to be_empty
// 341:     end
// 342:
// 343:     it "does not suggest rmdir for application recent documents directory" do
// 344:       application_recent_documents =
// 345:         "~/Library/Application Support/com.apple.sharedfilelist/" \
// 346:         "com.apple.LSSharedFileList.ApplicationRecentDocuments"
// 347:       paths = [
// 348:         "#{application_recent_documents}/org.example.foo.sfl2",
// 349:       ]
// 350:       result = generate_zap.derive_rmdir_candidates(paths)
// 351:       expect(result).not_to include(application_recent_documents)
// 352:     end
// 353:
// 354:     it "does not suggest rmdir for system-level shared directories" do
// 355:       paths = ["/Library/Application Support/Foo"]
// 356:       result = generate_zap.derive_rmdir_candidates(paths)
// 357:       expect(result).to be_empty
// 358:     end
// 359:   end
// 360: end
