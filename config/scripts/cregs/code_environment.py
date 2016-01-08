import re
from code_types import *
from code_output import *

class NamError(Exception):
    
    def __init__(self, message):
        self.message = message
    
    def __str__(self):
        return repr(self.message)


class Object(object):
    
    def __init__(self, owner, name, atyp, origin='<internal>', initspec=None):
        """Creates an Object. An object is an input, output, register, variable
        or constant made available to the user."""
        
        if name.startswith('_') and owner is not None:
            name = owner + name
        
        if atyp.needs_init() and initspec is None:
            raise Exception('%s %s needs an init/reset spec but does not have one.' %
                            (atyp, name))
        
        self.owner = owner
        self.name = name
        self.atyp = atyp
        self.origin = origin
        self.initspec = initspec
        self.init = None
        self.decl = None
        
        # Whether this object has ever been used.
        self.used = False
        
        # Whether this object has ever been assigned.
        self.assigned = False
        
    def parse_init(self, env):
        """Parses the init/reset specification."""
        # TODO
        pass
    
    def get_decl(self, lang):
        """Returns the object declaration code in the given language.
        
        lang must be 'vhdl' or 'c'."""
        
        if self.atyp.needs_init() and self.init is None:
            raise Exception('%s %s needs an init/reset spec but it has not been parsed yet.' %
                            (self.atyp, self.name))
        if self.decl is None:
            self.decl = declare(self)
        if lang == 'vhdl':
            return self.decl.output_vhdl(0)
        elif lang == 'c':
            return self.decl.output_c(0)
        else:
            raise Exception('Invalid language %s.' % lang)
        
    def __str__(self):
        return '%s %s' % (self.atyp, self.name)
    
    __repr__ = __str__
    

class Environment:
    
    def __init__(self):
        self.objects = {}
        self.implicit_ctxt = None
        self.user = ''
    
    def copy(self):
        e = Environment()
        e.objects = self.objects.copy()
        e.implicit_ctxt = self.implicit_ctxt
        e.user = self.user
        return e
    
    def declare(self, ob):
        """Adds an object to the environment. Raises a NamError if the name is
        already in use or if the name is invalid."""
        
        # Check whether the name is valid.
        if re.match(r'[a-zA-Z0-9][a-zA-Z0-9_]*$', ob.name) is None:
            raise NamError('Illegal object name \'%s\', declared after line %s.' %
                           (ob.name, ob.origin))
        
        # Make sure the name is not already in use.
        if ob.name.lower() in self.objects:
            conflict = self.objects[ob.name.lower()]
            raise NamError(('Name %s, declared after line %s, is already in use. ' +
                           'Conflicts with %s, declared after line %s.') %
                           (ob.name, ob.origin, conflict, conflict.origin))
        
        # Add the object. Note that we use lower() to make names
        # case-insensitive. This is necessary to be compatible with VHDL.
        self.objects[ob.name.lower()] = ob
    
    def parse_init(self):
        """Parses the reset/init specifications for all objects which need
        it."""
        for name in self.objects:
            ob = self.objects[name]
            if ob.atyp.needs_init():
                ob.parse_init(self)
    
    def set_implicit_ctxt(self, ctxt):
        """Sets the context which is implicitely accessed by per-context
        generated code. Typically this will be the loop iteration variable
        name, or None for globol code."""
        self.implicit_ctxt = ctxt
    
    def set_user(self, user):
        """Sets the current user, i.e. 'cr_<reg>_<field>' or ''."""
        self.user = user
    
    def lookup(self, name):
        """Looks up a name. name is of the format [<owner>]_<name>[@<ctxt>].
        If <owner> is not specified, user is used. If <ctxt> is not specified,
        implicit_ctxt is used. If <ctxt> IS specified, but the lookup does not
        resolve to a context-specific object, a NamError is raised. A NamError
        is also raised if the lookup failed entirely, or if <owner> != user for
        a local object.
        
        Returns a two-tuple: (object, ctxt). ctxt is always None for globals
        and always an Expression for context-specific objects."""
        
        # Extract the explicit context from the name.
        name = name.split('@', 1)
        ctxt = None
        if len(name) == 2:
            ctxt = name[1]
        name = name[0]
        
        # If name starts with an underscore, prefix user (abbreviated syntactic
        # sugar for locals).
        if name.startswith('_'):
            name = self.user + name
        
        # Look up the variable.
        if name.lower() not in self.objects:
            raise NamError('Undefined object \'%s\'.' % name)
        ob = self.objects[name.lower()]
        
        # Raise an error if this is a local and we're not the owner.
        if ob.atyp.is_local() and self.user.lower() != ob.owner.lower():
            raise NamError('Cannot access local \'%s\' from %s.' %
                           (ob.name, self.user))
        
        # Raise an error if a context is explicitly specified if this is a
        # global object.
        cxspec = ob.atyp.typ.exists_per_context()
        if not cxspec and ctxt is not None:
            raise NamError('Cannot apply @ context selection syntax to ' +
                           'global \'%s\'.' % ob.name)
        if cxspec and ctxt is None:
            ctxt = self.implicit_ctxt
            if ctxt is None:
                raise NamError('Cannot access context-specific object ' +
                               '\'%s\' without context.' % ob.name)
        
        # Look up the context if one is needed.
        if ctxt is not None:
            
            # Get an Expression for ctxt.
            ctxt = self.read(ctxt)
            
            # Typecast the Expression if needed.
            ctxt = ctxt.cast(Natural())
        
        # Lookup successful.
        return (ob, ctxt)

    def __str__(self):
        return '\n'.join([str(self.objects[key]) for key in self.objects])
    
    __repr__ = __str__
