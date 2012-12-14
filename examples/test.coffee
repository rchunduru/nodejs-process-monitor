respawn = require '../lib/respawn'
        
options = []
options.push "-fS"


udhcpd = new respawn

udhcpd.watch_directory("/tmp/config")

udhcpd.register_binary("udhcpd", "/usr/sbin", options)

