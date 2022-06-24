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

/* Example state = 09, county = 001, family = Falconidae
{
   "Falconidae" : {
      "species" : {
         "Falco columbarius" : {
            "seasons" : [
               "nonbreeding"
            ]
         },
         "Falco peregrinus" : {
            "seasons" : [
               "breeding",
               "nonbreeding",
               "passage"
            ]
         },
         "Falco sparverius" : {
            "seasons" : [
               "resident"
            ]
         }
      }
   }
}
*/
async function fetch_species_presence(query) {
  return await remote_fetch("/birds/presence", query);
}

async function fetch_given_species_distribution(scientific_name) {
  return await remote_fetch(`/birds/${encodeURI(scientific_name)}/distribution`);
}

const GeoAPI = {
  fetch_species_presence,
  fetch_given_species_distribution
};

export default GeoAPI;
