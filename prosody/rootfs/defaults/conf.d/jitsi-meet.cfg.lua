admins = { "{{ .Env.JICOFO_AUTH_USER }}@{{ .Env.XMPP_AUTH_DOMAIN }}" }
plugin_paths = { "/prosody-plugins/", "/prosody-plugins-custom" }
http_default_host = "{{ .Env.XMPP_DOMAIN }}"

{{ if .Env.XMPP_WS_ENABLE | default "0" | toBool }}
consider_websocket_secure = true
cross_domain_websocket = true
{{ end }}

{{ if .Env.TURN_ENABLE | default "0" | toBool }}
turncredentials_secret = "{{ .Env.TURN_SECRET | default "keepthissecret" }}";
turncredentials = {
  { type = "{{ .Env.TURN_TYPE | default "turns" }}",
    host = "{{ .Env.TURN_HOST | default .Env.DOCKER_HOST_ADDRESS }}",
    port = {{ .Env.TURN_PORT | default "3478" }},
    transport = "{{ .Env.TURN_TRANSPORT | default "tcp" }}"
  }
}
{{ end }}

VirtualHost "{{ .Env.XMPP_DOMAIN }}"
    {{ if .Env.ENABLE_AUTH | default "0" | toBool }}
      {{ if .Env.ENABLE_LDAP_AUTH }}
    authentication = "cyrus"
    cyrus_application_name = "xmpp"
    allow_unencrypted_plain_auth = true
      {{else}}
    authentication = "internal_plain"
      {{end}}
    {{ else }}
    authentication = "anonymous"
    {{ end }}
    ssl = {
        key = "/config/certs/{{ .Env.XMPP_DOMAIN }}.key";
        certificate = "/config/certs/{{ .Env.XMPP_DOMAIN }}.crt";
    }
    {{ if .Env.ENABLE_SPEAKER_STATS | default "0" | toBool }}
    speakerstats_component = "speakerstats.{{ .Env.XMPP_DOMAIN }}"
    {{ end }}
    modules_enabled = {
        {{ if .Env.XMPP_WS_ENABLE | default "0" | toBool }}
        "websocket";
        {{ end }}
        "bosh";
        "pubsub";
        "ping";
        {{ if .Env.XMPP_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_MODULES) }}";
        {{ end }}
        {{ if .Env.ENABLE_LDAP_AUTH }}
        "auth_cyrus";
        {{end}}
    }

    c2s_require_encryption = false

{{ if and (.Env.ENABLE_AUTH | default "0" | toBool) (.Env.ENABLE_GUESTS | default "0" | toBool) }}
VirtualHost "{{ .Env.XMPP_GUEST_DOMAIN }}"
    authentication = "anonymous"
    c2s_require_encryption = false
{{ end }}

VirtualHost "{{ .Env.XMPP_AUTH_DOMAIN }}"
    ssl = {
        key = "/config/certs/{{ .Env.XMPP_AUTH_DOMAIN }}.key";
        certificate = "/config/certs/{{ .Env.XMPP_AUTH_DOMAIN }}.crt";
    }
    authentication = "internal_plain"

{{ if .Env.XMPP_RECORDER_DOMAIN }}
VirtualHost "{{ .Env.XMPP_RECORDER_DOMAIN }}"
    modules_enabled = {
      "ping";
    }
    authentication = "internal_plain"
{{ end }}

{{ if .Env.ENABLE_SPEAKER_STATS | default "0" | toBool }}
Component "speakerstats.{{ .Env.XMPP_DOMAIN }}" "speakerstats_component"
    muc_component = "{{ .Env.XMPP_MUC_DOMAIN }}"
{{ end }}

Component "{{ .Env.XMPP_INTERNAL_MUC_DOMAIN }}" "muc"
    modules_enabled = {
        "ping";
        {{ if .Env.XMPP_INTERNAL_MUC_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_INTERNAL_MUC_MODULES) }}";
        {{ end }}
    }
    storage = "memory"
    muc_room_cache_size = 1000

Component "{{ .Env.XMPP_MUC_DOMAIN }}" "muc"
    storage = "memory"
    modules_enabled = {
        {{ if .Env.XMPP_MUC_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_MUC_MODULES) }}";
        {{ end }}
    }
    muc_room_locking = false
    muc_room_default_public_jids = true

Component "focus.{{ .Env.XMPP_DOMAIN }}"
    component_secret = "{{ .Env.JICOFO_COMPONENT_SECRET }}"

