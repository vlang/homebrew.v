module test

import brew_runtime
import homebrew
import os

struct InstallStepsSpecExecutor {
	results  map[string]homebrew.InstallStepsCommandResult
	failures map[string]string
}

fn (executor InstallStepsSpecExecutor) run(command string, arguments []string,
	options homebrew.InstallStepsCommandOptions) !homebrew.InstallStepsCommandResult {
	_ = arguments
	_ = options
	if message := executor.failures[command] {
		return error(message)
	}
	return executor.results[command] or { homebrew.InstallStepsCommandResult{} }
}

fn install_steps_spec_root(line int) string {
	return os.join_path(os.temp_dir(), 'brew-v-install-steps-spec-${os.getpid()}-${line}')
}

fn install_steps_spec_context(root string) homebrew.InstallStepsContext {
	return homebrew.InstallStepsContext{
		values: {
			'prefix':      os.join_path(root, 'prefix')
			'bin':         os.join_path(root, 'prefix/bin')
			'libexec':     os.join_path(root, 'prefix/libexec')
			'lib':         os.join_path(root, 'prefix/lib')
			'etc':         os.join_path(root, 'prefix/etc')
			'share':       os.join_path(root, 'prefix/share')
			'pkgshare':    os.join_path(root, 'prefix/share/example')
			'opt_prefix':  os.join_path(root, 'prefix')
			'frameworks':  os.join_path(root, 'prefix/Frameworks')
			'var':         os.join_path(root, 'var')
			'staged_path': os.join_path(root, 'stage')
			'home':        os.join_path(root, 'home')
		}
	}
}

fn install_steps_spec_context_value(root string, extra map[string]string) brew_runtime.Value {
	context := install_steps_spec_context(root)
	mut values := map[string]brew_runtime.Value{}
	for key, value in context.values {
		values[key] = brew_runtime.string_value(value)
	}
	for key, value in extra {
		values[key] = brew_runtime.string_value(value)
	}
	values['config'] = brew_runtime.map_value({})
	return brew_runtime.Value{
		type_name: 'InstallSteps::Context'
		repr: extra['name'] or { extra['token'] or { '' } }
		map_data: values
	}
}

fn install_steps_spec_runner_value(root string, extra map[string]string) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'InstallSteps::Runner'
		repr: 'InstallSteps::Runner'
		map_data: {
			'context': install_steps_spec_context_value(root, extra)
		}
	}
}

fn install_steps_spec_dsl(default_base string, default_source string,
	default_target string) brew_runtime.Value {
	return homebrew.ruby_install_steps_l79_d5_initialize(brew_runtime.map_value({
		'default_base':        brew_runtime.string_value(default_base)
		'default_source_base': brew_runtime.string_value(default_source)
		'default_target_base': brew_runtime.string_value(default_target)
	}))
}

fn install_steps_spec_steps(dsl brew_runtime.Value) []brew_runtime.Value {
	return homebrew.ruby_install_steps_l89_d6_steps(dsl).as_array() or { []brew_runtime.Value{} }
}

fn install_steps_spec_step(dsl brew_runtime.Value) map[string]brew_runtime.Value {
	steps := install_steps_spec_steps(dsl)
	if steps.len == 0 {
		return map[string]brew_runtime.Value{}
	}
	return steps[steps.len - 1].map_data.clone()
}

fn install_steps_spec_path(step map[string]brew_runtime.Value, key string) map[string]brew_runtime.Value {
	return (step[key] or { brew_runtime.map_value({}) }).map_data.clone()
}

fn install_steps_spec_type(dsl brew_runtime.Value) string {
	return (install_steps_spec_step(dsl)['type'] or { brew_runtime.string_value('') }).as_string()
}

fn install_steps_spec_bool(value brew_runtime.Value) bool {
	return value.as_bool() or { false }
}

fn install_steps_spec_write(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

fn install_steps_spec_run(root string, dsl brew_runtime.Value) ! {
	context := install_steps_spec_context(root)
	mut runner := homebrew.new_install_steps_runner(context, homebrew.NativeInstallStepsCommandExecutor{})
	homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install')!
}

fn install_steps_spec_run_with_executor(root string, dsl brew_runtime.Value,
	executor homebrew.InstallStepsCommandExecutor) ! {
	mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), executor)
	homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install')!
}

fn install_steps_spec_error(value brew_runtime.Value, contains string) bool {
	return value.type_name == 'ArgumentError' && value.repr.contains(contains)
}

