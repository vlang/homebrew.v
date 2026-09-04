module homebrew

import ruby
import os

pub struct HardwareCpu {
pub:
	platform          string
	cores             int
	big_endian        bool
	virtualized       bool
	features          []string
	family            string
	in_rosetta2       bool
	rosetta_installed bool
}

pub fn current_hardware_cpu() &HardwareCpu {
	platform := os.uname().machine
	result := ruby.run_command('getconf', ['_NPROCESSORS_ONLN'])
	cores := if result.exit_code == 0 && result.output.trim_space().int() > 0 {
		result.output.trim_space().int()
	} else {
		1
	}
	return &HardwareCpu{ platform: platform, cores: cores }
}

pub fn hardware_cpu_type(platform string) string {
	lower := platform.to_lower()
	if lower.contains('x86_64') || lower.contains('i386') || lower.contains('i486') || lower.contains('i586') || lower.contains('i686') {
		return 'intel'
	}
	if lower.contains('arm') || lower.contains('aarch64') {
		return 'arm'
	}
	if lower.contains('ppc') || lower.contains('powerpc') {
		return 'ppc'
	}
	return 'dunno'
}

pub fn hardware_cpu_bits(platform string) int {
	lower := platform.to_lower()
	if lower.contains('x86_64') || lower.contains('ppc64') || lower.contains('powerpc64') || lower.contains('aarch64') || lower.contains('arm64') {
		return 64
	}
	if lower.contains('i386') || lower.contains('i486') || lower.contains('i586') || lower.contains('i686') || lower.contains('ppc') || lower.contains('arm') {
		return 32
	}
	return 0
}

pub fn hardware_cpu_arch(cpu HardwareCpu) string {
	kind := hardware_cpu_type(cpu.platform)
	bits := hardware_cpu_bits(cpu.platform)
	if kind == 'arm' {
		return if bits == 64 { 'arm64' } else { 'arm' }
	}
	if kind == 'intel' {
		return if bits == 64 { 'x86_64' } else { 'i386' }
	}
	if kind == 'ppc' && bits == 32 {
		return 'ppc32'
	}
	if kind == 'ppc' && bits == 64 {
		return if cpu.big_endian { 'ppc64' } else { 'ppc64le' }
	}
	return 'dunno'
}

pub fn hardware_arch_flag(cpu HardwareCpu, arch string) string {
	return if hardware_cpu_type(cpu.platform) == 'ppc' { '-mcpu=${arch}' } else { '-march=${arch}' }
}

pub fn hardware_optimization_flags(cpu HardwareCpu) map[string]string {
	return {
		'dunno':              ''
		'native':             hardware_arch_flag(cpu, 'native')
		'ivybridge':          '-march=ivybridge'
		'sandybridge':        '-march=sandybridge'
		'westmere':           '-march=westmere'
		'nehalem':            '-march=nehalem'
		'core2':              '-march=core2'
		'core':               '-march=prescott'
		'arm_vortex_tempest': ''
		'armv6':              '-march=armv6'
		'armv8':              '-march=armv8-a'
		'ppc64':              '-mcpu=powerpc64'
		'ppc64le':            '-mcpu=powerpc64le'
	}
}

pub fn hardware_cores_as_words(cores int) string {
	return match cores {
		1 { 'single' }
		2 { 'dual' }
		4 { 'quad' }
		6 { 'hexa' }
		8 { 'octa' }
		10 { 'deca' }
		12 { 'dodeca' }
		else { cores.str() }
	}
}

pub fn hardware_oldest_cpu(cpu HardwareCpu) string {
	kind := hardware_cpu_type(cpu.platform)
	bits := hardware_cpu_bits(cpu.platform)
	if kind == 'intel' {
		return if bits == 64 { 'core2' } else { 'core' }
	}
	if kind == 'arm' {
		return if bits == 64 { 'armv8' } else { 'armv6' }
	}
	if kind == 'ppc' && bits == 64 {
		return if cpu.big_endian { 'ppc64' } else { 'ppc64le' }
	}
	return if cpu.family == '' { 'dunno' } else { cpu.family }
}

