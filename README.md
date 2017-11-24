
ruby\_abc ruby C extension
==========================

**ruby\_abc** is a ruby C extension wrapping the Berkeley logic synthesis system *abc*.

*abc* is a system for sequential synthesis and verification,
developped at the University of California, Berkeley.
*abc* documentation can be found on its website:  
[http://people.eecs.berkeley.edu/~alanmi/abc/](https://people.eecs.berkeley.edu/~alanmi/abc/)

The source code of *abc* is included in this gem, 
it was cloned on 2017/11/22 from :  
[https://bitbucket.org/alanmi/abc](https://bitbucket.org/alanmi/abc)


Goal
----

The *abc* program is a command line interface: the user issues commands and adjust them according to the results he gets back.
For example, the user can iterrate through minimization commands, and stops when the number of nodes of the logic network stops decreasing.

To automate this process, it is possible to give *abc* a predefined sequence of commands.
In this case, however, the number of minimization command can be too short, and the resulting network will be bigger than it could be.
The number of minimization command can also be too big, and the process will take more time than needed to execute.

In order to solve this process, *ruby_abc* allows to retreive some information on the current logic network in ruby, 
such as the number of nodes or its logic level, to allow automation. 
In the example of the minimization of a logic network, minimization commands are sent to *abc* in a ruby loop which breaks 
when the number of nodes stops decreasing.


Example
-------

```ruby
require 'ruby_abc'

## Load a netlist ##
ABC.read 'test/generic_netlist.blif'

## Print informations on the logic network ##
ABC.print_stats
puts ABC.nb_nodes

## Minimize the network ##
ABC.optimize # itera through minimization commands and stops when the number of nodes reach a plateau

## Retime the network ##
ABC.retime

## Map the network to 4-intpu LUTs (break the network in logic functions not exceeding 4 inputs) ##
n_nodes = ABC.nb_nodes
loop do
	ABC.run_command 'choice; if -K 4; ps'
	break if ABC.nb_nodes == n_nodes
	n_nodes = ABC.nb_nodes
end
# is equivalent to:
ABC.map 4

## Write the network to an output file ##
ABC.write 'mapped_netlist.blif'
```

Installation
------------

To install *ruby_abc* from the git repository:

```lang-none
$ git clone https://github.com/TheotimeBollengier/ruby_abc
$ cd ruby_abc
$ gem build ruby_abc.gemspec
$ gem install ruby_abc.<version>.gem
```

Alternatively, *ruby_abc* gem is also hosted on RubyGems ([https://rubygems.org/gems/ruby_abc](https://rubygems.org/gems/ruby_abc)).
So you can simply type:

```lang-none
$ gem install ruby_abc
```

This will build *abc* and the *ruby_abc* extension, and install it.
Building *abc* may take quite some time.

As this gem includes a C extension, building it requires the ruby developpement headers.
On Debian, you can get them with:

```lang-none
$ sudo apt-get install ruby-dev 
```


Executable
----------

To use *ruby_abc* directly from a terminal or a Makefile,
this gem also include the `ruby_abc` executable script, which uses command line arguments.

```lang-none
$ ruby_abc --help
Usage: rubyabc_synthesis [options] -i <input_file> -o <output_file>
 -i, --input FILE                 Input BLIF file
 -o, --output FILE                Output netlist to FILE
 -r, --retime                     Retime netlist
 -z, --zero                       Set latches initial value to zero
 -l, --lcorr                      Computes latch correspondence using 1-step induction
 -a, --area                       Optimize for area instead of performance (minimize the number of nodes instead of the logic level)
 -w, --sweep                      Sweep logic network to remove dangling nodes
 -k, --lut_inputs K               Map to K-input LUTs.
 -h, --help                       Display this help
```

The *abc* executable is also included so that it can be used natively without ruby.


Documentation
-------------

Html documentation for *ruby_abc* can be generated with `rake doc`.
This documentation covers only the API of *ruby_abc*, not *abc* itself.
*abc* documentation can be found on [http://people.eecs.berkeley.edu/~alanmi/abc/](https://people.eecs.berkeley.edu/~alanmi/abc/).
Also, available *abc* commands can be retreived with `ABC.help` (in ruby), 
and specific command documentation can be seen with `ABC.run_command('<command_name> -h')` (in ruby).


Test
----

`$ rake test` will execute `test/test_ruby_abc.rb`.
This will read a BLIF netlist, optimize it and check the result against a golden model.

