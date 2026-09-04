module cask

import ruby
import homebrew.cask as base_cask
import homebrew.extend.os.mac.cask as mac_cask
import homebrew.os.mac.ffi as mac_ffi

fn quarantine_spec_success(_ base_cask.QuarantineCommand) !base_cask.QuarantineCommandResult {
	return base_cask.QuarantineCommandResult{}
}

fn quarantine_spec_status_approved(command base_cask.QuarantineCommand) !base_cask.QuarantineCommandResult {
	if '-p' in command.args {
		return base_cask.QuarantineCommandResult{ stdout: '01c3;6723b9fa;Safari;event-id\n' }
	}
	return base_cask.QuarantineCommandResult{}
}

fn quarantine_spec_status_unapproved(command base_cask.QuarantineCommand) !base_cask.QuarantineCommandResult {
	if '-p' in command.args {
		return base_cask.QuarantineCommandResult{ stdout: '0183;6723b9fa;Safari;event-id\n' }
	}
	return base_cask.QuarantineCommandResult{}
}

fn quarantine_spec_status_inherit(command base_cask.QuarantineCommand) !base_cask.QuarantineCommandResult {
	if '-p' in command.args {
		return base_cask.QuarantineCommandResult{
			stdout: '0381;6a51855d;;3C86362A-29CA-4D55-90E7-A6621B9CC78D'
		}
	}
	return base_cask.QuarantineCommandResult{}
}

fn quarantine_spec_copy(_ string, _ string) ! {}

fn quarantine_spec_context(run base_cask.QuarantineCommandRunner) base_cask.QuarantineContext {
	return base_cask.QuarantineContext{
		xattr: '/usr/bin/xattr'
		run: run
	}
}

// Translated from Homebrew/brew `test/cask/quarantine_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:klass) { described_class }` at line 7.
pub fn ruby_quarantine_spec_l7_d1_klass(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Cask::Quarantine', 'Cask::Quarantine')
}

// Ruby it `it "uses FFI quarantine support when xattr works" do` at line 14.
pub fn ruby_quarantine_spec_l14_d2_uses(args ...ruby.Value) ruby.Value {
	context := quarantine_spec_context(quarantine_spec_success)
	support := mac_cask.mac_quarantine_check_support(base_cask.quarantine_xattr_available(context))
	return ruby.bool_value(base_cask.quarantine_available(support))
}

// Ruby let `let(:cask) do` at line 27.
pub fn ruby_quarantine_spec_l27_d3_cask(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'url':      ruby.string_value('https://example.com/download')
		'homepage': ruby.string_value('https://example.com')
	})
}

