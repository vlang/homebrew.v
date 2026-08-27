module patchelf

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/saver.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :in_file` at line 22.
pub fn ruby_saver_l22_d1_in_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('in_file', ...args)
}

// Ruby attr_reader `attr_reader :out_file` at line 23.
pub fn ruby_saver_l23_d2_out_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('out_file', ...args)
}

// Ruby method `initialize(in_file, out_file, set)` at line 29.
pub fn ruby_saver_l29_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `save!` at line 46.
pub fn ruby_saver_l46_d4_save(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('save!', ...args)
}

// Ruby method `patch_interpreter` at line 62.
pub fn ruby_saver_l62_d5_patch_interpreter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_interpreter', ...args)
}

// Ruby method `patch_dynamic` at line 97.
pub fn ruby_saver_l97_d6_patch_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_dynamic', ...args)
}

// Ruby method `patch_soname` at line 112.
pub fn ruby_saver_l112_d7_patch_soname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_soname', ...args)
}

// Ruby method `patch_runpath(sym = :runpath)` at line 120.
pub fn ruby_saver_l120_d8_patch_runpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_runpath', ...args)
}

// Ruby method `patch_needed` at line 128.
pub fn ruby_saver_l128_d9_patch_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_needed', ...args)
}

// Ruby method `lazy_dyn(sym)` at line 157.
pub fn ruby_saver_l157_d10_lazy_dyn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lazy_dyn', ...args)
}

// Ruby method `expand_dynamic!` at line 165.
pub fn ruby_saver_l165_d11_expand_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expand_dynamic!', ...args)
}

// Ruby method `malloc_strtab!` at line 186.
pub fn ruby_saver_l186_d12_malloc_strtab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('malloc_strtab!', ...args)
}

// Ruby method `reg_str_table(str, &block)` at line 215.
pub fn ruby_saver_l215_d13_reg_str_table(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reg_str_table', ...args)
}

// Ruby method `strtab_string` at line 224.
pub fn ruby_saver_l224_d14_strtab_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strtab_string', ...args)
}

// Ruby method `inline_patch(off, str)` at line 245.
pub fn ruby_saver_l245_d15_inline_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inline_patch', ...args)
}

// Ruby method `patch_out(out_file)` at line 250.
pub fn ruby_saver_l250_d16_patch_out(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_out', ...args)
}

// Ruby method `section_header(name)` at line 278.
pub fn ruby_saver_l278_d17_section_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('section_header', ...args)
}

// Ruby method `dynamic` at line 285.
pub fn ruby_saver_l285_d18_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dynamic', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'elftools/constants'
// 4: require 'elftools/elf_file'
// 5: require 'elftools/structs'
// 6: require 'elftools/util'
// 7: require 'fileutils'
// 8: require 'objspace'
// 9:
// 10: require 'patchelf/helper'
// 11: require 'patchelf/mm'
// 12:
// 13: module PatchELF
// 14:   # To mark a not-using tag
// 15:   IGNORE = ELFTools::Constants::DT_LOOS
// 16:
// 17:   # Internal use only.
// 18:   #
// 19:   # For {Patcher} to do patching things and save to file.
// 20:   # @private
// 21:   class Saver
// 22:     attr_reader :in_file # @return [String] Input filename.
// 23:     attr_reader :out_file # @return [String] Output filename.
// 24:
// 25:     # Instantiate a {Saver} object.
// 26:     # @param [String] in_file
// 27:     # @param [String] out_file
// 28:     # @param [{Symbol => String, Array}] set
// 29:     def initialize(in_file, out_file, set)
// 30:       @in_file = in_file
// 31:       @out_file = out_file
// 32:       @set = set
// 33:       # [{Integer => String}]
// 34:       @inline_patch = {}
// 35:       f = File.open(in_file) # rubocop:disable Style/FileOpen
// 36:       @elf = ELFTools::ELFFile.new(f)
// 37:       @mm = PatchELF::MM.new(@elf)
// 38:       @strtab_extend_requests = []
// 39:       @append_dyn = []
// 40:
// 41:       # Ensure file is closed when the {Saver} object is garbage collected.
// 42:       ObjectSpace.define_finalizer(self, Helper.close_file_proc(f))
// 43:     end
// 44:
// 45:     # @return [void]
// 46:     def save!
// 47:       # In this method we assume all attributes that should exist do exist.
// 48:       # e.g. DT_INTERP, DT_DYNAMIC. These should have been checked in the patcher.
// 49:       patch_interpreter
// 50:       patch_dynamic
// 51:
// 52:       @mm.dispatch!
// 53:
// 54:       FileUtils.cp(in_file, out_file) if out_file != in_file
// 55:       patch_out(@out_file)
// 56:       # Let output file have the same permission as input.
// 57:       FileUtils.chmod(File.stat(in_file).mode, out_file)
// 58:     end
// 59:
// 60:     private
// 61:
// 62:     def patch_interpreter
// 63:       return if @set[:interpreter].nil?
// 64:
// 65:       new_interp = "#{@set[:interpreter]}\x00"
// 66:       old_interp = "#{@elf.segment_by_type(:interp).interp_name}\x00"
// 67:       return if old_interp == new_interp
// 68:
// 69:       # These headers must be found here but not in the proc.
// 70:       seg_header = @elf.segment_by_type(:interp).header
// 71:       sec_header = section_header('.interp')
// 72:
// 73:       patch = proc do |off, vaddr|
// 74:         # Register an inline patching
// 75:         inline_patch(off, new_interp)
// 76:
// 77:         # The patching feature of ELFTools
// 78:         seg_header.p_offset = off
// 79:         seg_header.p_vaddr = seg_header.p_paddr = vaddr
// 80:         seg_header.p_filesz = seg_header.p_memsz = new_interp.size
// 81:
// 82:         if sec_header
// 83:           sec_header.sh_offset = off
// 84:           sec_header.sh_size = new_interp.size
// 85:         end
// 86:       end
// 87:
// 88:       if new_interp.size <= old_interp.size
// 89:         # easy case
// 90:         patch.call(seg_header.p_offset.to_i, seg_header.p_vaddr.to_i)
// 91:       else
// 92:         # hard case, we have to request a new LOAD area
// 93:         @mm.malloc(new_interp.size, &patch)
// 94:       end
// 95:     end
// 96:
// 97:     def patch_dynamic
// 98:       # We never do inline patching on strtab's string.
// 99:       # 1. Search if there's useful string exists
// 100:       #   - only need header patching
// 101:       # 2. Append a new string to the strtab.
// 102:       #   - register strtab extension
// 103:       dynamic.tags # HACK, force @tags to be defined
// 104:       patch_soname if @set[:soname]
// 105:       patch_runpath if @set[:runpath]
// 106:       patch_runpath(:rpath) if @set[:rpath]
// 107:       patch_needed if @set[:needed]
// 108:       malloc_strtab!
// 109:       expand_dynamic!
// 110:     end
// 111:
// 112:     def patch_soname
// 113:       # The tag must exist.
// 114:       so_tag = dynamic.tag_by_type(:soname)
// 115:       reg_str_table(@set[:soname]) do |idx|
// 116:         so_tag.header.d_val = idx
// 117:       end
// 118:     end
// 119:
// 120:     def patch_runpath(sym = :runpath)
// 121:       tag = dynamic.tag_by_type(sym)
// 122:       tag = tag.nil? ? lazy_dyn(sym) : tag.header
// 123:       reg_str_table(@set[sym]) do |idx|
// 124:         tag.d_val = idx
// 125:       end
// 126:     end
// 127:
// 128:     def patch_needed
// 129:       original_needs = dynamic.tags_by_type(:needed)
// 130:       @set[:needed].uniq!
// 131:
// 132:       original = original_needs.map(&:name)
// 133:       replace = @set[:needed]
// 134:
// 135:       # 3 sets:
// 136:       # 1. in original and in needs - remain unchanged
// 137:       # 2. in original but not in needs - remove
// 138:       # 3. not in original and in needs - append
// 139:       append = replace - original
// 140:       remove = original - replace
// 141:
// 142:       ignored_dyns = remove.each_with_object([]) do |name, ignored|
// 143:         dyn = original_needs.find { |n| n.name == name }.header
// 144:         dyn.d_tag = IGNORE
// 145:         ignored << dyn
// 146:       end
// 147:
// 148:       append.zip(ignored_dyns) do |name, ignored_dyn|
// 149:         dyn = ignored_dyn || lazy_dyn(:needed)
// 150:         dyn.d_tag = ELFTools::Constants::DT_NEEDED
// 151:         reg_str_table(name) { |idx| dyn.d_val = idx }
// 152:       end
// 153:     end
// 154:
// 155:     # Create a temp tag header.
// 156:     # @return [ELFTools::Structs::ELF_Dyn]
// 157:     def lazy_dyn(sym)
// 158:       ELFTools::Structs::ELF_Dyn.new(endian: @elf.endian).tap do |dyn|
// 159:         @append_dyn << dyn
// 160:         dyn.elf_class = @elf.elf_class
// 161:         dyn.d_tag = ELFTools::Util.to_constant(ELFTools::Constants::DT, sym)
// 162:       end
// 163:     end
// 164:
// 165:     def expand_dynamic!
// 166:       return if @append_dyn.empty?
// 167:
// 168:       dyn_sec = section_header('.dynamic')
// 169:       total = dynamic.tags.map(&:header)
// 170:       # the last must be a null-tag
// 171:       total = total[0..-2] + @append_dyn + [total.last]
// 172:       bytes = total.first.num_bytes * total.size
// 173:       @mm.malloc(bytes) do |off, vaddr|
// 174:         inline_patch(off, total.map(&:to_binary_s).join)
// 175:         dynamic.header.p_offset = off
// 176:         dynamic.header.p_vaddr = dynamic.header.p_paddr = vaddr
// 177:         dynamic.header.p_filesz = dynamic.header.p_memsz = bytes
// 178:         if dyn_sec
// 179:           dyn_sec.sh_offset = off
// 180:           dyn_sec.sh_addr = vaddr
// 181:           dyn_sec.sh_size = bytes
// 182:         end
// 183:       end
// 184:     end
// 185:
// 186:     def malloc_strtab!
// 187:       return if @strtab_extend_requests.empty?
// 188:
// 189:       strtab = dynamic.tag_by_type(:strtab)
// 190:       # Process registered requests
// 191:       need_size = strtab_string.size + @strtab_extend_requests.reduce(0) { |sum, (str, _)| sum + str.size + 1 }
// 192:       dynstr = section_header('.dynstr')
// 193:       @mm.malloc(need_size) do |off, vaddr|
// 194:         new_str = "#{strtab_string}#{@strtab_extend_requests.map(&:first).join("\x00")}\x00"
// 195:         inline_patch(off, new_str)
// 196:         cur = strtab_string.size
// 197:         @strtab_extend_requests.each do |str, block|
// 198:           block.call(cur)
// 199:           cur += str.size + 1
// 200:         end
// 201:         # Now patching strtab header
// 202:         strtab.header.d_val = vaddr
// 203:         # We also need to patch dynstr to let readelf have correct output.
// 204:         if dynstr
// 205:           dynstr.sh_size = new_str.size
// 206:           dynstr.sh_offset = off
// 207:           dynstr.sh_addr = vaddr
// 208:         end
// 209:       end
// 210:     end
// 211:
// 212:     # @param [String] str
// 213:     # @yieldparam [Integer] idx
// 214:     # @yieldreturn [void]
// 215:     def reg_str_table(str, &block)
// 216:       idx = strtab_string.index("#{str}\x00")
// 217:       # Request string is already exist
// 218:       return yield idx if idx
// 219:
// 220:       # Record the request
// 221:       @strtab_extend_requests << [str, block]
// 222:     end
// 223:
// 224:     def strtab_string
// 225:       return @strtab_string if defined?(@strtab_string)
// 226:
// 227:       # TODO: handle no strtab exists..
// 228:       offset = @elf.offset_from_vma(dynamic.tag_by_type(:strtab).value)
// 229:       # This is a little tricky since no length information is stored in the tag.
// 230:       # We first get the file offset of the string then 'guess' where the end is.
// 231:       @elf.stream.pos = offset
// 232:       @strtab_string = +''
// 233:       loop do
// 234:         c = @elf.stream.read(1)
// 235:         break unless c =~ /\x00|[[:print:]]/
// 236:
// 237:         @strtab_string << c
// 238:       end
// 239:       @strtab_string
// 240:     end
// 241:
// 242:     # This can only be used for patching interpreter's name
// 243:     # or set strings in a malloc-ed area.
// 244:     # i.e. NEVER intend to change the string defined in strtab
// 245:     def inline_patch(off, str)
// 246:       @inline_patch[off] = str
// 247:     end
// 248:
// 249:     # Modify the out_file according to registered patches.
// 250:     def patch_out(out_file)
// 251:       File.open(out_file, 'r+') do |f|
// 252:         if @mm.extended?
// 253:           original_head = @mm.threshold
// 254:           extra = {}
// 255:           # Copy all data after the second load
// 256:           @elf.stream.pos = original_head
// 257:           extra[original_head + @mm.extend_size] = @elf.stream.read # read to end
// 258:           # zero out the 'gap' we created
// 259:           extra[original_head] = "\x00" * @mm.extend_size
// 260:           extra.each do |pos, str|
// 261:             f.pos = pos
// 262:             f.write(str)
// 263:           end
// 264:         end
// 265:         @elf.patches.each do |pos, str|
// 266:           f.pos = @mm.extended_offset(pos)
// 267:           f.write(str)
// 268:         end
// 269:
// 270:         @inline_patch.each do |pos, str|
// 271:           f.pos = pos
// 272:           f.write(str)
// 273:         end
// 274:       end
// 275:     end
// 276:
// 277:     # @return [ELFTools::Sections::Section?]
// 278:     def section_header(name)
// 279:       sec = @elf.section_by_name(name)
// 280:       return if sec.nil?
// 281:
// 282:       sec.header
// 283:     end
// 284:
// 285:     def dynamic
// 286:       @dynamic ||= @elf.segment_by_type(:dynamic)
// 287:     end
// 288:   end
// 289: end
