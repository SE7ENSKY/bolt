EMAIL_REGEX = ///^[a-zA-Z_\-\.0-9]+@[a-zA-Z_\-\.0-9]+\.[a-zA-Z]+///

predefinedValidations =
	required: (s) -> s and s isnt ""
	email: (s) -> EMAIL_REGEX.test s

module.exports = reform = (data, schema, callback) ->
	result = {}
	errors = {}
	invalid = no
	for key, validations of schema
		value = data[key]
		if validations
			validations = ['required'] if validations and typeof validations is 'boolean'
			validations = [validations] if typeof validations is 'string'
			validations = [validations] if typeof validations is 'function'
			invalids = {}
			hasInvalids = false
			for validation in validations
				validator = if typeof validation is 'string'
					predefinedValidations[validation]
				else if typeof validation is 'function'
					validation
				valid = validator value
				if valid and typeof valid is 'boolean'
					result[key] = value
				else
					invalids[validation.toString()] = true
					hasInvalids = yes
					invalid = yes
			errors[key] = invalids if hasInvalids
		else
			result[key] = value
	if invalid
		callback errors
	else
		callback null, result
