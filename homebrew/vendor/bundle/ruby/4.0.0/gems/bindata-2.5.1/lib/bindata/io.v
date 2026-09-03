module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/io.rb`.
// The original source is retained below until every stub has a typed V body.

// BinaryStringIO is the binary, in-memory stream created by create_string_io.
// A non-seekable instance models streams such as Ruby's IO.pipe endpoints.
@[heap]
pub struct BinaryStringIO {
mut:
	data     []u8
	position int
	seekable bool = true
}

// new_binary_string_io creates the binary StringIO used by the Ruby source.
pub fn new_binary_string_io(value string) &BinaryStringIO {
	return &BinaryStringIO{
		data: value.bytes()
	}
}

// new_binary_stream exposes the same storage with configurable seekability for
// typed adapters around pipes and other forward-only streams.
pub fn new_binary_stream(value string, seekable bool) &BinaryStringIO {
	return &BinaryStringIO{
		data: value.bytes()
		seekable: seekable
	}
}

pub fn (stream &BinaryStringIO) value() string {
	return stream.data.bytestr()
}

pub fn (stream &BinaryStringIO) pos() int {
	return stream.position
}

pub fn (mut stream BinaryStringIO) rewind() ! {
	if !stream.seekable {
		return error('stream is unseekable')
	}
	stream.position = 0
}

fn (mut stream BinaryStringIO) seek(position int) ! {
	if !stream.seekable {
		return error('stream is unseekable')
	}
	if position < 0 {
		return error('Invalid argument')
	}
	stream.position = position
}

fn (mut stream BinaryStringIO) read(n int) []u8 {
	if stream.position >= stream.data.len {
		return []
	}
	end := if n < 0 || stream.position + n > stream.data.len {
		stream.data.len
	} else {
		stream.position + n
	}
	result := stream.data[stream.position..end].clone()
	stream.position = end
	return result
}

fn (mut stream BinaryStringIO) write(data []u8) int {
	if stream.position > stream.data.len {
		stream.data << []u8{len: stream.position - stream.data.len}
	}
	end := stream.position + data.len
	if end > stream.data.len {
		stream.data << []u8{len: end - stream.data.len}
	}
	for index, byte in data {
		stream.data[stream.position + index] = byte
	}
	stream.position = end
	return data.len
}

// RawIO provides the source's position-independent logical offset on top of the
// underlying stream position.
@[heap]
pub struct RawIO {
mut:
	stream      &BinaryStringIO
	position    int
	initial_pos int
}

pub fn new_raw_io(stream &BinaryStringIO) &RawIO {
	return &RawIO{
		stream: stream
		initial_pos: if stream.seekable { stream.position } else { 0 }
	}
}

pub fn (raw &RawIO) is_seekable() bool {
	return raw.stream.seekable
}

pub fn (raw &RawIO) seekable() bool {
	return raw.stream.seekable
}

pub fn (mut raw RawIO) num_bytes_remaining() !int {
	if !raw.stream.seekable {
		return error('stream is unseekable')
	}
	return raw.stream.data.len - raw.stream.position
}

pub fn (raw &RawIO) offset() int {
	return raw.position
}

fn (mut raw RawIO) unseekable_skip(n int) ! {
	if n < 0 {
		return error('can not skip backwards')
	}
	mut remaining := n
	for remaining > 0 {
		bytes_to_read := if remaining < 8192 { remaining } else { 8192 }
		raw.read(bytes_to_read)
		remaining -= bytes_to_read
	}
}

pub fn (mut raw RawIO) skip(n int) ! {
	if n < 0 {
		return error('can not skip backwards')
	}
	if !raw.stream.seekable {
		raw.unseekable_skip(n)!
		return
	}
	raw.stream.seek(raw.stream.position + n)!
	raw.position += n
}

pub fn (mut raw RawIO) seek_abs(n int) ! {
	if !raw.stream.seekable {
		raw.unseekable_skip(n - raw.position)!
		return
	}
	raw.stream.seek(n + raw.initial_pos)!
	raw.position = n
}

pub fn (mut raw RawIO) read(n int) []u8 {
	data := raw.stream.read(n)
	raw.position += data.len
	return data
}

pub fn (mut raw RawIO) write(data []u8) int {
	return raw.stream.write(data)
}

enum IOChainKind {
	raw
	transform
}

@[heap]
struct IOChain {
mut:
	kind      IOChainKind
	raw       &RawIO = unsafe { nil }
	transform &IOTransform = unsafe { nil }
}

fn raw_io_chain(raw &RawIO) &IOChain {
	return &IOChain{
		kind: .raw
		raw: raw
	}
}

fn transform_io_chain(transform &IOTransform) &IOChain {
	return &IOChain{
		kind: .transform
		transform: transform
	}
}

fn (chain &IOChain) seekable() bool {
	return match chain.kind {
		.raw { chain.raw.seekable() }
		.transform { chain.transform.seekable() }
	}
}

fn (mut chain IOChain) num_bytes_remaining() !int {
	return match chain.kind {
		.raw { chain.raw.num_bytes_remaining()! }
		.transform { chain.transform.num_bytes_remaining()! }
	}
}

fn (chain &IOChain) offset() int {
	return match chain.kind {
		.raw { chain.raw.offset() }
		.transform { chain.transform.offset() }
	}
}

fn (mut chain IOChain) skip(n int) ! {
	match chain.kind {
		.raw { chain.raw.skip(n)! }
		.transform { chain.transform.skip(n)! }
	}
}

fn (mut chain IOChain) seek_abs(n int) ! {
	match chain.kind {
		.raw { chain.raw.seek_abs(n)! }
		.transform { chain.transform.seek_abs(n)! }
	}
}

fn (mut chain IOChain) read(n int) ![]u8 {
	return match chain.kind {
		.raw { chain.raw.read(n) }
		.transform { chain.transform.read(n)! }
	}
}

fn (mut chain IOChain) write(data []u8) !int {
	return match chain.kind {
		.raw { chain.raw.write(data) }
		.transform { chain.transform.write(data)! }
	}
}

// IOTransform is the source's identity Transform base class. Subclasses can use
// the public chain_* methods as their typed superclass adapter.
@[heap]
pub struct IOTransform {
mut:
	chain                 &IOChain = unsafe { nil }
	head                  &IOChain = unsafe { nil }
	changes_stream_length bool
}

pub fn new_io_transform() &IOTransform {
	return &IOTransform{}
}

pub fn (mut transform IOTransform) transform_changes_stream_length() {
	transform.changes_stream_length = true
}

pub fn (mut transform IOTransform) before_transform() ! {}

pub fn (mut transform IOTransform) after_read_transform() ! {}

pub fn (mut transform IOTransform) after_write_transform() ! {}

fn (mut transform IOTransform) prepend_to_chain(chain &IOChain) !&IOChain {
	transform.chain = chain
	transform.before_transform()!
	transform.head = transform_io_chain(&transform)
	return transform.head
}

pub fn (transform &IOTransform) seekable() bool {
	if transform.changes_stream_length {
		return false
	}
	return transform.chain.seekable()
}

pub fn (mut transform IOTransform) num_bytes_remaining() !int {
	if transform.changes_stream_length {
		return error('stream is unseekable')
	}
	return transform.chain_num_bytes_remaining()!
}

pub fn (transform &IOTransform) offset() int {
	return transform.chain_offset()
}

fn (mut transform IOTransform) unseekable_skip(n int) ! {
	if n < 0 {
		return error('can not skip backwards')
	}
	mut remaining := n
	for remaining > 0 {
		bytes_to_read := if remaining < 8192 { remaining } else { 8192 }
		transform.read(bytes_to_read)!
		remaining -= bytes_to_read
	}
}

pub fn (mut transform IOTransform) skip(n int) ! {
	if transform.changes_stream_length {
		transform.unseekable_skip(n)!
		return
	}
	transform.chain_skip(n)!
}

pub fn (mut transform IOTransform) seek_abs(n int) ! {
	if transform.changes_stream_length {
		transform.unseekable_skip(n - transform.offset())!
		return
	}
	transform.chain_seek_abs(n)!
}

pub fn (mut transform IOTransform) read(n int) ![]u8 {
	return transform.chain_read(n)!
}

pub fn (mut transform IOTransform) write(data []u8) !int {
	return transform.chain_write(data)!
}

pub fn (transform &IOTransform) create_empty_binary_string() string {
	return ''
}

pub fn (transform &IOTransform) chain_seekable() bool {
	return transform.chain.seekable()
}

pub fn (mut transform IOTransform) chain_num_bytes_remaining() !int {
	return transform.chain.num_bytes_remaining()!
}

pub fn (transform &IOTransform) chain_offset() int {
	return transform.chain.offset()
}

pub fn (mut transform IOTransform) chain_skip(n int) ! {
	transform.chain.skip(n)!
}

pub fn (mut transform IOTransform) chain_seek_abs(n int) ! {
	transform.chain.seek_abs(n)!
}

pub fn (mut transform IOTransform) chain_read(n int) ![]u8 {
	return transform.chain.read(n)!
}

pub fn (mut transform IOTransform) chain_write(data []u8) !int {
	return transform.chain.write(data)!
}

enum BitEndian {
	none
	big
	little
}

fn mask_bits(nbits int) u64 {
	if nbits <= 0 {
		return 0
	}
	if nbits >= 64 {
		return ~u64(0)
	}
	return (u64(1) << nbits) - 1
}

@[heap]
pub struct IORead {
mut:
	io      &IOChain
	rnbits  int
	rval    u64
	rendian BitEndian
}

pub fn new_io_read(stream &BinaryStringIO) &IORead {
	return &IORead{
		io: raw_io_chain(new_raw_io(stream))
	}
}

pub fn new_io_read_string(value string) &IORead {
	return new_io_read(new_binary_string_io(value))
}

pub fn (mut reader IORead) transform(mut transform IOTransform, operation fn(mut IORead, mut IOTransform) !) ! {
	reader.reset_read_bits()
	saved := reader.io
	defer {
		reader.io = saved
	}
	reader.io = transform.prepend_to_chain(saved)!
	operation(mut reader, mut transform)!
	transform.after_read_transform()!
}

pub fn (mut reader IORead) num_bytes_remaining() !int {
	return reader.io.num_bytes_remaining()!
}

pub fn (mut reader IORead) skipbytes(n int) ! {
	reader.reset_read_bits()
	reader.io.skip(n)!
}

pub fn (mut reader IORead) seek_to_abs_offset(n int) ! {
	reader.reset_read_bits()
	reader.io.seek_abs(n)!
}

fn (mut reader IORead) read(n int) ![]u8 {
	data := reader.io.read(n)!
	if n >= 0 {
		if n > 0 && data.len == 0 {
			return error('End of file reached')
		}
		if data.len < n {
			return error('data truncated')
		}
	}
	return data
}

pub fn (mut reader IORead) readbytes(n int) ![]u8 {
	reader.reset_read_bits()
	return reader.read(n)!
}

pub fn (mut reader IORead) read_all_bytes() ![]u8 {
	reader.reset_read_bits()
	return reader.read(-1)!
}

pub fn (mut reader IORead) readbits(nbits int, endian BitEndian) !u64 {
	if nbits < 0 || nbits > 64 {
		return error('nbits must be between 0 and 64')
	}
	if reader.rendian != endian {
		reader.reset_read_bits()
		reader.rendian = endian
	}
	return if endian == .big {
		reader.read_big_endian_bits(nbits)!
	} else {
		reader.read_little_endian_bits(nbits)!
	}
}

pub fn (mut reader IORead) readbits_big(nbits int) !u64 {
	return reader.readbits(nbits, .big)!
}

pub fn (mut reader IORead) readbits_little(nbits int) !u64 {
	return reader.readbits(nbits, .little)!
}

pub fn (mut reader IORead) reset_read_bits() {
	reader.rnbits = 0
	reader.rval = 0
}

fn (mut reader IORead) read_big_endian_bits(nbits int) !u64 {
	for reader.rnbits < nbits {
		reader.accumulate_big_endian_bits()!
	}
	value := (reader.rval >> (reader.rnbits - nbits)) & mask_bits(nbits)
	reader.rnbits -= nbits
	reader.rval &= mask_bits(reader.rnbits)
	return value
}

fn (mut reader IORead) accumulate_big_endian_bits() ! {
	byte := reader.read(1)![0] & 0xff
	reader.rval = (reader.rval << 8) | byte
	reader.rnbits += 8
}

fn (mut reader IORead) read_little_endian_bits(nbits int) !u64 {
	for reader.rnbits < nbits {
		reader.accumulate_little_endian_bits()!
	}
	value := reader.rval & mask_bits(nbits)
	reader.rnbits -= nbits
	reader.rval >>= nbits
	return value
}

fn (mut reader IORead) accumulate_little_endian_bits() ! {
	byte := reader.read(1)![0] & 0xff
	reader.rval |= u64(byte) << reader.rnbits
	reader.rnbits += 8
}

@[heap]
pub struct IOWrite {
mut:
	io      &IOChain
	wnbits  int
	wval    u64
	wendian BitEndian
}

pub fn new_io_write(stream &BinaryStringIO) &IOWrite {
	return &IOWrite{
		io: raw_io_chain(new_raw_io(stream))
	}
}

pub fn new_io_write_string(value string) &IOWrite {
	return new_io_write(new_binary_string_io(value))
}

pub fn (mut writer IOWrite) transform(mut transform IOTransform, operation fn(mut IOWrite, mut IOTransform) !) ! {
	writer.flushbits()!
	saved := writer.io
	defer {
		writer.io = saved
	}
	writer.io = transform.prepend_to_chain(saved)!
	operation(mut writer, mut transform)!
	transform.after_write_transform()!
}

pub fn (mut writer IOWrite) seek_to_abs_offset(n int) ! {
	if !writer.io.seekable() {
		return error('stream is unseekable')
	}
	writer.flushbits()!
	writer.io.seek_abs(n)!
}

fn (mut writer IOWrite) write(data []u8) !int {
	return writer.io.write(data)!
}

pub fn (mut writer IOWrite) writebytes(data []u8) !int {
	writer.flushbits()!
	return writer.write(data)!
}

pub fn (mut writer IOWrite) writebits(value u64, nbits int, endian BitEndian) ! {
	if nbits < 0 || nbits > 64 {
		return error('nbits must be between 0 and 64')
	}
	if writer.wendian != endian {
		writer.flushbits()!
		writer.wendian = endian
	}
	clamped_value := value & mask_bits(nbits)
	if endian == .big {
		writer.write_big_endian_bits(clamped_value, nbits)!
	} else {
		writer.write_little_endian_bits(clamped_value, nbits)!
	}
}

pub fn (mut writer IOWrite) writebits_big(value u64, nbits int) ! {
	writer.writebits(value, nbits, .big)!
}

pub fn (mut writer IOWrite) writebits_little(value u64, nbits int) ! {
	writer.writebits(value, nbits, .little)!
}

pub fn (mut writer IOWrite) flushbits() ! {
	if writer.wnbits >= 8 {
		return error('Internal state error nbits = ${writer.wnbits}')
	}
	if writer.wnbits > 0 {
		writer.writebits(0, 8 - writer.wnbits, writer.wendian)!
	}
}

pub fn (mut writer IOWrite) flush() ! {
	writer.flushbits()!
}

fn (mut writer IOWrite) write_big_endian_bits(initial_value u64, initial_nbits int) ! {
	mut value := initial_value
	mut nbits := initial_nbits
	for nbits > 0 {
		bits_required := 8 - writer.wnbits
		if nbits >= bits_required {
			most_significant_bits := (value >> (nbits - bits_required)) & mask_bits(bits_required)
			nbits -= bits_required
			value &= mask_bits(nbits)
			writer.wval = (writer.wval << bits_required) | most_significant_bits
			writer.write([u8(writer.wval)])!
			writer.wval = 0
			writer.wnbits = 0
		} else {
			writer.wval = (writer.wval << nbits) | value
			writer.wnbits += nbits
			nbits = 0
		}
	}
}

fn (mut writer IOWrite) write_little_endian_bits(initial_value u64, initial_nbits int) ! {
	mut value := initial_value
	mut nbits := initial_nbits
	for nbits > 0 {
		bits_required := 8 - writer.wnbits
		if nbits >= bits_required {
			least_significant_bits := value & mask_bits(bits_required)
			nbits -= bits_required
			value >>= bits_required
			writer.wval |= least_significant_bits << writer.wnbits
			writer.write([u8(writer.wval)])!
			writer.wval = 0
			writer.wnbits = 0
		} else {
			writer.wval |= value << writer.wnbits
			writer.wnbits += nbits
			nbits = 0
		}
	}
}

fn io_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn binary_string_io_value(stream &BinaryStringIO) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'StringIO'
		repr: stream.value()
		int_data: i64(u64(voidptr(stream)))
		attributes: {
			'binary_string_io_address': u64(voidptr(stream)).str()
			'seekable':                 stream.seekable.str()
		}
	}
}

fn binary_string_io_from_value(value brew_runtime.Value) &BinaryStringIO {
	if address := value.attributes['binary_string_io_address'] {
		return unsafe { &BinaryStringIO(voidptr(address.u64())) }
	}
	return new_binary_string_io(value.as_string())
}

pub fn io_read_boundary_value(reader &IORead) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::IO::Read'
		repr: 'BinData::IO::Read'
		int_data: i64(u64(voidptr(reader)))
		attributes: {
			'io_read_address': u64(voidptr(reader)).str()
		}
	}
}

fn io_read_from_value(value brew_runtime.Value) &IORead {
	address := value.attributes['io_read_address'] or {
		panic('expected BinData::IO::Read, got ${value.type_name}')
	}
	return unsafe { &IORead(voidptr(address.u64())) }
}

pub fn io_write_boundary_value(writer &IOWrite) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::IO::Write'
		repr: 'BinData::IO::Write'
		int_data: i64(u64(voidptr(writer)))
		attributes: {
			'io_write_address': u64(voidptr(writer)).str()
		}
	}
}

fn io_write_from_value(value brew_runtime.Value) &IOWrite {
	address := value.attributes['io_write_address'] or {
		panic('expected BinData::IO::Write, got ${value.type_name}')
	}
	return unsafe { &IOWrite(voidptr(address.u64())) }
}

fn raw_io_value(raw &RawIO) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::IO::RawIO'
		repr: 'BinData::IO::RawIO'
		int_data: i64(u64(voidptr(raw)))
		attributes: {
			'raw_io_address': u64(voidptr(raw)).str()
		}
	}
}

fn raw_io_from_value(value brew_runtime.Value) &RawIO {
	address := value.attributes['raw_io_address'] or {
		panic('expected BinData::IO::RawIO, got ${value.type_name}')
	}
	return unsafe { &RawIO(voidptr(address.u64())) }
}

pub fn io_transform_boundary_value(transform &IOTransform) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::IO::Transform'
		repr: 'BinData::IO::Transform'
		int_data: i64(u64(voidptr(transform)))
		attributes: {
			'io_transform_address':  u64(voidptr(transform)).str()
			'changes_stream_length': transform.changes_stream_length.str()
		}
	}
}

fn io_transform_from_value(value brew_runtime.Value) &IOTransform {
	address := value.attributes['io_transform_address'] or {
		panic('expected BinData::IO::Transform, got ${value.type_name}')
	}
	return unsafe { &IOTransform(voidptr(address.u64())) }
}

fn io_chain_from_value(value brew_runtime.Value) &IOChain {
	if value.type_name == 'BinData::IO::Read' {
		return io_read_from_value(value).io
	}
	if value.type_name == 'BinData::IO::Write' {
		return io_write_from_value(value).io
	}
	if value.type_name == 'BinData::IO::RawIO' {
		return raw_io_chain(raw_io_from_value(value))
	}
	if value.type_name == 'BinData::IO::Transform' {
		return io_transform_from_value(value).head
	}
	return raw_io_chain(new_raw_io(binary_string_io_from_value(value)))
}

fn io_boundary_int(args []brew_runtime.Value, index int, name string) int {
	if index >= args.len {
		panic('${name} requires argument ${index + 1}')
	}
	return int(args[index].as_int() or { panic(err) })
}

fn io_boundary_endian(value brew_runtime.Value) BitEndian {
	return match value.as_string().trim_left(':') {
		'big' { .big }
		'little' { .little }
		else { .little }
	}
}

// Ruby method `self.create_string_io(str = "")` at line 9.
pub fn ruby_io_l9_d1_self_create_string_io(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	return binary_string_io_value(new_binary_string_io(value))
}

// Ruby method `initialize(io)` at line 32.
pub fn ruby_io_l32_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('BinData::IO::Read#initialize requires io')
	}
	if args[0].type_name == 'BinData::IO::Read' {
		panic('io must not be a BinData::IO::Read')
	}
	return io_read_boundary_value(new_io_read(binary_string_io_from_value(args[0])))
}

// Ruby method `transform(io)` at line 56.
pub fn ruby_io_l56_d3_transform(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('BinData::IO::Read#transform requires a transform')
	}
	mut reader := io_read_from_value(args[0])
	mut transform := io_transform_from_value(args[1])
	reader.transform(mut transform, fn (mut _ IORead, mut _ IOTransform) ! {}) or { panic(err) }
	return io_read_boundary_value(reader)
}

// Ruby method `num_bytes_remaining` at line 68.
pub fn ruby_io_l68_d4_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	return brew_runtime.int_value(reader.num_bytes_remaining() or { panic(err) })
}

// Ruby method `skipbytes(n)` at line 73.
pub fn ruby_io_l73_d5_skipbytes(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	reader.skipbytes(io_boundary_int(args, 1, 'skipbytes')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `seek_to_abs_offset(n)` at line 79.
pub fn ruby_io_l79_d6_seek_to_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	reader.seek_to_abs_offset(io_boundary_int(args, 1, 'seek_to_abs_offset')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `readbytes(n)` at line 89.
pub fn ruby_io_l89_d7_readbytes(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	return brew_runtime.string_value(reader.readbytes(io_boundary_int(args, 1, 'readbytes')) or {
		panic(err)
	}.bytestr())
}

// Ruby method `read_all_bytes` at line 95.
pub fn ruby_io_l95_d8_read_all_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	return brew_runtime.string_value(reader.read_all_bytes() or { panic(err) }.bytestr())
}

// Ruby method `readbits(nbits, endian)` at line 102.
pub fn ruby_io_l102_d9_readbits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	value := reader.readbits(io_boundary_int(args, 1, 'readbits'), io_boundary_endian(args[2])) or {
		panic(err)
	}
	return brew_runtime.int_value(i64(value))
}

// Ruby method `reset_read_bits` at line 118.
pub fn ruby_io_l118_d10_reset_read_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	reader.reset_read_bits()
	return io_nil_value()
}

// Ruby method `read(n = nil)` at line 126.
pub fn ruby_io_l126_d11_read(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	n := if args.len > 1 && args[1].type_name != 'NilClass' {
		io_boundary_int(args, 1, 'read')
	} else {
		-1
	}
	return brew_runtime.string_value(reader.read(n) or { panic(err) }.bytestr())
}

// Ruby method `read_big_endian_bits(nbits)` at line 135.
pub fn ruby_io_l135_d12_read_big_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	return brew_runtime.int_value(i64(reader.read_big_endian_bits(io_boundary_int(args, 1, 'read_big_endian_bits')) or { panic(err) }))
}

// Ruby method `accumulate_big_endian_bits` at line 147.
pub fn ruby_io_l147_d13_accumulate_big_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	reader.accumulate_big_endian_bits() or { panic(err) }
	return io_nil_value()
}

// Ruby method `read_little_endian_bits(nbits)` at line 153.
pub fn ruby_io_l153_d14_read_little_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	return brew_runtime.int_value(i64(reader.read_little_endian_bits(io_boundary_int(args, 1, 'read_little_endian_bits')) or { panic(err) }))
}

// Ruby method `accumulate_little_endian_bits` at line 165.
pub fn ruby_io_l165_d15_accumulate_little_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut reader := io_read_from_value(args[0])
	reader.accumulate_little_endian_bits() or { panic(err) }
	return io_nil_value()
}

// Ruby method `mask(nbits)` at line 171.
pub fn ruby_io_l171_d16_mask(args ...brew_runtime.Value) brew_runtime.Value {
	index := if args.len > 1 { 1 } else { 0 }
	return brew_runtime.int_value(i64(mask_bits(io_boundary_int(args, index, 'mask'))))
}

// Ruby method `initialize(io)` at line 184.
pub fn ruby_io_l184_d17_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('BinData::IO::Write#initialize requires io')
	}
	if args[0].type_name == 'BinData::IO::Write' {
		panic('io must not be a BinData::IO::Write')
	}
	return io_write_boundary_value(new_io_write(binary_string_io_from_value(args[0])))
}

// Ruby method `transform(io)` at line 207.
pub fn ruby_io_l207_d18_transform(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('BinData::IO::Write#transform requires a transform')
	}
	mut writer := io_write_from_value(args[0])
	mut transform := io_transform_from_value(args[1])
	writer.transform(mut transform, fn (mut _ IOWrite, mut _ IOTransform) ! {}) or { panic(err) }
	return io_write_boundary_value(writer)
}

// Ruby method `seek_to_abs_offset(n)` at line 219.
pub fn ruby_io_l219_d19_seek_to_abs_offset(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	writer.seek_to_abs_offset(io_boundary_int(args, 1, 'seek_to_abs_offset')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `writebytes(str)` at line 227.
pub fn ruby_io_l227_d20_writebytes(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	return brew_runtime.int_value(writer.writebytes(args[1].as_string().bytes()) or { panic(err) })
}

// Ruby method `writebits(val, nbits, endian)` at line 234.
pub fn ruby_io_l234_d21_writebits(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	writer.writebits(u64(args[1].as_int() or { panic(err) }), io_boundary_int(args, 2, 'writebits'), io_boundary_endian(args[3])) or { panic(err) }
	return io_nil_value()
}

// Ruby method `flushbits` at line 251.
pub fn ruby_io_l251_d22_flushbits(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	writer.flushbits() or { panic(err) }
	return io_nil_value()
}

// Ruby alias `alias flush flushbits` at line 258.
pub fn ruby_io_l258_d23_flush(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_io_l251_d22_flushbits(...args)
}

// Ruby method `write(data)` at line 263.
pub fn ruby_io_l263_d24_write(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	return brew_runtime.int_value(writer.write(args[1].as_string().bytes()) or { panic(err) })
}

// Ruby method `write_big_endian_bits(val, nbits)` at line 267.
pub fn ruby_io_l267_d25_write_big_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	writer.write_big_endian_bits(u64(args[1].as_int() or { panic(err) }), io_boundary_int(args, 2, 'write_big_endian_bits')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `write_little_endian_bits(val, nbits)` at line 288.
pub fn ruby_io_l288_d26_write_little_endian_bits(args ...brew_runtime.Value) brew_runtime.Value {
	mut writer := io_write_from_value(args[0])
	writer.write_little_endian_bits(u64(args[1].as_int() or { panic(err) }), io_boundary_int(args, 2, 'write_little_endian_bits')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `mask(nbits)` at line 309.
pub fn ruby_io_l309_d27_mask(args ...brew_runtime.Value) brew_runtime.Value {
	index := if args.len > 1 { 1 } else { 0 }
	return brew_runtime.int_value(i64(mask_bits(io_boundary_int(args, index, 'mask'))))
}

// Ruby method `initialize(io)` at line 316.
pub fn ruby_io_l316_d28_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('BinData::IO::RawIO#initialize requires io')
	}
	return raw_io_value(new_raw_io(binary_string_io_from_value(args[0])))
}

// Ruby method `is_seekable?(io)` at line 327.
pub fn ruby_io_l327_d29_is_seekable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(binary_string_io_from_value(args[args.len - 1]).seekable)
}

// Ruby method `seekable?` at line 333.
pub fn ruby_io_l333_d30_seekable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(raw_io_from_value(args[0]).seekable())
}

// Ruby method `num_bytes_remaining` at line 337.
pub fn ruby_io_l337_d31_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	mut raw := raw_io_from_value(args[0])
	return brew_runtime.int_value(raw.num_bytes_remaining() or { panic(err) })
}

// Ruby method `offset` at line 346.
pub fn ruby_io_l346_d32_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(raw_io_from_value(args[0]).offset())
}

// Ruby method `skip(n)` at line 350.
pub fn ruby_io_l350_d33_skip(args ...brew_runtime.Value) brew_runtime.Value {
	mut raw := raw_io_from_value(args[0])
	raw.skip(io_boundary_int(args, 1, 'skip')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `seek_abs(n)` at line 356.
pub fn ruby_io_l356_d34_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	mut raw := raw_io_from_value(args[0])
	raw.seek_abs(io_boundary_int(args, 1, 'seek_abs')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `read(n)` at line 361.
pub fn ruby_io_l361_d35_read(args ...brew_runtime.Value) brew_runtime.Value {
	mut raw := raw_io_from_value(args[0])
	n := if args.len > 1 && args[1].type_name != 'NilClass' {
		io_boundary_int(args, 1, 'read')
	} else {
		-1
	}
	return brew_runtime.string_value(raw.read(n).bytestr())
}

// Ruby method `write(data)` at line 365.
pub fn ruby_io_l365_d36_write(args ...brew_runtime.Value) brew_runtime.Value {
	mut raw := raw_io_from_value(args[0])
	return brew_runtime.int_value(raw.write(args[1].as_string().bytes()))
}

// Ruby method `transform_changes_stream_length!` at line 387.
pub fn ruby_io_l387_d37_transform_changes_stream_length(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(true)
	}
	mut transform := io_transform_from_value(args[0])
	transform.transform_changes_stream_length()
	return io_transform_boundary_value(transform)
}

// Ruby method `initialize` at line 392.
pub fn ruby_io_l392_d38_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return io_transform_boundary_value(new_io_transform())
}

// Ruby method `before_transform; end` at line 399.
pub fn ruby_io_l399_d39_before_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.before_transform() or { panic(err) }
	return io_nil_value()
}

// Ruby method `after_read_transform; end` at line 404.
pub fn ruby_io_l404_d40_after_read_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.after_read_transform() or { panic(err) }
	return io_nil_value()
}

// Ruby method `after_write_transform; end` at line 409.
pub fn ruby_io_l409_d41_after_write_transform(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.after_write_transform() or { panic(err) }
	return io_nil_value()
}

// Ruby method `prepend_to_chain(chain)` at line 414.
pub fn ruby_io_l414_d42_prepend_to_chain(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.prepend_to_chain(io_chain_from_value(args[1])) or { panic(err) }
	return io_transform_boundary_value(transform)
}

// Ruby method `seekable?` at line 421.
pub fn ruby_io_l421_d43_seekable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(io_transform_from_value(args[0]).seekable())
}

// Ruby method `num_bytes_remaining` at line 426.
pub fn ruby_io_l426_d44_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	return brew_runtime.int_value(transform.num_bytes_remaining() or { panic(err) })
}

// Ruby method `offset` at line 431.
pub fn ruby_io_l431_d45_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(io_transform_from_value(args[0]).offset())
}

// Ruby method `skip(n)` at line 436.
pub fn ruby_io_l436_d46_skip(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.skip(io_boundary_int(args, 1, 'skip')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `seek_abs(n)` at line 441.
pub fn ruby_io_l441_d47_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.seek_abs(io_boundary_int(args, 1, 'seek_abs')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `read(n)` at line 446.
pub fn ruby_io_l446_d48_read(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	n := if args.len > 1 && args[1].type_name != 'NilClass' {
		io_boundary_int(args, 1, 'read')
	} else {
		-1
	}
	return brew_runtime.string_value(transform.read(n) or { panic(err) }.bytestr())
}

// Ruby method `write(data)` at line 451.
pub fn ruby_io_l451_d49_write(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	return brew_runtime.int_value(transform.write(args[1].as_string().bytes()) or { panic(err) })
}

// Ruby method `create_empty_binary_string` at line 458.
pub fn ruby_io_l458_d50_create_empty_binary_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('')
}

// Ruby method `chain_seekable?` at line 462.
pub fn ruby_io_l462_d51_chain_seekable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(io_transform_from_value(args[0]).chain_seekable())
}

// Ruby method `chain_num_bytes_remaining` at line 466.
pub fn ruby_io_l466_d52_chain_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	return brew_runtime.int_value(transform.chain_num_bytes_remaining() or { panic(err) })
}

// Ruby method `chain_offset` at line 470.
pub fn ruby_io_l470_d53_chain_offset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(io_transform_from_value(args[0]).chain_offset())
}

// Ruby method `chain_skip(n)` at line 474.
pub fn ruby_io_l474_d54_chain_skip(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.chain_skip(io_boundary_int(args, 1, 'chain_skip')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `chain_seek_abs(n)` at line 478.
pub fn ruby_io_l478_d55_chain_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	transform.chain_seek_abs(io_boundary_int(args, 1, 'chain_seek_abs')) or { panic(err) }
	return io_nil_value()
}

// Ruby method `chain_read(n)` at line 482.
pub fn ruby_io_l482_d56_chain_read(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	n := if args.len > 1 && args[1].type_name != 'NilClass' {
		io_boundary_int(args, 1, 'chain_read')
	} else {
		-1
	}
	return brew_runtime.string_value(transform.chain_read(n) or { panic(err) }.bytestr())
}

// Ruby method `chain_write(data)` at line 486.
pub fn ruby_io_l486_d57_chain_write(args ...brew_runtime.Value) brew_runtime.Value {
	mut transform := io_transform_from_value(args[0])
	return brew_runtime.int_value(transform.chain_write(args[1].as_string().bytes()) or { panic(err) })
}

// Ruby method `seekable?` at line 495.
pub fn ruby_io_l495_d58_seekable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `num_bytes_remaining` at line 499.
pub fn ruby_io_l499_d59_num_bytes_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	panic('stream is unseekable')
}

// Ruby method `skip(n)` at line 503.
pub fn ruby_io_l503_d60_skip(args ...brew_runtime.Value) brew_runtime.Value {
	mut chain := io_chain_from_value(args[0])
	n := io_boundary_int(args, 1, 'skip')
	if n < 0 {
		panic('can not skip backwards')
	}
	mut remaining := n
	for remaining > 0 {
		bytes_to_read := if remaining < 8192 { remaining } else { 8192 }
		chain.read(bytes_to_read) or { panic(err) }
		remaining -= bytes_to_read
	}
	return io_nil_value()
}

// Ruby method `seek_abs(n)` at line 514.
pub fn ruby_io_l514_d61_seek_abs(args ...brew_runtime.Value) brew_runtime.Value {
	mut chain := io_chain_from_value(args[0])
	target := io_boundary_int(args, 1, 'seek_abs')
	delta := target - chain.offset()
	if delta < 0 {
		panic('can not skip backwards')
	}
	mut remaining := delta
	for remaining > 0 {
		bytes_to_read := if remaining < 8192 { remaining } else { 8192 }
		chain.read(bytes_to_read) or { panic(err) }
		remaining -= bytes_to_read
	}
	return io_nil_value()
}

// Original Ruby source (line-for-line):
// 1: require 'stringio'
// 2:
// 3: module BinData
// 4:   # A wrapper around an IO object.  The wrapper provides a consistent
// 5:   # interface for BinData objects to use when accessing the IO.
// 6:   module IO
// 7:
// 8:     # Creates a StringIO around +str+.
// 9:     def self.create_string_io(str = "")
// 10:       bin_str = str.dup.force_encoding(Encoding::BINARY)
// 11:       StringIO.new(bin_str).tap(&:binmode)
// 12:     end
// 13:
// 14:     # Create a new IO Read wrapper around +io+.  +io+ must provide #read,
// 15:     # #pos if reading the current stream position and #seek if setting the
// 16:     # current stream position.  If +io+ is a string it will be automatically
// 17:     # wrapped in an StringIO object.
// 18:     #
// 19:     # The IO can handle bitstreams in either big or little endian format.
// 20:     #
// 21:     #      M  byte1   L      M  byte2   L
// 22:     #      S 76543210 S      S fedcba98 S
// 23:     #      B          B      B          B
// 24:     #
// 25:     # In big endian format:
// 26:     #   readbits(6), readbits(5) #=> [765432, 10fed]
// 27:     #
// 28:     # In little endian format:
// 29:     #   readbits(6), readbits(5) #=> [543210, a9876]
// 30:     #
// 31:     class Read
// 32:       def initialize(io)
// 33:         if self.class === io
// 34:           raise ArgumentError, "io must not be a #{self.class}"
// 35:         end
// 36:
// 37:         # wrap strings in a StringIO
// 38:         if io.respond_to?(:to_str)
// 39:           io = BinData::IO.create_string_io(io.to_str)
// 40:         end
// 41:
// 42:         @io = RawIO.new(io)
// 43:
// 44:         # bits when reading
// 45:         @rnbits  = 0
// 46:         @rval    = 0
// 47:         @rendian = nil
// 48:       end
// 49:
// 50:       # Allow transforming data in the input stream.
// 51:       # See +BinData::Buffer+ as an example.
// 52:       #
// 53:       # +io+ must be an instance of +Transform+.
// 54:       #
// 55:       # yields +self+ and +io+ to the given block
// 56:       def transform(io)
// 57:         reset_read_bits
// 58:
// 59:         saved = @io
// 60:         @io = io.prepend_to_chain(@io)
// 61:         yield(self, io)
// 62:         io.after_read_transform
// 63:       ensure
// 64:         @io = saved
// 65:       end
// 66:
// 67:       # The number of bytes remaining in the io steam.
// 68:       def num_bytes_remaining
// 69:         @io.num_bytes_remaining
// 70:       end
// 71:
// 72:       # Seek +n+ bytes from the current position in the io stream.
// 73:       def skipbytes(n)
// 74:         reset_read_bits
// 75:         @io.skip(n)
// 76:       end
// 77:
// 78:       # Seek to an absolute offset within the io stream.
// 79:       def seek_to_abs_offset(n)
// 80:         reset_read_bits
// 81:         @io.seek_abs(n)
// 82:       end
// 83:
// 84:       # Reads exactly +n+ bytes from +io+.
// 85:       #
// 86:       # If the data read is nil an EOFError is raised.
// 87:       #
// 88:       # If the data read is too short an IOError is raised.
// 89:       def readbytes(n)
// 90:         reset_read_bits
// 91:         read(n)
// 92:       end
// 93:
// 94:       # Reads all remaining bytes from the stream.
// 95:       def read_all_bytes
// 96:         reset_read_bits
// 97:         read
// 98:       end
// 99:
// 100:       # Reads exactly +nbits+ bits from the stream. +endian+ specifies whether
// 101:       # the bits are stored in +:big+ or +:little+ endian format.
// 102:       def readbits(nbits, endian)
// 103:         if @rendian != endian
// 104:           # don't mix bits of differing endian
// 105:           reset_read_bits
// 106:           @rendian = endian
// 107:         end
// 108:
// 109:         if endian == :big
// 110:           read_big_endian_bits(nbits)
// 111:         else
// 112:           read_little_endian_bits(nbits)
// 113:         end
// 114:       end
// 115:
// 116:       # Discards any read bits so the stream becomes aligned at the
// 117:       # next byte boundary.
// 118:       def reset_read_bits
// 119:         @rnbits = 0
// 120:         @rval   = 0
// 121:       end
// 122:
// 123:       #---------------
// 124:       private
// 125:
// 126:       def read(n = nil)
// 127:         str = @io.read(n)
// 128:         if n
// 129:           raise EOFError, "End of file reached" if str.nil?
// 130:           raise IOError, "data truncated" if str.size < n
// 131:         end
// 132:         str
// 133:       end
// 134:
// 135:       def read_big_endian_bits(nbits)
// 136:         while @rnbits < nbits
// 137:           accumulate_big_endian_bits
// 138:         end
// 139:
// 140:         val     = (@rval >> (@rnbits - nbits)) & mask(nbits)
// 141:         @rnbits -= nbits
// 142:         @rval   &= mask(@rnbits)
// 143:
// 144:         val
// 145:       end
// 146:
// 147:       def accumulate_big_endian_bits
// 148:         byte = read(1).unpack1('C') & 0xff
// 149:         @rval = (@rval << 8) | byte
// 150:         @rnbits += 8
// 151:       end
// 152:
// 153:       def read_little_endian_bits(nbits)
// 154:         while @rnbits < nbits
// 155:           accumulate_little_endian_bits
// 156:         end
// 157:
// 158:         val     = @rval & mask(nbits)
// 159:         @rnbits -= nbits
// 160:         @rval   >>= nbits
// 161:
// 162:         val
// 163:       end
// 164:
// 165:       def accumulate_little_endian_bits
// 166:         byte = read(1).unpack1('C') & 0xff
// 167:         @rval = @rval | (byte << @rnbits)
// 168:         @rnbits += 8
// 169:       end
// 170:
// 171:       def mask(nbits)
// 172:         (1 << nbits) - 1
// 173:       end
// 174:     end
// 175:
// 176:     # Create a new IO Write wrapper around +io+.  +io+ must provide #write.
// 177:     # If +io+ is a string it will be automatically wrapped in an StringIO
// 178:     # object.
// 179:     #
// 180:     # The IO can handle bitstreams in either big or little endian format.
// 181:     #
// 182:     # See IO::Read for more information.
// 183:     class Write
// 184:       def initialize(io)
// 185:         if self.class === io
// 186:           raise ArgumentError, "io must not be a #{self.class}"
// 187:         end
// 188:
// 189:         # wrap strings in a StringIO
// 190:         if io.respond_to?(:to_str)
// 191:           io = BinData::IO.create_string_io(io.to_str)
// 192:         end
// 193:
// 194:         @io = RawIO.new(io)
// 195:
// 196:         @wnbits  = 0
// 197:         @wval    = 0
// 198:         @wendian = nil
// 199:       end
// 200:
// 201:       # Allow transforming data in the output stream.
// 202:       # See +BinData::Buffer+ as an example.
// 203:       #
// 204:       # +io+ must be an instance of +Transform+.
// 205:       #
// 206:       # yields +self+ and +io+ to the given block
// 207:       def transform(io)
// 208:         flushbits
// 209:
// 210:         saved = @io
// 211:         @io = io.prepend_to_chain(@io)
// 212:         yield(self, io)
// 213:         io.after_write_transform
// 214:       ensure
// 215:         @io = saved
// 216:       end
// 217:
// 218:       # Seek to an absolute offset within the io stream.
// 219:       def seek_to_abs_offset(n)
// 220:         raise IOError, "stream is unseekable" unless @io.seekable?
// 221:
// 222:         flushbits
// 223:         @io.seek_abs(n)
// 224:       end
// 225:
// 226:       # Writes the given string of bytes to the io stream.
// 227:       def writebytes(str)
// 228:         flushbits
// 229:         write(str)
// 230:       end
// 231:
// 232:       # Writes +nbits+ bits from +val+ to the stream. +endian+ specifies whether
// 233:       # the bits are to be stored in +:big+ or +:little+ endian format.
// 234:       def writebits(val, nbits, endian)
// 235:         if @wendian != endian
// 236:           # don't mix bits of differing endian
// 237:           flushbits
// 238:           @wendian = endian
// 239:         end
// 240:
// 241:         clamped_val = val & mask(nbits)
// 242:
// 243:         if endian == :big
// 244:           write_big_endian_bits(clamped_val, nbits)
// 245:         else
// 246:           write_little_endian_bits(clamped_val, nbits)
// 247:         end
// 248:       end
// 249:
// 250:       # To be called after all +writebits+ have been applied.
// 251:       def flushbits
// 252:         raise "Internal state error nbits = #{@wnbits}" if @wnbits >= 8
// 253:
// 254:         if @wnbits > 0
// 255:           writebits(0, 8 - @wnbits, @wendian)
// 256:         end
// 257:       end
// 258:       alias flush flushbits
// 259:
// 260:       #---------------
// 261:       private
// 262:
// 263:       def write(data)
// 264:         @io.write(data)
// 265:       end
// 266:
// 267:       def write_big_endian_bits(val, nbits)
// 268:         while nbits > 0
// 269:           bits_req = 8 - @wnbits
// 270:           if nbits >= bits_req
// 271:             msb_bits = (val >> (nbits - bits_req)) & mask(bits_req)
// 272:             nbits -= bits_req
// 273:             val &= mask(nbits)
// 274:
// 275:             @wval   = (@wval << bits_req) | msb_bits
// 276:             write(@wval.chr)
// 277:
// 278:             @wval   = 0
// 279:             @wnbits = 0
// 280:           else
// 281:             @wval = (@wval << nbits) | val
// 282:             @wnbits += nbits
// 283:             nbits = 0
// 284:           end
// 285:         end
// 286:       end
// 287:
// 288:       def write_little_endian_bits(val, nbits)
// 289:         while nbits > 0
// 290:           bits_req = 8 - @wnbits
// 291:           if nbits >= bits_req
// 292:             lsb_bits = val & mask(bits_req)
// 293:             nbits -= bits_req
// 294:             val >>= bits_req
// 295:
// 296:             @wval   = @wval | (lsb_bits << @wnbits)
// 297:             write(@wval.chr)
// 298:
// 299:             @wval   = 0
// 300:             @wnbits = 0
// 301:           else
// 302:             @wval   = @wval | (val << @wnbits)
// 303:             @wnbits += nbits
// 304:             nbits = 0
// 305:           end
// 306:         end
// 307:       end
// 308:
// 309:       def mask(nbits)
// 310:         (1 << nbits) - 1
// 311:       end
// 312:     end
// 313:
// 314:     # API used to access the raw data stream.
// 315:     class RawIO
// 316:       def initialize(io)
// 317:         @io = io
// 318:         @pos = 0
// 319:
// 320:         if is_seekable?(io)
// 321:           @initial_pos = io.pos
// 322:         else
// 323:           singleton_class.prepend(UnSeekableIO)
// 324:         end
// 325:       end
// 326:
// 327:       def is_seekable?(io)
// 328:         io.pos
// 329:       rescue NoMethodError, Errno::ESPIPE, Errno::EPIPE, Errno::EINVAL
// 330:         nil
// 331:       end
// 332:
// 333:       def seekable?
// 334:         true
// 335:       end
// 336:
// 337:       def num_bytes_remaining
// 338:         start_mark = @io.pos
// 339:         @io.seek(0, ::IO::SEEK_END)
// 340:         end_mark = @io.pos
// 341:         @io.seek(start_mark, ::IO::SEEK_SET)
// 342:
// 343:         end_mark - start_mark
// 344:       end
// 345:
// 346:       def offset
// 347:         @pos
// 348:       end
// 349:
// 350:       def skip(n)
// 351:         raise IOError, "can not skip backwards" if n.negative?
// 352:         @io.seek(n, ::IO::SEEK_CUR)
// 353:         @pos += n
// 354:       end
// 355:
// 356:       def seek_abs(n)
// 357:         @io.seek(n + @initial_pos, ::IO::SEEK_SET)
// 358:         @pos = n
// 359:       end
// 360:
// 361:       def read(n)
// 362:         @io.read(n).tap { |data| @pos += (data&.size || 0) }
// 363:       end
// 364:
// 365:       def write(data)
// 366:         @io.write(data)
// 367:       end
// 368:     end
// 369:
// 370:     # An IO stream may be transformed before processing.
// 371:     # e.g. encoding, compression, buffered.
// 372:     #
// 373:     # Multiple transforms can be chained together.
// 374:     #
// 375:     # To create a new transform layer, subclass +Transform+.
// 376:     # Override the public methods +#read+ and +#write+ at a minimum.
// 377:     # Additionally the hook, +#before_transform+, +#after_read_transform+
// 378:     # and +#after_write_transform+ are available as well.
// 379:     #
// 380:     # IMPORTANT!  If your transform changes the size of the underlying
// 381:     # data stream (e.g. compression), then call
// 382:     # +::transform_changes_stream_length!+ in your subclass.
// 383:     class Transform
// 384:       class << self
// 385:         # Indicates that this transform changes the length of the
// 386:         # underlying data. e.g. performs compression or error correction
// 387:         def transform_changes_stream_length!
// 388:           prepend(UnSeekableIO)
// 389:         end
// 390:       end
// 391:
// 392:       def initialize
// 393:         @chain_io = nil
// 394:       end
// 395:
// 396:       # Initialises this transform.
// 397:       #
// 398:       # Called before any IO operations.
// 399:       def before_transform; end
// 400:
// 401:       # Flushes the input stream.
// 402:       #
// 403:       # Called after the final read operation.
// 404:       def after_read_transform; end
// 405:
// 406:       # Flushes the output stream.
// 407:       #
// 408:       # Called after the final write operation.
// 409:       def after_write_transform; end
// 410:
// 411:       # Prepends this transform to the given +chain+.
// 412:       #
// 413:       # Returns self (the new head of chain).
// 414:       def prepend_to_chain(chain)
// 415:         @chain_io = chain
// 416:         before_transform
// 417:         self
// 418:       end
// 419:
// 420:       # Is the IO seekable?
// 421:       def seekable?
// 422:         @chain_io.seekable?
// 423:       end
// 424:
// 425:       # How many bytes are available for reading?
// 426:       def num_bytes_remaining
// 427:         chain_num_bytes_remaining
// 428:       end
// 429:
// 430:       # The current offset within the stream.
// 431:       def offset
// 432:         chain_offset
// 433:       end
// 434:
// 435:       # Skips forward +n+ bytes in the input stream.
// 436:       def skip(n)
// 437:         chain_skip(n)
// 438:       end
// 439:
// 440:       # Seeks to the given absolute position.
// 441:       def seek_abs(n)
// 442:         chain_seek_abs(n)
// 443:       end
// 444:
// 445:       # Reads +n+ bytes from the stream.
// 446:       def read(n)
// 447:         chain_read(n)
// 448:       end
// 449:
// 450:       # Writes +data+ to the stream.
// 451:       def write(data)
// 452:         chain_write(data)
// 453:       end
// 454:
// 455:       #-------------
// 456:       private
// 457:
// 458:       def create_empty_binary_string
// 459:         String.new.force_encoding(Encoding::BINARY)
// 460:       end
// 461:
// 462:       def chain_seekable?
// 463:         @chain_io.seekable?
// 464:       end
// 465:
// 466:       def chain_num_bytes_remaining
// 467:         @chain_io.num_bytes_remaining
// 468:       end
// 469:
// 470:       def chain_offset
// 471:         @chain_io.offset
// 472:       end
// 473:
// 474:       def chain_skip(n)
// 475:         @chain_io.skip(n)
// 476:       end
// 477:
// 478:       def chain_seek_abs(n)
// 479:         @chain_io.seek_abs(n)
// 480:       end
// 481:
// 482:       def chain_read(n)
// 483:         @chain_io.read(n)
// 484:       end
// 485:
// 486:       def chain_write(data)
// 487:         @chain_io.write(data)
// 488:       end
// 489:     end
// 490:
// 491:     # A module to be prepended to +RawIO+ or +Transform+ when the data
// 492:     # stream is not seekable.  This is either due to underlying stream
// 493:     # being unseekable or the transform changes the number of bytes.
// 494:     module UnSeekableIO
// 495:       def seekable?
// 496:         false
// 497:       end
// 498:
// 499:       def num_bytes_remaining
// 500:         raise IOError, "stream is unseekable"
// 501:       end
// 502:
// 503:       def skip(n)
// 504:         raise IOError, "can not skip backwards" if n.negative?
// 505:
// 506:         # skip over data in 8k blocks
// 507:         while n > 0
// 508:           bytes_to_read = [n, 8192].min
// 509:           read(bytes_to_read)
// 510:           n -= bytes_to_read
// 511:         end
// 512:       end
// 513:
// 514:       def seek_abs(n)
// 515:         skip(n - offset)
// 516:       end
// 517:     end
// 518:   end
// 519: end
