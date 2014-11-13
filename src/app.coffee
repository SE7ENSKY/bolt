GoogleSpreadsheet = require "google-spreadsheet"

sheet = new GoogleSpreadsheet process.env.SPREADSHEET_KEY
# sheet.getRows 1, (err, rows) ->
# 	console.log 'row count: ' + rows.length
sheet.setAuth process.env.GOOGLE_USER, process.env.GOOGLE_PASS, (err) ->
	if err
		console.error err
		process.exit 1
	else
		express = require 'express'
		moment = require 'moment'
		Validator = require 'validate-form'
		validators =
			truthy: require 'validate-form/truthy'
			email: require 'validate-form/email'
		validateForm = Validator
			name: [validators.truthy()]
			email: [validators.truthy(), validators.email("Please ensure that you enter valid email")]
			phone: []
			company: []
			position: []
			message: []
		
		app = express()
		app.enable 'trust proxy'
		app.use (req, res, next) ->
			res.header "Access-Control-Allow-Origin", "*"
			res.header "Access-Control-Allow-Headers", "X-Requested-With"
			next()
		app.use require('body-parser').urlencoded
			extended: on
			limit: '4kb'
			parameterLimit: 20
		app.post '/form', (req, res) ->
			validationErrors = validateForm req.body
			if validationErrors
				res.send "validation failed"
			else
				row = req.body
				now = moment()
				row.date = now.format 'DD.MM.YYYY'
				row.time = now.format 'HH:mm:ss'
				row.ip = req.ip
				sheet.addRow process.env.SPREADSHEET_SHEET_INDEX, row
				res.send 'ok'

		app.listen process.env.PORT or 3000
