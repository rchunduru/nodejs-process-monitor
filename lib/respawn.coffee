child = require('./monitor').child
fs = require 'fs'

@db = db = 
    spawn: require('dirty') '/tmp/spawn.db'

class respawn
    constructor: ->
        console.log 'initialized respawn'
        @program = {}
        

    register_binary: (binary, binarypath, options) ->
        @program.binary = binary
        @program.binarypath = binarypath
        @program.options = options
        #@start_binary()

    start_binary: (filename) ->
        pchild =  new child
        entry = db.spawn.get filename
            
        @program.child = pchild.start @program.binary, @program.binarypath, @program.options, (code, signal) =>
            console.log ' code is ' + code + ' signal is ' + signal
            if signal == "SIGUSR1"
                console.log 'User wants to not to start the program'
                # Do nothing
            else if code == 1
                console.log 'program terminated and cannot be started '
            else
                # For all other cases, let us restart the application
                console.log 'restarting the application ' + @program.binary
                db.spawn.forEach (key, val) =>
                    if val == @program.child.pid
                        @start_binary(key)
        console.log @program
        pid = @program.child.pid
        db.spawn.set filename, pid, ->
            console.log  'db set'
          
    
    watch_directory: (directory) ->
        #unless  @program.db
        #    @parse_directory(directory)

        fs.watch directory, (event, filename) =>
            console.log ' Received event ' + event + 'for file ' + filename
            switch (event)
                when "change", "rename" 
                    # Change in filename or renamed, try to bring up the binary
                    # kill it first if existing program using that file
                    entry = db.spawn.get filename
                    console.log 'for filename ' + filename + ' pid is ' + entry
                    if entry
                        try
                            process.kill entry, 'SIGUSR1'
                        catch err
                            console.log err
                    @start_binary(filename)
                         

    parse_directory: (directory)->
        # parse the directory and start binary for each file
        files = fs.readdirSync directory
        for file in files
            @start_binary(file)

                 
module.exports = respawn                    
