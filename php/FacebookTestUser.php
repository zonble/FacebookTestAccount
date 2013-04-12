<?php

/**
 * FacebookTestUserManager
 *
 * A tool which helps to create and delete test account for Facebook.
 * @author Weizhong Yang <zonble at gmail dot com>
 * @package FacebookTestUserManager
 * @link https://developers.facebook.com/docs/test_users/
 */

/**
 * The manager which helps to create and delete test accounts.
 * @package FacebookTestUserManager
 * @subpackage classes
 */
Class FacebookTestUserManager {
  var $appID;
  var $appSecret;
  var $appToken;

  function __construct($inAppID, $inAppSecret) {
	$this->appID = $inAppID;
	$this->appSecret = $inAppSecret;
  }

  function _obtain_app_access_token() {
	$URL = "https://graph.facebook.com/oauth/access_token?";
	$URL .= http_build_query(array(
	  'client_id'=> $this->appID,
	  'client_secret' => $this->appSecret,
	  'grant_type' => 'client_credentials'
	));
	$content = @file_get_contents($URL);
	if (strlen($content)) {
	  $this->appToken = substr($content, strlen('access_token='));
	}
  }

  function _try_obtain_app_access_token() {
	if (is_null($this->appToken)) {
	  $this->_obtain_app_access_token();
	}
	if (is_null($this->appToken)) {
	  die("Unable to fetch app access token.");
	}
  }

  /**
   * Create a new test account.
   * @param string $username user name of the new test account.
   * @param array $perms disired permissions.
   * @return object
   */
  function create_test_account($username='test',
							   $perms=array('email', 'publish_stream',
											'user_about_me',
											'publish_actions')) {
	$this->_try_obtain_app_access_token();
	$URL = "https://graph.facebook.com/{$this->appID}/accounts/test-users?";
	$URL .= http_build_query(array(
	  'installed' => 'true',
	  'name' => $username,
	  'locale' => 'en_US',
	  'access_token' => $this->appToken,
	  'method' => 'post'));
	$URL .= '&permissions='.implode(',', $perms);
	return @json_decode(@file_get_contents($URL));
  }

  /**
   * Delete a test account.
   * @param string $userID ID of the user that will be deleted
   * @return boolean
   */
  function delete_test_user($userID) {
	$this->_try_obtain_app_access_token();
	$URL = "https://graph.facebook.com/{$userID}/?";
	$URL .= http_build_query(array(
	  'method' => 'delete',
	  'access_token' => $this->appToken));
	return @json_decode(@file_get_contents($URL));
  }

  /**
   * List all test users.
   */
  function list_test_users() {
	$this->_try_obtain_app_access_token();
	$URL = "https://graph.facebook.com/{$this->appID}/accounts/test-users?";
	$URL .= 'access_token='.$this->appToken;
	return @json_decode(@file_get_contents($URL))->data;
  }

  /**
   * Delete all test users.
   */
  function delete_all_test_users() {
	$users = $this->list_test_users();
	foreach($users as $user) {
	  $this->delete_test_user($user->id);
	}
  }
}

/*
$appID = '181603781919524';
$appSecret = 'f075c9b716d5b48d04d40275a92c7fc7';
$m = new FacebookTestUserManager($appID, $appSecret);
var_dump($m->create_test_account());
var_dump($m->list_test_users());
$m->delete_all_test_users();
var_dump($m->list_test_users());
*/
?>
