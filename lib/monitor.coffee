fs = require 'fs'
class child
    constructor: ->
        console.log 'initialized'

    start: (binary, binarypath, options, callback) ->
        spawn = require('child_process').spawn
        cmd = "#{binarypath}/#{binary}"
        console.log 'about to execute command ' + cmd
        console.log options

#        log = fs.openSync("/tmp/log.log", 'a')
#        additionalOptions=
#            detached:true
#            stdio: ["ignore", log, log]
#        @startchild = spawn(cmd,options,additionalOptions)
        @startchild = spawn(cmd,options)

        @startchild.stderr.on 'data', (data) ->
            console.log 'recvd stderror ' + data
            #callback(data, '', '')

#        @startchild.stdout.on 'data', (data) ->
#            console.log 'rcvd data ' + data

        @childpid = @startchild.pid
        console.log 'pid of the binary executed is ' + @childpid

        @startchild.on 'exit', (code, signal) =>
            if code
                console.log 'exit code is ' + code
            if signal
                console.log 'signal sent by parent to the child ' + signal
            callback(code, signal) unless signal=='SIGUSR1'


    kill: (signal, callback) ->
        console.log 'signali ' + signal + ' to ' +  @startchild.pid
        @startchild.kill(signal)
        callback(true)

    disconnect: (callback) ->
        console.log 'signal SIGUSR1' + ' to ' +  @startchild.pid
        @startchild.kill('SIGUSR1')
        callback(true)


        
            

class monitor
    constructor:  ->
        console.log 'monitor initialized'
        @watched = {}

    add: (cmd, binaryPath, options, file) ->
        program = {}
        program.cmd = cmd
        program.path = binaryPath
        program.options = options
        @watched.program = program
        @watched.file = file


    startMonitor: (callback) ->
        binary  = new child
        console.log @watched.program
        program = @watched.program
        @watched.binary = binary

        binary.start program.cmd, program.path, program.options, (code, signal) =>
            if code == 1
                console.log 'program terminated'
                err = new Error "program terminated due to config error"
                callback(err)
               
            else if signal == 'SIGUSR1'
                console.log 'We are done watching the binary ' + program.cmd

            else
                console.log 'code is ' + code + ' signal is ' + signal
                console.log 'our monitored program is terminated: ' + program.cmd + ' pid is ' + @watched.binary.pid
                @startMonitor (error)->
                    if error
                        console.log 'Not able to start the monitor'
                        console.log error
        callback()

    watch: (directory)  =>
        fs.watch directory, (event, filename) =>
            console.log 'event is ' + event + ' below are the files '
            console.log filename,  @watched.file
            if filename == @watched.file
                # Now restart the process
                console.log 'restarting the binary ' + @watched.program.cmd + ' with pid ' + @watched.binary.pid
                @kill (result) ->
                    console.log 'killed to restart the watched binary'
            else
                console.log 'an unwanted file changed'
                


    kill: (callback)->
        console.log 'signalling binary with pid ' + @watched.binary.pid
        @watched.binary.kill('SIGHUP', callback)

    pid: ->
        return @watched.binary.childpid

    stop: (callback) ->
        console.log 'stopping the watcher'
        @watched.binary.disconnect(callback)
        #process.exit(0)




module.exports.monitor = monitor
module.exports.child = child

