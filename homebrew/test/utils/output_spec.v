module utils

import brew_runtime
import homebrew.utils as brew_utils

fn output_spec_options(stream_is_tty bool, no_emoji bool) brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty:      brew_utils.TtyState{
			stream_is_tty: stream_is_tty
		}
		no_emoji: no_emoji
	}
}

// Translated from Homebrew/brew `test/utils/output_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `esc(code)` at line 8.
pub fn ruby_output_spec_l8_d1_esc(args ...brew_runtime.Value) brew_runtime.Value {
	code := if args.len > 0 { args[0].as_int() or { 0 } } else { 0 }
	return brew_runtime.string_value('\x1b[${code}m')
}

// Ruby subject `subject(:pretty_installed_output) { described_class.pretty_installed("foo") }` at line 13.
pub fn ruby_output_spec_l13_d2_pretty_installed_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(brew_utils.pretty_installed('foo', output_spec_options(true,
		false)))
}

// Ruby it `it "returns a string with a colored checkmark" do` at line 19.
pub fn ruby_output_spec_l19_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_installed('foo', output_spec_options(true, false))
	return brew_runtime.bool_value(output.contains('\x1b[1mfoo ') && output.contains('\x1b[32m✔')
		&& output.contains('\x1b[0m'))
}

// Ruby it `it "returns a string with colored info" do` at line 28.
pub fn ruby_output_spec_l28_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_installed('foo', output_spec_options(true, true))
	return brew_runtime.bool_value(
		output.contains('\x1b[1mfoo (installed)') && output.contains('\x1b[0m'))
}

// Ruby it `it "returns plain text" do` at line 38.
pub fn ruby_output_spec_l38_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_installed('foo', output_spec_options(false,
		false)) == 'foo')
}

// Ruby it `it "returns a bold string with a colored up arrow by default" do` at line 48.
pub fn ruby_output_spec_l48_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_upgradable('foo', true, output_spec_options(true, false))
	return brew_runtime.bool_value(output.starts_with('\x1b[1mfoo ')
		&& output.contains('\x1b[32m↑'))
}

// Ruby it `it "omits the bold escape when bold is false" do` at line 52.
pub fn ruby_output_spec_l52_d7_omits(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_upgradable('foo', false, output_spec_options(true, false))
	return brew_runtime.bool_value(output.starts_with('foo ') && output.contains('\x1b[32m↑'))
}

// Ruby it `it "returns plain text" do` at line 60.
pub fn ruby_output_spec_l60_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_upgradable('foo', false, output_spec_options(false,
		false)) == 'foo')
}

// Ruby subject `subject(:pretty_uninstalled_output) { described_class.pretty_uninstalled("foo") }` at line 67.
pub fn ruby_output_spec_l67_d9_pretty_uninstalled_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(brew_utils.pretty_uninstalled('foo', true, output_spec_options(true,
		false)))
}

// Ruby it `it "returns a string with a colored checkmark" do` at line 73.
pub fn ruby_output_spec_l73_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_uninstalled('foo', true, output_spec_options(true, false))
	return brew_runtime.bool_value(output.contains('\x1b[1mfoo ') && output.contains('\x1b[31m✘'))
}

// Ruby it `it "returns a string with colored info" do` at line 82.
pub fn ruby_output_spec_l82_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_uninstalled('foo', true, output_spec_options(true, true))
	return brew_runtime.bool_value(
		output.contains('\x1b[1mfoo (uninstalled)') && output.contains('\x1b[0m'))
}

// Ruby it `it "returns plain text" do` at line 92.
pub fn ruby_output_spec_l92_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_uninstalled('foo', true, output_spec_options(false,
		false)) == 'foo')
}

// Ruby it `it "returns a bold string" do` at line 102.
pub fn ruby_output_spec_l102_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_unmarked('foo', true, output_spec_options(true,
		false)) == '\x1b[1mfoo\x1b[0m')
}

