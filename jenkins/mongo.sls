{% if pillar['environment'] is defined %}
{% set environment = pillar['environment'] %}
{% else %}
{% set environment = " self triggered exception " %}
{% endif %}


include:
  - python.pymongo

mongodb:
  pkg:
    - installed
  service:
    - running
    - require:
      - file: mongo-data
      - file: /etc/mongod.conf
      - file: /var/log/mongo
  user:
    - present
    - uid: 497
    - gid: 497
    - require:
      - group: mongod
  group:
    - present
    - gid: 497

mongo-dirs:
  file:
    - directory
    - user: mongod
    - group: mongod
    - mode: 755
    - makedirs: True
    - names:
      - /var/log/mongod
      - /usr/bin/mongo
    - require:
      - user: mongod
      - group: mongod

/etc/mongod.conf:
  file:
    - managed
    - user: mongod
    - group: mongod
    - mode: 644
    - source: salt://{{environment}}/jenkins/files/mongod.conf
    - template: jinja
    - require:
      - pkg: mongodb

# Ensure that mongodb.conf dbpath=/opt/jenkins 
