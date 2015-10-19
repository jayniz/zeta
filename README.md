![](https://dl.dropboxusercontent.com/u/1953503/old-maid.jpg)

# Old Maid

```
tl;dr:

- each service defines which objects it publishes or consumes
- these contracts are formatted in human readable markdown
- Old Maid knows the rest of your infrastructure and fetches the
  contracts of all other services
- you never have to know/care about other services or repositories
- Old Maid will alert you if your change in service X breaks service Y
```

In an infrastructure where many services are talking with each other, it's sometimes hard to know **how changes in one service affect other services**, as each project often just knows about itself. Even if local tests pass, you can't know what other services might be affected when you make changes to a service.

*Old Maid* tackles this problem by allowing each service to define which objects it consumes, and which objects it publishes - in simple Markdown (specifically [MSON](https://github.com/apiaryio/mson)).It doesn't matter if these objected are transported via a HTTP, a message broker like RabbitMQ or any other mean.


## Walk this way

Let's imagine an imaginary chat app that is split up into three independent services that communicate via a message broker:

- **MessageService** keeps track of the state of to do items
- **SearchService** makes your chat history searchable
- **NotificationService**: sends an email when a private message is received

Each time a message is sent, MessageService publishes the full message to the message broker. While the SearchService is likely interested in the full message with all of its properties to index it probably, the NotificationService might just care about the sender and the receiver of the message, discarding all other properties.

An intern is asked to implement a feature that allows one message to be sent to multiple people at the same time. They go ahead and just change the numerical `recepient_id` property of a message to an `recipient_ids` array. They run their tests and all looks good. But **THE INTERN JUST BROKE THE NOTIFICATION SERVICE** because it depends on the `recipient_id` property. 😱

Wouldn't it be nice of some test local to the **MessageService** repository to tell the poorintern that removing the `recipient_id` property breaks the expectations other services have of the *MessageService* BEFORE they deploy?


## Yes, it would!

Each project have to contain two files in order for *Old Maid* to do its job:

1. `contracts/publish.mson`
2. `contracts/consume.mson`

These are simple markdown files in the wonderful [MSON](https://github.com/apiaryio/mson) format. Let's look at the contracts dir of **MessageService**, shall we?

```bash
/home/dev/message-service$ cat contracts/publish.mson
# Data Structures
This file defines what MessageService may publish.

# Message
- id: (number, required)
- sender_id: (number, required)
- recipients: (Array[number], required)
- text: (string, required)
- emoji: (string)

/home/dev/MessageService$
```

So far so good. This way *MessageService* can tell the world what exactly it means when a `Message` object is published. Much the same, the *NotificationService* could define which properties of a `Message` object from the `MessageService` it is actually interested in:

```bash
/home/dev/notification-service$ cat contracts/consume.mson
# Data Structures
We just consume one object type, and it comes from the MessageService. Check it out!

# MessageService:Message
- sender_id: (number, required)
- recipient_id: (number, required)
```

As you can see, it expects the `recipient_id` property to be present.


## Getting started

### 1. Installation
First, add *Old Maid* to your `Gemfile` or install manually:

```bash
$ gem install old-maid
```

### 2. Configuration

If you're using ruby on rails, *Old Maid* will automatically know your
environment and look for its configuration in `config/old-maid.yml`, which could look like this:

```yaml
common: &common
  # This name will be used by other services to identify objects they consume
  # from the MessageService
  service_name: MessageService

  # Which directory contains the publish.mson and consume.mson
  contracts_path: contracts

  # Where to cache the contracts from all other projects that are part of the
  # infrastructure. Old Maid will fetch these for you.
  contracts_cache_path: contracts/.cache


development:
  <<: *common
  # The services file contains all services that are part of your infrastructure
  # and tested with Old Maid. It's just another yaml file, but the nice thing is
  # that it's outside of the service's repository and has to be maintained only
  # in one place.
  services_file:

    # The file name to look for
    file: 'development.yml'

    # You can either host the file yourself via HTTP, but it's quite convenient
    # to have it version controlled and hosted by a service like github. We'll
    # call this repo old-maid-config for this example:
    github:
      repo: jensmander/old-maid-config
      branch: master
      path: infrastructure

# And here we can adjust things for each environment as needed
production:
  <<: *common
  ...

```

You typically just create this file once and then don't touch it anymore. Here's how `github.com/jensmander/old-maid-config/infrastructure/master.yml` might look:


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
