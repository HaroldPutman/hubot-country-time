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
zones = require './data/country-timezone.json'
names = require './data/country-name.json'

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

# Look up the country code from a free-form location
#
# @param [String] location The location string
# @return [String] The two character iso country code (uppercase)
#
findCountry = (location) ->
  iso = location.match(/^([a-z][a-z][\-_])?([a-z][a-z])$/i)
  if iso
    return iso[2].toUpperCase()
  location = location
    .toLowerCase()
    .replace(/\s+/,' ')
    .replace(/(\s(right )?now)?[ ?.!]*$/,'')
  for cc, name of names
    if name.toLowerCase().indexOf(location) == 0
      return cc
  location = location.replace(' ', '_')
  for cc, tz of zones
    for z in tz
      if z.toLowerCase().indexOf('/' + location) > 0
        return cc
  return null

module.exports = (robot) ->
  # hubot what time is it in Mexico
  # hubot daytime en_US
  tCommand = '(what\\s+)?(night|day)?time\\s*((is\\s+it\\s+)?in\\s+)?'
  tCountry = '(.*)'
  trigger = new RegExp(tCommand + tCountry, 'i')
  robot.respond trigger, (msg) ->
    day = (msg.match[2]?.toLowerCase() == 'day')
    night = (msg.match[2]?.toLowerCase() == 'night')
    location = msg.match[5]
    if !(day || night) && !location then return #abort if just 'time'
    if location
      country = findCountry location
      if !country || !zones[country]?
        msg.send "Sorry, I know nothing about `#{location}`."
        return
      tz = zones[country]
      if tz.length == 1
        time = moment().tz(tz[0])
        msg.send "It's " + time.format('h:mm a') +
         ' in ' + names[country] + ' right now. ' +
         indicator time.hour(), day, night
      else
        text = 'In ' + names[country] + ' right now it is:\n'
        for z in tz
          time = moment().tz(z)
          text += time.format('h:mm a')
          text += ' (' + z.replace(/^.*\//,'').replace('_', ' ') + ')'
          text += ' ' + indicator time.hour(), day, night
          text += '\n'
        msg.send text
    else
      marked = []
      for cc, tz of zones
        select = true
        for z in tz
          time = moment().tz(z)
          i = indicator time.hour(), day, night
          select &= i.length > 0
        if select then marked.push names[cc]
      if day
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