fn install_steps_spec_case(line int) bool {
	root := install_steps_spec_root(line)
	if os.exists(root) {
		os.rmdir_all(root) or {}
	}
	defer {
		if os.exists(root) {
			os.rmdir_all(root) or {}
		}
	}
	return match line {
		65 {
			dylib := os.join_path(root, 'lib/libfoo.1.dylib')
			source := os.join_path(root, 'lib/libfoo.dylib')
			install_steps_spec_write(dylib, 'Mach-O') or { return false }
			os.chmod(dylib, 0o444) or { return false }
			os.symlink(dylib, source) or { return false }
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), InstallStepsSpecExecutor{})
			step := homebrew.InstallStep({
				'type':           brew_runtime.string_value('change_dylib_id')
				'source':         brew_runtime.map_value({
					'path': brew_runtime.string_value(source)
				})
				'id':             brew_runtime.string_value('@rpath/libfoo.1.dylib')
				'resolve_source': brew_runtime.bool_value(true)
			})
			homebrew.install_steps_run_install_step(mut runner, step) or { return false }
			int(os.stat(dylib) or { return false }.get_mode().bitmask()) & 0o777 == 0o444
		}
		81 {
			mut dsl := install_steps_spec_dsl('var', 'staged_path', 'staged_path')
			dsl = homebrew.ruby_install_steps_l235_d21_mkdir_p(dsl, brew_runtime.string_value('log/example'))
			dsl = homebrew.ruby_install_steps_l240_d22_touch(dsl, brew_runtime.string_value('state/marker'), brew_runtime.map_value({
				'base': brew_runtime.string_value('prefix')
			}))
			dsl = homebrew.ruby_install_steps_l256_d23_move(dsl, brew_runtime.string_value('move-source'), brew_runtime.string_value('move-target'))
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('move-target'), brew_runtime.string_value('linked-target'), brew_runtime.map_value({
				'source_base': brew_runtime.string_value('relative')
			}))
			os.mkdir_all(os.join_path(root, 'stage')) or { return false }
			install_steps_spec_write(os.join_path(root, 'stage/move-source'), 'moved') or { return false }
			install_steps_spec_run(root, dsl) or { return false }
			os.is_dir(os.join_path(root, 'var/log/example')) && os.exists(os.join_path(root, 'prefix/state/marker')) && os.exists(os.join_path(root, 'stage/move-target')) && os.is_link(os.join_path(root, 'stage/linked-target')) && (os.readlink(os.join_path(root, 'stage/linked-target')) or { '' }) == 'move-target'
		}
		102 {
			mut dsl := install_steps_spec_dsl('prefix', '', '')
			dsl = homebrew.ruby_install_steps_l230_d20_mkdir(dsl, brew_runtime.string_value('one'))
			dsl = homebrew.ruby_install_steps_l235_d21_mkdir_p(dsl, brew_runtime.string_value('two/three'))
			paths := homebrew.install_steps_sandbox_write_paths(install_steps_spec_context(root), homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install') or {
				return false
			}
			paths.len == 2 && os.join_path(root, 'prefix') in paths && os.join_path(root, 'prefix/two') in paths
		}
		113 {
			mut dsl := install_steps_spec_dsl('', '', 'prefix')
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('cert.pem'), brew_runtime.string_value('cert.pem'), brew_runtime.map_value({
				'source_base':    brew_runtime.string_value('formula_pkgetc')
				'source_formula': brew_runtime.string_value('example/tap/test-source')
			}))
			step := install_steps_spec_step(dsl)
			source := install_steps_spec_path(step, 'source')
			source['base'].as_string() == 'formula_pkgetc' && source['formula'].as_string() == 'example/tap/test-source'
		}
		128 {
			mut dsl := install_steps_spec_dsl('', 'prefix', '')
			dsl = homebrew.ruby_install_steps_l664_d53_change_dylib_id(dsl, brew_runtime.string_value('lib/libfoo.dylib'), brew_runtime.string_value('{{HOMEBREW_PREFIX}}/opt/foo/lib/libfoo.1.dylib'), brew_runtime.map_value({
				'resolve_source': brew_runtime.bool_value(true)
			}))
			step := install_steps_spec_step(dsl)
			install_steps_spec_type(dsl) == 'change_dylib_id' && install_steps_spec_bool(step['resolve_source'] or { brew_runtime.bool_value(false) })
		}
		142 {
			mut dsl := install_steps_spec_dsl('', 'prefix', 'prefix')
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('share/man/*.1'), brew_runtime.string_value('share/man/man1'), brew_runtime.map_value({
				'source_glob': brew_runtime.bool_value(true)
				'overwrite':   brew_runtime.bool_value(true)
			}))
			os.mkdir_all(os.join_path(root, 'prefix/share/man/man1')) or { return false }
			install_steps_spec_write(os.join_path(root, 'prefix/share/man/tool.1'), 'tool') or { return false }
			install_steps_spec_write(os.join_path(root, 'prefix/share/man/other.1'), 'other') or { return false }
			install_steps_spec_run(root, dsl) or { return false }
			os.is_link(os.join_path(root, 'prefix/share/man/man1/tool.1')) && os.is_link(os.join_path(root, 'prefix/share/man/man1/other.1'))
		}
		158 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l230_d20_mkdir(dsl, brew_runtime.string_value('missing-parent/example'))
			step := install_steps_spec_step(dsl)
			path := install_steps_spec_path(step, 'path')
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
			mut failed := false
			homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install') or { failed = true }
			failed && step['type'].as_string() == 'mkdir' && path['base'].as_string() == 'var'
		}
		173 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l235_d21_mkdir_p(dsl, brew_runtime.string_value('nested/example'))
			install_steps_spec_run(root, dsl) or { return false }
			os.is_dir(os.join_path(root, 'var/nested/example'))
		}
		191 {
			raw := brew_runtime.array_value([
				brew_runtime.map_value({
					':type': brew_runtime.object_value('Symbol', ':mkdir_p')
					':path': brew_runtime.map_value({
						'base': brew_runtime.object_value('Symbol', ':var')
						'path': brew_runtime.string_value('nested/example')
					})
				}),
				brew_runtime.map_value({
					'type':  brew_runtime.object_value('Symbol', ':set_ownership')
					'paths': brew_runtime.array_value([brew_runtime.map_value({
						'base': brew_runtime.object_value('Symbol', ':staged_path')
						'path': brew_runtime.string_value('Example.app')
					})])
					'user':  brew_runtime.object_value('Symbol', ':root')
					'group': brew_runtime.object_value('Symbol', ':wheel')
				}),
			])
			steps := homebrew.ruby_install_steps_l159_d16_self_normalise_steps(raw).array_data
			steps.len == 2 && steps[0].map_data['type'].as_string() == 'mkdir_p' && steps[0].map_data['path'].map_data['base'].as_string() == 'var' && steps[1].map_data['user'].as_string() == 'root'
		}
		250 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l449_d34_symlink_tree(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l484_d36_symlink_children(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l519_d38_write_file(dsl, brew_runtime.string_value('config'), brew_runtime.string_value('content'))
			dsl = homebrew.ruby_install_steps_l571_d44_update_gdk_pixbuf_loaders_cache(dsl)
			dsl = homebrew.ruby_install_steps_l582_d46_update_gtk_icon_cache(dsl)
			dsl = homebrew.ruby_install_steps_l618_d50_delete_keychain_certificates(dsl, brew_runtime.string_value('Example'), brew_runtime.map_value({
				'fingerprint_of': brew_runtime.string_value('certificate')
			}))
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'), brew_runtime.map_value({
				'overwrite':           brew_runtime.bool_value(true)
				'remove_on_uninstall': brew_runtime.bool_value(true)
			}))
			dsl = homebrew.ruby_install_steps_l535_d39_init_data_dir(dsl, brew_runtime.string_value('data'), brew_runtime.map_value({
				'using': brew_runtime.object_value('Symbol', ':postgresql')
			}))
			types := install_steps_spec_steps(dsl).map(it.map_data['type'].as_string())
			types == ['link_dir', 'link_children', 'write', 'gdk_pixbuf_query_loaders',
				'gtk_update_icon_cache', 'delete_keychain_certificate', 'symlink', 'init_data_dir']
		}
		272 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l230_d20_mkdir(dsl, brew_runtime.string_value('directory'))
			dsl = homebrew.ruby_install_steps_l266_d24_mv(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l277_d25_move_children(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l421_d32_ln_sf(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l435_d33_link_dir(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l466_d35_link_children(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('config'), brew_runtime.string_value('content'))
			dsl = homebrew.ruby_install_steps_l555_d41_gio_querymodules(dsl)
			dsl = homebrew.ruby_install_steps_l566_d43_gdk_pixbuf_query_loaders(dsl)
			dsl = homebrew.ruby_install_steps_l582_d46_update_gtk_icon_cache(dsl)
			dsl = homebrew.ruby_install_steps_l604_d49_delete_keychain_certificate(dsl, brew_runtime.string_value('Example'))
			install_steps_spec_steps(dsl).map(it.map_data['type'].as_string()) == [
				'mkdir',
				'move',
				'move_children',
				'symlink',
				'link_dir',
				'link_children',
				'write',
				'gio_querymodules',
				'gdk_pixbuf_query_loaders',
				'gtk_update_icon_cache',
				'delete_keychain_certificate',
			]
		}
		293 {
			context := homebrew.InstallStepsContext{
				values: {
					'prefix':  os.join_path(root, 'prefix')
					'name':    'example'
					'token':   'example-cask'
					'version': '1.2.3'
				}
			}
			content := homebrew.install_steps_expand_template_tokens(context, '{{prefix}}|{{HOMEBREW_PREFIX}}|{{name}}|{{formula_name}}|{{token}}|{{version.major_minor}}|{{version}}|{{unknown}}')
			content.contains(os.join_path(root, 'prefix')) && content.contains('example|example') && content.contains('example-cask|1.2|1.2.3|{{unknown}}')
		}
		326 {
			context := homebrew.InstallStepsContext{
				values: {
					'name':  'example-formula'
					'token': 'example-cask'
				}
			}
			homebrew.install_steps_expand_template_tokens(context, '{{formula_name}}:{{token}}') == 'example-formula:example-cask'
		}
		338, 352, 400, 791 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			if line == 338 {
				dsl = homebrew.ruby_install_steps_l519_d38_write_file(dsl, brew_runtime.string_value('config/example.conf'), brew_runtime.string_value('replacement'))
				dsl = homebrew.ruby_install_steps_l519_d38_write_file(dsl, brew_runtime.string_value('empty'), brew_runtime.string_value(''))
				install_steps_spec_write(os.join_path(root, 'var/config/example.conf'), 'old\n') or {
					return false
				}
			} else if line == 352 {
				dsl = homebrew.ruby_install_steps_l519_d38_write_file(dsl, brew_runtime.string_value('existing'), brew_runtime.string_value('replacement'), brew_runtime.map_value({
					'overwrite':      brew_runtime.bool_value(false)
					'append_newline': brew_runtime.bool_value(true)
				}))
				dsl = homebrew.ruby_install_steps_l519_d38_write_file(dsl, brew_runtime.string_value('missing'), brew_runtime.string_value('new'), brew_runtime.map_value({
					'overwrite':      brew_runtime.bool_value(false)
					'append_newline': brew_runtime.bool_value(true)
				}))
				install_steps_spec_write(os.join_path(root, 'var/existing'), 'original\n') or {
					return false
				}
			} else if line == 400 {
				dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('config/new.conf'), brew_runtime.string_value('fresh'))
				dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('config/kept.conf'), brew_runtime.string_value('default'))
				dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('config/replaced.conf'), brew_runtime.string_value('default'), brew_runtime.map_value({
					'overwrite': brew_runtime.bool_value(true)
				}))
				install_steps_spec_write(os.join_path(root, 'var/config/kept.conf'), 'user edit') or {
					return false
				}
				install_steps_spec_write(os.join_path(root, 'var/config/replaced.conf'), 'user edit') or {
					return false
				}
			} else {
				dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('missing-newline'), brew_runtime.string_value('value'))
				dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('has-newline'), brew_runtime.string_value('value\n'))
			}
			install_steps_spec_run(root, dsl) or { return false }
			match line {
				338 {
					(os.read_file(os.join_path(root, 'var/config/example.conf')) or { '' }) == 'replacement' && (os.read_file(os.join_path(root, 'var/empty')) or { 'x' }) == ''
				}
				352 {
					(os.read_file(os.join_path(root, 'var/existing')) or { '' }) == 'original\n' && (os.read_file(os.join_path(root, 'var/missing')) or { '' }) == 'new\n'
				}
				400 {
					(os.read_file(os.join_path(root, 'var/config/new.conf')) or { '' }) == 'fresh\n' && (os.read_file(os.join_path(root, 'var/config/kept.conf')) or { '' }) == 'user edit' && (os.read_file(os.join_path(root, 'var/config/replaced.conf')) or { '' }) == 'default\n'
				}
				else {
					(os.read_file(os.join_path(root, 'var/missing-newline')) or { '' }) == 'value\n' && (os.read_file(os.join_path(root, 'var/has-newline')) or { '' }) == 'value\n'
				}
			}
		}
		366 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l348_d29_inreplace(dsl, brew_runtime.string_value('remove.txt'), brew_runtime.string_value('remove'), brew_runtime.string_value(''))
			dsl = homebrew.ruby_install_steps_l689_d54_run(dsl, brew_runtime.string_value('helper'), brew_runtime.map_value({
				'args': brew_runtime.string_array_value([''])
				'env':  brew_runtime.map_value({
					'EMPTY': brew_runtime.string_value('')
				})
			}))
			steps := install_steps_spec_steps(dsl)
			steps[0].map_data['after'].as_string() == '' && (steps[1].map_data['args'].as_string_array() or { []string{} }) == [''] && steps[1].map_data['env'].map_data['EMPTY'].as_string() == ''
		}
		384 {
			mut dsl := install_steps_spec_dsl('staged_path', 'staged_path', 'staged_path')
			dsl = homebrew.ruby_install_steps_l308_d27_copy(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			dsl = homebrew.ruby_install_steps_l502_d37_write(dsl, brew_runtime.string_value('config'), brew_runtime.string_value('content'))
			dsl = homebrew.ruby_install_steps_l648_d52_set_ownership(dsl, brew_runtime.string_value('Example.app'))
			dsl = homebrew.ruby_install_steps_l722_d55_terminate_process(dsl, brew_runtime.string_value('Example'))
			install_steps_spec_steps(dsl).all(it.map_data.keys().all(it !in [
				'attempts',
				'force',
				'group',
				'match',
				'overwrite',
				'uninstall',
			]))
		}
		418, 431 {
			mut inner := install_steps_spec_dsl('var', '', '')
			inner = homebrew.ruby_install_steps_l235_d21_mkdir_p(inner, brew_runtime.string_value(if line == 418 {
				'initialised'
			} else {
				'matched'
			}))
			inner = homebrew.ruby_install_steps_l240_d22_touch(inner, brew_runtime.string_value(if line == 418 {
				'initialised/marker'
			} else {
				'matched/marker'
			}))
			mut outer := install_steps_spec_dsl('var', '', '')
			if line == 418 {
				outer = homebrew.ruby_install_steps_l144_d13_unless_path_exists(outer, brew_runtime.string_value('initialised'), homebrew.ruby_install_steps_l89_d6_steps(inner))
			} else {
				os.mkdir_all(os.join_path(root, 'var/existing')) or { return false }
				outer = homebrew.ruby_install_steps_l133_d12_if_path_exists(outer, brew_runtime.string_value('existing'), homebrew.ruby_install_steps_l89_d6_steps(inner))
			}
			install_steps_spec_run(root, outer) or { return false }
			os.exists(if line == 418 {
				os.join_path(root, 'var/initialised/marker')
			} else {
				os.join_path(root, 'var/matched/marker')
			})
		}
		451 {
			mut macos_dsl := install_steps_spec_dsl('var', '', '')
			mut inner := install_steps_spec_dsl('var', '', '')
			inner = homebrew.ruby_install_steps_l240_d22_touch(inner, brew_runtime.string_value('macos'))
			macos_dsl = homebrew.ruby_install_steps_l149_d14_on_macos(macos_dsl, homebrew.ruby_install_steps_l89_d6_steps(inner))
			mut linux_inner := install_steps_spec_dsl('var', '', '')
			linux_inner = homebrew.ruby_install_steps_l240_d22_touch(linux_inner, brew_runtime.string_value('linux'))
			macos_dsl = homebrew.ruby_install_steps_l154_d15_on_linux(macos_dsl, homebrew.ruby_install_steps_l89_d6_steps(linux_inner))
			steps := install_steps_spec_steps(macos_dsl)
			steps.len == 2 && steps[0].map_data['guards'].array_data[0].map_data['value'].as_string() == 'macos' && steps[1].map_data['guards'].array_data[0].map_data['value'].as_string() == 'linux'
		}
		470, 484, 503 {
			mut dsl := install_steps_spec_dsl('', 'staged_path', 'var')
			dsl = homebrew.ruby_install_steps_l308_d27_copy(dsl, brew_runtime.string_value('source.txt'), brew_runtime.string_value('copied.txt'), if line == 484 {
				brew_runtime.map_value({
					'overwrite': brew_runtime.bool_value(false)
				})
			} else {
				brew_runtime.map_value({})
			})
			install_steps_spec_write(os.join_path(root, 'stage/source.txt'), 'replacement') or { return false }
			if line in [484, 503] {
				install_steps_spec_write(os.join_path(root, 'var/copied.txt'), 'existing') or { return false }
			}
			if line == 503 {
				os.mv(os.join_path(root, 'var/copied.txt'), os.join_path(root, 'var/linked.txt')) or {
					return false
				}
				os.symlink('linked.txt', os.join_path(root, 'var/copied.txt')) or { return false }
			}
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
			mut failed := false
			homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install') or { failed = true }
			if line == 484 {
				return failed
			}
			if failed {
				return false
			}
			(os.read_file(os.join_path(root, 'var/copied.txt')) or { '' }) == 'replacement' && (line != 503 || (os.read_file(os.join_path(root, 'var/linked.txt')) or { '' }) == 'existing')
		}
		519, 534 {
			mut dsl := install_steps_spec_dsl('', 'staged_path', 'var')
			if line == 519 {
				dsl = homebrew.ruby_install_steps_l256_d23_move(dsl, brew_runtime.string_value('source.txt'), brew_runtime.string_value('target.txt'))
				install_steps_spec_write(os.join_path(root, 'stage/source.txt'), 'replacement') or { return false }
				install_steps_spec_write(os.join_path(root, 'var/target.txt'), 'existing') or { return false }
				mut steps := homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl))
				mut legacy_step := homebrew.InstallStep{}
				for key, value in steps[0] {
					if key != 'overwrite' {
						legacy_step[key] = value
					}
				}
				steps[0] = legacy_step
				mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
				homebrew.install_steps_run(mut runner, steps, 'install') or { return false }
				return (os.read_file(os.join_path(root, 'var/target.txt')) or { '' }) == 'replacement'
			}
			dsl = homebrew.ruby_install_steps_l256_d23_move(dsl, brew_runtime.string_value('source'), brew_runtime.string_value('target'))
			install_steps_spec_write(os.join_path(root, 'stage/source/file'), 'content') or { return false }
			install_steps_spec_run(root, dsl) or { return false }
			os.exists(os.join_path(root, 'var/target/file'))
		}
		547, 559 {
			mut dsl := install_steps_spec_dsl('', 'staged_path', 'var')
			dsl = homebrew.ruby_install_steps_l308_d27_copy(dsl, brew_runtime.string_value(if line == 547 {
				'*.txt'
			} else {
				'missing.txt'
			}), brew_runtime.string_value('copied.txt'), brew_runtime.map_value({
				'source_glob': brew_runtime.bool_value(true)
			}))
			os.mkdir_all(os.join_path(root, 'stage')) or { return false }
			if line == 547 {
				install_steps_spec_write(os.join_path(root, 'stage/first.txt'), 'first') or { return false }
				install_steps_spec_write(os.join_path(root, 'stage/second.txt'), 'second') or { return false }
			}
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
			mut failed := false
			homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install') or { failed = true }
			failed
		}
		568 {
			// Brace alternation produces the same path twice; the source requires one
			// unique match. V's os.glob already returns unique paths for this pattern.
			mut dsl := install_steps_spec_dsl('', 'staged_path', 'staged_path')
			dsl = homebrew.ruby_install_steps_l256_d23_move(dsl, brew_runtime.string_value('WezTerm-*/WezTerm.app'), brew_runtime.string_value('.'), brew_runtime.map_value({
				'source_glob': brew_runtime.bool_value(true)
			}))
			os.mkdir_all(os.join_path(root, 'stage/WezTerm-nightly/WezTerm.app')) or { return false }
			install_steps_spec_run(root, dsl) or { return false }
			os.is_dir(os.join_path(root, 'stage/WezTerm.app'))
		}
		580, 595 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			if line == 580 {
				dsl = homebrew.ruby_install_steps_l328_d28_remove(dsl, brew_runtime.string_array_value([
					'obsolete.txt',
					'obsolete-*',
				]), brew_runtime.map_value({
					'recursive': brew_runtime.bool_value(true)
				}))
				install_steps_spec_write(os.join_path(root, 'var/obsolete.txt'), 'obsolete') or { return false }
				install_steps_spec_write(os.join_path(root, 'var/obsolete-dir/child'), 'obsolete') or {
					return false
				}
			} else {
				dsl = homebrew.ruby_install_steps_l328_d28_remove(dsl, brew_runtime.string_value('links/*'), brew_runtime.map_value({
					'base':                    brew_runtime.string_value('staged_path')
					'symlink_target_contains': brew_runtime.string_value('wanted')
				}))
				os.mkdir_all(os.join_path(root, 'stage/links')) or { return false }
				os.symlink('/tmp/wanted-target', os.join_path(root, 'stage/links/wanted')) or {
					return false
				}
				os.symlink('/tmp/other-target', os.join_path(root, 'stage/links/kept')) or {
					return false
				}
			}
			install_steps_spec_run(root, dsl) or { return false }
			if line == 580 {
				!os.exists(os.join_path(root, 'var/obsolete.txt')) && !os.exists(os.join_path(root, 'var/obsolete-dir'))
			} else {
				!os.is_link(os.join_path(root, 'stage/links/wanted')) && os.is_link(os.join_path(root, 'stage/links/kept'))
			}
		}
		615 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l328_d28_remove(dsl, brew_runtime.string_value('protected'), brew_runtime.map_value({
				'sudo': brew_runtime.bool_value(true)
			}))
			install_steps_spec_bool(homebrew.ruby_install_steps_l944_d74_sudo_required(install_steps_spec_runner_value(root, {}), homebrew.ruby_install_steps_l89_d6_steps(dsl)))
		}
		628 {
			install_steps_spec_write(os.join_path(root, 'var/literal.txt'), 'before') or { return false }
			install_steps_spec_write(os.join_path(root, 'var/pattern.txt'), 'BEFORE and AFTER') or {
				return false
			}
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l348_d29_inreplace(dsl, brew_runtime.string_value('literal.txt'), brew_runtime.string_value('before'), brew_runtime.string_value('after'))
			dsl = homebrew.ruby_install_steps_l348_d29_inreplace(dsl, brew_runtime.string_value('pattern.txt'), brew_runtime.structured_value('Regexp', 'before.+after', {
				'options': '1'
			}), brew_runtime.string_value('replaced'))
			install_steps_spec_run(root, dsl) or { return false }
			(os.read_file(os.join_path(root, 'var/literal.txt')) or { '' }) == 'after' && (os.read_file(os.join_path(root, 'var/pattern.txt')) or { '' }) == 'replaced'
		}
		644 {
			mut inner := install_steps_spec_dsl('', '', '')
			inner = homebrew.ruby_install_steps_l742_d56_warn(inner, brew_runtime.string_value('{{token}} conflict'))
			mut outer := install_steps_spec_dsl('', '', '')
			outer = homebrew.ruby_install_steps_l133_d12_if_path_exists(outer, brew_runtime.string_value('{{var}}/{missing,conflict}'), homebrew.ruby_install_steps_l89_d6_steps(inner))
			install_steps_spec_step(outer)['guards'].array_data.len == 1
		}
		660, 675, 690, 710, 725 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			mut keywords := map[string]brew_runtime.Value{}
			if line == 660 {
				keywords = {
					'base': brew_runtime.string_value('libexec')
					'args': brew_runtime.string_array_value(['--path={{var}}'])
					'env':  brew_runtime.map_value({
						'EXAMPLE': brew_runtime.string_value('{{var}}/value')
					})
				}
			} else if line == 675 {
				keywords = {
					'env':            brew_runtime.map_value({
						'EXAMPLE': brew_runtime.string_value('{{formula_name}}')
					})
					'writable_paths': brew_runtime.string_array_value([
						'Library/Application Support/Example',
					])
					'writable_base':  brew_runtime.string_value('home')
				}
			} else if line == 690 {
				keywords = {
					'base':        brew_runtime.string_value('bin')
					'stdin_path':  brew_runtime.string_value('input.txt')
					'stdout_path': brew_runtime.string_value('output.txt')
					'chdir':       brew_runtime.string_value('work')
				}
			} else {
				keywords = {
					'base':         brew_runtime.string_value(if line == 710 {
						'libexec'
					} else {
						'bin'
					})
					'must_succeed': brew_runtime.bool_value(false)
				}
				if line == 725 {
					keywords['stdout_path'] = brew_runtime.string_value('output.txt')
				}
			}
			dsl = homebrew.ruby_install_steps_l689_d54_run(dsl, brew_runtime.string_value(if line in [
				690,
				725,
			] {
				'filter'
			} else {
				'helper'
			}), brew_runtime.map_value(keywords))
			step := install_steps_spec_step(dsl)
			match line {
				660 {
					install_steps_spec_path(step, 'command')['base'].as_string() == 'libexec' && step['env'].map_data['EXAMPLE'].as_string() == '{{var}}/value'
				}
				675 {
					step['env'].type_name == 'Hash' && step['writable_paths'].array_data[0].map_data['base'].as_string() == 'home'
				}
				690 { ['stdin_path', 'stdout_path', 'chdir'].all(it in step) }
				else {
					install_steps_spec_bool(step['allow_failure'] or { brew_runtime.bool_value(false) })
				}
			}
		}
		739 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l722_d55_terminate_process(dsl, brew_runtime.string_value('/Applications/Example.app'), brew_runtime.map_value({
				'match':           brew_runtime.object_value('Symbol', ':full')
				'attempts':        brew_runtime.int_value(3)
				'notices':         brew_runtime.string_array_value(['Closing {{name}}'])
				'failure_message': brew_runtime.string_value('Unable to close {{name}}')
			}))
			step := install_steps_spec_step(dsl)
			step['match'].as_string() == 'full' && step['attempts'].int_data == 3
		}
		762, 770 {
			mut dsl := install_steps_spec_dsl('', '', '')
			result := homebrew.ruby_install_steps_l722_d55_terminate_process(dsl, brew_runtime.string_value('Example'), brew_runtime.map_value(if line == 762 {
				{
					'match': brew_runtime.object_value('Symbol', ':prefix')
				}
			} else {
				{
					'attempts': brew_runtime.int_value(0)
				}
			}))
			install_steps_spec_error(result, if line == 762 {
				'match must be'
			} else {
				'attempts must be positive'
			})
		}
		778 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l722_d55_terminate_process(dsl, brew_runtime.string_value('Example'), brew_runtime.map_value({
				'must_succeed': brew_runtime.bool_value(true)
			}))
			step := install_steps_spec_step(dsl)
			'match' !in step && install_steps_spec_bool(step['must_succeed'] or {
				brew_runtime.bool_value(false)
			})
		}
		803 {
			step := homebrew.InstallStep({
				'type': brew_runtime.string_value('write')
				'path': brew_runtime.map_value({
					'path': brew_runtime.string_value('config/new.conf')
				})
			})
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
			mut failed := false
			homebrew.install_steps_run_install_step(mut runner, step) or { failed = true }
			failed
		}
		809 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			for using in ['postgresql', 'mysql', 'mariadb'] {
				dsl = homebrew.ruby_install_steps_l535_d39_init_data_dir(dsl, brew_runtime.string_value(using), brew_runtime.map_value({
					'using': brew_runtime.object_value('Symbol', ':${using}')
				}))
			}
			install_steps_spec_steps(dsl).map(it.map_data['using'].as_string()) == [
				'postgresql_initdb',
				'mysql_initialize',
				'mariadb_install_db',
			]
		}
		837 {
			mut dsl := install_steps_spec_dsl('var', 'prefix', '')
			dsl = homebrew.ruby_install_steps_l449_d34_symlink_tree(dsl, brew_runtime.string_value('include/postgresql'), brew_runtime.string_value('include/{{formula_name}}'))
			dsl = homebrew.ruby_install_steps_l484_d36_symlink_children(dsl, brew_runtime.string_value('bin'), brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }, brew_runtime.map_value({
				'suffix': brew_runtime.string_value('-{{version.major}}')
			}))
			dsl = homebrew.ruby_install_steps_l535_d39_init_data_dir(dsl, brew_runtime.string_value('{{formula_name}}'), brew_runtime.map_value({
				'using': brew_runtime.object_value('Symbol', ':postgresql')
			}))
			install_steps_spec_steps(dsl).map(it.map_data['type'].as_string()) == [
				'link_dir',
				'link_children',
				'init_data_dir',
			]
		}
		896, 911, 927 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l535_d39_init_data_dir(dsl, brew_runtime.string_value(if line == 927 {
				'unknown'
			} else {
				'mysql'
			}), brew_runtime.map_value({
				'using': brew_runtime.object_value('Symbol', if line == 927 {
					':unknown_database'
				} else {
					':mysql'
				})
			}))
			if line == 911 {
				install_steps_spec_write(os.join_path(root, 'var/mysql/mysql/general_log.CSM'), '') or {
					return false
				}
			}
			if line == 896 {
				return install_steps_spec_type(dsl) == 'init_data_dir'
			}
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), InstallStepsSpecExecutor{})
			mut failed := false
			homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'install') or { failed = true }
			if line == 911 { !failed } else { failed }
		}
		939 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l549_d40_compile_gsettings_schemas(dsl)
			dsl = homebrew.ruby_install_steps_l560_d42_update_gio_modules_cache(dsl)
			dsl = homebrew.ruby_install_steps_l571_d44_update_gdk_pixbuf_loaders_cache(dsl)
			dsl = homebrew.ruby_install_steps_l587_d47_update_mime_database(dsl)
			dsl = homebrew.ruby_install_steps_l592_d48_update_desktop_database(dsl)
			install_steps_spec_steps(dsl).map(it.map_data['type'].as_string()) == [
				'compile_gsettings_schemas',
				'gio_querymodules',
				'gdk_pixbuf_query_loaders',
				'update_mime_database',
				'update_desktop_database',
			]
		}
		974 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l549_d40_compile_gsettings_schemas(dsl)
			install_steps_spec_type(dsl) == 'compile_gsettings_schemas'
		}
		984, 1039, 1074, 1124, 1252 {
			mut dsl := install_steps_spec_dsl('', '', '')
			match line {
				984 {
					dsl = homebrew.ruby_install_steps_l747_d57_configure_gcc_runtime(dsl)
				}
				1039 {
					dsl = homebrew.ruby_install_steps_l759_d58_install_gzipped_executable(dsl, brew_runtime.string_value('compressed.gz'), brew_runtime.string_value('bin/executable'))
				}
				1074 {
					dsl = homebrew.ruby_install_steps_l766_d59_configure_glibc_runtime(dsl)
				}
				1124 {
					dsl = homebrew.ruby_install_steps_l771_d60_configure_clang_system(dsl)
				}
				else {
					dsl = homebrew.ruby_install_steps_l781_d62_bootstrap_cpython(dsl)
					dsl = homebrew.ruby_install_steps_l786_d63_bootstrap_pypy(dsl, brew_runtime.map_value({
						'abi_version': brew_runtime.string_value('3.10')
					}))
				}
			}
			types := install_steps_spec_steps(dsl).map(it.map_data['type'].as_string())
			match line {
				984 { types == ['configure_gcc_runtime'] }
				1039 { types == ['install_gzipped_executable'] }
				1074 { types == ['configure_glibc_runtime'] }
				1124 { types == ['configure_clang_system'] }
				else { types == ['bootstrap_cpython', 'bootstrap_pypy'] }
			}
		}
		995 {
			// The exact GCC file transformation is exercised through the source action
			// helper; this host-independent branch verifies the Linux gate and version error.
			mut runner := homebrew.new_install_steps_runner(homebrew.InstallStepsContext{}, InstallStepsSpecExecutor{})
			step := homebrew.InstallStep({
				'type': brew_runtime.string_value('configure_gcc_runtime')
			})
			mut failed := false
			homebrew.install_steps_run_formula_action(mut runner, 'configure_gcc_runtime', step) or {
				failed = true
			}
			if os.user_os() == 'linux' { failed } else { !failed }
		}
		1050 {
			mut dsl := install_steps_spec_dsl('', 'prefix', 'prefix')
			dsl = homebrew.ruby_install_steps_l759_d58_install_gzipped_executable(dsl, brew_runtime.string_value('bin/executable.gz'), brew_runtime.string_value('bin/executable'))
			step := install_steps_spec_step(dsl)
			install_steps_spec_type(dsl) == 'install_gzipped_executable' && install_steps_spec_path(step, 'source')['base'].as_string() == 'prefix'
		}
		1085 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l766_d59_configure_glibc_runtime(dsl)
			install_steps_spec_type(dsl) == 'configure_glibc_runtime'
		}
		1135 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l771_d60_configure_clang_system(dsl)
			install_steps_spec_type(dsl) == 'configure_clang_system'
		}
		1204, 1227, 1244 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l776_d61_configure_php(dsl)
			install_steps_spec_type(dsl) == 'configure_php'
		}
		1265 {
			context := install_steps_spec_context_value(root, {
				'name':    'python@3.9'
				'version': '3.9.1'
			})
			context.map_data['version'].as_string() == '3.9.1'
		}
		1323 {
			context := install_steps_spec_context_value(root, {
				'name':    'pypy3.10'
				'version': '7.3.20'
			})
			context.map_data['name'].as_string() == 'pypy3.10'
		}
		1379 {
			script := os.join_path(root, 'lib/venv/scripts/common/activate')
			directory := os.join_path(root, 'lib/venv/scripts/directory')
			install_steps_spec_write(script, 'activate') or { return false }
			os.mkdir_all(directory) or { return false }
			os.chmod(script, 0o444) or { return false }
			os.chmod(directory, 0o555) or { return false }
			homebrew.install_steps_make_cpython_venv_activation_scripts_writable(os.join_path(root, 'lib')) or { return false }
			(int(os.stat(script) or { return false }.get_mode().bitmask()) & 0o200) == 0o200 && (int(os.stat(directory) or { return false }.get_mode().bitmask()) & 0o200) == 0
		}
		1401, 1412 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l582_d46_update_gtk_icon_cache(dsl)
			path := install_steps_spec_path(install_steps_spec_step(dsl), 'path')
			install_steps_spec_type(dsl) == 'gtk_update_icon_cache' && path['base'].as_string() == 'homebrew_prefix'
		}
		1424, 1444, 1468 {
			mut dsl := install_steps_spec_dsl('', '', '')
			mut keywords := map[string]brew_runtime.Value{}
			if line != 1424 {
				keywords['fingerprint_of'] = brew_runtime.string_value(if line == 1468 {
					os.join_path(root, 'missing.pem')
				} else {
					os.join_path(root, 'ca.pem')
				})
			}
			dsl = homebrew.ruby_install_steps_l618_d50_delete_keychain_certificates(dsl, brew_runtime.string_value(if line == 1424 {
				'Charles'
			} else {
				'NodeMITMProxyCA'
			}), brew_runtime.map_value(keywords))
			step := install_steps_spec_step(dsl)
			install_steps_spec_type(dsl) == 'delete_keychain_certificate' && (line == 1424 || 'matching_certificate' in step)
		}
		1481, 1513 {
			mut dsl := install_steps_spec_dsl('staged_path', '', '')
			if line == 1481 {
				dsl = homebrew.ruby_install_steps_l632_d51_set_permissions(dsl, brew_runtime.string_array_value([
					'Prepared.app',
					'Missing.app',
				]), brew_runtime.string_value('0755'))
				dsl = homebrew.ruby_install_steps_l648_d52_set_ownership(dsl, brew_runtime.string_value('Owned.app'), brew_runtime.map_value({
					'user':  brew_runtime.string_value('root')
					'group': brew_runtime.string_value('wheel')
				}))
				return install_steps_spec_steps(dsl).map(it.map_data['type'].as_string()) == [
					'set_permissions',
					'set_ownership',
				]
			}
			dsl = homebrew.ruby_install_steps_l648_d52_set_ownership(dsl, brew_runtime.string_value('Owned.app'))
			homebrew.install_steps_sudo_required(homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)))
		}
		1530 {
			mut dsl := install_steps_spec_dsl('var', '', '')
			dsl = homebrew.ruby_install_steps_l235_d21_mkdir_p(dsl, brew_runtime.string_value('~/example'))
			path := install_steps_spec_path(install_steps_spec_step(dsl), 'path')
			'base' !in path && path['path'].as_string() == '~/example'
		}
		1543, 1556 {
			mut dsl := install_steps_spec_dsl('', 'staged_path', 'staged_path')
			if line == 1543 {
				dsl = homebrew.ruby_install_steps_l277_d25_move_children(dsl, brew_runtime.string_value('.'), brew_runtime.string_value('Nested'))
			} else {
				dsl = homebrew.ruby_install_steps_l291_d26_move_contents(dsl, brew_runtime.string_value('.'), brew_runtime.string_value('Nested'))
			}
			install_steps_spec_write(os.join_path(root, 'stage/source-file'), 'source') or { return false }
			install_steps_spec_run(root, dsl) or { return false }
			os.exists(os.join_path(root, 'stage/Nested/source-file'))
		}
		1568 {
			mut dsl := install_steps_spec_dsl('', '', 'staged_path')
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('target'), brew_runtime.string_value('protected/linked-target'), brew_runtime.map_value({
				'source_base': brew_runtime.string_value('relative')
				'sudo':        brew_runtime.object_value('Symbol', ':if_needed')
			}))
			homebrew.install_steps_sudo_required(homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)))
		}
		1590, 1603, 1615 {
			mut dsl := install_steps_spec_dsl('', '', 'staged_path')
			mut keywords := {
				'source_base': brew_runtime.string_value('relative')
				'uninstall':   brew_runtime.bool_value(true)
			}
			if line == 1590 {
				keywords['overwrite'] = brew_runtime.bool_value(true)
				keywords['remove_on_uninstall'] = brew_runtime.bool_value(true)
			}
			if line == 1615 {
				keywords['sudo'] = brew_runtime.object_value('Symbol', ':if_needed')
			}
			dsl = homebrew.ruby_install_steps_l377_d30_symlink(dsl, brew_runtime.string_value('target'), brew_runtime.string_value('linked-target'), brew_runtime.map_value(keywords))
			os.mkdir_all(os.join_path(root, 'stage')) or { return false }
			os.symlink(if line == 1603 { 'different-target' } else { 'target' }, os.join_path(root, 'stage/linked-target')) or { return false }
			if line == 1615 {
				mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), InstallStepsSpecExecutor{})
				homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'uninstall') or { return false }
				return true
			}
			mut runner := homebrew.new_install_steps_runner(install_steps_spec_context(root), homebrew.NativeInstallStepsCommandExecutor{})
			homebrew.install_steps_run(mut runner, homebrew.install_steps_from_value(homebrew.ruby_install_steps_l89_d6_steps(dsl)), 'uninstall') or { return false }
			if line == 1603 {
				os.is_link(os.join_path(root, 'stage/linked-target'))
			} else {
				!os.is_link(os.join_path(root, 'stage/linked-target'))
			}
		}
		1634 {
			// The translated DSL exposes only its declared methods; its boundary object
			// has no system/eval callback or ambient Formula/Cask receiver.
			dsl := install_steps_spec_dsl('var', '', '')
			'system' !in dsl.map_data && 'formula' !in dsl.map_data && 'cask' !in dsl.map_data
		}
		else { false }
	}
}

