namespace(:bash) {
  bashrc = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.bashrc')
    t.requirements << 'bashrc'
    t.action = proc { |dst, src|
      FileUtils.cp src, dst, verbose: true
    }
  }

  desc 'Installs bash configuration'
  C8.task(install: Names[bashrc])
}

