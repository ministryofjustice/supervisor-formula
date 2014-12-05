include:
  - bootstrap.groups
  - python

supervisord:
  service:
    - running
    - name: supervisor
    - enable: True
    - reload: True
    - require:
      - group: supervisor
    - watch:
      - file: /etc/supervisord.conf
      - file: /etc/init.d/supervisor
      - pip: supervisor-python


/etc/supervisord.conf:
  file:
    - managed
    - source: salt://supervisor/templates/supervisord.conf
    - user: root
    - group: root
    - mode: 644


supervisor-python:
  pip:
    - installed
    - name: supervisor
    - require:
      - pkg: python-pip
      - pkg: python-dev


/etc/init.d/supervisor:
  file:
    - managed
    - source: salt://supervisor/files/supervisor
    - user: root
    - group: root
    - mode: 755
    - watch:
        - pip: supervisor-python


/etc/supervisor.d:
  file:
    - directory
    - user: root
    - group: root
    - clean: True


/var/log/supervisor:
  file:
    - directory
    - user: root
    - group: root


