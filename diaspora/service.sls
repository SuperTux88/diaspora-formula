{%- from "diaspora/map.jinja" import diaspora with context %}

include:
  - diaspora.install
  - diaspora.config

/etc/systemd/system/diaspora-sidekiq.service:
  file.managed:
    - user: root
    - mode: 644
    - source: salt://diaspora/files/diaspora-sidekiq.service
    - template: jinja
    - context:
        diaspora: {{ diaspora|json }}

/etc/systemd/system/diaspora-web.service:
  file.managed:
    - user: root
    - mode: 644
    - source: salt://diaspora/files/diaspora-web.service
    - template: jinja
    - context:
        diaspora: {{ diaspora|json }}

/etc/systemd/system/diaspora.target:
  file.managed:
    - user: root
    - mode: 644
    - source: salt://diaspora/files/diaspora.target
    - template: jinja
    - context:
        diaspora: {{ diaspora|json }}

diaspora_sidekiq_service:
  service.enabled:
    - name: diaspora-sidekiq
    - requre:
      - file: /etc/systemd/system/diaspora-sidekiq.service

diaspora_web_service:
  service.enabled:
    - name: diaspora-web
    - requre:
      - file: /etc/systemd/system/diaspora-web.service

diaspora_service:
  service.running:
    - name: diaspora.target
    - enable: True
    - requre:
      - cmd: diaspora_precompile_assets
      - file: /etc/systemd/system/diaspora.target
      - service: diaspora_sidekiq_service
      - service: diaspora_web_service
    - watch:
      - git: diaspora_git
      - file: {{ diaspora.install_path }}/config/database.yml
      - file: {{ diaspora.install_path }}/config/diaspora.yml
