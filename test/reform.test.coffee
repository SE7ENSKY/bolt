chai = require('chai')
chai.should()

reform = require '../src/reform'

describe 'reform', ->
	it 'should work on kz example', ->
		kzSchema =
			name: on
			email: ['required', 'email']
			phone: off
			company: off
			position: off
			message: off
		reform {name: 'Ivan', email:'roma@se7ensky.com'}, kzSchema, (err, params) ->
			console.log err, params
