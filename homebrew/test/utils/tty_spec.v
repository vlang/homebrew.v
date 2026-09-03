module utils

import homebrew.utils as hb_utils

// Translated from Homebrew/brew `test/utils/tty_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "removes ANSI escape codes from a string" do` at line 6.
pub fn ruby_tty_spec_l6_d1_removes() bool {
	return hb_utils.tty_strip_ansi('\x1b[36;7mhello\x1b[0m') == 'hello'
}

// Ruby it `it "keeps only the final segment of a carriage-return-delimited progress bar" do` at line 12.
pub fn ruby_tty_spec_l12_d2_keeps() bool {
	return hb_utils.tty_collapse_carriage_returns('#\r##\r### 100%') == '### 100%'
}

// Ruby it `it "collapses carriage returns independently on each real line" do` at line 16.
pub fn ruby_tty_spec_l16_d3_collapses() bool {
	return hb_utils.tty_collapse_carriage_returns('a\rb\nc\rd') == 'b\nd'
}

// Ruby it `it "returns the string unchanged when it has no carriage returns" do` at line 20.
pub fn ruby_tty_spec_l20_d4_returns() bool {
	input := "curl: (7) Couldn't connect to server"
	return hb_utils.tty_collapse_carriage_returns(input) == input
}

// Ruby it `it "keeps the last written content when the string ends with a trailing carriage return" do` at line 26.
pub fn ruby_tty_spec_l26_d5_keeps() bool {
	return hb_utils.tty_collapse_carriage_returns('### 50%\r') == '### 50%'
}

// Ruby it `it "returns the DEC private mode 2026 set sequence" do` at line 32.
pub fn ruby_tty_spec_l32_d6_returns() bool {
	return hb_utils.tty_begin_synchronized_update() == '\x1b[?2026h'
}

// Ruby it `it "returns the DEC private mode 2026 reset sequence" do` at line 38.
pub fn ruby_tty_spec_l38_d7_returns() bool {
	return hb_utils.tty_end_synchronized_update() == '\x1b[?2026l'
}

// Ruby specify `specify do` at line 44.
pub fn ruby_tty_spec_l44_d8_do() bool {
	return hb_utils.tty_width() >= 0
}

// Ruby it `it "truncates the text to the terminal width, minus 4, to account for '==> '" do` at line 51.
pub fn ruby_tty_spec_l51_d9_truncates() bool {
	return hb_utils.tty_truncate('foobar something very long', 15) == 'foobar some' && hb_utils.tty_truncate('truncate', 15) == 'truncate'
}

// Ruby it `it "doesn't truncate the text if the terminal is unsupported, i.e. the width is 0" do` at line 58.
pub fn ruby_tty_spec_l58_d10_doesn() bool {
	input := 'foobar something very long'
	return hb_utils.tty_truncate(input, 0) == input
}

fn tty_spec_color_codes(state hb_utils.TtyState) []string {
	mut codes := []string{}
	for name in ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'default'] {
		mut colored := state
		colored.escape_sequence = state.escape_sequence.clone()
		colored.add_code(name) or { return []string{} }
		codes << colored.str()
	}
	return codes
}

// Ruby it `it "returns an empty string for all colors" do` at line 69.
pub fn ruby_tty_spec_l69_d11_returns() bool {
	state := hb_utils.TtyState{
		stream_is_tty: false
	}
	return state.current_escape_sequence() == '' && tty_spec_color_codes(state) == ['', '', '',
		'', '', '', '']
}

// Ruby it `it "returns ANSI escape codes for colors" do` at line 86.
pub fn ruby_tty_spec_l86_d12_returns() bool {
	state := hb_utils.TtyState{
		stream_is_tty: true
	}
	return state.current_escape_sequence() == '' && tty_spec_color_codes(state) == [
		'\x1b[31m',
		'\x1b[32m',
		'\x1b[33m',
		'\x1b[34m',
		'\x1b[35m',
		'\x1b[36m',
		'\x1b[39m',
	]
}

