module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/maybe.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :just` at line 114.
pub fn ruby_maybe_l114_d1_just(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('just', ...args)
}

// Ruby attr_reader `attr_reader :nothing` at line 117.
pub fn ruby_maybe_l117_d2_nothing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nothing', ...args)
}

// Ruby method `self.from(*args)` at line 137.
pub fn ruby_maybe_l137_d3_self_from(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from', ...args)
}

// Ruby method `self.just(value)` at line 152.
pub fn ruby_maybe_l152_d4_self_just(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.just', ...args)
}

// Ruby method `self.nothing(error = '')` at line 164.
pub fn ruby_maybe_l164_d5_self_nothing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.nothing', ...args)
}

// Ruby method `just?` at line 176.
pub fn ruby_maybe_l176_d6_just(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('just?', ...args)
}

// Ruby alias `alias :fulfilled? :just?` at line 179.
pub fn ruby_maybe_l179_d7_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn(':fulfilled?', ...args)
}

// Ruby method `nothing?` at line 184.
pub fn ruby_maybe_l184_d8_nothing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nothing?', ...args)
}

// Ruby alias `alias :rejected? :nothing?` at line 187.
pub fn ruby_maybe_l187_d9_rejected(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn(':rejected?', ...args)
}

// Ruby alias `alias :value :just` at line 189.
pub fn ruby_maybe_l189_d10_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn(':value', ...args)
}

// Ruby alias `alias :reason :nothing` at line 191.
pub fn ruby_maybe_l191_d11_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn(':reason', ...args)
}

// Ruby method `<=>(other)` at line 199.
pub fn ruby_maybe_l199_d12_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `or(other)` at line 210.
pub fn ruby_maybe_l210_d13_or(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('or', ...args)
}

// Ruby method `initialize(just, nothing)` at line 224.
pub fn ruby_maybe_l224_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/object'
// 2:
// 3: module Concurrent
// 4:
// 5:   # A `Maybe` encapsulates an optional value. A `Maybe` either contains a value
// 6:   # of (represented as `Just`), or it is empty (represented as `Nothing`). Using
// 7:   # `Maybe` is a good way to deal with errors or exceptional cases without
// 8:   # resorting to drastic measures such as exceptions.
// 9:   #
// 10:   # `Maybe` is a replacement for the use of `nil` with better type checking.
// 11:   #
// 12:   # For compatibility with {Concurrent::Concern::Obligation} the predicate and
// 13:   # accessor methods are aliased as `fulfilled?`, `rejected?`, `value`, and
// 14:   # `reason`.
// 15:   #
// 16:   # ## Motivation
// 17:   #
// 18:   # A common pattern in languages with pattern matching, such as Erlang and
// 19:   # Haskell, is to return *either* a value *or* an error from a function
// 20:   # Consider this Erlang code:
// 21:   #
// 22:   # ```erlang
// 23:   # case file:consult("data.dat") of
// 24:   #   {ok, Terms} -> do_something_useful(Terms);
// 25:   #   {error, Reason} -> lager:error(Reason)
// 26:   # end.
// 27:   # ```
// 28:   #
// 29:   # In this example the standard library function `file:consult` returns a
// 30:   # [tuple](http://erlang.org/doc/reference_manual/data_types.html#id69044)
// 31:   # with two elements: an [atom](http://erlang.org/doc/reference_manual/data_types.html#id64134)
// 32:   # (similar to a ruby symbol) and a variable containing ancillary data. On
// 33:   # success it returns the atom `ok` and the data from the file. On failure it
// 34:   # returns `error` and a string with an explanation of the problem. With this
// 35:   # pattern there is no ambiguity regarding success or failure. If the file is
// 36:   # empty the return value cannot be misinterpreted as an error. And when an
// 37:   # error occurs the return value provides useful information.
// 38:   #
// 39:   # In Ruby we tend to return `nil` when an error occurs or else we raise an
// 40:   # exception. Both of these idioms are problematic. Returning `nil` is
// 41:   # ambiguous because `nil` may also be a valid value. It also lacks
// 42:   # information pertaining to the nature of the error. Raising an exception
// 43:   # is both expensive and usurps the normal flow of control. All of these
// 44:   # problems can be solved with the use of a `Maybe`.
// 45:   #
// 46:   # A `Maybe` is unambiguous with regard to whether or not it contains a value.
// 47:   # When `Just` it contains a value, when `Nothing` it does not. When `Just`
// 48:   # the value it contains may be `nil`, which is perfectly valid. When
// 49:   # `Nothing` the reason for the lack of a value is contained as well. The
// 50:   # previous Erlang example can be duplicated in Ruby in a principled way by
// 51:   # having functions return `Maybe` objects:
// 52:   #
// 53:   # ```ruby
// 54:   # result = MyFileUtils.consult("data.dat") # returns a Maybe
// 55:   # if result.just?
// 56:   #   do_something_useful(result.value)      # or result.just
// 57:   # else
// 58:   #   logger.error(result.reason)            # or result.nothing
// 59:   # end
// 60:   # ```
// 61:   #
// 62:   # @example Returning a Maybe from a Function
// 63:   #   module MyFileUtils
// 64:   #     def self.consult(path)
// 65:   #       file = File.open(path, 'r')
// 66:   #       Concurrent::Maybe.just(file.read)
// 67:   #     rescue => ex
// 68:   #       return Concurrent::Maybe.nothing(ex)
// 69:   #     ensure
// 70:   #       file.close if file
// 71:   #     end
// 72:   #   end
// 73:   #
// 74:   #   maybe = MyFileUtils.consult('bogus.file')
// 75:   #   maybe.just?    #=> false
// 76:   #   maybe.nothing? #=> true
// 77:   #   maybe.reason   #=> #<Errno::ENOENT: No such file or directory @ rb_sysopen - bogus.file>
// 78:   #
// 79:   #   maybe = MyFileUtils.consult('README.md')
// 80:   #   maybe.just?    #=> true
// 81:   #   maybe.nothing? #=> false
// 82:   #   maybe.value    #=> "# Concurrent Ruby\n[![Gem Version..."
// 83:   #
// 84:   # @example Using Maybe with a Block
// 85:   #   result = Concurrent::Maybe.from do
// 86:   #     Client.find(10) # Client is an ActiveRecord model
// 87:   #   end
// 88:   #
// 89:   #   # -- if the record was found
// 90:   #   result.just? #=> true
// 91:   #   result.value #=> #<Client id: 10, first_name: "Ryan">
// 92:   #
// 93:   #   # -- if the record was not found
// 94:   #   result.just?  #=> false
// 95:   #   result.reason #=> ActiveRecord::RecordNotFound
// 96:   #
// 97:   # @example Using Maybe with the Null Object Pattern
// 98:   #   # In a Rails controller...
// 99:   #   result = ClientService.new(10).find    # returns a Maybe
// 100:   #   render json: result.or(NullClient.new)
// 101:   #
// 102:   # @see https://hackage.haskell.org/package/base-4.2.0.1/docs/Data-Maybe.html Haskell Data.Maybe
// 103:   # @see https://github.com/purescript/purescript-maybe/blob/master/docs/Data.Maybe.md PureScript Data.Maybe
// 104:   class Maybe < Synchronization::Object
// 105:     include Comparable
// 106:     safe_initialization!
// 107:
// 108:     # Indicates that the given attribute has not been set.
// 109:     # When `Just` the {#nothing} getter will return `NONE`.
// 110:     # When `Nothing` the {#just} getter will return `NONE`.
// 111:     NONE = ::Object.new.freeze
// 112:
// 113:     # The value of a `Maybe` when `Just`. Will be `NONE` when `Nothing`.
// 114:     attr_reader :just
// 115:
// 116:     # The reason for the `Maybe` when `Nothing`. Will be `NONE` when `Just`.
// 117:     attr_reader :nothing
// 118:
// 119:     private_class_method :new
// 120:
// 121:     # Create a new `Maybe` using the given block.
// 122:     #
// 123:     # Runs the given block passing all function arguments to the block as block
// 124:     # arguments. If the block runs to completion without raising an exception
// 125:     # a new `Just` is created with the value set to the return value of the
// 126:     # block. If the block raises an exception a new `Nothing` is created with
// 127:     # the reason being set to the raised exception.
// 128:     #
// 129:     # @param [Array<Object>] args Zero or more arguments to pass to the block.
// 130:     # @yield The block from which to create a new `Maybe`.
// 131:     # @yieldparam [Array<Object>] args Zero or more block arguments passed as
// 132:     #   arguments to the function.
// 133:     #
// 134:     # @return [Maybe] The newly created object.
// 135:     #
// 136:     # @raise [ArgumentError] when no block given.
// 137:     def self.from(*args)
// 138:       raise ArgumentError.new('no block given') unless block_given?
// 139:       begin
// 140:         value = yield(*args)
// 141:         return new(value, NONE)
// 142:       rescue => ex
// 143:         return new(NONE, ex)
// 144:       end
// 145:     end
// 146:
// 147:     # Create a new `Just` with the given value.
// 148:     #
// 149:     # @param [Object] value The value to set for the new `Maybe` object.
// 150:     #
// 151:     # @return [Maybe] The newly created object.
// 152:     def self.just(value)
// 153:       return new(value, NONE)
// 154:     end
// 155:
// 156:     # Create a new `Nothing` with the given (optional) reason.
// 157:     #
// 158:     # @param [Exception] error The reason to set for the new `Maybe` object.
// 159:     #   When given a string a new `StandardError` will be created with the
// 160:     #   argument as the message. When no argument is given a new
// 161:     #   `StandardError` with an empty message will be created.
// 162:     #
// 163:     # @return [Maybe] The newly created object.
// 164:     def self.nothing(error = '')
// 165:       if error.is_a?(Exception)
// 166:         nothing = error
// 167:       else
// 168:         nothing = StandardError.new(error.to_s)
// 169:       end
// 170:       return new(NONE, nothing)
// 171:     end
// 172:
// 173:     # Is this `Maybe` a `Just` (successfully fulfilled with a value)?
// 174:     #
// 175:     # @return [Boolean] True if `Just` or false if `Nothing`.
// 176:     def just?
// 177:       ! nothing?
// 178:     end
// 179:     alias :fulfilled? :just?
// 180:
// 181:     # Is this `Maybe` a `nothing` (rejected with an exception upon fulfillment)?
// 182:     #
// 183:     # @return [Boolean] True if `Nothing` or false if `Just`.
// 184:     def nothing?
// 185:       @nothing != NONE
// 186:     end
// 187:     alias :rejected? :nothing?
// 188:
// 189:     alias :value :just
// 190:
// 191:     alias :reason :nothing
// 192:
// 193:     # Comparison operator.
// 194:     #
// 195:     # @return [Integer] 0 if self and other are both `Nothing`;
// 196:     #   -1 if self is `Nothing` and other is `Just`;
// 197:     #   1 if self is `Just` and other is nothing;
// 198:     #   `self.just <=> other.just` if both self and other are `Just`.
// 199:     def <=>(other)
// 200:       if nothing?
// 201:         other.nothing? ? 0 : -1
// 202:       else
// 203:         other.nothing? ? 1 : just <=> other.just
// 204:       end
// 205:     end
// 206:
// 207:     # Return either the value of self or the given default value.
// 208:     #
// 209:     # @return [Object] The value of self when `Just`; else the given default.
// 210:     def or(other)
// 211:       just? ? just : other
// 212:     end
// 213:
// 214:     private
// 215:
// 216:     # Create a new `Maybe` with the given attributes.
// 217:     #
// 218:     # @param [Object] just The value when `Just` else `NONE`.
// 219:     # @param [Exception, Object] nothing The exception when `Nothing` else `NONE`.
// 220:     #
// 221:     # @return [Maybe] The new `Maybe`.
// 222:     #
// 223:     # @!visibility private
// 224:     def initialize(just, nothing)
// 225:       @just = just
// 226:       @nothing = nothing
// 227:     end
// 228:   end
// 229: end
