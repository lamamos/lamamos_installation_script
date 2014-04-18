use config;
use install;


sub initialise{

  if (my $err = ReadCfg('/etc/lamamos/lamamos.conf')) {
    print(STDERR $err, "\n");
    exit(1);
  }

  $CFG::hostName = getHostName();

  #now the config hash is in : $CFG::config{'varName'};
  #print $CFG::config{'ddName'}."\n";

  #we make sure that Rex will run in 15 minutes
  Service::crontask::define({

    'name' => 'Rex',
    'minute' => '*/30',
    'user' => 'root',
    'commande' => 'cd /etc/lamamos/rex/ && rex configure',
  });

  #we start the socket server
  communication::start();

  communication::waitOtherServ('test', 1);

  #Launching of pacemaker
  installBaseSysteme();

  Service::pacemaker::primitive::define({

    'primitive_name' => 'p_ip',
    'primitive_class' => 'ocf',
    'provided_by' => 'heartbeat',
    'primitive_type' => 'IPaddr2',
    'parameters' => {'ip' => '192.168.56.100', 'cidr_netmask'=>'24', 'nic'=>'eth0',},
  });
}



sub finalise{

  #we stop the socket server
  communication::stop({});

  #print $CFG::config{'OCFS2Init'};
  writeCfg('/etc/lamamos/lamamos.conf');
}



1;