const login = token => {
    return {
        type: 'LOGIN',
        payload: token
    }
}

const AuthAction = {
    login
}


export default AuthAction;