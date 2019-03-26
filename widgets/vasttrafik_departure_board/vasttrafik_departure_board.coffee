class Dashing.VasttrafikDepartureBoard extends Dashing.Widget

 ready: ->
    meter = $(@node).find(".name")

 onData: (data) ->
    meter = $(@node).find(".name")

    for key,departure of data.departures
         fgcolor = departure.fgColor
         meter.attr("style", "background-color: " + fgcolor)
