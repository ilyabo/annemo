require('zappa').run 3001, ->
  

  @get '/': -> 
    @render 'list'


  @view list: ->
    h1 -> "Hello"
    video src:"GROUP_33_CLIENT_2_EMO_E_MOOD_NEG_20_04_09_PART1.wmv"