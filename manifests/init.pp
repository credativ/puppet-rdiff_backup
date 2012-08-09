# = Class: rdiff_backup
#
# Manage backup jobs with rdiff-backup
#
# == Requirements:
#
# - This module makes use of the example42 functions in the puppi module
#   (https://github.com/credativ/puppet-example42lib)
#
# - Uses the crond module to create cronjobs
#   (https://github.com/credativ/crond)
#
# == Parameters:
#
# [*ensure*]
#   Weither to ensure backups or not.
#   Default: present
#
# [*base_backupdir*]
#   Defines the base backup directory. Backups will be created in a hostname-
#   specific subdirectory of this directory.
#   (Default: /srv/configs/backup)
#
# [*remove_older_than*]
#   Defines the maximum age of increments. Parameter needs to be accepted
#   by the --remove-older-than option of rdiff-backup.
#   (Default: 4W)
#
# [*include*]
#   Defines the pathes to include. Its possible to specify excludes by just
#   prefixing them with a - sign.
#   (Default: ['/srv', '/etc'])
#
# == Author:
#
#  Patrick Schoenfeld (<patrick.schoenfeld@credativ.de>)
class rdiff_backup (
    $ensure             = params_lookup('ensure'),
    $base_backupdir     = params_lookup('base_backupdir'),
    $remove_older_than  = params_lookup('remove_older_than'),
    $include            = params_lookup('include')
    ) inherits rdiff_backup::params {

    $backupdir = "${base_backupdir}/${::hostname}"

    Package['rdiff-backup'] -> File[$backupdir] -> Crond['rdiff-backup']

    package { 'rdiff-backup':
        ensure  => $ensure
    }

    file { $backupdir:
        ensure => directory,
        mode   => 0700,
    }

    if $ensure == 'present' {
        $ensure_backup_directory = directory
    } else {
        $ensure_backup_directory = $ensure
    }

    file { '/etc/rdiff-backup':
        ensure  => $ensure,
        owner   => root,
        group   => root,
        mode    => 0644,
    }

    file { '/etc/rdiff-backup/includelist':
        ensure => $ensure,
        owner   => root,
        group   => root,
        content => template('rdiff_backup/includelist.erb')
    }

    crond { 'rdiff-backup':
        ensure  => $ensure,
        command => [
            "rdiff-backup --include-globbing-filelist /etc/rdiff-backup/includelist / ${backupdir}",
            "rdiff-backup -v0 --remove-older-than $remove_older_than ${backupdir}"
        ],
    user        => root,
    hour        => 23,
    minute      => 21,
    }
}
