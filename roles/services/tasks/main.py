- name: Enable the user service
  systemd:
    name: night-mode.service
    user: yes
    enabled: yes
    state: restarted
