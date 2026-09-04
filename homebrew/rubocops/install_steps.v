module rubocops

import ruby
import homebrew.rubocops.@shared as install_steps_shared

// Translated from Homebrew/brew `rubocops/install_steps.rb`.
const formula_install_steps_conflict_message = '`post_install` and `post_install_steps` cannot both be used.'
const formula_install_steps_legacy_message = 'Formulae in official Homebrew taps must use `post_install_steps` instead of `post_install`.'
const formula_install_steps_explicit_base_message = 'Formula install-step paths must specify their base explicitly.'
const formula_install_steps_brew_ruby_message = 'Install steps must not use `brew ruby` because it enables developer mode.'
const formula_install_steps_simple_message = 'Use `post_install_steps` for simple file preparation.'

pub struct FormulaInstallStepsOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
}

pub struct FormulaInstallStepsAnalysis {
pub:
	source    string
	file_path string
	offenses  []FormulaInstallStepsOffense
	corrected string
}

struct FormulaInstallStepsEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

fn formula_install_steps_offense(begin_pos int, end_pos int, message string) FormulaInstallStepsOffense {
	return FormulaInstallStepsOffense{ begin_pos: begin_pos, end_pos: end_pos, message: message }
}

fn formula_install_steps_apply_edits(source string, edits []FormulaInstallStepsEdit) string {
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	mut result := source
	for edit in ordered {
		if edit.begin_pos < 0 || edit.end_pos < edit.begin_pos || edit.end_pos > result.len {
			continue
		}
		result = result[..edit.begin_pos] + edit.replacement + result[edit.end_pos..]
	}
	return result
}

fn formula_install_steps_remove_span(source string, span install_steps_shared.InstallStepSpan) string {
	mut begin := span.begin_pos
	for begin > 0 && source[begin - 1].is_space() {
		begin--
	}
	return source[..begin] + source[span.end_pos..]
}

fn formula_install_steps_class_name(source string) string {
	for line in source.split('\n') {
		trimmed := line.trim_space()
		if trimmed.starts_with('class ') {
			return trimmed[6..].all_before(' ').trim_space()
		}
	}
	return ''
}

fn formula_install_steps_string_value(expression string) ?string {
	trimmed := expression.trim_space()
	if trimmed.len < 2 {
		return none
	}
	quote := trimmed[0]
	if (quote != `"` && quote != `'`) || trimmed[trimmed.len - 1] != quote {
		return none
	}
	return trimmed[1..trimmed.len - 1]
}

fn formula_install_steps_explicit_expression(expression string) bool {
	trimmed := expression.trim_space()
	if trimmed.starts_with('[') && trimmed.ends_with(']') {
		items := trimmed[1..trimmed.len - 1].split(',')
		return items.len > 0 && items.all(formula_install_steps_string_value(it) != none && install_steps_shared.install_steps_explicit_formula_path(formula_install_steps_string_value(it) or {
			''
		}))
	}
	path := formula_install_steps_string_value(trimmed) or { return false }
	return install_steps_shared.install_steps_explicit_formula_path(path)
}

fn formula_install_steps_add_base(statement string) string {
	if statement.contains(', {}') {
		return statement.replace(', {}', ', base: :var')
	}
	if position := statement.index(' do') {
		return statement[..position] + ', base: :var' + statement[position..]
	}
	return statement.trim_right(' \t\n') + ', base: :var'
}

fn formula_install_steps_bare_symbol(source string) string {
	mut value := source.trim_space().trim_left(':')
	for separator in [',', ' ', '}', '\n'] {
		if index := value.index(separator) {
			value = value[..index]
		}
	}
	return value
}

