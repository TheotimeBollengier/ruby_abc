#include <ruby.h>
#include "ruby_abc_wrapper.h"


static int rubyabc_echo_commands = 1;


/* call-seq:
 * nb_ands -> integer or nil
 *
 * Return the number of AND gate in the network.  
 * If no network have been loaded or the then network is not in AIG form, return +nil+.
 *
 *  ABC.nb_ands #=> 264
 */
static VALUE rubyabc_n_ands(VALUE self)
{
	int res = rubyabc_c_n_ands();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * nb_nodes -> integer or nil
 *
 * Return the number combinatorial logic nodes in the network.  
 * If no network have been loaded or the then network is in AIG form, return +nil+.
 *
 *  ABC.nb_nodes #=> 114
 */
static VALUE rubyabc_n_nodes(VALUE self)
{
	int res = rubyabc_c_n_nodes();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * nb_primary_inputs -> integer or nil
 *
 * Return the number of primary inputs of the network.  
 * If no network have been loaded, return +nil+.
 *
 *  ABC.nb_primary_inputs #=> 7
 */
static VALUE rubyabc_n_pis(VALUE self)
{
	int res = rubyabc_c_n_pis();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * nb_primary_outputs -> integer or nil
 *
 * Return the number of primary outputs of the network.  
 * If no network have been loaded, return +nil+.
 *
 *  ABC.nb_primary_outputs #=> 6
 */
static VALUE rubyabc_n_pos(VALUE self)
{
	int res = rubyabc_c_n_pos();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * nb_latches -> integer or nil
 *
 * Return the number of latches in the network.  
 * If no network have been loaded, return +nil+.
 *
 *  ABC.nb_latches #=> 17
 */
static VALUE rubyabc_n_latches(VALUE self)
{
	int res = rubyabc_c_n_latches();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * nb_levels -> integer or nil
 *
 * Return the number of logic levels.  
 * This is the number of combinatorial logic between two latches
 * or primary input/output.
 * If no network have been loaded, return +nil+.
 *
 *  ABC.nb_latches #=> 8
 */
static VALUE rubyabc_n_levels(VALUE self)
{
	int res = rubyabc_c_n_levels();

	if (res < 0)
		return Qnil;

	return INT2NUM(res);
}


/* call-seq:
 * run_command (string)
 *
 * Run the command +string+ in ABC.
 *
 * If ABC::echo_commands has been set to true, +string+ will be echoed on STDOUT before it is given to +abc+.
 *
 *  ABC.run_command 'read netlist.blif; strash; resyn; if -K 4; write out.blif'
 *  # To see available ABC commands:
 *  ABC.run_command 'help'
 *
 *  # To get help on a particular command, use `-h' after the command name:
 *  ABC.run_command 'csweep -h'
 */
static VALUE rubyabc_run_command(VALUE self, VALUE cmd)
{
	Check_Type(cmd, T_STRING);

	if (rubyabc_echo_commands)
		rb_io_puts(1, &cmd, rb_stdout);

	if (rubyabc_c_run_command(StringValueCStr(cmd)))
		return Qfalse;

	return Qtrue;
}


/* call-seq:
 * echo_commands -> true or false
 *
 * Return if each command received is echoed back.
 *
 *  ABC.echo_commands #=> true
 */
static VALUE rubyabc_get_echo_commands(VALUE self)
{
	if (rubyabc_echo_commands)
		return Qtrue;
	return Qfalse;
}


/* call-seq:
 * echo_commands= (boolean)
 *
 * Set whether each command is echoed or not.
 *
 *  ABC.echo_commands = false
 */
static VALUE rubyabc_set_echo_commands(VALUE self, VALUE b)
{
	if (b == Qtrue)
		rubyabc_echo_commands = 1;
	else if (b == Qfalse || b == Qnil)
		rubyabc_echo_commands = 0;
	else
		rb_raise(rb_eTypeError, "expecting true or false");

	return Qnil;
}


/* Document-module: ABC
 *
 * ABC module wrapps the command line interface of the Berkeley +abc+ program.
 * +abc+ is a system for sequential synthesis and verification, developped at the University of California, Berkeley.
 * Documentation on ABC can be found at [http://people.eecs.berkeley.edu/~alanmi/abc/](https://people.eecs.berkeley.edu/~alanmi/abc/)
 *
 * The +abc+ program is a command line interface: the user issue commands and adjust them according to the results he gets back.
 * In order to automate this process, the ABC module allows to retreive some information on the logic network in ruby, 
 * such as the number of nodes or its logic level. The command adjustment can then be done in ruby instead of manually.
 *
 * +abc+ commands are issued with the ABC::run_command module method, thus the +abc+ documentation is not covered in this API documentation.
 * However, available commands can be retreived with ABC::run_command('help'), 
 * and the documentation of a given command can be retreived with ABC::run_command('command_name -h').
 */
void Init_ruby_abc() 
{
	VALUE rubyabc_mABC;

	rubyabc_mABC = rb_define_module("ABC");
	rb_define_module_function(rubyabc_mABC, "nb_ands",            rubyabc_n_ands,            0);
	rb_define_module_function(rubyabc_mABC, "nb_nodes",           rubyabc_n_nodes,           0);
	rb_define_module_function(rubyabc_mABC, "nb_primary_inputs",  rubyabc_n_pis,             0);
	rb_define_module_function(rubyabc_mABC, "nb_primary_outputs", rubyabc_n_pos,             0);
	rb_define_module_function(rubyabc_mABC, "nb_latches",         rubyabc_n_latches,         0);
	rb_define_module_function(rubyabc_mABC, "nb_levels",          rubyabc_n_levels,          0);
	rb_define_module_function(rubyabc_mABC, "run_command",        rubyabc_run_command,       1);
	rb_define_module_function(rubyabc_mABC, "echo_commands",      rubyabc_get_echo_commands, 0);
	rb_define_module_function(rubyabc_mABC, "echo_commands=",     rubyabc_set_echo_commands, 1);

	rubyabc_c_start();
	rubyabc_c_run_command("set check");
	rubyabc_c_run_command("alias ps      print_stats");
	rubyabc_c_run_command("alias st      strash");
	rubyabc_c_run_command("alias ssw     ssweep");
	rubyabc_c_run_command("alias b       balance");
	rubyabc_c_run_command("alias rw      rewrite");
	rubyabc_c_run_command("alias rwz     rewrite -z");
	rubyabc_c_run_command("alias rf      refactor");
	rubyabc_c_run_command("alias rfz     refactor -z");
	rubyabc_c_run_command("alias rs      resub");
	rubyabc_c_run_command("alias rsz     resub -z");
	rubyabc_c_run_command("alias resyn   \"b; rw; rwz; b; rwz; b\"");
	rubyabc_c_run_command("alias resyn2  \"b; rw; rf; b; rw; rwz; b; rfz; rwz; b\"");
	rubyabc_c_run_command("alias resyn3  \"b; rs; rs -K 6; b; rsz; rsz -K 6; b; rsz -K 5; b\"");
	rubyabc_c_run_command("alias choice  \"fraig_store; resyn; fraig_store; resyn2; fraig_store; fraig_restore\"");
	rubyabc_c_run_command("alias choice2 \"fraig_store; balance; fraig_store; resyn; fraig_store; resyn2; fraig_store; resyn2; fraig_store; fraig_restore\"");
}

