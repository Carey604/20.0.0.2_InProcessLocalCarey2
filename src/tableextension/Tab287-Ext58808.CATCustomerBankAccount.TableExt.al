tableextension 58808 "CAT Customer Bank Account" extends "Customer Bank Account" //287
{
    // CAT.001 2022-06-09 CL - new tabext
    fields
    {
        field(58800; "CAT ACH PAD Savings Account"; Boolean)
        {
            Caption = 'ACH Savings Account';
        }
        field(58801; "CAT ACH PAD Account Type"; Option)
        {
            Caption = 'ACH Account Type';
            OptionMembers = "Corporate","Consumer";
            OptionCaption = 'Corporate,Consumer';
        }
    }
}