fn formula_install_steps_implicit_analysis(source string) ([]FormulaInstallStepsOffense, string) {
	mut offenses := []FormulaInstallStepsOffense{}
	mut corrected := source
	base_methods := ['if_path_exists', 'unless_path_exists', 'mkdir', 'mkdir_p', 'touch', 'remove',
		'inreplace', 'write', 'write_file', 'init_data_dir', 'set_permissions']
	for statement in install_steps_shared.install_steps_all_statements(source, 'post_install_steps') {
		if statement.name in base_methods {
			argument := install_steps_shared.install_steps_first_argument(statement.source)
			if argument != '' && !formula_install_steps_explicit_expression(argument) && !statement.source.contains('base:') {
				offenses << formula_install_steps_offense(statement.begin_pos, statement.end_pos, formula_install_steps_explicit_base_message)
				corrected = corrected.replace(statement.source, formula_install_steps_add_base(statement.source))
			}
		} else if statement.name == 'run' {
			for keyword in ['stdin_path', 'stdout_path', 'chdir'] {
				marker := '${keyword}:'
				position := statement.source.index(marker) or { continue }
				rest := statement.source[position + marker.len..].trim_left(' \t')
				if rest.len < 2 || (rest[0] != `"` && rest[0] != `'`) {
					continue
				}
				quote := rest[0]
				end := rest.index_after(quote.ascii_str(), 1) or { continue }
				path := rest[1..end]
				if install_steps_shared.install_steps_explicit_formula_path(path) {
					continue
				}
				value_start := statement.begin_pos + position + marker.len + (statement.source[position + marker.len..].len - rest.len)
				offenses << formula_install_steps_offense(value_start, value_start + end + 1, formula_install_steps_explicit_base_message)
				corrected = corrected.replace('${keyword}: ${quote.ascii_str()}${path}${quote.ascii_str()}', '${keyword}: "{{var}}/${path}"')
			}
		}
	}
	return offenses, corrected
}

fn formula_install_steps_simple_lines(source string) ?[]string {
	statements := install_steps_shared.install_steps_direct_statements(source, 'post_install')
	if statements.len == 0 {
		return none
	}
	mut lines := []string{}
	for statement in statements {
		if statement.source.contains('.atomic_write <<~') {
			position := statement.source.index('.atomic_write ') or { return none }
			path := install_steps_shared.install_steps_parse_path(statement.source[..position]) or {
				return none
			}
			if install_steps_shared.install_steps_relative_path(path) {
				return none
			}
			first_line := statement.source.all_before('\n')
			heredoc := first_line[position + '.atomic_write '.len..]
			mut line := 'write_file ${install_steps_shared.install_steps_path_source(path)}, ${heredoc}${install_steps_shared.install_steps_path_keywords(path, 'var', 'base')}'
			if statement.source.contains('\n') {
				line += '\n' + statement.source.all_after('\n')
			}
			lines << line
			continue
		}
		line := install_steps_shared.install_steps_simple_line(statement.source, 'var', 'prefix', 'prefix', true) or { return none }
		lines << line
	}
	return lines
}

fn formula_install_steps_service_paths(source string) []install_steps_shared.InstallStepPath {
	mut paths := []install_steps_shared.InstallStepPath{}
	for statement in install_steps_shared.install_steps_direct_statements(source, 'service') {
		if statement.name !in ['working_dir', 'root_dir', 'input_path', 'log_path', 'error_log_path'] {
			continue
		}
		argument := install_steps_shared.install_steps_first_argument(statement.source)
		mut path := install_steps_shared.install_steps_parse_path(argument) or { continue }
		if statement.name in ['input_path', 'log_path', 'error_log_path'] {
			path = install_steps_shared.install_steps_path_parent(path) or { continue }
		}
		if !paths.any(install_steps_shared.install_steps_paths_match(it, path)) {
			paths << path
		}
	}
	return paths
}

fn formula_install_steps_statement_path(statement install_steps_shared.InstallStepSpan,
	block_name string) ?install_steps_shared.InstallStepPath {
	if block_name == 'post_install' {
		normalised := install_steps_shared.install_steps_normalised_source(statement.source)
		if !normalised.ends_with('.mkpath') {
			return none
		}
		return install_steps_shared.install_steps_parse_path(normalised[..normalised.len - '.mkpath'.len])
	}
	if statement.name !in ['mkdir', 'mkdir_p'] {
		return none
	}
	path := install_steps_shared.install_steps_parse_path(install_steps_shared.install_steps_first_argument(statement.source)) or {
		return none
	}
	if path.base == '' && !install_steps_shared.install_steps_absolute_path(path) {
		base := if statement.source.contains('base:') {
			formula_install_steps_bare_symbol(statement.source.all_after('base:'))
		} else {
			'var'
		}
		return install_steps_shared.InstallStepPath{
			path: path.path
			base: base
		}
	}
	return path
}

fn formula_install_steps_redundant(source string, block_name string,
	service_paths []install_steps_shared.InstallStepPath) bool {
	statements := install_steps_shared.install_steps_direct_statements(source, block_name)
	if statements.len == 0 || service_paths.len == 0 {
		return false
	}
	for statement in statements {
		path := formula_install_steps_statement_path(statement, block_name) or { return false }
		if !service_paths.any(install_steps_shared.install_steps_paths_match(path, it)) {
			return false
		}
	}
	return true
}

