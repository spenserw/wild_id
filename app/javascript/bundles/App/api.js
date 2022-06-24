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
/* Example 'Falconidae'
  {
   "common_names" : [
      "Falcons, caracaras"
   ],
   "created_at" : "2022-04-29T15:18:21.817Z",
   "id" : 49,
   "scientific_name" : "Falconidae",
   "species_count" : 7,
   "updated_at" : "2022-04-29T15:18:21.817Z"
   }
*/
async function get_bird_family_info(families) {
  return await fetch("/api/birds/families", {families});
}

/* Example ['Falco rusticolus'] 
  {
   "Falconidae" : {
      "species" : {
         "Falco rusticolus" : {
            "bird_family_id" : 49,
            "common_names" : [
               "Gyrfalcon"
            ],
            "created_at" : "2022-04-29T15:18:26.133Z",
            "gallery_reference_image_ids" : [
               "caab78cd-5387-43d3-a7aa-36650049bec6",
               "1f401786-83a3-491f-a141-78c0904d08e3",
               "3ca2d21d-a6e3-4ea5-b644-ae625c9bd6f3",
               "8422c21f-7ba9-4016-9413-eff5a03d105a"
            ],
            "id" : 702,
            "primary_reference_image_id" : "314c7a4a-ff8f-4d23-a92b-de1281502631",
            "scientific_name" : "Falco rusticolus",
            "updated_at" : "2022-04-29T15:21:47.119Z"
         }
      }
   }
}
*/
async function get_bird_species_info(species_list) {
  return await fetch(`/api/birds/species`, { species: species_list });
}

async function get_species_by_location(species, family, state_fips, county_fips, seasons, origin) {
  // Perform seasonal distribution fetch
  const allDistData = await GeoAPI.fetch_species_presence({
    species,
    family,
    state: state_fips,
    county: county_fips,
    seasons,
    origin
  });

  if(_.isEmpty(allDistData))
    return {};

  const familiesInfo = await get_bird_family_info(Object.keys(allDistData));
  const distData = _.pickBy(allDistData, (v, k)=>_.has(familiesInfo, k));
  const resp = familiesInfo;

  const speciesNames = _.flatten(_.map(distData, (v)=>_.keys(v.species)));
  const speciesInfo = await get_bird_species_info(speciesNames);
  
  // Associate distribution data with curated species
  for (let familyName of _.keys(distData)) {
    // We don't have curation for any of these species
    if(!_.has(speciesInfo, familyName)) {
      delete resp[familyName];
      continue;
    }

    const species = speciesInfo[familyName].species;
    // Filter species we don't have curation data for
    resp[familyName].species = _.map(
      _.pickBy(distData[familyName].species, (dist, sciName) => _.has(species, sciName)),
      (dist, sciName) => _.merge(dist, species[sciName])
    );
  }

  return resp;
}

async function get_distribution_for_species(scientific_name) {
  return await GeoAPI.fetch_given_species_distribution(scientific_name);
}

// DEV: This shouldn't be in the API module probably...
function get_reference_image_src(image_uuid, size) {
  return `${config.reference_images.endpoint}/wild-id-reference-images/birds/${image_uuid}-${size}.jpg`;
}

export {
  get_bird_families,
  get_bird_family_info,
  get_bird_species_info,
  get_species_by_location,
  get_reference_image_src,
  get_distribution_for_species
};
