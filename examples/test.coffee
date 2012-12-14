respawn = require '../lib/respawn'
        
file = "/etc/udhcpd.conf"
options = []
options.push "-fS"
options.push "/etc/udhcpd.conf"
options.push "&"


udhcpd = new respawn

udhcpd.watch_directory("/tmp/config")

udhcpd.register_binary("udhcpd", "/usr/sbin", options)

