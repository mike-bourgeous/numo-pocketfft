require 'mkmf'
require 'numo/narray'

# XXX don't merge this
puts "Git submodule update:"
puts `git submodule update`

$LOAD_PATH.each do |lp|
  if File.exist?(File.join(lp, 'numo/numo/narray.h'))
    $INCFLAGS = "-I#{lp}/numo #{$INCFLAGS}"
    break
  end
end

unless have_header('numo/narray.h')
  puts 'numo/narray.h not found.'
  exit(1)
end

if RUBY_PLATFORM =~ /mswin|cygwin|mingw/
  $LOAD_PATH.each do |lp|
    if File.exist?(File.join(lp, 'numo/libnarray.a'))
      $LDFLAGS = "-L#{lp}/numo #{$LDFLAGS}"
      break
    end
  end
  unless have_library('narray', 'nary_new')
    puts 'libnarray.a not found.'
    exit(1)
  end
end

$CFLAGS = "#{$CFLAGS} -std=c99"

$srcs = Dir.glob("#{$srcdir}/*.c").map { |path| File.basename(path) }
$srcs << 'pocketfft.c'
Dir.glob("#{$srcdir}/*/") do |path|
  dir = File.basename(path)
  $INCFLAGS << " -I$(srcdir)/#{dir}"
  $VPATH << "$(srcdir)/#{dir}"
end

create_makefile('numo/pocketfft/pocketfftext')
