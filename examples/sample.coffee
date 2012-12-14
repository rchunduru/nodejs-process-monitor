monitor = require './lib/monitor'
        
file = "/etc/udhcpd.conf"
options = []
options.push "-fS"
options.push file
options.push "&"

udhcpd = new monitor
udhcpd.add "udhcpd", "/usr/sbin", options, file

udhcpd.startMonitor (err) =>
    if err instanceof Error
        console.log 'error in starting the monitorr'
        udhcpd.stop (result) ->
            console.log 'stopped check the errors'
            console.log err

udhcpd.watch("/config/network/udhcpd")
pid = udhcpd.pid()
console.log 'udhcpd pid is ' + pid
