plugin_paths = { "/prosody-plugins/", "/prosody-plugins-custom" };
muc_mapper_domain_base = "{{ .Env.XMPP_DOMAIN }}";
http_default_host = "{{ .Env.XMPP_DOMAIN }}";
ssl = {
  protocol = "tlsv1_2+";
  ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
}

{{ $ENABLE_AUTH := .Env.ENABLE_AUTH | default "0" | toBool }}
{{ $ENABLE_GUESTS := .Env.ENABLE_GUESTS | default "0" | toBool }}
{{ $AUTH_TYPE := .Env.AUTH_TYPE | default "internal" }}
{{ $JWT_ASAP_KEYSERVER := .Env.JWT_ASAP_KEYSERVER | default "" }}
{{ $JWT_ALLOW_EMPTY := .Env.JWT_ALLOW_EMPTY | default "0" | toBool }}
{{ $JWT_AUTH_TYPE := .Env.JWT_AUTH_TYPE | default "token" }}
{{ $JWT_TOKEN_AUTH_MODULE := .Env.JWT_TOKEN_AUTH_MODULE | default "token_verification" }}
{{ $JVB_WS_ENABLE := .Env.JVB_WS_ENABLE | default "0" | toBool }}
{{ $TURN_ENABLE := .Env.TURN_ENABLE | default "0" | toBool }}

{{ if and $ENABLE_AUTH (eq $AUTH_TYPE "jwt") .Env.JWT_ACCEPTED_ISSUERS }}
asap_accepted_issuers = { "{{ join "\",\"" (splitList "," .Env.JWT_ACCEPTED_ISSUERS) }}" };
{{ end }}

{{ if and $ENABLE_AUTH (eq $AUTH_TYPE "jwt") .Env.JWT_ACCEPTED_AUDIENCES }}
asap_accepted_audiences = { "{{ join "\",\"" (splitList "," .Env.JWT_ACCEPTED_AUDIENCES) }}" };
{{ end }}

{{ if $JVB_WS_ENABLE }}
consider_websocket_secure = true;
cross_domain_websocket = true;
smacks_max_unacked_stanzas = 5;
smacks_hibernation_time = 60;
smacks_max_hibernated_sessions = 1;
smacks_max_old_sessions = 1;
{{ end }}

{{ if $TURN_ENABLE }}
turncredentials_secret = "{{ .Env.TURN_SECRET | default "keepthissecret" }}";
turncredentials = {
  { type = "{{ .Env.TURN_TYPE | default "turns" }}",
    host = "{{ .Env.TURN_HOST | default .Env.DOCKER_HOST_ADDRESS }}",
    port = {{ .Env.TURN_PORT | default "3478" }},
    transport = "{{ .Env.TURN_TRANSPORT | default "tcp" }}"
  }
}
{{ end }}

cross_domain_bosh = false;
consider_bosh_secure = true;

VirtualHost "{{ .Env.XMPP_DOMAIN }}"
  {{ if $ENABLE_AUTH }}
    {{ if eq $AUTH_TYPE "jwt" }}
    authentication = "{{ $JWT_AUTH_TYPE }}";
    app_id = "{{ .Env.JWT_APP_ID }}";
    app_secret = "{{ .Env.JWT_APP_SECRET }}";
    allow_empty_token = {{ if $JWT_ALLOW_EMPTY }}true{{ else }}false{{ end }};
    {{ if $JWT_ASAP_KEYSERVER }}
    asap_key_server = "{{ .Env.JWT_ASAP_KEYSERVER }}";
    {{ end }}
    {{ else if eq $AUTH_TYPE "ldap" }}
    authentication = "cyrus";
    cyrus_application_name = "xmpp";
    allow_unencrypted_plain_auth = true;
    {{ else if eq $AUTH_TYPE "internal" }}
    authentication = "internal_hashed";
    {{ end }}
  {{ else }}
    authentication = "anonymous";
  {{ end }}
    ssl = {
        key = "/config/certs/{{ .Env.XMPP_DOMAIN }}.key";
        certificate = "/config/certs/{{ .Env.XMPP_DOMAIN }}.crt";
    }
    speakerstats_component = "speakerstats.{{ .Env.XMPP_DOMAIN }}";
    conference_duration_component = "conferenceduration.{{ .Env.XMPP_DOMAIN }}";
    modules_enabled = {
        "bosh";
        "ping";
        {{ if $TURN_ENABLE }}
        "turncredentials"; -- Use XEP-0215
        {{ end }}
        {{ if $JVB_WS_ENABLE }}
        "websocket";
        "smacks"; -- XEP-0198: Stream Management
        {{ end }}
        "speakerstats";
        "conference_duration";
        {{ if not $ENABLE_GUESTS }}
        "muc_lobby_rooms";
        {{ end }}
        {{ if .Env.XMPP_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_MODULES) }}";
        {{ end }}
        {{ if and $ENABLE_AUTH (eq $AUTH_TYPE "ldap") }}
        "auth_cyrus";
        {{end}}
    }
    {{ if not $ENABLE_GUESTS }}
    lobby_muc = "lobby.{{ .Env.XMPP_DOMAIN }}";
    main_muc = "{{ .Env.XMPP_MUC_DOMAIN }}";
    muc_lobby_whitelist = { "{{ .Env.XMPP_RECORDER_DOMAIN }}" };
    {{ end }}
    c2s_require_encryption = false;

