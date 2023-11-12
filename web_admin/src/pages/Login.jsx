import { Button, Form, Input, message } from "antd";
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import { useHistory } from "react-router-dom";
import banner from "../assets/images/banner.avif";
import AuthAction from "../redux/actions/AuthAction";
import authApi from "../service/authService";

const Login = () => {
  const history = useHistory();
  const isLogin = localStorage.getItem("accessToken");
  const dispatch = useDispatch();
  useEffect(() => {
    if (isLogin != null) {
      dispatch(AuthAction.login(isLogin));
      history.push("/");
    }
  }, []);
  //console.log(localStorage.getItem("accessToken"));

  const onFinish = (values) => {
    authApi
      .login("/auth/login", {
        email: values.email,
        password: values.password,
      })
      .then((res) => {
        dispatch(AuthAction.login(res.accessToken));
        localStorage.setItem("accessToken", JSON.stringify(res.data.accessToken));
        localStorage.setItem("user", JSON.stringify(res.data.user));
        history.push("/");
      })
      .catch((err) => {
        console.log("err");
        console.log(err);
        message.error({
          content: "Đăng nhập thất bại!",
        });
      });
  };

  return (
    <div className="login-page">
      <div className="login-box">
        <div className="illustration-wrapper">
          <img src={banner} alt="Login" />
        </div>
        <Form
          name="login-form"
          initialValues={{ remember: true }}
          onFinish={onFinish}
        >
          <p className="form-title">Welcome</p>
          <p>Login to the Dashboard</p>

          <Form.Item
            name="email"
            rules={[{ required: true, message: "Please input your email!" }]}
          >
            <Input placeholder="Email" />
          </Form.Item>

          <Form.Item
            name="password"
            rules={[{ required: true, message: "Please input your password!" }]}
          >
            <Input.Password placeholder="Password" />
          </Form.Item>

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              className="login-form-button"
            >
              LOGIN
            </Button>
          </Form.Item>
        </Form>
      </div>
    </div>
  );
};
export default Login;