// Ruby it `it "sets the quarantine attribute on a file in a temporary directory" do` at line 35.
pub fn ruby_quarantine_spec_l35_d4_sets(args ...ruby.Value) ruby.Value {
	outcome := mac_cask.mac_quarantine_cask(mac_cask.MacQuarantineCask{
		url: 'https://example.com/download'
		homepage: 'https://example.com'
	}, '/tmp/Test.dmg', true, mac_cask.MacQuarantineFfi{}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(outcome.present && outcome.write.path == '/tmp/Test.dmg' && outcome.write.agent_name == 'Homebrew Cask')
}

// Ruby it `it "raises when the quarantine properties cannot be written" do` at line 52.
pub fn ruby_quarantine_spec_l52_d5_raises(args ...ruby.Value) ruby.Value {
	mac_cask.mac_quarantine_cask(mac_cask.MacQuarantineCask{
		url: 'https://example.com/download'
		homepage: 'https://example.com'
	}, '/tmp/missing.dmg', true, mac_cask.MacQuarantineFfi{
		property_written: false
	}) or {
		return ruby.bool_value(err.msg().contains('Failed to set quarantine properties'))
	}
	return ruby.bool_value(false)
}

// Ruby it `it "uses FFI quarantining by default" do` at line 64.
pub fn ruby_quarantine_spec_l64_d6_uses(args ...ruby.Value) ruby.Value {
	outcome := mac_cask.mac_quarantine_cask(mac_cask.MacQuarantineCask{
		url: 'https://example.com/download'
		homepage: 'https://example.com'
	}, '/tmp/Test.dmg', true, mac_cask.MacQuarantineFfi{}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(outcome.present && outcome.write.data_url == 'https://example.com/download' && outcome.write.origin_url == 'https://example.com')
}

// Ruby it `it "uses FFI when the destination is writable" do` at line 110.
pub fn ruby_quarantine_spec_l110_d7_uses(args ...ruby.Value) ruby.Value {
	plan := mac_cask.mac_quarantine_copy_xattrs('/tmp/Source.app', '/tmp/Destination.app', true, 'ruby', [], '', '/brew/Library/Homebrew', quarantine_spec_copy, quarantine_spec_success) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.executable == '' && !plan.sudo)
}

// Ruby it `it "uses FFI through vendored Ruby when the destination needs sudo" do` at line 125.
pub fn ruby_quarantine_spec_l125_d8_uses(args ...ruby.Value) ruby.Value {
	plan := mac_cask.mac_quarantine_copy_xattrs('/tmp/Source.app', '/tmp/Destination.app', false, '/brew/ruby', [
		'--disable=gems',
	], '/brew/load', '/brew/Library/Homebrew', quarantine_spec_copy, quarantine_spec_success) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.executable == '/brew/ruby' && plan.sudo && plan.args == [
		'--disable=gems',
		'-I',
		'/brew/load',
		'/brew/Library/Homebrew/cask/utils/copy_xattrs.rb',
		'/tmp/Source.app',
		'/tmp/Destination.app',
	])
}

// Ruby it `it "copies extended attributes when run as a standalone script" do` at line 151.
pub fn ruby_quarantine_spec_l151_d9_copies(args ...ruby.Value) ruby.Value {
	mut store := mac_ffi.XattrStore{}
	mac_ffi.set_xattr(mut store, '/tmp/source', 'com.homebrew.test.source', 'source') or {
		return ruby.bool_value(false)
	}
	mac_ffi.copy_xattrs(mut store, '/tmp/source', '/tmp/destination') or {
		return ruby.bool_value(false)
	}
	value := mac_ffi.get_xattr(&store, '/tmp/destination', 'com.homebrew.test.source') or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(value == 'source')
}

// Ruby let `let(:file) { Pathname("/tmp/Test.app") }` at line 176.
pub fn ruby_quarantine_spec_l176_d10_file(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/tmp/Test.app')
}

// Ruby it `it "returns true when the user approval flag is set" do` at line 182.
pub fn ruby_quarantine_spec_l182_d11_returns(args ...ruby.Value) ruby.Value {
	approved := base_cask.quarantine_user_approved('/tmp/Test.app', quarantine_spec_context(quarantine_spec_status_approved)) or { false }
	return ruby.bool_value(approved)
}

// Ruby it `it "returns false when the user approval flag is not set" do` at line 188.
pub fn ruby_quarantine_spec_l188_d12_returns(args ...ruby.Value) ruby.Value {
	approved := base_cask.quarantine_user_approved('/tmp/Test.app', quarantine_spec_context(quarantine_spec_status_unapproved)) or { true }
	return ruby.bool_value(!approved)
}

// Ruby let `let(:file) { Pathname("/tmp/Test.app") }` at line 196.
pub fn ruby_quarantine_spec_l196_d13_file(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/tmp/Test.app')
}

// Ruby let `let(:xattr) { Pathname("/usr/bin/xattr") }` at line 197.
pub fn ruby_quarantine_spec_l197_d14_xattr(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/usr/bin/xattr')
}

