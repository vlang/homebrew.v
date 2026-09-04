module methods

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/_methods.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct RuntimeDeclarationBlock {
pub mut:
	mod         ruby.Value
	method_name string
	location    string
	blk_or_decl ruby.Value
	final_      bool
	abstract_   bool
	override_   string
	overridable bool
}

@[heap]
struct MethodsRuntimeRegistry {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	installed_hooks       map[string]bool
	signatures_by_method  map[string]ruby.Value
	sig_wrappers          map[string]ruby.Value
	sigs_that_raised      map[string]bool
	was_ever_final_names  map[string]bool
	modules_with_final    map[string]map[string]bool
	active_declaration    ruby.Value
	previous_declaration  ruby.Value
	final_checks_on_hooks bool
}

fn methods_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn new_methods_runtime_registry() &MethodsRuntimeRegistry {
	return &MethodsRuntimeRegistry{
		active_declaration: methods_nil()
		previous_declaration: methods_nil()
	}
}

const methods_runtime_registry_global = new_methods_runtime_registry()

fn methods_runtime_registry() &MethodsRuntimeRegistry {
	return unsafe { &MethodsRuntimeRegistry(methods_runtime_registry_global) }
}

fn declaration_block_value(block &RuntimeDeclarationBlock) ruby.Value {
	return ruby.Value{
		type_name: 'T::Private::Methods::DeclarationBlock'
		repr: '${block.mod.as_string()}#${block.method_name}'
		map_data: {
			'mod':         block.mod
			'blk_or_decl': block.blk_or_decl
		}
		attributes: {
			'declaration_block_address': u64(voidptr(block)).str()
			'method_name':               block.method_name
			'location':                  block.location
			'final':                     block.final_.str()
			'abstract':                  block.abstract_.str()
			'override':                  block.override_
			'overridable':               block.overridable.str()
		}
	}
}

fn declaration_block_from_value(value ruby.Value) &RuntimeDeclarationBlock {
	address := value.attribute('declaration_block_address') or { panic('invalid DeclarationBlock value') }
	return unsafe { &RuntimeDeclarationBlock(voidptr(address.u64())) }
}

fn module_identity(mod ruby.Value) string {
	return mod.attribute('object_id') or { mod.as_string() }
}

pub fn method_owner_and_name_key(owner ruby.Value, name string) string {
	return '${module_identity(owner)}#${name.trim_string_left(':')}'
}

pub fn method_value_key(method ruby.Value) string {
	owner := method.map_data['owner'] or {
		ruby.object_value('Module', method.attribute('owner') or { '<unknown>' })
	}
	return method_owner_and_name_key(owner, method.attribute('name') or { method.as_string() })
}

pub fn declare_runtime_signature(mod ruby.Value, location string, argument string,
	block_value ruby.Value) !ruby.Value {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	defer { registry.mutex.unlock() }
	if registry.active_declaration.type_name != 'NilClass' {
		registry.active_declaration = methods_nil()
		registry.previous_declaration = methods_nil()
		return error('You called sig twice without declaring a method in between')
	}
	clean_argument := argument.trim_string_left(':')
	if clean_argument != '' && clean_argument != 'nil' && clean_argument != 'final' {
		return error('Invalid argument to `sig`: ${argument}')
	}
	block := &RuntimeDeclarationBlock{
		mod: mod
		location: location
		blk_or_decl: block_value
		final_: clean_argument == 'final'
	}
	value := declaration_block_value(block)
	registry.active_declaration = value
	return methods_nil()
}

fn previous_runtime_declaration(mod ruby.Value, method_name string,
	dsl_name string) !&RuntimeDeclarationBlock {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	value := registry.previous_declaration
	registry.mutex.unlock()
	if value.type_name == 'NilClass' {
		return error('You must declare a `sig` before using `${dsl_name}` on the method `${method_name}`')
	}
	block := declaration_block_from_value(value)
	if block.blk_or_decl.type_name != 'Proc' && block.blk_or_decl.type_name != 'T::Private::Methods::SignatureThunk' {
		return error('Cannot call `${dsl_name} ${method_name}`, because the sig block has already run')
	}
	mod_matches := module_identity(block.mod) == module_identity(mod) || block.mod.attribute('singleton_of') or { '' } == module_identity(mod)
	if !mod_matches || block.method_name != method_name {
		return error("Can only call `${dsl_name} ${method_name}` for the previously sig'd method. Expected: ${block.mod.as_string()}#${block.method_name}")
	}
	return block
}

pub fn add_runtime_final_method(mod ruby.Value, method_name string) {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	clean_name := method_name.trim_string_left(':')
	registry.was_ever_final_names[clean_name] = true
	key := module_identity(mod)
	mut methods := (registry.modules_with_final[key] or { map[string]bool{} }).clone()
	methods[clean_name] = true
	registry.modules_with_final[key] = methods.clone()
	registry.mutex.unlock()
}

fn module_ancestors(mod ruby.Value) []string {
	return mod.attribute('ancestors') or { mod.as_string() }.split(',').map(it.trim_space()).filter(it != '')
}

pub fn check_runtime_final_ancestors(target ruby.Value, source_method_names []string,
	source ruby.Value) !bool {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	modules_with_final := registry.modules_with_final.clone()
	registry.mutex.unlock()
	source_ancestors := if source.type_name == 'NilClass' {
		[]string{}
	} else {
		module_ancestors(source)
	}
	mut found_error := false
	for ancestor in module_ancestors(target).reverse() {
		final_methods := (modules_with_final[ancestor] or { continue }).clone()
		for method_name in source_method_names {
			if !(final_methods[method_name] or { false }) {
				continue
			}
			if source_ancestors.len > 0 {
				matching := source_ancestors.filter((modules_with_final[it] or { map[string]bool{} })[method_name] or { false })
				if matching.len > 0 && matching[0] == ancestor {
					continue
				}
			}
			found_error = true
		}
	}
	return !found_error
}

pub fn consume_runtime_method_added(hook_mod ruby.Value, mod ruby.Value,
	method_name string, original_method ruby.Value) !ruby.Value {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	current_value := registry.active_declaration
	registry.previous_declaration = current_value
	registry.active_declaration = methods_nil()
	registry.mutex.unlock()
	is_final_module := mod.attribute('final_module') or { 'false' } == 'true'
	if is_final_module && (current_value.type_name == 'NilClass' || !declaration_block_from_value(current_value).final_) {
		return error('${mod.as_string()} was declared as final but its method `${method_name}` was not declared as final')
	}
	if current_value.type_name == 'NilClass' {
		return methods_nil()
	}
	mut declaration := declaration_block_from_value(current_value)
	declaration.method_name = method_name
	if method_name in ['method_added', 'singleton_method_added'] {
		return error('Putting a `sig` on `${method_name}` is not supported (sorbet-runtime uses this method internally to perform `sig` validation logic)')
	}
	mod_matches := module_identity(hook_mod) == module_identity(declaration.mod) || hook_mod.attribute('singleton_id') or { '' } == module_identity(declaration.mod) || declaration.mod.as_string() == 'main'
	if !mod_matches {
		return error('A method (${method_name}) is being added on a different class/module (${hook_mod.as_string()}) than the last call to `sig` (${declaration.mod.as_string()}).')
	}
	declaration.mod = mod
	key := method_owner_and_name_key(mod, method_name)
	wrapper := ruby.Value{
		type_name: 'T::Private::Methods::SignatureThunk'
		repr: key
		map_data: {
			'declaration_block': current_value
			'original_method':   original_method
		}
		attributes: {
			'method_name': method_name
		}
	}
	registry.mutex.lock()
	registry.sig_wrappers[key] = wrapper
	registry.mutex.unlock()
	if declaration.final_ {
		add_runtime_final_method(mod, method_name)
	}
	return wrapper
}