// Ruby it `it "returns an empty string for all colors when HOMEBREW_NO_COLOR is set" do` at line 97.
pub fn ruby_tty_spec_l97_d13_returns() bool {
	state := hb_utils.TtyState{
		stream_is_tty: true
		no_color: true
	}
	return state.current_escape_sequence() == '' && tty_spec_color_codes(state) == ['', '', '',
		'', '', '', '']
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Tty do
// 5:   describe "::strip_ansi" do
// 6:     it "removes ANSI escape codes from a string" do
// 7:       expect(described_class.strip_ansi("\033[36;7mhello\033[0m")).to eq("hello")
// 8:     end
// 9:   end
// 10:
// 11:   describe "::collapse_carriage_returns" do
// 12:     it "keeps only the final segment of a carriage-return-delimited progress bar" do
// 13:       expect(described_class.collapse_carriage_returns("#\r##\r### 100%")).to eq("### 100%")
// 14:     end
// 15:
// 16:     it "collapses carriage returns independently on each real line" do
// 17:       expect(described_class.collapse_carriage_returns("a\rb\nc\rd")).to eq("b\nd")
// 18:     end
// 19:
// 20:     it "returns the string unchanged when it has no carriage returns" do
// 21:       expect(described_class.collapse_carriage_returns("curl: (7) Couldn't connect to server")).to(
// 22:         eq("curl: (7) Couldn't connect to server"),
// 23:       )
// 24:     end
// 25:
// 26:     it "keeps the last written content when the string ends with a trailing carriage return" do
// 27:       expect(described_class.collapse_carriage_returns("### 50%\r")).to eq("### 50%")
// 28:     end
// 29:   end
// 30:
// 31:   describe "::begin_synchronized_update" do
// 32:     it "returns the DEC private mode 2026 set sequence" do
// 33:       expect(described_class.begin_synchronized_update).to eq("\033[?2026h")
// 34:     end
// 35:   end
// 36:
// 37:   describe "::end_synchronized_update" do
// 38:     it "returns the DEC private mode 2026 reset sequence" do
// 39:       expect(described_class.end_synchronized_update).to eq("\033[?2026l")
// 40:     end
// 41:   end
// 42:
// 43:   describe "::width" do
// 44:     specify do
// 45:       expect(described_class.width).to be_a(Integer)
// 46:       expect(described_class.width).to be >= 0
// 47:     end
// 48:   end
// 49:
// 50:   describe "::truncate" do
// 51:     it "truncates the text to the terminal width, minus 4, to account for '==> '" do
// 52:       allow(described_class).to receive(:width).and_return(15)
// 53:
// 54:       expect(described_class.truncate("foobar something very long")).to eq("foobar some")
// 55:       expect(described_class.truncate("truncate")).to eq("truncate")
// 56:     end
// 57:
// 58:     it "doesn't truncate the text if the terminal is unsupported, i.e. the width is 0" do
// 59:       allow(described_class).to receive(:width).and_return(0)
// 60:       expect(described_class.truncate("foobar something very long")).to eq("foobar something very long")
// 61:     end
// 62:   end
// 63:
// 64:   context "when $stdout is not a TTY" do
// 65:     before do
// 66:       allow($stdout).to receive(:tty?).and_return(false)
// 67:     end
// 68:
// 69:     it "returns an empty string for all colors" do
// 70:       expect(described_class.to_s).to eq("")
// 71:       expect(described_class.red.to_s).to eq("")
// 72:       expect(described_class.green.to_s).to eq("")
// 73:       expect(described_class.yellow.to_s).to eq("")
// 74:       expect(described_class.blue.to_s).to eq("")
// 75:       expect(described_class.magenta.to_s).to eq("")
// 76:       expect(described_class.cyan.to_s).to eq("")
// 77:       expect(described_class.default.to_s).to eq("")
// 78:     end
// 79:   end
// 80:
// 81:   context "when $stdout is a TTY" do
// 82:     before do
// 83:       allow($stdout).to receive(:tty?).and_return(true)
// 84:     end
// 85:
// 86:     it "returns ANSI escape codes for colors" do
// 87:       expect(described_class.to_s).to eq("")
// 88:       expect(described_class.red.to_s).to eq("\033[31m")
// 89:       expect(described_class.green.to_s).to eq("\033[32m")
// 90:       expect(described_class.yellow.to_s).to eq("\033[33m")
// 91:       expect(described_class.blue.to_s).to eq("\033[34m")
// 92:       expect(described_class.magenta.to_s).to eq("\033[35m")
// 93:       expect(described_class.cyan.to_s).to eq("\033[36m")
// 94:       expect(described_class.default.to_s).to eq("\033[39m")
// 95:     end
// 96:
// 97:     it "returns an empty string for all colors when HOMEBREW_NO_COLOR is set" do
// 98:       ENV["HOMEBREW_NO_COLOR"] = "1"
// 99:       expect(described_class.to_s).to eq("")
// 100:       expect(described_class.red.to_s).to eq("")
// 101:       expect(described_class.green.to_s).to eq("")
// 102:       expect(described_class.yellow.to_s).to eq("")
// 103:       expect(described_class.blue.to_s).to eq("")
// 104:       expect(described_class.magenta.to_s).to eq("")
// 105:       expect(described_class.cyan.to_s).to eq("")
// 106:       expect(described_class.default.to_s).to eq("")
// 107:     end
// 108:   end
// 109: end