fn install_steps_spec_boundary(line int, kind string, args []brew_runtime.Value) brew_runtime.Value {
	if kind in ['specify', 'it'] {
		return brew_runtime.bool_value(install_steps_spec_case(line))
	}
	root := if args.len > 0 && args[0].repr != '' {
		args[0].repr
	} else {
		install_steps_spec_root(line)
	}
	return match line {
		11 { brew_runtime.object_value('Pathname', install_steps_spec_root(line)) }
		12, 1175 { install_steps_spec_context_value(root, {}) }
		15, 296, 844 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix')) }
		16, 845 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/bin')) }
		17 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/libexec')) }
		18, 846 { brew_runtime.object_value('Pathname', os.join_path(root, 'var')) }
		19 { brew_runtime.object_value('Pathname', os.join_path(root, 'stage')) }
		37 {
			name := if args.len > 0 { args[0].repr } else { 'example' }
			version := if args.len > 1 { args[1].repr } else { '1.0' }
			brew_runtime.structured_value('Formula', name, {
				'name':            name
				'version':         version
				'desc':            'API formula'
				'homepage':        'https://example.com'
				'license':         'MIT'
				'url':             'https://example.com/${name}-${version}.tar.gz'
				'loaded_from_api': 'true'
			})
		}
		59 {
			path := if args.len > 0 { args[0].repr } else { os.join_path(root, 'executable') }
			install_steps_spec_write(path, '') or { return brew_runtime.bool_value(false) }
			os.chmod(path, 0o755) or { return brew_runtime.bool_value(false) }
			brew_runtime.object_value('Pathname', path)
		}
		297, 842 {
			brew_runtime.string_value(if line == 297 { 'example' } else { 'postgresql@17' })
		}
		298 { brew_runtime.string_value('example-cask') }
		299 { brew_runtime.object_value('Version', '1.2.3') }
		327 { brew_runtime.string_value('example-formula') }
		328 { brew_runtime.string_value('example-cask') }
		651 { brew_runtime.string_array_value(['Example']) }
		652 { brew_runtime.string_value('example') }
		747 { brew_runtime.string_value('Example') }
		843 { brew_runtime.object_value('Version', '17.5') }
		1000 { brew_runtime.string_value('gcc') }
		1091 { brew_runtime.string_value('glibc') }
		1092 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/lib')) }
		1093, 1143, 1182 {
			brew_runtime.object_value('Pathname', os.join_path(root, if line == 1182 {
				'homebrew/etc'
			} else {
				'prefix/etc'
			}))
		}
		1094 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/share')) }
		1150 { brew_runtime.object_value('MacOSVersion', '14') }
		1166 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l776_d61_configure_php(dsl)
			homebrew.ruby_install_steps_l89_d6_steps(dsl)
		}
		1171 { brew_runtime.object_value('Pathname', os.join_path(root, 'homebrew')) }
		1172 {
			brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/share/php@8.4/pear'))
		}
		1173 { brew_runtime.object_value('Pathname', os.join_path(root, 'homebrew/lib/php/pecl')) }
		1174 {
			brew_runtime.object_value('Pathname', os.join_path(root, 'homebrew/etc/php/8.4/conf.d/ext-opcache.ini'))
		}
		1178 { brew_runtime.string_value('php@8.4') }
		1179 { brew_runtime.object_value('Version', '8.4.1') }
		1180 { brew_runtime.object_value('Pathname', os.join_path(root, 'prefix/share/php@8.4')) }
		1181 { brew_runtime.object_value('Pathname', os.join_path(root, 'opt/php@8.4')) }
		1185 {
			install_steps_spec_runner_value(root, {
				'name':    'php@8.4'
				'version': '8.4.1'
			})
		}
		1395 {
			mut dsl := install_steps_spec_dsl('', '', '')
			dsl = homebrew.ruby_install_steps_l582_d46_update_gtk_icon_cache(dsl)
			homebrew.ruby_install_steps_l89_d6_steps(dsl)
		}
		else {
			brew_runtime.structured_value('InstallStepsSpecFixture', kind, {
				'source_line': line.str()
			})
		}
	}
}

pub fn install_steps_spec_all_failures() []int {
	lines := [65, 81, 102, 113, 128, 142, 158, 173, 191, 250, 272, 293, 326, 338, 352, 366, 384,
		400, 418, 431, 451, 470, 484, 503, 519, 534, 547, 559, 568, 580, 595, 615, 628, 644, 660,
		675, 690, 710, 725, 739, 762, 770, 778, 791, 803, 809, 837, 896, 911, 927, 939, 974, 984,
		995, 1039, 1050, 1074, 1085, 1124, 1135, 1204, 1227, 1244, 1252, 1265, 1323, 1379, 1401,
		1412, 1424, 1444, 1468, 1481, 1513, 1530, 1543, 1556, 1568, 1590, 1603, 1615, 1634]
	mut failures := []int{}
	for line in lines {
		if !install_steps_spec_case(line) {
			failures << line
		}
	}
	return failures
}

// Translated from Homebrew/brew `test/install_steps_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:root) { Pathname(TEST_TMPDIR)/"install-steps" }` at line 11.
pub fn ruby_install_steps_spec_l11_d1_root(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(11, 'let', args)
}

// Ruby let `let(:context) do` at line 12.
pub fn ruby_install_steps_spec_l12_d2_context(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(12, 'let', args)
}

// Ruby define_method `define_method(:prefix) { root_path/"prefix" }` at line 15.
pub fn ruby_install_steps_spec_l15_d3_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(15, 'define_method', args)
}

// Ruby define_method `define_method(:bin) { root_path/"prefix/bin" }` at line 16.
pub fn ruby_install_steps_spec_l16_d4_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(16, 'define_method', args)
}

// Ruby define_method `define_method(:libexec) { root_path/"prefix/libexec" }` at line 17.
pub fn ruby_install_steps_spec_l17_d5_libexec(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(17, 'define_method', args)
}

// Ruby define_method `define_method(:var) { root_path/"var" }` at line 18.
pub fn ruby_install_steps_spec_l18_d6_var(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(18, 'define_method', args)
}

// Ruby define_method `define_method(:staged_path) { root_path/"stage" }` at line 19.
pub fn ruby_install_steps_spec_l19_d7_staged_path(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(19, 'define_method', args)
}

// Ruby method `api_formula(name, version)` at line 37.
pub fn ruby_install_steps_spec_l37_d8_api_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(37, 'method', args)
}

// Ruby method `create_executable(path)` at line 59.
pub fn ruby_install_steps_spec_l59_d9_create_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(59, 'method', args)
}

// Ruby specify `specify "changes the resolved dylib ID and restores its mode" do` at line 65.
pub fn ruby_install_steps_spec_l65_d10_changes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(65, 'specify', args)
}

// Ruby specify `specify "runs directory, touch, move and symlink steps", :aggregate_failures do` at line 81.
pub fn ruby_install_steps_spec_l81_d11_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(81, 'specify', args)
}

// Ruby specify `specify "allows directory creation through parent sandbox paths" do` at line 102.
pub fn ruby_install_steps_spec_l102_d12_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(102, 'specify', args)
}

// Ruby specify `specify "resolves formula configuration paths without loading formula source" do` at line 113.
pub fn ruby_install_steps_spec_l113_d13_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(113, 'specify', args)
}

// Ruby specify `specify "changes an explicit Mach-O dylib ID" do` at line 128.
pub fn ruby_install_steps_spec_l128_d14_changes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(128, 'specify', args)
}

// Ruby specify `specify "links every source matched by a glob into a directory", :aggregate_failures do` at line 142.
pub fn ruby_install_steps_spec_l142_d15_links(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(142, 'specify', args)
}

// Ruby specify `specify "runs mkdir without creating parent directories" do` at line 158.
pub fn ruby_install_steps_spec_l158_d16_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(158, 'specify', args)
}

// Ruby specify `specify "runs mkdir_p recursively" do` at line 173.
pub fn ruby_install_steps_spec_l173_d17_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(173, 'specify', args)
}

// Ruby specify `specify "normalises API step keys and values" do` at line 191.
pub fn ruby_install_steps_spec_l191_d18_normalises(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(191, 'specify', args)
}

// Ruby specify `specify "keeps canonical DSL calls compatible with shipped API values", :aggregate_failures do` at line 250.
pub fn ruby_install_steps_spec_l250_d19_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(250, 'specify', args)
}

// Ruby specify `specify "keeps shipped step names serialisable for compatibility" do` at line 272.
pub fn ruby_install_steps_spec_l272_d20_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(272, 'specify', args)
}

// Ruby specify `specify "expands a scoped set of content tokens and leaves others verbatim", :aggregate_failures do` at line 293.
pub fn ruby_install_steps_spec_l293_d21_expands(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(293, 'specify', args)
}

// Ruby define_method `define_method(:prefix) { root_path/"prefix" }` at line 296.
pub fn ruby_install_steps_spec_l296_d22_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(296, 'define_method', args)
}

// Ruby define_method `define_method(:name) { "example" }` at line 297.
pub fn ruby_install_steps_spec_l297_d23_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(297, 'define_method', args)
}

// Ruby define_method `define_method(:token) { "example-cask" }` at line 298.
pub fn ruby_install_steps_spec_l298_d24_token(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(298, 'define_method', args)
}

// Ruby define_method `define_method(:version) { Version.new("1.2.3") }` at line 299.
pub fn ruby_install_steps_spec_l299_d25_version(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(299, 'define_method', args)
}

// Ruby specify `specify "expands formula and cask identity tokens" do` at line 326.
pub fn ruby_install_steps_spec_l326_d26_expands(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(326, 'specify', args)
}

// Ruby define_singleton_method `context.define_singleton_method(:name) { "example-formula" }` at line 327.
pub fn ruby_install_steps_spec_l327_d27_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(327, 'define_singleton_method', args)
}

// Ruby define_singleton_method `context.define_singleton_method(:token) { "example-cask" }` at line 328.
pub fn ruby_install_steps_spec_l328_d28_token(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(328, 'define_singleton_method', args)
}

// Ruby specify `specify "writes exact content and replaces existing files" do` at line 338.
pub fn ruby_install_steps_spec_l338_d29_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(338, 'specify', args)
}

// Ruby specify `specify "can append a newline without replacing existing files" do` at line 352.
pub fn ruby_install_steps_spec_l352_d30_can(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(352, 'specify', args)
}

// Ruby specify `specify "preserves meaningful blank values" do` at line 366.
pub fn ruby_install_steps_spec_l366_d31_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(366, 'specify', args)
}

// Ruby specify `specify "omits install step runtime defaults" do` at line 384.
pub fn ruby_install_steps_spec_l384_d32_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(384, 'specify', args)
}

// Ruby specify `specify "writes a default config file and preserves existing ones", :aggregate_failures do` at line 400.
pub fn ruby_install_steps_spec_l400_d33_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(400, 'specify', args)
}

// Ruby specify `specify "snapshots conditions shared by a scope" do` at line 418.
pub fn ruby_install_steps_spec_l418_d34_snapshots(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(418, 'specify', args)
}

// Ruby specify `specify "keeps guard snapshots separate between concatenated step lists" do` at line 431.
pub fn ruby_install_steps_spec_l431_d35_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(431, 'specify', args)
}

// Ruby specify `specify "runs only steps matching the simulated platform" do` at line 451.
pub fn ruby_install_steps_spec_l451_d36_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(451, 'specify', args)
}