// Ruby it `it "sets the user approval flag while preserving the quarantine metadata" do` at line 199.
pub fn ruby_quarantine_spec_l199_d15_sets(args ...ruby.Value) ruby.Value {
	outcome := base_cask.quarantine_inherit_user_approval('/tmp/Test.app', quarantine_spec_context(quarantine_spec_status_inherit)) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(outcome.present && outcome.command.args == ['-w',
		base_cask.quarantine_attribute, '03c1;6a51855d;;3C86362A-29CA-4D55-90E7-A6621B9CC78D',
		'/tmp/Test.app'])
}

// Ruby let `let(:file) { Pathname("/tmp/Test.app") }` at line 221.
pub fn ruby_quarantine_spec_l221_d16_file(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/tmp/Test.app')
}

// Ruby let `let(:requirement) do` at line 222.
pub fn ruby_quarantine_spec_l222_d17_requirement(args ...ruby.Value) ruby.Value {
	return ruby.string_value('identifier "sh.brew.test-app" and anchor apple generic and certificate leaf[subject.OU] = "ABCDE12345"')
}

// Ruby it `it "returns the validated designated requirement without invoking codesign" do` at line 226.
pub fn ruby_quarantine_spec_l226_d18_returns(args ...ruby.Value) ruby.Value {
	requirement := 'identifier "sh.brew.test-app" and anchor apple generic and certificate leaf[subject.OU] = "ABCDE12345"'
	identity := mac_cask.mac_quarantine_signing_identity('/tmp/Test.app', requirement) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(identity.requirement == requirement)
}

// Ruby it `it "returns nil when the signature cannot be verified" do` at line 233.
pub fn ruby_quarantine_spec_l233_d19_returns(args ...ruby.Value) ruby.Value {
	identity := mac_cask.mac_quarantine_signing_identity('/tmp/Test.app', none)
	return ruby.bool_value(identity == none)
}

// Ruby let `let(:file) { Pathname("/tmp/Test.app") }` at line 241.
pub fn ruby_quarantine_spec_l241_d20_file(args ...ruby.Value) ruby.Value {
	return ruby.string_value('/tmp/Test.app')
}

// Ruby let `let(:requirement) { 'identifier "sh.brew.test-app" and anchor apple' }` at line 242.
pub fn ruby_quarantine_spec_l242_d21_requirement(args ...ruby.Value) ruby.Value {
	return ruby.string_value('identifier "sh.brew.test-app" and anchor apple')
}

// Ruby let `let(:identity) { Cask::Quarantine::SigningIdentity.new(requirement:) }` at line 243.
pub fn ruby_quarantine_spec_l243_d22_identity(args ...ruby.Value) ruby.Value {
	requirement := 'identifier "sh.brew.test-app" and anchor apple'
	return ruby.structured_value('SigningIdentity', requirement, {
		'requirement': requirement
	})
}

