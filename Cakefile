{spawn, exec} = require 'child_process'
path = require 'path'

videosPath = 'videos'

option '-e', '--environment [ENVIRONMENT_NAME]', 'set the environment for `restart`'

task 'build', ->


task 'restart', 'Restart emotions.coffee', (options) ->
  if !path.existsSync(videosPath) then fs.mkdirSync(videosPath, parseInt('0755', 8))
  invoke 'build'
  run 'PATH=/usr/bin:/usr/local/bin  && kill -9 `pgrep -f "coffee emotions.coffee"`'
  run "coffee emotions.coffee"



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
