tableextension 58803 "CATEFTBankAccount" extends "Bank Account"
{
    // CAT.001 2022-06-06 CL - add fields to existing tabext. Used for ACH PAD (Pre-authorized debit)
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
        //>>CAT.001
        field(58820; "CAT ACH PAD Immed. Dest. Name"; Text[23])
        {
            Caption = 'ACH PPD Immediate Destination Name';
            DataClassification = CustomerContent;
        }
        field(58821; "CAT ACH PAD Immed. Origin Name"; Text[23])
        {
            Caption = 'ACH PPD Immediate Origin Name';
            DataClassification = CustomerContent;
        }
        field(58822; "CAT Last ACH PAD File DateTime"; DateTime)
        {
            Caption = 'Last ACH PPD File DateTime';
            Editable = false;
        }
        field(58823; "CAT Last ACH PAD File ID Mod."; Code[1])
        {
            Caption = 'Last ACH PPD File ID Modifier';
            Editable = false;
        }
        field(58825; "CAT ACH PAD Immediate Dest."; Text[10])
        {
            Caption = 'ACH PPD Immediate Destination';
        }
        field(58826; "CAT ACH PAD Immediate Origin"; Text[10])
        {
            Caption = 'ACH PPD Immediate Origin';
        }
        field(58827; "CAT ACH PAD Company Name"; Text[16])
        {
            Caption = 'ACH PPD Company Name';
        }
        field(58828; "CAT ACH PAD Company Id."; Text[10])
        {
            Caption = 'ACH PPD Company Identification';
        }
        field(58829; "CAT ACH PAD Orig. Stat. Cd."; Text[1])
        {
            Caption = 'ACH PPD Originator Status Code';
        }
        field(58830; "CAT ACH PAD Orig. DFI Id."; Text[8])
        {
            Caption = 'ACH PPD Originating DFI Identification';
        }
        field(58831; "CAT ACH PAD Filename Prefix"; Text[30])
        {
            Caption = 'ACH PPD Filename Prefix';
        }
        //<<CAT.001
    }
}