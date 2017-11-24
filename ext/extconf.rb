#!/usr/bin/env ruby

require 'mkmf'

extension_name = 'ruby_abc'

abc_path = File.join(File.dirname(File.expand_path(__FILE__)), 'abc')

$CFLAGS += " -I #{File.join(abc_path, 'src')}"
$CFLAGS += ' ' + `#{File.join(abc_path, 'arch_flags')}`
$LOCAL_LIBS += ' ' + File.join(abc_path, 'libabc.so')

create_makefile(extension_name)

