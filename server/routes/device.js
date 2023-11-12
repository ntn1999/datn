const express = require('express');
const router = express.Router();
const Device = require('../models/Device');
const moment = require('moment');
const auth = require('../middlewares/auth');
// router.get('/', auth(['customer', 'admin']), async (req, res) => {
router.get('/listDevice', async (req, res) => {
    try {
        if(req.query.userId ==null || req.query.userId == '' ){

            // Device.updateMany(
            //     {},
            //     { $set: { isControl: true}},
            //     { upsert: true },
            //     function(err, result) {
            //       if (err) throw err;
            //       console.log(result.result.nModified + " documents updated");
            //     }
            //   );

            Device.find({}, function(err, devices) {
                return res.status(200).json({
                    devices,
                });
              });
        }else{
            Device.find({userId: [req.query.userId]}, function(err, devices) {
                return res.status(200).json({
                    devices,
                });
              });
        }

      
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});


router.get('/deviceRequestFix', async (req, res) => {
    try {
        if(req.query.userId ==null || req.query.userId =='' ){
            Device.find({ status:false }, function(err, devices) {
                return res.status(200).json({
                    length: devices.length,
                    devices,
                });
              });
        }else Device.find({userId: req.query.userId, status:false }, function(err, devices) {
            return res.status(200).json({
                length: devices.length,
                devices,
            });
          });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});
router.patch('/update/:id', async (req, res) => {
    try {
        Device.findOneAndUpdate({_id: req.params.id},
            {
                $set : req.body
            },
            { new: true },
            (err, device) =>{
                if (err) {
                    res.status(400).json({ message: err });
                  } else  res.status(200).json({
                    device
                });
            }  
           
        );
        
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

//router.post('/create', auth(['customer', 'admin']), async (req, res) => {
router.post('/create', async (req, res) => {

    const device = new Device({
        name: req.body.name,
        userId: req.body.userId,
        deviceOwner: req.body.deviceOwner,
        description: req.body.description,
        installationDate: req.body.installationDate,
        note: req.body.note,
        room: req.body.room,
        status: req.body.status
    });
    try {
        const savedDevice = await device.save();
        res.status(200).json(savedDevice);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

router.get('/delete/:id', async (req, res) => {

    try {
        //Device.findOneAndRemove()
        Device.findByIdAndRemove(req.params.id, (err, doc) => {
            if (!err) {
                res.status(200).json({message: 'Delete success'});
            } else {
                res.status(400).json({ message: err });
            }
        });
       // res.status(200).json(savedDevice);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

module.exports = router;