fn declaration_from_block(block &RuntimeDeclarationBlock) !&SignatureDeclaration {
	if block.blk_or_decl.type_name == 'T::Private::Methods::Declaration' {
		return declaration_from_value(block.blk_or_decl)
	}
	mut result := block.blk_or_decl.map_data['declaration'] or {
		block.blk_or_decl.map_data['result'] or { return error('SignatureThunk requires a translated `declaration` result because ruby.Value cannot execute Ruby blocks') }
	}
	if result.type_name == 'T::Private::Methods::DeclBuilder' {
		mut builder := declaration_builder_from_args([result])
		if block.abstract_ {
			builder.set_abstract()!
		}
		if block.override_ != '' {
			builder.set_override(block.override_)!
		}
		if block.overridable {
			builder.set_overridable()!
		}
		builder.finalize()!
		result = declaration_value(builder.decl)
	}
	if result.type_name != 'T::Private::Methods::Declaration' {
		return error('signature thunk result must be a Declaration or DeclBuilder')
	}
	mut mutable_block := unsafe { &RuntimeDeclarationBlock(block) }
	mutable_block.blk_or_decl = result
	return declaration_from_value(result)
}

pub fn build_runtime_signature(method_name string, original_method ruby.Value,
	declaration &SignatureDeclaration) &RuntimeMethodSignature {
	raw_args := declaration.params.as_map() or { map[string]ruby.Value{} }
	parameters := signature_parameters_from_method(original_method)
	return new_runtime_method_signature(original_method, method_name, raw_args, declaration.returns, declaration.bind, declaration.mode, declaration.checked, declaration.on_failure, parameters, declaration.override_allow_incompatible, declaration.raw) or {
		new_untyped_runtime_method_signature(original_method, 'untyped', parameters) or { panic(err) }
	}
}

pub fn run_runtime_signature(method_name string, original_method ruby.Value,
	block &RuntimeDeclarationBlock) !ruby.Value {
	declaration := declaration_from_block(block)!
	signature := build_runtime_signature(method_name, original_method, declaration)
	value := runtime_signature_value(signature)
	key := method_value_key(original_method)
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	registry.signatures_by_method[key] = value
	registry.sig_wrappers.delete(key)
	registry.mutex.unlock()
	mut mutable_block := unsafe { &RuntimeDeclarationBlock(block) }
	mutable_block.location = ''
	mutable_block.blk_or_decl = methods_nil()
	return value
}

pub fn run_runtime_signature_for_key(key string, force_type_init bool) !ruby.Value {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	wrapper := registry.sig_wrappers[key] or {
		signature := registry.signatures_by_method[key] or {
			registry.mutex.unlock()
			return error('No `sig` wrapper for ${key}. This is likely a bug in sorbet-runtime.')
		}
		registry.mutex.unlock()
		return signature
	}
	registry.mutex.unlock()
	block_value := wrapper.map_data['declaration_block'] or { return error('invalid signature wrapper') }
	original_method := wrapper.map_data['original_method'] or { return error('invalid signature wrapper method') }
	block := declaration_block_from_value(block_value)
	value := run_runtime_signature(block.method_name, original_method, block) or {
		registry.mutex.lock()
		registry.sigs_that_raised[key] = true
		registry.mutex.unlock()
		return err
	}
	registry.mutex.lock()
	previously_raised := registry.sigs_that_raised[key] or { false }
	registry.mutex.unlock()
	if previously_raised {
		return error("A previous invocation of ${value.as_string()} raised, and the current one succeeded. Please don't do that.")
	}
	if force_type_init && value.attribute('runtime_signature_address') or { '' } != '' {
		mut signature := runtime_signature_from_value(value)
		signature.types_built = true
	}
	return value
}

pub fn run_all_runtime_signatures(force_type_init bool) ! {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	if registry.active_declaration.type_name != 'NilClass' {
		pending := declaration_block_from_value(registry.active_declaration)
		registry.active_declaration = methods_nil()
		registry.previous_declaration = methods_nil()
		registry.mutex.unlock()
		return error('Cannot call `run_all_sig_blocks` while there is a pending `sig` block in ${pending.mod.as_string()} at ${pending.location}')
	}
	registry.mutex.unlock()
	for {
		registry.mutex.lock()
		keys := registry.sig_wrappers.keys()
		registry.mutex.unlock()
		if keys.len == 0 {
			break
		}
		run_runtime_signature_for_key(keys[0], force_type_init)!
	}
	registry.mutex.lock()
	registry.active_declaration = methods_nil()
	registry.previous_declaration = methods_nil()
	registry.mutex.unlock()
}

fn signature_for_runtime_key(key string) ?ruby.Value {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	has_wrapper := key in registry.sig_wrappers
	registry.mutex.unlock()
	if has_wrapper {
		return run_runtime_signature_for_key(key, false) or { return none }
	}
	registry.mutex.lock()
	value := registry.signatures_by_method[key] or {
		registry.mutex.unlock()
		return none
	}
	registry.mutex.unlock()
	return value
}

fn wrapper_has_key(key string) bool {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	defer { registry.mutex.unlock() }
	return key in registry.sig_wrappers
}

fn methods_bool_arg(value ruby.Value) bool {
	return value.as_bool() or { value.as_string() in ['true', ':true'] }
}

// Ruby method `self.declare_sig(mod, loc, arg, &blk)` at line 53.
pub fn ruby_methods_l53_d1_self_declare_sig(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.declare_sig requires mod and location') }
	argument := if args.len > 2 { args[2].as_string() } else { 'nil' }
	block_value := if args.len > 3 { args[3] } else { ruby.object_value('Proc', '#<Proc>') }
	return declare_runtime_signature(args[0], args[1].as_string(), argument, block_value) or { panic(err) }
}

// Ruby method `self.ensure_valid_declare_dsl!(mod, method_name, dsl_name)` at line 72.
pub fn ruby_methods_l72_d2_self_ensure_valid_declare_dsl(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Methods.ensure_valid_declare_dsl! requires mod, method_name, and DSL name')
	}
	return declaration_block_value(previous_runtime_declaration(args[0], args[1].as_string().trim_string_left(':'), args[2].as_string().trim_string_left(':')) or { panic(err) })
}

// Ruby method `self.declare_abstract(mod, method_name)` at line 97.
pub fn ruby_methods_l97_d3_self_declare_abstract(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.declare_abstract requires mod and method_name') }
	mut block := previous_runtime_declaration(args[0], args[1].as_string().trim_string_left(':'), 'abstract') or { panic(err) }
	if block.abstract_ { panic('Cannot call `abstract` twice for the method `${block.method_name}`') }
	block.abstract_ = true
	return methods_nil()
}

// Ruby method `self.declare_override(mod, method_name, allow_incompatible:)` at line 122.
pub fn ruby_methods_l122_d4_self_declare_override(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.declare_override requires mod and method_name') }
	method_name := args[1].as_string().trim_string_left(':')
	mut block := previous_runtime_declaration(args[0], method_name, 'override') or { panic(err) }
	if block.override_ != '' { panic('Cannot call `override` twice for the method `${method_name}`') }
	allow := if args.len > 2 { args[2].as_string().trim_string_left(':') } else { 'false' }
	block.override_ = allow
	return methods_nil()
}

// Ruby method `self.declare_final(mod, method_name)` at line 142.
pub fn ruby_methods_l142_d5_self_declare_final(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.declare_final requires mod and method_name') }
	method_name := args[1].as_string().trim_string_left(':')
	mut block := previous_runtime_declaration(args[0], method_name, 'final') or { panic(err) }
	if block.final_ {
		panic('Cannot declare `${method_name}` final twice (from `sig(:final)` nor `final def`)')
	}
	block.final_ = true
	add_runtime_final_method(block.mod, method_name)
	return methods_nil()
}

