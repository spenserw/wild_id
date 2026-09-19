# Wild ID

Wildlife identification and species exploration app. Discover birds, plants, and more in your surroundings.

## Development Environment

- Ruby 4.0.5
- Rails 8.1.3
- PostgreSQL 16 w/ PostGIS extension
- Solid Queue for background jobs

### Setup

```bash
bin/dev
```

This starts PostgreSQL via Docker Compose, prepares the database, and launches the Rails server with Overmind (or Foreman).

### Docker

The `compose.yml` provides a PostgreSQL database. Credentials default to `wild_id`/`wild_id`.

## App Structure

```
app/
├── controllers/
│   ├── landing_controller.rb    # Root page
│   └── birds_controller.rb      # Birds index
├── jobs/
│   └── plants/scrape_symbol_job.rb  # USDA plant scraping
└── models/
    ├── taxonomic_class.rb       # Base class (e.g. Aves)
    ├── order.rb, family.rb, genus.rb, species.rb  # Base taxonomy
    ├── concerns/
    │   └── taxonomic_rank.rb    # Shared taxonomy behavior
    ├── bird/
    │   ├── order.rb, family.rb, genus.rb, species.rb  # Bird taxonomy (STI)
    │   └── birdlife/
    │       ├── taxon.rb         # BirdLife checklist data
    │       └── distribution.rb  # Species range polygons
    ├── plant/
    │   └── order.rb, family.rb, genus.rb, species.rb  # Plant taxonomy (STI)
    └── fungi/
        └── order.rb, family.rb, genus.rb, species.rb  # Fungi taxonomy (STI)
```

## Datasets

| Dataset | Rake Tasks | Description |
|---------|------------|-------------|
| **Census** | `census:extract` | Downloads US county boundaries and creates `us_boundary` table with union geometries |
| **BirdLife** | `birdlife:import` | Full pipeline: cleanup, extract BOTW archive, build US taxa, load families/species |
| | `birdlife:cleanup` | Destroys all Bird::Species and Bird::Family records |
| | `birdlife:artifacts:extract` | Extracts BOTW.7z, loads taxonomy/distributions into PostGIS |
| | `birdlife:artifacts:us_taxa` | Builds `data/birdlife/us_taxa.json` from US distributions |
| | `birdlife:import_us_bird_orders` | Imports US bird orders from us_taxa artifact |
| | `birdlife:import_us_bird_families` | Imports US bird families from us_taxa artifact |
| | `birdlife:import_us_bird_genera` | Imports US bird genera from us_taxa artifact |
| | `birdlife:import_us_bird_species` | Imports US bird species from us_taxa artifact |
| **Plants** | `plants:import` | Full pipeline: cleanup, and load classes/orders/families/genera/species |
| | `plants:cleanup` | Destroys all Plant::Species and Plant::Family records |
| | `plants:artifacts:us_taxa` | Builds `data/plants/us_plants_taxa.json` from scraped plant profiles |
| | `plants:pull_complete_list` | Downloads full USDA plants list |
| | `plants:pull_state_list[State]` | Downloads state-specific plants list |
| | `plants:schedule_full_scrape` | Enqueues jobs to scrape all plants from USDA plants |
| | `plants:schedule_state_scrape[State]` | Enqueues jobs to perform a state specific scrape |
| | `plants:import_us_plant_classes` | Imports US plant classes from us_taxa artifact |
| | `plants:import_us_plant_orders` | Imports US plant orders from us_taxa artifact |
| | `plants:import_us_plant_families` | Imports US plant families from us_taxa artifact |
| | `plants:import_us_plant_genera` | Imports US plant genera from us_taxa artifact |
| | `plants:import_us_plant_species` | Imports US plant species from us_taxa artifact |
