def os_family
  case RUBY_PLATFORM
  when /ix/i, /ux/i, /gnu/i,
    /sysv/i, /solaris/i,
    /sunos/i, /bsd/i
    "unix"
  when /win/i, /ming/i
    "windows"
  else
    "others"
  end
end

def sys_script_ext
  os_family == 'unix' ? 'sh' : 'cmd'
end
