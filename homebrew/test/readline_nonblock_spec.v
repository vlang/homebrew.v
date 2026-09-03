module test

import homebrew

// Translated from Homebrew/brew `test/readline_nonblock_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns only full lines", :aggregate_failures do` at line 8.
pub fn ruby_readline_nonblock_spec_l8_d1_returns() bool {
	mut reader := homebrew.ReadlineNonblock{}
	mut source := homebrew.ReadlineNonblockSource{
		events: [
			homebrew.readline_wait_readable(),
			homebrew.readline_data('Test'),
			homebrew.readline_wait_readable(),
			homebrew.readline_data('1\n2'),
			homebrew.readline_eof(),
			homebrew.readline_eof(),
		]
	}
	if !readline_spec_waits(mut reader, mut source) {
		return false
	}
	if !readline_spec_waits(mut reader, mut source) {
		return false
	}
	if reader.read(mut source) or { return false } != 'Test1\n' {
		return false
	}
	if reader.read(mut source) or { return false } != '2' {
		return false
	}
	return readline_spec_eof(mut reader, mut source)
}

// Ruby it `it "returns same lines from file as File.readlines" do` at line 22.
pub fn ruby_readline_nonblock_spec_l22_d2_returns() bool {
	contents := 'First line\nSecond line\n\nFourth line\nFifth line'
	mut reader := homebrew.ReadlineNonblock{}
	mut source := homebrew.ReadlineNonblockSource{
		events: [
			homebrew.readline_data(contents[..17]),
			homebrew.readline_data(contents[17..]),
			homebrew.readline_eof(),
		]
	}
	mut lines := []string{}
	for {
		line := reader.read(mut source) or {
			if err is homebrew.ReadlineEofError {
				break
			}
			return false
		}
		lines << line
	}
	return lines == ['First line\n', 'Second line\n', '\n', 'Fourth line\n', 'Fifth line']
}

// Ruby it `it "handles long lines" do` at line 48.
pub fn ruby_readline_nonblock_spec_l48_d3_handles() bool {
	line_length := 10_000
	mut reader := homebrew.ReadlineNonblock{}
	mut source := homebrew.ReadlineNonblockSource{
		events: [homebrew.readline_data('a'.repeat(line_length)), homebrew.readline_eof()]
	}
	line := reader.read(mut source) or { return false }
	return line.len == line_length && line == 'a'.repeat(line_length) && source.last_request_size == homebrew.readline_nonblock_buffer_size && readline_spec_eof(mut reader, mut source)
}

fn readline_spec_waits(mut reader homebrew.ReadlineNonblock,
	mut source homebrew.ReadlineNonblockSource) bool {
	reader.read(mut source) or { return err is homebrew.ReadlineWaitReadableError }
	return false
}

fn readline_spec_eof(mut reader homebrew.ReadlineNonblock,
	mut source homebrew.ReadlineNonblockSource) bool {
	reader.read(mut source) or { return err is homebrew.ReadlineEofError }
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "readline_nonblock"
// 5:
// 6: RSpec.describe ReadlineNonblock do
// 7:   describe "#read", timeout: 10 do
// 8:     it "returns only full lines", :aggregate_failures do
// 9:       IO.pipe do |read_io, write_io|
// 10:         reader = described_class.new(read_io)
// 11:         expect { reader.read }.to raise_error(IO::WaitReadable)
// 12:         write_io.write "Test"
// 13:         expect { reader.read }.to raise_error(IO::WaitReadable)
// 14:         write_io.write "1\n2"
// 15:         expect(reader.read).to eq("Test1\n")
// 16:         write_io.close
// 17:         expect(reader.read).to eq("2")
// 18:         expect { reader.read }.to raise_error(EOFError)
// 19:       end
// 20:     end
// 21:
// 22:     it "returns same lines from file as File.readlines" do
// 23:       mktmpdir do |tmpdir|
// 24:         (tmpdir/"test.txt").write <<~EOS.chomp
// 25:           First line
// 26:           Second line
// 27:
// 28:           Fourth line
// 29:           Fifth line
// 30:         EOS
// 31:
// 32:         lines = []
// 33:         (tmpdir/"test.txt").open do |file|
// 34:           reader = described_class.new(file)
// 35:           loop do
// 36:             lines << reader.read
// 37:           rescue IO::WaitReadable
// 38:             file.wait_readable
// 39:           rescue EOFError
// 40:             break
// 41:           end
// 42:         end
// 43:         expect(lines).to eq(File.readlines(tmpdir/"test.txt"))
// 44:         expect(lines).to eq ["First line\n", "Second line\n", "\n", "Fourth line\n", "Fifth line"]
// 45:       end
// 46:     end
// 47:
// 48:     it "handles long lines" do
// 49:       IO.pipe do |read_io, write_io|
// 50:         line_length = 10000
// 51:         write_io.write("a" * line_length)
// 52:         write_io.close
// 53:         reader = described_class.new(read_io)
// 54:         expect(reader.read.length).to eq line_length
// 55:         expect { reader.read }.to raise_error(EOFError)
// 56:       end
// 57:     end
// 58:   end
// 59: end
