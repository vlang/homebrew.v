module homebrew

import brew_runtime

// Translated from Homebrew/brew `readline_nonblock.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(io)` at line 12.
pub fn ruby_readline_nonblock_l12_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `read` at line 29.
pub fn ruby_readline_nonblock_l29_d2_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # An {IO} wrapper class that allows performing non-blocking line reads on the
// 5: # provided instance. It is undefined behaviour to run this with other modifying
// 6: # {IO} operations, e.g. {IO#read} or {IO#seek}, on the same instance.
// 7: class ReadlineNonblock
// 8:   BUFFER_SIZE = 4096
// 9:   private_constant :BUFFER_SIZE
// 10:
// 11:   sig { params(io: IO).void }
// 12:   def initialize(io)
// 13:     @io = io
// 14:     @buffer = T.let(+"", String)
// 15:     @line = T.let(+"", String)
// 16:   end
// 17:
// 18:   # Reads and returns a line ending with `"\n"` or remaining text before EOF.
// 19:   # Non-blocking reads should return similar output as {IO#readline} with `"\n"`,
// 20:   # while reads that would block raise {IO::WaitReadable}.
// 21:   #
// 22:   # Note that this method does not support the global line separator `$/`.
// 23:   # Also it does not modify `$_`.
// 24:   #
// 25:   # @return the next line
// 26:   # @raise [IO::WaitReadable] if read would block
// 27:   # @raise [EOFError] on EOF
// 28:   sig { returns(String) }
// 29:   def read
// 30:     begin
// 31:       loop do
// 32:         if (index = @buffer.index("\n"))
// 33:           @line.concat(@buffer.slice!(0..index).to_s)
// 34:           break
// 35:         end
// 36:
// 37:         @line.concat(@buffer)
// 38:         @buffer.clear
// 39:         @io.read_nonblock(BUFFER_SIZE, @buffer)
// 40:       end
// 41:     rescue EOFError
// 42:       raise if @line.empty?
// 43:     end
// 44:
// 45:     line = @line.freeze
// 46:     @line = +""
// 47:     line
// 48:   end
// 49: end
