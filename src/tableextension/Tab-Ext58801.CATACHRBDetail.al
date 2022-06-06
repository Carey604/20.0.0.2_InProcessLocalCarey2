tableextension 58801 "CAT ACH RB Detail" extends "ACH RB Detail"
{
    fields
    {   // CAT.001 2020-06-01 CL - add 50210; "CAT Vendor Bank City State"
        // CAT.002 2020-06-24 CL- add fields 50211 50212. Std Amount (LCY) usage changed to save Amount from
        //      the GenJnlLine in some cases, so these new fields save the original values.
        // CAT.003 2020-06-29 CL - change CAT Bank Account No. from Text[20] to Text[30]

        //Current File Info        
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
        field(50002; "CAT File Creation Number"; Integer)
        {
            Caption = 'File Creation Number';
            DataClassification = ToBeClassified;
        }

        field(50003; "CAT Payment Date Year"; Integer)
        {
            Caption = 'Payment Date Year';
            DataClassification = ToBeClassified;
        }

        field(50004; "CAT Payment Date Day (Julian)"; Integer)
        {
            Caption = 'Payment Date Day (Julian)';
            DataClassification = ToBeClassified;
        }

        //Company Bank Account Info

        field(50100; "CAT Input Qualifier"; Code[50])
        {
            Caption = 'Input Qualifier';
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

        //Vendor Bank Account Info        

        field(50200; "CAT Vend. Bank Code"; Text[3])
        {
            Caption = 'Vendor Bank Insitution No.';
            DataClassification = ToBeClassified;
        }
        field(50201; "CAT Vendor Branch No."; Text[5])
        {
            Caption = 'Vendor Branch No.';
            DataClassification = ToBeClassified;
        }
        field(50202; "CAT Vendor Transit No."; Text[5])
        {
            Caption = 'Vendor Transit No.';
            DataClassification = ToBeClassified;
        }
        field(50203; "CAT Vendor Bank Name"; Text[100])
        {
            Caption = 'Vendor Bank Name';
            DataClassification = ToBeClassified;
        }
        field(50204; "CAT Vendor Bank Address"; Text[100])
        {
            Caption = 'Vendor Bank Address';
            DataClassification = ToBeClassified;
        }
        field(50205; "CAT Vendor Bank Address 2"; Text[100])
        {
            Caption = 'Vendor Bank Address 2';
            DataClassification = ToBeClassified;
        }
        field(50206; "CAT Vendor Bank City"; Text[30])
        {
            Caption = 'Vendor Bank City';
            DataClassification = ToBeClassified;
        }
        field(50207; "CAT Vendor Bank State"; Text[30])
        {
            Caption = 'Vendor Bank Province/State';
            DataClassification = ToBeClassified;
        }
        field(50208; "CAT Vendor Bank Post Code"; Code[20])
        {
            Caption = 'Vendor Bank Postal Code';
            DataClassification = ToBeClassified;
        }
        field(50209; "CAT Vendor Bank Country/Region"; Code[10])
        {
            Caption = 'Vendor Bank Country/Reg';
            DataClassification = ToBeClassified;
        }
        //>>CAT.001
        field(50210; "CAT Vendor Bank City State"; Text[60])
        {
            Caption = 'Vendor Bank City State';
            DataClassification = ToBeClassified;
        }
        field(50220; "CAT Vendor Bank ACH Rout. No."; Text[9])
        {
            Caption = 'Vendor Bank ACH Routing No.';
        }
        //<<CAT.001

        //File Creation Dates

        field(50300; CATFileCreationDateCYYDDD; Text[6])
        {
            Caption = 'File Creation Date (CYYDDD)';
            DataClassification = ToBeClassified;
        }


        field(50301; CATPaymentDateCYYDDD; Text[6])
        {
            Caption = 'Payment Date (CYYDDD)';
            DataClassification = ToBeClassified;
        }
        field(50302; CATPaymentDateDDMMYY; Text[6])
        {
            Caption = 'Payment Date (DDMMYY)';
            DataClassification = ToBeClassified;
        }
        field(50303; CATPaymentDateMMDDYY; Text[6])
        {
            Caption = 'Payment Date (MMDDYY)';
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

        field(50211; "CAT Original Amount (LCY)"; Decimal)
        {
            Caption = 'Original Amount (LCY)';
            DataClassification = ToBeClassified;
        }
        field(50212; "CAT Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
            DataClassification = ToBeClassified;
        }



    }
}