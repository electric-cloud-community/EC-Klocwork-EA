my %runKwecbuild = (
    label       => "Klocwork-EA - Run kwecbuild",
    procedure   => "runKwecbuild",
    description => "Integrates klocwork's distributed analysis functionality into the Electric Accelerator based projects",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Klocwork-EA - runKwecbuild");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Klocwork-EA - Run kwecbuild");

@::createStepPickerSteps = (\%runKwecbuild);
