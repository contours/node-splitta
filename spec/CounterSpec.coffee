Counter = require('./../Counter').Counter

describe 'Counter' , ->

  it 'should start at zero', ->
    c = new Counter
    expect(c.get 'foo').toEqual 0

  it 'should increment', ->
    c = new Counter
    c.count 'bar'
    expect(c.get 'bar').toEqual 1
    c.count 'bar'
    expect(c.get 'bar').toEqual 2

  it 'should total up', ->
    c = new Counter
    expect(c.totalCount()).toEqual 0
    c.count 'foo'
    c.count 'foo'
    c.count 'foo'
    c.count 'bar'
    expect(c.totalCount()).toEqual 4

  it 'should normalize counts', ->
    c = new Counter
    c = c.normalize() # shouldn't throw error
    expect(c.totalCount()).toEqual 0
    c.count 'foo'
    c.count 'foo'
    c.count 'foo'
    c.count 'bar'
    c = c.normalize()
    expect(c.get 'foo').toEqual 0.75
    expect(c.get 'bar').toEqual 0.25
    expect(c.totalCount()).toEqual 1
