require 'rake'
require 'mkmf'

root_path = File.dirname(File.expand_path(__FILE__))
ext_path  = "#{root_path}/ext"
test_path = "#{root_path}/test"
lib_path  = "#{root_path}/lib"
ilib_path = "#{lib_path}/ruby_abc"
abc_path  = "#{ext_path}/abc"


rubyabcext  = "#{ilib_path}/ruby_abc.so"
rubyabcsrc  = Rake::FileList["#{ext_path}/*.c", "#{ext_path}/*.h"]
abcsrc      = Rake::FileList["#{abc_path}/**/*.c", "#{abc_path}/**/*.h"]
libabc      = "#{abc_path}/libabc.so"
docsrcfiles = Rake::FileList["#{ext_path}/*.c", "#{ext_path}/*.h", "lib/ruby_abc.rb", "README.md"]


desc 'build gem, test it and generate html documentaion'
task :default => [:compile, :test, :doc]

desc 'build extension'
task :compile => rubyabcext

desc 'compile extension'
task rubyabcext => ([libabc] + rubyabcsrc) do
	wd = Dir.getwd
	Dir.chdir ext_path
	sh "ruby extconf.rb"
	sh "make"
	Dir.chdir wd
	sh "mkdir -p #{ilib_path}"
	sh "cp #{ext_path}/ruby_abc.so #{rubyabcext}"
end

desc 'compile abc'
task libabc => abcsrc do
	abort "Library libpthread was not found" if !have_library('pthread')
	abort "Library libdl was not found"      if !have_library('dl')
	abort "Library librt was not found"      if !have_library('rt')
	wd = Dir.getwd
	Dir.chdir(abc_path)
	sh "make -j4 ABC_USE_PIC=true OPTFLAGS='-O2' ABC_USE_NO_READLINE=true libabc.so"
	Dir.chdir(wd)
end

desc 'Test ruby_abc'
task :test => rubyabcext do
	sh "ruby '#{test_path}/test_ruby_abc.rb'"
end

desc 'Generate html documentation'
task :doc  do
	sh "rdoc --main=README.md --title='ruby_abc ruby extension' --output='#{root_path}/doc' #{docsrcfiles}"
end

desc 'Cleanup build files'
task :clean do
	extmakefile = "#{ext_path}/Makefile"
	if File.exist? extmakefile
		wd = Dir.getwd
		Dir.chdir ext_path
		sh "make -f '#{extmakefile}' clean" 
		Dir.chdir wd
	end

	abcmakefile = "#{abc_path}/Makefile"
	if File.exist? abcmakefile
		wd = Dir.getwd
		Dir.chdir abc_path
		sh "make -f '#{abcmakefile}' clean" 
		Dir.chdir wd
	end

	sh "rm -rvf '#{root_path}/doc'"
end

desc 'Cleanup everyting'
task :mrproper => :clean do
	sh "rm  -vf '#{ext_path}/Makefile'"
	sh "rm -rvf '#{ilib_path}}'"
end

