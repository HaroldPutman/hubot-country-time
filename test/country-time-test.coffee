chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'country-time', ->
  user =
    name: 'user'
    id: 'U123'

  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()
    @msg =
      send: sinon.spy()
      reply: sinon.spy()
      envelope:
        user:
          @user
      message:
        user:
          @user

    require('../src/country-time')(@robot)

  it 'registers a respond listener', ->
    expect(@robot.respond).to.have.been.called

  it 'responds to "daytime"', ->
    @msg.match = [0, 'daytime']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's daytime in:/)

  it 'responds to "nighttime"', ->
    @msg.match = [0, 'nighttime']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's nighttime in:/)

  it 'responds to "what time is it in sweden" with country name', ->
    @msg.match = [0, 'time', 'sweden']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in sweden right now/)

  it 'responds to "what time is it in helsingborg?" with alias', ->
    @msg.match = [0, 'time', 'helsingborg?']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Helsingborg right now/)

  it 'responds to "what time is it in Phoenix?" with timezone city', ->
    @msg.match = [0, 'time', 'Phoenix?']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Phoenix right now/)

  it 'responds to "time in en_US" with United States', ->
    @msg.match = [0, 'time', 'en_US']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^In United States right now it is:/)

  it 'responds to "time in CET" with timezone', ->
    @msg.match = [0, 'time', 'CET?']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in CET right now\./)

  it 'responds to "time in America/Argentina/Rio_Gallegos" with timezone', ->
    @msg.match = [0, 'time', 'America/Argentina/Rio_Gallegos']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in America\/Argentina\/Rio_Gallegos right now\./)

  it 'responds to "time in phoe" with Phoenix', ->
    @msg.match = [0, 'time', 'phoe']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Phoenix right now\./)

  it 'responds to "what time is it in heisingburg" with Helsingborg', ->
    @msg.match = [0, 'time', 'heisingberg']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Helsingborg right now/)

  it 'responds to "time in Ho Chi Minh" with the city', ->
    @msg.match = [0, 'time', 'Ho Chi Minh']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Ho Chi Minh right now/)


  it 'responds to "time in Area51" with unknown', ->
    @msg.match = [0, 'time', 'Area51']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^Sorry I know nothing about `Area51`\./)
