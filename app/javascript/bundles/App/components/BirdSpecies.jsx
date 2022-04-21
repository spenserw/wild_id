import React from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import styled from 'styled-components';
import { Card, Tag, Space } from 'antd';
import { FileImageOutlined } from '@ant-design/icons';
import _ from 'lodash';

const { Meta } = Card;

import { get_reference_image_src } from '../api';

const BirdSpeciesContainer = styled.div`
  border: 1px solid rgb(211, 211, 211, 0.6);
  border-radius: 3px;
  overflow: hidden;
  flex: 1 1 345px;
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
  background: linear-gradient(0deg, rgba(24,24,24,0.6796919451374299) 0%, rgba(24,24,24,0.36876757538953087) 60%, rgba(24,24,24,0) 100%);
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

const BirdBadgesWrapper = styled.span`
  position: absolute;
  top: 8px;
  right: 2px;
`;

const BirdSpeciesSmall = (props) => {
  const primaryReferenceImage = () => {
	// Missing image
	if(props.primary_reference_image_id ==  null || props.primary_reference_image_id == 'undefined')
	  return (
		<div style={{textAlign: 'center', position: 'relative' }}>
		  <FileImageOutlined style={{ position: 'absolute', top: '56px', left: '42%', fontSize: '64px'}} />
		</div>
	  );
	
	const primaryReferenceImageSrc = get_reference_image_src(props.primary_reference_image_id);
	return (<BirdSpeciesPrimaryReferenceImage src={primaryReferenceImageSrc} />);
  };

  const seasonalBadges = () => {
	// TODO 4-4-2022: Replace these hardcoded values with the configurable colors to be used in the range maps.
	const seasonToColor = {
	  'resident': '#8302fc',
	  'breeding': '#fc5902',
	  'nonbreeding': '#02b1fc',
	  'passage': '#fcd202'
	};
	const seasons = props.seasons;

	let badges = [];
	if(seasons.includes('resident')) {
	  badges.push((<Tag key='resident' color={seasonToColor['resident']}>Resident</Tag>));
	} else {
	  badges = seasons.map(season=>(<Tag key={season} color={seasonToColor[season]}>{_.capitalize(season)}</Tag>));
	}

	return (<BirdBadgesWrapper>{badges}</BirdBadgesWrapper>);
  };

  const birdSpeciesLinkPath = encodeURI(`/birds/${props.scientific_name}`)

  return (
	<BirdSpeciesContainer>
	  <Link to={birdSpeciesLinkPath}>
		{primaryReferenceImage()}
		<BirdSpeciesInfoContainer>
		  <BirdSpeciesInfoWrapper>
			<BirdSpeciesCommonName>{props.common_names[0]}</BirdSpeciesCommonName>
			<BirdSpeciesSciName>({props.scientific_name})</BirdSpeciesSciName>
		  </BirdSpeciesInfoWrapper>
		</BirdSpeciesInfoContainer>
		{seasonalBadges()}
	  </Link>
	</BirdSpeciesContainer>
  );
};

// TODO 4-6-2022: Fill out propTypes
BirdSpeciesSmall.propTypes = {
  primaryReferenceImageId: PropTypes.string
};

export {
  BirdSpeciesSmall
};
