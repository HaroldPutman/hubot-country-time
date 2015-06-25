# Description
#   Hubot script to show time in a specified country
#
# Configuration:
#   none
#
# Commands:
#   hubot daytime en_US - returns time in the specified location
#   hubot nighttime - Lists all countries where people are sleeping
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Harold Putman <hputman@lexmark.com>

moment = require 'moment-timezone'
require 'string_score'
countries = require './data/country-info.json'
aliases = require './data/aliases.json'

DAY_START = 7 # Start of workday
DAY_END = 18 # End of workday
NIGHT_START = 22 # Bedtime
NIGHT_END = 6 # Before anyone is awake

# Returns The day/night indicator based on time
#
# @param [int] hr the hour of the day 0-23
# @param [bool] day I want day indicator
# @param [bool] night I want the night indicator
# @return [String] The daylight indicator emoji string
#
indicator = (hr, day, night) ->
  if day && (hr >= DAY_START && hr < DAY_END)
    return ':sun_with_face:'
  if night && (hr < NIGHT_END || hr >= NIGHT_START)
    return ':crescent_moon:'
  return ''

# Looks up location and gets a list of timezones for
# that location.
infoFromLocation = (location) ->
  best =
    score : 0
    found : location
    timezones : []

  # remove filler from start and end
  location = location
    .replace(/^ in /i, '')
    .replace(/(\W*(right )?now)?\W*$/, '')
  if not location
    return null

  # Check for ISO code
  iso = location.toLowerCase().match((/^(?:[a-z][a-z][\-_])?([a-z][a-z])$/i))
  if iso
    c = countries[ iso[1] ]
    if c
      best =
        score : 0.8
        found : c.name
        timezones : c.timezones
      return best

  # Check for location is timezone
  z = moment.tz.zone(location)
  if z
    best =
      score : 1.0
      found : z.name
      timezones : [ z.name ]
    return best

  # Search aliases for match
  for loc, zone of aliases
    s = loc.toLowerCase().score(location)
    if s > best.score
      best =
        score : s
        found : loc
        timezones : [ zone ]
    if s == 1.0
      return best

  # Search timezones for match
  for zone in moment.tz.names()
    city = zone.replace(/.*\//,'')
    s = city.toLowerCase().score(location)
    if s > best.score
      best =
        score : s
        found : city
        timezones : [ zone ]
    if s == 1.0
      return best

  # Search country names for match
  for cc, country of countries
    s = country.name.toLowerCase().score(location)
    if s > best.score
      best =
        score : s
        found : country.name
        timezones : country.timezones
    if s == 1.0
      return best

  return best

module.exports = (robot) ->
  # hubot what time is it in location?
  # hubot daytime in location?
  # hubot nighttime in location?
  robot.respond /((?:what )?time(?: is it)?|daytime|nightt?ime)(?: in )?(.*)/i, (msg) ->
    isDay = (msg.match[1].toLowerCase().substring(0,3) == 'day')
    isNight = (msg.match[1].toLowerCase().substring(0,5) == 'night')
    location = msg.match[2]
    if location
      info = infoFromLocation location
      if not info or not info.timezones.length
        msg.send "Sorry I know nothing about `#{location}`."
        return
      if info.score < 1.0
        location = info.found
      if info.timezones.length == 1
        time = moment().tz(info.timezones[0])
        msg.send "It's " + time.format('h:mm a') +
         " in #{location} right now. " +
         indicator time.hour(), isDay, isNight
      else
        text = "In #{location} right now it is:\n"
        for z in info.timezones
          time = moment().tz(z)
          text += time.format('h:mm a')
          text += ' (' + z.replace(/^.*\//,'').replace('_', ' ') + ')'
          text += ' ' + indicator time.hour(), isDay, isNight
          text += '\n'
        msg.send text
    else
      marked = []
      for cc, info of countries
        select = true
        for z in info.timezones
          time = moment().tz(z)
          i = indicator time.hour(), isDay, isNight
          select &= i.length > 0
        if select then marked.push info.name
      if isDay
        text = "It's daytime in: "
      else
        text = "It's nighttime in: "
      if marked.length > 1
        last = marked.pop()
        text += marked.join(', ')
        text += ', and ' + last
      else
        text += marked[0]
      msg.send text
