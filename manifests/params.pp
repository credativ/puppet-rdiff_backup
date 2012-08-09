class rdiff_backup::params {
  $ensure = 'present'
  $base_backupdir = '/srv/configs/backup'
  $remove_older_than = '4W'
  $include = ['/etc', '/srv']
}
