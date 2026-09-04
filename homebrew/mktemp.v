module homebrew

import ruby
import os
import time

// Translated from Homebrew/brew `mktemp.rb`.
pub struct MktempConfig {
pub:
	retain             bool
	retain_in_cache    bool
	cache_dir          string
	temp_dir           string
	original_brew_file string
}

@[heap]
pub struct Mktemp {
pub:
	prefix             string
	cache_dir          string
	temp_dir           string
	original_brew_file string
pub mut:
	retain          bool
	retain_in_cache bool
	quiet           bool
	tmpdir          string
	messages        []string
	warnings        []string
	boundary_result ruby.Value
}

pub fn new_mktemp(prefix string, config MktempConfig) &Mktemp {
	cache_dir := if config.cache_dir != '' {
		config.cache_dir
	} else {
		os.getenv('HOMEBREW_CACHE')
	}
	temp_dir := if config.temp_dir != '' {
		config.temp_dir
	} else if os.getenv('HOMEBREW_TEMP') != '' {
		os.getenv('HOMEBREW_TEMP')
	} else {
		os.temp_dir()
	}
	return &Mktemp{
		prefix: prefix
		cache_dir: cache_dir
		temp_dir: temp_dir
		original_brew_file: config.original_brew_file
		retain: config.retain || config.retain_in_cache
		retain_in_cache: config.retain_in_cache
	}
}

pub fn (mut stage Mktemp) retain_files() {
	stage.retain = true
}

pub fn (stage Mktemp) should_retain() bool {
	return stage.retain
}

pub fn (stage Mktemp) should_retain_in_cache() bool {
	return stage.retain_in_cache
}

pub fn (mut stage Mktemp) suppress_messages() {
	stage.quiet = true
}

pub fn (stage Mktemp) str() string {
	return '[Mktemp: ${stage.tmpdir} retain=${stage.retain} quiet=${stage.quiet}]'
}

fn mktemp_unique_directory(parent string, prefix string) !string {
	os.mkdir_all(parent)!
	stamp := time.now().unix_micro()
	for attempt in 0 .. 100 {
		path := os.join_path(parent, '${prefix}-${os.getpid()}-${stamp}-${attempt}')
		os.mkdir(path) or {
			if os.exists(path) {
				continue
			}
			return err
		}
		return path
	}
	return error('unable to create a unique temporary directory for ${prefix}')
}

fn (mut stage Mktemp) prepare() ! {
	// Ruby String#tr maps the single source character `@` to the first replacement
	// character, so `tr "@", "AT"` turns `@` into `A`.
	prefix_name := stage.prefix.replace('@', 'A')
	stage.tmpdir = if stage.should_retain_in_cache() {
		path := os.join_path(stage.cache_dir, 'Sources', prefix_name)
		mktemp_chmod_rm_rf(path)
		os.mkdir_all(path)!
		path
	} else {
		mktemp_unique_directory(stage.temp_dir, prefix_name)!
	}

	mut group_id := os.getgid()
	if stage.original_brew_file != '' {
		if stat := os.stat(stage.original_brew_file) {
			if int(stat.gid) == os.getgid() {
				group_id = int(stat.gid)
			}
		}
	}
	os.chown(stage.tmpdir, -1, group_id) or {
		stage.warnings << 'Failed setting group "${group_id}" on ${stage.tmpdir}'
	}
}

fn (mut stage Mktemp) finish() {
	if !stage.should_retain() {
		mktemp_chmod_rm_rf(stage.tmpdir)
	}
	if stage.should_retain() && stage.tmpdir != '' && !stage.quiet {
		message := if stage.should_retain_in_cache() {
			'Source files for debugging available at:'
		} else {
			'Temporary files retained at:'
		}
		stage.messages << '${message}\n${stage.tmpdir}'
	}
}

pub fn (mut stage Mktemp) run(chdir bool,
	action fn (mut Mktemp) !ruby.Value) !ruby.Value {
	stage.prepare()!
	original_directory := os.getwd()
	mut changed_directory := false
	defer {
		if changed_directory {
			os.chdir(original_directory) or {}
		}
		stage.finish()
	}
	if chdir {
		os.chdir(stage.tmpdir)!
		changed_directory = true
	}
	return action(mut stage)
}

pub fn mktemp_chmod_rm_rf(path string) {
	if path == '' || (!os.exists(path) && !os.is_link(path)) {
		return
	}
	if os.is_dir(path) && !os.is_link(path) {
		if stat := os.stat(path) {
			if int(stat.uid) == os.getuid() {
				os.chmod(path, int(stat.mode) | 0o600) or {}
			}
		}
		for child in os.ls(path) or { return } {
			mktemp_chmod_rm_rf(os.join_path(path, child))
		}
		os.rmdir(path) or {}
	} else {
		os.rm(path) or {}
	}
}

fn mktemp_value(stage &Mktemp) ruby.Value {
	return ruby.structured_value('Mktemp', stage.str(), {
		'mktemp_address': u64(voidptr(stage)).str()
		'prefix':         stage.prefix
		'tmpdir':         stage.tmpdir
	})
}

fn mktemp_from_args(args []ruby.Value, method string) &Mktemp {
	if args.len == 0 || args[0].type_name != 'Mktemp' {
		panic('Mktemp#${method} requires a translated Mktemp receiver')
	}
	address := args[0].attributes['mktemp_address'] or {
		panic('Mktemp receiver has no translated state')
	}
	return unsafe { &Mktemp(voidptr(address.u64())) }
}

pub fn mktemp_boundary(stage &Mktemp) ruby.Value {
	return mktemp_value(stage)
}

fn mktemp_boundary_action(mut stage Mktemp) !ruby.Value {
	return stage.boundary_result
}

// Ruby method `retain!` at line 27.
pub fn ruby_mktemp_l27_d3_retain(args ...ruby.Value) ruby.Value {
	mut stage := mktemp_from_args(args, 'retain!')
	stage.retain_files()
	return ruby.object_value('NilClass', 'nil')
}
