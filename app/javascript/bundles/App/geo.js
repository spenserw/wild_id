import axios from 'axios';

const config = require('config');

async function remote_fetch(path, params) {
  try {
	const resp = await axios.get(`${config.wid_geo.endpoint}${path}`, {params});
	return resp.data;
  } catch(error) {
	console.error(error);
  }
}

async function fetch_species_presence(family, state_fips, county_fips, seasons) {
  return await remote_fetch('/birds/presence', { state: state_fips, county: county_fips, seasons, family });
}

async function fetch_given_species_distribution(scientific_name) {
  return await remote_fetch(`/birds/${encodeURI(scientific_name)}/distribution`);
}

const GeoAPI = {
  fetch_species_presence,
  fetch_given_species_distribution
};

export default GeoAPI;
