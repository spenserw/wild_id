import React from "react";
import styled from "styled-components";

import landingPhoto from "images/landing-photo.jpg";

const HomeContainer = styled.div``;

const LandingContainer = styled.div`
  background-color: rgba(0, 0, 0, 0.4);
  position: absolute;
  top: 18%;
  left: 5%;
  padding: 15px;
  color: white;

  p {
    color: "white";
  }
`;

const LandingPhoto = styled.img`
  width: 100%;
  height: 86vh;
  object-fit: cover;
`;

const LandingMotto = styled.h1`
  font-size: 32px;
  color: white;
  margin-bottom: 8px;
`;

const Home = () => {
  return (
    <HomeContainer>
      <LandingPhoto src={landingPhoto} />
      <LandingContainer>
        <LandingMotto>Explore your surroundings</LandingMotto>
        <p>Discover species of birds, plants, and more.</p>
      </LandingContainer>
    </HomeContainer>
  );
};

export default Home;
