module utils

import brew_runtime

// Translated from Homebrew/brew `utils/popen.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.popen_read(*args, safe: false, **options, &block)` at line 17.
pub fn ruby_popen_l17_d1_self_popen_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.popen_read', ...args)
}

// Ruby method `self.safe_popen_read(*args, **options, &block)` at line 32.
pub fn ruby_popen_l32_d2_self_safe_popen_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.safe_popen_read', ...args)
}

// Ruby method `self.popen_write(*args, safe: false, **options, &_block)` at line 44.
pub fn ruby_popen_l44_d3_self_popen_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.popen_write', ...args)
}

// Ruby method `self.safe_popen_write(*args, **options, &block)` at line 75.
pub fn ruby_popen_l75_d4_self_safe_popen_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.safe_popen_write', ...args)
}

// Ruby method `self.popen(args, mode, options = {}, &_block)` at line 88.
pub fn ruby_popen_l88_d5_self_popen(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.popen', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   IO_DEFAULT_BUFFER_SIZE = 4096
// 6:   private_constant :IO_DEFAULT_BUFFER_SIZE
// 7:
// 8:   sig {
// 9:     type_parameters(:U)
// 10:       .params(
// 11:         args:    T.nilable(T.any(String, Pathname, T::Hash[String, String])),
// 12:         safe:    T::Boolean,
// 13:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 14:         block:   T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 15:       ).returns(T.any(T.type_parameter(:U), String))
// 16:   }
// 17:   def self.popen_read(*args, safe: false, **options, &block)
// 18:     output = popen(args, "rb", options, &block)
// 19:     return output if !safe || $CHILD_STATUS.success?
// 20:
// 21:     raise ErrorDuringExecution.new(args, status: $CHILD_STATUS, output: [[:stdout, T.cast(output, String)]])
// 22:   end
// 23:
// 24:   sig {
// 25:     type_parameters(:U)
// 26:       .params(
// 27:         args:    T.nilable(T.any(String, Pathname, T::Hash[String, String])),
// 28:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 29:         block:   T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 30:       ).returns(T.any(T.type_parameter(:U), String))
// 31:   }
// 32:   def self.safe_popen_read(*args, **options, &block)
// 33:     popen_read(*args, safe: true, **options, &block)
// 34:   end
// 35:
// 36:   sig {
// 37:     params(
// 38:       args:    T.any(String, Pathname),
// 39:       safe:    T::Boolean,
// 40:       options: T.nilable(T.any(Pathname, String, Symbol)),
// 41:       _block:  T.proc.params(arg0: IO).returns(T.anything),
// 42:     ).returns(String)
// 43:   }
// 44:   def self.popen_write(*args, safe: false, **options, &_block)
// 45:     output = ""
// 46:     popen(args, "w+b", options) do |pipe|
// 47:       # Before we yield to the block, capture as much output as we can
// 48:       loop do
// 49:         output += pipe.read_nonblock(IO_DEFAULT_BUFFER_SIZE)
// 50:       rescue IO::WaitReadable, EOFError
// 51:         break
// 52:       end
// 53:
// 54:       yield pipe
// 55:       pipe.close_write
// 56:       pipe.wait_readable
// 57:
// 58:       # Capture the rest of the output
// 59:       output += pipe.read
// 60:       output.freeze
// 61:     end
// 62:     return output if !safe || $CHILD_STATUS.success?
// 63:
// 64:     raise ErrorDuringExecution.new(args, status: $CHILD_STATUS, output: [[:stdout, output]])
// 65:   end
// 66:
// 67:   sig {
// 68:     type_parameters(:U)
// 69:       .params(
// 70:         args:    T.any(String, Pathname),
// 71:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 72:         block:   T.proc.params(arg0: IO).returns(T.type_parameter(:U)),
// 73:       ).returns(T.type_parameter(:U))
// 74:   }
// 75:   def self.safe_popen_write(*args, **options, &block)
// 76:     popen_write(*args, safe: true, **options, &block)
// 77:   end
// 78:
// 79:   sig {
// 80:     type_parameters(:U)
// 81:       .params(
// 82:         args:    T::Array[T.nilable(T.any(Pathname, String, T::Hash[String, String]))],
// 83:         mode:    String,
// 84:         options: T::Hash[Symbol, T.nilable(T.any(Pathname, String, Symbol))],
// 85:         _block:  T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 86:       ).returns(T.any(T.type_parameter(:U), String))
// 87:   }
// 88:   def self.popen(args, mode, options = {}, &_block)
// 89:     # `brew prof --vernier` uses this to avoid inheriting Vernier's active
// 90:     # native collector state through `IO.popen("-")` fork paths.
// 91:     if ENV["HOMEBREW_SPAWN_SYSTEM"] == "1"
// 92:       options[:err] ||= File::NULL unless ENV["HOMEBREW_STDERR"]
// 93:       IO.popen(args, mode, options) do |pipe|
// 94:         return pipe.read unless block_given?
// 95:
// 96:         return yield pipe
// 97:       end
// 98:     end
// 99:
// 100:     IO.popen("-", mode) do |pipe|
// 101:       if pipe
// 102:         return pipe.read unless block_given?
// 103:
// 104:         yield pipe
// 105:       else
// 106:         options[:err] ||= File::NULL unless ENV["HOMEBREW_STDERR"]
// 107:         cmd = if args[0].is_a? Hash
// 108:           args[1]
// 109:         else
// 110:           args[0]
// 111:         end
// 112:         begin
// 113:           exec(*args, options)
// 114:         rescue Errno::ENOENT
// 115:           $stderr.puts "brew: command not found: #{cmd}" if options[:err] != :close
// 116:           exit! 127
// 117:         rescue SystemCallError => e
// 118:           if options[:err] != :close
// 119:             require "utils"
// 120:             $stderr.puts "brew: exec failed (#{Utils.demodulize(e.class.name)}): #{cmd}"
// 121:           end
// 122:           exit! 1
// 123:         end
// 124:       end
// 125:     end
// 126:   end
// 127: end
