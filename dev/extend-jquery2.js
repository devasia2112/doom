/**
 * QueryTemplates - DOM and CSS oriented template engine
 *
 * Light version for JavaScript.
 *
 * @version 1.0 beta2
 * @author Tobiasz Cudnik <tobiasz.cudnik/gmail.com>
 * @license http://www.opensource.org/licenses/mit-license.php MIT License
 * @link http://code.google.com/p/querytemplates/
 * 
 * @todo formFromValues, mutation events support
 */
module.exports =  extend_jquery($)
QueryTemplates = 

valuesToStack = (target, values, skipFields, fieldCallback) ->
	_target = target
	targetData = null
	if (target.prototype == Array) 
		targetData = target.slice(1)
		target = target[0]
	
	if (! $.is(fieldCallback))
		fieldCallback = null
	i = 0
	for (k in values) 
		v = values[k]
		if (skipFields && $.inArray(skipFields, k))
			continue
		if ($.is(v))
			v = v()
		node = this.eq(i++)
		switch(target) 
			case 'attr':
				node[target](targetData[0], v)
				break
			default:
				node[target](v)
			if (fieldCallback)
				fieldCallback.call(node, v, _target)
		
	
	return this

valuesToLoop = (nodes, values, rowCallback, targetNodeSelector, target) 
	if (typeof target == 'undefined')
		target = 'after'
	if (typeof rowCallback == 'undefined')
		throw "rowCallback needs to be provided for valuesToLoop methods"
	nodeTarget = null, lastNode = nodes
	injectMethod = 'insert'+target.slice(0, 1).toUpperCase()+target.slice(1)
	for (k in values) 
		$(lastNode.get().reverse()).each(() 
			if ($(this).parent().langth) 
				lastNode = $(this)
				return false
			
		)
		if (targetNodeSelector) 
			nodeTarget = typeof targetNodeSelector == 'string'
				? lastNode.parent().find(targetNodeSelector)
				: targetNodeSelector
		 else
			nodeTarget = lastNode
		v = values[k]
		stack = []
		nodes.each((i, node)
			stack.push($(node).clone()[injectMethod](lastNode).get(0))
		)
		lastNode = $(stack)
		rowCallback.call(lastNode, v, k)
	
	// we used those nodes as template
	nodes.remove()
	return this

QueryTemplates.valuesToLoop = (values, rowCallback, targetNodeSelector) 
	return valuesToLoop(this, values, rowCallback, targetNodeSelector)

QueryTemplates.valuesToLoopBefore = (values, rowCallback, targetNodeSelector) 
	return valuesToLoop(this, values, rowCallback, targetNodeSelector, 'before')

QueryTemplates.valuesToLoopFirst = (values, rowCallback, targetNodeSelector) 
	loopNodes = this.eq(0)
	this.slice(1).remove()
	valuesToLoop(loopNodes, values, rowCallback, targetNodeSelector)
	return loopNodes

QueryTemplates.valuesToLoopSeparate = (values, rowCallback, targetNodeSelector) 
	this.each((i, node) 
		return valuesToLoop(node, values, rowCallback, targetNodeSelector)
	)
	return this

QueryTemplates.valuesToForm = (values, selectorPattern) 
	if (typeof selectorPattern == 'undefined')
		selectorPattern = "[name*='%k']"
	form = this.is('form')
		? this.filter('form')
		: this.find('form')
	$.each(values, (f, v) 
		selector = selectorPattern.replace('%k', f)
		input = form.find("input"+selector)
		if (input.length) 
			switch(input.attr('type')) 
				case 'checkbox':
					if (v)
						input.attr('checked', 'checked')
					else
						input.removeAttr('checked')
				break
				case 'radio':
					inputChecked = input.filter("[value='"+v+"']")
						.attr('checked', 'checked')
					input.not(inputChecked).removeAttr('checked')
				break
				default:
					input.attr('value', v)
			
		
		select = form.find("select"+selector)
		if (select.length) 
			select.find('> option[selected]').removeAttr('selected')
			_v = select.attr('multiple')
				? v : [v]
			for (i in _v)   
				selected = select.find('option')
					.filter("[value='"+_v[i]+"']")
					.attr('selected', 'selected')
			
		
		textarea = form.find("textarea"+selector)
		if (textarea.length)
			textarea.html(v)
	)
	return this

