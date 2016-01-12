# Locomotive

[![Build Status](https://travis-ci.org/locomotivecms/engine.svg?branch=master)](https://travis-ci.org/locomotivecms/engine) [![Code Climate](https://codeclimate.com/github/locomotivecms/engine/badges/gpa.svg)](https://codeclimate.com/github/locomotivecms/engine) [![Dependency Status](https://gemnasium.com/locomotivecms/engine.svg)](https://gemnasium.com/locomotivecms/engine) [![Coverage Status](https://img.shields.io/coveralls/locomotivecms/engine.svg)](https://coveralls.io/r/locomotivecms/engine?branch=master) [![Join the chat at https://gitter.im/locomotivecms/engine](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locomotivecms/engine?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Locomotive is an open source platform to create, publish and edit sites (CMS). It is designed to save time and help you focus on what matters: front-end technology, standard development process and a very low learning curve for your clients.

Locomotive relies on a **very original workflow**:

- Sites are coded locally using our open source tool: [Wagon](https://github.com/locomotivecms/wagon). A desktop version (not open source and not tested in v3) is also available [here](http://www.wagonapp.com).
- Sites are deployed to the platform (engine) thanks to our internal API.
- A back-office for the end-users is automatically generated based on the custom models and editable regions described by the developers.

![Locomotive](https://dl.dropboxusercontent.com/u/20823269/locomotive-engine.png)

Visit the Locomotive official website [here](http://
locomotive.works) for more information.

## Features

- Multi-sites natively supported
- Uses Liquid, a simple and clean templating language
- Easy to add custom content types, no SQL needed
- Beautiful and intuitive editing interface
- Can fully localize all the content and pages
- Embed a Restful API to manage every site
- Develop and preview sites locally with your favorite tools **(Wagon)**
- Support for SASS, HAML and Coffee Script **(Wagon)**

## Instructions and help

- [Documentation](https://locomotive-v3.readme.io/)
- Get help with Locomotive or discuss technical issues on [Gitter](https://gitter.im/locomotivecms/engine?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) or [here](https://locomotive-v3.readme.io/discuss).
- [Follow us on twitter](http://twitter.com/locomotivecms)

## Contribute

V3 has launched! Which means a lot of stuff changed and we got bunch of new features shipped in. However, Locomotive will be updated frequently with more awesome features. Have a look at our [Trello](https://trello.com/b/kRiy1dZu/locomotive-v3) board to see what's next or see where you can help out.

### Technologies

Here is a list of the main gems used to power the Locomotive platform:

- Rails 4.2   - *web framework*
- Bootstrap   - *UI framework*
- Mongoid 5   - *Object-Document-Mapper for MongoDB 2/3*
- Devise 3.4  - *Authentication*
- Carrierwave - *Upload*
- Pundit      - *Permissions*

### Translating the back-office

By default, the Locomotive back-office is fully translated in English, Dutch and Greek.

Adding a new language is pretty straightforward since we now manage all our I18n translation keys in [Transifex](https://www.transifex.com), a platform dedicated to this kind of task.

Here is our Transifex portal page: [https://www.transifex.com/locomotive/locomotive-engine](https://www.transifex.com/locomotive/locomotive-engine). Feel free to sign up and translate!

### How to contribute

Locomotive is an open source project, we encourage contributions. If you have found a bug and want to contribute a fix, or have a new feature you would like to add, follow the steps below to get your patch into the project:

- Install ruby, mongoDB and phantomjs
- Clone the project <code>git clone git@github.com:locomotivecms/engine.git</code>
- Setup a virtual host entry for <code>test.example.com</code> to point to localhost
- Start mongodb if it is not already running
- Run the tests <code>bundle exec rake</code>
- Write your failing tests
- Make the tests pass
- [Create a GitHub pull request](http://help.github.com/send-pull-requests)

For new features (especially large ones) it is best to create a topic on the [Google group](https://groups.google.com/forum/?fromgroups#!forum/locomotivecms) first to make sure it fits into the goals of the project.

### Contact

Feel free to contact me at did at locomotivecms dot com.

Copyright (c) 2016 NoCoffee, released under the MIT license
