import instance from "./client"

class AuthApi {
    login = (url, params) => {
        return instance.post(url, params)
    }
}
const authApi = new AuthApi();
export default authApi;