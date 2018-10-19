# :hospital: PIUBS :hospital:

[![CodeFactor](https://www.codefactor.io/repository/github/rafaeelaudibert/piubs/badge/master)](https://www.codefactor.io/repository/github/rafaeelaudibert/piubs/overview/master)

This repository is meant to create the platform to handle the Controversy Solution problem, in a cooperation project between UFRGS (Rio Grande do Sul's Federal University) and the Brazilian Health Ministery

### :floppy_disk: Prerequisites
To have this running your local machine, you only must have a Ruby version >= 2.3.1. Everything else is covered by Docker, which are used to keep your envinroment safe.

* Ruby >= 2.3.1
* Rails >= 5.2.1
* PGAdmin III *(optional, awesome to see inside container database)*

Learn more about [Installing rbenv](https://github.com/rbenv/rbenv), which is pretty useful to manage your ruby versions.  
Learn more about [Installing Rails](https://rubyonrails.org/), which is pretty useful to have in your machine to improve debugging.

### :zap: Getting Started
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

## :whale: Deployment
[Docker](https://www.docker.com/) and [Docker-compose](https://docs.docker.com/compose/) are used to run this app.

***REMEMBER TO SET CONFIG/.ENV ENVIRONMENT VARIABLES TO REFLECT WHAT YOU WANT TO DO, ESPECIALLY ABOUT DEVELOPMENT/TEST/PRODUCTION ENVIRONMENT***

To build the images of PIUBS app you should run the following (only needed in the first time you are doing it):

```bash
$ docker-compose build
```

The next times, you just need to run the following. If you want to daemonize it, just append the `-d` flag
```bash
$ docker-compose up
```

In the first time you are running it, you need to configure the database. Be sure your containers are up, and run:
```bash
$ docker-compose exec app rake db:setup
```

It's done! You are ready to find your app running at `localhost:8081` with a database port open in `localhost:5433`

If you want to enter in a container you can run `docker-compose ps` and see what is the name of your container according to `piubs_<name_of_container>_1`. After you only need to run the following, to enter in a bash inside the container, so you are able to run whatever you want:
```bash
$ docker-compose exec <name_of_container> /bin/bash
```


## :capital_abcd: Running the tests
[WIP] Work in Progress. No tests yet, but [RSpec](https://github.com/rspec/rspec-rails) will be used.



## :train: Built With
* [RailsComposer](https://github.com/RailsApps/rails-composer) - Application generation tool
* [Bootstrap](https://getbootstrap.com/) - Web Framework
* [Ruby on Rails](https://rubyonrails.org/) - Ruby Framework for web
* [postgreSQL](https://www.postgresql.org/) - SQL Database
* [Redis](https://redis.io/) - NoSQL Database
* :heart: @ [INF](www.inf.ufrgs.br) - UFRGS / Porto Alegre - Brazil

## :muscle: Contributing
Please follow the [issue guides](https://github.com/rafaeelaudibert/PIUBS/issues/new/choose) to open any issue.
Feel free to open any pull request, or contact the team here in Github.
We use [Gitmoji](https://gitmoji.carloscuesta.me/) :tada: in our commits, so please follow the guidelines of it.

## :1234: Versioning
We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## :construction_worker: Authors
* **Felipe Comerlato** - *Initial work* - [felipefcomerlato](https://github.com/felipefcomerlato)
* **Mario Figueiró** - *Initial work* - [mgfzemor](https://github.com/mgfzemor)
* **Rafael Baldasso Audibert** - *Initial work* - [rafaeelaudibert](https://github.com/rafaeelaudibert)

## :globe_with_meridians: Website
The live version of this project is available at https://piubs.inf.ufrgs.br

## :page_facing_up: License
This project is licensed under the GNU AGPL 3.0 License - see the [LICENSE.md](LICENSE) file for details
