# InfigoniaAssessment

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

# Application Details

  * We have 3 controllers to mock external apis sending csv files
  * csv_fetcher folder is used to make api requests, get csv data and then write them to a file inside priv/csv_files
  * exchange_rates folder is responsible to fetech exchange rates daily at 12 pm and update them in db
  * revenue folder is responsible to read the stored csv files in priv/csv_files, modify the revenue with reveve * rate and the store in db

  * We are using Swarm library to distibute processes across all the nodes on the cluster 
  * We are using Redix to managing distributed locking of database table
  * We are using Quantum to shedule cron jobs 




