@::gMatchers = (
    #invalid license
    {
        id =>        "cs-invalid-license",
        pattern =>          q{FLEXlm Error -2, (.*)},
        action =>           q{&addSimpleError("cs-invalid-license", $1);updateSummary();},
    },
    #connection to license server
    {
        id =>        "cs-connection-error",
        pattern =>          q{FLEXlm Error -15, (.*)},
        action =>           q{&addSimpleError("cs-connection-error", $1);updateSummary();},
    },
    #invalid command option
    {
        id =>        "cs-invalid-command",
        pattern =>          q{Unrecognized options (.*)},
        action =>           q{&addSimpleError("cs-invalid-command","Option $1 is not recognized"); updateSummary();},
    },
    #invalid file
    {
        id =>        "cs-invalid-file",
        pattern =>          q{Unable to find file (.*)},
        action =>           q{&addSimpleError("cs-invalid-file", "Unable to find file: $1");updateSummary();},
    },
    #Licensed number of users already reached
    {
        id =>       "cs-number-users",
        pattern =>          q{FLEXlm Error -4, (.*)},
        action =>           q{&addSimpleError("cs-number-users",$1);updateSummary();},
    },
    #License server does not support this feature.
    {
        id =>       "cs-unsupported-feature",
        pattern =>          q{FLEXlm Error -18, (.*)},
        action =>           q{&addSimpleError("cs-unsupported-feature",$1);updateSummary();},
    },
    #errors and warnings
    {
        id =>       "cs-error-warning",
        pattern =>          q{(\d+) error\(s\) and (\d+) warning\(s\)},
        action =>           q{&addSimpleError("cs-error-warning","$1 error(s) and $2 warning(s)");updateSummary();},
    },
    {
        id =>        "cs-compiling",
        pattern =>          q{Compiling },
        action =>           q{incValueWithString("cs-compiles", "Compiled sources: 0");updateSummary();},
    },
    {
        id =>        "cs-analyzing",
        pattern =>          q{Analyzing },
        action =>           q{incValueWithString("cs-analyze", "Analyzed objects: 0");updateSummary();},
    },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub incValueWithString($;$$) {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString = (defined $::gProperties{$name}) ? $::gProperties{$name} :
                                                        $patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;
    
    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;

    setProperty ($name, $localString);
}

sub updateSummary() {
 
    my $summary = (defined $::gProperties{"cs-invalid-license"}) ? $::gProperties{"cs-invalid-license"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-connection-error"}) ? $::gProperties{"cs-connection-error"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-invalid-command"}) ? $::gProperties{"cs-invalid-command"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-invalid-file"}) ? $::gProperties{"cs-invalid-file"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-number-users"}) ? $::gProperties{"cs-number-users"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-unsupported-feature"}) ? $::gProperties{"cs-unsupported-feature"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-compiles"}) ? $::gProperties{"cs-compiles"} . "\n" : "";
	$summary   .= (defined $::gProperties{"cs-analyze"}) ? $::gProperties{"cs-analyze"} . "\n" : "";
    $summary   .= (defined $::gProperties{"cs-error-warning"}) ? $::gProperties{"cs-error-warning"} . "\n" : "";
    setProperty ("summary", $summary);
}