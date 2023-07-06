pageextension 58800 "CAT EFT Bank Account Fields" extends "Bank Account Card"
{
    // CAT.001 2022-06-06 CL - add fields to existing pagext. Used for ACH PAD (Pre-authorized debit)
    // CAT.002 2023-07-06 CL - add field to control whether to export Amount instead of Amount (LCY). See codeunit 58800.

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
                //>>CAT.001
                field("CAT ACH PAD Immediate Dest."; "CAT ACH PAD Immediate Dest.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the 9 digit routing number of the financial institution receiving the ACH file for processing pre-arranged payment or deposit. Typically, this is your bank''s routing and transit number';
                }
                field("CAT ACH PAD Immed. Dest. Name"; Rec."CAT ACH PAD Immed. Dest. Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the financial institution receiving the payment file for ACH pre-arranged payment or deposit.';
                }
                field("CAT ACH PAD Immediate Origin"; Rec."CAT ACH PAD Immediate Origin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the 9 digit routing transit number of the institution sending (originating) the ACH file for processing pre-arranged payment or deposit. (Often your ODFI (Originating Depository Financial Institution) will have you insert your company ID in this field.)';
                }
                field("CAT ACH PAD Immed. Origin Name"; Rec."CAT ACH PAD Immed. Origin Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the financial institution sending the payment file for ACH pre-arranged payment or deposit.';
                }
                field("CAT ACH PAD Company Name"; Rec."CAT ACH PAD Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Originator known and recognized by the Receiver.';

                }
                field("CAT ACH PAD Company Id."; Rec."CAT ACH PAD Company Id.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Originator. Assigned by the ODFI (Originating Depository Financial Institution).';
                }
                field("CAT ACH PAD Orig. Stat. Cd."; Rec."CAT ACH PAD Orig. Stat. Cd.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code referring to the ODFI (Originating Depository Financial Institution) initiating the entry.';
                }
                field("CAT ACH PAD Orig. DFI Id."; Rec."CAT ACH PAD Orig. DFI Id.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the routing number of the DFI (Depository Financial Institution) originating the entries within the batch in the payment file for ACH pre-arranged payment or deposit.';
                }
                field("CAT ACH PAD Filename Prefix"; Rec."CAT ACH PAD Filename Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the string to be prefixed to the export filename for pre-arranged payment or deposit';
                }
                //<<CAT.001
                //>>CAT.002
                field("CAT Use Src.Curr.Amt. EFT Exp."; Rec."CAT Use Src.Curr.Amt. EFT Exp.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to export the Amount (the non LCY amount) to the EFT export file. If false, the system will export what BC normally exports, which is the Amount (LCY) value (the amount in home currency).';
                }
                //<<CAT.002
            }
        }
    }
}