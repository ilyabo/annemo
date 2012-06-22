{spawn, exec} = require 'child_process'
path = require 'path'

app = "emotions"
mainfile = "emotions.coffee"


option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `restart`'

task 'build', ->


task 'restart', 'Restart #{app}', (options) ->
  invoke 'build'
  run 'PATH=/usr/bin:/usr/local/bin:/opt/local/bin  && kill -9 `pgrep -f "coffee '+mainfile+'"`'
  run "coffee #{mainfile}"




foreverBinary = "node_modules/forever/bin/forever"
forever = (action, options) ->
  invoke 'build'
  options.environment or= 'production'
  run "NODE_ENV=#{options.environment} " +
      "#{foreverBinary} #{action} -c coffee " +
      " --sourceDir ./" +
      " -l #{app}.log "+
      #" -o logs/#{app}.out "+
      #" -e logs/#{app}.err "+
      " -a" +   # append logs
      " #{mainfile}"


task 'forever-restart', (options) -> forever 'restart', options
task 'forever-start', (options) -> forever 'start', options
task 'forever-stop', (options) -> run "#{foreverBinary} stop -c coffee #{mainfile}"
task 'forever-list', (options) -> run "#{foreverBinary} list"




run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a
  
  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0
