module homebrew

import ruby
import os
import time

// Translated from Homebrew/brew `mktemp.rb`.
// The original source is retained below until every stub has a typed V body.
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
	action fn(mut Mktemp) !ruby.Value) !ruby.Value {
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

// Ruby attr_reader `attr_reader :tmpdir` at line 14.
pub fn ruby_mktemp_l14_d1_tmpdir(args ...ruby.Value) ruby.Value {
	stage := mktemp_from_args(args, 'tmpdir')
	return if stage.tmpdir == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.object_value('Pathname', stage.tmpdir)
	}
}

// Ruby method `initialize(prefix, retain: false, retain_in_cache: false)` at line 17.
pub fn ruby_mktemp_l17_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'prefix is required')
	}
	return mktemp_value(new_mktemp(args[0].as_string(), MktempConfig{
		retain: args.len > 1 && args[1].bool_data
		retain_in_cache: args.len > 2 && args[2].bool_data
		cache_dir: if args.len > 3 { args[3].as_string() } else { '' }
		temp_dir: if args.len > 4 { args[4].as_string() } else { '' }
		original_brew_file: if args.len > 5 { args[5].as_string() } else { '' }
	}))
}

// Ruby method `retain!` at line 27.
pub fn ruby_mktemp_l27_d3_retain(args ...ruby.Value) ruby.Value {
	mut stage := mktemp_from_args(args, 'retain!')
	stage.retain_files()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `retain?` at line 33.
pub fn ruby_mktemp_l33_d4_retain(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mktemp_from_args(args, 'retain?').should_retain())
}

// Ruby method `retain_in_cache?` at line 39.
pub fn ruby_mktemp_l39_d5_retain_in_cache(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mktemp_from_args(args, 'retain_in_cache?').should_retain_in_cache())
}

// Ruby method `quiet!` at line 45.
pub fn ruby_mktemp_l45_d6_quiet(args ...ruby.Value) ruby.Value {
	mut stage := mktemp_from_args(args, 'quiet!')
	stage.suppress_messages()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `to_s` at line 50.
pub fn ruby_mktemp_l50_d7_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(mktemp_from_args(args, 'to_s').str())
}