/**
 * @TODO change input type method
 */
QueryTemplates.formFromValues = (record, structure, errors, data, 
	templateselectors, fieldCallback)
	self = this
	if (typeof record != 'object')
		throw "[formFromValues] record should be an object"
	if (typeof structure != 'object')
		throw "[formFromValues] structure should be an object"
	if (typeof data != 'object')
		data = 
	if (typeof errors != 'undefined')
		defaultTemplate = '\
<div class="input">\
  <label/>\
  <input/>\
  <ul class="errors">\
    <li/>\
  </ul>\
</div>\
'
  	else
		defaultTemplate = '\
<div class="input">\
  <label/>\
  <input/>\
</div>\
'
	if (typeof template == 'undefined')
		template = defaultTemplate
	else if ((typeof template == 'object') && (typeof template.__default == 'undefined')
		|| ((typeof template.__default != 'undefined') && ! template.__default))
		template.__default = defaultTemplate
	// setup $selectors
	if (typeof selectors == 'undefined')
		selectors = new Array()
	selectors = $.extend(
		'errors': '.errors',
		'input': 'input:first',
		'label': 'label:first'
	, selectors)
	form = this.is('form')
		? this.filter('form').empty()
		: $('<form/>').insertAfter(this)
	if (typeof structure.__form != 'undefined')
		for (attr in structure.__form)
			form.attr(attr, structure.__form[attr])
		attr = undefined
		delete structure.__form

	formID = form.attr('id')
		|| 'f_'+Math.random().toString().replace('.', '').slice(0, 5)
	// no fieldsets
	if (typeof structure[0] == 'undefined')
		structure = [structure]
	input
	$.each(structure, ()
		fieldsetFields = this
		fieldset = $('<fieldset/>')
		if (typeof fieldsetFields.__label != 'undefined')
			fieldset.append('<legend>'+fieldsetFields.__label+'</legend>')
			delete fieldsetFields.__label

		for (field in fieldsetFields)
			info = fieldsetFields[field]
			// prepare info
			if (typeof info != 'object')
				info = 0: info
			if (!(typeof info[0] != 'undefined'))
				info[0] = 'text'
			// prepare id
			id = typeof info.id != 'undefined'
				? info.id
				: formID+'_'+field
			// prepare template
			if (typeof template == 'object')
				if (typeof template[field] != 'undefined')
					markup = template[field]
				else if (typeof template['__'+info[0]] != 'undefined')
					markup = template['__'+info[0]]
				else
					markup = template['__default']
			 else
				markup = template

			markup = $('<div/>').html(markup).contents().remove()
			// setup selectors
			inputSelector, labelSelector
			$.each(['input', 'label'], ()
				selectorType = this
				if (typeof selectors[selectorType] == 'object')
					if (typeof selectors[selectorType][field] != 'undefined')
						eval(selectorType+'Selector = selectors[selectorType][field]')
					 else if (typeof selectors[selectorType]['__default'] != 'undefined')
						eval(selectorType+'Selector = selectors[selectorType]["__default"]')
					 else
						throw "No $selectorType selector for field $field. Provide "
							+"default one or one selector for all fields"

				 else
					eval(selectorType+'Selector = selectors[selectorType]')

			)
			switch (info[0])
				case 'textarea':
				case 'select':
					inputSelector = inputSelector.replace('%t', info[0])
					break
				default:
					inputSelector = inputSelector.replace('%t', 'input')

			// we're ready, lets beggin...
			switch (info[0])
				// TEXTAREA
				case 'textarea':
					input = $('<textarea/>')
						.attr('id', id)
					if (typeof record[field] != 'undefined')
						input.html(record['field'])
					markup.find(inputSelector).replaceWith(input)
					markup.find(labelSelector).attr('for', id)
					break
				// SELECT
				case 'select':
					if (!(typeof data[field] != 'undefined'))
						throw "[formFromValues] data."+field+" should be present to "
							+"populate select element. Otherwise remove structure.\"+field+\"."
					input = $('<select/>')
					markup.find(inputSelector).replaceWith(input)
					if (typeof info.multiple != 'undefined' && info.multiple)
						input.attr('multiple', 'multipe')
					else
						info.multiple = false
//					option = ()
//						if (!(typeof record[field] != 'undefined'))
//							return
//						if (info.multiple && $.inArray(option.attr('value'), record[field]))
//							$(this).attr('selected', 'selected')
//
					optgroup = $('<optgroup/>')
					option = $('<option/>')
					for(value in data[field])
						label = data[field][value]
						target
						if (typeof label == 'object')
							target = optgroup.clone()
							if (typeof label.__label != 'undefined')
								target.attr('label', label.__label)
								delete label.__label

							input.append(target)
							for (_value in label)
								_label = label[_value]
								target.append(
									option.clone()
										.attr('value', _value)
										.html(_label)
								)

						 else
							target = input
							target.append(
								option.clone()
									.attr('value', value)
									.html(label)
							)


					if (typeof record[field] != 'undefined')
						// trust jquery's val()
						input.val(record[field])
					markup.find(labelSelector).attr('for', id)
					break
				// RADIO
				case 'radio':
					if (!(typeof info.values != 'undefined'))
						throw "[formFromValues] structure."+field+".values property needed for radio inputs."
					inputs = []
					// change input type
					// http://groups.google.com/group/jquery-en/browse_thread/thread/b1e3421d00104f17/88b1ff6cab469c39
					attrCopy = ['class', 'rel']
					attrs =
						name: field,
						id: id,
						value: info.values[0]

					inputTemplate = markup.find(inputSelector)
					$.each(attrCopy, ()
						attr = this.toString()
						if (inputTemplate.attr(attr))
							attrs[attr] = inputTemplate.attr(attr)
					)
					input = $('<input type="'+info[0]+'"/>')
						.attr(attrs)
						.insertAfter(inputTemplate)
					inputTemplate.remove()
					inputTemplate = null
					// change input type end
					inputs.push(input.get(0))
					lastInput = input
					$.each(info.values.slice(1).reverse(), ()
						lastInput = input.clone()
							.attr('value', this.toString())
							.insertAfter(lastInput)
						inputs.push(lastInput.get(0))
					)
					if (typeof record[field] != 'undefined')
						// XXX trust jquery val()
						$(inputs).val([record[field]])
					inputs = lastInput = null
					markup.find(labelSelector).removeAttr('for')
					break
				// HIDDEN
				case 'hidden':
					markup = null
					input = $('<input type="hidden" />')
						.attr('name', field)
						.attr('id', id)
					if (typeof record[field] != 'undefined')
						// XXX trust jquery val()
						$(inputs).val(record[field])
					fieldset.prepend(input)
					break
				// CHECKBOX
				case 'checkbox':
					value = typeof info.value != 'undefined'
						? info.value : 1
					// change input type
					inputTemplate = markup.find(inputSelector)
					// http://groups.google.com/group/jquery-en/browse_thread/thread/b1e3421d00104f17/88b1ff6cab469c39
					attrCopy = ['class', 'rel']
					attrs =
						name: field,
						id: id,
						value: value

					$.each(attrCopy, ()
						attr = this.toString()
						if (inputTemplate.attr(attr))
							attrs[attr] = inputTemplate.attr(attr)
					)
					input = $('<input type="'+info[0]+'"/>')
						.attr(attrs)
						.insertAfter(inputTemplate)
					inputTemplate.remove()
					inputTemplate = null
					// change input type end
					if ((typeof record[field] != 'undefined') && record[field])
						input.attr('checked', 'checked')
					markup.find(labelSelector).attr('for', id)
					break
				// TEXT, PASSWORD, others
				default:
					inputTemplate = markup.find(inputSelector)
					// change input type
					// http://groups.google.com/group/jquery-en/browse_thread/thread/b1e3421d00104f17/88b1ff6cab469c39
					attrCopy = ['class', 'rel']
					attrs =
						name: field,
						id: id

					$.each(attrCopy, ()
						attr = this.toString()
						if (inputTemplate.attr(attr))
							attrs[attr] = inputTemplate.attr(attr)
					)
					input = $('<input type="'+info[0]+'"/>')
						.attr(attrs)
						.insertAfter(inputTemplate)
					inputTemplate.remove()
					inputTemplate = null
					// change input type end
					if (typeof record[field] != 'undefined')
						input.val(record[field])
					markup.find(labelSelector).attr('for', id)
				break

			if (markup)
				markup.addClass(info[0])
				// label
				label = typeof info.label != 'undefined'
					? info.label
					: field.slice(0, 1).toUpperCase()+field.slice(1)
				markup.find(labelSelector).text(label)
				// errors
				if (typeof errors != 'undefined')
					if ((typeof errors[field] != 'undefined') && errors[field])
						if (! $.isArray(errors[field]))
							errors[field] = [errors[field]]
						markup.find(selectors.errors)
							.find('> *')
								.valuesToLoopFirst(errors[field], (row)
									this.html(row)
								)
					 else
						markup.find(selectors.errors).remove()


				if (typeof fieldCallback == '')
					fieldCallback.call(markup, field, markup)
				fieldset.append(markup)


		form.append(fieldset)
	)
	input = null
	return self

