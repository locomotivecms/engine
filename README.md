# Locomotive

[![Build Status](https://travis-ci.org/locomotivecms/engine.svg?branch=master)](https://travis-ci.org/locomotivecms/engine) [![Code Climate](https://codeclimate.com/github/locomotivecms/engine/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/engine) [![Dependency Status](https://gemnasium.com/locomotivecms/engine.svg)](https://gemnasium.com/locomotivecms/engine) [![Coverage Status](https://img.shields.io/coveralls/locomotivecms/engine.svg)](https://coveralls.io/r/locomotivecms/engine?branch=master) [![Join the chat at https://gitter.im/locomotivecms/engine](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locomotivecms/engine?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![Locomotive Screenshot](https://wagonapp.s3.amazonaws.com/doc/v3_backoffice.png)

Locomotive is an open source platform to create, publish and edit sites. It is designed to save your time and help you focus on what matters: front-end technology, standard development process and no learning time for your client.

Locomotive relies on a **very original workflow**.

- Sites are coded locally using our open source tool: [Wagon](https://github.com/locomotivecms/wagon). A desktop version (not open source) is also available [here](http://www.wagonapp.com).
- Sites are deployed to the platform (engine) thanks to our internal API.
- A back-office for the end-users is automatically generated based on the custom models and editable regions described by the developers.

Visit the Locomotive official website [here](http://www.locomotivecms.com) for more information.

## Development Status ##

As you can see from the commit logs, we are intensively working on the new V3 version. We kept all the features from our stable [v2 version](https://github.com/locomotivecms/engine/tree/v2.5.x), we just replace the UI, upgrade the gems and refactor our code.

**[UPDATES]** Finally, we've been doing much more than we planed at first. We extracted the rendering functionality from the Engine and make it a gem named [Steam](https://github.com/locomotivecms/steam). This gem is also now used by [Wagon](https://github.com/locomotivecms/wagon) (version 2.0 in progress) which makes sure you get the same result between Wagon and Engine when you preview a page.
And last but not least, we added a Ruby API client for Locomotive that we called [Coal](https://github.com/locomotivecms/coal). That client consumes the API from Engine which embeds now GrapeAPI. [Nic Boie](https://github.com/boie0025) is in charge of it. Kudos to him!

**TRELLO** [here](https://trello.com/b/kRiy1dZu/locomotive-v3)

## Getting Started ##

If you can not wait for playing with our new version, you still can use the current one (v2.5.x). Check out our [installation guide](http://doc.locomotivecms.com/get-started).

## Features ##

- Multi-sites natively supported
- Uses Liquid, a simple and clean templating language
- Easy to add custom content types, no SQL needed
- Beautiful and intuitive editing interface
- Can fully localize all the content and pages
- Embed a Restful API to manage every site
- Develop and preview sites locally with your favorite tools **(Wagon)**
- Support for SASS, LESS, HAML and Coffee Script **(Wagon)**

## Technologies ##

Here is a list of the main gems used to power the Locomotive backend:

- Rails 4.2   - *web framework*
- Bootstrap   - *UI framework*
- Mongoid 4.0 - *Object-Document-Mapper for MongoDB*
- Devise 3.4  - *Authentication*
- Carrierwave - *Upload*
- Pundit      - *Permissions*

## Community ##

- [Gitter](https://gitter.im/locomotivecms/engine?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) for technical discussions.
- Get help or discuss Locomotive at the [Locomotive Google group](https://groups.google.com/forum/?fromgroups#!forum/locomotivecms)
- [Follow us on twitter](http://twitter.com/locomotivecms)

## Contributing to Locomotive ##

Locomotive is an open source project, we encourage contributions. If you have found a bug and want to contribute a fix, or have a new feature you would like to add, follow the steps below to get your patch into the project:

- Install ruby and mongoDB
- Clone the project <code>git clone git@github.com:locomotivecms/engine.git</code>
- Setup a virtual host entry for <code>test.example.com</code> to point to localhost
- Run the tests <code>bundle exec rake</code>
- Write your failing tests
- Make the tests pass
- [Create a GitHub pull request](http://help.github.com/send-pull-requests)

For new features (especially large ones) it is best to create a topic on the [Google group](https://groups.google.com/forum/?fromgroups#!forum/locomotivecms) first to make sure it fits into the goals of the project.

## Contact ##

Feel free to contact me at did at locomotivecms dot com.

Copyright (c) 2015 NoCoffee, released under the MIT license
