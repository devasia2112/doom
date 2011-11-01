doom = require '../doom'
flow = require '../libs/object-flow/flow'
log = require('logging').from __filename

module.exports =
	'Template file can be loaded': flow.define(
		(test) ->
			@test = test
			@test.expect 3
			doom.get 'tests/assets/test.html', @

		(err, dom) ->
			@test.equal null, err
			@test.equal 1, dom.$('title').length
			@test.equal 'H1', dom.$('h1').text()

			@test.done()
	)