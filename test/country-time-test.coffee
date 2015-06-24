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
    @msg.match = [0, null, 'day']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's daytime in:/)

  it 'responds to "nighttime"', ->
    @msg.match = [0, null, 'night']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's nighttime in:/)

  it 'responds to "what time is it in sweden"', ->
    @msg.match = [0, 'what', null, 'is it in', 'is it', 'sweden']
    @robot.respond.args[0][1](@msg)
    expect(@msg.send).to.have.been.calledWithMatch(/^It's .* in Sweden right now/)
