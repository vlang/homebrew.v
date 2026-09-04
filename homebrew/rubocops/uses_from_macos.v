module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/uses_from_macos.rb`.
pub const provided_by_macos_formulae = [
	'apr',
	'bc',
	'bc-gh',
	'berkeley-db',
	'bison',
	'bzip2',
	'cups',
	'curl',
	'cyrus-sasl',
	'dyld-headers',
	'ed',
	'expat',
	'file-formula',
	'flex',
	'gperf',
	'icu4c',
	'krb5',
	'libarchive',
	'libedit',
	'libffi',
	'libiconv',
	'libpcap',
	'libressl',
	'libxcrypt',
	'libxml2',
	'libxslt',
	'llvm',
	'lsof',
	'm4',
	'ncompress',
	'ncurses',
	'net-snmp',
	'netcat',
	'openldap',
	'pax',
	'pcsc-lite',
	'pod2man',
	'ruby',
	'sqlite',
	'ssh-copy-id',
	'swift',
	'tcl-tk',
	'unifdef',
	'unzip',
	'whois',
	'zip',
	'zlib',
]

pub const allowed_uses_from_macos_deps = [
	'bash',
	'cpio',
	'expect',
	'git',
	'groff',
	'gzip',
	'jq',
	'less',
	'mandoc',
	'openssl',
	'perl',
	'php',
	'python',
	'rsync',
	'vim',
	'xz',
	'zsh',
]

pub struct UsesFromMacosProblem {
pub:
	kind       string
	dependency string
	begin_pos  int
	end_pos    int
	message    string
}

fn uses_from_macos_calls(source string) []UsesFromMacosProblem {
	mut calls := []UsesFromMacosProblem{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		mut cursor := 0
		for cursor < line.len && (line[cursor] == ` ` || line[cursor] == `\t`) {
			cursor++
		}
		if line[cursor..].starts_with('uses_from_macos') {
			after := cursor + 'uses_from_macos'.len
			if after == line.len || line[after] == ` ` || line[after] == `\t` || line[after] == `(` {
				mut quote := after
				for quote < line.len && line[quote] != `"` {
					quote++
				}
				if quote < line.len {
					mut end := quote + 1
					mut escaped := false
					for end < line.len {
						if escaped {
							escaped = false
						} else if line[end] == `\\` {
							escaped = true
						} else if line[end] == `"` {
							if end > quote + 1 {
								calls << UsesFromMacosProblem{
									dependency: line[quote + 1..end]
									begin_pos: line_start + cursor
									end_pos: line_end
								}
							}
							break
						}
						end++
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return calls
}

pub fn audit_provided_by_macos(source string, formula_name string) []UsesFromMacosProblem {
	if !source.contains('keg_only :provided_by_macos') || formula_name in provided_by_macos_formulae {
		return []UsesFromMacosProblem{}
	}
	position := source.index('keg_only :provided_by_macos') or { 0 }
	return [UsesFromMacosProblem{
		kind: 'missing_from_provided_list'
		begin_pos: position
		end_pos: position + 'keg_only :provided_by_macos'.len
		message: 'Formulae that are `keg_only :provided_by_macos` should be added to the `PROVIDED_BY_MACOS_FORMULAE` list (in the Homebrew/brew repository)'
	}]
}

pub fn audit_uses_from_macos(source string) []UsesFromMacosProblem {
	depends_on_linux := source.contains('depends_on :linux')
	mut problems := []UsesFromMacosProblem{}
	for call in uses_from_macos_calls(source) {
		if depends_on_linux {
			problems << UsesFromMacosProblem{
				...call
				kind: 'linux_required'
				message: '`uses_from_macos` should not be used when Linux is required.'
			}
		}
		if call.dependency !in allowed_uses_from_macos_deps && call.dependency !in provided_by_macos_formulae {
			problems << UsesFromMacosProblem{
				...call
				kind: 'non_macos_dependency'
				message: "`uses_from_macos` should only be used for macOS dependencies, not '${call.dependency}'."
			}
		}
	}
	return problems
}

fn uses_from_macos_problem_value(problem UsesFromMacosProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':       problem.kind
		'dependency': problem.dependency
		'begin_pos':  problem.begin_pos.str()
		'end_pos':    problem.end_pos.str()
		'message':    problem.message
	})
}
