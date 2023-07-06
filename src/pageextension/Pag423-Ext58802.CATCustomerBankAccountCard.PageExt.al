pageextension 58802 "CAT Customer Bank Account Card" extends "Customer Bank Account Card" //423
{
    layout
    {
        addlast(Transfer)
        {
            field("CAT ACH PAD Savings Account"; Rec."CAT ACH PAD Savings Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the account is a savings account when used for ACH PPD exports.';
            }
            field("CAT ACH PAD Account Type"; Rec."CAT ACH PAD Account Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the account type of the bank account. When exporting ACH for Vendor payment, if account type is Corporate, then the SEC Code (Standard Entry Class Code) will be set to CCD. If account type is Consumer then the SEC code will be set to PPD.';
            }
        }
    }

    actions
    {

    }
}
