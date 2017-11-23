
ruby\_abc ruby C extension
==========================

**ruby\_abc** is a ruby C extension wrapping the Berkeley logic synthesis system *abc*.

*abc* is a system for sequential synthesis and verification,
developped at the University of California, Berkeley.
Documentation on *abc* can be found on its website:  
[http://people.eecs.berkeley.edu/~alanmi/abc/](https://people.eecs.berkeley.edu/~alanmi/abc/)

The source code of *abc* is included in this gem, 
it was cloned on 2017/11/22 from :  
[https://bitbucket.org/alanmi/abc](https://bitbucket.org/alanmi/abc)
It is under MIT license.


Goal
----

The *abc* program is a command line interface: the user issue commands and adjust them according to the results he gets back.
In order to automate this process, the *ruby_abc* allows to retreive some information on the current logic network in ruby, 
such as the number of nodes or its logic level. The command adjustment can then be done in ruby instead of manually.


Installation
------------

```lang-none
$ gem install ruby_abc
```

This will build *abc* and the ruby\_abc extension, test and install it.
Building *abc* may be quite long.

To build the gem, you will need the ruby developpement headers.
On Debian:

```lang-none
$ sudo apt-get install ruby-dev 
```

Example
-------

```ruby
require 'ruby_abc'

## Load a netlist ##
ABC.read 'test/generic_netlist.blif'

## Print informations on the logic network ##
ABC.print_stats
puts ABC.nb_nodes

## Minimize number the of nodes of the network ##
ABC.optimize

## Retime the network ##
ABC.retime

## Map the network to 4-intpu LUTs ##
n_nodes = ABC.nb_nodes
loop do
	ABC.run_command 'choice; if -K 4 -a; ps'
	break if ABC.nb_nodes == n_nodes
	n_nodes = ABC.nb_nodes
end
# is equivalent to:
ABC.map 4

## Write the network to an output file ##
ABC.write 'mapped_netlist.blif'
```

Executable
----------

This gem also include the `rubyabc_synthesis` executable (a ruby script)
allowing to synthesize netlists directly from a terminal.

```lang-none
$ rubyabc_synthesis --help
Usage: rubyabc_synthesis [options] -i <input_file> -o <output_file>
 -i, --input FILE                 Input BLIF file
 -o, --output FILE                Output netlist to FILE
 -r, --retime                     Retime netlist
 -z, --zero                       Set latches initial value to zero
 -l, --lcorr                      Computes latch correspondence using 1-step induction
 -a, --area                       Optimize in area
 -w, --sweep                      Sweep logic network to remove dangling nodes
 -k, --lut_inputs K               Map to K-input LUTs.
 -h, --help                       Display this help
```

