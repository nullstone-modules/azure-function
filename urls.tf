locals {
  private_urls = []
  public_urls  = ["https://${azurerm_linux_function_app.this.default_hostname}"]

  uri_matcher       = "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?"
  authority_matcher = "^(?:(?P<user>[^@]*)@)?(?:(?P<host>[^:]*))(?:[:](?P<port>[\\d]*))?"

  public_hosts  = [for url in local.public_urls : lookup(regex(local.authority_matcher, lookup(regex(local.uri_matcher, url), "authority")), "host")]
  private_hosts = []
}
