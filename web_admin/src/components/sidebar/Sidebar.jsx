import React from "react";

import { Link } from "react-router-dom";

import "./sidebar.css";

import logo from "../../assets/images/main-logo.jpg";

import sidebar_items from "../../assets/JsonData/sidebar_routes.json";

import sidebar_sp_items from "../../assets/JsonData/sidebar_routes_sp.json";

const SidebarItem = (props) => {
  const active = props.active ? "active" : "";

  return (
    <div className="sidebar__item">
      <div className={`sidebar__item-inner ${active}`}>
        <i className={props.icon}></i>
        <span>{props.title}</span>
      </div>
    </div>
  );
};

const Sidebar = (props) => {
  const user = JSON.parse(localStorage.getItem("user"));
  const sideBar = user.role !== "admin" ? sidebar_sp_items : sidebar_items;

  const activeItem = sidebar_items.findIndex(
    (item) => item.route === props.location.pathname
  );

  return (
    <div className="sidebar">
      <div className="sidebar__logo">
        <img src={logo} alt="company logo" />
      </div>
      {/* {role === 'supporter' ? () : ()} */}
      {sideBar.map((item, index) => (
        <Link to={item.route} key={index}>
          <SidebarItem
            title={item.display_name}
            icon={item.icon}
            active={index === activeItem}
          />
        </Link>
      ))}
    </div>
  );
};

export default Sidebar;
