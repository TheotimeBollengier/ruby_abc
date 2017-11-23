#!/usr/bin/env ruby

require 'mkmf'

extension_name = 'ruby_abc'

abc_path = File.dirname(File.expand_path(__FILE__)) + '/abc'

$CFLAGS += " -I #{abc_path}/src"
$CFLAGS += ' ' + `#{abc_path}/arch_flags`
$LOCAL_LIBS += " #{abc_path}/libabc.so"

create_makefile(extension_name)

