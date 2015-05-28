{% if pillar['environment'] is defined %}
{% set environment = pillar['environment'] %}
{% else %}
{% set environment = " self triggered exception " %}
{% endif %}
            
mwelness:
  user.present:
    - home: /home/mwelness
    - uid: 501
    - gid: 501
    - groups:
        - mwelness
        - devops

yum_dev_tools:
    - pkg.group_install 'Development Tools'
    
yum_nodejs:
    - pkg.install 'nodejs'

yum_npm:
    - pkg.install 'npm'
    
yum_java_devel:
    - pkg.install 'java-1.7.0-openjdk-devel'

yum_java_devel:
    - pkg.install 'java-1.7.0-openjdk' 

# REQUIRES Entry of External IP address of Minion Server
# What is the command to ask input? 
npm_set_proxy:
  cmd.run:
    - name: npm config set proxy -g http://{% grain.reverse_ip %}:128
    
maven:
  archive:
    - extracted
    - name: /usr/local/
    - source: http://apache.arvixe.com/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
#    - source_hash: md5=94c51f0dd139b4b8549204d0605a5859
    - archive_format: tar
    - tar_options: z

/opt/mwelness/.m2:
  file.managed:
    - source: salt://{{environment}}/jenkins/files/m2
    - user: mwelness
    - group: mwelness
    - mode: 644
    - template: jinja

cmd.run:
  - name: export PATH=$PATH:/usr/local/apache-maven-3.2.5/bin
    
/opt/mwelness/.ssh:
  file.managed:
    - source: salt://{{environment}}/jenkins/files/ssh
    - user: mwelness
    - group: mwelness
    - mode: 644
    - template: jinja

cmd.run:
    - name: ln -s /usr/bin/java /usr/java/default/bin/java

cmd.run:
    - name: ln -s /opt/jenkins /opt/mwelness/jenkins

cmd.run:
    - name: chown -R mwelness:mwelness /opt/jenkins
    
yum_remove_git:
  - pkg.remove git

yum_install_git:
  -pkg.install git

# All cmd.run are to be replaced. Short term fix only
cmd.run:
    - name: export PATH=$PATH:/var/opt/git/bin >> /etc/bashrc 
       
cmd.run:
    - name: export PATH=$PATH:/var/opt/git/bin >> /home/mwelness/bashrc
    
cmd.run:
    - name: chown mwelness:melness /home/mwelness/bashrc

/home/mwelness/.gitconfig:
  file.managed:
    - source: salt://{{environment}}/jenkins/files/gitconfig
    - user: mwelness
    - group: mwelness
    - mode: 644
    - template: jinja

/home/mwelness/.git-credentials:
  file.managed:
    - source: salt://{{environment}}/jenkins/files/git-credentials
    - user: mwelness
    - group: mwelness
    - mode: 644
    - template: jinja
    
yum_mongodb-server:
    - pkg.install: 
        - name: mongodb-server
    
yum_nodejs-mongodb.noarch:
    - pkg.install  nodejs-mongodb.noarch
    
yum_pymongo:
    - pkg.install pymongo.x86_64


## Include Mongo.sls file components here 
# File: mongo.sls
	- include
	- mongodb
    - mongo-dirs
    - /etc/mongod.conf

cmd.run:
    - name: mkdir -p ./opt/jenkins/mongodb; mv /var/lib/mongodb $_

cmd.run:
    - name: ln -s /opt/jenkins/mongodb /var/lib/mongodb

# Copy mongo_database from known good server to carry over users.
cmd.run:
    - name: scp -rp mwelness@{{environment}}:/opt/mwelness/mongo_database ~

cmd.run:
    - name: chown -R mongodb:mongodb /opt/jenkins/mongodb
    
cmd.run:
    - name: chown -R mongodb:mongodb /opt/jenkins/mongo_database
    
cmd.run:
    - name: service mongod stop
    
cmd.run:
    - name: service mongod start
    
yum_gcc:
    - pkg.install gcc

ruby-devel:
    pkg.installed
  
yum_rubygems:
    - pkg.install rubygems

gem_update:
  cmd.run:
    - name: gem update --system

gem_chunky_png:
  cmd.run:
    - name: gem install chunky_png-1.3.3.gem -s https://rubygems.org

gem_fsevent:
  cmd.run:
    - name: gem install rb-fsevent-0.9.4.gem -s https://rubygems.org

gem_inotify:
  cmd.run:
    - name: gem install rb-inotify-0.9.5-2.gem -s https://rubygems.org
    
gem_ffi:
  cmd.run:
    - name: gem install ffi-1.9.6-2.gem  -s https://rubygems.org

gem_sass:
  cmd.run:
    - name: gem install sass-3.4.9.gem -s https://rubygems.org

gem_compass:
  cmd.run:
    - name: gem install compass-core-1.0.1.gem -s https://rubygems.org

gem_multi_json:
  cmd.run:
    - name: gem install compass-core-1.0.1.gem -s https://rubygems.org

gem_multi_json:
  cmd.run:
    - name: gem install compass-1.0.1.gem -s https://rubygems.org



/opt/mwelness/build-automation/uDeploy/management_scripts:
  file.managed:
    - source: salt://{{environment}}/jenkins/files/management_scripts
    - user: mwelness
    - group: mwelness
    - mode: 644
    - template: jinja
    
npm_scripts:
  npm.installed:
    - pkgs: 
        - inherits 
        ldapauth 
        grunt-cli 
        mocha

# file.append
rights_cron:
  cmd.run: echo "*/1 * * * * chown -R mwelness:mwelness /opt/jenkins/workspace" /var/spool/cron/root
  cmd.run: echo "*/1 * * * * chown -R mwelness:mwelness /opt/jenkins/tools" /var/spool/cron/root
  cmd.run: echo "*/1 * * * * chown -R mongodb:mongodb /opt/jenkins/mongo_database" /var/spool/cron/root
  cmd.run: echo "*/1 * * * * chown -R mongodb:mongodb /opt/jenkins/journal" /var/spool/cron/root
  cmd.run: echo "*/1 * * * * chown -R mongodb:mongodb /opt/jenkins/mongodb" /var/spool/cron/root
  cmd.run: echo "*/1 * * * * chown -R mongodb:mongodb /opt/jenkins/mongod.lock" /var/spool/cron/root