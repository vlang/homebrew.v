module readall

pub const min_files_per_worker = 4

pub enum SystemOs {
	macos
	linux
}

pub enum SystemArch {
	arm
	intel
}

pub struct SystemCombination {
pub:
	os   SystemOs
	arch SystemArch
}

pub struct RubyFile {
pub:
	path              string
	contents          string
	compiler_warnings []string
	syntax_error      string
}

pub struct AliasEntry {
pub:
	path    string
	name    string
	symlink bool
	file    bool
}

pub struct FormulaFile {
pub:
	path                string
	on_system_blocks    bool
	evaluation_error    string
	invalid_bottle_tags []string
}

pub struct FormulaEvaluation {
pub:
	on_system_blocks bool
}

pub struct CaskFile {
pub:
	path                  string
	supports_linux        bool
	sha256_by_arch        map[string]bool
	excluded_linux_arches []SystemArch
	evaluation_error      string
}

pub struct CaskEvaluation {
pub:
	supports_linux bool
	sha256         bool
	arch_excluded  bool
}

pub struct Tap {
pub:
	name             string
	alias_dir_exists bool
	aliases          []AliasEntry
	formula_files    []FormulaFile
	cask_files       []CaskFile
}

pub struct ValidationResult {
pub:
	valid        bool = true
	stdout       string
	stderr       string
	worker_count int = 1
	processed    []string
}

pub struct ParallelItem {
pub:
	name            string
	valid           bool = true
	stdout          string
	stderr          string
	unexpected_exit bool
}

pub struct State {
pub mut:
	warning_buffer_enabled bool
	warning_buffer         []string
	formula_cache          map[string][]string
}

pub fn new_state() State {
	return State{
		formula_cache: map[string][]string{}
	}
}

pub type SyntaxCompiler = fn(file RubyFile) ![]string

pub type FormulaEvaluator = fn(file FormulaFile, bottle_tag string) !FormulaEvaluation

pub type CaskEvaluator = fn(file CaskFile, arch SystemArch) !CaskEvaluation

pub fn compile_ruby_file(file RubyFile) ![]string {
	if file.syntax_error != '' {
		return error(file.syntax_error)
	}
	mut open_parentheses := 0
	for character in file.contents {
		if character == `(` {
			open_parentheses++
		} else if character == `)` {
			open_parentheses--
		}
	}
	if open_parentheses != 0 {
		return error('${file.path}: syntax error, unexpected end-of-input')
	}
	mut warnings := file.compiler_warnings.clone()
	for line in file.contents.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.contains(' = ') {
			name := trimmed.all_before(' = ').trim_space()
			if name != '' && name.bytes().all(it.is_letter() || it.is_digit() || it == `_`) {
				warnings << '${file.path}: warning: assigned but unused variable - ${name}\n'
			}
		}
	}
	return warnings
}

pub fn evaluate_formula_file(file FormulaFile, bottle_tag string) !FormulaEvaluation {
	if file.evaluation_error != '' {
		return error(file.evaluation_error)
	}
	if bottle_tag in file.invalid_bottle_tags {
		return error('formula is invalid for ${bottle_tag}')
	}
	return FormulaEvaluation{
		on_system_blocks: file.on_system_blocks
	}
}

pub fn evaluate_cask_file(file CaskFile, arch SystemArch) !CaskEvaluation {
	if file.evaluation_error != '' {
		return error(file.evaluation_error)
	}
	return CaskEvaluation{
		supports_linux: file.supports_linux
		sha256: file.sha256_by_arch[arch.str()]
		arch_excluded: arch in file.excluded_linux_arches
	}
}

pub fn warning(mut state State, message string) string {
	if state.warning_buffer_enabled {
		state.warning_buffer << message
		return ''
	}
	return message
}

pub fn set_warning_buffer(mut state State, enabled bool, messages []string) []string {
	state.warning_buffer_enabled = enabled
	state.warning_buffer = messages.clone()
	return state.warning_buffer.clone()
}

pub fn warning_buffer(state State) []string {
	return state.warning_buffer.clone()
}

