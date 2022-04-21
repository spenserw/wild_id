import axios from 'axios';
import _ from 'lodash';

import GeoAPI from './geo';

const config = require('config');

async function fetch(path, params) {
  try {
	const resp = await axios.get(path, {params});
	return resp.data;
  } catch (error) {
	console.error(error);
  }
}

async function get_bird_families() {
  return await fetch(`/api/birds/families`);
}

async function get_bird_family_info(scientific_name) {
  return await fetch(`/api/birds/families/${scientific_name}`);
}

async function get_bird_species_info(species_list) {
  return await fetch(`/api/birds/species`, { species: species_list });
}

async function get_species_by_location(family, state_fips, county_fips, seasons) {
  // Perform seasonal distribution fetch
  const species = await GeoAPI.fetch_species_presence(family, state_fips, county_fips, seasons);

  const resp = JSON.parse(JSON.stringify(species));

  // Associate results with curated species
  for (let [family_name, data] of Object.entries(species)) {
	const species_names = Object.keys(data.species);
	const species_info = await get_bird_species_info(species_names);
	_.merge(resp, species_info);

	const family_info = await get_bird_family_info(family_name);
	_.merge(resp[family_name], family_info);
  }

  return resp;
}

async function get_distribution_for_species(scientific_name) {
  return await GeoAPI.fetch_given_species_distribution(scientific_name);
}

// DEV: This shouldn't be in the API module probably...
function get_reference_image_src(image_uuid) {
  return `${config.reference_images.endpoint}/wild-id-reference-images/birds/${image_uuid}.jpg`;
}

export {
  get_bird_families,
  get_bird_family_info,
  get_bird_species_info,
  get_species_by_location,
  get_reference_image_src,
  get_distribution_for_species
};
