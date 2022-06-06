pageextension 58800 "CAT EFT Bank Account Fields" extends "Bank Account Card"
{
    layout
    {
        addafter(Transfer)
        {
            group(CATEFTFields)
            {
                Caption = 'Additional EFT Fields';
                Editable = true;
                Visible = true;

                field(CATBankCode; "Bank Code")
                {
                    Caption = 'Bank Insitution No.';
                    ApplicationArea = All;
                }

                field(CATTransitNo; "Transit No.")
                {
                    Caption = 'Bank Transit No.';
                    ApplicationArea = All;
                }


                field(CATBranchNo; "Bank Branch No.")
                {
                    Caption = 'Bank Branch No.';
                    ApplicationArea = All;
                }

                field(CATAccountNo; "Bank Account No.")
                {
                    Caption = 'Bank Account No.';
                    ApplicationArea = All;
                }

                field(CATInputQualifier; "Input Qualifier")
                {
                    Caption = 'Input Qualifier';
                    ApplicationArea = All;
                }

                field(CATOriginatorID; CATOriginatorID)
                {
                    Caption = 'Originator ID';
                    ApplicationArea = All;
                }

                field(CATBankShortName; CATBankShortName)
                {
                    ApplicationArea = All;
                    Caption = 'Originator Short Name';
                }

                field(CATClientNo; "Client No.")
                {
                    Caption = 'Client No.';
                    ApplicationArea = All;
                }

                field(CATClientName; "Client Name")
                {
                    Caption = 'Client Name';
                    ApplicationArea = All;
                }

                field(CATBankLongName; CATBankLongName)
                {
                    Caption = 'Originator Long Name';
                    ApplicationArea = All;
                }

                field(CATDestDataCentre; CATDestDataCentre)
                {
                    Caption = 'Destination Data Centre';
                    ApplicationArea = All;
                }
            }
        }
    }
}