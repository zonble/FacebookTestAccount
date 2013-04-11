http = require('http')
https = require('https')
open_url = (url, callback) ->
	https.get url, (resp) =>
		resp.setEncoding 'utf8'
		data = ''
		resp.on 'data', (chunk) -> data += chunk
		resp.on 'end', -> callback data
		return

class FacebookTestUserManager

	constructor: (@facebookAppID, @facebookSecret) -> @appAccessToken = null

	_obtain_app_access_token: (callback) ->
		url = 'https://graph.facebook.com/oauth/access_token?'
		url += 'client_id=' + @facebookAppID
		url += '&client_secret=' + @facebookSecret
		url += '&grant_type=client_credentials'
		open_url url, (data) =>
			@appAccessToken = data.substr 'access_token='.length
			callback.call this, @appAccessToken if callback?
			return

	_create_test_account: (callback, username='Test') ->
		url = "https://graph.facebook.com/#{@facebookAppID}/accounts/test-users?"
		url += '&installed=true'
		url += '&name=' + username
		url += '&locale=en_US'
		url += '&method=post'
		url += '&access_token=' + @appAccessToken
		url += '&permissions=email,publish_stream,user_about_me,publish_actions'
		open_url url, (data) =>
			callback JSON.parse(data) if callback?; return
		return

	create_test_account: (callback, username='Test') ->
		if !@appAccessToken
			@_obtain_app_access_token ->
				@_create_test_account callback, username; return
		else
			@_create_test_account callback, username
		return

	_delete_test_account: (user_id, callback) ->
		url = "https://graph.facebook.com/#{user_id}/?"
		url += 'method=delete'
		url += '&access_token=' + @appAccessToken
		open_url url, (data) =>
			callback data == 'true' if callback?; return
		return

	delete_test_account: (user_id, callback) ->
		if !@appAccessToken
			@_obtain_app_access_token ->
				@delete_test_account user_id, callback; return
		else
			@_delete_test_account user_id, callback
		return

	_list_test_users: (callback) ->
		url = "https://graph.facebook.com/#{@facebookAppID}/accounts/test-users"
		url += '?access_token=' + @appAccessToken
		open_url url, (data) =>
			callback JSON.parse(data)['data'] if callback; return
		return

	list_test_users: (callback) ->
		if !@appAccessToken
			@_obtain_app_access_token ->
				@_list_test_users callback; return
		else
			@_list_test_users callback
		return

	_delete_all_test_users: (callback) ->
		@list_test_users (users) =>
			@delete_test_account user['id'] for user in users; return
		return

	delete_all_test_users: (callback) ->
		if !@appAccessToken
			@_obtain_app_access_token ->
				@_delete_all_test_users callback; return
		else
			@_delete_all_test_users callback
		return

if require.main == module
	appID = '181603781919524'
	appSecret = 'f075c9b716d5b48d04d40275a92c7fc7'
	m = new FacebookTestUserManager appID, appSecret
	m.create_test_account( (user) ->
		user_id = user['id']
		console.log user_id
		m.delete_test_account user_id, (x) -> console.log x
		)
	m.list_test_users((x) -> console.log x )
	m.delete_all_test_users()