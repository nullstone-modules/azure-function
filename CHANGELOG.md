# 0.2.0 (Sep 30, 2026)
* Pinned `nullstone-io/ns` provider to `~> 0.13.0`.
* Replaced `ns_env_variables` with the layered `ns_env_layout`, `ns_env_values`, and `ns_env_platform_data` data sources to aggregate environment variables and secrets.
* Emitted the `env` platform data record, including the source of each variable and the Key Vault secret id of each managed secret.
* Reported the variable Azure injects into function apps (`WEBSITE_SITE_NAME`) in the `cloud` layer of the `env` platform data record.

# 0.1.0 (Unreleased)
* Initial release