{{ if $ENABLE_GUESTS }}
VirtualHost "{{ .Env.XMPP_GUEST_DOMAIN }}"
    {{ if $JVB_WS_ENABLE }}
    -- https://github.com/jitsi/docker-jitsi-meet/pull/502#issuecomment-619146339
    authentication = "token";
    app_id = "";
    app_secret = "";
    allow_empty_token = true;
    {{ else }}
    authentication = "anonymous";
    {{ end }}
    speakerstats_component = "speakerstats.{{ .Env.XMPP_DOMAIN }}";
    conference_duration_component = "conferenceduration.{{ .Env.XMPP_DOMAIN }}";
    modules_enabled = {
        {{ if $TURN_ENABLE }}
        "turncredentials"; -- Use XEP-0215
        {{ end }}
        {{ if $JVB_WS_ENABLE }}
        "websocket";
        "smacks"; -- XEP-0198: Stream Management
        {{ end }}
        "speakerstats";
        "conference_duration";
        "muc_lobby_rooms";
    }
    lobby_muc = "lobby.{{ .Env.XMPP_DOMAIN }}";
    main_muc = "{{ .Env.XMPP_MUC_DOMAIN }}";
    muc_lobby_whitelist = { "{{ .Env.XMPP_RECORDER_DOMAIN }}" };
    c2s_require_encryption = false;
{{ end }}

{{ if .Env.XMPP_RECORDER_DOMAIN }}
VirtualHost "{{ .Env.XMPP_RECORDER_DOMAIN }}"
    modules_enabled = {
      "ping";
    }
    authentication = "internal_hashed";
    c2s_require_encryption = false;
{{ end }}

Component "{{ .Env.XMPP_MUC_DOMAIN }}" "muc"
    storage = "memory";
    modules_enabled = {
        "muc_meeting_id";
        "muc_domain_mapper";
        {{ if .Env.XMPP_MUC_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_MUC_MODULES) }}";
        {{ end }}
        {{ if and $ENABLE_AUTH (eq $AUTH_TYPE "jwt") }}
        "{{ $JWT_TOKEN_AUTH_MODULE }}";
        {{ end }}
    }
    admins = { "{{ .Env.JICOFO_AUTH_USER }}@{{ .Env.XMPP_AUTH_DOMAIN }}" }
    muc_room_cache_size = 1000;
    muc_room_locking = false;
    muc_room_default_public_jids = true;

-- internal muc component
Component "{{ .Env.XMPP_INTERNAL_MUC_DOMAIN }}" "muc"
    storage = "memory";
    modules_enabled = {
        "ping";
        {{ if .Env.XMPP_INTERNAL_MUC_MODULES }}
        "{{ join "\";\n\"" (splitList "," .Env.XMPP_INTERNAL_MUC_MODULES) }}";
        {{ end }}
    }
    admins = {
        "{{ .Env.JICOFO_AUTH_USER }}@{{ .Env.XMPP_AUTH_DOMAIN }}",
        "{{ .Env.JVB_AUTH_USER }}@{{ .Env.XMPP_AUTH_DOMAIN }}"
    }
    muc_room_locking = false;
    muc_room_default_public_jids = true;

VirtualHost "{{ .Env.XMPP_AUTH_DOMAIN }}"
    ssl = {
        key = "/config/certs/{{ .Env.XMPP_AUTH_DOMAIN }}.key";
        certificate = "/config/certs/{{ .Env.XMPP_AUTH_DOMAIN }}.crt";
    }
    authentication = "internal_hashed"

Component "focus.{{ .Env.XMPP_DOMAIN }}"
    component_secret = "{{ .Env.JICOFO_COMPONENT_SECRET }}";

Component "speakerstats.{{ .Env.XMPP_DOMAIN }}" "speakerstats_component"
    muc_component = "{{ .Env.XMPP_MUC_DOMAIN }}";

Component "conferenceduration.{{ .Env.XMPP_DOMAIN }}" "conference_duration_component"
    muc_component = "{{ .Env.XMPP_MUC_DOMAIN }}";

Component "lobby.{{ .Env.XMPP_DOMAIN }}" "muc"
    storage = "memory";
    restrict_room_creation = true;
    muc_room_locking = false;
    muc_room_default_public_jids = true;