fn formula_install_steps_special_conversion(source string, class_name string,
	post install_steps_shared.InstallStepSpan, steps ?install_steps_shared.InstallStepSpan) ?string {
	normalised := install_steps_shared.install_steps_normalised_source(post.source)
	mut step_lines := []string{}
	mut remaining := ''
	mut removable_names := []string{}
	if normalised.contains('(var/"log").mkpath') && normalised.contains('postgresql_datadir.mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"initdb"') && source.contains('def postgresql_datadir') && source.contains('def pg_version_exists?') {
		step_lines << 'mkdir_p "log", base: :var'
		if normalised.contains('%w[include lib share].each') {
			step_lines << [
				'symlink_tree "include/postgresql", "include/{{formula_name}}"',
				'symlink_tree "lib/postgresql", "lib/{{formula_name}}"',
				'symlink_tree "share/postgresql", "share/{{formula_name}}"',
			]
		}
		if normalised.contains('bin.each_child') {
			step_lines << 'symlink_children "bin", suffix: "-{{version.major}}"'
		}
		init := if normalised.contains('--locale=C') {
			'init_data_dir formula_name, using: :postgresql, base: :var, locale: "C"'
		} else {
			'init_data_dir formula_name, using: :postgresql, base: :var'
		}
		step_lines << init
		remaining = post.source.split('\n').filter(it.trim_space().starts_with('opoo ')).join('\n')
		removable_names << 'pg_version_exists?'
	} else if (class_name == 'Mysql' || (class_name.starts_with('MysqlAT') && class_name['MysqlAT'.len..].bytes().all(it.is_digit()))) && normalised.contains('(var/"mysql").mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"mysqld", "--initialize-insecure"') && source.contains('def datadir') {
		step_lines << 'init_data_dir "mysql", using: :mysql, base: :var'
		if normalised.contains('if File.exist? "/etc/my.cnf"') {
			remaining = 'if File.exist? "/etc/my.cnf"\n    opoo "existing configuration"\n  end'
		}
	} else if normalised.contains('(var/"mysql").mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"mysql_install_db", "--verbose"') {
		step_lines << 'init_data_dir "mysql", using: :mariadb, base: :var'
	} else if normalised.contains('rm(pkgetc/"cert.pem") if (pkgetc/"cert.pem").exist?') && normalised.contains('pkgetc.install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"') {
		step_lines << 'symlink "cert.pem", "cert.pem",\n        source_formula: "ca-certificates",\n        source_base: :formula_pkgetc,\n        target_base: :pkgetc,\n        overwrite: true'
		remaining = post.source.split('\n').filter(it.trim_space().starts_with('opoo ')).join('\n')
	} else {
		return none
	}
	mut corrected := source
	if existing := steps {
		updated := install_steps_shared.install_steps_append_lines(existing.source, step_lines, existing.indent)
		corrected = corrected.replace(existing.source, updated)
	} else {
		block := install_steps_shared.install_steps_block_source('post_install_steps', step_lines, post.indent)
		corrected = corrected[..post.begin_pos] + block + '\n\n' + ' '.repeat(post.indent) + corrected[post.begin_pos..]
	}
	if remaining == '' {
		current_post := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
			return corrected
		}
		corrected = formula_install_steps_remove_span(corrected, current_post)
	} else {
		current_post := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
			return corrected
		}
		body := remaining.split('\n').map(' '.repeat(current_post.indent + 2) + it.trim_space()).join('\n')
		replacement := 'def post_install\n${body}\n${' '.repeat(current_post.indent)}end'
		corrected = corrected[..current_post.begin_pos] + replacement + corrected[current_post.end_pos..]
	}
	for method in removable_names {
		if removable := install_steps_shared.install_steps_find_block(corrected, method) {
			corrected = formula_install_steps_remove_span(corrected, removable)
		}
	}
	return corrected
}

