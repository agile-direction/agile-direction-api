# Keep Delivering

[![Join the chat at https://gitter.im/keep-delivering/com](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/keep-delivering/com?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<a href="https://travis-ci.org/agile-direction/agile-direction-api/builds" target="_blank">
  <img title="Build Status Images" src="https://travis-ci.org/agile-direction/agile-direction-api.svg">
</a>

## Dependencies

```
brew install chromedriver postgresql
```

## Setup

```
bin/rake db:create db:migrate db:seed
RACK_ENV=test bin/rake db:create
bin/rake test
```

## Ways to Run the App

```
bin/spring rails server # live reloads, port 9393
bin/foreman start # performant, port 5000
```

## Remote

### Setup

```
open "https://toolbelt.heroku.com/" # get the Heroku toolbelt
heroku login
heroku git:remote -a keepdelivering
```

### Deploy

```
bin/deploy
```

### Migrations

```
heroku run rake db:migrate
heroku restart
```
