DEBUG = false
_ = require 'underscore'
if DEBUG
	log = require('logging').from __filename
else
	log = ->

jquery = (obj) -> obj.constructor

valuesToSelector = (target, values, selector_pattern, skip_fields, field_callback) ->

	# define
	$ = jquery(@)
	selector_pattern ?= '.%k'
	original_taret = target
	target_data = null

	# support target arguments
	if target.constructor is Array
		target_data = target.slice 1
		target = target[0]

	target = target.toLowerCase()

	# assert callable callback
#		callable = not $(@).isFunction( field_callback )
#		array_of_callable = if $(@).isArray( field_callback )
#			for v of field_callback
#				return jquery(@).isFunction field_callback[ v ]
#
#		if callable
#			field_callback = null
#		else if array_of_callable

	if not $.isFunction fieldCallback
		fieldCallback = null

	for k in values

		continue if skip_fields? and k in skip_fields

		# support values by callback
		if $.isFunction v
			v = v()

		# TODO @todoc
		node = if selector_pattern == true then @ else @find selector_pattern.replace '%k', k

		switch target
			when 'attr'
				node[target] target_data[0], v
			else
				node[target] v

		if field_callback
			field_callback.call node, k, original_taret

	@

valuesToStack = (target, values, skipFields, fieldCallback) ->
	# define
	_target = target
	targetData = null

	if target.constructor is Array
		targetData = target.slice 1
		target = target[0]

	target = target.toLowerCase()

	if not jquery(@).isFunction fieldCallback
		fieldCallback = null

	i = 0
	for k, v of values
		v = values[k]
		continue if skipFields? and k in skipFields

		if jquery(@).isFunction v
			v = v()

		node = @eq i++
		switch target
			when 'attr'
				node[target] targetData[0], v
			else
				node[target] v

		if fieldCallback
			fieldCallback.call node, v, _target

	@

valuesToLoop = (nodes, values, rowCallback, targetNodeSelector, target) ->

	# define
	$ = jquery(@)
	target ?= 'after'
	if not rowCallback?
		throw Error "rowCallback needs to be provided for valuesToLoop methods"
	nodeTarget = null
	lastNode = nodes

	injectMethod = "insert#{target.slice(0, 1).toUpperCase()}#{target.slice 1}"
	for v, k in values
		$( lastNode.get().reverse() ).each ->
			# TODO check this
			if $(@).parent().length
				lastNode = $ @
				false

		nodeTarget =
			if targetNodeSelector
				if targetNodeSelector is String
					lastNode.parent().find targetNodeSelector
				else targetNodeSelector
			else lastNode

		stack = []

		nodes.each (i, node) ->
			stack.push $(node).clone()[ injectMethod ](lastNode).get(0)

		lastNode = $ stack
		rowCallback.call lastNode, v, k

	# we used those nodes as templates
	nodes.remove()
	@

whoisNode = (node) ->
	output = []

	if node.tagName
		node = jquery(@) node
		# TODO rewrite
		number_value = node.attr 'value' && node.attr('value').constructor isnt Number
		output.push node.get(0).tagName.toLowerCase() + (
			+ if node.attr('id') then '#'+node.attr('id') else ''
			+ if node.attr('class') then '.'+node.attr('class').split(' ').join('.') else ''
			+ if node.attr('name') then '[name="'+node.attr('name')+'"]' else ''
			+ if number_value then "[value=\"#{node.attr('value').toString().substr(0, 15).replace /\n/g, ' '}\"]" else ''
			+ if node.attr 'selected' then '[selected]' else ''
			+ if node.attr 'checked' then '[checked]' else ''
		)
	else if jquery(@).trim node.textContent
		output.push "Text:'#{node.textContent
			.substr(0, 15)
			.replace("/\n/g", ' ')
			}'"

	output[0]

__dumpTree = (node, indent) ->
	if indent
		indent = 0
	output = ''
	whois = whoisNode.call @, node
	if whois
		for i in [ 0..indent ]
			output += ' - '
		output += "#{whois}\n"

	if node.childNodes
		jquery(@).each node.childNodes, (i, chNode) ->
			output += __dumpTree.call @, chNode, indent + 1

	output

