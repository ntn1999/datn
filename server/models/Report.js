const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
	
	userId: {
		type: String,
	},
    nameUser: {
		type: String,
		required: true,
	},
    customerName: {
		type: String,
		required: true,
	},
    customerId: {
		type: String,
		required: true,
	},
    content:{
		type: String,
		required: true,
	},
    title:{
		type: String,
		required: true,
	},
    bill:{
		type: String,
	},
    createdDate: {
		type: Date,
		default: Date.now,
	},

});

module.exports = mongoose.model('Report', reportSchema);
