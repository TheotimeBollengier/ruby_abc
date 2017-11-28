#! /usr/bin/env ruby

require_relative 'ruby_abc/ruby_abc.so'


module ABC
	VERSION = '0.0.5'

	##
	# call-seq:
	# print_stats
	#
	# Print out network statistics.
	#
	#  ABC.print_stats
	#  # Inputs: ..... 7
	#  # Outputs: .... 6
	#  # Nodes: .... 114
	#  # Latches: ... 17
	#  # Levels: .... 18
	#  #=> nil
	#
	def self.print_stats
		n_pis     = ABC::nb_primary_inputs
		n_pos     = ABC::nb_primary_outputs
		n_nodes   = ABC::nb_nodes
		n_latches = ABC::nb_latches
		n_levels  = ABC::nb_levels
		n_ands    = ABC::nb_ands

		arr = [n_pis, n_pos, n_nodes, n_latches, n_levels, n_ands].reject{|v| v.nil?}
		return nil if arr.empty?
		max_len = arr.collect{|v| v.to_s.length}.max + 1

		puts "Inputs: ...#{(' ' + n_pis.to_s).rjust(max_len, '.')}"     if n_pis
		puts "Outputs: ..#{(' ' + n_pos.to_s).rjust(max_len, '.')}"     if n_pos
		puts "Nodes: ....#{(' ' + n_nodes.to_s).rjust(max_len, '.')}"   if n_nodes
		puts "Latches: ..#{(' ' + n_latches.to_s).rjust(max_len, '.')}" if n_latches
		puts "Levels: ...#{(' ' + n_levels.to_s).rjust(max_len, '.')}"  if n_levels
		puts "And gates: #{(' ' + n_ands.to_s).rjust(max_len, '.')}"    if n_ands
		return nil
	end # ABC::print_stats


	##
	# call-seq:
	# optimize -> nb_ands
	#
	# Combinatorial synthesis of the network. 
	# This method loops the command "resyn; resyn2, resyn3, print_stats" and stops when the number of AND gates stop decreasing.
	# At the end, the logic network is in AIG form.
	#
	# "Fast and efficient synthesis is achieved by DAG-aware rewriting of the AIG. i
	# Rewriting is performed using a library of pre-computed four-input AIGs (command rewrite; standard alias rw), 
	# or collapsing and refactoring of logic cones with 10-20 inputs (command refactor; standard alias rf). 
	# It can be experimentally shown that iterating these two transformations and interleaving them with AIG balancing 
	# (command balance; standard alias b) substantially reduces the AIG size and tends to reduce the number of AIG levels."
	#
	#  ABC.optimize
	#
	def self.optimize
		n_ands = ABC::nb_ands
		loop do
			ABC::run_command('resyn; resyn2; resyn3; ps')
			new_n_ands = ABC::nb_ands
			break unless new_n_ands < n_ands
			n_ands = new_n_ands
		end 
		return ABC::nb_ands
	end # ABC::optimize


	##
	# call-seq:
	# map (lut_size, optimize_for_area = false) -> nb_nodes
	#
	# Map the logic network to nodes with at most +lut_size+ inputs.
	# If +optimize_for_area+ is true, minimize the number of nodes instead of minimizing the logic level of the network.
	#
	# This method loops the command: 
	#  "choice; if -K #{lut_size}#{optimize_for_area ? ' -a':''}; ps"
	# and stops when the number of nodes stop decreasing.
	#
	#  ABC.map(4)
	#
	def self.map (k, optimize_area = false)
		map_cmd = "choice; if -K #{k}#{optimize_area ? ' -a':''}; ps"

		n_nodes = -1
		loop do
			ABC::run_command(map_cmd)
			new_n_nodes = ABC::nb_nodes
			break if new_n_nodes >= n_nodes and n_nodes > 0
			n_nodes = new_n_nodes
		end
		return ABC::nb_nodes
	end # ABC::map


	##
	# call-seq:
	# method_missing(method, *args)
	#
	# The +method_missing+ method is implemented so that commands can be issued to +abc+ without using ABC::run_command.
	# Methods arguments are concatenated as strings to the command.
	#
	#  ABC.read '-m', filename
	#  # equivalent to
	#  ABC.run_command "read -m #{filename}"
	#
	def self.method_missing (name, *args)
		cmd = name.to_s
		cmd += ' ' + args.join(' ') if args
		ABC::run_command cmd
	end # ABC::missing_method


	##
	# call-seq:
	# synthesis (input: nil, output: nil, zero: false, sweep: false, retime: false, lcorr: false, area: false, lut_map: nil, help: nil)
	#
	# This method is an atempt to automate the logic synthesis process (combinatorial and sequential) according to some parameters.
	#
	# Keyword parameters are:
	# * +input:+   (string)  Input netilist file name
	# * +output:+  (string)  Output netlist file name
	# * +zero:+    (boolean) Set latches initial value to zero (netlist functionality is keept by adding inverters around latches with initial value 1)
	# * +sweep:+   (boolean) Sweep logic network to remove dangling nodes
	# * +retime:+  (boolean) Retime the netlist (reduce logic level, but increase the number of latches)
	# * +lcorr:+   (boolean) Computes latch correspondence using 1-step induction
	# * +area:+    (boolean) Optimize for area (minimize number of nodes) instead of speed (minimize number of logic levels)
	# * +lut_map:+ (integer) Map the netlist to K-input LUTs. Optimize for area if area: == true
	#
	#  ABC.synthesis(input: 'generic.blif', output: 'maped.blif', lcorr: true, lut_map: 4, area: true)
	#
	def self.synthesis(input: nil, output: nil, zero: false, sweep: false, retime: false, lcorr: false, area: false, lut_map: nil, help: nil)
		if help then
			puts <<EOS
