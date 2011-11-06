###
Very early version of new QueryTemplates.
###

DEBUG = true || global.DEBUG

doom_jquery = require './src/doom-jquery'
flow = require './libs/object-flow/flow'
dom = require 'jsdom'
fs = require 'fs'
_ = require 'underscore'

if DEBUG
	log = require('logging').from __filename
else
	log = ->

class Template
	constructor: flow.define(
		(args...) ->
			@this.markups = []
			@dom = null

      # filter out empty args
			args = _.compact args

			@next = _.last args
			@args = _.initial args
#			@args = args[ 0...args.length-1 ]

			log "opening file #{@args[0]}"
			fs.readFile args[0], @

		(err, markup) ->
			log err if err?
#			log markup.toString()
			dom.env markup.toString(), ["#{__dirname}/libs/jquery.js"], @

		(err, dom) ->
			log err if err?
			Template.extendDomWindow dom
			# assign
			@this.dom = dom
			$ = @this.$ = @this.dom.$
			@this.dom.template = @

			# extend jquery
			doom_jquery $
			$('body + script').remove()

			# read more files
			if @args.length > 2
				log @args.length
				for file in @args[ 1...(@args.length-1) ]
					log file
					fs.readFile file, this.MULTI()
			else @()

		(markups) ->
			log 'loaded all markups'
			@this.markups = markups or {}
			@next null, @this.dom

		)

	toString: ->
		@getMarkup()

	getMarkup: ->
		@this.dom.str()

#	getMarkup: (path) ->
#		@this.markups[ path ]

	disposeMarkup: (path) ->
		delete @this.markups[ path ]

# extend prototype
Template.extendDomWindow = (doc) ->
	doc.str = -> ( @document.doctype || '' ).toString() + @document.outerHTML
	doc.fragment = -> @$('body > *')

module.exports =
	###
	@param ...templates Templates' files paths.
	@param next Callback accepting (err, dom)
	###
	getTemplate: flow.define(
		(args...) -> new Template args[0], args[1], args[2], args[3]
	)

	getCacheOrTemplate: flow.define(
		(container, prop_name, args...) ->
			ret = container[prop_name]
			return ret if ret?
			new Template args[0], args[1], args[2], args[3]
	)

	getCacheOrTemplateFromFlow: flow.define(
		(resource, args...) ->
			[ res_flow, next, name ] = [ resource[0], resource[1], resource[2] ]

			ret = res_flow?[name] || res_flow.this?[name]
			return ret if ret?

			new Template args[0], args[1], args[2], args[3]
	)
	Template: Template

_.extend(
	module.exports,
		get: module.exports.getTemplate
		getCache: module.exports.getCacheOrTemplate
		resDom: module.exports.getCacheOrTemplateFromFlow
)
