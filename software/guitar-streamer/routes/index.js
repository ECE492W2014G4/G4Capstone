var express = require('express');
var router = express.Router();
var streamer = require('icy');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/audio', function(req, res, next) {
	streamer.get("http://localhost:8000/guitar.ogg",function(icyRes){
		res.status(200).set({
			'Content-Type': "audio/ogg",
			'Transfer-Encoding': 'chunked'
		});
		icyRes.pipe(res);
	});
});



module.exports = router;