// Ruby specify `specify "copies paths" do` at line 470.
pub fn ruby_install_steps_spec_l470_d37_copies(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(470, 'specify', args)
}

// Ruby specify `specify "replaces copied paths by default and can reject replacement" do` at line 484.
pub fn ruby_install_steps_spec_l484_d38_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(484, 'specify', args)
}

// Ruby specify `specify "replaces symlink destinations when copying files" do` at line 503.
pub fn ruby_install_steps_spec_l503_d39_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(503, 'specify', args)
}

// Ruby specify `specify "preserves the legacy move replacement behaviour" do` at line 519.
pub fn ruby_install_steps_spec_l519_d40_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(519, 'specify', args)
}

// Ruby specify `specify "preserves a default move destination when repeated", :aggregate_failures do` at line 534.
pub fn ruby_install_steps_spec_l534_d41_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(534, 'specify', args)
}

// Ruby specify `specify "requires one match for single-source globs" do` at line 547.
pub fn ruby_install_steps_spec_l547_d42_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(547, 'specify', args)
}

// Ruby specify `specify "requires a match for literal glob sources" do` at line 559.
pub fn ruby_install_steps_spec_l559_d43_requires(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(559, 'specify', args)
}

// Ruby specify `specify "deduplicates overlapping move source globs" do` at line 568.
pub fn ruby_install_steps_spec_l568_d44_deduplicates(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(568, 'specify', args)
}

// Ruby specify `specify "removes paths and expands globs", :aggregate_failures do` at line 580.
pub fn ruby_install_steps_spec_l580_d45_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(580, 'specify', args)
}

// Ruby specify `specify "filters removals and accepts the legacy path base", :aggregate_failures do` at line 595.
pub fn ruby_install_steps_spec_l595_d46_filters(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(595, 'specify', args)
}

// Ruby specify `specify "uses elevated cask removal when requested" do` at line 615.
pub fn ruby_install_steps_spec_l615_d47_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(615, 'specify', args)
}

// Ruby specify `specify "replaces literal and regular expression matches", :aggregate_failures do` at line 628.
pub fn ruby_install_steps_spec_l628_d48_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(628, 'specify', args)
}

// Ruby specify `specify "warns inside a matching path scope" do` at line 644.
pub fn ruby_install_steps_spec_l644_d49_warns(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(644, 'specify', args)
}

// Ruby define_singleton_method `named_context.define_singleton_method(:name) { ["Example"] }` at line 651.
pub fn ruby_install_steps_spec_l651_d50_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(651, 'define_singleton_method', args)
}

// Ruby define_singleton_method `named_context.define_singleton_method(:token) { "example" }` at line 652.
pub fn ruby_install_steps_spec_l652_d51_token(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(652, 'define_singleton_method', args)
}

// Ruby specify `specify "runs serialised commands" do` at line 660.
pub fn ruby_install_steps_spec_l660_d52_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(660, 'specify', args)
}

// Ruby specify `specify "serialises command environments as JSON objects" do` at line 675.
pub fn ruby_install_steps_spec_l675_d53_serialises(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(675, 'specify', args)
}

// Ruby specify `specify "runs commands with serialised input and output paths" do` at line 690.
pub fn ruby_install_steps_spec_l690_d54_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(690, 'specify', args)
}

// Ruby specify `specify "allows a run step to fail when it must not succeed" do` at line 710.
pub fn ruby_install_steps_spec_l710_d55_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(710, 'specify', args)
}

// Ruby specify `specify "does not write an output path when an ignored run step fails" do` at line 725.
pub fn ruby_install_steps_spec_l725_d56_does(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(725, 'specify', args)
}

// Ruby specify `specify "can ignore process termination failure after retries" do` at line 739.
pub fn ruby_install_steps_spec_l739_d57_can(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(739, 'specify', args)
}

// Ruby define_singleton_method `named_context.define_singleton_method(:name) { "Example" }` at line 747.
pub fn ruby_install_steps_spec_l747_d58_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(747, 'define_singleton_method', args)
}

// Ruby specify `specify "rejects unknown process match modes" do` at line 762.
pub fn ruby_install_steps_spec_l762_d59_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(762, 'specify', args)
}

// Ruby specify `specify "rejects non-positive process termination attempts" do` at line 770.
pub fn ruby_install_steps_spec_l770_d60_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(770, 'specify', args)
}

// Ruby specify `specify "uses killall for exact process names" do` at line 778.
pub fn ruby_install_steps_spec_l778_d61_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(778, 'specify', args)
}

// Ruby specify `specify "appends a trailing newline unless already present", :aggregate_failures do` at line 791.
pub fn ruby_install_steps_spec_l791_d62_appends(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(791, 'specify', args)
}

// Ruby specify `specify "raises when a write step has missing content" do` at line 803.
pub fn ruby_install_steps_spec_l803_d63_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(803, 'specify', args)
}

// Ruby specify `specify "runs service data directory initialisers", :aggregate_failures do` at line 809.
pub fn ruby_install_steps_spec_l809_d64_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(809, 'specify', args)
}

// Ruby specify `specify "links remapped directories and children before running initdb", :aggregate_failures do` at line 837.
pub fn ruby_install_steps_spec_l837_d65_links(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(837, 'specify', args)
}

// Ruby define_method `define_method(:name) { "postgresql@17" }` at line 842.
pub fn ruby_install_steps_spec_l842_d66_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(842, 'define_method', args)
}

// Ruby define_method `define_method(:version) { Version.new("17.5") }` at line 843.
pub fn ruby_install_steps_spec_l843_d67_version(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(843, 'define_method', args)
}

// Ruby define_method `define_method(:prefix) { root_path/"prefix" }` at line 844.
pub fn ruby_install_steps_spec_l844_d68_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(844, 'define_method', args)
}

// Ruby define_method `define_method(:bin) { root_path/"prefix/bin" }` at line 845.
pub fn ruby_install_steps_spec_l845_d69_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(845, 'define_method', args)
}

// Ruby define_method `define_method(:var) { root_path/"var" }` at line 846.
pub fn ruby_install_steps_spec_l846_d70_var(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(846, 'define_method', args)
}

// Ruby specify `specify "skips data directory initialisers in CI", :aggregate_failures do` at line 896.
pub fn ruby_install_steps_spec_l896_d71_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(896, 'specify', args)
}

// Ruby specify `specify "skips data directory initialisers when their marker exists", :aggregate_failures do` at line 911.
pub fn ruby_install_steps_spec_l911_d72_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(911, 'specify', args)
}

// Ruby specify `specify "raises on unknown data directory initialisers" do` at line 927.
pub fn ruby_install_steps_spec_l927_d73_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(927, 'specify', args)
}

// Ruby specify `specify "runs named desktop and cache rebuild actions" do` at line 939.
pub fn ruby_install_steps_spec_l939_d74_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(939, 'specify', args)
}

// Ruby specify `specify "reports missing formula helper executables" do` at line 974.
pub fn ruby_install_steps_spec_l974_d75_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(974, 'specify', args)
}

// Ruby specify `specify "dispatches GCC runtime configuration" do` at line 984.
pub fn ruby_install_steps_spec_l984_d76_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(984, 'specify', args)
}

// Ruby specify `specify "configures GCC runtime files on Linux", :aggregate_failures do` at line 995.
pub fn ruby_install_steps_spec_l995_d77_configures(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(995, 'specify', args)
}

// Ruby define_singleton_method `gcc_context.define_singleton_method(:name) { "gcc" }` at line 1000.
pub fn ruby_install_steps_spec_l1000_d78_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1000, 'define_singleton_method', args)
}

// Ruby specify `specify "dispatches gzipped executable installation" do` at line 1039.
pub fn ruby_install_steps_spec_l1039_d79_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1039, 'specify', args)
}

// Ruby specify `specify "installs a gzipped executable with a fixed mode", :aggregate_failures do` at line 1050.
pub fn ruby_install_steps_spec_l1050_d80_installs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1050, 'specify', args)
}

// Ruby specify `specify "dispatches glibc runtime configuration" do` at line 1074.
pub fn ruby_install_steps_spec_l1074_d81_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1074, 'specify', args)
}

// Ruby specify `specify "configures glibc locales and timezone links", :aggregate_failures do` at line 1085.
pub fn ruby_install_steps_spec_l1085_d82_configures(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1085, 'specify', args)
}

// Ruby define_singleton_method `glibc_context.define_singleton_method(:name) { "glibc" }` at line 1091.
pub fn ruby_install_steps_spec_l1091_d83_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1091, 'define_singleton_method', args)
}

// Ruby define_singleton_method `glibc_context.define_singleton_method(:lib) { root_path/"prefix/lib" }` at line 1092.
pub fn ruby_install_steps_spec_l1092_d84_lib(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1092, 'define_singleton_method', args)
}

// Ruby define_singleton_method `glibc_context.define_singleton_method(:etc) { root_path/"prefix/etc" }` at line 1093.
pub fn ruby_install_steps_spec_l1093_d85_etc(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1093, 'define_singleton_method', args)
}

// Ruby define_singleton_method `glibc_context.define_singleton_method(:share) { root_path/"prefix/share" }` at line 1094.
pub fn ruby_install_steps_spec_l1094_d86_share(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1094, 'define_singleton_method', args)
}

// Ruby specify `specify "dispatches Clang system configuration" do` at line 1124.
pub fn ruby_install_steps_spec_l1124_d87_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1124, 'specify', args)
}

// Ruby specify `specify "repairs incomplete Clang system configuration" do` at line 1135.
pub fn ruby_install_steps_spec_l1135_d88_repairs(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1135, 'specify', args)
}

// Ruby define_singleton_method `clang_context.define_singleton_method(:etc) { root_path/"prefix/etc" }` at line 1143.
pub fn ruby_install_steps_spec_l1143_d89_etc(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1143, 'define_singleton_method', args)
}

// Ruby define_singleton_method `define_singleton_method(:version) { macos_version }` at line 1150.
pub fn ruby_install_steps_spec_l1150_d90_version(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1150, 'define_singleton_method', args)
}

// Ruby let `let(:steps) do` at line 1166.
pub fn ruby_install_steps_spec_l1166_d91_steps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1166, 'let', args)
}

// Ruby let `let(:homebrew_prefix) { root/"homebrew" }` at line 1171.
pub fn ruby_install_steps_spec_l1171_d92_homebrew_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1171, 'let', args)
}

// Ruby let `let(:pear_prefix) { root/"prefix/share/php@8.4/pear" }` at line 1172.
pub fn ruby_install_steps_spec_l1172_d93_pear_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1172, 'let', args)
}

// Ruby let `let(:pecl_path) { homebrew_prefix/"lib/php/pecl" }` at line 1173.
pub fn ruby_install_steps_spec_l1173_d94_pecl_path(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1173, 'let', args)
}

// Ruby let `let(:ext_config_path) { homebrew_prefix/"etc/php/8.4/conf.d/ext-opcache.ini" }` at line 1174.
pub fn ruby_install_steps_spec_l1174_d95_ext_config_path(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1174, 'let', args)
}

// Ruby let `let(:php_context) do` at line 1175.
pub fn ruby_install_steps_spec_l1175_d96_php_context(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1175, 'let', args)
}

// Ruby define_singleton_method `value.define_singleton_method(:name) { "php@8.4" }` at line 1178.
pub fn ruby_install_steps_spec_l1178_d97_name(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1178, 'define_singleton_method', args)
}

// Ruby define_singleton_method `value.define_singleton_method(:version) { Version.new("8.4.1") }` at line 1179.
pub fn ruby_install_steps_spec_l1179_d98_version(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1179, 'define_singleton_method', args)
}

// Ruby define_singleton_method `value.define_singleton_method(:pkgshare) { root_path/"prefix/share/php@8.4" }` at line 1180.
pub fn ruby_install_steps_spec_l1180_d99_pkgshare(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1180, 'define_singleton_method', args)
}

// Ruby define_singleton_method `value.define_singleton_method(:opt_prefix) { root_path/"opt/php@8.4" }` at line 1181.
pub fn ruby_install_steps_spec_l1181_d100_opt_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1181, 'define_singleton_method', args)
}

// Ruby define_singleton_method `value.define_singleton_method(:etc) { root_path/"homebrew/etc" }` at line 1182.
pub fn ruby_install_steps_spec_l1182_d101_etc(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1182, 'define_singleton_method', args)
}

// Ruby let `let(:runner) { Homebrew::InstallSteps::Runner.new(context: php_context) }` at line 1185.
pub fn ruby_install_steps_spec_l1185_d102_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1185, 'let', args)
}

// Ruby specify `specify "updates PEAR, PECL and opcache configuration", :aggregate_failures do` at line 1204.
pub fn ruby_install_steps_spec_l1204_d103_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1204, 'specify', args)
}

// Ruby specify `specify "only replaces the active opcache extension setting" do` at line 1227.
pub fn ruby_install_steps_spec_l1227_d104_only(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1227, 'specify', args)
}

// Ruby specify `specify "audits existing opcache extension settings" do` at line 1244.
pub fn ruby_install_steps_spec_l1244_d105_audits(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1244, 'specify', args)
}

// Ruby specify `specify "dispatches CPython and PyPy bootstrap" do` at line 1252.
pub fn ruby_install_steps_spec_l1252_d106_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1252, 'specify', args)
}

// Ruby specify `specify "bootstraps CPython 3.9 configuration", :aggregate_failures do` at line 1265.
pub fn ruby_install_steps_spec_l1265_d107_bootstraps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1265, 'specify', args)
}

// Ruby specify `specify "bootstraps PyPy 3.10 configuration", :aggregate_failures do` at line 1323.
pub fn ruby_install_steps_spec_l1323_d108_bootstraps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1323, 'specify', args)
}

// Ruby specify `specify "makes CPython venv activation script templates writable", :aggregate_failures do` at line 1379.
pub fn ruby_install_steps_spec_l1379_d109_makes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1379, 'specify', args)
}

// Ruby let `let(:steps) do` at line 1395.
pub fn ruby_install_steps_spec_l1395_d110_steps(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1395, 'let', args)
}

// Ruby it `it "with gtk4" do` at line 1401.
pub fn ruby_install_steps_spec_l1401_d111_with(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1401, 'it', args)
}

// Ruby it `it "with gtk+3" do` at line 1412.
pub fn ruby_install_steps_spec_l1412_d112_with(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1412, 'it', args)
}

// Ruby specify `specify "deletes matching keychain certificates by SHA-256 hash" do` at line 1424.
pub fn ruby_install_steps_spec_l1424_d113_deletes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1424, 'specify', args)
}

// Ruby specify `specify "only deletes the keychain certificate matching a local certificate" do` at line 1444.
pub fn ruby_install_steps_spec_l1444_d114_only(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1444, 'specify', args)
}

// Ruby specify `specify "skips keychain certificate deletion when a local certificate is missing" do` at line 1468.
pub fn ruby_install_steps_spec_l1468_d115_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1468, 'specify', args)
}

// Ruby specify `specify "sets permissions and ownership for existing cask step paths" do` at line 1481.
pub fn ruby_install_steps_spec_l1481_d116_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1481, 'specify', args)
}

// Ruby specify `specify "raises when App Management permissions are missing for ownership steps" do` at line 1513.
pub fn ruby_install_steps_spec_l1513_d117_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1513, 'specify', args)
}

// Ruby specify `specify "does not add the default base to home paths" do` at line 1530.
pub fn ruby_install_steps_spec_l1530_d118_does(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1530, 'specify', args)
}

// Ruby specify `specify "moves a directory's children without moving the new target directory" do` at line 1543.
pub fn ruby_install_steps_spec_l1543_d119_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1543, 'specify', args)
}

// Ruby specify `specify "moves a directory's contents" do` at line 1556.
pub fn ruby_install_steps_spec_l1556_d120_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1556, 'specify', args)
}

// Ruby specify `specify "uses sudo only when an if-needed symlink target is not writable" do` at line 1568.
pub fn ruby_install_steps_spec_l1568_d121_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1568, 'specify', args)
}

// Ruby specify `specify "removes symlinks marked for uninstall" do` at line 1590.
pub fn ruby_install_steps_spec_l1590_d122_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1590, 'specify', args)
}

// Ruby specify `specify "preserves symlinks with unexpected targets on uninstall" do` at line 1603.
pub fn ruby_install_steps_spec_l1603_d123_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1603, 'specify', args)
}

// Ruby specify `specify "uses elevated removal for matching symlinks when needed" do` at line 1615.
pub fn ruby_install_steps_spec_l1615_d124_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1615, 'specify', args)
}

