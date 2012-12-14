monitor = require '../lib/monitor'
        
file = "/etc/udhcpd.conf"
options = []
options.push "-fS"
options.push "/etc/udhcpd.conf"
options.push "&"

udhcpd = new monitor
udhcpd.add "udhcpd", "/usr/sbin", options, file

udhcpd.startMonitor (err) =>
    if err instanceof Error
        console.log 'error in starting the monitorr'
        udhcpd.stop (result) ->
            console.log 'stopped check the errors'
            console.log err
            process.exit(1)

udhcpd.watch('/etc/udhcpd.conf')
pid = udhcpd.pid()
console.log 'udhcpd pid is ' + pid
