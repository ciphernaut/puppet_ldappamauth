# $Id: init.pp,v 1.8 2013/02/25 19:42:03 root Exp $

class ldappamauth {
  tag("security")
  tag("authentication")
  tag("authorization")

  case $lsbmajdistrelease {
    "6": {
      package {
         ["sssd", "sssd-client","pam_ldap", "nss-pam-ldapd"]:
          ensure => present;
      }
    }
    "5": {
      package {
        "nss_ldap":
          ensure => present;
      }
    }
  }
  
  if $lsbmajdistrelease <= 5 {
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
    include nscd
  } else {
    replace {
      "/etc/nsswitch.conf:group":
        require     => Service[sssd],
        file        => "/etc/nsswitch.conf",
        pattern     => "\\s*group:\s*files\s*(ldap\s*)?$",
        replacement => "group:      files sss";
      "/etc/nsswitch.conf:passwd":
        require     => Service[sssd],
        file        => "/etc/nsswitch.conf",
        pattern     => "\\s*passwd:\s*files\s*(ldap\s*)?$",
        replacement => "passwd:      files sss";
    }
    include nscd::disabled # argues with sssd
  }
  
  if $lsbmajdistrelease <= 5 {
    file { 
      "/etc/ldap.conf":
        require => Package["nss_ldap"],
        source  => "puppet:///ldappamauth/ldap.conf";
    }
  } else { # RHEL6
    file {
      "/etc/pam_ldap.conf":
        require => Package["pam_ldap"],
        source  => "puppet:///ldappamauth/pam_ldap.conf";
#      "/etc/nslcd.conf":
#        require => Package["nss-pam-ldapd"],
#        notify  => Service["nslcd"],
#        source  => "puppet:///ldappamauth/nslcd.conf";
      "/etc/sssd/sssd.conf":
         require => Package["sssd"],
         notify  => Service[sssd],
         mode    => 0600,
         source  => "puppet:///ldappamauth/sssd.conf";
      
    }
    service {
#      nslcd:
#        enable  => true,
#        ensure  => running,
#        require => [ File["/etc/nslcd.conf"], Package["nss-pam-ldapd"] ];
      sssd:
        enable => true,
        ensure => running;
    }
  }


  if $lsbmajdistrelease <= 5 {
    file {
      "/etc/pam.d/system-auth-ac":
        source => "puppet:///ldappamauth/system-auth-ac";
    }  
  } else { # RHEL6
    file {
      "/etc/pam.d/system-auth-ac":
        require => Service[sssd],
        source  => "puppet:///ldappamauth/system-auth-ac";
      "/etc/pam.d/password-auth-ac":
        require => Service[sssd],
        source  => "puppet:///ldappamauth/password-auth-ac";
    }
  }
}
