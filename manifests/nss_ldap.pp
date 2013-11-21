class ldappamauth::nss_ldap {
  tag("security")
  tag("authorization")

  include ldappamauth::base
  include nscd

  realize(Package["nss_ldap"])
  realize(File["/etc/ldap.conf"])

  replace {
    "/etc/nsswitch.conf:group":
      file        => "/etc/nsswitch.conf",
      pattern     => "\\s*group:\s*files\s*$",
      replacement => "group:      files ldap";
    "/etc/nsswitch.conf:passwd":
      file        => "/etc/nsswitch.conf",
      pattern     => "\\s*passwd:\s*files\s*$",
      replacement => "passwd:      files ldap";
  }

}