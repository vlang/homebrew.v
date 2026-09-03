module cask

import brew_runtime
import homebrew.cask as core

// Translated from Homebrew/brew `test/cask/pkg_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const pkg_spec_id = 'my.fake.pkg'
const pkg_info_spec_id = 'my.fancy.package.main'

fn pkg_spec_command() &core.PkgCommand {
	return &core.PkgCommand{
		infos: {
			pkg_spec_id: core.PkgInfo{
				volume: '/opt'
				install_location: 'fake-root'
			}
		}
		boms: {
			pkg_spec_id: [
				core.PkgBomEntry{
					path: 'plain-file'
					kind: .file
				},
				core.PkgBomEntry{
					path: 'special-file'
					kind: .symlink
				},
				core.PkgBomEntry{
					path: 'directory'
					kind: .directory
				},
			]
		}
	}
}

fn pkg_spec_plist() string {
	return '<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>install-location</key><string>tmp</string>
<key>volume</key><string>/</string>
<key>paths</key><dict>
<key>fancy/bin/fancy.exe</key><dict></dict>
<key>fancy/var/fancy.data</key><dict></dict>
<key>fancy</key><dict></dict>
<key>fancy/bin</key><dict></dict>
<key>fancy/var</key><dict></dict>
</dict></dict></plist>'
}

// Ruby let `let(:fake_system_command) { NeverSudoSystemCommand }` at line 6.
pub fn ruby_pkg_spec_l6_d1_fake_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return core.pkg_command_boundary(pkg_spec_command())
}

// Ruby let `let(:empty_response) do` at line 7.
pub fn ruby_pkg_spec_l7_d2_empty_response(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'stdout':           brew_runtime.string_value('')
		'volume':           brew_runtime.string_value('/')
		'install-location': brew_runtime.string_value('')
		'paths':            brew_runtime.string_array_value([])
	})
}

// Ruby let `let(:pkg) { described_class.new("my.fake.pkg", fake_system_command) }` at line 14.
pub fn ruby_pkg_spec_l14_d3_pkg(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	command := pkg_spec_command()
	return core.ruby_pkg_l23_d3_initialize(brew_runtime.string_value(pkg_spec_id), core.pkg_command_boundary(command))
}

// Ruby it `it "removes files and dirs referenced by the pkg" do` at line 16.
pub fn ruby_pkg_spec_l16_d4_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	command := pkg_spec_command()
	pkg := core.new_pkg(pkg_spec_id, command)
	pkg.uninstall()
	return brew_runtime.bool_value(command.invocations.len == 5 && command.invocations[0].args == [
		'-0',
		'--',
		'/bin/rm',
		'--',
	] && command.invocations[1].args == ['-0', '--', '/bin/rm', '--'] && command.invocations[2].args[2].ends_with('rmdir.sh') && command.invocations.last().args == [
		'--forget',
		pkg_spec_id,
	])
}

// Ruby it `it "forgets the pkg" do` at line 52.
pub fn ruby_pkg_spec_l52_d5_forgets(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	command := &core.PkgCommand{
		infos: {
			pkg_spec_id: core.PkgInfo{
				volume: '/'
			}
		}
	}
	pkg := core.new_pkg(pkg_spec_id, command)
	pkg.uninstall()
	return brew_runtime.bool_value(command.invocations.len == 1 && command.invocations[0].executable == '/usr/sbin/pkgutil' && command.invocations[0].sudo && command.invocations[0].sudo_as_root)
}

// Ruby it `it "removes broken symlinks" do` at line 74.
pub fn ruby_pkg_spec_l74_d6_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(core.pkg_special(core.PkgBomEntry{
		path: 'broken_symlink'
		kind: .symlink
	}) && !core.pkg_special(core.PkgBomEntry{
		path: 'intact_file'
		kind: .file
	}))
}

// Ruby it `it "snags permissions on ornery dirs, but returns them afterwards" do` at line 99.
pub fn ruby_pkg_spec_l99_d7_snags(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	command := core.new_pkg_command()
	pkg := core.new_pkg(pkg_spec_id, command)
	pkg.rmdir(['/tmp/ornery-dir'])
	return brew_runtime.bool_value(command.invocations.len == 1 && command.invocations[0].input == '/tmp/ornery-dir' && command.invocations[0].sudo && command.invocations[0].sudo_as_root)
}

// Ruby let `let(:fake_system_command) { class_double(SystemCommand) }` at line 136.
pub fn ruby_pkg_spec_l136_d8_fake_system_command(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return core.pkg_command_boundary(core.new_pkg_command())
}

// Ruby let `let(:volume) { "/" }` at line 138.
pub fn ruby_pkg_spec_l138_d9_volume(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('/')
}

// Ruby let `let(:install_location) { "tmp" }` at line 139.
pub fn ruby_pkg_spec_l139_d10_install_location(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('tmp')
}

