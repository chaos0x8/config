require 'tempfile'

namespace(:wpa_supplicant) {
  wpa_supplicant = GeneratedFile.new { |t|
    t.name = '/etc/wpa_supplicant/wpa_supplicant.conf'
    t.requirements << 'templates/wpa_supplicant.conf.erb'
    t.action = proc { |dst, src|
      Tempfile.open(['wpa', '.conf']) { |f|
        $stdout.print "Enter ssid: "
        ssid = $stdin.gets.chomp
        password = C8::Password.aquire('Enter password: ')
        rPassword = C8::Password.aquire('Repeat password: ')

        raise 'Password does not match!' unless password == rPassword

        f.write(
          C8.erb(IO.read(src),
          ssid: ssid.strip, password: password.strip))
        f.close

        sh 'sudo', 'cp', f.path, dst
      }
    }
  }

  desc 'Installs sqlite configuration'
  C8.task(install: Names[wpa_supplicant])
}

