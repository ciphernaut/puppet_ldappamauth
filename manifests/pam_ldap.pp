class ldappamauth::pam_ldap {
  tag("security")
  tag("authentication")
  tag("authorization")

  include ldappamauth::base

  case $lsbmajdistrelease {
    "6": {
      package {
        "pam_ldap":
          ensure => present;
      }
    }
    "5": {
      realize(Package["nss_ldap"])
      realize(File["/etc/ldap.conf"])
    }
  }
  file {
      "/etc/pam.d/system-auth-ac":
      source => "puppet:///ldappamauth/system-auth-ac";
  }  
}