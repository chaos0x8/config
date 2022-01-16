namespace(:vim) {
  pkgs = InstallPkg.new { |t|
    t.name = :install_vim_pkgs
    t.pkgs << ['vim-nox', 'rcs', 'silversearcher-ag']
  }

  vimrc = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.vimrc')
    t.requirements << 'vimrc'
    t.action = proc { |dst, src|
      FileUtils.cp src, dst, verbose: true
    }
  }

  pathogen = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.vim', 'vim-pathogen')
    t.action = proc { |dst|
      if File.directory?(dst)
        Dir.chdir(dst) do
          sh 'git', 'pull', '-r'
        end
      else
        Dir.chdir(File.dirname(dst)) {
          sh 'git', 'clone', 'https://github.com/tpope/vim-pathogen.git'
        }
      end
    }
  }

  autol = GeneratedFile.new { |t|
    t.name = File.join(ENV['HOME'], '.vim', 'autoload', 'pathogen.vim')
    t.requirements << pathogen
    t.action = proc { |dst, src|
      if File.exist? dst
        FileUtils.touch dst
      else
        FileUtils.ln_s File.expand_path(File.join(src, 'autoload/pathogen.vim')), dst, verbose: true
      end
    }
  }

  syntax = Dir['vim/syntax/*'].collect { |fn|
    GeneratedFile.new { |t|
      t.name = File.join(ENV['HOME'], '.vim', 'syntax', File.basename(fn))
      t.requirements << fn
      t.action = proc { |dst, src|
        FileUtils.cp src, dst, verbose: true
      }
    }
  }

  bundleList = ['https://github.com/mileszs/ack.vim.git', 'https://github.com/scrooloose/nerdtree.git']
  bundle = bundleList.collect { |uri|
    GeneratedFile.new { |t|
      t.name = File.join(ENV['HOME'], '.vim', 'bundle', File.basename(uri).chomp('.git'))
      t.action = proc { |fn|
        if File.directory?(fn)
          Dir.chdir(fn) do
            sh 'git', 'pull', '-r'
          end
        else
          Dir.chdir(File.dirname(fn)) {
            sh 'git', 'clone', uri
          }
        end
      }
    }
  }

  plugin = Dir['vim/plugin/*'].collect { |fn|
    GeneratedFile.new { |t|
      t.name = File.join(ENV['HOME'], '.vim', 'plugin', File.basename(fn))
      t.requirements << fn
      t.action = proc { |dst, src|
        FileUtils.cp src, dst, verbose: true
      }
    }
  }

  C8.task('plugin-remove-old') {
    Dir[File.join(ENV['HOME'], '.vim', 'plugin', '*')].each { |fn|
      if Dir[File.join('vim', 'plugin', File.basename(fn))].size == 0
        FileUtils.rm fn, verbose: true
      end
    }
  }

  C8.task(bundle: Names[bundle, pathogen])
  C8.multitask(plugin: Names[vimrc, syntax, plugin, autol])

  desc 'Installs vim configuration'
  C8.task(install: Names[pkgs, 'vim:plugin-remove-old', 'vim:bundle', 'vim:plugin'])
}
