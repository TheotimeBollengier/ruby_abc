#!/usr/bin/env ruby

require_relative '../lib/ruby_abc'

golden_generic_nb_primary_inputs  =   7
golden_generic_nb_primary_outputs =   6
golden_generic_nb_nodes           = 114
golden_generic_nb_latches         =  17
golden_generic_nb_levels          =  18

golden_mapped_nb_primary_inputs  =  7
golden_mapped_nb_primary_outputs =  6
golden_mapped_nb_nodes           = 80
golden_mapped_nb_latches         = 45
golden_mapped_nb_levels          =  6

netlist_filename = File.join(File.dirname(File.expand_path(__FILE__)), 'generic_netlist.blif')

ABC.echo_commands = false

ABC.read netlist_filename

if ABC.nb_primary_inputs != golden_generic_nb_primary_inputs or
		ABC.nb_primary_outputs != golden_generic_nb_primary_outputs or
		ABC.nb_nodes != golden_generic_nb_nodes or
		ABC.nb_latches != golden_generic_nb_latches or
		ABC.nb_levels != golden_generic_nb_levels then
	abort "Test failed: read input netlist mismatch with golden model!"
end

ABC.synthesis input: 'generic_netlist.blif', zero: true, sweep: true, retime: true, lcorr: true, area: true, lut_map: 4

if ABC.nb_primary_inputs != golden_mapped_nb_primary_inputs or
		ABC.nb_primary_outputs != golden_mapped_nb_primary_outputs or
		ABC.nb_nodes != golden_mapped_nb_nodes or
		ABC.nb_latches != golden_mapped_nb_latches or
		ABC.nb_levels != golden_mapped_nb_levels then
	abort "Test failed: synthesized netlist mismatch with golden model!"
end

puts "OK, TEST PASSED"

