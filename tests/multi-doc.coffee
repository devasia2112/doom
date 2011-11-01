doom = require '../doom'
flow = require '../libs/object-flow/flow'
log = require('logging').from __filename

module.exports =
	setUp: flow.define(
		(callback) ->
			@done = callback
			doom.get 'tests/assets/test.html', @MULTI 'dom1'
			doom.get 'tests/assets/test.html', @MULTI 'dom2'
		(args) ->
			log args['dom1'][k] for k in [0, 1] if args['dom1'][k]
			@this.dom1 = args['dom1'][1]
			@this.dom2 = args['dom2'][1]
			@done()
	)

	'Nodes can be imported into other document': (test) ->
		doc1_body = @dom1.$ 'body'
		doc2_lis = @dom2.$ 'li'
		nodes = doc1_body._importNodes.call doc1_body, doc2_lis, doc1_body

		debugger
		test.equals nodes.length, 2
		test.ok nodes[0]._ownerDocument is @dom1.document, 'Nodes belongs to the new document.'
		test.done()

	'Nodes can be inserted into other document with append()': (test) ->
		li = @dom1.$ 'li'
		@dom2.$('ul').append li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with appendTo()': (test) ->
		ul = @dom2.$ 'ul'
		@dom1.$('li').appendTo ul
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be prepend into other document with prepend()': (test) ->
		li = @dom1.$ 'li'
		@dom2.$('ul').prepend li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be prepended into other document with prependTo()': (test) ->
		ul = @dom2.$ 'ul'
		@dom1.$('li').prependTo ul
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with after()': (test) ->
		li = @dom1.$ 'li'
		@dom2.$('ul > li:last').after li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with insertAfter()': (test) ->
		last_li = @dom2.$ 'ul > li:last'
		@dom1.$('li').insertAfter last_li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with before()': (test) ->
		li = @dom1.$ 'li'
		@dom2.$('ul > li:first').before li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with insertBefore()': (test) ->
		first_li = @dom2.$ 'ul > li:first'
		@dom1.$('li').insertBefore first_li
		test.equals @dom2.$('li').length, 4
		test.done()

	'Nodes can be inserted into other document with replaceWith()': (test) ->
		li = @dom1.$ 'li'
		@dom2.$('ul > li:last').replaceWith li
		test.equals @dom2.$('li').length, 3
		test.done()

