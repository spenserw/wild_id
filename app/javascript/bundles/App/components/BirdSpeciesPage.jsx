import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { useLocation } from 'react-router-dom';
import { Space } from 'antd';

import 'react-gallery-carousel/dist/index.css';
import Carousel from 'react-gallery-carousel';

import { ComposableMap, ZoomableGroup, Geographies, Geography } from 'react-simple-maps';
import { get_distribution_for_species, get_bird_species_info, get_reference_image_src } from '../api';

const countiesGeo = require('geographies/counties-10m.json');

const BirdSpeciesPageContainer = styled.div`
  position: relative;
  height: 1020px;
`;

const BirdSpeciesPageInfoConatiner = styled.div`
  padding-top: 64px;
  padding-left: 48px;
`;

const BirdSpeciesPageInfoName = styled.h1`
`;

const BirdSpeciesPageInfoDescription = styled.p`
  width: 480px;
`;

const BirdSpeciesGalleryContainer = styled.div`
  float: right;
  width: 640px;
  height: 480px;
  margin: 40px;
`;

const BirdSpeciesPageMapContainer = styled.div`
  position: absolute;
  top: 580px;
  left: 48px;
  background-color: rgba(0, 0, 0, 0.1);
  width: 540px;
  height: 400px;
`;

const BirdSpeciesPage = () => {

  const [_, encodedSpeciesName] = useLocation().pathname.match(/([^/]+)$/);
  const speciesName = decodeURI(encodedSpeciesName);
  
  const [speciesInfo, setSpeciesInfo] = useState({});
  useEffect(() => {
	const fetch = async () => {
	  const data = await get_bird_species_info(speciesName);
	  const info = Object.values(data)[0].species[speciesName];
	  setSpeciesInfo(info);
	}

	fetch().catch(console.error);
  }, [null]);
  
  const [distribution, setDistribution] = useState({});
  useEffect(() => {
	const fetch = async () => {
	  const data = await get_distribution_for_species(speciesName);
	  setDistribution(data);
	}

	fetch()
	  .catch(console.error);
  }, [null]);
  
  const seasonToColor = {
	'resident': '#8302fc',
	'breeding': '#fc5902',
	'nonbreeding': '#02b1fc',
	'passage': '#fcd202'
  };

  const colorForCounty = (fipsCode) => {
	// Haven't loaded distribution data...
	if(Object.keys(distribution).length == 0) {
	  return '#fff';
	}

	const [_, stateCode, countyCode] = fipsCode.match(/(\d\d)(\d\d\d)/);

	const seasonalPresence = Object.keys(seasonToColor)
		  .map(season=>distribution[season]
			   && Object.keys(distribution[season]).includes(stateCode)
			   && distribution[season][stateCode].includes(countyCode)
			   ? season : null)
		  .filter(_=>_!=null);

	if(!seasonalPresence || seasonalPresence.length == 0) {
	  return 'Gray';
	} else if(seasonalPresence.length == 1) {
	  return seasonToColor[seasonalPresence];
	} else if(seasonalPresence.length > 1) {
	  return `url(#${seasonalPresence.join('-')})`;
	}
  };

  // Transform for map to be centered on US while showing a sliver of Alaska so the user knows it's there.
  const mapCenter = [-98, 40];
  const renderGeography = geo => {
	const color = colorForCounty(geo.id);
	const stroke = color.includes('url') ? seasonToColor[color.match(/url\(#\S+-(\S)/)[1]] : color;
	return (<Geography  key={geo.rsmKey} geography={geo} fill={color} strokeWidth='0.4' stroke={stroke} />)
  };

  const generatePatternSvgElement = (id, color1, color2, color3=null) => {
	return (
	  <pattern id={id} patternUnits="userSpaceOnUse" width="2" height="2" key={id}>
   		<rect fill={color1} width='2' height='2'/>
   		<g fillOpacity='1'>
   		  <polygon  fill={color2} points='2 1 1 0 0 0 2 2'/>
   		  <polygon  fill={color3 ? color3 : color2} points='0 1 0 2 1 2'/>
   		</g>
   	  </pattern>
   	);
  };

  // Create dashed line patterns where seasonal distributions collide.
  const mixedPresencePatterns = () => {
	const patterns = [];
	for(let i = 0; i < Object.keys(seasonToColor).length; i++) {
	  for(let j = i + 1; j < Object.keys(seasonToColor).length; j++) {
		const firstKey = Object.keys(seasonToColor)[i];
		const secondKey = Object.keys(seasonToColor)[j];
		patterns.push(generatePatternSvgElement(`${firstKey}-${secondKey}`, seasonToColor[firstKey], seasonToColor[secondKey]));

		// Collision of 3 zones can really happen!! See `Buteo regalis`! I wonder if all four could?
		for(let k = j + 1; k < Object.keys(seasonToColor).length; k++) {
		  const thirdKey = Object.keys(seasonToColor)[k];
		  patterns.push(generatePatternSvgElement(`${firstKey}-${secondKey}-${thirdKey}`, seasonToColor[firstKey], seasonToColor[secondKey], seasonToColor[thirdKey]));
		}
	  }
	}

	return patterns;
  };

  const renderGalleryImages = () => {
	return speciesInfo.gallery_reference_image_ids.map(uuid=>{
	  const srcPath = get_reference_image_src(uuid);
	  return { src: srcPath };
	});
  }

  // Don't render until species info is loaded
  if(Object.keys(speciesInfo).length == 0)
	return (<div />);
  
  return (
	<BirdSpeciesPageContainer>

	  <BirdSpeciesGalleryContainer>
		<Carousel images={renderGalleryImages()} hasDotButtons='bottom' hasMediaButton={false} hasThumbnails={false} hasIndexBoard={false}/>
      </BirdSpeciesGalleryContainer>

	  <BirdSpeciesPageInfoConatiner>
		<BirdSpeciesPageInfoName>
		  <Space>
			{speciesInfo.common_names[0]}
			(<i>{speciesInfo.scientific_name}</i>)
	      </Space>
		</BirdSpeciesPageInfoName>
		<BirdSpeciesPageInfoDescription>
		  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
		</BirdSpeciesPageInfoDescription>
	  </BirdSpeciesPageInfoConatiner>

	  <BirdSpeciesPageMapContainer>
		<ComposableMap projection='geoMercator' projectionConfig={{center: mapCenter}}>
		  {mixedPresencePatterns()}
		  <ZoomableGroup zoom={3.8} center={mapCenter}>
			<Geographies geography={countiesGeo}>
			  {({geographies }) => geographies.map(renderGeography)}
			</Geographies>
		  </ZoomableGroup>
		</ComposableMap>
	  </BirdSpeciesPageMapContainer>
	</BirdSpeciesPageContainer>
  );
}

// TODO 4-7-2022: Fill out  propTypes
BirdSpeciesPage.propTypes = {
};

export default BirdSpeciesPage;
