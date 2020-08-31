namespace(:sqlite) {
  sqliterc = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.sqliterc')
    t.requirements << 'sqliterc'
    t.action = proc { |dst, src|
      FileUtils.cp src, dst, verbose: true
    }
  }

  desc 'Installs sqlite configuration'
  C8.task(install: Names[sqliterc])
}
