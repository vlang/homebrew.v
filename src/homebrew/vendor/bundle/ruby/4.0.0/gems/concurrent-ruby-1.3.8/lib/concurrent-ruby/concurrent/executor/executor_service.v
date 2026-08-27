module executor

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/executor/executor_service.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `post(*args, &task)` at line 161.
pub fn ruby_executor_service_l161_d1_post(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('post', ...args)
}

// Ruby method `<<(task)` at line 166.
pub fn ruby_executor_service_l166_d2_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `can_overflow?` at line 174.
pub fn ruby_executor_service_l174_d3_can_overflow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can_overflow?', ...args)
}

// Ruby method `serialized?` at line 181.
pub fn ruby_executor_service_l181_d4_serialized(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialized?', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/concern/logging'
// 2:
// 3: module Concurrent
// 4:
// 5:   ###################################################################
// 6:
// 7:   # @!macro executor_service_method_post
// 8:   #
// 9:   #   Submit a task to the executor for asynchronous processing.
// 10:   #
// 11:   #   @param [Array] args zero or more arguments to be passed to the task
// 12:   #
// 13:   #   @yield the asynchronous task to perform
// 14:   #
// 15:   #   @return [Boolean] `true` if the task is queued, `false` if the executor
// 16:   #     is not running
// 17:   #
// 18:   #   @raise [ArgumentError] if no task is given
// 19:
// 20:   # @!macro executor_service_method_left_shift
// 21:   #
// 22:   #   Submit a task to the executor for asynchronous processing.
// 23:   #
// 24:   #   @param [Proc] task the asynchronous task to perform
// 25:   #
// 26:   #   @return [self] returns itself
// 27:
// 28:   # @!macro executor_service_method_can_overflow_question
// 29:   #
// 30:   #   Does the task queue have a maximum size?
// 31:   #
// 32:   #   @return [Boolean] True if the task queue has a maximum size else false.
// 33:
// 34:   # @!macro executor_service_method_serialized_question
// 35:   #
// 36:   #   Does this executor guarantee serialization of its operations?
// 37:   #
// 38:   #   @return [Boolean] True if the executor guarantees that all operations
// 39:   #     will be post in the order they are received and no two operations may
// 40:   #     occur simultaneously. Else false.
// 41:
// 42:   ###################################################################
// 43:
// 44:   # @!macro executor_service_public_api
// 45:   #
// 46:   #   @!method post(*args, &task)
// 47:   #     @!macro executor_service_method_post
// 48:   #
// 49:   #   @!method <<(task)
// 50:   #     @!macro executor_service_method_left_shift
// 51:   #
// 52:   #   @!method can_overflow?
// 53:   #     @!macro executor_service_method_can_overflow_question
// 54:   #
// 55:   #   @!method serialized?
// 56:   #     @!macro executor_service_method_serialized_question
// 57:
// 58:   ###################################################################
// 59:
// 60:   # @!macro executor_service_attr_reader_fallback_policy
// 61:   #   @return [Symbol] The fallback policy in effect. Either `:abort`, `:discard`, or `:caller_runs`.
// 62:
// 63:   # @!macro executor_service_method_shutdown
// 64:   #
// 65:   #   Begin an orderly shutdown. Tasks already in the queue will be executed,
// 66:   #   but no new tasks will be accepted. Has no additional effect if the
// 67:   #   thread pool is not running.
// 68:
// 69:   # @!macro executor_service_method_kill
// 70:   #
// 71:   #   Begin an immediate shutdown. In-progress tasks will be allowed to
// 72:   #   complete but enqueued tasks will be dismissed and no new tasks
// 73:   #   will be accepted. Has no additional effect if the thread pool is
// 74:   #   not running.
// 75:
// 76:   # @!macro executor_service_method_wait_for_termination
// 77:   #
// 78:   #   Block until executor shutdown is complete or until `timeout` seconds have
// 79:   #   passed.
// 80:   #
// 81:   #   @note Does not initiate shutdown or termination. Either `shutdown` or `kill`
// 82:   #     must be called before this method (or on another thread).
// 83:   #
// 84:   #   @param [Integer] timeout the maximum number of seconds to wait for shutdown to complete
// 85:   #
// 86:   #   @return [Boolean] `true` if shutdown complete or false on `timeout`
// 87:
// 88:   # @!macro executor_service_method_running_question
// 89:   #
// 90:   #   Is the executor running?
// 91:   #
// 92:   #   @return [Boolean] `true` when running, `false` when shutting down or shutdown
// 93:
// 94:   # @!macro executor_service_method_shuttingdown_question
// 95:   #
// 96:   #   Is the executor shuttingdown?
// 97:   #
// 98:   #   @return [Boolean] `true` when not running and not shutdown, else `false`
// 99:
// 100:   # @!macro executor_service_method_shutdown_question
// 101:   #
// 102:   #   Is the executor shutdown?
// 103:   #
// 104:   #   @return [Boolean] `true` when shutdown, `false` when shutting down or running
// 105:
// 106:   # @!macro executor_service_method_auto_terminate_question
// 107:   #
// 108:   #   Is the executor auto-terminate when the application exits?
// 109:   #
// 110:   #   @return [Boolean] `true` when auto-termination is enabled else `false`.
// 111:
// 112:   # @!macro executor_service_method_auto_terminate_setter
// 113:   #
// 114:   #
// 115:   #   Set the auto-terminate behavior for this executor.
// 116:   #   @deprecated Has no effect
// 117:   #   @param [Boolean] value The new auto-terminate value to set for this executor.
// 118:   #   @return [Boolean] `true` when auto-termination is enabled else `false`.
// 119:
// 120:   ###################################################################
// 121:
// 122:   # @!macro abstract_executor_service_public_api
// 123:   #
// 124:   #   @!macro executor_service_public_api
// 125:   #
// 126:   #   @!attribute [r] fallback_policy
// 127:   #     @!macro executor_service_attr_reader_fallback_policy
// 128:   #
// 129:   #   @!method shutdown
// 130:   #     @!macro executor_service_method_shutdown
// 131:   #
// 132:   #   @!method kill
// 133:   #     @!macro executor_service_method_kill
// 134:   #
// 135:   #   @!method wait_for_termination(timeout = nil)
// 136:   #     @!macro executor_service_method_wait_for_termination
// 137:   #
// 138:   #   @!method running?
// 139:   #     @!macro executor_service_method_running_question
// 140:   #
// 141:   #   @!method shuttingdown?
// 142:   #     @!macro executor_service_method_shuttingdown_question
// 143:   #
// 144:   #   @!method shutdown?
// 145:   #     @!macro executor_service_method_shutdown_question
// 146:   #
// 147:   #   @!method auto_terminate?
// 148:   #     @!macro executor_service_method_auto_terminate_question
// 149:   #
// 150:   #   @!method auto_terminate=(value)
// 151:   #     @!macro executor_service_method_auto_terminate_setter
// 152:
// 153:   ###################################################################
// 154:
// 155:   # @!macro executor_service_public_api
// 156:   # @!visibility private
// 157:   module ExecutorService
// 158:     include Concern::Logging
// 159:
// 160:     # @!macro executor_service_method_post
// 161:     def post(*args, &task)
// 162:       raise NotImplementedError
// 163:     end
// 164:
// 165:     # @!macro executor_service_method_left_shift
// 166:     def <<(task)
// 167:       post(&task)
// 168:       self
// 169:     end
// 170:
// 171:     # @!macro executor_service_method_can_overflow_question
// 172:     #
// 173:     # @note Always returns `false`
// 174:     def can_overflow?
// 175:       false
// 176:     end
// 177:
// 178:     # @!macro executor_service_method_serialized_question
// 179:     #
// 180:     # @note Always returns `false`
// 181:     def serialized?
// 182:       false
// 183:     end
// 184:   end
// 185: end
