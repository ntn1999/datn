const express = require('express');
const router = express.Router();
const Device = require('../models/Device');
const User = require('../models/User');
const Report = require('../models/Report');
const moment = require('moment');

// router.get('/', auth(['customer', 'admin']), async (req, res) => {
router.get('/reports', async (req, res) => {
    try {
            const {role, address, city, district, ward,cityId,districtId,wardId  } = req.query;
            var query = {};
            if (role) {
                query.role = role;
            }
            if (address) {
                query.address = address;
            }
            const reports =await  Report.find(query);
            return res.status(200).json({
                code:200,
                reports
            });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.post('/create', async (req, res) => {

    const report = new Report({
        userId: req.body.userId,
        nameUser: req.body.nameUser,
        customerName: req.body.customerName,
        customerId: req.body.customerId,
        content: req.body.content,
        title: req.body.title,
        bill: req.body.bill
    });
    try {
        const savedReport = await report.save();
        res.status(200).json(savedReport);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const report= await Report.findOne({ _id: req.query.id });
            return res.status(200).json({
                code:200,
                report,
            });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.patch('/update/:id', async (req, res) => {
    try {
        Report.findOneAndUpdate({_id: req.params.id},
            {
                $set : req.body
            },
            { new: true },
            (err, report) =>{
                if (err) {
                    res.status(400).json({ message: err });
                  } else  res.status(200).json({
                    report
                });
            }  
           
        );
        
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.get('/delete/:id', async (req, res) => {

    try {
        Report.findByIdAndRemove(req.params.id, (err, doc) => {
            if (!err) {
                res.status(200).json({message: 'Delete success'});
            } else {
                res.status(400).json({ message: err });
            }
        });

    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

module.exports = router;
