const AuthReducer = (state = {}, action) => {
    switch (action.type) {
        case 'LOGIN':
            return {
                ...state,
                accessToken: action.payload
            }

        default:
            return state
    }
}

export default AuthReducer;