// Ruby method `self.declare_overridable(mod, method_name)` at line 160.
pub fn ruby_methods_l160_d6_self_declare_overridable(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.declare_overridable requires mod and method_name') }
	method_name := args[1].as_string().trim_string_left(':')
	mut block := previous_runtime_declaration(args[0], method_name, 'overridable') or { panic(err) }
	if block.overridable { panic('Cannot call `overridable` twice for the method `${method_name}`') }
	block.overridable = true
	return methods_nil()
}

// Ruby method `self.start_proc` at line 173.
pub fn ruby_methods_l173_d7_self_start_proc(args ...ruby.Value) ruby.Value {
	return declaration_builder_value(new_declaration_builder(ruby.object_value('T::Private::Methods::PROC_TYPE', 'PROC_TYPE'), false, '', false) or { panic(err) })
}

// Ruby method `self.finalize_proc(decl)` at line 181.
pub fn ruby_methods_l181_d8_self_finalize_proc(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.finalize_proc requires a Declaration') }
	mut declaration := declaration_from_value(args[0])
	declaration.finalized = true
	if declaration.mode != 'standard' { panic('Procs cannot have override/abstract modifiers') }
	if declaration.mod.type_name != 'T::Private::Methods::PROC_TYPE' {
		panic('You are passing a DeclBuilder as a type. Did you accidentally use `self` inside a `sig` block? Perhaps you wanted the `T.self_type` instead: https://sorbet.org/docs/self-type')
	}
	if declaration_is_missing(declaration.returns) { panic('Procs must specify a return type') }
	if !declaration_is_missing(declaration.on_failure) { panic('Procs cannot use .on_failure') }
	if declaration_is_missing(declaration.params) {
		declaration.params = ruby.map_value({})
	}
	return ruby.Value{
		type_name: 'T::Types::Proc'
		repr: 'T.proc'
		map_data: {
			'params':  declaration.params
			'returns': declaration.returns
		}
	}
}

// Ruby method `self._check_final_ancestors(target, source_method_names, source)` at line 220.
pub fn ruby_methods_l220_d9_self_check_final_ancestors(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods._check_final_ancestors requires target and method names') }
	names := args[1].as_string_array() or { args[1].as_array() or { []ruby.Value{} }.map(it.as_string().trim_string_left(':')) }
	source := if args.len > 2 { args[2] } else { methods_nil() }
	return ruby.bool_value(check_runtime_final_ancestors(args[0], names, source) or { panic(err) })
}

// Ruby method `self.add_module_with_final_method(mod, method_name)` at line 287.
pub fn ruby_methods_l287_d10_self_add_module_with_final_method(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.add_module_with_final_method requires module and method name') }
	add_runtime_final_method(args[0], args[1].as_string())
	return methods_nil()
}

// Ruby method `self._on_method_added(hook_mod, mod, method_name)` at line 301.
pub fn ruby_methods_l301_d11_self_on_method_added(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('Methods._on_method_added requires hook module, module, and method name') }
	name := args[2].as_string().trim_string_left(':')
	original := if args.len > 3 {
		args[3]
	} else {
		ruby.Value{
			type_name: 'UnboundMethod'
			repr: name
			map_data: {
				'owner': args[1]
			}
			attributes: {
				'name':            name
				'parameter_kinds': ''
				'parameter_names': ''
			}
		}
	}
	return consume_runtime_method_added(args[0], args[1], name, original) or { panic(err) }
}

// Ruby alias_method `"This should only be executed if you used `alias_method` to grab a handle to a method after `sig`ing it, but that clearly isn't what you are doing. " \` at line 366.
pub fn ruby_methods_l366_d12_alias_method_dynamic(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('T::Private::Methods::AliasLookup', if args.len > 0 {
		args.last().as_string()
	} else {
		''
	}, {
		'optimized': 'false'
	})
}

// Ruby method `self._unwrap_alias(method_sig, receiver, original_method, callee)` at line 403.
pub fn ruby_methods_l403_d13_self_unwrap_alias(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Methods._unwrap_alias requires signature, receiver, original method, and callee')
	}
	callee := args[3].as_string().trim_string_left(':')
	if args[0].attribute('runtime_signature_address') or { '' } != '' {
		signature := runtime_signature_from_value(args[0])
		if callee != signature.method_name {
			mut alias_signature := &RuntimeMethodSignature{ ...signature, method_name: callee }
			return runtime_signature_value(alias_signature)
		}
	}
	return args[0]
}

// Ruby method `self.run_sig(method_name, original_method, declaration_block)` at line 435.
pub fn ruby_methods_l435_d14_self_run_sig(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Methods.run_sig requires method name, original method, and declaration block')
	}
	return run_runtime_signature(args[0].as_string().trim_string_left(':'), args[1], declaration_block_from_value(args[2])) or { panic(err) }
}

// Ruby method `self.run_builder(declaration_block)` at line 465.
pub fn ruby_methods_l465_d15_self_run_builder(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.run_builder requires a declaration block') }
	return declaration_value(declaration_from_block(declaration_block_from_value(args[0])) or { panic(err) })
}

// Ruby method `self.build_sig(method_name, original_method, current_declaration)` at line 484.
pub fn ruby_methods_l484_d16_self_build_sig(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Methods.build_sig requires method name, original method, and declaration')
	}
	return runtime_signature_value(build_runtime_signature(args[0].as_string().trim_string_left(':'), args[1], declaration_from_value(args[2])))
}

// Ruby method `self.signature_for_method(method)` at line 521.
pub fn ruby_methods_l521_d17_self_signature_for_method(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return methods_nil()
	}
	return signature_for_runtime_key(method_value_key(args[0])) or { methods_nil() }
}

// Ruby method `self.signature_for_key(key)` at line 525.
pub fn ruby_methods_l525_d18_self_signature_for_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return methods_nil()
	}
	return signature_for_runtime_key(args[0].as_string()) or { methods_nil() }
}

// Ruby method `self.unwrap_method(mod, signature, original_method)` at line 530.
pub fn ruby_methods_l530_d19_self_unwrap_method(args ...ruby.Value) ruby.Value {
	if args.len < 3 { panic('Methods.unwrap_method requires module, signature, and original method') }
	plan := ruby_call_validation_l18_d1_self_wrap_method_if_needed(args[0], args[1], args[2])
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	registry.signatures_by_method[method_value_key(args[2])] = args[1]
	registry.mutex.unlock()
	return plan
}

// Ruby method `self.has_sig_block_for_method(method)` at line 535.
pub fn ruby_methods_l535_d20_self_has_sig_block_for_method(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && wrapper_has_key(method_value_key(args[0])))
}

// Ruby method `self.has_sig_block_for_key(key)` at line 539.
pub fn ruby_methods_l539_d21_self_has_sig_block_for_key(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && wrapper_has_key(args[0].as_string()))
}

// Ruby method `self.maybe_run_sig_block_for_method(method)` at line 543.
pub fn ruby_methods_l543_d22_self_maybe_run_sig_block_for_method(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return methods_nil()
	}
	key := method_value_key(args[0])
	return if wrapper_has_key(key) {
		run_runtime_signature_for_key(key, false) or { panic(err) }
	} else {
		methods_nil()
	}
}

// Ruby method `self.maybe_run_sig_block_for_key(key)` at line 548.
pub fn ruby_methods_l548_d23_self_maybe_run_sig_block_for_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return methods_nil()
	}
	key := args[0].as_string()
	return if wrapper_has_key(key) {
		run_runtime_signature_for_key(key, false) or { panic(err) }
	} else {
		methods_nil()
	}
}

// Ruby method `self.run_sig_block_for_method(method)` at line 552.
pub fn ruby_methods_l552_d24_self_run_sig_block_for_method(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.run_sig_block_for_method requires a method') }
	return run_runtime_signature_for_key(method_value_key(args[0]), false) or { panic(err) }
}

// Ruby method `self.method_owner_and_name_to_key(owner, name)` at line 557.
pub fn ruby_methods_l557_d25_self_method_owner_and_name_to_key(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods.method_owner_and_name_to_key requires owner and name') }
	return ruby.string_value(method_owner_and_name_key(args[0], args[1].as_string()))
}

