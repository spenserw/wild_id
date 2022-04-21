import  React, { useState, useEffect } from "react";
import styled from "styled-components";
import { Form, Tag, Select, Divider, Collapse, Space } from "antd";

const { Option } = Select;
const { Panel } = Collapse;

import { BirdSpeciesSmall } from "./BirdSpecies";

import { get_bird_families, get_species_by_location } from "../api";
import fips_codes from "../fips.json";

// TODO 3-31-2022: We need to refactor this into a proper landing page for Birds, which would act as a path to searching.
// For example, we could have a featured bird, or a random species. Something to draw people in, with range map and whatnot.

const BirdSearchContainer = styled.div`
`;

const BirdSearchTitle = styled.h2`
  margin-bottom: 2px;
`;

const BirdSearchFormContainer = styled.div`
  margin: 20px;
  padding: 20px;
  background-color: rgb(245, 245, 245, 0.9);
  border: 2px solid LightGray;
  border-radius: 7px;
`;

const BirdSearchLocationContainer = styled.span`
  white-space: nowrap;
`;

const BirdResultsContainer = styled.div`
  margin: 40px;  
`;

const BirdSpeciesContainer = styled.div`
  display: flex;
  flex-flow: row wrap;
  justify-content: space-between;
`;

const submit_query = async (family, state_fips, county_fips, seasons) => {
  return await get_species_by_location(family, state_fips, county_fips, seasons);
};

const Birds = () => {

  const [families, setFamilies] = useState([]);
  useEffect(() => {
	const fetchFamilyList = async () => {
	  const data = await get_bird_families();
	  setFamilies(data);
	};

	fetchFamilyList().catch(console.error);
  }, []);

  const familyListOptions = () => {
	return families.map(_=>(<Option key={_.scientific_name}>{_.scientific_name}</Option>));
  }
  const [selectedFamily, setSelectedFamily] = useState(undefined);

  const [seasons, setSeasons] = useState([]),
		seasonToColor = {
		  "resident": "#8302fc",
		  "breeding": "#fc5902",
		  "nonbreeding": "#02b1fc",
		  "passage": "#fcd202"
		},
		seasonOptions = [
		  {label: "Resident", value: "resident"},
		  {label: "Breeding", value: "breeding"},
		  {label: "Nonbreeding", value: "nonbreeding"},
		  {label: "Passage", value: "passage"}
		],
		renderSeasonTag = (props) => {
		  const { label, value, onClose } = props;
		  return (<Tag color={seasonToColor[value]} closable={true} onClose={onClose}>{label}</Tag>);
		};

  const [stateFips, setStateFips] = useState(0);
  const [countyFips, setCountyFips] = useState(0);

  const stateSelectOptions = Object.keys(fips_codes).map(code=>{
	if(!fips_codes[code].name) return null;

	const isDisabled = (fips_codes[code].abbrev == "PR" ||
						fips_codes[code].abbrev == "AS" ||
						fips_codes[code].abbrev == "VI")
		  ? {disabled: true} : {disabled: false};
	return (<Option key={code} value={code} { ...isDisabled } >{fips_codes[code].name}</Option>);
  }).filter(_=>_!=null);

  let isCountySelectDisabled = stateFips == 0 ? {disabled: true} : {disabled: false};
  const countySelectOptions = () => {
	if(stateFips == 0) {
	  return ""; 
	}

	// TODO 4-4-2022: We have to do this nonsense because organizing the fips_codes file
	// by fips code as opposed to state abbreviation causes the Select to sort incorrectly,
	// showing 01-09 at the bottom. We could theoretically store the state abbreviation in
	// `stateFips`, however this would be a surprise for anyone editing the file. Alternatively,
	// we could  just store `stateAbbrev` in a React hook, but that feels dirty. Kicking the can.
	const stateObj = Object.entries(fips_codes).map(([abbrev, obj]) => {
	  if(obj.code == stateFips)
		return obj;
	  else
		return null;
	}).filter(_=>_ != null).at(0);
	return Object.entries(stateObj).map(([name, code]) => {
	  if(name == "abbrev" || name == "name" || name == "code") return null;
	  
	  return (<Option key={code} value={code}>{name}</Option>);
	}).filter(_=>_!=null);
  };

  const [speciesResults, setSpeciesResults] = useState({});
  useEffect(async () => {
	const fetchSpeciesResults = async () => {
	  const species = await submit_query(selectedFamily, stateFips, countyFips, seasons);
	  setSpeciesResults(species);
	};

	fetchSpeciesResults()
	  .catch(console.error);
  }, [selectedFamily, stateFips, countyFips, seasons]);

  const renderResults = () => {
	if(speciesResults == undefined || Object.keys(speciesResults) == 0) {
	  return (<h2>No results. Try a new search.</h2>);
	} else {
	  let i = 0;
	  const familiesRender = Object.keys(speciesResults).map(familyName => {
		i++;
		const speciesRender = Object.values(speciesResults[familyName].species).map(species=> {
		  return (<BirdSpeciesSmall {...species} key={species.id} />);
		});

		const panelHeader = `${speciesResults[familyName].common_names[0]} (${familyName})`;
		return (
		  <Panel header={panelHeader} key={i} style={{flex:1, fontSize: "16px"}}>
			<BirdSpeciesContainer>
			  {speciesRender}
			</BirdSpeciesContainer>
		  </Panel>
		)
	  });

	  // Make all panels open by default
	  const defaultActiveKeys = Array.from(Array(Object.keys(speciesResults).length).keys()).map(_=>_+1)
	  return (
		<Collapse defaultActiveKey={defaultActiveKeys}>
		  {familiesRender}
		</Collapse>
	  );
	}
  };

  const selectStateFips = (abbrev) => {
	const fips = fips_codes[abbrev].code;
	setStateFips(fips);
	setCountyFips(0);
  };

  const clearStateFips = () => {
	setStateFips(0);
	setCountyFips(0);
  };

  const selectCountyFips = (code) => {
	setCountyFips(code);
  };
  const clearCountyFips = () => {
	setCountyFips(0);
  };

  return (
	<BirdSearchContainer>
	  <BirdSearchFormContainer>
		<BirdSearchTitle>
		  Species search:
		</BirdSearchTitle>
		<p>Any field may be left blank.</p>
		<Form size="small">
		  <Space>
			<Form.Item label="Family">
			  <Select style={{width: "170px"}} onSelect={_=>setSelectedFamily(_)} onClear={()=>setSelectedFamily(undefined)} allowClear>
				{familyListOptions()}
			  </Select>
			</Form.Item>
		  </Space>
		  <br />
		  <Space size="middle">
			<Form.Item label="State" name="state">
			  <Select style={{width: "170px"}} onClear={clearStateFips} onSelect={selectStateFips} allowClear>
				{stateSelectOptions}
			  </Select>
			</Form.Item>
			<Form.Item label="County">
			  <Select style={{width: "170px"}} onSelect={selectCountyFips} onClear={clearCountyFips} {...isCountySelectDisabled} allowClear>
				{countySelectOptions()}
			  </Select>
			</Form.Item>
		  </Space>
		  <br />
	      <Space>
			<Form.Item label="Seasonal presence">
			  <Select mode="multiple" tagRender={renderSeasonTag} style={{width: "380px"}} onChange={setSeasons} options={seasonOptions} />
			</Form.Item>
		  </Space>
		</Form>
	  </BirdSearchFormContainer>
	  <BirdResultsContainer>
		<Divider style={{color: "#1890ff"}} orientation="left">Species</Divider>
		{renderResults()}
	  </BirdResultsContainer>
	</BirdSearchContainer>
  );
};

export default Birds;