// Ruby method `run(chdir: true, &_block)` at line 60.
pub fn ruby_mktemp_l60_d8_run(args ...ruby.Value) ruby.Value {
	mut stage := mktemp_from_args(args, 'run')
	chdir := if args.len > 1 { args[1].bool_data } else { true }
	stage.boundary_result = if args.len > 2 {
		args[2]
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return stage.run(chdir, mktemp_boundary_action) or {
		ruby.object_value('SystemCallError', err.msg())
	}
}

// Ruby method `chmod_rm_rf(path)` at line 114.
pub fn ruby_mktemp_l114_d9_chmod_rm_rf(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('NilClass', 'nil')
	}
	path := if args.len > 1 && args[0].type_name == 'Mktemp' {
		args[1].as_string()
	} else {
		args[args.len - 1].as_string()
	}
	mktemp_chmod_rm_rf(path)
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Performs {Formula#mktemp}'s functionality and tracks the results.
// 7: # Each instance is only intended to be used once.
// 8: # Can also be used to create a temporary directory with the brew instance's group.
// 9: class Mktemp
// 10:   include Utils::Output::Mixin
// 11:
// 12:   # Path to the tmpdir used in this run
// 13:   sig { returns(T.nilable(Pathname)) }
// 14:   attr_reader :tmpdir
// 15:
// 16:   sig { params(prefix: String, retain: T::Boolean, retain_in_cache: T::Boolean).void }
// 17:   def initialize(prefix, retain: false, retain_in_cache: false)
// 18:     @prefix = prefix
// 19:     @retain_in_cache = retain_in_cache
// 20:     @retain = T.let(retain || @retain_in_cache, T::Boolean)
// 21:     @quiet = T.let(false, T::Boolean)
// 22:     @tmpdir = T.let(nil, T.nilable(Pathname))
// 23:   end
// 24:
// 25:   # Instructs this {Mktemp} to retain the staged files.
// 26:   sig { void }
// 27:   def retain!
// 28:     @retain = true
// 29:   end
// 30:
// 31:   # True if the staged temporary files should be retained.
// 32:   sig { returns(T::Boolean) }
// 33:   def retain?
// 34:     @retain
// 35:   end
// 36:
// 37:   # True if the source files should be retained.
// 38:   sig { returns(T::Boolean) }
// 39:   def retain_in_cache?
// 40:     @retain_in_cache
// 41:   end
// 42:
// 43:   # Instructs this Mktemp to not emit messages when retention is triggered.
// 44:   sig { void }
// 45:   def quiet!
// 46:     @quiet = true
// 47:   end
// 48:
// 49:   sig { returns(String) }
// 50:   def to_s
// 51:     "[Mktemp: #{tmpdir} retain=#{@retain} quiet=#{@quiet}]"
// 52:   end
// 53:
// 54:   sig {
// 55:     type_parameters(:U).params(
// 56:       chdir:  T::Boolean,
// 57:       _block: T.proc.params(arg0: Mktemp).returns(T.type_parameter(:U)),
// 58:     ).returns(T.type_parameter(:U))
// 59:   }
// 60:   def run(chdir: true, &_block)
// 61:     prefix_name = @prefix.tr "@", "AT"
// 62:     @tmpdir = if retain_in_cache?
// 63:       tmp_dir = HOMEBREW_CACHE/"Sources/#{prefix_name}"
// 64:       chmod_rm_rf(tmp_dir) # clear out previous staging directory
// 65:       tmp_dir.mkpath
// 66:       tmp_dir
// 67:     else
// 68:       Pathname.new(Dir.mktmpdir("#{prefix_name}-", HOMEBREW_TEMP))
// 69:     end
// 70:
// 71:     # Make sure files inside the temporary directory have the same group as the
// 72:     # brew instance.
// 73:     #
// 74:     # Reference from `man 2 open`
// 75:     # > When a new file is created, it is given the group of the directory which
// 76:     # contains it.
// 77:     group_id = if HOMEBREW_ORIGINAL_BREW_FILE.grpowned?
// 78:       HOMEBREW_ORIGINAL_BREW_FILE.stat.gid
// 79:     else
// 80:       Process.gid
// 81:     end
// 82:     begin
// 83:       @tmpdir.chown(nil, group_id)
// 84:     rescue Errno::EPERM
// 85:       require "etc"
// 86:       group_name = begin
// 87:         Etc.getgrgid(group_id)&.name
// 88:       rescue ArgumentError
// 89:         # Cover for misconfigured NSS setups
// 90:         nil
// 91:       end
// 92:       opoo "Failed setting group \"#{group_name || group_id}\" on #{@tmpdir}"
// 93:     end
// 94:
// 95:     begin
// 96:       if chdir
// 97:         Dir.chdir(@tmpdir) { yield self }
// 98:       else
// 99:         yield self
// 100:       end
// 101:     ensure
// 102:       ignore_interrupts { chmod_rm_rf(@tmpdir) } unless retain?
// 103:     end
// 104:   ensure
// 105:     if retain? && @tmpdir.present? && !@quiet
// 106:       message = retain_in_cache? ? "Source files for debugging available at:" : "Temporary files retained at:"
// 107:       ohai message, @tmpdir.to_s
// 108:     end
// 109:   end
// 110:
// 111:   private
// 112:
// 113:   sig { params(path: Pathname).void }
// 114:   def chmod_rm_rf(path)
// 115:     if path.directory? && !path.symlink?
// 116:       FileUtils.chmod("u+rw", path) if path.owned? # Need permissions in order to see the contents
// 117:       path.children.each { |child| chmod_rm_rf(child) }
// 118:       FileUtils.rmdir(path)
// 119:     else
// 120:       FileUtils.rm_f(path)
// 121:     end
// 122:   rescue
// 123:     nil # Just skip this directory.
// 124:   end
// 125: end
