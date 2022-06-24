import React from "react";
import { Link } from "react-router-dom";
import PropTypes from "prop-types";
import styled from "styled-components";
import { Tag } from "antd";
import { FileImageOutlined } from "@ant-design/icons";
import _ from "lodash";

import { get_reference_image_src } from "../api";

// flex: 1 1 345px;
const BirdSpeciesContainer = styled.div`
  border: 1px solid rgb(211, 211, 211, 0.6);
  border-radius: 3px;
  flex: 0 1 23%;
  overflow: hidden;
  min-height: 240px;
  margin: 10px;
  position: relative;
`;

const BirdSpeciesPrimaryReferenceImage = styled.img`
  width: 100%;
  height: 240px;
  object-fit: cover;
`;

const BirdSpeciesInfoContainer = styled.div`
  position: absolute;
  width: 100%;
  height: 60px;
  bottom: 0px;
  left: 0px;
  background: linear-gradient(
    0deg,
    rgba(24, 24, 24, 0.6796919451374299) 0%,
    rgba(24, 24, 24, 0.36876757538953087) 60%,
    rgba(24, 24, 24, 0) 100%
  );
`;

const BirdSpeciesInfoWrapper = styled.div`
  position: absolute;
  bottom: 8px;
  left: 8px;
`;

const BirdSpeciesCommonName = styled.span`
  font-size: 18px;
  margin: 5px;
  margin-right: 8px;
  color: white;
`;

const BirdSpeciesSciName = styled.span`
  font-style: italic;
  font-size: 17px;
  color: white;
`;

const BirdSeasonalBadgesWrapper = styled.span`
  position: absolute;
  top: 8px;
  right: 2px;
`;

const BirdOriginBadgeWrapper = styled.span`
  position: absolute;
  top: 34px;
  right: 2px;
`;

const BirdSpeciesSmall = (props) => {
  const primaryReferenceImage = () => {
    // Missing image
    if (
      props.primary_reference_image_id == null ||
      props.primary_reference_image_id == "undefined"
    )
      return (
        <div style={{ textAlign: "center", position: "relative" }}>
          <FileImageOutlined
            style={{
              position: "absolute",
              top: "56px",
              left: "42%",
              fontSize: "64px",
            }}
          />
        </div>
      );

    const primaryReferenceImageSrc = get_reference_image_src(
      props.primary_reference_image_id,
      "m"
    );
    return <BirdSpeciesPrimaryReferenceImage src={primaryReferenceImageSrc} />;
  };

  const renderSeasonalBadges = () => {
    // TODO 4-4-2022: Replace these hardcoded values with the configurable colors to be used in the range maps.
    const seasonToColor = {
      resident: "#8302fc",
      breeding: "#fc5902",
      nonbreeding: "#02b1fc",
      passage: "#fcd202",
    };
    const seasons = props.seasons;

    let badges = [];
    if (seasons.includes("resident")) {
      badges.push(
        <Tag key="resident" color={seasonToColor["resident"]}>
          Resident
        </Tag>
      );
    } else {
      badges = seasons.map((season) => (
        <Tag key={season} color={seasonToColor[season]}>
          {_.capitalize(season)}
        </Tag>
      ));
    }

    return <BirdSeasonalBadgesWrapper>{badges}</BirdSeasonalBadgesWrapper>;
  };

  const renderOriginBadge = () => {
    if (!props.showNativeTag && props.origin == 1) return (<div />);

    const originToColor = {
      // DEV: Native is a keyword?? Probably a Java thing >:( EW! 
      "1": "#4bbd3c",
      "3": "#e63a2e"
    },
    originLabels = {
      "1": "Native",
      "3": "Introduced"
    };

    return (
      <BirdOriginBadgeWrapper>
        <Tag key={props.origin} color={originToColor[props.origin]} >
          {originLabels[props.origin]}
        </Tag>
      </BirdOriginBadgeWrapper>
    );
  };

  const birdSpeciesLinkPath = encodeURI(`/birds/${props.scientific_name}`);

  return (
    <BirdSpeciesContainer>
      <Link to={birdSpeciesLinkPath}>
        {primaryReferenceImage()}
        <BirdSpeciesInfoContainer>
          <BirdSpeciesInfoWrapper>
            <BirdSpeciesCommonName>
              {props.common_names[0]}
            </BirdSpeciesCommonName>
            <BirdSpeciesSciName>({props.scientific_name})</BirdSpeciesSciName>
          </BirdSpeciesInfoWrapper>
        </BirdSpeciesInfoContainer>
        {renderSeasonalBadges()}
        {renderOriginBadge()}
      </Link>
    </BirdSpeciesContainer>
  );
};

// TODO 4-6-2022: Fill out propTypes
BirdSpeciesSmall.propTypes = {
  scientific_name: PropTypes.string,
  common_names: PropTypes.arrayOf(PropTypes.string),
  primary_reference_image_id: PropTypes.string,
  seasons: PropTypes.arrayOf(PropTypes.string),
  origin: PropTypes.arrayOf(PropTypes.number),
  // Only show 'Native' tag if user specifically is looking for natives.
  showNativeTag: PropTypes.bool
};

export { BirdSpeciesSmall };
