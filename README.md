# vasttrafik_smashing_widget
A widget for Smashing Dashboard showing Västtrafik departures

![screenshot](screenshot.png?raw=true "screenshot")

Put this in your dashboard .erb file:
```
<li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
  <div data-id="vasttrafik_departure_board"
       data-view="VasttrafikDepartureBoard">
  </div>
</li>
```

Edit your AUTH_KEY and STOP_ID in jobs/vasttrafik-get-bus-stop.rb