// Ruby it `it "returns plain text" do` at line 110.
pub fn ruby_output_spec_l110_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_unmarked('foo', true, output_spec_options(false,
		false)) == 'foo')
}

// Ruby it `it "bolds an uninstalled string when bold is true" do` at line 119.
pub fn ruby_output_spec_l119_d15_bolds(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_install_status('foo', brew_utils.InstallStatusOptions{
		installed:        false
		mark_uninstalled: false
		bold:             true
	}, output_spec_options(true, false))
	return brew_runtime.bool_value(output == '\x1b[1mfoo\x1b[0m')
}

// Ruby it `it "leaves an uninstalled string plain when bold is unset" do` at line 124.
pub fn ruby_output_spec_l124_d16_leaves(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_install_status('foo', brew_utils.InstallStatusOptions{
		installed:        false
		mark_uninstalled: false
	}, output_spec_options(true, false))
	return brew_runtime.bool_value(output == 'foo')
}

// Ruby it `it "bolds an installed entry when bold is unset" do` at line 128.
pub fn ruby_output_spec_l128_d17_bolds(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_install_status('foo', brew_utils.InstallStatusOptions{
		installed: true
		outdated:  true
	}, output_spec_options(true, false))
	return brew_runtime.bool_value(output.starts_with('\x1b[1mfoo ')
		&& output.contains('\x1b[32m↑'))
}

// Ruby it `it "omits the bold escape on every entry when bold is false" do` at line 133.
pub fn ruby_output_spec_l133_d18_omits(args ...brew_runtime.Value) brew_runtime.Value {
	output := brew_utils.pretty_install_status('foo', brew_utils.InstallStatusOptions{
		installed: true
		outdated:  true
		bold:      false
	}, output_spec_options(true, false))
	return brew_runtime.bool_value(output.starts_with('foo ') && output.contains('\x1b[32m↑'))
}

// Ruby subject `subject(:pretty_deprecated_output) { described_class.pretty_deprecated("foo") }` at line 140.
pub fn ruby_output_spec_l140_d19_pretty_deprecated_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(brew_utils.pretty_deprecated('foo', output_spec_options(true,
		false)))
}

// Ruby it `it "returns a string with a colored (deprecated) label" do` at line 145.
pub fn ruby_output_spec_l145_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_deprecated('foo', output_spec_options(true,
		false)).contains('foo \x1b[33m(deprecated)\x1b[0m'))
}

// Ruby it `it "returns plain text" do` at line 154.
pub fn ruby_output_spec_l154_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_deprecated('foo', output_spec_options(false,
		false)) == 'foo')
}

// Ruby subject `subject(:pretty_disabled_output) { described_class.pretty_disabled("foo") }` at line 161.
pub fn ruby_output_spec_l161_d22_pretty_disabled_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(brew_utils.pretty_disabled('foo', output_spec_options(true,
		false)))
}

// Ruby it `it "returns a string with a colored (disabled) label" do` at line 166.
pub fn ruby_output_spec_l166_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_disabled('foo', output_spec_options(true,
		false)).contains('foo \x1b[31m(disabled)\x1b[0m'))
}

// Ruby it `it "returns plain text" do` at line 175.
pub fn ruby_output_spec_l175_d24_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(brew_utils.pretty_disabled('foo', output_spec_options(false,
		false)) == 'foo')
}

