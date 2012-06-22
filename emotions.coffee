require('zappa').run 3001, ->
  
  fs = require("fs")
  dateFormat = require('dateformat')

  @use 'static': __dirname + '/static'

  video = @include './video'

  resultsFile = fs.createWriteStream __dirname + '/results.csv', {'flags': 'a'} 
  

  @use 'bodyParser', 'methodOverride', @app.router, 'static'

  @get '/': ->
    unless @query.subject in video.users
      @send  "Subject must be properly specified"
    @render "home" : { subject:@query.subject, layout: "frameset"}
  

  @view home: ->
    console.log @subject
    frame name:"menuFrame", src:"menu?subject=#{@subject}"
    frame id:"videoFrame", name:"videoFrame", src:"about:blank"



  @view frameset: ->
    doctype 5
    html ->
      head -> title @title
      frameset cols:"25%,*", -> @body


  @get '/menu': -> 
    @render "menu": { videos : video.files, users : video.users, subject:@query.subject}
  

  @view menu: ->

    ###

    form action: "video", target:"videoFrame", ->
      div class:"formelem", ->
        span -> "Test subject: "
        select name: "subject", id:"subject", ->
          option value:"", -> ""
          for v in @users
            option -> v

      div class:"formelem", ->
        span -> "Dimension: "
        select name: "dim", id:"dim", ->
          option value:"", -> ""
          option -> "arousal"
          option -> "valence"
      div class:"formelem", ->
        span -> "Video to play: "
        select name: "video", id:"video", ->
          option value:"", -> ""
          for v in @videos
            option -> v
    ###


    div class:"formelem", ->
      ul class:"videolist", ->
        for dim in ["arousal", "valence"]
          for v in @videos
            li ->
              a href:"video?video=#{v}&dim=#{dim}&subject=#{@subject}", target:"videoFrame",-> dim + " - " + v

      ###
      div class:"formelem", ->
        input id:"startSubmit", type:"submit", value:"Start"
      ###

      script src: 'home.js'




  @coffee '/home.js': ->
    $ ->
      $(".videolist a").click ->
        if $("#subject").val().trim() is ""  or   $("#dimension").val() is ""
          alert("Please, fill in the form fields")
          return false
        return true






  @get '/video': -> 
    if not (@query.subject in video.users) or (not @query.video?) or (not @query.dim?)
      @send  "Subject, video, dim must be properly specified"

    @render video:
      video: video.location + @query.video
      videoName: @query.video
      subject: @query.subject
      dimension: @query.dim


  @view video: ->
    script src: 'video.js'

    script -> """
        subject = "#{@subject.replace(/"/g, '\\"')}"
        video = "#{@video}"
        videoName = "#{@videoName}"
        dimension = "#{@dimension}"
      """

    div id:"content", ->

      div id:"buttonArea",->
        button id:"start", -> "Start"

      video id:"video", width:640, height:480, ->
        source src: @video

      div id:"dimension", -> "#{@dimension}"

      div id:"slider", class:"#{@dimension}"

      div id:"labels", ->
        span class:"left", ->
          switch @dimension
            when "arousal" then "very passive"
            when "valence" then "very negative"

        span class:"right", ->
          switch @dimension
            when "arousal" then "very active"
            when "valence" then "very positive"


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
          clienttime: Date.now()
          subject: subject
          video: videoName
          dimension: dimension
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
          v.get(0).currentTime = 0
          v.data("isPlaying", true)
           .get(0).play()

          $(this).html("Pause")
        else
          v.data("isPlaying", false)
           .get(0).pause()

          $(this).html("Restart")



  @post '/save_value': ->

    q = (s) ->
      if (s.indexOf(",") >= 0)
        '"' + s.replace(/"/g, '\\"') + '"'
      else
        s

    csv = ""
    for obj in @body.buffer
      formattedDate = q(dateFormat(Date.now(), "dddd, mmmm dS, yyyy, h:MM:ss TT"))
      csv = csv + formattedDate + "," + ((q(v) for k, v of obj).join(",") + "\n")

    resultsFile.write csv, (err) =>
      unless err?
        @send
          result: 'Ok'
      else
        @next(err)




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







