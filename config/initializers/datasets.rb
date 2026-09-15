# Dataset tables are populated by rake tasks, not migrations.
# Exclude them from schema dumps.
ActiveRecord::SchemaDumper.ignore_tables |= [
  "birdlife_distributions",
  "birdlife_taxonomy",
  "us_boundary"
]