// Ruby it `it "converts seconds to a human-readable string" do` at line 182.
pub fn ruby_output_spec_l182_d25_converts(args ...brew_runtime.Value) brew_runtime.Value {
	examples := {
		'1':      '1 second'
		'2.5':    '2 seconds'
		'42':     '42 seconds'
		'240':    '4 minutes'
		'252.45': '4 minutes 12 seconds'
		'300':    '5 minutes'
		'365':    '6 minutes'
		'3600':   '1 hour'
		'3660':   '1 hour 1 minute'
		'73085':  '20 hours 18 minutes'
	}
	for seconds, expected in examples {
		if brew_utils.pretty_duration(seconds.f64()) != expected {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "sets Homebrew.failed to true" do` at line 197.
pub fn ruby_output_spec_l197_d26_sets(args ...brew_runtime.Value) brew_runtime.Value {
	result := brew_utils.output_fail('foo', output_spec_options(false, false))
	return brew_runtime.bool_value(result.failed && result.message == 'Error: foo')
}

// Ruby it `it "prints a warning without a GitHub Actions annotation" do` at line 207.
pub fn ruby_output_spec_l207_d27_prints(args ...brew_runtime.Value) brew_runtime.Value {
	options := brew_utils.OutputOptions{
		tty:            brew_utils.TtyState{}
		github_actions: true
	}
	return brew_runtime.bool_value(brew_utils.output_warning_without_annotation('foo', options) == 'Warning: foo')
}

// Ruby it `it "exits with 1" do` at line 219.
pub fn ruby_output_spec_l219_d28_exits(args ...brew_runtime.Value) brew_runtime.Value {
	exit_value := brew_utils.ruby_output_l151_d12_odie(brew_runtime.string_value('foo'))
	return brew_runtime.bool_value(exit_value.type_name == 'SystemExit' && (exit_value.attribute('exit_code') or {
		''
	}) == '1' && exit_value.as_string().contains('Error: foo'))
}

// Ruby it `it "raises a MethodDeprecatedError when `disable` is true" do` at line 227.
pub fn ruby_output_spec_l227_d29_raises(args ...brew_runtime.Value) brew_runtime.Value {
	if _ := brew_utils.output_deprecated('method', brew_utils.DeprecationOptions{
		replacement: 'replacement'
		disable:     true
		caller:      ['/Library/Taps/playbrew/homebrew-play/formula.rb:12']
	}, output_spec_options(false, false))
	{
		return brew_runtime.bool_value(false)
	} else {
		return brew_runtime.bool_value(err.msg().contains('method')
			&& err.msg().contains('replacement') && err.msg().contains('playbrew/homebrew-play')
			&& err.msg().contains('/Taps/playbrew/homebrew-play/'))
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5: require "utils/github/actions"
// 6:
// 7: RSpec.describe Utils::Output do
// 8:   def esc(code)
// 9:     /(\e\[\d+m)*\e\[#{code}m/
// 10:   end
// 11:
// 12:   describe "#pretty_installed" do
// 13:     subject(:pretty_installed_output) { described_class.pretty_installed("foo") }
// 14:
// 15:     context "when $stdout is a TTY" do
// 16:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 17:
// 18:       context "with HOMEBREW_NO_EMOJI unset" do
// 19:         it "returns a string with a colored checkmark" do
// 20:           expect(pretty_installed_output)
// 21:             .to match(/#{esc 1}foo #{esc 32}✔#{esc 0}/)
// 22:         end
// 23:       end
// 24:
// 25:       context "with HOMEBREW_NO_EMOJI set" do
// 26:         before { ENV["HOMEBREW_NO_EMOJI"] = "1" }
// 27:
// 28:         it "returns a string with colored info" do
// 29:           expect(pretty_installed_output)
// 30:             .to match(/#{esc 1}foo \(installed\)#{esc 0}/)
// 31:         end
// 32:       end
// 33:     end
// 34:
// 35:     context "when $stdout is not a TTY" do
// 36:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 37:
// 38:       it "returns plain text" do
// 39:         expect(pretty_installed_output).to eq("foo")
// 40:       end
// 41:     end
// 42:   end
// 43:
// 44:   describe "#pretty_upgradable" do
// 45:     context "when $stdout is a TTY" do
// 46:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 47:
// 48:       it "returns a bold string with a colored up arrow by default" do
// 49:         expect(described_class.pretty_upgradable("foo")).to match(/#{esc 1}foo #{esc 32}↑#{esc 0}/)
// 50:       end
// 51:
// 52:       it "omits the bold escape when bold is false" do
// 53:         expect(described_class.pretty_upgradable("foo", bold: false)).to match(/\Afoo #{esc 32}↑#{esc 0}/)
// 54:       end
// 55:     end
// 56:
// 57:     context "when $stdout is not a TTY" do
// 58:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 59:
// 60:       it "returns plain text" do
// 61:         expect(described_class.pretty_upgradable("foo", bold: false)).to eq("foo")
// 62:       end
// 63:     end
// 64:   end
// 65:
// 66:   describe "#pretty_uninstalled" do
// 67:     subject(:pretty_uninstalled_output) { described_class.pretty_uninstalled("foo") }
// 68:
// 69:     context "when $stdout is a TTY" do
// 70:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 71:
// 72:       context "with HOMEBREW_NO_EMOJI unset" do
// 73:         it "returns a string with a colored checkmark" do
// 74:           expect(pretty_uninstalled_output)
// 75:             .to match(/#{esc 1}foo #{esc 31}✘#{esc 0}/)
// 76:         end
// 77:       end
// 78:
// 79:       context "with HOMEBREW_NO_EMOJI set" do
// 80:         before { ENV["HOMEBREW_NO_EMOJI"] = "1" }
// 81:
// 82:         it "returns a string with colored info" do
// 83:           expect(pretty_uninstalled_output)
// 84:             .to match(/#{esc 1}foo \(uninstalled\)#{esc 0}/)
// 85:         end
// 86:       end
// 87:     end
// 88:
// 89:     context "when $stdout is not a TTY" do
// 90:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 91:
// 92:       it "returns plain text" do
// 93:         expect(pretty_uninstalled_output).to eq("foo")
// 94:       end
// 95:     end
// 96:   end
// 97:
// 98:   describe "#pretty_unmarked" do
// 99:     context "when $stdout is a TTY" do
// 100:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 101:
// 102:       it "returns a bold string" do
// 103:         expect(described_class.pretty_unmarked("foo")).to match(/\A#{esc 1}foo#{esc 0}\z/)
// 104:       end
// 105:     end
// 106:
// 107:     context "when $stdout is not a TTY" do
// 108:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 109:
// 110:       it "returns plain text" do
// 111:         expect(described_class.pretty_unmarked("foo")).to eq("foo")
// 112:       end
// 113:     end
// 114:   end
// 115:
// 116:   describe "#pretty_install_status" do
// 117:     before { allow($stdout).to receive(:tty?).and_return(true) }
// 118:
// 119:     it "bolds an uninstalled string when bold is true" do
// 120:       expect(described_class.pretty_install_status("foo", installed: false, mark_uninstalled: false, bold: true))
// 121:         .to match(/\A#{esc 1}foo#{esc 0}\z/)
// 122:     end
// 123:
// 124:     it "leaves an uninstalled string plain when bold is unset" do
// 125:       expect(described_class.pretty_install_status("foo", installed: false, mark_uninstalled: false)).to eq("foo")
// 126:     end
// 127:
// 128:     it "bolds an installed entry when bold is unset" do
// 129:       expect(described_class.pretty_install_status("foo", installed: true, outdated: true))
// 130:         .to match(/\A#{esc 1}foo #{esc 32}↑#{esc 0}/)
// 131:     end
// 132:
// 133:     it "omits the bold escape on every entry when bold is false" do
// 134:       expect(described_class.pretty_install_status("foo", installed: true, outdated: true, bold: false))
// 135:         .to match(/\Afoo #{esc 32}↑#{esc 0}/)
// 136:     end
// 137:   end
// 138:
// 139:   describe "#pretty_deprecated" do
// 140:     subject(:pretty_deprecated_output) { described_class.pretty_deprecated("foo") }
// 141:
// 142:     context "when $stdout is a TTY" do
// 143:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 144:
// 145:       it "returns a string with a colored (deprecated) label" do
// 146:         expect(pretty_deprecated_output)
// 147:           .to match(/foo #{esc 33}\(deprecated\)#{esc 0}/)
// 148:       end
// 149:     end
// 150:
// 151:     context "when $stdout is not a TTY" do
// 152:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 153:
// 154:       it "returns plain text" do
// 155:         expect(pretty_deprecated_output).to eq("foo")
// 156:       end
// 157:     end
// 158:   end
// 159:
// 160:   describe "#pretty_disabled" do
// 161:     subject(:pretty_disabled_output) { described_class.pretty_disabled("foo") }
// 162:
// 163:     context "when $stdout is a TTY" do
// 164:       before { allow($stdout).to receive(:tty?).and_return(true) }
// 165:
// 166:       it "returns a string with a colored (disabled) label" do
// 167:         expect(pretty_disabled_output)
// 168:           .to match(/foo #{esc 31}\(disabled\)#{esc 0}/)
// 169:       end
// 170:     end
// 171:
// 172:     context "when $stdout is not a TTY" do
// 173:       before { allow($stdout).to receive(:tty?).and_return(false) }
// 174:
// 175:       it "returns plain text" do
// 176:         expect(pretty_disabled_output).to eq("foo")
// 177:       end
// 178:     end
// 179:   end
// 180:
// 181:   describe "#pretty_duration" do
// 182:     it "converts seconds to a human-readable string" do
// 183:       expect(described_class.pretty_duration(1)).to eq("1 second")
// 184:       expect(described_class.pretty_duration(2.5)).to eq("2 seconds")
// 185:       expect(described_class.pretty_duration(42)).to eq("42 seconds")
// 186:       expect(described_class.pretty_duration(240)).to eq("4 minutes")
// 187:       expect(described_class.pretty_duration(252.45)).to eq("4 minutes 12 seconds")
// 188:       expect(described_class.pretty_duration(300)).to eq("5 minutes")
// 189:       expect(described_class.pretty_duration(365)).to eq("6 minutes")
// 190:       expect(described_class.pretty_duration(3600)).to eq("1 hour")
// 191:       expect(described_class.pretty_duration(3660)).to eq("1 hour 1 minute")
// 192:       expect(described_class.pretty_duration(73_085)).to eq("20 hours 18 minutes")
// 193:     end
// 194:   end
// 195:
// 196:   describe "#ofail" do
// 197:     it "sets Homebrew.failed to true" do
// 198:       expect do
// 199:         described_class.ofail "foo"
// 200:       end.to output("Error: foo\n").to_stderr
// 201:
// 202:       expect(Homebrew).to have_failed
// 203:     end
// 204:   end
// 205:
// 206:   describe "#opoo_without_github_actions_annotation" do
// 207:     it "prints a warning without a GitHub Actions annotation" do
// 208:       with_env(GITHUB_ACTIONS: "true") do
// 209:         expect(GitHub::Actions).not_to receive(:puts_annotation_if_env_set!)
// 210:
// 211:         expect do
// 212:           described_class.opoo_without_github_actions_annotation "foo"
// 213:         end.to output("Warning: foo\n").to_stderr
// 214:       end
// 215:     end
// 216:   end
// 217:
// 218:   describe "#odie" do
// 219:     it "exits with 1" do
// 220:       expect do
// 221:         described_class.odie "foo"
// 222:       end.to output("Error: foo\n").to_stderr.and raise_error SystemExit
// 223:     end
// 224:   end
// 225:
// 226:   describe "#odeprecated" do
// 227:     it "raises a MethodDeprecatedError when `disable` is true" do
// 228:       ENV.delete("HOMEBREW_DEVELOPER")
// 229:       expect do
// 230:         described_class.odeprecated(
// 231:           "method", "replacement",
// 232:           caller:  ["#{HOMEBREW_LIBRARY}/Taps/playbrew/homebrew-play/"],
// 233:           disable: true
// 234:         )
// 235:       end.to raise_error(
// 236:         MethodDeprecatedError,
// 237:         %r{method.*replacement.*playbrew/homebrew-play.*/Taps/playbrew/homebrew-play/}m,
// 238:       )
// 239:     end
// 240:   end
// 241: end
