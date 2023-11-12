import React from "react";

import "./topnav.css";

import { useHistory } from "react-router-dom";

import Dropdown from "../dropdown/Dropdown";

import user_image from "../../assets/images/person.png";

import { Button } from "antd";
import user_menu from "../../assets/JsonData/user_menus.json";
import { useDispatch } from "react-redux";
import AuthAction from "../../redux/actions/AuthAction";

const renderUserToggle = (user) => (
  <div className="topnav__right-user">
    <div className="topnav__right-user__name">{user.display_name}</div>
    <div className="topnav__right-user__image">
      <img src={user.image} alt="" />
    </div>
  </div>
);

const Topnav = () => {
  const user = JSON.parse(localStorage.getItem("user"));

  const curr_user = {
    display_name: user.name,
    image: user_image,
  };
  const history = useHistory();
  const dispatch = useDispatch();
  const renderUserMenu = (item, index) => (
    <Button
      type="link"
      onClick={() => {
        localStorage.clear();
        dispatch(AuthAction.login(undefined));
        history.push("/login");
      }}
      key={index}
    >
      <div className="notification-item">
        <i className={item.icon}></i>
        <span>{item.content}</span>
      </div>
    </Button>
  );
  return (
    <div className="topnav">
      <div className="topnav__search">
        {/* <input type="text" placeholder="Search here..." />
        <i className="bx bx-search"></i> */}
      </div>
      <div className="topnav__right">
        <div className="topnav__right-item">
          {/* dropdown here */}
          <Dropdown
            customToggle={() => renderUserToggle(curr_user)}
            contentData={user_menu}
            renderItems={(item, index) => renderUserMenu(item, index)}
          />
        </div>
      </div>
    </div>
  );
};

export default Topnav;
