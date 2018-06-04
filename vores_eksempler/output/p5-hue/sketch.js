var x, y;
var lightStates = {};

function setup() {
	createCanvas(500, 500);
	setupOsc(12000, 3334);
}	

function draw() {
	background(127);
	if (lightStates.light1) {
		fill(lightStates.light1.bri, lightStates.light1.bri, 0);
		ellipse(mouseX, mouseY, 100, 100);
	}	
}	

function mouseReleased() {
	setLight(1, mouseX / width);
}

function receiveOsc(address, value) {
	if (address == '/wek/outputs') {
		setLight(1, value);
	}	
}	

function sendOsc(address, value) {
	socket.emit('message', [address].concat(value));
}	

function setupOsc(oscPortIn, oscPortOut) {
	var socket = io.connect('http://127.0.0.1:8081', {
		port: 12000,
		rememberTransport: false
	});
	socket.on('connect', function () {
		socket.emit('config', {
			server: {
				port: oscPortIn,
				host: '127.0.0.1'
			},
			client: {
				port: oscPortOut,
				host: '127.0.0.1'
			}
		});
	});
	socket.on('message', function (msg) {
		if (msg[0] == '#bundle') {
			for (var i = 2; i < msg.length; i++) {
				receiveOsc(msg[i][0], msg[i].splice(1));
			}
		} else {
			receiveOsc(msg[0], msg.splice(1));
		}
	});
}

function setLight(lightNo, value) {

	var hue = {
		ipAddress: '192.168.8.109',
		apiKey: 'C2fr-2XtwFq3Z7G3Xk4XftfEq48pY0oxXaYMJcU4'
	};

	var url = "http://" + hue.ipAddress + "/api/" + hue.apiKey + "/lights/" + lightNo + "/state"

	var payload = {
		'on': (value > 0),
		'bri': Math.round(value * 255),
		'transitiontime': 0
	};

	var thisLightState = lightStates["light" + lightNo];

	if (thisLightState === undefined || 
		Math.abs(thisLightState.bri - payload.bri) > 5) {

		lightStates["light" + lightNo] = payload;

		var payloadLength = JSON.stringify(payload).length;

		var reqwestOptions = {
			url: url,
			type: 'json',
			method: 'put',
			data: JSON.stringify(payload),
			crossOrigin: true,
			error: function (err) {
				console.log(err);
			},
			success: function (err) {
				console.log(err);
			}
		};

		httpDo(reqwestOptions);
	}
}
