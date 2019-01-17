    # -------------------------------------------------------------------------
	# Package
	#    klocworkeaDriver.pl
	#
	# Dependencies
	#    None
	#
	# Template Version
	#    1.0
	#
	# Date
	#    11/05/2010
	#
	# Engineer
	#    Carlos Rojas 
	#
	# Copyright (c) 2012 Electric Cloud, Inc.
	# All rights reserved
	# -------------------------------------------------------------------------

    # -------------------------------------------------------------------------
	# Includes
	# -------------------------------------------------------------------------
    use ElectricCommander;
    use warnings;
    use strict; 
    $|=1;
    
    my $ec = ElectricCommander->new();
    $ec->abortOnError(0);
    
    # -------------------------------------------------------------------------
    # Parameters
    # -------------------------------------------------------------------------
    $::gAdditionalCommands  = ($ec->getProperty( "options" ))->findvalue('//value')->string_value;
    $::gHostManager         = ($ec->getProperty( "echost" ))->findvalue('//value')->string_value;
    $::gPathToEmake         = ($ec->getProperty( "emakePath" ))->findvalue('//value')->string_value;
    $::gLicenseHost         = ($ec->getProperty( "licenseHost" ))->findvalue('//value')->string_value;
    $::gLicensePort         = ($ec->getProperty( "licensePort" ))->findvalue('//value')->string_value;
    $::gOutputTablesDir     = ($ec->getProperty( "outputTablesDir" ))->findvalue('//value')->string_value;
    $::gForce               = ($ec->getProperty( "force" ))->findvalue('//value')->string_value;
    $::gWorkingDirectory    = ($ec->getProperty( "workingDirectory" ))->findvalue('//value')->string_value;
    $::gKlocworkRoot        = ($ec->getProperty( "klocroot" ))->findvalue('//value')->string_value;
    $::gBuildSpecFilePath   = ($ec->getProperty( "buildspec" ))->findvalue('//value')->string_value;
    $::gEmakeAnotationFile  = ($ec->getProperty( "emakeAnotationFile" ))->findvalue('//value')->string_value;
    $::gBuildTraceFile      = ($ec->getProperty( "buildTrace" ))->findvalue('//value')->string_value;
    $::gDebug               = ($ec->getProperty( "debug" ))->findvalue('//value')->string_value;

    #more global variables to be added here
    
    # -------------------------------------------------------------------------
	# Main functions
	# -------------------------------------------------------------------------
    
    ########################################################################
    # main - contains the whole process to be done by the plugin, it builds the
    #        command line, sets the properties and the working directory
    #
    # Arguments:
    #   -none
    #
    # Returns:
    #   -nothing
    #
    ########################################################################
    sub main() {
    
        # Args array for kwecbuild 
        my @kwecbuildArgs = ();
        # Args array for kwlogparser
        my @kwlogparserArgs = ();
        # Args array for kwinject
        my @kwinjectArgs = ();
        
        #properties' map
        my %props;	
        
        
        my $kwecbuildExec = "";
        my $kwlogparserExec = "";
        my $kwinjectExec = "";
        
        if($::gKlocworkRoot && $::gKlocworkRoot ne ""){
            $kwecbuildExec = $::gKlocworkRoot;
            $kwlogparserExec = $::gKlocworkRoot;
            $kwinjectExec = $::gKlocworkRoot;
        }
        
        $kwecbuildExec .= "kwecbuild"; 
        $kwlogparserExec .= "kwlogparser";
        $kwinjectExec .= "kwinject";
        
        push(@kwecbuildArgs, $kwecbuildExec);
        push(@kwlogparserArgs, $kwlogparserExec);
        push(@kwinjectArgs, $kwinjectExec);

        # if gAdditionalCommands contains text: add the additional 
        # commands that the user specified
        if($::gAdditionalCommands  && $::gAdditionalCommands  ne "") {
            foreach my $klocworkeaCommand (split(' +', $::gAdditionalCommands)) {
                push(@kwecbuildArgs, "$klocworkeaCommand");
            }
        }
        
        if($::gForce && $::gForce ne "") {
            push(@kwecbuildArgs, "--force");
        }
        
        if($::gDebug && $::gDebug ne "")
        {
            push(@kwecbuildArgs, "--debug");
        }
        
        if($::gLicenseHost && $::gLicenseHost ne "") {
            push(@kwecbuildArgs, "--license-host " . $::gLicenseHost);
        }
        
        if($::gLicensePort && $::gLicensePort ne "") {
            push(@kwecbuildArgs, "--license-port " . $::gLicensePort);
        }
        
        # if gEmakeRoots: add to command string
        if($::gPathToEmake && $::gPathToEmake ne "") {
            push(@kwecbuildArgs, qq{--ec-make "$::gPathToEmake"});
        }
        
        # if gcmdErrors: add to command string
        if($::gHostManager && $::gHostManager ne "") {
            push(@kwecbuildArgs, "--ec-host " . $::gHostManager);
        }  

        # if gTargets: add to command string
        if($::gOutputTablesDir && $::gOutputTablesDir ne "") {
            push(@kwecbuildArgs, qq{--output-dir "$::gOutputTablesDir"});
        }
        
        # if gTargets: add to command string
        if($::gBuildSpecFilePath && $::gBuildSpecFilePath ne "") {
            push(@kwecbuildArgs, qq{"$::gBuildSpecFilePath"});
        }
        
        # name of the buid trace file that kwinject is going to process
        if($::gBuildTraceFile && $::gBuildTraceFile ne ""){
            if($::gDebug && $::gDebug ne "")
            {
                push(@kwinjectArgs, "--debug");
            }
            push(@kwinjectArgs, qq{--trace-in "$::gBuildTraceFile" -o kwinject.out});
        }
        
        # name of the anotation file that kwlogparser will convert into a build trace file
        if($::gEmakeAnotationFile && $::gEmakeAnotationFile ne ""){
            push(@kwlogparserArgs, "-o");
            if($::gBuildTraceFile && $::gBuildTraceFile ne ""){
                push(@kwlogparserArgs, qq{"$::gBuildTraceFile"});
            }else{
                push(@kwlogparserArgs, "emake.trace");
            }
            push(@kwlogparserArgs, qq{emake-annotation "$::gEmakeAnotationFile"});
            # add debug information to the output
            if($::gDebug && $::gDebug ne ""){
                push(@kwlogparserArgs, "--debug");
            }
        }
        
        $props{"klocworkeaWorkingDir"} = "$::gWorkingDirectory";
        
        #generate the commands to execute in console
        
        #if any of the command arrays has more that 1 parameter it must be executed
        $props{"kwlogparserCommandLine"} = (@kwlogparserArgs > 1) ? createKlocworkEACommandLine(\@kwlogparserArgs) : "";
        $props{"kwinjectCommandLine"}    = (@kwinjectArgs    > 1) ? createKlocworkEACommandLine(\@kwinjectArgs) : "";
        $props{"klocworkeaCommandLine"}  = (@kwecbuildArgs   > 1) ? createKlocworkEACommandLine(\@kwecbuildArgs) : "";
        
        setProperties(\%props);
    }
    
    ########################################################################
    # createKlocworkEACommandLine - builds up the command line that will be executed 
    #                     by the plugin
    #
    # Arguments:
    #   -arr: array containing the command name in the first position and the
    #         arguments in the following positions
    #
    # Returns:
    #   -a string with the command line
    #
    ########################################################################
    sub createKlocworkEACommandLine($) {
        my ($arr) = @_;
        return join(" ", @$arr);
    }
    
    ########################################################################
    # setProperties - set a group of properties into the Electric Commander
    #
    # Arguments:
    #   -propHash: hash containing the ID and the value of the properties 
    #              to be written into the Electric Commander
    #
    # Returns:
    #   -nothing
    #
    ########################################################################
    sub setProperties($) {

        my ($propHash) = @_;
        
        my $pluginKey = 'EC-Klocwork-EA';
        my $xpath = $ec->getPlugin($pluginKey);
        my $pluginName = $xpath->findvalue('//pluginVersion')->value;
        print "Using plugin $pluginKey version $pluginName\n";
        
        foreach my $key (keys % $propHash) {
            my $val = $propHash->{$key};
            $ec->setProperty("/myCall/$key", $val);
        }
    }

    main();

