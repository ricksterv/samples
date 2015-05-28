{%- set environment = "sys" %}

salt-minion:
  pkg:
    - installed
  service.running:
    - watch:
      - file: /etc/salt/minion
    - require:
      - pkg: salt-minion
  file.managed:
    - name: /etc/salt/minion
    - source: salt://{{environment}}/minion/files/minion
    - user: root
    - group: root
    - mode: 640
