import instance from "./client"

class CustomerApi {
    getAll = (url, params) => {
        return instance.get(url,  params)
    };
    getQuantity = (url, params) => {
        return instance.get(url,  params)
    };
    getCustomerById = (url, params) => {
        return instance.get(url,  {params} )
    }
    getUserRequest = (url, params) => {
        return instance.get(url,  {params} )
    }
    addCustomer = (url, params) => {
        return instance.post(url,  params)
    }
}
const customerApi = new CustomerApi();
export default customerApi;