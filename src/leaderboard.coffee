# Description:
#   Keeps track of leaderboards
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot <user> climbs <event> leaderboard - Add a victory for the user
#   hubot set <event> leaderboard <user> <score> - Set the score for a user
#   hubot show <event> leaderboard - Returns the event leaderboard
#   hubot reset <event> leaderboard - Clears the event leaderboard
#   hubot list leaderboards - Returns a list of leaderboards
#
# Author:
#   canadianveggie

class Leaderboards
  constructor: (@robot) ->
    this.reload()
    @robot.brain.on 'loaded', =>
      this.reload()

  reload: ->
    @leaderboards = @robot.brain.get('leaderboards') || @robot.brain.data.leaderboards || {}

  save: ->
    @robot.brain.set('leaderboards', @leaderboards)
    @robot.brain.save()

  initialize: (event, user) ->
    @leaderboards[event.toLowerCase()] ?= {}
    @leaderboards[event.toLowerCase()][user.toLowerCase()] ?= {user: user, score: 0}

  increment: (event, user, i) ->
    this.initialize event, user
    i ?= 1
    @leaderboards[event.toLowerCase()][user.toLowerCase()].score += i
    this.save()

  set: (event, user, val) ->
    this.initialize event, user
    @leaderboards[event.toLowerCase()][user.toLowerCase()].score = val
    this.save()

  delete: (event) ->
    delete @leaderboards[event.toLowerCase()]
    this.save()

  get: (event) ->
    sortBy = (key, a, b, r) ->
      r = if r then 1 else -1
      return -1*r if a[key] > b[key]
      return +1*r if a[key] < b[key]
      return 0

    leaderboard_values = (v for k,v of @leaderboards[event.toLowerCase()] or {})

    leaderboard_values.sort (a,b) ->
      sortBy('score', a, b, true) or
      sortBy('user', a, b)
    return leaderboard_values

  list: ->
    return (key for key of @leaderboards)

module.exports = (robot) ->
  leaderboards = new Leaderboards robot

  robot.respond /(.*) (climbs|rises|ascends)( up)?( the)? (.*) leaderboard/i, (msg) ->
    name = msg.match[1]
    event = msg.match[5]
    users = robot.brain.usersForFuzzyName name
    if users.length > 1
      msg.send "I found #{users.length} people named #{name}"
    else
      if users.length == 1
        name = users[0].name

      leaderboards.increment event, name
      if event.toLowerCase() is "king of tokyo"
        msg.send "We have a new king"
      else
        msg.send "We have a winner"

  robot.respond /set( the)? (.*) leaderboard (.*) (\d*)/i, (msg) ->
    event = msg.match[2]
    name = msg.match[3]
    score = parseInt(msg.match[4], 10)
    users = robot.brain.usersForFuzzyName name
    if isNaN(score)
      return
    if users.length > 1
      msg.send "I found #{users.length} people named #{name}"
    else
      if users.length == 1
        name = users[0].name
      else

      leaderboards.set event, name, score
      msg.send "#{name} has #{score} victories in #{event}"

  robot.respond /reset( the)? (.*) leaderboard/i, (msg) ->
    event = msg.match[2]
    leaderboards.delete event
    msg.send "No more #{event} champions"

  robot.respond /(show|list|get)( the)? (.*) leaderboard/i, (msg) ->
    event = msg.match[3]
    leaderboard = leaderboards.get event

    if leaderboard.length > 0
      leader_string = ("#{leader.user}: #{leader.score}" for key, leader of leaderboard).join("\n")
      msg.send "#{event} Leaderboard\n#{leader_string}"
    else
      msg.send "There are no #{event} champions"

  robot.respond /(show|list|get) leaderboards/i, (msg) ->
    leaderboard_keys = leaderboards.list()
    if leaderboard_keys.length > 0
      for leaderboard in leaderboard_keys
        msg.send "#{leaderboard}"
    else
      msg.send "There are no leaderboards"

