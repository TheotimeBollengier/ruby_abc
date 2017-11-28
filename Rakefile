require 'rake'
require 'mkmf'
require 'fileutils'

root_path = File.dirname(File.expand_path(__FILE__))
ext_path  = File.join(root_path, 'ext')
test_path = File.join(root_path, 'test')
lib_path  = File.join(root_path, 'lib')
ilib_path = File.join(lib_path,  'ruby_abc')
abc_path  = File.join(ext_path,  'abc')


rubyabcext  = File.join(ilib_path, 'ruby_abc.so')
rubyabcsrc  = Rake::FileList["#{ext_path}/*.c", "#{ext_path}/*.h"]
abcsrc      = Rake::FileList["#{abc_path}/**/*.c", "#{abc_path}/**/*.h"]
libabc      = File.join(abc_path, 'libabc.so')
docsrcfiles = Rake::FileList["#{ext_path}/*.c", "#{ext_path}/*.h", "lib/ruby_abc.rb", "README.md"]


desc 'build the gem'
task :default => :compile

desc 'build extension'
task :compile => rubyabcext

desc 'compile extension'
task rubyabcext => ([libabc] + rubyabcsrc) do
	wd = Dir.getwd
	Dir.chdir ext_path
	sh "ruby extconf.rb"
	sh "make"
	Dir.chdir wd
	sh "mkdir -p '#{ilib_path}'"
	sh "cp '#{File.join(ext_path, 'ruby_abc.so')}' '#{rubyabcext}'"
end

desc 'compile libabc.so and abc'
task libabc => abcsrc do
	abort "Library libpthread was not found" if !have_library('pthread')
	abort "Library libdl was not found"      if !have_library('dl')
	#abort "Library librt was not found"      if !have_library('rt') ## librt.a is not on Mac OS
	wd = Dir.getwd
	Dir.chdir(abc_path)
	sh "make -j4 ABC_USE_PIC=true OPTFLAGS='-O2' ABC_USE_NO_READLINE=true libabc.so"
	sh "make     ABC_USE_PIC=true OPTFLAGS='-O2' ABC_USE_NO_READLINE=true abc"
	Dir.chdir(wd)
	FileUtils.move(File.join(abc_path, 'abc'), File.join(root_path, 'bin', 'abc'), force: true)
end

desc 'Test ruby_abc'
task :test => rubyabcext do
	sh "ruby '#{File.join(test_path, 'test_ruby_abc.rb')}'"
end

desc 'Generate html documentation'
task :doc  do
	sh "rdoc --main=README.md --title='ruby_abc ruby extension' --output='#{File.join(root_path, 'doc')}' #{docsrcfiles}"
end

desc 'Cleanup build files'
task :clean do
	extmakefile = File.join(ext_path, 'Makefile')
	if File.exist? extmakefile
		wd = Dir.getwd
		Dir.chdir ext_path
		sh "make -f '#{extmakefile}' clean" 
		Dir.chdir wd
	end

	abcmakefile = File.join(abc_path, 'Makefile')
	if File.exist? abcmakefile
		wd = Dir.getwd
		Dir.chdir abc_path
		sh "make -f '#{abcmakefile}' clean" 
		Dir.chdir wd
	end

	sh "rm -rvf '#{File.join(root_path, 'doc')}'"
end

desc 'Cleanup everyting'
task :mrproper => :clean do
	sh "rm  -vf '#{File.join(ext_path, 'Makefile')}'"
	sh "rm -rvf '#{ilib_path}'"
	sh "rm  -vf '#{File.join(root_path, 'bin', 'abc')}'"
end

