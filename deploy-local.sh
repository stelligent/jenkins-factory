#!/bin/bash

gem uninstall jenkins-factory -x
gem build jenkins-factory.gemspec
gem install jenkins-factory-0.0.0.gem --no-ri --no-rdoc