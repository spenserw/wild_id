import React from "react";
import { Link, NavLink, Outlet, useLocation } from "react-router-dom";
import { Divider, Layout, Menu, Tooltip } from "antd";

import logo from "images/wild_id_logo_draft1.png";

const { Header, Content, Footer } = Layout;

const AppLayout = () => {
  // Currently selected tab based on route
  const selectedKeys = () => {
    const path = useLocation().pathname;
    const [match, tab] = path.match(/\/([^\/]+)?\/?/);
    return tab ? tab : [];
  };

  return (
    <Layout>
      <Header style={{ backgroundColor: "#ffffff" }}>
        <Link to="/">
          <div className="logo" style={{ float: "left", marginRight: "32px" }}>
            <img src={logo} height="32" />
          </div>
        </Link>

        <Menu mode="horizontal" selectedKeys={selectedKeys()}>
          <Menu.Item key="birds">
            <NavLink to="birds">Birds</NavLink>
          </Menu.Item>
          <Menu.Item key="plants" disabled="true">
            <Tooltip placement="bottom" title={<span>Coming soon!</span>}>
              <NavLink to="plants">Plants</NavLink>
            </Tooltip>
          </Menu.Item>
        </Menu>
      </Header>

      <Content style={{ backgroundColor: "white" }}>
        <Outlet />
      </Content>

      <Footer>WildID ©2022</Footer>
    </Layout>
  );
};

export default AppLayout;
