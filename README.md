# Facebook Test Users Manager

> **⚠️ This project is no longer maintained and has been archived.**
>
> **Why it no longer works:** Facebook has made several breaking changes to its Graph API that render all implementations in this project non-functional:
>
> 1. **Access token response format changed** — The `/oauth/access_token` endpoint used to return plain text (`access_token=TOKEN`). It now returns JSON (`{"access_token": "...", "token_type": "bearer"}`), breaking the token-parsing logic in every language implementation.
> 2. **HTTP method tunneling removed** — The project passes `method=post` and `method=delete` as GET query parameters to fake HTTP verbs. Facebook removed support for this method-override mechanism.
> 3. **Permissions removed** — The `publish_stream` and `publish_actions` permissions requested when creating test users no longer exist on the Facebook platform.
> 4. **Unversioned API endpoints deprecated** — The code calls unversioned Graph API URLs (e.g. `graph.facebook.com/{app_id}/accounts/test-users`). Facebook now requires a versioned path (e.g. `graph.facebook.com/v21.0/…`).
> 5. **Python 2 only** — The Python implementation uses `urllib2` and Python 2 `print` statement syntax, which are incompatible with Python 3.

- Weizhong Yang (a.k.a zonble)
- zonble at gmail dot com

You may have the same problem. You made a great application, and your
application publishes contents to Facebook, so you created a lots of
test cases which publish contents using your own Facebook account, and
then your account is banned since Facebook considers that you are
spamming.

In such a case, Facebook askes you to create a test user account but
not to use your own account. Facebook's API documentation is available
at https://developers.facebook.com/docs/test_users/ . All you need to
do is to visit the API endpoints with specific GET parameters.

The project aims to provide tools to make it easier to manipulate
Facebook's test user APIs. The project includes implementation with
Python, Ruby, PHP, Objective-C and JavaScript programming languages.

Enjoy it!
