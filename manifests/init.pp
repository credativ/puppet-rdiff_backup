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

    file { '/etc/rdiff-backup':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 0644,
    }

    file { '/etc/rdiff-backup/includelist':
        ensure => present,
        owner   => root,
        group   => root,
        content => template('rdiff_backup/includelist.erb')
    }

    crond { 'rdiff-backup':
        ensure  => present,
        command => [
            "rdiff-backup --include-globbing-filelist /etc/rdiff-backup/includelist / ${backupdir}",
            "rdiff-backup -v0 --remove-older-than $remove_older_than ${backupdir}"
        ],
    user        => root,
    hour        => 23,
    minute      => 21,
    }
}
