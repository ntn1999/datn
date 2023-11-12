const subscriberRouter = require('./subscribers');
const authRouter = require('./auth');
const sensorRouter = require('./sensor');
const userRouter = require('./user');
const deviceRouter = require('./device');
const reportRouter = require('./report');
//Index of route middleware
const route = (app) => {
	//Route middleware subscribers
	app.use('/subscribers', subscriberRouter);

	//Route middleware auth
	app.use('/api/auth', authRouter);

	//Route sensor
	app.use('/api/sensor', sensorRouter);

	app.use('/api/user', userRouter);

	app.use('/api/device', deviceRouter);

	app.use('/api/report', reportRouter);
};

module.exports = route;
