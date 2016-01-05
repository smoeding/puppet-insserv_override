# = Define: insserv_override
#
# Manage override files for LSB init.d boot dependencies
#
# == Parameters:
#
# [*ensure*]
#   Whether the override file should exist or not. This parameter is passed
#   to the File resource. Default: present
#
# [*provides*]
#   The names of the boot facilities provided by this script. Defaults to the
#   resource title. Can be an array when more than one facility is provided.
#
# [*required_start*]
#   The names of the facilities that must be available before this facility
#   can be started. Can be a string or an array.
#
# [*required_stop*]
#   The names of the facilities that must still be available when this
#   facility is stopped. Can be a string or an array.
#
# [*should_start*]
#   Facilities which should be available during startup of this facility.
#   Can be a string or an array.
#
# [*should_stop*]
#   Facilities which should still be available during shutdown of this
#   facility. Can be a string or an array.
#
# [*x_start_before*]
#   Facilities that should be started after the current facility.
#   Can be a string or an array.
#
# [*x_stop_after*]
#   Facilities that should be stopped before the current facility.
#   Can be a string or an array.
#
# [*default_start*]
#   The runlevels in which the current facility should be started.
#
# [*default_stop*]
#   The runlevels in which the current facility should be stopped.
#
# [*x_interactive*]
#   Whether to start this script alone during boot so the user can interact
#   with it at the console. Should be set to 'true' or left undefined.
#
# [*short_description*]
#   A one-line description for the service.
#
# == Requires:
#
# Module stdlib
#
# == Sample Usage:
#
#   insserv_override { 'foo':
#     required_start    => [ '2', '3', ],
#     required_stop     => [ '0', '1', '4', '5', '6', ],
#     short_description => 'Service foo',
#   }
#
#
define insserv_override (
  $ensure            = present,
  $provides          = $title,
  $required_start    = undef,
  $required_stop     = undef,
  $should_start      = undef,
  $should_stop       = undef,
  $x_start_before    = undef,
  $x_stop_after      = undef,
  $default_start     = undef,
  $default_stop      = undef,
  $x_interactive     = undef,
  $short_description = undef,
) {
  # Valid runlevels
  $runlevels = [ '0', '1', '2', '3', '4', '5', '6', 's' ]

  if !empty($default_start) {
    validate_array($default_start)
    if !member($runlevels, $default_start) {
      fail('Illegal runlevel found in default_start')
    }
  }

  if !empty($default_stop) {
    validate_array($default_stop)
    if !member($runlevels, $default_stop) {
      fail('Illegal runlevel found in default_stop')
    }
  }

  if !empty($default_start) and !empty($default_stop) {
    if !empty(intersection(any2array($default_start), any2array($default_stop))) {
      fail('The runlevels in default_start and default_stop must be distinct')
    }
  }

  $overrides_all = {
    'Provides:'          => $provides,
    'Required-Start:'    => $required_start,
    'Required-Stop:'     => $required_stop,
    'Should-Start:'      => $should_start,
    'Should-Stop:'       => $should_stop,
    'X-Start-Before:'    => $x_start_before,
    'X-Stop-After:'      => $x_stop_after,
    'Default-Start:'     => $default_start,
    'Default-Stop:'      => $default_stop,
    'X-Interactive:'     => str2bool($x_interactive) ? {
      true    => 'true',        # lint:ignore:quoted_booleans
      default => undef,
    },
    'Short-Description:' => $short_description,
  }

  # Remove unset hash entries
  $overrides = delete_undef_values($overrides_all)

  file { "/etc/insserv/overrides/${title}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('insserv_override/lsbheader.erb'),
    notify  => Exec["insserv-overrides-${title}"],
  }

  # Update links if necessary
  exec { "insserv-overrides-${title}":
    command     => "insserv -r ${title} ; insserv -d ${title}",
    cwd         => '/',
    path        => '/sbin:/bin:/usr/sbin:/usr/bin',
    refreshonly => true,
  }
}
