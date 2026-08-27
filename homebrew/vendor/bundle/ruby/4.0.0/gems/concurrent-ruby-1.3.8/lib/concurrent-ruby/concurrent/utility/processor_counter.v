module utility

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/processor_counter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 11.
pub fn ruby_processor_counter_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `processor_count` at line 18.
pub fn ruby_processor_counter_l18_d2_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processor_count', ...args)
}

// Ruby method `physical_processor_count` at line 22.
pub fn ruby_processor_counter_l22_d3_physical_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('physical_processor_count', ...args)
}

// Ruby method `available_processor_count` at line 26.
pub fn ruby_processor_counter_l26_d4_available_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available_processor_count', ...args)
}

// Ruby method `cpu_quota` at line 41.
pub fn ruby_processor_counter_l41_d5_cpu_quota(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpu_quota', ...args)
}

// Ruby method `cpu_shares` at line 45.
pub fn ruby_processor_counter_l45_d6_cpu_shares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpu_shares', ...args)
}

// Ruby method `compute_processor_count` at line 51.
pub fn ruby_processor_counter_l51_d7_compute_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_processor_count', ...args)
}

// Ruby method `compute_physical_processor_count` at line 59.
pub fn ruby_processor_counter_l59_d8_compute_physical_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_physical_processor_count', ...args)
}

// Ruby method `run(command)` at line 99.
pub fn ruby_processor_counter_l99_d9_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `compute_cpu_quota` at line 104.
pub fn ruby_processor_counter_l104_d10_compute_cpu_quota(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_cpu_quota', ...args)
}

// Ruby method `compute_cpu_shares` at line 124.
pub fn ruby_processor_counter_l124_d11_compute_cpu_shares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compute_cpu_shares', ...args)
}

// Ruby attr_reader `singleton_class.send :attr_reader, :processor_counter` at line 142.
pub fn ruby_processor_counter_l142_d12_processor_counter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processor_counter', ...args)
}

// Ruby method `self.processor_count` at line 160.
pub fn ruby_processor_counter_l160_d13_self_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.processor_count', ...args)
}

// Ruby method `self.physical_processor_count` at line 181.
pub fn ruby_processor_counter_l181_d14_self_physical_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.physical_processor_count', ...args)
}

// Ruby method `self.available_processor_count` at line 194.
pub fn ruby_processor_counter_l194_d15_self_available_processor_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.available_processor_count', ...args)
}

// Ruby method `self.cpu_quota` at line 209.
pub fn ruby_processor_counter_l209_d16_self_cpu_quota(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cpu_quota', ...args)
}