// Ruby let `let(:pkg_id) { "my.fancy.package.main" }` at line 141.
pub fn ruby_pkg_spec_l141_d11_pkg_id(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pkg_info_spec_id)
}

// Ruby let `let(:pkg_files) do` at line 143.
pub fn ruby_pkg_spec_l143_d12_pkg_files(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['fancy/bin/fancy.exe', 'fancy/var/fancy.data'])
}

// Ruby let `let(:pkg_directories) do` at line 149.
pub fn ruby_pkg_spec_l149_d13_pkg_directories(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['fancy', 'fancy/bin', 'fancy/var'])
}

// Ruby let `let(:pkg_info_plist) do` at line 157.
pub fn ruby_pkg_spec_l157_d14_pkg_info_plist(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(pkg_spec_plist())
}

// Ruby it `it "correctly parses a Property List" do` at line 176.
pub fn ruby_pkg_spec_l176_d15_correctly(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	info := core.parse_pkg_info_plist(pkg_spec_plist())
	return brew_runtime.bool_value(info.install_location == 'tmp' && info.volume == '/' && info.paths == [
		'fancy/bin/fancy.exe',
		'fancy/var/fancy.data',
		'fancy',
		'fancy/bin',
		'fancy/var',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Pkg, :cask do
// 5:   describe "#uninstall" do
// 6:     let(:fake_system_command) { NeverSudoSystemCommand }
// 7:     let(:empty_response) do
// 8:       instance_double(
// 9:         SystemCommand::Result,
// 10:         stdout: "",
// 11:         plist:  { "volume" => "/", "install-location" => "", "paths" => {} },
// 12:       )
// 13:     end
// 14:     let(:pkg) { described_class.new("my.fake.pkg", fake_system_command) }
// 15:
// 16:     it "removes files and dirs referenced by the pkg" do
// 17:       some_files = Array.new(3) { Pathname.new(Tempfile.new("plain_file").path) }
// 18:
// 19:       some_specials = Array.new(3) { Pathname.new(Tempfile.new("special_file").path) }
// 20:
// 21:       some_dirs = Array.new(3) { mktmpdir }
// 22:
// 23:       root_dir = Pathname.new(mktmpdir)
// 24:       allow(pkg).to receive_messages(pkgutil_bom_files: some_files, pkgutil_bom_specials: some_specials,
// 25:                                      pkgutil_bom_dirs: some_dirs, root: root_dir)
// 26:
// 27:       allow(pkg).to receive(:forget)
// 28:
// 29:       pkg.uninstall
// 30:
// 31:       some_files.each do |file|
// 32:         expect(file).not_to exist
// 33:       end
// 34:
// 35:       some_specials.each do |file|
// 36:         expect(file).not_to exist
// 37:       end
// 38:
// 39:       some_dirs.each do |dir|
// 40:         expect(dir).not_to exist
// 41:       end
// 42:
// 43:       expect(root_dir).not_to exist
// 44:     ensure
// 45:       some_files&.each { |path| FileUtils.rm_rf(path) }
// 46:       some_specials&.each { |path| FileUtils.rm_rf(path) }
// 47:       some_dirs&.each { |path| FileUtils.rm_rf(path) }
// 48:       FileUtils.rm_rf(root_dir) if root_dir
// 49:     end
// 50:
// 51:     describe "pkgutil" do
// 52:       it "forgets the pkg" do
// 53:         allow(fake_system_command).to receive(:run!).with(
// 54:           "/usr/sbin/pkgutil",
// 55:           args: ["--pkg-info-plist", "my.fake.pkg"],
// 56:         ).and_return(empty_response)
// 57:
// 58:         expect(fake_system_command).to receive(:run!).with(
// 59:           "/usr/sbin/pkgutil",
// 60:           args: ["--files", "my.fake.pkg"],
// 61:         ).and_return(empty_response)
// 62:
// 63:         expect(fake_system_command).to receive(:run!).with(
// 64:           "/usr/sbin/pkgutil",
// 65:           args:         ["--forget", "my.fake.pkg"],
// 66:           sudo:         true,
// 67:           sudo_as_root: true,
// 68:         )
// 69:
// 70:         pkg.uninstall
// 71:       end
// 72:     end
// 73:
// 74:     it "removes broken symlinks" do
// 75:       fake_root = mktmpdir
// 76:       fake_dir  = mktmpdir
// 77:       fake_file = fake_dir.join("ima_file").tap do |path|
// 78:         FileUtils.touch(path)
// 79:       end
// 80:
// 81:       intact_symlink = fake_dir.join("intact_symlink").tap { |path| path.make_symlink(fake_file) }
// 82:       broken_symlink = fake_dir.join("broken_symlink").tap { |path| path.make_symlink("im_nota_file") }
// 83:
// 84:       allow(pkg).to receive_messages(pkgutil_bom_specials: [], pkgutil_bom_files: [], pkgutil_bom_dirs: [fake_dir],
// 85:                                      root: fake_root)
// 86:       allow(pkg).to receive(:forget)
// 87:
// 88:       pkg.uninstall
// 89:
// 90:       expect(intact_symlink).to exist
// 91:       expect(broken_symlink).not_to exist
// 92:       expect(fake_dir).to exist
// 93:       expect(fake_root).not_to exist
// 94:     ensure
// 95:       FileUtils.rm_rf(fake_dir) if fake_dir
// 96:       FileUtils.rm_rf(fake_root) if fake_root
// 97:     end
// 98:
// 99:     it "snags permissions on ornery dirs, but returns them afterwards" do
// 100:       fake_root = mktmpdir
// 101:       fake_dir = mktmpdir
// 102:       fake_file = fake_dir.join("ima_unrelated_file").tap { |path| FileUtils.touch(path) }
// 103:       fake_dir.chmod(0000)
// 104:
// 105:       allow(pkg).to receive_messages(pkgutil_bom_specials: [], pkgutil_bom_files: [], pkgutil_bom_dirs: [fake_dir],
// 106:                                      root: fake_root)
// 107:       allow(pkg).to receive(:forget)
// 108:
// 109:       # This is expected to fail in tests since we don't use `sudo`.
// 110:       allow(fake_system_command).to receive(:run!).and_call_original
// 111:       expect(fake_system_command).to receive(:run!).with(
// 112:         "/usr/bin/xargs",
// 113:         args:         ["-0", "--", a_string_including("rmdir")],
// 114:         input:        [fake_dir].join("\0"),
// 115:         sudo:         true,
// 116:         sudo_as_root: true,
// 117:       ).and_return(instance_double(SystemCommand::Result, stdout: ""))
// 118:
// 119:       pkg.uninstall
// 120:
// 121:       expect(fake_dir).to be_a_directory
// 122:       expect(fake_dir.stat.mode % 01000).to eq(0)
// 123:
// 124:       fake_dir.chmod(0777)
// 125:       expect(fake_file).to be_a_file
// 126:     ensure
// 127:       if fake_dir
// 128:         fake_dir.chmod(0777)
// 129:         FileUtils.rm_rf(fake_dir)
// 130:       end
// 131:       FileUtils.rm_rf(fake_root) if fake_root
// 132:     end
// 133:   end
// 134:
// 135:   describe "#info" do
// 136:     let(:fake_system_command) { class_double(SystemCommand) }
// 137:
// 138:     let(:volume) { "/" }
// 139:     let(:install_location) { "tmp" }
// 140:
// 141:     let(:pkg_id) { "my.fancy.package.main" }
// 142:
// 143:     let(:pkg_files) do
// 144:       %w[
// 145:         fancy/bin/fancy.exe
// 146:         fancy/var/fancy.data
// 147:       ]
// 148:     end
// 149:     let(:pkg_directories) do
// 150:       %w[
// 151:         fancy
// 152:         fancy/bin
// 153:         fancy/var
// 154:       ]
// 155:     end
// 156:
// 157:     let(:pkg_info_plist) do
// 158:       <<~XML
// 159:         <?xml version="1.0" encoding="UTF-8"?>
// 160:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 161:         <plist version="1.0">
// 162:         <dict>
// 163:           <key>install-location</key>
// 164:           <string>#{install_location}</string>
// 165:           <key>volume</key>
// 166:           <string>#{volume}</string>
// 167:           <key>paths</key>
// 168:           <dict>
// 169:             #{(pkg_files + pkg_directories).map { |f| "<key>#{f}</key><dict></dict>" }.join}
// 170:           </dict>
// 171:         </dict>
// 172:         </plist>
// 173:       XML
// 174:     end
// 175:
// 176:     it "correctly parses a Property List" do
// 177:       pkg = described_class.new(pkg_id, fake_system_command)
// 178:
// 179:       expect(fake_system_command).to receive(:run!).with(
// 180:         "/usr/sbin/pkgutil",
// 181:         args: ["--pkg-info-plist", pkg_id],
// 182:       ).and_return(
// 183:         SystemCommand::Result.new(
// 184:           ["/usr/sbin/pkgutil", "--pkg-info-plist", pkg_id],
// 185:           [[:stdout, pkg_info_plist]],
// 186:           instance_double(Process::Status, exitstatus: 0),
// 187:           secrets: [],
// 188:         ),
// 189:       )
// 190:
// 191:       info = pkg.info
// 192:
// 193:       expect(info["install-location"]).to eq(install_location)
// 194:       expect(info["volume"]).to eq(volume)
// 195:       expect(info["paths"].keys).to eq(pkg_files + pkg_directories)
// 196:     end
// 197:   end
// 198: end