pub fn hardware_rustflags_target_cpu(arch string) ?string {
	target := match arch {
		'core' { 'prescott' }
		'native', 'ivybridge', 'sandybridge', 'westmere', 'nehalem', 'core2' { arch }
		else { '' }
	}
	return if target == '' { none } else { '--codegen target-cpu=${target}' }
}

pub fn hardware_zig_cpu(arch string) string {
	return match arch {
		'arm_vortex_tempest' { 'apple_m1' }
		'armv6' { 'arm1136j_s' }
		'armv8' { 'xgene1' }
		'core' { 'prescott' }
		'dunno' { 'baseline' }
		else { arch.replace('-', '_') }
	}
}

pub fn hardware_cpu_value(cpu &HardwareCpu) ruby.Value {
	return ruby.structured_value('Hardware::CPU', hardware_cpu_arch(*cpu), {
		'cpu_address': u64(voidptr(cpu)).str()
	})
}

fn hardware_cpu_from_args(args []ruby.Value) (&HardwareCpu, int) {
	if args.len > 0 && args[0].type_name == 'Hardware::CPU' {
		address := args[0].attributes['cpu_address'] or { panic('invalid Hardware::CPU') }
		return unsafe { &HardwareCpu(voidptr(address.u64())) }, 1
	}
	return current_hardware_cpu(), 0
}