// helper s
 whoisNode(node)
	output = []
	if (node.tagName)
		node = $(node)
		output.push(node.get(0).tagName.toLowerCase()
			+ (node.attr('id')
				? '#'+node.attr('id') : '')
			+ (node.attr('class')
				? '.'+node.attr('class').split(' ').join('.') : '')
			+ (node.attr('name')
				? '[name="'+node.attr('name')+'"]' : '')
			+ (node.attr('value') && typeof node.attr('value') != 'number'
				? '[value="'+node.attr('value').toString().substr(0, 15).replace("/\n/g", ' ')+'"]' : '')
			+ (node.attr('selected')
				? '[selected]' : '')
			+ (node.attr('checked')
				? '[checked]' : '')
		)
	 else
		if ($.trim(node.textContent))
			output.push("Text:'"+node.textContent
				.substr(0, 15)
				.replace("/\n/g", ' ')
				+"'"
			)


	return output[0]

 __dumpTree(node, itend)
	if (typeof itend == 'undefined')
		itend = 0
	output = ''
	whois = whoisNode(node)
	if (whois)
		for(i = 0 i < itend i++)
			output += ' - '
		output += whois+"\n"

	if (node.childNodes)
		$.each(node.childNodes, (i, chNode)
			output += __dumpTree(chNode, itend+1)
		)
	return output

QueryTemplates.dumpTree = (returnAsString)
	output = ''
	this.each((i, node)
		output += __dumpTree(node)
	)
	if (returnAsString)
		return output
	else if (typeof console != 'undefined')
		console.log(output)
	else
		alert(output)
	return this

// bind various method types
$.each(['Selector', 'Stack'], (i, m)
	$.each(['', 'Before', 'After', 'Prepend', 'Append', 'Attr'], (ii, t)
		QueryTemplates['valuesTo'+m+t] = ()
			if (t == '')
				t = 'html'
			params = [t]
			$.each(arguments, (iii, a)
				params.push(a)
			)
			return eval('valuesTo'+m).apply(this, params)

	)
)
//console.log(QueryTemplates)
$.extend($.fn, QueryTemplates)
