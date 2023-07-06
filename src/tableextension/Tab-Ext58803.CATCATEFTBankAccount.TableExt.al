tableextension 58803 "CATEFTBankAccount" extends "Bank Account"

{
    fields
    {
        field(58800; CATBankShortName; Text[15])
        {
            Caption = 'Originator Short Name';
            DataClassification = ToBeClassified;
        }

        field(58801; CATBankLongName; Text[30])
        {
            Caption = 'Originator Long Name';
            DataClassification = ToBeClassified;
        }

        field(58802; CATDestDataCentre; Text[5])
        {
            Caption = 'Destination Data Centre';
            DataClassification = ToBeClassified;
        }

        field(58803; CATOriginatorID; Text[10])
        {
            Caption = 'Originator ID';
            DataClassification = ToBeClassified;
        }

        field(58810; CATFileCreationDecrement; Integer)
        {
            Caption = 'File Creation Decrement';
            MinValue = 0;
            DataClassification = ToBeClassified;
        }
        field(58811; "CAT Skip EFT Curr. Code Check"; Boolean)
        {
            Caption = 'Skip EFT Currency Code Check';
            DataClassification = ToBeClassified;
        }
    }
}