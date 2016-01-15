from __future__ import print_function

import common.templates
from code.back_end import *
from code.transform import *
from code.type_sys import *
from code.indentation import *

def generate(regs, dirs):
    for mo, mod, mode in [('gb', 'glob', 'global'), ('cx', 'ctxt', 'context')]:
        iface = regs[mo + 'iface']
        decl = regs[mo + 'decl']
        env = regs[mo + 'env']
        
        common.templates.generate('vhdl',
            dirs['tmpldir'] + '/core_%sRegLogic.vhd' % mode,
            dirs['outdir'] + '/core_%sRegLogic.vhd' % mode,
            {
                'PORT_DECL':  ports(iface),
                'LIB_FUNCS':  generate_vhdl_libfuncs(),
                'REG_DECL':   decls(decl, env, True),
                'VAR_DECL':   decls(decl, env, False),
                'REG_RESET':  reset(iface, decl, env),
                'IMPL':       '',
                'RESET_IMPL': ''
            })


def ports(iface):
    output = []
    for el in iface:
        if el[0] == 'group':
            output.append('-'*75 + '\n-- ' + el[1] + '\n' + '-'*75 + '\n')
        elif el[0] == 'doc':
            if el[1] != '':
                output.append(common.templates.rewrap(el[1], 75, '-- '))
        elif el[0] == 'space':
            output.append('\n')
        elif el[0] == 'ob':
            output.append(generate_declaration_vhdl(el[1]))
        else:
            raise Exception('Unknown element type %s.' % el[0])
    return ''.join(output)


def decls(obs, env, do_regs):
    output = []
    
    # Make sure that the constant initialization expressions only use predefined
    # constants and constants which have already been defined.
    defined_constants = set()
    def const_init_access(ob):
        if isinstance(ob.atyp, PredefinedConstant):
            return True
        if isinstance(ob.atyp, Constant):
            return ob.name in defined_constants
        return False
    env = env.with_access_check(const_init_access)
    
    # Loop over and generate all object declarations.
    for ob in obs:
        if (ob.atyp.name() == 'register') != do_regs:
            continue
        if ob.atyp.name() == 'constant':
            
            # Parse the expression for constant object values.
            if ob.initspec is None:
                raise Exception('Constant object without init: \'%s\'.' % ob.name)
            init = transform_expression(
                ob.initspec, ob.origin, ob.atyp.typ, {}, env,
                'in constant \'%s\' initialization: ' % ob.name,
                True)[0]
            
            # Mark that this constant has been defined.
            defined_constants.add(ob.name)
        
        else:
            init = None
        
        # Append the declaration.
        output.append(generate_declaration_vhdl(ob, init))
        
    return ''.join(output)


def reset(iface, decl, env):
    output = []
    
    # Make sure that the reset specifications only use constant and input
    # objects.
    def reset_access(ob):
        if isinstance(ob.atyp, PredefinedConstant):
            return True
        if isinstance(ob.atyp, Constant):
            return True
        if isinstance(ob.atyp, Input):
            return True
        return False
    env = env.with_access_check(reset_access)
    
    # Gather all register-like objects.
    obs = [x[1] for x in iface if x[0] == 'ob' and x[1].atyp.name() == 'output']
    obs += [x for x in decl if x.atyp.name() == 'register']
    
    # Loop over all and generate all of them.
    for ob in obs:
        if ob.initspec is None:
            raise Exception('Output or register object without reset: \'%s\'.' % ob.name)
        output.append(transform_assignment(
            ob, ob.initspec, ob.origin, {}, env,
            'in output/register \'%s\' reset: ' % ob.name)[0])
    
    return indentify(''.join(output), 'vhdl')
    