// Ruby method `self.method_to_key(method)` at line 561.
pub fn ruby_methods_l561_d26_self_method_to_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.method_to_key requires a method') }
	return ruby.string_value(method_value_key(args[0]))
}

// Ruby method `self.run_sig_block_for_key(key, force_type_init: false)` at line 569.
pub fn ruby_methods_l569_d27_self_run_sig_block_for_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.run_sig_block_for_key requires a key') }
	force := args.len > 1 && methods_bool_arg(args[1])
	return run_runtime_signature_for_key(args[0].as_string(), force) or { panic(err) }
}

// Ruby method `self.run_all_sig_blocks(force_type_init: true)` at line 598.
pub fn ruby_methods_l598_d28_self_run_all_sig_blocks(args ...ruby.Value) ruby.Value {
	force := if args.len > 0 { methods_bool_arg(args[0]) } else { true }
	run_all_runtime_signatures(force) or { panic(err) }
	return methods_nil()
}

// Ruby method `self.all_checked_tests_sigs` at line 617.
pub fn ruby_methods_l617_d29_self_all_checked_tests_sigs(args ...ruby.Value) ruby.Value {
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	values := registry.signatures_by_method.values().filter(it.attribute('check_level') or { '' } == 'tests')
	registry.mutex.unlock()
	return ruby.array_value(values)
}

// Ruby method `self._hook_impl(target, source)` at line 623.
pub fn ruby_methods_l623_d30_self_hook_impl(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Methods._hook_impl requires target and source') }
	method_names := args[1].attribute('instance_methods') or { '' }.split(',').map(it.trim_space()).filter(it != '')
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	interesting := method_names.filter(registry.was_ever_final_names[it] or { false })
	registry.mutex.unlock()
	if interesting.len == 0 {
		return methods_nil()
	}
	return ruby.bool_value(check_runtime_final_ancestors(args[0], interesting, args[1]) or { panic(err) })
}

// Ruby method `self.set_final_checks_on_hooks(enable)` at line 648.
pub fn ruby_methods_l648_d31_self_set_final_checks_on_hooks(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.set_final_checks_on_hooks requires a boolean') }
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	registry.final_checks_on_hooks = methods_bool_arg(args[0])
	registry.mutex.unlock()
	return methods_nil()
}

// Ruby define_method `Module.define_method(:included, @old_hooks[0])` at line 657.
pub fn ruby_methods_l657_d32_included(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('T::Private::Methods::RestoredHook', 'included', {
		'hook': 'included'
	})
}

// Ruby define_method `Module.define_method(:extended, @old_hooks[1])` at line 658.
pub fn ruby_methods_l658_d33_extended(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('T::Private::Methods::RestoredHook', 'extended', {
		'hook': 'extended'
	})
}

// Ruby define_method `Class.define_method(:inherited, @old_hooks[2])` at line 659.
pub fn ruby_methods_l659_d34_inherited(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('T::Private::Methods::RestoredHook', 'inherited', {
		'hook': 'inherited'
	})
}

// Ruby method `method_added(name)` at line 687.
pub fn ruby_methods_l687_d35_method_added(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('MethodHooks#method_added requires receiver and name') }
	name := args[1].as_string().trim_string_left(':')
	method := ruby.Value{
		type_name: 'UnboundMethod'
		repr: name
		map_data: {
			'owner': args[0]
		}
		attributes: {
			'name':            name
			'parameter_kinds': ''
			'parameter_names': ''
		}
	}
	return consume_runtime_method_added(args[0], args[0], name, method) or { panic(err) }
}

// Ruby method `singleton_method_added(name)` at line 694.
pub fn ruby_methods_l694_d36_singleton_method_added(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('SingletonMethodHooks#singleton_method_added requires receiver and name') }
	name := args[1].as_string().trim_string_left(':')
	singleton := ruby.structured_value('Class', '${args[0].as_string()}.singleton_class', {
		'object_id': '${module_identity(args[0])}:singleton'
	})
	method := ruby.Value{
		type_name: 'UnboundMethod'
		repr: name
		map_data: {
			'owner': singleton
		}
		attributes: {
			'name':            name
			'parameter_kinds': ''
			'parameter_names': ''
		}
	}
	return consume_runtime_method_added(args[0], singleton, name, method) or { panic(err) }
}

