module test

import brew_runtime

// Translated from Homebrew/brew `test/readline_nonblock_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns only full lines", :aggregate_failures do` at line 8.
pub fn ruby_readline_nonblock_spec_l8_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns same lines from file as File.readlines" do` at line 22.
pub fn ruby_readline_nonblock_spec_l22_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "handles long lines" do` at line 48.
pub fn ruby_readline_nonblock_spec_l48_d3_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
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
