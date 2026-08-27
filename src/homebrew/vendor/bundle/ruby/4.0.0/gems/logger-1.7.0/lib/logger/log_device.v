module logger

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger/log_device.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :dev` at line 10.
pub fn ruby_log_device_l10_d1_dev(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dev', ...args)
}

// Ruby attr_reader `attr_reader :filename` at line 11.
pub fn ruby_log_device_l11_d2_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filename', ...args)
}

// Ruby method `initialize(` at line 14.
pub fn ruby_log_device_l14_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `write(message)` at line 27.
pub fn ruby_log_device_l27_d4_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write', ...args)
}

// Ruby method `close` at line 38.
pub fn ruby_log_device_l38_d5_close(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('close', ...args)
}

// Ruby method `reopen(log = nil, shift_age: nil, shift_size: nil, shift_period_suffix: nil, binmode: nil)` at line 48.
pub fn ruby_log_device_l48_d6_reopen(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reopen', ...args)
}

// Ruby method `set_dev(log)` at line 78.
pub fn ruby_log_device_l78_d7_set_dev(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_dev', ...args)
}

// Ruby method `set_file(shift_age, shift_size, shift_period_suffix)` at line 92.
pub fn ruby_log_device_l92_d8_set_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_file', ...args)
}

// Ruby method `fixup_mode(dev)` at line 104.
pub fn ruby_log_device_l104_d9_fixup_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixup_mode', ...args)
}

// Ruby method `fixup_mode(dev)` at line 108.
pub fn ruby_log_device_l108_d10_fixup_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixup_mode', ...args)
}

// Ruby method `open_logfile(filename)` at line 119.
pub fn ruby_log_device_l119_d11_open_logfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('open_logfile', ...args)
}

// Ruby method `create_logfile(filename)` at line 132.
pub fn ruby_log_device_l132_d12_create_logfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_logfile', ...args)
}

// Ruby method `handle_write_errors(mesg)` at line 148.
pub fn ruby_log_device_l148_d13_handle_write_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handle_write_errors', ...args)
}

// Ruby method `add_log_header(file)` at line 156.
pub fn ruby_log_device_l156_d14_add_log_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_log_header', ...args)
}

// Ruby method `check_shift_log` at line 162.
pub fn ruby_log_device_l162_d15_check_shift_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_shift_log', ...args)
}

// Ruby method `lock_shift_log` at line 177.
pub fn ruby_log_device_l177_d16_lock_shift_log(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lock_shift_log', ...args)
}

// Ruby method `shift_log_age` at line 207.
pub fn ruby_log_device_l207_d17_shift_log_age(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift_log_age', ...args)
}

// Ruby method `shift_log_period(period_end)` at line 216.
pub fn ruby_log_device_l216_d18_shift_log_period(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift_log_period', ...args)
}

// Ruby method `shift_log_file(shifted)` at line 232.
pub fn ruby_log_device_l232_d19_shift_log_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift_log_file', ...args)
}

// Ruby attr_reader `attr_reader :path` at line 259.
pub fn ruby_log_device_l259_d20_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby method `self.set_path(file, path)` at line 261.
pub fn ruby_log_device_l261_d21_self_set_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.set_path', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require_relative 'period'
// 4:
// 5: class Logger
// 6:   # Device used for logging messages.
// 7:   class LogDevice
// 8:     include Period
// 9:
// 10:     attr_reader :dev
// 11:     attr_reader :filename
// 12:     include MonitorMixin
// 13:
// 14:     def initialize(
// 15:       log = nil, shift_age: nil, shift_size: nil, shift_period_suffix: nil,
// 16:       binmode: false, reraise_write_errors: [], skip_header: false
// 17:     )
// 18:       @dev = @filename = @shift_age = @shift_size = @shift_period_suffix = nil
// 19:       @binmode = binmode
// 20:       @reraise_write_errors = reraise_write_errors
// 21:       @skip_header = skip_header
// 22:       mon_initialize
// 23:       set_dev(log)
// 24:       set_file(shift_age, shift_size, shift_period_suffix) if @filename
// 25:     end
// 26:
// 27:     def write(message)
// 28:       handle_write_errors("writing") do
// 29:         synchronize do
// 30:           if @shift_age and @dev.respond_to?(:stat)
// 31:             handle_write_errors("shifting") {check_shift_log}
// 32:           end
// 33:           handle_write_errors("writing") {@dev.write(message)}
// 34:         end
// 35:       end
// 36:     end
// 37:
// 38:     def close
// 39:       begin
// 40:         synchronize do
// 41:           @dev.close rescue nil
// 42:         end
// 43:       rescue Exception
// 44:         @dev.close rescue nil
// 45:       end
// 46:     end
// 47:
// 48:     def reopen(log = nil, shift_age: nil, shift_size: nil, shift_period_suffix: nil, binmode: nil)
// 49:       # reopen the same filename if no argument, do nothing for IO
// 50:       log ||= @filename if @filename
// 51:       @binmode = binmode unless binmode.nil?
// 52:       if log
// 53:         synchronize do
// 54:           if @filename and @dev
// 55:             @dev.close rescue nil # close only file opened by Logger
// 56:             @filename = nil
// 57:           end
// 58:           set_dev(log)
// 59:           set_file(shift_age, shift_size, shift_period_suffix) if @filename
// 60:         end
// 61:       end
// 62:       self
// 63:     end
// 64:
// 65:   private
// 66:
// 67:     # :stopdoc:
// 68:
// 69:     MODE = File::WRONLY | File::APPEND
// 70:     # TruffleRuby < 24.2 does not have File::SHARE_DELETE
// 71:     if File.const_defined? :SHARE_DELETE
// 72:       MODE_TO_OPEN = MODE | File::SHARE_DELETE | File::BINARY
// 73:     else
// 74:       MODE_TO_OPEN = MODE | File::BINARY
// 75:     end
// 76:     MODE_TO_CREATE = MODE_TO_OPEN | File::CREAT | File::EXCL
// 77:
// 78:     def set_dev(log)
// 79:       if log.respond_to?(:write) and log.respond_to?(:close)
// 80:         @dev = log
// 81:         if log.respond_to?(:path) and path = log.path
// 82:           if File.exist?(path)
// 83:             @filename = path
// 84:           end
// 85:         end
// 86:       else
// 87:         @dev = open_logfile(log)
// 88:         @filename = log
// 89:       end
// 90:     end
// 91:
// 92:     def set_file(shift_age, shift_size, shift_period_suffix)
// 93:       @shift_age = shift_age || @shift_age || 7
// 94:       @shift_size = shift_size || @shift_size || 1048576
// 95:       @shift_period_suffix = shift_period_suffix || @shift_period_suffix || '%Y%m%d'
// 96:
// 97:       unless @shift_age.is_a?(Integer)
// 98:         base_time = @dev.respond_to?(:stat) ? @dev.stat.mtime : Time.now
// 99:         @next_rotate_time = next_rotate_time(base_time, @shift_age)
// 100:       end
// 101:     end
// 102:
// 103:     if MODE_TO_OPEN == MODE
// 104:       def fixup_mode(dev)
// 105:         dev
// 106:       end
// 107:     else
// 108:       def fixup_mode(dev)
// 109:         return dev if @binmode
// 110:         dev.autoclose = false
// 111:         old_dev = dev
// 112:         dev = File.new(dev.fileno, mode: MODE, path: dev.path)
// 113:         old_dev.close
// 114:         PathAttr.set_path(dev, filename) if defined?(PathAttr)
// 115:         dev
// 116:       end
// 117:     end
// 118:
// 119:     def open_logfile(filename)
// 120:       begin
// 121:         dev = File.open(filename, MODE_TO_OPEN)
// 122:       rescue Errno::ENOENT
// 123:         create_logfile(filename)
// 124:       else
// 125:         dev = fixup_mode(dev)
// 126:         dev.sync = true
// 127:         dev.binmode if @binmode
// 128:         dev
// 129:       end
// 130:     end
// 131:
// 132:     def create_logfile(filename)
// 133:       begin
// 134:         logdev = File.open(filename, MODE_TO_CREATE)
// 135:         logdev.flock(File::LOCK_EX)
// 136:         logdev = fixup_mode(logdev)
// 137:         logdev.sync = true
// 138:         logdev.binmode if @binmode
// 139:         add_log_header(logdev) unless @skip_header
// 140:         logdev.flock(File::LOCK_UN)
// 141:         logdev
// 142:       rescue Errno::EEXIST
// 143:         # file is created by another process
// 144:         open_logfile(filename)
// 145:       end
// 146:     end
// 147:
// 148:     def handle_write_errors(mesg)
// 149:       yield
// 150:     rescue *@reraise_write_errors
// 151:       raise
// 152:     rescue
// 153:       warn("log #{mesg} failed. #{$!}")
// 154:     end
// 155:
// 156:     def add_log_header(file)
// 157:       file.write(
// 158:         "# Logfile created on %s by %s\n" % [Time.now.to_s, Logger::ProgName]
// 159:       ) if file.size == 0
// 160:     end
// 161:
// 162:     def check_shift_log
// 163:       if @shift_age.is_a?(Integer)
// 164:         # Note: always returns false if '0'.
// 165:         if @filename && (@shift_age > 0) && (@dev.stat.size > @shift_size)
// 166:           lock_shift_log { shift_log_age }
// 167:         end
// 168:       else
// 169:         now = Time.now
// 170:         if now >= @next_rotate_time
// 171:           @next_rotate_time = next_rotate_time(now, @shift_age)
// 172:           lock_shift_log { shift_log_period(previous_period_end(now, @shift_age)) }
// 173:         end
// 174:       end
// 175:     end
// 176:
// 177:     def lock_shift_log
// 178:       retry_limit = 8
// 179:       retry_sleep = 0.1
// 180:       begin
// 181:         File.open(@filename, MODE_TO_OPEN) do |lock|
// 182:           lock.flock(File::LOCK_EX) # inter-process locking. will be unlocked at closing file
// 183:           if File.identical?(@filename, lock) and File.identical?(lock, @dev)
// 184:             yield # log shifting
// 185:           else
// 186:             # log shifted by another process (i-node before locking and i-node after locking are different)
// 187:             @dev.close rescue nil
// 188:             @dev = open_logfile(@filename)
// 189:           end
// 190:         end
// 191:         true
// 192:       rescue Errno::ENOENT
// 193:         # @filename file would not exist right after #rename and before #create_logfile
// 194:         if retry_limit <= 0
// 195:           warn("log rotation inter-process lock failed. #{$!}")
// 196:         else
// 197:           sleep retry_sleep
// 198:           retry_limit -= 1
// 199:           retry_sleep *= 2
// 200:           retry
// 201:         end
// 202:       end
// 203:     rescue
// 204:       warn("log rotation inter-process lock failed. #{$!}")
// 205:     end
// 206:
// 207:     def shift_log_age
// 208:       (@shift_age-3).downto(0) do |i|
// 209:         if FileTest.exist?("#{@filename}.#{i}")
// 210:           File.rename("#{@filename}.#{i}", "#{@filename}.#{i+1}")
// 211:         end
// 212:       end
// 213:       shift_log_file("#{@filename}.0")
// 214:     end
// 215:
// 216:     def shift_log_period(period_end)
// 217:       suffix = period_end.strftime(@shift_period_suffix)
// 218:       age_file = "#{@filename}.#{suffix}"
// 219:       if FileTest.exist?(age_file)
// 220:         # try to avoid filename crash caused by Timestamp change.
// 221:         idx = 0
// 222:         # .99 can be overridden; avoid too much file search with 'loop do'
// 223:         while idx < 100
// 224:           idx += 1
// 225:           age_file = "#{@filename}.#{suffix}.#{idx}"
// 226:           break unless FileTest.exist?(age_file)
// 227:         end
// 228:       end
// 229:       shift_log_file(age_file)
// 230:     end
// 231:
// 232:     def shift_log_file(shifted)
// 233:       stat = @dev.stat
// 234:       @dev.close rescue nil
// 235:       File.rename(@filename, shifted)
// 236:       @dev = create_logfile(@filename)
// 237:       mode, uid, gid = stat.mode, stat.uid, stat.gid
// 238:       begin
// 239:         @dev.chmod(mode) if mode
// 240:         mode = nil
// 241:         @dev.chown(uid, gid)
// 242:       rescue Errno::EPERM
// 243:         if mode
// 244:           # failed to chmod, probably nothing can do more.
// 245:         elsif uid
// 246:           uid = nil
// 247:           retry # to change gid only
// 248:         end
// 249:       end
// 250:       return true
// 251:     end
// 252:   end
// 253: end
// 254:
// 255: File.open(__FILE__) do |f|
// 256:   File.new(f.fileno, autoclose: false, path: "").path
// 257: rescue IOError
// 258:   module PathAttr               # :nodoc:
// 259:     attr_reader :path
// 260:
// 261:     def self.set_path(file, path)
// 262:       file.extend(self).instance_variable_set(:@path, path)
// 263:     end
// 264:   end
// 265: end
