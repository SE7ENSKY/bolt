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

		reform = require './reform'
		reformValidator = (req, res, next) ->
			reform req.body,
				name: on
				email: ['required', 'email']
				phone: off
				company: off
				position: off
				message: off
			, (err, params) ->
				if err
					res.status(409).json
						message: 'ValidationError'
						code: 'ValidationError'
						errors: err
					next "invalid input"
				else
					req.body = params
					next()
		
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
		app.post '/form', reformValidator, (req, res) ->
			row = req.body
			now = moment()
			row.date = now.format 'DD.MM.YYYY'
			row.time = now.format 'HH:mm:ss'
			row.ip = req.ip
			sheet.addRow process.env.SPREADSHEET_SHEET_INDEX, row
			res.send 'ok'

		app.listen process.env.PORT or 3000
