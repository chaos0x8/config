namespace(:screen) {
  screenrc = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.screenrc')
    t.requirements << 'screenrc'
    t.action = proc { |dst, src|
      FileUtils.cp src, dst, verbose: true
    }
  }

  desc 'Installs screen configuration'
  C8.task(install: Names[screenrc])
}