pub fn analyze_formula_install_steps(source string, file_path string) FormulaInstallStepsAnalysis {
	mut offenses := []FormulaInstallStepsOffense{}
	mut corrected := source
	steps := install_steps_shared.install_steps_find_block(source, 'post_install_steps')
	post := install_steps_shared.install_steps_find_block(source, 'post_install')
	service_paths := formula_install_steps_service_paths(source)
	if step_block := steps {
		if post != none {
			offenses << formula_install_steps_offense(step_block.begin_pos, step_block.end_pos, formula_install_steps_conflict_message)
		}
		compatibility := install_steps_shared.install_steps_compatibility_analysis(corrected, 'post_install_steps', install_steps_shared.install_steps_allowed_methods())
		for offense in compatibility.offenses {
			offenses << formula_install_steps_offense(offense.begin_pos, offense.end_pos, offense.message)
		}
		corrected = compatibility.corrected
		if brew_offense := install_steps_shared.install_steps_brew_ruby_offense(source, 'post_install_steps') {
			offenses << formula_install_steps_offense(brew_offense.begin_pos, brew_offense.end_pos, formula_install_steps_brew_ruby_message)
		} else if block_offense := install_steps_shared.install_steps_block_offense_for(source, 'post_install_steps', install_steps_shared.install_steps_allowed_methods()) {
			offenses << formula_install_steps_offense(block_offense.begin_pos, block_offense.end_pos, install_steps_shared.install_steps_step_block_message(install_steps_shared.install_steps_allowed_methods()))
		} else {
			implicit_offenses, implicit_corrected := formula_install_steps_implicit_analysis(corrected)
			offenses << implicit_offenses
			corrected = implicit_corrected
		}
	}
	mut redundant_post := false
	if post_block := post {
		if formula_install_steps_redundant(source, 'post_install', service_paths) {
			redundant_post = true
			offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, '`post_install` only creates directories created by `brew services`.')
			current := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
				post_block
			}
			corrected = formula_install_steps_remove_span(corrected, current)
		}
	}
	if step_block := steps {
		if formula_install_steps_redundant(source, 'post_install_steps', service_paths) {
			offenses << formula_install_steps_offense(step_block.begin_pos, step_block.end_pos, '`post_install_steps` only creates directories created by `brew services`.')
			current := install_steps_shared.install_steps_find_block(corrected, 'post_install_steps') or { step_block }
			corrected = formula_install_steps_remove_span(corrected, current)
		}
	}
	mut converted := false
	if !redundant_post {
		if post_block := post {
			step_after_post := if step_block := steps {
				step_block.begin_pos > post_block.begin_pos
			} else {
				false
			}
			if !step_after_post {
				if special := formula_install_steps_special_conversion(corrected, formula_install_steps_class_name(source), post_block, steps) {
					converted = true
					corrected = special
					offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_simple_message)
				} else if steps == none {
					if step_lines := formula_install_steps_simple_lines(source) {
						converted = true
						block := install_steps_shared.install_steps_block_source('post_install_steps', step_lines, post_block.indent)
						corrected = corrected.replace(post_block.source, block)
						offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_simple_message)
					}
				}
			}
		}
	}
	if post_block := post {
		if install_steps_shared.install_steps_official_homebrew_tap(file_path) && !converted && !redundant_post {
			offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_legacy_message)
		}
	}
	return FormulaInstallStepsAnalysis{ source: source, file_path: file_path, offenses: offenses, corrected: corrected }
}

fn formula_install_steps_offense_value(offense FormulaInstallStepsOffense) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::Offense'
		repr: offense.message
		map_data: {
			'message': ruby.string_value(offense.message)
		}
		attributes: {
			'begin_pos': offense.begin_pos.str()
			'end_pos':   offense.end_pos.str()
		}
	}
}

fn formula_install_steps_analysis_value(analysis FormulaInstallStepsAnalysis) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::FormulaAudit::InstallSteps::Analysis'
		repr: analysis.source
		array_data: analysis.offenses.map(formula_install_steps_offense_value(it))
		map_data: {
			'offenses':  ruby.array_value(analysis.offenses.map(formula_install_steps_offense_value(it)))
			'corrected': ruby.string_value(analysis.corrected)
		}
	}
}

fn formula_install_steps_args(args []ruby.Value) (string, string) {
	source := if args.len > 0 { args[0].as_string() } else { 'class Foo < Formula\nend\n' }
	path := if args.len > 1 { args[1].as_string() } else { '' }
	return source, path
}

fn formula_install_steps_path_value(path install_steps_shared.InstallStepPath) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::InstallStepsHelper::InstallStepPath'
		repr: install_steps_shared.install_steps_path_source(path)
		map_data: {
			'path':   ruby.string_value(path.path)
			'base':   ruby.string_value(path.base)
			'source': ruby.string_value(path.source)
		}
	}
}

fn formula_install_steps_path_arg(value ruby.Value) ?install_steps_shared.InstallStepPath {
	if value.type_name == 'RuboCop::Cop::InstallStepsHelper::InstallStepPath' {
		return install_steps_shared.InstallStepPath{
			path: (value.map_data['path'] or { ruby.string_value('') }).as_string()
			base: (value.map_data['base'] or { ruby.string_value('') }).as_string()
			source: (value.map_data['source'] or { ruby.string_value('') }).as_string()
		}
	}
	return install_steps_shared.install_steps_parse_path(value.as_string())
}
