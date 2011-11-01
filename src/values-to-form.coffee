module.exports = (values, selectorPattern) ->
    selectorPattern ?= "[name*='%k']"
    form = if @is 'form' then @filter 'form' else @find 'form'

    $.each values, (f, v) ->
        selector = selectorPattern.replace '%k', f
        input = form.find "input#{selector}"
        if input.length
            switch input.attr 'type'
                when 'checkbox'
                    if v?
                        input.attr 'checked', 'checked'
                    else
                        input.removeAttr 'checked'
                when 'radio'
                    inputChecked = input.filter("[value='#{v}']")
                        .attr 'checked', 'checked'
                    input.not(inputChecked).removeAttr 'checked'
                else
                    input.attr 'value', v

        select = form.find "select#{selector}"
        if select.length
            select.find('> option[selected]')
                .removeAttr 'selected'
            _v = if select.attr 'multiple' then v else [v]

            for i of _v
                selected = select.find('option')
                    .filter("[value='"+_v[i]+"']")
                    .attr 'selected', 'selected'

        textarea = form.find "textarea#{selector}"
        if textarea.length
            textarea.html v

    @

#
# @TODO change input type method
#
#QueryTemplates.formFromValues = (record, structure, errors, data,
#	templateselectors, fieldCallback) ->
#	self = @
#	if record.constructor is Object
#		throw "[formFromValues] record should be an object"
#	if structure.constructor isnt Object
#		throw "[formFromValues] structure should be an object"
#	if data.constructor isnt Object
#		data = []
#
#	defaultTemplate = if not errors?
#		then """
#			<div class="input">
#			  <label/>
#			  <input/>
#			  <ul class="errors">
#			    <li/>
#			  </ul>
#			</div>
#		"""
#    else """
#			<div class="input">
#			  <label/>
#			  <input/>
#			</div>
#		"""
#	template ?= defaultTemplate
#
#	# TODO encapsulate condition vars
#	if (template is Object and not template.__default? )
#		or (not template.__default? and template.__default?)
#		template.__default = defaultTemplate
#	# setup $selectors
#	if not selectors?
#		selectors = []
#
#	selectors = $.extend
#			'errors': '.errors'
#			'input': 'input:first'
#			'label': 'label:first'
#		, selectors
#
#	form = if @is 'form'
#		then @filter('form').empty()
#		else $('<form/>').insertAfter @
#
#	if not structure.__form?
#		for attr, val of structure.__form
#			form.attr attr, val
#		attr = undefined
#		delete structure.__form

    # TODO dived to functions (class?), finish rewriting
#
#	formID = form.attr('id')
#		|| 'f_'+Math.random().toString().replace('.', '').slice(0, 5)
#	// no fieldsets
#	if (typeof structure[0] == 'undefined')
#		structure = [structure]
#	input
#	$.each(structure, ()
#		fieldsetFields = @
#		fieldset = $('<fieldset/>')
#		if (typeof fieldsetFields.__label != 'undefined')
#			fieldset.append('<legend>'+fieldsetFields.__label+'</legend>')
#			delete fieldsetFields.__label
#
#		for (field in fieldsetFields)
#			info = fieldsetFields[field]
#			// prepare info
#			if (typeof info != 'object')
#				info = 0: info
#			if (!(typeof info[0] != 'undefined'))
#				info[0] = 'text'
#			// prepare id
#			id = typeof info.id != 'undefined'
#				? info.id
#				: formID+'_'+field
#			// prepare template
#			if (typeof template == 'object')
#				if (typeof template[field] != 'undefined')
#					markup = template[field]
#				else if (typeof template['__'+info[0]] != 'undefined')
#					markup = template['__'+info[0]]
#				else
#					markup = template['__default']
#			 else
#				markup = template
#
#			markup = $('<div/>').html(markup).contents().remove()
#			// setup selectors
#			inputSelector, labelSelector
#			$.each(['input', 'label'], ()
#				selectorType = @
#				if (typeof selectors[selectorType] == 'object')
#					if (typeof selectors[selectorType][field] != 'undefined')
#						eval(selectorType+'Selector = selectors[selectorType][field]')
#					 else if (typeof selectors[selectorType]['__default'] != 'un