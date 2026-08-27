module utils

import brew_runtime

// Translated from Homebrew/brew `utils/phase_timings.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.start!(output_path:, started_at:, command:)` at line 21.
pub fn ruby_phase_timings_l21_d1_self_start(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.start!', ...args)
}

// Ruby method `self.measure(phase, detail: nil, &_block)` at line 38.
pub fn ruby_phase_timings_l38_d2_self_measure(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.measure', ...args)
}

// Ruby method `self.install!` at line 52.
pub fn ruby_phase_timings_l52_d3_self_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install!', ...args)
}

// Ruby method `self.write!` at line 92.
pub fn ruby_phase_timings_l92_d4_self_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write!', ...args)
}

// Ruby method `self.detail_for(receiver, args)` at line 109.
pub fn ruby_phase_timings_l109_d5_self_detail_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.detail_for', ...args)
}

// Ruby method `self.instrument(klass, method_name, phase)` at line 128.
pub fn ruby_phase_timings_l128_d6_self_instrument(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.instrument', ...args)
}

// Ruby define_method `define_method(method_name) do |*args, **kwargs, &block|` at line 139.
pub fn ruby_phase_timings_l139_d7_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_name', ...args)
}

// Ruby method `self.record(phase, started_at, completed_at, detail: nil)` at line 159.
pub fn ruby_phase_timings_l159_d8_self_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.record', ...args)
}

