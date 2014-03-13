{#
include:
  - supervisor

#}

{% macro supervise(appslug,
                   user=None,
                   template='supervisor/templates/app-generic.ini',
                   cmd=None,
                   args=None,
                   numprocs=1,
                   log_dir=None,
                   working_dir=None,
                   supervise=False,
                   logship=False) %}

# user supervise flag when service is deployed through salt (i.e. generic service), no separate deploy step

{% set user = user or appslug %}
{% set working_dir = working_dir or ("/srv/" + user) %}
{% set log_dir = log_dir or ("/var/log/" + user) %}


/etc/supervisor.d/{{appslug}}.conf:
  file:
    - managed
    - source: salt://{{template}}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      appslug: {{appslug}}
      user: {{user}}
      cmd: {{cmd}}
      args: {{args}}
      working_dir: {{working_dir}}
      log_dir: {{log_dir}}
    - require:
      - file: /etc/supervisor.d
      - file: {{log_dir}}
{%- if user != 'root' %}
      - user: {{user}}
{%- endif %}
    - watch_in:
      - service: supervisord


{% if supervise %}
supervise-{{appslug}}:
  supervisord:
    - running
    - name: '{{appslug}}'
    - bin_env: /usr/local/bin/supervisorctl
    - conf_file: /etc/supervisord.conf
{% endif %}

{% if logship %}
{% from 'logging/lib.sls' import logship with context %}
{{ logship(appslug+'-supervisor.out', log_dir+'/'+appslug+'-supervisor.out', 'supervisor', ['supervisor', appslug, 'out'], 'json') }}
{{ logship(appslug+'-supervisor.err', log_dir+'/'+appslug+'-supervisor.err', 'supervisor', ['supervisor', appslug, 'err'], 'json') }}
{% endif %}

{% endmacro %}


{% macro supervise_unicorn(appslug, working_dir, logship=False) -%}

/var/run/{{appslug}}:
  file:
    - directory
    - mode: 755
    - user: {{appslug}}
    - require:
{%- if user != 'root' %}
      - user: {{appslug}}
{%- endif %}

{{ supervise(appslug,
             cmd="/usr/local/bin/bundle",
             args="exec unicorn -E production -o unix:///var/run/" + appslug + "/" + appslug + ".sock",
             working_dir=working_dir,
             logship=logship) }}

{%- endmacro %}



{% macro supervise_java(appslug) -%}

{{ supervise(appslug,
             cmd="java",
             args="-Dcom.sun.xml.internal.ws.transport.http.HttpAdapter.dump=true -jar " + appslug + ".jar",
             working_dir="/srv/" + appslug,
             logship=logship) }}

{%- endmacro %}
