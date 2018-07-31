# :hospital: PIUBS :hospital:

This repository is meant to create the platform to handle the Controversy Solution problem, in a cooperation project between UFRGS (Rio Grande do Sul's Federal University) and the Brazilian Health Ministery

<br />
### :floppy_disk: Prerequisites
---
To have this running your local machine, you must have the following applications in your computer

* Ruby >= 2.3.1
* Rails 5.2.0
* PostreSQL 9.6.*

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).  

<br />
### :zap: Getting Started
---
- Install application requirements listed above
- clone project

```bash
$ git clone https://github.com/rafaeelaudibert/PIUBS.git
```

- Install gems

```bash
$ cd PIUBS
$ bundle install
```

- Configure you database in `/config/database.yml`

- Create DB tables

```bash
$ rake db:create db:migrate
```

- Restore the DB `PIUBS` from `db/piubs_dev_backup.backup` using `psql` or the [PgAdminIII](https://www.pgadmin.org/download/) GUI.

- Start your local server

```bash
$ rails server -p <your_port>
```

- Drink a cup of tea and enjoy it ;)

- The next time, you just need to run `rails server -p <your_port>`


<br />
## :capital_abcd: Running the tests
---
[WIP] Work in Progress. No tests yet, but [RSpec](https://github.com/rspec/rspec-rails) will be used.


<br />
## :whale: Deployment
---
[WIP] Work in Progress. No Deployment yet, but [Docker](https://www.docker.com/) will be used.

<br />
## :train: Built With
---
* [RailsComposer](https://github.com/RailsApps/rails-composer) - Application generation tool
* [Bootstrap](https://getbootstrap.com/) - Web Framework
* [postgreSQL](https://www.postgresql.org/) - Database
* [Ruby on Rails](https://rubyonrails.org/) - Web server host

<br />
## :muscle: Contributing
---
Please follow the [issue guides](https://github.com/rafaeelaudibert/PIUBS/issues/new/choose) to open any issue.
Feel free to open any pull request, or contact the team here in Github.

<br />
## :1234: Versioning
---
We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

<br />
## :construction_worker: Authors
---
* **Felipe Comerlatto** - *Initial work* - [felipefcomerlatto](https://github.com/felipefcomerlato)
* **Mario Figueiró** - *Initial work* - [mgfzemor](https://github.com/mgfzemor)
* **Rafael Baldasso Audibert** - *Initial work* - [rafaeelaudibert](https://github.com/rafaeelaudibert)

<br />
## :page_facing_up: License
---
This project is licensed under the GNU AGPL 3.0 License - see the [LICENSE.md](LICENSE.md) file for details
