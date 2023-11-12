const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
	name: {
		type: String,
		required: true,
	},
	userId: {
		type: String,
		required: true,
	},
	deviceOwner: {
		type: String,
		required: true,
	},
    description:{
		type: String,
		
		required: true,
	},
	room:{
		type: String,
		enum: ['living-room', 'kitchen','bathroom','bedroom'],
		required: true,
	},
	note:{
		type: String,
	},
	installationDate:{
		type: String,
		required: true,
	},
	status:{
		type: Boolean,
		default: false,
	},
	statusRequest:{
		type: Boolean,
		default: true,
	},
	isControl:{
		type: Boolean,
		default: true,
	},

});

module.exports = mongoose.model('Device', userSchema);