fn worker_count_for(items int, cores int) int {
	if items == 0 {
		return 1
	}
	requested := items / min_files_per_worker
	workers := if cores < requested { cores } else { requested }
	return if workers > 1 { workers } else { 1 }
}

pub fn parallel_slices_valid(items []ParallelItem, cores int) ValidationResult {
	workers := worker_count_for(items.len, if cores > 0 { cores } else { 1 })
	slice_size := if workers > 0 { (items.len + workers - 1) / workers } else { items.len }
	mut valid := true
	mut stdout := ''
	mut stderr := ''
	mut processed := []string{}
	mut start := 0
	for start < items.len {
		end := if start + slice_size < items.len { start + slice_size } else { items.len }
		for item in items[start..end] {
			processed << item.name
			stdout += item.stdout
			stderr += item.stderr
			if item.unexpected_exit {
				stderr += 'Error: readall worker exited unexpectedly!\n'
				valid = false
			} else if !item.valid {
				valid = false
			}
		}
		start = end
	}
	return ValidationResult{
		valid: valid
		stdout: stdout
		stderr: stderr
		worker_count: workers
		processed: processed
	}
}

pub fn syntax_errors_or_warnings(file RubyFile, compiler SyntaxCompiler) ValidationResult {
	warnings := compiler(file) or {
		message := if err.msg().ends_with('\n') { err.msg() } else { '${err.msg()}\n' }
		return ValidationResult{
			valid: false
			stderr: message
			processed: [file.path]
		}
	}
	messages := warnings.filter(!it.contains('named capture conflicts a local variable')).join('')
	return ValidationResult{
		valid: messages.trim_space() == ''
		stderr: messages
		processed: [file.path]
	}
}

pub fn valid_ruby_syntax(files []RubyFile, cores int, compiler SyntaxCompiler) ValidationResult {
	mut items := []ParallelItem{cap: files.len}
	for file in files {
		checked := syntax_errors_or_warnings(file, compiler)
		items << ParallelItem{
			name: file.path
			valid: checked.valid
			stderr: checked.stderr
		}
	}
	return parallel_slices_valid(items, cores)
}

fn basename(path string) string {
	trimmed := path.trim_right('/')
	return trimmed.all_after_last('/')
}

pub fn valid_aliases(tap Tap) ValidationResult {
	if !tap.alias_dir_exists {
		return ValidationResult{}
	}
	formula_basenames := tap.formula_files.map(basename(it.path))
	mut valid := true
	mut stderr := ''
	mut processed := []string{}
	for alias_entry in tap.aliases {
		processed << alias_entry.path
		if !alias_entry.symlink {
			stderr += 'Error: Non-symlink alias: ${alias_entry.path}\n'
			valid = false
		} else if !alias_entry.file {
			stderr += 'Error: Non-file alias: ${alias_entry.path}\n'
			valid = false
		}
		alias_name := if alias_entry.name != '' {
			alias_entry.name
		} else {
			basename(alias_entry.path)
		}
		if '${alias_name}.rb' in formula_basenames {
			stderr += 'Error: Formula duplicating alias: ${alias_entry.path}\n'
			valid = false
		}
	}
	return ValidationResult{
		valid: valid
		stderr: stderr
		processed: processed
	}
}

pub fn valid_formulae(mut state State, tap Tap, bottle_tag string, files []FormulaFile,
	evaluator FormulaEvaluator) ValidationResult {
	mut valid := true
	mut stderr := ''
	mut processed := []string{}
	for file in files {
		cached_tags := state.formula_cache[file.path]
		if '*' in cached_tags || bottle_tag in cached_tags {
			continue
		}
		processed << file.path
		evaluation := evaluator(file, bottle_tag) or {
			stderr += 'Error: Invalid formula (${bottle_tag}): ${file.path}\n${err.msg()}\n'
			valid = false
			continue
		}
		if evaluation.on_system_blocks {
			mut updated := cached_tags.clone()
			if bottle_tag !in updated {
				updated << bottle_tag
			}
			state.formula_cache[file.path] = updated
		} else {
			state.formula_cache[file.path] = ['*']
		}
	}
	_ = tap
	return ValidationResult{
		valid: valid
		stderr: stderr
		processed: processed
	}
}

