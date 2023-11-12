import React from "react";

import { Route, Switch } from "react-router-dom";

import Customers from "../pages/Customers";
import Dashboard from "../pages/Dashboard";
import Requests from "../pages/Requests";
import Reports from "../pages/Reports";
import CustomerDetail from "../pages/CustomerDetail";

const Routes = () => {
  return (
    <Switch>
      <Route path="/" exact component={Dashboard} />
      <Route path="/customers" exact component={Customers} />
      <Route path="/customer/:id" exact component={CustomerDetail} />
      <Route path="/requests" exact component={Requests} />
      <Route path="/reports" exact component={Reports} />
    </Switch>
  );
};

export default Routes;