fn hardware_optional_value(value ?string) ruby.Value {
	if item := value {
		return ruby.string_value(item)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Translated from Homebrew/brew `hardware.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `optimization_flags` at line 29.
pub fn ruby_hardware_l29_d1_optimization_flags(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	mut values := map[string]ruby.Value{}
	for name, flag in hardware_optimization_flags(*cpu) {
		values[name] = ruby.string_value(flag)
	}
	return ruby.map_value(values)
}

// Ruby method `arch_32_bit` at line 48.
pub fn ruby_hardware_l48_d2_arch_32_bit(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	mut copy := HardwareCpu{
		...*cpu
		platform: match hardware_cpu_type(cpu.platform) {
			'intel' { 'i386' }
			'arm' { 'arm' }
			'ppc' { 'ppc' }
			else { cpu.platform }
		}
	}
	return ruby.string_value(hardware_cpu_arch(copy))
}

// Ruby method `arch_64_bit` at line 61.
pub fn ruby_hardware_l61_d3_arch_64_bit(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	mut copy := HardwareCpu{
		...*cpu
		platform: match hardware_cpu_type(cpu.platform) {
			'intel' { 'x86_64' }
			'arm' { 'arm64' }
			'ppc' {
				if cpu.big_endian { 'ppc64' } else { 'ppc64le' }
			}
			else { cpu.platform }
		}
	}
	return ruby.string_value(hardware_cpu_arch(copy))
}

// Ruby method `arch` at line 76.
pub fn ruby_hardware_l76_d4_arch(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_value(hardware_cpu_arch(*cpu))
}

// Ruby method `type` at line 88.
pub fn ruby_hardware_l88_d5_type(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_value(hardware_cpu_type(cpu.platform))
}

// Ruby method `family` at line 98.
pub fn ruby_hardware_l98_d6_family(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_value(if cpu.family == '' { 'dunno' } else { cpu.family })
}

// Ruby method `cores` at line 103.
pub fn ruby_hardware_l103_d7_cores(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.int_value(cpu.cores)
}

// Ruby method `bits` at line 114.
pub fn ruby_hardware_l114_d8_bits(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	bits := hardware_cpu_bits(cpu.platform)
	return if bits == 0 {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.int_value(bits)
	}
}

// Ruby method `sse4?` at line 122.
pub fn ruby_hardware_l122_d9_sse4(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(cpu.platform.contains('x86_64'))
}

// Ruby method `is_32_bit?` at line 127.
pub fn ruby_hardware_l127_d10_is_32_bit(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_bits(cpu.platform) == 32)
}

// Ruby method `is_64_bit?` at line 132.
pub fn ruby_hardware_l132_d11_is_64_bit(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_bits(cpu.platform) == 64)
}

// Ruby method `intel?` at line 137.
pub fn ruby_hardware_l137_d12_intel(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'intel')
}

// Ruby method `ppc?` at line 142.
pub fn ruby_hardware_l142_d13_ppc(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'ppc')
}

// Ruby method `ppc32?` at line 147.
pub fn ruby_hardware_l147_d14_ppc32(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'ppc' && hardware_cpu_bits(cpu.platform) == 32)
}

// Ruby method `ppc64le?` at line 152.
pub fn ruby_hardware_l152_d15_ppc64le(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'ppc' && hardware_cpu_bits(cpu.platform) == 64 && !cpu.big_endian)
}

// Ruby method `ppc64?` at line 157.
pub fn ruby_hardware_l157_d16_ppc64(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'ppc' && hardware_cpu_bits(cpu.platform) == 64 && cpu.big_endian)
}

// Ruby method `arm?` at line 165.
pub fn ruby_hardware_l165_d17_arm(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'arm')
}

// Ruby method `arm64?` at line 171.
pub fn ruby_hardware_l171_d18_arm64(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(hardware_cpu_type(cpu.platform) == 'arm' && hardware_cpu_bits(cpu.platform) == 64)
}

// Ruby method `little_endian?` at line 176.
pub fn ruby_hardware_l176_d19_little_endian(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(!cpu.big_endian)
}

// Ruby method `big_endian?` at line 181.
pub fn ruby_hardware_l181_d20_big_endian(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(cpu.big_endian)
}

// Ruby method `virtualized?` at line 186.
pub fn ruby_hardware_l186_d21_virtualized(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(cpu.virtualized)
}

// Ruby method `features` at line 191.
pub fn ruby_hardware_l191_d22_features(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_array_value(cpu.features)
}

// Ruby method `feature?(name)` at line 196.
pub fn ruby_hardware_l196_d23_feature(args ...ruby.Value) ruby.Value {
	cpu, offset := hardware_cpu_from_args(args)
	if args.len <= offset { panic('feature? requires a name') }
	return ruby.bool_value(args[offset].as_string() in cpu.features)
}

// Ruby method `arch_flag(arch)` at line 201.
pub fn ruby_hardware_l201_d24_arch_flag(args ...ruby.Value) ruby.Value {
	cpu, offset := hardware_cpu_from_args(args)
	if args.len <= offset { panic('arch_flag requires an architecture') }
	return ruby.string_value(hardware_arch_flag(*cpu, args[offset].as_string()))
}

// Ruby method `in_rosetta2?` at line 208.
pub fn ruby_hardware_l208_d25_in_rosetta2(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(cpu.in_rosetta2)
}

// Ruby method `rosetta_installed?` at line 213.
pub fn ruby_hardware_l213_d26_rosetta_installed(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.bool_value(cpu.rosetta_installed)
}

// Ruby method `cores_as_words` at line 221.
pub fn ruby_hardware_l221_d27_cores_as_words(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_value(hardware_cores_as_words(cpu.cores))
}

// Ruby method `oldest_cpu(_version = nil)` at line 236.
pub fn ruby_hardware_l236_d28_oldest_cpu(args ...ruby.Value) ruby.Value {
	cpu, _ := hardware_cpu_from_args(args)
	return ruby.string_value(hardware_oldest_cpu(*cpu))
}

// Ruby method `rustflags_target_cpu(arch)` at line 263.
pub fn ruby_hardware_l263_d29_rustflags_target_cpu(args ...ruby.Value) ruby.Value {
	_, offset := hardware_cpu_from_args(args)
	if args.len <= offset { panic('rustflags_target_cpu requires an architecture') }
	return hardware_optional_value(hardware_rustflags_target_cpu(args[offset].as_string()))
}

// Ruby method `zig_cpu(arch)` at line 283.
pub fn ruby_hardware_l283_d30_zig_cpu(args ...ruby.Value) ruby.Value {
	_, offset := hardware_cpu_from_args(args)
	if args.len <= offset { panic('zig_cpu requires an architecture') }
	return ruby.string_value(hardware_zig_cpu(args[offset].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/popen"
// 5:
// 6: # Helper module for querying hardware information.
// 7: module Hardware
// 8:   # Helper module for querying CPU information.
// 9:   class CPU
// 10:     INTEL_32BIT_ARCHS = [:i386].freeze
// 11:     INTEL_64BIT_ARCHS = [:x86_64].freeze
// 12:     INTEL_ARCHS       = T.let((INTEL_32BIT_ARCHS + INTEL_64BIT_ARCHS).freeze, T::Array[Symbol])
// 13:     PPC_32BIT_ARCHS   = [:ppc, :ppc32, :ppc7400, :ppc7450, :ppc970].freeze
// 14:     PPC_64BIT_ARCHS   = [:ppc64, :ppc64le, :ppc970].freeze
// 15:     PPC_ARCHS         = T.let((PPC_32BIT_ARCHS + PPC_64BIT_ARCHS).freeze, T::Array[Symbol])
// 16:     ARM_64BIT_ARCHS   = [:arm64, :aarch64].freeze
// 17:     ARM_ARCHS         = ARM_64BIT_ARCHS
// 18:     ALL_ARCHS = T.let([
// 19:       *INTEL_ARCHS,
// 20:       *PPC_ARCHS,
// 21:       *ARM_ARCHS,
// 22:     ].freeze, T::Array[Symbol])
// 23:
// 24:     INTEL_64BIT_OLDEST_CPU = :core2
// 25:     ROSETTA_RUNTIME_PATH = "/Library/Apple/usr/libexec/oah/libRosettaRuntime"
// 26:
// 27:     class << self
// 28:       sig { returns(T::Hash[Symbol, String]) }
// 29:       def optimization_flags
// 30:         @optimization_flags ||= T.let({
// 31:           dunno:              "",
// 32:           native:             arch_flag("native"),
// 33:           ivybridge:          "-march=ivybridge",
// 34:           sandybridge:        "-march=sandybridge",
// 35:           westmere:           "-march=westmere",
// 36:           nehalem:            "-march=nehalem",
// 37:           core2:              "-march=core2",
// 38:           core:               "-march=prescott",
// 39:           arm_vortex_tempest: "", # TODO: -mcpu=apple-m1 when we've patched all our GCCs to support it
// 40:           armv6:              "-march=armv6",
// 41:           armv8:              "-march=armv8-a",
// 42:           ppc64:              "-mcpu=powerpc64",
// 43:           ppc64le:            "-mcpu=powerpc64le",
// 44:         }.freeze, T.nilable(T::Hash[Symbol, String]))
// 45:       end
// 46:
// 47:       sig { returns(Symbol) }
// 48:       def arch_32_bit
// 49:         if arm?
// 50:           :arm
// 51:         elsif intel?
// 52:           :i386
// 53:         elsif ppc32?
// 54:           :ppc32
// 55:         else
// 56:           :dunno
// 57:         end
// 58:       end
// 59:
// 60:       sig { returns(Symbol) }
// 61:       def arch_64_bit
// 62:         if arm?
// 63:           :arm64
// 64:         elsif intel?
// 65:           :x86_64
// 66:         elsif ppc64le?
// 67:           :ppc64le
// 68:         elsif ppc64?
// 69:           :ppc64
// 70:         else
// 71:           :dunno
// 72:         end
// 73:       end
// 74:
// 75:       sig { returns(Symbol) }
// 76:       def arch
// 77:         case bits
// 78:         when 32
// 79:           arch_32_bit
// 80:         when 64
// 81:           arch_64_bit
// 82:         else
// 83:           :dunno
// 84:         end
// 85:       end
// 86:
// 87:       sig { returns(Symbol) }
// 88:       def type
// 89:         case RUBY_PLATFORM
// 90:         when /x86_64/, /i\d86/ then :intel
// 91:         when /arm/, /aarch64/ then :arm
// 92:         when /ppc|powerpc/ then :ppc
// 93:         else :dunno
// 94:         end
// 95:       end
// 96:
// 97:       sig { returns(Symbol) }
// 98:       def family
// 99:         :dunno
// 100:       end
// 101:
// 102:       sig { returns(Integer) }
// 103:       def cores
// 104:         @cores ||= T.let(
// 105:           begin
// 106:             cores = Utils.popen_read("getconf", "_NPROCESSORS_ONLN").chomp.to_i
// 107:             $CHILD_STATUS.success? ? cores : 1
// 108:           end,
// 109:           T.nilable(Integer),
// 110:         )
// 111:       end
// 112:
// 113:       sig { returns(T.nilable(Integer)) }
// 114:       def bits
// 115:         @bits ||= T.let(case RUBY_PLATFORM
// 116:         when /x86_64/, /ppc64|powerpc64/, /aarch64|arm64/ then 64
// 117:         when /i\d86/, /ppc/, /arm/ then 32
// 118:         end, T.nilable(Integer))
// 119:       end
// 120:
// 121:       sig { returns(T::Boolean) }
// 122:       def sse4?
// 123:         RUBY_PLATFORM.to_s.include?("x86_64")
// 124:       end
// 125:
// 126:       sig { returns(T::Boolean) }
// 127:       def is_32_bit?
// 128:         bits == 32
// 129:       end
// 130:
// 131:       sig { returns(T::Boolean) }
// 132:       def is_64_bit?
// 133:         bits == 64
// 134:       end
// 135:
// 136:       sig { returns(T::Boolean) }
// 137:       def intel?
// 138:         type == :intel
// 139:       end
// 140:
// 141:       sig { returns(T::Boolean) }
// 142:       def ppc?
// 143:         type == :ppc
// 144:       end
// 145:
// 146:       sig { returns(T::Boolean) }
// 147:       def ppc32?
// 148:         ppc? && is_32_bit?
// 149:       end
// 150:
// 151:       sig { returns(T::Boolean) }
// 152:       def ppc64le?
// 153:         ppc? && is_64_bit? && little_endian?
// 154:       end
// 155:
// 156:       sig { returns(T::Boolean) }
// 157:       def ppc64?
// 158:         ppc? && is_64_bit? && big_endian?
// 159:       end
// 160:
// 161:       # Check whether the CPU architecture is ARM.
// 162:       #
// 163:       # @api internal
// 164:       sig { returns(T::Boolean) }
// 165:       def arm?
// 166:         type == :arm
// 167:       end
// 168:
// 169:       # Check whether the CPU architecture is 64-bit ARM.
// 170:       sig { returns(T::Boolean) }
// 171:       def arm64?
// 172:         arm? && is_64_bit?
// 173:       end
// 174:
// 175:       sig { returns(T::Boolean) }
// 176:       def little_endian?
// 177:         !big_endian?
// 178:       end
// 179:
// 180:       sig { returns(T::Boolean) }
// 181:       def big_endian?
// 182:         [1].pack("I") == [1].pack("N")
// 183:       end
// 184:
// 185:       sig { returns(T::Boolean) }
// 186:       def virtualized?
// 187:         false
// 188:       end
// 189:
// 190:       sig { returns(T::Array[Symbol]) }
// 191:       def features
// 192:         []
// 193:       end
// 194:
// 195:       sig { params(name: Symbol).returns(T::Boolean) }
// 196:       def feature?(name)
// 197:         features.include?(name)
// 198:       end
// 199:
// 200:       sig { params(arch: T.any(String, Symbol)).returns(String) }
// 201:       def arch_flag(arch)
// 202:         return "-mcpu=#{arch}" if ppc?
// 203:
// 204:         "-march=#{arch}"
// 205:       end
// 206:
// 207:       sig { returns(T::Boolean) }
// 208:       def in_rosetta2?
// 209:         false
// 210:       end
// 211:
// 212:       sig { returns(T::Boolean) }
// 213:       def rosetta_installed?
// 214:         false
// 215:       end
// 216:     end
// 217:   end
// 218:
// 219:   class << self
// 220:     sig { returns(String) }
// 221:     def cores_as_words
// 222:       case Hardware::CPU.cores
// 223:       when 1 then "single"
// 224:       when 2 then "dual"
// 225:       when 4 then "quad"
// 226:       when 6 then "hexa"
// 227:       when 8 then "octa"
// 228:       when 10 then "deca"
// 229:       when 12 then "dodeca"
// 230:       else
// 231:         Hardware::CPU.cores.to_s
// 232:       end
// 233:     end
// 234:
// 235:     sig { params(_version: T.nilable(MacOSVersion)).returns(Symbol) }
// 236:     def oldest_cpu(_version = nil)
// 237:       if Hardware::CPU.intel?
// 238:         if Hardware::CPU.is_64_bit?
// 239:           Hardware::CPU::INTEL_64BIT_OLDEST_CPU
// 240:         else
// 241:           :core
// 242:         end
// 243:       elsif Hardware::CPU.arm?
// 244:         if Hardware::CPU.is_64_bit?
// 245:           :armv8
// 246:         else
// 247:           :armv6
// 248:         end
// 249:       elsif Hardware::CPU.ppc? && Hardware::CPU.is_64_bit?
// 250:         if Hardware::CPU.little_endian?
// 251:           :ppc64le
// 252:         else
// 253:           :ppc64
// 254:         end
// 255:       else
// 256:         Hardware::CPU.family
// 257:       end
// 258:     end
// 259:
// 260:     # Returns a Rust flag to set the target CPU if necessary.
// 261:     # Defaults to nil.
// 262:     sig { params(arch: Symbol).returns(T.nilable(String)) }
// 263:     def rustflags_target_cpu(arch)
// 264:       # Rust already defaults to the oldest supported cpu for each target-triplet
// 265:       # so it's safe to ignore generic archs such as :armv6 here.
// 266:       # Rust defaults to apple-m1 since Rust 1.71 for aarch64-apple-darwin.
// 267:       @target_cpu ||= T.let(case arch
// 268:       when :core
// 269:         :prescott
// 270:       when :native, :ivybridge, :sandybridge, :westmere, :nehalem, :core2
// 271:         arch
// 272:       end, T.nilable(Symbol))
// 273:       return if @target_cpu.blank?
// 274:
// 275:       "--codegen target-cpu=#{@target_cpu}"
// 276:     end
// 277:
// 278:     # Returns the closest Zig target CPU for the requested brew-supported
// 279:     # architecture symbol. See `zig targets` for available CPUs.
// 280:     #
// 281:     # @see https://github.com/Homebrew/homebrew-core/issues/92282
// 282:     sig { params(arch: Symbol).returns(Symbol) }
// 283:     def zig_cpu(arch)
// 284:       case arch
// 285:       when :arm_vortex_tempest then :apple_m1
// 286:       when :armv6 then :arm1136j_s
// 287:       when :armv8 then :xgene1
// 288:       when :core  then :prescott
// 289:       when :dunno then :baseline
// 290:       else arch.to_s.tr("-", "_").to_sym
// 291:       end
// 292:     end
// 293:   end
// 294: end
// 295:
// 296: require "extend/os/hardware"