// Ruby method `self.monotonic_time` at line 171.
pub fn ruby_phase_timings_l171_d9_self_monotonic_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.monotonic_time', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module PhaseTimings
// 6:     Event = T.type_alias { T::Hash[String, T.any(Integer, String)] }
// 7:
// 8:     @command = T.let([], T::Array[String])
// 9:     @events = T.let([], T::Array[Event])
// 10:     @mutex = T.let(Thread::Mutex.new, Thread::Mutex)
// 11:     @output_path = T.let(nil, T.nilable(Pathname))
// 12:     @started_at = T.let(0.0, Float)
// 13:
// 14:     sig {
// 15:       params(
// 16:         output_path: T.any(Pathname, String),
// 17:         started_at:  Float,
// 18:         command:     T::Array[String],
// 19:       ).void
// 20:     }
// 21:     def self.start!(output_path:, started_at:, command:)
// 22:       @output_path = Pathname(output_path)
// 23:       @started_at = started_at
// 24:       @command = command
// 25:       @mutex.synchronize { @events = [] }
// 26:       record("startup", started_at, monotonic_time)
// 27:     end
// 28:
// 29:     sig {
// 30:       type_parameters(:U)
// 31:         .params(
// 32:           phase:  String,
// 33:           detail: T.nilable(String),
// 34:           _block: T.proc.returns(T.type_parameter(:U)),
// 35:         )
// 36:         .returns(T.type_parameter(:U))
// 37:     }
// 38:     def self.measure(phase, detail: nil, &_block)
// 39:       # Recording is opt-in via `$HOMEBREW_PHASE_TIMINGS`, so callers on the
// 40:       # startup path can measure unconditionally without paying for it.
// 41:       return yield if @output_path.nil?
// 42:
// 43:       started_at = monotonic_time
// 44:       begin
// 45:         yield
// 46:       ensure
// 47:         record(phase, started_at, monotonic_time, detail:)
// 48:       end
// 49:     end
// 50:
// 51:     sig { void }
// 52:     def self.install!
// 53:       instrument(Homebrew::CLI::NamedArgs, :to_formulae_and_casks, "formula_resolution") if defined?(Homebrew::CLI)
// 54:       instrument(Formulary.singleton_class, :factory, "formula_inflation") if defined?(Formulary)
// 55:       instrument(Homebrew::API.singleton_class, :fetch_api_files!, "api_metadata_load") if defined?(Homebrew::API)
// 56:       if defined?(Homebrew::API::Internal)
// 57:         instrument(Homebrew::API::Internal.singleton_class, :formula_struct, "api_metadata_load")
// 58:       end
// 59:       if defined?(Homebrew::Install)
// 60:         instrument(Homebrew::Install.singleton_class, :formula_installers, "planning")
// 61:         instrument(Homebrew::Install.singleton_class, :perform_preinstall_checks_once, "preinstall_checks")
// 62:       end
// 63:       if defined?(FormulaInstaller)
// 64:         instrument(FormulaInstaller, :prelude, "planning")
// 65:         instrument(FormulaInstaller, :compute_dependencies, "dependency_resolution")
// 66:         instrument(FormulaInstaller, :pour, "pour")
// 67:         instrument(FormulaInstaller, :link, "link")
// 68:         instrument(FormulaInstaller, :clean, "cleanup")
// 69:         instrument(FormulaInstaller, :post_install, "postinstall")
// 70:       end
// 71:       instrument(Homebrew::DownloadQueue, :enqueue, "download_enqueue") if defined?(Homebrew::DownloadQueue)
// 72:       if defined?(Utils::Curl)
// 73:         instrument(Utils::Curl, :curl_headers, "curl_headers")
// 74:         instrument(Utils::Curl.singleton_class, :curl_headers, "curl_headers")
// 75:         instrument(Utils::Curl, :curl_download, "curl_body")
// 76:         instrument(Utils::Curl.singleton_class, :curl_download, "curl_body")
// 77:       end
// 78:       instrument(Downloadable::VerificationCache, :verify, "checksum") if defined?(Downloadable::VerificationCache)
// 79:       if defined?(AbstractFileDownloadStrategy)
// 80:         instrument(AbstractFileDownloadStrategy, :create_symlink_to_cached_download, "symlink")
// 81:       end
// 82:       instrument(AbstractDownloadStrategy, :stage, "extraction") if defined?(AbstractDownloadStrategy)
// 83:       instrument(Bottle, :stage_from_download_queue, "extraction") if defined?(Bottle)
// 84:       instrument(Cask::Download, :stage_from_download_queue, "extraction") if defined?(Cask::Download)
// 85:       instrument(Tab, :write, "tab_write") if defined?(Tab)
// 86:       return unless defined?(Cleanup)
// 87:
// 88:       instrument(Cleanup.singleton_class, :install_formula_clean!, "cleanup")
// 89:     end
// 90:
// 91:     sig { void }
// 92:     def self.write!
// 93:       output_path = @output_path
// 94:       return if output_path.nil?
// 95:
// 96:       require "json"
// 97:
// 98:       events = @mutex.synchronize { @events.sort_by { |event| event.fetch("start") } }
// 99:       output_path.dirname.mkpath
// 100:       output_path.write("#{JSON.pretty_generate({
// 101:         "schema_version" => 1,
// 102:         "time_unit"      => "microseconds",
// 103:         "command"        => @command,
// 104:         "events"         => events,
// 105:       })}\n")
// 106:     end
// 107:
// 108:     sig { params(receiver: Object, args: T::Array[T.anything]).returns(T.nilable(String)) }
// 109:     def self.detail_for(receiver, args)
// 110:       object = if receiver.respond_to?(:formula)
// 111:         receiver.public_method(:formula).call
// 112:       elsif receiver.respond_to?(:url)
// 113:         receiver.public_method(:url).call
// 114:       else
// 115:         args.first
// 116:       end
// 117:
// 118:       if object.respond_to?(:full_name)
// 119:         object.full_name.to_s
// 120:       elsif object.respond_to?(:download_queue_name)
// 121:         object.download_queue_name.to_s
// 122:       elsif object.is_a?(String) || object.is_a?(Symbol) || object.is_a?(Pathname)
// 123:         object.to_s
// 124:       end
// 125:     end
// 126:
// 127:     sig { params(klass: T::Module[T.anything], method_name: Symbol, phase: String).void }
// 128:     private_class_method def self.instrument(klass, method_name, phase)
// 129:       visibility = if klass.private_method_defined?(method_name)
// 130:         :private
// 131:       elsif klass.protected_method_defined?(method_name)
// 132:         :protected
// 133:       elsif klass.method_defined?(method_name)
// 134:         :public
// 135:       end
// 136:       return if visibility.nil?
// 137:
// 138:       wrapper = Module.new do
// 139:         define_method(method_name) do |*args, **kwargs, &block|
// 140:           Homebrew::PhaseTimings.measure(
// 141:             phase,
// 142:             detail: Homebrew::PhaseTimings.detail_for(self, args),
// 143:           ) { super(*args, **kwargs, &block) }
// 144:         end
// 145:       end
// 146:       wrapper.module_eval { private method_name } if visibility == :private
// 147:       wrapper.module_eval { protected method_name } if visibility == :protected
// 148:       klass.prepend(wrapper)
// 149:     end
// 150:
// 151:     sig {
// 152:       params(
// 153:         phase:        String,
// 154:         started_at:   Float,
// 155:         completed_at: Float,
// 156:         detail:       T.nilable(String),
// 157:       ).void
// 158:     }
// 159:     private_class_method def self.record(phase, started_at, completed_at, detail: nil)
// 160:       event = T.let({
// 161:         "phase"     => phase,
// 162:         "start"     => ((started_at - @started_at) * 1_000_000).round,
// 163:         "duration"  => ((completed_at - started_at) * 1_000_000).round,
// 164:         "thread_id" => Thread.current.object_id,
// 165:       }, Event)
// 166:       event["detail"] = detail if detail
// 167:       @mutex.synchronize { @events << event }
// 168:     end
// 169:
// 170:     sig { returns(Float) }
// 171:     private_class_method def self.monotonic_time
// 172:       Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f
// 173:     end
// 174:   end
// 175: end