fn linux_label(arch ?SystemArch) string {
	if value := arch {
		return if value == .intel { 'Linux on Intel x86_64' } else { 'Linux on ARM64' }
	}
	return 'Linux'
}

pub fn valid_casks(tap Tap, os_name ?SystemOs, arch ?SystemArch, files []CaskFile,
	current_os SystemOs, current_arch SystemArch, evaluator CaskEvaluator) ValidationResult {
	validating_linux := if selected_os := os_name {
		selected_os == .linux
	} else {
		current_os == .linux
	}
	if !validating_linux {
		return ValidationResult{}
	}
	actual_arch := arch or { current_arch }
	mut valid := true
	mut stderr := ''
	mut processed := []string{}
	for file in files {
		processed << file.path
		evaluation := evaluator(file, actual_arch) or {
			stderr += 'Error: Invalid cask (${linux_label(arch)}): ${file.path}\n${err.msg()}\n'
			valid = false
			continue
		}
		if !evaluation.supports_linux || evaluation.arch_excluded || evaluation.sha256 {
			continue
		}
		stderr += 'Error: Invalid cask (${linux_label(arch)}): ${file.path}\n'
		stderr += 'Missing Linux stanzas can leave Linux `sha256` as nil. Add `depends_on :macos` if this cask is macOS-only or `depends_on arch:` if it does not support this architecture.\n'
		valid = false
	}
	_ = tap
	return ValidationResult{
		valid: valid
		stderr: stderr
		processed: processed
	}
}

pub struct TapValidationOptions {
pub:
	aliases              bool
	no_simulate          bool
	os_arch_combinations []SystemCombination
	cores                int = 1
	current_os           SystemOs = .macos
	current_arch         SystemArch = .arm
	formula_evaluator    FormulaEvaluator = evaluate_formula_file
	cask_evaluator       CaskEvaluator = evaluate_cask_file
}

pub fn valid_tap(mut state State, tap Tap, options TapValidationOptions) ValidationResult {
	mut valid := true
	mut stderr := ''
	mut stdout := ''
	mut processed := []string{}
	if options.aliases {
		aliases := valid_aliases(tap)
		valid = valid && aliases.valid
		stdout += aliases.stdout
		stderr += aliases.stderr
		processed << aliases.processed
	}
	mut combinations := options.os_arch_combinations.clone()
	if combinations.len == 0 {
		combinations = [SystemCombination{
			os: options.current_os
			arch: options.current_arch
		}]
	}
	if options.no_simulate {
		formulae := valid_formulae(mut state, tap, '', tap.formula_files, options.formula_evaluator)
		casks := valid_casks(tap, none, none, tap.cask_files, options.current_os, options.current_arch, options.cask_evaluator)
		valid = valid && formulae.valid && casks.valid
		stdout += formulae.stdout + casks.stdout
		stderr += formulae.stderr + casks.stderr
		processed << formulae.processed
		processed << casks.processed
	} else {
		for combination in combinations {
			tag := '${combination.os.str()}-${combination.arch.str()}'
			formulae := valid_formulae(mut state, tap, tag, tap.formula_files, options.formula_evaluator)
			casks := valid_casks(tap, combination.os, combination.arch, tap.cask_files, options.current_os, options.current_arch, options.cask_evaluator)
			valid = valid && formulae.valid && casks.valid
			stdout += formulae.stdout + casks.stdout
			stderr += formulae.stderr + casks.stderr
			processed << formulae.processed
			processed << casks.processed
		}
	}
	return ValidationResult{
		valid: valid
		stdout: stdout
		stderr: stderr
		worker_count: worker_count_for(tap.formula_files.len + tap.cask_files.len, if options.cores > 0 {
			options.cores} else {
			1})
		processed: processed
	}
}

pub fn all_system_combinations() []SystemCombination {
	return [
		SystemCombination{ os: .macos, arch: .arm },
		SystemCombination{ os: .macos, arch: .intel },
		SystemCombination{ os: .linux, arch: .arm },
		SystemCombination{ os: .linux, arch: .intel },
	]
}
