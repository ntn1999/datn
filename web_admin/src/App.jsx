import { useSelector } from "react-redux";
import { BrowserRouter, Redirect, Route, Switch } from "react-router-dom";
import Layout from "./components/layout/Layout";
import Login from "./pages/Login";

const App = () => {
  const authReducer = useSelector((state) => state.AuthReducer);

  return (
    <BrowserRouter>
      <Switch>
        {authReducer.accessToken ? (
          <Route path={"/*"} component={Layout} exact />
        ) : (
          <Route path={"/login"} component={Login} exact />
        )}
        <Route path="*">
          <Redirect to={"/login"} />
        </Route>
      </Switch>
    </BrowserRouter>
  );
};

export default App;