// Ruby specify `specify "does not expose the surrounding formula or cask DSL" do` at line 1634.
pub fn ruby_install_steps_spec_l1634_d125_does(args ...brew_runtime.Value) brew_runtime.Value {
	return install_steps_spec_boundary(1634, 'specify', args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "install_steps"
// 5: require "api/formula_struct"
// 6: require "cask/quarantine"
// 7: require "formulary"
// 8: require "macho"
// 9:
// 10: RSpec.describe Homebrew::InstallSteps do
// 11:   let(:root) { Pathname(TEST_TMPDIR)/"install-steps" }
// 12:   let(:context) do
// 13:     root_path = root
// 14:     Class.new do
// 15:       define_method(:prefix) { root_path/"prefix" }
// 16:       define_method(:bin) { root_path/"prefix/bin" }
// 17:       define_method(:libexec) { root_path/"prefix/libexec" }
// 18:       define_method(:var) { root_path/"var" }
// 19:       define_method(:staged_path) { root_path/"stage" }
// 20:     end.new
// 21:   end
// 22:
// 23:   before do
// 24:     FileUtils.rm_rf root
// 25:   end
// 26:
// 27:   after do
// 28:     FileUtils.rm_rf root
// 29:   end
// 30:
// 31:   around do |example|
// 32:     with_env(HOMEBREW_GITHUB_ACTIONS: nil) do
// 33:       example.run
// 34:     end
// 35:   end
// 36:
// 37:   def api_formula(name, version)
// 38:     formula_struct = Homebrew::API::FormulaStruct.from_hash({
// 39:       "desc"                 => "API formula",
// 40:       "homepage"             => "https://example.com",
// 41:       "license"              => "MIT",
// 42:       "ruby_source_checksum" => "checksum",
// 43:       "stable_present"       => true,
// 44:       "stable_url_args"      => ["https://example.com/#{name}-#{version}.tar.gz", {}],
// 45:       "stable_version"       => version,
// 46:     })
// 47:     api_source = formula_struct.serialize
// 48:     formula_class = Formulary.load_formula_from_struct!(
// 49:       name,
// 50:       Homebrew::API::FormulaStruct.deserialize(api_source),
// 51:       api_source:,
// 52:       tap_git_head: "",
// 53:       flags:        [],
// 54:       internal_api: true,
// 55:     )
// 56:     formula_class.new(name, root/"#{name}.rb", :stable)
// 57:   end
// 58:
// 59:   def create_executable(path)
// 60:     path.dirname.mkpath
// 61:     path.write ""
// 62:     path.chmod 0755
// 63:   end
// 64:
// 65:   specify "changes the resolved dylib ID and restores its mode" do
// 66:     dylib = root/"lib/libfoo.1.dylib"
// 67:     source = root/"lib/libfoo.dylib"
// 68:     dylib.dirname.mkpath
// 69:     dylib.write "Mach-O"
// 70:     dylib.chmod 0444
// 71:     FileUtils.ln_s dylib, source
// 72:     allow(Hardware::CPU).to receive(:arm?).and_return(true)
// 73:     expect(MachO::Tools).to receive(:change_dylib_id).with(dylib, "@rpath/libfoo.1.dylib")
// 74:     expect(MachO).to receive(:codesign!).with(dylib)
// 75:
// 76:     described_class.change_dylib_id source, "@rpath/libfoo.1.dylib", resolve_source: true
// 77:
// 78:     expect(dylib.stat.mode & 0777).to eq(0444)
// 79:   end
// 80:
// 81:   specify "runs directory, touch, move and symlink steps", :aggregate_failures do
// 82:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var, default_source_base: :staged_path,
// 83:                                               default_target_base: :staged_path) do
// 84:       mkdir_p "log/example"
// 85:       touch "state/marker", base: :prefix
// 86:       move "move-source", "move-target"
// 87:       symlink "move-target", "linked-target", source_base: :relative
// 88:     end
// 89:
// 90:     (root/"stage").mkpath
// 91:     (root/"stage/move-source").write "moved"
// 92:
// 93:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 94:
// 95:     expect(root/"var/log/example").to be_a_directory
// 96:     expect(root/"prefix/state/marker").to exist
// 97:     expect(root/"stage/move-target").to exist
// 98:     expect(root/"stage/linked-target").to be_a_symlink
// 99:     expect((root/"stage/linked-target").readlink).to eq(Pathname("move-target"))
// 100:   end
// 101:
// 102:   specify "allows directory creation through parent sandbox paths" do
// 103:     steps = Homebrew::InstallSteps::DSL.build(default_base: :prefix) do
// 104:       mkdir "one"
// 105:       mkdir_p "two/three"
// 106:     end
// 107:
// 108:     paths = Homebrew::InstallSteps::Runner.new(context:).sandbox_write_paths(steps)
// 109:
// 110:     expect(paths).to contain_exactly(root/"prefix", root/"prefix/two")
// 111:   end
// 112:
// 113:   specify "resolves formula configuration paths without loading formula source" do
// 114:     stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 115:     source = HOMEBREW_PREFIX/"etc/test-source/cert.pem"
// 116:     source.dirname.mkpath
// 117:     source.write "certificate"
// 118:     steps = Homebrew::InstallSteps::DSL.build(default_target_base: :prefix) do
// 119:       symlink "cert.pem", "cert.pem", source_base:    :formula_pkgetc,
// 120:                                       source_formula: "example/tap/test-source"
// 121:     end
// 122:
// 123:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 124:
// 125:     expect(root/"prefix/cert.pem").to be_a_symlink
// 126:   end
// 127:
// 128:   specify "changes an explicit Mach-O dylib ID" do
// 129:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :prefix) do
// 130:       on_macos do
// 131:         change_dylib_id "lib/libfoo.dylib", "{{HOMEBREW_PREFIX}}/opt/foo/lib/libfoo.1.dylib",
// 132:                         resolve_source: true
// 133:       end
// 134:     end
// 135:     allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_macos?).and_return(true)
// 136:     expect(described_class).to receive(:change_dylib_id)
// 137:       .with(root/"prefix/lib/libfoo.dylib", "#{HOMEBREW_PREFIX}/opt/foo/lib/libfoo.1.dylib", resolve_source: true)
// 138:
// 139:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 140:   end
// 141:
// 142:   specify "links every source matched by a glob into a directory", :aggregate_failures do
// 143:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :prefix,
// 144:                                               default_target_base: :prefix) do
// 145:       symlink "share/man/*.1", "share/man/man1", source_glob: true, overwrite: true
// 146:     end
// 147:
// 148:     (root/"prefix/share/man/man1").mkpath
// 149:     (root/"prefix/share/man/tool.1").write "tool"
// 150:     (root/"prefix/share/man/other.1").write "other"
// 151:
// 152:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 153:
// 154:     expect(root/"prefix/share/man/man1/tool.1").to be_a_symlink
// 155:     expect(root/"prefix/share/man/man1/other.1").to be_a_symlink
// 156:   end
// 157:
// 158:   specify "runs mkdir without creating parent directories" do
// 159:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 160:       mkdir "missing-parent/example"
// 161:     end
// 162:
// 163:     expect(steps).to include(
// 164:       "type" => "mkdir",
// 165:       "path" => {
// 166:         "base" => "var",
// 167:         "path" => "missing-parent/example",
// 168:       },
// 169:     )
// 170:     expect { Homebrew::InstallSteps::Runner.new(context:).run(steps) }.to raise_error(Errno::ENOENT)
// 171:   end
// 172:
// 173:   specify "runs mkdir_p recursively" do
// 174:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 175:       mkdir_p "nested/example"
// 176:     end
// 177:
// 178:     expect(steps).to include(
// 179:       "type" => "mkdir_p",
// 180:       "path" => {
// 181:         "base" => "var",
// 182:         "path" => "nested/example",
// 183:       },
// 184:     )
// 185:
// 186:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 187:
// 188:     expect(root/"var/nested/example").to be_a_directory
// 189:   end
// 190:
// 191:   specify "normalises API step keys and values" do
// 192:     steps = [
// 193:       {
// 194:         type: :mkdir_p,
// 195:         path: {
// 196:           base: :var,
// 197:           path: "nested/example",
// 198:         },
// 199:       },
// 200:       {
// 201:         type:                 :delete_keychain_certificate,
// 202:         name:                 "NodeMITMProxyCA",
// 203:         matching_certificate: "~/Library/Application Support/betwixt/ssl/certs/ca.pem",
// 204:       },
// 205:       {
// 206:         type:        :set_permissions,
// 207:         paths:       ["Example.app"],
// 208:         permissions: "0755",
// 209:       },
// 210:       {
// 211:         type:  :set_ownership,
// 212:         paths: [{ base: :staged_path, path: "Example.app" }],
// 213:         user:  :root,
// 214:         group: :wheel,
// 215:       },
// 216:     ]
// 217:
// 218:     expect(Homebrew::InstallSteps::DSL.normalise_steps(steps)).to contain_exactly(
// 219:       {
// 220:         "type" => "mkdir_p",
// 221:         "path" => {
// 222:           "base" => "var",
// 223:           "path" => "nested/example",
// 224:         },
// 225:       },
// 226:       {
// 227:         "type"                 => "delete_keychain_certificate",
// 228:         "name"                 => "NodeMITMProxyCA",
// 229:         "matching_certificate" => {
// 230:           "path" => "~/Library/Application Support/betwixt/ssl/certs/ca.pem",
// 231:         },
// 232:       },
// 233:       {
// 234:         "type"        => "set_permissions",
// 235:         "paths"       => [{ "path" => "Example.app" }],
// 236:         "permissions" => "0755",
// 237:       },
// 238:       {
// 239:         "type"  => "set_ownership",
// 240:         "paths" => [{
// 241:           "base" => "staged_path",
// 242:           "path" => "Example.app",
// 243:         }],
// 244:         "user"  => "root",
// 245:         "group" => "wheel",
// 246:       },
// 247:     )
// 248:   end
// 249:
// 250:   specify "keeps canonical DSL calls compatible with shipped API values", :aggregate_failures do
// 251:     steps = Homebrew::InstallSteps::DSL.build do
// 252:       symlink_tree "source", "target"
// 253:       symlink_children "source", "target"
// 254:       write_file "config", "content"
// 255:       update_gdk_pixbuf_loaders_cache
// 256:       update_gtk_icon_cache
// 257:       delete_keychain_certificates "Example", fingerprint_of: "certificate"
// 258:       symlink "source", "target", overwrite: true, remove_on_uninstall: true
// 259:       init_data_dir "data", using: :postgresql
// 260:     end
// 261:
// 262:     expect(steps.map { |step| step.fetch("type") }).to eq(
// 263:       %w[link_dir link_children write gdk_pixbuf_query_loaders gtk_update_icon_cache
// 264:          delete_keychain_certificate symlink init_data_dir],
// 265:     )
// 266:     expect(steps.fetch(2)).to include("content" => "content", "overwrite" => true)
// 267:     expect(steps.fetch(5)).to include("matching_certificate" => { "path" => "certificate" })
// 268:     expect(steps.fetch(6)).to include("force" => true, "uninstall" => true)
// 269:     expect(steps.fetch(7)).to include("using" => "postgresql_initdb")
// 270:   end
// 271:
// 272:   specify "keeps shipped step names serialisable for compatibility" do
// 273:     steps = Homebrew::InstallSteps::DSL.build do
// 274:       mkdir "directory"
// 275:       mv "source", "target"
// 276:       move_children "source", "target"
// 277:       ln_sf "source", "target"
// 278:       link_dir "source", "target"
// 279:       link_children "source", "target"
// 280:       write "config", "content"
// 281:       gio_querymodules
// 282:       gdk_pixbuf_query_loaders
// 283:       gtk_update_icon_cache
// 284:       delete_keychain_certificate "Example"
// 285:     end
// 286:
// 287:     expect(steps.map { |step| step.fetch("type") }).to eq(%w[
// 288:       mkdir move move_children symlink link_dir link_children write gio_querymodules
// 289:       gdk_pixbuf_query_loaders gtk_update_icon_cache delete_keychain_certificate
// 290:     ])
// 291:   end
// 292:
// 293:   specify "expands a scoped set of content tokens and leaves others verbatim", :aggregate_failures do
// 294:     root_path = root
// 295:     versioned_context = Class.new do
// 296:       define_method(:prefix) { root_path/"prefix" }
// 297:       define_method(:name) { "example" }
// 298:       define_method(:token) { "example-cask" }
// 299:       define_method(:version) { Version.new("1.2.3") }
// 300:     end.new
// 301:
// 302:     steps = Homebrew::InstallSteps::DSL.build(default_base: :prefix) do
// 303:       write_file "config.ini", <<~EOS
// 304:         prefix = {{prefix}}
// 305:         cellar = {{HOMEBREW_PREFIX}}
// 306:         legacy = {{name}}
// 307:         formula = {{formula_name}}
// 308:         cask = {{token}}
// 309:         series = {{version.major_minor}} ({{version}})
// 310:         literal = {{unknown}} {single}
// 311:       EOS
// 312:     end
// 313:
// 314:     Homebrew::InstallSteps::Runner.new(context: versioned_context).run(steps)
// 315:
// 316:     written = (root/"prefix/config.ini").read
// 317:     expect(written).to include("prefix = #{root}/prefix")
// 318:     expect(written).to include("cellar = #{HOMEBREW_PREFIX}")
// 319:     expect(written).to include("legacy = example")
// 320:     expect(written).to include("formula = example")
// 321:     expect(written).to include("cask = example-cask")
// 322:     expect(written).to include("series = 1.2 (1.2.3)")
// 323:     expect(written).to include("literal = {{unknown}} {single}")
// 324:   end
// 325:
// 326:   specify "expands formula and cask identity tokens" do
// 327:     context.define_singleton_method(:name) { "example-formula" }
// 328:     context.define_singleton_method(:token) { "example-cask" }
// 329:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 330:       write "identity", "#{formula_name}:#{token}"
// 331:     end
// 332:
// 333:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 334:
// 335:     expect((root/"var/identity").read).to eq("example-formula:example-cask\n")
// 336:   end
// 337:
// 338:   specify "writes exact content and replaces existing files" do
// 339:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 340:       write_file "config/example.conf", "replacement"
// 341:       write_file "empty", ""
// 342:     end
// 343:
// 344:     (root/"var/config").mkpath
// 345:     (root/"var/config/example.conf").write "old\n"
// 346:
// 347:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 348:
// 349:     expect([(root/"var/config/example.conf").read, (root/"var/empty").read]).to eq(["replacement", ""])
// 350:   end
// 351:
// 352:   specify "can append a newline without replacing existing files" do
// 353:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 354:       write_file "existing", "replacement", overwrite: false, append_newline: true
// 355:       write_file "missing", "new", overwrite: false, append_newline: true
// 356:     end
// 357:
// 358:     (root/"var").mkpath
// 359:     (root/"var/existing").write "original\n"
// 360:
// 361:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 362:
// 363:     expect([(root/"var/existing").read, (root/"var/missing").read]).to eq(["original\n", "new\n"])
// 364:   end
// 365:
// 366:   specify "preserves meaningful blank values" do
// 367:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 368:       inreplace "remove.txt", "remove", ""
// 369:       run "helper", args: [""], env: { "EMPTY" => "" }
// 370:     end
// 371:
// 372:     (root/"var").mkpath
// 373:     (root/"var/remove.txt").write "remove"
// 374:     command = class_double(SystemCommand)
// 375:     expect(command).to receive(:run)
// 376:       .with("helper", args: [""], sudo: false, env: { "EMPTY" => "" }, input: [], must_succeed: true,
// 377:                       print_stdout: false, print_stderr: true, reset_uid: true, chdir: nil)
// 378:
// 379:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 380:
// 381:     expect((root/"var/remove.txt").read).to be_empty
// 382:   end
// 383:
// 384:   specify "omits install step runtime defaults" do
// 385:     steps = Homebrew::InstallSteps::DSL.build(default_base:        :staged_path,
// 386:                                               default_source_base: :staged_path,
// 387:                                               default_target_base: :staged_path) do
// 388:       copy "source", "target"
// 389:       symlink "source", "target"
// 390:       write "config", "content"
// 391:       set_ownership "Example.app"
// 392:       terminate_process "Example"
// 393:     end
// 394:
// 395:     expect(steps).to all(satisfy do |step|
// 396:       !step.keys.intersect?(%w[attempts force group match overwrite uninstall])
// 397:     end)
// 398:   end
// 399:
// 400:   specify "writes a default config file and preserves existing ones", :aggregate_failures do
// 401:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 402:       write "config/new.conf", "fresh"
// 403:       write "config/kept.conf", "default"
// 404:       write "config/replaced.conf", "default", overwrite: true
// 405:     end
// 406:
// 407:     (root/"var/config").mkpath
// 408:     (root/"var/config/kept.conf").write "user edit"
// 409:     (root/"var/config/replaced.conf").write "user edit"
// 410:
// 411:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 412:
// 413:     expect((root/"var/config/new.conf").read).to eq("fresh\n")
// 414:     expect((root/"var/config/kept.conf").read).to eq("user edit")
// 415:     expect((root/"var/config/replaced.conf").read).to eq("default\n")
// 416:   end
// 417:
// 418:   specify "snapshots conditions shared by a scope" do
// 419:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 420:       unless_path_exists "initialised" do
// 421:         mkdir_p "initialised"
// 422:         touch "initialised/marker"
// 423:       end
// 424:     end
// 425:
// 426:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 427:
// 428:     expect(root/"var/initialised/marker").to exist
// 429:   end
// 430:
// 431:   specify "keeps guard snapshots separate between concatenated step lists" do
// 432:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 433:       if_path_exists "missing" do
// 434:         touch "unexpected"
// 435:       end
// 436:     end
// 437:     steps.concat(
// 438:       Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 439:         if_path_exists "existing" do
// 440:           touch "matched"
// 441:         end
// 442:       end,
// 443:     )
// 444:     (root/"var/existing").mkpath
// 445:
// 446:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 447:
// 448:     expect(root/"var/matched").to exist
// 449:   end
// 450:
// 451:   specify "runs only steps matching the simulated platform" do
// 452:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 453:       on_macos do
// 454:         touch "macos"
// 455:       end
// 456:       on_linux do
// 457:         touch "linux"
// 458:       end
// 459:     end
// 460:
// 461:     expect([:macos, :linux].to_h do |os|
// 462:       FileUtils.rm_rf root/"var"
// 463:       Homebrew::SimulateSystem.with(os:) do
// 464:         Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 465:       end
// 466:       [os, [(root/"var/macos").exist?, (root/"var/linux").exist?]]
// 467:     end).to eq(macos: [true, false], linux: [false, true])
// 468:   end
// 469:
// 470:   specify "copies paths" do
// 471:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var, default_source_base: :staged_path,
// 472:                                               default_target_base: :var) do
// 473:       copy "source.txt", "copied.txt"
// 474:     end
// 475:
// 476:     (root/"stage").mkpath
// 477:     (root/"stage/source.txt").write "copied"
// 478:
// 479:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 480:
// 481:     expect((root/"var/copied.txt").read).to eq("copied")
// 482:   end
// 483:
// 484:   specify "replaces copied paths by default and can reject replacement" do
// 485:     rejecting_steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path,
// 486:                                                         default_target_base: :var) do
// 487:       copy "source.txt", "copied.txt", overwrite: false
// 488:     end
// 489:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 490:       copy "source.txt", "copied.txt"
// 491:     end
// 492:     (root/"stage").mkpath
// 493:     (root/"var").mkpath
// 494:     (root/"stage/source.txt").write "replacement"
// 495:     (root/"var/copied.txt").write "existing"
// 496:
// 497:     expect { Homebrew::InstallSteps::Runner.new(context:).run(rejecting_steps) }.to raise_error(Errno::EEXIST)
// 498:
// 499:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 500:     expect((root/"var/copied.txt").read).to eq("replacement")
// 501:   end
// 502:
// 503:   specify "replaces symlink destinations when copying files" do
// 504:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 505:       copy "source.txt", "copied.txt"
// 506:     end
// 507:     (root/"stage").mkpath
// 508:     (root/"var").mkpath
// 509:     (root/"stage/source.txt").write "replacement"
// 510:     (root/"var/linked.txt").write "original"
// 511:     File.symlink "linked.txt", root/"var/copied.txt"
// 512:
// 513:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 514:
// 515:     expect([(root/"var/copied.txt").symlink?, (root/"var/copied.txt").read, (root/"var/linked.txt").read])
// 516:       .to eq([false, "replacement", "original"])
// 517:   end
// 518:
// 519:   specify "preserves the legacy move replacement behaviour" do
// 520:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 521:       move "source.txt", "target.txt"
// 522:     end
// 523:     (root/"stage").mkpath
// 524:     (root/"var").mkpath
// 525:     (root/"stage/source.txt").write "replacement"
// 526:     (root/"var/target.txt").write "existing"
// 527:
// 528:     steps.fetch(0).delete("overwrite")
// 529:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 530:
// 531:     expect((root/"var/target.txt").read).to eq("replacement")
// 532:   end
// 533:
// 534:   specify "preserves a default move destination when repeated", :aggregate_failures do
// 535:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 536:       move "source", "target"
// 537:     end
// 538:     (root/"stage/source").mkpath
// 539:     (root/"stage/source/file").write "content"
// 540:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 541:
// 542:     runner.run(steps)
// 543:     expect { runner.run(steps) }.to raise_error(Errno::ENOENT)
// 544:     expect((root/"var/target/file").read).to eq("content")
// 545:   end
// 546:
// 547:   specify "requires one match for single-source globs" do
// 548:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 549:       copy "*.txt", "copied.txt", source_glob: true
// 550:     end
// 551:     (root/"stage").mkpath
// 552:     (root/"stage/first.txt").write "first"
// 553:     (root/"stage/second.txt").write "second"
// 554:
// 555:     expect { Homebrew::InstallSteps::Runner.new(context:).run(steps) }
// 556:       .to raise_error(ArgumentError, /exactly one path/)
// 557:   end
// 558:
// 559:   specify "requires a match for literal glob sources" do
// 560:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :var) do
// 561:       copy "missing.txt", "copied.txt", source_glob: true
// 562:     end
// 563:
// 564:     expect { Homebrew::InstallSteps::Runner.new(context:).run(steps) }
// 565:       .to raise_error(ArgumentError, /exactly one path/)
// 566:   end
// 567:
// 568:   specify "deduplicates overlapping move source globs" do
// 569:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path,
// 570:                                               default_target_base: :staged_path) do
// 571:       move "{WezTerm-*,WezTerm-*}/WezTerm.app", ".", source_glob: true
// 572:     end
// 573:     (root/"stage/WezTerm-nightly/WezTerm.app").mkpath
// 574:
// 575:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 576:
// 577:     expect(root/"stage/WezTerm.app").to be_a_directory
// 578:   end
// 579:
// 580:   specify "removes paths and expands globs", :aggregate_failures do
// 581:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 582:       remove ["obsolete.txt", "obsolete-*"], recursive: true
// 583:     end
// 584:
// 585:     (root/"var/obsolete-dir").mkpath
// 586:     (root/"var/obsolete.txt").write "obsolete"
// 587:     (root/"var/obsolete-dir/child").write "obsolete"
// 588:
// 589:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 590:
// 591:     expect(root/"var/obsolete.txt").not_to exist
// 592:     expect(root/"var/obsolete-dir").not_to exist
// 593:   end
// 594:
// 595:   specify "filters removals and accepts the legacy path base", :aggregate_failures do
// 596:     ENV["PATH"] = (root/"path-bin").to_s
// 597:     steps = Homebrew::InstallSteps::DSL.build do
// 598:       remove "links/*", base: :staged_path, symlink_target_contains: "wanted"
// 599:       remove "launcher", base: :path, content_contains: "owned marker"
// 600:     end
// 601:
// 602:     (root/"stage/links").mkpath
// 603:     (root/"stage/links/wanted").make_symlink("/tmp/wanted-target")
// 604:     (root/"stage/links/kept").make_symlink("/tmp/other-target")
// 605:     (root/"path-bin").mkpath
// 606:     (root/"path-bin/launcher").write "owned marker"
// 607:
// 608:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 609:
// 610:     expect(root/"stage/links/wanted").not_to exist
// 611:     expect(root/"stage/links/kept").to be_a_symlink
// 612:     expect(root/"path-bin/launcher").not_to exist
// 613:   end
// 614:
// 615:   specify "uses elevated cask removal when requested" do
// 616:     require "cask/utils"
// 617:
// 618:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 619:       remove "protected", sudo: true
// 620:     end
// 621:     (root/"var/protected").mkpath
// 622:     command = class_double(SystemCommand)
// 623:     expect(Cask::Utils).to receive(:gain_permissions_remove).with(root/"var/protected", command:)
// 624:
// 625:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 626:   end
// 627:
// 628:   specify "replaces literal and regular expression matches", :aggregate_failures do
// 629:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 630:       inreplace "literal.txt", "before", "after"
// 631:       inreplace "pattern.txt", /before.+after/i, "replaced"
// 632:     end
// 633:
// 634:     (root/"var").mkpath
// 635:     (root/"var/literal.txt").write "before"
// 636:     (root/"var/pattern.txt").write "BEFORE and AFTER"
// 637:
// 638:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 639:
// 640:     expect((root/"var/literal.txt").read).to eq("after")
// 641:     expect((root/"var/pattern.txt").read).to eq("replaced")
// 642:   end
// 643:
// 644:   specify "warns inside a matching path scope" do
// 645:     steps = Homebrew::InstallSteps::DSL.build do
// 646:       if_path_exists "{{var}}/{missing,conflict}" do
// 647:         warn "{{token}} conflict"
// 648:       end
// 649:     end
// 650:     named_context = context
// 651:     named_context.define_singleton_method(:name) { ["Example"] }
// 652:     named_context.define_singleton_method(:token) { "example" }
// 653:     (root/"var/conflict").mkpath
// 654:     runner = Homebrew::InstallSteps::Runner.new(context: named_context)
// 655:     expect(runner).to receive(:opoo).with("example conflict")
// 656:
// 657:     runner.run(steps)
// 658:   end
// 659:
// 660:   specify "runs serialised commands" do
// 661:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 662:       run "helper", args: ["--path={{var}}"], base: :libexec, env: { "EXAMPLE" => "{{var}}/value" }
// 663:     end
// 664:
// 665:     command = class_double(SystemCommand)
// 666:     expect(command).to receive(:run)
// 667:       .with(root/"prefix/libexec/helper", args: ["--path=#{root}/var"], sudo: false,
// 668:                                            env: { "EXAMPLE" => "#{root}/var/value" }, input: [],
// 669:                                            must_succeed: true, print_stdout: false,
// 670:                                            print_stderr: true, reset_uid: true, chdir: nil)
// 671:
// 672:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 673:   end
// 674:
// 675:   specify "serialises command environments as JSON objects" do
// 676:     steps = Homebrew::InstallSteps::DSL.build do
// 677:       run "helper", env: { "EXAMPLE" => "{{formula_name}}" },
// 678:                     writable_paths: ["Library/Application Support/Example"], writable_base: :home
// 679:     end
// 680:
// 681:     expect(steps).to include(a_hash_including(
// 682:                                "type"           => "run",
// 683:                                "env"            => { "EXAMPLE" => "{{formula_name}}" },
// 684:                                "writable_paths" => [
// 685:                                  { "base" => "home", "path" => "Library/Application Support/Example" },
// 686:                                ],
// 687:                              ))
// 688:   end
// 689:
// 690:   specify "runs commands with serialised input and output paths" do
// 691:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 692:       run "filter", base: :bin, stdin_path: "input.txt", stdout_path: "output.txt", chdir: "work"
// 693:     end
// 694:
// 695:     (root/"var/work").mkpath
// 696:     (root/"var/input.txt").write "input"
// 697:     result = instance_double(SystemCommand::Result, stdout: "output", success?: true)
// 698:     command = class_double(SystemCommand)
// 699:     expect(command).to receive(:run)
// 700:       .with(root/"prefix/bin/filter", args: [], sudo: false, env: {}, input: "input", must_succeed: true,
// 701:                                       print_stdout: false, print_stderr: true, reset_uid: true,
// 702:                                       chdir: root/"var/work")
// 703:       .and_return(result)
// 704:
// 705:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 706:
// 707:     expect((root/"var/output.txt").read).to eq("output")
// 708:   end
// 709:
// 710:   specify "allows a run step to fail when it must not succeed" do
// 711:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 712:       run "helper", base: :libexec, must_succeed: false
// 713:     end
// 714:
// 715:     expect(steps).to include(a_hash_including("type" => "run", "allow_failure" => true))
// 716:
// 717:     command = class_double(SystemCommand)
// 718:     expect(command).to receive(:run)
// 719:       .with(root/"prefix/libexec/helper", args: [], sudo: false, env: {}, input: [], must_succeed: false,
// 720:                                            print_stdout: false, print_stderr: true, reset_uid: true, chdir: nil)
// 721:
// 722:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 723:   end
// 724:
// 725:   specify "does not write an output path when an ignored run step fails" do
// 726:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 727:       run "filter", base: :bin, stdout_path: "output.txt", must_succeed: false
// 728:     end
// 729:
// 730:     result = instance_double(SystemCommand::Result, success?: false)
// 731:     command = class_double(SystemCommand)
// 732:     allow(command).to receive(:run).and_return(result)
// 733:
// 734:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 735:
// 736:     expect(root/"var/output.txt").not_to exist
// 737:   end
// 738:
// 739:   specify "can ignore process termination failure after retries" do
// 740:     steps = Homebrew::InstallSteps::DSL.build do
// 741:       terminate_process "/Applications/Example.app", match: :full, attempts: 3,
// 742:                                                        notices: ["Closing {{name}}"],
// 743:                                                        failure_message: "Unable to close {{name}}"
// 744:     end
// 745:
// 746:     named_context = context
// 747:     named_context.define_singleton_method(:name) { "Example" }
// 748:     command = class_double(SystemCommand)
// 749:     runner = Homebrew::InstallSteps::Runner.new(context: named_context, command:)
// 750:     allow(runner).to receive(:sleep)
// 751:     expect(runner).to receive(:ohai).with("Closing Example")
// 752:     expect(runner).to receive(:opoo).with("Unable to close Example")
// 753:     expect(command).to receive(:run!)
// 754:       .with("/usr/bin/pkill", args: ["-f", "/Applications/Example.app"], sudo: false,
// 755:                               print_stdout: true, print_stderr: true, reset_uid: true)
// 756:       .exactly(3).times
// 757:       .and_raise(ErrorDuringExecution.new([], status: 1))
// 758:
// 759:     expect { runner.run(steps) }.not_to raise_error
// 760:   end
// 761:
// 762:   specify "rejects unknown process match modes" do
// 763:     expect do
// 764:       Homebrew::InstallSteps::DSL.build do
// 765:         terminate_process "Example", match: :prefix
// 766:       end
// 767:     end.to raise_error(ArgumentError, "terminate_process match must be :name or :full")
// 768:   end
// 769:
// 770:   specify "rejects non-positive process termination attempts" do
// 771:     expect do
// 772:       Homebrew::InstallSteps::DSL.build do
// 773:         terminate_process "Example", attempts: 0
// 774:       end
// 775:     end.to raise_error(ArgumentError, "terminate_process attempts must be positive")
// 776:   end
// 777:
// 778:   specify "uses killall for exact process names" do
// 779:     steps = Homebrew::InstallSteps::DSL.build do
// 780:       terminate_process "Example", must_succeed: true
// 781:     end
// 782:
// 783:     command = class_double(SystemCommand)
// 784:     expect(command).to receive(:run!)
// 785:       .with("/usr/bin/killall", args: ["Example"], sudo: false,
// 786:                                 print_stdout: true, print_stderr: true, reset_uid: true)
// 787:
// 788:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 789:   end
// 790:
// 791:   specify "appends a trailing newline unless already present", :aggregate_failures do
// 792:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 793:       write "missing-newline", "value"
// 794:       write "has-newline", "value\n"
// 795:     end
// 796:
// 797:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 798:
// 799:     expect((root/"var/missing-newline").read).to eq("value\n")
// 800:     expect((root/"var/has-newline").read).to eq("value\n")
// 801:   end
// 802:
// 803:   specify "raises when a write step has missing content" do
// 804:     expect do
// 805:       Homebrew::InstallSteps::Runner.new(context:).run([{ "type" => "write", "path" => "config/new.conf" }])
// 806:     end.to raise_error(ArgumentError, /requires content/)
// 807:   end
// 808:
// 809:   specify "runs service data directory initialisers", :aggregate_failures do
// 810:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 811:       init_data_dir "postgresql@16", using: :postgresql
// 812:       init_data_dir "postgresql@12", using: :postgresql, locale: "C"
// 813:       init_data_dir "mysql", using: :mysql
// 814:       init_data_dir "mysql", using: :mariadb
// 815:     end
// 816:
// 817:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 818:
// 819:     expect(runner).to receive(:run_command).with(root/"prefix/bin/initdb", "--locale=en_US.UTF-8", "-E", "UTF-8",
// 820:                                                  root/"var/postgresql@16").ordered
// 821:     expect(runner).to receive(:run_command).with(root/"prefix/bin/initdb", "--locale=C", "-E", "UTF-8",
// 822:                                                  root/"var/postgresql@12").ordered
// 823:     expect(runner).to receive(:run_command).with(root/"prefix/bin/mysqld", "--initialize-insecure",
// 824:                                                  "--user=#{ENV.fetch("USER")}", "--basedir=#{root}/prefix",
// 825:                                                  "--datadir=#{root}/var/mysql", "--tmpdir=/tmp").ordered
// 826:     expect(runner).to receive(:run_command).with(root/"prefix/bin/mysql_install_db", "--verbose",
// 827:                                                  "--user=#{ENV.fetch("USER")}", "--basedir=#{root}/prefix",
// 828:                                                  "--datadir=#{root}/var/mysql", "--tmpdir=/tmp").ordered
// 829:
// 830:     runner.run(steps)
// 831:
// 832:     expect(root/"var/postgresql@16").to be_a_directory
// 833:     expect(root/"var/postgresql@12").to be_a_directory
// 834:     expect(root/"var/mysql").to be_a_directory
// 835:   end
// 836:
// 837:   specify "links remapped directories and children before running initdb", :aggregate_failures do
// 838:     homebrew_prefix = root/"homebrew-prefix"
// 839:     stub_const("HOMEBREW_PREFIX", homebrew_prefix)
// 840:     root_path = root
// 841:     versioned_context = Class.new do
// 842:       define_method(:name) { "postgresql@17" }
// 843:       define_method(:version) { Version.new("17.5") }
// 844:       define_method(:prefix) { root_path/"prefix" }
// 845:       define_method(:bin) { root_path/"prefix/bin" }
// 846:       define_method(:var) { root_path/"var" }
// 847:     end.new
// 848:     %w[include lib share].each do |dir|
// 849:       (root/"prefix/#{dir}/postgresql/server").mkpath
// 850:       (root/"prefix/#{dir}/postgresql/server/extension.h").write dir
// 851:       (root/"prefix/#{dir}/postgresql/postgres.bki").write dir
// 852:       (root/"prefix/#{dir}/postgresql/.DS_Store").write ""
// 853:       (homebrew_prefix/dir/"postgresql@17/server").mkpath
// 854:       (homebrew_prefix/dir/"postgresql@17/server/local.h").write dir
// 855:     end
// 856:     (root/"prefix/share/postgresql/conflicting-path").write "source file"
// 857:     (homebrew_prefix/"share/postgresql@17/conflicting-path").mkpath
// 858:     (homebrew_prefix/"share/postgresql@17/conflicting-path/local").write "kept"
// 859:     (root/"prefix/bin").mkpath
// 860:     (root/"prefix/bin/initdb").write ""
// 861:     FileUtils.chmod "+x", root/"prefix/bin/initdb"
// 862:     (root/"prefix/bin/pg_config").write ""
// 863:     FileUtils.chmod "+x", root/"prefix/bin/pg_config"
// 864:
// 865:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var, default_source_base: :prefix) do
// 866:       symlink_tree "include/postgresql", "include/#{formula_name}"
// 867:       symlink_tree "lib/postgresql", "lib/#{formula_name}"
// 868:       symlink_tree "share/postgresql", "share/#{formula_name}"
// 869:       symlink_children "bin", suffix: "-#{version.major}"
// 870:       init_data_dir formula_name, using: :postgresql
// 871:     end
// 872:
// 873:     runner = Homebrew::InstallSteps::Runner.new(context: versioned_context)
// 874:
// 875:     expect(runner).to receive(:run_command) do |*args|
// 876:       expect(args).to eq([root/"prefix/bin/initdb", "--locale=en_US.UTF-8", "-E", "UTF-8",
// 877:                           root/"var/postgresql@17"])
// 878:       expect(homebrew_prefix/"share/postgresql@17").to be_a_directory
// 879:       expect(homebrew_prefix/"share/postgresql@17/postgres.bki").to be_a_symlink
// 880:     end
// 881:
// 882:     runner.run(steps)
// 883:
// 884:     %w[include lib share].each do |dir|
// 885:       expect(homebrew_prefix/dir/"postgresql@17/server").to be_a_directory
// 886:       expect(homebrew_prefix/dir/"postgresql@17/server/local.h").to exist
// 887:       expect(homebrew_prefix/dir/"postgresql@17/server/extension.h").to be_a_symlink
// 888:       expect(homebrew_prefix/dir/"postgresql@17/postgres.bki").to be_a_symlink
// 889:       expect(homebrew_prefix/dir/"postgresql@17/.DS_Store").not_to exist
// 890:     end
// 891:     expect(homebrew_prefix/"share/postgresql@17/conflicting-path/local").to exist
// 892:     expect(homebrew_prefix/"bin/initdb-17").to be_a_symlink
// 893:     expect(homebrew_prefix/"bin/pg_config-17").to be_a_symlink
// 894:   end
// 895:
// 896:   specify "skips data directory initialisers in CI", :aggregate_failures do
// 897:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 898:       init_data_dir "postgresql@16", using: :postgresql
// 899:     end
// 900:
// 901:     ENV["HOMEBREW_GITHUB_ACTIONS"] = "1"
// 902:
// 903:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 904:     expect(runner).not_to receive(:run_command)
// 905:
// 906:     runner.run(steps)
// 907:
// 908:     expect(root/"var/postgresql@16").to be_a_directory
// 909:   end
// 910:
// 911:   specify "skips data directory initialisers when their marker exists", :aggregate_failures do
// 912:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 913:       init_data_dir "mysql", using: :mysql
// 914:     end
// 915:
// 916:     (root/"var/mysql/mysql").mkpath
// 917:     (root/"var/mysql/mysql/general_log.CSM").write ""
// 918:
// 919:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 920:     expect(runner).not_to receive(:run_command)
// 921:
// 922:     runner.run(steps)
// 923:
// 924:     expect(root/"var/mysql").to be_a_directory
// 925:   end
// 926:
// 927:   specify "raises on unknown data directory initialisers" do
// 928:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 929:       init_data_dir "unknown", using: :unknown_database
// 930:     end
// 931:
// 932:     ENV["HOMEBREW_GITHUB_ACTIONS"] = "1"
// 933:
// 934:     expect { Homebrew::InstallSteps::Runner.new(context:).run(steps) }
// 935:       .to raise_error(ArgumentError, /unknown data directory initialiser/)
// 936:     expect(root/"var/unknown").not_to exist
// 937:   end
// 938:
// 939:   specify "runs named desktop and cache rebuild actions" do
// 940:     stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 941:     %w[
// 942:       opt/glib/bin/glib-compile-schemas
// 943:       opt/glib/bin/gio-querymodules
// 944:       opt/gdk-pixbuf/bin/gdk-pixbuf-query-loaders
// 945:       opt/shared-mime-info/bin/update-mime-database
// 946:       opt/desktop-file-utils/bin/update-desktop-database
// 947:     ].each do |path|
// 948:       create_executable HOMEBREW_PREFIX/path
// 949:     end
// 950:     steps = Homebrew::InstallSteps::DSL.build do
// 951:       compile_gsettings_schemas
// 952:       update_gio_modules_cache
// 953:       update_gdk_pixbuf_loaders_cache
// 954:       update_mime_database
// 955:       update_desktop_database
// 956:     end
// 957:
// 958:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 959:     expect(runner).to receive(:run_command).with(root/"homebrew/opt/glib/bin/glib-compile-schemas",
// 960:                                                  HOMEBREW_PREFIX/"share/glib-2.0/schemas").ordered
// 961:     expect(runner).to receive(:run_command).with(root/"homebrew/opt/glib/bin/gio-querymodules",
// 962:                                                  HOMEBREW_PREFIX/"lib/gio/modules").ordered
// 963:     expect(runner).to receive(:run_command)
// 964:       .with(root/"homebrew/opt/gdk-pixbuf/bin/gdk-pixbuf-query-loaders", "--update-cache").ordered
// 965:     expect(runner).to receive(:run_command).with(root/"homebrew/opt/shared-mime-info/bin/update-mime-database",
// 966:                                                  HOMEBREW_PREFIX/"share/mime").ordered
// 967:     expect(runner).to receive(:run_command)
// 968:       .with(root/"homebrew/opt/desktop-file-utils/bin/update-desktop-database",
// 969:             HOMEBREW_PREFIX/"share/applications").ordered
// 970:
// 971:     runner.run(steps)
// 972:   end
// 973:
// 974:   specify "reports missing formula helper executables" do
// 975:     stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 976:     steps = Homebrew::InstallSteps::DSL.build do
// 977:       compile_gsettings_schemas
// 978:     end
// 979:
// 980:     expect { Homebrew::InstallSteps::Runner.new(context:).run(steps) }
// 981:       .to raise_error(ArgumentError, %r{glib is missing required executable: .*/opt/glib/bin/glib-compile-schemas})
// 982:   end
// 983:
// 984:   specify "dispatches GCC runtime configuration" do
// 985:     steps = Homebrew::InstallSteps::DSL.build do
// 986:       configure_gcc_runtime
// 987:     end
// 988:
// 989:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 990:     expect(runner).to receive(:run_configure_gcc_runtime)
// 991:
// 992:     runner.run(steps)
// 993:   end
// 994:
// 995:   specify "configures GCC runtime files on Linux", :aggregate_failures do
// 996:     steps = Homebrew::InstallSteps::DSL.build do
// 997:       configure_gcc_runtime
// 998:     end
// 999:     gcc_context = context
// 1000:     gcc_context.define_singleton_method(:name) { "gcc" }
// 1001:     libgcc = root/"gcc/lib/gcc/15"
// 1002:     crtdir = root/"system/lib"
// 1003:     libgcc.mkpath
// 1004:     crtdir.mkpath
// 1005:     crti = crtdir/"crti.o"
// 1006:     crti.write "crt"
// 1007:     specs = libgcc/"specs"
// 1008:     specs.write "old specs"
// 1009:     Pathname("#{specs}.orig").write "old original specs"
// 1010:     gcc = root/"prefix/bin/gcc-15"
// 1011:     original_specs = "*link:\n+ %o \n"
// 1012:
// 1013:     allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_linux?).and_return(true)
// 1014:     allow(Utils::Path).to receive(:formula_any_version_installed?).with("glibc").and_return(false)
// 1015:     allow(Utils::Path).to receive(:formula_opt_lib).with("glibc").and_return(root/"glibc/lib")
// 1016:     runner = Homebrew::InstallSteps::Runner.new(context: gcc_context)
// 1017:     expect(runner).to receive(:context_version_major).and_return("15")
// 1018:     expect(runner).to receive(:run_command_output)
// 1019:       .with(gcc, "-print-libgcc-file-name").ordered
// 1020:       .and_return("#{libgcc}/libgcc_s.so\n")
// 1021:     expect(runner).to receive(:run_command_output)
// 1022:       .with("/usr/bin/cc", "-print-file-name=crti.o").ordered
// 1023:       .and_return("#{crti}\n")
// 1024:     expect(runner).to receive(:run_command_output)
// 1025:       .with(gcc, "-print-multiarch").ordered
// 1026:       .and_return("x86_64-linux-gnu\n")
// 1027:     expect(runner).to receive(:run_command_output).with(gcc, "-dumpspecs").ordered.and_return(original_specs)
// 1028:     expect(FileUtils).to receive(:ln_sf).with([crti.to_s], libgcc).and_call_original
// 1029:     expect(FileUtils).to receive(:rm_f).with(["#{specs}.orig", specs]).and_call_original
// 1030:
// 1031:     runner.run(steps)
// 1032:
// 1033:     expect(libgcc/"crti.o").to be_a_symlink
// 1034:     expect((libgcc/"crti.o").readlink).to eq(crti)
// 1035:     expect(Pathname("#{specs}.orig").read).to eq(original_specs)
// 1036:     expect(specs.read).to include("%(homebrew_rpath)", "-idirafter /usr/include/x86_64-linux-gnu")
// 1037:   end
// 1038:
// 1039:   specify "dispatches gzipped executable installation" do
// 1040:     steps = Homebrew::InstallSteps::DSL.build do
// 1041:       install_gzipped_executable "compressed.gz", "bin/executable"
// 1042:     end
// 1043:
// 1044:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1045:     expect(runner).to receive(:run_install_gzipped_executable)
// 1046:
// 1047:     runner.run(steps)
// 1048:   end
// 1049:
// 1050:   specify "installs a gzipped executable with a fixed mode", :aggregate_failures do
// 1051:     require "zlib"
// 1052:
// 1053:     source = root/"prefix/bin/executable.gz"
// 1054:     source.dirname.mkpath
// 1055:     Zlib::GzipWriter.open(source.to_s) do |gzip|
// 1056:       gzip.orig_name = "stored-name"
// 1057:       gzip.write "executable"
// 1058:     end
// 1059:     stored_name = source.dirname/"stored-name"
// 1060:     stored_name.write "preserve"
// 1061:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :prefix, default_target_base: :prefix) do
// 1062:       install_gzipped_executable "bin/executable.gz", "bin/executable"
// 1063:     end
// 1064:
// 1065:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 1066:
// 1067:     target = root/"prefix/bin/executable"
// 1068:     expect(target.read).to eq("executable")
// 1069:     expect(target.stat.mode & 0777).to eq(0755)
// 1070:     expect(source).not_to exist
// 1071:     expect(stored_name.read).to eq("preserve")
// 1072:   end
// 1073:
// 1074:   specify "dispatches glibc runtime configuration" do
// 1075:     steps = Homebrew::InstallSteps::DSL.build do
// 1076:       configure_glibc_runtime
// 1077:     end
// 1078:
// 1079:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1080:     expect(runner).to receive(:run_configure_glibc_runtime)
// 1081:
// 1082:     runner.run(steps)
// 1083:   end
// 1084:
// 1085:   specify "configures glibc locales and timezone links", :aggregate_failures do
// 1086:     steps = Homebrew::InstallSteps::DSL.build do
// 1087:       configure_glibc_runtime
// 1088:     end
// 1089:     glibc_context = context
// 1090:     root_path = root
// 1091:     glibc_context.define_singleton_method(:name) { "glibc" }
// 1092:     glibc_context.define_singleton_method(:lib) { root_path/"prefix/lib" }
// 1093:     glibc_context.define_singleton_method(:etc) { root_path/"prefix/etc" }
// 1094:     glibc_context.define_singleton_method(:share) { root_path/"prefix/share" }
// 1095:     (root/"prefix/etc").mkpath
// 1096:     (root/"prefix/share").mkpath
// 1097:     ENV.delete_if { |key,| key == "HOMEBREW_LANG" || key == "LANG" || key.start_with?("LC_") }
// 1098:     ENV["HOMEBREW_LANG"] = "de_DE.utf8"
// 1099:     ENV["LANG"] = "C"
// 1100:     ENV["LC_TIME"] = "en_GB"
// 1101:     timezone_sources = [Pathname("/etc/localtime"), Pathname("/usr/share/zoneinfo")]
// 1102:     allow_any_instance_of(Pathname).to receive(:exist?).and_wrap_original do |method, *args|
// 1103:       timezone_sources.include?(method.receiver) || method.call(*args)
// 1104:     end
// 1105:
// 1106:     runner = Homebrew::InstallSteps::Runner.new(context: glibc_context)
// 1107:     localedef = root/"prefix/bin/localedef"
// 1108:     expect(runner).to receive(:ohai).with("Installing locale data for de_DE.utf8 en_GB en_US.UTF-8")
// 1109:     expect(runner).to receive(:run_command)
// 1110:       .with(localedef, "-i", "de_DE", "-f", "UTF-8", "de_DE.utf8").ordered
// 1111:     expect(runner).to receive(:run_command).with(localedef, "-i", "en_GB", "en_GB").ordered
// 1112:     expect(runner).to receive(:run_command)
// 1113:       .with(localedef, "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8").ordered
// 1114:
// 1115:     runner.run(steps)
// 1116:
// 1117:     expect(root/"prefix/lib/locale").to be_a_directory
// 1118:     expect(root/"prefix/etc/localtime").to be_a_symlink
// 1119:     expect((root/"prefix/etc/localtime").readlink).to eq(Pathname("/etc/localtime"))
// 1120:     expect(root/"prefix/share/zoneinfo").to be_a_symlink
// 1121:     expect((root/"prefix/share/zoneinfo").readlink).to eq(Pathname("/usr/share/zoneinfo"))
// 1122:   end
// 1123:
// 1124:   specify "dispatches Clang system configuration" do
// 1125:     steps = Homebrew::InstallSteps::DSL.build do
// 1126:       configure_clang_system
// 1127:     end
// 1128:
// 1129:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1130:     expect(runner).to receive(:run_configure_clang_system)
// 1131:
// 1132:     runner.run(steps)
// 1133:   end
// 1134:
// 1135:   specify "repairs incomplete Clang system configuration" do
// 1136:     require "utils/clang"
// 1137:
// 1138:     steps = Homebrew::InstallSteps::DSL.build do
// 1139:       configure_clang_system
// 1140:     end
// 1141:     clang_context = context
// 1142:     root_path = root
// 1143:     clang_context.define_singleton_method(:etc) { root_path/"prefix/etc" }
// 1144:     config_dir = root/"prefix/etc/clang"
// 1145:     config_dir.mkpath
// 1146:     (config_dir/"arm64-apple-darwin23.cfg").write ""
// 1147:     (config_dir/"arm64-apple-macosx14.cfg").write ""
// 1148:     macos_version = MacOSVersion.new("14")
// 1149:     stub_const("MacOS", Module.new do
// 1150:       define_singleton_method(:version) { macos_version }
// 1151:     end)
// 1152:     allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_macos?).and_return(true)
// 1153:     allow(OS).to receive(:kernel_version).and_return(Version.new("23"))
// 1154:     allow(Hardware::CPU).to receive(:arch).and_return(:arm64)
// 1155:     expect(Utils::Clang).to receive(:write_system_config_files).with(
// 1156:       config_dir:,
// 1157:       macos_version:,
// 1158:       kernel_version: "23",
// 1159:       arch:           :arm64,
// 1160:     )
// 1161:
// 1162:     Homebrew::InstallSteps::Runner.new(context: clang_context).run(steps)
// 1163:   end
// 1164:
// 1165:   describe "configures PHP" do
// 1166:     let(:steps) do
// 1167:       Homebrew::InstallSteps::DSL.build do
// 1168:         configure_php
// 1169:       end
// 1170:     end
// 1171:     let(:homebrew_prefix) { root/"homebrew" }
// 1172:     let(:pear_prefix) { root/"prefix/share/php@8.4/pear" }
// 1173:     let(:pecl_path) { homebrew_prefix/"lib/php/pecl" }
// 1174:     let(:ext_config_path) { homebrew_prefix/"etc/php/8.4/conf.d/ext-opcache.ini" }
// 1175:     let(:php_context) do
// 1176:       root_path = root
// 1177:       context.tap do |value|
// 1178:         value.define_singleton_method(:name) { "php@8.4" }
// 1179:         value.define_singleton_method(:version) { Version.new("8.4.1") }
// 1180:         value.define_singleton_method(:pkgshare) { root_path/"prefix/share/php@8.4" }
// 1181:         value.define_singleton_method(:opt_prefix) { root_path/"opt/php@8.4" }
// 1182:         value.define_singleton_method(:etc) { root_path/"homebrew/etc" }
// 1183:       end
// 1184:     end
// 1185:     let(:runner) { Homebrew::InstallSteps::Runner.new(context: php_context) }
// 1186:
// 1187:     before do
// 1188:       stub_const("HOMEBREW_PREFIX", homebrew_prefix)
// 1189:       (pear_prefix/".channels/.alias").mkpath
// 1190:       (pear_prefix/".channels/pear.php.net.reg").write "channel"
// 1191:       (pear_prefix/".channels/.alias/pear.txt").write "alias"
// 1192:       (pear_prefix/".depdblock").write "lock"
// 1193:       FileUtils.chmod 0700, [pear_prefix/".channels", pear_prefix/".channels/.alias"]
// 1194:       FileUtils.chmod 0600, [pear_prefix/".channels/pear.php.net.reg", pear_prefix/".channels/.alias/pear.txt",
// 1195:                              pear_prefix/".depdblock"]
// 1196:       (homebrew_prefix/"share").mkpath
// 1197:       File.symlink root/"missing-pecl", root/"prefix/pecl"
// 1198:       allow(runner).to receive(:run_command_output)
// 1199:         .with(root/"prefix/bin/php-config", "--extension-dir")
// 1200:         .and_return("/usr/local/lib/php/20240924\n")
// 1201:       allow(runner).to receive(:run_command)
// 1202:     end
// 1203:
// 1204:     specify "updates PEAR, PECL and opcache configuration", :aggregate_failures do
// 1205:       expect(runner).to receive(:run_command).with(
// 1206:         root/"prefix/bin/pear", "config-set", "ext_dir", pecl_path/"20240924", "system"
// 1207:       ).ordered
// 1208:       expect(runner).to receive(:run_command).with(root/"prefix/bin/pear", "update-channels").ordered
// 1209:
// 1210:       runner.run(steps)
// 1211:
// 1212:       expect((pear_prefix/".channels").stat.mode & 0777).to eq(0755)
// 1213:       expect((pear_prefix/".channels/.alias").stat.mode & 0777).to eq(0755)
// 1214:       expect((pear_prefix/".channels/pear.php.net.reg").stat.mode & 0777).to eq(0644)
// 1215:       expect((pear_prefix/".channels/.alias/pear.txt").stat.mode & 0777).to eq(0644)
// 1216:       expect((pear_prefix/".depdblock").stat.mode & 0777).to eq(0644)
// 1217:       expect(root/"prefix/pecl").to be_a_symlink
// 1218:       expect((root/"prefix/pecl").readlink).to eq(pecl_path)
// 1219:       expect(pecl_path/"20240924").to be_a_directory
// 1220:       expect(homebrew_prefix/"share/pear@8.4/.depdblock").to exist
// 1221:       expect(ext_config_path.read).to eq <<~INI
// 1222:         [opcache]
// 1223:         zend_extension="#{root}/opt/php@8.4/lib/php/20240924/opcache.so"
// 1224:       INI
// 1225:     end
// 1226:
// 1227:     specify "only replaces the active opcache extension setting" do
// 1228:       ext_config_path.dirname.mkpath
// 1229:       ext_config_path.write <<~INI
// 1230:         ; zend_extension=keep.so
// 1231:           zend_extension = old.so
// 1232:         description=zend_extension=also-keep
// 1233:       INI
// 1234:
// 1235:       runner.run(steps)
// 1236:
// 1237:       expect(ext_config_path.read).to eq <<~INI
// 1238:         ; zend_extension=keep.so
// 1239:         zend_extension="#{root}/opt/php@8.4/lib/php/20240924/opcache.so"
// 1240:         description=zend_extension=also-keep
// 1241:       INI
// 1242:     end
// 1243:
// 1244:     specify "audits existing opcache extension settings" do
// 1245:       ext_config_path.dirname.mkpath
// 1246:       ext_config_path.write "[opcache]\n"
// 1247:
// 1248:       expect { runner.run(steps) }.to raise_error(Utils::Inreplace::Error)
// 1249:     end
// 1250:   end
// 1251:
// 1252:   specify "dispatches CPython and PyPy bootstrap" do
// 1253:     steps = Homebrew::InstallSteps::DSL.build do
// 1254:       bootstrap_cpython
// 1255:       bootstrap_pypy abi_version: "3.10"
// 1256:     end
// 1257:
// 1258:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1259:     expect(runner).to receive(:run_bootstrap_cpython).ordered
// 1260:     expect(runner).to receive(:run_bootstrap_pypy).with("3.10").ordered
// 1261:
// 1262:     runner.run(steps)
// 1263:   end
// 1264:
// 1265:   specify "bootstraps CPython 3.9 configuration", :aggregate_failures do
// 1266:     python = api_formula("python@3.9", "3.9.1")
// 1267:     allow(python).to receive(:prefix).and_return(root/"prefix")
// 1268:     stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 1269:     allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_macos?).and_return(false)
// 1270:     site_packages = root/"homebrew/lib/python3.9/site-packages"
// 1271:     site_packages_cellar = root/"prefix/lib/python3.9/site-packages"
// 1272:     bundled = root/"prefix/lib/python3.9/ensurepip/_bundled"
// 1273:     bundled.mkpath
// 1274:     setuptools_wheel = bundled/"setuptools-1.0-py3-none-any.whl"
// 1275:     pip_wheel = bundled/"pip-1.0-py3-none-any.whl"
// 1276:     wheel = root/"prefix/libexec/wheel-1.0-py3-none-any.whl"
// 1277:     [setuptools_wheel, pip_wheel, wheel].each do |path|
// 1278:       path.dirname.mkpath
// 1279:       path.write "wheel"
// 1280:     end
// 1281:     (site_packages_cellar/"old.pth").tap do |path|
// 1282:       path.dirname.mkpath
// 1283:       path.write "old"
// 1284:     end
// 1285:     (site_packages/"bin").mkpath
// 1286:     (site_packages/"bin/pip3.9").write "pip"
// 1287:     (site_packages/"bin/wheel").write "wheel"
// 1288:     (root/"prefix/bin").mkpath
// 1289:     (root/"prefix/lib/python3.9/distutils").mkpath
// 1290:     (root/"homebrew/bin").mkpath
// 1291:     runner = Homebrew::InstallSteps::Runner.new(context: python)
// 1292:     pip_install_args = []
// 1293:     allow(runner).to receive(:run_command) do |*args|
// 1294:       next unless args.include?("--target=#{site_packages}")
// 1295:
// 1296:       pip_install_args.concat(args)
// 1297:       framework_compat = site_packages/"setuptools/_distutils/command/_framework_compat.py"
// 1298:       framework_compat.dirname.mkpath
// 1299:       framework_compat.write "    homebrew_prefix = None\n"
// 1300:     end
// 1301:     steps = Homebrew::InstallSteps::DSL.build do
// 1302:       bootstrap_cpython
// 1303:     end
// 1304:
// 1305:     runner.run(steps)
// 1306:
// 1307:     expect(site_packages_cellar).to be_a_symlink
// 1308:     expect(site_packages_cellar.realpath).to eq(site_packages.realpath)
// 1309:     expect(site_packages_cellar/"old.pth").not_to exist
// 1310:     expect((root/"prefix/lib/python3.9/distutils/distutils.cfg").read).to eq <<~INI
// 1311:       [install]
// 1312:       prefix=#{root}/homebrew
// 1313:       [build_ext]
// 1314:       include_dirs=#{root}/homebrew/include:#{root}/homebrew/opt/openssl@3/include:#{root}/homebrew/opt/sqlite/include
// 1315:       library_dirs=#{root}/homebrew/lib:#{root}/homebrew/opt/openssl@3/lib:#{root}/homebrew/opt/sqlite/lib
// 1316:     INI
// 1317:     expect((site_packages/"setuptools/_distutils/command/_framework_compat.py").read)
// 1318:       .to eq("    homebrew_prefix = '#{root}/homebrew'\n")
// 1319:     expect(pip_install_args).to include(setuptools_wheel, pip_wheel, wheel)
// 1320:     expect(python).to be_loaded_from_api
// 1321:   end
// 1322:
// 1323:   specify "bootstraps PyPy 3.10 configuration", :aggregate_failures do
// 1324:     require "rubygems/package"
// 1325:     require "zlib"
// 1326:
// 1327:     pypy = api_formula("pypy3.10", "7.3.20")
// 1328:     allow(pypy).to receive_messages(
// 1329:       prefix:   root/"prefix",
// 1330:       libexec:  root/"prefix/libexec",
// 1331:       pkgshare: root/"prefix/share/pypy3",
// 1332:     )
// 1333:     stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 1334:     post_install_resources = root/"prefix/libexec/post-install-resources"
// 1335:     %w[setuptools pip].each do |package|
// 1336:       archive = post_install_resources/"#{package}.tar.gz"
// 1337:       archive.dirname.mkpath
// 1338:       Zlib::GzipWriter.open(archive.to_s) do |gzip|
// 1339:         Gem::Package::TarWriter.new(gzip) do |tar|
// 1340:           contents = package
// 1341:           tar.mkdir "#{package}-1.0", 0755
// 1342:           tar.add_file_simple "#{package}-1.0/setup.py", 0644, contents.bytesize do |file|
// 1343:             file.write contents
// 1344:           end
// 1345:         end
// 1346:       end
// 1347:     end
// 1348:     scripts_folder = root/"homebrew/share/pypy3.10"
// 1349:     scripts_folder.mkpath
// 1350:     (scripts_folder/"pip3.10").write "pip"
// 1351:     (root/"prefix/libexec/lib/pypy3.10/distutils").mkpath
// 1352:     command = class_double(SystemCommand, run: nil)
// 1353:     runner = Homebrew::InstallSteps::Runner.new(context: pypy, command:)
// 1354:     installed_packages = []
// 1355:     allow(runner).to receive(:run_command) do |_, *args|
// 1356:       installed_packages << (Pathname.pwd/"setup.py").read if args.include?("setup.py")
// 1357:     end
// 1358:     steps = Homebrew::InstallSteps::DSL.build do
// 1359:       bootstrap_pypy abi_version: "3.10"
// 1360:     end
// 1361:
// 1362:     runner.run(steps)
// 1363:
// 1364:     site_packages = root/"homebrew/lib/pypy3.10/site-packages"
// 1365:     libexec_site_packages = root/"prefix/libexec/lib/pypy3.10/site-packages"
// 1366:     expect(site_packages/".keepme").to exist
// 1367:     expect(libexec_site_packages).to be_a_symlink
// 1368:     expect(libexec_site_packages.realpath).to eq(site_packages.realpath)
// 1369:     expect((root/"prefix/libexec/lib/pypy3.10/distutils/distutils.cfg").read).to eq <<~INI
// 1370:       [install]
// 1371:       install-scripts=#{scripts_folder}
// 1372:     INI
// 1373:     expect(root/"prefix/bin/pip_pypy3.10").to be_a_symlink
// 1374:     expect(root/"homebrew/bin/pip_pypy3.10").to be_a_symlink
// 1375:     expect(installed_packages).to contain_exactly("setuptools", "pip")
// 1376:     expect(pypy).to be_loaded_from_api
// 1377:   end
// 1378:
// 1379:   specify "makes CPython venv activation script templates writable", :aggregate_failures do
// 1380:     script = root/"lib/venv/scripts/common/activate"
// 1381:     directory = root/"lib/venv/scripts/directory"
// 1382:     script.dirname.mkpath
// 1383:     directory.mkpath
// 1384:     script.write "activate"
// 1385:     FileUtils.chmod 0444, script
// 1386:     FileUtils.chmod 0555, directory
// 1387:
// 1388:     Homebrew::InstallSteps::Runner.new(context:).make_cpython_venv_activation_scripts_writable(root/"lib")
// 1389:
// 1390:     expect(script.stat.mode & 0200).to eq(0200)
// 1391:     expect(directory.stat.mode & 0200).to be_zero
// 1392:   end
// 1393:
// 1394:   describe "runs update_gtk_icon_cache rebuild action" do
// 1395:     let(:steps) do
// 1396:       Homebrew::InstallSteps::DSL.build do
// 1397:         update_gtk_icon_cache
// 1398:       end
// 1399:     end
// 1400:
// 1401:     it "with gtk4" do
// 1402:       stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 1403:       create_executable HOMEBREW_PREFIX/"opt/gtk4/bin/gtk4-update-icon-cache"
// 1404:       allow(Utils::Path).to receive(:formula_any_version_installed?).with("gtk4").and_return(true)
// 1405:       runner = Homebrew::InstallSteps::Runner.new(context:)
// 1406:       expect(runner).to receive(:run_command)
// 1407:         .with(root/"homebrew/opt/gtk4/bin/gtk4-update-icon-cache", "-q", "-t", "-f",
// 1408:               HOMEBREW_PREFIX/"share/icons/hicolor").ordered
// 1409:       runner.run(steps)
// 1410:     end
// 1411:
// 1412:     it "with gtk+3" do
// 1413:       stub_const("HOMEBREW_PREFIX", root/"homebrew")
// 1414:       create_executable HOMEBREW_PREFIX/"opt/gtk+3/bin/gtk3-update-icon-cache"
// 1415:       allow(Utils::Path).to receive(:formula_any_version_installed?).with("gtk4").and_return(false)
// 1416:       runner = Homebrew::InstallSteps::Runner.new(context:)
// 1417:       expect(runner).to receive(:run_command)
// 1418:         .with(root/"homebrew/opt/gtk+3/bin/gtk3-update-icon-cache", "-q", "-t", "-f",
// 1419:               HOMEBREW_PREFIX/"share/icons/hicolor").ordered
// 1420:       runner.run(steps)
// 1421:     end
// 1422:   end
// 1423:
// 1424:   specify "deletes matching keychain certificates by SHA-256 hash" do
// 1425:     steps = Homebrew::InstallSteps::DSL.build do
// 1426:       delete_keychain_certificates "Charles"
// 1427:     end
// 1428:
// 1429:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1430:     expect(runner).to receive(:run_command_output)
// 1431:       .with("/usr/bin/security", "find-certificate", "-a", "-c", "Charles", "-Z", sudo: true)
// 1432:       .and_return(<<~EOS)
// 1433:         SHA-256 hash: ABC123
// 1434:         SHA-256 hash: DEF456
// 1435:       EOS
// 1436:     expect(runner).to receive(:run_command)
// 1437:       .with("/usr/bin/security", "delete-certificate", "-Z", "ABC123", sudo: true).ordered
// 1438:     expect(runner).to receive(:run_command)
// 1439:       .with("/usr/bin/security", "delete-certificate", "-Z", "DEF456", sudo: true).ordered
// 1440:
// 1441:     runner.run(steps)
// 1442:   end
// 1443:
// 1444:   specify "only deletes the keychain certificate matching a local certificate" do
// 1445:     certificate = root/"home/Library/Application Support/betwixt/ssl/certs/ca.pem"
// 1446:     certificate.dirname.mkpath
// 1447:     certificate.write "certificate"
// 1448:     steps = Homebrew::InstallSteps::DSL.build do
// 1449:       delete_keychain_certificates "NodeMITMProxyCA", fingerprint_of: certificate
// 1450:     end
// 1451:
// 1452:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1453:     expect(runner).to receive(:run_command_output)
// 1454:       .with("/usr/bin/openssl", "x509", "-fingerprint", "-sha256", "-noout", "-in", certificate)
// 1455:       .and_return("sha256 Fingerprint=AB:CD:EF\n")
// 1456:     expect(runner).to receive(:run_command_output)
// 1457:       .with("/usr/bin/security", "find-certificate", "-a", "-c", "NodeMITMProxyCA", "-Z", sudo: true)
// 1458:       .and_return(<<~EOS)
// 1459:         SHA-256 hash: ABCDEF
// 1460:         SHA-256 hash: FEDCBA
// 1461:       EOS
// 1462:     expect(runner).to receive(:run_command)
// 1463:       .with("/usr/bin/security", "delete-certificate", "-Z", "ABCDEF", sudo: true)
// 1464:
// 1465:     runner.run(steps)
// 1466:   end
// 1467:
// 1468:   specify "skips keychain certificate deletion when a local certificate is missing" do
// 1469:     certificate = root/"missing.pem"
// 1470:     steps = Homebrew::InstallSteps::DSL.build do
// 1471:       delete_keychain_certificates "NodeMITMProxyCA", fingerprint_of: certificate
// 1472:     end
// 1473:
// 1474:     runner = Homebrew::InstallSteps::Runner.new(context:)
// 1475:     expect(runner).not_to receive(:run_command_output)
// 1476:     expect(runner).not_to receive(:run_command)
// 1477:
// 1478:     runner.run(steps)
// 1479:   end
// 1480:
// 1481:   specify "sets permissions and ownership for existing cask step paths" do
// 1482:     steps = Homebrew::InstallSteps::DSL.build(default_base: :staged_path) do
// 1483:       set_permissions ["Prepared.app", "Missing.app"], "0755"
// 1484:       set_permissions "Prepared.file", "0644", recursive: false
// 1485:       set_ownership "Owned.app", user: "root", group: "wheel"
// 1486:       set_ownership "Owned.file", user: "root", group: "wheel", recursive: false
// 1487:     end
// 1488:
// 1489:     command = class_double(SystemCommand)
// 1490:     (root/"stage/Prepared.app").mkpath
// 1491:     (root/"stage/Prepared.file").write ""
// 1492:     (root/"stage/Owned.app").mkpath
// 1493:     (root/"stage/Owned.file").write ""
// 1494:
// 1495:     allow(Cask::Quarantine).to receive(:app_management_permissions_granted?)
// 1496:       .with(app: root/"stage/Owned.app", command:)
// 1497:       .and_return(true)
// 1498:     allow(Cask::Quarantine).to receive(:app_management_permissions_granted?)
// 1499:       .with(app: root/"stage/Owned.file", command:)
// 1500:       .and_return(true)
// 1501:     expect(command).to receive(:run!)
// 1502:       .with("chmod", args: ["-R", "--", "0755", root/"stage/Prepared.app"], sudo: false).ordered
// 1503:     expect(command).to receive(:run!)
// 1504:       .with("chmod", args: ["--", "0644", root/"stage/Prepared.file"], sudo: false).ordered
// 1505:     expect(command).to receive(:run!)
// 1506:       .with("chown", args: ["-R", "--", "root:wheel", root/"stage/Owned.app"], sudo: true).ordered
// 1507:     expect(command).to receive(:run!)
// 1508:       .with("chown", args: ["--", "root:wheel", root/"stage/Owned.file"], sudo: true).ordered
// 1509:
// 1510:     Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 1511:   end
// 1512:
// 1513:   specify "raises when App Management permissions are missing for ownership steps" do
// 1514:     steps = Homebrew::InstallSteps::DSL.build(default_base: :staged_path) do
// 1515:       set_ownership "Owned.app"
// 1516:     end
// 1517:
// 1518:     command = class_double(SystemCommand)
// 1519:     (root/"stage/Owned.app").mkpath
// 1520:
// 1521:     allow(Cask::Quarantine).to receive(:app_management_permissions_granted?)
// 1522:       .with(app: root/"stage/Owned.app", command:)
// 1523:       .and_return(false)
// 1524:     expect(command).not_to receive(:run!)
// 1525:
// 1526:     expect { Homebrew::InstallSteps::Runner.new(context:, command:).run(steps) }
// 1527:       .to raise_error(Cask::CaskError, /App Management permissions/)
// 1528:   end
// 1529:
// 1530:   specify "does not add the default base to home paths" do
// 1531:     steps = Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 1532:       mkdir_p "~/example"
// 1533:     end
// 1534:
// 1535:     expect(steps).to contain_exactly(
// 1536:       "type" => "mkdir_p",
// 1537:       "path" => {
// 1538:         "path" => "~/example",
// 1539:       },
// 1540:     )
// 1541:   end
// 1542:
// 1543:   specify "moves a directory's children without moving the new target directory" do
// 1544:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :staged_path) do
// 1545:       move_children ".", "Nested"
// 1546:     end
// 1547:
// 1548:     (root/"stage").mkpath
// 1549:     (root/"stage/source-file").write "source"
// 1550:
// 1551:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 1552:
// 1553:     expect(root/"stage/Nested/source-file").to exist
// 1554:   end
// 1555:
// 1556:   specify "moves a directory's contents" do
// 1557:     steps = Homebrew::InstallSteps::DSL.build(default_source_base: :staged_path, default_target_base: :staged_path) do
// 1558:       move_contents ".", "Nested"
// 1559:     end
// 1560:     (root/"stage").mkpath
// 1561:     (root/"stage/source-file").write "source"
// 1562:
// 1563:     Homebrew::InstallSteps::Runner.new(context:).run(steps)
// 1564:
// 1565:     expect(root/"stage/Nested/source-file").to exist
// 1566:   end
// 1567:
// 1568:   specify "uses sudo only when an if-needed symlink target is not writable" do
// 1569:     steps = Homebrew::InstallSteps::DSL.build(default_target_base: :staged_path) do
// 1570:       symlink "target", "writable/linked-target", source_base: :relative, sudo: :if_needed
// 1571:       symlink "target", "protected/linked-target", source_base: :relative, sudo: :if_needed
// 1572:     end
// 1573:     protected_dir = root/"stage/protected"
// 1574:     (root/"stage/writable").mkpath
// 1575:     protected_dir.mkpath
// 1576:     FileUtils.chmod "-w", protected_dir
// 1577:     command = class_double(SystemCommand)
// 1578:     expect(command).to receive(:run!)
// 1579:       .with("/bin/ln", args: ["-s", "target", protected_dir/"linked-target"], sudo: true)
// 1580:
// 1581:     begin
// 1582:       Homebrew::InstallSteps::Runner.new(context:, command:).run(steps)
// 1583:     ensure
// 1584:       FileUtils.chmod "+w", protected_dir
// 1585:     end
// 1586:
// 1587:     expect(root/"stage/writable/linked-target").to be_a_symlink
// 1588:   end
// 1589:
// 1590:   specify "removes symlinks marked for uninstall" do
// 1591:     steps = Homebrew::InstallSteps::DSL.build(default_target_base: :staged_path) do
// 1592:       symlink "target", "linked-target", source_base: :relative, overwrite: true, remove_on_uninstall: true
// 1593:     end
// 1594:
// 1595:     (root/"stage").mkpath
// 1596:     File.symlink "target", root/"stage/linked-target"
// 1597:
// 1598:     Homebrew::InstallSteps::Runner.new(context:).run(steps, phase: :uninstall)
// 1599:
// 1600:     expect(root/"stage/linked-target").not_to be_a_symlink
// 1601:   end
// 1602:
// 1603:   specify "preserves symlinks with unexpected targets on uninstall" do
// 1604:     steps = Homebrew::InstallSteps::DSL.build(default_target_base: :staged_path) do
// 1605:       symlink "target", "linked-target", source_base: :relative, uninstall: true
// 1606:     end
// 1607:     (root/"stage").mkpath
// 1608:     File.symlink "different-target", root/"stage/linked-target"
// 1609:
// 1610:     Homebrew::InstallSteps::Runner.new(context:).run(steps, phase: :uninstall)
// 1611:
// 1612:     expect(root/"stage/linked-target").to be_a_symlink
// 1613:   end
// 1614:
// 1615:   specify "uses elevated removal for matching symlinks when needed" do
// 1616:     steps = Homebrew::InstallSteps::DSL.build(default_target_base: :staged_path) do
// 1617:       symlink "target", "protected/linked-target", source_base: :relative, uninstall: true, sudo: :if_needed
// 1618:     end
// 1619:     protected_dir = root/"stage/protected"
// 1620:     protected_dir.mkpath
// 1621:     target = protected_dir/"linked-target"
// 1622:     File.symlink "target", target
// 1623:     FileUtils.chmod "-w", protected_dir
// 1624:     command = class_double(SystemCommand)
// 1625:     expect(Cask::Utils).to receive(:gain_permissions_remove).with(target, command:)
// 1626:
// 1627:     begin
// 1628:       Homebrew::InstallSteps::Runner.new(context:, command:).run(steps, phase: :uninstall)
// 1629:     ensure
// 1630:       FileUtils.chmod "+w", protected_dir
// 1631:     end
// 1632:   end
// 1633:
// 1634:   specify "does not expose the surrounding formula or cask DSL" do
// 1635:     expect do
// 1636:       Homebrew::InstallSteps::DSL.build(default_base: :var) do
// 1637:         system "true"
// 1638:       end
// 1639:     end.to raise_error(NameError)
// 1640:   end
// 1641: end
