require('dotenv').config();

const express = require('express');
const app = express();
const mongoose = require('mongoose');
const route = require('./routes');
const cors = require('cors');

const Sensor = require('./models/Sensor');

const mqtt = require('mqtt')

const accountSid = "ACf7576834793c6a73350507af5fc4c341";
const authToken = "9d5fb086575622a24f62296b6a436de5";
const clientsms = require("twilio")(accountSid, authToken);



const options = {
	host: 'broker.hivemq.com',
	port: 1883,
	protocol: 'mqtt',
}
const client = mqtt.connect(options);
client.on('connect', function () {
	console.log('Connected');
	client.subscribe('demo', function (err) {
		if (!err) {
			console.log('Subcribing to MQTT Broker!');
		}
	});
});
client.on('error', function (error) {
	console.log(error);
});


//Connect to mongodb database
mongoose.connect('mongodb+srv://admin:aloalo123@cluster0.ex56l.mongodb.net/myFirstDatabase?retryWrites=true&w=majority', {
	useUnifiedTopology: true,
	useNewUrlParser: true,
});
const db = mongoose.connection;
db.on('error', (error) => console.error(error));
db.once('open', () => {
	console.log('Connected to Database');
	client.on('message', async function (topic, message) {
		try {
			let content = JSON.parse(message.toString());
			console.log("content" + content);

			if(content.gasVal>600){
				clientsms.messages
  					.create({ body: "Phat hien khi gas, hay kiem tra", from: "+13156108151", to: "+84868349331" })
  					.then(message => console.log(message.sid));
			}

			//Save to db
			//Create a new Sensor
			const sensor = new Sensor({
				humidityAir: content.humidityAir,
				temperature: content.temperature,
				gasVal: content.gasVal,
			});
			
			const savedSensor = await sensor.save();
			console.log('[Saved DB] =>', savedSensor);
		} catch (err) {
			console.error(err);
		}
	});
});

//Use middleware to parse body req to json
app.use(express.json());

//Use middleware to enable cors
app.use(cors({
	origin: '*'
}));

//Route middleware
route(app);

//Start an express server
app.listen(process.env.PORT || 4000, () => console.log(`Server Started`));


