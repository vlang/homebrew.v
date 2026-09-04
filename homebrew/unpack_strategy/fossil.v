module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/fossil.rb`.

pub fn fossil_extensions() []string {
	return []
}

pub fn fossil_can_extract(path string) bool {
	if !file_starts_with(path, [u8(`S`), `Q`, `L`, `i`, `t`, `e`, ` `, `f`, `o`, `r`, `m`, `a`,
		`t`, ` `, `3`, 0]) {
		return false
	}
	sqlite := command_path('sqlite3') or { return false }
	query := "select count(*) from sqlite_master where type = 'view' and name = 'artifact'"
	result := ruby.run_command(sqlite, [path, query])
	return result.exit_code == 0 && result.output.trim_space().int() == 1
}

pub fn fossil_extract_to_dir(strategy Strategy, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	mut args := ['open', strategy.path]
	if strategy.ref_type != '' && strategy.ref != '' { args << strategy.ref }
	checked_command_in_directory(command_path('fossil')!, args, unpack_dir)!
}