ABC::synthesis keyword arguments:
 input:   (string)  Input netilist file name
 output:  (string)  Output netlist file name
 zero:    (boolean) Set latches initial value to zero (netlist functionality is keept by adding inverters around latches with initial value 1)
 sweep:   (boolean) Sweep logic network to remove dangling nodes
 retime:  (boolean) Retime the netlist (reduce logic level, but increase the number of latches)
 lcorr:   (boolean) Computes latch correspondence using 1-step induction
 area:    (boolean) Optimize for area (minimize number of nodes) instead of speed (minimize number of logic levels)
 lut_map: (integer) Map the netlist to K-input LUTs. Optimize for area if area: == true
EOS
			return
		end

		if input then
			raise "Expecting a string for :input argument" unless input.kind_of?(String)
			ABC::read input
		end

		puts "---- Input netlist ----"
		ABC::print_stats
		puts "-----------------------"

		ABC::ps

		if sweep then
			ABC::sweep
			ABC::ps
		end

		if zero and ABC::nb_latches > 0 then
			ABC::run_command 'strash; zero; ps'
		else
			ABC::run_command 'strash; ps'
		end

		ABC::lcorr if (lcorr and ABC::nb_latches > 0)

		if sweep then
			ABC::ssweep
			ABC::csweep
			ABC::ps
		end

		ABC::optimize

		if retime and ABC::nb_latches > 0 then
			level = ABC::nb_levels
			ABC::run_command('retime; strash; ps')
			if ABC::nb_levels >= level then
				ABC::run_command('dretime; strash; ps')
			end
			ABC::optimize
		end

		ABC::zero if zero

		if lut_map then
			raise "Expecting a strictly positive integer for argument :lut_map" unless (lut_map.kind_of?(Integer) and lut_map > 0)
			ABC::map(lut_map, not(not(area)))
		end

		if sweep then
			ABC::run_command 'sop; sweep; resyn; resyn2; resyn3; scleanup; resyn; scleanup; scleanup; scleanup; strash; ssweep; csweep; ps'
			ABC::optimize
			if lut_map then
				raise "Expecting a strictly positive integer for argument :lut_map" unless (lut_map.kind_of?(Integer) and lut_map > 0)
				ABC::map(lut_map, not(not(area)))
			end
		end

		if (lcorr and ABC::nb_latches > 0) then
			ABC::run_command 'strash; lcorr'
			if lut_map then
				raise "Expecting a strictly positive integer for argument :lut_map" unless (lut_map.kind_of?(Integer) and lut_map > 0)
				ABC::map(lut_map, not(not(area)))
			end
		end

		puts "---- output netlist ----"
		ABC::print_stats
		puts "------------------------"

		if output then
			raise "Expecting a string for :output argument" unless output.kind_of?(String)
			puts "Writing output netlist to file \"#{output}\""
			if input then
				ABC.write_hie input, output
			else
				ABC.write output
			end
		end
	end #ABC::synthesis

end # ABC

