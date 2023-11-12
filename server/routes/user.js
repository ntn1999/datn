const express = require('express');
const router = express.Router();
const Device = require('../models/Device');
const User = require('../models/User');
const moment = require('moment');

// router.get('/', auth(['customer', 'admin']), async (req, res) => {
router.get('/userList', async (req, res) => {
    try {
        // User.find({}, function(err, users) {
        //    return res.status(200).json({
        //         code:200,
        //         users,
        //     });      
        //  });
        
            const {role, address, city, district, ward,cityId,districtId,wardId  } = req.query;
            var query = {};
            if (role) {
                query.role = role;
            }
            if (address) {
                query.address = address;
            }
            if (city) {
                query.city = city;
            }
            if (district) {
                query.district = district;
            }
            if (ward) {
                query.ward = ward;
            }
            if (cityId) {
                query.cityId = cityId;
            }
            if (districtId) {
                query.districtId = districtId;
            }
            if (wardId) {
                query.wardId = wardId;
            }
            const users =await  User.find(query);
            return res.status(200).json({
                code:200,
                users
            });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const user = await User.findOne({ _id: req.query.id });
            return res.status(200).json({
                code:200,
                user,
            });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.post('/update/:id', async (req, res) => {
    try {
        User.findOneAndUpdate({_id: req.params.id},
            {
                $set : req.body
                // $set : {
                //     name: req.body.name,
                //     email: req.body.email,
                //     role: req.body.role,
                //     phone:req.body.phone,
                //     address:req.body.address,
                //     location:req.body.location
                // }
            },
            { new: true },
            (err, user) =>{
                if (err) {
                    res.status(400).json({ message: err });
                  } else  res.status(200).json({
                    user
                });
            }  
           
        );
        
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});
router.patch('/update/:id', async (req, res) => {
    try {
        User.findOneAndUpdate({_id: req.params.id},
            {
                $set : req.body
                // $set : {
                //     name: req.body.name,
                //     email: req.body.email,
                //     role: req.body.role,
                //     phone:req.body.phone,
                //     address:req.body.address,
                //     location:req.body.location
                // }
            },
            { new: true },
            (err, user) =>{
                if (err) {
                    res.status(400).json({ message: err });
                  } else  res.status(200).json({
                    user
                });
            }  
           
        );
        
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

router.get('/count', async (req, res) => {
  const FIRST_MONTH = 1
const LAST_MONTH = 12
const MONTHS_ARRAY = [ '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12' ]

  let TODAY  = new Date();
  let YEAR_BEFORE  = new Date(TODAY.getFullYear() - 1, TODAY.getMonth(), TODAY.getDate());
  try {
      User.aggregate([
        { 
          $match: { 
              role: 'customer',
              createdDate: { $gte: YEAR_BEFORE, $lte: TODAY }
          }
      },
      { 
          $group: {
              _id: { "year_month": { $substrCP: [ "$createdDate", 0, 7 ] } }, 
              count: { $sum: 1 }
          } 
      },
      {
          $sort: { "_id.year_month": 1 }
      },
      { 
          $project: { 
              _id: 0, 
              count: 1, 
              month_year: { 
                  $concat: [ 
                     { $arrayElemAt: [ MONTHS_ARRAY, { $subtract: [ { $toInt: { $substrCP: [ "$_id.year_month", 5, 2 ] } }, 1 ] } ] },
                     "-", 
                     { $substrCP: [ "$_id.year_month", 0, 4 ] }
                  ] 
              }
          } 
      },
      { 
          $group: { 
              _id: null, 
              data: { $push: { k: "$month_year", v: "$count" } }
          } 
      },
      { 
          $addFields: { 
              start_year: { $substrCP: [ YEAR_BEFORE, 0, 4 ] }, 
              end_year: { $substrCP: [ TODAY, 0, 4 ] },
              months1: { $range: [ { $toInt: { $substrCP: [ YEAR_BEFORE, 5, 2 ] } }, { $add: [ LAST_MONTH, 1 ] } ] },
              months2: { $range: [ FIRST_MONTH, { $add: [ { $toInt: { $substrCP: [ TODAY, 5, 2 ] } }, 1 ] } ] }
          } 
      },
      { 
          $addFields: { 
              template_data: { 
                  $concatArrays: [ 
                      { $map: { 
                           input: "$months1", as: "m1",
                           in: {
                               count: 0,
                               month_year: { 
                                   $concat: [ { $arrayElemAt: [ MONTHS_ARRAY, { $subtract: [ "$$m1", 1 ] } ] }, "-",  "$start_year" ] 
                               }                                            
                           }
                      } }, 
                      { $map: { 
                           input: "$months2", as: "m2",
                           in: {
                               count: 0,
                               month_year: { 
                                   $concat: [ { $arrayElemAt: [ MONTHS_ARRAY, { $subtract: [ "$$m2", 1 ] } ] }, "-",  "$end_year" ] 
                               }                                            
                           }
                      } }
                  ] 
             }
          }
      },
      { 
          $addFields: { 
              data: { 
                 $map: { 
                     input: "$template_data", as: "t",
                     in: {   
                         k: "$$t.month_year",
                         v: { 
                             $reduce: { 
                                 input: "$data", initialValue: 0, 
                                 in: {
                                     $cond: [ { $eq: [ "$$t.month_year", "$$this.k"] },
                                                  { $add: [ "$$this.v", "$$value" ] },
                                                  { $add: [ 0, "$$value" ] }
                                     ]
                                 }
                             } 
                         }
                     }
                  }
              }
          }
      },
      {
          $project: { 
              data: { $arrayToObject: "$data" }, 
              _id: 0 
          } 
      }
        ], function(err, result) {
          res.status(200).json({ result: result[0].data });

        });       
  
  } catch (error) {
      res.status(400).json({ message: error.message });
  }
});

router.get('/delete/:id', async (req, res) => {

    try {
        //Device.findOneAndRemove()
        User.findByIdAndRemove(req.params.id, (err, doc) => {
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

router.get('/userRequest', async (req,res)=>{ 
    try {
        const {role, address, city, district, ward,cityId,districtId,wardId  } = req.query;
        var query = {};
        if (role) {
            query.role = role;
        }
        if (address) {
            query.address = address;
        }
        if (city) {
            query.city = city;
        }
        if (district) {
            query.district = district;
        }
        if (ward) {
            query.ward = ward;
        }
        if (cityId) {
            query.cityId = cityId;
        }
        if (districtId) {
            query.districtId = districtId;
        }
        if (wardId) {
            query.wardId = wardId;
        }
    
        var arrayResult = [];
        const users = await User.find(query);
        await Promise.all(users.map(async (user) => {
            const devices = await Device.find({userId: user._id, status:false });
            if(devices.length > 0){
                arrayResult.push({
                    user,
                    devices: devices
                });
                console.log(arrayResult);
            }
        }));
        return res.status(200).json({
            result: arrayResult
        });
    
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

module.exports = router;
