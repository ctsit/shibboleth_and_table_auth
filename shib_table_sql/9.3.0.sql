REPLACE INTO redcap_config(field_name,value) VALUES('shibboleth_table_config', '{\"splash_default\":\"non-inst-login\",\"table_login_option\":\"Use local REDCap login\",\"institutions\":[{\"login_option\":\"Shibboleth Login\",\"login_text\":\"Click the image below to login using Shibboleth\",\"login_image\":\"https:\/\/wiki.shibboleth.net\/confluence\/download\/attachments\/131074\/atl.site.logo?version=2&modificationDate=1502412080059&api=v2\",\"login_url\":\"\"}]}');

-- Delete the old config style for redcap_config
DELETE FROM redcap_config where field_name in (
    'shibboleth_table_login_image', 
    'shibboleth_table_shibboleth_login_option', 
    'shibboleth_table_table_login_option', 
    'shibboleth_table_shibboleth_login_text', 
    'shibboleth_table_splash_default'
);