// Ruby it `it "checks the new app against the previous version's designated requirement" do` at line 245.
pub fn ruby_quarantine_spec_l245_d23_checks(args ...ruby.Value) ruby.Value {
	matched := mac_cask.mac_quarantine_signing_identity_match('/tmp/Test.app', base_cask.QuarantineSigningIdentity{
		requirement: 'identifier "sh.brew.test-app" and anchor apple'
	}, true) or { false }
	return ruby.bool_value(matched)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: RSpec.describe Cask::Quarantine do
// 7:   let(:klass) { described_class }
// 8:
// 9:   describe ".available?", :needs_macos do
// 10:     before do
// 11:       klass.remove_instance_variable(:@quarantine_support) if klass.instance_variable_defined?(:@quarantine_support)
// 12:     end
// 13:
// 14:     it "uses FFI quarantine support when xattr works" do
// 15:       allow(klass).to receive(:xattr).and_return(Pathname("/usr/bin/xattr"))
// 16:       allow(klass).to receive(:system_command)
// 17:         .with(Pathname("/usr/bin/xattr"), args: ["-h"], print_stderr: false)
// 18:         .and_return(instance_double(SystemCommand::Result, success?: true))
// 19:
// 20:       with_env(HOMEBREW_DEVELOPER: nil) do
// 21:         expect(klass.available?).to be(true)
// 22:       end
// 23:     end
// 24:   end
// 25:
// 26:   describe ".cask!", :needs_macos do
// 27:     let(:cask) do
// 28:       instance_double(
// 29:         Cask::Cask,
// 30:         url:      "https://example.com/download",
// 31:         homepage: "https://example.com",
// 32:       )
// 33:     end
// 34:
// 35:     it "sets the quarantine attribute on a file in a temporary directory" do
// 36:       mktmpdir do |tmpdir|
// 37:         download_path = tmpdir/"Test.dmg"
// 38:         download_path.write("test")
// 39:
// 40:         expect(klass.status(download_path)).to eq("")
// 41:
// 42:         with_env(HOMEBREW_DEVELOPER: nil) do
// 43:           klass.cask!(cask:, download_path:)
// 44:         end
// 45:
// 46:         expect(klass.status(download_path)).to match(
// 47:           /\A[0-9a-f]{4};[0-9a-f]+;(?:Homebrew\\x20Cask)?;[0-9A-F-]{36}\z/i,
// 48:         )
// 49:       end
// 50:     end
// 51:
// 52:     it "raises when the quarantine properties cannot be written" do
// 53:       mktmpdir do |tmpdir|
// 54:         download_path = tmpdir/"missing.dmg"
// 55:
// 56:         expect do
// 57:           with_env(HOMEBREW_DEVELOPER: nil) do
// 58:             klass.cask!(cask:, download_path:)
// 59:           end
// 60:         end.to raise_error(Cask::CaskQuarantineError, /Failed to set quarantine properties/)
// 61:       end
// 62:     end
// 63:
// 64:     it "uses FFI quarantining by default" do
// 65:       require "os/mac/ffi"
// 66:
// 67:       download_path = Pathname("/tmp/Test.dmg")
// 68:       path = instance_double(Fiddle::Pointer, null?: false)
// 69:       url = instance_double(Fiddle::Pointer, null?: false)
// 70:       agent_name = instance_double(Fiddle::Pointer, null?: false)
// 71:       data_url = instance_double(Fiddle::Pointer, null?: false)
// 72:       origin_url = instance_double(Fiddle::Pointer, null?: false)
// 73:       dictionary = instance_double(Fiddle::Pointer, null?: false)
// 74:       quarantine_properties_key = instance_double(Fiddle::Pointer)
// 75:
// 76:       allow(klass).to receive(:detect).with(download_path).and_return(false)
// 77:       allow(MacOS::FFI::CoreFoundation).to receive(:string_create).with(download_path.to_s).and_return(path)
// 78:       allow(MacOS::FFI::CoreFoundation).to receive(:url_create_with_file_system_path).with(path).and_return(url)
// 79:       allow(MacOS::FFI::CoreFoundation).to receive(:string_create).with("Homebrew Cask").and_return(agent_name)
// 80:       allow(MacOS::FFI::CoreFoundation).to receive(:string_create).with("https://example.com/download")
// 81:                                                                   .and_return(data_url)
// 82:       allow(MacOS::FFI::CoreFoundation).to receive(:string_create).with("https://example.com")
// 83:                                                                   .and_return(origin_url)
// 84:       allow(MacOS::FFI::LaunchServices).to receive_messages(
// 85:         quarantine_agent_name_key:    instance_double(Fiddle::Pointer),
// 86:         quarantine_type_key:          instance_double(Fiddle::Pointer),
// 87:         quarantine_type_web_download: instance_double(Fiddle::Pointer),
// 88:         quarantine_data_url_key:      instance_double(Fiddle::Pointer),
// 89:         quarantine_origin_url_key:    instance_double(Fiddle::Pointer),
// 90:       )
// 91:       expect(MacOS::FFI::CoreFoundation).to receive(:dictionary_create).with(
// 92:         MacOS::FFI::LaunchServices.quarantine_agent_name_key => agent_name,
// 93:         MacOS::FFI::LaunchServices.quarantine_type_key       => MacOS::FFI::LaunchServices.quarantine_type_web_download,
// 94:         MacOS::FFI::LaunchServices.quarantine_data_url_key   => data_url,
// 95:         MacOS::FFI::LaunchServices.quarantine_origin_url_key => origin_url,
// 96:       ).and_return(dictionary)
// 97:       allow(MacOS::FFI::CoreFoundation).to receive(:url_quarantine_properties_key)
// 98:         .and_return(quarantine_properties_key)
// 99:       expect(MacOS::FFI::CoreFoundation).to receive(:url_set_resource_property_for_key)
// 100:         .with(url, quarantine_properties_key, dictionary)
// 101:         .and_return(true)
// 102:
// 103:       with_env(HOMEBREW_DEVELOPER: nil) do
// 104:         klass.cask!(cask:, download_path:)
// 105:       end
// 106:     end
// 107:   end
// 108:
// 109:   describe ".copy_xattrs", :needs_macos do
// 110:     it "uses FFI when the destination is writable" do
// 111:       require "os/mac/ffi"
// 112:
// 113:       source = Pathname("/tmp/Source.app")
// 114:       destination = Pathname("/tmp/Destination.app")
// 115:       command = class_double(SystemCommand)
// 116:
// 117:       allow(destination).to receive(:writable?).and_return(true)
// 118:       expect(MacOS::FFI).to receive(:copy_xattrs).with(source.to_s, destination.to_s)
// 119:
// 120:       with_env(HOMEBREW_DEVELOPER: nil) do
// 121:         klass.copy_xattrs(source, destination, command:)
// 122:       end
// 123:     end
// 124:
// 125:     it "uses FFI through vendored Ruby when the destination needs sudo" do
// 126:       require "os/mac/ffi"
// 127:
// 128:       source = Pathname("/tmp/Source.app")
// 129:       destination = Pathname("/tmp/Destination.app")
// 130:       command = class_double(SystemCommand)
// 131:       ruby, *args = HOMEBREW_RUBY_EXEC_ARGS
// 132:
// 133:       allow(destination).to receive(:writable?).and_return(false)
// 134:       expect(command).to receive(:run!).with(
// 135:         ruby,
// 136:         args: args + [
// 137:           "-I",
// 138:           $LOAD_PATH.join(File::PATH_SEPARATOR),
// 139:           OS::Mac::Cask::Quarantine::COPY_XATTRS_SCRIPT,
// 140:           source,
// 141:           destination,
// 142:         ],
// 143:         sudo: true,
// 144:       )
// 145:
// 146:       with_env(HOMEBREW_DEVELOPER: nil) do
// 147:         klass.copy_xattrs(source, destination, command:)
// 148:       end
// 149:     end
// 150:
// 151:     it "copies extended attributes when run as a standalone script" do
// 152:       require "os/mac/ffi"
// 153:
// 154:       mktmpdir do |tmpdir|
// 155:         source = tmpdir/"source"
// 156:         destination = tmpdir/"destination"
// 157:         source.write("source")
// 158:         destination.write("destination")
// 159:         MacOS::FFI.set_xattr(source.to_s, "com.homebrew.test.source", "source")
// 160:
// 161:         _, stderr, status = Open3.capture3(
// 162:           *HOMEBREW_RUBY_EXEC_ARGS,
// 163:           "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 164:           OS::Mac::Cask::Quarantine::COPY_XATTRS_SCRIPT.to_s,
// 165:           source.to_s,
// 166:           destination.to_s
// 167:         )
// 168:
// 169:         expect(status).to be_success, stderr
// 170:         expect(MacOS::FFI.get_xattr(destination.to_s, "com.homebrew.test.source")).to eq("source")
// 171:       end
// 172:     end
// 173:   end
// 174:
// 175:   describe ".user_approved?" do
// 176:     let(:file) { Pathname("/tmp/Test.app") }
// 177:
// 178:     before do
// 179:       allow(klass).to receive(:xattr).and_return(Pathname("/usr/bin/xattr"))
// 180:     end
// 181:
// 182:     it "returns true when the user approval flag is set" do
// 183:       allow(klass).to receive(:status).with(file).and_return("01c3;6723b9fa;Safari;event-id")
// 184:
// 185:       expect(klass.user_approved?(file)).to be(true)
// 186:     end
// 187:
// 188:     it "returns false when the user approval flag is not set" do
// 189:       allow(klass).to receive(:status).with(file).and_return("0183;6723b9fa;Safari;event-id")
// 190:
// 191:       expect(klass.user_approved?(file)).to be(false)
// 192:     end
// 193:   end
// 194:
// 195:   describe ".inherit_user_approval!" do
// 196:     let(:file) { Pathname("/tmp/Test.app") }
// 197:     let(:xattr) { Pathname("/usr/bin/xattr") }
// 198:
// 199:     it "sets the user approval flag while preserving the quarantine metadata" do
// 200:       allow(klass).to receive_messages(
// 201:         detect: true,
// 202:         status: "0381;6a51855d;;3C86362A-29CA-4D55-90E7-A6621B9CC78D",
// 203:         xattr:,
// 204:       )
// 205:       expect(klass).to receive(:system_command).with(
// 206:         xattr,
// 207:         args:         [
// 208:           "-w",
// 209:           Cask::Quarantine::QUARANTINE_ATTRIBUTE,
// 210:           "03c1;6a51855d;;3C86362A-29CA-4D55-90E7-A6621B9CC78D",
// 211:           file,
// 212:         ],
// 213:         print_stderr: false,
// 214:       ).and_return(instance_double(SystemCommand::Result, success?: true))
// 215:
// 216:       klass.inherit_user_approval!(download_path: file)
// 217:     end
// 218:   end
// 219:
// 220:   describe ".signing_identity", :needs_macos do
// 221:     let(:file) { Pathname("/tmp/Test.app") }
// 222:     let(:requirement) do
// 223:       'identifier "sh.brew.test-app" and anchor apple generic and certificate leaf[subject.OU] = "ABCDE12345"'
// 224:     end
// 225:
// 226:     it "returns the validated designated requirement without invoking codesign" do
// 227:       allow(MacOS::FFI::Security).to receive(:designated_requirement).with(file.to_s).and_return(requirement)
// 228:       expect(klass).not_to receive(:system_command)
// 229:
// 230:       expect(klass.signing_identity(file)).to have_attributes(requirement:)
// 231:     end
// 232:
// 233:     it "returns nil when the signature cannot be verified" do
// 234:       allow(MacOS::FFI::Security).to receive(:designated_requirement).with(file.to_s).and_return(nil)
// 235:
// 236:       expect(klass.signing_identity(file)).to be_nil
// 237:     end
// 238:   end
// 239:
// 240:   describe ".signing_identity_match", :needs_macos do
// 241:     let(:file) { Pathname("/tmp/Test.app") }
// 242:     let(:requirement) { 'identifier "sh.brew.test-app" and anchor apple' }
// 243:     let(:identity) { Cask::Quarantine::SigningIdentity.new(requirement:) }
// 244:
// 245:     it "checks the new app against the previous version's designated requirement" do
// 246:       expect(MacOS::FFI::Security).to receive(:requirement_match).with(file.to_s, requirement).and_return(true)
// 247:
// 248:       expect(klass.signing_identity_match(file, identity)).to be(true)
// 249:     end
// 250:   end
// 251: end
