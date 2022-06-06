tableextension 58800 "CAT ACH RB Header" extends "ACH RB Header"
{
    fields
    {
        field(50000; "CAT File Creation Year"; Integer)
        {
            Caption = 'File Creation Year';
            DataClassification = ToBeClassified;
        }

        field(50001; "CAT File Creation Day (Julian)"; Integer)
        {
            Caption = 'File Creation Day (Julian)';
            DataClassification = ToBeClassified;
        }

        field(50101; "CAT Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            DataClassification = ToBeClassified;
        }

        field(50102; "CAT Bank Code"; Text[3])
        {
            Caption = 'Bank Code';
            DataClassification = ToBeClassified;
        }

        field(50103; "CAT Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
            DataClassification = ToBeClassified;
        }

        field(50104; "CAT Bank Transit No."; Text[20])
        {
            Caption = 'Bank Transit No.';
            DataClassification = ToBeClassified;
        }


        field(50110; "CAT Bank Short Name"; Text[15])
        {
            Caption = 'Originator Short Name';
            DataClassification = ToBeClassified;
        }

        field(50111; "CAT Bank Long Name"; Text[30])
        {
            Caption = 'Originator Long Name';
            DataClassification = ToBeClassified;
        }

        field(50112; "CAT Destination Data Centre"; Text[5])
        {
            Caption = 'Destination Data Centre';
            DataClassification = ToBeClassified;
        }

        field(50113; "CAT Originator ID"; Text[10])
        {
            Caption = 'Originator ID';
            DataClassification = ToBeClassified;
        }

        field(50300; CATFileCreationDateCYYDDD; Text[6])
        {
            Caption = 'File Creation Date (CYYDDD)';
            DataClassification = ToBeClassified;
        }

        field(50305; CATFileCreationDateDDMMYY; Text[6])
        {
            Caption = 'File Creation Date (DDMMYY)';
            DataClassification = ToBeClassified;
        }

        field(50306; CATFileCreationDateMMDDYY; Text[6])
        {
            Caption = 'File Creation Date (MMDDYY)';
            DataClassification = ToBeClassified;
        }

    }
}