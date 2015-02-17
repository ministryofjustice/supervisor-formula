supervisor
==========

usage
-----
include:
  - supervisor


optional integration
--------------------
include:
  - supervisor.alerts
  - supervisor.logship


pillar config flags
-------------------

supervisor:dotdirclean:disabled - if True, avoids cleanup of the /etc/supervisor.d/ folder.

available macros
----------------
{% macro supervise(
                   appslug,
                   user=None,  # defaults to appslug
                   template='supervisor/templates/app-generic.ini',
                   cmd=None,
                   args=None,
                   numprocs=1,        # fix me
                   log_dir=None,      # defaults to "/var/log/" + user
                   working_dir=None,  # defaults to "/srv/" + user
                   supervise=False,   # don't use together with numprocs
                   logship=False      # to automatically ship the logs (requires logging-formula)
                   ) %}


examples
--------

{% from 'supervisor/lib.sls' import supervise with context %}

{{ supervise('yourapp',
             cmd='yout cmd',
             args='your args',
             numprocs=salt['pillar.get']('apps:pdf:workers', 3),
             working_dir='/srv/pdf/opg-lpa-pdf-generator') }}


{{ supervise('yourapp',
             cmd='yout cmd',
             args='your args',
             working_dir='/srv/yourapp/application/current',
             supervise=True,
             logship=True) }}

