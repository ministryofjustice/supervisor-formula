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


available macros
----------------
{% macro supervise(
                   appslug,
                   user=None,  # defaults to appslug
                   template='supervisor/templates/app-generic.ini',
                   cmd=None,
                   args=None,
                   numprocs=1,
                   log_dir=None,      # defaults to "/var/log/" + user
                   working_dir=None,  # defaults to "/srv/" + user
                   supervise=False    # don't use together with umprocs
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
             supervise=True) }}


note
----
don't forget to logship the logs i.e.::

    {% from 'monitoring/logs/lib.sls' import logship2 with context %}
    {{ logship2('supervisor-'+appslug+'-stdout', log_dir+'/'+appslug+'-supervisor.out', appslug, ['supervisor','stdout',appslug], 'json') }}
    {{ logship2('supervisor-'+appslug+'-stderr', log_dir+'/'+appslug+'-supervisor.err', appslug, ['supervisor','stderr',appslug], 'json') }}
