start = null
is-blink = false
is-light = true
is-run = false
is-show = true
is-warned = false
handler = null
latency = 0
stop-by = null
delay = 60000
audio-remind = null
audio-end = null

pad-left = (num, size) ->
  s = num.toString!
  while s.length < size
    s = '0' + s
  s

format-time = (ms) ->
  total = Math.floor ms
  mins = Math.floor total / 60000
  secs = Math.floor (total % 60000) / 1000
  millis = Math.floor total % 1000
  minutes: pad-left mins, 2
  seconds: pad-left secs, 2
  millis: pad-left millis, 3

render-time = (ms) ->
  parts = format-time ms
  html = "<span class=\"timer-minutes\">#{parts.minutes}</span>"
  html += "<span class=\"timer-sep\">:</span>"
  html += "<span class=\"timer-seconds\">#{parts.seconds}</span>"
  html += "<span class=\"timer-sep\">:</span>"
  html += "<span class=\"timer-millis\">#{parts.millis}</span>"
  $ \#timer .html html

set-blink-classes = (enabled) ->
  tm = $ \#timer
  if enabled
    tm.toggleClass \blink-light, is-light
    tm.toggleClass \blink-dark, !is-light
  else
    tm.removeClass \blink-light
    tm.removeClass \blink-dark

new-audio = (file) ->
  node = new Audio!
    ..src = file
    ..loop = false
    ..load!
  document.body.appendChild node
  return node

sound-toggle = (des, state) ->
  if state => des.play!
  else des
    ..currentTime = 0
    ..pause!

show = ->
  is-show := !is-show
  $ \.fbtn .css \opacity, if is-show => \1.0 else \0.1

adjust = (it,v) ->
  if is-blink => return
  delay := delay + it * 1000
  if it==0 => delay := v * 1000
  if delay <= 0 => delay := 0
  render-time delay
  resize!

toggle = ->
  is-run := !is-run
  $ \#toggle .text if is-run => "STOP" else "RUN"
  if !is-run and handler => 
    stop-by := new Date!
    clearInterval handler
    handler := null
    sound-toggle audio-end, false
    sound-toggle audio-remind, false
  if stop-by =>
    latency := latency + (new Date!)getTime! - stop-by.getTime!
  if is-run => run!

reset = ->
  if delay == 0 => delay := 1000
  sound-toggle audio-remind, false
  sound-toggle audio-end, false
  stop-by := 0
  is-warned := false
  is-blink := false
  latency := 0
  start := null #new Date!
  is-run := true
  toggle!
  if handler => clearInterval handler
  handler := null
  set-blink-classes false
  render-time delay
  resize!


blink = ->
  is-blink := true
  is-light := !is-light
  set-blink-classes true

count = ->
  tm = $ \#timer
  diff = start.getTime! - (new Date!)getTime! + delay + latency
  if diff > 60000 => is-warned := false
  if diff < 60000 and !is-warned =>
    is-warned := true
    sound-toggle audio-remind, true
  if diff < 55000 => sound-toggle audio-remind, false
  if diff < 0 and !is-blink =>
    sound-toggle audio-end, true
    is-blink := true
    diff = 0
    clearInterval handler
    handler := setInterval ( -> blink!), 500
  if !is-blink => set-blink-classes false
  render-time diff
  resize!

run =  ->
  if start == null =>
    start := new Date!
    latency := 0
    is-blink := false
  if handler => clearInterval handler
  if is-blink => handler := setInterval (-> blink!), 500
  else handler := setInterval (-> count!), 100

resize = ->
  tm = $ \#timer
  w = tm.width!
  h = $ window .height!
  len = tm.text!length
  len>?=3
  tm.css \font-size, "#{1.5 * w/len}px"
  tm.css \line-height, "#{h}px"


window.onload = ->
  render-time delay
  resize!
  #audio-remind := new-audio \audio/cop-car.mp3
  #audio-end := new-audio \audio/fire-alarm.mp3
  audio-remind := new-audio \audio/smb_warning.mp3
  audio-end := new-audio \audio/smb_mariodie.mp3
window.onresize = -> resize!
