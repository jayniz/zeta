# Zeta [![Circle CI](https://circleci.com/gh/moviepilot/zeta.svg?style=svg)](https://circleci.com/gh/moviepilot/zeta) [![Coverage Status](https://coveralls.io/repos/moviepilot/zeta/badge.svg?branch=master&service=github)](https://coveralls.io/github/moviepilot/zeta?branch=master) [![Code Climate](https://codeclimate.com/github/moviepilot/zeta/badges/gpa.svg)](https://codeclimate.com/github/moviepilot/zeta) [![Dependency Status](https://gemnasium.com/moviepilot/zeta.svg)](https://gemnasium.com/moviepilot/zeta) [![Gem Version](https://badge.fury.io/rb/zeta.svg)](https://badge.fury.io/rb/zeta)

![](https://dl.dropboxusercontent.com/u/1953503/zeta.jpg)


```
TLDR:
- each service defines which objects it publishes or consumes
- these contracts are formatted in human readable markdown
- you never have to check out other services' repositories

Zeta will:
- know the rest of your infrastructure and fetch the contracts of all other services
- alert you if your change breaks the expectactions of other services
```

In an infrastructure where many services are talking with each other, it's sometimes hard to know **how changes in one service affect other services**, as each service often just knows about itself. Even if local tests pass, you can't know what other services might be affected when you make changes to a service.

*Zeta* tackles this problem by allowing each service to define which objects it consumes, and which objects it publishes - in simple Markdown (specifically [MSON](https://github.com/apiaryio/mson)).It doesn't matter if these objected are transported via a HTTP, a message broker like RabbitMQ or any other mean.


## Walk this way

Let's imagine an imaginary chat app that is split up into three independent services that communicate via a message broker:

- **MessageService** keeps track off storing messages
- **SearchService** makes your chat history searchable
- **NotificationService**: sends an email when a private message is received

Each time a message is sent, MessageService publishes the full message to the message broker. While the SearchService is likely interested in the full message with all of its properties to index it probably, the NotificationService might just care about the sender and the receiver of the message, discarding all other properties.

An intern is asked to implement a feature that allows one message to be sent to multiple people at the same time. They go ahead and just change the numerical `recepient_id` property of a message to an `recipient_ids` array. They run their tests and all looks good.

😱But **THE INTERN JUST BROKE THE NOTIFICATION SERVICE** because it depends on the `recipient_id` property 😱

Wouldn't it be nice of some test local to the **MessageService** repository to tell the poor intern that removing the `recipient_id` property breaks the expectations other services have regarding the *MessageService* BEFORE the intern hits the red deploy button?


## Yes, it would!

Each service has to contain two files in order for *Zeta* to do its job:

1. `contracts/publish.mson`
2. `contracts/consume.mson`

These are simple markdown files in the wonderful [MSON](https://github.com/apiaryio/mson) format. Let's look at the contracts dir of **MessageService**, shall we?

### A publish specification:
`contracts/publish.mson`:
```shell
# Message
- id: (number, required)
- sender_id: (number, required)
- recipients: (Array[number], required)
- text: (string, required)
- emoji: (string)
```

So far so good. This way *MessageService* can tell the world what exactly it means when a `Message` object is published. Much the same, the *NotificationService* could define which properties of a `Message` object from the `MessageService` it is actually interested in:

### A consume specification:
`contracts/consume.mson`:
```shell
# MessageService::Message
- sender_id: (number, required)
- recipient_id: (number, required)
```

As you can see, this consumer expects the `recipient_id` property to be present when a `Message` object is received from `MessageService`. While a publish specification just defines objects, a consume specification prefixes the names of objects it consumes with the name of the service publishing the object. As in our example above:

```
# MessageService::Message
     |              `---------- object name
     `------------------------- service name

```

## Getting started

### 1. Installation
Even though it does not matter what programming languages your services are written in, you'll need ruby to run Zeta. To install, add *Zeta* to your `Gemfile` or install it manually:

```shell
$ gem install zeta
```

### 2. Configuration

If you're using ruby on rails, *Zeta* will automatically know your
environment and look for its configuration in `config/zeta.yml`, which could look like this:

```yaml
common: &common
  # This name will be used by other services to identify objects they consume
  # from the MessageService
  service_name: MessageService

  # Which directory contains the publish.mson and consume.mson
  contracts_path: contracts

  # Where to cache the contracts from all other services that are part of the
  # infrastructure. Zeta will fetch these for you.
  contracts_cache_path: contracts/.cache


development:
  <<: *common
  # The services file contains all services that are part of your infrastructure
  # and tested with Zeta. It's just another yaml file, but the nice thing is
  # that it's outside of the service's repository and has to be maintained only
  # in one place.
  services_file:

    # The file name to look for
    file: 'development.yml'

    # You can either host the file yourself via HTTP, but it's quite convenient
    # to have it version controlled and hosted by a service like github. We'll
    # call this repo zeta-config for this example:
    github:
      repo: jensmander/zeta-config
      branch: master
      path: infrastructure

# And here we can adjust things for each environment as needed
production:
  <<: *common
  ...

```

You typically just create the above file once in each project and then don't touch it anymore. Whenever a new service gets added to or removed from the infrastructure, you just update the central infrastructure configuration. The what? Central infrastructure configuration? Oh, look:

Here's how the infrastructure configuration file might look for our example above:

`git@github.com:jensmander/zeta-config/infrastructure/master.yml`:
```yaml
MessageService:
  github:
    repo: 'jensmander/messages'
    branch: 'master'
    path: 'contracts'
SearchService:
  github:
    repo: 'jensmander/search'
    branch: 'master'
    path: 'contracts'
NotificationService:
  github:
    repo: 'jensmander/notifications'
    branch: 'master'
    path: 'contracts'
```

Whenever you add a service to the infrastructure, you just add it to this central file and all existing services will automatically know about your new service.

### 3. Authentication

If your infrastruture configuration file is HTTP Basic auth protected, or in a private repository on github (that would be a good idea), make sure you `export HTTP_USER=username` and `HTTP_PASSWORD=secret` and *Zeta* will use that. If you host on github, then use your github username as `HTTP_USER` and generate an API token to use as the `HTTP_PASSWORD`.

### 4. Usage: Without ruby (CLI)

Zeta comes with a `zeta` command that takes care of all the things:

```
Usage: zeta [options] full_check|fetch_remote_contracts|update_own_contracts|validate

Specific options:
    -c, --config=CONFIG_FILE         Config file (default: config/zeta.yml)
    -e, --env=ENVIRONMENT            Environment (default: RAILS_ENV, if it is set)
    -s, --silent                     No output, just an appropriate return code
    -t, --trace                      Print exception stack traces

Common options:
    -h, --help                       Show this message
    -v, --version                    Show version
```

Example time. You can tell *Zeta* to validate the whole infrastructure like this:

```shell
$ zeta -e development full_check
```

The above command performs the following three steps:

1. **Fetch all contracts** from remote repositories and put them into the cache directory configured above
2. **Copy the current service's contracts** which you might have changed into the contracts cache directory
3. **Validate all contracts** (i.e. make sure that every publishing service satisfies its consumers)

The above commands can also be run in isolation:

```shell
$ zeta -e development fetch_contracts
```

This command will populate the `contracts/.cache` directory with the current version of all contracts and then copy over your local changes to your contract. You can then validate your infrastructure like this:

```shell
$ zeta -e development validate
```

If you just made changes to your local contracts, you can copy them over to the cache and validate your infrastructure like this:

```shell
$ zeta -e development update_own_contracts validate
```

Otherwise it will exit with an error and display any contract violations in JSON.

### 5. Usage: With ruby

If you use *Zeta* in ruby, it will automatically know the current service, i.e. the one that it's running in. It will create a singleton `Lacerda::Infrastructure` instance from the [Lacerda gem](https://github.com/moviepilot/lacerda#readme), which gives you access to a bunch of interesting functions. If you're using [pry](https://github.com/pry/pry#readme), go ahead and do a quick `ls Zeta` and you will something like this, likely outdated, list:

```ruby
[1] pry(main)> ls Zeta
Zeta.methods:
  cache_dir             current_service       validate_object_to_consume
  clear_cache           env                   validate_object_to_consume!
  config                errors                validate_object_to_publish
  config_file           infrastructure        validate_object_to_publish!
  consume_object        update_contracts      verbose=
  contracts_fulfilled?  update_own_contracts
[2] pry(main)>
```

Each and every one of these goes directly to your instance `Lacerda::Infrastructure`, as defined by `config/zeta.yml`. Feel free to explore them a bit, but the ones' that might be of most interest are:

- `Zeta.validate_object_to_publish('Post', data_to_send)` makes sure that the content in `data_to_send` conforms to your 'Post' specification in your local `publish.mson`
- `Zeta.consume_object('MessageService::Message', received_data)` will give you an instance of the [Blumquist](https://github.com/moviepilot/blumquist#readme) class, which is an obect that has getters for all properties you specified in `consume.mson`

If you use these in your servies, they will help keeping the publish and consume specifications in sync with what's actually happening in the code.

### RSpec integration

Of course you'll want to have your infrastructure checked in CI. If you're using RSpec, we've got you covered. Just place the following lines in, for example, `spec/zeta_spec.rb`:

```ruby
require_relative 'spec_helper'

require 'zeta/rspec'
Zeta::RSpec.update_contracts
Zeta::RSpec.run
```

This will do the same as a `zeta -e test full_check` would do on the command line, but reporting to RSpec instead of printing its output directly. Whether or not you run `Zeta::RSpec.update_contracts` is up to you - perhaps you have HTTP requests disabled in your test suite, or you don't want to be network dependant for every run. If you remove it, however, make sure you run `zeta -e test fetch_remote_contracts` often enough to not be outdated.