// Ruby method `self.install_hooks(mod)` at line 708.
pub fn ruby_methods_l708_d37_self_install_hooks(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Methods.install_hooks requires a module') }
	mod := args[0]
	key := module_identity(mod)
	mut registry := methods_runtime_registry()
	registry.mutex.lock()
	already := registry.installed_hooks[key] or { false }
	registry.installed_hooks[key] = true
	registry.mutex.unlock()
	return ruby.structured_value('T::Private::Methods::InstalledHooks', mod.as_string(), {
		'already_installed': already.str()
		'method_hook':       if mod.attribute('singleton_class') or { 'false' } == 'true' {
			'included'
		} else {
			'extended'
		}
		'singleton_hook':    'extended'
	})
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Methods
// 5:   @installed_hooks = {}
// 6:   if defined?(Concurrent::Hash)
// 7:     # Hide the Concurrent::Hash so that we get better typing by lying and saying it's a Hash
// 8:     instance_variable_set(:@signatures_by_method, Concurrent::Hash.new)
// 9:     instance_variable_set(:@sig_wrappers, Concurrent::Hash.new)
// 10:   else
// 11:     @signatures_by_method = {}
// 12:     @sig_wrappers = {}
// 13:   end
// 14:   @sigs_that_raised = {}
// 15:   # stores method names that were declared final without regard for where.
// 16:   # enables early rejection of names that we know can't induce final method violations.
// 17:   @was_ever_final_names = {}.compare_by_identity
// 18:   # maps from a module's object_id to the set of final methods declared in that module.
// 19:   # we also overload entries slightly: if the value is nil, that means that the
// 20:   # module has final methods somewhere along its ancestor chain, but does not itself
// 21:   # have any final methods.
// 22:   #
// 23:   # we need the latter information to know whether we need to check along the ancestor
// 24:   # chain for final method violations.  we need the former information because we
// 25:   # care about exactly where a final method is defined (e.g. including the same module
// 26:   # twice is permitted).  we could do this with two tables, but it seems slightly
// 27:   # cleaner with a single table.
// 28:   # Effectively T::Hash[Module, T.nilable(Set))]
// 29:   @modules_with_final = Hash.new { |hash, key| hash[key] = nil }.compare_by_identity
// 30:   # this stores the old [included, extended] hooks for Module and inherited hook for Class that we override when
// 31:   # enabling final checks for when those hooks are called. the 'hooks' here don't have anything to do with the 'hooks'
// 32:   # in installed_hooks.
// 33:   @old_hooks = nil
// 34:
// 35:   # These names are for backwards compatibility from when these were `Object.new` instances
// 36:   # rubocop:disable Naming/ClassAndModuleCamelCase
// 37:   module ARG_NOT_PROVIDED
// 38:     freeze
// 39:   end
// 40:   module PROC_TYPE
// 41:     freeze
// 42:   end
// 43:   # rubocop:enable Naming/ClassAndModuleCamelCase
// 44:
// 45:   # blk_or_decl:
// 46:   # - It's a `Proc` if we haven't forced the thunk yet.
// 47:   # - It's a `Declaration` if we have, but we haven't finished building the sig
// 48:   #   (This can matter for circular load-time behavior, where a method is
// 49:   #   called while its Signature is being built)
// 50:   # - It's `nil` if we've finished building the sig
// 51:   DeclarationBlock = Struct.new(:mod, :method_name, :loc, :blk_or_decl, :final, :abstract, :override, :overridable)
// 52:
// 53:   def self.declare_sig(mod, loc, arg, &blk)
// 54:     if T::Private::DeclState.current.active_declaration
// 55:       T::Private::DeclState.current.reset!
// 56:       raise "You called sig twice without declaring a method in between"
// 57:     end
// 58:
// 59:     if !arg.nil? && arg != :final
// 60:       raise "Invalid argument to `sig`: #{arg}"
// 61:     end
// 62:
// 63:     method_name = nil # will be filled in once the next method is defined
// 64:     abstract = nil
// 65:     override = nil
// 66:     overridable = nil
// 67:     T::Private::DeclState.current.active_declaration = DeclarationBlock.new(mod, method_name, loc, blk, arg == :final, abstract, override, overridable)
// 68:
// 69:     nil
// 70:   end
// 71:
// 72:   private_class_method def self.ensure_valid_declare_dsl!(mod, method_name, dsl_name)
// 73:     previous_declaration = T::Private::DeclState.current.previous_declaration
// 74:     if previous_declaration.nil?
// 75:       # TODO(jez) Eventually, relax this and allow these DSLs without a preceding `sig`
// 76:       raise DeclBuilder::BuilderError.new("You must declare a `sig` before using `#{dsl_name}` on the method `#{method_name}`")
// 77:     end
// 78:
// 79:     if !previous_declaration.blk_or_decl.is_a?(Proc)
// 80:       raise DeclBuilder::BuilderError.new("Cannot call `#{dsl_name} #{method_name.inspect}`, because the sig block has already run")
// 81:     end
// 82:
// 83:     # previous_declaration.mod is the method owner (which for `def self.foo`
// 84:     # is the singleton class). The DSL caller's `self` is the class itself,
// 85:     # so we also accept mod.singleton_class == previous_declaration.mod.
// 86:     mod_matches = previous_declaration.mod == mod || previous_declaration.mod == mod.singleton_class
// 87:     if !mod_matches || previous_declaration.method_name != method_name
// 88:       raise DeclBuilder::BuilderError.new(
// 89:         "Can only call `#{dsl_name} #{method_name.inspect}` for the previously sig'd method. " \
// 90:         "Expected: #{previous_declaration.mod}##{previous_declaration.method_name}"
// 91:       )
// 92:     end
// 93:
// 94:     previous_declaration
// 95:   end
// 96:
// 97:   def self.declare_abstract(mod, method_name)
// 98:     previous_declaration = ensure_valid_declare_dsl!(mod, method_name, :abstract)
// 99:     return unless previous_declaration
// 100:
// 101:     if previous_declaration.abstract
// 102:       raise DeclBuilder::BuilderError.new("Cannot call `abstract` twice for the method `#{method_name}`")
// 103:     end
// 104:
// 105:     previous_declaration.abstract = true
// 106:
// 107:     # # TODO(jez) In the future, we will want some logic like this, but ONLY if
// 108:     # # the method did not have a sig. The first-call sig wrapper is normally in
// 109:     # # charge of running the sig block (even for abstract methods) If we know
// 110:     # # for sure that we're not going to have a sig, but we want the runtime
// 111:     # # `super` logic (possibly because there is an RBS method annotation), we
// 112:     # # are safe to eagerly call `create_abstract_wrapper` to overwrite the
// 113:     # # user's method.
// 114:     # #
// 115:     # # (Omitting this until we support DSL methods without runtime `sig`'s)
// 116:     # original_visibility = T::Private::ClassUtils.visibility_method_name(mod, method_name)
// 117:     # T::Private::Methods::CallValidation.create_abstract_wrapper(mod, method_name, original_visibility)
// 118:
// 119:     nil
// 120:   end
// 121:
// 122:   def self.declare_override(mod, method_name, allow_incompatible:)
// 123:     previous_declaration = ensure_valid_declare_dsl!(mod, method_name, :override)
// 124:     return unless previous_declaration
// 125:
// 126:     if previous_declaration.override
// 127:       raise DeclBuilder::BuilderError.new("Cannot call `override` twice for the method `#{method_name}`")
// 128:     end
// 129:
// 130:     method = mod.instance_method(method_name)
// 131:     super_method = method.super_method
// 132:     if super_method.nil?
// 133:       source_loc = Kernel.caller_locations(2, 1)&.map { |loc| [loc.path || "<unknown>", loc.lineno] }&.first
// 134:       T::Private::Methods::SignatureValidation.validate_non_override_mode(Modes.override, method_name, method, source_loc)
// 135:     end
// 136:
// 137:     previous_declaration.override = {allow_incompatible: allow_incompatible}
// 138:
// 139:     nil
// 140:   end
// 141:
// 142:   def self.declare_final(mod, method_name)
// 143:     previous_declaration = ensure_valid_declare_dsl!(mod, method_name, :final)
// 144:     return unless previous_declaration
// 145:
// 146:     if previous_declaration.final
// 147:       raise DeclBuilder::BuilderError.new("Cannot declare `#{method_name}` final twice (from `sig(:final)` nor `final def`)")
// 148:     end
// 149:
// 150:     previous_declaration.final = true
// 151:
// 152:     # Register final bookkeeping that _on_method_added would have done if it
// 153:     # had seen final=true at that time. Use previous_declaration.mod (the actual
// 154:     # method owner, which is the singleton_class for `def self.foo`).
// 155:     add_module_with_final_method(previous_declaration.mod, method_name)
// 156:
// 157:     nil
// 158:   end
// 159:
// 160:   def self.declare_overridable(mod, method_name)
// 161:     previous_declaration = ensure_valid_declare_dsl!(mod, method_name, :overridable)
// 162:     return unless previous_declaration
// 163:
// 164:     if previous_declaration.overridable
// 165:       raise DeclBuilder::BuilderError.new("Cannot call `overridable` twice for the method `#{method_name}`")
// 166:     end
// 167:
// 168:     previous_declaration.overridable = true
// 169:
// 170:     nil
// 171:   end
// 172:
// 173:   def self.start_proc
// 174:     # abstract/override/overridable don't make sense on procs
// 175:     abstract = false
// 176:     override = nil
// 177:     overridable = false
// 178:     DeclBuilder.new(PROC_TYPE, abstract, override, overridable)
// 179:   end
// 180:
// 181:   def self.finalize_proc(decl)
// 182:     decl.finalized = true
// 183:
// 184:     if decl.mode != Modes.standard
// 185:       raise "Procs cannot have override/abstract modifiers"
// 186:     end
// 187:     if decl.mod != PROC_TYPE
// 188:       raise "You are passing a DeclBuilder as a type. Did you accidentally use `self` inside a `sig` block? Perhaps you wanted the `T.self_type` instead: https://sorbet.org/docs/self-type"
// 189:     end
// 190:     if decl.returns == ARG_NOT_PROVIDED
// 191:       raise "Procs must specify a return type"
// 192:     end
// 193:     if decl.on_failure != ARG_NOT_PROVIDED
// 194:       raise "Procs cannot use .on_failure"
// 195:     end
// 196:
// 197:     if decl.params == ARG_NOT_PROVIDED
// 198:       decl.params = {}
// 199:     end
// 200:
// 201:     T::Types::Proc.new(decl.params, decl.returns)
// 202:   end
// 203:
// 204:   # Fetch the directory name of the file that defines the `T::Private` constant and
// 205:   # add a trailing slash to allow us to match it as a directory prefix.
// 206:   sorbet_runtime_loc = T.const_source_location(:Private)
// 207:   raise "T::Private constant location not found" unless sorbet_runtime_loc
// 208:   SORBET_RUNTIME_LIB_PATH = File.dirname(sorbet_runtime_loc.first) + File::SEPARATOR
// 209:   private_constant :SORBET_RUNTIME_LIB_PATH
// 210:
// 211:   # when target includes a module with instance methods source_method_names, ensure there is zero intersection between
// 212:   # the final instance methods of target and source_method_names. so, for every m in source_method_names, check if there
// 213:   # is already a method defined on one of target_ancestors with the same name that is final.
// 214:   #
// 215:   # we assume that source_method_names has already been filtered to only include method
// 216:   # names that were declared final at one point.
// 217:   #
// 218:   # Returns a boolean indicating whether it's okay to define any of `source_method_names` in `target`
// 219:   # (e.g. true if no final method violations)
// 220:   def self._check_final_ancestors(target, source_method_names, source)
// 221:     source_ancestors = nil
// 222:     if T::Private::IS_TYPECHECKING
// 223:       # Need to avoid a pinning error, but don't want to use runtime types in _methods.rb
// 224:       source_ancestors = T.let(nil, T.nilable(T::Array[T::Module[T.anything]]))
// 225:       found_error = T.let(false, T::Boolean)
// 226:     end
// 227:     found_error = false
// 228:     # use reverse_each to check farther-up ancestors first, for better error messages.
// 229:     target.ancestors.reverse_each do |ancestor|
// 230:       final_methods = @modules_with_final.fetch(ancestor, nil)
// 231:       # In this case, either ancestor didn't have any final methods anywhere in its
// 232:       # ancestor chain, or ancestor did have final methods somewhere in its ancestor
// 233:       # chain, but no final methods defined in ancestor itself.  Either way, there
// 234:       # are no final methods to check here, so we can move on to the next ancestor.
// 235:       next unless final_methods
// 236:       source_method_names.each do |method_name|
// 237:         next unless final_methods.include?(method_name)
// 238:
// 239:         # If we get here, we are defining a method that some ancestor declared as
// 240:         # final.  however, we permit a final method to be defined multiple
// 241:         # times if it is the same final method being defined each time.
// 242:         if source
// 243:           if !source_ancestors
// 244:             source_ancestors = source.ancestors
// 245:             # filter out things without actual final methods just to make sure that
// 246:             # the below checks (which should be uncommon) go as quickly as possible.
// 247:             source_ancestors.select! do |a|
// 248:               @modules_with_final.fetch(a, nil)
// 249:             end
// 250:           end
// 251:           # final-ness means that there should be no more than one index for which
// 252:           # the below block returns true.
// 253:           defining_ancestor_idx = source_ancestors.index do |a|
// 254:             @modules_with_final.fetch(a).include?(method_name)
// 255:           end
// 256:           next if defining_ancestor_idx && source_ancestors[defining_ancestor_idx] == ancestor
// 257:         end
// 258:
// 259:         found_error = true
// 260:
// 261:         final_sig = T::Private::Methods.signature_for_method(ancestor.instance_method(method_name))
// 262:         definition_file, definition_line = final_sig&.method&.source_location
// 263:         is_redefined = target == ancestor
// 264:         caller_loc = T::Private::CallerUtils.find_caller { |loc| !loc.path.to_s.start_with?(SORBET_RUNTIME_LIB_PATH) }
// 265:         extra_info = "\n"
// 266:         if caller_loc
// 267:           extra_info = (is_redefined ? "Redefined" : "Overridden") + " here: #{caller_loc.path}:#{caller_loc.lineno}\n"
// 268:         end
// 269:
// 270:         error_message = "The method `#{method_name}` on #{ancestor} was declared as final and cannot be " +
// 271:                         (is_redefined ? "redefined" : "overridden in #{target}")
// 272:         pretty_message = "#{error_message}\n" \
// 273:                          "Made final here: #{definition_file}:#{definition_line}\n" \
// 274:                          "#{extra_info}"
// 275:
// 276:         begin
// 277:           # raise + rescue to populate the backtrace
// 278:           raise pretty_message
// 279:         rescue => e
// 280:           T::Configuration.sig_validation_error_handler(e, {})
// 281:         end
// 282:       end
// 283:     end
// 284:     !found_error
// 285:   end
// 286:
// 287:   def self.add_module_with_final_method(mod, method_name)
// 288:     @was_ever_final_names[method_name] = true
// 289:
// 290:     # Side-effectfully initializes the value if it's not already there
// 291:     methods = @modules_with_final[mod]
// 292:     if methods.nil?
// 293:       methods = {}
// 294:       @modules_with_final[mod] = methods
// 295:     end
// 296:     methods[method_name] = true
// 297:     nil
// 298:   end
// 299:
// 300:   # Only public because it needs to get called below inside the replace_method blocks below.
// 301:   def self._on_method_added(hook_mod, mod, method_name)
// 302:     # The thread-local DeclState object is stable for the duration of this call
// 303:     # (nothing reassigns `DeclState.current=`), so fetch it once.
// 304:     decl_state = T::Private::DeclState.current
// 305:     if decl_state.skip_on_method_added
// 306:       return
// 307:     end
// 308:
// 309:     current_declaration = decl_state.consume!
// 310:
// 311:     if T::Private::Final.final_module?(mod) && (current_declaration.nil? || !current_declaration.final)
// 312:       raise "#{mod} was declared as final but its method `#{method_name}` was not declared as final"
// 313:     end
// 314:     # Don't compute mod.ancestors if we don't need to bother checking final-ness.
// 315:     if @was_ever_final_names.include?(method_name) && @modules_with_final.include?(mod) &&
// 316:        !_check_final_ancestors(mod, [method_name], nil)
// 317:       # We want to pretend like the method did not have a sig, so return.
// 318:       # (This code is not dead, because some `sig_validation_error_handler`'s do not raise.)
// 319:       return
// 320:     end
// 321:
// 322:     if current_declaration.nil?
// 323:       return
// 324:     end
// 325:
// 326:     current_declaration.method_name = method_name
// 327:
// 328:     if method_name == :method_added || method_name == :singleton_method_added
// 329:       raise(
// 330:         "Putting a `sig` on `#{method_name}` is not supported" \
// 331:         " (sorbet-runtime uses this method internally to perform `sig` validation logic)"
// 332:       )
// 333:     end
// 334:
// 335:     # We allow `sig` in the current module's context (normal case) and
// 336:     if hook_mod != current_declaration.mod &&
// 337:        # inside `class << self`, and
// 338:        hook_mod.singleton_class != current_declaration.mod &&
// 339:        # on `self` at the top level of a file
// 340:        current_declaration.mod != TOP_SELF
// 341:       raise "A method (#{method_name}) is being added on a different class/module (#{hook_mod}) than the " \
// 342:             "last call to `sig` (#{current_declaration.mod}). Make sure each call " \
// 343:             "to `sig` is immediately followed by a method definition on the same " \
// 344:             "class/module."
// 345:     end
// 346:     # Overwrite the DeclarationBlock mod with `mod`, which is the Module that owns the method.
// 347:     current_declaration.mod = mod
// 348:
// 349:     original_method = mod.instance_method(method_name)
// 350:     sig_block = lambda do
// 351:       T::Private::Methods.run_sig(method_name, original_method, current_declaration)
// 352:     end
// 353:
// 354:     # Always replace the original method with this wrapper,
// 355:     # which is called only on the *first* invocation.
// 356:     # This wrapper is very slow, so it will subsequently re-wrap with a much faster wrapper
// 357:     # (or unwrap back to the original method).
// 358:     key = method_owner_and_name_to_key(mod, method_name)
// 359:     T::Private::ClassUtils.replace_method(original_method, mod, method_name) do |*args, &blk|
// 360:       method_sig = T::Private::Methods.maybe_run_sig_block_for_key(key)
// 361:       if !method_sig
// 362:         callee = __callee__ || raise("Unknown __callee__ for method without a signature")
// 363:         method_sig = T::Private::Methods.signature_for_method(original_method)
// 364:         if !method_sig
// 365:           raise "`sig` not present for method `#{callee}` on #{self.inspect} but you're trying to run it anyways. " \
// 366:             "This should only be executed if you used `alias_method` to grab a handle to a method after `sig`ing it, but that clearly isn't what you are doing. " \
// 367:             "Maybe look to see if an exception was thrown in your `sig` lambda or somehow else your `sig` wasn't actually applied to the method."
// 368:         end
// 369:
// 370:         method_sig = T::Private::Methods._unwrap_alias(
// 371:           method_sig,
// 372:           self,
// 373:           original_method,
// 374:           callee,
// 375:         )
// 376:       end
// 377:
// 378:       # Should be the same logic as CallValidation.wrap_method_if_needed but we
// 379:       # don't want that extra layer of indirection in the callstack
// 380:       if method_sig.mode == T::Private::Methods::Modes.abstract
// 381:         # We're in an interface method, keep going up the chain
// 382:         if defined?(super)
// 383:           super(*args, &blk)
// 384:         else
// 385:           raise NotImplementedError.new("The method `#{method_sig.method_name}` on #{mod} is declared as `abstract`. It does not have an implementation.")
// 386:         end
// 387:       # Note, this logic is duplicated (intentionally, for micro-perf) at `CallValidation.wrap_method_if_needed`,
// 388:       # make sure to keep changes in sync.
// 389:       elsif method_sig.check_level == :always || (method_sig.check_level == :tests && T::Private::RuntimeLevels.check_tests?)
// 390:         CallValidation.validate_call(self, original_method, method_sig, args, blk)
// 391:       else
// 392:         original_method.bind_call(self, *args, &blk)
// 393:       end
// 394:     end
// 395:
// 396:     @sig_wrappers[key] = sig_block
// 397:     if current_declaration.final
// 398:       add_module_with_final_method(mod, method_name)
// 399:     end
// 400:   end
// 401:
// 402:   # Only public so that it can be accessed in the closure for _on_method_added
// 403:   def self._unwrap_alias(method_sig, receiver, original_method, callee)
// 404:     if receiver.class <= original_method.owner
// 405:       receiving_class = receiver.class
// 406:     elsif receiver.singleton_class <= original_method.owner
// 407:       receiving_class = receiver.singleton_class
// 408:     elsif receiver.is_a?(Module) && receiver <= original_method.owner
// 409:       receiving_class = receiver
// 410:     else
// 411:       raise "#{receiver} is not related to #{original_method} - how did we get here?"
// 412:     end
// 413:
// 414:     # Check for a case where `alias` or `alias_method` was called for a
// 415:     # method which had already had a `sig` applied. In that case, we want
// 416:     # to avoid hitting this slow path again, by moving to a faster validator
// 417:     # just like we did or will for the original method.
// 418:     #
// 419:     # If this isn't an `alias` or `alias_method` case, we're probably in the
// 420:     # middle of some metaprogramming using a Method object, e.g. a pattern like
// 421:     # `arr.map(&method(:foo))`. There's nothing really we can do to optimize
// 422:     # that here.
// 423:     receiving_method = receiving_class.instance_method(callee)
// 424:     if receiving_method != original_method && receiving_method.original_name == original_method.name
// 425:       aliasing_mod = receiving_method.owner
// 426:       method_sig = method_sig.as_alias(callee)
// 427:       unwrap_method(aliasing_mod, method_sig, original_method)
// 428:     end
// 429:
// 430:     method_sig
// 431:   end
// 432:
// 433:   # Executes the `sig` block, and converts the resulting Declaration
// 434:   # to a Signature.
// 435:   def self.run_sig(method_name, original_method, declaration_block)
// 436:     current_declaration =
// 437:       begin
// 438:         run_builder(declaration_block)
// 439:       rescue DeclBuilder::BuilderError => e
// 440:         T::Configuration.sig_builder_error_handler(e, declaration_block.loc)
// 441:         nil
// 442:       end
// 443:
// 444:     # Release location information sooner
// 445:     declaration_block.loc = nil
// 446:
// 447:     signature =
// 448:       if current_declaration
// 449:         build_sig(method_name, original_method, current_declaration)
// 450:       else
// 451:         Signature.new_untyped(method: original_method)
// 452:       end
// 453:
// 454:     unwrap_method(signature.method.owner, signature, original_method)
// 455:
// 456:     # Drop this declaration. Only drop it after we've actually wrapped the
// 457:     # method and recorded the signature, because that might raise an exception,
// 458:     # leaving the declaration in a weird state if the program rescues that
// 459:     # exception and continues.
// 460:     declaration_block.blk_or_decl = nil
// 461:
// 462:     signature
// 463:   end
// 464:
// 465:   def self.run_builder(declaration_block)
// 466:     blk_or_decl = declaration_block.blk_or_decl
// 467:     return blk_or_decl if blk_or_decl.is_a?(Declaration)
// 468:     if blk_or_decl.nil?
// 469:       raise "DeclarationBlock for #{declaration_block.mod} at #{declaration_block.loc} should have already been unwrapped"
// 470:     end
// 471:
// 472:     builder = DeclBuilder.new(
// 473:       declaration_block.mod,
// 474:       declaration_block.abstract,
// 475:       declaration_block.override,
// 476:       declaration_block.overridable
// 477:     )
// 478:     decl = builder.instance_exec(&blk_or_decl).finalize!.decl
// 479:     # Record that we've already run `blk` once and constructed a `Declaration`
// 480:     declaration_block.blk_or_decl = decl
// 481:     decl
// 482:   end
// 483:
// 484:   def self.build_sig(method_name, original_method, current_declaration)
// 485:     begin
// 486:       signature = Signature.new(
// 487:         method: original_method,
// 488:         method_name: method_name,
// 489:         raw_arg_types: current_declaration.params,
// 490:         raw_return_type: current_declaration.returns,
// 491:         bind: current_declaration.bind,
// 492:         mode: current_declaration.mode,
// 493:         check_level: current_declaration.checked,
// 494:         on_failure: current_declaration.on_failure,
// 495:         override_allow_incompatible: current_declaration.override_allow_incompatible,
// 496:         defined_raw: current_declaration.raw,
// 497:       )
// 498:
// 499:       SignatureValidation.validate(signature)
// 500:       signature
// 501:     rescue => e
// 502:       super_method = original_method.super_method
// 503:       super_signature = signature_for_method(super_method) if super_method
// 504:
// 505:       T::Configuration.sig_validation_error_handler(
// 506:         e,
// 507:         method: original_method,
// 508:         declaration: current_declaration,
// 509:         signature: signature,
// 510:         super_signature: super_signature
// 511:       )
// 512:
// 513:       Signature.new_untyped(method: original_method)
// 514:     end
// 515:   end
// 516:
// 517:   # Returns the signature for a method whose definition was preceded by `sig`.
// 518:   #
// 519:   # @param method [UnboundMethod]
// 520:   # @return [T::Private::Methods::Signature]
// 521:   def self.signature_for_method(method)
// 522:     signature_for_key(method_to_key(method))
// 523:   end
// 524:
// 525:   private_class_method def self.signature_for_key(key)
// 526:     maybe_run_sig_block_for_key(key)
// 527:     @signatures_by_method[key]
// 528:   end
// 529:
// 530:   private_class_method def self.unwrap_method(mod, signature, original_method)
// 531:     maybe_wrapped_method = CallValidation.wrap_method_if_needed(mod, signature, original_method)
// 532:     @signatures_by_method[method_to_key(maybe_wrapped_method)] = signature
// 533:   end
// 534:
// 535:   def self.has_sig_block_for_method(method)
// 536:     has_sig_block_for_key(method_to_key(method))
// 537:   end
// 538:
// 539:   private_class_method def self.has_sig_block_for_key(key)
// 540:     @sig_wrappers.key?(key)
// 541:   end
// 542:
// 543:   def self.maybe_run_sig_block_for_method(method)
// 544:     maybe_run_sig_block_for_key(method_to_key(method))
// 545:   end
// 546:
// 547:   # Only public so that it can be accessed in the closure for _on_method_added
// 548:   def self.maybe_run_sig_block_for_key(key)
// 549:     run_sig_block_for_key(key) if has_sig_block_for_key(key)
// 550:   end
// 551:
// 552:   def self.run_sig_block_for_method(method)
// 553:     run_sig_block_for_key(method_to_key(method))
// 554:   end
// 555:
// 556:   # use this directly if you don't want/need to box up the method into an object to pass to method_to_key.
// 557:   private_class_method def self.method_owner_and_name_to_key(owner, name)
// 558:     "#{owner.object_id}##{name}"
// 559:   end
// 560:
// 561:   private_class_method def self.method_to_key(method)
// 562:     # If a subclass Sub inherits a method `foo` from Base, then
// 563:     # Sub.instance_method(:foo) != Base.instance_method(:foo) even though they resolve to the
// 564:     # same method. Similarly, Foo.method(:bar) != Foo.singleton_class.instance_method(:bar).
// 565:     # So, we always do the look up by the method on the owner (Base in this example).
// 566:     method_owner_and_name_to_key(method.owner, method.name)
// 567:   end
// 568:
// 569:   private_class_method def self.run_sig_block_for_key(key, force_type_init: false)
// 570:     blk = @sig_wrappers[key]
// 571:     if !blk
// 572:       sig = @signatures_by_method[key]
// 573:       if sig
// 574:         # We already ran the sig block, perhaps in another thread.
// 575:         return sig
// 576:       else
// 577:         raise "No `sig` wrapper for #{key}. This is likely a bug in sorbet-runtime. If you can reproduce, please report an issue."
// 578:       end
// 579:     end
// 580:
// 581:     begin
// 582:       sig = blk.call
// 583:     rescue
// 584:       @sigs_that_raised[key] = true
// 585:       raise
// 586:     end
// 587:     if @sigs_that_raised[key]
// 588:       raise "A previous invocation of #{sig.method_desc} raised, and the current one succeeded. Please don't do that."
// 589:     end
// 590:
// 591:     @sig_wrappers.delete(key)
// 592:
// 593:     sig.force_type_init if force_type_init
// 594:
// 595:     sig
// 596:   end
// 597:
// 598:   def self.run_all_sig_blocks(force_type_init: true)
// 599:     current_declaration = T::Private::DeclState.current.active_declaration
// 600:     if !current_declaration.nil?
// 601:       T::Private::DeclState.current.reset!
// 602:       raise "Cannot call `run_all_sig_blocks` while there is a pending `sig` block in #{current_declaration.mod} at #{current_declaration.loc}"
// 603:     end
// 604:
// 605:     loop do
// 606:       first_wrapper = @sig_wrappers.first
// 607:       break unless first_wrapper
// 608:       key, = first_wrapper
// 609:       run_sig_block_for_key(key, force_type_init: force_type_init)
// 610:     end
// 611:
// 612:     # Make sure that there are no lingering declaration blocks being kept alive
// 613:     # (so we're not retaining any extra references for a possible GC)
// 614:     T::Private::DeclState.current.reset!
// 615:   end
// 616:
// 617:   def self.all_checked_tests_sigs
// 618:     @signatures_by_method.values.select { |sig| sig.check_level == :tests }
// 619:   end
// 620:
// 621:   # the module target is adding the methods from the module source to itself. we need to check that for all instance
// 622:   # methods M on source, M is not defined on any of target's ancestors.
// 623:   def self._hook_impl(target, source)
// 624:     # we do not need to call add_was_ever_final here, because we have already marked
// 625:     # any such methods when source was originally defined.
// 626:     if !@modules_with_final.include?(target)
// 627:       if !@modules_with_final.include?(source)
// 628:         return
// 629:       end
// 630:       # Side-effectfully initialize the value if it's not already there
// 631:       @modules_with_final[target]
// 632:       install_hooks(target)
// 633:       return
// 634:     end
// 635:
// 636:     methods = source.instance_methods
// 637:     methods.select! do |method_name|
// 638:       @was_ever_final_names.include?(method_name)
// 639:     end
// 640:     if methods.empty?
// 641:       return
// 642:     end
// 643:
// 644:     _check_final_ancestors(target, methods, source)
// 645:     nil
// 646:   end
// 647:
// 648:   def self.set_final_checks_on_hooks(enable)
// 649:     is_enabled = !@old_hooks.nil?
// 650:     if enable == is_enabled
// 651:       return
// 652:     end
// 653:     if is_enabled
// 654:       # A cut-down version of T::Private::ClassUtils::ReplacedMethod#restore, because we
// 655:       # should only be resetting final hooks during tests.
// 656:       T::Configuration.without_ruby_warnings do
// 657:         Module.define_method(:included, @old_hooks[0])
// 658:         Module.define_method(:extended, @old_hooks[1])
// 659:         Class.define_method(:inherited, @old_hooks[2])
// 660:       end
// 661:       @old_hooks = nil
// 662:     else
// 663:       # Grab the original methods before replacing them, so that each block
// 664:       # closure can reference a variable that is already assigned.
// 665:       # (Do this directly, to avoid pinning errors)
// 666:       old_included = Module.instance_method(:included)
// 667:       T::Private::ClassUtils.replace_method(old_included, Module, :included) do |arg|
// 668:         old_included.bind_call(self, arg)
// 669:         ::T::Private::Methods._hook_impl(arg, self)
// 670:       end
// 671:       old_extended = Module.instance_method(:extended)
// 672:       T::Private::ClassUtils.replace_method(old_extended, Module, :extended) do |arg|
// 673:         old_extended.bind_call(self, arg)
// 674:         ::T::Private::Methods._hook_impl(arg.singleton_class, self)
// 675:       end
// 676:       old_inherited = Class.instance_method(:inherited)
// 677:       T::Private::ClassUtils.replace_method(old_inherited, Class, :inherited) do |arg|
// 678:         old_inherited.bind_call(self, arg)
// 679:         ::T::Private::Methods._hook_impl(arg, self)
// 680:         ::T::Private::Methods._hook_impl(arg.singleton_class, self.singleton_class)
// 681:       end
// 682:       @old_hooks = [old_included, old_extended, old_inherited]
// 683:     end
// 684:   end
// 685:
// 686:   module MethodHooks
// 687:     def method_added(name)
// 688:       ::T::Private::Methods._on_method_added(T.unsafe(self), T.unsafe(self), name)
// 689:       super(name)
// 690:     end
// 691:   end
// 692:
// 693:   module SingletonMethodHooks
// 694:     def singleton_method_added(name)
// 695:       ::T::Private::Methods._on_method_added(T.unsafe(self), singleton_class, name)
// 696:       super(name)
// 697:     end
// 698:   end
// 699:
// 700:   # Normally, this should be taken care of by simply `extend T::Sig`.
// 701:   #
// 702:   # But there are a few cases where we actually want the hooks to be "viral"
// 703:   # for final modules and final methods, such that we actually want to forcibly
// 704:   # install the hooks even if they would not have naturally been there via
// 705:   # inheritance.
// 706:   #
// 707:   # As such, we don't have to handle quite as many edge cases as `lib/types/sig.rb` does
// 708:   def self.install_hooks(mod)
// 709:     return if @installed_hooks.include?(mod)
// 710:     @installed_hooks[mod] = true
// 711:
// 712:     # See https://github.com/sorbet/sorbet/pull/3964 for an explanation of why this
// 713:     # check (which theoretically should not be needed) is actually needed.
// 714:     if !mod.is_a?(Module)
// 715:       return
// 716:     end
// 717:
// 718:     if mod.singleton_class?
// 719:       mod.include(SingletonMethodHooks)
// 720:     else
// 721:       mod.extend(MethodHooks)
// 722:     end
// 723:     mod.extend(SingletonMethodHooks)
// 724:   end
// 725: end
// 726:
// 727: # This has to be here, and can't be nested inside `T::Private::Methods`,
// 728: # because the value of `self` depends on lexical (nesting) scope, and we
// 729: # specifically need a reference to the file-level self, i.e. `main:Object`
// 730: T::Private::Methods::TOP_SELF = self
