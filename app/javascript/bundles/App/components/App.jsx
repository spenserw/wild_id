import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import "antd/dist/antd.css";

import AppLayout from "./Layout";
import Home from "./Home";
import Birds from "./Birds";
import BirdSpeciesPage from "./BirdSpeciesPage";

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<AppLayout />}>
        <Route index element={<Home />} />
        <Route path="birds" element={<Birds />} />
        <Route path="birds/:sci_name" element={<BirdSpeciesPage />} />
      </Route>
    </Routes>
  </BrowserRouter>
);

export default App;