###
Adds multi document support, auto importing foreign document nodes when inserting.
###
JqueryMultiDocMixin =
	# TODO support multiple targets?
	_importNodes: (nodes, target, return_jquery = false) ->
		# if jquery object
		# TODO better type checking (supporting jquery from different docs)
		if target['jquery']
			target = target.get 0
		else if target.constructor is Array
			target = target[0]

		# TODO err?
		return nodes if not target?

		target_doc = target._ownerDocument
		result = []

		for node in nodes
			if target_doc isnt node._ownerDocument
#				log "Importing #{whoisNode.call @, node}"
				debugger
				result.push target_doc.importNode node, true
#				log result[ result.length-1 ]._ownerDocument == target_doc
			else
				result.push node

		if return_jquery then @constructor result else result

	append: (fn, nodes) ->
		fn.call @, @_importNodes nodes, @

	appendTo: (fn, target) ->
		fn.call @_importNodes(@, target, true), target

	prepend: (fn, nodes) ->
		fn.call @, @_importNodes nodes, @

	prependTo: (fn, target) ->
		fn.call @_importNodes(@, target, true), target

	after: (fn, nodes) ->
		fn.call @, @_importNodes nodes, @

	insertAfter: (fn, target) ->
		fn.call @_importNodes(@, target, true), target

	before: (fn, nodes) ->
		fn.call @, @_importNodes nodes, @

	insertBefore: (fn, target) ->
		fn.call @_importNodes(@, target, true), target

	replaceWith: (fn, nodes) ->
		fn.call @, @_importNodes nodes, @

DoomJqueryMixin =

	valuesToLoop: (values, rowCallback, targetNodeSelector) ->
		valuesToLoop.call @, @, values, rowCallback, targetNodeSelector

	valuesToLoopBefore: (values, rowCallback, targetNodeSelector) ->
		valuesToLoop.call @, @, values, rowCallback, targetNodeSelector, 'before'

	valuesToLoopFirst: (values, rowCallback, targetNodeSelector) ->
		loopNodes = @eq 0
		@slice(1).remove()
		valuesToLoop.call @, loopNodes, values, rowCallback, targetNodeSelector
		loopNodes

	valuesToLoopSeparate: (values, rowCallback, targetNodeSelector) ->
		@each (i, node) ->
			valuesToLoop.call @, node, values, rowCallback, targetNodeSelector
		@

	valuesToSelector: (args...) ->
		args.unshift 'html'
		valuesToSelector.apply @, args

	valuesToSelectorBefore: (args...) ->
		args.unshift 'before'
		valuesToSelector.apply @, args

	valuesToSelectorAfter: (args...) ->
		args.unshift 'after'
		valuesToSelector.apply @, args

	valuesToSelectorPrepend: (args...) ->
		args.unshift 'prepend'
		valuesToSelector.apply @, args

	valuesToSelectorAppend: (args...) ->
		args.unshift 'append'
		valuesToSelector.apply @, args

	valuesToSelectorAttr: (args...) ->
		args.unshift 'attr'
		valuesToSelector.apply @, args

	valuesToStack: (args...) ->
		args.unshift 'html'
		valuesToStack.apply @, args

	valuesToStackBefore: (args...) ->
		args.unshift 'before'
		valuesToStack.apply @, args

	valuesToStackAfter: (args...) ->
		args.unshift 'after'
		valuesToStack.apply @, args

	valuesToStackPrepend: (args...) ->
		args.unshift 'prepend'
		valuesToStack.apply @, args

	valuesToStackAppend: (args...) ->
		args.unshift 'append'
		valuesToStack.apply @, args

	valuesToStackAttr: (args...) ->
		args.unshift 'attr'
		valuesToStack.apply @, args

	dumpTree: (returnAsString) ->
		output = ''
		@each (i, node) ->
			output += __dumpTree.call @, node

		if returnAsString
			output
		else if not console?
			console.log output
		else
			alert output
		@

module.exports = ($) ->
	_.extend $.fn, DoomJqueryMixin
	# proxy jquery methods related to node insertion into doc
	# auto importing new nodes to context doc
	# closure scope is needed, as `name` would be mutable otherwise
	_.forEach JqueryMultiDocMixin, (v, name) ->
		if $.fn[ name ]
			$.fn[ name ] = _.wrap $.fn[ name ], ->
				JqueryMultiDocMixin[ name ].apply @, arguments
		else
			$.fn[ name ] = JqueryMultiDocMixin[ name ]
