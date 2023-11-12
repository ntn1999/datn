const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
	name: {
		type: String,
		required: true,
		min: 6,
		max: 30,
	},
	email: {
		type: String,
		required: true,
		max: 255,
		min: 6,
	},
	location: {
		type: String,
		required: true,
		max: 255,
		min: 6,
	},
	address: {
		type: String,
		max: 255,
		min: 6,
	},
	city: {
		type: String,
		required: true,
		max: 255,
	},
	district: {
		type: String,
		required: true,
		max: 255,
	},
	ward: {
		type: String,
		required: true,
		max: 255,
	},
	cityId: {
		type: String,
		required: true,
		max: 255,
	},
	districtId: {
		type: String,
		required: true,
		max: 255,
	},
	wardId: {
		type: String,
		required: true,
		max: 255,
	},
	phone: {
		type: String,
		required: true,
	},
	supporterId: {
		type: String,
	},
	supporterName: {
		type: String,
	},
	password: {
		type: String,
		required: true,
		max: 128,
		min: 6,
	},
	role: {
		type: String,
		enum: ['admin', 'customer', 'support'],
		default: 'customer',
	},
	createdDate: {
		type: Date,
		default: Date.now,
	},
	modifiedDate: {
		type: Date,
		default: Date.now,
	},
});

module.exports = mongoose.model('User', userSchema);
