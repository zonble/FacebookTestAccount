using HTTPClient.HTTPC
using JSON

type FacebookAppInfo
    app_id::String
    app_secret::String
    app_access_token::String
end

function obtain_app_access_token!(app_info::FacebookAppInfo)
    get_parameters = [("client_id", app_info.app_id),
                      ("client_secret", app_info.app_secret),
                      ("grant_type", "client_credentials")]
    url = "https://graph.facebook.com/oauth/access_token?" *
          HTTPC.urlencode_query_params(get_parameters)
    r = HTTPC.get(url)
    @assert r.http_code == 200
    body = bytestring(r.body)
    access_token = body[length("access_token=") + 1:]
    app_info.app_access_token = access_token
end

macro confirm_logged_in(app_info)
    quote
        if length(app_info.app_access_token) == 0
            obtain_app_access_token!(app_info)
        end
    end
end

function _open_url(url)
    r = HTTPC.get(url)
    @assert r.http_code == 200
    body = bytestring(r.body)
    return JSON.parse(bytestring(r.body))
end

function create_test_account(app_info::FacebookAppInfo, username="Test",
    permissions=["email", "publish_stream", "user_about_me", "publish_actions"])
    @confirm_logged_in app_info
    get_parameters = [("installed", "true"), ("name", username),
                      ("locale", "en_US"), ("method", "post"),
                      ("access_token", app_info.app_access_token)]
    url = "https://graph.facebook.com/" * app_info.app_id * "/accounts/test-users?"
    url *= HTTPC.urlencode_query_params(get_parameters)
    url *= "&permissions=" * join(",", permissions)
    return _open_url(url)
end

function delete_test_user(app_info::FacebookAppInfo, user_id)
    @confirm_logged_in app_info
    get_parameters = [("method", "delete"),
                      ("access_token", app_info.app_access_token)]
    url = "https://graph.facebook.com/" * string(user_id) * "/?"
    url *= HTTPC.urlencode_query_params(get_parameters)
    return _open_url(url)
end

function list_test_users(app_info::FacebookAppInfo)
    @confirm_logged_in app_info
    url = "https://graph.facebook.com/" * app_info.app_id * "/accounts/test-users?"
    url *= "access_token=" * app_info.app_access_token
    return _open_url(url)["data"]
end

function delete_all_test_users(app_info::FacebookAppInfo)
    @confirm_logged_in app_info
    users = list_test_users(app_info)
    for user in users
        delete_test_user(app_info, user["id"])
    end
end

# app_info = FacebookAppInfo("181603781919524", "f075c9b716d5b48d04d40275a92c7fc7", "")
# print(list_test_users(app_info))
# delete_all_test_users(app_info)
# print(list_test_users(app_info))
# id = create_test_account(app_info)["id"]
# println(delete_test_user(app_info, id))
