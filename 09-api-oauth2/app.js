const express = require('express');
const request = require("sync-request");
const randomstring = require("randomstring");
const querystring = require('querystring');
const url = require("url");
const qs = require("qs");
const __ = require('underscore');
const cons = require('consolidate');

// The OAuth2 client: this node.js app
var oauth2Client = {
    clientId: "my-client-id",
    clientSecret: "my-client-secret",
    redirectUri: "http://localhost:8081/callback"
};

// The OAuth2 server: Auth0 in this example
var oauth2Server = {
    authEndpoint: "https://my-tenant.auth0.com/authorize",
    tokenEndpoint: "https://my-tenant.auth0.com/oauth/token"
};

// The OAuth2 protected resource: ShinyProxy, assumed to be running on localhost:8080
var oauth2Resource = {
	audience: "my-resource-id",
	proxyControlUrl: "http://localhost:8080/api/proxy",
	proxyAccessUrl: "http://localhost:8080/api/route",
	exampleProxySpec: "01_hello"
};

var accessToken = null;
var state = null;
var scope = null;
var proxyId = null;

var app = express();
app.engine('html', cons.underscore);
app.set('view engine', 'html');

app.get('/', function (req, res) {
    res.render('index', {access_token: accessToken, scope: scope, proxyId: proxyId});
});

app.get('/authorize', function (req, res) {
    accessToken = null;
    state = randomstring.generate();
    
    var authUrl = url.parse(oauth2Server.authEndpoint, true);
    authUrl.query = {
		response_type: 'code',
		state: state,
		client_id: oauth2Client.clientId,
		redirect_uri: oauth2Client.redirectUri,
		audience: oauth2Resource.audience
	};
    authUrl = url.format(authUrl);
    
    res.redirect(authUrl);
});

app.get('/callback', function(req, res) {
	if (req.query.error) {
		res.render('error', {error: req.query.error});
		return;
	}
	if (req.query.state != state) {
		res.render('error', {error: 'State value did not match'});
		return;
	}

	var code = req.query.code;
    var basicAuth = new Buffer(querystring.escape(oauth2Client.clientId) + ':' + querystring.escape(oauth2Client.clientSecret)).toString('base64');

	var response = request('POST', oauth2Server.tokenEndpoint, {	
			body: qs.stringify({
                grant_type: 'authorization_code',
                code: code,
                redirect_uri: oauth2Client.redirectUri
            }),
			headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': 'Basic ' + basicAuth
            }
	});
	
	if (response.statusCode >= 200 && response.statusCode < 300) {
		var body = JSON.parse(response.getBody());
		accessToken = body.access_token;
		res.render('index', {access_token: accessToken, scope: scope, proxyId: proxyId});
	} else {
		res.render('error', {error: 'Error retrieving access token: ' + response.statusCode})
	}
});

app.get('/launch_proxy', function(req, res) {
	var response = request('POST', oauth2Resource.proxyControlUrl + "/" + oauth2Resource.exampleProxySpec, {	
		body: "[]",
		headers: {
			'Content-Type': 'application/json',
			'Authorization': 'Bearer ' + accessToken
		}
	});

	if (response.statusCode == 201) {
		var body = JSON.parse(response.getBody());
		proxyId = body.id;
		res.render('index', {access_token: accessToken, scope: scope, proxyId: proxyId});
	} else {
		res.render('error', {error: 'Error launching proxy: ' + response.statusCode})
	}
});

app.get('/access_proxy', function(req, res) {
	res.cookie('access_token', accessToken);
	res.redirect(oauth2Resource.proxyAccessUrl + "/" + proxyId + "/");
});

app.get('/stop_proxy', function(req, res) {
	var response = request('DELETE', oauth2Resource.proxyControlUrl + "/" + proxyId, {
		headers: {
			'Authorization': 'Bearer ' + accessToken
		}
	});

	if (response.statusCode == 200) {
		proxyId = null;
		res.render('index', {access_token: accessToken, scope: scope, proxyId: proxyId});
	} else {
		res.render('error', {error: 'Error stopping proxy: ' + response.statusCode})
	}
});

app.listen(8081);