// Ruby method `self.cpu_shares` at line 217.
pub fn ruby_processor_counter_l217_d17_self_cpu_shares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cpu_shares', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'etc'
// 2: require 'rbconfig'
// 3: require 'concurrent/delay'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   module Utility
// 8:
// 9:     # @!visibility private
// 10:     class ProcessorCounter
// 11:       def initialize
// 12:         @processor_count          = Delay.new { compute_processor_count }
// 13:         @physical_processor_count = Delay.new { compute_physical_processor_count }
// 14:         @cpu_quota                = Delay.new { compute_cpu_quota }
// 15:         @cpu_shares               = Delay.new { compute_cpu_shares }
// 16:       end
// 17:
// 18:       def processor_count
// 19:         @processor_count.value
// 20:       end
// 21:
// 22:       def physical_processor_count
// 23:         @physical_processor_count.value
// 24:       end
// 25:
// 26:       def available_processor_count
// 27:         cpu_count = processor_count.to_f
// 28:         quota = cpu_quota
// 29:
// 30:         return cpu_count if quota.nil?
// 31:
// 32:         # cgroup cpus quotas have no limits, so they can be set to higher than the
// 33:         # real count of cores.
// 34:         if quota > cpu_count
// 35:           cpu_count
// 36:         else
// 37:           quota
// 38:         end
// 39:       end
// 40:
// 41:       def cpu_quota
// 42:         @cpu_quota.value
// 43:       end
// 44:
// 45:       def cpu_shares
// 46:         @cpu_shares.value
// 47:       end
// 48:
// 49:       private
// 50:
// 51:       def compute_processor_count
// 52:         if Concurrent.on_jruby?
// 53:           java.lang.Runtime.getRuntime.availableProcessors
// 54:         else
// 55:           Etc.nprocessors
// 56:         end
// 57:       end
// 58:
// 59:       def compute_physical_processor_count
// 60:         ppc = case RbConfig::CONFIG["target_os"]
// 61:               when /darwin\d\d/
// 62:                 IO.popen("/usr/sbin/sysctl -n hw.physicalcpu", &:read).to_i
// 63:               when /linux/
// 64:                 cores = {} # unique physical ID / core ID combinations
// 65:                 phy   = 0
// 66:                 IO.read("/proc/cpuinfo").scan(/^physical id.*|^core id.*/) do |ln|
// 67:                   if ln.start_with?("physical")
// 68:                     phy = ln[/\d+/]
// 69:                   elsif ln.start_with?("core")
// 70:                     cid        = phy + ":" + ln[/\d+/]
// 71:                     cores[cid] = true if not cores[cid]
// 72:                   end
// 73:                 end
// 74:                 cores.count
// 75:               when /mswin|mingw/
// 76:                 # Get-CimInstance introduced in PowerShell 3 or earlier: https://learn.microsoft.com/en-us/previous-versions/powershell/module/cimcmdlets/get-ciminstance?view=powershell-3.0
// 77:                 result = run('powershell -command "Get-CimInstance -ClassName Win32_Processor -Property NumberOfCores | Select-Object -Property NumberOfCores"')
// 78:                 if !result || $?.exitstatus != 0
// 79:                   # fallback to deprecated wmic for older systems
// 80:                   result = run("wmic cpu get NumberOfCores")
// 81:                 end
// 82:                 if !result || $?.exitstatus != 0
// 83:                   # Bail out if both commands returned something unexpected
// 84:                   processor_count
// 85:                 else
// 86:                   # powershell: "\nNumberOfCores\n-------------\n            4\n\n\n"
// 87:                   # wmic:       "NumberOfCores  \n\n4              \n\n\n\n"
// 88:                   result.scan(/\d+/).map(&:to_i).reduce(:+)
// 89:                 end
// 90:               else
// 91:                 processor_count
// 92:               end
// 93:         # fall back to logical count if physical info is invalid
// 94:         ppc > 0 ? ppc : processor_count
// 95:       rescue
// 96:         return 1
// 97:       end
// 98:
// 99:       def run(command)
// 100:         IO.popen(command, &:read)
// 101:       rescue Errno::ENOENT
// 102:       end
// 103:
// 104:       def compute_cpu_quota
// 105:         if RbConfig::CONFIG["target_os"].include?("linux")
// 106:           if File.exist?("/sys/fs/cgroup/cpu.max")
// 107:             # cgroups v2: https://docs.kernel.org/admin-guide/cgroup-v2.html#cpu-interface-files
// 108:             cpu_max = File.read("/sys/fs/cgroup/cpu.max")
// 109:             return nil if cpu_max.start_with?("max ") # no limit
// 110:             max, period = cpu_max.split.map(&:to_f)
// 111:             max / period
// 112:           elsif File.exist?("/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us")
// 113:             # cgroups v1: https://kernel.googlesource.com/pub/scm/linux/kernel/git/glommer/memcg/+/cpu_stat/Documentation/cgroups/cpu.txt
// 114:             max = File.read("/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_quota_us").to_i
// 115:             # If the cpu.cfs_quota_us is -1, cgroup does not adhere to any CPU time restrictions
// 116:             # https://docs.kernel.org/scheduler/sched-bwc.html#management
// 117:             return nil if max <= 0
// 118:             period = File.read("/sys/fs/cgroup/cpu,cpuacct/cpu.cfs_period_us").to_f
// 119:             max / period
// 120:           end
// 121:         end
// 122:       end
// 123:
// 124:       def compute_cpu_shares
// 125:         if RbConfig::CONFIG["target_os"].include?("linux")
// 126:           if File.exist?("/sys/fs/cgroup/cpu.weight")
// 127:             # cgroups v2: https://docs.kernel.org/admin-guide/cgroup-v2.html#cpu-interface-files
// 128:             # Ref: https://github.com/kubernetes/enhancements/tree/master/keps/sig-node/2254-cgroup-v2#phase-1-convert-from-cgroups-v1-settings-to-v2
// 129:             weight = File.read("/sys/fs/cgroup/cpu.weight").to_f
// 130:             ((((weight - 1) * 262142) / 9999) + 2) / 1024
// 131:           elsif File.exist?("/sys/fs/cgroup/cpu/cpu.shares")
// 132:             # cgroups v1: https://kernel.googlesource.com/pub/scm/linux/kernel/git/glommer/memcg/+/cpu_stat/Documentation/cgroups/cpu.txt
// 133:             File.read("/sys/fs/cgroup/cpu/cpu.shares").to_f / 1024
// 134:           end
// 135:         end
// 136:       end
// 137:     end
// 138:   end
// 139:
// 140:   # create the default ProcessorCounter on load
// 141:   @processor_counter = Utility::ProcessorCounter.new
// 142:   singleton_class.send :attr_reader, :processor_counter
// 143:
// 144:   # Number of processors seen by the OS and used for process scheduling. For
// 145:   # performance reasons the calculated value will be memoized on the first
// 146:   # call.
// 147:   #
// 148:   # When running under JRuby the Java runtime call
// 149:   # `java.lang.Runtime.getRuntime.availableProcessors` will be used. According
// 150:   # to the Java documentation this "value may change during a particular
// 151:   # invocation of the virtual machine... [applications] should therefore
// 152:   # occasionally poll this property." We still memoize this value once under
// 153:   # JRuby.
// 154:   #
// 155:   # Otherwise Ruby's Etc.nprocessors will be used.
// 156:   #
// 157:   # @return [Integer] number of processors seen by the OS or Java runtime
// 158:   #
// 159:   # @see http://docs.oracle.com/javase/6/docs/api/java/lang/Runtime.html#availableProcessors()
// 160:   def self.processor_count
// 161:     processor_counter.processor_count
// 162:   end
// 163:
// 164:   # Number of physical processor cores on the current system. For performance
// 165:   # reasons the calculated value will be memoized on the first call.
// 166:   #
// 167:   # On Windows the Win32 API will be queried for the `NumberOfCores from
// 168:   # Win32_Processor`. This will return the total number "of cores for the
// 169:   # current instance of the processor." On Unix-like operating systems either
// 170:   # the `hwprefs` or `sysctl` utility will be called in a subshell and the
// 171:   # returned value will be used. In the rare case where none of these methods
// 172:   # work or an exception is raised the function will simply return 1.
// 173:   #
// 174:   # @return [Integer] number physical processor cores on the current system
// 175:   #
// 176:   # @see https://github.com/grosser/parallel/blob/4fc8b89d08c7091fe0419ca8fba1ec3ce5a8d185/lib/parallel.rb
// 177:   #
// 178:   # @see http://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
// 179:   # @see http://www.unix.com/man-page/osx/1/HWPREFS/
// 180:   # @see http://linux.die.net/man/8/sysctl
// 181:   def self.physical_processor_count
// 182:     processor_counter.physical_processor_count
// 183:   end
// 184:
// 185:   # Number of processors cores available for process scheduling.
// 186:   # This method takes in account the CPU quota if the process is inside a cgroup with a
// 187:   # dedicated CPU quota (typically Docker).
// 188:   # Otherwise it returns the same value as #processor_count but as a Float.
// 189:   #
// 190:   # For performance reasons the calculated value will be memoized on the first
// 191:   # call.
// 192:   #
// 193:   # @return [Float] number of available processors
// 194:   def self.available_processor_count
// 195:     processor_counter.available_processor_count
// 196:   end
// 197:
// 198:   # The maximum number of processors cores available for process scheduling.
// 199:   # Returns `nil` if there is no enforced limit, or a `Float` if the
// 200:   # process is inside a cgroup with a dedicated CPU quota (typically Docker).
// 201:   #
// 202:   # Note that nothing prevents setting a CPU quota higher than the actual number of
// 203:   # cores on the system.
// 204:   #
// 205:   # For performance reasons the calculated value will be memoized on the first
// 206:   # call.
// 207:   #
// 208:   # @return [nil, Float] Maximum number of available processors as set by a cgroup CPU quota, or nil if none set
// 209:   def self.cpu_quota
// 210:     processor_counter.cpu_quota
// 211:   end
// 212:
// 213:   # The CPU shares requested by the process. For performance reasons the calculated
// 214:   # value will be memoized on the first call.
// 215:   #
// 216:   # @return [Float, nil] CPU shares requested by the process, or nil if not set
// 217:   def self.cpu_shares
// 218:     processor_counter.cpu_shares
// 219:   end
// 220: end
