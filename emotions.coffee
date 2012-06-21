require('zappa').run 3001, ->
  
  fs = require("fs")

  #@enable 'default layout'
  @use 'static': __dirname + '/videos'
  @use 'static': __dirname + '/static'

  #resultsFile = __dirname + '/results.csv'
  resultsFile = fs.createWriteStream __dirname + '/results.csv', {'flags': 'a'} 
  

  @use 'bodyParser', 'methodOverride', @app.router, 'static'

  @get '/': -> 
    fs.readdir  __dirname + '/videos', (err, files) =>
      @render "home": { videos:files }
  
  @view home: ->
    h2 -> "Welcome!"

    form action: "video", ->
      div class:"formelem", ->
        span -> "Test subject: "
        input type:"text", name:"subject", id:"subject", ->

      div class:"formelem", ->
        span -> "Video to play: "
        select name: "video", id:"video", ->
          option value:"", -> ""
          for v in @videos
            option -> v

      div class:"formelem", ->
        input id:"startSubmit", type:"submit", value:"Start"

      script src: 'home.js'


  @coffee '/home.js': ->
    $ ->
      $("#startSubmit").click ->
        if $("#subject").val().trim() is ""  or   $("#video").val() is ""
          alert("Please, fill in the form fields")
          return false
        return true






  @get '/video': -> 
    @render video: { video: @query.video, subject: @query.subject}


  @view video: ->
    script src: 'video.js'

    h2 -> "Hello #{@subject}!"
    div id:"buttonArea",->
      button id:"start", -> "Start"

    script -> """
        subject = "#{@subject.replace(/"/g, '\\"')}"
        video = "#{@video}"
      """

    video id:"video", width:640, height:480, ->
      source src: @video

    div id:"slider"


  @coffee '/video.js': ->
    $ ->
      $("#video").data("isPlaying", false)

      buffer = []
      maxBufferSize = 10

      sendBufferToServer = ->
        tosend = buffer
        buffer = []
        $.ajax
          type: 'post'
          url: 'save_value'
          dataType: 'json'
          data: 
            buffer: tosend


      onValueChange = (e, ui) ->
        buffer.push
          subject: subject
          video: video
          time: $("#video").get(0).currentTime
          value: ui.value
          playing: $("#video").data("isPlaying")

        if buffer.length > maxBufferSize
          sendBufferToServer()

  
      $(document).mousemove (e) ->
        s = $("#slider")
        h = $(".ui-slider-handle", s)
        if h.hasClass("ui-state-focus")
          val = ((e.clientX - s.offset().left) / s.width()) * 2 - 1 
          if val > 1 then val = 1
          if val < -1 then val = -1
          s.slider("option", "value", val)

      $("#slider")
        .slider({ 
          orientation: 'horizontal',
          min: -1,
          max: 1,
          value: 0, 
          step:0.01,
          slide: onValueChange,
          change: onValueChange
        })

      $("#video").bind "ended", ->
        $(this).data("isPlaying", false)
        sendBufferToServer()

      $("#start").click ->
        v = $("#video")
        if not v.data("isPlaying")
          v.data("isPlaying", true)
           .get(0).play()

          $(this).html("Pause")
        else
          v.data("isPlaying", false)
           .get(0).pause()

          $(this).html("Play")



  @post '/save_value': ->

    q = (s) ->
      if (s.indexOf(",") >= 0)
        '"' + s.replace(/"/g, '\\"') + '"'
      else
        s

    csv = ""
    for obj in @body.buffer
      csv = csv + ((q(v) for k, v of obj).join(",") + "\n")


    #f = fs.createWriteStream resultsFile, {'flags': 'a'}, ->
    resultsFile.write csv

    @send
      result: 'Ok'




  @view layout: ->
    doctype 5
    html ->
      head ->
        title @title
        link rel:"stylesheet", type:"text/css", href:"css/jquery-ui-1.8.18.custom.css"
        link rel:"stylesheet", type:"text/css", href:"css/style.css"
        script src: 'js/jquery-1.7.2.min.js'
        script src: 'js/jquery-ui-1.8.18.custom.min.js'
      body @body







