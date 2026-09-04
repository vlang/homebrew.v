module homebrew

import ruby

// Translated from Homebrew/brew `readline_nonblock.rb`.

pub const readline_nonblock_buffer_size = 4096

pub struct ReadlineWaitReadableError {}

pub fn (_ ReadlineWaitReadableError) msg() string {
	return 'read would block'
}

pub fn (_ ReadlineWaitReadableError) code() int {
	return 11
}

pub struct ReadlineEofError {}

pub fn (_ ReadlineEofError) msg() string {
	return 'end of file reached'
}

pub fn (_ ReadlineEofError) code() int {
	return 0
}

pub enum ReadlineReadEventKind {
	data
	wait_readable
	eof
}

pub struct ReadlineReadEvent {
pub:
	kind ReadlineReadEventKind
	data string
}

// ReadlineNonblockSource is a deterministic read_nonblock boundary. Oversized
// data events are returned over multiple calls using the requested byte limit.
pub struct ReadlineNonblockSource {
pub:
	events []ReadlineReadEvent
pub mut:
	cursor            int
	offset            int
	read_calls        int
	last_request_size int
}

// ReadlineNonblock retains data already obtained from the source separately
// from a partial line that must survive IO::WaitReadable.
pub struct ReadlineNonblock {
pub mut:
	buffer string
	line   string
}

pub fn readline_data(data string) ReadlineReadEvent {
	return ReadlineReadEvent{
		kind: .data
		data: data
	}
}

pub fn readline_wait_readable() ReadlineReadEvent {
	return ReadlineReadEvent{
		kind: .wait_readable
	}
}

pub fn readline_eof() ReadlineReadEvent {
	return ReadlineReadEvent{
		kind: .eof
	}
}

pub fn (mut source ReadlineNonblockSource) read_nonblock(max_bytes int) !string {
	source.read_calls++
	source.last_request_size = max_bytes
	if max_bytes <= 0 {
		return error('read size must be positive')
	}
	if source.cursor >= source.events.len {
		return ReadlineEofError{}
	}
	event := source.events[source.cursor]
	match event.kind {
		.data {
			if source.offset >= event.data.len {
				source.cursor++
				source.offset = 0
				return source.read_nonblock(max_bytes)
			}
			remaining := event.data.len - source.offset
			length := if remaining < max_bytes { remaining } else { max_bytes }
			chunk := event.data[source.offset..source.offset + length]
			source.offset += length
			if source.offset == event.data.len {
				source.cursor++
				source.offset = 0
			}
			if chunk.len == 0 {
				return ReadlineWaitReadableError{}
			}
			return chunk
		}
		.wait_readable {
			source.cursor++
			source.offset = 0
			return ReadlineWaitReadableError{}
		}
		.eof {
			source.cursor++
			source.offset = 0
			return ReadlineEofError{}
		}
	}
}

pub fn (mut reader ReadlineNonblock) read(mut source ReadlineNonblockSource) !string {
	for {
		if newline_index := reader.buffer.index('\n') {
			reader.line += reader.buffer[..newline_index + 1]
			reader.buffer = reader.buffer[newline_index + 1..]
			result := reader.line
			reader.line = ''
			return result
		}
		reader.line += reader.buffer
		reader.buffer = ''
		reader.buffer = source.read_nonblock(readline_nonblock_buffer_size) or {
			if err is ReadlineEofError {
				if reader.line.len == 0 {
					return err
				}
				result := reader.line
				reader.line = ''
				return result
			}
			return err
		}
	}
	return error('unreachable readline state')
}

fn readline_nonblock_boundary_value(reader ReadlineNonblock, source ReadlineNonblockSource,
	status string, value string) ruby.Value {
	return ruby.Value{
		type_name: 'ReadlineNonblock'
		repr: value
		array_data: source.events.map(readline_event_value(it))
		attributes: {
			'buffer':            reader.buffer
			'line':              reader.line
			'cursor':            source.cursor.str()
			'offset':            source.offset.str()
			'read_calls':        source.read_calls.str()
			'last_request_size': source.last_request_size.str()
			'status':            status
			'value':             value
		}
	}
}

fn readline_event_value(event ReadlineReadEvent) ruby.Value {
	return match event.kind {
		.data { ruby.string_value(event.data) }
		.wait_readable { ruby.object_value('IO::WaitReadable', '') }
		.eof { ruby.object_value('EOFError', '') }
	}
}

fn readline_events_from_value(value ruby.Value) []ReadlineReadEvent {
	event_values := if value.type_name == 'Array' { value.array_data } else { value.array_data }
	return event_values.map(match it.type_name {
		'IO::WaitReadable' { readline_wait_readable() }
		'EOFError' { readline_eof() }
		else { readline_data(it.as_string()) }
	})
}

fn readline_nonblock_from_value(value ruby.Value) ReadlineNonblock {
	return ReadlineNonblock{
		buffer: value.attributes['buffer'] or { '' }
		line: value.attributes['line'] or { '' }
	}
}

fn readline_nonblock_source_from_value(value ruby.Value) ReadlineNonblockSource {
	return ReadlineNonblockSource{
		events: readline_events_from_value(value)
		cursor: (value.attributes['cursor'] or { '0' }).int()
		offset: (value.attributes['offset'] or { '0' }).int()
		read_calls: (value.attributes['read_calls'] or { '0' }).int()
		last_request_size: (value.attributes['last_request_size'] or { '0' }).int()
	}
}
