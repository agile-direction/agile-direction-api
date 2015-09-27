<h1>
  <img height="40" alt="keep-delivering" src="https://cloud.githubusercontent.com/assets/96204/10121548/71f8f330-64b7-11e5-8586-f700fb2d3938.png" />
  Keep Delivering
</h1>

[![Join the chat at https://gitter.im/keep-delivering/com](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/keep-delivering/com?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<a href="https://travis-ci.org/keep-delivering/com/builds" target="_blank">
  <img title="Build Status Images" src="https://travis-ci.org/keep-delivering/com.svg">
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
BROWSER=true bin/cucumber # run cucumbers in browser
```

## Ways to Run the App

```
bin/spring rails server # live reloads, port 3000
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
