import React, { useState, useEffect } from "react";
import { useSearchParams } from "react-router-dom";
import styled from "styled-components";
import { Form, Tag, Tooltip, Input, Select, Button, Divider, Collapse, Space } from "antd";
import _ from "lodash";

const { Option } = Select;
const { Panel } = Collapse;

import { BirdSpeciesSmall } from "./BirdSpecies";

import { get_bird_families, get_species_by_location } from "../api";
import fips_codes from "../fips.json";

// TODO 3-31-2022: We need to refactor this into a proper landing page for Birds, which would act as a path to searching.
// For example, we could have a featured bird, or a random species. Something to draw people in, with range map and whatnot.

const BirdSearchContainer = styled.div``;

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

const BirdResultsContainer = styled.div`
  margin: 40px;
`;

const BirdSpeciesContainer = styled.div`
  display: flex;
  flex-flow: row wrap;
  justify-content: flex-start;
`;

const submit_query = async (family, state_fips, county_fips, seasons, origin) => {
  return await get_species_by_location(
    family,
    state_fips,
    county_fips,
    seasons,
    origin
  );
};

const Birds = () => {
  const [searchParams, setSearchParams] = useSearchParams();

  const [familyData, setFamilyData] = useState([]);
  useEffect(() => {
    const fetchFamilyList = async () => {
      const data = await get_bird_families();
      setFamilyData(data);
    };

    fetchFamilyList().catch(console.error);
  }, []);

  const familyOptions = () => {
    return _.values(familyData).map((_) => (
      <Option key={_.scientific_name}>{_.common_names[0]} ({_.scientific_name})</Option>
    ));
  };

  const [selectedFamily, setSelectedFamily] = useState(searchParams.get("family"));
  const onSelectFamily = (family) => {
    setSelectedFamily(family);
    setQuery({family});
  };

  const [speciesSearch, setSpeciesSearch] = useState(searchParams.get("species"));
  const onChangeSpeciesSearch = (event) => {
    const search = event.target.value;
    setSpeciesSearch(search);
    setQuery({ species: search });
  };

  const [selectedSeasons, setSelectedSeasons] = useState(searchParams.getAll("seasons[]") || []),
    seasonToColor = {
      resident: "#8302fc",
      breeding: "#fc5902",
      nonbreeding: "#02b1fc",
      passage: "#fcd202",
    },
    seasonOptions = [
      { label: "Resident", value: "resident" },
      { label: "Breeding", value: "breeding" },
      { label: "Nonbreeding", value: "nonbreeding" },
      { label: "Passage", value: "passage" },
    ],
    renderSeasonTag = (tagProps) => {
      const { label, value, onClose } = tagProps;
      return (
        <Tag color={seasonToColor[value]} closable={true} onClose={onClose}>
          {label}
        </Tag>
      );
    };

  const onChangeSeasons = (seasons) => {
    setSelectedSeasons(seasons);
    setQuery({"seasons[]": seasons});
  };

  const [selectedOrigin, setSelectedOrigin] = useState(searchParams.get("origin")),
        originOptions = [
          { label: "Native", value: "1" },
          { label: "Introduced", value: "3" }
        ];

  const onChangeOrigin = (origin) => {
    setSelectedOrigin(origin);
    setQuery({origin});
  };


  const [stateFips, setStateFips] = useState(searchParams.get("state") || "0");
  const [countyFips, setCountyFips] = useState(searchParams.get("county") || "0");

  const stateSelectOptions = Object.keys(fips_codes)
    .map((code) => {
      if (!fips_codes[code].name) return null;

      const isDisabled =
        fips_codes[code].abbrev == "PR" ||
        fips_codes[code].abbrev == "AS" ||
        fips_codes[code].abbrev == "VI"
          ? { disabled: true }
          : { disabled: false };
      return (
        <Option key={code} value={code} {...isDisabled}>
          {fips_codes[code].name}
        </Option>
      );
    }).filter((_) => _ != null);

  const stateNameFromCode = (code) => {
    if(code == "0") return undefined;
    return Object.values(fips_codes).find(s=>s.code == code).abbrev;
  };


  let isCountySelectDisabled =
    stateFips == 0 ? { disabled: true } : { disabled: false };
  const countySelectOptions = () => {
    if (stateFips == 0) {
      return "";
    }

    // TODO 4-4-2022: We have to do this nonsense because organizing the fips_codes file
    // by fips code as opposed to state abbreviation causes the Select to sort incorrectly,
    // showing 01-09 at the bottom. We could theoretically store the state abbreviation in
    // `stateFips`, however this would be a surprise for anyone editing the file. Alternatively,
    // we could  just store `stateAbbrev` in a React hook, but that feels dirty. Kicking the can.
    const stateObj = Object.values(fips_codes)
      .map((obj) => {
        if (obj.code == stateFips) return obj;
        else return null;
      })
      .filter((_) => _ != null)
      .at(0);
    return Object.entries(stateObj)
      .map(([name, code]) => {
        if (name == "abbrev" || name == "name" || name == "code") return null;

        return (
          <Option key={code} value={code}>
            {name}
          </Option>
        );
      })
      .filter((_) => _ != null);
  };

  const onSelectStateFips = (abbrev) => {
    const fips = fips_codes[abbrev].code;
    setStateFips(fips);
    setCountyFips(0);
    setQuery({state: fips});
  };

  const onClearStateFips = () => {
    setStateFips(0);
    setCountyFips(0);
    setQuery({state: undefined, county: undefined});
  };

  const onSelectCountyFips = (code) => {
    setCountyFips(code);
    setQuery({county: code});
  };
  const onClearCountyFips = () => {
    setCountyFips(0);
    setQuery({county: undefined});
  };

  const [speciesResults, setSpeciesResults] = useState({});
  const submitSearch = async () => {
    if(_.isEmpty(speciesSearch) && stateFips == "0") {
      setSpeciesResults({});
      return;
    }

    const species = await submit_query(
      speciesSearch,
      selectedFamily,
      stateFips,
      countyFips,
      selectedSeasons,
      selectedOrigin
    );

    setSpeciesResults(species);
  };

  // Run submit on page load, that way navigating to a search link will populate with results
  useEffect(() => {
    submitSearch();
  }, []);

  //   useEffect(async () => {
  //     await submitSearch();
  // }, [speciesSearch, selectedFamily, stateFips, countyFips, selectedSeasons, selectedOrigin]);

  const renderResults = () => {
    if (speciesResults == undefined || Object.keys(speciesResults) == 0) {
      return <h2>No results. Try a new search.</h2>;
    } else {
      let i = 0;
      const familiesRender = Object.keys(speciesResults).map((familyName) => {
        i++;
        const speciesRender = Object.values(
          speciesResults[familyName].species
        ).map((species) => {
          return <BirdSpeciesSmall {...species} showNativeTag={!!selectedOrigin} key={species.id} />;
        });

        const panelHeader = `${speciesResults[familyName].common_names[0]} (${familyName})`;
        return (
          <Panel
            header={panelHeader}
            key={i}
            style={{ flex: 1, fontSize: "16px" }}
          >
            <BirdSpeciesContainer>{speciesRender}</BirdSpeciesContainer>
          </Panel>
        );
      });

      // Make all panels open by default
      const defaultActiveKeys = Array.from(
        Array(Object.keys(speciesResults).length).keys()
      ).map((_) => _ + 1);
      return (
        <Collapse defaultActiveKey={defaultActiveKeys}>
          {familiesRender}
        </Collapse>
      );
    }
  };

  // DEV: Passing the new query is necessary because otherwise the query remains a step behind rerenders due to us making use of useState to update the values in `baseQuery`
  const setQuery = (newQuery) => {
    const baseQuery = {
      species: speciesSearch,
      family: selectedFamily,
      state: stateFips == "0" ? undefined : stateFips,
      county: countyFips == "0" ? undefined : countyFips,
      "seasons[]": selectedSeasons.length == 0 ? undefined : selectedSeasons,
      origin: selectedOrigin
    };

    // Build query:
    // If newQuery contains the key:
    //    - Apply it if it is valid, added/modified in query
    //    - Skip it if undefined, remove it (e.g. user cleared selection)
    // Else if baseQuery contains key, keep it
    const query =
          Object.keys(baseQuery)
          .reduce((acc, key) => {
            if(_.has(newQuery, key)) {
              if(newQuery[key])
                acc[key] = newQuery[key];
            } else if(baseQuery[key]) {
              acc[key] = baseQuery[key];
            }

            return acc;
          }, {});

    setSearchParams(query);
  };

  return (
    <BirdSearchContainer>
      <BirdSearchFormContainer>
        <BirdSearchTitle>Species search:</BirdSearchTitle>
        <p>At least one required field must be provided. Required fields are marked with an asterisk(*).</p>
        <Form size="small">
          <Space>
            <Tooltip title="Species name can include all or part of a species binomial. (e.g. 'Buteo' will match all species in the genus)">
              <Form.Item label="Species*">
                <Input
                  defaultValue={speciesSearch}
                  style={{ width: "200px" }}
                  onChange={onChangeSpeciesSearch}
                />
              </Form.Item> 
            </Tooltip>
            <Form.Item label="Family">
              <Select
                defaultValue={selectedFamily}
                style={{ width: "200px" }}
                onSelect={onSelectFamily}
                onClear={() => onSelectFamily(undefined)}
                allowClear
              >
                {familyOptions()}
              </Select>
            </Form.Item>
          </Space>
          <br />
          <Space size="middle">
            <Form.Item label="State*" name="state">
              <Select
                defaultValue={stateNameFromCode(stateFips)}
                style={{ width: "170px" }}
                onClear={onClearStateFips}
                onSelect={onSelectStateFips}
                allowClear
              >
                {stateSelectOptions}
              </Select>
            </Form.Item>
            <Form.Item label="County">
              <Select
                defaultValue={countyFips == "0" ? undefined : countyFips}
                value={countyFips == "0" ? "" : countyFips}
                style={{ width: "170px" }}
                onSelect={onSelectCountyFips}
                onClear={onClearCountyFips}
                {...isCountySelectDisabled}
                allowClear
              >
                {countySelectOptions()}
              </Select>
            </Form.Item>
          </Space>
          <br />
          <Space>
            <Form.Item label="Seasonal presence">
              <Select
                defaultValue={selectedSeasons}
                mode="multiple"
                tagRender={renderSeasonTag}
                style={{ width: "380px" }}
                onChange={onChangeSeasons}
                options={seasonOptions}
              />
            </Form.Item>
          </Space>
          <br />
          <Space>
            <Form.Item label="Origin">
              <Select
                defaultValue={selectedOrigin}
                style={{ width: "170px" }}
                onChange={onChangeOrigin}
                options={originOptions}
                allowClear
              />
            </Form.Item>
          </Space>
          <br />
          <Space>
            <Form.Item>
              <Button type="primary" htmlType="submit" onClick={submitSearch}>
                Submit
              </Button>
            </Form.Item>
          </Space>
        </Form>
      </BirdSearchFormContainer>
      <BirdResultsContainer>
        <Divider style={{ color: "#1890ff" }} orientation="left">
          Species
        </Divider>
        {renderResults()}
      </BirdResultsContainer>
    </BirdSearchContainer>
  );
};

export default Birds;
